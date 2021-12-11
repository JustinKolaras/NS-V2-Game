return {
	Name = "rejoin";
	Aliases =  {};
	Description = "Automatically rejoins a player to the same place.";
	Group = "Admin";
	Args = {
		{
			Type = "player";
			Name = "player";
			Description = "The player to rejoin.";
		};
	};
}