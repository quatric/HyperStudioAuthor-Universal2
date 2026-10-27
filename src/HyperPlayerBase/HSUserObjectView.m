#import "HSUserObjectView.h"
#import "CGEBitmapContext.h"
#import "CGEImage.h"
#import "CVEPixelBuffer.h"
#import "__NSEWeakObjectProxy.h"
#import "HSFunctions.h"
#import "HSMutableRegion.h"
#import "HSRendererStreamDrawable.h"
#import "HSGenericRenderDelegate.h"
#import "HSGenericRenderCacheController.h"
#import "HSAnimation.h"
#import "HSAnimationController.h"
#import "HSSystem.h"

// The attachment caching the CGImage of a frame.
static NSString * const HSPixelBufferCGImageAttachment = @"HSPixelBufferCGImage";

static NSUInteger HSUserObjectViewPixelCount(CGFloat aLength)
{
    return aLength > 0 ? (NSUInteger)lroundf(ceilf(aLength)) : 0;
}

static void HSUserObjectViewReleaseFrame(CVPixelBufferRef *aFrame)
{
    if (*aFrame) {
        CVBufferRemoveAttachment(*aFrame, (CFStringRef)HSPixelBufferCGImageAttachment);
        CVPixelBufferRelease(*aFrame);
    }
    *aFrame = NULL;
}

// Draws a user object's visualization through renderers split in two layers:
// the view layer, and a window layer floating over it while a child is
// interacted with as a real view (the children above it go to the window
// layer). Runs of "don't erase" children get their own renderers drawn
// through stream drawables, so their previous frames stay on screen.
// Capturing consumers receive every frame as a pixel buffer.
@implementation HSUserObjectView

+ (id)visualizationProtocol
{
    return @protocol(HSVisualization);
}

// The card drawn offscreen without its hidden objects (or without any of them
// when the stack hides card objects).
- (struct CGImage *)getCardImageForCard:(id)aCard
{
    if (!aCard)
        return NULL;
    NSRect bounds = [self contentBoundingRect];
    HSMutableRegion *region = [HSMutableRegion regionWithRect:bounds];
    [region applyAffineTransform:[self viewSpaceToUserSpaceCGAffineTransform]];
    HSRendererStreamDrawable *drawable = [[HSRendererStreamDrawable alloc] initWithWidth:(NSUInteger)bounds.size.width height:(NSUInteger)bounds.size.height];
    // As in the original, the flip replaces the translation set first.
    [drawable setRendererTransform:CGAffineTransformMakeTranslation(-bounds.origin.x, -bounds.origin.y)];
    [drawable setRendererTransform:CGAffineTransformMake(1, 0, 0, -1, 0, bounds.size.height)];
    NSSet *ignored = [NSSet set];
    NSInteger visibility = (NSInteger)[[aCard stack] cardObjectsVisibility];
    if (visibility == 1) {
        ignored = [NSSet setWithArray:[aCard hyperChildren]];
    } else if (visibility == 2) {
        NSMutableSet *hidden = [NSMutableSet set];
        for (id child in [aCard hyperChildren]) {
            if ([(id<HSCardObjectAttributes>)[child queryHyperInterface:@protocol(HSCardObjectAttributes)] isHidden])
                [hidden addObject:child];
        }
        ignored = hidden;
    }
    id visualization = [aCard queryHyperInterface:[[self class] visualizationProtocol]];
    [drawable setRenderer:[visualization queryRendererWithVisualizationOptions:[NSDictionary dictionaryWithObject:ignored forKey:@"HSIgnoredSubobjectsVisualizationOption"]]];
    CGImageRef image = NULL;
    CVPixelBufferRef pixelBuffer = [self HSUserObjectView_pixelBufferForStreamDrawable:drawable updateRegion:region];
    if (pixelBuffer) {
        image = (CGImageRef)CVBufferGetAttachment(pixelBuffer, (CFStringRef)HSPixelBufferCGImageAttachment, NULL);
        if (!image) {
            image = CGEImageCreateWithPixelBuffer(pixelBuffer, kCVPixelBufferLock_ReadOnly, NULL, false, kCGRenderingIntentDefault);
            if (image) {
                CVBufferSetAttachment(pixelBuffer, (CFStringRef)HSPixelBufferCGImageAttachment, image, kCVAttachmentMode_ShouldNotPropagate);
                CGImageRelease(image);
            }
        }
    }
    // The image only lived as an attachment of the drawable's buffer, so the
    // original returned it freed along with the drawable.
    if (image)
        CFAutorelease(CGImageRetain(image));
    [drawable release];
    return image;
}

// Sends the consumers the view layer frame, mixed with the window contents
// while a subview renders interactively, and with the window layer frame.
- (void)HSUserObjectView_finalizeUpdate
{
    if (!_currentViewRendererFrame) {
        NSArray *renderers = [self HSUserObjectView_viewLayerUserObjectRenderers];
        if (renderers)
            _currentViewRendererFrame = [self HSUserObjectView_drawRenderers:renderers inRect:[self userObjectBounds] createPixeBuffer:YES needsToDrawPixelBuffer:NO];
    }
    if (!_currentWindowRendererFrame) {
        NSArray *renderers = [self HSUserObjectView_windowLayerUserObjectRenderers];
        if (renderers)
            _currentWindowRendererFrame = [self HSUserObjectView_drawRenderers:renderers inRect:[self userObjectBounds] createPixeBuffer:YES needsToDrawPixelBuffer:NO];
    }
    CVPixelBufferRef viewFrame = CVPixelBufferRetain(_currentViewRendererFrame);
    if ([self isRenderInteractiveSubview]) {
        CVPixelBufferRelease(viewFrame);
        viewFrame = [self HSUserObjectView_createMixedFrameWithPixelBuffer:_currentViewRendererFrame andPixelBuffer:[self HSUserObjectView_windowBufferPixelBuffer] atPoint:NSZeroPoint];
    }
    CVPixelBufferRef frame = CVPixelBufferRetain(viewFrame);
    if (_currentWindowRendererFrame) {
        CVPixelBufferRelease(frame);
        frame = [self HSUserObjectView_createMixedFrameWithPixelBuffer:viewFrame andPixelBuffer:_currentWindowRendererFrame atPoint:NSZeroPoint];
    }
    [self HSUserObjectView_sendFrame:frame atTime:_currentViewRendererFrameTime];
    CVPixelBufferRelease(viewFrame);
    CVPixelBufferRelease(frame);
}

// The last consumer gone, the frames and stream drawables are dropped.
- (void)stopCapturingForConsumer:(id)aConsumer
{
    if (!_activeConsumers)
        return;
    NSUInteger count = (NSUInteger)CFDictionaryGetValue(_activeConsumers, aConsumer);
    if (count == 0)
        return;
    if (count != 1) {
        CFDictionarySetValue(_activeConsumers, aConsumer, (const void *)(count - 1));
        return;
    }
    CFDictionaryRemoveValue(_activeConsumers, aConsumer);
    if (CFDictionaryGetCount(_activeConsumers) != 0)
        return;
    HSUserObjectViewReleaseFrame(&_currentViewRendererFrame);
    HSUserObjectViewReleaseFrame(&_currentWindowRendererFrame);
    [self HSUserObjectView_invalidatePixelBufferOfViewFromWindowBuffer];
    if (_streamDrawableByRenderer) {
        NSFreeMapTable(_streamDrawableByRenderer);
        _streamDrawableByRenderer = nil;
    }
    if (_streamDrawableByObjects) {
        NSFreeMapTable(_streamDrawableByObjects);
        _streamDrawableByObjects = nil;
    }
}

// A new consumer gets the current frame right away.
- (void)startCapturingForConsumer:(id)aConsumer
{
    if (!_activeConsumers) {
        _activeConsumers = CFDictionaryCreateMutable(NULL, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (!_activeConsumers)
            return;
    }
    NSUInteger count = (NSUInteger)CFDictionaryGetValue(_activeConsumers, aConsumer);
    CFDictionarySetValue(_activeConsumers, aConsumer, (const void *)(count + 1));
    _currentViewRendererFrameTime = [NSDate timeIntervalSinceReferenceDate];
    [self HSUserObjectView_finalizeUpdate];
}

- (BOOL)renderDelegate:(id)aDelegate willQueryRenderCacheForRegion:(id)aRegion ofRenderLayerAtIndexPath:(id)aPath inRenderer:(id)aRenderer withOptions:(int *)aOptions acceptableValidnessLimit:(float *)aLimit
{
    *aLimit = 1.0f - (float)[self acceptableDrawingQualityLoss];
    return YES;
}

- (void)declineDrawingQualityLoss:(CGFloat)aLoss
{
    [super declineDrawingQualityLoss:aLoss];
    [(HSGenericRenderCacheController *)[_renderDelegate renderCacheController] releaseWithStorableValidnessLimit:1.0 - aLoss];
}

- (void)acceptDrawingQualityLoss:(CGFloat)aLoss
{
    [(HSGenericRenderCacheController *)[self HSUserObjectView_renderCacheController] retainWithStorableValidnessLimit:1.0 - aLoss];
    [super acceptDrawingQualityLoss:aLoss];
}

- (void)interactiveSubviewDidUpdate
{
    if (_renderInteractiveSubviewCounter == 0 || ![self HSUserObjectView_hasConsumers])
        return;
    if (_currentViewRendererFrameTime == 0)
        _currentViewRendererFrameTime = [NSDate timeIntervalSinceReferenceDate];
    [self HSUserObjectView_invalidatePixelBufferOfViewFromWindowBuffer];
    [self HSUserObjectView_cancelUpdate];
    [self HSUserObjectView_finalizeUpdate];
}

- (BOOL)isRenderInteractiveSubview
{
    return _renderInteractiveSubviewCounter != 0;
}

- (void)stopRenderInteractiveSubview
{
    if (_renderInteractiveSubviewCounter != 0)
        _renderInteractiveSubviewCounter--;
}

- (void)beginRenderInteractiveSubview
{
    _renderInteractiveSubviewCounter++;
}

- (void)endViewBasedInteractionForNodeChild:(id)aChild
{
    [[self window] disableScreenUpdatesUntilFlush];
    [self removeWindowLayer:_windowLayer];
    [_windowLayer release];
    _windowLayer = nil;
    [self unignoreChild:aChild];
    [_interactiveChild release];
    _interactiveChild = nil;
    [self setNeedsDisplayOpenGLSurface:YES];
}

// The children above the interacted one move to a window layer.
- (void)beginViewBasedInteractionForNodeChild:(id)aChild
{
    _interactiveChild = [aChild retain];
    [self ignoreChild:aChild];
    [[self window] disableScreenUpdatesUntilFlush];
    _isWaitingForInteractiveSubview = YES;
    _windowLayer = [[self addWindowLayerWithDrawingSelector:@selector(HSUserObjectView_drawWindowLayerRect:)] retain];
    _isWaitingForInteractiveSubview = NO;
    [self setNeedsDisplayOpenGLSurface:YES];
}

- (void)drawQuartzRect:(NSRect)aRect
{
    [self preDrawContentRect:aRect];
    [NSGraphicsContext saveGraphicsState];
    [self drawViewLayerContentRect:aRect];
    [NSGraphicsContext restoreGraphicsState];
    if (!_windowLayer)
        [self postDrawContentRect:aRect];
}

- (void)postDrawContentRect:(NSRect)aRect
{
}

- (void)HSUserObjectView_drawWindowLayerRect:(NSRect)aRect
{
    [NSGraphicsContext saveGraphicsState];
    [self drawWindowLayerContentRect:aRect];
    [NSGraphicsContext restoreGraphicsState];
    if (!_isWaitingForInteractiveSubview && _currentViewRendererFrameTime == 0 && [self HSUserObjectView_hasConsumers]) {
        _currentViewRendererFrameTime = [NSDate timeIntervalSinceReferenceDate];
        [self HSUserObjectView_finalizeUpdate];
    }
    [self postDrawContentRect:aRect];
}

- (void)drawWindowLayerContentRect:(NSRect)aRect
{
    BOOL hasConsumers = [self HSUserObjectView_hasConsumers];
    NSArray *renderers = [self HSUserObjectView_windowLayerUserObjectRenderers];
    CVPixelBufferRef frame = [self HSUserObjectView_drawRenderers:renderers inRect:aRect createPixeBuffer:hasConsumers needsToDrawPixelBuffer:YES];
    if (hasConsumers) {
        HSUserObjectViewReleaseFrame(&_currentWindowRendererFrame);
        _currentWindowRendererFrame = frame;
    }
    [_previousWindowLayerUserObjectRenderers release];
    _previousWindowLayerUserObjectRenderers = nil;
}

// A copy of the first buffer with the second drawn over it at the point.
- (struct __CVBuffer *)HSUserObjectView_createMixedFrameWithPixelBuffer:(struct __CVBuffer *)aBuffer andPixelBuffer:(struct __CVBuffer *)aBuffer2 atPoint:(NSPoint)aPoint
{
    if (!aBuffer || !aBuffer2)
        return NULL;
    CGImageRef image = CGEImageCreateWithPixelBuffer(aBuffer2, kCVPixelBufferLock_ReadOnly, NULL, false, kCGRenderingIntentDefault);
    if (!image)
        return NULL;
    CVPixelBufferRef mixed = NULL;
    if (CVPixelBufferPoolCreatePixelBuffer(NULL, [self HSUserObjectView_pixelBufferPool], &mixed) == kCVReturnSuccess
        && CVPixelBufferLockBaseAddress(mixed, 0) == kCVReturnSuccess) {
        if (CVPixelBufferLockBaseAddress(aBuffer, 0) == kCVReturnSuccess) {
            memmove(CVPixelBufferGetBaseAddress(mixed), CVPixelBufferGetBaseAddress(aBuffer), CVPixelBufferGetDataSize(aBuffer));
            CVPixelBufferUnlockBaseAddress(aBuffer, 0);
            CVPixelBufferUnlockBaseAddress(mixed, 0);
            CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(mixed, 0);
            if (context) {
                CGContextDrawImage(context, CGRectMake(aPoint.x, aPoint.y, CGImageGetWidth(image), CGImageGetHeight(image)), image);
                CGContextRelease(context);
            }
        } else {
            CVPixelBufferUnlockBaseAddress(mixed, 0);
            // The original returned the buffer uncopied here.
            CVPixelBufferRelease(mixed);
            mixed = NULL;
        }
    } else if (mixed) {
        // The original leaked the buffer when it could not be locked.
        CVPixelBufferRelease(mixed);
        mixed = NULL;
    }
    CGImageRelease(image);
    return mixed;
}

- (id)HSUserObjectView_rendererStreamDrawable:(id)aDrawable
{
    NSRect bounds = [self contentBoundingRect];
    HSRendererStreamDrawable *drawable = [[HSRendererStreamDrawable alloc] initWithWidth:(NSUInteger)bounds.size.width height:(NSUInteger)bounds.size.height];
    // As in the original, the flip replaces the translation set first.
    [drawable setRendererTransform:CGAffineTransformMakeTranslation(-bounds.origin.x, -bounds.origin.y)];
    [drawable setRendererTransform:CGAffineTransformMake(1, 0, 0, -1, 0, bounds.size.height)];
    [drawable setRenderer:aDrawable];
    [drawable setRenderDelegate:[self renderDelegate]];
    [drawable setAutoInvalidates:NO];
    return [drawable autorelease];
}

// The consumers get the new frame once drawn; it waits for the next turn of
// the run loop while a subview renders interactively.
- (void)drawViewLayerContentRect:(NSRect)aRect
{
    BOOL hasConsumers = [self HSUserObjectView_hasConsumers];
    NSArray *renderers = [self HSUserObjectView_viewLayerUserObjectRenderers];
    CVPixelBufferRef frame = [self HSUserObjectView_drawRenderers:renderers inRect:aRect createPixeBuffer:hasConsumers needsToDrawPixelBuffer:YES];
    if (hasConsumers) {
        HSUserObjectViewReleaseFrame(&_currentViewRendererFrame);
        _currentViewRendererFrame = frame;
    }
    if ([self HSUserObjectView_hasConsumers] && _currentViewRendererFrameTime == 0) {
        _currentViewRendererFrameTime = [NSDate timeIntervalSinceReferenceDate];
        if ([self isRenderInteractiveSubview])
            [self HSUserObjectView_updateAfterDelay];
        else
            [self HSUserObjectView_finalizeUpdate];
    }
    [_previousViewLayerUserObjectRenderers release];
    _previousViewLayerUserObjectRenderers = nil;
}

// Renderers without a stream drawable draw straight into the current context.
// The others' buffers are drawn (clipped to their changed rects), or when a
// pixel buffer is wanted, composed into a new one carrying the union of the
// changed rects, and drawn when asked.
- (struct __CVBuffer *)HSUserObjectView_drawRenderers:(id)aRenderers inRect:(NSRect)aRect createPixeBuffer:(BOOL)aBuffer needsToDrawPixelBuffer:(BOOL)aBuffer2
{
    CVPixelBufferRef pixelBuffer = NULL;
    NSUInteger count = [aRenderers count];
    if (count == 0)
        return NULL;
    if (aBuffer2)
        [(NSAffineTransform *)[self userSpaceToViewSpaceTransform] concat];
    HSMutableRegion *region = [HSMutableRegion regionWithRect:aRect];
    [region applyAffineTransform:[self viewSpaceToUserSpaceCGAffineTransform]];
    CFStringRef changedRegionKey = (CFStringRef)kCVEImageBufferChangedRegionKey;
    CFMutableDataRef changedRects = NULL;
    BOOL succeeded = NO;
    for (NSUInteger index = 0; index < count; index++) {
        id renderer = [aRenderers objectAtIndex:index];
        id drawable = _streamDrawableByRenderer ? NSMapGet(_streamDrawableByRenderer, renderer) : nil;
        if (!drawable && aBuffer) {
            NSMapTable *drawables = [self HSUserObjectView_streamDrawableByRendererCreateIfNeeded:YES];
            drawable = [self HSUserObjectView_rendererStreamDrawable:renderer];
            NSMapInsertKnownAbsent(drawables, renderer, drawable);
        }
        if (!drawable) {
            if (aBuffer2)
                [renderer drawRegion:region withDelegate:[self renderDelegate]];
            succeeded = YES;
            continue;
        }
        CVPixelBufferRef rendererBuffer = [self HSUserObjectView_pixelBufferForStreamDrawable:drawable updateRegion:region];
        if (!rendererBuffer) {
            succeeded = NO;
            break;
        }
        CFDataRef changed = (CFDataRef)CVBufferGetAttachment(rendererBuffer, changedRegionKey, NULL);
        if (aBuffer2 || aBuffer) {
            CGImageRef image = NULL;
            CGRect wholeRect = CGRectZero;
            const CGRect *rects = NULL;
            size_t rectCount = 0;
            // The first buffer composed is copied as is.
            if (!aBuffer || pixelBuffer) {
                image = CGEImageCreateWithPixelBuffer(rendererBuffer, kCVPixelBufferLock_ReadOnly, NULL, false, kCGRenderingIntentDefault);
                if (!image) {
                    succeeded = NO;
                    break;
                }
                if (changed && (rectCount = (size_t)CFDataGetLength(changed) / sizeof(CGRect)) != 0) {
                    rects = (const CGRect *)CFDataGetBytePtr(changed);
                } else {
                    wholeRect = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
                    rects = &wholeRect;
                    rectCount = 1;
                }
            }
            if (!aBuffer) {
                CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
                if (!context) {
                    CGImageRelease(image);
                    succeeded = NO;
                    break;
                }
                CGRect imageRect = CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
                CGContextSaveGState(context);
                CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, imageRect.size.height));
                if (!CGRectEqualToRect(imageRect, rects[0]))
                    CGContextClipToRects(context, rects, rectCount);
                CGContextDrawImage(context, imageRect, image);
                CGContextRestoreGState(context);
            } else if (!pixelBuffer) {
                CVPixelBufferPoolCreatePixelBuffer(NULL, [self HSUserObjectView_pixelBufferPool], &pixelBuffer);
                if (!pixelBuffer) {
                    succeeded = NO;
                    break;
                }
                BOOL locked = CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess;
                if (locked && CVPixelBufferLockBaseAddress(rendererBuffer, kCVPixelBufferLock_ReadOnly) != kCVReturnSuccess) {
                    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                    locked = NO;
                }
                if (!locked) {
                    CVPixelBufferRelease(pixelBuffer);
                    pixelBuffer = NULL;
                    succeeded = NO;
                    break;
                }
                memcpy(CVPixelBufferGetBaseAddress(pixelBuffer), CVPixelBufferGetBaseAddress(rendererBuffer), CVEPixelBufferGetDataSize(rendererBuffer));
                CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                CVPixelBufferUnlockBaseAddress(rendererBuffer, kCVPixelBufferLock_ReadOnly);
            } else {
                CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
                if (!context) {
                    CGImageRelease(image);
                    succeeded = NO;
                    break;
                }
                CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
                CGContextRelease(context);
            }
            if (image)
                CGImageRelease(image);
        }
        if (aBuffer && changed && CFDataGetLength(changed) > 0) {
            if (!changedRects)
                changedRects = CFDataCreateMutable(NULL, 0);
            CFDataAppendBytes(changedRects, CFDataGetBytePtr(changed), CFDataGetLength(changed));
        }
        succeeded = YES;
    }
    if (pixelBuffer) {
        if (succeeded) {
            if (changedRects)
                CVBufferSetAttachment(pixelBuffer, changedRegionKey, changedRects, kCVAttachmentMode_ShouldNotPropagate);
            CGImageRef image;
            if (aBuffer2 && (image = CGEImageCreateWithPixelBuffer(pixelBuffer, kCVPixelBufferLock_ReadOnly, NULL, false, kCGRenderingIntentDefault))) {
                CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
                CGContextSaveGState(context);
                CGFloat height = CGImageGetHeight(image);
                CGContextConcatCTM(context, CGAffineTransformMake(1, 0, 0, -1, 0, height));
                CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), height), image);
                CGContextRestoreGState(context);
                CGImageRelease(image);
            }
        } else {
            CVBufferRemoveAttachment(pixelBuffer, changedRegionKey);
            CVPixelBufferRelease(pixelBuffer);
            pixelBuffer = NULL;
        }
    }
    if (changedRects)
        CFRelease(changedRects);
    return pixelBuffer;
}

// Consumers with a count of zero (being removed) are skipped.
- (void)HSUserObjectView_sendFrame:(struct __CVBuffer *)aFrame atTime:(double)aTime
{
    CFIndex count = CFDictionaryGetCount(_activeConsumers);
    if (count == 1) {
        const void *consumer = NULL;
        CFDictionaryGetKeysAndValues(_activeConsumers, &consumer, NULL);
        [(id)consumer capturingDataSource:self didOutputFrame:aFrame atTime:aTime];
    } else if (count != 0) {
        const void **consumers = malloc(count * sizeof(void *));
        if (consumers) {
            CFDictionaryGetKeysAndValues(_activeConsumers, consumers, NULL);
            for (; count != 0; count--) {
                if (CFDictionaryGetValue(_activeConsumers, consumers[count - 1]))
                    [(id)consumers[count - 1] capturingDataSource:self didOutputFrame:aFrame atTime:aTime];
            }
            free(consumers);
        }
    }
    _currentViewRendererFrameTime = 0;
}

- (void)HSUserObjectView_invalidatePixelBufferOfViewFromWindowBuffer
{
    if (_currentWindowBufferFrame)
        HSUserObjectViewReleaseFrame(&_currentWindowBufferFrame);
}

// What the window shows of the scroll view's visible part, placed relative to
// the user object.
- (struct __CVBuffer *)HSUserObjectView_windowBufferPixelBuffer
{
    if (_currentWindowBufferFrame)
        return _currentWindowBufferFrame;
    NSWindow *window = [self window];
    NSRect objectRect = NSIntegralRect([self convertRect:[self viewBoundingRectForUserRect:[self userObjectBounds]] toView:nil]);
    NSRect visibleRect = NSIntegralRect([self convertRect:[[self enclosingScrollView] documentVisibleRect] toView:nil]);
    NSPoint point = NSMakePoint(visibleRect.origin.x - objectRect.origin.x, visibleRect.origin.y - objectRect.origin.y);
    // NSCachedImageRep reads the window's backing store, as in the original.
    NSCachedImageRep *windowImage = [[[NSCachedImageRep alloc] initWithWindow:window rect:visibleRect] autorelease];
    if (!windowImage)
        return _currentWindowBufferFrame;
    CVPixelBufferPoolRef pool = [self HSUserObjectView_pixelBufferPool];
    if (!pool)
        return _currentWindowBufferFrame;
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &_currentWindowBufferFrame);
    if (!_currentWindowBufferFrame)
        return NULL;
    CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(_currentWindowBufferFrame, 0);
    if (!context) {
        CVPixelBufferRelease(_currentWindowBufferFrame);
        _currentWindowBufferFrame = NULL;
        return NULL;
    }
    memset(CGBitmapContextGetData(context), 0, CGBitmapContextGetBytesPerRow(context) * CGBitmapContextGetHeight(context));
    NSAutoreleasePool *autoreleasePool = [NSAutoreleasePool new];
    NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:YES];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:graphicsContext];
    [windowImage drawAtPoint:point];
    [NSGraphicsContext restoreGraphicsState];
    [autoreleasePool release];
    CGContextRelease(context);
    return _currentWindowBufferFrame;
}

// One pool of BGRA buffers of the user object's size, remade when it changes.
- (struct __CVPixelBufferPool *)HSUserObjectView_pixelBufferPool
{
    NSRect bounds = [self userObjectBounds];
    NSUInteger width = HSUserObjectViewPixelCount(bounds.size.width);
    NSUInteger height = HSUserObjectViewPixelCount(bounds.size.height);
    if (_mixedFramesPool) {
        NSDictionary *attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_mixedFramesPool);
        NSNumber *poolWidth = [attributes objectForKey:(id)kCVPixelBufferWidthKey];
        NSNumber *poolHeight = [attributes objectForKey:(id)kCVPixelBufferHeightKey];
        if (!poolWidth || !poolHeight)
            return _mixedFramesPool;
        if (NSEqualSizes(NSMakeSize(width, height), NSMakeSize([poolWidth unsignedIntValue], [poolHeight unsignedIntValue])))
            return _mixedFramesPool;
        CVPixelBufferPoolRelease(_mixedFramesPool);
        _mixedFramesPool = NULL;
    }
    CFDictionaryRef attributes = [self HSUserObjectView_pixelBufferAttributesWithBufferWidth:width height:height pixelFormat:kCVPixelFormatType_32BGRA];
    if (attributes)
        CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, attributes, &_mixedFramesPool);
    return _mixedFramesPool;
}

- (struct __CFDictionary *)HSUserObjectView_pixelBufferAttributesWithBufferWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight pixelFormat:(NSUInteger)aFormat
{
    NSDictionary *nonPropagated = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], (id)kCVEPixelBufferAlphaInfoKey, nil];
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSNumber numberWithUnsignedLong:aWidth], (id)kCVPixelBufferWidthKey,
        [NSNumber numberWithUnsignedLong:aHeight], (id)kCVPixelBufferHeightKey,
        [NSNumber numberWithUnsignedInt:(unsigned int)aFormat], (id)kCVPixelBufferPixelFormatTypeKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGImageCompatibilityKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferOpenGLCompatibilityKey,
        nonPropagated, (id)kCVBufferNonPropagatedAttachmentsKey, nil];
    return (CFMutableDictionaryRef)[attributes autorelease];
}

// The drawable redraws the region (in its own space) before handing its buffer.
- (struct __CVBuffer *)HSUserObjectView_pixelBufferForStreamDrawable:(id)aDrawable updateRegion:(id)aRegion
{
    if (aRegion) {
        HSMutableRegion *region = [aRegion mutableCopy];
        [region applyAffineTransform:[(HSRendererStreamDrawable *)aDrawable rendererTransform]];
        [(HSStreamDrawable *)aDrawable invalidateInRect:[region boundingRect]];
        [region release];
    }
    [(HSStreamDrawable *)aDrawable setColorProfile:[self colorSyncProfile] colorSpace:[self colorSpace]];
    return [(HSStreamDrawable *)aDrawable pixelBuffer];
}

- (void)preDrawContentRect:(NSRect)aRect
{
}

- (BOOL)hasWindowLayer
{
    return _windowLayer != nil;
}

- (id)renderDelegate
{
    if (!_renderDelegate)
        [self HSUserObjectView_initializeRenderDelegate];
    return _renderDelegate;
}

- (id)renderCacheController
{
    return [self HSUserObjectView_renderCacheController];
}

- (id)HSUserObjectView_renderCacheController
{
    if (!_renderDelegate)
        [self HSUserObjectView_initializeRenderDelegate];
    return [_renderDelegate renderCacheController];
}

- (id)createRenderCacheController
{
    return [[HSGenericRenderCacheController alloc] init];
}

- (void)HSUserObjectView_initializeRenderDelegate
{
    if (_renderDelegate)
        return;
    id controller = [self createRenderCacheController];
    _renderDelegate = [[HSGenericRenderDelegate alloc] initWithDrawable:self];
    [_renderDelegate setRenderCacheController:controller];
    [controller release];
}

// Cached renderings are for the previous screen's profile.
- (void)HSUserObjectView_windowDidChangeScreenProfile:(id)aProfile
{
    if (!_renderDelegate)
        return;
    id controller = [self createRenderCacheController];
    [_renderDelegate setRenderCacheController:controller];
    [controller release];
}

// Removed "don't erase" children leave their region to redraw.
- (void)HSUserObjectView_userObjectDidChangeChildren:(id)aChildren
{
    if (_windowLayer) {
        _areLayersIgnoredChildrenValid = NO;
        [self HSUserObjectView_invalidateRenderers];
    }
    NSArray *removed = [[aChildren userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if ([removed count]) {
        for (id child in removed) {
            if (![child dontErase])
                continue;
            BOOL inViewLayer = !_windowLayerIgnoredChildren || [_windowLayerIgnoredChildren containsObject:child];
            [self HSUserObjectView_setNeedsDisplayInRect:[self contentBoundingRect] inViewLayer:inViewLayer];
            if (_streamDrawableByObjects)
                NSMapRemove(_streamDrawableByObjects, child);
        }
    }
    [_previousViewLayerUserObjectRenderers autorelease];
    _previousViewLayerUserObjectRenderers = _currentViewLayerUserObjectRenderers;
    _currentViewLayerUserObjectRenderers = nil;
}

// A temporary child (an animation copy) leaves its trail while its animation
// does not erase it.
- (void)HSUserObjectView_userObjectWillChangeVisualAttribute:(id)aAttribute
{
    if (_isHibernating)
        return;
    NSNotification *underlying = [[aAttribute userInfo] objectForKey:@"HSUnderlyingAttributeNotification"];
    if (underlying) {
        id<HSNodeChild> child = [[underlying object] queryHyperInterface:@protocol(HSNodeChild)];
        if (child && [child isTemporary]) {
            id card = [(id<HSUserObjectSupport>)[child queryHyperInterface:@protocol(HSUserObjectSupport)] card];
            HSAnimation *animation = [[card animationController] playingAnimationAnimatingObject:[child hyperObject]];
            if (animation) {
                BOOL dontErase = [(id)child dontErase];
                BOOL wantsDontErase = ![animation suppressDontErase]
                    && (([animation isGoing] && [animation dontEraseGoing]) || ([animation isReturning] && [animation dontEraseReturning]));
                if (dontErase != wantsDontErase) {
                    if (!wantsDontErase) {
                        BOOL inViewLayer = !_windowLayerIgnoredChildren || [_windowLayerIgnoredChildren containsObject:child];
                        [self HSUserObjectView_setNeedsDisplayInRect:[self contentBoundingRect] inViewLayer:inViewLayer];
                    }
                    [(id)child setDontErase:wantsDontErase];
                    _isViewLayerRendererValid = NO;
                    _isWindowLayerRendererValid = NO;
                }
            }
        }
    }
    [self HSUserObjectView_userObjectWillDidChangeVisualAttribute:aAttribute];
}

- (void)HSUserObjectView_userObjectDidChangeVisualAttribute:(id)aAttribute
{
    if (!_isHibernating)
        [self HSUserObjectView_userObjectWillDidChangeVisualAttribute:aAttribute];
}

// The changed region goes to the view layer unless only window layer renderers
// cover it.
- (void)HSUserObjectView_userObjectWillDidChangeVisualAttribute:(id)aAttribute
{
    id attributes = [aAttribute attributeProtocolSet];
    id object = [aAttribute object];
    id info = [aAttribute userInfo];
    HSMutableRegion *region = [HSMutableRegion region];
    for (id renderer in [self HSUserObjectView_windowLayerUserObjectRenderers])
        [renderer unionBoundingRegionOfAttributeSet:attributes ofHyperObject:object withInfo:info withRegion:region];
    BOOL inViewLayer = [region isEmpty];
    for (id renderer in [self HSUserObjectView_viewLayerUserObjectRenderers])
        [renderer unionBoundingRegionOfAttributeSet:attributes ofHyperObject:object withInfo:info withRegion:region];
    [region applyAffineTransform:[self userSpaceToViewSpaceCGAffineTransform]];
    if (![region isEmpty])
        [self HSUserObjectView_setNeedsDisplayInRect:[region boundingRect] inViewLayer:inViewLayer];
}

- (void)presentationContextDidChange
{
}

- (void)setPresentationContext:(id)aContext
{
    if (_presentationContext == aContext)
        return;
    [_presentationContext release];
    _presentationContext = [aContext retain];
    [self presentationContextDidChange];
}

- (id)presentationContext
{
    return _presentationContext;
}

- (NSRect)contentBoundingRect
{
    HSMutableRegion *region = [HSMutableRegion region];
    if (!region)
        return NSZeroRect;
    for (id renderer in [self HSUserObjectView_viewLayerUserObjectRenderers])
        [renderer unionBoundingRegionWithRegion:region];
    for (id renderer in [self HSUserObjectView_windowLayerUserObjectRenderers])
        [renderer unionBoundingRegionWithRegion:region];
    return [region boundingRect];
}

- (NSRect)userObjectBounds
{
    return NSZeroRect;
}

- (id)hyperObject
{
    return _userObject;
}

- (void)reenableVisualizationForNode:(id)aNode
{
    id child = [aNode queryHyperInterface:@protocol(HSNodeChild)];
    [self unignoreChild:child];
    [self invalidateRegionOfChild:child];
}

- (void)disableVisualizationForNode:(id)aNode
{
    id child = [aNode queryHyperInterface:@protocol(HSNodeChild)];
    [self invalidateRegionOfChild:child];
    [self ignoreChild:child];
}

- (void)unignoreChild:(id)aChild
{
    [_ignoredChildren removeObject:aChild];
    _areLayersIgnoredChildrenValid = NO;
    [self HSUserObjectView_invalidateRenderers];
}

- (void)ignoreChild:(id)aChild
{
    if (!_ignoredChildren)
        _ignoredChildren = [[NSCountedSet alloc] init];
    [_ignoredChildren addObject:aChild];
    _areLayersIgnoredChildrenValid = NO;
    [self HSUserObjectView_invalidateRenderers];
}

- (id)ignoredChildren
{
    return _ignoredChildren ? [NSSet setWithSet:_ignoredChildren] : [NSSet set];
}

- (void)invalidateRegionOfChild:(id)aChild
{
    if (_isHibernating || [_ignoredChildren countForObject:aChild] != 0)
        return;
    NSDictionary *description = [NSDictionary dictionaryWithObject:aChild forKey:@"HSVisualSubobject"];
    NSDictionary *info = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:description] forKey:@"HSVisualSubobjectChangeDescriptions"];
    [self HSUserObjectView_validateLayersIgnoredChildren];
    BOOL inViewLayer = !_windowLayerIgnoredChildren || [_windowLayerIgnoredChildren containsObject:aChild];
    HSMutableRegion *region = [HSMutableRegion region];
    NSArray *renderers = inViewLayer ? [self HSUserObjectView_viewLayerUserObjectRenderers] : [self HSUserObjectView_windowLayerUserObjectRenderers];
    for (id renderer in renderers)
        [renderer unionBoundingRegionOfAttribute:@protocol(HSVisualSubobjectsAttribute) ofHyperObject:_userObject withInfo:info withRegion:region];
    [region applyAffineTransform:[self userSpaceToViewSpaceCGAffineTransform]];
    [self HSUserObjectView_setNeedsDisplayInRect:[region boundingRect] inViewLayer:inViewLayer];
}

- (id)userObjectChildrenEnumerator
{
    return [_userObject hyperEnumerator];
}

- (void)setUserObject:(id)aObject
{
    if ([self userObject] == aObject)
        return;
    if (_userObject) {
        [self unregisterObservingUserObjectAttributesChange];
        if (_windowLayer) {
            [self removeWindowLayer:_windowLayer];
            [_windowLayer release];
            _windowLayer = nil;
        }
        [_currentWindowLayerUserObjectRenderers release];
        _currentWindowLayerUserObjectRenderers = nil;
        [_previousWindowLayerUserObjectRenderers release];
        _previousWindowLayerUserObjectRenderers = nil;
        if (_streamDrawableByRenderer)
            NSFreeMapTable(_streamDrawableByRenderer);
        _streamDrawableByRenderer = nil;
        if (_streamDrawableByObjects)
            NSFreeMapTable(_streamDrawableByObjects);
        _streamDrawableByObjects = nil;
        [_previousViewLayerUserObjectRenderers release];
        _previousViewLayerUserObjectRenderers = nil;
        [_currentViewLayerUserObjectRenderers release];
        _currentViewLayerUserObjectRenderers = nil;
        [_defaultUserObjectRenderer release];
        _defaultUserObjectRenderer = nil;
        [_userObjectVisualization release];
        _userObjectVisualization = nil;
        [_interactiveChild release];
        _interactiveChild = nil;
        [_windowLayerIgnoredChildren release];
        _windowLayerIgnoredChildren = nil;
        [_viewLayerIgnoredChildren release];
        _viewLayerIgnoredChildren = nil;
        [_ignoredChildren release];
        _ignoredChildren = nil;
        _areLayersIgnoredChildrenValid = YES;
    }
    [_userObject release];
    _userObject = [aObject retain];
    if (_userObject)
        [self registerObservingUserObjectAttributesChange];
}

- (id)userObject
{
    return _userObject;
}

- (void)HSUserObjectView_invalidateRenderers
{
    HSUserObjectViewReleaseFrame(&_currentViewRendererFrame);
    _isViewLayerRendererValid = NO;
    HSUserObjectViewReleaseFrame(&_currentWindowRendererFrame);
    _isWindowLayerRendererValid = NO;
}

// The subobjects above the interacted child, when there is one.
- (id)HSUserObjectView_windowLayerUserObjectRenderers
{
    [self HSUserObjectView_validateLayersIgnoredChildren];
    if (!_windowLayerIgnoredChildren) {
        [self HSUserObjectView_releaseCurrentWindowLayerUserObjectRenderer];
    } else if (!_currentWindowLayerUserObjectRenderers || !_isWindowLayerRendererValid) {
        if (_currentWindowLayerUserObjectRenderers)
            [self HSUserObjectView_releaseCurrentWindowLayerUserObjectRenderer];
        NSMutableArray *objects = [[(id)_userObjectVisualization subobjects] mutableCopy];
        if ([objects count]) {
            if ([_windowLayerIgnoredChildren count])
                [objects removeObjectsInArray:[_windowLayerIgnoredChildren allObjects]];
            NSArray *dontEraseRenderers = nil;
            _currentWindowLayerUserObjectRenderers = [[self HSUserObjectView_renderersForObjects:objects includeBackground:NO dontEraseRenderers:&dontEraseRenderers] retain];
            [_currentViewLayerUserObjectRenderers removeObjectsInArray:_currentWindowLayerUserObjectRenderers];
            [self HSUserObjectView_updateStreamDrawablesWithDontEraseRenderers:dontEraseRenderers removedRenderers:_previousWindowLayerUserObjectRenderers];
        }
        [objects release];
    }
    _isWindowLayerRendererValid = YES;
    return _currentWindowLayerUserObjectRenderers;
}

// The previous renderers are kept until drawn once more.
- (void)HSUserObjectView_releaseCurrentWindowLayerUserObjectRenderer
{
    if (!_previousWindowLayerUserObjectRenderers)
        _previousWindowLayerUserObjectRenderers = _currentWindowLayerUserObjectRenderers;
    else
        [_currentWindowLayerUserObjectRenderers autorelease];
    _currentWindowLayerUserObjectRenderers = nil;
}

// The subobjects below the interacted child (all of them otherwise), over the
// background; nil when there is nothing to draw.
- (id)HSUserObjectView_viewLayerUserObjectRenderers
{
    [self HSUserObjectView_validateLayersIgnoredChildren];
    if (!_currentViewLayerUserObjectRenderers || !_isViewLayerRendererValid) {
        if (_currentViewLayerUserObjectRenderers) {
            if (!_previousViewLayerUserObjectRenderers)
                _previousViewLayerUserObjectRenderers = _currentViewLayerUserObjectRenderers;
            else
                [_currentViewLayerUserObjectRenderers autorelease];
            _currentViewLayerUserObjectRenderers = nil;
        }
        NSMutableArray *objects = [[(id)_userObjectVisualization subobjects] mutableCopy];
        if ([_viewLayerIgnoredChildren count])
            [objects removeObjectsInArray:[_viewLayerIgnoredChildren allObjects]];
        if ([objects count] == 0) {
            _currentViewLayerUserObjectRenderers = [[NSMutableArray alloc] initWithObjects:[self HSUserObjectView_rendererWithObjects:nil subobjectsOnlyVisualizationFlag:NO], nil];
        } else {
            NSArray *dontEraseRenderers = nil;
            _currentViewLayerUserObjectRenderers = [[self HSUserObjectView_renderersForObjects:objects includeBackground:YES dontEraseRenderers:&dontEraseRenderers] retain];
            [_currentWindowLayerUserObjectRenderers removeObjectsInArray:_currentViewLayerUserObjectRenderers];
            _isViewLayerRendererValid = YES;
            [self HSUserObjectView_updateStreamDrawablesWithDontEraseRenderers:dontEraseRenderers removedRenderers:_previousViewLayerUserObjectRenderers];
        }
        [objects release];
    }
    _isViewLayerRendererValid = YES;
    if ([_currentViewLayerUserObjectRenderers count] == 0) {
        [_currentViewLayerUserObjectRenderers release];
        _currentViewLayerUserObjectRenderers = nil;
    }
    return _currentViewLayerUserObjectRenderers;
}

// A "don't erase" renderer reuses the stream drawable of the same objects, so
// their trail survives the renderers being rebuilt.
- (void)HSUserObjectView_updateStreamDrawablesWithDontEraseRenderers:(id)aRenderers removedRenderers:(id)aRenderers2
{
    if ([aRenderers count] == 0)
        return;
    if (!_streamDrawableByRenderer) {
        _streamDrawableByRenderer = [self HSUserObjectView_streamDrawableByRendererCreateIfNeeded:YES];
    } else {
        for (id renderer in aRenderers2)
            NSMapRemove(_streamDrawableByRenderer, renderer);
    }
    if (!_streamDrawableByObjects)
        _streamDrawableByObjects = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    for (id renderer in aRenderers) {
        NSMutableArray *objects = [[[renderer visualization] subobjects] mutableCopy];
        [objects removeObjectsInArray:[[renderer ignoredSubobjects] allObjects]];
        HSRendererStreamDrawable *drawable = NSMapGet(_streamDrawableByObjects, objects);
        if (!drawable) {
            drawable = [self HSUserObjectView_rendererStreamDrawable:renderer];
            [drawable setClearsContextBeforeDraw:NO];
        } else {
            [drawable setRenderer:renderer invalidate:NO];
        }
        NSMapInsert(_streamDrawableByRenderer, renderer, drawable);
        NSMapInsert(_streamDrawableByObjects, objects, drawable);
        [objects release];
    }
}

// Splits the objects in runs drawn by one renderer each: the "don't erase"
// objects one by one, the others together (an object that had a stream
// drawable ends its run too). The background goes in the first renderer, or
// alone before a leading "don't erase" object.
- (id)HSUserObjectView_renderersForObjects:(id)aObjects includeBackground:(BOOL)aBackground dontEraseRenderers:(id *)aRenderers
{
    if (!_userObjectVisualization)
        return nil;
    BOOL includeBackground = aBackground;
    NSMutableArray *renderers = [NSMutableArray array];
    NSMutableArray *dontEraseRenderers = aRenderers ? [NSMutableArray array] : nil;
    BOOL runDontErase = NO;
    NSMutableSet *run = nil;
    NSEnumerator *enumerator = [aObjects objectEnumerator];
    id object;
    do {
        object = [enumerator nextObject];
        BOOL dontErase = [object dontErase];
        BOOL endsRun = !object || dontErase != runDontErase || (runDontErase && dontErase);
        if ([renderers count] == 0 && dontErase && includeBackground) {
            [renderers addObject:[self HSUserObjectView_rendererWithObjects:nil subobjectsOnlyVisualizationFlag:NO]];
            includeBackground = NO;
        }
        BOOL hasStreamDrawable = object && _streamDrawableByObjects && NSMapGet(_streamDrawableByObjects, [NSArray arrayWithObject:object]);
        if ((endsRun || (!dontErase && hasStreamDrawable)) && run) {
            id renderer = [self HSUserObjectView_rendererWithObjects:run subobjectsOnlyVisualizationFlag:!includeBackground];
            [renderers addObject:renderer];
            if (runDontErase)
                [dontEraseRenderers addObject:renderer];
            else if (_streamDrawableByRenderer)
                NSMapRemove(_streamDrawableByRenderer, renderer);
            if (hasStreamDrawable) {
                id subobjectsRenderer = [self HSUserObjectView_rendererWithObjects:nil subobjectsOnlyVisualizationFlag:YES];
                [renderers addObject:subobjectsRenderer];
                HSRendererStreamDrawable *drawable = NSMapGet(_streamDrawableByObjects, [NSArray arrayWithObject:object]);
                [drawable setRenderer:subobjectsRenderer invalidate:NO];
                NSMapInsertIfAbsent(_streamDrawableByRenderer, subobjectsRenderer, drawable);
            }
            [run release];
            includeBackground = NO;
            run = nil;
        }
        if (!run && object) {
            run = [NSMutableSet new];
            runDontErase = dontErase;
        }
        if (object)
            [run addObject:object];
    } while (object);
    [run release];
    if (aRenderers)
        *aRenderers = dontEraseRenderers;
    return renderers;
}

// Renders the given subobjects only, over the background unless the flag is set.
- (id)HSUserObjectView_rendererWithObjects:(id)aObjects subobjectsOnlyVisualizationFlag:(BOOL)aFlag
{
    NSMutableSet *ignored = [NSMutableSet setWithArray:[(id)_userObjectVisualization subobjects]];
    [ignored minusSet:aObjects];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:ignored, @"HSIgnoredSubobjectsVisualizationOption", aFlag ? [NSNumber numberWithBool:aFlag] : nil, @"HSSubobjectsOnlyVisualizationOption", nil];
    return [(id)_userObjectVisualization queryRendererWithVisualizationOptions:options];
}

- (id)HSUserObjectView_viewLayerRendererForUserObject:(id)aObject
{
    return [[aObject queryHyperInterface:[[self class] visualizationProtocol]] queryRenderer];
}

// With an interacted child, the subobjects below it are ignored by the window
// layer and those above it by the view layer.
- (void)HSUserObjectView_validateLayersIgnoredChildren
{
    if (![self HSUserObjectView_userObjectVisualization] || _areLayersIgnoredChildrenValid)
        return;
    if (!_viewLayerIgnoredChildren) {
        if (_ignoredChildren) {
            _viewLayerIgnoredChildren = [[NSMutableSet alloc] initWithSet:_ignoredChildren];
            if (!_viewLayerIgnoredChildren)
                return;
        }
    } else if (_ignoredChildren) {
        [_viewLayerIgnoredChildren setSet:_ignoredChildren];
    } else {
        [_viewLayerIgnoredChildren removeAllObjects];
    }
    if (!_interactiveChild) {
        [_windowLayerIgnoredChildren release];
        _windowLayerIgnoredChildren = nil;
    } else {
        [_windowLayerIgnoredChildren removeAllObjects];
        NSArray *subobjects = [(id)_userObjectVisualization subobjects];
        NSUInteger count = [subobjects count];
        NSUInteger index = 0;
        for (; index < count; index++) {
            id subobject = [subobjects objectAtIndex:index];
            if (subobject == _interactiveChild)
                break;
            if (!_windowLayerIgnoredChildren)
                _windowLayerIgnoredChildren = [[NSMutableSet alloc] init];
            [_windowLayerIgnoredChildren addObject:subobject];
        }
        if (index + 1 < count) {
            if (!_viewLayerIgnoredChildren)
                _viewLayerIgnoredChildren = [[NSMutableSet alloc] init];
            for (NSUInteger above = index + 1; above < count; above++)
                [_viewLayerIgnoredChildren addObject:[subobjects objectAtIndex:above]];
            if (_ignoredChildren) {
                if (!_windowLayerIgnoredChildren)
                    _windowLayerIgnoredChildren = [[NSMutableSet alloc] initWithSet:_ignoredChildren];
                else
                    [_windowLayerIgnoredChildren unionSet:_ignoredChildren];
            }
        } else {
            [_windowLayerIgnoredChildren release];
            _windowLayerIgnoredChildren = nil;
        }
    }
    _areLayersIgnoredChildrenValid = YES;
}

- (id)HSUserObjectView_streamDrawableByRendererCreateIfNeeded:(BOOL)aNeeded
{
    if (!_streamDrawableByRenderer && aNeeded)
        _streamDrawableByRenderer = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    return _streamDrawableByRenderer;
}

- (id)HSUserObjectView_userObjectVisualization
{
    if (!_userObjectVisualization)
        _userObjectVisualization = [[_userObject queryHyperInterface:[[self class] visualizationProtocol]] retain];
    return _userObjectVisualization;
}

- (void)HSUserObjectView_updateAfterDelay
{
    [self HSUserObjectView_cancelUpdate];
    [self performSelector:@selector(HSUserObjectView_finalizeUpdate) withObject:nil afterDelay:0 inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil]];
}

- (void)HSUserObjectView_cancelUpdate
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(HSUserObjectView_finalizeUpdate) object:nil];
}

- (BOOL)HSUserObjectView_hasConsumers
{
    return _activeConsumers && CFDictionaryGetCount(_activeConsumers) > 0;
}

- (void)awakeFromHibernating
{
}

- (void)fallToHibernating
{
}

- (void)dehibernate
{
    if (!_isHibernating)
        return;
    _isHibernating = NO;
    [self awakeFromHibernating];
}

- (void)hibernate
{
    if (_isHibernating)
        return;
    _isHibernating = YES;
    [self fallToHibernating];
}

- (BOOL)isHibernating
{
    return _isHibernating;
}

// Grown by a little over a device pixel for antialiased edges.
- (void)HSUserObjectView_setNeedsDisplayInRect:(NSRect)aRect inViewLayer:(BOOL)aLayer
{
    NSSize margin = [self convertSize:NSMakeSize(1.05, 1.05) fromView:nil];
    NSRect rect = NSIntegralRect(NSInsetRect(aRect, -margin.width, -margin.height));
    if (aLayer)
        [self setNeedsDisplayInViewLayerRect:rect];
    else
        [self setNeedsDisplayInRect:rect inWindowLayer:_windowLayer];
}

- (void)registerObservingUserObjectAttributesChange
{
    [_userObject addObserver:self selector:@selector(HSUserObjectView_userObjectWillChangeVisualAttribute:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSVisualAttribute) withPriority:-0.75];
    [_userObject addObserver:self selector:@selector(HSUserObjectView_userObjectDidChangeVisualAttribute:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute) withPriority:-0.75];
    [_userObject addObserver:self selector:@selector(HSUserObjectView_userObjectDidChangeChildren:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.75];
}

- (void)unregisterObservingUserObjectAttributesChange
{
    [_userObject removeObserver:self selector:@selector(HSUserObjectView_userObjectWillChangeVisualAttribute:) ofChanges:HSActualWillAttributeChanges ofAttribute:@protocol(HSVisualAttribute)];
    [_userObject removeObserver:self selector:@selector(HSUserObjectView_userObjectDidChangeVisualAttribute:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute)];
    [_userObject removeObserver:self selector:@selector(HSUserObjectView_userObjectDidChangeChildren:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
}

- (void)viewDidMoveToWindow
{
    NSWindow *window = [self window];
    if (window && [self HSUserObjectView_userObjectViewProxy])
        [[NSNotificationCenter defaultCenter] addObserver:_userObjectViewProxy selector:@selector(HSUserObjectView_windowDidChangeScreenProfile:) name:NSWindowDidChangeScreenProfileNotification object:window];
    [super viewDidMoveToWindow];
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    NSWindow *window = [self window];
    if (window && _userObjectViewProxy)
        [[NSNotificationCenter defaultCenter] removeObserver:_userObjectViewProxy name:NSWindowDidChangeScreenProfileNotification object:window];
    [super viewWillMoveToWindow:aWindow];
}

- (void)enableOpenGLSurface
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HSOpenGLBackEndDisabled"])
        return;
    if (CFPreferencesGetAppBooleanValue(CFSTR("HSOpenGLBackEndDisabled"), CFSTR("com.mackiev.hyperplayerbase"), NULL))
        return;
    [super enableOpenGLSurface];
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (id)HSUserObjectView_userObjectViewProxy
{
    if (!_userObjectViewProxy)
        _userObjectViewProxy = [self NSE_newWeakProxy];
    return _userObjectViewProxy;
}

- (void)dealloc
{
    [self HSUserObjectView_cancelUpdate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // The original left the proxy observing the window.
    if (_userObjectViewProxy)
        [[NSNotificationCenter defaultCenter] removeObserver:_userObjectViewProxy];
    [_userObject removeAttributeObserver:self];
    [_userObject removeChildrenAttributeObserver:self];
    [self unregisterObservingUserObjectAttributesChange];
    [_renderDelegate clearDrawable];
    [_renderDelegate release];
    [_currentWindowLayerUserObjectRenderers release];
    [_currentViewLayerUserObjectRenderers release];
    [_previousViewLayerUserObjectRenderers release];
    [_previousWindowLayerUserObjectRenderers release];
    if (_streamDrawableByRenderer)
        NSFreeMapTable(_streamDrawableByRenderer);
    if (_streamDrawableByObjects)
        NSFreeMapTable(_streamDrawableByObjects);
    [_defaultUserObjectRenderer release];
    [_userObjectVisualization release];
    [_windowLayer release];
    [_viewLayerIgnoredChildren release];
    [_windowLayerIgnoredChildren release];
    [_interactiveChild release];
    [_ignoredChildren release];
    [_userObject release];
    [_presentationContext release];
    if (_activeConsumers)
        CFRelease(_activeConsumers);
    HSUserObjectViewReleaseFrame(&_currentWindowRendererFrame);
    HSUserObjectViewReleaseFrame(&_currentViewRendererFrame);
    [self HSUserObjectView_invalidatePixelBufferOfViewFromWindowBuffer];
    CVPixelBufferPoolRelease(_mixedFramesPool);
    [[self class] NSE_invalidateWeakProxy:_userObjectViewProxy];
    [_userObjectViewProxy release];
    [super dealloc];
}

- (NSRect)HSUserObjectView_viewBoundingRectForUserRect:(NSRect)aRect
{
    id region = [HSMutableRegion regionWithRect:aRect];
    [region applyAffineTransform:[self userSpaceToViewSpaceCGAffineTransform]];
    return [region boundingRect];
}

@end
