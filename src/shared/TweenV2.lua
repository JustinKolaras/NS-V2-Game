-- WIP

local TweenService = game:GetService("TweenService")

local TweenV2 = {}
TweenV2.__index = TweenV2

setmetatable({
	Saved = {},
}, TweenV2)

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
function TweenV2:Now(options: { [string]: any }): (Tween)
	local tweenID = options["_ID"]
	if tweenID then
		if self.Saved[tweenID] then
			local savedOptions = self.Saved[tweenID]
			return TweenService:Create(savedOptions.Part, savedOptions.Info, savedOptions.Properties):Play()
		else
			error("TweenV2 (function 'Now'): Could not find predefined ID")
		end
	end
	return TweenService:Create(options.Part, options.Info, options.Properties):Play()
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
function TweenV2:Later(options: { [string]: any })
	local tweenID = options["_ID"]
	if self.Saved[tweenID] then
		error("TweenV2 (function 'Later'): Attempt to call Later on an already saved ID")
	end
	self.Saved[tweenID] = options.Options
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

end

-- Deletes a saved tween
--[[
    TweenV2:Delete({
        _ID = ...
    })
]]
function TweenV2:Delete(options: { [string]: any }) end
