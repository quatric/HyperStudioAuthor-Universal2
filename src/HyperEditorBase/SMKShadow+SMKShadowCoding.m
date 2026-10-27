#import "SMKShadow+SMKShadowCoding.h"

// Stored as an NSShadow, with the offset as a string.

@implementation SMKShadow (SMKShadowCoding)

- (void)setShadowOffsetAsString:(id)aString
{
    [self setShadowOffset:NSSizeFromString(aString)];
}

- (id)shadowOffsetAsString
{
    return NSStringFromSize([self shadowOffset]);
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [[NSShadow class] keysForExtraStoringWithCodingContext:aContext];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}

- (id)extraClassNameForStoring
{
    return NSStringFromClass([NSShadow class]);
}

@end
