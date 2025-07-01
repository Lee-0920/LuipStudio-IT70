--[[
 * @brief 校准流程。
--]]

CalibrateType =
{
    calibrate= 0,
    oneKeyMaintain = 1,
    onlyCalibrateBlank = 2,
    onlyCalibrateStandard = 3,
}

CalibrateFlow = Flow:new
{
    calibrateDateTime = 0,
    zeroCalibrateDateTime = 0,
    standardCalibrateDateTime = 0,
    measureBlank = true,
    measureStandard = true,
    currentRange = 1,
    isUseStart = false,
    curveCalibrateRange = 0,
    lastResultInfo = "N",
}

function CalibrateFlow:new(o, target)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.calibrateDateTime = os.time()
    o.zeroCalibrateDateTime = status.measure.calibrate[config.measureParam.range[config.measureParam.calibrateRangeIndex + 1] + 1].zeroCalibrateDateTime
    o.standardCalibrateDateTime = status.measure.calibrate[config.measureParam.range[config.measureParam.calibrateRangeIndex + 1] + 1].standardCalibrateDateTime
    o.calibrateType = target
    o.currentRange = config.measureParam.range[config.measureParam.calibrateRangeIndex + 1] + 1
    o.isUseStart = false
    o.curveCalibrateRange = 0
    o.lastResultInfo = status.measure.newResult.measure.resultInfo
    o.zeroPeakArea = {0,0,0,0}
    o.standardPeakArea = {0,0,0,0}

    return o
end

function CalibrateFlow:GetRuntime()
    local runtime = 0
    if self.calibrateType == CalibrateType.calibrate then
        runtime = setting.runStatus.calibrate.GetTime()
    elseif self.calibrateType == CalibrateType.oneKeyMaintain then
        runtime = setting.runStatus.oneKeyMaintain.GetTime()
    elseif self.calibrateType == CalibrateType.onlyCalibrateBlank then
        runtime = setting.runStatus.onlyCalibrateBlank.GetTime()
    elseif self.calibrateType == CalibrateType.onlyCalibrateStandard then
        runtime = setting.runStatus.onlyCalibrateStandard.GetTime()
    end
    return runtime
end

function CalibrateFlow:OnStart()
    if 1 == config.system.OEM and self.calibrateType == CalibrateType.oneKeyMaintain then
        self.calibrateType = CalibrateType.calibrate
    end
    --组合流程需要重新加载时间
    self.calibrateDateTime = os.time()
    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()

    status.measure.isUseStart = self.isUseStart
    status.measure.newResult.measure.resultInfo = "C"
    ConfigLists.SaveMeasureStatus()

    --继电器指示
    Helper.Result.RelayOutOperate(setting.mode.relayOut.calibrateInstruct, true)

    --设置运行状态
    local runStatus
    if self.curveCalibrateRange == 1 then
        runStatus = Helper.Status.SetStatus(setting.runStatus.range1CurveCalibrate)
        self.currentRange = config.measureParam.range[1] + 1 --量程二校准
    elseif self.curveCalibrateRange == 2 then
        runStatus = Helper.Status.SetStatus(setting.runStatus.range2CurveCalibrate)
        self.currentRange = config.measureParam.range[2] + 1 --量程三校准
    elseif self.curveCalibrateRange == 3 then
        runStatus = Helper.Status.SetStatus(setting.runStatus.range3CurveCalibrate)
        self.currentRange = config.measureParam.range[3] + 1 --量程三校准
    else
        if self.calibrateType == CalibrateType.oneKeyMaintain then
            runStatus = Helper.Status.SetStatus(setting.runStatus.oneKeyMaintain)
            self.currentRange = config.measureParam.range[config.measureParam.calibrateRangeIndex + 1] + 1
        elseif self.calibrateType == CalibrateType.onlyCalibrateBlank then
            runStatus = Helper.Status.SetStatus(setting.runStatus.onlyCalibrateBlank)
            self.currentRange = config.measureParam.range[config.measureParam.calibrateRangeIndex + 1] + 1
        elseif self.calibrateType == CalibrateType.onlyCalibrateStandard then
            runStatus = Helper.Status.SetStatus(setting.runStatus.onlyCalibrateStandard)
            self.currentRange = config.measureParam.range[config.measureParam.calibrateRangeIndex + 1] + 1
        else
            runStatus = Helper.Status.SetStatus(setting.runStatus.calibrate)
        end
    end

    StatusManager.Instance():SetStatus(runStatus)

    --重设LED测量周期
    op:ResetLEDMeasurePeriod()

    --检查压力补偿状态
    op:CheckCarryPressureOffsetStatus()

    --检测消解室是否为安全温度
    op:CheckDigestSafety()
end


function CalibrateFlow:OnProcess()
    local initAbsorbance = {0,0}
    local absorbance = {0,0}
    local peakArea = {0,0}
    local consistency = {config.measureParam.curveParam[self.currentRange].ZeroConsistency,config.measureParam.curveParam[self.currentRange].RangeConsistency}
    local addParam = {setting.calibrate[1],setting.calibrate[2]}
    local measureResult1 = Measurer:GetZeroMeasureResult()
    local measureResult2 = Measurer:GetZeroMeasureResult()
    local measureAD1 = MeasureAD:new()
    local measureAD2 = MeasureAD:new()
    local curveK = 1
    local curveB = 0
    local meausureConsistency = {}
    local checkError = {}
    local oneTimesCreateCurve = false
    if config.measureParam.range[config.measureParam.currentRange + 1] + 1 == 1 then
        --setting.measureResult.startReactVolume = setting.measureResult.reactVolume[2] --更新反应体积
        --config.measureParam.addSampleCnt = 2
        config.measureParam.carryingPressure = config.measureParam.preCarryingPressure
        setting.measureResult.startReactVolume = setting.measureResult.lowConsistencyReactVolume[2] --更新反应体积
        config.measureParam.addSampleCnt = 2
    else
        setting.measureResult.startReactVolume = setting.measureResult.reactVolume[1] --更新反应体积
        config.measureParam.addSampleCnt = 1
        config.measureParam.carryingPressure = config.measureParam.preCarryingPressure
    end
    ConfigLists.SaveMeasureParamConfig()

    --开总阀，保证总阀全程开着，只通过比例阀调节流速
    op:TurnOnNirtrogen()

    App.Sleep(500)
    --开始更新基线状态
    status.measure.isCheckBaseLine = true
    ConfigLists.SaveMeasureStatus()

    UpdateWidgetManager.Instance():Update(UpdateEvent.BaseLineStatusChanged, "Failed")

    App.Sleep(500)

    self.isUserStop = false
    self.isFinish = false

    if self.calibrateType == CalibrateType.calibrate or self.calibrateType == CalibrateType.oneKeyMaintain then
        self:CleanDeeplyCheckTime()
    end

    if config.measureParam.rangeAccurateCalibrate == true then
        config.measureParam.zeroAccurateCalibrate = true
        config.measureParam.standardAccurateCalibrate = true
    else
        config.measureParam.zeroAccurateCalibrate = false
        config.measureParam.standardAccurateCalibrate = false
    end


    if self.curveCalibrateRange > 0 then
        if status.measure.standardCurve > 0 then
            self.measureBlank = false
            self.measureStandard = true
            peakArea[1] = status.measure.calibrate[status.measure.standardCurve].point0Absorbance
        else
            log:info("不存在基准标线，无法进行量程系数校正")
            return
        end
    else
        --一键运行增加管路更新操作
        if self.calibrateType == CalibrateType.oneKeyMaintain then
            oneTimesCreateCurve = true
            self:PipeRenew()
        elseif self.calibrateType == CalibrateType.onlyCalibrateBlank then   --零点校准
            self.measureBlank = true
            self.measureStandard = false
            peakArea[2] = status.measure.calibrate[self.currentRange].point1Absorbance
        elseif self.calibrateType == CalibrateType.onlyCalibrateStandard then  --量程校准
            self.measureBlank = false
            self.measureStandard = true
            peakArea[1] = status.measure.calibrate[self.currentRange].point0Absorbance
        else
            oneTimesCreateCurve = config.measureParam.updateAllCalibrateKB
        end
    end

    --零点校准和量程校准时间更新
    local timeRecord = os.time()
    if self.measureBlank == true and self.measureStandard == true then
        self.zeroCalibrateDateTime = timeRecord
        self.standardCalibrateDateTime = timeRecord
    elseif self.measureBlank == false and self.measureStandard == true then
        self.standardCalibrateDateTime = timeRecord
    elseif self.measureBlank == true and self.measureStandard == false then
        self.zeroCalibrateDateTime = timeRecord
    end

    --需要测量零点
    if self.measureBlank == true then
        --测量零点
        log:debug("校准-零点测量")

        if Measurer.flow then
            Measurer:Reset()
        end
        Measurer.flow = self
        Measurer.measureType = MeasureType.Blank
        Measurer.currentRange = self.currentRange
        for k,v in pairs(addParam[1]) do
            Measurer.addParam [k] = v
        end
        --根据量程修改参数
        Measurer.addParam.standardVolume = 0
        Measurer.addParam.blankVolume = setting.measure.range[self.currentRange].blankVolume + setting.measure.range[self.currentRange].sampleVolume
        Measurer.addParam.dilutionExtractVolume1 = setting.measure.range[self.currentRange].dilutionExtractVolume1
        Measurer.addParam.dilutionAddBlankVolume1 = setting.measure.range[self.currentRange].dilutionAddBlankVolume1
        Measurer.addParam.dilutionExtractVolume2 = setting.measure.range[self.currentRange].dilutionExtractVolume2
        Measurer.addParam.dilutionAddBlankVolume2 = setting.measure.range[self.currentRange].dilutionAddBlankVolume2
        Measurer.addParam.dilutionExtractVolume3 = setting.measure.range[self.currentRange].dilutionExtractVolume3
        Measurer.addParam.dilutionAddBlankVolume3 = setting.measure.range[self.currentRange].dilutionAddBlankVolume3
        Measurer.addParam.afterReagent1AddBlankVolume = setting.measure.range[self.currentRange].afterReagent1AddBlankVolume
        Measurer.addParam.diluteFactor = setting.measure.range[self.currentRange].diluteFactor
        Measurer.addParam.rinseSampleVolume = 0
        Measurer.addParam.rinseBlankVolume = setting.measure.range[self.currentRange].rinseStandardVolume + setting.measure.range[self.currentRange].rinseSampleVolume
        Measurer.addParam.rinseStandardVolume = 0

        --零点流程执行
        local handleType = AccurateType.normal
        if config.measureParam.zeroAccurateCalibrate == true then
            handleType = AccurateType.normalWithoutClean
        end
        local err,result = pcall(function() return Measurer:CalibrateMeasure(handleType) end)
        if not err then      -- 出现异常
            if type(result) == "table" then
                if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                    self.isUserStop = true
                    error(result)
                else
                    error(result)
                end
            else
                error(result)
            end
        else    -- 正常
            measureAD1.initReference = result.initReferenceAD
            measureAD1.initMeasure = result.initMeasureAD
            measureAD1.finalReference = result.finalReferenceAD
            measureAD1.finalMeasure = result.finalMeasureAD

            --零点峰面积计算
            initAbsorbance[1] = measureAD1:CalculateInitAbsorbance()
            absorbance[1] = measureAD1:CalculateRelAbsorbance()

            peakArea[1] = result.peakArea
            self.zeroPeakArea[1] = string.format("%.2f", peakArea[1])
            log:debug("第一次空白水测试峰面积= " .. peakArea[1])

            for k,v in pairs(result) do
                measureResult1[k] = v
            end
            local volumeFactor = 1
            meausureConsistency[1] = self:CalculateConsistency(peakArea[1])/volumeFactor
            --log:debug("体积系数： " .. volumeFactor)
            checkError[1] = math.abs(meausureConsistency[1] - config.measureParam.curveParam[self.currentRange].ZeroConsistency)/config.measureParam.curveParam[self.currentRange].RangeConsistency
            log:debug("零点计算浓度 = " .. meausureConsistency[1].." ，偏差为 "..checkError[1]*100 .." %")
        end

        --零点精准校准 强制校准3次
        if config.measureParam.zeroAccurateCalibrate == true then
            -- 测量流程执行
            local err,result = pcall(function() return CalibrateFlow:AccurateCalibrate(peakArea[1], config.measureParam.rangeCalibrateDeviation, self, MeasureType.Blank) end)
            if not err then      -- 出现异常
                if type(result) == "table" then
                    if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                        self.isUserStop = true
                        error(result)
                    elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                        self.isUserStop = true
                        error(result)
                    elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                        self.isUserStop = true
                        error(result)
                    elseif getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                        self.isUserStop = true
                        error(result)
                    elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                        self.isUserStop = true
                        error(result)
                    else
                        error(result)
                    end
                else
                    error(result)
                end
            else    -- 正常
                --absorbance[1] = result   ----获取结果
                peakArea[1] = result
                --			print("absorbance[1] = "..absorbance[1])
            end
        end
    end

    --需要测量标点
    if self.measureStandard == true then
        --检测消解室是否为安全温度
        op:CheckDigestSafety()

        log:debug("校准-标点测量")

        --测量标点
        if Measurer.flow then
            Measurer:Reset()
        end
        Measurer.flow = self
        Measurer.measureType = MeasureType.Standard
        Measurer.currentRange = self.currentRange
        for k,v in pairs(addParam[2]) do
            Measurer.addParam [k] = v
        end

        --根据量程修改参数
        Measurer.addParam.standardVolume = setting.measure.range[self.currentRange].sampleVolume
        Measurer.addParam.blankVolume = setting.measure.range[self.currentRange].blankVolume
        Measurer.addParam.dilutionExtractVolume1 = setting.measure.range[self.currentRange].dilutionExtractVolume1
        Measurer.addParam.dilutionAddBlankVolume1 = setting.measure.range[self.currentRange].dilutionAddBlankVolume1
        Measurer.addParam.dilutionExtractVolume2 = setting.measure.range[self.currentRange].dilutionExtractVolume2
        Measurer.addParam.dilutionAddBlankVolume2 = setting.measure.range[self.currentRange].dilutionAddBlankVolume2
        Measurer.addParam.dilutionExtractVolume3 = setting.measure.range[self.currentRange].dilutionExtractVolume3
        Measurer.addParam.dilutionAddBlankVolume3 = setting.measure.range[self.currentRange].dilutionAddBlankVolume3
        Measurer.addParam.afterReagent1AddBlankVolume = setting.measure.range[self.currentRange].afterReagent1AddBlankVolume
        Measurer.addParam.diluteFactor = setting.measure.range[self.currentRange].diluteFactor
        Measurer.addParam.rinseSampleVolume = 0
        Measurer.addParam.rinseBlankVolume = 0
        Measurer.addParam.rinseStandardVolume = setting.measure.range[self.currentRange].rinseStandardVolume + setting.measure.range[self.currentRange].rinseSampleVolume

        --标点流程执行
        local handleType = AccurateType.normal
        if config.measureParam.standardAccurateCalibrate == true then
            handleType = AccurateType.normalWithoutClean
        end
        local err,result = pcall(function() return Measurer:CalibrateMeasure(handleType)  end)
        if not err then      -- 出现异常
            if type(result) == "table" then
                if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                    self.isUserStop = true
                    error(result)
                else
                    error(result)
                end
            else
                error(result)
            end
        else    -- 正常
            measureAD2.initReference = result.initReferenceAD
            measureAD2.initMeasure = result.initMeasureAD
            measureAD2.finalReference = result.finalReferenceAD
            measureAD2.finalMeasure = result.finalMeasureAD

            --标点峰面积计算
            initAbsorbance[2] = measureAD2:CalculateInitAbsorbance()
            absorbance[2] = measureAD2:CalculateRelAbsorbance()

            peakArea[2] = result.peakArea
            self.standardPeakArea[1] =  peakArea[2]
            log:debug("第一次标液测试峰面积= " .. peakArea[2])

            for k,v in pairs(result) do
                measureResult2[k] = v
            end
            local volumeFactor = 1
            meausureConsistency[2] = self:CalculateConsistency(peakArea[2])/volumeFactor
            --log:debug("体积系数： " .. volumeFactor)
            checkError[2] = math.abs(meausureConsistency[2] - config.measureParam.curveParam[self.currentRange].RangeConsistency)/config.measureParam.curveParam[self.currentRange].RangeConsistency

            log:debug("标点计算浓度 = " .. meausureConsistency[2].." ，偏差为 "..checkError[2]*100 .." %")

        end
        --标点精准校准
        if config.measureParam.standardAccurateCalibrate == true then
            -- 测量流程执行
            local err,result = pcall(function() return CalibrateFlow:AccurateCalibrate(peakArea[2], config.measureParam.rangeCalibrateDeviation, self, MeasureType.Standard) end)
            if not err then      -- 出现异常
                if type(result) == "table" then
                    if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                        self.isUserStop = true
                        error(result)
                    elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                        self.isUserStop = true
                        error(result)
                    elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                        self.isUserStop = true
                        error(result)
                    elseif getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                        self.isUserStop = true
                        error(result)
                    elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                        self.isUserStop = true
                        error(result)
                    else
                        error(result)
                    end
                else
                    error(result)
                end
            else    -- 正常
                peakArea[2] = result ----获取结果
                --			print("absorbance[2] = "..absorbance[2])
            end
        end
    end

    if self.calibrateType == CalibrateType.oneKeyMaintain or self.calibrateType == CalibrateType.calibrate then
        --保存基准线
        status.measure.standardCurve = self.currentRange
    end

    local absorbancess = (peakArea[2] - peakArea[1]) * setting.measure.range[self.currentRange].diluteFactor / config.measureParam.curveParam[self.currentRange].RangeConsistency / config.measureParam.reviseParameter[self.currentRange]
    local calibrateRange  = self.currentRange
    local rangeTable = {}
    table.insert(rangeTable, self.currentRange)
    if oneTimesCreateCurve then
        table.remove(rangeTable, 1)
        for i = 1, setting.measure.range.rangeNum do
            if i ~= self.currentRange then
                table.insert(rangeTable, i)
            end
        end
        table.insert(rangeTable, self.currentRange)
    end

    for i, range in pairs(rangeTable) do
        local showPeakArea = {peakArea[1],peakArea[2]}
        if math.abs(consistency[2] - consistency[1]) < 0.000001 then
            log:info("校准结果计算异常")
            error(CalibrateResultWrongException:new())
        else
            if oneTimesCreateCurve then
                --刷新浓度
                self.currentRange = range
                consistency = {config.measureParam.curveParam[range].ZeroConsistency,
                               config.measureParam.curveParam[range].RangeConsistency}
                if self.currentRange ~= calibrateRange then
                    showPeakArea = {0,0}
                else
                    showPeakArea = {peakArea[1],peakArea[2]}
                end
                --一键校准量程以0-100斜率为参考
                local ZeroConsistency = config.measureParam.curveParam[calibrateRange].ZeroConsistency
                local RangeConsistency = config.measureParam.curveParam[calibrateRange].RangeConsistency
                local realDiluteFactor = {0.5 ,1 ,8.89 ,19.56 ,52.29}

                -- 计算K，B值
                curveK = (peakArea[2] - peakArea[1])/(RangeConsistency - ZeroConsistency)
                curveB = peakArea[2] - curveK * RangeConsistency -- B = A2-KC2 or B = A1-KC1, 当前C1 = 0

                --非0-100量程先换算到0-100量程
                if calibrateRange ~= 2 then
                    curveK = curveK * realDiluteFactor[calibrateRange]
                    if calibrateRange == 1 then
                        curveB = curveB * realDiluteFactor[calibrateRange]
                    end
                end

                if range == 1 then
                    curveK = curveK * 2
                    curveB = curveB * 2
                elseif range == 3 then
                    curveK = curveK / 8.89
                elseif range == 4 then
                    curveK = curveK / 19.56
                elseif range == 5 then
                    curveK = curveK / 52.29
                end
            else
                -- 计算K，B值
                curveK = (peakArea[2] - peakArea[1])/(consistency[2] - consistency[1])
                curveB = peakArea[2] - curveK * consistency[2] -- B = A2-KC2 or B = A1-KC1, 当前C1 = 0
            end
        end

        if self.curveCalibrateRange > 0 then
            config.measureParam.reviseParameter[self.currentRange] = self:CalculateReviseParam(peakArea[2])
        end

        local curveQualified = false
        --if config.measureParam.curveQualifiedDetermination == true and false == oneTimesCreateCurve then
        --    if setting.measureResult.curve[self.currentRange].curveKUpLimit ~= nil then
        --        if setting.measureResult.curve[self.currentRange].curveKUpLimit < curveK or curveK < setting.measureResult.curve[self.currentRange].curveKLowLimit then
        --            log:warn("curveK = "..curveK..",斜率合理范围为 "..setting.measureResult.curve[self.currentRange].curveKLowLimit.." ~ "..setting.measureResult.curve[self.currentRange].curveKUpLimit.."，标线斜率异常")
        --            local alarm = Helper.MakeAlarm(setting.alarm.curveNotQualifiedWrong, "")
        --            AlarmManager.Instance():AddAlarm(alarm)
        --            curveQualified = true
        --        end
        --    else
        --        log:info("量程 "..self.currentRange.."斜率未设置合理范围")
        --    end
        --end

        -- 保存校准结果
        --	print("Push calibrate result data to file.")
        local resultManager = ResultManager.Instance()
        local recordData = RecordData.new(resultManager:GetCalibrateRecordDataSize(setting.resultFileInfo.calibrateRecordFile[1].name))
        recordData:PushInt(self.calibrateDateTime) 			        -- 时间
        recordData:PushDouble(curveK)   				            --标线斜率K
        recordData:PushDouble(curveB)   				            --标线截距B

        recordData:PushFloat(showPeakArea[1]) 			            -- 零点反应峰面积
        recordData:PushFloat(consistency[1]) 			            -- 零点浓度
        recordData:PushFloat(self.zeroPeakArea[1])		            	-- 零点第一次峰面积
        recordData:PushFloat(self.zeroPeakArea[2])		            	-- 零点第二次峰面积
        recordData:PushFloat(self.zeroPeakArea[3])		            	-- 零点第三次峰面积
        recordData:PushFloat(measureResult1.initRefrigeratorTemp)      	-- 零点初始制冷模块温度
        recordData:PushFloat(measureResult1.initNDIRTemp) 		        -- 零点初始测量模块温度
        recordData:PushFloat(measureResult1.finalRefrigeratorTemp) 	    -- 零点反应制冷模块温度
        recordData:PushFloat(measureResult1.finalNDIRTemp) 	            -- 零点反应测量模块温度
        recordData:PushFloat(measureResult1.initThermostatTemp) 	    -- 零点初始值燃烧炉温度
        recordData:PushFloat(measureResult1.initEnvironmentTemp) 	    -- 零点反应值上机箱温度
        recordData:PushFloat(measureResult1.initEnvironmentTempDown) 	-- 零点反应值下机箱温度
        recordData:PushFloat(measureResult1.finalThermostatTemp) 	    -- 零点反应值燃烧炉温度
        recordData:PushFloat(measureResult1.finalEnvironmentTemp) 	    -- 零点反应值上机箱温度
        recordData:PushFloat(measureResult1.finalEnvironmentTempDown) 	-- 零点反应值下机箱温度

        recordData:PushFloat(showPeakArea[2]) 			                -- 标点峰面积
        recordData:PushFloat(consistency[2]) 		            	    -- 标点浓度
        recordData:PushFloat(self.standardPeakArea[1])		            -- 标点第一次峰面积
        recordData:PushFloat(self.standardPeakArea[2])		-- 标点第二次峰面积
        recordData:PushFloat(self.standardPeakArea[3])       -- 标点第三次峰面积
        recordData:PushFloat(measureResult2.initRefrigeratorTemp)      	-- 标点初始制冷模块温度
        recordData:PushFloat(measureResult2.initNDIRTemp) 		        -- 标点初始测量模块温度
        recordData:PushFloat(measureResult2.finalRefrigeratorTemp) 	    -- 标点反应制冷模块温度
        recordData:PushFloat(measureResult2.finalNDIRTemp) 	            -- 标点反应测量模块温度
        recordData:PushFloat(measureResult2.initThermostatTemp) 	    -- 标点初始值燃烧炉温度
        recordData:PushFloat(measureResult2.initEnvironmentTemp) 	    -- 标点反应值上机箱温度
        recordData:PushFloat(measureResult2.initEnvironmentTempDown) 	-- 标点反应值下机箱温度
        recordData:PushFloat(measureResult2.finalThermostatTemp) 	    -- 标点反应值燃烧炉温度
        recordData:PushFloat(measureResult2.finalEnvironmentTemp) 	    -- 标点反应值上机箱温度
        recordData:PushFloat(measureResult2.finalEnvironmentTempDown) 	-- 标点反应值下机箱温度

        recordData:PushFloat(1)					                    -- 曲线线性度R2
        recordData:PushInt(os.time()-self.calibrateDateTime) 	    -- 校准时长
        recordData:PushFloat(config.system.rangeViewMap[self.currentRange].view)                 --当前量程

        local flowManager = FlowManager.Instance()
        if true == flowManager:IsReagentAuthorize() then
            if curveQualified == false then
                log:debug("保存量程 "..self.currentRange.." ,校准结果，K： "..curveK.." B： "..curveB)
                Helper.Result.OnCalibrateResultAdded(self.calibrateDateTime, self.zeroCalibrateDateTime, self.standardCalibrateDateTime,curveK, curveB, consistency[1], consistency[2], showPeakArea[1], showPeakArea[2],self.currentRange ,false)
                Helper.Result.OnSaveCalibrateConsistencyAdded(meausureConsistency[1],meausureConsistency[2],checkError[1],checkError[2],self.currentRange)
                op:SaveCalibrationTimeStr(self.calibrateDateTime,self.currentRange)
            end
            resultManager:AddCalibrateRecord(setting.resultFileInfo.calibrateRecordFile[1].name, recordData)
            setting.ui.profile.measureParam.updaterCurveParam(0,true)
            config.modifyRecord.measureParam(true)
            ConfigLists.SaveMeasureParamConfig()
            ConfigLists.SaveMeasureStatus()
        else
            local alarm = Helper.MakeAlarm(setting.alarm.reagentAuthorizationError, "")
            AlarmManager.Instance():AddAlarm(alarm)

            status.measure.schedule.autoCalibrate.dateTime = self.calibrateDateTime
        end

        self.isFinish = true

        --if self.measureBlank == true then
        --    log:debug("校准-零点 iRef  =" .. measureResult1.initReferenceAD .. ",iMea  = " .. measureResult1.initMeasureAD .. ", fRef  = " .. measureResult1.finalReferenceAD .. ", fMea  = " .. measureResult1.finalMeasureAD .. ", A  = " .. peakArea[1])
        --end
        if self.measureStandard == true then
            log:debug("校准-标点 iRef  =" .. measureResult2.initReferenceAD .. ",iMea  = " .. measureResult2.initMeasureAD .. ", fRef  = " .. measureResult2.finalReferenceAD .. ", fMea  = " .. measureResult2.finalMeasureAD .. ", A  = " .. peakArea[2])
        end
        log:debug("曲线 k  = " .. curveK .. "B = " .. curveB)
    end
end

function CalibrateFlow:OnStop()
    --保存载气压力
    config.measureParam.carryingPressure = config.measureParam.preCarryingPressure
    ConfigLists.SaveMeasureParamConfig()

    if nil ~= setting.common.skipFlow and true == setting.common.skipFlow then

    else
        if setting.sensor.isValid == true then
            op:SlidersSensorCheck()
        end
    end

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()
    op:TurnOffNirtrogen(setting.pressure.delayTime)
    dc:GetIOpticalAcquire():TurnOffLED()	--关LED
    dc:ClearBuf()--清buf,防止数组刷新

    --继电器指示
    Helper.Result.RelayOutOperate(setting.mode.relayOut.calibrateInstruct, false)

    if self.calibrateType == CalibrateType.calibrate or self.calibrateType == CalibrateType.oneKeyMaintain then
        status.measure.schedule.autoCalibrate.dateTime = self.calibrateDateTime
    end

    if not self.isFinish then
        if self.isUserStop then
            status.measure.newResult.measure.resultInfo = self.lastResultInfo
            self.result = "用户终止"
            log:info("用户终止")
        else
            status.measure.newResult.measure.resultInfo = "D"
            self.result = "故障终止"
            log:warn("故障终止")
        end
    else
        local flowStr = "校准"
        if self.calibrateType == CalibrateType.oneKeyMaintain then
            flowStr = "一键运行"
        elseif self.calibrateType == CalibrateType.onlyCalibrateBlank then
            flowStr = "零点校准"
        elseif self.calibrateType == CalibrateType.onlyCalibrateStandard then
            flowStr = "量程校准"
        end

        self.result = flowStr.."完成"
        log:info(self.result)
        log:info(flowStr.."总时间 = ".. os.time()-self.calibrateDateTime)
    end

    --保存试剂余量表
    ReagentRemainManager.SaveRemainStatus()

    --停止峰形图数据更新
    UpdateWidgetManager.Instance():Update(UpdateEvent.PeakStatusChanged, "Stop")
    App.Sleep(500)

    --开始更新基线状态
    status.measure.isCheckBaseLine = false
    status.measure.isUseStart = false
    ConfigLists.SaveMeasureStatus()

    UpdateWidgetManager.Instance():Update(UpdateEvent.BaseLineStatusChanged, "Stop")
    App.Sleep(500)

    --检测消解室是否为安全温度
    op:CheckDigestSafety()

end

--[[
 * @brief 精准校准处理
 * @param[in] refAbs 参考吸光度
 * @param[in] waveRange 限制波动范围
--]]
function CalibrateFlow:AccurateCalibrate(area, waveRange, calibrateFlow, measureType)
    local measureAD = MeasureAD:new()
    local tempPeakArea1,tempPeakArea2,tempPeakArea3,tempPeakArea4
    local peakArea

    tempPeakArea1 = area;
    log:debug("第1次校准测量峰面积 area = ".. tempPeakArea1)
    --	print("tempAbsorbance1 = "..tempAbsorbance1)
    --检测消解室是否为安全温度
    op:CheckDigestSafety()

    -- 校准测量
    log:debug("精准校准测量2")

    -- 测量流程执行
    local err,result = pcall(function() return Measurer:CalibrateMeasure(AccurateType.onlyAddSample) end)
    if not err then      -- 出现异常
        if type(result) == "table" then
            if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                self.isUserStop = true
                error(result)
            elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                self.isUserStop = true
                error(result)
            elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                self.isUserStop = true
                error(result)
            elseif getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                self.isUserStop = true
                error(result)
            elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                self.isUserStop = true
                error(result)
            else
                error(result)
            end
        else
            error(result)
        end
    else    -- 正常
        measureAD.initReference = result.initReferenceAD
        measureAD.initMeasure = result.initMeasureAD
        measureAD.finalReference = result.finalReferenceAD
        measureAD.finalMeasure = result.finalMeasureAD

        --tempPeakArea2 = measureAD:CalculateRelAbsorbance()
        tempPeakArea2 = result.peakArea
        if measureType == MeasureType.Blank then
            calibrateFlow.zeroPeakArea[2] =  string.format("%.2f", tempPeakArea2)
        else
            calibrateFlow.standardPeakArea[2] =  string.format("%.2f", tempPeakArea2)
        end
        log:debug("第2次校准测量峰面积 area = " .. tempPeakArea2)
    end

    --local deviation12 = math.abs(tempPeakArea1 - tempPeakArea2)/(math.abs(tempPeakArea1 + tempPeakArea2)/2)
    local deviation12 = 1
    if deviation12 < waveRange then ----------两次校准偏差小于阈值

        peakArea = (tempPeakArea1 + tempPeakArea2)/2
        log:debug("峰面积平均修正 peakArea = ".. peakArea)
        --清洗流程执行
        local err,result = pcall(function() return  Measurer:CalibrateMeasureClean() end)
        if not err then      -- 出现异常
            if type(result) == "table" then
                if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                    self.isUserStop = true
                    error(result)
                else
                    error(result)
                end
            else
                error(result)
            end

        end

    else  ----------两次校准偏差大于阈值
        --检测消解室是否为安全温度
        op:CheckDigestSafety()
        -- 校准-第三次测量
        log:debug("精准校准测量3")

        --流程执行
        local err,result = pcall(function() return Measurer:CalibrateMeasure(AccurateType.onlyAddSample) end)
        if not err then      -- 出现异常
            if type(result) == "table" then
                if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                    self.isUserStop = true
                    error(result)
                else
                    error(result)
                end
            else
                error(result)
            end
        else    -- 正常
            measureAD.initReference = result.initReferenceAD
            measureAD.initMeasure = result.initMeasureAD
            measureAD.finalReference = result.finalReferenceAD
            measureAD.finalMeasure = result.finalMeasureAD

            --tempPeakArea3 = measureAD:CalculateRelAbsorbance()
            tempPeakArea3 = result.peakArea
            if measureType == MeasureType.Blank then
                calibrateFlow.zeroPeakArea[3] = string.format("%.2f", tempPeakArea3)
            else
                calibrateFlow.standardPeakArea[3] = string.format("%.2f", tempPeakArea3)
            end
            log:debug("第3次校准测量峰面积 area= " .. tempPeakArea3)

            ----判断精准校准结果是否满足要求
            --local deviation13 = math.abs(tempPeakArea1 - tempPeakArea3)/(tempPeakArea1 + tempPeakArea3)/2
            --local deviation23 = math.abs(tempPeakArea2 - tempPeakArea3)/(tempPeakArea2 + tempPeakArea3)/2
            ----if deviation13 >= waveRange and deviation23 >= waveRange then
            ----    peakArea = (tempPeakArea1 + tempPeakArea2 + tempPeakArea3)/3
            ----    log:debug("峰面积123平均修正 peakArea = " .. peakArea)
            ----	--log:debug("校准结果错误")
            ----	--error(CalibrateResultWrongException:new())
            ----else
            --	if deviation13 < deviation23 then
            --        peakArea = (tempPeakArea1 + tempPeakArea3)/2
            --		log:debug("峰面积13平均修正 Absorbance = " .. peakArea)
            --	else
            --        peakArea = (tempPeakArea2 + tempPeakArea3)/2
            --		log:debug("峰面积23平均修正 Absorbance = " .. peakArea)
            --	end
            ----end
        end

        --检测消解室是否为安全温度
        op:CheckDigestSafety()
        -- 校准-第三次测量
        log:debug("精准校准测量4")

        --流程执行
        local err,result = pcall(function() return Measurer:CalibrateMeasure(AccurateType.addSampleWithClean) end)
        if not err then      -- 出现异常
            if type(result) == "table" then
                if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                    self.isUserStop = true
                    error(result)
                elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                    self.isUserStop = true
                    error(result)
                else
                    error(result)
                end
            else
                error(result)
            end
        else    -- 正常
            measureAD.initReference = result.initReferenceAD
            measureAD.initMeasure = result.initMeasureAD
            measureAD.finalReference = result.finalReferenceAD
            measureAD.finalMeasure = result.finalMeasureAD

            tempPeakArea4 = result.peakArea
            if measureType == MeasureType.Blank then
                calibrateFlow.zeroPeakArea[4] = string.format("%.2f", tempPeakArea4)
            else
                calibrateFlow.standardPeakArea[4] = string.format("%.2f", tempPeakArea4)
            end
            log:debug("第4次校准测量峰面积 area= " .. tempPeakArea4)

            local maxValue = math.max(tempPeakArea1,
                    tempPeakArea2,
                    tempPeakArea3,
                    tempPeakArea4)
            local minValue = math.min(tempPeakArea1,
                    tempPeakArea2,
                    tempPeakArea3,
                    tempPeakArea4)
            peakArea = (tempPeakArea1 + tempPeakArea2 + tempPeakArea3 + tempPeakArea4 - maxValue - minValue)/2
        end
    end

    return peakArea
end

--[[
 * @brief 浓度计算
 * @param[in] absorbance 吸光度
--]]
function CalibrateFlow:CalculateConsistency(area)
    local consistency = 0
    local timeStr = config.measureParam.curveParam[self.currentRange].timeStr
    local curveK = config.measureParam.curveParam[self.currentRange].curveK
    local curveB = config.measureParam.curveParam[self.currentRange].curveB

    local realUseRange = 0

    if math.abs(curveK - 0)<0.00001 then
        log:debug("校准数值异常")
        return 0
    end

    log:debug("current range: " .. self.currentRange .. ", K: " .. curveK .. ", B: " .. curveB)

    consistency = (area - curveB)/curveK
    consistency = consistency

    if config.measureParam.absCalibrateMode == true and self.currentRange == 1 then
        local absCurveB  = curveB / config.measureParam.curveParam[1].curveK
        consistency = consistency + absCurveB
        log:debug("绝对浓度 = " .. consistency .. ", absCurveB = " .. absCurveB)
    end

    if consistency < 0 then
        consistency = 0
    end

    return consistency
end


--[[
 * @brief 管路更新
 * @detail 一键运行流程中先执行管路更新再校准
--]]
function CalibrateFlow:PipeRenew()

    local runAction

    -- 清空残留液
    runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearWaste)
    StatusManager.Instance():SetAction(runAction)
    op:DrainToWaste(setting.liquid.meterPipeVolume)
    op:DrainFromDigestionRoom()

    -- 清空试剂一管
    runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearReagent1Pipe)
    StatusManager.Instance():SetAction(runAction)
    op:ClearReagentPipe(setting.liquidType.reagent1, setting.liquid.pipeRenewVolume)

    -- 清空量程校准液管
    runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearStandardPipe)
    StatusManager.Instance():SetAction(runAction)
    op:ClearReagentPipe(setting.liquidType.standard, setting.liquid.pipeRenewVolume)

    -- 清空试剂二管
    --runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearReagent2Pipe)
    --StatusManager.Instance():SetAction(runAction)
    --op:ClearReagentPipe(setting.liquidType.reagent2, setting.liquid.pipeRenewVolume)

    -- 清空零点校准液管
    runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearBlankPipe)
    StatusManager.Instance():SetAction(runAction)
    op:ClearReagentPipe(setting.liquidType.blank, setting.liquid.pipeRenewVolume)

    ----开启扩展功能
    ----if config.system.targetMap.EXTEND.enable == true then
    ---- 清空零点核查液管
    --runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearZeroCheckPipe)
    --StatusManager.Instance():SetAction(runAction)
    --op:ClearReagentPipe(setting.liquidType.zeroCheck, setting.liquid.pipeRenewVolume)
    --
    ---- 清空量程核查液管
    --runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearRangeCheckPipe)
    --StatusManager.Instance():SetAction(runAction)
    --op:ClearReagentPipe(setting.liquidType.rangeCheck, setting.liquid.pipeRenewVolume)
    ----end

    op:SyringUpdate(6)

end

--[[
 * @brief 检查是否需要进行深度清洗
 * @detail 若上次校准间隔时间较长则进行深度清洗
--]]
function CalibrateFlow:CleanDeeplyCheckTime()
    local currentTime = os.time()
    local lastTime
    local temp
    local MeasurerIntervalMaxTime = 144        --距离上次校准允许度最大间隔时间，超过则进行深度清洗

    temp = status.measure.newResult.calibrate.dateTime

    lastTime = temp + MeasurerIntervalMaxTime*3600
    if lastTime - currentTime < 0 then
        log:debug("距离上次校准已超"..MeasurerIntervalMaxTime.."小时，进行深度清洗")
        local flow = CleanFlow:new({},cleanType.cleanDeeply)
        flow:CleanDeeply(self)
    end
end


--[[
 * @brief 计算校正系数系数
--]]
function CalibrateFlow:CalculateReviseParam(absorbance)
    local standardCurve = status.measure.standardCurve
    local absorbancess = (status.measure.calibrate[standardCurve].point1Absorbance - status.measure.calibrate[standardCurve].point0Absorbance)
            * setting.measure.range[standardCurve].diluteFactor
            / config.measureParam.curveParam[standardCurve].RangeConsistency
            / config.measureParam.reviseParameter[standardCurve]

    local reviseParameter = (absorbance - status.measure.calibrate[standardCurve].point0Absorbance)
            * setting.measure.range[self.currentRange].diluteFactor
            / absorbancess
            /config.measureParam.curveParam[self.currentRange].RangeConsistency

    log:debug("基准线为量程 "..standardCurve..", 校正量程为 "..self.currentRange.." ,校正系数计算结果 = "..reviseParameter)

    return reviseParameter
end

--[[
 * @brief 测量结果处理
 * @param[in] result 测量过程得到的各参数电流值和对应波形文件索引
--]]
function CalibrateFlow:ResultHandle(result)
    if false == config.measureParam.addCalibrateRecord then
        return
    end

    if MeasureType.Blank ==  Measurer.measureType then
        local flow = MeasureFlow:new({}, MeasureType.Blank)
        local param = {self.zeroCalibrateDateTime,self.currentRange}
        flow:AddParam(param)
        if config.system.targetMap.COD.enable == true then   --根据选择模式区分存储码
            flow.currentModelType = ModelType.COD
            flow.currentView = config.system.CODRangeViewMap[self.currentRange].view
        else
            flow.currentView = config.system.TOCRangeViewMap[self.currentRange].view
        end

        local oldReportMode = config.interconnection.reportMode
        config.interconnection.reportMode = ReportMode.Calibrate
        flow:ResultHandle(result)
        config.interconnection.reportMode = oldReportMode

    elseif MeasureType.Standard ==  Measurer.measureType then
        local flow = MeasureFlow:new({}, MeasureType.Standard)
        local param = {self.standardCalibrateDateTime,self.currentRange}
        flow:AddParam(param)

        if config.system.targetMap.COD.enable == true then   --根据选择模式区分存储码
            flow.currentModelType = ModelType.COD
            flow.currentView = config.system.CODRangeViewMap[self.currentRange].view
        else
            flow.currentView = config.system.TOCRangeViewMap[self.currentRange].view
        end

        local oldReportMode = config.interconnection.reportMode
        config.interconnection.reportMode = ReportMode.Calibrate
        flow:ResultHandle(result)
        config.interconnection.reportMode = oldReportMode

    end
end