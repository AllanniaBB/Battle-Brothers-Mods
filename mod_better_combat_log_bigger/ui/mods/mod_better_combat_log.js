{
	
	TacticalScreenTopbarEventLogModule.prototype.Extend = function()
	{
		this.mExtendedHeight = '82.0rem';
	}
	
	TacticalScreenTopbarEventLogModule.prototype.Shrink = function()
	{
		this.mExtendedHeight = '12.4rem';
	}
	
	TacticalScreenTopbarEventLogModule.prototype.createDIV = function (_parentDiv)
	{
		var self = this;
		
		this.Extend();
		//this.Shrink();

		// create: container
		this.mContainer = $('<div class="topbar-event-log-module"/>');
		_parentDiv.append(this.mContainer);

		// create: log container
		var eventLogsContainerLayout = $('<div class="l-event-logs-container"/>');
		this.mContainer.append(eventLogsContainerLayout);
		this.mEventsListContainer = eventLogsContainerLayout.createList(15);
		this.mEventsListScrollContainer = this.mEventsListContainer.findListScrollContainer();

		// create: button
		var layout = $('<div class="l-expand-button"/>');
		this.mContainer.append(layout);
		this.ExpandButton = layout.createImageButton(Path.GFX + Asset.BUTTON_OPEN_EVENTLOG, function ()
		{
			self.expand(!self.mIsExpanded);
		}, '', 6);
		this.mIsExpanded = false
		this.expand(true); // start expanded
	}
}