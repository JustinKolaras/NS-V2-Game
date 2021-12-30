--[[

	TryOn Ver. 1.0
	Developed by Aerosphia

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Market = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer

local Gui = Player.PlayerGui
if not Gui then
	repeat
		task.wait()
	until Gui ~= nil
end

local Promise = require(ReplicatedStorage.Shared.Promise)
local Util = require(ReplicatedStorage.Shared.Util)

local ScreenGui = Gui.TryOn

local Base = ScreenGui.Base
local Viewport = Base.Mannequin
local BuyOutfit = Base.BuyOutfit
local BuyShirt = Base.BuyS
local BuyPant = Base.BuyP
local TryOn = Base.TryOn
local CloseButton = Base.X
local ManType = Base.MannequinType
local Loading = Base.Loading
local ErrorNotif = Base.Error

local AdvView = ScreenGui.Advanced_View
local SpeedInput = AdvView.SpeedInput
local Exit = AdvView.Exit

local AdvTriggFrame = ScreenGui.AV_Trigger
local AdvTrigger = AdvTriggFrame.Trigger

local Notice = ScreenGui.Notice
local NoticeCloseButton = Notice.X
local NoticeDesc = Notice.Desc

local TryOnFolder = ReplicatedStorage:FindFirstChild("TryOn")

local Event = TryOnFolder:FindFirstChild("TryOn Event")
local Function = TryOnFolder:FindFirstChild("TryOn Function")
local viewportCharacter = TryOnFolder:FindFirstChild("Character")

local clientConfig = setmetatable({
	key = 0,
	templatePrefix = "http://www.roblox.com/asset/?id=%d",
	buyOutfitFormat = 'Buy Outfit <font color="#3CDD52">R$%d</font>',
	buyShirtFormat = 'Shirt <b><font color="#3CDD52">R$%d</font></b>',
	buyPantFormat = 'Pants <b><font color="#3CDD52">R$%d</font></b>',
	ownedFormat = '<b><font color="#3CDD52">OWNED</font></b>',
	_connections = {
		terminal = {
			close = 0,
			tryOn = 0,
			buyS = 0,
			buyP = 0,
			buyOutfit = 0,
			manType = 0,
		},
		advancedView = {
			trigger = 0,
			speedInputFocusLost = 0,
			speedInputTPCS = 0,
			exit = 0,
		},
		notice = {
			close = 0,
		},
		died = 0,
		clientEvent = 0,
	},
	_promise = {
		mainLoad = 0,
	},
	_db = {
		avTrigg = false,
		avExit = false,
	},
	isAdvancedView = false,
	advSpeed = 1,
	connectionBreak3d = false,
	currentPi = 0,
	originalCFrame3d = 0,
	storedViewport = 0,
	previousHumanoidCF = CFrame.new(),
	buyIndividualObjectYScale = 0.395,
	tryOnObjectYScale = 0.14,
	greyOut = Color3.fromRGB(118, 118, 118),
	advExFunc = 0,
	globalTemplates = {
		TemplateS = 0,
		TemplateP = 0,
	},
	isTryingOn = false,
	loadText = Loading.Text,
	loadErrorText = "Unknown error",
	noticeExecErrorText = "Please join our Discord server with this screenshot as a bug report. This usually has something to do with your avatar - try removing packages!",
	loadingTimes = {},
	archivedLoads = {},
}, {
	__index = function(_, indx)
		error(
			(
				"Try On Client::clientConfigError: Attempt to get clientConfig value with a nil index. -> clientConfig[%s]?\n\n%s"
			):format(indx, debug.traceback())
		)
	end,

	__newindex = function(_, indx, val)
		error(
			("Try On Client::clientConfigError: New items are disallowed! -> Operation (clientConfig[%s] = %s) failed.\n\n%s"):format(
				indx, 
				tostring(val), 
				debug.traceback()
			)
		)
	end,
})

local function makeLibraryMeta(Name)
	assert(Name and typeof(Name) == "string", "makeLibraryMeta: Parameter 1 (Name) string expected")
	return {
		__index = function(_, indx)
			error(
				("Try On Client::inBuiltLibraryError: %s is not a function of %s.\n\n%s"):format(indx, Name, debug.traceback())
			)
		end,
	}
end

local Time = setmetatable({}, makeLibraryMeta("Time"))
local Templates = setmetatable({}, makeLibraryMeta("Templates"))
local Core = setmetatable({}, makeLibraryMeta("Core"))

function Time.Set()
	table.insert(clientConfig.loadingTimes, 1, os.clock())
end

function Time.Get()
	local loadingTimes = clientConfig.loadingTimes
	local archivedLoads = clientConfig.archivedLoads

	local toReturn = tostring(os.clock() - loadingTimes[1])
	toReturn = (#tostring(loadingTimes[1]) < 3) and toReturn:sub(1, #tostring(loadingTimes[1])) or toReturn:sub(1, 3)

	table.move(loadingTimes, 1, 1, select("#", archivedLoads), archivedLoads)

	return tonumber(toReturn)
end

function Time.Forget()
	table.remove(clientConfig.loadingTimes, 1)
end

function Templates.New(Shirt, Pant)
	return {
		TemplateS = Shirt,
		TemplateP = Pant,
	}
end

function Core.elements(Toggle)
	local ok, _, timeout = nil, nil, 0
	assert(typeof(Toggle) == "boolean", "core.elements: Parameter 1 (Toggle) bool expected")
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, Toggle)
	local function ResetButtonCallback()
		StarterGui:SetCore("ResetButtonCallback", Toggle)
	end
	ok, _ = pcall(ResetButtonCallback)
	if not ok then
		repeat
			timeout += 1
			ok, _ = pcall(ResetButtonCallback)
		until ok or timeout == 10
	end
end

local function fireServer(...)
	Event:FireServer(clientConfig.key, ...)
end

local function tryOn(...)
	AdvTriggFrame.Visible = true
	TryOn.Text = "Take Off Outfit"
	clientConfig.isTryingOn = true
	fireServer("TryOn", ...)
end

local function takeOff()
	fireServer("TakeOff")
	TryOn.Text = "Try On Outfit"
	clientConfig.isTryingOn = false
end

local function getPi(mannequinModel)
	local value = mannequinModel:GetAttribute("PI")
	assert(value, "getPi: No personal identification value")
	return value
end

local function checkAsset(Proto, ...)
	local Data = { ... }
	return Promise.new(function(resolve)
		for a, b in ipairs(Data) do
			if typeof(Proto) == "boolean" and not Proto then
				if Market:PlayerOwnsAsset(Player, b) then
					resolve(1)
				else
					resolve(2)
				end
			elseif typeof(Proto) == "boolean" and Proto then
				if Market:PlayerOwnsAsset(Player, b) then
					if a == select("#", Data) then
						resolve(1)
					end
				else
					resolve(2)
				end
			end
		end
	end)
end

local function productInfo(id, enum)
	assert(enum.EnumType == Enum.InfoType, "productInfo: Parameter 2 (enum) InfoType Enumerator expected")
	return Promise.new(function(resolve, reject)
		local succ, result = pcall(Market.GetProductInfo, Market, id, enum)
		return succ and resolve(result) or reject(result)
	end)
end

local function manageIndividuals(toTop)
	if toTop then
		BuyShirt.Position = UDim2.fromScale(BuyShirt.Position.X.Scale, clientConfig.tryOnObjectYScale)
		BuyPant.Position = UDim2.fromScale(BuyPant.Position.X.Scale, clientConfig.tryOnObjectYScale)
	else
		BuyShirt.Position = UDim2.fromScale(BuyShirt.Position.X.Scale, clientConfig.buyIndividualObjectYScale)
		BuyPant.Position = UDim2.fromScale(BuyPant.Position.X.Scale, clientConfig.buyIndividualObjectYScale)
	end
end

local function manageButtons(outfitVisible, tryOnVisible)
	local exception = false
	if outfitVisible then
		BuyOutfit.Visible = true
	end
	if tryOnVisible then
		TryOn.Visible = true
	else
		exception = true
		manageIndividuals(true)
	end
	if not exception then
		BuyPant.Visible = true
		BuyShirt.Visible = true
	else
		if
			(BuyPant.Position.Y.Scale ~= clientConfig.buyIndividualObjectYScale)
			or (BuyShirt.Position.Y.Scale ~= clientConfig.buyIndividualObjectYScale)
		then
			manageIndividuals(true)
			BuyPant.Visible = true
			BuyShirt.Visible = true
		end
	end
end

local function stillActivated()
	return (BuyShirt.Visible and BuyPant.Visible)
end

local function loadingState(customText)
	BuyOutfit.Visible = false
	BuyPant.Visible = false
	BuyShirt.Visible = false
	TryOn.Visible = false
	Loading.Visible = true
	Loading.Text = customText or clientConfig.loadText
end

local function cancelLoading()
	local loadPromise = clientConfig._promise.mainLoad
	loadPromise:cancel()
	loadPromise = nil
end

local function close(Key, Type)
	if Key == "Base" then
		local vpChar = clientConfig.storedViewport

		cancelLoading()
		Base.Visible = false
		ErrorNotif.Visible = false
		ManType.Text = "2D"
		clientConfig.connectionBreak3d = true

		if not Type or Type == 0 then
			AdvTriggFrame.Visible = false
		end

		pcall(function()
			vpChar.PrimaryPart = vpChar:FindFirstChild("HumanoidRootPart")
			vpChar:SetPrimaryPartCFrame(clientConfig.originalCFrame3d)
		end)

		task.wait(1 / 60)
		clientConfig.connectionBreak3d = false
	elseif Key == "Notice" then
		Notice.Visible = false
		NoticeDesc.Text = ""
	end
end

local function err(info, text)
	Time.Forget()
	ErrorNotif.Visible = true
	warn(info)
	Loading.Text = text or clientConfig.loadErrorText
	task.wait()
	if stillActivated() then
		loadingState(clientConfig.loadErrorText)
	end
end

local function isOwned(indivButton)
	assert(indivButton:IsA("TextButton"), "isOwned: Parameter 1 (indivButton) TextButton expected")
	return indivButton.Text:lower():match("owned")
end

local function disconnect(Client)
	if Client.UserId == Player.UserId then
		for _, outermost in pairs(clientConfig._connections) do
			if typeof(outermost) == "table" then -- Not expecting to loop multiple tables, so we'll loop here
				for _, innermost in pairs(outermost) do
					if typeof(innermost) == "RBXScriptConnection" then
						pcall(innermost.Disconnect, innermost)
						innermost = nil
					end
				end
			else
				pcall(outermost.Disconnect, outermost)
				outermost = nil
			end
		end
	end
end

function createViewport(templates)
	return Promise.new(function(resolve)
		Viewport:ClearAllChildren()

		local clone = Util:Clone(viewportCharacter)
		clone["Pants"].PantsTemplate = clientConfig.templatePrefix:format(templates.TemplateP)
		clone["Shirt"].ShirtTemplate = clientConfig.templatePrefix:format(templates.TemplateS)

		local newModel = Util:Create("Model", { Name = "Character", Parent = Viewport })

		local hrp
		for _, b in ipairs(clone:GetChildren()) do
			if b.Name == "HumanoidRootPart" then
				hrp = b
			end
			if b.Name == "Head" then
				b["default face"]:Destroy()
			end
			if b:IsA("BasePart") then
				b.CFrame *= CFrame.Angles(0, math.rad(180), 0)
			end
			b.Parent = newModel
		end

		local vpCam = Util:Create("Camera", { FieldOfView = 5, Parent = Viewport })
		Viewport.CurrentCamera = vpCam

		vpCam.CFrame = CFrame.new(Vector3.new(0, 2, 12), hrp.Position)

		clientConfig.storedViewport = newModel
		resolve()
	end)
end

function noticeConnectionUnit()
	for _, b in pairs(clientConfig._connections.notice) do
		if typeof(b) == "RBXScriptConnection" then
			b:Disconnect()
			b = nil
		end
	end
	return Promise.new(function(resolve)
		clientConfig._connections.notice.close = NoticeCloseButton.MouseButton1Click:Connect(function()
			close("Notice")
		end)
		resolve()
	end)
end

local function newNotice(noticeText)
	noticeConnectionUnit():catch(error):await()
	NoticeDesc.Text = noticeText
	Notice.Visible = true
end

function advConnectionUnit()
	for _, b in pairs(clientConfig._connections.advancedView) do
		if typeof(b) == "RBXScriptConnection" then
			b:Disconnect()
			b = nil
		end
	end
	return Promise.new(function(resolve)
		clientConfig._connections.advancedView.speedInputTPCS = SpeedInput
			:GetPropertyChangedSignal("Text")
			:Connect(function()
				local function subtract()
					SpeedInput.Text = SpeedInput.Text:sub(0, -2)
				end
				if #SpeedInput.Text > 1 then
					return subtract()
				elseif not tonumber(SpeedInput.Text) then
					return subtract()
				elseif tonumber(SpeedInput.Text) > 5 then
					return subtract()
				end
			end)
		clientConfig._connections.advancedView.speedInputFocusLost = SpeedInput.FocusLost:Connect(function()
			if #SpeedInput.Text < 1 then
				clientConfig.advSpeed = SpeedInput.PlaceholderText
			else
				clientConfig.advSpeed = tonumber(SpeedInput.Text)
			end
		end)
		clientConfig.advExFunc = function()
			if clientConfig._db.avExit then
				return
			end

			clientConfig.isAdvancedView = false
			Core.elements(true)

			AdvView.Visible = false
			RunService:UnbindFromRenderStep("CameraRotation")
			SpeedInput.Text = ""
			clientConfig.advSpeed = SpeedInput.PlaceholderText
			AdvTriggFrame.Visible = true
			Player.Character.HumanoidRootPart.CFrame = clientConfig.previousHumanoidCF
			clientConfig.previousHumanoidCF = CFrame.new()
			Player.Character.HumanoidRootPart.Anchored = false

			clientConfig._db.avTrigg = true
			AdvTrigger.TextColor3 = clientConfig.greyOut
			AdvTrigger.AutoButtonColor = false
			task.delay(2, function()
				clientConfig._db.avTrigg = false
				AdvTrigger.TextColor3 = Color3.fromRGB(255, 255, 255)
				AdvTrigger.AutoButtonColor = true
			end)

			close("Base", 1)
		end
		clientConfig._connections.advancedView.exit = Exit.MouseButton1Click:Connect(clientConfig.advExFunc)
		resolve()
	end)
end

function mainConnectionUnit(shirtObject, pantObject)
	for _, b in pairs(clientConfig._connections.terminal) do
		if typeof(b) == "RBXScriptConnection" then
			b:Disconnect()
			b = nil
		end
	end
	return Promise.new(function(resolve)
		clientConfig._connections.terminal.close = CloseButton.MouseButton1Click:Connect(function()
			close("Base", 1)
		end)
		clientConfig._connections.terminal.tryOn = TryOn.MouseButton1Click:Connect(function()
			if TryOn.Text == "Try On Outfit" then
				tryOn(clientConfig.globalTemplates.TemplateS, clientConfig.globalTemplates.TemplateP)
				close("Base", 1)
			elseif TryOn.Text == "Take Off Outfit" then
				takeOff()
				close("Base")
			end
		end)
		clientConfig._connections.terminal.buyS = BuyShirt.MouseButton1Click:Connect(function()
			if isOwned(BuyShirt) then
				return
			end
			Market:PromptPurchase(Player, shirtObject)
			local temp
			temp = Market.PromptPurchaseFinished:Connect(function(_, assetId, wasPurchased)
				if wasPurchased and assetId == shirtObject then
					BuyShirt.Text = clientConfig.ownedFormat
					BuyOutfit.Visible = false
				end
				temp:Disconnect()
				temp = nil
			end)
		end)
		clientConfig._connections.terminal.buyP = BuyPant.MouseButton1Click:Connect(function()
			if isOwned(BuyPant) then
				return
			end
			Market:PromptPurchase(Player, pantObject)
			local temp
			temp = Market.PromptPurchaseFinished:Connect(function(_, assetId, wasPurchased)
				if wasPurchased and assetId == pantObject then
					BuyPant.Text = clientConfig.ownedFormat
					BuyOutfit.Visible = false
				end
				temp:Disconnect()
				temp = nil
			end)
		end)
		clientConfig._connections.terminal.buyOutfit = BuyOutfit.MouseButton1Click:Connect(function()
			Market:PromptPurchase(Player, shirtObject)
			local temp
			temp = Market.PromptPurchaseFinished:Connect(function(_, assetId, wasPurchased)
				if wasPurchased and assetId == shirtObject then
					BuyShirt.Text = clientConfig.ownedFormat
					BuyOutfit.Visible = false
					task.wait(0.1)
					Market:PromptPurchase(Player, pantObject)
				elseif wasPurchased and assetId == pantObject then
					BuyPant.Text = clientConfig.ownedFormat
					TryOn.Visible = false
					manageIndividuals(true)
					temp:Disconnect()
					temp = nil
				else
					temp:Disconnect()
					temp = nil
				end
			end)
		end)
		clientConfig._connections.terminal.manType = ManType.MouseButton1Click:Connect(function()
			local vpChar = clientConfig.storedViewport
			vpChar.PrimaryPart = vpChar:FindFirstChild("HumanoidRootPart")
			if ManType.Text == "2D" then
				local temp
				clientConfig.originalCFrame3d = vpChar:GetPrimaryPartCFrame()
				ManType.Text = "3D"
				temp = RunService.Heartbeat:Connect(function(t)
					local atr = math.rad(180) * t / 3
					if clientConfig.connectionBreak3d then
						temp:Disconnect()
						temp = nil
					end
					vpChar:SetPrimaryPartCFrame(
						vpChar:GetPrimaryPartCFrame() * CFrame.fromEulerAnglesXYZ(0, tonumber(atr), 0)
					)
				end)
			elseif ManType.Text == "3D" then
				clientConfig.connectionBreak3d = true
				vpChar:SetPrimaryPartCFrame(clientConfig.originalCFrame3d)
				ManType.Text = "2D"
				task.wait(1 / 60)
				clientConfig.connectionBreak3d = false
			end
		end)
		clientConfig._connections.adv.trigg = AdvTrigger.MouseButton1Click:Connect(function()
			if clientConfig._db.avTrigg then
				return
			end
			advConnectionUnit():catch(error):await()

			clientConfig._db.avExit = true
			Exit.TextColor3 = clientConfig.greyOut
			Exit.AutoButtonColor = false
			task.delay(1, function()
				clientConfig._db.avExit = false
				Exit.TextColor3 = Color3.fromRGB(255, 255, 255)
				Exit.AutoButtonColor = true
			end)

			AdvTriggFrame.Visible = false
			AdvView.Visible = true
			close("Base")

			local Character = Player.Character

			clientConfig.isAdvancedView = true
			Core.elements(false)
			Character.HumanoidRootPart.Anchored = true
			clientConfig.previousHumanoidCF = Character.HumanoidRootPart.CFrame

			local centerCFrame = (Character.Head.CFrame + Vector3.new(0, 2, 0)) * CFrame.Angles(0, 180, 0)
			local offsetCFrame = CFrame.new(0, 0, 10) * CFrame.Angles(math.rad(-22.5), 0, 0)
			local currentAngle = 0

			RunService:BindToRenderStep("CameraRotation", Enum.RenderPriority.Camera.Value + 1, function()
				Camera.CFrame = centerCFrame * CFrame.Angles(0, math.rad(currentAngle), 0) * offsetCFrame
				currentAngle += clientConfig.advSpeed
			end)
		end)
		resolve()
	end)
end

clientConfig._connections.clientEvent = Event.OnClientEvent:Connect(function(Key, ...)
	local Data = { ... }
	if Key == "Open" then
		clientConfig._promise.mainLoad = Promise.new(function(_, _, onCancel)
			if Base.Visible or Notice.Visible or clientConfig.isAdvancedView then
				return
			end

			local shirt, pant = Data[1], Data[2]
			local templateTable = Data[3]
			local characterModel = Data[4]
			local characterPi = getPi(characterModel)
			local infoShirt, infoPant

			onCancel(loadingState)

			if characterPi ~= clientConfig.currentPi then
				if clientConfig.isTryingOn then
					takeOff()
					AdvTriggFrame.Visible = false
				end
			end

			clientConfig.currentPi = characterPi
			Loading.Text = clientConfig.loadText
			ManType.Visible = false
			if not Notice.Visible then
				Base.Visible = true
			end

			Time.Set()

			productInfo(shirt, Enum.InfoType.Asset)
				:andThen(function(result)
					infoShirt = result
				end)
				:catch(error)
				:await()

			productInfo(pant, Enum.InfoType.Asset)
				:andThen(function(result)
					infoPant = result
				end)
				:catch(error)
				:await()

			local outfitVisible, tryOnVisible = true, true
			local pantOwned, shirtOwned = false, false

			clientConfig.globalTemplates.TemplateS = templateTable.TemplateS
			clientConfig.globalTemplates.TemplateP = templateTable.TemplateP

			manageIndividuals(false)
			createViewport(templateTable):catch(error):await()
			mainConnectionUnit(shirt, pant):catch(error):await()

			checkAsset(true, shirt)
				:andThen(function(Type)
					if Type == 1 then
						BuyShirt.Text = clientConfig.ownedFormat
						BuyShirt.AutoButtonColor = false
						outfitVisible = false
						shirtOwned = true
					elseif Type == 2 then
						BuyShirt.Text = clientConfig.buyShirtFormat:format(infoShirt.PriceInRobux)
					end
				end)
				:catch(error)
				:await()

			checkAsset(true, pant)
				:andThen(function(Type)
					if Type == 1 then
						BuyPant.Text = clientConfig.ownedFormat
						BuyPant.AutoButtonColor = false
						outfitVisible = false
						pantOwned = true
					elseif Type == 2 then
						BuyPant.Text = clientConfig.buyPantFormat:format(infoShirt.PriceInRobux)
					end
				end)
				:catch(error)
				:await()

			if not pantOwned and not shirtOwned then
				BuyOutfit.Text = clientConfig.buyOutfitFormat:format(infoShirt.PriceInRobux + infoPant.PriceInRobux)
			end
			if pantOwned and shirtOwned then
				tryOnVisible = false
			end

			Loading.Visible = false
			ManType.Visible = true
			manageButtons(outfitVisible, tryOnVisible)

			print(("Took " .. Time.Get() .. " seconds to load on client %s!"):format(Player.Name))
		end):catch(function(errorMsg)
			return Base.Visible and err(errorMsg) or newNotice(clientConfig.noticeExecErrorText)
		end)
	elseif Key == "Config" then
		clientConfig.key = Data[1]
	end
end)

Function.OnClientInvoke = function(Key)
	if Key == "MouseTarget" then
		return Player:GetMouse().Target
	end
end

Util:WaitForChildOfClass(Player.Character, "Humanoid", 2):andThen(function(result)
	if result then
		clientConfig._connections.died = result.Died:Connect(function()
			if Base.Visible then
				close("Base")
			end
			if clientConfig.isTryingOn then
				takeOff()
				AdvTriggFrame.Visible = false
			end
		end)
	end
end)

Players.PlayerRemoving:Connect(disconnect)
