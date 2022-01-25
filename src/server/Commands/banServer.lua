local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Messaging = game:GetService("MessagingService")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local Admins = require(ServerStorage.Storage.Modules.Admins)
local Util = require(ReplicatedStorage.Shared.Util)

return function(Context, Victim, Reason)
	local Executor = Context.Executor
	local isVictimBanned = BanService:GetBanInfo(Victim)

	if Victim == Executor.UserId then
		return "Error: You can't perform this action on yourself."
	end

	for _, b in next, Admins do
		if b == Victim then
			return "Error: You can't perform this action on another moderator."
		end
	end

	if isVictimBanned then
		return "Error: " .. Players:GetNameFromUserIdAsync(Victim) .. " is already banned."
	end

	if #Reason > 85 then
		return "Error: Reason too long. Cap: 85chars"
	end

	local Date = Util:GetUTCDate()

	local Format = ("\nBanned from all servers!\nModerator: %s\nReason: %s\n%s"):format(
		Players:GetNameFromUserIdAsync(Executor.UserId),
		Reason,
		Date .. " UTC"
	)

	local err = BanService:Add(Victim, Executor.UserId, Reason, Date)
	if err then
		return "Error: " .. tostring(err)
	end

	Messaging:PublishAsync("Servers:Kick", {
		UserId = Victim,
		Reason = Format,
	})

	return ("Banned %s (%s) successfully."):format(Players:GetNameFromUserIdAsync(Victim), Victim)
end
