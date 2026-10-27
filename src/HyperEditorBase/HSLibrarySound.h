#import "HyperEditorBasePrefix.h"


@interface HSLibrarySound : NSObject <HSLibraryMediaDataItem, NSObject, HSLibraryMediaDataItemAccessibility>
{
    NSURL *_soundURL;
    BOOL _urlAccessTested;
    BOOL _urlAccessOk;
    NSString *_displayString;
    NSDictionary *_info;
    NSNumber *_duration;
}
+ (id)stringForValue:(id)aValue forIdentifier:(id)aIdentifier;
+ (CGFloat)maxWidthForIdentifier:(id)aIdentifier cell:(id)aCell;
+ (CGFloat)minWidthForIdentifier:(id)aIdentifier cell:(id)aCell;
+ (id)soundIdentifiers;
+ (BOOL)canInitWithURL:(id)aURL;
- (id)getTotalTime;
- (id)getArtist;
- (id)getName;
- (NSInteger)compareWithSound:(id)aSound;
- (id)dataDisplayName;
- (id)dataURL;
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (id)info;
- (BOOL)hasAccessibleURL;
- (id)displayName;
- (id)URL;
- (void)dealloc;
- (id)initWithURL:(id)aURL;
@end

