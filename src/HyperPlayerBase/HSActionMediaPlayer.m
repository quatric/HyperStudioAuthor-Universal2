#import "HSActionMediaPlayer.h"
#import "HSActionEvent.h"
#import "HSMovie.h"
#import "NSMutableArray+EXMutableArray.h"
#import "SMKSpeechManager.h"

// The shared player of the sounds and movies started by actions. Each sound
// is recorded (keyed by a non-retained NSValue) with the action, the sound
// item and the owner (the object's card, or the card/stack itself); one
// foreground sound plays at a time per stack, background sounds play alongside;
// the sounds are kept per stack (by its UID). Movies
// are mapped to their attributes (their owner to tell when they stop).

static HSActionMediaPlayer *sSharedActionMediaPlayer = nil;

@implementation HSActionMediaPlayer

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized (self) {
        if (sSharedActionMediaPlayer == nil)
            sSharedActionMediaPlayer = [super allocWithZone:aZone];
    }
    return sSharedActionMediaPlayer;
}

+ (id)sharedActionMediaPlayer
{
    @synchronized (self) {
        if (sSharedActionMediaPlayer == nil)
            [[self alloc] init];
    }
    return sSharedActionMediaPlayer;
}

// Objects other than cards and stacks are owned by their card.
static id HSActionMediaPlayerOwnerForObject(id aObject)
{
    id support = [aObject queryHyperInterface:@protocol(HSUserObjectSupport)];
    id stack = [support stack];
    if (aObject != [support card] && aObject != stack)
        aObject = [[aObject queryHyperInterface:@protocol(HSUserObjectSupport)] card];
    return aObject;
}

static NSString * const HSForegroundSoundKey = @"HSForegroundSoundKey";
static NSString * const HSBackgroundSoundsKey = @"HSBackgroundSoundsKey";

// The UID of the stack an object belongs to (nil if it has none).
static id HSActionMediaPlayerStackUIDForObject(id aObject)
{
    id stack = [[aObject queryHyperInterface:@protocol(HSUserObjectSupport)] stack];
    return [[stack queryHyperInterface:@protocol(HSObjectUIDAttribute)] hyperUID];
}

- (void)startSound:(id)aSound forObject:(id)aObject
{
    id support = [aObject queryHyperInterface:@protocol(HSUserObjectSupport)];
    id stack = [support stack];
    id owner = aObject;
    if ([support card] != owner && stack != owner)
        owner = [[aObject queryHyperInterface:@protocol(HSUserObjectSupport)] card];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"action", [NSNull null], @"item", owner, @"owner", nil];
    [[self ownersBySound] setObject:info forKey:[NSValue valueWithNonretainedObject:aSound]];
    [self setForegroundSound:aSound forStackUID:[[stack queryHyperInterface:@protocol(HSObjectUIDAttribute)] hyperUID]];
    [(HSMovie *)aSound play];
}

- (id)ownersBySound
{
    if (_ownersBySound == nil)
        _ownersBySound = [NSMutableDictionary new];
    return _ownersBySound;
}

// The sound of the action's first sound item, recorded with its owner.
- (id)movieWithSoundAttributes:(id)aAttributes
{
    id item = [[[aAttributes sounds] extraFirstObject] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
    if (item == nil)
        return nil;
    id sound = [item sound];
    if (sound != nil) {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:aAttributes, @"action", item, @"item", [self ownerForAction:aAttributes], @"owner", nil];
        [[self ownersBySound] setObject:info forKey:[NSValue valueWithNonretainedObject:sound]];
    }
    return sound;
}

- (id)ownerForAction:(id)aAction
{
    return HSActionMediaPlayerOwnerForObject([[aAction owner] hyperObjectForAction:aAction]);
}

- (id)stackSounds
{
    if (_stackSounds == nil)
        _stackSounds = [[NSMutableDictionary alloc] init];
    return _stackSounds;
}

- (void)movieDidStop:(id)aStop
{
    [self movieDidEnd:aStop];
}

- (void)movieDidPlayOnce:(id)aOnce
{
}

// Tells the action its item stopped and forgets the sound.
- (void)movieDidEnd:(id)aEnd
{
    [aEnd setDelegate:nil];
    NSDictionary *info = [[self ownersBySound] objectForKey:[NSValue valueWithNonretainedObject:aEnd]];
    [[[info objectForKey:@"action"] queryHyperInterface:@protocol(HSActionMediaPlayerMovieOwner)] hyperPlayableObjectDidStop:[info objectForKey:@"item"]];
    [[self ownersBySound] removeObjectForKey:[NSValue valueWithNonretainedObject:aEnd]];
    [self removeSound:aEnd];
}

- (void)movieDidChangeImage:(id)aImage
{
}

// Forgets a sound that ended: it is dropped from the foreground and the
// background sounds of every stack, and a stack left with none is removed.
- (void)removeSound:(id)aSound
{
    for (id uid in _stackSounds) {
        NSMutableDictionary *sounds = [[_stackSounds objectForKey:uid] mutableCopy];
        if ([sounds objectForKey:HSForegroundSoundKey] == aSound)
            [sounds removeObjectForKey:HSForegroundSoundKey];
        if ([[sounds objectForKey:HSBackgroundSoundsKey] containsObject:aSound]) {
            NSMutableArray *background = [[sounds objectForKey:HSBackgroundSoundsKey] mutableCopy];
            [background removeObject:aSound];
            if ([background count] == 0)
                [sounds removeObjectForKey:HSBackgroundSoundsKey];
            else
                [sounds setObject:background forKey:HSBackgroundSoundsKey];
            [background release];
        }
        if ([sounds count] != 0)
            [_stackSounds setObject:sounds forKey:uid];
        else
            [_stackSounds removeObjectForKey:uid];
        [sounds release];
    }
}

// Replaces the stack's foreground sound; the old one is stopped.
- (void)setForegroundSound:(id)aSound forStackUID:(id)aUID
{
    NSDictionary *current = [[self stackSounds] objectForKey:aUID];
    id foreground = [current objectForKey:HSForegroundSoundKey];
    if (foreground == aSound)
        return;
    [foreground stop];
    if (aSound == nil)
        return;
    NSMutableDictionary *stackSounds = [self stackSounds];
    NSDictionary *sounds = [stackSounds objectForKey:aUID];
    if (sounds == nil) {
        sounds = [NSDictionary dictionaryWithObjectsAndKeys:aSound, HSForegroundSoundKey, nil];
        [stackSounds setObject:sounds forKey:aUID];
    } else {
        id old = [sounds objectForKey:HSForegroundSoundKey];
        [old setDelegate:nil];
        [old stop];
        NSMutableDictionary *updated = [sounds mutableCopy];
        [updated setObject:aSound forKey:HSForegroundSoundKey];
        [stackSounds setObject:updated forKey:aUID];
        [updated release];
    }
    [aSound setDelegate:self];
}

- (void)stopBackgroundSoundsForStackUID:(id)aUID withFadeOutTime:(double)aTime
{
    NSArray *sounds = [[[[self stackSounds] objectForKey:aUID] objectForKey:HSBackgroundSoundsKey] copy];
    for (id sound in sounds)
        [sound setSoundFadeOutStopTime:aTime];
    [sounds makeObjectsPerformSelector:@selector(stop)];
    [sounds release];
}

- (void)stopSoundForObject:(id)aObject forStackUID:(id)aUID
{
    [self setForegroundSound:nil forStackUID:aUID];
}

- (void)startForegroundSoundForSoundAttributes:(id)aAttributes forStackUID:(id)aUID
{
    id sound = [self movieWithSoundAttributes:aAttributes];
    [self setForegroundSound:sound forStackUID:aUID];
    [sound play];
}

- (void)startBackgroundSoundForSoundAttributes:(id)aAttributes forStackUID:(id)aUID
{
    id sound = [self movieWithSoundAttributes:aAttributes];
    if (sound != nil) {
        NSMutableDictionary *stackSounds = [self stackSounds];
        NSDictionary *sounds = [stackSounds objectForKey:aUID];
        if (sounds == nil) {
            sounds = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:sound], HSBackgroundSoundsKey, nil];
            [stackSounds setObject:sounds forKey:aUID];
        } else {
            NSArray *background = [sounds objectForKey:HSBackgroundSoundsKey];
            background = background != nil ? [background arrayByAddingObject:sound] : [NSArray arrayWithObject:sound];
            NSMutableDictionary *updated = [sounds mutableCopy];
            [updated setObject:background forKey:HSBackgroundSoundsKey];
            [stackSounds setObject:updated forKey:aUID];
            [updated release];
        }
    }
    [self setForegroundSound:nil forStackUID:aUID];
    [sound play];
}

// Fades out and stops every sound of the stack (the fade time comes from the
// action, if there is one) and any speech.
- (void)stopAllSoundsForStackUID:(id)aUID andSoundAttributes:(id)aAttributes
{
    double fadeOutTime = 0.0;
    if (aAttributes != nil)
        fadeOutTime = [aAttributes fadeOutTimeForStopAllSounds];
    [[[[self stackSounds] objectForKey:aUID] objectForKey:HSForegroundSoundKey] setSoundFadeOutStopTime:fadeOutTime];
    [self setForegroundSound:nil forStackUID:aUID];
    [self stopBackgroundSoundsForStackUID:aUID withFadeOutTime:fadeOutTime];
    [[SMKSpeechManager sharedSpeechManager] stopSpeech];
}

// Stops the sounds not owned by aSounds' card or stack, except the stack's
// background sounds; sounds of leave-card actions keep playing unless
// aSounds2 is set.
- (void)stopAllForeignSounds:(id)aSounds affectLeavingSounds:(BOOL)aSounds2 forStackUID:(id)aUID
{
    id background = [[[self stackSounds] objectForKey:aUID] objectForKey:HSBackgroundSoundsKey];
    NSEnumerator *keys = [[[self ownersBySound] allKeys] objectEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil) {
        id owner = [[[self ownersBySound] objectForKey:key] objectForKey:@"owner"];
        BOOL isOwn = owner == [aSounds card] || owner == [aSounds stack];
        id action = [[[self ownersBySound] objectForKey:key] objectForKey:@"action"];
        id sound = [key nonretainedObjectValue];
        BOOL leaving = [[action events] containsObject:[HSActionEvent actionEventOfType:kHSLeaveActionEventType]];
        if (![background containsObject:sound] && !isOwn && (aSounds2 || !leaving))
            [sound stop];
    }
}

// Stops the first playing sound with the same media name as the action's.
- (void)stopThisSoundForSoundAttributes:(id)aAttributes
{
    id item = [[[aAttributes sounds] extraFirstObject] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
    NSString *mediaName = [[item media] mediaName];
    for (NSValue *key in [[self ownersBySound] allKeys]) {
        id playingItem = [[[self ownersBySound] objectForKey:key] objectForKey:@"item"];
        if ([mediaName isEqualToString:[[playingItem media] mediaName]]) {
            [[key nonretainedObjectValue] stop];
            return;
        }
    }
}

// Stops the first playing sound of each listed sound item, fading it out.
- (void)stopSoundsForSoundAttributes:(id)aAttributes
{
    for (id uid in [aAttributes soundsUIDsToStop]) {
        for (NSValue *key in [[self ownersBySound] allKeys]) {
            id itemUID = [[[[[self ownersBySound] objectForKey:key] objectForKey:@"item"] queryHyperInterface:@protocol(HSSoundItemAttributes)] itemUID];
            if ([uid isEqual:itemUID]) {
                id sound = [key nonretainedObjectValue];
                [sound setSoundFadeOutStopTime:[aAttributes fadeOutTimeForStopSoundUID:itemUID]];
                [sound stop];
            }
        }
    }
}

- (void)pauseAllSoundsForStackUID:(id)aUID
{
    NSDictionary *sounds = [[self stackSounds] objectForKey:aUID];
    [[sounds objectForKey:HSForegroundSoundKey] pause];
    [[sounds objectForKey:HSBackgroundSoundsKey] makeObjectsPerformSelector:@selector(pause)];
}

- (void)resumeAllSoundsForStackUID:(id)aUID
{
    NSDictionary *sounds = [[self stackSounds] objectForKey:aUID];
    [[sounds objectForKey:HSForegroundSoundKey] resume];
    [[sounds objectForKey:HSBackgroundSoundsKey] makeObjectsPerformSelector:@selector(resume)];
}

- (void)hyperPlayableObjectDidStop:(id)aStop
{
    NSMapTable *map = [self movieWithAttributesMap];
    id owner = [(NSDictionary *)NSMapGet(map, aStop) objectForKey:@"HSActionMediaPlayerMovieOwner"];
    if (owner != nil)
        [owner hyperPlayableObjectDidStop:aStop];
    NSMapRemove(map, aStop);
}

- (void)stopAllMovies
{
    for (id movie in NSAllMapTableKeys([self movieWithAttributesMap]))
        [self stopMovie:movie];
}

- (void)stopMovie:(id)aMovie
{
    [aMovie hyperStop];
}

// A movie not already playing may stop the other movies and the stack's sounds first.
- (void)playMovie:(id)aMovie movieOwner:(id)aOwner forStackUID:(id)aUID
{
    NSMapTable *map = [self movieWithAttributesMap];
    if (NSMapGet(map, aMovie) != NULL)
        return;
    id attributes = [aMovie queryHyperInterface:@protocol(HSPlayableObjectHyperAllowPlayingOtherMoviesAttribute)];
    if (attributes != nil) {
        if (![attributes isHyperAllowPlayingOtherMovies])
            [self stopAllMovies];
        if (![attributes isHyperAllowPlayingOtherSounds])
            [self stopAllSoundsForStackUID:aUID andSoundAttributes:nil];
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if (aOwner != nil)
        [info setObject:aOwner forKey:@"HSActionMediaPlayerMovieOwner"];
    NSMapInsert(map, aMovie, info);
    [aMovie hyperStart:self];
}

- (id)movieWithAttributesMap
{
    if (_movieWithAttributesMap == nil)
        _movieWithAttributesMap = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0, [self zone]);
    return _movieWithAttributesMap;
}

// HyperStudio 5 entry points: the stack is taken from the object or action.
- (void)stopSoundForObject:(id)aObject
{
    [self stopSoundForObject:aObject forStackUID:HSActionMediaPlayerStackUIDForObject(aObject)];
}

- (void)stopAllSounds
{
    for (id uid in [[self stackSounds] allKeys])
        [self stopAllSoundsForStackUID:uid andSoundAttributes:nil];
}

- (void)stopAllSoundsForSoundAttributes:(id)aAttributes
{
    [self stopAllSoundsForStackUID:HSActionMediaPlayerStackUIDForObject([self ownerForAction:aAttributes]) andSoundAttributes:aAttributes];
}

- (void)startForegroundSoundForSoundAttributes:(id)aAttributes
{
    [self startForegroundSoundForSoundAttributes:aAttributes forStackUID:HSActionMediaPlayerStackUIDForObject([self ownerForAction:aAttributes])];
}

- (void)startBackgroundSoundForSoundAttributes:(id)aAttributes
{
    [self startBackgroundSoundForSoundAttributes:aAttributes forStackUID:HSActionMediaPlayerStackUIDForObject([self ownerForAction:aAttributes])];
}

- (void)playMovie:(id)aMovie movieOwner:(id)aOwner
{
    [self playMovie:aMovie movieOwner:aOwner forStackUID:HSActionMediaPlayerStackUIDForObject(aMovie)];
}

- (void)dealloc
{
    if (_movieWithAttributesMap != nil)
        NSFreeMapTable(_movieWithAttributesMap);
    for (id uid in _stackSounds) {
        NSDictionary *sounds = [_stackSounds objectForKey:uid];
        id foreground = [sounds objectForKey:HSForegroundSoundKey];
        [foreground setDelegate:nil];
        [foreground stop];
        NSArray *background = [sounds objectForKey:HSBackgroundSoundsKey];
        [background makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
        [background makeObjectsPerformSelector:@selector(stop)];
    }
    [_stackSounds release];
    [_ownersBySound release];
    [super dealloc];
}

// The singleton is never released.
- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
