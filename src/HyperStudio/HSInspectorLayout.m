#import "HSInspectorLayout.h"

static const float kHSInspectorPadding = 15.0f;

@implementation HSInspectorLayout

- (void)setShouldCorrectWindowFrame:(BOOL)aFrame
{
    _shouldCorrectWindowFrame = aFrame;
}

- (BOOL)shouldCorrectWindowFrame
{
    return _shouldCorrectWindowFrame;
}

// The inspector keeps its top left corner; the pop-up animation starts at its center.
- (id)layoutForObjectFrame:(NSRect)aFrame cardViewFrame:(NSRect)aFrame2 windowSize:(NSSize)aSize currentWindowSize:(NSSize)aSize2 primaryObstacleRects:(id)aRects secondaryObstacleRects:(id)aRects2 shouldNotCoverObjectForInspector:(BOOL)aInspector oldLayout:(id)aLayout
{
    BOOL sizeChanged = !NSEqualSizes(aSize, aSize2);
    NSPoint topLeft = [self inspectorTopLeft];
    NSRect frame;

    if (NSEqualPoints(topLeft, NSZeroPoint))
        frame = NSMakeRect(_inspectorOrigin.x, _inspectorOrigin.y - (aSize.height - aSize2.height), aSize.width, aSize.height);
    else
        frame = NSMakeRect(topLeft.x, topLeft.y - aSize.height, aSize.width, aSize.height);
    if (aInspector)
        frame = [self calculateWindowFrame:frame shouldNotCoverObjectWithFrame:aFrame];
    if (sizeChanged || _shouldCorrectWindowFrame)
        frame = [HSPaletteController adjustFrameToFitVisibleScreenFrame:frame];
    [self setInspectorTopLeft:NSMakePoint(frame.origin.x, frame.origin.y + frame.size.height)];
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSValue valueWithRect:NSIntegralRect(NSInsetRect(frame, -kHSInspectorPadding, -kHSInspectorPadding))], HSObjectAssistantLayoutPopUpMiddleFrame,
        [NSValue valueWithRect:NSMakeRect(NSMidX(frame), NSMidY(frame), 0.0, 0.0)], HSObjectAssistantLayoutPopUpStartFrame,
        [NSValue valueWithRect:NSIntegralRect(frame)], HSObjectAssistantLayoutWindowFrame, nil];
}

// Moves the window to the right of the object, or to its left when it would still cover it.
// Original quirk kept: the second test is NSContainsRect, not an intersection.
- (NSRect)calculateWindowFrame:(NSRect)aFrame shouldNotCoverObjectWithFrame:(NSRect)aFrame2
{
    NSRect frame = aFrame;

    if (NSIntersectsRect(frame, aFrame2)) {
        frame.origin.x = NSMaxX(aFrame2) + kHSInspectorPadding;
        frame.origin.y = aFrame2.origin.y - kHSInspectorPadding - aFrame.size.height;
        frame = [HSPaletteController adjustFrameToFitVisibleScreenFrame:frame];
    }
    if (NSContainsRect(frame, aFrame2)) {
        frame.origin.x = aFrame2.origin.x - aFrame.size.width - kHSInspectorPadding;
        frame = [HSPaletteController adjustFrameToFitVisibleScreenFrame:frame];
    }
    return frame;
}

- (void)setInspectorTopLeft:(NSPoint)aLeft
{
    if (!NSEqualPoints(aLeft, _inspectorTopLeft)) {
        _inspectorTopLeft = aLeft;
        [[NSUserDefaults standardUserDefaults] setObject:NSStringFromPoint(_inspectorTopLeft) forKey:HSInspectorTopLeftKey];
    }
}

// Falls back to the older origin default, in which case the top left stays zero.
- (NSPoint)inspectorTopLeft
{
    if (!_originInitialized) {
        id topLeft = [[NSUserDefaults standardUserDefaults] objectForKey:HSInspectorTopLeftKey];
        id origin = [[NSUserDefaults standardUserDefaults] objectForKey:HSInspectorOriginKey];

        _inspectorOrigin = NSZeroPoint;
        _inspectorTopLeft = NSZeroPoint;
        if (topLeft != nil)
            _inspectorTopLeft = NSPointFromString(topLeft);
        else if (origin != nil)
            _inspectorOrigin = NSPointFromString(origin);
        _originInitialized = YES;
    }
    return _inspectorTopLeft;
}

@end
