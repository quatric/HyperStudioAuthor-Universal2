#import "HSAnimationSetupTryItTool.h"

@implementation HSAnimationSetupTryItTool

- (void)cancelForTryItCanvasLayer:(id)aLayer
{
    [_delegate cancelForTryItTool:self];
}

- (id)tryItCanvasLayer
{
    if (_tryItCanvasLayer == nil) {
        _tryItCanvasLayer = [HSAnimationSetupTryItCanvasLayer new];
        [_tryItCanvasLayer setDelegate:self];
    }
    return _tryItCanvasLayer;
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
    id rootLayer = [[self view] rootCanvasLayer];
    [[rootLayer vectorToolsCanvasLayer] removeSublayer:[self tryItCanvasLayer]];
    [rootLayer setEnabledSublayerIdentifiers:nil];
}

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id rootLayer = [[self view] rootCanvasLayer];
    [[rootLayer vectorToolsCanvasLayer] addSublayer:[self tryItCanvasLayer]];
    [rootLayer setEnabledSublayerIdentifiers:[rootLayer vectorToolsIdentifiers]];
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

- (BOOL)shouldResetToolOnAddObjects
{
    return NO;
}

- (void)dealloc
{
    [_tryItCanvasLayer setDelegate:nil];
    [_tryItCanvasLayer release];
    [super dealloc];
}

- (BOOL)shouldResetToolOnSelectObjects
{
    return NO;
}

@end
