#import "HyperEditorBasePrefix.h"


@interface HSGraphicsLibraryiPhotoPhoto : NSObject <HSLibraryMediaDataItem, NSObject, HSLibraryMediaDataItemAccessibility>
{
    NSDictionary *_info;
    BOOL _urlAccessTested;
    BOOL _urlAccessOk;
}
- (id)imageUID;
- (id)imageRepresentation;
- (id)imageRepresentationType;
- (id)dataDisplayName;
- (id)dataURL;
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (id)info;
- (BOOL)hasAccessibleURL;
- (id)displayName;
- (id)thumbURL;
- (id)URL;
- (void)dealloc;
- (id)initWithDictionaryRepresentation:(id)aRepresentation;
- (id)init;
@end

