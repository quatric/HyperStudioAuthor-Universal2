#import "HyperPlayerBasePrefix.h"
#import "HSPresentationContext.h"


@interface HSSlideshowContext : HSPresentationContext
{
}
- (BOOL)isSlideshowContext;
- (NSInteger)renderQuality;
- (BOOL)supportsRotatableObjects;
- (BOOL)supportsResizableObjects;
- (BOOL)supportsDraggableObjects;
- (BOOL)allowsEditing;
- (BOOL)supportsOwnActions;
- (BOOL)supportsUserActions;
@end

