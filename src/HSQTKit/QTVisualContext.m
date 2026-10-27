#import "HSQTKit.h"
#import <objc/runtime.h>

// QuickTime's pixel buffer visual context on an AVPlayerItemVideoOutput. A
// context follows the movie it's set on: the movie makes its player item again
// after edits, so the output moves to the current item whenever it's asked
// for an image. QuickTime calls the image available callback as frames are
// decoded; here it's called after the context is set on a movie and after the
// item's time jumps (a seek or a step while stopped), once the output has the
// new frame. While a movie plays, its renderer polls for frames itself.
// The OpenGL texture context hands out the frames as textures of a
// CVOpenGLTextureCache instead.

NSString * const kQTVisualContextPixelBufferAttributesKey = @"PixelBufferAttributes";
NSString * const kQTVisualContextOutputColorSpaceKey = @"OutputColorSpace";

// The callback is retried while the output has no frame yet, for up to two seconds.
enum { kHSQTVisualContextMaxPolls = 120 };

static char sMovieVisualContextKey;

@interface HSQTVisualContext : NSObject
{
    NSDictionary *_pixelBufferAttributes;
    CGColorSpaceRef _outputColorSpace;
    QTMovie *_movie;                    // not retained: cleared when the context is taken off the movie
    AVPlayerItem *_item;
    AVPlayerItemVideoOutput *_output;
    CVPixelBufferRef _lastPixelBuffer;
    CVOpenGLTextureCacheRef _textureCache;
    CVOpenGLTextureRef _lastTexture;
    QTVisualContextImageAvailableCallback _imageAvailableCallback;
    void *_imageAvailableRefCon;
    NSUInteger _pollCount;
}
- (id)initWithOptions:(NSDictionary *)options;
- (id)initWithOptions:(NSDictionary *)options textureCache:(CVOpenGLTextureCacheRef)textureCache;
- (void)setMovie:(QTMovie *)movie;
- (void)setImageAvailableCallback:(QTVisualContextImageAvailableCallback)callback refCon:(void *)refCon;
- (BOOL)isNewImageAvailable;
- (CVImageBufferRef)copyImage;
@end

@implementation HSQTVisualContext

- (id)initWithOptions:(NSDictionary *)options
{
    self = [super init];
    if (self) {
        _pixelBufferAttributes = [[options objectForKey:kQTVisualContextPixelBufferAttributesKey] copy];
        id space = [options objectForKey:kQTVisualContextOutputColorSpaceKey];
        if (space)
            _outputColorSpace = CGColorSpaceRetain((CGColorSpaceRef)space);
    }
    return self;
}

- (id)initWithOptions:(NSDictionary *)options textureCache:(CVOpenGLTextureCacheRef)textureCache
{
    self = [self initWithOptions:options];
    if (self)
        _textureCache = CVOpenGLTextureCacheRetain(textureCache);
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self setMovie:nil];
    [_pixelBufferAttributes release];
    CGColorSpaceRelease(_outputColorSpace);
    CVPixelBufferRelease(_lastPixelBuffer);
    CVOpenGLTextureRelease(_lastTexture);
    CVOpenGLTextureCacheRelease(_textureCache);
    [super dealloc];
}

- (void)detachFromItem
{
    if (_item == nil)
        return;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:_item];
    [_item removeOutput:_output];
    [_output release];
    _output = nil;
    [_item release];
    _item = nil;
}

// Moves the output to the movie's current player item.
- (void)syncItem
{
    AVPlayerItem *item = [_movie AVPlayerItem];
    if (item == _item)
        return;
    [self detachFromItem];
    if (item == nil)
        return;
    _item = [item retain];
    _output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:_pixelBufferAttributes];
    [_item addOutput:_output];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemTimeJumped:)
                                                 name:AVPlayerItemTimeJumpedNotification object:_item];
}

- (void)setMovie:(QTMovie *)movie
{
    if (movie == _movie)
        return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollForImage) object:nil];
    _movie = movie;
    [self syncItem];
    if (_movie)
        [self schedulePoll];
}

- (void)setImageAvailableCallback:(QTVisualContextImageAvailableCallback)callback refCon:(void *)refCon
{
    _imageAvailableCallback = callback;
    _imageAvailableRefCon = refCon;
}

- (void)schedulePoll
{
    _pollCount = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pollForImage) object:nil];
    [self performSelector:@selector(pollForImage) withObject:nil afterDelay:0.0
                  inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)itemTimeJumped:(NSNotification *)notification
{
    if ([NSThread isMainThread])
        [self schedulePoll];
    else
        [self performSelectorOnMainThread:@selector(schedulePoll) withObject:nil waitUntilDone:NO];
}

- (void)pollForImage
{
    if (_movie == nil)
        return;
    if ([self isNewImageAvailable]) {
        if (_imageAvailableCallback)
            _imageAvailableCallback((QTVisualContextRef)self, NULL, _imageAvailableRefCon);
    }
    else if (++_pollCount < kHSQTVisualContextMaxPolls)
        [self performSelector:@selector(pollForImage) withObject:nil afterDelay:1.0 / 60.0
                      inModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (BOOL)isNewImageAvailable
{
    [self syncItem];
    return _output && [_output hasNewPixelBufferForItemTime:[_item currentTime]];
}

// The frame at the item's current time, or the last one when there's no new frame.
- (CVImageBufferRef)copyImage
{
    [self syncItem];
    if (_output) {
        CVPixelBufferRef buffer = [_output copyPixelBufferForItemTime:[_item currentTime] itemTimeForDisplay:NULL];
        if (buffer) {
            if (_outputColorSpace && CVBufferGetAttachment(buffer, kCVImageBufferCGColorSpaceKey, NULL) == NULL)
                CVBufferSetAttachment(buffer, kCVImageBufferCGColorSpaceKey, _outputColorSpace, kCVAttachmentMode_ShouldPropagate);
            CVPixelBufferRelease(_lastPixelBuffer);
            _lastPixelBuffer = buffer;
            if (_textureCache) {
                CVOpenGLTextureRef texture = NULL;
                CVOpenGLTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, buffer, NULL, &texture);
                if (texture) {
                    CVBufferPropagateAttachments(buffer, texture);
                    CVOpenGLTextureRelease(_lastTexture);
                    _lastTexture = texture;
                }
                CVOpenGLTextureCacheFlush(_textureCache, 0);
            }
        }
    }
    if (_textureCache)
        return CVOpenGLTextureRetain(_lastTexture);
    return CVPixelBufferRetain(_lastPixelBuffer);
}

@end

OSStatus QTPixelBufferContextCreate(CFAllocatorRef allocator, CFDictionaryRef attributes, QTVisualContextRef *newPixelBufferContext)
{
    if (newPixelBufferContext == NULL)
        return paramErr;
    *newPixelBufferContext = (QTVisualContextRef)[[HSQTVisualContext alloc] initWithOptions:(NSDictionary *)attributes];
    return *newPixelBufferContext ? noErr : memFullErr;
}

// Frames in BGRA pixel buffers OpenGL can take, made into textures for the context.
OSStatus QTOpenGLTextureContextCreate(CFAllocatorRef allocator, CGLContextObj cglContext, CGLPixelFormatObj cglPixelFormat, CFDictionaryRef attributes, QTVisualContextRef *newTextureContext)
{
    if (newTextureContext == NULL || cglContext == NULL || cglPixelFormat == NULL)
        return paramErr;
    *newTextureContext = NULL;
    CVOpenGLTextureCacheRef cache = NULL;
    if (CVOpenGLTextureCacheCreate(allocator, NULL, cglContext, cglPixelFormat, NULL, &cache) != kCVReturnSuccess || cache == NULL)
        return paramErr;
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)attributes];
    if ([options objectForKey:kQTVisualContextPixelBufferAttributesKey] == nil)
        [options setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
                            [NSNumber numberWithBool:YES], kCVPixelBufferOpenGLCompatibilityKey, nil]
                    forKey:kQTVisualContextPixelBufferAttributesKey];
    *newTextureContext = (QTVisualContextRef)[[HSQTVisualContext alloc] initWithOptions:options textureCache:cache];
    CVOpenGLTextureCacheRelease(cache);
    return *newTextureContext ? noErr : memFullErr;
}

QTVisualContextRef QTVisualContextRetain(QTVisualContextRef visualContext)
{
    return (QTVisualContextRef)[(HSQTVisualContext *)visualContext retain];
}

void QTVisualContextRelease(QTVisualContextRef visualContext)
{
    [(HSQTVisualContext *)visualContext release];
}

OSStatus QTVisualContextSetImageAvailableCallback(QTVisualContextRef visualContext, QTVisualContextImageAvailableCallback imageAvailableCallback, void *refCon)
{
    if (visualContext == NULL)
        return paramErr;
    [(HSQTVisualContext *)visualContext setImageAvailableCallback:imageAvailableCallback refCon:refCon];
    return noErr;
}

Boolean QTVisualContextIsNewImageAvailable(QTVisualContextRef visualContext, const CVTimeStamp *timeStamp)
{
    return visualContext && [(HSQTVisualContext *)visualContext isNewImageAvailable];
}

OSStatus QTVisualContextCopyImageForTime(QTVisualContextRef visualContext, CFAllocatorRef allocator, const CVTimeStamp *timeStamp, CVImageBufferRef *newImage)
{
    if (visualContext == NULL || newImage == NULL)
        return paramErr;
    *newImage = [(HSQTVisualContext *)visualContext copyImage];
    return *newImage ? noErr : -1;
}

void QTVisualContextTask(QTVisualContextRef visualContext)
{
}

// The movie handle is the QTMovie (see -quickTimeMovie).
OSStatus SetMovieVisualContext(void *theMovie, QTVisualContextRef visualContext)
{
    QTMovie *movie = (QTMovie *)theMovie;
    if (movie == nil)
        return paramErr;
    HSQTVisualContext *old = objc_getAssociatedObject(movie, &sMovieVisualContextKey);
    if (old == (HSQTVisualContext *)visualContext)
        return noErr;
    [old setMovie:nil];
    [(HSQTVisualContext *)visualContext setMovie:movie];
    objc_setAssociatedObject(movie, &sMovieVisualContextKey, (HSQTVisualContext *)visualContext, OBJC_ASSOCIATION_RETAIN);
    return noErr;
}
