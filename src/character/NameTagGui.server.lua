task.wait()

local Market = game:GetService("MarketplaceService")

local Character = 

local char,NameTag,plr,MarketplaceService = script.Parent,script:FindFirstChild('NameTag'),game.Players:GetPlayerFromCharacter(script.Parent),game:GetService('MarketplaceService')
NameTag.Enabled = false

local UserString,RankString = Instance.new('StringValue'), Instance.new('StringValue')
UserString.Name = 'Username'
UserString.Value = char.Name
RankString.Name = 'GroupRank'
RankString.Value = plr:GetRoleInGroup(8046949)

local NameTagClone = NameTag:Clone()
NameTagClone.Enabled = true
local ClonedFrame = NameTagClone:FindFirstChild('Frame')
local ClonedRank = ClonedFrame:FindFirstChild('GroupRank')
local ClonedUser = ClonedFrame:FindFirstChild('Username')
local ClonedVIP = ClonedFrame:FindFirstChild('VIP')

NameTagClone.Parent = char:FindFirstChild('Head')
NameTagClone.Adornee = char:FindFirstChild('Head')
NameTagClone.StudsOffset = Vector3.new(0,2.25,0)

ClonedUser.Text = UserString.Value
ClonedUser.TextStrokeTransparency = .85
ClonedUser.TextTransparency = .05
ClonedRank.Text = RankString.Value
ClonedRank.TextStrokeTransparency = .85
ClonedRank.TextTransparency = .05

function DownsizeUser()
	ClonedUser.Position = UDim2.new(0, 0, 0.35, 0)
	ClonedUser.Size = UDim2.new(1, 0, 0.2, 0)
end
function UpsizeUser()
	ClonedUser.Position = UDim2.new(0, 0, 0.3, 0)
	ClonedUser.Size = UDim2.new(1, 0, 0.3, 0)
end

function ConfigureSizeUser()
	local getCharacters = string.len(ClonedUser.Text)
	if getCharacters >= 17 then
		DownsizeUser()
	else
		UpsizeUser()
	end
end

UserString:GetPropertyChangedSignal('Value'):Connect(function()
	ClonedUser.Text = UserString.Value
	ConfigureSizeUser()
end)

local giveTag = Instance.new('BindableEvent')
giveTag.Name = 'NT Bindable' 
giveTag.Parent = game:GetService("ReplicatedStorage")

giveTag.Event:Connect(function(name, c1,c2,c3)
	ClonedVIP.TextColor3 = Color3.fromRGB(c1,c2,c3)
	ClonedVIP.Text = name
	ClonedVIP.Visible = true
end)

function PremiumTag()
	giveTag:Fire("= VIP =", 255,219,11)
end

if MarketplaceService:UserOwnsGamePassAsync(plr.UserId,13375778) then
	PremiumTag()
end

char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

local getCharactersUser = string.len(ClonedUser.Text)
if getCharactersUser >= 17 then
	DownsizeUser()
end

if plr:GetRankInGroup(8046949) >= 252 then
	local speed = 10
	task.spawn(function()
		while wait() do
			for i = 0,1,0.001*speed do
				ClonedUser.TextColor3 = Color3.fromHSV(i,1,1)
				wait()
			end				
		end
	end)
end