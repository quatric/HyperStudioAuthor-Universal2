#import "HSPlayMovieActionTool.h"

@implementation HSPlayMovieActionTool

- (id)selectedObjectsCanvasLayer
{
    return [[self selectionCanvasLayer] enabledSelectedObjectsLayer];
}

- (id)disablingCanvasLayer
{
    if (_disablingCanvasLayer == nil)
        _disablingCanvasLayer = [HSDisablingCanvasLayer new];
    return _disablingCanvasLayer;
}

- (id)selectionCanvasLayer
{
    if (_selectionCanvasLayer == nil)
        _selectionCanvasLayer = [HSSelectionCanvasLayer new];
    return _selectionCanvasLayer;
}

- (id)visualizationCanvasLayer
{
    if (_visualizationCanvasLayer == nil)
        _visualizationCanvasLayer = [[HSAuxiliaryVisualizationCanvasLayer alloc] initForRenderingCardNodes:NO];
    return _visualizationCanvasLayer;
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [self setCardObject:nil];
    if ([[self delegate] respondsToSelector:@selector(playMovieActionToolDidFinish:)])
        [[self delegate] playMovieActionToolDidFinish:self];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

- (void)finalizeMovieTool
{
}

- (void)activateMovieTool
{
}

- (void)setCardObject:(id)aObject
{
    if (_cardObject == aObject)
        return;
    id layer = [self visualizationCanvasLayer];
    if (_cardObject != nil) {
        [layer removeItemForNode:_cardObject];
        [self finalizeMovieTool];
    }
    [_cardObject release];
    _cardObject = [aObject retain];
    if (_cardObject != nil) {
        [layer addItemForNode:_cardObject];
        [self activateMovieTool];
    }
}

- (id)cardObject
{
    return _cardObject;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self setCardObject:nil];
    [_visualizationCanvasLayer release];
    [_disablingCanvasLayer release];
    [_selectionCanvasLayer release];
    [super dealloc];
}

@end
