return {
	--[[
		GroupRank = # ; Users of this group rank id will possess the tag associated with it
		MarketPass = # ; Users with this gamepass id will possess the tag associated with it
		Users = {#,#,#,etc..} ; The UserId(s) in this table will possess the tag associated with it
		
		Tags are in precedence from highest in the list to lowest.
	]]

	["Owner"] = {
		Color = Color3.fromRGB(255, 0, 0),
		Users = { 28872421, 2606923587 },
		Chat = Color3.fromRGB(255, 170, 0),
	},
	["Co-Owner"] = {
		Color = Color3.fromRGB(78, 96, 255),
		Users = { 56415482 },
		Chat = Color3.fromRGB(255, 170, 0),
	},
	["Mod"] = {
		Color = Color3.fromRGB(0, 255, 127),
		GroupRank = 252,
		Chat = Color3.fromRGB(255, 170, 0),
	},
	["Developer"] = {
		Color = Color3.fromRGB(255, 0, 127),
		GroupRank = 251,
	},
	["Designer"] = {
		Color = Color3.fromRGB(85, 255, 255),
		GroupRank = 250,
	},
	["Contributor"] = {
		Color = Color3.fromRGB(255, 255, 127),
		Users = { 48508536 },
	},
	["VIP"] = {
		Color = Color3.fromRGB(231, 175, 4),
		MarketPass = 13375778,
	},
}
