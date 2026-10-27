#import "HSSystemChecker.h"
static HSSystemChecker *HSSystemCheckerSharedInstance = nil;
@implementation HSSystemChecker
// The one checker, made from MinSpec.plist.
+ (id)sharedInstance
{
    if (HSSystemCheckerSharedInstance == nil)
        HSSystemCheckerSharedInstance = [[HSAbstractChecker objectWithExtraDictionary:[NSDictionary extraDictionaryNamed:@"MinSpec.plist"]] retain];
    return HSSystemCheckerSharedInstance;
}
- (void)dealloc
{
    [_checkers release];
    [super dealloc];
}
// Runs the automatic checkers; one-time ones are removed after running.
- (void)checkMinSpec
{
    NSUInteger count = [_checkers count];
    for (NSUInteger i = 0; i < count; i++) {
        id checker = [_checkers objectAtIndex:i];
        if ([checker isManually])
            continue;
        [checker checkMinSpec];
        if ([checker isOnce]) {
            [(NSMutableArray *)_checkers removeObjectAtIndex:i];
            i--;
            count = [_checkers count];
        }
    }
}
- (void)setCheckers:(id)aCheckers
{
    if (_checkers != aCheckers) {
        [_checkers release];
        _checkers = [aCheckers retain];
    }
}
- (id)checkers
{
    return _checkers;
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        if (HSSystemCheckerSharedInstance != nil) {
            [self release];
            return HSSystemCheckerSharedInstance;
        }
        HSSystemCheckerSharedInstance = self;
    }
    return self;
}
@end
