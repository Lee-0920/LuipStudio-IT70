setting.ui.operation.liquidOperator =
{
    name ="liquidOperator",
    text= "管道操作",
    rowCount = 16,
    superRow = 0,
    administratorRow = 0,
    writePrivilege=  RoleType.Maintain,
    readPrivilege = RoleType.Maintain,
    -- row = 1
    {
        name = "SuckFromSample",
        text= "填充水样",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.sample, setting.liquidType.none, mode, volume, 0, setting.runAction.suckFromSample)
            flow.name = setting.ui.operation.liquidOperator[1].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 2
    {
        name = "SuckFromBlank",
        text= "填充零点校准液",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.blank, setting.liquidType.none, mode, volume, 0,setting.runAction.suckFromBlank)
            flow.name = setting.ui.operation.liquidOperator[2].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 3
    {
        name = "SuckFromStandard",
        text= "填充量程校准液",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.standard, setting.liquidType.none, mode, volume, 0,setting.runAction.suckFromStandard)
            flow.name = setting.ui.operation.liquidOperator[3].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 4
    {
        name = "SuckFromZeroCheck",
        text= "填充零点核查液",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.zeroCheck, setting.liquidType.none, mode, volume, 0,setting.runAction.suckFromZeroCheck)
            flow.name = setting.ui.operation.liquidOperator[4].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 5
    {
        name = "SuckFromRangeCheck",
        text= "填充标样(跨度)核查液",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.rangeCheck, setting.liquidType.none, mode, volume, 0,setting.runAction.suckFromRangeCheck)
            flow.name = setting.ui.operation.liquidOperator[5].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 6
    {
        name = "SuckFromReagent1",
        text= "填充试剂一",
        data = 1,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.reagent1, setting.liquidType.none, mode, volume, 0,setting.runAction.suckFromReagent1)
            flow.name = setting.ui.operation.liquidOperator[6].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 7
    --{
    --    name = "SuckFromReagent2",
    --    text= "填充试剂二",
    --    data = 2,
    --    createFlow= function(mode, volume)
    --        local flow = LiquidOperateFlow:new({}, setting.liquidType.reagent2, setting.liquidType.none, mode, volume, 0,setting.runAction.suckFromReagent2)
    --        flow.name = setting.ui.operation.liquidOperator[5].name
    --        FlowList.AddFlow(flow)
    --    end,
    --    writePrivilege=  RoleType.Maintain,
    --    readPrivilege = RoleType.Maintain,
    --},
    -- row = 7
    {
        name = "SuckFromDigestionRoom",
        text= "吸逐出室溶液",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.digestionRoom, setting.liquidType.none, mode, volume, 0,setting.runAction.suckFromDigestionRoom)
            flow.name = setting.ui.operation.liquidOperator[7].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 8
    {
        name = "DrainToWaste",
        text= "排至分析废液",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.none, setting.liquidType.waste, mode,0, volume, setting.runAction.drainToWaste)
            flow.name = setting.ui.operation.liquidOperator[8].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
   -- row = 9
    {
        name = "DrainToWasteWater",
        text= "排至清洗废水",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.none, setting.liquidType.wasteWater, mode,0, volume, setting.runAction.drainToWasteWater)
            flow.name = setting.ui.operation.liquidOperator[9].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 10
    {
        name = "DrainToDigestionRoom",
        text= "排至逐出室",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({},setting.liquidType.none, setting.liquidType.digestionRoom, mode,
                                            0, volume + setting.liquid.digestionRoomPipeVolume, setting.runAction.drainToDigestionRoom)
            flow.name = setting.ui.operation.liquidOperator[10].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 11
    {
        name = "DrainToSample",
        text= "排至水样管",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.none, setting.liquidType.sample, mode, 0, volume, setting.runAction.drainToSample)
            flow.name = setting.ui.operation.liquidOperator[11].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 12
    {
        name = "DrainToBlank",
        text= "排至零点校准液管",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.none, setting.liquidType.blank, mode,0, volume, setting.runAction.drainToBlank)
            flow.name = setting.ui.operation.liquidOperator[12].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 13
    {
        name = "DrainToStandard",
        text= "排至量程校准液管",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.none, setting.liquidType.standard, mode,0, volume, setting.runAction.drainToStandard)
            flow.name = setting.ui.operation.liquidOperator[13].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 14
    {
        name = "DrainToZeroCheck",
        text= "排至零点核查液管",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.none, setting.liquidType.zeroCheck, mode,0, volume, setting.runAction.drainToZeroCheck)
            flow.name = setting.ui.operation.liquidOperator[14].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 15
    {
        name = "DrainToRangeCheck",
        text= "排至标样(跨度)核查液管",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.none, setting.liquidType.rangeCheck, mode,0, volume, setting.runAction.drainToRangeCheck)
            flow.name = setting.ui.operation.liquidOperator[15].name
            FlowList.AddFlow(flow)
        end,
        --targetPrivilege = Target.EXTEND,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 16
    {
        name = "DrainToReagent1",
        text= "排至试剂一管",
        data = 0.5,
        createFlow= function(mode, volume)
            local flow = LiquidOperateFlow:new({}, setting.liquidType.none, setting.liquidType.reagent1, mode,0, volume, setting.runAction.drainToReagent1)
            flow.name = setting.ui.operation.liquidOperator[16].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 14
    --{
    --    name = "DrainToReagent2",
    --    text= "排至试剂二管",
    --    data = 2,
    --    createFlow= function(mode, volume)
    --        local flow = LiquidOperateFlow:new({}, setting.liquidType.none, setting.liquidType.reagent2, mode,0, volume, setting.runAction.drainToReagent2)
    --        flow.name = setting.ui.operation.liquidOperator[14].name
    --        FlowList.AddFlow(flow)
    --    end,
    --    writePrivilege=  RoleType.Maintain,
    --    readPrivilege = RoleType.Maintain,
    --},

    checkvalue = function(mode, value)
        local pointNum = config.hardwareConfig.meterPoint.num
        local maxPoint = config.hardwareConfig.meterPoint.point[pointNum].setVolume
        local minPoint = config.hardwareConfig.meterPoint.point[1].setVolume
        local PRECISE = 0.000001

        local vol = tonumber(value)

        if not vol then
            return string.format("%.2f", maxPoint)
        end

        if mode == 1 then

            if vol > 2*maxPoint then
                return string.format("%.2f", 2*maxPoint)
            elseif vol < minPoint then
                return string.format("%.2f", minPoint)
            else
                return value
            end

        elseif mode == 2 then

            local operateVol = 0
            local volList = {}

            for i = 1, pointNum do
                volList[i] = config.hardwareConfig.meterPoint.point[i].setVolume
            end

            if vol <= PRECISE then -- 输入体积为0

                operateVol = minPoint

            elseif volList[1] - vol >= -PRECISE then -- 输入体积小于或等于低定量点

                operateVol = minPoint

            elseif volList[1] - vol < -PRECISE  and
                    volList[pointNum] - vol > PRECISE then -- 输入体积大于低定量点，小于高定量点

                pointNum = pointNum + 1
                volList[pointNum] = vol

                local temp = 0
                for i = 1, pointNum - 1 do
                    for j = pointNum, i + 1, -1 do
                        if volList[j] < volList[j - 1] then
                            temp = volList[j - 1]
                            volList[j - 1] = volList[j]
                            volList[j] = temp
                        end
                    end
                end

                local index = 1
                for i = 1, pointNum do
                    if (-PRECISE <= volList[i] - vol) and
                            (volList[i] - vol <= PRECISE) then
                        break;
                    end
                    index = index + 1
                end

                local pPoint = volList[index - 1]
                local nPoint = volList[index + 1]
                local pD = vol - pPoint

                if pD < (nPoint - pPoint) / 2 then
                    operateVol = pPoint
                else
                    operateVol = nPoint
                end
            else  --输入体积大于等于高定量点
                operateVol = maxPoint
            end
            return string.format("%.2f", operateVol)

        else  --泵计步 type == 0
            if vol > 100 then
                return string.format("%.2f", maxPoint)
            elseif vol < 0 or vol - PRECISE < 0 then
                return string.format("%.2f", 0)
            else
                return string.format("%.2f", tonumber(value))
            end
        end
    end,
}
return setting.ui.operation.liquidOperator
