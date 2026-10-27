#import "HyperPlayerBasePrefix.h"


@interface NSBitmapImageRep (HSExtensions)
+ (id)hyperRGBA8888BitmapRepresentationFromImageRepresentation:(id)aRepresentation;
+ (id)hyperRGBA8888BitmapRepresentationWithWide:(NSInteger)aWide high:(NSInteger)aHigh fromImageRepresentation:(id)aRepresentation;
+ (struct CGColorSpace *)hyperCGColorSpaceForName:(id)aName decode:(CGFloat **)aDecode;
- (struct CGImage *)hyperCGImage;
- (NSInteger)hyperCGBitmapInfo;
- (struct CGColorSpace *)hyperCGColorSpaceAndDecode:(CGFloat **)aDecode;
@end

