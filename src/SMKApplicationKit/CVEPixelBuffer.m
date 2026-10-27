#import "CVEPixelBuffer.h"

// The OpenGL formats CoreVideo describes for a pixel format; each pointer
// may be NULL, and each value asked for must be there.
static Boolean getOpenGLFormat(OSType pixelFormat, GLint *internalFormat, GLenum *format, GLenum *type,
                               int *bitsPerBlock, int *blockWidth)
{
    CFDictionaryRef description = CVPixelFormatDescriptionCreateWithPixelFormatType(NULL, pixelFormat);
    if (!description)
        return false;
    int values[5] = { 0, 0, 0, 0, 1 };
    CFStringRef keys[5] = { kCVPixelFormatOpenGLInternalFormat, kCVPixelFormatOpenGLFormat, kCVPixelFormatOpenGLType,
                            kCVPixelFormatBitsPerBlock, kCVPixelFormatBlockWidth };
    void *wanted[5] = { internalFormat, format, type, bitsPerBlock, blockWidth };
    Boolean ok = true;
    for (int i = 0; i < 5 && ok; i++) {
        if (!wanted[i])
            continue;
        CFNumberRef number = CFDictionaryGetValue(description, keys[i]);
        if (number)
            CFNumberGetValue(number, kCFNumberIntType, &values[i]);
        ok = values[i] != 0;
    }
    CFRelease(description);
    if (!ok)
        return false;
    if (internalFormat) *internalFormat = values[0];
    if (format) *format = values[1];
    if (type) *type = values[2];
    if (bitsPerBlock) *bitsPerBlock = values[3];
    if (blockWidth) *blockWidth = values[4];
    return true;
}

// The unpack row length and the largest alignment (8, 4, 2, 1) the row
// bytes are a multiple of, unless the padding at the end of a row is that
// large.
static Boolean rowLengthAndAlignment(size_t bytesPerRow, int bitsPerBlock, int blockWidth, GLint *rowLength, GLint *alignment)
{
    int rowBytes = (int)bytesPerRow;
    int extra = (rowBytes * 8) % bitsPerBlock;
    int scaled = extra * blockWidth;
    extra -= ((blockWidth - 1 + scaled) - scaled % bitsPerBlock) / blockWidth;
    static const int alignments[4] = { 8, 4, 2, 1 };
    for (int i = 0; i < 4; i++) {
        if (rowBytes % alignments[i])
            continue;
        if (alignments[i] * 8 <= extra)
            return false;
        if (alignment)
            *alignment = alignments[i];
        break;
    }
    if (rowLength)
        *rowLength = rowBytes * 8 * blockWidth / bitsPerBlock;
    return true;
}

size_t CVEPixelBufferGetDataSize(CVPixelBufferRef buffer)
{
    if (!CVPixelBufferIsPlanar(buffer))
        return CVPixelBufferGetBytesPerRow(buffer) * CVPixelBufferGetHeight(buffer);
    return CVPixelBufferGetDataSize(buffer);
}

Boolean CVEPixelBufferGetOpenGLRowLengthAndAlignment(CVPixelBufferRef buffer, GLint *rowLength, GLint *alignment)
{
    if (CVPixelBufferIsPlanar(buffer))
        return false;
    int bitsPerBlock = 0, blockWidth = 1;
    if (!getOpenGLFormat(CVPixelBufferGetPixelFormatType(buffer), NULL, NULL, NULL, &bitsPerBlock, &blockWidth))
        return false;
    return rowLengthAndAlignment(CVPixelBufferGetBytesPerRow(buffer), bitsPerBlock, blockWidth, rowLength, alignment);
}

Boolean CVEPixelBufferIsOpenGLCompatible(CVPixelBufferRef buffer, GLint *internalFormat, GLenum *format, GLenum *type,
                                         GLint *rowLength, GLint *alignment)
{
    if (CVPixelBufferIsPlanar(buffer))
        return false;
    GLint internal = 0;
    GLenum f = 0, t = 0;
    int bitsPerBlock = 0, blockWidth = 1;
    if (!getOpenGLFormat(CVPixelBufferGetPixelFormatType(buffer), &internal, &f, &t, &bitsPerBlock, &blockWidth))
        return false;
    if (!rowLengthAndAlignment(CVPixelBufferGetBytesPerRow(buffer), bitsPerBlock, blockWidth, rowLength, alignment))
        return false;
    if (internalFormat) *internalFormat = internal;
    if (format) *format = f;
    if (type) *type = t;
    return true;
}

CFStringRef CVEPixelFormatTypeCopyDescription(OSType type)
{
    CFStringRef code = CFECopyOSTypeDescription(type);
    if (!code)
        return NULL;
    CFDictionaryRef description = CVPixelFormatDescriptionCreateWithPixelFormatType(NULL, type);
    if (!description)
        return code;
    CFStringRef name = CFDictionaryGetValue(description, kCVPixelFormatName);
    if (name) {
        CFStringRef full = CFStringCreateWithFormat(NULL, NULL, CFSTR("%@ (%@)"), name, code);
        CFRelease(code);
        code = full;
    }
    CFRelease(description);
    return code;
}

typedef struct {
    OSType type;
    Boolean needsAlpha;         // not with alpha as is (alphaMode 0)
    size_t bitsPerComponent;
    CGColorSpaceModel model;
    CGBitmapInfo info;          // alpha premultiplied or as is
    CGBitmapInfo skipInfo;      // alpha ignored
    Boolean inverted;
} BitmapFormat;

static const BitmapFormat bitmapFormats[] = {
    { kCVPixelFormatType_8Indexed, false, 8, kCGColorSpaceModelMonochrome, 0, 0, false },
    { kCVPixelFormatType_16BE555, false, 5, kCGColorSpaceModelRGB, 0x4006, 0x4006, false },
    { kCVPixelFormatType_32ARGB, true, 8, kCGColorSpaceModelRGB, 0x4002, 0x4006, false },
    { kCVPixelFormatType_8IndexedGray_WhiteIsZero, false, 8, kCGColorSpaceModelMonochrome, 0, 0, true },
    { kCVPixelFormatType_32ABGR, true, 8, kCGColorSpaceModelRGB, 0x2001, 0x2005, false },
    { kCVPixelFormatType_32BGRA, true, 8, kCGColorSpaceModelRGB, 0x2002, 0x2006, false },
    { kCVPixelFormatType_16LE555, false, 5, kCGColorSpaceModelRGB, 0x2006, 0x2006, false },
    { kCVPixelFormatType_32RGBA, true, 8, kCGColorSpaceModelRGB, 0x4001, 0x4005, false },
    { kCVPixelFormatType_16Gray, false, 16, kCGColorSpaceModelMonochrome, 0x4000, 0x4000, false },
};

Boolean CVEPixelFormatTypeIsCGBitmapContextCompatible(OSType type, int alphaMode, size_t *bitsPerComponent,
                                                      CGColorSpaceModel *model, CGBitmapInfo *bitmapInfo,
                                                      Boolean *invertedDecode)
{
    for (size_t i = 0; i < sizeof bitmapFormats / sizeof *bitmapFormats; i++) {
        const BitmapFormat *f = &bitmapFormats[i];
        if (f->type != type)
            continue;
        if (f->needsAlpha && alphaMode == 0)
            return false;
        if (bitsPerComponent) *bitsPerComponent = f->bitsPerComponent;
        if (model) *model = f->model;
        if (bitmapInfo) *bitmapInfo = alphaMode == -1 ? f->skipInfo : f->info;
        if (invertedDecode) *invertedDecode = f->inverted;
        return true;
    }
    return false;
}

typedef struct {
    OSType type;
    size_t bitsPerComponent;
    size_t bitsPerPixel;
    CGColorSpaceModel model;
    CGBitmapInfo premultipliedInfo;     // alphaMode 1
    CGBitmapInfo skipInfo;              // alphaMode -1
    CGBitmapInfo straightInfo;          // alphaMode 0
    int inverted;                       // -1: left as it is
} ImageFormat;

static const ImageFormat imageFormats[] = {
    { kCVPixelFormatType_64ARGB, 16, 64, kCGColorSpaceModelRGB, 2, 6, 4, 0 },
    { kCVPixelFormatType_32AlphaGray, 16, 32, kCGColorSpaceModelMonochrome, 0x4002, 0x4006, 0x4004, 0 },
    { kCVPixelFormatType_16Gray, 16, 16, kCGColorSpaceModelMonochrome, 0x4000, 0x4000, 0x4000, 0 },
    { kCVPixelFormatType_32RGBA, 8, 32, kCGColorSpaceModelRGB, 0x4001, 0x4005, 0x4003, 0 },
    { kCVPixelFormatType_8IndexedGray_WhiteIsZero, 8, 8, kCGColorSpaceModelMonochrome, 0, 0, 0, 1 },
    { kCVPixelFormatType_32ARGB, 8, 32, kCGColorSpaceModelRGB, 0x4002, 0x4006, 0x4004, 0 },
    { kCVPixelFormatType_1IndexedGray_WhiteIsZero, 1, 1, kCGColorSpaceModelMonochrome, 0, 0, 0, 1 },
    { kCVPixelFormatType_2IndexedGray_WhiteIsZero, 2, 2, kCGColorSpaceModelMonochrome, 0, 0, 0, 1 },
    { kCVPixelFormatType_4IndexedGray_WhiteIsZero, 4, 4, kCGColorSpaceModelMonochrome, 0, 0, 0, 1 },
    { kCVPixelFormatType_24RGB, 8, 24, kCGColorSpaceModelRGB, 0, 0, 0, 0 },
    { kCVPixelFormatType_16BE555, 5, 16, kCGColorSpaceModelRGB, 0x4006, 0x4006, 0x4006, -1 },
    { kCVPixelFormatType_1Monochrome, 1, 1, kCGColorSpaceModelMonochrome, 0, 0, 0, 0 },
    { kCVPixelFormatType_2Indexed, 2, 2, kCGColorSpaceModelMonochrome, 0, 0, 0, 0 },
    { kCVPixelFormatType_4Indexed, 4, 4, kCGColorSpaceModelMonochrome, 0, 0, 0, 0 },
    { kCVPixelFormatType_8Indexed, 8, 8, kCGColorSpaceModelMonochrome, 0, 0, 0, 0 },
    { kCVPixelFormatType_16LE5551, 5, 16, kCGColorSpaceModelRGB, 0x2001, 0x2005, 0x2003, 0 },
    { kCVPixelFormatType_32ABGR, 8, 32, kCGColorSpaceModelRGB, 0x2001, 0x2005, 0x2003, 0 },
    { kCVPixelFormatType_32BGRA, 8, 32, kCGColorSpaceModelRGB, 0x2002, 0x2006, 0x2004, 0 },
    { kCVPixelFormatType_16LE555, 5, 16, kCGColorSpaceModelRGB, 0x2006, 0x2006, 0x2006, 0 },
    { kCVPixelFormatType_48RGB, 16, 48, kCGColorSpaceModelRGB, 0, 0, 0, 0 },
};

Boolean CVEPixelFormatTypeIsCGImageCompatible(OSType type, int alphaMode, size_t *bitsPerComponent,
                                              size_t *bitsPerPixel, CGColorSpaceModel *model,
                                              CGBitmapInfo *bitmapInfo, Boolean *invertedDecode)
{
    for (size_t i = 0; i < sizeof imageFormats / sizeof *imageFormats; i++) {
        const ImageFormat *f = &imageFormats[i];
        if (f->type != type)
            continue;
        if (bitsPerComponent) *bitsPerComponent = f->bitsPerComponent;
        if (bitsPerPixel) *bitsPerPixel = f->bitsPerPixel;
        if (model) *model = f->model;
        if (bitmapInfo) *bitmapInfo = alphaMode == 1 ? f->premultipliedInfo : alphaMode == -1 ? f->skipInfo : f->straightInfo;
        if (invertedDecode && f->inverted >= 0) *invertedDecode = f->inverted;
        return true;
    }
    return false;
}

Boolean CVEPixelFormatTypeIsOpenGLCompatible(OSType type, GLint *internalFormat, GLenum *format, GLenum *type2,
                                             int *bitsPerBlock, int *blockWidth)
{
    return getOpenGLFormat(type, internalFormat, format, type2, bitsPerBlock, blockWidth);
}
