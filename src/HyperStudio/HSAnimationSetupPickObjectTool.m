#import "HSAnimationSetupPickObjectTool.h"

@implementation HSAnimationSetupPickObjectTool

- (void)cancelFromPickObjectCanvasLayer:(id)aLayer
{
    [_delegate cancelFromPickObjectTool:self];
}

- (void)animationPickObjectCanvasLayer:(id)aLayer pickedObject:(id)aObject final:(BOOL)aFinal event:(id)aEvent
{
    if ([aObject conformsToProtocol:@protocol(HSCannotBeAnimated)])
        return;
    [self highlightObject:aObject];
    if (aFinal)
        [_delegate animationEditModePickTool:self pickedObject:aObject event:aEvent];
}

- (void)highlightObject:(id)aObject
{
    if (_highlightedObject == aObject)
        return;
    if (_highlightedObject != nil) {
        [[self view] reenableVisualizationForNode:_highlightedObject];
        [[self visualizationCanvasLayer] removeItemForNode:_highlightedObject];
    }
    _highlightedObject = aObject;
    if (aObject != nil) {
        [[self visualizationCanvasLayer] addItemForNode:_highlightedObject];
        [[self view] disableVisualizationForNode:_highlightedObject];
    }
}

- (id)visualizationCanvasLayer
{
    if (_visualizationCanvasLayer == nil)
        _visualizationCanvasLayer = [[HSAuxiliaryVisualizationCanvasLayer alloc] initForRenderingCardNodes:NO];
    return _visualizationCanvasLayer;
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [self highlightObject:nil];
    [self setDelegate:nil];
    id rootLayer = [[self view] rootCanvasLayer];
    [[rootLayer vectorToolsCanvasLayer] removeAllSublayers];
    [rootLayer setEnabledSublayerIdentifiers:nil];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    [super didActivateExplicitly:aExplicitly];
    id rootLayer = [[self view] rootCanvasLayer];
    HSAnimationPickObjectCanvasLayer *pickLayer = [[[HSAnimationPickObjectCanvasLayer alloc] init] autorelease];
    [pickLayer setDelegate:self];
    [[rootLayer vectorToolsCanvasLayer] addSublayer:[[[HSDisablingCanvasLayer alloc] init] autorelease]];
    [[rootLayer vectorToolsCanvasLayer] addSublayer:[self visualizationCanvasLayer]];
    [[rootLayer vectorToolsCanvasLayer] addSublayer:pickLayer];
    [rootLayer setEnabledSublayerIdentifiers:[rootLayer vectorToolsIdentifiers]];
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

- (BOOL)shouldResetToolOnAddObjects
{
    return NO;
}

- (void)dealloc
{
    [_visualizationCanvasLayer release];
    [super dealloc];
}

@end
