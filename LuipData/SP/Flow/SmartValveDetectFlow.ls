--[[
 * @brief 智能阀诊断流程。
--]]


SmartValveDetectFlow = Flow:new
{
}

function SmartValveDetectFlow:new(o, target, act)
        o = o or {}
        setmetatable(o, self)
        self.__index = self

    o.valveTarget = target
    o.action = act
    o.detectTime = os.time()

        return o
end

function SmartValveDetectFlow:GetRuntime()
    return 0
end

function SmartValveDetectFlow:OnStart()

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()

    --检测消解室是否为安全温度
    op:CheckDigestSafety()

    --更新状态
    local runStatus = Helper.Status.SetStatus(setting.runStatus.smartDetect)
    StatusManager.Instance():SetStatus(runStatus)
    --更新动作
    local runAction = Helper.Status.SetAction(self.action)
    StatusManager.Instance():SetAction(runAction)

    self.isUserStop  = false
end

function SmartValveDetectFlow:OnProcess()

    local flowManager = FlowManager.Instance()
    flowManager:UpdateFlowMessage(self.name, "诊断中...")
    ModbusInterface.detectResult = setting.modbusCoder.detectResultID.detecting

    local status = false

    -- 诊断流程
    local detect = function()
        op:DrainToWaste(setting.liquid.meterPipeVolume)

        if self.valveTarget == setting.liquidType.digestionRoom then 	--消解室阀诊断

            op:DrainFromDigestionRoom()

            local num = config.hardwareConfig.meterPoint.num
            local maxMP = config.hardwareConfig.meterPoint.point[num].setVolume
            local factor = dc:GetIPeristalticPump():GetPumpFactor(0)

            op:SetMeterOverValue(MeterMode.Smart, 0)
            op:Meter(MeterMode.Smart, setting.liquidType.blank, maxMP, RollDirection.Suck)
            op:Drain(setting.liquidType.digestionRoom, maxMP + setting.liquid.digestionRoomPipeVolume, setting.liquid.drainSpeed * factor)
            op:SetMeterOverValue(MeterMode.Smart, 0)
            op:Meter(MeterMode.Smart, setting.liquidType.blank, maxMP, RollDirection.Suck)
            op:Drain(setting.liquidType.digestionRoom, maxMP + setting.liquid.digestionRoomPipeVolume, setting.liquid.drainSpeed * factor)
            op:DrainFromDigestionRoom()
            status = true

        elseif self.valveTarget == setting.liquidType.waste then 	--废液阀诊断

            local num = config.hardwareConfig.meterPoint.num
            local maxMP = config.hardwareConfig.meterPoint.point[num].setVolume

            op:SetMeterOverValue(MeterMode.Smart, 0)
            op:Meter(MeterMode.Smart, setting.liquidType.blank, maxMP, RollDirection.Suck)
            op:DrainToWaste(0, WasteType.WasteReagent)
            op:SetMeterOverValue(MeterMode.Smart, 0)
            op:Meter(MeterMode.Smart, setting.liquidType.blank, maxMP, RollDirection.Suck)
            op:DrainToWaste(maxMP, WasteType.WasteReagent)

            status = true
        elseif self.valveTarget == setting.liquidType.wasteWater then    --废水阀诊断

            local num = config.hardwareConfig.meterPoint.num
            local maxMP = config.hardwareConfig.meterPoint.point[num].setVolume

            op:SetMeterOverValue(MeterMode.Smart, 0)
            op:Meter(MeterMode.Smart, setting.liquidType.blank, maxMP, RollDirection.Suck)
            op:DrainToWaste(0, WasteType.WasteWater)
            op:SetMeterOverValue(MeterMode.Smart, 0)
            op:Meter(MeterMode.Smart, setting.liquidType.blank, maxMP, RollDirection.Suck)
            op:DrainToWaste(0, WasteType.WasteWater)

            status = true
        else										--其他试剂阀诊断
            local MP0 = config.hardwareConfig.meterPoint.point[1].setVolume
            op:SetMeterOverValue(MeterMode.Smart, 0)
            op:Meter(MeterMode.Smart, self.valveTarget, MP0, RollDirection.Suck)
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
                log:warn("SmartValveDetectFlow:OnProcess() =>" .. result:What())
            end
        elseif type(result) == "table" then
            if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                self.isUserStop = true
            elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                self.isUserStop = true
            elseif getmetatable(result)== UserStopException then 				--用户停止测量流程
                self.isUserStop = true
            elseif getmetatable(result)== AcquirerADStoppedException then 	    --光学采集被停止异常
                self.isUserStop = true
            elseif getmetatable(result) == AcquirerADFailedException then 	    --光学采集中途出现故障，未能完成异常。
                ExceptionHandler.MakeAlarm(result)
            elseif getmetatable(result) == PumpFailedException then 			--泵操作中途出现故障，未能完成异常。
                ExceptionHandler.MakeAlarm(result)
            elseif getmetatable(result) == MeterFailedException then 			--定量中途出现故障，未能完成异常。
                ExceptionHandler.MakeAlarm(result)
            elseif getmetatable(result) == MeterUnfinishedException then 		--定量目标未达成异常。
                ExceptionHandler.MakeAlarm(result)
            elseif getmetatable(result) == MeterExpectTimeoutException then 	--定量超时异常。
                ExceptionHandler.MakeAlarm(result)
            else
                log:warn("SmartValveDetectFlow:OnProcess() =>" .. result:What())								--其他定义类型异常
            end
        elseif type(result) == "string" then
            log:warn("SmartValveDetectFlow:OnProcess() =>" .. result)	--C++、Lua系统异常
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

        if self.valveTarget == setting.liquidType.digestionRoom then 	--消解阀诊断
            op:DrainFromDigestionRoom()
        elseif self.valveTarget == setting.liquidType.waste then 	--废液阀诊断
            op:DrainToWaste(setting.liquid.meterPipeVolume)
        elseif self.valveTarget == setting.liquidType.wasteWater then    --废水阀诊断
            op:DrainToWasteWater(setting.liquid.meterPipeVolume)
        else										--其他试剂阀诊断
            op:DrainToWaste(setting.liquid.meterPipeVolume)
            op:SecludeLiquid(self.valveTarget)
        end
    end
end

function SmartValveDetectFlow:OnStop()

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()

    --保存试剂余量表
    ReagentRemainManager.SaveRemainStatus()


    log:info("智能阀诊断结束")
    log:debug("诊断时间 = "..os.time() - self.detectTime )
end
