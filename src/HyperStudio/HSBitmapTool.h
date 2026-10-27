#import "HyperStudioPrefix.h"
#import "HSBaseBitmapTool.h"


@interface HSBitmapTool : HSBaseBitmapTool
{
    id<HSEditableImageAttributes> _currentEditableImageAttributes;
    HSBitmapToolSelectionCanvasLayer *_toolSelectionCanvasLayer;
}
+ (Class)toolCanvasLayerClass;
- (CGAffineTransform)imageToViewTransform;
- (id)tool:(id)aTool willSetUndoActionName:(id)aName;
- (id)undoManagerForTool:(id)aTool category:(id)aCategory;
- (void)tool:(id)aTool didUpdateOutputForKey:(id)aKey;
- (void)tool:(id)aTool willUpdateOutputForKey:(id)aKey;
- (void)tool:(id)aTool didReplaceImageWithEffectiveChangeInRect:(NSRect)aRect;
- (void)tool:(id)aTool willReplaceImageWithEffectiveChangeInRect:(NSRect)aRect;
- (void)tool:(id)aTool didChangeImageInRect:(NSRect)aRect;
- (void)tool:(id)aTool willChangeImageInRect:(NSRect)aRect;
- (void)toolDidEndChangingImageContinuously:(id)aContinuously;
- (void)toolWillBeginChangingImageContinuously:(id)aContinuously;
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2;
- (void)HSBitmapTool_tool:(id)aTool didChangeImageInRect:(NSRect)aRect;
- (void)reactivate;
- (void)deactivateBitmapTool;
- (BOOL)activateBitmapTool;
- (void)didActivateExplicitly:(BOOL)aExplicitly;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)HSBitmapTool_userObjectDidChangeImage:(id)aImage;
- (BOOL)HSBitmapTool_setWorkImage;
- (id)currentEditableImageAttributes;
- (void)dealloc;
@end

