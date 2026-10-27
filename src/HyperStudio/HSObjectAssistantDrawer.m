#import "HSObjectAssistantDrawer.h"

// Shadow margin around the assistant window.
static const float kHSAssistantWindowMargin = 16.0f;

@implementation HSObjectAssistantDrawer

- (void)toggle:(id)aToggle
{
}

- (void)close:(id)aClose
{
    [[self window] setFrame:[self standByFrame] display:YES animate:YES];
    [[[self objectAssistant] window] removeChildWindow:[self window]];
    [[self window] close];
}

// Slides out from behind the assistant window to its right.
- (void)open:(id)aOpen
{
    NSRect frame = [self standByFrame];
    [[self window] setFrame:frame display:YES animate:NO];
    [[[self objectAssistant] window] addChildWindow:[self window] ordered:NSWindowBelow];
    [[self window] setFrame:NSOffsetRect(frame, frame.size.width + 30.0f - kHSAssistantWindowMargin - 6.0f, 0.0) display:YES animate:YES];
}

- (NSRect)standByFrame
{
    NSRect frame = [[[self objectAssistant] window] frame];
    return NSInsetRect(frame, kHSAssistantWindowMargin + 15.0f, kHSAssistantWindowMargin + 15.0f);
}

- (NSInteger)preferredSide
{
    return 0;
}

- (void)setContentView:(id)aView
{
    if (_contentView != aView) {
        [_contentView release];
        _contentView = [aView retain];
    }
}

- (id)contentView
{
    return _contentView;
}

- (id)window
{
    if (_window == nil) {
        NSRect frame = NSInsetRect([[[self objectAssistant] window] frame], kHSAssistantWindowMargin + 15.0f, kHSAssistantWindowMargin + 15.0f);
        _window = (NSPanel *)[[NSWindow alloc] initWithContentRect:frame styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        [_window setHidesOnDeactivate:YES];
        [_window setOpaque:NO];
        [_window setBackgroundColor:[NSColor clearColor]];
        [_window setHasShadow:YES];
        [_window setReleasedWhenClosed:NO];
        HSTexturedView *background = [[HSTexturedView alloc] initWithFrame:frame];
        [background setImage:[NSImage imageNamed:@"drawer_top"] forType:1];
        [background setImage:[NSImage imageNamed:@"drawer_top_left"] forType:0];
        [background setImage:[NSImage imageNamed:@"drawer_top_right"] forType:2];
        [background setImage:[NSImage imageNamed:@"drawer_center"] forType:4];
        [background setImage:[NSImage imageNamed:@"drawer_left"] forType:3];
        [background setImage:[NSImage imageNamed:@"drawer_right"] forType:5];
        [background setImage:[NSImage imageNamed:@"drawer_bottom"] forType:7];
        [background setImage:[NSImage imageNamed:@"drawer_bottom_left"] forType:6];
        [background setImage:[NSImage imageNamed:@"drawer_bottom_right"] forType:8];
        [_window setContentView:background];
        [background release];
        _containerView = [[NSView alloc] initWithFrame:NSMakeRect(6.0, 3.0, frame.size.width - 12.0f, frame.size.height - 6.0f)];
        [[_window contentView] addSubview:_containerView];
        [_containerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [[self contentView] setFrame:[_containerView bounds]];
        [_containerView addSubview:[self contentView]];
        [(NSView *)[self contentView] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }
    return _window;
}

- (void)setObjectAssistant:(id)aAssistant
{
    if (_objectAssistant != aAssistant)
        _objectAssistant = aAssistant;
}

- (id)objectAssistant
{
    return _objectAssistant;
}

- (void)dealloc
{
    [_window release];
    [_contentView release];
    [_containerView release];
    [super dealloc];
}

- (id)initWithContentView:(id)aView objectAssistant:(id)aAssistant
{
    self = [super init];
    if (self != nil) {
        [self setObjectAssistant:aAssistant];
        [self setContentView:aView];
    }
    return self;
}

- (void)hideContent
{
    [[self window] orderOut:nil];
}

- (void)showContent
{
    [[self window] orderFront:nil];
}

@end

@implementation HSObjectAssistant (HSObjectAssistantDrawerSupport)

- (void)setDrawer:(id)aDrawer
{
    if (_drawer != aDrawer) {
        [_drawer close:self];
        [_drawer release];
        _drawer = [aDrawer retain];
    }
}

@end
