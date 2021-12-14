local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Storage.Modules.BanService)

return function(Context, Player)
	local Executor = Context.Executor
	local PlayerBanned, BanReason, ExecutorId = BanService:GetBanInfo(Player)

	if Player == Executor.UserId then
		return "You can't perform this action on yourself."
	end
	if not PlayerBanned then
		return Players:GetNameFromUserIdAsync(Player) .. " is not banned."
	end

	return ('%s was banned by %s for: "%s"'):format(
		Players:GetNameFromUserIdAsync(Player),
		Players:GetNameFromUserIdAsync(ExecutorId),
		BanReason
	)
end
