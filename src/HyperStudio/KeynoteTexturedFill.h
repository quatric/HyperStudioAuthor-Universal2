#import "HyperStudioPrefix.h"
#import "KeynoteObject.h"


@interface KeynoteTexturedFill : KeynoteObject
{
    BOOL _isLoaded;
    NSImage *_image;
    NSImage *_tintedImage;
    NSMutableDictionary *_mediaDictionary;
    NSSize _size;
}
- (id)mediaWithSize:(NSSize)aSize;
- (id)scaledTintedImageForSize:(NSSize)aSize;
- (id)tintedImage;
- (id)tintColor;
- (NSSize)size;
- (id)image;
- (void)loadImageAndSize;
- (NSInteger)scaleType;
- (void)didDetail;
- (void)dealloc;
@end

