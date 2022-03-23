--[[
	Two groups:
	Admin - Roleset 252+ (Moderator)
	Owner - Roleset 254+ (Owner)
]]

local CommandTeam = require(game:GetService("ServerStorage").Storage.Modules.Command)

return function(registry)
	registry:RegisterHook("BeforeRun", function(Context)
		if (Context.Executor:GetRankInGroup(8046949) < 252) and (Context.Executor.UserId ~= tonumber("-1")) then
			Context.Executor:Kick()
			return "Access Denied"
		end

		if Context.Group == "Command" and not table.find(CommandTeam, Context.Executor.UserId) then
			return "Access Denied"
		end

		if
			(Context.Group == "Owner")
			and (Context.Executor:GetRankInGroup(8046949) < 254)
			and (Context.Executor.UserId ~= tonumber("-1"))
		then
			return "Access Denied"
		end
	end)
end
