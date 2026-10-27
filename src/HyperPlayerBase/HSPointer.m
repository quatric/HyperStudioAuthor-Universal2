#import "HSPointer.h"
// A pointer owned by an object: the disposer (a function taking the
// pointer) is called with it when the object goes.
@implementation HSPointer
+ (id)wrapperForPointer:(void *)aPointer withDisposer:(void *)aDisposer
{
    return [[[self alloc] initWithPointer:aPointer disposer:aDisposer] autorelease];
}
// The pointer, disposed of with the current autorelease pool.
+ (void *)autoreleasedPointer:(void *)aPointer withDisposer:(void *)aDisposer
{
    if (aDisposer != NULL && aPointer != NULL && [self wrapperForPointer:aPointer withDisposer:aDisposer] == nil) {
        ((void (*)(void *))aDisposer)(aPointer);
        aPointer = NULL;
    }
    return aPointer;
}
- (void *)pointer
{
    return _pointer;
}
- (void)dealloc
{
    if (_disposer != NULL && _pointer != NULL)
        ((void (*)(void *))_disposer)(_pointer);
    [super dealloc];
}
- (id)init
{
    return [self initWithPointer:NULL disposer:NULL];
}
- (id)initWithPointer:(void *)aPointer
{
    return [self initWithPointer:aPointer disposer:NULL];
}
- (id)initWithPointer:(void *)aPointer disposer:(void *)aDisposer
{
    self = [super init];
    if (self != nil) {
        _pointer = aPointer;
        _disposer = aDisposer;
    }
    return self;
}
@end
