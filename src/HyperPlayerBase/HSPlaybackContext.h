#import "HyperPlayerBasePrefix.h"
#import "HSPresentationContext.h"


@interface HSPlaybackContext : HSPresentationContext
{
}
- (BOOL)canOpenObjectInPlayer;
- (BOOL)needsHistory;
- (NSInteger)renderQuality;
- (BOOL)supportsRotatableObjects;
- (BOOL)supportsResizableObjects;
- (BOOL)supportsDraggableObjects;
- (BOOL)supportsOwnActions;
- (BOOL)supportsUserActions;
@end

