#import "BTFillTool.h"
#import "BTCGBitmapLayer.h"
#import "BTPointer.h"
#import "NSApplication+BTEvents.h"
#import "NSEvent+BTLocation.h"

@implementation BTFillTool

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

/* An eraser fills with the alternate color too. */
- (BOOL)flagsChanged:(id)aEvent
{
    NSUInteger flags = [aEvent modifierFlags];
    BOOL alternate = BTModifierFlagsMatchOption(flags, _alternateFillColorOption)
                     || [NSApp BT_effectivePointingDeviceType] == NSPointingDeviceTypeEraser;
    BOOL picking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    if (alternate == (BOOL)_isUsingAlternateFillColor && picking == (BOOL)_isColorPicking)
        return NO;
    _isUsingAlternateFillColor = alternate;
    _isColorPicking = picking;
    [_delegate tool:self didUpdateCursorWithEvent:aEvent];
    return YES;
}

/* Picks the fill color from the image, or fills the area of similar color under the mouse. */
- (BOOL)mouseDown:(id)aEvent
{
    id image = [self workImage];
    if (image == nil)
        return NO;

    NSUInteger flags = [aEvent modifierFlags];
    _isUsingAlternateFillColor = BTModifierFlagsMatchOption(flags, _alternateFillColorOption)
                                 || [aEvent BT_pointingDeviceType] == NSPointingDeviceTypeEraser;

    if (BTModifierFlagsMatchOption(flags, _colorPickingOption)) {
        id color = (id)[image colorAtPoint:[self eventLocationInImage:aEvent]];
        if (color == nil)
            return NO;
        NSString *key = _isUsingAlternateFillColor ? @"alternateFillColor" : @"fillColor";
        [_delegate tool:self willUpdateOutputForKey:key];
        if (_isUsingAlternateFillColor)
            [self setAlternateFillColor:color];
        else
            [self setFillColor:color];
        [_delegate tool:self didUpdateOutputForKey:key];
        [_delegate tool:self didFinalizeOutputForKey:@"alternateFillColor"];
        [_delegate tool:self didFinalizeOutputForKey:@"fillColor"];
    } else {
        CGEColorRef color = (_isUsingAlternateFillColor && _alternateFillColor != NULL) ? _alternateFillColor : [self BTFillTool_fillColor];
        id<BTRawImage, BTCGMutableImage> bitmap = color != NULL ? [self BTFillTool_bitmapWorkImage] : nil;
        CGMutablePathRef path;
        if (bitmap != nil && (path = (CGMutablePathRef)CFAutorelease(CGPathCreateMutable())) != NULL) {
            CGSize size = [bitmap imageSize];
            NSPoint location = [self eventLocationInImage:aEvent];
            CGRect bounds = CGRectZero;
            if (CGEPathAddPathsFromARGB8888PremultipliedBitmap(path, NULL, [bitmap imageBytes], lround(size.width), lround(size.height),
                                                               [bitmap imageBytesPerRow], location.x, location.y, _tolerance, 1, 8, &bounds)) {
                /* The outline is stroked too, wider for higher tolerances, to cover antialiased edges. */
                CGFloat lineWidth = _tolerance < 0.5 ? _tolerance * 6.0 : 3.0;
                CGRect imageRect = { CGPointZero, size };
                CGFloat outset = -(lineWidth * 0.5 + 0.05);
                CGRect rect = CGRectIntersection(CGRectIntegral(CGRectInset(bounds, outset, outset)), imageRect);
                if (!CGRectIsEmpty(rect)) {
                    [self beginUndoAction];
                    [self preEditWorkImage:bitmap inRect:rect];
                    [bitmap beginCGEditing];
                    CGContextRef context = [bitmap imageCGContext];
                    if (context != NULL) {
                        CGContextBeginPath(context);
                        CGContextAddPath(context, path);
                        if (CGEContextSetFillColorWithColor(context, NULL, imageRect, color)) {
                            CGContextEOFillPath(context);
                        } else if (lineWidth > 0.0) {
                            CGContextSaveGState(context);
                            CGEContextEOFillPathWithColor(context, NULL, imageRect, color);
                            CGContextRestoreGState(context);
                        } else {
                            CGEContextEOFillPathWithColor(context, NULL, imageRect, color);
                        }
                        if (lineWidth > 0.0) {
                            CGContextSetLineWidth(context, lineWidth);
                            CGContextBeginPath(context);
                            CGContextAddPath(context, path);
                            CGEContextStrokePathWithColor(context, NULL, imageRect, color);
                        }
                    }
                    [bitmap endCGEditing];
                    [self postEditWorkImageInRect:rect];
                    [self endUndoActionWithName:@"Fill"];
                }
            }
        }
    }
    [_delegate tool:self didFinalizeStage:@"BTWaitingToolStage" withEvent:aEvent nextStage:nil];
    return YES;
}

- (id)cursorForPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags
{
    if (BTModifierFlagsMatchOption(aFlags, _colorPickingOption))
        return [self pickColorCursor];
    if (_alternateFillColor != NULL
        && (BTModifierFlagsMatchOption(aFlags, _alternateFillColorOption)
            || [NSApp BT_effectivePointingDeviceType] == NSPointingDeviceTypeEraser))
        return [self willAlternateDrawCursor];
    return [self willDrawCursor];
}

/* The work image itself when it is a plain ARGB bitmap, else an ARGB copy of it. */
- (id)BTFillTool_bitmapWorkImage
{
    id image = [self workImage];
    if (image == nil)
        return nil;
    if ([image conformsToProtocol:@protocol(BTRawImage)] && [image conformsToProtocol:@protocol(BTCGMutableImage)]
        && [image imageFormat] == -1 && [image imageDecode] == NULL && [image imageColorProfile] == NULL)
        return image;

    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (space == NULL)
        return nil;
    CGSize size = [image imageSize];
    long width = size.width > 0.0 ? lround(ceil(size.width)) : 0;
    long height = size.height > 0.0 ? lround(ceil(size.height)) : 0;
    CGContextRef context = CGEBitmapContextCreate(NULL, width, height, 8, (width * 4 + 15) & ~15L, space, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(space);
    if (context == NULL)
        return nil;
    [image drawInCGContext:context atPoint:CGPointZero];
    id layer = [BTCGBitmapLayer bitmapLayerWithCGContext:context decode:NULL format:-1 colorProfile:NULL];
    CGContextRelease(context);
    return layer;
}

- (id)currentStage
{
    return @"BTWaitingToolStage";
}

- (BOOL)activateWithDelegate:(id)aDelegate inView:(id)aView
{
    if (![super activateWithDelegate:aDelegate inView:aView])
        return NO;
    NSUInteger flags = [NSApp BT_effectiveModifierFlags];
    _isUsingAlternateFillColor = BTModifierFlagsMatchOption(flags, _alternateFillColorOption)
                                 || [NSApp BT_effectivePointingDeviceType] == NSPointingDeviceTypeEraser;
    _isColorPicking = BTModifierFlagsMatchOption(flags, _colorPickingOption);
    return YES;
}

- (id)outputKeys
{
    return [NSArray arrayWithObjects:@"fillColor", @"alternateFillColor", nil];
}

- (id)inputKeys
{
    return [NSArray arrayWithObjects:@"generalKeyBindings", @"willDrawCursor", @"willAlternateDrawCursor", @"pickColorCursor",
            @"fillColor", @"alternateFillColor", @"tolerance", @"colorPickingOption", @"alternateFillColorOption", nil];
}

- (id *)optionalImageProtocols
{
    static id protocols[3];
    protocols[0] = @protocol(BTRawImage);
    protocols[1] = @protocol(BTCGMutableImage);
    return protocols;
}

- (id *)requiredImageProtocols
{
    static id protocols[2];
    protocols[0] = @protocol(BTCGImage);
    return protocols;
}

- (void)setTolerance:(CGFloat)aTolerance
{
    _tolerance = aTolerance;
}

- (CGFloat)tolerance
{
    return _tolerance;
}

/* Colors come in as CGColors or as BTPointer-wrapped CGEColors. */
static CGEColorRef BTFillToolCreateColor(id aColor)
{
    if (aColor == nil)
        return NULL;
    if (CFGetTypeID((CFTypeRef)aColor) == CGColorGetTypeID())
        return CGEColorCreateWithCGColor((CGColorRef)aColor);
    return CGEColorRetain([aColor pointer]);
}

- (void)setAlternateFillColor:(id)aColor
{
    CGEColorRef old = _alternateFillColor;
    _alternateFillColor = BTFillToolCreateColor(aColor);
    CGEColorRelease(old);
}

- (id)alternateFillColor
{
    if (_alternateFillColor == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:_alternateFillColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(_alternateFillColor);
    return wrapper;
}

- (void)setFillColor:(id)aColor
{
    _isFillColorInitialized = 1;
    CGEColorRef old = _fillColor;
    _fillColor = BTFillToolCreateColor(aColor);
    CGEColorRelease(old);
}

- (id)fillColor
{
    if ([self BTFillTool_fillColor] == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:_fillColor withDisposer:CGEColorRelease];
    if (wrapper != nil)
        CGEColorRetain(_fillColor);
    return wrapper;
}

- (id)defaultFillColor
{
    CGEColorRef color = [self BTFillTool_createDefaultFillColor];
    if (color == NULL)
        return nil;
    id wrapper = [BTPointer wrapperForPointer:color withDisposer:CGEColorRelease];
    if (wrapper == nil)
        CGEColorRelease(color);
    return wrapper;
}

- (struct CGEColor *)BTFillTool_fillColor
{
    if (!_isFillColorInitialized) {
        _fillColor = [self BTFillTool_createDefaultFillColor];
        _isFillColorInitialized = 1;
    }
    return _fillColor;
}

/* Opaque black. */
- (struct CGEColor *)BTFillTool_createDefaultFillColor
{
    CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (space == NULL)
        return NULL;
    const CGFloat components[4] = { 0, 0, 0, 1 };
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

- (void)setWillDrawCursor:(id)aCursor
{
    if (_willDrawCursor != aCursor) {
        [_willDrawCursor release];
        _willDrawCursor = [aCursor retain];
    }
}

- (id)willDrawCursor
{
    return _willDrawCursor;
}

- (id)defaultWillDrawCursor
{
    return nil;
}

- (void)setAlternateColorOption:(NSUInteger)aOption
{
    _alternateFillColorOption = aOption;
}

- (NSUInteger)alternateColorOption
{
    return _alternateFillColorOption;
}

/* Option down. */
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

/* Command down. */
- (NSUInteger)defaultColorPickingOption
{
    return NSEventModifierFlagCommand;
}

- (void)dealloc
{
    [_willDrawCursor release];
    [_willAlternateDrawCursor release];
    [_pickColorCursor release];
    CGEColorRelease(_fillColor);
    CGEColorRelease(_alternateFillColor);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _colorPickingOption = NSEventModifierFlagCommand;
        _alternateFillColorOption = NSEventModifierFlagOption;
    }
    return self;
}

@end
