return {
	Name = "prompt",
	Aliases = {},
	Description = "Prompts a user an asset or gamepass purchase.",
	Group = "Util",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to prompt.",
		},
		{
			Type = "number",
			Name = "asset",
			Description = "The assetId to prompt.",
		},
	},
}
