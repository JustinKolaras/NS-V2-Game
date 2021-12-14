local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

return function(_, Victim)
	if #Players:GetPlayers() == 1 then
		return "Can't execute rejoin with a server of only one player."
	end

	TeleportService:Teleport(game.PlaceId, Victim)
	return "Successfully frisbee'd " .. Victim.Name .. "."
end
