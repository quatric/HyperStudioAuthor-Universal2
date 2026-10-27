#import "SMKBitmapToolsPrefix.h"


@interface NSBezierPath (BTPixelizing)
- (id)BT_bezierPathByPixelizingPathWithStep:(NSSize)aStep;
- (void)BT_appendBezierPathWithPixelizedLineToPoint:(NSPoint)aPoint otherPoint:(NSPoint)aPoint2 pixelizationStep:(NSSize)aStep;
@end

