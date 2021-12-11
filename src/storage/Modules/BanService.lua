--[[
	An extensible ban module by Aerosphia.	
]]

local banService = {}

--

local RunService = game:GetService("RunService")

if RunService:IsClient() then
	error("BanService is somehow running on the client!")
end

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BanStore = DataStoreService:GetDataStore("PlayerBanStore")

local Promise = require(ReplicatedStorage.Shared.Promise)

local Settings = {
	storeKey = "playerBans//",
}

local retry = {}

--

function retry.Set(dataStore, dataKey, count, data)
	return Promise.new(function(resolve,reject)
		count = tonumber(count)
		local ok,result
		for _ = 1,count do
			ok,result = pcall(
				dataStore.SetAsync, 
				dataStore, 
				dataKey, 
				data
			)
			if ok then
				resolve( result )
			end
			task.wait(.1)
		end
		if not ok then
			reject( result )
		end
	end)
end

function retry.Get(dataStore, dataKey, count)
	return Promise.new(function(resolve,reject)
		count = tonumber(count)
		local ok,result,data
		for _ = 1,count do
			ok,result = pcall(function()
				data = dataStore:GetAsync(dataKey)
			end)
			if ok then
				resolve( data )
			end
			task.wait(.1)
		end
		if not ok then
			reject( result )
		end
	end)
end

function retry.Remove(dataStore, dataKey, count)
	return Promise.new(function(resolve,reject)
		count = tonumber(count)
		local ok,result
		for _ = 1,count do
			ok,result = pcall(
				dataStore.RemoveAsync, 
				dataStore, 
				dataKey
			)
			if ok then
				resolve( result )
			end
			task.wait(.1)
		end
		if not ok then
			reject( result )
		end		
	end)
end

--

function banService:Add(Id, Executor, Reason)
	local _, Err = pcall( 
		BanStore.SetAsync,
		BanStore,
		Settings.storeKey..Id, 
		{true, Executor, Reason} 
	)
	if Err then
		local err
		retry.Set(nil, BanStore, Settings.storeKey..Id, 5, {true, Executor, Reason} ):catch(function(errorMsg)
			err = errorMsg
		end):await()
		if err then
			return "Error: "..err
		end
	end
end

function banService:Remove(Id)
	local _, Err = pcall(
		BanStore.RemoveAsync, 
		BanStore,
		Settings.storeKey..Id
	)
	if Err then
		local err
		retry.Remove(nil, BanStore, Settings.storeKey..Id, 5):catch(function(errorMsg)
			err = errorMsg
		end):await()
		if err then
			return "Error: "..err
		end
	end
end

function banService:GetBanInfo(Id)
	local isBanned, executorId, banReason
	
	local _, Err = pcall(function()
		local getData = BanStore:GetAsync( Settings.storeKey..Id )
		if getData ~= nil then
			isBanned,executorId,banReason = unpack(getData)
		end
	end)
	
	if Err then
		local err
		retry.Get(nil, BanStore, Settings.storeKey..Id, 5):andThen(function(result)
			isBanned, executorId, banReason = unpack(result)
		end):catch(function(errorMsg)
			err = errorMsg
		end)
		if err then
			return "Error: "..err
		end
	end

	return isBanned, banReason, executorId
end

--

return banService