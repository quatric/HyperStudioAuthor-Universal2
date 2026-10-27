#import "HSAnimationStructureAttribute.h"

// Relative tolerance used for key frame time comparisons: 1e-5 of the
// larger magnitude, with zero treated as 1.
static double HSKeyFrameTolerance(double a, double b)
{
    double ma = (a != 0.0) ? fabs(a) : 1.0;
    double mb = (b != 0.0) ? fabs(b) : 1.0;
    return (mb <= ma ? ma : mb) * 1e-05;
}

@implementation HSAnimationStructureAttribute

- (id)copyWithZone:(NSZone *)aZone
{
    HSAnimationStructureAttribute *copy = [[[self class] allocWithZone:aZone] initWithType:_type];
    [copy setKeyFrames:[self keyFrames]];
    [copy setValues:[self values]];
    return copy;
}

- (void)decodeSizeValuesWithCoder:(id)aCoder
{
    NSArray *strings = [aCoder decodeObjectForKey:@"values"];
    NSMutableArray *values = [NSMutableArray new];
    NSEnumerator *e = [strings objectEnumerator];
    NSString *string;
    while ((string = [e nextObject]) != nil)
        [values addObject:[NSValue valueWithSize:NSSizeFromString(string)]];
    [self setValues:values];
    [values release];
}

- (void)encodeSizeValuesWithCoder:(id)aCoder
{
    NSMutableArray *strings = [NSMutableArray new];
    NSEnumerator *e = [_values objectEnumerator];
    NSValue *value;
    while ((value = [e nextObject]) != nil)
        [strings addObject:NSStringFromSize([value sizeValue])];
    [aCoder encodeObject:strings forKey:@"values"];
    [strings release];
}

// Size values (type 3) are stored as strings.
- (void)encodeWithCoder:(id)aCoder
{
    [aCoder encodeInt:_type forKey:@"type"];
    [aCoder encodeObject:_keyFrames forKey:@"keyFrames"];
    if (_type == 3)
        [self encodeSizeValuesWithCoder:aCoder];
    else
        [aCoder encodeObject:_values forKey:@"values"];
}

- (id)initWithCoder:(id)aCoder
{
    self = [self init];
    if (self != nil) {
        _type = [aCoder decodeIntForKey:@"type"];
        [self setKeyFrames:[aCoder decodeObjectForKey:@"keyFrames"]];
        if (_type == 3)
            [self decodeSizeValuesWithCoder:aCoder];
        else
            [self setValues:[aCoder decodeObjectForKey:@"values"]];
    }
    return self;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray array];
    [keys addObject:@"type"];
    [keys addObject:@"keyFrames"];
    [keys addObject:@"values"];
    return keys;
}

- (double)timeOfLastKeyFrame
{
    if ([_keyFrames count] == 0)
        return 0.0;
    return [[_keyFrames lastObject] doubleValue];
}

- (BOOL)interpolatedBoolValueForValue1:(BOOL)aValue1 value2:(BOOL)aValue2 atPercents:(double)aPercents
{
    if (1.0 - HSKeyFrameTolerance(aPercents, 1.0) <= aPercents)
        return aValue2;
    return aValue1;
}

// Colors that cannot be converted to calibrated RGB keep the first color.
- (id)interpolatedColorForColor1:(id)aColor1 color2:(id)aColor2 atPercents:(double)aPercents
{
    NSColor *color1 = [aColor1 colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    NSColor *color2 = [aColor2 colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    if (color1 == nil || color2 == nil)
        return aColor1;
    float red1 = [color1 redComponent], green1 = [color1 greenComponent], blue1 = [color1 blueComponent];
    float red2 = [color2 redComponent], green2 = [color2 greenComponent], blue2 = [color2 blueComponent];
    float red = [self interpolatedFloatValueForValue1:red1 value2:red2 atPercents:aPercents];
    float green = [self interpolatedFloatValueForValue1:green1 value2:green2 atPercents:aPercents];
    float blue = [self interpolatedFloatValueForValue1:blue1 value2:blue2 atPercents:aPercents];
    return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0];
}

- (CGFloat)interpolatedFloatValueForValue1:(CGFloat)aValue1 value2:(CGFloat)aValue2 atPercents:(double)aPercents
{
    float value1 = (float)aValue1;
    float value2 = (float)aValue2;
    return (float)((double)value1 + (double)(value2 - value1) * aPercents);
}

- (NSInteger)interpolatedIntValueForValue1:(NSInteger)aValue1 value2:(NSInteger)aValue2 atPercents:(double)aPercents
{
    int value1 = (int)aValue1;
    int value2 = (int)aValue2;
    return (int)lround((double)value1 + (double)(value2 - value1) * aPercents);
}

// Types: 1 int, 2 float, 3 size, 4 color, 5 bool.
- (id)interpolatedValueForValue1:(id)aValue1 value2:(id)aValue2 atPercents:(double)aPercents
{
    switch (_type) {
    case 1:
        return [NSNumber numberWithInt:(int)[self interpolatedIntValueForValue1:[aValue1 intValue] value2:[aValue2 intValue] atPercents:aPercents]];
    case 2:
        return [NSNumber numberWithFloat:(float)[self interpolatedFloatValueForValue1:[aValue1 floatValue] value2:[aValue2 floatValue] atPercents:aPercents]];
    case 3: {
        NSSize size1 = [aValue1 sizeValue];
        NSSize size2 = [aValue2 sizeValue];
        NSSize size;
        size.width = (float)[self interpolatedFloatValueForValue1:size1.width value2:size2.width atPercents:aPercents];
        size.height = (float)[self interpolatedFloatValueForValue1:size1.height value2:size2.height atPercents:aPercents];
        return [NSValue valueWithSize:size];
    }
    case 4:
        return [self interpolatedColorForColor1:aValue1 color2:aValue2 atPercents:aPercents];
    case 5:
        return [NSNumber numberWithBool:[self interpolatedBoolValueForValue1:[aValue1 boolValue] value2:[aValue2 boolValue] atPercents:aPercents]];
    default:
        return nil;
    }
}

- (void)setValues:(id)aValues
{
    if (_values != aValues) {
        [_values removeAllObjects];
        [_values addObjectsFromArray:aValues];
    }
}

- (void)setKeyFrames:(id)aFrames
{
    if (_keyFrames != aFrames) {
        [_keyFrames removeAllObjects];
        [_keyFrames addObjectsFromArray:aFrames];
    }
}

- (void)setType:(NSInteger)aType
{
    _type = (int)aType;
}

- (void)checkKeyFrames:(id)aFrames values:(id)aValues
{
}

- (void)setValue:(id)aValue atTime:(double)aTime
{
    NSInteger index = [self keyFrameIndexAtTime:aTime];
    if (index == -1)
        [self insertKeyFrameAtTime:aTime withValue:aValue];
    else
        [_values replaceObjectAtIndex:index withObject:aValue];
}

- (id)valueAtTime:(double)aTime
{
    NSUInteger count = [_keyFrames count];
    if (count < 2) {
        if (count != 1)
            return nil;
        return [_values objectAtIndex:0];
    }
    NSUInteger index = [_keyFrames indexOfMaxKeyFrameLessThanTimeInterval:aTime];
    if (index < count - 1) {
        double percents = [_keyFrames intervalBetweenKeyFrameAtIndex:index andTimeInterval:aTime];
        return [self interpolatedValueForValue1:[_values objectAtIndex:index] value2:[_values objectAtIndex:index + 1] atPercents:percents];
    }
    return [_values objectAtIndex:index];
}

- (void)deleteKeyFrameAtIndex:(NSInteger)aIndex
{
    [_keyFrames removeObjectAtIndex:aIndex];
    [_values removeObjectAtIndex:aIndex];
}

- (NSInteger)insertKeyFrameAtTime:(double)aTime withValue:(id)aValue
{
    int index = 0;
    while (index < (int)[_keyFrames count]) {
        double time = [[_keyFrames objectAtIndex:index] doubleValue];
        if (aTime < time - HSKeyFrameTolerance(aTime, time))
            break;
        index++;
    }
    [_keyFrames insertObject:[NSNumber numberWithDouble:aTime] atIndex:index];
    [_values insertObject:aValue atIndex:index];
    return index;
}

// Key frames within 5 ms of the time match.
- (NSInteger)keyFrameIndexAtTime:(double)aTime
{
    double high = aTime + 0.005;
    double low = aTime - 0.005;
    int index;
    for (index = 0; index < (int)[_keyFrames count]; index++) {
        double time = [[_keyFrames objectAtIndex:index] doubleValue];
        if (low <= time + HSKeyFrameTolerance(low, time) && time <= high + HSKeyFrameTolerance(time, high))
            return index;
    }
    return -1;
}

- (void)setKeyFrames:(id)aFrames values:(id)aValues
{
    [self checkKeyFrames:aFrames values:aValues];
    [self setKeyFrames:aFrames];
    [self setValues:aValues];
}

- (id)values
{
    return _values;
}

- (id)keyFrames
{
    return _keyFrames;
}

- (NSInteger)type
{
    return _type;
}

- (void)dealloc
{
    [_values release];
    [_keyFrames release];
    [super dealloc];
}

- (id)initWithType:(NSInteger)aType
{
    self = [self init];
    if (self != nil)
        _type = (int)aType;
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _type = 0;
        _keyFrames = [NSMutableArray new];
        _values = [NSMutableArray new];
    }
    return self;
}

@end

@implementation NSArray (HSAnimationKeyFrames)

- (double)intervalBetweenKeyFrameAtIndex:(NSUInteger)aIndex andTimeInterval:(double)aInterval
{
    if ([self count] < 2)
        return 0.0;
    if ([self count] - 2 < aIndex)
        aIndex = [self count] - 2;
    double start = [[self objectAtIndex:aIndex] doubleValue];
    double end = [[self objectAtIndex:aIndex + 1] doubleValue];
    return (aInterval - start) / (end - start);
}

// The time is clamped to the key frame range first; past the last segment
// the last segment index examined is returned.
- (NSUInteger)indexOfMaxKeyFrameLessThanTimeInterval:(double)aInterval
{
    double first = [[self objectAtIndex:0] doubleValue];
    double last = [[self lastObject] doubleValue];
    double time = first;
    if (first - HSKeyFrameTolerance(aInterval, first) <= aInterval)
        time = aInterval;
    if (time <= last + HSKeyFrameTolerance(time, last))
        last = time;
    time = last;
    int count = (int)[self count];
    int result = 0;
    int index;
    for (index = 0; index < count - 1; index++) {
        double start = [[self objectAtIndex:index] doubleValue];
        double end = [[self objectAtIndex:index + 1] doubleValue];
        if (time >= start - HSKeyFrameTolerance(time, start) && end - HSKeyFrameTolerance(time, end) > time)
            return index;
        result = index;
    }
    return result;
}

@end
