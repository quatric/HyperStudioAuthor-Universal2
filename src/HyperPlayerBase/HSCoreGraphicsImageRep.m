#import "HSCoreGraphicsImageRep.h"
// An image rep of a CGImage, archived as PNG.
@implementation HSCoreGraphicsImageRep
- (BOOL)draw
{
    CGContextRef context = [[NSGraphicsContext currentContext] CGContext];
    size_t width, height;
    if (context == NULL || (width = CGImageGetWidth(_coreGraphicsImage)) == 0 || (height = CGImageGetHeight(_coreGraphicsImage)) == 0)
        return NO;
    NSSize size = [self size];
    CGContextScaleCTM(context, size.width / width, size.height / height);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), _coreGraphicsImage);
    return YES;
}
- (struct CGImage *)coreGraphicsImage
{
    return _coreGraphicsImage;
}
- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}
- (void)dealloc
{
    CGImageRelease(_coreGraphicsImage);
    [super dealloc];
}
- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorSystemDefault, 0);
    if (data == NULL)
        return;
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(data, kUTTypePNG, 1, NULL);
    if (destination != NULL) {
        CGImageDestinationAddImage(destination, _coreGraphicsImage, NULL);
        if (CGImageDestinationFinalize(destination)) {
            if ([aCoder allowsKeyedCoding])
                [aCoder encodeObject:(NSData *)data forKey:(NSString *)kUTTypePNG];
            else
                [aCoder encodeObject:(NSData *)data];
        }
        CFRelease(destination);
    }
    // (The original released the data only with a destination.)
    CFRelease(data);
}
- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self != nil) {
        NSData *data = [aCoder allowsKeyedCoding] ? [aCoder decodeObjectForKey:(NSString *)kUTTypePNG] : [aCoder decodeObject];
        if (data != nil) {
            NSDictionary *options = [NSDictionary dictionaryWithObject:(NSString *)kUTTypePNG forKey:(NSString *)kCGImageSourceTypeIdentifierHint];
            CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, (CFDictionaryRef)options);
            if (source != NULL) {
                _coreGraphicsImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
                CFRelease(source);
            }
        }
    }
    return self;
}
// The rep takes the image's size, alpha and color space (device ones
// recognized; calibrated RGB otherwise).
- (id)initWithCoreGraphicsImage:(struct CGImage *)aImage
{
    self = [super init];
    if (self == nil)
        return nil;
    _coreGraphicsImage = CGImageRetain(aImage);
    size_t width = CGImageGetWidth(_coreGraphicsImage);
    size_t height = CGImageGetHeight(_coreGraphicsImage);
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(_coreGraphicsImage);
    BOOL hasAlpha = NO;
    if (alphaInfo <= 7 && ((0x9e >> alphaInfo) & 1))
        hasAlpha = YES;
    else if (!(alphaInfo <= 7 && ((0x61 >> alphaInfo) & 1)))
        CFShow(CFSTR("Invalid / unsupported image alpha info."));
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(_coreGraphicsImage);
    NSString *colorSpaceName = NSCalibratedRGBColorSpace;
    CGColorSpaceRef deviceSpace = CGColorSpaceCreateDeviceRGB();
    CGColorSpaceRelease(deviceSpace);
    if (colorSpace == deviceSpace)
        colorSpaceName = NSDeviceRGBColorSpace;
    else {
        deviceSpace = CGColorSpaceCreateDeviceGray();
        CGColorSpaceRelease(deviceSpace);
        if (colorSpace == deviceSpace)
            colorSpaceName = NSDeviceWhiteColorSpace;
        else {
            deviceSpace = CGColorSpaceCreateDeviceCMYK();
            CGColorSpaceRelease(deviceSpace);
            if (colorSpace == deviceSpace)
                colorSpaceName = NSDeviceCMYKColorSpace;
        }
    }
    [super setSize:NSMakeSize(width, height)];
    [super setAlpha:hasAlpha];
    [super setOpaque:!hasAlpha];
    [super setColorSpaceName:colorSpaceName];
    [super setBitsPerSample:CGImageGetBitsPerComponent(_coreGraphicsImage)];
    [super setPixelsWide:width];
    [super setPixelsHigh:height];
    return self;
}
- (id)init
{
    [super release];
    return nil;
}
@end
