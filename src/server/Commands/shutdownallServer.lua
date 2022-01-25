local Messaging = game:GetService("MessagingService")

return function(Context, Reason)
	local Executor = Context.Executor

	if Reason and #Reason > 50 then
		return "Error: Reason too long. Cap: 50chars"
	end

	Messaging:PublishAsync("Servers:Shutdown", {
		Reason = if Reason then ("Game-wide shutdown by %s: %s"):format(Executor.Name, Reason) else ("Game-wide shutdown by %s!"):format(Executor.Name),
	})
end
