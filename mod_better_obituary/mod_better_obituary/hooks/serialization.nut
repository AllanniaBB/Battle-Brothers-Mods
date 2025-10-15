::mods_hookNewObject("statistics/statistics_manager", function(o) 
{
    local onSerialize = o.onSerialize;
    o.onSerialize = function (_out) 
	{
        local extendedFallenData = this.m.Fallen.map(function(_fallen) 
		{
            return {
                Level = "level" in _fallen ? _fallen.level : 0,
                Traits = "traits" in _fallen ? _fallen.traits : [],
                Perks = "perks" in _fallen ? _fallen.perks : [],
                Injures = "perminjuries" in _fallen ? _fallen.perminjuries : [],
                Stats = "stats" in _fallen ? _fallen.stats : [],
                Talents = "talents" in _fallen ? _fallen.talents : []
            };
        });
	
        ::BetterObituary.Mod.Serialization.flagSerialize("BetterObituary", extendedFallenData, this.getFlags());
		
        onSerialize(_out);
    }
	
    local onDeserialize = o.onDeserialize;
    o.onDeserialize = function (_in) 
	{
        onDeserialize(_in);
		
        local data = ::BetterObituary.Mod.Serialization.flagDeserialize("BetterObituary", [], null, this.getFlags());
		
        if (data.len() == 0) 
		{
            if(::BetterObituary.Debug) ::logInfo("Better Obituary: No mod data found in save (vanilla save)");
            return;
        }
		
        foreach (index, entry in data) 
		{
			if (index >= this.m.Fallen.len()) break;
						
			this.m.Fallen[index].level <- "Level" in entry ? entry.Level : 0;
			this.m.Fallen[index].traits <- "Traits" in entry ? entry.Traits : [];
			this.m.Fallen[index].perks <- "Perks" in entry ? entry.Perks : [];
			this.m.Fallen[index].perminjuries <- "Injures" in entry ? entry.Injures : [];
			this.m.Fallen[index].stats <- "Stats" in entry ? entry.Stats : [];
			this.m.Fallen[index].talents <- "Talents" in entry ? entry.Talents : [];

			if(::BetterObituary.Debug) 
			{
				function logListInfo(listName, list) 
				{
					if (list.len() > 0) {
					
						local listStr = "";
						foreach (item in list) 
						{
							listStr += item + ", ";
						}
						listStr = listStr.slice(0, listStr.len() - 2);  // Remove the last ", "
						if(::BetterObituary.Debug) logInfo("Better Obituary: Fallen info - " + listName + " = " + list.len() + " -> " + listStr);
					}
				}

				::logInfo("Better Obituary: Fallen info - Level = " + this.m.Fallen[index].level);

				logListInfo("Traits", this.m.Fallen[index].traits);
				logListInfo("Perks", this.m.Fallen[index].perks);
				logListInfo("Injuries", this.m.Fallen[index].perminjuries);
				logListInfo("Stats", this.m.Fallen[index].stats);
				logListInfo("Talents", this.m.Fallen[index].talents);
			}
		}
    }
});
