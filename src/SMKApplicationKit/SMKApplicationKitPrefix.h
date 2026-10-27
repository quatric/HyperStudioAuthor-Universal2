// Shared declarations for the SMKApplicationKit sources.
#import "HSSystemFrameworks.h"
#import "SMKApplicationKitData.h"
#import "CVEPixelBuffer.h"
#import "CGEContext.h"
#import "CGEColor.h"
#import "CGERegion.h"
#import "CGEPDF.h"
#import "CGEPath.h"
#import "CGEImage.h"
#import "CGEBitmapContext.h"
#import "CGELine.h"
#import "CGEText.h"
#import "SMKCapturedFunctions.h"
#import "CFEURL.h"

// Collections copy their elements to a depth: deep copies (NSE_copyToDepth)
// of elements that adopt these, plain copies of the others.
@protocol NSEDeepCopying <NSCopying>
- (id)NSE_copyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone;
@end
@protocol NSEDeepMutableCopying <NSMutableCopying>
- (id)NSE_mutableCopyToDepth:(NSUInteger)aDepth zone:(NSZone *)aZone;
@end
@protocol NSEControlTinterDelegate <NSObject>
@end
@protocol NSECountdownViewDelegate <NSObject>
@end
@protocol NSEOpenGLCGContextDestination <NSObject>
@end
@protocol NSEOpenGLTexture <NSObject>
@end
// Pixels read from OpenGL: as a pixel buffer, or an image of them.
@protocol NSEPixelBufferLink <NSObject>
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
@end
@protocol QTECaptureConsumer <NSObject>
@end
@protocol QTECaptureDeviceListItem <NSObject>
@end
@protocol QTECaptureSampleOutputFactory <NSObject>
@end
@protocol QTESampleConsumer <NSObject>
@end
@protocol QTESampleProcessor <NSObject>
@end
@protocol QTESampleProcessorDestination <NSObject>
@end

@class NSEBackgroundView;
@class NSEControlTinter;
@class NSECountdownView;
@class NSEMutableProtocolSet;
@class NSEOffscreenWindowOpenGLDrawable;
@class NSEOpenGLContext;
@class NSEOpenGLFramebufferClipper;
@class NSEPixelBufferOpenGLDrawable;
@class NSEProtocolSet;
@class NSETextureOpenGLDrawable;
@class NSEUndoProxy;
@class NSEView;
@class NSEWindow;
@class QTECaptureDeviceList;
@class QTECaptureMultisession;
@class QTEMultiformatPixelBufferSet;
@class QTEPixelFormatProcessor;
@class QTEVideoRecordingPanel;
@class __NSEControlTinterLink;
@class __NSEFileManagerPathDelegate;
@class __NSEFileManagerPathHandler;
@class __NSEFileManagerURLDelegate;
@class __NSEFileManagerURLHandler;
@class __NSEObjectProxy;
@class __NSEOpenGLContextShareRecordPixelBufferRemover;
@class __NSEOpenGLPixelBufferObject;
@class __NSEPixelBufferLink;
@class __NSEPixelBufferOpenGLTexture;
@class __NSEPixelBufferWrapper;
@class __NSEUndoAutogroupBreaker;
@class __NSEUndoAutogroupNamer;
@class __NSEWeakObjectProxy;
@class __NSEWindowShadowChild;
@class __QTECaptureDecompressedAudioOutput;
@class __QTECaptureDecompressedVideoOutput;
@class __QTESampleBufferData;
@class __QTESampleProcessorNode;

struct SMKApplicationKit_anon1 {
    unsigned int f0;
    id *f1;
    unsigned int *f2;
    unsigned int f3[5];
};

struct SMKApplicationKit_anon2 {
    unsigned int f0;
    int f1;
};

struct __QTEMenuAttachment {
    id f0;
    SEL f1;
    SEL f2;
    SEL f3;
    int f4;
    unsigned int f5:31;
    unsigned int f6:1;
};

struct SMKApplicationKit_anon3 {
    long long timeValue;
    int timeScale;
    int flags;
};

struct SMKApplicationKit_anon4 {
    long long f0;
    int f1;
    int f2;
};

// What contexts sharing their objects have in common.
struct __NSEOpenGLContextShareRecord {
    NSString *category;
    struct __CFSet *contexts;               // weak
    pthread_mutex_t mutex;                  // guards the textures
    pthread_cond_t *textureValidated;
    struct __CFSet *textures;
    struct __CFDictionary *pixelBufferTextures; // buffer (weak) -> texture, or {target, border} -> texture
};


struct CGEBitmapRect {
    int x;
    int y;
    unsigned int width;
    unsigned int height;
};

struct __NSEViewOpenGLSurfaceInvalidationInfo {
    pthread_mutex_t f0;
    unsigned int f1;
    struct __CFData *f2;
};

struct __NSEViewOpenGLDrawingInfo {
    CGAffineTransform f0;
    NSRect f1;
    NSRect f2;
    NSRect f3;
    NSRect f4;
    unsigned int f5;
    CGRect *f6;
    struct __CFData *f7;
    struct CGEBitmapRect f8;
    struct CGEBitmapRect *f9;
    NSRect f10;
    struct __CFData *f11;
    NSEOpenGLContext *f12;
    struct __NSEViewOpenGLQuartzTextureInfo *f13;
    unsigned int f14;
    unsigned int *f15;
    int f16;
};

struct __NSEViewQuartzLayer {
    char *f0;
    struct CGContext *f1;
    NSGraphicsContext *f2;
};

struct __QTESampleConsumerRecord {
    struct __QTESampleConsumerRecord *f0;
    struct __QTESampleConsumerRecord *f1;
    id<QTESampleConsumer> f2;
    NSDictionary *f3;
    unsigned long long f4;
    unsigned long long f5;
    unsigned int f6;
};

