local Players = game:GetService("Players")

local Physics = game:GetService("PhysicsService")
Physics:CreateCollisionGroup("p")
Physics:CollisionGroupSetCollidable("p", "p", false)

function NoCollide(model)
	for _, v in next, model:GetChildren() do
		if v:IsA("BasePart") then
			Physics:SetPartCollisionGroup(v, "p")
		end
	end
end

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(char)
		char:WaitForChild("HumanoidRootPart")
		char:WaitForChild("Head")
		char:WaitForChild("Humanoid")
		task.wait(0.1)
		NoCollide(char)
	end)

	if Player.Character then
		NoCollide(Player.Character)
	end
end)
