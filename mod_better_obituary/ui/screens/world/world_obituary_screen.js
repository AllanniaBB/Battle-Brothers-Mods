/*
 *  @Project:		Battle Brothers
 *	@Company:		Overhype Studios
 *
 *	@Copyright:		(c) Overhype Studios | 2015
 * 
 *  @Author:		Overhype Studios
 *  @Date:			31.10.2017
 *  @Description:	World Relations Screen JS
 */
"use strict";

var WorldObituaryScreen = function(_parent)
{
	this.mSQHandle = null;

	// generic containers
	this.mContainer = null;
    this.mDialogContainer = null;
    this.mListContainer = null;
    this.mListScrollContainer = null;

    // buttons
    this.mLeaveButton = null;

    // generics
    this.mIsVisible = false;

    // selected entry
    this.mSelectedEntry = null;
};

WorldObituaryScreen.prototype.isConnected = function ()
{
    return this.mSQHandle !== null;
};

WorldObituaryScreen.prototype.onConnection = function (_handle)
{
	this.mSQHandle = _handle;
	this.register($('.root-screen'));
};

WorldObituaryScreen.prototype.onDisconnection = function ()
{
	this.mSQHandle = null;
	this.unregister();
};

WorldObituaryScreen.prototype.getModule = function (_name)
{
	switch(_name)
	{
        default: return null;
	}
};

WorldObituaryScreen.prototype.getModules = function ()
{
	return [];
};

WorldObituaryScreen.prototype.createDIV = function (_parentDiv)
{
    var self = this;

	// create: containers (init hidden!)
     this.mContainer = $('<div class="world-obituary-screen display-none opacity-none"/>');
     _parentDiv.append(this.mContainer);

    // create: containers (init hidden!)
    var dialogLayout = $('<div class="l-obituary-dialog-container"/>');
    this.mContainer.append(dialogLayout);
    this.mDialogContainer = dialogLayout.createDialog('Obituary', '', '', true, 'better-obituary');

    // create tabs
    var tabButtonsContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(tabButtonsContainer);

    // create content
    var content = this.mDialogContainer.findDialogContentContainer();

	// column headers
    var headers = $('<div class="table-header"/>');
    content.append(headers);

    this.mColumnName = $('<div class="table-header-name title title-font-big font-bold font-color-title">Name</div>');
    headers.append(this.mColumnName);

    //this.mColumnTime = $('<div class="table-header-time title title-font-big font-bold font-color-title">Days</div>');
	this.mColumnTime = $('<div class="table-header-time">\
    <img class="header-icon" src="' + Path.GFX + 'ui/images/day_time.png"></div>');
    headers.append(this.mColumnTime);

    //this.mColumnBattles = $('<div class="table-header-battles title title-font-big font-bold font-color-title">Battles</div>');
	this.mColumnBattles = $('<div class="table-header-battles title title-font-big font-bold font-color-title">\
    <img class="header-icon" src="' + Path.GFX + 'ui/icons/obituary_battles.png"></div>');
    headers.append(this.mColumnBattles);

    //this.mColumnKills = $('<div class="table-header-kills title title-font-big font-bold font-color-title">Kills</div>');
	this.mColumnKills = $('<div class="table-header-kills">\
    <img class="header-icon" src="' + Path.GFX + 'ui/icons/obituary_kills.png"></div>');
    headers.append(this.mColumnKills);

    this.mColumnKilledBy = $('<div class="table-header-killed-by title title-font-big font-bold font-color-title">Fate</div>');
    headers.append(this.mColumnKilledBy);

    this.mLevel = $('<div class="table-header-level title title-font-big font-bold font-color-title">Lv</div>');
    headers.append(this.mLevel);

	this.mTraits = $('<div class="table-header-traits title title-font-big font-bold font-color-title">Traits</div>');
	headers.append(this.mTraits);

	this.mPermInjuries = $('<div class="table-header-perminjuries">\
		<img class="header-icon" src="' + Path.GFX + 'ui/icons/days_wounded.png' + '"></div>');
	headers.append(this.mPermInjuries);

	this.mHP = $('<div class="table-header-hp">\
		<img class="header-icon" src="' + Path.GFX + Asset.ICON_HEALTH + '"></div>');
	headers.append(this.mHP);

	this.mFT = $('<div class="table-header-ft">\
		<img class="header-icon" src="' + Path.GFX + Asset.ICON_FATIGUE + '"></div>');
	headers.append(this.mFT);

	this.mBR = $('<div class="table-header-br">\
		<img class="header-icon" src="' + Path.GFX + Asset.ICON_BRAVERY + '"></div>');
	headers.append(this.mBR);

	this.mIT = $('<div class="table-header-it">\
		<img class="header-icon" src="' + Path.GFX + Asset.ICON_INITIATIVE + '"></div>');
	headers.append(this.mIT);

	this.mMA = $('<div class="table-header-ma">\
		<img class="header-icon" src="' + Path.GFX + Asset.ICON_MELEE_SKILL + '"></div>');
	headers.append(this.mMA);

	this.mRA = $('<div class="table-header-ra">\
		<img class="header-icon" src="' + Path.GFX + Asset.ICON_RANGE_SKILL + '"></div>');
	headers.append(this.mRA);

	this.mMD = $('<div class="table-header-md">\
		<img class="header-icon" src="' + Path.GFX + Asset.ICON_MELEE_DEFENCE + '"></div>');
	headers.append(this.mMD);

	this.mRD = $('<div class="table-header-rd">\
		<img class="header-icon" src="' + Path.GFX + Asset.ICON_RANGE_DEFENCE + '"></div>');
	headers.append(this.mRD);

    // left column
    var column = $('<div class="column is-left"/>');
    content.append(column);
    var listContainerLayout = $('<div class="l-list-container"/>');
    column.append(listContainerLayout);
    this.mListContainer = listContainerLayout.createList(1.0/*8.85*/);
    this.mListScrollContainer = this.mListContainer.findListScrollContainer();

    // create footer button bar
    var footerButtonBar = $('<div class="l-button-bar"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerButtonBar);

    // create: buttons
    var layout = $('<div class="l-leave-button"/>');
    footerButtonBar.append(layout);
    this.mLeaveButton = layout.createTextButton("Close", function()
	{
        self.notifyBackendCloseButtonPressed();
    }, '', 1);

    this.mIsVisible = false;
};


WorldObituaryScreen.prototype.destroyDIV = function ()
{
	//this.mAssets.destroyDIV();

    this.mListScrollContainer.empty();
    this.mListScrollContainer = null;
    this.mListContainer.destroyList();
    this.mListContainer.remove();
    this.mListContainer = null;

	this.mLeaveButton.remove();
    this.mLeaveButton = null;

    this.mDialogContainer.empty();
    this.mDialogContainer.remove();
    this.mDialogContainer = null;

    this.mContainer.empty();
    this.mContainer.remove();
    this.mContainer = null;
};

WorldObituaryScreen.prototype.getStatOrder = function ()
{
    var SwapStats = MSU.getSettingValue("mod_better_obituary", "SwapStats");

    return SwapStats
        ? [4, 5, 6, 7, 0, 1, 2, 3]
        : [0, 1, 2, 3, 4, 5, 6, 7];
};

WorldObituaryScreen.prototype.CreateStatHeader = function ()
{
    var statOrder = this.getStatOrder();

    var headerMap = [
        'table-header-hp', 'table-header-ft', 'table-header-br', 'table-header-it',
        'table-header-ma', 'table-header-ra', 'table-header-md', 'table-header-rd'
    ];

    for (var i = 0; i < headerMap.length; i++) {
        var className = headerMap[i];
        var selector = '.world-obituary-screen > .l-obituary-dialog-container .table-header .' + className;
        var element = document.querySelector(selector);
        if (element) {
            var newIndex = statOrder[i];
            var leftRem = 119 + (newIndex * 7.2) + 1;
            element.style.setProperty('left', leftRem + 'rem', 'important');
        }
    }
};

WorldObituaryScreen.prototype.addListEntry = function (_data)
{
    var result = $('<div class="l-row"/>');
    this.mListScrollContainer.append(result);

    result.append($('<div class="name text-font-normal font-color-description">' + _data.Name + '</div>'));
    result.append($('<div class="time text-font-normal font-color-description">' + _data.TimeWithCompany + '</div>'));
    result.append($('<div class="battles text-font-normal font-color-description">' + _data.Battles + '</div>'));
    result.append($('<div class="kills text-font-normal font-color-description">' + _data.Kills + '</div>'));
    result.append($('<div class="killed-by text-font-normal font-color-description">' + _data.KilledBy + '</div>'));

    if (typeof _data.traits !== "undefined" && _data.stats[0]) 
    {
        result.append($('<div class="level text-font-normal font-color-description">' + _data.level + '</div>'));

        // Stat header
        this.CreateStatHeader();

        var statsLabels = ['hptext', 'fttext', 'brtext', 'ittext', 'matext', 'ratext', 'mdtext', 'rdtext'];
        var TalentStackedStars = MSU.getSettingValue("mod_better_obituary", "StackedStars");
        var statOrder = this.getStatOrder();
        var talentPrefix = TalentStackedStars ? 'BO_stacked_talent_' : 'BO_talent_';

        var statWidth = !TalentStackedStars ? '6.5rem' : '';
        var iconWidth = !TalentStackedStars ? '3.6rem' : '';

        for (var i = 0; i < statsLabels.length; i++) 
        {
            var statClass = statsLabels[i];
            var statValue = _data.stats[i];
            var talentIndex = _data.talents[i];

            var statDiv = $('<div class="' + statClass + ' text-font-normal font-color-description">').append(statValue);

            if (!TalentStackedStars) {
                statDiv[0].style.setProperty('width', statWidth, 'important');
            }

            var star = $('<img/>').attr('src', Path.GFX + 'ui/icons/' + talentPrefix + talentIndex + '.png');
            if (!TalentStackedStars) {
                star[0].style.setProperty('width', iconWidth, 'important');
            }
            statDiv.append(star);

            var leftRem = 119 + (statOrder[i] * 7.2);
            statDiv[0].style.setProperty('left', leftRem + 'rem', 'important');

            result.append(statDiv);
        }

        // Traits
        var show_traits = MSU.getSettingValue("mod_better_obituary", "show_traits");
        var traitsGroup = $('<div class="trait-group"></div>');
        for (var i = 0; i < show_traits; i++)
        {
            var trait = _data.traits[i];
            if (trait) 
            {
                if (trait.icon && trait.id) 
                {
                    var img = $('<img/>')
                        .attr('src', Path.GFX + trait.icon)
                        .attr('id', trait.id);
                    traitsGroup.append(img);
                    img.bindTooltip({ contentType: 'ui-element', elementId: trait.id });
                } 
                else 
                {
                    traitsGroup.append($('<img/>').attr('src', Path.GFX + trait));
                }
            }
        }
        result.append(traitsGroup);

        // Perm Injuries
        var show_perminjuries = MSU.getSettingValue("mod_better_obituary", "show_perminjuries");
        var perminjuryGroup = $('<div class="perminjury-group"></div>');
        for (var i = 0; i < show_perminjuries; i++) 
        {
            var injury = _data.perminjuries[i];
            if (injury) 
            {
                if (injury.icon && injury.id) 
                {
                    var img = $('<img/>')
                        .attr('src', Path.GFX + injury.icon)
                        .attr('id', injury.id);
                    perminjuryGroup.append(img);
                    img.bindTooltip({ contentType: 'ui-element', elementId: injury.id });
                } 
                else 
                {
                    perminjuryGroup.append($('<img/>').attr('src', Path.GFX + injury));
                }
            }
        }
        result.append(perminjuryGroup);

        // TODO: Perks (need to regig Ui to fit)
    }
};


WorldObituaryScreen.prototype.bindTooltips = function ()
{
	this.mColumnName.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldScreen.Obituary.ColumnName });
	this.mColumnTime.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldScreen.Obituary.ColumnTime });
	this.mColumnBattles.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldScreen.Obituary.ColumnBattles });
	this.mColumnKills.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldScreen.Obituary.ColumnKills });
	this.mColumnKilledBy.bindTooltip({ contentType: 'ui-element', elementId: TooltipIdentifier.WorldScreen.Obituary.ColumnKilledBy });
	this.mLevel.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.Level' });
	this.mTraits.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.Traits' });
	this.mPermInjuries.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.PermInjuries' });
	this.mHP.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.HP' });
	this.mFT.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.FT' });
	this.mBR.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.BR' });
	this.mIT.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.IT' });
	this.mMA.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.MA' });
	this.mRA.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.RA' });
	this.mMD.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.MD' });
	this.mRD.bindTooltip({ contentType: 'ui-element', elementId: 'world-screen.obituary.RD' });
};

WorldObituaryScreen.prototype.unbindTooltips = function ()
{
	this.mColumnName.unbindTooltip();
	this.mColumnTime.unbindTooltip();
	this.mColumnBattles.unbindTooltip();
	this.mColumnKills.unbindTooltip();
	this.mColumnKilledBy.unbindTooltip();
	this.mLevel.unbindTooltip();
	this.mTraits.unbindTooltip();
	this.mPermInjuries.unbindTooltip();
	this.mHP.unbindTooltip();
	this.mFT.unbindTooltip();
	this.mBR.unbindTooltip();
	this.mIT.unbindTooltip();
	this.mMA.unbindTooltip();
	this.mRA.unbindTooltip();
	this.mMD.unbindTooltip();
	this.mRD.unbindTooltip();
};


WorldObituaryScreen.prototype.create = function(_parentDiv)
{
    this.createDIV(_parentDiv);
    this.bindTooltips();
};

WorldObituaryScreen.prototype.destroy = function()
{
    this.unbindTooltips();
    this.destroyDIV();
};


WorldObituaryScreen.prototype.register = function (_parentDiv)
{
    console.log('WorldObituaryScreen::REGISTER');

    if (this.mContainer !== null)
    {
        console.error('ERROR: Failed to register Relations Screen. Reason: Already initialized.');
        return;
    }

    if (_parentDiv !== null && typeof(_parentDiv) == 'object')
    {
        this.create(_parentDiv);
    }
};

WorldObituaryScreen.prototype.unregister = function ()
{
    console.log('WorldObituaryScreen::UNREGISTER');

    if (this.mContainer === null)
    {
        console.error('ERROR: Failed to unregister Relations Screen. Reason: Not initialized.');
        return;
    }

    this.destroy();
};

WorldObituaryScreen.prototype.isRegistered = function ()
{
    if (this.mContainer !== null)
    {
        return this.mContainer.parent().length !== 0;
    }

    return false;
};


WorldObituaryScreen.prototype.show = function (_data)
{
    this.loadFromData(_data);

	if(!this.mIsVisible)
	{
		var self = this;

		var withAnimation = true;//(_data !== undefined && _data['withSlideAnimation'] !== null) ? _data['withSlideAnimation'] : true;
		if (withAnimation === true)
		{
			var offset = -(this.mContainer.parent().width() + this.mContainer.width());
			this.mContainer.css({ 'left': offset });
			this.mContainer.velocity("finish", true).velocity({ opacity: 1, left: '0', right: '0' }, {
				duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
				easing: 'swing',
				begin: function () {
					$(this).removeClass('display-none').addClass('display-block');
					self.notifyBackendOnAnimating();
				},
				complete: function () {
					self.mIsVisible = true;
					self.notifyBackendOnShown();
				}
			});
		}
		else
		{
			this.mContainer.css({ opacity: 0 });
			this.mContainer.velocity("finish", true).velocity({ opacity: 1 }, {
				duration: Constants.SCREEN_FADE_IN_OUT_DELAY,
				easing: 'swing',
				begin: function() {
					$(this).removeClass('display-none').addClass('display-block');
					self.notifyBackendOnAnimating();
				},
				complete: function() {
					self.mIsVisible = true;
					self.notifyBackendOnShown();
				}
			});
		}
	}
};

WorldObituaryScreen.prototype.hide = function (_withSlideAnimation)
{
    var self = this;

    var withAnimation = true;//(_withSlideAnimation !== undefined && _withSlideAnimation !== null) ? _withSlideAnimation : true;
    if (withAnimation === true)
    {
        var offset = -(this.mContainer.parent().width() + this.mContainer.width());
        this.mContainer.velocity("finish", true).velocity({ opacity: 0, left: offset },
		{
            duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
            easing: 'swing',
            begin: function ()
            {
                $(this).removeClass('is-center');
                self.notifyBackendOnAnimating();
            },
            complete: function ()
            {
            	self.mIsVisible = false;
            	self.mListScrollContainer.empty();
                $(this).removeClass('display-block').addClass('display-none');
                self.notifyBackendOnHidden();
            }
        });
    }
    else
    {
    	this.mContainer.velocity("finish", true).velocity({ opacity: 0 },
		{
            duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
            easing: 'swing',
            begin: function ()
            {
                $(this).removeClass('is-center');
                self.notifyBackendOnAnimating();
            },
            complete: function ()
            {
                self.mIsVisible = false;
                self.mListScrollContainer.empty();
                $(this).removeClass('display-block').addClass('display-none');
                self.notifyBackendOnHidden();
            }
        });
    }
};

WorldObituaryScreen.prototype.isVisible = function ()
{
    return this.mIsVisible;
};


WorldObituaryScreen.prototype.loadFromData = function (_data)
{
    if(_data === undefined || _data === null)
    {
        return;
    }

    this.mListScrollContainer.empty();

    if(_data.Fallen.length == 0)
    	this.mDialogContainer.findDialogSubTitle().text('No one has fallen since you took command');
    else if(_data.Fallen.length == 1)
		this.mDialogContainer.findDialogSubTitle().text('A single man has fallen since you took command');
    else
    	this.mDialogContainer.findDialogSubTitle().text('' + _data.Fallen.length + ' men have fallen since you took command');
	
	for(var i = 0; i < _data.Fallen.length; ++i)
    {
		this.addListEntry(_data.Fallen[i]);
    }
};

WorldObituaryScreen.prototype.notifyBackendOnConnected = function ()
{
	if(this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenConnected');
	}
};

WorldObituaryScreen.prototype.notifyBackendOnDisconnected = function ()
{
	if(this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenDisconnected');
	}
};

WorldObituaryScreen.prototype.notifyBackendOnShown = function ()
{
    if(this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onScreenShown');
    }
};

WorldObituaryScreen.prototype.notifyBackendOnHidden = function ()
{
    if(this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onScreenHidden');
    }
};

WorldObituaryScreen.prototype.notifyBackendOnAnimating = function ()
{
    if(this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onScreenAnimating');
    }
};

WorldObituaryScreen.prototype.notifyBackendCloseButtonPressed = function (_buttonID)
{
    if(this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onClose', _buttonID);
    }
};