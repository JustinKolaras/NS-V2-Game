return function (Context, toTeleport)
	local Executor = Context.Executor
	
	if Executor.Character and Executor.Character:FindFirstChild("HumanoidRootPart") then
		Executor.Character.HumanoidRootPart.CFrame = toTeleport
	end

	return "Done."
end
