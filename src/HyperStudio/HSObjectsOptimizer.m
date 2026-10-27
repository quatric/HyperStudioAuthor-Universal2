#import "HSObjectsOptimizer.h"

@implementation HSObjectsOptimizer

+ (BOOL)canOptimizeMediaUID:(id)aUID usedInObjects:(id)aObjects
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

+ (id)optimizerForMediaUID:(id)aUID usedInObjects:(id)aObjects
{
    id optimizer = [[[HSImageObjectsOptimizer alloc] initWithMediaUID:aUID usedInObjects:aObjects] autorelease];
    if (optimizer == nil)
        optimizer = [[[HSMovieObjectsOptimizer alloc] initWithMediaUID:aUID usedInObjects:aObjects] autorelease];
    if (optimizer == nil)
        optimizer = [[[HSPlaySoundActionsOptimizer alloc] initWithMediaUID:aUID usedInObjects:aObjects] autorelease];
    return optimizer;
}

- (void)postprocessAfterOptimization
{
}

- (void)optimize
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id)objects
{
    return _objects;
}

- (id)mediaUID
{
    return _mediaUID;
}

- (void)dealloc
{
    [_mediaUID release];
    [_objects release];
    [super dealloc];
}

- (id)initWithMediaUID:(id)aUID usedInObjects:(id)aObjects
{
    if (![[self class] canOptimizeMediaUID:aUID usedInObjects:aObjects]) {
        [self release];
        return nil;
    }
    self = [super init];
    if (self != nil) {
        _mediaUID = [aUID retain];
        _objects = [aObjects retain];
    }
    return self;
}

@end
