#import "HSPlaybackControlImagesProvider.h"

// The playback control images (type_size_state_tint.png), cached; a
// singleton that is never released.

static HSPlaybackControlImagesProvider *sSharedProvider;

@implementation HSPlaybackControlImagesProvider

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedProvider == nil) {
            sSharedProvider = [super allocWithZone:aZone];
            return sSharedProvider;
        }
    }
    return nil;
}

+ (id)sharedPlaybackControlsImagesProvider
{
    @synchronized(self) {
        if (sSharedProvider == nil)
            [[self alloc] init];
    }
    return sSharedProvider;
}

- (id)playbackImageOfType:(id)aType state:(id)aState size:(id)aSize tint:(id)aTint
{
    NSString *name = [NSString stringWithFormat:@"%@_%@_%@_%@", aType, aSize, aState, aTint];
    NSImage *image = [[self imagesCache] objectForKey:name];
    if (image == nil) {
        image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"png"]];
        // (A missing image, nil, raised in the original.)
        if (image != nil)
            [[self imagesCache] setObject:image forKey:name];
        [image release];
    }
    return image;
}

- (id)imagesCache
{
    if (_imagesCache == nil)
        _imagesCache = [NSMutableDictionary new];
    return _imagesCache;
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
