local Http = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local Util = require(ReplicatedStorage.Shared.Util)
local secrets = require(ServerStorage.Storage.Modules.secrets)

local Endpoints = {
	OUTBOUND_BANS = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/bans",
	DELETE_OUTBOUND_BAN = "https://ns-api-nnrz4.ondigitalocean.app/api/remote/outbound/bans/%d",
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

				-- Add to Roblox DataStore
				local date = Util:GetUTCDate() .. " UTC"
				local banServiceError = BanService:Add(id, executor, reason, date)
				if banServiceError then
					error(banServiceError)
				end

				task.wait(1)

				-- Kick if in-game
				local Format = ("\nBanned from all servers!\nModerator: %s\nReason: %s\n%s"):format(
					Players:GetNameFromUserIdAsync(executor),
					reason,
					date
				)

				local playerObject = Players:GetPlayerByUserId(id)
				if playerObject then
					playerObject:Kick(Format)
				end

				-- Send delete request
				local function requestDelete()
					Http:RequestAsync({
						Url = Endpoints.DELETE_OUTBOUND_BAN:format(id),
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
