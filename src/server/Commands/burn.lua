return {
	Name = "burn",
	Aliases = {},
	Description = "Fun Command - Burns and unanchors the entire Workspace. IRREVERSIBLE!!",
	Group = "Owner",
	Args = {
		{
			Type = "number",
			Name = "interval",
			Description = "Interval between each next-burned part. Default is 0.1",
			Optional = true,
		},
	},
}
