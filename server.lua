-- QB
local QBCore = exports['qb-core']:GetCoreObject()

-- Register the item in the QBCore framework
QBCore.Functions.CreateUseableItem(Config.Inventory.IDCard, function(source, item)
	print("Använd ID-kort", json.encode(item))
	local gender = "Man"
	local closestId, _closestPed, _closestCoords = lib.getClosestPlayer(GetEntityCoords(GetPlayerPed(source)), 2, false)

	if not closestId then
		TriggerClientEvent('QBCore:Notify', source, "Ingen i närheten", "error")
		return
	end

	if
		not item or
		not item.info.firstname or
		not item.info.lastname or
		not item.info.dateofbirth or
		not item.info.sex or
		not item.info.nationality or
		not item.info.personalnumber or
		not item.info.headshot
	then
		TriggerClientEvent('QBCore:Notify', source, "ID-kortet är ogiltigt", "error")
		return
	end

	if not item.info.sex == 0 then
		gender = "Kvinna"
	end

	local idData = {
		firstname = item.info.firstname,
		lastname = item.info.lastname,
		dateofbirth = item.info.dateofbirth,
		nationality = item.info.nationality,
		sex = gender,
		personalnumber = item.info.personalnumber,
		headshot = item.info.headshot
	}

	TriggerClientEvent('legitimation:open', closestId or source, idData)
end)

-- Callback for the ID card creation
lib.callback.register('legitimation:getIdCard', function(source, url)
	local Player = QBCore.Functions.GetPlayer(source)

	if not Player then
		return false
	end

	local idCardData = {
		name = ('%s %s'):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
		firstname = Player.PlayerData.charinfo.firstname,
		lastname = Player.PlayerData.charinfo.lastname,
		personalnumber = Player.PlayerData.citizenid,
		dateofbirth = Player.PlayerData.charinfo.birthdate,
		sex = Player.PlayerData.charinfo.gender,
		nationality = Player.PlayerData.charinfo.nationality,
		time = os.date("!%Y-%m-%d"),
		label = ('%s %s - Identiteskort'):format(Player.PlayerData.charinfo.firstname,
			Player.PlayerData.charinfo.lastname),
		headshot = url
	}

	MySQL.Async.execute([[
        UPDATE players SET mugshot = @mugshot WHERE citizenid = @citizenid
    ]], {
		['@citizenid'] = Player.PlayerData.citizenid,
		['@mugshot'] = url
	}, function(result)
	end)

	exports['qs-inventory']:AddItem(source, Config.Inventory.IDCard, 1, nil, idCardData)

	return true
end)
