#import "HSQTKit.h"
// Converts a movie with HyperPlayerBase's movie helper and tags a copy with artwork: sh tests/run.sh moviehelpertest <movie> <dir>
@protocol MovieHelperTest
+ (NSInteger)convertMovie:(id)aMovie frameSize:(NSSize)aSize ofType:(NSInteger)aType toFile:(id)aFile progressCallback:(void *)aCallback sender:(id)aSender;
+ (NSInteger)addArtworkImage:(id)aImage inMovie:(id)aMovie ofType:(NSInteger)aType;
@end
static int sCalls;
static short progress(void *aMovie, short aMessage, short aOperation, int aPercentDone, id aSender) { sCalls++; return 0; }
int main(int argc, char **argv) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    NSString *dir = [NSString stringWithUTF8String:argv[2]];
    Class helper = NSClassFromString(@"HSQuickTimeMovieHelper");
    QTMovie *movie = [QTMovie movieWithFile:[NSString stringWithUTF8String:argv[1]] error:NULL];
    NSString *out = [dir stringByAppendingPathComponent:@"out.m4v"];
    NSInteger error = [helper convertMovie:movie frameSize:NSMakeSize(80, 60) ofType:'M4VH' toFile:out progressCallback:(void *)progress sender:nil];
    AVURLAsset *result = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:out] options:nil];
    AVAssetTrack *track = [[result tracksWithMediaType:AVMediaTypeVideo] firstObject];
    NSLog(@"convert %ld size %@ duration %.2f progress calls %d", (long)error, NSStringFromSize([track naturalSize]), CMTimeGetSeconds([result duration]), sCalls);
    NSString *copy = [dir stringByAppendingPathComponent:@"copy.mov"];
    [[NSFileManager defaultManager] removeItemAtPath:copy error:NULL];
    [[NSFileManager defaultManager] copyItemAtPath:[NSString stringWithUTF8String:argv[1]] toPath:copy error:NULL];
    QTMovie *tagged = [QTMovie movieWithFile:copy error:NULL];
    [tagged setAttribute:@YES forKey:QTMovieEditableAttribute];
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(8, 8)] autorelease];
    [image lockFocus]; [[NSColor greenColor] set]; NSRectFill(NSMakeRect(0, 0, 8, 8)); [image unlockFocus];
    error = [helper addArtworkImage:image inMovie:tagged ofType:'M4V '];
    AVURLAsset *reread = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:copy] options:nil];
    NSArray *art = [AVMetadataItem metadataItemsFromArray:[reread metadataForFormat:AVMetadataFormatQuickTimeMetadata] withKey:AVMetadataQuickTimeMetadataKeyArtwork keySpace:AVMetadataKeySpaceQuickTimeMetadata];
    NSLog(@"artwork %ld items %lu bytes %lu", (long)error, (unsigned long)[art count], (unsigned long)[[[art firstObject] dataValue] length]);
  }
  return 0;
}
