::BetterObituary <- {
    ID = "mod_better_obituary",
    Version = "3.5.0",
    Name = "Better Obituary",
    BuildName = "Perks and all the settings",
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
		
	BO_settings.addBooleanSetting("SwapPerks",    false, "Show Perks", "Swaps the trait/permanent injuries columns for perks.");
	BO_settings.addBooleanSetting("SwapStats", 	  false, "Swap Stat Order", "Swaps the position of first 4 stats (hp, fatigue, initiative, bravery) with the last 4 (attack / defense).");
    BO_settings.addBooleanSetting("StackedStars", false, "Stacked Talent Stars", "Replace the 3 star talent icon (row of 3) with a triangle of stars.");
	
	BO_settings.addDivider("Divider");
	
	BO_settings.addBooleanSetting("HideObituarySetting",    false, "Hide Obituary Settings", "Hide the checkbox settings shown in top right of the obituary.\n\nThese mirror the settings above, providing a way to change them whilst in the obituary without using hotkeys, or simply to view the current settings.");
	
	BO_settings.addDivider("Divider");
	
	BO_settings.addTitle("DisplayLimit", "Display Limit (Icons shrink beyond defaults)");
    BO_settings.addRangeSetting( "show_num_traits", 8, 1, 12, 1, "Traits" );
    BO_settings.addRangeSetting( "show_num_perminjuries", 3, 1, 5, 1, "Permanent Injuries" );
    BO_settings.addRangeSetting( "show_num_perks", 10, 1, 20, 1, "Perks" );
	
	BO_settings.addDivider("Divider");
	BO_settings.addTitle("TooltipSettings", "Tooltip Settings");
		
	BO_settings.addColorPickerSetting("hotkey_text_colour", "255,255,0,1", "Hotkey Text Colour");

	// Configurable hotkeys
	::BetterObituary.Mod.Keybinds.addJSKeybind("toggle_perks", 		   "shift+p", "Show Perks");
	::BetterObituary.Mod.Keybinds.addJSKeybind("toggle_stat_order",	   "shift+s", "Swap Stat Order");
	::BetterObituary.Mod.Keybinds.addJSKeybind("stacked_talent_stars", "shift+t", "Stacked Talent Stars");
});