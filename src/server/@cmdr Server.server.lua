local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cmdr = require(ServerScriptService.Server.Cmdr)

Cmdr:RegisterCommandsIn(ServerScriptService.Server:WaitForChild("Commands"))
Cmdr:RegisterHooksIn(ServerStorage.Storage:WaitForChild("Cmdr").Hooks)
