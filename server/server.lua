local QBCore = exports['qb-core']:GetCoreObject()

-- ***Event Memanen Kapas***
RegisterServerEvent('tailorjob:server:harvestCotton')
AddEventHandler('tailorjob:server:harvestCotton', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    Player.Functions.AddItem(Config.Items.cotton, Config.CottonPickingAmount)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config.Items.cotton], "add")
    TriggerClientEvent("QBCore:Notify", src, "You harvested some Cotton!", "success")
end)


-- ***Event Membuat Fabric Roll***
RegisterServerEvent('tailorjob:server:makeFabricRoll')
AddEventHandler('tailorjob:server:makeFabricRoll', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveItem(Config.Items.cotton, Config.MinPiecesCot) then
        Player.Functions.AddItem(Config.Items.fabricroll, Config.MinPiecesCot)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config.Items.cotton], "remove")
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config.Items.fabricroll], "add")
        TriggerClientEvent("QBCore:Notify", src, "You made a Fabricroll!", "success")
    else
        TriggerClientEvent("QBCore:Notify", src, "You don't have enough cotton.", "error")
    end
end)


-- ***Event Menjahit Pakaian***
RegisterServerEvent('tailorjob:server:sewShirt')
AddEventHandler('tailorjob:server:sewShirt', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

  --  if Player.Functions.RemoveItem("fabricroll", 1) and Player.Functions.RemoveItem("cotton", 1) then
  if Player.Functions.RemoveItem(Config.Items.fabricroll, Config.MinPiecesCot) and Player.Functions.RemoveItem(Config.Items.cotton, Config.MinPiecesCot) then
        Player.Functions.AddItem(Config.Items.shirt, Config.MinPiecesCot)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config.Items.fabricroll], "remove")
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config.Items.cotton], "remove")
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config.Items.shirt], "add")
        TriggerClientEvent("QBCore:Notify", src, "You sewed a Shirt!", "success")
    else
        TriggerClientEvent("QBCore:Notify", src, "You don't have enough Fabricroll/Cotton.", "error")
    end
end)


-- ***Event Menjual Pakaian***
RegisterServerEvent('tailorjob:server:sellShirt')
AddEventHandler('tailorjob:server:sellShirt', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem(Config.Items.shirt, Config.MinPiecesCot) then
        local reward = Config.Prices.SellShirt * Config.MinPiecesCot 
        Player.Functions.AddMoney("cash", reward)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[Config.Items.shirt], "remove")
        TriggerClientEvent("QBCore:Notify", src, "You sold " .. Config.MinPiecesCot .. " Shirt(s) for $" .. reward, "success")
    else
        TriggerClientEvent("QBCore:Notify", src, "You don't have enough shirts to sell.", "error")
    end
end)
