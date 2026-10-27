#import "HyperPlayerBasePrefix.h"


@interface HSCelMovieObjectFramesCacheItem : NSObject <HSCelMovieObjectCacheItem, HSAbstractCacheItem, NSObject>
{
    HSUID *_frameMediaUID;
    NSImage *_frameImage;
    unsigned int _hardLinkCount;
    id<HSGroupCacheItem> _groupOwner;
}
- (void)removeItemFromContainer:(id)aContainer;
- (id)groupOwner;
- (NSUInteger)hardLinkCount;
- (id)frameImage:(id)aImage;
- (id)frameMediaUID;
- (NSUInteger)unlinkFromCacheObject:(id)aObject;
- (id)linkToCacheObject:(id)aObject;
- (void)dealloc;
- (id)initWithFrameImage:(id)aImage mediaUID:(id)aUID groupOwner:(id)aOwner;
@end

@interface HSCelMovieObjectFramesLazyCacheItem : HSCelMovieObjectFramesCacheItem
{
}
- (id)frameImage:(id)aImage;
- (id)initWithFrameMediaUID:(id)aUID groupOwner:(id)aOwner;
@end

@interface HSGroupCacheItem : NSObject <HSGroupCacheItem, HSAbstractCacheItem, NSObject>
{
    NSString *_groupIdentifier;
    NSMutableDictionary *_groupCache;
}
- (NSUInteger)hardLinkCount;
- (id)groupCacheCreateIfNeed:(BOOL)aNeed;
- (id)groupIdentifier;
- (void)dealloc;
- (id)initWithIdentifier:(id)aIdentifier;
@end

@interface HSCelMovieObjectFramesCacheManager : NSObject
{
    NSMutableDictionary *_cacheDictionary;
    NSTimer *_releasingTimer;
    NSMutableArray *_itemsToRelease;
}
+ (id)sharedMannagerShouldCreate:(BOOL)aCreate;
+ (id)sharedMannager;
- (void)releaseItemsOnTimer:(id)aTimer;
- (id)cachedFrameForMediaUID:(id)aUID groupIdentifier:(id)aIdentifier;
- (void)precacheFramesMedia:(id)aMedia frameImages:(id)aImages;
- (id)registerGroupWithIdentifier:(id)aIdentifier;
- (id)registerFrameImageLazyWithMediaUID:(id)aUID cacheObject:(id)aObject group:(id)aGroup;
- (id)registerFrameImage:(id)aImage mediaUID:(id)aUID cacheObject:(id)aObject group:(id)aGroup;
- (void)unlinkItems:(id)aItems cacheObject:(id)aObject;
- (id)linkItemToCacheObject:(id)aObject mediaUID:(id)aUID group:(id)aGroup;
- (void)dealloc;
- (id)init;
@end

@interface HSCelMovieObjectFramesCache : NSObject
{
    NSMutableArray *_cachedFrames;
    id<HSCelMovieObjectFramesDataSource> _frameDataSource;
    id<HSGroupCacheItem> _framesMediaGroup;
}
+ (id)cachedFrameForMediaUID:(id)aUID groupIdentifier:(id)aIdentifier;
+ (void)precacheFramesMedia:(id)aMedia frameImages:(id)aImages;
- (NSUInteger)cachedFramesCount;
- (id)cachedFrameAtIndex:(NSUInteger)aIndex;
- (void)cacheFramesWithMedia:(id)aMedia;
- (void)addCacheFrameWithMediaUID:(id)aUID;
- (void)addCacheFrameWithMediaUID:(id)aUID frameImage:(id)aImage;
- (void)dealloc;
- (id)initWithFramesMedia:(id)aMedia frameDataSource:(id)aSource groupIdentifier:(id)aIdentifier;
- (id)initWithFramesMedia:(id)aMedia frameImages:(id)aImages groupIdentifier:(id)aIdentifier;
- (id)initWithCapacity:(NSUInteger)aCapacity groupIdentifier:(id)aIdentifier;
@end

