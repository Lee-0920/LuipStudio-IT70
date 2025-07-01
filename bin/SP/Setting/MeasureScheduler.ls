setting.measureScheduler=
{
    -- 1 校准  --
    {
        name ="Calibrate",
        text = "校准",

        --开启排期
        isOpen = function()
            local open =false
            local timedMeasureMode = false

            local mode = config.scheduler.calibrate.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                open =true
                timedMeasureMode = false
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                open =true
                timedMeasureMode = true
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                open =true
                timedMeasureMode = false
            elseif mode == MeasureMode.Trigger then                  -- 触发测量
                open =false
                timedMeasureMode = false
            elseif mode == MeasureMode.Manual then                  -- 手动测量
                open = false
                timedMeasureMode = false
            end

            return open, timedMeasureMode
        end,

        --优先级
        getPriority= function()
            return 1
        end,

        --排期周期
        getInterval = function()
            local interva = 0

            local mode = config.scheduler.calibrate.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                interva =  config.scheduler.calibrate.interval
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                interva = 0
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                local runTime = setting.runStatus.calibrate.GetTime()
                interva = runTime/3600
            end

            return interva
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.autoCalibrate.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            local isValid = false
            local nextTime = 0
            local mode = config.scheduler.calibrate.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = status.measure.schedule.autoCalibrate.dateTime + 3600 * config.scheduler.calibrate.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                local lastDateTime = os.date("*t", status.measure.schedule.autoCalibrate.dateTime)
                local configChangeTime = os.date("*t", config.scheduler.calibrate.configChangeTime)
                --log:debug("上次次启动时间 "..lastDateTime.day.." 日 "..lastDateTime.hour.." 时 "..lastDateTime.min.." 分 "..lastDateTime.sec.." 秒 ")
                local interval = config.scheduler.calibrate.timedPointInterval
                if configChangeTime.day == lastDateTime.day and configChangeTime.hour < config.scheduler.calibrate.oneTimedPoint then
                    interval = 0
                elseif configChangeTime.day == lastDateTime.day
                        and configChangeTime.hour == config.scheduler.calibrate.oneTimedPoint
                        and configChangeTime.min == 0
                        and configChangeTime.sec <= 1 then
                    interval = 0
                end
                lastDateTime.day = lastDateTime.day + interval
                lastDateTime.hour = config.scheduler.calibrate.oneTimedPoint
                lastDateTime.min = 0
                lastDateTime.sec = 0
                local nextStartTime = os.time(lastDateTime)

                if nextStartTime <= status.measure.schedule.autoCalibrate.dateTime then
                    lastDateTime = os.date("*t", status.measure.schedule.autoCalibrate.dateTime)
                    interval = config.scheduler.calibrate.timedPointInterval
                    lastDateTime.day = lastDateTime.day + interval
                    lastDateTime.hour = config.scheduler.calibrate.oneTimedPoint
                    lastDateTime.min = 0
                    lastDateTime.sec = 0
                    nextStartTime = os.time(lastDateTime)
                end

                --log:debug("下次启动时间 "..lastDateTime.day.." 日 "..lastDateTime.hour.." 时 ")

                nextTime = nextStartTime
                isValid = true
            elseif mode == MeasureMode.Continous then -- 连续测量
                nextTime = os.time()
                isValid = true
            elseif mode == MeasureMode.Trigger then -- 触发测量
                nextTime = 0
                isValid = true
            elseif mode == MeasureMode.Manual then -- 手动测量
                nextTime = 0
                isValid = true
            end

            return isValid, nextTime
        end,

        --掉电重测
        isRetry = function()
            return false
        end,

        --预测下次启动时间
        calculateNextTime = function(startTime, runTime)
            local isValid = false
            local nextTime = 0
            local mode = config.scheduler.calibrate.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = startTime  + 3600 * config.scheduler.calibrate.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                local lastDateTime = os.date("*t", startTime+runTime)
                local configChangeTime = os.date("*t", config.scheduler.calibrate.configChangeTime)

                local interval = config.scheduler.calibrate.timedPointInterval
                if configChangeTime.day == lastDateTime.day and configChangeTime.hour < config.scheduler.calibrate.oneTimedPoint and lastDateTime.hour <= config.scheduler.calibrate.oneTimedPoint then
                    interval = 0
                end

                lastDateTime.day = lastDateTime.day + interval
                lastDateTime.hour = config.scheduler.calibrate.oneTimedPoint
                lastDateTime.min = 0
                lastDateTime.sec = 0
                local nextStartTime = os.time(lastDateTime)
                --log:debug("预测下次启动时间 "..lastDateTime.day.." 日 "..lastDateTime.hour.." 时 ")
                nextTime = nextStartTime
                isValid = true
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                local runTime = setting.runStatus.calibrate.GetTime()
                nextTime = startTime  + runTime
                isValid = true
            end

            return isValid, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.calibrate.GetTime()
        end,

        --创建流程
        createFlow = function()
            --防止59s的时候启动（lua与C++的误差）
            if config.scheduler.calibrate.mode == MeasureMode.Timed then
                while true do
                    local curDateTime = os.date("*t", os.time())
                    if curDateTime.sec ~= 59 then
                        break
                    else
                        App.Sleep(200)
                    end
                end
            end
            log:debug("MeasureScheduler createFlow ==> CalibrateFlow:calibrate")
            local flow = CalibrateFlow:new({}, CalibrateType.calibrate)
            flow.name  = setting.measureScheduler[1].name
            FlowList.AddFlow(flow)
        end,
    },
    -- 2 跨度(标样)核查  --
    {
        name ="MeasureRangeCheck",
        text = "标样(跨度)核查",

        --开启排期
        isOpen = function()
            local open =false
            local timedMeasureMode = false

            local mode = config.scheduler.rangeCheck.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                open = true
                timedMeasureMode = false
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                open = true
                timedMeasureMode = true
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                open = false
                timedMeasureMode = false
            elseif mode == MeasureMode.Trigger then                  -- 触发测量
                open = false
                timedMeasureMode = false
            elseif mode == MeasureMode.Manual then                  -- 手动测量
                open = false
                timedMeasureMode = false
            end

            return open, timedMeasureMode
        end,

        --优先级
        getPriority= function()
            return 1
        end,

        --排期周期
        getInterval = function()
            local interva = 0

            local mode = config.scheduler.rangeCheck.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                interva =  config.scheduler.rangeCheck.interval
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                interva = 0
            end

            return interva
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.rangeCheck.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            local isValid = false
            local nextTime = 0
            local timeList = {}

            local mode = config.scheduler.rangeCheck.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = status.measure.schedule.rangeCheck.dateTime + 3600 * config.scheduler.rangeCheck.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                for i = 1,#config.scheduler.rangeCheck.timedPoint do
                    if config.scheduler.rangeCheck.timedPoint[i] == true then
                        table.insert(timeList, i - 1)
                    end
                end

                local curDateTime = os.date("*t", os.time())

                if #timeList > 0 then
                    local ret = false
                    for i = 1,#timeList do
                        if curDateTime.hour == timeList[i] and (curDateTime.min*60 + curDateTime.sec) <= config.scheduler.timedPointJudgeTime then  --避免刚好这个函数调用时过了0秒
                            curDateTime.hour = timeList[i]
                            curDateTime.min = 0
                            curDateTime.sec = 0

                            ret = true
                            break
                        elseif curDateTime.hour < timeList[i]  then
                            curDateTime.hour = timeList[i]
                            curDateTime.min = 0
                            curDateTime.sec = 0

                            ret = true
                            break
                        end
                    end

                    if ret == false then
                        curDateTime.day = curDateTime.day  + 1
                        curDateTime.hour = timeList[1]
                        curDateTime.min = 0
                        curDateTime.sec = 0
                    end

                    nextTime = os.time(curDateTime)
                    isValid = true
                end
            elseif mode == MeasureMode.Continous then -- 连续测量
                nextTime = 0
                isValid = true
            elseif mode == MeasureMode.Trigger then -- 触发测量
                nextTime = 0
                isValid = true
            elseif mode == MeasureMode.Manual then -- 手动测量
                nextTime = 0
                isValid = true
            end

            return isValid, nextTime
        end,

        --掉电重测
        isRetry = function()
            return false
        end,

        --预测下次启动时间
        calculateNextTime = function(startTime, runTime)
            local isValid = false
            local nextTime = 0
            local mode = config.scheduler.rangeCheck.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = startTime  + 3600 * config.scheduler.rangeCheck.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                local timeList = {}

                for i = 1,#config.scheduler.rangeCheck.timedPoint do
                    if config.scheduler.rangeCheck.timedPoint[i] == true then
                        table.insert(timeList, i - 1)
                    end
                end

                local dateTime = os.date("*t", startTime + runTime)

                if #timeList > 0 then
                    local ret = false
                    for i = 1,#timeList do
                        if dateTime.hour == timeList[i] and dateTime.min == 0 and dateTime.sec == 0 then
                            dateTime.hour = timeList[i]
                            dateTime.min = 0
                            dateTime.sec = 0

                            ret = true
                            break
                        elseif dateTime.hour < timeList[i]  then
                            dateTime.hour = timeList[i]
                            dateTime.min = 0
                            dateTime.sec = 0

                            ret = true
                            break
                        end
                    end

                    if ret == false then
                        dateTime.day = dateTime.day  + 1
                        dateTime.hour = timeList[1]
                        dateTime.min = 0
                        dateTime.sec = 0
                    end

                    nextTime = os.time(dateTime)
                    isValid = true
                end
            end

            return isValid, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.measureRangeCheck.GetTime()
        end,

        --创建流程
        createFlow = function()
            log:debug("MeasureScheduler createFlow ==> MeasureFlow:RangeCheck")
            local flow = MeasureFlow:new({},MeasureType.RangeCheck)
            flow.name  = setting.measureScheduler[2].name
            flow.adjustTime = true
            FlowList.AddFlow(flow)
        end,
    },
    -- 3 零点核查  --
    {
        name ="MeasureZeroCheck",
        text = "零点核查",

        --开启排期
        isOpen = function()
            local open =false
            local timedMeasureMode = false

            local mode = config.scheduler.zeroCheck.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                open = true
                timedMeasureMode = false
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                open = true
                timedMeasureMode = true
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                open = false
                timedMeasureMode = false
            elseif mode == MeasureMode.Trigger then                  -- 触发测量
                open = false
                timedMeasureMode = false
            elseif mode == MeasureMode.Manual then                  -- 手动测量
                open = false
                timedMeasureMode = false
            end

            return open, timedMeasureMode
        end,

        --优先级
        getPriority= function()
            return 0
        end,

        --排期周期
        getInterval = function()
            local interva = 0

            local mode = config.scheduler.zeroCheck.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                interva =  config.scheduler.zeroCheck.interval
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                interva = 0
            end

            return interva
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.zeroCheck.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            local isValid = false
            local nextTime = 0
            local timeList = {}

            local mode = config.scheduler.zeroCheck.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = status.measure.schedule.zeroCheck.dateTime + 3600 * config.scheduler.zeroCheck.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                for i = 1,#config.scheduler.zeroCheck.timedPoint do
                    if config.scheduler.zeroCheck.timedPoint[i] == true then
                        table.insert(timeList, i - 1)
                    end
                end

                local curDateTime = os.date("*t", os.time())

                if #timeList > 0 then
                    local ret = false
                    for i = 1,#timeList do
                        if curDateTime.hour == timeList[i] and (curDateTime.min*60 + curDateTime.sec) <= config.scheduler.timedPointJudgeTime then  --避免刚好这个函数调用时过了0秒
                            curDateTime.hour = timeList[i]
                            curDateTime.min = 0
                            curDateTime.sec = 0

                            ret = true
                            break
                        elseif curDateTime.hour < timeList[i]  then
                            curDateTime.hour = timeList[i]
                            curDateTime.min = 0
                            curDateTime.sec = 0

                            ret = true
                            break
                        end
                    end

                    if ret == false then
                        curDateTime.day = curDateTime.day  + 1
                        curDateTime.hour = timeList[1]
                        curDateTime.min = 0
                        curDateTime.sec = 0
                    end

                    nextTime = os.time(curDateTime)
                    isValid = true
                end
            elseif mode == MeasureMode.Continous then -- 连续测量
                nextTime = 0
                isValid = true
            elseif mode == MeasureMode.Trigger then -- 触发测量
                nextTime = 0
                isValid = true
            elseif mode == MeasureMode.Manual then -- 手动测量
                nextTime = 0
                isValid = true
            end

            return isValid, nextTime
        end,

        --掉电重测
        isRetry = function()
            return false
        end,

        --预测下次启动时间
        calculateNextTime = function(startTime, runTime)
            local isValid = false
            local nextTime = 0
            local mode = config.scheduler.zeroCheck.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = startTime  + 3600 * config.scheduler.zeroCheck.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                local timeList = {}

                for i = 1,#config.scheduler.zeroCheck.timedPoint do
                    if config.scheduler.zeroCheck.timedPoint[i] == true then
                        table.insert(timeList, i - 1)
                    end
                end

                local dateTime = os.date("*t", startTime + runTime)

                if #timeList > 0 then
                    local ret = false
                    for i = 1,#timeList do
                        if dateTime.hour == timeList[i] and dateTime.min == 0 and dateTime.sec == 0 then
                            dateTime.hour = timeList[i]
                            dateTime.min = 0
                            dateTime.sec = 0

                            ret = true
                            break
                        elseif dateTime.hour < timeList[i]  then
                            dateTime.hour = timeList[i]
                            dateTime.min = 0
                            dateTime.sec = 0

                            ret = true
                            break
                        end
                    end

                    if ret == false then
                        dateTime.day = dateTime.day  + 1
                        dateTime.hour = timeList[1]
                        dateTime.min = 0
                        dateTime.sec = 0
                    end

                    nextTime = os.time(dateTime)
                    isValid = true
                end
            end

            return isValid, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.measureZeroCheck.GetTime()
        end,

        --创建流程
        createFlow = function()
            log:debug("MeasureScheduler createFlow ==> MeasureFlow:ZeroCheck")
            local flow = MeasureFlow:new({}, MeasureType.ZeroCheck)
            flow.name  = setting.measureScheduler[3].name
            flow.adjustTime = true
            FlowList.AddFlow(flow)
        end,
    },
    -- 4  测量水样  --
    {
        name ="MeasureSample",
        text = "测量水样",

        --开启排期
        isOpen = function()
            local open =false
            local timedMeasureMode = false

            local mode = config.scheduler.measure.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                open =true
                timedMeasureMode = false
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                open =true
                timedMeasureMode = true
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                open =true
                timedMeasureMode = false
            elseif mode == MeasureMode.Trigger then                  -- 触发测量
                open =false
                timedMeasureMode = false
            elseif mode == MeasureMode.Manual then                  -- 手动测量
                open = false
                timedMeasureMode = false
            end

            return open, timedMeasureMode
        end,

        --优先级
        getPriority= function()
            local priority = 2

            if config.scheduler.measure.mode == MeasureMode.Continous then
                priority = 20
            end

            return priority
        end,

        --排期周期
        getInterval = function()
            local interva = 0

            local mode = config.scheduler.measure.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                interva =  config.scheduler.measure.interval
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                interva = 0
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                local runTime = setting.runStatus.measureSample.GetTime()
                interva = runTime/3600
            end

            return interva
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.autoMeasure.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            local isValid = false
            local nextTime = 0
            local timeList = {}

            local mode = config.scheduler.measure.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = status.measure.schedule.autoMeasure.dateTime + 3600 * config.scheduler.measure.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                for i = 1,#config.scheduler.measure.timedPoint do
                    if config.scheduler.measure.timedPoint[i] == true then
                        table.insert(timeList, i - 1)
                    end
                end

                local curDateTime = os.date("*t", os.time())

                if #timeList > 0 then
                    local ret = false
                    for i = 1,#timeList do
                        if curDateTime.hour == timeList[i] and (curDateTime.min*60 + curDateTime.sec) <= config.scheduler.timedPointJudgeTime then  --避免刚好这个函数调用时过了0秒
                            curDateTime.hour = timeList[i]
                            curDateTime.min = 0
                            curDateTime.sec = 0

                            ret = true
                            break
                        elseif curDateTime.hour < timeList[i]  then
                            curDateTime.hour = timeList[i]
                            curDateTime.min = 0
                            curDateTime.sec = 0

                            ret = true
                            break
                        end
                    end

                    if ret == false then
                        curDateTime.day = curDateTime.day  + 1
                        curDateTime.hour = timeList[1]
                        curDateTime.min = 0
                        curDateTime.sec = 0
                    end

                    nextTime = os.time(curDateTime)
                    isValid = true
                end
            elseif mode == MeasureMode.Continous then -- 连续测量
                nextTime = os.time()
                isValid = true
            elseif mode == MeasureMode.Trigger then -- 触发测量
                nextTime = 0
                isValid = true
            elseif mode == MeasureMode.Manual then -- 手动测量
                nextTime = 0
                isValid = true
            end

            return isValid, nextTime
        end,

        --掉电重测
        isRetry = function()
            return status.running.isMeasuring
        end,

        --预测下次启动时间
        calculateNextTime = function(startTime, runTime)
            local isValid = false
            local nextTime = 0
            local mode = config.scheduler.measure.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = startTime  + 3600 * config.scheduler.measure.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                local timeList = {}

                for i = 1,#config.scheduler.measure.timedPoint do
                    if config.scheduler.measure.timedPoint[i] == true then
                        table.insert(timeList, i - 1)
                    end
                end

                local dateTime = os.date("*t", startTime + runTime)

                if #timeList > 0 then
                    local ret = false
                    for i = 1,#timeList do
                        if dateTime.hour == timeList[i] and dateTime.min == 0 and dateTime.sec == 0 then
                            dateTime.hour = timeList[i]
                            dateTime.min = 0
                            dateTime.sec = 0

                            ret = true
                            break
                        elseif dateTime.hour < timeList[i]  then
                            dateTime.hour = timeList[i]
                            dateTime.min = 0
                            dateTime.sec = 0

                            ret = true
                            break
                        end
                    end

                    if ret == false then
                        dateTime.day = dateTime.day  + 1
                        dateTime.hour = timeList[1]
                        dateTime.min = 0
                        dateTime.sec = 0
                    end

                    nextTime = os.time(dateTime)
                    isValid = true
                end
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                local runTime = setting.runStatus.measureSample.GetTime()
                nextTime = startTime  + runTime
                isValid = true
            end

            return isValid, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.measureSample.GetTime()
        end,

        --创建流程
        createFlow = function()
            --防止59s的时候启动
            if config.scheduler.measure.mode == MeasureMode.Timed then
                while true do
                    local curDateTime = os.date("*t", os.time())
                    if curDateTime.sec ~= 59 then
                        break
                    else
                        App.Sleep(200)
                    end
                end
            end

            log:debug("MeasureScheduler createFlow ==> MeasureFlow:Sample")
            local flow = MeasureFlow:new({}, MeasureType.Sample)
            flow.name  = setting.measureScheduler[4].name
            flow.adjustTime = true
            if status.running.isMeasuring == true then
                local osRunTime = App.GetOSRunTime()
                if osRunTime > 300 then
                    flow.isCrashMeasure = true --程序崩溃重启
                end
            end
            FlowList.AddFlow(flow)
        end,
    },
    -- 5 量程校准液核查  --
    {
        name ="MeasureStandard",
        text = "测量程校准液",

        --开启排期
        isOpen = function()
            return config.scheduler.standard.enable, false
        end,

        --优先级
        getPriority= function()
            return 3
        end,

        --排期周期
        getInterval = function()
            return config.scheduler.standard.interval
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.autoCheck.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            return true, status.measure.schedule.autoCheck.dateTime + 3600 * config.scheduler.standard.interval
        end,

        --掉电重测
        isRetry = function()
            return false
        end,

        --预测下次启动时间
        calculateNextTime = function(startTime, runTime)
            local nextTime = startTime  + 3600 * config.scheduler.standard.interval
            return true, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.measureStandard.GetTime()
        end,

        --创建流程
        createFlow = function()
            log:debug("MeasureScheduler createFlow ==> MeasureFlow:Standard")
            local flow = MeasureFlow:new({}, MeasureType.Standard)
            flow.name  = setting.measureScheduler[5].name
            FlowList.AddFlow(flow)
        end,
    },
    --6 清洗  --
    {
        name ="Clean",
        text = "清洗",

        --开启排期
        isOpen = function()
            return config.scheduler.clean.enable, false
        end,

        --优先级
        getPriority= function()
            return 10
        end,

        --排期周期
        getInterval = function()
            return config.scheduler.clean.interval
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.autoClean.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            return true, status.measure.schedule.autoClean.dateTime + 3600 * config.scheduler.clean.interval
        end,

        --掉电重测
        isRetry = function()
            return false
        end,

        --预测下次启动时间
        calculateNextTime = function(startTime, runTime)
            local nextTime = startTime  + 3600 * config.scheduler.clean.interval
            return true, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.cleanDeeply.GetTime()
        end,

        --创建流程
        createFlow= function()
            log:debug("MeasureScheduler createFlow ==> CleanFlow:cleanDeeply")
            local flow = CleanFlow:new({},cleanType.cleanDeeply)
            flow.name  = setting.measureScheduler[6].name
            FlowList.AddFlow(flow)
        end,
    },
    -- 7 测零点校准液  --
    {
        name ="MeasureBlank",
        text = "测零点校准液",

        --开启排期
        isOpen = function()
            return config.scheduler.blankCheck.enable, false
        end,

        --优先级
        getPriority= function()
            return 5
        end,

        --排期周期
        getInterval = function()
            return config.scheduler.blankCheck.interval
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.autoBlankCheck.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            return true, status.measure.schedule.autoBlankCheck.dateTime + 3600 * config.scheduler.blankCheck.interval
        end,

        --掉电重测
        isRetry = function()
            return false
        end,

        --预测下次启动时间

        calculateNextTime = function(startTime, runTime)
            local nextTime = startTime  + 3600 * config.scheduler.blankCheck.interval
            return true, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.measureBlank.GetTime()
        end,

        --创建流程
        createFlow = function()
            log:debug("MeasureScheduler createFlow ==> MeasureFlow:Blank")
            local flow = MeasureFlow:new({}, MeasureType.Blank)
            flow.name  = setting.measureScheduler[7].name
            FlowList.AddFlow(flow)
        end,
    },
    -- 8 排卤素液
    {
        name ="SuckHalogenBottleWater",
        text = "排卤素液",

        --开启排期
        isOpen = function()
            return config.scheduler.suckHalogenBottleWater.enable, false
        end,

        --优先级
        getPriority= function()
            return 2
        end,

        --排期周期
        getInterval = function()
            return config.scheduler.suckHalogenBottleWater.interval
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.autoSuckHalogenBottleWater.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            return true, status.measure.schedule.autoSuckHalogenBottleWater.dateTime + 3600 * config.scheduler.suckHalogenBottleWater.interval
        end,

        --掉电重测
        isRetry = function()
            return false
        end,

        --预测下次启动时间

        calculateNextTime = function(startTime, runTime)
            local nextTime = startTime  + 3600 * config.scheduler.suckHalogenBottleWater.interval
            return true, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.suckHalogenBottleWater.GetTime()
        end,

        --创建流程
        createFlow = function()
            log:debug("MeasureScheduler createFlow ==> CleanFlow:suckHalogenBottleWater")
            local flow = CleanFlow:new({},cleanType.suckHalogenBottleWater)
            flow.name  = setting.measureScheduler[8].name
            FlowList.AddFlow(flow)
        end,
    },
    -- 9 周期采样
    {
        name ="CollectSample",
        text = "反吹",

        --开启排期
        isOpen = function()
            return config.scheduler.collectSample.enable, false
        end,

        --优先级
        getPriority= function()
            return 2
        end,

        --排期周期
        getInterval = function()
            return config.scheduler.collectSample.interval
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.autoCollectSample.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            return true, status.measure.schedule.autoCollectSample.dateTime + 3600 * config.scheduler.collectSample.interval
        end,

        --掉电重测
        isRetry = function()
            return false
        end,

        --预测下次启动时间

        calculateNextTime = function(startTime, runTime)
            local nextTime = startTime  + 3600 * config.scheduler.collectSample.interval
            return true, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.collectSample.GetTime()
        end,

        --创建流程
        createFlow = function()
            log:debug("MeasureScheduler createFlow ==> SampleWaterRelay")
            local flow = CollectSampleFlow:new({},true)
            flow.name  = "SampleWaterRelay"
            FlowList.AddFlow(flow)
        end,
    },
    ---- 9 催化剂活化
    --{
    --    name ="CatalystActive",
    --    text = "催化剂活化",
    --
    --    --开启排期
    --    isOpen = function()
    --        return config.scheduler.catalystActive.enable, false
    --    end,
    --
    --    --优先级
    --    getPriority= function()
    --        return 8
    --    end,
    --
    --    --排期周期
    --    getInterval = function()
    --        return config.scheduler.catalystActive.interval
    --    end,
    --
    --    --上次启动时间
    --    getLastTime = function()
    --        return status.measure.schedule.autoCatalystActive.dateTime
    --    end,
    --
    --    --下次启动时间
    --    getNextTime = function()
    --        return true, status.measure.schedule.autoCatalystActive.dateTime + 3600 * config.scheduler.catalystActive.interval
    --    end,
    --
    --    --掉电重测
    --    isRetry = function()
    --        return false
    --    end,
    --
    --    --预测下次启动时间
    --
    --    calculateNextTime = function(startTime, runTime)
    --        local nextTime = startTime  + 3600 * config.scheduler.catalystActive.interval
    --        return true, nextTime
    --    end,
    --
    --    --流程运行用时
    --    getRunTime = function()
    --        return setting.runStatus.catalystActive.GetTime()
    --    end,
    --
    --    --创建流程
    --    createFlow = function()
    --        log:debug("MeasureScheduler createFlow ==> CleanFlow:catalystActive")
    --        local flow = CleanFlow:new({},cleanType.catalystActive)
    --        flow.name  = setting.measureScheduler[9].name
    --        FlowList.AddFlow(flow)
    --    end,
    --},
    -- 10 快速测量
    {
        name ="QuickMeasure",
        text = "快速测量",

        --开启排期
        isOpen = function()
            local open =false
            local timedMeasureMode = false

            local mode = config.scheduler.quickMeasure.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                open =true
                timedMeasureMode = false
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                open =true
                timedMeasureMode = true
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                open =true
                timedMeasureMode = false
            elseif mode == MeasureMode.Trigger then                  -- 触发测量
                open =false
                timedMeasureMode = false
            elseif mode == MeasureMode.Manual then                  -- 手动测量
                open = false
                timedMeasureMode = false
            end

            return open, timedMeasureMode
        end,

        --优先级
        getPriority= function()
            local priority = 2

            if config.scheduler.quickMeasure.mode == MeasureMode.Continous then
                priority = 20
            end

            return priority
        end,

        --排期周期
        getInterval = function()
            local interva = 0

            local mode = config.scheduler.quickMeasure.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                interva =  config.scheduler.quickMeasure.interval
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                interva = 0
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                local runTime = setting.runStatus.measureSample.GetTime()
                interva = runTime/3600
            end

            return interva
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.autoQuickMeasure.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            local isValid = false
            local nextTime = 0
            local timeList = {}

            local mode = config.scheduler.quickMeasure.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = status.measure.schedule.autoQuickMeasure.dateTime + 3600 * config.scheduler.quickMeasure.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                for i = 1,#config.scheduler.quickMeasure.timedPoint do
                    if config.scheduler.quickMeasure.timedPoint[i] == true then
                        table.insert(timeList, i - 1)
                    end
                end

                local curDateTime = os.date("*t", os.time())

                if #timeList > 0 then
                    local ret = false
                    for i = 1,#timeList do
                        if curDateTime.hour == timeList[i] and curDateTime.min == 0 and curDateTime.sec <= 5 then  --避免刚好这个函数调用时过了0秒
                            curDateTime.hour = timeList[i]
                            curDateTime.min = 0
                            curDateTime.sec = 0

                            ret = true
                            break
                        elseif curDateTime.hour < timeList[i]  then
                            curDateTime.hour = timeList[i]
                            curDateTime.min = 0
                            curDateTime.sec = 0

                            ret = true
                            break
                        end
                    end

                    if ret == false then
                        curDateTime.day = curDateTime.day  + 1
                        curDateTime.hour = timeList[1]
                        curDateTime.min = 0
                        curDateTime.sec = 0
                    end

                    nextTime = os.time(curDateTime)
                    isValid = true
                end
            elseif mode == MeasureMode.Continous then -- 连续测量
                nextTime = os.time()
                isValid = true
            elseif mode == MeasureMode.Trigger then -- 触发测量
                nextTime = 0
                isValid = true
            elseif mode == MeasureMode.Manual then -- 手动测量
                nextTime = 0
                isValid = true
            end

            return isValid, nextTime
        end,

        --掉电重测
        isRetry = function()
            return status.running.isMeasuring
        end,

        --预测下次启动时间
        calculateNextTime = function(startTime, runTime)
            local isValid = false
            local nextTime = 0
            local mode = config.scheduler.quickMeasure.mode

            if mode == MeasureMode.Periodic then                            -- 周期测量
                nextTime = startTime  + 3600 * config.scheduler.quickMeasure.interval
                isValid = true
            elseif mode == MeasureMode.Timed then                       -- 整点测量
                local timeList = {}

                for i = 1,#config.scheduler.quickMeasure.timedPoint do
                    if config.scheduler.quickMeasure.timedPoint[i] == true then
                        table.insert(timeList, i - 1)
                    end
                end

                local dateTime = os.date("*t", startTime + runTime)

                if #timeList > 0 then
                    local ret = false
                    for i = 1,#timeList do
                        if dateTime.hour == timeList[i] and dateTime.min == 0 and dateTime.sec == 0 then
                            dateTime.hour = timeList[i]
                            dateTime.min = 0
                            dateTime.sec = 0

                            ret = true
                            break
                        elseif dateTime.hour < timeList[i]  then
                            dateTime.hour = timeList[i]
                            dateTime.min = 0
                            dateTime.sec = 0

                            ret = true
                            break
                        end
                    end

                    if ret == false then
                        dateTime.day = dateTime.day  + 1
                        dateTime.hour = timeList[1]
                        dateTime.min = 0
                        dateTime.sec = 0
                    end

                    nextTime = os.time(dateTime)
                    isValid = true
                end
            elseif mode == MeasureMode.Continous then                    -- 连续测量
                local runTime = 300
                nextTime = startTime  + runTime
                isValid = true
            end

            return isValid, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return 300
        end,

        --创建流程
        createFlow = function()
            --防止59s的时候启动
            if config.scheduler.quickMeasure.mode == MeasureMode.Timed then
                while true do
                    local curDateTime = os.date("*t", os.time())
                    if curDateTime.sec ~= 59 then
                        break
                    else
                        App.Sleep(200)
                    end
                end
            end

            log:debug("MeasureScheduler createFlow ==> MeasureFlow:QuickMeasure")
            local flow = QuickMeasureFlow:new({}, MeasureType.Sample)
            flow.name  = "QuickMeasure"
            flow.adjustTime = true
            if status.running.isMeasuring == true then
                local osRunTime = App.GetOSRunTime()
                if osRunTime > 300 then
                    flow.isCrashMeasure = true --程序崩溃重启
                end
            end
            FlowList.AddFlow(flow)
        end,
    },
    -- 11 气体置换
    {
        name ="AirReplacement",
        text = "气体置换",

        --开启排期
        isOpen = function()
            return config.scheduler.airReplacement.enable, false
        end,

        --优先级
        getPriority= function()
            return 2
        end,

        --排期周期
        getInterval = function()
            return config.scheduler.airReplacement.interval
        end,

        --上次启动时间
        getLastTime = function()
            return status.measure.schedule.autoAirReplacement.dateTime
        end,

        --下次启动时间
        getNextTime = function()
            return true, status.measure.schedule.autoAirReplacement.dateTime + 3600 * config.scheduler.airReplacement.interval
        end,

        --掉电重测
        isRetry = function()
            return false
        end,

        --预测下次启动时间

        calculateNextTime = function(startTime, runTime)
            local nextTime = startTime  + 3600 * config.scheduler.airReplacement.interval
            return true, nextTime
        end,

        --流程运行用时
        getRunTime = function()
            return setting.runStatus.airReplacement.GetTime()
        end,

        --创建流程
        createFlow = function()
            log:debug("MeasureScheduler createFlow ==> CleanFlow:airReplacement")
            local flow = CleanFlow:new({},cleanType.airReplacement)
            flow.name  = "AirReplacement"
            FlowList.AddFlow(flow)
        end,
    },
    ----8  测加标样  --
    --{
    --    name ="MeasureAddstandard ",
    --    text = "测加标样",
    --
    --    --开启排期
    --    isOpen = function()
    --        return config.scheduler.addstandard.enable, false
    --    end,
    --
    --    --优先级
    --    getPriority= function()
    --        return 6
    --    end,
    --
    --    --排期周期
    --    getInterval = function()
    --        return config.scheduler.addstandard.interval
    --    end,
    --
    --    --上次启动时间
    --    getLastTime = function()
    --        return status.measure.schedule.autoAddstandard.dateTime
    --    end,
    --
    --    --下次启动时间
    --    getNextTime = function()
    --        return true, status.measure.schedule.autoAddstandard.dateTime + 3600 * config.scheduler.addstandard.interval
    --    end,
    --
    --    --掉电重测
    --    isRetry = function()
    --        return false
    --    end,
    --
    --    --预测下次启动时间
    --    calculateNextTime = function(startTime, runTime)
    --        local nextTime = startTime  + 3600 * config.scheduler.addstandard.interval
    --        return true, nextTime
    --    end,
    --
    --    --流程运行用时
    --    getRunTime = function()
    --        return setting.runStatus.measureAddstandard.GetTime()
    --    end,
    --
    --    --创建流程
    --    createFlow = function()
    --        log:debug("MeasureScheduler createFlow ==> MeasureFlow:Addstandard")
    --        local flow = MeasureFlow:new({}, MeasureType.Addstandard)
    --        flow.name  = setting.measureScheduler[8].name
    --        FlowList.AddFlow(flow)
    --    end,
    --},
    ----9  测平行样  --
    --{
    --    name ="MeasureParallel ",
    --    text = "测平行样",
    --
    --    --开启排期
    --    isOpen = function()
    --        return config.scheduler.parallel.enable, false
    --    end,
    --
    --    --优先级
    --    getPriority= function()
    --        return 7
    --    end,
    --
    --    --排期周期
    --    getInterval = function()
    --        return config.scheduler.parallel.interval
    --    end,
    --
    --    --上次启动时间
    --    getLastTime = function()
    --        return status.measure.schedule.autoParallel.dateTime
    --    end,
    --
    --    --下次启动时间
    --    getNextTime = function()
    --        return true, status.measure.schedule.autoParallel.dateTime + 3600 * config.scheduler.parallel.interval
    --    end,
    --
    --    --掉电重测
    --    isRetry = function()
    --        return false
    --    end,
    --
    --    --预测下次启动时间
    --    calculateNextTime = function(startTime, runTime)
    --        local nextTime = startTime  + 3600 * config.scheduler.parallel.interval
    --        return true, nextTime
    --    end,
    --
    --    --流程运行用时
    --    getRunTime = function()
    --        return setting.runStatus.measureParallel.GetTime()
    --    end,
    --
    --    --创建流程
    --    createFlow = function()
    --        log:debug("MeasureScheduler createFlow ==> MeasureFlow:Parallel")
    --        local flow = MeasureFlow:new({}, MeasureType.Parallel)
    --        flow.name  = setting.measureScheduler[9].name
    --        FlowList.AddFlow(flow)
    --    end,
    --},
}