#import "HSPlaySoundActionsOptimizer.h"

@implementation HSPlaySoundActionsOptimizer

+ (id)soundForMediaUID:(id)aUID inPlaySoundAction:(id)aAction
{
    NSEnumerator *enumerator = [[aAction sounds] objectEnumerator];
    id sound;

    while ((sound = [enumerator nextObject]) != nil) {
        if ([[[sound queryHyperInterface:@protocol(HSSoundPlaybackAttributes)] mediaUID] isEqualTo:aUID])
            return sound;
    }
    return nil;
}

// Optimizable when every action plays the same trimmed part of the sound.
+ (BOOL)canOptimizeMediaUID:(id)aUID usedInObjects:(id)aObjects
{
    id playback, object;
    NSEnumerator *enumerator;
    struct HSTimeRange range;

    if ([aObjects count] == 0 || aUID == nil)
        return NO;
    playback = [[self soundForMediaUID:aUID inPlaySoundAction:[[aObjects anyObject] queryHyperInterface:@protocol(HSPlaySoundActionAttributes)]] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
    range = [playback soundPlayRange];
    if (HSEqualTimeRanges(range, HSMakeTimeRange(0.0, [playback soundDuration])))
        return NO;
    enumerator = [aObjects objectEnumerator];
    while ((object = [enumerator nextObject]) != nil) {
        id action = [object queryHyperInterface:@protocol(HSPlaySoundActionAttributes)];
        id sound;

        if (action == nil || (sound = [self soundForMediaUID:aUID inPlaySoundAction:action]) == nil)
            return NO;
        playback = [sound queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
        if (playback == nil || !HSEqualTimeRanges([playback soundPlayRange], range))
            return NO;
    }
    return YES;
}

- (id)optimizedMedia
{
    id playback = [self anySoundPlayback];
    QTMovie *movie, *trimmed;
    struct HSTimeRange range;
    id media = nil;

    if (playback == nil || [[playback sound] quickTimeMovie] == NULL)
        return nil;
    movie = [[QTMovie alloc] initWithQuickTimeMovie:[[playback sound] quickTimeMovie] disposeWhenDone:NO error:nil];
    if (movie == nil)
        return nil;
    range = [playback soundPlayRange];
    trimmed = [movie movieWithTimeRange:QTMakeTimeRange(QTMakeTimeWithTimeInterval(range.location), QTMakeTimeWithTimeInterval(range.length)) error:nil];
    if (trimmed != nil)
        media = [HSNewMedia mediaWithQTMovie:trimmed name:[[playback media] mediaName] type:[[[playback media] fullPathToMediaFile] pathExtension]];
    [movie release];
    return media;
}

- (id)anySoundPlayback
{
    id action = [[[self objects] anyObject] queryHyperInterface:@protocol(HSPlaySoundActionAttributes)];

    return [[[self class] soundForMediaUID:[self mediaUID] inPlaySoundAction:action] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
}

- (void)optimize
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id media = [self optimizedMedia];

    if (media != nil) {
        NSEnumerator *enumerator = [[self objects] objectEnumerator];
        id object;

        while ((object = [enumerator nextObject]) != nil) {
            id action = [object queryHyperInterface:@protocol(HSPlaySoundActionAttributes)];
            id oldSound = [[self class] soundForMediaUID:[self mediaUID] inPlaySoundAction:action];
            id playback = [oldSound queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
            HSSoundItem *sound = [[[HSSoundItem alloc] initWithMediaUID:[media mediaUID] andApplyOptionsFromSound:[playback sound]] autorelease];

            [sound setSoundPlayRange:HSMakeTimeRange(0.0, [playback soundDuration])];
            [sound copyAttributesFromSoundItem:oldSound];
            [action removeSound:oldSound];
            [action addSound:sound];
        }
    }
    // Fix: the pool was only released when there was optimized media.
    [pool release];
}

@end
