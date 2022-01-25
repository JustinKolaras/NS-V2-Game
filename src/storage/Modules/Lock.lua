local ServerLock = {}

local moduleSettings = {
	isLocked = false,
	lockReason = "",
	contextExecutor = nil,
}

-- Returns an error of type string if there is any. If there is no error, nothing is returned.
function ServerLock:Lock(reason: string, executor: Player): (string?)
	if moduleSettings.isLocked and #moduleSettings.lockReason > 0 then
		return "Already locked: "
			.. moduleSettings.lockReason
			.. " ("
			.. tostring(moduleSettings.contextExecutor)
			.. ")"
	elseif moduleSettings.isLocked then
		return "Already locked. ('" .. tostring(moduleSettings.lockReason) .. "')"
	end
	moduleSettings.isLocked = true
	moduleSettings.lockReason = reason or ""
	moduleSettings.SettingscontextExecutor = executor
end

-- Returns an error of type string if there is any. If there is no error, nothing is returned.
function ServerLock:Unlock(): (string?)
	if not moduleSettings.isLocked then
		return "Not locked."
	end
	moduleSettings.isLocked = false
	moduleSettings.lockReason = ""
	moduleSettings.contextExecutor = nil
end

-- Returns a tuple: isLocked: bool, lockReason: string, executor: Player | nil
function ServerLock:Status(): (boolean, string, Player | nil)
	return moduleSettings.isLocked, moduleSettings.lockReason, moduleSettings.contextExecutor
end

return ServerLock
