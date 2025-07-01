config.interconnection =
{
    alarmValue = false,				-- 报警
    outputType = 0,                 -- 输出参数类型(单参数默认0)
    meaUpLimit = _G.setting.measure.range[_G.setting.measure.range.rangeNum].viewRange,				-- 测量上限
    meaLowLimit = 0,			    -- 测量下限
    overProofResultMark = 0,        -- 超上限标识
    rangeCheckResultMark = 0,       -- 核查标识
    overProofAutoCheck = false,     -- 超标启动核查
    connectAddress = 1,				-- 通信地址
    RS485BaudRate  = 0,				-- RS485传输速率
    RS485Parity = 0,				-- RS485校验位
    RS232BaudRate = 0,				-- RS232传输速率
    RS232Parity = 0,				-- RS232校验位
    sampleLowLimit = 0,				-- 水样4-20浓度下限
    sampleUpLimit = 200,			-- 水样4-20浓度上限
    collectSampleMode = 0,	        -- 采水模式
    miningWaterTime = 20,			-- 采水时间
    silentTime = 20,				-- 静默时间
    collectSamplePeriod = 2,        -- 采水周期
    relayOne = 5,					-- 继电器1
    relayTwo = 0,					-- 继电器2
    reportMode = _G.ReportMode.OnLine,					-- 上报模式
    settingIPMode = _G.SettingIPMode.DHCP,				-- 设置IP模式
}

