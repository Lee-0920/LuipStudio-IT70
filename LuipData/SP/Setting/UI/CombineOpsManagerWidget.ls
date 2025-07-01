setting.ui.operation.combineOperator =
{
    name ="combineOperator",
    text= "组合操作",
    rowCount = 9,
    superRow = 1,
    administratorRow = 8,
    writePrivilege=  RoleType.Maintain,
    readPrivilege = RoleType.Maintain,
    -- row = 1
    {
        name = "SuckBlankToDigestionRoom",
        text= "吸零点校准液至逐出室",
        data = 2,
        mode = 1,
        --disableWrite = true,
        createFlow= function(mode, volume)
            local flow = CombineOperateFlow:new({},setting.liquidType.blank, setting.liquidType.digestionRoom, mode,
                    volume, volume + setting.liquid.digestionRoomPipeVolume, setting.runAction.suckBlankToDigestionRoom)
            flow.name = setting.ui.operation.combineOperator[1].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 2
    {
        name = "SuckDigestionRoomToWaste",
        text= "排逐出液至分析废液",
        data = 2,
        mode = 1,
        --disableWrite = true,
        createFlow= function(mode, volume)
            local flow = CombineOperateFlow:new({},setting.liquidType.digestionRoom, setting.liquidType.waste, mode,
                    volume, volume + setting.liquid.wastePipeVolume, setting.runAction.suckDigestionRoomToWaste)
            flow.name = setting.ui.operation.combineOperator[2].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 3
    {
        name = "SuckDigestionRoomToWasteWater",
        text= "排逐出液至清洗废水",
        data = 2,
        mode = 1,
        --disableWrite = true,
        createFlow= function(mode, volume)
            local flow = CombineOperateFlow:new({},setting.liquidType.digestionRoom, setting.liquidType.wasteWater, mode,
                    volume, volume + setting.liquid.wasteWaterPipeVolume, setting.runAction.suckDigestionRoomToWasteWater)
            flow.name = setting.ui.operation.combineOperator[3].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    -- row = 4
    {
        name = "GasSealCheck",
        text= "气密性检查",
        data = 60,
        mode = 0,
        disableWrite = true,
        createFlow= function(mode, volume)
            local flow = CombineOperateFlow:new({}, setting.liquidType.gas, setting.liquidType.none, mode,volume, 0, setting.runAction.gasSealCheck)
            flow.name = setting.ui.operation.combineOperator[4].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    -- row = 5
    {
        name = "FillHalogenBottleWater",
        text= "填充卤素液",
        data = 8,
        mode = 5,
        disableWrite = true,
        createFlow= function(mode, volume)
            local flow = CombineOperateFlow:new({}, setting.liquidType.blank, setting.liquidType.halogenBottleWater, mode, volume, volume, setting.runAction.fillHalogenBottleWater)
            flow.name = setting.ui.operation.combineOperator[5].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
        isRemind = true,
        remindText = "请再次确认卤素瓶液位，防止液体溢出导致仪器损坏",
    },
    -- row = 6
    {
        name = "FillHalogenBottleWater",
        text= "排卤素液",
        data = 2,
        mode = 5,
        createFlow= function(mode, volume)
            local flow = CombineOperateFlow:new({}, setting.liquidType.halogenBottleWater, setting.liquidType.none, mode, volume, volume, setting.runAction.drainHalogenBottleWater)
            flow.name = setting.ui.operation.combineOperator[6].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    -- row = 7
    {
        name = "SuckRefrigeratorWater",
        text= "排冷凝液",
        data = 2,
        mode = 5,
        createFlow= function(mode, volume)
            local flow = CombineOperateFlow:new({}, setting.liquidType.coolerWater, setting.liquidType.none, mode, volume, volume, setting.runAction.suckRefrigeratorWater)
            flow.name = setting.ui.operation.combineOperator[7].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Super,
        readPrivilege = RoleType.Super,
    },
    -- row = 8
    {
        name = "SyringUpdate",
        text= "注射器更新",
        data = 1,
        mode = 5,
        createFlow= function(mode, volume)
            local flow = CombineOperateFlow:new({}, setting.liquidType.syringeBlank, setting.liquidType.none, mode, volume, volume, setting.runAction.syringUpdate)
            flow.name = setting.ui.operation.combineOperator[8].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
    -- row = 9
    {
        name = "SyringUpdate",
        text= "注射器单步测试",
        data = 0.035,
        mode = 5,
        createFlow= function(mode, volume)
            local flow = CombineOperateFlow:new({}, setting.liquidType.syringeBlank, setting.liquidType.waste, mode, volume, volume, setting.runAction.syringTest)
            flow.name = setting.ui.operation.combineOperator[9].name
            FlowList.AddFlow(flow)
        end,
        writePrivilege=  RoleType.Administrator,
        readPrivilege = RoleType.Administrator,
    },
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
            local operateVol = 0
            if vol > 18 then
                return string.format("%.2f", 3*maxPoint)
            elseif vol < minPoint then
                return string.format("%.2f", minPoint)
            else
                local volList = {}

                for i = 1, pointNum do
                    volList[i] = config.hardwareConfig.meterPoint.point[i].setVolume
                end

                if volList[1] - vol >= -PRECISE then -- 输入体积小于或等于低定量点
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
                else -- 输入体积大于或等于高定量点

                    local isMatch = false

                    for i = 1, pointNum do
                        local MP = volList[i]
                        local fcount = vol / MP
                        local count = math.floor(fcount + PRECISE)
                        local residue = vol - count * MP

                        if (-PRECISE <= residue) and (residue <= PRECISE) then
                            operateVol = vol
                            isMatch = true
                            break
                        end
                    end

                    if isMatch == false then
                        operateVol = maxPoint
                    end

                end
                return string.format("%.2f", operateVol)
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

        elseif mode == 3 then
            if type(value) == "string" then
                local patterm = "^%d?%d?%d?%d$"
                if string.find(value, patterm) then
                    if vol >= 3 and vol <= 5 then
                        return tostring(vol)
                    end
                end
            end
            return tostring(4)
        elseif mode == 4 then
            if type(value) == "string" then
                local patterm = "^%d?%d?%d?%d$"
                if string.find(value, patterm) then
                    if vol >= 1 and vol <= setting.liquid.syringeUpdateUpperLimit then
                        return tostring(vol)
                    end
                end
            end
            return tostring(1)
        elseif mode == 5 then
            if vol <= 24 and vol > 0 then
                return tostring(vol)
            else
                return tostring(6)
            end

        else  --泵计步 type == 0
            if vol > 200 then
                return string.format("%.2f", maxPoint)
            elseif vol < 0 or vol - PRECISE < 0 then
                return string.format("%.2f", 0)
            else
                return string.format("%.2f", tonumber(value))
            end
        end
    end,
}
return setting.ui.operation.combineOperator