setting.ui.operation.hardwareTest =
{
    name ="hardwareTest",
    text= "硬件测试",
    rowCount = 31,
    writePrivilege=  RoleType.Administrator,
    readPrivilege = RoleType.Administrator,
    superRow = 0,
    administratorRow = 31,
    {
        name = "PumpGroup",
        text = "泵组",
        {
            name ="MeterPump",
            text= "定量泵",
            createFlow= function(action)
                -- print("MeterPump", action)
                return HardwareTest:execute(1, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="SyringPump",
            text= "注射泵",
            createFlow= function(action)
                -- print("MeterPump", action)
                return HardwareTest:execute(34, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "ValveGroup",
        text = "阀组",
        {
            name ="SampleValve",
            text= "水样阀",
            createFlow= function(action)
                -- print("SampleValve", action)
                return HardwareTest:execute(2, action)
            end,
            writePrivilege = RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="reagent1Valve",
            text= "试剂一阀",
            createFlow= function(action)
                --print("reagent1Valve", action)
                return HardwareTest:execute(3, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="BlankValve",
            text= "零点校准液阀",
            createFlow= function(action)
                -- print("BlankValve", action)
                return HardwareTest:execute(7, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="standardValve",
            text= "量程校准液阀",
            createFlow= function(action)
                -- print("standardValve", action)
                return HardwareTest:execute(6, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="ZeroCheckValve",
            text= "零点核查液阀",
            createFlow= function(action)
                -- print("ZeroCheckValve", action)
                return HardwareTest:execute(8, action)
            end,
            --targetPrivilege = Target.EXTEND,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="RangeCheckValve",
            text= "标样(跨度)核查液阀",
            createFlow= function(action)
                -- print("RangeCheckValve", action)
                return HardwareTest:execute(9, action)
            end,
            --targetPrivilege = Target.EXTEND,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="WasteValve",
            text= "分析废液阀",
            createFlow= function(action)
                --print("WasteValve", action)
                return HardwareTest:execute(10, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="WasteWaterValve",
            text= "清洗废水阀",
            createFlow= function(action)
                --print("WasteValve", action)
                return HardwareTest:execute(11, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="RefrigeratorWaterValve",
            text= "冷凝水阀",
            createFlow= function(action)
                --print("DigestRoomUpValve", action)
                return HardwareTest:execute(40, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="DigestRoomBottomValve",
            text= "逐出室下阀",
            createFlow= function(action)
                --print("DigestRoomBottomValve", action)
                return HardwareTest:execute(13, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="ProportionalValve1",
            text= "曝气比例阀",
            createFlow= function(action)
                --print("DigestRoomBottomValve", action)
                return HardwareTest:execute(27, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="ProportionalValve2",
            text= "载气比例阀",
            createFlow= function(action)
                --print("DigestRoomBottomValve", action)
                return HardwareTest:execute(28, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="HalogenBottleWater",
            text= "卤素三通阀",
            createFlow= function(action)
                --print("DigestRoomUpValve", action)
                return HardwareTest:execute(41, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="ThreeWayValve",
            text= "加样三通阀",
            createFlow= function(action)
                -- print("reagent2SpareValve", action)
                return HardwareTest:execute(42, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="NirtrogenValve",
            text= "氮气阀",
            createFlow= function(action)
                return HardwareTest:execute(30, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "MeasurementModule",
        text = "测量模块",
        {
            name ="MeasuerLED",
            text= "测量LED",
            createFlow= function(action)
                -- print("MeasuerLED", action)
                return HardwareTest:execute(16, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "OpticalMeter",
        text = "光学定量",
        {
            name ="Meter1LED",
            text= "定量点一LED",
            createFlow= function(action)
                -- print("Meter1LED", action)
                return HardwareTest:execute(17, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="Meter2LED",
            text= "定量点二LED",
            createFlow= function(action)
                -- print("Meter2LED", action)
                return HardwareTest:execute(18, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "MiningRelay",
        text = "继电器",
        {
            name ="CollectSampleRelay",
            text= "采水继电器",
            showCheck = true,
            createFlow= function(action)
                --  print("CollectSampleRelay", action)
                return HardwareTest:execute(19, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="Relay1",
            text= "继电器1",
            createFlow= function(action)
                -- print("Relay1", action)
                return HardwareTest:execute(20, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="Relay2",
            text= "继电器2",
            createFlow= function(action)
                -- print("Relay2", action)
                return HardwareTest:execute(21, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "Sample4-20mA",
        text = "样品4-20mA",
        {
            name ="SampleCurrent4Output",
            text= "4mA输出",
            analogConfig = true,
            createFlow= function(action)
                --   print("SampleCurrent4Output", action)
                return HardwareTest:execute(22, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="SampleCurrent12Output",
            text= "12mA输出",
            analogConfig = true,
            createFlow= function(action)
                --  print("SampleCurrent12Output", action)
                return HardwareTest:execute(23, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="SampleCurrent20Output",
            text= "20mA输出",
            analogConfig = true,
            createFlow= function(action)
                --print("SampleCurrent20Output", action)
                return HardwareTest:execute(24, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "TemperatureMonitoring",
        text = "温度监控",
        {
            name ="BoxUpFan",
            text= "上机箱风扇",
            createFlow= function(action)
                -- print("SystemFanTest", action)
                return HardwareTest:execute(39, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="BoxDownFan",
            text= "下机箱风扇",
            createFlow= function(action)
                -- print("SystemFanTest", action)
                return HardwareTest:execute(25, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
    },
    --{
    --    name = "Refrigeration",
    --    text = "制冷模块",
    --    {
    --        name ="Cooler",
    --        text= "制冷片",
    --        createFlow= function(action)
    --            -- print("SystemFanTest", action)
    --            return HardwareTest:execute(29, action)
    --        end,
    --        writePrivilege=  RoleType.Administrator,
    --        readPrivilege = RoleType.Administrator,
    --    },
    --    {
    --        name ="RefrigeratorFan",
    --        text= "制冷风扇",
    --        createFlow= function(action)
    --            --print("DigestionCooling", action)
    --            return HardwareTest:execute(26, action)
    --        end,
    --        writePrivilege=  RoleType.Administrator,
    --        readPrivilege = RoleType.Administrator,
    --    },
    --},
    --{
    --    name = "HeatModule",
    --    text = "加热模块",
    --    {
    --        name ="StoveHeating",
    --        text= "燃烧炉加热",
    --        createFlow= function(action)
    --            --print("StoveHeating", action)
    --            return HardwareTest:execute(14, action)
    --        end,
    --        writePrivilege=  RoleType.Administrator,
    --        readPrivilege = RoleType.Administrator,
    --    },
    --    {
    --        name ="StoveFan",
    --        text= "电炉风扇",
    --        createFlow= function(action)
    --            --print("StoveFan", action)
    --            return HardwareTest:execute(15, action)
    --        end,
    --        writePrivilege=  RoleType.Administrator,
    --        readPrivilege = RoleType.Administrator,
    --    },
    --},
    {
        name = "ExposureNirtrogen",
        text = "气流模块",
        {
            name ="ExposureNirtrogen",
            text= "曝气",
            createFlow= function(action)
                -- print("SystemFanTest", action)
                return HardwareTest:execute(31, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name ="CarrierGas",
            text= "载气",
            createFlow= function(action)
                -- print("SystemFanTest", action)
                return HardwareTest:execute(32, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "SlidersCheck",
        text = "进样模块",
        {
            name ="SlidersPump",
            text= "进样",
            isRemind = true,
            createFlow= function(action)
                -- print("MeterPump", action)createFlowcreateFlow
                return HardwareTest:execute(33, action)
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        --{
        --    name ="SlidersCalibrate",
        --    text= "进样校准",
        --    isRemind = true,
        --    createFlow= function(action)
        --        -- print("SystemFanTest", action)
        --        return HardwareTest:execute(36, action)
        --    end,
        --    writePrivilege=  RoleType.Administrator,
        --    readPrivilege = RoleType.Administrator,
        --},
        --{
        --    name ="SlidersForward",
        --    text= "前进校准",
        --    isRemind = true,
        --    createFlow= function(action)
        --        -- print("SystemFanTest", action)
        --        return HardwareTest:execute(37, action)
        --    end,
        --    writePrivilege=  RoleType.Administrator,
        --    readPrivilege = RoleType.Administrator,
        --},
        --{
        --    name ="SlidersBackward",
        --    text= "后退校准",
        --    isRemind = true,
        --    createFlow= function(action)
        --        -- print("SystemFanTest", action)
        --        return HardwareTest:execute(38, action)
        --    end,
        --    writePrivilege=  RoleType.Administrator,
        --    readPrivilege = RoleType.Administrator,
        --},
    },
    checkOEM = function()
        return config.system.OEM
    end,
    isShowCheck = function()
        return true
    end,
}
return setting.ui.operation.hardwareTest
