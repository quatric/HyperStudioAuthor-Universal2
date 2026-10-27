#import "SMKBitmapToolsPrefix.h"
#import "BTTrackingView_BTVisibleRectTrackingZone.h"


@interface BTToolView : BTTrackingView <BTToolDelegate, NSObject, BTImageViewTransformer>
{
    id<BTImage> _image;
    NSDictionary *_imageProperties;
    NSDictionary *_availableTools;
    BTTool *_currentTool;
    NSCursor *_currentToolCursor;
    BTTrackingZone *_trackingVisibleZone;
    BOOL _isInVisibleZoneAndActive;
    NSSize _zoomFactor;
    NSEvent *_currentKeyEvent;
}
- (NSRect)convertImageRectToViewRect:(NSRect)aRect;
- (NSPoint)convertImagePointToViewPoint:(NSPoint)aPoint;
- (CGAffineTransform)imageToViewTransform;
- (NSRect)convertViewRectToImageRect:(NSRect)aRect;
- (NSPoint)convertViewPointToImagePoint:(NSPoint)aPoint;
- (CGAffineTransform)viewToImageTransform;
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
- (void)BTToolView_setNeedsDisplayImageInRect:(NSRect)aRect;
- (BOOL)tool:(id)aTool didFinalizeStage:(id)aStage withEvent:(id)aEvent nextStage:(id)aStage2;
- (void)tool:(id)aTool didUpdateCursorWithEvent:(id)aEvent;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)interpretCurrentKeyEventAsCommand:(SEL *)aCommand text:(id *)aText;
- (void)scrollWheel:(id)aWheel;
- (void)mouseExited:(id)aExited;
- (void)mouseEntered:(id)aEntered;
- (void)mouseMoved:(id)aMoved;
- (void)mouseDown:(id)aDown;
- (void)flagsChanged:(id)aChanged;
- (void)keyUp:(id)aUp;
- (void)keyDown:(id)aDown;
- (BOOL)acceptsFirstResponder;
- (void)drawRect:(NSRect)aRect;
- (void)drawToolRect:(NSRect)aRect;
- (void)drawContentRect:(NSRect)aRect;
- (void)resignKeyWindow;
- (void)becomeKeyWindow;
- (BOOL)setCurrentToolByName:(id)aName forceSwitch:(BOOL)aSwitch;
- (BOOL)setCurrentTool:(id)aTool forceSwitch:(BOOL)aSwitch;
- (id)currentTool;
- (id)toolForName:(id)aName;
- (id)availableToolNames;
- (id)BTToolView_availableTools;
- (void)BTToolView_updateCursorWithEvent:(id)aEvent;
- (void)BTToolView_updateToolCursorWithEvent:(id)aEvent;
- (void)BTToolView_updateToolCursorWithPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags;
- (void)BTToolView_popCursor;
- (void)BTToolView_getLocation:(NSPoint *)aLocation modifierFlags:(NSUInteger *)aFlags forEvent:(id)aEvent;
- (void)BTToolView_setupTrackingZone;
- (NSPoint)convertMouseLocationFromWindow:(NSPoint)aWindow;
- (void)setImage:(id)aImage imageProperties:(id)aProperties;
- (id)BTToolView_mutableImage;
- (id)imageProperties;
- (id)image;
- (BOOL)canBecomeKeyView;
- (oneway void)release;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

