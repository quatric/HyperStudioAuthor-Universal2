#import "HSRectSelectionTool.h"

@implementation HSRectSelectionTool

- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    id root = [[self view] rootCanvasLayer];
    [[root bitmapToolsCanvasLayer] addSublayer:[[[HSTrackingRectCanvasLayer alloc] init] autorelease]];
    [root setEnabledSublayerIdentifiers:[root bitmapToolsIdentifiers]];
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    id root = [[self view] rootCanvasLayer];
    [[root bitmapToolsCanvasLayer] removeAllSublayers];
    [root setEnabledSublayerIdentifiers:nil];
}

@end
