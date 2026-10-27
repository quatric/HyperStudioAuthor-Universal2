#import "HSCardObject.h"
@implementation HSCardObject
- (id)basename
{
    return @"Object";
}
- (id)wrapperExtension
{
    return @"hsobject";
}
- (BOOL)isItemProxy
{
    return NO;
}
- (BOOL)isLeaf
{
    return YES;
}
@end
