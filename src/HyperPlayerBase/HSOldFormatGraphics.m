#import "HSOldFormatGraphics.h"
#import "HSOldFormatGraphicsImport.h"

static unsigned short HSOldFormatBigEndian16(const unsigned char *aBytes)
{
    return (unsigned short)(aBytes[0] << 8 | aBytes[1]);
}

static unsigned int HSOldFormatBigEndian32(const unsigned char *aBytes)
{
    return (unsigned int)aBytes[0] << 24 | aBytes[1] << 16 | aBytes[2] << 8 | aBytes[3];
}

static unsigned short HSOldFormatLittleEndian16(const unsigned char *aBytes)
{
    return (unsigned short)(aBytes[0] | aBytes[1] << 8);
}

static unsigned int HSOldFormatLittleEndian32(const unsigned char *aBytes)
{
    return (unsigned int)aBytes[0] | aBytes[1] << 8 | aBytes[2] << 16 | (unsigned int)aBytes[3] << 24;
}

// The original reported errors through ReportOSErr, which looked up an alert
// string and showed nothing; that is dropped.
OSErr CreatePixPak(struct HSOldFormatPixPak *aPixPak, const Rect *aBounds, short aDepth)
{
    memset(aPixPak, 0, sizeof(*aPixPak));
    Rect bounds = { 0, 0, aBounds->bottom - aBounds->top, aBounds->right - aBounds->left };
    int rowBytes = (bounds.right + 15) / 16 * aDepth * 2;
    if ((unsigned short)rowBytes >= 0x3fff)
        return paramErr;
    // Depth 128 was a one-bit pixel map with wide rows.
    aPixPak->depth = aDepth == 128 ? 1 : aDepth;
    aPixPak->rowBytes = (short)rowBytes;
    aPixPak->bounds = bounds;
    aPixPak->size = (size_t)(unsigned short)rowBytes * (size_t)MAX(bounds.bottom, 0);
    aPixPak->pixels = calloc(MAX(aPixPak->size, 1), 1);
    if (!aPixPak->pixels) {
        aPixPak->size = 0;
        return memFullErr;
    }
    return noErr;
}

void DisposePixPak(struct HSOldFormatPixPak *aPixPak)
{
    if (!aPixPak)
        return;
    free(aPixPak->pixels);
    memset(aPixPak, 0, sizeof(*aPixPak));
}

// QuickDraw's UnpackBits over aCount output bytes; returns the input used.
static long HSOldFormatUnpackBits(const unsigned char *aData, long aLength, unsigned char *aBuffer, long aCount)
{
    long in = 0, out = 0;
    while (out < aCount && in < aLength) {
        signed char header = (signed char)aData[in++];
        if (header >= 0) {
            long run = MIN((long)header + 1, MIN(aCount - out, aLength - in));
            memcpy(aBuffer + out, aData + in, run);
            in += header + 1;
            out += run;
        } else if (header != -128 && in < aLength) {
            long run = MIN(1 - (long)header, aCount - out);
            memset(aBuffer + out, aData[in++], run);
            out += run;
        }
    }
    return MIN(in, aLength);
}

// Fix: the original wrote as much as the data decoded to, whatever the buffer
// size; the output stops at the buffer's end now.
void LZW_Decompress(const void *aData, long aLength, void *aBuffer, size_t *aSize)
{
    const unsigned char *data = aData, *end = data + aLength, *in = data + 4;
    unsigned char *buffer = aBuffer, *out = buffer, *limit = buffer + *aSize;
    if (aLength < 4) {
        *aSize = 0;
        return;
    }
    if (data[0] == 1) {
        size_t length = MIN((size_t)(aLength - 4), *aSize);
        memmove(buffer, in, length);
        *aSize = length;
        return;
    }
    unsigned int flags = 1;
    while (in < end) {
        if (flags == 1) {
            if (end - in < 2)
                break;
            flags = HSOldFormatLittleEndian16(in) + 0x10000;
            in += 2;
        }
        // Near the end one item at a time, so the input ends on an item.
        int items = in > end - 0x20 ? 1 : 16;
        while (items-- && in < end) {
            unsigned char byte = *in;
            if (!(flags & 1)) {
                if (out < limit)
                    *out++ = byte;
            } else if (in + 1 < end) {
                long distance = (byte & 0xf0) << 4 | in[1];
                long length = 3 + (byte & 0xf);
                in++;
                for (long i = 0; i < length && out < limit; i++, out++)
                    *out = out - distance >= buffer ? out[-distance] : 0;
            }
            flags >>= 1;
            in++;
        }
    }
    *aSize = out - buffer;
}

// Runs of a constant long at both ends (big-endian counts, raw values), the
// middle compressed.
static OSErr HSOldFormatDecompressBetweenRuns(struct HSOldFormatPixPak *aPixPak, const unsigned char *aData, long aLength, BOOL aHasRuns)
{
    size_t head = 0, tail = 0, offset = 0;
    if (aHasRuns) {
        if (aLength < 16)
            return noErr;
        unsigned int headValue, tailValue;
        memcpy(&headValue, aData, 4);
        memcpy(&tailValue, aData + 8, 4);
        head = MIN(HSOldFormatBigEndian32(aData + 4), aPixPak->size) & ~(size_t)3;
        tail = MIN(HSOldFormatBigEndian32(aData + 12), aPixPak->size - head) & ~(size_t)3;
        for (size_t i = 0; i < head; i += 4)
            memcpy(aPixPak->pixels + i, &headValue, 4);
        for (size_t i = 0; i < tail; i += 4)
            memcpy(aPixPak->pixels + aPixPak->size - 4 - i, &tailValue, 4);
        offset = 16;
    }
    size_t size = aPixPak->size - head - tail;
    if (size)
        LZW_Decompress(aData + offset, aLength - offset, aPixPak->pixels + head, &size);
    return noErr;
}

OSErr PixPak_Decompress(struct HSOldFormatPixPak *aPixPak, const void *aData, long aLength, short aPackType)
{
    const unsigned char *data = aData;
    int rows = aPixPak->bounds.bottom - aPixPak->bounds.top;
    if (aPackType == 1000) {
        switch (aPixPak->depth) {
        case 32:
            return 1;
        case 1:
            aPackType = 0;
            break;
        case 4:
        case 8:
        case 16:
            aPackType = 2;
            break;
        default:
            return noErr;
        }
    }
    switch (aPackType) {
    case 0:
        HSOldFormatUnpackBits(data, aLength, aPixPak->pixels, aPixPak->size);
        return noErr;
    case 1:
    case 2:
        return HSOldFormatDecompressBetweenRuns(aPixPak, data, aLength, aPackType == 2);
    case 3:
        return 1;
    case 4: {
        // Each row: a compressed block whose length is in its header bytes 2-3.
        if (rows <= 0)
            return noErr;
        size_t rowSize = aPixPak->size / rows;
        unsigned char *row = malloc(MAX(rowSize * 2, 1));
        if (!row)
            return memFullErr;
        const unsigned char *in = data, *end = data + aLength;
        for (int i = 0; i < rows; i++) {
            if (end - in < 4 || HSOldFormatBigEndian16(in + 2) > end - in) {
                free(row);
                return -110;
            }
            long length = HSOldFormatBigEndian16(in + 2);
            size_t size = rowSize * 2;
            LZW_Decompress(in, length, row, &size);
            memmove(aPixPak->pixels + i * rowSize, row, MIN(size, rowSize));
            in += length;
        }
        free(row);
        return noErr;
    }
    case 6: {
        // Rows of PackBits, the unpacked row length first (native order, as
        // the original read it).
        if (aLength < 2)
            return noErr;
        unsigned short rowLength;
        memcpy(&rowLength, data, 2);
        long in = 2;
        size_t out = 0;
        for (int i = 0; i < rows && out < aPixPak->size; i++) {
            long count = MIN((size_t)rowLength, aPixPak->size - out);
            in += HSOldFormatUnpackBits(data + in, aLength - in, aPixPak->pixels + out, count);
            out += count;
        }
        return noErr;
    }
    default:
        return noErr;
    }
}

// Fix: the original passed the whole record length on with the data past the
// 0x50-byte header, so decoding could read past the record.
OSErr UnpackGraphic(struct HSOldFormatPixPak *aPixPak, const void *aGraphic, long aLength)
{
    const unsigned char *graphic = aGraphic;
    short packType = 0;
    if (graphic[0x1d] & 0x10) {
        packType = HSOldFormatBigEndian16(graphic + 0x44);
        if (!packType)
            packType = 4;
    }
    return PixPak_Decompress(aPixPak, graphic + 0x50, aLength - 0x50, packType);
}

OSErr Graphic_GetImage(const void *aGraphic, struct HSOldFormatPixPak *aPixPak, long aLength)
{
    const unsigned char *graphic = aGraphic;
    Rect bounds;
    bounds.top = HSOldFormatBigEndian16(graphic + 0x1e);
    bounds.left = HSOldFormatBigEndian16(graphic + 0x20);
    bounds.bottom = HSOldFormatBigEndian16(graphic + 0x22);
    bounds.right = HSOldFormatBigEndian16(graphic + 0x24);
    OSErr error = CreatePixPak(aPixPak, &bounds, HSOldFormatBigEndian16(graphic + 0x36));
    if (error == noErr)
        error = UnpackGraphic(aPixPak, aGraphic, aLength);
    return error;
}

OSErr Graphic_GetBackground(const void *aData, struct HSOldFormatPixPak *aPixPak, const Rect *aBounds, short aDepth, short aPackType, long aLength)
{
    OSErr error = CreatePixPak(aPixPak, aBounds, aDepth);
    if (error == noErr)
        error = PixPak_Decompress(aPixPak, aData, aLength, aPackType);
    return error;
}

// ReSeedCT was empty, so the seed stays 0. Short tables mark their last entry
// with the value 1 (two colours) or 3 (three), as the original did.
unsigned char *Win2MacCTable(const unsigned char *aColors, short aCount)
{
    short size = aCount - 1;
    unsigned char *table = calloc(MAX(size, 0) * 8 + 16, 1);
    if (!table)
        return NULL;
    memcpy(table + 6, &size, 2);
    for (short i = 0; i <= size; i++) {
        unsigned short spec[4];
        spec[0] = i == size && size < 3 ? (size < 2 ? 1 : 3) : i;
        spec[1] = aColors[i * 4 + 2] << 8;
        spec[2] = aColors[i * 4 + 1] << 8;
        spec[3] = aColors[i * 4] << 8;
        memcpy(table + 8 + i * 8, spec, 8);
    }
    return table;
}

void DisposeCicn(struct HSOldFormatCicn *aCicn)
{
    if (!aCicn)
        return;
    free(aCicn->colors);
    free(aCicn->pixels);
    free(aCicn->maskRecord);
    free(aCicn);
}

// Reads the first image of an ICONDIR: the DIB's pixels and AND mask are
// bottom-up, so rows are copied last first; the mask is inverted to opacity.
// Fix: offsets and sizes are checked against the data; the original trusted
// them.
struct HSOldFormatCicn *IconToCicn(const void *aIcon, long aLength, short *aHotSpotH, short *aHotSpotV, short aSize[3])
{
    const unsigned char *icon = aIcon;
    if (aLength < 0x16)
        return NULL;
    unsigned int width = icon[6], height = icon[7];
    aSize[0] = width;
    aSize[1] = height;
    if (HSOldFormatLittleEndian16(icon + 2) == 2) {
        if (aHotSpotH)
            *aHotSpotH = HSOldFormatLittleEndian16(icon + 10);
        if (aHotSpotV)
            *aHotSpotV = HSOldFormatLittleEndian16(icon + 12);
    }
    unsigned int offset = HSOldFormatLittleEndian32(icon + 0x12);
    if (offset > aLength || aLength - offset < 0x28)
        return NULL;
    const unsigned char *bitmap = icon + offset;
    unsigned short depth = HSOldFormatLittleEndian16(bitmap + 0xe);
    aSize[2] = depth;
    unsigned int colorCount = HSOldFormatLittleEndian32(bitmap + 0x20);
    if (!colorCount)
        colorCount = 1u << (depth & 0x1f);
    // The table size is a short, as in the original.
    short tableCount = (short)colorCount;

    int maskRowBytes = (width + 15) / 16 * 2;
    int rowBytes = maskRowBytes * depth;
    int sourceRowBytes = (depth * width + 31) / 32 * 4;
    int sourceMaskRowBytes = (width + 31) / 32 * 4;
    size_t pixelsOffset = 0x28 + (size_t)colorCount * 4;
    size_t maskOffset = pixelsOffset + (size_t)sourceRowBytes * height;
    if (maskOffset + (size_t)sourceMaskRowBytes * height > aLength - offset
        || (tableCount > 0 && 0x28 + (size_t)tableCount * 4 > aLength - offset))
        return NULL;

    struct HSOldFormatCicn *cicn = calloc(sizeof(struct HSOldFormatCicn), 1);
    if (!cicn)
        return NULL;
    cicn->colors = Win2MacCTable(bitmap + 0x28, tableCount);
    cicn->pixels = calloc(MAX(rowBytes * height, 1), 1);
    cicn->maskRecord = calloc(24 + maskRowBytes * height, 1);
    if (!cicn->colors || !cicn->pixels || !cicn->maskRecord) {
        DisposeCicn(cicn);
        return NULL;
    }
    int copied = MIN(sourceRowBytes, rowBytes);
    for (unsigned int row = 0; row < height; row++)
        memmove(cicn->pixels + row * rowBytes, bitmap + pixelsOffset + (height - 1 - row) * sourceRowBytes, copied);
    short header[2] = { (short)width, (short)height };
    memcpy(cicn->maskRecord, header, sizeof(header));
    unsigned char *mask = cicn->maskRecord + 24;
    for (unsigned int row = 0; row < height; row++) {
        const unsigned char *source = bitmap + maskOffset + (height - 1 - row) * sourceMaskRowBytes;
        for (int i = 0; i < maskRowBytes; i++)
            mask[row * maskRowBytes + i] = i < sourceMaskRowBytes ? ~source[i] : 0;
    }
    return cicn;
}

// Fix: the original created every image as "skip first" with no alpha, which
// grey and indexed images no longer accept; those have no alpha info now.
CGImageRef HSOldFormatCreateCGImageWithPixels(const void *aPixels, size_t aWidth, size_t aHeight, int aDepth, size_t aRowBytes, BOOL aCopy, const unsigned char *aColors, size_t aColorsLength, BOOL aSwapBlackAndWhite)
{
    size_t bitsPerComponent, bitsPerPixel = aDepth;
    BOOL isRGB = NO;
    switch (aDepth) {
    case 1:
    case 2:
    case 4:
    case 8:
        bitsPerComponent = aDepth;
        break;
    case 16:
        bitsPerComponent = 5;
        isRGB = YES;
        break;
    case 32:
        bitsPerComponent = 8;
        isRGB = YES;
        break;
    case 44:
        bitsPerComponent = bitsPerPixel = 1;
        break;
    default:
        return NULL;
    }
    CGColorSpaceRef colorSpace;
    if (isRGB) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    } else if (!aColors) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        if (!rgb)
            return NULL;
        size_t count = aColorsLength >> 3;
        unsigned char *table = malloc(MAX(count * 3, 1));
        if (!table) {
            CGColorSpaceRelease(rgb);
            return NULL;
        }
        // The high bytes of each ColorSpec's red, green and blue.
        for (size_t i = 0; i < count; i++) {
            unsigned char *rgbEntry = table + i * 3;
            rgbEntry[0] = aColors[i * 8 + 3];
            rgbEntry[1] = aColors[i * 8 + 5];
            rgbEntry[2] = aColors[i * 8 + 7];
            if (aSwapBlackAndWhite) {
                if (rgbEntry[0] == 0xff && rgbEntry[1] == 0xff && rgbEntry[2] == 0xff)
                    memset(rgbEntry, 0, 3);
                else if (!rgbEntry[0] && !rgbEntry[1] && !rgbEntry[2])
                    memset(rgbEntry, 0xff, 3);
            }
        }
        colorSpace = count ? CGColorSpaceCreateIndexed(rgb, count - 1, table) : NULL;
        CGColorSpaceRelease(rgb);
        free(table);
    }
    if (!colorSpace)
        return NULL;
    CGImageRef image = NULL;
    CGDataProviderRef provider = NULL;
    if (aCopy) {
        CFDataRef data = CFDataCreate(NULL, aPixels, aRowBytes * aHeight);
        if (data) {
            provider = CGDataProviderCreateWithCFData(data);
            CFRelease(data);
        }
    } else {
        provider = CGDataProviderCreateWithData(NULL, aPixels, aRowBytes * aHeight, NULL);
    }
    if (provider) {
        CGBitmapInfo info = (CGBitmapInfo)(isRGB ? kCGImageAlphaNoneSkipFirst : kCGImageAlphaNone);
        image = CGImageCreate(aWidth, aHeight, bitsPerComponent, bitsPerPixel, aRowBytes, colorSpace, info, provider, NULL, false, kCGRenderingIntentDefault);
        CGDataProviderRelease(provider);
    }
    CGColorSpaceRelease(colorSpace);
    return image;
}

// Draws the image into premultiplied ARGB rows of the given length.
static CGContextRef HSOldFormatCreateARGBContext(void *aBytes, unsigned int aWidth, unsigned int aHeight, size_t aRowBytes, CGColorSpaceRef aColorSpace)
{
    CGContextRef context = CGBitmapContextCreate(aBytes, aWidth, aHeight, 8, aRowBytes, aColorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context) {
        CGContextSetShouldAntialias(context, false);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextClearRect(context, CGRectMake(0, 0, aWidth, aHeight));
    }
    return context;
}

// With a mask the pixels are drawn (uncopied) into an ARGB image through it,
// and that image's rows become the representation's source data. Quirk kept:
// the mask is placed at its offset but sized to the image less the offset.
NSImage *HSOldFormatCreateImageWithPixels(const void *aPixels, unsigned int aWidth, unsigned int aHeight, int aDepth, const unsigned char *aColors, size_t aColorsLength, const void *aMask, short aMaskType, unsigned int *aMaskRowBytes)
{
    size_t rowBytes = (aWidth + 15) / 16 * aDepth * 2;
    CGImageRef image;
    NSMutableData *sourceData = nil;
    if (!aMask) {
        image = HSOldFormatCreateCGImageWithPixels(aPixels, aWidth, aHeight, aDepth, rowBytes, YES, aColors, aColorsLength, NO);
    } else {
        const unsigned char *maskBits = aMask;
        unsigned short maskWidth = 0, maskHeight = 0, maskRowBytes = 0;
        short maskX = 0, maskY = 0;
        BOOL swapBlackAndWhite = NO;
        if (aMaskType == 4) {
            maskWidth = (unsigned short)aWidth;
            maskHeight = (unsigned short)aHeight;
            maskRowBytes = (maskWidth + 15) >> 3 & 0x3ffe;
        } else if (aMaskType >= 1 && aMaskType <= 3) {
            unsigned short header[4];
            memcpy(header, aMask, sizeof(header));
            if (aMaskType == 1) {
                for (int i = 0; i < 4; i++)
                    header[i] = CFSwapInt16(header[i]);
            }
            maskWidth = header[0];
            maskHeight = header[1];
            maskX = (short)header[2];
            maskY = (short)header[3];
            maskBits += 24;
            maskRowBytes = aMaskType == 2 ? (maskWidth + 15) >> 3 & 0x3ffe : (maskWidth + 31) >> 3 & 0x3ffc;
            swapBlackAndWhite = aMaskType == 3;
        } else {
            maskBits = NULL;
        }
        image = NULL;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (maskBits && maskWidth && maskHeight && maskRowBytes && colorSpace) {
            CGImageRef mask = NULL;
            CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, maskBits, maskRowBytes * maskHeight, NULL);
            if (provider) {
                const CGFloat decode[2] = { 1, 0 };
                mask = CGImageMaskCreate(maskWidth, maskHeight, 1, 1, maskRowBytes, provider, decode, false);
                CGDataProviderRelease(provider);
            }
            if (mask) {
                image = HSOldFormatCreateCGImageWithPixels(aPixels, aWidth, aHeight, aDepth, rowBytes, NO, aColors, aColorsLength, swapBlackAndWhite);
                if (image) {
                    size_t argbRowBytes = (aWidth * 4 + 15) & ~15u;
                    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image);
                    // Images without alpha are redrawn into ARGB first.
                    if (alpha == kCGImageAlphaNone || alpha == kCGImageAlphaNoneSkipLast || alpha == kCGImageAlphaNoneSkipFirst) {
                        void *bytes = malloc(argbRowBytes * aHeight);
                        CGContextRef context = bytes ? HSOldFormatCreateARGBContext(bytes, aWidth, aHeight, argbRowBytes, colorSpace) : NULL;
                        if (context) {
                            CGContextDrawImage(context, CGRectMake(0, 0, aWidth, aHeight), image);
                            CGContextRelease(context);
                            CFDataRef data = CFDataCreateWithBytesNoCopy(NULL, bytes, argbRowBytes * aHeight, kCFAllocatorMalloc);
                            if (data) {
                                CGDataProviderRef argbProvider = CGDataProviderCreateWithCFData(data);
                                CFRelease(data);
                                if (argbProvider) {
                                    CGImageRef argbImage = CGImageCreate(aWidth, aHeight, 8, 32, argbRowBytes, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst, argbProvider, NULL, false, kCGRenderingIntentDefault);
                                    CGDataProviderRelease(argbProvider);
                                    if (argbImage) {
                                        CGImageRelease(image);
                                        image = argbImage;
                                    }
                                }
                                bytes = NULL;
                            }
                        }
                        free(bytes);
                    }
                    sourceData = [[NSMutableData alloc] initWithLength:argbRowBytes * aHeight];
                    CGContextRef context = sourceData ? HSOldFormatCreateARGBContext([sourceData mutableBytes], aWidth, aHeight, argbRowBytes, colorSpace) : NULL;
                    if (context) {
                        CGContextClipToMask(context, CGRectMake(maskX, maskY, (CGFloat)aWidth - maskX, (CGFloat)aHeight - maskY), mask);
                        CGContextDrawImage(context, CGRectMake(0, 0, aWidth, aHeight), image);
                        CGContextRelease(context);
                        CGDataProviderRef maskedProvider = CGDataProviderCreateWithCFData((CFDataRef)sourceData);
                        if (maskedProvider) {
                            CGImageRef maskedImage = CGImageCreate(aWidth, aHeight, 8, 32, argbRowBytes, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst, maskedProvider, NULL, false, kCGRenderingIntentDefault);
                            CGDataProviderRelease(maskedProvider);
                            if (maskedImage) {
                                CGImageRelease(image);
                                image = maskedImage;
                                if (aMaskRowBytes)
                                    *aMaskRowBytes = maskRowBytes;
                            }
                        }
                    }
                }
                CGImageRelease(mask);
            }
        }
        CGColorSpaceRelease(colorSpace);
    }
    if (!image) {
        [sourceData release];
        return nil;
    }
    HSOldFormatGraphicsImportCGImageImageRep *representation = [[HSOldFormatGraphicsImportCGImageImageRep alloc] initWithCGImage:image sourceData:sourceData];
    CGImageRelease(image);
    [sourceData release];
    NSImage *result = [[NSImage alloc] initWithSize:NSMakeSize(aWidth, aHeight)];
    [result addRepresentation:representation];
    [representation release];
    return result;
}
