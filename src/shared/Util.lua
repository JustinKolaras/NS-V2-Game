--- @class Util
---
--- Holds all utility functions; developed by Aerosphia.

local Util = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Shared.Promise)

--[=[
	Recursively looks through the ancestors of 'Current' until 'Ancestor' is found.

	@param Ancestor Instance -- The ancestor you want to look for
	@param Current Instance -- The current instance you want to start with
	@return Instance
]=]
function Util:FindAbsoluteAncestor(Ancestor: Instance, Current: Instance): (Instance?)
	local toReturn
	local currentNoTypes = Current
	repeat
		if toReturn and toReturn.Parent == nil then
			return nil
		end
		if currentNoTypes then
			toReturn = currentNoTypes.Parent
			currentNoTypes = nil
		elseif toReturn then
			toReturn = toReturn.Parent
		end
	until toReturn == Ancestor
	return toReturn
end

--[=[
	Finds a specific descendant held by the ancestor.

	@param Ancestor Instance -- The ancestor to search through
	@param Descendant string -- The descendant's name to find
	@return Instance
]=]
function Util:FindFirstDescendant(Ancestor: Instance, Descendant: string): (Instance?)
	for _, inst in ipairs(Ancestor:GetDescendants()) do
		if inst.Name == Descendant then
			return inst
		end
	end
	return nil
end

--[=[
	Uses the Promise library to wait for a child of a specific class.
	If after the timeout (in seconds), there is still no valid child, this function will cancel and resolve.

	@param Parent Instance -- The parent of which is looking for a child
	@param Class string -- The class of the child you want to retrieve
	@param Timeout number -- The timeout, in seconds, of this function to automatically resolve
	@return Promise<Instance>
]=]
function Util:WaitForChildOfClass(Parent: Instance, Class: string, Timeout: number)
	return Promise.new(function(resolve)
		local temp
		local disregard
		if Parent:FindFirstChildOfClass(Class) then
			disregard = true
			resolve(Parent:FindFirstChildOfClass(Class))
		end
		if not disregard then
			temp = Parent.ChildAdded:Connect(function(it)
				if it:IsA(Class) then
					disregard = true
					temp:Disconnect()
					temp = nil
					resolve(it)
				end
			end)
			Promise.delay(Timeout):andThen(function()
				if not disregard then
					warn(("Timeout reached on:\n%s waiting for %s"):format(Parent.Name, Class))
					if temp and temp.Connected then
						temp:Disconnect()
						temp = nil
						resolve()
					end
				end
			end)
		end
	end)
end

--[=[
	Uses the Promise library to wait for a child to receive a new parent.
	If a parent is provided, this function will only return a result if the new parent matches such.
	If after the timeout (in seconds), there is still no valid parent, this function will cancel and resolve.

	@param Object Instance -- The object to receive a new parent
	@param Timeout number -- The timeout, in seconds, of this function to automatically resolve
	@param Parent? Instance -- The optional parent object to validate before resolving
	@return Promise<Instance>
]=]
function Util:WaitForNewParent(Object: Instance, Timeout: number, Parent: Instance?)
	return Promise.new(function(resolve)
		local temp
		local disregard
		if Parent and Object.Parent == Parent then
			disregard = true
			resolve(Object.Parent)
		end
		if not disregard then
			temp = Object:GetPropertyChangedSignal("Parent"):Connect(function(it)
				if (Parent and it == Parent) or not Parent then
					disregard = true
					temp:Disconnect()
					temp = nil
					resolve(it)
				end
			end)
			Promise.delay(Timeout):andThen(function()
				if not disregard then
					warn(
						("Timeout reached on:\n%s waiting for a new parent (%s)"):format(
							Object.Name,
							if Parent then Parent.Name else ""
						)
					)
					if temp and temp.Connected then
						temp:Disconnect()
						temp = nil
						resolve()
					end
				end
			end)
		end
	end)
end

--[=[
	Creates an instance with the provided properties.

	@param Object string -- The class of the object to create
	@param Properties dict -- Key-value pair table representing k as the property and v as the value
	@return Instance
]=]
function Util:Create(Object: string, Properties: { [string]: any }?): (Instance)
	local toReturn = Instance.new(Object)
	if Properties then
		for a: string, b: any in pairs(Properties) do
			toReturn[a] = b
		end
	end
	return toReturn
end

--[=[
	Clones an instance with the provided properties.

	@param Object Instance -- The object to clone from
	@param Properties dict -- Key-value pair table representing k as the property and v as the value
	@return Instance
]=]
function Util:Clone(Object: Instance, Properties: { [string]: any }?): (Instance)
	local toReturn = Object:Clone()
	if Properties then
		for a: string, b: any in pairs(Properties) do
			toReturn[a] = b
		end
	end
	return toReturn
end

--[=[
	Moves children from Previous to Next.
	If shouldDelete is true, Previous will be destroyed after the conversion has been made.

	@param Previous Instance -- The instance to move children from
	@param Next Instance -- The instance to move children to
	@param shouldDelete? boolean -- Specifies if Previous should be deleted after the conversion
	@return void
]=]
function Util:MoveChildren(Previous: Instance, Next: Instance, shouldDelete: boolean?): ()
	for _, b: Instance in ipairs(Previous:GetChildren()) do
		b.Parent = Next
	end
	if shouldDelete then
		Previous:Destroy()
	end
end

--[=[
	Uses the Promise library to wait for the callback in "callbackFn" to produce a truthy value.
	A timeout can be paired to this, using :timeout() with the Promise library.

	Only works with :await() paired to it.

	@param callbackFn function -- The callback function to return at
	@return Promise<void>
]=]
function Util:WaitUntil(callbackFn: (nil) -> (nil))
	return Promise.defer(function(resolve)
		while true do
			local callback = callbackFn()
			if callback then
				resolve()
			end
			task.wait()
		end
	end)
end

--[=[
	Prefaces numbers under the select digit count with zeros.
	i.e Calling this function with a digit count of 2 and a number of "1" will return "01"

	@param transformer number -- The number to transform
	@param digitCount number -- The digits to return
	@return number
]=]
function Util:PrefaceZeroes(transformer: number, digitCount: number): (number)
	local newNumber = transformer

	while #tostring(newNumber) < digitCount do
		newNumber = 0 .. newNumber
	end

	return newNumber
end

--[=[
	Returns a formatted UTC date.

	@return string
]=]
function Util:GetUTCDate(): (string)
	local utcTime = os.date("!*t")

	return ("%s-%s-%s %s:%s:%s"):format(
		Util:PrefaceZeroes(utcTime.year, 4),
		Util:PrefaceZeroes(utcTime.month, 2),
		Util:PrefaceZeroes(utcTime.day, 2),
		Util:PrefaceZeroes(utcTime.hour, 2),
		Util:PrefaceZeroes(utcTime.min, 2),
		Util:PrefaceZeroes(utcTime.sec, 2)
	)
end

--[=[
	Requires the specified value to meet callback function criteria.
	If the callback function returns a truthy value, the value will be returned back.
	Otherwise, nil will be returned.

	@param item any -- The item to inspect
	@param callbackFn function -- The callback function to return at (must return a boolean)
	@return any | nil
]=]
function Util:Inspect(item: any, callbackFn: (nil) -> (boolean)): (any)
	return if callbackFn() then item else nil
end

--[=[
	Cycles through an array of booleans.
	If all booleans meet the conditioner, this function returns true.

	@param looper array -- The array to loop through
	@param conditioner? boolean | function -- The conditions to meet (defaults to true)
	@return boolean
]=]
function Util:Logical_All(looper: { boolean }, conditioner: boolean | (nil) -> (boolean)?): (boolean)
	local function Validate(value)
		if typeof(conditioner) == "function" then
			return conditioner(value)
		elseif conditioner then
			return conditioner
		else
			return true
		end
	end
	for _, val in ipairs(looper) do
		if not Validate(val) then
			return false
		end
	end
	return true
end

--[=[
	Cycles through an array of booleans.
	If any boolean meets the conditioner, this function returns true.

	@param looper array -- The array to loop through
	@param conditioner? boolean | function -- The conditions to meet (defaults to true)
	@return boolean
]=]
function Util:Logical_Any(looper: { boolean }, conditioner: boolean | (nil) -> (boolean)?): (boolean)
	local function Validate(value)
		if typeof(conditioner) == "function" then
			return conditioner(value)
		elseif conditioner then
			return conditioner
		else
			return value
		end
	end
	for _, val in ipairs(looper) do
		if Validate(val) then
			return true
		end
	end
	return false
end

return Util
