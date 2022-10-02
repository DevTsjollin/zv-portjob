local PlayerJob = {}
local MainBlip, HandlerBlip
local showMarker = false
local markerLocation
local selectedVeh = nil

-- Functions

function ShowHelpNotification(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local containerland = true
local pickedup = false

local function RemoveHarbourBlips()
    if MainBlip then
        RemoveBlip(MainBlip)
        MainBlip = nil
    end

    if HandlerBlip then
        RemoveBlip(HandlerBlip)
        HandlerBlip = nil
    end
end

local function ShowMarker(active)
    if PlayerJob.name ~= "harbour" then return end
    showMarker = active
end

local function CreateZone(type, number)
    local coords
    local heading
    local boxName
    local event
    local label
    local size

    if type == "main" then
        event = "zv-harbourjob:client:PaySlip"
        label = "Payslip"
        coords = vector3(cfg.Locations[type].coords.xyz)
        heading = cfg.Locations[type].coords.h
        boxName = cfg.Locations[type].label
        size = 3
    elseif type == "handler" then
        event = "zv-harbourjob:client:Handler"
        label = "Handler"
        coords = vector3(cfg.Locations[type].coords.xyz)
        heading = cfg.Locations[type].coords.h
        boxName = cfg.Locations[type].label
        size = 5
    end

    if cfg.interaction == "qb-target" and type == "main" then
        exports['qb-target']:AddBoxZone(boxName, coords, size, size, {
            minZ = coords.z - 5.0,
            maxZ = coords.z + 5.0,
            name = boxName,
            heading = heading,
            debugPoly = false,
        }, {
            options = {
                {
                    type = "client",
                    event = event,
                    label = label,
                },
            },
            distance = 2
        })
    else
        local zone = BoxZone:Create(
            coords, size, size, {
                minZ = coords.z - 5.0,
                maxZ = coords.z + 5.0,
                name = boxName,
                debugPoly = false,
                heading = heading,
            })

        zoneCombo = ComboZone:Create({zone}, {name = boxName, debugPoly = false})
        zoneCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                if type == "main" then
                    TriggerEvent('zv-harbourjob:client:PaySlip')
                elseif type == "handler" then
                    TriggerEvent('zv-harbourjob:client:Handler')
                end
            end
        end)
        if type == "handler" then
            local zonedel = BoxZone:Create(
                coords, 40, 40, {
                    minZ = coords.z - 5.0,
                    maxZ = coords.z + 5.0,
                    name = boxName,
                    debugPoly = false,
                    heading = heading,
                })

            local zoneCombodel = ComboZone:Create({zonedel}, {name = boxName, debugPoly = false})
            zoneCombodel:onPlayerInOut(function(isPointInside)
                if isPointInside then
                    markerLocation = coords
                    ShowMarker(true)
                else
                    ShowMarker(false)
                end
            end)
        end
    end
end

local function CreateElements()
    MainBlip = AddBlipForCoord(cfg.Locations["main"].coords.xyz)
    SetBlipSprite(MainBlip, cfg.Locations["main"].sprite)
    SetBlipDisplay(MainBlip, cfg.Locations["main"].display)
    SetBlipScale(MainBlip, cfg.Locations["main"].scale)
    SetBlipAsShortRange(MainBlip, true)
    SetBlipColour(MainBlip, cfg.Locations["main"].colour)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(cfg.Locations["main"].label)
    EndTextCommandSetBlipName(MainBlip)

    HandlerBlip = AddBlipForCoord(cfg.Locations["handler"].coords.xyz)
    SetBlipSprite(HandlerBlip, cfg.Locations["handler"].sprite)
    SetBlipDisplay(HandlerBlip, cfg.Locations["handler"].display)
    SetBlipScale(HandlerBlip, cfg.Locations["handler"].scale)
    SetBlipAsShortRange(HandlerBlip, true)
    SetBlipColour(HandlerBlip, cfg.Locations["handler"].colour)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(cfg.Locations["handler"].label)
    EndTextCommandSetBlipName(HandlerBlip)

    CreateZone("main")
    CreateZone("handler")
end

RegisterNetEvent('zv-harbourjob:client:TakeHandler', function(data)
    local vehicleInfo = data.vehicle
    TriggerServerEvent('zv-harbourjob:server:DoBail', true, vehicleInfo)
    selectedVeh = vehicleInfo
end)

local function MenuGarage()
    local truckMenu = {
        {
            header = Lang:t("menu.header"),
            isMenuHeader = true
        }
    }
    truckMenu[#truckMenu+1] = {
        header = "Handler",
        params = {
            event = "zv-harbourjob:client:TakeHandler",
            args = {
                vehicle = "handler"
            }
        }
    }

    truckMenu[#truckMenu+1] = {
        header = Lang:t("menu.close_menu"),
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }

    }
    exports['qb-menu']:openMenu(truckMenu)
end

-- Events

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    while not Core do
        Wait(0)
    end
    PlayerJob = Core.Functions.GetPlayerData().job
    if PlayerJob.name ~= "harbour" then return end
    CreateElements()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = Core.Functions.GetPlayerData().job
    if PlayerJob.name ~= "harbour" then return end
    CreateElements()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    RemoveHarbourBlips()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    local OldPlayerJob = PlayerJob.name
    PlayerJob = JobInfo
    if OldPlayerJob == "harbour" then
        RemoveHarbourBlips()
        showMarker = false
    elseif PlayerJob.name == "harbour" then
        CreateElements()
    end
end)

RegisterNetEvent('zv-harbourjob:client:SpawnHandler', function()
    local vehicleInfo = selectedVeh
    local coords = cfg.Locations["handler"].coords
    Core.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        SetVehicleNumberPlateText(veh, "TRUK"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        SetVehicleLivery(veh, 1)
        SetVehicleColours(veh, 122, 122)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        exports['qb-menu']:closeMenu()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", Core.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        CurrentPlate = Core.Functions.GetPlate(veh)
    end, vehicleInfo, coords, true)
end)

RegisterNetEvent('zv-harbourjob:client:Handler', function()
    if IsPedInAnyVehicle(PlayerPedId()) and GetEntityModel(GetVehiclePedIsIn(PlayerPedId())) == joaat("handler") then
        if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
            if GetEntityModel(GetVehiclePedIsIn(PlayerPedId())) == joaat("handler") then
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                TriggerServerEvent('zv-harbourjob:server:DoBail', false)
                if CurrentBlip ~= nil then
                    RemoveBlip(CurrentBlip)
                    ClearAllBlipRoutes()
                    CurrentBlip = nil
                end
                if returningToStation or CurrentLocation then
                    ClearAllBlipRoutes()
                    returningToStation = false
                    QBCore.Functions.Notify(Lang:t("mission.job_completed"), "success")
                end
            else
                QBCore.Functions.Notify(Lang:t("error.vehicle_not_correct"), 'error')
            end
        else
            QBCore.Functions.Notify(Lang:t("error.no_driver"))
        end
    else
        MenuGarage()
    end
end)

-- Threads

CreateThread(function()
    while true do
        if showMarker then
            DrawMarker(2, markerLocation.x, markerLocation.y, markerLocation.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
        end

        local vehicle = GetVehiclePedIsIn(PlayerPedId())
        local coords = GetEntityCoords(PlayerPedId())
        local container = GetClosestObjectOfType(coords.xyz, 15.0, GetHashKey('prop_contr_03b_ld'), 1, 0, 1) -- zet op 1 0 1 voor alleen eigen containers
        if not containerland then
            if not IsAnyEntityAttachedToHandlerFrame(vehicle) then
                if HasEntityCollidedWithAnything(container) then
                    if RequestScriptAudioBank("Container_Lifter", 0) then
                        PlaySoundFromEntity(GetSoundId(), "Container_Land", vehicle, "CONTAINER_LIFTER_SOUNDS", 0, 0)
                    end
                    containerland = true
                    pickedup = false
                end
            end
        end
        if not IsAnyEntityAttachedToHandlerFrame(vehicle) and not pickedup then
            if IsVehicleDriveable(vehicle, 0) then
                if DoesEntityExist(container) then
                    if IsHandlerFrameAboveContainer(vehicle, container) then
                        ShowHelpNotification('Press ~INPUT_CONTEXT~ to pick up the container.')
                        if IsControlJustPressed(0, 38) then
                            if RequestScriptAudioBank("Container_Lifter", 0) then
                                PlaySoundFromEntity(GetSoundId(), "Container_Attach", vehicle, "CONTAINER_LIFTER_SOUNDS", 0, 0)
                            end
                            AttachContainerToHandlerFrame(vehicle, container)    
                            pickedup = true    
                        end
                    end
                end
            end
        end
        if pickedup then
            if IsVehicleDriveable(vehicle, 0) then
                if DoesEntityExist(container) then
                    ShowHelpNotification('Press ~INPUT_CONTEXT~ to release the container.')
                    if IsControlJustPressed(0, 38) then
                        if RequestScriptAudioBank("Container_Lifter", 0) then
                            PlaySoundFromEntity(GetSoundId(), "Container_Release", vehicle, "CONTAINER_LIFTER_SOUNDS", 0, 0)
                        end
                        containerland = false
                    end
                end
            end
        end    
        Wait(3)
    end
end)

RegisterCommand("spawn", function()
    if not HasModelLoaded(GetHashKey('prop_contr_03b_ld')) then
        RequestModel(GetHashKey('prop_contr_03b_ld'))

        while not HasModelLoaded(GetHashKey('prop_contr_03b_ld')) do
            Wait(1)
        end
    end
    local object = CreateObject(GetHashKey('prop_contr_03b_ld'), -54.58629608154297, -2399.421875, 4.99999856948852, 1, 0, 0)
    SetEntityAsMissionEntity(object, 1, 1)
end, false)