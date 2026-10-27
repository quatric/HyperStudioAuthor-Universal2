#import "HyperPlayerBasePrefix.h"
#import "HSAbstractChecker.h"


@interface HSSystemChecker : HSAbstractChecker
{
    NSArray *_checkers;
}
+ (id)sharedInstance;
- (void)dealloc;
- (void)checkMinSpec;
- (void)setCheckers:(id)aCheckers;
- (id)checkers;
- (id)init;
@end

