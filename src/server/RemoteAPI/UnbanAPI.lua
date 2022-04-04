local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local GameModLogs = require(ServerStorage.Storage.WebhookPresets.GameModLogs)
local secrets = require(ServerStorage.Storage.Modules.secrets)

local Endpoints = {
	OUTBOUND_UNBANS = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/unbans",
	DELETE_OUTBOUND_UNBAN = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/unbans/%d",
}

return function()
	while true do
		local data = Http:GetAsync(Endpoints.OUTBOUND_UNBANS, false, {
			["Authorization"] = secrets["NS_API_AUTHORIZATION"],
		})
		data = Http:JSONDecode(data)
		if data.status == "ok" then
			for _, dict in ipairs(data.data) do
				local id, executor = dict.toUnbanID, dict.executor
				local executorName = Players:GetNameFromUserIdAsync(executor)

				-- If the ban doesn't exist, we still will want to remove it.

				-- Send delete request
				Http:RequestAsync({
					Url = Endpoints.DELETE_OUTBOUND_UNBAN:format(id),
					Method = "DELETE",
					Headers = {
						["Authorization"] = secrets["NS_API_AUTHORIZATION"],
					},
				})

				-- Send to mod log channel
				local err, result = GameModLogs:SendUnban({
					ExecutorName = executorName,
					VictimName = Players:GetNameFromUserIdAsync(id),
					VictimID = id,
				})

				if err then
					warn(result)
				end

				-- Remove from Roblox DataStore
				local apiResult = BanService:Remove(id)
				if apiResult.status == "error" then
					error(apiResult.error)
				end
			end
		else
			error(data.error)
		end
		task.wait(10)
	end
end
