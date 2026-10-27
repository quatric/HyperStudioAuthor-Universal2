#import "HSActionMediaPlayer.h"
#import "HSActionEvent.h"
#import "HSMovie.h"
#import "NSMutableArray+EXMutableArray.h"
#import "SMKSpeechManager.h"

// The shared player of the sounds and movies started by actions. Each sound
// is recorded (keyed by a non-retained NSValue) with the action, the sound
// item and the owner (the object's card, or the card/stack itself); one
// foreground sound plays at a time, background sounds play alongside. Movies
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

- (void)startSound:(id)aSound forObject:(id)aObject
{
    id owner = HSActionMediaPlayerOwnerForObject(aObject);
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null], @"action", [NSNull null], @"item", owner, @"owner", nil];
    [[self ownersBySound] setObject:info forKey:[NSValue valueWithNonretainedObject:aSound]];
    [self setForegroundSound:aSound];
    [(HSMovie *)[self foregroundSound] play];
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
    // the original only did this from Mac OS X 10.7 (AppKit 1138) on
    [_backgroundSounds removeObject:aEnd];
}

- (void)movieDidChangeImage:(id)aImage
{
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
                [self stopSound:sound];
                break;
            }
        }
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
            [self stopSound:[key nonretainedObjectValue]];
            return;
        }
    }
}

// Stops the foreground sounds not owned by aSounds' card or stack; sounds of
// leave-card actions keep playing unless aSounds2 is set.
// Fades out every sound and stops any speech.
// Starting a background sound still stops the foreground sound.
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

// A movie not already playing may stop the other movies and sounds first.
- (id)movieWithAttributesMap
{
    if (_movieWithAttributesMap == nil)
        _movieWithAttributesMap = NSCreateMapTableWithZone(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0, [self zone]);
    return _movieWithAttributesMap;
}

- (void)dealloc
{
    if (_movieWithAttributesMap != nil)
        NSFreeMapTable(_movieWithAttributesMap);
    [_backgroundSounds makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
    [_backgroundSounds makeObjectsPerformSelector:@selector(stop)];
    [_backgroundSounds release];
    [_foregroundSound setDelegate:nil];
    [_foregroundSound stop];
    [_foregroundSound release];
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
