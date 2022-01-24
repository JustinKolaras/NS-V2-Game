local Key = {}

local moduleConfig = {
	used = {},
}

function Key.new(Chars)
	local currentKey = "_."
	for _ = 1, Chars do
		currentKey = currentKey .. string.char(math.random(127))
	end

	if not moduleConfig.used[currentKey] then
		table.insert(moduleConfig.used, currentKey)
		return currentKey
	else -- Chances are astronomically low, but never 0!
		repeat
			task.wait(0.1)
			currentKey = "_."
			for _ = 1, Chars do
				currentKey = currentKey .. string.char(math.random(127))
			end
		until not moduleConfig.used[currentKey]
		table.insert(moduleConfig.used, currentKey)
		return currentKey
	end
end

return Key
