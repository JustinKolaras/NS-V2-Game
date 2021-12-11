local util = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Shared.Promise)

--[=[
    Recursively looks through the ancestors of 'Current' until 'Ancestor' is found.

    @param Ancestor Instance -- The ancestor you want to look for
    @param Current Instance -- The current instance you want to start with
    @return Instance -- Returns the ancestor
]=]
function util:FindAbsoluteAncestor(Ancestor, Current)
	local toReturn
	repeat
		if toReturn and toReturn.Parent == nil then 
			return nil 
		end
		if Current then
			toReturn = Current.Parent
		elseif toReturn then
			toReturn = toReturn.Parent
		end
		if Current then 
			Current = nil 
		end
	until (toReturn.Name == Ancestor.Name) and (toReturn.ClassName == Ancestor.ClassName)
	return toReturn
end

--[=[
    Uses the Promise library to wait for a child of a specific class.
    If after the timeout (in seconds), there is still no valid child, this function will cancel and resolve.

    @param Parent Instance -- The parent of which is looking for a child
    @param Class Class -- The class of the child you want to retrieve
    @return Promise<Instance> -- Returns the ancestor
]=]
function util:WaitForChildOfClass(Parent, Class, Timeout)
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
					warn(("Timeout reached on:\n%s waiting for %s"):format(tostring(Parent), Class))
					if (temp) and (temp.Connected) then
						temp:Disconnect()
						temp = nil
						resolve()
					end
				end
			end)
		end
	end)
end

-- Waits for the specified object to receive a new parent.
-- If p is provided, it will only return the result if p is the new parent.
-- If after the timeout (in seconds), there is still no new parent, this function will cancel and resolve.
-- Returns Promise (result)
function util:WaitForNewParent(obj, timeout, p)
	return Promise.new(function(resolve)
		local temp
		local disregard
		if p and obj.Parent == p then
			disregard = true
			resolve(obj.Parent)
		end
		if not disregard then
			temp = obj:GetPropertyChangedSignal("Parent"):Connect(function(it)
				if (p and it == p) or (not p) then
					disregard = true
					temp:Disconnect()
					temp = nil
					resolve(it)
				end
			end)
			Promise.delay(timeout):andThen(function()
				if not disregard then 
					warn(("Timeout reached on:\n%s waiting for a new parent"):format(tostring(obj)))
					if (temp) and (temp.Connected) then
						temp:Disconnect()
						temp = nil
						resolve()
					end
				end
			end)
		end
	end)
end

-- Creates an instance with the provided properties.
-- Returns the instance created
function util:Create(obj, properties)
	local toReturn = Instance.new(obj)
	if properties then
		for a,b in next,properties do
			toReturn[a] = b
		end
	end
	return toReturn
end

-- Clones an instance with the provided properties.
-- Returns the instance cloned
function util:Clone(obj, properties)
	local toReturn = obj:Clone()
	if properties then
		for a,b in next,properties do
			toReturn[a] = b
		end
	end
	return toReturn
end

-- Moves all children in obj1 to obj2. If dObj1 is true, obj1 will be destroyed after all children were moved.
-- Returns nothing
function util:MoveChildren(obj1, obj2, dObj1)
	for a,b in next,obj1:GetChildren() do
		b.Parent = obj2
	end
	if dObj1 then
		obj1:Destroy()
	end
end

return util