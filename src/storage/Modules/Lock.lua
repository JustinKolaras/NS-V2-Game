local LockModule = {}
local isLocked, lockReason, contextExecutor = false, "", nil

function LockModule:Lock(reason, executor)
	if isLocked and #lockReason > 0 then
		return "Already locked: " .. lockReason .. " (" .. tostring(contextExecutor) .. ")"
	elseif isLocked then
		return "Already locked. (" .. tostring(contextExecutor) .. ")"
	end
	isLocked = true
	lockReason = reason or ""
	contextExecutor = executor
end

function LockModule:Unlock()
	if not isLocked then
		return "Not locked."
	end
	isLocked = false
	lockReason = ""
	contextExecutor = nil
end

function LockModule:Status()
	return isLocked, lockReason, contextExecutor
end

return LockModule
