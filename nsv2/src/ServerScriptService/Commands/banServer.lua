local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Messaging = game:GetService("MessagingService")

local BanService = require(ServerStorage.Modules['BanService'])
local BackupAdmins = require(ServerStorage.Modules['BackupAdminList'])
local Format = require(ServerStorage.Modules['ModFormats'])

return function (Context, Victim, Reason)
	
	if not Reason then return "Reason required." end
	local Executor = Context.Executor
	local VictimBanned = BanService:GetBanInfo(Victim)
	
	-- See if they are attempting to perform actions on themselves.
	if Victim == Executor.UserId then
		return "You can't perform this action on yourself."
	end
	-- See if the Victim is an admin.
	for a,b in next,BackupAdmins do
		if b == Victim then
			return "You can't perform this action on another moderator."
		end
	end
	-- See if the Victim is already banned.
	if VictimBanned then
		return Players:GetNameFromUserIdAsync(Victim).." is already banned."
	end
	-- See if the Reason is above the character limit.
	if Reason:len() > 85 then
		return "Reason too long."
	end
	
	local Format = Format("Ban",Executor.UserId,Reason)
	
	local err = BanService:Add(Victim, Executor.UserId, Reason)
	if err then
		return tostring(err)
	end
	
	for a,b in next,Players:GetPlayers() do
		if b.UserId == Victim then
			b:Kick(Format)
		end
	end
	
	Messaging:PublishAsync('Servers:Kick', {
		UserId = Victim,
		Reason = Format
	})
	
	return ("Banned %s (%s) successfully."):format( Players:GetNameFromUserIdAsync(Victim), Victim )
	
end