local ServerStorage = game:GetService("ServerStorage")
local Http = game:GetService("HttpService")
local Players = game:GetService("Players")

local Format = require(ServerStorage.Modules['ModFormats'])
local BackupAdmins = require(ServerStorage.Modules['BackupAdminList'])

local httpUrl = 																																"https://discord.com/api/webhooks/868369518462914560/ROHLjG0hSIpfxYpolbLMqmHpHllo2PFpqKoI6xqO1Z2w6AyXaQLwSa4GXDtB32b8UoCl"

local function Log(Executor, Victim, Reason)
	if game:GetService("RunService"):IsStudio() then return end
	
	local Data = {
		['embeds'] = {{
			['title'] = "Player Kicked!",
			['description'] = '**'..Executor.Name..'** kicked **'..Victim.Name..' ('..Victim.UserId..')**: "'..Reason..'"',
			['color'] = 5814783,
		}}
	}

	local finalData = Http:JSONEncode(Data)
	Http:PostAsync(httpUrl, finalData)	
end

return function (Context, Victim, Reason)
	
	if not Reason then return "Reason required." end
	local Executor = Context.Executor
	
	-- See if they are attempting to perform actions on themselves.
	if Victim.UserId == Executor.UserId then
		return "You can't perform this action on yourself."
	end
	-- See if the Victim is an admin.
	for a,b in next,BackupAdmins do
		if b == Victim.UserId then
			return "You can't perform this action on another moderator."
		end
	end
	-- See if the Reason is above the character limit.
	if Reason:len() > 85 then
		return "Reason too long."
	end
	
	local Format = Format("Kick",Executor,Reason)
	
	Victim:Kick(Format)
	
	Log(Executor, Victim, Reason)
	
	return ("Kicked %s (%s) successfully."):format( Victim.Name, Victim.UserId )
	
end