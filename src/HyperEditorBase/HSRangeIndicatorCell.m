#import "HSRangeIndicatorCell.h"

// The draggable indicator of a range control: a grey track and, when
// enabled, the active range in the control tint, both with bound images at
// their ends. Dragging it moves the range, keeping its length.

// compositeToPoint:fromRect:operation:fraction: (gone): the image upright
// with its bottom left corner at the point.
static void HSRangeIndicatorCellComposite(NSImage *aImage, NSPoint aPoint, BOOL aFlipped)
{
    NSSize size = [aImage size];
    NSRect rect = NSMakeRect(aPoint.x, aFlipped ? aPoint.y - size.height : aPoint.y, size.width, size.height);
    [aImage drawInRect:rect fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositingOperationSourceOver fraction:1 respectFlipped:YES hints:nil];
}

@implementation HSRangeIndicatorCell

// Two bound images wide.
+ (NSSize)minimalCellSize
{
    static NSSize size;
    if (NSEqualSizes(size, NSZeroSize)) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"GrayIndicatorBound" ofType:@"tiff"]];
        if (image != nil) {
            NSSize imageSize = [image size];
            [image release];
            size = NSMakeSize(imageSize.width + imageSize.width, imageSize.height);
        }
    }
    return size;
}

- (void)setParent:(id)aParent
{
    if (_parent != aParent)
        _parent = aParent;
}

- (id)parent
{
    return _parent;
}

- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView
{
    HSRangeCell *parent = _parent;
    NSRect frame = [aView bounds];
    NSRect active = [parent activeIndicatorRectInFrame:frame];
    float length = [parent indicatorLengthForFrame:frame];
    double span = [parent finishTime] - [parent startTime];
    float offset = ((float)frame.size.width - length) * 0.5f + (float)aTracking.x - (float)active.origin.x;
    double start = [parent secondsValueAtPosition:(float)aAt.x - offset inFrame:frame];
    if (start < 0) {
        [parent setStartTime:0];
        [parent setFinishTime:span];
    } else if (start + span <= [parent duration]) {
        [parent setStartTime:start];
        [parent setFinishTime:start + span];
    } else {
        [parent setFinishTime:[parent duration]];
        [parent setStartTime:[parent finishTime] - span];
    }
    if ([aView isKindOfClass:[NSControl class]])
        [(NSControl *)aView sendAction:[parent action] to:[parent target]];
    return YES;
}

- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView
{
    HSRangeCell *parent = _parent;
    return NSPointInRect(aAt, [parent activeIndicatorRectInFrame:[aView bounds]]);
}

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    HSRangeCell *parent = _parent;
    BOOL flipped = [aView isFlipped];
    if (flipped) {
        [_indicatorImage setFlipped:YES];
        [_activeIndicatorImage setFlipped:YES];
    }
    NSRect rect = [parent indicatorRectInFrame:aFrame];
    rect.origin.x -= 1;
    rect.origin.y -= 1;
    rect.size.width += 2;
    NSSize size = [_indicatorImage size];
    [_indicatorImage drawInRect:rect fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositingOperationSourceOver fraction:1];
    NSSize boundSize = [_indicatorBoundImage size];
    float y = boundSize.height + rect.origin.y;
    HSRangeIndicatorCellComposite(_indicatorBoundImage, NSMakePoint(rect.origin.x, y), flipped);
    HSRangeIndicatorCellComposite(_indicatorBoundImage, NSMakePoint(rect.origin.x + rect.size.width - 1, y), flipped);
    if (![self isEnabled])
        return;
    float start = rect.origin.x + [parent positionFromStartTimeSecondsValueInFrame:aFrame];
    float width = ([parent positionFromFinishTimeSecondsValueInFrame:aFrame] - start) + rect.origin.x + 1;
    float left = floorf(start);
    width += start - left;
    size = [_activeIndicatorImage size];
    [_activeIndicatorImage drawInRect:NSMakeRect(left, rect.origin.y, width, boundSize.height) fromRect:NSMakeRect(0, 0, size.width, size.height)
                            operation:NSCompositingOperationSourceOver fraction:1];
    HSRangeIndicatorCellComposite(_activeIndicatorBoundImage, NSMakePoint(left, y), flipped);
    HSRangeIndicatorCellComposite(_activeIndicatorBoundImage, NSMakePoint(left + width, y), flipped);
}

- (void)controlTintDidChange:(id)aChange
{
    [self setupImages];
}

- (void)setupImages
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    [_indicatorImage release];
    _indicatorImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"GrayIndicator" ofType:@"tiff"]];
    [_indicatorBoundImage release];
    _indicatorBoundImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"GrayIndicatorBound" ofType:@"tiff"]];
    NSString *tint = [NSColor currentControlTint] == NSGraphiteControlTint ? @"Graphite" : @"Aqua";
    [_activeIndicatorImage release];
    _activeIndicatorImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:[NSString stringWithFormat:@"%@Indicator", tint] ofType:@"tiff"]];
    [_activeIndicatorBoundImage release];
    _activeIndicatorBoundImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:[NSString stringWithFormat:@"%@IndicatorBound", tint] ofType:@"tiff"]];
}

- (void)dealloc
{
    [_activeIndicatorImage release];
    [_indicatorImage release];
    [_indicatorBoundImage release];
    [_activeIndicatorBoundImage release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        [self setupImages];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTintDidChange:) name:NSControlTintDidChangeNotification object:nil];
    }
    return self;
}

@end
