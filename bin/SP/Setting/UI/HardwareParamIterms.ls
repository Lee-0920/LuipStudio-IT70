setting.ui.profile.hardwareParamIterms =
{
    name = "hardwareParamIterms",
    text = "硬件校准",
    writePrivilege=  RoleType.Administrator,
    readPrivilege = RoleType.Administrator,
    rowCount = 33,
    superRow = 0,
    administratorRow = 33,
    index = 10,
    {
        name = "pumpFactor",
        text = "泵校准",
        pumpFactor =
        {
            0,
            0,
        },
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local ret = {}
                    ret[1]  = dc:GetIPeristalticPump():GetPumpFactor(0)
                    ret[2]  = dc:GetIPeristalticPump():GetPumpFactor(2)
                    return ret
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    for k in pairs(setting.ui.profile.hardwareParamIterms[1].pumpFactor) do
                        setting.ui.profile.hardwareParamIterms[1].pumpFactor[k] = 0
                    end
                    --setting.ui.profile.hardwareParamIterms[1].pumpFactor[1] = 0
                    --setting.ui.profile.hardwareParamIterms[1].pumpFactor[2] = 0
                else
                    setting.ui.profile.hardwareParamIterms[1].pumpFactor = nil
                    setting.ui.profile.hardwareParamIterms[1].pumpFactor = result
                end
            else
                for k in pairs(setting.ui.profile.hardwareParamIterms[1].pumpFactor) do
                    setting.ui.profile.hardwareParamIterms[1].pumpFactor[k] = 0
                end
                --setting.ui.profile.hardwareParamIterms[1].pumpFactor[1] = 0
                --setting.ui.profile.hardwareParamIterms[1].pumpFactor[2] = 0
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    dc:GetIPeristalticPump():SetPumpFactor(0, setting.ui.profile.hardwareParamIterms[1].pumpFactor[1])
                    dc:GetIPeristalticPump():SetPumpFactor(2, setting.ui.profile.hardwareParamIterms[1].pumpFactor[2])
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置泵校准失败\n"
                else
                    config.hardwareConfig.backupParam.pumpMeter = string.format("%.8f", setting.ui.profile.hardwareParamIterms[1].pumpFactor[1])
                    config.hardwareConfig.backupParam.pumpSyring = string.format("%.8f", setting.ui.profile.hardwareParamIterms[1].pumpFactor[2])
                    return true, ""
                end
            else
                return false, "驱动板连接断开,\n设置泵校准失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local pumpfactor = dc:GetIPeristalticPump():GetPumpFactor(0)
                    if math.abs(pumpfactor - config.hardwareConfig.backupParam.pumpMeter) > PRECISE then
                        log:debug("参数同步-[定量泵系数(ml/步)] " .. config.hardwareConfig.backupParam.pumpMeter)
                        dc:GetIPeristalticPump():SetPumpFactor(0, config.hardwareConfig.backupParam.pumpMeter)
                        App.Sleep(200)

                        pumpfactor = dc:GetIPeristalticPump():GetPumpFactor(0)
                        if math.abs(pumpfactor - config.hardwareConfig.backupParam.pumpMeter) > PRECISE then
                            log:warn("同步定量泵系数失败。")
                        else
                            log:warn("同步定量泵系数成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步定量泵系数失败。")
                end

                App.Sleep(200)
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local pumpfactor = dc:GetIPeristalticPump():GetPumpFactor(2)
                    if math.abs(pumpfactor - config.hardwareConfig.backupParam.pumpSyring) > PRECISE then
                        log:debug("[参数同步-注射泵系数(ml/步)] " .. config.hardwareConfig.backupParam.pumpSyring)
                        dc:GetIPeristalticPump():SetPumpFactor(2, config.hardwareConfig.backupParam.pumpMeter)
                        App.Sleep(200)

                        pumpfactor = dc:GetIPeristalticPump():GetPumpFactor(2)
                        if math.abs(pumpfactor - config.hardwareConfig.backupParam.pumpSyring) > PRECISE then
                            log:warn("同步注射泵系数失败。")
                        else
                            log:warn("同步注射泵系数成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步注射泵系数数失败。")
                end
            end
        end,
        {
            name = "meterPump",
            text = "定量泵",
            refData = "pumpFactor[1]",
            unit = "ml/步",
            get = function()
                return setting.ui.profile.hardwareParamIterms[1].pumpFactor[1]
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.8f",setting.ui.profile.hardwareParamIterms[1][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[1].pumpFactor[1] = value
                config.hardwareConfig.backupParam.pumpMeter = string.format("%.8f", setting.ui.profile.hardwareParamIterms[1].pumpFactor[1])
                ConfigLists.SaveHardwareConfig()
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Administrator,
        },
        {
            name = "SyringePump",
            text = "注射泵",
            refData = "pumpFactor[2]",
            unit = "ml/步",
            get = function()
                return setting.ui.profile.hardwareParamIterms[1].pumpFactor[2]
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.8f",setting.ui.profile.hardwareParamIterms[1][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[1].pumpFactor[2] = value
                config.hardwareConfig.backupParam.pumpSyring = string.format("%.8f", setting.ui.profile.hardwareParamIterms[1].pumpFactor[2])
                ConfigLists.SaveHardwareConfig()
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "tempCalibrate",
        text = "制冷温度校准",
        tempCalibrate = TempCalibrateFactor.new(),
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    --return dc:GetITemperatureControl():GetCalibrateFactor()
                    return dc:GetITemperatureControl():GetCalibrateFactorForTOC(1)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[2].tempCalibrate:SetNegativeInput(0)
                    setting.ui.profile.hardwareParamIterms[2].tempCalibrate:SetReferenceVoltage(0)
                    setting.ui.profile.hardwareParamIterms[2].tempCalibrate:SetCalibrationVoltage(0)
                else
                    setting.ui.profile.hardwareParamIterms[2].tempCalibrate = nil
                    setting.ui.profile.hardwareParamIterms[2].tempCalibrate = result
                end
            else
                setting.ui.profile.hardwareParamIterms[2].tempCalibrate:SetNegativeInput(0)
                setting.ui.profile.hardwareParamIterms[2].tempCalibrate:SetReferenceVoltage(0)
                setting.ui.profile.hardwareParamIterms[2].tempCalibrate:SetCalibrationVoltage(0)
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():SetCalibrateFactorForTOC(1, setting.ui.profile.hardwareParamIterms[2].tempCalibrate)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置温度校准系数失败\n"
                else
                    config.hardwareConfig.backupParam.CoolerTempCalibrate.negativeInput = string.format("%.4f", setting.ui.profile.hardwareParamIterms[2].tempCalibrate:GetNegativeInput())
                    config.hardwareConfig.backupParam.CoolerTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[2].tempCalibrate:GetReferenceVoltage())
                    config.hardwareConfig.backupParam.CoolerTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[2].tempCalibrate:GetCalibrationVoltage())
                    return true, ""
                end
            else
                return false,"驱动板连接断开,\n设置温度校准系数失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(1)
                    if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.CoolerTempCalibrate.negativeInput) > PRECISE
                            or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.CoolerTempCalibrate.referenceVoltage) > PRECISE
                            or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.CoolerTempCalibrate.calibrationVoltage) > PRECISE then

                        local tempCalibrate = TempCalibrateFactor.new()
                        tempCalibrate:SetNegativeInput(config.hardwareConfig.backupParam.CoolerTempCalibrate.negativeInput)
                        tempCalibrate:SetReferenceVoltage(config.hardwareConfig.backupParam.CoolerTempCalibrate.referenceVoltage)
                        tempCalibrate:SetCalibrationVoltage(config.hardwareConfig.backupParam.CoolerTempCalibrate.calibrationVoltage)

                        log:debug("参数同步-[制冷校准系数(V)-负输入分压-参考电压-校准电压] " ..  config.hardwareConfig.backupParam.CoolerTempCalibrate.negativeInput
                                .. ", "  .. config.hardwareConfig.backupParam.CoolerTempCalibrate.referenceVoltage
                                .. ", "  .. config.hardwareConfig.backupParam.CoolerTempCalibrate.calibrationVoltage)
                        dc:GetITemperatureControl():SetCalibrateFactorForTOC(1, tempCalibrate)
                        App.Sleep(200)

                        getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(1)
                        if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.CoolerTempCalibrate.negativeInput) > PRECISE
                                or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.CoolerTempCalibrate.referenceVoltage) > PRECISE
                                or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.CoolerTempCalibrate.calibrationVoltage) > PRECISE then
                            log:warn("同步制冷温度系数失败。")
                        else
                            log:warn("同步制冷温度系数成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步制冷温度系数失败。")
                end
            end
        end,
        {
            name = "negativeInput",
            text = "负输入分压",
            refData = "tempCalibrate.negativeInput",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[2].tempCalibrate:GetNegativeInput()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[2][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[2].tempCalibrate:SetNegativeInput(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "referenceVoltage",
            text = "参考电压",
            refData = "tempCalibrate.referenceVoltage",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[2].tempCalibrate:GetReferenceVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[2][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[2].tempCalibrate:SetReferenceVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "calibrationVoltage",
            text = "校准电压",
            refData = "tempCalibrate.calibrationVoltage",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[2].tempCalibrate:GetCalibrationVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[2][3].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[2].tempCalibrate:SetCalibrationVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        name = "NDIRTempCalibrate",
        text = "测量温度校准",
        tempCalibrate = TempCalibrateFactor.new(),
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():GetCalibrateFactorForTOC(2)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[3].tempCalibrate:SetNegativeInput(0)
                    setting.ui.profile.hardwareParamIterms[3].tempCalibrate:SetReferenceVoltage(0)
                    setting.ui.profile.hardwareParamIterms[3].tempCalibrate:SetCalibrationVoltage(0)
                else
                    setting.ui.profile.hardwareParamIterms[3].tempCalibrate = nil
                    setting.ui.profile.hardwareParamIterms[3].tempCalibrate = result
                end
            else
                setting.ui.profile.hardwareParamIterms[3].tempCalibrate:SetNegativeInput(0)
                setting.ui.profile.hardwareParamIterms[3].tempCalibrate:SetReferenceVoltage(0)
                setting.ui.profile.hardwareParamIterms[3].tempCalibrate:SetCalibrationVoltage(0)
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():SetCalibrateFactorForTOC(2, setting.ui.profile.hardwareParamIterms[3].tempCalibrate)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置温度校准系数失败\n"
                else
                    config.hardwareConfig.backupParam.NDIRTempCalibrate.negativeInput = string.format("%.4f", setting.ui.profile.hardwareParamIterms[3].tempCalibrate:GetNegativeInput())
                    config.hardwareConfig.backupParam.NDIRTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[3].tempCalibrate:GetReferenceVoltage())
                    config.hardwareConfig.backupParam.NDIRTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[3].tempCalibrate:GetCalibrationVoltage())
                    return true, ""
                end
            else
                return false,"驱动板连接断开,\n设置温度校准系数失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(2)
                    if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.NDIRTempCalibrate.negativeInput) > PRECISE
                            or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.NDIRTempCalibrate.referenceVoltage) > PRECISE
                            or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.NDIRTempCalibrate.calibrationVoltage) > PRECISE then

                        local tempCalibrate = TempCalibrateFactor.new()
                        tempCalibrate:SetNegativeInput(config.hardwareConfig.backupParam.NDIRTempCalibrate.negativeInput)
                        tempCalibrate:SetReferenceVoltage(config.hardwareConfig.backupParam.NDIRTempCalibrate.referenceVoltage)
                        tempCalibrate:SetCalibrationVoltage(config.hardwareConfig.backupParam.NDIRTempCalibrate.calibrationVoltage)

                        log:debug("参数同步-[测量校准系数(V)-负输入分压-参考电压-校准电压] " ..  config.hardwareConfig.backupParam.NDIRTempCalibrate.negativeInput
                                .. ", "  .. config.hardwareConfig.backupParam.NDIRTempCalibrate.referenceVoltage
                                .. ", "  .. config.hardwareConfig.backupParam.NDIRTempCalibrate.calibrationVoltage)

                        dc:GetITemperatureControl():SetCalibrateFactorForTOC(2, tempCalibrate)
                        App.Sleep(200)

                        getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(2)
                        if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.NDIRTempCalibrate.negativeInput) > PRECISE
                                or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.NDIRTempCalibrate.referenceVoltage) > PRECISE
                                or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.NDIRTempCalibrate.calibrationVoltage) > PRECISE then
                            log:warn("同步测量温度系数失败。")
                        else
                            log:warn("同步测量温度系数成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步测量温度系数失败。")
                end
            end
        end,
        {
            name = "negativeInput",
            text = "负输入分压",
            refData = "NDIRTempCalibrate.negativeInput",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[3].tempCalibrate:GetNegativeInput()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[3][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[3].tempCalibrate:SetNegativeInput(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "referenceVoltage",
            text = "参考电压",
            refData = "NDIRTempCalibrate.referenceVoltage",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[3].tempCalibrate:GetReferenceVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[3][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[3].tempCalibrate:SetReferenceVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "calibrationVoltage",
            text = "校准电压",
            refData = "NDIRTempCalibrate.calibrationVoltage",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[3].tempCalibrate:GetCalibrationVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[3][3].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[3].tempCalibrate:SetCalibrationVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        name = "stoveTempCalibrate",
        text = "电炉温度校准",
        tempCalibrate = TempCalibrateFactor.new(),
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():GetCalibrateFactorForTOC(0)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[4].tempCalibrate:SetNegativeInput(0)
                    setting.ui.profile.hardwareParamIterms[4].tempCalibrate:SetReferenceVoltage(0)
                    setting.ui.profile.hardwareParamIterms[4].tempCalibrate:SetCalibrationVoltage(0)
                else
                    setting.ui.profile.hardwareParamIterms[4].tempCalibrate = nil
                    setting.ui.profile.hardwareParamIterms[4].tempCalibrate = result
                end
            else
                setting.ui.profile.hardwareParamIterms[4].tempCalibrate:SetNegativeInput(0)
                setting.ui.profile.hardwareParamIterms[4].tempCalibrate:SetReferenceVoltage(0)
                setting.ui.profile.hardwareParamIterms[4].tempCalibrate:SetCalibrationVoltage(0)
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():SetCalibrateFactorForTOC(0, setting.ui.profile.hardwareParamIterms[4].tempCalibrate)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置温度校准系数失败\n"
                else
                    config.hardwareConfig.backupParam.stoveTempCalibrate.negativeInput = string.format("%.4f", setting.ui.profile.hardwareParamIterms[4].tempCalibrate:GetNegativeInput())
                    config.hardwareConfig.backupParam.stoveTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[4].tempCalibrate:GetReferenceVoltage())
                    config.hardwareConfig.backupParam.stoveTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[4].tempCalibrate:GetCalibrationVoltage())
                    return true, ""
                end
            else
                return false,"驱动板连接断开,\n设置温度校准系数失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(0)
                    if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.stoveTempCalibrate.negativeInput) > PRECISE
                            or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.stoveTempCalibrate.referenceVoltage) > PRECISE
                            or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.stoveTempCalibrate.calibrationVoltage) > PRECISE then

                        local tempCalibrate = TempCalibrateFactor.new()
                        tempCalibrate:SetNegativeInput(config.hardwareConfig.backupParam.stoveTempCalibrate.negativeInput)
                        tempCalibrate:SetReferenceVoltage(config.hardwareConfig.backupParam.stoveTempCalibrate.referenceVoltage)
                        tempCalibrate:SetCalibrationVoltage(config.hardwareConfig.backupParam.stoveTempCalibrate.calibrationVoltage)

                        log:debug("参数同步-[电炉校准系数(V)-校准系数-校准AD-校准温度] " ..  config.hardwareConfig.backupParam.stoveTempCalibrate.negativeInput
                                .. ", "  .. config.hardwareConfig.backupParam.stoveTempCalibrate.referenceVoltage
                                .. ", "  .. config.hardwareConfig.backupParam.stoveTempCalibrate.calibrationVoltage)

                        dc:GetITemperatureControl():SetCalibrateFactorForTOC(0, tempCalibrate)
                        App.Sleep(200)

                        getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(0)
                        if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.stoveTempCalibrate.negativeInput) > PRECISE
                                or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.stoveTempCalibrate.referenceVoltage) > PRECISE
                                or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.stoveTempCalibrate.calibrationVoltage) > PRECISE then
                            log:warn("同步电炉温度系数失败。")
                        else
                            log:warn("同步电炉温度系数成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步电炉温度系数失败。")
                end
            end
        end,
        {
            name = "stoveTempCalibrate",
            text = "校准系数",
            refData = "stoveTempCalibrate.calibrationFactor",
            get = function()
                return setting.ui.profile.hardwareParamIterms[4].tempCalibrate:GetNegativeInput()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[4][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[4].tempCalibrate:SetNegativeInput(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "calibrationAD",
            text = "校准AD",
            refData = "stoveTempCalibrate.calibrationAD",
            get = function()
                return setting.ui.profile.hardwareParamIterms[4].tempCalibrate:GetReferenceVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[4][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[4].tempCalibrate:SetReferenceVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "calibrationTemp",
            text = "校准温度",
            refData = "stoveTempCalibrate.calibrationTemp",
            unit = "℃",
            get = function()
                return setting.ui.profile.hardwareParamIterms[4].tempCalibrate:GetCalibrationVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[4][3].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[4].tempCalibrate:SetCalibrationVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        name = "fanUpTempCalibrate",
        text = "上机箱温度校准",
        tempCalibrate = TempCalibrateFactor.new(),
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():GetCalibrateFactorForTOC(3)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[5].tempCalibrate:SetNegativeInput(0)
                    setting.ui.profile.hardwareParamIterms[5].tempCalibrate:SetReferenceVoltage(0)
                    setting.ui.profile.hardwareParamIterms[5].tempCalibrate:SetCalibrationVoltage(0)
                else
                    setting.ui.profile.hardwareParamIterms[5].tempCalibrate = nil
                    setting.ui.profile.hardwareParamIterms[5].tempCalibrate = result
                end
            else
                setting.ui.profile.hardwareParamIterms[5].tempCalibrate:SetNegativeInput(0)
                setting.ui.profile.hardwareParamIterms[5].tempCalibrate:SetReferenceVoltage(0)
                setting.ui.profile.hardwareParamIterms[5].tempCalibrate:SetCalibrationVoltage(0)
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():SetCalibrateFactorForTOC(3, setting.ui.profile.hardwareParamIterms[5].tempCalibrate)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置温度校准系数失败\n"
                else
                    config.hardwareConfig.backupParam.fanUpTempCalibrate.negativeInput = string.format("%.4f", setting.ui.profile.hardwareParamIterms[5].tempCalibrate:GetNegativeInput())
                    config.hardwareConfig.backupParam.fanUpTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[5].tempCalibrate:GetReferenceVoltage())
                    config.hardwareConfig.backupParam.fanUpTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[5].tempCalibrate:GetCalibrationVoltage())
                    return true, ""
                end
            else
                return false,"驱动板连接断开,\n设置温度校准系数失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(3)
                    if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.fanUpTempCalibrate.negativeInput) > PRECISE
                            or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.fanUpTempCalibrate.referenceVoltage) > PRECISE
                            or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.fanUpTempCalibrate.calibrationVoltage) > PRECISE then

                        local tempCalibrate = TempCalibrateFactor.new()
                        tempCalibrate:SetNegativeInput(config.hardwareConfig.backupParam.fanUpTempCalibrate.negativeInput)
                        tempCalibrate:SetReferenceVoltage(config.hardwareConfig.backupParam.fanUpTempCalibrate.referenceVoltage)
                        tempCalibrate:SetCalibrationVoltage(config.hardwareConfig.backupParam.fanUpTempCalibrate.calibrationVoltage)

                        log:debug("参数同步-[上机箱风扇校准系数(V)-负输入分压-参考电压-校准电压] " ..  config.hardwareConfig.backupParam.fanUpTempCalibrate.negativeInput
                                .. ", "  .. config.hardwareConfig.backupParam.fanUpTempCalibrate.referenceVoltage
                                .. ", "  .. config.hardwareConfig.backupParam.fanUpTempCalibrate.calibrationVoltage)

                        dc:GetITemperatureControl():SetCalibrateFactorForTOC(3, tempCalibrate)
                        App.Sleep(200)

                        getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(3)
                        if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.fanUpTempCalibrate.negativeInput) > PRECISE
                                or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.fanUpTempCalibrate.referenceVoltage) > PRECISE
                                or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.fanUpTempCalibrate.calibrationVoltage) > PRECISE then
                            log:warn("同步上机箱温度系数失败。")
                        else
                            log:warn("同步上机箱温度系数成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步上机箱温度系数失败。")
                end
            end
        end,
        {
            name = "negativeInput",
            text = "负输入分压",
            refData = "fanUpTempCalibrate.negativeInput",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[5].tempCalibrate:GetNegativeInput()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[5][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[5].tempCalibrate:SetNegativeInput(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "referenceVoltage",
            text = "参考电压",
            refData = "fanUpTempCalibrate.referenceVoltage",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[5].tempCalibrate:GetReferenceVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[5][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[5].tempCalibrate:SetReferenceVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "calibrationVoltage",
            text = "校准电压",
            refData = "fanUpTempCalibrate.calibrationVoltage",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[5].tempCalibrate:GetCalibrationVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[5][3].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[5].tempCalibrate:SetCalibrationVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        name = "fanDownTempCalibrate",
        text = "下机箱温度校准",
        tempCalibrate = TempCalibrateFactor.new(),
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():GetCalibrateFactorForTOC(4)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[6].tempCalibrate:SetNegativeInput(0)
                    setting.ui.profile.hardwareParamIterms[6].tempCalibrate:SetReferenceVoltage(0)
                    setting.ui.profile.hardwareParamIterms[6].tempCalibrate:SetCalibrationVoltage(0)
                else
                    setting.ui.profile.hardwareParamIterms[6].tempCalibrate = nil
                    setting.ui.profile.hardwareParamIterms[6].tempCalibrate = result
                end
            else
                setting.ui.profile.hardwareParamIterms[6].tempCalibrate:SetNegativeInput(0)
                setting.ui.profile.hardwareParamIterms[6].tempCalibrate:SetReferenceVoltage(0)
                setting.ui.profile.hardwareParamIterms[6].tempCalibrate:SetCalibrationVoltage(0)
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():SetCalibrateFactorForTOC(4, setting.ui.profile.hardwareParamIterms[6].tempCalibrate)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置温度校准系数失败\n"
                else
                    config.hardwareConfig.backupParam.fanDownTempCalibrate.negativeInput = string.format("%.4f", setting.ui.profile.hardwareParamIterms[6].tempCalibrate:GetNegativeInput())
                    config.hardwareConfig.backupParam.fanDownTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[6].tempCalibrate:GetReferenceVoltage())
                    config.hardwareConfig.backupParam.fanDownTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[6].tempCalibrate:GetCalibrationVoltage())
                    return true, ""
                end
            else
                return false,"驱动板连接断开,\n设置温度校准系数失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(4)
                    if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.fanDownTempCalibrate.negativeInput) > PRECISE
                            or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.fanDownTempCalibrate.referenceVoltage) > PRECISE
                            or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.fanDownTempCalibrate.calibrationVoltage) > PRECISE then

                        local tempCalibrate = TempCalibrateFactor.new()
                        tempCalibrate:SetNegativeInput(config.hardwareConfig.backupParam.fanDownTempCalibrate.negativeInput)
                        tempCalibrate:SetReferenceVoltage(config.hardwareConfig.backupParam.fanDownTempCalibrate.referenceVoltage)
                        tempCalibrate:SetCalibrationVoltage(config.hardwareConfig.backupParam.fanDownTempCalibrate.calibrationVoltage)

                        log:debug("参数同步-[下机箱校准系数(V)-负输入分压-参考电压-校准电压] " ..  config.hardwareConfig.backupParam.fanDownTempCalibrate.negativeInput
                                .. ", "  .. config.hardwareConfig.backupParam.fanDownTempCalibrate.referenceVoltage
                                .. ", "  .. config.hardwareConfig.backupParam.fanDownTempCalibrate.calibrationVoltage)

                        dc:GetITemperatureControl():SetCalibrateFactorForTOC(4, tempCalibrate)
                        App.Sleep(200)

                        getTempCalibrate = dc:GetITemperatureControl():GetCalibrateFactorForTOC(4)
                        if math.abs(getTempCalibrate:GetNegativeInput() - config.hardwareConfig.backupParam.fanDownTempCalibrate.negativeInput) > PRECISE
                                or math.abs(getTempCalibrate:GetReferenceVoltage() - config.hardwareConfig.backupParam.fanDownTempCalibrate.referenceVoltage) > PRECISE
                                or math.abs(getTempCalibrate:GetCalibrationVoltage() - config.hardwareConfig.backupParam.fanDownTempCalibrate.calibrationVoltage) > PRECISE then
                            log:warn("同步上机箱温度系数失败。")
                        else
                            log:warn("同步上机箱温度系数成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步上机箱温度系数失败。")
                end
            end
        end,
        {
            name = "negativeInput",
            text = "负输入分压",
            refData = "fanDownTempCalibrate.negativeInput",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[6].tempCalibrate:GetNegativeInput()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[6][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[6].tempCalibrate:SetNegativeInput(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "referenceVoltage",
            text = "参考电压",
            refData = "fanDownTempCalibrate.referenceVoltage",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[6].tempCalibrate:GetReferenceVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[6][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[6].tempCalibrate:SetReferenceVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "calibrationVoltage",
            text = "校准电压",
            refData = "fanDownTempCalibrate.calibrationVoltage",
            unit = "V",
            get = function()
                return setting.ui.profile.hardwareParamIterms[6].tempCalibrate:GetCalibrationVoltage()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.4f",setting.ui.profile.hardwareParamIterms[6][3].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[6].tempCalibrate:SetCalibrationVoltage(value)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        text = "定量校准",
        name = "meterPoints",
        meterPoints = MeterPoints.new(2),
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetIOpticalMeter():GetMeterPoints()
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)

                    local meterPoint = MeterPoint.new()
                    meterPoint:SetRealVolume(0)

                    local num = setting.ui.profile.hardwareParamIterms[7].meterPoints:GetNum()

                    for i = 1, num do
                        meterPoint:SetSetVolume(config.hardwareConfig.meterPoint.point[i].setVolume)
                        setting.ui.profile.hardwareParamIterms[7].meterPoints:SetPoint(i, meterPoint)
                    end
                else
                    setting.ui.profile.hardwareParamIterms[7].meterPoints = nil
                    setting.ui.profile.hardwareParamIterms[7].meterPoints = result
                end
            else
                local meterPoint = MeterPoint.new()
                meterPoint:SetRealVolume(0)

                local num = setting.ui.profile.hardwareParamIterms[7].meterPoints:GetNum()

                for i = 1, num do
                    meterPoint:SetSetVolume(config.hardwareConfig.meterPoint.point[i].setVolume)
                    setting.ui.profile.hardwareParamIterms[7].meterPoints:SetPoint(i, meterPoint)
                end
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetIOpticalMeter():SetMeterPoints(setting.ui.profile.hardwareParamIterms[7].meterPoints)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置定量点失败\n"
                else
                    return true, ""
                end
            else
                return false, "驱动板连接断开,\n设置定量点失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local temp = 0
                    local isInequality = false

                    local meterPoints = dc:GetIOpticalMeter():GetMeterPoints()
                    --判断上下位机定量点体系是否相同，相同的条件为定量点数目一样且定量点设置体积(参考值)一样。
                    if meterPoints:GetNum() ~= config.hardwareConfig.meterPoint.num then
                        isInequality = true
                    else
                        for i = 1 , config.hardwareConfig.meterPoint.num do
                            local meterPoint = meterPoints:GetPoint(i)
                            if math.abs(config.hardwareConfig.meterPoint.point[i].setVolume - meterPoint:GetSetVolume()) > PRECISE then
                                isInequality = true
                                break;
                            end
                        end
                    end

                    if isInequality then -- 不相同，使用上位机的定量点体系设置下位机
                        meterPoints:SetNum(config.hardwareConfig.meterPoint.num)
                        local meterPoint = MeterPoint.new()
                        for i = 1, config.hardwareConfig.meterPoint.num do
                            meterPoint:SetRealVolume(config.hardwareConfig.meterPoint.point[i].realVolume)
                            App.Sleep(200);
                            meterPoint:SetSetVolume(config.hardwareConfig.meterPoint.point[i].setVolume)
                            App.Sleep(200);
                            meterPoints:SetPoint(i, meterPoint)
                            App.Sleep(200);
                        end

                        dc:GetIOpticalMeter():SetMeterPoints(meterPoints)
                        App.Sleep(200);
                        getMeterPoints = dc:GetIOpticalMeter():GetMeterPoints()
                        if getMeterPoints == meterPoints then
                            log:warn("上下位机定量点同步成功。")
                        else
                            log:warn("上下位机定量点同步失败。")
                        end
                    else -- 相同，上位机使用下位机的真实值(校准值)
                        local meterPoint
                        for i = 1, config.hardwareConfig.meterPoint.num do
                            meterPoint = meterPoints:GetPoint(i)
                            config.hardwareConfig.meterPoint.point[i].realVolume = meterPoint:GetRealVolume()
                        end
                        ConfigLists.SaveHardwareConfig()
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("上下位机定量点同步失败。")
                end
            end
        end,
        {
            name = "point1",
            text = "定量点1",
            refData = "meterPoint.point[1].setVolume",
            unit = "ml",
            get = function()
                local meterPoint = setting.ui.profile.hardwareParamIterms[7].meterPoints:GetPoint(1)
                return meterPoint:GetRealVolume()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.twoDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.2f",setting.ui.profile.hardwareParamIterms[7][1].get())
                end
            end,
            set = function(value)
                local meterPoint = setting.ui.profile.hardwareParamIterms[7].meterPoints:GetPoint(1)
                meterPoint:SetRealVolume(value)
                setting.ui.profile.hardwareParamIterms[7].meterPoints:SetPoint(1, meterPoint)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "point2",
            text = "定量点2",
            refData = "meterPoint.point[2].setVolume",
            unit = "ml",
            get = function()
                local meterPoint = setting.ui.profile.hardwareParamIterms[7].meterPoints:GetPoint(2)
                return meterPoint:GetRealVolume()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.twoDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.2f",setting.ui.profile.hardwareParamIterms[7][2].get())
                end
            end,
            set = function(value)
                local meterPoint = setting.ui.profile.hardwareParamIterms[7].meterPoints:GetPoint(2)
                meterPoint:SetRealVolume(value)
                setting.ui.profile.hardwareParamIterms[7].meterPoints:SetPoint(2, meterPoint)
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        name = "meterLed",
        text = "定量AD校准",
        point =
        {
            128,
            128,
        },
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local ret = {}
                    ret[1]  = dc:GetIOpticalAcquire():GetStaticADControlParam(2)
                    ret[2]  = dc:GetIOpticalAcquire():GetStaticADControlParam(3)
                    return ret
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[8].point[1] = 0
                    setting.ui.profile.hardwareParamIterms[8].point[2] = 0
                else
                    setting.ui.profile.hardwareParamIterms[8].point[1] = result[1]
                    setting.ui.profile.hardwareParamIterms[8].point[2] = result[2]
                end
            else
                setting.ui.profile.hardwareParamIterms[8].point[1] = 0
                setting.ui.profile.hardwareParamIterms[8].point[2] = 0
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    dc:GetIOpticalAcquire():SetStaticADControlParam(2, setting.ui.profile.hardwareParamIterms[8].point[1])
                    App.Sleep(200)
                    dc:GetIOpticalAcquire():SetStaticADControlParam(3, setting.ui.profile.hardwareParamIterms[8].point[2])
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "定量AD校准失败\n"
                else
                    config.hardwareConfig.meterLed.point[1].real = setting.ui.profile.hardwareParamIterms[8].point[1]
                    config.hardwareConfig.meterLed.point[2].real = setting.ui.profile.hardwareParamIterms[8].point[2]
                    return true, ""
                end
            else
                return false, "驱动板连接断开,\n定量AD校准失败\n"
            end
        end,
        {
            name = "point1ad",
            text = "定量一",
            refData = "meterLed.point[1].set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[8].point[1]
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.integerPattern(value) == true then
                    local num = tonumber(value)
                    if num < 0 or num > 256 then
                        return string.format("%d", setting.ui.profile.hardwareParamIterms[8][1].get())
                    else
                        return value
                    end
                else
                    return string.format("%d",setting.ui.profile.hardwareParamIterms[8][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[8].point[1] = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "point2ad",
            text = "定量二",
            refData = "meterLed.point[2].set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[8].point[2]
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.integerPattern(value) == true then
                    local num = tonumber(value)
                    if num < 0 or num > 256 then
                        return string.format("%d", setting.ui.profile.hardwareParamIterms[8][2].get())
                    else
                        return value
                    end
                else
                    return string.format("%d",setting.ui.profile.hardwareParamIterms[8][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[8].point[2] = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        }
    },
    {
        name = "measureLed",
        text = "测量模块校准",
        period = 0,
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local ret = {}
                    ret[1] = dc:GetIOpticalAcquire():GetLEDDefaultValue(0)
                    --ret[2] = dc:GetIOpticalAcquire():GetStaticADControlParam(1)
                    --ret[3] = dc:GetIOpticalAcquire():GetLEDControllerTartet()
                    --ret[4] = dc:GetIOpticalAcquire():GetLEDDefaultValue()
                    return ret
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[9].period = 0

                else
                    setting.ui.profile.hardwareParamIterms[9].period = result[1]
                end
            else
                setting.ui.profile.hardwareParamIterms[9].period = 0
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    dc:GetIOpticalAcquire():SetLEDDefaultValue(setting.ui.profile.hardwareParamIterms[9].period)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "测量模块校准失败\n"
                else
                    config.hardwareConfig.measureLed.period.real = setting.ui.profile.hardwareParamIterms[9].period
                    ConfigLists.SaveHardwareConfig()
                    return true, ""
                end
            else
                return false, "驱动板连接断开,\n测量模块校准失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local period = dc:GetIOpticalAcquire():GetLEDDefaultValue(0)
                    if math.abs(period - config.hardwareConfig.measureLed.period.real) > PRECISE then

                        log:debug("参数同步-[测量周期(ms)] " .. config.hardwareConfig.measureLed.period.real)

                        dc:GetIOpticalAcquire():SetLEDDefaultValue(config.hardwareConfig.measureLed.period.real)
                        App.Sleep(200)

                        period = dc:GetIOpticalAcquire():GetLEDDefaultValue(0)
                        if math.abs(period - config.hardwareConfig.measureLed.period.real) > PRECISE then
                            log:warn("同步测量周期失败。")
                        else
                            log:warn("同步测量周期成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步测量周期失败。")
                end
            end
        end,
        {
            name = "measure",
            text = "测量周期",
            refData = "measureLed.period.set",
            unit = "ms",
            get = function()
                return setting.ui.profile.hardwareParamIterms[9].period
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.integerPattern(value) == true then
                    local num = tonumber(value)
                    if num >= 80 and num < 2000 then
                        if math.floor(num%10) == 0 then
                            return value
                        else
                            return string.format("%d", setting.ui.profile.hardwareParamIterms[9][1].get())
                        end
                    else
                        return string.format("%d", setting.ui.profile.hardwareParamIterms[9][1].get())
                    end
                else
                    return string.format("%d",setting.ui.profile.hardwareParamIterms[9][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[9].period = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "motorOffsetStep",
        text = "进样校准",
        offsetStep = 0,
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local ret = dc:GetIPeristalticPump():GetPumpOffsetStep(0)
                    return ret
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[10].offsetStep = 0
                else
                    setting.ui.profile.hardwareParamIterms[10].offsetStep = result
                end
            else
                setting.ui.profile.hardwareParamIterms[10].offsetStep = 0
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    dc:GetIPeristalticPump():SetPumpOffsetStep(0, setting.ui.profile.hardwareParamIterms[10].offsetStep)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "进样电机校准失败\n"
                else
                    config.hardwareConfig.motorOffsetStep.offsetStep.real = setting.ui.profile.hardwareParamIterms[10].offsetStep
                    ConfigLists.SaveHardwareConfig()
                    return true, ""
                end
            else
                return false, "驱动板连接断开,\n进样电机校准失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local offsetStep = dc:GetIPeristalticPump():GetPumpOffsetStep(0)
                    if math.abs(offsetStep - config.hardwareConfig.motorOffsetStep.offsetStep.real) > PRECISE then

                        log:debug("参数同步-[进样偏移步数(ms)] " .. config.hardwareConfig.motorOffsetStep.offsetStep.real)

                        dc:GetIPeristalticPump():SetPumpOffsetStep(0, config.hardwareConfig.motorOffsetStep.offsetStep.real)
                        App.Sleep(200)

                        offsetStep = dc:GetIOpticalAcquire():GetLEDDefaultValue(0)
                        if math.abs(offsetStep - config.hardwareConfig.motorOffsetStep.offsetStep.real) > PRECISE then
                            log:warn("同步进样校准系数失败。")
                        else
                            log:warn("同步进样校准系数成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步进样校准系数失败。")
                end
            end
        end,
        {
            name = "offsetStep",
            text = "偏移步数",
            refData = "motorOffsetStep.offsetStep.set",
            unit = "ms/步",
            get = function()
                return setting.ui.profile.hardwareParamIterms[10].offsetStep
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.symbolIntegerPattern(value) == true then
                    local num = tonumber(value)
                    if num <= -1000 or num >= 1000 then
                        return string.format("%d", setting.ui.profile.hardwareParamIterms[10][1].get())
                    else
                        return value
                    end
                else
                    return string.format("%d",setting.ui.profile.hardwareParamIterms[10][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[10].offsetStep = value
            end,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
    },
    {
        name = "syringMaxAcceleration",
        text = "注射器",
        maxAcceleration = 0,
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local ret = {}
                    ret[1] = dc:GetIOpticalAcquire():GetLEDControllerTartet()

                    return ret
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[11].maxAcceleration = 0

                else
                    setting.ui.profile.hardwareParamIterms[11].maxAcceleration = result[1]
                end
            else
                setting.ui.profile.hardwareParamIterms[11].maxAcceleration = 0
            end
        end,
        set = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    dc:GetIOpticalAcquire():SetLEDControllerTarget(setting.ui.profile.hardwareParamIterms[11].maxAcceleration)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "注射器最大加速度校准失败\n"
                else
                    return true, ""
                end
            else
                return false, "驱动板连接断开,\n注射器最大加速度校准失败\n"
            end
        end,
        {
            name = "syringMaxAcceleration",
            text = "最大加速度",
            refData = "syringMaxAcceleration",
            unit = " ml/s^2",
            get = function()
                return setting.ui.profile.hardwareParamIterms[11].maxAcceleration
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.integerPattern(value) == true then
                    local num = tonumber(value)
                    if num >= 1 and num < 60 then
                        return value
                    else
                        return string.format("%d", setting.ui.profile.hardwareParamIterms[11][1].get())
                    end
                else
                    return string.format("%d",setting.ui.profile.hardwareParamIterms[11][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[11].maxAcceleration = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        name = "thermostatParam",
        text = "燃烧炉PID",
        thermostatParam = ThermostatParam.new(),
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():GetThermostatParam()
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[12].thermostatParam:SetProportion(0)
                    App.Sleep(200)
                    setting.ui.profile.hardwareParamIterms[12].thermostatParam:SetIntegration(0)
                    App.Sleep(200)
                    setting.ui.profile.hardwareParamIterms[12].thermostatParam:SetDifferential(0)
                else
                    setting.ui.profile.hardwareParamIterms[12].thermostatParam = result
                end
            else
                setting.ui.profile.hardwareParamIterms[12].thermostatParam:SetProportion(0)
                App.Sleep(200)
                setting.ui.profile.hardwareParamIterms[12].thermostatParam:SetIntegration(0)
                App.Sleep(200)
                setting.ui.profile.hardwareParamIterms[12].thermostatParam:SetDifferential(0)
            end
        end,
        set = function()
            ConfigLists.SaveHardwareConfig()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetITemperatureControl():SetThermostatParam(setting.ui.profile.hardwareParamIterms[12].thermostatParam)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置恒温器PID失败\n"
                else
                    return true, ""
                end
            else
                return false, "驱动板连接断开,\n设置恒温器PID失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local getthermostatParam = dc:GetITemperatureControl():GetThermostatParam()
                    if math.abs(getthermostatParam:GetProportion() - config.hardwareConfig.thermostatParam.proportion.real) > PRECISE
                            or math.abs(getthermostatParam:GetIntegration() - config.hardwareConfig.thermostatParam.integration.real) > PRECISE
                            or math.abs(getthermostatParam:GetDifferential() - config.hardwareConfig.thermostatParam.differential.real) > PRECISE then

                        local thermostatParam = ThermostatParam.new()
                        thermostatParam:SetProportion(config.hardwareConfig.thermostatParam.proportion.real)
                        thermostatParam:SetIntegration(config.hardwareConfig.thermostatParam.integration.real)
                        thermostatParam:SetDifferential(config.hardwareConfig.thermostatParam.differential.real)

                        dc:GetITemperatureControl():SetThermostatParam(thermostatParam)
                        App.Sleep(200)

                        getthermostatParam = dc:GetITemperatureControl():GetThermostatParam()
                        if math.abs(getthermostatParam:GetProportion() - config.hardwareConfig.thermostatParam.proportion.real) > PRECISE
                                or math.abs(getthermostatParam:GetIntegration() - config.hardwareConfig.thermostatParam.integration.real) > PRECISE
                                or math.abs(getthermostatParam:GetDifferential() - config.hardwareConfig.thermostatParam.differential.real) > PRECISE then
                            log:warn("同步恒温器PID失败。")
                        else
                            log:warn("同步恒温器PID成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步恒温器PID失败。")
                end
            end
        end,
        {
            name = "proportion",
            text = "比例系数",
            refData = "thermostatParam.proportion.set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[12].thermostatParam:GetProportion()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.threeDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.3f",setting.ui.profile.hardwareParamIterms[12][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[12].thermostatParam:SetProportion(value)
                config.hardwareConfig.thermostatParam.proportion.real = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "integration",
            text = "积分系数",
            refData = "thermostatParam.integration.set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[12].thermostatParam:GetIntegration()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.threeDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.3f",setting.ui.profile.hardwareParamIterms[12][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[12].thermostatParam:SetIntegration(value)
                config.hardwareConfig.thermostatParam.integration.real = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "differential",
            text = "微分系数",
            refData = "thermostatParam.differential.set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[12].thermostatParam:GetDifferential()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.threeDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.3f",setting.ui.profile.hardwareParamIterms[12][3].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[12].thermostatParam:SetDifferential(value)
                config.hardwareConfig.thermostatParam.differential.real = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        name = "thermostatParamCooler",
        text = "制冷模块PID",
        thermostatParam = ThermostatParam.new(),
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetIExtTemperatureControl():GetThermostatParam(1)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[13].thermostatParam:SetProportion(0)
                    App.Sleep(200)
                    setting.ui.profile.hardwareParamIterms[13].thermostatParam:SetIntegration(0)
                    App.Sleep(200)
                    setting.ui.profile.hardwareParamIterms[13].thermostatParam:SetDifferential(0)
                else
                    setting.ui.profile.hardwareParamIterms[13].thermostatParam = result
                end
            else
                setting.ui.profile.hardwareParamIterms[13].thermostatParam:SetProportion(0)
                App.Sleep(200)
                setting.ui.profile.hardwareParamIterms[13].thermostatParam:SetIntegration(0)
                App.Sleep(200)
                setting.ui.profile.hardwareParamIterms[13].thermostatParam:SetDifferential(0)
            end
        end,
        set = function()
            ConfigLists.SaveHardwareConfig()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetIExtTemperatureControl():SetThermostatParam(1, setting.ui.profile.hardwareParamIterms[13].thermostatParam)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置恒温器PID失败\n"
                else
                    return true, ""
                end
            else
                return false, "驱动板连接断开,\n设置恒温器PID失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local getthermostatParam = dc:GetIExtTemperatureControl():GetThermostatParam(1)
                    if math.abs(getthermostatParam:GetProportion() - config.hardwareConfig.thermostatParamCooler.proportion.real) > PRECISE
                            or math.abs(getthermostatParam:GetIntegration() - config.hardwareConfig.thermostatParamCooler.integration.real) > PRECISE
                            or math.abs(getthermostatParam:GetDifferential() - config.hardwareConfig.thermostatParamCooler.differential.real) > PRECISE then

                        local thermostatParam = ThermostatParam.new()
                        thermostatParam:SetProportion(config.hardwareConfig.thermostatParamCooler.proportion.real)
                        thermostatParam:SetIntegration(config.hardwareConfig.thermostatParamCooler.integration.real)
                        thermostatParam:SetDifferential(config.hardwareConfig.thermostatParamCooler.differential.real)

                        dc:GetIExtTemperatureControl():SetThermostatParam(1, thermostatParam)
                        App.Sleep(200)

                        getthermostatParam = dc:GetIExtTemperatureControl():GetThermostatParam(1)
                        if math.abs(getthermostatParam:GetProportion() - config.hardwareConfig.thermostatParamCooler.proportion.real) > PRECISE
                                or math.abs(getthermostatParam:GetIntegration() - config.hardwareConfig.thermostatParamCooler.integration.real) > PRECISE
                                or math.abs(getthermostatParam:GetDifferential() - config.hardwareConfig.thermostatParamCooler.differential.real) > PRECISE then
                            log:warn("同步恒温器PID失败。")
                        else
                            log:warn("同步恒温器PID成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步恒温器PID失败。")
                end
            end
        end,
        {
            name = "proportion",
            text = "比例系数",
            refData = "thermostatParamCooler.proportion.set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[13].thermostatParam:GetProportion()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.threeDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.3f",setting.ui.profile.hardwareParamIterms[13][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[13].thermostatParam:SetProportion(value)
                config.hardwareConfig.thermostatParamCooler.proportion.real = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "integration",
            text = "积分系数",
            refData = "thermostatParamCooler.integration.set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[13].thermostatParam:GetIntegration()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.threeDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.3f",setting.ui.profile.hardwareParamIterms[13][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[13].thermostatParam:SetIntegration(value)
                config.hardwareConfig.thermostatParamCooler.integration.real = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "differential",
            text = "微分系数",
            refData = "thermostatParamCooler.differential.set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[13].thermostatParam:GetDifferential()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.threeDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.3f",setting.ui.profile.hardwareParamIterms[13][3].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[13].thermostatParam:SetDifferential(value)
                config.hardwareConfig.thermostatParamCooler.differential.real = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        name = "thermostatParamNDIR",
        text = "测量模块PID",
        thermostatParam = ThermostatParam.new(),
        get = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetIExtTemperatureControl():GetThermostatParam(2)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    setting.ui.profile.hardwareParamIterms[14].thermostatParam:SetProportion(0)
                    App.Sleep(200)
                    setting.ui.profile.hardwareParamIterms[14].thermostatParam:SetIntegration(0)
                    App.Sleep(200)
                    setting.ui.profile.hardwareParamIterms[14].thermostatParam:SetDifferential(0)
                else
                    setting.ui.profile.hardwareParamIterms[14].thermostatParam = result
                end
            else
                setting.ui.profile.hardwareParamIterms[14].thermostatParam:SetProportion(0)
                App.Sleep(200)
                setting.ui.profile.hardwareParamIterms[14].thermostatParam:SetIntegration(0)
                App.Sleep(200)
                setting.ui.profile.hardwareParamIterms[14].thermostatParam:SetDifferential(0)
            end
        end,
        set = function()
            ConfigLists.SaveHardwareConfig()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    return dc:GetIExtTemperatureControl():SetThermostatParam(2, setting.ui.profile.hardwareParamIterms[14].thermostatParam)
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    return false, "设置恒温器PID失败\n"
                else
                    return true, ""
                end
            else
                return false, "驱动板连接断开,\n设置恒温器PID失败\n"
            end
        end,
        synchronize = function()
            if dc:GetConnectStatus() then
                local status,result = pcall(function()
                    local PRECISE = 0.000001
                    local getthermostatParam = dc:GetIExtTemperatureControl():GetThermostatParam(2)
                    if math.abs(getthermostatParam:GetProportion() - config.hardwareConfig.thermostatParamNDIR.proportion.real) > PRECISE
                            or math.abs(getthermostatParam:GetIntegration() - config.hardwareConfig.thermostatParamNDIR.integration.real) > PRECISE
                            or math.abs(getthermostatParam:GetDifferential() - config.hardwareConfig.thermostatParamNDIR.differential.real) > PRECISE then

                        local thermostatParam = ThermostatParam.new()
                        thermostatParam:SetProportion(config.hardwareConfig.thermostatParamNDIR.proportion.real)
                        thermostatParam:SetIntegration(config.hardwareConfig.thermostatParamNDIR.integration.real)
                        thermostatParam:SetDifferential(config.hardwareConfig.thermostatParamNDIR.differential.real)

                        dc:GetIExtTemperatureControl():SetThermostatParam(2, thermostatParam)
                        App.Sleep(200)

                        getthermostatParam = dc:GetIExtTemperatureControl():GetThermostatParam(2)
                        if math.abs(getthermostatParam:GetProportion() - config.hardwareConfig.thermostatParamNDIR.proportion.real) > PRECISE
                                or math.abs(getthermostatParam:GetIntegration() - config.hardwareConfig.thermostatParamNDIR.integration.real) > PRECISE
                                or math.abs(getthermostatParam:GetDifferential() - config.hardwareConfig.thermostatParamNDIR.differential.real) > PRECISE then
                            log:warn("同步恒温器PID失败。")
                        else
                            log:warn("同步恒温器PID成功。")
                        end
                    end
                end)
                if not status then
                    ExceptionHandler.MakeAlarm(result)
                    log:warn("同步恒温器PID失败。")
                end
            end
        end,
        {
            name = "proportion",
            text = "比例系数",
            refData = "thermostatParamNDIR.proportion.set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[14].thermostatParam:GetProportion()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.threeDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.3f",setting.ui.profile.hardwareParamIterms[14][1].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[14].thermostatParam:SetProportion(value)
                config.hardwareConfig.thermostatParamNDIR.proportion.real = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "integration",
            text = "积分系数",
            refData = "thermostatParamNDIR.integration.set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[14].thermostatParam:GetIntegration()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.threeDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.3f",setting.ui.profile.hardwareParamIterms[14][2].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[14].thermostatParam:SetIntegration(value)
                config.hardwareConfig.thermostatParamNDIR.integration.real = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "differential",
            text = "微分系数",
            refData = "thermostatParamNDIR.differential.set",
            get = function()
                return setting.ui.profile.hardwareParamIterms[14].thermostatParam:GetDifferential()
            end,
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.threeDecimalPattern(value) == true then
                    return value
                else
                    return string.format("%.3f",setting.ui.profile.hardwareParamIterms[14][3].get())
                end
            end,
            set = function(value)
                setting.ui.profile.hardwareParamIterms[14].thermostatParam:SetDifferential(value)
                config.hardwareConfig.thermostatParamNDIR.differential.real = value
            end,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    autoTempCalibrate =
    {
        {
            name = "tempCalibrate1",
            text = "温度1",
            index = 0,
            unit = "℃",
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return ""
                end
            end,
            calibrateFunc = function(index, value)
                if dc:GetConnectStatus() then
                    local err,ret = pcall(function()
                        local tempAD = 0
                        for i=1,5 do
                            tempAD = tempAD + dc:GetStoveADValue()
                            App.Sleep(1000)
                        end
                        tempAD = tempAD/5
                        log:debug("getad " .. tempAD)
                        config.hardwareConfig.twoPointTempCalibrate.firstTempAD = tempAD
                        config.hardwareConfig.twoPointTempCalibrate.firstTemp = value
                        return true
                    end)

                    if not err then      -- 出现异常
                        if type(ret) == "userdata" then
                            log:warn("TemperatureCalibrate() =>" .. ret:What())
                        elseif type(ret) == "table" then
                            log:warn("TemperatureCalibrate() =>" .. ret:What())
                        elseif type(ret) == "string" then
                            log:warn("TemperatureCalibrate() =>" .. ret)	--C++、Lua系统异常
                        end
                    end
                else
                    log:debug("驱动板未连接")
                end
            end
        },
        {
            name = "tempCalibrate2",
            text = "温度2",
            index = 1,
            unit = "℃",
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return ""
                end
            end,
            calibrateFunc = function(index, value)
                if dc:GetConnectStatus() then
                    local err,ret = pcall(function()
                        local tempAD = 0
                        for i=1,5 do
                            tempAD = tempAD + dc:GetStoveADValue()
                            App.Sleep(1000)
                        end
                        tempAD = tempAD/5
                        log:debug("getad " .. tempAD)
                        config.hardwareConfig.twoPointTempCalibrate.secondTempAD = tempAD
                        config.hardwareConfig.twoPointTempCalibrate.secondTemp = value
                        return true
                    end)
                    if not err then      -- 出现异常
                        if type(ret) == "userdata" then
                            log:warn("TemperatureCalibrate() =>" .. ret:What())
                        elseif type(ret) == "table" then
                            log:warn("TemperatureCalibrate() =>" .. ret:What())
                        elseif type(ret) == "string" then
                            log:warn("TemperatureCalibrate() =>" .. ret)	--C++、Lua系统异常
                        end
                    end
                else
                    log:debug("驱动板未连接")
                end
            end
        },
    },
    exAutoTempCalibrate =
    {
        {
            name = "tempCalibrate",
            text = "制冷温度",
            index = 1,
            unit = "℃",
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return ""
                end
            end,
            calibrateFunc = function(index, value)
                if dc:GetConnectStatus() then
                    local tempCalibrate = TempCalibrateFactor.new()

                    local status,result = pcall(function()
                        return dc:GetITemperatureControl():GetCalibrateFactorForTOC(index)
                    end)

                    if not status then
                        ExceptionHandler.MakeAlarm(result)
                        return false
                    else
                        tempCalibrate = nil
                        tempCalibrate = result
                    end

                    local offsetFactor = 0.01
                    local startNegativeInput = result:GetNegativeInput()
                    local setNegativeInput = startNegativeInput - offsetFactor
                    local startTemperature = 0
                    local reviseTemperature = 0
                    local temperatureFactor
                    local temperatureTolerance = 1.5
                    for i=1,5 do
                        startTemperature = startTemperature + dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
                        App.Sleep(1000)
                    end
                    startTemperature = startTemperature / 5
                    if value > startTemperature  then
                        setNegativeInput = startNegativeInput - offsetFactor
                    else
                        setNegativeInput = startNegativeInput + offsetFactor
                    end
                    tempCalibrate:SetNegativeInput(setNegativeInput)
                    log:debug("targetTemperature " .. value .. ", startTemperature " .. startTemperature .. ", startNegativeInput "  .. startNegativeInput .. ", setNegativeInput " .. setNegativeInput)

                    local status,result = pcall(function()
                        return dc:GetITemperatureControl():SetCalibrateFactorForTOC(index, tempCalibrate)
                    end)
                    if not status then
                        ExceptionHandler.MakeAlarm(result)
                        return false, "设置温度校准系数失败\n"
                    else
                        App.Sleep(1000)
                        for i=1,5 do
                            reviseTemperature = reviseTemperature + dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
                            App.Sleep(1000)
                        end
                        reviseTemperature = reviseTemperature / 5

                        temperatureFactor = offsetFactor / (math.abs(reviseTemperature - startTemperature))

                        offsetFactor = temperatureFactor * (math.abs(value - startTemperature))

                        if value > startTemperature then
                            setNegativeInput = startNegativeInput - offsetFactor
                        else
                            setNegativeInput = startNegativeInput + offsetFactor
                        end
                        tempCalibrate:SetNegativeInput(setNegativeInput)
                        log:debug("reviseTemperature " .. reviseTemperature .. ", setNegativeInput " .. setNegativeInput .. ", factor " .. offsetFactor)

                        local status,result = pcall(function()
                            return dc:GetITemperatureControl():SetCalibrateFactorForTOC(index, tempCalibrate)
                        end)
                        App.Sleep(1000)
                        if not status then
                            ExceptionHandler.MakeAlarm(result)
                            return false, "设置温度校准系数失败\n"
                        else
                            reviseTemperature = 0
                            for i=1,5 do
                                reviseTemperature = reviseTemperature + dc:GetReportThermostatTemp(setting.temperature.temperatureRefrigerator)
                                App.Sleep(1000)
                            end

                            reviseTemperature = reviseTemperature / 5
                            if math.abs(value - reviseTemperature) < temperatureTolerance then

                                local status,result = pcall(function()
                                    return dc:GetITemperatureControl():GetCalibrateFactorForTOC(index)
                                end)

                                if not status then
                                    ExceptionHandler.MakeAlarm(result)
                                    return false
                                else
                                    tempCalibrate = nil
                                    tempCalibrate = result
                                end

                                config.hardwareConfig.backupParam.CoolerTempCalibrate.negativeInput = string.format("%.4f", tempCalibrate:GetNegativeInput())
                                config.hardwareConfig.backupParam.CoolerTempCalibrate.referenceVoltage =  string.format("%.4f", tempCalibrate:GetReferenceVoltage())
                                config.hardwareConfig.backupParam.CoolerTempCalibrate.calibrationVoltage =  string.format("%.4f", tempCalibrate:GetCalibrationVoltage())

                                ConfigLists.SaveHardwareConfig()

                                return true
                            else
                                return false
                            end
                        end
                    end

                else
                    log:debug("驱动板未连接")
                end
            end,
        },
        {
            name = "NDIRTempCalibrate",
            text = "测量温度",
            tempCalibrate = TempCalibrateFactor.new(),
            index = 2,
            unit = "℃",
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return ""
                end
            end,
            calibrateFunc = function(index, value)
                if dc:GetConnectStatus() then
                    local tempCalibrate = TempCalibrateFactor.new()

                    local status,result = pcall(function()
                        return dc:GetITemperatureControl():GetCalibrateFactorForTOC(index)
                    end)

                    if not status then
                        ExceptionHandler.MakeAlarm(result)
                        return false
                    else
                        tempCalibrate = nil
                        tempCalibrate = result
                    end

                    local offsetFactor = 0.01
                    local startNegativeInput = result:GetNegativeInput()
                    local setNegativeInput = startNegativeInput - offsetFactor
                    local startTemperature = 0
                    local reviseTemperature = 0
                    local temperatureFactor
                    local temperatureTolerance = 1.5
                    for i=1,5 do
                        startTemperature = startTemperature + dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
                        App.Sleep(1000)
                    end
                    startTemperature = startTemperature / 5
                    if value > startTemperature  then
                        setNegativeInput = startNegativeInput - offsetFactor
                    else
                        setNegativeInput = startNegativeInput + offsetFactor
                    end
                    tempCalibrate:SetNegativeInput(setNegativeInput)
                    log:debug("targetTemperature " .. value .. ", startTemperature " .. startTemperature .. ", startNegativeInput "  .. startNegativeInput .. ", setNegativeInput " .. setNegativeInput)

                    local status,result = pcall(function()
                        return dc:GetITemperatureControl():SetCalibrateFactorForTOC(index, tempCalibrate)
                    end)
                    if not status then
                        ExceptionHandler.MakeAlarm(result)
                        return false, "设置温度校准系数失败\n"
                    else
                        App.Sleep(1000)
                        for i=1,5 do
                            reviseTemperature = reviseTemperature + dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
                            App.Sleep(1000)
                        end
                        reviseTemperature = reviseTemperature / 5

                        temperatureFactor = offsetFactor / (math.abs(reviseTemperature - startTemperature))

                        offsetFactor = temperatureFactor * (math.abs(value - startTemperature))

                        if value > startTemperature then
                            setNegativeInput = startNegativeInput - offsetFactor
                        else
                            setNegativeInput = startNegativeInput + offsetFactor
                        end
                        tempCalibrate:SetNegativeInput(setNegativeInput)
                        log:debug("reviseTemperature " .. reviseTemperature .. ", setNegativeInput " .. setNegativeInput .. ", factor " .. offsetFactor)

                        local status,result = pcall(function()
                            return dc:GetITemperatureControl():SetCalibrateFactorForTOC(index, tempCalibrate)
                        end)
                        App.Sleep(1000)
                        if not status then
                            ExceptionHandler.MakeAlarm(result)
                            return false, "设置温度校准系数失败\n"
                        else
                            reviseTemperature = 0
                            for i=1,5 do
                                reviseTemperature = reviseTemperature + dc:GetReportThermostatTemp(setting.temperature.temperatureNDIR)
                                App.Sleep(1000)
                            end

                            reviseTemperature = reviseTemperature / 5
                            if math.abs(value - reviseTemperature) < temperatureTolerance then

                                local status,result = pcall(function()
                                    return dc:GetITemperatureControl():GetCalibrateFactorForTOC(index)
                                end)

                                if not status then
                                    ExceptionHandler.MakeAlarm(result)
                                    return false
                                else
                                    tempCalibrate = nil
                                    tempCalibrate = result
                                end

                                config.hardwareConfig.backupParam.NDIRTempCalibrate.negativeInput = string.format("%.4f", tempCalibrate:GetNegativeInput())
                                config.hardwareConfig.backupParam.NDIRTempCalibrate.referenceVoltage =  string.format("%.4f", tempCalibrate:GetReferenceVoltage())
                                config.hardwareConfig.backupParam.NDIRTempCalibrate.calibrationVoltage =  string.format("%.4f", tempCalibrate:GetCalibrationVoltage())

                                ConfigLists.SaveHardwareConfig()

                                return true
                            else
                                return false
                            end
                        end
                    end

                else
                    log:debug("驱动板未连接")
                end
            end,
        },
        {
            name = "fanUpTempCalibrate",
            text = "上机箱温度",
            tempCalibrate = TempCalibrateFactor.new(),
            index = 3,
            unit = "℃",
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return ""
                end
            end,
            calibrateFunc = function(index, value)
                if dc:GetConnectStatus() then
                    local tempCalibrate = TempCalibrateFactor.new()

                    local status,result = pcall(function()
                        return dc:GetITemperatureControl():GetCalibrateFactorForTOC(index)
                    end)

                    if not status then
                        ExceptionHandler.MakeAlarm(result)
                        return false
                    else
                        tempCalibrate = nil
                        tempCalibrate = result
                    end

                    local offsetFactor = 0.01
                    local startNegativeInput = result:GetNegativeInput()
                    local setNegativeInput = startNegativeInput - offsetFactor
                    local startTemperature = 0
                    local reviseTemperature = 0
                    local temperatureFactor
                    local temperatureTolerance = 1.5
                    for i=1,5 do
                        startTemperature = startTemperature + dc:GetEnvironmentTemperature()
                        App.Sleep(1000)
                    end
                    startTemperature = startTemperature / 5
                    if value > startTemperature  then
                        setNegativeInput = startNegativeInput - offsetFactor
                    else
                        setNegativeInput = startNegativeInput + offsetFactor
                    end
                    tempCalibrate:SetNegativeInput(setNegativeInput)
                    log:debug("targetTemperature " .. value .. ", startTemperature " .. startTemperature .. ", startNegativeInput "  .. startNegativeInput .. ", setNegativeInput " .. setNegativeInput)

                    local status,result = pcall(function()
                        return dc:GetITemperatureControl():SetCalibrateFactorForTOC(index, tempCalibrate)
                    end)
                    if not status then
                        ExceptionHandler.MakeAlarm(result)
                        return false, "设置温度校准系数失败\n"
                    else
                        App.Sleep(1000)
                        for i=1,5 do
                            reviseTemperature = reviseTemperature + dc:GetEnvironmentTemperature()
                            App.Sleep(1000)
                        end
                        reviseTemperature = reviseTemperature / 5

                        temperatureFactor = offsetFactor / (math.abs(reviseTemperature - startTemperature))

                        offsetFactor = temperatureFactor * (math.abs(value - startTemperature))

                        if value > startTemperature then
                            setNegativeInput = startNegativeInput - offsetFactor
                        else
                            setNegativeInput = startNegativeInput + offsetFactor
                        end
                        tempCalibrate:SetNegativeInput(setNegativeInput)
                        log:debug("reviseTemperature " .. reviseTemperature .. ", setNegativeInput " .. setNegativeInput .. ", factor " .. offsetFactor)

                        local status,result = pcall(function()
                            return dc:GetITemperatureControl():SetCalibrateFactorForTOC(index, tempCalibrate)
                        end)
                        App.Sleep(1000)
                        if not status then
                            ExceptionHandler.MakeAlarm(result)
                            return false, "设置温度校准系数失败\n"
                        else
                            reviseTemperature = 0
                            for i=1,5 do
                                reviseTemperature = reviseTemperature + dc:GetEnvironmentTemperature()
                                App.Sleep(1000)
                            end

                            reviseTemperature = reviseTemperature / 5
                            if math.abs(value - reviseTemperature) < temperatureTolerance then

                                local status,result = pcall(function()
                                    return dc:GetITemperatureControl():GetCalibrateFactorForTOC(index)
                                end)

                                if not status then
                                    ExceptionHandler.MakeAlarm(result)
                                    return false
                                else
                                    tempCalibrate = nil
                                    tempCalibrate = result
                                end

                                config.hardwareConfig.backupParam.fanUpTempCalibrate.negativeInput = string.format("%.4f", tempCalibrate:GetNegativeInput())
                                config.hardwareConfig.backupParam.fanUpTempCalibrate.referenceVoltage =  string.format("%.4f", tempCalibrate:GetReferenceVoltage())
                                config.hardwareConfig.backupParam.fanUpTempCalibrate.calibrationVoltage =  string.format("%.4f", tempCalibrate:GetCalibrationVoltage())

                                ConfigLists.SaveHardwareConfig()

                                return true
                            else
                                return false
                            end
                        end
                    end

                else
                    log:debug("驱动板未连接")
                end
            end,
        },
        {
            name = "fanDownTempCalibrate",
            text = "下机箱温度",
            tempCalibrate = TempCalibrateFactor.new(),
            index = 4,
            unit = "℃",
            checkValue = function(value)
                if setting.ui.profile.hardwareParamIterms.manyDecimalPattern(value) == true then
                    return value
                else
                    return ""
                end
            end,
            calibrateFunc = function(index, value)
                if dc:GetConnectStatus() then
                    local tempCalibrate = TempCalibrateFactor.new()

                    local status,result = pcall(function()
                        return dc:GetITemperatureControl():GetCalibrateFactorForTOC(index)
                    end)

                    if not status then
                        ExceptionHandler.MakeAlarm(result)
                        return false
                    else
                        tempCalibrate = nil
                        tempCalibrate = result
                    end

                    local offsetFactor = 0.01
                    local startNegativeInput = result:GetNegativeInput()
                    local setNegativeInput
                    local startTemperature = 0
                    local reviseTemperature = 0
                    local temperatureFactor
                    local temperatureTolerance = 1.5
                    for i=1,5 do
                        startTemperature = startTemperature + dc:GetReportThermostatTemp(setting.temperature.temperatureBoxLow)
                        App.Sleep(1000)
                    end
                    startTemperature = startTemperature / 5
                    if value > startTemperature  then
                        setNegativeInput = startNegativeInput - offsetFactor
                    else
                        setNegativeInput = startNegativeInput + offsetFactor
                    end
                    tempCalibrate:SetNegativeInput(setNegativeInput)
                    log:debug("targetTemperature " .. value .. ", startTemperature " .. startTemperature .. ", startNegativeInput "  .. startNegativeInput .. ", setNegativeInput " .. setNegativeInput)

                    local status,result = pcall(function()
                        return dc:GetITemperatureControl():SetCalibrateFactorForTOC(index, tempCalibrate)
                    end)
                    if not status then
                        ExceptionHandler.MakeAlarm(result)
                        return false, "设置温度校准系数失败\n"
                    else
                        App.Sleep(1000)
                        for i=1,5 do
                            reviseTemperature = reviseTemperature + dc:GetReportThermostatTemp(setting.temperature.temperatureBoxLow)
                            App.Sleep(1000)
                        end
                        reviseTemperature = reviseTemperature / 5

                        temperatureFactor = offsetFactor / (math.abs(reviseTemperature - startTemperature))

                        offsetFactor = temperatureFactor * (math.abs(value - startTemperature))

                        if value > startTemperature then
                            setNegativeInput = startNegativeInput - offsetFactor
                        else
                            setNegativeInput = startNegativeInput + offsetFactor
                        end
                        tempCalibrate:SetNegativeInput(setNegativeInput)
                        log:debug("reviseTemperature " .. reviseTemperature .. ", setNegativeInput " .. setNegativeInput .. ", factor " .. offsetFactor)

                        local status,result = pcall(function()
                            return dc:GetITemperatureControl():SetCalibrateFactorForTOC(index, tempCalibrate)
                        end)
                        App.Sleep(1000)
                        if not status then
                            ExceptionHandler.MakeAlarm(result)
                            return false, "设置温度校准系数失败\n"
                        else
                            reviseTemperature = 0
                            for i=1,5 do
                                reviseTemperature = reviseTemperature + dc:GetReportThermostatTemp(setting.temperature.temperatureBoxLow)
                                App.Sleep(1000)
                            end

                            reviseTemperature = reviseTemperature / 5
                            if math.abs(value - reviseTemperature) < temperatureTolerance then

                                local status,result = pcall(function()
                                    return dc:GetITemperatureControl():GetCalibrateFactorForTOC(index)
                                end)

                                if not status then
                                    ExceptionHandler.MakeAlarm(result)
                                    return false
                                else
                                    tempCalibrate = nil
                                    tempCalibrate = result
                                end

                                config.hardwareConfig.backupParam.fanDownTempCalibrate.negativeInput = string.format("%.4f", tempCalibrate:GetNegativeInput())
                                config.hardwareConfig.backupParam.fanDownTempCalibrate.referenceVoltage =  string.format("%.4f", tempCalibrate:GetReferenceVoltage())
                                config.hardwareConfig.backupParam.fanDownTempCalibrate.calibrationVoltage =  string.format("%.4f", tempCalibrate:GetCalibrationVoltage())

                                ConfigLists.SaveHardwareConfig()

                                return true
                            else
                                return false
                            end
                        end
                    end

                else
                    log:debug("驱动板未连接")
                end
            end,
        },
    },
    manyDecimalPattern = function(value)
        if type(value) == "string" then
            local ret = false
            local decimalPatterm = "^%d?%d?%d%.%d%d?%d?%d?%d?%d?%d?%d?$"
            local integerPatterm = "^%d?%d?%d$"
            if not string.find(value, decimalPatterm) then
                if string.find(value, integerPatterm) then
                    ret = true
                end
            else
                ret = true
            end
            return ret
        else
            return false
        end
    end,
    twoDecimalPattern = function(value)
        if type(value) == "string" then
            local ret = false
            local decimalPatterm = "^%d?%d?%d%.%d%d?$"
            local integerPatterm = "^%d?%d?%d$"
            if not string.find(value, decimalPatterm) then
                if string.find(value, integerPatterm) then
                    ret = true
                end
            else
                ret = true
            end
            return ret
        else
            return false
        end
    end,
    threeDecimalPattern = function(value)
        if type(value) == "string" then
            local ret = false
            local decimalPatterm = "^%d?%d?%d%.%d%d?%d?$"
            local integerPatterm = "^%d?%d?%d$"
            if not string.find(value, decimalPatterm) then
                if string.find(value, integerPatterm) then
                    ret = true
                end
            else
                ret = true
            end
            return ret
        else
            return false
        end
    end,
    integerPattern = function(value)
        if type(value) == "string" then
            local ret = false
            local integerPatterm = "^%d?%d?%d?%d$"
            if string.find(value, integerPatterm) then
                ret = true
            end
            return ret
        else
            return false
        end
    end,
    electricPattern = function(value)
        if type(value) == "string" then
            local ret = false
            local decimalPatterm = "^[-+]?%d?%d?%d?%d%.%d%d?$"
            local integerPatterm = "^[-+]?%d?%d?%d?%d$"
            if not string.find(value, decimalPatterm) then
                if string.find(value, integerPatterm) then
                    ret = true
                end
            else
                ret = true
            end
            return ret
        else
            return false
        end
    end,
    symbolIntegerPattern = function(value)
        if type(value) == "string" then
            local ret = false
            local decimalPatterm = "^[-+]?%d?%d?%d?%d$"
            local integerPatterm = "^[-+]?%d?%d?%d?%d$"
            if not string.find(value, decimalPatterm) then
                if string.find(value, integerPatterm) then
                    ret = true
                end
            else
                ret = true
            end
            return ret
        else
            return false
        end
    end,
    synchronize = function()
        setting.ui.profile.hardwareParamIterms[7].synchronize()
        setting.ui.profile.hardwareParamIterms[12].synchronize()
        setting.ui.profile.hardwareParamIterms[13].synchronize()
        setting.ui.profile.hardwareParamIterms[14].synchronize()
        if config.hardwareConfig.backupSign then
            setting.ui.profile.hardwareParamIterms[1].synchronize()
            setting.ui.profile.hardwareParamIterms[2].synchronize()
            setting.ui.profile.hardwareParamIterms[3].synchronize()
            setting.ui.profile.hardwareParamIterms[4].synchronize()
            setting.ui.profile.hardwareParamIterms[5].synchronize()
            setting.ui.profile.hardwareParamIterms[6].synchronize()
            setting.ui.profile.hardwareParamIterms[9].synchronize()
            setting.ui.profile.hardwareParamIterms[10].synchronize()
        end
    end,

    backupParam = function()
        local ret = false
        if dc:GetConnectStatus() then
            config.hardwareConfig.backupSign = true
            --泵系数
            config.hardwareConfig.backupParam.pumpMeter = string.format("%.8f", setting.ui.profile.hardwareParamIterms[1].pumpFactor[1])
            config.hardwareConfig.backupParam.pumpSyring = string.format("%.8f", setting.ui.profile.hardwareParamIterms[1].pumpFactor[2])
            log:debug("[定量泵系数(ml/步)] " .. config.hardwareConfig.backupParam.pumpMeter)
            log:debug("[注射泵系数(ml/步)] " .. config.hardwareConfig.backupParam.pumpSyring)

            --制冷温度
            config.hardwareConfig.backupParam.CoolerTempCalibrate.negativeInput = string.format("%.4f", setting.ui.profile.hardwareParamIterms[2].tempCalibrate:GetNegativeInput())
            config.hardwareConfig.backupParam.CoolerTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[2].tempCalibrate:GetReferenceVoltage())
            config.hardwareConfig.backupParam.CoolerTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[2].tempCalibrate:GetCalibrationVoltage())
            log:debug("[制冷校准系数(V)-负输入分压-参考电压-校准电压] " ..  config.hardwareConfig.backupParam.CoolerTempCalibrate.negativeInput
                    .. ", "  .. config.hardwareConfig.backupParam.CoolerTempCalibrate.referenceVoltage
                    .. ", "  .. config.hardwareConfig.backupParam.CoolerTempCalibrate.calibrationVoltage)

            --测量温度
            config.hardwareConfig.backupParam.NDIRTempCalibrate.negativeInput =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[3].tempCalibrate:GetNegativeInput())
            config.hardwareConfig.backupParam.NDIRTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[3].tempCalibrate:GetReferenceVoltage())
            config.hardwareConfig.backupParam.NDIRTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[3].tempCalibrate:GetCalibrationVoltage())
            log:debug("[测量校准系数(V)-负输入分压-参考电压-校准电压] " ..  config.hardwareConfig.backupParam.NDIRTempCalibrate.negativeInput
                    .. ", "  .. config.hardwareConfig.backupParam.NDIRTempCalibrate.referenceVoltage
                    .. ", "  .. config.hardwareConfig.backupParam.NDIRTempCalibrate.calibrationVoltage)

            --电炉温度
            config.hardwareConfig.backupParam.stoveTempCalibrate.negativeInput =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[4].tempCalibrate:GetNegativeInput())
            config.hardwareConfig.backupParam.stoveTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[4].tempCalibrate:GetReferenceVoltage())
            config.hardwareConfig.backupParam.stoveTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[4].tempCalibrate:GetCalibrationVoltage())
            log:debug("参数同步-[电炉校准系数(V)-校准系数-校准AD-校准温度] " ..  config.hardwareConfig.backupParam.stoveTempCalibrate.negativeInput
                    .. ", "  .. config.hardwareConfig.backupParam.stoveTempCalibrate.referenceVoltage
                    .. ", "  .. config.hardwareConfig.backupParam.stoveTempCalibrate.calibrationVoltage)

            --上机箱温度
            config.hardwareConfig.backupParam.fanUpTempCalibrate.negativeInput =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[5].tempCalibrate:GetNegativeInput())
            config.hardwareConfig.backupParam.fanUpTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[5].tempCalibrate:GetReferenceVoltage())
            config.hardwareConfig.backupParam.fanUpTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[5].tempCalibrate:GetCalibrationVoltage())
            log:debug("[上机箱风扇校准系数(V)-负输入分压-参考电压-校准电压] " ..  config.hardwareConfig.backupParam.fanUpTempCalibrate.negativeInput
                    .. ", "  .. config.hardwareConfig.backupParam.fanUpTempCalibrate.referenceVoltage
                    .. ", "  .. config.hardwareConfig.backupParam.fanUpTempCalibrate.calibrationVoltage)

            --下机箱温度
            config.hardwareConfig.backupParam.fanDownTempCalibrate.negativeInput =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[6].tempCalibrate:GetNegativeInput())
            config.hardwareConfig.backupParam.fanDownTempCalibrate.referenceVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[6].tempCalibrate:GetReferenceVoltage())
            config.hardwareConfig.backupParam.fanDownTempCalibrate.calibrationVoltage =  string.format("%.4f", setting.ui.profile.hardwareParamIterms[6].tempCalibrate:GetCalibrationVoltage())
            log:debug("[下机箱校准系数(V)-负输入分压-参考电压-校准电压] " ..  config.hardwareConfig.backupParam.fanDownTempCalibrate.negativeInput
                    .. ", "  .. config.hardwareConfig.backupParam.fanDownTempCalibrate.referenceVoltage
                    .. ", "  .. config.hardwareConfig.backupParam.fanDownTempCalibrate.calibrationVoltage)

            config.hardwareConfig.measureLed.period.real = string.format("%d", setting.ui.profile.hardwareParamIterms[9].period)
            config.hardwareConfig.motorOffsetStep.offsetStep.real = string.format("%d", setting.ui.profile.hardwareParamIterms[10].offsetStep)
            log:debug("[测量周期(ms)] " .. config.hardwareConfig.measureLed.period.real)
            log:debug("[进样偏移步数(ms)] " .. config.hardwareConfig.motorOffsetStep.offsetStep.real)

            ConfigLists.SaveHardwareConfig()
            log:info("参数备份成功")
            ret = true
        else
            log:warn("通信异常，参数备份失败")
        end

        return ret
    end,
}
