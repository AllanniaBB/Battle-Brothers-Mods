::BetterObituary <- {
    ID = "mod_better_obituary",
    Version = "2.0.0",
    Name = "Better Obituary",
    BuildName = "Testing",
    FallenList = [],
    num_traits = 4,
    num_stats = 8,
    num_talents = 8,
    num_perminjuries = 3,
	placeholder_data = -99
};

// Register using Modern Hooks
local mod = ::Hooks.register(::BetterObituary.ID, ::BetterObituary.Version, ::BetterObituary.Name);

mod.require("mod_msu >= 1.7.0");
mod.queue(">mod_msu", function() 
{
    ::BetterObituary.Mod <- ::MSU.Class.Mod(::BetterObituary.ID, ::BetterObituary.Version, ::BetterObituary.Name);
	
    foreach (file in ::IO.enumerateFiles("mod_better_obituary/config"))
            ::include(file);
    foreach (file in ::IO.enumerateFiles("mod_better_obituary/hooks"))
            ::include(file);

    // Function to add a fallen brother to the FallenList and World.Statistics
    ::BetterObituary.addFallen <- function(_bro, _cause) 
	{
        //::logInfo("Better Obituary: addFallen called for " + _bro.getName() + " cause " + _cause);
		
        local fallen = {
			Name = _bro.getName(),
			Time = this.World.getTime().Days,
			TimeWithCompany = this.Math.max(1, _bro.getDaysWithCompany()),
			Kills = _bro.getLifetimeStats().Kills,
			Battles = _bro.getLifetimeStats().Battles,
			KilledBy = _cause,
			Expendable = _bro.getBackground().getID() == "background.slave"
        };

        ::BetterObituary.FallenList.push(fallen);
        ::World.Statistics.addFallen(_bro.finalizeFallen(fallen));
    };

    // Load new UI
    ::Hooks.registerCSS("ui/mods/css/better_obituary_dialog.css");
    ::Hooks.registerCSS("ui/mods/css/better_obituary_world_obituary_screen.css");

});