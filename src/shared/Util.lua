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
	repeat
		if toReturn and toReturn.Parent == nil then
			return nil
		end
		if Current then
			toReturn = Current.Parent
			Current = nil
		elseif toReturn then
			toReturn = toReturn.Parent
		end
	until (toReturn.Name == Ancestor.Name) and (toReturn.ClassName == Ancestor.ClassName)
	return toReturn
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
		for a, b in pairs(Properties) do
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
		for a, b in pairs(Properties) do
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
	for _, b in ipairs(Previous:GetChildren()) do
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

return Util
