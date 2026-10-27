#import "HSHyperImplementation.h"
@implementation HSHyperImplementation
- (id)implementationForHyperObject:(id)aObject
{
    if (_hyperObject == aObject)
        return self;
    return [[[[self class] alloc] initWithHyperObject:aObject] autorelease];
}
- (id)hyperObject
{
    return _hyperObject;
}
- (void)dealloc
{
    [_hyperObject release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject
{
    self = [super init];
    if (self != nil)
        _hyperObject = [aObject retain];
    return self;
}
@end
