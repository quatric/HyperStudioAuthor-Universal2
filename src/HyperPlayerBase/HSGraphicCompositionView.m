#import "HSGraphicCompositionView.h"
#import <OpenGL/gl.h>
#import "CGEBitmapContext.h"
#import "CGEImage.h"
#import "HSGraphicComposition.h"
#import "HSGraphicCompositionPlayer.h"
#import "HSFunctions.h"

// The attachment carrying the CGImage of a frame sent to capturing consumers.
static NSString * const HSPixelBufferCGImageAttachment = @"HSPixelBufferCGImage";

struct HSGraphicCompositionInputsApplier {
    CFDictionaryRef inputs;
    id<HSGraphicCompositionRenderer> renderer;
};

static void HSGraphicCompositionViewApplyInput(const void *aKey, void *aContext)
{
    struct HSGraphicCompositionInputsApplier *applier = aContext;
    [applier->renderer setValue:(id)CFDictionaryGetValue(applier->inputs, aKey) forInputKey:(id)aKey];
}

static void HSGraphicCompositionViewQueryInput(const void *aKey, void *aContext)
{
    HSGraphicCompositionView *view = aContext;
    [view setGraphicCompositionInputValue:[[view dataSource] graphicCompositionView:view graphicCompositionInputValueForKey:(id)aKey] forKey:(id)aKey];
}

static NSUInteger HSGraphicCompositionViewPixelCount(CGFloat aLength)
{
    return aLength > 0 ? lround(ceil(aLength)) : 0;
}

// Plays a graphic composition through its OpenGL renderer when it has one and
// the view is not being captured, otherwise through its Quartz renderer at the
// view's device size. Inputs come from the data source when invalidated and
// are handed to each renderer before it draws next. Capturing consumers
// receive every Quartz frame as a pixel buffer.
@implementation HSGraphicCompositionView

+ (id)createDefaultOpenGLContext
{
    NSOpenGLContext *context = [super createDefaultOpenGLContext];
    if (context) {
        GLint opacity = 0;
        [context setValues:&opacity forParameter:NSOpenGLCPSurfaceOpacity];
        GLint swapInterval = 1;
        [context setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
    }
    return context;
}

- (void)stopCapturingForConsumer:(id)aConsumer
{
    if (!_activeConsumers)
        return;
    NSUInteger count = (NSUInteger)CFDictionaryGetValue(_activeConsumers, aConsumer);
    if (count == 0)
        return;
    if (count == 1)
        CFDictionaryRemoveValue(_activeConsumers, aConsumer);
    else
        CFDictionarySetValue(_activeConsumers, aConsumer, (const void *)(count - 1));
}

// A playing composition sends the new consumer a frame right away.
- (void)startCapturingForConsumer:(id)aConsumer
{
    NSUInteger count;
    if (!_activeConsumers) {
        _activeConsumers = CFDictionaryCreateMutable(NULL, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (!_activeConsumers)
            return;
        count = 1;
    } else {
        count = (NSUInteger)CFDictionaryGetValue(_activeConsumers, aConsumer) + 1;
    }
    CFDictionarySetValue(_activeConsumers, aConsumer, (const void *)count);
    if (CFDictionaryGetCount(_activeConsumers) <= 0)
        return;
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    if (_deviceSize.width == 0 || _deviceSize.height == 0 || ![self HSGraphicCompositionView_quartzGraphicCompositionRenderer] || ![_graphicCompositionPlayer isPlaying])
        return;
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferPoolRef pool = [self HSGraphicCompositionView_pixelBufferPoolWithWidth:HSGraphicCompositionViewPixelCount(_deviceSize.width) height:HSGraphicCompositionViewPixelCount(_deviceSize.height)];
    CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &pixelBuffer);
    if (!pixelBuffer)
        return;
    CGContextRef context = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
    if (context) {
        CGContextClearRect(context, CGRectMake(0, 0, CGBitmapContextGetWidth(context), CGBitmapContextGetHeight(context)));
        [_quartzGraphicCompositionRenderer renderFrameAtTime:[self renderingTime] inCoreGraphicsContext:context];
        CGContextRelease(context);
        [self HSGraphicCompositionView_sendFrame:pixelBuffer withTime:time];
    }
    // The original leaked the buffer when no context could be made.
    CVPixelBufferRelease(pixelBuffer);
}

- (void)mouseDown:(NSEvent *)aDown
{
    if (_stopsOnMouseClick) {
        if ([_graphicCompositionPlayer isPlaying])
            [self stopRendering];
    } else {
        [super mouseDown:aDown];
    }
}

- (void)drawQuartzSurfaceRect:(NSRect)aRect
{
    [self drawBackgroundRect:aRect];
    if (_openGLGraphicCompositionRenderer || ![self HSGraphicCompositionView_quartzGraphicCompositionRenderer])
        return;
    if ([_invalidatedGraphicCompositionInputKeys count])
        [self HSGraphicCompositionView_queryGraphicCompositionInputs];
    if ([_pendingGraphicCompositionInputKeysForQuartzRenderer count]) {
        struct HSGraphicCompositionInputsApplier applier = { _graphicCompositionInputs, _quartzGraphicCompositionRenderer };
        CFSetApplyFunction((CFSetRef)_pendingGraphicCompositionInputKeysForQuartzRenderer, HSGraphicCompositionViewApplyInput, &applier);
        [_pendingGraphicCompositionInputKeysForQuartzRenderer removeAllObjects];
    }
    [self drawQuartzFrameRect:aRect];
}

- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect
{
    if (![self HSGraphicCompositionView_openGLGraphicCompositionRenderer])
        return NO;
    if ([_invalidatedGraphicCompositionInputKeys count])
        [self HSGraphicCompositionView_queryGraphicCompositionInputs];
    if ([_pendingGraphicCompositionInputKeysForOpenGLRenderer count]) {
        struct HSGraphicCompositionInputsApplier applier = { _graphicCompositionInputs, _openGLGraphicCompositionRenderer };
        CFSetApplyFunction((CFSetRef)_pendingGraphicCompositionInputKeysForOpenGLRenderer, HSGraphicCompositionViewApplyInput, &applier);
        [_pendingGraphicCompositionInputKeysForOpenGLRenderer removeAllObjects];
    }
    glClearColor(0, 0, 0, 0);
    glClearDepth(1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self drawOpenGLFrame];
    return YES;
}

- (void)HSGraphicCompositionView_queryGraphicCompositionInputs
{
    CFSetApplyFunction((CFSetRef)_invalidatedGraphicCompositionInputKeys, HSGraphicCompositionViewQueryInput, self);
    [_invalidatedGraphicCompositionInputKeys removeAllObjects];
}

// While captured, the frame is rendered into a pixel buffer that goes to the
// consumers first and is then drawn into the view.
- (void)drawQuartzFrameRect:(NSRect)aRect
{
    if (_deviceSize.width == 0 || _deviceSize.height == 0)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    if (!context)
        return;
    NSRect bounds = [self bounds];
    CGContextScaleCTM(context, bounds.size.width / _deviceSize.width, bounds.size.height / _deviceSize.height);
    if (!_activeConsumers || CFDictionaryGetCount(_activeConsumers) < 1) {
        [_quartzGraphicCompositionRenderer renderFrameAtTime:[self renderingTime] inCoreGraphicsContext:context];
        return;
    }
    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferPoolRef pool = [self HSGraphicCompositionView_pixelBufferPoolWithWidth:HSGraphicCompositionViewPixelCount(_deviceSize.width) height:HSGraphicCompositionViewPixelCount(_deviceSize.height)];
    CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &pixelBuffer);
    if (!pixelBuffer)
        return;
    CGContextRef bitmapContext = CGEBitmapContextCreateWithPixelBuffer(pixelBuffer, 0);
    if (bitmapContext) {
        CGContextClearRect(bitmapContext, CGRectMake(0, 0, CGBitmapContextGetWidth(bitmapContext), CGBitmapContextGetHeight(bitmapContext)));
        [_quartzGraphicCompositionRenderer renderFrameAtTime:[self renderingTime] inCoreGraphicsContext:bitmapContext];
        CGContextRelease(bitmapContext);
        CGImageRef image = CGEImageCreateWithPixelBuffer(pixelBuffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
        if (image) {
            CVBufferSetAttachment(pixelBuffer, (CFStringRef)HSPixelBufferCGImageAttachment, image, kCVAttachmentMode_ShouldNotPropagate);
            [self HSGraphicCompositionView_sendFrame:pixelBuffer withTime:time];
            CVBufferRemoveAttachment(pixelBuffer, (CFStringRef)HSPixelBufferCGImageAttachment);
            CVPixelBufferRelease(pixelBuffer);
            CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
            CGImageRelease(image);
            return;
        }
    }
    CVPixelBufferRelease(pixelBuffer);
}

- (void)drawOpenGLFrame
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    [_openGLGraphicCompositionRenderer renderFrameAtTime:[self renderingTime]];
}

- (void)drawBackgroundRect:(NSRect)aRect
{
    if (_backgroundColor) {
        [_backgroundColor set];
        NSRectFill(aRect);
    }
}

- (void)graphicCompositionPlayerDidPlayNewFrame:(id)aFrame
{
    if (_graphicCompositionPlayer == aFrame && ![self displayOpenGLSurface])
        [self display];
}

- (void)changeOpenGLSurfaceViewportFrom:(int *)aFrom to:(int *)aTo
{
    [self HSGraphicCompositionView_invalidateOpenGLGraphicCompositionRenderer];
    [super changeOpenGLSurfaceViewportFrom:aFrom to:aTo];
}

- (void)disassociateOpenGLContext
{
    [self HSGraphicCompositionView_invalidateOpenGLGraphicCompositionRenderer];
    [super disassociateOpenGLContext];
}

// Captured frames need the Quartz renderer.
- (BOOL)shouldDisplayOpenGLSurface
{
    if (![_graphicComposition hasOpenGLRenderer])
        return NO;
    return !_activeConsumers || CFDictionaryGetCount(_activeConsumers) < 1;
}

// One pool of BGRA buffers, remade when the size changes.
- (struct __CVPixelBufferPool *)HSGraphicCompositionView_pixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight
{
    if (_pixelBufferPool) {
        NSDictionary *attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool);
        if ([[attributes objectForKey:(id)kCVPixelBufferWidthKey] unsignedLongValue] == aWidth
            && [[attributes objectForKey:(id)kCVPixelBufferHeightKey] unsignedLongValue] == aHeight)
            return _pixelBufferPool;
        CVPixelBufferPoolRelease(_pixelBufferPool);
        _pixelBufferPool = NULL;
    }
    NSDictionary *nonPropagated = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], (id)kCVEPixelBufferAlphaInfoKey, nil];
    if (!nonPropagated)
        return _pixelBufferPool;
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
        [NSNumber numberWithUnsignedLong:aWidth], (id)kCVPixelBufferWidthKey,
        [NSNumber numberWithUnsignedLong:aHeight], (id)kCVPixelBufferHeightKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey,
        (id)kCFBooleanTrue, (id)kCVPixelBufferCGImageCompatibilityKey,
        nonPropagated, (id)kCVBufferNonPropagatedAttachmentsKey, nil];
    if (attributes)
        CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef)attributes, &_pixelBufferPool);
    return _pixelBufferPool;
}

// The bounds of every view up the hierarchy are observed again for the new
// window.
- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if (!_areDeviceSizeChangesObserved)
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:_graphicCompositionViewProxy name:NSViewBoundsDidChangeNotification object:nil];
    for (NSView *view = self; view; view = [view superview])
        [center addObserver:_graphicCompositionViewProxy selector:@selector(HSGraphicCompositionView_viewDidChangeDeviceSize:) name:NSViewBoundsDidChangeNotification object:view];
}

- (BOOL)isOpaque
{
    if (!_backgroundColor || [[_backgroundColor colorSpaceName] isEqualToString:NSPatternColorSpace])
        return NO;
    return [_backgroundColor alphaComponent] >= 0.9980392156862745;
}

- (void)graphicCompositionPlayerDidFinish:(id)aFinish
{
    if (_graphicCompositionPlayer == aFinish)
        [_delegate graphicCompositionViewDidFinishRendering:self];
}

- (void)setRenderingTime:(double)aTime
{
    [[self HSGraphicCompositionView_graphicCompositionPlayer] setPlayTime:aTime];
}

- (double)renderingTime
{
    if (![self HSGraphicCompositionView_graphicCompositionPlayer])
        return 0;
    return [_graphicCompositionPlayer playTime];
}

- (BOOL)isRendering
{
    return [_graphicCompositionPlayer isPlaying];
}

- (void)stopRendering
{
    [_graphicCompositionPlayer stop];
    [_delegate graphicCompositionViewDidStopRendering:self];
}

// A player that fails to start is rewound; either way the current frame is
// shown.
- (BOOL)startRendering
{
    BOOL started = [[self HSGraphicCompositionView_graphicCompositionPlayer] start];
    if (!started)
        [_graphicCompositionPlayer setPlayTime:0];
    [self graphicCompositionPlayerDidPlayNewFrame:_graphicCompositionPlayer];
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

- (id)graphicCompositionInputValueForKey:(id)aKey
{
    if (!_graphicCompositionInputs)
        return nil;
    return (id)CFDictionaryGetValue(_graphicCompositionInputs, aKey);
}

- (void)setGraphicCompositionInputValue:(id)aValue forKey:(id)aKey
{
    if (!_graphicCompositionInputs) {
        _graphicCompositionInputs = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &HSCFTypeOrNullCFDictionaryValueCallBacks);
        if (!_graphicCompositionInputs)
            return;
    }
    CFDictionarySetValue(_graphicCompositionInputs, aKey, aValue);
    [self HSGraphicCompositionView_graphicCompositionInputDidChangeForKey:aKey];
}

- (void)HSGraphicCompositionView_graphicCompositionInputDidChangeForKey:(id)aKey
{
    if (!_pendingGraphicCompositionInputKeysForOpenGLRenderer)
        _pendingGraphicCompositionInputKeysForOpenGLRenderer = [[NSMutableSet alloc] init];
    [_pendingGraphicCompositionInputKeysForOpenGLRenderer addObject:aKey];
    if (!_pendingGraphicCompositionInputKeysForQuartzRenderer)
        _pendingGraphicCompositionInputKeysForQuartzRenderer = [[NSMutableSet alloc] init];
    [_pendingGraphicCompositionInputKeysForQuartzRenderer addObject:aKey];
}

- (void)invalidateGraphicCompositionInputForKey:(id)aKey
{
    if (!_invalidatedGraphicCompositionInputKeys)
        _invalidatedGraphicCompositionInputKeys = [[NSMutableSet alloc] init];
    [_invalidatedGraphicCompositionInputKeys addObject:aKey];
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (id)dataSource
{
    return _dataSource;
}

- (void)setGraphicComposition:(id)aComposition
{
    if (_graphicComposition == aComposition)
        return;
    [aComposition retain];
    [_graphicComposition release];
    _graphicComposition = aComposition;
    [[self HSGraphicCompositionView_graphicCompositionPlayer] setGraphicComposition:aComposition];
    [self HSGraphicCompositionView_invalidateOpenGLGraphicCompositionRenderer];
    [self HSGraphicCompositionView_invalidateQuartzGraphicCompositionRenderer];
    [self setNeedsDisplay:YES];
}

- (id)graphicComposition
{
    return _graphicComposition;
}

- (void)setStopsOnMouseClick:(BOOL)aClick
{
    _stopsOnMouseClick = aClick;
}

- (BOOL)stopsOnMouseClick
{
    return _stopsOnMouseClick;
}

- (void)setMaxRenderingFrameRate:(double)aRate
{
    [[self HSGraphicCompositionView_graphicCompositionPlayer] setMaxFPS:aRate];
}

- (double)maxRenderingFrameRate
{
    if (![self HSGraphicCompositionView_graphicCompositionPlayer])
        return 0;
    return [_graphicCompositionPlayer maxFPS];
}

- (void)setRenderingDuration:(double)aDuration
{
    [[self HSGraphicCompositionView_graphicCompositionPlayer] setDuration:aDuration];
}

- (double)renderingDuration
{
    if (![self HSGraphicCompositionView_graphicCompositionPlayer])
        return 0;
    return [_graphicCompositionPlayer duration];
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

// Consumers removed by an earlier one's callback are skipped.
- (void)HSGraphicCompositionView_sendFrame:(struct __CVBuffer *)aFrame withTime:(double)aTime
{
    CFIndex count = CFDictionaryGetCount(_activeConsumers);
    if (count == 0)
        return;
    if (count == 1) {
        const void *consumer = NULL;
        CFDictionaryGetKeysAndValues(_activeConsumers, &consumer, NULL);
        [(id)consumer capturingDataSource:self didOutputFrame:aFrame atTime:aTime];
        return;
    }
    const void **consumers = malloc(count * sizeof(*consumers));
    if (!consumers)
        return;
    CFDictionaryGetKeysAndValues(_activeConsumers, consumers, NULL);
    for (; count != 0; count--) {
        if (CFDictionaryGetValue(_activeConsumers, consumers[count - 1]))
            [(id)consumers[count - 1] capturingDataSource:self didOutputFrame:aFrame atTime:aTime];
    }
    free(consumers);
}

- (void)HSGraphicCompositionView_viewDidChangeDeviceSize:(id)aSize
{
    NSSize size = [self convertSize:[self bounds].size toView:nil];
    if (size.width != _deviceSize.width || size.height != _deviceSize.height) {
        _deviceSize = size;
        [_quartzGraphicCompositionRenderer setRendererSize:size];
    }
}

- (void)HSGraphicCompositionView_invalidateQuartzGraphicCompositionRenderer
{
    [_quartzGraphicCompositionRenderer release];
    _quartzGraphicCompositionRenderer = nil;
    if (_areDeviceSizeChangesObserved) {
        [self HSGraphicCompositionView_stopDeviceSizeChangesObserving];
        _areDeviceSizeChangesObserved = NO;
    }
}

// Made at the view's size in device space, which is then tracked.
- (id)HSGraphicCompositionView_quartzGraphicCompositionRenderer
{
    if (!_quartzGraphicCompositionRenderer && [self HSGraphicCompositionView_proxy]) {
        if (!_areDeviceSizeChangesObserved)
            _deviceSize = [self convertSize:[self bounds].size toView:nil];
        _quartzGraphicCompositionRenderer = [_graphicComposition createQuartzRendererForSize:_deviceSize];
        if (_quartzGraphicCompositionRenderer && !_areDeviceSizeChangesObserved) {
            [self HSGraphicCompositionView_startDeviceSizeChangesObserving];
            _areDeviceSizeChangesObserved = YES;
        }
    }
    return _quartzGraphicCompositionRenderer;
}

- (void)HSGraphicCompositionView_invalidateOpenGLGraphicCompositionRenderer
{
    [_openGLGraphicCompositionRenderer release];
    _openGLGraphicCompositionRenderer = nil;
}

- (id)HSGraphicCompositionView_openGLGraphicCompositionRenderer
{
    if (!_openGLGraphicCompositionRenderer) {
        NSEOpenGLContext *context = [self openGLContext];
        if (context)
            _openGLGraphicCompositionRenderer = [_graphicComposition createOpenGLRendererForContext:context pixelFormat:[context format]];
    }
    return _openGLGraphicCompositionRenderer;
}

- (HSGraphicCompositionPlayer *)HSGraphicCompositionView_graphicCompositionPlayer
{
    if (!_graphicCompositionPlayer) {
        _graphicCompositionPlayer = [[HSGraphicCompositionPlayer alloc] init];
        [_graphicCompositionPlayer setDelegate:self];
    }
    return _graphicCompositionPlayer;
}

- (id)HSGraphicCompositionView_proxy
{
    if (!_graphicCompositionViewProxy)
        _graphicCompositionViewProxy = [self NSE_newWeakProxy];
    return _graphicCompositionViewProxy;
}

// The OpenGL renderer goes with the context, when super disassociates it.
- (void)dealloc
{
    if (_areDeviceSizeChangesObserved)
        [self HSGraphicCompositionView_stopDeviceSizeChangesObserving];
    [[self class] NSE_invalidateWeakProxy:_graphicCompositionViewProxy];
    [_graphicCompositionViewProxy release];
    if ([_graphicCompositionPlayer isPlaying])
        [_graphicCompositionPlayer stop];
    [_graphicCompositionPlayer setDelegate:nil];
    [_graphicCompositionPlayer release];
    [_quartzGraphicCompositionRenderer release];
    [_invalidatedGraphicCompositionInputKeys release];
    if (_graphicCompositionInputs)
        CFRelease(_graphicCompositionInputs);
    [_pendingGraphicCompositionInputKeysForQuartzRenderer release];
    [_pendingGraphicCompositionInputKeysForOpenGLRenderer release];
    [_graphicComposition release];
    [_backgroundColor release];
    if (_activeConsumers)
        CFRelease(_activeConsumers);
    CVPixelBufferPoolRelease(_pixelBufferPool);
    [super dealloc];
}

- (void)HSGraphicCompositionView_stopDeviceSizeChangesObserving
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:_graphicCompositionViewProxy name:NSViewBoundsDidChangeNotification object:nil];
    [center removeObserver:_graphicCompositionViewProxy name:NSViewFrameDidChangeNotification object:self];
}

// Bounds changes anywhere up the hierarchy and frame changes of the view
// itself can change the device size.
- (void)HSGraphicCompositionView_startDeviceSizeChangesObserving
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (NSView *view = self; view; view = [view superview])
        [center addObserver:_graphicCompositionViewProxy selector:@selector(HSGraphicCompositionView_viewDidChangeDeviceSize:) name:NSViewBoundsDidChangeNotification object:view];
    [center addObserver:_graphicCompositionViewProxy selector:@selector(HSGraphicCompositionView_viewDidChangeDeviceSize:) name:NSViewFrameDidChangeNotification object:self];
}

@end

@implementation NSObject (HSGraphicCompositionViewDelegate)

- (void)graphicCompositionViewDidFinishRendering:(id)aRendering
{
}

- (void)graphicCompositionViewDidStopRendering:(id)aRendering
{
}

@end
