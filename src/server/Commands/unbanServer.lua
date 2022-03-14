local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local GameModLogs = require(ServerStorage.Storage.WebhookPresets.GameModLogs)

return function(Context, Victim)
	local Executor = Context.Executor
	local VictimName = Players:GetNameFromUserIdAsync(Victim)
	local VictimBanned = BanService:GetBanInfo(Victim)

	if Victim == Executor.UserId then
		return "Command failed to execute."
	end

	if not VictimBanned then
		return VictimName .. " is not banned."
	end

	local err, result = GameModLogs:SendUnban({
		ExecutorName = Executor.Name,
		VictimName = VictimName,
		VictimID = Victim,
	})

	if err then
		warn(result)
		return ("Error (%s): %s"):format(result.errorStatus, result.errorString)
	end

	local apiResult = BanService:Remove(Victim)
	if apiResult.status == "error" then
		return "Error: " .. apiResult.error
	end

	return ("Unbanned %s (%s) successfully."):format(VictimName, Victim)
end
