--[[
 * @brief 智能定量模块诊断流程。
--]]


SmartMeterDetectFlow = Flow:new
{
}

function SmartMeterDetectFlow:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.detectTime = os.time()

    return o
end

function SmartMeterDetectFlow:GetRuntime()
    return 0
end

function SmartMeterDetectFlow:OnStart()

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()

    --更新状态
    local runStatus = Helper.Status.SetStatus(setting.runStatus.smartDetect)
    StatusManager.Instance():SetStatus(runStatus)
    --更新动作
    local runAction = Helper.Status.SetAction(setting.runAction.smartMeterDetect)
    StatusManager.Instance():SetAction(runAction)

    self.isUserStop  = false
end

function SmartMeterDetectFlow:OnProcess()

    local flowManager = FlowManager.Instance()
    flowManager:UpdateFlowMessage(self.name, "诊断中...")
    ModbusInterface.detectResult = setting.modbusCoder.detectResultID.detecting

    local status = false

    --  诊断流程
    local detect = function()
        op:DrainToWaste(setting.liquid.meterPipeVolume)

        local repeatCount = 0
        local meterReTry = setting.liquid.meterFailedReTry	-- 定量失败重试次数
        local pointNum = config.hardwareConfig.meterPoint.num

        op:SetMeterOverValue(MeterMode.Accurate, setting.liquid.accurateMeterOverValue)
        
        for i=1, pointNum do
            local vol =  config.hardwareConfig.meterPoint.point[i].setVolume

            for repeatCount = 1, meterReTry do
                local err,result = pcall(function()  op:Meter(MeterMode.Accurate, setting.liquidType.blank, vol, RollDirection.Suck)  end)
                if not err then      -- 出现异常
                    if type(result) == "table" then
                        if getmetatable(result) == MeterFailedException then 			--定量中途出现故障，未能完成异常。
                            ExceptionHandler.MakeAlarm(result)
                        elseif getmetatable(result) == MeterOverflowException then
                            ExceptionHandler.MakeAlarm(result)
                        elseif getmetatable(result) == MeterUnfinishedException then 		--定量目标未达成异常。
                            ExceptionHandler.MakeAlarm(result)
                        elseif getmetatable(result) == MeterAirBubbleException then
                            ExceptionHandler.MakeAlarm(result)
                        elseif getmetatable(result) == MeterExpectTimeoutException then 	--定量超时异常。
                            ExceptionHandler.MakeAlarm(result)
                        else
                            error(result)								--其他定义类型异常
                        end
                    else
                        error(result)									--C++、Lua系统异常
                    end
                else
                    break
                end

                if repeatCount >= meterReTry  then
                    error (MeterFailedException:new{liquidType = setting.liquidType.blank,})
                end

                op:DrainToWaste(vol, WasteType.WasteWater)
            end
        end

        status = true
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
                log:warn("SmartMeterDetectFlow:OnProcess() =>" .. result:What())
            end
        elseif type(result) == "table" then
            if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                self.isUserStop = true
            elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                self.isUserStop = true
            elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                self.isUserStop = true
            elseif getmetatable(result) == PumpFailedException then 			--泵操作中途出现故障，未能完成异常。

            else
                log:warn("SmartMeterDetectFlow:OnProcess() =>" .. result:What())								--其他定义类型异常
            end
        elseif type(result) == "string" then
            log:warn("SmartMeterDetectFlow:OnProcess() =>" .. result)	--C++、Lua系统异常
        end
    end

    if self.isUserStop then
        self.result = "停止"
        ModbusInterface.detectResult = setting.modbusCoder.detectResultID.stop
    else										--其他试剂阀诊断
        if status == true then
            self.result = "通过"
            ModbusInterface.detectResult = setting.modbusCoder.detectResultID.passed
        else
            self.result = "未通过"
            ModbusInterface.detectResult = setting.modbusCoder.detectResultID.fail
        end

        op:DrainToWaste(setting.liquid.meterPipeVolume, WasteType.WasteWater)
        op:SecludeLiquid(setting.liquidType.blank)
    end
end

function SmartMeterDetectFlow:OnStop()

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()


    --保存试剂余量表
    ReagentRemainManager.SaveRemainStatus()

    log:info("智能定量模块诊断结束")
    log:debug("定量模块诊断时间 = "..os.time() - self.detectTime )
end
