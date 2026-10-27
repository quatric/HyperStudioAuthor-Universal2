#import "HSProtocolIdentifier.h"
// A protocol as a dictionary key or set member.
@implementation HSProtocolIdentifier
+ (id)identifierForProtocol:(id)aProtocol
{
    return [[[self alloc] initWithProtocol:aProtocol] autorelease];
}
- (id)description
{
    return [NSString stringWithFormat:@"<%@: 0x%x> %s", NSStringFromClass([self class]), (unsigned int)(uintptr_t)self, protocol_getName(_protocol)];
}
// The name's last, middle and first characters and its length.
- (NSUInteger)hash
{
    const char *name = protocol_getName(_protocol);
    size_t length;
    if (name == NULL || (length = strlen(name)) == 0)
        return 0;
    return (unsigned int)((unsigned char)name[length - 1] << 24 | (int)name[length >> 1] << 16 | (int)name[0] << 8 | (unsigned int)length);
}
- (BOOL)isEqual:(id)aEqual
{
    if (aEqual == self)
        return YES;
    if (![aEqual isKindOfClass:[HSProtocolIdentifier class]])
        return NO;
    Class class = [self class];
    // A subclass instance decides for itself.
    if ([aEqual isKindOfClass:class] && ![aEqual isMemberOfClass:class])
        return [aEqual isEqual:self];
    return HSProtocolsAreEqual(_protocol, [(HSProtocolIdentifier *)aEqual protocol]);
}
- (id)protocol
{
    return _protocol;
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
- (id)initWithProtocol:(id)aProtocol
{
    self = [super init];
    if (self != nil)
        _protocol = aProtocol;
    return self;
}
@end
