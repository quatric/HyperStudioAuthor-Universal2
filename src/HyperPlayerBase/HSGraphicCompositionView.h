#import "HyperPlayerBasePrefix.h"


@interface HSGraphicCompositionView : NSEView <HSCapturingDataSource, NSObject>
{
    id _graphicCompositionViewProxy;
    HSGraphicComposition *_graphicComposition;
    NSColor *_backgroundColor;
    HSGraphicCompositionPlayer *_graphicCompositionPlayer;
    CGSize _deviceSize;
    id<HSOpenGLGraphicCompositionRenderer> _openGLGraphicCompositionRenderer;
    id<HSQuartzGraphicCompositionRenderer> _quartzGraphicCompositionRenderer;
    struct __CFDictionary *_graphicCompositionInputs;
    id<HSGraphicCompositionViewDataSource> _dataSource;
    NSMutableSet *_invalidatedGraphicCompositionInputKeys;
    NSMutableSet *_pendingGraphicCompositionInputKeysForQuartzRenderer;
    NSMutableSet *_pendingGraphicCompositionInputKeysForOpenGLRenderer;
    id _delegate;
    struct __CFDictionary *_activeConsumers;
    struct __CVPixelBufferPool *_pixelBufferPool;
    unsigned int _stopsOnMouseClick:1;
    unsigned int _areDeviceSizeChangesObserved:1;
}
+ (id)createDefaultOpenGLContext;
- (void)stopCapturingForConsumer:(id)aConsumer;
- (void)startCapturingForConsumer:(id)aConsumer;
- (void)mouseDown:(id)aDown;
- (void)drawQuartzSurfaceRect:(NSRect)aRect;
- (BOOL)drawOpenGLSurfaceRect:(NSRect)aRect;
- (void)HSGraphicCompositionView_queryGraphicCompositionInputs;
- (void)drawQuartzFrameRect:(NSRect)aRect;
- (void)drawOpenGLFrame;
- (void)drawBackgroundRect:(NSRect)aRect;
- (void)graphicCompositionPlayerDidPlayNewFrame:(id)aFrame;
- (void)changeOpenGLSurfaceViewportFrom:(int *)aFrom to:(int *)aTo;
- (void)disassociateOpenGLContext;
- (BOOL)shouldDisplayOpenGLSurface;
- (struct __CVPixelBufferPool *)HSGraphicCompositionView_pixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight;
- (void)viewDidMoveToWindow;
- (BOOL)isOpaque;
- (void)graphicCompositionPlayerDidFinish:(id)aFinish;
- (void)setRenderingTime:(double)aTime;
- (double)renderingTime;
- (BOOL)isRendering;
- (void)stopRendering;
- (BOOL)startRendering;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)graphicCompositionInputValueForKey:(id)aKey;
- (void)setGraphicCompositionInputValue:(id)aValue forKey:(id)aKey;
- (void)HSGraphicCompositionView_graphicCompositionInputDidChangeForKey:(id)aKey;
- (void)invalidateGraphicCompositionInputForKey:(id)aKey;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (void)setGraphicComposition:(id)aComposition;
- (id)graphicComposition;
- (void)setStopsOnMouseClick:(BOOL)aClick;
- (BOOL)stopsOnMouseClick;
- (void)setMaxRenderingFrameRate:(double)aRate;
- (double)maxRenderingFrameRate;
- (void)setRenderingDuration:(double)aDuration;
- (double)renderingDuration;
- (void)setBackgroundColor:(id)aColor;
- (id)backgroundColor;
- (void)HSGraphicCompositionView_sendFrame:(struct __CVBuffer *)aFrame withTime:(double)aTime;
- (void)HSGraphicCompositionView_viewDidChangeDeviceSize:(id)aSize;
- (void)HSGraphicCompositionView_invalidateQuartzGraphicCompositionRenderer;
- (id)HSGraphicCompositionView_quartzGraphicCompositionRenderer;
- (void)HSGraphicCompositionView_invalidateOpenGLGraphicCompositionRenderer;
- (id)HSGraphicCompositionView_openGLGraphicCompositionRenderer;
- (HSGraphicCompositionPlayer *)HSGraphicCompositionView_graphicCompositionPlayer;
- (id)HSGraphicCompositionView_proxy;
- (void)dealloc;
- (void)HSGraphicCompositionView_stopDeviceSizeChangesObserving;
- (void)HSGraphicCompositionView_startDeviceSizeChangesObserving;
@end

@interface NSObject (HSGraphicCompositionViewDelegate)
- (void)graphicCompositionViewDidFinishRendering:(id)aRendering;
- (void)graphicCompositionViewDidStopRendering:(id)aRendering;
@end

