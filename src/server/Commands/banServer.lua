local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Messaging = game:GetService("MessagingService")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local Admins = require(ReplicatedStorage.Shared.Admins)
local Util = require(ReplicatedStorage.Shared.Util)
local GameModLogs = require(ServerStorage.Storage.WebhookPresets.GameModLogs)

return function(context, victim, reason)
	local executor = context.executor
	local victimName = Players:GetNameFromUserIdAsync(victim)
	local isVictimBanned = BanService:GetBanInfo(victim)

	if victim == executor.UserId then
		return "Access Denied"
	end

	for _, b in ipairs(Admins) do
		if b == victim then
			return "Access Denied"
		end
	end

	if isVictimBanned then
		return victimName .. " is already banned."
	end

	if #reason > 85 then
		return "Reason too long. Cap: 85 Characters"
	end

	local date = Util:GetUTCDate()
	local Format = ("\nBanned from all servers!\nModerator: %s\nReason: %s\n%s"):format(
		executor.Name,
		reason,
		date .. " UTC"
	)

	local err, result = GameModLogs:SendBan({
		ExecutorName = executor.Name,
		VictimName = victimName,
		VictimID = victim,
		Reason = reason,
	})

	if err then
		warn(result)
		return ("Error (%s): %s"):format(result.errorStatus, result.errorString)
	end

	local apiResult = BanService:Add(victim, executor.UserId, reason, date)
	if apiResult.status == "error" then
		return "Error: " .. apiResult.error
	end

	Messaging:PublishAsync("Servers:Kick", {
		UserId = victim,
		Reason = Format,
	})

	return ("Banned %s (%s) successfully."):format(victimName, victim)
end
