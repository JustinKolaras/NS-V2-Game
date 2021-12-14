return function(Context, Players)
	local toCFrame = Context.Executor.Character.HumanoidRootPart.CFrame

	for _, player in ipairs(Players) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = toCFrame
		end
	end
end
