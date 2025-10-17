"use strict";

// Display modes
var ArmourIndicatorsMode = 0; // 0 = Armor, 1 = Weapon+Shield, 2 = None

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

    var statusImage = $('<img/>').attr('src', getIconForRatio(type, ratio));
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

// Remove armor status
$.fn.removeListBrotherHeadStatus   = function() { this.removeStatusIcon('head'); };
$.fn.removeListBrotherArmorStatus  = function() { this.removeStatusIcon('body'); };
$.fn.removeListBrotherWeaponStatus = function() { this.removeStatusIcon('weapon'); };
$.fn.removeListBrotherShieldStatus = function() { this.removeStatusIcon('shield'); };

var originalCreateListBrother = $.fn.createListBrother;
$.fn.createListBrother = function(_brotherId, _classes) {

    var result = originalCreateListBrother.apply(this, arguments);
    var assetLayer = result.find('.asset-layer');

    if (assetLayer.length) 
	{
		var containers = ['head', 'body', 'weapon', 'shield'];
		
		for (var i = 0; i < containers.length; i++) 
		{
			var type = containers[i];
			if (!assetLayer.find('.' + type + '-status-container').length) 
			{
				assetLayer.append('<div class="' + type + '-status-container"></div>');
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

function updateBrotherStatusIcons(_data, result) 
{
    var armorHead = _data.stats.armorHead;
    var armorBody = _data.stats.armorBody;
    var mainhand = _data.equipment ? _data.equipment.mainhand : null;
    var offhand = _data.equipment ? _data.equipment.offhand : null;

    // Show status icons based on mode and condition
    if (ArmourIndicatorsMode === 0) 
	{
        if (armorHead < _data.stats.armorHeadMax) result.assignListBrotherHeadStatus(armorHead / _data.stats.armorHeadMax);
        if (armorBody < _data.stats.armorBodyMax) result.assignListBrotherArmorStatus(armorBody / _data.stats.armorBodyMax);
    }

    if (ArmourIndicatorsMode === 1) 
	{
        if (mainhand && mainhand.amount)
		{
            var repairValue = parseFloat(mainhand.amount.replace('%', '')) / 100;
			
            if (repairValue < 1.0) result.assignListBrotherWeaponStatus(repairValue);
            else result.removeListBrotherWeaponStatus();
        } 
		else 
		{
            result.removeListBrotherWeaponStatus();
        }

        if (offhand && offhand.amount) 
		{
            var repairValue = parseFloat(offhand.amount.replace('%', '')) / 100;
			
            if (repairValue < 1.0) result.assignListBrotherShieldStatus(repairValue);
            else result.removeListBrotherShieldStatus();
        } 
		else 
		{
            result.removeListBrotherShieldStatus();
        }
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
    slot.removeListBrotherHeadStatus();
    slot.removeListBrotherArmorStatus();
    slot.removeListBrotherWeaponStatus();
    slot.removeListBrotherShieldStatus();

    updateBrotherStatusIcons(_data, slot);
};


var originalCreateDIV = CharacterScreenInventoryListModule.prototype.createDIV;
CharacterScreenInventoryListModule.prototype.createDIV = function(_parentDiv) 
{
    originalCreateDIV.call(this, _parentDiv);

    var self = this;

    var layout = $('<div class="l-button is-armourindicators-filter"/>');

    this.mFilterPanel.append(layout);
    this.mFilterArmourIndicatorsButton = layout.createImageButton(Path.GFX + 'ui/icons/icon_cycle_1.png', function () 
	{
        var mode = self.mParent.mParent.mBrothersModule.cycleArmourIndicators();

        if (mode === 0)			self.mFilterArmourIndicatorsButton.changeButtonImage(Path.GFX + 'ui/icons/icon_cycle_1.png');
        else if (mode === 1)	self.mFilterArmourIndicatorsButton.changeButtonImage(Path.GFX + 'ui/icons/icon_cycle_2.png');
        else					self.mFilterArmourIndicatorsButton.changeButtonImage(Path.GFX + 'ui/icons/icon_cycle_3.png');
    }, '', 3);

    // Bind the tooltip after button creation
    this.mFilterArmourIndicatorsButton.bindTooltip({
        contentType: 'msu-generic',
        modId: 'mod_armour_indicators',  // Replace with your mod's ID
        elementId: 'MyScreen.isArmourIndicatorsFilterButton',
    });
};


// New function - toggle armor damage icon visibility
CharacterScreenBrothersListModule.prototype.cycleArmourIndicators = function ()
{
    ArmourIndicatorsMode = (ArmourIndicatorsMode + 1) % 3;

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
                child.removeListBrotherHeadStatus();
                child.removeListBrotherArmorStatus();
                child.removeListBrotherWeaponStatus();
                child.removeListBrotherShieldStatus();

                // Recalculate and re-apply the armor status icons based on current data
                this.updateBrotherSlot(updatedData);
            }
        }
    }
    return ArmourIndicatorsMode;
};