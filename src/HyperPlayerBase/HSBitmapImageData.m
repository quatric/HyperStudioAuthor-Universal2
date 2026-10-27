#import "HSBitmapImageData.h"

@implementation HSBitmapImageData
- (BOOL)isFlippedVertically
{
    return _bitmapImageDataFlags.isFlippedVertically ? YES : NO;
}
- (BOOL)isFlippedHorizontally
{
    return _bitmapImageDataFlags.isFlippedHorizontally ? YES : NO;
}
- (NSUInteger)bitsPerPixel
{
    return _bitsPerPixel;
}
- (NSUInteger)bytesPerRow
{
    return _bytesPerRow;
}
// NSBitmapFormat -> CGImageAlphaInfo; floating point samples report no alpha.
- (NSInteger)bitmapInfo
{
    if (_bitmapFormat & NSBitmapFormatFloatingPointSamples)
        return kCGImageAlphaNone;
    BOOL nonPremultiplied = (_bitmapFormat & NSBitmapFormatAlphaNonpremultiplied) != 0;
    if (_bitmapFormat & NSBitmapFormatAlphaFirst)
        return nonPremultiplied ? kCGImageAlphaFirst : kCGImageAlphaPremultipliedFirst;
    return nonPremultiplied ? kCGImageAlphaLast : kCGImageAlphaPremultipliedLast;
}
- (NSInteger)bitmapFormat
{
    return _bitmapFormat;
}
- (NSUInteger)colorSpaceSignature
{
    return _colorSpaceSignature;
}
- (BOOL)hasAlpha
{
    return _bitmapImageDataFlags.hasAlpha ? YES : NO;
}
- (NSUInteger)samplesPerPixel
{
    return _samplesPerPixel;
}
- (NSUInteger)bitsPerSample
{
    return _bitsPerSample;
}
- (NSUInteger)height
{
    return _height;
}
- (NSUInteger)width
{
    return _width;
}
- (id)mutableData
{
    return _mutableData;
}
- (id)data
{
    return _data ? _data : _mutableData;
}
// The original leaked the +1 data copies passed to the initialisers.
- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[[self class] allocWithZone:aZone] initWithMutableData:[[[self data] mutableCopyWithZone:aZone] autorelease] pixelsWide:_width pixelsHigh:_height bitsPerSample:_bitsPerSample samplesPerPixel:_samplesPerPixel hasAlpha:[self hasAlpha] colorSpaceSignature:_colorSpaceSignature bitmapFormat:_bitmapFormat bytesPerRow:_bytesPerRow bitsPerPixel:_bitsPerPixel isFlippedHorizontally:[self isFlippedHorizontally] isFlippedVertically:[self isFlippedVertically]];
}
// Immutable data is shared.
- (id)copyWithZone:(NSZone *)aZone
{
    if (_data)
        return [self retain];
    return [[[self class] allocWithZone:aZone] initWithData:[[_mutableData copyWithZone:aZone] autorelease] pixelsWide:_width pixelsHigh:_height bitsPerSample:_bitsPerSample samplesPerPixel:_samplesPerPixel hasAlpha:[self hasAlpha] colorSpaceSignature:_colorSpaceSignature bitmapFormat:_bitmapFormat bytesPerRow:_bytesPerRow bitsPerPixel:_bitsPerPixel isFlippedHorizontally:[self isFlippedHorizontally] isFlippedVertically:[self isFlippedVertically]];
}
- (void)dealloc
{
    [_data release];
    [_mutableData release];
    [super dealloc];
}
- (id)initWithMutableData:(id)aData pixelsWide:(NSUInteger)aWide pixelsHigh:(NSUInteger)aHigh bitsPerSample:(NSUInteger)aSample samplesPerPixel:(NSUInteger)aPixel hasAlpha:(BOOL)aAlpha colorSpaceSignature:(NSUInteger)aSignature bitmapFormat:(NSInteger)aFormat bytesPerRow:(NSUInteger)aRow bitsPerPixel:(NSUInteger)aPixel2 isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically
{
    self = [super init];
    if (self) {
        _mutableData = [aData retain];
        _width = (unsigned int)aWide;
        _height = (unsigned int)aHigh;
        _bitsPerSample = (unsigned int)aSample;
        _samplesPerPixel = (unsigned int)aPixel;
        _colorSpaceSignature = (unsigned int)aSignature;
        _bitmapFormat = (int)aFormat;
        _bytesPerRow = (unsigned int)aRow;
        _bitsPerPixel = (unsigned int)aPixel2;
        _bitmapImageDataFlags.hasAlpha = aAlpha ? 1 : 0;
        _bitmapImageDataFlags.isFlippedHorizontally = aHorizontally ? 1 : 0;
        _bitmapImageDataFlags.isFlippedVertically = aVertically ? 1 : 0;
    }
    return self;
}
- (id)initWithData:(id)aData pixelsWide:(NSUInteger)aWide pixelsHigh:(NSUInteger)aHigh bitsPerSample:(NSUInteger)aSample samplesPerPixel:(NSUInteger)aPixel hasAlpha:(BOOL)aAlpha colorSpaceSignature:(NSUInteger)aSignature bitmapFormat:(NSInteger)aFormat bytesPerRow:(NSUInteger)aRow bitsPerPixel:(NSUInteger)aPixel2 isFlippedHorizontally:(BOOL)aHorizontally isFlippedVertically:(BOOL)aVertically
{
    self = [super init];
    if (self) {
        _data = [aData retain];
        _width = (unsigned int)aWide;
        _height = (unsigned int)aHigh;
        _bitsPerSample = (unsigned int)aSample;
        _samplesPerPixel = (unsigned int)aPixel;
        _colorSpaceSignature = (unsigned int)aSignature;
        _bitmapFormat = (int)aFormat;
        _bytesPerRow = (unsigned int)aRow;
        _bitsPerPixel = (unsigned int)aPixel2;
        _bitmapImageDataFlags.hasAlpha = aAlpha ? 1 : 0;
        _bitmapImageDataFlags.isFlippedHorizontally = aHorizontally ? 1 : 0;
        _bitmapImageDataFlags.isFlippedVertically = aVertically ? 1 : 0;
    }
    return self;
}
@end
