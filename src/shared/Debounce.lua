-- A library by Aerosphia for easier management of debounces.

local Debounce = {}

local Config = {
	Index = {},
}

-- Initiates debounce on an ID
function Debounce:LockState(options: { [string]: any }): ()
	local ID, length = options._ID, options.length
	if Config.Index[ID] then
		error(("ID already in use\n\n%s"):format(debug.traceback()))
	end
	Config.Index[ID] = true
	task.delay(length, function()
		Config.Index[ID] = nil
		if options.callback then
			options.callback()
		end
	end)
end

-- Checks debounce state on an ID
-- Returns false if the debounce isn't currently pending
function Debounce:State(options: { [string]: any }): (boolean)
	local ID = options._ID
	return if Config.Index[ID] then true else false -- This seems unusual, but Config.Index[ID] would normally return the actual value; not a bool.
end

-- Force cahnges a Debounce ID's state
function Debounce:Force(options: { [string]: any }): ()
	local ID, value = options._ID, options.value
	if not Config.Index[ID] then
		error(("ID not in use\n\n%s"):format(debug.traceback()))
	end
	Config.Index[ID] = if value then true else nil
end

return Debounce
