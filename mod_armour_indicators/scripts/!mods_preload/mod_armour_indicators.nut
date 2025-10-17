::ArmourIndicators <- {
    ID = "mod_armour_indicators",
    Version = "1.3.0",
    Name = "Armour Indicators",
    BuildName = "MSU Settings",
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
	
	// Tooltip for new button
	::ArmourIndicators.Mod.Tooltips.setTooltips({
		MyScreen = { isArmourIndicatorsFilterButton = ::MSU.Class.BasicTooltip("Armour Indicators", "Cycles damage icons display in order: head/body, weapon/shield, none.") }
	})

});