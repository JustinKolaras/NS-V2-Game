local Players = game:GetService("Players")

return function(Context)
	local Executor = Context.Executor

	for _, b in next, Players:GetPlayers() do
		b:Kick(("Server shutdown by %s!"):format(Executor.Name))
	end
end
