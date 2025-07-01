CombineOperateFlow = Flow:new
{
    source = setting.liquidType.none,
    dest = setting.liquidType.none,
    mode = 0,
    sVolume = 0,
    dVolume = 0,
    action = setting.runAction.suckFromBlank
}

function CombineOperateFlow:new(o, source, dest, mode, sVol, dVol, action)
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

function CombineOperateFlow:GetRuntime()
    return 0
end

function CombineOperateFlow:OnStart()
    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()
    --检测消解室是否为安全温度
    --op:CheckDigestSafety()

end

function CombineOperateFlow:OnProcess()

    self.isUserStop = false
    self.isFinish = false

    self.dateTime = os.time()
    local flowManager = FlowManager.Instance()
    local runStatus = Helper.Status.SetStatus(setting.runStatus.combineOperate)
    StatusManager.Instance():SetStatus(runStatus)

    local runAction = Helper.Status.SetAction(self.action)
    StatusManager.Instance():SetAction(runAction)

    local err,result = pcall
    (
            function()
                if self.source ~= setting.liquidType.none then
                    local factor = dc:GetIPeristalticPump():GetPumpFactor(0)
                    dc:GetIOpticalMeter():SetMeteSpeed(setting.liquid.meterSpeed * factor)

                    if self.source == setting.liquidType.blank and self.dest == setting.liquidType.digestionRoom then
                        op:PumpToDigestionRoom(self.source, self.sVolume)
                    elseif self.source == setting.liquidType.digestionRoom and self.dest == setting.liquidType.waste then
                        op:DrainFromDigestionRoom(WasteType.WasteReagent)
                    elseif self.source == setting.liquidType.digestionRoom and self.dest == setting.liquidType.wasteWater then
                        op:DrainFromDigestionRoom(WasteType.WasteWater)
                    elseif self.source == setting.liquidType.gas and self.dest == setting.liquidType.none then
                        op:Pump(self.source, self.sVolume, 0.2)
                    elseif self.source == setting.liquidType.blank and self.dest == setting.liquidType.wasteWater then
                        -- 排空液体
                        op:DrainToWaste(setting.liquid.meterPipeVolume)
                        op:DrainFromDigestionRoom()
                        -- 加零点校准液至消解管
                        op:PumpToDigestionRoom(self.source, self.sVolume)
                        -- 加热
                        self:Heating(setting.temperature.oneKeyHeatingTemp)
                        -- 冷却
                        self:Cooling(setting.temperature.oneKeyHeatingCoolingTemp)
                        -- 排液
                        op:DrainFromDigestionRoom(self.dest)
                    elseif self.source == setting.liquidType.blank and self.dest == setting.liquidType.halogenBottleWater then

                        --打开氮气气路
                        op:TurnOnNirtrogen()

                        --local refrigeratorVol = math.floor(self.sVolume / setting.unitVolume)
                        --if refrigeratorVol < 1 then
                        --    refrigeratorVol = 1
                        --end
                        --refrigeratorVol = refrigeratorVol * setting.unitVolume
                        --log:debug("填充体积： " .. refrigeratorVol .." , 填充次数： " .. (refrigeratorVol/setting.unitVolume))
                        op:PumpToHalogenBottle(setting.liquidType.reagent1, 0.5)
                        op:PumpToHalogenBottle(setting.liquidType.blank, 8)

                        --关闭氮气气路
                        op:TurnOffNirtrogen(setting.pressure.delayTime)

                    elseif self.source == setting.liquidType.halogenBottleWater then

                        --打开氮气气路
                        op:TurnOnNirtrogen()

                        op:DrainFromHalogenBottle()

                        --关闭氮气气路
                        op:TurnOffNirtrogen(setting.pressure.delayTime)
                    elseif self.source == setting.liquidType.coolerWater then
                        op:DrainFromRefrigeratorWaterRoom()
                    elseif self.source == setting.liquidType.syringeBlank and self.dest == setting.liquidType.waste then
                        if config.measureParam.range[config.measureParam.currentRange + 1] + 1 == 1 then
                            setting.measureResult.startReactVolume = setting.measureResult.reactVolume[2] --更新反应体积
                            config.measureParam.addSampleCnt = 1
                            config.measureParam.carryingPressure = config.measureParam.preCarryingPressure
                        else
                            setting.measureResult.startReactVolume = setting.measureResult.reactVolume[1] --更新反应体积
                            config.measureParam.addSampleCnt = 2
                            config.measureParam.carryingPressure = config.measureParam.preCarryingPressure
                        end
                        ConfigLists.SaveMeasureParamConfig()
                        --op:SyringToWaste(self.sVolume)
                        op:SyringToStove(setting.measureResult.startReactVolume, config.measureParam.addSampleCnt)
                    elseif self.source == setting.liquidType.syringeBlank then
                        op:SyringUpdate(self.sVolume)
                    elseif self.source == setting.liquidType.waste then
                        op:SyringUpdateClean(self.sVolume)
                    else
                        log:warn("此模式不支持")
                        return false
                    end
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

function CombineOperateFlow:OnStop()

    if setting.sensor.isValid == true then
        op:SlidersSensorCheck()
    end

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()

    if self.source ~= setting.liquidType.syringeBlank then
        --关闭氮气气路
        op:TurnOffNirtrogen(setting.pressure.delayTime)
    end

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
        self.result = "组合操作结束"
        log:info("组合操作结束")
        local str = "组合操作流程总时间 = " .. tostring(os.time() - self.dateTime)
        log:debug(str)
    end
end


--[[
 * @brief 加热
 * @details 加热至目标温度
 * @param[in] targetTemp 目标温度,
--]]
function CombineOperateFlow:Heating(targetTemp)
    local startTime = os.time()

    local isHeating = false
    local thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
    log:debug("加热消解前温度 = " .. thermostatTemp .. " ℃");

    local temp = targetTemp - thermostatTemp
    if temp > 0.01  then
        isHeating = true

        local err,result = pcall(function()
            return op:StartThermostat(ThermostatMode.Auto,
                    targetTemp,
                    setting.temperature.toleranceTemp,
                    setting.temperature.oneKeyHeatingTempTimeout)
        end)
        if not err then -- 出现异常
            if type(result) == "table" then        --Lua异常
                if getmetatable(result) == ThermostatFailedException then
                    ExceptionHandler.MakeAlarm(result)
                elseif getmetatable(result) == ThermostatTimeoutException then
                    ExceptionHandler.MakeAlarm(result)
                else
                    error(result)
                end
            elseif type(result) == "userdata" then --C++异常
                if result:GetType() == "ExpectEventTimeoutException" then
                    ExceptionHandler.MakeAlarm(result)
                else
                    error(result)
                end
            else
                error(result)
            end
        else  -- 正常
            thermostatTemp = result
        end
    end
    log:debug("到达加热目标温度 = " .. thermostatTemp .. "℃")


    if isHeating == true then
        op:StopThermostat()  --停止恒温器
    end

    log:debug("加热时间 = " .. os.time() - startTime);
end

--[[
 * @brief 降温
 * @details 开风扇降温至目标温度
 * @param[in] targetTemp 目标温度,
--]]
function CombineOperateFlow:Cooling(targetTemp)
    local startTime = os.time()

    local thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
    log:debug("降温前温度 = ".. thermostatTemp .."℃")

    -- 冷却
    local difference = thermostatTemp - targetTemp
    if difference > 0.01 then
        local err,result =  pcall(function()
            return op:StartThermostat(ThermostatMode.Auto,
                    targetTemp,
                    setting.temperature.toleranceTemp,
                    setting.temperature.oneKeyHeatingCoolingTempTimeout)
        end)
        if not err then -- 出现异常
            if type(result) == "table" then        --Lua异常
                if getmetatable(result) == ThermostatFailedException then
                    ExceptionHandler.MakeAlarm(result)
                elseif getmetatable(result) == ThermostatTimeoutException then
                    ExceptionHandler.MakeAlarm(result)
                else
                    error(result)
                end
            elseif type(result) == "userdata" then --C++异常
                if result:GetType() == "ExpectEventTimeoutException" then
                    ExceptionHandler.MakeAlarm(result)
                else
                    error(result)
                end
            else
                error(result)
            end
        else -- 正常
            thermostatTemp = result
        end
    end
    log:debug("到达冷却目标温度 = ".. thermostatTemp .."℃")

    log:debug("消解冷却时间 = " .. os.time() - startTime);
end