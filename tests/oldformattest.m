// HyperStudio 4 graphics import: PackBits and LZ unpacking, indexed and
// masked images, Windows icons, background palettes.
#import <Cocoa/Cocoa.h>
#import "../src/HyperPlayerBase/HSOldFormatGraphics.h"

@interface HSOldFormatGraphicsImport : NSObject
- (void)setBackgroundData:(id)aData;
- (id)backgroundColorAtIndex:(NSUInteger)aIndex;
- (id)imageFromIconData:(id)aData;
@end

static int failures;
#define CHECK(...) do { if (!(__VA_ARGS__)) { printf("FAIL %s:%d %s\n", __FILE__, __LINE__, #__VA_ARGS__); failures++; } } while (0)

// Channels within a colour-matching tolerance.
static BOOL Near(unsigned int aPixel, unsigned int aExpected)
{
    for (int shift = 0; shift < 32; shift += 8)
        if (abs((int)(aPixel >> shift & 0xff) - (int)(aExpected >> shift & 0xff)) > 0x30)
            return NO;
    return YES;
}

// The image's pixel (x from the left, y from the top) as premultiplied ARGB.
static unsigned int Pixel(NSImage *aImage, int aX, int aY)
{
    CGImageRef image = [aImage CGImageForProposedRect:NULL context:nil hints:nil];
    size_t width = CGImageGetWidth(image), height = CGImageGetHeight(image);
    unsigned int *pixels = calloc(width * height, 4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    unsigned int pixel = pixels[aY * width + aX];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    return pixel;
}

int main(void)
{
    @autoreleasepool {
        // PackBits: a run of four 'A', then the literals "BCDE".
        struct HSOldFormatPixPak pixPak;
        Rect bounds = { 10, 20, 12, 24 };
        CHECK(CreatePixPak(&pixPak, &bounds, 8) == noErr);
        CHECK(pixPak.rowBytes == 16 && pixPak.size == 32 && pixPak.bounds.bottom == 2 && pixPak.bounds.right == 4);
        DisposePixPak(&pixPak);
        Rect wide = { 0, 0, 1, 4 };
        CHECK(CreatePixPak(&pixPak, &wide, 8) == noErr);
        const unsigned char packed[] = { 0xfd, 'A', 0x03, 'B', 'C', 'D', 'E' };
        Rect eight = { 0, 0, 1, 16 };
        DisposePixPak(&pixPak);
        CHECK(CreatePixPak(&pixPak, &eight, 4) == noErr && pixPak.size == 8);
        CHECK(PixPak_Decompress(&pixPak, packed, sizeof(packed), 0) == noErr);
        CHECK(memcmp(pixPak.pixels, "AAAABCDE", 8) == 0);
        DisposePixPak(&pixPak);

        // The LZ decoder: stored data, and two literals then a 4-byte copy
        // from 2 back.
        unsigned char out[16];
        size_t size = sizeof(out);
        const unsigned char stored[] = { 1, 0, 0, 0, 'x', 'y' };
        LZW_Decompress(stored, sizeof(stored), out, &size);
        CHECK(size == 2 && memcmp(out, "xy", 2) == 0);
        const unsigned char compressed[] = { 0, 0, 0, 0, 0x04, 0x00, 'a', 'b', 0x01, 0x02 };
        size = sizeof(out);
        LZW_Decompress(compressed, sizeof(compressed), out, &size);
        CHECK(size == 6 && memcmp(out, "ababab", 6) == 0);
        size = 3;
        LZW_Decompress(compressed, sizeof(compressed), out, &size);
        CHECK(size == 3);
        // Pack type 2: 4 bytes of 0x11 before and after, "ab" in between.
        Rect ten = { 0, 0, 2, 10 };
        CHECK(CreatePixPak(&pixPak, &ten, 8) == noErr && pixPak.size == 32);
        unsigned char runs[16 + sizeof(compressed)] = { 0x11, 0x11, 0x11, 0x11, 0, 0, 0, 4, 0x22, 0x22, 0x22, 0x22, 0, 0, 0, 4 };
        memcpy(runs + 16, compressed, sizeof(compressed));
        CHECK(PixPak_Decompress(&pixPak, runs, sizeof(runs), 2) == noErr);
        CHECK(pixPak.pixels[0] == 0x11 && pixPak.pixels[3] == 0x11 && memcmp(pixPak.pixels + 4, "ababab", 6) == 0 && pixPak.pixels[31] == 0x22 && pixPak.pixels[28] == 0x22 && pixPak.pixels[27] == 0);
        DisposePixPak(&pixPak);

        // Indexed 8-bit pixels through a red/blue palette (ColorSpecs with
        // native-order components).
        unsigned short colors[8] = { 0, 0xffff, 0, 0, 1, 0, 0, 0xffff };
        unsigned char pixels[2 * 32] = { 0 };
        pixels[1] = 1;
        NSImage *image = HSOldFormatCreateImageWithPixels(pixels, 2, 2, 8, (const unsigned char *)colors, sizeof(colors), NULL, 4, NULL);
        CHECK(image && NSEqualSizes([image size], NSMakeSize(2, 2)));
        CHECK(Near(Pixel(image, 0, 0), 0xffff0000) && Near(Pixel(image, 1, 0), 0xff0000ff));
        [image release];
        // A bare mask hiding the right column.
        unsigned char mask[2 * 2] = { 0x80, 0, 0x80, 0 };
        image = HSOldFormatCreateImageWithPixels(pixels, 2, 2, 8, (const unsigned char *)colors, sizeof(colors), mask, 4, NULL);
        CHECK(image && Near(Pixel(image, 0, 0), 0xffff0000) && Pixel(image, 1, 0) >> 24 == 0);
        [image release];

        // A 16x16 4-bit icon: colour 1 (green) on the left half, the right
        // half transparent through the AND mask.
        NSMutableData *icon = [NSMutableData dataWithLength:6 + 16 + 40 + 16 * 4 + 16 * 8 + 16 * 4];
        unsigned char *bytes = [icon mutableBytes];
        bytes[2] = 1;
        bytes[4] = 1;
        bytes[6] = 16;
        bytes[7] = 16;
        bytes[0x12] = 22;
        unsigned char *dib = bytes + 22;
        dib[0] = 40;
        dib[4] = 16;
        dib[8] = 32;
        dib[12] = 1;
        dib[14] = 4;
        dib[0x20] = 16;
        dib[40 + 4 + 1] = 0xff;
        for (int row = 0; row < 16; row++) {
            memset(dib + 40 + 64 + row * 8, 0x11, 4);
            dib[40 + 64 + 128 + row * 4 + 1] = 0xff;
        }
        HSOldFormatGraphicsImport *import = [[HSOldFormatGraphicsImport alloc] init];
        image = [import imageFromIconData:icon];
        CHECK(image && NSEqualSizes([image size], NSMakeSize(16, 16)));
        CHECK(Near(Pixel(image, 0, 0), 0xff00ff00) && Pixel(image, 15, 15) >> 24 == 0);
        CHECK(NSEqualSizes([[import imageFromIconData:[NSData dataWithBytes:"\1\0\1\0\0\0" length:6]] size], NSMakeSize(1, 1)));

        // A background palette: ctSize 1, white and a 50% grey.
        unsigned char background[8 + 16 + 8] = { 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0, 1, 0x80, 0, 0x80, 0, 0x80, 0 };
        [import setBackgroundData:[NSData dataWithBytes:background length:sizeof(background)]];
        NSColor *color = [import backgroundColorAtIndex:2];
        CHECK(color && fabs([color redComponent] - 128 / 255.0) < 1e-6 && [color alphaComponent] == 1);
        CHECK([[import backgroundColorAtIndex:1] greenComponent] == 1 && [import backgroundColorAtIndex:3] == nil);
        CHECK([[import backgroundColorAtIndex:0] isEqual:[NSColor blackColor]]);
        [import release];
    }
    printf("%s\n", failures ? "FAILED" : "ok");
    return failures != 0;
}
