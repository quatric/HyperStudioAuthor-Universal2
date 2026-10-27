#import "HSColorSlider.h"

// A vertical slider over a gradient of two colors, with markers along
// its left side (the color picker's brightness and alpha sliders).

@implementation HSColorSlider

+ (id)defaultBottomColor
{
    return [NSColor blackColor];
}

+ (id)defaultTopColor
{
    return [NSColor whiteColor];
}

+ (Class)cellClass
{
    return [NSActionCell class];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdeprecated-implementations"

- (id)accessibilityFocusedUIElement
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (BOOL)accessibilityIsIgnored
{
    return NO;
}

- (id)accessibilityHitTest:(NSPoint)aTest
{
    return NSAccessibilityUnignoredAncestor(self);
}

- (id)accessibilityAttributeValue:(id)aValue
{
    if ([aValue isEqualToString:NSAccessibilityRoleAttribute])
        return NSAccessibilityUnknownRole;
    if ([aValue isEqualToString:NSAccessibilityRoleDescriptionAttribute])
        return NSAccessibilityRoleDescription(NSAccessibilitySliderRole, nil);
    return [super accessibilityAttributeValue:aValue];
}

#pragma clang diagnostic pop

- (id)knobPressedImage
{
    if (_knobPressedImage == nil)
        _knobPressedImage = [[NSImage imageNamed:@"cp_knob_pressed"] retain];
    return _knobPressedImage;
}

- (id)knobImage
{
    if (_knobImage == nil) {
        _knobImage = [[NSImage imageNamed:@"cp_knob_normal"] retain];
        _knobHeight = [_knobImage size].height - 2.0;
    }
    return _knobImage;
}

// The value at the mouse, the knob's middle at the ends.
- (void)updateWithEvent:(id)aEvent
{
    NSRect bounds = [self bounds];
    float knobHeight = _knobHeight;
    NSPoint point = [self convertPoint:[(NSEvent *)aEvent locationInWindow] fromView:nil];
    float half = knobHeight * 0.5f;
    float value;
    if (point.y < half)
        value = 0.0f;
    else {
        float height = bounds.size.height - knobHeight;
        value = half + height < point.y ? 1.0f : (point.y - half) / height;
    }
    if ([self floatValue] != value) {
        [self setFloatValue:value];
        if ([self target] != nil)
            [super sendAction:[self action] to:[self target]];
    }
}

- (void)mouseDragged:(id)aDragged
{
    [self updateWithEvent:aDragged];
}

- (void)mouseUp:(id)aUp
{
    _isPressed = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(id)aDown
{
    [self updateWithEvent:aDown];
    _isPressed = YES;
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (float)floatValue
{
    return _floatValue;
}

- (void)setFloatValue:(float)aValue
{
    if ([self floatValue] != aValue) {
        _floatValue = aValue;
        [self setNeedsDisplay:YES];
    }
}

- (NSUInteger)markersCount
{
    return _markersCount;
}

- (void)setMarkersCount:(NSUInteger)aCount
{
    if (_markersCount != aCount) {
        _markersCount = (unsigned int)aCount;
        [self setNeedsDisplay:YES];
    }
}

- (void)setBottomColor:(id)aColor
{
    if (![_bottomColor isEqual:aColor]) {
        [_bottomColor release];
        _bottomColor = [aColor retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)bottomColor
{
    if (_bottomColor == nil)
        _bottomColor = [[[self class] defaultBottomColor] retain];
    return _bottomColor;
}

- (void)setTopColor:(id)aColor
{
    if (![_topColor isEqual:aColor]) {
        [_topColor release];
        _topColor = [aColor retain];
        [self setNeedsDisplay:YES];
    }
}

- (id)topColor
{
    if (_topColor == nil)
        _topColor = [[[self class] defaultTopColor] retain];
    return _topColor;
}

static void HSColorSliderStrokeMarker(float aY)
{
    [NSBezierPath strokeLineFromPoint:NSMakePoint(0, aY + 0.5f) toPoint:NSMakePoint(4, aY + 0.5f)];
}

// The framed gradient, the markers and the knob over them.
- (void)drawRect:(NSRect)aRect
{
    NSRect bounds = [self bounds];
    NSRect frame = NSMakeRect(bounds.origin.x + 4.0, bounds.origin.y, MAX(bounds.size.width - 5.0, 0), MAX(bounds.size.height - 2.0, 0));
    [[NSColor whiteColor] set];
    NSRectFill(frame);
    NSColor *frameColor = [NSColor colorWithCalibratedWhite:0.6 alpha:0.9];
    [frameColor set];
    NSFrameRect(frame);
    NSRect inner = NSMakeRect(frame.origin.x + 2.0, frame.origin.y + 2.0, MAX(frame.size.width - 4.0, 0), MAX(frame.size.height - 4.0, 0));
    HSColor *gradient = [[HSColor alloc] init];
    [gradient setStartColor:[self topColor]];
    [gradient setEndColor:[self bottomColor]];
    [gradient setAngle:270];
    [gradient drawGradientInCocoaContext:[NSGraphicsContext currentContext] rect:inner ofBounds:inner];
    [gradient release];
    NSImage *knob = _isPressed ? [self knobPressedImage] : [self knobImage];
    if (_markersCount != 0) {
        [frameColor set];
        float height = bounds.size.height;
        if (_markersCount == 1)
            HSColorSliderStrokeMarker(roundf(height * 0.5f));
        else {
            HSColorSliderStrokeMarker(roundf(_knobHeight * 0.5f));
            HSColorSliderStrokeMarker(roundf(_knobHeight * -0.5f + height));
            NSUInteger last = _markersCount - 1;
            for (NSUInteger index = 1; index < last; index++)
                HSColorSliderStrokeMarker(roundf((float)index * ((height - _knobHeight) / (float)last) + _knobHeight * 0.5f));
        }
    }
    float knobHeight = _knobHeight;
    float y = roundf(((float)frame.size.height - knobHeight) * [self floatValue]);
    [knob drawInRect:NSMakeRect(3.0, y, frame.size.width + 2.0, knobHeight + 2.0) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
}

- (void)dealloc
{
    [_knobImage release];
    [_bottomColor release];
    [_topColor release];
    [_knobPressedImage release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame
{
    if ((self = [super initWithFrame:aFrame]))
        _markersCount = 3;
    return self;
}

@end
