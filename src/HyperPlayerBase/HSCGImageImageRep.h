#import "HyperPlayerBasePrefix.h"


@interface HSCGImageImageRep : NSImageRep
{
    struct CGImage *_cgImage;
}
+ (void)load;
- (BOOL)draw;
- (void)setCGImage:(struct CGImage *)aImage;
- (struct CGImage *)cgImage;
- (NSInteger)pixelsHigh;
- (NSInteger)pixelsWide;
- (NSInteger)bitsPerSample;
- (BOOL)hasAlpha;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)initWithCGImage:(struct CGImage *)aImage;
- (id)init;
@end

