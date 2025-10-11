::mods_registerCSS("mod_detailed_status_effects.css");

::mods_registerMod("mod_detailed_status_effects", 1.9, "Detailed Status Effects");

::mods_queue("mod_detailed_status_effects", ">mod_legends", function() {

	::mods_hookNewObject("states/tactical_state", function ( o )
	{
		local handleKey = o.helper_handleContextualKeyInput;
		o.helper_handleContextualKeyInput = function ( key )
		{
			local handled = handleKey(key);
			
			//::logInfo("Key pressed, getKey = " + key.getKey() + ", getState = " + key.getState() + ", modifier = " + key.getModifier());

			local KEY_CODES = {
				SPECIAL = 75,       // F5 key, toggles special status effects
				TERRAIN = 76,       // F6 key, toggles terrain effects
				INJURY = 77,        // F7 key, toggles injury status
				SEMI_INJURY = 78,   // F8 key, toggles semi-injury status
				DRUG_EFFECT = 79,   // F9 key, toggles drug effects
				PERK = 80,          // F10 key, toggles perks
				STATUS_EFFECT = 81  // F11 key, toggles other status effects
			}

			local canToggle = !handled
				&& key.getState() == 0
				&& key.getModifier() != 1
				&& !this.isInCharacterScreen()
				&& !this.isInLoadingScreen()
				&& !this.isBattleEnded();

			if (canToggle)
			{
				switch(key.getKey())
				{
					case KEY_CODES.SPECIAL:
						this.Show.Special = !this.Show.Special;
						handled = true;
						break;
					case KEY_CODES.TERRAIN:
						this.Show.Terrain = !this.Show.Terrain;
						handled = true;
						break;
					case KEY_CODES.INJURY:
						this.Show.Injury = !this.Show.Injury;
						handled = true;
						break;
					case KEY_CODES.SEMI_INJURY:
						this.Show.SemiInjury = !this.Show.SemiInjury;
						handled = true;
						break;
					case KEY_CODES.DRUG_EFFECT:
						this.Show.DrugEffect = !this.Show.DrugEffect;
						handled = true;
						break;
					case KEY_CODES.PERK:
						this.Show.Perk = !this.Show.Perk;
						handled = true;
						break;
					case KEY_CODES.STATUS_EFFECT:
						this.Show.StatusEffect = !this.Show.StatusEffect;
						handled = true;
						break;
					default:
						break;
				}
			}

			return handled;
		};
	});
	local getTooltip = function ( _targetedWithSkill = null )
	{
		if (!this.isPlacedOnMap() || !this.isAlive() || this.isDying())
		{
			return [];
		}

		if (!this.isDiscovered())
		{
			local tooltip = [
				{
					id = 1,
					type = "title",
					text = "Hidden Opponent"
				}
			];
			return tooltip;
		}

		local tooltip = [
			{
				id = 1,
				type = "title",
				text = this.getName(),
				icon = this.getLevelImagePath()
			}
		];

		if (this.isHiddenToPlayer())
		{
			tooltip.push({
				id = 3,
				type = "headerText",
				icon = "ui/tooltips/warning.png",
				text = "[color=" + this.Const.UI.Color.NegativeValue + "]Not currently in sight[/color]"
			});
		}
		else
		{
			if (_targetedWithSkill != null && this.isKindOf(_targetedWithSkill, "skill"))
			{
				local tile = this.getTile();

				if (tile.IsVisibleForEntity && _targetedWithSkill.isUsableOn(tile))
				{
					local hitchance = _targetedWithSkill.getHitchance(this);
					tooltip.push({
						id = 3,
						type = "headerText",
						icon = "ui/icons/hitchance.png",
						children = _targetedWithSkill.getHitFactors(tile),
						text = "[color=" + this.Const.UI.Color.PositiveValue + "]" + hitchance + "%[/color] chance to hit"
					});
				}
			}

			if (this.m.IsActingEachTurn)
			{
				local turnsToGo = this.Tactical.TurnSequenceBar.getTurnsUntilActive(this.getID());

				if (this.Tactical.TurnSequenceBar.getActiveEntity() == this)
				{
					tooltip.push({
						id = 4,
						type = "text",
						icon = "ui/icons/initiative.png",
						text = "Acting right now!"
					});
				}
				else if (this.m.IsTurnDone || turnsToGo == null)
				{
					tooltip.push({
						id = 4,
						type = "text",
						icon = "ui/icons/initiative.png",
						text = "Turn done"
					});
				}
				else
				{
					tooltip.push({
						id = 4,
						type = "text",
						icon = "ui/icons/initiative.png",
						text = "Acts in " + turnsToGo + (turnsToGo > 1 ? " turns" : " turn")
					});
				}
			}

			tooltip.push({
				id = 5,
				type = "progressbar",
				icon = "ui/icons/armor_head.png",
				value = this.getArmor(this.Const.BodyPart.Head),
				valueMax = this.getArmorMax(this.Const.BodyPart.Head),
				text = this.Const.ArmorStateName[this.getArmorState(this.Const.BodyPart.Head)],
				style = "armor-head-slim"
			});
			tooltip.push({
				id = 6,
				type = "progressbar",
				icon = "ui/icons/armor_body.png",
				value = this.getArmor(this.Const.BodyPart.Body),
				valueMax = this.getArmorMax(this.Const.BodyPart.Body),
				text = this.Const.ArmorStateName[this.getArmorState(this.Const.BodyPart.Body)],
				style = "armor-body-slim"
			});
			tooltip.push({
				id = 7,
				type = "progressbar",
				icon = "ui/icons/health.png",
				value = this.getHitpoints() >= 0 ? this.getHitpoints() : 0,
				valueMax = this.getHitpointsMax(),
				text = this.Const.HitpointsStateName[this.getHitpointsState()],
				style = "hitpoints-slim"
			});
			tooltip.push({
				id = 8,
				type = "progressbar",
				icon = "ui/icons/morale.png",
				value = this.getMoraleState(),
				valueMax = this.Const.MoraleState.COUNT - 1,
				text = this.Const.MoraleStateName[this.getMoraleState()],
				style = "morale-slim"
			});
			tooltip.push({
				id = 9,
				type = "progressbar",
				icon = "ui/icons/fatigue.png",
				value = this.getFatigue(),
				valueMax = this.getFatigueMax(),
				text = this.Const.FatigueStateName[this.getFatigueState()],
				style = "fatigue-slim"
			});
			local result = [];
			local statusEffects = this.getSkills().query(this.Const.SkillType.StatusEffect | this.Const.SkillType.TemporaryInjury, false, true);

			foreach( i, statusEffect in statusEffects )
			{
				tooltip.push({
					id = 100 + i,
					type = "text",
					icon = statusEffect.getIcon(),
					text = statusEffect.getName()
				});
				local fulltooltip = statusEffect.getTooltip();
				local special = statusEffect.isType(this.Const.SkillType.Special);
				local terrain = statusEffect.isType(this.Const.SkillType.Terrain);
				local injury = statusEffect.isType(this.Const.SkillType.TemporaryInjury);
				local semiinjury = statusEffect.isType(this.Const.SkillType.SemiInjury);
				local drugeffect = statusEffect.isType(this.Const.SkillType.DrugEffect);
				local perk = statusEffect.isType(this.Const.SkillType.Perk);
				local statuseffect = statusEffect.isType(this.Const.SkillType.StatusEffect);

				if (this.Show.Special && special)
				{
					for( i = 2; i < fulltooltip.len(); i++ )
					{
						tooltip.push({
							id = 100 + i - 2,
							type = "text",
							icon = fulltooltip[i].icon,
							text = fulltooltip[i].text
						});
					}
				}

				if (this.Show.Terrain && terrain)
				{
					for( i = 2; i < fulltooltip.len(); i++ )
					{
						tooltip.push({
							id = 100 + i - 2,
							type = "text",
							icon = fulltooltip[i].icon,
							text = fulltooltip[i].text
						});
					}
				}

				if (this.Show.Injury && injury)
				{
					for( i = 2; i < fulltooltip.len(); i++ )
					{
						tooltip.push({
							id = 100 + i - 2,
							type = "text",
							icon = fulltooltip[i].icon,
							text = fulltooltip[i].text
						});
					}
				}

				if (this.Show.SemiInjury && semiinjury)
				{
					for( i = 2; i < fulltooltip.len(); i++ )
					{
						tooltip.push({
							id = 100 + i - 2,
							type = "text",
							icon = fulltooltip[i].icon,
							text = fulltooltip[i].text
						});
					}
				}

				if (this.Show.DrugEffect && drugeffect)
				{
					for( i = 2; i < fulltooltip.len(); i++ )
					{
						tooltip.push({
							id = 100 + i - 2,
							type = "text",
							icon = fulltooltip[i].icon,
							text = fulltooltip[i].text
						});
					}
				}

				if (this.Show.Perk && perk)
				{
					for( i = 2; i < fulltooltip.len(); i++ )
					{
						tooltip.push({
							id = 100 + i - 2,
							type = "text",
							icon = fulltooltip[i].icon,
							text = fulltooltip[i].text
						});
					}
				}

				if (this.Show.StatusEffect && statuseffect && !(special || terrain || injury || semiinjury || drugeffect || perk))
				{
					for( i = 2; i < fulltooltip.len(); i++ )
					{
						tooltip.push({
							id = 100 + i - 2,
							type = "text",
							icon = fulltooltip[i].icon,
							text = fulltooltip[i].text
						});
					}
				}
			}
		}

		return tooltip;
	};
	::mods_hookClass("entity/tactical/actor", function ( o )
	{
		::mods_override(o, "getTooltip", getTooltip);
	});
	local getTooltip2 = function ( _targetedWithSkill = null )
	{
		if (!this.isPlacedOnMap() || !this.isAlive() || this.isDying())
		{
			return [];
		}

		local turnsToGo = this.Tactical.TurnSequenceBar.getTurnsUntilActive(this.getID());
		local tooltip = [
			{
				id = 1,
				type = "title",
				text = this.getName(),
				icon = "ui/tooltips/height_" + this.getTile().Level + ".png"
			}
		];

		if (!this.isPlayerControlled() && _targetedWithSkill != null && this.isKindOf(_targetedWithSkill, "skill"))
		{
			local tile = this.getTile();

			if (tile.IsVisibleForEntity && _targetedWithSkill.isUsableOn(this.getTile()))
			{
				tooltip.push({
					id = 3,
					type = "headerText",
					icon = "ui/icons/hitchance.png",
					text = "[color=" + this.Const.UI.Color.PositiveValue + "]" + _targetedWithSkill.getHitchance(this) + "%[/color] chance to hit",
					children = _targetedWithSkill.getHitFactors(tile)
				});
			}
		}

		tooltip.extend([
			{
				id = 2,
				type = "text",
				icon = "ui/icons/initiative.png",
				text = this.Tactical.TurnSequenceBar.getActiveEntity() == this ? "Acting right now!" : this.m.IsTurnDone || turnsToGo == null ? "Turn done" : "Acts in " + turnsToGo + (turnsToGo > 1 ? " turns" : " turn")
			},
			{
				id = 3,
				type = "progressbar",
				icon = "ui/icons/armor_head.png",
				value = this.getArmor(this.Const.BodyPart.Head),
				valueMax = this.getArmorMax(this.Const.BodyPart.Head),
				text = "" + this.getArmor(this.Const.BodyPart.Head) + " / " + this.getArmorMax(this.Const.BodyPart.Head) + "",
				style = "armor-head-slim"
			},
			{
				id = 4,
				type = "progressbar",
				icon = "ui/icons/armor_body.png",
				value = this.getArmor(this.Const.BodyPart.Body),
				valueMax = this.getArmorMax(this.Const.BodyPart.Body),
				text = "" + this.getArmor(this.Const.BodyPart.Body) + " / " + this.getArmorMax(this.Const.BodyPart.Body) + "",
				style = "armor-body-slim"
			},
			{
				id = 5,
				type = "progressbar",
				icon = "ui/icons/health.png",
				value = this.getHitpoints(),
				valueMax = this.getHitpointsMax(),
				text = "" + this.getHitpoints() + " / " + this.getHitpointsMax() + "",
				style = "hitpoints-slim"
			},
			{
				id = 6,
				type = "progressbar",
				icon = "ui/icons/morale.png",
				value = this.getMoraleState(),
				valueMax = this.Const.MoraleState.COUNT - 1,
				text = this.Const.MoraleStateName[this.getMoraleState()],
				style = "morale-slim"
			},
			{
				id = 7,
				type = "progressbar",
				icon = "ui/icons/fatigue.png",
				value = this.getFatigue(),
				valueMax = this.getFatigueMax(),
				text = "" + this.getFatigue() + " / " + this.getFatigueMax() + "",
				style = "fatigue-slim"
			}
		]);
		local result = [];
		local statusEffects = this.getSkills().query(this.Const.SkillType.StatusEffect | this.Const.SkillType.TemporaryInjury, false, true);

		foreach( i, statusEffect in statusEffects )
		{
			tooltip.push({
				id = 100 + i,
				type = "text",
				icon = statusEffect.getIcon(),
				text = statusEffect.getName()
			});
			local fulltooltip = statusEffect.getTooltip();
			local special = statusEffect.isType(this.Const.SkillType.Special);
			local terrain = statusEffect.isType(this.Const.SkillType.Terrain);
			local injury = statusEffect.isType(this.Const.SkillType.TemporaryInjury);
			local semiinjury = statusEffect.isType(this.Const.SkillType.SemiInjury);
			local drugeffect = statusEffect.isType(this.Const.SkillType.DrugEffect);
			local perk = statusEffect.isType(this.Const.SkillType.Perk);
			local statuseffect = statusEffect.isType(this.Const.SkillType.StatusEffect);

			if (this.Show.Special && special)
			{
				for( i = 2; i < fulltooltip.len(); i++ )
				{
					tooltip.push({
						id = 100 + i - 2,
						type = "text",
						icon = fulltooltip[i].icon,
						text = fulltooltip[i].text
					});
				}
			}

			if (this.Show.Terrain && terrain)
			{
				for( i = 2; i < fulltooltip.len(); i++ )
				{
					tooltip.push({
						id = 100 + i - 2,
						type = "text",
						icon = fulltooltip[i].icon,
						text = fulltooltip[i].text
					});
				}
			}

			if (this.Show.Injury && injury)
			{
				for( i = 2; i < fulltooltip.len(); i++ )
				{
					tooltip.push({
						id = 100 + i - 2,
						type = "text",
						icon = fulltooltip[i].icon,
						text = fulltooltip[i].text
					});
				}
			}

			if (this.Show.SemiInjury && semiinjury)
			{
				for( i = 2; i < fulltooltip.len(); i++ )
				{
					tooltip.push({
						id = 100 + i - 2,
						type = "text",
						icon = fulltooltip[i].icon,
						text = fulltooltip[i].text
					});
				}
			}

			if (this.Show.DrugEffect && drugeffect)
			{
				for( i = 2; i < fulltooltip.len(); i++ )
				{
					tooltip.push({
						id = 100 + i - 2,
						type = "text",
						icon = fulltooltip[i].icon,
						text = fulltooltip[i].text
					});
				}
			}

			if (this.Show.Perk && perk)
			{
				for( i = 2; i < fulltooltip.len(); i++ )
				{
					tooltip.push({
						id = 100 + i - 2,
						type = "text",
						icon = fulltooltip[i].icon,
						text = fulltooltip[i].text
					});
				}
			}

			if (this.Show.StatusEffect && statuseffect && !(special || terrain || injury || semiinjury || drugeffect || perk))
			{
				for( i = 2; i < fulltooltip.len(); i++ )
				{
					tooltip.push({
						id = 100 + i - 2,
						type = "text",
						icon = fulltooltip[i].icon,
						text = fulltooltip[i].text
					});
				}
			}
		}

		return tooltip;
	};
	::mods_hookClass("entity/tactical/player", function ( o )
	{
		::mods_override(o, "getTooltip", getTooltip2);
	});
	::mods_hookNewObject("ui/screens/tooltip/tooltip_events", function ( o )
	{
		local queryTooltipData = o.general_queryUIElementTooltipData;
		o.general_queryUIElementTooltipData = function ( entityId, elementId, elementOwner )
		{
			local tooltip = queryTooltipData(entityId, elementId, elementOwner);
			
			local toggleStateText = function (toggleName)
			{
				if (this.Show && this.Show[toggleName])
					return "[color=green]ON[/color]";
				else
					return "[color=red]OFF[/color]";
			};
			

			if (elementId == "tactical-screen.topbar.options-bar-module.QuitButton")
			{
				return [
					{
						id = 1,
						type = "title",
						text = "Open Menu (Esc)"
					},
					{
						id = 2,
						type = "description",
						text = "Open menu to adjust game options."
					},
					{
						id = 3,
						type = "description",
						text = ""
					},
					{
						id = 4,
						type = "description",
						text = "F5 [" + toggleStateText("Special") + "] - Toggle special status (night effect, morale)"
					},
					{
						id = 5,
						type = "description",
						text = "F6 [" + toggleStateText("Terrain") + "] - Toggle terrain status (swamp)"
					},
					{
						id = 6,
						type = "description",
						text = "F7 [" + toggleStateText("Injury") + "] - Toggle injuries status (temporary injuries)"
					},
					{
						id = 7,
						type = "description",
						text = "F8 [" + toggleStateText("SemiInjury") + "] - Toggle semi-injury status (drunk, exhausted, hangover)"
					},
					{
						id = 8,
						type = "description",
						text = "F9 [" + toggleStateText("DrugEffect") + "] - Toggle drug effects status (berserker mushrooms, potions)"
					},
					{
						id = 9,
						type = "description",
						text = "F10 [" + toggleStateText("Perk") + "] - Toggle perk status (nimble, battleforged)"
					},
					{
						id = 10,
						type = "description",
						text = "F11 [" + toggleStateText("StatusEffect") + "] - Toggle other status (e.g. net, acid damage, lone wolf, killing frenzy, overwhelmed, indomitable, dodge, battle standard resolve, shieldwall)"
					}
				];
			}

			if (tooltip != null)
			{
				return tooltip;
			}

			return null;
		};
	});
})
