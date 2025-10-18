"use strict";

// Display modes
var ArmourIndicatorsMode = 0; // 0 = Head/Body Armor, 1 = Weapon/Shield, 2 = All, 3 = None

// Utility function to get icon for a ratio
function getIconForRatio(type, ratio) 
{
    var Icons_Green = MSU.getSettingValue("mod_armour_indicators", "Icons_Green") / 100;
    var Icons_Yellow = MSU.getSettingValue("mod_armour_indicators", "Icons_Yellow") / 100;
    var Icons_Orange = MSU.getSettingValue("mod_armour_indicators", "Icons_Orange") / 100;
    var iconPath = Path.GFX + 'ui/icons/';

    if (ratio >= Icons_Green) return iconPath + type + '_1.png';
    if (ratio >= Icons_Yellow) return iconPath + type + '_2.png';
    if (ratio >= Icons_Orange) return iconPath + type + '_3.png';
	
    return iconPath + type + '_4.png';
}


$.fn.assignStatusIcon = function(type, ratio) 
{
    var layer = this.find('.asset-layer:first');
	
    if (layer.length === 0) return;

    var statusContainer = layer.find('.' + type + '-status-container:first');
    if (statusContainer.length === 0) 
	{
        statusContainer = $('<div class="' + type + '-status-container"></div>');
        layer.append(statusContainer);
    } 
	else 
	{
        statusContainer.empty();
    }

    var statusImage = $('<img/>').attr('src', getIconForRatio(type.replace(/\d$/, ''), ratio));
    statusContainer.append(statusImage);
};

$.fn.removeStatusIcon = function(type) 
{
    var layer = this.find('.asset-layer:first');
    if (layer.length > 0) 
	{
        var statusContainer = layer.find('.' + type + '-status-container:first');
        var statusImage = statusContainer.find('img:first');
        if (statusImage.length > 0) 
		{
            statusImage.remove();
        }
    }
};

// Assign armor status
$.fn.assignListBrotherHeadStatus   = function(ratio) { this.assignStatusIcon('head', ratio); };
$.fn.assignListBrotherArmorStatus  = function(ratio) { this.assignStatusIcon('body', ratio); };
$.fn.assignListBrotherWeaponStatus = function(ratio) { this.assignStatusIcon('weapon', ratio); };
$.fn.assignListBrotherShieldStatus = function(ratio) { this.assignStatusIcon('shield', ratio); };
$.fn.assignListBrotherHead2Status  = function(ratio) { this.assignStatusIcon('head2', ratio); };
$.fn.assignListBrotherArmor2Status = function(ratio) { this.assignStatusIcon('body2', ratio); };

// Remove armor status
function removeAllStatusIcons(slot) {
    slot.removeListBrotherHeadStatus();
    slot.removeListBrotherArmorStatus();
    slot.removeListBrotherWeaponStatus();
    slot.removeListBrotherShieldStatus();
    slot.removeListBrotherHead2Status();
    slot.removeListBrotherArmor2Status();
}

$.fn.removeListBrotherHeadStatus   = function() { this.removeStatusIcon('head'); };
$.fn.removeListBrotherArmorStatus  = function() { this.removeStatusIcon('body'); };
$.fn.removeListBrotherWeaponStatus = function() { this.removeStatusIcon('weapon'); };
$.fn.removeListBrotherShieldStatus = function() { this.removeStatusIcon('shield'); };
$.fn.removeListBrotherHead2Status  = function() { this.removeStatusIcon('head2'); };
$.fn.removeListBrotherArmor2Status = function() { this.removeStatusIcon('body2'); };

var originalCreateListBrother = $.fn.createListBrother;
$.fn.createListBrother = function(_brotherId, _classes) 
{
    var result = originalCreateListBrother.apply(this, arguments);
    var assetLayer = result.find('.asset-layer');

    if (assetLayer.length) 
	{
		var containers = ['head', 'body', 'weapon', 'shield'];
		for (var i = 0; i < containers.length; i++) 
		{
			if (!assetLayer.find('.' + containers[i] + '-status-container').length) 
			{
				assetLayer.append('<div class="' + containers[i] + '-status-container"></div>');
			}
		}
    }

    return result;
};

function getItemById(dataSource, itemId) 
{
    if (dataSource && itemId) 
	{
        for (var i = 0; i < dataSource.length; i++) 
		{
            if (dataSource[i].id === itemId) 
			{
                return dataSource[i];
            }
        }
    }
    return null;
}

function parseEquipmentCondition(item) {
    if (item && item.amount && item.amount.indexOf('%') !== -1) {
        return parseFloat(item.amount.replace('%', '')) / 100;
    }
    return null;
}


function updateBrotherStatusIcons(_data, result) 
{
    var armorHead = _data.stats.armorHead;
    var armorBody = _data.stats.armorBody;
    var mainhand = _data.equipment ? _data.equipment.mainhand : null;
    var offhand = _data.equipment ? _data.equipment.offhand : null;
	
	removeAllStatusIcons(result);

    // Show status icons based on mode and condition
    if (ArmourIndicatorsMode === 0) 
	{
        if (armorHead < _data.stats.armorHeadMax) result.assignListBrotherHeadStatus(armorHead / _data.stats.armorHeadMax);
        if (armorBody < _data.stats.armorBodyMax) result.assignListBrotherArmorStatus(armorBody / _data.stats.armorBodyMax);

    }
    else if (ArmourIndicatorsMode === 1) 
	{
		var mainhandCondition = parseEquipmentCondition(mainhand);
		if (mainhandCondition !== null && mainhandCondition < 1.0) result.assignListBrotherWeaponStatus(mainhandCondition);
		else result.removeListBrotherWeaponStatus();

		var offhandCondition = parseEquipmentCondition(offhand);
		if (offhandCondition !== null && offhandCondition < 1.0) result.assignListBrotherShieldStatus(offhandCondition);
		else result.removeListBrotherShieldStatus();
    }
	else if (ArmourIndicatorsMode === 2)
	{
		if (armorHead < _data.stats.armorHeadMax) result.assignListBrotherHead2Status(armorHead / _data.stats.armorHeadMax);
		if (armorBody < _data.stats.armorBodyMax) result.assignListBrotherArmor2Status(armorBody / _data.stats.armorBodyMax);

		if (mainhand && mainhand.amount && mainhand.amount.indexOf('%') !== -1)
		{
			var mainhandCondition = parseEquipmentCondition(mainhand);;
			if (mainhandCondition < 1.0) result.assignListBrotherWeaponStatus(mainhandCondition);
			else result.removeListBrotherWeaponStatus();
		}
		else
		{
			result.removeListBrotherWeaponStatus();
		}

		if (offhand && offhand.amount && offhand.amount.indexOf('%') !== -1) 
		{
			var offhandCondition = parseEquipmentCondition(offhand);
			if (offhandCondition < 1.0) result.assignListBrotherShieldStatus(offhandCondition);
			else result.removeListBrotherShieldStatus();
		}
		else
		{
			result.removeListBrotherShieldStatus();
		}
	}
	else if (ArmourIndicatorsMode === 3) 
	{
	}	
}


var originalAddBrotherSlotDIV = CharacterScreenBrothersListModule.prototype.addBrotherSlotDIV;
CharacterScreenBrothersListModule.prototype.addBrotherSlotDIV = function(_parentDiv, _data, _index, _allowReordering) {
    originalAddBrotherSlotDIV.apply(this, arguments);

    var result = this.mSlots[_index].data('child');
    if (!result) return;

    updateBrotherStatusIcons(_data, result);

    result.data('brother', _data);
};


var originalUpdateBrotherSlot = CharacterScreenBrothersListModule.prototype.updateBrotherSlot;
CharacterScreenBrothersListModule.prototype.updateBrotherSlot = function(_data) {
    originalUpdateBrotherSlot.apply(this, arguments);

    var slot = this.mListScrollContainer.find('#slot-index_' + _data[CharacterScreenIdentifier.Entity.Id] + ':first');

    if (slot.length === 0) {
        return;
    }

	// Clear previous status icons before recalculating
	removeAllStatusIcons(slot);
	
    updateBrotherStatusIcons(_data, slot);
};

var originalCreateDIV = CharacterScreenInventoryListModule.prototype.createDIV;
CharacterScreenInventoryListModule.prototype.createDIV = function(_parentDiv) 
{
    originalCreateDIV.call(this, _parentDiv);

    var self = this;

    var layout = $('<div class="l-button is-armourindicators-filter"/>');
    this.mFilterPanel.append(layout);
	
	function updateButtonTooltip(nextMode) 
	{
		var tooltipMap = [
			'MyScreen.isArmourIndicatorsSetMode3',
			'MyScreen.isArmourIndicatorsSetMode0',
			'MyScreen.isArmourIndicatorsSetMode1',
			'MyScreen.isArmourIndicatorsSetMode2'
		];

		var tooltipId = tooltipMap[nextMode];

		self.mFilterArmourIndicatorsButton.bindTooltip({
			contentType: 'msu-generic',
			modId: 'mod_armour_indicators',
			elementId: tooltipId
		});
	}
	
	this.mFilterArmourIndicatorsButton = layout.createImageButton(
	
		Path.GFX + 'ui/icons/icon_cycle_1.png',
		function () 
		{
			var mode = self.mParent.mParent.mBrothersModule.cycleArmourIndicators();
			updateButtonImage(mode);
			updateButtonTooltip((mode + 1) % 4);
		},
		'',
		3
	);

	// Set initial tooltip to next mode (since clicking cycles forward)
	updateButtonTooltip((ArmourIndicatorsMode + 1) % 4);

	var iconMap = [
		'icon_cycle_1.png',
		'icon_cycle_2.png',
		'icon_cycle_3.png',
		'icon_cycle_4.png'
	];

	function updateButtonImage(mode) 
	{
		var icon = iconMap[mode] || 'warning.png';
		self.mFilterArmourIndicatorsButton.changeButtonImage(Path.GFX + 'ui/icons/' + icon);
	}

    // Hotkeys
    function setMode(mode) {
        if (self.mParent && self.mParent.mParent && self.mParent.mParent.mBrothersModule)
        {
            ArmourIndicatorsMode = mode;

            var brothersList = self.mParent.mParent.mBrothersModule.mDataSource.getBrothersList();
			
            for (var i = 0; i < self.mParent.mParent.mBrothersModule.mSlots.length; i++) 
			{
                var child = self.mParent.mParent.mBrothersModule.mSlots[i].data('child');
                if (!child) continue;

                var slotId = child.data('ID');
                if (slotId == null) continue;

                var updatedData = null;
				
                for (var j = 0; j < brothersList.length; j++) 
				{
                    if (brothersList[j] && brothersList[j].id === slotId) 
					{
                        updatedData = brothersList[j];
                        break;
                    }
                }

                if (updatedData !== null) {
				
				
                    child.removeListBrotherHeadStatus();
                    child.removeListBrotherArmorStatus();
                    child.removeListBrotherWeaponStatus();
                    child.removeListBrotherShieldStatus();

                    self.mParent.mParent.mBrothersModule.updateBrotherSlot(updatedData);
                }
            }

            updateButtonImage(mode);
			updateButtonTooltip((mode + 1) % 4);
        }
    }

    $(document).off('keyup.mod_armour_indicators');
	
	$(document).on('keyup.mod_armour_indicators', function(event) {
	
		var keyModeMap = {
			SetMode0: 0,
			SetMode1: 1,
			SetMode2: 2,
			SetMode3: 3,
			CycleArmourIndicatorsPrevious: (ArmourIndicatorsMode + 3) % 4,
			CycleArmourIndicatorsNext: (ArmourIndicatorsMode + 1) % 4
		};

		for (var key in keyModeMap) 
		{
			if (MSU.Keybinds.isKeybindPressed("mod_armour_indicators", key, event)) 
			{
				setMode(keyModeMap[key]);
				return false;
			}
		}
	});
};


// New function - toggle armor damage icon visibility
CharacterScreenBrothersListModule.prototype.cycleArmourIndicators = function ()
{
    ArmourIndicatorsMode = (ArmourIndicatorsMode + 1) % 4;

    var brothersList = this.mDataSource.getBrothersList();

    for (var i = 0; i < this.mSlots.length; ++i)
    {
        var child = this.mSlots[i].data('child');
        if (child != null)
        {
            var slotId = child.data('ID');

            if (slotId == null) 
			{
                continue;
            }

            var updatedData = null;
            for (var j = 0; j < brothersList.length; ++j)
            {
                //if (brothersList[j].id === slotId)
				if (brothersList[j] && brothersList[j].id === slotId)
                {
                    updatedData = brothersList[j];
                    break;
                }
            }

            if (updatedData !== null) 
			{
                // Clear previous status icons before recalculating
				removeAllStatusIcons(child);

                // Recalculate and re-apply the armor status icons based on current data
                this.updateBrotherSlot(updatedData);
            }
        }
    }
    return ArmourIndicatorsMode;
};




