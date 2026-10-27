#import "HSQTKit.h"
// Builds a three-frame movie from images with HyperPlayerBase's image sequence tool: sh tests/run.sh imagesequencetest
@protocol ImageSequenceTest
+ (id)movieWithImageSequence:(id)aSequence timeSequence:(id)aSequence2 frameLength:(long long)aLength error:(id *)aError;
- (id)movieData;
- (void)setImageSequence:(id)aSequence;
- (id)movie;
- (void)setTimeSequence:(id)aSequence;
@end
static NSImage *image(NSColor *color) {
  NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(32, 24)] autorelease];
  [image lockFocus]; [color set]; NSRectFill(NSMakeRect(0, 0, 32, 24)); [image unlockFocus];
  return image;
}
int main(int argc, char **argv) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    NSArray *images = @[image([NSColor redColor]), image([NSColor greenColor]), image([NSColor blueColor])];
    // frames last 300, 600 and the default 30 (of 600)
    id movie = [NSClassFromString(@"HSMovie") movieWithImageSequence:images timeSequence:@[@300, @600] frameLength:30 error:NULL];
    QTMovie *qt = [movie respondsToSelector:@selector(QTMovie)] ? [movie performSelector:@selector(QTMovie)] : nil;
    NSLog(@"movie %@ qt duration %@", movie != nil ? @"ok" : @"nil", qt ? QTStringFromTime([qt duration]) : @"-");
    id tool = [NSClassFromString(@"HSMovieFromImageSequenceTool") new];
    [tool setImageSequence:images];
    QTMovie *m = [tool movie];
    NSURL *url = [[m movieAttributes] objectForKey:QTMovieURLAttribute];
    [m updateMovieFile];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSLog(@"tool duration %.3f s tracks %lu data %lu bytes", CMTimeGetSeconds([asset duration]), (unsigned long)[[asset tracksWithMediaType:AVMediaTypeVideo] count], (unsigned long)[[tool movieData] length]);
    [tool setTimeSequence:@[@300, @600]];
    m = [tool movie];
    [m updateMovieFile];
    asset = [AVURLAsset URLAssetWithURL:[[m movieAttributes] objectForKey:QTMovieURLAttribute] options:nil];
    NSLog(@"timed duration %.3f s (expect 1.550)", CMTimeGetSeconds([asset duration]));
    [tool release];
  }
  return 0;
}
