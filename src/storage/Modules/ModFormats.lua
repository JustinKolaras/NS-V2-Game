local Players = game:GetService("Players")

return function (Starter, ...)
	if Starter == "Kick" then
		local Data = {...}
		local Executor,Reason = Data[1],Data[2]
		return ("\nKicked\nModerator: %s\nReason: %s"):format(Executor.Name, tostring(Reason))
	elseif Starter == "Ban" then
		local Data = {...}
		local ExecutorId,Reason = Data[1],Data[2]
		return ("\nBanned from all servers!\nModerator: %s\nReason: %s"):format(Players:GetNameFromUserIdAsync(ExecutorId) , tostring(Reason))
	end
end