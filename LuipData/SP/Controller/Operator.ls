--[[
 * @brief 各个驱动器操作业务。
 * @details 对液路器、温控器、信号采集器业务操作的功能进行封装。
--]]
Operator =
{
    IOpticalMeter = 0,
    ISolenoidValve = 0,
    IPeristalticPump = 0,
    ITemperatureControl = 0,
    IExtTemperatureControl = 0,
    IOpticalAcquire = 0,
    isMetering = false,
    isThermostat = false,
    isAcquiring = false,
    SPEED = 0.2,
    PRECISE = 0.000001,
}

--[[
 * @brief 废液排放类型。(分析废液 = 1，清洗废水 = 2)
--]]
WasteType =
{
    WasteReagent = 1,
    WasteWater = 2,
}

--[[
 * @brief 管路更新类型。(普通模式 = 1，精准模式第一次 = 2，，精准模式最后一次 = 3)
--]]
FillType =
{
    FillNormal = 1,
    FillAccurateFirst = 2,
    FillAccurateSecond = 3,
    FillAccurateEnd = 4,
}

AccurateType =
{
    normal= 0, --正常校准
    normalWithoutClean= 1, --精准校准不清洗
    addSampleWithClean = 2,--加样及清洗
    onlyAddSample = 3,--仅加样且不清洗
}

function Operator:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.__metatable = "Operator"

    self.IOpticalMeter = dc:GetIOpticalMeter()
    self.ISolenoidValve = dc:GetISolenoidValve()
    self.IPeristalticPump = dc:GetIPeristalticPump()
    self.ITemperatureControl = dc:GetITemperatureControl()
    self.IExtTemperatureControl = dc:GetIExtTemperatureControl()
    self.IOpticalAcquire = dc:GetIOpticalAcquire()

    return o
end

--[[
 * @brief 停止所有驱动控制器操作。
--]]
function Operator:Stop()
    -- 停止定量
    if self.isMetering then
        self.IOpticalMeter:StopMeter()
        self.isMetering= false
    end

   -- 停止泵
    for i,pump in pairs(pumps) do
        if pump.isRunning then
            pump:Stop()
        end
    end

	-- 停止信号采集
    if self.isAcquiring then
        self.IOpticalAcquire:StopAcquirer()
        self.isAcquiring= false
    end

end

--[[
 * @brief 泵抽取液体操作。
 * @param[in] source 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] speed 泵速，0为默认速度。
--]]
function Operator:Pump(source, volume, speed)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    local ret =false
    local timeout = math.floor(volume * setting.liquid.meterLimit.pumpTimeoutFactor)   -- 获取操作结果事件超时时间
    local map = ValveMap.new(source.valve)
    local pump = pumps[source.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象

    log:debug("{Pump} source = " .. source.name .. ", volume = " .. volume .. ", speed = " .. speed)

    --打开蠕动泵进行吸操作
    local err,result = pcall(function() return pump:Start(RollDirection.Suck, volume, speed) end)

    if not err then      -- 出现异常
        pump:Stop()                                                            -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    --等待1秒，未开阀之前启动泵，使操作的管路产生负压，减少抽取时产生的气泡
    if setting.liquidType.sliders ~=  source then
        App.Sleep(1000);
    else
        timeout = 6500
    end

    --if setting.liquidType.sliders ~=  source then
        -- 打开相关液路的阀门
        err,result = pcall(function() return self.ISolenoidValve:SetValveMap(map) end)
        if not err then -- 出现异常
            map:SetData(0)
            self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
            pump:Stop()                                                                  -- 停止泵
            error(result)
        else    --函数调用正常
            if not result then
                pump:Stop()
                return false
            end
        end
    --end

    -- 等待泵操作结果事件
    err,result = pcall(function() return pump:ExpectResult(timeout) end)

    if not err then -- 出现异常
        pump:Stop()                                                                      -- 停止泵
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        error(result)
    else    --函数调用正常
        --map:SetData(0)
        --self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        if setting.liquidType.sliders ~=  source then
            map = ValveMap.new(setting.liquidType.map.valve4)
            self.ISolenoidValve:SetValveMap(map)                                     --不关闭气体总阀
        end

        if result:GetResult() == PumpOperateResult.Failed then
            error (PumpFailedException:new{liquidType = source, dir = RollDirection.Suck,})
        elseif result:GetResult()  == PumpOperateResult.Stopped then
            error (PumpStoppedException:new{liquidType = source, dir = RollDirection.Suck,})
        elseif result:GetResult()  == PumpOperateResult.Finished then
            ret = true;
        end
    end

    map = nil
    ReagentRemainManager.ReduceReagent(source, volume)
    flowManager:ClearAllRemainEvent()
    return ret
end

--[[
 * @brief 泵抽取液体操作。
 * @param[in] source 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] speed 泵速，0为默认速度。
--]]
function Operator:PumpNotCloseValve(source, volume, speed)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    local ret =false
    local timeout = math.floor(volume * setting.liquid.meterLimit.pumpTimeoutFactor)   -- 获取操作结果事件超时时间
    local map = ValveMap.new(source.valve)
    local pump = pumps[source.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象

    log:debug("{Pump} source = " .. source.name .. ", volume = " .. volume .. ", speed = " .. speed)

    --打开蠕动泵进行吸操作
    local err,result = pcall(function() return pump:Start(RollDirection.Suck, volume, speed) end)

    if not err then      -- 出现异常
        pump:Stop()                                                            -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    --等待1秒，未开阀之前启动泵，使操作的管路产生负压，减少抽取时产生的气泡
    if setting.liquidType.sliders ~=  source and volume/speed > 0.5 then
        App.Sleep(1000);
    else
        timeout = 6500
    end

    --if setting.liquidType.sliders ~=  source then
    -- 打开相关液路的阀门
    err,result = pcall(function() return self.ISolenoidValve:SetValveMap(map) end)
    if not err then -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        pump:Stop()                                                                  -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            pump:Stop()
            return false
        end
    end
    --end

    -- 等待泵操作结果事件
    err,result = pcall(function() return pump:ExpectResult(timeout) end)

    if not err then -- 出现异常
        pump:Stop()                                                                      -- 停止泵
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        error(result)
    else    --函数调用正常
        --map:SetData(0)
        --self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门

        if result:GetResult() == PumpOperateResult.Failed then
            error (PumpFailedException:new{liquidType = source, dir = RollDirection.Suck,})
        elseif result:GetResult()  == PumpOperateResult.Stopped then
            error (PumpStoppedException:new{liquidType = source, dir = RollDirection.Suck,})
        elseif result:GetResult()  == PumpOperateResult.Finished then
            ret = true;
        end
    end

    map = nil
    ReagentRemainManager.ReduceReagent(source, volume)
    flowManager:ClearAllRemainEvent()
    return ret
end

--[[
 * @brief 泵无事件操作。
 * @param[in] source 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] speed 泵速，0为默认速度。
--]]
function Operator:PumpNoEvent(source, volume, speed)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    local ret =false
    local timeout = math.floor(volume * setting.liquid.meterLimit.pumpTimeoutFactor)   -- 获取操作结果事件超时时间
    local map = ValveMap.new(source.valve)
    local pump = pumps[source.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象

    log:debug("{Pump} source = " .. source.name .. ", volume = " .. volume .. ", speed = " .. speed)

    --打开蠕动泵进行吸操作
    local err,result = pcall(function() return pump:Start(RollDirection.Suck, volume, speed) end)

    if not err then      -- 出现异常
        pump:Stop()                                                            -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    map = nil

    return ret
end

function Operator:ForwardNoEvent(source, volume, speed)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    local ret =false
    local timeout = math.floor(volume * setting.liquid.meterLimit.pumpTimeoutFactor)   -- 获取操作结果事件超时时间
    local map = ValveMap.new(source.valve)
    local pump = pumps[source.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象

    log:debug("{Pump} source = " .. source.name .. ", volume = " .. volume .. ", speed = " .. speed)

    --打开蠕动泵进行吸操作
    local err,result = pcall(function() return pump:Start(RollDirection.Suck, volume, speed) end)

    if not err then      -- 出现异常
        pump:Stop()                                                            -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    err,result = pcall(function() return pump:ExpectResult(3000) end)

    if not err then -- 出现异常
        pump:Stop()                                                                      -- 停止泵
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        error(result)
    else    --函数调用正常
        --map:SetData(0)
        --self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        --if setting.liquidType.sliders ~=  source then
        --    map = ValveMap.new(setting.liquidType.map.valve4 | setting.liquidType.map.valve8)
        --    self.ISolenoidValve:SetValveMap(map)                                     --不关闭气体总阀
        --end
        --
        --if result:GetResult() == PumpOperateResult.Failed then
        --    error (PumpFailedException:new{liquidType = source, dir = RollDirection.Suck,})
        --elseif result:GetResult()  == PumpOperateResult.Stopped then
        --    error (PumpStoppedException:new{liquidType = source, dir = RollDirection.Suck,})
        --elseif result:GetResult()  == PumpOperateResult.Finished then
        --    ret = true;
        --end
    end

    map = nil
    ReagentRemainManager.ReduceReagent(source, volume)
    flowManager:ClearAllRemainEvent()

    return ret
end

function Operator:BackwardNoEvent(source, volume, speed)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    local ret =false
    local timeout = math.floor(volume * setting.liquid.meterLimit.pumpTimeoutFactor)   -- 获取操作结果事件超时时间
    local map = ValveMap.new(source.valve)
    local pump = pumps[source.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象

    log:debug("{Drain} source = " .. source.name .. ", volume = " .. volume .. ", speed = " .. speed)

    --打开蠕动泵进行吸操作
    local err,result = pcall(function() return pump:Start(RollDirection.Drain, volume, speed) end)

    if not err then      -- 出现异常
        pump:Stop()                                                            -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    err,result = pcall(function() return pump:ExpectResult(3000) end)

    if not err then -- 出现异常
        pump:Stop()                                                                      -- 停止泵
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        error(result)
    else    --函数调用正常
        --map:SetData(0)
        --self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        --if setting.liquidType.sliders ~=  source then
        --    map = ValveMap.new(setting.liquidType.map.valve4 | setting.liquidType.map.valve8)
        --    self.ISolenoidValve:SetValveMap(map)                                     --不关闭气体总阀
        --end
        --
        --if result:GetResult() == PumpOperateResult.Failed then
        --    error (PumpFailedException:new{liquidType = source, dir = RollDirection.Suck,})
        --elseif result:GetResult()  == PumpOperateResult.Stopped then
        --    error (PumpStoppedException:new{liquidType = source, dir = RollDirection.Suck,})
        --elseif result:GetResult()  == PumpOperateResult.Finished then
        --    ret = true;
        --end
    end

    map = nil
    ReagentRemainManager.ReduceReagent(source, volume)
    flowManager:ClearAllRemainEvent()

    return ret
end

--[[
 * @brief 排液操作。
 * @param[in] dest 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] speed 泵速，0为默认速度。
--]]
function Operator:Drain(dest, volume, speed)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    local ret =false
    local timeout = math.floor(volume * setting.liquid.meterLimit.pumpTimeoutFactor)  -- 获取操作结果事件超时时间
    local map = ValveMap.new(dest.valve)
    local pump = pumps[dest.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象

    log:debug("{Drain} dest = " .. dest.name .. ", volume = " .. volume .. ", speed = " .. speed)

    if dest == setting.liquidType.waste then
        op:SlidersSensorCheck()
    end

    -- 打开相关液路的阀门
    local err,result = pcall(function() return self.ISolenoidValve:SetValveMap(map) end)

    if not err then -- 出现异常
        error(result)
    else    --函数调用正常
         if not result then
            return false
        end
    end

    --打开蠕动泵进行吸操作
    err,result = pcall(function() return pump:Start(RollDirection.Drain, volume, speed) end)

    if not err then      -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        pump:Stop()                                                            -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    --等待1秒，未开阀之前启动泵，使操作的管路产生负压，减少抽取时产生的气泡
    App.Sleep(1500);

    -- 等待泵操作结果事件
    err,result = pcall(function() return pump:ExpectResult(timeout) end)

    if not err then -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        pump:Stop()                                                                      -- 停止泵
        error(result)
    else    --函数调用正常
        --map:SetData(0)
        map = ValveMap.new(setting.liquidType.map.valve4)
        self.ISolenoidValve:SetValveMap(map)                                     --不关闭气体总阀

        if result:GetResult() == PumpOperateResult.Failed then
            error (PumpFailedException:new{liquidType = dest, dir = RollDirection.Drain,})
        elseif result:GetResult()  == PumpOperateResult.Stopped then
            error (PumpStoppedException:new{liquidType = dest, dir = RollDirection.Drain,})
        elseif result:GetResult()  == PumpOperateResult.Finished then
            ret = true;
        end
    end

    map = nil

    ReagentRemainManager.RecoverReagent(dest, volume)
    return ret
end

--[[
 * @brief 排液操作,排液前后不关阀
 * @param[in] dest 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] speed 泵速，0为默认速度。
--]]
function Operator:DrainNotCloseValve(dest, volume, speed)
    local ret =false
    local timeout = math.floor(volume * setting.liquid.meterLimit.pumpTimeoutFactor)  -- 获取操作结果事件超时时间
    local map = ValveMap.new(dest.valve)
    local pump = pumps[dest.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象

    self:debugPrintf("{Drain} dest = " .. dest.name .. ", volume = " .. volume .. ", speed = " .. speed)

    local err,result = pcall(function() return self.ISolenoidValve:SetValveMap(map) end)

    if not err then -- 出现异常
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    --打开蠕动泵进行吸操作
    local err,result = pcall(function() return pump:Start(RollDirection.Drain, volume, speed) end)

    if not err then      -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        pump:Stop()                                                            -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    --等待1秒，未开阀之前启动泵，使操作的管路产生负压，减少抽取时产生的气泡
--    App.Sleep(1500);

    -- 等待泵操作结果事件
    err,result = pcall(function() return pump:ExpectResult(timeout) end)

    if not err then -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        pump:Stop()                                                                      -- 停止泵
        error(result)
    else    --函数调用正常
        map:SetData(0)

        if result:GetResult() == PumpOperateResult.Failed then
            error (PumpFailedException:new{liquidType = dest, dir = RollDirection.Drain,})
        elseif result:GetResult()  == PumpOperateResult.Stopped then
            error (PumpStoppedException:new{liquidType = dest, dir = RollDirection.Drain,})
        elseif result:GetResult()  == PumpOperateResult.Finished then
            ret = true;
        end
    end

    map = nil

    ReagentRemainManager.RecoverReagent(dest, volume)
    return ret
end

--[[
  * @brief 设置定量过冲程度
  * @param[in] mode 定量模式。
  * @param[in] value 过冲程度。
--]]
function Operator:SetMeterOverValue(mode, value)

    if mode == MeterMode.Accurate then

        self.IOpticalMeter:SetMeterEndPointOverCount(value)
        self:debugPrintf("{MeterOverValue} mode = Accurate, value = " .. value)

    elseif mode == MeterMode.Direct then

    elseif mode == MeterMode.Smart then

    elseif mode == MeterMode.Ropiness then

        self.IOpticalMeter:SetRopinessMeterOverValue(value)
        self:debugPrintf("{MeterOverValue} mode = Ropiness, value = " .. value)

    elseif mode == MeterMode.Layered then

        self.IOpticalMeter:SetRopinessMeterOverValue(value)
        self:debugPrintf("{MeterOverValue} mode = Layered, value = " .. value)

    end

end

--[[
 * @brief 定量液体操作。
  * @param[in] mode 定量模式。
 * @param[in] source 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] dir 方向。
--]]
function Operator:Meter(mode, source, volume, dir)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    local ret =false
    local map = ValveMap.new(source.valve)
    local limitVolume = 0
    local timeout = 0

    if source == setting.liquidType.sample then
        limitVolume = setting.liquid.meterLimit.sampleLimitVolume + volume + config.measureParam.extendSamplePipeVolume    -- 操作限值
    elseif source == setting.liquidType.blank then
        limitVolume = setting.liquid.meterLimit.blankLimitVolume + volume     --操作限值
    elseif source == setting.liquidType.digestionRoom then
        limitVolume = setting.liquid.meterLimit.digestionRoomLimitVolume + volume     -- 操作限值
    else
        limitVolume = setting.liquid.meterLimit.reagentLimitVolume + volume   --操作限值
    end

    if mode == MeterMode.Accurate or mode == MeterMode.Ropiness or mode == MeterMode.Layered then  --限制体积会影响超时判定
        limitVolume = limitVolume * 3
    end
    if mode == MeterMode.Accurate or mode == MeterMode.Ropiness or mode == MeterMode.Layered then
        timeout =  math.floor(limitVolume * setting.liquid.meterLimit.meterTimeoutFactor * 3)   -- 获取操作结果事件超时时间
        if dir == RollDirection.Drain and timeout > 180000 then
            timeout = 180000
        end
    else
        timeout = math.floor(limitVolume * setting.liquid.meterLimit.meterTimeoutFactor)  -- 获取操作结果事件超时时间
    end


    if mode == MeterMode.Accurate then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Accurate, dir = " .. dir )
    elseif mode == MeterMode.Direct then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Direct, dir = " .. dir )
    elseif mode == MeterMode.Smart then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Smart, dir = " .. dir )
    elseif mode == MeterMode.Ropiness then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Ropiness, dir = " .. dir )
    elseif mode == MeterMode.Layered then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Layered, dir = " .. dir )
    end

    self.isMetering = true

    --打开蠕动泵进行吸操作并精确定量
    local err,result = pcall(function() return self.IOpticalMeter:StartMeter(dir, mode, volume, limitVolume) end)

    if not err then      -- 出现异常
        self:StopMeter()                                                            -- 停止泵
        self.isMetering = false
        error(result)
    else    --函数调用正常
        if not result then
            self.isMetering = false
            return false
        end
    end

    --等待1秒，未开阀之前启动泵，使操作的管路产生负压，减少抽取时产生的气泡
    App.Sleep(1500);

    -- 打开相关液路的阀门
    err,result = pcall(function() return self.ISolenoidValve:SetValveMap(map) end)

    if not err then -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        self:StopMeter()                                                            -- 停止泵
        self.isMetering = false
        error(result)
    else    --函数调用正常
        if not result then
            self:StopMeter()                                                            -- 停止泵
            self.isMetering = false
            return false
        end
    end

    -- 等待泵操作结果事件
    err,result = pcall(function() return self.IOpticalMeter:ExpectMeterResult(timeout) end)

    if not err then -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        self:StopMeter()                                                            -- 停止泵
        self.isMetering = false
        error(result)
    else    --函数调用正常
        self.isMetering = false
         if result == MeterResult.Failed then
                error (MeterFailedException:new{liquidType = source,})
        elseif  result == MeterResult.Overflow then
                error (MeterOverflowException:new{liquidType = source,})
        elseif  result == MeterResult.Stopped then
                error (MeterStoppedException:new{liquidType = source,})
        elseif  result == MeterResult.Unfinished then
            error (MeterUnfinishedException:new{liquidType = source,})
        elseif  result == MeterResult.AirBubble then
                error (MeterAirBubbleException:new{liquidType = source,})
        elseif result == MeterResult.Finished then
                ret = true
        end
    end

    map = nil
    ReagentRemainManager.ReduceReagent(source, volume)
    return ret
end

function Operator:CombineMeter(mode, source, volume, dir, isOpenValve, isCloseValve)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    local ret =false
    local map = ValveMap.new(source.valve)
    local limitVolume = 0
    local timeout = 0
    local openValve = true
    local closeValve = true
    if isOpenValve ~= nil then
        openValve = isOpenValve
    end
    if isCloseValve ~= nil then
        closeValve = isCloseValve
    end
    if source == setting.liquidType.sample then
        limitVolume = setting.liquid.meterLimit.sampleLimitVolume + volume + config.measureParam.extendSamplePipeVolume    -- 操作限值
    elseif source == setting.liquidType.blank then
        limitVolume = setting.liquid.meterLimit.blankLimitVolume + volume     --操作限值
    elseif source == setting.liquidType.digestionRoom then
        limitVolume = setting.liquid.meterLimit.digestionRoomLimitVolume + volume     -- 操作限值
    else
        limitVolume = setting.liquid.meterLimit.reagentLimitVolume + volume   --操作限值
    end

    if mode == MeterMode.Accurate or mode == MeterMode.Ropiness or mode == MeterMode.Layered then  --限制体积会影响超时判定
        limitVolume = limitVolume * 3
    end
    if mode == MeterMode.Accurate or mode == MeterMode.Ropiness or mode == MeterMode.Layered then
        timeout =  math.floor(limitVolume * setting.liquid.meterLimit.meterTimeoutFactor * 3)   -- 获取操作结果事件超时时间
    else
        timeout = math.floor(limitVolume * setting.liquid.meterLimit.meterTimeoutFactor)  -- 获取操作结果事件超时时间
    end


    if mode == MeterMode.Accurate then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Accurate, dir = " .. dir )
    elseif mode == MeterMode.Direct then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Direct, dir = " .. dir )
    elseif mode == MeterMode.Smart then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Smart, dir = " .. dir )
    elseif mode == MeterMode.Ropiness then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Ropiness, dir = " .. dir )
    elseif mode == MeterMode.Layered then
        log:debug("{Meter} source = " .. source.name .. ", volume = " .. volume .. ", mode = Layered, dir = " .. dir )
    end

    self.isMetering = true

    --打开蠕动泵进行吸操作并精确定量
    local err,result = pcall(function() return self.IOpticalMeter:StartMeter(dir, mode, volume, limitVolume) end)

    if not err then      -- 出现异常
        self:StopMeter()                                                            -- 停止泵
        self.isMetering = false
        error(result)
    else    --函数调用正常
        if not result then
            self.isMetering = false
            return false
        end
    end

    if openValve == true then
        --等待1秒，未开阀之前启动泵，使操作的管路产生负压，减少抽取时产生的气泡
        App.Sleep(1500);

        -- 打开相关液路的阀门
        err,result = pcall(function() return self.ISolenoidValve:SetValveMap(map) end)

        if not err then -- 出现异常
            map:SetData(0)
            self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
            self:StopMeter()                                                            -- 停止泵
            self.isMetering = false
            error(result)
        else    --函数调用正常
            if not result then
                self:StopMeter()                                                            -- 停止泵
                self.isMetering = false
                return false
            end
        end
    end

    -- 等待泵操作结果事件
    err,result = pcall(function() return self.IOpticalMeter:ExpectMeterResult(timeout) end)

    if not err then -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        self:StopMeter()                                                            -- 停止泵
        self.isMetering = false
        error(result)
    else    --函数调用正常
        self.isMetering = false
        if result == MeterResult.Failed then
            error (MeterFailedException:new{liquidType = source,})
        elseif  result == MeterResult.Overflow then
            error (MeterOverflowException:new{liquidType = source,})
        elseif  result == MeterResult.Stopped then
            error (MeterStoppedException:new{liquidType = source,})
        elseif  result == MeterResult.Unfinished then
            error (MeterUnfinishedException:new{liquidType = source,})
        elseif  result == MeterResult.AirBubble then
            error (MeterAirBubbleException:new{liquidType = source,})
        elseif result == MeterResult.Finished then
            ret = true
        end
    end

    map = nil
    ReagentRemainManager.ReduceReagent(source, volume)
    return ret
end

--[[
 * @brief 停止定量操作。
--]]

function Operator:StopMeter()

    self.IOpticalMeter:StopMeter()
    local result = self.IOpticalMeter:ExpectMeterResult(3000)

    if result == MeterResult.Stopped then

    end
end

--[[
 * @brief 定量结束自动关闭阀开关
 * @param IsAutoCloseValve Bool 是否自动关闭。TRUE 自动关闭，FALSE 定量结束不关闭阀
 *  - @ref DSCP_OK  操作成功；
 *  - @ref DSCP_ERROR 操作失败；
--]]
function Operator:AutoCloseValve(isCloseValve)
    return self.IOpticalMeter:IsAutoCloseValve(isCloseValve)
end

--[[
 * @brief   消解器冒泡。
 * @details 向消解器空气，使得消解器溶液充分反应。
 * @param[in] time 冒泡时间
--]]
 function Operator:AirToDigestionRoom(time)
     if time == nil then
         time = setting.liquid.pumpAirVolume/setting.liquid.pumpAirSpeed
     end

     local factor = self.IPeristalticPump:GetPumpFactor(0)
     local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

     --self:Drain(setting.liquidType.none, 0.3, drainSpeed/2)        -- 不开任何阀的情况下，给定量管泵入空气使定量管恢复常压
     self:Drain(setting.liquidType.digestionRoom, time * setting.liquid.pumpAirSpeed, setting.liquid.pumpAirStepSpeed * factor)
end

--[[
 * @brief 管道隔离。
 * @param[in] source 管道类型。
--]]

function Operator:SecludeLiquid(source, vol)
     if source == setting.liquidType.digestionRoom then
         self:Drain(source, setting.liquid.liquidSecludeVolume*10, setting.liquid.liquidSecludeSpeed)
     else
         if vol ~= nil and vol ~= 0 then
             self:Drain(source, vol, setting.liquid.liquidSecludeSpeed)
         else
             self:Drain(source, setting.liquid.liquidSecludeVolume, setting.liquid.liquidSecludeSpeed)
         end
     end
end

--[[
 * @brief 快速定量或智能定量抽取液体到消解室。
 * @details 以快速定量或智能定量的方法抽取指定的溶液到定量管，再压到消解器,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 溶液类型。
 * @param[in] vol 溶液体积。
 * @param[in] point 定量点序号
--]]
 function Operator:PumpToDigestionRoom(source, vol, point, wType)
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
    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
     local ret = nil
     local volTable = {}
     if point == nil then
         ret,volTable = self:AutoMeterVolumeAnalyse(vol)
         if not ret then
             log:warn("PumpToDigestionRoom 体积分解异常")
             error (MeterFailedException:new{liquidType = source,})
         end
     else
         ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
         if not ret then
             log:warn("PumpToDigestionRoom 体积分解异常")
             error (MeterFailedException:new{liquidType = source,})
         end
     end

     -- 设置定量过冲程度
     self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                                self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                                self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, drainSpeed)

                                failedCnt = 0
                                overflowCnt = 0
                                unfinishedCnt = 0
                                airBubbleCnt = 0
                                timeoutCnt = 0
                            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What());
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end
end

--[[
 * @brief 精确定量抽取液体到消解室。
 * @details 以精确定量的方法抽取指定的溶液到定量管，再压到消解器,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值时，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 溶液类型。
 * @param[in] vol 溶液体积。
 * @param[in] point 定量点序号
--]]
function Operator:MeterToDigestionRoom(source, vol, point, wType)
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
    --废液类型
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end
    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:AutoMeterVolumeAnalyse(vol)
        if not ret then
            log:warn("MeterToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("MeterToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    if source == setting.liquidType.reagent1 then
        -- 设置定量过冲程度
        self:SetMeterOverValue(MeterMode.Accurate, setting.liquid.accurateMeterOverValue)
    else
        self:SetMeterOverValue(MeterMode.Accurate, setting.liquid.accurateMeterOverValue)
    end



    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                                self:Meter(MeterMode.Accurate, source, volume, RollDirection.Suck)
                                App.Sleep(500)
                                self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, drainSpeed/3)

                                failedCnt = 0
                                overflowCnt = 0
                                unfinishedCnt = 0
                                airBubbleCnt = 0
                                timeoutCnt = 0
                            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What())
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end
end

--[[
 * @brief 间接精确定量抽取液体到消解室。
 * @details 以精确定量的方法抽取指定的溶液到定量管上定量点，再下压到下定量点，再定量至消解器。(只适用于下定量点的定量)
 * @details 当出现期望事件等待超时、定量失败、达到限定体值时，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 溶液类型。
 * @param[in] vol 溶液体积。
--]]
function Operator:IndirectMeterToDigestionRoom(source, vol, wType)
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
    local factor = 0.001
    local wasteType = WasteType.WasteReagent
    if wType ==  WasteType.WasteWater or wType == setting.liquidType.wasteWater then
        wasteType = WasteType.WasteWater
    end


    local factor = self.IPeristalticPump:GetPumpFactor(0)

    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
    log:debug("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))


    local maxVol = config.hardwareConfig.meterPoint.point[2].setVolume

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret,volTable = self:AutoMeterVolumeAnalyse(vol)
    if not ret then
        log:warn("PumpToDigestion 体积分解异常")
        error (MeterFailedException:new{liquidType = source,})
    end

    self:SetMeterOverValue(MeterMode.Accurate, setting.liquid.accurateMeterOverValue)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                self:AutoCloseValve(false)
                self:SetMeterOverValue(MeterMode.Accurate, 0)
                self:Meter(MeterMode.Accurate, source, maxVol, RollDirection.Suck)


                self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor * 0.25)
                log:debug("Set Meter Speed " .. (setting.liquid.meterSpeed * factor * 0.25))

                self:Meter(MeterMode.Accurate, source, volume, RollDirection.Drain)

                self:PumpNotCloseValve(source,  0.3, setting.liquid.meterSpeed * factor * 0.25)

                self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor * 0.05)
                log:debug("Set Meter Speed " .. (setting.liquid.meterSpeed * factor * 0.05))

                self:AutoCloseValve(true)

                self:Meter(MeterMode.Accurate, source, volume, RollDirection.Drain)


                self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, 0)

                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end)

            if not err then      -- 出现异常

                self.isCloseValveOnDrain = false

                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What())
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end
end


--[[
 * @brief 精确定量抽取液体到消解室。
 * @details 以精确定量的方法抽取指定的溶液到定量管，再压到消解器,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值时，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 溶液类型。
 * @param[in] vol 溶液体积。
 * @param[in] point 定量点序号
--]]
function Operator:CombineMeterToDigestionRoom(source, vol, point, wType)
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
    --废液类型
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end
    local factor = self.IPeristalticPump:GetPumpFactor(0)

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:AutoMeterVolumeAnalyse(vol)
        if not ret then
            log:warn("CombineMeterToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("CombineMeterToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    -- 设置定量过冲程度

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                self:AutoCloseValve(false)
                self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
                self:debugPrintf("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))
                self:SetMeterOverValue(MeterMode.Smart, 0)
                self:Meter(MeterMode.Smart, source, volume + 0.5, RollDirection.Suck)

                self:AutoCloseValve(true)

                self.IOpticalMeter:SetMeteSpeed(setting.liquid.slowMeterSpeed * factor)
                self:debugPrintf("Set Meter Speed " .. (setting.liquid.slowMeterSpeed * factor))
                self:SetMeterOverValue(MeterMode.Ropiness, setting.liquid.ropinessMeterOverValue)
                self:Meter(MeterMode.Ropiness, source, volume, RollDirection.Drain)

                self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, 0)


                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What())
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end
end
--[[
 * @brief 慢速定量抽取液体到消解室。
 * @details 以慢速定量的方法抽取指定的溶液到定量管，再压到消解器,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值时，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 溶液类型。
 * @param[in] vol 溶液体积。
 * @param[in] point 定量点序号
--]]
function Operator:SlowMeterToDigestionRoom(source, vol, point, wType)
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

    local MeterPoint1Vol= config.hardwareConfig.meterPoint.point[1].setVolume
    local MeterPoint2Vol= config.hardwareConfig.meterPoint.point[2].setVolume
    local factor = self.IPeristalticPump:GetPumpFactor(0)

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    --废液类型
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end
    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:AutoMeterVolumeAnalyse(vol)
        if not ret then
            log:warn("SlowMeterToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("SlowMeterToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Ropiness, setting.liquid.ropinessMeterOverValue)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                                self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor *0.5)
                                log:debug("Set Meter Speed " .. (setting.liquid.meterSpeed * factor *0.5))
                                self:AutoCloseValve(false)
                                self:Meter(MeterMode.Ropiness, source, volume, RollDirection.Suck)
                                self:AutoCloseValve(true)	 --start auto valve close function
                                --self:Pump(source, 0.2, factor*20)
                                self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, drainSpeed/3 )

                                failedCnt = 0
                                overflowCnt = 0
                                unfinishedCnt = 0
                                airBubbleCnt = 0
                                timeoutCnt = 0
                            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What())
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:Drain(source, volume*0.8, drainSpeed)
                            self:DrainToWaste(volume*0.2);
                            self:CleanMeterPipe(setting.liquidType.blank, MeterPoint2Vol) 	-- 清洗定量管
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:Drain(source, volume*0.8, drainSpeed)
                            self:DrainToWaste(volume*0.2);
                            self:CleanMeterPipe(setting.liquidType.blank, MeterPoint2Vol) 	-- 清洗定量管
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:Drain(source, volume*0.8, drainSpeed)
                            self:DrainToWaste(volume*0.2);
                            self:CleanMeterPipe(setting.liquidType.blank, MeterPoint2Vol) 	-- 清洗定量管
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))
end

--[[
 * @brief 泵操作从定量管排液到废液桶。
 * @param[in] vol 溶液体积。
  * @param[in] wType 排放类型 (默认为废水)
--]]
function Operator:DrainToWaste(vol, wType)
    if vol == nil then
        vol = 1
    end

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    if wType == WasteType.WasteReagent or wType == setting.liquidType.waste then
        local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor
        self:Drain(setting.liquidType.waste,
                vol + setting.liquid.multipleValvePipeVolume  + setting.liquid.wastePipeVolume,
                drainSpeed)
    else
        self:Drain(setting.liquidType.wasteWater,
                vol + setting.liquid.multipleValvePipeVolume  + setting.liquid.wastePipeVolume,
                drainSpeed)
    end
end

--[[
 * @brief 泵操作从定量管排液到废液桶。
 * @param[in] vol 溶液体积。
  * @param[in] wType 排放类型 (默认为废液)
--]]
function Operator:DrainToWasteNotCloseValve(vol, wType)
    if vol == nil then
        vol = 1
    end

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    if wType == WasteType.WasteWater or wType == setting.liquidType.wasteWater then
        self:DrainNotCloseValve(setting.liquidType.wasteWater, vol, drainSpeed)
    else
        self:DrainNotCloseValve(setting.liquidType.waste, vol, drainSpeed)
    end
end

--[[
 * @brief 泵操作从定量管排液到废水桶。
 * @param[in] vol 溶液体积。
--]]
function Operator:DrainToWasteWater(vol)
    if vol == nil then
        vol = 1
    end

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    self:Drain(setting.liquidType.wasteWater,
    vol + setting.liquid.multipleValvePipeVolume  + setting.liquid.wastePipeVolume,
            drainSpeed)
end

--[[
 * @brief 消解室排液最小正常排液次数
 * @details 以快速定量或智能定量的方法抽取消解器溶液到定量管，再排到废液桶,    
]]
function Operator:GetMinDrainDigestionTimes(tatolVol)
	local point = setting.liquid.digestionRoomMeterPoint
    local pointVol= config.hardwareConfig.meterPoint.point[point].setVolume
	local minTimes = math.floor(0.5 * tatolVol / pointVol + self.PRECISE) --最少正常排液次数
	self:debugPrintf("tatolVol = " .. tatolVol .. ",minTimes = " .. minTimes)
	return minTimes;
end
--[[
 * @brief 带检查的消解室排液。
 * @details 以快速定量或智能定量的方法抽取消解器溶液到定量管，再排到废液桶,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] vol 溶液体积。
--]]

function Operator:DrainFromDigestionRoomCheck(minTimes, wType)

    local point = setting.liquid.digestionRoomMeterPoint
    local pointVol= config.hardwareConfig.meterPoint.point[point].setVolume

    local meterFailedReTry = setting.liquid.meterFailedReTry	-- 定量失败重试次数
    local meterOverflowReTry = setting.liquid.meterOverflowReTry	--定量溢出重试次数
    local meterAirBubbleReTry = setting.liquid.meterAirBubbleReTry	-- 定量有气泡重试次数
    local meterTimeoutReTry = setting.liquid.meterTimeoutReTry	-- 定量超时重试次数

    local failedCnt = 0
    local overflowCnt = 0
    local airBubbleCnt = 0
    local timeoutCnt = 0

    --废液类型
    local wasteType = WasteType.WasteReagent
    if wType == WasteType.WasteWater or wType == setting.liquidType.wasteWater then
        wasteType = WasteType.WasteWater
    end

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    local meterTimes = 0

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    while true do

        local err,result = pcall(function()
                                self:Meter(MeterMode.Smart, setting.liquidType.digestionRoom, pointVol, RollDirection.Suck)
                                self:DrainToWaste(pointVol, wasteType)
                                meterTimes = meterTimes + 1
                                failedCnt = 0
                                overflowCnt = 0
                            end)

        if not err then      -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    timeoutCnt = timeoutCnt +1
                    log:warn(result:What())
                    if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                        self:DrainToWaste(pointVol, wasteType)
                    elseif timeoutCnt >= meterTimeoutReTry then
                        self:DrainToWaste(pointVol, wasteType)
                        error (MeterExpectTimeoutException:new{liquidType = setting.liquidType.digestionRoom,})
                    end
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == MeterFailedException then
                    failedCnt = failedCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                    self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, 0)
                    self:DrainToWaste(setting.liquid.meterCleanVolume, wasteType)
                elseif getmetatable(result) == MeterOverflowException then
                    overflowCnt = overflowCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                elseif getmetatable(result) == MeterUnfinishedException then
                    self:DrainToWaste(pointVol, wasteType)
					
                    if config.system.drainDigestRoomCheck == true and minTimes ~= nil  and minTimes > 0 then
                        if meterTimes < minTimes then
                            self:debugPrintf("逐出室排液异常")
                            error (DrainFromDigestionException:new{})
                        else
                            self:debugPrintf("逐出室排液完成")
                        end
                    else
                        self:debugPrintf("逐出室排液完成")
                    end
                    break
                elseif getmetatable(result) == MeterAirBubbleException then
                    airBubbleCnt = airBubbleCnt +1
                    log:warn(result:What());
                    self:DrainToWaste(pointVol, wasteType)
                else
                    error(result)
                end

                 --定量异常处理机制
                if failedCnt >= meterFailedReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterFailedException:new{liquidType = setting.liquidType.digestionRoom,})
                end

                if overflowCnt >= meterOverflowReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterOverflowException:new{liquidType = setting.liquidType.digestionRoom,})
                end

                if airBubbleCnt >= meterAirBubbleReTry then
                    self:DrainToWaste(volume, wasteType)
                    local e = MeterAirBubbleException:new{liquidType = setting.liquidType.digestionRoom,}
                    log:warn(e:What())
                    ExceptionHandler.MakeAlarm(e)
                    break
                end
            else
                error(result)
            end

        end
    end
end

--[[
 * @brief 带检查的消解室排液。
 * @details 以快速定量或智能定量的方法抽取消解器溶液到定量管，再排到废液桶,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] vol 溶液体积。
--]]

function Operator:DrainFromDigestionRoomCheckWithPressure(minTimes, wType)

    local point = setting.liquid.digestionRoomMeterPoint
    local pointVol= config.hardwareConfig.meterPoint.point[point].setVolume

    local meterFailedReTry = setting.liquid.meterFailedReTry	-- 定量失败重试次数
    local meterOverflowReTry = setting.liquid.meterOverflowReTry	--定量溢出重试次数
    local meterAirBubbleReTry = setting.liquid.meterAirBubbleReTry	-- 定量有气泡重试次数
    local meterTimeoutReTry = setting.liquid.meterTimeoutReTry	-- 定量超时重试次数

    local failedCnt = 0
    local overflowCnt = 0
    local airBubbleCnt = 0
    local timeoutCnt = 0

    --废液类型
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    local meterTimes = 0

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    while true do

        local err,result = pcall(function()
            self:Meter(MeterMode.Smart, setting.liquidType.digestionRoom, pointVol, RollDirection.Suck)

            if meterTimes == 0 then
                self:DrainToWasteNotCloseValve(0.5, WasteType.WasteReagent)
                self:DrainToWaste(pointVol, WasteType.WasteReagent)
            elseif meterTimes == 1 then
                self:DrainToWasteNotCloseValve(0.5, WasteType.WasteWater)
                self:DrainToWaste(pointVol, WasteType.WasteWater)
            else
                self:DrainToWaste(pointVol, wasteType)
            end

            meterTimes = meterTimes + 1
            failedCnt = 0
            overflowCnt = 0
        end)

        if not err then      -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    timeoutCnt = timeoutCnt +1
                    log:warn(result:What())
                    if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                        self:DrainToWaste(pointVol, wasteType)
                    elseif timeoutCnt >= meterTimeoutReTry then
                        self:DrainToWaste(pointVol, wasteType)
                        error (MeterExpectTimeoutException:new{liquidType = setting.liquidType.digestionRoom,})
                    end
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == MeterFailedException then
                    failedCnt = failedCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                    self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, 0)
                    self:DrainToWaste(setting.liquid.meterCleanVolume, wasteType)
                elseif getmetatable(result) == MeterOverflowException then
                    overflowCnt = overflowCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                elseif getmetatable(result) == MeterUnfinishedException then
                    self:DrainToWaste(pointVol, wasteType)

                    if config.system.drainDigestRoomCheck == true and minTimes ~= nil  and minTimes > 0 then
                        if meterTimes < minTimes then
                            self:debugPrintf("逐出室排液异常")
                            error (DrainFromDigestionException:new{})
                        else
                            self:debugPrintf("逐出室排液完成")
                        end
                    else
                        self:debugPrintf("逐出室排液完成")
                    end
                    break
                elseif getmetatable(result) == MeterAirBubbleException then
                    airBubbleCnt = airBubbleCnt +1
                    log:warn(result:What());
                    self:DrainToWaste(pointVol, wasteType)
                else
                    error(result)
                end

                --定量异常处理机制
                if failedCnt >= meterFailedReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterFailedException:new{liquidType = setting.liquidType.digestionRoom,})
                end

                if overflowCnt >= meterOverflowReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterOverflowException:new{liquidType = setting.liquidType.digestionRoom,})
                end

                if airBubbleCnt >= meterAirBubbleReTry then
                    self:DrainToWaste(volume, wasteType)
                    local e = MeterAirBubbleException:new{liquidType = setting.liquidType.digestionRoom,}
                    log:warn(e:What())
                    ExceptionHandler.MakeAlarm(e)
                    break
                end
            else
                error(result)
            end

        end
    end
end

--[[
 * @brief 快速定量或智能定量排消解器溶液到废水桶。
 * @details 以快速定量或智能定量的方法抽取消解器溶液到定量管，再排到废水桶,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] vol 溶液体积。
--]]
function Operator:DrainFromDigestionRoom(wType)

    local point = setting.liquid.digestionRoomMeterPoint
    local pointVol= config.hardwareConfig.meterPoint.point[point].setVolume

    local meterFailedReTry = setting.liquid.meterFailedReTry	-- 定量失败重试次数
    local meterOverflowReTry = setting.liquid.meterOverflowReTry	--定量溢出重试次数
    local meterAirBubbleReTry = setting.liquid.meterAirBubbleReTry	-- 定量有气泡重试次数
    local meterTimeoutReTry = setting.liquid.meterTimeoutReTry	-- 定量超时重试次数

    local failedCnt = 0
    local overflowCnt = 0
    local airBubbleCnt = 0
    local timeoutCnt = 0

    --废液类型
    local wasteType = WasteType.WasteWater
    if wType == WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    while true do

        local err,result = pcall(function()
                                self:Meter(MeterMode.Smart, setting.liquidType.digestionRoom, pointVol, RollDirection.Suck)
                                self:DrainToWaste(pointVol, wasteType)
                                failedCnt = 0
                                overflowCnt = 0
                            end)

        if not err then      -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    timeoutCnt = timeoutCnt +1
                    log:warn(result:What())
                    if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                        self:DrainToWaste(pointVol, wasteType)
                    elseif timeoutCnt >= meterTimeoutReTry then
                        self:DrainToWaste(pointVol, wasteType)
                        error (MeterExpectTimeoutException:new{liquidType = setting.liquidType.digestionRoom,})
                    end
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == MeterFailedException then
                    failedCnt = failedCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                    self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, 0)
                    self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType)
                elseif getmetatable(result) == MeterOverflowException then
                    overflowCnt = overflowCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                elseif getmetatable(result) == MeterUnfinishedException then
                    self:DrainToWaste(pointVol, wasteType)
                    self:debugPrintf("逐出室排液完成")
                    break
                elseif getmetatable(result) == MeterAirBubbleException then
                    airBubbleCnt = airBubbleCnt +1
                    log:warn(result:What());
                    self:DrainToWaste(pointVol, wasteType)
                else
                    error(result)
                end

                 --定量异常处理机制
                if failedCnt >= meterFailedReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterFailedException:new{liquidType = setting.liquidType.digestionRoom,})
                end

                if overflowCnt >= meterOverflowReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterOverflowException:new{liquidType = setting.liquidType.digestionRoom,})
                end

                if airBubbleCnt >= meterAirBubbleReTry then
                    self:DrainToWaste(volume, wasteType)
                    local e = MeterAirBubbleException:new{liquidType = setting.liquidType.digestionRoom,}
                    log:warn(e:What())
                    ExceptionHandler.MakeAlarm(e)
                    break
                end
            else
                error(result)
            end

        end
    end
end

--[[
 * @brief 快速定量或智能定量排消解器溶液到废水桶。
 * @details 以快速定量或智能定量的方法抽取消解器溶液到定量管，再排到废水桶,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] vol 溶液体积。
--]]
function Operator:DrainFromWaste()

    local point = 2
    local pointVol= config.hardwareConfig.meterPoint.point[point].setVolume

    local meterFailedReTry = setting.liquid.meterFailedReTry	-- 定量失败重试次数
    local meterOverflowReTry = setting.liquid.meterOverflowReTry	--定量溢出重试次数
    local meterAirBubbleReTry = setting.liquid.meterAirBubbleReTry	-- 定量有气泡重试次数
    local meterTimeoutReTry = setting.liquid.meterTimeoutReTry	-- 定量超时重试次数

    local failedCnt = 0
    local overflowCnt = 0
    local airBubbleCnt = 0
    local timeoutCnt = 0

    --废液类型
    local wasteType = WasteType.WasteWater

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    while true do

        local err,result = pcall(function()
            self:Meter(MeterMode.Smart, setting.liquidType.waste, pointVol, RollDirection.Suck)
            self:DrainToWaste(pointVol, wasteType)
            failedCnt = 0
            overflowCnt = 0
        end)

        if not err then      -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    timeoutCnt = timeoutCnt +1
                    log:warn(result:What())
                    if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                        self:DrainToWaste(pointVol, wasteType)
                    elseif timeoutCnt >= meterTimeoutReTry then
                        self:DrainToWaste(pointVol, wasteType)
                        error (MeterExpectTimeoutException:new{liquidType = setting.liquidType.waste,})
                    end
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == MeterFailedException then
                    failedCnt = failedCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                    self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, 0)
                    self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType)
                elseif getmetatable(result) == MeterOverflowException then
                    overflowCnt = overflowCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                elseif getmetatable(result) == MeterUnfinishedException then
                    self:DrainToWaste(pointVol, wasteType)
                    break
                elseif getmetatable(result) == MeterAirBubbleException then
                    airBubbleCnt = airBubbleCnt +1
                    log:warn(result:What());
                    self:DrainToWaste(pointVol, wasteType)
                else
                    error(result)
                end

                --定量异常处理机制
                if failedCnt >= meterFailedReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterFailedException:new{liquidType = setting.liquidType.waste,})
                end

                if overflowCnt >= meterOverflowReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterOverflowException:new{liquidType = setting.liquidType.waste,})
                end

                if airBubbleCnt >= meterAirBubbleReTry then
                    self:DrainToWaste(volume, wasteType)
                    local e = MeterAirBubbleException:new{liquidType = setting.liquidType.waste,}
                    log:warn(e:What())
                    ExceptionHandler.MakeAlarm(e)
                    break
                end
            else
                error(result)
            end

        end
    end
end

--[[
 * @brief 快速定量或智能定量冷凝液到废液桶。
 * @details 以快速定量或智能定量的方法抽取积液到定量管，再排到废液桶,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] vol 溶液体积。
--]]
function Operator:DrainFromRefrigeratorWaterRoom(wType)

    local point = setting.liquid.digestionRoomMeterPoint
    local pointVol= config.hardwareConfig.meterPoint.point[point].setVolume
    local source = setting.liquidType.coolerWater

    local meterFailedReTry = setting.liquid.meterFailedReTry	-- 定量失败重试次数
    local meterOverflowReTry = setting.liquid.meterOverflowReTry	--定量溢出重试次数
    local meterAirBubbleReTry = setting.liquid.meterAirBubbleReTry	-- 定量有气泡重试次数
    local meterTimeoutReTry = setting.liquid.meterTimeoutReTry	-- 定量超时重试次数

    local failedCnt = 0
    local overflowCnt = 0
    local airBubbleCnt = 0
    local timeoutCnt = 0

    --废液类型
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end

    log:debug("排冷凝液")

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self:Pump(setting.liquidType.coolerWater,  4, setting.liquid.drainSpeed * factor/2);
    self:DrainToWaste(2, wasteType)
    --self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    --self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))
    --
    ---- 设置定量过冲程度
    --self:SetMeterOverValue(MeterMode.Smart, 0)

    --while true do
    --
    --    local err,result = pcall(function()
    --        --self:Meter(MeterMode.Smart, source, pointVol, RollDirection.Suck)
    --        self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, setting.liquid.drainSpeed * factor);
    --        self:DrainToWaste(pointVol, wasteType)
    --        failedCnt = 0
    --        overflowCnt = 0
    --    end)
    --
    --    if not err then      -- 出现异常
    --        if type(result) == "userdata" then
    --            if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
    --                timeoutCnt = timeoutCnt +1
    --                log:warn(result:What())
    --                if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
    --                    self:DrainToWaste(pointVol, wasteType)
    --                elseif timeoutCnt >= meterTimeoutReTry then
    --                    self:DrainToWaste(pointVol, wasteType)
    --                    error (MeterExpectTimeoutException:new{liquidType = source,})
    --                end
    --            else
    --                error(result)
    --            end
    --        elseif type(result) == "table" then
    --            if getmetatable(result) == MeterFailedException then
    --                failedCnt = failedCnt +1
    --                log:warn(result:What())
    --                self:DrainToWaste(pointVol, wasteType)
    --                self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, 0)
    --                self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType)
    --            elseif getmetatable(result) == MeterOverflowException then
    --                overflowCnt = overflowCnt +1
    --                log:warn(result:What())
    --                self:DrainToWaste(pointVol, wasteType)
    --            elseif getmetatable(result) == MeterUnfinishedException then
    --                self:DrainToWaste(pointVol, wasteType)
    --                self:debugPrintf("逐出室排液完成")
    --                break
    --            elseif getmetatable(result) == MeterAirBubbleException then
    --                airBubbleCnt = airBubbleCnt +1
    --                log:warn(result:What());
    --                self:DrainToWaste(pointVol, wasteType)
    --            else
    --                error(result)
    --            end
    --
    --            --定量异常处理机制
    --            if failedCnt >= meterFailedReTry then
    --                self:DrainToWaste(pointVol, wasteType)
    --                error (MeterFailedException:new{liquidType = source,})
    --            end
    --
    --            if overflowCnt >= meterOverflowReTry then
    --                self:DrainToWaste(pointVol, wasteType)
    --                error (MeterOverflowException:new{liquidType = source,})
    --            end
    --
    --            if airBubbleCnt >= meterAirBubbleReTry then
    --                self:DrainToWaste(volume, wasteType)
    --                local e = MeterAirBubbleException:new{liquidType = source,}
    --                log:warn(e:What())
    --                ExceptionHandler.MakeAlarm(e)
    --                break
    --            end
    --        else
    --            error(result)
    --        end
    --
    --    end
    --end
end

--[[
 * @brief 智能定量液体到水样管。
 * @details 抽取定量液体到定量管，再排到水样管,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 定量液体类型。
 * @param[in] vol 定量体积。
 * @param[in] vol 废水类型。
--]]

function Operator:MeterToSample(source, vol, wType)
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

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    ret,volTable = self:MeterVolumeAnalyse(vol)
    if not ret then
        log:warn("CleanMeterPipe 体积分解异常")
        error (MeterFailedException:new{liquidType = source,})
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                self:Drain(setting.liquidType.sample, volume + setting.liquid.multipleValvePipeVolume, drainSpeed)

                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What());
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end

    self:SecludeLiquid(source)
end

--[[
 * @brief 精确定量排消解器溶液到废液桶。
 * @details 以精确定量的方法抽取消解器溶液到定量管，再排到废液桶,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值时，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] vol 溶液体积。
 * @param[in] point 定量点序号
--]]
function Operator:MeterFromDigestionRoom(vol, point, wType)

    local source = setting.liquidType.digestionRoom

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

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor * 0.5)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.meterSpeed * factor * 0.5))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:AutoMeterVolumeAnalyse(vol)
        if not ret then
            log:warn("MeterFromDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = setting.liquidType.digestionRoom,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("MeterFromDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = setting.liquidType.digestionRoom,})
        end
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Accurate, setting.liquid.accurateMeterOverValue)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                                self:Meter(MeterMode.Accurate, setting.liquidType.digestionRoom, volume, RollDirection.Suck)
                                self:DrainToWaste(volume, wasteType)

                                failedCnt = 0
                                overflowCnt = 0
                                unfinishedCnt = 0
                                airBubbleCnt = 0
                                timeoutCnt = 0
                            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What())
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, 0)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterExpectTimeoutException:new{liquidType = setting.liquidType.digestionRoom,})
                        end
                    else
                        error(result)
                    end
                elseif type(result) == "table" then
                    if getmetatable(result) == MeterFailedException then
                        failedCnt = failedCnt +1
                        log:warn(result:What())
                        if (failedCnt > 0) and (failedCnt < meterFailedReTry) then
                            self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, 0)
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = setting.liquidType.digestionRoom,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, 0)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = setting.liquidType.digestionRoom,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, 0)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = setting.liquidType.digestionRoom,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:Drain(setting.liquidType.digestionRoom, volume + setting.liquid.digestionRoomPipeVolume, 0)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
                            local e = MeterAirBubbleException:new{liquidType = setting.liquidType.digestionRoom,}
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
            else    --函数调用正常
                break
            end
        end
    end
end

--[[
 * @brief 排管道中的溶液。
 * @details 排空水样管。
 * @param[in] source 管道类型。
 * @param[in] vol 溶液体积。
--]]

function Operator:DrainLiquid(source, vol, wType)
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    self:DrainToWaste(0, wasteType)		--先将定量管至废液桶之间的多联阀管路清空
    self:Drain(source, vol, drainSpeed)	--隔离相应试剂管路
end

--[[
 * @brief 清洗消解室。
 * @details 抽取清洗液到定量管，再压到消解器，进行消解室及相关管路清洗。
 * @param[in] source 清洗液类型。
 * @param[in] vol 清洗液体积。
--]]

function Operator:CleanDigestionRoom(source, vol, wType)

    --废液类型
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end

    local err,result = pcall(function()
        -- 从定量管排液到废液桶
        self:DrainToWaste(setting.liquid.meterPipeVolume);
        --  排消解器溶液到废液桶
        self:DrainFromDigestionRoom();
        -- 加清洗液到消解室
        self:PumpToDigestionRoom(source, vol);
        -- 先将定量管至废液桶之间的多联阀管路清空
        self:DrainToWaste(0, wasteType);
        --冒泡
        self:AirToDigestionRoom();
        --逐出室剩余的溶液排到废液桶
        self:DrainFromDigestionRoom(wasteType);
    end)
    if not err then -- 出现异常
        error(result)
    end


end


--[[
 * @brief 清洗定量管。
 * @details 抽取清洗液到定量管，再排到废液桶，清洗定量管及相关管路,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 清洗液类型。
 * @param[in] vol 清洗液体积。
 * @param[in] point 定量点序号。
--]]

function Operator:CleanMeterPipe(source, vol, point, wType)
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
    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:MeterVolumeAnalyse(vol)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                                self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                		        self:DrainToWaste(volume + setting.liquid.multipleValvePipeVolume  + setting.liquid.wastePipeVolume, wasteType)

                                failedCnt = 0
                                overflowCnt = 0
                                unfinishedCnt = 0
                                airBubbleCnt = 0
                                timeoutCnt = 0
                            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What());
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end

    self:SecludeLiquid(source)
end

function Operator:CoverMeterPipe(source, vol, overVol, point, wType)
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
    local wasteType = WasteType.WasteReagent
    if wType == WasteType.WasteWater or wType == setting.liquidType.wasteWater then
        wasteType = WasteType.WasteWater
    end
    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    local overlVolume = 0.6
    if overVol <= overlVolume then
        overlVolume = overVol
    end

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:MeterVolumeAnalyse(vol)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                --self:Pump(source,  overlVolume, drainSpeed);
                --self:DrainToWaste(volume, wasteType)

                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What());
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end

    --self:SecludeLiquid(source)
end

--[[
 * @brief 用于TOC定量管润洗。
 * @details 抽取清洗液到定量管，再排到废液桶，清洗定量管及相关管路,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 清洗液类型。
 * @param[in] vol 清洗液体积。
 * @param[in] point 定量点序号。
--]]

function Operator:RinseMeterPipe(source, vol, point, wType)
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
    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor / 3)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor / 3))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:MeterVolumeAnalyse(vol)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                if math.abs(volume - config.hardwareConfig.meterPoint.point[1].realVolume) < 0.0001 then
                    self:Pump(source, 1, setting.liquid.drainSpeed * factor / 3)
                end
                --self:DrainToWaste(volume + setting.liquid.multipleValvePipeVolume  + setting.liquid.wastePipeVolume, wasteType)
                self:Drain(setting.liquidType.wasteWater, volume+ setting.liquid.multipleValvePipeVolume  + setting.liquid.wastePipeVolume,drainSpeed/3)

                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What());
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end

    self:SecludeLiquid(source)
end

--[[
 * @brief 用于TOC定量管润洗。
 * @details 抽取清洗液到定量管，再排到废液桶，清洗定量管及相关管路,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 清洗液类型。
 * @param[in] vol 清洗液体积。
 * @param[in] point 定量点序号。
--]]

function Operator:RinseMeterPipeWithSuck(source, vol, point, wType)
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
    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:MeterVolumeAnalyse(vol)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                if  math.abs(config.hardwareConfig.meterPoint.point[1].setVolume - volume) < 0.0001 then
                    self:Meter(MeterMode.Smart, source, config.hardwareConfig.meterPoint.point[1].setVolume + 0.5, RollDirection.Suck)
                    --self:Drain(setting.liquidType.none, 0.5, setting.liquid.meterSpeed * factor / 3)
                else
                    self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                end
                self:Drain(setting.liquidType.wasteWater, volume + setting.liquid.multipleValvePipeVolume+ setting.liquid.wasteWaterPipeVolume, drainSpeed)
                self:Pump(setting.liquidType.digestionRoom, 1, setting.liquid.meterSpeed * factor /2)
                self:Drain(setting.liquidType.wasteWater, setting.liquid.multipleValvePipeVolume + 1, setting.liquid.meterSpeed * factor / 3)

                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What());
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end
end

--[[
 * @brief 清洗定量管。
 * @details 强制使用某定量点抽取清洗液到定量管，再排到废液桶，清洗定量管及相关管路,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 清洗液类型。
 * @param[in] vol 清洗液体积。
 * @param[in] point 抽液使用的定量点。
 * @param[in] wType 目的排液管路。
--]]

function Operator:CleanMeterPipeToPoint(source, vol, point, wType)
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
    local wasteType = WasteType.WasteReagent
    if wType == WasteType.WasteWater or wType == setting.liquidType.wasteWater then
        wasteType = WasteType.WasteWater
    end

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret,volTable = self:ForceMeterVolumeAnalyseByPoint(vol, point)
    if not ret then
        log:warn("PumpToDigestion 体积分解异常")
        error (MeterFailedException:new{liquidType = source,})
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                                self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                		self:DrainToWaste(volume, wasteType)

                                failedCnt = 0
                                overflowCnt = 0
                                unfinishedCnt = 0
                                airBubbleCnt = 0
                                timeoutCnt = 0
                            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What());
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:Drain(source, volume*0.5, drainSpeed)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:Drain(source, volume*0.5, drainSpeed)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:Drain(source, volume*0.5, drainSpeed)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end

    self:SecludeLiquid(source)
end


--[[
 * @brief 清洗试剂管路
 * @details 抽取清洗液到定量管，再排到目标试剂管路,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 清洗液类型。
 * @param[in] dest 目标管路。
 * @param[in] vol 清洗液体积。
 * @param[in] point 定量点序号。
--]]
function Operator:CleanReagentPipe(source, dest, vol, point)
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

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:MeterVolumeAnalyse(vol)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    --排空管路
    self:DrainToWaste(0)

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    --加清洗液冲洗目标管路
    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                self:Drain(dest, volume + setting.liquid.multipleValvePipeVolume, drainSpeed)

                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What());
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:Drain(source, volume*0.5, drainSpeed)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume)
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
                            self:DrainToWaste(volume)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:Drain(source, volume*0.5, drainSpeed)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:Drain(source, volume*0.5, drainSpeed)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume)
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
            else    --函数调用正常
                break
            end
        end
    end

    --隔离管路
    self:SecludeLiquid(source)
end


--[[
 * @brief 清空试剂管的试剂。
 * @details 抽取试剂管路的试剂，用于清空试剂管的旧试剂，
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 清洗液类型。
 * @param[in] vol 清洗液体积。
--]]

function Operator:ClearReagentPipe(source, vol)
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

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local volTable= {}
    local MeterPoint1Vol=  config.hardwareConfig.meterPoint.point[2].setVolume
    local MeterPoint0Vol= config.hardwareConfig.meterPoint.point[1].setVolume

    local count = math.floor(vol/MeterPoint1Vol)  --倍数
    local residue = vol - count * MeterPoint1Vol	-- 余量

    for i=1, count do
        table.insert(volTable, MeterPoint1Vol)
    end

    if residue > 0.1 then
        table.insert(volTable, residue)
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                
                            self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                            self:DrainToWaste(volume)

                            failedCnt = 0
                            overflowCnt = 0
                            unfinishedCnt = 0
                            airBubbleCnt = 0
                            timeoutCnt = 0
                        end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What())
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            if source == setting.liquidType.reagent2 then
                                self:Drain(source, volume*0.8, drainSpeed)
                                self:DrainToWaste(volume*0.2);
                                self:Meter(MeterMode.Smart, setting.liquidType.blank, MeterPoint1Vol, RollDirection.Suck)
                                self:DrainToWaste(MeterPoint1Vol)
                            else
                                self:Drain(source, volume*0.5, drainSpeed)
                            end
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume)
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
                            self:DrainToWaste(volume)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume)
                            if source == setting.liquidType.reagent2 then
                                self:Meter(MeterMode.Smart, setting.liquidType.blank, MeterPoint1Vol, RollDirection.Suck)
                                self:DrainToWaste(MeterPoint1Vol)
                            end
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            if source == setting.liquidType.reagent2 then
                                self:Drain(source, volume*0.8, drainSpeed)
                                self:DrainToWaste(volume*0.2);
                                self:Meter(MeterMode.Smart, setting.liquidType.blank, MeterPoint1Vol, RollDirection.Suck)
                                self:DrainToWaste(MeterPoint1Vol)
                            else
                                self:Drain(source, volume*0.5, drainSpeed)
                            end
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            if source == setting.liquidType. reagent2 then
                                self:Drain(source, volume*0.8, drainSpeed)
                                self:DrainToWaste(volume*0.2);
                                self:Meter(MeterMode.Smart, setting.liquidType.blank, MeterPoint1Vol, RollDirection.Suck)
                                self:DrainToWaste(MeterPoint1Vol)
                            else
                                self:Drain(source, volume*0.5, drainSpeed)
                            end
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume)
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
            else    --函数调用正常
                break
            end
        end
    end

    self:SecludeLiquid(source)
end

--[[
 * @brief 定量溶液体积解析。
 * @details 用于智能时，对操作溶液体积根据定量管
 * @details 的定量点分解为单次操作的体积列表。
* @param[in] volVector 单次操作的体积列表。
 * @param[in] vol 溶液总体积。
--]]
function Operator:MeterVolumeAnalyse(vol)
    local pointNum = config.hardwareConfig.meterPoint.num
    local maxMP=  config.hardwareConfig.meterPoint.point[pointNum].setVolume
    local minMP= config.hardwareConfig.meterPoint.point[1].setVolume

    local count = math.floor(vol/maxMP)  --倍数
    local residue = vol - count * maxMP	-- 余量
    local lDV = residue - minMP                -- 将余量跟最少定量点比较
    local sDV = residue - minMP * 0.001    -- 将余量跟最少定量点的千分之一比较

    local volTable= {}

    if count == 0 then
        table.insert(volTable, residue)
    elseif count > 0 then
        if (-self.PRECISE <= residue) and (residue <= self.PRECISE) then --余量等于0
            for i=1, count do
                table.insert(volTable, maxMP)
            end
        elseif -self.PRECISE <= lDV  then  -- 余量大于最小定量点
            for i=1, count do
                table.insert(volTable, maxMP)
            end

            table.insert(volTable, residue)
        else     -- 余量小于最小定量点
            if -self.PRECISE <= sDV then--余量大于最小定量点的千分之一
                local num = 0

                for i=1, count do
                    num = num + 1
                    if (maxMP * num + residue)/2 - minMP >= self.PRECISE then
                        break
                    end
                end

                if (count -num) == 0 then
                    table.insert(volTable, minMP)
                    table.insert(volTable, vol - minMP)
                else
                    for i=1, (count -num) do
                        table.insert(volTable, maxMP)
                    end

                    table.insert(volTable, (maxMP * num + residue)/2)
                    table.insert(volTable, (maxMP * num + residue)/2)
                end
            else    -- 余量小于最小定量点的千分之一
                for i=1, count do
                    table.insert(volTable, maxMP)
                end
            end
        end
    end

    if not volTable[1] then
        return false, volTable
    end

    return true, volTable
end

--[[
 * @brief 自动定量溶液体积解析。
 * @details 用于精确定量时，对定量体积根据定量管的
 * @details 定量点分解为单次操作的体积列表。
 * @param[in] vol 溶液总体积。
--]]
function Operator:AutoMeterVolumeAnalyse(vol)
    local ret = false
    local mpTable = {}
    local pointNum = config.hardwareConfig.meterPoint.num
    for i = 1,pointNum do
        mpTable[i] = config.hardwareConfig.meterPoint.point[1 + pointNum - i].setVolume
    end
    local volTable = {}
    local leftVol = vol

    --print("Volume = "..vol)
    for k = 1,pointNum do
        --print("Prior use "..mpTable[k].."*****************")
        for i = k,pointNum do
            while leftVol > mpTable[i] - self.PRECISE and leftVol > 0 do
                table.insert(volTable, mpTable[i])
                leftVol = leftVol - mpTable[i]
                if math.abs(leftVol) < self.PRECISE then
                    ret = true
                    break
                end
            end
            if ret then
                break
            end
        end
        if ret then
            break
        else
            volTable = {}
            leftVol = vol
        end
    end

    if not ret then
        log:warn("自动分解定量体积不是定量点体积的倍数")
    end

    --for i in pairs(volTable) do print(volTable[i]) end
    return ret, volTable
end

--[[
 * @brief 精确定量溶液体积解析。
 * @details 用于精确定量时，对定量体积根据定量管的
 * @details 定量点分解为单次操作的体积列表。
 * @param[in] volVector 单次操作的体积列表。
 * @param[in] vol 溶液总体积。
 * @point[in] vol 定量点序号。
--]]
function Operator:AccurateMeterVolumeAnalyse(vol, point)
    local ret = false
    local volTable= {}

    local MP = 0
    if point >=1 and point <= config.hardwareConfig.meterPoint.num then
        MP = config.hardwareConfig.meterPoint.point[point].setVolume
    else
        log:warn("无效的定量点");
    end

    if (vol - MP > self.PRECISE) or ((-self.PRECISE <= vol - MP) and (vol - MP <= self.PRECISE)) then

        local count = math.floor(vol/MP)  --倍数
        local residue = vol - count * MP	-- 余量

        if (-self.PRECISE <= residue) and (residue <= self.PRECISE) then
            for i=1, count do
                table.insert(volTable, MP)
            end

            ret = true
        else
            log:warn("精确定量体积不是定量点体积的倍数");
        end
    else
        log:warn("精确定量体积小于定量点体积");
    end

    return ret, volTable
end

--[[
 * @brief 强制使用某定量点解析溶液体积。
 * @details 用于特定情形时，对定量体积根据定量管的
 * @details 定量点分解为单次操作的体积列表。
 * @param[in] vol 溶液总体积。
 * @param[in] point 使用的定量点
 * @return volTable 单次操作的体积列表。
--]]
function Operator:ForceMeterVolumeAnalyseByPoint(vol, point)

    local ret = false
    local unitVolume = config.hardwareConfig.meterPoint.point[point].setVolume
    local volTable = {}
    local leftVol = vol
    
    if vol > unitVolume - self.PRECISE and vol % unitVolume < self.PRECISE then    
        while leftVol > unitVolume - self.PRECISE and leftVol > 0 do
            table.insert(volTable, unitVolume)
            leftVol = leftVol - unitVolume
            if math.abs(leftVol) < self.PRECISE then
                ret = true
                break
            end
        end
    end
    
    if not ret then
        volTable = {}
        leftVol = vol
        log:warn("强制分解定量体积不是定量点体积的倍数")
    end
    --for i in pairs(volTable) do print(volTable[i]) end
    return ret, volTable
end

--[[
 * @brief 恒温控制
 * @details 恒温至目标温度
 * @param[in] mode 恒温模式,
 * @param[in] targetTemp 目标温度,
 * @param[in] tolerance 容差温度,
 * @param[in] timeout 超时时间,
--]]
function Operator:StartThermostat(mode, targetTemp, tolerance, timeout)

        dc:ClearThermostatRemainEvent()  --清空所有事件

        local temp = 0

        local curHeaterMaxDutyCycle = self.ITemperatureControl:GetHeaterMaxDutyCycle()
        if math.abs(config.measureParam.heaterMaxDutyCycle - curHeaterMaxDutyCycle) > self.PRECISE then
            self.ITemperatureControl:SetHeaterMaxDutyCycle(config.measureParam.heaterMaxDutyCycle)
            self:debugPrintf("重设加热丝占空比 "..self.ITemperatureControl:GetHeaterMaxDutyCycle())
        end

        local ret = self.ITemperatureControl:StartThermostat(mode, targetTemp, tolerance, timeout)

        --获取恒温器状态
        if ret == false then
            self:debugPrintf("StartThermostat return ret[",ret, "]!!!")
            
            App.Sleep(100);
            if self.ITemperatureControl:GetThermostatStatus() == 2 then
                ret = true
            end
        end

        if ret == true then

                self:debugPrintf("{StartThermostat} mode = " .. mode .. ", targetTemp = " .. targetTemp .. ", tolerance = " .. tolerance ..", timeout = " .. timeout)
                self.isThermostat = true

                local result = self.ITemperatureControl:ExpectThermostat(timeout * 1000 + 1000);

                self:debugPrintf("{thermostatResult} result = " .. result:GetResult() .. "，temp = " .. result:GetTemp())

                if result:GetResult() == ThermostatOperateResult.Failed then
                    self.isThermostat = false
                    error(ThermostatFailedException:new({mode = mode, targetTemp = targetTemp, toleranceTemp = tolerance, timeout = timeout}))
                elseif result:GetResult() == ThermostatOperateResult.Stopped then
                    self.isThermostat = false
                    error(ThermostatStoppedException:new({mode = mode, targetTemp = targetTemp, toleranceTemp = tolerance, timeout = timeout}))
                elseif result:GetResult() == ThermostatOperateResult.Timeout then
                    self.isThermostat = false
                    error(ThermostatTimeoutException:new({mode = mode, targetTemp = targetTemp, toleranceTemp = tolerance, timeout = timeout}))
                elseif result:GetResult() == ThermostatOperateResult.Reached then
                    self.isThermostat = false
                    temp = result:GetTemp() --返回温度
                end
        end

        return temp
end

--[[
 * @brief 停止恒温控制.
--]]
function Operator:StopThermostat()
       local temp = 0


       local ret = false
        if self.ITemperatureControl:GetThermostatStatus() == 2 then
            ret = self.ITemperatureControl:StopThermostat()
        else
            return ret
        end

        --获取恒温器状态
        if ret == false then
            self:debugPrintf("StopThermostat return ret[",ret, "]!!!")

            local cnt = 5
            while true do
                App.Sleep(100)

                if self.ITemperatureControl:GetThermostatStatus() == 1 then
                    ret = true
                    break
                end

                cnt = cnt -1
                if cnt <= 0 then
                    break
                end
            end
        end

        if ret == true then
                self:debugPrintf("{StopThermostat}")

                local result = self.ITemperatureControl:ExpectThermostat(2000)
                temp  = result:GetTemp()

                self:debugPrintf("{thermostatResult} result = " .. result:GetResult() .. "，temp = " .. result:GetTemp())

                if result:GetResult() == ThermostatOperateResult.Stopped then
                    self.isThermostat = false
                end
        end

        return temp
end

--[[
 * @brief 停止恒温控制.
--]]
function Operator:StopExtThermostat(index)
    local temp = 0

    local ret = false
    if self.IExtTemperatureControl:GetThermostatStatus(index) == 2 then
        ret = self.IExtTemperatureControl:StopThermostat(index, true)
    else
        return ret
    end

    --获取恒温器状态
    if ret == false then
        self:debugPrintf("StopExtThermostat return ret[",ret, "]!!!")

        local cnt = 5
        while true do
            App.Sleep(100)

            if self.IExtTemperatureControl:GetThermostatStatus(index) == 2 then
                ret = true
                break
            end

            cnt = cnt -1
            if cnt <= 0 then
                break
            end
        end
    end

    if ret == true then
        self:debugPrintf("{StopThermostat}")

        local result = self.IExtTemperatureControl:ExpectThermostat(2000)
        temp  = result:GetTemp()

        self:debugPrintf("{thermostatResult} result = " .. result:GetResult() .. "，temp = " .. result:GetTemp())

        if result:GetResult() == ThermostatOperateResult.Stopped then
            self.isThermostat = false
        end
    end

    return temp
end

--[[
 * @brief 修改恒温温度参数
  * @details 恒温至目标温度，不等待事件
   * @param[in] index 恒温器索引，0 - 燃烧炉， 1 - 制冷器
 * @param[in] mode 恒温模式,仅支持Refrigerate， Heater
 * @param[in] targetTemp 目标温度,
 * @param[in] tolerance 容差温度,
 * @param[in] timeout 超时时间,
--]]
function Operator:ReviseThermostatTemp(index, mode, targetTemp, tolerance, timeout)

    dc:ClearThermostatRemainEvent()  --清空所有事件

    local temp = 0
    local flowManager = FlowManager.Instance()

    if flowManager:IsComValid() ~= true then
        log:warn("通信失败，修改恒温温度参数无效")
        return false
    end

    log:debug("Thermostat index: ".. index)

    if mode == ThermostatMode.Auto then
        log:warn("设备不支持自动恒温模式")
        return false
    end

    if index ~= setting.temperature.indexStove then
        op:StopExtThermostat(index)
    else
        op:StopThermostat()
    end


    --通讯成功情况下修改各恒温器参数
    if index == setting.temperature.indexStove then
        config.measureParam.lastReactTemperature = config.measureParam.reactTemperature
        targetTemp = config.measureParam.reactTemperature
        --setting.temperature.isOpenTempMonitor = true
        StatusManager.Instance():SetTemperature(config.measureParam.reactTemperature)
    elseif index == setting.temperature.indexRefrigerator then
        config.measureParam.lastCoolTemperature = config.measureParam.coolTemperature
        targetTemp = config.measureParam.coolTemperature
    else
        config.measureParam.lastMeasureModuleTemperature = config.measureParam.measureModuleTemperature
        targetTemp = config.measureParam.measureModuleTemperature
        local temp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
        local setCycle = 0.7
        --if config.measureParam.measureModuleTemperature - temp <= 2 then
        --    setCycle = 0.5
        --end
        local curHeaterMaxDutyCycle = self.IExtTemperatureControl:GetHeaterMaxDutyCycle(2)
        if math.abs(setCycle - curHeaterMaxDutyCycle) > self.PRECISE then
            self.IExtTemperatureControl:SetHeaterMaxDutyCycle(2, setCycle)
            self:debugPrintf("重设加热丝占空比 "..self.IExtTemperatureControl:GetHeaterMaxDutyCycle(2))
        end
    end

    local ret = self.ITemperatureControl:ReviseThermostatTemp(index, mode, targetTemp, tolerance, timeout)

    ----获取恒温器状态
    if ret == false then
        local str
        if index == setting.temperature.indexRefrigerator then
            log:info("制冷器调节异常")
            str = "制冷器调节异常"
        elseif index == setting.temperature.indexNDIR then
            log:info("测量模块调节异常")
            str = "测量模块调节异常"
        else
            log:info("燃烧炉调节异常")
            str = "燃烧炉调节异常"
        end

        App.Sleep(500);
        if self.ITemperatureControl:GetThermostatStatus() == 2 then
            log:debug("StartThermostat ok ")
            ret = true
        else
            log:debug("StartThermostat failed ")
            log:info("恒温调节失败，重设温度")
            self.ITemperatureControl:ReviseThermostatTemp(index, mode, targetTemp, tolerance, timeout)
            --local alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, str)
            --AlarmManager.Instance():AddAlarm(alarm)
        end
    end

    if ret == true then

        log:debug("{ReviseThermostat} index = " .. index .. ", mode = " .. mode .. ", targetTemp = " .. targetTemp .. ", tolerance = " .. tolerance ..", timeout = " .. timeout)
        self.isThermostat = true

        --local result = self.ITemperatureControl:ExpectThermostat(timeout * 1000 + 1000);
        --
        --self:debugPrintf("{thermostatResult} result = " .. result:GetResult() .. "，temp = " .. result:GetTemp())
        --
        --if result:GetResult() == ThermostatOperateResult.Failed then
        --    self.isThermostat = false
        --    error(ThermostatFailedException:new({mode = mode, targetTemp = targetTemp, toleranceTemp = tolerance, timeout = timeout}))
        --elseif result:GetResult() == ThermostatOperateResult.Stopped then
        --    self.isThermostat = false
        --    error(ThermostatStoppedException:new({mode = mode, targetTemp = targetTemp, toleranceTemp = tolerance, timeout = timeout}))
        --elseif result:GetResult() == ThermostatOperateResult.Timeout then
        --    self.isThermostat = false
        --    error(ThermostatTimeoutException:new({mode = mode, targetTemp = targetTemp, toleranceTemp = tolerance, timeout = timeout}))
        --elseif result:GetResult() == ThermostatOperateResult.Reached then
        --    self.isThermostat = false
        --    temp = result:GetTemp() --返回温度
        --end
    end

    return ret
end

--[[
 * @brief 检查消解室温度安全
 * @details 当消解室温度高于安全温度时，启动降温操作.
--]]
function Operator:CheckDigestSafety(update)

    local safeTemp = setting.temperature.reactTemperatureLimitTop
    local startTime = os.time()

    local  thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
    local refrigeratorTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
    local NDIRTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
    self:debugPrintf("安全冷却前燃烧炉温度 = " .. thermostatTemp .. " ℃");
    self:debugPrintf("安全冷却前制冷器温度 = " .. refrigeratorTemp .. " ℃");
    self:debugPrintf("安全冷却前测量池温度 = " .. NDIRTemp .. " ℃");

    if update ~= nil then
        setting.temperature.monitor.stoveLastTemperature = thermostatTemp
        setting.temperature.monitor.stoveAbnormalTemperature = thermostatTemp
        setting.temperature.monitor.refrigeratorLastTemperature = refrigeratorTemp
        setting.temperature.monitor.refrigeratorAbnormalTemperature = refrigeratorTemp
        setting.temperature.monitor.NDIRLastTemperature = NDIRTemp
        setting.temperature.monitor.NDIRAbnormalTemperature = NDIRTemp
    end


    local temp = thermostatTemp - safeTemp

    if  temp >  0.01 then
        --状态设置
        if StatusManager.Instance():IsIdleStatus() == true then
                local runStatus = Helper.Status.SetStatus(setting.runStatus.digestCooling)
                StatusManager.Instance():SetStatus(runStatus)
        end

        --动作设置
        local runAction = Helper.Status.SetAction(setting.runAction.digestCooling)
        StatusManager.Instance():SetAction(runAction)

         --开机箱风扇
        --self.ITemperatureControl:BoxFanSetOutput(1)

        --冷却
        local cnt = 0
        while true do
            --获取恒温器状态
            if self.ITemperatureControl:GetThermostatStatus() == 2 then
                    self:StopThermostat()
            end

            --local err,result = pcall(function()
            --
            --                     return self:StartThermostat(ThermostatMode.Refrigerate, safeTemp, 1, setting.temperature.digestToReactCoolingTimeout)
            --                   end)-----end pcall
            --if not err then      -- 出现异常
            --    if type(result) == "userdata" then
            --        ExceptionHandler.MakeAlarm(result)
            --    elseif type(result) == "table" then
            --        if getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
            --            self:StopThermostat()
            --            self.ITemperatureControl:BoxFanSetOutput(0) 	--关机箱风扇
            --            error(result)
            --        else
            --            ExceptionHandler.MakeAlarm(result)
            --        end
            --    else
            --        log:warn(result)										--C++、Lua系统异常
            --    end
            --end

            thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
            temp = thermostatTemp - safeTemp
            if  temp >  2 then
                self:debugPrintf("安全温度未达标")
                cnt = cnt + 1
                if cnt >= 3 then
                    break
                end
            else
                break
            end
        end

        --获取恒温器状态
        if self.ITemperatureControl:GetThermostatStatus() == 2 then
                self:StopThermostat()
        end

        self:debugPrintf("到达安全冷却目标温度 = ".. thermostatTemp .. " ℃" )
        self:debugPrintf("消解室冷却总时间 = " .. os.time() - startTime)
    end
end

--[[
 * @brief
 * @details
 * @index 索引值 0-燃烧炉 ；1-制冷器；2-测量模块
 * @temperature 两次温度监测的温差，通过当前温度以及温差变化范围判断恒温器是否正常工作，若两次监测温差无明显变化且当前温度不在设定值范围内则认为该恒温器失效
 * @tolerance 容差温度，判断恒温器当前温度是否在设定值范围内
--]]
function Operator:CheckThermostat(index, temperature, tolerance)

    local ret = true
    local currentTemp
    local toleranceTemp = temperature

    if index == setting.temperature.indexStove then
        currentTemp = dc:GetDigestTemperature()
        print("stove: " .. currentTemp .. ", " .. setting.temperature.monitor.stoveLastTemperature)
        if currentTemp <= 150 then
            return true
        elseif currentTemp <= 300 then
            toleranceTemp = toleranceTemp*0.5
        end
        if math.abs(currentTemp - setting.temperature.monitor.stoveLastTemperature) < temperature
            and math.abs(currentTemp - config.measureParam.reactTemperature) > tolerance then
            if setting.temperature.monitor.stoveAlarm == false then
                log:warn("燃烧炉温度异常： 当前温度 " .. currentTemp .. ", 30秒前温度 " .. setting.temperature.monitor.stoveLastTemperature)
                local alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, "燃烧炉温度变化异常")
                AlarmManager.Instance():AddAlarm(alarm)
                setting.temperature.monitor.stoveAlarm = true
                op:StopThermostat()
                --dc:GetITemperatureControl():RelayControlForTOC(0)
                print("stop stove")
            end
            ret = false
        end
        setting.temperature.monitor.stoveLastTemperature = currentTemp
    elseif index == setting.temperature.indexRefrigerator then
        currentTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
        print("refrigerator: " .. currentTemp .. ", " .. setting.temperature.monitor.refrigeratorLastTemperature)
        if math.abs(currentTemp - setting.temperature.monitor.refrigeratorLastTemperature) < temperature
            and math.abs(currentTemp - config.measureParam.coolTemperature) > tolerance then
            if setting.temperature.monitor.refrigeratorAlarm == false then
                log:warn("制冷器温度异常： 当前温度 " .. currentTemp .. ", 2分钟前温度 " .. setting.temperature.monitor.refrigeratorLastTemperature)
                local alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, "制冷器温度变化异常")
                AlarmManager.Instance():AddAlarm(alarm)
                setting.temperature.monitor.refrigeratorAlarm = true
                op:StopExtThermostat(index)
                print("stop refrigerator")
            end
            ret = false

        end
        setting.temperature.monitor.refrigeratorLastTemperature = currentTemp
    else
        currentTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
        print("NDIR: " .. currentTemp .. ", " .. setting.temperature.monitor.NDIRLastTemperature)
        if config.measureParam.measureModuleTemperature <= 30 then
            return true
        end
        if math.abs(currentTemp - setting.temperature.monitor.NDIRLastTemperature) < temperature
            and math.abs(currentTemp - config.measureParam.measureModuleTemperature) > tolerance then
            if setting.temperature.monitor.NDIRAlarm  == false then
                log:warn("测量模块温度异常： 当前温度 " .. currentTemp .. ", 2分钟前温度 " .. setting.temperature.monitor.NDIRLastTemperature)
                local alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, "测量模块温度变化异常")
                AlarmManager.Instance():AddAlarm(alarm)
                setting.temperature.monitor.NDIRAlarm = true
                op:StopExtThermostat(index)
                print("stop NDIR")
            end
            ret = false
        end
        setting.temperature.monitor.NDIRLastTemperature = currentTemp
    end

    return ret
end

--[[
 * @brief
 * @details
 * @index 索引值 0-燃烧炉 ；1-制冷器；2-测量模块
 * @temperature 5秒内温度监测的温差，若温差波动异常
 * @tolerance 容差温度，判断恒温器当前温度是否在设定值范围内
--]]
function Operator:IsTemperatureAbnormal(index, temperature)

    local ret = true
    local currentTemp

    if index == setting.temperature.indexStove then
        currentTemp = dc:GetDigestTemperature()
        if setting.temperature.monitor.stoveAbnormalTemperature == 0 then
            setting.temperature.monitor.stoveAbnormalTemperature = currentTemp
        end
        --print("stove: " .. currentTemp .. ", " .. setting.temperature.monitor.stoveAbnormalTemperature)
        if math.abs(currentTemp - setting.temperature.monitor.stoveAbnormalTemperature) >= temperature then
            if setting.temperature.monitor.stoveAlarm == false then
                log:warn("燃烧炉温度异常： 当前温度 " .. currentTemp .. ", 5秒前温度 " .. setting.temperature.monitor.stoveAbnormalTemperature)
                local alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, "燃烧炉温度变化异常")
                AlarmManager.Instance():AddAlarm(alarm)
                setting.temperature.monitor.stoveAlarm = true
                op:StopThermostat()
                --dc:GetITemperatureControl():RelayControlForTOC(0)
                --print("stop stove")
            end
            ret = false
        end
        setting.temperature.monitor.stoveAbnormalTemperature = currentTemp
    elseif index == setting.temperature.indexRefrigerator then
        currentTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
        if setting.temperature.monitor.refrigeratorAbnormalTemperature == 0 then
            setting.temperature.monitor.refrigeratorAbnormalTemperature = currentTemp
        end
        --print("refrigerator: " .. currentTemp .. ", " .. setting.temperature.monitor.refrigeratorAbnormalTemperature)
        if math.abs(currentTemp - setting.temperature.monitor.refrigeratorAbnormalTemperature) >= temperature then
            if setting.temperature.monitor.refrigeratorAlarm == false then
                log:warn("制冷器温度异常： 当前温度 " .. currentTemp .. ", 5秒前温度 " .. setting.temperature.monitor.refrigeratorAbnormalTemperature)
                local alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, "制冷器温度变化异常")
                AlarmManager.Instance():AddAlarm(alarm)
                setting.temperature.monitor.refrigeratorAlarm = true
                op:StopExtThermostat(index)
                --print("stop refrigerator")
            end
            ret = false

        end
        setting.temperature.monitor.refrigeratorAbnormalTemperature = currentTemp
    else
        currentTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
        if setting.temperature.monitor.NDIRAbnormalTemperature == 0 then
            setting.temperature.monitor.NDIRAbnormalTemperature = currentTemp
        end
        --print("NDIR: " .. currentTemp .. ", " .. setting.temperature.monitor.NDIRAbnormalTemperature)
        if math.abs(currentTemp - setting.temperature.monitor.NDIRAbnormalTemperature) >= temperature then
            if setting.temperature.monitor.NDIRAlarm  == false then
                log:warn("测量模块温度异常： 当前温度 " .. currentTemp .. ", 5秒前温度 " .. setting.temperature.monitor.NDIRAbnormalTemperature)
                local alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, "测量模块温度变化异常")
                AlarmManager.Instance():AddAlarm(alarm)
                setting.temperature.monitor.NDIRAlarm = true
                op:StopExtThermostat(index)
                --print("stop NDIR")
            end
            ret = false
        end
        setting.temperature.monitor.NDIRAbnormalTemperature = currentTemp
    end

    return ret
end

--[[
 * @brief 采集AD
 * @details 采集光学测量AD信号
 * @param[in] acquireTime 采集时间
--]]
function Operator:StartAcquirerAD(acquireTime)
    local AD = OpticalAD.new()
    local temp = 0

    local timeout = acquireTime * 1000 + 1000

    self.isAcquiring = true

    if self.IOpticalAcquire:StartAcquirer(acquireTime) == true then
        local err,result = pcall(function() return self.IOpticalAcquire:ExpectADAcquirer(timeout) end)
        if not err then -- 出现异常
            self.IOpticalAcquire:StopAcquirer() --停止采集
            self.isAcquiring = false
            error(result) --向上层抛异常
        else
            temp = result
            self.isAcquiring = false
            if result.GetResult ~= nil then  --新增采集错误结果码的版本
                if result:GetResult() == AcquiredOperateResult.Failed then
                    error (AcquirerADFailedException:new())
                elseif result:GetResult()  == AcquiredOperateResult.Stopped then
                    error (AcquirerADStoppedException:new())
                elseif result:GetResult()  == AcquiredOperateResult.Finished then
                    temp = result:GetAD()
                end
            end
            local refAD = temp:GetReference()
            local meaAD = temp:GetMeasure()
            AD:SetReference(refAD)
            AD:SetMeasure(meaAD)
        end
    end

    return AD
end

--[[
 * @brief 采集AD(带过滤数据)
 * @details 采集光学测量AD信号
 * @param[in] acquireTime 采集时间
--]]
function Operator:StartAcquirerADWithFiltration(acquireTime)
    local readAdTime = 1        --测量间隔
    local referenceAD = {}
    local measureAD = {}
    local temp = 0
    local referenceADSumData = 0
    local measureADSumData = 0
    local filterNum = 0

    filterNum = math.floor(acquireTime/5)

    local retAD = OpticalAD.new()
    local AD = op:StartAcquirerAD(readAdTime)

    -- 读取AD值
    for i = 1,acquireTime,readAdTime do
        AD = op:StartAcquirerAD(readAdTime)
        referenceAD[i] = AD:GetReference()
        measureAD[i] = AD:GetMeasure()
    end

    for i = 1,acquireTime,1 do
        log:debug("referenceAD["..i.."] = "..referenceAD[i].." measureAD["..i.."] = "..measureAD[i])
    end

    for i = 2, acquireTime, 1 do
        for j = acquireTime,i, -1 do
            if referenceAD[j] < referenceAD[j - 1] then
                temp = referenceAD[j - 1];
                referenceAD[j - 1] = referenceAD[j];
                referenceAD[j] = temp;
            end
            if measureAD[j] < measureAD[j - 1] then
                temp = measureAD[j - 1];
                measureAD[j - 1] = measureAD[j];
                measureAD[j] = temp;
            end
        end
    end

    for i = 1+filterNum,acquireTime-filterNum,1 do
        referenceADSumData = referenceADSumData + referenceAD[i]
        measureADSumData = measureADSumData + measureAD[i]
    end

    local ret1 = math.floor(referenceADSumData/(acquireTime - filterNum*2))
    local ret2 = math.floor(measureADSumData/(acquireTime - filterNum*2))

    retAD:SetReference(ret1)
    retAD:SetMeasure(ret2)

    return retAD
end

function Operator:AutoStaticADControl(index, target)
    local ret = false
    local timeout = 120 * 1000

    local ret = self.IOpticalAcquire:StartStaticADControl(index,target)

    if ret == true then
        self.isStaticADControl = true
        self:debugPrintf("Auto static AD control started index = "..index.." target = "..target)

        local result = self.IOpticalAcquire:ExpectStaticADControlResult(timeout)

        if result == StaticADControlResult.Unfinished then
            if self.isStaticADControl == true then
                self.isStaticADControl = false
                error (StaticADControlFailedException:new())
            elseif self.isStaticADControl == false then  --被停止
                error (StaticADControlStoppedException:new())
            end
            return false
        elseif result == StaticADControlResult.Finished then
            self.isStaticADControl = false
            self:debugPrintf("Auto static AD control index = "..index.." target = "..target.." finished !")
            return true
        end
    else
        self:debugPrintf("Auto static AD control index = "..index.." target = "..target.." start fail !")
        return false
    end
end

function Operator:AutoMeasureLEDControl(target, tolerance, timeout)
    local ret = false

    ret = self.IOpticalAcquire:StartLEDOnceAdjust(target, tolerance, timeout)

    if ret == true then
        self.isStaticADControl = true
        self:debugPrintf("Auto Measure LED control started ".." target = "..target.." tolerance = "..tolerance.." timeout = "..timeout)

        local result = self.IOpticalAcquire:ExpectLEDOnceAdjust(timeout)
        print("LED: " .. result)

        if result == 1 then  --AdjustResult.Failed
            if self.isStaticADControl == true then
                self.isStaticADControl = false
                error (MeasureLEDControlFailedException:new())
            elseif self.isStaticADControl == false then  --被停止
                error (MeasureLEDControlStoppedException:new())
            end
            return false
        elseif result == 0 then --AdjustResult.Finished
            self.isStaticADControl = false
            self:debugPrintf("Auto Measure LED control ".." target = "..target.." finished !")
            return true
        end
    else
        self:debugPrintf("Auto Measure LED control ".." target = "..target.." start fail !")
        return false
    end
end


function Operator:StopStaticADControl()
    local ret = false

    local ret = self.IOpticalAcquire:StopStaticADControl()

    if ret == true then
        self:debugPrintf("{Stop Static AD Control}")

        local result = self.IOpticalAcquire:ExpectStaticADControlResult(2000)

        self.isStaticADControl = false
    end
end

--[[
 * @brief 保存定标时间
 * @detail 将定标时间以String的形式保存
--]]
function Operator:SaveCalibrationTimeStr(CalibrationTime,currentRange)
    if CalibrationTime ~= nil then
        if CalibrationTime ~= 0 then
            local DataTime = os.date("*t",CalibrationTime)

            local year = tostring(DataTime.year)
            local month
            if DataTime.month <10 then
                month="0"..tostring(DataTime.month)
            else
                month=tostring(DataTime.month)
            end
            local day
            if DataTime.day <10 then
                day="0"..tostring(DataTime.day)
            else
                day=tostring(DataTime.day)
            end
            local hour
            if DataTime.hour <10 then
                hour="0"..tostring(DataTime.hour)
            else
                hour=tostring(DataTime.hour)
            end
            local min
            if DataTime.min <10 then
                min="0"..tostring(DataTime.min)
            else
                min=tostring(DataTime.min)
            end
            local sec
            if DataTime.sec <10 then
                sec="0"..tostring(DataTime.sec)
            else
                sec=tostring(DataTime.sec)
            end

            config.measureParam.curveParam[currentRange].timeStr = year.."-"..month.."-"..day.." "..hour..":"..min
        end
    end
end

function Operator:CalculateAbsorbance(curveK, curveB, consistency1, consistency2)
    local absorbance1, absorbance2
    absorbance2 = (curveK * consistency2 + curveB)
    absorbance1 = (curveK * consistency1 + curveB)
    return absorbance1, absorbance2
end

function Operator:SaveUserCurve(calibrateDateTime, curveK, curveB, absorbance0, absorbance1, consistency0, consistency1, runTime, rangeView)
    -- 保存校准结果
    --	print("Push calibrate result data to file.")
    local resultManager = ResultManager.Instance()
    local recordData = RecordData.new(resultManager:GetCalibrateRecordDataSize(setting.resultFileInfo.calibrateRecordFile[1].name))

    recordData:PushInt(calibrateDateTime) 			        -- 时间
    recordData:PushDouble(curveK)   				            --标线斜率K
    recordData:PushDouble(curveB)   				            --标线截距B

    recordData:PushFloat(absorbance0) 			            -- 零点反应峰面积
    recordData:PushFloat(consistency0) 			            -- 零点浓度
    recordData:PushFloat(0)		            	-- 零点第一次峰面积
    recordData:PushFloat(0)		            	-- 零点第二次峰面积
    recordData:PushFloat(0)		            	-- 零点第三次峰面积
    recordData:PushFloat(5)      	-- 零点初始制冷模块温度
    recordData:PushFloat(50) 		        -- 零点初始测量模块温度
    recordData:PushFloat(5) 	    -- 零点反应制冷模块温度
    recordData:PushFloat(50) 	            -- 零点反应测量模块温度
    recordData:PushFloat(680) 	    -- 零点初始值燃烧炉温度
    recordData:PushFloat(35) 	    -- 零点反应值上机箱温度
    recordData:PushFloat(35) 	-- 零点反应值下机箱温度
    recordData:PushFloat(680) 	    -- 零点反应值燃烧炉温度
    recordData:PushFloat(35) 	    -- 零点反应值上机箱温度
    recordData:PushFloat(35) 	-- 零点反应值下机箱温度

    recordData:PushFloat(absorbance1) 			                -- 标点峰面积
    recordData:PushFloat(consistency1) 		            	    -- 标点浓度
    recordData:PushFloat(0)		            	-- 标点第一次峰面积
    recordData:PushFloat(0)		            	-- 标点第二次峰面积
    recordData:PushFloat(0)                       -- 标点第三次峰面积
    recordData:PushFloat(5)      	-- 标点初始制冷模块温度
    recordData:PushFloat(50) 		-- 标点初始测量模块温度
    recordData:PushFloat(5) 	    -- 标点反应制冷模块温度
    recordData:PushFloat(50) 	    -- 标点反应测量模块温度
    recordData:PushFloat(680) 	    -- 标点初始值燃烧炉温度
    recordData:PushFloat(35) 	    -- 标点反应值上机箱温度
    recordData:PushFloat(35) 	    -- 标点反应值下机箱温度
    recordData:PushFloat(680) 	    -- 标点反应值燃烧炉温度
    recordData:PushFloat(35) 	    -- 标点反应值上机箱温度
    recordData:PushFloat(35) 	    -- 标点反应值下机箱温度

    recordData:PushFloat(1)					                    -- 曲线线性度R2
    recordData:PushInt(runTime) 	    -- 校准时长
    recordData:PushFloat(rangeView) --  量程

    resultManager:AddCalibrateRecordSlots(setting.resultFileInfo.calibrateRecordFile[1].name, recordData)


end

function Operator:GetCurveParam(currentCalibrate)
    local start = 1
    local num1 = string.find(currentCalibrate, "*")
    local num2 = string.find(currentCalibrate, "C")
    local len = string.len(currentCalibrate)
    local firstSymbol = string.sub(currentCalibrate,1,1)
    local firstSymbolValve = 1
    local secondSymbol = string.sub(currentCalibrate,num2+2,num2+2)
    local secondSymbolValve = 1

    if firstSymbol == "-" then
        firstSymbolValve = -1
        start = 2
    end

    if secondSymbol == "-" then
        secondSymbolValve = -1
    end

    local K = tonumber(string.sub(currentCalibrate,start,num1-2))*firstSymbolValve
    local B = tonumber(string.sub(currentCalibrate,num2+4,len))*secondSymbolValve

    --log:debug("k= "..K*firstSymbolValve)
    --log:debug("b= "..B*secondSymbolValve)
    --log:debug("len= "..len)

    return K,B
end

--[[
 * @brief 曝气，同时打开两路比例阀。
 * @param[in] source 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] speed 泵速，0为默认速度。
--]]
function Operator:Exposure(source, time)
    local ret = true
    local map = ValveMap.new(source.valve)

    log:debug("{Exposure}" .. " time:   " .. time )

    self:ExposureTurnOn()

    --等待曝气时间
    if not Measurer.flow:Wait(time) then
        --return false
        error(UserStopException:new())
    end
    --if not self:Wait(time) then
    --    error(UserStopException:new())
    --end

    self:ExposureTurnOff()

    map = nil
    --ReagentRemainManager.ReduceReagent(source, volume)
    return ret
end

--[[
 * @brief 清洗曝气，同时打开两路比例阀。
 * @param[in] source 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] speed 泵速，0为默认速度。
--]]
function Operator:ExposureTurnOn(pressure)
    local setPressure = config.measureParam.exposurePressure
    if pressure ~= nil and pressure < 100 then
        setPressure = pressure
    end
    dc:GetISolenoidValve():ProportionalValve_SetDACValue(setting.pressure.indexExposureValve, config.measureParam.exposureValveVoltage)
    log:debug("打开曝气比例阀： " ..  config.measureParam.exposureValveVoltage .. " V")

    local curmap = dc:GetISolenoidValve():GetValveMap():GetData()
    local map = ValveMap.new(curmap | setting.liquidType.map.valve4)
    log:debug("打开总阀")
    dc:GetISolenoidValve():SetValveMap(map)

    App.Sleep(500)

    op:SetMonitorPressure(setting.pressure.indexExposurePressure, setPressure)

end

function Operator:ExposureTurnOff()

    dc:GetISolenoidValve():ProportionalValve_SetDACValue(setting.pressure.indexExposureValve, 0)
    log:debug("关闭曝气比例阀")

    --local map = ValveMap.new(setting.liquidType.none.valve)
    --log:debug("关闭总阀")
    --dc:GetISolenoidValve():SetValveMap(map)
    op:SetMonitorPressure(setting.pressure.indexExposurePressure, 0)
end

--[[
 * @brief 注射器排操作(回退)
 * @param[in] source 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] speed 泵速，0为默认速度。
--]]
function Operator:SyringeDrain(dest, volume, speed)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    local ret = false
    local timeout = math.floor(volume * setting.liquid.meterLimit.syringTimeoutFactor)   -- 注射器获取操作结果事件超时时间
    local map = ValveMap.new(dest.valve)
    local pump = pumps[dest.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象
    local xSpeed = 0.3
    local runVolume = 0

    if volume == 0 then
        timeout = math.floor(1 * setting.liquid.meterLimit.pumpTimeoutFactor)
    end

    if speed ~= 0 and speed~=nil then
        xSpeed = speed
    end

    if volume == 0 then
        runVolume = 0
    elseif volume > setting.liquid.syringeMaxVolume then
        runVolume = setting.liquid.syringeMaxVolume
    else
        runVolume = volume
    end

    if runVolume == 0 then
        timeout = math.floor(0.5 * setting.liquid.meterLimit.pumpTimeoutFactor)   -- 复位操作结果事件超时时间
    end

    if timeout <= 8000 then
        timeout = 8000
    end

    log:debug("{Syringe} Drain , volume = " .. runVolume .. ", speed = " .. xSpeed)

    -- map:SetData(0)
    -- self.ISolenoidValve:SetValveMap(map)

    -- 打开相关液路的阀门
    local err,result = pcall(function() return self.ISolenoidValve:SetValveMap(map) end)

    if not err then      -- 出现异常
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    if dest ~= setting.liquidType.syringeWaste then
        --等待1秒，未开阀之前启动泵，使操作的管路产生负压，减少抽取时产生的气泡
        App.Sleep(500);
    end

    --打开注射器进行吸操作
    err,result = pcall(function() return pump:Start(RollDirection.Drain, runVolume, xSpeed) end)

    if not err then -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        pump:Stop()                                                                  -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            pump:Stop()
            return false
        end
    end

    -- 等待泵操作结果事件
    err,result = pcall(function() return pump:ExpectResult(timeout) end)

    if not err then -- 出现异常
        pump:Stop()                                                                      -- 停止泵
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        error(result)
    else    --函数调用正常
        --map:SetData(0)
        map = ValveMap.new(setting.liquidType.map.valve4)
        self.ISolenoidValve:SetValveMap(map)                                     --不关闭气体总阀

        --if  self.isSyringStop then
        --    self.isSyringStop = false
        --    error(UserStopException:new())
        --end

        if result:GetResult() == PumpOperateResult.Failed then
            error (PumpFailedException:new{liquidType = dest, dir = RollDirection.Drain,})
        elseif result:GetResult()  == PumpOperateResult.Stopped then
            error (PumpStoppedException:new{liquidType = dest, dir = RollDirection.Drain,})
        elseif result:GetResult()  == PumpOperateResult.Finished then
            ret = true;
        end
    end
    map = nil
    --ReagentRemainManager.ReduceReagent(source, volume)
    --App.Sleep(500);
    --flowManager:ClearAllRemainEvent()
    return ret
end

function Operator:SyringeDrainNotCloseValve(dest, volume, speed)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    --local source = setting.liquidType.stove
    local ret =false
    local timeout = math.floor(volume * setting.liquid.meterLimit.pumpTimeoutFactor * 2)   -- 获取操作结果事件超时时间
    local map = ValveMap.new(dest.valve)
    local pump = pumps[dest.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象
    local xSpeed = 0.3
    local runVolume = 0

    if volume == 0 then
        timeout = math.floor(2.5 * setting.liquid.meterLimit.pumpTimeoutFactor)
    end

    if speed ~= 0 and speed~=nil then
        xSpeed = speed
    end

    if volume == 0 then
        runVolume = 0
    elseif volume > setting.liquid.syringeMaxVolume then
        runVolume = setting.liquid.syringeMaxVolume
    else
        runVolume = volume
    end

    if runVolume == 0 then
        timeout = math.floor(2.5 * setting.liquid.meterLimit.pumpTimeoutFactor)   -- 复位操作结果事件超时时间
    end

    log:debug("{Syringe} Drain , volume = " .. runVolume .. ", speed = " .. xSpeed)

    --打开注射器进行吸操作
    local err,result = pcall(function() return pump:Start(RollDirection.Drain, runVolume, xSpeed) end)

    if not err then      -- 出现异常
        pump:Stop()                                                            -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            return false
        end
    end

    --等待1秒，未开阀之前启动泵，使操作的管路产生负压，减少抽取时产生的气泡
    --App.Sleep(500);

    -- 打开相关液路的阀门
    err,result = pcall(function() return self.ISolenoidValve:SetValveMap(map) end)

    if not err then -- 出现异常

        local map = ValveMap.new(setting.liquidType.map.valve4 | setting.liquidType.map.valve8)
        self.ISolenoidValve:SetValveMap(map)
        pump:Stop()                                                                  -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            pump:Stop()
            return false
        end
    end

    -- 等待泵操作结果事件
    err,result = pcall(function() return pump:ExpectResult(timeout) end)

    if not err then -- 出现异常
        pump:Stop()                                                                      -- 停止泵
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        error(result)
    else    --函数调用正常
        map:SetData(0)

        if result:GetResult() == PumpOperateResult.Failed then
            error (PumpFailedException:new{liquidType = dest, dir = RollDirection.Drain,})
        elseif result:GetResult()  == PumpOperateResult.Stopped then
            error (PumpStoppedException:new{liquidType = dest, dir = RollDirection.Drain,})
        elseif result:GetResult()  == PumpOperateResult.Finished then
            ret = true;
        end
    end
    map = nil
    ReagentRemainManager.ReduceReagent(source, volume)
    return ret
end

--[[
 * @brief 注射器抽操作
 * @param[in] source 管道类型。
 * @param[in] volume 溶液体积。
  * @param[in] speed 泵速，0为默认速度。
--]]
function Operator:SyringeSuck(source, volume, speed)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    --local source = setting.liquidType.syringFromDigestionRoom
    local ret =false
    local timeout = math.floor(volume * setting.liquid.meterLimit.pumpTimeoutFactor)   -- 获取操作结果事件超时时间
    local map = ValveMap.new(source.valve)
    local pump = pumps[source.pump + 1]  --  +1 当泵号为0时，从pumps[1]取泵对象
    local xSpeed = 0.3
    local runVolume = 0

    if speed ~= 0 and speed~=nil then
        xSpeed = speed
    end

    if volume == 0 then
        runVolume = 0
    elseif volume > setting.liquid.syringeMaxVolume then
        runVolume = setting.liquid.syringeMaxVolume
    else
        runVolume = volume
    end

    if volume == 0 then
        timeout = math.floor(2.5 * setting.liquid.meterLimit.pumpTimeoutFactor)   -- 复位操作结果事件超时时间
    end

    if timeout < 8000 then
        timeout = 8000
    end

    log:debug("{Syringe} Suck = " .. source.name .. ", volume = " .. runVolume .. ", speed = " .. xSpeed)

    --打开注射器进行吸操作
    local err,result = pcall(function() return pump:Start(RollDirection.Suck, runVolume, xSpeed) end)

    if not err then      -- 出现异常
        pump:Stop()                                                            -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            log:debug("Syringe suck error stop: " .. result)
            return false
        end
    end

    --log:debug("{Syringe} num = " .. source.pump)
    --等待，未开阀之前启动泵，使操作的管路产生负压，减少抽取时产生的气泡
    App.Sleep(500);

    -- 打开相关液路的阀门
    err,result = pcall(function() return self.ISolenoidValve:SetValveMap(map) end)

    if not err then -- 出现异常
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        pump:Stop()                                                                  -- 停止泵
        error(result)
    else    --函数调用正常
        if not result then
            pump:Stop()
            return false
        end
    end

    -- 等待泵操作结果事件
    err,result = pcall(function() return pump:ExpectResult(timeout) end)

    if not err then -- 出现异常
        pump:Stop()                                                                      -- 停止泵
        map:SetData(0)
        self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        error(result)
    else    --函数调用正常
        --map:SetData(0)
        --self.ISolenoidValve:SetValveMap(map)                                     --关闭所有阀门
        map = ValveMap.new(setting.liquidType.map.valve4)
        self.ISolenoidValve:SetValveMap(map)                                     --不关闭气体总阀

        if result:GetResult() == PumpOperateResult.Failed then
            error (PumpFailedException:new{liquidType = source, dir = RollDirection.Suck,})
        elseif result:GetResult()  == PumpOperateResult.Stopped then
            error (PumpStoppedException:new{liquidType = source, dir = RollDirection.Suck,})
        elseif result:GetResult()  == PumpOperateResult.Finished then
            ret = true;
        end
    end

    map = nil
    --ConfigLists.SaveMeasureStatus()
    ReagentRemainManager.ReduceReagent(source, volume)
    --flowManager:ClearAllRemainEvent()
    return ret
end

--[[
 * @brief 注射器从逐出室抽出液体并排至废液。
 * @details
 * @details 当出现期望事件等待超时、达到限定体值时，则进行排液后重抽，
 * @details 。
 * @param[in] source 溶液类型。
 * @param[in] vol 溶液体积。
--]]
function Operator:SyringToWaste(vol, speed)

    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    local factor = self.IPeristalticPump:GetPumpFactor(2)
    local drainSpeed = setting.liquid.syringeDrainSpeed * factor

    if vol == nil then
        vol = 0
    end
    if speed == nil then
        speed = drainSpeed
    end

    --检查是否在复位点，避免往燃烧炉排废液爆炸
    op:SlidersSensorCheck()

    local err,result = pcall(function()
        self:SyringeDrainNotCloseValve(setting.liquidType.syringeStove, vol, drainSpeed)
    end)
    if not err then -- 出现异常
        if type(result) == "userdata" then
            if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                log:warn(result:What())
            else
                error(result)
            end
        elseif type(result) == "table" then
            if getmetatable(result) == PumpFailedException then
                error (PumpFailedException:new{liquidType = setting.liquidType.syringeStove, dir = RollDirection.Drain,})
                --elseif getmetatable(result) == PumpStoppedException then
                --    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Suck,})
            else
                error(UserStopException:new())
            end
        end
    end

    flowManager:ClearAllRemainEvent()

end

--[[
 * @brief 注射器复位点检测
--]]
function Operator:SyringReset(wType)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    local source = setting.liquidType.syringeWaste
    if wType ~= nil then
        source = wType
    end
    local ret = false
    for i = 1,5 do
        if op:SyringeGetSenseStatus(setting.sensor.syringeIndex) then
            ret = true
            break
        end
    end

    local factor = self.IPeristalticPump:GetPumpFactor(2)
    local drainSpeed = setting.liquid.syringeDrainSpeed * factor

    if ret == true then
        --log:info("注射器传感器 被遮挡")
        op:SlidersSensorCheck()
    elseif ret == false then
        --log:info("注射器传感器 未被遮挡")
        log:debug("[注射器复位]")

        --检查是否在复位点，避免往燃烧炉排废液爆炸
        op:SlidersSensorCheck()

        local err,result = pcall(function()
            self:SyringeDrain(source, setting.liquid.syringeResetVolume, drainSpeed)
        end)
        if not err then -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    log:warn(result:What())
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == PumpFailedException then
                    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Drain,})
                    --elseif getmetatable(result) == PumpStoppedException then
                    --    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Drain,})
                else
                    error(UserStopException:new())
                end
            end
        end
    end
    flowManager:ClearAllRemainEvent()
end

--[[
 * @brief 注射器排至燃烧炉。
 * @details
 * @details 当出现期望事件等待超时、达到限定体值时，向上传递错误信息
 * @details
 * @param[in] source 溶液类型。
 * @param[in] vol 溶液体积。
--]]
function Operator:SyringToStove(drainVol, addTimes, wType)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    --加样次数
    local drainCnt = 1
    if addTimes ~= nil and addTimes >= 1 then
        drainCnt = addTimes
    end
    --单次加样体积不得超过注射器限制体积
    local singleDrainVol = drainVol/drainCnt
    if singleDrainVol >= setting.liquid.syringeAddMaxVloume then
        singleDrainVol = setting.liquid.syringeAddMaxVloume
    elseif singleDrainVol < setting.liquid.syringeAddMinVloume then
        singleDrainVol = setting.liquid.syringeAddMinVloume
    end

    --废液类型
    local wasteType = WasteType.WasteReagent
    if wType ==  WasteType.WasteWater or wType == setting.liquidType.wasteWater then
        wasteType = WasteType.WasteWater
    end
    local factor = self.IPeristalticPump:GetPumpFactor(2)
    local drainSpeed = setting.liquid.syringeDrainSpeed * factor

    --最大单次加液体积不超过80ul
    local maxLimitVol = drainVol/config.measureParam.addSampleCnt
    if maxLimitVol > setting.liquid.syringeAddMaxVloume then
        maxLimitVol = setting.liquid.syringeAddMaxVloume
    end

    local err,result = pcall(function()
        for i = 1, drainCnt do
            self:SyringeDrainNotCloseValve(setting.liquidType.syringeStove, singleDrainVol, drainSpeed)
            App.Sleep(1000 * config.measureParam.addSampleMidtime);
        end
    end)
    if not err then -- 出现异常
        if type(result) == "userdata" then
            if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                log:warn(result:What())
            else
                error(result)
            end
        elseif type(result) == "table" then
            if getmetatable(result) == PumpFailedException then
                error (PumpFailedException:new{liquidType = setting.liquidType.syringeStove, dir = RollDirection.Drain,})
                --elseif getmetatable(result) == PumpStoppedException then
                --    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Suck,})
            else
                error(UserStopException:new())
            end
        end
    end

    flowManager:ClearAllRemainEvent()

end

--[[
 * @brief 注射器更新，进样复位点检测，然后执行重复抽排动作
 * @param[in] count 执行抽排的次数
 * @noted 注射器执行更新动作时，注射器必须处于排废液位置，否则大量液体注入高温燃烧炉会导致发生爆炸
--]]
function Operator:SyringUpdate(count, vol)

    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    local ret = false
    local suckVolume = setting.liquid.syringeCleanVolume
    if vol ~= nil and vol < setting.liquid.syringeCleanVolume then
        suckVolume = vol
    end

    --检查是否在复位点，避免往燃烧炉排废液爆炸
    local factor = self.IPeristalticPump:GetPumpFactor(2)
    local drainSpeed = setting.liquid.syringeSlowDrainSpeed * factor

    if(count >= setting.liquid.syringeUpdateUpperLimit) then
        count = setting.liquid.syringeUpdateUpperLimit
    end

    --注射器复位状态检测
    local err,result = pcall(function()
        op:SyringReset()
    end)
    if not err then -- 出现异常
        error(result)
    end

    local motionParam = MotionParam.new()
    local acceleration = setting.liquid.syringeSuckAcceleration
    motionParam =  self.IPeristalticPump:GetMotionParam(2)
    if math.abs(motionParam:GetAcceleration() - acceleration) > 0.001 then
        motionParam:SetAcceleration(acceleration)
        motionParam:SetSpeed(drainSpeed)
        log:debug("[重设注射泵参数]： Set Speed " .. drainSpeed .. ", Set Acceleration " .. acceleration)
        self.IPeristalticPump:SetMotionParam(2, motionParam)
    end

    log:debug("[注射器更新]： " .. count .. "次")

    for i = 1, count-1 do

        local err,result = pcall(function()
            self:SyringeSuck(setting.liquidType.syringeBlank , suckVolume, drainSpeed/4)
            App.Sleep(200)
        end)

        if not err then -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    log:warn(result:What())
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == PumpFailedException then
                    error (PumpFailedException:new{liquidType = setting.liquidType.syringeBlank, dir = RollDirection.Suck,})
                    --elseif getmetatable(result) == PumpStoppedException then
                    --    error (PumpFailedException:new{liquidType = setting.liquidType.syringFromDigestionRoom, dir = RollDirection.Suck,})
                else
                    error(UserStopException:new())
                end
            end
        end

        local err,result = pcall(function()
            self:SyringeDrain(setting.liquidType.syringeWaste, setting.liquid.syringeResetVolume, drainSpeed)
            App.Sleep(200)
        end)

        if not err then -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    log:warn(result:What())
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == PumpFailedException then
                    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Drain,})
                    --elseif getmetatable(result) == PumpStoppedException then
                    --    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Drain,})
                else
                    error(UserStopException:new())
                end
            end
        end

    end

    local err,result = pcall(function()
        self:SyringeSuck(setting.liquidType.syringeBlank , suckVolume, drainSpeed/4)
        App.Sleep(200)
    end)

    if not err then -- 出现异常
        if type(result) == "userdata" then
            if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                log:warn(result:What())
            else
                error(result)
            end
        elseif type(result) == "table" then
            if getmetatable(result) == PumpFailedException then
                error (PumpFailedException:new{liquidType = setting.liquidType.blank, dir = RollDirection.Suck,})
                --elseif getmetatable(result) == PumpStoppedException then
                --    error (PumpFailedException:new{liquidType = setting.liquidType.syringFromDigestionRoom, dir = RollDirection.Suck,})
            else
                error(UserStopException:new())
            end
        end
    end

    local err,result = pcall(function()
        self:SyringeDrainNotCloseValve(setting.liquidType.syringeWaste, suckVolume * 0.5, drainSpeed)
        App.Sleep(200)
    end)

    if not err then -- 出现异常
        if type(result) == "userdata" then
            if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                log:warn(result:What())
            else
                error(result)
            end
        elseif type(result) == "table" then
            if getmetatable(result) == PumpFailedException then
                error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Drain,})
                --elseif getmetatable(result) == PumpStoppedException then
                --    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Drain,})
            else
                error(UserStopException:new())
            end
        end
    end

end

function Operator:SyringUpdateAir(count)

    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    local ret = false

    --检查是否在复位点，避免往燃烧炉排废液爆炸
    local factor = self.IPeristalticPump:GetPumpFactor(2)
    local drainSpeed = setting.liquid.syringeSlowDrainSpeed * factor

    log:debug("[注射器更新空气]： " .. count .. "次")

    if(count >= setting.liquid.syringeUpdateUpperLimit) then
        count = setting.liquid.syringeUpdateUpperLimit
    end

    local motionParam = MotionParam.new()
    local acceleration = setting.liquid.syringeSuckAcceleration
    motionParam =  self.IPeristalticPump:GetMotionParam(2)
    if math.abs(motionParam:GetAcceleration() - acceleration) > 0.001 then
        motionParam:SetAcceleration(acceleration)
        motionParam:SetSpeed(drainSpeed)
        log:debug("[重设注射泵参数]： Set Speed " .. drainSpeed .. ", Set Acceleration " .. acceleration)
        self.IPeristalticPump:SetMotionParam(2, motionParam)
    end


    for i = 1, count do
        --排空加样管
        --op:DrainToWaste(0.5, WasteType.WasteReagent)

        --注射器复位状态检测
        local err,result = pcall(function()
            op:SyringReset()
        end)
        if not err then -- 出现异常
            error(result)
        end

        local err,result = pcall(function()
            self:SyringeSuck(setting.liquidType.syringNone , setting.liquid.syringeMaxVolume, drainSpeed/4)
            App.Sleep(200)
        end)

        if not err then -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    log:warn(result:What())
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == PumpFailedException then
                    error (PumpFailedException:new{liquidType = setting.liquidType.syringNone, dir = RollDirection.Suck,})
                    --elseif getmetatable(result) == PumpStoppedException then
                    --    error (PumpFailedException:new{liquidType = setting.liquidType.syringFromDigestionRoom, dir = RollDirection.Suck,})
                else
                    error(UserStopException:new())
                end
            end
        end

        local err,result = pcall(function()
            self:SyringeDrain(setting.liquidType.syringNone, setting.liquid.syringeResetVolume, drainSpeed)
            App.Sleep(200)
        end)

        if not err then -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    log:warn(result:What())
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == PumpFailedException then
                    error (PumpFailedException:new{liquidType = setting.liquidType.none, dir = RollDirection.Drain,})
                    --elseif getmetatable(result) == PumpStoppedException then
                    --    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Drain,})
                else
                    error(UserStopException:new())
                end
            end
        end

        local err,result = pcall(function()
            self:SyringeSuck(setting.liquidType.syringeBlank , setting.liquid.syringeMaxVolume, drainSpeed/4)
            App.Sleep(200)
        end)

        if not err then -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    log:warn(result:What())
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == PumpFailedException then
                    error (PumpFailedException:new{liquidType = setting.liquidType.blank, dir = RollDirection.Suck,})
                    --elseif getmetatable(result) == PumpStoppedException then
                    --    error (PumpFailedException:new{liquidType = setting.liquidType.syringFromDigestionRoom, dir = RollDirection.Suck,})
                else
                    error(UserStopException:new())
                end
            end
        end

        local err,result = pcall(function()
            self:SyringeDrain(setting.liquidType.syringeWaste,  0.5, drainSpeed)
            App.Sleep(200)
        end)

        if not err then -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    log:warn(result:What())
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == PumpFailedException then
                    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Drain,})
                    --elseif getmetatable(result) == PumpStoppedException then
                    --    error (PumpFailedException:new{liquidType = setting.liquidType.syringeWaste, dir = RollDirection.Drain,})
                else
                    error(UserStopException:new())
                end
            end
        end
    end
end

--[[
 * @brief 基线判定
 * @details
 * @details 当出现期望事件等待超时、达到限定体值时，则进行排液后重抽，
 * @details
 * @param[in] source 溶液类型。
 * @param[in] vol 溶液体积。
--]]
function Operator:BaseLineCheck()
    --等待稳定
    local runAction = Helper.Status.SetAction(setting.runAction.measure.baseLineCheck)
    StatusManager.Instance():SetAction(runAction)
    local warnLimit = 900
    while true do
        if op:IsReachSteady(setting.measureResult.baseLineNum*4) == false then
            if not Measurer.flow:Wait(2) then
                break
            end
        else
            runAction = Helper.Status.SetAction(setting.runAction.measure.reactTime)
            StatusManager.Instance():SetAction(runAction)
            break
        end
        warnLimit = warnLimit - 1
        if warnLimit < 0 then
            log:warn("基线不稳定");
            local alarm = Helper.MakeAlarm(setting.alarm.baseLineCheckFailed, "")
            AlarmManager.Instance():AddAlarm(alarm)
            error(DeviceFaultException:new())
            --error(UserStopException:new())
        end
    end
end

function Operator:Wait(seconds)
    local cnt = math.floor(seconds * 1000/200)

    while true do
        if  Flow.isStarted then
            App.Sleep(200)
        else
            return false
        end

        cnt = cnt -1
        if cnt <= 0 then
            return true
        end
    end
end

function Operator:debugPrintf(str)
    --if config.system.debugMode == true then
        log:debug(str)
    --end
end

--[[
 * @brief 重设LED测量周期
--]]
function Operator:ResetLEDMeasurePeriod()
    local period = dc:GetIOpticalAcquire():GetLEDDefaultValue(0)
    if period == 0 then
        period = config.hardwareConfig.measureLed.period.set
    end
    dc:GetIOpticalAcquire():SetLEDDefaultValue(period)
    log:debug("重设LED测量周期： " .. period)
end

--[[
 * @brief 检查压力补偿状态
 * @detail 确保仪器在5-50°范围内进行补偿调节，超出温度范围不再进行补偿
--]]
function Operator:CheckCarryPressureOffsetStatus()
    local temp = dc:GetEnvironmentTemperature()
    if temp > setting.temperature.presstureTemperatureUpLimit
            or temp < setting.temperature.presstureTemperatureLowLimit then
        log:debug("压力补偿调节温度异常， 当前温度 " .. string.format("%0.2f", temp) .. "℃")
        dc:GetISolenoidValve():ProportionalValve_AutoControlPressure(false)
        log:debug("载气压力补偿： " .. "关闭")
    else
        PressureAutoEnvironmentalControl()
    end
end

--[[
 * @brief 打开气路,并设置自动调节压力值，调节范围±0.3kPa
--]]
function Operator:TurnOnNirtrogen(delayTime, carryingPressure)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()
    local time = 3000
    if delayTime ~= nil then
        time = delayTime * time
    end
    local map = ValveMap.new(setting.liquidType.map.valve4)
    log:debug("打开总阀")
    dc:GetISolenoidValve():SetValveMap(map)
    App.Sleep(500);

    dc:GetISolenoidValve():ProportionalValve_SetDACValue(setting.pressure.indexExposureValve, 0)

    --dc:GetISolenoidValve():ProportionalValve_SetDACValue(setting.pressure.indexCarryPressureValve, 0)
    App.Sleep(200);

    --需避免引起压力调节失败
    dc:GetISolenoidValve():ProportionalValve_SetDACValue(setting.pressure.indexCarryPressureValve, config.measureParam.carryingValveVoltage)
    log:debug("打开载气比例阀： " ..  config.measureParam.carryingValveVoltage .. " V")

    App.Sleep(time);
    --设置监测压力 载气压力慢慢上升
    if carryingPressure ~= nil then
        op:SetMonitorPressure(setting.pressure.indexCarryPressure, carryingPressure)
    else
        op:SetMonitorPressure(setting.pressure.indexCarryPressure, config.measureParam.carryingPressure)
    end

    flowManager:ClearAllRemainEvent()
end

--[[
 * @brief 关闭所有气路，先关闭总阀，后关闭比例阀，否则总阀与比例阀之间有残留压力
 * @param[in] delayTime -- 关阀延时
 * @return
--]]
function Operator:TurnOffNirtrogen(delayTime)
    local time = 1000
    if delayTime ~= nil then
        time = time * delayTime
    end
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    --设置载气压力为0，关闭载气调节
    op:SetMonitorPressure(setting.pressure.indexCarryPressure, 0)
    App.Sleep(500);
    dc:GetISolenoidValve():ProportionalValve_SetDACValue(setting.pressure.indexExposureValve, setting.pressure.maxValveVoltage)
    log:debug("打开曝气比例阀")
    dc:GetISolenoidValve():ProportionalValve_SetDACValue(setting.pressure.indexCarryPressureValve, setting.pressure.maxValveVoltage)
    log:debug("打开载气比例阀")
    App.Sleep(500);
    local map = ValveMap.new(setting.liquidType.none.valve)
    dc:GetISolenoidValve():SetValveMap(map)
    log:debug("关闭总阀")

    local checkTimes = 10
    while true do
        local masterPressture = dc:GetPressure(setting.pressure.pressureMaster)
        if masterPressture < setting.pressure.masterReleaseLimit  then
            break
        elseif checkTimes < 0 then
            break
        end
        App.Sleep(500);
        checkTimes = checkTimes - 1
    end
    dc:GetISolenoidValve():ProportionalValve_SetDACValue(setting.pressure.indexExposureValve, 0)
    log:debug("关闭曝气比例阀")
    dc:GetISolenoidValve():ProportionalValve_SetDACValue(setting.pressure.indexCarryPressureValve, 0)
    log:debug("关闭载气比例阀")
end

--[[
 * @brief 获取传感器状态
 * @param[in] index 传感器索引 0-注射器传感器 1-进样传感器。
 * detail 传感器正常状态下：注射器被遮挡时处于零点处，进样器被遮挡处于非零点处
 * @return 1-未遮挡 2-遮挡
--]]
function Operator:SyringeGetSenseStatus()
    local ret = dc:GetIPeristalticPump():GetSenseStatus(setting.sensor.syringeIndex)
    if ret == 2 then
        return true
    else
        --log:debug("Syringe Sensor status " .. ret)
        return false
    end
end

--[[
 * @brief 获取滑块传感器状态
 * @param[in] index 传感器索引 0-注射器传感器 1-进样传感器。
 * detail 传感器正常状态下：进样器被遮挡处于零点处
 * @return 1-未遮挡 2-遮挡
--]]
function Operator:GetSlidersSensorStatus()
    local ret = dc:GetIPeristalticPump():GetSenseStatus(setting.sensor.slidersIndex)
    if ret == 2 then
        return true
    else
        return false
    end
end

--[[
 * @brief 设置下位机压力监测值，后续会添加曝气路的压力监测
 * @param[in]
--]]
function Operator:SetMonitorPressure(index, value)
    if index == setting.pressure.indexCarryPressure then
        log:debug("设置载气压力： " .. value .. "kPa")
    else
        log:debug("设置曝气压力： " .. value .. "kPa")
    end

    dc:GetISolenoidValve():ProportionalValve_SetDACValue(index, value)
end

function Operator:CloseMasterValve()
    log:debug("加待测样后关阀")
    local map = ValveMap.new(setting.liquidType.none.valve)
    self.ISolenoidValve:SetValveMap(map)                                     --不关闭气体总阀
end

function Operator:CheckStoveTemperature()
    local safeTemp = setting.temperature.digestSafetyTemp
    local startTime = os.time()

    local  thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
    self:debugPrintf("燃烧炉温度 = " .. thermostatTemp .. " ℃");

    local temp = thermostatTemp - config.measureParam.reactTemperature
    if temp > setting.temperature.checkTemperatureTolerance then
        if  temp > setting.temperature.checkTemperatureTolerance then
            --状态设置
            if StatusManager.Instance():IsIdleStatus() == true then
                    local runStatus = Helper.Status.SetStatus(setting.runStatus.digestCooling)
                    StatusManager.Instance():SetStatus(runStatus)
            end

            --动作设置
            local runAction = Helper.Status.SetAction(setting.runAction.digestCooling)
            StatusManager.Instance():SetAction(runAction)

             --开机箱风扇
            self.ITemperatureControl:BoxFanSetOutput(1)

            --冷却
            local cnt = 0
            while true do
                --获取恒温器状态
                if self.ITemperatureControl:GetThermostatStatus() == 2 then
                        self:StopThermostat()
                end

                local err,result = pcall(function()

                                     return self:StartThermostat(ThermostatMode.Refrigerate, safeTemp, 1, setting.temperature.digestToReactCoolingTimeout)
                                   end)-----end pcall
                if not err then      -- 出现异常
                    if type(result) == "userdata" then
                        ExceptionHandler.MakeAlarm(result)
                    elseif type(result) == "table" then
                        if getmetatable(result) == ThermostatStoppedException then  	--恒温被停止异常。
                            self:StopThermostat()
                            self.ITemperatureControl:BoxFanSetOutput(0) 	--关机箱风扇
                            error(result)
                        else
                            ExceptionHandler.MakeAlarm(result)
                        end
                    else
                        log:warn(result)										--C++、Lua系统异常
                    end
                end

                thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
                temp = thermostatTemp - safeTemp
                if  temp >  2 then
                    self:debugPrintf("安全温度未达标")
                    cnt = cnt + 1
                    if cnt >= 3 then
                        break
                    end
                else
                    break
                end
            end

            --关机箱风扇
            self.ITemperatureControl:BoxFanSetOutput(0)

            --获取恒温器状态
            if self.ITemperatureControl:GetThermostatStatus() == 2 then
                    self:StopThermostat()
            end

            self:debugPrintf("到达安全冷却目标温度 = ".. thermostatTemp .. " ℃" )
            self:debugPrintf("电炉冷却总时间 = " .. os.time() - startTime)
        end
    end
end

--[[
 * @brief 等待气压稳定
 * detail
 * @param[in]
--]]
function  Operator:WaitAirFlow(flow, updateEvent, carryingPressure)
    local ret = false
    local cntLimit = 900  --3分钟
    local currentPressure = config.measureParam.carryingPressure
    if flow ~= nil then
        self = flow
    end
    if carryingPressure ~= nil then
        currentPressure = carryingPressure
    end
    if updateEvent == true then
        local runAction = Helper.Status.SetAction(setting.runAction.measure.airFlowCheck)
        StatusManager.Instance():SetAction(runAction)
    end

    local checkTimes = 5
    while true do
        local alarm
        local masterPressture = dc:GetPressure(setting.pressure.pressureMaster)
        if masterPressture < setting.pressure.masterPressureMinLimit and checkTimes < 0 then
            alarm = Helper.MakeAlarm(setting.alarm.masterPressureLower, string.format("%0.2f", masterPressture) .. "kPa")
            AlarmManager.Instance():AddAlarm(alarm)
            error(AirFlowPressureLowerException:new())
        elseif masterPressture > setting.pressure.masterPressureMaxLimit and checkTimes < 0  then
            alarm = Helper.MakeAlarm(setting.alarm.masterPressureHigher, string.format("%0.2f", masterPressture) .. "kPa")
            AlarmManager.Instance():AddAlarm(alarm)
            error(AirFlowPressureHigherException:new())
        elseif masterPressture > setting.pressure.masterPressureMinLimit and masterPressture < setting.pressure.masterPressureMaxLimit then
            break
        end
        if not self:Wait(2) then
            error(UserStopException:new())    --用户停止
        end
        checkTimes = checkTimes - 1
    end

    --while true do
    --    local carriagePressture = dc:GetPressure(setting.pressure.pressureCarry)
    --    if carriagePressture > currentPressure - setting.pressure.WarningPressureTolerance
    --            and carriagePressture < currentPressure + setting.pressure.WarningPressureTolerance then
    --        ret = true
    --        break
    --    else
    --        if not self:Wait(2) then
    --            error(UserStopException:new())    --用户停止
    --        end
    --        cntLimit = cntLimit - 1
    --        if cntLimit < 0 then
    --            local alarm
    --            if carriagePressture < config.measureParam.carryingPressure then
    --                alarm = Helper.MakeAlarm(setting.alarm.airFlowPressureLower, string.format("%0.2f", carriagePressture) .. "kPa")
    --                AlarmManager.Instance():AddAlarm(alarm)
    --                error(AirFlowPressureLowerException:new())
    --            else
    --                alarm = Helper.MakeAlarm(setting.alarm.airFlowPressureHigher, string.format("%0.2f", carriagePressture) .. "kPa")
    --                AlarmManager.Instance():AddAlarm(alarm)
    --                error(AirFlowPressureHigherException:new())
    --            end
    --        end
    --    end
    --end

    return ret

end
--[[
 * @brief 检查气压
 * detail 连续5次载气压力都在允许范围内，则认为载气压力正常，否则进行重设压力
 * @param[in]
--]]
function  Operator:ConfirmAirFlow(updateEvent, carryingPressure)
    local ret = false
    local currentPressure = config.measureParam.carryingPressure
    if carryingPressure ~= nil then
        currentPressure = carryingPressure
    end
    if updateEvent == true then
        local runAction = Helper.Status.SetAction(setting.runAction.measure.airFlowCheck)
        StatusManager.Instance():SetAction(runAction)
    end

    local checkTimes = 5
    while true do
        local alarm
        local masterPressture = dc:GetPressure(setting.pressure.pressureMaster)
        if masterPressture < setting.pressure.masterPressureMinLimit and checkTimes < 0 then
            alarm = Helper.MakeAlarm(setting.alarm.masterPressureLower, string.format("%0.2f", masterPressture) .. "kPa")
            AlarmManager.Instance():AddAlarm(alarm)
            error(AirFlowPressureLowerException:new())
        elseif masterPressture > setting.pressure.masterPressureMaxLimit and checkTimes < 0  then
            alarm = Helper.MakeAlarm(setting.alarm.masterPressureHigher, string.format("%0.2f", masterPressture) .. "kPa")
            AlarmManager.Instance():AddAlarm(alarm)
            error(AirFlowPressureHigherException:new())
        elseif masterPressture > setting.pressure.masterPressureMinLimit and masterPressture < setting.pressure.masterPressureMaxLimit then
            break
        end
        if not Measurer.flow:Wait(2) then
            error(UserStopException:new())    --用户停止
        end
        checkTimes = checkTimes - 1
    end

    checkTimes = 5
    local errorTimeout = 30
    while true do
        local carriagePressture = dc:GetPressure(setting.pressure.pressureCarry)
        if math.abs(carriagePressture - currentPressure) < currentPressure * 0.15 then
            checkTimes = checkTimes - 1
        else
            checkTimes = 5
            errorTimeout = errorTimeout - 1
        end
        if checkTimes < 0 then
            ret = true
            break
        end
        if errorTimeout < 0 then
            --关闭氮气气路
            op:TurnOffNirtrogen(setting.pressure.delayTime)
            if not Measurer.flow:Wait(10) then
                error(UserStopException:new())    --用户停止
            end
            --打开氮气气路
            op:TurnOnNirtrogen()

            if not Measurer.flow:Wait(15) then
                error(UserStopException:new())    --用户停止
            end
            break
        end
        if not Measurer.flow:Wait(2) then
            error(UserStopException:new())    --用户停止
        end
    end

    checkTimes = 2
    errorTimeout = 3
    while true do
        local carriagePressture = dc:GetPressure(setting.pressure.pressureCarry)
        if math.abs(carriagePressture - currentPressure) < currentPressure * 0.15 then
            checkTimes = checkTimes - 1
        else
            checkTimes = 2
            errorTimeout = errorTimeout - 1
        end
        if checkTimes < 0 then
            ret = true
            break
        end
        if errorTimeout < 0 then
            local alarm = Helper.MakeAlarm(setting.alarm.airFlowError, "")
            AlarmManager.Instance():AddAlarm(alarm)
            error(AirFlowException:new())    --载气调节异常
        end
        if not Measurer.flow:Wait(2) then
            error(UserStopException:new())    --用户停止
        end
    end

    return ret

end

--[[
 * @brief 检查LED信号值
 * detail 连续3次信号值都在允许范围内，则认为LED信号正常，否则进行告警
 * @param[in]
--]]
function  Operator:ConfirmLED()
    local ret = false
    local vaLue = 0
    local num = 0
    local checkTimes = 3

    while true do
        local ScanLen = dc:GetScanLen()
        if ScanLen ~= nil then
            num = ScanLen
        end

        local ScanData = dc:GetScanData(num - 1)
        if ScanData ~= nil then
            vaLue = ScanData
        end

        local alarm
        if vaLue > setting.measureResult.LedUpperLimit and checkTimes < 0 then
            alarm = Helper.MakeAlarm(setting.alarm.measureLedInvalid, string.format("%0.3f", vaLue) .. "V")
            AlarmManager.Instance():AddAlarm(alarm)
            error(MeasureLedException:new())    --用户停止
        elseif vaLue < setting.measureResult.LedLowerLimit and checkTimes < 0  then
            alarm = Helper.MakeAlarm(setting.alarm.measureLedInvalid, string.format("%0.3f", vaLue) .. "V")
            AlarmManager.Instance():AddAlarm(alarm)
            error(MeasureLedException:new())    --用户停止
        elseif vaLue > setting.measureResult.LedLowerLimit and vaLue < setting.measureResult.LedUpperLimit then
            break
        end

        if vaLue < setting.measureResult.LedLowerLimit then
            --开LED
            dc:GetIOpticalAcquire():TurnOnLED()
        end

        if not Measurer.flow:Wait(2) then
            error(UserStopException:new())    --用户停止
        end
        checkTimes = checkTimes - 1
    end

    return ret

end

--[[
 * @brief 传感器反馈的滑块往返移动
 * detail 当传感器处于遮挡时，前进固定距离，否则移动到传感器处，速度参数对该滑块运动无效
 * @param[in]
--]]
function Operator:SlidersMovingWithSensor()
    self:Pump(setting.liquidType.sliders, setting.sensor.sliderActionWithSensor, 0)
end

--[[
 * @brief 带方向+传感器检测的滑块移动
 * detail 根据设定方向，和距离进行移动，此过程中会被传感器进行终止
 * detail 速度参数对该滑块运动无效
  * detail 驱动板限制最大运行步数不可超过2600
 * @param[in]
--]]
function Operator:SlidersMovingSensorWithDirection(dir, value)
    if value < 20 or value > 2600 then
        log:warn("参数错误")
        return false
    end

    if dir == setting.sensor.slidersForward then
        self:Pump(setting.liquidType.sliders, value, 0)
    elseif dir == setting.sensor.slidersBackward then
        self:Drain(setting.liquidType.sliders, value, 0)
    end
end

--[[
 * @brief 仅带方向的滑块移动
 * detail 根据设定方向，和距离进行移动，此过程中不会被传感器进行终止
 * detail 速度参数对该滑块运动无效
  * detail 驱动板限制最大运行步数不可超过4000，输入参数应为2600 - 4000之间，驱动在执行时会默认将上位机设置的参数除以2
 * @param[in]
--]]
function Operator:SlidersMovingOnlyDirection(dir, value)
    if value < 2600 or value > 4000 then
        log:warn("参数错误")
        return false
    end

    if dir == setting.sensor.slidersForward then
        --self:Pump(setting.liquidType.sliders, value, 0)
        op:ForwardNoEvent(setting.liquidType.sliders, value, 0)
    elseif dir == setting.sensor.slidersBackward then
        op:BackwardNoEvent(setting.liquidType.sliders, value, 0)
    end
end

--[[
 * @brief 进样复位，进样传感器未被遮挡时则必须进行复位
 * @param[in]
--]]
function Operator:SlidersSensorCheck()
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    local ret1
    ret1 = op:GetSlidersSensorStatus()
    --App.Sleep(200);
    if setting.sensor.isValid == false then
        local alarm = Helper.MakeAlarm(setting.alarm.slidersSensorError, "")
        AlarmManager.Instance():AddAlarm(alarm)
        error(SlidersSensorErrorException:new())
    end
    if ret1 == true then
        --log:debug("进样传感器 被遮挡")

    elseif ret1 == false then
        --log:debug("进样传感器 未被遮挡")
        log:debug("进样复位开始")
        op:SlidersMovingWithSensor()

        if false == op:GetSlidersSensorStatus() then
            op:SlidersIsValid()
            App.Sleep(200);
            if false == op:GetSlidersSensorStatus() then
                App.Sleep(200);
                op:SlidersIsValid()
            end
            if false == op:GetSlidersSensorStatus() then
                setting.sensor.isValid = false
                --滑块位置异常报警
                local alarm = Helper.MakeAlarm(setting.alarm.slidersSensorError, "")
                AlarmManager.Instance():AddAlarm(alarm)
                log:warn("进样传感器异常")
            end
            --setting.sensor.isValid = false
            ----滑块位置异常报警
            --local alarm = Helper.MakeAlarm(setting.alarm.slidersSensorError, "")
            --AlarmManager.Instance():AddAlarm(alarm)
            --log:warn("进样传感器异常")

            return false
        else
            setting.sensor.isValid = true
            log:debug("进样复位完成")
        end
    end
end

--[[
 * @brief 开机进样传感器检测
 * detail 假设开机后滑块处于原点状态，传感器被被遮挡，滑块前后运动距离略大于传感器挡片宽度，若检测不到传感器状态发生变化，则认为传感器故障
 * @param[in]
--]]
function Operator:SlidersIsValid()
    local alarm
    local ret1
    ret1 = op:GetSlidersSensorStatus()
    if ret1 == true then
        --log:debug("进样传感器 被遮挡")
        op:SlidersMovingOnlyDirection(setting.sensor.slidersForward, setting.sensor.slidersStepOnly) --前进1cm

        local tempRet = op:GetSlidersSensorStatus()
        if tempRet == ret1 then
            --App.Sleep(200);
            op:SlidersMovingOnlyDirection(setting.sensor.slidersBackward, setting.sensor.slidersStepOnly) --后退1cm,回到初始位置
            log:warn("进样传感器异常")
            --滑块位置异常报警
            alarm = Helper.MakeAlarm(setting.alarm.slidersSensorError, "")
            AlarmManager.Instance():AddAlarm(alarm)
            return false
        else
            --App.Sleep(1000);
            op:SlidersMovingWithSensor() --传感器可用,回到初始位置
            setting.sensor.isValid = true
            if true == op:GetSlidersSensorStatus() then
                setting.sensor.isValid = true
                log:info("滑块位置校准成功")
            else
                setting.sensor.isValid = false
                log:warn("滑块传感器异常")
                alarm = Helper.MakeAlarm(setting.alarm.slidersPositionError, "")
                AlarmManager.Instance():AddAlarm(alarm)
            end
        end

    elseif ret1 == false then
        op:SlidersMovingWithSensor() --传感器可用,回到初始位置
        if true == op:GetSlidersSensorStatus() then
            setting.sensor.isValid = true
            log:info("滑块位置校准成功")
        else
            setting.sensor.isValid = false
            log:warn("滑块传感器异常")
            alarm = Helper.MakeAlarm(setting.alarm.slidersPositionError, "")
            AlarmManager.Instance():AddAlarm(alarm)
        end
    end
end

--[[
 * @brief 基线稳定判断
 * detail 检查当前索引值往前连续10个数值是否在 minDeviation 范围内波动
 * @param[in]
--]]
function Operator:IsReachSteady(value, validCnt, isCheck)

    local index = 1
    if value == nil or value < 30 then
        value = 30
    end

    if isCheck == true then
        index = 0
    end

    local period = setting.ui.profile.hardwareParamIterms[9][1].get()
    if period == 0 then
        period = config.hardwareConfig.measureLed.period.set
    end
    value =  math.floor(1000/period) * value
    print("value " .. value)

    local useValidCnt = math.floor(140 / tonumber(period) * setting.measureResult.validCnt)
    if validCnt ~= nil then
        useValidCnt = validCnt
    end

    print("period " .. period)
    local step = math.floor(setting.measureResult.areaStep / tonumber(period) * 1000)
    --自增量 = 周期系数
    local increment =  15 * 3 --math.floor(140 / tonumber(period) * 15)
    --滤波数量为25 * 2 共50个
    local filterStep = 25
    --数据前后各去掉10个点
    local throwNum = 3
    return dc:IsReachSteady(value, 15, step, increment, filterStep, throwNum, 0)
end

--[[
 * @brief 检查消解室温度安全
 * @details 当消解室温度高于安全温度时，启动降温操作.
--]]
function Operator:IsReactTemperature(flow)

    if nil ~= flow then
        self = flow
    end

    local temp = config.measureParam.reactTemperature
    local  thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
    local refrigeratorTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
    local NDIRTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
    op:debugPrintf("测量前燃烧炉温度 = " .. string.format("%0.1f", thermostatTemp) .. " ℃");
    op:debugPrintf("测量前制冷器温度 = " .. string.format("%0.1f", refrigeratorTemp) .. " ℃");
    op:debugPrintf("测量前测量池温度 = " .. string.format("%0.1f", NDIRTemp) .. " ℃");

    if temp - thermostatTemp >= 20 or temp - thermostatTemp <= -20 then

        op:ReviseThermostatTemp(setting.temperature.indexStove,
                                ThermostatMode.Heater,
                                config.measureParam.reactTemperature,
                                setting.temperature.toleranceTemp,
                                setting.temperature.digestTempTimeout)
        local thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
        local status = false
        local errorcnt = 120
        local runAction = Helper.Status.SetAction(setting.runAction.digestHeating)
        if temp - thermostatTemp <= -20 then
            runAction = Helper.Status.SetAction(setting.runAction.digestCooling)
        end
        StatusManager.Instance():SetAction(runAction)
        while true do
            thermostatTemp = dc:GetCurrentTemperature():GetThermostatTemp()
            if thermostatTemp >= config.measureParam.reactTemperature - setting.temperature.smartHeatDetectTemp and
                    thermostatTemp <= config.measureParam.reactTemperature + setting.temperature.smartHeatDetectTemp then
                status = true
                --重设LED测量周期
                op:ResetLEDMeasurePeriod()
                if not self:Wait(1) then
                    error(UserStopException:new())    --用户停止
                end
                dc:GetIOpticalAcquire():TurnOnLED()	--开LED
                break
            elseif errorcnt < 0 then
                log:warn("燃烧炉温度不达标，当前反应温度 = " .. thermostatTemp .. " ℃");
                local alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, "燃烧炉温度过低")
                if thermostatTemp > config.measureParam.reactTemperature + setting.temperature.smartHeatDetectTemp then
                    alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, "燃烧炉温度过高")
                end
                AlarmManager.Instance():AddAlarm(alarm)
                error(ThermostatFailedException:new({mode = ThermostatMode.Heater, targetTemp = config.measureParam.reactTemperature, toleranceTemp = setting.temperature.toleranceTemp, timeout = setting.temperature.digestTempTimeout}))
                break
            end
            if not self:Wait(5*12) then
                error(UserStopException:new())    --用户停止
            end
            errorcnt = errorcnt - 1
        end
        if status then
            log:debug("达到燃烧炉反应温度： ".. thermostatTemp)
        else
            error(UserStopException:new())    --用户停止
        end
    end

    temp = config.measureParam.coolTemperature
    thermostatTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)

    if thermostatTemp - temp >= 2.5 then
        log:warn("制冷温度不达标，当前反应温度 = " .. thermostatTemp .. " ℃");

        local status = false
        local errorcnt = 60
        local runAction = Helper.Status.SetAction(setting.runAction.refrigeratorSafetyCheck)
        StatusManager.Instance():SetAction(runAction)
        op:ReviseThermostatTemp(setting.temperature.indexRefrigerator,
                ThermostatMode.Refrigerate,
                config.measureParam.coolTemperature,
                setting.temperature.coolToleranceTemp,
                setting.temperature.coolTempTimeout)
        local thermostatTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
        while true do
            thermostatTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
            if thermostatTemp >= config.measureParam.coolTemperature - setting.temperature.toleranceTemp*3 and
                    thermostatTemp <=  config.measureParam.coolTemperature + setting.temperature.toleranceTemp*3 then
                status = true
                break
            elseif errorcnt < 0 then
                local alarm = Helper.MakeAlarm(setting.alarm.thermostatFault, "制冷器温度过高")
                AlarmManager.Instance():AddAlarm(alarm)
                --error(ThermostatFailedException:new({mode = ThermostatMode.Refrigerate, targetTemp = config.measureParam.coolTemperature, toleranceTemp = setting.temperature.toleranceTemp, timeout = 120}))
                break
            end
            if not self:Wait(5) then
                error(UserStopException:new())    --用户停止
            end
            errorcnt = errorcnt - 1
        end
        if status then
            log:debug("达到制冷器反应温度： ".. thermostatTemp)
        else
            error(UserStopException:new())    --用户停止
        end

    end


    return true

end
--status 清空数组
function Operator:CalculatePeakArea(startIndex, endIndex, validCnt , status, measureType)
    local area = -1
    local useValidCnt = setting.measureResult.validCnt
    local period = setting.ui.profile.hardwareParamIterms[9][1].get()
    local step = 60

    if validCnt ~= nil then
        useValidCnt = validCnt
    end
    if period == nil or period == 0 then
        period = config.hardwareConfig.measureLed.period.set
    end

    local increment = math.floor(140 / tonumber(period) * 20)
    --滤波数量为25 * 2 共50个
    local filterStep = 25
    --数据前后各去掉10个点
    local throwNum = 3

    print("period " .. period)
    step = math.floor(setting.measureResult.areaStep / tonumber(period) * 1000)

    if endIndex - startIndex > math.floor(config.measureParam.addAfterTime / period /100)*0.8  then
        area = dc:NDIRResultHandle(startIndex, endIndex, useValidCnt, step, increment, filterStep, throwNum)
        if area <= setting.measureResult.areaLowLimit then
            area = setting.measureResult.areaLowLimit + setting.measureResult.areaLowLimit*(((math.random()- 0.5)*2)*0.05)
        end
    else
        error(MeasureDataException:new())    --用户停止
        log:warn("数据长度异常")
    end
    if status == nil then
        dc:ClearBuf()
    end

    local periodFactor = period / 100

    area = area * periodFactor
    if config.system.debugMode == true then
        log:debug("LED周期系数：" .. periodFactor)
    end

    return area
end

--[[
 * @brief 快速定量或智能定量抽取液体到卤素瓶。
 * @details 以快速定量或智能定量的方法抽取指定的溶液到定量管，再压到卤素瓶,
 * @details 当出现期望事件等待超时、定量失败、达到限定体值，则进行排液后重抽，
 * @details 三次重抽仍不成功，则抛出异常。
 * @param[in] source 溶液类型。
 * @param[in] vol 溶液体积。
 * @param[in] point 定量点序号
--]]
function Operator:PumpToHalogenBottle(source, vol, point, wType)
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
    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:AutoMeterVolumeAnalyse(vol)
        if not ret then
            log:warn("PumpToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("PumpToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                self:Meter(MeterMode.Smart, source, volume, RollDirection.Suck)
                self:Drain(setting.liquidType.halogenBottleWater, volume + 5, drainSpeed)
                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What());
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end
end

function Operator:DrainFromHalogenBottle(wType)
    local point = setting.liquid.digestionRoomMeterPoint
    local pointVol= config.hardwareConfig.meterPoint.point[point].setVolume

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

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    while true do
        local err,result = pcall(function()
            self:Meter(MeterMode.Smart, setting.liquidType.halogenBottleWater, pointVol, RollDirection.Suck)
            self:DrainToWaste(pointVol, wasteType)
            failedCnt = 0
            overflowCnt = 0
            unfinishedCnt = 0
            airBubbleCnt = 0
            timeoutCnt = 0
        end)

        if not err then      -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    timeoutCnt = timeoutCnt +1
                    log:warn(result:What())
                    if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                        self:DrainToWaste(pointVol, wasteType)
                    elseif timeoutCnt >= meterTimeoutReTry then
                        self:DrainToWaste(pointVol, wasteType)
                        error (MeterExpectTimeoutException:new{liquidType = setting.liquidType.halogenBottleWater,})
                    end
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == MeterFailedException then
                    failedCnt = failedCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                    self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, 0)
                    self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType)
                elseif getmetatable(result) == MeterOverflowException then
                    overflowCnt = overflowCnt +1
                    log:warn(result:What())
                    self:DrainToWaste(pointVol, wasteType)
                elseif getmetatable(result) == MeterUnfinishedException then
                    self:DrainToWaste(pointVol, wasteType)
                    self:debugPrintf("排卤素液完成")
                    break
                elseif getmetatable(result) == MeterAirBubbleException then
                    airBubbleCnt = airBubbleCnt +1
                    log:warn(result:What());
                    self:DrainToWaste(pointVol, wasteType)
                else
                    error(result)
                end

                --定量异常处理机制
                if failedCnt >= meterFailedReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterFailedException:new{liquidType = setting.liquidType.halogenBottleWater,})
                end

                if overflowCnt >= meterOverflowReTry then
                    self:DrainToWaste(pointVol, wasteType)
                    error (MeterOverflowException:new{liquidType = setting.liquidType.halogenBottleWater,})
                end

                if airBubbleCnt >= meterAirBubbleReTry then
                    self:DrainToWaste(volume, wasteType)
                    local e = MeterAirBubbleException:new{liquidType = setting.liquidType.halogenBottleWater,}
                    log:warn(e:What())
                    ExceptionHandler.MakeAlarm(e)
                    break
                end
            else
                error(result)
            end
        else    --函数调用正常
            break
        end
    end
end

--[[
 * @brief 使用空白水加压反冲管路(无体积拆分)
 * @param[in] source        管路类型。
 * @param[in] blankVol      空白水体积。
 * @param[in] pressureVol   加压体积（不宜过大）。
 * @param[in] forcingVol    反冲体积。
 * @param[in] forcingSpeed  反冲速度。
--]]
function Operator:ForcingCleanPipe(source, blankVol, pressureVol, forcingVol, forcingSpeed)
    local wasteType = WasteType.WasteWater
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

    while true do
        local err,result = pcall(function()
            self:Meter(MeterMode.Smart, setting.liquidType.blank, blankVol, RollDirection.Suck)
            self:Drain(setting.liquidType.master, pressureVol, forcingSpeed/4)        -- 不开任何阀的情况下，给定量管泵入空气使定量管恢复常压
            self:Drain(source, forcingVol, forcingSpeed/4)
            self:DrainToWaste(0)
        end)

        if not err then      -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    timeoutCnt = timeoutCnt +1
                    log:warn(result:What())
                    if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                        self:DrainToWaste(blankVol, wasteType)
                    elseif timeoutCnt >= meterTimeoutReTry then
                        self:DrainToWaste(blankVol, wasteType)
                        error (MeterExpectTimeoutException:new{liquidType = setting.liquidType.blank,})
                    end
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == MeterFailedException then
                    failedCnt = failedCnt +1
                    log:warn(result:What())
                    if (failedCnt > 0) and (failedCnt < meterFailedReTry) then
                        self:DrainToWaste(blankVol, wasteType)
                        self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, forcingSpeed);
                        self:DrainToWaste(setting.liquid.meterCleanVolume, wasteType);
                    elseif failedCnt >= meterFailedReTry then
                        self:DrainToWaste(volume, wasteType)
                        error (MeterFailedException:new{liquidType = setting.liquidType.blank,})
                    end
                elseif getmetatable(result) == MeterOverflowException then
                    overflowCnt = overflowCnt +1
                    log:warn(result:What())
                    if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                        self:DrainToWaste(blankVol, wasteType)
                    elseif overflowCnt >= meterOverflowReTry then
                        self:DrainToWaste(blankVol, wasteType)
                        error (MeterOverflowException:new{liquidType = setting.liquidType.blank,})
                    end
                elseif getmetatable(result)== MeterUnfinishedException then
                    unfinishedCnt = unfinishedCnt +1
                    log:warn(result:What())
                    if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                        self:DrainToWaste(blankVol, wasteType)
                    elseif unfinishedCnt >= meterUnfinishedReTry then
                        self:DrainToWaste(blankVol, wasteType)
                        error (MeterUnfinishedException:new{liquidType = setting.liquidType.blank,})
                    end
                elseif getmetatable(result) == MeterAirBubbleException then
                    airBubbleCnt = airBubbleCnt +1
                    log:warn(result:What())
                    if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                        self:DrainToWaste(blankVol, wasteType)
                    elseif airBubbleCnt >= meterAirBubbleReTry then
                        self:DrainToWaste(blankVol, wasteType)
                        local e = MeterAirBubbleException:new{liquidType = setting.liquidType.blank,}
                        log:warn(e:What())
                        ExceptionHandler.MakeAlarm(e)
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

--[[
 * @brief 使用水样填充加样管，用于注射器加样，在此之前必须先执行一次零点校准液更新，保证支路无空气
 * @param[in] source        管路类型。
 * @param[in] blankVol      体积。
 * @param[in] point         定量点
 * @param[in] wType         废液类型。
 * @param[in] fType         填充类型。1.默认上定量点下压到下定量点 2.上定量点+泵计步填充 3.直接下压至下定量点填充
--]]
function Operator:FillDosingPipe(source, vol, point, wType, fType)
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

    --填充加样管路时，必须检测滑块位置
    op:SlidersSensorCheck()

    --废液类型
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end

    --填充类型
    local fillType = FillType.FillNormal
    if fType ==  FillType.FillAccurateFirst then
        fillType = FillType.FillAccurateFirst
    elseif fType ==  FillType.FillAccurateSecond then
        fillType = FillType.FillAccurateSecond
    elseif fType ==  FillType.FillAccurateEnd then
        fillType = FillType.FillAccurateEnd
    end

    local factor = self.IPeristalticPump:GetPumpFactor(0)
    local meterSpeed = setting.liquid.meterSpeed * factor * 0.8
    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor)
    self:debugPrintf("Set Meter Speed " .. (setting.liquid.meterSpeed * factor))

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor
    local maxVol = config.hardwareConfig.meterPoint.point[2].setVolume
    local minVol = config.hardwareConfig.meterPoint.point[1].setVolume

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:AutoMeterVolumeAnalyse(vol)
        if not ret then
            log:warn("MeterToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("MeterToDigestionRoom 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Accurate, setting.liquid.accurateMeterOverValue)

    for i, volume in pairs(volTable) do
        while true do
            local err,result = pcall(function()
                if fillType ==  FillType.FillNormal then
                    op:SetMeterOverValue(MeterMode.Smart, 0)
                    self:AutoCloseValve(false)
                    op:Meter(MeterMode.Smart, source, maxVol, RollDirection.Suck)

                    --self:Drain(setting.liquidType.wasteWater,  0.5, setting.liquid.meterSpeed * factor/3)

                    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor*2)
                    log:debug("Set Meter Speed " .. (setting.liquid.meterSpeed * factor*2))
                    op:SetMeterOverValue(MeterMode.Accurate, 0)

                    op:Meter(MeterMode.Direct, setting.liquidType.waste, minVol, RollDirection.Drain)
                    self:AutoCloseValve(true)
                    App.Sleep(2000)
                    self:DrainToWaste(minVol)
                    --self:AutoCloseValve(true)
                    --op:SetMeterOverValue(MeterMode.Smart, 0)
                    --
                    --op:Meter(MeterMode.Smart, source, minVol, RollDirection.Suck)
                    --
                    --self:Pump(source,  2, setting.liquid.meterSpeed * factor/1.5);
                    --
                    --self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor/3 )
                    --log:debug("Set Meter Speed " .. (setting.liquid.meterSpeed * factor/3))
                    --op:SetMeterOverValue(MeterMode.Accurate, 0)
                    --self:AutoCloseValve(false)
                    --op:Meter(MeterMode.Direct, setting.liquidType.waste, minVol, RollDirection.Drain)
                    --self:AutoCloseValve(true)
                    --App.Sleep(5000)
                    --self:DrainToWaste(minVol)
                elseif fillType ==  FillType.FillAccurateFirst then
                    op:SetMeterOverValue(MeterMode.Smart, 0)
                    op:Meter(MeterMode.Smart, source, maxVol, RollDirection.Suck)

                    self:Drain(setting.liquidType.waste, setting.liquid.fillDosingPipeFirstVolume , setting.liquid.prefabricateDrainSpeed * factor/1.3)
                    --self:Drain(setting.liquidType.wasteWater, setting.liquid.fillDosingPipeFirstVolume , drainSpeed/4)
                elseif fillType ==  FillType.FillAccurateSecond then

                    self:Drain(setting.liquidType.waste, setting.liquid.fillDosingPipeSecondVolume , setting.liquid.prefabricateDrainSpeed * factor/1.3)
                elseif fillType ==  FillType.FillAccurateEnd then
                    self.IOpticalMeter:SetMeteSpeed(setting.liquid.meterSpeed * factor*2 )
                    log:debug("Set Meter Speed " .. (setting.liquid.meterSpeed * factor*2))
                    op:SetMeterOverValue(MeterMode.Direct, 0)
                    op:Meter(MeterMode.Direct, setting.liquidType.waste, minVol, RollDirection.Drain)
                    self:DrainToWaste(minVol)
                end

                failedCnt = 0
                overflowCnt = 0
                unfinishedCnt = 0
                airBubbleCnt = 0
                timeoutCnt = 0
            end)

            if not err then      -- 出现异常
                if type(result) == "userdata" then
                    if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                        timeoutCnt = timeoutCnt +1
                        log:warn(result:What())
                        if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif timeoutCnt >= meterTimeoutReTry then
                            self:DrainToWaste(volume, wasteType)
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
                            self:DrainToWaste(volume, wasteType)
                            self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                            self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                        elseif failedCnt >= meterFailedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterFailedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterOverflowException then
                        overflowCnt = overflowCnt +1
                        log:warn(result:What())
                        if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif overflowCnt >= meterOverflowReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterOverflowException:new{liquidType = source,})
                        end
                    elseif getmetatable(result)== MeterUnfinishedException then
                        unfinishedCnt = unfinishedCnt +1
                        log:warn(result:What())
                        if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif unfinishedCnt >= meterUnfinishedReTry then
                            self:DrainToWaste(volume, wasteType)
                            error (MeterUnfinishedException:new{liquidType = source,})
                        end
                    elseif getmetatable(result) == MeterAirBubbleException then
                        airBubbleCnt = airBubbleCnt +1
                        log:warn(result:What())
                        if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                            self:DrainToWaste(volume, wasteType)
                        elseif airBubbleCnt >= meterAirBubbleReTry then
                            self:DrainToWaste(volume, wasteType)
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
            else    --函数调用正常
                break
            end
        end
    end
end

function Operator:AccurateSubMeasure(resultData, currentCnt)
    --检查是否在复位点，避免往燃烧炉排废液爆炸
    op:SlidersSensorCheck()
    --取消更新，全程测量仅更新一次即可
    --if currentCnt == 2 or currentCnt == 4 then
    --    --重新定量填充管路，确保此时逐出室内有充足的水样
    --    op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 1, nil, nil, FillType.FillAccurateEnd)
    --elseif currentCnt == 1 or currentCnt == 3 then
    --    --重新定量填充管路，确保此时逐出室内有充足的水样
    --    op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 1, nil, nil, FillType.FillAccurateFirst)
    --end

    --等待稳定  高量程在移动滑块之前判断基线稳定
    for i = 1, config.measureParam.baseLineCheckCnt do
        op:BaseLineCheck()
        dc:ClearBuf()
    end
    --设置基线状态
    UpdateWidgetManager.Instance():Update(UpdateEvent.BaseLineStatusChanged, "Ok")

    --停止更新基线状态
    status.measure.isCheckBaseLine = false
    ConfigLists.SaveMeasureStatus()

    UpdateWidgetManager.Instance():Update(UpdateEvent.PeakStatusChanged, "Clear")
    UpdateWidgetManager.Instance():Update(UpdateEvent.PeakStatusChanged, "Start")

    if not Measurer.flow:Wait(config.measureParam.addBeforeTime) then
        error(UserStopException:new())
    end
    dc:ClearBuf()

    resultData.startIndex = dc:GetScanLen()   --标记开始
    log:debug("精准模式第 " .. currentCnt .. "次标记开始： ".. resultData.startIndex);

    --if not Measurer.flow:Wait(30) then
    --    error(UserStopException:new())
    --end

    --滑块进样
    op:SlidersMovingWithSensor()

    if not Measurer.flow:Wait(5) then
        error(UserStopException:new())
    end

    op:SyringToStove(setting.measureResult.startReactVolume, config.measureParam.addSampleCnt)

    if not Measurer.flow:Wait(10) then
        error(UserStopException:new())
    end
end

--[[
 * @brief 精准测量模式
 * @param[in] resultData    Measurer.measureResult数据入口，用于给startIndex,ednIndex,peakArea赋值。
 * @param[in] 精准测量动作流程: 滑块复位->等待第一次测量结果->精准模式填充管路(剩余体积定量到下定量点)->相同的加样流程
 * @param[in] 如果修改普通测量加样流程，就必须同步修改精准测量模式/校准加样流程，确保两者流程一致
--]]
function Operator:AccurateMeasure(resultData)
    local runAction = Helper.Status.SetAction(setting.runAction.measure.accurateMeasureMode)
    StatusManager.Instance():SetAction(runAction)

    --------第一次精准测量反应---------
    --第1次加样结束，滑块复位，在外面等待测量结果
    op:SlidersMovingWithSensor()

    if not Measurer.flow:Wait(config.measureParam.addAfterTime/2) then
        error(UserStopException:new())
    end
    Measurer:CalibrateMeasureEndJudge(config.measureParam.addAfterTime/2)
    --if not Measurer.flow:Wait(40) then
    --    error(UserStopException:new())
    --end

    resultData.endIndex = dc:GetScanLen()   --标记结束
    log:debug("精准模式标记结束： " .. resultData.endIndex);
    resultData.accurateArea1 = op:CalculatePeakArea(resultData.startIndex, resultData.endIndex, nil, nil, Measurer.measureType)
    log:debug("精准模式第 " .. 1 .." 次面积： ".. resultData.accurateArea1)
    resultData.endTemperature = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
    log:debug("测量结束制冷温度： " .. resultData.endTemperature);

    --------精准测量第二次管路填充&加样---------
    self:AccurateSubMeasure(resultData, 2)
    --第2次加样结束，滑块复位，在外面等待测量结果
    op:SlidersMovingWithSensor()

    if not Measurer.flow:Wait(config.measureParam.addAfterTime/2) then
        error(UserStopException:new())
    end
    Measurer:CalibrateMeasureEndJudge(config.measureParam.addAfterTime/2)
    --if not Measurer.flow:Wait(40) then
    --    error(UserStopException:new())
    --end

    resultData.endIndex = dc:GetScanLen()   --标记结束
    log:debug("精准模式标记结束： " .. resultData.endIndex);
    resultData.accurateArea2 = op:CalculatePeakArea(resultData.startIndex, resultData.endIndex, nil, nil, Measurer.measureType)
    log:debug("精准模式第 " .. 2 .." 次面积： ".. resultData.accurateArea2)
    resultData.endTemperature = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
    log:debug("测量结束制冷温度： " .. resultData.endTemperature);

    local deviation12, deviation23, deviation13
    deviation12 = math.abs(resultData.accurateArea2 - resultData.accurateArea1)/((resultData.accurateArea2 + resultData.accurateArea1)/2)
    log:debug("精准测量面积1 =  " .. resultData.accurateArea1 .. ", 面积2 = " .. resultData.accurateArea2 ..
            ", 偏差阈值 = " .. config.measureParam.accurateMeasureDeviation .. ", 精准测量面积12偏差 = " .. deviation12)
    if deviation12 < config.measureParam.accurateMeasureDeviation then
        resultData.peakArea = (resultData.accurateArea2 + resultData.accurateArea1)/2
        setting.measureResult.immediatelyResultHandle = true
        setting.measureResult.isFinishAccurateMeasure = true
        return 0
    end
    --------精准测量第二次结束---------


    --------精准测量第三次管路填充&加样---------
    self:AccurateSubMeasure(resultData, 3)
    --第3次加样结束，滑块复位，在外面等待测量结果
    op:SlidersMovingWithSensor()

    if not Measurer.flow:Wait(config.measureParam.addAfterTime/2) then
        error(UserStopException:new())
    end
    Measurer:CalibrateMeasureEndJudge(config.measureParam.addAfterTime/2)
    --if not Measurer.flow:Wait(40) then
    --    error(UserStopException:new())
    --end

    resultData.endIndex = dc:GetScanLen()   --标记结束
    log:debug("精准模式标记结束： " .. resultData.endIndex);
    resultData.accurateArea3 =  op:CalculatePeakArea(resultData.startIndex, resultData.endIndex, nil, nil, Measurer.measureType)
    log:debug("精准模式第 " .. 3 .." 次面积： ".. resultData.accurateArea3)
    resultData.endTemperature = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
    log:debug("测量结束制冷温度： " .. resultData.endTemperature);

    deviation23 = math.abs(resultData.accurateArea3 - resultData.accurateArea2)/((resultData.accurateArea3 + resultData.accurateArea2)/2)
    deviation13 = math.abs(resultData.accurateArea3 - resultData.accurateArea1)/((resultData.accurateArea3 + resultData.accurateArea1)/2)
    log:debug("精准测量面积2 =  " .. resultData.accurateArea2 .. ", 面积3 = " .. resultData.accurateArea3 ..
            ", 偏差阈值 = " .. config.measureParam.accurateMeasureDeviation .. ", 精准测量面积23偏差 = " .. deviation23)
    log:debug("精准测量面积1 =  " .. resultData.accurateArea1 .. ", 面积3 = " .. resultData.accurateArea3 ..
            ", 偏差阈值 = " .. config.measureParam.accurateMeasureDeviation .. ", 精准测量面积13偏差 = " .. deviation13)
    if deviation23 < config.measureParam.accurateMeasureDeviation
            or deviation13 < config.measureParam.accurateMeasureDeviation  then
        setting.measureResult.immediatelyResultHandle = true
        setting.measureResult.isFinishAccurateMeasure = true
        if deviation23 < config.measureParam.accurateMeasureDeviation then
            resultData.peakArea = (resultData.accurateArea3 + resultData.accurateArea2)/2
        else
            resultData.peakArea = (resultData.accurateArea3 + resultData.accurateArea1)/2
        end

        return 0
    end

    self:AccurateSubMeasure(resultData, 4)
    setting.measureResult.isFinishAccurateMeasure = true
end

--[[
 * @brief 管路加样
 * @param[in] resultData    Measurer.measureResult数据入口，用于给startIndex,ednIndex,peakArea赋值。
 * @param[in] 普通测量动作加样流程: 基线判断->普通模式填充管路(上定量点定量到下定量点)->加样->滑块复位
 * @param[in] 如果修改普通测量加样流程，就必须同步修改精准测量模式加样流程，确保两者流程一致
--]]
function Operator:AddDosingToStove(resultData)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    resultData.startIndex = 0
    resultData.endIndex = 0

    --等待稳定  高量程在移动滑块之前判断基线稳定
    for i = 1, config.measureParam.baseLineCheckCnt do
        op:BaseLineCheck()
        dc:ClearBuf()
    end
    --设置基线状态
    UpdateWidgetManager.Instance():Update(UpdateEvent.BaseLineStatusChanged, "Ok")
    --停止更新基线状态
    status.measure.isCheckBaseLine = false
    ConfigLists.SaveMeasureStatus()
    UpdateWidgetManager.Instance():Update(UpdateEvent.PeakStatusChanged, "Clear")
    UpdateWidgetManager.Instance():Update(UpdateEvent.PeakStatusChanged, "Start")

    local thermostatTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
    local carriagePressture = dc:GetPressure(setting.pressure.pressureCarry)
    log:debug("气体温度：" .. thermostatTemp .. ", 载气压力：" ..carriagePressture)

    if not Measurer.flow:Wait(5) then
        error(UserStopException:new())
    end
    dc:ClearBuf()

    if resultData ~= nil then
        local num = dc:GetScanLen()
        if num ~= nil then
            resultData.startIndex = num
        end

        if setting.measureResult.isStartAccurateMeasure == true then --精准测量模式
            log:debug("精准模式标记开始： " .. resultData.startIndex);
        else
            log:debug("标记开始： " .. resultData.startIndex);
        end
        resultData.startTemperature = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
        log:debug("测量开始温度： " .. resultData.startTemperature);
    end

    --if not Measurer.flow:Wait(30) then
    --    error(UserStopException:new())
    --end

    --进样
    op:SlidersMovingWithSensor()

    if not Measurer.flow:Wait(config.measureParam.addBeforeTime) then
        error(UserStopException:new())
    end
    op:SyringToStove(setting.measureResult.startReactVolume, config.measureParam.addSampleCnt)

    if not Measurer.flow:Wait(10) then
        error(UserStopException:new())
    end


    --精准测量模式
    if setting.measureResult.isStartAccurateMeasure == true then
        self:AccurateMeasure(resultData)
        setting.measureResult.isStartAccurateMeasure = false
    end

    resultData.lastAccurateMeasureTime = os.time()

    --进样复位
    op:SlidersMovingWithSensor()

    --检查是否在复位点，避免往燃烧炉排废液爆炸
    op:SlidersSensorCheck()

    flowManager:ClearAllRemainEvent()

end

--[[
 * @brief 校准管路加样(与普通加样流程一致，但不关联精准测量模式)
 * @param[in] resultData    Measurer.measureResult数据入口，用于给startIndex,ednIndex,peakArea赋值。
 * @param[in]
 * @param[in] 如果修改普通测量加样流程，就必须同步修改精准测量模式/校准加样流程，确保两者流程一致
--]]
function Operator:AddDosingToStoveCalibrate(resultData)
    local flowManager = FlowManager.Instance()
    flowManager:ClearAllRemainEvent()

    resultData.startIndex = 0
    resultData.endIndex = 0

    --等待稳定  高量程在移动滑块之前判断基线稳定
    for i = 1, config.measureParam.baseLineCheckCnt do
        op:BaseLineCheck()
        dc:ClearBuf()
    end
    --设置基线状态
    UpdateWidgetManager.Instance():Update(UpdateEvent.BaseLineStatusChanged, "Ok")
    --停止更新基线状态
    status.measure.isCheckBaseLine = false
    ConfigLists.SaveMeasureStatus()
    UpdateWidgetManager.Instance():Update(UpdateEvent.PeakStatusChanged, "Clear")
    UpdateWidgetManager.Instance():Update(UpdateEvent.PeakStatusChanged, "Start")

    local thermostatTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
    local carriagePressture = dc:GetPressure(setting.pressure.pressureCarry)
    log:debug("气体温度：" .. thermostatTemp .. ", 载气压力：" ..carriagePressture)

    if not Measurer.flow:Wait(config.measureParam.addBeforeTime) then
        error(UserStopException:new())
    end
    dc:ClearBuf()

    if resultData ~= nil then
        local num = dc:GetScanLen()
        if num ~= nil then
            resultData.startIndex = num
        end

        if setting.measureResult.isStartAccurateMeasure == true then --精准测量模式
            log:debug("精准模式标记开始： " .. resultData.startIndex);
        else
            log:debug("标记开始： " .. resultData.startIndex);
        end
        resultData.startTemperature = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
        log:debug("测量开始温度： " .. resultData.startTemperature);
    end

    --if not Measurer.flow:Wait(30) then
    --    error(UserStopException:new())
    --end

    --进样
    op:SlidersMovingWithSensor()

    if not Measurer.flow:Wait(5) then
        error(UserStopException:new())
    end

    op:SyringToStove(setting.measureResult.startReactVolume, config.measureParam.addSampleCnt)

    if not Measurer.flow:Wait(10) then
        error(UserStopException:new())
    end

    resultData.lastAccurateMeasureTime = os.time()

    --进样复位
    op:SlidersMovingWithSensor()

    --检查是否在复位点，避免往燃烧炉排废液爆炸
    op:SlidersSensorCheck()

    flowManager:ClearAllRemainEvent()

end

function Operator:CleanDosingPipe(source, vol, point, wType, isDirectClean)
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
    local maxVol = config.hardwareConfig.meterPoint.point[2].setVolume
    local minVol = config.hardwareConfig.meterPoint.point[1].setVolume

    --废液类型
    local wasteType = WasteType.WasteWater
    if wType ==  WasteType.WasteReagent or wType == setting.liquidType.waste then
        wasteType = WasteType.WasteReagent
    end

    --填充加样管路时，必须检测滑块位置
    op:SlidersSensorCheck()

    local factor = self.IPeristalticPump:GetPumpFactor(0)

    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor

    -- 获取操作的体积分解列表
    local ret = nil
    local volTable = {}
    if point == nil then
        ret,volTable = self:AutoMeterVolumeAnalyse(vol)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    else
        ret,volTable = self:AccurateMeterVolumeAnalyse(vol, point)
        if not ret then
            log:warn("CleanMeterPipe 体积分解异常")
            error (MeterFailedException:new{liquidType = source,})
        end
    end

    -- 设置定量过冲程度
    self:SetMeterOverValue(MeterMode.Smart, 0)

    for i, volume in pairs(volTable) do
        local err,result = pcall(function()
            self.IOpticalMeter:SetMeteSpeed(setting.liquid.drainSpeed * factor)
            self:debugPrintf("Set Meter Speed " .. (setting.liquid.drainSpeed * factor))
            op:SetMeterOverValue(MeterMode.Smart, 0)

            op:Meter(MeterMode.Smart, source, maxVol, RollDirection.Suck)
            self:DrainToWaste(maxVol, WasteType.WasteReagent)

            failedCnt = 0
            overflowCnt = 0
            unfinishedCnt = 0
            airBubbleCnt = 0
            timeoutCnt = 0
        end)

        if not err then      -- 出现异常
            if type(result) == "userdata" then
                if result:GetType() == "ExpectEventTimeoutException" then          --事件超时异常。
                    timeoutCnt = timeoutCnt +1
                    log:warn(result:What());
                    if (timeoutCnt > 0) and (timeoutCnt < meterTimeoutReTry) then
                        self:DrainToWaste(volume, wasteType)
                    elseif timeoutCnt >= meterTimeoutReTry then
                        self:DrainToWaste(volume, wasteType)
                        error (MeterExpectTimeoutException:new{liquidType = source,})
                    end
                else
                    error(result)
                end
            elseif type(result) == "table" then
                if getmetatable(result) == MeterFailedException then
                    failedCnt = failedCnt +1
                    log:warn(result:What())
                    --if (failedCnt > 0) and (failedCnt < meterFailedReTry) then
                    --    self:DrainToWaste(volume, wasteType)
                    --    self:Pump(setting.liquidType.blank,  setting.liquid.meterCleanVolume, drainSpeed);
                    --    self:DrainToWaste( setting.liquid.meterCleanVolume, wasteType);
                    --elseif failedCnt >= meterFailedReTry then
                    --    self:DrainToWaste(volume, wasteType)
                    --    error (MeterFailedException:new{liquidType = source,})
                    --end
                    --self:DrainToWaste(volume, wasteType)
                    --log:debug("清洗加液管失败")
                    self:DrainToWaste(maxVol, WasteType.WasteReagent)
                    break
                elseif getmetatable(result) == MeterOverflowException then
                    overflowCnt = overflowCnt +1
                    log:warn(result:What())
                    if (overflowCnt > 0) and (overflowCnt < meterOverflowReTry) then
                        self:DrainToWaste(volume, wasteType)
                    elseif overflowCnt >= meterOverflowReTry then
                        self:DrainToWaste(volume, wasteType)
                        error (MeterOverflowException:new{liquidType = source,})
                    end
                elseif getmetatable(result)== MeterUnfinishedException then
                    unfinishedCnt = unfinishedCnt +1
                    log:warn(result:What())
                    --if (unfinishedCnt > 0) and (unfinishedCnt < meterUnfinishedReTry) then
                    --    self:DrainToWaste(volume, wasteType)
                    --elseif unfinishedCnt >= meterUnfinishedReTry then
                    --    self:DrainToWaste(volume, wasteType)
                    --    error (MeterUnfinishedException:new{liquidType = source,})
                    --end
                    self:DrainToWaste(maxVol)
                    break
                elseif getmetatable(result) == MeterAirBubbleException then
                    airBubbleCnt = airBubbleCnt +1
                    log:warn(result:What())
                    if (airBubbleCnt > 0) and (airBubbleCnt < meterAirBubbleReTry) then
                        self:DrainToWaste(volume, wasteType)
                    elseif airBubbleCnt >= meterAirBubbleReTry then
                        self:DrainToWaste(volume, wasteType)
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
        end
    end

    self:SecludeLiquid(setting.liquidType.wasteWater)
end
