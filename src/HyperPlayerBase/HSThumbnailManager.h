#import "HyperPlayerBasePrefix.h"


@interface HSThumbnailManager : NSObject <HSNodeSupport, NSObject>
{
    NSMutableDictionary *_thumbnails;
    NSMutableDictionary *_cachedThumbnails;
    NSRecursiveLock *_thumbnailsLock;
    NSString *_thumbnailsImagesFolder;
    NSImage *_mainThreadImage;
}
+ (id)sharedThumbnailManager;
- (void)generateMovieThumbnailInMainThread:(id)aThread;
- (id)thumbnailsImagesFolder;
- (id)thumbnailFileExtension;
- (BOOL)isThumbnailValid:(id)aValid;
- (void)clenaupThread:(id)aThread;
- (id)cacheThumbnailForUID:(id)aUID;
- (id)createThumbnailForUID:(id)aUID originalImage:(id)aImage;
- (id)cacheThumbnailForObject:(id)aObject;
- (id)createThumbnailForObject:(id)aObject;
- (id)cacheThumbnailForPath:(id)aPath;
- (id)createThumbnailForPath:(id)aPath;
- (id)cachedThumbnailImageForKey:(id)aKey;
- (id)cachedThumbnails;
- (id)thumbnails;
- (void)saveThumbnailsDatabase;
- (void)saveThumbnails;
- (void)loadThumbnails;
- (BOOL)isAttributesNotificationPostingDisabled;
- (id)cardGroupController;
- (id)delegate;
- (id)scriptController;
- (id)undoManager;
- (void)cleanup;
- (BOOL)thumbnailExistForUID:(id)aUID;
- (BOOL)thumbnailExistForObject:(id)aObject;
- (BOOL)thumbnailExistForObjectDescription:(id)aDescription;
- (BOOL)thumbnailExistForPath:(id)aPath;
- (BOOL)thumbnailExistForURL:(id)aURL;
- (void)removeThumbnailForUID:(id)aUID;
- (void)removeThumbnailForObject:(id)aObject;
- (void)removeThumbnailForObjectDescription:(id)aDescription;
- (void)removeThumbnailForPath:(id)aPath;
- (void)removeThumbnailForURL:(id)aURL;
- (id)thumbnailForUID:(id)aUID originalImage:(id)aImage;
- (id)thumbnailForObject:(id)aObject;
- (id)thumbnailForObjectDescription:(id)aDescription;
- (NSSize)thumbnailOriginalSizeForPath:(id)aPath;
- (NSSize)thumbnailOriginalSizeForURL:(id)aURL;
- (id)thumbnailForPath:(id)aPath;
- (id)thumbnailForURL:(id)aURL;
- (CGFloat)thumbnailSize;
- (void)HSThumbnailManager_lock;
- (void)dealloc;
- (id)init;
@end

