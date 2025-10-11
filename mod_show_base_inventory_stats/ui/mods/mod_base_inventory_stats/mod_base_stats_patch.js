// Patch ProgressbarValueIdentifier with base stat
(function() {
    if (typeof ProgressbarValueIdentifier !== 'undefined') {
        var baseStats = {
            FatigueBase: 'fatigueBase',
            HitpointsBase: 'hitpointsBase',
            BraveryBase: 'braveryBase',
            InitiativeBase: 'initiativeBase',
            MeleeSkillBase: 'meleeSkillBase',
            RangedSkillBase: 'rangedSkillBase',
            MeleeDefenseBase: 'meleeDefenseBase',
            RangedDefenseBase: 'rangedDefenseBase'
        };
        for (var key in baseStats) {
            ProgressbarValueIdentifier[key] = baseStats[key];
        }
    }
})();


CharacterScreenStatsModule.prototype.setProgressbarValue = function (_progressbarDiv, _data, _valueKey, _valueMaxKey, _labelKey)
{
    if (_valueKey in _data && _data[_valueKey] !== null && _valueMaxKey in _data && _data[_valueMaxKey] !== null)
    {
        _progressbarDiv.changeProgressbarNormalWidth(_data[_valueKey], _data[_valueMaxKey]);

        if (_labelKey in _data && _data[_labelKey] !== null)
        {
            _progressbarDiv.changeProgressbarLabel(_data[_labelKey]);
        }
        else
        {
            switch(_valueKey)
            {
                case ProgressbarValueIdentifier.ArmorHead:
                case ProgressbarValueIdentifier.ArmorBody:
                case ProgressbarValueIdentifier.ActionPoints:
                case ProgressbarValueIdentifier.Morale:
                {
                    _progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' / ' + _data[_valueMaxKey] + '');
                } break;
                case ProgressbarValueIdentifier.Fatigue:
                {
                    (_data[_valueMaxKey] != _data.fatigueBase)
                        ? (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' / ' + _data[_valueMaxKey] + ' (' + _data.fatigueBase + ')'))
                        : (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' / ' + _data[_valueMaxKey]));
                } break;
                case ProgressbarValueIdentifier.Hitpoints:
                {
                    (_data[_valueMaxKey] != _data.hitpointsBase)
                        ? (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' / ' + _data[_valueMaxKey] + ' (' + _data.hitpointsBase + ')'))
                        : (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' / ' + _data[_valueMaxKey]));
                } break;
                case ProgressbarValueIdentifier.Bravery:
                {
                    (_data[_valueKey] != _data.braveryBase)
                        ? (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' (' + _data.braveryBase + ')'))
                        : (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey]));
                } break;
                case ProgressbarValueIdentifier.Initiative:
                {
                    (_data[_valueKey] != _data.initiativeBase)
                        ? (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' (' + _data.initiativeBase + ')'))
                        : (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey]));
                } break;
                case ProgressbarValueIdentifier.MeleeSkill:
                {
                    (_data[_valueKey] != _data.meleeSkillBase)
                        ? (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' (' + _data.meleeSkillBase + ')'))
                        : (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey]));
                } break;
                case ProgressbarValueIdentifier.RangeSkill:
                {
                    (_data[_valueKey] != _data.rangedSkillBase)
                        ? (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' (' + _data.rangedSkillBase + ')'))
                        : (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey]));
                } break;
                case ProgressbarValueIdentifier.MeleeDefense:
                {
                    (_data[_valueKey] != _data.meleeDefenseBase)
                        ? (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' (' + _data.meleeDefenseBase + ')'))
                        : (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey]));
                } break;
                case ProgressbarValueIdentifier.RangeDefense:
                {
                    (_data[_valueKey] != _data.rangedDefenseBase)
                        ? (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey] + ' (' + _data.rangedDefenseBase + ')'))
                        : (_progressbarDiv.changeProgressbarLabel('' + _data[_valueKey]));
                } break;
                default:
                {
                    _progressbarDiv.changeProgressbarLabel('' + _data[_valueKey]);
                }
            }
        }
    }
};
