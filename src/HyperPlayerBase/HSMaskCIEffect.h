#import "HyperPlayerBasePrefix.h"
#import "HSCIEffect.h"


@interface HSMaskCIEffect : HSCIEffect
{
    CIFilter *_compositeFilter;
}
+ (id)effectsDescription;
- (id)compositeOutputCIImage:(id)aImage;
- (id)category;
- (void)dealloc;
@end

