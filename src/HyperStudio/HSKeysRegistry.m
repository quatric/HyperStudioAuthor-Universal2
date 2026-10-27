#import "HSKeysRegistry.h"

@implementation HSKeysRegistry

+ (id)sharedRegistry
{
    static HSKeysRegistry *sharedRegistry = nil;
    if (sharedRegistry == nil)
        sharedRegistry = [HSKeysRegistry new];
    return sharedRegistry;
}

- (void)processKeyUpEvent:(id)aEvent
{
    unsigned short keyCode = [(NSEvent *)aEvent keyCode];
    _keysRegistry[keyCode >> 3] &= ~(unsigned char)(1 << (keyCode & 7));
    [[self keysCharCodesRegistry] removeObject:[(NSEvent *)aEvent characters]];
    _isRegistryReseted = NO;
}

- (void)processKeyDownEvent:(id)aEvent
{
    unsigned short keyCode = [(NSEvent *)aEvent keyCode];
    _keysRegistry[keyCode >> 3] |= (unsigned char)(1 << (keyCode & 7));
    [[self keysCharCodesRegistry] addObject:[(NSEvent *)aEvent characters]];
    _isRegistryReseted = NO;
}

- (void)resetKeysRegistry
{
    if (_isRegistryReseted)
        return;
    memset(_keysRegistry, 0, sizeof(_keysRegistry));
    [[self keysCharCodesRegistry] removeAllObjects];
    _isRegistryReseted = YES;
}

- (BOOL)isKeyWithCharCodesPressed:(id)aPressed
{
    return [[self keysCharCodesRegistry] containsObject:aPressed];
}

- (BOOL)isKeyWithVirtualCodePressed:(unsigned short)aPressed
{
    return (_keysRegistry[aPressed >> 3] >> (aPressed & 7)) & 1;
}

- (id)keysCharCodesRegistry
{
    if (_keysCharCodesRegistry == nil)
        _keysCharCodesRegistry = [[NSMutableSet alloc] initWithCapacity:0];
    return _keysCharCodesRegistry;
}

- (void)dealloc
{
    [_keysCharCodesRegistry release];
    [super dealloc];
}

@end
