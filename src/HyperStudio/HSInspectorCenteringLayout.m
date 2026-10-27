#import "HSInspectorCenteringLayout.h"

@implementation HSInspectorCenteringLayout

// The window centered over the card view; the pop-up animation starts from
// its center point and grows through a frame 15 points larger.
- (id)layoutForObjectFrame:(NSRect)aFrame cardViewFrame:(NSRect)aFrame2 windowSize:(NSSize)aSize currentWindowSize:(NSSize)aSize2 primaryObstacleRects:(id)aRects secondaryObstacleRects:(id)aRects2 shouldNotCoverObjectForInspector:(BOOL)aInspector oldLayout:(id)aLayout
{
    NSRect window = NSMakeRect(NSMidX(aFrame2) - aSize.width * 0.5f, NSMidY(aFrame2) - aSize.height * 0.5f, aSize.width, aSize.height);
    NSValue *middle = [NSValue valueWithRect:NSIntegralRect(NSInsetRect(window, -15.0, -15.0))];
    NSValue *start = [NSValue valueWithRect:NSMakeRect(NSMidX(window), NSMidY(window), 0.0, 0.0)];
    NSValue *frame = [NSValue valueWithRect:NSIntegralRect(window)];
    return [NSDictionary dictionaryWithObjectsAndKeys:frame, HSObjectAssistantLayoutWindowFrame,
                                                      start, HSObjectAssistantLayoutPopUpStartFrame,
                                                      middle, HSObjectAssistantLayoutPopUpMiddleFrame, nil];
}

@end
