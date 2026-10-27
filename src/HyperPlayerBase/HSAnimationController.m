#import "HSAnimationController.h"
#import "HSAnimation.h"
#import "HSAnimationPositioning.h"
#import "HSFunctions.h"
#import "HSPlayAnimationAction.h"
#import "HSUID.h"

// The playing animations dictionary is keyed by animations, which compare by
// their animation UID; a bare HSUID also works as a key, so a UID can be looked
// up directly.
static id HSAnimationKeyUID(id aKey)
{
    return [aKey isKindOfClass:[HSUID class]] ? aKey : [aKey animationUID];
}

static const void *HSAnimationKeyRetain(CFAllocatorRef aAllocator, const void *aValue)
{
    return [(id)aValue retain];
}

static void HSAnimationKeyRelease(CFAllocatorRef aAllocator, const void *aValue)
{
    [(id)aValue release];
}

static CFStringRef HSAnimationKeyCopyDescription(const void *aValue)
{
    return (CFStringRef)[[(id)aValue description] retain];
}

static Boolean HSAnimationKeyEqual(const void *aValue, const void *aValue2)
{
    id uid = HSAnimationKeyUID((id)aValue);
    id uid2 = HSAnimationKeyUID((id)aValue2);
    if (uid == nil)
        return uid2 == nil;
    if (uid2 == nil)
        return NO;
    return [uid isEqual:uid2];
}

static CFHashCode HSAnimationKeyHash(const void *aValue)
{
    return [HSAnimationKeyUID((id)aValue) hash];
}

// Plays the animations of a card. Animated objects are temporary card children
// placed by the animation's layer: at the bottom or the top of the card, or
// right over the object whose action started the animation.
@implementation HSAnimationController

- (void)removeAllTemporaryButAnimationsObjects
{
    [(HSCard *)_owner removeAllTemporaryObjectsForAnimationController:self exceptObjects:[self temporaryAnimationsObjects]];
}

- (void)removeAllTemporaryObjects
{
    [(HSCard *)_owner removeTemporaryObjects:_temporaryAnimationsObjects];
    _bottomAnimationsCountOnAbsoluteLayerBottom = 0;
    _bottomAnimationsCountOnAbsoluteLayerTop = 0;
}

- (void)removeTemporaryObjects:(id)aObjects
{
    for (id object in aObjects)
        [_temporaryAnimationsObjects removeObject:object];
    [(HSCard *)_owner removeTemporaryObjects:aObjects];
}

// An animation going to one absolute layer and returning to another moves its
// object when it turns around.
- (void)animationDirectionDidChange:(id)aChange
{
    HSAnimation *animation = [aChange object];
    if ([animation goingAbsoluteLayer] == [animation returningAbsoluteLayer])
        return;
    BOOL isReturning = [[[aChange userInfo] objectForKey:HSAnimationIsReturningKey] boolValue];
    NSRange below = [(HSCard *)_owner rangeOfTemporaryObjectsBelowForAnimationController:self];
    NSRange over = [(HSCard *)_owner rangeOfTemporaryObjectsOverForAnimationController:self];
    if (NSMaxRange(below) >= over.location)
        return;
    NSInteger oldLayer = isReturning ? [animation goingAbsoluteLayer] : [animation returningAbsoluteLayer];
    if ([animation layer] == 0) {
        if (oldLayer == 0)
            _bottomAnimationsCountOnAbsoluteLayerBottom--;
        else if (oldLayer == 1)
            _bottomAnimationsCountOnAbsoluteLayerTop--;
    }
    NSInteger newLayer = isReturning ? [animation returningAbsoluteLayer] : [animation goingAbsoluteLayer];
    [self changeObjectIndexOnStartingAnimation:animation inAbsoluteLayer:newLayer forActingObject:(id)CFDictionaryGetValue(_playingAnimations, animation)];
}

// A finished temporary object stays on the card when its animation keeps the
// last frame and played to the end the first time; otherwise it is removed.
- (void)animationPlaybackDidEnd:(id)aEnd
{
    HSAnimation *animation = [[aEnd object] retain];
    CFDictionaryRemoveValue(_playingAnimations, animation);
    id animatedObject = [animation animatedObject];
    [animatedObject endContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSHorizontalOffsetAttribute), @protocol(HSVerticalOffsetAttribute), nil]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationDirectionDidChangeNotification object:animation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationPlaybackDidEndNotification object:animation];
    if ([animatedObject isTemporary]) {
        BOOL keep = NO;
        if (![animation hideOnLastFrame]) {
            double duration = [animation playbackDuration];
            if (duration == -1.0)
                duration = [animation movieDuration];
            double time = [animation playbackTime];
            keep = [_finishedObjects objectForKey:[animation animationUID]] == nil && time >= duration;
        }
        if (keep) {
            [_finishedObjects setObject:animatedObject forKey:[animation animationUID]];
        } else {
            if ([animation layer] == 0) {
                NSInteger layer = [animation wasReturning] ? [animation returningAbsoluteLayer] : [animation goingAbsoluteLayer];
                if (layer == 0)
                    _bottomAnimationsCountOnAbsoluteLayerBottom--;
                else if (layer == 1)
                    _bottomAnimationsCountOnAbsoluteLayerTop--;
            }
            [(HSCard *)_owner animationController:self removeObject:animatedObject];
        }
    }
    [animation autorelease];
}

- (void)changeObjectIndexOnStartingAnimation:(id)aAnimation inAbsoluteLayer:(NSInteger)aLayer forActingObject:(id)aObject
{
    if ([(HSAnimation *)aAnimation layer] == 0) {
        if (aLayer == 0)
            _bottomAnimationsCountOnAbsoluteLayerBottom++;
        else if (aLayer == 1)
            _bottomAnimationsCountOnAbsoluteLayerTop++;
    }
    NSUInteger index = [self indexForObjectReplacementForAnimation:aAnimation inAbsoluteLayer:aLayer forActingObject:aObject];
    [(HSCard *)_owner animationController:self moveObject:[(HSAnimation *)aAnimation animatedObject] toIndex:index];
}

// The insertion index, less one when the object already sits below it.
- (NSUInteger)indexForObjectReplacementForAnimation:(id)aAnimation inAbsoluteLayer:(NSInteger)aLayer forActingObject:(id)aObject
{
    NSUInteger index = [self indexForObjectInsertionForAnimation:aAnimation inAbsoluteLayer:aLayer forActingObject:aObject];
    id animatedObject;
    if (index != NSNotFound && (animatedObject = [(HSAnimation *)aAnimation animatedObject]) != nil) {
        NSUInteger current = [(HSCard *)_owner indexOfObject:animatedObject forAnimationController:self];
        if (current != NSNotFound && current < index)
            return index - 1;
    }
    return index;
}

// Absolute layers: 0 bottom of the card, 1 top of the card, 2 over the acting
// object. Animation layers: 0 bottom, 1 middle, 2 top within the place.
- (NSUInteger)indexForObjectInsertionForAnimation:(id)aAnimation inAbsoluteLayer:(NSInteger)aLayer forActingObject:(id)aObject
{
    NSInteger layer;
    if (aLayer == 0) {
        layer = [(HSAnimation *)aAnimation layer];
        if (layer == 2)
            return NSMaxRange([(HSCard *)_owner rangeOfTemporaryObjectsBelowForAnimationController:self]);
        if (layer == 1)
            return _bottomAnimationsCountOnAbsoluteLayerBottom;
        if (layer == 0)
            return 0;
    } else if (aLayer == 1) {
        layer = [(HSAnimation *)aAnimation layer];
        if (layer == 2)
            return [(HSCard *)_owner objectCountForAnimationController:self];
        if (layer == 1)
            return [(HSCard *)_owner rangeOfTemporaryObjectsOverForAnimationController:self].location + _bottomAnimationsCountOnAbsoluteLayerTop;
        if (layer == 0)
            return [(HSCard *)_owner rangeOfTemporaryObjectsOverForAnimationController:self].location;
    } else if (aLayer == 2) {
        layer = [(HSAnimation *)aAnimation layer];
        BOOL isCardOrStack = aObject == nil || [aObject implementsHyperInterface:@protocol(HSCardAttributes)] || [aObject implementsHyperInterface:@protocol(HSStackAttributes)];
        if (layer == 2) {
            if (isCardOrStack)
                return NSMaxRange([(HSCard *)_owner rangeOfTemporaryObjectsBelowForAnimationController:self]);
            id child = [aObject queryHyperInterface:@protocol(HSNodeChild)];
            if (child == nil)
                return NSNotFound;
            return NSMaxRange([(HSCard *)_owner rangeOfTemporaryObjectsOverActingObject:child forAnimationController:self]);
        }
        if (layer == 0 || layer == 1) {
            if (isCardOrStack || [aObject queryHyperInterface:@protocol(HSHypertextLink)] != nil)
                return 0;
            id child = [aObject queryHyperInterface:@protocol(HSNodeChild)];
            if (child == nil)
                return NSNotFound;
            return [child hyperIndex] + 1;
        }
    }
    return NSNotFound;
}

- (void)addAnimatedObject:(id)aObject toCardForAnimation:(id)aAnimation forActingObject:(id)aObject2
{
    NSInteger layer = [(HSAnimation *)aAnimation goingAbsoluteLayer];
    if (layer == 1 && aObject2 != nil)
        layer = 2;
    NSUInteger index = [self indexForObjectInsertionForAnimation:aAnimation inAbsoluteLayer:layer forActingObject:aObject2];
    [self addAnimatedObject:aObject toCardForAnimation:aAnimation atIndex:index];
}

- (void)addAnimatedObject:(id)aObject toCardForAnimation:(id)aAnimation atIndex:(NSInteger)aIndex
{
    [[aObject queryHyperInterface:@protocol(HSMutableCardObjectAttributes)] setHidden:NO];
    [[self temporaryAnimationsObjects] addObject:aObject];
    [(HSCard *)_owner animationController:self addTemporaryObject:aObject atIndex:aIndex];
    [[(HSCard *)_owner undoManagerForAnimationController:self] disableUndoRegistration];
    [HSAnimationPositioning setPosition:[(HSAnimation *)aAnimation pathPointAtTime:[(HSAnimation *)aAnimation startPathTime]] ofObject:aObject];
    [[(HSCard *)_owner undoManagerForAnimationController:self] enableUndoRegistration];
}

- (BOOL)isPlayingAnimationWithUID:(id)aUID
{
    return CFDictionaryContainsKey(_playingAnimations, aUID);
}

- (id)playingAnimationAnimatingObject:(id)aObject
{
    for (HSAnimation *animation in (NSDictionary *)_playingAnimations) {
        if ([animation animatedObject] == aObject)
            return animation;
    }
    return nil;
}

- (id)playingAnimations
{
    return [(NSDictionary *)_playingAnimations allKeys];
}

- (void)resumeAllPlayingAnimations
{
    [[self playingAnimations] makeObjectsPerformSelector:@selector(resume)];
}

- (void)pauseAllPlayingAnimations
{
    [[self playingAnimations] makeObjectsPerformSelector:@selector(pause)];
}

- (void)stopAllPlayingAnimations
{
    CFIndex count = CFDictionaryGetCount(_playingAnimations);
    const void **animations;
    if (count == 0 || (animations = malloc(count * sizeof(void *))) == NULL)
        return;
    CFDictionaryGetKeysAndValues(_playingAnimations, animations, NULL);
    for (CFIndex i = 0; i < count; i++) {
        [(HSAnimation *)animations[i] stop];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationDirectionDidChangeNotification object:(id)animations[i]];
    }
    free(animations);
    CFDictionaryRemoveAllValues(_playingAnimations);
}

- (void)stopAnimation:(id)aAnimation
{
    [(HSAnimation *)aAnimation stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationDirectionDidChangeNotification object:aAnimation];
    CFDictionaryRemoveValue(_playingAnimations, aAnimation);
}

// Plays a copy of the animation on its own animated object, without adding a
// temporary object to the card. An animation already playing is started again
// only when it uses clones.
- (id)startAnimationWithoutCopyingAnimatedObject:(id)aObject
{
    if ([self isPlayingAnimationWithUID:[aObject animationUID]] && ![aObject useClones])
        return nil;
    HSAnimation *animation = [[aObject copy] autorelease];
    [animation setAnimatedObject:[aObject animatedObject]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationPlaybackDidEnd:) name:HSAnimationPlaybackDidEndNotification object:animation];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationDirectionDidChange:) name:HSAnimationDirectionDidChangeNotification object:animation];
    CFDictionarySetValue(_playingAnimations, animation, NULL);
    [animation start];
    return animation;
}

// Copies the animation and puts its animated object on the card: the object
// prepared for the first frame when there is one, else a fresh temporary copy.
- (id)prepareToStartAnimation:(id)aAnimation forActingObject:(id)aObject
{
    if ([self isPlayingAnimationWithUID:[(HSAnimation *)aAnimation animationUID]] && ![(HSAnimation *)aAnimation useClones])
        return nil;
    HSAnimation *animation = [[(HSAnimation *)aAnimation copy] autorelease];
    id prepared = [_preparedObjects objectForKey:[animation animationUID]];
    if (prepared == nil) {
        if ([(HSAnimation *)aAnimation useClones])
            [animation setAnimationUID:[HSUID UID]];
        [[animation animatedObject] setHyperUID:[HSUID UID]];
        [self addAnimatedObject:[animation animatedObject] toCardForAnimation:animation forActingObject:aObject];
    } else {
        [animation setAnimatedObject:prepared];
        [_preparedObjects removeObjectForKey:[animation animationUID]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationDirectionDidChange:) name:HSAnimationDirectionDidChangeNotification object:animation];
    CFDictionarySetValue(_playingAnimations, animation, aObject);
    return animation;
}

// Animations started inside a continuous run of play animation actions wait
// paused until the run ends, so they all start together.
- (id)startAnimation:(id)aAnimation forActingObject:(id)aObject
{
    HSAnimation *animation = [self prepareToStartAnimation:aAnimation forActingObject:aObject];
    if (animation != nil) {
        [self changeObjectIndexOnStartingAnimation:animation inAbsoluteLayer:[animation goingAbsoluteLayer] forActingObject:aObject];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animationPlaybackDidEnd:) name:HSAnimationPlaybackDidEndNotification object:animation];
        [animation start];
        if ([self isInContiniousPlayAnimationActionsStarting]) {
            [animation pause];
            if (_pausedAnimations == nil)
                _pausedAnimations = [[NSMutableArray array] retain];
            [_pausedAnimations addObject:animation];
        }
    }
    return animation;
}

- (void)endContiniousPlayAnimationActionsStarting
{
    if (--_continiousActionsStartingCount == 0) {
        [_pausedAnimations makeObjectsPerformSelector:@selector(resume)];
        [_pausedAnimations release];
        _pausedAnimations = nil;
    }
}

- (void)beginContiniousPlayAnimationActionsStarting
{
    _continiousActionsStartingCount++;
}

- (BOOL)isInContiniousPlayAnimationActionsStarting
{
    return _continiousActionsStartingCount > 0;
}

- (void)cleanUpAfterTryIt
{
    [self stopAllPlayingAnimations];
    [self removeAllTemporaryObjects];
    [_finishedObjects removeAllObjects];
}

- (void)prepareForTryItAnimation:(id)aAnimation
{
    [self removeAllTemporaryObjects];
    [_preparedObjects removeAllObjects];
    [_finishedObjects removeAllObjects];
}

- (void)presentationIsStarting
{
    [self removeAllTemporaryObjects];
    [_preparedObjects removeAllObjects];
    [self addAllShowFirstFrameAnimatedObjectsToCard:YES toPreparedObjects:YES playLiveVideo:YES];
    [_finishedObjects removeAllObjects];
}

// Animations that show their first frame before playing get a copy of their
// animated object on the card in advance.
- (void)addAllShowFirstFrameAnimatedObjectsToCard:(BOOL)aCard toPreparedObjects:(BOOL)aObjects playLiveVideo:(BOOL)aVideo
{
    [self addAllShowFirstFrameAnimatedObjectsToCard:aCard toPreparedObjects:aObjects playLiveVideo:aVideo addedToCardObjects:nil];
}

// The objects put on the card are also collected into aAdded, so the caller
// can take them off again.
- (void)addAllShowFirstFrameAnimatedObjectsToCard:(BOOL)aCard toPreparedObjects:(BOOL)aObjects playLiveVideo:(BOOL)aVideo addedToCardObjects:(id)aAdded
{
    if (!aObjects && !aCard)
        return;
    NSEnumerator *enumerator = [[(HSCard *)_owner allPlayAnimationActionsForAnimationController:self] objectEnumerator];
    HSPlayAnimationAction *action;
    while ((action = [enumerator nextObject]) != nil) {
        HSAnimation *animation = [action animation];
        if (animation == nil || [animation animatedObject] == nil || [animation hideOnFirstFrame])
            continue;
        id object = [[animation animatedObject] localCopyIncludingNodeUnits:YES];
        [object setHyperUID:[HSUID UID]];
        if (aObjects)
            [_preparedObjects setObject:object forKey:[animation animationUID]];
        if (aCard) {
            [self addAnimatedObject:object toCardForAnimation:animation forActingObject:[action hyperObject]];
            [aAdded addObject:object];
        }
        if (aVideo) {
            id liveObject = [object queryHyperInterface:@protocol(HSLiveObjectAttributes)];
            if (liveObject != nil)
                [liveObject hyperStart:self];
        }
        [object release];
    }
}

- (id)temporaryAnimationsObjects
{
    if (_temporaryAnimationsObjects == nil)
        _temporaryAnimationsObjects = [NSMutableSet new];
    return _temporaryAnimationsObjects;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationDirectionDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSAnimationPlaybackDidEndNotification object:nil];
    [_finishedObjects release];
    [_preparedObjects release];
    if (_playingAnimations != NULL)
        CFRelease(_playingAnimations);
    [_pausedAnimations release];
    [_temporaryAnimationsObjects release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        CFDictionaryKeyCallBacks keyCallBacks = {0, HSAnimationKeyRetain, HSAnimationKeyRelease, HSAnimationKeyCopyDescription, HSAnimationKeyEqual, HSAnimationKeyHash};
        _playingAnimations = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &keyCallBacks, &HSCFTypeOrNullCFDictionaryValueCallBacks);
        if (_playingAnimations != NULL) {
            _preparedObjects = [NSMutableDictionary new];
            if (_preparedObjects != nil) {
                _finishedObjects = [NSMutableDictionary new];
                if (_finishedObjects != nil)
                    return self;
            }
        }
        [self release];
    }
    return nil;
}

// While a card is exported to an image its show-first-frame animated objects
// are put on the card temporarily.
- (void)exportCardToImageWillStart
{
    if (_addedObjectsWhileExportCardToImage == nil)
        _addedObjectsWhileExportCardToImage = [NSMutableSet new];
    unsigned int top = _bottomAnimationsCountOnAbsoluteLayerTop;
    unsigned int bottom = _bottomAnimationsCountOnAbsoluteLayerBottom;
    [self addAllShowFirstFrameAnimatedObjectsToCard:YES toPreparedObjects:NO playLiveVideo:NO addedToCardObjects:_addedObjectsWhileExportCardToImage];
    _bottomAnimationsCountOnAbsoluteLayerTopInc = _bottomAnimationsCountOnAbsoluteLayerTop - top;
    _bottomAnimationsCountOnAbsoluteLayerBottomInc = _bottomAnimationsCountOnAbsoluteLayerBottom - bottom;
}

- (void)exportCardToImageDidEnd
{
    [self removeTemporaryObjects:_addedObjectsWhileExportCardToImage];
    [_addedObjectsWhileExportCardToImage release];
    _addedObjectsWhileExportCardToImage = nil;
    _bottomAnimationsCountOnAbsoluteLayerTop -= _bottomAnimationsCountOnAbsoluteLayerTopInc;
    _bottomAnimationsCountOnAbsoluteLayerBottom -= _bottomAnimationsCountOnAbsoluteLayerBottomInc;
    _bottomAnimationsCountOnAbsoluteLayerTopInc = 0;
    _bottomAnimationsCountOnAbsoluteLayerBottomInc = 0;
    [self stopAllPlayingAnimations];
}

// Cards, stacks and hypertext links are not part of the object order.
- (BOOL)isNonIndexedObject:(id)aObject
{
    if (aObject == nil)
        return YES;
    if ([aObject implementsHyperInterface:@protocol(HSCardAttributes)])
        return YES;
    if ([aObject implementsHyperInterface:@protocol(HSStackAttributes)])
        return YES;
    return [aObject queryHyperInterface:@protocol(HSHypertextLink)] != nil;
}

@end

@implementation HSCard (HSAnimationControllerOwner)

- (id)undoManagerForAnimationController:(id)aController
{
    return [self undoManager];
}

- (id)allPlayAnimationActionsForAnimationController:(id)aController
{
    NSMutableArray *actions = [NSMutableArray new];
    NSMutableArray *actors = [NSMutableArray new];
    [actors addObjectsFromArray:[self hyperChildren]];
    [actors addObject:self];
    NSEnumerator *enumerator = [actors objectEnumerator];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        id actor = [object queryHyperInterface:@protocol(HSActor)];
        if (actor != nil)
            [actions addObjectsFromArray:[actor hyperActionsOfType:[HSPlayAnimationAction actionType]]];
    }
    [actors release];
    return [actions autorelease];
}

- (void)removeTemporaryObjects:(id)aObjects
{
    NSEnumerator *enumerator = [self hyperLoadedNodeEnumerator];
    id node;
    while ((node = [enumerator nextObject]) != nil) {
        if ([node isTemporary] && [aObjects containsObject:node]) {
            [[self undoManager] disableUndoRegistration];
            [self removeChild:node];
            [[self undoManager] enableUndoRegistration];
        }
    }
}

- (void)removeAllTemporaryObjectsForAnimationController:(id)aController exceptObjects:(id)aObjects
{
    NSEnumerator *enumerator = [self hyperLoadedNodeEnumerator];
    id node;
    while ((node = [enumerator nextObject]) != nil) {
        if ([node isTemporary] && ![aObjects containsObject:node]) {
            [[self undoManager] disableUndoRegistration];
            [self removeChild:node];
            [[self undoManager] enableUndoRegistration];
        }
    }
}

- (void)animationController:(id)aController moveObject:(id)aObject toIndex:(NSUInteger)aIndex
{
    [[self undoManager] disableUndoRegistration];
    [self setIndex:aIndex ofHyperChild:aObject];
    [[self undoManager] enableUndoRegistration];
}

- (void)animationController:(id)aController removeObject:(id)aObject
{
    [[self undoManager] disableUndoRegistration];
    [self removeChild:[aObject queryHyperInterface:@protocol(HSNodeChild)]];
    [[self undoManager] enableUndoRegistration];
}

- (void)animationController:(id)aController addTemporaryObject:(id)aObject atIndex:(NSUInteger)aIndex
{
    [[self undoManager] disableUndoRegistration];
    [self insertTemporaryHyperChild:aObject atIndex:aIndex];
    [[self undoManager] enableUndoRegistration];
}

// The animated objects at the bottom of the card.
- (NSRange)rangeOfTemporaryObjectsBelowForAnimationController:(id)aController
{
    NSUInteger count = 0;
    while (count < [self hyperCount] && [self isAnimatedObject:[self hyperChildAtIndex:count]])
        count++;
    return NSMakeRange(0, count);
}

// The animated objects at the top of the card.
- (NSRange)rangeOfTemporaryObjectsOverForAnimationController:(id)aController
{
    NSUInteger total = [self hyperCount];
    NSUInteger count = 0;
    while (count != total && [self isAnimatedObject:[self hyperChildAtIndex:total - 1 - count]])
        count++;
    return NSMakeRange(total - count, count);
}

// Quirk kept: despite the name this spans the objects over the acting object
// up to the next animated one, so animations land below other animations.
- (NSRange)rangeOfTemporaryObjectsOverActingObject:(id)aObject forAnimationController:(id)aController
{
    NSArray *children = [self children];
    if (children == nil)
        return NSMakeRange(NSNotFound, 0);
    NSUInteger index = [children indexOfObject:aObject];
    if (index == NSNotFound)
        return NSMakeRange(NSNotFound, 0);
    NSUInteger location = index + 1;
    NSUInteger count = [children count];
    NSUInteger length = 0;
    while (location + length < count && ![self isAnimatedObject:[children objectAtIndex:location + length]])
        length++;
    return NSMakeRange(location, length);
}

- (BOOL)isAnimatedObject:(id)aObject
{
    return [[[self animationController] temporaryAnimationsObjects] containsObject:aObject];
}

- (NSUInteger)indexOfObject:(id)aObject forAnimationController:(id)aController
{
    NSArray *children = [self children];
    if (children == nil)
        return NSNotFound;
    return [children indexOfObject:aObject];
}

- (NSUInteger)objectCountForAnimationController:(id)aController
{
    return [[self children] count];
}

@end
