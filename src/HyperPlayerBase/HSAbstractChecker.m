#import "HSAbstractChecker.h"
// A link in a chain of minimum-spec checks; each passes the check on to the
// next one, and one-shot checkers drop out after running.
@implementation HSAbstractChecker
- (void)dealloc
{
    [_nextInstance release];
    [super dealloc];
}
- (void)checkMinSpec
{
    if ([self nextInstance] != nil) {
        [[self nextInstance] checkMinSpec];
        if ([[self nextInstance] isOnce])
            [self setNextInstance:nil];
    }
}
- (id)initWithNextChecker:(id)aChecker
{
    self = [self init];
    if (self != nil)
        [self setNextInstance:aChecker];
    return self;
}
- (void)setIsManually:(BOOL)aManually
{
    _isManually = aManually;
}
- (BOOL)isManually
{
    return _isManually;
}
- (void)setIsOnce:(BOOL)aOnce
{
    _isOnce = aOnce;
}
- (BOOL)isOnce
{
    return _isOnce;
}
- (void)setNextInstance:(id)aInstance
{
    if (_nextInstance != aInstance) {
        [_nextInstance release];
        _nextInstance = [aInstance retain];
    }
}
- (id)nextInstance
{
    return _nextInstance;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray array];
}
@end
