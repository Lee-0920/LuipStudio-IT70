setting.ui.useResourceWidget =
{
    rowCount = 4,
    superRow = 0,
    administratorRow = 0,
    writePrivilege=  RoleType.Maintain,
    readPrivilege = RoleType.Maintain,
    {
        name = "pumpPipe",
        text = "蠕动泵软管",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    {
        name = "liquidHalogenBottle",
        text = "液态卤素瓶",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    {
        name = "solidHalogenBottle",
        text = "固态卤素瓶",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    {
        name = "catalyst",
        text = "催化剂",
        writePrivilege=  RoleType.Maintain,
        readPrivilege = RoleType.Maintain,
    },
    checkMaterialLife = function()
       MaterialLifeManager.CheckAllMaterialLife()
    end,
    changeMaterialLife = function(name)
        MaterialLifeManager.Reset(setting.materialType[name])
    end,
}

return setting.ui.useResourceWidget
