local UserInput = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Icon = require(ReplicatedStorage.Shared.Icon)
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local function cmdrPermission()
	return Player:GetRankInGroup(8046949) > 252
end

if cmdrPermission() and UserInput.TouchEnabled then
	
	local cmdrIcon = Icon.new():setLabel('Cmdr'):setCornerRadius(0, 4):setTip("Open Cmdr Window")
	
	cmdrIcon.selected:Connect(function()
		Cmdr:Toggle()
	end)
	
end