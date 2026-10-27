#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

// The HyperStudio 4 graphics engine, reduced to what the old-format import
// uses. The original built QuickDraw pixel maps, GDevices and ports around
// each PixPak and kept everything in Memory Manager handles; QuickDraw is gone
// on 64-bit and the import only reads the unpacked pixels, so a PixPak is now
// the pixel buffer and its geometry, and a converted icon a plain record.

#ifdef __cplusplus
extern "C" {
#endif

struct HSOldFormatPixPak {
    unsigned char *pixels;
    size_t size;
    short depth;
    short rowBytes;
    Rect bounds;
};

// A Windows icon or cursor converted for drawing: the palette as a ColorTable
// (ctSize at +6, ColorSpecs from +8), the pixels top row first with
// 2 * ((width + 15) / 16) * depth bytes per row, and the mask record the image
// builder takes (width, height, 0, 0 as shorts, 16 zero bytes, then the rows
// at 2 * ((width + 15) / 16) bytes, 1 = opaque).
struct HSOldFormatCicn {
    unsigned char *colors;
    unsigned char *pixels;
    unsigned char *maskRecord;
};

// The pixel buffer for the bounds (moved to the origin) at the depth, cleared;
// paramErr when a row would reach 16 KB, memFullErr without memory.
OSErr CreatePixPak(struct HSOldFormatPixPak *aPixPak, const Rect *aBounds, short aDepth);
void DisposePixPak(struct HSOldFormatPixPak *aPixPak);
// Unpacks into the PixPak: 0 PackBits, 1 compressed, 2 compressed between
// constant runs, 3 unsupported (returns 1), 4 compressed rows, 6 PackBits rows,
// 1000 chosen by depth.
OSErr PixPak_Decompress(struct HSOldFormatPixPak *aPixPak, const void *aData, long aLength, short aPackType);
// A graphic record: 0x50 bytes of big-endian header, then the packed pixels.
OSErr UnpackGraphic(struct HSOldFormatPixPak *aPixPak, const void *aGraphic, long aLength);
OSErr Graphic_GetImage(const void *aGraphic, struct HSOldFormatPixPak *aPixPak, long aLength);
OSErr Graphic_GetBackground(const void *aData, struct HSOldFormatPixPak *aPixPak, const Rect *aBounds, short aDepth, short aPackType, long aLength);
// The engine's LZ decoder: a type byte (1 = stored) and 3 more header bytes,
// then 16-bit flag words, each flag a literal byte or a 12-bit distance with a
// 3 to 18 byte copy. aSize holds the buffer size and receives the bytes made.
void LZW_Decompress(const void *aData, long aLength, void *aBuffer, size_t *aSize);

// Windows RGBQUADs to a ColorTable (malloc'd).
unsigned char *Win2MacCTable(const unsigned char *aColors, short aCount);
// aSize receives width, height and depth; the hot spot is read for cursors.
struct HSOldFormatCicn *IconToCicn(const void *aIcon, long aLength, short *aHotSpotH, short *aHotSpotV, short aSize[3]);
void DisposeCicn(struct HSOldFormatCicn *aCicn);

// A CGImage over the pixels at depth 1, 2, 4, 8 (grey, or indexed through the
// ColorSpecs), 16 or 32 (RGB), or 44 (one bit); optionally copying them, and
// optionally swapping black and white in the palette.
CGImageRef HSOldFormatCreateCGImageWithPixels(const void *aPixels, size_t aWidth, size_t aHeight, int aDepth, size_t aRowBytes, BOOL aCopy, const unsigned char *aColors, size_t aColorsLength, BOOL aSwapBlackAndWhite);
// The pixels as an NSImage (retained), clipped by a 1-bit mask: type 4 a bare
// mask the size of the image, 1 to 3 a mask record (1 big-endian, 3 with black
// and white swapped). aMaskRowBytes receives the mask's row bytes.
NSImage *HSOldFormatCreateImageWithPixels(const void *aPixels, unsigned int aWidth, unsigned int aHeight, int aDepth, const unsigned char *aColors, size_t aColorsLength, const void *aMask, short aMaskType, unsigned int *aMaskRowBytes);

#ifdef __cplusplus
}
#endif
