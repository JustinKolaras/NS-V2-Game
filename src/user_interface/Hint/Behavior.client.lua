local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Gui = Player.PlayerGui
if not Gui then
	repeat
		task.wait()
	until Gui ~= nil
end

local Event = ReplicatedStorage.Events:FindFirstChild("Cmdr-Connection")

local HintGui = Gui:WaitForChild("Hint")
local ClipFrame = HintGui:WaitForChild("Clip")
local ValueText = ClipFrame:WaitForChild("Value")

local Hints = {
	"Join the <b>group</b> for more updates, clothing, and rank ups!",
	"Communications server code: <b>SHRuvXcpMc</b>",
	"Want a shirt/pants designed to your liking? Comment your requests on the <b>group wall</b>!",
	"To open clothing interaction menus, hold out your <b>Shopping Bag</b> and click on any mannequin.",
	"Most designs were made by astroxics and the rest of the designers! This game was scripted by Aerosphia.",
	"<b>Next Saturday</b> is a streetwear clothing group, offering (primarily) mens and womens clothing!",
	"Have a bug report? Please contact <b>astroxics</b> or <b>Aerosphia</b> with relevant details.",
}
local Clearing = {}

local activeTime = 7.5
local inactiveTime = 60

local automatic = true

function Hint(Text)
	if ClipFrame.Position ~= UDim2.new(0, 0, -0.5, 0) then
		ClipFrame.Position = UDim2.new(0, 0, -0.5, 0)
	end
	ValueText.Text = tostring(Text)
	ClipFrame.Visible = true
	ClipFrame:TweenPosition(UDim2.new(0, 0, 0, 0), "Out", "Quint", 1, false, function()
		if Enum.TweenStatus.Completed then
			if automatic then
				task.delay(activeTime, function()
					ClipFrame:TweenPosition(UDim2.new(0, 0, -0.5, 0), "Out", "Quint", 1)
				end)
			end
		end
	end)
end

Event.OnClientEvent:Connect(function(Starter, ...)
	local Data = { ... }
	if Starter == "Activate" then
		local Text = Data[1]
		if ClipFrame.Position ~= UDim2.new(0, 0, -0.5, 0) then
			ClipFrame:TweenPosition(UDim2.new(0, 0, -0.5, 0), "Out", "Quint", 1, false, function()
				automatic = false
				task.wait(0.1)
				Hint(Text)
			end)
		else
			automatic = false
			task.wait(0.1)
			Hint(Text)
		end
	elseif Starter == "Deactivate" then
		if not automatic then
			ClipFrame:TweenPosition(UDim2.new(0, 0, -0.5, 0), "Out", "Quint", 1, false, function()
				automatic = true
			end)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(inactiveTime)
		if automatic then
			if #Hints == 0 then
				for _, b in pairs(Clearing) do
					table.insert(Hints, b)
				end
			end
			local Chosen = Hints[math.random(1, #Hints)]
			Hint(Chosen, false)
			for a, b in ipairs(Hints) do
				if b == Chosen then
					table.insert(Clearing, b)
					table.remove(Hints, a)
				end
			end
		end
	end
end)
