::mods_hookNewObject("ui/screens/tooltip/tooltip_events", function(o) 
{
	local original_onQueryUIElementTooltipData = o.onQueryUIElementTooltipData;

	function extendTooltipData(tooltip, _entityId, _elementId, _elementOwner) 
	{
		local tooltipMap = {
			"world-screen.obituary.Level": ["Level", "The level the character was upon meeting their fate."],
			"world-screen.obituary.Traits": ["Traits", "The background and traits the character had upon meeting their fate."],
			"world-screen.obituary.PermInjuries": ["Permanent Injuries", "The permanent injuries the character had upon meeting their fate."],
			"world-screen.obituary.HP": ["Hitpoints", "The base hitpoints the character had upon meeting their fate."],
			"world-screen.obituary.FT": ["Fatigue", "The base fatigue the character had upon meeting their fate."],
			"world-screen.obituary.BR": ["Resolve", "The base resolve the character had upon meeting their fate."],
			"world-screen.obituary.IT": ["Initiative", "The base initiative the character had upon meeting their fate."],
			"world-screen.obituary.MA": ["Melee Skill", "The base melee skill the character had upon meeting their fate."],
			"world-screen.obituary.RA": ["Ranged Skill", "The base ranged skill the character had upon meeting their fate."],
			"world-screen.obituary.MD": ["Melee Defense", "The base melee defense the character had upon meeting their fate."],
			"world-screen.obituary.RD": ["Ranged Defense", "The base ranged defense the character had upon meeting their fate."]
			
		};

		if (_elementId in tooltipMap) 
		{
			local data = tooltipMap[_elementId];
			return [
				{ id = 1, type = "title", text = data[0] },
				{ id = 2, type = "description", text = data[1] }
			];
		}

		return tooltip;
	}

	o.onQueryUIElementTooltipData = function(_entityId, _elementId, _elementOwner) 
	{
		local tooltip = original_onQueryUIElementTooltipData(_entityId, _elementId, _elementOwner);

		// Extend tooltip and use the returned value
		local extendedTooltip = extendTooltipData(tooltip, _entityId, _elementId, _elementOwner);

		return extendedTooltip;
	}
});