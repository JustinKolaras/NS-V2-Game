local Http = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Shared.Promise)
local BanService = require(ServerStorage.Storage.Modules.BanService)
local secrets = require(ServerStorage.Storage.Modules.secrets)

local Endpoints = {
	OUTBOUND_UNBANS = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/unbans",
	DELETE_OUTBOUND_UNBAN = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/unbans/%d",
}

local function promisify(callback)
	return Promise.promisify(callback)
end

return function()
	while true do
		local data = Http:GetAsync(Endpoints.OUTBOUND_UNBANS, false, {
			["Authorization"] = secrets["NS_API_AUTHORIZATION"],
		})
		data = Http:JSONDecode(data)
		if data.status == "ok" then
			for _, dict in ipairs(data.data) do
				local id = dict.toUnbanID

				-- If the ban doesn't exist, we still will want to remove it.

				-- Send delete request
				promisify(function()
					Http:RequestAsync({
						Url = Endpoints.DELETE_OUTBOUND_UNBAN:format(id),
						Method = "DELETE",
						Headers = {
							["Authorization"] = secrets["NS_API_AUTHORIZATION"],
						},
					})
				end)

				-- Remove from Roblox DataStore
				local banServiceError = promisify(function()
					BanService:Remove(id)
				end)():await()
				if banServiceError then
					warn(banServiceError)
				end
			end
		else
			error(data.error)
		end
		task.wait(5)
	end
end
