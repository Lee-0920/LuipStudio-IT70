AutoPumpCheckFlow = Flow:new()

function AutoPumpCheckFlow:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.SPEED = 0.2
    return o
end

function AutoPumpCheckFlow:GetRuntime()
	return 0
end

function AutoPumpCheckFlow:OnStart()
	-- 初始化下位机

	dc:GetIDeviceStatus():Initialize()

	--检测消解室是否为安全温度
	op:CheckDigestSafety()

    local runStatus = Helper.Status.SetStatus(setting.runStatus.autoPumpCheck)
    StatusManager.Instance():SetStatus(runStatus)

    local runAction = Helper.Status.SetAction(setting.runAction.autoPumpCheck)
    StatusManager.Instance():SetAction(runAction)
end

function AutoPumpCheckFlow:OnProcess()

    self.isUserStop = false
    self.isFinish = false
    self.dateTime = os.time()

	local err,result = pcall
    (
        function()

            local source = setting.liquidType.blank
            local IOpticalMeter = dc:GetIOpticalMeter()
            --重新设置速度
            local factor = IOpticalMeter:GetPumpFactor()
            IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
            log:debug("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))

            --排走定量管液体
            op:DrainToWaste(setting.liquid.meterPipeVolume)

            --精确定量定量最小定量点的液体。
            self:MeterToMinMeterPoint(source)

            IOpticalMeter:SetMeteSpeed(30 * factor)
            log:debug("Set Meter Speed " .. (30 * factor))

            --直接定量定量最大定量点的液体。
            self:MeterToMaxMeterPoint(source)

            IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
            log:debug("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))

            local meterPoinNum = config.hardwareConfig.meterPoint.num
            local step = dc:GetIPeristalticPump():GetPumpVolume(0) / factor
            local setFactor = (config.hardwareConfig.meterPoint.point[meterPoinNum].realVolume - config.hardwareConfig.meterPoint.point[1].setVolume) / step

            op:DrainToWaste(setting.liquid.meterPipeVolume)

            config.hardwareConfig.backupParam.pumpMeter = setFactor
            ConfigLists.SaveHardwareConfig()

            IOpticalMeter:SetPumpFactor(setFactor)
            self.result = string.format("%.8f", IOpticalMeter:GetPumpFactor())
	    
            local configVector = ConfigVector.new()
            local configValue = Config.new()
            configValue:__set_profile(setting.ui.profile.hardwareParamIterms.name)
            configValue:__set_config(setting.ui.profile.hardwareParamIterms[1][1].name)
            configValue:__set_value(self.result)
            configVector:Push(configValue)
            WqimcManager.Instance():updateConfigs(configVector)
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

function AutoPumpCheckFlow:OnStop()

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
		self.result = "泵校准结束"
        log:info("泵校准结束")
        local str = "泵校准流程总时间 = " .. tostring(os.time() - self.dateTime)
        log:debug(str)
        UpdateWidgetManager.Instance():Update(UpdateEvent.AutoPumpCheck, "AutoPumpCheckFlow")
	end

end

function AutoPumpCheckFlow:MeterToMinMeterPoint(source)

    local minMeterPointVolume = config.hardwareConfig.meterPoint.point[1].setVolume
    local meterPoinNum = config.hardwareConfig.meterPoint.num
    local maxMeterPointVolume = config.hardwareConfig.meterPoint.point[meterPoinNum].setVolume

	local meterFailedReTry = setting.liquid.meterFailedReTry	-- 定量失败重试次数
	local meterOverflowReTry = setting.liquid.meterOverflowReTry	--定量溢出重试次数
	local meterUnfinishedReTry = setting.liquid.meterUnfinishedReTry	-- 定量未达成目标重试次数
	local meterAirBubbleReTry = setting.liquid.meterAirBubbleReTry	-- 定量有气泡重试次数
	local meterTimeoutReTry = setting.liquid.meterTimeoutReTry	-- 定量超时重试次数

	local failedCnt = 0
	local overflowCnt = 0
	local unfinishedCnt = 0
	local airBubbleCnt = 0
	local timeoutCnt = 0

    --废液类型
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end

    while true do
        local err,result = pcall
        (
            function()
                op:SetMeterOverValue(MeterMode.Accurate, setting.liquid.accurateMeterOverValue)
                op:Meter(MeterMode.Accurate, source, minMeterPointVolume, RollDirection.Suck)
                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end
        )

        if not err then      -- 出现异常
            if type(result) == "userdata" then

                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    timeoutCnt = timeoutCnt + 1
                    log:warn(result:What())

                    if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                        op:Drain(source, minMeterPointVolume * 0.5, self.SPEED)

                    elseif timeoutCnt >= meterTimeoutReTry then
                        op:DrainToWaste(minMeterPointVolume, wasteType)
                        error (MeterExpectTimeoutException:new{liquidType = source,})
                    end
                else
                    error(result)
                end

            elseif type(result) == "table" then

                if getmetatable(result) == MeterFailedException then
                    failedCnt = failedCnt +1
                    log:warn(result:What())

                    if (failedCnt > 0) and (failedCnt < meterFailedReTry) then

                        op:DrainToWaste(minMeterPointVolume, wasteType)
                        op:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, self.SPEED)
                        op:DrainToWaste(setting.liquid.meterCleanVolume, wasteType)

                    elseif failedCnt >= meterFailedReTry then
                        op:DrainToWaste(minMeterPointVolume, wasteType)
                        error (MeterFailedException:new{liquidType = source,})
                    end

                elseif getmetatable(result) == MeterOverflowException then
                    overflowCnt = overflowCnt +1
                    log:warn(result:What())

                    if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then

                        op:DrainToWaste(minMeterPointVolume, wasteType)

                    elseif overflowCnt >= meterOverflowReTry then

                        op:DrainToWaste(minMeterPointVolume, wasteType)
                        error (MeterOverflowException:new{liquidType = source,})
                    end

                elseif getmetatable(result)== MeterUnfinishedException then
                    unfinishedCnt = unfinishedCnt +1
                    log:warn(result:What())

                    if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then

                        op:Drain(source, minMeterPointVolume*0.5, self.SPEED)

                    elseif unfinishedCnt >= meterUnfinishedReTry then

                        op:DrainToWaste(minMeterPointVolume, wasteType)
                        error (MeterUnfinishedException:new{liquidType = source,})

                    end

                elseif getmetatable(result) == MeterAirBubbleException then
                    airBubbleCnt = airBubbleCnt +1
                    log:warn(result:What())

                    if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then

                        op:Drain(source, minMeterPointVolume*0.5, self.SPEED)

                    elseif airBubbleCnt >= meterAirBubbleReTry then

                        op:DrainToWaste(minMeterPointVolume, wasteType)
                        local e = MeterAirBubbleException:new{liquidType = source,}
                        log:warn(e:What())
                        ExceptionHandler.MakeAlarm(e)
                        break
                    end
                else
                    error(result)
                end
            else
                error(result)
            end
        else
            break
        end
    end

end

function AutoPumpCheckFlow:MeterToMaxMeterPoint(source)

    local meterPoinNum = config.hardwareConfig.meterPoint.num
    local maxMeterPointVolume = config.hardwareConfig.meterPoint.point[meterPoinNum].setVolume

    --废液类型
    local wasteType = WasteType.WasteReagent
    if source == setting.liquidType.blank then
        wasteType = WasteType.WasteReagent
    end

    local err,result = pcall
    (
        function()
            op:SetMeterOverValue(MeterMode.Direct, 0)
            op:Meter(MeterMode.Direct, source, maxMeterPointVolume, RollDirection.Suck)
        end
    )
    if not err then      -- 出现异常
        if type(result) == "userdata" then

            if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                op:DrainToWaste(maxMeterPointVolume, wasteType)
                error (MeterExpectTimeoutException:new{liquidType = source,})
            else
                error(result)
            end

        elseif type(result) == "table" then

            if getmetatable(result) == MeterFailedException then
                op:DrainToWaste(maxMeterPointVolume, wasteType)
                error (MeterExpectTimeoutException:new{liquidType = source,})

            elseif getmetatable(result) == MeterOverflowException then

                op:DrainToWaste(maxMeterPointVolume, wasteType)
                error (MeterOverflowException:new{liquidType = source,})


            elseif getmetatable(result)== MeterUnfinishedException then

                op:DrainToWaste(maxMeterPointVolume, wasteType)
                error (MeterUnfinishedException:new{liquidType = source,})

            elseif getmetatable(result) == MeterAirBubbleException then

                op:DrainToWaste(maxMeterPointVolume, wasteType)
                error(MeterAirBubbleException:new{liquidType = source,})

            else
                error(result)
            end
        else
            error(result)
        end
    end
end


