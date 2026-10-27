#import "HSCanvasActionIdentifier.h"
@implementation HSCanvasActionIdentifier
+ (id)identifierWithActionSelector:(SEL)aSelector
{
    return [[[self alloc] initWithActionSelector:aSelector] autorelease];
}
- (id)copyWithZone:(NSZone *)aZone
{
    HSCanvasActionIdentifier *copy = [[[self class] allocWithZone:aZone] initWithActionSelector:_selector];
    copy->_hash = _hash;
    return copy;
}
// The selector name's hash, computed once (never 0).
- (NSUInteger)hash
{
    if (_hash == 0) {
        _hash = (unsigned int)[NSStringFromSelector(_selector) hash];
        if (_hash == 0)
            _hash = 1;
    }
    return _hash;
}
- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[HSCanvasActionIdentifier class]])
        return [super isEqual:aEqual];
    return ((HSCanvasActionIdentifier *)aEqual)->_selector == _selector;
}
- (SEL)selector
{
    return _selector;
}
- (id)init
{
    return [self initWithActionSelector:NULL];
}
- (id)initWithActionSelector:(SEL)aSelector
{
    self = [super init];
    if (self != nil)
        _selector = aSelector;
    return self;
}
@end
