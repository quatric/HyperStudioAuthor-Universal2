#import "HyperStudioPrefix.h"
#import "HSBaseBitmapTool.h"


@interface HSVectorDrawingTool : HSBaseBitmapTool
{
    HSAuxiliaryVisualizationCanvasLayer *_visualizationCanvasLayer;
    id _prototypeObject;
    id _prototypeNodeSupport;
    id _trackingObject;
    BOOL _isTrackingObjectActive;
}
+ (id)layerIdentifiersWithRootLayer:(id)aLayer;
+ (id)toolsCanvasLayerWithRootLayer:(id)aLayer;
+ (Class)toolCanvasLayerClass;
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2;
- (void)finalizeObjectCreationAndNotify:(BOOL)aNotify;
- (id)prepareTrackingObjectForAddingToCard;
- (id)geometryAttributes;
- (id)vectorAttributes;
- (void)deactivateTrackingObjectIfNeeded;
- (BOOL)createIfNeededAndActivateTrackingObject;
- (id)trackingObject;
- (id)prototypeObject;
- (id)prototypeNodeSupport;
- (id)visualizationCanvasLayer;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)dealloc;
- (id)initWithBTTool:(id)aTool;
@end

