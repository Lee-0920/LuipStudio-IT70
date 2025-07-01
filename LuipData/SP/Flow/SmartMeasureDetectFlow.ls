--[[
 * @brief 智能测量模块诊断流程。
--]]


SmartMeasureDetectFlow = Flow:new
{
}

function SmartMeasureDetectFlow:new(o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self

    o.detectTime = os.time()

        return o
end

function SmartMeasureDetectFlow:GetRuntime()
    return 0
end

function SmartMeasureDetectFlow:OnStart()

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()

    --重设LED测量周期
    op:ResetLEDMeasurePeriod()

    --检测消解室是否为安全温度
    op:CheckDigestSafety()

    --更新状态
    local runStatus = Helper.Status.SetStatus(setting.runStatus.smartDetect)
    StatusManager.Instance():SetStatus(runStatus)
    --更新动作
    local runAction = Helper.Status.SetAction(setting.runAction.smartMeasureDetect)
    StatusManager.Instance():SetAction(runAction)

    self.isUserStop  = false
end

function SmartMeasureDetectFlow:OnProcess()

    local flowManager = FlowManager.Instance()
    flowManager:UpdateFlowMessage(self.name, "诊断中...")
    ModbusInterface.detectResult = setting.modbusCoder.detectResultID.detecting

    local status = false

    --  诊断流程
    local detect = function()
        --op:DrainToWaste(setting.liquid.meterPipeVolume)
        --op:DrainFromDigestionRoom()
		
        --local AD0 = op:StartAcquirerAD(setting.signal.readADTime)
        op:TurnOnNirtrogen()
        dc:GetIOpticalAcquire():TurnOnLED()	--开LED

        local cntLimit = 90
        while true do
            local carriagePressture = dc:GetPressure(setting.pressure.pressureCarry)
            print("pressure " .. carriagePressture)
            if carriagePressture > config.measureParam.carryingPressure - setting.pressure.WarningPressureTolerance
                    and carriagePressture < config.measureParam.carryingPressure + setting.pressure.WarningPressureTolerance then
                break
            else
                if not self:Wait(2) then
                    error(UserStopException:new())    --用户停止
                end
                cntLimit = cntLimit - 1
                if cntLimit < 0 then
                    local alarm
                    if carriagePressture < config.measureParam.carryingPressure then
                        alarm = Helper.MakeAlarm(setting.alarm.airFlowPressureLower, string.format("%0.2f", carriagePressture) .. "kPa")
                        AlarmManager.Instance():AddAlarm(alarm)
                        error(AirFlowPressureLowerException:new())
                    else
                        alarm = Helper.MakeAlarm(setting.alarm.airFlowPressureHigher, string.format("%0.2f", carriagePressture) .. "kPa")
                        AlarmManager.Instance():AddAlarm(alarm)
                        error(AirFlowPressureHigherException:new())
                    end
                end
            end
        end

        if not self:Wait(60) then
            error(UserStopException:new())    --用户停止
        end

        local ScanData = 0
        local ScanLen = dc:GetScanLen()

        for i = 1, 5 do
            ScanData = ScanData + dc:GetScanData(ScanLen - 1)
            ScanLen = ScanLen + 1
            App.Sleep(1000)
        end
        ScanData = ScanData / 5

        dc:GetIOpticalAcquire():TurnOffLED()     --关LED
        log:debug("测量值： " .. ScanData)
        if ScanData > 2 and ScanData < 4 then
            status = true 
        end
    end

    --执行
    local err,result = pcall(function()  detect() end)

    if not err then      -- 出现异常
        if type(result) == "userdata" then
            if result:GetType() == "ExpectEventTimeoutException" then          --期望事件等待超时异常。
                ExceptionHandler.MakeAlarm(result)
            elseif result:GetType() == "CommandTimeoutException" then          --命令应答超时异常
                ExceptionHandler.MakeAlarm(result)
            else
                log:warn("SmartMeasureDetectFlow:OnProcess() =>" .. result:What())
            end
        elseif type(result) == "table" then
            if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                self.isUserStop = true
            elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                self.isUserStop = true
            elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                self.isUserStop = true
            elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                self.isUserStop = true 
            elseif getmetatable(result) == AcquirerADFailedException then 	    --光学采集中途出现故障，未能完成异常。
                ExceptionHandler.MakeAlarm(result)                                
            elseif getmetatable(result) == PumpFailedException then 			--泵操作中途出现故障，未能完成异常。
                ExceptionHandler.MakeAlarm(result)
            elseif getmetatable(result) == MeterFailedException then 			--定量中途出现故障，未能完成异常。
                ExceptionHandler.MakeAlarm(result)
            else
                log:warn("SmartMeasureDetectFlow:OnProcess() =>" .. result:What())								--其他定义类型异常
            end
        elseif type(result) == "string" then
            log:warn("SmartMeasureDetectFlow:OnProcess() =>" .. result)	--C++、Lua系统异常
        end
    end

    if self.isUserStop then
        self.result = "停止"
        ModbusInterface.detectResult = setting.modbusCoder.detectResultID.stop
    else
        if status == true then
            self.result = "通过"
            ModbusInterface.detectResult = setting.modbusCoder.detectResultID.passed
        else
            self.result = "未通过"
            ModbusInterface.detectResult = setting.modbusCoder.detectResultID.fail
        end
    end
end

function SmartMeasureDetectFlow:OnStop()

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()
    dc:GetIOpticalAcquire():TurnOffLED()	--关LED
    dc:ClearBuf()--清buf,防止数组刷新

    log:info("智能测量模块诊断结束")
    log:debug("诊断时间 = "..os.time() - self.detectTime )
end
