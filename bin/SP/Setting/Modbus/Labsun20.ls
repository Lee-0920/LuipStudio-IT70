setting.externalInterface = {}

setting.externalInterface.modbus =
{
    calculateNextRangeCheckTime = function()
        local nextStartTime_Hour
        local nextStartTime
        local freeTime = {}
        local isHaveFreeTime = false
        for i = 1,24 do
            if config.scheduler.measure.timedPoint[i] ~= true and
                    config.scheduler.zeroCheck.timedPoint[i] ~= true then
                table.insert(freeTime,i-1)
                isHaveFreeTime = true
            end
        end

        if isHaveFreeTime == false then
            log:debug("没有空闲整点时间")
            return false
        end

        local curTimeData = os.date("*t",os.time())

        for v,time in pairs(freeTime) do
            if curTimeData.hour < time then
                log:debug("下个空闲整点时间为 "..time)
                nextStartTime_Hour = time
                break
            end
        end

        if nextStartTime_Hour == nil then
            curTimeData.day = curTimeData.day + 1
            nextStartTime_Hour = freeTime[1]
            log:debug("当天没有空闲整点时间，跳转至第二天")
        elseif config.scheduler.rangeCheck.timedPoint[nextStartTime_Hour] == true then
            log:debug("下个空闲时间已是核查")
            return false
        end

        curTimeData.hour = nextStartTime_Hour
        curTimeData.min  = 0
        curTimeData.sec  = 0

        nextStartTime = os.time(curTimeData)

        return true ,nextStartTime
    end,

    inputRegAddr = 0,
    inputRegNum = 0,
    holdRegAddr = 0,
    holdRegNum = 256,

    registers =
    {
        [0] = --水样测量结果
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 0 - setting.externalInterface.modbus.holdRegAddr

                local value = status.measure.report.measure.consistency

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [2] = --水样测量吸光度
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 2 - setting.externalInterface.modbus.holdRegAddr

                local value = status.measure.report.measure.absorbance

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [4] = --水样测量时间
        {
            number = 3, -- Register number

            read = function()
                local offsetAddress = 4 - setting.externalInterface.modbus.holdRegAddr

                local time = status.measure.report.measure.dateTime

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetHexTime(RegisterType.Hold, offsetAddress, time)
            end,

            write = function()
            end,
        },
        [7] = --水样数据标识
        {
            number = 1, -- Register number

            read = function()
                local offsetAddress = 7 - setting.externalInterface.modbus.holdRegAddr
                local resultInfo = status.measure.report.measure.resultInfo
                local ret = 0

                if resultInfo == "D" then
                    ret = 3
                elseif resultInfo == "U" then
                    ret = 9
                elseif resultInfo == "A" then
                    ret = 8
                elseif resultInfo == "K" then
                    ret = 7
                elseif resultInfo == "M" then
                    ret = 2
                elseif resultInfo == "C" then
                    ret = 4
                elseif resultInfo == "T" then
                    ret = 6
                elseif resultInfo == "L" then
                    ret = 5
                elseif resultInfo == "B" then
                    ret = 1
                elseif resultInfo == "N" then
                    ret = 0
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetShort(RegisterType.Hold, offsetAddress, ret)
            end,

            write = function()
            end,
        },
        [8] = --当前工作状态
        {
            number = 1, -- Register number

            read = function()
                local offsetAddress = 8 - setting.externalInterface.modbus.holdRegAddr
                local modbusManager = ModbusManager.Instance()

                local statusManager = StatusManager.Instance()
                local runStatus = statusManager:GetStatus()
                local name = runStatus:GetName()
                local result = 0

                if setting.modbusCoder.statusID[name].dbsID ~= nil then
                    result = setting.modbusCoder.statusID[name].dbsID
                end

                if result == 19 then
                    if name == "OnlyCalibrateBlank" then
                        result = 8
                    elseif name == "OnlyCalibrateStandard" then
                        result = 9
                    else
                        result = 8
                    end
                end

                modbusManager:SetShort(RegisterType.Hold, offsetAddress, result)
            end,

            write = function()
            end,
        },
        [9] = --当前运行标记
        {
            number = 1, -- Register number

            read = function()
                local offsetAddress = 9 - setting.externalInterface.modbus.holdRegAddr

                local statusManager = StatusManager.Instance()
                local runStatus = statusManager:GetStatus()
                local name = runStatus:GetName()
                local alarmManager = AlarmManager.Instance()
                local modbusManager = ModbusManager.Instance()
                local ret = 0
                if alarmManager:GetUpLoadStatus() or config.interconnection.reportMode == _G.ReportMode.Fault then
                    ret = 3
                elseif config.interconnection.reportMode == _G.ReportMode.OffLine then
                    ret = 1
                elseif config.interconnection.reportMode == _G.ReportMode.Debugging then
                    ret = 8
                elseif config.interconnection.reportMode == _G.ReportMode.Maintain then
                    ret = 2
                elseif config.interconnection.reportMode == _G.ReportMode.Calibrate
                        or name == "Calibrate"
                        or name == "OnlyCalibrateBlank"
                        or name == "OnlyCalibrateStandard" then
                    ret = 4
                elseif config.interconnection.reportMode == _G.ReportMode.OnLine and name == "MeasureRangeCheck" then
                    ret = 7
                end

                modbusManager:SetShort(RegisterType.Hold, offsetAddress, ret)
            end,

            write = function()
            end,
        },
        [10] = --  当前工作量程上限
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 10 - setting.externalInterface.modbus.holdRegAddr

                local rangeMax = 0
                local currentRange = config.measureParam.range[config.measureParam.currentRange + 1] + 1

                if config.system.rangeViewMap[currentRange].view ~= nil then
                    rangeMax = config.system.rangeViewMap[currentRange].view
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, rangeMax)
            end,

            write = function()
            end,
        },
        [12] = -- 小数位数
        {
            number = 1, -- Register number

            read = function()
                local offsetAddress = 12 - setting.externalInterface.modbus.holdRegAddr

                local temp = setting.measureResult.decimalNum

                if nil ~= config.system.decimalNum then
                    temp = config.system.decimalNum
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetShort(RegisterType.Hold, offsetAddress, temp)
            end,

            write = function()
            end,
        },
        [13] = --分析仪取样时间
        {
            number = 1, -- Register number

            read = function()
                local offsetAddress = 13 - setting.externalInterface.modbus.holdRegAddr
                local temp = 0
                if config.scheduler.measure.mode == MeasureMode.Timed then
                    local timedStart = 0
                    local timedEnd = 1
                    local timedInterval = 0
                    for i=1,24 do
                        if config.scheduler.measure.timedPoint[i] == true then
                            timedEnd = i
                            if timedStart ~= 0 and timedEnd - timedStart > 0 then
                                if timedInterval ~= 0 then
                                    if timedInterval ~= timedEnd - timedStart then
                                        timedInterval = config.scheduler.measure.interval
                                        break
                                    end
                                else
                                    timedInterval = timedEnd - timedStart
                                end
                            end
                            timedStart = i
                        end
                    end
                    temp = math.ceil(timedInterval * 60)
                else
                    temp = math.ceil(config.scheduler.measure.interval * 60)
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetShort(RegisterType.Hold, offsetAddress, temp)
            end,

            write = function()
            end,
        },
        [14] = --  消解温度
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 14 - setting.externalInterface.modbus.holdRegAddr

                local temp = config.measureParam.digestTemperature

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, temp)
            end,

            write = function()
            end,
        },
        [16] = -- 消解时间(分钟)
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 16 - setting.externalInterface.modbus.holdRegAddr

                local temp = config.measureParam.digestTime / 60

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, temp)
            end,

            write = function()
            end,
        },
        [18] = --曲线斜率
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 18 - setting.externalInterface.modbus.holdRegAddr
                local curveK = 1
                local curveB = 0
                if nil ~= config.measureParam.curveParam.curveK then
                    curveK = config.measureParam.curveParam.curveK
                    curveB = config.measureParam.curveParam.curveB
                else
                    curveK = config.measureParam.curveParam[config.measureParam.range[config.measureParam.currentRange + 1]+1].curveK
                    curveB = config.measureParam.curveParam[config.measureParam.range[config.measureParam.currentRange + 1]+1].curveB
                end

                curveK, curveB  = CurveParamCurveXYChange(curveK, curveB)

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, curveK)
            end,

            write = function()
            end,
        },
        [20] = --曲线截距
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 20 - setting.externalInterface.modbus.holdRegAddr
                local curveK = 1
                local curveB = 0
                if nil ~= config.measureParam.curveParam.curveK then
                    curveK = config.measureParam.curveParam.curveK
                    curveB = config.measureParam.curveParam.curveB
                else
                    curveK = config.measureParam.curveParam[config.measureParam.range[config.measureParam.currentRange + 1]+1].curveK
                    curveB = config.measureParam.curveParam[config.measureParam.range[config.measureParam.currentRange + 1]+1].curveB
                end

                curveK, curveB  = CurveParamCurveXYChange(curveK, curveB)

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, curveB)
            end,

            write = function()
            end,
        },
        [22] = --检出限值(定量下限)
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 22 - setting.externalInterface.modbus.holdRegAddr

                local valve = 0

                if setting.measureResult.quantifyLowLimit ~= nil then
                    valve = setting.measureResult.quantifyLowLimit
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, valve)
            end,

            write = function()
            end,
        },
        [24] = --当前量程标液1浓度
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 24 - setting.externalInterface.modbus.holdRegAddr

                local valve = 0
                if nil ~= config.measureParam.curveParam then
                    valve = config.measureParam.curveParam[config.measureParam.range[config.measureParam.currentRange + 1]+1].ZeroConsistency
                else
                    if config.measureParam.calibratePointConsistency[1] ~= nil then
                        valve = config.measureParam.calibratePointConsistency[1]
                    end
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, valve)
            end,

            write = function()
            end,
        },
        [26] = --当前量程标液2浓度
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 26 - setting.externalInterface.modbus.holdRegAddr

                local valve = 0
                if nil ~= config.measureParam.curveParam then
                    valve = config.measureParam.curveParam[config.measureParam.range[config.measureParam.currentRange + 1]+1].RangeConsistency
                else
                    if config.measureParam.calibratePointConsistency[2] ~= nil then
                        valve = config.measureParam.calibratePointConsistency[2]
                    end
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, valve)
            end,

            write = function()
            end,
        },
        [28] = --校准时间
        {
            number = 3, -- Register number

            read = function()
                local offsetAddress = 28 - setting.externalInterface.modbus.holdRegAddr

                local time = status.measure.newResult.calibrate.dateTime

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetHexTime(RegisterType.Hold, offsetAddress, time)
            end,

            write = function()
            end,
        },
        [31] = --量程(标样)核查浓度
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 31 - setting.externalInterface.modbus.holdRegAddr

                local value = status.measure.report.rangeCheck.consistency

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [33] = --量程(标样)核查吸光度
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 33 - setting.externalInterface.modbus.holdRegAddr

                local value = status.measure.report.rangeCheck.absorbance

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [35] = --量程(标样)核查时间
        {
            number = 3, -- Register number

            read = function()
                local offsetAddress = 35 - setting.externalInterface.modbus.holdRegAddr

                local time = status.measure.report.rangeCheck.dateTime

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetHexTime(RegisterType.Hold, offsetAddress, time)
            end,

            write = function()
            end,
        },
        [38] = --量程(标样)核查设置浓度
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 38 - setting.externalInterface.modbus.holdRegAddr

                local value = config.measureParam.checkConsistency

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [40] = --量程(标样)核查偏差限值
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 40 - setting.externalInterface.modbus.holdRegAddr

                local value = config.measureParam.checkErrorLimit

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [42] = --系统时间
        {
            number = 3, -- Register number

            read = function()
                local offsetAddress = 42 - setting.externalInterface.modbus.holdRegAddr

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetHexTime(RegisterType.Hold, offsetAddress, os.time() )
            end,

            write = function()
                local offsetAddress = 42 - setting.externalInterface.modbus.holdRegAddr

                if not config.system.solidifyMeaParamFromModbus then
                    local modbusManager = ModbusManager.Instance()
                    modbusManager:SetHexSysTime(RegisterType.Hold, offsetAddress)
                end
            end,
        },
        [45] = --仪器最新测量值（所有结果）
        {
            number = 2, -- Register number

            read = function()
                local offsetAddress = 45 - setting.externalInterface.modbus.holdRegAddr

                local value = status.measure.newResult.measure.consistency

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [47] = --仪器最新吸光度
        {
            number = 2,

            read = function()
                local offsetAddress = 47 - setting.externalInterface.modbus.holdRegAddr

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, status.measure.newResult.measure.absorbance)
            end,

            write = function()
            end,
        },
        [49] = --仪器最新数据标记
        {
            number = 1, -- Register number

            read = function()
                local offsetAddress = 49 - setting.externalInterface.modbus.holdRegAddr

                local code = 0

                local resultInfo = status.measure.newResult.measure.resultInfo

                if resultInfo == "Q" then
                    code = 10
                elseif resultInfo == "U" then
                    code = 9
                elseif resultInfo == "Td" then
                    code = 8
                elseif resultInfo == "A" then
                    code = 7
                elseif resultInfo == "B" then
                    code = 6
                elseif resultInfo == "K" then
                    code = 5
                elseif resultInfo == "C" then
                    code = 4
                elseif resultInfo == "D" then
                    code = 3
                elseif resultInfo == "M" then
                    code = 2
                elseif resultInfo == "T" then
                    code = 1
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetShort(RegisterType.Hold, offsetAddress, code)
            end,

            write = function()
            end,
        },
        [50] = --仪器最新数据标记
        {
            number = 1, -- Register number

            read = function()
                local offsetAddress = 50 - setting.externalInterface.modbus.holdRegAddr

                local resultInfo = status.measure.newResult.measure.resultInfo

                if resultInfo == "K" then
                elseif resultInfo == "C" then
                elseif resultInfo == "M" then
                elseif resultInfo == "T" then
                elseif resultInfo == "D" then
                elseif resultInfo == "B" then
                elseif resultInfo == "A" then
                elseif resultInfo == "Td" then
                elseif resultInfo == "U" then
                elseif resultInfo == "Q" then
                else
                    resultInfo = "N"
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetCharString(RegisterType.Hold, offsetAddress, resultInfo, 1)
            end,

            write = function()
            end,
        },
        [51] = --仪器最新数据采集时间
        {
            number = 6,

            read = function()
                local offsetAddress = 51 - setting.externalInterface.modbus.holdRegAddr
                local DataTime = status.measure.newResult.measure.dateTime

                local temp = os.date("*t",DataTime)

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetShort(RegisterType.Hold, offsetAddress + 0, temp.year)
                modbusManager:SetShort(RegisterType.Hold, offsetAddress + 1, temp.month)
                modbusManager:SetShort(RegisterType.Hold, offsetAddress + 2, temp.day)
                modbusManager:SetShort(RegisterType.Hold, offsetAddress + 3, temp.hour)
                modbusManager:SetShort(RegisterType.Hold, offsetAddress + 4, temp.min)
                modbusManager:SetShort(RegisterType.Hold, offsetAddress + 5, temp.sec)
            end,

            write = function()
            end,
        },
        [57] =   -- 零点校准误差
        {
            number = 2,        -- Register number

            read = function()
                local offsetAddress = 57 - setting.externalInterface.modbus.holdRegAddr

                local value = 0

                if nil ~= status.measure.newResult.calibrate.zeroCheckError then
                    value = 100 * status.measure.newResult.calibrate.zeroCheckError
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [59] =   -- 标点校准误差
        {
            number = 2,        -- Register number

            read = function()
                local offsetAddress = 59 - setting.externalInterface.modbus.holdRegAddr

                local value = 0

                if nil ~= status.measure.newResult.calibrate.standardCheckError then
                    value = 100 * status.measure.newResult.calibrate.standardCheckError
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [61] =   -- 核查误差
        {
            number = 2,        -- Register number

            read = function()
                local offsetAddress = 61 - setting.externalInterface.modbus.holdRegAddr

                local value = 0

                if nil ~= status.measure.report.rangeCheck.checkError then
                    value = 100 * status.measure.report.rangeCheck.checkError
                end

                local modbusManager = ModbusManager.Instance()
                modbusManager:SetFloat(RegisterType.Hold, offsetAddress, value)
            end,

            write = function()
            end,
        },
        [63] =   -- 预留
        {
            number = 38,        -- Register number

            read = function()
            end,

            write = function()
            end,
        },
        [100] =
        {
            number = 1, -- Register number
            read = function()
            end,

            write = function()
                local offsetAddress = 100 - setting.externalInterface.modbus.holdRegAddr

                local modbusManager = ModbusManager.Instance()
                local optcode = modbusManager:GetShort(RegisterType.Hold, offsetAddress)

                local flowManager = FlowManager.Instance()
                if flowManager:IsAuthorize() == true and config.interconnection.reportMode ~= _G.ReportMode.Maintain then
                    log:debug("ModbusManager LS2.0 100 optcode = "..optcode)
                    if optcode == 0 then
                        flowManager:StopFlow()

                        if config.scheduler.measure.mode == MeasureMode.Continous then
                            config.scheduler.measure.mode = MeasureMode.Trigger
                            config.modifyRecord.scheduler(true)
                            ConfigLists.SaveSchedulerConfig()

                            local updateWidgetManager = UpdateWidgetManager.Instance()
                            updateWidgetManager:Update(UpdateEvent.ChangeMeaModeOnHome, "Modbus")
                        end
                    elseif optcode == 1 then
                        if flowManager:IsFlowEnable() == true then
                            local flow = MeasureFlow:new({}, MeasureType.Sample)
                            flow.name = "MeasureSample"
                            FlowList.AddFlow(flow)
                            flowManager:StartFlow()
                        end
                    elseif optcode == 2 then
                        if flowManager:IsFlowEnable() == true then
                            local flow = CalibrateFlow:new({}, CalibrateType.calibrate)
                            flow.name  = "Calibrate"
                            FlowList.AddFlow(flow)
                            flowManager:StartFlow()
                        end
                    elseif optcode == 3 then
                        if flowManager:IsFlowEnable() == true then
                            local flow = CalibrateFlow:new({}, CalibrateType.onlyCalibrateBlank)
                            flow.name  = "OnlyCalibrateBlank"
                            FlowList.AddFlow(flow)
                            flowManager:StartFlow()
                        end
                    elseif optcode == 4 then
                        if flowManager:IsFlowEnable() == true then
                            local flow = CalibrateFlow:new({}, CalibrateType.onlyCalibrateStandard)
                            flow.name  = "OnlyCalibrateStandard"
                            FlowList.AddFlow(flow)
                            flowManager:StartFlow()
                        end
                    elseif optcode == 5 then
                        local needSetScheduler,nextStartTime = setting.externalInterface.modbus.calculateNextRangeCheckTime()
                        if needSetScheduler == true then
                            config.scheduler.rangeCheck.ZJ.lastMode = config.scheduler.rangeCheck.mode
                            if config.scheduler.rangeCheck.mode ~= MeasureMode.Timed then
                                log:info("根据协议需求，核查更改为整点模式")
                                config.scheduler.rangeCheck.mode = MeasureMode.Timed
                            end

                            config.scheduler.rangeCheck.timedPoint[os.date("%H",nextStartTime) + 1] = true
                            config.scheduler.rangeCheck.ZJ.nextStartTime = nextStartTime
                            config.modifyRecord.scheduler(true)
                            ConfigLists.SaveSchedulerConfig()

                            local updateWidgetManager = UpdateWidgetManager.Instance()
                            updateWidgetManager:Update(UpdateEvent.ChangeAutoMeasure, "Modbus")
                        end
                    elseif optcode == 6 then
                        if flowManager:IsFlowEnable() == true then
                            local flow = MeasureFlow:new({}, MeasureType.RangeCheck)
                            flow.name  = "MeasureRangeCheck"
                            FlowList.AddFlow(flow)
                            flowManager:StartFlow()
                        end
                    elseif optcode == 10 then
                        local nextStartTime = os.date("%H",config.scheduler.rangeCheck.ZJ.nextStartTime)
                        if config.scheduler.rangeCheck.mode == MeasureMode.Timed then
                            config.scheduler.rangeCheck.mode = config.scheduler.rangeCheck.ZJ.lastMode
                            config.scheduler.rangeCheck.timedPoint[os.date("%H",nextStartTime) + 1] = false
                            config.modifyRecord.scheduler(true)
                            ConfigLists.SaveSchedulerConfig()

                            local updateWidgetManager = UpdateWidgetManager.Instance()
                            updateWidgetManager:Update(UpdateEvent.ChangeAutoMeasure, "Modbus")
                        end
                    else
                        log:debug("无效命令 code = "..optcode)
                    end
                end
            end,
        },
    }
}