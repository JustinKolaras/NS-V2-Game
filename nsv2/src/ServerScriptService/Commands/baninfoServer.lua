local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")

local BanService = require(ServerStorage.Modules['BanService'])
local Format = require(ServerStorage.Modules['ModFormats'])

return function (Context, Player)

	local Executor = Context.Executor
	local PlayerBanned,BanReason,ExecutorId = BanService:GetBanInfo(Player)

	-- See if they are attempting to perform actions on themselves.
	if Player == Executor.UserId then
		return "You can't perform this action on yourself."
	end
	-- See if the Player is banned.
	if not PlayerBanned then
		return Players:GetNameFromUserIdAsync(Player).." is not banned."
	end
	
	return ('%s was banned by %s for: "%s"'):format( Players:GetNameFromUserIdAsync(Player), Players:GetNameFromUserIdAsync(ExecutorId), BanReason )
end