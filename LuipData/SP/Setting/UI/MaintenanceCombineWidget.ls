setting.ui.operation.maintainCombine =
{
    name ="maintainCombine",
    text= "维护组合",
    writePrivilege=  RoleType.Administrator,
    readPrivilege = RoleType.Administrator,
    {
        name = "MeasureSample",
        text= "测量水样",
        createFlow= function()
            local flow = MeasureFlow:new({}, MeasureType.Sample)
            flow.name = "MeasureSample"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name = "OneKeyMaintain",
        text= "一键校准",
        createFlow= function()
            local flow = CalibrateFlow:new({}, CalibrateType.oneKeyMaintain)
            flow.name = "OneKeyMaintain"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name = "Calibrate",
        text= "校准",
        createFlow= function()
            local flow = CalibrateFlow:new({}, CalibrateType.calibrate)
            flow.name  = "Calibrate"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureRangeCheck",
        text= "标样(跨度)核查",
        createFlow= function()
            local flow = MeasureFlow:new({}, MeasureType.RangeCheck)
            flow.name ="MeasureRangeCheck"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureZeroCheck",
        text= "零点核查",
        createFlow= function()
            local flow = MeasureFlow:new({}, MeasureType.ZeroCheck)
            flow.name ="MeasureZeroCheck"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureStandard",
        text= "测量程校准液",
        createFlow= function()
            local flow = MeasureFlow:new({}, MeasureType.Standard)
            flow.name ="MeasureStandard"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureBlank",
        text= "测零点校准液",
        createFlow= function()
            local flow = MeasureFlow:new({}, MeasureType.Blank)
            flow.name ="MeasureBlank"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="CleanDeeply",
        text= "深度清洗",
        createFlow= function()
            local flow = CleanFlow:new({},cleanType.cleanDeeply)
            flow.name ="CleanDeeply"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="OneKeyRenew",
        text= "一键更新试剂",
        createFlow= function()
            local flow = CleanFlow:new({}, cleanType.oneKeyRenew)
            flow.name ="OneKeyRenew"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },

    ClearFlowList = function()
        log:debug("MaintainCombine ClearFlowList")
        FlowList.ClearList()
    end,
}
return setting.ui.operation.maintainCombine
