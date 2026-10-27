#import "HyperPlayerBasePrefix.h"


@interface NSShadow (HSExtensions)
+ (CGFloat)hyperShadowDistanceWithShadowOffset:(NSSize)aOffset;
+ (NSSize)hyperShadowOffsetWithShadowDistance:(CGFloat)aDistance currentOffset:(NSSize)aOffset;
+ (NSSize)hyperShadowOffsetWithShadowAngle:(CGFloat)aAngle currentOffset:(NSSize)aOffset;
+ (NSSize)hyperShadowOffsetWithShadowAngle:(CGFloat)aAngle shadowDistance:(CGFloat)aDistance;
+ (CGFloat)hyperShadowAngleWithShadowOffset:(NSSize)aOffset;
+ (CGFloat)hyperNormalizedShadowAngleWithShadowOffset:(NSSize)aOffset;
+ (id)hyperShadowWithDefaultSettingsForTextObject;
- (NSSize)hyperShadowOffsetForDistance:(CGFloat)aDistance;
- (void)setHyperShadowDistance:(CGFloat)aDistance;
- (CGFloat)hyperShadowDistance;
- (NSSize)hyperShadowOffsetForAngle:(CGFloat)aAngle;
- (void)setHyperShadowAngle:(CGFloat)aAngle;
- (CGFloat)hyperShadowAngle;
@end

