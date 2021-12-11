local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cmdr = require(ServerScriptService.Server.Cmdr)

Cmdr:RegisterCommandsIn(ServerScriptService:WaitForChild("Commands"))
Cmdr:RegisterHooksIn(ServerStorage:WaitForChild('Cmdr').Hooks)
