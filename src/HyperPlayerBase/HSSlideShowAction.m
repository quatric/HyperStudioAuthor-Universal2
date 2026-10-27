#import "HSSlideShowAction.h"

@implementation HSSlideShowAction
- (id)attributeNotificationCenterForTransition:(id)aTransition
{
    return [self attributeNotificationCenter];
}
- (id)undoManagerForTransition:(id)aTransition
{
    return [self undoManager];
}
// The card after the source card, wrapping to the first.
- (id)destinationCard
{
    id container = [[self stack] queryHyperInterface:@protocol(HSNodeContainer)];
    NSUInteger index = [[[self sourceCard] queryHyperInterface:@protocol(HSNodeAttributes)] hyperIndex];
    if (index == NSNotFound)
        return nil;
    return [container hyperChildAtIndex:(index + 1 < [container hyperCount] ? index + 1 : 0)];
}
- (id)sourceCard
{
    return [self card];
}
- (void)setUseClickOnExitCard:(BOOL)aValue
{
    if ([self useClickOnExitCard] == aValue)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Use Click on Exit Card" value:@"" table:@"UndoManager"]];
    [(HSSlideShowAction *)[[self undoManager] prepareWithInvocationTarget:self] setUseClickOnExitCard:[self useClickOnExitCard]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSUseClickOnExitCardAttribute) ofObject:self withUserInfo:nil];
    _useClickOnExitCard = aValue;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSUseClickOnExitCardAttribute) ofObject:self withUserInfo:nil];
}
- (BOOL)useClickOnExitCard
{
    return _useClickOnExitCard;
}
- (void)setLoopSlideShow:(BOOL)aValue
{
    if ([self loopSlideShow] == aValue)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Loop Slide Show" value:@"" table:@"UndoManager"]];
    [(HSSlideShowAction *)[[self undoManager] prepareWithInvocationTarget:self] setLoopSlideShow:[self loopSlideShow]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSLoopSlideShowAttribute) ofObject:self withUserInfo:nil];
    _loopSlideShow = aValue;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSLoopSlideShowAttribute) ofObject:self withUserInfo:nil];
}
- (BOOL)loopSlideShow
{
    return _loopSlideShow;
}
- (void)setReturnsToOriginalCard:(BOOL)aValue
{
    if ([self returnsToOriginalCard] == aValue)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Return to Original Card" value:@"" table:@"UndoManager"]];
    [(HSSlideShowAction *)[[self undoManager] prepareWithInvocationTarget:self] setReturnsToOriginalCard:[self returnsToOriginalCard]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSReturnsToOriginalCardAttribute) ofObject:self withUserInfo:nil];
    _returnsToOriginalCard = aValue;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSReturnsToOriginalCardAttribute) ofObject:self withUserInfo:nil];
}
- (BOOL)returnsToOriginalCard
{
    return _returnsToOriginalCard;
}
- (void)setSlideDuration:(double)aValue
{
    if ([self slideDuration] == aValue)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Slide Duration" value:@"" table:@"UndoManager"]];
    [(HSSlideShowAction *)[[self undoManager] prepareWithInvocationTarget:self] setSlideDuration:[self slideDuration]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSlideDurationAttribute) ofObject:self withUserInfo:nil];
    _slideDuration = aValue;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSlideDurationAttribute) ofObject:self withUserInfo:nil];
}
- (double)slideDuration
{
    return _slideDuration;
}
- (void)HSSlideShowAction_transitionEffectChange:(id)aChange
{
    [[self attributeNotificationCenter] notifyChange:[aChange attributeChange] ofAttribute:@protocol(HSSlideTransitionAttribute) ofObject:self withUserInfo:[NSDictionary dictionaryWithObject:aChange forKey:@"HSUnderlyingAttributeNotification"]];
}
- (void)setSlideTransition:(id)aTransition
{
    if ([self slideTransition] == aTransition)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Slide Transition" value:@"" table:@"UndoManager"]];
    [(HSSlideShowAction *)[[self undoManager] prepareWithInvocationTarget:self] setSlideTransition:[self slideTransition]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSlideTransitionAttribute) ofObject:self withUserInfo:nil];
    [[_slideTransition attributeObservingController] removeObserver:self selector:@selector(HSSlideShowAction_transitionEffectChange:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSTransitionNameAttribute)];
    if ([_slideTransition delegate] == self)
        [_slideTransition setDelegate:nil];
    [_slideTransition release];
    _slideTransition = [aTransition retain];
    [[_slideTransition attributeObservingController] addObserver:self selector:@selector(HSSlideShowAction_transitionEffectChange:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSTransitionNameAttribute) withPriority:0.25];
    [_slideTransition setDelegate:self];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSlideTransitionAttribute) ofObject:self withUserInfo:nil];
}
- (id)slideTransition
{
    return _slideTransition;
}
// Starts a slide show unless one is already running.
- (void)startInContext:(id)aContext
{
    if (![aContext isSlideshow]) {
        HSSlideshowAttributes *attributes = [HSSlideshowAttributes new];
        [attributes setTransition:[self slideTransition]];
        [attributes setDurationBetweenSlides:[self slideDuration]];
        [attributes setStartsNextSlideAutomatically:YES];
        [attributes setStopsAfterEnd:![self loopSlideShow]];
        [attributes setUseClickOnExitCard:[self useClickOnExitCard]];
        [attributes setReturnsToOriginalCard:[self returnsToOriginalCard]];
        [aContext startSlideshowWithAttributes:attributes];
        [attributes release];
    }
    [self notifyDidFinish];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"slideTransition", @"slideDuration", @"returnsToOriginalCard", @"useClickOnExitCard", @"loopSlideShow", nil]];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[_slideTransition attributeObservingController] removeObserver:self selector:@selector(HSSlideShowAction_transitionEffectChange:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSTransitionNameAttribute)];
    if ([_slideTransition delegate] == self)
        [_slideTransition setDelegate:nil];
    [_slideTransition release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        HSSlideshowAttributes *defaults = [HSSlideshowAttributes defaultSlideshowAttributes];
        _slideTransition = [[defaults transition] retain];
        [[_slideTransition attributeObservingController] addObserver:self selector:@selector(HSSlideShowAction_transitionEffectChange:) ofChanges:HSAllAttributeChanges ofAttribute:@protocol(HSTransitionNameAttribute) withPriority:0.25];
        [_slideTransition setDelegate:self];
        _slideDuration = [defaults durationBetweenSlides];
        _returnsToOriginalCard = YES;
        _loopSlideShow = ![defaults stopsAfterEnd];
        _useClickOnExitCard = NO;
    }
    return self;
}
@end
