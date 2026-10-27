#import "HSSystemTextViewAttributesSharedProvider.h"
@implementation HSSystemTextViewAttributesSharedProvider
+ (id)systemTextViewAttributesSharedProvider
{
    static id provider = nil;
    if (provider == nil)
        provider = [[self class] new];
    return provider;
}
- (void)setSpaceBetweenCharacters:(CGFloat)aCharacters
{
    _spaceBetweenCharacters = aCharacters;
}
- (CGFloat)spaceBetweenCharacters
{
    return _spaceBetweenCharacters;
}
- (void)setSharedSystemTextViewAttributes:(id)aAttributes
{
    if (_sharedSystemTextViewAttributes != aAttributes) {
        [_sharedSystemTextViewAttributes release];
        _sharedSystemTextViewAttributes = [aAttributes copy];
    }
}
- (id)sharedSystemTextViewAttributes
{
    return _sharedSystemTextViewAttributes;
}
- (void)dealloc
{
    [_sharedSystemTextViewAttributes release];
    [super dealloc];
}
@end
