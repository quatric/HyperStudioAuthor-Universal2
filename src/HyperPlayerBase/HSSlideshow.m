#import "HSSlideshow.h"
#import "HSQTTransition.h"
#import "HSSlideshowAttributes.h"
#import "HSThreadInvocationWrapper.h"
#import "HSTransitionView.h"

static HSSlideshow *HSSharedSlideshow;

// Shows a data source's items (images, or paths of image files) one after
// another in a transition view, stepping automatically, on a keystroke or on
// a click as the slideshow attributes say. Runs in the data source's view
// when it has one.
@implementation HSSlideshow

+ (id)sharedHSSlideshow
{
    if (HSSharedSlideshow == nil)
        HSSharedSlideshow = [self new];
    return HSSharedSlideshow;
}

- (id)transitionView
{
    return _transitionView;
}

- (void)setIndexOfCurrentSlideshowItem:(NSUInteger)aItem
{
    if ([_transitionView isTransitionPlaying])
        [_transitionView stopTransition];
    if (_indexOfCurrentSlideshowItem == aItem)
        return;
    if (aItem < [self itemCount]) {
        _indexOfCurrentSlideshowItem = (unsigned int)aItem;
        if ([_dataSource respondsToSelector:@selector(slideshowDidChangeCurrentIndex:)])
            [_dataSource slideshowDidChangeCurrentIndex:_indexOfCurrentSlideshowItem];
        [_transitionView setTransitionTime:[_transitionView transitionPlayRangeStartTime]];
        [_transitionView setStartImage:[self itemAtIndex:_indexOfCurrentSlideshowItem]];
        [_transitionView setStartImageAsEndImage];
    }
    if (_isRunning) {
        if ([_slideshowAttributes startsNextSlideAutomatically]) {
            [_autoPlayTimer invalidate];
            [_autoPlayTimer release];
            _autoPlayTimer = nil;
            if ([self shouldStop])
                [self stopSlideshow:nil];
            else
                [self HSSlideshow_autoPlay];
        } else if ([self shouldStop]) {
            [self stopSlideshow:nil];
        }
    }
    [_transitionView setNeedsDisplay:YES];
}

- (NSUInteger)indexOfCurrentSlideshowItem
{
    return _indexOfCurrentSlideshowItem;
}

- (void)reloadSlideshowItemAtIndex:(NSUInteger)aIndex
{
    NSMapRemove(_cachedItems, (void *)aIndex);
}

- (void)reloadData
{
    _indexOfCurrentSlideshowItem = 0;
    NSResetMapTable(_cachedItems);
}

- (id)dataSource
{
    return _dataSource;
}

- (void)resumeSlideshow
{
    _isPaused = NO;
    if ([_slideshowAttributes startsNextSlideAutomatically])
        [self HSSlideshow_autoPlay];
    else if ([self shouldStop])
        [self stopSlideshow:nil];
}

- (void)pauseSlideshow
{
    _isPaused = YES;
}

- (void)stopSlideshow:(id)aSlideshow
{
    _isRunning = NO;
    [_autoPlayTimer invalidate];
    [_autoPlayTimer release];
    _autoPlayTimer = nil;
    if ([_transitionView isTransitionPlaying])
        [_transitionView stopTransition];
    if ([self isRunningInExternalView])
        [_transitionView removeFromSuperview];
    [self setSlideshowContentView:nil];
    if ([_delegate respondsToSelector:@selector(slideshowDidStop)])
        [_delegate slideshowDidStop];
    [self setDataSource:nil];
    [self setDelegate:nil];
}

// Options: "HSCustomSlideshowAttributes", "IKSlideshowStartIndex" and
// "HSTransitionBackgroundColor".
- (void)runSlideshowWithDataSource:(id)aSource delegate:(id)aDelegate options:(id)aOptions
{
    [self setDataSource:aSource];
    [self setDelegate:aDelegate];
    if (aOptions != nil) {
        id attributes = [aOptions objectForKey:@"HSCustomSlideshowAttributes"];
        if (attributes != nil)
            [self setSlideshowAttributes:attributes];
        id startIndex = [aOptions objectForKey:@"IKSlideshowStartIndex"];
        if (startIndex != nil)
            _indexOfCurrentSlideshowItem = [startIndex unsignedIntValue];
    }
    if ([_delegate respondsToSelector:@selector(slideshowWillStart)])
        [_delegate slideshowWillStart];
    [self maintainTransitionView];
    [_transitionView setBackgroundColor:[aOptions objectForKey:@"HSTransitionBackgroundColor"]];
    [[self window] makeFirstResponder:_transitionView];
    [self HSSlideshow_updateTransition];
    [_transitionView setStartImage:[self itemAtIndex:_indexOfCurrentSlideshowItem]];
    [_transitionView setStartImageAsEndImage];
    [_transitionView setNeedsDisplay:YES];
    if ([_slideshowAttributes startsNextSlideAutomatically])
        [self HSSlideshow_autoPlay];
    _isRunning = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_autoPlayTimer invalidate];
    [_autoPlayTimer release];
    [_slideshowContentView release];
    if ([_transitionView isTransitionPlaying])
        [_transitionView stopTransition];
    if ([_transitionView delegate] == self)
        [_transitionView setDelegate:nil];
    [_transitionView release];
    [_slideshowAttributes release];
    NSFreeMapTable(_cachedItems);
    [super dealloc];
}

// Follows the default slideshow attributes.
- (id)init
{
    self = [super init];
    if (self != nil) {
        _cachedItems = NSCreateMapTable(NSIntegerMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultSlideshowAttributesDidChange:) name:@"HSSlideshowDidChangeAttributesNotification" object:nil];
        [self defaultSlideshowAttributesDidChange:nil];
        _transitionView = [[HSSlideshow_HSTransitionView alloc] initWithFrame:NSZeroRect];
        [_transitionView setDelegate:self];
    }
    return self;
}

- (BOOL)HSSlideshow_shouldSlideshowStepOnKeystroke
{
    return [_slideshowAttributes useKeystrokeOnNextSlide];
}

- (BOOL)HSSlideshow_shouldSlideshowStopOnKeystroke:(id)aKeystroke
{
    return [_slideshowAttributes useKeystrokeOnExitCard:aKeystroke];
}

- (BOOL)HSSlideshow_shouldSlideshowStepOnMouseClick
{
    return [_slideshowAttributes useClickOnNextSlide];
}

// Only after the last item.
- (BOOL)HSSlideshow_shouldSlideshowStopOnMouseClick
{
    if (![_slideshowAttributes useClickOnExitCard] && ![_slideshowAttributes leavesLastPictureOnExit])
        return NO;
    return [self shouldStop];
}

- (void)defaultSlideshowAttributesDidChange:(id)aChange
{
    id dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSSlideshowAttributesKeyString"];
    [self setSlideshowAttributes:[HSSlideshowAttributes objectWithExtraDictionary:dictionary]];
    [self HSSlideshow_updateTransition];
}

- (void)HSSlideshow_updateTransition
{
    HSTransition *transition = [_slideshowAttributes transition];
    if (transition == nil) {
        [_transitionView setTransitionEffect:nil];
        [_transitionView setTransitionDuration:0];
    } else {
        [_transitionView setTransitionEffect:[transition effect]];
        [_transitionView setTransitionDuration:[transition duration]];
    }
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (void)setDataSource:(id)aSource
{
    if (_dataSource == aSource)
        return;
    _dataSource = aSource;
    [self reloadData];
}

// In the data source's view (its frame and autoresizing mask when given),
// or in the own content view filling it.
- (void)maintainTransitionView
{
    id contentView = nil;
    if ([_dataSource respondsToSelector:@selector(slideshowView)])
        contentView = [_dataSource slideshowView];
    if (contentView == nil)
        contentView = _ownContentView;
    [self setSlideshowContentView:contentView];
    NSRect frame = [contentView bounds];
    NSUInteger mask = NSViewWidthSizable | NSViewHeightSizable;
    if ([self isRunningInExternalView]) {
        if ([_dataSource respondsToSelector:@selector(slideshowAutoresizingMask)])
            mask = [_dataSource slideshowAutoresizingMask];
        if ([_dataSource respondsToSelector:@selector(slideshowFrame)])
            frame = [_dataSource slideshowFrame];
    }
    [_transitionView setAutoresizingMask:mask];
    [_transitionView setFrame:frame];
    if (![self isRunningInExternalView] && [_transitionView superview] != nil)
        return;
    [[self slideshowContentView] addSubview:_transitionView];
}

- (void)transitionViewDidFinishTransition:(id)aTransition
{
    if (_transitionView == aTransition)
        [self HSSlideshow_transitionDidEnd];
    [super transitionViewDidFinishTransition:aTransition];
}

- (void)transitionViewDidStopTransition:(id)aTransition
{
    if (_transitionView == aTransition)
        [self HSSlideshow_transitionDidEnd];
    [super transitionViewDidStopTransition:aTransition];
}

// Transitions to the next item; after the last one it stops unless the last
// picture stays.
- (void)HSSlideshow_stepSlideshow:(id)aSlideshow
{
    [_autoPlayTimer invalidate];
    [_autoPlayTimer release];
    _autoPlayTimer = nil;
    if (_isPaused)
        return;
    if (![self shouldStop]) {
        [_transitionView setEndImageAsStartImage];
        [_transitionView setEndImage:[self itemAtIndex:[self indexOfNextSlideshowItem]]];
        if (![_transitionView startTransition])
            [self HSSlideshow_transitionDidEnd];
    } else if (![_slideshowAttributes leavesLastPictureOnExit]) {
        [self stopSlideshow:nil];
    }
}

- (void)HSSlideshow_transitionDidEnd
{
    _indexOfCurrentSlideshowItem = (unsigned int)[self indexOfNextSlideshowItem];
    if ([_dataSource respondsToSelector:@selector(slideshowDidChangeCurrentIndex:)])
        [_dataSource slideshowDidChangeCurrentIndex:_indexOfCurrentSlideshowItem];
    if (!_isRunning)
        return;
    if ([_slideshowAttributes startsNextSlideAutomatically])
        [self HSSlideshow_autoPlay];
    else if ([self shouldStop])
        [self stopSlideshow:nil];
}

- (void)HSSlideshow_autoPlay
{
    _autoPlayTimer = [[NSThread hyperScheduledThreadTimerWithInterval:[_slideshowAttributes durationBetweenSlides] mainThreadTarget:self selector:@selector(HSSlideshow_stepSlideshow:) repeats:NO] retain];
}

- (BOOL)shouldStop
{
    return [self indexOfNextSlideshowItem] == [self itemCount];
}

// An existing file's path becomes its image.
- (id)itemAtIndex:(NSUInteger)aIndex
{
    id item = (id)NSMapGet(_cachedItems, (void *)aIndex);
    if (item != nil)
        return item;
    item = [_dataSource slideshowItemAtIndex:aIndex];
    if (item == nil)
        return nil;
    if ([item isKindOfClass:[NSString class]] && [[NSFileManager defaultManager] fileExistsAtPath:item])
        item = [[[NSImage alloc] initWithContentsOfFile:item] autorelease];
    NSMapInsert(_cachedItems, (void *)aIndex, item);
    return item;
}

// Wraps around unless the slideshow stops after the end (the item count
// then means past the end).
- (NSUInteger)indexOfNextSlideshowItem
{
    NSUInteger index = _indexOfCurrentSlideshowItem + 1;
    if (index == [self itemCount] && ![_slideshowAttributes stopsAfterEnd])
        index = 0;
    return index;
}

- (NSUInteger)itemCount
{
    return [_dataSource numberOfSlideshowItems];
}

- (void)setSlideshowAttributes:(id)aAttributes
{
    if (_slideshowAttributes == aAttributes)
        return;
    [_slideshowAttributes release];
    _slideshowAttributes = [aAttributes retain];
}

- (id)window
{
    return [_slideshowContentView window];
}

- (BOOL)isRunningInExternalView
{
    return _slideshowContentView != _ownContentView;
}

- (void)setSlideshowContentView:(id)aView
{
    if (_slideshowContentView == aView)
        return;
    [_slideshowContentView release];
    _slideshowContentView = [aView retain];
}

- (id)slideshowContentView
{
    return _slideshowContentView;
}

@end

// Steps or stops the slideshow (its delegate) on keystrokes and clicks.
@implementation HSSlideshow_HSTransitionView

- (void)keyDown:(id)aDown
{
    HSSlideshow *slideshow = [self delegate];
    if ([slideshow HSSlideshow_shouldSlideshowStopOnKeystroke:aDown])
        [slideshow stopSlideshow:self];
    else if ([slideshow HSSlideshow_shouldSlideshowStepOnKeystroke])
        [slideshow HSSlideshow_stepSlideshow:nil];
    else
        [super keyDown:aDown];
}

- (void)mouseUp:(id)aUp
{
    HSSlideshow *slideshow = [self delegate];
    if ([slideshow HSSlideshow_shouldSlideshowStopOnMouseClick])
        [slideshow stopSlideshow:self];
    else if ([slideshow HSSlideshow_shouldSlideshowStepOnMouseClick])
        [slideshow HSSlideshow_stepSlideshow:nil];
    else
        [super mouseUp:aUp];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end
