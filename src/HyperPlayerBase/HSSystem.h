#import "HyperPlayerBasePrefix.h"


@interface HSSystem : NSObject
{
}
+ (id)sharedSystem;
+ (id)allocWithZone:(NSZone *)aZone;
- (BOOL)isOpenGLEnabled;
- (BOOL)isSandboxed;
- (BOOL)isCoreImageAccelerated;
- (NSInteger)quickTimeVersion;
- (BOOL)isQTKitCapturingAvailable;
- (BOOL)isJaguarOrGreater;
- (BOOL)isPantherOrGreater;
- (BOOL)isTigerOrGreater;
- (BOOL)isLeopardOrGreater;
- (BOOL)isSnowLeopardOrGreater;
- (BOOL)isLionOrGreater;
- (BOOL)isMountainLionOrGreater;
- (id)init;
@end

