#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSPlayMovieActionTool : HSTool
{
    HSAuxiliaryVisualizationCanvasLayer *_visualizationCanvasLayer;
    HSSelectionCanvasLayer *_selectionCanvasLayer;
    HSDisablingCanvasLayer *_disablingCanvasLayer;
    HSNode *_cardObject;
    id _delegate;
}
- (id)selectedObjectsCanvasLayer;
- (id)disablingCanvasLayer;
- (id)selectionCanvasLayer;
- (id)visualizationCanvasLayer;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeMovieTool;
- (void)activateMovieTool;
- (void)setCardObject:(id)aObject;
- (id)cardObject;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

