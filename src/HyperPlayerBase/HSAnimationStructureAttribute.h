#import "HyperPlayerBasePrefix.h"


@interface HSAnimationStructureAttribute : NSObject <EXKeyValueCoding, NSCoding, NSCopying>
{
    int _type;
    NSMutableArray *_keyFrames;
    NSMutableArray *_values;
}
- (id)copyWithZone:(NSZone *)aZone;
- (void)decodeSizeValuesWithCoder:(id)aCoder;
- (void)encodeSizeValuesWithCoder:(id)aCoder;
- (void)encodeWithCoder:(id)aCoder;
- (id)initWithCoder:(id)aCoder;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (double)timeOfLastKeyFrame;
- (BOOL)interpolatedBoolValueForValue1:(BOOL)aValue1 value2:(BOOL)aValue2 atPercents:(double)aPercents;
- (id)interpolatedColorForColor1:(id)aColor1 color2:(id)aColor2 atPercents:(double)aPercents;
- (CGFloat)interpolatedFloatValueForValue1:(CGFloat)aValue1 value2:(CGFloat)aValue2 atPercents:(double)aPercents;
- (NSInteger)interpolatedIntValueForValue1:(NSInteger)aValue1 value2:(NSInteger)aValue2 atPercents:(double)aPercents;
- (id)interpolatedValueForValue1:(id)aValue1 value2:(id)aValue2 atPercents:(double)aPercents;
- (void)setValues:(id)aValues;
- (void)setKeyFrames:(id)aFrames;
- (void)setType:(NSInteger)aType;
- (void)checkKeyFrames:(id)aFrames values:(id)aValues;
- (void)setValue:(id)aValue atTime:(double)aTime;
- (id)valueAtTime:(double)aTime;
- (void)deleteKeyFrameAtIndex:(NSInteger)aIndex;
- (NSInteger)insertKeyFrameAtTime:(double)aTime withValue:(id)aValue;
- (NSInteger)keyFrameIndexAtTime:(double)aTime;
- (void)setKeyFrames:(id)aFrames values:(id)aValues;
- (id)values;
- (id)keyFrames;
- (NSInteger)type;
- (void)dealloc;
- (id)initWithType:(NSInteger)aType;
- (id)init;
- (void)setValue:(id)aValue forKeyFrameAtIndex:(NSInteger)aIndex;
@end

@interface NSArray (HSAnimationKeyFrames)
- (double)intervalBetweenKeyFrameAtIndex:(NSUInteger)aIndex andTimeInterval:(double)aInterval;
- (NSUInteger)indexOfMaxKeyFrameLessThanTimeInterval:(double)aInterval;
@end

