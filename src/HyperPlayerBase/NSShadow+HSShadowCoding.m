#import "NSShadow+HSShadowCoding.h"
@implementation NSShadow (HSShadowCoding)
+ (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"shadowOffsetAsString", @"shadowBlurRadius", @"shadowColor", nil];
}
- (void)setShadowOffsetAsString:(id)aString
{
    [self setShadowOffset:NSSizeFromString(aString)];
}
- (id)shadowOffsetAsString
{
    return NSStringFromSize([self shadowOffset]);
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[self class] keysForExtraStoringWithCodingContext:aContext];
}
@end
