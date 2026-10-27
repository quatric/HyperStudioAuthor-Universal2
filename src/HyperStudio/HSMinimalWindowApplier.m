#import "HSMinimalWindowApplier.h"

@implementation HSMinimalWindowApplier

- (void)setSupportsMinimalWindowMode:(BOOL)aMode
{
    if (_doesntSupportMinimalWindowMode != !aMode) {
        _doesntSupportMinimalWindowMode = !aMode;
        _minimalWindowModeStatusIsChangingBecauseOfSupport = YES;
        [self applyProperWindowModeIfNeeded];
        _minimalWindowModeStatusIsChangingBecauseOfSupport = NO;
    }
}

- (BOOL)supportsMinimalWindowMode
{
    return !_doesntSupportMinimalWindowMode;
}

- (void)setIsInMinimalWindowMode:(BOOL)aMode
{
    if (_isInMinimalWindowMode != (aMode != NO)) {
        _isInMinimalWindowMode = aMode != NO;
        [self applyProperWindowModeIfNeeded];
    }
}

- (BOOL)isInMinimalWindowMode
{
    return _isInMinimalWindowMode;
}

- (void)applyProperWindowModeIfNeeded
{
    BOOL minimal = _isInMinimalWindowMode;
    if (_doesntSupportMinimalWindowMode)
        minimal = NO;
    [self setMinimalWindowModeApplied:minimal];
}

- (void)setMinimalWindowModeApplied:(BOOL)aApplied
{
    if (_isMinimalWindowModeApplied != (aApplied != NO)) {
        if (aApplied)
            [self applyMinimalWindowMode];
        else
            [self applyFullWindowMode];
    }
}

- (BOOL)isMinimalWindowModeApplied
{
    return _isMinimalWindowModeApplied;
}

// Brings back the toolbar, bottom toolbar and window size stored when the
// minimal mode was applied (unless only the support for it changed).
- (void)applyFullWindowMode
{
    id controller = [[self window] windowController];
    if ([controller respondsToSelector:@selector(setBottomToolbarVisible:)])
        [controller setBottomToolbarVisible:YES];
    [[self cardView] setHasEdgeShadowView:YES];
    if (!_minimalWindowModeStatusIsChangingBecauseOfSupport) {
        NSMutableDictionary *settings = [self fullWindowModeSettings];
        id visibility = [settings objectForKey:@"HSStoredToolbarVisibility"];
        if (visibility)
            [[[self window] toolbar] setVisible:[visibility intValue]];
        id sizeValue = [settings objectForKey:@"HSStoredWindowFrameSize"];
        if (sizeValue) {
            NSRect frame = [[self window] frame];
            CGFloat top = frame.origin.y + frame.size.height;
            frame.size = [sizeValue sizeValue];
            frame.origin.y = top - frame.size.height;
            [[self window] setFrame:frame display:YES];
        }
    }
    [_mediaStripSwitcher showStrip:self];
    _isMinimalWindowModeApplied = NO;
}

// Hides the strip and toolbars and shrinks the window to the card, keeping
// its top edge.
- (void)applyMinimalWindowMode
{
    NSWindow *window = [self window];
    NSRect windowFrame = [window frame];
    id controller = [window windowController];
    if ([controller respondsToSelector:@selector(setBottomToolbarVisible:)])
        [controller setBottomToolbarVisible:NO];
    [[self cardView] setHasEdgeShadowView:NO];
    [_mediaStripSwitcher hideStrip:self];
    NSMutableDictionary *settings = [self fullWindowModeSettings];
    if (!_minimalWindowModeStatusIsChangingBecauseOfSupport) {
        [settings setObject:[NSValue valueWithSize:windowFrame.size] forKey:@"HSStoredWindowFrameSize"];
        [settings setObject:[[window toolbar] isVisible] ? @"1" : @"0" forKey:@"HSStoredToolbarVisibility"];
        [[window toolbar] setVisible:NO];
        NSRect viewingRect = [[self cardView] convertRect:[[self cardView] cardViewingRect] toView:nil];
        NSRect frame = [window frame];
        CGFloat top = frame.origin.y + frame.size.height;
        NSRect contentRect = NSMakeRect(frame.origin.x, frame.origin.y, viewingRect.size.width, viewingRect.size.height);
        NSRect newFrame = [NSWindow frameRectForContentRect:contentRect styleMask:[window styleMask]];
        NSSize minSize = [window minSize];
        CGFloat width = MAX(minSize.width, newFrame.size.width);
        CGFloat height = MAX(minSize.height, newFrame.size.height);
        [window setFrame:NSMakeRect(frame.origin.x, top - height, width, height) display:YES];
    }
    _isMinimalWindowModeApplied = YES;
}

- (void)replaceCardView:(id)aView
{
    if (_cardView != aView) {
        [_cardView setHasEdgeShadowView:YES];
        [_cardView release];
        _cardView = [aView retain];
        [_cardView setHasEdgeShadowView:!_isMinimalWindowModeApplied];
    }
}

- (void)setupWithWorkAreaView:(id)aView cardWorkAreaView:(id)aView2 statusBarContainerView:(id)aView3 cardScrollView:(id)aView4 mediaStripSwitcher:(id)aSwitcher
{
    _workAreaView = [aView retain];
    _cardWorkAreaView = [aView2 retain];
    _statusBarContainerView = [aView3 retain];
    _mediaStripSwitcher = [aSwitcher retain];
    _cardScrollView = [aView4 retain];
}

- (id)cardView
{
    return [[_cardView retain] autorelease];
}

- (id)window
{
    return [[_window retain] autorelease];
}

- (id)fullWindowModeSettings
{
    if (!_fullWindowModeSettings)
        _fullWindowModeSettings = [NSMutableDictionary new];
    return _fullWindowModeSettings;
}

- (void)dealloc
{
    [_fullWindowModeSettings release];
    [_window autorelease];
    [_cardView release];
    [_workAreaView release];
    [_cardWorkAreaView release];
    [_statusBarContainerView release];
    [_mediaStripSwitcher release];
    [_cardScrollView release];
    [super dealloc];
}

- (id)init
{
    return [self initWithWindow:nil cardView:nil];
}

- (id)initWithWindow:(id)aWindow cardView:(id)aView
{
    self = [super init];
    if (self) {
        _window = [aWindow retain];
        _cardView = [aView retain];
    }
    return self;
}

@end
