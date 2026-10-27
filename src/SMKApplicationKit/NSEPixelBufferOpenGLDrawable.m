#import "NSEPixelBufferOpenGLDrawable.h"
#import "NSEOffscreenWindowOpenGLDrawable.h"
#import "NSEOpenGLDrawableSupport.h"
#import <libkern/OSAtomic.h>

// Drawing with OpenGL into pixel buffers (and images of them): an offscreen
// window's context draws, and its pixels are read back, into a pixel buffer
// object where the renderer reads those asynchronously, else straight into a
// CoreVideo pixel buffer. The pixels come out bottom row first.

// A pixel buffer object's pixels, mapped when they're first wanted. Its
// effective retain count counts the users of the pixels; when that drops to
// none the buffer object is deleted, though the object may live on.
@implementation __NSEOpenGLPixelBufferObject

+ (id)allocWithZone:(NSZone *)aZone
{
    __NSEOpenGLPixelBufferObject *object = [super allocWithZone:aZone];
    if (object)
        object->_effectiveRetainCount = 1;
    return object;
}

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithOpenGLContext:(id)aContext pixelBufferObject:(NSUInteger)aObject
{
    if ((self = [super init])) {
        _openGLContext = [aContext retain];
        _coreGLContext = [aContext CGLContextObj];
        _pixelBufferObject = (unsigned int)aObject;
    }
    return self;
}

- (void)invalidate
{
    if (!_coreGLContext)
        return;
    if (CGLLockContext(_coreGLContext) == kCGLNoError) {
        CGLContextObj cgl_ctx = _coreGLContext;
        glBindBuffer(GL_PIXEL_PACK_BUFFER, _pixelBufferObject);
        if (_pixels) {
            glUnmapBuffer(GL_PIXEL_PACK_BUFFER);
            _pixels = NULL;
        }
        glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
        glDeleteBuffers(1, &_pixelBufferObject);
        CGLUnlockContext(_coreGLContext);
    }
    [_openGLContext release];
    _openGLContext = nil;
    _coreGLContext = NULL;
}

- (id)retain
{
    OSAtomicAdd32Barrier(1, (volatile int32_t *)&_effectiveRetainCount);
    return [super retain];
}

- (oneway void)release
{
    if (OSAtomicAdd32Barrier(-1, (volatile int32_t *)&_effectiveRetainCount) == 0)
        [self invalidate];
    [super release];
}

// Retaining and releasing that doesn't count as using the pixels.
- (id)serviceRetain
{
    return [super retain];
}

- (oneway void)serviceRelease
{
    [super release];
}

- (void *)pixels
{
    if (!_pixels && _coreGLContext && CGLLockContext(_coreGLContext) == kCGLNoError) {
        CGLContextObj cgl_ctx = _coreGLContext;
        glBindBuffer(GL_PIXEL_PACK_BUFFER, _pixelBufferObject);
        _pixels = glMapBuffer(GL_PIXEL_PACK_BUFFER, GL_READ_ONLY);
        glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
        CGLUnlockContext(_coreGLContext);
    }
    return _pixels;
}

// Before the context draws again: the pixels are fetched if they're still
// used, else the buffer object goes.
- (void)synchronize
{
    if (OSAtomicAdd32Barrier(1, (volatile int32_t *)&_effectiveRetainCount) == 1)
        _effectiveRetainCount = 0;
    else {
        [self pixels];
        if (OSAtomicAdd32Barrier(-1, (volatile int32_t *)&_effectiveRetainCount) == 0)
            [self invalidate];
    }
}

@end

static void releasePixelBufferObject(void *releaseRefCon, const void *baseAddress)
{
    [(id)releaseRefCon release];
}

static const void *getPixelBufferObjectPixels(void *info)
{
    return [(__NSEOpenGLPixelBufferObject *)info pixels];
}

static void releasePixelBufferObjectInfo(void *info)
{
    [(id)info release];
}

// Adds an attachment to the first dictionary of a pair, removing it from the
// other.
static void moveAttachment(const void *key, const void *value, void *context)
{
    CFMutableDictionaryRef *dictionaries = context;
    CFDictionarySetValue(dictionaries[0], key, value);
    if (dictionaries[1])
        CFDictionaryRemoveValue(dictionaries[1], key);
}

static CFMutableDictionaryRef newAttachments(void)
{
    return CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks,
                                     &kCFTypeDictionaryValueCallBacks);
}

// A pixel buffer object's pixels as a pixel buffer (made when it's first
// wanted, with the attachments then).
@implementation __NSEPixelBufferLink

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithOpenGLPixelBufferObject:(id)aObject pixelsWide:(NSUInteger)aWide pixelsHigh:(NSUInteger)aHigh bytesPerRow:(NSUInteger)aRow pixelFormatType:(NSUInteger)aType nonPropagatedAttachments:(struct __CFDictionary *)aAttachments propagatedAttachments:(struct __CFDictionary *)aAttachments2
{
    if (!(self = [super init]))
        return nil;
    _pixelBufferObject = [aObject retain];
    _pixelsWide = (unsigned int)aWide;
    _pixelsHigh = (unsigned int)aHigh;
    _bytesPerRow = (unsigned int)aRow;
    _pixelFormatType = (unsigned int)aType;
    if ((aAttachments && !(_nonPropagatedAttachments = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, aAttachments))) ||
        (aAttachments2 && !(_propagatedAttachments = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, aAttachments2)))) {
        [self release];
        return nil;
    }
    return self;
}

- (void)dealloc
{
    if (_pixelBuffer)
        CVPixelBufferRelease(_pixelBuffer);
    else {
        if (_nonPropagatedAttachments)
            CFRelease(_nonPropagatedAttachments);
        if (_propagatedAttachments)
            CFRelease(_propagatedAttachments);
    }
    [_pixelBufferObject release];
    [super dealloc];
}

- (NSUInteger)width
{
    return _pixelsWide;
}

- (NSUInteger)height
{
    return _pixelsHigh;
}

- (NSUInteger)pixelFormatType
{
    return _pixelFormatType;
}

- (NSUInteger)bytesPerRow
{
    return _bytesPerRow;
}

- (NSUInteger)dataSize
{
    return (NSUInteger)_pixelsHigh * _bytesPerRow;
}

- (void *)attachmentForKey:(struct __CFString *)aKey mode:(unsigned int *)aMode
{
    if (_pixelBuffer)
        return (void *)CVBufferGetAttachment(_pixelBuffer, aKey, (CVAttachmentMode *)aMode);
    const void *value;
    if (_propagatedAttachments && (value = CFDictionaryGetValue(_propagatedAttachments, aKey))) {
        if (aMode)
            *aMode = kCVAttachmentMode_ShouldPropagate;
        return (void *)value;
    }
    value = NULL;
    if (_nonPropagatedAttachments && (value = CFDictionaryGetValue(_nonPropagatedAttachments, aKey)) && aMode)
        *aMode = kCVAttachmentMode_ShouldNotPropagate;
    return (void *)value;
}

- (struct __CFDictionary *)attachmentsForMode:(NSUInteger)aMode
{
    if (_pixelBuffer)
        return (CFMutableDictionaryRef)CVBufferGetAttachments(_pixelBuffer, (CVAttachmentMode)aMode);
    CFMutableDictionaryRef attachments;
    if (aMode == kCVAttachmentMode_ShouldPropagate)
        attachments = _propagatedAttachments;
    else if (aMode == kCVAttachmentMode_ShouldNotPropagate)
        attachments = _nonPropagatedAttachments;
    else
        return NULL;
    return attachments ? attachments : (CFMutableDictionaryRef)[NSDictionary dictionary];
}

- (void)setAttachment:(void *)aAttachment forKey:(struct __CFString *)aKey mode:(NSUInteger)aMode
{
    if (_pixelBuffer) {
        CVBufferSetAttachment(_pixelBuffer, aKey, aAttachment, (CVAttachmentMode)aMode);
        return;
    }
    CFMutableDictionaryRef other;
    if (aMode == kCVAttachmentMode_ShouldPropagate) {
        if (!_propagatedAttachments && !(_propagatedAttachments = newAttachments()))
            return;
        CFDictionarySetValue(_propagatedAttachments, aKey, aAttachment);
        other = _nonPropagatedAttachments;
    }
    else if (aMode == kCVAttachmentMode_ShouldNotPropagate) {
        if (!_nonPropagatedAttachments && !(_nonPropagatedAttachments = newAttachments()))
            return;
        CFDictionarySetValue(_nonPropagatedAttachments, aKey, aAttachment);
        other = _propagatedAttachments;
    }
    else
        return;
    if (other)
        CFDictionaryRemoveValue(other, aKey);
}

- (void)setAttachments:(struct __CFDictionary *)aAttachments mode:(NSUInteger)aMode
{
    if (_pixelBuffer) {
        CVBufferSetAttachments(_pixelBuffer, aAttachments, (CVAttachmentMode)aMode);
        return;
    }
    CFMutableDictionaryRef dictionaries[2];
    if (aMode == kCVAttachmentMode_ShouldPropagate) {
        if (!_propagatedAttachments && !(_propagatedAttachments = newAttachments()))
            return;
        dictionaries[0] = _propagatedAttachments;
        dictionaries[1] = _nonPropagatedAttachments;
    }
    else if (aMode == kCVAttachmentMode_ShouldNotPropagate) {
        if (!_nonPropagatedAttachments && !(_nonPropagatedAttachments = newAttachments()))
            return;
        dictionaries[0] = _nonPropagatedAttachments;
        dictionaries[1] = _propagatedAttachments;
    }
    else
        return;
    CFDictionaryApplyFunction(aAttachments, moveAttachment, dictionaries);
}

- (void)removeAttachmentForKey:(struct __CFString *)aKey
{
    if (_pixelBuffer) {
        CVBufferRemoveAttachment(_pixelBuffer, aKey);
        return;
    }
    if (_nonPropagatedAttachments)
        CFDictionaryRemoveValue(_nonPropagatedAttachments, aKey);
    if (_propagatedAttachments)
        CFDictionaryRemoveValue(_propagatedAttachments, aKey);
}

- (void)removeAllAttachments
{
    if (_pixelBuffer) {
        CVBufferRemoveAllAttachments(_pixelBuffer);
        return;
    }
    if (_nonPropagatedAttachments)
        CFDictionaryRemoveAllValues(_nonPropagatedAttachments);
    if (_propagatedAttachments)
        CFDictionaryRemoveAllValues(_propagatedAttachments);
}

- (struct CGImage *)newImageWithDecode:(const CGFloat *)aDecode interpolation:(BOOL)aInterpolation colorRenderingIntent:(NSInteger)aIntent
{
    if (_pixelBuffer)
        return CGEImageCreateWithPixelBuffer(_pixelBuffer, kCVPixelBufferLock_ReadOnly, aDecode, aInterpolation,
                                             (CGColorRenderingIntent)aIntent);
    CGDataProviderDirectCallbacks callbacks = { 0, getPixelBufferObjectPixels, NULL, NULL, releasePixelBufferObjectInfo };
    CGDataProviderRef provider = CGDataProviderCreateDirect(_pixelBufferObject, (off_t)_pixelsHigh * _bytesPerRow,
                                                            &callbacks);
    if (!provider)
        return NULL;
    [_pixelBufferObject retain];
    int alphaMode = [(id)[self attachmentForKey:(struct __CFString *)kCVEPixelBufferAlphaInfoKey mode:NULL] intValue];
    CGColorSpaceRef space = [self attachmentForKey:(struct __CFString *)kCVImageBufferCGColorSpaceKey mode:NULL];
    CGImageRef image = CGEImageCreateAsPixelFormatType(_pixelsWide, _pixelsHigh, _pixelFormatType, _bytesPerRow, space,
                                                       alphaMode, provider, aDecode, aInterpolation,
                                                       (CGColorRenderingIntent)aIntent);
    CGDataProviderRelease(provider);
    return image;
}

- (struct __CVBuffer *)pixelBuffer
{
    if (!_pixelBuffer) {
        void *pixels = [_pixelBufferObject pixels];
        if (pixels) {
            CVPixelBufferCreateWithBytes(kCFAllocatorDefault, _pixelsWide, _pixelsHigh, _pixelFormatType, pixels,
                                         _bytesPerRow, releasePixelBufferObject, _pixelBufferObject, NULL,
                                         &_pixelBuffer);
            if (_pixelBuffer) {
                [_pixelBufferObject retain];
                if (_nonPropagatedAttachments) {
                    CVBufferSetAttachments(_pixelBuffer, _nonPropagatedAttachments, kCVAttachmentMode_ShouldNotPropagate);
                    CFRelease(_nonPropagatedAttachments);
                    _nonPropagatedAttachments = NULL;
                }
                if (_propagatedAttachments) {
                    CVBufferSetAttachments(_pixelBuffer, _propagatedAttachments, kCVAttachmentMode_ShouldPropagate);
                    CFRelease(_propagatedAttachments);
                    _propagatedAttachments = NULL;
                }
            }
        }
    }
    return _pixelBuffer;
}

@end

// A pixel buffer as a pixel buffer link.
@implementation __NSEPixelBufferWrapper

- (id)init
{
    [self release];
    return nil;
}

- (id)initWithPixelBuffer:(struct __CVBuffer *)aBuffer
{
    if ((self = [super init]))
        _pixelBuffer = CVPixelBufferRetain(aBuffer);
    return self;
}

- (void)dealloc
{
    CVPixelBufferRelease(_pixelBuffer);
    [super dealloc];
}

- (struct __CVBuffer *)pixelBuffer
{
    return _pixelBuffer;
}

- (NSUInteger)width
{
    return CVPixelBufferGetWidth(_pixelBuffer);
}

- (NSUInteger)height
{
    return CVPixelBufferGetHeight(_pixelBuffer);
}

- (NSUInteger)pixelFormatType
{
    return CVPixelBufferGetPixelFormatType(_pixelBuffer);
}

- (NSUInteger)bytesPerRow
{
    return CVPixelBufferGetBytesPerRow(_pixelBuffer);
}

- (NSUInteger)dataSize
{
    return CVEPixelBufferGetDataSize(_pixelBuffer);
}

- (void *)attachmentForKey:(struct __CFString *)aKey mode:(unsigned int *)aMode
{
    return (void *)CVBufferGetAttachment(_pixelBuffer, aKey, (CVAttachmentMode *)aMode);
}

- (struct __CFDictionary *)attachmentsForMode:(NSUInteger)aMode
{
    return (CFMutableDictionaryRef)CVBufferGetAttachments(_pixelBuffer, (CVAttachmentMode)aMode);
}

- (void)setAttachment:(void *)aAttachment forKey:(struct __CFString *)aKey mode:(NSUInteger)aMode
{
    CVBufferSetAttachment(_pixelBuffer, aKey, aAttachment, (CVAttachmentMode)aMode);
}

- (void)setAttachments:(struct __CFDictionary *)aAttachments mode:(NSUInteger)aMode
{
    CVBufferSetAttachments(_pixelBuffer, aAttachments, (CVAttachmentMode)aMode);
}

- (void)removeAttachmentForKey:(struct __CFString *)aKey
{
    CVBufferRemoveAttachment(_pixelBuffer, aKey);
}

- (void)removeAllAttachments
{
    CVBufferRemoveAllAttachments(_pixelBuffer);
}

- (struct CGImage *)newImageWithDecode:(const CGFloat *)aDecode interpolation:(BOOL)aInterpolation colorRenderingIntent:(NSInteger)aIntent
{
    return CGEImageCreateWithPixelBuffer(_pixelBuffer, kCVPixelBufferLock_ReadOnly, aDecode, aInterpolation,
                                         (CGColorRenderingIntent)aIntent);
}

@end

// What an OpenGL layer drawn into a CGContext is.
typedef struct {
    CGContextRef context;
    CGRect rect;            // where the image goes: in user space, or device space when aligned to it
    CGFloat opacity;
    BOOL inDeviceSpace;
} LayerInfo;

@implementation NSEPixelBufferOpenGLDrawable

- (id)init
{
    NSEOffscreenWindowOpenGLDrawable *drawable = [[NSEOffscreenWindowOpenGLDrawable alloc] init];
    if (!drawable) {
        [self release];
        return nil;
    }
    self = [self initWithOffscreenWindowOpenGLDrawable:drawable];
    [drawable release];
    return self;
}

- (id)initWithOpenGLContext:(id)aContext
{
    NSEOffscreenWindowOpenGLDrawable *drawable = [[NSEOffscreenWindowOpenGLDrawable alloc] initWithOpenGLContext:aContext];
    if (!drawable) {
        [self release];
        return nil;
    }
    self = [self initWithOffscreenWindowOpenGLDrawable:drawable];
    [drawable release];
    return self;
}

- (id)initWithOffscreenWindowOpenGLDrawable:(id)aDrawable
{
    NSNumber *alpha;
    if (!(_pixelBufferNonPropagatedAttachments = newAttachments()) || !(alpha = [NSNumber numberWithInt:1])) {
        [self release];
        return nil;
    }
    CFDictionarySetValue(_pixelBufferNonPropagatedAttachments, kCVEPixelBufferAlphaInfoKey, alpha);
    _offscreenWindowOpenGLDrawable = [aDrawable retain];
    _coreGLContext = [[aDrawable openGLContext] CGLContextObj];
    _pixelFormatType = kCVPixelFormatType_32BGRA;
    _isPixelBufferPoolSizeSynchronized = 1;
    _isPixelBufferPoolFormatSynchronized = 1;
    return self;
}

- (void)dealloc
{
    [_pixelBufferObject synchronize];
    [_pixelBufferObject serviceRelease];
    if (_pixelBufferPropagatedAttachments)
        CFRelease(_pixelBufferPropagatedAttachments);
    if (_pixelBufferNonPropagatedAttachments)
        CFRelease(_pixelBufferNonPropagatedAttachments);
    CVPixelBufferPoolRelease(_pixelBufferPool);
    [_offscreenWindowOpenGLDrawable release];
    [super dealloc];
}

- (NSUInteger)pixelsWide
{
    return _pixelsWide;
}

- (NSUInteger)pixelsHigh
{
    return _pixelsHigh;
}

// Pixel buffers from the pool are only made the size (or format) set
// statically.
- (void)setPixelsWide:(NSUInteger)aWide pixelsHigh:(NSUInteger)aHigh statically:(BOOL)aStatically
{
    _pixelsWide = (unsigned int)aWide;
    _pixelsHigh = (unsigned int)aHigh;
    [_offscreenWindowOpenGLDrawable setWidth:aWide height:aHigh statically:aStatically];
    _isPixelBufferPoolSizeSynchronized = !aStatically;
}

- (NSUInteger)pixelFormatType
{
    return _pixelFormatType;
}

- (void)setPixelFormatType:(NSUInteger)aType statically:(BOOL)aStatically
{
    _pixelFormatType = (unsigned int)aType;
    _isPixelBufferPoolFormatSynchronized = !aStatically;
}

- (BOOL)isPixelBufferExtensionDisabled
{
    return _isPixelBufferForceDisabled;
}

- (void)setPixelBufferExtensionDisabled:(BOOL)aDisabled
{
    _isPixelBufferForceDisabled = aDisabled != NO;
}

- (struct __CFDictionary *)NSEPixelBufferOpenGLDrawable_pixelBufferPropagatedAttachments
{
    if (!_pixelBufferPropagatedAttachments)
        _pixelBufferPropagatedAttachments = newAttachments();
    return _pixelBufferPropagatedAttachments;
}

- (struct __CFDictionary *)NSEPixelBufferOpenGLDrawable_pixelBufferNonPropagatedAttachments
{
    if (!_pixelBufferNonPropagatedAttachments)
        _pixelBufferNonPropagatedAttachments = newAttachments();
    return _pixelBufferNonPropagatedAttachments;
}

- (void *)pixelBufferAttachmentForKey:(struct __CFString *)aKey mode:(unsigned int *)aMode
{
    const void *value;
    if (_pixelBufferPropagatedAttachments && (value = CFDictionaryGetValue(_pixelBufferPropagatedAttachments, aKey))) {
        if (aMode)
            *aMode = kCVAttachmentMode_ShouldPropagate;
        return (void *)value;
    }
    value = NULL;
    if (_pixelBufferNonPropagatedAttachments &&
        (value = CFDictionaryGetValue(_pixelBufferNonPropagatedAttachments, aKey)) && aMode)
        *aMode = kCVAttachmentMode_ShouldNotPropagate;
    return (void *)value;
}

- (struct __CFDictionary *)pixelBufferAttachmentsForMode:(NSUInteger)aMode
{
    CFMutableDictionaryRef attachments;
    if (aMode == kCVAttachmentMode_ShouldPropagate)
        attachments = _pixelBufferPropagatedAttachments;
    else if (aMode == kCVAttachmentMode_ShouldNotPropagate)
        attachments = _pixelBufferNonPropagatedAttachments;
    else
        return NULL;
    return attachments ? attachments : (CFMutableDictionaryRef)[NSDictionary dictionary];
}

- (void)setPixelBufferAttachment:(void *)aAttachment forKey:(struct __CFString *)aKey mode:(NSUInteger)aMode
{
    CFMutableDictionaryRef other;
    if (aMode == kCVAttachmentMode_ShouldPropagate) {
        if (![self NSEPixelBufferOpenGLDrawable_pixelBufferPropagatedAttachments])
            return;
        CFDictionarySetValue(_pixelBufferPropagatedAttachments, aKey, aAttachment);
        other = _pixelBufferNonPropagatedAttachments;
    }
    else if (aMode == kCVAttachmentMode_ShouldNotPropagate) {
        if (![self NSEPixelBufferOpenGLDrawable_pixelBufferNonPropagatedAttachments])
            return;
        CFDictionarySetValue(_pixelBufferNonPropagatedAttachments, aKey, aAttachment);
        other = _pixelBufferPropagatedAttachments;
    }
    else
        return;
    if (other)
        CFDictionaryRemoveValue(other, aKey);
}

- (void)setPixelBufferAttachments:(struct __CFDictionary *)aAttachments mode:(NSUInteger)aMode
{
    CFMutableDictionaryRef dictionaries[2];
    if (aMode == kCVAttachmentMode_ShouldPropagate) {
        dictionaries[0] = [self NSEPixelBufferOpenGLDrawable_pixelBufferPropagatedAttachments];
        dictionaries[1] = _pixelBufferNonPropagatedAttachments;
    }
    else if (aMode == kCVAttachmentMode_ShouldNotPropagate) {
        dictionaries[0] = [self NSEPixelBufferOpenGLDrawable_pixelBufferNonPropagatedAttachments];
        dictionaries[1] = _pixelBufferPropagatedAttachments;
    }
    else
        return;
    if (dictionaries[0])
        CFDictionaryApplyFunction(aAttachments, moveAttachment, dictionaries);
}

- (void)removePixelBufferAttachmentForKey:(struct __CFString *)aKey
{
    if (_pixelBufferNonPropagatedAttachments)
        CFDictionaryRemoveValue(_pixelBufferNonPropagatedAttachments, aKey);
    if (_pixelBufferPropagatedAttachments)
        CFDictionaryRemoveValue(_pixelBufferPropagatedAttachments, aKey);
}

- (void)removeAllPixelBufferAttachmentsForMode:(NSUInteger)aMode
{
    CFMutableDictionaryRef attachments;
    if (aMode == kCVAttachmentMode_ShouldPropagate)
        attachments = _pixelBufferPropagatedAttachments;
    else if (aMode == kCVAttachmentMode_ShouldNotPropagate)
        attachments = _pixelBufferNonPropagatedAttachments;
    else
        return;
    if (attachments)
        CFDictionaryRemoveAllValues(attachments);
}

// The pool, remade if the size or format set statically changed.
- (struct __CVPixelBufferPool *)NSEPixelBufferOpenGLDrawable_pixelBufferPool
{
    if (_isPixelBufferPoolSizeSynchronized && _isPixelBufferPoolFormatSynchronized)
        return _pixelBufferPool;
    if (!_pixelBufferPool) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithUnsignedInt:_pixelFormatType], kCVPixelBufferPixelFormatTypeKey,
                                    [NSNumber numberWithUnsignedLong:_pixelsWide], kCVPixelBufferWidthKey,
                                    [NSNumber numberWithUnsignedLong:_pixelsHigh], kCVPixelBufferHeightKey,
                                    (id)kCFBooleanTrue, kCVPixelBufferCGImageCompatibilityKey,
                                    (id)kCFBooleanTrue, kCVPixelBufferOpenGLCompatibilityKey, nil];
        if (!attributes ||
            CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef)attributes, &_pixelBufferPool) != kCVReturnSuccess ||
            !_pixelBufferPool)
            return NULL;
    }
    else {
        NSDictionary *attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool);
        BOOL widthChanged = !_isPixelBufferPoolSizeSynchronized &&
                            _pixelsWide != [[attributes objectForKey:(id)kCVPixelBufferWidthKey] unsignedLongValue];
        BOOL heightChanged = !_isPixelBufferPoolSizeSynchronized &&
                             _pixelsHigh != [[attributes objectForKey:(id)kCVPixelBufferHeightKey] unsignedLongValue];
        BOOL formatChanged = !_isPixelBufferPoolFormatSynchronized &&
                             _pixelFormatType != [[attributes objectForKey:(id)kCVPixelBufferPixelFormatTypeKey] unsignedIntValue];
        if (widthChanged || heightChanged || formatChanged) {
            NSNumber *width = nil, *height = nil, *format = nil;
            if ((widthChanged && !(width = [NSNumber numberWithUnsignedLong:_pixelsWide])) ||
                (heightChanged && !(height = [NSNumber numberWithUnsignedLong:_pixelsHigh])) ||
                (formatChanged && !(format = [NSNumber numberWithUnsignedInt:_pixelFormatType])))
                return NULL;
            CFMutableDictionaryRef changed = CFDictionaryCreateMutableCopy(kCFAllocatorDefault,
                                                                           CFDictionaryGetCount((CFDictionaryRef)attributes),
                                                                           (CFDictionaryRef)attributes);
            if (!changed)
                return NULL;
            if (width)
                CFDictionarySetValue(changed, kCVPixelBufferWidthKey, width);
            if (height)
                CFDictionarySetValue(changed, kCVPixelBufferHeightKey, height);
            if (format)
                CFDictionarySetValue(changed, kCVPixelBufferPixelFormatTypeKey, format);
            CVPixelBufferPoolRef pool = NULL;
            CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, changed, &pool);
            CFRelease(changed);
            if (!pool)
                return NULL;
            CVPixelBufferPoolRelease(_pixelBufferPool);
            _pixelBufferPool = pool;
        }
    }
    _isPixelBufferPoolSizeSynchronized = 1;
    _isPixelBufferPoolFormatSynchronized = 1;
    return _pixelBufferPool;
}

// A new pixel buffer of the size and format, from the pool if it's that, with
// the attachments.
- (struct __CVBuffer *)createEmptyPixelBuffer
{
    CVPixelBufferRef buffer = NULL;
    NSDictionary *attributes;
    if ([self NSEPixelBufferOpenGLDrawable_pixelBufferPool] &&
        (attributes = (NSDictionary *)CVPixelBufferPoolGetPixelBufferAttributes(_pixelBufferPool)) &&
        _pixelsWide == [[attributes objectForKey:(id)kCVPixelBufferWidthKey] unsignedLongValue] &&
        _pixelsHigh == [[attributes objectForKey:(id)kCVPixelBufferHeightKey] unsignedLongValue] &&
        _pixelFormatType == [[attributes objectForKey:(id)kCVPixelBufferPixelFormatTypeKey] unsignedIntValue])
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _pixelBufferPool, &buffer);
    if (!buffer) {
        attributes = [NSDictionary dictionaryWithObjectsAndKeys:(id)kCFBooleanTrue, kCVPixelBufferCGImageCompatibilityKey,
                                   (id)kCFBooleanTrue, kCVPixelBufferOpenGLCompatibilityKey, nil];
        if (!attributes)
            return NULL;
        CVPixelBufferCreate(kCFAllocatorDefault, _pixelsWide, _pixelsHigh, _pixelFormatType,
                            (CFDictionaryRef)attributes, &buffer);
        if (!buffer)
            return NULL;
    }
    if (_pixelBufferNonPropagatedAttachments)
        CVBufferSetAttachments(buffer, _pixelBufferNonPropagatedAttachments, kCVAttachmentMode_ShouldNotPropagate);
    if (_pixelBufferPropagatedAttachments)
        CVBufferSetAttachments(buffer, _pixelBufferPropagatedAttachments, kCVAttachmentMode_ShouldPropagate);
    return buffer;
}

- (id)openGLContext
{
    return [_offscreenWindowOpenGLDrawable openGLContext];
}

- (id)offscreenWindowOpenGLDrawable
{
    return _offscreenWindowOpenGLDrawable;
}

- (id)lockOpenGLFocus
{
    if (!_pixelsWide || !_pixelsHigh)
        return nil;
    if (_pixelBufferObject) {
        [_pixelBufferObject synchronize];
        [_pixelBufferObject serviceRelease];
        _pixelBufferObject = nil;
    }
    return [_offscreenWindowOpenGLDrawable lockOpenGLFocus];
}

- (void)unlockOpenGLFocus
{
    [_offscreenWindowOpenGLDrawable unlockOpenGLFocus];
}

// The pixels read into a pixel buffer.
- (struct __CVBuffer *)NSEPixelBufferOpenGLDrawable_readPixelBuffer
{
    CVPixelBufferRef buffer = [self createEmptyPixelBuffer];
    if (!buffer)
        return NULL;
    GLenum format = 0, type = 0;
    GLint rowLength = 0, alignment = 0;
    if (!CVEPixelBufferIsOpenGLCompatible(buffer, NULL, &format, &type, &rowLength, &alignment) ||
        CVPixelBufferLockBaseAddress(buffer, 0) != kCVReturnSuccess) {
        CVPixelBufferRelease(buffer);
        return NULL;
    }
    void *base = CVPixelBufferGetBaseAddress(buffer);
    if (!base) {
        CVPixelBufferUnlockBaseAddress(buffer, 0);
        CVPixelBufferRelease(buffer);
        return NULL;
    }
    CGLContextObj cgl_ctx = _coreGLContext;
    GLint previousRowLength = 0, previousAlignment = 0;
    glGetIntegerv(GL_PACK_ROW_LENGTH, &previousRowLength);
    glGetIntegerv(GL_PACK_ALIGNMENT, &previousAlignment);
    if (rowLength != previousRowLength)
        glPixelStorei(GL_PACK_ROW_LENGTH, rowLength);
    if (alignment != previousAlignment)
        glPixelStorei(GL_PACK_ALIGNMENT, alignment);
    glFlush();
    glReadPixels(0, 0, _pixelsWide, _pixelsHigh, format, type, base);
    if (alignment != previousAlignment)
        glPixelStorei(GL_PACK_ALIGNMENT, previousAlignment);
    if (rowLength != previousRowLength)
        glPixelStorei(GL_PACK_ROW_LENGTH, previousRowLength);
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return buffer;
}

// Whether the pixels can be read into a pixel buffer object, and its layout:
// rows 32-byte aligned where the renderer can read into them.
- (BOOL)NSEPixelBufferOpenGLDrawable_isPixelBufferObjectExtensionPresentWithBytesPerRow:(unsigned int *)aRow rowLength:(int *)aLength rowAlignment:(int *)aAlignment openGLFormat:(unsigned int *)aFormat openGLType:(unsigned int *)aType
{
    CGLContextObj cgl_ctx = _coreGLContext;
    if (!_isPixelBufferObjectExtensionPresenceInitialized) {
        _isPixelBufferObjectExtensionPresent = 0;
        const GLubyte *extensions = glGetString(GL_EXTENSIONS);
        if (extensions) {
            if (!_isPixelBufferForceDisabled &&
                gluCheckExtension((const GLubyte *)"GL_ARB_pixel_buffer_object", extensions)) {
                _isPixelBufferObjectRowLengthIgnored = 0;
                _isPixelBufferObjectBytesPerRow32ByteUnaligned = 0;
                BOOL usable = YES;
                const char *vendor = (const char *)glGetString(GL_VENDOR), *renderer;
                if (vendor) {
                    if (strcmp(vendor, "NVIDIA Corporation") == 0)
                        usable = NO;
                    else if (strcmp(vendor, "ATI Technologies Inc.") == 0 &&
                             (renderer = (const char *)glGetString(GL_RENDERER))) {
                        if (strcmp(renderer, "AMD Radeon HD 6750M OpenGL Engine") == 0 ||
                            strcmp(renderer, "ATI Radeon HD 6750M OpenGL Engine") == 0)
                            usable = NO;
                        else if (strcmp(renderer, "ATI Radeon X1600 OpenGL Engine") == 0)
                            _isPixelBufferObjectRowLengthIgnored = 1;
                        else if (strcmp(renderer, "ATI Radeon X800 XT OpenGL Engine") == 0 ||
                                 strcmp(renderer, "ATI Radeon 9550 OpenGL Engine") == 0 ||
                                 strcmp(renderer, "ATI Radeon 9600 OpenGL Engine") == 0 ||
                                 strcmp(renderer, "ATI Radeon 9600 XT OpenGL Engine") == 0)
                            _isPixelBufferObjectBytesPerRow32ByteUnaligned = 1;
                    }
                }
                if (usable)
                    _isPixelBufferObjectExtensionPresent = 1;
            }
            _isPixelBufferObjectExtensionPresenceInitialized = 1;
        }
    }
    if (!_isPixelBufferObjectExtensionPresent)
        return NO;

    int bitsPerBlock = 0, blockWidth = 0;
    if (!CVEPixelFormatTypeIsOpenGLCompatible(_pixelFormatType, NULL, aFormat, aType, &bitsPerBlock, &blockWidth))
        return NO;
    int rowBits;
    if (!_isPixelBufferObjectRowLengthIgnored && !_isPixelBufferObjectBytesPerRow32ByteUnaligned) {
        // 32-byte aligned rows, whole blocks of pixels long.
        *aRow = (unsigned int)((((blockWidth - 1) + (NSUInteger)_pixelsWide * bitsPerBlock) / blockWidth + 0xff) >> 3 & ~(NSUInteger)0x1f);
        *aAlignment = 8;
        rowBits = (int)*aRow * blockWidth * 8;
        if (rowBits % bitsPerBlock >= blockWidth * 64) {
            do
                rowBits += blockWidth * 256;
            while (rowBits % bitsPerBlock >= blockWidth * 64);
            *aRow = (rowBits >> 3) / blockWidth;
        }
    }
    else {
        // Rows as long as the pixels, or for renderers that can't read into
        // 32-byte aligned rows, a block longer.
        NSUInteger tight = (((blockWidth - 1) + (NSUInteger)_pixelsWide * bitsPerBlock) / blockWidth + 7) >> 3;
        *aRow = (unsigned int)tight;
        NSUInteger rowBytes;
        if (!_isPixelBufferObjectBytesPerRow32ByteUnaligned || (tight & 0x1f)) {
            *aLength = 0;
            rowBytes = *aRow;
            aLength = NULL;
        }
        else {
            NSUInteger blockBytes = (bitsPerBlock + 7) >> 3;
            if (!(blockBytes & 0x1f) && !((blockBytes = (((bitsPerBlock - 1) + blockWidth) / blockWidth + 7) >> 3) & 0x1f))
                return NO;
            rowBytes = tight + blockBytes;
            *aRow = (unsigned int)rowBytes;
        }
        rowBits = (int)rowBytes * 8;
        int extraBits = rowBits % bitsPerBlock, extraPixelBits = extraBits * blockWidth;
        static const int alignments[] = { 8, 4, 2, 1 };
        for (int i = 0; i < 4; i++) {
            int alignment = alignments[i];
            if ((int)rowBytes % alignment == 0) {
                if (alignment * 8 <= extraBits - ((blockWidth - 1 + extraPixelBits) - extraPixelBits % bitsPerBlock) / blockWidth)
                    return NO;
                if (aAlignment)
                    *aAlignment = alignment;
                break;
            }
        }
        if (!aLength)
            return YES;
        rowBits *= blockWidth;
    }
    *aLength = rowBits / bitsPerBlock;
    return YES;
}

// The pixels read into a new pixel buffer object, asynchronously.
- (id)NSEPixelBufferOpenGLDrawable_readPixelBufferObjectWithBytesPerRow:(NSUInteger)aRow rowLength:(NSInteger)aLength rowAlignment:(NSInteger)aAlignment openGLFormat:(NSUInteger)aFormat openGLType:(NSUInteger)aType
{
    CGLContextObj cgl_ctx = _coreGLContext;
    NSUInteger height = _pixelsHigh;
    GLuint name = 0;
    glGenBuffers(1, &name);
    glBindBuffer(GL_PIXEL_PACK_BUFFER, name);
    glBufferData(GL_PIXEL_PACK_BUFFER, aRow * height, NULL, GL_STREAM_READ);
    GLint previousRowLength = 0, previousAlignment = 0;
    glGetIntegerv(GL_PACK_ROW_LENGTH, &previousRowLength);
    glGetIntegerv(GL_PACK_ALIGNMENT, &previousAlignment);
    if (previousRowLength != aLength)
        glPixelStorei(GL_PACK_ROW_LENGTH, (GLint)aLength);
    if (previousAlignment != aAlignment)
        glPixelStorei(GL_PACK_ALIGNMENT, (GLint)aAlignment);
    glFlush();
    glReadPixels(0, 0, _pixelsWide, _pixelsHigh, (GLenum)aFormat, (GLenum)aType, NULL);
    if (previousAlignment != aAlignment)
        glPixelStorei(GL_PACK_ALIGNMENT, previousAlignment);
    if (previousRowLength != aLength)
        glPixelStorei(GL_PACK_ROW_LENGTH, previousRowLength);
    glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
    __NSEOpenGLPixelBufferObject *object = [[__NSEOpenGLPixelBufferObject alloc] initWithOpenGLContext:[_offscreenWindowOpenGLDrawable openGLContext]
                                                                                     pixelBufferObject:name];
    if (!object)
        glDeleteBuffers(1, &name);
    return object;
}

- (struct __CVBuffer *)unlockOpenGLFocusAsPixelBuffer
{
    CVPixelBufferRef buffer = [self NSEPixelBufferOpenGLDrawable_readPixelBuffer];
    [_offscreenWindowOpenGLDrawable unlockOpenGLFocus];
    return buffer;
}

- (id)unlockOpenGLFocusAsPixelBufferLink
{
    unsigned int bytesPerRow = 0, format = 0, type = 0;
    int rowLength = 0, alignment = 4;
    id link = nil;
    if ([self NSEPixelBufferOpenGLDrawable_isPixelBufferObjectExtensionPresentWithBytesPerRow:&bytesPerRow rowLength:&rowLength
                                                                                  rowAlignment:&alignment openGLFormat:&format
                                                                                    openGLType:&type]) {
        __NSEOpenGLPixelBufferObject *object = [self NSEPixelBufferOpenGLDrawable_readPixelBufferObjectWithBytesPerRow:bytesPerRow
                                                                                                             rowLength:rowLength
                                                                                                          rowAlignment:alignment
                                                                                                          openGLFormat:format
                                                                                                            openGLType:type];
        if (object) {
            link = [[__NSEPixelBufferLink alloc] initWithOpenGLPixelBufferObject:object pixelsWide:_pixelsWide pixelsHigh:_pixelsHigh
                                                                     bytesPerRow:bytesPerRow pixelFormatType:_pixelFormatType
                                                        nonPropagatedAttachments:_pixelBufferNonPropagatedAttachments
                                                           propagatedAttachments:_pixelBufferPropagatedAttachments];
            [object release];
            if (link)
                _pixelBufferObject = [object serviceRetain];
        }
    }
    else {
        CVPixelBufferRef buffer = [self NSEPixelBufferOpenGLDrawable_readPixelBuffer];
        if (buffer) {
            link = [[__NSEPixelBufferWrapper alloc] initWithPixelBuffer:buffer];
            CVPixelBufferRelease(buffer);
        }
    }
    [_offscreenWindowOpenGLDrawable unlockOpenGLFocus];
    return link;
}

- (struct CGImage *)unlockOpenGLFocusAsImageWithDecode:(const CGFloat *)aDecode interpolation:(BOOL)aInterpolation colorRenderingIntent:(NSInteger)aIntent
{
    unsigned int bytesPerRow = 0, format = 0, type = 0;
    int rowLength = 0, alignment = 4;
    CGImageRef image = NULL;
    if ([self NSEPixelBufferOpenGLDrawable_isPixelBufferObjectExtensionPresentWithBytesPerRow:&bytesPerRow rowLength:&rowLength
                                                                                  rowAlignment:&alignment openGLFormat:&format
                                                                                    openGLType:&type]) {
        __NSEOpenGLPixelBufferObject *object = [self NSEPixelBufferOpenGLDrawable_readPixelBufferObjectWithBytesPerRow:bytesPerRow
                                                                                                             rowLength:rowLength
                                                                                                          rowAlignment:alignment
                                                                                                          openGLFormat:format
                                                                                                            openGLType:type];
        if (object) {
            // The provider owns the object.
            CGDataProviderDirectCallbacks callbacks = { 0, getPixelBufferObjectPixels, NULL, NULL, releasePixelBufferObjectInfo };
            CGDataProviderRef provider = CGDataProviderCreateDirect(object, (off_t)_pixelsHigh * bytesPerRow, &callbacks);
            if (provider) {
                int alphaMode = [(id)[self pixelBufferAttachmentForKey:(struct __CFString *)kCVEPixelBufferAlphaInfoKey mode:NULL] intValue];
                CGColorSpaceRef space = [self pixelBufferAttachmentForKey:(struct __CFString *)kCVImageBufferCGColorSpaceKey mode:NULL];
                image = CGEImageCreateAsPixelFormatType(_pixelsWide, _pixelsHigh, _pixelFormatType, bytesPerRow, space,
                                                        alphaMode, provider, aDecode, aInterpolation,
                                                        (CGColorRenderingIntent)aIntent);
                CGDataProviderRelease(provider);
                if (image)
                    _pixelBufferObject = [object serviceRetain];
            }
            else
                [object release];
        }
    }
    else {
        // (The decode, interpolation and intent aren't used here.)
        CVPixelBufferRef buffer = [self NSEPixelBufferOpenGLDrawable_readPixelBuffer];
        if (buffer) {
            image = CGEImageCreateWithPixelBuffer(buffer, kCVPixelBufferLock_ReadOnly, NULL, true, kCGRenderingIntentDefault);
            CVPixelBufferRelease(buffer);
        }
    }
    [_offscreenWindowOpenGLDrawable unlockOpenGLFocus];
    return image;
}

- (struct CGImage *)unlockOpenGLFocusAsImage
{
    return [self unlockOpenGLFocusAsImageWithDecode:NULL interpolation:YES colorRenderingIntent:kCGRenderingIntentDefault];
}

// Starts drawing with OpenGL what's then drawn as an image into a rect of a
// context: in user space (scaled to the device), or when the context is
// multisampled, in device space, pixel aligned. The modelview matrix maps
// the rect (as for the context) into the pixels.
- (BOOL)beginOpenGLLayerForCGContext:(struct CGContext *)aContext rect:(CGRect)aRect opacity:(CGFloat)aOpacity
{
    LayerInfo *info = _layerInfo = malloc(sizeof(LayerInfo));
    if (!info)
        return NO;
    info->context = aContext;
    info->opacity = aOpacity;
    NSEOpenGLContext *context = [_offscreenWindowOpenGLDrawable openGLContext];
    GLint sampleBuffers = 0;
    [[context format] getValues:&sampleBuffers forAttribute:NSOpenGLPFASampleBuffers forVirtualScreen:[context currentVirtualScreen]];
    CGAffineTransform ctm = CGContextGetCTM(aContext);
    CGRect device = CGRectNull;
    long width, height;
    BOOL aligned;
    if (!sampleBuffers) {
        CGFloat w = hypot(ctm.a, ctm.b) * aRect.size.width, h = hypot(ctm.c, ctm.d) * aRect.size.height;
        width = w > 0 ? lround(ceil(w)) : 0;
        height = h > 0 ? lround(ceil(h)) : 0;
        info->rect = aRect;
        info->inDeviceSpace = NO;
        aligned = YES;
    }
    else {
        CGRect transformed = CGRectApplyAffineTransform(aRect, ctm);
        device = CGRectIntegral(transformed);
        width = lround(device.size.width);
        height = lround(device.size.height);
        aligned = !(ctm.b < -1e-7 || ctm.b > 1e-7 || ctm.c < -1e-7 || ctm.c > 1e-7 ||
                    transformed.origin.x < device.origin.x - 0.001953125 || transformed.origin.x > device.origin.x + 0.001953125 ||
                    transformed.origin.y < device.origin.y - 0.001953125 || transformed.origin.y > device.origin.y + 0.001953125 ||
                    transformed.size.width < device.size.width - 0.001953125 ||
                    transformed.size.width > device.size.width + 0.001953125 ||
                    transformed.size.height < device.size.height - 0.001953125 ||
                    transformed.size.height > device.size.height + 0.001953125);
        info->rect = device;
        info->inDeviceSpace = YES;
    }
    if (width && height) {
        [self setPixelsWide:width pixelsHigh:height statically:NO];
        // Only opaque if it's drawn opaque and pixel aligned.
        if (aOpacity < 0.998046875 || !aligned)
            [self removePixelBufferAttachmentForKey:(struct __CFString *)kCVEImageBufferOpaquenessKey];
        if ([self lockOpenGLFocus]) {
            GLdouble m[16] = { 0 };
            if (!sampleBuffers) {
                m[0] = aRect.size.width != 0 ? 2.0 / aRect.size.width : 1.0;
                m[5] = aRect.size.height != 0 ? 2.0 / aRect.size.height : 1.0;
                m[12] = -1.0 - aRect.origin.x * m[0];
                m[13] = -1.0 - aRect.origin.y * m[5];
            }
            else {
                CGFloat sx = device.size.width != 0 ? 2.0 / device.size.width : 1.0;
                CGFloat sy = device.size.height != 0 ? 2.0 / device.size.height : 1.0;
                m[0] = ctm.a * sx;
                m[1] = ctm.b * sy;
                m[4] = ctm.c * sx;
                m[5] = ctm.d * sy;
                m[12] = -1.0 - device.origin.x * sx + ctm.tx * sx;
                m[13] = -1.0 - device.origin.y * sy + ctm.ty * sy;
            }
            // Upside down, as the pixels are read.
            m[1] = -m[1];
            m[5] = -m[5];
            m[13] = -m[13];
            m[10] = 1;
            m[15] = 1;
            CGLContextObj cgl_ctx = _coreGLContext;
            glMatrixMode(GL_MODELVIEW);
            glLoadMatrixd(m);
            return YES;
        }
    }
    free(_layerInfo);
    _layerInfo = NULL;
    return NO;
}

- (BOOL)endOpenGLLayerForCGContext
{
    LayerInfo *info = _layerInfo;
    CGImageRef image = [self unlockOpenGLFocusAsImage];
    BOOL drawn = NO;
    if (image) {
        CGFloat opacity = info->opacity;
        if (opacity < 0.998046875)
            CGContextSetAlpha(info->context, 1.0);
        if (!info->inDeviceSpace)
            CGContextDrawImage(info->context, info->rect, image);
        else {
            CGAffineTransform ctm = CGContextGetCTM(info->context);
            CGContextConcatCTM(info->context, CGAffineTransformInvert(ctm));
            CGContextDrawImage(info->context, info->rect, image);
            CGContextConcatCTM(info->context, ctm);
        }
        if (opacity < 0.998046875)
            CGContextSetAlpha(info->context, opacity);
        CGImageRelease(image);
        drawn = YES;
    }
    free(_layerInfo);
    _layerInfo = NULL;
    return drawn;
}

@end
