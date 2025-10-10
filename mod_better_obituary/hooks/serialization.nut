::mods_hookNewObject("statistics/statistics_manager", function(o) 
{
	// Serialize arrays (traits, stats, talents, injuries)
    local function serializeArray(array, _out, itemType) 
	{
        _out.writeU8(array.len());
        foreach (item in array) 
		{
            switch (itemType)
			{
                case "string": _out.writeString(item); break;
                case "int":    _out.writeU32(item); break;
                case "byte":   _out.writeU8(item); break;
            }
        }
    }

    // Fill arrays with default values when loading vanilla save
    local function fillArrayWithDefaults(_out, defaultValue, count, itemType) 
	{
        _out.writeU8(count);
        for (local i = 0; i < count; i++) 
		{
            switch (itemType) 
			{
                case "string": _out.writeString(defaultValue); break;
                case "int":    _out.writeU32(defaultValue); break;
                case "byte":   _out.writeU8(defaultValue); break;
            }
        }
    }

    // Deserialize array (traits, stats, talents, injuries)
    local function deserializeArray(_in, itemType)
	{
        local arr = [];
        local count = _in.readU8();
        for (local i = 0; i < count; i++) 
		{
            switch (itemType) 
			{
                case "string": arr.push(_in.readString()); break;
                case "int":    arr.push(_in.readU32()); break;
                case "byte":   arr.push(_in.readU8()); break;
            }
        }
        return arr;
    }

    o.onSerialize = function (_out) 
	{
        //::logInfo("Better Obituary: onSerialize");

		this.m.Flags.onSerialize(_out);
		_out.writeU8(this.m.News.len());

		foreach( n in this.m.News )
		{
			_out.writeString(n.Type);
			_out.writeF32(n.Time);
			n.onSerialize(_out);
		}

        _out.writeU32(this.m.Fallen.len());

        foreach(f in this.m.Fallen) 
		{
            _out.writeString(f.Name);
            _out.writeU32(f.Time);
            _out.writeU32(f.TimeWithCompany);
            _out.writeU32(f.Kills);
            _out.writeU32(f.Battles);
            _out.writeString(f.KilledBy);
			_out.writeBool(f.Expendable);
			
			/*
			::logInfo("Better Obituary: Fallen base information done");
			::logInfo("Better Obituary: has extended fallen level = " + ("level" in f));
			::logInfo("Better Obituary: has extended fallen traits = " + ("traits" in f));
			::logInfo("Better Obituary: has extended fallen stats = " + ("stats" in f));
			::logInfo("Better Obituary: has extended fallen talents = " + ("talents" in f));
			::logInfo("Better Obituary: has extended fallen perminjuries = " + ("perminjuries" in f));
			*/
			
			local hasExt = ("level" in f) && ("traits" in f) && ("stats" in f) && ("talents" in f) && ("perminjuries" in f);
			
            if (hasExt) 
			{
                ::logInfo("Better Obituary: write known extended data");

                _out.writeU8(f.level);
                serializeArray(f.traits, _out, "string");
                serializeArray(f.perminjuries, _out, "string");
                serializeArray(f.stats, _out, "int");
                serializeArray(f.talents, _out, "byte");
            } 
			else 
			{
                ::logInfo("Better Obituary: write filler extended data"); // Undefined if not.

                _out.writeU8(::BetterObituary.placeholder_data);

                fillArrayWithDefaults(_out, "", ::BetterObituary.num_traits, "string");
                fillArrayWithDefaults(_out, "", ::BetterObituary.num_perminjuries, "string");
                fillArrayWithDefaults(_out, ::BetterObituary.placeholder_data, ::BetterObituary.num_stats, "int");
                fillArrayWithDefaults(_out, ::BetterObituary.placeholder_data, ::BetterObituary.num_talents, "byte");
            }
        }
    };

	o.onDeserialize = function ( _in )
	{
		//::logInfo("Better Obituary: Start Deserialize = version: " + _in.getMetaData().getVersion());
	
		if (_in.getMetaData().getVersion() <= 53)
		{
			this.m.Flags.set("LastLocationDestroyedName", _in.readString());
			this.m.Flags.set("LastLocationDestroyedFaction", _in.readU8());
			this.m.Flags.set("LastLocationDestroyedForContract", _in.readBool());
			this.m.Flags.set("LastEnemiesDefeatedCount", _in.readU16());
			this.m.Flags.set("LastCombatResult", _in.readU8());

			if (_in.getMetaData().getVersion() >= 42)
			{
				this.m.Flags.set("LastCombatFaction", _in.readU8());
			}
			else
			{
				this.m.Flags.set("LastCombatFaction", 0);
			}

			this.m.Flags.set("LastCombatSavedCaravan", false);
			this.m.Flags.set("LastCombatSavedCaravanProduce", "");
		}

		this.m.Flags.onDeserialize(_in);
		local numNews = _in.readU8();
		this.m.News.resize(numNews);

		for( local i = 0; i < numNews; i = ++i )
		{
			local news = this.new("scripts/tools/tag_collection");
			news.Type <- _in.readString();
			news.Time <- _in.readF32();
			news.onDeserialize(_in);
			this.m.News[i] = news;
		}
		
		//::logInfo("Better Obituary: Start Deserialize Fallen");

		local numFallen = _in.readU32();
		this.m.Fallen.resize(numFallen);

		for( local i = 0; i < numFallen; i = ++i )
		{
			//::logInfo("Better Obituary: fallen = " + i);
		
			local f = {};
			f.Name <- _in.readString();
			f.Time <- _in.readU32();
			f.TimeWithCompany <- _in.readU32();
			f.Kills <- _in.readU32();
			f.Battles <- _in.readU32();
			f.KilledBy <- _in.readString();
			f.Expendable <- _in.readBool();
			
			/*
			::logInfo("Better Obituary: fallen Name = " + f.Name);
			::logInfo("Better Obituary: fallen Time = " + f.Time);
			::logInfo("Better Obituary: fallen TimeWithCompany = " + f.TimeWithCompany);
			::logInfo("Better Obituary: fallen Kills = " + f.Kills);
			::logInfo("Better Obituary: fallen Battles = " + f.Battles);
			::logInfo("Better Obituary: fallen KilledBy = " + f.KilledBy);
			::logInfo("Better Obituary: fallen Expendable = " + f.Expendable);
			*/
			
            if (_in.getMetaData().getVersion() >= 90)
			{
                ::logInfo("Better Obituary: Start Deserialize extended fallen data");

                f.level <- _in.readU8();
                f.traits <- deserializeArray(_in, "string");
                f.perminjuries <- deserializeArray(_in, "string");
                f.stats <- deserializeArray(_in, "int");
                f.talents <- deserializeArray(_in, "byte");
            }
			
			this.m.Fallen[i] = f;
		}
	}
});
