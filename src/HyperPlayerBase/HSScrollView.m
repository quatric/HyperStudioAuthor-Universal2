#import "HSScrollView.h"
// Scroll view whose clip view (an HSClipView) is scrollable only while
// scrolling is enabled, or while the user drags a scroller or turns the
// scroll wheel. Scroll wheel scrolling ends half a second after the last
// wheel event.

@implementation HSScrollView

- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    if ([aCoder allowsKeyedCoding])
        [aCoder encodeBool:_isScrollingDisabled forKey:@"HSHyperScrollable"];
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self && [aCoder allowsKeyedCoding])
        _isScrollingDisabled = [aCoder decodeBoolForKey:@"HSHyperScrollable"];
    return self;
}

- (void)scrollWheel:(id)aWheel
{
    [self setIsScrollingByScrollWheel:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSScrollWheelDidStartScrollingNotification" object:self];
    [super scrollWheel:aWheel];
    if (!_scrollWheelTimer) {
        _scrollWheelTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(HSScrollView_scrollWheelDidEnd:) userInfo:nil repeats:NO] retain];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_scrollWheelTimer forMode:NSDefaultRunLoopMode];
        [runLoop addTimer:_scrollWheelTimer forMode:NSEventTrackingRunLoopMode];
        [runLoop addTimer:_scrollWheelTimer forMode:NSModalPanelRunLoopMode];
    } else {
        [_scrollWheelTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    [self setIsScrollingByScrollWheel:NO];
}

- (void)HSScrollView_scrollWheelDidEnd:(id)aEnd
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSScrollWheelDidEndScrollingNotification" object:self];
    [_scrollWheelTimer invalidate];
    [_scrollWheelTimer release];
    _scrollWheelTimer = nil;
}

- (void)didFinishTrackingScroller:(id)aScroller
{
    [self setIsTrackingScroller:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSScrollViewDidEndScrollingNotification" object:self];
}

- (void)willStartTrackingScroller:(id)aScroller
{
    [self setIsTrackingScroller:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSScrollViewDidStartScrollingNotification" object:self];
}

- (void)updateClipViewScrollableState
{
    [[self hyperContentView] setScrollable:[self isScrollable] || [self isTrackingScroller] || [self isScrollingByScrollWheel]];
}

- (void)setIsScrollingByScrollWheel:(BOOL)aWheel
{
    if (_isScrollingByScrollWheel != (aWheel != NO)) {
        _isScrollingByScrollWheel = aWheel != NO;
        [self updateClipViewScrollableState];
    }
}

- (BOOL)isScrollingByScrollWheel
{
    return _isScrollingByScrollWheel;
}

- (void)setIsTrackingScroller:(BOOL)aScroller
{
    if (_isTrackingScroller != (aScroller != NO)) {
        _isTrackingScroller = aScroller != NO;
        [self updateClipViewScrollableState];
    }
}

- (BOOL)isTrackingScroller
{
    return _isTrackingScroller;
}

- (void)setScrollable:(BOOL)aScrollable
{
    if (_isScrollingDisabled != !aScrollable) {
        _isScrollingDisabled = !aScrollable;
        [self updateClipViewScrollableState];
    }
}

- (BOOL)isScrollable
{
    return !_isScrollingDisabled;
}

- (id)hyperContentView
{
    id contentView = [self contentView];
    return [contentView isKindOfClass:[HSClipView class]] ? contentView : nil;
}

- (void)dealloc
{
    [_scrollWheelTimer invalidate];
    [_scrollWheelTimer release];
    [super dealloc];
}

@end
