#import "HyperPlayerBasePrefix.h"
#import "HSPresentationContext.h"


@interface HSPrintingContext : HSPresentationContext
{
}
- (BOOL)isPrinting;
- (NSInteger)renderQuality;
- (BOOL)supportsDraggableObjects;
- (BOOL)supportsRotatableObjects;
- (BOOL)supportsResizableObjects;
- (BOOL)allowsEditing;
- (BOOL)supportsOwnActions;
- (BOOL)supportsUserActions;
@end

