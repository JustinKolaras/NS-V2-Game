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

function retry.Set(dataStore: DataStore, dataKey: string, count: number, data: any)
	return Promise.new(function(resolve, reject)
		count = tonumber(count)
		local ok, result
		for _ = 1, count do
			ok, result = pcall(dataStore.SetAsync, dataStore, dataKey, data)
			if ok then
				resolve(result)
			end
			task.wait(0.1)
		end
		if not ok then
			reject(result)
		end
	end)
end

function retry.Get(dataStore: DataStore, dataKey: string, count: number)
	return Promise.new(function(resolve, reject)
		count = tonumber(count)
		local ok, result, data
		for _ = 1, count do
			ok, result = pcall(function()
				data = dataStore:GetAsync(dataKey)
			end)
			if ok then
				resolve(data)
			end
			task.wait(0.1)
		end
		if not ok then
			reject(result)
		end
	end)
end

function retry.Remove(dataStore: DataStore, dataKey: string, count: number)
	return Promise.new(function(resolve, reject)
		count = tonumber(count)
		local ok, result
		for _ = 1, count do
			ok, result = pcall(dataStore.RemoveAsync, dataStore, dataKey)
			if ok then
				resolve(result)
			end
			task.wait(0.1)
		end
		if not ok then
			reject(result)
		end
	end)
end

--

function banService:Add(Id: number, Executor: number, Reason: string | number): (string?)
	local ok, Err = pcall(BanStore.SetAsync, BanStore, Settings.storeKey .. Id, { true, Executor, Reason })
	if not ok then
		retry.Set(BanStore, Settings.storeKey .. Id, 5, { true, Executor, Reason })
			:catch(function(errorMsg)
				Err = errorMsg
			end)
			:await()
		if Err then
			return "Error: " .. tostring(Err)
		end
	end
end

function banService:Remove(Id: number): (string?)
	local ok, Err = pcall(BanStore.RemoveAsync, BanStore, Settings.storeKey .. Id)
	if not ok then
		retry.Remove(BanStore, Settings.storeKey .. Id, 5)
			:catch(function(errorMsg)
				Err = errorMsg
			end)
			:await()
		if Err then
			return "Error: " .. tostring(Err)
		end
	end
end

function banService:GetBanInfo(Id: number): (boolean, string, number)
	local isBanned, executorId, banReason, isSystem

	local ok, Err = pcall(function()
		local getData = BanStore:GetAsync(Settings.storeKey .. Id)
		if getData ~= nil then
			isBanned, executorId, banReason = unpack(getData)
		end
	end)

	if not ok then
		retry.Get(BanStore, Settings.storeKey .. Id, 5)
			:andThen(function(result)
				isBanned, executorId, banReason = unpack(result)
			end)
			:catch(function(errorMsg)
				Err = errorMsg
			end)
		if Err then
			return "Error: " .. tostring(Err)
		end
	end

	isSystem = executorId == "System"

	return isBanned, banReason, executorId, isSystem
end

--

return banService
