#import "HyperPlayerBasePrefix.h"
#import "HSUserObjectView.h"


@interface HSUserObjectInteractiveView : HSUserObjectView <HSCanvasLayerContext, HyperInterface, NSObject>
{
    id _delegate;
    NSPoint _lastClickPosition;
    HSRootCanvasLayer *_rootCanvasLayer;
    HSCanvasHitTester *_canvasHitTester;
    BOOL _didHandleKeyEvent;
    BOOL _isWithinDefaultKeyDownImplementation;
    BOOL _ignoreCreateCanvasLayerTree;
    NSString *_gestureBeingHandled;
    unsigned int _numberOfCurrentGestures;
    unsigned int _countOfRotateEvents;
    unsigned int _countOfZoomEvents;
}
- (void)paste:(id)aPaste;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (BOOL)validateUserInterfaceItem:(id)aItem;
- (void)viewDidMoveToWindow;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setUserObject:(id)aObject;
- (void)touchesCancelledWithEvent:(id)aEvent;
- (void)touchesEndedWithEvent:(id)aEvent;
- (void)touchesMovedWithEvent:(id)aEvent;
- (void)touchesBeganWithEvent:(id)aEvent;
- (void)swipeWithEvent:(id)aEvent;
- (void)rotateWithEvent:(id)aEvent;
- (void)magnifyWithEvent:(id)aEvent;
- (void)endGestureWithEvent:(id)aEvent;
- (void)beginGestureWithEvent:(id)aEvent;
- (void)didHandleKeyEvent;
- (void)doCommandBySelector:(SEL)aSelector;
- (BOOL)handleKeyEventSelector:(SEL)aSelector;
- (BOOL)performKeyEquivalent:(id)aEquivalent;
- (void)keyUp:(id)aUp;
- (void)keyDown:(id)aDown;
- (void)exploreMenuForShortcuts:(id)aShortcuts;
- (void)resetCursorRects;
- (void)handleMouseMoved:(id)aMoved;
- (void)updateCursorAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent;
- (void)flagsChanged:(id)aChanged;
- (void)scrollWheel:(id)aWheel;
- (void)mouseUp:(id)aUp;
- (void)mouseDown:(id)aDown;
- (void)renderRootCanvasLayerInRect:(NSRect)aRect;
- (void)postDrawContentRect:(NSRect)aRect;
- (void)didChangeHitTestingInterface;
- (void)setHitTestingInterface:(id)aInterface;
- (id)createCanvasHitTester;
- (id)actionExecutionContext;
- (id)actionExecutionManager;
- (id)canvasHitTester;
- (id)renderingView;
- (id)createRootCanvasLayer;
- (void)setupRootCanvasLayer:(id)aLayer;
- (id)rootCanvasLayer;
- (id)rootCanvasLayerCreateIfNeeded:(BOOL)aNeeded;
- (id)initWithFrame:(NSRect)aFrame ignoreCreateRootCanvasLayer:(BOOL)aLayer;
- (void)dealloc;
@end

@interface HSUserObjectInteractiveView (HSUserObjectInteractiveViewStateInfo)
- (void)setLastClickPosition:(NSPoint)aPosition;
- (NSPoint)lastClickPosition;
@end

