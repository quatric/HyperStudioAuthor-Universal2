#import "SMKBitmapToolsPrefix.h"
#import "BTTool.h"


@interface BTCreateShapeSelectionTool : BTTool <BTToolDelegate, NSObject, BTMouseTracker>
{
    CGPathRef _selectionShapePrototypePath;
    CGRect _selectionShapePrototypePathBounds;
    NSUInteger _centeringOption;
    NSPoint _initialSelectionPoint;
    NSPoint _selectionStartPoint;
    NSPoint _selectionEndPoint;
    NSRect _feedbackInvalidationRect;
    NSUInteger _effectiveModifierFlags;
    BTPointsCreationTool *_pointsCreationTool;
    unsigned int _isShapePrototypePathInitialized:1;
    unsigned int _isSelectionPathDefined:1;
    unsigned int _isSelectionPathBeingCreated:1;
}
- (void)trackingView:(id)aView didAutoscroll:(BOOL)aAutoscroll withMouseEvent:(id)aEvent;
- (BOOL)trackingView:(id)aView shouldAutoscrollWithMouseEvent:(id)aEvent;
- (void)haltWithMouseUp:(id)aUp inView:(id)aView;
- (void)trackFlagsChanged:(id)aChanged inView:(id)aView;
- (void)trackMouseUp:(id)aUp inView:(id)aView;
- (void)trackMouseDragged:(id)aDragged inView:(id)aView;
- (void)trackMouseDown:(id)aDown inView:(id)aView;
- (id)layoutGuidingContextForTool:(id)aTool;
- (id)mouseTrackingDelegateForTool:(id)aTool;
- (id)imageViewTransformerForTool:(id)aTool;
- (id)tool:(id)aTool willSetUndoActionName:(id)aName;
- (void)tool:(id)aTool willRegisterUndoInManager:(id)aManager category:(id)aCategory;
- (id)undoManagerForTool:(id)aTool category:(id)aCategory;
- (void)tool:(id)aTool didFinalizeOutputForKey:(id)aKey;
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey;
- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(NSRect)aRect;
- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(NSRect)aRect;
- (void)tool:(id)aTool didChangeImageInRect:(NSRect)aRect;
- (void)tool:(id)aTool willChangeImageInRect:(NSRect)aRect;
- (void)toolDidEndChangingImageContinuously:(id)aContinuously;
- (void)toolWillBeginChangingImageContinuously:(id)aContinuously;
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2;
- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent;
- (BOOL)isFeedbackLayerActive:(id)aActive;
- (id)activeFeedbackLayers;
- (id)activeFeedbackLayersForDrawing;
- (void)draw_BTSelectionFeedbackLayer_Rect:(NSRect)aRect;
- (void)selectAllArea:(id)aArea;
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags;
- (id)currentStage;
- (void)performDeactivate;
- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView;
- (void)changeReferenceCGContextTo:(struct CGContext *)aTo;
- (void)changeWorkPasteboardTo:(id)aTo;
- (void)changeWorkImageTo:(id)aTo;
- (id)outputKeys;
- (id)inputKeys;
- (id)selectionPath;
- (id)selectionStartPoint;
- (void)setProportionalModePrimary:(BOOL)aPrimary;
- (BOOL)isProportionalModePrimary;
- (BOOL)defaultProportionalModePrimary;
- (void)setAlternateProportion:(CGFloat)aProportion;
- (CGFloat)alternateProportion;
- (CGFloat)defaultAlternateProportion;
- (void)setCenteringOption:(NSUInteger)aOption;
- (NSUInteger)centeringOption;
- (NSUInteger)defaultCenteringOption;
- (void)setSelectionShapePrototypePath:(id)aPath;
- (id)selectionShapePrototypePath;
- (id)defaultSelectionShapePrototypePath;
- (void)setDoCreateSelectionCursor:(id)aCursor;
- (id)doCreateSelectionCursor;
- (id)defaultDoCreateSelectionCursor;
- (void)setWillCreateSelectionCursor:(id)aCursor;
- (id)willCreateSelectionCursor;
- (id)defaultWillCreateSelectionCursor;
- (void)BTCreateShapeSelectionTool_setNeedsDisplaySelectionPathIfNeeded;
- (void)BTCreateShapeSelectionTool_setNeedsDisplaySelectionPath;
- (void)dealloc;
- (id)init;
- (void)setProportionalMode:(BOOL)aMode;
- (BOOL)isProportionalMode;
- (BOOL)defaultProportionalMode;

@end

