#import "HyperPlayerBasePrefix.h"
#import "HSPresentationContext.h"


@interface HSEditingContext : HSPresentationContext
{
}
- (BOOL)canOpenObjectInEditor;
- (BOOL)needsHistory;
- (NSInteger)renderQuality;
- (BOOL)allowsEditing;
@end

