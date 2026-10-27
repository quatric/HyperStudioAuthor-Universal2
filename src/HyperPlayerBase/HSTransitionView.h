#import "HyperPlayerBasePrefix.h"


@interface HSTransitionView : NSEView <HSCapturingDataSource, NSObject>
{
    id _transitionViewProxy;
    HSTransitionEffect *_transitionEffect;
    NSColor *_backgroundColor;
    HSTransitionPlayer *_transitionPlayer;
    CGSize _deviceSize;
    id<HSOpenGLTransitionRenderer> _openGLTransitionRenderer;
    id<HSQuartzTransitionRenderer> _quartzTransitionRenderer;
    id _startImageBuffer;
    id _endImageBuffer;
    id<HSTransitionViewDataSource> _dataSource;
    struct __CVPixelBufferPool *_pixelBufferPool;
    struct __CVBuffer *_startPixelBuffer;
    struct __CVBuffer *_endPixelBuffer;
    id _delegate;
    struct __CFDictionary *_activeConsumers;
    unsigned int _areDeviceSizeChangesObserved:1;
    unsigned int _scalesImagesToFit:1;
    unsigned int _isStartImageInvalid:1;
    unsigned int _isStartImageChangedForOpenGL:1;
    unsigned int _isStartImageChangedForQuartz:1;
    unsigned int _isEndImageInvalid:1;
    unsigned int _isEndImageChangedForOpenGL:1;
    unsigned int _isEndImageChangedForQuartz:1;
}
+ (id)createDefaultOpenGLContext;
- (void)stopCapturingForConsumer:(id)aConsumer;
- (void)startCapturingForConsumer:(id)aConsumer;
- (id)accessibilityFocusedUIElement;
- (BOOL)accessibilityIsIgnored;
- (BOOL)accessibilityIsAttributeSettable:(id)aSettable;
- (void)accessibilityPerformAction:(id)aAction;
- (id)accessibilityActionDescription:(id)aDescription;
- (id)accessibilityActionNames;
- (id)accessibilityHitTest:(NSPoint)aTest;
- (id)accessibilityAttributeValue:(id)aValue;
- (void)drawQuartzSurfaceRect:(NSRect)aRect;
- (void)HSTransitionView_synchronizeQuartzTransitionRenderer;
- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect;
- (void)drawQuartzFrameRect:(NSRect)aRect;
- (void)HSTransitionView_drawQuartzFrameInContext:(struct CGContext *)aContext;
- (void)HSTransitionView_drawImage:(id)aImage inContext:(struct CGContext *)aContext;
- (void)HSTransitionView_sendFrame:(struct __CVBuffer *)aFrame withTime:(double)aTime;
- (void)drawOpenGLFrame;
- (void)drawBackgroundRect:(NSRect)aRect;
- (void)transitionPlayerDidPlayNewFrame:(id)aFrame;
- (void)getOpenGLSurfaceProjectionMatrix:(float *)aMatrix forBounds:(NSRect)aBounds viewportRect:(NSRect)aRect;
- (void)changeOpenGLSurfaceViewportFrom:(int *)aFrom to:(int *)aTo;
- (void)disassociateOpenGLContext;
- (BOOL)shouldDisplayOpenGLSurface;
- (void)viewDidMoveToWindow;
- (BOOL)isOpaque;
- (void)transitionPlayerDidFinish:(id)aFinish;
- (void)setTransitionTime:(double)aTime;
- (double)transitionTime;
- (BOOL)isTransitionPlaying;
- (void)stopTransition;
- (BOOL)startTransition;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)invalidateEndImage;
- (void)invalidateStartImage;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (void)swapStartImageAndEndImage;
- (void)setStartImageAsEndImage;
- (void)setEndImageAsStartImage;
- (void)setEndImage:(id)aImage;
- (void)setStartImage:(id)aImage;
- (id)HSTransitionView_endImage;
- (id)HSTransitionView_startImage;
- (id)HSTransitionView_imageForImageBuffer:(id)aBuffer pixelBuffer:(struct __CVBuffer **)aBuffer2;
- (id)HSTransitionView_scaleImage:(id)aImage;
- (struct __CVPixelBufferPool *)HSTransitionView_pixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight;
- (void)setScalesImagesToFit:(BOOL)aFit;
- (BOOL)scalesImagesToFit;
- (void)setMaxRenderingFrameRate:(double)aRate;
- (double)maxRenderingFrameRate;
- (void)setTransitionPlayRangeStartTime:(double)aTime duration:(double)aDuration;
- (double)transitionPlayRangeDuration;
- (double)transitionPlayRangeStartTime;
- (void)setTransitionDuration:(double)aDuration;
- (double)transitionDuration;
- (void)setTransitionEffect:(id)aEffect;
- (id)transitionEffect;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (void)HSTransitionView_viewDidChangeDeviceSize:(id)aSize;
- (BOOL)HSTransitionView_isImageOfDeviceSize:(id)aSize;
- (void)HSTransitionView_invalidateQuartzTransitionRenderer;
- (id)HSTransitionView_quartzTransitionRenderer;
- (void)HSTransitionView_invalidateOpenGLTransitionRenderer;
- (id)HSTransitionView_openGLTransitionRenderer;
- (void)HSTransitionView_synchronizeDeviceSizeChangesObserving;
- (id)HSTransitionView_transitionPlayer;
- (id)HSTransitionView_proxy;
- (void)dealloc;
- (void)HSTransitionView_stopDeviceSizeChangesObserving;
- (void)HSTransitionView_startDeviceSizeChangesObserving;
- (void)pause;
- (void)resume;
- (void)setTransitionPlaybackController:(id)aController;
- (id)transitionPlaybackController;
@end

@interface NSObject (HSTransitionViewDelegate)
- (void)transitionViewDidFinishTransition:(id)aTransition;
- (void)transitionViewDidStopTransition:(id)aTransition;
@end

