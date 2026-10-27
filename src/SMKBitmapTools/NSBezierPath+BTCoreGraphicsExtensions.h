#import "SMKBitmapToolsPrefix.h"


@interface NSBezierPath (BTCoreGraphicsExtensions)
+ (id)BT_bezierPathWithCGPath:(struct CGPath *)aPath;
- (struct CGPath *)BT_coreGraphicsPath;
@end

