#import "HyperStudioPrefix.h"
#import "HSLegacyCreationTool.h"


@interface HSLineTool : HSLegacyCreationTool
{
    HSVectorGraphicsObject *_trackingObject;
    HSAuxiliaryVisualizationCanvasLayer *_visualizationCanvasLayer;
}
+ (Class)userObjectClass;
- (BOOL)worksInBitmapLayer;
- (void)setupToolLayer;
- (void)cleanupToolLayer;
- (id)defaultToolCursorName;
- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface;
- (BOOL)allowsActiveInPlaceEditors;
- (void)insertNewline:(id)aNewline;
- (void)cancelOperation:(id)aOperation;
- (void)flagsChanged:(id)aChanged;
- (void)handleMouseUp:(id)aUp;
- (void)handleAutoscrollingWithMouseEvent:(id)aEvent;
- (void)handleMouseDragged:(id)aDragged;
- (void)handleMouseDown:(id)aDown;
- (void)setView:(id)aView;
- (id)defaultPath;
- (BOOL)isObjectResizedScaledProportionally;
- (BOOL)updatePrototypeWithDictionary:(id)aDictionary;
- (void)createTrackingObjectAtPoint:(NSPoint)aPoint;
- (BOOL)leaveTrackingObjectAndNotify:(BOOL)aNotify;
- (BOOL)leaveTrackingObjectAndNotify:(BOOL)aNotify registerInCard:(BOOL)aCard forceSwitchTool:(BOOL)aTool;
- (void)objectDidChangeGeometry:(id)aGeometry;
- (id)vectorAttributes;
- (void)setTrackingObject:(id)aObject;
- (id)trackingObject;
- (id)visualizationCanvasLayer;
- (void)dealloc;
@end

