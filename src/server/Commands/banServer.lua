local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Messaging = game:GetService("MessagingService")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local Admins = require(ReplicatedStorage.Shared.Admins)
local Util = require(ReplicatedStorage.Shared.Util)
local GameModLogs = require(ServerStorage.Storage.WebhookPresets.GameModLogs)

return function(Context, Victim, Reason)
	local Executor = Context.Executor
	local VictimName = Players:GetNameFromUserIdAsync(Victim)
	local isVictimBanned = BanService:GetBanInfo(Victim)

	if Victim == Executor.UserId then
		return "Access Denied"
	end

	for _, b in next, Admins do
		if b == Victim then
			return "Access Denied"
		end
	end

	if isVictimBanned then
		return VictimName .. " is already banned."
	end

	if #Reason > 85 then
		return "Error: Reason too long. Cap: 85chars"
	end

	local Date = Util:GetUTCDate()

	local Format = ("\nBanned from all servers!\nModerator: %s\nReason: %s\n%s"):format(
		Executor.Name,
		Reason,
		Date .. " UTC"
	)

	local err, result = GameModLogs:SendBan({
		ExecutorName = Executor.Name,
		VictimName = VictimName,
		VictimID = Victim,
		Reason = Reason,
	})

	if err then
		warn(result)
		return ("Error (%s): %s"):format(result.errorStatus, result.errorString)
	end

	local apiResult = BanService:Add(Victim, Executor.UserId, Reason, Date)
	if apiResult.status == "error" then
		return "Error: " .. apiResult.error
	end

	Messaging:PublishAsync("Servers:Kick", {
		UserId = Victim,
		Reason = Format,
	})

	return ("Banned %s (%s) successfully."):format(VictimName, Victim)
end
