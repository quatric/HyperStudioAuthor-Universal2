#import "HyperPlayerBasePrefix.h"
#import "HSPresentationContext.h"


@interface HSPlayerPreviewContext : HSPresentationContext
{
}
- (NSInteger)renderQuality;
- (BOOL)supportsRotatableObjects;
- (BOOL)supportsResizableObjects;
- (BOOL)supportsDraggableObjects;
- (BOOL)allowsEditing;
- (BOOL)supportsOwnActions;
- (BOOL)supportsUserActions;
@end

