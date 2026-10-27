#import "HSValueConstraints.h"
@implementation HSValueConstraints
static HSValueConstraints *sSharedConstraints;
+ (id)sharedConstraints
{
    if (sSharedConstraints == nil)
        sSharedConstraints = [HSValueConstraints new];
    return sSharedConstraints;
}
// HSDefaultMaxValue for keys without their own constraint.
- (id)constraintForKey:(id)aKey
{
    id constraint = [[self constraintsDictionary] objectForKey:aKey];
    if (constraint == nil)
        constraint = [[self constraintsDictionary] objectForKey:@"HSDefaultMaxValue"];
    return constraint;
}
- (id)constraintsDictionary
{
    if (_constraintsDictionary == nil)
        _constraintsDictionary = [[HSPlayerBaseID extraDictionaryNamed:@"HSValueConstraints"] retain];
    return _constraintsDictionary;
}
- (void)dealloc
{
    [_constraintsDictionary release];
    [super dealloc];
}
@end
@implementation NSObject (HSValueConstraints)
// The <attribute><aValue>Value constraint (e.g. "opacityMaxValue" for
// aValue "Max"): the object's own method of that name, else the
// HSValueConstraints entry of that name, else HSDefault<aValue>Value.
- (id)hyperConstraintValue:(id)aValue forAttribute:(SEL)aAttribute
{
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@%@Value", NSStringFromSelector(aAttribute), aValue]);
    NSDictionary *constraints = [[HSValueConstraints sharedConstraints] constraintsDictionary];
    if ([self respondsToSelector:selector])
        return [self performSelector:selector];
    if ([constraints objectForKey:NSStringFromSelector(selector)] != nil)
        return [constraints objectForKey:NSStringFromSelector(selector)];
    return [constraints objectForKey:[NSString stringWithFormat:@"HSDefault%@Value", aValue]];
}
@end
