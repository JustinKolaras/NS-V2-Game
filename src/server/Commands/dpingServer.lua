local ServerStorage = game:GetService("ServerStorage")

local Pong = require(ServerStorage.Storage.WebhookPresets.Pong)

return function(Context)
	local err, result = Pong:Send({
		CTXE = Context.Executor,
		Job = game.JobId,
	})

	if err then
		warn(result)
		return ("Error (%s): %s"):format(result.errorStatus, result.errorString)
	end

	return "Sent! Check Discord!"
end
