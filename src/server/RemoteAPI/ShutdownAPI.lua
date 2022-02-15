local Http = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local secrets = require(ServerStorage.Storage.Modules.secrets)

local Endpoints = {
	OUTBOUND_SDS = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/shutdowns",
	DELETE_OUTBOUND_SD = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/shutdowns/%d",
}

return function()
	-- Clear all kicks
	Http:RequestAsync({
		Url = Endpoints.OUTBOUND_SDS,
		Method = "DELETE",
		Headers = {
			["Authorization"] = secrets["NS_API_AUTHORIZATION"],
		},
	})
	while true do
		local data = Http:GetAsync(Endpoints.OUTBOUND_SDS, false, {
			["Authorization"] = secrets["NS_API_AUTHORIZATION"],
		})
		data = Http:JSONDecode(data)
		if data.status == "ok" then
			for _, dict in ipairs(data.data) do
				local uuid, reason, executor = dict._ID, dict.reason, dict.executor
				local executorName = Players:GetNameFromUserIdAsync(executor)

				-- Kick
				local Format
				if reason ~= "" then
					Format = ("Server shutdown by %s: %s\n%s"):format(executorName, reason, tostring(uuid))
				else
					Format = ("Server shutdown by %s!\n%s"):format(executorName, tostring(uuid))
				end

				for _, b in ipairs(Players:GetPlayers()) do
					b:Kick(Format)
				end

				-- Send delete request
				local function requestDelete()
					Http:RequestAsync({
						Url = Endpoints.DELETE_OUTBOUND_KICK:format(uuid),
						Method = "DELETE",
						Headers = {
							["Authorization"] = secrets["NS_API_AUTHORIZATION"],
						},
					})
				end

				task.delay(1, requestDelete)
			end
		else
			error(data.error)
		end
		task.wait(5)
	end
end
