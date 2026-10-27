#import "HSPlaceObjectTool.h"

@implementation HSPlaceObjectTool

- (void)placeObjectCanvasLayer:(id)aLayer mouseMovedToPoint:(NSPoint)aPoint
{
    if (!_needsAddObject) {
        [_delegate placeObjectTool:self setObjectPosition:aPoint];
        _lastPoint = aPoint;
    } else {
        [self addObject];
    }
}

- (void)cancelPlacingObjectForPlaceObjectCanvasLayer:(id)aLayer
{
    [self removeObject];
    [_delegate placingCanceledForPlaceObjectTool:self];
}

- (void)finishPlacingObjectForPlaceObjectCanvasLayer:(id)aLayer
{
    [_delegate placingFinishedForPlaceObjectTool:self atPoint:_lastPoint];
}

- (void)removeObject
{
    [_delegate removeObjectFromCardForPlaceObjectTool:self];
}

// The object is added to the card only once the pointer is inside the card
// view's scroll view.
- (void)addObject
{
    id view = [[self placeObjectCanvasLayer] renderingView];
    NSPoint mouse = [[view window] mouseLocationOutsideOfEventStream];
    NSScrollView *scrollView = [view enclosingScrollView];
    NSPoint inScroll = [scrollView convertPoint:mouse fromView:nil];
    if (!NSPointInRect(inScroll, [scrollView bounds])) {
        _needsAddObject = YES;
    } else {
        _needsAddObject = NO;
        [_delegate addObjectToCardForPlaceObjectTool:self];
        NSPoint viewPoint = [view convertPoint:mouse fromView:nil];
        NSPoint userPoint = [view convertPointFromViewSpaceToUserSpace:viewPoint];
        [_delegate placeObjectTool:self setObjectPosition:userPoint];
        _lastPoint = userPoint;
    }
}

- (void)run
{
    [self performSelectorOnMainThread:@selector(addObject) withObject:self waitUntilDone:NO];
}

- (id)placeObjectCanvasLayer
{
    if (!_placeObjectCanvasLayer) {
        _placeObjectCanvasLayer = [[HSPlaceObjectCanvasLayer alloc] init];
        [_placeObjectCanvasLayer setOwner:self];
    }
    return _placeObjectCanvasLayer;
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    id root = [[self view] rootCanvasLayer];
    [[root vectorToolsCanvasLayer] removeAllSublayers];
    [root setEnabledSublayerIdentifiers:nil];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id root = [[self view] rootCanvasLayer];
    if (root) {
        [[root vectorToolsCanvasLayer] addSublayer:[self placeObjectCanvasLayer]];
        [root setEnabledSublayerIdentifiers:[root vectorToolsIdentifiers]];
    }
    [super didActivateExplicitly:aExplicitly];
}

- (BOOL)allowsActiveInPlaceEditors
{
    return NO;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (BOOL)shouldResetToolOnSelectObjects
{
    return NO;
}

- (BOOL)shouldResetToolOnAddObjects
{
    return NO;
}

- (void)dealloc
{
    [_placeObjectCanvasLayer setOwner:nil];
    [_placeObjectCanvasLayer release];
    [super dealloc];
}

@end
