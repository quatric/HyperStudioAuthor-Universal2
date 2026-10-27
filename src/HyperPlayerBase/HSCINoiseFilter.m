#import "HSCINoiseFilter.h"
@implementation HSCINoiseFilter
+ (id)customFilterCategories
{
    return [NSArray arrayWithObject:kCICategoryStillImage];
}
+ (id)customFilterPath
{
    return [[NSBundle bundleForClass:self] pathForResource:[self customFilterName] ofType:@"qtz"];
}
+ (id)customFilterName
{
    return NSStringFromClass(self);
}
@end
