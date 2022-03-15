local Http = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local Util = require(ReplicatedStorage.Shared.Util)
local GameModLogs = require(ServerStorage.Storage.WebhookPresets.GameModLogs)
local secrets = require(ServerStorage.Storage.Modules.secrets)

local Endpoints = {
	OUTBOUND_BANS = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/bans",
	DELETE_OUTBOUND_BAN = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/bans/%d",
	OUTBOUND_UNBANS = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/unbans",
}

return function()
	while true do
		local data = Http:GetAsync(Endpoints.OUTBOUND_BANS, false, {
			["Authorization"] = secrets["NS_API_AUTHORIZATION"],
		})
		data = Http:JSONDecode(data)
		if data.status == "ok" then
			for _, dict in ipairs(data.data) do
				local id, reason, executor = dict.toBanID, dict.reason, dict.executor
				local executorName = Players:GetNameFromUserIdAsync(executor)

				-- If they have an outgoing unban, we want to ignore them entirely
				local unbanData = Http:GetAsync(Endpoints.OUTBOUND_UNBANS, false, {
					["Authorization"] = secrets["NS_API_AUTHORIZATION"],
				})
				unbanData = Http:JSONDecode(unbanData)
				for _, uDict in ipairs(unbanData.data) do
					if uDict.toUnbanID == id then
						return
					end
				end

				-- Send delete request
				Http:RequestAsync({
					Url = Endpoints.DELETE_OUTBOUND_BAN:format(id),
					Method = "DELETE",
					Headers = {
						["Authorization"] = secrets["NS_API_AUTHORIZATION"],
					},
				})

				-- Check if ban exists already
				local Banned = BanService:GetBanInfo(id)
				if Banned then
					return
				end

				-- Send to mod log channel
				local err, result = GameModLogs:SendBan({
					ExecutorName = executorName,
					VictimName = Players:GetNameFromUserIdAsync(id),
					VictimID = id,
					Reason = reason,
				})

				if err then
					warn(result)
				end

				-- Add to Roblox DataStore
				local date = Util:GetUTCDate() .. " UTC"
				local apiResult = BanService:Add(id, executor, reason, date)
				if apiResult.status == "error" then
					error(apiResult.error)
				end

				-- Kick if in-game
				local Format = ("\nBanned from all servers!\nModerator: %s\nReason: %s\n%s"):format(
					executorName,
					reason,
					date
				)

				local playerObject = Players:GetPlayerByUserId(id)
				if playerObject then
					playerObject:Kick(Format)
				end
			end
		else
			error(data.error)
		end
		task.wait(10)
	end
end
