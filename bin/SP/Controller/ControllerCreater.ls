
function  CreateControllers()
    local controllerManager = ControllerManager.Instance()
    for i, controller in pairs(setting.plugins.controllers) do
        local name = controller.name
        local text = controller.text
        local addr = DscpAddress.new(controller.address[1],  controller.address[2],  controller.address[3], controller.address[4])
        if type(name)  == "string" then
            if name == "TOCDriveControllerPlugin"then
                    dc = TOCDriveController.new(addr)
                    controllerManager:AddController(name, text, dc)
            end
        end

        addr = nil
    end
end

function  CreatePumps()

    pumps = {}
    for _,v in pairs(setting.liquidType)  do
        if v ~= setting.liquidType.map then
            if pumps[v.pump +1]  == nil then
                pump = PeristalticPump:new()
                pump.index =  v.pump
                pump.isRunning = false
                pump.peristalticPumpInterface = dc:GetIPeristalticPump()
                pumps[v.pump +1] = pump
            end
        end
    end
end

function  CreateOperator()
    op = Operator:new()
end

function  StopOperator()
    op:Stop()
end

