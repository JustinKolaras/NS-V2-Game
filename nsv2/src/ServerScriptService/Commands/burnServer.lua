return function (Context, Interval)	
	local partCount = 0
	for a,b in next,workspace:GetDescendants() do
		if b:IsA("BasePart") or b:IsA("UnionOperation") or b:IsA("MeshPart") then
			partCount += 1
		end
	end
	
	for a,b in next,workspace:GetDescendants() do
		if b:IsA("BasePart") or b:IsA("UnionOperation") or b:IsA("MeshPart") then
			local fireEffect = Instance.new("Fire")
			fireEffect.Size = 7
			fireEffect.Parent = b
			b.Anchored = false
			task.wait(Interval or .1)
		end
	end
	
	return ("Burned %s parts. <3"):format(partCount)
end