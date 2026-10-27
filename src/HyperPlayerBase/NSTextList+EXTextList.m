#import "NSTextList+EXTextList.h"
@implementation NSTextList (EXTextList)
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        NSStringFromClass([NSTextList class]), EXClassNameKey,
        [self markerFormat], @"markerFormat",
        [NSNumber numberWithUnsignedInt:(unsigned int)[self listOptions]], @"listOptions",
        nil];
}
- (id)initWithExtraDictionary:(id)aDictionary codingContext:(id)aContext
{
    [self release];
    return [[NSTextList alloc] initWithMarkerFormat:[aDictionary objectForKey:@"markerFormat"]
                                            options:[[aDictionary objectForKey:@"listOptions"] unsignedIntValue]];
}
- (BOOL)canBeExtraPostLoaded
{
    return NO;
}
@end
