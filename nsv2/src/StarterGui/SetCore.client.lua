local replicatedStorage = game:GetService("ReplicatedStorage")
local starterGui = game:GetService("StarterGui")
local SetCoreEvent = replicatedStorage:WaitForChild("Events")["SetCore"]

SetCoreEvent.OnClientEvent:Connect(function(...)
	local Data = {...}
	if Data[1] == "BoughtItem" then
		local Bc = BrickColor.new("Lime green")
		starterGui:SetCore("ChatMakeSystemMessage", {
			Text = Data[2].Name.." bought '"..Data[3].Name.."'! Niiice!",
			Font = Enum.Font.SourceSans,
			Color = Bc.Color,
			FontSize = Enum.FontSize.Size96,
		})
	elseif Data[1] == "PlayerJoinNormal" then
		local Bc = BrickColor.new("Medium stone grey")
		starterGui:SetCore("ChatMakeSystemMessage", {
			Text = Data[2].Name.." joined the game!",
			Font = Enum.Font.SourceSans,
			Color = Bc.Color,
			FontSize = Enum.FontSize.Size96,
		})
	elseif Data[1] == "PlayerLeaveNormal" then
		local Bc = BrickColor.new("Medium stone grey")
		starterGui:SetCore("ChatMakeSystemMessage", {
			Text = Data[2].Name.." left the game!",
			Font = Enum.Font.SourceSans,
			Color = Bc.Color,
			FontSize = Enum.FontSize.Size96,
		})
	elseif Data[1] == "PlayerJoinExclusive" then
		starterGui:SetCore("SendNotification", {
			Title = "Developer Joined!",
			Text = ("Woahh, a developer!\nThat's a-maze-eeng!!!"):format(Data[2].Name),
			Icon = game.Players:GetUserThumbnailAsync(Data[2].UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420),
		})
	elseif Data[1] == "ObbyWin" then
		local Bc = BrickColor.new("Toothpaste")
		starterGui:SetCore("ChatMakeSystemMessage", {
			Text = Data[2].Name.." finished the obby!! Wowzas!",
			Font = Enum.Font.SourceSans,
			Color = Bc.Color,
			FontSize = Enum.FontSize.Size96,
		})
	end
end)