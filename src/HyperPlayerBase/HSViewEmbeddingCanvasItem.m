#import "HSViewEmbeddingCanvasItem.h"

// Canvas item that shows a lazily created Cocoa view as a subview of the
// rendering view while active. Subclasses provide createView and the frame.
@implementation HSViewEmbeddingCanvasItem
- (void)removeViewFromSuperview
{
    [_view removeFromSuperview];
}
- (void)invalidateParentCanvasLayer
{
    _activeParentCanvasLayer = nil;
}
- (void)deactivate
{
    [self removeViewFromSuperview];
    _activeParentCanvasLayer = nil;
}
- (void)activateInCanvasLayer:(id)aLayer
{
    _activeParentCanvasLayer = aLayer;
    NSView *view = [self viewCreateIfNeeded:YES];
    NSView *renderingView = [[_activeParentCanvasLayer context] renderingView];
    [self setupViewFrameInCanvasLayer:aLayer];
    [renderingView addSubview:view];
    if ([view acceptsFirstResponder])
        [[renderingView window] makeFirstResponder:view];
}
- (id)renderingRegionInCanvasLayer:(id)aLayer
{
    return nil;
}
- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    return [self isActive] ? [_view frame] : NSZeroRect;
}
- (BOOL)prefersRegionInvalidation
{
    return NO;
}
static BOOL HSViewEmbeddingCanvasItem_rectsDiffer(NSRect aRect1, NSRect aRect2)
{
    CGFloat xScale1 = fabs(aRect1.origin.x) + aRect1.size.width, xScale2 = fabs(aRect2.origin.x) + aRect2.size.width;
    CGFloat yScale1 = fabs(aRect1.origin.y) + aRect1.size.height, yScale2 = fabs(aRect2.origin.y) + aRect2.size.height;
    CGFloat xScale = MAX(xScale1 != 0.0 ? fabs(xScale1) : 1.0, xScale2 != 0.0 ? fabs(xScale2) : 1.0);
    CGFloat yScale = MAX(yScale1 != 0.0 ? fabs(yScale1) : 1.0, yScale2 != 0.0 ? fabs(yScale2) : 1.0);
    return xScale * 0.0005 < fabs(aRect1.origin.x - aRect2.origin.x)
        || yScale * 0.0005 < fabs(aRect1.origin.y - aRect2.origin.y)
        || xScale * 0.0005 < fabs(aRect1.size.width - aRect2.size.width)
        || yScale * 0.0005 < fabs(aRect1.size.height - aRect2.size.height);
}
- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    NSRect oldBounds = [self renderingBoundsInCanvasLayer:aLayer];
    [self setupViewFrameInCanvasLayer:aLayer];
    NSRect newBounds = [self renderingBoundsInCanvasLayer:aLayer];
    return HSViewEmbeddingCanvasItem_rectsDiffer(oldBounds, newBounds);
}
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return nil;
}
- (BOOL)hitTestPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    return NO;
}
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
}
- (id)createView
{
    return nil;
}
- (void)setupViewFrameInCanvasLayer:(id)aLayer
{
}
- (id)activeParentCanvasLayer
{
    return _activeParentCanvasLayer;
}
- (BOOL)isActive
{
    return _activeParentCanvasLayer != nil;
}
- (id)view
{
    return _view;
}
- (void)dereferenceView:(id)aView
{
}
- (void)willDisposeView:(id)aView
{
}
- (void)setupView:(id)aView
{
}
- (void)invalidateView
{
    if (_view) {
        [self willDisposeView:_view];
        [_view release];
    }
    _view = nil;
}
- (id)viewCreateIfNeeded:(BOOL)aNeeded
{
    if (_view == nil && aNeeded) {
        _view = [self createView];
        [self setupView:_view];
    }
    return _view;
}
- (void)dealloc
{
    if (_view) {
        [self willDisposeView:_view];
        [_view release];
    }
    [super dealloc];
}
@end
