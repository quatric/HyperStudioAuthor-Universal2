#import "HSQTKit.h"
// Plays a movie through HyperPlayerBase's pixel buffer renderer: sh tests/run.sh renderertest <movie>
@protocol RendererTest
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage;
- (CGImageRef)currentFrameImage;
- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3;
@end
static int sUpdates;
@interface Observer : NSObject @end
@implementation Observer
- (void)didUpdate:(NSNotification *)n { sUpdates++; }
@end
static void spin(double seconds) { [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]]; }
static NSString *pixel(CGImageRef image) {
  unsigned char p[4] = {0};
  CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
  CGContextRef c = CGBitmapContextCreate(p, 1, 1, 8, 4, cs, kCGImageAlphaPremultipliedLast);
  CGContextDrawImage(c, CGRectMake(0, 0, 1, 1), image);
  CGContextRelease(c); CGColorSpaceRelease(cs);
  return [NSString stringWithFormat:@"%d,%d,%d,%d", p[0], p[1], p[2], p[3]];
}
int main(int argc, char **argv) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    NSError *e = nil;
    QTMovie *movie = [QTMovie movieWithFile:[NSString stringWithUTF8String:argv[1]] error:&e];
    Observer *o = [[Observer new] autorelease];
    [[NSNotificationCenter defaultCenter] addObserver:o selector:@selector(didUpdate:) name:@"HSMovieRendererDidUpdateFrameImageNotification" object:nil];
    id<RendererTest> r = [[NSClassFromString(@"HSMoviePixelBufferRenderer") alloc] initWithQTMovie:movie storage:nil];
    NSLog(@"renderer %@", r);
    CGImageRef image = NULL;
    for (int i = 0; i < 100 && image == NULL; i++) { spin(0.02); image = [r currentFrameImage]; }
    NSLog(@"first frame %zux%zu %@ updates %d", image ? CGImageGetWidth(image) : 0, image ? CGImageGetHeight(image) : 0, image ? pixel(image) : @"-", sUpdates);
    int before = sUpdates;
    [movie setCurrentTime:QTMakeTime(1500, 1000)];
    spin(0.5);
    image = [r currentFrameImage];
    NSLog(@"after seek updates +%d frame %@", sUpdates - before, image ? pixel(image) : @"-");
    before = sUpdates;
    [movie setCurrentTime:QTZeroTime];
    [movie play];
    spin(0.6);
    [movie stop];
    NSLog(@"while playing updates +%d frame %@", sUpdates - before, (image = [r currentFrameImage]) ? pixel(image) : @"-");
    NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:40 pixelsHigh:30 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0] autorelease];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    [r drawCurrentFrameInRect:NSMakeRect(0, 0, 40, 30) fromRelativeRect:NSMakeRect(0, 0, 1, 1) withTransparentColor:[NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:1] hueTolerance:0.1 chromaTolerance:0.3 lightnessTolerance:0.3];
    [NSGraphicsContext restoreGraphicsState];
    NSLog(@"keyed draw pixel %@", [rep colorAtX:20 y:15]);
    [(id)r release];
    NSLog(@"released");
  }
  return 0;
}
