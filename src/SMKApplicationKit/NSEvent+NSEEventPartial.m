#import "NSEvent+NSEEventPartial.h"

@implementation NSEvent (NSEEventPartial)

// The event types that carry modifier flags: key, flags-changed, mouse,
// scroll and tablet events (bit n for type n).
- (BOOL)NSE_hasModifierFlags
{
    return (0xfc31ffeU >> ([self type] & 0x1f)) & 1;
}

@end

@implementation NSEvent (NSEEventLoading)

// Tiger to Snow Leopard (AppKit 677-833) got backported methods here; later
// systems have them.
+ (void)load
{
}

@end

