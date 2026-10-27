#import "HSMainWindowStatusbarController.h"

@implementation HSMainWindowStatusbarController

- (void)setZoomControlsEnabled:(BOOL)aEnabled
{
    if ([_zoomSlider isEnabled] != aEnabled)
        [_zoomSlider setEnabled:aEnabled];
}

- (void)refreshStatusbarText
{
    if ([[self delegate] respondsToSelector:@selector(textForStatusBarController:)]) {
        id text = [[self delegate] textForStatusBarController:self];
        if (text)
            [_stausbarTextField setAttributedStringValue:text];
    }
}

- (void)hyperCustomSliderDidFinishTracking:(id)aTracking
{
    if ([[self delegate] respondsToSelector:@selector(zoomSliderDidFinishTracking:inStatusbarController:)])
        [[self delegate] zoomSliderDidFinishTracking:aTracking inStatusbarController:self];
}

- (void)hyperCustomSliderDidStartTracking:(id)aTracking
{
    if ([[self delegate] respondsToSelector:@selector(zoomSliderDidStartTracking:inStatusbarController:)])
        [[self delegate] zoomSliderDidStartTracking:aTracking inStatusbarController:self];
}

- (void)setMinZoomFactor:(CGFloat)aFactor
{
    [_zoomSlider setMinValue:aFactor];
}

- (void)setMaxZoomFactor:(CGFloat)aFactor
{
    [_zoomSlider setMaxValue:aFactor];
}

- (void)setZoomFactor:(CGFloat)aFactor
{
    [_zoomSlider setFloatValue:aFactor];
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
        [self validateUI];
    }
}

// Enables each control according to whether the target of its action
// validates it.
- (void)validateUI
{
    NSEnumerator *enumerator = [[NSArray arrayWithObjects:_toggleCardIndexButton, _toggleStoryboardButton, _enterFullScreenButton, _cardNavigationControl, _goToHomeStackButton, nil] objectEnumerator];
    id control;
    while ((control = [enumerator nextObject])) {
        if ([control isKindOfClass:[NSMatrix class]]) {
            NSEnumerator *cells = [[control cells] objectEnumerator];
            id cell;
            while ((cell = [cells nextObject])) {
                if ([cell isKindOfClass:[NSActionCell class]])
                    [self validateActionCell:cell];
            }
        } else if ([control isKindOfClass:[NSControl class]] || [control respondsToSelector:@selector(action)]) {
            SEL action = [(NSControl *)control action];
            id target = [control respondsToSelector:@selector(target)] ? [(NSControl *)control target] : nil;
            if (action) {
                id validator = [NSApp targetForAction:action to:target from:control];
                BOOL enabled;
                if (!validator)
                    enabled = NO;
                else if (![validator respondsToSelector:@selector(validateUserInterfaceItem:)])
                    enabled = YES;
                else
                    enabled = [validator validateUserInterfaceItem:control];
                [control setEnabled:enabled];
            }
        }
    }
}

- (void)validateActionCell:(id)aCell
{
    id target = [(NSActionCell *)aCell target];
    id validator = [NSApp targetForAction:[(NSActionCell *)aCell action] to:target from:aCell];
    BOOL enabled;
    if (!validator)
        enabled = NO;
    else if (![validator respondsToSelector:@selector(validateUserInterfaceItem:)])
        enabled = YES;
    else
        enabled = [validator validateUserInterfaceItem:aCell];
    [aCell setEnabled:enabled];
}

- (void)didLoadNib
{
    [_cardNavigationControl setBackgroundRenderer:[HSCardNavigationControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_toggleCardIndexButton cell] setBackgroundRenderer:[HSCardNavigationControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_toggleStoryboardButton cell] setBackgroundRenderer:[HSCardNavigationControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_enterFullScreenButton cell] setBackgroundRenderer:[HSCardNavigationControlBackgroundRenderer sharedBackgroundRenderer]];
    [[_goToHomeStackButton cell] setBackgroundRenderer:[HSCardNavigationControlBackgroundRenderer sharedBackgroundRenderer]];
    [_zoomSlider setDelegate:self];
    [(SMKEngravedTextFieldCell *)[_stausbarTextField cell] setEngraveOffset:1.0f];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillUpdate:) name:NSApplicationWillUpdateNotification object:NSApp];
}

- (void)loadNibIfNeeded
{
    if (!_statusbarView) {
        [NSBundle loadNibNamed:[self nibName] owner:self];
        [self didLoadNib];
    }
}

- (id)nibName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)statusbarView
{
    [self loadNibIfNeeded];
    return _statusbarView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_statusbarView release];
    [super dealloc];
}

@end
