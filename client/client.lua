local QBCore = exports['qb-core']:GetCoreObject()

local isPickingUp = false
local isProcessingFabricroll = false
local isSellingShirt = false
isProcessingFabricroll = false


-- Fungsi untuk memulai/menghentikan progress bar (MENGGUNAKAN CALLBACK)
local function StartProgressBar(label, duration, callback)
    QBCore.Functions.Progressbar("task", label, duration, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        -- Selesai
        if callback then
            callback(true) -- Panggil callback dengan success = true
        end
    end, function()
        -- Batal
        if callback then
            callback(false) -- Panggil callback dengan success = false
        end
    end)
end

-- Fungsi untuk memberikan notifikasi
local function Notify(message, type)
    QBCore.Functions.Notify(message, type)
end

-- Fungsi untuk cek apakah punya item
local function HasItem(itemName, amount, cb)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
        if cb then
            cb(result)
        end
    end, itemName, amount)
end

-- ***Interaksi Memanen Kapas***
exports.interact:AddInteraction({
    coords = Config.CircleZones.CottonField.coords,
    distance = Config.InteractDistances.cottonField,
    id = 'tailor_harvest_cotton',
    name = 'Harvest Cotton',
    options = {
        {
            label = 'Pick Cotton',
            action = function()
                if isPickingUp then
                    Notify("You are already picking cotton.", "error")
                    return
                end
                isPickingUp = true
                StartProgressBar("Picking Cotton", 3000, function(success) -- Menggunakan callback
                    if success then
                        TriggerServerEvent('tailorjob:server:harvestCotton')
                    end
                    isPickingUp = false
                end)
            end
        }
    }
})


-- ***Interaksi Membuat Fabric Roll***
exports.interact:AddInteraction({
    coords = Config.CircleZones.MakeFabricroll.coords,
    distance = Config.InteractDistances.default,
    id = 'tailor_make_fabric',
    name = 'Make Fabric Roll',
    options = {
        {
            label = 'Process Cotton to Fabricroll',
            action = function()
                print("Make Fabric Roll: Action started")
                if isProcessingFabricroll then
                    Notify("You are already processing cotton into Fabricroll.", "error")
                    return
                end
                if not QBCore.Functions.HasItem(Config.Items.cotton, Config.MinPiecesCot) then
                    Notify("You need some Cotton to do this!", "error")
                    return
                end
                isProcessingFabricroll = true
                StartProgressBar("Making Fabricroll...", Config.Delays.MakeFabricroll, function(success)
                    print("Make Fabric Roll: StartProgressBar callback", success)
                    if success then
                        TriggerServerEvent('tailorjob:server:makeFabricRoll')
                    end
                    isProcessingFabricroll = false
                end)
            end
        }
    }
})



-- ***Interaksi Menjahit Pakaian***
exports.interact:AddInteraction({
    coords = Config.CircleZones.SewingClothes.coords,
    distance = Config.InteractDistances.default,
    id = 'tailor_sew_clothes',
    name = 'Sew Clothes',
    options = {
        {
            label = 'Sew Shirt',
            action = function()
                if not QBCore.Functions.HasItem(Config.Items.cotton, Config.MinPiecesCot) then
                    Notify("You need some Cotton to do this!", "error")
                    return
                end
                if not QBCore.Functions.HasItem(Config.Items.fabricroll, Config.MinPiecesCot) then
                    Notify("You need Fabric Roll to sew!", "error")
                    return
                end
                StartProgressBar("Sewing Shirt...", Config.Delays.SewingClothes, function(success)
                    if success then
                        TriggerServerEvent('tailorjob:server:sewShirt')
                    end
                end)
            end
        }
    }
})


exports.interact:AddInteraction({
    coords = Config.CircleZones.TextileOwner.coords,
    distance = Config.InteractDistances.default,
    id = 'tailor_sell_clothes',
    name = 'Sell Clothes',
    options = {
        {
            label = 'Sell Shirt',
            action = function()
                if isSellingShirt then
                    Notify("You are already selling a shirt.", "error")
                    return
                end
                if not QBCore.Functions.HasItem(Config.Items.shirt, Config.MinPiecesCot) then
                    Notify("You need some shirts to sell!", "error")
                    return
                end
                isSellingShirt = true
                StartProgressBar("Selling Shirt...", Config.Delays.SellShirt, function(success)
                    if success then
                        TriggerServerEvent('tailorjob:server:sellShirt')
                    end
                    isSellingShirt = false
                end)
            end
        }
    }
})


-- Fungsi untuk membuat blip (opsional)
local function CreateBlip(coords, sprite, color, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.7)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
end

-- Membuat blip untuk lokasi (opsional)
Citizen.CreateThread(function()
  CreateBlip(Config.CircleZones.CottonField.coords, 73, 49, "Cotton Field")
  CreateBlip(Config.CircleZones.MakeFabricroll.coords, 73, 49, "Make Fabric Roll")
  CreateBlip(Config.CircleZones.SewingClothes.coords, 73, 49, "Sew Clothes")
  CreateBlip(Config.CircleZones.TextileOwner.coords, 73, 49, "Textile Owner")
end)