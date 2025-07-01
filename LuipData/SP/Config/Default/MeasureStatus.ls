status.measure =
{
    schedule =                      -- 自动测量
    {
        autoMeasure =               -- 自动测量
        {
            dateTime = _G.os.time(),   -- 测量日期
        },
        zeroCheck =               -- 零点核查
        {
            dateTime = _G.os.time(),   -- 核查日期
        },
        rangeCheck =             -- 核查液
        {
            dateTime = _G.os.time(),   -- 核查日期
        },
        autoCalibrate =             -- 自动校准
        {
            dateTime = _G.os.time(),   -- 校准日期
        },
        autoClean =                 -- 自动清洗
        {
            dateTime = _G.os.time(),   -- 清洗日期
        },
        autoBlankCheck =                 -- 自动测零点校准液
        {
            dateTime = _G.os.time(),   -- 测零点校准液日期
        },
        autoCheck =                 -- 自动核查
        {
            dateTime = _G.os.time(),   -- 核查日期
        },
        autoAddstandard =           -- 自动加标
        {
            dateTime = _G.os.time(),   -- 核查日期
        },
        autoParallel =              -- 自动平行
        {
            dateTime = _G.os.time(),   -- 核查日期
        },
        autoSuckHalogenBottleWater =              -- 自动平行
        {
            dateTime = _G.os.time(),   -- 排卤素液日期
        },
        autoCatalystActive =              -- 自动平行
        {
            dateTime = _G.os.time(),   -- 催化剂活化日期
        },
        autoQuickMeasure =                 -- 自动平行
        {
            dateTime = _G.os.time(),   -- 快速测量
        },
        autoAirReplacement =    -- 气体置换
        {
            dateTime = _G.os.time(),   -- 排冷凝液日期
        },
        autoCollectSample =              -- 自动采样
        {
            dateTime = _G.os.time(),   -- 采样日期
        },
    },

    report =
    {
        measure =                   -- 测量结果上报
        {
            dateTime = 0,           -- 测量日期
            consistency = 0,        --TOC 4-20输出浓度
            consistencyCOD = 0,     --COD 4-20输出浓度
            resultType = 0,        --  测量类型
            measureTime = 0,        -- 测量时长
            absorbance = 0,         -- 吸光度
            deviceTypeNum = 0,      -- 设备参数类型号
            oldTypeNum = 0,         -- 旧设备参数类型号
            resultInfo = "N",       -- 数据标识
        },
        addstandard =
        {
            dateTime = 0,           -- 加标样日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "N",       -- 数据标识
        },
        parallel =
        {
            dateTime = 0,           -- 平行样日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "N",       -- 数据标识
        },
        check =
        {
            dateTime = 0,           -- 核查日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "N",       -- 数据标识
        },
        blankCheck =
        {
            dateTime = 0,           -- 核查日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "N",       -- 数据标识
        },
        zeroCheck =
        {
            dateTime = 0,           -- 零点核查日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "N",       -- 数据标识
        },
        rangeCheck =
        {
            dateTime = 0,           -- 量程核查日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "N",       -- 数据标识
        },
        qualityHandle =
        {
            dateTime = 0,           -- 测质控样日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "B",       -- 数据标识
        },
        complexResult =             -- 复合测量结果上报
        {
            dateTime = 0,           -- 测量日期
            consistency = 0,        --4-20输出浓度
            resultType = 0,         --  测量类型
            measureTime = 0,        -- 测量时长
            absorbance = 0,         -- 吸光度
            deviceTypeNum = 0,      -- 设备参数类型号
            oldTypeNum = 0,         -- 旧设备参数类型号
            resultInfo = "N",       -- 数据标识
        },
    },
    offline =                       --离线数据缓存
    {
        measure =                   -- 测量结果
        {
            dateTime = 0,           -- 测量日期
            consistency = 0,        --4-20输出浓度
            resultType = 0,        --  测量类型
            measureTime = 0,        -- 测量时长
            absorbance = 0,         -- 吸光度
            deviceTypeNum = 0,      -- 设备参数类型号
            oldTypeNum = 0,         -- 旧设备参数类型号
            resultInfo = "B",       -- 数据标识
        },
        addstandard =
        {
            dateTime = 0,           -- 加标样日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "B",       -- 数据标识
        },
        parallel =
        {
            dateTime = 0,           -- 平行样日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "B",       -- 数据标识
        },
        check =
        {
            dateTime = 0,           -- 核查日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "B",       -- 数据标识
        },
        blankCheck =
        {
            dateTime = 0,           -- 核查日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "B",       -- 数据标识
        },
        zeroCheck =
        {
            dateTime = 0,           -- 零点核查日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "B",       -- 数据标识
        },
        rangeCheck =
        {
            dateTime = 0,           -- 量程核查日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "B",       -- 数据标识
        },
        qualityHandle =
        {
            dateTime = 0,           -- 测质控样日期
            consistency = 0,        --4-20输出浓度
            absorbance = 0,         -- 吸光度
            resultInfo = "B",       -- 数据标识
        },
    },

    proformaResult =
    {
        measure =                   -- 新测量结果
        {
            dateTime = 0,           -- 测量日期
            consistency = 0,        -- 测量浓度
            absorbance = 0,    	    -- 吸光度
            blankReference = 0,     -- 空白参考AD值
            blankMeasure = 0,       -- 空白测量AD值
            initReference = 0,      -- 初始参考AD值
            initMeasure = 0,        -- 初始测量AD值
            finalReference = 0,     -- 反应参考AD值
            finalMeasure = 0,       -- 反应测量AD值
        },
    },

    newResult =
    {
        measure =                   -- 新测量结果
        {
            dateTime = 0,           -- 测量日期
            consistency = 0,        -- 测量浓度
            consistencyCOD = 0,     -- COD测量浓度
            resultType = 255,        --  测量类型
            absorbance = 0,    	    -- 吸光度
            peakArea = 0,           --峰面积
            resultInfo = "N",       -- 数据标识
            resultMark = "N",       -- 数据标识(兼容初版地表水协议)
            isUseStart = false,     -- 是否为用户手动启动
            isFault = false,        -- 流程是否出错
            modelType = 0,          --测量参数
        },
        calibrate =                 -- 新校准结果
        {
            dateTime = 0,           -- 测量日期
            curveB = 0,             -- 曲线截距
            curveK = 1,             -- 曲线斜率
            point0Consistency = 0,  -- 零点浓度
            point1Consistency = 0,  -- 标点浓度
            point0Absorbance = 0,   -- 零点吸光度值
            point1Absorbance = 0,   -- 标点吸光度值
            point0PeakArea = 0,     -- 零点峰面积
            point1PeakArea = 0,     -- 标点峰面积
            zeroCalculateConsistency = 0,       -- 零点计算浓度
            standardCalculateConsistency = 0,   -- 标点计算浓度
            zeroCheckError = 0,                 -- 零点偏差
            standardCheckError = 0,             -- 标点偏差
            R2 = 1,
            zeroCalibrateDateTime = 0,    -- 零点校准时间
            standardCalibrateDateTime=0,  -- 量程校准时间
        },
    },

    calibrate =
    {
        {
            dateTime = 0,           -- 测量日期
            curveB = 0,             -- 曲线截距
            curveK = 1,             -- 曲线斜率
            point0Consistency = 0,  -- 零点浓度
            point1Consistency = 0,  -- 标点浓度
            point0Absorbance = 0,   -- 零点吸光度值
            point1Absorbance = 0,   -- 标点吸光度值
            point0PeakArea = 0,     -- 零点峰面积
            point1PeakArea = 0,     -- 标点峰面积
            R2 = 1,
            zeroCalibrateDateTime = 0,    -- 零点校准时间
            standardCalibrateDateTime=0,  -- 量程校准时间
            userSettings = false,
        },
        {
            dateTime = 0,           -- 测量日期
            curveB = 0,             -- 曲线截距
            curveK = 1,             -- 曲线斜率
            point0Consistency = 0,  -- 零点浓度
            point1Consistency = 0,  -- 标点浓度
            point0Absorbance = 0,   -- 零点吸光度值
            point1Absorbance = 0,   -- 标点吸光度值
            point0PeakArea = 0,     -- 零点峰面积
            point1PeakArea = 0,     -- 标点峰面积
            R2 = 1,
            zeroCalibrateDateTime = 0,    -- 零点校准时间
            standardCalibrateDateTime=0,  -- 量程校准时间
            userSettings = false,
        },
        {
            dateTime = 0,           -- 测量日期
            curveB = 0,             -- 曲线截距
            curveK = 1,             -- 曲线斜率
            point0Consistency = 0,  -- 零点浓度
            point1Consistency = 0,  -- 标点浓度
            point0Absorbance = 0,   -- 零点吸光度值
            point1Absorbance = 0,   -- 标点吸光度值
            point0PeakArea = 0,     -- 零点峰面积
            point1PeakArea = 0,     -- 标点峰面积
            R2 = 1,
            zeroCalibrateDateTime = 0,    -- 零点校准时间
            standardCalibrateDateTime=0,  -- 量程校准时间
            userSettings = false,
        },
        {
            dateTime = 0,           -- 测量日期
            curveB = 0,             -- 曲线截距
            curveK = 1,             -- 曲线斜率
            point0Consistency = 0,  -- 零点浓度
            point1Consistency = 0,  -- 标点浓度
            point0Absorbance = 0,   -- 零点吸光度值
            point1Absorbance = 0,   -- 标点吸光度值
            point0PeakArea = 0,     -- 零点峰面积
            point1PeakArea = 0,     -- 标点峰面积
            R2 = 1,
            zeroCalibrateDateTime = 0,    -- 零点校准时间
            standardCalibrateDateTime=0,  -- 量程校准时间
            userSettings = false,
        },
        {
            dateTime = 0,           -- 测量日期
            curveB = 0,             -- 曲线截距
            curveK = 1,             -- 曲线斜率
            point0Consistency = 0,  -- 零点浓度
            point1Consistency = 0,  -- 标点浓度
            point0Absorbance = 0,   -- 零点吸光度值
            point1Absorbance = 0,   -- 标点吸光度值
            point0PeakArea = 0,     -- 零点峰面积
            point1PeakArea = 0,     -- 标点峰面积
            R2 = 1,
            zeroCalibrateDateTime = 0,    -- 零点校准时间
            standardCalibrateDateTime=0,  -- 量程校准时间
            userSettings = false,
        },
        {
            dateTime = 0,           -- 测量日期
            curveB = 0,             -- 曲线截距
            curveK = 1,             -- 曲线斜率
            point0Consistency = 0,  -- 零点浓度
            point1Consistency = 0,  -- 标点浓度
            point0Absorbance = 0,   -- 零点吸光度值
            point1Absorbance = 0,   -- 标点吸光度值
            point0PeakArea = 0,     -- 零点峰面积
            point1PeakArea = 0,     -- 标点峰面积
            R2 = 1,
            zeroCalibrateDateTime = 0,    -- 零点校准时间
            standardCalibrateDateTime=0,  -- 量程校准时间
            userSettings = false,
        },
        {
            dateTime = 0,           -- 测量日期
            curveB = 0,             -- 曲线截距
            curveK = 1,             -- 曲线斜率
            point0Consistency = 0,  -- 零点浓度
            point1Consistency = 0,  -- 标点浓度
            point0Absorbance = 0,   -- 零点吸光度值
            point1Absorbance = 0,   -- 标点吸光度值
            point0PeakArea = 0,     -- 零点峰面积
            point1PeakArea = 0,     -- 标点峰面积
            R2 = 1,
            zeroCalibrateDateTime = 0,    -- 零点校准时间
            standardCalibrateDateTime=0,  -- 量程校准时间
            userSettings = false,
        },
    },

    standardCurve = 0 ,         -- 基准曲线（最新一次完整定标的量程）
    lastMeasureEndTime = 0,     -- 上一次测量流程结束日期
    isDeviceFault = false,
    isFatalError = false,
    isUseStart = false,     -- 是否为用户手动启动 正在进行的流程
    isCheckBaseLine = true,    -- 基线状态
}
