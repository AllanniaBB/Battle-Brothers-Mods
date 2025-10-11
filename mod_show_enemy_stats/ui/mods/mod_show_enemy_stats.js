"use strict";

// Store original function reference
var originalAddContentProgressbarDiv = TooltipModule.prototype.addContentProgressbarDiv;

TooltipModule.prototype.addContentProgressbarDiv = function(_parentDIV, _data) {

    // Call original function
    var container = originalAddContentProgressbarDiv.call(this, _parentDIV, _data);
    
    // Find progress bar text container
    var progressbarText = container.find('.progressbar-label');

    // Modify progress bar to show values like brothers
    if ('value' in _data && 'valueMax' in _data) {
        var parsedText = _data.value + " / " + _data.valueMax; // New text format
        progressbarText.html(parsedText); // Apply the new text
    }

    return container;
};
