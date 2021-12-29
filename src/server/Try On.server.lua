--[[

	TryOn Ver. 1.0
	Developed by Aerosphia

]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Event = ReplicatedStorage.TryOn:FindFirstChild("TryOn Event")
local Function = ReplicatedStorage.TryOn:FindFirstChild("TryOn Function")

local Connections = {}

local Folder = workspace.Mannequins
local Tool = ReplicatedStorage.TryOn["Shopping Bag"]

local Util = require(ReplicatedStorage.Shared.Util)
local Key = require(ServerStorage.Storage.Modules.Key)

local serverConfig = setmetatable({
	Keys = {},
	piStatus = false,
	templatePrefix = "http://www.roblox.com/asset/?id=%s",
	toolName = "Shopping Bag",
	originalClothes = {},
	bagsEquipped = {},
	playerAdded = {},
}, {
	__index = function(_, indx)
		error(
			("Try On::serverConfigError: Attempt to get serverConfig value with a nil index. -> serverConfig[%s]?"):format(
				indx
			),
			2
		)
	end,

	__newindex = function(_, indx, val)
		error(
			("Try On::serverConfigError: New items are disallowed! -> Operation (serverConfig[%s] = %s) failed."):format(
				indx,
				tostring(val)
			),
			2
		)
	end,
})

local templates = {}

local function GetId(Object)
	local result = Object:FindFirstChild("ID")
	return result and result.Value or "nil"
end

local function IsBagEquipped(Player)
	return serverConfig.bagsEquipped[Player.Name]
end

function templates.New(Shirt, Pant)
	return {
		TemplateS = Shirt,
		TemplateP = Pant,
	}
end

function OnClicked(Player, shirtId, pantsId, templateTable, character)
	if IsBagEquipped(Player) then
		Event:FireClient(Player, "Open", shirtId, pantsId, templateTable, character)
	end
end

function customOnMouseClick(Player, TheirTool)
	local _, MouseTarget = pcall(Function.InvokeClient, Function, Player, "MouseTarget")
	local shirt, pants
	if IsBagEquipped(Player) then
		if
			MouseTarget
			and (
				MouseTarget:FindFirstChildOfClass("ClickDetector")
				or MouseTarget.Parent:FindFirstChildOfClass("ClickDetector")
			)
		then
			local ClickDetector = MouseTarget:FindFirstChildOfClass("ClickDetector")
				or MouseTarget.Parent:FindFirstChildOfClass("ClickDetector")
			shirt, pants = ClickDetector.Parent.Shirt, ClickDetector.Parent.Pants
			if Util:FindAbsoluteAncestor(Folder, ClickDetector) then
				if
					(TheirTool.Handle.Position - MouseTarget.Position).Magnitude <= ClickDetector.MaxActivationDistance
				then
					OnClicked(
						Player,
						GetId(shirt),
						GetId(pants),
						templates.New(shirt.ShirtTemplate:match("%d+"), pants.PantsTemplate:match("%d+")),
						ClickDetector.Parent.Parent
					)
				end
			end
		end
	end
end

Event.OnServerEvent:Connect(function(Player, ClientKey, Starter, ...)
	local Data = { ... }
	if serverConfig.Keys[Player.UserId] == ClientKey then
		if Starter == "TryOn" then
			local Character = Player.Character
			local cShirt, cPants = Character.Shirt, Character.Pants
			local s, p = Data[1], Data[2]
			serverConfig.originalClothes[Player.Name] = {}
			serverConfig.originalClothes[Player.Name]["Shirt"] = cShirt.ShirtTemplate:match("%d+")
			serverConfig.originalClothes[Player.Name]["Pants"] = cPants.PantsTemplate:match("%d+")
			cShirt.ShirtTemplate = serverConfig.templatePrefix:format(s)
			cPants.PantsTemplate = serverConfig.templatePrefix:format(p)
		elseif Starter == "TakeOff" then
			local Character = Player.Character
			local cShirt, cPants = Character.Shirt, Character.Pants
			if serverConfig.originalClothes[Player.Name] then
				cShirt.ShirtTemplate = serverConfig.templatePrefix:format(
					serverConfig.originalClothes[Player.Name]["Shirt"]
				)
				cPants.PantsTemplate = serverConfig.templatePrefix:format(
					serverConfig.originalClothes[Player.Name]["Pants"]
				)
				serverConfig.originalClothes[Player.Name] = nil
			end
		end
	end
end)

function Rewrite(Player, TheirTool)
	for _, b in next, Connections[Player.UserId] do
		if b ~= nil then
			b:Disconnect()
			b = nil
		end
	end

	table.insert(
		Connections[Player.UserId],
		TheirTool.Equipped:Connect(function()
			serverConfig.bagsEquipped[Player.Name] = true
		end)
	)
	table.insert(
		Connections[Player.UserId],
		TheirTool.Unequipped:Connect(function()
			serverConfig.bagsEquipped[Player.Name] = nil
		end)
	)
	table.insert(
		Connections[Player.UserId],
		TheirTool.Activated:Connect(function()
			customOnMouseClick(Player, TheirTool)
		end)
	)
end

Players.PlayerAdded:Connect(function(Player)
	Connections[Player.UserId] = {}
	serverConfig.playerAdded[Player.UserId] = true

	local Character = Player.Character or Player.CharacterAdded:Wait()

	local playerKey = Key.new(50)
	serverConfig.Keys[Player.UserId] = playerKey
	Event:FireClient(Player, "Config", playerKey)

	if not serverConfig.piStatus then
		serverConfig.piStatus = true
		for _, model in next, Folder:GetChildren() do
			Util:Create("StringValue", { Name = "PI", Value = Key.new(10), Parent = model })
		end
	end

	task.defer(function()
		local theirTool = Util:Clone(Tool, { Parent = Player:WaitForChild("Backpack") })
		Rewrite(Player, theirTool)
		task.delay(0.1, function()
			serverConfig.playerAdded[Player.UserId] = false
		end)
	end)

	table.insert(
		Connections[Player.UserId],
		Player.CharacterAdded:Connect(function()
			if not serverConfig.playerAdded[Player.UserId] then
				local theirTool = Util:Clone(Tool, { Parent = Player:WaitForChild("Backpack") })
				Rewrite(Player, theirTool)
				task.delay(0.2, function()
					Event:FireClient(Player, "Config", playerKey)
				end)
			end
		end)
	)

	Util
		:WaitForChildOfClass(Character, "Shirt", 1)
		:andThen(function(result)
			if not result then
				Util:Create("Shirt", { ShirtTemplate = serverConfig.templatePrefix:format("0"), Parent = Character })
			end
		end)
		:catch(error)
		:await()
	Util
		:WaitForChildOfClass(Character, "Pants", 1)
		:andThen(function(result)
			if not result then
				Util:Create("Pants", { PantsTemplate = serverConfig.templatePrefix:format("0"), Parent = Character })
			end
		end)
		:catch(error)
		:await()

	local Count = 0
	for _, b in next, Player:WaitForChild("Backpack"):GetChildren() do
		Count += (b.Name == serverConfig.toolName) and 1 or 0
		if Count > 1 then
			b:Destroy()
			warn("An additional tool was found and destroyed in a player's backpack!")
		end
	end
end)

Players.PlayerRemoving:Connect(function(Player)
	Connections[Player.UserId] = nil
	serverConfig.Keys[Player.UserId] = nil
end)
