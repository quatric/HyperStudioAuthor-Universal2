#import "HyperPlayerBasePrefix.h"


@interface HSSystemTextViewAttributesSharedProvider : NSObject
{
    NSDictionary *_sharedSystemTextViewAttributes;
    float _spaceBetweenCharacters;
}
+ (id)systemTextViewAttributesSharedProvider;
- (void)setSpaceBetweenCharacters:(CGFloat)aCharacters;
- (CGFloat)spaceBetweenCharacters;
- (void)setSharedSystemTextViewAttributes:(id)aAttributes;
- (id)sharedSystemTextViewAttributes;
- (void)dealloc;
@end

