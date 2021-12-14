local ServerStorage = game:GetService("ServerStorage")

local LockModule = require(ServerStorage.Storage.Modules.Lock)

return function(Context, lockReason)
	if #lockReason > 100 then
		return "Reason too long."
	end

	local errorMsg = LockModule:Lock(lockReason, Context.Executor)
	if errorMsg then
		return tostring(errorMsg)
	end

	return lockReason and "Locked server: " .. lockReason or "Locked server, no reason provided."
end
