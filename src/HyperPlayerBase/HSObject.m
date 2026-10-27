#import "HSObject.h"
@implementation HSObject
- (CGFloat)extraCodingVersion
{
    return [[HSDocument currentDocumentVersion] floatValue];
}
- (BOOL)conformsToProtocol:(id)aProtocol
{
    // Answers are cached per protocol: 1 = conforms, -1 = does not.
    NSInteger cached = (NSInteger)NSMapGet([self intefaceIdentifiers], aProtocol);
    if (cached != 0)
        return cached == 1;
    BOOL conforms = [super conformsToProtocol:aProtocol];
    NSMapInsert([self intefaceIdentifiers], aProtocol, (void *)(NSInteger)(conforms ? 1 : -1));
    return conforms;
}
- (id)intefaceIdentifiers
{
    if (_intefaceIdentifiers == nil)
        _intefaceIdentifiers = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSIntegerMapValueCallBacks, 8);
    return _intefaceIdentifiers;
}
- (void)dealloc
{
    if (_intefaceIdentifiers != nil)
        NSFreeMapTable(_intefaceIdentifiers);
    [super dealloc];
}
@end
