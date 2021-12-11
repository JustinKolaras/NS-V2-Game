local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local Player = Players.LocalPlayer

Cmdr:SetEnabled(false)

if Player:GetRankInGroup(8046949) >= 252 or Player.UserId == tonumber('-1') then
	Cmdr:SetEnabled(true)
	Cmdr:SetActivationKeys({ Enum.KeyCode.Semicolon })
end

