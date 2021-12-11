local playerService = game:GetService("Players")
local runService = game:GetService("RunService")
game.ReplicatedFirst:RemoveDefaultLoadingScreen()

local Player = playerService.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local CharacterHumanoid = Character:WaitForChild("Humanoid")
local PlayerGui = Player.PlayerGui
wait()

local IntroGui = PlayerGui:WaitForChild("Intro")
local TweenBgr = IntroGui:WaitForChild("TweenBackground")
local Title = TweenBgr:WaitForChild("To Transparentify Title")
local Desc = TweenBgr:WaitForChild("To Transparentify Desc")
local Skip = TweenBgr:WaitForChild("Skip Button")

function Setup()
	IntroGui.Enabled = true
	TweenBgr.Position = UDim2.new(0,0,-1,0)
	TweenBgr.Visible = false
	Skip.Position = UDim2.new(-0.1,0,0.938,0)
	Skip.Visible = false
	Title.TextTransparency = 1
	Desc.TextTransparency = 1	
end

function DoIt()
	TweenBgr.Visible = true
	TweenBgr:TweenPosition(UDim2.new(0,0,0,0),'Out','Quart',2,false,function()
		if Enum.TweenStatus.Completed then
			delay(1, function()
				Skip.Visible = true
				Skip:TweenPosition(UDim2.new(0.013,0,0.938,0),'Out','Quart',1)
				repeat
					Title.TextTransparency -= .1
					wait(.1)
				until Title.TextTransparency <= 0
				delay(1, function()
					repeat
						Desc.TextTransparency -= .1
						wait(.1)
					until Desc.TextTransparency <= 0
					delay(3, function()
						CharacterHumanoid.WalkSpeed = 16
						Skip:TweenPosition(UDim2.new(-0.1,0,0.938,0),'Out','Quart',.5)
						TweenBgr:TweenPosition(UDim2.new(0,0,-1,0),'Out','Quart',.5,false,function()
							if Enum.TweenStatus.Completed then
								Setup()
							end
						end)
					end)
				end)
			end)
		end
	end)
end

Skip.MouseButton1Click:Connect(function()
	CharacterHumanoid.WalkSpeed = 16
	Skip:TweenPosition(UDim2.new(-0.1,0,0.938,0),'Out','Quart',.5)
	TweenBgr:TweenPosition(UDim2.new(0,0,-1,0),'Out','Quart',1,false,function()
		if Enum.TweenStatus.Completed then
			Setup()
		end
	end)
end)

if not runService:IsStudio() then
	CharacterHumanoid.WalkSpeed = 0
	Setup()
	DoIt()	
end
