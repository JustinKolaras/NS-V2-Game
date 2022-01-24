return {
	Name = "baninfo",
	Aliases = {},
	Description = "Provides information on a player's ban.",
	Group = "Admin",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "The player to get information on.",
		},
	},
}
