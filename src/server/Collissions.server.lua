local PhysService = game:GetService("PhysicsService")

PhysService:CreateCollisionGroup("p")
PhysService:CollisionGroupSetCollidable("p", "p", false)

function NoCollide(model)
	for _, b in next, model:GetChildren() do
		if b:IsA("BasePart") then
			PhysService:SetPartCollisionGroup(b, "p")
		end
	end
end

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connnect(function(Character)
		Character:WaitForChild("HumanoidRootPart")
		Character:WaitForChild("Head")
		Character:WaitForChild("Humanoid")
		task.wait(0.1)
		NoCollide(Character)
	end)

	if Player.Character then
		NoCollide(Player.Character)
	end
end)
