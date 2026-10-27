#import <ApplicationServices/ApplicationServices.h>
#import <CoreVideo/CoreVideo.h>

// Data providers and consumers.

// Of malloc'd bytes, freed when it's released.
CGDataProviderRef CGEDataProviderCreateWithBytes(void *bytes, size_t length);
// Of bytes from an allocator, deallocated with it when it's released.
CGDataProviderRef CGEDataProviderCreateWithCFBytes(void *bytes, size_t length, CFAllocatorRef allocator);
// Of a pixel buffer's bytes, its base address locked with lockFlags while
// they're read.
CGDataProviderRef CGEDataProviderCreateWithPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags);
// Writing into data from an offset on, replacing what's there and appending;
// the data ends where the writing did once it's released.
CGDataConsumerRef CGEDataConsumerCreateWithCFDataAndOffset(CFMutableDataRef data, CFIndex offset);

// Images of bitmaps.

// Of a provider of a bitmap context's pixels.
CGImageRef CGEImageCreateAsBitmapContext(CGContextRef context, CGDataProviderRef provider, const CGFloat *decode,
                                         bool shouldInterpolate, CGColorRenderingIntent intent);
// Of pixels of a CoreVideo pixel format type (alphaMode as for
// CVEPixelFormatTypeIsCGImageCompatible). Without a color space, a device
// one of the format's model.
CGImageRef CGEImageCreateAsPixelFormatType(size_t width, size_t height, OSType type, size_t bytesPerRow,
                                           CGColorSpaceRef space, int alphaMode, CGDataProviderRef provider,
                                           const CGFloat *decode, bool shouldInterpolate,
                                           CGColorRenderingIntent intent);
// Of pixels like a (non-planar) pixel buffer's.
CGImageRef CGEImageCreateAsPixelBuffer(CVPixelBufferRef buffer, CGDataProviderRef provider, const CGFloat *decode,
                                       bool shouldInterpolate, CGColorRenderingIntent intent);
// Of a pixel buffer's pixels.
CGImageRef CGEImageCreateWithPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags, const CGFloat *decode,
                                         bool shouldInterpolate, CGColorRenderingIntent intent);

// Image masks of a bitmap's gray or alpha (when it's first in memory).
CGImageRef CGEImageMaskCreateAsBitmapContext(CGContextRef context, CGDataProviderRef provider, const CGFloat *decode,
                                             bool shouldInterpolate);
CGImageRef CGEImageMaskCreateAsPixelFormatType(size_t width, size_t height, OSType type, size_t bytesPerRow,
                                               CGDataProviderRef provider, const CGFloat *decode,
                                               bool shouldInterpolate);
CGImageRef CGEImageMaskCreateAsPixelBuffer(CVPixelBufferRef buffer, CGDataProviderRef provider, const CGFloat *decode,
                                           bool shouldInterpolate);
CGImageRef CGEImageMaskCreateWithPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags, const CGFloat *decode,
                                             bool shouldInterpolate);

// Debugging: saves an image as a PNG file in the temporary folder, named for
// a name and an object, and opens it.
void CGEImageShowAs(CGImageRef image, CFStringRef name, const void *object);
void CGEImageShow(CGImageRef image);
