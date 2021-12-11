local playerService = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local Player = playerService.LocalPlayer
local PlayerGui = Player.PlayerGui

local Event = repStorage.Events:FindFirstChild("CmdrHintBoundary")

local HintGui = PlayerGui:WaitForChild("Hint")
local ClipFrame = HintGui:WaitForChild("Clip")
local ValueText = ClipFrame:WaitForChild("Value")

local Hints = {
	"Join the <b>group</b> for more updates, clothing, and rank ups!",
	"Communications server code: <b>SHRuvXcpMc</b>",
	"Want a shirt/pants designed to your liking? Comment your requests on the <b>group wall</b>!",
	'To open clothing interaction menus, hold out your <b>Shopping Bag</b> and click on any mannequin.',
	"Most designs were made by astroxics and the rest of the designers! This game was scripted by Aerosphia.",
	"<b>Next Saturday</b> is a streetwear clothing group, offering (primarily) mens and womens clothing!",
	"Have a bug report? Please contact <b>astroxics</b> or <b>Aerosphia</b> with relevant details.",
}

local Clearing = {}

local activeTime = 7.5 -- How long the tip will be when active (displayed) until being hidden
local inactiveTime = 60 -- How long between each new randomized tip

local automatic = true

function Hint(Text,Perm)
	if ClipFrame.Position ~= UDim2.new(0,0,-0.5,0) then
		ClipFrame.Position = UDim2.new(0,0,-0.5,0)
	end
	ValueText.Text = tostring(Text)
	ClipFrame.Visible = true
	ClipFrame:TweenPosition(UDim2.new(0,0,0,0),'Out','Quint',1,false,function()
		if Enum.TweenStatus.Completed then
			if not Perm then
				task.delay(activeTime,function()
					if automatic then
						ClipFrame:TweenPosition(UDim2.new(0,0,-0.5,0),'Out','Quint',1)
					end
				end)
			end
		end
	end)
end

Event.OnClientEvent:Connect(function(Starter,...)
	local Data = {...}
	if Starter == "Activate" then
		local Text = Data[1]
		if ClipFrame.Position ~= UDim2.new(0,0,-0.5,0) then
			ClipFrame:TweenPosition(UDim2.new(0,0,-0.5,0),'Out','Quint',1,false,function()
				automatic = false
				task.wait(.1)
				Hint(Text,true)
			end)
		else
			automatic = false
			task.wait(.1)
			Hint(Text,true)
		end
	elseif Starter == "Deactivate" then
		if not automatic then
			ClipFrame:TweenPosition(UDim2.new(0,0,-0.5,0),'Out','Quint',1,false,function()
				automatic = true
			end)
		end
	end
end)

task.spawn(function()
	while wait(inactiveTime) do
		if automatic then
			if #Hints == 0 then
				for a,b in pairs(Clearing) do
					table.insert(Hints,b)
				end
			end
			local Ran = math.random(1,#Hints)
			local Chosen = Hints[Ran]
			Hint(Chosen,false)
			for a,b in pairs(Hints) do
				if b == Chosen then
					table.insert(Clearing,b)
					table.remove(Hints,a)
				end
			end
		end
	end
end)