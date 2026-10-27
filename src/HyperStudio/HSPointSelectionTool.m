#import "HSPointSelectionTool.h"

@implementation HSPointSelectionTool

- (void)trackingPointCanvasLayerDidCancelTracking
{
    if ([_delegate respondsToSelector:@selector(pointSelectionToolDidCancelSelection)])
        [_delegate pointSelectionToolDidCancelSelection];
}

- (void)trackingPointCanvasLayer:(id)aLayer didFinishTrackingWithPoint:(NSPoint)aPoint
{
    if (!NSEqualPoints(_selectedPoint, aPoint)) {
        _selectedPoint = aPoint;
        [_delegate pointSelectionTool:self selectedPointChange:aPoint];
    }
}

- (NSPoint)trackingPointCanvasLayer:(id)aLayer shouldChoosePoint:(NSPoint)aPoint
{
    return [(HSEditorCardView *)[self view] convertPointFromViewSpaceToUserSpace:aPoint];
}

- (id)trackingPointCanvasLayer
{
    if (_trackingPointCanvasLayer == nil)
        _trackingPointCanvasLayer = [HSTrackingPointCanvasLayer new];
    return _trackingPointCanvasLayer;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (NSPoint)selectedPoint
{
    return _selectedPoint;
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [[self trackingPointCanvasLayer] setDelegate:nil];
    id rootLayer = [[self view] rootCanvasLayer];
    [[rootLayer bitmapToolsCanvasLayer] removeAllSublayers];
    [rootLayer setEnabledSublayerIdentifiers:nil];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    [[self view] setOccupiedByTool:NO];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    [[self view] setOccupiedByTool:YES];
    [super didActivateExplicitly:aExplicitly];
    [[self trackingPointCanvasLayer] setDelegate:self];
    id rootLayer = [[self view] rootCanvasLayer];
    [[rootLayer bitmapToolsCanvasLayer] addSublayer:[self trackingPointCanvasLayer]];
    [rootLayer setEnabledSublayerIdentifiers:[rootLayer bitmapToolsIdentifiers]];
}

- (void)dealloc
{
    [_trackingPointCanvasLayer setDelegate:nil];
    [_trackingPointCanvasLayer release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _selectedPoint = NSZeroPoint;
    return self;
}

@end
