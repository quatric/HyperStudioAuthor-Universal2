#import "HSOldFormatGraphicsImport.h"
#import "HSOldFormatGraphics.h"

static unsigned short HSOldFormatImportBigEndian16(const unsigned char *aBytes)
{
    return (unsigned short)(aBytes[0] << 8 | aBytes[1]);
}

static unsigned int HSOldFormatImportBigEndian32(const unsigned char *aBytes)
{
    return (unsigned int)aBytes[0] << 24 | aBytes[1] << 16 | aBytes[2] << 8 | aBytes[3];
}

// Copies big-endian ColorSpecs (value, red, green, blue) into native order,
// leaving each value unset as the original did.
static void HSOldFormatImportCopyColorSpecs(unsigned char *aTable, const unsigned char *aSpecs, size_t aCount)
{
    for (size_t i = 0; i < aCount; i++) {
        unsigned short rgb[3];
        for (int c = 0; c < 3; c++)
            rgb[c] = HSOldFormatImportBigEndian16(aSpecs + i * 8 + 2 + c * 2);
        memcpy(aTable + i * 8 + 2, rgb, sizeof(rgb));
    }
}

// Images of HyperStudio 4 graphics: the background (a palette, then packed
// pixels), graphic items (a graphic record with its mask at the end), icons
// and cursors (Windows icon data) and cel frames (pixel records, later frames
// as word patches over the last full frame).
@implementation HSOldFormatGraphicsImport

// The background's ColorTable in native order: the header and ctSize + 1
// ColorSpecs.
- (id)HSOldFormatGraphicsImport_backgroundPaletteData
{
    if (_backgroundPaletteData)
        return _backgroundPaletteData;
    if (_isBackgroundPalatteDataAnalyzed)
        return nil;
    NSMutableData *palette = nil;
    NSUInteger length = [_backgroundData length];
    if (length > 16) {
        const unsigned char *bytes = [_backgroundData bytes];
        NSUInteger size = HSOldFormatImportBigEndian16(bytes + 6);
        if (size * 8 + 16 <= length) {
            palette = [[NSMutableData alloc] initWithLength:size * 8 + 8];
            HSOldFormatImportCopyColorSpecs([palette mutableBytes], bytes + 8, size + 1);
        }
    }
    _backgroundPaletteData = palette;
    _isBackgroundPalatteDataAnalyzed = YES;
    return palette;
}

// Index 0 is black; otherwise the palette entry before the index.
- (id)backgroundColorAtIndex:(NSUInteger)aIndex
{
    if (!aIndex)
        return [NSColor blackColor];
    NSData *palette = [self HSOldFormatGraphicsImport_backgroundPaletteData];
    NSUInteger count = [palette length] >> 3;
    if (!count || aIndex - 1 >= count)
        return nil;
    const unsigned short *spec = (const unsigned short *)[palette bytes] + (aIndex - 1) * 4;
    return [NSColor colorWithCalibratedRed:(spec[1] >> 8) / 255.0 green:(spec[2] >> 8) / 255.0 blue:(spec[3] >> 8) / 255.0 alpha:1];
}

- (void)setGraphicItemBorderBezierPath:(id)aPath
{
    if (_borderBezierPath != aPath) {
        [_borderBezierPath autorelease];
        _borderBezierPath = [aPath retain];
    }
}

- (id)graphicItemBorderBezierPath
{
    return _borderBezierPath;
}

- (void)setGraphicItemData:(id)aData
{
    if (_graphicItemData != aData) {
        [_graphicItemData release];
        _graphicItemData = [aData retain];
        [_graphicItemImage release];
        _graphicItemImage = nil;
    }
}

- (id)graphicItemData
{
    return _graphicItemData;
}

- (void)setBackgroundData:(id)aData
{
    if (_backgroundData != aData) {
        [_backgroundData release];
        _backgroundData = [aData retain];
        [_backgroundPaletteData release];
        _backgroundPaletteData = nil;
        _isBackgroundPalatteDataAnalyzed = NO;
    }
}

- (id)backgroundData
{
    return _backgroundData;
}

// The graphic in the background's palette, masked by the record that ends the
// data (its offset from the end at +0x3c, one byte further when bit 1 of +0x16
// is set); the mask also becomes the item's border path. Once made, the image
// replaces the data. Graphics flagged 0x40 at +0x17 have no image.
// Fix: data shorter than the graphic header is refused; the original read it.
- (id)graphicItemImage
{
    if (_graphicItemImage)
        return _graphicItemImage;
    NSUInteger length = [_graphicItemData length];
    if (length < 0x50)
        return nil;
    const unsigned char *bytes = [_graphicItemData bytes];
    unsigned short top = HSOldFormatImportBigEndian16(bytes + 0x1e), left = HSOldFormatImportBigEndian16(bytes + 0x20);
    unsigned short bottom = HSOldFormatImportBigEndian16(bytes + 0x22), right = HSOldFormatImportBigEndian16(bytes + 0x24);
    if (right == left || bottom == top)
        return nil;
    if (bytes[0x17] & 0x40)
        return _graphicItemImage;
    unsigned int maskOffset = HSOldFormatImportBigEndian32(bytes + 0x3c);
    const unsigned char *mask = NULL;
    if (maskOffset && maskOffset <= length)
        mask = bytes + length - maskOffset - ((bytes[0x16] & 2) ? 1 : 0);
    struct HSOldFormatPixPak pixPak = { 0 };
    if (Graphic_GetImage(bytes, &pixPak, length) == noErr) {
        unsigned int maskRowBytes = 0;
        NSData *palette = [self HSOldFormatGraphicsImport_backgroundPaletteData];
        NSUInteger paletteLength = [palette length];
        _graphicItemImage = HSOldFormatCreateImageWithPixels(pixPak.pixels, right - left, bottom - top, HSOldFormatImportBigEndian16(bytes + 0x36), paletteLength ? [palette bytes] : NULL, paletteLength, mask, 1, &maskRowBytes);
        if (_graphicItemImage) {
            if ((int)maskOffset > 0 && maskRowBytes) {
                NSBezierPath *path = [NSBezierPath hyperBezierPathFromOneBitMask:(void *)(mask + 24) width:(short)HSOldFormatImportBigEndian16(mask) height:(short)HSOldFormatImportBigEndian16(mask + 2) bytesPerRow:maskRowBytes pathColor:1];
                if (path) {
                    NSAffineTransform *transform = [NSAffineTransform transform];
                    [transform translateXBy:HSOldFormatImportBigEndian16(mask + 4) yBy:HSOldFormatImportBigEndian16(mask + 6)];
                    [path transformUsingAffineTransform:transform];
                    [self setGraphicItemBorderBezierPath:path];
                }
            }
            [_graphicItemData release];
            _graphicItemData = nil;
        }
    }
    DisposePixPak(&pixPak);
    return _graphicItemImage;
}

// The rectangle of the background (packed pixels after the 8-byte header and
// the palette) in the background's palette. The flags are not used.
- (id)backgroundImageWithRect:(NSRect)aRect depth:(short)aDepth packtype:(short)aPacktype flags:(short)aFlags
{
    if (!_backgroundData || NSIsEmptyRect(aRect))
        return nil;
    NSData *palette = [self HSOldFormatGraphicsImport_backgroundPaletteData];
    NSUInteger paletteLength = [palette length], length = [_backgroundData length];
    if (paletteLength + 8 > length)
        return nil;
    Rect bounds;
    bounds.top = (short)lrintf(aRect.origin.y);
    bounds.left = (short)lrintf(aRect.origin.x);
    bounds.bottom = (short)lrintf(aRect.size.height) + bounds.top;
    bounds.right = (short)lrintf(aRect.size.width) + bounds.left;
    struct HSOldFormatPixPak pixPak = { 0 };
    NSImage *image = nil;
    if (Graphic_GetBackground((const unsigned char *)[_backgroundData bytes] + 8 + paletteLength, &pixPak, &bounds, aDepth, aPacktype, length - 8 - paletteLength) == noErr)
        image = [HSOldFormatCreateImageWithPixels(pixPak.pixels, bounds.right - bounds.left, bounds.bottom - bounds.top, aDepth, [palette bytes], paletteLength, NULL, 1, NULL) autorelease];
    DisposePixPak(&pixPak);
    return image;
}

// Windows icon (type 1) or cursor (type 2, black and white swapped) data;
// anything else gives an empty 1x1 image.
- (id)imageFromIconData:(id)aData
{
    if ([aData length] < 6)
        return nil;
    const unsigned short *header = [aData bytes];
    NSImage *image;
    if (header[0] == 0 && (unsigned short)(header[1] - 1) < 2) {
        short size[3] = { 0, 0, 0 };
        struct HSOldFormatCicn *cicn = IconToCicn([aData bytes], [aData length], NULL, NULL, size);
        if (!cicn)
            return nil;
        short tableSize;
        memcpy(&tableSize, cicn->colors + 6, 2);
        image = HSOldFormatCreateImageWithPixels(cicn->pixels, size[0], size[1], size[2], cicn->colors + 8, tableSize * 8 + 8, cicn->maskRecord, header[1] == 2 ? 3 : 2, NULL);
        DisposeCicn(cicn);
    } else {
        image = [[NSImage alloc] initWithSize:NSMakeSize(1, 1)];
    }
    return [image autorelease];
}

// The cel image's premultiplied ARGB rows: the masked image's own source data,
// or the image drawn anew.
- (id)imageARGB8888PremultipliedDataForPPakData:(id)aData mask:(id)aMask width:(unsigned int *)aWidth height:(unsigned int *)aHeight bytesPerRow:(unsigned int *)aRow
{
    NSImage *image = [self imageForPPakData:aData mask:aMask frameData:nil];
    if (!image)
        return nil;
    HSOldFormatGraphicsImportCGImageImageRep *representation = (HSOldFormatGraphicsImportCGImageImageRep *)[[image representations] objectAtIndex:0];
    if (![representation isKindOfClass:[HSOldFormatGraphicsImportCGImageImageRep class]])
        return nil;
    CGImageRef cgImage = [representation cgImage];
    if (!cgImage)
        return nil;
    size_t width = CGImageGetWidth(cgImage), height = CGImageGetHeight(cgImage);
    NSData *data = [representation sourceData];
    unsigned int rowBytes;
    if (!data) {
        rowBytes = (unsigned int)((width * 4 + 15) & ~(size_t)15);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        NSMutableData *pixels = [NSMutableData dataWithLength:rowBytes * height];
        if (!pixels)
            return nil;
        CGContextRef context = CGBitmapContextCreate([pixels mutableBytes], width, height, 8, rowBytes, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        // Fix: the original leaked the colour space on this failure.
        if (!context) {
            CGColorSpaceRelease(colorSpace);
            return nil;
        }
        CGContextSetShouldAntialias(context, false);
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextClearRect(context, CGRectMake(0, 0, width, height));
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        data = pixels;
    } else {
        rowBytes = (unsigned int)CGImageGetBytesPerRow(cgImage);
    }
    if (aWidth)
        *aWidth = (unsigned int)width;
    if (aHeight)
        *aHeight = (unsigned int)height;
    if (aRow)
        *aRow = rowBytes;
    return data;
}

// A cel record: width (+0xa), height (+0xc), depth (+0xe), pack type (+0x18),
// palette size (+0x1a, a ColorTable from +0x3a) and pixel data size (+0x1e,
// after the palette), all big-endian. The mask is a record of the same shape
// unpacked at the image's size (all opaque when it can't be unpacked). Without
// frame data the pixels are unpacked and kept; frame data patches the kept
// pixels with (offset, word) pairs, 0x180 words moving the offsets on 0x8000.
// Quirk kept: a palette size under 8 is used whole. Fix: sizes are checked
// against the data, and patches against the kept pixels.
- (id)imageForPPakData:(id)aData mask:(id)aMask frameData:(id)aData2
{
    NSUInteger length = [aData length];
    if (length <= 0x39)
        return nil;
    const unsigned char *bytes = [aData bytes];
    unsigned short height = HSOldFormatImportBigEndian16(bytes + 0xc), width = HSOldFormatImportBigEndian16(bytes + 0xa);
    if (!height || !width)
        return nil;
    unsigned int pixelsSize = HSOldFormatImportBigEndian32(bytes + 0x1e);
    if (!pixelsSize || pixelsSize > length)
        return nil;
    short depth = HSOldFormatImportBigEndian16(bytes + 0xe);
    if (!depth)
        return nil;
    unsigned int paletteSize = HSOldFormatImportBigEndian32(bytes + 0x1a);
    if ((NSUInteger)paletteSize + 0x3a + pixelsSize > length)
        return nil;
    size_t colorsLength = paletteSize < 8 ? paletteSize : paletteSize - 8;
    unsigned char *colors = NULL;
    if (colorsLength) {
        colors = malloc(colorsLength);
        if (colors)
            HSOldFormatImportCopyColorSpecs(colors, bytes + 0x42, colorsLength / 8);
    }
    Rect bounds = { 0, 0, (short)height, (short)width };

    struct HSOldFormatPixPak maskPixPak = { 0 };
    const void *maskBits = NULL;
    NSUInteger maskLength = [aMask length];
    if (maskLength > 0x3a) {
        const unsigned char *mask = [aMask bytes];
        unsigned short maskDepth = HSOldFormatImportBigEndian16(mask + 0xe);
        unsigned int maskSize = HSOldFormatImportBigEndian32(mask + 0x1e);
        if (maskSize && maskSize + 0x3a <= maskLength && maskDepth) {
            if (Graphic_GetBackground(mask + 0x3a, &maskPixPak, &bounds, maskDepth, HSOldFormatImportBigEndian16(mask + 0x18), maskSize) != noErr && maskPixPak.pixels)
                memset(maskPixPak.pixels, 0xff, maskPixPak.size);
            maskBits = maskPixPak.pixels;
        }
    }

    NSImage *image = nil;
    NSUInteger frameLength = [aData2 length];
    if (!frameLength) {
        struct HSOldFormatPixPak pixPak = { 0 };
        if (Graphic_GetBackground(bytes + 0x3a + paletteSize, &pixPak, &bounds, depth, HSOldFormatImportBigEndian16(bytes + 0x18), pixelsSize) == noErr) {
            [_lastCellFrameData release];
            _lastCellFrameData = [[NSMutableData alloc] initWithBytes:pixPak.pixels length:pixPak.size];
            image = HSOldFormatCreateImageWithPixels(pixPak.pixels, width, height, depth, colors, colorsLength, maskBits, 4, NULL);
        }
        DisposePixPak(&pixPak);
    } else if (_lastCellFrameData) {
        const unsigned short *patch = [aData2 bytes];
        unsigned char *pixels = [_lastCellFrameData mutableBytes];
        NSUInteger pixelsLength = [_lastCellFrameData length], base = 0;
        for (NSUInteger left = frameLength / 4; left; left--, patch += 2) {
            if (patch[0] == 0x180) {
                base += 0x8000;
                continue;
            }
            NSUInteger offset = base + CFSwapInt16BigToHost(patch[0]);
            if (offset + 2 <= pixelsLength)
                memcpy(pixels + offset, &patch[1], 2);
        }
        image = HSOldFormatCreateImageWithPixels(pixels, width, height, depth, colors, colorsLength, maskBits, 4, NULL);
    }
    free(colors);
    DisposePixPak(&maskPixPak);
    return [image autorelease];
}

- (void)dealloc
{
    [_backgroundPaletteData release];
    [_backgroundData release];
    [_graphicItemData release];
    [_graphicItemImage release];
    [_lastCellFrameData release];
    [_borderBezierPath release];
    [super dealloc];
}

@end

// Keeps the bytes an image was made over alive with it.
@implementation HSOldFormatGraphicsImportCGImageImageRep

- (void)dealloc
{
    [_sourceData release];
    [super dealloc];
}

- (id)sourceData
{
    return _sourceData;
}

- (id)initWithCGImage:(struct CGImage *)aImage sourceData:(id)aData
{
    self = [super initWithCGImage:aImage];
    if (self)
        _sourceData = [aData retain];
    return self;
}

@end
