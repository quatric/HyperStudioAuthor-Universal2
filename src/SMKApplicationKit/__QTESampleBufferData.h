#import "SMKApplicationKitPrefix.h"


@interface __QTESampleBufferData : NSData
{
    QTSampleBuffer *_sampleBuffer;
}
- (const void *)bytes;
- (NSUInteger)length;
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (Class)classForCoder;
- (void)dealloc;
- (id)initWithSampleBuffer:(id)aBuffer;
@end

@interface QTSampleBuffer (QTESampleBuffer)
- (struct __CVBuffer *)QTE_openGLCompatiblePixelBuffer;
- (struct __CVBuffer *)QTE_pixelBuffer;
- (id)QTE_retainDataForAllSamples;
@end

