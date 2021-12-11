local SS = game:GetService("ServerStorage")
local SSS = game:GetService("ServerScriptService")
local Cmdr = require(SSS.Cmdr)

Cmdr:RegisterCommandsIn(SSS:WaitForChild("Commands"))
Cmdr:RegisterHooksIn(SS:WaitForChild("Cmdr").Hooks)
