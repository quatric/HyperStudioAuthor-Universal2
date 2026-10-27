#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSBaseBitmapTool : HSTool <BTToolDelegate, BTImageViewTransformer, BTLayoutGuidingContext>
{
    HSBitmapToolViewProxy *_bitmapToolViewProxy;
    BTTool *_bitmapTool;
    BTToolSettingsSerialization *_toolSettingsWrapper;
    HSBaseBitmapToolCanvasLayer *_toolCanvasLayer;
    HSDragCardViewCanvasLayer *_dragCardCanvasLayer;
    unsigned int _obeysLayoutGuiding:1;
    unsigned int _resetOnSave:1;
}
+ (Class)settingsSerializationClass;
+ (id)layerIdentifiersWithRootLayer:(id)aLayer;
+ (id)toolsCanvasLayerWithRootLayer:(id)aLayer;
+ (Class)toolCanvasLayerClass;
- (void)setToolSize:(NSSize)aSize;
- (id)toolSettings;
- (id)toolSettingsWrapper;
- (CGAffineTransform)imageToViewTransform;
- (NSRect)convertImageRectToViewRect:(NSRect)aRect;
- (NSPoint)convertImagePointToViewPoint:(NSPoint)aPoint;
- (NSRect)convertViewRectToImageRect:(NSRect)aRect;
- (NSPoint)convertViewPointToImagePoint:(NSPoint)aPoint;
- (CGAffineTransform)viewToImageTransform;
- (void)SMKBitmapTools_showAppliedRules:(id)aRules forSnappedParallelogram:(struct CGEParallelogram)aParallelogram;
- (void)SMKBitmapTools_showAppliedRules:(id)aRules forSnappedPoint:(CGPoint)aPoint;
- (void)showAppliedRules:(id)aRules;
- (BOOL)snapPoints:(id)aPoints sizes:(id)aSizes withEvent:(id)aEvent options:(id)aOptions snappedReflectedPoint:(CGPoint *)aPoint snapDistance:(float *)aDistance appliedRules:(id *)aRules;
- (id)layoutGuidingContextForTool:(id)aTool;
- (id)mouseTrackingDelegateForTool:(id)aTool;
- (id)imageViewTransformerForTool:(id)aTool;
- (id)tool:(id)aTool willSetUndoActionName:(id)aName;
- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory;
- (id)undoManagerForTool:(id)aTool category:(id)aCategory;
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2;
- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey;
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey;
- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(NSRect)aRect;
- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(NSRect)aRect;
- (void)tool:(id)aTool didChangeImageInRect:(NSRect)aRect;
- (void)tool:(id)aTool willChangeImageInRect:(NSRect)aRect;
- (void)toolDidEndChangingImageContinuously:(id)aContinuously;
- (void)toolWillBeginChangingImageContinuously:(id)aContinuously;
- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent;
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)saveChanges;
- (void)HSBitmapTool_updateCursorWithEvent:(id)aEvent;
- (void)deactivateBitmapTool;
- (BOOL)isActiveAtPoint:(NSPoint)aPoint;
- (BOOL)activateBitmapTool;
- (void)reactivate;
- (BOOL)obeysLayoutGuiding;
- (id)bitmapTool;
- (id)HSBaseBitmapTool_bitmapToolView;
- (void)setView:(id)aView;
- (BOOL)allowsSelection;
- (void)dealloc;
- (id)initWithBTTool:(id)aTool obeyLayoutGuiding:(BOOL)aGuiding resetOnSave:(BOOL)aSave;
- (id)initWithBTTool:(id)aTool;
@end

@interface HSBitmapToolViewProxy : NSProxy <BTMouseTracker, NSObject>
{
    HSToolView *_toolView;
    id<BTMouseTracker> _mouseTracker;
}
- (void)trackingView:(id)aView didAutoscroll:(BOOL)aAutoscroll withMouseEvent:(id)aEvent;
- (BOOL)trackingView:(id)aView shouldAutoscrollWithMouseEvent:(id)aEvent;
- (void)haltWithMouseUp:(id)aUp inView:(id)aView;
- (void)trackFlagsChanged:(id)aChanged inView:(id)aView;
- (void)trackMouseUp:(id)aUp inView:(id)aView;
- (void)trackMouseDragged:(id)aDragged inView:(id)aView;
- (void)trackMouseDown:(id)aDown inView:(id)aView;
- (id)BT_trackMouseWithEvent:(id)aEvent tracker:(id)aTracker;
- (id)BT_trackMouseWithEvent:(id)aEvent tracker:(id)aTracker startDelay:(double)aDelay;
- (void)setNeedsDisplayInRect:(NSRect)aRect;
- (void)setNeedsDisplay:(BOOL)aDisplay;
- (void)setToolView:(id)aView;
- (id)toolView;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (id)initWithToolView:(id)aView;
- (id)init;
@end

