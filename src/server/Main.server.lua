-- This is the main "entry point" of the game, which handles new players and connects various systems.

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Messaging = game:GetService("MessagingService")
local Players = game:GetService("Players")

local Physics = game:GetService("PhysicsService")
Physics:CreateCollisionGroup("p")
Physics:CollisionGroupSetCollidable("p", "p", false)

local BanService = require(ServerStorage.Storage.Modules.BanService)
local Lock = require(ServerStorage.Storage.Modules.Lock)

ReplicatedStorage:WaitForChild("Events")
local SetCoreEvent = ReplicatedStorage.Events:FindFirstChild("SetCore")

-- Initiate API
local RemoteAPIFolder = script.Parent.RemoteAPI
for _, b in ipairs(RemoteAPIFolder:GetChildren()) do
	task.spawn(require(b))
end

local function NoCollide(model)
	for _, v in next, model:GetChildren() do
		if v:IsA("BasePart") then
			Physics:SetPartCollisionGroup(v, "p")
		end
	end
end

Players.PlayerAdded:Connect(function(Player)
	local Banned, Reason, ExecutorId, Date, System = BanService:GetBanInfo(Player.UserId)
	if Banned then
		return Player:Kick(
			("\nBanned from all servers!\nModerator: %s\nReason: %s\n%s"):format(
				if System then "System" else Players:GetNameFromUserIdAsync(ExecutorId),
				Reason,
				Date
			)
		)
	end
	local lockStatus, lockReason = Lock:Status()
	if lockStatus then
		if Player:GetRankInGroup(8046949) < 252 then -- Game mods are immune
			return Player:Kick(if #lockReason > 0 then "\nLocked\n" .. lockReason else "This server is locked.")
		end
	end

	local connection
	connection = Player.CharacterAdded:Connect(function(Character)
		Character:WaitForChild("HumanoidRootPart")
		Character:WaitForChild("Head")
		Character:WaitForChild("Humanoid")
		task.wait(0.1)
		NoCollide(Character)
		connection:Disconnect()
		connection = nil
	end)

	if Player.Character then
		NoCollide(Player.Character)
	end

	SetCoreEvent:FireAllClients("PlayerJoin", Player)
end)

Players.PlayerRemoving:Connect(function(Player)
	SetCoreEvent:FireAllClients("PlayerLeave", Player)
end)

-- Set MessagingService connections for moderation
pcall(function()
	Messaging:SubscribeAsync("Servers:Kick", function(dataTable)
		dataTable = dataTable.Data
		local playerObject = Players:GetPlayerByUserId(dataTable.UserId)
		if playerObject then
			playerObject:Kick(dataTable.Reason)
		end
	end)

	Messaging:SubscribeAsync("Servers:Shutdown", function(dataTable)
		dataTable = dataTable.Data
		for _, b in ipairs(Players:GetPlayers()) do
			b:Kick(dataTable.Reason)
		end
	end)
end)
