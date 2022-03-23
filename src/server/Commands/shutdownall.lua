return {
	Name = "shutdownall",
	Aliases = { "sdall" },
	Description = "Kicks everyone (including you) from all servers in the game.",
	Group = "Command",
	Args = {
		{
			Type = "string",
			Name = "reason",
			Description = "The reason for shutting down all servers.",
			Optional = true,
		},
	},
}
