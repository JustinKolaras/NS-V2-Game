return {
	Name = "shutdown",
	Aliases = { "sd" },
	Description = "Kicks everyone (including you) from the server.",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "reason",
			Description = "The reason for shutting down the server.",
			Optional = true,
		},
	},
}
