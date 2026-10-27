#import "HyperEditorBasePrefix.h"


@interface HSGraphicsLibraryAnimation : NSObject <HSLibraryMediaDataItem, NSObject, HSLibraryMediaDataItemAccessibility>
{
    NSURL *_animationURL;
    BOOL _urlAccessTested;
    BOOL _urlAccessOk;
    NSString *_displayString;
    NSDictionary *_info;
    NSImage *_movieImage;
    NSImage *_invalidMovieImage;
}
+ (BOOL)canInitWithURL:(id)aURL;
- (void)generateMovieImageInMainThread:(id)aThread;
- (id)invalidMovieImage;
- (id)movieImage;
- (id)dataDisplayName;
- (id)dataURL;
- (NSInteger)compareWithAnimation:(id)aAnimation;
- (void)pasteboard:(id)aPasteboard provideDataForType:(id)aType;
- (id)info;
- (BOOL)hasAccessibleURL;
- (id)displayName;
- (id)URL;
- (void)dealloc;
- (id)initWithURL:(id)aURL;
@end

