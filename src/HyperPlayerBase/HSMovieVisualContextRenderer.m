#import "HSMovieVisualContextRenderer.h"
#import "HSThreadInvocationWrapper.h"

// Renders a movie's frames through a QuickTime visual context (HSQTKit's, on
// an AVPlayerItemVideoOutput). The current frame is fetched on demand and
// dropped when the context says a new one is available; the renderer posts
// HSMovieRendererWill/DidUpdateFrameImageNotification around that. While the
// movie plays, a timer checks for new frames 60 times a second.
//
// The bit fields: _isMovieOpaque (the movie has no alpha and nothing
// uncovered it), _isInterestedInFrameChangeNotifications (the current frame
// was fetched since the last change) and _isMovieInvalidationPending.

@implementation HSMovieVisualContextRenderer

static void HSMovieVisualContextRendererImageAvailable(QTVisualContextRef aContext, const CVTimeStamp *aTimeStamp, void *aRenderer)
{
    [(HSMovieVisualContextRenderer *)aRenderer HSMovieVisualContextRenderer_invalidateMovieOnMainThread];
}

// A video sample description of depth 32 has alpha.
+ (BOOL)HSMovieVisualContextRenderer_isAlphaPresentInMovie:(id)aMovie
{
    NSArray *tracks = [aMovie tracksOfMediaType:QTMediaTypeVideo];
    NSUInteger count = [tracks count];
    for (NSUInteger i = 0; i < count; i++) {
        for (id description in [[[tracks objectAtIndex:i] AVAssetTrack] formatDescriptions]) {
            CFTypeRef depth = CMFormatDescriptionGetExtension((CMFormatDescriptionRef)description, kCMFormatDescriptionExtension_Depth);
            if (depth != NULL && CFGetTypeID(depth) == CFNumberGetTypeID() && [(NSNumber *)depth intValue] == 32)
                return YES;
        }
    }
    return NO;
}

- (void)invalidateCurrentFrame
{
    CVBufferRelease(_currentFrameImageBuffer);
    _currentFrameImageBuffer = NULL;
}

- (void)didUpdateCurrentFrameImageBuffer:(struct __CVBuffer *)aBuffer
{
}

- (struct __CVBuffer *)currentFrameImageBuffer
{
    if (_currentFrameImageBuffer != NULL)
        return _currentFrameImageBuffer;
    QTVisualContextCopyImageForTime(_visualContext, kCFAllocatorDefault, NULL, &_currentFrameImageBuffer);
    // Fix: the original sets the attachment on a missing frame too.
    if (_isMovieOpaque && _currentFrameImageBuffer != NULL)
        CVBufferSetAttachment(_currentFrameImageBuffer, (CFStringRef)kCVEImageBufferOpaquenessKey, kCFBooleanTrue, kCVAttachmentMode_ShouldPropagate);
    _isInterestedInFrameChangeNotifications = 1;
    if (_currentFrameImageBuffer == NULL)
        return NULL;
    [self didUpdateCurrentFrameImageBuffer:_currentFrameImageBuffer];
    return _currentFrameImageBuffer;
}

- (id)posterImage
{
    return [_movie posterImage];
}

- (void)reattachToMovie
{
    SetMovieVisualContext([_movie quickTimeMovie], _visualContext);
    [self HSMovieVisualContextRenderer_installInvalidationTimerIfNeeded];
}

- (void)detachFromMovie
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:QTMovieRateDidChangeNotification object:_movie];
    if (_invalidationTimer != nil) {
        [self HSMovieVisualContextRenderer_invalidateMovie];
        [_invalidationTimer invalidate];
        [_invalidationTimer release];
        _invalidationTimer = nil;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"HSMovieRendererWillUpdateFrameImageNotification" object:self];
    [self invalidateCurrentFrame];
    [center postNotificationName:@"HSMovieRendererDidUpdateFrameImageNotification" object:self];
    SetMovieVisualContext([_movie quickTimeMovie], NULL);
}

- (void)dealloc
{
    if (_movie != nil) {
        CVBufferRelease(_currentFrameImageBuffer);
        [[NSNotificationCenter defaultCenter] removeObserver:self name:QTMovieRateDidChangeNotification object:_movie];
        [_invalidationTimer invalidate];
        [_invalidationTimer release];
        if (_visualContext != NULL) {
            QTVisualContextSetImageAvailableCallback(_visualContext, NULL, NULL);
            SetMovieVisualContext([_movie quickTimeMovie], NULL);
            QTVisualContextRelease(_visualContext);
        }
        [_movie release];
    }
    [_movieStorage release];
    [super dealloc];
}

// QuickTime's movie cover procs and start/stop time base callback are gone:
// the movie's rate notifications stand in for the callback, and nothing
// uncovers movie regions any more.
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage visualContext:(struct OpaqueQTVisualContext *)aContext
{
    self = [super init];
    if (self == nil)
        return nil;
    void *movie = [aMovie quickTimeMovie];
    if (movie != NULL) {
        _movie = [aMovie retain];
        _visualContext = QTVisualContextRetain(aContext);
        if (QTVisualContextSetImageAvailableCallback(_visualContext, HSMovieVisualContextRendererImageAvailable, self) == noErr
            && SetMovieVisualContext(movie, _visualContext) == noErr) {
            _isInterestedInFrameChangeNotifications = 1;
            [self HSMovieVisualContextRenderer_installInvalidationTimerIfNeeded];
            _isMovieOpaque = ![HSMovieVisualContextRenderer HSMovieVisualContextRenderer_isAlphaPresentInMovie:_movie];
            _movieStorage = [aStorage retain];
            return self;
        }
    }
    [self release];
    return nil;
}

- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage
{
    [super release];
    return nil;
}

- (id)initWithNSMovie:(id)aMovie
{
    QTMovie *movie = [QTMovie movieWithQuickTimeMovie:[aMovie QTMovie] disposeWhenDone:NO error:NULL];
    return [self initWithQTMovie:movie storage:aMovie];
}

- (id)init
{
    [super release];
    return nil;
}

// The original clears the uncovered region in the movie's GWorld; with no
// GWorld left, only the movie's opaqueness is given up.
- (void)HSMovieVisualContextRenderer_uncoverMovieRegion:(struct OpaqueRgnHandle *)aRegion
{
    _isMovieOpaque = 0;
}

- (void)HSMovieVisualContextRenderer_movieDidStartStop
{
    [self HSMovieVisualContextRenderer_installInvalidationTimerIfNeeded];
}

- (void)HSMovieVisualContextRenderer_movieRateDidChange:(NSNotification *)aNotification
{
    [self HSMovieVisualContextRenderer_movieDidStartStop];
}

- (void)HSMovieVisualContextRenderer_installInvalidationTimerIfNeeded
{
    if ([(QTMovie *)_movie rate] == 0) {
        if (_invalidationTimer != nil) {
            [self HSMovieVisualContextRenderer_invalidateMovie];
            [_invalidationTimer invalidate];
            [_invalidationTimer release];
            _invalidationTimer = nil;
        }
    } else if (_invalidationTimer == nil) {
        _invalidationTimer = [[NSThread hyperScheduledThreadTimerWithInterval:1.0 / 60.0 mainThreadTarget:self selector:@selector(HSMovieVisualContextRenderer_invalidateMovie) repeats:YES] retain];
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:QTMovieRateDidChangeNotification object:_movie];
    [center addObserver:self selector:@selector(HSMovieVisualContextRenderer_movieRateDidChange:) name:QTMovieRateDidChangeNotification object:_movie];
}

- (void)HSMovieVisualContextRenderer_invalidateMovieOnMainThread
{
    if (!_isMovieInvalidationPending) {
        _isMovieInvalidationPending = 1;
        [self performSelectorOnMainThread:@selector(HSMovieVisualContextRenderer_invalidateMovie) withObject:nil waitUntilDone:NO];
    }
}

- (void)HSMovieVisualContextRenderer_invalidateMovie
{
    if (_isInterestedInFrameChangeNotifications && QTVisualContextIsNewImageAvailable(_visualContext, NULL)) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"HSMovieRendererWillUpdateFrameImageNotification" object:self];
        [self invalidateCurrentFrame];
        _isInterestedInFrameChangeNotifications = 0;
        [center postNotificationName:@"HSMovieRendererDidUpdateFrameImageNotification" object:self];
    }
    QTVisualContextTask(_visualContext);
    _isMovieInvalidationPending = 0;
}

@end
