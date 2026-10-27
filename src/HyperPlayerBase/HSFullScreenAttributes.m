#import "HSFullScreenAttributes.h"
@implementation HSFullScreenAttributes
- (void)setBackGroundColor:(id)aColor
{
    if (_backGroundColor != aColor) {
        [_backGroundColor release];
        _backGroundColor = [aColor retain];
    }
}
- (id)backGroundColor
{
    return _backGroundColor;
}
- (void)dealloc
{
    [_backGroundColor release];
    [super dealloc];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:[@"_backGroundColor" extraKeyForMultiRepresentations], nil];
}
@end
