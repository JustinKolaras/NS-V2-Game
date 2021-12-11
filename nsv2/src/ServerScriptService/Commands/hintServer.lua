local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Event = ReplicatedStorage.Events:FindFirstChild("CmdrHintBoundary")

return function (Context, Text)
	
	if not Text then
		Event:FireAllClients('Deactivate')
		return "Reverted broadcast message to normal flow."
	end
	
	-- See if the Text is above the character limit.
	if Text:len() > 150 then
		return "Reason too long."
	end
	
	-- Filter string for broadcast.
	local cleanText
	
	local success,errorMsg = pcall(function()
		cleanText = TextService:FilterStringAsync(Text, Context.Executor.UserId)
	end)
	
	cleanText = cleanText:GetNonChatStringForBroadcastAsync()
	
	if success then
		Event:FireAllClients('Activate', cleanText)
		return "Changed broadcast message successfully: "..cleanText
	else
		return "Error: "..tostring(errorMsg)
	end	
	
end