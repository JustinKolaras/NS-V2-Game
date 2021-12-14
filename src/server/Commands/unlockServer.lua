local ServerStorage = game:GetService("ServerStorage")

local LockModule = require(ServerStorage.Storage.Modules.Lock)

return function()
	local errorMsg = LockModule:Unlock()

	if errorMsg then
		return tostring(errorMsg)
	end

	return "Unlocked server."
end
