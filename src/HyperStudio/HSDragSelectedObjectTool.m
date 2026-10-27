#import "HSDragSelectedObjectTool.h"

@implementation HSDragSelectedObjectTool

- (void)mouseUpHandled
{
    [self notifyManagerAtomOperationPerformedWithResult:YES];
}

- (void)selectedObjectsCanvasLayerDidHandleMouseUp:(id)aUp
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSSelectedObjectsCanvasLayerDidHandleMouseUpNotification" object:[self selectedObjectsCanvasLayer]];
    [self performSelector:@selector(mouseUpHandled) withObject:nil afterDelay:0.0 inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil]];
}

- (id)selectedObjectsCanvasLayer
{
    return [[self selectionCanvasLayer] enabledSelectedObjectsLayer];
}

- (void)selectionChanged
{
    if ([_delegate respondsToSelector:@selector(dragSelectedObjectToolDidFinish:)])
        [_delegate dragSelectedObjectToolDidFinish:self];
}

- (void)selectionDidChange:(id)aChange
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNodeSelectionDidChangeNotification" object:[self selection]];
    [self performSelector:@selector(selectionChanged) withObject:nil afterDelay:0.0 inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil]];
}

- (id)selection
{
    return [[self view] selection];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id rootLayer = [[self view] rootCanvasLayer];
    [[rootLayer vectorToolsCanvasLayer] addSublayer:[self selectionCanvasLayer]];
    [rootLayer setEnabledSublayerIdentifiers:[rootLayer vectorToolsIdentifiers]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:@"HSNodeSelectionDidChangeNotification" object:[self selection]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedObjectsCanvasLayerDidHandleMouseUp:) name:@"HSSelectedObjectsCanvasLayerDidHandleMouseUpNotification" object:[self selectedObjectsCanvasLayer]];
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNodeSelectionDidChangeNotification" object:[self selection]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSSelectedObjectsCanvasLayerDidHandleMouseUpNotification" object:[self selectedObjectsCanvasLayer]];
    id rootLayer = [[self view] rootCanvasLayer];
    [[rootLayer vectorToolsCanvasLayer] removeSublayer:_selectionCanvasLayer];
    [rootLayer setEnabledSublayerIdentifiers:nil];
}

- (id)selectionCanvasLayer
{
    if (_selectionCanvasLayer == nil)
        _selectionCanvasLayer = [[HSSelectionCanvasLayer alloc] init];
    return _selectionCanvasLayer;
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate)
        _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_selectionCanvasLayer release];
    _delegate = nil;
    [super dealloc];
}

@end
