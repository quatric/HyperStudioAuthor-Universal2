#import "HyperStudioPrefix.h"
#import "HSCreationTool.h"


@interface HSDragShapeTool : HSCreationTool
{
    id<HSNodeAttributes> _trackingObject;
    HSDragShapeCreationCanvasLayer *_shapeCreationCanvasLayer;
    HSAuxiliaryVisualizationCanvasLayer *_visualizationCanvasLayer;
}
+ (Class)userObjectClass;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)dragShapeCreationLayer:(id)aLayer willCancelEditingObject:(id)aObject;
- (void)dragShapeCreationLayer:(id)aLayer willFinishEditingObject:(id)aObject;
- (void)dragShapeCreationLayer:(id)aLayer didStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint;
- (BOOL)dragShapeCreationLayer:(id)aLayer shouldStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint;
- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface;
- (void)finalizeObjectCreationAndNotify:(BOOL)aNotify;
- (id)prepareTrackingObjectForAddingToCard;
- (void)cancelObjectCreation;
- (void)setTrackingObject:(id)aObject;
- (id)trackingObject;
- (void)setPath:(id)aPath;
- (id)path;
- (void)setFillColor:(id)aColor;
- (id)fillColor;
- (void)setStrokeWidth:(CGFloat)aWidth;
- (CGFloat)strokeWidth;
- (void)setDrawColor:(id)aColor;
- (id)drawColor;
- (id)settingsIdentifiers;
- (id)primarySettingsIdentifier;
- (id)localizedObjectKindName;
- (void)saveChangesAndNotify:(BOOL)aNotify;
- (BOOL)allowsActiveInPlaceEditors;
- (id)visualizationCanvasLayer;
- (id)shapeCreationCanvasLayer;
- (void)dealloc;
@end

