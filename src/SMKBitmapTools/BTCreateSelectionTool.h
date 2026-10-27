#import "SMKBitmapToolsPrefix.h"
#import "BTTool.h"


@interface BTCreateSelectionTool : BTTool <BTToolDelegate, NSObject>
{
    NSString *_initialCreateSelectionMode;
    BTCreateShapeSelectionTool *_createShapeSelectionTool;
    BTCreateLassoSelectionTool *_createLassoSelectionTool;
    unsigned int _ignoresCurrentCreateSelectionModeChange:1;
}
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
- (id)currentStage;
- (void)performDeactivate;
- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView;
- (void)changeViewInvalidationEnabledTo:(BOOL)aTo;
- (void)changeReferenceCGContextTo:(struct CGContext *)aTo;
- (void)changeWorkPasteboardTo:(id)aTo;
- (void)changeWorkImageTo:(id)aTo;
- (id)outputKeys;
- (id)inputKeys;
- (id *)requiredImageProtocols;
- (void)setFinalizingCreateSelectionMode:(id)aMode;
- (id)finalizingCreateSelectionMode;
- (void)setInitialSelectionPath:(id)aPath;
- (id)initialSelectionPath;
- (id)selectionPath;
- (void)setSelectionStartPoint:(id)aPoint;
- (id)selectionStartPoint;
- (void)setProportionalModePrimary:(BOOL)aPrimary;
- (BOOL)isProportionalModePrimary;
- (BOOL)defaultProportionalModePrimary;
- (void)setAlternateProportion:(CGFloat)aProportion;
- (CGFloat)alternateProportion;
- (CGFloat)defaultAlternateProportion;
- (void)setLassoSwitchingOption:(NSUInteger)aOption;
- (NSUInteger)lassoSwitchingOption;
- (NSUInteger)defaultLassoSwitchingOption;
- (void)setMagicSwitchingOption:(NSUInteger)aOption;
- (NSUInteger)magicSwitchingOption;
- (NSUInteger)defaultMagicSwitchingOption;
- (void)setSelectionShapePrototypePath:(id)aPath;
- (id)selectionShapePrototypePath;
- (void)setTolerance:(CGFloat)aTolerance;
- (CGFloat)tolerance;
- (id)currentCreateSelectionMode;
- (void)setInitialCreateSelectionMode:(id)aMode;
- (id)initialCreateSelectionMode;
- (void)setDoCreateShapeSelectionCursor:(id)aCursor;
- (id)doCreateShapeSelectionCursor;
- (id)defaultDoCreateShapeSelectionCursor;
- (void)setWillCreateShapeSelectionCursor:(id)aCursor;
- (id)willCreateShapeSelectionCursor;
- (id)defaultWillCreateShapeSelectionCursor;
- (void)setDoCreateMagicLassoSelectionCursor:(id)aCursor;
- (id)doCreateMagicLassoSelectionCursor;
- (id)defaultDoCreateMagicLassoSelectionCursor;
- (void)setWillCreateMagicLassoSelectionCursor:(id)aCursor;
- (id)willCreateMagicLassoSelectionCursor;
- (id)defaultWillCreateMagicLassoSelectionCursor;
- (void)setWillCreateMagicWandSelectionCursor:(id)aCursor;
- (id)willCreateMagicWandSelectionCursor;
- (id)defaultWillCreateMagicWandSelectionCursor;
- (void)setDoCreateFreeHandSelectionCursor:(id)aCursor;
- (id)doCreateFreeHandSelectionCursor;
- (id)defaultDoCreateFreeHandSelectionCursor;
- (void)setWillCreateFreeHandSelectionCursor:(id)aCursor;
- (id)willCreateFreeHandSelectionCursor;
- (id)defaultWillCreateFreeHandSelectionCursor;
- (void)dealloc;
- (id)init;
@end

