local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Messaging = game:GetService("MessagingService")

local Admins = require(ServerStorage.Storage.Modules.Admins)
local Util = require(ReplicatedStorage.Shared.Util)

return function(Context, Victim, Reason)
	local Executor = Context.Executor

	if Victim == Executor.UserId then
		return "Error: You can't perform this action on yourself."
	end

	for _, b in next, Admins do
		if b == Victim then
			return "Error: You can't perform this action on another moderator."
		end
	end

	if #Reason > 85 then
		return "Error: Reason too long. Cap: 85chars"
	end

    return "Under maintenance"
end
