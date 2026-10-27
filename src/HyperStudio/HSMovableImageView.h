#import "HyperStudioPrefix.h"


@interface HSMovableImageView : NSView
{
    NSImage *_previewImage;
    struct HyperStudio_anon4 _movableImageViewFlags;
    NSPoint _dragPoint;
    NSPoint _currentDrawPoint;
    NSSize _maxDragSize;
    NSSize _imageSize;
    NSSize _viewRectSize;
    float _horizontalScale;
    float _verticalScale;
}
- (NSSize)imageViewSize;
- (void)dealloc;
- (id)image;
- (void)setImage:(id)aImage resetPosition:(BOOL)aPosition viewRectSize:(NSSize)aSize imageScaling:(NSUInteger)aScaling;
- (void)setImage:(id)aImage resetPosition:(BOOL)aPosition viewRectSize:(NSSize)aSize;
- (void)drawRect:(NSRect)aRect;
- (void)resetCursorRects;
- (id)initWithFrame:(NSRect)aFrame;
@end

@interface HSMovableImageView (MouseHandling)
- (void)handleMouseDragged:(id)aDragged;
- (void)mouseDown:(id)aDown;
- (void)resetCursorRectsForEvent:(id)aEvent;
@end

