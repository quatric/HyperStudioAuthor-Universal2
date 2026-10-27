#import "HSPrintingContext.h"
// Printing: still pictures.
@implementation HSPrintingContext
- (BOOL)isPrinting
{
    return YES;
}
- (NSInteger)renderQuality
{
    return 2;
}
- (BOOL)supportsDraggableObjects
{
    return NO;
}
- (BOOL)supportsRotatableObjects
{
    return NO;
}
- (BOOL)supportsResizableObjects
{
    return NO;
}
- (BOOL)allowsEditing
{
    return NO;
}
- (BOOL)supportsOwnActions
{
    return NO;
}
- (BOOL)supportsUserActions
{
    return NO;
}
@end
