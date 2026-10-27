#import "HyperPlayerBasePrefix.h"


@interface HSMovieVisualContextRenderer : NSObject
{
    id _movieStorage;
    QTMovie *_movie;
    void *_movieRegionUncoverUPP;
    struct QTCallBackHeader *_movieStartStopCallBack;
    struct OpaqueQTVisualContext *_visualContext;
    NSTimer *_invalidationTimer;
    struct __CVBuffer *_currentFrameImageBuffer;
    unsigned int _isMovieOpaque:1;
    unsigned int _isInterestedInFrameChangeNotifications:1;
    unsigned int _isMovieInvalidationPending:1;
    unsigned int _isSynchronous:1;
}
+ (BOOL)HSMovieVisualContextRenderer_isAlphaPresentInMovie:(id)aMovie;
- (void)invalidateCurrentFrame;
- (void)didUpdateCurrentFrameImageBuffer:(struct __CVBuffer *)aBuffer;
- (struct __CVBuffer *)currentFrameImageBuffer;
- (id)posterImage;
- (void)reattachToMovie;
- (void)detachFromMovie;
- (void)dealloc;
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage visualContext:(struct OpaqueQTVisualContext *)aContext;
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage;
- (id)initWithNSMovie:(id)aMovie;
- (id)init;
- (void)HSMovieVisualContextRenderer_uncoverMovieRegion:(struct OpaqueRgnHandle *)aRegion;
- (void)HSMovieVisualContextRenderer_movieDidStartStop;
- (void)HSMovieVisualContextRenderer_installInvalidationTimerIfNeeded;
- (void)HSMovieVisualContextRenderer_invalidateMovieOnMainThread;
- (void)HSMovieVisualContextRenderer_invalidateMovie;
- (BOOL)isSynchronous;
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage synchronous:(BOOL)aSynchronous;
@end

