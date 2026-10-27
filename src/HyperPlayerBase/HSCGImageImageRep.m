#import "HSCGImageImageRep.h"
// NSImageRep that wraps a CGImage. It archives the image as PNG data.

// Size test with a relative tolerance of 0.0005 (absolute below 1).
static BOOL HSCGImageImageRepIsPositive(float aValue)
{
    float magnitude = aValue != 0 ? fabsf(aValue) : 1.0f;
    float tolerance = magnitude <= 1.0f ? 0.0005f : magnitude * 0.0005f;
    return aValue - tolerance > 0;
}

@implementation HSCGImageImageRep

+ (void)load
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [NSImageRep registerImageRepClass:[self class]];
    [pool release];
}

- (BOOL)draw
{
    NSSize size = [self size];
    CGImageRef image = _cgImage;
    if (!image || !HSCGImageImageRepIsPositive(size.width) || !HSCGImageImageRepIsPositive(size.height))
        return NO;
    CGContextDrawImage((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], CGRectMake(0, 0, size.width, size.height), image);
    return YES;
}

- (void)setCGImage:(struct CGImage *)aImage
{
    if (_cgImage == aImage)
        return;
    if (_cgImage) {
        CGImageRelease(_cgImage);
        _cgImage = NULL;
    }
    if (aImage) {
        _cgImage = CGImageRetain(aImage);
        [self setSize:NSMakeSize(CGImageGetWidth(_cgImage), CGImageGetHeight(_cgImage))];
    }
}

- (struct CGImage *)cgImage
{
    return _cgImage;
}

- (NSInteger)pixelsHigh
{
    return _cgImage ? (NSInteger)CGImageGetHeight(_cgImage) : 0;
}

- (NSInteger)pixelsWide
{
    return _cgImage ? (NSInteger)CGImageGetWidth(_cgImage) : 0;
}

- (NSInteger)bitsPerSample
{
    return _cgImage ? (NSInteger)CGImageGetBitsPerComponent(_cgImage) : 0;
}

- (BOOL)hasAlpha
{
    if (!_cgImage)
        return NO;
    switch (CGImageGetAlphaInfo(_cgImage)) {
    case kCGImageAlphaPremultipliedLast:
    case kCGImageAlphaPremultipliedFirst:
    case kCGImageAlphaLast:
    case kCGImageAlphaFirst:
    case kCGImageAlphaOnly:
        return YES;
    default:
        return NO;
    }
}

- (void)encodeWithCoder:(id)aCoder
{
    [super encodeWithCoder:aCoder];
    CFMutableDataRef data = CFDataCreateMutable(kCFAllocatorDefault, 0);
    if (!data)
        return;
    CGImageDestinationRef destination = CGImageDestinationCreateWithData(data, kUTTypePNG, 1, NULL);
    if (!destination) {
        // (The original leaks the data here.)
        CFRelease(data);
        return;
    }
    CGImageDestinationAddImage(destination, _cgImage, NULL);
    if (CGImageDestinationFinalize(destination)) {
        if ([aCoder allowsKeyedCoding])
            [aCoder encodeObject:(NSData *)data forKey:(NSString *)kUTTypePNG];
        else
            [aCoder encodeObject:(NSData *)data];
    }
    CFRelease(destination);
    CFRelease(data);
}

- (id)initWithCoder:(id)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        NSData *data = [aCoder allowsKeyedCoding] ? [aCoder decodeObjectForKey:(NSString *)kUTTypePNG] : [aCoder decodeObject];
        if (data) {
            NSDictionary *options = [NSDictionary dictionaryWithObject:(NSString *)kUTTypePNG forKey:(NSString *)kCGImageSourceTypeIdentifierHint];
            CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, (CFDictionaryRef)options);
            if (source) {
                _cgImage = CGImageSourceCreateImageAtIndex(source, 0, NULL);
                CFRelease(source);
            }
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithCGImage:_cgImage];
}

- (void)dealloc
{
    if (_cgImage)
        CGImageRelease(_cgImage);
    [super dealloc];
}

- (id)initWithCGImage:(struct CGImage *)aImage
{
    self = [super init];
    if (self && aImage) {
        _cgImage = CGImageRetain(aImage);
        [self setSize:NSMakeSize(CGImageGetWidth(_cgImage), CGImageGetHeight(_cgImage))];
    }
    return self;
}

- (id)init
{
    return [self initWithCGImage:NULL];
}

@end
