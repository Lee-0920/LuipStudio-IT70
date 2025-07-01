
Measurer =
{
    flow = nil,
    measureType = MeasureType.Sample,
    currentRange = 1,
    addParam = {},
    temperatureBeforeAddReagent2 = 0,


    measureResult =
    {
        initReferenceAD =0,      		-- 初始参考AD值
        initMeasureAD =0,         		-- 初始测量AD值
        finalReferenceAD =0,    	 	-- 结果参考AD值
        finalMeasureAD =0,        		-- 结果参考AD值
        initRefrigeratorTemp =0,        -- 初始制冷模块温度
        initNDIRTemp =0,                -- 初始测量模块温度
        finalRefrigeratorTemp =0,       -- 反应制冷模块温度
        finalNDIRTemp =0,               -- 反应测量模块温度
        initThermostatTemp =0,    		-- 读初始值时的消解室温度
        initEnvironmentTemp =0,   	    -- 初始上机箱温度
        initEnvironmentTempDown =0,     -- 初始下机箱温度
        finalThermostatTemp =0,   	    -- 读反应值时的消解室温度
        finalEnvironmentTemp =0,  	    -- 反应值上机箱温度
        finalEnvironmentTempDown =0,    -- 反应值下机箱温度
        startIndex = 0,                 -- 读反应值数组开始索引
        endIndex = 0,                   -- 读反应值数组结束索引
        peakArea = 0,                   -- 结果峰面积数值
        accurateArea1 = 0,              --精准测量面积1
        accurateArea2 = 0,              --精准测量面积2
        accurateArea3 = 0,              --精准测量面积3
        accurateArea4 = 0,              --精准测量面积4
        measureDate = os.time(),         --测量日期
        lastMeasureDate = os.time(),     --上一次测量日期
        lastAccurateMeasureTime = 0,
        startTemperature = 0,
        endTemperature = 0,
    },

    procedure = {},

    steps =
    {
        --1 等待气路稳定
        {
            action = setting.runAction.measure.airFlowCheck,
            execute = function()
                local startTime = os.time()
                --连续测量时间管理
                if config.scheduler.measure.mode == MeasureMode.Continous then
                    if setting.measureResult.continousModeParam.currentMeasureCnt == 0 then
                        Measurer.measureResult.measureDate = os.time()
                        Measurer.measureResult.lastMeasureDate = os.time()
                        --打开氮气气路
                        --op:TurnOnNirtrogen()
                        dc:GetIOpticalAcquire():TurnOnLED()	--开LED
                    else
                        Measurer.measureResult.measureDate = Measurer.measureResult.lastMeasureDate
                        Measurer.measureResult.lastMeasureDate = os.time()
                    end
                else
                    Measurer.measureResult.lastMeasureDate = os.time()
                    --打开氮气气路
                    --op:TurnOnNirtrogen()
                    dc:GetIOpticalAcquire():TurnOnLED()	--开LED
                end

                --检测是否达到反应温度
                op:IsReactTemperature(Measurer.flow)
                --检测总阀压力
                op:WaitAirFlow(Measurer.flow)
                --检测载气压力
                op:ConfirmAirFlow(true)

                Measurer.measureResult.initRefrigeratorTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
                Measurer.measureResult.initNDIRTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
                Measurer.measureResult.initThermostatTemp = dc:GetDigestTemperature()
                Measurer.measureResult.initEnvironmentTemp = dc:GetEnvironmentTemperature()
                Measurer.measureResult.initEnvironmentTempDown = dc:GetReportThermostatTemp(setting.temperature.temperatureBoxLow)
                log:debug("检测载气时间 = " .. os.time() - startTime);
            end
        },
        --2 DrainBeforeMeasure 测量前排液
        {
            action = setting.runAction.measure.drainBeforeMeasure,
            execute = function()
                local startTime = os.time()

                --进样复位检测
                op:SlidersSensorCheck()

                --非连续测量模式测量前排一次冷凝水
                if setting.measureResult.continousModeParam.currentMeasureCnt == 0 then
                    op:DrainToWaste(0)
                    op:DrainFromDigestionRoom()

                    --if  config.scheduler.measure.mode == MeasureMode.Continous then
                    --    local runAction = Helper.Status.SetAction(setting.runAction.suckRefrigeratorWater)
                    --    StatusManager.Instance():SetAction(runAction)
                    --    op:DrainFromRefrigeratorWaterRoom()
                    --end
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                log:debug("测量前排液时间 = " .. os.time() - startTime);
            end
        },
        --3 CleanBeforeMeasure 测量前清洗
        {
            action = setting.runAction.measure.cleanBeforeMeasure,
            execute = function()
                local startTime = os.time()

                if Measurer.measureType ~= MeasureType.Sample then
                    op:PumpToDigestionRoom(setting.liquidType.blank,  8)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)

                    op:ExposureTurnOn(config.measureParam.exposurePressure*1.2)

                    if not Measurer.flow:Wait(60) then
                        error(UserStopException:new())
                    end

                    op:ExposureTurnOff()

                    op:DrainFromDigestionRoom()
                end

                -- 零点校准液清洗消解器
                if config.measureParam.cleanBefMeaBlankVol > 0 then
                    op:PumpToDigestionRoom(setting.liquidType.blank,  config.measureParam.cleanBefMeaBlankVol)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                    op:DrainFromDigestionRoom()
                end

                if Measurer:TimeCheck() then
                    log:debug("二次清洗")
                    status.measure.lastMeasureEndTime = os.time()
                    ConfigLists.SaveMeasureStatus()
                    -- 零点校准液清洗消解器
                    op:PumpToDigestionRoom(setting.liquidType.blank, setting.unitVolume * 2, nil)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                    op:DrainFromDigestionRoom()
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                log:debug("测量前清洗时间 = " .. os.time() - startTime);
            end
        },
        --4 Rinse 润洗
        {
            action = setting.runAction.measure.rinse,
            execute = function()
                local startTime = os.time()

                -- 根据测量类型获取对应的润洗体积，其中包括判断上次测量间隔时间是否超过36h
                --local RinseVolume = Measurer:GetRinseVol()
                local RinseVolume = setting.unitVolume * 4
                --local RinseVolume =  config.hardwareConfig.meterPoint.point[2].realVolume
                if Measurer.addParam.rinseEnable == true then
                    --润洗加水样
                    if Measurer.addParam.rinseSampleVolume > 0 then
                        if config.measureParam.sampleRenewVolume > 0 then
                            op:CleanMeterPipe(setting.liquidType.sample, config.measureParam.sampleRenewVolume, PointNum.First) --水样管路更新
                        end
                        op:CleanMeterPipe(setting.liquidType.sample, RinseVolume)
                        --op:RinseMeterPipeWithSuck(setting.liquidType.sample, RinseVolume)  --清洗定量管
                        --op:RinseMeterPipeWithSuck(setting.liquidType.sample, RinseVolume)  --清洗定量管
                    end

                    --润洗加量程校准液
                    if Measurer.addParam.rinseStandardVolume > 0 then
                        --op:RinseMeterPipeWithSuck(setting.liquidType.standard, RinseVolume)  --清洗定量管
                        --op:RinseMeterPipeWithSuck(setting.liquidType.standard, RinseVolume)  --清洗定量管
                        op:CleanMeterPipe(setting.liquidType.standard, RinseVolume)
                    end

                    --润洗加零点核查液
                    if Measurer.addParam.rinseZeroCheckVolume > 0 then
                        --op:CleanMeterPipe(setting.liquidType.zeroCheck, 0.5, PointNum.First)
                        --op:RinseMeterPipeWithSuck(setting.liquidType.zeroCheck, RinseVolume)  --清洗定量管
                        --op:RinseMeterPipeWithSuck(setting.liquidType.zeroCheck, RinseVolume)  --清洗定量管
                        op:CleanMeterPipe(setting.liquidType.zeroCheck, RinseVolume)
                    end

                    --润洗加量程核查液
                    if Measurer.addParam.rinseRangeCheckVolume > 0 then
                        --op:CleanMeterPipe(setting.liquidType.rangeCheck, 0.5, PointNum.First)
                        --op:RinseMeterPipeWithSuck(setting.liquidType.rangeCheck, RinseVolume)  --清洗定量管
                        --op:RinseMeterPipeWithSuck(setting.liquidType.rangeCheck, RinseVolume)  --清洗定量管
                        op:CleanMeterPipe(setting.liquidType.rangeCheck, RinseVolume)
                    end
                    --润洗加零点校准液
                    if Measurer.addParam.rinseBlankVolume > 0 then
                        --op:CleanMeterPipe(setting.liquidType.blank, 0.5, PointNum.First)
                        op:CleanMeterPipe(setting.liquidType.blank, RinseVolume)
                    end
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                if config.measureParam.accurateMeasure == true then
                    setting.measureResult.isStartAccurateMeasure = true
                else
                    setting.measureResult.isStartAccurateMeasure = false
                end
                --核查默认开启精准测量
                if Measurer.measureType == MeasureType.RangeCheck or Measurer.measureType == MeasureType.ZeroCheck then
                    if config.measureParam.accurateCheck == true then
                        setting.measureResult.isStartAccurateMeasure = true
                    end
                end

                log:debug("润洗时间 = " .. os.time() - startTime);
            end
        },
        --5 AddMeasureSample 加待测样
        {
            action = setting.runAction.measure.addSample,
            execute = function()
                local startTime = os.time()
                local cleanMeterPipevolume = config.hardwareConfig.meterPoint.point[2].setVolume
                --加水样
                if Measurer.addParam.sampleVolume > 0 then
                    if Measurer.currentRange <= 2 then
                        op:MeterToDigestionRoom(setting.liquidType.sample, Measurer.addParam.sampleVolume)
                    else
                        op:IndirectMeterToDigestionRoom(setting.liquidType.sample, Measurer.addParam.sampleVolume)
                    end

                    Measurer:ContinousModeCheckResult() --检查测量是否完成
                    op:DrainLiquid(setting.liquidType.sample, setting.liquid.samplePipeVolume + config.measureParam.extendSamplePipeVolume)

                    local CleanPipeTimes = 1        -- 清洗次数
                    if true == config.measureParam.wasteWaterEnvironment then   -- 抗污模式清洗两次
                        CleanPipeTimes = 2
                    end

                    if Measurer.currentRange <= 2 then
                        --CleanPipeTimes = CleanPipeTimes + 1
                    else
                        CleanPipeTimes = CleanPipeTimes + 1
                    end

                    for i=1,CleanPipeTimes do
                        op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)
                    end

                    Measurer:ContinousModeCheckResult() --检查测量是否完成

                    -- 定量零点校准液，加压反冲水样管
                    local factor = dc:GetIPeristalticPump():GetPumpFactor(0)
                    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor
                    op:SetMeterOverValue(MeterMode.Smart, 0)
                    op:ForcingCleanPipe(setting.liquidType.sample, 1, 0.5, 0.5, drainSpeed)
                    --加待测样后清洗水样管
                    if config.measureParam.cleanSampleVol > 0 then
                        op:DrainToWaste(0)
                        op:MeterToSample(setting.liquidType.blank, config.measureParam.cleanSampleVol)
                        op:SecludeLiquid(setting.liquidType.blank)
                        op:DrainLiquid(setting.liquidType.sample, setting.liquid.samplePipeVolume + config.measureParam.extendSamplePipeVolume)
                    end
                end

                if config.interconnection.collectSampleMode == setting.mode.collectSample.toAddSampleEnd then
                    local waterCollector = WaterCollector.Instance()
                    if not string.find(config.info.instrument["type"], "PT63P") then
                        waterCollector:TurnOff()
                    end
                    Helper.Result.RelayOutOperate(setting.mode.relayOut.collectInstruct, false)
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                --加量程校准液
                if Measurer.addParam.standardVolume > 0 then
                    if Measurer.currentRange <= 2 then
                        op:MeterToDigestionRoom(setting.liquidType.standard, Measurer.addParam.standardVolume)
                    else
                        op:IndirectMeterToDigestionRoom(setting.liquidType.standard, Measurer.addParam.standardVolume)
                    end
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.standard)

                    local CleanPipeTimes = 1        -- 清洗次数
                    if true == config.measureParam.wasteWaterEnvironment then   -- 抗污模式清洗两次
                        CleanPipeTimes = 2
                    end
                    if Measurer.currentRange <= 2 then
                        --CleanPipeTimes = CleanPipeTimes + 1
                    else
                        CleanPipeTimes = CleanPipeTimes + 1
                    end

                    for i=1,CleanPipeTimes do
                        op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)
                    end
                end

		        --加零点核查液
                if Measurer.addParam.zeroCheckVolume > 0 then
                    if Measurer.currentRange <= 2 then
                        op:MeterToDigestionRoom(setting.liquidType.zeroCheck, Measurer.addParam.zeroCheckVolume)
                    else
                        op:IndirectMeterToDigestionRoom(setting.liquidType.zeroCheck, Measurer.addParam.zeroCheckVolume)
                    end
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.zeroCheck)

                    local CleanPipeTimes = 1        -- 清洗次数
                    if true == config.measureParam.wasteWaterEnvironment then   -- 抗污模式清洗两次
                        CleanPipeTimes = 2
                    end
                    if Measurer.currentRange <= 2 then
                        --CleanPipeTimes = CleanPipeTimes + 1
                    else
                        CleanPipeTimes = CleanPipeTimes + 1
                    end

                    for i=1,CleanPipeTimes do
                        op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)
                    end
                end

                --加量程核查液
                if Measurer.addParam.rangeCheckVolume > 0 then
                    if Measurer.currentRange <= 2 then
                        op:MeterToDigestionRoom(setting.liquidType.rangeCheck, Measurer.addParam.rangeCheckVolume)
                    else
                        op:IndirectMeterToDigestionRoom(setting.liquidType.rangeCheck, Measurer.addParam.rangeCheckVolume)
                    end
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.rangeCheck)

                    local CleanPipeTimes = 1        -- 清洗次数
                    if true == config.measureParam.wasteWaterEnvironment then   -- 抗污模式清洗两次
                        CleanPipeTimes = 2
                    end
                    if Measurer.currentRange <= 2 then
                        --CleanPipeTimes = CleanPipeTimes + 1
                    else
                        CleanPipeTimes = CleanPipeTimes + 1
                    end

                    for i=1,CleanPipeTimes do
                        op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)
                    end
                end

                --加零点校准液
                if Measurer.addParam.blankVolume > 0 then
                    op:MeterToDigestionRoom(setting.liquidType.blank, Measurer.addParam.blankVolume)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                --第1次定量稀释抽取混合液体积
                if Measurer.addParam.dilutionExtractVolume1 > 0 then
                    op:AirToDigestionRoom(20)
                    op:MeterFromDigestionRoom(Measurer.addParam.dilutionExtractVolume1)
                    op:SecludeLiquid(setting.liquidType.digestionRoom)
                    op:CleanMeterPipe(setting.liquidType.blank, 0.5)  --清洗定量管
                    op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)  --清洗定量管
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                --第1次定量稀释加零点校准液体积
                if Measurer.addParam.dilutionAddBlankVolume1 > 0 then
                    op:MeterToDigestionRoom(setting.liquidType.blank, Measurer.addParam.dilutionAddBlankVolume1)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                --第2次定量稀释抽取混合液体积
                if Measurer.addParam.dilutionExtractVolume2 > 0 then
                    op:AirToDigestionRoom(20)
                    op:MeterFromDigestionRoom(Measurer.addParam.dilutionExtractVolume2)
                    op:SecludeLiquid(setting.liquidType.digestionRoom)
                    op:CleanMeterPipe(setting.liquidType.blank, 0.5)  --清洗定量管
                    op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)  --清洗定量管
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                --第2次定量稀释加零点校准液体积
                if Measurer.addParam.dilutionAddBlankVolume2 > 0 then
                    op:MeterToDigestionRoom(setting.liquidType.blank, Measurer.addParam.dilutionAddBlankVolume2)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                end

                --第3次定量稀释抽取混合液体积
                if Measurer.addParam.dilutionExtractVolume3 > 0 then
                    op:AirToDigestionRoom(20)
                    op:MeterFromDigestionRoom(Measurer.addParam.dilutionExtractVolume3)
                    op:SecludeLiquid(setting.liquidType.digestionRoom)
                    op:CleanMeterPipe(setting.liquidType.blank, 0.5)  --清洗定量管
                    op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)  --清洗定量管
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                --第3次定量稀释加零点校准液体积
                if Measurer.addParam.dilutionAddBlankVolume3 > 0 then
                    op:MeterToDigestionRoom(setting.liquidType.blank, Measurer.addParam.dilutionAddBlankVolume3)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                log:debug("加待测样时间 = " .. os.time() - startTime);

            end
        },
        --6 AddReagent1 加试剂一
        {
            action = setting.runAction.measure.addReagent1,
            execute = function()
                local startTime = os.time()
                --op:CleanMeterPipe(setting.liquidType.reagent1, 0.5)
                --op:MeterToDigestionRoom(setting.liquidType.reagent1, setting.liquid.reagent1Volume)
                op:SlowMeterToDigestionRoom(setting.liquidType.reagent1, setting.liquid.reagent1Volume)
                --op:CombineMeterToDigestionRoom(setting.liquidType.reagent1, setting.liquid.reagent1Volume)

                op:DrainToWaste(0)
                op:SecludeLiquid(setting.liquidType.reagent1)

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                log:debug("加试剂一时间 = " .. os.time() - startTime);
                end
        },
        --7 exposure 曝气
        {
            action = setting.runAction.measure.exposureNirtrogen,
            execute = function()
                local startTime = os.time()
                op:Exposure(setting.liquidType.exposureNirtrogen, config.measureParam.exposureTime)

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                log:debug("曝气时间 = " .. os.time() - startTime)
            end
        },
        --8 管路更新
        {
            action = setting.runAction.measure.updateTime,
            execute = function()
                local startTime = os.time()
                op:SyringUpdateAir(1)
                --op:SyringUpdate(config.measureParam.syringeUpdateCnt)
                if setting.measureResult.isStartAccurateMeasure == true  then --精准测量模式管路更新
                    --if setting.measureResult.continousModeParam.currentMeasureCnt ~= 0 then
                    --    local runAction = Helper.Status.SetAction(setting.runAction.suckRefrigeratorWater)
                    --    StatusManager.Instance():SetAction(runAction)
                    --    op:DrainFromRefrigeratorWaterRoom()
                    --end

                    local runAction = Helper.Status.SetAction(setting.runAction.measure.updateTime)
                    StatusManager.Instance():SetAction(runAction)
                    --op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 1, nil, nil, FillType.FillAccurateFirst)
                    --管路更新一次 0.3ml 可使用3——4次
                    if Measurer.currentRange <= 3 then
                        op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                    else
                        op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                        op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                        op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                    end
                else
                    if Measurer.currentRange <= 3 then
                        op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                    else
                        op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                        op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                        op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                    end
                end
                op:SyringToWaste(setting.measureResult.startReactVolume/config.measureParam.addSampleCnt)
                Measurer:ContinousModeCheckResult() --检查测量是否完成

                log:debug("管路更新时间 = " .. os.time() - startTime)
            end
        },
        --9 加样等待
        {
            action = setting.runAction.measure.baseLineCheck,
            execute = function()

                if setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                    local startTime = os.time()
                    --连续测量的第二次开始，每次都在此处等待剩余的时长
                    if setting.measureResult.continousModeParam.currentMeasureCnt ~= 0 then
                        local runAction = Helper.Status.SetAction(setting.runAction.measure.waittingResult)
                        StatusManager.Instance():SetAction(runAction)
                        log:debug("currentMeasureCnt: " .. setting.measureResult.continousModeParam.currentMeasureCnt)
                        log:debug("lastStartIndex: " .. setting.measureResult.continousModeParam.lastStartIndex)

                        Measurer.measureResult.endIndex = 0
                        Measurer.measureResult.startIndex = setting.measureResult.continousModeParam.lastStartIndex

                        local reactTime = config.measureParam.addAfterTime

                        local restTime = os.time() - Measurer.measureResult.lastAccurateMeasureTime
                        log:debug("restTime: " .. (reactTime - restTime) .. ", done: " .. restTime)

                        if restTime < reactTime or setting.measureResult.immediatelyResultHandle == false then
                            if not Measurer.flow:Wait(reactTime - restTime) then
                                error(UserStopException:new())
                            end
                        end

                        Measurer:Handle(Measurer.measureResult)

                        if Measurer.flow.ResultHandle then
                            Measurer.flow:ResultHandle(Measurer.measureResult)
                            log:info("测量完成")
                            log:info("测量流程总时间 = ".. os.time() - Measurer.measureResult.measureDate)
                        end

                    end

                    log:debug("加样等待时间 = " .. os.time() - startTime)
                end
            end
        },
        --10 加样
        {
            action = setting.runAction.measure.addSampleTime,
            execute = function()
                local startTime = os.time()
                --检测载气压力
                op:ConfirmAirFlow(true)
                --检测LED信号
                op:ConfirmLED()
                --加样
                op:AddDosingToStove(Measurer.measureResult)

                log:debug("加样时间 = " .. os.time() - startTime)

            end
        },
        --11 CleanAfterMeasure 测量后清洗
        {
            action = setting.runAction.measure.cleanAfterMeasure,
            execute = function()
                local startTime = os.time()
                op:SyringReset()

                op:DrainFromDigestionRoom()  -- 测量后排液带排液检查，仅当排液检查开关打开才生效
                if Measurer.currentRange <= 3 then
                    op:PumpToDigestionRoom(setting.liquidType.blank, setting.liquid.cleanAftMeaBlankVol)
                else
                    op:PumpToDigestionRoom(setting.liquidType.blank, 12)
                end

                --op:Exposure(setting.liquidType.exposureNirtrogen, 10)
                op:AirToDigestionRoom(10)

                if config.measureParam.highSaltMode == true then
                    log:debug("高盐模式-清洗加样管路")
                    op:FillDosingPipe(setting.liquidType.blank, setting.unitVolume * 2)
                    op:FillDosingPipe(setting.liquidType.blank, setting.unitVolume * 2)
                end

                op:DrainFromWaste()

                op:DrainFromDigestionRoom()  -- 测量后排液带排液检查，仅当排液检查开关打开才生效

                log:debug("测量后清洗时间 = " .. os.time() - startTime);
            end
        },
        --12 反应
        {
            action = setting.runAction.measure.waittingResult,
            execute = function()
                local startTime = os.time()

                --非连续模式下等待出测量结果
                if config.scheduler.measure.mode ~= MeasureMode.Continous then

                    local reactTime = config.measureParam.addAfterTime

                    local restTime = os.time() - Measurer.measureResult.lastAccurateMeasureTime
                    log:debug("restTime: " .. (reactTime - restTime) .. ", done: " .. restTime)

                    if restTime < reactTime or setting.measureResult.immediatelyResultHandle == false then
                        if not Measurer.flow:Wait((reactTime - restTime)/2) then
                            error(UserStopException:new())
                        end
                        Measurer:CalibrateMeasureEndJudge((reactTime - restTime)/2)
                        --if not Measurer.flow:Wait(40) then
                        --    error(UserStopException:new())
                        --end
                    end

                    Measurer:Handle(Measurer.measureResult)

                    setting.measureResult.continousModeParam.isfinishContinousMeasure = false
                else --连续模式下跳过等待直接下一个流程
                    setting.measureResult.continousModeParam.isfinishContinousMeasure = true
                end

                --连续测量不关灯，避免抖动
                if config.scheduler.measure.mode ~= MeasureMode.Continous then
                    dc:GetIOpticalAcquire():TurnOffLED()	--关LED
                    dc:ClearBuf()--清buf,防止数组刷新
                end

                log:debug("反应时间 = " .. os.time() - startTime);
            end
        },
        --13 返回结果
        {
            action = nil,
            execute = function()
                status.measure.lastMeasureEndTime = os.time()

                if setting.measureResult.continousModeParam.isfinishContinousMeasure == false then
                    --非0-10量程： 非连续模式>>连续测量
                    --需判定是否完成精准测量动作，并直接在当前流程出测量结果
                    if setting.measureResult.isFinishAccurateMeasure == true then
                        setting.measureResult.isFinishAccurateMeasure = false
                    end

                    if Measurer.flow.ResultHandle then
                        Measurer.flow:ResultHandle(Measurer.measureResult)
                    end

                    --local runAction = Helper.Status.SetAction(setting.runAction.suckRefrigeratorWater)
                    --StatusManager.Instance():SetAction(runAction)
                    --op:DrainFromRefrigeratorWaterRoom()

                    setting.measureResult.continousModeParam.currentMeasureCnt = 0

                else
                    setting.measureResult.continousModeParam.isfinishContinousMeasure = true  --连续测量标志位
                    setting.measureResult.continousModeParam.lastAccuratePeakArea = Measurer.measureResult.peakArea
                    setting.measureResult.continousModeParam.lastStartIndex = Measurer.measureResult.startIndex
                    setting.measureResult.continousModeParam.currentMeasureCnt = setting.measureResult.continousModeParam.currentMeasureCnt + 1
                    log:debug("流程执行次数 = " .. setting.measureResult.continousModeParam.currentMeasureCnt);
                end
            end
        },
    },

    calibrate =
    {
        calibrateTime = 0,              --当前校准次数
        isActiveClear = false,          --清空残留液标志位
        fillType = FillType.FillNormal,                   --校准模式
        handleType = AccurateType.normal
    },

    calibrateSteps =
    {
        --1 等待气路稳定 -- 校准
        {
            action = setting.runAction.measure.airFlowCheck,
            execute = function()
                local startTime = os.time()
                Measurer.measureResult.measureDate = os.time()

                --打开氮气气路
                op:TurnOnNirtrogen()
                --开LED
                dc:GetIOpticalAcquire():TurnOnLED()
                --清buf,防止数组刷新
                dc:ClearBuf()

                --检测是否达到反应温度
                op:IsReactTemperature(Measurer.flow)

                Measurer.measureResult.initRefrigeratorTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
                Measurer.measureResult.initNDIRTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
                Measurer.measureResult.initThermostatTemp = dc:GetDigestTemperature()
                Measurer.measureResult.initEnvironmentTemp = dc:GetEnvironmentTemperature()
                Measurer.measureResult.initEnvironmentTempDown = dc:GetReportThermostatTemp(setting.temperature.temperatureBoxLow)
                --检测载气压力
                op:ConfirmAirFlow(true)
                log:debug("检测载气时间 = " .. os.time() - startTime);
            end
        },
        --2 DrainBeforeMeasure 测量前排液 -- 校准
        {
            action = setting.runAction.measure.drainBeforeMeasure,
            execute = function()
                local startTime = os.time()

                --进样复位检测
                op:SlidersSensorCheck()

                op:DrainToWaste(0)
                op:DrainFromDigestionRoom()

                --local runAction = Helper.Status.SetAction(setting.runAction.suckRefrigeratorWater)
                --StatusManager.Instance():SetAction(runAction)
                --op:DrainFromRefrigeratorWaterRoom()

                log:debug("测量前排液时间 = " .. os.time() - startTime);
            end
        },
        --3 CleanBeforeMeasure 测量前清洗 -- 校准
        {
            action = setting.runAction.measure.cleanBeforeMeasure,
            execute = function()
                local startTime = os.time()

                if Measurer.measureType ~= MeasureType.Sample then
                    op:PumpToDigestionRoom(setting.liquidType.blank,  8)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)

                    op:ExposureTurnOn(config.measureParam.exposurePressure*1.2)

                    if not Measurer.flow:Wait(60) then
                        error(UserStopException:new())
                    end

                    op:ExposureTurnOff()

                    op:DrainFromDigestionRoom()
                end

                -- 零点校准液清洗消解器
                if config.measureParam.cleanBefMeaBlankVol > 0 then
                    op:PumpToDigestionRoom(setting.liquidType.blank,  config.measureParam.cleanBefMeaBlankVol)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                    op:DrainFromDigestionRoom()
                end

                if Measurer:TimeCheck() then
                    log:debug("二次清洗")
                    status.measure.lastMeasureEndTime = os.time()
                    ConfigLists.SaveMeasureStatus()
                    -- 零点校准液清洗消解器
                    op:PumpToDigestionRoom(setting.liquidType.blank, setting.unitVolume * 2, nil)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                    op:DrainFromDigestionRoom()
                end

                log:debug("测量前清洗时间 = " .. os.time() - startTime);
            end
        },
        --4 Rinse 润洗 -- 校准
        {
            action = setting.runAction.measure.rinse,
            execute = function()
                local startTime = os.time()

                -- 根据测量类型获取对应的润洗体积，其中包括判断上次测量间隔时间是否超过36h
                --local RinseVolume = Measurer:GetRinseVol()
                local RinseVolume = setting.unitVolume * 4
                --local RinseVolume =  config.hardwareConfig.meterPoint.point[2].realVolume
                if Measurer.addParam.rinseEnable == true then
                    --润洗加水样
                    if Measurer.addParam.rinseSampleVolume > 0 then
                        if config.measureParam.sampleRenewVolume > 0 then
                            op:CleanMeterPipe(setting.liquidType.sample, config.measureParam.sampleRenewVolume, PointNum.First) --水样管路更新
                        end
                        op:CleanMeterPipe(setting.liquidType.sample, RinseVolume)
                        --op:RinseMeterPipeWithSuck(setting.liquidType.sample, RinseVolume)  --清洗定量管
                        --op:RinseMeterPipeWithSuck(setting.liquidType.sample, RinseVolume)  --清洗定量管
                    end

                    --润洗加量程校准液
                    if Measurer.addParam.rinseStandardVolume > 0 then
                        --op:RinseMeterPipeWithSuck(setting.liquidType.standard, RinseVolume)  --清洗定量管
                        --op:RinseMeterPipeWithSuck(setting.liquidType.standard, RinseVolume)  --清洗定量管
                        op:CleanMeterPipe(setting.liquidType.standard, RinseVolume)
                    end

                    --润洗加零点核查液
                    if Measurer.addParam.rinseZeroCheckVolume > 0 then
                        --op:CleanMeterPipe(setting.liquidType.zeroCheck, 0.5, PointNum.First)
                        --op:RinseMeterPipeWithSuck(setting.liquidType.zeroCheck, RinseVolume)  --清洗定量管
                        --op:RinseMeterPipeWithSuck(setting.liquidType.zeroCheck, RinseVolume)  --清洗定量管
                        op:CleanMeterPipe(setting.liquidType.zeroCheck, RinseVolume)
                    end

                    --润洗加量程核查液
                    if Measurer.addParam.rinseRangeCheckVolume > 0 then
                        --op:CleanMeterPipe(setting.liquidType.rangeCheck, 0.5, PointNum.First)
                        --op:RinseMeterPipeWithSuck(setting.liquidType.rangeCheck, RinseVolume)  --清洗定量管
                        --op:RinseMeterPipeWithSuck(setting.liquidType.rangeCheck, RinseVolume)  --清洗定量管
                        op:CleanMeterPipe(setting.liquidType.rangeCheck, RinseVolume)
                    end
                    --润洗加零点校准液
                    if Measurer.addParam.rinseBlankVolume > 0 then
                        --op:CleanMeterPipe(setting.liquidType.blank, 0.5, PointNum.First)
                        op:CleanMeterPipe(setting.liquidType.blank, RinseVolume)
                    end
                end

                if config.measureParam.accurateMeasure == true then
                    setting.measureResult.isStartAccurateMeasure = true
                else
                    setting.measureResult.isStartAccurateMeasure = false
                end
                --核查默认开启精准测量
                if Measurer.measureType == MeasureType.RangeCheck or Measurer.measureType == MeasureType.ZeroCheck then
                    if config.measureParam.accurateCheck == true then
                        setting.measureResult.isStartAccurateMeasure = true
                    end
                end

                log:debug("润洗时间 = " .. os.time() - startTime);
            end
        },
        --5 AddMeasureSample 加待测样 -- 校准
        {
            action = setting.runAction.measure.addSample,
            execute = function()
                local startTime = os.time()
                local cleanMeterPipevolume = config.hardwareConfig.meterPoint.point[2].setVolume
                --加水样
                if Measurer.addParam.sampleVolume > 0 then
                    if Measurer.currentRange <= 2 then
                        op:MeterToDigestionRoom(setting.liquidType.sample, Measurer.addParam.sampleVolume)
                    else
                        op:IndirectMeterToDigestionRoom(setting.liquidType.sample, Measurer.addParam.sampleVolume)
                    end

                    op:DrainLiquid(setting.liquidType.sample, setting.liquid.samplePipeVolume + config.measureParam.extendSamplePipeVolume)

                    local CleanPipeTimes = 1        -- 清洗次数
                    if true == config.measureParam.wasteWaterEnvironment then   -- 抗污模式清洗两次
                        CleanPipeTimes = 2
                    end

                    if Measurer.currentRange <= 2 then
                        --CleanPipeTimes = CleanPipeTimes + 1
                    else
                        CleanPipeTimes = CleanPipeTimes + 1
                    end

                    for i=1,CleanPipeTimes do
                        op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)
                    end

                    -- 定量零点校准液，加压反冲水样管
                    local factor = dc:GetIPeristalticPump():GetPumpFactor(0)
                    local drainSpeed = setting.liquid.prefabricateDrainSpeed * factor
                    op:SetMeterOverValue(MeterMode.Smart, 0)
                    op:ForcingCleanPipe(setting.liquidType.sample, 1, 0.5, 0.5, drainSpeed)
                    --加待测样后清洗水样管
                    if config.measureParam.cleanSampleVol > 0 then
                        op:DrainToWaste(0)
                        op:MeterToSample(setting.liquidType.blank, config.measureParam.cleanSampleVol)
                        op:SecludeLiquid(setting.liquidType.blank)
                        op:DrainLiquid(setting.liquidType.sample, setting.liquid.samplePipeVolume + config.measureParam.extendSamplePipeVolume)
                    end
                end

                if config.interconnection.collectSampleMode == setting.mode.collectSample.toAddSampleEnd then
                    local waterCollector = WaterCollector.Instance()
                    if not string.find(config.info.instrument["type"], "PT63P") then
                        waterCollector:TurnOff()
                    end
                    Helper.Result.RelayOutOperate(setting.mode.relayOut.collectInstruct, false)
                end

                --加量程校准液
                if Measurer.addParam.standardVolume > 0 then
                    if Measurer.currentRange <= 2 then
                        op:MeterToDigestionRoom(setting.liquidType.standard, Measurer.addParam.standardVolume)
                    else
                        op:IndirectMeterToDigestionRoom(setting.liquidType.standard, Measurer.addParam.standardVolume)
                    end
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.standard)

                    local CleanPipeTimes = 1        -- 清洗次数
                    if true == config.measureParam.wasteWaterEnvironment then   -- 抗污模式清洗两次
                        CleanPipeTimes = 2
                    end
                    if Measurer.currentRange <= 2 then
                        --CleanPipeTimes = CleanPipeTimes + 1
                    else
                        CleanPipeTimes = CleanPipeTimes + 1
                    end

                    for i=1,CleanPipeTimes do
                        op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)
                    end
                end

                --加零点核查液
                if Measurer.addParam.zeroCheckVolume > 0 then
                    if Measurer.currentRange <= 2 then
                        op:MeterToDigestionRoom(setting.liquidType.zeroCheck, Measurer.addParam.zeroCheckVolume)
                    else
                        op:IndirectMeterToDigestionRoom(setting.liquidType.zeroCheck, Measurer.addParam.zeroCheckVolume)
                    end
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.zeroCheck)

                    local CleanPipeTimes = 1        -- 清洗次数
                    if true == config.measureParam.wasteWaterEnvironment then   -- 抗污模式清洗两次
                        CleanPipeTimes = 2
                    end
                    if Measurer.currentRange <= 2 then
                        --CleanPipeTimes = CleanPipeTimes + 1
                    else
                        CleanPipeTimes = CleanPipeTimes + 1
                    end

                    for i=1,CleanPipeTimes do
                        op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)
                    end
                end

                --加量程核查液
                if Measurer.addParam.rangeCheckVolume > 0 then
                    if Measurer.currentRange <= 2 then
                        op:MeterToDigestionRoom(setting.liquidType.rangeCheck, Measurer.addParam.rangeCheckVolume)
                    else
                        op:IndirectMeterToDigestionRoom(setting.liquidType.rangeCheck, Measurer.addParam.rangeCheckVolume)
                    end
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.rangeCheck)

                    local CleanPipeTimes = 1        -- 清洗次数
                    if true == config.measureParam.wasteWaterEnvironment then   -- 抗污模式清洗两次
                        CleanPipeTimes = 2
                    end
                    if Measurer.currentRange <= 2 then
                        --CleanPipeTimes = CleanPipeTimes + 1
                    else
                        CleanPipeTimes = CleanPipeTimes + 1
                    end

                    for i=1,CleanPipeTimes do
                        op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)
                    end
                end

                --加零点校准液
                if Measurer.addParam.blankVolume > 0 then
                    op:MeterToDigestionRoom(setting.liquidType.blank, Measurer.addParam.blankVolume)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                end

                --第1次定量稀释抽取混合液体积
                if Measurer.addParam.dilutionExtractVolume1 > 0 then
                    op:AirToDigestionRoom(20)
                    op:MeterFromDigestionRoom(Measurer.addParam.dilutionExtractVolume1)
                    op:SecludeLiquid(setting.liquidType.digestionRoom)
                    op:CleanMeterPipe(setting.liquidType.blank, 0.5)  --清洗定量管
                    op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)  --清洗定量管
                end

                --第1次定量稀释加零点校准液体积
                if Measurer.addParam.dilutionAddBlankVolume1 > 0 then
                    op:MeterToDigestionRoom(setting.liquidType.blank, Measurer.addParam.dilutionAddBlankVolume1)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                end

                --第2次定量稀释抽取混合液体积
                if Measurer.addParam.dilutionExtractVolume2 > 0 then
                    op:AirToDigestionRoom(20)
                    op:MeterFromDigestionRoom(Measurer.addParam.dilutionExtractVolume2)
                    op:SecludeLiquid(setting.liquidType.digestionRoom)
                    op:CleanMeterPipe(setting.liquidType.blank, 0.5)  --清洗定量管
                    op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)  --清洗定量管
                end

                --第2次定量稀释加零点校准液体积
                if Measurer.addParam.dilutionAddBlankVolume2 > 0 then
                    op:MeterToDigestionRoom(setting.liquidType.blank, Measurer.addParam.dilutionAddBlankVolume2)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                end

                --第3次定量稀释抽取混合液体积
                if Measurer.addParam.dilutionExtractVolume3 > 0 then
                    op:AirToDigestionRoom(20)
                    op:MeterFromDigestionRoom(Measurer.addParam.dilutionExtractVolume3)
                    op:SecludeLiquid(setting.liquidType.digestionRoom)
                    op:CleanMeterPipe(setting.liquidType.blank, 0.5)  --清洗定量管
                    op:CleanMeterPipe(setting.liquidType.blank, cleanMeterPipevolume)  --清洗定量管
                end

                --第3次定量稀释加零点校准液体积
                if Measurer.addParam.dilutionAddBlankVolume3 > 0 then
                    op:MeterToDigestionRoom(setting.liquidType.blank, Measurer.addParam.dilutionAddBlankVolume3)
                    op:DrainToWaste(0)
                    op:SecludeLiquid(setting.liquidType.blank)
                end

                log:debug("加待测样时间 = " .. os.time() - startTime);

            end
        },
        --6 AddReagent1 加试剂一 -- 校准
        {
            action = setting.runAction.measure.addReagent1,
            execute = function()
                local startTime = os.time()
                --op:CleanMeterPipe(setting.liquidType.reagent1, 0.5)
                --op:MeterToDigestionRoom(setting.liquidType.reagent1, setting.liquid.reagent1Volume)
                op:SlowMeterToDigestionRoom(setting.liquidType.reagent1, setting.liquid.reagent1Volume)
                --op:CombineMeterToDigestionRoom(setting.liquidType.reagent1, setting.liquid.reagent1Volume)

                op:DrainToWaste(0)
                op:SecludeLiquid(setting.liquidType.reagent1)

                log:debug("加试剂一时间 = " .. os.time() - startTime);
            end
        },
        --7 exposure 曝气 -- 校准
        {
            action = setting.runAction.measure.exposureNirtrogen,
            execute = function()
                local startTime = os.time()
                op:Exposure(setting.liquidType.exposureNirtrogen, config.measureParam.exposureTime)
                log:debug("曝气时间 = " .. os.time() - startTime)

            end
        },
        --8 管路更新 -- 校准
        {
            action = setting.runAction.measure.updateTime,
            execute = function()
                local startTime = os.time()
                --op:SyringUpdate(config.measureParam.syringeUpdateCnt)
                op:SyringUpdateAir(1)

                if Measurer.currentRange <= 3 then
                    op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                else
                    op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                    op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                    op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
                end
                op:SyringToWaste(setting.measureResult.startReactVolume/config.measureParam.addSampleCnt)
                log:debug("管路更新时间 = " .. os.time() - startTime)
            end
        },
        --9 加样 -- 校准
        {
            action = setting.runAction.measure.addSampleTime,
            execute = function()
                local startTime = os.time()
                --检测载气压力
                op:ConfirmAirFlow(true)
                --检测LED信号
                op:ConfirmLED()
                --加样
                op:AddDosingToStoveCalibrate(Measurer.measureResult)

                log:debug("加样时间 = " .. os.time() - startTime)

            end
        },
        --10 测量后清洗 -- 校准
        {
            action = setting.runAction.measure.cleanAfterMeasure,
            execute = function()
                local startTime = os.time()
                op:SyringReset()

                op:DrainFromDigestionRoom()  -- 测量后排液带排液检查，仅当排液检查开关打开才生效
                if Measurer.currentRange <= 3 then
                    op:PumpToDigestionRoom(setting.liquidType.blank, setting.liquid.cleanAftMeaBlankVol)
                else
                    op:PumpToDigestionRoom(setting.liquidType.blank, 12)
                end
                --op:Exposure(setting.liquidType.exposureNirtrogen, 10)
                op:AirToDigestionRoom(10)

                op:DrainFromWaste()
                op:DrainFromDigestionRoom()  -- 测量后排液带排液检查，仅当排液检查开关打开才生效

                log:debug("测量后清洗时间 = " .. os.time() - startTime);
            end
        },
        --11 测量反应 -- 校准
        {
            action = setting.runAction.measure.waittingResult,
            execute = function()
                local startTime = os.time()
                local reactTime = config.measureParam.addAfterTime

                local restTime = os.time() - Measurer.measureResult.lastAccurateMeasureTime
                log:debug("CailbrateRestTime: " .. (reactTime - restTime) .. ", done: " .. restTime)

                if restTime < reactTime or setting.measureResult.immediatelyResultHandle == false then
                    if not Measurer.flow:Wait((reactTime - restTime)/2) then
                        error(UserStopException:new())
                    end
                    Measurer:CalibrateMeasureEndJudge((reactTime - restTime)/2)
                    --if not Measurer.flow:Wait(40) then
                    --    error(UserStopException:new())
                    --end
                end
                setting.measureResult.immediatelyResultHandle = false
                Measurer.measureResult.finalRefrigeratorTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
                Measurer.measureResult.finalNDIRTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
                Measurer.measureResult.finalThermostatTemp = dc:GetDigestTemperature()
                Measurer.measureResult.finalEnvironmentTemp = dc:GetEnvironmentTemperature()
                Measurer.measureResult.finalEnvironmentTempDown = dc:GetReportThermostatTemp(setting.temperature.temperatureBoxLow)

                if Measurer.measureResult.endIndex == 0 then
                    Measurer.measureResult.endIndex = dc:GetScanLen()   --标记结束
                    log:debug("标记结束： " .. Measurer.measureResult.endIndex);
                end

                log:debug("测量反应 = " .. os.time() - startTime);

            end
        },
        --12 返回结果 -- 校准
        {
            action = nil,
            execute = function()
                status.measure.lastMeasureEndTime = os.time()

                Measurer.measureResult.peakArea = op:CalculatePeakArea(Measurer.measureResult.startIndex, Measurer.measureResult.endIndex, nil, nil, Measurer.measureType)

                log:debug("校准面积： " .. Measurer.measureResult.peakArea)

                setting.measureResult.isFinishAccurateMeasure = false

                if Measurer.flow.ResultHandle then
                    Measurer.flow:ResultHandle(Measurer.measureResult)
                end

            end
        },
    },

    quickMeasureSteps =
    {
        --1 等待气路稳定 --快速测量
        {
            action = setting.runAction.measure.airFlowCheck,
            execute = function()
                local startTime = os.time()
                --连续测量时间管理
                if config.scheduler.quickMeasure.mode == MeasureMode.Continous then
                    if setting.measureResult.continousModeParam.currentMeasureCnt == 0 then
                        Measurer.measureResult.measureDate = os.time()
                        Measurer.measureResult.lastMeasureDate = os.time()
                        --打开氮气气路
                        --op:TurnOnNirtrogen()
                        dc:GetIOpticalAcquire():TurnOnLED()	--开LED
                    else
                        Measurer.measureResult.measureDate = Measurer.measureResult.lastMeasureDate
                        Measurer.measureResult.lastMeasureDate = os.time()
                    end
                else
                    Measurer.measureResult.lastMeasureDate = os.time()
                    --打开氮气气路
                    --op:TurnOnNirtrogen()
                    dc:GetIOpticalAcquire():TurnOnLED()	--开LED
                end

                --检测是否达到反应温度
                op:IsReactTemperature(Measurer.flow)
                --检测总阀压力
                op:WaitAirFlow(Measurer.flow)
                --检测载气压力
                op:ConfirmAirFlow(true)

                Measurer.measureResult.initRefrigeratorTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
                Measurer.measureResult.initNDIRTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
                Measurer.measureResult.initThermostatTemp = dc:GetDigestTemperature()
                Measurer.measureResult.initEnvironmentTemp = dc:GetEnvironmentTemperature()
                Measurer.measureResult.initEnvironmentTempDown = dc:GetReportThermostatTemp(setting.temperature.temperatureBoxLow)
                log:debug("检测载气时间 = " .. os.time() - startTime);
            end
        },
        --2 DrainBeforeMeasure 测量前排液 --快速测量
        {
            action = setting.runAction.measure.drainBeforeMeasure,
            execute = function()
                local startTime = os.time()

                --进样复位检测
                op:SlidersSensorCheck()

                --非连续测量模式测量前排一次冷凝水
                if setting.measureResult.continousModeParam.currentMeasureCnt == 0 then
                    op:DrainToWaste(0)
                end

                Measurer:ContinousModeCheckResult() --检查测量是否完成

                log:debug("测量前排液时间 = " .. os.time() - startTime);
            end
        },
        --3 管路更新 --快速测量
        {
            action = setting.runAction.measure.updateTime,
            execute = function()
                local startTime = os.time()
                op:SyringUpdateAir(1)
                if Measurer.addParam.sampleVolume > 0 then
                    op:FillDosingPipe(setting.liquidType.sample, setting.unitVolume * 2)
                end

                if Measurer.addParam.standardVolume > 0 then
                    op:FillDosingPipe(setting.liquidType.standard, setting.unitVolume * 2)
                end

                if Measurer.addParam.zeroCheckVolume > 0 then
                    op:FillDosingPipe(setting.liquidType.zeroCheck, setting.unitVolume * 2)
                end

                if Measurer.addParam.rangeCheckVolume > 0 then
                    op:FillDosingPipe(setting.liquidType.rangeCheck, setting.unitVolume * 2)
                end

                if Measurer.addParam.blankVolume > 0 then
                    op:FillDosingPipe(setting.liquidType.blank, setting.unitVolume * 2)
                end

                op:SyringToWaste(setting.measureResult.startReactVolume/config.measureParam.addSampleCnt)
                Measurer:ContinousModeCheckResult() --检查测量是否完成

                log:debug("管路更新时间 = " .. os.time() - startTime)
            end
        },
        --4 加样等待 --快速测量
        {
            action = setting.runAction.measure.baseLineCheck,
            execute = function()

                if setting.measureResult.continousModeParam.isfinishContinousMeasure == true then
                    local startTime = os.time()
                    --连续测量的第二次开始，每次都在此处等待剩余的时长
                    if setting.measureResult.continousModeParam.currentMeasureCnt ~= 0 then
                        local runAction = Helper.Status.SetAction(setting.runAction.measure.waittingResult)
                        StatusManager.Instance():SetAction(runAction)
                        log:debug("currentMeasureCnt: " .. setting.measureResult.continousModeParam.currentMeasureCnt)
                        log:debug("lastStartIndex: " .. setting.measureResult.continousModeParam.lastStartIndex)

                        Measurer.measureResult.endIndex = 0
                        Measurer.measureResult.startIndex = setting.measureResult.continousModeParam.lastStartIndex

                        local reactTime = config.measureParam.addAfterTime

                        local restTime = os.time() - Measurer.measureResult.lastAccurateMeasureTime
                        log:debug("restTime: " .. (reactTime - restTime) .. ", done: " .. restTime)

                        if restTime < reactTime or setting.measureResult.immediatelyResultHandle == false then
                            if not Measurer.flow:Wait(reactTime - restTime) then
                                error(UserStopException:new())
                            end
                        end

                        Measurer:Handle(Measurer.measureResult)

                        if Measurer.flow.ResultHandle then
                            Measurer.flow:ResultHandle(Measurer.measureResult)
                            log:info("测量完成")
                            log:info("测量流程总时间 = ".. os.time() - Measurer.measureResult.measureDate)
                        end

                    end

                    log:debug("加样等待时间 = " .. os.time() - startTime)
                end
            end
        },
        --5 加样 --快速测量
        {
            action = setting.runAction.measure.addSampleTime,
            execute = function()
                local startTime = os.time()
                --检测载气压力
                op:ConfirmAirFlow(true)
                --检测LED信号
                op:ConfirmLED()
                --加样
                op:AddDosingToStove(Measurer.measureResult)

                log:debug("加样时间 = " .. os.time() - startTime)

            end
        },
        --6 CleanAfterMeasure 测量后清洗 --快速测量
        {
            action = setting.runAction.measure.cleanAfterMeasure,
            execute = function()
                local startTime = os.time()
                op:SyringReset()

                log:debug("测量后清洗时间 = " .. os.time() - startTime);
            end
        },
        --7 反应 --快速测量
        {
            action = setting.runAction.measure.waittingResult,
            execute = function()
                local startTime = os.time()

                --非连续模式下等待出测量结果
                if config.scheduler.quickMeasure.mode ~= MeasureMode.Continous then

                    local reactTime = config.measureParam.addAfterTime

                    local restTime = os.time() - Measurer.measureResult.lastAccurateMeasureTime
                    log:debug("restTime: " .. (reactTime - restTime) .. ", done: " .. restTime)

                    if restTime < reactTime or setting.measureResult.immediatelyResultHandle == false then
                        if not Measurer.flow:Wait((reactTime - restTime)/2) then
                            error(UserStopException:new())
                        end
                        Measurer:CalibrateMeasureEndJudge((reactTime - restTime)/2)
                        --if not Measurer.flow:Wait(40) then
                        --    error(UserStopException:new())
                        --end
                    end

                    Measurer:Handle(Measurer.measureResult)

                    setting.measureResult.continousModeParam.isfinishContinousMeasure = false
                else --连续模式下跳过等待直接下一个流程
                    setting.measureResult.continousModeParam.isfinishContinousMeasure = true
                end

                --连续测量不关灯，避免抖动
                if config.scheduler.quickMeasure.mode ~= MeasureMode.Continous then
                    dc:GetIOpticalAcquire():TurnOffLED()	--关LED
                    dc:ClearBuf()--清buf,防止数组刷新
                end

                log:debug("反应时间 = " .. os.time() - startTime);
            end
        },
        --13 返回结果 --快速测量
        {
            action = nil,
            execute = function()
                status.measure.lastMeasureEndTime = os.time()

                if setting.measureResult.continousModeParam.isfinishContinousMeasure == false then
                    --非0-10量程： 非连续模式>>连续测量
                    --需判定是否完成精准测量动作，并直接在当前流程出测量结果
                    if setting.measureResult.isFinishAccurateMeasure == true then
                        setting.measureResult.isFinishAccurateMeasure = false
                    end

                    if Measurer.flow.ResultHandle then
                        Measurer.flow:ResultHandle(Measurer.measureResult)
                    end

                    setting.measureResult.continousModeParam.currentMeasureCnt = 0

                else
                    setting.measureResult.continousModeParam.isfinishContinousMeasure = true  --连续测量标志位
                    setting.measureResult.continousModeParam.lastAccuratePeakArea = Measurer.measureResult.peakArea
                    setting.measureResult.continousModeParam.lastStartIndex = Measurer.measureResult.startIndex
                    setting.measureResult.continousModeParam.currentMeasureCnt = setting.measureResult.continousModeParam.currentMeasureCnt + 1
                    log:debug("流程执行次数 = " .. setting.measureResult.continousModeParam.currentMeasureCnt);
                end
            end
        },
    },
}

function Measurer:SkipFlow()
    status.measure.lastMeasureEndTime = os.time()
    if Measurer.flow.ResultHandle then
        Measurer.flow:ResultHandle(Measurer.measureResult)
    end
end

function Measurer:Measure()
    if nil ~= setting.common.skipFlow and true == setting.common.skipFlow then
        Measurer:SkipFlow()
        return Measurer.measureResult
    end
    if #self.procedure ~= 0  then
        print("--------------Execute configuration procedure--------------")
        for i, index in pairs(self.procedure) do
            print("index = ".. index)
            local step = self.steps[index]
            if step.action then
                local runAction = Helper.Status.SetAction(step.action)
                StatusManager.Instance():SetAction(runAction)
                log:info(step.action.text)
            end

            step.execute()
        end
    else
        print("--------------Execute default procedure--------------")
        for i, step in pairs(self.steps) do
            print("i = ".. i)
            if step.action then
                local runAction = Helper.Status.SetAction(step.action)
                StatusManager.Instance():SetAction(runAction)
                log:info(step.action.text)
            end

            step.execute()
        end
    end

    return Measurer.measureResult
end

function Measurer:CalibrateMeasure(handleType)

    --8-管路更新 9-加样 10-测量后清洗 11-测量反应 12-测量结果
    if handleType == AccurateType.normal then
        self.procedure = {}
        self.calibrate.fillType = FillType.FillNormal
        print("mode normal")
    elseif handleType == AccurateType.normalWithoutClean then
        --精准校准第一次，不清洗
        self.procedure = {1,2,3,4,5,6,7,8,9,11,12}
        --self.calibrate.fillType = FillType.FillAccurateFirst
        print("mode first and without clean")
    elseif  handleType == AccurateType.addSampleWithClean then
        --精准校准最后一次，清洗
        self.procedure = {9,10,11,12}
        --self.calibrate.fillType = FillType.FillAccurateEnd
        print("mode last with clean")
    elseif handleType == AccurateType.onlyAddSample then
        --精准校准第二次，不清洗
        self.procedure = {9,11,12}
        --self.calibrate.fillType = FillType.FillAccurateSecond
        print("mode second without clean")
    end

    if #self.procedure ~= 0  then
        print("--------------Execute configuration procedure--------------")
        for i, index in pairs(self.procedure) do
            print("index = ".. index)
            local step = self.calibrateSteps[index]
            if step.action then
                local runAction = Helper.Status.SetAction(step.action)
                StatusManager.Instance():SetAction(runAction)
                log:info(step.action.text)
            end

            step.execute()
        end
    else
        print("--------------Execute default procedure--------------")
        for i, step in pairs(self.calibrateSteps) do
            print("i = ".. i)
            if step.action then
                local runAction = Helper.Status.SetAction(step.action)
                StatusManager.Instance():SetAction(runAction)
                log:info(step.action.text)
            end

            step.execute()
        end
    end

    return Measurer.measureResult
end

function Measurer:QuickMeasure()
    if #self.procedure ~= 0  then
        print("--------------Execute configuration procedure--------------")
        for i, index in pairs(self.procedure) do
            print("index = ".. index)
            local step = self.steps[index]
            if step.action then
                local runAction = Helper.Status.SetAction(step.action)
                StatusManager.Instance():SetAction(runAction)
                log:info(step.action.text)
            end

            step.execute()
        end
    else
        print("--------------Execute default procedure--------------")
        for i, step in pairs(self.quickMeasureSteps) do
            print("i = ".. i)
            if step.action then
                local runAction = Helper.Status.SetAction(step.action)
                StatusManager.Instance():SetAction(runAction)
                log:info(step.action.text)
            end

            step.execute()
        end
    end

    return Measurer.measureResult
end

function Measurer:CalibrateMeasureClean()
    op:DrainFromDigestionRoom()  -- 测量后排液带排液检查，仅当排液检查开关打开才生效
    op:PumpToDigestionRoom(setting.liquidType.blank, setting.unitVolume * 6)
    op:Exposure(setting.liquidType.exposureNirtrogen, 10)
    --op:CleanDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 1)
    op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 1)
    if true == config.measureParam.wasteWaterEnvironment then   -- 抗污模式清洗两次

        op:PumpToDigestionRoom(setting.liquidType.blank, setting.liquid.cleanAftMeaBlankVol)
        op:DrainToWaste(0)
        op:Exposure(setting.liquidType.exposureNirtrogen, 10)
        --op:CleanDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
        op:FillDosingPipe(setting.liquidType.digestionRoom, setting.unitVolume * 2)
    else
        op:DrainFromDigestionRoom()  -- 测量后排液带排液检查，仅当排液检查开关打开才生效
    end

    --op:DrainToWaste(0, WasteType.WasteReagent)
    op:DrainFromWaste()
end

--[[
 * @brief 校准测量终点判断
 * @details
--]]
function Measurer:CalibrateMeasureEndJudge(time)
    local startTime = os.time()
    local timeout = 0
    if time ~= nil and time > 0 then
        timeout = time
    end

    while true do
        local currentTime = os.time()
        if currentTime - startTime > timeout then
            break
        elseif op:IsReachSteady(setting.measureResult.baseLineNum*4, setting.measureResult.validCnt) == false then
            if not Measurer.flow:Wait(2) then
                break
            end
        else
            break
        end
    end
end

function Measurer:Reset()
    Measurer.flow = nil
    Measurer.measureType = MeasureType.Sample
    Measurer.currentRange = 1
    Measurer.procedure = {}

    for k, v in pairs(Measurer.addParam) do
        Measurer.addParam[k] = nil
    end

    for k, v in pairs(Measurer.measureResult) do
        v = 0
    end
end

function Measurer:GetMeasureResult()
    local dstTable = {}
    for k, v in pairs(Measurer.measureResult) do
        dstTable[k] = v
    end
    return dstTable
end

function Measurer:GetZeroMeasureResult()
    local dstTable = {}
    for k, v in pairs(Measurer.measureResult) do
        dstTable[k] = 0
    end
    return dstTable
end


function Measurer:TimeCheck()
    local currentTime = os.time()
    local lastTime
    local temp
    local MeasurerIntervalMaxTime = 36*60*60        --距离上次测量允许度最大间隔时间，超过则进行额外清洗

    temp = status.measure.lastMeasureEndTime

    if temp  == 0 then
        log:debug("出厂首次流程测量")
        return true
    end

    lastTime = temp + MeasurerIntervalMaxTime
    if lastTime - currentTime < 0 then
        log:debug("距离上次测量已超36小时")
        return true
    else
        return false
    end
end

function Measurer:GetRinseVol()
    local rinseVol = 0

    if Measurer:TimeCheck() then
        rinseVol = setting.unitVolume * 2
    else
        if Measurer.addParam.rinseSampleVolume > 0 then
            rinseVol = Measurer.addParam.rinseSampleVolume
        elseif Measurer.addParam.rinseStandardVolume > 0 then
            rinseVol = Measurer.addParam.rinseStandardVolume
        elseif Measurer.addParam.rinseZeroCheckVolume > 0 then
            rinseVol = Measurer.addParam.rinseZeroCheckVolume
        elseif Measurer.addParam.rinseRangeCheckVolume > 0 then
            rinseVol = Measurer.addParam.rinseRangeCheckVolume
        elseif Measurer.addParam.rinseBlankVolume > 0 then
            rinseVol = Measurer.addParam.rinseBlankVolume
        end
    end


    return rinseVol
end


--[[
 * @brief 生成测量数据
 * @details 该函数应当用于连续模式切换导致其他模式此类情形
--]]
function Measurer:ContinousMeasureSafetyStop()
    if setting.measureResult.continousModeParam.currentMeasureCnt ~= 0 then

        log:debug("safe currentMeasureCnt: " .. setting.measureResult.continousModeParam.currentMeasureCnt)
        log:debug("safe lastStartIndex: " .. setting.measureResult.continousModeParam.lastStartIndex)

        Measurer.measureResult.endIndex = 0
        Measurer.measureResult.startIndex = setting.measureResult.continousModeParam.lastStartIndex
        local reactTime = config.measureParam.addAfterTime

        local restTime = os.time() - Measurer.measureResult.lastAccurateMeasureTime
        log:debug("restTime: " .. (reactTime - restTime) .. ", done: " .. restTime)

        if restTime < reactTime or setting.measureResult.immediatelyResultHandle == false then
            if not Measurer.flow:Wait((reactTime - restTime)/2) then
                error(UserStopException:new())
            end
            Measurer:CalibrateMeasureEndJudge((reactTime - restTime)/2)
            --if not Measurer.flow:Wait(40) then
            --    error(UserStopException:new())
            --end
        end

        Measurer:Handle(Measurer.measureResult)

        --连续测量中时间排卤素液抢占
        Measurer.measureResult.measureDate = Measurer.measureResult.lastMeasureDate
        if Measurer.flow.ResultHandle then
            Measurer.flow:ResultHandle(Measurer.measureResult)
            log:info("测量完成")
            log:info("测量流程总时间 = ".. os.time() - Measurer.measureResult.measureDate)
        end
    end
end


--[[
 * @brief 检测连续模式测量结果
 * @details 用于检测反应时间是否超时
--]]
function Measurer:ContinousModeCheckResult()
    if setting.measureResult.continousModeParam.isfinishContinousMeasure == true then

        Measurer.measureResult.endIndex = 0
        Measurer.measureResult.startIndex = setting.measureResult.continousModeParam.lastStartIndex
        local restTime = os.time() -  Measurer.measureResult.lastAccurateMeasureTime

        if op:IsReachSteady(setting.measureResult.baseLineNum*4, setting.measureResult.validCnt) == true or
                setting.measureResult.immediatelyResultHandle == true or restTime > config.measureParam.addAfterTime   then

            if restTime < config.measureParam.addAfterTime/2 then
                return
            end
            --if not Measurer.flow:Wait(20) then
            --    error(UserStopException:new())
            --end
            Measurer:Handle(Measurer.measureResult)

            if Measurer.flow.ResultHandle then
                Measurer.flow:ResultHandle(Measurer.measureResult)
                log:info("测量完成")
                log:info("测量流程总时间 = ".. os.time() - Measurer.measureResult.measureDate)
            end
            setting.measureResult.continousModeParam.isfinishContinousMeasure = false
            --op:DrainFromRefrigeratorWaterRoom()
        end
    end
end

--[[
 * @brief 结果处理
 * @details
--]]
function Measurer:Handle(measureResult)
    measureResult.finalRefrigeratorTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
    measureResult.finalNDIRTemp = dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
    measureResult.finalThermostatTemp = dc:GetDigestTemperature()
    measureResult.finalEnvironmentTemp = dc:GetEnvironmentTemperature()
    measureResult.finalEnvironmentTempDown = dc:GetReportThermostatTemp(setting.temperature.temperatureBoxLow)

    local num = dc:GetScanLen()
    if num ~= nil then
        measureResult.endIndex = num
        log:debug("标记结束： " .. num);
    end

    if config.measureParam.accurateMeasure == false and setting.measureResult.isFinishAccurateMeasure == false then
        measureResult.peakArea = op:CalculatePeakArea(measureResult.startIndex, measureResult.endIndex, nil, false, Measurer.measureType)
        log:debug("普通测量： " .. measureResult.peakArea)
    elseif config.measureParam.accurateMeasure == true or setting.measureResult.isFinishAccurateMeasure == true then
        --清精准定量动作完成标志位
        setting.measureResult.isFinishAccurateMeasure = false
        if setting.measureResult.immediatelyResultHandle == true then
            --完成精准测量无需赋值
            setting.measureResult.immediatelyResultHandle = false
        else
            measureResult.accurateArea4 = op:CalculatePeakArea(measureResult.startIndex, measureResult.endIndex, nil, false, Measurer.measureType)
            if measureResult.accurateArea4 == -1 then
                error(UserStopException:new())
            end
            if measureResult.accurateArea1 == 0 and
                    measureResult.accurateArea2 == 0 and
                    measureResult.accurateArea3 == 0 then
                measureResult.peakArea = measureResult.accurateArea4
            else
                local deviation12 = math.abs(measureResult.accurateArea2 - measureResult.accurateArea1)/
                        ((measureResult.accurateArea2 + measureResult.accurateArea1)/2)
                local deviation23 = math.abs(measureResult.accurateArea3 - measureResult.accurateArea2)/
                        ((measureResult.accurateArea3 + measureResult.accurateArea2)/2)
                local deviation34 = math.abs(measureResult.accurateArea4 - measureResult.accurateArea3)/
                        ((measureResult.accurateArea4 + measureResult.accurateArea3)/2)
                local deviation14 = math.abs(measureResult.accurateArea4 - measureResult.accurateArea1)/
                        ((measureResult.accurateArea4 + measureResult.accurateArea1)/2)
                local deviation13 = math.abs(measureResult.accurateArea3 - measureResult.accurateArea1)/
                        ((measureResult.accurateArea3 + measureResult.accurateArea1)/2)
                local deviation24 = math.abs(measureResult.accurateArea4 - measureResult.accurateArea2)/
                        ((measureResult.accurateArea4 + measureResult.accurateArea2)/2)
                local minDeviation = math.min(deviation12, deviation23, deviation34, deviation14, deviation13, deviation24)
                log:debug("deviation12 " .. deviation12 .. ", deviation23 " .. deviation23 .. ", deviation34 " .. deviation34)
                log:debug("deviation14 " .. deviation14 .. ", deviation13 " .. deviation13 .. ", deviation24 " .. deviation24)
                log:debug("minDeviation " .. minDeviation)
                if measureResult.accurateArea1 ~= 0 and
                        measureResult.accurateArea2 ~= 0 and
                        measureResult.accurateArea3 ~= 0 and
                        measureResult.accurateArea4 ~= 0 then
                    local maxValue = math.max(measureResult.accurateArea1,
                            measureResult.accurateArea2,
                            measureResult.accurateArea3,
                            measureResult.accurateArea4)
                    local minValue = math.min(measureResult.accurateArea1,
                            measureResult.accurateArea2,
                            measureResult.accurateArea3,
                            measureResult.accurateArea4)
                    measureResult.peakArea = (measureResult.accurateArea1+measureResult.accurateArea2
                            +measureResult.accurateArea3+measureResult.accurateArea4
                            - maxValue - minValue)/2
                else
                    if minDeviation == deviation12 then
                        measureResult.peakArea = (measureResult.accurateArea2 + measureResult.accurateArea1)/2
                    elseif minDeviation == deviation23 then
                        measureResult.peakArea = (measureResult.accurateArea3 + measureResult.accurateArea2)/2
                    elseif minDeviation == deviation34 then
                        measureResult.peakArea = (measureResult.accurateArea4 + measureResult.accurateArea3)/2
                    elseif  minDeviation == deviation14 then
                        measureResult.peakArea = (measureResult.accurateArea4 + measureResult.accurateArea1)/2
                    elseif  minDeviation == deviation13 then
                        measureResult.peakArea = (measureResult.accurateArea3 + measureResult.accurateArea1)/2
                    elseif  minDeviation == deviation24 then
                        measureResult.peakArea = (measureResult.accurateArea4 + measureResult.accurateArea2)/2
                    end
                end
            end
        end
        log:debug("精准测量： " .. string.format("%.3f", measureResult.accurateArea1) .. ", " .. string.format("%.3f", measureResult.accurateArea2) .. ", " ..
                string.format("%.3f", measureResult.accurateArea3) .. ", " .. string.format("%.3f", measureResult.accurateArea4))
        log:debug("精准模式平均面积： " .. measureResult.peakArea)
        log:debug("精准测量： " .. measureResult.peakArea)
    end
    measureResult.accurateArea1 = 0
    measureResult.accurateArea2 = 0
    measureResult.accurateArea3 = 0
    measureResult.accurateArea4 = 0
    --停止峰形图数据更新
    UpdateWidgetManager.Instance():Update(UpdateEvent.PeakStatusChanged, "Stop")

    --开始更新基线状态
    status.measure.isCheckBaseLine = true
    ConfigLists.SaveMeasureStatus()
end


