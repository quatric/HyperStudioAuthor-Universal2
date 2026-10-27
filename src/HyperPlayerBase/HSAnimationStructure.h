#import "HyperPlayerBasePrefix.h"


@interface HSAnimationStructure : NSObject <EXKeyValueCoding, HSAnimationStructure, NSCopying>
{
    NSBezierPath *_path;
    NSMutableArray *_pathKeyFrames;
    NSMutableDictionary *_attributes;
}
- (id)copyWithZone:(NSZone *)aZone;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)isEqual:(id)aEqual;
- (double)timeOfLastAttributesKeyFrame;
- (void)setAttributes:(id)aAttributes;
- (void)addAttribute:(id)aAttribute withName:(id)aName;
- (id)attributes;
- (double)timeOfLastPathKeyFrame;
- (void)checkKeyFramesAreOrdered:(id)aOrdered;
- (void)checkPath:(id)aPath keyFrames:(id)aFrames;
- (id)defaultKeyFramesForPath:(id)aPath;
- (void)setPathKeyFrames:(id)aFrames;
- (void)setPath:(id)aPath;
- (NSPoint)pathPointAtTime:(double)aTime;
- (CGFloat)pathLengthAtTime:(double)aTime;
- (void)removePath;
- (void)setPathAndGenerateKeyFrames:(id)aFrames;
- (BOOL)isOnePointPathAnimation;
- (void)setPath:(id)aPath keyFrames:(id)aFrames;
- (id)pathKeyFrames;
- (id)path;
- (void)clear;
- (double)duration;
- (BOOL)isEmpty;
- (void)dealloc;
- (id)init;
+ (double)defaultPointsPerSecond;
+ (double)minTimeIntervalBetweenKeyFrames;
+ (NSInteger)keyFrameCountForPath:(id)aPath;
+ (CGFloat)pathLengthAtTime:(double)aTime forPath:(id)aPath keyFrames:(id)aFrames;
- (BOOL)hasPath;
- (CGFloat)lengthOfSegment:(NSInteger)aSegment;
- (CGFloat)relativeSpeedAtTime:(double)aTime;
- (void)removeAttributeWithName:(id)aName;
- (NSInteger)segmentIndexAtTime:(double)aTime;
- (void)setTime:(double)aTime ofPathKeyFrameAtIndex:(NSInteger)aIndex;
- (double)timeOfPathKeyFrameAtIndex:(NSInteger)aIndex;
- (void)updatePathKeyFramesTo:(id)aFrames;
- (void)updatePathTo:(id)aPath;
@end

@interface NSBezierPath (HSAnimationStructure)
- (NSUInteger)hyperKeyFrameCount;
- (CGFloat)hyperLengthOfElementsUpToIndex:(NSUInteger)aIndex;
- (CGFloat)hyperLengthAtTime:(double)aTime forKeyFrames:(id)aFrames;
@end

