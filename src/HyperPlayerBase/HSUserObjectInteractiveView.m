#import "HSUserObjectInteractiveView.h"
#import "HSCanvasHitTester.h"
#import "HSCanvasLayerActionSelectorSupport.h"
#import "HSCursorSynchronizer.h"
#import "HSProtocolIdentifier.h"
#import "HSRootCanvasLayer.h"

// Menu key equivalents ({key, modifiers}), collected from the main menu once.
static NSMutableArray *HSMenuShortcuts = nil;

// Modifier bits compared against menu key equivalents.
#define HSShortcutModifierMask 0xfa0000

// Event types that carry a mouse location: mouse buttons, moves, drags,
// enter/exit, scroll, tablet, other-mouse and gesture events.
#define HSLocatedEventTypesMask 0x2f8003feU

// Declares paste: for the super call below; it is resolved at run time.
@interface HSUserObjectView (HSUserObjectInteractiveViewPasting)
- (void)paste:(id)aSender;
@end

@implementation HSUserObjectInteractiveView

- (void)paste:(id)aPaste
{
    if ([[self rootCanvasLayer] respondsToActionSelector:@selector(paste:)]
        && [[NSPasteboard generalPasteboard] availableTypeFromArray:[NSArray arrayWithObject:@"BTArchivedImageRegionPboardType"]] != nil) {
        [super paste:self];
        return;
    }
    [[[self window] windowController] paste:aPaste];
}

- (void)forwardInvocation:(id)aInvocation
{
    SEL selector = [aInvocation selector];
    if (![[self rootCanvasLayer] respondsToActionSelector:selector]) {
        [super forwardInvocation:aInvocation];
        return;
    }
    id sender = nil;
    [aInvocation getArgument:&sender atIndex:2];
    [[self rootCanvasLayer] performActionSelector:selector withSender:sender];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    if ([[self rootCanvasLayer] respondsToActionSelector:aSelector])
        return [HSCanvasLayerActionSelectorSupport methodSignatureForActionSelector];
    return [super methodSignatureForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL responds = [super respondsToSelector:aSelector];
    // paste: is only offered when the canvas can take it.
    if (aSelector == @selector(paste:) || !responds)
        responds = [[self rootCanvasLayer] respondsToActionSelector:aSelector];
    return responds;
}

- (BOOL)validateUserInterfaceItem:(id)aItem
{
    id<NSValidatedUserInterfaceItem> item = aItem;
    if ([[self rootCanvasLayer] respondsToActionSelector:[item action]])
        return [[self rootCanvasLayer] validateActionSelector:[item action] withUserInterfaceItem:item];
    if ([item action] == @selector(paste:) && ![[[self userObject] document] isInPresentationMode])
        return [[[self window] windowController] validateUserInterfaceItem:aItem];
    return NO;
}

- (void)viewDidMoveToWindow
{
    [[self window] setAcceptsMouseMovedEvents:YES];
    [super viewDidMoveToWindow];
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate)
        _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)setUserObject:(id)aObject
{
    if ([self userObject] == aObject)
        return;

    if ([self userObject] != nil && [_delegate respondsToSelector:@selector(userObjectInteractiveView:willSetUserObject:)])
        [_delegate userObjectInteractiveView:self willSetUserObject:aObject];
    [super setUserObject:aObject];
    [_rootCanvasLayer setRepresentedObject:[self userObject]];
    [_canvasHitTester setRootNode:[self userObject]];
    [self setNeedsDisplayOpenGLSurface:YES];
    if ([_delegate respondsToSelector:@selector(userObjectInteractiveView:didSetUserObject:)])
        [_delegate userObjectInteractiveView:self didSetUserObject:aObject];
}

- (void)touchesCancelledWithEvent:(id)aEvent
{
    if ([[self rootCanvasLayer] isRunning])
        [[self rootCanvasLayer] handleTouchesCancelled:aEvent];
}

- (void)touchesEndedWithEvent:(id)aEvent
{
    if ([[self rootCanvasLayer] isRunning])
        [[self rootCanvasLayer] handleTouchesEnded:aEvent];
}

- (void)touchesMovedWithEvent:(id)aEvent
{
    if ([[self rootCanvasLayer] isRunning])
        [[self rootCanvasLayer] handleTouchesMoved:aEvent];
}

- (void)touchesBeganWithEvent:(id)aEvent
{
    if ([[self rootCanvasLayer] isRunning])
        [[self rootCanvasLayer] handleTouchesBegan:aEvent];
}

// Unhandled gestures: the original only looked up the superclass method
// signature here and forwarded nothing.
- (void)swipeWithEvent:(id)aEvent
{
    if (![self handleSwipeGesture:aEvent])
        [super swipeWithEvent:aEvent];
}

- (void)rotateWithEvent:(id)aEvent
{
    if (![self handleRotationGesture:aEvent])
        [super rotateWithEvent:aEvent];
}

- (void)magnifyWithEvent:(id)aEvent
{
    if (![self handleMagnificationGesture:aEvent])
        [super magnifyWithEvent:aEvent];
}

// The first gesture of a kind to arrive owns the interaction until all
// current gestures end.
- (BOOL)handleMagnificationGesture:(id)aGesture
{
    _countOfZoomEvents++;
    if (_gestureBeingHandled == nil)
        _gestureBeingHandled = @"zoom";
    return [_gestureBeingHandled isEqual:@"zoom"] && [[self rootCanvasLayer] isRunning] && [[self rootCanvasLayer] handleMagnificationGesture:aGesture];
}

- (BOOL)handleRotationGesture:(id)aGesture
{
    _countOfRotateEvents++;
    if (_gestureBeingHandled == nil)
        _gestureBeingHandled = @"rotate";
    return [_gestureBeingHandled isEqual:@"rotate"] && [[self rootCanvasLayer] isRunning] && [[self rootCanvasLayer] handleRotationGesture:aGesture];
}

- (BOOL)handleSwipeGesture:(id)aGesture
{
    return [[self rootCanvasLayer] isRunning] && [[self rootCanvasLayer] handleSwipeGesture:aGesture];
}

- (void)endGestureWithEvent:(id)aEvent
{
    if (--_numberOfCurrentGestures == 0) {
        _gestureBeingHandled = nil;
        _countOfRotateEvents = 0;
        _countOfZoomEvents = 0;
    }
}

- (void)beginGestureWithEvent:(id)aEvent
{
    _numberOfCurrentGestures++;
}

- (void)didHandleKeyEvent
{
    _didHandleKeyEvent = YES;
}

- (void)doCommandBySelector:(SEL)aSelector
{
    if ([self respondsToSelector:aSelector])
        [self performSelector:aSelector withObject:nil];
    else if ([self handleKeyEventSelector:aSelector])
        [self didHandleKeyEvent];
}

- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    return [[self rootCanvasLayer] handleKeyEventSelector:aSelector];
}

- (BOOL)performKeyEquivalent:(id)aEquivalent
{
    BOOL handled;
    [self beginContentChangeAccumulation];
    if (!_isWithinDefaultKeyDownImplementation && [[self rootCanvasLayer] handleKeyEquivalent:aEquivalent])
        handled = YES;
    else
        handled = [super performKeyEquivalent:aEquivalent];
    [self endContentChangeAccumulation];
    return handled;
}

- (void)keyUp:(id)aUp
{
    if (![[self rootCanvasLayer] handleRawKeyUpEvent:aUp])
        [super keyUp:aUp];
}

- (void)keyDown:(id)aDown
{
    [self beginContentChangeAccumulation];
    _didHandleKeyEvent = NO;
    _didHandleKeyEvent = [[self rootCanvasLayer] handleRawKeyDownEvent:aDown];

    if (HSMenuShortcuts == nil) {
        HSMenuShortcuts = [NSMutableArray new];
        [self exploreMenuForShortcuts:[NSApp mainMenu]];
    }

    // Menu shortcuts are left to the menu.
    BOOL isMenuShortcut = NO;
    NSEnumerator *enumerator = [HSMenuShortcuts objectEnumerator];
    NSDictionary *shortcut;
    while ((shortcut = [enumerator nextObject]) != nil) {
        if (![[shortcut objectForKey:@"key"] isEqual:[aDown charactersIgnoringModifiers]])
            continue;
        if ([[shortcut objectForKey:@"modifiers"] unsignedIntValue] == ([aDown modifierFlags] & HSShortcutModifierMask)) {
            isMenuShortcut = YES;
            break;
        }
    }

    if (!isMenuShortcut && !_didHandleKeyEvent) {
        if (![[self actionExecutionContext] isSlideshow])
            [self interpretKeyEvents:[NSArray arrayWithObject:aDown]];
    }
    if (!_didHandleKeyEvent) {
        _isWithinDefaultKeyDownImplementation = YES;
        [super keyDown:aDown];
        _isWithinDefaultKeyDownImplementation = NO;
    }
    [self endContentChangeAccumulation];
}

- (void)exploreMenuForShortcuts:(id)aShortcuts
{
    NSEnumerator *enumerator = [[aShortcuts itemArray] objectEnumerator];
    NSMenuItem *item;
    while ((item = [enumerator nextObject]) != nil) {
        if ([item hasSubmenu]) {
            [self exploreMenuForShortcuts:[item submenu]];
        } else if ([[item keyEquivalent] length] != 0) {
            [HSMenuShortcuts addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                [item keyEquivalent], @"key",
                [NSNumber numberWithInt:(int)[item keyEquivalentModifierMask]], @"modifiers",
                nil]];
        }
    }
}

- (void)resetCursorRects
{
    NSWindow *window = [self window];
    if (window == nil) {
        [super resetCursorRects];
        return;
    }

    NSEvent *event = [window currentEvent];
    NSUInteger modifierFlags = [event modifierFlags];
    NSEventType type = [event type];
    NSPoint location;
    if (type <= 0x1d && ((HSLocatedEventTypesMask >> type) & 1) != 0) {
        location = [event locationInWindow];
    } else {
        // Synthesize a mouse-moved event at the current mouse location.
        location = [window convertPointFromScreen:[NSEvent mouseLocation]];
        event = [NSEvent mouseEventWithType:NSEventTypeMouseMoved location:location modifierFlags:modifierFlags timestamp:[event timestamp]
                               windowNumber:[event windowNumber] context:nil eventNumber:0 clickCount:0 pressure:0];
    }

    [super discardCursorRects];
    NSPoint point = [self convertPoint:location fromView:nil];
    NSRect visibleRect = [self visibleRect];
    BOOL inside = [self mouse:point inRect:visibleRect];
    id cursor = [[self rootCanvasLayer] cursorForPoint:point insideView:inside modifierFlags:modifierFlags event:event];
    if (cursor == nil)
        cursor = [HSCursor cursorNamed:HSDefaultCursor];
    NSCursor *systemCursor = [cursor cursor];
    if (systemCursor != nil) {
        [super addCursorRect:visibleRect cursor:systemCursor];
        [systemCursor setOnMouseEntered:YES];
    }
}

- (void)handleMouseMoved:(id)aMoved
{
    [[self rootCanvasLayer] handleMouseMoved:aMoved];
    [super handleMouseMoved:aMoved];
}

- (void)updateCursorAtPoint:(NSPoint)aPoint inside:(BOOL)aInside modifierFlags:(NSUInteger)aFlags event:(id)aEvent
{
    HSCursor *cursor = [[self rootCanvasLayer] cursorForPoint:aPoint insideView:aInside modifierFlags:aFlags event:aEvent];
    if (cursor == nil)
        cursor = [HSCursor cursorNamed:HSDefaultCursor];
    [cursor set];
}

- (void)flagsChanged:(id)aChanged
{
    [[self rootCanvasLayer] handleFlagsChanged:aChanged];
}

- (void)scrollWheel:(id)aWheel
{
    if ([[self rootCanvasLayer] isRunning] && [[self rootCanvasLayer] handleScrollWheel:aWheel])
        return;
    [super scrollWheel:aWheel];
}

- (void)mouseUp:(id)aUp
{
    if ([[self rootCanvasLayer] isRunning] && [[self rootCanvasLayer] handleMouseUp:aUp])
        return;
    [super mouseUp:aUp];
}

- (void)mouseDown:(id)aDown
{
    if ([[self rootCanvasLayer] isRunning] && [[self rootCanvasLayer] handleMouseDown:aDown])
        return;
    [super mouseDown:aDown];
}

- (void)renderRootCanvasLayerInRect:(NSRect)aRect
{
    [[self rootCanvasLayer] renderRect:aRect];
}

- (void)postDrawContentRect:(NSRect)aRect
{
    [self renderRootCanvasLayerInRect:aRect];
}

- (void)didChangeHitTestingInterface
{
}

- (void)setHitTestingInterface:(id)aInterface
{
    [self canvasHitTester];
    id oldInterface = [_canvasHitTester hitTestingInterface];
    [_canvasHitTester setHitTestingInterface:[HSProtocolIdentifier identifierForProtocol:aInterface]];
    if (![oldInterface isEqual:[_canvasHitTester hitTestingInterface]])
        [self didChangeHitTestingInterface];
}

- (id)createCanvasHitTester
{
    return nil;
}

- (id)actionExecutionContext
{
    return [[[[self userObject] document] queryHyperInterface:@protocol(HSActionExecutionContextProvider)] actionExecutionContext];
}

- (id)actionExecutionManager
{
    return [[[[self userObject] document] queryHyperInterface:@protocol(HSActionExecutionManagerProvider)] actionExecutionManager];
}

- (id)canvasHitTester
{
    if (_canvasHitTester == nil) {
        _canvasHitTester = [self createCanvasHitTester];
        [_canvasHitTester setCanvasLayerContext:self];
        [_canvasHitTester setRootNode:[self userObject]];
    }
    return _canvasHitTester;
}

- (id)renderingView
{
    return self;
}

- (id)createRootCanvasLayer
{
    return nil;
}

- (void)setupRootCanvasLayer:(id)aLayer
{
}

- (id)rootCanvasLayer
{
    if (_rootCanvasLayer == nil && !_ignoreCreateCanvasLayerTree) {
        _rootCanvasLayer = [self createRootCanvasLayer];
        [self setupRootCanvasLayer:_rootCanvasLayer];
        [_rootCanvasLayer setContext:self];
        [_rootCanvasLayer setRepresentedObject:[self userObject]];
    }
    return _rootCanvasLayer;
}

- (id)rootCanvasLayerCreateIfNeeded:(BOOL)aNeeded
{
    if (aNeeded)
        return [self rootCanvasLayer];
    return _rootCanvasLayer;
}

- (id)initWithFrame:(NSRect)aFrame ignoreCreateRootCanvasLayer:(BOOL)aLayer
{
    self = [self initWithFrame:aFrame];
    if (self != nil)
        _ignoreCreateCanvasLayerTree = aLayer;
    return self;
}

- (void)dealloc
{
    [[self userObject] removeAttributeObserver:self];
    [_canvasHitTester setCanvasLayerContext:nil];
    [_canvasHitTester release];
    [_rootCanvasLayer setContext:nil];
    [_rootCanvasLayer release];
    [super dealloc];
}

@end

@implementation HSUserObjectInteractiveView (HSUserObjectInteractiveViewStateInfo)

- (void)setLastClickPosition:(NSPoint)aPosition
{
    _lastClickPosition = aPosition;
}

- (NSPoint)lastClickPosition
{
    return _lastClickPosition;
}

@end
