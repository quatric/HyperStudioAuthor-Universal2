#import "HSBackwardObjectLink.h"
// Holds an object through its backward (non-owning) reference count; equal
// links point at the same object.
@implementation HSBackwardObjectLink
+ (id)linkToObject:(id)aObject
{
    return [[[self alloc] initWithObject:aObject] autorelease];
}
- (NSUInteger)hash
{
    return (NSUInteger)_object;
}
- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSBackwardObjectLink class]])
        return NO;
    Class class = [self class];
    // A subclass instance decides for itself.
    if (![aEqual isKindOfClass:class] || [aEqual isMemberOfClass:class])
        return _object == [aEqual object];
    return [aEqual isEqual:self];
}
- (id)object
{
    return _object;
}
- (void)dealloc
{
    [_object backwardRelease];
    [super dealloc];
}
- (id)init
{
    [self release];
    return nil;
}
- (id)initWithObject:(id)aObject
{
    self = [super init];
    if (self != nil)
        _object = [aObject backwardRetain];
    return self;
}
@end
