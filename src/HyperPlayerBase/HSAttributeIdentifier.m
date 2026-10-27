#import "HSAttributeIdentifier.h"
// An attribute: a selector of an interface (protocol).
@implementation HSAttributeIdentifier
+ (id)attributeIdentifierWithInterface:(id)aInterface selector:(SEL)aSelector
{
    return [[[self alloc] initWithInterface:aInterface selector:aSelector] autorelease];
}
// The hash of "Interface.selector", computed once.
- (NSUInteger)hash
{
    if (_hash == 0)
        _hash = (unsigned int)[[NSString stringWithFormat:@"%s.%@", protocol_getName(_interface), NSStringFromSelector(_selector)] hash];
    return _hash;
}
- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSAttributeIdentifier class]])
        return NO;
    Class class = [self class];
    // A subclass instance decides for itself.
    if ([aEqual isKindOfClass:class] && ![aEqual isMemberOfClass:class])
        return [aEqual isEqual:self];
    return HSProtocolsAreEqual(_interface, [aEqual interface]) && _selector == [aEqual selector];
}
- (SEL)selector
{
    return _selector;
}
- (id)interface
{
    return _interface;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}
- (id)init
{
    [self release];
    return nil;
}
- (id)initWithInterface:(id)aInterface selector:(SEL)aSelector
{
    self = [super init];
    if (self != nil) {
        _interface = aInterface;
        _selector = aSelector;
    }
    return self;
}
@end
