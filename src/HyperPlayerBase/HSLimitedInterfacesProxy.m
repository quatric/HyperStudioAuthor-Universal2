#import "HSLimitedInterfacesProxy.h"
@implementation HSLimitedInterfacesProxy
- (NSUInteger)hyperIdentifier
{
    return [_hyperObject hyperIdentifier];
}
// Only the allowed interfaces, each wrapped in a proxy whose parent is this one.
- (id)queryHyperInterface:(id)aInterface
{
    id identifier = [HSProtocolIdentifier identifierForProtocol:aInterface];
    if (![_allowedInterfaces containsObject:identifier])
        return nil;
    id implementation = [_hyperObject queryHyperInterface:aInterface];
    return [[[HSHyperImplementationProxy alloc] initWithImplementation:implementation forInterface:identifier parentObject:self] autorelease];
}
- (id)hyperObject
{
    return _hyperObject;
}
- (void)dealloc
{
    [_allowedInterfaces release];
    [_hyperObject release];
    [super dealloc];
}
- (id)initWithHyperObject:(id)aObject interfaces:(id)aInterfaces
{
    self = [super init];
    if (self != nil) {
        _hyperObject = [aObject retain];
        _allowedInterfaces = [aInterfaces retain];
    }
    return self;
}
@end
