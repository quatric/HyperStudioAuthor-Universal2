#import "HSAnimationSetupEditPathCanvasItem.h"

static id HSEditPathSelectedKnobImage = nil;
static id HSEditPathKnobImage = nil;
static id HSEditPathSelectedLastKnobImage = nil;
static id HSEditPathLastKnobImage = nil;
static id HSEditPathSelectedFirstKnobImage = nil;
static id HSEditPathFirstKnobImage = nil;

@implementation HSAnimationSetupEditPathCanvasItem

// Knob image slots are shared by all instances.
+ (NSRect)pathBoundsWithKnobOffset:(id)aOffset
{
    NSRect bounds = NSZeroRect;
    if (aOffset) {
        NSPoint offset = [self knobOffset];
        bounds = NSInsetRect([aOffset bounds], -offset.x, -offset.y);
    }
    return bounds;
}

+ (NSPoint)knobOffset
{
    NSSize size = [(NSImage *)[self knobImage] size];
    return NSMakePoint(size.width * 0.5f, size.height * 0.5f);
}

+ (id)selectedKnobImage
{
    if (!HSEditPathSelectedKnobImage)
        HSEditPathSelectedKnobImage = [NSImage imageNamed:@"hRoundRed_on"];
    return HSEditPathSelectedKnobImage;
}

+ (id)knobImage
{
    if (!HSEditPathKnobImage)
        HSEditPathKnobImage = [NSImage imageNamed:@"hRoundRed"];
    return HSEditPathKnobImage;
}

+ (id)selectedLastKnobImage
{
    if (!HSEditPathSelectedLastKnobImage)
        HSEditPathSelectedLastKnobImage = [NSImage imageNamed:@"hRoundRed_on"];
    return HSEditPathSelectedLastKnobImage;
}

+ (id)lastKnobImage
{
    if (!HSEditPathLastKnobImage)
        HSEditPathLastKnobImage = [NSImage imageNamed:@"hRoundRed"];
    return HSEditPathLastKnobImage;
}

+ (id)selectedFirstKnobImage
{
    if (!HSEditPathSelectedFirstKnobImage)
        HSEditPathSelectedFirstKnobImage = [NSImage imageNamed:@"hRoundGreen_on"];
    return HSEditPathSelectedFirstKnobImage;
}

+ (id)firstKnobImage
{
    if (!HSEditPathFirstKnobImage)
        HSEditPathFirstKnobImage = [NSImage imageNamed:@"hRoundGreen"];
    return HSEditPathFirstKnobImage;
}

- (void)drawImage:(id)aImage forKnob:(NSInteger)aKnob path:(id)aPath
{
    NSRect rect = [self rectForKnob:aKnob path:aPath];
    [aImage drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
}

- (void)drawKnob:(NSInteger)aKnob path:(id)aPath
{
    BOOL selected = [[self delegate] editPathCanvasItem:self isSelectedKnob:aKnob];
    NSInteger first = [[self delegate] firstKnobIndexForEditPathCanvasItem:self];
    NSInteger last = [[self delegate] lastKnobIndexForEditPathCanvasItem:self];
    id image;
    if (first == aKnob)
        image = selected ? [[self class] selectedFirstKnobImage] : [[self class] firstKnobImage];
    else if (last == aKnob)
        image = selected ? [[self class] selectedLastKnobImage] : [[self class] lastKnobImage];
    else
        image = selected ? [[self class] selectedKnobImage] : [[self class] knobImage];
    [self drawImage:image forKnob:aKnob path:aPath];
}

- (BOOL)updateIfNeededInCanvasLayer:(id)aLayer
{
    return NO;
}

- (NSRect)contentPathBounds
{
    return [[self class] pathBoundsWithKnobOffset:[[self delegate] pathForEditPathCanvasItem:self]];
}

- (NSRect)renderingBoundsInCanvasLayer:(id)aLayer
{
    id path = [self pathForLayer:aLayer];
    if (!path)
        return [[[aLayer context] renderingView] bounds];
    return [[self class] pathBoundsWithKnobOffset:path];
}

// Unselected inner knobs first, then selected ones, then the end points.
- (void)renderRect:(NSRect)aRect inCanvasLayer:(id)aLayer isActive:(BOOL)aActive
{
    [super renderRect:aRect inCanvasLayer:aLayer isActive:aActive];
    id path = [self pathForLayer:aLayer];
    NSInteger i;
    for (i = 1; i < (NSInteger)[path elementCount] - 1; i++) {
        if (![[self delegate] editPathCanvasItem:self isSelectedKnob:i])
            [self drawKnob:i path:path];
    }
    for (i = 1; i < (NSInteger)[path elementCount] - 1; i++) {
        if ([[self delegate] editPathCanvasItem:self isSelectedKnob:i])
            [self drawKnob:i path:path];
    }
    [self drawKnob:0 path:path];
    [self drawKnob:[path elementCount] - 1 path:path];
}

// Checks the first knob, then the rest from the last down; NSNotFound if none is hit.
- (NSUInteger)knobAtViewPoint:(NSPoint)aPoint
{
    id path = [self pathForLayer:[[self delegate] layerForEditPathCanvasItem:self]];
    if (NSPointInRect(aPoint, [self rectForKnob:0 path:path]))
        return 0;
    NSUInteger count = [[self delegate] knobCountForEditPathCanvasItem:self];
    NSUInteger remaining = count;
    for (NSUInteger i = 0; i != count; i++) {
        remaining--;
        if (NSPointInRect(aPoint, [self rectForKnob:remaining path:path]))
            return remaining;
    }
    return NSNotFound;
}

- (NSRect)rectForKnob:(NSInteger)aKnob path:(id)aPath
{
    NSPoint points[3];
    [aPath elementAtIndex:aKnob associatedPoints:points];
    NSPoint offset = [[self class] knobOffset];
    NSSize size = [(NSImage *)[[self class] knobImage] size];
    return NSMakeRect(points[0].x - offset.x, points[0].y - offset.y, size.width, size.height);
}

- (void)setDelegate:(id)aDelegate
{
    [super setDelegate:aDelegate];
}

@end
