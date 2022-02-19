-- WIP

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Shared.Promise)

local TweenV2 = {}

local Config = {
	Saved = {},
}

-- Runs a tween as soon as possible
-- Also runs a "Later" tween
--[[
    TweenV2:Now({
        Part = ...,
        Info = ...,
        Properties = ...
    })

    TweenV2:Now({
        _ID = ...
    })
]]
function TweenV2:Now(options: { [string]: any })
	return Promise.new(function(resolve, reject, onCancel)
		local tweenID = options["_ID"]
		if tweenID then
			if Config.Saved[tweenID] then
				local savedOptions = Config.Saved[tweenID]
				local Tween = TweenService:Create(savedOptions.Object, savedOptions.Info, savedOptions.Properties)

				onCancel(function()
					Tween:Cancel()
				end)

				Tween.Completed:Connect(resolve)
				Tween:Play()
				return
			else
				reject("TweenV2 (function 'Now'): Could not find predefined ID")
			end
		end

		local Tween = TweenService:Create(options.Object, options.Info, options.Properties)

		onCancel(function()
			Tween:Cancel()
		end)

		Tween.Completed:Connect(resolve)
		Tween:Play()
	end)
end

-- Defines a tween and saves it for later, without running it
--[[
    TweenV2:Later({
        _ID = ...,
        Options = {
            Part = ...,
            Info = ...,
            Properties = ...
        }
    })
]]
function TweenV2:Later(options: { [string]: any }): (nil)
	local tweenID = options["_ID"]
	if Config.Saved[tweenID] then
		error("TweenV2 (function 'Later'): Attempt to call Later on an already saved ID")
	end
	Config.Saved[tweenID] = options.Options
end

-- Runs a tween as soon as possible, and also saves it for later for future use
--[[
    TweenV2:NowAndSave({
        _ID = ...,
        Options = {
            Part = ...,
            Info = ...,
            Properties = ...
        }
    })
]]
function TweenV2:NowAndSave(options: { [string]: any })
	return Promise.new(function(resolve, reject, onCancel)
		local tweenID = options["_ID"]
		if tweenID then
			if Config.Saved[tweenID] then
				reject("TweenV2 (function 'NowAndSave'): Attempt to call NowAndSave on an already saved ID")
			else
				local tweenOptions = options.Options
				Config.Saved[tweenID] = tweenOptions

				local Tween = TweenService:Create(tweenOptions.Object, tweenOptions.Info, tweenOptions.Properties)

				onCancel(function()
					Tween:Cancel()
				end)

				Tween.Completed:Connect(resolve)
				Tween:Play()
			end
		else
			reject("TweenV2 (function 'NowAndSave'): Attempt to call NowAndSave without ID")
		end
	end)
end

-- Deletes a saved tween
--[[
    TweenV2:Delete({
        _ID = ...
    })
]]
function TweenV2:Delete(options: { [string]: any }): (nil)
	local tweenID = options["_ID"]
	if not Config.Saved[tweenID] then
		error("TweenV2 (function 'Delete'): Attempt to call Delete on invalid ID")
	end
	Config.Saved[tweenID] = nil
end

return TweenV2
