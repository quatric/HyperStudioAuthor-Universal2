#import "HyperStudioPrefix.h"


@interface HSInspectorCenteringLayout : NSObject <HSObjectAssistantLayout, NSObject>
{
}
- (id)layoutForObjectFrame:(NSRect)aFrame cardViewFrame:(NSRect)aFrame2 windowSize:(NSSize)aSize currentWindowSize:(NSSize)aSize2 primaryObstacleRects:(id)aRects secondaryObstacleRects:(id)aRects2 shouldNotCoverObjectForInspector:(BOOL)aInspector oldLayout:(id)aLayout;
@end

