#import "HSCFObject.h"
@implementation HSCFObject
+ (id)wrapperForCFObject:(void *)aObject
{
    return [[[self alloc] initWithCFObject:aObject] autorelease];
}
// Hands a +1 CF object to the autorelease pool (through a wrapper that
// releases it).
+ (void *)autoreleasedCFObject:(void *)aObject
{
    if (aObject != NULL)
        [self wrapperForCFObject:aObject];
    return aObject;
}
- (void *)CFObject
{
    return _CFObject;
}
- (void)dealloc
{
    if (_CFObject != NULL)
        CFRelease(_CFObject);
    [super dealloc];
}
- (id)initWithCFObject:(void *)aObject
{
    self = [super init];
    if (self != nil)
        _CFObject = aObject;
    return self;
}
@end
