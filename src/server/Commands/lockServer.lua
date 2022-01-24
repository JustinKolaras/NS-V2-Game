local ServerStorage = game:GetService("ServerStorage")

local LockModule = require(ServerStorage.Storage.Modules.Lock)

return function(Context, lockReason)
	if #lockReason > 100 then
		return "Error: Reason too long. Cap: 100chars"
	end

	local errorMsg = LockModule:Lock(lockReason, Context.Executor)
	if errorMsg then
		return "Error: " .. tostring(errorMsg)
	end

	return if lockReason then "Locked server: " .. lockReason else "Locked server, no reason provided." 
end
