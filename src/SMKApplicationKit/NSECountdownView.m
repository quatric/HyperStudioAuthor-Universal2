#import "NSECountdownView.h"

// No label is active.
#define NO_LABEL 0x7fffffff

@interface NSObject (NSECountdownViewDelegate)
- (void)viewDidFinishCountdown:(NSECountdownView *)view;
@end

// Three labels, "3", "2" and "1", light up in turn a second apart; then the
// delegate hears viewDidFinishCountdown:.
@implementation NSECountdownView

- (BOOL)isCountingDown
{
    return _timer != nil;
}

- (void)stopCountdown
{
    if (!_timer)
        return;
    if (_activeLabelIndex != NO_LABEL)
        [_labels[_activeLabelIndex] setTextColor:_inactiveTextColor];
    _activeLabelIndex = NO_LABEL;
    [_timer invalidate];
    [_timer release];
    _timer = nil;
}

- (void)NSECountdownView_timerDidFire:(id)aFire
{
    if (_activeLabelIndex == NO_LABEL) {
        _activeLabelIndex = 0;
        [_labels[0] setTextColor:_activeTextColor];
        return;
    }
    [_labels[_activeLabelIndex] setTextColor:_inactiveTextColor];
    if (_activeLabelIndex < 2) {
        _activeLabelIndex++;
        [_labels[_activeLabelIndex] setTextColor:_activeTextColor];
        return;
    }
    _activeLabelIndex = NO_LABEL;
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    if ([_delegate respondsToSelector:@selector(viewDidFinishCountdown:)])
        [(id)_delegate viewDidFinishCountdown:self];
}

- (void)startCountdown
{
    if (![self NSECountdownView_setFont:nil] || ![self inactiveTextColor] || ![self activeTextColor])
        return;
    for (int i = 0; i < 3; i++)
        if (![_labels[i] superview])
            [self addSubview:_labels[i]];
    _timer = [[NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(NSECountdownView_timerDidFire:)
                                    userInfo:nil repeats:YES] retain];
    if (_timer) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
        [runLoop addTimer:_timer forMode:NSEventTrackingRunLoopMode];
        [runLoop addTimer:_timer forMode:NSModalPanelRunLoopMode];
    }
}

- (void)viewWillMoveToSuperview:(id)aSuperview
{
    if (![self NSECountdownView_setFont:nil])
        return;
    for (int i = 0; i < 3; i++)
        if (![_labels[i] superview])
            [self addSubview:_labels[i]];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)setActiveTextColor:(id)aColor
{
    if (_activeTextColor == aColor)
        return;
    NSColor *color = [aColor copy];
    if (!color)
        return;
    [_activeTextColor release];
    _activeTextColor = color;
    if (_activeLabelIndex != NO_LABEL)
        [_labels[_activeLabelIndex] setTextColor:color];
}

- (id)activeTextColor
{
    if (!_activeTextColor)
        _activeTextColor = [[NSColor whiteColor] retain];
    return _activeTextColor;
}

- (void)setInactiveTextColor:(id)aColor
{
    if (_inactiveTextColor == aColor)
        return;
    NSColor *color = [aColor copy];
    if (!color)
        return;
    [_inactiveTextColor release];
    _inactiveTextColor = color;
    if (_labels[0])
        for (unsigned int i = 0; i < 3; i++)
            if (i != _activeLabelIndex)
                [_labels[i] setTextColor:_inactiveTextColor];
}

// The labels' own color unless one was set.
- (id)inactiveTextColor
{
    if (!_inactiveTextColor) {
        if (![self NSECountdownView_setFont:nil])
            return nil;
        _inactiveTextColor = [[_labels[0] textColor] copy];
    }
    return _inactiveTextColor;
}

- (void)setFont:(id)aFont
{
    [self NSECountdownView_setFont:aFont];
}

- (id)font
{
    if (![self NSECountdownView_setFont:nil])
        return nil;
    return [_labels[0] font];
}

// Makes the labels that aren't made yet (in the font, bold 45-point system
// by default) at a quarter, half and three quarters of the width; with a
// font, gives it to the ones that are, keeping their centers. YES when all
// three are there.
- (BOOL)NSECountdownView_setFont:(id)aFont
{
    NSFont *font = aFont;
    if (!font && !(font = [NSFont boldSystemFontOfSize:45.0]))
        return NO;
    NSRect bounds = [self bounds];
    unsigned int i;
    for (i = 0; i < 3; i++) {
        NSTextField *label = _labels[i];
        if (label) {
            if (aFont) {
                NSRect old = [label frame];
                [label sizeToFit];
                NSRect frame = [label frame];
                frame.origin.x = old.origin.x + (old.size.width - frame.size.width) * 0.5;
                frame.origin.y = old.origin.y + (old.size.height - frame.size.height) * 0.5;
                [label setFrame:frame];
            }
            continue;
        }
        label = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 34, 54)];
        _labels[i] = label;
        if (!label)
            break;
        [label setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        [label setBordered:NO];
        [label setDrawsBackground:NO];
        [label setSelectable:NO];
        [label setFont:font];
        if (_inactiveTextColor)
            [label setTextColor:_inactiveTextColor];
        NSString *number = [NSString stringWithFormat:@"%i", 3 - i];
        if (number) {
            NSString *text = [[NSBundle bundleForClass:[NSECountdownView class]] localizedStringForKey:number value:@"" table:@"CountdownView"];
            if (!text)
                text = [@"" length] ? @"" : number;
            [label setStringValue:text];
        }
        [label sizeToFit];
        NSRect frame = [label frame];
        frame.origin.x = bounds.origin.x + floorf(frame.size.width * -0.5 + (float)(i + 1) * bounds.size.width * 0.25);
        frame.origin.y = bounds.origin.y + floorf((bounds.size.height - frame.size.height) * 0.5);
        [label setFrameOrigin:frame.origin];
    }
    return i == 3;
}

- (void)dealloc
{
    [_timer invalidate];
    [_timer release];
    for (int i = 0; i < 3; i++)
        [_labels[i] release];
    [_activeTextColor release];
    [_inactiveTextColor release];
    [super dealloc];
}

- (id)initWithCoder:(id)aCoder
{
    if ((self = [super initWithCoder:aCoder]))
        _activeLabelIndex = NO_LABEL;
    return self;
}

- (id)initWithFrame:(NSRect)aFrame
{
    if ((self = [super initWithFrame:aFrame]))
        _activeLabelIndex = NO_LABEL;
    return self;
}

@end
