#import "HSToolsPaletteContentView.h"

@implementation HSToolsPaletteContentView

- (void)resizeDrawerBy:(CGFloat)aBy withAutoresizingMask:(NSUInteger)aMask
{
    NSRect frame = [[self window] frame];
    frame.origin.y += aBy;
    frame.size.height -= aBy;
    NSUInteger mask = [_drawerContentView autoresizingMask];
    [_drawerContentView setAutoresizingMask:aMask];
    [self setNewWindowFrame:frame];
    [_drawerContentView setAutoresizingMask:mask];
}

- (void)hideDrawer:(id)aDrawer
{
    if (!_drawerIsOpen)
        return;
    [self updateImagesForDrawerState:NO];
    [_drawerContentView setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
    NSRect contentFrame = [_drawerContentView frame];
    NSRect frame = [[self window] frame];
    CGFloat delta = contentFrame.origin.y + contentFrame.size.height;
    frame.origin.y += delta;
    frame.size.height -= delta;
    [self setNewWindowFrame:frame];
    [_drawerContentView removeFromSuperview];
    _drawerIsOpen = NO;
}

- (void)showDrawer:(id)aDrawer
{
    if (_drawerIsOpen)
        return;
    [self updateImagesForDrawerState:YES];
    [_drawerContentView setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
    [self addDrawerContentViewToDrawerView];
    NSRect contentFrame = [_drawerContentView frame];
    NSRect frame = [[self window] frame];
    CGFloat delta = contentFrame.origin.y + contentFrame.size.height;
    frame.origin.y -= delta;
    frame.size.height += delta;
    [self setNewWindowFrame:frame];
    _drawerIsOpen = YES;
}

- (BOOL)drawerIsOpen
{
    return _drawerIsOpen;
}

- (void)setDrawerContentView:(id)aView
{
    if (_drawerContentView == aView)
        return;
    NSView *oldView = [_drawerContentView retain];
    [_drawerContentView release];
    _drawerContentView = [aView retain];
    CGFloat windowHeight = [[self window] frame].size.height;
    NSRect knobFrame = [_knobView frame];
    NSRect contentFrame = [_drawerContentView frame];
    CGFloat neededHeight = contentFrame.origin.y + contentFrame.size.height + knobFrame.origin.y + knobFrame.size.height;
    if (_drawerIsOpen && neededHeight < windowHeight) {
        NSUInteger mask = [oldView autoresizingMask];
        [oldView setAutoresizingMask:NSViewMinYMargin];
        [self resizeDrawerBy:windowHeight - neededHeight withAutoresizingMask:NSViewMinYMargin];
        [oldView setAutoresizingMask:mask];
    }
    [oldView removeFromSuperview];
    if (_drawerIsOpen) {
        [self addDrawerContentViewToDrawerView];
        if (windowHeight <= neededHeight)
            [self resizeDrawerBy:windowHeight - neededHeight withAutoresizingMask:NSViewMinYMargin];
    }
    [oldView release];
}

- (void)addDrawerContentViewToDrawerView
{
    NSRect drawerFrame = [_drawerView frame];
    NSRect contentFrame = [_drawerContentView frame];
    [_drawerContentView setFrame:NSMakeRect(3.0, 0.0, drawerFrame.size.width - 6.0, contentFrame.size.height)];
    [_drawerView addSubview:_drawerContentView];
}

- (void)setNewWindowFrame:(NSRect)aFrame
{
    NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
    if (aFrame.origin.y < visibleFrame.origin.y)
        aFrame.origin.y = visibleFrame.origin.y;
    [[self window] setFrame:aFrame display:YES animate:YES];
}

- (void)awakeFromNib
{
    [_mainView setImage:[NSImage imageNamed:@"Head_Left_Top"] forType:0];
    [_mainView setImage:[NSImage imageNamed:@"Head_Right_Top"] forType:2];
    [_mainView setImage:[NSImage imageNamed:@"Head_Center_Top"] forType:1];
    [_mainView setImage:[NSImage imageNamed:@"Head_Center_Center"] forType:4];
    [_mainView setImage:[NSImage imageNamed:@"Head_Left_Center"] forType:3];
    [_mainView setImage:[NSImage imageNamed:@"Head_Right_Center"] forType:5];
    [_mainView setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [_drawerView setImage:[NSImage imageNamed:@"Drawer_Center_Top"] forType:1];
    [_drawerView setImage:[NSImage imageNamed:@"Drawer_Center_Center"] forType:4];
    [_drawerView setImage:[NSImage imageNamed:@"Drawer_Right_Center"] forType:5];
    [_drawerView setImage:[NSImage imageNamed:@"Drawer_Left_Center"] forType:3];
    [_drawerView setImage:[NSImage imageNamed:@"Drawer_Left_Top"] forType:0];
    [_drawerView setImage:[NSImage imageNamed:@"Drawer_Right_Top"] forType:2];
    [_drawerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self updateImagesForDrawerState:NO];
    [_knobView setAutoresizingMask:NSViewMaxXMargin | NSViewMinYMargin];
}

- (void)updateImagesForDrawerState:(BOOL)aState
{
    if (aState)
        [self setImagesForOpenedDrawer];
    else
        [self setImagesForClosedDrawer];
}

- (void)setImagesForClosedDrawer
{
    [_mainView setImage:[NSImage imageNamed:@"Head_Center_Bottom_off"] forType:7];
    [_mainView setImage:[NSImage imageNamed:@"Head_Left_Bottom_off"] forType:6];
    [_mainView setImage:[NSImage imageNamed:@"Head_Right_Bottom_off"] forType:8];
    [_knobView setImage:[NSImage imageNamed:@"Down_Left_off"] forType:6];
    [_knobView setImage:[NSImage imageNamed:@"Down_Right_off"] forType:8];
    [_knobView setImage:[NSImage imageNamed:@"Down_Center_off"] forType:7];
}

- (void)setImagesForOpenedDrawer
{
    [_mainView setImage:[NSImage imageNamed:@"Head_Center_Bottom"] forType:7];
    [_mainView setImage:[NSImage imageNamed:@"Head_Left_Bottom"] forType:6];
    [_mainView setImage:[NSImage imageNamed:@"Head_Right_Bottom"] forType:8];
    [_knobView setImage:[NSImage imageNamed:@"Down_Left"] forType:6];
    [_knobView setImage:[NSImage imageNamed:@"Down_Right"] forType:8];
    [_knobView setImage:[NSImage imageNamed:@"Down_Center"] forType:7];
}

- (void)dealloc
{
    [_mainView release];
    [_drawerView release];
    [_knobView release];
    [_drawerContentView release];
    [super dealloc];
}

@end
