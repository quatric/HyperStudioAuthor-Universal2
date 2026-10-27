#import "HSExportPanelController.h"

@implementation HSExportPanelController

// Ends the sheet, then calls the modal delegate's did-end selector with the
// return code filled in.
- (BOOL)isExpanded
{
    return YES;
}

- (void)setRequiredFileType:(id)aType
{
    if (![_requiredFileType isEqualToString:aType]) {
        [_requiredFileType release];
        _requiredFileType = [aType retain];
    }
}

- (id)requiredFileType
{
    return _requiredFileType;
}

- (void)setAccessoryViewController:(id)aController
{
    if (_accessoryViewController != aController) {
        [_accessoryViewController release];
        _accessoryViewController = [aController retain];
    }
}

- (id)accessoryViewController
{
    return _accessoryViewController;
}

// Swaps the accessory view and resizes the window by the difference between
// the new view and the container.
- (void)setAccessoryView:(id)aView
{
    if ([self accessoryView] != aView) {
        [_accessoryViewController viewWillAppear:NO];
        NSRect windowFrame = [[self window] frame];
        NSRect containerFrame = [_accessoryViewContainer frame];
        NSRect viewFrame = [aView frame];
        [_accessoryViewContainer setContentView:aView];
        windowFrame.size.width = (viewFrame.size.width - containerFrame.size.width) + windowFrame.size.width;
        windowFrame.size.height = (viewFrame.size.height - containerFrame.size.height) + windowFrame.size.height;
        [[self window] setFrame:windowFrame display:YES animate:YES];
    }
}

- (id)accessoryView
{
    return [_accessoryViewContainer contentView];
}

- (void)dealloc
{
    [_requiredFileType release];
    [_accessoryViewController release];
    [super dealloc];
}

@end
