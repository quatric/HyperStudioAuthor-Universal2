#import "HyperPlayerBasePrefix.h"


@interface HSResizeWindowView : NSView
{
    NSImage *_image;
    float _resizeRightMargin;
    float _resizeBottomMargin;
    BOOL _beginSended;
}
- (void)setResizeBottomMargin:(CGFloat)aMargin;
- (CGFloat)resizeBottomMargin;
- (void)setResizeRightMargin:(CGFloat)aMargin;
- (CGFloat)resizeRightMargin;
- (id)image;
- (void)setImage:(id)aImage;
- (void)resizeWindowWithEvent:(id)aEvent;
- (void)mouseDown:(id)aDown;
- (void)drawRect:(NSRect)aRect;
- (BOOL)isOpaque;
- (void)dealloc;
@end

