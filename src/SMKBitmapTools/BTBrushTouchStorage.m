#import "BTBrushTouchStorage.h"
#import "BTPointer.h"
#import "NSApplication+BTEvents.h"
#import "NSEvent+BTLocation.h"
#import "NSView+BTMouseTracking.h"

/* Touches recorded by a brush, kept in one data block. Each touch is its
   position, size, rotation angle and opacity deviations (CGFloats), then the
   four color deviations (an NSUInteger count followed by that many CGFloats:
   HSVA, native, shadow HSVA, shadow native) and the alternate color flag (an
   NSUInteger); _touchDataOffsets holds each touch's offset. Archives store
   doubles and unsigned long longs, so they don't depend on the layout. */
@implementation BTBrushTouchStorage

#define BTBrushTouchStorageDeviationCount 4

static NSData *BTBrushTouchStorageReadDeviation(const uint8_t **aCursor)
{
    NSUInteger count = *(const NSUInteger *)*aCursor;
    *aCursor += sizeof(NSUInteger);
    NSData *data = count != 0 ? [NSMutableData dataWithBytes:*aCursor length:count * sizeof(CGFloat)] : nil;
    *aCursor += count * sizeof(CGFloat);
    return data;
}

- (void)position:(CGPoint *)aPosition sizeDeviation:(CGSize *)aSizeDeviation rotationAngleDeviation:(CGFloat *)aAngleDeviation opacityDeviation:(CGFloat *)aOpacityDeviation alternateColor:(BOOL *)aAlternate colorHSVADeviation:(id *)aColorHSVA colorNativeDeviation:(id *)aColorNative shadowColorHSVADeviation:(id *)aShadowHSVA shadowColorNativeDeviation:(id *)aShadowNative forTouchAtIndex:(NSUInteger)aIndex
{
    NSUInteger offset = ((const NSUInteger *)[_touchDataOffsets bytes])[aIndex];
    const uint8_t *touch = (const uint8_t *)[_touchesData bytes] + offset;
    const CGFloat *values = (const CGFloat *)touch;
    if (aPosition != NULL)
        *aPosition = CGPointMake(values[0], values[1]);
    if (aSizeDeviation != NULL)
        *aSizeDeviation = CGSizeMake(values[2], values[3]);
    if (aAngleDeviation != NULL)
        *aAngleDeviation = values[4];
    if (aOpacityDeviation != NULL)
        *aOpacityDeviation = values[5];
    const uint8_t *cursor = touch + 6 * sizeof(CGFloat);
    id *outputs[BTBrushTouchStorageDeviationCount] = { aColorHSVA, aColorNative, aShadowHSVA, aShadowNative };
    for (int i = 0; i < BTBrushTouchStorageDeviationCount; i++) {
        NSData *deviation = BTBrushTouchStorageReadDeviation(&cursor);
        if (outputs[i] != NULL)
            *outputs[i] = deviation;
    }
    if (aAlternate != NULL)
        *aAlternate = (*(const NSUInteger *)cursor & 1) != 0;
}

- (NSUInteger)numberOfTouches
{
    return [_touchDataOffsets length] / sizeof(NSUInteger);
}

- (CGRect)boundingRectForToolSize:(CGSize)aSize rotationAngle:(CGFloat)aAngle shadowOffset:(CGSize)aShadowOffset shadowBlurRadius:(CGFloat)aBlurRadius
{
    NSUInteger count = [self numberOfTouches];
    if (count == 0)
        return CGRectNull;
    CGRect r = [self boundingRectOfTouchAtIndex:0 forToolSize:aSize rotationAngle:aAngle shadowOffset:aShadowOffset shadowBlurRadius:aBlurRadius];
    for (NSUInteger i = 1; i < count; i++)
        r = CGRectUnion(r, [self boundingRectOfTouchAtIndex:i forToolSize:aSize rotationAngle:aAngle shadowOffset:aShadowOffset shadowBlurRadius:aBlurRadius]);
    return r;
}

/* The tool-sized rect around the touch, rotated about it, with its shadow
   (offset, and grown by the blur radius unless that is NaN). */
- (CGRect)boundingRectOfTouchAtIndex:(NSUInteger)aIndex forToolSize:(CGSize)aSize rotationAngle:(CGFloat)aAngle shadowOffset:(CGSize)aShadowOffset shadowBlurRadius:(CGFloat)aBlurRadius
{
    CGPoint p = CGPointZero;
    CGSize deviation = CGSizeZero;
    CGFloat angleDeviation = 0.0;
    [self position:&p sizeDeviation:&deviation rotationAngleDeviation:&angleDeviation opacityDeviation:NULL alternateColor:NULL
        colorHSVADeviation:NULL colorNativeDeviation:NULL shadowColorHSVADeviation:NULL shadowColorNativeDeviation:NULL forTouchAtIndex:aIndex];
    CGFloat angle = angleDeviation + aAngle;
    CGFloat s = sin(angle), c = cos(angle);
    CGAffineTransform m = { c, s, -s, c, (1.0 - c) * p.x + s * p.y, (1.0 - c) * p.y - s * p.x };
    CGFloat width = (deviation.width + 1.0) * aSize.width;
    CGFloat height = (deviation.height + 1.0) * aSize.height;
    CGRect r = CGRectMake(p.x + width * -0.5, p.y + height * -0.5, width, height);
    if (isnan(aBlurRadius)) {
        CGRect shadow = CGRectOffset(r, aShadowOffset.width, aShadowOffset.height);
        return CGRectUnion(CGRectApplyAffineTransform(r, m), CGRectApplyAffineTransform(shadow, m));
    }
    r = CGRectApplyAffineTransform(r, m);
    CGRect shadow = CGRectMake(r.origin.x - aBlurRadius + aShadowOffset.width, r.origin.y - aBlurRadius + aShadowOffset.height,
                               r.size.width + aBlurRadius + aBlurRadius, r.size.height + aBlurRadius + aBlurRadius);
    return CGRectUnion(r, shadow);
}

- (void)applyAffineTransform:(CGAffineTransform)aTransform
{
    const NSUInteger *offsets = [_touchDataOffsets bytes];
    uint8_t *touches = [_touchesData mutableBytes];
    NSUInteger count = [self numberOfTouches];
    for (NSUInteger i = 0; i < count; i++) {
        CGFloat *p = (CGFloat *)(touches + offsets[i]);
        CGPoint q = CGPointApplyAffineTransform(CGPointMake(p[0], p[1]), aTransform);
        p[0] = q.x;
        p[1] = q.y;
    }
}

static void BTBrushTouchStorageAppendDeviation(NSMutableData *aData, NSData *aDeviation)
{
    NSUInteger count = [aDeviation length] / sizeof(CGFloat);
    [aData appendBytes:&count length:sizeof(count)];
    if (count != 0)
        [aData appendData:aDeviation];
}

- (void)addTouchAtPoint:(CGPoint)aPoint withSizeDeviation:(CGSize)aSizeDeviation rotationAngleDeviation:(CGFloat)aAngleDeviation opacityDeviation:(CGFloat)aOpacityDeviation alternateColor:(BOOL)aAlternate colorHSVADeviation:(id)aColorHSVA colorNativeDeviation:(id)aColorNative shadowColorHSVADeviation:(id)aShadowHSVA shadowColorNativeDeviation:(id)aShadowNative
{
    NSUInteger offset = [_touchesData length];
    [_touchDataOffsets appendBytes:&offset length:sizeof(offset)];
    const CGFloat values[6] = { aPoint.x, aPoint.y, aSizeDeviation.width, aSizeDeviation.height, aAngleDeviation, aOpacityDeviation };
    [_touchesData appendBytes:values length:sizeof(values)];
    BTBrushTouchStorageAppendDeviation(_touchesData, aColorHSVA);
    BTBrushTouchStorageAppendDeviation(_touchesData, aColorNative);
    BTBrushTouchStorageAppendDeviation(_touchesData, aShadowHSVA);
    BTBrushTouchStorageAppendDeviation(_touchesData, aShadowNative);
    NSUInteger alternate = aAlternate ? 1 : 0;
    [_touchesData appendBytes:&alternate length:sizeof(alternate)];
}

- (id)copyWithZone:(NSZone *)aZone
{
    BTBrushTouchStorage *copy = [[BTBrushTouchStorage allocWithZone:aZone] init];
    [copy->_touchDataOffsets setData:_touchDataOffsets];
    [copy->_touchesData setData:_touchesData];
    return copy;
}

- (void)dealloc
{
    [_touchDataOffsets release];
    [_touchesData release];
    [super dealloc];
}

/* Version 0: the touch count, then per touch six doubles, the four color
   deviations (a count, then that many doubles) and the alternate flag. */
- (id)initWithCoder:(id)aCoder
{
    self = [super init];
    if (self == nil)
        return nil;
    unsigned long long value = 0;
    [aCoder decodeValueOfObjCType:"Q" at:&value];
    if (value != 0) {
        [self release];
        return nil;
    }
    [aCoder decodeValueOfObjCType:"Q" at:&value];
    NSUInteger count = (NSUInteger)value;
    _touchDataOffsets = [[NSMutableData alloc] initWithLength:count * sizeof(NSUInteger)];
    _touchesData = [[NSMutableData alloc] init];
    if (_touchDataOffsets == nil || _touchesData == nil) {
        [self release];
        return nil;
    }
    NSUInteger *offsets = [_touchDataOffsets mutableBytes];
    for (NSUInteger i = 0; i < count; i++) {
        offsets[i] = [_touchesData length];
        for (int j = 0; j < 6; j++) {
            double d = 0.0;
            [aCoder decodeValueOfObjCType:"d" at:&d];
            CGFloat f = d;
            [_touchesData appendBytes:&f length:sizeof(f)];
        }
        [aCoder decodeValueOfObjCType:"Q" at:&value];
        for (int j = 0; j < BTBrushTouchStorageDeviationCount; j++) {
            NSUInteger n = (NSUInteger)value;
            [_touchesData appendBytes:&n length:sizeof(n)];
            for (NSUInteger k = 0; k < n; k++) {
                double d = 0.0;
                [aCoder decodeValueOfObjCType:"d" at:&d];
                CGFloat f = d;
                [_touchesData appendBytes:&f length:sizeof(f)];
            }
            [aCoder decodeValueOfObjCType:"Q" at:&value];
        }
        NSUInteger alternate = (NSUInteger)value;
        [_touchesData appendBytes:&alternate length:sizeof(alternate)];
    }
    return self;
}

- (void)encodeWithCoder:(id)aCoder
{
    unsigned long long value = 0;
    [aCoder encodeValueOfObjCType:"Q" at:&value];
    NSUInteger count = [self numberOfTouches];
    value = count;
    [aCoder encodeValueOfObjCType:"Q" at:&value];
    const NSUInteger *offsets = [_touchDataOffsets bytes];
    const uint8_t *touches = [_touchesData bytes];
    for (NSUInteger i = 0; i < count; i++) {
        const CGFloat *values = (const CGFloat *)(touches + offsets[i]);
        for (int j = 0; j < 6; j++) {
            double d = values[j];
            [aCoder encodeValueOfObjCType:"d" at:&d];
        }
        const uint8_t *cursor = touches + offsets[i] + 6 * sizeof(CGFloat);
        for (int j = 0; j < BTBrushTouchStorageDeviationCount; j++) {
            NSUInteger n = *(const NSUInteger *)cursor;
            cursor += sizeof(NSUInteger);
            value = n;
            [aCoder encodeValueOfObjCType:"Q" at:&value];
            for (NSUInteger k = 0; k < n; k++) {
                double d = ((const CGFloat *)cursor)[k];
                [aCoder encodeValueOfObjCType:"d" at:&d];
            }
            cursor += n * sizeof(CGFloat);
        }
        value = *(const NSUInteger *)cursor;
        [aCoder encodeValueOfObjCType:"Q" at:&value];
    }
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;
    _touchDataOffsets = [[NSMutableData alloc] init];
    _touchesData = [[NSMutableData alloc] init];
    if (_touchDataOffsets == nil || _touchesData == nil) {
        [self release];
        return nil;
    }
    return self;
}

@end

/* A brush paints by stamping a pad (the image, or the color filled through the
   shape and mask, with overlays and a shadow) at touches spaced along the drag.
   Pads that don't vary from touch to touch are cached in a layer per color. */
@implementation BTBrushTool

static void BTBrushToolReleasePadLayers(BTBrushTool *self)
{
    CGLayerRelease(self->_padLayer);
    self->_padLayer = NULL;
    CGLayerRelease(self->_alternatePadLayer);
    self->_alternatePadLayer = NULL;
}

/* The pen's eraser end counts as asking for the alternate color. */
static BOOL BTBrushToolWantsAlternateColor(NSUInteger aFlags, NSUInteger aOption, NSUInteger aPointingDeviceType)
{
    return BTModifierFlagsMatchOption(aFlags, aOption) || aPointingDeviceType == NSEraserPointingDevice;
}

static size_t BTBrushToolPixelCount(CGFloat aLength)
{
    return aLength > 0.0 ? (size_t)lround(ceil(aLength)) : 0;
}

/* An 8-bit gray context of a whole number of pixels covering the size. */
static CGContextRef BTBrushToolCreateGrayContext(CGFloat aWidth, CGFloat aHeight)
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
    if (space == NULL)
        return NULL;
    size_t width = BTBrushToolPixelCount(aWidth);
    CGContextRef context = CGEBitmapContextCreate(NULL, width, BTBrushToolPixelCount(aHeight), 8,
        (width + 15) & ~(size_t)15, space, 0);
    CGColorSpaceRelease(space);
    return context;
}

static CGImageRef BTBrushToolCreateMaskFromGrayContext(CGContextRef aContext)
{
    static const CGFloat decode[2] = { 1.0, 0.0 };
    return CGEBitmapContextCreateImageMaskNoCopy(aContext, decode, true);
}

+ (struct CGImage *)BTBrushTool_createMaskFromImage:(id)aImage
{
    NSSize size = [aImage imageSize];
    CGContextRef context = BTBrushToolCreateGrayContext(size.width, size.height);
    if (context == NULL)
        return NULL;
    [aImage drawInCGContext:context atPoint:CGPointZero];
    CGImageRef mask = BTBrushToolCreateMaskFromGrayContext(context);
    CGContextRelease(context);
    return mask;
}

+ (NSInteger)BTBrushTool_blendModeForName:(id)aName
{
    static NSMapTable *modes = nil;
    if (modes == nil) {
        modes = NSCreateMapTable(NSObjectMapKeyCallBacks, NSIntegerMapValueCallBacks, 16);
        if (modes == nil)
            return kCGBlendModeNormal;
        NSString *names[] = { @"Normal", @"Multiply", @"Screen", @"Overlay", @"Darken", @"Lighten",
            @"Color Dodge", @"Color Burn", @"Soft Light", @"Hard Light", @"Difference", @"Exclusion",
            @"Hue", @"Saturation", @"Color", @"Luminosity" };
        for (NSInteger i = 0; i < 16; i++)
            NSMapInsert(modes, names[i], (void *)i);
    }
    void *mode = (void *)kCGBlendModeNormal;
    NSMapMember(modes, aName, NULL, &mode);
    return (NSInteger)mode;
}

/* The color's opaque RGB as drawn into one generic RGB pixel, with its own alpha. */
+ (id)BTBrushTool_cocoaColorForCoreGraphicsColor:(struct CGColor *)aColor
{
    static CGContextRef pixelContext = NULL;
    static uint8_t pixel[4];
    if (CGColorGetPattern(aColor) != NULL)
        return nil;
    if (pixelContext == NULL) {
        CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        if (space == NULL)
            return nil;
        pixelContext = CGBitmapContextCreate(pixel, 1, 1, 8, 4, space, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
        CGColorSpaceRelease(space);
        if (pixelContext == NULL)
            return nil;
    }
    CGColorRef opaque = CGColorCreateCopyWithAlpha(aColor, 1.0);
    if (opaque == NULL)
        return nil;
    CGContextSetFillColorWithColor(pixelContext, opaque);
    CGContextFillRect(pixelContext, CGRectMake(0.0, 0.0, 1.0, 1.0));
    CGColorRelease(opaque);
    return [NSColor colorWithCalibratedRed:pixel[0] / 255.0 green:pixel[1] / 255.0 blue:pixel[2] / 255.0
        alpha:CGColorGetAlpha(aColor)];
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

- (void)haltWithMouseUp:(id)aUp inView:(id)aView
{
    if (_view == aView)
        [[_delegate mouseTrackingDelegateForTool:self] haltWithMouseUp:aUp inView:aView];
}

/* Releasing the color picking keys mid-drag starts painting from there. */
- (void)trackFlagsChanged:(id)aChanged inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackFlagsChanged:aChanged inView:aView];
    if (!_isColorPicking)
        return;
    NSUInteger flags = [aChanged modifierFlags];
    _isUsingAlternateColor = BTBrushToolWantsAlternateColor(flags, _alternateColorOption, [NSApp BT_effectivePointingDeviceType]);
    if (BTModifierFlagsMatchOption(flags, _colorPickingOption))
        return;
    _isColorPicking = 0;
    _isDrawing = 1;
    [_delegate tool:self didFinalizeOutputForKey:@"alternateColor"];
    [_delegate tool:self didFinalizeOutputForKey:@"color"];
    [self BTBrushTool_beginDrawing];
}

- (void)trackMouseUp:(id)aUp inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseUp:aUp inView:aView];
    if (_isDrawing) {
        [self endWorkImageUndoGrouping];
        CGEColorRef color = _isUsingAlternateColor ? _alternateColor : _color;
        [self endUndoActionWithName:_image != nil || color != NULL ? @"Paint" : @"Erase"];
        [_delegate toolDidEndChangingImageContinuously:self];
        [_touchTimer invalidate];
        [_touchTimer release];
        _touchTimer = nil;
    } else {
        [_delegate tool:self didFinalizeOutputForKey:@"alternateColor"];
        [_delegate tool:self didFinalizeOutputForKey:@"color"];
    }
    NSUInteger flags = [aUp modifierFlags];
    _isUsingAlternateColor = BTBrushToolWantsAlternateColor(flags, _alternateColorOption, [aUp BT_pointingDeviceType]);
    _isColorPicking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    _isTracking = 0;
}

/* A pressure of 0 from a mouse (no pointing device) paints at full pressure. */
static CGFloat BTBrushToolEventPressure(NSEvent *aEvent)
{
    float pressure = [aEvent pressure];
    if (pressure == 0.0f && [aEvent BT_pointingDeviceType] == 0)
        return 1.0;
    return pressure;
}

- (void)trackMouseDragged:(id)aDragged inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDragged:aDragged inView:aView];
    NSPoint start = [self convertImagePointToViewPoint:_imageStartPoint];
    NSPoint location = [self eventLocationInView:aDragged];
    CGPoint guided = [self guideMovementFromPoint:NSPointToCGPoint(start) toPoint:NSPointToCGPoint(location)
        centeringOnDevicePixel:YES inMode:(char *)&_guidingMode withEvent:aDragged];
    NSPoint point = [self convertViewPointToImagePoint:NSPointFromCGPoint(guided)];
    if (_isColorPicking)
        [self BTBrushTool_pickColorAtPoint:point];
    else
        [self BTBrushTool_drawToPoint:point withPressure:BTBrushToolEventPressure(aDragged)];
    _imageStartPoint = point;
}

/* Shift guides the drag along horizontals, verticals and diagonals. */
- (void)trackMouseDown:(id)aDown inView:(id)aView
{
    if (_view != aView)
        return;
    [[_delegate mouseTrackingDelegateForTool:self] trackMouseDown:aDown inView:aView];
    _isTracking = 1;
    _guidingMode = ([aDown modifierFlags] & NSShiftKeyMask) != 0 ? 0xff : 0;
    CGPoint location = NSPointToCGPoint([self eventLocationInView:aDown]);
    [self snapPoint:&location asDevicePixelCenter:YES withinBoundsWithMinX:-INFINITY maxX:INFINITY
        minY:-INFINITY maxY:INFINITY alongTrajectoryLine:CGELineUndefined withEvent:aDown options:nil];
    _imageStartPoint = [self convertViewPointToImagePoint:NSPointFromCGPoint(location)];
    if (_isColorPicking)
        return;
    _isDrawing = 1;
    [self BTBrushTool_beginDrawing];
    [self BTBrushTool_drawToPoint:_imageStartPoint withPressure:BTBrushToolEventPressure(aDown)];
}

- (void)BTBrushTool_beginDrawing
{
    NSCursor *cursor;
    if (_isUsingAlternateColor && _alternateColor != NULL) {
        cursor = [self doAlternateDrawCursor];
        if (_doDrawCursorShapeContour != NULL)
            cursor = [self BTBrushTool_doAlternateDrawShapeContourCursor:cursor];
    } else {
        cursor = [self doDrawCursor];
        if (_doDrawCursorShapeContour != NULL)
            cursor = [self BTBrushTool_doDrawShapeContourCursor:cursor];
    }
    [cursor set];
    [_delegate toolWillBeginChangingImageContinuously:self];
    [self beginUndoAction];
    [self beginWorkImageUndoGrouping];
    [self BTBrushTool_scheduleTouchTimerIfNeeded];
}

/* Holding still keeps painting at the last point while there is a touch interval. */
- (void)BTBrushTool_touchByTimer:(id)aTimer
{
    [self BTBrushTool_drawToPoint:_imageStartPoint withPressure:1.0];
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

- (BOOL)isFeedbackLayerActive:(id)aActive
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

- (BOOL)flagsChanged:(id)aChanged
{
    NSUInteger flags = [aChanged modifierFlags];
    BOOL alternate = BTBrushToolWantsAlternateColor(flags, _alternateColorOption, [NSApp BT_effectivePointingDeviceType]);
    BOOL picking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    if (alternate == (BOOL)_isUsingAlternateColor && picking == (BOOL)_isColorPicking)
        return NO;
    _isUsingAlternateColor = alternate;
    _isColorPicking = picking;
    [_delegate tool:self didUpdateCursorWithEvent:aChanged];
    return YES;
}

- (BOOL)mouseDown:(id)aDown
{
    if ([self workImage] == nil)
        return NO;
    BOOL handled = [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:aDown nextStage:@"BTDrawingToolStage"];
    if (![self isActive])
        return handled;
    NSUInteger flags = [aDown modifierFlags];
    _isUsingAlternateColor = BTBrushToolWantsAlternateColor(flags, _alternateColorOption, [aDown BT_pointingDeviceType]);
    if (BTModifierFlagsMatchOption(flags, _colorPickingOption))
        [self BTBrushTool_pickColorAtPoint:[self eventLocationInImage:aDown]];
    id lastEvent = [_view BT_trackMouseWithEvent:aDown tracker:self startDelay:0.0];
    [_delegate tool:self didFinalizeStage:@"BTDrawingToolStage" withEvent:lastEvent nextStage:nil];
    if ([self isActive]) {
        _isDrawing = 0;
        [_delegate tool:self didUpdateCursorWithEvent:lastEvent];
    }
    return YES;
}

- (BOOL)BTBrushTool_pickColorAtPoint:(NSPoint)aPoint
{
    id image = [self workImage];
    id color = image != nil ? (id)[image colorAtPoint:aPoint] : nil;
    if (color == nil)
        return NO;
    NSString *key = _isUsingAlternateColor ? @"alternateColor" : @"color";
    [_delegate tool:self willUpdateOutputForKey:key];
    if (_isUsingAlternateColor)
        [self setAlternateColor:color];
    else
        [self setColor:color];
    [_delegate tool:self didUpdateOutputForKey:key];
    return YES;
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    if (!_isDrawing && BTModifierFlagsMatchOption(aFlags, _colorPickingOption))
        return [self pickColorCursor];
    if (_alternateColor != NULL && BTBrushToolWantsAlternateColor(aFlags, _alternateColorOption, [NSApp BT_effectivePointingDeviceType])) {
        NSCursor *cursor = [self willAlternateDrawCursor];
        return _willDrawCursorShapeContour != NULL ? [self BTBrushTool_willAlternateDrawShapeContourCursor:cursor] : cursor;
    }
    NSCursor *cursor = [self willDrawCursor];
    return _willDrawCursorShapeContour != NULL ? [self BTBrushTool_willDrawShapeContourCursor:cursor] : cursor;
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
    [_touchTimer invalidate];
    [_touchTimer release];
    _touchTimer = nil;
    CGLayerRelease(_padLayer);
    _padLayer = NULL;
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
    _isUsingAlternateColor = BTBrushToolWantsAlternateColor(flags, _alternateColorOption, [NSApp BT_effectivePointingDeviceType]);
    _isColorPicking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    return YES;
}

/* Consumers are counted: each start needs a matching stop. */
- (void)stopRecordTouchesWithConsumer:(id)aConsumer
{
    if (_touchConsumers == nil)
        return;
    NSInteger count = (NSInteger)NSMapGet(_touchConsumers, aConsumer);
    if (count == 0)
        return;
    if (count == 1)
        NSMapRemove(_touchConsumers, aConsumer);
    else
        NSMapInsert(_touchConsumers, aConsumer, (void *)(count - 1));
}

- (void)startRecordTouchesWithConsumer:(id)aConsumer
{
    if (_touchConsumers == nil) {
        _touchConsumers = NSCreateMapTable(BTObjectPointerMapKeyCallBacks, NSIntegerMapValueCallBacks, 0);
        if (_touchConsumers == nil)
            return;
    }
    NSInteger count = (NSInteger)NSMapGet(_touchConsumers, aConsumer);
    NSMapInsert(_touchConsumers, aConsumer, (void *)(count + 1));
}

- (CGRect)recordAlongPolylineWithPoints:(CGPoint *)aPoints count:(NSUInteger)aCount withAlternateColor:(BOOL)aColor withPressure:(CGFloat)aPressure to:(id)aTo
{
    if (aCount == 0)
        return CGRectZero;
    if (aCount == 1)
        return [self BTBrushTool_recordTouchesFromPoint:aPoints[0] toPoint:aPoints[0] withAlternateColor:aColor
            withPressure:aPressure toStorage:aTo consumers:NO];
    CGRect bounds = [self BTBrushTool_recordTouchesFromPoint:aPoints[0] toPoint:aPoints[1] withAlternateColor:aColor
        withPressure:aPressure toStorage:aTo consumers:NO];
    for (NSUInteger i = 2; i < aCount; i++)
        bounds = CGRectUnion(bounds, [self BTBrushTool_recordTouchesFromPoint:aPoints[i - 1] toPoint:aPoints[i]
            withAlternateColor:aColor withPressure:aPressure toStorage:aTo consumers:NO]);
    return bounds;
}

- (void)drawWithTouchProvider:(id)aProvider inContext:(struct CGContext *)aContext withBounds:(CGRect)aBounds
{
    [self BTBrushTool_drawWithTouchProvider:aProvider inContext:aContext withBounds:aBounds];
}

/* Paints the touches from the last point to this one into the work image. */
- (void)BTBrushTool_drawToPoint:(NSPoint)aPoint withPressure:(CGFloat)aPressure
{
    BTBrushTouchStorage *storage = [[[BTBrushTouchStorage alloc] init] autorelease];
    if (storage == nil)
        return;
    CGRect touched = [self BTBrushTool_recordTouchesFromPoint:NSPointToCGPoint(_imageStartPoint) toPoint:NSPointToCGPoint(aPoint)
        withAlternateColor:_isUsingAlternateColor withPressure:aPressure toStorage:storage consumers:YES];
    id image = [self workImage];
    if (image == nil)
        return;
    NSSize imageSize = [image imageSize];
    CGRect imageBounds = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    CGRect rect = CGRectIntersection(imageBounds, CGRectIntegral(CGRectInset(touched, -0.95, -0.95)));
    if (CGRectIsEmpty(rect))
        return;
    [self preEditWorkImage:image inRect:rect];
    [image beginCGEditing];
    CGContextRef context = [image imageCGContext];
    if (context != NULL)
        [self BTBrushTool_drawWithTouchProvider:storage inContext:context withBounds:imageBounds];
    [image endCGEditing];
    [self postEditWorkImageInRect:rect];
}

static CGFloat BTBrushToolDeviation(BTBrushTool *self, CGFloat aOscillation)
{
    CGFloat factor = [self BTBrushTool_randomFactor];
    return (factor + factor - 1.0) * aOscillation;
}

/* Spreads touches from one point to the other by the spacing (a fraction of the
   brush size along the way), randomizing each by the oscillations; lighter
   pressure makes touches smaller and more transparent. Returns the area the
   touches cover, shadows included. */
- (CGRect)BTBrushTool_recordTouchesFromPoint:(CGPoint)aPoint toPoint:(CGPoint)aPoint2 withAlternateColor:(BOOL)aColor withPressure:(CGFloat)aPressure toStorage:(id)aStorage consumers:(BOOL)aConsumers
{
    CGFloat dx = aPoint2.x - aPoint.x, dy = aPoint2.y - aPoint.y;
    CGFloat length = hypot(dx, dy);
    CGFloat step;
    BOOL fixedStep;
    if (_spacing <= 0.0 || length == 0.0) {
        step = 1.0;
        fixedStep = YES;
    } else if (_spacingOscillation == 0.0) {
        step = fmin(_spacing / length, 1.0);
        fixedStep = YES;
    } else {
        step = 1.0;
        fixedStep = NO;
    }
    CGFloat lightness = 1.0 - aPressure;
    CGFloat sizeLoss = lightness * 0.45;
    CGFloat minX = DBL_MAX, minY = DBL_MAX, maxX = -DBL_MAX, maxY = -DBL_MAX;
    CGFloat t = 0.0;
    do {
        if (!fixedStep) {
            CGFloat spacing = fmax(BTBrushToolDeviation(self, _spacingOscillation) + _spacing, 0.01);
            step = fmin(spacing / length, 1.0);
        }
        t = fmin(t + step, 1.0);
        CGFloat x = t * dx + aPoint.x, y = t * dy + aPoint.y;
        if (_positionOscillation.width != 0.0)
            x += BTBrushToolDeviation(self, _positionOscillation.width);
        if (_positionOscillation.height != 0.0)
            y += BTBrushToolDeviation(self, _positionOscillation.height);
        CGFloat widthFactor = [self BTBrushTool_randomFactor];
        CGFloat heightFactor = [self BTBrushTool_randomFactor];
        CGFloat angleFactor = [self BTBrushTool_randomFactor];
        CGFloat opacityFactor = [self BTBrushTool_randomFactor];
        NSData *colorHSVA = nil, *colorNative = nil, *shadowHSVA = nil, *shadowNative = nil;
        [self BTBrushTool_colorHSVADeviation:&colorHSVA nativeDeviation:&colorNative
            withHSVAOscillation:_colorHSVAOscillation nativeOscillation:_colorNativeOscillation];
        [self BTBrushTool_colorHSVADeviation:&shadowHSVA nativeDeviation:&shadowNative
            withHSVAOscillation:_shadowColorHSVAOscillation nativeOscillation:_shadowColorNativeOscillation];
        CGFloat opacityDeviation = (opacityFactor + opacityFactor - 1.0) * _opacityOscillation - sqrt(lightness);
        CGFloat angleDeviation = (angleFactor + angleFactor - 1.0) * _rotationAngleOscillation;
        CGSize sizeDeviation = CGSizeMake((widthFactor + widthFactor - 1.0) * _sizeOscillation.width - sizeLoss,
            (heightFactor + heightFactor - 1.0) * _sizeOscillation.height - sizeLoss);
        CGPoint point = CGPointMake(x, y);
        [aStorage addTouchAtPoint:point withSizeDeviation:sizeDeviation rotationAngleDeviation:angleDeviation
            opacityDeviation:opacityDeviation alternateColor:aColor colorHSVADeviation:colorHSVA colorNativeDeviation:colorNative
            shadowColorHSVADeviation:shadowHSVA shadowColorNativeDeviation:shadowNative];
        if (aConsumers)
            [self BTBrushTool_recordTouchAtPoint:point withSizeDeviation:sizeDeviation rotationAngleDeviation:angleDeviation
                opacityDeviation:opacityDeviation alternateColor:aColor colorHSVADeviation:colorHSVA colorNativeDeviation:colorNative
                shadowColorHSVADeviation:shadowHSVA shadowColorNativeDeviation:shadowNative];
        CGFloat angle = angleDeviation + _rotationAngle;
        CGFloat sine = sin(angle), cosine = cos(angle);
        CGFloat width = (sizeDeviation.width + 1.0) * _size.width, height = (sizeDeviation.height + 1.0) * _size.height;
        CGAffineTransform rotation = CGAffineTransformMake(cosine, sine, -sine, cosine,
            (1.0 - cosine) * x + sine * y, (1.0 - cosine) * y - sine * x);
        CGRect rect = CGRectMake(x - width * 0.5, y - height * 0.5, width, height);
        BOOL shadowMaskPresent = [self BTBrushTool_isShadowMaskPresent];
        if (_shadowColor != NULL && shadowMaskPresent) {
            CGRect shadowRect = CGRectOffset(rect, _shadowOffset.width, _shadowOffset.height);
            rect = CGRectUnion(CGRectApplyAffineTransform(shadowRect, rotation), CGRectApplyAffineTransform(rect, rotation));
        } else
            rect = CGRectApplyAffineTransform(rect, rotation);
        CGFloat left = rect.origin.x, bottom = rect.origin.y;
        CGFloat right = rect.origin.x + rect.size.width, top = rect.origin.y + rect.size.height;
        if (_shadowColor != NULL && !shadowMaskPresent) {
            CGFloat blur = _shadowBlurRadius, offset = _shadowOffset.width;
            if (offset < 0.0) {
                if (blur + offset > 0.0)
                    right += blur + offset;
                left += offset - blur;
            } else {
                if (blur - offset > 0.0)
                    left -= blur - offset;
                right += offset + blur;
            }
            offset = _shadowOffset.height;
            if (offset < 0.0) {
                if (blur + offset > 0.0)
                    top += blur + offset;
                bottom += offset - blur;
            } else {
                if (blur - offset > 0.0)
                    bottom -= blur - offset;
                top += offset + blur;
            }
        }
        maxY = fmax(top, maxY);
        minY = fmin(bottom, minY);
        maxX = fmax(right, maxX);
        minX = fmin(left, minX);
    } while (t < 1.0);
    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

/* Hands the touch to every consumer; a consumer's exception is logged and ignored. */
- (void)BTBrushTool_recordTouchAtPoint:(CGPoint)aPoint withSizeDeviation:(CGSize)aDeviation rotationAngleDeviation:(CGFloat)aDeviation2 opacityDeviation:(CGFloat)aDeviation3 alternateColor:(BOOL)aColor colorHSVADeviation:(id)aDeviation4 colorNativeDeviation:(id)aDeviation5 shadowColorHSVADeviation:(id)aDeviation6 shadowColorNativeDeviation:(id)aDeviation7
{
    if (_touchConsumers == nil)
        return;
    NSMapEnumerator enumerator = NSEnumerateMapTable(_touchConsumers);
    id consumer = nil;
    while (NSNextMapEnumeratorPair(&enumerator, (void **)&consumer, NULL)) {
        @try {
            [consumer addTouchAtPoint:aPoint withSizeDeviation:aDeviation rotationAngleDeviation:aDeviation2
                opacityDeviation:aDeviation3 alternateColor:aColor colorHSVADeviation:aDeviation4
                colorNativeDeviation:aDeviation5 shadowColorHSVADeviation:aDeviation6 shadowColorNativeDeviation:aDeviation7];
        } @catch (id exception) {
            NSLog(@"Exception was raised while providing touch data to a consumer. Ignored.");
            NSLog(@"%@", exception);
        }
    }
    NSEndMapTableEnumeration(&enumerator);
}

- (void)BTBrushTool_drawWithTouchProvider:(id)aProvider inContext:(struct CGContext *)aContext withBounds:(CGRect)aBounds
{
    NSUInteger count = [aProvider numberOfTouches];
    for (NSUInteger i = 0; i < count; i++) {
        CGPoint position = CGPointZero;
        CGSize sizeDeviation = CGSizeZero;
        CGFloat angleDeviation = 0.0, opacityDeviation = 0.0;
        BOOL alternate = NO;
        id colorHSVA = nil, colorNative = nil, shadowHSVA = nil, shadowNative = nil;
        [aProvider position:&position sizeDeviation:&sizeDeviation rotationAngleDeviation:&angleDeviation
            opacityDeviation:&opacityDeviation alternateColor:&alternate colorHSVADeviation:&colorHSVA
            colorNativeDeviation:&colorNative shadowColorHSVADeviation:&shadowHSVA shadowColorNativeDeviation:&shadowNative
            forTouchAtIndex:i];
        [self BTBrushTool_drawTouchAtPoint:position withSizeDeviation:sizeDeviation rotationAngleDeviation:angleDeviation
            opacityDeviation:opacityDeviation alternateColor:alternate colorHSVADeviation:colorHSVA colorNativeDeviation:colorNative
            shadowColorHSVADeviation:shadowHSVA shadowColorNativeDeviation:shadowNative inContext:aContext withBounds:aBounds];
    }
}

static BOOL BTBrushToolScaleDiffers(CGFloat aCached, CGFloat aScale)
{
    return aCached < aScale - 0.0001 || aScale + 0.0001 < aCached;
}

/* Stamps one touch: rotated (and flipped) about its center, then either drawn
   directly when it varies (deviated or gradient colors, a varied size, a blurred
   shadow on a rotated pad) or from the cached pad layer of its color. With no
   image and no color the touch erases. As in the original, a cached pad only
   carries a masked shadow: an unmasked one is left out (with the pad moved by
   the blur past the offset). */
- (void)BTBrushTool_drawTouchAtPoint:(CGPoint)aPoint withSizeDeviation:(CGSize)aDeviation rotationAngleDeviation:(CGFloat)aDeviation2 opacityDeviation:(CGFloat)aDeviation3 alternateColor:(BOOL)aColor colorHSVADeviation:(id)aDeviation4 colorNativeDeviation:(id)aDeviation5 shadowColorHSVADeviation:(id)aDeviation6 shadowColorNativeDeviation:(id)aDeviation7 inContext:(struct CGContext *)aContext withBounds:(CGRect)aBounds
{
    CGAffineTransform ctm = CGContextGetCTM(aContext);
    CGSize scale = CGSizeMake(hypot(ctm.a, ctm.b), hypot(ctm.c, ctm.d));
    CGFloat height = (aDeviation.height + 1.0) * _size.height;
    CGFloat width = (aDeviation.width + 1.0) * _size.width;
    CGRect rect = CGRectMake(aPoint.x - width * 0.5, aPoint.y - height * 0.5, width, height);
    /* As in the original, each pad layer is checked against the other one's context and scale. */
    CGEColorRef color;
    CGLayerRef *layer;
    CGContextRef *layerContext;
    CGSize *layerScale;
    if (aColor && _alternateColor != NULL) {
        color = _alternateColor;
        layer = &_alternatePadLayer;
        layerContext = &_padLayerReferenceContext;
        layerScale = &_padLayerScale;
    } else {
        color = _color;
        layer = &_padLayer;
        layerContext = &_alternatePadLayerReferenceContext;
        layerScale = &_alternatePadLayerScale;
    }
    CGContextSaveGState(aContext);
    CGFloat angle = aDeviation2 + _rotationAngle;
    CGFloat sine = sin(angle), cosine = cos(angle);
    CGAffineTransform transform = CGAffineTransformMake(cosine, sine, -sine, cosine,
        (1.0 - cosine) * aPoint.x + sine * aPoint.y, (1.0 - cosine) * aPoint.y - sine * aPoint.x);
    if (_isPadFlippedHorizontally) {
        CGFloat flip = rect.origin.x + rect.origin.x + width;
        transform = CGAffineTransformMake(-transform.a, -transform.b, transform.c, transform.d,
            transform.tx + transform.a * flip, transform.ty + transform.b * flip);
    }
    if (_isPadFlippedVertically) {
        CGFloat flip = rect.origin.y + rect.origin.y + height;
        transform = CGAffineTransformMake(transform.a, transform.b, -transform.c, -transform.d,
            transform.tx + transform.c * flip, transform.ty + transform.d * flip);
    }
    CGContextConcatCTM(aContext, transform);
    if (_image == nil && color == NULL) {
        [self mask];
        if (_shapePrototypePath != NULL || _mask != NULL)
            [self BTBrushTool_clipPadInContext:aContext withScale:scale inRect:rect];
        CGContextClearRect(aContext, rect);
        CGContextRestoreGState(aContext);
        return;
    }
    [self shadowMask];
    CGContextSetAlpha(aContext, aDeviation3 + _opacity);
    if (!_padding || (color != NULL && (aDeviation4 != nil || aDeviation5 != nil)) || CGEColorIsGradient(color)
        || aDeviation.width != 0.0 || aDeviation.height != 0.0
        || (_shadowColor != NULL && _shadowMask == NULL && angle != 0.0)) {
        [self BTBrushTool_drawPadInContext:aContext withBounds:aBounds scale:scale inRect:rect withColor:color
            colorHSVADeviation:aDeviation4 colorNativeDeviation:aDeviation5 shadow:YES
            shadowColorHSVADeviation:aDeviation6 shadowColorNativeDeviation:aDeviation7];
        CGContextRestoreGState(aContext);
        return;
    }
    if (*layer != NULL && (*layerContext != aContext || BTBrushToolScaleDiffers(layerScale->width, scale.width)
            || BTBrushToolScaleDiffers(layerScale->height, scale.height))) {
        CGLayerRelease(*layer);
        *layer = NULL;
    }
    if (*layer == NULL) {
        BOOL shadow = _shadowMask != NULL && aDeviation6 == nil && aDeviation7 == nil;
        *layer = [self BTBrushTool_createPadLayerForRect:rect withColor:color shadow:shadow forContext:aContext
            withBounds:aBounds scale:scale];
        *layerContext = aContext;
        *layerScale = scale;
    }
    if (*layer == NULL) {
        CGContextRestoreGState(aContext);
        return;
    }
    CGPoint origin = rect.origin;
    if (_shadowColor != NULL) {
        if (aDeviation6 != nil || aDeviation7 != nil) {
            CGColorRef shadowColor = [self BTBrushTool_deviateCGColor:_shadowColor withHSVADeviation:aDeviation6
                nativeDeviation:aDeviation7];
            if (_shadowMask == NULL)
                CGContextSetShadowWithColor(aContext, _shadowOffset, _shadowBlurRadius, shadowColor);
            else
                [self BTBrushTool_drawShadowMaskInContext:aContext withScale:scale inRect:rect withColor:shadowColor];
        } else if (_shadowMask == NULL) {
            CGFloat spread = _shadowBlurRadius - _shadowOffset.width;
            if (_shadowOffset.width < 0.0 || spread > 0.0)
                origin.x -= spread;
            spread = _shadowBlurRadius - _shadowOffset.height;
            if (_shadowOffset.height < 0.0 || spread > 0.0)
                origin.y -= spread;
        } else {
            origin.x = fmin(rect.origin.x + _shadowOffset.width, rect.origin.x);
            origin.y = fmin(rect.origin.y + _shadowOffset.height, rect.origin.y);
        }
    }
    CGSize layerSize = CGLayerGetSize(*layer);
    CGContextDrawLayerInRect(aContext, CGRectMake(origin.x, origin.y, layerSize.width / scale.width,
        layerSize.height / scale.height), *layer);
    CGContextRestoreGState(aContext);
}

/* A layer of the pad (and its masked shadow) at the context's scale. */
- (struct CGLayer *)BTBrushTool_createPadLayerForRect:(CGRect)aRect withColor:(struct CGEColor *)aColor shadow:(BOOL)aShadow forContext:(struct CGContext *)aContext withBounds:(CGRect)aBounds scale:(CGSize)aScale
{
    CGRect padRect = CGRectMake(0.0, 0.0, aRect.size.width, aRect.size.height);
    if (aShadow)
        padRect = CGRectUnion(padRect, CGRectOffset(padRect, _shadowOffset.width, _shadowOffset.height));
    CGFloat layerHeight = (CGFloat)BTBrushToolPixelCount(padRect.size.height * aScale.height);
    CGFloat layerWidth = (CGFloat)BTBrushToolPixelCount(padRect.size.width * aScale.width);
    CGLayerRef layer = CGLayerCreateWithContext(aContext, CGSizeMake(layerWidth, layerHeight), NULL);
    if (layer == NULL)
        return NULL;
    CGContextRef context = CGLayerGetContext(layer);
    if (context == NULL) {
        CGLayerRelease(layer);
        return NULL;
    }
    CGRect bounds = CGRectMake((aBounds.origin.x - aRect.origin.x) * aScale.width, (aBounds.origin.y - aRect.origin.y) * aScale.height,
        aBounds.size.width * aScale.width, aBounds.size.height * aScale.height);
    CGRect inRect = CGRectMake(-padRect.origin.x, -padRect.origin.y, aRect.size.width * aScale.width,
        aRect.size.height * aScale.height);
    [self BTBrushTool_drawPadInContext:context withBounds:bounds scale:CGSizeMake(1.0, 1.0) inRect:inRect withColor:aColor
        colorHSVADeviation:nil colorNativeDeviation:nil shadow:aShadow shadowColorHSVADeviation:nil shadowColorNativeDeviation:nil];
    return layer;
}

/* Overlay layers may be missing for overlays without an image. */
static const void *BTBrushToolRetainLayer(CFAllocatorRef aAllocator, const void *aValue)
{
    return aValue != NULL ? CFRetain(aValue) : NULL;
}

static void BTBrushToolReleaseLayer(CFAllocatorRef aAllocator, const void *aValue)
{
    if (aValue != NULL)
        CFRelease(aValue);
}

/* Colorizes the colorization image with the (deviated) color: its grays map from
   the colorization shadow color through the color at the gray mid point to the
   colorization light color. */
static void BTBrushToolDrawColorizedImage(BTBrushTool *self, CGContextRef aContext, CGRect aRect, CGColorRef aColor)
{
    NSSize imageSize = [self->_colorizationImage imageSize];
    size_t width = BTBrushToolPixelCount(imageSize.width);
    size_t height = BTBrushToolPixelCount(imageSize.height);
    size_t rowBytes = ((width * 32 + 0x7f) >> 3) & ~(size_t)15;
    NSMutableData *data = [NSMutableData dataWithLength:height * rowBytes];
    unsigned char *bytes = [data mutableBytes];
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (space == NULL)
        return;
    CGContextRef bitmap = CGBitmapContextCreate(bytes, width, height, 8, rowBytes, space, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(space);
    if (bitmap == NULL)
        return;
    [self->_colorizationImage drawInCGContext:bitmap inRect:CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:&bytes pixelsWide:width pixelsHigh:height
        bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace
        bytesPerRow:rowBytes bitsPerPixel:32];
    if (rep == nil) {
        CGContextRelease(bitmap);
        return;
    }
    Class class = [self class];
    NSColor *light = [class BTBrushTool_cocoaColorForCoreGraphicsColor:self->_colorizationLightColor];
    NSColor *shadow = [class BTBrushTool_cocoaColorForCoreGraphicsColor:self->_colorizationShadowColor];
    NSColor *midColor = [class BTBrushTool_cocoaColorForCoreGraphicsColor:aColor];
    [rep colorizeByMappingGray:self->_colorizationGrayMidPoint toColor:midColor blackMapping:shadow whiteMapping:light];
    [rep release];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    if (provider == NULL) {
        CGContextRelease(bitmap);
        return;
    }
    CGImageRef image = CGEImageCreateAsBitmapContext(bitmap, provider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGContextRelease(bitmap);
    if (image == NULL)
        return;
    CGContextDrawImage(aContext, aRect, image);
    CGImageRelease(image);
}

/* Draws the overlay images (cached as layers at the pad's pixel size) over the
   pad, each in its blend mode. */
static void BTBrushToolDrawOverlays(BTBrushTool *self, CGContextRef aContext, CGSize aScale, CGRect aRect, NSUInteger aCount)
{
    if (self->_overlayLayers == NULL) {
        static const CFArrayCallBacks callBacks = { 0, BTBrushToolRetainLayer, BTBrushToolReleaseLayer, NULL, NULL };
        self->_overlayLayers = CFArrayCreateMutable(kCFAllocatorDefault, 0, &callBacks);
        if (self->_overlayLayers == NULL)
            return;
    }
    NSUInteger layerCount = CFArrayGetCount(self->_overlayLayers);
    CGFloat width = (CGFloat)BTBrushToolPixelCount(aRect.size.width * aScale.width);
    CGFloat height = (CGFloat)BTBrushToolPixelCount(aRect.size.height * aScale.height);
    BOOL rebuild = layerCount != aCount;
    if (!rebuild) {
        CGSize cachedSize = CGSizeZero;
        for (NSUInteger i = 0; i < aCount; i++) {
            CGLayerRef layer = (CGLayerRef)CFArrayGetValueAtIndex(self->_overlayLayers, i);
            if (layer != NULL) {
                cachedSize = CGLayerGetSize(layer);
                break;
            }
        }
        if (self->_overlayLayersReferenceContext != aContext || BTBrushToolScaleDiffers(cachedSize.width, width)
                || BTBrushToolScaleDiffers(cachedSize.height, height)) {
            CFArrayRemoveAllValues(self->_overlayLayers);
            rebuild = YES;
        }
    }
    if (rebuild) {
        for (NSUInteger i = 0; i < aCount; i++) {
            CGImageRef image = (CGImageRef)[[self->_overlays objectAtIndex:i] objectForKey:@"overlayImage"];
            CGLayerRef layer = NULL;
            if (image != NULL && (layer = CGLayerCreateWithContext(aContext, CGSizeMake(width, height), NULL)) != NULL) {
                CGContextRef context = CGLayerGetContext(layer);
                if (context == NULL) {
                    CGLayerRelease(layer);
                    layer = NULL;
                } else
                    CGContextDrawImage(context, CGRectMake(0.0, 0.0, width, height), image);
            }
            CFArrayAppendValue(self->_overlayLayers, layer);
            CGLayerRelease(layer);
        }
        self->_overlayLayersReferenceContext = aContext;
    }
    for (NSUInteger i = 0; i < aCount; i++) {
        CGLayerRef layer = (CGLayerRef)CFArrayGetValueAtIndex(self->_overlayLayers, i);
        if (layer == NULL)
            continue;
        id modeName = [[self->_overlays objectAtIndex:i] objectForKey:@"overlayBlendMode"];
        CGContextSetBlendMode(aContext, modeName != nil ? (CGBlendMode)[[self class] BTBrushTool_blendModeForName:modeName] : kCGBlendModeNormal);
        CGContextDrawLayerInRect(aContext, CGRectMake(aRect.origin.x, aRect.origin.y, width / aScale.width,
            height / aScale.height), layer);
    }
}

- (void)BTBrushTool_drawPadInContext:(struct CGContext *)aContext withBounds:(CGRect)aBounds scale:(CGSize)aScale inRect:(CGRect)aRect withColor:(struct CGEColor *)aColor colorHSVADeviation:(id)aDeviation colorNativeDeviation:(id)aDeviation2 shadow:(BOOL)aShadow shadowColorHSVADeviation:(id)aDeviation3 shadowColorNativeDeviation:(id)aDeviation4
{
    CGColorRef shadowColor = NULL;
    if (aShadow && _shadowColor != NULL) {
        shadowColor = [self BTBrushTool_deviateCGColor:_shadowColor withHSVADeviation:aDeviation3 nativeDeviation:aDeviation4];
        if (shadowColor != NULL) {
            if (_shadowMask == NULL) {
                /* The blur scales by the mean of the axis scales. */
                CGFloat blurX = _shadowBlurRadius * aScale.width, blurY = _shadowBlurRadius * aScale.height;
                CGContextSetShadowWithColor(aContext, CGSizeMake(_shadowOffset.width * aScale.width, _shadowOffset.height * aScale.height),
                    sqrt(2.0 / (1.0 / (blurY * blurY) + 1.0 / (blurX * blurX))), shadowColor);
                CGContextBeginTransparencyLayer(aContext, NULL);
            } else
                [self BTBrushTool_drawShadowMaskInContext:aContext withScale:aScale inRect:aRect withColor:shadowColor];
        }
    }
    [self mask];
    if (_shapePrototypePath != NULL || _mask != NULL)
        [self BTBrushTool_clipPadInContext:aContext withScale:aScale inRect:aRect];
    NSUInteger overlayCount = [_overlays count];
    if (_image != nil)
        [_image drawInCGContext:aContext inRect:aRect];
    else if (aColor != NULL) {
        if (CGEColorIsSolid(aColor) && _colorizationImage != nil && [self colorizationShadowColor] != nil
                && [self colorizationLightColor] != nil) {
            CGColorRef color = [self BTBrushTool_deviateCGColor:CGEColorGetCGColor(aColor) withHSVADeviation:aDeviation
                nativeDeviation:aDeviation2];
            BTBrushToolDrawColorizedImage(self, aContext, aRect, color);
        } else {
            CGRect bounds = aBounds;
            CGEColorRef color = aColor;
            if (CGEColorIsSolid(aColor))
                color = [self BTBrushTool_deviateCGEColor:aColor withHSVADeviation:aDeviation nativeDeviation:aDeviation2];
            else if (CGEColorIsUserPattern(aColor)) {
                bounds.origin.x += _userPatternPhase.width;
                bounds.origin.y += _userPatternPhase.height;
            }
            CGContextBeginPath(aContext);
            CGContextAddRect(aContext, aRect);
            if (CGEContextSetFillColorWithColor(aContext, NULL, bounds, color))
                CGContextFillPath(aContext);
            else if (overlayCount != 0) {
                CGContextSaveGState(aContext);
                CGEContextFillPathWithColor(aContext, NULL, bounds, color);
                CGContextRestoreGState(aContext);
            } else
                CGEContextFillPathWithColor(aContext, NULL, bounds, color);
        }
    }
    if (overlayCount != 0)
        BTBrushToolDrawOverlays(self, aContext, aScale, aRect, overlayCount);
    if (shadowColor != NULL && _shadowMask == NULL)
        CGContextEndTransparencyLayer(aContext);
}

/* Clips to the pad's shape and mask, rendered once per pixel size into a cached
   mask; a plain mask at least as large as the pad clips directly. */
- (void)BTBrushTool_clipPadInContext:(struct CGContext *)aContext withScale:(CGSize)aScale inRect:(CGRect)aRect
{
    CGFloat pixelWidth = aRect.size.width * aScale.width, pixelHeight = aRect.size.height * aScale.height;
    CGImageRef clip = _mask;
    CGRect clipRect = aRect;
    if (_cachedMask != NULL && !BTBrushToolScaleDiffers(_cachedMaskSize.width, pixelWidth)
            && !BTBrushToolScaleDiffers(_cachedMaskSize.height, pixelHeight)) {
        clip = _cachedMask;
    } else {
        CGImageRelease(_cachedMask);
        _cachedMask = NULL;
        CGFloat maskWidth = (CGFloat)CGImageGetWidth(_mask), maskHeight = (CGFloat)CGImageGetHeight(_mask);
        CGContextRef context;
        if ((_shapePrototypePath != NULL || maskWidth - 0.01 > pixelWidth || maskHeight - 0.01 > pixelHeight)
                && (context = BTBrushToolCreateGrayContext(pixelWidth, pixelHeight)) != NULL) {
            if (_shapePrototypePath != NULL) {
                if (_mask == NULL)
                    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
                else
                    CGContextSaveGState(context);
                CGRect pathBounds = _shapePrototypePathBounds;
                CGFloat sx = pathBounds.size.width != 0.0 ? pixelWidth / pathBounds.size.width : 1.0;
                CGFloat sy = pathBounds.size.height != 0.0 ? pixelHeight / pathBounds.size.height : 1.0;
                CGContextConcatCTM(context, CGAffineTransformMake(sx, 0.0, 0.0, sy, -pathBounds.origin.x * sx,
                    -pathBounds.origin.y * sy));
                CGContextBeginPath(context);
                CGContextAddPath(context, _shapePrototypePath);
                if (_mask == NULL)
                    CGContextFillPath(context);
                else {
                    CGContextRestoreGState(context);
                    CGContextClip(context);
                }
            }
            BOOL drawn = YES;
            if (_mask != NULL) {
                if (_maskRGBLayer == NULL) {
                    _maskRGBLayer = CGLayerCreateWithContext(context, CGSizeMake(maskWidth, maskHeight), NULL);
                    CGContextRef layerContext = _maskRGBLayer != NULL ? CGLayerGetContext(_maskRGBLayer) : NULL;
                    if (layerContext == NULL) {
                        CGLayerRelease(_maskRGBLayer);
                        _maskRGBLayer = NULL;
                        drawn = NO;
                    } else {
                        CGContextSetRGBFillColor(layerContext, 1.0, 1.0, 1.0, 1.0);
                        CGContextDrawImage(layerContext, CGRectMake(0.0, 0.0, maskWidth, maskHeight), _mask);
                    }
                }
                if (drawn)
                    CGContextDrawLayerInRect(context, CGRectMake(0.0, 0.0, pixelWidth, pixelHeight), _maskRGBLayer);
            }
            if (drawn) {
                _cachedMask = BTBrushToolCreateMaskFromGrayContext(context);
                _cachedMaskSize = CGSizeMake(pixelWidth, pixelHeight);
            }
            CGContextRelease(context);
            if (_cachedMask != NULL)
                clip = _cachedMask;
        }
    }
    if (clip == _cachedMask && clip != NULL)
        clipRect.size = CGSizeMake(CGImageGetWidth(clip) / aScale.width, CGImageGetHeight(clip) / aScale.height);
    if (clip != NULL)
        CGContextClipToMask(aContext, clipRect, clip);
}

/* Fills the shadow color through the shadow mask at the shadow offset. */
- (void)BTBrushTool_drawShadowMaskInContext:(struct CGContext *)aContext withScale:(CGSize)aScale inRect:(CGRect)aRect withColor:(struct CGColor *)aColor
{
    CGPoint origin = CGPointMake(aRect.origin.x + _shadowOffset.width, aRect.origin.y + _shadowOffset.height);
    CGSize size = CGSizeMake(aRect.size.width * aScale.width, aRect.size.height * aScale.height);
    CGImageRef mask = [self BTBrushTool_shadowMaskForSize:&size];
    if (mask == NULL)
        return;
    size.width /= aScale.width;
    size.height /= aScale.height;
    CGContextSaveGState(aContext);
    CGContextClipToMask(aContext, CGRectMake(origin.x, origin.y, size.width, size.height), mask);
    CGContextSetFillColorWithColor(aContext, aColor);
    CGContextFillRect(aContext, CGRectMake(origin.x, origin.y, aRect.size.width, aRect.size.height));
    CGContextRestoreGState(aContext);
}

/* The shadow mask scaled to the pixel size (cached); the size becomes the mask's
   pixel size. A shadow mask at least as large is returned as it is. */
- (struct CGImage *)BTBrushTool_shadowMaskForSize:(CGSize *)aSize
{
    if (_cachedShadowMask != NULL) {
        if (!BTBrushToolScaleDiffers(_cachedShadowMaskSize.width, aSize->width)
                && !BTBrushToolScaleDiffers(_cachedShadowMaskSize.height, aSize->height)) {
            *aSize = CGSizeMake(CGImageGetWidth(_cachedShadowMask), CGImageGetHeight(_cachedShadowMask));
            return _cachedShadowMask;
        }
        CGImageRelease(_cachedShadowMask);
        _cachedShadowMask = NULL;
    }
    CGFloat maskWidth = (CGFloat)CGImageGetWidth(_shadowMask), maskHeight = (CGFloat)CGImageGetHeight(_shadowMask);
    if (maskWidth - 0.01 <= aSize->width && maskHeight - 0.01 <= aSize->height)
        return _shadowMask;
    CGContextRef context = BTBrushToolCreateGrayContext(aSize->width, aSize->height);
    if (context == NULL)
        return _shadowMask;
    BOOL drawn = YES;
    if (_shadowMaskRGBLayer == NULL) {
        _shadowMaskRGBLayer = CGLayerCreateWithContext(context, CGSizeMake(maskWidth, maskHeight), NULL);
        CGContextRef layerContext = _shadowMaskRGBLayer != NULL ? CGLayerGetContext(_shadowMaskRGBLayer) : NULL;
        if (layerContext == NULL) {
            CGLayerRelease(_shadowMaskRGBLayer);
            _shadowMaskRGBLayer = NULL;
            drawn = NO;
        } else {
            CGContextSetRGBFillColor(layerContext, 1.0, 1.0, 1.0, 1.0);
            CGContextDrawImage(layerContext, CGRectMake(0.0, 0.0, maskWidth, maskHeight), _shadowMask);
        }
    }
    if (drawn) {
        CGContextDrawLayerInRect(context, CGRectMake(0.0, 0.0, aSize->width, aSize->height), _shadowMaskRGBLayer);
        _cachedShadowMask = BTBrushToolCreateMaskFromGrayContext(context);
        _cachedShadowMaskSize = *aSize;
    }
    CGContextRelease(context);
    if (_cachedShadowMask == NULL)
        return _shadowMask;
    *aSize = CGSizeMake(CGImageGetWidth(_cachedShadowMask), CGImageGetHeight(_cachedShadowMask));
    return _cachedShadowMask;
}

/* Deviates a color's base colors: HSVA deviations apply to RGBA colors (in HSV),
   native ones to the components of any color space, each component pinned to
   0...1. Returns the color itself when nothing deviates. */
- (struct CGEColor *)BTBrushTool_deviateCGEColor:(struct CGEColor *)aColor withHSVADeviation:(id)aDeviation nativeDeviation:(id)aDeviation2
{
    size_t baseColorCount = CGEColorGetNumberOfBaseColors(aColor);
    if (baseColorCount == 0)
        return aColor;
    size_t componentCount = CGColorSpaceGetNumberOfComponents(CGEColorGetBaseColorSpace(aColor)) + 1;
    size_t length = baseColorCount * componentCount * sizeof(CGFloat);
    CGFloat *components = NULL;
    if (aDeviation != nil && componentCount == 4) {
        components = [[NSMutableData dataWithBytes:CGEColorGetBaseColorsComponents(aColor) length:length] mutableBytes];
        if (components == NULL)
            return aColor;
        for (size_t i = 0; i < baseColorCount; i++) {
            CGFloat *c = components + i * componentCount;
            CGEColorConvertRGBToHSV(c[0], c[1], c[2], &c[0], &c[1], &c[2]);
            [self BTBrushTool_deviateColorComonents:c count:4 withDeviation:aDeviation];
            CGEColorConvertHSVToRGB(c[0], c[1], c[2], &c[0], &c[1], &c[2]);
        }
    }
    if (aDeviation2 != nil && [aDeviation2 length] / sizeof(CGFloat) == componentCount) {
        if (components == NULL) {
            components = [[NSMutableData dataWithBytes:CGEColorGetBaseColorsComponents(aColor) length:length] mutableBytes];
            if (components == NULL)
                return aColor;
        }
        for (size_t i = 0; i < baseColorCount; i++)
            [self BTBrushTool_deviateColorComonents:components + i * componentCount count:componentCount withDeviation:aDeviation2];
    }
    if (components == NULL)
        return aColor;
    CGEColorRef deviated = [BTPointer autoreleasedPointer:CGEColorCreateCopyWithBaseColorsComponents(aColor, components)
        withDisposer:CGEColorRelease];
    return deviated != NULL ? deviated : aColor;
}

- (struct CGColor *)BTBrushTool_deviateCGColor:(struct CGColor *)aColor withHSVADeviation:(id)aDeviation nativeDeviation:(id)aDeviation2
{
    CGColorSpaceRef space = CGColorGetColorSpace(aColor);
    size_t componentCount = CGColorSpaceGetNumberOfComponents(space) + 1;
    CGFloat *components = NULL;
    if (aDeviation != nil && componentCount == 4) {
        components = [[NSMutableData dataWithBytes:CGColorGetComponents(aColor) length:4 * sizeof(CGFloat)] mutableBytes];
        if (components == NULL)
            return aColor;
        CGEColorConvertRGBToHSV(components[0], components[1], components[2], &components[0], &components[1], &components[2]);
        [self BTBrushTool_deviateColorComonents:components count:4 withDeviation:aDeviation];
        CGEColorConvertHSVToRGB(components[0], components[1], components[2], &components[0], &components[1], &components[2]);
    }
    if (aDeviation2 != nil && [aDeviation2 length] / sizeof(CGFloat) == componentCount) {
        if (components == NULL) {
            components = [[NSMutableData dataWithBytes:CGColorGetComponents(aColor) length:componentCount * sizeof(CGFloat)] mutableBytes];
            if (components == NULL)
                return aColor;
        }
        [self BTBrushTool_deviateColorComonents:components count:componentCount withDeviation:aDeviation2];
    }
    if (components == NULL)
        return aColor;
    CGColorRef deviated = (CGColorRef)[(id)CGColorCreate(space, components) autorelease];
    return deviated != NULL ? deviated : aColor;
}

- (void)BTBrushTool_deviateColorComonents:(CGFloat *)aComonents count:(NSUInteger)aCount withDeviation:(id)aDeviation
{
    const CGFloat *deviation = [aDeviation bytes];
    for (NSUInteger i = 0; i < aCount; i++) {
        CGFloat value = aComonents[i] + deviation[i];
        aComonents[i] = value < 0.0 ? 0.0 : value > 1.0 ? 1.0 : value;
    }
}

/* Random deviations within the oscillations: HSVA only for four of them, native
   for any number. */
- (void)BTBrushTool_colorHSVADeviation:(id *)aDeviation nativeDeviation:(id *)aDeviation2 withHSVAOscillation:(id)aOscillation nativeOscillation:(id)aOscillation2
{
    if (aDeviation != NULL) {
        if (aOscillation == nil)
            *aDeviation = nil;
        else {
            NSUInteger count = [aOscillation length] / sizeof(CGFloat);
            if (count == 4) {
                *aDeviation = [NSMutableData dataWithLength:count * sizeof(CGFloat)];
                if (*aDeviation != nil) {
                    const CGFloat *oscillation = [aOscillation bytes];
                    CGFloat *deviation = [*aDeviation mutableBytes];
                    for (NSUInteger i = 0; i < count; i++)
                        deviation[i] = BTBrushToolDeviation(self, oscillation[i]);
                }
            }
        }
    }
    if (aDeviation2 != NULL) {
        if (aOscillation2 == nil)
            *aDeviation2 = nil;
        else {
            NSUInteger count = [aOscillation2 length] / sizeof(CGFloat);
            *aDeviation2 = [NSMutableData dataWithLength:count * sizeof(CGFloat)];
            if (*aDeviation2 != nil) {
                const CGFloat *oscillation = [aOscillation2 bytes];
                CGFloat *deviation = [*aDeviation2 mutableBytes];
                for (NSUInteger i = 0; i < count; i++)
                    deviation[i] = BTBrushToolDeviation(self, oscillation[i]);
            }
        }
    }
}

- (CGFloat)BTBrushTool_randomFactor
{
    return (CGFloat)(random() % 10000) * 0.0001;
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"color", @"alternateColor", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"colorPickingOption", @"alternateColorOption",
        @"willDrawCursor", @"doDrawCursor", @"willDrawCursorShapeContour", @"doDrawCursorShapeContour",
        @"willAlternateDrawCursor", @"doAlternateDrawCursor", @"pickColorCursor", @"size", @"sizeOscillation",
        @"spacing", @"spacingOscillation", @"colorizationImage", @"colorizationGrayMidPoint",
        @"colorizationShadowColor", @"colorizationLightColor", @"shapePrototypePath", @"image", @"mask",
        @"positionOscillation", @"rotationAngle", @"rotationAngleOscillation", @"touchInterval", @"opacity",
        @"opacityOscillation", @"color", @"alternateColor", @"userPatternPhase", @"padding",
        @"isPadFlippedHorizontally", @"isPadFlippedVertically", @"colorHSVAOscillation",
        @"colorNativeOscillation", @"shadowOffset", @"shadowBlurRadius", @"shadowMask", @"shadowColor",
        @"shadowColorHSVAOscillation", @"shadowColorNativeOscillation", @"overlays", nil];
}

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGMutableImage);
    return protocols;
}

- (void)setShadowColorNativeOscillation:(id)aOscillation
{
    if (_shadowColorNativeOscillation == aOscillation)
        return;
    BTBrushToolReleasePadLayers(self);
    [_shadowColorNativeOscillation release];
    _shadowColorNativeOscillation = [aOscillation copy];
}

- (id)shadowColorNativeOscillation
{
    return _shadowColorNativeOscillation;
}

- (void)setShadowColorHSVAOscillation:(id)aOscillation
{
    if (_shadowColorHSVAOscillation == aOscillation)
        return;
    BTBrushToolReleasePadLayers(self);
    [_shadowColorHSVAOscillation release];
    _shadowColorHSVAOscillation = [aOscillation copy];
}

/* The original returns the native oscillation here too. */
- (id)shadowColorHSVAOscillation
{
    return _shadowColorNativeOscillation;
}

- (void)setShadowColor:(id)aColor
{
    CGColorRef color = (CGColorRef)aColor;
    if (CGColorGetPattern(color) != NULL || CGColorEqualToColor(color, _shadowColor))
        return;
    BTBrushToolReleasePadLayers(self);
    CGColorRelease(_shadowColor);
    _shadowColor = CGColorRetain(color);
}

- (id)shadowColor
{
    return (id)_shadowColor;
}

/* A mask is a CGImage, or an image the mask is made from when first asked for. */
- (void)setShadowMask:(id)aMask
{
    if ((CGImageRef)aMask == _shadowMask && (_shadowMask != NULL || _shadowMaskInput == aMask))
        return;
    CGImageRelease(_cachedShadowMask);
    _cachedShadowMask = NULL;
    BTBrushToolReleasePadLayers(self);
    CGLayerRelease(_shadowMaskRGBLayer);
    _shadowMaskRGBLayer = NULL;
    [_shadowMaskInput release];
    _shadowMaskInput = nil;
    CGImageRelease(_shadowMask);
    _shadowMask = NULL;
    if (aMask == nil)
        return;
    if (CFGetTypeID((CFTypeRef)aMask) == CGImageGetTypeID())
        _shadowMask = CGImageRetain((CGImageRef)aMask);
    else
        _shadowMaskInput = [aMask retain];
}

- (id)shadowMask
{
    if (_shadowMask == NULL && _shadowMaskInput != nil) {
        _shadowMask = [[self class] BTBrushTool_createMaskFromImage:_shadowMaskInput];
        if (_shadowMask == NULL)
            return nil;
        [_shadowMaskInput release];
        _shadowMaskInput = nil;
    }
    return (id)_shadowMask;
}

- (BOOL)BTBrushTool_isShadowMaskPresent
{
    return _shadowMask != NULL || _shadowMaskInput != nil;
}

- (void)setShadowBlurRadius:(CGFloat)aRadius
{
    if (_shadowBlurRadius == aRadius)
        return;
    _shadowBlurRadius = aRadius;
    BTBrushToolReleasePadLayers(self);
}

- (CGFloat)shadowBlurRadius
{
    return _shadowBlurRadius;
}

- (void)setShadowOffset:(NSSize)aOffset
{
    if (NSEqualSizes(_shadowOffset, aOffset))
        return;
    _shadowOffset = aOffset;
    BTBrushToolReleasePadLayers(self);
}

- (NSSize)shadowOffset
{
    return _shadowOffset;
}

- (void)setOpacityOscillation:(CGFloat)aOscillation
{
    _opacityOscillation = aOscillation;
}

- (CGFloat)opacityOscillation
{
    return _opacityOscillation;
}

- (void)setOpacity:(CGFloat)aOpacity
{
    _opacity = aOpacity;
}

- (CGFloat)opacity
{
    return _opacity;
}

- (CGFloat)defaultOpacity
{
    return 1.0;
}

- (void)setMask:(id)aMask
{
    if ((CGImageRef)aMask == _mask && (_mask != NULL || _maskInput == aMask))
        return;
    CGImageRelease(_cachedMask);
    _cachedMask = NULL;
    BTBrushToolReleasePadLayers(self);
    CGLayerRelease(_maskRGBLayer);
    _maskRGBLayer = NULL;
    [_maskInput release];
    _maskInput = nil;
    CGImageRelease(_mask);
    _mask = NULL;
    if (aMask == nil)
        return;
    if (CFGetTypeID((CFTypeRef)aMask) == CGImageGetTypeID())
        _mask = CGImageRetain((CGImageRef)aMask);
    else
        _maskInput = [aMask retain];
}

- (id)mask
{
    if (_mask == NULL && _maskInput != nil) {
        _mask = [[self class] BTBrushTool_createMaskFromImage:_maskInput];
        if (_mask == NULL)
            return nil;
        [_maskInput release];
        _maskInput = nil;
    }
    return (id)_mask;
}

- (BOOL)BTBrushTool_isMaskPresent
{
    return _mask != NULL || _maskInput != nil;
}

/* An empty path, or one with empty bounds, leaves the brush without a shape. */
- (void)setShapePrototypePath:(id)aPath
{
    CGPathRef path = (CGPathRef)aPath;
    if (path == _shapePrototypePath)
        return;
    CGImageRelease(_cachedMask);
    _cachedMask = NULL;
    BTBrushToolReleasePadLayers(self);
    CGPathRelease(_shapePrototypePath);
    _shapePrototypePath = NULL;
    if (path == NULL || CGPathIsEmpty(path))
        return;
    _shapePrototypePathBounds = CGEPathGetPathBoundingBox(path);
    if (!CGRectIsEmpty(_shapePrototypePathBounds))
        _shapePrototypePath = (struct CGPath *)CGPathCreateCopy(path);
}

- (id)shapePrototypePath
{
    return (id)_shapePrototypePath;
}

/* Colorization colors only matter to solid-color pads drawn from a colorization image. */
static void BTBrushToolColorizationDidChange(BTBrushTool *self)
{
    if (self->_colorizationImage == nil)
        return;
    if (CGEColorIsSolid(self->_color)) {
        CGLayerRelease(self->_padLayer);
        self->_padLayer = NULL;
    }
    if (CGEColorIsSolid(self->_alternateColor)) {
        CGLayerRelease(self->_alternatePadLayer);
        self->_alternatePadLayer = NULL;
    }
}

- (void)setColorizationLightColor:(id)aColor
{
    CGColorRef color = (CGColorRef)aColor;
    if (CGColorGetPattern(color) != NULL)
        return;
    _isColorizationLightColorInitialized = 1;
    if (CGColorEqualToColor(color, _colorizationLightColor))
        return;
    BTBrushToolColorizationDidChange(self);
    CGColorRelease(_colorizationLightColor);
    _colorizationLightColor = CGColorRetain(color);
}

- (id)colorizationLightColor
{
    if (!_isColorizationLightColorInitialized) {
        _colorizationLightColor = CGColorRetain((CGColorRef)[self defaultColorizationLightColor]);
        _isColorizationLightColorInitialized = 1;
    }
    return (id)_colorizationLightColor;
}

static id BTBrushToolCreateGenericRGBColor(CGFloat aGray)
{
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (space == NULL)
        return nil;
    [(id)space autorelease];
    CGFloat components[4] = { aGray, aGray, aGray, 1.0 };
    return [(id)CGColorCreate(space, components) autorelease];
}

- (id)defaultColorizationLightColor
{
    return BTBrushToolCreateGenericRGBColor(1.0);
}

- (void)setColorizationShadowColor:(id)aColor
{
    CGColorRef color = (CGColorRef)aColor;
    if (CGColorGetPattern(color) != NULL)
        return;
    _isColorizationShadowColorInitialized = 1;
    if (CGColorEqualToColor(color, _colorizationShadowColor))
        return;
    BTBrushToolColorizationDidChange(self);
    CGColorRelease(_colorizationShadowColor);
    _colorizationShadowColor = CGColorRetain(color);
}

- (id)colorizationShadowColor
{
    if (!_isColorizationShadowColorInitialized) {
        _colorizationShadowColor = CGColorRetain((CGColorRef)[self defaultColorizationShadowColor]);
        _isColorizationShadowColorInitialized = 1;
    }
    return (id)_colorizationShadowColor;
}

- (id)defaultColorizationShadowColor
{
    return BTBrushToolCreateGenericRGBColor(0.0);
}

- (void)setColorizationGrayMidPoint:(CGFloat)aPoint
{
    if (_colorizationGrayMidPoint == aPoint)
        return;
    BTBrushToolColorizationDidChange(self);
    _colorizationGrayMidPoint = aPoint;
}

- (CGFloat)colorizationGrayMidPoint
{
    return _colorizationGrayMidPoint;
}

- (CGFloat)defaultColorizationGrayMidPoint
{
    return 0.5;
}

- (void)setColorizationImage:(id)aImage
{
    if (_colorizationImage == aImage)
        return;
    if (CGEColorIsSolid(_color)) {
        CGLayerRelease(_padLayer);
        _padLayer = NULL;
    }
    if (CGEColorIsSolid(_alternateColor)) {
        CGLayerRelease(_alternatePadLayer);
        _alternatePadLayer = NULL;
    }
    [_colorizationImage release];
    _colorizationImage = [aImage retain];
}

- (id)colorizationImage
{
    return _colorizationImage;
}

- (void)setOverlays:(id)aOverlays
{
    if (_overlays == aOverlays)
        return;
    BTBrushToolReleasePadLayers(self);
    if (_overlayLayers != NULL)
        CFArrayRemoveAllValues(_overlayLayers);
    [_overlays release];
    _overlays = aOverlays != nil ? [[NSArray alloc] initWithArray:aOverlays copyItems:YES] : nil;
}

- (id)overlays
{
    return _overlays;
}

- (void)setColorNativeOscillation:(id)aOscillation
{
    if (_colorNativeOscillation == aOscillation)
        return;
    BTBrushToolReleasePadLayers(self);
    [_colorNativeOscillation release];
    _colorNativeOscillation = [aOscillation copy];
}

- (id)colorNativeOscillation
{
    return _colorNativeOscillation;
}

- (void)setColorHSVAOscillation:(id)aOscillation
{
    if (_colorHSVAOscillation == aOscillation)
        return;
    BTBrushToolReleasePadLayers(self);
    [_colorHSVAOscillation release];
    _colorHSVAOscillation = [aOscillation copy];
}

/* The original returns the native oscillation here too. */
- (id)colorHSVAOscillation
{
    return _colorNativeOscillation;
}

- (void)setPadFlippedVertically:(BOOL)aVertically
{
    _isPadFlippedVertically = aVertically & 1;
}

- (BOOL)isPadFlippedVertically
{
    return _isPadFlippedVertically;
}

- (void)setPadFlippedHorizontally:(BOOL)aHorizontally
{
    _isPadFlippedHorizontally = aHorizontally & 1;
}

- (BOOL)isPadFlippedHorizontally
{
    return _isPadFlippedHorizontally;
}

- (void)setPadding:(BOOL)aPadding
{
    _padding = aPadding & 1;
    if (!_padding)
        BTBrushToolReleasePadLayers(self);
}

- (BOOL)padding
{
    return _padding;
}

- (BOOL)defaultPadding
{
    return YES;
}

- (void)setUserPatternPhase:(NSSize)aPhase
{
    _userPatternPhase = aPhase;
}

- (NSSize)userPatternPhase
{
    return _userPatternPhase;
}

static BOOL BTBrushToolReplaceColor(CGEColorRef *aSlot, id aColor)
{
    CGEColorRef old = *aSlot;
    if (aColor == nil) {
        if (old == NULL)
            return NO;
        *aSlot = NULL;
    } else if (CFGetTypeID((CFTypeRef)aColor) == CGColorGetTypeID()) {
        if (CGColorEqualToColor((CGColorRef)aColor, CGEColorGetCGColor(old)))
            return NO;
        *aSlot = CGEColorCreateWithCGColor((CGColorRef)aColor);
    } else {
        CGEColorRef color = (CGEColorRef)[aColor pointer];
        if (CGEColorEqualToColor(color, old))
            return NO;
        *aSlot = CGEColorRetain(color);
    }
    CGEColorRelease(old);
    return YES;
}

static id BTBrushToolWrapColor(CGEColorRef aColor)
{
    if (aColor == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:aColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(aColor);
    return wrapper;
}

- (void)setAlternateColor:(id)aColor
{
    if (!BTBrushToolReplaceColor(&_alternateColor, aColor))
        return;
    CGLayerRelease(_alternatePadLayer);
    _alternatePadLayer = NULL;
}

- (id)alternateColor
{
    return BTBrushToolWrapColor(_alternateColor);
}

- (void)setColor:(id)aColor
{
    if (!BTBrushToolReplaceColor(&_color, aColor))
        return;
    CGLayerRelease(_padLayer);
    _padLayer = NULL;
}

- (id)color
{
    return BTBrushToolWrapColor(_color);
}

- (void)setImage:(id)aImage
{
    if (_image == aImage)
        return;
    BTBrushToolReleasePadLayers(self);
    [_image release];
    _image = [aImage retain];
}

- (id)image
{
    return _image;
}

- (void)setTouchInterval:(double)aInterval
{
    if (_touchInterval == aInterval)
        return;
    _touchInterval = aInterval;
    if (!_isTracking)
        return;
    [_touchTimer invalidate];
    [_touchTimer release];
    _touchTimer = nil;
    [self BTBrushTool_scheduleTouchTimerIfNeeded];
}

- (double)touchInterval
{
    return _touchInterval;
}

- (void)setRotationAngleOscillation:(CGFloat)aOscillation
{
    _rotationAngleOscillation = aOscillation;
}

- (CGFloat)rotationAngleOscillation
{
    return _rotationAngleOscillation;
}

- (void)setRotationAngle:(CGFloat)aAngle
{
    _rotationAngle = aAngle;
}

- (CGFloat)rotationAngle
{
    return _rotationAngle;
}

- (void)setPositionOscillation:(NSSize)aOscillation
{
    _positionOscillation = aOscillation;
}

- (NSSize)positionOscillation
{
    return _positionOscillation;
}

- (void)setSpacingOscillation:(CGFloat)aOscillation
{
    _spacingOscillation = aOscillation;
}

- (CGFloat)spacingOscillation
{
    return _spacingOscillation;
}

- (void)setSpacing:(CGFloat)aSpacing
{
    _spacing = aSpacing;
}

- (CGFloat)spacing
{
    return _spacing;
}

/* A brush whose size oscillates can't reuse a cached pad. */
- (void)setSizeOscillation:(NSSize)aOscillation
{
    _sizeOscillation = aOscillation;
    if (aOscillation.width != 0.0 || aOscillation.height != 0.0)
        BTBrushToolReleasePadLayers(self);
}

- (NSSize)sizeOscillation
{
    return _sizeOscillation;
}

- (void)setSize:(NSSize)aSize
{
    if (NSEqualSizes(_size, aSize))
        return;
    _size = aSize;
    BTBrushToolReleasePadLayers(self);
}

- (NSSize)size
{
    return _size;
}

- (NSSize)defaultSize
{
    return NSMakeSize(20.0, 20.0);
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
        [_doAlternateDrawShapeContourCursor release];
        _doAlternateDrawShapeContourCursor = nil;
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
        [_willAlternateDrawShapeContourCursor release];
        _willAlternateDrawShapeContourCursor = nil;
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

- (void)setDoDrawCursorShapeContour:(id)aContour
{
    if ((CGPathRef)aContour == _doDrawCursorShapeContour)
        return;
    CGPathRelease(_doDrawCursorShapeContour);
    _doDrawCursorShapeContour = (struct CGPath *)CGPathCreateCopy((CGPathRef)aContour);
    [_doDrawShapeContourCursor release];
    _doDrawShapeContourCursor = nil;
    [_doAlternateDrawShapeContourCursor release];
    _doAlternateDrawShapeContourCursor = nil;
    if (_doDrawCursorShapeContour != NULL)
        _doDrawCursorShapeContourBounds = CGEPathGetPathBoundingBox(_doDrawCursorShapeContour);
}

- (id)doDrawCursorShapeContour
{
    return (id)_doDrawCursorShapeContour;
}

- (void)setDoDrawCursor:(id)aCursor
{
    if (_doDrawCursor != aCursor) {
        [_doDrawCursor release];
        _doDrawCursor = [aCursor retain];
        [_doDrawShapeContourCursor release];
        _doDrawShapeContourCursor = nil;
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

- (void)setWillDrawCursorShapeContour:(id)aContour
{
    if ((CGPathRef)aContour == _willDrawCursorShapeContour)
        return;
    CGPathRelease(_willDrawCursorShapeContour);
    _willDrawCursorShapeContour = (struct CGPath *)CGPathCreateCopy((CGPathRef)aContour);
    [_willDrawShapeContourCursor release];
    _willDrawShapeContourCursor = nil;
    [_willAlternateDrawShapeContourCursor release];
    _willAlternateDrawShapeContourCursor = nil;
    if (_willDrawCursorShapeContour != NULL)
        _willDrawCursorShapeContourBounds = CGEPathGetPathBoundingBox(_willDrawCursorShapeContour);
}

- (id)willDrawCursorShapeContour
{
    return (id)_willDrawCursorShapeContour;
}

- (void)setWillDrawCursor:(id)aCursor
{
    if (_willDrawCursor != aCursor) {
        [_willDrawCursor release];
        _willDrawCursor = [aCursor retain];
        [_willDrawShapeContourCursor release];
        _willDrawShapeContourCursor = nil;
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

/* The shape contour cursors are built once from the source cursor (the matching
   plain cursor when none is given) and kept until the cursor or contour changes. */
- (id)BTBrushTool_doAlternateDrawShapeContourCursor:(id)aCursor
{
    if (_doAlternateDrawShapeContourCursor == nil) {
        if (aCursor == nil)
            aCursor = [self doAlternateDrawCursor];
        _doAlternateDrawShapeContourCursor = [[self BTBrushTool_cursorWithShapeContour:_doDrawCursorShapeContour
            shapeContourPrototypeBounds:_doDrawCursorShapeContourBounds sourceCursor:aCursor size:_size] retain];
    }
    return _doAlternateDrawShapeContourCursor;
}

- (id)BTBrushTool_doDrawShapeContourCursor:(id)aCursor
{
    if (_doDrawShapeContourCursor == nil) {
        if (aCursor == nil)
            aCursor = [self doDrawCursor];
        _doDrawShapeContourCursor = [[self BTBrushTool_cursorWithShapeContour:_doDrawCursorShapeContour
            shapeContourPrototypeBounds:_doDrawCursorShapeContourBounds sourceCursor:aCursor size:_size] retain];
    }
    return _doDrawShapeContourCursor;
}

- (id)BTBrushTool_willAlternateDrawShapeContourCursor:(id)aCursor
{
    if (_willAlternateDrawShapeContourCursor == nil) {
        if (aCursor == nil)
            aCursor = [self willAlternateDrawCursor];
        _willAlternateDrawShapeContourCursor = [[self BTBrushTool_cursorWithShapeContour:_willDrawCursorShapeContour
            shapeContourPrototypeBounds:_willDrawCursorShapeContourBounds sourceCursor:aCursor size:_size] retain];
    }
    return _willAlternateDrawShapeContourCursor;
}

- (id)BTBrushTool_willDrawShapeContourCursor:(id)aCursor
{
    if (_willDrawShapeContourCursor == nil) {
        if (aCursor == nil)
            aCursor = [self willDrawCursor];
        _willDrawShapeContourCursor = [[self BTBrushTool_cursorWithShapeContour:_willDrawCursorShapeContour
            shapeContourPrototypeBounds:_willDrawCursorShapeContourBounds sourceCursor:aCursor size:_size] retain];
    }
    return _willDrawShapeContourCursor;
}

/* Combines the source cursor's image with the brush outline scaled to the brush's
   size in view space and centered on the hot spot. As in the original, the outline
   is drawn at the image origin rather than at its centered rect. */
- (id)BTBrushTool_cursorWithShapeContour:(struct CGPath *)aContour shapeContourPrototypeBounds:(CGRect)aBounds sourceCursor:(id)aCursor size:(CGSize)aSize
{
    if (aContour == NULL)
        return aCursor;
    CGRect shapeRect = CGRectApplyAffineTransform(CGRectMake(0.0, 0.0, aSize.width, aSize.height), [self imageToViewTransform]);
    shapeRect.origin = CGPointZero;
    NSPoint hotSpot = [aCursor hotSpot];
    NSImage *cursorImage = [aCursor image];
    NSSize imageSize = cursorImage != nil ? [cursorImage size] : NSZeroSize;
    CGFloat flippedHotSpotY = imageSize.height - hotSpot.y;
    CGRect contourRect = CGRectOffset(shapeRect, hotSpot.x + 0.5 - CGRectGetMidX(shapeRect),
        flippedHotSpotY + 0.5 - CGRectGetMidY(shapeRect));
    CGRect bounds = CGRectIntegral(CGRectUnion(contourRect, CGRectMake(0.0, 0.0, imageSize.width, imageSize.height)));
    NSImage *image = [[NSImage alloc] initWithSize:NSSizeFromCGSize(bounds.size)];
    [image lockFocus];
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGFloat sx = aBounds.size.width != 0.0 ? shapeRect.size.width / aBounds.size.width : 1.0;
    CGFloat sy = aBounds.size.height != 0.0 ? shapeRect.size.height / aBounds.size.height : 1.0;
    CGAffineTransform transform = CGAffineTransformMake(sx, 0.0, 0.0, sy, shapeRect.origin.x - aBounds.origin.x * sx,
        shapeRect.origin.y - aBounds.origin.y * sy);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddPath(path, &transform, aContour);
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextBeginPath(context);
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    CGPathRelease(path);
    [cursorImage drawAtPoint:NSMakePoint(-bounds.origin.x, -bounds.origin.y) fromRect:NSZeroRect
        operation:NSCompositeSourceOver fraction:1.0];
    [image unlockFocus];
    NSPoint newHotSpot = NSMakePoint(hotSpot.x - bounds.origin.x, bounds.size.height - (flippedHotSpotY - bounds.origin.y));
    return [[[NSCursor alloc] initWithImage:image hotSpot:newHotSpot] autorelease];
}

- (void)BTBrushTool_scheduleTouchTimerIfNeeded
{
    if (_touchInterval <= 0.0)
        return;
    _touchTimer = [[NSTimer timerWithTimeInterval:_touchInterval target:self
        selector:@selector(BTBrushTool_touchByTimer:) userInfo:nil repeats:YES] retain];
    if (_touchTimer != nil)
        [[NSRunLoop currentRunLoop] addTimer:_touchTimer forMode:NSEventTrackingRunLoopMode];
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
    return NSAlternateKeyMask;
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
    return NSCommandKeyMask;
}

- (void)dealloc
{
    [_touchTimer invalidate];
    [_touchTimer release];
    _touchTimer = nil;
    if (_touchConsumers != nil)
        NSFreeMapTable(_touchConsumers);
    CGLayerRelease(_padLayer);
    CGLayerRelease(_alternatePadLayer);
    CGColorRelease(_shadowColor);
    [_shadowColorNativeOscillation release];
    [_shadowColorHSVAOscillation release];
    CGLayerRelease(_shadowMaskRGBLayer);
    [_shadowMaskInput release];
    CGImageRelease(_shadowMask);
    CGImageRelease(_cachedMask);
    CGImageRelease(_cachedShadowMask);
    CGPathRelease(_shapePrototypePath);
    CGLayerRelease(_maskRGBLayer);
    [_maskInput release];
    CGImageRelease(_mask);
    [_image release];
    CGEColorRelease(_color);
    CGEColorRelease(_alternateColor);
    [_colorNativeOscillation release];
    [_colorHSVAOscillation release];
    [_colorizationImage release];
    CGColorRelease(_colorizationShadowColor);
    CGColorRelease(_colorizationLightColor);
    if (_overlayLayers != NULL)
        CFRelease(_overlayLayers);
    [_overlays release];
    [_willDrawCursor release];
    [_doDrawCursor release];
    [_willAlternateDrawCursor release];
    [_doAlternateDrawCursor release];
    [_pickColorCursor release];
    CGPathRelease(_willDrawCursorShapeContour);
    CGPathRelease(_doDrawCursorShapeContour);
    [_willDrawShapeContourCursor release];
    [_willAlternateDrawShapeContourCursor release];
    [_doDrawShapeContourCursor release];
    [_doAlternateDrawShapeContourCursor release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _size = NSMakeSize(20.0, 20.0);
        _opacity = 1.0;
        _padding = 1;
        _colorizationGrayMidPoint = 0.5;
        _colorPickingOption = NSCommandKeyMask;
        _alternateColorOption = NSAlternateKeyMask;
    }
    return self;
}

@end
