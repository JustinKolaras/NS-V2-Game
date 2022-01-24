local ServerLock = {}

local moduleSettings = {
	isLocked = false,
	lockReason = "",
	contextExecutor = nil,
}

function ServerLock:Lock(reason: string, executor: Player): (string?)
	if moduleSettings.isLocked and #moduleSettings.lockReason > 0 then
		return "Already locked: " .. moduleSettings.lockReason .. " (" .. tostring(moduleSettings.contextExecutor) .. ")"
	elseif isLocked then
		return "Already locked. ('" .. tostring(moduleSettings.lockReason) .. "')"
	end
	moduleSettings.isLocked = true
	moduleSettings.lockReason = reason or ""
	module.SettingscontextExecutor = executor
end

function ServerLock:Unlock(): (string?)
	if not moduleSettings.isLocked then
		return "Not locked."
	end
	moduleSettings.isLocked = false
	moduleSettings.lockReason = ""
	moduleSettings.contextExecutor = nil
end

function ServerLock:Status(): (boolean, string, Player | nil)
	return moduleSettings.isLocked, moduleSettings.lockReason, moduleSettings.contextExecutor
end

return ServerLock
