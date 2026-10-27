#import "HyperPlayerBasePrefix.h"
#import "HSGraphicCompositionView.h"
#import "HSTransitionView.h"


@interface HSPlayerView : NSView <HSTransitionViewDataSource, HSCapturingDataSource, NSObject, HSCapturingConsumer>
{
    HSNavigationOperation *_navigationOperation;
    HSBackgroundRendererView *_backgroundView;
    BOOL _isFullScreen;
    NSView *_playerTopView;
    id _delegate;
    NSView *_containerView;
    NSView *_cardSuperview;
    HSPlayerCardView *_cardView;
    HSStack *_stack;
    NSView *_presentationView;
    HSGraphicCompositionView *_graphicCompositionView;
    HSCard *_transitionDestinationCard;
    HSCard *_transitionSourceCard;
    NSPoint _transitionCenter;
    HSRendererStreamDrawable *_transitionDestinationCardDrawable;
    HSRendererStreamDrawable *_transitionSourceCardDrawable;
    HSTransitionView *_transitionView;
    HSFluidSwipe *_handledSwipe;
    HSSlideshowAttributes *_liveSlideShowAttributes;
    HSSlideshow *_slideshow;
    NSView *_slideshowContentView;
    NSScrollView *_slideshowScrollView;
    HSCard *_originalCard;
    unsigned int _cardViewAutoresizingMask;
    unsigned int _containerViewAutoresizingMask;
    HSFullScreenAttributes *_fullScreenAttributes;
    id _defaultBackgroundRenderer;
    struct __CFDictionary *_activeConsumers;
    struct __CVPixelBufferPool *_pixelBufferPool;
    struct __CVBuffer *_cardViewPixelBuffer;
    struct __CVBuffer *_graphicCompositionViewPixelBuffer;
    struct __CVBuffer *_slideshowBackgroundPixelBuffer;
    unsigned int _inited:1;
    unsigned int _didHandleKeyEvent:1;
    unsigned int _isSlideShowModeEnabled:1;
    unsigned int _slideShowAttributesChanged:1;
    unsigned int _liveSlideshow:1;
    unsigned int _slideShowExecutedByAction:1;
    unsigned int _needOnceJumpToBegin:1;
    unsigned int _isBorderless:1;
    unsigned int _paused:1;
    unsigned int _delayedByAction:1;
    unsigned int _isPictureShow:1;
    unsigned int _wasOpenGLSurfaceEnabled:1;
    unsigned int _isTransitionDestinationCardRendererValid:1;
}
- (void)capturingDataSource:(id)aSource didOutputFrame:(struct __CVBuffer *)aFrame atTime:(double)aTime;
- (struct __CVBuffer *)HSPlayerView_createMixedFrameWithPixelBuffer:(struct __CVBuffer *)aBuffer andPixelBuffer:(struct __CVBuffer *)aBuffer2;
- (void)stopCapturingForConsumer:(id)aConsumer;
- (void)startCapturingForConsumer:(id)aConsumer;
- (void)removeSlideshowBackgroundPixelBuffer;
- (BOOL)createSlideshowBackgroundPixelBuffer;
- (struct __CVPixelBufferPool *)HSPlayerView_pixelBufferPoolWithWidth:(NSUInteger)aWidth height:(NSUInteger)aHeight;
- (void)cardView:(id)aView didSetCard:(id)aCard;
- (void)cardView:(id)aView willSetCard:(id)aCard;
- (void)presentationWillInterrupt;
- (void)performNavigationOperation:(id)aOperation;
- (void)setNavigationOperation:(id)aOperation;
- (void)goToCard:(id)aCard inStack:(id)aStack withTransition:(id)aTransition interruptSlideshow:(BOOL)aSlideshow;
- (void)HSPlayerView_goToCard:(id)aCard inStack:(id)aStack withTransition:(id)aTransition;
- (BOOL)isTransitionPlaying;
- (void)stopTransition;
- (void)showTransition:(id)aTransition;
- (id)endImageForTransitionView:(id)aView;
- (id)startImageForTransitionView:(id)aView;
- (void)transitionViewDidFinishTransition:(id)aTransition;
- (void)transitionViewDidStopTransition:(id)aTransition;
- (void)startTransitionView;
- (void)startTransition;
- (void)HSPlayerView_transitionDidEnd;
- (void)setTransitionSourceCard:(id)aCard;
- (id)transitionSourceCard;
- (void)setTransitionDestinationCard:(id)aCard;
- (id)transitionDestinationCard;
- (void)finishNavigationOperationIfNeeded;
- (void)doCommandBySelector:(SEL)aSelector;
- (void)insertText:(id)aText;
- (BOOL)handleMouseDownEvent:(id)aEvent;
- (BOOL)handleKeyDownEvent:(id)aEvent;
- (void)graphicCompositionViewDidFinishRendering:(id)aRendering;
- (void)graphicCompositionViewDidStopRendering:(id)aRendering;
- (BOOL)isGraphicCompositionPlaying;
- (void)stopGraphicComposition;
- (void)showGraphicComposition:(id)aComposition duringTimeInterval:(double)aInterval stopOnMouseClick:(BOOL)aClick;
- (void)HSPlayerView_graphicCompositionDidEnd;
- (void)pausePictureShow;
- (void)resumePictureShow;
- (BOOL)isPictureShow;
- (void)setOriginalCard:(id)aCard;
- (id)originalCard;
- (id)checkOptions:(id)aOptions;
- (id)transitionBackgroundColor;
- (BOOL)slideshowExecutedByAction;
- (id)slideshowAttributes;
- (id)HSPlayerView_slideShowAttributesFromDefaults;
- (void)stopSlideshow;
- (void)interruptSlideshow;
- (void)startSlideshowWithDataSource:(id)aSource options:(id)aOptions;
- (void)startSlideshowWithOptions:(id)aOptions;
- (void)startSlideshow;
- (BOOL)isBackgroundRatherLightInRect:(NSRect)aRect;
- (void)setupBackgroundAttributes;
- (id)presentationSettings;
- (id)backgroundRenderer;
- (void)setFullScreenAttributes:(id)aAttributes;
- (void)defaultBackgroundAttributesDidChange:(id)aChange;
- (void)stackDidChangeBackgroundAttributes:(id)aAttributes;
- (BOOL)isOpaque;
- (BOOL)includesBorderThicknessInOptimalSize;
- (NSSize)frameSizeForStackSize:(NSSize)aSize withScrollView:(BOOL)aView;
- (void)exitBorderlesMode;
- (void)makeBorderlessWithFullScreen:(BOOL)aScreen;
- (void)createBackgroundViewIfNeeded;
- (void)resumeSlideshowIfNeeded;
- (void)pauseSlideshowIfNeeded;
- (id)selfBackgroundColor;
- (NSUInteger)cardCount;
- (NSUInteger)activeCardIndex;
- (id)cardContainer;
- (void)setSlideshow:(id)aSlideshow;
- (id)slideshow;
- (void)setPresentationView:(id)aView;
- (id)presentationView;
- (BOOL)isFullScreen;
- (void)setIsSlideshow:(BOOL)aSlideshow;
- (BOOL)isSlideshow;
- (BOOL)canDoSlideshow;
- (id)nextCardForSlideshow;
- (id)nextCard;
- (id)activeCard;
- (void)setActiveCard:(id)aCard;
- (id)cardView;
- (id)containerView;
- (id)cardContainerView;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)centrateCardView;
- (void)adjustCardViewSize;
- (void)setStack:(id)aStack;
- (id)document;
- (id)stack;
- (void)awakeFromNib;
- (void)dealloc;
- (id)onceInit;
- (id)contentViewNibName;
- (Class)bundleIDClassForContentViewNib;
- (id)initWithCoder:(id)aCoder;
- (id)initWithFrame:(NSRect)aFrame;
- (void)rendererStreamDrawable:(id)aDrawable didAutoInvalidateInRects:(NSRect *)aRects count:(NSUInteger)aCount;
- (void)HSPlayerView_transitionDestinationCardDidChangeChildren:(id)aChildren;
- (void)HSPlayerView_showTransitionView;
- (id)HSPlayerView_transitionDestinationCardRenderer;
- (id)HSPlayerView_transitionView;
- (id)HSPlayerView_graphicCompositionView;
- (void)handleFluidSwipe:(id)aSwipe;
- (BOOL)canceledWithSwipe;
- (BOOL)isComplete;
- (double)transitionAmount;
- (void)pauseTransition;
- (void)resumeTransition;
- (void)viewDidChangeUserSpaceToViewSpaceTransform:(id)aTransform;
@end

@interface HSPlayerView_HSGraphicCompositionView : HSGraphicCompositionView
{
}
- (void)keyDown:(id)aDown;
- (BOOL)acceptsFirstResponder;
@end

@interface HSPlayerView_HSTransitionView : HSTransitionView
{
}
- (void)mouseDown:(id)aDown;
- (void)keyDown:(id)aDown;
- (BOOL)acceptsFirstResponder;
@end

@interface HSPlayerView (SimpleSlideShow)
- (void)performNavigationDidFinishForceNextSlide:(BOOL)aSlide;
- (void)performNavigationDidFinish;
- (BOOL)HSPlayerView_goToNextSlide;
- (void)ignoreDurationBetweenSlides;
- (void)returnToOriginalSlide;
- (void)navigationOperationDidFinish:(id)aFinish;
- (void)actionExecutionManagerDidBecomeIdle:(id)aIdle;
- (void)HSPlayerView_defaultSlideshowAttributesDidChange:(id)aChange;
@end

@interface HSPlayerView (HSPlayerViewIKSlideshowDataSource)
- (NSRect)slideshowFrame;
- (NSUInteger)slideshowAutoresizingMask;
- (NSUInteger)slideshowViewAllowsAddSubview;
- (id)slideshowView;
- (void)slideshowDidChangeCurrentIndex:(NSUInteger)aIndex;
- (void)slideshowDidStop;
- (void)slideshowWillStart;
- (void)unmountSlideshow;
- (void)mountSlideshow;
- (void)adjustSlideshowSize:(id)aSize;
- (BOOL)canExportSlideshowItemAtIndex:(NSUInteger)aIndex toApplication:(id)aApplication;
- (id)nameOfSlideshowItemAtIndex:(NSUInteger)aIndex;
- (id)slideshowItemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)numberOfSlideshowItems;
@end

