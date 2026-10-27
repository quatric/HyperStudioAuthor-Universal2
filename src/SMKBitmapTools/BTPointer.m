#import "BTPointer.h"

// An object owning a C pointer, disposed of with a function when it goes.
@implementation BTPointer

+ (id)wrapperForPointer:(void *)aPointer withDisposer:(void *)aDisposer
{
    return [[[self alloc] initWithPointer:aPointer disposer:aDisposer] autorelease];
}

// Disposes of the pointer right away if no wrapper could be made.
+ (void *)autoreleasedPointer:(void *)aPointer withDisposer:(void *)aDisposer
{
    if (aDisposer && aPointer && ![self wrapperForPointer:aPointer withDisposer:aDisposer]) {
        ((void (*)(void *))aDisposer)(aPointer);
        return NULL;
    }
    return aPointer;
}

- (void *)pointer
{
    return _pointer;
}

- (void)dealloc
{
    if (_disposer && _pointer)
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
    if (self) {
        _pointer = aPointer;
        _disposer = aDisposer;
    }
    return self;
}

@end
