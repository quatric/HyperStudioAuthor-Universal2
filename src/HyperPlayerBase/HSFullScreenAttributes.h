#import "HyperPlayerBasePrefix.h"


@interface HSFullScreenAttributes : NSObject <EXKeyValueCoding>
{
    NSColor *_backGroundColor;
}
- (void)setBackGroundColor:(id)aColor;
- (id)backGroundColor;
- (void)dealloc;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

