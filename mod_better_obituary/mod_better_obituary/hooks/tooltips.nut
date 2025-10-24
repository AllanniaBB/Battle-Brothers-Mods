::mods_hookNewObject("ui/screens/tooltip/tooltip_events", function(o)
{
	local original_onQueryUIElementTooltipData = o.onQueryUIElementTooltipData;

	// Arena trait have getActor in getTooltip, so bypass with hardcoded data
	function BuildTooltip(_elementId, skill)
	{
		local title = skill.getName();
		local descr = skill.getDescription();
		local bonus1 = null;
		local bonus2 = null;

		// Arena traits specific
		if (_elementId.find("veteran") != null)
		{
			bonus1 = {
				id = 10,
				type = "text",
				icon = "ui/icons/bravery.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+10[/color] Resolve"
			};
			bonus2 = {
				id = 11,
				type = "text",
				icon = "ui/icons/special.png",
				text = "Has a [color=" + this.Const.UI.Color.PositiveValue + "]50%[/color] chance to survive if struck down and not killed by a fatality"
			};
			descr += " So far, this character has fought in and won many matches.";
		}
		else if (_elementId.find("pit_fighter") != null)
		{
			descr += " So far, this character has fought in and won some matches.";
		}
		else if (_elementId.find("fighter") != null)
		{
			bonus1 = {
				id = 10,
				type = "text",
				icon = "ui/icons/bravery.png",
				text = "[color=" + this.Const.UI.Color.PositiveValue + "]+5[/color] Resolve"
			};
			descr += " So far, this character has fought in and won a few matches.";
		}

		local result = [
			{ id = 1, type = "title", text = title },
			{ id = 2, type = "description", text = descr }
		];

		if (bonus1 != null) result.push(bonus1);
		if (bonus2 != null) result.push(bonus2);

		return result;
	}

	function getColoredKeybindText(_keybindId)
	{
		local hex = ::BetterObituary.Mod.ModSettings.getSetting("hotkey_text_colour").getValueAsHexString();
		local hexWithoutAlpha = hex.slice(0, 6); // Strip 'ff' alpha
		local textHexColour = "#" + hexWithoutAlpha;

		local colouredText = "[color=" + textHexColour + "]" + ::BetterObituary.Mod.Keybinds.getKeybind(_keybindId).getKeyCombinationsCapitalized() + "[/color]";

		return colouredText;
	}

	function getObituaryStatTooltip(_elementId)
	{
		local tooltipMap = {
			"world-screen.obituary.Level": ["Level", "The level the character was upon meeting their fate."],
			"world-screen.obituary.Traits": ["Traits", "The background and traits the character had upon meeting their fate."],
			"world-screen.obituary.PermInjuries": ["Permanent Injuries", "The permanent injuries the character had upon meeting their fate."],
			"world-screen.obituary.Perks": ["Perks", "The perks the character had upon meeting their fate."],
			"world-screen.obituary.HP": ["Hitpoints", "The base hitpoints the character had upon meeting their fate."],
			"world-screen.obituary.FT": ["Fatigue", "The base fatigue the character had upon meeting their fate."],
			"world-screen.obituary.BR": ["Resolve", "The base resolve the character had upon meeting their fate."],
			"world-screen.obituary.IT": ["Initiative", "The base initiative the character had upon meeting their fate."],
			"world-screen.obituary.MA": ["Melee Skill", "The base melee skill the character had upon meeting their fate."],
			"world-screen.obituary.RA": ["Ranged Skill", "The base ranged skill the character had upon meeting their fate."],
			"world-screen.obituary.MD": ["Melee Defense", "The base melee defense the character had upon meeting their fate."],
			"world-screen.obituary.RD": ["Ranged Defense", "The base ranged defense the character had upon meeting their fate."],
			"world-screen.obituary.swapperks": ["Show Perks", "Swap the trait/permanent injuries columns for perks.\nHotkey: " + getColoredKeybindText("toggle_perks")],
			"world-screen.obituary.swapstats": ["Swap Stat Order", "Swaps the position of first 4 stats (hp, fatigue, initiative, bravery) with the last 4 (attack / defense).\nHotkey: " + getColoredKeybindText("toggle_stat_order")],
			"world-screen.obituary.stackedstars": ["Stacked Talent Stars", "Replace the 3 star talent icon (row of 3) with a triangle of stars.\nHotkey: " + getColoredKeybindText("stacked_talent_stars")]
		};

		if (_elementId in tooltipMap)
		{
			local data = tooltipMap[_elementId];
			return [
				{ id = 1, type = "title", text = data[0] },
				{ id = 2, type = "description", text = data[1] }
			];
		}

		return null;
	}

	o.onQueryUIElementTooltipData = function(_entityId, _elementId, _elementOwner)
	{
		// New Obituary header UI elements
		local statTooltip = getObituaryStatTooltip(_elementId);
		if (statTooltip != null)
		{
			return statTooltip;
		}

		if (_elementId == null || _elementId == "" || _elementId.find("scripts/skills/") == null)
		{
			return original_onQueryUIElementTooltipData(_entityId, _elementId, _elementOwner);
		}

		local skill = ::new(_elementId);

		// Backgrounds use getGenericTooltip, not getTooltip
		if (_elementId.find("background") != null && _elementId.find("background") > 0)
		{
			return skill.getGenericTooltip();
		}

		// Arena traits manual override - they have getActor in getTooltip
		// Not all perks have getTooltip, so build manually.
		if (_elementId.find("arena") != null || _elementId.find("perk") != null)
		{
			return BuildTooltip(_elementId, skill);
		}

		if ("getTooltip" in skill)
		{
			try
			{
				return skill.getTooltip();
			}
			catch (e)
			{
				::logError("Better Obituary: skill.getTooltip() failed: " + e);
			}
		}
		else if ("getGenericTooltip" in skill)
		{
			try
			{
				return skill.getGenericTooltip();
			}
			catch (e)
			{
				::logError("Better Obituary: skill.getGenericTooltip() failed: " + e);
			}
		}

		return original_onQueryUIElementTooltipData(_entityId, _elementId, _elementOwner);
	};
});
