local TeleportService = game:GetService("TeleportService")

return function(Context)
	local Executor = Context.Executor
	TeleportService:Teleport(5833319019, Executor)

	return "Teleporting.."
end
