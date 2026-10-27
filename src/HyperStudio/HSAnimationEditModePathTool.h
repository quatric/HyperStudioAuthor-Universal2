#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSAnimationEditModePathTool : HSTool
{
    id<HSAnimationEditModePathToolDataSource> _dataSource;
    BOOL _creating;
    HSConcreteCardObject *_objectToAnimate;
    HSConcreteCardObject *_originalObjectToAnimate;
    HSAnimationEditModePathObject *_prototypeObject;
    HSAnimationEditModePathObject *_creationObject;
    HSAnimationEditModePathObject *_pathObject;
    HSAuxiliaryVisualizationCanvasLayer *_visualizationCanvasLayer;
    HSAnimationPathCanvasItem *_pathCanvasItem;
    HSBezierPathCreationCanvasLayer *_creationCanvasLayer;
    HSVectorGraphicsKnobsCanvasLayer *_selectionCanvasLayer;
}
- (void)startTrackingWithMouseDownEvent:(id)aEvent;
- (void)setSelectedSegments:(NSRange)aSegments;
- (BOOL)isCreatingTrajectory;
- (void)pathDidChange;
- (void)objectToAnimateDidChangeTo:(id)aTo original:(id)aOriginal;
- (id)originalObjectToAnimate;
- (id)objectToAnimate;
- (void)setDataSource:(id)aSource;
- (id)dataSource;
- (void)objectKnobsCanvasLayerDidFinishTrackingKnob:(id)aKnob;
- (void)objectKnobsCanvasLayerWillStartTrackingKnob:(id)aKnob;
- (void)bezierPathCreationLayer:(id)aLayer willCancelEditingObject:(id)aObject;
- (void)bezierPathCreationLayer:(id)aLayer willFinishEditingObject:(id)aObject;
- (void)bezierPathCreationLayer:(id)aLayer didStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint;
- (BOOL)bezierPathCreationLayer:(id)aLayer shouldStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint;
- (void)freehandPathCreationLayer:(id)aLayer willCancelEditingObject:(id)aObject;
- (void)freehandPathCreationLayer:(id)aLayer willFinishEditingObject:(id)aObject restart:(BOOL)aRestart;
- (void)freehandPathCreationLayer:(id)aLayer continueEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint;
- (void)freehandPathCreationLayer:(id)aLayer didStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint;
- (void)freehandPathCreationLayer:(id)aLayer setObjectPosition:(NSPoint)aPosition;
- (void)cleanUpSelectionCanvasLayer;
- (void)setUpSelectionCanvasLayer;
- (id)selectionCanvasLayer;
- (void)cleanUpCreationCanvasLayer;
- (void)setUpCreationCanvasLayer;
- (id)creationCanvasLayer;
- (id)pathCanvasItem;
- (id)visualizationCanvasLayer;
- (void)pathObjectPathDidChange:(id)aChange;
- (void)setPathObject:(id)aObject;
- (id)pathObject;
- (void)creationObjectPathDidChange:(id)aChange;
- (void)setCreationObject:(id)aObject;
- (id)creationObject;
- (id)prototypeObject;
- (BOOL)useFreehand;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (BOOL)allowsActiveInPlaceEditors;
- (void)dealloc;
- (id)init;
@end

