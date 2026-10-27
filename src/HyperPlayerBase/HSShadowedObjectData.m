#import "HSShadowedObjectData.h"
@implementation HSShadowedObjectData
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray arrayWithArray:[super keysForExtraStoringWithCodingContext:aContext]];
    [keys addObject:@"shadow"];
    [keys addObject:@"shadowEnabled"];
    return keys;
}
- (void)setShadowEnabled:(BOOL)aEnabled
{
    _shadowEnabled = aEnabled;
}
- (BOOL)isShadowEnabled
{
    return _shadowEnabled;
}
- (void)setShadow:(id)aShadow
{
    [aShadow retain];
    [_shadow release];
    _shadow = aShadow;
}
// Created on first use.
- (id)shadow
{
    if (_shadow == nil)
        _shadow = [NSShadow new];
    return _shadow;
}
- (void)dealloc
{
    [_shadow release];
    [super dealloc];
}
@end
