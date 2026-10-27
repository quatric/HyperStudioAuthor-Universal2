#import "HSQTKit.h"
int main(int argc, char **argv) {
  @autoreleasepool {
    NSString *out = [NSString stringWithUTF8String:argv[1]];
    QTMovie *m = [[[QTMovie alloc] init] autorelease];
    for (int i = 0; i < 10; i++) {
      NSImage *img = [[[NSImage alloc] initWithSize:NSMakeSize(160, 120)] autorelease];
      [img lockFocus];
      [[NSColor colorWithCalibratedHue:i/10.0 saturation:1 brightness:1 alpha:1] set];
      NSRectFill(NSMakeRect(0,0,160,120));
      [img unlockFocus];
      [m addImage:img forDuration:QTMakeTime(60, 600) withAttributes:@{QTAddImageCodecType: (i < 5 ? @"jpeg" : @"jpeg"), QTAddImageCodecQuality: @(codecHighQuality)}];
    }
    NSLog(@"built duration %@ size %@ tracks %lu", QTStringFromTime([m duration]), [m attributeForKey:QTMovieNaturalSizeAttribute], (unsigned long)[[m tracks] count]);
    NSError *e = nil;
    BOOL ok = [m writeToFile:out withAttributes:@{QTMovieFlatten: @YES} error:&e];
    NSLog(@"write %d %@", ok, e);
    QTMovie *r = [QTMovie movieWithFile:out error:&e];
    NSLog(@"reopen %@ err %@ duration %@ timescale %@", r, e, QTStringFromTime([r duration]), [r attributeForKey:QTMovieTimeScaleAttribute]);
    NSImage *f = [r frameImageAtTime:QTMakeTime(330, 600)];
    NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithData:[f TIFFRepresentation]] autorelease];
    NSLog(@"frame %@ color %@", NSStringFromSize([f size]), [rep colorAtX:80 y:60]);
    NSLog(@"canInit %d mov types %lu", [QTMovie canInitWithFile:out], (unsigned long)[[QTMovie movieUnfilteredFileTypes] count]);
    QTMovie *part = [r movieWithTimeRange:QTMakeTimeRange(QTMakeTime(120,600), QTMakeTime(240,600)) error:&e];
    NSLog(@"part %@", QTStringFromTime([part duration]));
    NSData *d = [part movieFormatRepresentation];
    QTMovie *fromData = [QTMovie movieWithData:d error:&e];
    NSLog(@"data %lu -> %@", (unsigned long)[d length], QTStringFromTime([fromData duration]));
    [r setCurrentTime:QTMakeTime(300, 600)];
    NSLog(@"current %@", QTStringFromTime([r currentTime]));
    NSLog(@"devices %@", [QTCaptureDevice inputDevices]);
    NSLog(@"opts %@", [[QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsSD480SizeH264Video"] localizedDisplayName]);
  }
  return 0;
}
