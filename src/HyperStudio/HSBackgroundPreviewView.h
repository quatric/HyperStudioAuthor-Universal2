#import "HyperStudioPrefix.h"


@interface HSBackgroundPreviewView : NSView
{
    NSImage *_image;
    int _imageScaling;
    NSArray *_relativeClipPaths;
    CGAffineTransform _relativeClipPathsTransform;
    NSSize _imageSize;
    NSImage *_previewImage;
}
- (void)invalidatePreviewImage;
- (id)previewImage;
- (void)drawRect:(NSRect)aRect;
- (void)applyClipPathsInRect:(NSRect)aRect;
- (NSSize)imageSize;
- (void)setImageSize:(NSSize)aSize;
- (void)setImage:(id)aImage scaling:(NSInteger)aScaling;
- (void)setRelativeClipPaths:(id)aPaths affineTransform:(CGAffineTransform *)aTransform;
- (void)setRelativeClipPaths:(id)aPaths;
- (id)relativeClipPaths;
- (void)setImageScaling:(NSInteger)aScaling;
- (NSInteger)imageScaling;
- (void)setImage:(id)aImage;
- (id)image;
- (void)dealloc;
- (id)init;
@end

@interface HSBackgroundPreviewImageRep : NSImageRep
{
    NSImage *_image;
}
- (BOOL)drawInRect:(NSRect)aRect;
- (BOOL)drawAtPoint:(NSPoint)aPoint;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)initWithPreviewImage:(id)aImage imageSize:(NSSize)aSize;
@end

