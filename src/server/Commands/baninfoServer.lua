local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Storage.Modules.BanService)

return function(_, Player)
	local PlayerBanned, BanReason, ExecutorId, Date, System = BanService:GetBanInfo(Player)
	local ExecutorName = Players:GetNameFromUserIdAsync(ExecutorId)
	local PlayerName = Players:GetNameFromUserIdAsync(Player)

	if not PlayerBanned then
		return PlayerName .. " is not banned."
	end

	return ('%s was banned on %s by %s for: "%s"'):format(
		PlayerName,
		Date,
		if System then "System" else ExecutorName,
		BanReason
	)
end
