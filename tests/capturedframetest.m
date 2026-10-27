#import "HSQTKit.h"
// Turns a YUV pixel buffer and a compressed movie sample into images with the Quartz frame processor: sh tests/run.sh capturedframetest <movie>
@protocol CapturedFrameTest
- (id)initWithImageBuffer:(CVImageBufferRef)aBuffer sampleBuffer:(id)aBuffer2 frameProcessor:(id)aProcessor;
- (id)frameRepresentation;
- (BOOL)isFrameProcessed;
@end
static NSString *describe(CGImageRef image) {
  if (image == NULL) return @"no image";
  unsigned char p[4] = {0};
  CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
  CGContextRef c = CGBitmapContextCreate(p, 1, 1, 8, 4, cs, kCGImageAlphaPremultipliedLast);
  CGContextDrawImage(c, CGRectMake(0, 0, 1, 1), image);
  CGContextRelease(c); CGColorSpaceRelease(cs);
  return [NSString stringWithFormat:@"%zux%zu %d,%d,%d,%d", CGImageGetWidth(image), CGImageGetHeight(image), p[0], p[1], p[2], p[3]];
}
int main(int argc, char **argv) {
  @autoreleasepool {
    id processor = [[NSClassFromString(@"HSQuartzVideoFrameProcessor") alloc] init];
    Class frameClass = NSClassFromString(@"HSQuartzVideoFrameProcessor_HSCapturedVideoFrame");
    CVPixelBufferRef yuv = NULL;
    CVPixelBufferCreate(NULL, 64, 48, kCVPixelFormatType_422YpCbCr8, NULL, &yuv);
    CVPixelBufferLockBaseAddress(yuv, 0);
    unsigned char *b = CVPixelBufferGetBaseAddress(yuv);
    for (size_t i = 0; i < CVPixelBufferGetBytesPerRow(yuv) * 48; i += 4) { b[i] = 90; b[i + 1] = 81; b[i + 2] = 240; b[i + 3] = 81; } // red in 2vuy
    CVPixelBufferUnlockBaseAddress(yuv, 0);
    id<CapturedFrameTest> frame = [[frameClass alloc] initWithImageBuffer:yuv sampleBuffer:nil frameProcessor:processor];
    NSLog(@"yuv processed %d", [frame isFrameProcessed]);
    NSLog(@"yuv image %@ processed %d", describe((CGImageRef)[frame frameRepresentation]), [frame isFrameProcessed]);
    [(id)frame release];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]]] options:nil];
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:NULL];
    AVAssetReaderTrackOutput *output = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] firstObject] outputSettings:nil];
    [reader addOutput:output];
    [reader startReading];
    CMSampleBufferRef sample = [output copyNextSampleBuffer];
    while (sample != NULL && (CMSampleBufferGetNumSamples(sample) == 0 || CMSampleBufferGetFormatDescription(sample) == NULL)) { CFRelease(sample); sample = [output copyNextSampleBuffer]; }
    QTSampleBuffer *qtSample = [[[QTSampleBuffer alloc] initWithCMSampleBuffer:sample connection:nil] autorelease];
    frame = [[frameClass alloc] initWithImageBuffer:NULL sampleBuffer:qtSample frameProcessor:processor];
    NSLog(@"h264 image %@", describe((CGImageRef)[frame frameRepresentation]));
    [(id)frame release];
    CFRelease(sample);
    CVPixelBufferRelease(yuv);
    [processor release];
  }
  return 0;
}
