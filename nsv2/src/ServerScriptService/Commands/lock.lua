return {
	Name = "lock";
	Aliases =  {};
	Description = "Locks the server, disallowing others from joining.";
	Group = "Admin";
	Args = {
		{
			Type = "string";
			Name = "reason";
			Description = "The reason for locking this server.";
			Optional = true;
		};
	};
}