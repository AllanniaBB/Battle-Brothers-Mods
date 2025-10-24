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

::mods_hookNewObject("entity/tactical/player", function(o) 
{ 
    // SkillTypes
	// None, Active, Trait, Racial, StatusEffect, Special, Item, Perk, Terrain, WorldEvent, Background, Alert, Injury, PermanentInjury, TemporaryInjury, SemiInjury, DrugEffect, DamageOverTime, Hiring
	
	o.getDeadTraits <- function() 
	{
		local skills = this.getSkills().query(this.Const.SkillType.Trait, false, true);
		
		local list_traits = [];

		foreach (i, s in skills)
		{		
			if(::BetterObituary.Debug) ::logInfo("Better Obituary: s.FilenameByHash = " + ::IO.scriptFilenameByHash(s.ClassNameHash));
		
			local Trait = this.Const.SkillType.Trait;
			local Background = this.Const.SkillType.Background;
			local StatusEffect = this.Const.SkillType.StatusEffect;
			local Special = this.Const.SkillType.Special;

			if ((s.isType(Trait) || s.isType(Background)) && !s.isType(StatusEffect) && !s.isType(Special))
			{
				if(::BetterObituary.Debug) ::logInfo("Better Obituary: getDeadTraits = " + i + " -> Name: " + s.m.Name + " -> Type: " + s.getType());;
						
				local trait_data = {
					"id": ::IO.scriptFilenameByHash(s.ClassNameHash),
					"icon": s.getIcon()
				};
				list_traits.append(trait_data);
			}
		}

		return list_traits;
	};
	
	o.getDeadPerks <- function() 
	{
		local skills = this.getSkills().query(this.Const.SkillType.Perk, true, true);
		local list_perks = [];

		foreach (i, s in skills)
		{
			local Perk = this.Const.SkillType.Perk;

			if (s.isType(Perk))
			{
				if(::BetterObituary.Debug) ::logInfo("Better Obituary: getDeadPerks = " + i + " -> Name: " + s.m.Name + " -> Type: " + s.getType());;
						
				local perk_data = {
					"id": ::IO.scriptFilenameByHash(s.ClassNameHash),
					"icon": s.getIcon()
				};
				list_perks.append(perk_data);
			}
		}

		return list_perks;
	};
	
	o.getDeadPermanentInjury <- function() 
	{
		local PermanentInjury = this.Const.SkillType.PermanentInjury;
		local skills = this.getSkills().query(PermanentInjury);
		local list_perminjuries = [];

		foreach (i, s in skills) 
		{		
			if(s.isType(this.Const.SkillType.PermanentInjury))
			{
			if(::BetterObituary.Debug) ::logInfo("Better Obituary: getDeadPermanentInjury = " + i + " -> Name: " + s.m.Name + " -> Type: " + s.getType());
			
				local injury_data = {
					"id": ::IO.scriptFilenameByHash(s.ClassNameHash),
					"icon": s.getIcon()
				};
				list_perminjuries.append(injury_data);
			}
		}

		return list_perminjuries;
	};

	/* Test for potentially adding extra information, such as identifying friendly fire deaths
	local getObituaryInfo = o.getObituaryInfo;
	o.getObituaryInfo = function(_skill, _killer, _fatalityType)
	{
		local fallen = getObituaryInfo(_skill, _killer, _fatalityType);

		if (_killer != null && _killer.isPlayerControlled != null && _killer.isPlayerControlled())
		{
			if(_killer.isGuest())	fallen.KilledBy += " (Guest)";
			else					fallen.KilledBy += " (Bro)";
		}

		return fallen;
	};
	*/

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
		if(::BetterObituary.Debug) ::logInfo("Better Obituary: Character Name = " + _fallen.Name);;
		
		_fallen.level <- this.getLevel();
		_fallen.traits <- this.getDeadTraits();
		_fallen.perks <- this.getDeadPerks();
		_fallen.perminjuries <- this.getDeadPermanentInjury();
		_fallen.stats <- [
			this.getBaseProperties().Hitpoints,
			this.getBaseProperties().Stamina,
			this.getBaseProperties().Bravery,
			this.getBaseProperties().Initiative,
			this.getBaseProperties().MeleeSkill,
			this.getBaseProperties().RangedSkill,
			this.getBaseProperties().MeleeDefense,
			this.getBaseProperties().RangedDefense
		];
		_fallen.talents <- this.getTalents();
		
		return _fallen;
	};

});