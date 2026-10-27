#import "HyperPlayerBasePrefix.h"


@interface HSBorderlessAttributes : NSObject <EXKeyValueCoding>
{
    BOOL _needShadow;
    BOOL _isOnTop;
}
- (void)setIsOnTop:(BOOL)aTop;
- (BOOL)isOnTop;
- (void)setNeedShadow:(BOOL)aShadow;
- (BOOL)needShadow;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

