setting.ui.operation = {}
setting.ui.operation.maintain =
{
    name ="maintain",
    text= "维护",
    rowCount = 26,
    superRow = 3,
    administratorRow = 6,
    writePrivilege=  RoleType.Maintain,
    readPrivilege = RoleType.Maintain,
    {
        name ="MeasureSample",
        text= "测量水样",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.measureSample.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> MeasureFlow:Sample")
            config.system.isWaitting = true
            local flow = MeasureFlow:new({}, MeasureType.Sample)
            flow.name = "MeasureSample",
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="Calibrate",
        text= "校准",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.calibrate.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> CalibrateFlow")
            local flow = CalibrateFlow:new({}, CalibrateType.calibrate)
            flow.name  = "Calibrate"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureSampleRangeCheck",
        text= "水样管核查",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.measureSample.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> MeasureFlow:SampleRangeCheck")
            local flow = MeasureFlow:new({}, MeasureType.RangeCheck)
            flow.name  = "MeasureSampleRangeCheck"
            flow.isSampleRangeCheck = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureStandard",
        text= "测量程校准液",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.measureStandard.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> MeasureFlow:Standard")
            local flow = MeasureFlow:new({}, MeasureType.Standard)
            flow.name  = "MeasureStandard"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureBlank",
        text= "测零点校准液",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.measureBlank.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> MeasureFlow:Blank")
            local flow = MeasureFlow:new({}, MeasureType.Blank)
            flow.name  = "MeasureBlank"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureRangeCheck",
        text= "测标样(跨度)核查液",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.measureStandard.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> MeasureFlow:RangeCheck")
            local flow = MeasureFlow:new({}, MeasureType.RangeCheck)
            flow.name  = "MeasureRangeCheck"
            flow.isCheck = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureZeroCheck",
        text= "测零点核查液",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.measureStandard.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> MeasureFlow:ZeroCheck")
            local flow = MeasureFlow:new({}, MeasureType.ZeroCheck)
            flow.name  = "MeasureZeroCheck"
            flow.isCheck = true
            FlowList.AddFlow(flow)
        end,
    },
    --{
    --    name ="OnlyCalibrateStandard",
    --    text= "量程校准",
    --    writePrivilege=  RoleType.Maintain,
    --    readPrivilege = RoleType.Maintain,
    --    getRunTime = function()
    --        return setting.runStatus.onlyCalibrateStandard.GetTime()
    --    end,
    --    createFlow= function()
    --        log:debug("Maintain createFlow ==> CalibrateFlow:onlyCalibrateStandard")
    --        local flow = CalibrateFlow:new({}, CalibrateType.onlyCalibrateStandard)
    --        flow.name  = setting.ui.operation.maintain[8].name
    --        FlowList.AddFlow(flow)
    --    end,
    --},
    --{
    --    name ="OnlyCalibrateBlank",
    --    text= "零点校准",
    --    writePrivilege=  RoleType.Maintain,
    --    readPrivilege = RoleType.Maintain,
    --    getRunTime = function()
    --        return setting.runStatus.onlyCalibrateBlank.GetTime()
    --    end,
    --    createFlow= function()
    --        log:debug("Maintain createFlow ==> CalibrateFlow:onlyCalibrateBlank")
    --        local flow = CalibrateFlow:new({}, CalibrateType.onlyCalibrateBlank)
    --        flow.name  = setting.ui.operation.maintain[9].name
    --        FlowList.AddFlow(flow)
    --    end,
    --},
    {
        name ="CleanMeterPipe",
        text= "清洗定量管",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.cleanMeterPipe.GetTime()
        end,
        createFlow= function()
            local flow = CleanFlow:new({},cleanType.cleanMeterPipe)
            flow.name  = "CleanMeterPipe"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="CleanDigestionRoom",
        text= "清洗逐出室",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.cleanDigestionRoom.GetTime()
        end,
        createFlow= function()
            local flow = CleanFlow:new({},cleanType.cleanDigestionRoom)
            flow.name  = "CleanDigestionRoom"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="CleanDeeply",
        text= "深度清洗",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.cleanDeeply.GetTime()
        end,
        createFlow= function()
            local flow = CleanFlow:new({},cleanType.cleanDeeply)
            flow.name  = "CleanDeeply"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="CleanAll",
        text= "清洗所有管路",
        writePrivilege=  RoleType.Super,
        readPrivilege = RoleType.Super,
        getRunTime = function()
            return setting.runStatus.cleanAll.GetTime()
        end,
        createFlow= function()
            local flow = CleanFlow:new({},cleanType.cleanAll)
            flow.name = "CleanAll"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="CollectSample",
        text= "采集水样",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.collectSample.GetTime()
        end,
        createFlow= function()
            local flow = CollectSampleFlow:new()
            flow.name  = "CollectSample"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="SampleWaterRelay",
        text= "反吹",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.sampleWaterRelay.GetTime()
        end,
        createFlow= function()
            local flow = CollectSampleFlow:new({},true)
            flow.name  = "SampleWaterRelay"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="AutoCalibratePump",
        text= "定量泵自动校准",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        createFlow= function()
            local flow = AutoPumpCheckFlow:new()
            flow.name = "AutoCalibratePump"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeterADAdjust",
        text= "定量AD调节",
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
        getRunTime = function()
            return setting.runStatus.meterADAdjust.GetTime()
        end,
        createFlow= function()
            local flow = ADAdjustFlow:new({}, setting.runAction.meterADAdjust)
            flow.name  = "MeterADAdjust"
            flow.action = setting.runAction.meterADAdjust
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="OneKeyRenew",
        text= "一键更新试剂",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.oneKeyRenew.GetTime()
        end,
        createFlow= function()
            local flow = CleanFlow:new({}, cleanType.oneKeyRenew)
            flow.name  = "OneKeyRenew"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MultiValveAutoClean",
        text= "多联阀自动清洗",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.multiValveAutoClean.GetTime()
        end,
        createFlow= function()
            local flow = CleanFlow:new({}, cleanType.multiValveAutoClean)
            flow.name  = "MultiValveAutoClean"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="MeasureQualityHandle",
        text= "测质控样",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.measureQualityHandle.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> MeasureFlow:QualityHandle")
            local flow = MeasureFlow:new({}, MeasureType.QualityHandle)
            flow.name  = "MeasureQualityHandle"
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="Range1CurveCalibrate",
        text= "量程一因子",
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
        getRunTime = function()
            return setting.runStatus.onlyCalibrateStandard.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> CalibrateFlow:Range1CurveCalibrate")
            local flow = CalibrateFlow:new({}, CalibrateType.onlyCalibrateStandard)
            flow.name  = "Range1CurveCalibrate"
            flow.curveCalibrateRange = 1
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="Range2CurveCalibrate",
        text= "量程二因子",
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
        getRunTime = function()
            return setting.runStatus.onlyCalibrateStandard.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> CalibrateFlow:Range2CurveCalibrate")
            local flow = CalibrateFlow:new({}, CalibrateType.onlyCalibrateStandard)
            flow.name  = "Range2CurveCalibrate"
            flow.curveCalibrateRange = 2
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="Range3CurveCalibrate",
        text= "量程三因子",
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
        getRunTime = function()
            return setting.runStatus.onlyCalibrateStandard.GetTime()
        end,
        createFlow= function()
            log:debug("Maintain createFlow ==> CalibrateFlow:Range3CurveCalibrate")
            local flow = CalibrateFlow:new({}, CalibrateType.onlyCalibrateStandard)
            flow.name  = "Range3CurveCalibrate"
            flow.curveCalibrateRange = 3
            flow.isUseStart = true
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="SuckHalogenBottleWater",
        text= "排卤素液",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
        getRunTime = function()
            return setting.runStatus.suckHalogenBottleWater.GetTime()
        end,
        createFlow= function()
            local flow = CleanFlow:new({}, cleanType.suckHalogenBottleWater)
            flow.name  = "SuckHalogenBottleWater"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="CatalystActive",
        text= "催化剂活化",
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
        getRunTime = function()
            return setting.runStatus.catalystActive.GetTime()
        end,
        createFlow= function()
            local flow = CleanFlow:new({}, cleanType.catalystActive)
            flow.name  = "CatalystActive"
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="SliderForwardCalibrate",
        text= "滑块前进校准",
        writePrivilege=  RoleType.Super,
        readPrivilege = RoleType.Super,
        getRunTime = function()
            return setting.runStatus.sliderForwardCalibrate.GetTime()
        end,
        createFlow= function()
            local flow = ADAdjustFlow:new({}, setting.runAction.sliderForwardCalibrate)
            flow.name  = "SliderForwardCalibrate"
            flow.action = setting.runAction.sliderForwardCalibrate
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="SliderBackWardCalibrate",
        text= "滑块后退校准",
        writePrivilege=  RoleType.Super,
        readPrivilege = RoleType.Super,
        getRunTime = function()
            return setting.runStatus.sliderBackWardCalibrate.GetTime()
        end,
        createFlow= function()
            local flow = ADAdjustFlow:new({}, setting.runAction.sliderBackWardCalibrate)
            flow.name  = "SliderBackWardCalibrate"
            flow.action = setting.runAction.sliderBackWardCalibrate
            FlowList.AddFlow(flow)
        end,
    },
    {
        name ="AirReplacement",
        text= "气体置换",
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
        getRunTime = function()
            return setting.runStatus.airReplacement.GetTime()
        end,
        createFlow= function()
            local flow = CleanFlow:new({}, cleanType.airReplacement)
            flow.name  = "AirReplacement"
            FlowList.AddFlow(flow)
        end,
    },
    checkOEM = function()
        return config.system.OEM
    end,

}
return setting.ui.operation.maintain
