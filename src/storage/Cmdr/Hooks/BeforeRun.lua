--[[
	Two groups:
	Admin - Roleset 252+ (Moderator)
	Owner - Roleset 254+ (Owner)
]]

return function(registry)
	registry:RegisterHook("BeforeRun", function(Context)
		if (Context.Executor:GetRankInGroup(8046949) < 252) and (Context.Executor.UserId ~= tonumber("-1")) then
			Context.Executor:Kick()
			return "Access Denied"
		end

		-- Access is by default granted to every Moderator, so we just have to restrict the Owner-only commands.

		if
			(Context.Group == "Owner")
			and (Context.Executor:GetRankInGroup(8046949) < 254)
			and (Context.Executor.UserId ~= tonumber("-1"))
		then
			return "You must be at or above the rank of Owner to run commands in this category."
		end
	end)
end
