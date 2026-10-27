#import "HSSystem.h"
// Singleton describing the system: OS version checks (by AppKit version),
// QuickTime version, and whether Core Image runs on the GPU.

static HSSystem *HSSystemSharedSystem = nil;
static BOOL HSSystemInitialized = NO;

@implementation HSSystem

+ (id)sharedSystem
{
    return [HSSystem new];
}

+ (id)allocWithZone:(NSZone *)aZone
{
    if (!HSSystemSharedSystem)
        HSSystemSharedSystem = [super allocWithZone:NULL];
    return HSSystemSharedSystem;
}

// The Author has no OpenGL back end and isn't sandboxed; callers written
// against the older sources take their plain paths.
- (BOOL)isOpenGLEnabled
{
    return NO;
}

- (BOOL)isSandboxed
{
    return NO;
}

// Runs the bundled CoreImageAccelerated composition once and reads its
// output.
- (BOOL)isCoreImageAccelerated
{
    static signed char accelerated = -1;
    if (accelerated == -1) {
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"CoreImageAccelerated" ofType:@"qtz"];
        if (path) {
            accelerated = 0;
            NSOpenGLPixelFormatAttribute attributes[] = {NSOpenGLPFAAccelerated, 0};
            NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
            if (format) {
                NSOpenGLContext *context = [[[NSOpenGLContext alloc] initWithFormat:format shareContext:nil] autorelease];
                if (context) {
                    QCRenderer *renderer = [[[QCRenderer alloc] initWithOpenGLContext:context pixelFormat:format file:path] autorelease];
                    if ([renderer renderAtTime:0 arguments:nil])
                        accelerated = [[renderer valueForOutputKey:@"CoreImageAccelerated"] boolValue] != NO;
                }
            }
        }
    }
    return accelerated != 0;
}

- (NSInteger)quickTimeVersion
{
    // QuickTime 7 no longer exists; the port plays and captures through
    // AVFoundation (HSQTKit), so report the last QuickTime release.
    return 0x07800000;
}

- (BOOL)isQTKitCapturingAvailable
{
    return [self quickTimeVersion] > 0x720ffff;
}

- (BOOL)isJaguarOrGreater
{
    return floor(NSAppKitVersionNumber) > 620.0;
}

- (BOOL)isPantherOrGreater
{
    return floor(NSAppKitVersionNumber) > 663.6;
}

- (BOOL)isTigerOrGreater
{
    return floor(NSAppKitVersionNumber) > 743.24;
}

- (BOOL)isLeopardOrGreater
{
    return floor(NSAppKitVersionNumber) > 824.0;
}

- (BOOL)isSnowLeopardOrGreater
{
    return floor(NSAppKitVersionNumber) >= 1038.0;
}

- (BOOL)isLionOrGreater
{
    return floor(NSAppKitVersionNumber) > 1038.0;
}

- (BOOL)isMountainLionOrGreater
{
    return floor(NSAppKitVersionNumber) > 1162.0;
}

- (id)init
{
    if (!HSSystemInitialized) {
        self = [super init];
        HSSystemInitialized = YES;
    }
    return self;
}

@end
