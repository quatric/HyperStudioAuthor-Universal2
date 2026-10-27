#import "SMKBitmapToolsPrefix.h"
#import "BTTool.h"


@interface BTCreateFreeHandSelectionTool : BTTool <BTMouseTracker, NSObject>
{
    NSCursor *_willCreateSelectionCursor;
    NSCursor *_doCreateSelectionCursor;
    NSPoint _selectionStartPoint;
    CGPathRef _selectionPath;
    CGMutablePathRef _workSelectionPath;
    CGRect _selectionPathBounds;
    unsigned int _isTracking:1;
    unsigned int _isCreatingSelectionPath:1;
    unsigned int _areSelectionPathBoundsCalculated:1;
}
- (void)trackingView:(id)aView didAutoscroll:(BOOL)aAutoscroll withMouseEvent:(id)aEvent;
- (BOOL)trackingView:(id)aView shouldAutoscrollWithMouseEvent:(id)aEvent;
- (void)haltWithMouseUp:(id)aUp inView:(id)aView;
- (void)trackFlagsChanged:(id)aChanged inView:(id)aView;
- (void)trackMouseUp:(id)aUp inView:(id)aView;
- (void)trackMouseDragged:(id)aDragged inView:(id)aView;
- (void)trackMouseDown:(id)aDown inView:(id)aView;
- (BOOL)isFeedbackLayerActive:(id)aActive;
- (id)activeFeedbackLayers;
- (id)activeFeedbackLayersForDrawing;
- (void)draw_BTSelectionFeedbackLayer_Rect:(NSRect)aRect;
- (void)selectAllArea:(id)aArea;
- (BOOL)validateAction_selectAllArea;
- (BOOL)mouseDown:(id)aDown;
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags;
- (BOOL)isTracking;
- (id)currentStage;
- (void)performDeactivate;
- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView;
- (void)BTCreateFreeHandSelectionTool_invalidateSelectionTrackingFeedback;
- (id)outputKeys;
- (id)inputKeys;
- (id)selectionPath;
- (id)selectionStartPoint;
- (void)setDoCreateSelectionCursor:(id)aCursor;
- (id)doCreateSelectionCursor;
- (id)defaultDoCreateSelectionCursor;
- (void)setWillCreateSelectionCursor:(id)aCursor;
- (id)willCreateSelectionCursor;
- (id)defaultWillCreateSelectionCursor;
- (void)dealloc;
@end

