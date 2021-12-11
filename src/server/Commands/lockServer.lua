local ServerStorage = game:GetService("ServerStorage")

local lockMod = require(ServerStorage.Modules.Lock)

return function (Context, lockReason)
	-- See if the Reason is above the character limit.
	if lockReason:len() > 100 then
		return "Reason too long."
	end
	
	local errorMsg = lockMod:Lock(lockReason, Context.Executor)
	if errorMsg then return errorMsg end
	if lockReason then
		return "Locked server: "..lockReason
	else
		return "Locked server."
	end
end