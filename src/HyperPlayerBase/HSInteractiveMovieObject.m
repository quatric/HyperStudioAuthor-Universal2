#import "HSInteractiveMovieObject.h"
#import "HSActionEvent.h"
#import "HSActionMediaPlayer.h"
#import "HSCursor+EXCursor.h"
#import "HSMovie.h"
#import "HSMovieWithController.h"
#import "HSUserObjectView.h"
#import "HSVisualSystemViewLoader.h"
#import "NSEView.h"

// A movie object in interactive mode. Interactive movies (QuickTime VR and the
// like) are shown in a movie view while the object is active; the others are
// drawn by the card and handle clicks in their controller themselves.
//
// QuickTime VR is gone, so no prescreen imaging proc is installed to tell the
// card view the movie view was redrawn (_qtvrImagingCompleteUPP stays NULL).

@implementation HSInteractiveMovieObject

- (void)mediaWillChange:(id)aChange
{
    [_movieForView release];
    _movieForView = nil;
}

// Fix: the original drops a movie made earlier without releasing it.
- (id)HSInteractiveMovieObject_movieForView
{
    HSMovie *movie = [[self HSInteractiveMovieObject_hyperMovieObjectAttributes] hyperMovie];
    [_movieForView release];
    if (![movie isPanoramaObject] && ![movie isQTVRMovie])
        _movieForView = [[QTMovie alloc] initWithQuickTimeMovie:[movie quickTimeMovie] disposeWhenDone:NO error:NULL];
    else
        _movieForView = [movie createQTVRMovie];
    return _movieForView;
}

- (id)HSInteractiveMovieObject_hyperMovieObjectAttributes
{
    if (_movieObjectAttributes == nil)
        _movieObjectAttributes = [[[self hyperObject] queryHyperInterface:@protocol(HSMovieObjectAttributes)] retain];
    return _movieObjectAttributes;
}

// The card view's OpenGL surface was turned off while the movie view was up
// (some NVIDIA renderers draw over subviews); it's turned back on here.
- (void)deactivate
{
    if (!_isInteractiveMovie)
        return;
    _isInteractiveMovie = 0;
    HSMovie *movie = [[self HSInteractiveMovieObject_hyperMovieObjectAttributes] hyperMovie];
    if ([movie isPanoramaObject] || [movie isQTVRMovie]) {
        [movie setTiltAngle:[HSMovie tiltAngleForMovie:_movieForView]];
        [movie setPanAngle:[HSMovie panAngleForMovie:_movieForView]];
        [movie setFieldOfView:[HSMovie fieldOfViewForMovie:_movieForView]];
    }
    _qtvrImagingCompleteUPP = NULL;
    [movie activateMovieRenderer];
    [movie deactivateMovieRenderer];
    [super deactivate];
    [self invalidateView];
    [_movieView setMovie:nil];
    [_movieForView release];
    _movieForView = nil;
    [movie activateMovieRenderer];
    if (_wasOpenGLEnabled) {
        NSEView *view = [[[self activeParentCanvasLayer] context] renderingView];
        [view allowOpenGLRendererWithName:@"NVIDIA GeForce 320M OpenGL Engine" vendor:@"NVIDIA Corporation"];
        [view allowOpenGLRendererWithName:@"NVIDIA GeForce 9400 OpenGL Engine" vendor:@"NVIDIA Corporation"];
        [view allowOpenGLRendererWithName:@"NVIDIA GeForce 9400M OpenGL Engine" vendor:@"NVIDIA Corporation"];
        [view allowOpenGLRendererWithName:@"NVIDIA GeForce 9600M GT OpenGL Engine" vendor:@"NVIDIA Corporation"];
        [view enableOpenGLSurface];
        [view setNeedsDisplayInRect:[view openGLSurfaceBounds]];
    }
}

- (void)activateInCanvasLayer:(id)aLayer
{
    if (_isInteractiveMovie) {
        NSEView *view = [[aLayer context] renderingView];
        _wasOpenGLEnabled = [view isOpenGLSurfaceEnabled];
        if (_wasOpenGLEnabled) {
            [view disallowOpenGLRendererWithName:@"NVIDIA GeForce 320M OpenGL Engine" vendor:@"NVIDIA Corporation"];
            [view disallowOpenGLRendererWithName:@"NVIDIA GeForce 9400 OpenGL Engine" vendor:@"NVIDIA Corporation"];
            [view disallowOpenGLRendererWithName:@"NVIDIA GeForce 9400M OpenGL Engine" vendor:@"NVIDIA Corporation"];
            [view disallowOpenGLRendererWithName:@"NVIDIA GeForce 9600M GT OpenGL Engine" vendor:@"NVIDIA Corporation"];
            if (![view isOpenGLSurfaceEnabled])
                [view displayIfNeeded];
        }
        [(HSUserObjectView *)view beginRenderInteractiveSubview];
        [[[self HSInteractiveMovieObject_hyperMovieObjectAttributes] hyperMovie] deactivateMovieRenderer];
    }
    [super activateInCanvasLayer:aLayer];
}

- (void)setupViewFrameInCanvasLayer:(id)aLayer
{
    if (_isInteractiveMovie)
        [[self view] setFrame:[self movieFrameInContext:[[self activeParentCanvasLayer] context]]];
}

- (void)setupView:(id)aView
{
    if (_isInteractiveMovie && _movieView == aView)
        [_movieView setMovie:[self HSInteractiveMovieObject_movieForView]];
}

- (id)createView
{
    if (_isInteractiveMovie) {
        _movieView = [[HSVisualSystemViewLoader cocoaViewWithNibName:nibNameWithMovieView] retain];
        [_movieView setControllerVisible:[[self HSInteractiveMovieObject_hyperMovieObjectAttributes] hyperHasController]];
    }
    return _movieView;
}

- (BOOL)objectCanBeActivated
{
    BOOL interactive = [[[self HSInteractiveMovieObject_hyperMovieObjectAttributes] hyperMovie] isInteractiveMovie];
    _isInteractiveMovie = interactive;
    return interactive;
}

// Over the controller of a movie drawn by the card: the plain cursor.
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    id cursor = [super cursorAtPoint:aPoint modifierFlags:aFlags inCanvasLayer:aLayer];
    if (!_isInteractiveMovie && cursor == nil && [self hitTestMovieWithController:aPoint inContext:[aLayer context]] == 2) {
        id canvasContext = [aLayer queryHyperInterface:@protocol(HSInteractiveCanvasContext)];
        cursor = canvasContext != nil ? [canvasContext defaultInteractiveModeCursor] : [HSCursor defaultCursor];
    }
    return cursor;
}

// A click in the controller goes to the movie; elsewhere the object is
// dragged, resized or rotated if it can be, or else started or stopped if it
// starts on click.
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    if (_isInteractiveMovie) {
        [super trackMouseWithMouseDownEvent:aEvent inInteractiveContext:aContext];
        return;
    }
    id view = [[aContext context] renderingView];
    NSPoint point = [view convertPoint:[aEvent locationInWindow] fromView:nil];
    NSInteger hit = [self hitTestMovieWithController:point inContext:[aContext context]];
    BOOL wasDragged = NO;
    id<HSCardObjectAttributes> cardAttributes = [[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if (hit == 2) {
        id context = [aContext context];
        NSRect frame = [self movieFrameInContext:context];
        [(HSMovieWithController *)[self movieWithController] handleMouseDownInController:aEvent inView:[context renderingView] inMovieFrame:frame];
    } else {
        if ([cardAttributes isDraggable])
            [aContext trackMouseForDraggableItem:self withMouseDownEvent:aEvent wasDragged:&wasDragged];
        else if ([cardAttributes isResizable])
            [aContext trackMouseForResizableItem:self withMouseDownEvent:aEvent wasResized:&wasDragged];
        else if ([cardAttributes isRotatable])
            [aContext trackMouseForRotatableItem:self withMouseDownEvent:aEvent wasRotated:&wasDragged];
        if (!wasDragged) {
            id playable = [[self hyperObject] queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)];
            if (playable != nil && [playable isHyperStartingOnClick]) {
                BOOL playing = [[self hyperObject] isHyperPlaying];
                HSActionMediaPlayer *player = [HSActionMediaPlayer sharedActionMediaPlayer];
                if (playing)
                    [player stopMovie:[self hyperObject]];
                else
                    [player playMovie:[self hyperObject] movieOwner:nil];
            }
        }
    }
    if (![cardAttributes isNoClick] && ![cardAttributes isDropOffOnly] && hit == 1)
        [aContext sendClickActionsForItemIfNeeded:self];
    if (wasDragged)
        [aContext sendDropOffActionsFromItemIfNeeded:self];
}

- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return YES;
}

// A plain movie with nothing to do on a click lets it through.
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    if (_isInteractiveMovie)
        return NO;
    BOOL hasController = [[self HSInteractiveMovieObject_hyperMovieObjectAttributes] hyperHasController];
    BOOL startsOnClick = [[self HSInteractiveMovieObject_hyperMovieObjectAttributes] isHyperStartingOnClick];
    id<HSCardObjectAttributes> cardAttributes = [[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
    BOOL draggable = [cardAttributes isDraggable];
    BOOL resizable = [cardAttributes isResizable];
    BOOL rotatable = [cardAttributes isRotatable];
    NSUInteger clickActions = [[[[self hyperObject] actor] hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]] count];
    return clickActions == 0 && !startsOnClick && !hasController && !draggable && !resizable && !rotatable;
}

- (NSInteger)hitTestMovieWithController:(NSPoint)aController inContext:(id)aContext
{
    NSRect frame = [self movieFrameInContext:aContext];
    return [(HSMovieWithController *)[self movieWithController] hitTestPoint:aController inView:[aContext renderingView] inMovieFrame:frame];
}

// The object's frame in the view; with a usable controller, the part of it
// the movie takes.
- (NSRect)movieFrameInContext:(id)aContext
{
    id view = [aContext renderingView];
    id<HSGeometryAttributes> geometry = [[self hyperObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
    if (geometry == nil)
        return NSZeroRect;
    NSRect frame = [geometry frameBoundingRect];
    id attributes = [self HSInteractiveMovieObject_hyperMovieObjectAttributes];
    if ([attributes hyperHasController] && [attributes hyperCanUseController])
        frame = [(HSMovieWithController *)[self movieWithController] movieFrameForMovieArea:frame isFlipped:[view isFlipped]];
    return [view viewBoundingRectForUserRect:frame];
}

- (id)movieWithController
{
    return [[self hyperObject] movieWithController];
}

- (void)dealloc
{
    [[[self hyperObject] attributeObservingController] removeAttributeObserver:self];
    [_movieForView release];
    [_movieObjectAttributes release];
    [super dealloc];
}

- (id)initWithNode:(id)aNode
{
    self = [super initWithNode:aNode];
    if (self)
        [[[self hyperObject] attributeObservingController] addObserver:self selector:@selector(mediaWillChange:) ofChanges:1 ofAttribute:@protocol(HSMediaAttribute) withPriority:-0.25f];
    return self;
}

@end
