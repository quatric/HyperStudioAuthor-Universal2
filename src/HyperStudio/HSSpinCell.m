#import "HSSpinCell.h"

static NSPoint HSSpinCellSegmentOrigins[4] = { { 1.0f, 48.0f }, { 36.0f, 48.0f }, { 8.0f, 20.0f }, { 8.0f, 55.0f } };
static NSPoint HSSpinCellSpinImageOrigin = { 0.0f, 57.0f };

@implementation HSSpinCell

+ (BOOL)prefersTrackingUntilMouseUp
{
    return YES;
}

// The cell is a 4-way rocker: zones 1-4 are left, right, up and down (0 is none).
- (NSInteger)hitZoneForPoint:(NSPoint)aPoint
{
    float dy = aPoint.y - 29.0f;
    float dx = aPoint.x - 28.0f;
    float distance = sqrtf(dx * dx + dy * dy);
    int zone;
    if (27.0f <= distance || distance <= 11.5f)
        return 0;
    if (0.0f <= dx || fabsf(dx) <= fabsf(dy))
        zone = 0;
    else
        zone = 1;
    if (0.0f <= dx && fabsf(dy) < fabsf(dx))
        zone = 2;
    if (dy < 0.0f && fabsf(dx) < fabsf(dy))
        zone = 3;
    if (0.0f <= dy && fabsf(dx) < fabsf(dy))
        zone = 4;
    return zone;
}

- (id)segmentImageForZone:(NSInteger)aZone
{
    NSString *name;
    switch (aZone) {
    case 1:
        name = @"sc_left";
        break;
    case 2:
        name = @"sc_right";
        break;
    case 3:
        name = @"sc_up";
        break;
    case 4:
        name = @"sc_down";
        break;
    default:
        return nil;
    }
    return [NSImage imageNamed:name];
}

- (id)spinImage
{
    return [NSImage imageNamed:@"sc_grey"];
}

- (NSPoint)segmentOriginForZone:(NSInteger)aZone
{
    switch (aZone) {
    case 1:
        return HSSpinCellSegmentOrigins[0];
    case 2:
        return HSSpinCellSegmentOrigins[1];
    case 3:
        return HSSpinCellSegmentOrigins[2];
    case 4:
        return HSSpinCellSegmentOrigins[3];
    default:
        return NSZeroPoint;
    }
}

- (void)performClick:(id)aClick
{
    _prevHotZone = 0;
    [[self target] performSelector:[self action] withObject:self];
    [[self controlView] setKeyboardFocusRingNeedsDisplayInRect:[[self controlView] bounds]];
}

- (void)moveDown:(id)aDown
{
    _prevHotZone = 4;
    [[self target] performSelector:[self action] withObject:self];
    [[self controlView] setKeyboardFocusRingNeedsDisplayInRect:[[self controlView] bounds]];
}

- (void)moveUp:(id)aUp
{
    _prevHotZone = 3;
    [[self target] performSelector:[self action] withObject:self];
    [[self controlView] setKeyboardFocusRingNeedsDisplayInRect:[[self controlView] bounds]];
}

- (void)moveLeft:(id)aLeft
{
    _prevHotZone = 1;
    [[self target] performSelector:[self action] withObject:self];
    [[self controlView] setKeyboardFocusRingNeedsDisplayInRect:[[self controlView] bounds]];
}

- (void)moveRight:(id)aRight
{
    _prevHotZone = 2;
    [[self target] performSelector:[self action] withObject:self];
    [[self controlView] setKeyboardFocusRingNeedsDisplayInRect:[[self controlView] bounds]];
}

- (void)setIntValue:(int)aValue
{
    _prevHotZone = aValue;
    [[self controlView] setNeedsDisplay:YES];
}

- (int)intValue
{
    return _prevHotZone;
}

- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp
{
    if (aUp) {
        _prevHotZone = 0;
        [aView setNeedsDisplay:YES];
    }
}

- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView
{
    if (_isContinious)
        [[self target] performSelector:[self action] withObject:self];
    return YES;
}

- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView
{
    _prevHotZone = (int)[self hitZoneForPoint:aAt];
    if (_prevHotZone == 0)
        return NO;
    [aView setNeedsDisplay:YES];
    if (_isContinious)
        [[self target] performSelector:[self action] withObject:self];
    return YES;
}

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    [[self spinImage] compositeToPoint:HSSpinCellSpinImageOrigin operation:NSCompositeSourceOver];
    [[self segmentImageForZone:_prevHotZone] compositeToPoint:[self segmentOriginForZone:_prevHotZone] operation:NSCompositeSourceOver];
    if ([self showsFirstResponder]) {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(aFrame.origin.x, aFrame.origin.y, aFrame.size.width, aFrame.size.height - 2.0f)] fill];
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (BOOL)isOpaque
{
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setBordered:NO];
        [self setBezeled:NO];
        _isContinious = YES;
    }
    return self;
}

@end
