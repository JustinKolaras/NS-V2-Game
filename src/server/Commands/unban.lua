return {
	Name = "unban",
	Aliases = {},
	Description = "Unbans a previously banned player from the game.",
	Group = "Admin",
	Args = {
		{
			Type = "playerId",
			Name = "player",
			Description = "The full player name to unban.",
		},
	},
}
