#import "HyperStudioPrefix.h"


@interface HSWheelColorView : NSView
{
    NSImage *_wheelImage;
    HSWheelColorViewController *_controller;
}
+ (id)defaultColor;
- (BOOL)acceptsFirstResponder;
- (id)wheelImage;
- (void)mouseDown:(id)aDown;
- (id)colorAtLocation:(NSPoint)aLocation useWheelPath:(BOOL)aPath;
- (id)wheelPath;
- (NSRect)wheelRect;
- (void)setColor:(id)aColor;
- (id)color;
- (void)drawSelectionInWheelWithRadius:(CGFloat)aRadius;
- (void)drawRect:(NSRect)aRect;
- (id)initWithFrame:(NSRect)aFrame;
- (void)dealloc;
@end

