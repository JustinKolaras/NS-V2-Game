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

local SetCoreEvent = ReplicatedStorage:WaitForChild("Events").SetCore

local function NoCollide(model)
	for _, v in next, model:GetChildren() do
		if v:IsA("BasePart") then
			Physics:SetPartCollisionGroup(v, "p")
		end
	end
end

Players.PlayerAdded:Connect(function(Player)
	local Banned, Reason, ExecutorId, System = BanService:GetBanInfo(Player.UserId)
	if Banned then
		return Player:Kick(
			("\nBanned from all servers!\nModerator: %s\nReason: %s"):format(
				if System then "System" else Players:GetNameFromUserIdAsync(ExecutorId),
				Reason
			)
		)
	end

	local lockStatus, lockReason = Lock:Status()
	if lockStatus then
		return Player:Kick(if #lockReason > 0 then "\nLocked\n" .. lockReason else "This server is locked.")
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
end)
