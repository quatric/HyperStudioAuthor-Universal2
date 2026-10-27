#import <ApplicationServices/ApplicationServices.h>
#import <CoreVideo/CoreVideo.h>

// Bitmap contexts. Before 10.6 (CF 550) the originals emulated
// CGBitmapContextCreateWithData and the NULL-data CGBitmapContextCreate with
// associated objects; on macOS 11+ they are the CoreGraphics calls.

CGContextRef CGEBitmapContextCreate(void *data, size_t width, size_t height, size_t bitsPerComponent,
                                    size_t bytesPerRow, CGColorSpaceRef space, CGBitmapInfo bitmapInfo);
CGContextRef CGEBitmapContextCreateWithData(void *data, size_t width, size_t height, size_t bitsPerComponent,
                                            size_t bytesPerRow, CGColorSpaceRef space, CGBitmapInfo bitmapInfo,
                                            CGBitmapContextReleaseDataCallback releaseCallback, void *releaseInfo);
// Over data laid out like a (non-planar) pixel buffer: its size, format, alpha
// info attachment and color space (a device one of the format's model without).
CGContextRef CGEBitmapContextCreateAsPixelBuffer(CVPixelBufferRef buffer, void *data,
                                                 CGBitmapContextReleaseDataCallback releaseCallback,
                                                 void *releaseInfo);
// Over a pixel buffer locked with lockFlags, retained and unlocked when the
// context goes away.
CGContextRef CGEBitmapContextCreateWithLockedPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags);
// Locks it first (and unlocks it again if there's no context).
CGContextRef CGEBitmapContextCreateWithPixelBuffer(CVPixelBufferRef buffer, CVOptionFlags lockFlags);

// Images sharing the context's pixels (the image keeps the context alive);
// drawing into the context afterwards changes them.
CGImageRef CGEBitmapContextCreateImageNoCopy(CGContextRef context, const CGFloat *decode, bool shouldInterpolate,
                                             CGColorRenderingIntent intent);
CGImageRef CGEBitmapContextCreateImageMaskNoCopy(CGContextRef context, const CGFloat *decode,
                                                 bool shouldInterpolate);

// Color components plus alpha.
size_t CGEBitmapContextGetNumberOfComponents(CGContextRef context);
CFStringRef CGEBitmapContextCopyDescription(CGContextRef context);
// Opens the pixels as an image for debugging (CGEImageShowAs).
void CGEBitmapContextShow(CGContextRef context);

// A cache key (CFData) for a stroke style in device pixels: the line width
// and dash lengths scaled by the transform's columns over unitScale, cap,
// join and miter limit.
CFDataRef CGEBitmapCacheCreateLineInfoKey(CGFloat unitScale, CGFloat lineWidth, CGLineCap cap, CGLineJoin join,
                                          CGFloat miterLimit, CGFloat phase, const CGFloat *lengths, size_t count,
                                          CGAffineTransform transform);
CFStringRef CGEBitmapCacheCopyLineInfoKeyDescription(CFDataRef key, CGFloat unitScale);
