#import "HSPlayMovieActionPlayTool.h"

@implementation HSPlayMovieActionPlayTool

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    if ([[self delegate] respondsToSelector:@selector(playMovieActionPlayToolDidFinish:)])
        [[self delegate] playMovieActionPlayToolDidFinish:self];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

- (void)finalizeMovieTool
{
    if ([self cardObject] != nil)
        [[[[self view] rootCanvasLayer] arrowToolCanvasLayer] enableSublayerForIdentifier:@"HSSelectionCanvasLayer"];
}

- (void)activateMovieTool
{
    if ([self cardObject] != nil) {
        id root = [[self view] rootCanvasLayer];
        [[root arrowToolCanvasLayer] disableSublayerForIdentifier:@"HSSelectionCanvasLayer"];
        [root setEnabledSublayerIdentifiers:[root arrowToolIdentifiers]];
    }
}

@end
