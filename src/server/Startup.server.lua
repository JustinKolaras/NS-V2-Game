local ServerStorage = game:GetService("ServerStorage")
local Messaging = game:GetService("MessagingService")
local Players = game:GetService("Players")
local Chat = require(game.ServerScriptService:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))
local Market = game:GetService("MarketplaceService")

local BanService = require(ServerStorage.Storage.Modules.BanService)
local ChatTags = require(ServerStorage.Storage.Modules.ChatTags)
local Lock = require(ServerStorage.Storage.Modules.Lock)

function getTag(Player)
	local getGroupRank = Player:GetRankInGroup(8046949)
	local tag, color, textColor
	for a, b in next,ChatTags do 
		if (b.Users) and (typeof(b.Users) == "table") then
			for _, d in next,b.Users do
				if Player.UserId == d then
					tag,color = a,b.Color
					if b.Chat then
						textColor = b.Chat
					end
					return tag,color,textColor
				end
			end
		elseif (b.GroupRank) and (typeof(b.GroupRank) == "number") then
			if getGroupRank == b.GroupRank then
				tag,color = a,b.Color
				if b.Chat then
					textColor = b.Chat
				end
				return tag,color,textColor
			end
		elseif (b.MarketPass) and (typeof(b.MarketPass) == "number") then
			if Market:UserOwnsGamePassAsync(Player.UserId,b.MarketPass) then
				tag,color = a,b.Color
				if b.Chat then
					textColor = b.Chat
				end
				return tag,color,textColor
			end
		end
	end
end

Players.PlayerAdded:Connect(function(Player)
	local Banned, Reason, ExecutorId = BanService:GetBanInfo(Player.UserId)
	if Banned then
		return Player:Kick( ("\nBanned from all servers!\nModerator: %s\nReason: %s"):format( Players:GetNameFromUserIdAsync(ExecutorId), Reason) )
	end

	local lockStatus, lockReason = Lock:Status()
	if lockStatus and #lockReason > 0 then
		return Player:Kick("\nLocked\n"..lockReason)
	elseif lockStatus then
		return Player:Kick("This server is locked.")
	end
	
	if Market:UserOwnsGamePassAsync(Player.UserId, 13375778) then -- VIP Gamepass
		local cola = ServerStorage.Tools.Cola
		local colaClone = cola:Clone()
		colaClone.Parent = Player:WaitForChild("StarterGear")
	end
end)

Chat.SpeakerAdded:Connect(function(playerName)
	local speaker = Chat:GetSpeaker(playerName)
	local player = Players[playerName]

	local tag,color,textColor = getTag(player)

	if tag and color then
		speaker:SetExtraData("Tags", {{ TagText = tostring(tag), TagColor = color }})
		if textColor then
			speaker:SetExtraData("ChatColor",textColor)
		end
	end
end)

pcall(function()
	Messaging:SubscribeAsync("Servers:Kick", function(dataTable)
		dataTable = dataTable.Data
		local playerObject = Players:GetPlayerByUserId(dataTable.UserId)
		if playerObject then
			playerObject:Kick(dataTable.Reason)
		end
	end)
end)

