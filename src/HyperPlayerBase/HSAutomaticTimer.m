#import "HSAutomaticTimer.h"
#import "HSAttributeNotificationCenter.h"

// The automatic timer settings of an actor: whether its actions run by
// themselves, after which delay, and how often they repeat (0 = not at all;
// stored documents mark repeating with -1 until the delay is known).
@implementation HSAutomaticTimer

// "repeating" loaded as -1 repeats with the first delay (or 0.05 seconds).
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext
{
    [super loadExtraDictionaryRepresentation:aRepresentation withCodingContext:aContext];
    if (_delayBetweenRepeatingActions < 0)
        _delayBetweenRepeatingActions = _delayBeforeRunActionsAutomatically > 0 ? _delayBeforeRunActionsAutomatically : 0.05;
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"runActionsAutomatically", @"delayBeforeRunActionsAutomatically", @"delayBetweenRepeatingActions", @"repeating", nil];
}

// "repeating" too for older readers when both delays are the same.
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"runActionsAutomatically", @"delayBeforeRunActionsAutomatically", @"delayBetweenRepeatingActions", nil];
    if (_delayBetweenRepeatingActions > 0 && _delayBetweenRepeatingActions == _delayBeforeRunActionsAutomatically)
        [keys addObject:@"repeating"];
    return keys;
}

- (void)setRepeating:(BOOL)aRepeating
{
    if (aRepeating)
        _delayBetweenRepeatingActions = -1;
}

- (BOOL)isRepeating
{
    return _delayBetweenRepeatingActions != 0;
}

- (id)implementationForHyperObject:(id)aObject
{
    return [super implementationForHyperObject:aObject];
}

- (id)hyperObject
{
    return [super hyperObject];
}

- (BOOL)implementsHyperInterface:(id)aInterface
{
    return [super implementsHyperInterface:aInterface];
}

- (id)queryHyperInterface:(id)aInterface
{
    return [super queryHyperInterface:aInterface];
}

- (id)attributesChangedTemporary
{
    return [NSEProtocolSet protocolSet];
}

- (id)attributesBeingChangedContinuously
{
    return [NSEProtocolSet protocolSet];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
}

- (void)endContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttributeSet:(id)aSet
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttributeSet:aSet ofObject:self withUserInfo:nil];
}

- (void)endContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x80 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)beginContinuousChangeOfAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] notifyChange:0x40 ofAttribute:aAttribute ofObject:self withUserInfo:nil];
}

- (void)removeAttributeObserver:(id)aObserver
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:NULL ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeAttributeObserver:(id)aObserver selector:(SEL)aSelector
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:HSAllAttributeChanges ofAttribute:nil ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self];
}

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterfaces:(id *)aInterfaces withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterfaces:aInterfaces ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesOfHyperInterface:(id)aInterface withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesOfHyperInterface:aInterface ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributes:(id *)aAttributes withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributes:aAttributes ofObject:self withPriority:aPriority];
}

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttribute:(id)aAttribute withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttribute:aAttribute ofObject:self withPriority:aPriority];
}

- (id)attributeObservingController
{
    return self;
}

- (void)setDelayBetweenRepeatingActions:(double)aActions
{
    if ([self delayBetweenRepeatingActions] == aActions)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Delay Between Repeating Actions" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDelayBetweenRepeatingActions:_delayBetweenRepeatingActions];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutomaticTimerActionsDelayBetweenRepeatingActionsAttribute) ofObject:self withUserInfo:nil];
    _delayBetweenRepeatingActions = aActions;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutomaticTimerActionsDelayBetweenRepeatingActionsAttribute) ofObject:self withUserInfo:nil];
}

- (double)delayBetweenRepeatingActions
{
    return _delayBetweenRepeatingActions;
}

- (void)setDelayBeforeRunActionsAutomatically:(double)aAutomatically
{
    if ([self delayBeforeRunActionsAutomatically] == aAutomatically)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Automatic Timer Actions Delay" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setDelayBeforeRunActionsAutomatically:[self delayBeforeRunActionsAutomatically]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutomaticTimerActionsDelayAttribute) ofObject:self withUserInfo:nil];
    _delayBeforeRunActionsAutomatically = aAutomatically;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutomaticTimerActionsDelayAttribute) ofObject:self withUserInfo:nil];
}

- (double)delayBeforeRunActionsAutomatically
{
    return _delayBeforeRunActionsAutomatically;
}

- (void)setRunActionsAutomatically:(BOOL)aAutomatically
{
    if ([self runActionsAutomatically] == aAutomatically)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Automatic Timer Action" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setRunActionsAutomatically:[self runActionsAutomatically]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAutomaticTimerActionsEnabledAttribute) ofObject:self withUserInfo:nil];
    _runActionsAutomatically = aAutomatically;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAutomaticTimerActionsEnabledAttribute) ofObject:self withUserInfo:nil];
    [_actor notifyUserObject];
}

- (BOOL)runActionsAutomatically
{
    return _runActionsAutomatically;
}

- (id)attributeNotificationCenter
{
    return [HSAttributeNotificationCenter defaultCenter];
}

// The actor's object's undo manager, if it has one.
- (id)undoManager
{
    id object = [_actor hyperObject];
    if (![object respondsToSelector:@selector(undoManager)])
        return nil;
    return [[_actor hyperObject] undoManager];
}

// Not retained.
- (void)setActor:(id)aActor
{
    _actor = aActor;
}

- (id)actor
{
    return _actor;
}

- (id)initActive:(BOOL)aActive
{
    self = [super init];
    if (self != nil)
        _runActionsAutomatically = aActive;
    return self;
}

- (id)init
{
    return [self initActive:NO];
}

@end
