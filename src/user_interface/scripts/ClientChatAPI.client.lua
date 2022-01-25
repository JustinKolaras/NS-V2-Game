local Chat = game:GetService("Chat")
local ClientChatModules = Chat:WaitForChild("ClientChatModules")
local ChatSettings = require(ClientChatModules:WaitForChild("ChatSettings"))

-- Enable bubble chat
ChatSettings.BlubbleChatEnabled = true

-- Allow window to be resizeable & draggable
ChatSettings.WindowResizable = true
ChatSettings.WindowDragable = true

-- Change chat window colors
ChatSettings.BackGroundColor = Color3.fromRGB(18, 18, 18)
ChatSettings.ChatBarBoxColor = Color3.fromRGB(80, 80, 80)
