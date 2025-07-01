config.measureParam =
{                                                       -- 测量参数设置
    currentRange                = 0,                    -- 当前量程（三量程）
    calibrateRangeIndex         = 0,                    -- 校准
    zeroCheckRangeIndex         = 0,                    -- 零点核查量程
    rangeCheckRangeIndex        = 0,                    -- 量程核查量程
    range =
    {
        1,                                              -- 量程一
        2,                                              -- 量程二
        3,                                              -- 量程三
    },
    timeStr = "--",                                     -- 当前量程校准时间
    ZeroConsistency = 0,                                -- 当前量程零点校准液浓度
    RangeConsistency = 0,                               -- 当前量程量程校准液浓度
    CODRangeConsistency = 0,                            -- 当前COD量程量程校准液浓度
    curveK = 0,                                         -- 当前量程曲线斜率
    curveB = 0,                                         -- 当前量程曲线截距
    zeroOffsetArea = 0,                                 -- 零点偏移面积
    zeroAreaFactor = 1,                                 -- 零点面积因子
    syringReactVolume = 0.04,                           -- 当前量程注射器加样体积
    addBeforeTime = 5,                                  -- 当前量程注样前等待时间
    addAfterTime = 300,                                 -- 当前量程注样后等待时间

    currentRangeIndex = 1,                              -- 当前量程
    autoChangeRange = false,                             -- 量程自动切换
    accurateMeasure = false,                             --精准测量模式
    accurateMeasureDeviation = 0,                     -- 精准测量偏差阈值
    absCalibrateMode = false,                           -- 绝对浓度模式
    activeRangeMode = 0,                             -- 量程自动切换后生效模式
    digestTemperature = 165,                            -- 消解温度
    coolTemperature = 3,                                -- 制冷温度
    lastCoolTemperature = 3,
    catalystActivePressure = 45,                        -- 活化压力
    catalystActiveTemperature = 750,                    -- 活化温度
    catalystActiveTime = 1800,                          -- 活化时间
    digestTime = 900,                                   -- 消解时间
    reactTemperature = 680,                             -- 反应温度
    lastReactTemperature = 680,                         --上一次反应温度
    measureModuleTemperature = 50,                      --NDIR温度
    lastMeasureModuleTemperature = 50,
    reactTime = 30,                                     -- 反应时间
    temperatureIncrement = 0,                         --温度增量(加试剂二)
    negativeRevise = true,                              -- 负值修正
    shiftFactor = 0,                                    -- 平移因子
    reviseFactor = 1,                                   -- 修正因子
    meterLedAD =
    {
        3500,
        3500,
    },
    measureLedAD =
    {
        reference = 3.75,
        measure = 3.75,
        offsetPercent = 0.05,
        timeout = 30,
    },

    pidCtrl = true,                                     -- PID调光
    calibratePointConsistency =                         -- 标定浓度
    {
        0.0,                                            -- 标定0的浓度
        100.0,                                          -- 标定1的浓度
        100.0,                                            -- 标定2的浓度
        100.0,                                          -- 标定3的浓度
        500.0,                                            -- 标定4的浓度
        2500.0,                                          -- 标定5的浓度
        5000.0,                                            -- 标定6的浓度
        10000.0,                                          -- 标定7的浓度
    },
    range2StandardConsistency = 500,                       -- 量程二校正液浓度
    range3StandardConsistency = 2500,                       -- 量程三校正液浓度
    range4StandardConsistency = 500,                       -- 量程4校正液浓度
    range5StandardConsistency = 2500,                       -- 量程5校正液浓度
    range6StandardConsistency = 5000,                       -- 量程6校正液浓度
    range7StandardConsistency = 10000,                       -- 量程7校正液浓度
    cleanBefMeaBlankVol = 0,       -- 测量前清洗，零点校准液体积
    cleanAftMeaBlankVol = 0,       -- 测量后清洗，零点校准液体积
    wasteWaterEnvironment = false,                           -- 污水环境
    highSaltMode = false,          -- 高盐模式
    cleanSampleVol = 0,                                 -- 加完水样后，零点校准液清洗水样管体积
    extendSamplePipeVolume = 0,     -- 水样管延长体积
    sampleRenewVolume = 0,           -- 样品更新体积
    zeroAccurateCalibrate = false,                      -- 零点精准校准
    standardAccurateCalibrate = false,                  -- 标点精准校准
    rangeAccurateCalibrate = false,                     -- 量程精准校正
    curveQualifiedDetermination = false,                -- 标线合格判定
    rangeCalibrateDeviation = 0,                        -- 量程精准校正偏差阈值
    checkConsistency = 100,                             -- 标样核查浓度
    checkErrorLimit = 0.1,                              -- 标样核查偏差限值
    checkReporting = true,
    failAutoRevise = false,                             -- 核查失败自动校准
    accurateCheck = false,                               -- 精准核查
    highClMode = false,                                 -- 高氯模式
    readInitRilentTime = 120,                           -- 读初始值前静置时间
    heaterMaxDutyCycle = 0.2,                           -- 加热丝最大占空比
    digestionFanLevel = 1,                              -- 消解风扇功率等级
    stoveFanLevel = 1,                                  -- 电炉风扇等级
    exposureTime = 50,                                  -- TOC曝气时间
    exposureValveVoltage = 1.5,                         -- 曝气比例阀输出电压
    carryingValveVoltage = 1.2,                           -- 载气比例阀输出电压
    carryingPressure = 60,                              -- 自动调节压力
    preCarryingPressure = 60,                           -- 预设调节压力
    lastCarryingPressure = 60,                          -- 历史自动调节压力
    exposurePressure = 60,                              -- 曝气压力
    syringeUpdateCnt = 1,                               -- 注射器加样更新次数
    addSampleMidtime = 0.5,                             -- 加样间隔时间
    addSampleCnt = 2,                                   -- 注射器加样次数
    baseLineCheckCnt = 1,                               -- 基线合格判定次数
    volumeIndex = 0,                                    -- 注射器加样体积
    curveParam =                                        -- 曲线参数
    {
        {
            curveK = 1,                                     -- 量程一曲线斜率
            curveB = 0,                                     -- 量程一曲线截距
            ZeroConsistency = 0,
            RangeConsistency = 16,
            CODRangeConsistency = 40,                            -- 当前COD量程量程校准液浓度
            timeStr = "--",
        },
        {
            curveK = 1,                                     -- 量程二曲线斜率
            curveB = 0,                                     -- 量程二曲线截距
            ZeroConsistency = 0,
            RangeConsistency = 80,
            CODRangeConsistency = 200,                            -- 当前COD量程量程校准液浓度
            timeStr = "--",
        },
        {
            curveK = 1,                                     -- 量程三曲线斜率
            curveB = 0,                                     -- 量程三曲线截距
            ZeroConsistency = 0,
            RangeConsistency = 400,
            CODRangeConsistency = 1000,                            -- 当前COD量程量程校准液浓度
            timeStr = "--",
        },
        {
            curveK = 1,                                     -- 量程四曲线斜率
            curveB = 0,                                     -- 量程四曲线截距
            ZeroConsistency = 0,
            RangeConsistency = 1600,
            CODRangeConsistency = 4000,                            -- 当前COD量程量程校准液浓度
            timeStr = "--",
        },
        {
            curveK = 1,                                     -- 量程五曲线斜率
            curveB = 0,                                     -- 量程五曲线截距
            ZeroConsistency = 0,
            RangeConsistency = 4000,
            CODRangeConsistency = 10000,                            -- 当前COD量程量程校准液浓度
            timeStr = "--",
        },
    },
    reviseParameter =                                   -- 内部校正参数
    {
        _G.setting.measure.range[1].excursion,
        _G.setting.measure.range[2].excursion,
        _G.setting.measure.range[3].excursion,
        _G.setting.measure.range[4].excursion,
        _G.setting.measure.range[5].excursion,
    },
    measureDataOffsetValve = 0,
}
