return {
	Name = "ban",
	Aliases = {},
	Description = "Permanently bans a player from the game.",
	Group = "Admin",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "The player to ban.",
		},
		{
			Type = "string",
			Name = "reason",
			Description = "The reason for banning this player.",
		},
	},
}
