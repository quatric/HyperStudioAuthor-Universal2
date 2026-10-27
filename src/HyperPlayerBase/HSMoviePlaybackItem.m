#import "HSMoviePlaybackItem.h"
#import "EXCodingContext.h"
#import "HSActionExecutionContext.h"
#import "HSActionMediaPlayer.h"
#import "HSAttributeNotificationCenter.h"
#import "HSFunctions.h"
#import "HSMovie.h"
#import "HSMovieObject.h"
#import "HSNewMediaAccessor.h"

static BOOL HSMoviePlaybackItemFloatsAreEqual(float aValue1, float aValue2)
{
    float scale1 = aValue1 != 0.0f ? fabsf(aValue1) : 1.0f;
    float scale2 = aValue2 != 0.0f ? fabsf(aValue2) : 1.0f;
    return fabsf(aValue1 - aValue2) <= MAX(scale1, scale2) * 0.0005f;
}

// How a play movie action plays a movie object: the object of a card, or a
// temporary one only the action holds. While it plays, the object takes the
// item's play count, range, volume and fade out time, and gets its own back
// when done.
@implementation HSMoviePlaybackItem

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
    [element addAttribute:[NSXMLNode attributeWithName:@"objectUID" stringValue:[[self movieObjectUID] stringValue]]];
    [element addAttribute:[NSXMLNode attributeWithName:@"showFirstFrame" stringValue:[self showFirstFrame] ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"playOverObjects" stringValue:[self playOverObjects] ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"loopMovie" stringValue:[self loopMovie] ? HSXMLStoring1String : HSXMLStoring0String]];
    [element addAttribute:[NSXMLNode attributeWithName:@"eraseWhenDone" stringValue:[self eraseWhenDone] ? HSXMLStoring1String : HSXMLStoring0String]];
    NSString *playRange = [NSString stringWithFormat:@"%.1f,%.1f", [self playRange].location, [self playRange].length];
    [element addAttribute:[NSXMLNode attributeWithName:@"playRange" stringValue:playRange]];
    [element addAttribute:[NSXMLNode attributeWithName:@"volume" stringValue:[NSString stringWithFormat:@"%.8f", (double)[self volume]]]];
    return element;
}

- (id)XMLElementName
{
    return @"movieSettings";
}

// Stored as a size string, location as the width.
- (void)setPlayRangeForSaving:(id)aSaving
{
    NSSize size = NSSizeFromString(aSaving);
    _playRange = HSMakeTimeRange((float)size.width, (float)size.height);
}

- (id)playRangeForSaving
{
    return NSStringFromSize(NSMakeSize((float)_playRange.location, (float)_playRange.length));
}

- (id)movieObjectMutableGeometryAttributes
{
    if (!_movieMutableGeometryAttributes)
        _movieMutableGeometryAttributes = [[_movieObject queryHyperInterface:@protocol(HSMutableGeometryAttributes)] retain];
    return _movieMutableGeometryAttributes;
}

// A card object out of its card is replaced by the stack's object with its
// UID, and a temporary object showing its first frame by the card's object with
// its UID. The object gets the action's node support unless it is the
// action's own object.
- (id)HSMoviePlaybackItem_movieObject
{
    id child = nil;
    if (![_movieObject hyperParent] && _movieObjectUID)
        child = [[[_playMovieAction stackForAction] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:_movieObjectUID];
    else if (![_movieObject hyperParent] && !_movieObjectUID && _showFirstFrame)
        child = [[[_playMovieAction cardForAction] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:[_movieObject hyperUID]];
    if (child) {
        [_movieObject release];
        _movieObject = [child retain];
        [_movieMutableGeometryAttributes release];
        _movieMutableGeometryAttributes = nil;
    }
    if (_movieObject && ![_movieObject support] && [_playMovieAction nodeSupportForMovie] && [[_playMovieAction objectForAction] hyperIdentifier] != [_movieObject hyperIdentifier])
        [_movieObject setSupport:[_playMovieAction nodeSupportForMovie]];
    return _movieObject;
}

// Only a temporary object is stored with the item.
- (id)movieObject
{
    if (_movieObjectUID && [_movieObject hyperParent])
        return nil;
    return _movieObject;
}

- (void)setMovieObjectUID:(id)aUID
{
    [self setMovieObjectUIDForSaving:aUID];
}

- (void)setMovieObjectUIDForSaving:(id)aSaving
{
    if ([_movieObjectUID isEqual:aSaving])
        return;
    [_movieObjectUID release];
    _movieObjectUID = [aSaving retain];
}

- (id)movieObjectUIDForSaving
{
    return _movieObjectUID;
}

- (void)restoreAttributesOfMovieObject:(id)aObject
{
    [[self undoManager] disableUndoRegistration];
    [aObject setHyperPlayCount:_originalPlayCount];
    if ([self playOverObjects] && ![self showFirstFrame])
        [[aObject queryHyperInterface:@protocol(HSNodeAttributes)] setHyperIndex:_originalIndex];
    [aObject setHyperPlayRange:_originalPlayRange];
    [aObject setHyperVolume:_originalVolume];
    [[aObject movie] setSoundFadeOutTime:_originalSoundFadeOutTime];
    [[self undoManager] enableUndoRegistration];
}

// Remembers the object's own attributes (a temporary object has the item's)
// and gives it the item's. A looping movie plays once in limited mode.
- (void)applyAttributesToMovieObject:(id)aObject
{
    if (!aObject || ![aObject hyperParent])
        return;
    BOOL temporary = [aObject isTemporary];
    if (!temporary)
        _originalPlayCount = (unsigned int)[aObject hyperPlayCount];
    else if ([_actionExecutionContext isInLimitedMode])
        _originalPlayCount = 1;
    else
        _originalPlayCount = (unsigned int)[self playCount];
    [[self undoManager] disableUndoRegistration];
    if ([_actionExecutionContext isInLimitedMode] && [self playCount] == 0)
        [aObject setHyperPlayCount:1];
    else
        [aObject setHyperPlayCount:[self playCount]];
    _originalPlayRange = temporary ? _playRange : [aObject hyperPlayRange];
    [aObject setHyperPlayRange:_playRange];
    _originalVolume = temporary ? _volume : (float)[aObject hyperVolume];
    [aObject setHyperVolume:_volume];
    _originalSoundFadeOutTime = temporary ? _soundFadeOutTime : [[aObject movie] soundFadeOutTime];
    [[aObject movie] setSoundFadeOutTime:_soundFadeOutTime];
    [self applyMoviePositionForMovieObject:aObject];
    [[self undoManager] enableUndoRegistration];
}

// Played over the objects, the object goes on top; a temporary one otherwise
// goes just above the last temporary playable object at the bottom.
- (void)applyMoviePositionForMovieObject:(id)aObject
{
    if (![aObject isTemporary])
        return;
    NSInteger index = 0;
    if (_actionExecutionContext) {
        index = [_actionExecutionContext bottomPositionOfLastTemporaryPlayableObject] + 1;
        if (index < 0)
            index = 0;
    }
    [aObject setHyperIndex:index];
}

- (void)cleanupPlayableMovieObject
{
    _cardForPlayableMovieObject = nil;
    [[self attributeNotificationCenter] removeObserver:self selector:@selector(playableMovieObjectHiddenWillChange:) ofChanges:1 ofAttribute:@protocol(HSCardObjectHiddenAttribute) ofObject:_playableMovieObject];
    [[self attributeNotificationCenter] removeObserver:self selector:@selector(playableMovieObjectHiddenDidChange:) ofChanges:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute) ofObject:_playableMovieObject];
    if ([_playableMovieObject support] == [_playMovieAction nodeSupportForMovie])
        [_playableMovieObject setSupport:nil];
    [_playableMovieObject release];
    _playableMovieObject = nil;
}

- (void)preparePlayableMovieObjectWithMovieObject:(id)aObject forCard:(id)aCard
{
    if (!aObject || _playableMovieObject == aObject)
        return;
    [self cleanupPlayableMovieObject];
    _playableMovieObject = [aObject retain];
    if (![aObject support])
        [_playableMovieObject setSupport:[_playMovieAction nodeSupportForMovie]];
    [[self attributeNotificationCenter] addObserver:self selector:@selector(playableMovieObjectHiddenWillChange:) ofChanges:1 ofAttribute:@protocol(HSCardObjectHiddenAttribute) ofObject:_playableMovieObject withPriority:0.25];
    [[self attributeNotificationCenter] addObserver:self selector:@selector(playableMovieObjectHiddenDidChange:) ofChanges:2 ofAttribute:@protocol(HSCardObjectHiddenAttribute) ofObject:_playableMovieObject withPriority:0.25];
    _cardForPlayableMovieObject = aCard;
}

- (void)willDisconnectFromDocument
{
}

// Takes the attributes older formats kept in the movie object.
- (void)didConnectToDocument
{
    if (!(_oldFormatVersion > 0 && _oldFormatVersion < 1207))
        return;
    id object = [self HSMoviePlaybackItem_movieObject];
    if (object)
        _volume = [object hyperVolume];
    if (_oldFormatVersion >= 1201)
        return;
    if (object)
        _playRange = [object hyperPlayRange];
    if (_oldFormatVersion >= 604)
        return;
    if (object)
        [self setLoopMovie:[object loopMode] == 1];
    if (_oldFormatVersion < 440) {
        _volume = _oldVolume;
        [object setHyperHasController:_oldUseMovieController];
    }
}

- (void)setPlaybackItemSupport:(id)aSupport
{
    [self cleanupPlayableMovieObject];
    if (_movieObject && [_movieObject support] == [_playMovieAction nodeSupportForMovie])
        [_movieObject setSupport:[aSupport nodeSupportForMovie]];
    _playMovieAction = aSupport;
}

- (id)playbackItemSupport
{
    return _playMovieAction;
}

- (void)setSize:(NSSize)aSize
{
    [(id<HSMutableGeometryAttributes>)[self movieObjectMutableGeometryAttributes] setSize:aSize];
}

- (NSSize)size
{
    if (![self movieObjectMutableGeometryAttributes])
        return NSZeroSize;
    return [_movieMutableGeometryAttributes size];
}

- (void)setAffineTransform:(CGAffineTransform)aTransform
{
    [[self movieObjectMutableGeometryAttributes] setAffineTransform:aTransform];
}

- (CGAffineTransform)affineTransform
{
    if (![self movieObjectMutableGeometryAttributes])
        return CGAffineTransformIdentity;
    return [_movieMutableGeometryAttributes affineTransform];
}

// Temporary unless the action's card holds the object.
- (BOOL)isTemporary
{
    id child = [[[_playMovieAction cardForAction] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:[[self HSMoviePlaybackItem_movieObject] hyperUID]];
    if (![child hyperParent])
        return YES;
    return [child isTemporary];
}

- (void)setPlayRange:(struct HSTimeRange)aRange
{
    if (HSEqualTimeRanges(_playRange, aRange))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Play Range" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPlayRange:[self playRange]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlayMoviePlayRangeAttribute) ofObject:self withUserInfo:nil];
    _playRange = aRange;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlayMoviePlayRangeAttribute) ofObject:self withUserInfo:nil];
}

- (struct HSTimeRange)playRange
{
    return _playRange;
}

- (void)setVolume:(CGFloat)aVolume
{
    if (_volume == (float)aVolume)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Volume" value:@"" table:@"UndoManager"]];
    [(HSMoviePlaybackItem *)[[self undoManager] prepareWithInvocationTarget:self] setVolume:[self volume]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSMovieVolumeAttribute) ofObject:self withUserInfo:nil];
    _volume = aVolume;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSMovieVolumeAttribute) ofObject:self withUserInfo:nil];
}

- (CGFloat)volume
{
    return _volume;
}

- (void)setSoundFadeOutTime:(double)aTime
{
    if (HSMoviePlaybackItemFloatsAreEqual((float)_soundFadeOutTime, (float)aTime))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Sound Fade Out Time Change" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSoundFadeOutTime:_soundFadeOutTime];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlayMovieSoundFadeOutTimeAttribute) ofObject:self withUserInfo:nil];
    _soundFadeOutTime = aTime;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlayMovieSoundFadeOutTimeAttribute) ofObject:self withUserInfo:nil];
}

- (double)soundFadeOutTime
{
    return _soundFadeOutTime;
}

- (void)setEraseWhenDone:(BOOL)aDone
{
    if (_eraseWhenDone == aDone)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Erase When Done" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setEraseWhenDone:[self eraseWhenDone]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlayMovieEraseWhenDoneAttribute) ofObject:self withUserInfo:nil];
    _eraseWhenDone = aDone;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlayMovieEraseWhenDoneAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)eraseWhenDone
{
    return _eraseWhenDone;
}

// Kept by the movie object.
- (void)setUseMovieController:(BOOL)aController
{
    id object = [self HSMoviePlaybackItem_movieObject];
    if ([object hyperHasController] == aController)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Use Movie Controller" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setUseMovieController:[self useMovieController]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlayMovieUseMovieControllerAttribute) ofObject:self withUserInfo:nil];
    [object setHyperHasController:aController];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlayMovieUseMovieControllerAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)useMovieController
{
    return [[self HSMoviePlaybackItem_movieObject] hyperHasController];
}

- (void)setPlayCount:(NSUInteger)aCount
{
    if (_playCount == aCount)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Loop Movie" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPlayCount:[self playCount]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlayMovieActionPlayCountAttribute) ofObject:self withUserInfo:nil];
    _playCount = (unsigned int)aCount;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlayMovieActionPlayCountAttribute) ofObject:self withUserInfo:nil];
}

- (NSUInteger)playCount
{
    return _playCount;
}

// A looping movie plays endlessly (play count 0).
- (void)setLoopMovie:(BOOL)aMovie
{
    _playCount = !aMovie;
}

- (BOOL)loopMovie
{
    return _playCount != 1;
}

- (void)setPlayOverObjects:(BOOL)aObjects
{
    if (_playOverObjects == aObjects)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Play Over Objects" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setPlayOverObjects:[self playOverObjects]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlayMoviePlayOverObjectsAttribute) ofObject:self withUserInfo:nil];
    _playOverObjects = aObjects;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlayMoviePlayOverObjectsAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)playOverObjects
{
    return _playOverObjects;
}

- (void)setShowFirstFrame:(BOOL)aFrame
{
    if (_showFirstFrame == aFrame)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Show First Frame" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setShowFirstFrame:[self showFirstFrame]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlayMovieShowFirstFrameAttribute) ofObject:self withUserInfo:nil];
    _showFirstFrame = aFrame;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlayMovieShowFirstFrameAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)showFirstFrame
{
    return _showFirstFrame;
}

- (void)setEnabled:(BOOL)aEnabled
{
    if (_enabled == aEnabled)
        return;
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSPlaybackEnabledAttribute) ofObject:self withUserInfo:nil];
    _enabled = aEnabled;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSPlaybackEnabledAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)isEnabled
{
    return _enabled;
}

// On another card than the object's, the card's object sharing its node data
// (a copy when none does) plays instead, and becomes the item's object when
// it is on a card.
- (id)movieObjectForCard:(id)aCard
{
    id object = _playableMovieObject;
    if (object && _cardForPlayableMovieObject == aCard)
        return object;
    object = [self HSMoviePlaybackItem_movieObject];
    if (![object hyperParent] || !aCard)
        return object;
    NSUInteger cardIdentifier = [[aCard hyperObject] hyperIdentifier];
    if ([[[object hyperParent] hyperObject] hyperIdentifier] == cardIdentifier)
        return object;
    id found = nil;
    if ([object sharedNodeDataUID]) {
        NSEnumerator *objects = [[[[object nodeData] owner] objectsWithNodeDataUID:[object sharedNodeDataUID]] objectEnumerator];
        id candidate;
        while ((candidate = [objects nextObject])) {
            if ([[[candidate hyperParent] hyperObject] hyperIdentifier] == [[aCard hyperObject] hyperIdentifier]) {
                found = candidate;
                break;
            }
        }
    }
    if (!found)
        found = [[object copy] autorelease];
    if (found != _movieObject && [found hyperParent]) {
        [_movieObject release];
        [_movieMutableGeometryAttributes release];
        _movieMutableGeometryAttributes = nil;
        _movieObject = [found retain];
    }
    return found;
}

- (id)movieMediaUID
{
    return [[self HSMoviePlaybackItem_movieObject] mediaUID];
}

- (id)movieObjectUID
{
    if (_movieObjectUID)
        return _movieObjectUID;
    id object = _movieObject ? _movieObject : [self HSMoviePlaybackItem_movieObject];
    return [object hyperUID];
}

- (id)objectUID
{
    return [self movieObjectUID];
}

// Shows the movie's first frame on the action's card as a temporary object.
- (void)showFirstFrameIfNeededInContext:(id)aContext
{
    if (![self showFirstFrame])
        return;
    _actionExecutionContext = aContext;
    id card = [[self playbackItemSupport] cardForAction];
    [self preparePlayableMovieObjectWithMovieObject:[self movieObjectForCard:card] forCard:card];
    if (![_playableMovieObject hyperParent]) {
        [[self undoManager] disableUndoRegistration];
        [aContext addTemporaryPlayableObjectOnCard:_playableMovieObject];
        [[card queryHyperInterface:@protocol(HSNodeContainer)] addTemporaryHyperChild:_playableMovieObject];
        [self applyAttributesToMovieObject:_playableMovieObject];
        [[self undoManager] enableUndoRegistration];
        if (![self playOverObjects])
            [aContext addTemporaryPlayableObjectPlacedBottomOnCard:_playableMovieObject];
    }
    _actionExecutionContext = nil;
}

- (void)stopPlaying
{
    if ([_playableMovieObject isHyperPlaying])
        [[HSActionMediaPlayer sharedActionMediaPlayer] stopMovie:_playableMovieObject];
}

// A movie that played to its end (or a QTVR movie) is hidden when erased when
// done; the object gets its attributes back either way.
- (void)hyperPlayableObjectDidStop:(id)aStop
{
    id movie = [aStop queryHyperInterface:@protocol(HSMovieObjectAttributes)];
    if (!_shouldPauseHiddenMovie) {
        double end = HSMaxTimeRange([movie hyperPlayRange]);
        if ((fabs([movie hyperCurrentTime] - end) <= 0.01 || [movie isHyperQTVR]) && [self eraseWhenDone]) {
            id cardObject = [aStop queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
            if (cardObject && ![cardObject isHiddenInPlayer]) {
                [cardObject setHiddenInPlayer:YES];
                [_actionExecutionContext addMovieHiddenByPlayMovieAction:movie];
            }
        }
    }
    [self restoreAttributesOfMovieObject:movie];
    [_playMovieAction moviePlaybackDidFinish:self];
    [self cleanupPlayableMovieObject];
    _actionExecutionContext = nil;
}

// Puts the object on the card (a temporary one when not there), and plays it
// unless it is hidden. A QTVR movie ends at once.
- (void)playMovieInExecutionContext:(id)aContext
{
    id card = [[self playbackItemSupport] cardForAction];
    HSActionMediaPlayer *player = [HSActionMediaPlayer sharedActionMediaPlayer];
    [aContext restoreMovieHiddenByPlayMovieAction:_playableMovieObject];
    [aContext removeMovieHiddenByPlayMovieAction:_playableMovieObject];
    if (![_playableMovieObject hyperParent]) {
        [[self undoManager] disableUndoRegistration];
        [aContext addTemporaryPlayableObjectOnCard:_playableMovieObject];
        [[card queryHyperInterface:@protocol(HSNodeContainer)] addTemporaryHyperChild:_playableMovieObject];
        [[self undoManager] enableUndoRegistration];
    } else if ([_playableMovieObject isHiddenInPlayer]) {
        return;
    }
    [self applyAttributesToMovieObject:_playableMovieObject];
    if (![self playOverObjects] && ![_playableMovieObject hyperParent])
        [aContext addTemporaryPlayableObjectPlacedBottomOnCard:_playableMovieObject];
    if ([_playableMovieObject isHyperQTVR])
        [self hyperPlayableObjectDidStop:_playableMovieObject];
    else
        [player playMovie:_playableMovieObject movieOwner:self];
}

// Hiding the object stops it; showing it again plays it.
- (void)playableMovieObjectHiddenDidChange:(id)aChange
{
    if ([_playableMovieObject isHiddenInPlayer]) {
        if ([_playableMovieObject isHyperPlaying])
            [_playableMovieObject hyperStop];
    } else if (_actionExecutionContext) {
        [self playMovieInExecutionContext:_actionExecutionContext];
    }
}

- (void)playableMovieObjectHiddenWillChange:(id)aChange
{
    _shouldPauseHiddenMovie = ![_playableMovieObject isHiddenInPlayer];
}

- (void)playInActionExecutionContext:(id)aContext
{
    id card = [[self playbackItemSupport] cardForAction];
    [self preparePlayableMovieObjectWithMovieObject:[self movieObjectForCard:card] forCard:card];
    if (!_playableMovieObject)
        return;
    _actionExecutionContext = aContext;
    if ([_playableMovieObject isHyperPlaying])
        [_playableMovieObject hyperStop];
    [_playableMovieObject setHyperCurrentTime:[self playRange].location];
    [self playMovieInExecutionContext:aContext];
}

- (void)setMoviePlaybackItemVersion:(id)aVersion
{
}

- (id)moviePlaybackItemVersion
{
    return [NSNumber numberWithFloat:1207];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [[super keysForExtraLoadingWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"useMovieController", @"volume", @"isEnabled", nil]];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithObjects:@"showFirstFrame", @"movieObjectUIDForSaving", @"movieObject", @"playOverObjects", @"eraseWhenDone", @"enabled", @"playRangeForSaving", @"volume", @"moviePlaybackItemVersion", @"soundFadeOutTime", @"playCount", nil];
    if (_playCount < 2)
        [keys addObject:@"loopMovie"];
    return keys;
}

- (NSUInteger)hash
{
    CGAffineTransform transform = [self affineTransform];
    NSSize size = [self size];
    NSUInteger flags = [_movieObject hash] + [_movieObjectUID hash] + _playCount + _showFirstFrame + _playOverObjects + [self useMovieController] + _eraseWhenDone;
    double sum = (double)(float)transform.ty + (float)transform.tx + (float)transform.d + (float)transform.c + (float)transform.b + (float)transform.a + (float)size.width + (float)size.height + (double)(unsigned int)flags + [self playRange].location + [self playRange].length;
    return (NSUInteger)(long long)sum;
}

- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[HSMoviePlaybackItem class]])
        return NO;
    HSMoviePlaybackItem *item = aEqual;
    if (_playCount != [item playCount])
        return NO;
    if (!HSMoviePlaybackItemFloatsAreEqual((float)_soundFadeOutTime, (float)[item soundFadeOutTime]))
        return NO;
    if (!HSMoviePlaybackItemFloatsAreEqual([self volume], [item volume]))
        return NO;
    if (_showFirstFrame != [item showFirstFrame] || _playOverObjects != [item playOverObjects])
        return NO;
    if ([self useMovieController] != [item useMovieController] || _eraseWhenDone != [item eraseWhenDone])
        return NO;
    if (!HSEqualTimeRanges([self playRange], [item playRange]))
        return NO;
    if (![[self movieObjectUID] isEqual:[item movieObjectUID]])
        return NO;
    if (![_movieObject isEqual:[item movieObjectForCard:nil]])
        return NO;
    if (!NSEqualSizes([self size], [item size]))
        return NO;
    return CGAffineTransformEqualToTransform([self affineTransform], [item affineTransform]);
}

- (void)dealloc
{
    [self cleanupPlayableMovieObject];
    [_movieMutableGeometryAttributes release];
    [_movieObjectUID release];
    if ([_movieObject support] == [_playMovieAction nodeSupportForMovie])
        [_movieObject setSupport:nil];
    [_movieObject release];
    [super dealloc];
}

// As in the original, the copy has no play movie action.
- (id)copyWithZone:(NSZone *)aZone
{
    return [[HSMoviePlaybackItem allocWithZone:aZone] initWithExtraDictionary:[self extraDictionaryRepresentation]];
}

// The keys present tell the format version; older formats keep a temporary
// movie object and its UID as dictionaries, and some attributes elsewhere.
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    NSMutableDictionary *dictionary = [[aDictionary mutableCopy] autorelease];
    if ([dictionary objectForKey:@"playCount"]) {
        _oldFormatVersion = 1330;
    } else if ([dictionary objectForKey:@"soundFadeOutTime"]) {
        _oldFormatVersion = 1302;
    } else if ([dictionary objectForKey:@"volume"]) {
        _oldFormatVersion = 1207;
    } else if ([dictionary objectForKey:@"playRangeForSaving"]) {
        _oldFormatVersion = 1201;
    } else if ([dictionary objectForKey:@"movieObjectUIDForSaving"]) {
        _oldFormatVersion = 604;
    } else {
        id enabled = [dictionary objectForKey:@"enabled"];
        id isEnabled = [dictionary objectForKey:@"isEnabled"];
        if (!isEnabled && !enabled) {
            _enabled = YES;
            _oldFormatVersion = 440;
        } else if (!isEnabled || enabled) {
            _oldFormatVersion = 603;
        } else {
            _oldUseMovieController = [[dictionary objectForKey:@"useMovieController"] boolValue];
            _oldVolume = [[dictionary objectForKey:@"volume"] floatValue];
            _enabled = [[dictionary objectForKey:@"isEnabled"] boolValue];
            [dictionary removeObjectForKey:@"showLiveVideo"];
            [dictionary removeObjectForKey:@"useMovieController"];
            [dictionary removeObjectForKey:@"isEnabled"];
            [dictionary removeObjectForKey:@"volume"];
            [dictionary removeObjectForKey:[@"geometryNodeUnits" extraKeyForCollection]];
            _oldFormatVersion = 407;
        }
        if ([dictionary objectForKey:@"temporaryMovieObject"]) {
            _movieObject = [[NSObject objectWithExtraDictionary:[dictionary objectForKey:@"temporaryMovieObject"] zone:[super zone] codingContext:aContext] retain];
            [dictionary removeObjectForKey:@"temporaryMovieObject"];
        }
        if ([dictionary objectForKey:@"movieMediaUID"])
            [dictionary removeObjectForKey:@"movieMediaUID"];
        if ([dictionary objectForKey:@"movieObjectUID"]) {
            _movieObjectUID = [[NSObject objectWithExtraDictionary:[dictionary objectForKey:@"movieObjectUID"] zone:[super zone] codingContext:aContext] retain];
            [dictionary removeObjectForKey:@"movieObjectUID"];
        }
    }
    if (![dictionary objectForKey:@"playCount"])
        _playCount = ![[dictionary objectForKey:@"loopMovie"] boolValue];
    return [super initWithExtraDictionary:dictionary codingContext:aContext];
}

// A card object is found again by its UID; one off the cards plays over the
// objects.
- (id)initWithMovieObject:(id)aObject playMovieAction:(id)aAction
{
    self = [super init];
    if (!self)
        return nil;
    if (!aObject || !aAction) {
        [self release];
        return nil;
    }
    _movieObject = [aObject retain];
    if (![aObject hyperParent])
        _playOverObjects = YES;
    else
        _movieObjectUID = [[aObject hyperUID] retain];
    _movieMutableGeometryAttributes = [[_movieObject queryHyperInterface:@protocol(HSMutableGeometryAttributes)] retain];
    _playRange = [_movieObject hyperPlayRange];
    _volume = [_movieObject hyperVolume];
    _playCount = 1;
    [self setPlaybackItemSupport:aAction];
    return self;
}

- (id)initWithMediaUID:(id)aUID playMovieAction:(id)aAction
{
    self = [super init];
    if (!self)
        return nil;
    if (aUID && aAction) {
        _movieObject = [[HSMovieObject alloc] initWithMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
        _movieMutableGeometryAttributes = [[_movieObject queryHyperInterface:@protocol(HSMutableGeometryAttributes)] retain];
        _playRange = [_movieObject hyperPlayRange];
        _volume = [_movieObject hyperVolume];
        _playCount = 1;
        [self setPlaybackItemSupport:aAction];
    }
    if (!_movieObject) {
        [self release];
        return nil;
    }
    return self;
}

@end

@implementation HSMoviePlaybackItem (HSMoviePlaybackItemDeprecated)

- (void)setGeometryNodeUnits:(id)aUnits
{
}

- (id)geometryNodeUnits
{
    return nil;
}

@end
