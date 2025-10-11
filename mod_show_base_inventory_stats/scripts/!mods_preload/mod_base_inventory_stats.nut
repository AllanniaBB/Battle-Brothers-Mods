::mods_registerMod("mod_base_inventory_stats", 1.4, "Show Base Inventory Stats");

::mods_queue("mod_base_inventory_stats", ">mod_legends", function() {

    ::mods_hookNewObjectOnce("ui/global/data_helper", function(o) {
        //::logInfo("[mod_base_inventory_stats] Hooking data_helper");

        local oldConvert = o.addStatsToUIData;

        o.addStatsToUIData = function (_entity, _target)
        {
            if (oldConvert != null) oldConvert(_entity, _target);

            _target.fatigueBase <- _entity.getBaseProperties().Stamina;
            _target.hitpointsBase <- _entity.getBaseProperties().Hitpoints;
            _target.braveryBase <- _entity.getBaseProperties().Bravery;
            _target.initiativeBase <- _entity.getBaseProperties().Initiative;
            _target.meleeSkillBase <- _entity.getBaseProperties().MeleeSkill;
            _target.rangedSkillBase <- _entity.getBaseProperties().RangedSkill;
            _target.meleeDefenseBase <- _entity.getBaseProperties().MeleeDefense;
            _target.rangedDefenseBase <- _entity.getBaseProperties().RangedDefense;
        };
    });
});

::mods_queue("mod_base_inventory_stats", null, function() {

    ::mods_registerJS("mod_base_inventory_stats/mod_base_stats_patch.js");
});