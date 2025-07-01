--[[
 * @brief 测量流程。
--]]

CCEPSafeData = 0   --全局变量

MeasureFlow = Flow:new
{
    measureTarget = setting.liquidType.none,
    measureType = MeasureType.Sample,
    reportMode = ReportMode.OnLine,
    adjustTime = false,
    currentRange = 1,
    isCheck = false,
    consistency = 0,
    absorbance = 0,
    isUseStart = false,
    faultTimes = 0,
    isRetryMeasure = false,
    isRetryOnStart = false,
    isCrashMeasure = false,
    diluteFactor = 1,
    peakArea = 0,
    isChangeRangeAtTheEnd = false,
    targetRange = 1,
    isSampleRangeCheck = false,  --水样核查
    isOverProof = false,
}

function MeasureFlow:new(o, meaType)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.measureType = meaType
    o.measureDateTime = os.time()
    o.currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1
    o.reportMode = config.interconnection.reportMode
    o.adjustTime = false
    o.rangeAccurateCalibrate = config.measureParam.rangeAccurateCalibrate
    o.curveCalibrateConsistency = {}
    o.curveCalibrateTime = 1	        -- 量程校正当前次数
    o.curveCalibrateOver = false        -- 量程校正是否完成
    o.deviation12 = 1
    o.deviation13 = 1
    o.deviation23 = 1
    o.autoCheckTimes = 1
    o.isOldCheck = false        -- 是否为低配版仪器标样核查
    o.isUseStart = false
    o.currentModelType = ModelType.TOC    --当前测量参数
    o.currentView = config.system.TOCRangeViewMap[config.measureParam.range[config.measureParam.currentRange + 1] + 1].view
    o.isOverProof = false
    return o
end

function MeasureFlow:GetRuntime()
    local runtime = 0

    if self.measureType == MeasureType.Blank then
        runtime = setting.runStatus.measureBlank.GetTime()
    elseif self.measureType == MeasureType.Standard then
        runtime = setting.runStatus.measureStandard.GetTime()
    elseif self.measureType == MeasureType.Sample then
        runtime = setting.runStatus.measureSample.GetTime()
    elseif self.measureType == MeasureType.ZeroCheck then
        runtime = setting.runStatus.measureZeroCheck.GetTime()
    elseif self.measureType == MeasureType.QualityHandle then
        runtime = setting.runStatus.measureQualityHandle.GetTime()
    elseif self.measureType == MeasureType.RangeCheck then
        runtime = setting.runStatus.measureRangeCheck.GetTime()
    elseif self.measureType == MeasureType.Addstandard then
        runtime = setting.runStatus.measureAddstandard.GetTime()
    elseif self.measureType == MeasureType.Parallel then
        runtime = setting.runStatus.measureParallel.GetTime()
    elseif self.measureType == MeasureType.ExtAddstandard then
        runtime = setting.runStatus.measureExtAddstandard.GetTime()
    elseif self.measureType == MeasureType.ExtParallel then
        runtime = setting.runStatus.measureExtParallel.GetTime()
    end

    return runtime
end

function MeasureFlow:OnStart()
    --组合流程需要重新加载时间
    self.measureDateTime = os.time()
    if self.isCrashMeasure == true then
        self.measureDateTime = status.running.lastMeasureTime
    else
        status.running.lastMeasureTime = self.measureDateTime
    end

    status.measure.isUseStart = self.isUseStart
    ConfigLists.SaveMeasureStatus()

    -- 设置测量标志
    if self.measureType == MeasureType.Sample then  --测水样
        status.running.isMeasuring = true
    end

    ConfigLists.SaveMeasureRunning()

    --继电器指示
    Helper.Result.RelayOutOperate(setting.mode.relayOut.measureInstruct, true)

    if self.measureType == MeasureType.Blank then  --测零点校准液
        local runStatus = Helper.Status.SetStatus(setting.runStatus.measureBlank)
        StatusManager.Instance():SetStatus(runStatus)
        self.currentRange = config.measureParam.range[config.measureParam.calibrateRangeIndex + 1] + 1   --测零点校准液
    elseif self.measureType == MeasureType.Standard then  --测量程校准液
        local runStatus = Helper.Status.SetStatus(setting.runStatus.measureStandard)
        StatusManager.Instance():SetStatus(runStatus)
        self.currentRange = config.measureParam.range[config.measureParam.calibrateRangeIndex + 1] + 1 --测量程校准液量程
    elseif self.measureType == MeasureType.Sample then   --测水样
        local runStatus = Helper.Status.SetStatus(setting.runStatus.measureSample)
        StatusManager.Instance():SetStatus(runStatus)
        self.currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1  --测水样量程
    elseif self.measureType == MeasureType.ZeroCheck then   --测零点核查液
        local runStatus = Helper.Status.SetStatus(setting.runStatus.measureZeroCheck)
        StatusManager.Instance():SetStatus(runStatus)
        self.currentRange = config.measureParam.range[config.measureParam.zeroCheckRangeIndex + 1] + 1 --测零点核查量程
    elseif self.measureType == MeasureType.RangeCheck then   --测量程核查液
        if self.isSampleRangeCheck == true then
            local runStatus = Helper.Status.SetStatus(setting.runStatus.measureSampleRangeCheck)
            StatusManager.Instance():SetStatus(runStatus)
            self.currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1  --测水样量程
        else
            local runStatus = Helper.Status.SetStatus(setting.runStatus.measureRangeCheck)
            StatusManager.Instance():SetStatus(runStatus)
            self.currentRange = config.measureParam.range[config.measureParam.rangeCheckRangeIndex + 1] + 1 --测量程核查量程
            --if config.system.targetMap.EXTEND.enable ~= true then
            --    self.isOldCheck = true
            --    --低配版标样核查继电器输出
            --    Helper.Result.RelayOutOperate(setting.mode.relayOut.checkInstruct, true)
            --end
        end
    elseif self.measureType == MeasureType.QualityHandle then   --测质控样
        local runStatus = Helper.Status.SetStatus(setting.runStatus.measureQualityHandle)
        StatusManager.Instance():SetStatus(runStatus)
        self.currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1  --测水样量程
    elseif self.measureType == MeasureType.Addstandard then   --测加标样
        local runStatus = Helper.Status.SetStatus(setting.runStatus.measureAddstandard)
        StatusManager.Instance():SetStatus(runStatus)
        self.currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1  --测加标样量程
    elseif self.measureType == MeasureType.Parallel then   --测平行样
        local runStatus = Helper.Status.SetStatus(setting.runStatus.measureParallel)
        StatusManager.Instance():SetStatus(runStatus)
        self.currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1  --测平行样量程
    elseif self.measureType == MeasureType.ExtAddstandard then   --测外部加标样
        local runStatus = Helper.Status.SetStatus(setting.runStatus.measureExtAddstandard)
        StatusManager.Instance():SetStatus(runStatus)
        self.currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1 --测外部加标样量程
    elseif self.measureType == MeasureType.ExtParallel then   --测外部平行样
        local runStatus = Helper.Status.SetStatus(setting.runStatus.measureExtParallel)
        StatusManager.Instance():SetStatus(runStatus)
        self.currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1 --测外部平行样量程
    end
    if config.system.targetMap.COD.enable == true then   --根据选择模式区分存储码
        self.currentModelType = ModelType.COD
        self.currentView = config.system.CODRangeViewMap[self.currentRange].view
    else
        self.currentView = config.system.TOCRangeViewMap[self.currentRange].view
    end

    if nil ~= setting.common.skipFlow and true == setting.common.skipFlow then

    else
        op:SlidersSensorCheck()
        -- 初始化下位机
        dc:GetIDeviceStatus():Initialize()
        dc:GetITemperatureControl():DigestionFanSetOutputForTOC(setting.temperature.indexStoveFan, config.measureParam.stoveFanLevel)

        --重设LED测量周期
        op:ResetLEDMeasurePeriod()

        --检查压力补偿状态
        op:CheckCarryPressureOffsetStatus()

        --检测消解室是否为安全温度
        op:CheckDigestSafety()

        --开LED
        dc:GetIOpticalAcquire():TurnOnLED()
    end

    dc:ClearBuf()--清buf,防止数组刷新
end

function MeasureFlow:OnProcess()
    local loopcnt = 3
    self.isRetryMeasure = true
    self.isRetryOnStart = false

    self.isUserStop = false
    self.isFinish = false

    --重测循环
    while self.isRetryMeasure == true and loopcnt > 0 do
        loopcnt = loopcnt - 1
        self.isRetryMeasure = false

        local err,result = pcall(			-- 捕获异常
            function()
                if self.isRetryOnStart == true then
                    self.isRetryOnStart = false
                    self:OnStart()
                end

                --测量流程表复位、参数配置
                if Measurer.flow then
                    Measurer:Reset()
                end
                Measurer.flow = self
                if self.measureType == MeasureType.Sample or self.measureType == MeasureType.Addstandard or self.measureType == MeasureType.Parallel then
                    Measurer.measureType = MeasureType.Sample   --(内部)加标加标/平行的第一次测量类型为水样
                else
                    Measurer.measureType = self.measureType
                end
                Measurer.currentRange = self.currentRange

                for k,v in pairs(setting.measure.range[self.currentRange]) do
                    Measurer.addParam [k] = v
                end

                log:debug("当前量程 = " .. self.currentRange)

                --根据测量类型调整加液参数
                if self.measureType == MeasureType.Blank then
                    Measurer.addParam.blankVolume = Measurer.addParam.blankVolume + Measurer.addParam.sampleVolume
                    Measurer.addParam.sampleVolume = 0
                    Measurer.addParam.rinseBlankVolume = Measurer.addParam.rinseBlankVolume + Measurer.addParam.rinseSampleVolume
                    Measurer.addParam.rinseSampleVolume = 0
                elseif self.measureType == MeasureType.Standard then
                    Measurer.addParam.standardVolume = Measurer.addParam.standardVolume + Measurer.addParam.sampleVolume
                    Measurer.addParam.sampleVolume = 0
                    Measurer.addParam.rinseStandardVolume = Measurer.addParam.rinseStandardVolume + Measurer.addParam.rinseSampleVolume
                    Measurer.addParam.rinseSampleVolume = 0
                elseif self.measureType == MeasureType.ZeroCheck then
                    Measurer.addParam.zeroCheckVolume = Measurer.addParam.zeroCheckVolume + Measurer.addParam.sampleVolume
                    Measurer.addParam.sampleVolume = 0
                    Measurer.addParam.rinseZeroCheckVolume = Measurer.addParam.rinseZeroCheckVolume + Measurer.addParam.rinseSampleVolume
                    Measurer.addParam.rinseSampleVolume = 0
                elseif self.measureType == MeasureType.RangeCheck then --非低配版标样核查使用量程核查通道
                    if self.isSampleRangeCheck == true then
                        --按水样加,走水样管
                    else
                        Measurer.addParam.rangeCheckVolume = Measurer.addParam.rangeCheckVolume + Measurer.addParam.sampleVolume
                        Measurer.addParam.sampleVolume = 0
                        Measurer.addParam.rinseRangeCheckVolume = Measurer.addParam.rinseRangeCheckVolume + Measurer.addParam.rinseSampleVolume
                        Measurer.addParam.rinseSampleVolume = 0
                    end
                end

                self.diluteFactor = Measurer.addParam.diluteFactor  --稀释系数

                -- 采水样
                if self.measureType == MeasureType.Sample then
                    self:CollectSample()
                end

                -- CCEP模式下检测到崩溃重启
                if self.isCrashMeasure == true and config.system.CCEPMode == true then
                    self:RetryMeasureCheck()
                else
                    --测量流程执行
                    setting.measureResult.continousModeParam.lastAccuratePeakArea = 0
                    setting.measureResult.continousModeParam.lastStartIndex = 0
                    setting.measureResult.continousModeParam.currentMeasureCnt = 0
                    setting.measureResult.continousModeParam.isfinishContinousMeasure = false --连续测量标志位
                    setting.measureResult.isStartAccurateMeasure = false    --精确测量标志位
                    setting.measureResult.isFinishAccurateMeasure = false   --精确测量标志位
                    setting.measureResult.immediatelyResultHandle = false   --精确结果输出标志位
                    if config.measureParam.range[config.measureParam.currentRange + 1] + 1 == 1 then
                        setting.measureResult.startReactVolume = setting.measureResult.reactVolume[2] --更新反应体积
                        config.measureParam.addSampleCnt = 2
                        config.measureParam.carryingPressure = config.measureParam.preCarryingPressure
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

                    if config.scheduler.measure.mode == MeasureMode.Continous and self.measureType == MeasureType.Sample then
                        while config.scheduler.measure.mode == MeasureMode.Continous and self.measureType == MeasureType.Sample do
                            local runStatus = Helper.Status.SetStatus(setting.runStatus.measureSample)
                            StatusManager.Instance():SetStatus(runStatus)

                            Measurer:Measure()
                            if  self.isUserStop == true then
                                break
                            end

                            --量程切换
                            if self.currentRange ~= config.measureParam.range[config.measureParam.currentRange + 1] + 1 and setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                                log:debug("change range")
                                Measurer:ContinousMeasureSafetyStop()
                                self.isFinish = true
                                break
                            end

                            if config.scheduler.suckHalogenBottleWater.enable == true and setting.measureResult.continousModeParam.isfinishContinousMeasure == true then --避免重复出数
                                --自动排卤素液排期
                                local currentTime = os.time()
                                local ret, actionTime = setting.measureScheduler[8].getNextTime()
                                if currentTime - actionTime >= 0 then
                                    log:debug("suckHalogenBottleWater")
                                    Measurer:ContinousMeasureSafetyStop()
                                    self.isFinish = true
                                    break
                                end
                            end

                            if config.scheduler.calibrate.mode ~= MeasureMode.Trigger and setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                                --校准排期
                                local currentTime = os.time()
                                local ret, actionTime = setting.measureScheduler[1].getNextTime()
                                if currentTime - actionTime >= 0 then
                                    log:debug("calibrate")
                                    Measurer:ContinousMeasureSafetyStop()
                                    self.isFinish = true
                                    break
                                end
                            end

                            if config.scheduler.standard.enable == true and setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                                --量程校准排期
                                local currentTime = os.time()
                                local ret, actionTime = setting.measureScheduler[5].getNextTime()
                                if currentTime - actionTime >= 0 then
                                    log:debug("standard")
                                    Measurer:ContinousMeasureSafetyStop()
                                    self.isFinish = true
                                    break
                                end
                            end

                            if config.scheduler.blankCheck.enable == true and setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                                --零点校准排期
                                local currentTime = os.time()
                                local ret, actionTime = setting.measureScheduler[7].getNextTime()
                                if currentTime - actionTime >= 0 then
                                    log:debug("blankCheck")
                                    Measurer:ContinousMeasureSafetyStop()
                                    self.isFinish = true
                                    break
                                end
                            end

                            if config.scheduler.zeroCheck.mode ~= MeasureMode.Trigger and setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                                --零点核查排期
                                local currentTime = os.time()
                                local ret, actionTime = setting.measureScheduler[3].getNextTime()
                                if currentTime - actionTime >= 0 then
                                    log:debug("zeroCheck")
                                    Measurer:ContinousMeasureSafetyStop()
                                    self.isFinish = true
                                    break
                                end
                            end

                            if config.scheduler.rangeCheck.mode ~= MeasureMode.Trigger and setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                                --量程核查排期
                                local currentTime = os.time()
                                local ret, actionTime = setting.measureScheduler[2].getNextTime()
                                if currentTime - actionTime >= 0 then
                                    log:debug("rangeCheck")
                                    Measurer:ContinousMeasureSafetyStop()
                                    self.isFinish = true
                                    break
                                end
                            end

                            if config.interconnection.collectSampleMode == setting.mode.collectSample.period and
                                    setting.measureResult.continousModeParam.isfinishContinousMeasure == true then --避免重复出数
                                --自动采水排期
                                local currentTime = os.time()
                                local ret, actionTime = setting.measureScheduler[9].getNextTime()
                                if currentTime - actionTime >= 0 then
                                    log:debug("AutoCollectSample")
                                    Measurer:ContinousMeasureSafetyStop()
                                    self.isFinish = true
                                    break
                                end
                            end

                            if config.scheduler.airReplacement.enable == true and
                                    setting.measureResult.continousModeParam.isfinishContinousMeasure == true then --避免重复出数
                                --自动换气排期
                                local currentTime = os.time()
                                local ret, actionTime = setting.measureScheduler[11].getNextTime()
                                if currentTime - actionTime >= 0 then
                                    log:debug("AutoAirReplacement")
                                    Measurer:ContinousMeasureSafetyStop()
                                    self.isFinish = true
                                    break
                                end
                            end

                        end
                    else
                        Measurer:Measure()
                        if setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                            --非连续模式改为连续测量时安全出数
                            Measurer:ContinousMeasureSafetyStop()
                            self.isFinish = true
                        end
                    end

                    --加标和平行需要再测量一次
                    if self.measureType == MeasureType.Addstandard or self.measureType == MeasureType.Parallel then
                        --测量流程表复位、参数配置
                        if Measurer.flow then
                            Measurer:Reset()
                        end
                        Measurer.flow = self
                        Measurer.measureType = self.measureType
                        Measurer.currentRange = self.currentRange

                        for k,v in pairs(setting.measure.range[self.currentRange]) do
                            Measurer.addParam [k] = v
                        end

                        if self.measureType == MeasureType.Addstandard then  --加标样加液参数设置
                            if self.currentRange == 1 then
                                Measurer.addParam.sampleVolume = 1       -- 2ML Sample --> 1ML Smaple + 1ML Standard
                            elseif self.currentRange > 1 then
                                Measurer.addParam.afterReagent1AddBlankVolume = 0  -- 1ML Blank after Reagent1 --> 1ML Standard after Reagent1
                            end
                        end

                        --加标/平行测量流程执行
                        Measurer:Measure()
                    end
                end
            end
        )	-- 捕获异常结束

        if not err then      -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --期望事件等待超时异常。
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif result:GetType() == "CommandTimeoutException" then          --命令应答超时异常
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                else
                    log:warn("MeasureFlow:OnProcess =>" .. result:What())
                end
            elseif type(result) == "table" then
                if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
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
                elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                    self.isUserStop = true 
                    error(result)
                elseif getmetatable(result) == AcquirerADFailedException then 	    --光学采集中途出现故障，未能完成异常。
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()                    
                elseif getmetatable(result) == PumpFailedException then 			--泵操作中途出现故障，未能完成异常。
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result) == MeterFailedException then 			--定量中途出现故障，未能完成异常。
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result) == MeterOverflowException then 			--定量溢出异常。
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result) == MeterUnfinishedException then 		--定量目标未达成异常。
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result)== MeterAirBubbleException then			--定量气泡异常。
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result) == MeterExpectTimeoutException then 	--定量超时异常。
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result) == ThermostatFailedException then 		--恒温中途出现故障，未能完成异常。
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result) == ThermostatTimeoutException then 		--恒温超时，指定时间内仍未达到目标温度异常
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result) == DrainFromDigestionException then 	 	--排消解液异常
                    if config.system.CCEPMode == true then
                        ExceptionHandler.MakeAlarm(result)
                        self:RetryMeasureCheck()
                    else  --严重故障直接终止
                        error(result)
                    end
                elseif getmetatable(result) == AddLiquidToDigestionException then 	 	--消解室加液异常
                    if config.system.CCEPMode == true then
                        ExceptionHandler.MakeAlarm(result)
                        self:RetryMeasureCheck()
                    else  --严重故障直接终止
                        error(result)
                    end
                elseif getmetatable(result) == MeasureDataException then 	 	-- 测量数据异常
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result) == MeasureLedException then 	 	-- 测量信号异常
                    ExceptionHandler.MakeAlarm(result)
                    self:RetryMeasureCheck()
                elseif getmetatable(result) == MeasureRangeWrongException then 	 	--量程错误异常
                    self:RetryMeasureCheck(true)
                elseif getmetatable(result) == AirFlowException then        --载气调节异常
                    self:RetryMeasureCheck(true)
                    op:TurnOffNirtrogen()
                else
                    log:warn("MeasureFlow:OnProcess =>" .. result:What())								--其他定义类型异常
                end
            elseif type(result) == "string" then
                log:warn("MeasureFlow:OnProcess =>" .. result)	--C++、Lua系统异常
            end
        end
    end-----重测循环
end


function MeasureFlow:OnStop()
    -- 设置测量标志
    if status.running.isCorrectStopFlow ~= nil and status.running.isCorrectStopFlow == true then
        status.running.isMeasuring = false
        ConfigLists.SaveMeasureRunning()
    end

    --op:ReviseThermostatTemp(setting.temperature.indexNDIR, ThermostatMode.Heater, config.measureParam.measureModuleTemperature, setting.temperature.NDIRToleranceTemp, setting.temperature.NDIRTempTimeout)

    -- 隐藏预估值
    if config.system.displayProformaResult == true then
        UpdateWidgetManager.Instance():Update(UpdateEvent.ShowNewProformaData, "")
    end

    if not self.isFinish then
        if self.measureType == MeasureType.Sample then
            status.measure.schedule.autoMeasure.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.RangeCheck then
            status.measure.schedule.rangeCheck.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.Standard then
            status.measure.schedule.autoCheck.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.Blank then
            status.measure.schedule.autoBlankCheck.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.Addstandard or self.measureType == MeasureType.ExtAddstandard then
            status.measure.schedule.autoAddstandard.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.Parallel or self.measureType == MeasureType.ExtParallel then
            status.measure.schedule.autoParallel.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.ZeroCheck then
            status.measure.schedule.zeroCheck.dateTime = self.measureDateTime
        end

        if self.isUserStop then
            self.result = "用户终止"
            log:info("用户终止")
        else
            status.measure.newResult.measure.resultMark = "D"  --故障数据标记
            status.measure.newResult.measure.resultInfo = "D"  --故障数据标识
            status.measure.report.complexResult.resultInfo = "D"  --故障数据标记
            if self.measureType == MeasureType.Sample then
                status.measure.report.measure.resultInfo = status.measure.newResult.measure.resultInfo --更新数据标识
            elseif self.measureType == MeasureType.Standard then
                status.measure.report.check.resultInfo = status.measure.newResult.measure.resultInfo --更新数据标识
            elseif self.measureType == MeasureType.Blank then
                status.measure.report.blankCheck.resultInfo = status.measure.newResult.measure.resultInfo --更新数据标识
            elseif self.measureType == MeasureType.Addstandard or self.measureType == MeasureType.ExtAddstandard then
                status.measure.report.addstandard.resultInfo = status.measure.newResult.measure.resultInfo --更新数据标识
            elseif self.measureType == MeasureType.Parallel or self.measureType == MeasureType.ExtParallel then
                status.measure.report.parallel.resultInfo = status.measure.newResult.measure.resultInfo --更新数据标识
            elseif self.measureType == MeasureType.ZeroCheck then
                status.measure.report.zeroCheck.resultInfo = status.measure.newResult.measure.resultInfo --更新数据标识
            elseif self.measureType == MeasureType.RangeCheck then
                status.measure.report.rangeCheck.resultInfo = status.measure.newResult.measure.resultInfo --更新数据标识
            elseif self.measureType == MeasureType.QualityHandle then
                status.measure.report.qualityHandle.resultInfo = status.measure.newResult.measure.resultInfo --更新数据标识
            end

            self.result = "故障终止"
            log:warn("故障终止")

            local isSave = false
            if self.measureType == MeasureType.Sample and config.scheduler.measure.mode == MeasureMode.Continous then
                config.scheduler.measure.mode = MeasureMode.Trigger --连续测量变触发
                isSave = true
            elseif self.measureType == MeasureType.ZeroCheck and config.scheduler.zeroCheck.mode == MeasureMode.Continous then
                config.scheduler.zeroCheck.mode = MeasureMode.Trigger --连续测量变触发
                isSave = true
            elseif self.measureType == MeasureType.RangeCheck and config.scheduler.rangeCheck.mode == MeasureMode.Continous then
                config.scheduler.rangeCheck.mode = MeasureMode.Trigger --连续测量变触发
                isSave = true
            end

            if isSave == true then
                config.modifyRecord.scheduler(true)
                ConfigLists.SaveSchedulerConfig()

                local updateWidgetManager = UpdateWidgetManager.Instance()
                updateWidgetManager:Update(UpdateEvent.ChangeMeaModeOnHome, "DeviceFaultException")
            end

            --错误之后如实上报 生成上一次测量结果(贵州协议专用)
            if modbusStr == "GZ" then
                self:FaultGetLastTimeResult()
                log:info("流程错误")
                log:info("测量未完成")
                log:info("测量流程总时间 = ".. os.time() - self.measureDateTime)
            end
        end
        ConfigLists.SaveMeasureStatus()
    else
        status.measure.isDeviceFault = false
        ConfigLists.SaveMeasureStatus()

        self.result = "测量完成"
        log:info("测量完成")
        log:info("测量流程总时间 = ".. os.time() - self.measureDateTime)

        if self.measureType == MeasureType.RangeCheck then
            local checkConsistency = config.measureParam.checkConsistency
            local checkError = math.abs(self.consistency - checkConsistency)/checkConsistency
            log:debug("标样核查 实测值 = "..self.consistency.." 标准值 = "..checkConsistency.." 偏差 = "..checkError)
            status.measure.report.rangeCheck.checkError = checkError
            ConfigLists.SaveMeasureStatus()
            if config.measureParam.failAutoRevise == true then
                log:debug("标样核查 次数"..self.autoCheckTimes)
                if math.abs(checkError) > config.measureParam.checkErrorLimit then
                    if self.autoCheckTimes >= 3 then
                        log:debug("核查结果错误")
                        local alarm = Helper.MakeAlarm(setting.alarm.checkResultWrong, "")
                        AlarmManager.Instance():AddAlarm(alarm)

                        config.interconnection.reportMode = _G.ReportMode.Maintain  --变为维护模式
                        config.modifyRecord.interconnection(true)
                        ConfigLists.SaveInterconnectionConfig()
                        UpdateWidgetManager.Instance():Update(UpdateEvent.ChangeInterconnectionParam, "MeasureFlow")

                        config.modifyRecord.scheduler(true)
                        ConfigLists.SaveSchedulerConfig()
                        UpdateWidgetManager.Instance():Update(UpdateEvent.ChangeMeaModeOnHome, "MeasureFlow")
                    else  --误差较大重新校准并核查
                        log:debug("核查异常 重新校准核查")
                        local calibrateFlow = CalibrateFlow:new({}, CalibrateType.calibrate)
                        calibrateFlow.isStarted = true
                        calibrateFlow:OnStart()
                        calibrateFlow:OnProcess()
                        calibrateFlow:OnStop()
                        calibrateFlow.isStarted = false

                        local flow = MeasureFlow:new({}, MeasureType.RangeCheck)
                        flow.autoCheckTimes = self.autoCheckTimes + 1
                        flow.isStarted = true
                        flow:OnStart()
                        flow:OnProcess()
                        flow:OnStop()
                        flow.isStarted = false
                    end
                else
                    log:debug("标样核查结果正常")
                end
            end
        end

        if true == config.interconnection.overProofAutoCheck and true == self.isOverProof then
            log:debug("水样超上限 启动核查")
            local flow = MeasureFlow:new({}, MeasureType.RangeCheck)
            flow.isStarted = true
            flow:OnStart()
            flow:OnProcess()
            flow:OnStop()
            flow.isStarted = false
        end
    end

    --保存试剂余量表
    ReagentRemainManager.SaveRemainStatus()
    --保存载气压力
    config.measureParam.carryingPressure = config.measureParam.preCarryingPressure
    ConfigLists.SaveMeasureParamConfig()

    --检测消解室是否为安全温度
    op:CheckDigestSafety()

    --低配版标样核查继电器关闭
    if self.isOldCheck == true then
        Helper.Result.RelayOutOperate(setting.mode.relayOut.checkInstruct, false)
    end

    --继电器指示
    Helper.Result.RelayOutOperate(setting.mode.relayOut.measureInstruct, false)

    --关闭采水继电器
    if config.interconnection.collectSampleMode ~= setting.mode.collectSample.trigger then
        local waterCollector = WaterCollector.Instance()
        if not string.find(config.info.instrument["type"], "PT63P") then
            waterCollector:TurnOff()
        end
        Helper.Result.RelayOutOperate(setting.mode.relayOut.collectInstruct, false)
    end

    --开始更新基线状态
    status.measure.isCheckBaseLine = true
    status.measure.isUseStart = false
    ConfigLists.SaveMeasureStatus()

    if nil ~= setting.common.skipFlow and true == setting.common.skipFlow then

    else
        if setting.sensor.isValid == true then
            op:SlidersSensorCheck()
        end
        -- 初始化下位机
        dc:GetIDeviceStatus():Initialize()
        dc:GetITemperatureControl():DigestionFanSetOutputForTOC(setting.temperature.indexStoveFan, config.measureParam.stoveFanLevel)
        --dc:GetITemperatureControl():BoxFanSetOutputForTOC(1, 0)
        --dc:GetITemperatureControl():BoxFanSetOutputForTOC(0, 0)
        --dc:SetBoxFanEnable(true)
        --开总阀，保证总阀全程开着，只通过比例阀调节流速
        --关闭氮气气路
        op:TurnOffNirtrogen(setting.pressure.delayTime)
        op:ExposureTurnOff()
        dc:GetIOpticalAcquire():TurnOffLED()	--关LED
        dc:ClearBuf()--清buf,防止数组刷新
    end

    --停止峰形图数据更新
    UpdateWidgetManager.Instance():Update(UpdateEvent.PeakStatusChanged, "Stop")
    App.Sleep(500)

    --开始更新基线状态
    status.measure.isCheckBaseLine = false
    ConfigLists.SaveMeasureStatus()

    UpdateWidgetManager.Instance():Update(UpdateEvent.BaseLineStatusChanged, "Stop")
    App.Sleep(500)
end

--[[
 * @brief 预估测量结果处理
 * @param[in] result 测量过程得到的反应和对应波形文件索引
--]]
function MeasureFlow:ProformaResultHandle(result)
    --if self.isCheck == true then
    --    Measurer.measureType = MeasureType.Check
    --end
    log:debug("预估测量结果")
    --	print("MeasureFlow:ProformaResultHandle")
    local measureAD = MeasureAD:new()
    measureAD.initReference = status.measure.proformaResult.measure.initReference
    measureAD.initMeasure = status.measure.proformaResult.measure.initMeasure
    measureAD.finalReference = result.finalReferenceAD
    measureAD.finalMeasure = result.finalMeasureAD

    --print("iRef = ".. result.initReferenceAD .."，iMea = ".. result.initMeasureAD .."，fRef = ".. result.finalReferenceAD .." ，fMea = " .. result.finalMeasureAD)

    --吸光度计算
    local absorbance = 0
    if status.measure.proformaResult.measure.dateTime ~= 0 then

        --初始吸光度
        local initAbsorbance = measureAD:CalculateInitAbsorbance()

        --吸光度计算
        absorbance = measureAD:CalculateRelAbsorbance()
    end

    --异常吸光度修正
    absorbance = self:AbnormalAbsorbanceRevise(absorbance)

    --浓度计算
    local consistency = self:CalculateConsistency(absorbance)

    ----结果内部校正
    --local oldConsistency = consistency
    --if config.measureParam.reviseParameter[self.currentRange] ~= nil then
    --    consistency = oldConsistency*config.measureParam.reviseParameter[self.currentRange]
    --    log:debug("内部结果修正 修正系数 = " .. config.measureParam.reviseParameter[self.currentRange].."，原浓度 = "..oldConsistency.."，修正浓度 = " .. consistency)
    --end

    --管理员 浓度修正
    local tempConsistency = consistency
    consistency = tempConsistency * config.measureParam.reviseFactor
    log:debug("结果浓度修正 修正系数 = " .. config.measureParam.reviseFactor.."，原浓度 = "..tempConsistency.."，修正浓度 = " .. consistency)

    --超级管理员平移修正
    consistency = consistency + config.measureParam.shiftFactor
    local shiftAbs = config.measureParam.shiftFactor*config.measureParam.curveParam[self.currentRange].curveK/(config.measureParam.reviseFactor*config.measureParam.reviseParameter[self.currentRange])
    absorbance = absorbance + shiftAbs
    log:debug("Shift Revise shiftFactor = "..config.measureParam.shiftFactor.."，newC = " .. consistency.." shiftAbs = "..shiftAbs..", newA = "..absorbance)


    consistency = self:ConsistencyOffset(consistency)
    --absorbance = self:ReviseAbs(consistency)


    if config.measureParam.negativeRevise == true then
        --浓度小值显示校正
        consistency = self:ConsistencyRevise(consistency,false)
    end

    --整点测量时，测量时间整点校正，手动启动不校正
    if self.adjustTime == true then  --排期设置
        if (self.measureType == MeasureType.Sample and config.scheduler.measure.mode == MeasureMode.Timed) or
                (self.measureType == MeasureType.ZeroCheck and config.scheduler.zeroCheck.mode == MeasureMode.Timed) or
                (self.measureType == MeasureType.RangeCheck and config.scheduler.rangeCheck.mode == MeasureMode.Timed) then

            self.measureDateTime = self:AdjustMeasureDateTime(self.measureDateTime)
        end
    end

    Helper.Result.OnMeasureProformaResultAdded(self.measureDateTime, consistency, absorbance, measureAD)
    if config.system.displayProformaResult == true then
        UpdateWidgetManager.Instance():Update(UpdateEvent.ShowNewProformaData, setting.ui.runStatus.targets[1].name)
    end

    --测量结果
    log:debug("预估测量结果：".."iRef = " .. measureAD.initReference .. "，iMea = " .. measureAD.initMeasure ..
            "，fRef = " .. measureAD.finalReference .."，fMea =" .. measureAD.finalMeasure .. "，A = " .. absorbance .. "，C = " .. consistency)
end

--[[
 * @brief 测量结果处理
 * @param[in] result 测量过程得到的各参数电流值和对应波形文件索引
--]]
function MeasureFlow:ResultHandle(result)

    local converfactor
    if self.measureType == MeasureType.Sample and self.currentModelType == ModelType.COD then
        converfactor = config.system.sampleConverCurveK
    elseif self.currentModelType == ModelType.TOC or self.measureType == MeasureType.Blank then
        converfactor = 1
    else
        converfactor = config.system.standardConverCurveK
    end

    local measureAD = MeasureAD:new()
    local peakArea = result.peakArea

    measureAD.initReference = result.initReferenceAD
    measureAD.initMeasure = result.initMeasureAD
    measureAD.finalReference = result.finalReferenceAD
    measureAD.finalMeasure = result.finalMeasureAD

    if config.scheduler.measure.mode == MeasureMode.Continous and setting.measureResult.continousModeParam.currentMeasureCnt ~= 0 then
        if result.measureDate ~= nil then
            if setting.measureResult.continousModeParam.isfinishContinousMeasure == false then
                self.measureDateTime = result.lastMeasureDate
            else
                self.measureDateTime = result.measureDate
            end
        end
    elseif config.scheduler.measure.mode ~= MeasureMode.Continous and setting.measureResult.continousModeParam.currentMeasureCnt ~= 0 then
        if result.lastMeasureDate ~= nil then
            if setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                --在上一次测量结果前改为触发模式,时间为上一次流程所保存的时间
                self.measureDateTime = result.measureDate
            else
                --在上一次测量结果后改为触发模式,时间为当前流程所保存的时间
                self.measureDateTime = result.lastMeasureDate
            end
        end
    end

    --初始吸光度
    local initAbsorbance = measureAD:CalculateInitAbsorbance()

    --异常吸光度修正
    self.peakArea = self:AbnormalAbsorbanceRevise(peakArea)

    --local volumeFactor = setting.measureResult.startReactVolume/setting.measureResult.defaultReactVolume
    if config.measureParam.volumeIndex == 0 then
        setting.measureResult.startReactVolume = setting.measureResult.reactVolume[1] --更新反应体积
        config.measureParam.addSampleCnt = 1
    elseif config.measureParam.volumeIndex == 1 then
        setting.measureResult.startReactVolume = setting.measureResult.reactVolume[2] --更新反应体积
        config.measureParam.addSampleCnt = 2
    else
        setting.measureResult.startReactVolume = setting.measureResult.reactVolume[3] --更新反应体积
        config.measureParam.addSampleCnt = 3
    end
    if config.measureParam.range[config.measureParam.currentRange + 1] + 1 == 1 then
        setting.measureResult.startReactVolume = setting.measureResult.reactVolume[2] --更新反应体积
        config.measureParam.addSampleCnt = 2
        config.measureParam.carryingPressure = config.measureParam.preCarryingPressure
    else
        setting.measureResult.startReactVolume = setting.measureResult.reactVolume[1] --更新反应体积
        config.measureParam.addSampleCnt = 1
        config.measureParam.carryingPressure = config.measureParam.preCarryingPressure
    end
    ConfigLists.SaveMeasureParamConfig()

    local volumeFactor = 1
    --log:debug("体积系数： " .. volumeFactor)

   --浓度计算  当前result.peak 应避免未空值
    if nil ~= setting.common.skipFlow and true == setting.common.skipFlow then
        self.consistency = setting.common.minRandomData + math.random() * (setting.common.maxRandomData - setting.common.minRandomData)
    else
        self.consistency = self:CalculateConsistency(self.peakArea)/volumeFactor
    end
    log:info("浓度结果： " .. self.consistency)

    --管理员 浓度修正
    local tempConsistency = self.consistency
    self.consistency = tempConsistency * config.measureParam.reviseFactor
    log:debug("结果浓度修正 修正系数 = " .. config.measureParam.reviseFactor.."，原浓度 = "..tempConsistency.."，修正浓度 = " .. self.consistency)

    --超级管理员平移修正
    self.consistency = self.consistency + config.measureParam.shiftFactor
    local shiftAbs = config.measureParam.shiftFactor*config.measureParam.curveParam[self.currentRange].curveK/(config.measureParam.reviseFactor*config.measureParam.reviseParameter[self.currentRange])
    self.peakArea = self.peakArea + shiftAbs
    log:debug("Shift Revise shiftFactor = "..config.measureParam.shiftFactor.."，newC = " .. self.consistency.." shiftAbs = "..shiftAbs..", newA = "..self.peakArea)

    self.consistency = self:ConsistencyOffset(self.consistency)
    --self.absorbance = self:ReviseAbs(self.consistency)
    --self.peakArea = self:ReviseAbs(self.consistency)      --峰面积反算 ，后面确定标线后再加上


    if config.measureParam.negativeRevise == true then
        --浓度小值显示校正
        self.consistency = self:ConsistencyRevise(self.consistency)
    end

    --if self.consistency > config.system.rangeViewMap[self.currentRange].view*150/100 and true == self:CheckCurve() then
    --    self.consistency = config.system.rangeViewMap[self.currentRange].view*150/100 +
    --            math.random() * setting.measureResult.quantifyLowLimit
    --    self.peakArea = self:ReviseAbs(self.consistency)      --峰面积反算 ，后面确定标线后再加上
    --end

    --自动量程切换检查
    if Measurer.measureType == MeasureType.Sample and config.measureParam.autoChangeRange == true then
        self:RangeCheck(self.consistency, self.currentRange)
    end

    --结果数据标识
    local resultMark = ResultMark.N
    self.reportMode = config.interconnection.reportMode     -- 出结果时重拿一次上报模式

    if self.reportMode == ReportMode.OnLine then
        --在线情况下 水样才去监测超上限与超量程的阈值，且核查才会标记为K
        if self.measureType == MeasureType.Sample then
            if self.consistency > config.interconnection.meaUpLimit and 1 == config.interconnection.overProofResultMark then
                resultMark = ResultMark.T
                self.isOverProof = true
            elseif self.consistency > config.system.rangeViewMap[self.currentRange].view then
                resultMark = ResultMark.E
            end
        elseif self.measureType == MeasureType.RangeCheck or self.measureType == MeasureType.ZeroCheck then
            resultMark = ResultMark.C
        elseif self.measureType == MeasureType.QualityHandle then
            resultMark = ResultMark.K
        end

        if self.measureType == MeasureType.RangeCheck or self.measureType == MeasureType.ZeroCheck then
            if 1 == config.interconnection.rangeCheckResultMark then
                resultMark = ResultMark.K
            end
        end
    elseif self.reportMode == ReportMode.OffLine then
        resultMark = ResultMark.B
    elseif self.reportMode == ReportMode.Maintain then
        resultMark = ResultMark.M
    elseif self.reportMode == ReportMode.Fault then
        resultMark = ResultMark.D
    elseif self.reportMode == ReportMode.Calibrate then
        resultMark = ResultMark.C
    elseif self.reportMode == ReportMode.Debugging then
        resultMark = ResultMark.A
    end

    --四川协议下零点校准液和量程校准液直接标记为 维护M 数据
    if modbusStr == "SC" then
        if self.measureType == MeasureType.Blank or self.measureType == MeasureType.Standard then
            resultMark = ResultMark.M
            self.reportMode = ReportMode.Maintain
        end
    end


    --整点测量时，测量时间整点校正，手动启动不校正
    if self.adjustTime == true then  --排期设置
        if (self.measureType == MeasureType.Sample and config.scheduler.measure.mode == MeasureMode.Timed) or
                (self.measureType == MeasureType.ZeroCheck and config.scheduler.zeroCheck.mode == MeasureMode.Timed) or
                (self.measureType == MeasureType.RangeCheck and config.scheduler.rangeCheck.mode == MeasureMode.Timed) then

            self.measureDateTime = self:AdjustMeasureDateTime(self.measureDateTime)
        end
    end
    --print("Push result data to file.")
    local resultManager = ResultManager.Instance()
    local recordData = RecordData.new(resultManager:GetMeasureRecordDataSize(setting.resultFileInfo.measureRecordFile[1].name))
    recordData:PushInt(self.measureDateTime) -- 时间
    recordData:PushFloat(self.consistency) -- 浓度
    recordData:PushFloat(self.peakArea) -- 峰面积
    recordData:PushByte(resultMark) -- 结果标识
    recordData:PushByte(Measurer.measureType) -- 类型(当前测量过程)
    recordData:PushFloat(result.initRefrigeratorTemp) -- 初始制冷模块温度
    recordData:PushFloat(result.initNDIRTemp) -- 初始测量模块温度
    recordData:PushFloat(result.finalRefrigeratorTemp) -- 反应制冷模块温度
    recordData:PushFloat(result.finalNDIRTemp) -- 反应测量模块温度
    recordData:PushFloat(result.initThermostatTemp) -- 初始值燃烧炉温度
    recordData:PushFloat(result.initEnvironmentTemp) -- 初始值上机箱温度
    recordData:PushFloat(result.initEnvironmentTempDown) -- 初始值下机箱温度
    recordData:PushFloat(result.finalThermostatTemp) -- 反应值燃烧炉温度
    recordData:PushFloat(result.finalEnvironmentTemp) -- 反应值上机箱温度
    recordData:PushFloat(result.finalEnvironmentTempDown) -- 反应值下机箱温度
    recordData:PushInt(os.time()-self.measureDateTime) -- 测量时长
    recordData:PushFloat(config.measureParam.curveParam[self.currentRange].RangeConsistency) -- 加量程校准液浓度
    recordData:PushFloat(self.currentView)   -- 当前使用量程
    recordData:PushByte(self.currentModelType)        --根据选择模式区分存储码
    recordData:PushFloat(string.format("%.2f", converfactor)) -- 水样转换系数
    recordData:PushFloat(string.format("%.2f", config.system.standardConverCurveK)) -- 标样转换系数

    -- 隐藏预估值
    Helper.Result.OnMeasureProformaResultAdded(self.measureDateTime, self.consistency, self.absorbance, measureAD)
    if config.system.displayProformaResult == true then
        UpdateWidgetManager.Instance():Update(UpdateEvent.ShowNewProformaData, "")
    end

    local flowManager = FlowManager.Instance()
    if true == flowManager:IsReagentAuthorize() then
        Helper.Result.OnMeasureResultAdded(Measurer.measureType, self.measureDateTime, self.consistency, self.reportMode, self.peakArea ,self.isUseStart,false,resultMark,modbusStr, self.currentModelType)
        resultManager:AddMeasureRecord(setting.resultFileInfo.measureRecordFile[1].name, recordData, true)

        if config.system.printer.enable == true and config.system.printer.autoPrint == true and setting.ui.measureDataPrint.measure.printer ~= nil then
            UpdateWidgetManager.Instance():Update(UpdateEvent.PrintNewMeasureData, "MeasureFlow")
        end
    else
        local alarm = Helper.MakeAlarm(setting.alarm.reagentAuthorizationError, "")
        AlarmManager.Instance():AddAlarm(alarm)

        if self.measureType == MeasureType.Sample then
            status.measure.schedule.autoMeasure.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.Standard then
            status.measure.schedule.autoCheck.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.Blank then
            status.measure.schedule.autoBlankCheck.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.Addstandard or self.measureType == MeasureType.ExtAddstandard then
            status.measure.schedule.autoAddstandard.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.Parallel or self.measureType == MeasureType.ExtParallel then
            status.measure.schedule.autoParallel.dateTime = self.measureDateTime
        elseif self.measureType == MeasureType.ZeroCheck then
            status.measure.schedule.zeroCheck.dateTime = self.measureDateTime
        elseif self.measureType  == MeasureType.RangeCheck then
            status.measure.schedule.rangeCheck.dateTime = self.measureDateTime
        end
    end

    --测量流程类型和测量结果类型一致才认定完成
    if self.measureType == Measurer.measureType or self.isCheck == true then
        self.isFinish = true
    end

    if config.system.CCEPMode == true then
        CCEPSafeData = 0   --完成测量，安全标志清0
    end

    ConfigLists.SaveMeasureStatus()

    self.isCrashMeasure = false  --清除崩溃标记
    -- 设置测量结束标志
    status.running.isMeasuring = false
    ConfigLists.SaveMeasureRunning()
    --测量结果
    log:debug("测量结果：".."iRef = " .. measureAD.initReference .. "，iMea = " .. measureAD.initMeasure ..
    "，fRef = " .. measureAD.finalReference .."，fMea =" .. measureAD.finalMeasure .. "，A = " .. self.absorbance .. "，C = " .. self.consistency)

    if true == self.isChangeRangeAtTheEnd then
        config.measureParam.currentRange = self.targetRange 		--更新量程配置文件
        config.modifyRecord.measureParam(true)
        ConfigLists.SaveMeasureParamConfig()
    end
end

--[[
 * @brief 异常吸光度修正(吸光度超正常范围上限)
 * @param[in] absorbance 吸光度
--]]
function MeasureFlow:AbnormalAbsorbanceRevise(absorbance)
    local retA = absorbance
    if absorbance > setting.measureResult.absLimit then
        local random = 0.1*(math.random() - 0.5)*setting.measureResult.absLimit
        retA = setting.measureResult.absLimit + random

        log:warn("Abnormal Absorbance Revise ==> Abs0 = "..absorbance..",Abs = "..retA)
    end
    return retA
end

--[[
 * @brief 浓度计算
 * @param[in] absorbance 吸光度

--]]
function MeasureFlow:CalculateConsistency(area)
    local consistency = 0
    --local peakArea = 0
    local curveK = config.measureParam.curveParam[self.currentRange].curveK
    local curveB = config.measureParam.curveParam[self.currentRange].curveB

    if math.abs(curveK - 0)<0.00001 then
        log:debug("校准数值异常")
        return 0
    end
    log:debug("量程"..self.currentRange.."计算斜率 K = " .. curveK .. ", B = " .. curveB)

    consistency = (area - curveB)/curveK
    consistency = consistency

    if config.measureParam.absCalibrateMode == true and self.currentRange == 1 then
        local absCurveB  = curveB / config.measureParam.curveParam[1].curveK
        consistency = consistency + absCurveB
        log:debug("绝对浓度 = " .. consistency .. ", absCurveB = " .. absCurveB)
    end

    if self.currentModelType == ModelType.COD then
        if self.measureType ==  MeasureType.Sample then
            consistency = consistency * config.system.sampleConverCurveK + config.system.sampleConverCurveB --水样转换系数
        elseif self.measureType ==  MeasureType.Blank then
            --空白水不进行系数转换
        else
            consistency = consistency * config.system.standardConverCurveK + config.system.standardConverCurveB   --标样转换系数
        end
    end

    return consistency
end

--[[
 * @brief 吸光度反算
 * @param[in] consistency 浓度

--]]
function MeasureFlow:ReviseAbs(consistency)
    local absorbance = 0
    local curveK = config.measureParam.curveParam[self.currentRange].curveK
    local curveB = config.measureParam.curveParam[self.currentRange].curveB

    if math.abs(curveK - 0)<0.00001 then
        log:debug("校准数值异常")
        return 0
    end

    --consistency = consistency/diluteFactor
    absorbance = (consistency*curveK) + curveB


    return absorbance
end

--[[
 * @brief 检查标线是否为定标
--]]
function MeasureFlow:CheckCurve()
    local ret = true
    local timeStr = config.measureParam.curveParam[self.currentRange].timeStr

    if timeStr == "--" then
        ret = false
    end

    return ret
end

--[[
 * @brief 浓度小值修正
 * @param[in] consistency 浓度度
--]]
function MeasureFlow:ConsistencyRevise(consistency,infoPrintf)
    local ret = 0
    local pLowLimit = setting.measureResult.measureLowLimit
    local quantifyLowLimit = setting.measureResult.quantifyLowLimit
    local nLowLimit = -pLowLimit

    if self.currentModelType == ModelType.COD then
        pLowLimit = pLowLimit * 3
        quantifyLowLimit = quantifyLowLimit * 3
        nLowLimit = nLowLimit * 3
    end

    quantifyLowLimit = quantifyLowLimit*0.4
    if consistency < quantifyLowLimit then
        if infoPrintf == false then
            log:debug("低于检出限")
        else
            log:info("低于检出限")
        end
    end

    if consistency < nLowLimit then
        local random = 2 * (math.random() - 0.5 ) * setting.measureResult.negativeReviseWaveRange
        ret = setting.measureResult.negativeReviseBaseValue + random
    elseif nLowLimit <= consistency and consistency < -0.001 then
        ret = math.abs(consistency)
    elseif -0.001 <= consistency and consistency <= 0.001 then
        ret = setting.measureResult.zeroReviseValue
    else
        ret = consistency
    end

    return ret
end

--[[
 * @brief 浓度偏移
 * @param[in] consistency 浓度度
--]]
function MeasureFlow:ConsistencyOffset(consistency)
    local ret = consistency
    local quantifyLowLimit = setting.measureResult.quantifyLowLimit * self.diluteFactor

    if consistency < quantifyLowLimit then
        log:debug("结果偏移 原数值 = "..consistency.." 修正后数值 = "..(consistency + config.measureParam.measureDataOffsetValve))
        ret = consistency + config.measureParam.measureDataOffsetValve
    end

    return ret
end

--[[
 * @brief 量程范围检查
 * @param[in] result 结果浓度
 * @param[in] currange 当前量程
--]]
function MeasureFlow:RangeCheck(result, currange)
    if result >= setting.measure.range[currange].rangeWindowMin and
         result <= setting.measure.range[currange].rangeWindowMax then
        --log:debug("水样测量结果在量程内")
    elseif currange == 1 and result < setting.measure.range[currange].rangeWindowMin then
        log:info("水样超量程下限")
    elseif currange == setting.measure.range.rangeNum and result > setting.measure.range[currange].viewRange then
		log:info("水样超量程上限")
    else
        log:debug("结果"..self.consistency.."不在量程"..self.currentRange.."内")
        self.targetRange = self:RangeChange(self.consistency, self.currentRange)  --改变当前量程

        if self.targetRange ~= config.measureParam.currentRange then
            if self.currentModelType == ModelType.COD then
                if config.system.CODRangeViewMap[config.measureParam.range[self.targetRange + 1] + 1].view ~= nil then
                    log:info("量程自动切换至 = " .. config.system.CODRangeViewMap[config.measureParam.range[self.targetRange + 1] + 1].view)
                end
            else
                if config.system.TOCRangeViewMap[config.measureParam.range[self.targetRange + 1] + 1].view ~= nil then
                    log:info("量程自动切换至 = " .. config.system.TOCRangeViewMap[config.measureParam.range[self.targetRange + 1] + 1].view)
                end
            end
        end

        if config.measureParam.activeRangeMode == setting.mode.activeRange.now and self.targetRange ~= config.measureParam.currentRange then
            log:info("量程切换：立即生效")
            if self.faultTimes == 2 then
                log:debug("次数三次 停止测试")
                return
            end
            config.measureParam.currentRange = self.targetRange 		--更新量程配置文件
            ConfigLists.SaveMeasureParamConfig()
            self.currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1
            config.modifyRecord.measureParam(true)
            ConfigLists.SaveMeasureParamConfig()
            error(MeasureRangeWrongException:new())  --抛出量程错误异常
        elseif config.measureParam.activeRangeMode == setting.mode.activeRange.next and self.targetRange ~= config.measureParam.currentRange then
            log:info("量程切换：下次生效")
            self.isChangeRangeAtTheEnd = true
        elseif self.targetRange == config.measureParam.currentRange then
            log:info("量程切换：无需切换")
        end
    end

end


--[[
 * @brief 量程切换
 * @details 当测量结果不在当前量程范围内，自动切换量程。
 * @param[in] result, 结果浓度。
 * @param[in]  currange 当前量程。
--]]
function MeasureFlow:RangeChange(result, currange)
    local destRange = 0                                         --真实量程
    local realRange = config.measureParam.currentRange          --界面当前量程
    local rangeNum = 0

    --将量程存进表中
    local rangeTable = {}
    for i = 1, setting.measure.range.rangeNum do
        if         i == (config.measureParam.range[1] + 1)
                or i == (config.measureParam.range[2] + 1)
                or i == (config.measureParam.range[3] + 1) then
            rangeNum = rangeNum + 1
            table.insert(rangeTable, i)
        end
    end

    --向上切换 只允许向上切换一级
    if result > setting.measure.range[currange].rangeWindowMax then
        if rangeTable[rangeNum] == currange then
            log:info("量程已是配置的最大量程")
        else
            for num = 1, rangeNum do
                if rangeTable[num] > currange then
                    for i = 1, 3 do
                        if (rangeTable[num]-1) == config.measureParam.range[i] then
                            realRange = i-1
                            break
                        end
                    end
                    break
                end
            end
        end
        --向下切换
    elseif result < setting.measure.range[currange].rangeWindowMin then
        if currange ~= rangeTable[1] then
            for num, range in pairs(rangeTable) do
                if result < setting.measure.range[range].rangeWindowMax then
                    destRange = range
                    break
                end
            end

            --真实量程转换为界面当前量程一二三
            for i = 1, 3 do
                if (destRange - 1) == config.measureParam.range[i] then
                    realRange = i-1
                    break
                end
            end
        else
            log:info("量程已是配置的最小量程")
        end
    end

    return realRange
end


--[[
 * @brief 水样采集
 * @details 测量水样时，采集更新水样
--]]
function MeasureFlow:CollectSample()
    local waterCollector = WaterCollector.Instance()
    local mode = config.interconnection.collectSampleMode

    if mode == setting.mode.collectSample.beforeMeasure then

        local runAction = Helper.Status.SetAction(setting.runAction.collectSample.collect)
        StatusManager.Instance():SetAction(runAction)

        if not string.find(config.info.instrument["type"], "PT63P") then
            waterCollector:TurnOn()
        end
        Helper.Result.RelayOutOperate(setting.mode.relayOut.collectInstruct, true)

        if not self:Wait(config.interconnection.miningWaterTime) then 	-- 采集等待
            if config.interconnection.collectSampleMode ~= setting.mode.collectSample.trigger then
                if not string.find(config.info.instrument["type"], "PT63P") then
                    waterCollector:TurnOff()
                end
                Helper.Result.RelayOutOperate(setting.mode.relayOut.collectInstruct, false)
            end

            error(UserStopException:new())    --用户停止
        end

        runAction = Helper.Status.SetAction(setting.runAction.collectSample.silent)
        StatusManager.Instance():SetAction(runAction)

        if not string.find(config.info.instrument["type"], "PT63P") then
            waterCollector:TurnOff()
        end
        Helper.Result.RelayOutOperate(setting.mode.relayOut.collectInstruct, false)

        if not self:Wait(config.interconnection.silentTime) then 	-- 静默等待
            error(UserStopException:new())    --用户停止
        end
    elseif mode == setting.mode.collectSample.toAddSampleEnd or mode == setting.mode.collectSample.toMeaFlowEnd then
        local runAction = Helper.Status.SetAction(setting.runAction.collectSample.collect)
        StatusManager.Instance():SetAction(runAction)

        if not string.find(config.info.instrument["type"], "PT63P") then
            waterCollector:TurnOn()
        end
        Helper.Result.RelayOutOperate(setting.mode.relayOut.collectInstruct, true)

        if not self:Wait(config.interconnection.miningWaterTime) then 	-- 采集等待
            if config.interconnection.collectSampleMode ~= setting.mode.collectSample.trigger then
                if not string.find(config.info.instrument["type"], "PT63P") then
                    waterCollector:TurnOff()
                end
                Helper.Result.RelayOutOperate(setting.mode.relayOut.collectInstruct, false)
            end

            error(UserStopException:new())    --用户停止
        end
    end
end


--[[
 * @brief 重新测量检查
 * @details 当测量出现异常或结果异常时，进行重新测量。
--]]
function MeasureFlow:RetryMeasureCheck(isRangeCheck)
    local rangeCheckRetry = false
    self.isCrashMeasure = false  --清除崩溃标记

    if setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
        Measurer:ContinousMeasureSafetyStop()
        setting.measureResult.continousModeParam.isfinishContinousMeasure = false
    end

    if self.isFinish == true then
        log:debug("已出结果，无需重测");
        return false
    end

    --关闭异常重测
    if config.system.faultRetry ~= true then
        return false
    end

    if isRangeCheck == nil then
        rangeCheckRetry = false
    else
        rangeCheckRetry = isRangeCheck
    end

    self.faultTimes = self.faultTimes + 1   --更新重测次数记录

    if config.system.CCEPMode == true and CCEPSafeData < 2 then
        local useTime = os.time() - self.measureDateTime
        local leftTime = 3600 - useTime

        log:debug("安全测量剩余时间 = " .. leftTime .. " 安全测量时间 = " .. setting.measureResult.normalMeasureTime)
        if leftTime > setting.measureResult.normalMeasureTime then  --剩余时间充足,判断重测
            if self.faultTimes >= 3 then

                local isSave = false
                if self.measureType == MeasureType.Sample and config.scheduler.measure.mode == MeasureMode.Continous then
                    config.scheduler.measure.mode = MeasureMode.Trigger --连续测量变触发
                    isSave = true
                elseif self.measureType == MeasureType.ZeroCheck and config.scheduler.zeroCheck.mode == MeasureMode.Continous then
                    config.scheduler.zeroCheck.mode = MeasureMode.Trigger --连续测量变触发
                    isSave = true
                elseif self.measureType == MeasureType.RangeCheck and config.scheduler.rangeCheck.mode == MeasureMode.Continous then
                    config.scheduler.rangeCheck.mode = MeasureMode.Trigger --连续测量变触发
                    isSave = true
                end

                if isSave == true then
                    config.modifyRecord.scheduler(true)
                    ConfigLists.SaveSchedulerConfig()

                    local updateWidgetManager = UpdateWidgetManager.Instance()
                    updateWidgetManager:Update(UpdateEvent.ChangeMeaModeOnHome, "DeviceFaultException")
                end
                error(DeviceFaultException:new())   --抛出仪器故障运行停止异常
            else
                self.isRetryMeasure = true
                self.isRetryOnStart = true
                log:warn("测量异常重测次数 = "..self.faultTimes)
            end
        else	--生成安全测量结果
            self.isRetryMeasure = false
            self.isRetryOnStart = false
            self:SafeResultGenerate()
            self.isFinish = true
        end

    else
        if self.faultTimes >= 3 then

            --量程切换不作为错误返回
            if rangeCheckRetry == true then
                self.isRetryMeasure = false
                self.isRetryOnStart = false
                return true
            end

            local isSave = false
            if self.measureType == MeasureType.Sample and config.scheduler.measure.mode == MeasureMode.Continous then
                config.scheduler.measure.mode = MeasureMode.Trigger --连续测量变触发
                isSave = true
            elseif self.measureType == MeasureType.ZeroCheck and config.scheduler.zeroCheck.mode == MeasureMode.Continous then
                config.scheduler.zeroCheck.mode = MeasureMode.Trigger --连续测量变触发
                isSave = true
            elseif self.measureType == MeasureType.RangeCheck and config.scheduler.rangeCheck.mode == MeasureMode.Continous then
                config.scheduler.rangeCheck.mode = MeasureMode.Trigger --连续测量变触发
                isSave = true
            end

            if isSave == true then
                config.modifyRecord.scheduler(true)
                ConfigLists.SaveSchedulerConfig()

                local updateWidgetManager = UpdateWidgetManager.Instance()
                updateWidgetManager:Update(UpdateEvent.ChangeMeaModeOnHome, "DeviceFaultException")
            end
            error(DeviceFaultException:new())   --抛出仪器故障运行停止异常
        else
            self.isRetryMeasure = true
            self.isRetryOnStart = true
            log:warn("测量异常重测次数 = "..self.faultTimes)
        end
    end

    return true
end


--[[
 * @brief 安全结果生成
 * @details 剩余时间无法进行故障重测时，生成安全结果。
--]]
function MeasureFlow:SafeResultGenerate()

    local converfactor
    if self.measureType == MeasureType.Sample then
        converfactor = config.system.sampleConverCurveK
    elseif self.measureType == MeasureType.Blank then
        converfactor = 1
    else
        converfactor = config.system.standardConverCurveK
    end

    local curveK = config.measureParam.curveParam[self.currentRange].curveK
    local curveB = config.measureParam.curveParam[self.currentRange].curveB
    local diluteFactor = self.diluteFactor
    local random = 2*(math.random() - 0.5)*setting.measureResult.resultWaveRange

    local consistency = status.measure.report.measure.consistency + random   --生成浓度

    local oldConsistency = consistency/config.measureParam.reviseParameter[self.currentRange] --计算原始浓度
    local peakArea = oldConsistency * curveK + curveB  --生成吸光度

    --结果数据标识
    local resultMark = ResultMark.N
    self.reportMode = config.interconnection.reportMode     -- 出结果时重拿一次上报模式
    if self.reportMode == ReportMode.OnLine then
        --在线情况下 水样才去监测超上限与超量程的阈值，且核查才会标记为K
        if self.measureType == MeasureType.Sample then
            if self.consistency > config.interconnection.meaUpLimit and 1 == config.interconnection.overProofResultMark then
                resultMark = ResultMark.T
                self.isOverProof = true
            elseif self.consistency > config.system.rangeViewMap[self.currentRange].view then
                resultMark = ResultMark.E
            end
        elseif self.measureType == MeasureType.RangeCheck or self.measureType == MeasureType.ZeroCheck then
            resultMark = ResultMark.C
        elseif self.measureType == MeasureType.QualityHandle then
            resultMark = ResultMark.K
        end

        if self.measureType == MeasureType.RangeCheck or self.measureType == MeasureType.ZeroCheck then
            if 1 == config.interconnection.rangeCheckResultMark then
                resultMark = ResultMark.K
            end
        end
    elseif self.reportMode == ReportMode.OffLine then
        resultMark = ResultMark.B
    elseif self.reportMode == ReportMode.Maintain then
        resultMark = ResultMark.M
    elseif self.reportMode == ReportMode.Fault then
        resultMark = ResultMark.D
    elseif self.reportMode == ReportMode.Calibrate then
        resultMark = ResultMark.C
    elseif self.reportMode == ReportMode.Debugging then
        resultMark = ResultMark.A
    end

    --整点测量时，测量时间整点校正，手动启动不校正
    if self.adjustTime == true then  --排期设置
        if (self.measureType == MeasureType.Sample and config.scheduler.measure.mode == MeasureMode.Timed) or
                (self.measureType == MeasureType.ZeroCheck and config.scheduler.zeroCheck.mode == MeasureMode.Timed) or
                (self.measureType == MeasureType.RangeCheck and config.scheduler.rangeCheck.mode == MeasureMode.Timed) then

            self.measureDateTime = self:AdjustMeasureDateTime(self.measureDateTime)
        end
    end
--	print("Safe Result Generate.")
    local resultManager = ResultManager.Instance()
    local recordData = RecordData.new(resultManager:GetMeasureRecordDataSize(setting.resultFileInfo.measureRecordFile[1].name))
    recordData:PushInt(self.measureDateTime) -- 时间
    recordData:PushFloat(consistency) -- 浓度
    recordData:PushFloat(peakArea) -- 吸光度
    recordData:PushByte(resultMark) -- 结果标识
    recordData:PushByte(Measurer.measureType) -- 类型(当前测量过程)
    recordData:PushFloat(0) -- 初始制冷模块温度
    recordData:PushFloat(0) -- 初始测量模块温度
    recordData:PushFloat(0) -- 反应制冷模块温度
    recordData:PushFloat(0) -- 反应测量模块温度
    recordData:PushFloat(0) -- 初始值燃烧炉温度
    recordData:PushFloat(0) -- 初始值上机箱温度
    recordData:PushFloat(0) -- 初始值下机箱温度
    recordData:PushFloat(0) -- 反应值燃烧炉温度
    recordData:PushFloat(0) -- 反应值上机箱温度
    recordData:PushFloat(0) -- 反应值下机箱温度
    recordData:PushInt(os.time()-self.measureDateTime) -- 测量时长
    recordData:PushFloat(config.measureParam.curveParam[self.currentRange].RangeConsistency) -- 加量程校准液浓度
    recordData:PushFloat(self.currentView)   -- 当前使用量程
    recordData:PushByte(self.currentModelType)        --根据选择模式区分存储码
    recordData:PushFloat(string.format("%.2f", converfactor)) -- 水样转换系数
    recordData:PushFloat(string.format("%.2f", config.system.standardConverCurveK)) -- 标样转换系数
    
    -- 隐藏预估值
    if config.system.displayProformaResult == true then
        UpdateWidgetManager.Instance():Update(UpdateEvent.ShowNewProformaData, "")
    end

    Helper.Result.OnMeasureResultAdded(self.measureType, self.measureDateTime, consistency, self.reportMode, peakArea,self.isUseStart,false)
    resultManager:AddMeasureRecord(setting.resultFileInfo.measureRecordFile[1].name, recordData, true)
    ConfigLists.SaveMeasureStatus()

    self.isFinish = true

    --测量结果
    log:debug("测量结果：A = "..peakArea.."C = "..consistency)

    CCEPSafeData = CCEPSafeData + 1   --安全记录
    log:debug("Safe Result Generate Times = "..CCEPSafeData)
end

--[[
 * @brief 流程错误，生成上次测量结果
--]]
function MeasureFlow:FaultGetLastTimeResult()
    local consistency = status.measure.newResult.measure.consistency
    local peakArea = status.measure.newResult.measure.peakArea
    local measureType = status.measure.newResult.measure.resultType

    -- 隐藏预估值
    if config.system.displayProformaResult == true then
        UpdateWidgetManager.Instance():Update(UpdateEvent.ShowNewProformaData, "")
    end

    Helper.Result.OnMeasureResultAdded(measureType, self.measureDateTime, consistency, self.reportMode, peakArea,self.isUseStart, true)
    ConfigLists.SaveMeasureStatus()

    --测量结果
    log:debug("流程错误，测量结果生成：A = "..peakArea.." ,C = "..consistency)
end

--[[
 * @brief 整点测量的测量时间整点校准
 * @details 测量时间不是0分0秒时，对测量时间校准到整点。
--]]
function MeasureFlow:AdjustMeasureDateTime(meaDataTime)
    local newTime = meaDataTime

    local strOldTime = os.date("%Y-%m-%d %H:%M:%S",meaDataTime)
    log:debug("整点测量-原测量时间：" .. strOldTime .. " (" .. meaDataTime .. ")")

    if meaDataTime and meaDataTime >= 0 then

        local minute = tonumber(os.date("%M",meaDataTime))
        local second = tonumber(os.date("%S",meaDataTime))

        if minute >= 58 then
            newTime = newTime - minute * 60 - second + 3600   -- 当测量时间的分钟大于58时，分、秒清零，加1小时
        elseif minute > 0 and minute <= 20 then
            newTime = newTime - minute * 60 - second          -- 当测量时间的分钟大于0且小于5时，分、秒清零
        elseif minute == 0 and second > 0 then
            newTime = newTime - second                           -- 当测量时间的分钟等于0且秒大于0，秒清零
        end

        local strNewTime = os.date("%Y-%m-%d %H:%M:%S",newTime)
        log:debug("整点测量-新测量时间：" .. strNewTime .. " (" .. newTime .. ")")
    end

    return newTime
end