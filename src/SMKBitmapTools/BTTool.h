#import "SMKBitmapToolsPrefix.h"

// A tool modifier option packs the modifier flags that must be down in its
// high 16 bits and, in its low 16 bits, those that must be up (shifted down).
static inline BOOL BTModifierFlagsMatchOption(NSUInteger aFlags, NSUInteger aOption)
{
    NSUInteger required = aOption & 0xffff0000;
    return (aFlags & required) == required && ((uint32_t)aFlags & (uint32_t)(aOption << 16)) == 0;
}


@interface BTTool : NSObject <BTImageUndoingDelegate>
{
    id<BTImage> _workImage;
    id<BTImageUndoing> _workImageUndoer;
    NSMutableDictionary *_undoProxies;
    NSPasteboard *_workPasteboard;
    struct CGContext *_referenceCGContext;
    NSDictionary *_generalKeyBindings;
    void *_pointer;
    unsigned int _isActive:1;
    unsigned int _isViewInvalidationEnabled:1;
    unsigned int _isKeyEventHandled:1;
    unsigned int _isWorkPasteboardInitialized:1;
    unsigned int _areGeneralKeyBindingsInitialized:1;
    unsigned int _isWorkImageUndoGroupingBegun:1;
    unsigned int _isWorkImageUndoGroupingScheduled:1;
    unsigned int _isWorkImageBeingChanged:1;
    unsigned int _isWorkImageBeingReplaced:1;
    id<BTToolDelegate> _delegate;
    NSView *_view;
    BTTool *_currentSubtool;
}
+ (BOOL)accessInstanceVariablesDirectly;
- (CGPoint)guidePoints:(CGPoint *)aPoints count:(NSUInteger)aCount withReflectingTransforms:(CGAffineTransform *)aTransforms asDevicePixelCenters:(BOOL)aCenters forMovementFromPoint:(CGPoint)aPoint toPoint:(CGPoint)aPoint2 centeringOnDevicePixel:(BOOL)aPixel inMode:(char *)aMode withEvent:(id)aEvent;
- (CGPoint)guideMovementFromPoint:(CGPoint)aPoint toPoint:(CGPoint)aPoint2 centeringOnDevicePixel:(BOOL)aPixel inMode:(char *)aMode withEvent:(id)aEvent;
- (BOOL)snapPoint:(CGPoint)aPoint asDevicePixelCenter:(BOOL)aCenter withinBoundsWithMinX:(CGFloat)aX maxX:(CGFloat)aX2 minY:(CGFloat)aY maxY:(CGFloat)aY2 alongTrajectoryLine:(struct CGELine)aLine withEvent:(id)aEvent options:(id)aOptions snappedPoint:(CGPoint *)aPoint2 snapDistance:(CGFloat *)aDistance appliedRules:(id *)aRules;
- (BOOL)snapPoint:(CGPoint *)aPoint asDevicePixelCenter:(BOOL)aCenter withinBoundsWithMinX:(CGFloat)aX maxX:(CGFloat)aX2 minY:(CGFloat)aY maxY:(CGFloat)aY2 alongTrajectoryLine:(struct CGELine)aLine withEvent:(id)aEvent options:(id)aOptions;
- (BOOL)BTTool_snapPoints:(CGPoint *)aPoints count:(NSUInteger)aCount withReflectingTransforms:(CGAffineTransform *)aTransforms asDevicePixelCenter:(BOOL)aCenter withinBoundsWithMinX:(CGFloat)aX maxX:(CGFloat)aX2 minY:(CGFloat)aY maxY:(CGFloat)aY2 alongTrajectoryLine:(struct CGELine)aLine withEvent:(id)aEvent options:(id)aOptions showAppliedRules:(BOOL)aRules snappedPoint:(CGPoint *)aPoint snapDistance:(CGFloat *)aDistance appliedRules:(id *)aRules2;
- (NSPoint)eventLocationInImage:(id)aImage;
- (NSPoint)eventLocationInView:(id)aView;
- (NSRect)convertImageRectToViewRect:(NSRect)aRect;
- (NSPoint)convertImagePointToViewPoint:(NSPoint)aPoint;
- (CGAffineTransform)imageToViewTransform;
- (NSRect)convertViewRectToImageRect:(NSRect)aRect;
- (NSPoint)convertViewPointToImagePoint:(NSPoint)aPoint;
- (CGAffineTransform)viewToImageTransform;
- (void)performDrawRect:(NSRect)aRect ofActiveFeedbackLayer:(id)aLayer;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayers:(id)aLayers;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayer:(id)aLayer;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayers:(id)aLayers;
- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayer:(id)aLayer;
- (id)activeFeedbackLayersForDrawing;
- (BOOL)isFeedbackLayerActive:(id)aActive;
- (id)activeFeedbackLayers;
- (void)drawRect:(NSRect)aRect;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (BOOL)doCommandBySelector:(SEL)aSelector;
- (BOOL)insertText:(id)aText;
- (BOOL)performValidationSelector:(SEL)aSelector;
- (BOOL)validateAction:(SEL)aAction;
- (id)keyBindings;
- (BOOL)flagsChanged:(id)aChanged;
- (BOOL)keyUp:(id)aUp;
- (BOOL)rawKeyDown:(id)aDown;
- (BOOL)keyDown:(id)aDown;
- (BOOL)scrollWheel:(id)aWheel;
- (BOOL)mouseMoved:(id)aMoved;
- (BOOL)mouseDragged:(id)aDragged;
- (BOOL)mouseUp:(id)aUp;
- (BOOL)mouseDown:(id)aDown;
- (BOOL)sendEvent:(id)aEvent;
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags;
- (void)changeViewInvalidationEnabledTo:(BOOL)aTo;
- (void)setViewInvalidationEnabled:(BOOL)aEnabled;
- (BOOL)isViewInvalidationEnabled;
- (void)changeReferenceCGContextTo:(struct CGContext *)aTo;
- (void)setReferenceCGContext:(struct CGContext *)aContext;
- (struct CGContext *)referenceCGContext;
- (void)changeWorkPasteboardTo:(id)aTo;
- (void)setWorkPasteboard:(id)aPasteboard;
- (id)workPasteboard;
- (void)imageUndoer:(id)aUndoer didChangeImageInRect:(CGRect)aRect;
- (void)imageUndoer:(id)aUndoer willChangeImageInRect:(CGRect)aRect;
- (id)prepareUndoForImageUndoer:(id)aUndoer withInvocationTarget:(id)aTarget;
- (void)registerUndoForImageUndoer:(id)aUndoer withTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject;
- (BOOL)isGroupingWorkImageUndo;
- (void)endWorkImageUndoGrouping;
- (void)beginWorkImageUndoGrouping;
- (void)registerWorkImageUndoInRect:(CGRect)aRect;
- (id)BTTool_workImageUndoer;
- (void)setUndoActionName:(id)aName;
- (void)endUndoActionWithName:(id)aName;
- (void)beginUndoAction;
- (id)prepareUndoInManager:(id)aManager category:(id)aCategory withInvocationTarget:(id)aTarget;
- (void)registerUndoInManager:(id)aManager category:(id)aCategory withTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject;
- (id)BTTool_undoProxyForCategory:(id)aCategory;
- (void)removeAllUndoActionsFromManager:(id)aManager;
- (void)removeAllUndoActionsFromManager:(id)aManager category:(id)aCategory;
- (id)allUndoCategories;
- (BOOL)isTracking;
- (id)currentStage;
- (id)view;
- (id)delegate;
- (void)performDeactivate;
- (void)deactivate;
- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView;
- (BOOL)isActive;
- (void)setDefaults;
- (id)attributes;
- (id)valueForOutputKey:(id)aKey;
- (void)setInputs:(id)aInputs;
- (id)inputs;
- (void)setValue:(id)aValue forInputKey:(id)aKey;
- (id)defaultValueForInputKey:(id)aKey;
- (id)valueForInputKey:(id)aKey;
- (id)outputKeys;
- (id)inputKeys;
- (void)setGeneralKeyBindings:(id)aBindings;
- (id)generalKeyBindings;
- (id)defaultGeneralKeyBindings;
- (id *)optionalImageProtocols;
- (id *)requiredImageProtocols;
- (void)postEditWorkImageInRect:(CGRect)aRect;
- (void)preEditWorkImage:(id)aImage inRect:(CGRect)aRect;
- (CGRect)preEditWorkImage:(id)aImage;
- (CGRect)BTTool_preEditWorkImage:(id)aImage inRect:(CGRect *)aRect;
- (void)changeWorkImageTo:(id)aTo;
- (BOOL)setWorkImage:(id)aImage;
- (BOOL)setWorkImage:(id)aImage withEffectiveChangeInRect:(CGRect)aRect;
- (void)BTTool_changeWorkImageTo:(id)aTo workImageUndoerTo:(id)aTo2 withEffectiveChangeFromRect:(CGRect)aRect toRect:(CGRect)aRect2;
- (BOOL)verifyImage:(id)aImage;
- (id)workImage;
- (void)dealloc;
- (id)init;
@end

