#import "HSMagnifyingTool.h"

@implementation HSMagnifyingTool

- (id)layer
{
    if (_layer == nil) {
        _layer = [HSMagnifyingCanvasLayer new];
        [_layer setOwner:self];
    }
    return _layer;
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id root = [[self view] rootCanvasLayer];
    [[root vectorToolsCanvasLayer] addSublayer:[self layer]];
    [root setEnabledSublayerIdentifiers:[root vectorToolsIdentifiers]];
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id root = [[self view] rootCanvasLayer];
    [[root vectorToolsCanvasLayer] removeAllSublayers];
    [root setEnabledSublayerIdentifiers:nil];
}

- (void)dealloc
{
    [_layer release];
    [super dealloc];
}

@end
