local Http = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local secrets = require(ServerStorage.Storage.Modules.secrets)

local Endpoints = {
	OUTBOUND_KICKS = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/kicks",
	DELETE_OUTBOUND_KICK = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/kicks/%d",
}

return function()
	-- Clear all kicks
	Http:RequestAsync({
		Url = Endpoints.OUTBOUND_KICKS,
		Method = "DELETE",
		Headers = {
			["Authorization"] = secrets["NS_API_AUTHORIZATION"],
		},
	})
	while true do
		local data = Http:GetAsync(Endpoints.OUTBOUND_KICKS, false, {
			["Authorization"] = secrets["NS_API_AUTHORIZATION"],
		})
		data = Http:JSONDecode(data)
		if data.status == "ok" then
			for _, dict in ipairs(data.data) do
				local id, reason, executor = dict.toKickID, dict.reason, dict.executor

				-- Send delete request
				Http:RequestAsync({
					Url = Endpoints.DELETE_OUTBOUND_KICK:format(id),
					Method = "DELETE",
					Headers = {
						["Authorization"] = secrets["NS_API_AUTHORIZATION"],
					},
				})

				-- Kick
				local Format = ("\nKicked\nModerator: %s\nReason: %s"):format(
					Players:GetNameFromUserIdAsync(executor),
					reason
				)

				local playerObject = Players:GetPlayerByUserId(id)
				if playerObject then
					playerObject:Kick(Format)
				end
			end
		else
			error(data.error)
		end
		task.wait(5)
	end
end
