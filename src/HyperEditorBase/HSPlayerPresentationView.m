#import "HSPlayerPresentationView.h"

// The player view of presentation mode: in full screen an exit button
// fades in at the top while the mouse is off the card (or the app comes
// back), and out two seconds later.

@implementation HSPlayerPresentationView

- (void)validateExitFullScreenButton
{
    if (_exitFullScreenButton != nil)
        [_exitFullScreenButton setImage:[self exitFullScreenButtonImage]];
}

- (void)showExitFullScreenButton:(BOOL)aButton
{
    if (!_isFullScreen && aButton)
        return;
    if (_exitFullScreenButton == nil) {
        if (!aButton)
            return;
        [self createExitFullScreenButtonIfNeeded];
    }
    if (aButton) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideExitFullScreenButton) object:nil];
        [self performSelector:@selector(hideExitFullScreenButton) withObject:nil afterDelay:2.0];
    }
    BOOL animating = [_showHideExitFullScreenButtonAnimation isAnimating];
    if (animating && _showExitFullScreenButtonAnimation == aButton)
        return;
    float progress = animating ? [_showHideExitFullScreenButtonAnimation currentProgress] : 1.0f;
    [_showHideExitFullScreenButtonAnimation stopAnimation];
    [_showHideExitFullScreenButtonAnimation release];
    _showHideExitFullScreenButtonAnimation = nil;
    if ([_exitFullScreenButton isHidden] != aButton)
        return;
    _showExitFullScreenButtonAnimation = aButton;
    if (!_isFullScreen) {
        [_exitFullScreenButton setHidden:YES];
        return;
    }
    NSDictionary *animation = [NSDictionary dictionaryWithObjectsAndKeys:_exitFullScreenButton, NSViewAnimationTargetKey,
        aButton ? NSViewAnimationFadeInEffect : NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil];
    _showHideExitFullScreenButtonAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animation]];
    [_showHideExitFullScreenButtonAnimation setAnimationBlockingMode:NSAnimationNonblocking];
    // Original quirk kept: a duration of 0, so the fade is immediate.
    [_showHideExitFullScreenButtonAnimation setDuration:0];
    [_showHideExitFullScreenButtonAnimation setCurrentProgress:1.0f - progress];
    [_showHideExitFullScreenButtonAnimation startAnimation];
}

- (void)hideExitFullScreenButton
{
    [self showExitFullScreenButton:NO];
}

- (void)showHideExitFullScreenButton
{
    NSView *cardView = [self cardView];
    NSPoint point = [cardView convertPoint:[[self window] BT_effectiveMouseLocation] fromView:nil];
    [self showExitFullScreenButton:!NSPointInRect(point, [cardView bounds])];
}

- (void)delayedShowHideExitFullScreenButton
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showHideExitFullScreenButton) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideExitFullScreenButton) object:nil];
    if (!_isFullScreen)
        return;
    NSView *cardView = [self cardView];
    NSPoint point = [cardView convertPoint:[[self window] BT_effectiveMouseLocation] fromView:nil];
    BOOL inside = NSPointInRect(point, [cardView bounds]);
    if (_exitFullScreenButton == nil && !inside)
        [self createExitFullScreenButtonIfNeeded];
    if (_exitFullScreenButton == nil)
        return;
    if (!inside)
        [self showExitFullScreenButton:YES];
    else
        [self performSelector:@selector(showHideExitFullScreenButton) withObject:nil afterDelay:0.1];
}

// 48 points square, centred at the top of the background view.
- (void)createExitFullScreenButtonIfNeeded
{
    if (_exitFullScreenButton != nil)
        return;
    NSRect frame;
    frame.origin = NSZeroPoint;
    frame.size = NSMakeSize(48.0, 48.0);
    NSRect bounds = [self bounds];
    frame.origin.x = bounds.origin.x + round((bounds.size.width - frame.size.width) * 0.5);
    _exitFullScreenButton = [[NSButton alloc] initWithFrame:frame];
    [_exitFullScreenButton setButtonType:NSButtonTypeMomentaryChange];
    [_exitFullScreenButton setBordered:NO];
    [_exitFullScreenButton setBezelStyle:NSBezelStyleRegularSquare];
    [_exitFullScreenButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
    [self createBackgroundViewIfNeeded];
    [_backgroundView addSubview:_exitFullScreenButton];
    [_exitFullScreenButton setHidden:!_showExitFullScreenButtonAnimation];
    [_exitFullScreenButton setImagePosition:NSImageOnly];
    [_exitFullScreenButton setImage:[self exitFullScreenButtonImage]];
    [_exitFullScreenButton setAction:@selector(togglePlayerMode:)];
}

- (id)exitFullScreenButtonImage
{
    BOOL light = [self isBackgroundRatherLightInRect:[_exitFullScreenButton frame]];
    return [NSImage imageNamed:light ? @"PM_OFF_Black" : @"PM_OFF_White"];
}

- (void)setupBackgroundAttributes
{
    [super setupBackgroundAttributes];
    [self validateExitFullScreenButton];
}

- (void)setStack:(id)aStack
{
    if ([self stack] == aStack)
        return;
    if (_exitFullScreenButton != nil) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showHideExitFullScreenButton) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideExitFullScreenButton) object:nil];
    }
    [super setStack:aStack];
}

- (BOOL)includesBorderThicknessInOptimalSize
{
    return NO;
}

- (id)contentViewNibName
{
    return @"PresentationContentView";
}

- (void)applicationWillBecomeActive:(id)aActive
{
    [self showExitFullScreenButton:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_showHideExitFullScreenButtonAnimation stopAnimation];
    [_showHideExitFullScreenButtonAnimation release];
    [super dealloc];
}

- (id)onceInit
{
    id result = [super onceInit];
    if (result != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillBecomeActive:) name:NSApplicationWillBecomeActiveNotification object:NSApp];
    return result;
}

@end
