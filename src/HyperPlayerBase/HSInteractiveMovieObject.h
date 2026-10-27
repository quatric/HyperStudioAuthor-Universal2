#import "HyperPlayerBasePrefix.h"
#import "HSInteractiveViewItem.h"


@interface HSInteractiveMovieObject : HSInteractiveViewItem
{
    QTMovieView *_movieView;
    id<HSMovieObjectAttributes> _movieObjectAttributes;
    QTMovie *_movieForView;
    void *_qtvrImagingCompleteUPP;
    unsigned int _isInteractiveMovie:1;
    unsigned int _wasOpenGLEnabled:1;
}
- (void)mediaWillChange:(id)aChange;
- (id)HSInteractiveMovieObject_movieForView;
- (id)HSInteractiveMovieObject_hyperMovieObjectAttributes;
- (void)deactivate;
- (void)activateInCanvasLayer:(id)aLayer;
- (void)setupViewFrameInCanvasLayer:(id)aLayer;
- (void)setupView:(id)aView;
- (id)createView;
- (BOOL)objectCanBeActivated;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer;
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext;
- (NSInteger)hitTestMovieWithController:(NSPoint)aController inContext:(id)aContext;
- (NSRect)movieFrameInContext:(id)aContext;
- (id)movieWithController;
- (void)dealloc;
- (id)initWithNode:(id)aNode;
@end

