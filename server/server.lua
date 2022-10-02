local Bail = {}

RegisterNetEvent('zv-harbourjob:server:DoBail', function(bool, vehInfo)
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    if bool then
        if Player.PlayerData.money.cash >= cfg.BailPrice then
            Bail[Player.PlayerData.citizenid] = cfg.BailPrice
            Player.Functions.RemoveMoney('cash', cfg.BailPrice, "tow-received-bail")
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.paid_with_cash", {value = cfg.BailPrice}), 'success')
            TriggerClientEvent('zv-harbourjob:client:SpawnHandler', src, vehInfo)
        elseif Player.PlayerData.money.bank >= cfg.BailPrice then
            Bail[Player.PlayerData.citizenid] = cfg.BailPrice
            Player.Functions.RemoveMoney('bank', cfg.BailPrice, "tow-received-bail")
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.paid_with_bank", {value = cfg.BailPrice}), 'success')
            TriggerClientEvent('zv-harbourjob:client:SpawnHandler', src, vehInfo)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.no_deposit", {value = cfg.BailPrice}), 'error')
        end
    else
        if Bail[Player.PlayerData.citizenid] then
            Player.Functions.AddMoney('cash', Bail[Player.PlayerData.citizenid], "harbour-bail-paid")
            Bail[Player.PlayerData.citizenid] = nil
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.refund_to_cash", {value = cfg.BailPrice}), 'success')
        end
    end
end)