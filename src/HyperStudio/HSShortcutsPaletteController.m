#import "HSShortcutsPaletteController.h"

@implementation HSShortcutsPaletteController

// Mirrors the current document's toolbar as a vertical column of buttons, keeping the window's top edge in place.
- (void)rebuildShortcutsIfNeeded
{
    if ([[HSApplicationController sharedDocumentController] currentDocument] == nil)
        return;
    NSToolbar *toolbar = [[[[[HSApplicationController sharedDocumentController] currentDocument] currentWindowController] toolbarController] toolbar];
    NSMutableArray *items = [self filteredToolbarItems:[NSMutableArray arrayWithArray:[toolbar items]]];
    if (![self needUpdateToolbarItems:items withItems:[self toolbarItems]])
        return;
    [[self toolbarItems] removeAllObjects];

    NSRect frame = [[self window] frameRectForContentRect:[self viewFrameForButtonsCount:[items count]]];
    if (_firstTimeLaunch) {
        frame.origin = [[self window] frame].origin;
        _firstTimeLaunch = NO;
    }
    else {
        NSRect oldFrame = [[self window] frame];
        frame.origin.x = oldFrame.origin.x;
        frame.origin.y = oldFrame.origin.y + oldFrame.size.height - frame.size.height;
    }
    [[self window] setFrame:frame display:YES animate:YES];
    [[_containerView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_containerView setFrame:[self viewFrameForButtonsCount:[items count]]];

    NSInteger index = 0;
    CGFloat y = 2.0f;
    for (NSToolbarItem *item in [items reverseObjectEnumerator]) {
        NSRect itemFrame = [self frameForItemIndex:index origin:NSMakePoint(2.0, y)];
        if ([item isKindOfClass:[HSToolbarItem class]]) {
            NSToolbarItem *copy = [item copy];
            NSView *container = [[NSView alloc] initWithFrame:NSInsetRect(itemFrame, -2.0, -2.0)];
            NSView *view = [copy view];
            NSRect viewFrame = [view frame];
            [view setFrame:NSMakeRect(ceilf(([container frame].size.width - viewFrame.size.width) * 0.5f), 23.0, viewFrame.size.width, viewFrame.size.height)];
            [container addSubview:view];
            NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(4.0, 4.0, [container frame].size.width - 8.0f, 14.0)];
            [label setEditable:NO];
            [label setSelectable:NO];
            [label setEnabled:YES];
            [label setBezeled:NO];
            [label setAlignment:NSTextAlignmentCenter];
            [label setBackgroundColor:[NSColor windowBackgroundColor]];
            [label setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
            [label setStringValue:[item label]];
            HSButton *button = [[HSButton alloc] initWithFrame:[self frameForItemIndex:index origin:NSMakePoint(2.0, y)]];
            [[button cell] setBackgroundRenderer:[HSShortcutsPaletteButtonBackgroundRenderer sharedBackgroundRenderer]];
            [button setTitle:@""];
            [container addSubview:label];
            [_containerView addSubview:button];
            [_containerView addSubview:container];
            [container release];
            [button release];
            [label release];
            [copy release];
        }
        else {
            HSButton *button = [[HSButton alloc] initWithFrame:itemFrame];
            [[button cell] setBackgroundRenderer:[HSShortcutsPaletteButtonBackgroundRenderer sharedBackgroundRenderer]];
            [[button cell] setButtonType:NSButtonTypeMomentaryLight];
            [[button cell] setImagePosition:NSImageAbove];
            [[button cell] setAlignment:NSTextAlignmentCenter];
            [[button cell] setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSFont systemFontOfSize:[NSFont smallSystemFontSize]], NSFontAttributeName,
                [NSParagraphStyle hyperParagraphStyleWithAlignment:NSTextAlignmentCenter lineBreakMode:NSLineBreakByTruncatingTail], NSParagraphStyleAttributeName, nil];
            NSAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[item label] attributes:attributes];
            [[button cell] setAttributedTitle:title];
            [[button cell] setImage:[item image]];
            [button setAction:[item action]];
            [button setTarget:[item target]];
            [_containerView addSubview:button];
            [button release];
            [title release];
        }
        [[self toolbarItems] addObject:item];
        index++;
        y += 53.0f + 2.0f;
    }
}

- (BOOL)needUpdateToolbarItems:(id)aItems withItems:(id)aItems2
{
    if ([aItems count] != [aItems2 count])
        return YES;
    for (id item in aItems2) {
        if ([aItems indexOfObjectIdenticalTo:item] == NSNotFound)
            return YES;
    }
    return NO;
}

- (id)filteredToolbarItems:(id)aItems
{
    NSArray *items = [aItems copy];
    for (NSToolbarItem *item in items) {
        NSString *identifier = [item itemIdentifier];
        if ([identifier isEqualToString:NSToolbarFlexibleSpaceItemIdentifier] || [identifier isEqualToString:NSToolbarSeparatorItemIdentifier] || [identifier isEqualToString:NSToolbarSpaceItemIdentifier])
            [aItems removeObject:item];
    }
    [items release];
    return aItems;
}

- (NSRect)frameForItemIndex:(NSInteger)aIndex origin:(NSPoint)aOrigin
{
    return NSMakeRect(aOrigin.x, aOrigin.y, 71.0, 53.0);
}

- (NSRect)viewFrameForButtonsCount:(NSInteger)aCount
{
    return NSMakeRect(0.0, 0.0, 75.0, (float)aCount * 55.0f + 2.0f);
}

- (id)toolbarItems
{
    if (_toolbarItems == nil)
        _toolbarItems = [NSMutableArray new];
    return _toolbarItems;
}

- (void)validateView:(id)aView
{
    for (NSView *subview in [aView subviews]) {
        if ([[subview subviews] count] != 0) {
            [self validateView:subview];
        }
        else if ([subview isKindOfClass:[NSMatrix class]] && [(NSMatrix *)subview action] == NULL) {
            for (id cell in [(NSMatrix *)subview cells])
                [self validatePaletteItem:cell];
        }
        else if ([subview isKindOfClass:[NSTextField class]]) {
            [(NSTextField *)subview setEnabled:[[[[[HSApplicationController sharedDocumentController] currentDocument] currentWindowController] window] attachedSheet] == nil];
        }
    }
}

// Validation may retitle a button; the palette keeps its own titles.
- (void)validateToolbarItems
{
    for (id subview in [_containerView subviews]) {
        if ([subview respondsToSelector:@selector(action)]) {
            NSString *title = [subview title];
            [self validatePaletteItem:subview];
            [subview setTitle:title];
        }
        else {
            [self validateView:subview];
        }
    }
}

- (void)validateUserInterface
{
    [self rebuildShortcutsIfNeeded];
    [self validateToolbarItems];
}

- (void)willShowWindow
{
    [super willShowWindow];
    [self validateUserInterface];
}

- (void)didLoadNib
{
    [super didLoadNib];
    [[[self window] standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    [[[self window] standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [[self window] setTitle:@""];
    [[self window] setShowsResizeIndicator:NO];
    _firstTimeLaunch = YES;
}

- (id)nibName
{
    return @"ShortcutsPalette";
}

- (void)dealloc
{
    [_toolbarItems release];
    [super dealloc];
}

@end
