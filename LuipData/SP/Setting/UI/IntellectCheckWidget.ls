setting.ui.diagnosis = {}
setting.ui.diagnosis.smartDetect =
{
    name ="smartDetect",
    text= "智能诊断",
    rowCount = 13,
    writePrivilege=  RoleType.Administrator,
    readPrivilege = RoleType.Administrator,
    superRow = 0,
    administratorRow = 13,
    {-- 1
        name ="SmartBlankValveDetect",
        text= "零点校准液阀",
        createFlow= function()
            local flow = SmartValveDetectFlow:new({}, setting.liquidType.blank, setting.runAction.smartBlankValveDetect)
            flow.name  = setting.ui.diagnosis.smartDetect[1].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 2
        name ="SmartSampleValveDetect",
        text= "水样阀",
        createFlow= function()
            local flow = SmartValveDetectFlow:new({}, setting.liquidType.sample, setting.runAction.smartSampleValveDetect)
            flow.name  = setting.ui.diagnosis.smartDetect[2].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 3
        name ="SmartStandardValveDetect",
        text= "量程校准液阀",
        createFlow= function()
            local flow = SmartValveDetectFlow:new({}, setting.liquidType.standard, setting.runAction.smartStandardValveDetect)
            flow.name  = setting.ui.diagnosis.smartDetect[3].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {--4
        name ="SmartZeroCheckValveDetect",
        text= "零点核查阀",
        createFlow= function()
            local flow = SmartValveDetectFlow:new({}, setting.liquidType.zeroCheck, setting.runAction.smartZeroCheckValveDetect)
            flow.name  = setting.ui.diagnosis.smartDetect[4].name
            FlowList.AddFlow(flow)
        end,
        --targetPrivilege = Target.EXTEND,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 5
        name ="SmartRangeCheckValveDetect",
        text= "标样(跨度)核查阀",
        createFlow= function()
            local flow = SmartValveDetectFlow:new({}, setting.liquidType.rangeCheck, setting.runAction.smartRangeCheckValveDetect)
            flow.name  = setting.ui.diagnosis.smartDetect[5].name
            FlowList.AddFlow(flow)
        end,
        --targetPrivilege = Target.EXTEND,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 6
        name ="SmartReagent1ValveDetect",
        text= "试剂一阀",
        createFlow= function()
            local flow = SmartValveDetectFlow:new({}, setting.liquidType.reagent1, setting.runAction.smartReagent1ValveDetect)
            flow.name  = setting.ui.diagnosis.smartDetect[6].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    --{--
    --    name ="SmartReagent2ValveDetect",
    --    text= "试剂二阀",
    --    createFlow= function()
    --        local flow = SmartValveDetectFlow:new({}, setting.liquidType.reagent2, setting.runAction.smartReagent2ValveDetect)
    --        flow.name  = setting.ui.diagnosis.smartDetect[5].name
    --        FlowList.AddFlow(flow)
    --    end,
    --    writePrivilege=  RoleType.Administrator,
    --    readPrivilege = RoleType.Administrator,
    --},
    {-- 7
        name ="SmartDigestionRoomValveDetect",
        text= "逐出室阀",
        createFlow= function()
            local flow = SmartValveDetectFlow:new({}, setting.liquidType.digestionRoom, setting.runAction.smartDigestionRoomValveDetect)
            flow.name  = setting.ui.diagnosis.smartDetect[7].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 8
        name ="SmartWasteValveDetect",
        text= "分析废液阀",
        createFlow= function()
            local flow = SmartValveDetectFlow:new({}, setting.liquidType.waste, setting.runAction.smartWasteValveDetect)
            flow.name  = setting.ui.diagnosis.smartDetect[8].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 9
        name ="SmartWasteWaterValveDetect",
        text= "清洗废水阀",
        createFlow= function()
            local flow = SmartValveDetectFlow:new({}, setting.liquidType.wasteWater, setting.runAction.smartWasteWaterValveDetect)
            flow.name  = setting.ui.diagnosis.smartDetect[9].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 10
        name ="SmartMeterDetect",
        text= "定量模块",
        createFlow= function()
            local flow = SmartMeterDetectFlow:new()
            flow.name  = setting.ui.diagnosis.smartDetect[10].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 11
        name ="SmartMeasureDetect",
        text= "测量模块",
        createFlow= function()
            local flow = SmartMeasureDetectFlow:new()
            flow.name  = setting.ui.diagnosis.smartDetect[11].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 12
        name ="SmartHeatDetect",
        text= "加热模块",
        createFlow= function()
            local flow = SmartHeatDetectFlow:new()
            flow.name  = setting.ui.diagnosis.smartDetect[12].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    {-- 13
        name ="SmartCoolDetect",
        text= "冷却模块",
        createFlow= function()
            local flow = SmartCoolDetectFlow:new()
            flow.name  = setting.ui.diagnosis.smartDetect[13].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
}
