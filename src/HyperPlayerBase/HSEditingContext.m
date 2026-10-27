#import "HSEditingContext.h"
@implementation HSEditingContext
- (BOOL)canOpenObjectInEditor
{
    return YES;
}
- (BOOL)needsHistory
{
    return YES;
}
- (NSInteger)renderQuality
{
    return 2;
}
- (BOOL)allowsEditing
{
    return YES;
}
@end
