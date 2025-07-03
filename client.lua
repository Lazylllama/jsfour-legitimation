-- QB
local QBCore = exports['qb-core']:GetCoreObject()

-- State
local cardOpen = false
local showText = false

-- Servern callback
RegisterNetEvent('legitimation:open')
AddEventHandler('legitimation:open', function(playerData)
	cardOpen = true
	SendNUIMessage({
		action = "open",
		array = playerData
	})
end)

-- Close the ID card
-- Key events
Citizen.CreateThread(function()
	while true do
		Wait(0)
		if IsControlPressed(0, 322) or IsControlPressed(0, 177) and cardOpen then
			SendNUIMessage({
				action = "close"
			})
			cardOpen = false
		end
	end
end)


-- ID Card Creation
local function syncCallback(typ, dat)
	local p = promise.new();

	lib.callback(typ, false, function(data)
		p:resolve(data)
	end, dat)

	return Citizen.Await(p)
end

local function getIdCard(url)
	local resp = syncCallback('legitimation:getIdCard', url)

	if resp == 0 then
		print("[ID Card]: ERROR - Client did not receive ID Card data.")
		return
	end

	return resp
end

Citizen.CreateThread(function()
	while true do
		local interval, playerPed = 1500, PlayerPedId();

		if #(GetEntityCoords(playerPed) - Config.Locations.start) < 2.5 then
			interval = 5;

			showText = true
			exports['jg-textui']:DrawText("Tryck [E] för att ta ut ett ID kort")

			if #(GetEntityCoords(playerPed) - Config.Locations.start) < 1.0 then
				if IsControlJustReleased(0, 38) then
					showText = false
					if not exports['qs-inventory']:HasItem(Config.Inventory.IDCard) then
						local MugShot = exports["MugShotBase64"]:GetMugShotBase64(PlayerPedId(), true)

						if not MugShot then
							QBCore.Functions.Notify("Kunde inte ta en bild, försök igen", "error", 5000)
						else
							getIdCard(MugShot)
						end
					else
						QBCore.Functions.Notify("Du har redan ett ID kort", "error", 5000)
					end
				end
			end
		elseif showText then
			exports['jg-textui']:HideText()
			showText = false
		end

		Citizen.Wait(interval)
	end
end)
