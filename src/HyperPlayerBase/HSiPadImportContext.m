#import "HSiPadImportContext.h"
@implementation HSiPadImportContext
- (void)setPrototypeObject:(id)aObject forUID:(id)aUID
{
    if (_prototypesMap == nil)
        _prototypesMap = [NSMutableDictionary new];
    [_prototypesMap setObject:aObject forKey:aUID];
}
- (id)prototypeObjectForUID:(id)aUID
{
    return [_prototypesMap objectForKey:aUID];
}
- (id)stack
{
    return _stack;
}
- (void)dealloc
{
    [_prototypesMap release];
    [super dealloc];
}
// The stack isn't retained.
- (id)initWithStack:(id)aStack
{
    self = [super init];
    if (self != nil)
        _stack = aStack;
    return self;
}
@end
