local ServerStorage = game:GetService("ServerStorage")

local lockMod = require(ServerStorage.Modules.Lock)

return function (Context)
	local errorMsg = lockMod:Unlock()
	if errorMsg then return errorMsg end
	return "Unlocked server."
end