#import "NSBitmapImageRep+HSExtensions.h"
static void NSBitmapImageRepHSExtensionsReleaseData(void *aInfo, const void *aData, size_t aSize)
{
    [(id)aInfo release];
}
@implementation NSBitmapImageRep (HSExtensions)
// At the representation's pixel size (or its point size rounded up when it
// has none).
+ (id)hyperRGBA8888BitmapRepresentationFromImageRepresentation:(id)aRepresentation
{
    if (aRepresentation == nil)
        return nil;
    NSSize size = [aRepresentation size];
    NSInteger wide = [aRepresentation pixelsWide];
    if (wide == 0 && size.width != 0)
        wide = size.width > 0 ? lroundf(ceilf(size.width)) : 0;
    NSInteger high = [aRepresentation pixelsHigh];
    if (high == 0 && size.height != 0)
        high = size.height > 0 ? lroundf(ceilf(size.height)) : 0;
    return [self hyperRGBA8888BitmapRepresentationWithWide:wide high:high fromImageRepresentation:aRepresentation];
}
// A premultiplied RGBA bitmap (rows 16-byte aligned) the representation is
// drawn into; nil when it doesn't draw.
+ (id)hyperRGBA8888BitmapRepresentationWithWide:(NSInteger)aWide high:(NSInteger)aHigh fromImageRepresentation:(id)aRepresentation
{
    if (aRepresentation == nil)
        return nil;
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:aWide pixelsHigh:aHigh
        bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace
        bytesPerRow:(aWide * 4 + 15) & ~(NSInteger)15 bitsPerPixel:32];
    if (bitmap == nil)
        return nil;
    BOOL drawn = NO;
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    if (context != nil) {
        @try {
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:context];
            NSRect rect = NSMakeRect(0, 0, (float)aWide, (float)aHigh);
            CGContextClearRect([context CGContext], rect);
            drawn = [aRepresentation drawInRect:rect];
            [NSGraphicsContext restoreGraphicsState];
        } @catch (NSException *exception) {
        }
    }
    if (drawn)
        return [bitmap autorelease];
    [bitmap release];
    return nil;
}
// The Core Graphics colour space for an AppKit colour space name; the
// "black" (inverted) gray spaces come with a {1, 0} decode array (only when
// asked for one). (The decode array was float, i.e. CGFloat on i386; it
// holds CGFloats.)
+ (struct CGColorSpace *)hyperCGColorSpaceForName:(id)aName decode:(CGFloat **)aDecode
{
    if (aDecode != NULL)
        *aDecode = NULL;
    CGColorSpaceRef colorSpace = NULL;
    BOOL inverted = NO;
    // (Tiger checks dropped: the generic spaces exist since 10.4.)
    if ([aName isEqualToString:NSCalibratedWhiteColorSpace])
        colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericGray);
    else if ([aName isEqualToString:NSCalibratedBlackColorSpace])
        inverted = YES;
    else if ([aName isEqualToString:NSCalibratedRGBColorSpace])
        colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    else if ([aName isEqualToString:NSDeviceWhiteColorSpace])
        colorSpace = CGColorSpaceCreateDeviceGray();
    else if ([aName isEqualToString:NSDeviceBlackColorSpace])
        inverted = YES;
    else if ([aName isEqualToString:NSDeviceRGBColorSpace])
        colorSpace = CGColorSpaceCreateDeviceRGB();
    else if ([aName isEqualToString:NSDeviceCMYKColorSpace])
        colorSpace = CGColorSpaceCreateDeviceCMYK();
    if (inverted && aDecode != NULL) {
        // (The original asked for an 8-byte capacity, not length.)
        *aDecode = [[NSMutableData dataWithLength:2 * sizeof(CGFloat)] mutableBytes];
        if (*aDecode != NULL) {
            colorSpace = [aName isEqualToString:NSCalibratedBlackColorSpace]
                ? CGColorSpaceCreateWithName(kCGColorSpaceGenericGray) : CGColorSpaceCreateDeviceGray();
            (*aDecode)[0] = 1.0;
            (*aDecode)[1] = 0.0;
        }
    }
    [HSCFObject autoreleasedCFObject:colorSpace];
    return colorSpace;
}
// A CGImage over the bitmap data (the image keeps the rep alive).
- (struct CGImage *)hyperCGImage
{
    CGFloat *decode = NULL;
    CGColorSpaceRef colorSpace = [self hyperCGColorSpaceAndDecode:&decode];
    if (colorSpace == NULL)
        return NULL;
    NSInteger high = [self pixelsHigh];
    NSInteger bytesPerRow = [self bytesPerRow];
    CGDataProviderRef provider = CGDataProviderCreateWithData(self, [self bitmapData], bytesPerRow * high, NSBitmapImageRepHSExtensionsReleaseData);
    if (provider == NULL)
        return NULL;
    [self retain];
    [HSCFObject autoreleasedCFObject:provider];
    CGImageRef image = CGImageCreate([self pixelsWide], high, [self bitsPerSample], [self bitsPerPixel], bytesPerRow, colorSpace,
                                     (CGBitmapInfo)[self hyperCGBitmapInfo], provider, decode, true, kCGRenderingIntentDefault);
    [HSCFObject autoreleasedCFObject:image];
    return image;
}
// The CGBitmapInfo for the rep's bitmap format.
- (NSInteger)hyperCGBitmapInfo
{
    if (![self respondsToSelector:@selector(bitmapFormat)])
        return [self hasAlpha] ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNone;
    NSBitmapFormat format = [self bitmapFormat];
    NSInteger info;
    if (![self hasAlpha])
        info = (format & NSBitmapFormatAlphaFirst) ? kCGImageAlphaNoneSkipFirst : kCGImageAlphaNoneSkipLast;
    else if (!(format & NSBitmapFormatAlphaFirst))
        info = (format & NSBitmapFormatAlphaNonpremultiplied) ? kCGImageAlphaLast : kCGImageAlphaPremultipliedLast;
    else
        // The original tested the whole format for 0 here (never true with
        // alpha first), so premultiplied alpha first came out as
        // kCGImageAlphaFirst.
        info = (format & NSBitmapFormatAlphaNonpremultiplied) ? kCGImageAlphaFirst : kCGImageAlphaPremultipliedFirst;
    if (format & NSBitmapFormatFloatingPointSamples)
        info |= kCGBitmapFloatComponents;
    return info;
}
- (struct CGColorSpace *)hyperCGColorSpaceAndDecode:(CGFloat **)aDecode
{
    return [[self class] hyperCGColorSpaceForName:[self colorSpaceName] decode:aDecode];
}
@end
