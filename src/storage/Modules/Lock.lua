local l = {}
local isLocked,lockReason,contextExecutor = false,"",nil

function l:Lock(r,e)
	if isLocked and #lockReason > 0 then
		return "Already locked: "..lockReason.." ("..tostring(contextExecutor)..")"
	elseif isLocked then
		return "Already locked. ("..tostring(contextExecutor)..")"
	end
	isLocked = true
	lockReason = r or ""
	contextExecutor = e
end

function l:Unlock()
	if not isLocked then
		return "Not locked."
	end
	isLocked = false
	lockReason = ""
	contextExecutor = nil
end

function l:Status()
	return isLocked,lockReason,contextExecutor
end

return l