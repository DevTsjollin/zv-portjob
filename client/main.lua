RegisterCommand("attach", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local coords = GetEntityCoords(PlayerPedId())
    local container = GetClosestObjectOfType(coords.xyz, 15.0, GetHashKey('prop_contr_03b_ld'), 1, 0, 1)
    if IsHandlerFrameAboveContainer(vehicle, container) then
        AttachContainerToHandlerFrame(vehicle, container)
    end
end, false)
RegisterCommand("detach", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local coords = GetEntityCoords(PlayerPedId())
    if IsAnyEntityAttachedToHandlerFrame(vehicle) then
        DetachContainerFromHandlerFrame(vehicle)
    end
end, false)
RegisterCommand("spawn", function()
    if not HasModelLoaded(GetHashKey('prop_contr_03b_ld')) then
        RequestModel(GetHashKey('prop_contr_03b_ld'))

        while not HasModelLoaded(GetHashKey('prop_contr_03b_ld')) do
            Wait(1)
        end
    end
    local object = CreateObject(GetHashKey('prop_contr_03b_ld'), -54.58629608154297, -2399.421875, 4.99999856948852, true, true, true)
    SetEntityAsMissionEntity(object, true, true)
end, false)
-- CreateThread(function()
--     while true do
--         local vehicle = GetVehiclePedIsIn(PlayerPedId())
--         local coords = GetEntityCoords(PlayerPedId())
--         local container = GetClosestObjectOfType(coords.xyz, 15.0, GetHashKey('prop_contr_03b_ld'), 1, 0, 1)
--         local above = IsHandlerFrameAboveContainer(vehicle, container)
--         if above then
--             print("gg")
--         end
--         Wait(0)
--     end
-- end)