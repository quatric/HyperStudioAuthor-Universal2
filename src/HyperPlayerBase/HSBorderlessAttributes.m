#import "HSBorderlessAttributes.h"
@implementation HSBorderlessAttributes
- (void)setIsOnTop:(BOOL)aTop
{
    if (_isOnTop != aTop)
        _isOnTop = aTop;
}
- (BOOL)isOnTop
{
    return _isOnTop;
}
- (void)setNeedShadow:(BOOL)aShadow
{
    if (_needShadow != aShadow)
        _needShadow = aShadow;
}
- (BOOL)needShadow
{
    return _needShadow;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"_needShadow", @"_isOnTop", nil];
}
@end
