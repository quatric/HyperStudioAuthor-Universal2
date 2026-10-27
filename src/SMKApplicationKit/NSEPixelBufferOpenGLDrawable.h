#import "SMKApplicationKitPrefix.h"


@interface NSEPixelBufferOpenGLDrawable : NSObject
{
    unsigned int _pixelsWide;
    unsigned int _pixelsHigh;
    NSEOffscreenWindowOpenGLDrawable *_offscreenWindowOpenGLDrawable;
    struct _CGLContextObject *_coreGLContext;
    struct __CFDictionary *_pixelBufferPropagatedAttachments;
    struct __CFDictionary *_pixelBufferNonPropagatedAttachments;
    struct __CVPixelBufferPool *_pixelBufferPool;
    __NSEOpenGLPixelBufferObject *_pixelBufferObject;
    void *_layerInfo;
    unsigned int _pixelFormatType;
    unsigned int _isPixelBufferForceDisabled:1;
    unsigned int _isPixelBufferPoolSizeSynchronized:1;
    unsigned int _isPixelBufferPoolFormatSynchronized:1;
    unsigned int _isPixelBufferObjectExtensionPresent:1;
    unsigned int _isPixelBufferObjectRowLengthIgnored:1;
    unsigned int _isPixelBufferObjectBytesPerRow32ByteUnaligned:1;
    unsigned int _isPixelBufferObjectExtensionPresenceInitialized:1;
}
- (BOOL)endOpenGLLayerForCGContext;
- (BOOL)beginOpenGLLayerForCGContext:(struct CGContext *)aContext rect:(CGRect)aRect opacity:(CGFloat)aOpacity;
- (struct __CVBuffer *)unlockOpenGLFocusAsPixelBuffer;
- (struct CGImage *)unlockOpenGLFocusAsImageWithDecode:(const CGFloat *)aDecode interpolation:(BOOL)aInterpolation colorRenderingIntent:(NSInteger)aIntent;
- (struct CGImage *)unlockOpenGLFocusAsImage;
- (id)unlockOpenGLFocusAsPixelBufferLink;
- (id)NSEPixelBufferOpenGLDrawable_readPixelBufferObjectWithBytesPerRow:(NSUInteger)aRow rowLength:(NSInteger)aLength rowAlignment:(NSInteger)aAlignment openGLFormat:(NSUInteger)aFormat openGLType:(NSUInteger)aType;
- (BOOL)NSEPixelBufferOpenGLDrawable_isPixelBufferObjectExtensionPresentWithBytesPerRow:(unsigned int *)aRow rowLength:(int *)aLength rowAlignment:(int *)aAlignment openGLFormat:(unsigned int *)aFormat openGLType:(unsigned int *)aType;
- (struct __CVBuffer *)NSEPixelBufferOpenGLDrawable_readPixelBuffer;
- (void)unlockOpenGLFocus;
- (id)lockOpenGLFocus;
- (id)offscreenWindowOpenGLDrawable;
- (id)openGLContext;
- (struct __CVBuffer *)createEmptyPixelBuffer;
- (struct __CVPixelBufferPool *)NSEPixelBufferOpenGLDrawable_pixelBufferPool;
- (void)removeAllPixelBufferAttachmentsForMode:(NSUInteger)aMode;
- (void)removePixelBufferAttachmentForKey:(struct __CFString *)aKey;
- (void)setPixelBufferAttachments:(struct __CFDictionary *)aAttachments mode:(NSUInteger)aMode;
- (void)setPixelBufferAttachment:(void *)aAttachment forKey:(struct __CFString *)aKey mode:(NSUInteger)aMode;
- (struct __CFDictionary *)pixelBufferAttachmentsForMode:(NSUInteger)aMode;
- (void *)pixelBufferAttachmentForKey:(struct __CFString *)aKey mode:(unsigned int *)aMode;
- (struct __CFDictionary *)NSEPixelBufferOpenGLDrawable_pixelBufferNonPropagatedAttachments;
- (struct __CFDictionary *)NSEPixelBufferOpenGLDrawable_pixelBufferPropagatedAttachments;
- (void)setPixelBufferExtensionDisabled:(BOOL)aDisabled;
- (BOOL)isPixelBufferExtensionDisabled;
- (void)setPixelFormatType:(NSUInteger)aType statically:(BOOL)aStatically;
- (NSUInteger)pixelFormatType;
- (void)setPixelsWide:(NSUInteger)aWide pixelsHigh:(NSUInteger)aHigh statically:(BOOL)aStatically;
- (NSUInteger)pixelsHigh;
- (NSUInteger)pixelsWide;
- (void)dealloc;
- (id)initWithOffscreenWindowOpenGLDrawable:(id)aDrawable;
- (id)initWithOpenGLContext:(id)aContext;
- (id)init;
@end

@interface __NSEPixelBufferLink : NSObject <NSEPixelBufferLink, NSObject>
{
    __NSEOpenGLPixelBufferObject *_pixelBufferObject;
    unsigned int _pixelsWide;
    unsigned int _pixelsHigh;
    unsigned int _bytesPerRow;
    unsigned int _pixelFormatType;
    struct __CFDictionary *_nonPropagatedAttachments;
    struct __CFDictionary *_propagatedAttachments;
    struct __CVBuffer *_pixelBuffer;
}
- (struct __CVBuffer *)pixelBuffer;
- (struct CGImage *)newImageWithDecode:(const CGFloat *)aDecode interpolation:(BOOL)aInterpolation colorRenderingIntent:(NSInteger)aIntent;
- (void)removeAllAttachments;
- (void)removeAttachmentForKey:(struct __CFString *)aKey;
- (void)setAttachments:(struct __CFDictionary *)aAttachments mode:(NSUInteger)aMode;
- (void)setAttachment:(void *)aAttachment forKey:(struct __CFString *)aKey mode:(NSUInteger)aMode;
- (struct __CFDictionary *)attachmentsForMode:(NSUInteger)aMode;
- (void *)attachmentForKey:(struct __CFString *)aKey mode:(unsigned int *)aMode;
- (NSUInteger)dataSize;
- (NSUInteger)bytesPerRow;
- (NSUInteger)pixelFormatType;
- (NSUInteger)height;
- (NSUInteger)width;
- (void)dealloc;
- (id)initWithOpenGLPixelBufferObject:(id)aObject pixelsWide:(NSUInteger)aWide pixelsHigh:(NSUInteger)aHigh bytesPerRow:(NSUInteger)aRow pixelFormatType:(NSUInteger)aType nonPropagatedAttachments:(struct __CFDictionary *)aAttachments propagatedAttachments:(struct __CFDictionary *)aAttachments2;
- (id)init;
@end

@interface __NSEPixelBufferWrapper : NSObject <NSEPixelBufferLink, NSObject>
{
    struct __CVBuffer *_pixelBuffer;
}
- (struct __CVBuffer *)pixelBuffer;
- (struct CGImage *)newImageWithDecode:(const CGFloat *)aDecode interpolation:(BOOL)aInterpolation colorRenderingIntent:(NSInteger)aIntent;
- (void)removeAllAttachments;
- (void)removeAttachmentForKey:(struct __CFString *)aKey;
- (void)setAttachments:(struct __CFDictionary *)aAttachments mode:(NSUInteger)aMode;
- (void)setAttachment:(void *)aAttachment forKey:(struct __CFString *)aKey mode:(NSUInteger)aMode;
- (struct __CFDictionary *)attachmentsForMode:(NSUInteger)aMode;
- (void *)attachmentForKey:(struct __CFString *)aKey mode:(unsigned int *)aMode;
- (NSUInteger)dataSize;
- (NSUInteger)bytesPerRow;
- (NSUInteger)pixelFormatType;
- (NSUInteger)height;
- (NSUInteger)width;
- (void)dealloc;
- (id)initWithPixelBuffer:(struct __CVBuffer *)aBuffer;
- (id)init;
@end

@interface __NSEOpenGLPixelBufferObject : NSObject
{
    unsigned int _effectiveRetainCount;
    NSEOpenGLContext *_openGLContext;
    struct _CGLContextObject *_coreGLContext;
    unsigned int _pixelBufferObject;
    void *_pixels;
}
+ (id)allocWithZone:(NSZone *)aZone;
- (void)synchronize;
- (void *)pixels;
- (void)serviceRelease;
- (id)serviceRetain;
- (void)release;
- (id)retain;
- (void)invalidate;
- (id)initWithOpenGLContext:(id)aContext pixelBufferObject:(NSUInteger)aObject;
- (id)init;
@end

