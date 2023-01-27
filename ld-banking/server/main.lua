ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

local firstname = ""
local lastname = ""

RegisterServerEvent("ld:getinfos")
AddEventHandler("ld:getinfos", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    bank = xPlayer.getAccount('bank').money
    cash = xPlayer.getAccount('money').money
    local result = MySQL.Sync.fetchAll("SELECT firstname, lastname, job, accounts, bankid FROM users WHERE identifier = @identifier", {
        ['@identifier'] = xPlayer.getIdentifier()
    })
    firstname = result[1]['firstname']
    lastname = result[1]['lastname']
    job = result[1]['job']
    bankid= result[1]['bankid']
    TriggerClientEvent("ld:infos", src, firstname, lastname, job, bank, cash, bankid)
    

end)

ESX.RegisterServerCallback('ld:getRecents', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT id, sender, target, label, amount, iden, type, date FROM account_recent WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		cb(result)

	end)
end)

RegisterServerEvent("ld:withdrawmoney")
AddEventHandler("ld:withdrawmoney", function(amount, comment, date)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local type = "neg"
    local iden = "WITHDRAW"
    local sender = firstname.. " " ..lastname
    local target = sender
    local ply = ESX.GetPlayerFromId(src).getIdentifier()

    xPlayer.removeAccountMoney('bank', amount)
    xPlayer.addAccountMoney('money', amount)


    TriggerEvent("ld-updaterecents", ply, amount, comment, date, type, sender, target, iden)
    TriggerClientEvent("ld-refreshpage", src)
    if comment == nil then
        comment = "YOK"
    end
end)

RegisterServerEvent("ld:depositmoney")
AddEventHandler("ld:depositmoney", function(amount, comment, date)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local type = "pos"
    local iden = "DEPOSIT"
    local sender = firstname.. " " ..lastname
    local target = sender
    local ply = ESX.GetPlayerFromId(src).getIdentifier()

    xPlayer.removeAccountMoney('money', amount)
    xPlayer.addAccountMoney('bank', amount)


    TriggerEvent("ld-updaterecents", ply, amount, comment, date, type, sender, target, iden)
    TriggerClientEvent("ld-refreshpage", src)
    if comment == nil then
        comment = "YOK"
    end
end)

RegisterServerEvent("ld:transfermoney")
AddEventHandler("ld:transfermoney", function(amount, comment, id, date)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local zPlayer = ESX.GetPlayerFromId(id)
    local type = "neg"
    local iden = "TRANSFER"
    local sender = firstname.. " " ..lastname
    local ply = ESX.GetPlayerFromId(src).getIdentifier()
    local result = MySQL.Sync.fetchAll("SELECT firstname, lastname FROM users WHERE identifier = @identifier", {
        ['@identifier'] = zPlayer.getIdentifier()
    })
    local fn2 = result[1]['firstname']
    local ln2 = result[1]['lastname']
    local target = fn2.. " ".. ln2
   

    
    
   if id == source then
    TriggerClientEvent('DoShortHudText', source, "You can't transfer money yourself!", 2)
   else
    
    TriggerClientEvent("ld-refreshpage", src)

    if comment == nil then
        comment = "YOK"
    end
    xPlayer.removeAccountMoney('bank', amount)
    zPlayer.addAccountMoney('bank', amount)
    TriggerEvent("ld-updaterecents", ply, amount, comment, date, type, sender, target, iden)
    ply = ESX.GetPlayerFromId(id).getIdentifier()
    type = "pos"
    TriggerEvent("ld-updaterecents", ply, amount, comment, date, type, sender, target, iden)
   end

    
end)

RegisterServerEvent("ld-updaterecents")
AddEventHandler("ld-updaterecents", function(ply, amount, comment, date, type, sender, target, iden)
    local src = source

    MySQL.Async.execute(
        "INSERT INTO account_recent (identifier,sender, target, label, amount, iden, type, date) VALUES (@identifier, @sender, @target, @label, @amount, @iden, @type, @date)",
        {
            ["@identifier"] = ply,
            ["@sender"] = sender,
            ["@target"] = target,
            ["@label"] = comment,
            ["@amount"] = amount,
            ["@iden"] = iden,
            ["@type"] = type,
            ["@date"] = date,
        },
        function(result)
            TriggerClientEvent("ld-refreshpage", src, result)
        end
    )
end)
