#import "BTPencilTool.h"
#import "NSView+BTMouseTracking.h"
#import "NSApplication+BTEvents.h"
#import "NSEvent+BTLocation.h"
#import "BTPointer.h"

/* Pencil strokes are recorded for consumers (e.g. brush touch storage) and
   replayed from point providers. */
@interface NSObject (BTPencilStrokes)
- (void)addPencilStrokeFromPoint:(CGPoint)aPoint toPoint:(CGPoint)aPoint2;
- (NSUInteger)numberOfPencilStrokes;
- (void)getStartPoint:(CGPoint *)aStart endtPoint:(CGPoint *)aEnd forPencilStrokeAtIndex:(NSUInteger)aIndex;
@end

/* The pencil draws one pixel wide lines in the stroke color, or in the
   alternate stroke color while its option is held (or with a tablet eraser).
   Holding the color picking option picks the stroke color from the image
   instead; letting go of it in a drag starts drawing. */
@implementation BTPencilTool

/* The alternate color is used with its modifier option or the eraser end. */
static BOOL BTPencilToolUsesAlternateColor(BTPencilTool *self, NSUInteger aFlags, NSEvent *aEvent)
{
    if (BTModifierFlagsMatchOption(aFlags, self->_alternateColorOption))
        return YES;
    if (aEvent != nil)
        return [aEvent BT_pointingDeviceType] == 3;
    return [NSApp BT_effectivePointingDeviceType] == 3;
}

/* Pixel centers for both ends; horizontal, vertical and single point strokes
   are extended half a pixel at each end along their axis so the end pixels
   are covered. */
static void BTPencilToolAdjustEnds(CGPoint *aStart, CGPoint *aEnd)
{
    if (aStart->x == aEnd->x) {
        if (aStart->y == aEnd->y) {
            aEnd->x += 0.5;
            aStart->x -= 0.5;
        } else if (aEnd->y >= aStart->y) {
            aEnd->y += 0.5;
            aStart->y -= 0.5;
        } else {
            aEnd->y -= 0.5;
            aStart->y += 0.5;
        }
    } else if (aStart->y == aEnd->y) {
        if (aEnd->x > aStart->x) {
            aEnd->x += 0.5;
            aStart->x -= 0.5;
        } else {
            aEnd->x -= 0.5;
            aStart->x += 0.5;
        }
    }
}

- (void)trackingView:(id)aView didAutoscroll:(BOOL)aAutoscroll withMouseEvent:(id)aEvent
{
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] trackingView:aView didAutoscroll:aAutoscroll withMouseEvent:aEvent];
}

- (BOOL)trackingView:(id)aView shouldAutoscrollWithMouseEvent:(id)aEvent
{
    id tracker;
    if (_view == aView && (tracker = [_delegate mouseTrackingDelegateForTool:self]) != nil)
        return [tracker trackingView:aView shouldAutoscrollWithMouseEvent:aEvent];
    return YES;
}

- (void)haltWithMouseUp:(id)aEvent inView:(id)aView
{
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] haltWithMouseUp:aEvent inView:aView];
}

/* Releasing the color picking option during a drag switches to drawing. */
- (void)trackFlagsChanged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aEvent inView:aView];
    if (!_isColorPicking)
        return;
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _isUsingAlternateStrokeColor = BTPencilToolUsesAlternateColor(self, flags, nil);
    if (BTModifierFlagsMatchOption(flags, _colorPickingOption))
        return;
    _isColorPicking = 0;
    _isDrawing = 1;
    [_delegate tool:self didFinalizeOutputForKey:@"alternateStrokeColor"];
    [_delegate tool:self didFinalizeOutputForKey:@"strokeColor"];
    [self BTPencilTool_beginDrawing];
}

- (void)trackMouseUp:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseUp:aEvent inView:aView];
    if (_isDrawing) {
        [self endWorkImageUndoGrouping];
        [_delegate toolDidEndChangingImageContinuously:self];
    } else {
        [_delegate tool:self didFinalizeOutputForKey:@"alternateStrokeColor"];
        [_delegate tool:self didFinalizeOutputForKey:@"strokeColor"];
    }
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _isUsingAlternateStrokeColor = BTPencilToolUsesAlternateColor(self, flags, aEvent);
    _isColorPicking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    _isTracking = 0;
}

- (void)trackMouseDragged:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDragged:aEvent inView:aView];
    NSPoint start = [self convertImagePointToViewPoint:_imageStartPoint];
    NSPoint p = [self eventLocationInView:aEvent];
    p = [self guideMovementFromPoint:start toPoint:p centeringOnDevicePixel:YES inMode:(char *)&_guidingMode withEvent:aEvent];
    p = [self convertViewPointToImagePoint:p];
    if (_isColorPicking) {
        if ([self BTPencilTool_pickColorAtPoint:p])
            _isColorPicked = 1;
    } else {
        [self BTPencilTool_drawLineToPoint:p withEvent:aEvent];
        _isStroked = 1;
    }
    _imageStartPoint = p;
}

/* Shift guides the drag along horizontals, verticals and diagonals. */
- (void)trackMouseDown:(id)aEvent inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDown:aEvent inView:aView];
    _isTracking = 1;
    _guidingMode = ([(NSEvent *)aEvent modifierFlags] & NSEventModifierFlagShift) ? 0xff : 0;
    CGPoint p = [self eventLocationInView:aEvent];
    [self snapPoint:&p asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:CGELineUndefined withEvent:aEvent options:nil];
    _imageStartPoint = [self convertViewPointToImagePoint:p];
    if (!_isColorPicking) {
        _isDrawing = 1;
        [self BTPencilTool_beginDrawing];
        [self BTPencilTool_drawLineToPoint:_imageStartPoint withEvent:aEvent];
        _isStroked = 1;
    }
}

- (void)BTPencilTool_beginDrawing
{
    if (_isUsingAlternateStrokeColor && _alternateStrokeColor != NULL)
        [(NSCursor *)[self doAlternateDrawCursor] set];
    else
        [(NSCursor *)[self doDrawCursor] set];
    [_delegate toolWillBeginChangingImageContinuously:self];
    [self beginWorkImageUndoGrouping];
}

/* Replays recorded strokes in the current color. */
- (void)drawWithPointProvider:(id)aProvider inContext:(struct CGContext *)aContext withBounds:(CGRect)aBounds
{
    CGEColorRef color = [self BTPencilTool_effectiveStrokeColor];
    if (color == NULL)
        return;
    NSUInteger count = [aProvider numberOfPencilStrokes];
    for (NSUInteger i = 0; i < count; i++) {
        CGPoint start, end;
        [aProvider getStartPoint:&start endtPoint:&end forPencilStrokeAtIndex:i];
        CGContextBeginPath(aContext);
        CGContextMoveToPoint(aContext, start.x, start.y);
        CGContextAddLineToPoint(aContext, end.x, end.y);
        if (CGEContextSetStrokeColorWithColor(aContext, NULL, aBounds, color)) {
            CGContextStrokePath(aContext);
        } else {
            CGContextSaveGState(aContext);
            CGEContextStrokePathWithColor(aContext, NULL, aBounds, color);
            CGContextRestoreGState(aContext);
        }
    }
}

/* Strokes from the last point to aPoint through pixel centers, in image
   points or (by default) so that the line is straight in window points. */
- (void)BTPencilTool_drawLineToPoint:(NSPoint)aPoint withEvent:(id)aEvent
{
    CGEColorRef color = [self BTPencilTool_effectiveStrokeColor];
    if (color == NULL)
        return;
    CGPoint start = _imageStartPoint, end = aPoint;
    if (_adjustsStrokeToMatchImagePoints) {
        start = CGPointMake(round(start.x - 0.5) + 0.5, round(start.y - 0.5) + 0.5);
        end = CGPointMake(round(end.x - 0.5) + 0.5, round(end.y - 0.5) + 0.5);
        BTPencilToolAdjustEnds(&start, &end);
    } else if (_adjustsStrokeToMatchWindowPoints) {
        CGPoint ws = [_view convertPoint:[self convertImagePointToViewPoint:start] toView:nil];
        CGPoint we = [_view convertPoint:[self convertImagePointToViewPoint:end] toView:nil];
        BTPencilToolAdjustEnds(&ws, &we);
        start = [self convertViewPointToImagePoint:[_view convertPoint:ws fromView:nil]];
        end = [self convertViewPointToImagePoint:[_view convertPoint:we fromView:nil]];
    }
    if (_strokeConsumers != nil)
        [self BTPencilTool_recordPencilStrokeFromPoint:start toPoint:end];

    id image = [self workImage];
    if (image == nil)
        return;
    CGRect imageRect = { CGPointZero, [image imageSize] };
    CGRect r = CGRectMake(MIN(start.x, end.x), MIN(start.y, end.y), fabs(end.x - start.x), fabs(end.y - start.y));
    r = CGRectIntersection(CGRectIntegral(CGRectInset(r, -0.55, -0.55)), imageRect);
    if (CGRectIsEmpty(r))
        return;
    [self preEditWorkImage:image inRect:r];
    [image beginCGEditing];
    CGContextRef context = [image imageCGContext];
    if (context != NULL) {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, start.x, start.y);
        CGContextAddLineToPoint(context, end.x, end.y);
        CGEContextStrokePathWithColor(context, NULL, imageRect, color);
    }
    [image endCGEditing];
    [self postEditWorkImageInRect:r];
}

- (void)BTPencilTool_recordPencilStrokeFromPoint:(CGPoint)aStart toPoint:(CGPoint)aEnd
{
    NSMapEnumerator e = NSEnumerateMapTable(_strokeConsumers);
    void *consumer = NULL;
    while (NSNextMapEnumeratorPair(&e, &consumer, NULL))
        [(id)consumer addPencilStrokeFromPoint:aStart toPoint:aEnd];
    NSEndMapTableEnumeration(&e);
}

- (struct CGEColor *)BTPencilTool_effectiveStrokeColor
{
    if (_isUsingAlternateStrokeColor && _alternateStrokeColor != NULL)
        return _alternateStrokeColor;
    return [self BTPencilTool_strokeColor];
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayers:(id)aLayers
{
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayer:(id)aLayer
{
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayers:(id)aLayers
{
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayer:(id)aLayer
{
}

- (id)activeFeedbackLayersForDrawing
{
    return [NSArray array];
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    return NO;
}

- (id)activeFeedbackLayers
{
    return [NSSet set];
}

- (void)drawRect:(NSRect)aRect
{
}

- (BOOL)flagsChanged:(id)aEvent
{
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    BOOL alternate = BTPencilToolUsesAlternateColor(self, flags, nil);
    BOOL picking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    if (alternate == (BOOL)_isUsingAlternateStrokeColor && picking == (BOOL)_isColorPicking)
        return NO;
    _isUsingAlternateStrokeColor = alternate;
    _isColorPicking = picking;
    [_delegate tool:self didUpdateCursorWithEvent:aEvent];
    return YES;
}

/* One undo action per click: picking, stroking, or both. */
- (BOOL)mouseDown:(id)aEvent
{
    BOOL result = [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:aEvent nextStage:@"BTDrawingToolStage"];
    if (![self isActive])
        return result;
    [self beginUndoAction];
    NSUInteger flags = [(NSEvent *)aEvent modifierFlags];
    _isUsingAlternateStrokeColor = BTPencilToolUsesAlternateColor(self, flags, aEvent);
    _isColorPicked = 0;
    _isStroked = 0;
    if (BTModifierFlagsMatchOption(flags, _colorPickingOption))
        _isColorPicked = [self BTPencilTool_pickColorAtPoint:[self eventLocationInImage:aEvent]];
    id upEvent = [_view BT_trackMouseWithEvent:aEvent tracker:self startDelay:0.0];
    NSString *name;
    if (_isStroked) {
        if (_isColorPicked)
            name = _isUsingAlternateStrokeColor ? @"Pick Alternate Color & Stroke" : @"Pick Color & Stroke";
        else
            name = _isUsingAlternateStrokeColor ? @"Alternate Stroke" : @"Stroke";
    } else if (_isColorPicked) {
        name = _isUsingAlternateStrokeColor ? @"Pick Alternate Color" : @"Pick Color";
    } else {
        name = nil;
    }
    [self endUndoActionWithName:name];
    [_delegate tool:self didFinalizeStage:@"BTDrawingToolStage" withEvent:upEvent nextStage:nil];
    if ([self isActive]) {
        _isDrawing = 0;
        [_delegate tool:self didUpdateCursorWithEvent:upEvent];
    }
    return YES;
}

- (BOOL)BTPencilTool_pickColorAtPoint:(NSPoint)aPoint
{
    id image = [self workImage];
    id color;
    if (image == nil || (color = (id)[image colorAtPoint:aPoint]) == nil)
        return NO;
    NSString *key = _isUsingAlternateStrokeColor ? @"alternateStrokeColor" : @"strokeColor";
    [_delegate tool:self willUpdateOutputForKey:key];
    if (_isUsingAlternateStrokeColor)
        [self setAlternateStrokeColor:color];
    else
        [self setStrokeColor:color];
    [_delegate tool:self didUpdateOutputForKey:key];
    return YES;
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    if (!_isDrawing && BTModifierFlagsMatchOption(aFlags, _colorPickingOption))
        return [self pickColorCursor];
    if (_alternateStrokeColor != NULL && BTPencilToolUsesAlternateColor(self, aFlags, nil))
        return [self willAlternateDrawCursor];
    return [self willDrawCursor];
}

- (BOOL)isTracking
{
    return _isTracking;
}

- (id)currentStage
{
    return _isDrawing ? @"BTDrawingToolStage" : @"BTWaitingToolStage";
}

- (void)performDeactivate
{
    if (_isTracking) {
        [_view BT_abortMouseTracking];
        _isTracking = 0;
    }
    _isDrawing = 0;
    [super performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    NSUInteger flags = [NSApp BT_effectiveModifierFlags];
    _isUsingAlternateStrokeColor = BTPencilToolUsesAlternateColor(self, flags, nil);
    _isColorPicking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    return YES;
}

/* Consumers are counted: each start needs a stop. */
- (void)stopRecordStrokesWithConsumer:(id)aConsumer
{
    if (_strokeConsumers == nil)
        return;
    NSUInteger count = (NSUInteger)NSMapGet(_strokeConsumers, aConsumer);
    if (count == 0)
        return;
    if (count == 1)
        NSMapRemove(_strokeConsumers, aConsumer);
    else
        NSMapInsert(_strokeConsumers, aConsumer, (void *)(count - 1));
}

- (void)startRecordStrokesWithConsumer:(id)aConsumer
{
    if (_strokeConsumers == nil) {
        _strokeConsumers = NSCreateMapTable(BTObjectPointerMapKeyCallBacks, NSIntegerMapValueCallBacks, 0);
        if (_strokeConsumers == nil)
            return;
    }
    NSUInteger count = (NSUInteger)NSMapGet(_strokeConsumers, aConsumer);
    NSMapInsert(_strokeConsumers, aConsumer, (void *)(count + 1));
}

- (id)allUndoCategories
{
    return [NSSet setWithObjects:@"BTToolWorkImageUndoCategory", @"BTStrokeColorUndoCategory", nil];
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"strokeColor", @"alternateStrokeColor", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"colorPickingOption", @"alternateColorOption", @"willDrawCursor",
            @"doDrawCursor", @"willAlternateDrawCursor", @"doAlternateDrawCursor", @"pickColorCursor", @"strokeColor",
            @"alternateStrokeColor", @"strokeAdjustment", nil];
}

- (id *)requiredImageProtocols
{
    static id protocols[3];
    protocols[0] = @protocol(BTCGImage);
    protocols[1] = @protocol(BTCGMutableImage);
    return protocols;
}

- (void)setStrokeAdjustment:(id)aAdjustment
{
    if (aAdjustment == nil) {
        _adjustsStrokeToMatchImagePoints = 0;
        _adjustsStrokeToMatchWindowPoints = 0;
    } else if ([aAdjustment isEqualToString:@"BTImagePointsStrokeAdjustment"]) {
        _adjustsStrokeToMatchImagePoints = 1;
        _adjustsStrokeToMatchWindowPoints = 0;
    } else if ([aAdjustment isEqualToString:@"BTWindowPointsStrokeAdjustment"]) {
        _adjustsStrokeToMatchImagePoints = 0;
        _adjustsStrokeToMatchWindowPoints = 1;
    }
}

- (id)strokeAdjustment
{
    if (_adjustsStrokeToMatchImagePoints)
        return @"BTImagePointsStrokeAdjustment";
    return _adjustsStrokeToMatchWindowPoints ? @"BTWindowPointsStrokeAdjustment" : nil;
}

- (id)defaultStrokeAdjustment
{
    return @"BTWindowPointsStrokeAdjustment";
}

/* Colors come in as CGColors or as BTPointer-wrapped CGEColors. */
static CGEColorRef BTPencilToolCreateColor(id aColor)
{
    if (aColor == nil)
        return NULL;
    if (CFGetTypeID((CFTypeRef)aColor) == CGColorGetTypeID())
        return CGEColorCreateWithCGColor((CGColorRef)aColor);
    return CGEColorRetain((CGEColorRef)[aColor pointer]);
}

static BOOL BTPencilToolColorEquals(id aColor, CGEColorRef aCurrent)
{
    if (aColor == nil)
        return aCurrent == NULL;
    if (CFGetTypeID((CFTypeRef)aColor) == CGColorGetTypeID())
        return CGColorEqualToColor((CGColorRef)aColor, CGEColorGetCGColor(aCurrent));
    return CGEColorEqualToColor((CGEColorRef)[aColor pointer], aCurrent);
}

/* Color changes while active are undoable in their own category. */
- (void)setAlternateStrokeColor:(id)aColor
{
    id undoManager;
    if ([self isActive] && (undoManager = [_delegate undoManagerForTool:self category:@"BTStrokeColorUndoCategory"]) != nil) {
        if (BTPencilToolColorEquals(aColor, _alternateStrokeColor))
            return;
        [[self prepareUndoInManager:undoManager category:@"BTStrokeColorUndoCategory" withInvocationTarget:self] setAlternateStrokeColor:[self alternateStrokeColor]];
    }
    CGEColorRef old = _alternateStrokeColor;
    _alternateStrokeColor = BTPencilToolCreateColor(aColor);
    CGEColorRelease(old);
}

- (id)alternateStrokeColor
{
    if (_alternateStrokeColor == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:_alternateStrokeColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(_alternateStrokeColor);
    return wrapper;
}

- (void)setStrokeColor:(id)aColor
{
    id undoManager;
    if ([self isActive] && (undoManager = [_delegate undoManagerForTool:self category:@"BTStrokeColorUndoCategory"]) != nil) {
        if (BTPencilToolColorEquals(aColor, [self BTPencilTool_strokeColor]))
            return;
        [[self prepareUndoInManager:undoManager category:@"BTStrokeColorUndoCategory" withInvocationTarget:self] setStrokeColor:[self strokeColor]];
    }
    CGEColorRef old = _strokeColor;
    _strokeColor = BTPencilToolCreateColor(aColor);
    CGEColorRelease(old);
    _isStrokeColorInitialized = 1;
}

- (id)strokeColor
{
    if ([self BTPencilTool_strokeColor] == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:_strokeColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(_strokeColor);
    return wrapper;
}

- (struct CGEColor *)BTPencilTool_strokeColor
{
    if (!_isStrokeColorInitialized) {
        _strokeColor = [self BTPencilTool_createDefaultStrokeColor];
        _isStrokeColorInitialized = 1;
    }
    return _strokeColor;
}

- (id)defaultStrokeColor
{
    CGEColorRef color = [self BTPencilTool_createDefaultStrokeColor];
    if (color == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:color withDisposer:CGEColorRelease];
    if (wrapper == nil)
        CGEColorRelease(color);
    return wrapper;
}

/* Opaque black. */
- (struct CGEColor *)BTPencilTool_createDefaultStrokeColor
{
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (space == NULL)
        return NULL;
    const CGFloat components[4] = { 0.0, 0.0, 0.0, 1.0 };
    CGEColorRef color = CGEColorCreateSolid(space, components);
    CGColorSpaceRelease(space);
    return color;
}

- (void)setPickColorCursor:(id)aCursor
{
    if (_pickColorCursor != aCursor) {
        [_pickColorCursor release];
        _pickColorCursor = [aCursor retain];
    }
    _isPickColorCursorInitialized = 1;
}

- (id)pickColorCursor
{
    if (!_isPickColorCursorInitialized) {
        _pickColorCursor = [[self defaultPickColorCursor] retain];
        _isPickColorCursorInitialized = 1;
    }
    return _pickColorCursor;
}

- (id)defaultPickColorCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoAlternateDrawCursor:(id)aCursor
{
    if (_doAlternateDrawCursor != aCursor) {
        [_doAlternateDrawCursor release];
        _doAlternateDrawCursor = [aCursor retain];
    }
    _isDoAlternateDrawCursorInitialized = 1;
}

- (id)doAlternateDrawCursor
{
    if (!_isDoAlternateDrawCursorInitialized) {
        _doAlternateDrawCursor = [[self defaultDoAlternateDrawCursor] retain];
        _isDoAlternateDrawCursorInitialized = 1;
    }
    return _doAlternateDrawCursor;
}

- (id)defaultDoAlternateDrawCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillAlternateDrawCursor:(id)aCursor
{
    if (_willAlternateDrawCursor != aCursor) {
        [_willAlternateDrawCursor release];
        _willAlternateDrawCursor = [aCursor retain];
    }
    _isWillAlternateDrawCursorInitialized = 1;
}

- (id)willAlternateDrawCursor
{
    if (!_isWillAlternateDrawCursorInitialized) {
        _willAlternateDrawCursor = [[self defaultWillAlternateDrawCursor] retain];
        _isWillAlternateDrawCursorInitialized = 1;
    }
    return _willAlternateDrawCursor;
}

- (id)defaultWillAlternateDrawCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setDoDrawCursor:(id)aCursor
{
    if (_doDrawCursor != aCursor) {
        [aCursor retain];
        [_doDrawCursor release];
        _doDrawCursor = aCursor;
    }
    _isDoDrawCursorInitialized = 1;
}

- (id)doDrawCursor
{
    if (!_isDoDrawCursorInitialized) {
        _doDrawCursor = [[self defaultDoDrawCursor] retain];
        _isDoDrawCursorInitialized = 1;
    }
    return _doDrawCursor;
}

- (id)defaultDoDrawCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setWillDrawCursor:(id)aCursor
{
    if (_willDrawCursor != aCursor) {
        [_willDrawCursor release];
        _willDrawCursor = [aCursor retain];
    }
    _isWillDrawCursorInitialized = 1;
}

- (id)willDrawCursor
{
    if (!_isWillDrawCursorInitialized) {
        _willDrawCursor = [[self defaultWillDrawCursor] retain];
        _isWillDrawCursorInitialized = 1;
    }
    return _willDrawCursor;
}

- (id)defaultWillDrawCursor
{
    return [NSCursor crosshairCursor];
}

- (void)setAlternateColorOption:(NSUInteger)aOption
{
    _alternateColorOption = aOption;
}

- (NSUInteger)alternateColorOption
{
    return _alternateColorOption;
}

- (NSUInteger)defaultAlternateColorOption
{
    return NSEventModifierFlagOption;
}

- (void)setColorPickingOption:(NSUInteger)aOption
{
    _colorPickingOption = aOption;
}

- (NSUInteger)colorPickingOption
{
    return _colorPickingOption;
}

- (NSUInteger)defaultColorPickingOption
{
    return NSEventModifierFlagCommand;
}

- (void)dealloc
{
    if (_strokeConsumers != nil)
        NSFreeMapTable(_strokeConsumers);
    [_willDrawCursor release];
    [_doDrawCursor release];
    [_willAlternateDrawCursor release];
    [_doAlternateDrawCursor release];
    [_pickColorCursor release];
    CGEColorRelease(_strokeColor);
    CGEColorRelease(_alternateStrokeColor);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _adjustsStrokeToMatchWindowPoints = 1;
    _colorPickingOption = NSEventModifierFlagCommand;
    _alternateColorOption = NSEventModifierFlagOption;
    return self;
}

@end
