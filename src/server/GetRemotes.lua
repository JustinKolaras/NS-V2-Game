local Http = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local Util = require(ReplicatedStorage.Shared.Util)
local env = require(ServerStorage.Storage.Modules.env)

local Endpoints = {
	OUTBOUND_BANS = "https://NS/api/remote/outbound/bans",
	DELETE_OUTBOUND_BAN = "https://NS/api/remote/outbound/bans/%d",
}

return function()
	while true do
		local data
		local ok, err = pcall(function()
			data = Http:GetAsync(Endpoints.OUTBOUND_BANS)
		end)
		if ok then
			for _, dict in ipairs(data) do
				-- Add to Roblox DataStore
				local date = Util:GetUTCDate() .. " UTC"
				local bsErr = BanService:Add(dict.toBanID, dict.executor, dict.reason, date)
				if bsErr then
					error(bsErr)
				end

				-- Kick if in-game
				local Format = ("\nBanned from all servers!\nModerator: %s\nReason: %s\n%s"):format(
					Players:GetNameFromUserIdAsync(dict.executor),
					dict.reason,
					date
				)

				local playerObject = Players:GetPlayerByUserId(dict.toBanID)
				if playerObject then
					playerObject:Kick(Format)
				end

				-- Send delete request
				local function requestDelete()
					pcall(function()
						Http:RequestAsync({
							Url = Endpoints.DELETE_OUTBOUND_BAN:format(dict.toBanID),
							Method = "DELETE",
							Headers = {
								["Authorization"] = env["NS_API_AUTHORIZATION"],
							},
						})
					end)
				end

				task.delay(1, requestDelete)
			end
		else
			error(err)
		end
		task.wait(20)
	end
end
