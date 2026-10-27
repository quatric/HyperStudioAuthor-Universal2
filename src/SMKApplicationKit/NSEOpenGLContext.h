#import "SMKApplicationKitPrefix.h"


@interface NSEOpenGLContext : NSOpenGLContext
{
    unsigned int _retainCount;
    NSOpenGLPixelFormat *_format;
    struct OpaqueCMProfileRef *_colorSyncProfile;
    struct CGColorSpace *_coreGraphicsColorSpace;
    NSColorSpace *_colorSpace;
    struct __NSEOpenGLContextShareRecord *_shareRecord;
    unsigned int _isSurfaceTransparent:1;
}
+ (id)contextWithFormatAttributesSequence:(unsigned int *)aSequence shareCategory:(id)aCategory;
+ (id)contextWithFormatAttributes:(unsigned int *)aAttributes shareCategory:(id)aCategory;
+ (id)contextWithFormat:(id)aFormat shareCategory:(id)aCategory;
+ (id)allocWithZone:(NSZone *)aZone;
- (id)bindTextureForPixelBuffer:(struct __CVBuffer *)aBuffer target:(NSUInteger)aTarget border:(NSInteger)aBorder specifyingIfNeeded:(BOOL)aNeeded withOptions:(NSInteger)aOptions;
- (void)flush;
- (void)setCurrentVirtualScreen:(NSInteger)aScreen;
- (void)getValues:(int *)aValues forParameter:(NSInteger)aParameter;
- (void)setValues:(int *)aValues forParameter:(NSInteger)aParameter;
- (void)invalidateColorProfile;
- (id)colorSpace;
- (struct CGColorSpace *)CGColorSpace;
- (struct OpaqueCMProfileRef *)colorSyncProfile;
- (void)update;
- (void)clearDrawable;
- (id)shareCategory;
- (BOOL)sharesContext:(id)aContext;
- (id)format;
- (void)release;
- (id)retain;
- (void)dealloc;
- (id)initWithFormat:(id)aFormat shareContext:(id)aContext;
- (id)initWithFormatAttributesSequence:(unsigned int *)aSequence shareContext:(id)aContext;
- (id)initWithFormatAttributes:(unsigned int *)aAttributes shareContext:(id)aContext;
- (void)NSEOpenGLContext_shareInCategory:(id)aCategory;
- (struct __NSEOpenGLContextShareRecord *)NSEOpenGLContext_addShareContext:(id)aContext;
- (BOOL)NSEOpenGLContext_createShareRecordAddingShareContext:(id)aContext remainingLocked:(BOOL)aLocked;
- (struct __NSEOpenGLContextShareRecord *)NSEOpenGLContext_shareRecord;
@end

@interface __NSEOpenGLContextShareRecordPixelBufferRemover : NSObject
{
    struct __CVBuffer *_pixelBuffer;
}
- (void)dealloc;
- (id)initWithPixelBuffer:(struct __CVBuffer *)aBuffer;
- (id)init;
@end

@interface __NSEPixelBufferOpenGLTexture : NSObject <NSEOpenGLTexture, NSObject>
{
    unsigned int _effectiveRetainCount;
    unsigned int _validnessBarrier;
    struct __CFSet *_shareContexts;
    unsigned int _name;
    unsigned int _target;
    int _border;
    struct __CVBuffer *_pixelBuffer;
    unsigned int _isBufferOwner:1;
}
+ (id)allocWithZone:(NSZone *)aZone;
- (id)buffer;
- (NSInteger)border;
- (NSUInteger)target;
- (NSUInteger)name;
- (BOOL)isInContext:(id)aContext;
- (void)invalidate;
- (BOOL)isValid;
- (void)validateWithName:(NSUInteger)aName pixelBuffer:(BOOL)aBuffer;
- (BOOL)isValidated;
- (void)serviceRelease;
- (id)serviceRetain;
- (void)release;
- (id)retain;
- (void)__NSEPixelBufferOpenGLTexture_invalidate;
- (void)dealloc;
- (id)initWithShareContexts:(struct __CFSet *)aContexts target:(NSUInteger)aTarget border:(NSInteger)aBorder pixelBuffer:(struct __CVBuffer *)aBuffer;
- (id)init;
@end

@interface NSOpenGLPixelFormat (NSEOpenGLPixelFormat)
+ (id)NSE_pixelFormatWithAttributesSequence:(unsigned int *)aSequence;
@end

