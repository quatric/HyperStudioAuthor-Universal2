#import "HSMediaPlaySynchronizer.h"

// Keeps the library's playing media (until they end) so they can be stopped
// together; a singleton never released.

static HSMediaPlaySynchronizer *sSharedSynchronizer;

@implementation HSMediaPlaySynchronizer

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedSynchronizer == nil) {
            sSharedSynchronizer = [super allocWithZone:aZone];
            return sSharedSynchronizer;
        }
    }
    return nil;
}

+ (id)sharedSynchronizer
{
    @synchronized(self) {
        if (sSharedSynchronizer == nil)
            [[self alloc] init];
    }
    return sSharedSynchronizer;
}

- (void)movieDidEnd:(id)aEnd
{
    id movie = [(NSNotification *)aEnd object];
    // Original quirk kept: only the did-end observation is removed.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HSMovieDidEndNotification object:movie];
    [_playingSounds removeObject:movie];
}

- (void)stopAllMedia
{
    [_playingSounds makeObjectsPerformSelector:@selector(stop)];
}

- (void)playMediaSingle:(id)aSingle
{
    [self stopAllMedia];
    [self playMedia:aSingle];
}

- (void)playMedia:(id)aMedia
{
    if (aMedia == nil)
        return;
    [_playingSounds addObject:aMedia];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidEnd:) name:HSMovieDidEndNotification object:aMedia];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidEnd:) name:HSMovieDidStopNotification object:aMedia];
    [(HSMovie *)aMedia play];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playingSounds release];
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
        _playingSounds = [[NSMutableArray alloc] init];
    return self;
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
