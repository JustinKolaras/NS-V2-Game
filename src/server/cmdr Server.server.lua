local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Cmdr = require(ServerScriptService.Server.Cmdr)

local StorageCmdrFolder = ServerStorage.Storage:WaitForChild("Cmdr")

Cmdr:RegisterCommandsIn(ServerScriptService.Server:WaitForChild("Commands"))
Cmdr:RegisterHooksIn(StorageCmdrFolder.Hooks)
