local Players = game:GetService("Players")

return function(Context, Reason)
	local Executor = Context.Executor

	if #Reason > 50 then
		return "Error: Reason too long. Cap: 50chars"
	end

	for _, b in ipairs(Players:GetPlayers()) do
		if Reason then
			b:Kick(("Server shutdown by %s: %s"):format(Executor.Name, Reason))
		else
			b:Kick(("Server shutdown by %s!"):format(Executor.Name))
		end
	end
end
