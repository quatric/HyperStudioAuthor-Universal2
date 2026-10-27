#import "HyperPlayerBasePrefix.h"


@interface HSNewMediaAccessor : NSObject
{
    NSMapTable *_mediaMap;
    NSMapTable *_groupedUIDs;
    NSArray *_defaultMedia;
}
+ (id)userAnimationObjectClassNamesForMediaType:(id)aType;
+ (id)supportedAnimationMediaTypesDictionary;
+ (BOOL)canCreateMediaObjectOfClass:(Class)aClass withPath:(id)aPath;
+ (id)userActionClassNamesForMediaType:(id)aType;
+ (id)userObjectClassNamesForMediaType:(id)aType;
+ (id)fullPathForMediaPath:(id)aPath mediaType:(id)aType;
+ (id)supportedMediaTypesForClass:(id)aClass;
+ (id)supportedMediaTypes;
+ (id)supportedActionMediaTypesDictionary;
+ (id)supportedMediaTypesDictionary;
+ (id)extensionForHFSType:(id)aType;
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedMediaAccessor;
- (void)cleanupMediaUsedByApplication;
- (void)dereferenceObject:(void *)aObject;
- (id)allMediaUIDsForGroup:(NSInteger)aGroup excludeUnused:(BOOL)aUnused;
- (id)groupedUIDs;
- (void)unregisterMedia:(id)aMedia;
- (void)registerMedia:(id)aMedia;
- (id)mediaForUID:(id)aUID;
- (id)mediaMap;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

