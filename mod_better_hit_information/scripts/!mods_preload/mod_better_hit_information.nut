::mods_registerMod("mod_better_hit_information", 2, "Better Hit Information");

local getHitFactors = function ( _targetTile )
{

	local textmodifier = function (text, textcolour)
	{
		if (textcolour == "green")
		{
			return "[color=" + this.Const.UI.Color.PositiveValue + "]" + text + "%[/color] ";
		}
		else if (textcolour == "red")
		{
			return "[color=" + this.Const.UI.Color.NegativeValue + "]" + text + "%[/color] ";
		}
		else{
			return text + "%";
		}
	};

	local ret = [];
	local user = this.m.Container.getActor();
	local myTile = user.getTile();
	local targetEntity = _targetTile.IsOccupiedByActor ? _targetTile.getEntity() : null;
	local properties = this.m.Container.buildPropertiesForUse(this, targetEntity);

	if (this.m.HitChanceBonus > 0)
	{
		ret.push({
			icon = "ui/tooltips/positive.png",
			text = textmodifier(this.m.HitChanceBonus, "green") + this.getName()
		});
	}

	if (!this.m.IsRanged && targetEntity != null && targetEntity.getSurroundedCount() != 0 && !targetEntity.getCurrentProperties().IsImmuneToSurrounding)
	{
		local malus = this.Math.max(0, targetEntity.getCurrentProperties().SurroundedBonus - targetEntity.getCurrentProperties().SurroundedDefense) * targetEntity.getSurroundedCount();
		ret.push({
			icon = "ui/tooltips/positive.png",
			text = textmodifier(malus, "green") + "Surrounded"
		});
	}

	if (_targetTile.Level < this.m.Container.getActor().getTile().Level)
	{
		ret.push({
			icon = "ui/tooltips/positive.png",
			text = textmodifier(this.Const.Combat.LevelDifferenceToHitBonus, "green") + "Height advantage"
		});
	}

	if (_targetTile.IsBadTerrain)
	{
		local targetEntityDefense = targetEntity.getCurrentProperties().getMeleeDefense();

		if (this.m.IsRanged)
		{
			targetEntityDefense = targetEntity.getCurrentProperties().getRangedDefense();
		}

		targetEntityDefense = targetEntityDefense / 0.75 * (1 - 0.75);
		ret.push({
			icon = "ui/tooltips/positive.png",
			text = textmodifier(this.Math.ceil(targetEntityDefense), "green") + "Target on bad terrain"
		});
	}

	if (this.m.IsAttack)
	{
		local fast_adaption = this.m.Container.getSkillByID("perk.fast_adaption");

		if (fast_adaption != null && fast_adaption.isBonusActive())
		{
			ret.push({
				icon = "ui/tooltips/positive.png",
				text = textmodifier(fast_adaption.m.Stacks * 8, "green") + "Fast Adaption"
			});
		}
	}

	local oath = this.m.Container.getSkillByID("trait.oath_of_wrath");

	if (oath != null)
	{
		local items = user.getItems();
		local main = items.getItemAtSlot(this.Const.ItemSlot.Mainhand);

		if (main != null && main.isItemType(this.Const.Items.ItemType.MeleeWeapon) && (main.isItemType(this.Const.Items.ItemType.TwoHanded) || items.getItemAtSlot(this.Const.ItemSlot.Offhand) == null && !items.hasBlockedSlot(this.Const.ItemSlot.Offhand)))
		{
			ret.push({
				icon = "ui/tooltips/positive.png",
				text = "Oath of Wrath"
			});
		}
	}

	if (this.m.IsTooCloseShown && this.m.HitChanceBonus < 0)
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = textmodifier(-this.m.HitChanceBonus, "red") + "Too close"
		});
	}
	else if (this.m.HitChanceBonus < 0)
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
				text = textmodifier(this.m.HitChanceBonus, "red") + this.getName()
		});
	}

	if (_targetTile.Level > myTile.Level)
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = textmodifier(-this.Const.Combat.LevelDifferenceToHitMalus, "red") + "Height disadvantage"
		});
	}

	if (myTile.IsBadTerrain && !this.m.IsRanged)
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = textmodifier(this.Math.ceil(user.getCurrentProperties().getMeleeSkill() / 0.75 * (1 - 0.75)), "red") + "On bad terrain"
		});
	}

	local shield;
	local bonus;
	local shieldBonus;

	if (this.m.IsShieldRelevant)
	{
		if (_targetTile.IsOccupiedByActor && targetEntity.isArmedWithShield())
		{
			shield = targetEntity.getItems().getItemAtSlot(this.Const.ItemSlot.Offhand);
			shieldBonus = (this.m.IsRanged ? shield.getRangedDefense() : shield.getMeleeDefense()) * (targetEntity.getCurrentProperties().IsSpecializedInShields ? 1.25 : 1.0);
			ret.push({
				icon = "ui/tooltips/negative.png",
				text = textmodifier(this.Math.floor(shieldBonus), "red") + "Armed with shield"
			});
		}
	}

	if (_targetTile.IsOccupiedByActor && myTile.getDistanceTo(_targetTile) <= 1 && targetEntity.getSkills().hasSkill("effects.riposte"))
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = "Riposte"
		});
	}

	if (this.m.IsRanged && myTile.getDistanceTo(_targetTile) > 1)
	{
		if (_targetTile.IsOccupiedByActor)
		{
			local distanceToTarget = _targetTile.getDistanceTo(user.getTile());
			local hitfalloff = -1 * (distanceToTarget - 1) * properties.HitChanceAdditionalWithEachTile * properties.HitChanceWithEachTileMult;
			ret.push({
				icon = "ui/tooltips/negative.png",
				text = textmodifier(hitfalloff, "red") + "Distance of " + distanceToTarget
			});
		}

		if (this.m.IsUsingHitchance)
		{
			local blockedTiles = this.Const.Tactical.Common.getBlockedTiles(myTile, _targetTile, user.getFaction(), true);
			local blockChance = this.Const.Combat.RangedAttackBlockedChance * properties.RangedAttackBlockedChanceMult;
			local toHit = this.Math.ceil(this.getHitchance(targetEntity) / (1.0 - blockChance) - this.getHitchance(targetEntity));

			if (blockedTiles.len() != 0)
			{
				ret.push({
					icon = "ui/tooltips/negative.png",
					text = textmodifier(toHit, "red") + "Line of fire blocked"
				});
			}
		}
	}

	if (this.m.IsAttack && _targetTile.IsOccupiedByActor && targetEntity.getFlags().has("skeleton"))
	{
		local DamageReceivedRegularMult = 1;

		if (this.getID() == "actives.aimed_shot" || this.getID() == "actives.quick_shot")
		{
			DamageReceivedRegularMult = DamageReceivedRegularMult * 0.1;
		}
		else if (this.getID() == "actives.shoot_bolt" || this.getID() == "actives.shoot_stake" || this.getID() == "actives.sling_stone")
		{
			DamageReceivedRegularMult = DamageReceivedRegularMult * 0.33;
		}
		else if (this.getID() == "actives.throw_javelin")
		{
			DamageReceivedRegularMult = DamageReceivedRegularMult * 0.25;
		}
		else if (this.getID() == "actives.puncture" || this.getID() == "actives.thrust" || this.getID() == "actives.stab" || this.getID() == "actives.impale" || this.getID() == "actives.rupture" || this.getID() == "actives.prong" || this.getID() == "actives.lunge")
		{
			DamageReceivedRegularMult = DamageReceivedRegularMult * 0.5;
		}

		if (this.m.IsRanged)
		{
			ret.push({
				icon = "ui/tooltips/negative.png",
				text = textmodifier(100 * (1 - DamageReceivedRegularMult), "red") + "Resistance against ranged weapons"
			});
		}
		else if (this.m.ID == "actives.puncture" || this.m.ID == "actives.thrust" || this.m.ID == "actives.stab" || this.m.ID == "actives.deathblow" || this.m.ID == "actives.impale" || this.m.ID == "actives.rupture" || this.m.ID == "actives.prong" || this.m.ID == "actives.lunge")
		{
			ret.push({
				icon = "ui/tooltips/negative.png",
				text = textmodifier(100 * (1 - DamageReceivedRegularMult), "red") + "Resistance against piercing attacks"
			});
		}
	}

	if (!this.m.IsRanged && targetEntity != null && targetEntity.getSurroundedCount() != 0 && targetEntity.getCurrentProperties().IsImmuneToSurrounding)
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = "Immune to being surrounded"
		});
	}

	if (_targetTile.IsOccupiedByActor && targetEntity.getCurrentProperties().IsImmuneToStun && (this.m.ID == "actives.knock_out" || this.m.ID == "actives.knock_over" || this.m.ID == "actives.strike_down"))
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = "Immune to stun"
		});
	}

	if (_targetTile.IsOccupiedByActor && targetEntity.getCurrentProperties().IsImmuneToRoot && this.m.ID == "actives.throw_net")
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = "Immune to being rooted"
		});
	}

	if (_targetTile.IsOccupiedByActor && (targetEntity.getCurrentProperties().IsImmuneToDisarm || targetEntity.getItems().getItemAtSlot(this.Const.ItemSlot.Mainhand) == null) && this.m.ID == "actives.disarm")
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = "Immune to being disarmed"
		});
	}

	if (_targetTile.IsOccupiedByActor && targetEntity.getCurrentProperties().IsImmuneToKnockBackAndGrab && (this.m.ID == "actives.knock_back" || this.m.ID == "actives.hook" || this.m.ID == "actives.repel"))
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = "Immune to being knocked back or hooked"
		});
	}

	if (this.m.IsRanged && user.getCurrentProperties().IsAffectedByNight && user.getSkills().hasSkill("special.night"))
	{
		ret.push({
			icon = "ui/tooltips/negative.png",
			text = textmodifier(this.Math.ceil(user.getCurrentProperties().getRangedSkill() / 0.7 * (1 - 0.7)), "red") + "Nighttime"
		});
	}

	return ret;
};

::mods_queue("mod_better_hit_information", "!Xmod_legends", function()
{
	::mods_hookClass("skills/skill", function ( o )
	{
		::mods_addMember(o, "skill", "getHitFactors", getHitFactors);
	});
});
