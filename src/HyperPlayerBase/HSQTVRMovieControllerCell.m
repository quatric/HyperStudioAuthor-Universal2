#import "HSQTVRMovieControllerCell.h"
@implementation HSQTVRMovieControllerCell
static NSImage *sDisabledQTVREmptyBarImage;
static NSImage *sDisabledQTVRControlsImage;
+ (id)disabledQTVREmptyBarImage
{
    if (sDisabledQTVREmptyBarImage == nil)
        sDisabledQTVREmptyBarImage = [[HSPlayerBaseID imageNamed:@"QTVREmptyBar_D"] retain];
    return sDisabledQTVREmptyBarImage;
}
+ (id)disabledQTVRControlsImage
{
    if (sDisabledQTVRControlsImage == nil)
        sDisabledQTVRControlsImage = [[HSPlayerBaseID imageNamed:@"QTVRControllerControls_D"] retain];
    return sDisabledQTVRControlsImage;
}
// The (disabled) QTVR controller: the controls at the left, the empty bar
// stretched over the rest.
- (void)drawWithFrame:(NSRect)aFrame inView:(id)aView
{
    NSImage *image = [[NSImage alloc] initWithSize:aFrame.size];
    NSImage *controls = [HSQTVRMovieControllerCell disabledQTVRControlsImage];
    CGFloat controlsWidth = [controls size].width;
    [image lockFocus];
    [controls drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [[HSQTVRMovieControllerCell disabledQTVREmptyBarImage]
        drawInRect:NSMakeRect(controlsWidth, NSZeroRect.origin.y, aFrame.size.width - controlsWidth, aFrame.size.height)
          fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [image unlockFocus];
    [image drawAtPoint:aFrame.origin fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [image release];
}
- (CGFloat)controllerHeight
{
    return 16.0;
}
- (CGFloat)minControllerWidth
{
    return [(NSImage *)[HSQTVRMovieControllerCell disabledQTVRControlsImage] size].width
         + [(NSImage *)[HSQTVRMovieControllerCell disabledQTVREmptyBarImage] size].width;
}
@end
