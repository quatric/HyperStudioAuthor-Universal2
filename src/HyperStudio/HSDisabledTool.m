#import "HSDisabledTool.h"

@implementation HSDisabledTool

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id rootLayer;

    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    rootLayer = [[self view] rootCanvasLayer];
    [[rootLayer vectorToolsCanvasLayer] removeSublayer:[self dummyLayer]];
    [rootLayer setEnabledSublayerIdentifiers:nil];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id rootLayer = [[self view] rootCanvasLayer];

    [[rootLayer vectorToolsCanvasLayer] addSublayer:[self dummyLayer]];
    [rootLayer setEnabledSublayerIdentifiers:[rootLayer vectorToolsIdentifiers]];
    [super didActivateExplicitly:aExplicitly];
}

- (id)dummyLayer
{
    if (_dummyLayer == nil)
        _dummyLayer = [HSAnimationSetupTryItCanvasLayer new];
    return _dummyLayer;
}

- (BOOL)shouldResetToolOnAddObjects
{
    return NO;
}

- (BOOL)allowsEditingToolView
{
    return NO;
}

- (void)dealloc
{
    [_dummyLayer release];
    [super dealloc];
}

@end
