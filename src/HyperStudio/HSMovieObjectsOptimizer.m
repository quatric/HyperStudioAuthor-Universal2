#import "HSMovieObjectsOptimizer.h"

@implementation HSMovieObjectsOptimizer

// Optimizable unless some object already plays the whole movie.
+ (BOOL)canOptimizeMediaUID:(id)aUID usedInObjects:(id)aObjects
{
    struct HSTimeRange merged = { 0.0, 0.0 };
    double duration = 0.0;
    BOOL isFirst = YES;
    BOOL canOptimize = NO;

    if ([aObjects count] == 0 || aUID == nil)
        return NO;
    for (id object in aObjects) {
        merged = HSMergeTimeRanges(merged, [self timeRangeInObject:object uid:aUID hyperDuration:isFirst ? &duration : NULL]);
        isFirst = NO;
        canOptimize = !HSEqualTimeRanges(HSMakeTimeRange(0.0, duration), merged);
        if (!canOptimize)
            break;
    }
    return canOptimize;
}

+ (struct HSTimeRange)timeRangeInObject:(id)aObject uid:(id)aUid hyperDuration:(double *)aDuration
{
    struct HSTimeRange range = { 0.0, 0.0 };
    id playable = [aObject queryHyperInterface:@protocol(HSPlayableObjectAttributes)];

    if (playable != nil) {
        range = [playable hyperPlayRange];
        if (aDuration != NULL)
            *aDuration = [playable hyperDuration];
    }
    else {
        id action = [aObject queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
        id movie;

        if (action != nil && (movie = [self movieForMediaUID:aUid inPlayMovieAction:action]) != nil) {
            range = [movie playRange];
            if (aDuration != NULL)
                *aDuration = [[movie movieObjectForCard:nil] hyperDuration];
        }
    }
    return range;
}

+ (id)movieForMediaUID:(id)aUID inPlayMovieAction:(id)aAction
{
    for (id movie in [aAction movies]) {
        if ([[movie movieMediaUID] isEqualTo:aUID])
            return movie;
    }
    return nil;
}

// Points every object at the trimmed media and shifts its play range by the trimmed start.
- (void)optimize
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id media = [self optimizedMedia];

    if (media != nil) {
        id objects = [self objects];
        struct HSTimeRange merged = [self mergedPlayRangeUsedInObjects:objects];

        for (id object in objects) {
            id movieObject = [object queryHyperInterface:@protocol(HSMovieObjectAttributes)];
            struct HSTimeRange range;

            if (movieObject != nil) {
                id playable = [object queryHyperInterface:@protocol(HSPlayableObjectAttributes)];

                range = [playable hyperPlayRange];
                [movieObject setMedia:media];
                range = HSMakeTimeRange(range.location - merged.location, range.length);
                if (range.location < 0.0)
                    range.location = 0.0;
                [playable setHyperPlayRange:range];
            }
            else {
                id action = [object queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
                id movie = [[self class] movieForMediaUID:[self mediaUID] inPlayMovieAction:action];

                if (movie == nil)
                    movie = [[self class] movieForMediaUID:[media mediaUID] inPlayMovieAction:action];
                range = [movie playRange];
                range = HSMakeTimeRange(range.location - merged.location, range.length);
                if (range.location < 0.0)
                    range.location = 0.0;
                [[movie movieObjectForCard:nil] setMedia:media];
                [movie setPlayRange:range];
            }
        }
    }
    [pool release];
}

// The merged play range of all objects, cut out of the movie as new media.
- (id)optimizedMedia
{
    struct HSTimeRange merged = [self mergedPlayRangeUsedInObjects:[self objects]];
    id movieObject = [[self objects] anyObject];
    QTMovie *movie, *trimmed;
    id media = nil;

    if (![movieObject implementsHyperInterface:@protocol(HSMovieObjectAttributes)] || movieObject == nil) {
        id action = [movieObject queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
        id actionMovie;

        if (action == nil || (actionMovie = [[self class] movieForMediaUID:[self mediaUID] inPlayMovieAction:action]) == nil
            || (movieObject = [actionMovie movieObjectForCard:nil]) == nil)
            return nil;
    }
    if ([[movieObject hyperMovie] quickTimeMovie] == NULL)
        return nil;
    movie = [[QTMovie alloc] initWithQuickTimeMovie:[[movieObject hyperMovie] quickTimeMovie] disposeWhenDone:NO error:nil];
    if (movie == nil)
        return nil;
    trimmed = [movie movieWithTimeRange:QTMakeTimeRange(QTMakeTimeWithTimeInterval(merged.location), QTMakeTimeWithTimeInterval(merged.length)) error:nil];
    if (trimmed != nil)
        media = [HSNewMedia mediaWithQTMovie:trimmed name:[[movieObject media] mediaName] type:[[[movieObject media] fullPathToMediaFile] pathExtension]];
    [movie release];
    return media;
}

// An empty merged range becomes a tenth of a second long.
- (struct HSTimeRange)mergedPlayRangeUsedInObjects:(id)aObjects
{
    struct HSTimeRange merged = { 0.0, 0.0 };

    for (id object in aObjects)
        merged = HSMergeTimeRanges(merged, [[self class] timeRangeInObject:object uid:[self mediaUID] hyperDuration:NULL]);
    if (merged.length == 0.0)
        merged.length = 0.1;
    return merged;
}

@end
