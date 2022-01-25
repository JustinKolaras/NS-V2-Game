local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Storage.Modules.BanService)

return function(Context, Player)
	local Executor = Context.Executor
	local PlayerBanned, BanReason, ExecutorId, Date, System = BanService:GetBanInfo(Player)

	if Player == Executor.UserId then
		return "Error: You can't perform this action on yourself."
	end

	if not PlayerBanned then
		return "Error: " .. Players:GetNameFromUserIdAsync(Player) .. " is not banned."
	end

	return ('%s was banned on %s by %s for: "%s"'):format(
		Players:GetNameFromUserIdAsync(Player),
		Date .. " UTC",
		if System then "System" else Players:GetNameFromUserIdAsync(ExecutorId),
		BanReason
	)
end
