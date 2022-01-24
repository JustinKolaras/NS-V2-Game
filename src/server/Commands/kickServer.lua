local ServerStorage = game:GetService("ServerStorage")

local Admins = require(ServerStorage.Storage.Modules.Admins)

return function(Context, Victim, Reason)
	local Executor = Context.Executor

	if Victim.UserId == Executor.UserId then
		return "Error: You can't perform this action on yourself."
	end

	for _, b in ipairs(Admins) do
		if b == Victim.UserId then
			return "You can't perform this action on another moderator."
		end
	end

	if #Reason > 85 then
		return "Error: Reason too long. Cap: 85chars"
	end

	Victim:Kick("\nKicked\nModerator: %s\nReason: %s"):format(Executor.Name, tostring(Reason))

	return ("Kicked %s (%s) successfully."):format(Victim.Name, Victim.UserId)
end
