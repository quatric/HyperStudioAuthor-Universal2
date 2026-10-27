#import "HSPlayerCardView.h"
#import "HSPlayerView.h"
#import "HSCursorSynchronizer.h"
#import "HSNode.h"
#import "HSPasteboardDataProvider.h"
#import "HSUserObjectInPlayerPreviewView.h"
#import "HSSemiTransparentImageRep.h"
#import "HSPlaybackContext.h"
#import "HSCanvasHitTester.h"
#import "HSProtocolIdentifier.h"
#import "HSPlayerRootCanvasLayer.h"
#import "NSEMutableProtocolSet.h"

// The card view of the player: interactive objects only while the card is
// presented interactively, the card clipped to its (optionally rounded)
// bounds, dragging objects out, and the stack's protected image drawn in
// place of the card when printing.
@implementation HSPlayerCardView

+ (id)visualizationProtocol
{
    return @protocol(HSPlayerVisualization);
}

// Objects scaled by a gesture recache their images when it ends.
- (void)endGestureWithEvent:(id)aEvent
{
    [[_nodeForGesture attributeObservingController] endContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSWidthAttribute), @protocol(HSHeightAttribute), @protocol(HSWidthScaleAttribute), @protocol(HSHeightScaleAttribute), @protocol(HSHorizontalScaleAttribute), @protocol(HSVerticalScaleAttribute), nil]];
    if ([_gestureBeingHandled isEqual:@"zoom"] || ![[self class] isEqualTo:[HSPlayerCardView class]])
        [[_nodeForGesture queryHyperInterface:@protocol(HSImageCacheAttributes)] forceRecacheIfNeededForGroupObjectsOnly:NO];
    [_nodeForGesture release];
    _nodeForGesture = nil;
    [super endGestureWithEvent:aEvent];
}

// A resizable or rotatable object caching its image changes continuously
// while the gesture goes on.
- (void)beginGestureWithEvent:(id)aEvent
{
    [super beginGestureWithEvent:aEvent];
    NSPoint point = [self convertPoint:[aEvent locationInWindow] fromView:nil];
    id node = [[self canvasHitTester] hitTestNodeAtPoint:point];
    id cardObjectAttributes = [node queryHyperInterface:@protocol(HSCardObjectAttributes)];
    if ([[node queryHyperInterface:@protocol(HSImageCacheAttributes)] isEnabledCacheImage]
        && ([cardObjectAttributes isResizable] || [cardObjectAttributes isRotatable]))
        _nodeForGesture = [node retain];
    [[_nodeForGesture attributeObservingController] beginContinuousChangeOfAttributeSet:[NSEProtocolSet protocolSetWithProtocols:@protocol(HSWidthAttribute), @protocol(HSHeightAttribute), @protocol(HSWidthScaleAttribute), @protocol(HSHeightScaleAttribute), @protocol(HSHorizontalScaleAttribute), @protocol(HSVerticalScaleAttribute), nil]];
}

- (void)invalidateCursor
{
    if ([self userObject])
        [super updateCursor];
    else
        [(HSCursor *)[HSCursor defaultCursor] set];
}

- (void)changeRoundsCardCorners:(BOOL)aCorners
{
    _roundsCardCorners = aCorners;
}

- (void)setRoundsCardCorners:(BOOL)aCorners
{
    if (_roundsCardCorners != aCorners)
        [self changeRoundsCardCorners:aCorners];
}

- (BOOL)roundsCardCorners
{
    return _roundsCardCorners;
}

- (void)clearQuartzSurfaceRect:(NSRect)aRect
{
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextSaveGState(context);
    [self HSPlayerCardView_clipToCardBounds];
    CGContextClearRect(context, NSRectToCGRect(aRect));
    CGContextRestoreGState(context);
}

- (void)drawQuartzSurfaceRect:(NSRect)aRect
{
    [self preDrawContentRect:aRect];
    if (![self isOpenGLSurfaceDisplayed])
        [self drawQuartzRect:aRect];
}

- (void)drawViewLayerContentRect:(NSRect)aRect
{
    [self HSPlayerCardView_clipToCardBounds];
    [super drawViewLayerContentRect:aRect];
}

- (void)HSPlayerCardView_clipToCardBounds
{
    NSSize cardSize = [self cardSize];
    if (NSEqualSizes(cardSize, NSSizeFromCGSize(CGSizeZero)))
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    CGContextBeginPath(context);
    CGContextSaveGState(context);
    CGContextConcatCTM(context, [self userSpaceToViewSpaceCGAffineTransform]);
    [self addCardRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, cardSize.width, cardSize.height) toContext:context];
    CGContextRestoreGState(context);
    CGContextClip(context);
}

- (void)addCardRect:(NSRect)aRect toContext:(struct CGContext *)aContext
{
    if (![self roundsCardCorners])
        CGContextAddRect(aContext, NSRectToCGRect(aRect));
    else
        CGContextAddPath(aContext, [self roundedRectClipPath:aRect]);
}

- (CGFloat)HSPlayerInEditorCardView_cornerRoundingRadiusForCardSize:(NSSize)aSize
{
    return fminf(16.0f, fminf(aSize.width, aSize.height) * 0.5f);
}

- (BOOL)acceptsFirstResponder
{
    return [[[self rootCanvasLayer] interactiveObjectsLayer] resignFirstResponder];
}

- (void)enableInteractivity
{
    [[[self rootCanvasLayer] interactiveObjectsLayer] setDisabled:NO];
}

- (void)disableInteractivity
{
    [[[self rootCanvasLayer] interactiveObjectsLayer] setDisabled:YES];
}

- (void)deactivate
{
    [super deactivate];
    [self disableInteractivity];
}

- (void)activate
{
    [super activate];
    [self enableInteractivity];
}

- (void)deactivateActiveTextField
{
    [[[self rootCanvasLayer] interactiveObjectsLayer] setActiveItem:nil];
}

- (id)activeTextField
{
    return [[[self rootCanvasLayer] interactiveObjectsLayer] activeTextField];
}

- (void)saveEditingState
{
    [[[self rootCanvasLayer] interactiveObjectsLayer] saveEditingState];
}

- (NSRange)selectedRangeInNode:(id)aNode
{
    return [[[self rootCanvasLayer] interactiveObjectsLayer] selectedRangeInNode:aNode];
}

- (void)selectRange:(NSRange)aRange inNode:(id)aNode
{
    [[[self rootCanvasLayer] interactiveObjectsLayer] selectRange:aRange inNode:aNode];
}

- (void)doCommandBySelector:(SEL)aSelector forNode:(id)aNode
{
    [[[self rootCanvasLayer] interactiveObjectsLayer] doCommandBySelector:aSelector forNode:aNode];
}

- (void)insertText:(id)aText toNode:(id)aNode
{
    [[[self rootCanvasLayer] interactiveObjectsLayer] insertText:aText toNode:aNode];
}

- (void)draggedImage:(id)aImage endedAt:(NSPoint)aAt operation:(NSUInteger)aOperation
{
    if (_draggingPasteboardDataProvider) {
        [_draggingPasteboardDataProvider release];
        _draggingPasteboardDataProvider = nil;
    }
}

- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)aLocal
{
    return !aLocal;
}

// Drags copies of the nodes, unless the mouse goes up (or a modifier
// changes) before it moves. The image is the copies drawn half transparent,
// placed where the objects are on the card.
- (BOOL)startDragWithNodes:(id)aNodes event:(id)aEvent
{
    NSEvent *nextEvent = [[self window] nextEventMatchingMask:NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged | NSEventMaskFlagsChanged];
    if ([nextEvent type] == NSEventTypeLeftMouseUp || [nextEvent type] == NSEventTypeFlagsChanged)
        return NO;
    NSPoint point = [self convertPoint:[aEvent locationInWindow] fromView:nil];
    NSMutableArray *copies = [NSMutableArray array];
    NSEnumerator *nodes = [aNodes objectEnumerator];
    id node;
    while ((node = [nodes nextObject])) {
        if (![node isKindOfClass:[HSNode class]])
            continue;
        [copies addObject:[[node localCopyIncludingNodeUnits:NO] autorelease]];
        [[copies lastObject] setSupport:[node queryHyperInterface:@protocol(HSNodeSupport)]];
    }
    [copies sortByHyperOrder];
    NSMutableArray *representations = [NSMutableArray array];
    NSMutableSet *mediaUIDs = [NSMutableSet set];
    NSEnumerator *copiesEnumerator = [copies objectEnumerator];
    id copy;
    while ((copy = [copiesEnumerator nextObject])) {
        [representations addObject:[copy fullDictionaryRepresentation]];
        NSSet *uids = [[copy queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs];
        if (uids)
            [mediaUIDs unionSet:uids];
    }
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSPasteboardNameDrag];
    [_draggingPasteboardDataProvider release];
    _draggingPasteboardDataProvider = [[HSPasteboardDataProvider alloc] initWithObjects:representations UIDs:mediaUIDs dragName:[[[copies lastObject] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName]];
    [_draggingPasteboardDataProvider declareTypesForPasteboard:pasteboard];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSImage *image = nil;
    HSUserObjectInPlayerPreviewView *preview = [[[HSUserObjectInPlayerPreviewView alloc] initWithFrame:NSZeroRect] autorelease];
    if (preview) {
        [preview setBackgroundColor:[NSColor clearColor]];
        if ([copies count] == 1) {
            [preview addUserObject:[copies lastObject]];
        } else if ([copies count] > 1) {
            NSEnumerator *previewCopies = [copies objectEnumerator];
            while ((copy = [previewCopies nextObject]))
                [preview addUserObject:copy];
        }
        NSRect bounds = [preview renderersBoundingRect];
        if (!NSIsEmptyRect(bounds)) {
            NSRect imageRect = NSIntegralRect(bounds);
            NSData *offsets = [preview offsetsFromPoint:point];
            if (offsets) {
                [pasteboard addTypes:[NSArray arrayWithObject:@"HSObjectsOriginOffsetsPasteboardType"] owner:nil];
                [pasteboard setData:offsets forType:@"HSObjectsOriginOffsetsPasteboardType"];
            }
            NSPoint cardPoint = [self convertPointFromDragHostToCard:point];
            point.x += imageRect.origin.x - cardPoint.x;
            CGFloat imageY = imageRect.origin.y;
            if ([self isFlipped])
                imageY += imageRect.size.height;
            [preview setFrameSize:imageRect.size];
            HSSemiTransparentImageRep *representation = [[[HSSemiTransparentImageRep alloc] initWithImage:[NSImage hyperImageWithView:preview] opacity:0.5f] autorelease];
            point.y += imageY - cardPoint.y;
            if (representation) {
                image = [[NSImage alloc] initWithSize:imageRect.size];
                [image addRepresentation:representation];
            }
        }
    }
    [pool release];
    [copies makeObjectsPerformSelector:@selector(setSupport:) withObject:nil];
    [self dragImage:image at:point offset:NSZeroSize event:aEvent pasteboard:pasteboard source:self slideBack:YES];
    [image release];
    return YES;
}

- (NSPoint)convertPointFromDragHostToCard:(NSPoint)aCard
{
    return [self convertPointFromViewSpaceToUserSpace:aCard];
}

// Outside a scroll view and presentation mode, scrolling moves the card
// within its superview, short of leaving a gap at an edge.
- (void)scrollWheel:(id)aWheel
{
    if ([self enclosingScrollView] || [[[_playerView stack] document] isInPresentationMode]) {
        [super scrollWheel:aWheel];
        return;
    }
    if (!_playerView || [_playerView isFullScreen])
        return;
    NSView *superview = [self superview];
    if (!superview)
        return;
    NSRect frame = [self frame];
    NSRect bounds = [superview bounds];
    frame.origin.x -= [aWheel deltaX];
    if (frame.origin.x > bounds.origin.x)
        frame.origin.x = bounds.origin.x;
    else if (bounds.origin.x + bounds.size.width - frame.size.width > frame.origin.x)
        frame.origin.x = bounds.origin.x + bounds.size.width - frame.size.width;
    frame.origin.y -= [aWheel deltaY];
    if (frame.origin.y > bounds.origin.y)
        frame.origin.y = bounds.origin.y;
    else if (bounds.origin.y + bounds.size.height - frame.size.height > frame.origin.y)
        frame.origin.y = bounds.origin.y + bounds.size.height - frame.size.height;
    [self setFrameOrigin:frame.origin];
}

// In presentation mode a right click goes back a card.
- (void)rightMouseDown:(id)aDown
{
    id document = [[_playerView stack] document];
    if ([document isInPresentationMode] && [[document navigationController] canGoToPreviousCard]) {
        [[document navigationController] goToPreviousCard:nil];
        return;
    }
    [super rightMouseDown:aDown];
}

- (void)mouseDown:(id)aDown
{
    if (![[self playerView] handleMouseDownEvent:aDown])
        [super mouseDown:aDown];
}

// Shape buttons show their borders in the player, unless the stack is
// protected. The change is not undoable.
- (void)updateShapeButtonsShowBorder:(BOOL)aBorder
{
    _buttonBorderVisibilityFlag = aBorder;
    if ([[[self card] document] isStackProtected])
        return;
    [[[self card] undoManager] disableUndoRegistration];
    NSEnumerator *objects = [[self card] hyperEnumerator];
    id object;
    while ((object = [objects nextObject])) {
        id button = [object queryHyperInterface:@protocol(HSButtonObjectAttributes)];
        if (!button)
            continue;
        id background = [[button background] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
        if (background)
            [background setShowsBorderInPlayer:aBorder];
    }
    [[[self card] undoManager] enableUndoRegistration];
}

- (void)stackPasswordDidChange:(id)aChange
{
    BOOL showsBorder = ![[[self card] document] isStackProtected] && _buttonBorderVisibilityFlag;
    [self updateShapeButtonsShowBorder:showsBorder];
}

// Off screen the card's image is drawn, fitted and centered on white.
- (void)drawQuartzRect:(NSRect)aRect
{
    BOOL toScreen = [NSGraphicsContext currentContextDrawingToScreen];
    [NSGraphicsContext saveGraphicsState];
    if (toScreen) {
        [self drawViewLayerContentRect:aRect];
        [NSGraphicsContext restoreGraphicsState];
        if (![self hasWindowLayer])
            [self postDrawContentRect:aRect];
        return;
    }
    [[NSColor whiteColor] set];
    NSRectFill(aRect);
    NSImage *image = [[NSImage alloc] initWithData:[[[self card] image] TIFFRepresentation]];
    if (image) {
        if ([self isFlipped])
            [image setFlipped:YES];
        NSSize size = [image size];
        CGFloat scale = aRect.size.width < size.width ? aRect.size.width / size.width : 1.0f;
        if (size.height * scale > aRect.size.height)
            scale = aRect.size.height / size.height;
        NSRect destination;
        destination.size.width = size.width * scale;
        destination.size.height = size.height * scale;
        destination.origin.x = aRect.origin.x + (aRect.size.width - destination.size.width) * 0.5f;
        destination.origin.y = aRect.origin.y + (aRect.size.height - destination.size.height) * 0.5f;
        [image drawInRect:destination fromRect:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, size.width, size.height) operation:NSCompositingOperationSourceOver fraction:1.0f];
        [image release];
    }
    [NSGraphicsContext restoreGraphicsState];
}

- (void)cardSizeDidChange:(id)aChange
{
    [self setNeedsDisplayOpenGLSurface:YES];
    [self setNeedsDisplay:YES];
}

- (void)setCard:(id)aCard
{
    if ([self card] != aCard) {
        [super setCard:aCard];
        [self adjustCardFrame];
    }
}

- (void)adjustCardFrame
{
    [[self playerView] adjustCardViewSize];
    [[self playerView] centrateCardView];
}

- (void)unregisterObservingUserObjectAttributesChange
{
    [super unregisterObservingUserObjectAttributesChange];
    if (_observedStackAttributes) {
        [[_observedStackAttributes queryHyperInterface:@protocol(HSAttributeObserving)] removeObserver:self selector:@selector(stackPasswordDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackPasswordAttribute)];
        [_observedStackAttributes release];
        _observedStackAttributes = nil;
    }
}

- (void)registerObservingUserObjectAttributesChange
{
    [super registerObservingUserObjectAttributesChange];
    _observedStackAttributes = [[[[self userObject] queryHyperInterface:@protocol(HSUserObjectSupport)] stack] retain];
    if (_observedStackAttributes)
        [[_observedStackAttributes queryHyperInterface:@protocol(HSAttributeObserving)] addObserver:self selector:@selector(stackPasswordDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackPasswordAttribute) withPriority:-0.75f];
}

- (void)setUserObject:(id)aObject
{
    if ([self userObject] == aObject)
        return;
    [[[self rootCanvasLayer] interactiveObjectsLayer] setActiveItem:nil];
    [super setUserObject:aObject];
    [self setNeedsDisplay:YES];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(invalidateCursor) object:nil];
    [self performSelector:@selector(invalidateCursor) withObject:nil afterDelay:0];
}

- (void)presentationContextDidChange
{
    [self refreshCanvasLayersIfNeededWithWindow:[self window]];
}

- (void)viewWillMoveToWindow:(id)aWindow
{
    [super viewWillMoveToWindow:aWindow];
    if (!aWindow)
        [self refreshCanvasLayersIfNeededWithWindow:nil];
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if ([self window])
        [self refreshCanvasLayersIfNeededWithWindow:[self window]];
}

// Interactive objects run only in a window and an interactive presentation.
- (void)refreshCanvasLayersIfNeededWithWindow:(id)aWindow
{
    NSSet *identifiers = nil;
    if (aWindow && [[self presentationContext] isInteractive])
        identifiers = [NSSet setWithObject:HSInteractivePlayerCanvasLayerIdentifier];
    [[self rootCanvasLayer] setEnabledSublayerIdentifiers:identifiers];
}

// Key commands go to the window controller first.
- (void)insertNewline:(id)aNewline
{
    id controller = [[self window] windowController];
    BOOL controllerHandles = [controller respondsToSelector:@selector(insertNewline:)];
    if (controllerHandles)
        [controller performSelector:@selector(insertNewline:) withObject:aNewline];
    if ([self handleKeyEventSelector:_cmd] || controllerHandles)
        [self didHandleKeyEvent];
}

- (void)insertBacktab:(id)aBacktab
{
    id controller = [[self window] windowController];
    BOOL controllerHandles = [controller respondsToSelector:@selector(insertBacktab:)];
    if (controllerHandles)
        [controller performSelector:@selector(insertBacktab:) withObject:aBacktab];
    if ([self handleKeyEventSelector:_cmd] || controllerHandles)
        [self didHandleKeyEvent];
}

- (void)insertTab:(id)aTab
{
    id controller = [[self window] windowController];
    BOOL controllerHandles = [controller respondsToSelector:@selector(insertTab:)];
    if (controllerHandles)
        [controller performSelector:@selector(insertTab:) withObject:aTab];
    if ([self handleKeyEventSelector:_cmd] || controllerHandles)
        [self didHandleKeyEvent];
}

- (id)presentationContext
{
    if (!_presentationContext)
        _presentationContext = [[HSPlaybackContext presentationContext] retain];
    return _presentationContext;
}

- (id)userObjectChildrenEnumerator
{
    return [[[self card] hyperChildren] objectEnumerator];
}

- (id)createCanvasHitTester
{
    return [[HSCanvasHitTester alloc] initWithHitTestingInterface:[HSProtocolIdentifier identifierForProtocol:@protocol(HSUserObjectInteractiveHitTesting)]];
}

- (id)createRootCanvasLayer
{
    return [[HSPlayerRootCanvasLayer alloc] init];
}

- (BOOL)isOpenGLSurfaceOpaque
{
    return YES;
}

- (void)setPlayerView:(id)aView
{
    _playerView = aView;
}

- (id)playerView
{
    return _playerView;
}

- (void)dealloc
{
    // The original sent the provider dealloc instead of release.
    [_draggingPasteboardDataProvider release];
    [_observedStackAttributes release];
    [_nodeForGesture release];
    [super dealloc];
}

- (id)onceInit
{
    return self;
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self && !_inited) {
        _inited = YES;
        self = [self onceInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self && !_inited) {
        _inited = YES;
        self = [self onceInit];
    }
    return self;
}

// Only at the actual size (within a small tolerance).
- (BOOL)canActivateNonScalableObjects
{
    float zoom = (float)[self zoomFactor];
    float scale = (zoom != 0.0f) ? fabsf(zoom) : 1.0f;
    if (scale <= 1.0f)
        scale = 1.0f;
    return fabsf(1.0f - zoom) <= scale * 0.0005f;
}

- (void)handleFluidSwipe:(id)aSwipe
{
    if (![[self playerView] tryToPerform:_cmd with:aSwipe])
        [[self nextResponder] tryToPerform:_cmd with:aSwipe];
}

// A clip path for the card rect with rounded corners, nil when the card does
// not round its corners.
- (CGPathRef)roundedRectClipPath:(NSRect)aRect
{
    if (![self roundsCardCorners])
        return NULL;
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat radius = [self HSPlayerInEditorCardView_cornerRoundingRadiusForCardSize:[self cardSize]];
    CGFloat minX = NSMinX(aRect), minY = NSMinY(aRect), maxX = NSMaxX(aRect), maxY = NSMaxY(aRect);
    CGPathMoveToPoint(path, NULL, minX, minY + radius);
    CGPathAddArcToPoint(path, NULL, minX, minY, minX + radius, minY, radius);
    CGPathAddLineToPoint(path, NULL, maxX - radius, minY);
    CGPathAddArcToPoint(path, NULL, maxX, minY, maxX, minY + radius, radius);
    CGPathAddLineToPoint(path, NULL, maxX, maxY - radius);
    CGPathAddArcToPoint(path, NULL, maxX, maxY, maxX - radius, maxY, radius);
    CGPathAddLineToPoint(path, NULL, minX + radius, maxY);
    CGPathAddArcToPoint(path, NULL, minX, maxY, minX, maxY - radius, radius);
    CGPathCloseSubpath(path);
    return (CGPathRef)[(id)path autorelease];
}

@end
