#import "BTImageFunctions.h"

BOOL BTIsImagePoint(id image, CGPoint point)
{
    if (point.x < 0 || point.y < 0)
        return NO;
    CGSize size = [image imageSize];
    return point.x < size.width && point.y < size.height;
}

// An unpremultiplied device RGB colour from premultiplied ARGB bytes.
static CGColorRef CopyColorFromARGB(CGColorSpaceRef space, const unsigned char *pixel)
{
    CGFloat components[4] = {pixel[1] / 255.0, pixel[2] / 255.0, pixel[3] / 255.0, pixel[0] / 255.0};
    if (components[3] != 0) {
        components[0] /= components[3];
        components[1] /= components[3];
        components[2] /= components[3];
    }
    return CGColorCreate(space, components);
}

CGColorRef BTCopyColorFromRawImage(id image, CGPoint point)
{
    const unsigned char *bytes = [image imageBytes];
    if (!bytes || [image imageFormat] != -1 || [image imageColorProfile])
        return NULL;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (!space)
        return NULL;
    long x = lround(floor(point.x));
    long y = lround(floor(point.y));
    long height = lround([image imageSize].height);
    // Rows run top down.
    CGColorRef color = CopyColorFromARGB(space, bytes + [image imageBytesPerRow] * (height - 1 - y) + x * 4);
    CGColorSpaceRelease(space);
    return color;
}

CGColorRef BTCopyColorFromCGImage(id image, CGPoint point)
{
    CGColorRef color = NULL;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    if (space) {
        unsigned char pixel[4] = {0, 0, 0, 0};
        CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, space, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        if (context) {
            long x = lround(floor(point.x));
            long y = lround(floor(point.y));
            [image drawInCGContext:context atPoint:CGPointMake(-x, -y)];
            CGContextRelease(context);
            color = CopyColorFromARGB(space, pixel);
        }
    }
    CGColorSpaceRelease(space);
    return color;
}
