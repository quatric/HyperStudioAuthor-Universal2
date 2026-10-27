#import "HSRangeKnobsCell.h"

// The start and finish knobs of a range cell (its parent), dragged to set
// the range; gray while inactive, in the control tint while dragged.

// compositeToPoint:operation: in the original.
static void HSRangeKnobsCellComposite(NSImage *aImage, NSPoint aPoint, BOOL aFlipped)
{
    NSSize size = [aImage size];
    NSRect rect = NSMakeRect(aPoint.x, aFlipped ? aPoint.y - size.height : aPoint.y, size.width, size.height);
    [aImage drawInRect:rect fromRect:NSMakeRect(0, 0, size.width, size.height) operation:NSCompositingOperationSourceOver fraction:1 respectFlipped:YES hints:nil];
}

// The knob images in the current control tint.
static NSImage *HSRangeKnobsCellTintImage(Class aClass, NSString *aFormat)
{
    NSString *tint = [NSColor currentControlTint] == NSGraphiteControlTint ? @"Graphite" : @"Aqua";
    NSString *path = [[NSBundle bundleForClass:aClass] pathForResource:[NSString stringWithFormat:aFormat, tint] ofType:@"tiff"];
    return [[NSImage alloc] initWithContentsOfFile:path];
}

@implementation HSRangeKnobsCell

// Both knobs side by side.
+ (NSSize)minimalCellSize
{
    static NSSize size;
    if (NSEqualSizes(size, NSZeroSize)) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSImage *left = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"LeftGrayKnob" ofType:@"tiff"]];
        NSImage *right = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"RightGrayKnob" ofType:@"tiff"]];
        if (left != nil && right != nil) {
            NSSize leftSize = [left size];
            NSSize rightSize = [right size];
            size = NSMakeSize(leftSize.width + rightSize.width, MAX(leftSize.height, rightSize.height));
        }
        [left release];
        [right release];
    }
    return size;
}

+ (BOOL)prefersTrackingUntilMouseUp
{
    return YES;
}

- (void)setParent:(id)aParent
{
    _parent = aParent;
}

- (id)parent
{
    return _parent;
}

- (NSRect)rightKnobImageFrameForImageSize:(NSSize)aSize inFrame:(NSRect)aFrame
{
    NSRect rect = NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, aSize.width, aSize.height);
    if (NSEqualRects(aFrame, NSZeroRect))
        return rect;
    HSRangeCell *parent = _parent;
    CGFloat position = [parent positionFromFinishTimeSecondsValueInFrame:aFrame];
    rect = NSOffsetRect(rect, [[self class] minimalCellSize].width * 0.5 + position, 0);
    if ([(NSView *)[parent controlView] isFlipped])
        rect.origin.y = rect.origin.y + aFrame.size.height - rect.size.height;
    return rect;
}

- (NSRect)leftKnobImageFrameForImageSize:(NSSize)aSize inFrame:(NSRect)aFrame
{
    NSRect rect = NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, aSize.width, aSize.height);
    if (NSEqualRects(aFrame, NSZeroRect))
        return rect;
    HSRangeCell *parent = _parent;
    rect = NSOffsetRect(rect, [parent positionFromStartTimeSecondsValueInFrame:aFrame], 0);
    if ([(NSView *)[parent controlView] isFlipped])
        rect.origin.y = rect.origin.y + aFrame.size.height - rect.size.height;
    return rect;
}

- (NSRect)rightKnobImageRectInFrame:(NSRect)aFrame
{
    return [self rightKnobImageFrameForImageSize:[_rightKnobImage size] inFrame:aFrame];
}

- (NSRect)leftKnobImageRectInFrame:(NSRect)aFrame
{
    return [self leftKnobImageFrameForImageSize:[_leftKnobImage size] inFrame:aFrame];
}

- (void)stopTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView mouseIsUp:(BOOL)aUp
{
    _leftKnobImage = _currentTintInactiveLeftKnobImage;
    _rightKnobImage = _currentTintInactiveRightKnobImage;
}

// Moves the dragged knob keeping the mouse where it took it.
- (BOOL)continueTracking:(NSPoint)aTracking at:(NSPoint)aAt inView:(id)aView
{
    NSView *view = aView;
    CGFloat offset = 0;
    if (_activeKnobsMask & 1)
        offset = aTracking.x - [self leftKnobImageRectInFrame:[view bounds]].origin.x;
    else if (_activeKnobsMask & 2)
        offset = aTracking.x - [self rightKnobImageRectInFrame:[view bounds]].origin.x;
    [self trackActiveKnobWithOffset:aAt.x - offset inFrame:[view bounds]];
    if ([view isKindOfClass:[NSControl class]])
        [(NSControl *)view sendAction:[(HSRangeCell *)_parent action] to:[(HSRangeCell *)_parent target]];
    return YES;
}

// Takes the knob under the mouse (telling the parent's target).
- (BOOL)startTrackingAt:(NSPoint)aAt inView:(id)aView
{
    NSControl *view = aView;
    HSRangeCell *parent = _parent;
    if (NSPointInRect(aAt, [self leftKnobImageRectInFrame:[view bounds]])) {
        [parent setFocusedKnobs:1];
        [view sendAction:[parent leftKnobClickAction] to:[parent target]];
        _leftKnobImage = _currentTintActiveLeftKnobImage;
        _activeKnobsMask = 1;
    } else if (NSPointInRect(aAt, [self rightKnobImageRectInFrame:[view bounds]])) {
        [parent setFocusedKnobs:2];
        [view sendAction:[parent rightKnobClickAction] to:[parent target]];
        _rightKnobImage = _currentTintActiveRightKnobImage;
        _activeKnobsMask = 2;
    } else
        return NO;
    return YES;
}

- (void)trackActiveKnobWithOffset:(CGFloat)aOffset inFrame:(NSRect)aFrame
{
    HSRangeCell *parent = _parent;
    if (_activeKnobsMask == 2) {
        CGFloat width = [self rightKnobImageRectInFrame:aFrame].size.width;
        [parent setFinishTime:[parent secondsValueAtPosition:aOffset - width inFrame:aFrame]];
    } else if (_activeKnobsMask == 1)
        [parent setStartTime:[parent secondsValueAtPosition:aOffset inFrame:aFrame]];
}

- (void)drawRightKnobAtPosition:(CGFloat)aPosition inView:(id)aView inRect:(NSRect)aRect
{
    NSRect knob = [self rightKnobImageRectInFrame:aRect];
    BOOL flipped = [(NSView *)aView isFlipped];
    CGFloat y = aRect.origin.y;
    if (flipped)
        y = aRect.size.height - [[self class] minimalCellSize].height + knob.size.height;
    NSPoint point = NSMakePoint(ceil(knob.size.width + aPosition), y);
    HSRangeCell *parent = _parent;
    if ([parent showsFirstResponder] && ([parent focusedKnobs] & 2)) {
        [NSGraphicsContext saveGraphicsState];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSSetFocusRingStyle(NSFocusRingAbove);
#pragma clang diagnostic pop
        HSRangeKnobsCellComposite(_rightKnobImage, point, flipped);
        [NSGraphicsContext restoreGraphicsState];
    } else
        HSRangeKnobsCellComposite(_rightKnobImage, point, flipped);
}

- (void)drawLeftKnobAtPosition:(CGFloat)aPosition inView:(id)aView inRect:(NSRect)aRect
{
    NSRect knob = [self leftKnobImageRectInFrame:aRect];
    BOOL flipped = [(NSView *)aView isFlipped];
    CGFloat y = aRect.origin.y;
    if (flipped)
        y = aRect.size.height - [[self class] minimalCellSize].height + knob.size.height;
    NSPoint point = NSMakePoint(floor(aPosition), y);
    HSRangeCell *parent = _parent;
    if ([parent showsFirstResponder] && ([parent focusedKnobs] & 1)) {
        [NSGraphicsContext saveGraphicsState];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSSetFocusRingStyle(NSFocusRingAbove);
#pragma clang diagnostic pop
        HSRangeKnobsCellComposite(_leftKnobImage, point, flipped);
        [NSGraphicsContext restoreGraphicsState];
    } else
        HSRangeKnobsCellComposite(_leftKnobImage, point, flipped);
}

- (void)drawInteriorWithFrame:(NSRect)aFrame inView:(id)aView
{
    if (_leftKnobImage == nil || _rightKnobImage == nil || ![self isEnabled])
        return;
    HSRangeCell *parent = _parent;
    [self drawLeftKnobAtPosition:[parent positionFromStartTimeSecondsValueInFrame:aFrame] inView:aView inRect:aFrame];
    [self drawRightKnobAtPosition:[parent positionFromFinishTimeSecondsValueInFrame:aFrame] inView:aView inRect:aFrame];
}

// The knobs keep their state (active or not) across a tint change.
- (void)reloadImages
{
    BOOL rightInactive = _rightKnobImage == _currentTintInactiveRightKnobImage;
    BOOL leftInactive = _leftKnobImage == _currentTintInactiveLeftKnobImage;
    _rightKnobImage = nil;
    _leftKnobImage = nil;
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    [_currentTintInactiveLeftKnobImage release];
    _currentTintInactiveLeftKnobImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"LeftGrayKnob" ofType:@"tiff"]];
    [_currentTintInactiveRightKnobImage release];
    _currentTintInactiveRightKnobImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"RightGrayKnob" ofType:@"tiff"]];
    [_currentTintActiveLeftKnobImage release];
    _currentTintActiveLeftKnobImage = HSRangeKnobsCellTintImage([self class], @"Left%@Knob");
    [_currentTintActiveRightKnobImage release];
    _currentTintActiveRightKnobImage = HSRangeKnobsCellTintImage([self class], @"Right%@Knob");
    _leftKnobImage = leftInactive ? _currentTintInactiveLeftKnobImage : _currentTintActiveLeftKnobImage;
    _rightKnobImage = rightInactive ? _currentTintInactiveRightKnobImage : _currentTintActiveRightKnobImage;
}

- (void)controlTintDidChange:(id)aChange
{
    [self reloadImages];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _leftKnobImage = nil;
    _rightKnobImage = nil;
    [_currentTintInactiveLeftKnobImage release];
    [_currentTintInactiveRightKnobImage release];
    [_currentTintActiveLeftKnobImage release];
    [_currentTintActiveRightKnobImage release];
    [super dealloc];
}

- (id)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTintDidChange:) name:NSControlTintDidChangeNotification object:nil];
        [self reloadImages];
    }
    return self;
}

@end
