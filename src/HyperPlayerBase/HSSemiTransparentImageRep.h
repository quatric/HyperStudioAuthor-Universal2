#import "HyperPlayerBasePrefix.h"


@interface HSSemiTransparentImageRep : NSImageRep
{
    NSImage *_image;
    float _opacity;
}
- (BOOL)draw;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (id)initWithImage:(id)aImage opacity:(CGFloat)aOpacity;
@end

