"use strict";

$.fn.assignListBrotherHeadStatus = function(_ratio)
{ // New function - add head armor damage icon
    var layer = this.find('.asset-layer:first');
    
    if (layer.length > 0)
    {
        var statusContainer = layer.find('.head-status-container:first');
        var statusImage = $('<img/>');
        if (_ratio >=0.75) 		 statusImage.attr('src', Path.GFX + 'ui/icons/armor_head_1.png');
        else if (_ratio >=0.50)  statusImage.attr('src', Path.GFX + 'ui/icons/armor_head_2.png');
        else if (_ratio >=0.25)  statusImage.attr('src', Path.GFX + 'ui/icons/armor_head_3.png');
        else				     statusImage.attr('src', Path.GFX + 'ui/icons/armor_head_4.png');
        statusContainer.append(statusImage);
        layer.append(statusContainer);
    }
}

$.fn.assignListBrotherArmorStatus = function(_ratio)
{ // New function - add body armor damage icon
    var layer = this.find('.asset-layer:first');
    
    if (layer.length > 0)
    {
        var statusContainer = layer.find('.armor-status-container:first');
        var statusImage = $('<img/>');
        if (_ratio >= 0.75)		 statusImage.attr('src', Path.GFX + 'ui/icons/armor_body_1.png');
        else if (_ratio >=0.50)  statusImage.attr('src', Path.GFX + 'ui/icons/armor_body_2.png');
        else if (_ratio >=0.25)  statusImage.attr('src', Path.GFX + 'ui/icons/armor_body_3.png');
        else				     statusImage.attr('src', Path.GFX + 'ui/icons/armor_body_4.png');
        statusContainer.append(statusImage);
        layer.append(statusContainer);
    }
}

$.fn.removeListBrotherHeadStatus = function()
{ // New function - remove head armor damage icon
    var layer = this.find('.asset-layer:first');
    
    if (layer.length > 0)
    {
        var statusContainer = layer.find('.head-status-container:first');
        var statusImage = statusContainer.find('img:first');
        if (statusImage.length > 0) 
        {
            statusImage.remove();
        }
    }
}
$.fn.removeListBrotherArmorStatus = function()
{ // New function - remove body armor damage icon
    var layer = this.find('.asset-layer:first');
    
    if (layer.length > 0)
    {
        var statusContainer = layer.find('.armor-status-container:first');
        var statusImage = statusContainer.find('img:first');
        if (statusImage.length > 0) 
        {
            statusImage.remove();
        }
    }
}

// overwrite
 $.fn.createListBrother = function(_brotherId, _classes)
 {
    var result = $('<div class="ui-control brother is-list-brother"/>');

    if (_classes !== undefined && _classes !== null && typeof(_classes) === 'string')
    {
        result.addClass(_classes);
    }

    // highlight layer
    var highlightLayer = $('<div class="highlight-layer"/>');
    result.append(highlightLayer);
    highlightLayer.createImage(Path.GFX + 'ui/skin/inventory_highlight.png', null, null, null);

    // image layer
    var imageLayer = $('<div class="image-layer"/>');
    result.append(imageLayer);

    /*imageLayer.createImage(null, function (_image)
    {
        var data = result.data('brother');
        _image.removeClass('display-none').addClass('display-block');
        //_image.centerImageWithinParent(data.imageOffsetX, data.imageOffsetY, data.imageScale);
    }, null, 'display-none');*/

    imageLayer.createImage(null, null, null, '');

    // lock layer
    var lockLayer = $('<div class="lock-layer"/>');
    result.append(lockLayer);
    lockLayer.createImage(null, function (_image)
    {
        _image.removeClass('display-none').addClass('display-block');
    }, null, 'display-none');

 	// mood layer
    var moodLayer = $('<div class="mood-layer"/>');
    result.append(moodLayer);
    moodLayer.createImage(null, function (_image)
    {
    	_image.removeClass('display-none').addClass('display-block');
    }, null, 'display-none');
     

    // name layer
    /*var nameLayer = $('<div class="name-layer"/>');
    result.append(nameLayer);
    var nameLabel = $('<div class="label title-font-very-small font-color-brother-name"/>');
    nameLayer.append(nameLabel); */

    // asset layer
    var assetLayer = $('<div class="asset-layer"/>');
    result.append(assetLayer);
     
    /*var dailyMoneyContainer = $('<div class="daily-money-container"/>');
    var dailyMoneyCostsText = $('<div class="label text-font-small font-color-progressbar-label"/>');
    dailyMoneyContainer.append(dailyMoneyCostsText);
    var dailyMoneyImage = $('<img/>');
    dailyMoneyImage.attr('src', Path.GFX + Asset.ICON_ASSET_DAILY_MONEY);
    dailyMoneyImage.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.Assets.DailyMoney });

    dailyMoneyContainer.append(dailyMoneyImage);
    assetLayer.append(dailyMoneyContainer);*/
    
    var statusContainer = $('<div class="primary-status-container"/>');
    assetLayer.append(statusContainer);

    var statusContainer = $('<div class="status-container"/>');
    assetLayer.append(statusContainer);
    
    var statusContainer = $('<div class="head-status-container"/>'); // Added for head icon
    assetLayer.append(statusContainer);
    
    var statusContainer = $('<div class="armor-status-container"/>'); // Added for body icon
    assetLayer.append(statusContainer);
          
    // add data
    var data = this.data('brother') || {};
    data.id = _brotherId || 0;
    data.imageOffsetX = 0;
    data.imageOffsetY = 0;
    data.imageScale = 0;

    result.data('brother', data);

    result.bindTooltip({ contentType: 'roster-entity', entityId: _brotherId });

    this.append(result);

    return result;
};


// overwrite
CharacterScreenBrothersListModule.prototype.addBrotherSlotDIV = function (_parentDiv, _data, _index, _allowReordering)
{
    var self = this;
    var screen = $('.character-screen');

    // create: slot & background layer
    var result = _parentDiv.createListBrother(_data[CharacterScreenIdentifier.Entity.Id]);
    result.attr('id', 'slot-index_' + _data[CharacterScreenIdentifier.Entity.Id]);
    result.data('ID', _data[CharacterScreenIdentifier.Entity.Id]);
    result.data('idx', _index);

    this.mSlots[_index].data('child', result);

    if (_index <= 17)
        ++this.mNumActive;

    // drag handler
    if (_allowReordering)
    {
        result.drag("start", function (ev, dd)
        {
            // dont allow drag if this is an empty slot
            /*var data = $(this).data('item');
            if (data.isEmpty === true)
            {
                return false;
            }*/

            // build proxy
            var proxy = $('<div class="ui-control brother is-proxy"/>');
            proxy.appendTo(document.body);
            proxy.data('idx', _index);

            var imageLayer = result.find('.image-layer:first');
            if (imageLayer.length > 0)
            {
                imageLayer = imageLayer.clone();
                proxy.append(imageLayer);
            }

            $(dd.drag).addClass('is-dragged');

            return proxy;
        }, { distance: 3 });

        result.drag(function (ev, dd)
        {
            $(dd.proxy).css({ top: dd.offsetY, left: dd.offsetX });
        }, { relative: false, distance: 3 });

        result.drag("end", function (ev, dd)
        {
            var drag = $(dd.drag);
            var drop = $(dd.drop);
            var proxy = $(dd.proxy);

            var allowDragEnd = true; // TODO: check what we're dropping onto

            // not dropped into anything?
            if (drop.length === 0 || allowDragEnd === false)
            {
                proxy.velocity("finish", true).velocity({ top: dd.originalY, left: dd.originalX },
			    {
			        duration: 300,
			        complete: function ()
			        {
			            proxy.remove();
			            drag.removeClass('is-dragged');
			        }
			    });
            }
            else
            {
                proxy.remove();
            }
        }, { drop: '.is-brother-slot' });
    }

    // update image & name
	
    var character = _data[CharacterScreenIdentifier.Entity.Character.Key];
    var imageOffsetX = (CharacterScreenIdentifier.Entity.Character.ImageOffsetX in character ? character[CharacterScreenIdentifier.Entity.Character.ImageOffsetX] : 0);
    var imageOffsetY = (CharacterScreenIdentifier.Entity.Character.ImageOffsetY in character ? character[CharacterScreenIdentifier.Entity.Character.ImageOffsetY] : 0);

    result.assignListBrotherImage(Path.PROCEDURAL + character[CharacterScreenIdentifier.Entity.Character.ImagePath], imageOffsetX, imageOffsetY, 0.66);
    //result.assignListBrotherName(character[CharacterScreenIdentifier.Entity.Character.Name]);
    //result.assignListBrotherDailyMoneyCost(character[CharacterScreenIdentifier.Entity.Character.DailyMoneyCost]);

    if(CharacterScreenIdentifier.Entity.Character.LeveledUp in character && character[CharacterScreenIdentifier.Entity.Character.LeveledUp] === true)
    {
        result.assignListBrotherLeveledUp();
    }

    /*if(CharacterScreenIdentifier.Entity.Character.DaysWounded in character && character[CharacterScreenIdentifier.Entity.Character.DaysWounded] === true)
    {
        result.assignListBrotherDaysWounded();
    }*/

    if('moodIcon' in character && this.mDataSource.getInventoryMode() == CharacterScreenDatasourceIdentifier.InventoryMode.Stash)
    {
    	result.showListBrotherMoodImage(this.IsMoodVisible, character['moodIcon']);
    }

    for(var i = 0; i != _data['injuries'].length && i < 3; ++i)
    {
        result.assignListBrotherStatusEffect(_data['injuries'][i].imagePath, _data[CharacterScreenIdentifier.Entity.Id], _data['injuries'][i].id)
    }

    if(_data['injuries'].length <= 2 && _data['stats'].hitpoints < _data['stats'].hitpointsMax)
    {
    	result.assignListBrotherDaysWounded();
    }
    
    if (_data['stats'].armorHead < _data['stats'].armorHeadMax)
    { // head armor damaged
        result.assignListBrotherHeadStatus(_data['stats'].armorHead / _data['stats'].armorHeadMax);
    }
    
    if (_data['stats'].armorBody < _data['stats'].armorBodyMax)
    { // body armor damaged
        result.assignListBrotherArmorStatus(_data['stats'].armorBody / _data['stats'].armorBodyMax);
    }

    result.assignListBrotherClickHandler(function (_brother, _event)
	{
        var data = _brother.data('brother');
        self.mDataSource.selectedBrotherById(data.id);
    });
};

// overwrite
CharacterScreenBrothersListModule.prototype.updateBrotherSlot = function (_data)
{
	var slot = this.mListScrollContainer.find('#slot-index_' + _data[CharacterScreenIdentifier.Entity.Id] + ':first');
	if (slot.length === 0)
	{
		return;
	}

	// update image & name
    var character = _data[CharacterScreenIdentifier.Entity.Character.Key];
    var imageOffsetX = (CharacterScreenIdentifier.Entity.Character.ImageOffsetX in character ? character[CharacterScreenIdentifier.Entity.Character.ImageOffsetX] : 0);
    var imageOffsetY = (CharacterScreenIdentifier.Entity.Character.ImageOffsetY in character ? character[CharacterScreenIdentifier.Entity.Character.ImageOffsetY] : 0);

    slot.assignListBrotherImage(Path.PROCEDURAL + character[CharacterScreenIdentifier.Entity.Character.ImagePath], imageOffsetX, imageOffsetY, 0.66);
    slot.assignListBrotherName(character[CharacterScreenIdentifier.Entity.Character.Name]);
    slot.assignListBrotherDailyMoneyCost(character[CharacterScreenIdentifier.Entity.Character.DailyMoneyCost]);

    if(this.mDataSource.getInventoryMode() == CharacterScreenDatasourceIdentifier.InventoryMode.Stash)
        slot.showListBrotherMoodImage(this.IsMoodVisible, character['moodIcon']);

    slot.removeListBrotherStatusEffects();
    slot.removeListBrotherHeadStatus(); // head armor damaged
    slot.removeListBrotherArmorStatus(); // body armor damaged

    for (var i = 0; i != _data['injuries'].length && i < 3; ++i)
    {
        slot.assignListBrotherStatusEffect(_data['injuries'][i].imagePath, character[CharacterScreenIdentifier.Entity.Id], _data['injuries'][i].id)
    }

    if (_data['injuries'].length <= 2 && _data['stats'].hitpoints < _data['stats'].hitpointsMax)
    {
        slot.assignListBrotherDaysWounded();
    }
    
    if (_data['stats'].armorHead < _data['stats'].armorHeadMax) 
    { // head armor damaged
        slot.assignListBrotherHeadStatus(_data['stats'].armorHead / _data['stats'].armorHeadMax);
    }
    
    if (_data['stats'].armorBody < _data['stats'].armorBodyMax) 
    { // body armor damaged
        slot.assignListBrotherArmorStatus(_data['stats'].armorBody / _data['stats'].armorBodyMax);
    }

    if (CharacterScreenIdentifier.Entity.Character.LeveledUp in character && character[CharacterScreenIdentifier.Entity.Character.LeveledUp] === false)
    {
        slot.removeListBrotherLeveledUp();
    }

    /*
	var imageContainer = slot.find('.l-brother-slot-image:first');
	if (imageContainer.length > 0)
	{
		var image = imageContainer.find('img:first');
		if (image.length > 0)
		{
			image.attr('src', Path.PROCEDURAL + _brother.character.imagePath);
		}
	}

	// update text
	var textContainer = slot.find('.l-brother-slot-text:first');
	if (textContainer.length > 0)
	{
		textContainer.html(_brother.character.name);
	}
	*/
};