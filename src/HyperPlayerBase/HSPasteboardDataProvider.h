#import "HyperPlayerBasePrefix.h"


@interface HSPasteboardDataProvider : NSObject
{
    NSArray *_objects;
    NSArray *_cards;
    NSMutableSet *_mediaUIDs;
    NSMutableArray *_medias;
    NSSet *_groupUIDs;
    NSSet *_unrefreshingUIDs;
    NSImage *_objectsImage;
    NSString *_objectString;
    NSAttributedString *_objectAttributedString;
    NSImage *_cardImage;
    NSString *_tempFilePath;
    NSString *_dragName;
}
+ (id)mediaInfoPasteboardTypePrefix;
+ (id)mediaInfoPasteboardTypeForUID:(id)aUID;
- (id)arrtibutedStringForObject;
- (id)stringForObject;
- (id)imageForObjects;
- (id)pathForCurrentObjectsTempImageFile;
- (id)nextPathForTempImageFile;
- (id)pasteboardTypes;
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (void)removeTypesFromPasteboard:(id)aPasteboard;
- (BOOL)declareTypesForPasteboard:(id)aPasteboard;
- (void)dealloc;
- (id)initWithCards:(id)aCards UIDs:(id)aDs groupUIDs:(id)aDs2 unrefreshingUIDs:(id)aDs3 cardImage:(id)aImage;
- (id)initWithCards:(id)aCards UIDs:(id)aDs groupUIDs:(id)aDs2 cardImage:(id)aImage;
- (id)initWithCards:(id)aCards UIDs:(id)aDs cardImage:(id)aImage;
- (id)initWithObjects:(id)aObjects UIDs:(id)aDs groupUIDs:(id)aDs2 unrefreshingUIDs:(id)aDs3 dragName:(id)aName;
- (id)initWithObjects:(id)aObjects UIDs:(id)aDs groupUIDs:(id)aDs2 dragName:(id)aName;
- (id)initWithObjects:(id)aObjects UIDs:(id)aDs dragName:(id)aName;
- (id)initWithMediaUIDs:(id)aDs;
@end

