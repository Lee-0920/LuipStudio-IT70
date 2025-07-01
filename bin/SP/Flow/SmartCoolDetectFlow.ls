--[[
 * @brief 智能冷却模块诊断流程。
--]]


SmartCoolDetectFlow = Flow:new
{
}

function SmartCoolDetectFlow:new(o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self

    o.detectTime = os.time()

        return o
end

function SmartCoolDetectFlow:GetRuntime()
    return 0
end

function SmartCoolDetectFlow:OnStart()

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()

    --检测消解室是否为安全温度
    op:CheckDigestSafety()

    --更新状态
    local runStatus = Helper.Status.SetStatus(setting.runStatus.smartDetect)
    StatusManager.Instance():SetStatus(runStatus)
    --更新动作
    local runAction = Helper.Status.SetAction(setting.runAction.smartCoolDetect)
    StatusManager.Instance():SetAction(runAction)

    self.isUserStop  = false
end

function SmartCoolDetectFlow:OnProcess()

    local flowManager = FlowManager.Instance()
    flowManager:UpdateFlowMessage(self.name, "诊断中...")
    ModbusInterface.detectResult = setting.modbusCoder.detectResultID.detecting

    local status = false
    local errorcnt = 12

    --  诊断流程
    local detect = function()
        --local thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
        local thermostatTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
        while true do
            thermostatTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
            if thermostatTemp >= config.measureParam.coolTemperature - setting.temperature.toleranceTemp and
                    thermostatTemp <=  config.measureParam.coolTemperature + setting.temperature.toleranceTemp then
                status = true
                break
            elseif errorcnt < 0 then
                error(ThermostatFailedException:new({mode = ThermostatMode.Refrigerate, targetTemp = config.measureParam.coolTemperature, toleranceTemp = setting.temperature.toleranceTemp, timeout = 120}))
                break
            end
            if not self:Wait(10) then
                error(UserStopException:new())    --用户停止
            end
            errorcnt = errorcnt - 1
        end

        log:debug("智能检测制冷温度： ".. thermostatTemp)


        --if thermostatTemp > config.measureParam.coolTemperature - setting.temperature.coolToleranceTemp and
        --        thermostatTemp < config.measureParam.coolTemperature + setting.temperature.coolToleranceTemp then
        --    status = true
        --else
        --
        --    local targeTemp
        --
        --    if thermostatTemp > config.measureParam.coolTemperature + 10 then
        --        targeTemp = config.measureParam.coolTemperature + 5
        --    end
        --
        --    if 80 - targeTemp > 0.01  then
        --
        --        op:ReviseThermostatTemp(setting.temperature.indexRefrigerator, ThermostatMode.Refrigerate, config.measureParam.coolTemperature, setting.temperature.coolToleranceTemp, setting.temperature.smartCoolDetectTime)
        --
        --        if not self:Wait(60) then
        --            error(UserStopException:new())    --用户停止
        --        end
        --
        --        local temp = dc:GetReportThermostatTemp(0) - targeTemp
        --        if temp < 0 then
        --            --op:StartThermostat(ThermostatMode.Refrigerate, thermostatTemp, 1, setting.temperature.smartHeatDetectTime * 2)
        --            --op:StopThermostat()
        --            status = true
        --        end
        --    end
        --end

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
                log:warn("SmartCoolDetectFlow:OnProcess() =>" .. result:What())
            end
        elseif type(result) == "table" then
            if getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                self.isUserStop = true
            elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                self.isUserStop = true
            elseif getmetatable(result) == ThermostatFailedException then 		--恒温中途出现故障，未能完成异常。
                ExceptionHandler.MakeAlarm(result)
            elseif getmetatable(result) == ThermostatTimeoutException then 		--恒温超时，指定时间内仍未达到目标温度异常
                ExceptionHandler.MakeAlarm(result)
            else
                log:warn("SmartCoolDetectFlow:OnProcess() =>" .. result:What())								--其他定义类型异常
            end
        elseif type(result) == "string" then
            log:warn("SmartCoolDetectFlow:OnProcess() =>" .. result)	--C++、Lua系统异常
        end
    end

    ----获取恒温器状态
    --if dc:GetITemperatureControl():GetThermostatStatus() == 2 then
    --    op:StopThermostat()
    --end

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

function SmartCoolDetectFlow:OnStop()

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()
    --检测消解室是否为安全温度
    op:CheckDigestSafety()

    log:info("智能冷却模块诊断结束")
    log:debug("诊断时间 = "..os.time() - self.detectTime )
end
