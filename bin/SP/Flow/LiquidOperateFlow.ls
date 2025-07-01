LiquidOperateFlow = Flow:new
{
    source = setting.liquidType.none,
    dest = setting.liquidType.none,
    mode = 0,
    sVolume = 0,
    dVolume = 0,
    action = setting.runAction.suckFromBlank
}

function LiquidOperateFlow:new(o, source, dest, mode, sVol, dVol, action)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.source = source
    o.dest = dest
    o.mode = mode
    o.sVolume = sVol
    o.dVolume = dVol
    o.action = action

    return o
end

function LiquidOperateFlow:GetRuntime()
    return 0
end

function LiquidOperateFlow:OnStart()
    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()

    --检测消解室是否为安全温度
    op:CheckDigestSafety()

end

function LiquidOperateFlow:OnProcess()

    self.isUserStop = false
    self.isFinish = false

    self.dateTime = os.time()

    local runStatus = Helper.Status.SetStatus(setting.runStatus.liquidOperate)
    StatusManager.Instance():SetStatus(runStatus)

    local runAction = Helper.Status.SetAction(self.action)
    StatusManager.Instance():SetAction(runAction)

    local err,result = pcall
    (
        function()
            if self.source ~= setting.liquidType.none then
                if self.source == setting.liquidType.reagent1 then
                --    local factor = dc:GetIPeristalticPump():GetPumpFactor(0)
                --    dc:GetIOpticalMeter():SetMeteSpeed(setting.liquid.slowMeterSpeed * factor)
                --else
                    local factor = dc:GetIPeristalticPump():GetPumpFactor(0)
                    dc:GetIOpticalMeter():SetMeteSpeed(setting.liquid.meterSpeed * factor)
                end
                if self.mode == 0 then
                    op:Pump(self.source, self.sVolume, 0.4)
                elseif self.mode == 1 then
                    op:SetMeterOverValue(MeterMode.Smart, 0)
                    op:Meter(MeterMode.Smart, self.source, self.sVolume, RollDirection.Suck)
                elseif self.mode == 2 then
                    op:SetMeterOverValue(MeterMode.Accurate, setting.liquid.accurateMeterOverValue)
                    op:Meter(MeterMode.Accurate, self.source, self.sVolume, RollDirection.Suck)
                else
                    op:Pump(self.source, self.sVolume, 0.4)
                end
            end

            if self.dest  ~= setting.liquidType.none then
                --op:FillDosingPipe(setting.liquidType.blank, setting.unitVolume * 1)
                op:Drain(self.dest, self.dVolume, 0.4)
            end

            return true
        end
    )
    if not err then      -- 出现异常
        if type(result) == "table" then
            if getmetatable(result) == PumpStoppedException then 			--泵操作被停止异常。
                self.isUserStop = true
                error(result)
            elseif getmetatable(result)== MeterStoppedException then			--定量被停止异常。
                self.isUserStop = true
                error(result)
            else
                error(result)
            end
        else
            error(result)
        end
    end

    self.isFinish = true
end

function LiquidOperateFlow:OnStop()

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()
    
    --保存试剂余量表
    ReagentRemainManager.SaveRemainStatus()

    if not self.isFinish then
        if self.isUserStop then
            self.result = "用户终止"
            log:info("用户终止")
        else
            self.result = "故障终止"
            log:warn("故障终止")
        end
    else
        self.result = "管路操作结束"
        log:info("管路操作结束")
        local str = "管路操作流程总时间 = " .. tostring(os.time() - self.dateTime)
        log:debug(str)
    end
end
