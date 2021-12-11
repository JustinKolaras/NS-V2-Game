return function (_, Interval)	
	local partCount = 0
	for _, b in next,workspace:GetDescendants() do
		if b:IsA("BasePart") or b:IsA("UnionOperation") or b:IsA("MeshPart") then
			partCount += 1
		end
	end
	
	for _ ,b in next,workspace:GetDescendants() do
		if b:IsA("BasePart") or b:IsA("UnionOperation") or b:IsA("MeshPart") then
			local fireEffect = Instance.new("Fire")
			fireEffect.Size = 7
			fireEffect.Parent = b
			b.Anchored = false
			task.wait(Interval or .1)
		end
	end
	
	return ('Burned %d parts. <3'):format(partCount)
end