#import "HyperStudioPrefix.h"
#import "HSCreationTool.h"


@interface HSPolyCurveTool : HSCreationTool
{
    id<HSNodeAttributes> _trackingObject;
    HSBezierPathCreationCanvasLayer *_pathCreationCanvasLayer;
    HSAuxiliaryVisualizationCanvasLayer *_visualizationCanvasLayer;
    BOOL _isStraightLineMode;
    BOOL _isShapeTool;
}
+ (Class)userObjectClass;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)bezierPathCreationLayer:(id)aLayer willCancelEditingObject:(id)aObject;
- (void)bezierPathCreationLayer:(id)aLayer willFinishEditingObject:(id)aObject;
- (void)bezierPathCreationLayer:(id)aLayer didStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint;
- (BOOL)bezierPathCreationLayer:(id)aLayer shouldStartEditingObject:(id)aObject atUserPoint:(NSPoint)aPoint;
- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface;
- (BOOL)updatePrototypeWithDictionary:(id)aDictionary;
- (void)finalizeObjectCreationAndNotify:(BOOL)aNotify;
- (void)cancelObjectCreation;
- (id)prepareTrackingObjectForAddingToCard;
- (void)objectDidChangeGeometry:(id)aGeometry;
- (id)vectorAttributes;
- (void)setTrackingObject:(id)aObject;
- (id)trackingObject;
- (void)prototypeObjectDidChange;
- (void)updatePrototypeWithObjectKindName;
- (id)localizedObjectKindName;
- (id)nonLocalizedObjectKindName;
- (BOOL)prototypeHasClosedPath;
- (void)saveChangesAndNotify:(BOOL)aNotify;
- (BOOL)allowsActiveInPlaceEditors;
- (NSUInteger)currentPointIndex;
- (NSInteger)editingMode;
- (void)setShapeTool:(BOOL)aTool;
- (BOOL)isShapeTool;
- (void)setStraightLineMode:(BOOL)aMode;
- (BOOL)isStraightLineMode;
- (id)visualizationCanvasLayer;
- (id)pathCreationCanvasLayer;
- (void)dealloc;
@end

