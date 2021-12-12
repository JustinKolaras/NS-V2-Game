local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Event = ReplicatedStorage:WaitForChild("Events").SetCore

Event.OnClientEvent:Connect(function(...)
	local Data = { ... }
	if Data[1] == "BoughtItem" then
		local Bc = BrickColor.new("Lime green")
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = Data[2].Name .. " bought '" .. Data[3].Name .. "'! Niiice!",
			Font = Enum.Font.SourceSans,
			Color = Bc.Color,
			FontSize = Enum.FontSize.Size96,
		})
	elseif Data[1] == "PlayerJoin" then
		local Bc = BrickColor.new("Medium stone grey")
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = Data[2].Name .. " joined the game!",
			Font = Enum.Font.SourceSans,
			Color = Bc.Color,
			FontSize = Enum.FontSize.Size96,
		})
	elseif Data[1] == "PlayerLeave" then
		local Bc = BrickColor.new("Medium stone grey")
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = Data[2].Name .. " left the game!",
			Font = Enum.Font.SourceSans,
			Color = Bc.Color,
			FontSize = Enum.FontSize.Size96,
		})
	end
end)
