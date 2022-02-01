local Http = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")

local BanService = require(ServerStorage.Storage.Modules.BanService)
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
				local id = dict.toUnbanID

				-- Check to see that a ban exists
				local Banned = BanService:GetBanInfo(id)
				if not Banned then
					return
				end

				-- Remove from Roblox DataStore
				local banServiceError = BanService:Remove(id)
				if banServiceError then
					error(banServiceError)
				end

				task.wait(1)

				-- Send delete request
				local function requestDelete()
					Http:RequestAsync({
						Url = Endpoints.DELETE_OUTBOUND_UNBAN:format(id),
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
