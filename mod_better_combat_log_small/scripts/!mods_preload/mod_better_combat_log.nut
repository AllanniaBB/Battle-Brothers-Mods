::mods_registerJS("mod_better_combat_log.js");
::mods_registerCSS("mod_better_combat_log.css");
::mods_hookClass("entity/tactical/actor", function ( o )
{
	if (!("ClassName" in o) || o.ClassName != "actor")
	{
		for( local b = o; "SuperName" in b;  )
		{
			local baseName = b.SuperName;
			b = b[baseName];

			if (baseName == "actor")
			{
				o = b;
				break;
			}
		}
	}

	o.m.MoraleRoll <- 0;
	o.m.MoraleThresholdA <- 0;
	o.m.MoraleThresholdB <- 0;
});

local onDamageReceived = function ( _attacker, _skill, _hitInfo )
{

	if (!this.isAlive() || !this.isPlacedOnMap())
		{
			return 0;
		}

		if (_hitInfo.DamageRegular == 0 && _hitInfo.DamageArmor == 0)
		{
			return 0;
		}

		if (typeof _attacker == "instance")
		{
			_attacker = _attacker.get();
		}

		if (_attacker != null && _attacker.isAlive() && _attacker.isPlayerControlled() && !this.isPlayerControlled())
		{
			this.setDiscovered(true);
			this.getTile().addVisibilityForFaction(this.Const.Faction.Player);
			this.getTile().addVisibilityForCurrentEntity();
		}

		if (this.m.CurrentProperties.IsImmuneToCriticals || this.m.CurrentProperties.IsImmuneToHeadshots)
		{
			_hitInfo.BodyDamageMult = 1.0;
		}

		local p = this.m.Skills.buildPropertiesForBeingHit(_attacker, _skill, _hitInfo);
		this.m.Items.onBeforeDamageReceived(_attacker, _skill, _hitInfo, p);
		local dmgMult = p.DamageReceivedTotalMult;

		if (_skill != null)
		{
			dmgMult = dmgMult * (_skill.isRanged() ? p.DamageReceivedRangedMult : p.DamageReceivedMeleeMult);
		}

		_hitInfo.DamageRegular -= p.DamageRegularReduction;
		_hitInfo.DamageArmor -= p.DamageArmorReduction;
		_hitInfo.DamageRegular *= p.DamageReceivedRegularMult * dmgMult;
		_hitInfo.DamageArmor *= p.DamageReceivedArmorMult * dmgMult;
		local armor = 0;
		local armorDamage = 0;

		if (_hitInfo.DamageDirect < 1.0)
		{
			armor = p.Armor[_hitInfo.BodyPart] * p.ArmorMult[_hitInfo.BodyPart];
			armorDamage = this.Math.min(armor, _hitInfo.DamageArmor);
			armor = armor - armorDamage;
			_hitInfo.DamageInflictedArmor = this.Math.max(0, armorDamage);
		}

		_hitInfo.DamageFatigue *= p.FatigueEffectMult;
		this.m.Fatigue = this.Math.min(this.getFatigueMax(), this.Math.round(this.m.Fatigue + _hitInfo.DamageFatigue * p.FatigueReceivedPerHitMult * this.m.CurrentProperties.FatigueLossOnAnyAttackMult));
		local damage = 0;
		damage = damage + this.Math.maxf(0.0, _hitInfo.DamageRegular * _hitInfo.DamageDirect * p.DamageReceivedDirectMult - armor * this.Const.Combat.ArmorDirectDamageMitigationMult);

		if (armor <= 0 || _hitInfo.DamageDirect >= 1.0)
		{
			damage = damage + this.Math.max(0, _hitInfo.DamageRegular * this.Math.maxf(0.0, 1.0 - _hitInfo.DamageDirect * p.DamageReceivedDirectMult) - armorDamage);
		}

		damage = damage * _hitInfo.BodyDamageMult;
		damage = this.Math.max(0, this.Math.max(this.Math.round(damage), this.Math.min(this.Math.round(_hitInfo.DamageMinimum), this.Math.round(_hitInfo.DamageMinimum * p.DamageReceivedTotalMult))));
		_hitInfo.DamageInflictedHitpoints = damage;
		this.m.Skills.onDamageReceived(_attacker, _hitInfo.DamageInflictedHitpoints, _hitInfo.DamageInflictedArmor);

		if (armorDamage > 0 && !this.isHiddenToPlayer() && _hitInfo.IsPlayingArmorSound)
		{
			local armorHitSound = this.m.Items.getAppearance().ImpactSound[_hitInfo.BodyPart];

			if (armorHitSound.len() > 0)
			{
				this.Sound.play(armorHitSound[this.Math.rand(0, armorHitSound.len() - 1)], this.Const.Sound.Volume.ActorArmorHit, this.getPos());
			}

			if (damage < this.Const.Combat.PlayPainSoundMinDamage)
			{
				this.playSound(this.Const.Sound.ActorEvent.NoDamageReceived, this.Const.Sound.Volume.Actor * this.m.SoundVolume[this.Const.Sound.ActorEvent.NoDamageReceived] * this.m.SoundVolumeOverall);
			}
		}

		if (damage > 0)
		{
			if (!this.m.IsAbleToDie && damage >= this.m.Hitpoints)
			{
				this.m.Hitpoints = 1;
			}
			else
			{
				this.m.Hitpoints = this.Math.round(this.m.Hitpoints - damage);
			}
		}

		if (this.m.Hitpoints <= 0)
		{
			local lorekeeperPotionEffect = this.m.Skills.getSkillByID("effects.lorekeeper_potion");

			if (lorekeeperPotionEffect != null && (!lorekeeperPotionEffect.isSpent() || lorekeeperPotionEffect.getLastFrameUsed() == this.Time.getFrame()))
			{
				this.getSkills().removeByType(this.Const.SkillType.DamageOverTime);
				this.m.Hitpoints = this.getHitpointsMax();
				lorekeeperPotionEffect.setSpent(true);
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + " is reborn by the power of the Lorekeeper!");
			}
			else
			{
				local nineLivesSkill = this.m.Skills.getSkillByID("perk.nine_lives");

				if (nineLivesSkill != null && (!nineLivesSkill.isSpent() || nineLivesSkill.getLastFrameUsed() == this.Time.getFrame()))
				{
					this.getSkills().removeByType(this.Const.SkillType.DamageOverTime);
					this.m.Hitpoints = this.Math.rand(11, 15);
					nineLivesSkill.setSpent(true);
					this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + " has nine lives!");
				}
			}
		}

		local fatalityType = this.Const.FatalityType.None;

		if (this.m.Hitpoints <= 0)
		{
			this.m.IsDying = true;

			if (_skill != null)
			{
				if (_skill.getChanceDecapitate() >= 100 || _hitInfo.BodyPart == this.Const.BodyPart.Head && this.Math.rand(1, 100) <= _skill.getChanceDecapitate() * _hitInfo.FatalityChanceMult)
				{
					fatalityType = this.Const.FatalityType.Decapitated;
				}
				else if (_skill.getChanceSmash() >= 100 || _hitInfo.BodyPart == this.Const.BodyPart.Head && this.Math.rand(1, 100) <= _skill.getChanceSmash() * _hitInfo.FatalityChanceMult)
				{
					fatalityType = this.Const.FatalityType.Smashed;
				}
				else if (_skill.getChanceDisembowel() >= 100 || _hitInfo.BodyPart == this.Const.BodyPart.Body && this.Math.rand(1, 100) <= _skill.getChanceDisembowel() * _hitInfo.FatalityChanceMult)
				{
					fatalityType = this.Const.FatalityType.Disemboweled;
				}
			}
		}

		if (_hitInfo.DamageDirect < 1.0)
		{
			local overflowDamage = _hitInfo.DamageArmor;

			if (this.m.BaseProperties.Armor[_hitInfo.BodyPart] != 0)
			{
				overflowDamage = overflowDamage - this.m.BaseProperties.Armor[_hitInfo.BodyPart] * this.m.BaseProperties.ArmorMult[_hitInfo.BodyPart];
				local newArmor = this.m.BaseProperties.Armor[_hitInfo.BodyPart] * p.ArmorMult[_hitInfo.BodyPart] - _hitInfo.DamageArmor;
				newArmor = newArmor / p.ArmorMult[_hitInfo.BodyPart];
				this.m.BaseProperties.Armor[_hitInfo.BodyPart] = this.Math.max(0, newArmor);
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + "\'s armor is hit for [b]" + this.Math.floor(_hitInfo.DamageArmor) + "[/b] damage");
			}

			if (overflowDamage > 0)
			{
				this.m.Items.onDamageReceived(overflowDamage, fatalityType, _hitInfo.BodyPart == this.Const.BodyPart.Body ? this.Const.ItemSlot.Body : this.Const.ItemSlot.Head, _attacker);
			}
		}

		if (this.getFaction() == this.Const.Faction.Player && _attacker != null && _attacker.isAlive())
		{
			this.Tactical.getCamera().quake(_attacker, this, 5.0, 0.16, 0.3);
		}

		if (damage <= 0 && armorDamage >= 0)
		{
			if ((this.m.IsFlashingOnHit || this.getCurrentProperties().IsStunned || this.getCurrentProperties().IsRooted) && !this.isHiddenToPlayer() && _attacker != null && _attacker.isAlive())
			{
				local layers = this.m.ShakeLayers[_hitInfo.BodyPart];
				local recoverMult = 1.0;
				this.Tactical.getShaker().cancel(this);
				this.Tactical.getShaker().shake(this, _attacker.getTile(), this.m.IsShakingOnHit ? 2 : 3, this.Const.Combat.ShakeEffectArmorHitColor, this.Const.Combat.ShakeEffectArmorHitHighlight, this.Const.Combat.ShakeEffectArmorHitFactor, this.Const.Combat.ShakeEffectArmorSaturation, layers, recoverMult);
			}

			this.m.Skills.update();
			this.setDirty(true);
			return 0;
		}

		if (damage >= this.Const.Combat.SpawnBloodMinDamage)
		{
			this.spawnBloodDecals(this.getTile());
		}

		if (this.m.Hitpoints <= 0)
		{
			this.spawnBloodDecals(this.getTile());
			this.kill(_attacker, _skill, fatalityType);
		}
		else
		{
			if (damage >= this.Const.Combat.SpawnBloodEffectMinDamage)
			{
				local mult = this.Math.maxf(0.75, this.Math.minf(2.0, damage / this.getHitpointsMax() * 3.0));
				this.spawnBloodEffect(this.getTile(), mult);
			}

			if (this.Tactical.State.getStrategicProperties() != null && this.Tactical.State.getStrategicProperties().IsArenaMode && _attacker != null && _attacker.getID() != this.getID())
			{
				local mult = damage / this.getHitpointsMax();

				if (mult >= 0.75)
				{
					this.Sound.play(this.Const.Sound.ArenaBigHit[this.Math.rand(0, this.Const.Sound.ArenaBigHit.len() - 1)], this.Const.Sound.Volume.Tactical * this.Const.Sound.Volume.Arena);
				}
				else if (mult >= 0.25 || this.Math.rand(1, 100) <= 20)
				{
					this.Sound.play(this.Const.Sound.ArenaHit[this.Math.rand(0, this.Const.Sound.ArenaHit.len() - 1)], this.Const.Sound.Volume.Tactical * this.Const.Sound.Volume.Arena);
				}
			}

			if (this.m.CurrentProperties.IsAffectedByInjuries && this.m.IsAbleToDie && damage >= this.Const.Combat.InjuryMinDamage && this.m.CurrentProperties.ThresholdToReceiveInjuryMult != 0 && _hitInfo.InjuryThresholdMult != 0 && _hitInfo.Injuries != null)
			{
				local potentialInjuries = [];
				local bonus = _hitInfo.BodyPart == this.Const.BodyPart.Head ? 1.25 : 1.0;

				foreach( inj in _hitInfo.Injuries )
				{
					if (inj.Threshold * _hitInfo.InjuryThresholdMult * this.Const.Combat.InjuryThresholdMult * this.m.CurrentProperties.ThresholdToReceiveInjuryMult * bonus <= damage / (this.getHitpointsMax() * 1.0))
					{
						if (!this.m.Skills.hasSkill(inj.ID) && this.m.ExcludedInjuries.find(inj.ID) == null)
						{
							potentialInjuries.push(inj.Script);
						}
					}
				}

				local appliedInjury = false;

				while (potentialInjuries.len() != 0)
				{
					local r = this.Math.rand(0, potentialInjuries.len() - 1);
					local injury = this.new("scripts/skills/" + potentialInjuries[r]);

					if (injury.isValid(this))
					{
						this.m.Skills.add(injury);

						if (this.isPlayerControlled() && this.isKindOf(this, "player"))
						{
							this.worsenMood(this.Const.MoodChange.Injury, "Suffered an injury");

							if (("State" in this.World) && this.World.State != null && this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.oath_of_sacrifice")
							{
								this.World.Statistics.getFlags().increment("OathtakersInjuriesSuffered");
							}
						}

						if (this.isPlayerControlled() || !this.isHiddenToPlayer())
						{
							this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + "\'s " + this.Const.Strings.BodyPartName[_hitInfo.BodyPart] + " is hit for [b]" + this.Math.floor(damage) + "[/b] damage and suffers " + injury.getNameOnly() + "!");
						}

						appliedInjury = true;
						break;
					}
					else
					{
						potentialInjuries.remove(r);
					}
				}

				if (!appliedInjury)
				{
					if (damage > 0 && !this.isHiddenToPlayer())
					{
						this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + "\'s " + this.Const.Strings.BodyPartName[_hitInfo.BodyPart] + " is hit for [b]" + this.Math.floor(damage) + "[/b] damage");
					}
				}
			}
		else if (damage > 0 && !this.isHiddenToPlayer())
		{
			this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + "\'s " + this.Const.Strings.BodyPartName[_hitInfo.BodyPart] + " is hit for [b]" + this.Math.floor(damage) + "[/b] damage");
		}

		if (this.m.MoraleState != this.Const.MoraleState.Ignore && damage >= this.Const.Morale.OnHitMinDamage && this.getCurrentProperties().IsAffectedByLosingHitpoints)
		{
			if (!this.isPlayerControlled() || !this.m.Skills.hasSkill("effects.berserker_mushrooms"))
			{
				this.checkMorale(-1, this.Const.Morale.OnHitBaseDifficulty * (1.0 - this.getHitpoints() / this.getHitpointsMax()) - (_attacker != null && _attacker.getID() != this.getID() ? _attacker.getCurrentProperties().ThreatOnHit : 0), this.Const.MoraleCheckType.Default, "", true);
			}
			if (!this.m.Skills.hasSkill("effects.berserker_mushrooms") && this.m.MoraleRoll > this.m.MoraleThresholdA)
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " : Morale Check - (Chance: " + this.Math.floor(this.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(this.m.MoraleRoll * 10) / 10 + ") - was scared by damage taken");

			}
		}

		this.m.Skills.onAfterDamageReceived();

		if (damage >= this.Const.Combat.PlayPainSoundMinDamage && this.m.Sound[this.Const.Sound.ActorEvent.DamageReceived].len() > 0)
		{
			local volume = 1.0;

			if (damage < this.Const.Combat.PlayPainVolumeMaxDamage)
			{
				volume = damage / this.Const.Combat.PlayPainVolumeMaxDamage;
			}

			this.playSound(this.Const.Sound.ActorEvent.DamageReceived, this.Const.Sound.Volume.Actor * this.m.SoundVolume[this.Const.Sound.ActorEvent.DamageReceived] * this.m.SoundVolumeOverall * volume, this.m.SoundPitch);
		}

		this.m.Skills.update();
		this.onUpdateInjuryLayer();

		if ((this.m.IsFlashingOnHit || this.getCurrentProperties().IsStunned || this.getCurrentProperties().IsRooted) && !this.isHiddenToPlayer() && _attacker != null && _attacker.isAlive())
		{
			local layers = this.m.ShakeLayers[_hitInfo.BodyPart];
			local recoverMult = this.Math.minf(1.5, this.Math.maxf(1.0, damage * 2.0 / this.getHitpointsMax()));
			this.Tactical.getShaker().cancel(this);
			this.Tactical.getShaker().shake(this, _attacker.getTile(), this.m.IsShakingOnHit ? 2 : 3, this.Const.Combat.ShakeEffectHitpointsHitColor, this.Const.Combat.ShakeEffectHitpointsHitHighlight, this.Const.Combat.ShakeEffectHitpointsHitFactor, this.Const.Combat.ShakeEffectHitpointsSaturation, layers, recoverMult);
		}

		this.setDirty(true);
	}

	return damage;
};

::mods_hookClass("entity/tactical/actor", function ( o )
{
	::mods_override(o, "onDamageReceived", onDamageReceived);
});

local onMovementFinish = function ( _tile )
{
	this.m.IsMoving = true;
	this.updateVisibility(_tile, this.m.CurrentProperties.getVision(), this.getFaction());

	if (this.Tactical.TurnSequenceBar.getActiveEntity() != null && this.Tactical.TurnSequenceBar.getActiveEntity().getID() != this.getID())
	{
		this.Tactical.TurnSequenceBar.getActiveEntity().updateVisibilityForFaction();
	}

	this.setZoneOfControl(_tile, this.hasZoneOfControl());

	if (!this.m.IsExertingZoneOfOccupation)
	{
		_tile.addZoneOfOccupation(this.getFaction());
		this.m.IsExertingZoneOfOccupation = true;
	}

	if (this.Const.Tactical.TerrainEffect[_tile.Type].len() > 0 && !this.m.Skills.hasSkill(this.Const.Tactical.TerrainEffectID[_tile.Type]))
	{
		this.m.Skills.add(this.new(this.Const.Tactical.TerrainEffect[_tile.Type]));
	}

	if (_tile.IsHidingEntity)
	{
		this.m.Skills.add(this.new(this.Const.Movement.HiddenStatusEffect));
	}

	local numOfEnemiesAdjacentToMe = _tile.getZoneOfControlCountOtherThan(this.getAlliedFactions());

	if (this.m.CurrentMovementType == this.Const.Tactical.MovementType.Default)
	{
		if (this.m.MoraleState != this.Const.MoraleState.Fleeing)
		{
			for( local i = 0; i != 6; i = ++i )
			{
				if (!_tile.hasNextTile(i))
				{
				}
				else
				{
					local otherTile = _tile.getNextTile(i);

					if (!otherTile.IsOccupiedByActor)
					{
					}
					else
					{
						local otherActor = otherTile.getEntity();
						local numEnemies = otherTile.getZoneOfControlCountOtherThan(otherActor.getAlliedFactions());

						if (otherActor.m.MaxEnemiesThisTurn < numEnemies && !otherActor.isAlliedWith(this))
						{
							local difficulty = this.Math.maxf(10.0, 50.0 - this.getXPValue() * 0.1);
							otherActor.checkMorale(-1, difficulty);
							otherActor.m.MaxEnemiesThisTurn = numEnemies;

							if (otherActor.m.MoraleRoll > otherActor.m.MoraleThresholdA)
							{
								this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(otherActor) + " : Morale Check - (Chance: " + this.Math.floor(otherActor.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(otherActor.m.MoraleRoll * 10) / 10 + ") - was scared by threatening enemy");
							}
							else{
								//this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(otherActor) + " : Morale Check - (Chance: " + this.Math.floor(otherActor.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(otherActor.m.MoraleRoll * 10) / 10 + ") - resisted  being scared by threatening enemy");
							}
						}
					}
				}
			}
		}
	}
	else if (this.m.CurrentMovementType == this.Const.Tactical.MovementType.Involuntary)
	{
		if (this.m.MaxEnemiesThisTurn < numOfEnemiesAdjacentToMe)
		{
			local difficulty = 40.0;
			this.checkMorale(-1, difficulty);
		}
	}

	this.m.CurrentMovementType = this.Const.Tactical.MovementType.Default;
	this.m.MaxEnemiesThisTurn = this.Math.max(1, numOfEnemiesAdjacentToMe);

	if (this.isPlayerControlled() && this.getMoraleState() > this.Const.MoraleState.Breaking && this.getMoraleState() != this.Const.MoraleState.Ignore && (_tile.SquareCoords.X == 0 || _tile.SquareCoords.Y == 0 || _tile.SquareCoords.X == 31 || _tile.SquareCoords.Y == 31))
	{
		local change = this.getMoraleState() - this.Const.MoraleState.Breaking;
		this.checkMorale(-change, -1000);
	}

	if (this.m.IsEmittingMovementSounds && this.Const.Tactical.TerrainMovementSound[_tile.Subtype].len() != 0)
	{
		local sound = this.Const.Tactical.TerrainMovementSound[_tile.Subtype][this.Math.rand(0, this.Const.Tactical.TerrainMovementSound[_tile.Subtype].len() - 1)];
		this.Sound.play("sounds/" + sound.File, sound.Volume * this.Const.Sound.Volume.TacticalMovement * this.Math.rand(90, 100) * 0.01, this.getPos(), sound.Pitch * this.Math.rand(95, 105) * 0.01);
	}

	this.spawnTerrainDropdownEffect(_tile);

	if (_tile.Properties.Effect != null && _tile.Properties.Effect.IsAppliedOnEnter)
	{
		_tile.Properties.Effect.Callback(_tile, this);
	}

	this.m.Skills.onMovementFinished();
	this.m.Items.onMovementFinished();
	this.setDirty(true);
	this.m.IsMoving = false;
};

::mods_hookClass("entity/tactical/actor", function ( o )
{
	::mods_override(o, "onMovementFinish", onMovementFinish);
});

local checkMorale = function ( _change, _difficulty, _type = this.Const.MoraleCheckType.Default, _showIconBeforeMoraleIcon = "", _noNewLine = false )
{

	if (!this.isAlive() || this.isDying())
	{
		return false;
	}

	if (this.m.MoraleState == this.Const.MoraleState.Ignore)
	{
		return false;
	}

	if (_change > 0 && this.m.MoraleState == this.Const.MoraleState.Confident)
	{
		return false;
	}

	if (_change < 0 && this.m.MoraleState == this.Const.MoraleState.Fleeing)
	{
		return false;
	}

	if (_change > 0 && this.m.MoraleState >= this.m.MaxMoraleState)
	{
		return false;
	}

	if (_change == 1 && this.m.MoraleState == this.Const.MoraleState.Fleeing)
	{
		return false;
	}

	local myTile = this.getTile();

	if (this.isPlayerControlled() && _change > 0 && (myTile.SquareCoords.X == 0 || myTile.SquareCoords.Y == 0 || myTile.SquareCoords.X == 31 || myTile.SquareCoords.Y == 31))
	{
		return false;
	}
	
	_difficulty = _difficulty * this.getCurrentProperties().MoraleEffectMult;
	local bravery = (this.getBravery() + this.getCurrentProperties().MoraleCheckBravery[_type]) * this.getCurrentProperties().MoraleCheckBraveryMult[_type];

	if (bravery > 500)
	{
		if (_change != 0)
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	local numOpponentsAdjacent = 0;
	local numAlliesAdjacent = 0;
	local threatBonus = 0;

	for( local i = 0; i != 6; i = ++i )
	{
		if (!myTile.hasNextTile(i))
		{
		}
		else
		{
			local tile = myTile.getNextTile(i);

			if (tile.IsOccupiedByActor && tile.getEntity().getMoraleState() != this.Const.MoraleState.Fleeing)
			{
				if (tile.getEntity().isAlliedWith(this))
				{
					numAlliesAdjacent = ++numAlliesAdjacent;
				}
				else
				{
					numOpponentsAdjacent = ++numOpponentsAdjacent;
					threatBonus = threatBonus + tile.getEntity().getCurrentProperties().Threat;
				}
			}
		}
	}

	this.m.MoraleRoll = this.Math.rand(1, 100);
	this.m.MoraleThresholdA = this.Math.minf(95, bravery + _difficulty - numOpponentsAdjacent * this.Const.Morale.OpponentsAdjacentMult + numAlliesAdjacent * this.Const.Morale.AlliesAdjacentMult - threatBonus);
	this.m.MoraleThresholdB = this.Math.minf(95, bravery + _difficulty - numOpponentsAdjacent * this.Const.Morale.OpponentsAdjacentMult - threatBonus);

	if (_change > 0)
	{
		if (this.Math.rand(1, 100) > this.Math.minf(95, bravery + _difficulty - numOpponentsAdjacent * this.Const.Morale.OpponentsAdjacentMult - threatBonus))
		{
			if (this.Math.rand(1, 100) > this.m.CurrentProperties.RerollMoraleChance || this.Math.rand(1, 100) > this.Math.minf(95, bravery + _difficulty - numOpponentsAdjacent * this.Const.Morale.OpponentsAdjacentMult - threatBonus))
			{
				return false;
			}
			
			// Rally
			if (_showIconBeforeMoraleIcon == "status_effect_56")
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " : Morale Check - (Chance: " + this.Math.floor(this.m.MoraleThresholdB * 10) / 10 + ", Rolled: " + this.Math.floor(this.m.MoraleRoll * 10) / 10 + ") - failed to rally");
			}

			return false;
		}
	}
	else if (_change < 0)
	{
		if (this.Math.rand(1, 100) <= this.Math.minf(95, bravery + _difficulty - numOpponentsAdjacent * this.Const.Morale.OpponentsAdjacentMult + numAlliesAdjacent * this.Const.Morale.AlliesAdjacentMult - threatBonus))
		{
		    // Rally
			if (_showIconBeforeMoraleIcon == "status_effect_56")
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " : Morale Check - (Chance: " + this.Math.floor(this.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(this.m.MoraleRoll * 10) / 10 + ") - successfully rallied");
			}
			return false;
		}

		if (this.Math.rand(1, 100) <= this.m.CurrentProperties.RerollMoraleChance && this.Math.rand(1, 100) <= this.Math.minf(95, bravery + _difficulty - numOpponentsAdjacent * this.Const.Morale.OpponentsAdjacentMult + numAlliesAdjacent * this.Const.Morale.AlliesAdjacentMult - threatBonus))
		{
		    // Rally
			if (_showIconBeforeMoraleIcon == "status_effect_56")
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " : Morale Check - (Chance: " + this.Math.floor(this.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(this.m.MoraleRoll * 10) / 10 + ") - successfully rallied");
			}
			return false;
		}
	}
	else if (this.Math.rand(1, 100) <= this.Math.minf(95, bravery + _difficulty - numOpponentsAdjacent * this.Const.Morale.OpponentsAdjacentMult + numAlliesAdjacent * this.Const.Morale.AlliesAdjacentMult - threatBonus))
	{
	    // Rally
		if (_showIconBeforeMoraleIcon == "status_effect_56")
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " : Morale Check - (Chance: " + this.Math.floor(this.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(this.m.MoraleRoll * 10) / 10 + ") - successfully rallied");
		}

		return true;
	}
	else if (this.Math.rand(1, 100) <= this.m.CurrentProperties.RerollMoraleChance && this.Math.rand(1, 100) <= this.Math.minf(95, bravery + _difficulty - numOpponentsAdjacent * this.Const.Morale.OpponentsAdjacentMult + numAlliesAdjacent * this.Const.Morale.AlliesAdjacentMult - threatBonus))
	{
		return true;
	}
	else
	{
	    // Rally
		if (_showIconBeforeMoraleIcon == "status_effect_56")
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " : Morale Check - (Chance: " + this.Math.floor(this.m.MoraleThresholdB * 10) / 10 + ", Rolled: " + this.Math.floor(this.m.MoraleRoll * 10) / 10 + ") - failed to rallied");
		}

		return false;
	}

	local oldMoraleState = this.m.MoraleState;
	this.m.MoraleState = this.Math.min(this.Const.MoraleState.Confident, this.Math.max(0, this.m.MoraleState + _change));
	this.m.FleeingRounds = 0;

	if (this.m.MoraleState == this.Const.MoraleState.Confident && oldMoraleState != this.Const.MoraleState.Confident && ("State" in this.World) && this.World.State != null && this.World.Ambitions.hasActiveAmbition() && this.World.Ambitions.getActiveAmbition().getID() == "ambition.oath_of_camaraderie")
	{
		this.World.Statistics.getFlags().increment("OathtakersBrosConfident");
	}

	if (oldMoraleState == this.Const.MoraleState.Fleeing && this.m.IsActingEachTurn)
	{
		this.setZoneOfControl(this.getTile(), this.hasZoneOfControl());

		if (this.isPlayerControlled() || !this.isHiddenToPlayer())
		{
			if (_noNewLine)
			{
				this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + " has rallied");
			}
			else
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " has rallied");
			}
		}
	}
	else if (this.m.MoraleState == this.Const.MoraleState.Fleeing)
	{
		this.setZoneOfControl(this.getTile(), this.hasZoneOfControl());
		this.m.Skills.removeByID("effects.shieldwall");
		this.m.Skills.removeByID("effects.spearwall");
		this.m.Skills.removeByID("effects.riposte");
		this.m.Skills.removeByID("effects.return_favor");
		this.m.Skills.removeByID("effects.indomitable");
	}

	local morale = this.getSprite("morale");

	if (this.Const.MoraleStateBrush[this.m.MoraleState].len() != 0)
	{
		if (this.m.MoraleState == this.Const.MoraleState.Confident)
		{
			morale.setBrush(this.m.ConfidentMoraleBrush);
		}
		else
		{
			morale.setBrush(this.Const.MoraleStateBrush[this.m.MoraleState]);
		}

		morale.Visible = true;
	}
	else
	{
		morale.Visible = false;
	}

	if (this.isPlayerControlled() || !this.isHiddenToPlayer())
	{
		if (_noNewLine)
		{
			this.Tactical.EventLog.logEx(this.Const.UI.getColorizedEntityName(this) + this.Const.MoraleStateEvent[this.m.MoraleState]);
		}
		else
		{
			this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + this.Const.MoraleStateEvent[this.m.MoraleState]);
		}

		if (_showIconBeforeMoraleIcon != "")
		{
			this.Tactical.spawnIconEffect(_showIconBeforeMoraleIcon, this.getTile(), this.Const.Tactical.Settings.SkillIconOffsetX, this.Const.Tactical.Settings.SkillIconOffsetY, this.Const.Tactical.Settings.SkillIconScale, this.Const.Tactical.Settings.SkillIconFadeInDuration, this.Const.Tactical.Settings.SkillIconStayDuration, this.Const.Tactical.Settings.SkillIconFadeOutDuration, this.Const.Tactical.Settings.SkillIconMovement);
		}

		if (_change > 0)
		{
			this.Tactical.spawnIconEffect(this.Const.Morale.MoraleUpIcon, this.getTile(), this.Const.Tactical.Settings.SkillIconOffsetX, this.Const.Tactical.Settings.SkillIconOffsetY, this.Const.Tactical.Settings.SkillIconScale, this.Const.Tactical.Settings.SkillIconFadeInDuration, this.Const.Tactical.Settings.SkillIconStayDuration, this.Const.Tactical.Settings.SkillIconFadeOutDuration, this.Const.Tactical.Settings.SkillIconMovement);
		}
		else
		{
			this.Tactical.spawnIconEffect(this.Const.Morale.MoraleDownIcon, this.getTile(), this.Const.Tactical.Settings.SkillIconOffsetX, this.Const.Tactical.Settings.SkillIconOffsetY, this.Const.Tactical.Settings.SkillIconScale, this.Const.Tactical.Settings.SkillIconFadeInDuration, this.Const.Tactical.Settings.SkillIconStayDuration, this.Const.Tactical.Settings.SkillIconFadeOutDuration, this.Const.Tactical.Settings.SkillIconMovement);
		}
	}

	this.m.Skills.update();
	this.setDirty(true);

	if (this.m.MoraleState == this.Const.MoraleState.Fleeing && this.Tactical.TurnSequenceBar.getActiveEntity() != this)
	{
		this.Tactical.TurnSequenceBar.pushEntityBack(this.getID());
	}

	if (this.m.MoraleState == this.Const.MoraleState.Fleeing)
	{
		local actors = this.Tactical.Entities.getInstancesOfFaction(this.getFaction());

		if (actors != null)
		{
			foreach( a in actors )
			{
				if (a.getID() != this.getID())
				{
					a.onOtherActorFleeing(this);
				}
			}
		}
	}

	return true;
};

::mods_hookClass("entity/tactical/actor", function ( o )
{
	::mods_override(o, "checkMorale", checkMorale);
});

::mods_hookNewObject("skills/actives/charm_skill", function ( o )
{
	o.onDelayedEffect = function ( _tag )
	{
		local _targetTile = _tag.TargetTile;
		local _user = _tag.User;
		local target = _targetTile.getEntity();
		local time = this.Tactical.spawnProjectileEffect("effect_heart_01", _user.getTile(), _targetTile, 0.33, 2.0, false, false);
		local self = this;
		this.Time.scheduleEvent(this.TimeUnit.Virtual, time, function ( _e )
		{
			local bonus = _targetTile.getDistanceTo(_user.getTile()) == 1 ? -5 : 0;

			if (target.checkMorale(0, -35 + bonus, this.Const.MoraleCheckType.MentalAttack))
			{
				if (!_user.isHiddenToPlayer() && !target.isHiddenToPlayer())
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(target) + " : (Chance: " + target.m.MoraleThresholdA + ", Rolled: " + target.m.MoraleRoll + ")" + " and resists being charmed");
				}

				return false;
			}

			if (target.checkMorale(0, -35 + bonus, this.Const.MoraleCheckType.MentalAttack))
			{
				if (!_user.isHiddenToPlayer() && !target.isHiddenToPlayer())
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(target) + " : (Chance: " + target.m.MoraleThresholdA + ", Rolled: " + target.m.MoraleRoll + ")" + " and resists being charmed");
				}

				return false;
			}

			if (target.getCurrentProperties().IsResistantToAnyStatuses && this.Math.rand(1, 100) <= 50)
			{
				if (!_user.isHiddenToPlayer() && !target.isHiddenToPlayer())
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(target) + " : (Chance: " + target.m.MoraleThresholdA + ", Rolled: " + target.m.MoraleRoll + ")" + " resists being charmed thanks to his unnatural physiology");
				}

				return false;
			}

			this.m.Slaves.push(target.getID());
			local charmed = this.new("scripts/skills/effects/charmed_effect");
			charmed.setMasterFaction(_user.getFaction() == this.Const.Faction.Player ? this.Const.Faction.PlayerAnimals : _user.getFaction());
			charmed.setMaster(self);
			target.getSkills().add(charmed);

			if (!_user.isHiddenToPlayer() && !target.isHiddenToPlayer())
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(target) + " is charmed");
			}

			_user.setCharming(true);
		}.bindenv(this), this);
	};
});

::mods_hookNewObject("skills/actives/warcry", function ( o )
{
	o.onDelayedEffect = function ( _tag )
	{
		local mytile = _tag.User.getTile();
		local actors = this.Tactical.Entities.getAllInstances();

		foreach( i in actors )
		{
			foreach( a in i )
			{
				if (a.getID() == _tag.User.getID())
				{
					continue;
				}

				if (a.getFaction() == _tag.User.getFaction())
				{
					local difficulty = 10 - this.Math.pow(a.getTile().getDistanceTo(mytile), this.Const.Morale.EnemyKilledDistancePow);

					if (a.getMoraleState() == this.Const.MoraleState.Fleeing)
					{
						a.checkMorale(this.Const.MoraleState.Wavering - this.Const.MoraleState.Fleeing, difficulty);
					}
					else
					{
						a.checkMorale(1, difficulty);
					}

					a.setFatigue(a.getFatigue() - 20);
				}
				else if (!a.isAlliedWith(_tag.User))
				{
					local difficulty = 5 + this.Math.pow(a.getTile().getDistanceTo(mytile), this.Const.Morale.AllyKilledDistancePow);
					a.checkMorale(-1, difficulty, this.Const.MoraleCheckType.MentalAttack);

					if (a.m.MoraleRoll < a.m.MoraleThresholdA)
					{
						this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(a) + " : Morale Check - (Chance: " + this.Math.floor(a.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(a.m.MoraleRoll * 10) / 10 + ") - resisted warcry");
					}
					else
					{
						this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(a) + " : Morale Check - (Chance: " + this.Math.floor(a.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(a.m.MoraleRoll * 10) / 10 + ") - was scared by warcry");
					}
				}
			}
		}
	};
});
::mods_hookNewObject("skills/actives/horror_skill", function ( o )
{
	o.onUse = function ( _user, _targetTile )
	{
		local targets = [];

		if (_targetTile.IsOccupiedByActor)
		{
			local entity = _targetTile.getEntity();

			if (this.isViableTarget(_user, entity))
			{
				targets.push(entity);
			}
		}

		for( local i = 0; i < 6; i = ++i )
		{
			if (!_targetTile.hasNextTile(i))
			{
			}
			else
			{
				local adjacent = _targetTile.getNextTile(i);

				if (adjacent.IsOccupiedByActor)
				{
					local entity = adjacent.getEntity();

					if (this.isViableTarget(_user, entity))
					{
						targets.push(entity);
					}
				}
			}
		}

		foreach( target in targets )
		{
			local effect = this.Tactical.spawnSpriteEffect("effect_skull_03", this.createColor("#ffffff"), target.getTile(), 0, 40, 1.0, 0.25, 0, 400, 300);

			if (target.getCurrentProperties().MoraleCheckBraveryMult[this.Const.MoraleCheckType.MentalAttack] >= 1000.0)
			{
				continue;
			}

			target.checkMorale(-1, -15, this.Const.MoraleCheckType.MentalAttack);

			if (!target.checkMorale(0, -5, this.Const.MoraleCheckType.MentalAttack))
			{
				target.getSkills().add(this.new("scripts/skills/effects/horrified_effect"));

				if (!_user.isHiddenToPlayer() && !target.isHiddenToPlayer())
				{
					this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " : Morale Check - (Chance: " + this.Math.floor(this.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(this.m.MoraleRoll * 10) / 10 + ") and is horrified");
				}
			}
			else
			{
				this.Tactical.EventLog.log(this.Const.UI.getColorizedEntityName(this) + " : Morale Check - (Chance: " + this.Math.floor(this.m.MoraleThresholdA * 10) / 10 + ", Rolled: " + this.Math.floor(this.m.MoraleRoll * 10) / 10 + ") and saved against horrified");
			}
		}

		return true;
	};
});