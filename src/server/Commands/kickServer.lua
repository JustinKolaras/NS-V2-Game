local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameModLogs = require(ServerStorage.Storage.WebhookPresets.GameModLogs)
local Admins = require(ReplicatedStorage.Shared.Admins)

return function(Context, Victim, Reason)
	local Executor = Context.Executor

	if Victim.UserId == Executor.UserId then
		return "Access Denied"
	end

	for _, b in ipairs(Admins) do
		if b == Victim.UserId then
			return "Access Denied"
		end
	end

	if #Reason > 85 then
		return "Error: Reason too long. Cap: 85chars"
	end

	local err, result = GameModLogs:SendKick({
		ExecutorName = Executor.Name,
		VictimName = Victim.Name,
		VictimID = Victim.UserId,
		Reason = Reason,
	})

	if err then
		warn(result)
		return ("Error (%s): %s"):format(result.errorStatus, result.errorString)
	end

	Victim:Kick(("\nKicked\nModerator: %s\nReason: %s"):format(Executor.Name, Reason))

	return ("Kicked %s (%s) successfully."):format(Victim.Name, Victim.UserId)
end
