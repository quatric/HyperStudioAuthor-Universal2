#import "HyperStudioPrefix.h"


@interface HSSOTSLayout : NSObject <HSObjectAssistantLayout, NSObject>
{
}
- (id)layoutForObjectFrame:(NSRect)aFrame cardViewFrame:(NSRect)aFrame2 windowSize:(NSSize)aSize currentWindowSize:(NSSize)aSize2 primaryObstacleRects:(id)aRects secondaryObstacleRects:(id)aRects2 shouldNotCoverObjectForInspector:(BOOL)aInspector oldLayout:(id)aLayout;
- (CGFloat)deltaForObstacleRects:(id)aRects withRect:(NSRect)aRect;
- (NSRect)layoutSize:(NSSize)aSize around:(CGFloat)aAround inRect:(NSRect)aRect horizontally:(BOOL)aHorizontally near:(BOOL)aNear;
- (NSInteger)minItemIndex:(float *)aIndex count:(NSInteger)aCount;
@end

