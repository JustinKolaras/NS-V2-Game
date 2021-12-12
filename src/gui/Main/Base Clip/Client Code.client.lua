local Players = game:GetService("Players")
local Market = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
if not PlayerGui then
	repeat
		wait()
	until Player.PlayerGui ~= nil
end

local Main = PlayerGui:WaitForChild("Main")
local BaseClip = Main:WaitForChild("Base Clip")
local Base = BaseClip:WaitForChild("Base")
local Credits = BaseClip:WaitForChild("Credits")
local Donate = BaseClip:WaitForChild("Donate")
local OpenButton = BaseClip:WaitForChild("OpenMenu")

--

local function TweenFrame(GuiObj, Starting, Goal, Check, FunctionWhenComplete)
	if Check == true then
		GuiObj.Position = Starting
		GuiObj.Visible = true
		GuiObj:TweenPosition(Goal, "Out", "Quint", 0.5, false, FunctionWhenComplete or nil)
	else
		GuiObj:TweenPosition(Goal, "Out", "Quint", 0.5, false, FunctionWhenComplete or nil)
	end
end

local function TweenTwoSubsequently(
	FirstObj,
	SecondObj,
	FirstObjGoal,
	SecondObjGoal,
	FirstObjStarting,
	SecondObjStarting,
	CheckFirst,
	CheckSecond,
	FunctionWhenComplete
)
	if CheckFirst == true then
		FirstObj.Position = FirstObjStarting
		FirstObj.Visible = true
	end
	if CheckSecond == true then
		SecondObj.Position = SecondObjStarting
		SecondObj.Visible = true
	end
	FirstObj:TweenPosition(FirstObjGoal, "Out", "Quint", 0.5, false, function()
		if Enum.TweenStatus.Completed then
			SecondObj:TweenPosition(SecondObjGoal, "Out", "Quint", 0.5, false, FunctionWhenComplete or nil)
		end
	end)
end

local function TweenTrigger(Type)
	if Type == 1 then
		OpenButton:TweenPosition(UDim2.new(1.1, 0, 0.5, 0), "Out", "Quint", 0.5)
	elseif Type == 2 then
		OpenButton:TweenPosition(UDim2.new(0.995, 0, 0.5, 0), "Out", "Quint", 0.5)
	end
end

--

OpenButton.Visible = true

-- Base Controls

local BaseControlsX = Base.Controls.X
local BaseControlsCredits = Base.CredsButton
local BaseControlsDonate = Base.DonateButton

OpenButton.MouseButton1Click:Connect(function()
	TweenFrame(Base, UDim2.new(1.5, 0, 0.5, 0), UDim2.new(0.5, 0, 0.5, 0), true)
	TweenTrigger(1)
end)

BaseControlsDonate.MouseButton1Click:Connect(function()
	TweenTwoSubsequently(
		Base,
		Donate,
		UDim2.new(1.5, 0, 0.5, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(1.5, 0, 0.5, 0),
		true,
		true
	)
end)

BaseControlsCredits.MouseButton1Click:Connect(function()
	TweenTwoSubsequently(
		Base,
		Credits,
		UDim2.new(1.5, 0, 0.5, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(1.5, 0, 0.5, 0),
		true,
		true
	)
end)

BaseControlsX.MouseButton1Click:Connect(function()
	repeat
		wait()
	until Base.Position == UDim2.new(0.5, 0, 0.5, 0)
	TweenTrigger(2)
	TweenFrame(Base, UDim2.new(0.5, 0, 0.5, 0), UDim2.new(1.5, 0, 0.5, 0), false, function()
		Base.Visible = false
	end)
end)

-- Credits Controls

local CreditsControlsX = Credits.Controls.X
local CreditsCanvas = Credits.Canvas

CreditsControlsX.MouseButton1Click:Connect(function()
	repeat
		task.wait()
	until Credits.Position == UDim2.new(0.5, 0, 0.5, 0)
	CreditsCanvas.CanvasPosition = Vector2.new(0, 0)
	TweenTwoSubsequently(
		Credits,
		Base,
		UDim2.new(1.5, 0, 0.5, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(1.5, 0, 0.5, 0),
		true,
		true
	)
end)

-- Donate Controls

local DonateControlsX = Donate.Controls.X
local DonateControlsR10 = Donate["10"]
local DonateControlsR25 = Donate["25"]
local DonateControlsR50 = Donate["50"]
local DonateControlsR100 = Donate["100"]
local DonateControlsR250 = Donate["250"]
local DonateControlsR500 = Donate["500"]
local DonateControlsR1K = Donate["1k"]

local DevProductIDs = {
	R10 = 1123753195,
	R25 = 1123753963,
	R50 = 1123754031,
	R100 = 1123754078,
	R250 = 1123754137,
	R500 = 1123754175,
	R1000 = 1123754238,
}

DonateControlsR10.MouseButton1Click:Connect(function()
	Market:PromptProductPurchase(Player, DevProductIDs.R10)
end)

DonateControlsR25.MouseButton1Click:Connect(function()
	Market:PromptProductPurchase(Player, DevProductIDs.R25)
end)

DonateControlsR50.MouseButton1Click:Connect(function()
	Market:PromptProductPurchase(Player, DevProductIDs.R50)
end)

DonateControlsR100.MouseButton1Click:Connect(function()
	Market:PromptProductPurchase(Player, DevProductIDs.R100)
end)

DonateControlsR250.MouseButton1Click:Connect(function()
	Market:PromptProductPurchase(Player, DevProductIDs.R250)
end)

DonateControlsR500.MouseButton1Click:Connect(function()
	Market:PromptProductPurchase(Player, DevProductIDs.R500)
end)

DonateControlsR1K.MouseButton1Click:Connect(function()
	Market:PromptProductPurchase(Player, DevProductIDs.R1000)
end)

DonateControlsX.MouseButton1Click:Connect(function()
	repeat
		task.wait()
	until Donate.Position == UDim2.new(0.5, 0, 0.5, 0)
	TweenTwoSubsequently(
		Donate,
		Base,
		UDim2.new(1.5, 0, 0.5, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(0.5, 0, 0.5, 0),
		UDim2.new(1.5, 0, 0.5, 0),
		true,
		true
	)
end)
