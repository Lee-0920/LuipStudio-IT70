setting.ui.measureDataPrint =
{
    showPrivilege=  RoleType.Administrator,
    measure =
    {
        printer = nil,
        totalWidth = 48,
        data =
        {
            {
                name = "measureFactor",
                header = " 参数 ",
                content = " TOC  ",
                width = 6,
            },
            {
                name = "dateTime",
                header = "     测量时间       ",
                format = "yyyy-MM-dd hh:mm:ss",
                width = 20,
            },
            {
                name = "consistency",
                header = " 浓度mg/L ",
                format = "%.3f",
                width = 10,
            },
            {
                name = "mode",
                header = "标识  ",
                width = 6,
            },
            {
                name = "resultType",
                header = "类型  ",
                width = 6,
            },
        },
    },
}

return setting.ui.measureDataPrint
