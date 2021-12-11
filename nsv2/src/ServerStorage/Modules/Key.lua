local key = {}

local moduleConfig = {
	used = {},
}

function key.new(Chars)
	local Key = '_.'
	for i = 1,Chars do
		Key = Key..string.char(math.random(127))
	end
	
	if not moduleConfig.used[Key] then
		table.insert(moduleConfig.used, Key)
		return Key 
	else
		repeat
			task.wait(.1)
			Key = '_.'
			for i=1,Chars do
				Key = Key..string.char(math.random(127))
			end
		until not moduleConfig.used[Key]
		table.insert(moduleConfig.used, Key)
		return Key
	end
end

return key