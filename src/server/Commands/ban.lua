return {
	Name = "ban";
	Aliases =  {};
	Description = "Bans a player from the game.";
	Group = "Admin";
	Args = {
		{
			Type = "playerId";
			Name = "player";
			Description = "The full player name to ban.";
		};
		{
			Type = "string";
			Name = "reason";
			Description = "The reason for banning this player.";
		};
	};
}