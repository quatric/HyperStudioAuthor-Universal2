#import "HSQCGraphicComposition.h"
#import "HSSystem.h"
#import "CGEImage.h"
#import "CVEPixelBuffer.h"
#import "NSEOpenGLContext.h"
#import "SMKApplicationKitData.h"

static void HSApplyRendererInput(const void *aKey, const void *aValue, void *aContext)
{
    [(HSOpenGLQCGraphicCompositionRenderer *)aContext setValue:(id)aValue forInputKey:(id)aKey];
}

// Frees a pixel buffer locked for the bytes it shares.
static void HSReleaseLockedPixelBuffer(void *aInfo, const void *aData, size_t aSize)
{
    CVPixelBufferUnlockBaseAddress(aInfo, 0);
    CVPixelBufferRelease(aInfo);
}

static void HSReleaseLockedPixelBufferBytes(void *aRefCon, const void *aBaseAddress)
{
    CVPixelBufferUnlockBaseAddress(aRefCon, 0);
    CVPixelBufferRelease(aRefCon);
}

// A Quartz Composer composition, held as a composition where the Quartz
// Composer API has QCComposition and as a file path before.
@implementation HSQCGraphicComposition

+ (id)compositionWithQuartzComposerComposition:(id)aComposition
{
    return [[[HSQCGraphicComposition_Leopard alloc] initWithQuartzComposerComposition:aComposition] autorelease];
}

+ (id)compositionWithCompositionFilePath:(id)aPath
{
    Class compositionClass = NSClassFromString(@"QCComposition");
    if (!compositionClass)
        return [[[HSQCGraphicComposition_Tiger alloc] initWithCompositionFilePath:aPath] autorelease];
    id composition = [compositionClass performSelector:@selector(compositionWithFile:) withObject:aPath];
    if (!composition)
        return nil;
    return [[[HSQCGraphicComposition_Leopard alloc] initWithQuartzComposerComposition:composition] autorelease];
}

@end

@implementation HSQCGraphicComposition_Leopard

- (id)createQuartzRendererForSize:(CGSize)aSize
{
    return [[HSQuartzQCGraphicCompositionRenderer alloc] initWithSize:aSize quartzComposerComposition:_quartzComposerComposition];
}

- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat
{
    return [[HSOpenGLQCGraphicCompositionRenderer alloc] initWithOpenGLContext:aContext pixelFormat:aFormat quartzComposerComposition:_quartzComposerComposition];
}

- (BOOL)hasOpenGLRenderer
{
    return YES;
}

- (BOOL)hasQuartzRenderer
{
    return YES;
}

- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2
{
    return aTime != aTime2;
}

- (BOOL)isSlow
{
    return ![[HSSystem sharedSystem] isCoreImageAccelerated];
}

- (id)quartzComposerComposition
{
    return _quartzComposerComposition;
}

- (NSUInteger)hash
{
    return [_quartzComposerComposition hash];
}

- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSQCGraphicComposition_Leopard class]])
        return NO;
    if (![aEqual isMemberOfClass:[self class]] && [aEqual isKindOfClass:[self class]])
        return [aEqual isEqual:self];
    return [_quartzComposerComposition isEqual:[aEqual quartzComposerComposition]];
}

- (void)dealloc
{
    [_quartzComposerComposition release];
    [super dealloc];
}

- (id)initWithQuartzComposerComposition:(id)aComposition
{
    self = [super init];
    if (self)
        _quartzComposerComposition = [aComposition retain];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

@implementation HSQCGraphicComposition_Tiger

- (id)createQuartzRendererForSize:(CGSize)aSize
{
    return [[HSQuartzQCGraphicCompositionRenderer alloc] initWithSize:aSize compositionFilePath:_compositionFilePath];
}

- (id)createOpenGLRendererForContext:(id)aContext pixelFormat:(id)aFormat
{
    return [[HSOpenGLQCGraphicCompositionRenderer alloc] initWithOpenGLContext:aContext pixelFormat:aFormat compositionFilePath:_compositionFilePath];
}

- (BOOL)hasOpenGLRenderer
{
    return YES;
}

- (BOOL)hasQuartzRenderer
{
    return YES;
}

- (BOOL)isNewFrameAtTime:(double)aTime relativeToTime:(double)aTime2
{
    return aTime != aTime2;
}

- (BOOL)isSlow
{
    return ![[HSSystem sharedSystem] isCoreImageAccelerated];
}

- (id)compositionFilePath
{
    return _compositionFilePath;
}

- (NSUInteger)hash
{
    return [_compositionFilePath hash];
}

- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSQCGraphicComposition_Tiger class]])
        return NO;
    if (![aEqual isMemberOfClass:[self class]] && [aEqual isKindOfClass:[self class]])
        return [aEqual isEqual:self];
    return [_compositionFilePath isEqualToString:[aEqual compositionFilePath]];
}

- (void)dealloc
{
    [_compositionFilePath release];
    [super dealloc];
}

- (id)initWithCompositionFilePath:(id)aPath
{
    self = [super init];
    if (self) {
        _compositionFilePath = [aPath copy];
        if (!_compositionFilePath) {
            [self release];
            return nil;
        }
    }
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end

// Renders a composition through OpenGL in an offscreen window, reading each
// frame back into a pixel buffer drawn as an image. Inputs set are kept to
// set again on an OpenGL renderer made after a size change.
@implementation HSQuartzQCGraphicCompositionRenderer

// Only without an offscreen window, which the renderer always has.
- (struct CGImage *)frameImageAtTime:(double)aTime
{
    if (_offscreenWindow)
        return NULL;
    return (CGImageRef)[(id)[self HSQuartzQCGraphicCompositionRenderer_createFrameImageAtTime:aTime] autorelease];
}

// Frames read from the window are bottom up.
- (void)renderFrameAtTime:(double)aTime inCoreGraphicsContext:(struct CGContext *)aContext
{
    CGImageRef image = [self HSQuartzQCGraphicCompositionRenderer_createFrameImageAtTime:aTime];
    if (!image)
        return;
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    if (_offscreenWindow)
        CGContextConcatCTM(aContext, CGAffineTransformMake(1, 0, 0, -1, 0, height));
    CGContextDrawImage(aContext, CGRectMake(0, 0, width, height), image);
    CGImageRelease(image);
}

- (struct CGImage *)HSQuartzQCGraphicCompositionRenderer_createFrameImageAtTime:(double)aTime
{
    unsigned long width = _size.width > 0 ? lroundf(ceilf(_size.width)) : 0;
    unsigned long height = _size.height > 0 ? lroundf(ceilf(_size.height)) : 0;
    BOOL isResized = NO;
    if (_isSizeChanged) {
        NSDictionary *attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool);
        unsigned long poolWidth = [[attributes objectForKey:(id)kCVPixelBufferWidthKey] unsignedLongValue];
        unsigned long poolHeight = [[attributes objectForKey:(id)kCVPixelBufferHeightKey] unsignedLongValue];
        if (width != poolWidth || height != poolHeight) {
            NSNumber *newWidth = nil;
            NSNumber *newHeight = nil;
            if (width != poolWidth) {
                newWidth = [NSNumber numberWithUnsignedLong:width];
                if (!newWidth)
                    return NULL;
            }
            if (height != poolHeight) {
                newHeight = [NSNumber numberWithUnsignedLong:height];
                if (!newHeight)
                    return NULL;
            }
            CFMutableDictionaryRef newAttributes = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, CFDictionaryGetCount((CFDictionaryRef)attributes), (CFDictionaryRef)attributes);
            if (!newAttributes)
                return NULL;
            if (newWidth)
                CFDictionarySetValue(newAttributes, kCVPixelBufferWidthKey, newWidth);
            if (newHeight)
                CFDictionarySetValue(newAttributes, kCVPixelBufferHeightKey, newHeight);
            CVPixelBufferPoolRef pool = NULL;
            CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, newAttributes, &pool);
            CFRelease(newAttributes);
            if (!pool)
                return NULL;
            CVPixelBufferPoolRelease(_pixelBufferPool);
            _pixelBufferPool = pool;
            [_openGLRenderer release];
            _openGLRenderer = nil;
            if (_offscreenWindow) {
                [_offscreenWindow setContentSize:NSMakeSize(width, height)];
                [_openGLContext update];
                isResized = YES;
            }
        }
        _isSizeChanged = NO;
    }
    if (!_pixelBufferPool)
        return NULL;
    CVPixelBufferRef buffer = NULL;
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _pixelBufferPool, &buffer);
    if (!buffer)
        return NULL;
    GLint rowLength = 0;
    GLint alignment = 0;
    if (!CVEPixelBufferGetOpenGLRowLengthAndAlignment(buffer, &rowLength, &alignment) || CVPixelBufferLockBaseAddress(buffer, 0) != kCVReturnSuccess) {
        CVPixelBufferRelease(buffer);
        return NULL;
    }
    void *baseAddress = CVPixelBufferGetBaseAddress(buffer);
    if (!_offscreenWindow)
        [(id)_openGLContext setOffScreen:baseAddress width:width height:height rowbytes:CVPixelBufferGetBytesPerRow(buffer)];
    NSOpenGLContext *previousContext = [NSOpenGLContext currentContext];
    if (previousContext != _openGLContext) {
        [previousContext retain];
        [_openGLContext makeCurrentContext];
    }
    if (isResized)
        glViewport(0, 0, (GLsizei)width, (GLsizei)height);
    if (!_openGLRenderer) {
        _openGLRenderer = [self HSQuartzQCGraphicCompositionRenderer_createOpenGLRenderer];
        if (!_openGLRenderer) {
            CVPixelBufferUnlockBaseAddress(buffer, 0);
            CVPixelBufferRelease(buffer);
            return NULL;
        }
        if (_inputs)
            CFDictionaryApplyFunction(_inputs, HSApplyRendererInput, _openGLRenderer);
    }
    glClearColor(0, 0, 0, 0);
    glClearDepth(1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [_openGLRenderer renderFrameAtTime:aTime];
    GLint isDoubleBuffered = 0;
    [[_openGLContext pixelFormat] getValues:&isDoubleBuffered forAttribute:NSOpenGLPFADoubleBuffer forVirtualScreen:[_openGLContext currentVirtualScreen]];
    if (isDoubleBuffered)
        [_openGLContext flushBuffer];
    else
        glFlush();
    if (_offscreenWindow) {
        GLint previousRowLength = 0;
        glGetIntegerv(GL_PACK_ROW_LENGTH, &previousRowLength);
        GLint previousAlignment = 0;
        glGetIntegerv(GL_PACK_ALIGNMENT, &previousAlignment);
        if (rowLength != previousRowLength)
            glPixelStorei(GL_PACK_ROW_LENGTH, rowLength);
        if (alignment != previousAlignment)
            glPixelStorei(GL_PACK_ALIGNMENT, alignment);
        glReadPixels(0, 0, (GLsizei)width, (GLsizei)height, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, baseAddress);
        if (alignment != previousAlignment)
            glPixelStorei(GL_PACK_ALIGNMENT, previousAlignment);
        if (rowLength != previousRowLength)
            glPixelStorei(GL_PACK_ROW_LENGTH, previousRowLength);
    }
    if (previousContext && previousContext != _openGLContext) {
        [previousContext makeCurrentContext];
        [previousContext release];
    } else {
        [NSOpenGLContext clearCurrentContext];
    }
    if (!_offscreenWindow)
        [_openGLContext clearDrawable];
    // The provider keeps the buffer locked until the image goes.
    CGDataProviderRef provider = CGDataProviderCreateWithData(buffer, baseAddress, CVPixelBufferGetDataSize(buffer), HSReleaseLockedPixelBuffer);
    if (!provider) {
        CVPixelBufferUnlockBaseAddress(buffer, 0);
        CVPixelBufferRelease(buffer);
        return NULL;
    }
    CGImageRef image = CGEImageCreateAsPixelBuffer(buffer, provider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    return image;
}

- (id)valueForOutputKey:(id)aKey
{
    return [_openGLRenderer valueForOutputKey:aKey];
}

- (id)valueForInputKey:(id)aKey
{
    return [_openGLRenderer valueForInputKey:aKey];
}

- (BOOL)setValue:(id)aValue forInputKey:(id)aKey
{
    if (!_inputs) {
        _inputs = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &HSCFTypeOrNullCFDictionaryValueCallBacks);
        if (!_inputs)
            return NO;
    }
    if (![_openGLRenderer setValue:aValue forInputKey:aKey])
        return NO;
    CFDictionarySetValue(_inputs, aKey, aValue);
    return YES;
}

- (id)outputKeys
{
    return [_openGLRenderer outputKeys];
}

- (id)inputKeys
{
    return [_openGLRenderer inputKeys];
}

- (void)setRendererSize:(CGSize)aSize
{
    if (_size.width != aSize.width || _size.height != aSize.height) {
        _size = aSize;
        _isSizeChanged = YES;
    }
}

- (CGSize)rendererSize
{
    return _size;
}

- (void)dealloc
{
    [_openGLRenderer release];
    if (_offscreenWindow) {
        [_openGLContext clearDrawable];
        [_offscreenWindow release];
    }
    [_openGLContext release];
    CVPixelBufferPoolRelease(_pixelBufferPool);
    if (_inputs)
        CFRelease(_inputs);
    [_compositionReference release];
    [super dealloc];
}

- (id)initWithSize:(CGSize)aSize quartzComposerComposition:(id)aComposition
{
    self = [super init];
    if (!self)
        return nil;
    if ([self HSQuartzQCGraphicCompositionRenderer_preinitWithSize:aSize]) {
        _compositionReference = [aComposition retain];
        _openGLRenderer = [[HSOpenGLQCGraphicCompositionRenderer alloc] initWithOpenGLContext:_openGLContext pixelFormat:[_openGLContext pixelFormat] quartzComposerComposition:_compositionReference];
        if (_openGLRenderer)
            return self;
    }
    [self release];
    return nil;
}

- (id)initWithSize:(CGSize)aSize compositionFilePath:(id)aPath
{
    self = [super init];
    if (!self)
        return nil;
    if ([self HSQuartzQCGraphicCompositionRenderer_preinitWithSize:aSize]) {
        _compositionReference = [aPath copy];
        if (_compositionReference) {
            _openGLRenderer = [[HSOpenGLQCGraphicCompositionRenderer alloc] initWithOpenGLContext:_openGLContext pixelFormat:[_openGLContext pixelFormat] compositionFilePath:_compositionReference];
            if (_openGLRenderer)
                return self;
        }
    }
    [self release];
    return nil;
}

// A window context, multisampled if it can be, drawing in a borderless
// window of the size, and a pool of BGRA buffers to read frames into.
- (BOOL)HSQuartzQCGraphicCompositionRenderer_preinitWithSize:(CGSize)aSize
{
    unsigned int attributes[] = {
        NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, NSOpenGLPFASampleBuffers, 1, NSOpenGLPFASamples, 6, 0,
        NSOpenGLPFAWindow, NSOpenGLPFAAccelerated, 0,
        NSOpenGLPFAWindow, 0,
        0
    };
    NSOpenGLPixelFormat *format = [NSOpenGLPixelFormat NSE_pixelFormatWithAttributesSequence:attributes];
    if (!format)
        return NO;
    _openGLContext = [[NSEOpenGLContext contextWithFormat:format shareCategory:NSEDefaultOpenGLContextShareCategory] retain];
    if (!_openGLContext)
        return NO;
    // The original asked for a nonretained backing store, which is no
    // longer supported.
    _offscreenWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, aSize.width, aSize.height) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    if (!_offscreenWindow)
        return NO;
    [_offscreenWindow setReleasedWhenClosed:NO];
    NSView *contentView = [_offscreenWindow contentView];
    if (!contentView)
        return NO;
    [_openGLContext setView:contentView];
    if ([_openGLContext view] != contentView)
        return NO;
    NSDictionary *attachments = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], kCVEPixelBufferAlphaInfoKey, nil];
    if (!attachments)
        return NO;
    unsigned long height = aSize.height > 0 ? lroundf(ceilf(aSize.height)) : 0;
    NSNumber *heightNumber = [NSNumber numberWithUnsignedLong:height];
    unsigned long width = aSize.width > 0 ? lroundf(ceilf(aSize.width)) : 0;
    NSNumber *widthNumber = [NSNumber numberWithUnsignedLong:width];
    NSDictionary *bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                                      widthNumber, kCVPixelBufferWidthKey,
                                      heightNumber, kCVPixelBufferHeightKey,
                                      kCFBooleanTrue, kCVPixelBufferCGImageCompatibilityKey,
                                      kCFBooleanTrue, kCVPixelBufferOpenGLCompatibilityKey,
                                      attachments, kCVBufferNonPropagatedAttachmentsKey,
                                      nil];
    if (!bufferAttributes)
        return NO;
    CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef)bufferAttributes, &_pixelBufferPool);
    if (!_pixelBufferPool)
        return NO;
    _size = aSize;
    return YES;
}

- (id)init
{
    [self release];
    return nil;
}

- (id)HSQuartzQCGraphicCompositionRenderer_createOpenGLRenderer
{
    if ([_compositionReference isKindOfClass:[NSString class]])
        return [[HSOpenGLQCGraphicCompositionRenderer alloc] initWithOpenGLContext:_openGLContext pixelFormat:[_openGLContext pixelFormat] compositionFilePath:_compositionReference];
    return [[HSOpenGLQCGraphicCompositionRenderer alloc] initWithOpenGLContext:_openGLContext pixelFormat:[_openGLContext pixelFormat] quartzComposerComposition:_compositionReference];
}

@end

// A Quartz Composer renderer drawing in the OpenGL context given. Pixel
// buffers set as image inputs are passed as images unless their alpha is
// premultiplied.
@implementation HSOpenGLQCGraphicCompositionRenderer

- (id)frameTextureAtTime:(double)aTime
{
    return nil;
}

- (void)renderFrameAtTime:(double)aTime
{
    [_quartzComposerRenderer renderAtTime:aTime arguments:nil];
}

- (id)valueForOutputKey:(id)aKey
{
    return [_quartzComposerRenderer valueForOutputKey:aKey];
}

- (id)valueForInputKey:(id)aKey
{
    return [_quartzComposerRenderer valueForInputKey:aKey];
}

// Without QCComposition the input keys may have lost leading underscores.
- (BOOL)setValue:(id)aValue forInputKey:(id)aKey
{
    NSDictionary *attributes = [_quartzComposerRenderer attributes];
    id value = aValue;
    NSDictionary *portAttributes;
    if (NSClassFromString(@"QCComposition")) {
        portAttributes = [attributes objectForKey:aKey];
    } else {
        while (!(portAttributes = [attributes objectForKey:aKey])) {
            if ([aKey length] < 2 || ![aKey hasPrefix:@"_"])
                return NO;
            aKey = [aKey substringFromIndex:1];
        }
    }
    if ([[portAttributes objectForKey:QCPortAttributeTypeKey] isEqualToString:QCPortTypeImage])
        value = [self HSOpenGLQCGraphicCompositionRenderer_imageForQuartzComposerRenderer:aValue];
    return [_quartzComposerRenderer setValue:value forInputKey:aKey];
}

// Before Leopard a premultiplied pixel buffer is passed as a copy sharing
// its bytes.
- (id)HSOpenGLQCGraphicCompositionRenderer_imageForQuartzComposerRenderer:(id)aRenderer
{
    if (!aRenderer)
        return nil;
    if (CFGetTypeID(aRenderer) != CVPixelBufferGetTypeID())
        return aRenderer;
    CVPixelBufferRef buffer = (CVPixelBufferRef)aRenderer;
    if ([(id)CVBufferGetAttachment(buffer, (CFStringRef)kCVEPixelBufferAlphaInfoKey, NULL) intValue] != 1)
        return [(id)CGEImageCreateWithPixelBuffer(buffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault) autorelease];
    if ([[HSSystem sharedSystem] isLeopardOrGreater])
        return aRenderer;
    if (CVPixelBufferLockBaseAddress(buffer, 0) != kCVReturnSuccess)
        return nil;
    void *baseAddress = CVPixelBufferGetBaseAddress(buffer);
    CVPixelBufferRef copy = NULL;
    if (baseAddress)
        CVPixelBufferCreateWithBytes(kCFAllocatorDefault, CVPixelBufferGetWidth(buffer), CVPixelBufferGetHeight(buffer), CVPixelBufferGetPixelFormatType(buffer),
                                     baseAddress, CVPixelBufferGetBytesPerRow(buffer), HSReleaseLockedPixelBufferBytes, buffer, NULL, &copy);
    if (!copy) {
        CVPixelBufferUnlockBaseAddress(buffer, 0);
        return nil;
    }
    CFDictionaryRef attachments = CVBufferGetAttachments(buffer, kCVAttachmentMode_ShouldNotPropagate);
    if (attachments)
        CVBufferSetAttachments(copy, attachments, kCVAttachmentMode_ShouldNotPropagate);
    CVBufferPropagateAttachments(buffer, copy);
    CVPixelBufferRetain(buffer);
    return [(id)copy autorelease];
}

- (id)outputKeys
{
    return [_quartzComposerRenderer outputKeys];
}

- (id)inputKeys
{
    return [_quartzComposerRenderer inputKeys];
}

- (id)openGLContext
{
    return _openGLContext;
}

- (id)openGLPixelFormat
{
    return _openGLPixelFormat;
}

- (void)dealloc
{
    [_quartzComposerRenderer release];
    [_openGLContext release];
    [_openGLPixelFormat release];
    [super dealloc];
}

// Renders in the color space of the context's display when it is on just
// one, else generic RGB.
- (id)initWithOpenGLContext:(id)aContext pixelFormat:(id)aFormat quartzComposerComposition:(id)aComposition
{
    self = [super init];
    if (!self)
        return nil;
    GLint displayMask = 0;
    [aFormat getValues:&displayMask forAttribute:NSOpenGLPFAScreenMask forVirtualScreen:[aContext currentVirtualScreen]];
    uint32_t displayCount = 0;
    CGGetDisplaysWithOpenGLDisplayMask(displayMask, 0, NULL, &displayCount);
    CGColorSpaceRef colorSpace = NULL;
    if (displayCount == 1) {
        CGDirectDisplayID display = CGOpenGLDisplayMaskToDisplayID(displayMask);
        // The original went through the display's ColorSync profile.
        if (display)
            colorSpace = CGDisplayCopyColorSpace(display);
    }
    if (!colorSpace)
        colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (colorSpace) {
        _quartzComposerRenderer = [[QCRenderer alloc] initWithCGLContext:[aContext CGLContextObj] pixelFormat:[aFormat CGLPixelFormatObj] colorSpace:colorSpace composition:aComposition];
        CGColorSpaceRelease(colorSpace);
        if (_quartzComposerRenderer) {
            _openGLPixelFormat = [aFormat retain];
            _openGLContext = [aContext retain];
            return self;
        }
    }
    [self release];
    return nil;
}

- (id)initWithOpenGLContext:(id)aContext pixelFormat:(id)aFormat compositionFilePath:(id)aPath
{
    self = [super init];
    if (!self)
        return nil;
    _quartzComposerRenderer = [[QCRenderer alloc] initWithOpenGLContext:aContext pixelFormat:aFormat file:aPath];
    if (!_quartzComposerRenderer) {
        [self release];
        return nil;
    }
    _openGLPixelFormat = [aFormat retain];
    _openGLContext = [aContext retain];
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
