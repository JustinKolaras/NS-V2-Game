local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Modules["BanService"])

return function(Context, Victim, Reason)
	local Executor = Context.Executor
	local VictimBanned = BanService:GetBanInfo(Victim)

	-- See if they are attempting to perform actions on themselves.
	if Victim == Executor.UserId then
		return "Error: You can't perform actions on yourself."
	end
	-- See if the Victim is banned.
	if not VictimBanned then
		return "Error: " .. Players:GetNameFromUserIdAsync(Victim) .. " is not banned."
	end

	local err = BanService:Remove(Victim)
	if err then
		return err
	end

	return ("Unbanned %s (%s) successfully."):format(Players:GetNameFromUserIdAsync(Victim), Victim)
end
