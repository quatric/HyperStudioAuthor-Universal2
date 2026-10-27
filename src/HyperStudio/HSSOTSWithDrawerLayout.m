#import "HSSOTSWithDrawerLayout.h"

@implementation HSSOTSWithDrawerLayout

// Lays out as if the window were shorter by the drawer, then grows the window
// frame back; if that no longer fits on screen, retries with the grown frame
// as an extra obstacle.
- (id)layoutForObjectFrame:(NSRect)aFrame cardViewFrame:(NSRect)aFrame2 windowSize:(NSSize)aSize currentWindowSize:(NSSize)aSize2 primaryObstacleRects:(id)aRects secondaryObstacleRects:(id)aRects2 shouldNotCoverObjectForInspector:(BOOL)aInspector oldLayout:(id)aLayout
{
    NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
    float drawerHeight = _drawerSize.height;
    NSMutableDictionary *layout = [NSMutableDictionary dictionaryWithDictionary:[super layoutForObjectFrame:aFrame cardViewFrame:aFrame2 windowSize:NSMakeSize(aSize.width, aSize.height - drawerHeight) currentWindowSize:aSize2 primaryObstacleRects:aRects secondaryObstacleRects:aRects2 shouldNotCoverObjectForInspector:aInspector oldLayout:aLayout]];
    NSRect windowFrame = [[layout objectForKey:HSObjectAssistantLayoutWindowFrame] rectValue];
    windowFrame.size.height += drawerHeight;
    if ([[layout objectForKey:HSObjectAssistantLayoutWindowPosition] intValue] != 2) {
        windowFrame.origin.y -= drawerHeight;
        NSRect anchorFrame = [[layout objectForKey:HSObjectAssistantLayoutLocalAnchorFrame] rectValue];
        anchorFrame.origin.y += drawerHeight;
        [layout setObject:[NSValue valueWithRect:anchorFrame] forKey:HSObjectAssistantLayoutLocalAnchorFrame];
    }
    if (!NSContainsRect(visibleFrame, windowFrame))
        return [self layoutForObjectFrame:aFrame cardViewFrame:aFrame2 windowSize:aSize currentWindowSize:aSize2 primaryObstacleRects:aRects secondaryObstacleRects:[aRects2 arrayByAddingObject:[NSValue valueWithRect:windowFrame]] shouldNotCoverObjectForInspector:aInspector oldLayout:nil];
    [layout setObject:[NSValue valueWithRect:windowFrame] forKey:HSObjectAssistantLayoutWindowFrame];
    return layout;
}

- (NSSize)drawerSize
{
    return _drawerSize;
}

- (void)setDrawerSize:(NSSize)aSize
{
    _drawerSize = aSize;
}

@end
