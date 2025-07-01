setting.ui.signalIterms =
{
    rowCount = 11,
    {
        name = "AcquireAD",
        text = "测量管",
        {
            name = "meaAD",
            text = "测量值",
            unit = "V",
            format = "%.6f",
        },
    },
    {
        name = "MeterPipe",
        text = "定量管",
        {
            name = "mp1AD",
            text = "点一AD",
            format = "%.0f",
        },
        {
            name = "mp2AD",
            text = "点二AD",
            format = "%.0f",
        },
    },
    {
        name = "DigestRoom ",
        text = "燃烧炉",
        showAD = false,
        {
            name = "tTemp",
            text = "燃烧炉温度",
            unit = "℃",
            format = "%.1f",
        },
        --{
        --    name = "eStoveAD",
        --    text = "温度AD",
        --    unit = " ",
        --    format = "%.0f",
        --},
    },
    {
        name = "Refrigerator",
        text = "制冷器",
        {
            name = "tTemp1",
            text = "制冷温度",
            unit = "℃",
            format = "%.1f",
        },
    },
    {
        name = "MeasureModule",
        text = "测量模块",
        {
            name = "tTemp2",
            text = "测量温度",
            unit = "℃",
            format = "%.1f",
        },
    },
    {
        name = "Instrument",
        text = "仪器",
        {
            name = "eTemp",
            text = "上机箱温度",
            unit = "℃",
            format = "%.1f",
        },
        {
            name = "tTemp3",
            text = "下机箱温度",
            unit = "℃",
            format = "%.1f",
        },
    },
    {
        name = "PressureSensor",
        text = "压力传感器",
        {
            name = "pSensor1",
            text = "总阀压力",
            unit = "kPa",
            format = "%.2f",
        },
        {
            name = "pSensor2",
            text = "曝气压力",
            unit = "kPa",
            format = "%.2f",
        },
        {
            name = "pSensor3",
            text = "载气压力",
            unit = "kPa",
            format = "%.2f",
        },
    },
    --{
    --    name = "TempCalibration",
    --    text = "校准AD值",
    --    showAD = false,
    --    {
    --        name = "eTempCheck",
    --        text = "燃烧炉AD值",
    --        unit = " ",
    --        format = "%.0f",
    --    },
    --},
}

return setting.ui.signalIterms
