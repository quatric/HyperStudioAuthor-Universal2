#import "HyperStudioPrefix.h"
#import "HSPlayMovieActionTool.h"


@interface HSPlayMovieActionPositionTool : HSPlayMovieActionTool
{
    HSDisablingDragCanvasLayer *_disablingDragCanvasLayer;
}
- (void)selectionChanged;
- (void)selectionDidChange:(id)aChange;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (BOOL)shouldResetToolOnSelectObjects;
- (id)selection;
- (void)finalizeMovieTool;
- (void)activateMovieTool;
- (id)disablingDragCanvasLayer;
- (void)dealloc;
@end

