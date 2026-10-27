#import "HSQTKit.h"
// Draws an image-sequence movie through HyperPlayerBase's OpenGL movie renderer: sh tests/run.sh glrenderertest
@protocol GLRendererTest
- (id)initWithQTMovie:(id)aMovie storage:(id)aStorage;
- (CGImageRef)currentFrameImage;
- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2;
- (void)drawCurrentFrameInRect:(NSRect)aRect fromRelativeRect:(NSRect)aRect2 withTransparentColor:(id)aColor hueTolerance:(double)aTolerance chromaTolerance:(double)aTolerance2 lightnessTolerance:(double)aTolerance3;
- (void)setImageSequence:(id)aSequence;
- (id)movie;
@end
static void spin(double seconds) { [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:seconds]]; }
// Red on the left, blue on the right.
static NSImage *frame(void) {
  NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(64, 48)] autorelease];
  [image lockFocus];
  [[NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:1] set]; NSRectFill(NSMakeRect(0, 0, 32, 48));
  [[NSColor colorWithSRGBRed:0 green:0 blue:1 alpha:1] set]; NSRectFill(NSMakeRect(32, 0, 32, 48));
  [image unlockFocus];
  return image;
}
static NSString *at(NSBitmapImageRep *rep, int x, int y) {
  NSColor *c = [[rep colorAtX:x y:y] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
  return [NSString stringWithFormat:@"%.2f,%.2f,%.2f,%.2f", [c redComponent], [c greenComponent], [c blueComponent], [c alphaComponent]];
}
static NSBitmapImageRep *draw(id<GLRendererTest> r, NSRect source, NSColor *key) {
  NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:64 pixelsHigh:48 bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0] autorelease];
  [NSGraphicsContext saveGraphicsState];
  [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
  if (key)
    [r drawCurrentFrameInRect:NSMakeRect(0, 0, 64, 48) fromRelativeRect:source withTransparentColor:key hueTolerance:0.1 chromaTolerance:0.3 lightnessTolerance:0.3];
  else
    [r drawCurrentFrameInRect:NSMakeRect(0, 0, 64, 48) fromRelativeRect:source];
  [NSGraphicsContext restoreGraphicsState];
  return rep;
}
int main(int argc, char **argv) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    id tool = [NSClassFromString(@"HSMovieFromImageSequenceTool") new];
    [tool setImageSequence:@[frame()]];
    QTMovie *movie = [tool movie];
    [movie updateMovieFile];
    id<GLRendererTest> r = [[NSClassFromString(@"HSMovieOpenGLRenderer") alloc] initWithQTMovie:movie storage:nil];
    NSLog(@"renderer %@", r);
    if (r == nil)
      return 1;
    CGImageRef image = NULL;
    for (int i = 0; i < 100 && image == NULL; i++) { spin(0.02); image = [r currentFrameImage]; }
    NSLog(@"frame image %zux%zu", image ? CGImageGetWidth(image) : 0, image ? CGImageGetHeight(image) : 0);
    if (image) {
      NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithCGImage:image] autorelease];
      NSLog(@"frame image left %@ right %@ (expect red, blue)", at(rep, 8, 24), at(rep, 56, 24));
    }
    NSBitmapImageRep *rep = draw(r, NSMakeRect(0, 0, 1, 1), nil);
    NSLog(@"draw left %@ right %@ (expect red, blue)", at(rep, 8, 24), at(rep, 56, 24));
    rep = draw(r, NSMakeRect(0.5, 0, 0.5, 1), nil);
    NSLog(@"right half left %@ right %@ (expect blue, blue)", at(rep, 8, 24), at(rep, 56, 24));
    rep = draw(r, NSMakeRect(0, 0, 1, 1), [NSColor colorWithSRGBRed:1 green:0 blue:0 alpha:1]);
    NSLog(@"keyed red left %@ right %@ (expect clear, blue)", at(rep, 8, 24), at(rep, 56, 24));
    [(id)r release];
    [tool release];
    NSLog(@"released");
  }
  return 0;
}
