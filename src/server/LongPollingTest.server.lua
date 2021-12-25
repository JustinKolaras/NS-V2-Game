local ServerScriptService = game:GetService("ServerScriptService")

local rbxWebhook = require(ServerScriptService.Server:WaitForChild("rbxWebhook"))
local client = rbxWebhook.new({ apiKey = "TO_SET_LATER" })

client:connect("127.0.0.1:3000/rbxwebhook")

client:on("pong", function(message)
	print("echoed from server: ", message)
end)

client:on("broadcast", function(message)
	print("broadcast: ", message)
end)

client:send("ping", "Hello world!")

game:BindToClose(function()
	client:disconnect()
end)
