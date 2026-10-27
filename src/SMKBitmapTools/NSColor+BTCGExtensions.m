#import "NSColor+BTCGExtensions.h"
#import "BTPointer.h"

// NSColor -> CGColor / CGEColor / CGColorSpace. Results are autoreleased (the
// CGEColor through a BTPointer).

// Draws a pattern colour's image as a pattern cell.
static void DrawPatternCell(void *info, CGContextRef context)
{
    NSImage *image = info;
    @try {
        NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
        if (graphicsContext) {
            NSGraphicsContext *current = [[NSGraphicsContext currentContext] retain];
            [NSGraphicsContext setCurrentContext:graphicsContext];
            [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
            [NSGraphicsContext setCurrentContext:current];
            [current release];
        }
    } @catch (id exception) {
        NSLog(@"Exception was raised while drawing a pattern cell. Ignored.");
        NSLog(@"%@", exception);
    }
}

static void ReleasePatternCell(void *info)
{
    [(id)info release];
}

@implementation NSColor (BTCGExtensions)

+ (struct CGColorSpace *)NSColor_BTCGExtensions_coreGraphicsColorSpaceForColorSpace:(id)aSpace
{
    if ([aSpace respondsToSelector:@selector(CGColorSpace)]) {
        CGColorSpaceRef space = [aSpace CGColorSpace];
        if (space)
            return space;
    }
    // The original went through the space's ColorSync profile first.
    NSData *data = [aSpace ICCProfileData];
    if (!data)
        return NULL;
    return (CGColorSpaceRef)CFAutorelease(CGColorSpaceCreateWithICCData((CFDataRef)data));
}

+ (struct CGColorSpace *)NSColor_BTCGExtensions_coreGraphicsGenericGrayColorSpace
{
    return (CGColorSpaceRef)CFAutorelease(CGColorSpaceCreateWithName(kCGColorSpaceGenericGray));
}

+ (struct CGColorSpace *)NSColor_BTCGExtensions_coreGraphicsGenericRGBColorSpace
{
    return (CGColorSpaceRef)CFAutorelease(CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB));
}

- (struct CGEColor *)BT_coreGraphicsExtendedColor
{
    CGEColorRef color = NULL;
    [self NSColor_BTCGExtensions_getCoreGraphicsColor:NULL coreGraphicsExtendedColor:&color coreGraphicsColorSpace:NULL];
    return color;
}

- (struct CGColor *)BT_coreGraphicsColor
{
    CGColorRef color = NULL;
    [self NSColor_BTCGExtensions_getCoreGraphicsColor:&color coreGraphicsExtendedColor:NULL coreGraphicsColorSpace:NULL];
    return color;
}

- (struct CGColorSpace *)BT_coreGraphicsColorSpace
{
    CGColorSpaceRef space = NULL;
    [self NSColor_BTCGExtensions_getCoreGraphicsColor:NULL coreGraphicsExtendedColor:NULL coreGraphicsColorSpace:&space];
    return space;
}

- (BOOL)NSColor_BTCGExtensions_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace
{
    NSString *name = [self colorSpaceName];
    if (!name)
        return NO;
    if ([name isEqualToString:NSPatternColorSpace])
        return [self NSColor_BTCGExtensions_NSPatternColorSpace_getCoreGraphicsColor:aColor
                                                          coreGraphicsExtendedColor:aColor2
                                                             coreGraphicsColorSpace:aSpace];
    if (![name isEqualToString:NSNamedColorSpace]) {
        NSColorSpace *colorSpace = [self colorSpace];
        CGColorSpaceRef space = colorSpace
            ? [[self class] NSColor_BTCGExtensions_coreGraphicsColorSpaceForColorSpace:colorSpace]
            : NULL;
        if (space) {
            if (aColor || aColor2) {
                NSInteger count = [self numberOfComponents];
                if (count) {
                    CGFloat components[count];
                    [self getComponents:components];
                    CGColorRef color = (CGColorRef)CFAutorelease(CGColorCreate(space, components));
                    if (!color)
                        return NO;
                    if (aColor2) {
                        CGEColorRef extended = CGEColorCreateWithCGColor(color);
                        if (![BTPointer autoreleasedPointer:extended withDisposer:CGEColorRelease])
                            return NO;
                        *aColor2 = extended;
                    }
                    if (aColor)
                        *aColor = color;
                    if (aSpace)
                        *aSpace = space;
                    return YES;
                }
            } else {
                if (aSpace)
                    *aSpace = space;
                return YES;
            }
        }
    }
    // The original then tried
    // -NSColor_BTCGExtensions_<space name>_getCoreGraphicsColor:coreGraphicsColorSpace:, a selector
    // nothing implements (the methods below take three arguments), so it always came here.
    NSColor *rgb = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (!rgb)
        return NO;
    return [rgb NSColor_BTCGExtensions_NSCalibratedRGBColorSpace_getCoreGraphicsColor:aColor
                                                            coreGraphicsExtendedColor:aColor2
                                                               coreGraphicsColorSpace:aSpace];
}

- (BOOL)NSColor_BTCGExtensions_NSPatternColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace
{
    NSImage *image = nil;
    NSSize size = NSZeroSize;
    if (aColor || aColor2) {
        image = [self patternImage];
        if (!image)
            return NO;
        size = [image size];
    }
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    CGColorSpaceRef space = NULL;
    CGColorRef color = NULL;
    if (aColor || aSpace) {
        space = (CGColorSpaceRef)CFAutorelease(CGColorSpaceCreatePattern(NULL));
        if (!space)
            return NO;
        if (aColor) {
            CGPatternCallbacks callbacks = {0, DrawPatternCell, ReleasePatternCell};
            CGPatternRef pattern = CGPatternCreate(image, bounds, CGAffineTransformIdentity, size.width, size.height,
                                                   kCGPatternTilingConstantSpacing, true, &callbacks);
            if (!pattern)
                return NO;
            [image retain];
            CGFloat alpha = [self alphaComponent];
            color = CGColorCreateWithPattern(space, pattern, &alpha);
            CGPatternRelease(pattern);
            if (!color)
                return NO;
            CFAutorelease(color);
        }
    }
    if (aColor2) {
        CGFloat alpha = [self alphaComponent];
        CGEColorRef extended =
            CGEColorCreateUserPattern(image, bounds, size.width, size.height, kCGPatternTilingConstantSpacing, NULL,
                                      &alpha, DrawPatternCell, ReleasePatternCell);
        if (!extended)
            return NO;
        [image retain];
        if (![BTPointer autoreleasedPointer:extended withDisposer:CGEColorRelease])
            return NO;
        *aColor2 = extended;
    }
    if (aColor)
        *aColor = color;
    if (aSpace)
        *aSpace = space;
    return YES;
}

- (BOOL)NSColor_BTCGExtensions_getSolidCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 withCoreGraphicsColorSpace:(struct CGColorSpace *)aSpace colorComponents:(const CGFloat *)aComponents
{
    CGColorRef color = CGColorCreate(aSpace, aComponents);
    if (!color)
        return NO;
    CFAutorelease(color);
    if (aColor2) {
        CGEColorRef extended = CGEColorCreateWithCGColor(color);
        if (![BTPointer autoreleasedPointer:extended withDisposer:CGEColorRelease])
            return NO;
        *aColor2 = extended;
    }
    if (aColor)
        *aColor = color;
    return YES;
}

// The solid spaces: the components in the space, through the method above.
static BOOL GetSolidColor(NSColor *self, CGColorRef *aColor, CGEColorRef *aColor2, CGColorSpaceRef *aSpace,
                          CGColorSpaceRef space, const CGFloat *components)
{
    if (!space)
        return NO;
    if ((aColor || aColor2) && ![self NSColor_BTCGExtensions_getSolidCoreGraphicsColor:aColor
                                                             coreGraphicsExtendedColor:aColor2
                                                            withCoreGraphicsColorSpace:space
                                                                       colorComponents:components])
        return NO;
    if (aSpace)
        *aSpace = space;
    return YES;
}

- (BOOL)NSColor_BTCGExtensions_NSDeviceCMYKColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace
{
    CGFloat c[5] = {0, 0, 0, 0, 0};
    if (aColor || aColor2)
        [self getCyan:&c[0] magenta:&c[1] yellow:&c[2] black:&c[3] alpha:&c[4]];
    return GetSolidColor(self, aColor, aColor2, aSpace, (CGColorSpaceRef)CFAutorelease(CGColorSpaceCreateDeviceCMYK()), c);
}

- (BOOL)NSColor_BTCGExtensions_NSDeviceBlackColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace
{
    CGFloat c[2] = {0, 0};
    if (aColor || aColor2) {
        [self getWhite:&c[0] alpha:&c[1]];
        c[0] = 1.0 - c[0];
    }
    return GetSolidColor(self, aColor, aColor2, aSpace, (CGColorSpaceRef)CFAutorelease(CGColorSpaceCreateDeviceGray()), c);
}

- (BOOL)NSColor_BTCGExtensions_NSCalibratedBlackColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace
{
    CGFloat c[2] = {0, 0};
    if (aColor || aColor2) {
        [self getWhite:&c[0] alpha:&c[1]];
        c[0] = 1.0 - c[0];
    }
    return GetSolidColor(self, aColor, aColor2, aSpace, [[self class] NSColor_BTCGExtensions_coreGraphicsGenericGrayColorSpace], c);
}

- (BOOL)NSColor_BTCGExtensions_NSDeviceWhiteColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace
{
    CGFloat c[2] = {0, 0};
    if (aColor || aColor2)
        [self getWhite:&c[0] alpha:&c[1]];
    return GetSolidColor(self, aColor, aColor2, aSpace, (CGColorSpaceRef)CFAutorelease(CGColorSpaceCreateDeviceGray()), c);
}

- (BOOL)NSColor_BTCGExtensions_NSCalibratedWhiteColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace
{
    CGFloat c[2] = {0, 0};
    if (aColor || aColor2)
        [self getWhite:&c[0] alpha:&c[1]];
    return GetSolidColor(self, aColor, aColor2, aSpace, [[self class] NSColor_BTCGExtensions_coreGraphicsGenericGrayColorSpace], c);
}

- (BOOL)NSColor_BTCGExtensions_NSDeviceRGBColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace
{
    CGFloat c[4] = {0, 0, 0, 0};
    if (aColor || aColor2)
        [self getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
    return GetSolidColor(self, aColor, aColor2, aSpace, (CGColorSpaceRef)CFAutorelease(CGColorSpaceCreateDeviceRGB()), c);
}

- (BOOL)NSColor_BTCGExtensions_NSCalibratedRGBColorSpace_getCoreGraphicsColor:(struct CGColor **)aColor coreGraphicsExtendedColor:(struct CGEColor **)aColor2 coreGraphicsColorSpace:(struct CGColorSpace **)aSpace
{
    CGFloat c[4] = {0, 0, 0, 0};
    if (aColor || aColor2)
        [self getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
    return GetSolidColor(self, aColor, aColor2, aSpace, [[self class] NSColor_BTCGExtensions_coreGraphicsGenericRGBColorSpace], c);
}

@end
