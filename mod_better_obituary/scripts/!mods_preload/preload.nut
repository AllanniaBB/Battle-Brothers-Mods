::BetterObituary <- {
    ID = "mod_better_obituary",
    Version = "3.4.0",
    Name = "Better Obituary",
    BuildName = "All the tooltips",
	Debug = false
};

local mod = ::Hooks.register(::BetterObituary.ID, ::BetterObituary.Version, ::BetterObituary.Name);

mod.require("mod_msu >= 1.7.0");
mod.queue(">mod_msu", function() 
{
    ::BetterObituary.Mod <- ::MSU.Class.Mod(::BetterObituary.ID, ::BetterObituary.Version, ::BetterObituary.Name);
	
    foreach (file in ::IO.enumerateFiles("mod_better_obituary/hooks"))
        ::include(file);

    // Load new UI
    ::Hooks.registerCSS("ui/mods/css/better_obituary_dialog.css");
    ::Hooks.registerCSS("ui/mods/css/better_obituary_world_obituary_screen.css");

    // MSU Settings Options
    local BO_settings = ::BetterObituary.Mod.ModSettings.addPage("Settings");
	
    BO_settings.addBooleanSetting("StackedStars", false, "Stacked Talent Stars", "The 3 star talent icon will be displayed in a triangle format, rather than a row.");
	BO_settings.addBooleanSetting("SwapStats", false, "Swap Stat Columns", "Swaps the position of first 4 stats (hp, fatigue, initiative, bravery) with the last 4 (attack / defense).");
	
	BO_settings.addDivider("Divider");
	
	BO_settings.addTitle("DisplayLimit", "Display Limit (Icons shrink beyond defaults)");
    BO_settings.addRangeSetting( "show_traits", 8, 1, 12, 1, "Traits" );
    BO_settings.addRangeSetting( "show_perminjuries", 3, 1, 5, 1, "Permanent Injuries" );
});