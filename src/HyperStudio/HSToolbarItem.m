#import "HSToolbarItem.h"

@implementation HSToolbarItem

// Copies of popup items keep the item images and go back to regular size.
- (id)copyWithZone:(NSZone *)aZone
{
    id copy = [super copyWithZone:aZone];
    if ([[self view] isKindOfClass:[HSBackgroundPopUpButton class]]) {
        id copyView = [copy view];
        id view = [self view];
        [copyView setRegularImage:[view regularImage]];
        [copyView setSmallImage:[view smallImage]];
        [copyView setMiniImage:[view miniImage]];
        [copyView setControlSize:NSControlSizeRegular];
    }
    return copy;
}

- (void)validate
{
    if ([[self toolbar] customizationPaletteIsRunning])
        return;
    [super validate];
    [self validateView:[self view]];
    [self setDisplayMode:[[self toolbar] displayMode]];
}

// Validates controls through the responder chain; actionless matrices are
// validated cell by cell.
- (void)validateView:(id)aView
{
    if (![aView isKindOfClass:[NSControl class]]) {
        NSEnumerator *enumerator = [[aView subviews] objectEnumerator];
        id subview;
        while ((subview = [enumerator nextObject]) != nil)
            [self validateView:subview];
        return;
    }
    if (![aView isKindOfClass:[NSMatrix class]] || [aView action] != NULL) {
        SEL action = [(NSControl *)aView action];
        id target = [NSApp targetForAction:action to:[(NSControl *)aView target] from:self];
        BOOL enabled;
        if (target == nil || ![target respondsToSelector:action])
            enabled = NO;
        else if ([target respondsToSelector:@selector(validateToolbarItem:)])
            enabled = [target validateToolbarItem:self];
        else if ([target respondsToSelector:@selector(validateUserInterfaceItem:)])
            enabled = [target validateUserInterfaceItem:self];
        else
            enabled = YES;
        [self setEnabled:enabled];
        [aView setEnabled:enabled];
        return;
    }
    NSEnumerator *enumerator = [[aView cells] objectEnumerator];
    // Original quirk kept: a cell whose target validates nothing inherits the previous cell's state.
    BOOL enabled = YES;
    id cell;
    while ((cell = [enumerator nextObject]) != nil) {
        SEL action = [(NSCell *)cell action];
        id target = [NSApp targetForAction:action to:[(NSCell *)cell target] from:self];
        if (target == nil || ![target respondsToSelector:action])
            enabled = NO;
        else if ([target respondsToSelector:@selector(validateCell:ofToolbarItem:)])
            enabled = [target validateCell:cell ofToolbarItem:self];
        else if ([target respondsToSelector:@selector(validateUserInterfaceItem:)])
            enabled = [target validateUserInterfaceItem:cell];
        [cell setEnabled:enabled];
    }
}

- (BOOL)isTextOnlyMode
{
    return _isTextOnlyMode;
}

- (void)setTextOnlyMode:(BOOL)aMode
{
    if (_isTextOnlyMode != aMode) {
        _isTextOnlyMode = aMode;
        [self setImagesToSubMenuItems:!aMode];
    }
}

- (void)setDisplayMode:(NSToolbarDisplayMode)aMode
{
    [self setTextOnlyMode:aMode == NSToolbarDisplayModeLabelOnly];
}

- (void)setEnabled:(BOOL)aEnabled
{
    [self setEnabled:aEnabled view:[self view]];
    [super setEnabled:aEnabled];
    [[self menuFormRepresentation] setEnabled:aEnabled];
}

- (void)setEnabled:(BOOL)aEnabled view:(id)aView
{
    if (![aView isKindOfClass:[NSControl class]]) {
        NSEnumerator *enumerator = [[aView subviews] objectEnumerator];
        id subview;
        while ((subview = [enumerator nextObject]) != nil)
            [self setEnabled:aEnabled view:subview];
    } else {
        [aView setEnabled:aEnabled];
    }
}

- (void)setImagesToSubMenuItems:(BOOL)aItems
{
    NSMenuItem *menuItem = [self menuFormRepresentation];
    if ([menuItem hasSubmenu]) {
        for (NSMenuItem *item in [[menuItem submenu] itemArray])
            [item setImage:aItems ? [item representedObject] : nil];
    }
}

@end
