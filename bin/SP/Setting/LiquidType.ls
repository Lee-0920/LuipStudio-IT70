setting.liquidType = {}

setting.liquidType.map =
{
    valve1 = 1,
    valve2 = 2,
    valve3 = 4,
    valve4 = 8,
    valve5 = 16,
    valve6 = 32,
    valve7 = 64,
    valve8 = 128,
    valve9 = 256,
    valve10= 512,
    valve11= 1024,
    valve12= 2048,
    valve13= 4096,
    valve14= 8192,
    valve15= 16384,
    valve16= 32768,
}

--无任何阀
setting.liquidType.none =
{
    name = "None",
    pump = 0,
    valve = 0,
}

--总阀
setting.liquidType.master =
{
    name = "Master",
    pump = 0,
    valve = setting.liquidType.map.valve4,
}

--水样
setting.liquidType.sample =
{
    name = "Sample",
    pump = 0,
    valve = setting.liquidType.map.valve1
            + setting.liquidType.map.valve4,
}

--量程校准液
setting.liquidType.standard =
{
    name = "Standard",
    pump = 0,
    valve = setting.liquidType.map.valve2
            + setting.liquidType.map.valve4,
}

--零点校准液
setting.liquidType.blank =
{
    name = "Blank",
    pump = 0,
    valve = setting.liquidType.map.valve3
            + setting.liquidType.map.valve4,
}

--量程核查液
setting.liquidType.rangeCheck =
{
    name = "RangeCheck",
    pump = 0,
    valve = setting.liquidType.map.valve15
            + setting.liquidType.map.valve4,
}

--零点核查液
setting.liquidType.zeroCheck =
{
    name = "ZeroCheck",
    pump = 0,
    valve = setting.liquidType.map.valve14
            + setting.liquidType.map.valve4,
}

--消解室
setting.liquidType.digestionRoom =
{
    name = "DigestionRoom",
    pump = 0,
    valve = setting.liquidType.map.valve10
            + setting.liquidType.map.valve4,
}

--加样管
setting.liquidType.dosingPipe =
{
    name = "DosingPipe",
    pump = 0,
    valve = setting.liquidType.map.valve6
            + setting.liquidType.map.valve4,
}

--废水
setting.liquidType.wasteWater =
{
    name = "WasteWater",
    pump = 0,
    valve = setting.liquidType.map.valve11
            + setting.liquidType.map.valve4,
}

--分析废液
setting.liquidType.waste =
{
    name = "Waste",
    pump = 0,
    valve = setting.liquidType.map.valve6
            + setting.liquidType.map.valve4,
}

--试剂1
setting.liquidType.reagent1 =
{
    name = "Reagent1",
    pump = 0,
    valve = setting.liquidType.map.valve7
            + setting.liquidType.map.valve4,
}

--试剂2
setting.liquidType.reagent2 =
{
    name = "Reagent2",
    pump = 0,
    valve = setting.liquidType.map.valve8,
}

--试剂2
setting.liquidType.reagent2Spare =
{
    name = "Reagent2Spare",
    pump = 0,
    valve = setting.liquidType.map.valve9,
}


--电炉
setting.liquidType.stove =
{
    name = "Stove",
    pump = 2,
    valve = setting.liquidType.map.valve8
            + setting.liquidType.map.valve4,

}

--曝气
setting.liquidType.exposureNirtrogen =
{
    name = "ExposureNirtrogen",
    pump = 0,
    valve = setting.liquidType.map.valve4
            + setting.liquidType.map.valve10,
}

--进样
setting.liquidType.sliders =
{
    name = "Sliders",
    pump = 3,
    valve = setting.liquidType.map.valve4,
}

--气密性检查阀
setting.liquidType.gas =
{
    name = "Gas",
    pump = 0,
    valve = setting.liquidType.map.valve2
            + setting.liquidType.map.valve3
            + setting.liquidType.map.valve7
}

--卤素液
setting.liquidType.halogenBottleWater =
{
    name = "HalogenBottleWater",
    pump = 0,
    valve = setting.liquidType.map.valve12
            + setting.liquidType.map.valve4,
}

--冷凝水
setting.liquidType.coolerWater =
{
    name = "CoolerWater",
    pump = 0,
    valve = setting.liquidType.map.valve9
            + setting.liquidType.map.valve4,

}

--注射器废液
setting.liquidType.syringeWaste =
{
    name = "SyringeWaste",
    pump = 2,
    valve = setting.liquidType.map.valve4,

}

--注射器燃烧炉
setting.liquidType.syringeStove =
{
    name = "SyringeStove",
    pump = 2,
    valve = setting.liquidType.map.valve4,

}

--注射器空白水
setting.liquidType.syringeBlank =
{
    name = "SyringeBlank",
    pump = 2,
    valve = setting.liquidType.map.valve8
            +setting.liquidType.map.valve4,

}

--无注射器任何阀
setting.liquidType.syringNone =
{
    name = "None",
    pump = 2,
    valve = setting.liquidType.map.valve4,
}

--排积液
setting.liquidType.seeper =
{
    name = "Seeper",
    pump = 0,
    valve = setting.liquidType.map.valve5
            +setting.liquidType.map.valve12
            +setting.liquidType.map.valve4,
}

--注射器
setting.liquidType.syringeSerial =
{
    name = "syringeSerial",
    pump = 2,
    valve = setting.liquidType.map.valve4
            +setting.liquidType.map.valve11
            +setting.liquidType.map.valve6,

}

--测量灯换气阀
setting.liquidType.airLED =
{
    name = "AirLED",
    pump = 0,
    valve = setting.liquidType.map.valve4
            + setting.liquidType.map.valve13,
}

return setting.liquidType
