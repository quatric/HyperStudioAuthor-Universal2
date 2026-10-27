#import "HSTransformedBTNSImage.h"

@implementation HSTransformedBTNSImage

// The image size seen through the inverse of the context transform.
- (CGSize)imageSize
{
    float a = _contextTransform.a, b = _contextTransform.b, c = _contextTransform.c, d = _contextTransform.d;
    float determinant = a * d - b * c;
    if (determinant != 0.0f) {
        float inverseA = d / determinant;
        d = a / determinant;
        a = inverseA;
        c = c / -determinant;
        b = b / -determinant;
    }
    CGSize size = [super imageSize];
    return CGSizeMake(a * (float)size.width + c * (float)size.height, b * (float)size.width + d * (float)size.height);
}

- (void)beginCocoaEditing
{
    [super beginCocoaEditing];
    CGContextConcatCTM([[NSGraphicsContext currentContext] CGContext], _contextTransform);
}

- (id)initWithNSImage:(id)aImage contextTransform:(CGAffineTransform)aTransform
{
    self = [self initWithNSImage:aImage];
    if (self != nil)
        _contextTransform = aTransform;
    return self;
}

@end
