local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local containerland = true
RegisterCommand("attach", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local coords = GetEntityCoords(PlayerPedId())
    local container = GetClosestObjectOfType(coords.xyz, 15.0, GetHashKey('prop_contr_03b_ld'), 1, 0, 1)
    if not IsAnyEntityAttachedToHandlerFrame(vehicle) then
        if IsVehicleDriveable(vehicle, 0) then
            if DoesEntityExist(container) then
                if IsHandlerFrameAboveContainer(vehicle, container) then
                    if RequestScriptAudioBank("Container_Lifter", 0) then
                        PlaySoundFromEntity(GetSoundId(), "Container_Attach", vehicle, "CONTAINER_LIFTER_SOUNDS", 0, 0)
                    end
                    AttachContainerToHandlerFrame(vehicle, container)
                end
            end
        end
    end
end, false)
RegisterCommand("detach", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    local coords = GetEntityCoords(PlayerPedId())
    if IsVehicleDriveable(vehicle, 0) then
        if IsAnyEntityAttachedToHandlerFrame(vehicle) then
            if RequestScriptAudioBank("Container_Lifter", 0) then
                PlaySoundFromEntity(GetSoundId(), "Container_Release", vehicle, "CONTAINER_LIFTER_SOUNDS", 0, 0)
            end
            DetachContainerFromHandlerFrame(vehicle)
            containerland = false
        end
    end
end, false)
RegisterCommand("spawn", function()
    if not HasModelLoaded(GetHashKey('prop_contr_03b_ld')) then
        RequestModel(GetHashKey('prop_contr_03b_ld'))

        while not HasModelLoaded(GetHashKey('prop_contr_03b_ld')) do
            Wait(1)
        end
    end
    local object = CreateObject(GetHashKey('prop_contr_03b_ld'), -54.58629608154297, -2399.421875, 4.99999856948852, true, true, false)
    SetEntityAsMissionEntity(object, true, true)
end, false)

CreateThread(function()
    while true do
        local vehicle = GetVehiclePedIsIn(PlayerPedId())
        local coords = GetEntityCoords(PlayerPedId())
        if not containerland then
            if not IsAnyEntityAttachedToHandlerFrame(vehicle) then
                local container = GetClosestObjectOfType(coords.xyz, 15.0, GetHashKey('prop_contr_03b_ld'), 1, 0, 1)
                if HasEntityCollidedWithAnything(container) then
                    if RequestScriptAudioBank("Container_Lifter", 0) then
                        PlaySoundFromEntity(GetSoundId(), "Container_Land", vehicle, "CONTAINER_LIFTER_SOUNDS", 0, 0)
                    end
                    containerland = true
                end
            end
        end
        Wait(0)
    end
end)