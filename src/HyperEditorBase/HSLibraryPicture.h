#import "HyperEditorBasePrefix.h"


@interface HSLibraryPicture : NSObject <HSLibraryMediaDataItem, NSObject, HSLibraryMediaDataItemAccessibility>
{
    NSURL *_pictureURL;
    BOOL _urlAccessTested;
    BOOL _urlAccessOk;
    NSString *_displayString;
    NSDictionary *_info;
    NSImage *_pictureImage;
    NSImage *_invalidPictureImage;
}
+ (id)invalidPictureImage;
+ (BOOL)canInitWithURL:(id)aURL;
- (id)invalidPictureImage;
- (id)dataDisplayName;
- (id)dataURL;
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (NSInteger)compareWithPicture:(id)aPicture;
- (id)pictureImage;
- (id)info;
- (BOOL)hasAccessibleURL;
- (id)displayName;
- (id)URL;
- (void)dealloc;
- (id)initWithURL:(id)aURL;
@end

