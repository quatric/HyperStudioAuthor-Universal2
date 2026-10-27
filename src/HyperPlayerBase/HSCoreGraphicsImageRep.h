#import "HyperPlayerBasePrefix.h"


@interface HSCoreGraphicsImageRep : NSImageRep
{
    struct CGImage *_coreGraphicsImage;
}
- (BOOL)draw;
- (struct CGImage *)coreGraphicsImage;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (id)initWithCoreGraphicsImage:(struct CGImage *)aImage;
- (id)init;
@end

