#import "HSAutoScrollAction.h"
#import "HSSystemTextView.h"
#import "__NSEWeakObjectProxy.h"

// The scrolled text views are those named by UID, else those named by name,
// else the first text view of the card.

static NSArray *HSAutoScrollTextViewsWithUIDs(HSAutoScrollAction *aAction)
{
    NSMutableArray *textViews = [NSMutableArray array];
    id card = [[aAction card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
    NSEnumerator *e = [[aAction textViewUIDs] objectEnumerator];
    id uid;
    while ((uid = [e nextObject]) != nil) {
        id textView = [[card childWithUID:uid] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
        if (textView != nil)
            [textViews addObject:textView];
    }
    return textViews;
}

static NSArray *HSAutoScrollTextViewsWithNames(HSAutoScrollAction *aAction)
{
    NSMutableArray *textViews = [NSMutableArray array];
    NSEnumerator *e = [[[aAction card] queryHyperInterface:@protocol(HSNodeAttributes)] hyperDeepEnumerator];
    id object;
    while ((object = [e nextObject]) != nil) {
        if (![object implementsHyperInterface:@protocol(HSSystemTextViewAttributes)])
            continue;
        if (![[aAction textViewNames] containsObject:[[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperName]])
            continue;
        id textView = [object queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
        if (textView != nil)
            [textViews addObject:textView];
    }
    return textViews;
}

static id HSAutoScrollFirstTextViewObject(HSAutoScrollAction *aAction)
{
    NSEnumerator *e = [[[aAction card] queryHyperInterface:@protocol(HSNodeAttributes)] hyperDeepEnumerator];
    id object;
    while ((object = [e nextObject]) != nil) {
        if ([object implementsHyperInterface:@protocol(HSSystemTextViewAttributes)])
            return object;
    }
    return nil;
}

static NSArray *HSAutoScrollTextViews(HSAutoScrollAction *aAction)
{
    if ([[aAction textViewUIDs] count] != 0)
        return HSAutoScrollTextViewsWithUIDs(aAction);
    if ([[aAction textViewNames] count] != 0)
        return HSAutoScrollTextViewsWithNames(aAction);
    id textView = [HSAutoScrollFirstTextViewObject(aAction) queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    return textView != nil ? [NSArray arrayWithObject:textView] : [NSArray array];
}

// Within 0.05% of 1 (relative to the larger magnitude) counts as the end.
static BOOL HSAutoScrollPositionAtEnd(float aPosition)
{
    float magnitude = aPosition != 0.0f ? fabsf(aPosition) : 1.0f;
    if (magnitude < 1.0f)
        magnitude = 1.0f;
    return aPosition >= magnitude * -0.0005f + 1.0f;
}

@implementation HSAutoScrollAction

- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    if (![self isValid])
        return nil;
    NSMutableDictionary *dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    NSString *uid = [[[self textViewUIDs] extraFirstObject] stringValue];
    if (uid != nil)
        [dictionary setObject:uid forKey:@"object"];
    [dictionary setObject:[NSString stringWithFormat:@"%d", _numberOfSteps] forKey:@"numberOfSteps"];
    [dictionary setObject:[NSString stringWithFormat:@"%d", _stepsPerSecond] forKey:@"stepsPerSecond"];
    [dictionary setObject:_ignoreMouseClicks ? @"1" : @"0" forKey:@"isIgnoreMouseClicks"];
    [dictionary setObject:[NSString stringWithFormat:@"%d", _scrollUnits] forKey:@"scrollingSetup"];
    if (_scrollUnits == 0)
        [dictionary setObject:[NSString stringWithFormat:@"%d", _scrollAmount] forKey:@"pixelsAmount"];
    [dictionary setObject:[NSString stringWithFormat:@"%d", _scrollDirection] forKey:@"scrollDirection"];
    return dictionary;
}

- (BOOL)canBeExportedToHTML5DocumentType:(id)aType
{
    return YES;
}

- (BOOL)isValid
{
    return [HSAutoScrollTextViews(self) count] != 0;
}

// A click on a scrolled text view stops the scrolling.
- (void)textViewPerformedClick:(id)aClick
{
    if ([self ignoreMouseClicks])
        return;
    id uid = [[[aClick object] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    id name = [[[aClick object] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    NSUInteger uidCount = [[self textViewUIDs] count];
    NSUInteger nameCount = [[self textViewNames] count];
    if (uidCount != 0 && [[self textViewUIDs] containsObject:uid]) {
        [self stopScrolling];
        return;
    }
    if (nameCount != 0 && [[self textViewNames] containsObject:name]) {
        [self stopScrolling];
        return;
    }
    if (nameCount != 0 || uidCount != 0)
        return;
    id textView = HSAutoScrollFirstTextViewObject(self);
    if (textView != nil && [textView isEqual:[aClick object]])
        [self stopScrolling];
}

- (void)setIgnoreMouseClicks:(BOOL)aClicks
{
    if (_ignoreMouseClicks == aClicks)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Ignore Mouse Clicks" value:@"" table:@"UndoManager"]];
    [(HSAutoScrollAction *)[[self undoManager] prepareWithInvocationTarget:self] setIgnoreMouseClicks:[self ignoreMouseClicks]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutoScrollIgnoreMouseClicksAttribute) ofObject:self withUserInfo:nil];
    _ignoreMouseClicks = aClicks;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutoScrollIgnoreMouseClicksAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)ignoreMouseClicks
{
    return _ignoreMouseClicks;
}

// Shares the scroll amount's undo name and attribute.
- (void)setScrollUnits:(NSInteger)aUnits
{
    if (_scrollUnits == aUnits)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Scroll Amount" value:@"" table:@"UndoManager"]];
    [(HSAutoScrollAction *)[[self undoManager] prepareWithInvocationTarget:self] setScrollUnits:[self scrollUnits]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutoScrollScrollAmountAttribute) ofObject:self withUserInfo:nil];
    _scrollUnits = (int)aUnits;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutoScrollScrollAmountAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)scrollUnits
{
    return _scrollUnits;
}

- (void)setScrollDirection:(NSInteger)aDirection
{
    if (_scrollDirection == aDirection)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Scroll Direction" value:@"" table:@"UndoManager"]];
    [(HSAutoScrollAction *)[[self undoManager] prepareWithInvocationTarget:self] setScrollDirection:[self scrollDirection]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutoScrollScrollDirectionAttribute) ofObject:self withUserInfo:nil];
    _scrollDirection = (int)aDirection;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutoScrollScrollDirectionAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)scrollDirection
{
    return _scrollDirection;
}

- (void)setScrollAmount:(NSInteger)aAmount
{
    if (_scrollAmount == aAmount)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Scroll Amount" value:@"" table:@"UndoManager"]];
    [(HSAutoScrollAction *)[[self undoManager] prepareWithInvocationTarget:self] setScrollAmount:[self scrollAmount]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutoScrollScrollAmountAttribute) ofObject:self withUserInfo:nil];
    _scrollAmount = (int)aAmount;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutoScrollScrollAmountAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)scrollAmount
{
    return _scrollAmount;
}

- (void)setStepsPerSecond:(NSInteger)aSecond
{
    if (_stepsPerSecond == aSecond)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Steps Per Second" value:@"" table:@"UndoManager"]];
    [(HSAutoScrollAction *)[[self undoManager] prepareWithInvocationTarget:self] setStepsPerSecond:[self stepsPerSecond]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutoScrollStepsPerSecondAttribute) ofObject:self withUserInfo:nil];
    _stepsPerSecond = (int)aSecond;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutoScrollStepsPerSecondAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)stepsPerSecond
{
    return _stepsPerSecond;
}

- (void)setNumberOfSteps:(NSInteger)aSteps
{
    if (_numberOfSteps == aSteps)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Number of Steps" value:@"" table:@"UndoManager"]];
    [(HSAutoScrollAction *)[[self undoManager] prepareWithInvocationTarget:self] setNumberOfSteps:[self numberOfSteps]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutoScrollNumberOfStepsAttribute) ofObject:self withUserInfo:nil];
    _numberOfSteps = (int)aSteps;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutoScrollNumberOfStepsAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)numberOfSteps
{
    return _numberOfSteps;
}

// Positions are computed from the time since the start, so a late timer
// catches up. Zero steps means scroll until the end.
- (void)fireTimer:(id)aTimer
{
    _timePassedSinceTimerStart = [[NSDate date] timeIntervalSinceDate:_timerStartDate];
    SEL scrollSelector = _scrollDirection == 0 ? @selector(scrollTextViewVertically:) : @selector(scrollTextViewHorizontally:);
    NSEnumerator *e = [HSAutoScrollTextViewsWithUIDs(self) objectEnumerator];
    id textView;
    while ((textView = [e nextObject]) != nil)
        [self performSelector:scrollSelector withObject:textView];
    e = [HSAutoScrollTextViewsWithNames(self) objectEnumerator];
    while ((textView = [e nextObject]) != nil)
        [self performSelector:scrollSelector withObject:textView];
    if ([[self textViewUIDs] count] == 0 && [[self textViewNames] count] == 0) {
        id object = HSAutoScrollFirstTextViewObject(self);
        if (object != nil)
            [self performSelector:scrollSelector withObject:[object queryHyperInterface:@protocol(HSSystemTextViewAttributes)]];
    }
    NSInteger stepsPerSecond = [self stepsPerSecond];
    if ((float)[self numberOfSteps] < (float)((double)stepsPerSecond * _timePassedSinceTimerStart) && [self numberOfSteps] != 0) {
        [self invalidateTimer];
        [self restoreTextViewParameters];
        [self notifyDidFinish];
    }
}

- (void)scrollTextViewHorizontally:(id)aHorizontally
{
    id cardObject = [aHorizontally queryHyperInterface:@protocol(HSCardObjectHiddenAttribute)];
    if (cardObject == nil || [cardObject isHiddenInPlayer])
        return;
    NSInteger amount = [self scrollAmount];
    NSInteger stepsPerSecond = [self stepsPerSecond];
    float position = (float)(((double)(stepsPerSecond * amount) * _timePassedSinceTimerStart) / [(HSSystemTextView *)aHorizontally totalScrollAmountInPixels]);
    if (1.0f < position)
        [self stopScrolling];
    else
        [aHorizontally setHorizontalScrollPosition:position];
}

// Units 0 scroll by pixels, units 1 by lines; other units do not scroll.
- (void)scrollTextViewVertically:(id)aVertically
{
    id cardObject = [aVertically queryHyperInterface:@protocol(HSCardObjectHiddenAttribute)];
    if (cardObject == nil || [cardObject isHiddenInPlayer])
        return;
    HSSystemTextView *textView = aVertically;
    float steps = (float)((double)[self stepsPerSecond] * _timePassedSinceTimerStart);
    float position;
    if ([self scrollUnits] == 0) {
        position = (steps * (float)[self scrollAmount]) / (float)[textView totalScrollAmountInPixels];
    } else if ([self scrollUnits] == 1) {
        float total = [textView totalScrollAmountInPixels];
        float magnitude = total != 0.0f ? fabsf(total) : 1.0f;
        float tolerance = 1.0f <= magnitude ? magnitude * 0.0005f : 0.0005f;
        if (tolerance < fabsf(total))
            position = (float)[textView heightOfFirstLineFragments:(NSUInteger)(int)steps] / (float)[textView totalScrollAmountInPixels];
        else
            position = 1.0f;
    } else {
        position = 0.0f;
    }
    if (HSAutoScrollPositionAtEnd(position)) {
        [textView setVerticalScrollPosition:1.0f];
        [self stopScrolling];
    } else {
        [textView setVerticalScrollPosition:position];
    }
}

- (void)stop:(id)aStop
{
    [self invalidateTimer];
    [self restoreTextViewParameters];
    [super stop:aStop];
}

- (BOOL)canBeStopped
{
    return YES;
}

- (void)startInContext:(id)aContext
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewPerformedClick:) name:HSTextViewDidPerformClickNotification object:nil];
    NSEnumerator *e = [HSAutoScrollTextViews(self) objectEnumerator];
    id textView;
    while ((textView = [e nextObject]) != nil)
        [self prepareSystemTextView:textView];
    [self invalidateTimer];
    _timerStartDate = [[NSDate date] retain];
    _timer = [[NSTimer scheduledTimerWithTimeInterval:(double)(1.0f / 30.0f) target:[[self NSE_newWeakProxy] autorelease]
                                             selector:@selector(fireTimer:) userInfo:nil repeats:YES] retain];
}

- (void)systemTextViewHiddenChanged:(id)aChanged
{
    [self stop:nil];
}

- (void)restoreSystemTextView:(id)aView
{
    HSSystemTextView *textView = aView;
    if ([textView scrollsHorizontally]) {
        [[textView attributeObservingController] endContinuousChangeOfAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute)];
        [textView setScrollsHorizontally:NO];
    } else {
        [[textView attributeObservingController] endContinuousChangeOfAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute)];
    }
    [[textView attributeObservingController] removeObserver:self selector:@selector(systemTextViewHiddenChanged:) ofChanges:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute)];
}

// A text view already scrolled to the end starts over from the beginning.
- (void)prepareSystemTextView:(id)aView
{
    HSSystemTextView *textView = aView;
    if (_scrollDirection == 1) {
        [[textView attributeObservingController] beginContinuousChangeOfAttribute:@protocol(HSSystemTextViewHorizontalScrollPostionAttribute)];
        [textView setScrollsHorizontally:YES];
        if (HSAutoScrollPositionAtEnd([textView horizontalScrollPosition]))
            [textView setHorizontalScrollPosition:0.0f];
    } else {
        [[textView attributeObservingController] beginContinuousChangeOfAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute)];
        if (HSAutoScrollPositionAtEnd([textView verticalScrollPosition]))
            [textView setVerticalScrollPosition:0.0f];
    }
    [[textView attributeObservingController] addObserver:self selector:@selector(systemTextViewHiddenChanged:) ofChanges:2
                                             ofAttribute:@protocol(HSCardObjectHiddenAttribute) withPriority:-0.25];
}

- (void)restoreTextViewParameters
{
    NSEnumerator *e = [HSAutoScrollTextViews(self) objectEnumerator];
    id textView;
    while ((textView = [e nextObject]) != nil)
        [self restoreSystemTextView:textView];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:@"numberOfSteps", @"stepsPerSecond", @"scrollAmount", @"scrollUnits", @"scrollDirection", @"ignoreMouseClicks", nil]];
}

- (void)notifyDidFinish
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSTextViewDidPerformClickNotification object:nil];
    [super notifyDidFinish];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSTextViewDidPerformClickNotification object:nil];
    [self invalidateTimer];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _numberOfSteps = 0;
        _stepsPerSecond = 20;
        _scrollAmount = 3;
        _ignoreMouseClicks = NO;
    }
    return self;
}

- (void)stopScrolling
{
    [self invalidateTimer];
    [self restoreTextViewParameters];
    [self notifyDidFinish];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
    [_timerStartDate release];
    _timerStartDate = nil;
}

- (id)XMLElementName
{
    return @"actAutoScroll";
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (BOOL)supportedInIPad
{
    return YES;
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"numberOfSteps" stringValue:[NSString stringWithFormat:@"%d", _numberOfSteps]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"stepsPerSecond" stringValue:[NSString stringWithFormat:@"%d", _stepsPerSecond]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"scrollAmount" stringValue:[NSString stringWithFormat:@"%d", _scrollAmount]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"scrollDirection" stringValue:[NSString stringWithFormat:@"%d", _scrollDirection]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"scrollUnits" stringValue:[NSString stringWithFormat:@"%d", _scrollUnits]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"ignoreMouseClicks" stringValue:_ignoreMouseClicks ? @"1" : @"0"]];
    if ([[self textViewUIDs] count] != 0)
        [element addAttribute:[NSXMLNode attributeWithName:@"textObjectUID" stringValue:[[[self textViewUIDs] objectAtIndex:0] stringValue]]];
    return element;
}

@end
