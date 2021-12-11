local Players = game:GetService("Players")
local Http = game:GetService("HttpService")

return function (Context)
	
	local Executor = Context.Executor
	
	for a,b in next,Players:GetPlayers() do
		b:Kick( ("Server shutdown by %s!"):format(Context.Executor.Name) )
	end
	
end