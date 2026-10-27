#import "__QTESampleBufferData.h"
#import "CVEPixelBuffer.h"

// The bytes of a sample buffer's samples without copying them; the samples
// are kept while it lives.
@implementation __QTESampleBufferData

- (const void *)bytes
{
    return [_sampleBuffer bytesForAllSamples];
}

- (NSUInteger)length
{
    return [_sampleBuffer lengthForAllSamples];
}

- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[NSMutableData allocWithZone:aZone] initWithData:self];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [self retain];
}

- (Class)classForCoder
{
    return [NSData class];
}

- (void)dealloc
{
    [_sampleBuffer decrementSampleUseCount];
    [_sampleBuffer release];
    [super dealloc];
}

- (id)initWithSampleBuffer:(id)aBuffer
{
    self = [self init];
    if (!self)
        return nil;
    _sampleBuffer = [aBuffer retain];
    [_sampleBuffer incrementSampleUseCount];
    return self;
}

@end

// Releases the sample buffer whose bytes a pixel buffer had.
static void ReleaseSampleBuffer(void *releaseRefCon, const void *baseAddress)
{
    QTSampleBuffer *buffer = releaseRefCon;
    [buffer decrementSampleUseCount];
    [buffer release];
}

@implementation QTSampleBuffer (QTESampleBuffer)

// A pixel buffer of the samples' bytes (a single frame): the decompressed
// frame's own, or one made with them (the original's only way, sized by the
// encoded pixels size with rows of length / height bytes). Autoreleased.
static CVPixelBufferRef SamplePixelBuffer(QTSampleBuffer *self)
{
    CVImageBufferRef image = CMSampleBufferGetImageBuffer([self CMSampleBuffer]);
    if (image && CFGetTypeID(image) == CVPixelBufferGetTypeID())
        return (CVPixelBufferRef)[[(id)image retain] autorelease];
    NSUInteger length = [self lengthForAllSamples];
    QTFormatDescription *description = [self formatDescription];
    if (!length || !description)
        return NULL;
    NSValue *sizeValue = [description attributeForKey:QTFormatDescriptionVideoEncodedPixelsSizeAttribute];
    if (!sizeValue)
        return NULL;
    NSSize size = [sizeValue sizeValue];
    if (!(size.width > 0))
        return NULL;
    long width = lroundf(ceilf(size.width));
    if (!width || !(size.height > 0))
        return NULL;
    long height = lroundf(ceilf(size.height));
    if (!height)
        return NULL;
    CVPixelBufferRef buffer = NULL;
    [[self retain] incrementSampleUseCount];
    if (CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, [description formatType],
                                     [self bytesForAllSamples], length / height, ReleaseSampleBuffer, self, NULL,
                                     &buffer) != kCVReturnSuccess || !buffer) {
        ReleaseSampleBuffer(self, NULL);
        return NULL;
    }
    return (CVPixelBufferRef)[(id)buffer autorelease];
}

// The pixel buffer if OpenGL can read its rows as they are.
- (struct __CVBuffer *)QTE_openGLCompatiblePixelBuffer
{
    CVPixelBufferRef buffer = SamplePixelBuffer(self);
    GLint rowLength, alignment;
    if (buffer && !CVEPixelBufferIsOpenGLCompatible(buffer, NULL, NULL, NULL, &rowLength, &alignment))
        return NULL;
    return buffer;
}

- (struct __CVBuffer *)QTE_pixelBuffer
{
    return SamplePixelBuffer(self);
}

// +1.
- (id)QTE_retainDataForAllSamples
{
    return [[__QTESampleBufferData alloc] initWithSampleBuffer:self];
}

@end
