#import "HSHistoryItem.h"
#import "HSHomeStackController.h"
#import "HSNavigationOperation.h"
#import "HSQTTransition.h"

@implementation HSHistoryItem

+ (id)itemWithCard:(id)aCard transition:(id)aTransition
{
    return [[[self alloc] initWithCard:aCard transition:aTransition] autorelease];
}

- (void)removeLinkOnStack
{
    [_cardStack release];
    _cardStack = nil;
}

- (id)cardStack
{
    return _cardStack;
}

- (id)cardUID
{
    return _cardUID;
}

- (id)createNavigationOperationWithTransition:(id)aTransition
{
    if (aTransition == nil)
        aTransition = [HSTransition oppositeTransitionForTransition:_cardTransition];
    NSURL *url = [self cardDocumentPath] ? [NSURL fileURLWithPath:[self cardDocumentPath]] : nil;
    HSNavigationOperation *operation = [[HSNavigationOperation alloc] initWithDestinationStackURL:url destinationCardUID:_cardUID transition:aTransition];
    [operation setDestinationStack:[self cardStack]];
    return operation;
}

- (NSUInteger)hash
{
    return [_cardUID hash];
}

- (BOOL)isEqual:(id)aEqual
{
    if ([aEqual isKindOfClass:[HSUID class]])
        return [_cardUID isEqual:aEqual];
    if (![aEqual isKindOfClass:[self class]])
        return [super isEqual:aEqual];
    return [_cardUID isEqual:[aEqual cardUID]]
        && [_cardDocumentPath isEqualToString:[aEqual cardDocumentPath]]
        && _cardStack == [aEqual cardStack];
}

- (void)setCardDocumentPath:(id)aPath
{
    if (![_cardDocumentPath isEqualToString:aPath]) {
        [_cardDocumentPath release];
        _cardDocumentPath = [aPath retain];
    }
}

- (id)cardDocumentPath
{
    // Unsaved documents get their path once they are saved.
    if (_cardDocumentPath == nil)
        _cardDocumentPath = [[[_cardStack document] fileName] retain];
    return _cardDocumentPath;
}

- (void)dealloc
{
    [_cardUID release];
    [_cardDocumentPath release];
    [_cardStack release];
    [(id)_cardTransition release];
    [super dealloc];
}

- (id)initWithCard:(id)aCard transition:(id)aTransition
{
    self = [super init];
    if (self != nil) {
        _cardUID = [[aCard hyperUID] retain];
        _cardDocumentPath = [[[aCard document] fileName] retain];
        if (_cardDocumentPath == nil)
            _cardStack = [[aCard stack] retain];
        _cardTransition = [aTransition retain];
    }
    return self;
}

@end

static HSHistoryStack *sSharedHistoryStack = nil;

@implementation HSHistoryStack

+ (id)allocWithZone:(NSZone *)aZone
{
    if (sSharedHistoryStack == nil) {
        sSharedHistoryStack = [super allocWithZone:aZone];
        return sSharedHistoryStack;
    }
    return nil;
}

+ (id)sharedHistoryStack
{
    if (sSharedHistoryStack == nil)
        [[self alloc] init];
    return sSharedHistoryStack;
}

- (void)removeCardWithUID:(id)aUID inStack:(id)aStack navigationStack:(id)aStack2
{
    NSString *path = [[aStack document] fileName];
    for (NSInteger i = (NSInteger)[aStack2 count] - 1; i >= 0; i--) {
        HSHistoryItem *item = [aStack2 objectAtIndex:i];
        if ([item cardDocumentPath] == nil
            || ([path isEqualToString:[item cardDocumentPath]] && [[item cardUID] isEqual:aUID]))
            [aStack2 removeObjectAtIndex:i];
    }
}

- (void)removeStack:(id)aStack navigationStack:(id)aStack2
{
    NSString *path = [[aStack document] fileName];
    for (NSInteger i = (NSInteger)[aStack2 count] - 1; i >= 0; i--) {
        HSHistoryItem *item = [aStack2 objectAtIndex:i];
        if ([item cardDocumentPath] == nil || [path isEqualToString:[item cardDocumentPath]])
            [aStack2 removeObjectAtIndex:i];
    }
}

- (void)removeCardWithUID:(id)aUID inStack:(id)aStack
{
    [self removeCardWithUID:aUID inStack:aStack navigationStack:_back];
    [self removeCardWithUID:aUID inStack:aStack navigationStack:_forward];
}

- (void)removeStack:(id)aStack
{
    [self removeStack:aStack navigationStack:_back];
    [self removeStack:aStack navigationStack:_forward];
}

- (void)removeAllLinksOnStack:(id)aStack navigationStack:(id)aStack2
{
    NSUInteger count = [aStack2 count];
    for (NSUInteger i = 0; i < count; i++) {
        HSHistoryItem *item = [aStack2 objectAtIndex:i];
        if ([item cardStack] == aStack)
            [item removeLinkOnStack];
    }
}

- (void)removeAllLinksOnStack:(id)aStack
{
    [self removeAllLinksOnStack:aStack navigationStack:_back];
    [self removeAllLinksOnStack:aStack navigationStack:_forward];
}

- (id)lastMarkedCard
{
    return _lastMarkedCard;
}

- (void)startForwardOperation
{
    [self startHistoryOperation];
    _currentStack = _back;
    _navigationStack = _forward;
}

- (void)startBackOperation
{
    [self startHistoryOperation];
    _currentStack = _forward;
    _navigationStack = _back;
}

- (void)concludeHistoryOperation:(BOOL)aOperation
{
    if (aOperation)
        [_navigationStack removeLastObject];
    _navigationStack = nil;
    _isGoingInStack = NO;
    _currentStack = _back;
}

- (void)startHistoryOperation
{
    _isGoingInStack = YES;
}

- (id)createLastMarkedCardNavigationOperationWithTransition:(id)aTransition
{
    if (_lastMarkedCard == nil)
        return nil;
    return [_lastMarkedCard createNavigationOperationWithTransition:aTransition];
}

- (id)createForwardNavigationOperationWithTransition:(id)aTransition
{
    return [[_forward lastObject] createNavigationOperationWithTransition:aTransition];
}

- (id)createBackNavigationOperationWithTransition:(id)aTransition
{
    return [[_back lastObject] createNavigationOperationWithTransition:aTransition];
}

- (void)pushCard:(id)aCard withTransition:(id)aTransition
{
    [[HSHomeStackController sharedHomeStackController] updateDefaultCardIndexUsingCurrentCard:aCard];
    HSHistoryItem *item = [HSHistoryItem itemWithCard:aCard transition:aTransition];
    if (![[_currentStack lastObject] isEqual:item])
        [_currentStack addObject:item];
    if ([aCard isMarkedCard]) {
        [_lastMarkedCard release];
        _lastMarkedCard = [item retain];
    }
    // A new visit outside back/forward navigation clears the forward list.
    if (!_isGoingInStack)
        [_forward removeAllObjects];
}

- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

- (void)dealloc
{
    [_back release];
    [_forward release];
    [_lastMarkedCard release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _back = [NSMutableArray new];
        _forward = [NSMutableArray new];
        _currentStack = _back;
    }
    return self;
}

- (BOOL)isBackGoing
{
    return _isGoingInStack && _navigationStack == _back;
}

- (BOOL)isForwardGoing
{
    return _isGoingInStack && _navigationStack == _forward;
}

- (void)setLastMarkedCard:(id)aCard
{
    if (_lastMarkedCard != aCard) {
        [_lastMarkedCard release];
        _lastMarkedCard = [aCard retain];
    }
}

@end
