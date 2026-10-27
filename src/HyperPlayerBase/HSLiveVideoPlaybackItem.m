#import "HSLiveVideoPlaybackItem.h"
#import "HSLiveObject.h"
#import "HSUID.h"
#import "HSNode.h"
#import "HSActionExecutionContext.h"
#import "HSPlayMovieAction.h"
#import "HSFunctions.h"
#import "EXCodingContext.h"
#import "NSEMutableProtocolSet.h"

// The live video one "play movie" action shows. It refers to a live object
// on the card (by UID) or keeps a temporary one of its own, and plays a copy
// of it on the card the action runs on. Its attributes are forwarded to the
// live object and notified through the action's item notification center.
@implementation HSLiveVideoPlaybackItem

- (id)attributesChangedTemporary
{
    return [NSEProtocolSet protocolSet];
}

- (id)attributesBeingChangedContinuously
{
    return [NSEProtocolSet protocolSet];
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

- (void)removeObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet
{
    [[self attributeNotificationCenter] removeObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self];
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

- (void)addObserver:(id)aObserver selector:(SEL)aSelector ofChanges:(NSUInteger)aChanges ofAttributesFromSet:(id)aSet withPriority:(CGFloat)aPriority
{
    [[self attributeNotificationCenter] addObserver:aObserver selector:aSelector ofChanges:aChanges ofAttributesFromSet:aSet ofObject:self withPriority:aPriority];
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

- (id)attributeNotificationCenter
{
    return [_playMovieAction itemAttributeNotificationCenter];
}

- (id)undoManager
{
    return [[_playMovieAction nodeSupportForMovie] undoManager];
}

- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}

- (id)XMLElementRepresentationInContext:(id)aContext
{
    NSXMLElement *element = [NSXMLElement elementWithName:[self XMLElementName]];
    [element addAttribute:[NSXMLNode attributeWithName:@"objectUID" stringValue:[[self liveObjectUID] stringValue]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"playOverObjects" stringValue:[self playOverObjects] ? HSXMLStoring1String : HSXMLStoring0String]];
    return element;
}

- (id)XMLElementName
{
    return @"liveVideoSettings";
}

- (BOOL)hasiPadUnsupportedFunctionality
{
    return YES;
}

- (id)iPadUnsupportedFunctionalityDescription
{
    return [NSArray arrayWithObject:@"Live video isn't supported currently on iPad."];
}

- (id)liveObjectMutableGeometryAttributes
{
    if (!_liveObjectMutableGeometryAttributes)
        _liveObjectMutableGeometryAttributes = [[_liveObject queryHyperInterface:@protocol(HSMutableGeometryAttributes)] retain];
    return _liveObjectMutableGeometryAttributes;
}

- (void)setPlaybackItemSupport:(id)aSupport
{
    if (_liveObject && [_liveObject support] == [_playMovieAction nodeSupportForMovie])
        [_liveObject setSupport:[aSupport nodeSupportForMovie]];
    _playMovieAction = aSupport;
}

- (id)playbackItemSupport
{
    return _playMovieAction;
}

- (void)setLiveObjectUIDForSaving:(id)aSaving
{
    if (_liveObjectUID != aSaving) {
        [_liveObjectUID release];
        _liveObjectUID = [aSaving retain];
    }
}

- (id)liveObjectUIDForSaving
{
    return _liveObjectUID;
}

- (id)HSLiveVideoPlaybackItem_liveObject
{
    // A live object that is not on a card yet is looked up in the stack by
    // its UID.
    if (![_liveObject hyperParent] && _liveObjectUID) {
        id stack = [[_playMovieAction stackForAction] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
        HSLiveObject *liveObject = [stack childInTreeWithUID:_liveObjectUID];
        if (liveObject) {
            [liveObject retain];
            [_liveObject release];
            _liveObject = liveObject;
            [_liveObjectMutableGeometryAttributes release];
            _liveObjectMutableGeometryAttributes = nil;
        }
    }
    if (_liveObject && ![_liveObject support] && [_playMovieAction nodeSupportForMovie])
        [_liveObject setSupport:[_playMovieAction nodeSupportForMovie]];
    return _liveObject;
}

- (id)liveObject
{
    if (_liveObjectUID && [_liveObject hyperParent])
        return nil;
    return _liveObject;
}

- (void)cleanupPlayableLiveObject
{
    _cardForPlayableLiveObject = nil;
    if ([_playableLiveObject support] == [_playMovieAction nodeSupportForMovie])
        [_playableLiveObject setSupport:nil];
    [_playableLiveObject release];
    _playableLiveObject = nil;
}

- (void)preparePlayableLiveObjectWithLiveObject:(id)aObject forCard:(id)aCard
{
    if (aObject && _playableLiveObject != aObject) {
        [self cleanupPlayableLiveObject];
        _playableLiveObject = [aObject retain];
        if (![aObject support])
            [_playableLiveObject setSupport:[_playMovieAction nodeSupportForMovie]];
        _cardForPlayableLiveObject = aCard;
    }
}

- (void)willDisconnectFromDocument
{
}

- (void)didConnectToDocument
{
}

- (void)restoreAttributesOfLiveVideo:(id)aVideo
{
    [[self undoManager] disableUndoRegistration];
    if ([self playOverObjects])
        [[aVideo queryHyperInterface:@protocol(HSNodeAttributes)] setHyperIndex:_originalIndex];
    [[self undoManager] enableUndoRegistration];
}

- (void)applyAttributesForLiveVideo:(id)aVideo
{
    _originalIndex = [aVideo hyperIndex];
    if (!aVideo)
        return;
    [[self undoManager] disableUndoRegistration];
    if ([self playOverObjects])
        [aVideo moveToHyperEnd];
    else if ([aVideo isTemporary]) {
        // Temporary videos playing under the objects stack up at the bottom.
        NSInteger index = 0;
        if (_actionExecutionContext)
            index = MAX((NSInteger)[_actionExecutionContext bottomPositionOfLastTemporaryPlayableObject] + 1, 0);
        [aVideo setHyperIndex:index];
    }
    [[self undoManager] enableUndoRegistration];
}

- (BOOL)isTemporary
{
    id card = [[_playMovieAction cardForAction] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
    id liveObject = [card childInTreeWithUID:[[self HSLiveVideoPlaybackItem_liveObject] hyperUID]];
    if (![liveObject hyperParent])
        return YES;
    return [liveObject isTemporary];
}

- (void)setPlayOverObjects:(BOOL)aObjects
{
    if (_playOverObjects != (aObjects != NO)) {
        [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Play Over Objects" value:@"" table:@"UndoManager"]];
        [[[self undoManager] prepareWithInvocationTarget:self] setPlayOverObjects:[self playOverObjects]];
        [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSLiveVideoPlayOverObjectsAttribute) ofObject:self withUserInfo:nil];
        _playOverObjects = aObjects != NO;
        [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSLiveVideoPlayOverObjectsAttribute) ofObject:self withUserInfo:nil];
    }
}

- (BOOL)playOverObjects
{
    return _playOverObjects;
}

- (void)setLiveVideoDeviceIndex:(NSInteger)aIndex
{
    HSLiveObject *liveObject = [self HSLiveVideoPlaybackItem_liveObject];
    if (liveObject && [liveObject hyperDeviceIndex] != aIndex) {
        [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlayMovieActionLiveVideoDeviceIndexAttribute) ofObject:self withUserInfo:nil];
        [liveObject setHyperDeviceIndex:aIndex];
        [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlayMovieActionLiveVideoDeviceIndexAttribute) ofObject:self withUserInfo:nil];
    }
}

- (NSInteger)liveVideoDeviceIndex
{
    return [[self HSLiveVideoPlaybackItem_liveObject] hyperDeviceIndex];
}

- (void)setSize:(NSSize)aSize
{
    [(id<HSMutableGeometryAttributes>)[self liveObjectMutableGeometryAttributes] setSize:aSize];
}

- (NSSize)size
{
    if (![self liveObjectMutableGeometryAttributes])
        return NSZeroSize;
    return [_liveObjectMutableGeometryAttributes size];
}

- (void)setAffineTransform:(CGAffineTransform)aTransform
{
    [[self liveObjectMutableGeometryAttributes] setAffineTransform:aTransform];
}

- (CGAffineTransform)affineTransform
{
    if (![self liveObjectMutableGeometryAttributes])
        return CGAffineTransformIdentity;
    return [_liveObjectMutableGeometryAttributes affineTransform];
}

- (void)setLiveVideoName:(id)aName
{
    HSLiveObject *liveObject = [self HSLiveVideoPlaybackItem_liveObject];
    if (![[liveObject hyperName] isEqual:aName]) {
        [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSLiveVideoNameAttribute) ofObject:self withUserInfo:nil];
        [liveObject setHyperName:aName];
        [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSLiveVideoNameAttribute) ofObject:self withUserInfo:nil];
    }
}

- (id)liveVideoName
{
    return [[self HSLiveVideoPlaybackItem_liveObject] hyperName];
}

- (void)setEnabled:(BOOL)aEnabled
{
    if (_enabled != aEnabled) {
        [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlaybackEnabledAttribute) ofObject:self withUserInfo:nil];
        _enabled = aEnabled;
        [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlaybackEnabledAttribute) ofObject:self withUserInfo:nil];
    }
}

- (BOOL)isEnabled
{
    return _enabled;
}

- (id)liveObjectForCard:(id)aCard
{
    if (_playableLiveObject && _cardForPlayableLiveObject == aCard)
        return _playableLiveObject;

    HSLiveObject *liveObject = [self HSLiveVideoPlaybackItem_liveObject];
    if ([liveObject hyperParent] && aCard
        && [[[liveObject hyperParent] hyperObject] hyperIdentifier] != [[aCard hyperObject] hyperIdentifier]) {
        // The live object is on another card: use the one sharing its data
        // on this card, or a copy.
        HSLiveObject *cardLiveObject = nil;
        if ([liveObject sharedNodeDataUID]) {
            NSEnumerator *enumerator = [[[[liveObject nodeData] owner] objectsWithNodeDataUID:[liveObject sharedNodeDataUID]] objectEnumerator];
            while ((cardLiveObject = [enumerator nextObject])) {
                if ([[[cardLiveObject hyperParent] hyperObject] hyperIdentifier] == [[aCard hyperObject] hyperIdentifier])
                    break;
            }
        }
        if (!cardLiveObject)
            cardLiveObject = [[liveObject copy] autorelease];
        if (cardLiveObject != _liveObject && [cardLiveObject hyperParent]) {
            [_liveObject release];
            [_liveObjectMutableGeometryAttributes release];
            _liveObjectMutableGeometryAttributes = nil;
            _liveObject = [cardLiveObject retain];
        }
        return cardLiveObject;
    }
    if (liveObject && ![liveObject hyperParent] && _liveObjectUID && aCard)
        return [[liveObject copy] autorelease];
    return liveObject;
}

- (id)liveObjectUID
{
    if (_liveObjectUID)
        return _liveObjectUID;
    HSLiveObject *liveObject = _liveObject;
    if (!liveObject)
        liveObject = [self HSLiveVideoPlaybackItem_liveObject];
    return [liveObject hyperUID];
}

- (id)objectUID
{
    return [self liveObjectUID];
}

- (void)stopPlaying
{
    [_playableLiveObject hyperStop];
    [self restoreAttributesOfLiveVideo:_playableLiveObject];
    [self cleanupPlayableLiveObject];
    _actionExecutionContext = nil;
}

- (void)playInActionExecutionContext:(id)aContext
{
    id card = [[self playbackItemSupport] cardForAction];
    [self preparePlayableLiveObjectWithLiveObject:[self liveObjectForCard:card] forCard:card];
    if (_playMovieAction && _playableLiveObject) {
        _actionExecutionContext = aContext;
        if (![_playableLiveObject hyperParent]) {
            [[self undoManager] disableUndoRegistration];
            [aContext addTemporaryPlayableObjectOnCard:_playableLiveObject];
            [[card queryHyperInterface:@protocol(HSNodeContainer)] addTemporaryHyperChild:_playableLiveObject];
            if (![self playOverObjects])
                [aContext addTemporaryPlayableObjectPlacedBottomOnCard:_playableLiveObject];
            [[self undoManager] enableUndoRegistration];
        }
        [self applyAttributesForLiveVideo:_playableLiveObject];
        [_playableLiveObject hyperStart:self];
    }
}

- (void)setLiveVideoPlaybackItemVersion:(id)aVersion
{
}

- (id)liveVideoPlaybackItemVersion
{
    return [NSNumber numberWithFloat:646];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"enabled", @"liveObjectUIDForSaving", @"liveObject", @"playOverObjects", @"liveVideoPlaybackItemVersion", nil];
}

- (void)dealloc
{
    [self cleanupPlayableLiveObject];
    [_liveObjectMutableGeometryAttributes release];
    if ([_liveObject support] == [_playMovieAction nodeSupportForMovie])
        [_liveObject setSupport:nil];
    [_liveObject release];
    [_liveObjectUID release];
    _liveObjectUID = nil;
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[HSLiveVideoPlaybackItem allocWithZone:aZone] initWithExtraDictionary:[self extraDictionaryRepresentation]];
}

- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    NSMutableDictionary *dictionary = [aDictionary mutableCopy];
    id version = [dictionary objectForKey:@"liveVideoPlaybackItemVersion"];
    if (!version || [version floatValue] == 0 || [version floatValue] < 646) {
        // Convert the settings stored by older versions.
        if (![dictionary objectForKey:@"enabled"] && ![dictionary objectForKey:@"isEnabled"])
            _enabled = YES;
        else if ([dictionary objectForKey:@"isEnabled"] && ![dictionary objectForKey:@"enabled"]) {
            _enabled = [[dictionary objectForKey:@"isEnabled"] boolValue];
            [dictionary removeObjectForKey:@"isEnabled"];
            [dictionary removeObjectForKey:[@"geometryNodeUnits" extraKeyForCollection]];
        }
        if ([dictionary objectForKey:@"isTemporary"])
            [dictionary removeObjectForKey:@"isTemporary"];
        if ([dictionary objectForKey:@"temporaryLiveObject"]) {
            _liveObject = [[NSObject objectWithExtraDictionary:[dictionary objectForKey:@"temporaryLiveObject"] zone:[super zone] codingContext:aContext] retain];
            [dictionary removeObjectForKey:@"temporaryLiveObject"];
        }
        if ([dictionary objectForKey:@"liveVideoDeviceIndex"])
            [dictionary removeObjectForKey:@"liveVideoDeviceIndex"];
        if ([dictionary objectForKey:@"liveObjectUID"]) {
            _liveObjectUID = [[NSObject objectWithExtraDictionary:[dictionary objectForKey:@"liveObjectUID"] zone:[super zone] codingContext:aContext] retain];
            [dictionary removeObjectForKey:@"liveObjectUID"];
        }
    }
    self = [super initWithExtraDictionary:dictionary codingContext:aContext];
    [dictionary release];
    return self;
}

- (id)initWithLiveObject:(id)aObject playMovieAction:(id)aAction
{
    self = [super init];
    if (self) {
        if (!aObject || !aAction) {
            [self release];
            return nil;
        }
        _liveObject = [aObject retain];
        if ([aObject hyperParent])
            _liveObjectUID = [[aObject hyperUID] retain];
        _liveObjectMutableGeometryAttributes = [[aObject queryHyperInterface:@protocol(HSMutableGeometryAttributes)] retain];
        [self setPlaybackItemSupport:aAction];
    }
    return self;
}

@end
