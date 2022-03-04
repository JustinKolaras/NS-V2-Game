local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Storage.Modules.BanService)

return function(_, Player)
	local PlayerBanned, BanReason, ExecutorId, Date, System = BanService:GetBanInfo(Player)

	if not PlayerBanned then
		return Players:GetNameFromUserIdAsync(Player) .. " is not banned."
	end

	return ('%s was banned on %s by %s for: "%s"'):format(
		Players:GetNameFromUserIdAsync(Player),
		Date,
		if System then "System" else Players:GetNameFromUserIdAsync(ExecutorId),
		BanReason
	)
end
