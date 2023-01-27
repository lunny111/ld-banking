ESX = nil
local opened = false
local pIsOpening = false
local pIsATM = false
local atm = true

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("ld:infos")
AddEventHandler("ld:infos",
                function(firstname, lastname, job, bank, cash, bankid)
    SendNUIMessage({
        type = "infos",
        firstname = firstname,
        lastname = lastname,
        job = job,
        bank = bank,
        cash = cash,
        bankid = bankid
    })
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function bankanimation(pIsATM, pIsOpening)
    local playerId = PlayerPedId()
    if pIsATM then
      loadAnimDict("amb@prop_human_atm@male@enter")
      loadAnimDict("amb@prop_human_atm@male@exit")
      loadAnimDict("amb@prop_human_atm@male@idle_a")
      if pIsOpening then
        TaskPlayAnim(playerId, "amb@prop_human_atm@male@idle_a", "idle_b", 1.0, 1.0, -1, 49, 0, 0, 0, 0)
        local finished = exports["np-taskbar"]:taskBar(3000, "Inserting card")
        ClearPedSecondaryTask(playerId)
      else
        ClearPedTasks(playerId)
        TaskPlayAnim(playerId, "amb@prop_human_atm@male@exit", "exit", 1.0, 1.0, -1, 49, 0, 0, 0, 0)
        local finished = exports["np-taskbar"]:taskBar(1000, "Retrieving Card")
        ClearPedTasks(playerId)
      end
    else
      loadAnimDict("mp_common")
      if pIsOpening then
        ClearPedTasks()
        TaskPlayAnim(playerId, "mp_common", "givetake1_a", 1.0, 1.0, -1, 49, 0, 0, 0, 0)
        local finished = exports["np-taskbar"]:taskBar(1000, "Showing bank documentation")
        ClearPedTasks(playerId)
      else
        TaskPlayAnim(playerId, "mp_common", "givetake1_a", 1.0, 1.0, -1, 49, 0, 0, 0, 0)
        local finished = exports["np-taskbar"]:taskBar(1000, "Collecting documentation")
        Citizen.Wait(1000)
        ClearPedTasks(playerId)
      end
    end
  end

function Nui(close)
    if close and not atm then
        SetNuiFocus(true, true)
        SendNUIMessage({type = "bank", toggle = true})
    elseif close and atm then
        SetNuiFocus(true, true)
        SendNUIMessage({type = "bank", toggle = true, boa = "atm"})
    else
        SetNuiFocus(false, false)
        SendNUIMessage({type = "bank", toggle = false})
    end
end

function loadanim()
    TriggerServerEvent("ld:getinfos")
    Citizen.Wait(100)
    recent()
    SendNUIMessage({type = "load"})
end

RegisterNetEvent("ld-refreshpage")
AddEventHandler("ld-refreshpage", function()
    TriggerServerEvent("ld:getinfos")
    recent()
    SendNUIMessage({type = "ccon"})
end)

RegisterNetEvent("ld:open-atm")
AddEventHandler("ld:open-atm", function()
    bankanimation(true, true)
    pIsATM = true
    loadanim()
    Citizen.Wait(1000)
    SetNuiFocus(true, true)
    SendNUIMessage({type = "bank", toggle = true, boa = "atm"})
end)

RegisterNetEvent("ld:open-bank")
AddEventHandler("ld:open-bank", function()
    bankanimation(false, true)
    loadanim()
    Citizen.Wait(1000)
    SetNuiFocus(true, true)
    SendNUIMessage({type = "bank", toggle = true})
end)

function recent()
    ESX.TriggerServerCallback('ld:getRecents', function(recent)
        if #recent > 0 then

            for k, v in ipairs(recent) do
                SendNUIMessage({
                    type = "recent",
                    sender = v.sender,
                    target = v.target,
                    amount = v.amount,
                    label = v.label,
                    date = v.date,
                    iden = v.iden,
                    rtype = v.type
                })
            end
        else
            SendNUIMessage({type = "recent", sender = "empty"})
        end
    end)
end

local years, months, days, hours, minutes, seconds
local date = 31

function time()

    years, months, days, hours, minutes, seconds =
        Citizen.InvokeNative(0x50C7A99057A69748, Citizen.PointerValueInt(),Citizen.PointerValueInt(),Citizen.PointerValueInt(),Citizen.PointerValueInt(),Citizen.PointerValueInt(), Citizen.PointerValueInt())

    if months < 10 then months = "0" .. months end

    if days < 10 then days = "0" .. days end

    if minutes < 10 then minutes = "0" .. minutes - 1 end

    if seconds < 10 then seconds = "0" .. seconds end

    if hours < 10 then hours = "0" .. hours end

    date = years .. "-" .. months .. "-" .. days .. "T" .. hours .. ":" ..minutes .. ":" .. seconds

end

RegisterNUICallback('withdraw', function(data, cb)
    amount = data.value
    comment = data.comment
    time()
    TriggerServerEvent("ld:withdrawmoney", tonumber(amount), comment, date)
    cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
    amount = data.value
    comment = data.comment
    time()
    TriggerServerEvent("ld:depositmoney", tonumber(amount), comment, date)
    cb('ok')
end)


RegisterNUICallback('transfer', function(data, cb)
    amount = data.value
    comment = data.comment
    id = data.id
    time()
    TriggerServerEvent("ld:transfermoney", tonumber(amount), comment, id, date)
    cb('ok')
end)


RegisterNUICallback('close', function(data, cb)
    Nui(false)
    cb('ok')
    bankanimation(pIsATM, false)
    pIsATM = false
end)

RegisterCommand("transfer", function()
    TriggerServerEvent("ld:transfermoney", tonumber("1000"), "sadasd", 1, "11111")
end)