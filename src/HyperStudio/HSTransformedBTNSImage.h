#import "HyperStudioPrefix.h"


@interface HSTransformedBTNSImage : BTNSImage
{
    CGAffineTransform _contextTransform;
}
- (CGSize)imageSize;
- (void)beginCocoaEditing;
- (id)initWithNSImage:(id)aImage contextTransform:(CGAffineTransform)aTransform;
@end

