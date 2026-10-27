#import "HyperStudioPrefix.h"
#import "HSSOTSLayout.h"


@interface HSSOTSWithDrawerLayout : HSSOTSLayout
{
    NSSize _drawerSize;
}
- (id)layoutForObjectFrame:(NSRect)aFrame cardViewFrame:(NSRect)aFrame2 windowSize:(NSSize)aSize currentWindowSize:(NSSize)aSize2 primaryObstacleRects:(id)aRects secondaryObstacleRects:(id)aRects2 shouldNotCoverObjectForInspector:(BOOL)aInspector oldLayout:(id)aLayout;
- (NSSize)drawerSize;
- (void)setDrawerSize:(NSSize)aSize;
@end

