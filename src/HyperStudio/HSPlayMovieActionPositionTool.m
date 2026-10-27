#import "HSPlayMovieActionPositionTool.h"

@implementation HSPlayMovieActionPositionTool

- (void)selectionChanged
{
    if ([[self delegate] respondsToSelector:@selector(userDidFinishPlayMovieActionSetupTool:)])
        [[self delegate] userDidFinishPlayMovieActionSetupTool:self];
}

- (void)selectionDidChange:(id)aChange
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNodeSelectionDidChangeNotification" object:[self selection]];
    [self performSelector:@selector(selectionChanged) withObject:nil afterDelay:0.0
                  inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSEventTrackingRunLoopMode, NSModalPanelRunLoopMode, nil]];
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [[self view] setOccupiedByTool:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSNodeSelectionDidChangeNotification" object:[self selection]];
    if ([[self delegate] respondsToSelector:@selector(playMovieActionPositionToolDidFinish:)])
        [[self delegate] playMovieActionPositionToolDidFinish:self];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    [[self view] setOccupiedByTool:YES];
    [super didActivateExplicitly:aExplicitly];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionDidChange:) name:@"HSNodeSelectionDidChangeNotification" object:[self selection]];
}

- (BOOL)shouldResetToolOnSelectObjects
{
    return NO;
}

- (id)selection
{
    return [[self view] selection];
}

- (void)finalizeMovieTool
{
    if ([self cardObject] != nil) {
        id rootLayer = [[self view] rootCanvasLayer];
        [[rootLayer vectorToolsCanvasLayer] removeAllSublayers];
        [rootLayer setEnabledSublayerIdentifiers:nil];
    }
}

- (void)activateMovieTool
{
    if ([self cardObject] != nil) {
        id dragLayer = [self disablingDragCanvasLayer];
        [dragLayer setDragDisableModifier:NSEventModifierFlagOption];
        id rootLayer = [[self view] rootCanvasLayer];
        id toolsLayer = [rootLayer vectorToolsCanvasLayer];
        [toolsLayer removeAllSublayers];
        [toolsLayer addSublayer:[self disablingCanvasLayer]];
        [toolsLayer addSublayer:[self visualizationCanvasLayer]];
        [toolsLayer addSublayer:[self selectionCanvasLayer]];
        [toolsLayer addSublayer:dragLayer];
        [rootLayer setEnabledSublayerIdentifiers:[rootLayer vectorToolsIdentifiers]];
    }
}

- (id)disablingDragCanvasLayer
{
    if (_disablingDragCanvasLayer == nil)
        _disablingDragCanvasLayer = [HSDisablingDragCanvasLayer new];
    return _disablingDragCanvasLayer;
}

- (void)dealloc
{
    [_disablingDragCanvasLayer release];
    [super dealloc];
}

@end
