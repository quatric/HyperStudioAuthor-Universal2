#import "NSTextTab+EXTextTab.h"
@implementation NSTextTab (EXTextTab)
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        NSStringFromClass([NSTextTab class]), EXClassNameKey,
        [NSNumber numberWithFloat:[self location]], @"location",
        [NSNumber numberWithInt:(int)[self tabStopType]], @"tabStopType",
        nil];
}
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    [self release];
    return [[NSTextTab alloc] initWithType:[[aDictionary objectForKey:@"tabStopType"] intValue]
                                  location:[[aDictionary objectForKey:@"location"] floatValue]];
}
- (BOOL)canBeExtraPostLoaded
{
    return NO;
}
@end
