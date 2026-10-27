#import "SMKBitmapToolsPrefix.h"


@interface NSColor (BTCGExtensions)
+ (struct CGColorSpace *)NSColor_BTCGExtensions_coreGraphicsColorSpaceForColorSpace:(id)aSpace;
+ (struct CGColorSpace *)NSColor_BTCGExtensions_coreGraphicsGenericGrayColorSpace;
+ (struct CGColorSpace *)NSColor_BTCGExtensions_coreGraphicsGenericRGBColorSpace;
- (struct CGEColor *)BT_coreGraphicsExtendedColor;
- (struct CGColor *)BT_coreGraphicsColor;
- (struct CGColorSpace *)BT_coreGraphicsColorSpace;
- (BOOL)NSColor_BTCGExtensions_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace;
- (BOOL)NSColor_BTCGExtensions_NSPatternColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace;
- (BOOL)NSColor_BTCGExtensions_NSDeviceCMYKColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace;
- (BOOL)NSColor_BTCGExtensions_NSDeviceBlackColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace;
- (BOOL)NSColor_BTCGExtensions_NSCalibratedBlackColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace;
- (BOOL)NSColor_BTCGExtensions_NSDeviceWhiteColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace;
- (BOOL)NSColor_BTCGExtensions_NSCalibratedWhiteColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace;
- (BOOL)NSColor_BTCGExtensions_NSDeviceRGBColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace;
- (BOOL)NSColor_BTCGExtensions_NSCalibratedRGBColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace;
- (BOOL)NSColor_BTCGExtensions_getSolidCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 withCoreGraphicsColorSpace:(struct CGColorSpace *)aSpace colorComponents:(const CGFloat *)aComponents;
@end

