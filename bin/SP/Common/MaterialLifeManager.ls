local _G = _ENV

local os = os
local pcall = pcall
local type = type
local log = log
local setting = setting
local config = config
local ExceptionHandler = ExceptionHandler
local MaterialGoBadException = MaterialGoBadException

local P = {}
MaterialLifeManager = P
_ENV = P

local isPumpPipeGoBad = false
local isLiquidHalogenBottleGoBad = false
local isSolidHalogenBottleGoBad = false
local isCatalystGoBad = false


function Reset(material)
    if material == setting.materialType.pumpPipe then
        isPumpPipeGoBad = false
    end
    if material == setting.materialType.liquidHalogenBottle then
        isLiquidHalogenBottleGoBad = false
    end
    if material == setting.materialType.solidHalogenBottle then
        isSolidHalogenBottleGoBad = false
    end
    if material == setting.materialType.catalyst then
        isCatalystGoBad = false
    end
end

local function Check(material)

   local currentTime = os.time()

    if material == setting.materialType.pumpPipe then
        local temp = os.date("*t", config.consumable.pumpPipe.lastTime)
        temp.month = temp.month + config.consumable.pumpPipe.cycle

        local materialGoBadTime = currentTime
        local err,result = pcall(function() return os.time(temp) end)
        if not err then
            if type(result) == "string" then
                log:warn(result)
            else
                log:warn("MaterialLifeManager ==> Check(material) Error.")
            end
        else
            materialGoBadTime = result
            if materialGoBadTime - currentTime < 0 then
                ExceptionHandler.MakeAlarm(MaterialGoBadException:new({materialType = setting.materialType.pumpPipe,}))
                isPumpPipeGoBad = true
            end
        end

    end

    if material == setting.materialType.liquidHalogenBottle then
        local temp = os.date("*t", config.consumable.liquidHalogenBottle.lastTime)
        temp.month = temp.month + config.consumable.liquidHalogenBottle.cycle

        local materialGoBadTime = currentTime
        local err,result = pcall(function() return os.time(temp) end)
        if not err then
            if type(result) == "string" then
                log:warn(result)
            else
                log:warn("MaterialLifeManager ==> Check(material) Error.")
            end
        else
            materialGoBadTime = result
            if materialGoBadTime - currentTime < 0 then
                ExceptionHandler.MakeAlarm(MaterialGoBadException:new({materialType = setting.materialType.liquidHalogenBottle,}))
                isLiquidHalogenBottleGoBad = true
            end
        end

    end

    if material == setting.materialType.solidHalogenBottle then
        local temp = os.date("*t", config.consumable.solidHalogenBottle.lastTime)
        temp.month = temp.month + config.consumable.solidHalogenBottle.cycle

        local materialGoBadTime = currentTime
        local err,result = pcall(function() return os.time(temp) end)
        if not err then
            if type(result) == "string" then
                log:warn(result)
            else
                log:warn("MaterialLifeManager ==> Check(material) Error.")
            end
        else
            materialGoBadTime = result
            if materialGoBadTime - currentTime < 0 then
                ExceptionHandler.MakeAlarm(MaterialGoBadException:new({materialType = setting.materialType.solidHalogenBottle,}))
                isSolidHalogenBottleGoBad = true
            end
        end

    end

    if material == setting.materialType.catalyst then
        local temp = os.date("*t", config.consumable.catalyst.lastTime)
        temp.month = temp.month + config.consumable.catalyst.cycle

        local materialGoBadTime = currentTime
        local err,result = pcall(function() return os.time(temp) end)
        if not err then
            if type(result) == "string" then
                log:warn(result)
            else
                log:warn("MaterialLifeManager ==> Check(material) Error.")
            end
        else
            materialGoBadTime = result
            if materialGoBadTime - currentTime < 0 then
                ExceptionHandler.MakeAlarm(MaterialGoBadException:new({materialType = setting.materialType.catalyst,}))
                isCatalystGoBad = true
            end
        end

    end

end

function CheckAllMaterialLife()

    if not isPumpPipeGoBad then
        Check(setting.materialType.pumpPipe)
    end
    if not isLiquidHalogenBottleGoBad then
        Check(setting.materialType.liquidHalogenBottle)
    end
    if not isSolidHalogenBottleGoBad then
        Check(setting.materialType.solidHalogenBottle)
    end
    if not isCatalystGoBad then
        Check(setting.materialType.catalyst)
    end

    log:debug("check")

end

function RecoverMaterialLifeCheckStatus()
    isPumpPipeGoBad = false
    isLiquidHalogenBottleGoBad = false
    isSolidHalogenBottleGoBad = false
    isCatalystGoBad = false
end

return MaterialLifeManager
