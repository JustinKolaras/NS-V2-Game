local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Event = ReplicatedStorage.Events:FindFirstChild("Hint")

return function(Context, Text)
	if not Text then
		Event:FireAllClients("Deactivate")
		return "Reverted broadcast message to normal flow."
	end

	if Text:len() > 150 then
		return "Error: Reason too long. Cap: 150chars"
	end

	local cleanText

	local success, errorMsg = pcall(function()
		cleanText = TextService:FilterStringAsync(Text, Context.Executor.UserId)
	end)

	cleanText = cleanText:GetNonChatStringForBroadcastAsync()

	if success then
		Event:FireAllClients("Activate", cleanText)
		return "Changed broadcast message successfully: " .. cleanText
	else
		return "Error: " .. tostring(errorMsg)
	end
end
