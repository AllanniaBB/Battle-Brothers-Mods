::mods_hookExactClass("events/events/special/desertion_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		
		foreach (s in this.m.Screens) {
			if (s.ID == "A") {
				s.Options = [
				{
					Text = "{I can hardly force any of them to remain with the company... | Bad news, indeed. | A momentary setback. | I can not let something like this happen again. | This will impact the bottom line.}",
					function getResult( _event )
					{				
						if (this.World.Assets.getEconomicDifficulty() != this.Const.Difficulty.Hard)
						{
							_event.m.Deserter.getItems().transferToStash(this.World.Assets.getStash());
						}

						_event.m.Deserter.getSkills().onDeath(this.Const.FatalityType.None);
						local departed = _event.m.Deserter;
						::BetterObituary.addFallen(departed, "Deserted the company");
						this.World.getPlayerRoster().remove(_event.m.Deserter);
						_event.m.Deserter = null;
						_event.m.Other = null;
						return 0;
					}
				}];
			}
		}
	}
})

::mods_hookExactClass("events/events/crisis/undead_crusader_leaves_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		
		foreach (s in this.m.Screens) {
			if (s.ID == "A") {
				s.Options = [
				{
					Text = "Farewell!",
					function getResult( _event )
					{
						this.Characters.push(_event.m.Dude.getImagePath());
						this.List.push({
							id = 13,
							icon = "ui/icons/kills.png",
							text = _event.m.Dude.getName() + " leaves the " + this.World.Assets.getName()
						});
						local departed = _event.m.Dude;
						::BetterObituary.addFallen(departed, "Left after undead crisis averted");
					}
				}];
			}
		}
	}
})

::mods_hookExactClass("events/events/crisis/greenskins_slayer_leaves_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();

		foreach (s in this.m.Screens) {
			if (s.ID == "A") {
				s.Options = [
				{
					Text = "Farewell!",
					function getResult(_event) 
					{
						this.Characters.push(_event.m.Dude.getImagePath());
						this.List.push({
							id = 13,
							icon = "ui/icons/kills.png",
							text = _event.m.Dude.getName() + " leaves the " + this.World.Assets.getName()
						});
						local departed = _event.m.Dude;
						::BetterObituary.addFallen(departed, "Left after undead crisis averted");
					}
				}];
			}
		}
	}
});


/*
::mods_hookExactClass("events/events/killer_vs_others_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();

		foreach (s in this.m.Screens) {
			if (s.ID == "C") {
				s.start <- function ( _event ) {
					this.Characters.push(_event.m.OtherGuy1.getImagePath());
					this.List.push({
						id = 13,
						icon = "ui/icons/kills.png",
						text = _event.m.Killer.getName() + " has died"
					});
					_event.m.Killer.getItems().transferToStash(this.World.Assets.getStash());
					_event.m.Killer.getSkills().onDeath(this.Const.FatalityType.None);
					local departed = _event.m.Killer;
					::BetterObituary.addFallen(departed, "Hanged for attempted murder");
					this.World.getPlayerRoster().remove(_event.m.Killer);
					_event.m.OtherGuy1.improveMood(2.0, "Got satisfaction with " + _event.m.Killer.getNameOnly() + "\'s hanging");

					if (_event.m.OtherGuy1.getMoodState() >= this.Const.MoodState.Neutral) {
						this.List.push({
							id = 10,
							icon = this.Const.MoodStateIcon[_event.m.OtherGuy1.getMoodState()],
							text = _event.m.OtherGuy1.getName() + this.Const.MoodStateEvent[_event.m.OtherGuy1.getMoodState()]
						});
					}
				}
			}
			if (s.ID == "E") {
				s.start <- function ( _event ) {
					this.Characters.push(_event.m.OtherGuy1.getImagePath());
					local departed = _event.m.Killer;
					::BetterObituary.addFallen(departed, "Murdered by his fellow brothers");
					this.List.push({
						id = 13,
						icon = "ui/icons/kills.png",
						text = _event.m.Killer.getName() + " has died"
					});
					_event.m.Killer.getItems().transferToStash(this.World.Assets.getStash());
					_event.m.Killer.getSkills().onDeath(this.Const.FatalityType.None);
					this.World.getPlayerRoster().remove(_event.m.Killer);
					local brothers = this.World.getPlayerRoster().getAll();

					foreach( bro in brothers )
					{
						if (bro.getID() == _event.m.OtherGuy1.getID())
						{
							continue;
						}

						if (this.Math.rand(1, 100) <= 33)
						{
							continue;
						}

						bro.worsenMood(1.0, "Concerned about lack of discipline");

						if (bro.getMoodState() < this.Const.MoodState.Neutral)
						{
							this.List.push({
								id = 10,
								icon = this.Const.MoodStateIcon[bro.getMoodState()],
								text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
							});
						}
					}
				}
			}
		}
	}
});
*/

::mods_hookExactClass("events/events/killer_vs_others_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();

		foreach (s in this.m.Screens) 
		{
			if (s.ID == "C") 
			{
				local originalStart = s.start;
				s.start <- function (_event) 
				{
					local departed = _event.m.Killer;
					::BetterObituary.addFallen(departed, "Hanged for attempted murder");
					originalStart(_event);
				}
			}

			if (s.ID == "E") 
			{
				local originalStart = s.start;
				s.start <- function (_event) 
				{
					local departed = _event.m.Killer;
					::BetterObituary.addFallen(departed, "Murdered by his fellow brothers");
					originalStart(_event);
				}
			}
		}
	}
});


/*
::mods_hookExactClass("events/events/sellsword_gets_better_deal_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		
		foreach (s in this.m.Screens) {
			if (s.ID == "A") {
				s.Options[0] = {
					Text = "I see, time to part ways then.",
					function getResult( _event ) {
						_event.m.Sellsword.getSkills().onDeath(this.Const.FatalityType.None);
						local departed = _event.m.Sellsword;
						::BetterObituary.addFallen(departed, "Got a better paying offer");
						this.World.getPlayerRoster().remove(_event.m.Sellsword);
						return 0;
					}
				}
			}
			if (s.ID == "C") {
				s.start <- function (_event) {
					this.List.push({
						id = 13,
						icon = "ui/icons/kills.png",
						text = _event.m.Sellsword.getName() + " leaves the " + this.World.Assets.getName()
					});
					_event.m.Sellsword.getItems().transferToStash(this.World.Assets.getStash());
					_event.m.Sellsword.getSkills().onDeath(this.Const.FatalityType.None);
					local departed = _event.m.Sellsword;
					::BetterObituary.addFallen(departed, "Got a better paying offer");
					this.World.getPlayerRoster().remove(_event.m.Sellsword);
				}
			}
		}
	}
})
*/

::mods_hookExactClass("events/events/sellsword_gets_better_deal_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		
		foreach (s in this.m.Screens) {
			if (s.ID == "A") 
			{
				s.Options[0] = {
					Text = "I see, time to part ways then.",
					function getResult(_event) 
					{
						_event.m.Sellsword.getSkills().onDeath(this.Const.FatalityType.None);
						local departed = _event.m.Sellsword;
						::BetterObituary.addFallen(departed, "Got a better paying offer");
						this.World.getPlayerRoster().remove(_event.m.Sellsword);
						return 0;
					}
				};
			}
			
			if (s.ID == "C") {
				local originalStart = s.start;
				s.start <- function (_event) 
				{
					local departed = _event.m.Sellsword;
					::BetterObituary.addFallen(departed, "Got a better paying offer");
					originalStart(_event);
				}
			}
		}
	}
})


/*
::mods_hookExactClass("events/events/lawmen_after_criminal_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		
		foreach (s in this.m.Screens) {
			if (s.ID == "B") {
				s.start <- function (_event) 
				{
					this.Banner = _event.m.NobleHouse.getUIBannerSmall();
					this.Characters.push(_event.m.Criminal.getImagePath());
					this.List.push({
						id = 13,
						icon = "ui/icons/asset_brothers.png",
						text = _event.m.Criminal.getName() + " has left the company"
					});
					_event.m.Criminal.getItems().transferToStash(this.World.Assets.getStash());
					_event.m.Criminal.getSkills().onDeath(this.Const.FatalityType.None);
					local departed = _event.m.Criminal;
					::BetterObituary.addFallen(departed, "Handed over to authorities");
					this.World.getPlayerRoster().remove(_event.m.Criminal);
					this.World.Assets.addMoney(100);
					this.List.push({
						id = 10,
						icon = "ui/icons/asset_money.png",
						text = "You gain [color=" + this.Const.UI.Color.PositiveEventValue + "]" + 100 + "[/color] Crowns"
					});
				}
			}
		}
	}
})
*/

::mods_hookExactClass("events/events/lawmen_after_criminal_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		foreach (s in this.m.Screens) 
		{
			if (s.ID == "B") 
			{
				local start = s.start;
				s.start <- function ( _event )
				{
					local departed = _event.m.Criminal;
					::BetterObituary.addFallen(departed, "Handed over to authorities");
					start(_event);
				}
			}
		}
	}
})

::mods_hookExactClass("events/events/hedgeknight_vs_hedgeknight_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		foreach (s in this.m.Screens) 
		{
			if (s.ID == "F") {
				s.start <- function ( _event ) {
					this.Characters.push(_event.m.HedgeKnight1.getImagePath());
					local departed = _event.m.HedgeKnight2;
					::BetterObituary.addFallen(departed, "Killed in a duel by " + _event.m.HedgeKnight1.getName());
					this.List.push({
						id = 13,
						icon = "ui/icons/kills.png",
						text = _event.m.HedgeKnight2.getName() + " has died"
					});
					_event.m.HedgeKnight2.getItems().transferToStash(this.World.Assets.getStash());
					_event.m.HedgeKnight2.getSkills().onDeath(this.Const.FatalityType.None);
					this.World.getPlayerRoster().remove(_event.m.HedgeKnight2);
					local injury = _event.m.HedgeKnight1.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.HedgeKnight1.getName() + " suffers " + injury.getNameOnly()
					});

					if (this.Math.rand(1, 2) == 1)
					{
						local v = this.Math.rand(1, 2);
						_event.m.HedgeKnight1.getBaseProperties().MeleeSkill += v;
						this.List.push({
							id = 16,
							icon = "ui/icons/melee_skill.png",
							text = _event.m.HedgeKnight1.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + v + "[/color] Melee Skill"
						});
					}
					else
					{
						local v = this.Math.rand(1, 2);
						_event.m.HedgeKnight1.getBaseProperties().MeleeDefense += v;
						this.List.push({
							id = 16,
							icon = "ui/icons/melee_defense.png",
							text = _event.m.HedgeKnight1.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + v + "[/color] Melee Defense"
						});
					}

					_event.m.HedgeKnight1.getSkills().update();
				}
			}
			if (s.ID == "G") {
				s.start <- function ( _event )
				{
					this.Characters.push(_event.m.HedgeKnight2.getImagePath());
					local departed = _event.m.HedgeKnight1;
					::BetterObituary.addFallen(departed,  "Killed in a duel by " + _event.m.HedgeKnight2.getName());
					this.List.push({
						id = 13,
						icon = "ui/icons/kills.png",
						text = _event.m.HedgeKnight1.getName() + " has died"
					});
					_event.m.HedgeKnight1.getItems().transferToStash(this.World.Assets.getStash());
					_event.m.HedgeKnight1.getSkills().onDeath(this.Const.FatalityType.None);
					this.World.getPlayerRoster().remove(_event.m.HedgeKnight1);
					local injury = _event.m.HedgeKnight2.addInjury(this.Const.Injury.Brawl);
					this.List.push({
						id = 10,
						icon = injury.getIcon(),
						text = _event.m.HedgeKnight2.getName() + " suffers " + injury.getNameOnly()
					});

					if (this.Math.rand(1, 2) == 1)
					{
						local v = this.Math.rand(1, 2);
						_event.m.HedgeKnight2.getBaseProperties().MeleeSkill += v;
						this.List.push({
							id = 16,
							icon = "ui/icons/melee_skill.png",
							text = _event.m.HedgeKnight2.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + v + "[/color] Melee Skill"
						});
					}
					else
					{
						local v = this.Math.rand(1, 2);
						_event.m.HedgeKnight2.getBaseProperties().MeleeDefense += v;
						this.List.push({
							id = 16,
							icon = "ui/icons/melee_defense.png",
							text = _event.m.HedgeKnight2.getName() + " gains [color=" + this.Const.UI.Color.PositiveEventValue + "]+" + v + "[/color] Melee Defense"
						});
					}

					_event.m.HedgeKnight2.getSkills().update();
				}
			}
		}
	}
})

::mods_hookExactClass("events/events/cultist_finale_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		foreach (s in this.m.Screens) {
			if (s.ID == "C") {
				s.start <- function ( _event ) {
					this.World.Assets.addMoralReputation(-10);
					this.Characters.push(_event.m.Sacrifice.getImagePath());
					local departed = _event.m.Sacrifice;
					::BetterObituary.addFallen(departed, "Sacrificed to Davkul");
					this.List.push({
						id = 13,
						icon = "ui/icons/kills.png",
						text = _event.m.Sacrifice.getName() + " has died"
					});
					_event.m.Sacrifice.getItems().transferToStash(this.World.Assets.getStash());
					_event.m.Sacrifice.getSkills().onDeath(this.Const.FatalityType.None);
					this.World.getPlayerRoster().remove(_event.m.Sacrifice);
					this.World.Assets.getStash().makeEmptySlots(1);
					local item = this.new("scripts/items/armor/legendary/armor_of_davkul");
					item.m.Description = "A grisly aspect of Davkul, an ancient power not from this world, and the last remnants of " + _event.m.Sacrifice.getName() + " from whose body it has been fashioned. It shall never break, but instead keep regrowing its scarred skin on the spot.";
					this.World.Assets.getStash().add(item);
					this.List.push({
						id = 10,
						icon = "ui/items/" + item.getIcon(),
						text = "You gain the " + item.getName()
					});
					local brothers = this.World.getPlayerRoster().getAll();

					foreach( bro in brothers )
					{
						if (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist")
						{
							bro.improveMood(2.0, "Appeased Davkul");

							if (bro.getMoodState() >= this.Const.MoodState.Neutral)
							{
								this.List.push({
									id = 10,
									icon = this.Const.MoodStateIcon[bro.getMoodState()],
									text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
								});
							}
						}
						else
						{
							bro.worsenMood(3.0, "Horrified by the death of " + _event.m.Sacrifice.getName());

							if (bro.getMoodState() < this.Const.MoodState.Neutral)
							{
								this.List.push({
									id = 10,
									icon = this.Const.MoodStateIcon[bro.getMoodState()],
									text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
								});
							}
						}
					}
				}
			}
		}
	}
})

::mods_hookExactClass("events/events/bastard_assassin_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		foreach (s in this.m.Screens) 
		{
			if (s.ID == "B") 
			{
				s.Options = [{
					Text = "Take care you bastard.",
					function getResult( _event )
					{
						this.World.getPlayerRoster().add(_event.m.Assassin);
						this.World.getTemporaryRoster().clear();
						_event.m.Assassin.onHired();
						_event.m.Bastard.getItems().transferToStash(this.World.Assets.getStash());
						_event.m.Bastard.getSkills().onDeath(this.Const.FatalityType.None);
						local departed = _event.m.Bastard;
						::BetterObituary.addFallen(_event.m.Bastard, "Left to claim their birthright");
						this.World.getPlayerRoster().remove(_event.m.Bastard);
						_event.m.Bastard = null;
						return 0;
					}
				}];
			}
		}
	}
})

::mods_hookExactClass("events/events/dlc4/wild_dog_sounds_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		
		foreach (s in this.m.Screens) 
		{
			if (s.ID == "F") {
				s.start <- function ( _event ) {
					this.Characters.push(_event.m.Expendable.getImagePath());
					local departed = _event.m.Expendable;
					::BetterObituary.addFallen(departed, "Went missing");
					this.List.push({
						id = 13,
						icon = "ui/icons/kills.png",
						text = _event.m.Expendable.getName() + " went missing"
					});
					_event.m.Expendable.getItems().transferToStash(this.World.Assets.getStash());
					_event.m.Expendable.getSkills().onDeath(this.Const.FatalityType.None);
					this.World.getPlayerRoster().remove(_event.m.Expendable);
				}
			}
		}
	}
})

::mods_hookExactClass("events/events/dlc4/cultist_origin_sacrifice_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();

		foreach (s in this.m.Screens) {
			if (s.ID == "B") {
				s.start <- function ( _event ) {
					this.Characters.push(_event.m.Sacrifice.getImagePath());
					local departed = _event.m.Sacrifice;
					::BetterObituary.addFallen(departed, "Sacrificed to Davkul");
					this.List.push({
						id = 13,
						icon = "ui/icons/kills.png",
						text = _event.m.Sacrifice.getName() + " has died"
					});
					_event.m.Sacrifice.getItems().transferToStash(this.World.Assets.getStash());
					this.World.getPlayerRoster().remove(_event.m.Sacrifice);
					local brothers = this.World.getPlayerRoster().getAll();
					local hasProphet = false;

					foreach( bro in brothers )
					{
						if (bro.getSkills().hasSkill("trait.cultist_prophet"))
						{
							hasProphet = true;
							break;
						}
					}

					foreach( bro in brothers )
					{
						if (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist")
						{
							bro.improveMood(2.0, "Appeased Davkul");

							if (bro.getMoodState() >= this.Const.MoodState.Neutral)
							{
								this.List.push({
									id = 10,
									icon = this.Const.MoodStateIcon[bro.getMoodState()],
									text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
								});
							}

							local skills = bro.getSkills();
							local skill;

							if (skills.hasSkill("trait.cultist_prophet"))
							{
								continue;
							}
							else if (skills.hasSkill("trait.cultist_chosen"))
							{
								if (hasProphet)
								{
									continue;
								}

								hasProphet = true;
								this.updateAchievement("VoiceOfDavkul", 1, 1);
								skills.removeByID("trait.cultist_chosen");
								skill = this.new("scripts/skills/actives/voice_of_davkul_skill");
								skills.add(skill);
								skill = this.new("scripts/skills/traits/cultist_prophet_trait");
								skills.add(skill);
							}
							else if (skills.hasSkill("trait.cultist_disciple"))
							{
								skills.removeByID("trait.cultist_disciple");
								skill = this.new("scripts/skills/traits/cultist_chosen_trait");
								skills.add(skill);
							}
							else if (skills.hasSkill("trait.cultist_acolyte"))
							{
								skills.removeByID("trait.cultist_acolyte");
								skill = this.new("scripts/skills/traits/cultist_disciple_trait");
								skills.add(skill);
							}
							else if (skills.hasSkill("trait.cultist_zealot"))
							{
								skills.removeByID("trait.cultist_zealot");
								skill = this.new("scripts/skills/traits/cultist_acolyte_trait");
								skills.add(skill);
							}
							else if (skills.hasSkill("trait.cultist_fanatic"))
							{
								skills.removeByID("trait.cultist_fanatic");
								skill = this.new("scripts/skills/traits/cultist_zealot_trait");
								skills.add(skill);
							}
							else
							{
								skill = this.new("scripts/skills/traits/cultist_fanatic_trait");
								skills.add(skill);
							}

							if (skill != null)
							{
								this.List.push({
									id = 10,
									icon = skill.getIcon(),
									text = bro.getName() + " is now " + this.Const.Strings.getArticle(skill.getName()) + skill.getName()
								});
							}
						}
						else if (!bro.getSkills().hasSkill("trait.mad"))
						{
							bro.worsenMood(4.0, "Horrified by the sacrifice of " + _event.m.Sacrifice.getName());

							if (bro.getMoodState() < this.Const.MoodState.Neutral)
							{
								this.List.push({
									id = 10,
									icon = this.Const.MoodStateIcon[bro.getMoodState()],
									text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
								});
							}
						}
					}
				}
			}
		}
	}
})

::mods_hookExactClass("events/events/dlc4/cultist_origin_finale_event", function(o) {
	local create = o.create;
	o.create = function() {
		create();
		
		foreach (s in this.m.Screens) {
			if (s.ID == "C") {
				s.start <- function ( _event ) {
					this.Characters.push(_event.m.Sacrifice.getImagePath());
					local departed = _event.m.Sacrifice;
					::BetterObituary.addFallen(departed, "Sacrificed to Davkul");
					this.List.push({
						id = 13,
						icon = "ui/icons/kills.png",
						text = _event.m.Sacrifice.getName() + " has died"
					});
					_event.m.Sacrifice.getItems().transferToStash(this.World.Assets.getStash());
					this.World.getPlayerRoster().remove(_event.m.Sacrifice);
					this.World.Assets.getStash().makeEmptySlots(1);
					local item = this.new("scripts/items/armor/legendary/armor_of_davkul");
					item.m.Description = "A grisly aspect of Davkul, an ancient power not from this world, and the last remnants of " + _event.m.Sacrifice.getName() + " from whose body it has been fashioned. It shall never break, but instead keep regrowing its scarred skin on the spot.";
					this.World.Assets.getStash().add(item);
					this.List.push({
						id = 10,
						icon = "ui/items/" + item.getIcon(),
						text = "You gain the " + item.getName()
					});
					local brothers = this.World.getPlayerRoster().getAll();

					foreach( bro in brothers )
					{
						if (bro.getBackground().getID() == "background.cultist" || bro.getBackground().getID() == "background.converted_cultist")
						{
							bro.improveMood(2.0, "Appeased Davkul");

							if (bro.getMoodState() >= this.Const.MoodState.Neutral)
							{
								this.List.push({
									id = 10,
									icon = this.Const.MoodStateIcon[bro.getMoodState()],
									text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
								});
							}
						}
						else
						{
							bro.worsenMood(3.0, "Horrified by the death of " + _event.m.Sacrifice.getName());

							if (bro.getMoodState() < this.Const.MoodState.Neutral)
							{
								this.List.push({
									id = 10,
									icon = this.Const.MoodStateIcon[bro.getMoodState()],
									text = bro.getName() + this.Const.MoodStateEvent[bro.getMoodState()]
								});
							}
						}
					}
				}
			}
		}
	}

})
