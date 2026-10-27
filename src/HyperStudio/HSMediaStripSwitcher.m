#import "HSMediaStripSwitcher.h"

@interface NSObject (HSMediaStripSwitcherPrivate)
- (void)mediaStripSwitcherDidShowMediaStrip:(id)aSwitcher;
- (void)mediaStripSwitcherWillHideMediaStrip:(id)aSwitcher;
@end

@implementation HSMediaStripSwitcher

- (void)mediaStripViewDidFinishRolling:(id)aRolling
{
    [self makeStripVisible:![self isStripVisible] animate:YES];
}

- (void)hideStripAndEnable:(BOOL)aEnable moveFrame:(BOOL)aFrame
{
    [self makeStripVisible:NO animate:NO moveFrame:aFrame];
    [_stripButton setEnabled:aEnable];
}

- (void)hideStripAndEnable:(BOOL)aEnable
{
    [self makeStripVisible:NO animate:NO];
    [_stripButton setEnabled:aEnable];
}

- (void)showStripAndEnable:(BOOL)aEnable
{
    [_stripButton setEnabled:aEnable];
    [self makeStripVisible:YES animate:NO];
}

- (void)hideStrip:(id)aStrip
{
    [self makeStripVisible:NO animate:YES];
}

- (void)showStrip:(id)aStrip
{
    [self makeStripVisible:YES animate:YES];
}

// Grows or shrinks the window by the strip's width. When shown the strip view
// is added at the left of the window and the window origin moves left (kept on
// screen); when hidden the strip view is removed and the origin moves back.
- (void)makeStripVisible:(BOOL)aVisible animate:(BOOL)aAnimate moveFrame:(BOOL)aFrame
{
    if (_isStripVisible == aVisible)
        return;
    NSWindow *window = [_topmostSuperview window];
    NSRect windowFrame = [[_topmostSuperview window] frame];
    if (!aVisible) {
        _isStripVisible = NO;
        [self notifyWillHideStrip];
        windowFrame.size.width -= _stripWidth;
        if (aFrame)
            windowFrame.origin.x += _stripWidth;
        [_cardView beginLightweightChangeProcessingMode];
        [_stripContainerView setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin];
        [_cardViewContainerView setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin];
        NSSize minSize = [window contentMinSize];
        minSize.width -= _stripWidth;
        [window setContentMinSize:minSize];
        [window setFrame:windowFrame display:YES animate:aAnimate];
        [_stripContainerView removeFromSuperview];
        [_cardViewContainerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_cardViewContainerView setFrame:[_topmostSuperview bounds]];
        [_cardView endLightweightChangeProcessingMode];
    } else {
        windowFrame.size.width += _stripWidth;
        if (aFrame) {
            windowFrame.origin.x -= _stripWidth;
            NSRect visible = [[window screen] visibleFrame];
            if (windowFrame.origin.x < visible.origin.x)
                windowFrame.origin.x = visible.origin.x;
        }
        [_cardView beginLightweightChangeProcessingMode];
        [[_stripScrollView documentView] scrollToTop];
        NSRect cardFrame = [_cardViewContainerView frame];
        [_stripContainerView setFrame:NSMakeRect(-_stripWidth, 0, _stripWidth, NSHeight(cardFrame))];
        [_topmostSuperview addSubview:_stripContainerView];
        [_stripContainerView setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin];
        [_cardViewContainerView setAutoresizingMask:NSViewWidthSizable | NSViewMinXMargin];
        [[_stripScrollView mediaStripView] scrollItemAtIndexToCenter:[[_stripScrollView mediaStripView] selectedItemIndex]];
        NSSize minSize = [window contentMinSize];
        minSize.width += _stripWidth;
        [window setContentMinSize:minSize];
        [window setFrame:windowFrame display:YES animate:aAnimate];
        [_stripContainerView setAutoresizingMask:NSViewMaxXMargin | NSViewHeightSizable];
        [_cardViewContainerView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_cardView endLightweightChangeProcessingMode];
        _isStripVisible = YES;
        [self notifyDidShowStrip];
    }
}

- (void)makeStripVisible:(BOOL)aVisible animate:(BOOL)aAnimate
{
    [self makeStripVisible:aVisible animate:aAnimate moveFrame:YES];
}

- (void)notifyDidShowStrip
{
    if ([_delegate respondsToSelector:@selector(mediaStripSwitcherDidShowMediaStrip:)])
        [_delegate mediaStripSwitcherDidShowMediaStrip:self];
}

- (void)notifyWillHideStrip
{
    if ([_delegate respondsToSelector:@selector(mediaStripSwitcherWillHideMediaStrip:)])
        [_delegate mediaStripSwitcherWillHideMediaStrip:self];
}

- (BOOL)isStripVisible
{
    return _isStripVisible;
}

- (void)awakeFromNib
{
    _isStripVisible = YES;
    _stripWidth = NSWidth([_stripContainerView frame]);
    [_stripContainerView retain];
    if (_isStripVisible)
        [self notifyDidShowStrip];
    else
        [self notifyWillHideStrip];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_stripContainerView release];
    [super dealloc];
}

- (void)makeStripVisibleWithoutAnimation:(BOOL)aVisible
{
    [self makeStripVisible:aVisible animate:NO];
}

@end
