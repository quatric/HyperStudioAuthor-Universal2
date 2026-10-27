#import "HyperPlayerBasePrefix.h"
#import "HSSlideshowAttributes.h"


@interface HSPictureshowAttributes : HSSlideshowAttributes
{
}
+ (id)defaultPictureshowAttributes;
- (BOOL)useClickOnNextSlide;
- (BOOL)useKeystrokeOnNextSlide;
- (BOOL)useKeystrokeOnExitCard:(id)aCard;
@end

