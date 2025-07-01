setting.ui.reagentManager =
{
    rowCount = 6,
    writePrivilege=  RoleType.Maintain,
    readPrivilege = RoleType.Maintain,
    superRow = 0,
    administratorRow = 0,
    changeReagent = function(name, vol)
        ReagentRemainManager.ChangeReagent(setting.liquidType[name], vol)
    end,
    checkReagentDate = function()
       ReagentRemainManager.CheckAllReagentDate()
    end,
    {
        name = "blank",
        text = "零点校准液",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    {
        name = "standard",
        text = "量程校准液",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    {
        name = "zeroCheck",
        text = "零点核查液",
        --targetPrivilege = Target.EXTEND,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    {
        name = "rangeCheck",
        text = "标样(跨度)核查液",
        --targetPrivilege = Target.EXTEND,
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    {
        name = "waste",
        text = "分析废液",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    --{
    --    name = "wasteWater",
    --    text = "清洗废水",
    --    writePrivilege=  RoleType.Maintain,
    --    readPrivilege = RoleType.Maintain,
    --},
    {
        name = "reagent1",
        text = "试剂一",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    --{
    --    name = "reagent2",
    --    text = "试剂二",
    --    writePrivilege=  RoleType.Maintain,
    --    readPrivilege = RoleType.Maintain,
    --},
}

return setting.ui.reagentManager
