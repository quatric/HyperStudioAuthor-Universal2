#import "HyperPlayerBasePrefix.h"
#import "HSObservingNodesCanvasSublayer.h"


@interface HSInteractiveModeMouseOverInfo : NSObject
{
    NSPoint _location;
    id<HSNodeAttributes> _node;
}
- (void)setNode:(id)aNode;
- (id)node;
- (void)setLocation:(NSPoint)aLocation;
- (NSPoint)location;
- (void)dealloc;
@end

@interface HSInteractiveObjectsLayer : HSObservingNodesCanvasSublayer <HSInteractiveCanvasContext, HyperInterface, NSObject>
{
    id _mouseOverInfo;
    BOOL _disabled;
    id<HSCanvasItem> _lastActiveTextViewItem;
    HSFlickGestureRecognizer *_flickRecognizer;
    NSMutableDictionary *_touchIdentityToHitItemMap;
}
- (void)setDisabled:(BOOL)aDisabled;
- (BOOL)isDisabled;
- (void)willStopRunning;
- (void)didStartRunning;
- (BOOL)handleTouchesCancelledWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesEndedWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesMovedWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleTouchesBeganWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (void)handleFlickGesture:(id)aGesture;
- (BOOL)handleSwipeGesture:(id)aGesture hitTestInfo:(id)aInfo;
- (BOOL)handleRotationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMagnificationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo;
- (void)rotateObject:(id)aObject aboutCenterBy:(CGFloat)aBy;
- (void)scaleObject:(id)aObject aboutCenterBy:(CGFloat)aBy;
- (void)scaleTextObject:(id)aObject aboutCenterBy:(CGFloat)aBy;
- (BOOL)resignFirstResponder;
- (id)activeTextField;
- (void)saveEditingState;
- (NSRange)selectedRangeInNode:(id)aNode;
- (void)selectRange:(NSRange)aRange inNode:(id)aNode;
- (void)doCommandBySelector:(SEL)aSelector forNode:(id)aNode;
- (void)insertText:(id)aText toNode:(id)aNode;
- (id)activeInteractiveTextView;
- (BOOL)isCorrectInteractiveTextViewItem:(id)aItem;
- (void)insertNewline:(id)aNewline;
- (void)cancelOperation:(id)aOperation;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (BOOL)handleRawKeyUpEvent:(id)aEvent;
- (BOOL)handleRawKeyDownEvent:(id)aEvent;
- (BOOL)handleKeyEquivalent:(id)aEquivalent;
- (BOOL)performActionForKeyEvent:(id)aEvent;
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint;
- (void)setMouseOverInfo:(id)aInfo;
- (id)mouseOverInfo;
- (void)willUnregisterCanvasItem:(id)aItem forNode:(id)aNode;
- (void)didRegisterCanvasItem:(id)aItem forNode:(id)aNode;
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent;
- (void)contextWillChange;
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inHitItem:(id)aItem;
- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent;
- (id)defaultInteractiveModeCursor;
- (BOOL)handleScrollWheelAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMouseUpAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo;
- (void)trackMouseForItem:(id)aItem withMouseDownEvent:(id)aEvent wasDragged:(BOOL *)aDragged;
- (void)trackMouseForDraggableItem:(id)aItem withMouseDownEvent:(id)aEvent wasDragged:(BOOL *)aDragged;
- (id)moveCardObjectTrackerForNode:(id)aNode;
- (void)trackMouseForRotatableItem:(id)aItem withMouseDownEvent:(id)aEvent wasRotated:(BOOL *)aRotated;
- (void)trackMouseForResizableItem:(id)aItem withMouseDownEvent:(id)aEvent wasResized:(BOOL *)aResized;
- (void)setActiveItem:(id)aItem;
- (void)deactivateInteractiveItem:(id)aItem;
- (void)sendDropOffActionsFromItemIfNeeded:(id)aNeeded;
- (id)hitTestDropOffTargetItemForItem:(id)aItem inLocation:(NSPoint)aLocation;
- (void)sendDropOffActionsForItem:(id)aItem;
- (BOOL)sendingDropOffOnlyActionIsDisabledForItem:(id)aItem;
- (BOOL)performActionsMappedToKeyEvent:(id)aEvent;
- (void)sendClickActionsForHypertextLink:(id)aLink;
- (void)sendMouseOverActionsForItem:(id)aItem;
- (void)sendClickActionsForItemIfNeeded:(id)aNeeded;
- (BOOL)itemHasClickActions:(id)aActions;
- (BOOL)itemHasHyperActions:(id)aActions;
- (BOOL)itemIsDraggable:(id)aDraggable;
- (BOOL)itemIsResizable:(id)aResizable;
- (BOOL)itemIsRotatable:(id)aRotatable;
- (BOOL)hitTestPoint:(NSPoint)aPoint inItem:(id)aItem;
- (BOOL)supportsHitTesting;
- (BOOL)hasRepresentationForRootNode;
- (id)actionExecutionManager;
- (id)actionExecutionContext;
- (id)nodeVisualizationDisabling;
- (id)queryCanvasItemForNode:(id)aNode;
- (id)objectInRepresentedObjectsAtIndex:(NSUInteger)aIndex;
- (NSUInteger)countOfRepresentedObjects;
- (BOOL)isTextObject:(id)aObject;
- (id)context;
- (void)dealloc;
@end

