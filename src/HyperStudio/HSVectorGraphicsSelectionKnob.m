#import "HSVectorGraphicsSelectionKnob.h"

static id HSVectorGraphicsSelectionKnobAttributes = nil;
static id HSVectorGraphicsSelectionKnobNormalImage = nil;
static id HSVectorGraphicsSelectionKnobTrackedImage = nil;

@implementation HSVectorGraphicsSelectionKnob

+ (id)affectingAttributes
{
    if (!HSVectorGraphicsSelectionKnobAttributes)
        HSVectorGraphicsSelectionKnobAttributes = [[NSEProtocolSet alloc] initWithProtocols:@protocol(HSVectorGraphicsBezierPathAttribute), @protocol(HSGeometryAttribute), nil];
    return HSVectorGraphicsSelectionKnobAttributes;
}

+ (id)beingTrackedActiveStateImage
{
    return nil;
}

+ (id)activeStateImage
{
    return nil;
}

+ (id)beingTrackedStateImage
{
    if (!HSVectorGraphicsSelectionKnobTrackedImage)
        HSVectorGraphicsSelectionKnobTrackedImage = [[NSImage imageNamed:@"hRomb_on"] retain];
    return HSVectorGraphicsSelectionKnobTrackedImage;
}

+ (id)normalStateImage
{
    if (!HSVectorGraphicsSelectionKnobNormalImage)
        HSVectorGraphicsSelectionKnobNormalImage = [[NSImage imageNamed:@"hRomb"] retain];
    return HSVectorGraphicsSelectionKnobNormalImage;
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inCanvasLayer:(id)aLayer
{
    return [HSCursor cursorNamed:HSArrowMoveCursor];
}

- (BOOL)isEqualToKnob:(id)aKnob
{
    if ([super isEqualToKnob:aKnob] && [aKnob isKindOfClass:[HSVectorGraphicsSelectionKnob class]])
        return [self associatedElementIndex] == [aKnob associatedElementIndex];
    return NO;
}

- (void)setValid:(BOOL)aValid
{
    _isValid = aValid;
}

- (BOOL)isValid
{
    return _isValid;
}

- (NSUInteger)associatedElementIndex
{
    return _associatedElementIndex;
}

// The knob image depends on the element: diamond for lines, round for curves,
// green at the start and red at the end of the path.
- (void)setAssociatedElementIndex:(NSUInteger)aIndex owner:(id)aOwner
{
    _isValid = aOwner != nil && (unsigned int)aIndex != 0xffffffff;
    if (_associatedElementIndex == (unsigned int)aIndex)
        return;
    _associatedElementIndex = (unsigned int)aIndex;
    [self invalidateCachedFrame];
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    id vectorAttributes = [aOwner queryHyperInterface:@protocol(HSVectorGraphicsAttributes)];
    NSUInteger type = [vectorAttributes hyperElementAtIndex:_associatedElementIndex associatedPoints:points];
    NSString *name;
    if (type <= 1)
        name = [@"h" stringByAppendingString:@"Romb"];
    else if (type == 2)
        name = [@"h" stringByAppendingString:@"Round"];
    else
        name = @"h";
    if (aIndex == 0)
        name = [name stringByAppendingString:@"Green"];
    else if ([vectorAttributes hyperElementCount] - 1 == aIndex)
        name = [name stringByAppendingString:@"Red"];
    [self setNormalStateImage:[NSImage imageNamed:name]];
    NSString *trackedName = [name stringByAppendingString:@"_on"];
    [self setBeingTrackedStateImage:[NSImage imageNamed:trackedName]];
    [self setActiveStateImage:[NSImage imageNamed:trackedName]];
}

- (void)drawWithFrame:(NSRect)aFrame owner:(id)aOwner inView:(id)aView invalidRect:(NSRect)aRect
{
    if (_isValid)
        [super drawWithFrame:aFrame owner:aOwner inView:aView invalidRect:aRect];
}

- (NSRect)calculateFrameForOwner:(id)aOwner inView:(id)aView
{
    NSPoint points[3] = { NSZeroPoint, NSZeroPoint, NSZeroPoint };
    [[aOwner queryHyperInterface:@protocol(HSVectorGraphicsAttributes)] hyperElementAtIndex:_associatedElementIndex associatedPoints:points];
    NSPoint point = [aView convertPointFromUserSpaceToViewSpace:points[0]];
    NSSize size = [self imageSize];
    NSRect frame = NSOffsetRect(NSMakeRect(point.x, point.y, size.width, size.height), size.width * -0.5f, size.height * -0.5f);
    return NSIntegralRect(frame);
}

- (BOOL)isVisible
{
    return _isValid && [super isVisible];
}

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
        _associatedElementIndex = 0xffffffff;
    return self;
}

- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    return [[HSVectorGraphicsSelectionTracker alloc] init];
}

@end
