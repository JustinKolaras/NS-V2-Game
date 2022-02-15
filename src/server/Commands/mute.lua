return {
	Name = "mute",
	Aliases = { "silence", "offify", "zipper" },
	Description = "Mutes and prevents a player from chatting.",
	Group = "Admin",
	Args = {
		{
			Type = "player",
			Name = "player",
			Description = "The player to mute.",
		},
		{
			Type = "string",
			Name = "reason",
			Description = "The reason for muting this player.",
		},
	},
}
