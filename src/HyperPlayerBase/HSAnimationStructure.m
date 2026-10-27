#import "HSAnimationStructure.h"
#import "HSAnimationStructureAttribute.h"
#import "NSBezierPath+HSBinarySerialization.h"

@implementation HSAnimationStructure

- (id)copyWithZone:(NSZone *)aZone
{
    HSAnimationStructure *copy = [[[self class] allocWithZone:aZone] init];
    [copy setPath:[self path]];
    [copy setPathKeyFrames:[self pathKeyFrames]];
    [copy setAttributes:[self attributes]];
    return copy;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSMutableArray *keys = [NSMutableArray array];
    [keys addObject:[@"path" extraKeyForMultiRepresentations]];
    [keys addObject:@"pathKeyFrames"];
    [keys addObject:[@"attributes" extraKeyForCollection]];
    return keys;
}

- (BOOL)isEqual:(id)aEqual
{
    return [[self extraDictionaryRepresentation] isEqualToDictionary:[aEqual extraDictionaryRepresentation]];
}

- (void)setAttributes:(id)aAttributes
{
    if (_attributes == aAttributes)
        return;
    [_attributes removeAllObjects];
    NSEnumerator *enumerator = [[aAttributes allKeys] objectEnumerator];
    id key;
    while ((key = [enumerator nextObject]) != nil) {
        id attribute = [[aAttributes objectForKey:key] copyWithZone:NULL];
        [_attributes setObject:attribute forKey:key];
        [attribute release];
    }
}

- (void)addAttribute:(id)aAttribute withName:(id)aName
{
    [_attributes setObject:aAttribute forKey:aName];
}

- (id)attributes
{
    return _attributes;
}

- (double)timeOfLastPathKeyFrame
{
    if ([self path] == nil)
        return 0.0;
    return [[_pathKeyFrames lastObject] doubleValue];
}

- (void)checkKeyFramesAreOrdered:(id)aOrdered
{
}

- (void)checkPath:(id)aPath keyFrames:(id)aFrames
{
}

- (id)defaultKeyFramesForPath:(id)aPath
{
    // One key frame per path element, spaced by element length at 60 points
    // per second but never closer than the minimum interval.
    NSUInteger count = [aPath hyperKeyFrameCount];
    NSMutableArray *keyFrames = [[NSMutableArray alloc] initWithCapacity:count];
    double minInterval = kAnimationMinTimeIntervalBetweenKeyFrames;
    double time = 0.0;
    for (NSUInteger i = 0; i < count; i++) {
        double interval = [aPath hyperLengthOfElementAtIndex:i] / 60.0;
        double magnitude = MAX(interval != 0.0 ? fabs(interval) : 1.0, minInterval != 0.0 ? fabs(minInterval) : 1.0);
        if (interval < minInterval - magnitude * 1e-05)
            interval = minInterval;
        time += interval;
        [keyFrames addObject:[NSNumber numberWithDouble:time]];
    }
    return [keyFrames autorelease];
}

- (void)setPathKeyFrames:(id)aFrames
{
    if (_pathKeyFrames != aFrames) {
        [_pathKeyFrames removeAllObjects];
        [_pathKeyFrames addObjectsFromArray:aFrames];
    }
}

- (void)setPath:(id)aPath
{
    if (_path != aPath) {
        [_path release];
        _path = [aPath copy];
    }
}

- (NSPoint)pathPointAtTime:(double)aTime
{
    if ([self path] == nil)
        return NSZeroPoint;
    return [_path hyperPointAtLength:(float)[self pathLengthAtTime:aTime]];
}

- (CGFloat)pathLengthAtTime:(double)aTime
{
    if ([self path] == nil)
        return 0.0f;
    return (float)[_path hyperLengthAtTime:aTime forKeyFrames:_pathKeyFrames];
}

- (void)removePath
{
    [self setPathKeyFrames:nil];
    [self setPath:nil];
}

- (void)setPathAndGenerateKeyFrames:(id)aFrames
{
    [self setPath:aFrames keyFrames:[self defaultKeyFramesForPath:aFrames]];
}

- (BOOL)isOnePointPathAnimation
{
    return [[self pathKeyFrames] count] == 1;
}

- (void)setPath:(id)aPath keyFrames:(id)aFrames
{
    [self checkPath:aPath keyFrames:aFrames];
    [self setPath:aPath];
    [self setPathKeyFrames:aFrames];
}

- (id)pathKeyFrames
{
    return _pathKeyFrames;
}

- (id)path
{
    return _path;
}

- (void)clear
{
    [self removePath];
    [_attributes removeAllObjects];
}

- (double)duration
{
    double pathTime = [self timeOfLastPathKeyFrame];
    double attributesTime = [self timeOfLastAttributesKeyFrame];
    double magnitude = MAX(pathTime != 0.0 ? fabs(pathTime) : 1.0, attributesTime != 0.0 ? fabs(attributesTime) : 1.0);
    if (pathTime <= attributesTime + magnitude * 1e-05)
        return attributesTime;
    return pathTime;
}

- (BOOL)isEmpty
{
    return [self path] == nil && [_attributes count] == 0;
}

- (void)dealloc
{
    [_attributes release];
    [_pathKeyFrames release];
    [_path release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _pathKeyFrames = [NSMutableArray new];
        _attributes = [NSMutableDictionary new];
    }
    return self;
}

@end

@implementation NSBezierPath (HSAnimationStructure)

- (NSUInteger)hyperKeyFrameCount
{
    NSUInteger count = [self elementCount];
    return [self isHyperLastContourClosed] ? count - 2 : count;
}

- (CGFloat)hyperLengthOfElementsUpToIndex:(NSUInteger)aIndex
{
    float length = 0.0f;
    NSUInteger i = 0;
    do {
        length += (float)[self hyperLengthOfElementAtIndex:i];
        i++;
    } while (i <= aIndex);
    return length;
}

- (CGFloat)hyperLengthAtTime:(double)aTime forKeyFrames:(id)aFrames
{
    NSUInteger index = [aFrames indexOfMaxKeyFrameLessThanTimeInterval:aTime];
    float lengthSoFar = (float)[self hyperLengthOfElementsUpToIndex:index];
    float fraction = (float)[aFrames intervalBetweenKeyFrameAtIndex:index andTimeInterval:aTime];
    float partial = 0.0f;
    if (index < [self hyperKeyFrameCount] - 1)
        partial = fraction * (float)[self hyperLengthOfElementAtIndex:index + 1];
    return lengthSoFar + partial;
}

@end
