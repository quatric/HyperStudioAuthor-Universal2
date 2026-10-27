#import "HSQTKit.h"
// Opens an image-sequence movie with HyperPlayerBase's HSMovie and plays it twice: sh tests/run.sh movietest
typedef struct { double location; double length; } TestRange;
@protocol MovieTest
- (void)setImageSequence:(id)aSequence;
- (void)setTimeSequence:(id)aSequence;
- (id)movie;
+ (id)movieWithURL:(id)aURL error:(id *)aError;
- (double)duration;
- (NSSize)size;
- (BOOL)hasVideo;
- (BOOL)hasSound;
- (BOOL)hasAnythingVisible;
- (BOOL)isOpaque;
- (BOOL)isQTVRMovie;
- (BOOL)hasMultiplySamples;
- (BOOL)isMovieSelfContained;
- (NSInteger)framesPerSecond;
- (NSInteger)numberOfFramesForMediaType:(NSUInteger)aType;
- (NSInteger)totalTrackCount;
+ (BOOL)canPlayMovie:(id)aMovie error:(id *)aError;
+ (BOOL)canInitAsVideoWithURL:(id)aURL error:(id *)aError;
+ (BOOL)canInitAsSoundOnlyWithURL:(id)aURL error:(id *)aError;
- (BOOL)checkExistingForCodecs:(id *)aCodecs;
- (void)setPlayCount:(NSUInteger)aCount;
- (void)play;
- (BOOL)isPlaying;
- (double)currentTime;
- (void)setCurrentTime:(double)aTime;
- (void)setPlayRange:(TestRange)aRange;
- (TestRange)playRange;
- (id)currentFrameImage;
@end
static NSImage *image(NSColor *color) {
  NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(32, 24)] autorelease];
  [image lockFocus]; [color set]; NSRectFill(NSMakeRect(0, 0, 32, 24)); [image unlockFocus];
  return image;
}
static int ends, onces;
int main(int argc, char **argv) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    id tool = [NSClassFromString(@"HSMovieFromImageSequenceTool") new];
    [tool setImageSequence:@[image([NSColor redColor]), image([NSColor greenColor]), image([NSColor blueColor])]];
    [tool setTimeSequence:@[@60, @60]];
    QTMovie *m = [tool movie];
    [m updateMovieFile];
    NSURL *url = [[m movieAttributes] objectForKey:QTMovieURLAttribute];
    Class HSMovie = NSClassFromString(@"HSMovie");
    NSError *error = nil;
    id movie = [HSMovie movieWithURL:url error:&error];
    NSLog(@"movie %@ duration %.3f size %@ tracks %ld video %d sound %d visible %d opaque %d qtvr %d multi %d self %d fps %ld frames %ld",
      movie ? @"ok" : error, [movie duration], NSStringFromSize([movie size]), (long)[movie totalTrackCount], [movie hasVideo], [movie hasSound], [movie hasAnythingVisible],
      [movie isOpaque], [movie isQTVRMovie], [movie hasMultiplySamples], [movie isMovieSelfContained], (long)[movie framesPerSecond], (long)[movie numberOfFramesForMediaType:'vide']);
    NSLog(@"canPlay %d asVideo %d asSound %d codecs %d", [HSMovie canPlayMovie:[movie QTMovie] error:NULL], [HSMovie canInitAsVideoWithURL:url error:NULL],
      [HSMovie canInitAsSoundOnlyWithURL:url error:NULL], [movie checkExistingForCodecs:NULL]);
    [movie setCurrentTime:0.15];
    [movie currentFrameImage];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    NSLog(@"seek 0.15 -> %.3f frame image %@", [movie currentTime], [movie currentFrameImage] ? @"ok" : @"nil");
    [[NSNotificationCenter defaultCenter] addObserverForName:@"HSMovieDidEndNotification" object:movie queue:nil usingBlock:^(NSNotification *n) { ends++; }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"HSMovieDidPlayOnceNotification" object:movie queue:nil usingBlock:^(NSNotification *n) { onces++; }];
    [movie setPlayCount:2];
    [movie setCurrentTime:0];
    NSDate *start = [NSDate date];
    [movie play];
    while ([[NSDate date] timeIntervalSinceDate:start] < 3 && ends == 0)
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.02]];
    NSLog(@"play x2: %.2f s (expect ~0.5) once %d end %d playing %d", [[NSDate date] timeIntervalSinceDate:start], onces, ends, [movie isPlaying]);
    TestRange range = { 0.1, 5 };
    [movie setPlayRange:range];
    range = [movie playRange];
    NSLog(@"range %.3f + %.3f (expect 0.100 + 0.150)", range.location, range.length);
    [tool release];
  }
  return 0;
}
