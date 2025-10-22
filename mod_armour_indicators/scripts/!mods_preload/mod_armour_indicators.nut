::ArmourIndicators <- {
    ID = "mod_armour_indicators",
    Version = "1.4.2",
    Name = "Armour Indicators",
    BuildName = "Hotkeys + all display mode",
	Debug = false
};

local mod = ::Hooks.register(::ArmourIndicators.ID, ::ArmourIndicators.Version, ::ArmourIndicators.Name);

mod.require("mod_msu >= 1.7.0");
mod.queue(">mod_msu", function() 
{
    ::ArmourIndicators.Mod <- ::MSU.Class.Mod(::ArmourIndicators.ID, ::ArmourIndicators.Version, ::ArmourIndicators.Name);

	::mods_registerCSS("mod_armour_indicators.css");
	::mods_registerJS("mod_armour_indicators.js");

    // MSU Settings Options
    local settings = ::ArmourIndicators.Mod.ModSettings.addPage("Settings");
	
	settings.addTitle("Icon_display_thresholds", "Icon % display thresholds", "Sets the minimum repair % at which the icons will show. Note: The red icon will show from 0% repair up to the orange threshold.");
    settings.addRangeSetting( "Icons_Orange", 25, 1,  32, 1, "Low Condition (orange) %",	"Minimum repair % at which the orange icons will be shown" );
    settings.addRangeSetting( "Icons_Yellow", 50, 33, 65, 1, "Medium Condition (yellow) %",	"Minimum repair % at which the yellow icons will be shown" );
    settings.addRangeSetting( "Icons_Green",  75, 66, 99, 1, "High Condition (green) %",	"Minimum repair % at which the green icons will be shown" );
		
	// Custom Hotkeys
	::ArmourIndicators.Mod.Keybinds.addJSKeybind("CycleArmourIndicatorsPrevious",	"shift+5", "Previous icon setting",	"Cycle to previous display setting");
	::ArmourIndicators.Mod.Keybinds.addJSKeybind("CycleArmourIndicatorsNext",		"shift+6", "Next icon setting",		"Cycle to next display setting");
	
	::ArmourIndicators.Mod.Keybinds.addJSKeybind("SetMode0", "shift+1", "Show Head/Body Armor icons")
	::ArmourIndicators.Mod.Keybinds.addJSKeybind("SetMode1", "shift+2", "Show Weapon/Shield icons")
	::ArmourIndicators.Mod.Keybinds.addJSKeybind("SetMode2", "shift+3", "Show all icons")
	::ArmourIndicators.Mod.Keybinds.addJSKeybind("SetMode3", "shift+4", "Show no icons")

	// Tooltip for new button
	::ArmourIndicators.Mod.Tooltips.setTooltips({
		MyScreen = {
			isArmourIndicatorsSetMode0	= ::MSU.Class.BasicTooltip("Equipment Damage Icons",	"Shows coloured icons indicating current equipment condition.\nCurrent setting: Head/Body Armour\nNext setting: Mainhand/Offhand"),
			isArmourIndicatorsSetMode1	= ::MSU.Class.BasicTooltip("Equipment Damage Icons",	"Shows coloured icons indicating current equipment condition.\nCurrent setting: Mainhand/Offhand\nNext setting: All"),
			isArmourIndicatorsSetMode2	= ::MSU.Class.BasicTooltip("Equipment Damage Icons",	"Shows coloured icons indicating current equipment condition.\nCurrent setting: All\nNext setting: None"),
			isArmourIndicatorsSetMode3	= ::MSU.Class.BasicTooltip("Equipment Damage Icons",	"Shows coloured icons indicating current equipment condition.\nCurrent setting: None\nNext setting: Head/Body Armour"),
		}
	});

});