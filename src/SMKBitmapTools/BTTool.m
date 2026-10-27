#import "BTTool.h"
#import "BTSizeToPointSnapSource.h"
#import "NSEvent_BTKeyBinding_BTKeyEventsInterpreter.h"

static NSString * const BTToolWorkImageUndoCategory = @"BTToolWorkImageUndoCategory";

/* Methods of the layout guiding context provided by the hosting editor. */
@interface NSObject (BTToolLayoutGuidingContext)
- (BOOL)snapPoints:(NSArray *)aSources sizes:(NSArray *)aSizes withEvent:(NSEvent *)aEvent options:(NSDictionary *)aOptions snappedReflectedPoint:(CGPoint *)aPoint snapDistance:(CGFloat *)aDistance appliedRules:(id *)aRules;
- (void)showAppliedRules:(id)aRules;
- (CGPoint)convertImagePointToViewPoint:(CGPoint)aPoint;
- (CGPoint)convertViewPointToImagePoint:(CGPoint)aPoint;
- (NSRect)convertImageRectToViewRect:(NSRect)aRect;
- (NSRect)convertViewRectToImageRect:(NSRect)aRect;
- (CGAffineTransform)viewToImageTransform;
- (id)activeFeedbackLayersForDrawing;
- (BOOL)rawKeyDown:(NSEvent *)aEvent;
- (BOOL)isTracking;
- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags;
- (id)keyBindings;
@end

@implementation BTTool

+ (BOOL)accessInstanceVariablesDirectly
{
    return NO;
}

- (CGPoint)guidePoints:(CGPoint *)aPoints count:(NSUInteger)aCount withReflectingTransforms:(CGAffineTransform *)aTransforms asDevicePixelCenters:(BOOL)aCenters forMovementFromPoint:(CGPoint)aFrom toPoint:(CGPoint)aTo centeringOnDevicePixel:(BOOL)aPixel inMode:(char *)aMode withEvent:(id)aEvent
{
    CGPoint to = aTo;
    BOOL snapped;

    if (aTo.x == aFrom.x && aTo.y == aFrom.y)
        return aTo;

    if (aMode == NULL || *aMode == 0) {
        snapped = [self BTTool_snapPoints:aPoints count:aCount withReflectingTransforms:aTransforms asDevicePixelCenter:aCenters withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:CGELineUndefined withEvent:aEvent options:nil showAppliedRules:YES snappedPoint:&to snapDistance:NULL appliedRules:NULL];
    } else if (*aMode == 1) {
        snapped = [self BTTool_snapPoints:aPoints count:aCount withReflectingTransforms:aTransforms asDevicePixelCenter:aCenters withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:aFrom.y maxY:aFrom.y alongTrajectoryLine:(CGELine){0, 1, -aFrom.y} withEvent:aEvent options:nil showAppliedRules:YES snappedPoint:&to snapDistance:NULL appliedRules:NULL];
    } else if (*aMode == 2) {
        snapped = [self BTTool_snapPoints:aPoints count:aCount withReflectingTransforms:aTransforms asDevicePixelCenter:aCenters withinBoundsWithMinX:aFrom.x maxX:aFrom.x minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){1, 0, -aFrom.x} withEvent:aEvent options:nil showAppliedRules:YES snappedPoint:&to snapDistance:NULL appliedRules:NULL];
    } else if (*aMode == 3) {
        snapped = [self BTTool_snapPoints:aPoints count:aCount withReflectingTransforms:aTransforms asDevicePixelCenter:aCenters withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){1, -1, aFrom.y - aFrom.x} withEvent:aEvent options:nil showAppliedRules:YES snappedPoint:&to snapDistance:NULL appliedRules:NULL];
    } else if (*aMode == 4) {
        snapped = [self BTTool_snapPoints:aPoints count:aCount withReflectingTransforms:aTransforms asDevicePixelCenter:aCenters withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){-1, -1, aFrom.y + aFrom.x} withEvent:aEvent options:nil showAppliedRules:YES snappedPoint:&to snapDistance:NULL appliedRules:NULL];
    } else {
        /* Auto-detect: pick the guide line the snapping prefers, else the movement direction. */
        CGPoint best = CGPointMake(NAN, NAN);
        id bestRules = nil;
        CGFloat bestDistance = INFINITY;
        id context = [_delegate layoutGuidingContextForTool:self];

        if (context != nil) {
            NSSize s = [_view convertSize:NSMakeSize(0.001, 0.001) fromView:nil];
            CGFloat tol = hypot(s.width, s.height);
            CGPoint candidate = CGPointMake(NAN, NAN);
            CGFloat distance = INFINITY;
            id rules = nil;

            if ([self BTTool_snapPoints:aPoints count:aCount withReflectingTransforms:aTransforms asDevicePixelCenter:aCenters withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:aFrom.y maxY:aFrom.y alongTrajectoryLine:(CGELine){0, 1, -aFrom.y} withEvent:aEvent options:nil showAppliedRules:NO snappedPoint:&candidate snapDistance:&distance appliedRules:&rules]
                && !(aFrom.x - tol <= candidate.x && candidate.x <= aFrom.x + tol)) {
                bestDistance = distance; best = candidate; bestRules = rules; *aMode = 1;
            }
            if ([self BTTool_snapPoints:aPoints count:aCount withReflectingTransforms:aTransforms asDevicePixelCenter:aCenters withinBoundsWithMinX:aFrom.x maxX:aFrom.x minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){1, 0, -aFrom.x} withEvent:aEvent options:nil showAppliedRules:NO snappedPoint:&candidate snapDistance:&distance appliedRules:&rules]
                && distance + tol < bestDistance
                && (candidate.y < aFrom.y - tol || aFrom.y + tol < candidate.y)) {
                bestDistance = distance; best = candidate; bestRules = rules; *aMode = 2;
            }
            if ([self BTTool_snapPoints:aPoints count:aCount withReflectingTransforms:aTransforms asDevicePixelCenter:aCenters withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){1, -1, aFrom.y - aFrom.x} withEvent:aEvent options:nil showAppliedRules:NO snappedPoint:&candidate snapDistance:&distance appliedRules:&rules]
                && distance + tol < bestDistance
                && (candidate.x < aFrom.x - tol || aFrom.x + tol < candidate.x)) {
                bestDistance = distance; best = candidate; bestRules = rules; *aMode = 3;
            }
            if ([self BTTool_snapPoints:aPoints count:aCount withReflectingTransforms:aTransforms asDevicePixelCenter:aCenters withinBoundsWithMinX:-INFINITY maxX:INFINITY minY:-INFINITY maxY:INFINITY alongTrajectoryLine:(CGELine){-1, -1, aFrom.y + aFrom.x} withEvent:aEvent options:nil showAppliedRules:NO snappedPoint:&candidate snapDistance:&distance appliedRules:&rules]
                && distance + tol < bestDistance
                && (candidate.x < aFrom.x - tol || aFrom.x + tol < candidate.x)) {
                bestDistance = distance; best = candidate; bestRules = rules; *aMode = 4;
            }
        }

        if (fabs(bestDistance) < INFINITY) {
            SEL showSel = @selector(SMKBitmapTools_showAppliedRules:forSnappedPoint:);
            id ctx = [_delegate layoutGuidingContextForTool:self];
            if ([ctx respondsToSelector:showSel]) {
                NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[ctx methodSignatureForSelector:showSel]];
                [inv setTarget:ctx];
                [inv setSelector:showSel];
                [inv setArgument:&bestRules atIndex:2];
                [inv setArgument:&best atIndex:3];
                [inv invoke];
            } else {
                [ctx showAppliedRules:bestRules];
            }
            return best;
        }

        CGFloat dx = fabs(aTo.x - aFrom.x);
        CGFloat dy = fabs(aTo.y - aFrom.y);
        if (dy <= dx) {
            if (dx < dy + dy)
                *aMode = ((aTo.x - aFrom.x) * (aTo.y - aFrom.y) < 0.0) ? 4 : 3;
            else
                *aMode = 1;
        } else if (dy < dx + dx) {
            *aMode = ((aTo.x - aFrom.x) * (aTo.y - aFrom.y) < 0.0) ? 4 : 3;
        } else {
            *aMode = 2;
        }
        snapped = NO;
    }

    if (snapped || aMode == NULL)
        return to;

    CGFloat x2, y2;
    switch (*aMode) {
    case 1:
        to.y = aFrom.y;
        return to;
    case 2:
        to.x = aFrom.x;
        return to;
    case 3:
        y2 = (to.y + to.x) + (aFrom.y - aFrom.x);
        x2 = (to.y + to.x) - (aFrom.y - aFrom.x);
        break;
    case 4:
        y2 = (aFrom.y + aFrom.x) + (to.y - to.x);
        x2 = (aFrom.y + aFrom.x) - (to.y - to.x);
        break;
    default:
        return to;
    }

    /* Diagonal guides: nudge the point so the line crosses a device pixel center. */
    CGPoint projected = CGPointMake(x2 * 0.5, y2 * 0.5);
    to = projected;
    if (aCenters) {
        NSPoint a = [_view convertPoint:aPoints[0] toView:nil];
        NSPoint b = [_view convertPoint:NSMakePoint(projected.x + aPoints[0].x - aFrom.x, projected.y + aPoints[0].y - aFrom.y) toView:nil];
        if (a.x != b.x) {
            CGFloat px = round(b.x + 0.5) - 0.5;
            CGFloat py = (px - b.x) * (b.y - a.y) / (b.x - a.x) + b.y;
            CGFloat f = fabs(fmod(py, 1.0));
            if (0.499 <= f && f <= 0.501) {
                NSPoint q = [_view convertPoint:NSMakePoint(px, py) fromView:nil];
                to.x = q.x + aFrom.x - aPoints[0].x;
                to.y = q.y + aFrom.y - aPoints[0].y;
            }
        }
    } else if (aPixel) {
        NSPoint a = [_view convertPoint:aFrom toView:nil];
        NSPoint b = [_view convertPoint:projected toView:nil];
        if (a.x != b.x) {
            CGFloat px = round(b.x + 0.5) - 0.5;
            CGFloat py = (px - b.x) * (b.y - a.y) / (b.x - a.x) + b.y;
            CGFloat f = fabs(fmod(py, 1.0));
            if (0.499 <= f && f <= 0.501)
                to = [_view convertPoint:NSMakePoint(px, py) fromView:nil];
        }
    }
    return to;
}

- (CGPoint)guideMovementFromPoint:(CGPoint)aFrom toPoint:(CGPoint)aTo centeringOnDevicePixel:(BOOL)aPixel inMode:(char *)aMode withEvent:(id)aEvent
{
    CGPoint point = aTo;
    return [self guidePoints:&point count:1 withReflectingTransforms:(CGAffineTransform *)&CGAffineTransformIdentity asDevicePixelCenters:aPixel forMovementFromPoint:aFrom toPoint:aTo centeringOnDevicePixel:NO inMode:aMode withEvent:aEvent];
}

- (BOOL)snapPoint:(CGPoint)aPoint asDevicePixelCenter:(BOOL)aCenter withinBoundsWithMinX:(CGFloat)aMinX maxX:(CGFloat)aMaxX minY:(CGFloat)aMinY maxY:(CGFloat)aMaxY alongTrajectoryLine:(struct CGELine)aLine withEvent:(id)aEvent options:(id)aOptions snappedPoint:(CGPoint *)aSnapped snapDistance:(CGFloat *)aDistance appliedRules:(id *)aRules
{
    CGPoint point = aPoint;
    return [self BTTool_snapPoints:&point count:1 withReflectingTransforms:(CGAffineTransform *)&CGAffineTransformIdentity asDevicePixelCenter:aCenter withinBoundsWithMinX:aMinX maxX:aMaxX minY:aMinY maxY:aMaxY alongTrajectoryLine:aLine withEvent:aEvent options:aOptions showAppliedRules:NO snappedPoint:aSnapped snapDistance:aDistance appliedRules:aRules];
}

- (BOOL)snapPoint:(CGPoint *)aPoint asDevicePixelCenter:(BOOL)aCenter withinBoundsWithMinX:(CGFloat)aMinX maxX:(CGFloat)aMaxX minY:(CGFloat)aMinY maxY:(CGFloat)aMaxY alongTrajectoryLine:(struct CGELine)aLine withEvent:(id)aEvent options:(id)aOptions
{
    return [self BTTool_snapPoints:aPoint count:1 withReflectingTransforms:(CGAffineTransform *)&CGAffineTransformIdentity asDevicePixelCenter:aCenter withinBoundsWithMinX:aMinX maxX:aMaxX minY:aMinY maxY:aMaxY alongTrajectoryLine:aLine withEvent:aEvent options:aOptions showAppliedRules:YES snappedPoint:aPoint snapDistance:NULL appliedRules:NULL];
}

- (BOOL)BTTool_snapPoints:(CGPoint *)aPoints count:(NSUInteger)aCount withReflectingTransforms:(CGAffineTransform *)aTransforms asDevicePixelCenter:(BOOL)aCenter withinBoundsWithMinX:(CGFloat)aMinX maxX:(CGFloat)aMaxX minY:(CGFloat)aMinY maxY:(CGFloat)aMaxY alongTrajectoryLine:(struct CGELine)aLine withEvent:(id)aEvent options:(id)aOptions showAppliedRules:(BOOL)aShowRules snappedPoint:(CGPoint *)aSnapped snapDistance:(CGFloat *)aDistance appliedRules:(id *)aRules
{
    id context = [_delegate layoutGuidingContextForTool:self];
    if (context == nil)
        return NO;

    CGPoint localPoint = CGPointZero;
    id localRules = nil;
    CGPoint *snapped = (aSnapped != NULL || !aShowRules) ? aSnapped : &localPoint;
    id *rules = (aRules != NULL || !aShowRules) ? aRules : &localRules;

    NSDictionary *sourceOptions = nil;
    if (aCenter)
        sourceOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:aCenter], @"BTPointSnapSourceOptionSnapAsDevicePixelCenter", nil];

    NSMutableArray *sources = [NSMutableArray arrayWithCapacity:aCount];
    for (NSUInteger i = 0; i < aCount; i++) {
        id source = [BTPointToPointSnapSource sourceWithPoint:aPoints[i] minXBound:aMinX maxXBound:aMaxX minYBound:aMinY maxYBound:aMaxY trajectoryLine:aLine options:sourceOptions reflectingTransform:aTransforms[i]];
        if (source != nil)
            [sources addObject:source];
    }

    if (![context snapPoints:sources sizes:nil withEvent:aEvent options:aOptions snappedReflectedPoint:snapped snapDistance:aDistance appliedRules:rules])
        return NO;
    if (!aShowRules)
        return YES;

    SEL showSel = @selector(SMKBitmapTools_showAppliedRules:forSnappedPoint:);
    if ([context respondsToSelector:showSel]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[context methodSignatureForSelector:showSel]];
        [inv setTarget:context];
        [inv setSelector:showSel];
        [inv setArgument:rules atIndex:2];
        [inv setArgument:snapped atIndex:3];
        [inv invoke];
    } else {
        [context showAppliedRules:*rules];
    }
    return YES;
}

- (NSPoint)eventLocationInImage:(id)aEvent
{
    return [self convertViewPointToImagePoint:[self eventLocationInView:aEvent]];
}

- (NSPoint)eventLocationInView:(id)aEvent
{
    NSPoint p = [aEvent locationInWindow];
    return [_view convertPoint:NSMakePoint(floor(p.x) + 0.5, floor(p.y) + 0.5) fromView:nil];
}

- (NSRect)convertImageRectToViewRect:(NSRect)aRect
{
    id transformer = [_delegate imageViewTransformerForTool:self];
    return transformer != nil ? [transformer convertImageRectToViewRect:aRect] : aRect;
}

- (NSPoint)convertImagePointToViewPoint:(NSPoint)aPoint
{
    id transformer = [_delegate imageViewTransformerForTool:self];
    return transformer != nil ? [transformer convertImagePointToViewPoint:aPoint] : aPoint;
}

- (CGAffineTransform)imageToViewTransform
{
    id transformer = [_delegate imageViewTransformerForTool:self];
    return transformer != nil ? [transformer imageToViewTransform] : CGAffineTransformIdentity;
}

- (NSRect)convertViewRectToImageRect:(NSRect)aRect
{
    id transformer = [_delegate imageViewTransformerForTool:self];
    return transformer != nil ? [transformer convertViewRectToImageRect:aRect] : aRect;
}

- (NSPoint)convertViewPointToImagePoint:(NSPoint)aPoint
{
    id transformer = [_delegate imageViewTransformerForTool:self];
    return transformer != nil ? [transformer convertViewPointToImagePoint:aPoint] : aPoint;
}

- (CGAffineTransform)viewToImageTransform
{
    id transformer = [_delegate imageViewTransformerForTool:self];
    return transformer != nil ? [transformer viewToImageTransform] : CGAffineTransformIdentity;
}

- (void)performDrawRect:(NSRect)aRect ofActiveFeedbackLayer:(id)aLayer
{
    NSString *name = [NSString stringWithFormat:@"draw%@Rect:", aLayer];
    if (name == nil)
        return;
    SEL sel = NSSelectorFromString(name);
    if (sel == NULL || ![self respondsToSelector:sel])
        return;
    NSMethodSignature *sig = [self methodSignatureForSelector:sel];
    if (sig == nil)
        return;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    if (inv == nil)
        return;
    [inv setTarget:self];
    [inv setSelector:sel];
    [inv setArgument:&aRect atIndex:2];
    [inv invoke];
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayers:(id)aLayers
{
    for (id layer in [self activeFeedbackLayersForDrawing])
        if (![aLayers containsObject:layer])
            [self performDrawRect:aRect ofActiveFeedbackLayer:layer];
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayersExcludingLayer:(id)aLayer
{
    for (id layer in [self activeFeedbackLayersForDrawing])
        if (![layer isEqualToString:aLayer])
            [self performDrawRect:aRect ofActiveFeedbackLayer:layer];
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayers:(id)aLayers
{
    for (id layer in [self activeFeedbackLayersForDrawing])
        if ([aLayers containsObject:layer])
            [self performDrawRect:aRect ofActiveFeedbackLayer:layer];
}

- (void)drawRect:(NSRect)aRect ofActiveFeedbackLayer:(id)aLayer
{
    if ([self isFeedbackLayerActive:aLayer])
        [self performDrawRect:aRect ofActiveFeedbackLayer:aLayer];
}

- (id)activeFeedbackLayersForDrawing
{
    if (_currentSubtool != nil)
        return [_currentSubtool activeFeedbackLayersForDrawing];
    return [NSArray array];
}

- (BOOL)isFeedbackLayerActive:(id)aLayer
{
    return [[self activeFeedbackLayers] containsObject:aLayer];
}

- (id)activeFeedbackLayers
{
    return [NSSet setWithArray:[self activeFeedbackLayersForDrawing]];
}

- (void)drawRect:(NSRect)aRect
{
    for (id layer in [self activeFeedbackLayersForDrawing])
        [self performDrawRect:aRect ofActiveFeedbackLayer:layer];
}

- (void)forwardInvocation:(id)aInvocation
{
    if (_currentSubtool == nil)
        [super forwardInvocation:aInvocation];
    else
        [aInvocation invokeWithTarget:_currentSubtool];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *sig = [super methodSignatureForSelector:aSelector];
    if (sig == nil)
        sig = [_currentSubtool methodSignatureForSelector:aSelector];
    return sig;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;
    return [_currentSubtool respondsToSelector:aSelector];
}

- (BOOL)doCommandBySelector:(SEL)aSelector
{
    BOOL responds = [self respondsToSelector:aSelector];
    if (responds)
        [self performSelector:aSelector withObject:nil];
    return responds;
}

- (BOOL)insertText:(id)aText
{
    return [_currentSubtool insertText:aText];
}

- (BOOL)performValidationSelector:(SEL)aSelector
{
    if (![self respondsToSelector:aSelector])
        return YES;
    NSMethodSignature *sig = [self methodSignatureForSelector:aSelector];
    if (sig == nil)
        return NO;
    if (strcmp([sig methodReturnType], @encode(BOOL)) != 0 && strcmp([sig methodReturnType], "c") != 0)
        return YES;
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    BOOL result = YES;
    if (inv != nil) {
        [inv setTarget:self];
        [inv setSelector:aSelector];
        [inv invoke];
        [inv getReturnValue:&result];
    }
    return result;
}

- (BOOL)validateAction:(SEL)aAction
{
    NSString *name = NSStringFromSelector(aAction);
    if (name == nil)
        return NO;
    name = [name substringToIndex:[name length] - 1];
    if (name == nil)
        return NO;
    NSString *validator = [NSString stringWithFormat:@"validateAction_%@", name];
    SEL sel = validator != nil ? NSSelectorFromString(validator) : NULL;
    if (sel == NULL)
        return NO;
    return [self performValidationSelector:sel];
}

- (id)keyBindings
{
    return [NSEvent BT_mergeKeyBindingDictionary:[self generalKeyBindings] intoDictionary:[_currentSubtool keyBindings]];
}

- (BOOL)flagsChanged:(id)aEvent
{
    return [_currentSubtool flagsChanged:aEvent];
}

- (BOOL)keyUp:(id)aEvent
{
    return [_currentSubtool keyUp:aEvent];
}

- (BOOL)rawKeyDown:(id)aEvent
{
    return [_currentSubtool rawKeyDown:aEvent];
}

- (BOOL)keyDown:(id)aEvent
{
    if ([self rawKeyDown:aEvent])
        return YES;

    NSDictionary *bindings = [self keyBindings];
    if (bindings != nil) {
        SEL command = [aEvent BT_commandSelectorUsingKeyBindingDictionary:bindings];
        if (command != NULL)
            return [self doCommandBySelector:command];
    }

    SEL command = NULL;
    NSString *text = nil;
    SEL interpretSel = @selector(interpretCurrentKeyEventAsCommand:text:);
    NSInvocation *inv = nil;
    if ([_view respondsToSelector:interpretSel]) {
        NSMethodSignature *sig = [_view methodSignatureForSelector:interpretSel];
        if (sig != nil && [sig methodReturnLength] == 0
            && strcmp([sig getArgumentTypeAtIndex:2], "^:") == 0
            && strcmp([sig getArgumentTypeAtIndex:3], "^@") == 0) {
            SEL *commandPtr = &command;
            NSString **textPtr = &text;
            inv = [NSInvocation invocationWithMethodSignature:sig];
            [inv setTarget:_view];
            [inv setSelector:interpretSel];
            [inv setArgument:&commandPtr atIndex:2];
            [inv setArgument:&textPtr atIndex:3];
        }
    }
    if (inv != nil)
        [inv invoke];
    else
        [aEvent BT_interpretAsCommand:&command text:&text];

    if (command != NULL)
        return [self doCommandBySelector:command];
    if (text == nil)
        return NO;
    return [self insertText:text];
}

- (BOOL)scrollWheel:(id)aEvent
{
    return [_currentSubtool scrollWheel:aEvent];
}

- (BOOL)mouseMoved:(id)aEvent
{
    return [_currentSubtool mouseMoved:aEvent];
}

- (BOOL)mouseDragged:(id)aEvent
{
    return [_currentSubtool mouseDragged:aEvent];
}

- (BOOL)mouseUp:(id)aEvent
{
    return [_currentSubtool mouseUp:aEvent];
}

- (BOOL)mouseDown:(id)aEvent
{
    return [_currentSubtool mouseDown:aEvent];
}

- (BOOL)sendEvent:(id)aEvent
{
    switch ([(NSEvent *)aEvent type]) {
    case NSEventTypeLeftMouseDown:   return [self mouseDown:aEvent];
    case NSEventTypeLeftMouseUp:     return [self mouseUp:aEvent];
    case NSEventTypeMouseMoved:      return [self mouseMoved:aEvent];
    case NSEventTypeLeftMouseDragged: return [self mouseDragged:aEvent];
    case NSEventTypeKeyDown:         return [self keyDown:aEvent];
    case NSEventTypeKeyUp:           return [self keyUp:aEvent];
    case NSEventTypeFlagsChanged:    return [self flagsChanged:aEvent];
    case NSEventTypeScrollWheel:     return [self scrollWheel:aEvent];
    default:                         return NO;
    }
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    return [_currentSubtool cursorForPoint:aPoint modifierFlags:aFlags];
}

- (void)changeViewInvalidationEnabledTo:(BOOL)aEnabled
{
    _isViewInvalidationEnabled = aEnabled ? 1 : 0;
}

- (void)setViewInvalidationEnabled:(BOOL)aEnabled
{
    if ((_isViewInvalidationEnabled && !aEnabled) || (!_isViewInvalidationEnabled && aEnabled))
        [self changeViewInvalidationEnabledTo:aEnabled];
}

- (BOOL)isViewInvalidationEnabled
{
    return _isViewInvalidationEnabled;
}

- (void)changeReferenceCGContextTo:(struct CGContext *)aContext
{
    CGContextRelease(_referenceCGContext);
    _referenceCGContext = CGContextRetain(aContext);
}

- (void)setReferenceCGContext:(struct CGContext *)aContext
{
    if (_referenceCGContext != aContext)
        [self changeReferenceCGContextTo:aContext];
}

- (struct CGContext *)referenceCGContext
{
    return _referenceCGContext;
}

- (void)changeWorkPasteboardTo:(id)aPasteboard
{
    [_workPasteboard release];
    _workPasteboard = [aPasteboard retain];
}

- (void)setWorkPasteboard:(id)aPasteboard
{
    if (_workPasteboard != aPasteboard)
        [self changeWorkPasteboardTo:aPasteboard];
    _isWorkPasteboardInitialized = 1;
}

- (id)workPasteboard
{
    if (!_isWorkPasteboardInitialized) {
        _workPasteboard = [[NSPasteboard generalPasteboard] retain];
        _isWorkPasteboardInitialized = 1;
    }
    return _workPasteboard;
}

- (void)imageUndoer:(id)aUndoer didChangeImageInRect:(CGRect)aRect
{
    if (_workImageUndoer == aUndoer)
        [_delegate tool:self didChangeImageInRect:aRect];
}

- (void)imageUndoer:(id)aUndoer willChangeImageInRect:(CGRect)aRect
{
    if (_workImageUndoer == aUndoer)
        [_delegate tool:self willChangeImageInRect:aRect];
}

- (id)prepareUndoForImageUndoer:(id)aUndoer withInvocationTarget:(id)aTarget
{
    if (_workImageUndoer != aUndoer)
        return nil;
    id manager = [_delegate undoManagerForTool:self category:BTToolWorkImageUndoCategory];
    if (manager == nil)
        return nil;
    return [self prepareUndoInManager:manager category:BTToolWorkImageUndoCategory withInvocationTarget:aTarget];
}

- (void)registerUndoForImageUndoer:(id)aUndoer withTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject
{
    if (_workImageUndoer != aUndoer)
        return;
    id manager = [_delegate undoManagerForTool:self category:BTToolWorkImageUndoCategory];
    if (manager != nil)
        [self registerUndoInManager:manager category:BTToolWorkImageUndoCategory withTarget:aTarget selector:aSelector object:aObject];
}

- (BOOL)isGroupingWorkImageUndo
{
    return _isWorkImageUndoGroupingBegun || _isWorkImageUndoGroupingScheduled;
}

- (void)endWorkImageUndoGrouping
{
    if (_workImage == nil)
        return;
    if (_isWorkImageUndoGroupingBegun) {
        [_workImageUndoer endUndoGrouping];
        _isWorkImageUndoGroupingBegun = 0;
    }
    _isWorkImageUndoGroupingScheduled = 0;
}

- (void)beginWorkImageUndoGrouping
{
    if (_workImage != nil)
        _isWorkImageUndoGroupingScheduled = 1;
}

- (void)registerWorkImageUndoInRect:(CGRect)aRect
{
    if ([_delegate undoManagerForTool:self category:BTToolWorkImageUndoCategory] == nil)
        return;
    if ([self BTTool_workImageUndoer] == nil)
        return;
    if (!_isWorkImageUndoGroupingBegun && _isWorkImageUndoGroupingScheduled) {
        [_workImageUndoer beginUndoGrouping];
        _isWorkImageUndoGroupingScheduled = 0;
        _isWorkImageUndoGroupingBegun = 1;
    }
    [_workImageUndoer registerUndoInRect:aRect];
}

- (id)BTTool_workImageUndoer
{
    if (_workImageUndoer == nil)
        _workImageUndoer = [_workImage createImageUndoerWithDelegate:self];
    return _workImageUndoer;
}

- (void)setUndoActionName:(id)aName
{
    id manager = [_delegate tool:self willSetUndoActionName:aName];
    if (manager == nil)
        return;
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.mackiev.SMKBitmapTools"];
    if (bundle == nil)
        bundle = [NSBundle bundleForClass:[BTTool class]];
    [manager NSE_setActionNameIfNeeded:[bundle localizedStringForKey:aName value:@"" table:@"Undo"]];
}

- (void)endUndoActionWithName:(id)aName
{
    if (aName != nil)
        [self setUndoActionName:aName];
}

- (void)beginUndoAction
{
}

- (id)prepareUndoInManager:(id)aManager category:(id)aCategory withInvocationTarget:(id)aTarget
{
    NSEUndoProxy *proxy = [self BTTool_undoProxyForCategory:aCategory];
    if (proxy == nil)
        return nil;
    [_delegate tool:self willRegisterUndoInManager:aManager category:aCategory];
    return [proxy prepareUndoInManager:aManager withInvocationTarget:aTarget];
}

- (void)registerUndoInManager:(id)aManager category:(id)aCategory withTarget:(id)aTarget selector:(SEL)aSelector object:(id)aObject
{
    NSEUndoProxy *proxy = [self BTTool_undoProxyForCategory:aCategory];
    if (proxy == nil)
        return;
    [_delegate tool:self willRegisterUndoInManager:aManager category:aCategory];
    [proxy registerUndoInManager:aManager withTarget:aTarget selector:aSelector object:aObject];
}

- (id)BTTool_undoProxyForCategory:(id)aCategory
{
    NSEUndoProxy *proxy = [_undoProxies objectForKey:aCategory];
    if (proxy != nil)
        return proxy;
    if (_undoProxies == nil) {
        _undoProxies = [[NSMutableDictionary alloc] init];
        if (_undoProxies == nil)
            return nil;
    }
    proxy = [[[NSEUndoProxy alloc] init] autorelease];
    if (proxy != nil)
        [_undoProxies setObject:proxy forKey:aCategory];
    return proxy;
}

- (void)removeAllUndoActionsFromManager:(id)aManager
{
    for (id proxy in [_undoProxies objectEnumerator])
        [aManager removeAllActionsWithTarget:proxy];
}

- (void)removeAllUndoActionsFromManager:(id)aManager category:(id)aCategory
{
    id proxy = [_undoProxies objectForKey:aCategory];
    if (proxy != nil)
        [aManager removeAllActionsWithTarget:proxy];
}

- (id)allUndoCategories
{
    return [NSSet set];
}

- (BOOL)isTracking
{
    return [_currentSubtool isTracking];
}

- (id)currentStage
{
    return @"BTWaitingToolStage";
}

- (id)view
{
    return _view;
}

- (id)delegate
{
    return _delegate;
}

- (void)performDeactivate
{
    _delegate = nil;
    _view = nil;
    _isActive = 0;
}

- (void)deactivate
{
    if (_isActive)
        [self performDeactivate];
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (!_isActive) {
        _delegate = aDelegate;
        _view = aView;
        _isActive = 1;
    }
    return _isActive;
}

- (BOOL)isActive
{
    return _isActive;
}

- (void)setDefaults
{
    for (id key in [self inputKeys]) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        id value = [self defaultValueForInputKey:key];
        if (value != (id)(intptr_t)-1)
            [self setValue:value forInputKey:key];
        [pool release];
    }
}

- (id)attributes
{
    return [NSDictionary dictionary];
}

- (id)valueForOutputKey:(id)aKey
{
    return [self valueForKey:aKey];
}

- (void)setInputs:(id)aInputs
{
    id null = [NSNull null];
    for (id key in [aInputs keyEnumerator]) {
        id value = [aInputs objectForKey:key];
        [self setValue:(value != null ? value : nil) forInputKey:key];
    }
}

- (id)inputs
{
    NSMutableDictionary *inputs = [NSMutableDictionary dictionary];
    for (id key in [self inputKeys]) {
        id value = [self valueForInputKey:key];
        if (value != nil)
            [inputs setValue:value forKey:key];
    }
    return [[inputs copy] autorelease];
}

- (void)setValue:(id)aValue forInputKey:(id)aKey
{
    [self setValue:aValue forKey:aKey];
}

/* Returns (id)-1 when the tool has no default for the key. */
- (id)defaultValueForInputKey:(id)aKey
{
    id value = nil;
    @try {
        NSString *name = [NSString stringWithFormat:@"default%@%@", [[aKey substringToIndex:1] uppercaseString], [aKey substringFromIndex:1]];
        value = [self valueForKey:name];
    } @catch (id exception) {
        value = (id)(intptr_t)-1;
    }
    return value;
}

- (id)valueForInputKey:(id)aKey
{
    return [self valueForKey:aKey];
}

- (id)outputKeys
{
    return [NSArray array];
}

- (id)inputKeys
{
    return [NSArray arrayWithObject:@"generalKeyBindings"];
}

- (void)setGeneralKeyBindings:(id)aBindings
{
    if (_generalKeyBindings != aBindings) {
        [_generalKeyBindings autorelease];
        _generalKeyBindings = [aBindings copy];
    }
    _areGeneralKeyBindingsInitialized = 1;
}

- (id)generalKeyBindings
{
    if (!_areGeneralKeyBindingsInitialized) {
        _generalKeyBindings = [[self defaultGeneralKeyBindings] copy];
        _areGeneralKeyBindingsInitialized = 1;
    }
    return _generalKeyBindings;
}

- (id)defaultGeneralKeyBindings
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.mackiev.SMKBitmapTools"];
    if (bundle == nil)
        bundle = [NSBundle bundleForClass:[BTTool class]];
    NSString *path = [bundle pathForResource:NSStringFromClass([self class]) ofType:@"dict" inDirectory:@"DefaultKeyBindings"];
    if (path == nil)
        return nil;
    return [NSDictionary dictionaryWithContentsOfFile:path];
}

/* Both return a NULL-terminated protocol list; the base tool requires nothing. */
- (id *)optionalImageProtocols
{
    static id none[1] = { nil };
    return none;
}

- (id *)requiredImageProtocols
{
    static id none[1] = { nil };
    return none;
}

- (void)postEditWorkImageInRect:(CGRect)aRect
{
    if (_isWorkImageBeingChanged) {
        [_delegate tool:self didChangeImageInRect:aRect];
        _isWorkImageBeingChanged = 0;
    } else if (_isWorkImageBeingReplaced) {
        id image = (id)_pointer;
        _pointer = NULL;
        [self changeWorkImageTo:image];
        [image release];
        _isWorkImageBeingReplaced = 0;
        [_delegate tool:self didReplaceImageWithEffectiveChangeInRect:aRect];
    }
}

- (void)preEditWorkImage:(id)aImage inRect:(CGRect)aRect
{
    [self BTTool_preEditWorkImage:aImage inRect:&aRect];
}

- (CGRect)preEditWorkImage:(id)aImage
{
    return [self BTTool_preEditWorkImage:aImage inRect:NULL];
}

/* Editing the current image registers an undo for the rect; editing another image schedules a
   replacement that postEditWorkImageInRect: completes. Returns the rect of the new image. */
- (CGRect)BTTool_preEditWorkImage:(id)aImage inRect:(CGRect *)aRect
{
    CGRect toRect = CGRectNull;

    if (_workImage == aImage) {
        if (aRect == NULL) {
            toRect.origin = CGPointZero;
            toRect.size = [_workImage imageSize];
        } else {
            toRect = *aRect;
        }
        [_delegate tool:self willChangeImageInRect:toRect];
        [self registerWorkImageUndoInRect:toRect];
        _isWorkImageBeingChanged = 1;
        return toRect;
    }

    if (![self verifyImage:aImage])
        return toRect;

    CGRect fromRect;
    if (aRect == NULL) {
        fromRect.origin = CGPointZero;
        fromRect.size = _workImage != nil ? [_workImage imageSize] : CGSizeZero;
        toRect.origin = CGPointZero;
        toRect.size = aImage != nil ? [aImage imageSize] : CGSizeZero;
    } else {
        fromRect = *aRect;
        toRect = *aRect;
    }
    [_delegate tool:self willReplaceImageWithEffectiveChangeInRect:fromRect];
    id manager = [_delegate undoManagerForTool:self category:BTToolWorkImageUndoCategory];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:BTToolWorkImageUndoCategory withInvocationTarget:self] BTTool_changeWorkImageTo:_workImage workImageUndoerTo:_workImageUndoer withEffectiveChangeFromRect:toRect toRect:fromRect];
    _pointer = [aImage retain];
    _isWorkImageBeingReplaced = 1;
    return toRect;
}

/* The new undoer is passed through _pointer by the callers. */
- (void)changeWorkImageTo:(id)aImage
{
    if (_isWorkImageUndoGroupingBegun) {
        [_workImageUndoer endUndoGrouping];
        _isWorkImageUndoGroupingBegun = 0;
        _isWorkImageUndoGroupingScheduled = 1;
    }
    [(id)_workImageUndoer release];
    _workImageUndoer = (id)_pointer;
    [aImage retain];
    [(id)_workImage release];
    _workImage = aImage;
}

- (BOOL)setWorkImage:(id)aImage
{
    if (_workImage == aImage)
        return YES;
    if (![self verifyImage:aImage])
        return NO;
    id manager = [_delegate undoManagerForTool:self category:BTToolWorkImageUndoCategory];
    if (manager != nil) {
        CGRect fromRect = { CGPointZero, _workImage != nil ? [_workImage imageSize] : CGSizeZero };
        CGRect toRect = { CGPointZero, aImage != nil ? [aImage imageSize] : CGSizeZero };
        [[self prepareUndoInManager:manager category:BTToolWorkImageUndoCategory withInvocationTarget:self] BTTool_changeWorkImageTo:_workImage workImageUndoerTo:_workImageUndoer withEffectiveChangeFromRect:toRect toRect:fromRect];
    }
    [self changeWorkImageTo:aImage];
    return YES;
}

- (BOOL)setWorkImage:(id)aImage withEffectiveChangeInRect:(CGRect)aRect
{
    if (_workImage == aImage)
        return YES;
    if (![self verifyImage:aImage])
        return NO;
    id manager = [_delegate undoManagerForTool:self category:BTToolWorkImageUndoCategory];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:BTToolWorkImageUndoCategory withInvocationTarget:self] BTTool_changeWorkImageTo:_workImage workImageUndoerTo:_workImageUndoer withEffectiveChangeFromRect:aRect toRect:aRect];
    [self changeWorkImageTo:aImage];
    return YES;
}

- (void)BTTool_changeWorkImageTo:(id)aImage workImageUndoerTo:(id)aUndoer withEffectiveChangeFromRect:(CGRect)aFromRect toRect:(CGRect)aToRect
{
    [_delegate tool:self willReplaceImageWithEffectiveChangeInRect:aFromRect];
    id manager = [_delegate undoManagerForTool:self category:BTToolWorkImageUndoCategory];
    if (manager != nil)
        [[self prepareUndoInManager:manager category:BTToolWorkImageUndoCategory withInvocationTarget:self] BTTool_changeWorkImageTo:_workImage workImageUndoerTo:_workImageUndoer withEffectiveChangeFromRect:aToRect toRect:aFromRect];
    _pointer = [aUndoer retain];
    [self changeWorkImageTo:aImage];
    _pointer = NULL;
    [_delegate tool:self didReplaceImageWithEffectiveChangeInRect:aToRect];
}

- (BOOL)verifyImage:(id)aImage
{
    if (aImage == nil)
        return YES;
    for (Protocol **p = (Protocol **)[self requiredImageProtocols]; *p != nil; p++)
        if (![aImage conformsToProtocol:*p])
            return NO;
    return YES;
}

- (id)workImage
{
    return _workImage;
}

- (void)dealloc
{
    [(id)_workImage release];
    [(id)_workImageUndoer release];
    [_workPasteboard release];
    CGContextRelease(_referenceCGContext);
    [_generalKeyBindings release];
    [_undoProxies release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _isViewInvalidationEnabled = 1;
    return self;
}

@end
