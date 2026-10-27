#import "HSSystemTextView+HSSystemTextViewVisualExtensions.h"
#import "CGEBitmapContext.h"
#import "SMKApplicationKitData.h"
#import "HSAttributeDictionaryReplacements.h"
#import "HSBackgroundCellRenderLayerInEditor.h"
#import "HSConcreteCardObjectData.h"
#import "HSGenericImageRenderLayer.h"
#import "HSGenericRenderDelegate.h"
#import "HSGenericVectorBrushRenderLayer.h"
#import "HSMutableRegion.h"
#import "HSPlaybackContext.h"
#import "HSPlayerCardView.h"
#import "HSSlideshowContext.h"
#import "HSVectorGraphicsObjectRenderLayer.h"
#import "HSVisualUserObject.h"
#import "NSAffineTransform+HSKeyValueCoding.h"

// Fill color of the shape masks used by the HTML5 exporter.
#define HSShapeImageFillColor() [NSColor colorWithDeviceRed:0.61f green:0.76f blue:0.91f alpha:1.0f]

@implementation HSSystemTextView (HSSystemTextViewVisualExtensions)

- (id)imageFromBackground
{
    NSColor *backgroundColor = [self backgroundColor];
    id<HSSizeAttributes> sizeAttributes = [self queryHyperInterface:@protocol(HSSizeAttributes)];
    NSSize textSize = [NSTextStorage hyperSizeForAttributedString:[self hyperText] withWidth:[sizeAttributes width] fixedWidth:NO];
    CGFloat height = [sizeAttributes height];
    NSRect bounds = [(id<HSGeometryAttributes>)[self queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect];
    NSRect textRect;
    textRect.origin = NSZeroPoint;
    textRect.size.width = textSize.width;
    textRect.size.height = MAX(height, textSize.height);
    NSRect rect = NSUnionRect(textRect, bounds);

    NSImage *image = [[NSImage alloc] initWithSize:rect.size];
    [image setFlipped:YES];
    [image lockFocus];
    [backgroundColor set];
    NSRectFill(rect);
    [image unlockFocus];
    return [image autorelease];
}

- (BOOL)needsToStoreBackgroundAsImage
{
    if ([self isTransparent])
        return NO;
    if ([[[self backgroundColor] colorSpaceName] isEqualToString:NSPatternColorSpace])
        return YES;

    // Relative float compare against 1.
    float alpha = [[self backgroundColor] alphaComponent];
    float magnitude = alpha != 0.0f ? fabsf(alpha) : 1.0f;
    return alpha < 1.0f - MAX(1.0f, magnitude) * 0.0005f;
}

@end

@implementation HSVectorBrushObject (HSUserObjectVisualExtensions)

- (Class)shapeRenderLayerClass
{
    return [HSGenericVectorBrushRenderLayer class];
}

@end

@implementation HSVectorGraphicsObject (HSUserObjectVisualExtensions)

- (Class)shapeRenderLayerClass
{
    return [HSVectorGraphicsObjectRenderLayer class];
}

@end

@implementation HSButtonObject (HSUserObjectVisualExtensions)

- (Class)shapeRenderLayerClass
{
    return [HSBackgroundCellRenderLayer class];
}

- (id)shapeImageWithSize:(NSSize)aSize
{
    BOOL systemBackground = [[self backgroundStyle] isEqualToString:@"HSButtonObjectSystemBackgroundStyle"];
    if (systemBackground) {
        id<HSButtonObjectSystemStyleBackgroundAttributes> systemAttributes = [self queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
        if (![[systemAttributes systemButtonType] isEqualToString:@"HSRectangleSystemButtonType"])
            return [super shapeImageWithSize:aSize];
    }

    id<HSGeometryAttributes> geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return nil;

    NSImage *image = [[[NSImage alloc] initWithSize:aSize] autorelease];
    if (image == nil)
        return nil;

    [image setFlipped:YES];
    [image lockFocus];
    [HSShapeImageFillColor() setFill];

    NSRect bounds = [geometry boundingRect];
    CGFloat flipHeight = (CGFloat)((double)bounds.origin.y * 2.0 + (double)bounds.size.height);
    CGAffineTransform transform = [self affineTransformIncludingShadowOffset];
    // Flip vertically around the bounding rect before applying the object transform.
    CGAffineTransform flipped;
    flipped.a = transform.a;
    flipped.b = transform.b;
    flipped.c = -transform.c;
    flipped.d = -transform.d;
    flipped.tx = transform.c * flipHeight + transform.tx;
    flipped.ty = transform.d * flipHeight + transform.ty;
    CGContextConcatCTM([[NSGraphicsContext currentContext] CGContext], flipped);

    if (systemBackground)
        NSRectFillUsingOperation(bounds, NSCompositingOperationSourceOver);
    else
        [[(id<HSBorderAttributes>)[self queryHyperInterface:@protocol(HSBorderAttributes)] borderPath] fill];

    [image unlockFocus];
    return image;
}

@end

@implementation HSImageObject (HSUserObjectVisualExtensions)

- (Class)shapeRenderLayerClass
{
    return [HSGenericImageRenderLayer class];
}

@end

@implementation HSStack (HSUserObjectVisualExtensionsPrivate)

- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol forExport:(BOOL)aExport
{
    return [[self posterCard] imageOfSize:aSize visualizationProtocol:aProtocol forExport:aExport];
}

- (id)HSUserObjectVisualExtensions_queryRendererForVisualizationProtocol:(id)aProtocol
{
    return [[[self posterCard] queryHyperInterface:aProtocol] queryRenderer];
}

- (NSSize)HSUserObjectVisualExtensions_size
{
    return [self hyperCardSize];
}

@end

@implementation HSCard (HSUserObjectVisualExtensionsPrivate)

- (id)imageOfSize:(NSSize)aSize forPresentationContext:(id)aContext
{
    if ([[aContext contextIdentifier] isEqual:[[HSPlaybackContext presentationContext] contextIdentifier]]
        || [[aContext contextIdentifier] isEqual:[[HSSlideshowContext presentationContext] contextIdentifier]])
        return [self imageForPlayerOfSize:aSize];
    return [self imageOfSize:aSize];
}

- (id)imageForPlayerOfSize:(NSSize)aSize
{
    NSRect frame;
    frame.origin = NSZeroPoint;
    frame.size = aSize;

    NSImage *image = [[NSImage alloc] initWithSize:aSize];
    HSPlayerCardView *cardView = [[HSPlayerCardView alloc] initWithFrame:frame ignoreCreateRootCanvasLayer:YES];
    [cardView setCard:self];
    [image setFlipped:YES];
    [image lockFocus];
    [cardView drawRect:frame];
    [image unlockFocus];
    [cardView setCard:nil];
    [cardView release];
    return [image autorelease];
}

- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol forExport:(BOOL)aExport withLiveVideo:(BOOL)aVideo
{
    if (aExport) {
        NSEnumerator *enumerator = [[self children] objectEnumerator];
        NSMutableArray *videoControllers = nil;
        NSMutableArray *webControllers = nil;
        id child;

        // Start every video and wait for web elements so the snapshot shows real content.
        _playedObjectsCount = 0;
        while ((child = [enumerator nextObject]) != nil) {
            if ([child implementsHyperInterface:@protocol(HSVideoStreamAttributes)]) {
                if (!aVideo && [child implementsHyperInterface:@protocol(HSLiveVideoAttributes)])
                    continue;
                id<HSPlayableObjectAttributes> playable = [child queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
                if (playable == nil || [playable isHyperPlaying])
                    continue;
                id controller = [playable attributeObservingController];
                [controller addObserver:self selector:@selector(playedObjectDidChangeVideoFrame:) ofChanges:2 ofAttribute:@protocol(HSVideoFrameAttribute) withPriority:-0.25];
                [playable hyperStart:self];
                if ([playable isHyperPlaying]) {
                    _playedObjectsCount++;
                    if (videoControllers == nil)
                        videoControllers = [NSMutableArray arrayWithObject:controller];
                    else
                        [videoControllers addObject:controller];
                } else {
                    [controller removeObserver:self selector:@selector(playedObjectDidChangeVideoFrame:) ofChanges:2 ofAttribute:@protocol(HSVideoFrameAttribute)];
                }
            } else {
                id<HSWebElementAttributes> webElement = [child queryHyperInterface:@protocol(HSWebElementAttributes)];
                if (webElement == nil || [webElement previewImage] != NULL)
                    continue;
                id controller = [webElement attributeObservingController];
                [controller addObserver:self selector:@selector(HSUserObject_HSUserObjectVisualExtensions_webElementDidLoad:) ofChanges:2 ofAttribute:@protocol(HSWebElementContentAttribute) withPriority:-0.25];
                _playedObjectsCount++;
                if (webControllers == nil)
                    webControllers = [NSMutableArray arrayWithObject:controller];
                else
                    [webControllers addObject:controller];
            }
        }

        NSDate *deadline = [NSDate dateWithTimeIntervalSinceNow:20.0];
        while (_playedObjectsCount > 0) {
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0.1];
            [[NSRunLoop currentRunLoop] runUntilDate:date];
            if ([date compare:deadline] == NSOrderedDescending)
                break;
        }
        _playedObjectsCount = 0;

        NSUInteger count = [videoControllers count];
        NSUInteger index;
        for (index = 0; index < count; index++)
            [[videoControllers objectAtIndex:index] removeObserver:self selector:@selector(playedObjectDidChangeVideoFrame:) ofChanges:2 ofAttribute:@protocol(HSVideoFrameAttribute)];
        count = [webControllers count];
        for (index = 0; index < count; index++)
            [[webControllers objectAtIndex:index] removeObserver:self selector:@selector(HSUserObject_HSUserObjectVisualExtensions_webElementDidLoad:) ofChanges:2 ofAttribute:@protocol(HSWebElementContentAttribute)];
    }
    return [super imageOfSize:aSize visualizationProtocol:aProtocol forExport:aExport];
}

- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol forExport:(BOOL)aExport
{
    return [self imageOfSize:aSize visualizationProtocol:aProtocol forExport:aExport withLiveVideo:YES];
}

- (NSRect)boundingRectUsingRenderer:(id)aRenderer
{
    NSRect rect;
    rect.origin = NSZeroPoint;
    rect.size = [(id<HSSizeAttributes>)[self queryHyperInterface:@protocol(HSSizeAttributes)] size];
    return rect;
}

- (void)HSUserObject_HSUserObjectVisualExtensions_webElementDidLoad:(id)aLoad
{
    _playedObjectsCount--;
}

- (void)playedObjectDidChangeVideoFrame:(id)aFrame
{
    id<HSPlayableObjectAttributes> playable = [[aFrame object] queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
    if (playable != nil) {
        [playable hyperStop];
        _playedObjectsCount--;
    }
}

- (NSSize)HSUserObjectVisualExtensions_size
{
    id<HSSizeAttributes> sizeAttributes = [self queryHyperInterface:@protocol(HSSizeAttributes)];
    if (sizeAttributes == nil)
        return NSZeroSize;
    return [sizeAttributes size];
}

@end

@implementation HSUserObject (HSUserObjectVisualExtensions)

- (id)shapeImageWithSize:(NSSize)aSize
{
    NSUndoManager *undoManager = [self undoManager];
    [undoManager disableUndoRegistration];
    id<HSMutableShadowAttributes> shadowAttributes = [self queryHyperInterface:@protocol(HSMutableShadowAttributes)];
    BOOL shadowEnabled = [shadowAttributes isHyperShadowEnabled];
    NSColor *shadowColor = [[[[shadowAttributes hyperShadow] shadowColor] retain] autorelease];
    NSImage *sourceImage;
    if (shadowEnabled) {
        // The mask must not include the shadow.
        [[shadowAttributes hyperShadow] setShadowColor:[NSColor clearColor]];
        sourceImage = [self imageForHTML5Export];
        [[shadowAttributes hyperShadow] setShadowColor:shadowColor];
    } else {
        sourceImage = [self imageForHTML5Export];
    }
    [undoManager enableUndoRegistration];

    size_t width = aSize.width > 0.0 ? lroundf(ceilf(aSize.width)) : 0;
    size_t height = aSize.height > 0.0 ? lroundf(ceilf(aSize.height)) : 0;
    NSRect rect;
    rect.origin = NSZeroPoint;
    rect.size = aSize;

    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGImageCompatibilityKey,
        nil];
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, (CFDictionaryRef)attributes, &pixelBuffer);
    if (pixelBuffer == NULL)
        return nil;

    NSImage *image = nil;
    CVBufferSetAttachment(pixelBuffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, [NSNumber numberWithInt:1], kCVAttachmentMode_ShouldNotPropagate);
    CGContextRef bitmap = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
    if (bitmap != NULL) {
        CGContextClearRect(bitmap, NSRectToCGRect(NSIntegralRect(rect)));
        NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithGraphicsPort:bitmap flipped:YES];
        if (context != nil) {
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:context];
            NSRect sourceRect;
            sourceRect.origin = NSZeroPoint;
            sourceRect.size = [sourceImage size];
            [sourceImage drawInRect:rect fromRect:sourceRect operation:NSCompositingOperationCopy fraction:1.0];

            CGImageRef mask = NULL;
            CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, CVPixelBufferGetBaseAddress(pixelBuffer), CVPixelBufferGetDataSize(pixelBuffer), NULL);
            if (provider != NULL) {
                CGFloat decode[2] = { 1.0, 0.0 };
                mask = CGImageMaskCreate(width, height, 8, 32, CVPixelBufferGetBytesPerRow(pixelBuffer), provider, decode, true);
                CGDataProviderRelease(provider);
            }
            // The original returned early on failure here without restoring the graphics state.
            [NSGraphicsContext restoreGraphicsState];

            if (mask != NULL) {
                image = [[NSImage alloc] initWithSize:aSize];
                [image lockFocus];
                [HSShapeImageFillColor() setFill];
                CGContextDrawImage([[NSGraphicsContext currentContext] CGContext], NSRectToCGRect(rect), mask);
                [image unlockFocus];
                CGImageRelease(mask);
            }
        }
        // The original leaked the bitmap context on the failure paths.
        CGContextRelease(bitmap);
    }
    CVPixelBufferRelease(pixelBuffer);
    return [image autorelease];
}

- (Class)shapeRenderLayerClass
{
    return Nil;
}

- (id)imageForHTML5Export
{
    NSUndoManager *undoManager = [self undoManager];
    [undoManager disableUndoRegistration];
    id<HSMutableCardObjectAttributes> cardObject = [self queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
    BOOL hiddenInPlayer = [cardObject isHiddenInPlayer];
    [cardObject setHiddenInPlayer:NO];

    id renderer = [[self queryHyperInterface:@protocol(HSPlayerVisualization)] queryRenderer];
    id region = [renderer boundingRegion];
    NSImage *image = nil;
    if (![region isEmpty]) {
        image = [[NSImage alloc] initWithSize:[self affineFrameBoundingRectIncludingShadow].size];
        [image setFlipped:YES];
        [image lockFocus];
        [[NSAffineTransform transformWithHyperCGAffineTransform:[self affineTransformIncludingShadowOffset]] concat];
        [renderer drawRegion:region withDelegate:[HSGenericRenderDelegate delegateWithDrawable:nil]];
        [image unlockFocus];
    }

    [cardObject setHiddenInPlayer:hiddenInPlayer];
    [undoManager enableUndoRegistration];
    return [image autorelease];
}

- (CGAffineTransform)affineTransformIncludingShadowOffset
{
    id<HSGeometryAttributes> geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    NSRect frame = [self affineFrameBoundingRectIncludingShadow];
    CGAffineTransform transform = [geometry affineTransform];
    transform.tx -= frame.origin.x;
    transform.ty -= frame.origin.y;
    return transform;
}

- (NSRect)affineFrameBoundingRectIncludingShadow
{
    NSUndoManager *undoManager = [self undoManager];
    [undoManager disableUndoRegistration];
    id<HSMutableCardObjectAttributes> cardObject = [self queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
    BOOL hiddenInPlayer = [cardObject isHiddenInPlayer];
    [cardObject setHiddenInPlayer:NO];

    id renderer = [[self queryHyperInterface:@protocol(HSPlayerVisualization)] queryRenderer];
    id<HSGeometryAttributes> geometry = [self queryHyperInterface:@protocol(HSGeometryAttributes)];
    HSMutableRegion *region = [[renderer boundingRegion] mutableCopy];
    region = [region applyAffineTransform:[geometry affineTransform]];
    NSRect rect = [region boundingRect];
    [region release];

    [cardObject setHiddenInPlayer:hiddenInPlayer];
    [undoManager enableUndoRegistration];
    return rect;
}

- (id)imageForIPadExport
{
    NSUndoManager *undoManager = [self undoManager];
    [undoManager disableUndoRegistration];
    CGFloat opacity = [(HSConcreteCardObjectData *)[self nodeData] opacity];
    [(HSConcreteCardObjectData *)[self nodeData] setOpacity:1.0];
    id<HSMutableCardObjectAttributes> cardObject = [self queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
    BOOL hiddenInPlayer = [cardObject isHiddenInPlayer];
    [cardObject setHiddenInPlayer:NO];
    BOOL shadowEnabled = [(id<HSMutableShadowAttributes>)[self queryHyperInterface:@protocol(HSMutableShadowAttributes)] isHyperShadowEnabled];
    if (shadowEnabled) {
        [(id)[self nodeData] setShadowEnabled:NO];
        [self notifyChange:2 ofAttribute:@protocol(HSShadowEnabledAttribute) withUserInfo:nil];
    }

    NSRect bounds = [self boundsForIPadExport];
    id renderer = [self HSUserObjectVisualExtensions_queryRendererForVisualizationProtocol:@protocol(HSVisualization)];
    NSImage *image = [[NSImage alloc] initWithSize:bounds.size];
    [image setFlipped:YES];
    [image lockFocus];
    [[NSAffineTransform transformWithHyperCGAffineTransform:CGAffineTransformMakeTranslation(-bounds.origin.x, -bounds.origin.y)] concat];
    [renderer drawRegion:[HSRegion regionWithRect:bounds] withDelegate:[HSGenericRenderDelegate delegateWithDrawable:nil]];
    [image unlockFocus];

    if (shadowEnabled) {
        [(id)[self nodeData] setShadowEnabled:shadowEnabled];
        [self notifyChange:2 ofAttribute:@protocol(HSShadowEnabledAttribute) withUserInfo:nil];
    }
    [cardObject setHiddenInPlayer:hiddenInPlayer];
    [(HSConcreteCardObjectData *)[self nodeData] setOpacity:opacity];
    [undoManager enableUndoRegistration];
    return [image autorelease];
}

- (NSRect)boundsForIPadExport
{
    NSUndoManager *undoManager = [self undoManager];
    [undoManager disableUndoRegistration];
    CGFloat opacity = [(HSConcreteCardObjectData *)[self nodeData] opacity];
    [(HSConcreteCardObjectData *)[self nodeData] setOpacity:1.0];
    id<HSMutableCardObjectAttributes> cardObject = [self queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
    BOOL hiddenInPlayer = [cardObject isHiddenInPlayer];
    [cardObject setHiddenInPlayer:NO];

    NSRect rect;
    BOOL shadowEnabled = [(id<HSMutableShadowAttributes>)[self queryHyperInterface:@protocol(HSMutableShadowAttributes)] isHyperShadowEnabled];
    if (shadowEnabled) {
        [(id)[self nodeData] setShadowEnabled:NO];
        [self notifyChange:2 ofAttribute:@protocol(HSShadowEnabledAttribute) withUserInfo:nil];
        rect = [[[self HSUserObjectVisualExtensions_queryRendererForVisualizationProtocol:@protocol(HSVisualization)] boundingRegion] boundingRect];
        [(id)[self nodeData] setShadowEnabled:shadowEnabled];
        [self notifyChange:2 ofAttribute:@protocol(HSShadowEnabledAttribute) withUserInfo:nil];
    } else {
        rect = [[[self HSUserObjectVisualExtensions_queryRendererForVisualizationProtocol:@protocol(HSVisualization)] boundingRegion] boundingRect];
    }

    [cardObject setHiddenInPlayer:hiddenInPlayer];
    [(HSConcreteCardObjectData *)[self nodeData] setOpacity:opacity];
    [undoManager enableUndoRegistration];
    return rect;
}

- (id)imageForExportOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol
{
    return [self imageOfSize:aSize visualizationProtocol:aProtocol forExport:YES];
}

- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol
{
    return [self imageOfSize:aSize visualizationProtocol:aProtocol forExport:NO];
}

- (id)imageOfSize:(NSSize)aSize visualizationProtocol:(id)aProtocol forExport:(BOOL)aExport
{
    if (aProtocol == nil)
        return nil;

    NSRect rect;
    rect.origin = NSZeroPoint;
    rect.size = aSize;
    id renderer = [self HSUserObjectVisualExtensions_queryRendererForVisualizationProtocol:aProtocol];
    NSRect bounds = [self boundingRectUsingRenderer:renderer];
    if (NSIsEmptyRect(rect))
        rect = bounds;
    NSRect integralRect = NSIntegralRect(rect);

    NSImage *image = [[NSImage alloc] initWithSize:integralRect.size];
    [image setFlipped:YES];
    [image lockFocus];
    // Scale the renderer bounds into the requested size; the offset uses the
    // requested rect's origin, which is only non-zero when it fell back to the bounds.
    CGFloat scaleX = rect.size.width / bounds.size.width;
    CGFloat scaleY = rect.size.height / bounds.size.height;
    CGAffineTransform transform;
    transform.a = scaleX;
    transform.b = scaleY * 0.0f;
    transform.c = scaleX * 0.0f;
    transform.d = scaleY;
    transform.tx = -rect.origin.x * scaleX;
    transform.ty = -rect.origin.y * scaleY;
    [[NSAffineTransform transformWithHyperCGAffineTransform:transform] concat];
    [renderer drawRegion:[HSRegion regionWithRect:bounds] withDelegate:[HSGenericRenderDelegate delegateWithDrawable:nil]];
    [image unlockFocus];
    return [image autorelease];
}

- (NSRect)boundingRectUsingRenderer:(id)aRenderer
{
    return [[aRenderer boundingRegion] boundingRect];
}

- (id)imageWithVisualizationProtocol:(id)aProtocol
{
    return [self imageOfSize:NSZeroSize visualizationProtocol:aProtocol];
}

- (id)imageOfSize:(NSSize)aSize forPresentationContext:(id)aContext
{
    return [self imageOfSize:aSize];
}

- (id)imageForPresentationContext:(id)aContext
{
    return [self imageOfSize:[self HSUserObjectVisualExtensions_size] forPresentationContext:aContext];
}

- (id)HSUserObjectVisualExtensions_queryRendererForVisualizationProtocol:(id)aProtocol
{
    return [[self queryHyperInterface:aProtocol] queryRenderer];
}

- (NSSize)HSUserObjectVisualExtensions_size
{
    return [(id<HSGeometryAttributes>)[self queryHyperInterface:@protocol(HSGeometryAttributes)] affineFrameSize];
}

- (id)previewForHTML5Export
{
    return [(HSCard *)self imageOfSize:[self HSUserObjectVisualExtensions_size] visualizationProtocol:@protocol(HSVisualization) forExport:YES withLiveVideo:NO];
}

- (id)imageForExport
{
    return [self imageForExportOfSize:[self HSUserObjectVisualExtensions_size]];
}

- (id)image
{
    return [self imageOfSize:[self HSUserObjectVisualExtensions_size]];
}

- (id)imageForExportOfSize:(NSSize)aSize
{
    return [self imageForExportOfSize:aSize visualizationProtocol:@protocol(HSVisualization)];
}

- (id)imageOfSize:(NSSize)aSize
{
    return [self imageOfSize:aSize visualizationProtocol:@protocol(HSVisualization)];
}

@end
