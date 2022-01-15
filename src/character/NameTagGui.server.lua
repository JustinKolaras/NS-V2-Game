task.wait()

local Market = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Shared.Util)

local Character = script.Parent.Parent
local Player = Players:GetPlayerFromCharacter(Character)

local NameTag = script:WaitForChild("NameTag")
NameTag.Enabled = false

local UserString, RankString = Util:Create("StringValue"), Util:Create("StringValue")
UserString.Name = "Username"
UserString.Value = Character.Name
RankString.Name = "GroupRank"
RankString.Value = Player:GetRoleInGroup(8046949)

local NameTagClone = NameTag:Clone()
NameTagClone.Enabled = true
local ClonedFrame = NameTagClone:FindFirstChild("Frame")
local ClonedRank = ClonedFrame:FindFirstChild("GroupRank")
local ClonedUser = ClonedFrame:FindFirstChild("Username")
local ClonedVIP = ClonedFrame:FindFirstChild("VIP")

NameTagClone.Parent = Character:FindFirstChild("Head")
NameTagClone.Adornee = Character:FindFirstChild("Head")
NameTagClone.StudsOffset = Vector3.new(0, 2.25, 0)

ClonedUser.Text = UserString.Value
ClonedUser.TextStrokeTransparency = 0.85
ClonedUser.TextTransparency = 0.05
ClonedRank.Text = RankString.Value
ClonedRank.TextStrokeTransparency = 0.85
ClonedRank.TextTransparency = 0.05

function DownsizeUser()
	ClonedUser.Position = UDim2.new(0, 0, 0.35, 0)
	ClonedUser.Size = UDim2.new(1, 0, 0.2, 0)
end

function UpsizeUser()
	ClonedUser.Position = UDim2.new(0, 0, 0.3, 0)
	ClonedUser.Size = UDim2.new(1, 0, 0.3, 0)
end

function ConfigureSizeUser()
	return #ClonedUser.Text >= 17 and DownsizeUser() or UpsizeUser()
end

UserString:GetPropertyChangedSignal("Value"):Connect(function()
	ClonedUser.Text = UserString.Value
	ConfigureSizeUser()
end)

local giveTag = Util:Create("BindableEvent", { Name = "NT Bindable", Parent = ReplicatedStorage })

giveTag.Event:Connect(function(name, color1, color2, color3)
	ClonedVIP.TextColor3 = Color3.fromRGB(color1, color2, color3)
	ClonedVIP.Text = name
	ClonedVIP.Visible = true
end)

if Market:UserOwnsGamePassAsync(Player.UserId, 13375778) then
	giveTag:Fire("= VIP =", 255, 219, 11)
end

if Player:GetRankInGroup(8046949) >= 252 then
	local speed = 10
	task.spawn(function()
		while true do
			for i = 0, 1, 0.001 * speed do
				ClonedUser.TextColor3 = Color3.fromHSV(i, 1, 1)
				task.wait()
			end
			task.wait()
		end
	end)
end

ConfigureSizeUser()
Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
