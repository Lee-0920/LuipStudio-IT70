--[[
 * @brief 清洗类型
--]]
cleanType =
{
    cleanMeterPipe = 0,     	--清洗定量管
    cleanDigestionRoom = 1,     --清洗消解室
    cleanDeeply = 2,     --深度清洗
    cleanAll = 3,       	--清洗所有管路
    oneKeyRenew = 4,      --一键填充试剂
    multiValveAutoClean = 5,  --多联阀自动清洗
    suckHalogenBottleWater = 6,      --排卤素液
    oneKeyFillHalogenBottleWater = 7,  --一键填充卤素液
    catalystActive = 8,  --新催化剂活化
    airReplacement = 9,      --气体置换
}

--[[
 * @brief 清洗流程。
--]]
CleanFlow = Flow:new
{
}

function CleanFlow:new(o, target)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.cleanDateTime = os.time()
    o.cleanType = target
    o.reactTemperature = config.measureParam.reactTemperature
    o.carryingPressure = config.measureParam.carryingPressure

    return o
end

function CleanFlow:GetRuntime()
    local runtime = 0

    if self.cleanType == cleanType.cleanMeterPipe then
        runtime = setting.runStatus.cleanMeterPipe.GetTime()
    elseif self.cleanType == cleanType.cleanDigestionRoom then
        runtime = setting.runStatus.cleanDigestionRoom.GetTime()
    elseif self.cleanType == cleanType.cleanDeeply then
        runtime = setting.runStatus.cleanDeeply.GetTime()
    elseif self.cleanType == cleanType.cleanAll then
        runtime = setting.runStatus.cleanAll.GetTime()
    elseif self.cleanType == cleanType.oneKeyRenew then
        runtime = setting.runStatus.oneKeyRenew.GetTime()
    elseif self.cleanType == cleanType.multiValveAutoClean then
        runtime = setting.runStatus.multiValveAutoClean.GetTime()
    elseif self.cleanType == cleanType.suckHalogenBottleWater then
        runtime = setting.runStatus.suckHalogenBottleWater.GetTime()
    elseif self.cleanType == cleanType.oneKeyFillHalogenBottleWater then
        runtime = setting.runStatus.oneKeyFillHalogenBottleWater.GetTime()
    elseif self.cleanType == cleanType.catalystActive then
        runtime = setting.runStatus.catalystActive.GetTime()
    elseif self.cleanType == cleanType.airReplacement then
        runtime = setting.runStatus.airReplacement.GetTime()
    end

    return runtime
end

function CleanFlow:OnStart()
    --组合流程需要重新加载时间
    self.measureDateTime = os.time()
    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()

    --检测消解室是否为安全温度
    op:CheckDigestSafety()

    --继电器指示
    Helper.Result.RelayOutOperate(setting.mode.relayOut.cleanInstruct, true)

    --设置运行状态
    local runStatus = Helper.Status.SetStatus(setting.runStatus.cleanDeeply)
    if self.cleanType == cleanType.cleanMeterPipe then
        runStatus = Helper.Status.SetStatus(setting.runStatus.cleanMeterPipe)
    elseif self.cleanType == cleanType.cleanDigestionRoom then
        runStatus = Helper.Status.SetStatus(setting.runStatus.cleanDigestionRoom)
    elseif self.cleanType == cleanType.cleanDeeply then
        runStatus = Helper.Status.SetStatus(setting.runStatus.cleanDeeply)
    elseif self.cleanType == cleanType.cleanAll then
        runStatus = Helper.Status.SetStatus(setting.runStatus.cleanAll)
    elseif self.cleanType == cleanType.oneKeyRenew then
        runStatus = Helper.Status.SetStatus(setting.runStatus.oneKeyRenew)
    elseif self.cleanType == cleanType.multiValveAutoClean then
        runStatus = Helper.Status.SetStatus(setting.runStatus.multiValveAutoClean)
    elseif self.cleanType == cleanType.suckHalogenBottleWater then
        runStatus = Helper.Status.SetStatus(setting.runStatus.suckHalogenBottleWater)
    elseif self.cleanType == cleanType.oneKeyFillHalogenBottleWater then
        runStatus = Helper.Status.SetStatus(setting.runStatus.oneKeyFillHalogenBottleWater)
    elseif self.cleanType == cleanType.catalystActive then
        runStatus = Helper.Status.SetStatus(setting.runStatus.catalystActive)
    elseif self.cleanType == cleanType.airReplacement then
        runStatus = Helper.Status.SetStatus(setting.runStatus.airReplacement)
    end
    StatusManager.Instance():SetStatus(runStatus)
end

function CleanFlow:OnProcess()
    self.isUserStop = false
    self.isFinish = false

    --清洗流程执行
    local err,result = pcall
    (
        function()
            if self.cleanType == cleanType.cleanMeterPipe then
                return self:CleanMeterPipe()
            elseif self.cleanType == cleanType.cleanDigestionRoom then
                return self:CleanDigestionRoom()
            elseif self.cleanType == cleanType.cleanDeeply then
                return self:CleanDeeply()
            elseif self.cleanType == cleanType.cleanAll then
                return self:CleanAll()
            elseif self.cleanType == cleanType.oneKeyRenew then
                return self:OneKeyRenew()
            elseif self.cleanType == cleanType.multiValveAutoClean then
                return self:MultiValveAutoClean()
            elseif self.cleanType == cleanType.suckHalogenBottleWater then
                return self:SuckHalogenBottleWater()
            elseif self.cleanType == cleanType.oneKeyFillHalogenBottleWater then
                return self:OneKeyFillHalogenBottleWater()
            elseif self.cleanType == cleanType.catalystActive then
                return self:CatalystActive()
            elseif self.cleanType == cleanType.airReplacement then
                return self:AirReplacement()
            end
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

    self.isFinish = true
end

function CleanFlow:OnStop()

    --继电器指示
    Helper.Result.RelayOutOperate(setting.mode.relayOut.cleanInstruct, false)

    if self.cleanType == cleanType.cleanDeeply then
        status.measure.schedule.autoClean.dateTime = self.cleanDateTime

        ConfigLists.SaveMeasureStatus()
    elseif self.cleanType == cleanType.suckHalogenBottleWater then
        status.measure.schedule.autoSuckHalogenBottleWater.dateTime = self.cleanDateTime

        ConfigLists.SaveMeasureStatus()
    elseif self.cleanType == cleanType.catalystActive then
        setting.temperature.isOpenTempMonitor = true
        config.measureParam.reactTemperature = self.reactTemperature
        config.measureParam.carryingPressure = self.carryingPressure
        setting.temperature.monitor.stoveLastTemperature = -1
        setting.temperature.monitor.stoveAbnormalTemperature = -1
        ConfigLists.SaveMeasureParamConfig()

        status.measure.schedule.autoCatalystActive.dateTime = self.cleanDateTime
        ConfigLists.SaveMeasureStatus()
        log:debug("更新测量参数 反应温度 " .. config.measureParam.reactTemperature .. "℃".. ", 载气压力 " .. config.measureParam.carryingPressure .. "kPa")
        --重置温控检测周期
        setting.temperature.monitor.time = 0
        setting.temperature.tempMonitorControlPeriod = 5
        self:Cooling(self)
    elseif self.cleanType == cleanType.airReplacement then
        status.measure.schedule.autoAirReplacement.dateTime = self.cleanDateTime

        ConfigLists.SaveMeasureStatus()
    end

    if setting.sensor.isValid == true then
        op:SlidersSensorCheck()
    end

    -- 初始化下位机
    dc:GetIDeviceStatus():Initialize()
    --关闭氮气气路
    op:TurnOffNirtrogen(setting.pressure.delayTime)
    --关LED
    dc:GetIOpticalAcquire():TurnOffLED()

    if not self.isFinish then
        if self.isUserStop then
            self.result = "用户终止"
            log:info("用户终止")
        else
            self.result = "故障终止"
            log:warn("故障终止")
        end
    else
        if self.cleanType == cleanType.suckHalogenBottleWater then
            self.result = "排卤素液完成"
            log:info("排卤素液完成")
            log:info("排卤素液流程总时间 = "..os.time()-self.cleanDateTime)
        elseif self.cleanType == cleanType.catalystActive then
            self.result = "催化剂活化完成"
            log:info("催化剂活化完成")
            log:info("催化剂活化流程总时间 = "..os.time()-self.cleanDateTime)
        elseif self.cleanType == cleanType.airReplacement then
            self.result = "气体置换完成"
            log:info("气体置换完成")
            log:info("气体置换流程总时间 = "..os.time()-self.cleanDateTime)
        else
            self.result = "清洗完成"
            log:info("清洗完成")
            log:info("清洗流程总时间 = "..os.time()-self.cleanDateTime)
        end
    end

    --保存试剂余量表
    ReagentRemainManager.SaveRemainStatus()

    --检测消解室是否为安全温度
    op:CheckDigestSafety()

end

--[[
 * @brief 深度清洗流程
--]]
function CleanFlow:CleanDeeply(flow)
    if nil ~= flow then
        self = flow
    end
    local runAction = Helper.Status.SetAction(setting.runAction.cleanDeeply)
    StatusManager.Instance():SetAction(runAction)

    local thermostatTemp = 0
    local mp0 = config.hardwareConfig.meterPoint.point[1].setVolume
    local mp1 = config.hardwareConfig.meterPoint.point[2].setVolume
    local wasteType = WasteType.WasteWater
    -- 从定量管排液到废液桶
    op:DrainToWaste(setting.liquid.meterPipeVolume)

    -- 排消解器溶液到废液桶
    op:DrainFromDigestionRoom()

    -- 加酸
    op:PumpToDigestionRoom(setting.liquidType.reagent1, mp1*5)
    op:DrainToWaste(0)
    op:SecludeLiquid(setting.liquidType.reagent1)

    local cleanTime = 3
    local restCnt = 0
    --for i = 1, cleanTime do
        op:ExposureTurnOn()

        if not self:Wait(60) then 	-- 采集等待
            error(UserStopException:new())    --用户停止
        end

        op:ExposureTurnOff()

        --if restCnt > cleanTime then
        --    break
        --end

        --if not self:Wait(60) then 	-- 采集等待
        --    error(UserStopException:new())    --用户停止
        --end

        -- 排消解器溶液到废水桶
        op:DrainFromDigestionRoom()

        --restCnt = restCnt + 1
    --end

    op:PumpToDigestionRoom(setting.liquidType.blank, mp1*1)
    op:DrainToWaste(0)
    op:SecludeLiquid(setting.liquidType.blank)

    op:DrainFromDigestionRoom(WasteType.WasteReagent)

    self.isFinish = true

    return true
end

--[[
 * @brief 清洗消解室流程
--]]
function CleanFlow:CleanDigestionRoom()
    local runAction = Helper.Status.SetAction(setting.runAction.cleanDigestionRoom)
    StatusManager.Instance():SetAction(runAction)

    --清洗逐出室
    op:CleanDigestionRoom(setting.liquidType.blank, setting.clean.cleanVolume*4)
    self.isFinish = true
    return true
end

--[[
 * @brief 清洗定量管流程
--]]
function CleanFlow:CleanMeterPipe()
    local runAction = Helper.Status.SetAction(setting.runAction.cleanMeterPipe)
    StatusManager.Instance():SetAction(runAction)

    local pointNum = config.hardwareConfig.meterPoint.num
    local maxVol = config.hardwareConfig.meterPoint.point[pointNum].setVolume

    op:DrainToWaste(setting.liquid.meterPipeVolume)
    op:CleanMeterPipe(setting.liquidType.blank, maxVol)

    self.isFinish = true

    return true
end

--[[
 * @brief 清洗所有管路
--]]
function CleanFlow:CleanAll()
    local runAction
    -- 清洗消解室(包含排空定量管和消解室)
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.cleanDigestionRoom)
    StatusManager.Instance():SetAction(runAction)
    op:CleanDigestionRoom(setting.liquidType.blank, setting.clean.cleanVolume)

    -- 排空水样管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.drainSamplePipe)
    StatusManager.Instance():SetAction(runAction)
    op:Drain(setting.liquidType.sample, setting.liquid.samplePipeVolume + config.measureParam.extendSamplePipeVolume, 0)

    -- 排空量程校准液管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.drainStandardPipe)
    StatusManager.Instance():SetAction(runAction)
    op:Drain(setting.liquidType.standard, setting.liquid.standardPipeVolume, 0)

    --开启扩展功能
    --if config.system.targetMap.EXTEND.enable == true then
         --排空零点核查液管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.drainZeroCheckPipe)
    StatusManager.Instance():SetAction(runAction)
    op:Drain(setting.liquidType.zeroCheck, setting.liquid.zeroCheckPipeVolume, 0)

     --排空量程核查液管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.drainRangeCheckPipe)
    StatusManager.Instance():SetAction(runAction)
    op:Drain(setting.liquidType.rangeCheck, setting.liquid.rangeCheckPipeVolume, 0)
    --end

    -- 排空试剂一管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.drainReagent1Pipe)
    StatusManager.Instance():SetAction(runAction)
    op:Drain(setting.liquidType.reagent1, setting.liquid.reagent1PipeVolume, 0)

    -- 清洗水样管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.cleanSamplePipe)
    StatusManager.Instance():SetAction(runAction)
    op:CleanReagentPipe(setting.liquidType.blank, setting.liquidType.sample, setting.unitVolume)
    op:Drain(setting.liquidType.sample, setting.liquid.samplePipeVolume + config.measureParam.extendSamplePipeVolume, 0)

    -- 清洗量程校准液管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.cleanStandardPipe)
    StatusManager.Instance():SetAction(runAction)
    op:CleanReagentPipe(setting.liquidType.blank, setting.liquidType.standard, setting.unitVolume)
    op:Drain(setting.liquidType.standard, setting.liquid.standardPipeVolume, 0)

    ----开启扩展功能
    --if config.system.targetMap.EXTEND.enable == true then
    -- 清洗零点核查液管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.cleanZeroCheckPipe)
    StatusManager.Instance():SetAction(runAction)
    op:CleanReagentPipe(setting.liquidType.blank, setting.liquidType.zeroCheck,  setting.unitVolume)
    op:Drain(setting.liquidType.zeroCheck, setting.liquid.zeroCheckPipeVolume, 0)

    -- 清洗量程核查液管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.cleanRangeCheckPipe)
    StatusManager.Instance():SetAction(runAction)
    op:CleanReagentPipe(setting.liquidType.blank, setting.liquidType.rangeCheck,  setting.unitVolume)
    op:Drain(setting.liquidType.rangeCheck, setting.liquid.rangeCheckPipeVolume, 0)
    --end

    -- 清洗试剂一管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.cleanReagent1Pipe)
    StatusManager.Instance():SetAction(runAction)
    op:CleanReagentPipe(setting.liquidType.blank, setting.liquidType.reagent1, setting.unitVolume)
    op:Drain(setting.liquidType.reagent1, setting.liquid.reagent1PipeVolume, 0)

    -- 排空零点校准液管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.drainBlankPipe)
    StatusManager.Instance():SetAction(runAction)
    op:Drain(setting.liquidType.blank, setting.liquid.blankPipeVolume, 0)

    -- 排空废液管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.drainWastePipe)
    StatusManager.Instance():SetAction(runAction)
    op:DrainToWaste(0)

    -- 排空废水管
    runAction = Helper.Status.SetAction(setting.runAction.cleanAll.drainWastePipe)
    StatusManager.Instance():SetAction(runAction)
    op:DrainToWaste(0)


    self.isFinish = true

    return true
end

--[[
 * @brief 一键管路更新
--]]
function CleanFlow:OneKeyRenew()

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
	
	-- 清空零点校准液管
	runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearBlankPipe)
	StatusManager.Instance():SetAction(runAction)
	op:ClearReagentPipe(setting.liquidType.blank, setting.liquid.pipeRenewVolume)

    -- 清空量程核查管
    runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearRangeCheckPipe)
    StatusManager.Instance():SetAction(runAction)
    op:ClearReagentPipe(setting.liquidType.rangeCheck, setting.liquid.pipeRenewVolume)

    -- 清空零点核查管
    runAction = Helper.Status.SetAction(setting.runAction.oneKeyMaintain.clearZeroCheckPipe)
    StatusManager.Instance():SetAction(runAction)
    op:ClearReagentPipe(setting.liquidType.zeroCheck, setting.liquid.pipeRenewVolume)


end

--[[
 * @brief 多联阀自动清洗
--]]
function CleanFlow:MultiValveAutoClean()

    local cleanMeterPipevolume = config.hardwareConfig.meterPoint.point[1].setVolume
    local factor = dc:GetIPeristalticPump():GetPumpFactor(0)
    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 定量零点校准液，加压反冲水样管
    op:SetMeterOverValue(MeterMode.Smart, 0)
    for i = 1, 3 do
        op:Meter(MeterMode.Smart, setting.liquidType.blank, cleanMeterPipevolume, RollDirection.Suck)
        op:DrainNotCloseValve(setting.liquidType.sample, 1, drainSpeed)
        op:Drain(setting.liquidType.sample, 5, drainSpeed)
    end

    -- 定量零点校准液，加压反冲废液管
    op:SetMeterOverValue(MeterMode.Smart, 0)
    for i = 1, 3 do
        op:Meter(MeterMode.Smart, setting.liquidType.blank, cleanMeterPipevolume, RollDirection.Suck)
        op:DrainToWasteNotCloseValve(1)
        op:DrainToWaste(5)
    end

    -- 定量零点校准液，加压反冲废水管
    op:SetMeterOverValue(MeterMode.Smart, 0)
    for i = 1, 3 do
        op:Meter(MeterMode.Smart, setting.liquidType.blank, cleanMeterPipevolume, RollDirection.Suck)
        op:DrainToWasteNotCloseValve( 1)
        op:DrainToWaste(5)
    end

end

--[[
 * @brief 排卤素液
--]]
function CleanFlow:SuckHalogenBottleWater()
    --打开氮气气路
    op:TurnOnNirtrogen()

    if not self:Wait(5) then
        error(UserStopException:new())
    end

    op:DrainFromHalogenBottle()

    op:PumpToHalogenBottle(setting.liquidType.blank, 2)
    op:SecludeLiquid(setting.liquidType.blank)

    op:DrainFromHalogenBottle()

    local factor = dc:GetIPeristalticPump():GetPumpFactor(0)
    dc:GetIOpticalMeter():SetMeteSpeed(setting.liquid.meterSpeed * factor)
    op:Pump(setting.liquidType.seeper,  setting.liquid.meterCleanVolume, 0)

    op:DrainToWaste(setting.liquid.meterCleanVolume, WasteType.WasteWater)

    op:DrainFromRefrigeratorWaterRoom()


end

--[[
 * @brief 一键填充卤素液
--]]
function CleanFlow:OneKeyFillHalogenBottleWater()
    --local refrigeratorVol = math.floor(220 / setting.unitVolume)
    local refrigeratorVol = setting.unitVolume
    refrigeratorVol = refrigeratorVol * setting.unitVolume
    log:debug("填充体积： " .. refrigeratorVol .." , 填充次数： " .. (refrigeratorVol/setting.unitVolume))
    op:PumpToHalogenBottle(setting.liquidType.blank, refrigeratorVol)
end

--[[
 * @brief 新催化剂活化
--]]
function CleanFlow:CatalystActive(flow)

    if nil ~= flow then
        self = flow
    end

    config.measureParam.reactTemperature = config.measureParam.catalystActiveTemperature
    config.measureParam.catalystActivePressure = config.measureParam.carryingPressure * 1.5
    if config.measureParam.catalystActivePressure < 100 then
        config.measureParam.carryingPressure = config.measureParam.catalystActivePressure
    end

    ConfigLists.SaveMeasureParamConfig()

    --重置温控检测周期
    setting.temperature.monitor.time = 0
    setting.temperature.tempMonitorControlPeriod = 2.5

    op:ReviseThermostatTemp(setting.temperature.indexStove,
            ThermostatMode.Heater,
            config.measureParam.reactTemperature,
            setting.temperature.toleranceTemp,
            setting.temperature.digestTempTimeout)
    log:info("催化剂活化温度： " .. config.measureParam.reactTemperature ..
            "--容差： " .. setting.temperature.toleranceTemp ..
            "--超时: " .. setting.temperature.digestTempTimeout)

    --重设LED测量周期
    op:ResetLEDMeasurePeriod()

    --打开氮气气路
    op:TurnOnNirtrogen()
    --开LED
    dc:GetIOpticalAcquire():TurnOnLED()

    if not self:Wait(30) then
        error(UserStopException:new())
    end

    --检测是否达到反应温度
    op:IsReactTemperature(self)

    local runAction = Helper.Status.SetAction(setting.runAction.catalystActive.drainMeterPipe)
    StatusManager.Instance():SetAction(runAction)
    op:DrainToWaste(0)

    runAction = Helper.Status.SetAction(setting.runAction.catalystActive.updateDosingPipe)
    StatusManager.Instance():SetAction(runAction)
    op:SyringUpdate(config.measureParam.syringeUpdateCnt)

    --op:CleanDosingPipe(setting.liquidType.blank, setting.unitVolume * 1)
    op:FillDosingPipe(setting.liquidType.reagent1, setting.unitVolume * 2)

    local addBlankPeriod = 1*60
    local addBlankTimes = math.floor(config.measureParam.catalystActiveTime / addBlankPeriod)
    local maxAddBlankTimes = 15

    for i = 1, addBlankTimes do
        --滑块进样
        runAction = Helper.Status.SetAction(setting.runAction.catalystActive.slidersIn)
        StatusManager.Instance():SetAction(runAction)
        op:SlidersMovingWithSensor()

        op:SyringToStove(setting.liquid.syringeRelifeVolume)

        --滑块复位
        runAction = Helper.Status.SetAction(setting.runAction.catalystActive.slidersOut)
        StatusManager.Instance():SetAction(runAction)
        op:SlidersMovingWithSensor()

        runAction = Helper.Status.SetAction(setting.runAction.catalystActive.silentTime)
        StatusManager.Instance():SetAction(runAction)
        if not self:Wait(addBlankPeriod) then
            error(UserStopException:new())
        end
        --重新更新注射器 加样管路
        if i >= maxAddBlankTimes and math.floor(i%maxAddBlankTimes) == 0 then
            runAction = Helper.Status.SetAction(setting.runAction.catalystActive.updateDosingPipe)
            StatusManager.Instance():SetAction(runAction)
            op:SyringUpdate(config.measureParam.syringeUpdateCnt)

            op:FillDosingPipe(setting.liquidType.reagent1, setting.unitVolume * 2)
        end
    end

    local runAction = Helper.Status.SetAction(setting.runAction.digestCooling)
    StatusManager.Instance():SetAction(runAction)

    setting.temperature.isOpenTempMonitor = false
    op:StopThermostat()

    local thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
    log:debug("降温前温度 = ".. thermostatTemp .."℃")

    local timeout = 600
    while true do
        thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
        if math.abs(thermostatTemp - self.reactTemperature) < 10 then
            break
        elseif timeout < 0 then
            break
        end
        if not self:Wait(5) then
            error(UserStopException:new())    --用户停止
        end
        timeout = timeout - 5
    end

    config.measureParam.reactTemperature = self.reactTemperature
    config.measureParam.carryingPressure = self.carryingPressure

    ConfigLists.SaveMeasureParamConfig()

    local flowManager = FlowManager.Instance()
    if flowManager:IsComValid() == true then
        op:ReviseThermostatTemp(setting.temperature.indexStove, ThermostatMode.Heater, config.measureParam.reactTemperature, setting.temperature.toleranceTemp, setting.temperature.digestTempTimeout)
        log:info("重设恒温器温度： " .. config.measureParam.reactTemperature .. "--容差： " .. setting.temperature.toleranceTemp .. "--超时: " .. setting.temperature.digestTempTimeout)
    end

end

--[[
 * @brief 检查消解室温度安全
 * @details 当消解室温度高于安全温度时，启动降温操作.
--]]
function CleanFlow:Cooling(flow)
    if nil ~= flow then
        self = flow
    end

    local safeTemp = config.measureParam.reactTemperature
    local startTime = os.time()

    local  thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()

    local temp = thermostatTemp - safeTemp - 10

    if  temp >  0.01 then
        op:debugPrintf("安全冷却前燃烧炉温度 = " .. thermostatTemp .. " ℃");
        --状态设置
        local runStatus = Helper.Status.SetStatus(setting.runStatus.digestCooling)
        StatusManager.Instance():SetStatus(runStatus)

        --动作设置
        local runAction = Helper.Status.SetAction(setting.runAction.digestCooling)
        StatusManager.Instance():SetAction(runAction)

        --关闭温度监控
        setting.temperature.isOpenTempMonitor = false

        --冷却
        local cnt = 60
        while true do
            --获取恒温器状态
            if dc:GetITemperatureControl():GetThermostatStatus() == 2 then
                op:StopThermostat()
            end

            thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
            if  thermostatTemp <  safeTemp  + 10 then
                break
            elseif cnt < 0 then
                op:debugPrintf("燃烧炉冷却超时")
                break
            end
            App.Sleep(5000)
            cnt = cnt - 1
        end

        op:debugPrintf("到达安全冷却目标温度 = ".. thermostatTemp .. " ℃" )
        op:debugPrintf("燃烧炉冷却总时间 = " .. os.time() - startTime)
        --打开温度监控
        setting.temperature.isOpenTempMonitor = true
        --重置温控检测周期
        setting.temperature.monitor.time = 0
        setting.temperature.tempMonitorControlPeriod = 5
        op:ReviseThermostatTemp(setting.temperature.indexStove, ThermostatMode.Heater, config.measureParam.reactTemperature, setting.temperature.toleranceTemp, setting.temperature.digestTempTimeout)
        log:info("重设恒温器温度： " .. config.measureParam.reactTemperature .. "--容差： " .. setting.temperature.toleranceTemp .. "--超时: " .. setting.temperature.digestTempTimeout)
        --重设LED测量周期
        op:ResetLEDMeasurePeriod()
    end
    StatusManager.Instance():SetTemperature(config.measureParam.reactTemperature)
end

--[[
 * @brief 气体置换
--]]
function CleanFlow:AirReplacement()

    --开LED
    dc:GetIOpticalAcquire():TurnOnLED()

    --打开曝气
    op:ExposureTurnOn(20)

    if not self:Wait(20) then
        error(UserStopException:new())
    end

    --使能总阀曝气阀常开
    local map = ValveMap.new(setting.liquidType.airLED.valve | setting.liquidType.master.valve)
    dc:GetISolenoidValve():SetValveMap(map)

    if not self:Wait(60) then
        error(UserStopException:new())
    end

    --关闭曝气
    op:ExposureTurnOff()

    op:SyringUpdateClean(1)

end