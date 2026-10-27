#import "NSImage+HSImageSize.h"

static void NSImageHSImageConvertReleaseData(void *aInfo, const void *aData, size_t aSize)
{
    if (aInfo)
        CFRelease(aInfo);
}

@implementation NSImage (HSImageSize)
// The largest non-cached bitmap representation, else the point size.
- (NSSize)hyperPixelsSize
{
    NSSize size;
    if ([self isHyperVectorImage]) {
        size = [self size];
    } else {
        NSArray *representations = [self representations];
        NSUInteger count = [representations count];
        NSInteger width = 0, height = 0;
        NSUInteger i;
        for (i = 0; i < count; i++) {
            NSImageRep *representation = [representations objectAtIndex:i];
            if ([representation isKindOfClass:[NSCachedImageRep class]])
                continue;
            NSInteger pixelsWide = [representation pixelsWide];
            if (width < pixelsWide) {
                height = [representation pixelsHigh];
                width = pixelsWide;
            }
        }
        if (width == 0) {
            NSImageRep *representation = [self bestRepresentationForDevice:nil];
            height = [representation pixelsHigh];
            width = [representation pixelsWide];
        }
        size = NSMakeSize((float)width, (float)height);
    }
    if (size.width <= 0 || size.height <= 0)
        size = [self size];
    return size;
}
- (BOOL)isHyperVectorImage
{
    return [self hyperImageRepOfClass:[NSPDFImageRep class]] || [self hyperImageRepOfClass:[NSEPSImageRep class]] || [self hyperImageRepOfClass:[HSPDFArtBoxImageRep class]];
}
@end

@implementation NSImage (HSImageDrawing)
// Scaling: 0 fit, 2 fill, 3 stretch, 4 original size, 5 tile; 1 and others
// draw nothing.
- (void)hyperDrawInRect:(NSRect)aRect ofBounds:(NSRect)aBounds withAlignment:(NSUInteger)aAlignment scaling:(NSInteger)aScaling
{
    [NSGraphicsContext saveGraphicsState];
    NSRectClip(aRect);
    BOOL draws = ((NSUInteger)aScaling < 6 && ((0x25u >> (aScaling & 0x1f)) & 1)) || (NSUInteger)(aScaling - 3) < 2;
    NSSize size = [self size];
    if (draws && !NSEqualSizes(size, NSZeroSize)) {
        NSRect source = NSMakeRect(0, 0, size.width, size.height);
        if (aScaling == 5) {
            BOOL wholeBounds = NSEqualRects(aRect, aBounds);
            CGFloat x, y;
            for (x = aBounds.origin.x; x < aBounds.origin.x + aBounds.size.width; x += size.width) {
                for (y = aBounds.origin.y; y < aBounds.size.height + aBounds.origin.y; y += size.height) {
                    if (wholeBounds || NSIntersectsRect(NSMakeRect(x, y, size.width, size.height), aRect))
                        [self drawAtPoint:NSMakePoint(x, y) fromRect:source operation:NSCompositingOperationSourceOver fraction:1.0];
                }
            }
        } else {
            NSRect destination = aBounds;
            switch (aScaling) {
            case 0:
            case 2: {
                float yScale = (float)(aBounds.size.height / size.height);
                float xScale = (float)(aBounds.size.width / size.width);
                float scale = aScaling == 0 ? fminf(xScale, yScale) : fmaxf(yScale, xScale);
                destination.size.width = size.width * scale;
                // (sic) The height uses the vertical factor, so it always
                // equals the bounds height.
                destination.size.height = size.height * yScale;
                break;
            }
            case 3:
                break;
            case 4:
                destination.size = size;
                break;
            }
            [self changeImageAlignment:aAlignment withBounds:&aBounds destination:&destination];
            [self drawInRect:destination fromRect:source operation:NSCompositingOperationSourceOver fraction:1.0];
        }
    }
    [NSGraphicsContext restoreGraphicsState];
}
// NSImageAlignment in a flipped view: "top" keeps the origin's y.
- (void)changeImageAlignment:(NSUInteger)aAlignment withBounds:(NSRect *)aBounds destination:(NSRect *)aDestination
{
    if (aAlignment > NSImageAlignRight)
        return;
    CGFloat dx = (aBounds->size.width - aDestination->size.width) * 0.5;
    CGFloat dy = (aBounds->size.height - aDestination->size.height) * 0.5;
    switch (aAlignment) {
    case NSImageAlignCenter:
        aDestination->origin.x += dx;
        aDestination->origin.y += dy;
        break;
    case NSImageAlignTop:
        aDestination->origin.x += dx;
        break;
    case NSImageAlignTopLeft:
        break;
    case NSImageAlignTopRight:
        aDestination->origin.x += 2 * dx;
        break;
    case NSImageAlignLeft:
        aDestination->origin.y += dy;
        break;
    case NSImageAlignBottom:
        aDestination->origin.x += dx;
        aDestination->origin.y += 2 * dy;
        break;
    case NSImageAlignBottomLeft:
        aDestination->origin.y += 2 * dy;
        break;
    case NSImageAlignBottomRight:
        aDestination->origin.x += 2 * dx;
        aDestination->origin.y += 2 * dy;
        break;
    case NSImageAlignRight:
        aDestination->origin.x += 2 * dx;
        aDestination->origin.y += dy;
        break;
    }
}
@end

@implementation NSImage (HSImageRepresentation)
- (id)hyperPNGRepresentationWithWide:(NSInteger)aWide high:(NSInteger)aHigh
{
    return [[NSBitmapImageRep hyperRGBA8888BitmapRepresentationWithWide:aWide high:aHigh fromImageRepresentation:[self bestRepresentationForDevice:nil]] representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
}
- (id)hyperPNGRepresentation
{
    return [self hyperRepresentationUsingType:NSBitmapImageFileTypePNG properties:@{}];
}
- (id)hyperRepresentationUsingType:(NSUInteger)aType properties:(id)aProperties
{
    NSBitmapImageRep *representation = [self hyperImageRepOfClass:[NSBitmapImageRep class]];
    if (!representation)
        representation = [NSBitmapImageRep hyperRGBA8888BitmapRepresentationFromImageRepresentation:[self bestRepresentationForDevice:nil]];
    return [representation representationUsingType:aType properties:aProperties ? aProperties : @{}];
}
- (id)hyperImageRepOfClass:(Class)aClass
{
    NSEnumerator *enumerator = [[self representations] objectEnumerator];
    id representation;
    while ((representation = [enumerator nextObject])) {
        if ([representation isKindOfClass:aClass])
            return representation;
    }
    return nil;
}
@end

@implementation NSImage (HSImageConvert)
// The first bitmap representation's image, else the first representation
// drawn into a new bitmap. The result is autoreleased.
- (struct CGImage *)hyperQuartzImage
{
    NSEnumerator *enumerator = [[self representations] objectEnumerator];
    id representation;
    while ((representation = [enumerator nextObject])) {
        if ([representation isKindOfClass:[NSBitmapImageRep class]]) {
            CGImageRef image = [representation hyperCGImage];
            if (image)
                return image;
            break;
        }
    }
    if (![[self representations] count])
        return NULL;
    NSImageRep *first = [[self representations] objectAtIndex:0];
    if (!first)
        return NULL;
    CGFloat *decode = NULL;
    CGColorSpaceRef colorSpace = [NSBitmapImageRep hyperCGColorSpaceForName:[first colorSpaceName] decode:&decode];
    if (!colorSpace) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        [HSCFObject autoreleasedCFObject:(void *)colorSpace];
    }
    NSInteger width = [first pixelsWide];
    NSInteger height = [first pixelsHigh];
    NSInteger bitsPerSample = [first bitsPerSample];
    size_t components = CGColorSpaceGetNumberOfComponents(colorSpace);
    size_t rowBytes = (((([first hasAlpha] ? 1 : 0) + components) * bitsPerSample + 7) >> 3) * width + 15 & ~(size_t)15;
    CGBitmapInfo alphaInfo = [first hasAlpha] ? (CGBitmapInfo)kCGImageAlphaPremultipliedFirst : (CGBitmapInfo)kCGImageAlphaNone;
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, rowBytes * height);
    if (!data)
        return NULL;
    // The original only reserved the capacity.
    CFDataSetLength(data, rowBytes * height);
    [HSCFObject autoreleasedCFObject:(void *)data];
    CGDataProviderRef provider = CGDataProviderCreateWithData((void *)data, CFDataGetMutableBytePtr(data), rowBytes * height, NSImageHSImageConvertReleaseData);
    if (!provider)
        return NULL;
    [HSCFObject autoreleasedCFObject:(void *)provider];
    CFRetain(data);
    CGContextRef context = CGBitmapContextCreate(CFDataGetMutableBytePtr(data), width, height, bitsPerSample, rowBytes, colorSpace, alphaInfo);
    if (!context)
        return NULL;
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
    NSGraphicsContext *current = [[NSGraphicsContext currentContext] retain];
    [NSGraphicsContext setCurrentContext:graphicsContext];
    [first drawInRect:NSMakeRect(0, 0, (float)width, (float)height)];
    [NSGraphicsContext setCurrentContext:current];
    [current release];
    CGImageRef image = CGImageCreate(width, height, CGBitmapContextGetBitsPerComponent(context), CGBitmapContextGetBitsPerPixel(context), rowBytes, colorSpace, alphaInfo, provider, decode, true, kCGRenderingIntentDefault);
    CGContextRelease(context);
    if (image)
        [HSCFObject autoreleasedCFObject:(void *)image];
    return image;
}
@end

@implementation NSImage (HSImageCreation)
+ (id)hyperImagesWithContentsOfPDFFile:(id)aFile
{
    NSMutableArray *images = [NSMutableArray array];
    for (NSImageRep *representation in [HSPDFArtBoxImageRep imageRepsForAllPDFPagesWithData:[NSData dataWithContentsOfFile:aFile]]) {
        NSImage *image = [[NSImage alloc] initWithSize:[representation size]];
        [image addRepresentation:representation];
        [images addObject:image];
        [image release];
    }
    return images;
}
+ (id)hyperImageWithContentsOfFile:(id)aFile
{
    return [self hyperImageWithData:[NSData dataWithContentsOfFile:aFile]];
}
// PDF data keeps its art box.
+ (id)hyperImageWithData:(id)aData
{
    if (![HSPDFArtBoxImageRep canInitWithData:aData])
        return [[[NSImage alloc] initWithData:aData] autorelease];
    HSPDFArtBoxImageRep *representation = [[[HSPDFArtBoxImageRep alloc] initWithData:aData] autorelease];
    NSImage *image = [[[NSImage alloc] initWithSize:[representation size]] autorelease];
    [image addRepresentation:representation];
    return image;
}
+ (id)hyperImageWithNSImage:(id)aImage
{
    NSData *pdf = [[aImage hyperImageRepOfClass:[NSPDFImageRep class]] PDFRepresentation];
    if (pdf)
        aImage = [NSImage hyperImageWithData:pdf];
    return aImage;
}
+ (id)hyperImageWithCGImage:(struct CGImage *)aImage
{
    if (!aImage)
        return nil;
    return [self hyperImageWithCGImage:aImage size:NSMakeSize((float)CGImageGetWidth(aImage), (float)CGImageGetHeight(aImage))];
}
+ (id)hyperImageWithCGImage:(struct CGImage *)aImage size:(NSSize)aSize
{
    HSCGImageImageRep *representation = [[HSCGImageImageRep alloc] initWithCGImage:aImage];
    if (!representation)
        return nil;
    [representation setSize:aSize];
    NSImage *image = [[[self alloc] initWithSize:NSMakeSize((float)[representation pixelsWide], (float)[representation pixelsHigh])] autorelease];
    [image addRepresentation:representation];
    [representation release];
    return image;
}
+ (id)hyperImageWithWindow:(id)aWindow
{
    return [[[self alloc] initWithHyperWindow:aWindow frame:[[aWindow contentView] frame]] autorelease];
}
+ (id)hyperImageWithView:(id)aView
{
    return [[[self alloc] initWithHyperView:aView] autorelease];
}
// Makes the window key for a moment so it is fully drawn, then caches it.
- (id)initWithHyperWindow:(id)aWindow frame:(NSRect)aFrame
{
    if (aWindow) {
        self = [self initWithSize:aFrame.size];
        if (self) {
            NSWindow *keyWindow = [NSApp keyWindow];
            if (![aWindow areCursorRectsEnabled]) {
                [aWindow becomeKeyWindow];
                [aWindow displayIfNeeded];
                [keyWindow makeKeyWindow];
            } else {
                [aWindow disableCursorRects];
                [aWindow becomeKeyWindow];
                [aWindow displayIfNeeded];
                [keyWindow makeKeyWindow];
                [aWindow enableCursorRects];
            }
            NSCachedImageRep *representation = [[[[[NSCachedImageRep alloc] initWithWindow:aWindow rect:aFrame] autorelease] copy] autorelease];
            if (representation) {
                [self addRepresentation:representation];
                return self;
            }
        }
    }
    [self release];
    return nil;
}
- (id)initWithHyperView:(id)aView
{
    if (aView) {
        NSRect frame = [aView frame];
        self = [self initWithSize:frame.size];
        if (self) {
            [aView setFrameOrigin:NSZeroPoint];
            NSCachedImageRep *representation = [[[NSCachedImageRep alloc] initWithHyperContentOfView:aView size:frame.size flipped:NO] autorelease];
            if (representation) {
                [self addRepresentation:representation];
                return self;
            }
        }
    }
    [self release];
    return nil;
}
@end
