#import "HSGroupRenderCacheValidnessEvaluator.h"
// Two validness evaluators as one: the lower validness of the two. Equal
// to another pair of the same two either way round.
@implementation HSGroupRenderCacheValidnessEvaluator
- (id)validnessEvaluatorByMergingWithValidnessEvaluator:(id)aEvaluator
{
    if ([self containsValidnessEvaluator:aEvaluator])
        return self;
    return [[[HSGroupRenderCacheValidnessEvaluator alloc] initWithValidnessEvaluator:self andValidnessEvaluator:aEvaluator] autorelease];
}
- (CGFloat)evaluateForAffineTransform:(CGAffineTransform)aTransform withContentValidness:(CGFloat)aValidness contentAffineTransform:(CGAffineTransform)aTransform2
{
    float second = [_validnessEvaluator2 evaluateForAffineTransform:aTransform withContentValidness:aValidness contentAffineTransform:aTransform2];
    float first = [_validnessEvaluator1 evaluateForAffineTransform:aTransform withContentValidness:aValidness contentAffineTransform:aTransform2];
    return fminf(first, second);
}
- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSGroupRenderCacheValidnessEvaluator class]])
        return NO;
    Class class = [self class];
    // A subclass instance decides for itself.
    if ([aEqual isKindOfClass:class] && ![aEqual isMemberOfClass:class])
        return [aEqual isEqual:self];
    id first = [aEqual HSGroupRenderCacheValidnessEvaluator_validnessEvaluator1];
    id second = [aEqual HSGroupRenderCacheValidnessEvaluator_validnessEvaluator2];
    if ([first isEqual:_validnessEvaluator1] && [second isEqual:_validnessEvaluator2])
        return YES;
    return [first isEqual:_validnessEvaluator2] && [second isEqual:_validnessEvaluator1];
}
// Itself, or either part (looking into groups).
- (BOOL)containsValidnessEvaluator:(id)aEvaluator
{
    if ([self isEqual:aEvaluator])
        return YES;
    for (id part in [NSArray arrayWithObjects:_validnessEvaluator1, _validnessEvaluator2, nil]) {
        if ([part isKindOfClass:[HSGroupRenderCacheValidnessEvaluator class]]) {
            if ([part containsValidnessEvaluator:aEvaluator])
                return YES;
        } else if ([part isEqual:aEvaluator])
            return YES;
    }
    return NO;
}
- (id)HSGroupRenderCacheValidnessEvaluator_validnessEvaluator2
{
    return _validnessEvaluator2;
}
- (id)HSGroupRenderCacheValidnessEvaluator_validnessEvaluator1
{
    return _validnessEvaluator1;
}
- (void)dealloc
{
    [_validnessEvaluator1 release];
    [_validnessEvaluator2 release];
    [super dealloc];
}
- (id)initWithValidnessEvaluator:(id)aEvaluator andValidnessEvaluator:(id)aEvaluator2
{
    self = [super init];
    if (self != nil) {
        _validnessEvaluator1 = [aEvaluator retain];
        _validnessEvaluator2 = [aEvaluator2 retain];
    }
    return self;
}
- (id)init
{
    [self release];
    return nil;
}
@end
