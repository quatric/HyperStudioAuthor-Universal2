#import "HSInteractiveModeMouseOverInfo.h"
#import "HSActionEvent.h"
#import "HSActionExecutionContext.h"
#import "HSActionExecutionManager.h"
#import "HSCursorSynchronizer.h"
#import "HSFlickAnimation.h"
#import "HSFlickGestureRecognizer.h"
#import "HSMouseTracker.h"
#import "HSMoveCardObjectTracker.h"
#import "HSMoveSnappingCardObjectTracker.h"
#import "HSResizeCardObjectTracker.h"
#import "HSRotateCardObjectTracker.h"
#import "HSTrackingLoop.h"

// Within 0.0005 of the larger magnitude, zero counting as 1.
static BOOL HSInteractiveObjectsLayerFloatsAreEqual(float aValue, float aValue2)
{
    float magnitude = (aValue != 0.0f) ? fabsf(aValue) : 1.0f;
    float magnitude2 = (aValue2 != 0.0f) ? fabsf(aValue2) : 1.0f;
    if (magnitude2 <= magnitude)
        magnitude2 = magnitude;
    return fabsf(aValue - aValue2) <= magnitude2 * 0.0005f;
}

@implementation HSInteractiveModeMouseOverInfo

/* i386 ivar offsets: _location=0x4, _node=0xc */

- (void)setNode:(id)aNode
{
    if (_node != aNode) {
        [_node release];
        _node = [aNode retain];
    }
}

- (id)node
{
    return _node;
}

- (void)setLocation:(NSPoint)aLocation
{
    _location = aLocation;
}

- (NSPoint)location
{
    return _location;
}

- (void)dealloc
{
    [_node release];
    [super dealloc];
}

@end

@implementation HSInteractiveObjectsLayer

/* i386 ivar offsets: _mouseOverInfo=0x18, _disabled=0x1c, _lastActiveTextViewItem=0x20, _flickRecognizer=0x24, _touchIdentityToHitItemMap=0x28 */

- (void)setDisabled:(BOOL)aDisabled
{
    _disabled = aDisabled;
}

- (BOOL)isDisabled
{
    return _disabled;
}

- (void)willStopRunning
{
    [self setActiveItem:nil];
}

- (void)didStartRunning
{
    NSEnumerator *nodes = [[self rootRepresentedNode] hyperEnumerator];
    id node;
    while ((node = [nodes nextObject]) != nil)
        [[[self canvasItemForNode:node] queryHyperInterface:@protocol(HSInteractivePlayerItem)] awakeInPlayer];
}

// Nothing in the layer creates the flick recognizer or fills the touch map
// (original), so the touch handlers only forward to a recognizer set from
// outside.
- (BOOL)handleTouchesCancelledWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    if (_flickRecognizer == nil)
        return NO;
    BOOL handled = [_flickRecognizer touchesCancelledWithEvent:aEvent];
    [_flickRecognizer release];
    _flickRecognizer = nil;
    for (NSTouch *touch in [aEvent touchesMatchingPhase:NSTouchPhaseCancelled inView:nil])
        [_touchIdentityToHitItemMap removeObjectForKey:[touch identity]];
    return handled;
}

- (BOOL)handleTouchesEndedWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    if (_flickRecognizer == nil)
        return NO;
    BOOL handled = [_flickRecognizer touchesEndedWithEvent:aEvent];
    [_flickRecognizer release];
    _flickRecognizer = nil;
    for (NSTouch *touch in [aEvent touchesMatchingPhase:NSTouchPhaseEnded inView:nil])
        [_touchIdentityToHitItemMap removeObjectForKey:[touch identity]];
    return handled;
}

- (BOOL)handleTouchesMovedWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return [_flickRecognizer touchesMovedWithEvent:aEvent];
}

- (BOOL)handleTouchesBeganWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    return [_flickRecognizer touchesBeganWithEvent:aEvent];
}

// Flicks the item hit by the first touch, at 1400 points per second at least.
- (void)handleFlickGesture:(id)aGesture
{
    id item = [_touchIdentityToHitItemMap objectForKey:[(NSTouch *)[_flickRecognizer initialTouch] identity]];
    // The original built the array with a nil item too, which raises.
    if (item == nil)
        return;
    NSArray *items = [NSArray arrayWithObject:item];
    CGFloat velocity = [(HSFlickGestureRecognizer *)aGesture velocity];
    if (velocity < 1400.0)
        velocity = 1400.0;
    HSFlickAnimation *animation = [[HSFlickAnimation alloc] initWithObjects:items velocity:velocity direction:[(HSFlickGestureRecognizer *)aGesture direction]];
    [animation setAnimationBlockingMode:NSAnimationNonblocking];
    [animation startAnimation];
    [animation release];
}

- (BOOL)handleSwipeGesture:(id)aGesture hitTestInfo:(id)aInfo
{
    return NO;
}

- (BOOL)handleRotationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    BOOL rotatable = [self itemIsRotatable:aInfo];
    if (rotatable)
        [self rotateObject:aInfo aboutCenterBy:([(NSEvent *)aEvent rotation] * M_PI) / -180.0];
    return rotatable;
}

- (BOOL)handleMagnificationGestureWithEvent:(id)aEvent hitTestInfo:(id)aInfo
{
    BOOL resizable = [self itemIsResizable:aInfo];
    if (resizable)
        [self scaleObject:aInfo aboutCenterBy:[(NSEvent *)aEvent magnification] + 1.0];
    return resizable;
}

- (void)rotateObject:(id)aObject aboutCenterBy:(CGFloat)aBy
{
    [[[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] rotateBy:aBy aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
}

- (void)scaleObject:(id)aObject aboutCenterBy:(CGFloat)aBy
{
    id textView = [aObject queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    if (textView != nil)
        [self scaleTextObject:textView aboutCenterBy:aBy];
    [[[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] resizeFrameBy:NSMakeSize(aBy, aBy) aboutRelativePoint:NSMakePoint(0.5, 0.5) withLayoutGuidingContext:nil];
}

- (void)scaleTextObject:(id)aObject aboutCenterBy:(CGFloat)aBy
{
    id font = [aObject queryHyperInterface:@protocol(HSGenericFontAttributes)];
    [font setHyperFontSize:[font hyperFontSize] * aBy];
}

- (BOOL)resignFirstResponder
{
    if ([self activeItem] != nil)
        [self setActiveItem:nil];
    return YES;
}

- (id)activeTextField
{
    return [[[self activeInteractiveTextView] hyperObject] queryHyperInterface:@protocol(HSStringContentAttributes)];
}

- (void)saveEditingState
{
    [[[self activeItem] queryHyperInterface:@protocol(HSInteractiveTextObject)] saveEditingState];
}

- (NSRange)selectedRangeInNode:(id)aNode
{
    id item = (aNode != nil) ? [self canvasItemForNode:aNode] : [self activeItem];
    id textObject = [item queryHyperInterface:@protocol(HSInteractiveTextObject)];
    if (textObject == nil)
        return NSMakeRange(NSNotFound, 0);
    return [textObject selectedRange];
}

// A node's text object is activated first when it can be.
- (void)selectRange:(NSRange)aRange inNode:(id)aNode
{
    id textObject;
    if (aNode == nil) {
        textObject = [[self activeItem] queryHyperInterface:@protocol(HSInteractiveTextObject)];
    } else {
        id item = [self canvasItemForNode:aNode];
        textObject = [item queryHyperInterface:@protocol(HSInteractiveTextObject)];
        if (item != nil && item != [self activeItem] && [textObject canBeActivated])
            [self setActiveItem:item];
    }
    [textObject selectRange:aRange];
}

// Only direct children of the represented node get activated.
- (void)doCommandBySelector:(SEL)aSelector forNode:(id)aNode
{
    id target;
    if (aNode == nil) {
        target = [self activeInteractiveTextView];
    } else {
        id parent = [[aNode queryHyperInterface:@protocol(HSNodeChild)] hyperParent];
        id root = [self rootRepresentedNode];
        id item = [self canvasItemForNode:aNode];
        id textObject = [item queryHyperInterface:@protocol(HSInteractiveTextObject)];
        if (item != nil && item != [self activeItem] && (textObject == nil || [textObject canBeActivated]) && parent == root)
            [self setActiveItem:item];
        target = [item queryHyperInterface:@protocol(HSInteractiveTextObject)];
    }
    [(id<HSInteractiveTextObject>)target doCommandBySelector:aSelector];
}

- (void)insertText:(id)aText toNode:(id)aNode
{
    id textObject;
    if (aNode == nil) {
        textObject = [[self activeInteractiveTextView] queryHyperInterface:@protocol(HSInteractiveTextObject)];
    } else {
        id item = [self canvasItemForNode:aNode];
        textObject = [item queryHyperInterface:@protocol(HSInteractiveTextObject)];
        id parent = [[aNode queryHyperInterface:@protocol(HSNodeChild)] hyperParent];
        id root = [self rootRepresentedNode];
        if (item != nil && item != [self activeItem] && [textObject canBeActivated] && parent == root)
            [self setActiveItem:item];
    }
    if (aText != nil)
        [(id<HSInteractiveTextObject>)textObject insertText:aText];
}

// The active text view, else the last one that was active, else the first
// one on the card; the found one is activated.
- (id)activeInteractiveTextView
{
    id textView = nil;
    if ([self isCorrectInteractiveTextViewItem:[self activeItem]]) {
        textView = [[self activeItem] queryHyperInterface:@protocol(HSInteractiveSystemViewItemInterface)];
        if (textView != nil)
            return textView;
    }
    if ([self isCorrectInteractiveTextViewItem:_lastActiveTextViewItem]) {
        NSEnumerator *nodes = [[self rootRepresentedNode] hyperEnumerator];
        id node;
        while ((node = [nodes nextObject]) != nil) {
            id item = [self canvasItemForNode:node];
            if (item == _lastActiveTextViewItem) {
                [self setActiveItem:item];
                textView = [item queryHyperInterface:@protocol(HSInteractiveSystemViewItemInterface)];
                break;
            }
        }
    }
    if (textView != nil)
        return textView;
    [_lastActiveTextViewItem release];
    _lastActiveTextViewItem = nil;
    NSEnumerator *nodes = [[self rootRepresentedNode] hyperEnumerator];
    id node;
    while ((node = [nodes nextObject]) != nil) {
        id item = [self canvasItemForNode:node];
        if ([self isCorrectInteractiveTextViewItem:item]) {
            [self setActiveItem:item];
            return [item queryHyperInterface:@protocol(HSInteractiveSystemViewItemInterface)];
        }
    }
    return nil;
}

// A shown, editable, unrotated system text view on a card whose objects are
// not all hidden.
- (BOOL)isCorrectInteractiveTextViewItem:(id)aItem
{
    if (aItem == nil || ![aItem implementsHyperInterface:@protocol(HSInteractiveSystemViewItemInterface)])
        return NO;
    if ([[[aItem hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)] isHiddenInPlayer])
        return NO;
    id object = [aItem hyperObject];
    id visibility = [[[object queryHyperInterface:@protocol(HSUserObjectSupport)] stack] queryHyperInterface:@protocol(HSStackCardObjectsVisibilityAttribute)];
    if ([visibility cardObjectsVisibility] == 1)
        return NO;
    id textView = [object queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    if (![textView isEditable])
        return NO;
    return ![textView isRotatableText];
}

// Return clicks the first default system button.
- (void)insertNewline:(id)aNewline
{
    NSEnumerator *nodes = [[self rootRepresentedNode] hyperEnumerator];
    id node;
    while ((node = [nodes nextObject]) != nil) {
        id button = [node queryHyperInterface:@protocol(HSButtonObjectAttributes)];
        if (button == nil || ![[(id<HSButtonObjectAttributes>)button backgroundStyle] isEqual:@"HSButtonObjectSystemBackgroundStyle"])
            continue;
        if (![[[[button background] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] systemButtonType] isEqual:@"HSDefaultSystemButtonType"])
            continue;
        [self sendClickActionsForItemIfNeeded:[self canvasItemForNode:node]];
        return;
    }
}

- (void)cancelOperation:(id)aOperation
{
    [[self actionExecutionContext] cancelOperation:aOperation];
}

// A handled cancel still returns NO (original).
- (BOOL)handleKeyEventSelector:(SEL)aSelector
{
    if (aSelector == @selector(cancelOperation:)) {
        if ([[self actionExecutionContext] canCancelOperation])
            [self cancelOperation:nil];
        return NO;
    }
    if (![self respondsToSelector:aSelector])
        return NO;
    [self performSelector:aSelector withObject:nil];
    return YES;
}

- (BOOL)handleRawKeyUpEvent:(id)aEvent
{
    if ([self isDisabled])
        return NO;
    return [[self actionExecutionContext] handleKeyUpEvent:aEvent];
}

// Option-Escape stops all automatic timers.
- (BOOL)handleRawKeyDownEvent:(id)aEvent
{
    BOOL notEscape = YES;
    if ([[aEvent characters] length] != 0)
        notEscape = [[aEvent characters] characterAtIndex:0] != 0x1b;
    if (([aEvent modifierFlags] & NSEventModifierFlagOption) && !notEscape)
        [[[self actionExecutionManager] automaticTimerManager] stopAllAutomaticActionTimers];
    if ([self isDisabled])
        return NO;
    return [self performActionForKeyEvent:aEvent];
}

- (BOOL)handleKeyEquivalent:(id)aEquivalent
{
    return [self performActionForKeyEvent:aEquivalent];
}

- (BOOL)performActionForKeyEvent:(id)aEvent
{
    return [[self actionExecutionContext] runActionsForKeyEvent:aEvent];
}

// Command-Option shows the borders of shape buttons.
- (BOOL)handleFlagsChanged:(id)aChanged atPoint:(NSPoint)aPoint
{
    NSUInteger flags = [aChanged modifierFlags];
    BOOL showBorder = (flags & NSEventModifierFlagCommand) && (flags & NSEventModifierFlagOption);
    id context = [[self renderingView] queryHyperInterface:@protocol(HSInteractiveCanvasLayerContext)];
    if (context != nil)
        [context updateShapeButtonsShowBorder:showBorder];
    return context != nil;
}

- (void)setMouseOverInfo:(id)aInfo
{
    if (_mouseOverInfo != aInfo) {
        [_mouseOverInfo release];
        _mouseOverInfo = [aInfo retain];
    }
}

- (id)mouseOverInfo
{
    return _mouseOverInfo;
}

- (void)willUnregisterCanvasItem:(id)aItem forNode:(id)aNode
{
    if (_mouseOverInfo != nil && [_mouseOverInfo node] == [self representedObjectForCanvasItem:aItem])
        [self setMouseOverInfo:nil];
    [super willUnregisterCanvasItem:aItem forNode:aNode];
}

// A new item above the mouse-over one under the mouse resets the mouse-over.
- (void)didRegisterCanvasItem:(id)aItem forNode:(id)aNode
{
    [super didRegisterCanvasItem:aItem forNode:aNode];
    if (_mouseOverInfo == nil)
        return;
    if (![self hitTestPoint:[(HSInteractiveModeMouseOverInfo *)[self mouseOverInfo] location] inItem:aItem])
        return;
    NSUInteger index = [[self representedObjectForCanvasItem:aItem] hyperIndex];
    if ([[_mouseOverInfo node] hyperIndex] < index)
        [self setMouseOverInfo:nil];
}

// Mouse-over actions run when the mouse enters another item.
- (BOOL)handleMouseMovedAtPoint:(NSPoint)aPoint insideView:(BOOL)aView event:(id)aEvent
{
    if (_mouseOverInfo != nil) {
        NSPoint location = [(HSInteractiveModeMouseOverInfo *)[self mouseOverInfo] location];
        if (HSInteractiveObjectsLayerFloatsAreEqual(location.x, aPoint.x) && HSInteractiveObjectsLayerFloatsAreEqual(location.y, aPoint.y))
            return YES;
    }
    id item = aView ? [self hitTestItem:aPoint] : nil;
    id node = [self representedObjectForCanvasItem:item];
    BOOL changed = _mouseOverInfo == nil || [_mouseOverInfo node] != node;
    if (item == nil)
        [self setMouseOverInfo:nil];
    else if (_mouseOverInfo == nil)
        [self setMouseOverInfo:[[HSInteractiveModeMouseOverInfo new] autorelease]];
    if (_mouseOverInfo != nil) {
        [(HSInteractiveModeMouseOverInfo *)_mouseOverInfo setLocation:aPoint];
        [_mouseOverInfo setNode:node];
    }
    if (changed && item != nil)
        [self sendMouseOverActionsForItem:item];
    return YES;
}

- (void)contextWillChange
{
    [self setActiveItem:nil];
}

// The microphone while recording; draggable items get the draggable cursor;
// otherwise the cursor of the parent item.
- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inHitItem:(id)aItem
{
    id cursor = nil;
    if ([[self actionExecutionContext] isRecording])
        cursor = [HSCursor microphoneCursor];
    if (cursor == nil)
        cursor = [super cursorAtPoint:aPoint modifierFlags:aFlags inHitItem:aItem];
    if (cursor == nil && [self itemIsDraggable:aItem])
        cursor = [HSCursor draggableCursor];
    if (cursor == nil) {
        id parent = [[[aItem queryHyperInterface:@protocol(HSNodeChild)] hyperParent] queryHyperInterface:@protocol(HSNodeAttributes)];
        if (parent != nil) {
            id parentItem = [self canvasItemForNode:parent];
            if (parentItem != nil)
                cursor = [self cursorAtPoint:aPoint modifierFlags:aFlags inHitItem:parentItem];
        }
    }
    return cursor;
}

- (id)cursorForPoint:(NSPoint)aPoint insideView:(BOOL)aView modifierFlags:(NSUInteger)aFlags hitTestInfo:(id)aInfo event:(id)aEvent
{
    id cursor = [super cursorForPoint:aPoint insideView:aView modifierFlags:aFlags hitTestInfo:aInfo event:aEvent];
    if (cursor == nil)
        cursor = [self itemHasClickActions:aInfo] ? [HSCursor actionCursor] : [self defaultInteractiveModeCursor];
    return cursor;
}

- (id)defaultInteractiveModeCursor
{
    return [HSCursor defaultPlayerCursor];
}

- (BOOL)handleScrollWheelAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    if (![self isDisabled] && aInfo != nil && [aInfo wantsToTrackMouseWithScrollWheelEvent:aEvent inInteractiveContext:self])
        return [aInfo trackMouseWithScrollWheelEvent:aEvent inInteractiveContext:self];
    return NO;
}

- (BOOL)handleMouseUpAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    if (![self isDisabled] && aInfo != nil && [self activeItem] == aInfo
        && [aInfo wantsToTrackMouseWithMouseUpEvent:aEvent inInteractiveContext:self]) {
        [aInfo trackMouseWithMouseUpEvent:aEvent inInteractiveContext:self];
        return YES;
    }
    return NO;
}

// Clicking the card itself (the root item) uses its click actions, else
// those of the card's parent. Items that neither take clicks nor move, or
// that pass the event through, hand it to the next item under the mouse.
// Ctrl-click opens the links in the item's comments.
- (BOOL)handleMouseDownAtPoint:(NSPoint)aPoint event:(id)aEvent hitTestInfo:(id)aInfo
{
    HSActionExecutionContext *context = [[self actionExecutionContext] retain];
    [aInfo retain];
    BOOL result = NO;
    id item = nil;

    if ([context handleMouseDownEvent:aEvent] || [self isDisabled])
        goto done;
    [context handleClickInInteractiveLayer];
    if ([context isSlideshow] && [context slideshowExecutedByAction]) {
        BOOL useClickOnExitCard = [[context currentSlideshowAttributes] useClickOnExitCard];
        [context stopSlideshow];
        if (!useClickOnExitCard) {
            result = YES;
            goto done;
        }
    }

    if ([self canvasItemForNode:[self rootRepresentedNode]] != aInfo) {
        item = aInfo;
    } else {
        [self setActiveItem:nil];
        if ([self itemHasClickActions:aInfo]) {
            item = aInfo;
        } else {
            id parent = [[self rootRepresentedNode] hyperParent];
            if (parent != nil) {
                item = [self canvasItemForNode:parent];
                if (item != nil && ![self itemHasClickActions:item])
                    item = nil;
            }
        }
    }
    if (item == nil) {
        goto done;
    }

    if (item != [self activeItem]) {
        id activation = [item queryHyperInterface:@protocol(HSInteractivePlayerItemActivation)];
        if (activation != nil && [activation wantsToActivateWithMouseInInteractiveContext:self])
            [self setActiveItem:activation];
    }
    BOOL wantsToTrack = [item wantsToTrackMouseWithMouseDownEvent:aEvent inInteractiveContext:self];
    BOOL passesToItem = [[item queryHyperInterface:@protocol(HSInteractiveTextObject)] hasExecutableActionsForMouseDownEvent:aEvent inInteractiveContext:self];
    if (!passesToItem) {
        id attributes = [[item hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
        if ([aEvent modifierFlags] & NSEventModifierFlagControl) {
            // No reset of the recording flag here (original).
            id comments = [[[item hyperObject] queryHyperInterface:@protocol(HSCommentsAttributes)] hyperComments];
            for (NSURL *link in [comments hyperRecognizedLinks]) {
                if ([[NSWorkspace sharedWorkspace] openURL:link])
                    result = YES;
            }
            goto done;
        }
        BOOL takesMouse = (![attributes isNoClick] && ![attributes isDropOffOnly])
            || [attributes isDraggable] || [attributes isResizable] || [attributes isRotatable];
        // Later items are never asked whether they track the mouse themselves,
        // and when no item takes the event the last one is tracked anyway
        // (original).
        while (!takesMouse || [item wantsToPassThroughMouseDownEvent:aEvent inInteractiveContext:self]) {
            id next = nil;
            NSView *view = [self renderingView];
            NSPoint point = [view convertPoint:[[view window] mouseLocationOutsideOfEventStream] fromView:nil];
            BOOL inside = [view mouse:point inRect:[view visibleRect]];
            [self hitTestNextInteractiveItemAfterItem:item atPoint:point insideView:inside clickCount:[aEvent clickCount] modifierFlags:[aEvent modifierFlags] hitTestInfo:&next];
            if (next == nil) {
                wantsToTrack = NO;
                break;
            }
            item = next;
            wantsToTrack = NO;
            attributes = [[next hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
            takesMouse = (![attributes isNoClick] && ![attributes isDropOffOnly])
                || [attributes isDraggable] || [attributes isResizable] || [attributes isRotatable];
        }
    }

    [item retain];
    if (wantsToTrack) {
        [item trackMouseWithMouseDownEvent:aEvent inInteractiveContext:self];
    } else {
        // The item is tracked, then gets its click actions when the mouse was
        // released over the layer and its drop-off actions when it was moved.
        BOOL wasDragged = NO;
        [self trackMouseForItem:item withMouseDownEvent:aEvent wasDragged:&wasDragged];
        NSView *view = [self renderingView];
        NSPoint point = [view convertPoint:[[view window] mouseLocationOutsideOfEventStream] fromView:nil];
        BOOL inside = [view mouse:point inRect:[view visibleRect]];
        if ([self hitTestCanvasLayerAtPoint:point insideView:inside clickCount:[aEvent clickCount] modifierFlags:[aEvent modifierFlags] hitTestInfo:NULL] != nil) {
            id attributes = [[item hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
            if (![attributes isNoClick] && ![attributes isDropOffOnly])
                [self sendClickActionsForItemIfNeeded:item];
            if (wasDragged)
                [self sendDropOffActionsFromItemIfNeeded:item];
        }
    }
    [item autorelease];
    result = YES;

done:
    [context autorelease];
    [aInfo autorelease];
    return result;
}

// Option-drag drags image objects out; otherwise the item is moved, resized
// or rotated, or the mouse is just tracked.
- (void)trackMouseForItem:(id)aItem withMouseDownEvent:(id)aEvent wasDragged:(BOOL *)aDragged
{
    *aDragged = NO;
    if ([aEvent modifierFlags] & NSEventModifierFlagOption) {
        id image = [aItem queryHyperInterface:@protocol(HSImageObjectAttributes)];
        if (image == nil || ![[self renderingView] respondsToSelector:@selector(startDragWithNodes:event:)])
            return;
        [[self renderingView] startDragWithNodes:[NSArray arrayWithObject:image] event:aEvent];
        return;
    }
    if ([self itemIsDraggable:aItem])
        [self trackMouseForDraggableItem:aItem withMouseDownEvent:aEvent wasDragged:aDragged];
    else if ([self itemIsResizable:aItem])
        [self trackMouseForResizableItem:aItem withMouseDownEvent:aEvent wasResized:aDragged];
    else if ([self itemIsRotatable:aItem])
        [self trackMouseForRotatableItem:aItem withMouseDownEvent:aEvent wasRotated:aDragged];
    else
        [[HSTrackingLoop nonAutoscrollingTrackingLoopWithView:[self renderingView] client:[[HSMouseTracker new] autorelease]] runWithMouseDownEvent:aEvent];
}

- (void)trackMouseForDraggableItem:(id)aItem withMouseDownEvent:(id)aEvent wasDragged:(BOOL *)aDragged
{
    id node = [aItem queryHyperInterface:@protocol(HSNodeAttributes)];
    if (node == nil)
        return;
    id tracker = [self moveCardObjectTrackerForNode:node];
    [tracker setLayoutGuidingContext:[[[self context] queryHyperInterface:@protocol(HSLayoutGuidingContextProvider)] layoutGuidingContext]];
    [tracker setTrackingObject:node];
    HSTrackingLoop *loop = [HSTrackingLoop nonAutoscrollingTrackingLoopWithView:[self renderingView] client:tracker];
    NSPoint point = [[self renderingView] convertPoint:[aEvent locationInWindow] fromView:nil];
    id cursor = [aItem cursorAtPoint:point modifierFlags:[aEvent modifierFlags] inCanvasLayer:self];
    if (cursor == nil)
        cursor = [HSCursor draggingCursor];
    [loop setCursor:cursor];
    [loop runWithMouseDownEvent:aEvent];
    if (aDragged != NULL)
        *aDragged = [loop wasTracked];
}

// Objects with a drop-off target snap to it.
- (id)moveCardObjectTrackerForNode:(id)aNode
{
    id identification = [aNode queryHyperInterface:@protocol(HSMutableSnappingTargetUIDIdentification)];
    id parent = [[[aNode hyperObject] hyperParent] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
    id target = [[parent childInTreeWithUID:[identification dropOffTargetUID]] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
    if (target != nil)
        return [[HSMoveSnappingCardObjectTracker new] autorelease];
    return [[HSMoveCardObjectTracker new] autorelease];
}

- (void)trackMouseForRotatableItem:(id)aItem withMouseDownEvent:(id)aEvent wasRotated:(BOOL *)aRotated
{
    id node = [aItem queryHyperInterface:@protocol(HSNodeAttributes)];
    if (node == nil)
        return;
    HSRotateCardObjectTracker *tracker = [[HSRotateCardObjectTracker new] autorelease];
    [tracker setLayoutGuidingContext:[[[self context] queryHyperInterface:@protocol(HSLayoutGuidingContextProvider)] layoutGuidingContext]];
    [tracker setTrackingObject:node];
    HSTrackingLoop *loop = [HSTrackingLoop nonAutoscrollingTrackingLoopWithView:[self renderingView] client:tracker];
    [loop runWithMouseDownEvent:aEvent];
    if (aRotated != NULL)
        *aRotated = [loop wasTracked];
}

- (void)trackMouseForResizableItem:(id)aItem withMouseDownEvent:(id)aEvent wasResized:(BOOL *)aResized
{
    id node = [aItem queryHyperInterface:@protocol(HSNodeAttributes)];
    if (node == nil)
        return;
    HSResizeCardObjectTracker *tracker = [[HSResizeCardObjectTracker new] autorelease];
    [tracker setLayoutGuidingContext:[[[self context] queryHyperInterface:@protocol(HSLayoutGuidingContextProvider)] layoutGuidingContext]];
    [tracker setTrackingObject:node];
    HSTrackingLoop *loop = [HSTrackingLoop nonAutoscrollingTrackingLoopWithView:[self renderingView] client:tracker];
    [loop runWithMouseDownEvent:aEvent];
    if (aResized != NULL)
        *aResized = [loop wasTracked];
}

// Nothing is activated while a sheet is open. The text view being left is
// remembered for activeInteractiveTextView.
- (void)setActiveItem:(id)aItem
{
    id sheet = [[[self renderingView] window] attachedSheet];
    id activeItem = [self activeItem];
    id item = (sheet == nil) ? aItem : nil;
    if ([self isCorrectInteractiveTextViewItem:activeItem]) {
        [activeItem retain];
        [_lastActiveTextViewItem release];
        _lastActiveTextViewItem = activeItem;
    }
    [super setActiveItem:item];
}

- (void)deactivateInteractiveItem:(id)aItem
{
    [self setActiveItem:nil];
}

// After a move, the drop-off target under the item's center (when it is not
// covered by another item) or the topmost other item there gets its drop
// actions.
- (void)sendDropOffActionsFromItemIfNeeded:(id)aNeeded
{
    if (![self itemIsDraggable:aNeeded] && ![self itemIsResizable:aNeeded] && ![self itemIsRotatable:aNeeded])
        return;
    NSRect frame = [[aNeeded queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
    frame = [[self renderingView] viewBoundingRectForUserRect:frame];
    NSPoint center = NSMakePoint(frame.size.width * 0.5 + frame.origin.x, frame.size.height * 0.5 + frame.origin.y);
    id target = [self hitTestDropOffTargetItemForItem:aNeeded inLocation:center];
    NSUInteger targetIndex = [self indexOfCanvasItem:target];
    id hit = [self hitTestItem:center];
    if ([hit isEqual:aNeeded])
        hit = [self hitTestItem:center totalCount:[self indexOfCanvasItem:aNeeded]];
    if (targetIndex != NSNotFound && [self indexOfCanvasItem:hit] <= targetIndex)
        hit = target;
    if ([[hit queryHyperInterface:@protocol(HSCardObjectAttributes)] canSendActionsOnDrop])
        [self sendDropOffActionsForItem:[hit queryHyperInterface:@protocol(HSInteractivePlayerItem)]];
}

// The item's drop-off-only target, when the location is on it (or, with
// snapping, exactly at its center).
- (id)hitTestDropOffTargetItemForItem:(id)aItem inLocation:(NSPoint)aLocation
{
    id attributes = [aItem queryHyperInterface:@protocol(HSCardObjectAttributes)];
    id card = [[self actionExecutionContext] card];
    id snapOptions = [attributes queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)];
    id access = [card queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
    id target = [[access childInTreeWithUID:[snapOptions dropOffTargetUID]] queryHyperInterface:@protocol(HSMutableCardObjectAttributes)];
    id targetSnapOptions = [target queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)];
    id targetAttributes = [target queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if (targetSnapOptions == nil || ![targetAttributes isDropOffOnly])
        return nil;
    NSRect frame = [[target queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
    frame = [[self renderingView] viewBoundingRectForUserRect:frame];
    if ([targetSnapOptions isDropOffSnappingEnabled]) {
        float centerX = frame.size.width * 0.5f + frame.origin.x;
        float centerY = frame.size.height * 0.5f + frame.origin.y;
        if (!HSInteractiveObjectsLayerFloatsAreEqual(aLocation.x, centerX) || !HSInteractiveObjectsLayerFloatsAreEqual(aLocation.y, centerY))
            return nil;
    } else if (!NSPointInRect(aLocation, frame)) {
        return nil;
    }
    return [self canvasItemForNodeIfExists:[target queryHyperInterface:@protocol(HSNodeAttributes)]];
}

- (void)sendDropOffActionsForItem:(id)aItem
{
    id attributes = [aItem queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if ([self sendingDropOffOnlyActionIsDisabledForItem:aItem] || ![attributes isDropOffOnly])
        return;
    [[self actionExecutionManager] runActionsForObject:aItem withEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType] inContext:[self actionExecutionContext] forRequestor:self];
}

- (BOOL)sendingDropOffOnlyActionIsDisabledForItem:(id)aItem
{
    id snapOptions = [aItem queryHyperInterface:@protocol(HSMutableSnapOptionsAttributes)];
    if (![aItem sendingActionsIsDisabled])
        return NO;
    return ![snapOptions isDropOffTarget];
}

- (BOOL)performActionsMappedToKeyEvent:(id)aEvent
{
    return [self performActionForKeyEvent:aEvent];
}

- (void)sendClickActionsForHypertextLink:(id)aLink
{
    if (aLink == nil)
        return;
    [[self actionExecutionManager] runActionsForObject:[aLink hyperObject] withEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType] inContext:[self actionExecutionContext] forRequestor:self];
}

// Mouse-over actions belong to "no click" objects; nothing runs while a sheet
// is open.
- (void)sendMouseOverActionsForItem:(id)aItem
{
    id attributes = [aItem queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if ([aItem sendingActionsIsDisabled] || ![attributes isNoClick])
        return;
    if ([[[self renderingView] window] attachedSheet] != nil)
        return;
    [[self actionExecutionManager] runActionsForObject:aItem withEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType] inContext:[self actionExecutionContext] forRequestor:self];
}

- (void)sendClickActionsForItemIfNeeded:(id)aNeeded
{
    [[self actionExecutionContext] handleClickInInteractiveLayer];
    if ([aNeeded sendingActionsIsDisabled] || [aNeeded wantsToInterceptSendingClickActionsInInteractiveContext:self])
        return;
    HSActionEvent *event = [HSActionEvent actionEventOfType:kHSClickActionEventType];
    [[self actionExecutionManager] runActionsForObject:aNeeded withEvent:event inContext:[self actionExecutionContext] forRequestor:self];
}

- (BOOL)itemHasClickActions:(id)aActions
{
    if ([aActions sendingActionsIsDisabled])
        return NO;
    id actor = [aActions queryHyperInterface:@protocol(HSActor)];
    if (actor == nil)
        return NO;
    return [[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]] count] != 0;
}

- (BOOL)itemHasHyperActions:(id)aActions
{
    id actor = [aActions queryHyperInterface:@protocol(HSActor)];
    if (actor == nil)
        return NO;
    return [[actor hyperActions] count] != 0;
}

- (BOOL)itemIsDraggable:(id)aDraggable
{
    return [[aDraggable queryHyperInterface:@protocol(HSCardObjectAttributes)] isDraggable];
}

- (BOOL)itemIsResizable:(id)aResizable
{
    return [[aResizable queryHyperInterface:@protocol(HSCardObjectAttributes)] isResizable];
}

- (BOOL)itemIsRotatable:(id)aRotatable
{
    return [[aRotatable queryHyperInterface:@protocol(HSCardObjectAttributes)] isRotatable];
}

// Hidden objects and animated ones that are not interactive while animating
// are never hit.
- (BOOL)hitTestPoint:(NSPoint)aPoint inItem:(id)aItem
{
    id attributes = [aItem queryHyperInterface:@protocol(HSCardObjectAttributes)];
    id animated = [aItem queryHyperInterface:@protocol(HSAnimatedObjectAttributes)];
    if ([attributes isHiddenInPlayer])
        return NO;
    if ([animated isAnimatedObject] && ![animated isInteractiveInAnimation])
        return NO;
    return [super hitTestPoint:aPoint inItem:aItem];
}

- (BOOL)supportsHitTesting
{
    return YES;
}

- (BOOL)hasRepresentationForRootNode
{
    return YES;
}

- (id)actionExecutionManager
{
    return [[self context] actionExecutionManager];
}

- (id)actionExecutionContext
{
    return [[self context] actionExecutionContext];
}

- (id)nodeVisualizationDisabling
{
    return [[self context] queryHyperInterface:@protocol(HSNodeVisualizationDisabling)];
}

- (id)queryCanvasItemForNode:(id)aNode
{
    return [aNode queryHyperInterface:@protocol(HSInteractivePlayerItem)];
}

// The parent of the represented node (the background of the card) comes
// first when there is one.
- (id)objectInRepresentedObjectsAtIndex:(NSUInteger)aIndex
{
    if ([self rootRepresentedNode] != nil && [[self rootRepresentedNode] hyperParent] != nil) {
        if (aIndex == 0)
            return [[self rootRepresentedNode] hyperParent];
        return [super objectInRepresentedObjectsAtIndex:aIndex - 1];
    }
    return [super objectInRepresentedObjectsAtIndex:aIndex];
}

- (NSUInteger)countOfRepresentedObjects
{
    if ([self rootRepresentedNode] != nil && [[self rootRepresentedNode] hyperParent] != nil)
        return [super countOfRepresentedObjects] + 1;
    return [super countOfRepresentedObjects];
}

- (BOOL)isTextObject:(id)aObject
{
    return [aObject implementsHyperInterface:@protocol(HSInteractiveTextObject)];
}

- (id)context
{
    return [super context];
}

- (void)dealloc
{
    [_mouseOverInfo release];
    [_lastActiveTextViewItem release];
    [_flickRecognizer release];
    [_touchIdentityToHitItemMap release];
    [super dealloc];
}

- (BOOL)canActivateNonScalableObjects
{
    return [[[self renderingView] queryHyperInterface:@protocol(HSInteractiveCanvasLayerContext)] canActivateNonScalableObjects];
}

- (BOOL)canActivateTextObjects
{
    return [self canActivateNonScalableObjects];
}

@end
