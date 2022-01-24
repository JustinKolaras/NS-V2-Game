local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Messaging = game:GetService("MessagingService")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local Admins = require(ServerStorage.Storage.Modules.Admins)

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

	local Format = ("\nBanned from all servers!\nModerator: %s\nReason: %s"):format(
		Players:GetNameFromUserIdAsync(Executor.UserId),
		Reason
	)

	local err = BanService:Add(Victim, Executor.UserId, Reason)
	if err then
		return "Error: " .. tostring(err)
	end

	for _, b in ipairs(Players:GetPlayers()) do
		if b.UserId == Victim then
			b:Kick(Format)
		end
	end

	Messaging:PublishAsync("Servers:Kick", {
		UserId = Victim,
		Reason = Format,
	})

	return ("Banned %s (%s) successfully."):format(Players:GetNameFromUserIdAsync(Victim), Victim)
end
