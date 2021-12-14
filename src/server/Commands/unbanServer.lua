local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Storage.Modules.BanService)

return function(Context, Victim)
	local Executor = Context.Executor
	local VictimBanned = BanService:GetBanInfo(Victim)

	if Victim == Executor.UserId then
		return "Error: You can't perform actions on yourself."
	end
	if not VictimBanned then
		return "Error: " .. Players:GetNameFromUserIdAsync(Victim) .. " is not banned."
	end

	local err = BanService:Remove(Victim)
	if err then
		return tostring(err)
	end

	return ("Unbanned %s (%s) successfully."):format(Players:GetNameFromUserIdAsync(Victim), Victim)
end
