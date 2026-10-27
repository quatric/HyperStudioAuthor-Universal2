#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSDragSelectedObjectTool : HSTool
{
    HSSelectionCanvasLayer *_selectionCanvasLayer;
    id _delegate;
}
- (void)mouseUpHandled;
- (void)selectedObjectsCanvasLayerDidHandleMouseUp:(id)aUp;
- (id)selectedObjectsCanvasLayer;
- (void)selectionChanged;
- (void)selectionDidChange:(id)aChange;
- (id)selection;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (id)selectionCanvasLayer;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)dealloc;
@end

