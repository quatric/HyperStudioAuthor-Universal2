#import "HyperPlayerBasePrefix.h"


@interface HSGWorldCGImageWrapper : NSObject
{
    struct OpaqueGrafPtr *_gWorld;
    struct CGImage *_cgImage;
    void *_gWorldData;
    int _gWorldDataSize;
}
+ (id)gWorldCGImageWithSize:(NSSize)aSize;
- (void)clear;
- (struct CGImage *)cgImage;
- (struct OpaqueGrafPtr *)gWorld;
- (void)dealloc;
- (id)initWithSize:(NSSize)aSize;
@end

