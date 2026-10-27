#import "NSURL+HSExtensions.h"
@implementation NSURL (HSExtensions)
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        NSStringFromClass([self class]), EXClassNameKey,
        [self absoluteString], @"absoluteString",
        nil];
}
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    [self release];
    return [[NSURL alloc] initWithString:[aDictionary objectForKey:@"absoluteString"]];
}
- (BOOL)canBeExtraPostLoaded
{
    return NO;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
@end
