return {
	Name = "teleport",
	Aliases = { "tp" },
	Description = "Teleports a player or set of players to one target.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "who",
			Description = "The player(s) to teleport.",
		},
		{
			Type = "player @ vector3",
			Name = "to",
			Description = "The player to teleport to.",
		},
	},
}
