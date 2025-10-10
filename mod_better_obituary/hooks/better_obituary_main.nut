// Hook into tactical state to modify gatherBrothers behavior
::mods_hookNewObject("states/tactical_state", function(o) 
{
	local oldGatherBrothers = o.gatherBrothers;
	o.gatherBrothers <- function(_isVictory) 
	{
		this.m.CombatResultRoster = [];
		this.Tactical.CombatResultRoster <- this.m.CombatResultRoster;
		local alive = this.Tactical.Entities.getAllInstancesAsArray();

		foreach(bro in alive) 
		{
			if (bro.isAlive() && this.isKindOf(bro, "player")) 
			{
				bro.onBeforeCombatResult();

				if (bro.isAlive() && !bro.isGuest() && bro.isPlayerControlled())
				{
					this.m.CombatResultRoster.push(bro);
				}
			}
		}

		local dead = this.Tactical.getCasualtyRoster().getAll();
		local survivor = this.Tactical.getSurvivorRoster().getAll();
		local retreated = this.Tactical.getRetreatRoster().getAll();
		local isArena = this.m.StrategicProperties != null && this.m.StrategicProperties.IsArenaMode;

		if (_isVictory || isArena) 
		{
			foreach(s in survivor) 
			{
				s.setIsAlive(true);
				s.onBeforeCombatResult();

				foreach(i, d in dead) 
				{
					if (s.getID() == d.getOriginalID()) 
					{
						dead.remove(i);
						this.Tactical.getCasualtyRoster().remove(d);
						break;
					}
				}
			}
			this.m.CombatResultRoster.extend(survivor);
		} 
		else {
			foreach(bro in survivor) 
			{
				::BetterObituary.addFallen(bro, "Left to die");
				bro.getSkills().onDeath(this.Const.FatalityType.None);
				this.World.getPlayerRoster().remove(bro);
				bro.die();
			}
		}

		foreach(s in retreated) 
		{
			s.onBeforeCombatResult();
		}

		this.m.CombatResultRoster.extend(retreated);
		this.m.CombatResultRoster.extend(dead);

		if (!this.isScenarioMode() && dead.len() > 1 && dead.len() >= this.m.CombatResultRoster.len() / 2) 
		{
			this.updateAchievement("TimeToRebuild", 1, 1);
		}

		if (!this.isScenarioMode() && this.World.getPlayerRoster().getSize() == 0 && this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians) != null && this.m.Factions.getHostileFactionWithMostInstances() == this.World.FactionManager.getFactionOfType(this.Const.FactionType.Barbarians).getID()) 
		{
			this.updateAchievement("GiveMeBackMyLegions", 1, 1);
		}
	};
});

// Hook player entity to add getDeadTraits and override onDeath
::mods_hookNewObject("entity/tactical/player", function(o) 
{

	o.getDeadTraits <- function() 
	{
		local skills = this.getSkills().query(this.Const.SkillType.Trait, false, true);
		local list_traits = [];

		foreach (i, s in skills) 
		{
	
		::logInfo("Better Obituary: getDeadTraits = " + this.Const.SkillType);
		
			if (s.isType(this.Const.SkillType.StatusEffect) ||
				s.isType(this.Const.SkillType.Active) ||
				s.isType(this.Const.SkillType.Racial) ||
				s.isType(this.Const.SkillType.Special) ||
				s.isType(this.Const.SkillType.Perk) ||
				s.isType(this.Const.SkillType.Terrain) ||
				s.isType(this.Const.SkillType.Injury) ||
				s.isType(this.Const.SkillType.PermanentInjury) ||
				s.isType(this.Const.SkillType.SemiInjury) ||
				s.isType(this.Const.SkillType.DrugEffect) ||
				s.isType(this.Const.SkillType.DamageOverTime)) {
				continue;
			}
			list_traits.append(s.getIcon());
		}

		for (local i = list_traits.len(); i < ::BetterObituary.num_traits ; i++) 
		{
			list_traits.append("");
		}

		return list_traits;
	};

	o.getDeadPermanentInjury <- function() 
	{
		local skills = this.getSkills().query(this.Const.SkillType.PermanentInjury);
		local list_perminjuries = [];

		foreach (i, s in skills) 
		{
		
		::logInfo("Better Obituary: getDeadPermanentInjury = " + s);
		
			if (s.isType(this.Const.SkillType.StatusEffect) ||
				s.isType(this.Const.SkillType.Active) ||
				s.isType(this.Const.SkillType.Racial) ||
				s.isType(this.Const.SkillType.Special) ||
				s.isType(this.Const.SkillType.Perk) ||
				s.isType(this.Const.SkillType.Terrain) ||
				s.isType(this.Const.SkillType.Trait) ||
				s.isType(this.Const.SkillType.SemiInjury) ||
				s.isType(this.Const.SkillType.DrugEffect) ||
				s.isType(this.Const.SkillType.DamageOverTime)) {
				continue;
			}
			list_perminjuries.append(s.getIcon());
		}

		for (local i = list_perminjuries.len(); i < ::BetterObituary.num_perminjuries ; i++) 
		{
			list_perminjuries.append("");
		}

		return list_perminjuries;
	};
	
	local onDeath = o.onDeath;
	o.onDeath <- function(_killer, _skill, _tile, _fatalityType) 
	{
		local bro = this;

		if (::Tactical.State.isScenarioMode()) 
		{
			onDeath(_killer, _skill, _tile, _fatalityType);
			return; 
		}

		local originalAddFallen = ::World.Statistics.addFallen;
		::World.Statistics.addFallen = function(_fallen) 
		{
			originalAddFallen(bro.finalizeFallen(_fallen));
		}

		onDeath(_killer, _skill, _tile, _fatalityType);
			
		::World.Statistics.addFallen = originalAddFallen;
	};
	
	o.finalizeFallen <- function(_fallen) 
	{
		_fallen.level <- this.getLevel();
		_fallen.traits <- this.getDeadTraits();
		_fallen.talents <- this.getTalents();
		_fallen.perminjuries <- this.getDeadPermanentInjury();
		local baseProps = this.getBaseProperties();
		_fallen.stats <- [
			baseProps.Hitpoints,
			baseProps.Stamina,
			baseProps.Bravery,
			baseProps.Initiative,
			baseProps.MeleeSkill,
			baseProps.RangedSkill,
			baseProps.MeleeDefense,
			baseProps.RangedDefense
		];
		return _fallen;
	};

});

::mods_hookNewObject("ui/screens/tooltip/tooltip_events", function(o) 
{
	local original_onQueryUIElementTooltipData = o.onQueryUIElementTooltipData;

	function extendTooltipData(tooltip, _entityId, _elementId, _elementOwner) 
	{
		local tooltipMap = {
			"world-screen.obituary.Level": ["Level", "The level the character was upon their demise."],
			"world-screen.obituary.Traits": ["Traits", "The background and traits the character had upon their demise."],
			"world-screen.obituary.PermInjuries": ["Permanent Injuries", "The permanent injuries the character had upon their demise."],
			"world-screen.obituary.Stats": ["Stats", "The base stats the character had upon their demise."]
		};

		if (_elementId in tooltipMap) 
		{
			local data = tooltipMap[_elementId];
			return [
				{ id = 1, type = "title", text = data[0] },
				{ id = 2, type = "description", text = data[1] }
			];
		}

		return tooltip; // fallback to original if no match
	}

	o.onQueryUIElementTooltipData = function(_entityId, _elementId, _elementOwner) 
	{

		// Call original function
		local tooltip = original_onQueryUIElementTooltipData(_entityId, _elementId, _elementOwner);

		// Extend tooltip and use the returned value
		local extendedTooltip = extendTooltipData(tooltip, _entityId, _elementId, _elementOwner);

		return extendedTooltip;
	}
});