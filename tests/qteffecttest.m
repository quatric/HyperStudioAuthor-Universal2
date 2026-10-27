#import "HSQTKit.h"
#import <objc/runtime.h>
// Checks the QuickTime transition and image effects: sh tests/run.sh qteffecttest
@interface NSObject (QTEffectTest)
- (id)initWithEffectFilePath:(id)aPath swappedInputs:(BOOL)aSwapped;
- (id)initWithAtomContainerData:(id)aData;
- (id)atomContainerData;
- (id)createQuartzRendererForSize:(CGSize)aSize;
- (void)setStartImage:(id)aImage;
- (void)setEndImage:(id)aImage;
- (void)renderFrameAtTime:(double)aTime inCoreGraphicsContext:(CGContextRef)aContext;
- (id)initWithName:(id)aName;
- (void)setDefaults;
- (void)setInputImage:(id)aImage;
- (id)outputImage;
+ (id)effectsDescription;
@end
static NSImage *solid(NSColor *color, NSSize size) {
  NSImage *image = [[[NSImage alloc] initWithSize:size] autorelease];
  [image lockFocus]; [color set]; NSRectFill(NSMakeRect(0, 0, size.width, size.height));
  [[NSColor whiteColor] set]; NSRectFill(NSMakeRect(size.width / 4, size.height / 4, size.width / 2, 2)); [image unlockFocus];
  return image;
}
// share of pixels closer to blue (the end image) than to red
static double endShare(CGContextRef ctx) {
  const unsigned char *p = CGBitmapContextGetData(ctx); size_t w = CGBitmapContextGetWidth(ctx), h = CGBitmapContextGetHeight(ctx), rb = CGBitmapContextGetBytesPerRow(ctx), n = 0, total = 0;
  for (size_t y = 0; y < h; y++) for (size_t x = 0; x < w; x++) { const unsigned char *q = p + y * rb + x * 4; if (q[0] == q[2]) continue; total++; if (q[2] > q[0]) n++; }
  return total ? (double)n / total : -1;
}
int main(int argc, char **argv) {
  @autoreleasepool {
    [NSApplication sharedApplication];
    NSString *dir = @"/Volumes/SSD/larsen/HyperStudio5-Universal2/game/Unpack Player.app/Contents/Frameworks/HyperPlayerBase.framework/Versions/A/Resources";
    NSArray *swapped = [NSArray arrayWithContentsOfFile:[dir stringByAppendingPathComponent:@"SwappedTransitions.plist"]];
    Class transition = NSClassFromString(@"HSQTTransitionEffect");
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, 64, 48, 8, 0, cs, kCGImageAlphaPremultipliedLast);
    int bad = 0;
    for (NSString *file in [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[dir stringByAppendingPathComponent:@"Transitions"] error:NULL] sortedArrayUsingSelector:@selector(compare:)]) {
      if (![[file pathExtension] isEqualToString:@"qfx"]) continue;
      NSString *name = [file stringByDeletingPathExtension];
      NSString *path = [[dir stringByAppendingPathComponent:@"Transitions"] stringByAppendingPathComponent:file];
      id effect = [[transition alloc] initWithEffectFilePath:path swappedInputs:[swapped containsObject:name]];
      NSData *data = [effect atomContainerData];
      id copy = [[transition alloc] initWithAtomContainerData:data];
      BOOL roundTrip = [[copy atomContainerData] isEqual:data] && [data length] == [[NSData dataWithContentsOfFile:path] length] + 48;
      id renderer = [effect createQuartzRendererForSize:CGSizeMake(64, 48)];
      [renderer setStartImage:solid([NSColor redColor], NSMakeSize(64, 48))];
      [renderer setEndImage:solid([NSColor blueColor], NSMakeSize(32, 24))];
      double share[3];
      for (int i = 0; i < 3; i++) { CGContextClearRect(ctx, CGRectMake(0, 0, 64, 48)); [renderer renderFrameAtTime:i / 2.0 inCoreGraphicsContext:ctx]; share[i] = endShare(ctx); }
      BOOL ok = roundTrip && share[0] < 0.02 && share[2] > 0.98 && share[1] > 0.02 && share[1] < 0.98;
      if (!ok) bad++;
      printf("%-16s %s roundtrip %d  end share %.2f %.2f %.2f\n", [name UTF8String], ok ? "ok " : "BAD", roundTrip, share[0], share[1], share[2]);
      [renderer release]; [copy release]; [effect release];
    }
    printf("transitions bad: %d\n", bad);
    Class qtEffect = NSClassFromString(@"HSQTEffect");
    // The test's HyperPlayerBase has no Resources, so the shipped plist stands in.
    static NSDictionary *description;
    description = [[NSDictionary alloc] initWithContentsOfFile:[dir stringByAppendingPathComponent:@"English.lproj/QTEffects.plist"]];
    method_setImplementation(class_getClassMethod(qtEffect, @selector(effectsDescription)), imp_implementationWithBlock(^id(id aClass) { return description; }));
    printf("effects description: %s\n", [qtEffect effectsDescription] ? "found" : "missing");
    for (NSString *name in [[[qtEffect effectsDescription] allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
      id effect = [[qtEffect alloc] initWithName:name];
      [effect setDefaults];
      [effect setInputImage:solid([NSColor colorWithCalibratedRed:0.8 green:0.4 blue:0.2 alpha:1], NSMakeSize(40, 30))];
      NSImage *output = [effect outputImage];
      NSBitmapImageRep *rep = [[[NSBitmapImageRep alloc] initWithCGImage:[output CGImageForProposedRect:NULL context:nil hints:nil]] autorelease];
      NSColor *c = [rep colorAtX:5 y:5], *edge = [rep colorAtX:20 y:20];
      NSMutableString *values = [NSMutableString string];
      for (NSString *key in [effect inputKeys]) [values appendFormat:@" %@=%@", [key substringFromIndex:5], [effect valueForKey:key]];
      printf("%-16s %s %.0fx%.0f flat %.2f %.2f %.2f line %.2f %.2f %.2f |%s\n", [name UTF8String], output ? "ok" : "NIL", [output size].width, [output size].height,
        [c redComponent], [c greenComponent], [c blueComponent], [edge redComponent], [edge greenComponent], [edge blueComponent], [values UTF8String]);
      [effect release];
    }
  }
  return 0;
}
