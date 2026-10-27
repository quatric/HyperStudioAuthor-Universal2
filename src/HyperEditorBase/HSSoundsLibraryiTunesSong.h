#import "HyperEditorBasePrefix.h"


@interface HSSoundsLibraryiTunesSong : NSObject <HSLibraryMediaDataItem, NSObject, HSLibraryMediaDataItemAccessibility>
{
    NSDictionary *_info;
    BOOL _urlAccessTested;
    BOOL _urlAccessOk;
    NSImage *_hasVideoImage;
}
+ (id)valueForSong:(id)aSong forIdentifier:(id)aIdentifier lineBreakInfo:(id)aInfo;
+ (id)stringForSong:(id)aSong forIdentifier:(id)aIdentifier;
+ (id)dataCellForIdentifier:(id)aIdentifier;
+ (CGFloat)maxWidthForIdentifier:(id)aIdentifier cell:(id)aCell;
+ (CGFloat)minWidthForIdentifier:(id)aIdentifier cell:(id)aCell;
+ (id)songIdentifiers;
- (id)hasVideoImage;
- (BOOL)hasVideo;
- (id)dataDisplayName;
- (id)dataURL;
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (id)info;
- (void)resetURLAccessTested;
- (BOOL)hasAccessibleURL;
- (id)displayName;
- (id)URL;
- (void)dealloc;
- (id)initWithDictionaryRepresentation:(id)aRepresentation;
- (id)init;
@end

