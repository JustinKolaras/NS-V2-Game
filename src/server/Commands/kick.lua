return {
	Name = "kick",
	Aliases = {},
	Description = "Kicks a player from the server.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to kick.",
		},
		{
			Type = "string",
			Name = "reason",
			Description = "The reason for kicking this player.",
		},
	},
}
