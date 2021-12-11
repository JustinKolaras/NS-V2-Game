local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Messaging = game:GetService("MessagingService")

local BanService = require(ServerStorage.Modules.Storage.BanService)
local Admins = require(ServerStorage.Modules.Storage.Admins)

return function (Context, Victim, Reason)
	if not Reason then return "Reason required." end
	local Executor = Context.Executor
	local isVictimBanned = BanService:GetBanInfo(Victim)
	
	if Victim == Executor.UserId then
		return "You can't perform this action on yourself."
	end
	for _, b in next,Admins do
		if b == Victim then
			return "You can't perform this action on another moderator."
		end
	end
	if isVictimBanned then
		return Players:GetNameFromUserIdAsync(Victim).." is already banned."
	end
	if #Reason > 85 then
		return "Reason too long."
	end
	
	local Format = ("\nBanned from all servers!\nModerator: %s\nReason: %s"):format(Players:GetNameFromUserIdAsync(Executor.UserId) , Reason)
	
	local err = BanService:Add(Victim, Executor.UserId, Reason)
	if err then
		return tostring(err)
	end
	
	for _, b in next,Players:GetPlayers() do
		if b.UserId == Victim then
			b:Kick(Format)
		end
	end
	
	Messaging:PublishAsync("Servers:Kick", {
		UserId = Victim,
		Reason = Format
	})
	
	return ('Banned %s (%s) successfully.'):format( Players:GetNameFromUserIdAsync(Victim), Victim )
end