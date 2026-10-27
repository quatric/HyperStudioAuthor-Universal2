#import "HSTransitionView.h"
#import "HSTransitionEffect.h"
#import "HSTransitionPlayer.h"
#import "NSEOpenGLContext.h"
#import "__NSEWeakObjectProxy.h"
#import "CGEBitmapContext.h"
#import "CGEImage.h"
#import "SMKApplicationKitData.h"
#import <OpenGL/gl.h>

// The kinds of images a transition view draws.
typedef NS_ENUM(NSInteger, HSTransitionViewImageKind) {
    HSTransitionViewImageKindOther,
    HSTransitionViewImageKindNSImage,
    HSTransitionViewImageKindCGImage,
    HSTransitionViewImageKindPixelBuffer
};

// The original took any object with a CFGetTypeID of 1 for an NSImage.
static HSTransitionViewImageKind HSTransitionViewKindOfImage(id aImage)
{
    CFTypeID type = CFGetTypeID((CFTypeRef)aImage);
    if (type == CGImageGetTypeID())
        return HSTransitionViewImageKindCGImage;
    if (type == CVPixelBufferGetTypeID())
        return HSTransitionViewImageKindPixelBuffer;
    if ([aImage isKindOfClass:[NSImage class]])
        return HSTransitionViewImageKindNSImage;
    return HSTransitionViewImageKindOther;
}

static BOOL HSTransitionViewLengthMatches(size_t aLength, float aDeviceLength)
{
    float length = aLength;
    return aDeviceLength - 0.005f <= length && length <= aDeviceLength + 0.005f;
}

static size_t HSTransitionViewPixelLength(float aLength)
{
    return aLength > 0.0f ? lroundf(ceilf(aLength)) : 0;
}

@implementation HSTransitionView

/* i386 ivar offsets: _transitionViewProxy=0xbc, _transitionEffect=0xc0, _backgroundColor=0xc4, _transitionPlayer=0xc8, _deviceSize=0xcc, _openGLTransitionRenderer=0xd4, _quartzTransitionRenderer=0xd8, _startImageBuffer=0xdc, _endImageBuffer=0xe0, _dataSource=0xe4, _pixelBufferPool=0xe8, _startPixelBuffer=0xec, _endPixelBuffer=0xf0, _delegate=0xf4, _activeConsumers=0xf8, _areDeviceSizeChangesObserved=0xfc, _scalesImagesToFit=0xfc, _isStartImageInvalid=0xfc, _isStartImageChangedForOpenGL=0xfc, _isStartImageChangedForQuartz=0xfc, _isEndImageInvalid=0xfc, _isEndImageChangedForOpenGL=0xfc, _isEndImageChangedForQuartz=0xfc */

// A transparent surface without vertical sync.
+ (id)createDefaultOpenGLContext
{
    NSEOpenGLContext *context = [super createDefaultOpenGLContext];
    if (context != nil) {
        int opacity = 0;
        [context setValues:&opacity forParameter:NSOpenGLContextParameterSurfaceOpacity];
        int swapInterval = 1;
        [context setValues:&swapInterval forParameter:NSOpenGLContextParameterSwapInterval];
    }
    return context;
}

- (void)stopCapturingForConsumer:(id)aConsumer
{
    if (_activeConsumers == NULL)
        return;
    NSUInteger count = (NSUInteger)CFDictionaryGetValue(_activeConsumers, aConsumer);
    if (count == 0)
        return;
    if (count == 1)
        CFDictionaryRemoveValue(_activeConsumers, aConsumer);
    else
        CFDictionarySetValue(_activeConsumers, aConsumer, (const void *)(count - 1));
}

// Consumers are counted; a playing transition sends its current frame at once.
- (void)startCapturingForConsumer:(id)aConsumer
{
    NSUInteger count;
    if (_activeConsumers == NULL) {
        _activeConsumers = CFDictionaryCreateMutable(NULL, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_activeConsumers == NULL)
            return;
        count = 1;
    } else {
        count = (NSUInteger)CFDictionaryGetValue(_activeConsumers, aConsumer) + 1;
    }
    CFDictionarySetValue(_activeConsumers, aConsumer, (const void *)count);
    if (CFDictionaryGetCount(_activeConsumers) <= 0)
        return;
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    if (_deviceSize.width == 0.0 || _deviceSize.height == 0.0)
        return;
    if ([self HSTransitionView_quartzTransitionRenderer] != nil)
        [self HSTransitionView_synchronizeQuartzTransitionRenderer];
    if (![_transitionPlayer isPlaying])
        return;
    CVPixelBufferRef pixelBuffer = NULL;
    size_t height = HSTransitionViewPixelLength(_deviceSize.height);
    size_t width = HSTransitionViewPixelLength(_deviceSize.width);
    CVPixelBufferPoolCreatePixelBuffer(NULL, [self HSTransitionView_pixelBufferPoolWithWidth:width height:height], &pixelBuffer);
    if (pixelBuffer == NULL)
        return;
    CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
    if (context != NULL) {
        CGContextClearRect(context, CGRectMake(0.0, 0.0, CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context)));
        [self HSTransitionView_drawQuartzFrameInContext:context];
        CGContextRelease(context);
        [self HSTransitionView_sendFrame:pixelBuffer withTime:time];
        CVPixelBufferRelease(pixelBuffer);
    }
    // The original leaked the pixel buffer when no bitmap context could be made.
    else {
        CVPixelBufferRelease(pixelBuffer);
    }
}

- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

- (BOOL)accessibilityIsAttributeSettable:(id)aSettable
{
    if ([aSettable isEqualToString:NSAccessibilityTitleAttribute] || [aSettable isEqualToString:NSAccessibilityHelpAttribute] ||
        [aSettable isEqualToString:NSAccessibilityChildrenAttribute] || [aSettable isEqualToString:NSAccessibilityVisibleChildrenAttribute])
        return NO;
    return [super accessibilityIsAttributeSettable:aSettable];
}

- (void)accessibilityPerformAction:(id)aAction
{
    if ([aAction isEqualToString:NSAccessibilityPressAction])
        [self startTransition];
}

- (id)accessibilityActionDescription:(id)aDescription
{
    if (![aDescription isEqualToString:NSAccessibilityPressAction])
        return nil;
    return [[NSBundle mainBundle] localizedStringForKey:@"Transition View" value:@"" table:nil];
}

- (id)accessibilityActionNames
{
    return [NSArray arrayWithObject:NSAccessibilityPressAction];
}

- (id)accessibilityHitTest:(NSPoint)aTest
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute])
        return NSAccessibilityWindowRole;
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute])
        return [[NSBundle mainBundle] localizedStringForKey:@"Transtition View Role" value:@"" table:nil];
    if ([aValue isEqualToString:NSAccessibilityTitleAttribute] || [aValue isEqualToString:NSAccessibilityHelpAttribute])
        return [[NSBundle mainBundle] localizedStringForKey:@"Transition View" value:@"" table:nil];
    return [super accessibilityAttributeValue:aValue];
}

- (void)drawQuartzSurfaceRect:(NSRect)aRect
{
    [self drawBackgroundRect:aRect];
    if (_openGLTransitionRenderer == nil) {
        if ([self HSTransitionView_quartzTransitionRenderer] != nil)
            [self HSTransitionView_synchronizeQuartzTransitionRenderer];
        [self drawQuartzFrameRect:aRect];
    }
}

// Fetches invalidated images from the data source and hands changed ones to
// the Quartz renderer.
- (void)HSTransitionView_synchronizeQuartzTransitionRenderer
{
    if (_isStartImageInvalid) {
        [self setStartImage:[_dataSource startImageForTransitionView:self]];
        _isStartImageInvalid = 0;
    }
    if (_isEndImageInvalid) {
        [self setEndImage:[_dataSource endImageForTransitionView:self]];
        _isEndImageInvalid = 0;
    }
    if (_isStartImageChangedForQuartz) {
        [_quartzTransitionRenderer setStartImage:[self HSTransitionView_startImage]];
        _isStartImageChangedForQuartz = 0;
    }
    if (_isEndImageChangedForQuartz) {
        [_quartzTransitionRenderer setEndImage:[self HSTransitionView_endImage]];
        _isEndImageChangedForQuartz = 0;
    }
}

- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect
{
    if ([self HSTransitionView_openGLTransitionRenderer] == nil)
        return NO;
    if (_isStartImageInvalid) {
        [self setStartImage:[_dataSource startImageForTransitionView:self]];
        _isStartImageInvalid = 0;
    }
    if (_isEndImageInvalid) {
        [self setEndImage:[_dataSource endImageForTransitionView:self]];
        _isEndImageInvalid = 0;
    }
    if (_isStartImageChangedForOpenGL) {
        [_openGLTransitionRenderer setStartImage:[self HSTransitionView_startImage]];
        _isStartImageChangedForOpenGL = 0;
    }
    if (_isEndImageChangedForOpenGL) {
        [_openGLTransitionRenderer setEndImage:[self HSTransitionView_endImage]];
        _isEndImageChangedForOpenGL = 0;
    }
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClearDepth(1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawOpenGLFrame];
    return YES;
}

// Draws the frame scaled from device size to the bounds. While capturing, the
// frame is rendered into a pixel buffer that is both sent to the consumers
// and drawn.
- (void)drawQuartzFrameRect:(NSRect)aRect
{
    if (_deviceSize.width == 0.0 || _deviceSize.height == 0.0)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    if (context == NULL)
        return;
    NSRect bounds = [self bounds];
    CGContextScaleCTM(context, bounds.size.width / _deviceSize.width, bounds.size.height / _deviceSize.height);
    if (_activeConsumers == NULL || CFDictionaryGetCount(_activeConsumers) < 1) {
        [self HSTransitionView_drawQuartzFrameInContext:context];
        return;
    }
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    CVPixelBufferRef pixelBuffer = NULL;
    size_t height = HSTransitionViewPixelLength(_deviceSize.height);
    size_t width = HSTransitionViewPixelLength(_deviceSize.width);
    CVPixelBufferPoolCreatePixelBuffer(NULL, [self HSTransitionView_pixelBufferPoolWithWidth:width height:height], &pixelBuffer);
    if (pixelBuffer == NULL)
        return;
    CGContextRef bitmap = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
    if (bitmap != NULL) {
        CGContextClearRect(bitmap, CGRectMake(0.0, 0.0, CGBitmapContextGetWidth(bitmap), CGBitmapContextGetHeight(bitmap)));
        [self HSTransitionView_drawQuartzFrameInContext:bitmap];
        CGContextRelease(bitmap);
        CGImageRef image = CGEImageCreateWithPixelBuffer(pixelBuffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
        if (image != NULL) {
            CVBufferSetAttachment(pixelBuffer, CFSTR("HSPixelBufferCGImage"), image, kCVAttachmentMode_ShouldNotPropagate);
            [self HSTransitionView_sendFrame:pixelBuffer withTime:time];
            CVBufferRemoveAttachment(pixelBuffer, CFSTR("HSPixelBufferCGImage"));
            CVPixelBufferRelease(pixelBuffer);
            CGContextDrawImage(context, CGRectMake(0.0, 0.0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
            CGImageRelease(image);
            return;
        }
    }
    CVPixelBufferRelease(pixelBuffer);
}

// Without a Quartz renderer the start image is drawn, or the end image once
// the transition is complete.
- (void)HSTransitionView_drawQuartzFrameInContext:(struct CGContext *)aContext
{
    if (_quartzTransitionRenderer != nil) {
        [_quartzTransitionRenderer renderFrameAtTime:[self transitionTime] inCoreGraphicsContext:aContext];
        return;
    }
    id image = [self transitionTime] == 1.0 ? [self HSTransitionView_endImage] : [self HSTransitionView_startImage];
    if (image != nil)
        [self HSTransitionView_drawImage:image inContext:aContext];
}

- (void)HSTransitionView_drawImage:(id)aImage inContext:(struct CGContext *)aContext
{
    switch (HSTransitionViewKindOfImage(aImage)) {
    case HSTransitionViewImageKindNSImage:
        if ([[NSGraphicsContext currentContext] CGContext] == aContext) {
            [aImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
        } else {
            NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:aContext flipped:NO];
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:graphicsContext];
            [aImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
            [NSGraphicsContext restoreGraphicsState];
        }
        break;
    case HSTransitionViewImageKindCGImage: {
        CGImageRef image = (CGImageRef)aImage;
        CGContextDrawImage(aContext, CGRectMake(0.0, 0.0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
        break;
    }
    case HSTransitionViewImageKindPixelBuffer: {
        CGImageRef image = CGEImageCreateWithPixelBuffer((CVPixelBufferRef)aImage, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
        if (image != NULL) {
            CGContextDrawImage(aContext, CGRectMake(0.0, 0.0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
            CGImageRelease(image);
        }
        break;
    }
    default:
        break;
    }
}

- (void)HSTransitionView_sendFrame:(struct __CVBuffer *)aFrame withTime:(double)aTime
{
    CFIndex count = CFDictionaryGetCount(_activeConsumers);
    if (count == 0)
        return;
    if (count == 1) {
        id consumer = nil;
        CFDictionaryGetKeysAndValues(_activeConsumers, (const void **)&consumer, NULL);
        [consumer capturingDataSource:self didOutputFrame:aFrame atTime:aTime];
        return;
    }
    const void **consumers = malloc(count * sizeof(void *));
    if (consumers == NULL)
        return;
    CFDictionaryGetKeysAndValues(_activeConsumers, consumers, NULL);
    for (; count != 0; count--) {
        if (CFDictionaryGetValue(_activeConsumers, consumers[count - 1]) != NULL)
            [(id)consumers[count - 1] capturingDataSource:self didOutputFrame:aFrame atTime:aTime];
    }
    free(consumers);
}

- (void)drawOpenGLFrame
{
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    [_openGLTransitionRenderer renderFrameAtTime:[self transitionTime]];
}

- (void)drawBackgroundRect:(NSRect)aRect
{
    if (_backgroundColor != nil) {
        [(NSColor *)_backgroundColor set];
        NSRectFill(aRect);
    }
}

- (void)transitionPlayerDidPlayNewFrame:(id)aFrame
{
    if (_transitionPlayer == aFrame && ![self displayOpenGLSurface])
        [self display];
}

// Identity, translated by the offset of the bounds in the viewport.
- (void)getOpenGLSurfaceProjectionMatrix:(float *)aMatrix forBounds:(NSRect)aBounds viewportRect:(NSRect)aRect
{
    aMatrix[0] = 1.0f;
    aMatrix[1] = 0.0f;
    aMatrix[2] = 0.0f;
    aMatrix[3] = 0.0f;
    aMatrix[4] = 0.0f;
    aMatrix[5] = 1.0f;
    aMatrix[6] = 0.0f;
    aMatrix[7] = 0.0f;
    aMatrix[8] = 0.0f;
    aMatrix[9] = 0.0f;
    aMatrix[10] = 1.0f;
    aMatrix[11] = 0.0f;
    double offsetX = (float)(aBounds.origin.x - aRect.origin.x);
    double offsetY = (float)(aBounds.origin.y - aRect.origin.y);
    aMatrix[12] = (offsetX + offsetX) / (float)aRect.size.width;
    aMatrix[13] = (offsetY + offsetY) / (float)aRect.size.height;
    aMatrix[14] = 0.0f;
    aMatrix[15] = 1.0f;
}

- (void)changeOpenGLSurfaceViewportFrom:(int *)aFrom to:(int *)aTo
{
    [self HSTransitionView_invalidateOpenGLTransitionRenderer];
    [self HSTransitionView_synchronizeDeviceSizeChangesObserving];
    [super changeOpenGLSurfaceViewportFrom:aFrom to:aTo];
}

- (void)disassociateOpenGLContext
{
    [self HSTransitionView_invalidateOpenGLTransitionRenderer];
    [self HSTransitionView_synchronizeDeviceSizeChangesObserving];
    [super disassociateOpenGLContext];
}

// Only for effects with an OpenGL renderer and while nobody captures. Before
// AppKit 949 the surface must also lie within the visible rect.
- (BOOL)shouldDisplayOpenGLSurface
{
    if (![_transitionEffect hasOpenGLRenderer])
        return NO;
    if (_activeConsumers != NULL && CFDictionaryGetCount(_activeConsumers) > 0)
        return NO;
    if (!(NSAppKitVersionNumber < 949.0))
        return YES;
    NSRect surface = [self openGLSurfaceBounds];
    NSRect visible = [self visibleRect];
    if (surface.origin.x + 0.0001 < visible.origin.x || surface.origin.y + 0.0001 < visible.origin.y ||
        visible.origin.x + visible.size.width < surface.origin.x + surface.size.width - 0.0001)
        return NO;
    return surface.origin.y + surface.size.height - 0.0001 <= visible.origin.y + visible.size.height;
}

// The bounds of every superview are observed, so they are observed anew.
- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if (!_areDeviceSizeChangesObserved)
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:_transitionViewProxy name:NSViewBoundsDidChangeNotification object:nil];
    // Quirk kept: the end pixel buffer, not the end image, is checked.
    if (_startImageBuffer == nil && _endPixelBuffer == NULL && _openGLTransitionRenderer == nil && _quartzTransitionRenderer == nil) {
        [center removeObserver:_transitionViewProxy name:NSViewFrameDidChangeNotification object:self];
        _areDeviceSizeChangesObserved = 0;
    } else {
        NSView *view = self;
        do {
            [center addObserver:_transitionViewProxy selector:@selector(HSTransitionView_viewDidChangeDeviceSize:) name:NSViewBoundsDidChangeNotification object:view];
            view = [view superview];
        } while (view != nil);
    }
}

- (BOOL)isOpaque
{
    if (_backgroundColor != nil && ![[_backgroundColor colorSpaceName] isEqualToString:NSPatternColorSpace])
        return [_backgroundColor alphaComponent] >= 0.9980392156862745;
    return NO;
}

- (void)transitionPlayerDidFinish:(id)aFinish
{
    if (_transitionPlayer == aFinish)
        [_delegate transitionViewDidFinishTransition:self];
}

- (void)setTransitionTime:(double)aTime
{
    [[self HSTransitionView_transitionPlayer] setTransitionTime:aTime];
}

- (double)transitionTime
{
    if ([self HSTransitionView_transitionPlayer] == nil)
        return 0.0;
    return [_transitionPlayer transitionTime];
}

- (BOOL)isTransitionPlaying
{
    return [_transitionPlayer isPlaying];
}

- (void)stopTransition
{
    [_transitionPlayer stop];
    [_delegate transitionViewDidStopTransition:self];
}

// A transition that cannot play jumps to its end.
- (BOOL)startTransition
{
    BOOL started = [(HSTransitionPlayer *)[self HSTransitionView_transitionPlayer] start];
    if (!started)
        [_transitionPlayer setTransitionTime:[_transitionPlayer transitionPlayRangeStartTime] + [_transitionPlayer transitionPlayRangeDuration]];
    [self transitionPlayerDidPlayNewFrame:_transitionPlayer];
    return started;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)invalidateEndImage
{
    _isEndImageInvalid = 1;
}

- (void)invalidateStartImage
{
    _isStartImageInvalid = 1;
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (id)dataSource
{
    return _dataSource;
}

// A renderer needs a new image when there is one, or when it exists and the
// image went away.
- (void)HSTransitionView_markStartImageChanged
{
    _isStartImageChangedForOpenGL = _startImageBuffer != nil || _openGLTransitionRenderer != nil;
    _isStartImageChangedForQuartz = _startImageBuffer != nil || _quartzTransitionRenderer != nil;
}

- (void)HSTransitionView_markEndImageChanged
{
    _isEndImageChangedForOpenGL = _endImageBuffer != nil || _openGLTransitionRenderer != nil;
    _isEndImageChangedForQuartz = _endImageBuffer != nil || _quartzTransitionRenderer != nil;
}

- (void)swapStartImageAndEndImage
{
    id start = _startImageBuffer;
    if (start == _endImageBuffer)
        return;
    _startImageBuffer = _endImageBuffer;
    _endImageBuffer = start;
    CVPixelBufferRef pixelBuffer = _endPixelBuffer;
    _endPixelBuffer = _startPixelBuffer;
    _startPixelBuffer = pixelBuffer;
    [self HSTransitionView_markStartImageChanged];
    [self HSTransitionView_markEndImageChanged];
}

- (void)setStartImageAsEndImage
{
    if (_startImageBuffer == _endImageBuffer)
        return;
    [_endImageBuffer release];
    _endImageBuffer = [_startImageBuffer retain];
    CVPixelBufferRelease(_endPixelBuffer);
    _endPixelBuffer = CVPixelBufferRetain(_startPixelBuffer);
    [self HSTransitionView_markEndImageChanged];
    [self HSTransitionView_synchronizeDeviceSizeChangesObserving];
}

- (void)setEndImageAsStartImage
{
    if (_endImageBuffer == _startImageBuffer)
        return;
    [_startImageBuffer release];
    _startImageBuffer = [_endImageBuffer retain];
    CVPixelBufferRelease(_startPixelBuffer);
    _startPixelBuffer = CVPixelBufferRetain(_endPixelBuffer);
    [self HSTransitionView_markStartImageChanged];
    [self HSTransitionView_synchronizeDeviceSizeChangesObserving];
}

- (void)setEndImage:(id)aImage
{
    if (_endImageBuffer == aImage)
        return;
    [aImage retain];
    [_endImageBuffer release];
    _endImageBuffer = aImage;
    CVPixelBufferRelease(_endPixelBuffer);
    _endPixelBuffer = NULL;
    [self HSTransitionView_markEndImageChanged];
    [self HSTransitionView_synchronizeDeviceSizeChangesObserving];
}

- (void)setStartImage:(id)aImage
{
    if (_startImageBuffer == aImage)
        return;
    [aImage retain];
    [_startImageBuffer release];
    _startImageBuffer = aImage;
    CVPixelBufferRelease(_startPixelBuffer);
    _startPixelBuffer = NULL;
    [self HSTransitionView_markStartImageChanged];
    [self HSTransitionView_synchronizeDeviceSizeChangesObserving];
}

- (id)HSTransitionView_endImage
{
    return [self HSTransitionView_imageForImageBuffer:_endImageBuffer pixelBuffer:&_endPixelBuffer];
}

- (id)HSTransitionView_startImage
{
    return [self HSTransitionView_imageForImageBuffer:_startImageBuffer pixelBuffer:&_startPixelBuffer];
}

// When scaling to fit, the image is scaled to device size once and the
// result kept while its size still matches.
- (id)HSTransitionView_imageForImageBuffer:(id)aBuffer pixelBuffer:(struct __CVBuffer **)aBuffer2
{
    if (aBuffer == nil)
        return nil;
    if (!_scalesImagesToFit)
        return aBuffer;
    if (*aBuffer2 != NULL) {
        if (HSTransitionViewLengthMatches(CVPixelBufferGetWidth(*aBuffer2), _deviceSize.width) &&
            HSTransitionViewLengthMatches(CVPixelBufferGetHeight(*aBuffer2), _deviceSize.height))
            return (id)*aBuffer2;
        CVPixelBufferRelease(*aBuffer2);
        *aBuffer2 = NULL;
    }
    id image = [self HSTransitionView_scaleImage:aBuffer];
    if (image != nil && CFGetTypeID((CFTypeRef)image) == CVPixelBufferGetTypeID())
        *aBuffer2 = CVPixelBufferRetain((CVPixelBufferRef)image);
    return image;
}

// Renders the image at device size into a pixel buffer and returns it as an
// image. Images already of device size are returned as they are.
- (id)HSTransitionView_scaleImage:(id)aImage
{
    size_t width = HSTransitionViewPixelLength(_deviceSize.width);
    if (width == 0)
        return nil;
    if (_deviceSize.height <= 0.0f)
        return nil;
    size_t height = HSTransitionViewPixelLength(_deviceSize.height);
    if (height == 0)
        return nil;
    CGImageRef source;
    switch (HSTransitionViewKindOfImage(aImage)) {
    case HSTransitionViewImageKindNSImage: {
        NSSize size = [(NSImage *)aImage size];
        if (size.width <= 0.0 || size.height <= 0.0)
            return nil;
        CVPixelBufferPoolRef pool = [self HSTransitionView_pixelBufferPoolWithWidth:width height:height];
        if (pool == NULL)
            return nil;
        CVPixelBufferRef pixelBuffer = NULL;
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBuffer);
        if (pixelBuffer == NULL)
            return nil;
        CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
        if (context == NULL) {
            CVPixelBufferRelease(pixelBuffer);
            return nil;
        }
        CGContextClearRect(context, CGRectMake(0.0, 0.0, width, height));
        CGContextScaleCTM(context, _deviceSize.width / (float)size.width, _deviceSize.height / (float)size.height);
        NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
        NSGraphicsContext *graphicsContext = [NSGraphicsContext graphicsContextWithCGContext:context flipped:NO];
        if (graphicsContext == nil) {
            [autoreleasePool release];
            CGContextRelease(context);
            CVPixelBufferRelease(pixelBuffer);
            return nil;
        }
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:graphicsContext];
        [aImage drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
        [NSGraphicsContext restoreGraphicsState];
        [autoreleasePool release];
        CGContextRelease(context);
        CGImageRef image = CGEImageCreateWithPixelBuffer(pixelBuffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
        CVPixelBufferRelease(pixelBuffer);
        return [(id)image autorelease];
    }
    case HSTransitionViewImageKindCGImage: {
        size_t imageWidth = CGImageGetWidth((CGImageRef)aImage);
        if (imageWidth == 0)
            return nil;
        size_t imageHeight = CGImageGetHeight((CGImageRef)aImage);
        if (imageHeight == 0)
            return nil;
        if (HSTransitionViewLengthMatches(imageWidth, _deviceSize.width) && HSTransitionViewLengthMatches(imageHeight, _deviceSize.height))
            return aImage;
        source = (CGImageRef)aImage;
        break;
    }
    case HSTransitionViewImageKindPixelBuffer: {
        size_t bufferWidth = CVPixelBufferGetWidth((CVPixelBufferRef)aImage);
        if (bufferWidth == 0)
            return nil;
        size_t bufferHeight = CVPixelBufferGetHeight((CVPixelBufferRef)aImage);
        if (bufferHeight == 0)
            return nil;
        if (HSTransitionViewLengthMatches(bufferWidth, _deviceSize.width) && HSTransitionViewLengthMatches(bufferHeight, _deviceSize.height))
            return aImage;
        source = CGEImageCreateWithPixelBuffer((CVPixelBufferRef)aImage, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
        [(id)source autorelease];
        if (source == NULL)
            return nil;
        break;
    }
    default:
        return nil;
    }
    CVPixelBufferPoolRef pool = [self HSTransitionView_pixelBufferPoolWithWidth:width height:height];
    if (pool == NULL)
        return nil;
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBuffer);
    if (pixelBuffer == NULL)
        return nil;
    CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
    if (context == NULL) {
        CVPixelBufferRelease(pixelBuffer);
        return nil;
    }
    CGContextClearRect(context, CGRectMake(0.0, 0.0, width, height));
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, _deviceSize.width, _deviceSize.height), source);
    CGContextRelease(context);
    CGImageRef image = CGEImageCreateWithPixelBuffer(pixelBuffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
    CVPixelBufferRelease(pixelBuffer);
    return [(id)image autorelease];
}

// A pool of BGRA buffers usable as bitmap contexts and images, recreated when
// the size changes.
- (struct __CVPixelBufferPool *)HSTransitionView_pixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight
{
    if (_pixelBufferPool != NULL) {
        NSDictionary *attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool);
        if ([[attributes objectForKey:(id)kCVPixelBufferWidthKey] unsignedLongValue] == aWidth &&
            [[attributes objectForKey:(id)kCVPixelBufferHeightKey] unsignedLongValue] == aHeight)
            return _pixelBufferPool;
        CVPixelBufferPoolRelease(_pixelBufferPool);
        _pixelBufferPool = NULL;
    }
    NSDictionary *attachments = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], kCVEPixelBufferAlphaInfoKey, nil];
    if (attachments == nil)
        return _pixelBufferPool;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
        [NSNumber numberWithUnsignedLong:aWidth], (id)kCVPixelBufferWidthKey,
        [NSNumber numberWithUnsignedLong:aHeight], (id)kCVPixelBufferHeightKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGImageCompatibilityKey,
        attachments, (id)kCVBufferNonPropagatedAttachmentsKey, nil];
    if (attributes != nil)
        CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef)attributes, &_pixelBufferPool);
    return _pixelBufferPool;
}

// Images not yet of device size have to be rescaled for both renderers.
- (void)HSTransitionView_invalidateImagesNotOfDeviceSizeWithPreviousFlags:(BOOL)aStartChangedForOpenGL quartz:(BOOL)aStartChangedForQuartz
{
    if (_startImageBuffer != nil && (!aStartChangedForOpenGL || !aStartChangedForQuartz) &&
        ![self HSTransitionView_isImageOfDeviceSize:_startImageBuffer]) {
        _isStartImageChangedForOpenGL = 1;
        _isStartImageChangedForQuartz = 1;
    }
    if (_endImageBuffer != nil && (!_isEndImageChangedForOpenGL || !_isEndImageChangedForQuartz) &&
        ![self HSTransitionView_isImageOfDeviceSize:_endImageBuffer]) {
        _isEndImageChangedForOpenGL = 1;
        _isEndImageChangedForQuartz = 1;
    }
}

- (void)setScalesImagesToFit:(BOOL)aFit
{
    if ((_scalesImagesToFit != 0) == (aFit != NO))
        return;
    BOOL startChangedForOpenGL = _isStartImageChangedForOpenGL, startChangedForQuartz = _isStartImageChangedForQuartz;
    _scalesImagesToFit = aFit != NO;
    [self HSTransitionView_invalidateImagesNotOfDeviceSizeWithPreviousFlags:startChangedForOpenGL quartz:startChangedForQuartz];
}

- (BOOL)scalesImagesToFit
{
    return _scalesImagesToFit;
}

- (void)setMaxRenderingFrameRate:(double)aRate
{
    [[self HSTransitionView_transitionPlayer] setMaxFPS:aRate];
}

- (double)maxRenderingFrameRate
{
    if ([self HSTransitionView_transitionPlayer] == nil)
        return 0.0;
    return [_transitionPlayer maxFPS];
}

- (void)setTransitionPlayRangeStartTime:(double)aTime duration:(double)aDuration
{
    [[self HSTransitionView_transitionPlayer] setTransitionPlayRangeStartTime:aTime duration:aDuration];
}

- (double)transitionPlayRangeDuration
{
    if ([self HSTransitionView_transitionPlayer] == nil)
        return 0.0;
    return [_transitionPlayer transitionPlayRangeDuration];
}

- (double)transitionPlayRangeStartTime
{
    if ([self HSTransitionView_transitionPlayer] == nil)
        return 0.0;
    return [_transitionPlayer transitionPlayRangeStartTime];
}

- (void)setTransitionDuration:(double)aDuration
{
    [(HSTransitionPlayer *)[self HSTransitionView_transitionPlayer] setDuration:aDuration];
}

- (double)transitionDuration
{
    if ([self HSTransitionView_transitionPlayer] == nil)
        return 0.0;
    return [_transitionPlayer duration];
}

- (void)setTransitionEffect:(id)aEffect
{
    if (_transitionEffect == aEffect)
        return;
    [aEffect retain];
    [_transitionEffect release];
    _transitionEffect = aEffect;
    [[self HSTransitionView_transitionPlayer] setTransitionEffect:aEffect];
    [self HSTransitionView_invalidateOpenGLTransitionRenderer];
    [self HSTransitionView_invalidateQuartzTransitionRenderer];
    [self HSTransitionView_synchronizeDeviceSizeChangesObserving];
    [self setNeedsDisplay:YES];
}

- (id)transitionEffect
{
    return _transitionEffect;
}

- (void)setBackgroundColor:(id)aColor
{
    if (_backgroundColor == aColor)
        return;
    [aColor retain];
    [_backgroundColor release];
    _backgroundColor = aColor;
    [self setNeedsDisplay:YES];
}

- (id)backgroundColor
{
    return _backgroundColor;
}

// The device size is the size of the bounds in window coordinates.
- (void)HSTransitionView_viewDidChangeDeviceSize:(id)aSize
{
    NSSize size = [self convertSize:[self bounds].size toView:nil];
    if ((float)size.width == _deviceSize.width && (float)size.height == _deviceSize.height)
        return;
    _deviceSize.width = (float)size.width;
    _deviceSize.height = (float)size.height;
    [_quartzTransitionRenderer setRendererSize:_deviceSize];
    if (_scalesImagesToFit)
        [self HSTransitionView_invalidateImagesNotOfDeviceSizeWithPreviousFlags:_isStartImageChangedForOpenGL quartz:_isStartImageChangedForQuartz];
}

- (BOOL)HSTransitionView_isImageOfDeviceSize:(id)aSize
{
    switch (HSTransitionViewKindOfImage(aSize)) {
    case HSTransitionViewImageKindCGImage:
        return HSTransitionViewLengthMatches(CGImageGetWidth((CGImageRef)aSize), _deviceSize.width) &&
               HSTransitionViewLengthMatches(CGImageGetHeight((CGImageRef)aSize), _deviceSize.height);
    case HSTransitionViewImageKindPixelBuffer:
        return HSTransitionViewLengthMatches(CVPixelBufferGetWidth((CVPixelBufferRef)aSize), _deviceSize.width) &&
               HSTransitionViewLengthMatches(CVPixelBufferGetHeight((CVPixelBufferRef)aSize), _deviceSize.height);
    default:
        return NO;
    }
}

- (void)HSTransitionView_invalidateQuartzTransitionRenderer
{
    [_quartzTransitionRenderer release];
    _quartzTransitionRenderer = nil;
    _isStartImageChangedForQuartz = _startImageBuffer != nil;
    _isEndImageChangedForQuartz = _endImageBuffer != nil;
}

- (id)HSTransitionView_quartzTransitionRenderer
{
    if (_quartzTransitionRenderer == nil && [self HSTransitionView_proxy] != nil) {
        if (!_areDeviceSizeChangesObserved) {
            NSSize size = [self convertSize:[self bounds].size toView:nil];
            _deviceSize.width = (float)size.width;
            _deviceSize.height = (float)size.height;
        }
        _quartzTransitionRenderer = [_transitionEffect createQuartzRendererForSize:_deviceSize];
        if (_quartzTransitionRenderer != nil && !_areDeviceSizeChangesObserved) {
            [self HSTransitionView_startDeviceSizeChangesObserving];
            _areDeviceSizeChangesObserved = 1;
        }
    }
    return _quartzTransitionRenderer;
}

- (void)HSTransitionView_invalidateOpenGLTransitionRenderer
{
    [_openGLTransitionRenderer release];
    _openGLTransitionRenderer = nil;
    _isStartImageChangedForOpenGL = _startImageBuffer != nil;
    _isEndImageChangedForOpenGL = _endImageBuffer != nil;
}

- (id)HSTransitionView_openGLTransitionRenderer
{
    if (_openGLTransitionRenderer == nil && [self HSTransitionView_proxy] != nil) {
        NSEOpenGLContext *context = [self openGLContext];
        if (context != nil) {
            _openGLTransitionRenderer = [_transitionEffect createOpenGLRendererForContext:context pixelFormat:[context format]];
            if (_openGLTransitionRenderer != nil && !_areDeviceSizeChangesObserved) {
                NSSize size = [self convertSize:[self bounds].size toView:nil];
                _deviceSize.width = (float)size.width;
                _deviceSize.height = (float)size.height;
                [self HSTransitionView_startDeviceSizeChangesObserving];
                _areDeviceSizeChangesObserved = 1;
            }
        }
    }
    return _openGLTransitionRenderer;
}

// Observes size changes only while there is an image or a renderer.
- (void)HSTransitionView_synchronizeDeviceSizeChangesObserving
{
    // Quirk kept: the end pixel buffer, not the end image, is checked.
    BOOL needed = _startImageBuffer != nil || _endPixelBuffer != NULL || _openGLTransitionRenderer != nil || _quartzTransitionRenderer != nil;
    if (!_areDeviceSizeChangesObserved) {
        if (needed && [self HSTransitionView_proxy] != nil) {
            NSSize size = [self convertSize:[self bounds].size toView:nil];
            _deviceSize.width = (float)size.width;
            _deviceSize.height = (float)size.height;
            [self HSTransitionView_startDeviceSizeChangesObserving];
            _areDeviceSizeChangesObserved = 1;
        }
    } else if (!needed) {
        [self HSTransitionView_stopDeviceSizeChangesObserving];
        _areDeviceSizeChangesObserved = 0;
    }
}

- (id)HSTransitionView_transitionPlayer
{
    if (_transitionPlayer == nil) {
        _transitionPlayer = [[HSTransitionPlayer alloc] init];
        [_transitionPlayer setDelegate:self];
    }
    return _transitionPlayer;
}

- (id)HSTransitionView_proxy
{
    if (_transitionViewProxy == nil)
        _transitionViewProxy = [self NSE_newWeakProxy];
    return _transitionViewProxy;
}

- (void)dealloc
{
    if (_areDeviceSizeChangesObserved)
        [self HSTransitionView_stopDeviceSizeChangesObserving];
    [[self class] NSE_invalidateWeakProxy:_transitionViewProxy];
    [_transitionViewProxy release];
    if ([_transitionPlayer isPlaying])
        [_transitionPlayer stop];
    [_transitionPlayer setDelegate:nil];
    [_transitionPlayer release];
    // As in the original, the OpenGL renderer is left to
    // disassociateOpenGLContext, which releases it with its context.
    [_quartzTransitionRenderer release];
    CVPixelBufferPoolRelease(_pixelBufferPool);
    CVPixelBufferRelease(_startPixelBuffer);
    [_startImageBuffer release];
    CVPixelBufferRelease(_endPixelBuffer);
    [_endImageBuffer release];
    [_transitionEffect release];
    [_backgroundColor release];
    if (_activeConsumers != NULL)
        CFRelease(_activeConsumers);
    [super dealloc];
}

- (void)HSTransitionView_stopDeviceSizeChangesObserving
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:_transitionViewProxy name:NSViewBoundsDidChangeNotification object:nil];
    [center removeObserver:_transitionViewProxy name:NSViewFrameDidChangeNotification object:self];
}

- (void)HSTransitionView_startDeviceSizeChangesObserving
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSView *view = self;
    do {
        [center addObserver:_transitionViewProxy selector:@selector(HSTransitionView_viewDidChangeDeviceSize:) name:NSViewBoundsDidChangeNotification object:view];
        view = [view superview];
    } while (view != nil);
    [center addObserver:_transitionViewProxy selector:@selector(HSTransitionView_viewDidChangeDeviceSize:) name:NSViewFrameDidChangeNotification object:self];
}

- (void)pause
{
    [_transitionPlayer pause];
}

- (void)resume
{
    [_transitionPlayer resume];
}

- (void)setTransitionPlaybackController:(id)aController
{
    [[self HSTransitionView_transitionPlayer] setTransitionPlaybackController:aController];
}

- (id)transitionPlaybackController
{
    return [[self HSTransitionView_transitionPlayer] transitionPlaybackController];
}

@end

@implementation NSObject (HSTransitionViewDelegate)

- (void)transitionViewDidFinishTransition:(id)aTransition
{
}

- (void)transitionViewDidStopTransition:(id)aTransition
{
}

@end
