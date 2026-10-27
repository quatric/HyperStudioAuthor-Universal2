#import "HSCelMovieObjectFramesLazyCacheItem.h"
#import "HSNewMediaAccessor.h"

// Cel movie frames are shared between movie objects through one cache
// manager: items are keyed by frame media UID, either directly in the
// manager's dictionary or inside a group item (keyed by the group
// identifier) that holds its own dictionary. Each item counts the cache
// objects linked to it; items whose count drops to zero are released by a
// one-minute timer unless some cache object links them again first.

static HSCelMovieObjectFramesCacheManager *sSharedCacheManager = nil;

// Links the cached item for aUID to aCacheObject, or loads the frame image
// from the media data and registers a new item for it.
static id CreateAndRegisterFrameImage(HSCelMovieObjectFramesCacheManager *aManager, id aCacheObject, id aUID, id aGroup)
{
    id item = [aManager linkItemToCacheObject:aCacheObject mediaUID:aUID group:aGroup];
    if (item == nil) {
        NSData *data = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID] mediaData];
        if (data != nil) {
            NSImage *image = [[NSImage alloc] initWithData:data];
            if (image != nil) {
                item = [aManager registerFrameImage:image mediaUID:aUID cacheObject:aCacheObject group:aGroup];
                [image release];
            }
        }
    }
    return item;
}

@implementation HSCelMovieObjectFramesCacheItem

// Called by the releasing timer: drops the item from its group, and the
// group itself from the container once the group is empty.
- (void)removeItemFromContainer:(id)aContainer
{
    if (aContainer == nil)
        return;
    id key = _frameMediaUID;
    if (_groupOwner != nil) {
        NSMutableDictionary *groupCache = [_groupOwner groupCacheCreateIfNeed:NO];
        [groupCache removeObjectForKey:_frameMediaUID];
        if ([groupCache count] != 0)
            return;
        key = [_groupOwner groupIdentifier];
    }
    [aContainer removeObjectForKey:key];
}

- (id)groupOwner
{
    return _groupOwner;
}

- (NSUInteger)hardLinkCount
{
    return _hardLinkCount;
}

- (id)frameImage:(id)aImage
{
    return _frameImage;
}

- (id)frameMediaUID
{
    return _frameMediaUID;
}

- (NSUInteger)unlinkFromCacheObject:(id)aObject
{
    return --_hardLinkCount;
}

- (id)linkToCacheObject:(id)aObject
{
    _hardLinkCount++;
    return self;
}

- (void)dealloc
{
    [_frameMediaUID release];
    [_frameImage release];
    [super dealloc];
}

// The group owner is not retained: the group outlives its items.
- (id)initWithFrameImage:(id)aImage mediaUID:(id)aUID groupOwner:(id)aOwner
{
    self = [super init];
    if (self != nil) {
        _frameMediaUID = [aUID retain];
        _frameImage = [aImage retain];
        _groupOwner = aOwner;
    }
    return self;
}

@end

@implementation HSCelMovieObjectFramesLazyCacheItem

// aImage is the frame data source here: the image is loaded on first use.
- (id)frameImage:(id)aImage
{
    if (_frameImage == nil)
        _frameImage = [[aImage frameImageForMediaUID:_frameMediaUID] retain];
    return _frameImage;
}

- (id)initWithFrameMediaUID:(id)aUID groupOwner:(id)aOwner
{
    return [super initWithFrameImage:nil mediaUID:aUID groupOwner:aOwner];
}

@end

@implementation HSGroupCacheItem

- (NSUInteger)hardLinkCount
{
    return 0;
}

- (id)groupCacheCreateIfNeed:(BOOL)aNeed
{
    if (_groupCache == nil && aNeed)
        _groupCache = [NSMutableDictionary new];
    return _groupCache;
}

- (id)groupIdentifier
{
    return _groupIdentifier;
}

- (void)dealloc
{
    [_groupIdentifier release];
    [_groupCache release];
    [super dealloc];
}

- (id)initWithIdentifier:(id)aIdentifier
{
    self = [super init];
    if (self == nil || aIdentifier == nil) {
        [self release];
        return nil;
    }
    _groupIdentifier = [aIdentifier retain];
    return self;
}

@end

@implementation HSCelMovieObjectFramesCacheManager

+ (id)sharedMannagerShouldCreate:(BOOL)aCreate
{
    if (sSharedCacheManager == nil && aCreate)
        sSharedCacheManager = [HSCelMovieObjectFramesCacheManager new];
    return sSharedCacheManager;
}

+ (id)sharedMannager
{
    return [self sharedMannagerShouldCreate:YES];
}

- (void)scheduleReleasingTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(releaseItemsOnTimer:) userInfo:_itemsToRelease repeats:NO];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runLoop addTimer:timer forMode:NSEventTrackingRunLoopMode];
    [runLoop addTimer:timer forMode:NSModalPanelRunLoopMode];
    _releasingTimer = [timer retain];
}

- (void)cancelReleasingTimer
{
    [_releasingTimer invalidate];
    [_releasingTimer autorelease];
    _releasingTimer = nil;
}

- (void)releaseItemsOnTimer:(id)aTimer
{
    NSArray *items = nil;
    @try {
        items = [[NSArray alloc] initWithArray:[aTimer userInfo]];
        [[aTimer userInfo] removeAllObjects];
        [items makeObjectsPerformSelector:@selector(removeItemFromContainer:) withObject:_cacheDictionary];
    }
    @catch (NSException *exception) {
    }
    [items release];
    [_releasingTimer autorelease];
    _releasingTimer = nil;
}

- (id)cachedFrameForMediaUID:(id)aUID groupIdentifier:(id)aIdentifier
{
    if (aUID == nil)
        return nil;
    id container = _cacheDictionary;
    if (aIdentifier != nil)
        container = [[container objectForKey:aIdentifier] groupCacheCreateIfNeed:NO];
    return [[container objectForKey:aUID] frameImage:nil];
}

// Precached frames start unlinked, so they go straight to the release list.
- (void)precacheFramesMedia:(id)aMedia frameImages:(id)aImages
{
    if (aMedia == nil || aImages == nil || [aImages count] != [aMedia count])
        return;
    NSEnumerator *uidEnumerator = [aMedia objectEnumerator];
    NSEnumerator *imageEnumerator = [aImages objectEnumerator];
    BOOL added = NO;
    id uid;
    id image;
    while ((uid = [uidEnumerator nextObject]) != nil && (image = [imageEnumerator nextObject]) != nil) {
        if ([_cacheDictionary objectForKey:uid] != nil)
            continue;
        if (_releasingTimer != nil)
            [self cancelReleasingTimer];
        id item = [[HSCelMovieObjectFramesCacheItem alloc] initWithFrameImage:image mediaUID:uid groupOwner:nil];
        if (item == nil) {
            // quirk kept: a failed item still schedules the timer
            added = YES;
            break;
        }
        [_cacheDictionary setObject:item forKey:uid];
        [_itemsToRelease addObject:item];
        [item release];
        added = YES;
    }
    if (added)
        [self scheduleReleasingTimer];
}

- (id)registerGroupWithIdentifier:(id)aIdentifier
{
    if (aIdentifier == nil)
        return nil;
    id group = [_cacheDictionary objectForKey:aIdentifier];
    if (group == nil) {
        group = [[HSGroupCacheItem alloc] initWithIdentifier:aIdentifier];
        if (group != nil) {
            [_cacheDictionary setObject:group forKey:aIdentifier];
            [group release];
        }
    }
    return group;
}

- (id)registerFrameImageLazyWithMediaUID:(id)aUID cacheObject:(id)aObject group:(id)aGroup
{
    id item = [[HSCelMovieObjectFramesLazyCacheItem alloc] initWithFrameMediaUID:aUID groupOwner:aGroup];
    if (item != nil) {
        id container = aGroup == nil ? _cacheDictionary : [aGroup groupCacheCreateIfNeed:YES];
        [container setObject:item forKey:aUID];
        [item linkToCacheObject:aObject];
        [item release];
    }
    return item;
}

- (id)registerFrameImage:(id)aImage mediaUID:(id)aUID cacheObject:(id)aObject group:(id)aGroup
{
    if (aImage == nil)
        return nil;
    id item = [[HSCelMovieObjectFramesCacheItem alloc] initWithFrameImage:aImage mediaUID:aUID groupOwner:aGroup];
    if (item != nil) {
        id container = aGroup == nil ? _cacheDictionary : [aGroup groupCacheCreateIfNeed:YES];
        [container setObject:item forKey:aUID];
        [item linkToCacheObject:aObject];
        [item release];
    }
    return item;
}

- (void)unlinkItems:(id)aItems cacheObject:(id)aObject
{
    if (aItems == nil || aObject == nil)
        return;
    BOOL added = NO;
    for (id item in aItems) {
        if ([item unlinkFromCacheObject:aObject] != 0)
            continue;
        if (_releasingTimer != nil)
            [self cancelReleasingTimer];
        [_itemsToRelease addObject:item];
        added = YES;
    }
    if (added)
        [self scheduleReleasingTimer];
}

// An unlinked item waiting for release is taken off the release list
// (restarting the timer for the rest) before it is linked again.
- (id)linkItemToCacheObject:(id)aObject mediaUID:(id)aUID group:(id)aGroup
{
    if (aUID == nil)
        return nil;
    id container = aGroup == nil ? _cacheDictionary : [aGroup groupCacheCreateIfNeed:NO];
    id item = [container objectForKey:aUID];
    if (item != nil && [item hardLinkCount] == 0) {
        [self cancelReleasingTimer];
        [_itemsToRelease removeObject:item];
        if ([_itemsToRelease count] != 0)
            [self scheduleReleasingTimer];
    }
    if (aObject != nil)
        item = [item linkToCacheObject:aObject];
    return item;
}

- (void)dealloc
{
    [_cacheDictionary release];
    [_releasingTimer invalidate];
    [_releasingTimer autorelease];
    [_itemsToRelease autorelease];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _cacheDictionary = [NSMutableDictionary new];
        _itemsToRelease = [NSMutableArray new];
    }
    return self;
}

@end

@implementation HSCelMovieObjectFramesCache

+ (id)cachedFrameForMediaUID:(id)aUID groupIdentifier:(id)aIdentifier
{
    return [[HSCelMovieObjectFramesCacheManager sharedMannagerShouldCreate:NO] cachedFrameForMediaUID:aUID groupIdentifier:aIdentifier];
}

+ (void)precacheFramesMedia:(id)aMedia frameImages:(id)aImages
{
    [[HSCelMovieObjectFramesCacheManager sharedMannager] precacheFramesMedia:aMedia frameImages:aImages];
}

- (NSUInteger)cachedFramesCount
{
    return [_cachedFrames count];
}

// Out-of-range indexes give nil.
- (id)cachedFrameAtIndex:(NSUInteger)aIndex
{
    id image = nil;
    @try {
        image = [[_cachedFrames objectAtIndex:aIndex] frameImage:_frameDataSource];
    }
    @catch (NSException *exception) {
    }
    return image;
}

// Replaces the cached frames, loading each frame image from its media; stops
// at the first frame that cannot be loaded.
- (void)cacheFramesWithMedia:(id)aMedia
{
    if (aMedia == nil)
        return;
    HSCelMovieObjectFramesCacheManager *manager = [HSCelMovieObjectFramesCacheManager sharedMannager];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:[aMedia count]];
    for (id uid in aMedia) {
        id item = CreateAndRegisterFrameImage(manager, self, uid, _framesMediaGroup);
        if (item == nil)
            break;
        [frames addObject:item];
    }
    [manager unlinkItems:_cachedFrames cacheObject:self];
    [_cachedFrames release];
    _cachedFrames = frames;
}

- (void)addCacheFrameWithMediaUID:(id)aUID
{
    if (aUID == nil)
        return;
    id item = CreateAndRegisterFrameImage([HSCelMovieObjectFramesCacheManager sharedMannager], self, aUID, _framesMediaGroup);
    // fixed: the original added nil (an exception) when the frame failed to load
    if (item != nil)
        [_cachedFrames addObject:item];
}

- (void)addCacheFrameWithMediaUID:(id)aUID frameImage:(id)aImage
{
    if (aUID == nil || aImage == nil)
        return;
    HSCelMovieObjectFramesCacheManager *manager = [HSCelMovieObjectFramesCacheManager sharedMannager];
    id item = [manager linkItemToCacheObject:self mediaUID:aUID group:_framesMediaGroup];
    if (item == nil)
        item = [manager registerFrameImage:aImage mediaUID:aUID cacheObject:self group:_framesMediaGroup];
    [_cachedFrames addObject:item];
}

- (void)dealloc
{
    HSCelMovieObjectFramesCacheManager *manager = [HSCelMovieObjectFramesCacheManager sharedMannagerShouldCreate:NO];
    if (manager != nil) {
        [manager unlinkItems:_cachedFrames cacheObject:self];
        [_cachedFrames release];
    }
    [_frameDataSource release];
    [_framesMediaGroup release];
    [super dealloc];
}

// Frames are lazy: images come from the data source on first use.
- (id)initWithFramesMedia:(id)aMedia frameDataSource:(id)aSource groupIdentifier:(id)aIdentifier
{
    self = [super init];
    NSUInteger count = [aMedia count];
    if (self != nil && count != 0 && aSource != nil) {
        _cachedFrames = [[NSMutableArray alloc] initWithCapacity:count];
        if (_cachedFrames != nil) {
            _frameDataSource = [aSource retain];
            HSCelMovieObjectFramesCacheManager *manager = [HSCelMovieObjectFramesCacheManager sharedMannager];
            if (aIdentifier != nil)
                _framesMediaGroup = [[manager registerGroupWithIdentifier:aIdentifier] retain];
            for (id uid in aMedia) {
                id item = [manager linkItemToCacheObject:self mediaUID:uid group:_framesMediaGroup];
                if (item == nil) {
                    item = [manager registerFrameImageLazyWithMediaUID:uid cacheObject:self group:_framesMediaGroup];
                    if (item == nil)
                        break;
                }
                [_cachedFrames addObject:item];
            }
            if ([_cachedFrames count] == [aMedia count])
                return self;
        }
    }
    [self release];
    return nil;
}

// Without images only the empty frame list is set up.
- (id)initWithFramesMedia:(id)aMedia frameImages:(id)aImages groupIdentifier:(id)aIdentifier
{
    self = [super init];
    NSUInteger count = [aMedia count];
    if (self != nil && aMedia != nil && (aImages == nil || [aImages count] == count)) {
        _cachedFrames = [[NSMutableArray alloc] initWithCapacity:count];
        if (_cachedFrames != nil) {
            if (aImages == nil)
                return self;
            HSCelMovieObjectFramesCacheManager *manager = [HSCelMovieObjectFramesCacheManager sharedMannager];
            if (aIdentifier != nil)
                _framesMediaGroup = [[manager registerGroupWithIdentifier:aIdentifier] retain];
            NSEnumerator *imageEnumerator = [aImages objectEnumerator];
            NSEnumerator *uidEnumerator = [aMedia objectEnumerator];
            id image;
            id uid;
            while ((image = [imageEnumerator nextObject]) != nil && (uid = [uidEnumerator nextObject]) != nil) {
                id item = [manager linkItemToCacheObject:self mediaUID:uid group:_framesMediaGroup];
                if (item == nil) {
                    item = [manager registerFrameImage:image mediaUID:uid cacheObject:self group:_framesMediaGroup];
                    if (item == nil)
                        break;
                }
                [_cachedFrames addObject:item];
            }
            if ([_cachedFrames count] == [aMedia count])
                return self;
        }
    }
    [self release];
    return nil;
}

- (id)initWithCapacity:(NSUInteger)aCapacity groupIdentifier:(id)aIdentifier
{
    self = [super init];
    if (self != nil) {
        _cachedFrames = [[NSMutableArray alloc] initWithCapacity:aCapacity];
        if (aIdentifier != nil)
            _framesMediaGroup = [[[HSCelMovieObjectFramesCacheManager sharedMannager] registerGroupWithIdentifier:aIdentifier] retain];
    }
    return self;
}

@end
