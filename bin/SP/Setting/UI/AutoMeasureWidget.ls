setting.ui.profile.scheduler =
{
    name = "scheduler",
    text = "测量排期",
    index = 1,
    rowCount = 31,
    superRow = 4,
    administratorRow = 2,
    isMeaParaml = false,
    writePrivilege=  RoleType.Maintain,
    readPrivilege = RoleType.Maintain,
    updateEvent = UpdateEvent.ChangeAutoMeasure,
    {
        name = "automeasurement",
        text = "水样测量",
        {
            name = "measure.mode",
            text = "测量模式",
            type = DataType.Option,
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            options =
            {
                "外部触发",
                "周期测量",
                "整点测量",
                "连续测量",
            },
        },
        {
            name = "measure.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.measure.interval)
                end
            end,
        },
        {
            name = "measure.timedPoint",
            text = "整点设置",
            type = DataType.IntArray,
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
        },
    },
    {
        name = "calibrate",
        text = "校准",
        {
            name = "calibrate.mode",
            text = "测量模式",
            type = DataType.Option,
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            options =
            {
                "外部触发",
                "周期测量",
                "整点测量",
            },
        },
        {
            name = "calibrate.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    if tonumber(value) > 0 then
                        return value
                    else
                        return string.format("%.1f", config.scheduler.calibrate.interval)
                    end

                else
                    return string.format("%.1f", config.scheduler.calibrate.interval)
                end
            end,
        },
        {
            name = "calibrate.oneTimedPoint",
            text = "整点设置",
            type = DataType.Int,
            unit = "(0~23)",
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            checkValue = function(value)
                if setting.ui.profile.scheduler.IntPattern(value) == true then
                    local num = tonumber(value)
                    if num < 0 or num > 23 then
                        return string.format("%d", config.scheduler.calibrate.oneTimedPoint)
                    else
                        return value
                    end
                else
                    return string.format("%d", config.scheduler.calibrate.oneTimedPoint)
                end
            end,
        },
        {
            name = "calibrate.timedPointInterval",
            text = "整点间隔时间",
            type = DataType.Int,
            unit = "天",
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            checkValue = function(value)
                if setting.ui.profile.scheduler.IntPattern(value) == true then
                    local num = tonumber(value)
                    if num <= 0 then
                        return string.format("%d", config.scheduler.calibrate.timedPointInterval)
                    else
                        return value
                    end
                else
                    return string.format("%d", config.scheduler.calibrate.timedPointInterval)
                end
            end,
        },
    },
    {
        name = "blankCheck",
        text = "测零点校准液",
        {
            name = "blankCheck.enable",
            text = "自动核查",
            type= DataType.Bool,
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
        },
        {
            name = "blankCheck.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.blankCheck.interval)
                end
            end,
        },
    },
    {
        name = "standard",
        text = "测量程校准液",
        {
            name = "standard.enable",
            text = "自动核查",
            type= DataType.Bool,
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
        },
        {
            name = "standard.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.standard.interval)
                end
            end,
        },
    },
    {
        name = "zeroCheck",
        text = "测零点核查液",
        {
            name = "zeroCheck.mode",
            text = "核查模式",
            type = DataType.Option,
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            options =
            {
                "外部触发",
                "周期测量",
                "整点测量",
            },
        },
        {
            name = "zeroCheck.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.zeroCheck.interval)
                end
            end,
        },
        {
            name = "rangeCheck.timedPoint",
            text = "整点设置",
            type = DataType.IntArray,
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
        },
    },
    {
        name = "rangeCheck",
        text = "测标样(跨度)核查液",
        {
            name = "rangeCheck.mode",
            text = "核查模式",
            type = DataType.Option,
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            options =
            {
                "外部触发",
                "周期测量",
                "整点测量",
            },
        },
        {
            name = "rangeCheck.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.rangeCheck.interval)
                end
            end,
        },
        {
            name = "rangeCheck.timedPoint",
            text = "整点设置",
            type = DataType.IntArray,
            writePrivilege=  RoleType.Maintain,
            readPrivilege = RoleType.Maintain,
        },
    },
    {
        name = "clean",
        text = "深度清洗",
        {
            name = "clean.enable",
            text = "自动清洗",
            type= DataType.Bool,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name = "clean.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.clean.interval)
                end
            end,
        },
    },
    {
        name = "collectSample",
        text = "反吹",
        {
            name = "collectSample.enable",
            text = "自动反吹",
            type= DataType.Bool,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name = "collectSample.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.collectSample.interval)
                end
            end,
        },
        {
            name = "collectSample.collectTime",
            text = "反吹时间",
            type = DataType.Int,
            unit = "秒",
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
            checkValue = function(value)
                if setting.ui.profile.scheduler.LongPattern(value) == true then
                    return value
                else
                    return string.format("%d", config.scheduler.collectSample.collectTime)
                end
            end,
        },
    },
    {
        name = "suckHalogenBottleWater",
        text = "排卤素液",
        {
            name = "suckHalogenBottleWater.enable",
            text = "自动排液",
            type= DataType.Bool,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
        {
            name = "suckHalogenBottleWater.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.suckHalogenBottleWater.interval)
                end
            end,
        },
    },
    {
        name = "airReplacement",
        text = "气体置换",
        {
            name = "airReplacement.enable",
            text = "自动换气",
            type= DataType.Bool,
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
        },
        {
            name = "airReplacement.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.airReplacement.interval)
                end
            end,
        },
    },
    {
        name = "quickMeasure",
        text = "快速测量",
        {
            name = "quickMeasure.mode",
            text = "测量模式",
            type = DataType.Option,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
            options =
            {
                "外部触发",
                "周期测量",
                "整点测量",
                "连续测量",
            },
        },
        {
            name = "quickMeasure.interval",
            text = "间隔周期",
            type = DataType.Float,
            unit = "小时",
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
            checkValue = function(value)
                if setting.ui.profile.scheduler.tempPattern(value) == true then
                    return value
                else
                    return string.format("%.1f", config.scheduler.quickMeasure.interval)
                end
            end,
        },
        {
            name = "quickMeasure.timedPoint",
            text = "整点设置",
            type = DataType.IntArray,
            writePrivilege=  RoleType.Super,
            readPrivilege = RoleType.Super,
        },
    },
    {
        name = "SchedulerSetting",
        text = "整点启动",
        {
            name = "timedPointJudgeTime",
            text = "判定延长时间",
            type = DataType.Int,
            unit = "秒",
            writePrivilege=  RoleType.Administrator,
            readPrivilege = RoleType.Administrator,
            checkValue = function(value)
                if setting.ui.profile.scheduler.IntPattern(value) == true then
                    local num = tonumber(value)
                    if num < 0 or num > 600 then
                        return string.format("%d", config.scheduler.timedPointJudgeTime)
                    else
                        return value
                    end
                else
                    return string.format("%d", config.scheduler.timedPointJudgeTime)
                end
            end,
        },
    },
    defaultRestore = function(userType)

        local defaultTable = ConfigLists.LoadSchedulerConfig(true)
        Helper.DefaultRestore(defaultTable, config.scheduler)
        local logger = Log.Instance():GetLogger()
        logger:info(Helper.GetRoleTypeStr().." 恢复默认"..setting.ui.profile.scheduler.text)
        config.modifyRecord.scheduler(true)
        ConfigLists.SaveSchedulerConfig()
    end,
    saveFile = function(isUpdate)
        local isChange = false
        local changeTable = {}
        local isRemind = false
        local remindStr = ""

        local logger = Log.Instance():GetLogger()
        logger:info(Helper.GetRoleTypeStr() .. " 修改".. setting.ui.profile.scheduler.text)
        isChange,changeTable=config.modifyRecord.scheduler(isUpdate)
        ConfigLists.SaveSchedulerConfig()

        --检测整点定标功能是否有更改
        if config.scheduler.calibrate.mode == MeasureMode.Timed then
            if changeTable ~= nil and type(changeTable) == "table" then
                for num,name in pairs(changeTable) do
                    if name == "calibrate.mode"
                            or name == "calibrate.oneTimedPoint"
                            or name == "calibrate.timedPointInterval" then
                        isRemind = true
                    end
                end
                if isRemind then
                    local curTime = os.time()
                    local curDateTime = os.date("*t", curTime)
                    curDateTime.hour    = 0
                    curDateTime.min     = 0
                    curDateTime.sec     = 0
                    local newTime = os.time(curDateTime)
                    status.measure.schedule.autoCalibrate.dateTime = newTime
                    config.scheduler.calibrate.configChangeTime = curTime
                    ConfigLists.SaveSchedulerConfig()
                    local isValid
                    local nextStartTime = 0
                    for i,tpye in pairs(setting.measureScheduler) do
                        if tpye.text == "校准" then
                            isValid,nextStartTime = tpye.getNextTime()
                            local DataTime = os.date("*t",nextStartTime)
                            remindStr = DataTime.year.."年"..DataTime.month.."月"..DataTime.day.."日"..DataTime.hour.."时"..DataTime.min.."分"..DataTime.sec.."秒"
                            remindStr = "检测到校准整点模式参数修改，下次启动校准的时间为 "..remindStr
                        end
                    end
                end
            end
        end

        return isRemind,remindStr
    end,
    tempPattern = function(value)
        if type(value) == "string" then
            local ret = false
            local decimalPatterm = "^%d?%d?%d%.%d$"
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
    IntPattern = function(value)
        if type(value) == "string" then
            local ret = false
            local integerPatterm = "^%d?%d?%d$"
            if string.find(value, integerPatterm) then
                ret = true
            end
            return ret
        else
            return false
        end
    end,
    LongPattern = function(value)
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
}

return setting.ui.profile.scheduler
