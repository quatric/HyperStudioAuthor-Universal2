#import "HyperPlayerBasePrefix.h"
#import "HSTransitionView.h"


@interface HSSlideshow : NSObject
{
    NSView *_ownContentView;
    NSView *_slideshowContentView;
    HSTransitionView *_transitionView;
    NSTimer *_autoPlayTimer;
    id _dataSource;
    id _delegate;
    HSSlideshowAttributes *_slideshowAttributes;
    unsigned int _indexOfCurrentSlideshowItem;
    NSMapTable *_cachedItems;
    BOOL _isRunning;
    BOOL _isPaused;
}
+ (id)sharedHSSlideshow;
- (id)transitionView;
- (void)setIndexOfCurrentSlideshowItem:(NSUInteger)aItem;
- (NSUInteger)indexOfCurrentSlideshowItem;
- (void)reloadSlideshowItemAtIndex:(NSUInteger)aIndex;
- (void)reloadData;
- (id)dataSource;
- (void)resumeSlideshow;
- (void)pauseSlideshow;
- (void)stopSlideshow:(id)aSlideshow;
- (void)runSlideshowWithDataSource:(id)aSource delegate:(id)aDelegate options:(id)aOptions;
- (void)dealloc;
- (id)init;
- (BOOL)HSSlideshow_shouldSlideshowStepOnKeystroke;
- (BOOL)HSSlideshow_shouldSlideshowStopOnKeystroke:(id)aKeystroke;
- (BOOL)HSSlideshow_shouldSlideshowStepOnMouseClick;
- (BOOL)HSSlideshow_shouldSlideshowStopOnMouseClick;
- (void)defaultSlideshowAttributesDidChange:(id)aChange;
- (void)HSSlideshow_updateTransition;
- (void)setDelegate:(id)aDelegate;
- (void)setDataSource:(id)aSource;
- (void)maintainTransitionView;
- (void)transitionViewDidFinishTransition:(id)aTransition;
- (void)transitionViewDidStopTransition:(id)aTransition;
- (void)HSSlideshow_stepSlideshow:(id)aSlideshow;
- (void)HSSlideshow_transitionDidEnd;
- (void)HSSlideshow_autoPlay;
- (BOOL)shouldStop;
- (id)itemAtIndex:(NSUInteger)aIndex;
- (NSUInteger)indexOfNextSlideshowItem;
- (NSUInteger)itemCount;
- (void)setSlideshowAttributes:(id)aAttributes;
- (id)window;
- (BOOL)isRunningInExternalView;
- (void)setSlideshowContentView:(id)aView;
- (id)slideshowContentView;
- (BOOL)isRunning;
@end

@interface HSSlideshow_HSTransitionView : HSTransitionView
{
}
- (void)keyDown:(id)aDown;
- (void)mouseUp:(id)aUp;
- (BOOL)acceptsFirstResponder;
@end

