-- Made by funwolf7
local UpButton = "Space"
local DownButton = "LeftControl"

local SpeedUpButton = "E"
local SpeedDownButton = "Q"

local DefaultSpeed = 60

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local Player = game.Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
local ControlModule = PlayerModule:GetControls()

local Equipped = false

local Speed = type(DefaultSpeed) and DefaultSpeed or 50

local Connection

local function OnPress(Name, State, Object)
	if not UserInputService:GetFocusedTextBox() and Equipped then
		if Name == "NoclipSpeedUp" then
			if State == Enum.UserInputState.Begin then
				Speed = Speed + 10
			end
		elseif Name == "NoclipSpeedDown" then
			if State == Enum.UserInputState.Begin then
				Speed = math.max(Speed - 10, 10)
			end
		end
	end
end

script.Parent.ToolTip = "Move around like you are playing normally."

if UpButton and type(UpButton) == "string" and Enum.KeyCode[UpButton] then
	script.Parent.ToolTip = script.Parent.ToolTip .. " Press " .. UpButton .. " to move upwards."
end
if DownButton and type(DownButton) == "string" and Enum.KeyCode[DownButton] then
	script.Parent.ToolTip = script.Parent.ToolTip .. " Press " .. UpButton .. " to move downwards."
end

if SpeedUpButton and type(SpeedUpButton) == "string" and Enum.KeyCode[SpeedUpButton] then
	ContextActionService:BindAction("NoclipSpeedUp", OnPress, false, Enum.KeyCode[SpeedUpButton])
	script.Parent.ToolTip = script.Parent.ToolTip .. " Press " .. SpeedUpButton .. " to speed up."
end
if SpeedDownButton and type(SpeedDownButton) == "string" and Enum.KeyCode[SpeedDownButton] then
	ContextActionService:BindAction("NoclipSpeedDown", OnPress, false, Enum.KeyCode[SpeedDownButton])
	script.Parent.ToolTip = script.Parent.ToolTip .. " Press " .. SpeedDownButton .. " to slow down."
end

script.Parent.Equipped:Connect(function()
	Equipped = true
	Connection = RunService.Heartbeat:Connect(function(Step)
		local Character = Player.Character
		if Character then
			local Humanoid = Character:FindFirstChild("Humanoid")
			local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
			local Camera = workspace.CurrentCamera

			if Humanoid then
				Humanoid.PlatformStand = true
			end

			if HumanoidRootPart then
				HumanoidRootPart.Anchored = true
				HumanoidRootPart.Velocity = Vector3.new()

				if Camera then
					local MoveAmount = ControlModule:GetMoveVector() or Vector3.new()

					if not UserInputService:GetFocusedTextBox() then
						if UpButton and type(UpButton) == "string" and Enum.KeyCode[UpButton] then
							if UserInputService:IsKeyDown(Enum.KeyCode[UpButton]) then
								MoveAmount = Vector3.new(MoveAmount.X, 1, MoveAmount.Z)
							end
						end
						if DownButton and type(DownButton) == "string" and Enum.KeyCode[DownButton] then
							if UserInputService:IsKeyDown(Enum.KeyCode[DownButton]) then
								MoveAmount = Vector3.new(MoveAmount.X, MoveAmount.Y - 1, MoveAmount.Z)
							end
						end
					end

					MoveAmount = MoveAmount.Magnitude > 1 and MoveAmount.Unit or MoveAmount
					MoveAmount = MoveAmount * Step * Speed

					HumanoidRootPart.CFrame = CFrame.new(
						HumanoidRootPart.Position,
						HumanoidRootPart.Position + Camera.CFrame.LookVector
					) * CFrame.new(MoveAmount)
				end
			end
		end
	end)
end)

script.Parent.Unequipped:Connect(function()
	Equipped = false
	local Character = Player.Character
	if Character then
		local Humanoid = Character:FindFirstChild("Humanoid")
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

		if Humanoid then
			Humanoid.PlatformStand = false
		end

		if HumanoidRootPart then
			HumanoidRootPart.Anchored = false
		end
	end
	if Connection then
		Connection:Disconnect()
		Connection = nil
	end
end)
