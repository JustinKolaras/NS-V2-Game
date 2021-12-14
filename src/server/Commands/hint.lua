return {
	Name = "hint",
	Aliases = {},
	Description = "Overrides the automatic hints with a custom announcement.",
	Group = "Admin",
	Args = {
		{
			Type = "string",
			Name = "text",
			Description = "The hint text to broadcast.",
			Optional = true,
		},
	},
}
