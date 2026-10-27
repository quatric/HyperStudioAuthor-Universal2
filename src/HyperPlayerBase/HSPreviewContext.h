#import "HyperPlayerBasePrefix.h"
#import "HSPresentationContext.h"


@interface HSPreviewContext : HSPresentationContext
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

