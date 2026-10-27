#import "HSGenericImageRenderLayer.h"
// Renders an image object: its image (or editable bitmap) in its image rect,
// with the object's transparent colour removed.
@implementation HSGenericImageRenderLayer
- (BOOL)willCacheRenderingInRegion:(id)aRegion force:(BOOL)aForce
{
    return YES;
}
// When only the image changed and the change says which part
// ("HSChangedImageRect", in image pixels from the top left), only that part;
// otherwise the whole image rect.
- (BOOL)unionBoundingRegionOfLocalVisualAttributeSet:(id)aSet ofHyperObject:(id)aObject withInfo:(id)aInfo withRegion:(id *)aRegion
{
    NSRect rect = [self HSGenericImageRenderLayer_imageRect];
    if (![aSet containsProtocolsExludingProtocols:@protocol(HSImageAttribute), nil]) {
        NSValue *changed = [aInfo objectForKey:@"HSChangedImageRect"];
        if (changed != nil) {
            CGSize imageSize = [self HSGenericImageRenderLayer_imageSize];
            CGFloat scaleX = imageSize.width != 0 ? rect.size.width / imageSize.width : 1;
            CGFloat scaleY = imageSize.height != 0 ? rect.size.height / imageSize.height : 1;
            CGAffineTransform transform = CGAffineTransformMake(scaleX, 0, 0, -scaleY, rect.origin.x, rect.origin.y + rect.size.height);
            rect = NSRectFromCGRect(CGRectApplyAffineTransform(NSRectToCGRect([changed rectValue]), transform));
        }
    }
    if (*aRegion == nil)
        *aRegion = [HSMutableRegion regionWithRect:rect];
    else
        [*aRegion addRect:rect];
    return YES;
}
- (id)calculateBoundingRegion
{
    return [HSRegion regionWithRect:[self HSGenericImageRenderLayer_imageRect]];
}
- (void)fillBoundingRegionAttributesSet:(id)aSet
{
    [aSet addAttribute:@protocol(HSImageRectAttribute) forObject:[self hyperObject]];
}
- (BOOL)requiresTransparencyLayer
{
    if (_editableImageAttributes != nil)
        return NO;
    return [_imageAttributes isImageComposite];
}
// The image without its transparent colour, for a cel movie (shared with
// HSCelMovieObject): drawn into a BGRA pixel buffer, then copied into another
// one without the colour (within the object's hue/chroma/lightness
// tolerances).
NSImage *HSGenericImageRenderLayerRemovingColorFromCelImage(NSImage *aImage, NSColor *aColor, double aHueTolerance, double aChromaTolerance, double aLightnessTolerance)
{
    NSSize pixelsSize = [aImage hyperPixelsSize];
    size_t width = (size_t)pixelsSize.width, height = (size_t)pixelsSize.height;
    if (width * height == 0 || aColor == nil)
        return nil;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCVPixelBufferCGImageCompatibilityKey, (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef source = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (CFDictionaryRef)attributes, &source);
    if (source == NULL)
        return nil;
    CVBufferSetAttachment(source, (CFStringRef)kCVEPixelBufferAlphaInfoKey, (CFTypeRef)[NSNumber numberWithInt:1], kCVAttachmentMode_ShouldNotPropagate);
    // the original locks it read-only although it draws into it
    CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(source, 0);
    if (context == NULL) {
        CVPixelBufferRelease(source);
        return nil;
    }
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];
    [aImage drawInRect:NSMakeRect(0, 0, width, height) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1];
    [NSGraphicsContext restoreGraphicsState];
    CGContextRelease(context);
    CVPixelBufferRef destination = NULL;
    if (CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, (CFDictionaryRef)attributes, &destination) != kCVReturnSuccess || destination == NULL) {
        CVPixelBufferRelease(source);
        return nil;
    }
    CVBufferRemoveAttachment(destination, (CFStringRef)kCVEImageBufferOpaquenessKey);
    if (CVPixelBufferLockBaseAddress(destination, 0) != kCVReturnSuccess) {
        CVPixelBufferRelease(destination);
        CVPixelBufferRelease(source);
        return nil;
    }
    if (CVPixelBufferLockBaseAddress(source, kCVPixelBufferLock_ReadOnly) != kCVReturnSuccess) {
        CVPixelBufferUnlockBaseAddress(destination, 0);
        CVPixelBufferRelease(destination);
        CVPixelBufferRelease(source);
        return nil;
    }
    CGFloat components[4] = {0, 0, 0, 0};
    [[aColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]] getComponents:components];
    UInt8 red = (UInt8)lroundf(components[0] * 255), green = (UInt8)lroundf(components[1] * 255), blue = (UInt8)lroundf(components[2] * 255);
    OSType format = CVPixelBufferGetPixelFormatType(source);
    if (format == kCVPixelFormatType_32BGRA)
        HSBitmapBGRA8888PremultipliedCopyRemovingColorFromBGRA8888(CVPixelBufferGetBaseAddress(destination), CVPixelBufferGetBytesPerRow(destination),
                                                                   CVPixelBufferGetBaseAddress(source), CVPixelBufferGetBytesPerRow(source),
                                                                   width, height, red, green, blue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
    else if (format == kCVPixelFormatType_32ARGB)
        HSBitmapBGRA8888PremultipliedCopyRemovingColorFromARGB8888(CVPixelBufferGetBaseAddress(destination), CVPixelBufferGetBytesPerRow(destination),
                                                                   CVPixelBufferGetBaseAddress(source), CVPixelBufferGetBytesPerRow(source),
                                                                   width, height, red, green, blue, aHueTolerance, aChromaTolerance, aLightnessTolerance);
    CVPixelBufferUnlockBaseAddress(source, kCVPixelBufferLock_ReadOnly);
    CVPixelBufferUnlockBaseAddress(destination, 0);
    CGImageRef image = CGEImageCreateWithPixelBuffer(destination, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
    CVPixelBufferRelease(source);
    CVPixelBufferRelease(destination);
    if (image == NULL)
        return nil;
    NSImage *result = [NSImage hyperImageWithCGImage:image];
    CGImageRelease(image);
    return result;
}
// The image without its transparent colour, through the shared "replace
// colors" effect (tolerance 0.13).
static NSImage *HSGenericImageRenderLayerRemovingColorWithEffect(NSImage *aImage, NSColor *aColor)
{
    id effect = HSTransparentColorEffect();
    if (aImage == nil || aColor == nil || effect == nil)
        return nil;
    [effect setInputImage:aImage];
    [effect setSourceColor:aColor];
    [effect setTolerance:0.13];
    NSImage *result = nil;
    CGImageRef output = (CGImageRef)[effect valueForKey:@"outputCGImage"];
    if (output != NULL) {
        NSSize size = [aImage size];
        HSCGImageImageRep *rep = [[HSCGImageImageRep alloc] initWithCGImage:output];
        [rep setSize:size];
        result = [[[NSImage alloc] initWithSize:size] autorelease];
        [result addRepresentation:rep];
        [result setDataRetained:YES];
        [rep release];
    }
    [effect setSourceColor:nil];
    [effect setInputImage:nil];
    return result;
}
// In the image rect, flipped (the image's top at the rect's top). The image:
// the transparent colour attributes' cached image when there's one; else the
// editable bitmap (drawn directly when there's no colour to remove) or the
// image. The colour is removed from cel movie images with the pixel copy and
// from editable bitmaps with the effect. The representation drawn is made a
// Core Graphics one first (drawn into a generic RGB bitmap).
- (void)predrawRegion:(id)aRegion withDelegate:(id)aDelegate
{
    NSRect rect = [self HSGenericImageRenderLayer_imageRect];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMake(1, 0, 0, -1, 0, rect.origin.y * 2 + rect.size.height)] concat];
    NSColor *color = nil;
    NSImage *image = nil;
    BOOL removeColor = NO;
    if ([_transparentColorAttributes isTransparentColorEnabled]) {
        color = [_transparentColorAttributes transparentColor];
        if (color != nil) {
            image = [[[[_transparentColorAttributes hyperObject] queryHyperInterface:@protocol(HSTransparentColorCachedImageAttribute)] cachedImage] retain];
            removeColor = image == nil;
        }
    }
    if (image == nil) {
        if (_editableImageAttributes != nil) {
            Protocol *required[] = {@protocol(BTCocoaImage), nil};
            id bitmap = [_editableImageAttributes queryImageWithRequiredProtocols:required optionalProtocols:NULL];
            if (bitmap == nil)
                return;
            if (color == nil) {
                [bitmap drawInCurrentNSGraphicsContextInRect:rect];
                return;
            }
            // the original sends this class method to [NSImage alloc] (an
            // unrecognized selector, and a leak); sent to the class here
            image = [[NSImage BT_imageWithBTCocoaImage:bitmap] retain];
        } else {
            image = [[_imageAttributes image] retain];
            removeColor = color != nil && [_imageAttributes implementsHyperInterface:@protocol(HSCelMovieObjectAttributes)];
        }
    }
    if (image == nil)
        return;
    if (removeColor) {
        NSImage *cleared;
        if ([_imageAttributes implementsHyperInterface:@protocol(HSCelMovieObjectAttributes)]) {
            double lightness = [_transparentColorAttributes lightnessTolerance];
            double chroma = [_transparentColorAttributes chromaTolerance];
            double hue = [_transparentColorAttributes hueTolerance];
            cleared = HSGenericImageRenderLayerRemovingColorFromCelImage(image, color, hue, chroma, lightness);
        } else {
            cleared = HSGenericImageRenderLayerRemovingColorWithEffect(image, color);
        }
        // the original releases the image before retaining its replacement,
        // even when that's the same image
        if (cleared != nil && cleared != image) {
            [image release];
            image = [cleared retain];
        }
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSImageRep *rep = [image bestRepresentationForDevice:nil];
    if ([rep isKindOfClass:[NSBitmapImageRep class]] || ![rep isKindOfClass:[HSCoreGraphicsImageRep class]]) {
        NSInteger width = [rep pixelsWide], height = [rep pixelsHigh];
        size_t rowBytes = (width * 4 + 15) & ~(size_t)15;
        CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, rowBytes * height);
        if ([(id)data autorelease] != nil) {
            CFDataSetLength(data, rowBytes * height);
            CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            if (space != NULL) {
                CGContextRef context = CGBitmapContextCreate(CFDataGetMutableBytePtr(data), width, height, 8, rowBytes, space, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
                CGColorSpaceRelease(space);
                if (context != NULL) {
                    NSAutoreleasePool *drawPool = [[NSAutoreleasePool alloc] init];
                    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO];
                    if (graphicsContext != nil) {
                        [NSGraphicsContext saveGraphicsState];
                        [NSGraphicsContext setCurrentContext:graphicsContext];
                        [rep drawInRect:NSMakeRect(0, 0, width, height)];
                        [NSGraphicsContext restoreGraphicsState];
                    }
                    [drawPool release];
                    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
                    if (provider == NULL) {
                        CGContextRelease(context);
                    } else {
                        CGImageRef cgImage = CGEImageCreateAsBitmapContext(context, provider, NULL, true, kCGRenderingIntentDefault);
                        CGContextRelease(context);
                        CGDataProviderRelease(provider);
                        if (cgImage != NULL) {
                            HSCoreGraphicsImageRep *cgRep = [[HSCoreGraphicsImageRep alloc] initWithCoreGraphicsImage:cgImage];
                            CGImageRelease(cgImage);
                            if (cgRep != nil) {
                                [cgRep setSize:[rep size]];
                                [image removeRepresentation:rep];
                                [image addRepresentation:cgRep];
                                [cgRep release];
                                rep = cgRep;
                            }
                        }
                    }
                }
            }
        }
    }
    [rep drawInRect:rect];
    [pool release];
    [image release];
}
- (void)fillVisualizationAttributesSet:(id)aSet
{
    id object = [self hyperObject];
    [aSet addAttribute:@protocol(HSImageAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSImageRectAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorEnabledAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorHueToleranceAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorChromaToleranceAttribute) forObject:object];
    [aSet addAttribute:@protocol(HSTransparentColorLightnessToleranceAttribute) forObject:object];
}
- (CGSize)HSGenericImageRenderLayer_imageSize
{
    if (_editableImageAttributes != nil) {
        id bitmap = [_editableImageAttributes queryImageWithRequiredProtocols:NULL optionalProtocols:NULL];
        return bitmap != nil ? NSSizeToCGSize([bitmap imageSize]) : CGSizeZero;
    }
    NSImage *image = [_imageAttributes image];
    return image != nil ? NSSizeToCGSize([image size]) : CGSizeZero;
}
- (NSRect)HSGenericImageRenderLayer_imageRect
{
    id attributes = _editableImageAttributes != nil ? (id)_editableImageAttributes : (id)_imageAttributes;
    return [attributes imageRect];
}
- (void)dealloc
{
    [_imageAttributes release];
    [_editableImageAttributes release];
    [_transparentColorAttributes release];
    [super dealloc];
}
// Editable image attributes, or else plain ones; neither fails.
- (id)initWithHyperObject:(id)aObject cachingPolicy:(NSInteger)aPolicy
{
    self = [super initWithHyperObject:aObject cachingPolicy:aPolicy];
    if (self == nil)
        return nil;
    _transparentColorAttributes = [[aObject queryHyperInterface:@protocol(HSTransparentColorAttributes)] retain];
    _editableImageAttributes = [[aObject queryHyperInterface:@protocol(HSEditableImageAttributes)] retain];
    if (_editableImageAttributes == nil) {
        _imageAttributes = [[aObject queryHyperInterface:@protocol(HSImageAttributes)] retain];
        if (_imageAttributes == nil) {
            [self release];
            return nil;
        }
    }
    return self;
}
@end
