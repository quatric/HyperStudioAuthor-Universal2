#import "HyperPlayerBasePrefix.h"


@interface HSAbstractChecker : NSObject <EXKeyValueCoding>
{
    HSAbstractChecker *_nextInstance;
    BOOL _isOnce;
    BOOL _isManually;
}
- (void)dealloc;
- (void)checkMinSpec;
- (id)initWithNextChecker:(id)aChecker;
- (void)setIsManually:(BOOL)aManually;
- (BOOL)isManually;
- (void)setIsOnce:(BOOL)aOnce;
- (BOOL)isOnce;
- (void)setNextInstance:(id)aInstance;
- (id)nextInstance;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
@end

