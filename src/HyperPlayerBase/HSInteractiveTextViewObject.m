#import "HSInteractiveTextViewObject.h"
#import "HSTextPortionSerialization.h"
#import "HSOverlayView.h"
#import "HSCardView.h"
#import "HSCursorSynchronizer.h"
#import "HSEditModeUndoHelper.h"
#import "HSRunTimeEditorUndoManager.h"
#import "HSMouseTracker.h"
#import "HSTrackingLoop.h"
#import "HSActionEvent.h"

// A system text field while playing. Activated, its text view edits the text
// (with its own undo manager whose actions are duplicated into the document's
// when editing completes); inactive, clicks on hypertext links and link
// attributes are handled from the object's system view, mapped through the
// object's transform.
@implementation HSInteractiveTextViewObject

- (void)overlayViewDidDraw:(id)aDraw
{
    [[[[self activeParentCanvasLayer] context] renderingView] interactiveSubviewDidUpdate];
}

- (void)erase:(id)aErase
{
    [[self textViewAttributes] setHyperText:[[NSAttributedString new] autorelease]];
}

- (void)deleteBackward:(id)aBackward
{
    NSUInteger length = [[[self textViewAttributes] hyperText] length];
    if (length == 0)
        return;
    NSMutableAttributedString *text = [[[self textViewAttributes] hyperText] mutableCopy];
    [text deleteCharactersInRange:NSMakeRange(length - 1, 1)];
    [[self textViewAttributes] setHyperText:text];
    [text release];
}

- (BOOL)canBeActivated
{
    return ![[self textViewAttributes] isRotatableText];
}

// Inactive, the editing commands this object implements act on the stored
// text.
- (void)doCommandBySelector:(SEL)aSelector
{
    if ([self isActive])
        [[[self view] documentView] doCommandBySelector:aSelector];
    else if ([self respondsToSelector:aSelector])
        [self performSelector:aSelector withObject:nil];
}

// A hypertext link under the point runs its actions (flashing its selection
// first when selectable); a link attribute opens its URL.
- (BOOL)textViewDidPerformClick:(id)aClick atLocation:(NSPoint)aLocation inInteractiveContext:(id)aContext
{
    NSTextView *textView = aClick;
    if ([textView selectedRange].length != 0)
        return NO;
    NSTextContainer *container = [textView textContainer];
    NSLayoutManager *layoutManager = [textView layoutManager];
    if (!layoutManager || !container)
        return NO;
    NSUInteger glyph = [layoutManager glyphIndexForPoint:aLocation inTextContainer:container];
    if (!NSPointInRect(aLocation, [layoutManager boundingRectForGlyphRange:NSMakeRange(glyph, 1) inTextContainer:container]))
        return NO;
    NSRange range = [layoutManager characterRangeForGlyphRange:NSMakeRange(glyph, 1) actualGlyphRange:NULL];
    id object = [self hyperObject];
    for (NSUInteger i = range.location; i < NSMaxRange(range); i++) {
        unsigned int start = 0;
        id link = [[object queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] hypertextLinkAtPosition:i inText:[[textView textStorage] string] startPosition:&start];
        if (link) {
            if ([textView isSelectable]) {
                NSRange selection = [textView selectedRange];
                [textView setSelectedRange:NSMakeRange(start, [[link title] length])];
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
                [textView setSelectedRange:selection];
            }
            [aContext sendClickActionsForHypertextLink:link];
            return YES;
        }
        id value = [[[object queryHyperInterface:@protocol(HSTextAttributes)] hyperText] attribute:NSLinkAttributeName atIndex:i effectiveRange:NULL];
        if (value) {
            id url = value;
            if ([value isKindOfClass:[NSString class]])
                url = [NSURL URLWithString:value];
            [[NSWorkspace sharedWorkspace] openURL:url];
        }
    }
    return NO;
}

- (void)textViewShouldCompleteEditing:(id)aEditing
{
    [aEditing breakUndoCoalescing];
    [_undoHelper finishDuplicating:YES];
    [_undoHelper release];
    _undoHelper = nil;
    [_undoManager removeAllActions];
    [self updateHyperObjectWithVisualText];
}

- (void)saveEditingState
{
    [[[self view] documentView] breakUndoCoalescing];
}

- (NSRange)selectedRange
{
    NSTextView *textView = [[self view] documentView];
    if (!textView || textView != [[[self view] window] firstResponder])
        return NSMakeRange(0, 0);
    return [textView selectedRange];
}

- (void)selectRange:(NSRange)aRange
{
    NSTextView *textView = [[self view] documentView];
    if (!textView || textView != [[[self view] window] firstResponder])
        return;
    [textView setSelectedRange:aRange];
    [textView scrollRangeToVisible:aRange];
}

// The click point in the system text view of the inactive object.
- (NSPoint)HSInteractiveTextViewObject_locationOfEvent:(NSEvent *)aEvent inTextView:(NSView *)aTextView ofSystemView:(NSView *)aSystemView inInteractiveContext:(id)aContext
{
    id renderingView = [[aContext context] renderingView];
    NSPoint point = [renderingView convertPoint:[aEvent locationInWindow] fromView:nil];
    point = [renderingView convertPointFromViewSpaceToUserSpace:point];
    CGAffineTransform transform = CGAffineTransformInvert([[[self node] queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform]);
    point = NSPointFromCGPoint(CGPointApplyAffineTransform(NSPointToCGPoint(point), transform));
    return [aTextView convertPoint:point fromView:aSystemView];
}

// Whether a hypertext link or link attribute is under the click.
- (BOOL)hasExecutableActionsForMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    if ([self isActive])
        return NO;
    NSScrollView *systemView = [[[self hyperObject] queryHyperInterface:@protocol(HSSystemViewAttribute)] hyperSystemView];
    NSTextView *textView = [systemView documentView];
    NSPoint point = [self HSInteractiveTextViewObject_locationOfEvent:aEvent inTextView:textView ofSystemView:systemView inInteractiveContext:aContext];
    if ([textView selectedRange].length != 0)
        return NO;
    NSTextContainer *container = [textView textContainer];
    NSLayoutManager *layoutManager = [textView layoutManager];
    if (!layoutManager || !container)
        return NO;
    NSUInteger glyph = [layoutManager glyphIndexForPoint:point inTextContainer:container];
    if (!NSPointInRect(point, [layoutManager boundingRectForGlyphRange:NSMakeRange(glyph, 1) inTextContainer:container]))
        return NO;
    NSRange range = [layoutManager characterRangeForGlyphRange:NSMakeRange(glyph, 1) actualGlyphRange:NULL];
    id object = [self hyperObject];
    BOOL hasActions = NO;
    for (NSUInteger i = range.location; i < NSMaxRange(range); i++) {
        unsigned int start = 0;
        if ([[object queryHyperInterface:@protocol(HSHypertextLinkContainerAttributes)] hypertextLinkAtPosition:i inText:[[textView textStorage] string] startPosition:&start]
            || [[[object queryHyperInterface:@protocol(HSTextAttributes)] hyperText] attribute:NSLinkAttributeName atIndex:i effectiveRange:NULL])
            hasActions = YES;
    }
    return hasActions;
}

// Inactive, the text is spliced at the last cursor location of the stored
// text, which then scrolls to its end.
- (void)insertText:(id)aText
{
    NSTextView *textView = [[self view] documentView];
    if (textView && textView == [[[self view] window] firstResponder]) {
        [textView insertText:aText];
        _lastCursorLocation = [textView selectedRange].location;
        return;
    }
    id attributes = [[self node] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    NSAttributedString *text = [attributes hyperText];
    NSUInteger length = [text length];
    if (length < _lastCursorLocation)
        _lastCursorLocation = length;
    NSAttributedString *head = [text attributedSubstringFromRange:NSMakeRange(0, _lastCursorLocation)];
    NSMutableAttributedString *insertion = [[NSMutableAttributedString alloc] initWithString:aText attributes:[attributes hyperTextAttributes]];
    NSAttributedString *tail = [text attributedSubstringFromRange:NSMakeRange(_lastCursorLocation, length - _lastCursorLocation)];
    NSMutableAttributedString *newText = [[NSMutableAttributedString alloc] init];
    if (head)
        [newText appendAttributedString:head];
    if (insertion)
        [newText appendAttributedString:insertion];
    if (tail)
        [newText appendAttributedString:tail];
    _lastCursorLocation += [insertion length];
    [attributes setHyperText:newText];
    [attributes setSelectedRange:NSMakeRange(_lastCursorLocation, 0)];
    [attributes setVerticalScrollPosition:1];
    [insertion release];
    [newText release];
}

- (void)deactivate
{
    NSTextView *textView = [[self view] documentView];
    _lastCursorLocation = [textView selectedRange].location;
    _deactivating = YES;
    [self textViewShouldCompleteEditing:textView];
    _deactivating = NO;
    [_overlayView setDrawingDelegate:nil];
    [[[[self activeParentCanvasLayer] context] renderingView] stopRenderInteractiveSubview];
    [super deactivate];
    [self invalidateView];
}

// Activating must not move the text's scroll position, so the stored one is
// put back when the view changed it noticeably.
- (void)activateInCanvasLayer:(id)aLayer
{
    id renderingView = [[aLayer context] renderingView];
    [renderingView beginRenderInteractiveSubview];
    CGFloat scrollPosition = [[self hyperObject] verticalScrollPosition];
    [super activateInCanvasLayer:aLayer];
    // The original overwrote any text kept from an earlier activation.
    [_initialText release];
    _initialText = [[[self hyperObject] hyperText] copy];
    NSTextView *textView = [[self view] documentView];
    if ([_initialText length])
        [textView setTypingAttributes:[_initialText attributesAtIndex:0 effectiveRange:NULL]];
    if (_lastCursorLocation <= [[textView textStorage] length])
        [textView setSelectedRange:NSMakeRange(_lastCursorLocation, 0)];
    CGFloat newScrollPosition = [[self hyperObject] verticalScrollPosition];
    CGFloat newMagnitude = newScrollPosition != 0 ? fabs(newScrollPosition) : 1;
    CGFloat magnitude = scrollPosition != 0 ? fabs(scrollPosition) : 1;
    if (fabs(newScrollPosition - scrollPosition) > MAX(magnitude, newMagnitude) * 0.0005)
        [[self hyperObject] setVerticalScrollPosition:scrollPosition];
    [_overlayView setDrawingDelegate:self];
    [renderingView addSubview:_overlayView];
}

- (void)setupViewFrameInCanvasLayer:(id)aLayer
{
    [super setupViewFrameInCanvasLayer:aLayer];
    NSRect frame = NSIntegralRect([[self view] frame]);
    [[self view] setFrame:frame];
    [_overlayView setFrame:frame];
}

- (id)createView
{
    _overlayView = [[HSOverlayView alloc] initWithFrame:NSZeroRect];
    return [super createView];
}

- (void)documentUndoManagerDidRemoveAllActions:(id)aActions
{
    [[[self view] documentView] breakUndoCoalescing];
    [_undoManager removeAllActions];
}

- (void)documentUndoManagerWillRegisterUndo:(id)aUndo
{
}

- (void)editModeUndoHelper:(id)aHelper didFinish:(NSInteger)aFinish
{
}

- (void)didRegisterUndoInUndoManager:(id)aManager
{
    [[self undoHelper] duplicateAction];
}

- (void)willRegisterUndoInUndoManager:(id)aManager
{
}

- (id)undoHelper
{
    if (!_undoHelper) {
        id document = [self document];
        _undoHelper = [[HSEditModeUndoHelper alloc] initWithDocument:document documentUndoManager:[document undoManager] editModeUndoManager:[self undoManager] delegate:self];
    }
    return _undoHelper;
}

- (id)undoManagerForTextView:(id)aView
{
    return [self undoManager];
}

- (BOOL)textView:(id)aView shouldHandlePerformKeyEquivalentOutsideOfKeyDown:(id)aDown
{
    return [self textViewShouldProceedWithHandlingKeyEvent:aDown];
}

- (BOOL)textView:(id)aView shouldHandleRawKeyDownEvent:(id)aEvent
{
    return [self textViewShouldProceedWithHandlingKeyEvent:aEvent];
}

// Keys mapped to actions run those actions instead.
- (BOOL)textViewShouldProceedWithHandlingKeyEvent:(id)aEvent
{
    return ![[self activeItemContext] performActionsMappedToKeyEvent:aEvent];
}

// Sends the click actions when the mouse goes up over this object; a click
// still in progress is tracked first.
- (void)trackMouseWithMouseDownEvent:(id)aEvent andPerformActionIfNeededInContext:(id)aContext
{
    id context = [aContext context];
    id renderingView = [context renderingView];
    id hitTester = [context canvasHitTester];
    NSEvent *currentEvent = [[renderingView window] currentEvent];
    NSPoint point;
    if ([currentEvent type] == NSEventTypeLeftMouseUp) {
        point = [renderingView convertPoint:[currentEvent locationInWindow] fromView:nil];
    } else {
        HSMouseTracker *tracker = [[HSMouseTracker new] autorelease];
        HSTrackingLoop *loop = [HSTrackingLoop nonAutoscrollingTrackingLoopWithView:renderingView client:tracker];
        [loop runWithMouseDownEvent:aEvent];
        point = [loop lastMouseLocation];
    }
    id node = [hitTester hitTestNodeAtPoint:point];
    id cardObject = [[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if (node == cardObject && ![cardObject isNoClick] && ![cardObject isDropOffOnly])
        [aContext sendClickActionsForItemIfNeeded:self];
}

// Clicks not on a link run the object's click actions.
- (void)textView:(id)aView didPerformClick:(id)aClick
{
    if ([self isHandlingMouseEvent])
        return;
    id context = [self activeItemContext];
    NSPoint point = [aView convertPoint:[aClick locationInWindow] fromView:nil];
    [[self retain] autorelease];
    [self setHandlingMouseEvent:YES];
    BOOL handled = [self textViewDidPerformClick:aView atLocation:point inInteractiveContext:context];
    [self setHandlingMouseEvent:NO];
    if (!handled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HSTextViewDidPerformClickNotification object:[self hyperObject]];
        [self trackMouseWithMouseDownEvent:aClick andPerformActionIfNeededInContext:context];
    }
}

// An empty selection's shadowed caret leaves traces, so the view is redrawn.
// Inactive, the system view scrolls and the event is taken while it can
// scroll further that way.
- (BOOL)trackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    if ([self isActive]) {
        NSScrollView *view = [self view];
        NSView *textView = [view documentView];
        NSPoint point = [[view superview] convertPoint:[aEvent locationInWindow] fromView:nil];
        NSView *hitView = [view hitTest:point];
        if (hitView != textView) {
            [self setHandlingMouseEvent:YES];
            [hitView scrollWheel:aEvent];
            [self setHandlingMouseEvent:NO];
        } else {
            [textView scrollWheel:aEvent];
        }
        return YES;
    }
    NSScrollView *systemView = [[[self hyperObject] queryHyperInterface:@protocol(HSSystemObjectAttributes)] hyperSystemView];
    [systemView scrollWheel:aEvent];
    CGFloat deltaY = [aEvent deltaY];
    NSClipView *contentView = [systemView contentView];
    if (deltaY >= 0)
        return [contentView bounds].origin.y > 0;
    NSRect visible = [contentView bounds];
    return [[systemView documentView] bounds].size.height > NSMaxY(visible);
}

- (BOOL)wantsToTrackMouseWithScrollWheelEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSSystemTextViewAttributes)] isScrollable];
}

// Active, the hit part of the text view's scroll view gets the click;
// inactive, links are tried before the object's click actions.
- (void)trackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    if ([self isHandlingMouseEvent])
        return;
    if ([self isActive]) {
        id view = [self view];
        NSView *textView = [view documentView];
        NSPoint point = [[view superview] convertPoint:[aEvent locationInWindow] fromView:nil];
        NSView *hitView = [view hitTest:point];
        if (hitView == textView) {
            [textView mouseDown:aEvent];
        } else if (hitView == [view verticalScroller]) {
            [view willStartTrackingScroller:[view verticalScroller]];
            [hitView mouseDown:aEvent];
            [view didFinishTrackingScroller:[view verticalScroller]];
        } else {
            [self setHandlingMouseEvent:YES];
            [hitView mouseDown:aEvent];
            [self setHandlingMouseEvent:NO];
        }
        return;
    }
    NSScrollView *systemView = [[[self hyperObject] queryHyperInterface:@protocol(HSSystemObjectAttributes)] hyperSystemView];
    NSTextView *textView = [systemView documentView];
    NSPoint point = [self HSInteractiveTextViewObject_locationOfEvent:aEvent inTextView:textView ofSystemView:systemView inInteractiveContext:aContext];
    [self setHandlingMouseEvent:YES];
    BOOL handled = [self textViewDidPerformClick:textView atLocation:point inInteractiveContext:aContext];
    [self setHandlingMouseEvent:NO];
    if (handled)
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:HSTextViewDidPerformClickNotification object:[self hyperObject]];
    [self trackMouseWithMouseDownEvent:aEvent andPerformActionIfNeededInContext:aContext];
}

- (BOOL)wantsToTrackMouseWithMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    id cardObject = [[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if ([cardObject isDraggable] || [cardObject isRotatable])
        return NO;
    return ![cardObject isResizable];
}

// Only a plain text with nothing to do on a click lets it through.
- (BOOL)wantsToPassThroughMouseDownEvent:(id)aEvent inInteractiveContext:(id)aContext
{
    id cardObject = [[self hyperObject] queryHyperInterface:@protocol(HSCardObjectAttributes)];
    HSActionEvent *clickEvent = [HSActionEvent actionEventOfType:kHSClickActionEventType];
    if ([[[[self hyperObject] actor] hyperActionsForEvent:clickEvent] count])
        return NO;
    if ([[self textViewAttributes] isSelectable] || [[self textViewAttributes] hasVerticalScroller])
        return NO;
    if ([cardObject isDraggable] || [cardObject isResizable])
        return NO;
    return ![cardObject isRotatable];
}

- (void)textDidEndEditing:(id)aEditing
{
    [self textViewShouldCompleteEditing:nil];
}

- (void)textDidChange:(id)aChange
{
    [self updateHyperObjectWithVisualText];
}

// Without an undo helper while deactivating, the change from the text at
// activation is registered as one undoable change: the initial text is put
// back silently and the edited text then set again with undo enabled.
- (void)updateHyperObjectWithVisualText
{
    NSTextView *textView = [[self view] documentView];
    id object = [self hyperObject];
    BOOL registersUndo = !_undoHelper && _deactivating;
    if (!registersUndo)
        [self disableUndoRegistration];
    NSAttributedString *text = [[[textView textStorage] copy] autorelease];
    NSAttributedString *currentText = [object hyperText];
    NSDictionary *typingAttributes = nil;
    if ([text length] == 0 && [currentText length] != 0)
        typingAttributes = [currentText attributesAtIndex:0 effectiveRange:NULL];
    BOOL skipsUnchangedText = YES;
    if (registersUndo && ![_initialText isExtraEqualToAttributedString:text]) {
        [self disableUndoRegistration];
        [self updateHyperObjectWithText:_initialText];
        [self enableUndoRegistration];
        [_initialText release];
        _initialText = nil;
        skipsUnchangedText = NO;
    }
    if (![currentText isExtraEqualToAttributedString:text] || !skipsUnchangedText)
        [self updateHyperObjectWithText:text];
    if (!registersUndo)
        [self enableUndoRegistration];
    [object setBackgroundColor:[textView backgroundColor]];
    [object setVerticalScrollPosition:[(id)textView hyperScrollPosition]];
    if (typingAttributes)
        [textView setTypingAttributes:typingAttributes];
}

// An emptied text keeps the typing attributes.
- (void)updateHyperObjectWithText:(id)aText
{
    id object = [self hyperObject];
    NSDictionary *typingAttributes = [[[[self view] documentView] typingAttributes] retain];
    [object setHyperText:aText];
    if ([aText length] == 0)
        [object applyHyperTextAttributesDictionary:typingAttributes];
    [typingAttributes release];
}

// The text cursor over the text, the context's default cursor elsewhere.
- (id)defaultCursorAtPoint:(NSPoint)aPoint inCanvasLayer:(id)aLayer
{
    NSRect frame = [[[self node] queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
    NSPoint origin = [[[aLayer context] renderingView] convertPointFromUserSpaceToViewSpace:frame.origin];
    NSRect textFrame;
    if ([self view]) {
        textFrame = [[[self view] documentView] frame];
    } else {
        textFrame = [[[[[self hyperObject] queryHyperInterface:@protocol(HSSystemViewAttribute)] hyperSystemView] documentView] frame];
        id renderingView = [[aLayer context] renderingView];
        if ([renderingView isKindOfClass:[HSCardView class]]) {
            CGFloat zoomFactor = [(HSCardView *)renderingView zoomFactor];
            textFrame.size.width *= zoomFactor;
            textFrame.size.height *= zoomFactor;
        }
    }
    if (NSPointInRect(NSMakePoint(aPoint.x - origin.x, aPoint.y - origin.y), textFrame))
        return [HSCursor textCursor];
    id context = [aLayer queryHyperInterface:@protocol(HSInteractiveCanvasContext)];
    if (context)
        return [context defaultInteractiveModeCursor];
    return [HSCursor defaultCursor];
}

- (id)undoManager
{
    if (!_undoManager) {
        _undoManager = [[HSRunTimeEditorUndoManager alloc] init];
        [_undoManager setDelegate:self];
    }
    return _undoManager;
}

- (void)enableUndoRegistration
{
    [[[self document] undoManager] enableUndoRegistration];
}

- (void)disableUndoRegistration
{
    [[[self document] undoManager] disableUndoRegistration];
}

- (id)document
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSUserObjectSupport)] document];
}

- (void)awakeInPlayer
{
    _lastCursorLocation = 0;
}

- (void)invalidateView
{
    [super invalidateView];
    [_undoManager release];
    _undoManager = nil;
    [_overlayView release];
    _overlayView = nil;
}

- (void)willDisposeView:(id)aView
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:NSViewBoundsDidChangeNotification object:[aView hyperContentView]];
    [center removeObserver:self name:@"HSScrollViewDidStartScrollingNotification" object:aView];
    [center removeObserver:self name:@"HSScrollViewDidEndScrollingNotification" object:aView];
    [center removeObserver:self name:@"HSScrollWheelDidStartScrollingNotification" object:aView];
    [center removeObserver:self name:@"HSScrollWheelDidEndScrollingNotification" object:aView];
    id renderingView = [[[self activeParentCanvasLayer] context] renderingView];
    if ([renderingView isKindOfClass:[HSCardView class]])
        [center removeObserver:self name:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:renderingView];
    [[aView documentView] setDelegate:nil];
    [super willDisposeView:aView];
}

- (void)setupView:(id)aView
{
    NSTextView *textView = [aView documentView];
    [textView setAllowsUndo:YES];
    [textView setUsesFindPanel:YES];
    [aView setDrawsBackground:NO];
    [textView setDrawsBackground:NO];
    [textView setDelegate:self];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(textViewDidScrolled:) name:NSViewBoundsDidChangeNotification object:[aView hyperContentView]];
    [center addObserver:self selector:@selector(textViewDidStartScrolling:) name:@"HSScrollViewDidStartScrollingNotification" object:aView];
    [center addObserver:self selector:@selector(textViewDidEndScrolling:) name:@"HSScrollViewDidEndScrollingNotification" object:aView];
    [center addObserver:self selector:@selector(textViewDidStartScrolling:) name:@"HSScrollWheelDidStartScrollingNotification" object:aView];
    [center addObserver:self selector:@selector(textViewDidEndScrolling:) name:@"HSScrollWheelDidEndScrollingNotification" object:aView];
    id renderingView = [[[self activeParentCanvasLayer] context] renderingView];
    if ([renderingView isKindOfClass:[HSCardView class]]) {
        [center addObserver:self selector:@selector(handleRenderingViewDidChangeUserSpaceToViewSpaceTransformNotification:) name:HSViewDidChangeUserSpaceToViewSpaceTransformNotification object:renderingView];
        [self updateZoomFactor];
    }
}

- (void)handleRenderingViewDidChangeUserSpaceToViewSpaceTransformNotification:(id)aNotification
{
    [self updateZoomFactor];
}

// The text view draws at the card view's zoom.
- (void)updateZoomFactor
{
    id renderingView = [[[self activeParentCanvasLayer] context] renderingView];
    id textView = [[self view] documentView];
    if ([renderingView isKindOfClass:[HSCardView class]] && [textView isKindOfClass:[HSNonOpaqueTextView class]]) {
        CGFloat zoomFactor = [(HSCardView *)renderingView zoomFactor];
        [(HSNonOpaqueTextView *)textView setScaleFactor:NSMakeSize(zoomFactor, zoomFactor)];
    }
}

- (void)textViewDidEndScrolling:(id)aScrolling
{
    [[[self hyperObject] attributeObservingController] endContinuousChangeOfAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute)];
}

- (void)textViewDidStartScrolling:(id)aScrolling
{
    [[[self hyperObject] attributeObservingController] beginContinuousChangeOfAttribute:@protocol(HSSystemTextViewVerticalScrollPositionAttribute)];
}

- (void)textViewDidScrolled:(id)aScrolled
{
    NSTextView *textView = [[self view] documentView];
    id object = [self hyperObject];
    NSRange selection = [textView selectedRange];
    [object setVerticalScrollPosition:[(id)textView hyperScrollPosition]];
    [object setSelectedRange:selection];
}

- (BOOL)objectCanBeActivated
{
    BOOL canBeActivated = [super objectCanBeActivated];
    id attributes = [self textViewAttributes];
    BOOL selectable = [attributes isSelectable];
    BOOL editable = [attributes isEditable];
    BOOL scrolls = [attributes hasVerticalScroller];
    return canBeActivated && (editable || selectable || scrolls);
}

- (id)textViewAttributes
{
    return [[self hyperObject] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_overlayView release];
    [_initialText release];
    [_undoManager autorelease];
    [_undoHelper release];
    [super dealloc];
}

- (id)initWithNode:(id)aNode
{
    if (![aNode implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
        [self release];
        return nil;
    }
    return [super initWithNode:aNode];
}

@end
