#import "HSVolumeCurve.h"

@implementation HSVolumeCurve

- (double)convertScalarToDB:(double)aDB
{
    return [self convertRawToDB:[self convertScalarToRaw:aDB]];
}

// Ranges wider than 30 dB use a square-root taper.
- (NSInteger)convertScalarToRaw:(double)aRaw
{
    double minDB = [self minimumDB];
    double maxDB = [self maximumDB];
    NSInteger minRaw = [self minimumRaw];
    double scalar = aRaw < 0.0 ? 0.0 : aRaw;
    if (scalar > 1.0)
        scalar = 1.0;
    NSInteger maxRaw = [self maximumRaw];
    if (maxDB - minDB > 30.0)
        scalar = sqrt(scalar);
    return (NSInteger)round((double)(maxRaw - minRaw) * scalar) + minRaw;
}

- (double)convertDBToScalar:(double)aScalar
{
    return [self convertRawToScalar:[self convertDBToRaw:aScalar]];
}

// The upper clamp compares against the raw span, not maximumRaw (original
// behaviour).
- (double)convertRawToScalar:(NSInteger)aScalar
{
    double minDB = [self minimumDB];
    double maxDB = [self maximumDB];
    NSInteger minRaw = [self minimumRaw];
    NSInteger raw = aScalar < minRaw ? minRaw : aScalar;
    NSInteger span = [self maximumRaw] - minRaw;
    if (raw > span)
        raw = span;
    double scalar = (double)(raw - minRaw) / (double)span;
    if (maxDB - minDB > 30.0)
        scalar = scalar * scalar;
    return scalar;
}

- (double)convertRawToDB:(NSInteger)aDB
{
    NSInteger minRaw = [self minimumRaw];
    NSInteger maxRaw = [self maximumRaw];
    NSInteger raw = aDB < minRaw ? minRaw : aDB;
    if (raw > maxRaw)
        raw = maxRaw;
    NSInteger remaining = raw - minRaw;
    NSUInteger count = [_rawArray count];
    HSRawPoint *rawPoint = nil;
    HSDBPoint *dbPoint = nil;
    double db = 0.0;
    if (count != 0) {
        rawPoint = [_rawArray objectAtIndex:0];
        dbPoint = [_dbArray objectAtIndex:0];
        db = [dbPoint minimum];
    }
    NSUInteger i = 0;
    while (remaining >= 1 && i < count) {
        i++;
        NSInteger span = [rawPoint maximum] - [rawPoint minimum];
        double dbMin = [dbPoint minimum];
        double dbMax = [dbPoint maximum];
        NSInteger step = remaining < span ? remaining : span;
        db += ((dbMax - dbMin) / (double)span) * (double)step;
        if (i >= count)
            break;
        rawPoint = [_rawArray objectAtIndex:i];
        remaining -= step;
        dbPoint = [_dbArray objectAtIndex:i];
    }
    return db;
}

- (NSInteger)convertDBToRaw:(double)aRaw
{
    double minDB = [self minimumDB];
    double maxDB = [self maximumDB];
    double db = aRaw < minDB ? minDB : aRaw;
    if (db > maxDB)
        db = maxDB;
    NSUInteger count = [_rawArray count];
    NSInteger offset = 0;
    NSInteger rawMin = 0, rawMax = 0;
    double dbMin = 0.0, dbMax = 0.0;
    for (NSUInteger i = 0; i < count; i++) {
        HSRawPoint *rawPoint = [_rawArray objectAtIndex:i];
        HSDBPoint *dbPoint = [_dbArray objectAtIndex:i];
        rawMin = [rawPoint minimum];
        rawMax = [rawPoint maximum];
        dbMin = [dbPoint minimum];
        dbMax = [dbPoint maximum];
        if (db <= dbMax)
            break;
        offset += rawMax - rawMin;
    }
    if (count == 0)
        return 0;
    return (NSInteger)round((db - dbMin) / ((dbMax - dbMin) / (double)(rawMax - rawMin))) + offset;
}

// Only the last junction ends up being compared, and it is measured against
// the running end of the previous segments (original behaviour).
- (BOOL)checkForContinuity
{
    NSUInteger count = [_rawArray count];
    HSRawPoint *rawPoint = nil;
    HSDBPoint *dbPoint = nil;
    if (count != 0) {
        rawPoint = [_rawArray objectAtIndex:0];
        dbPoint = [_dbArray objectAtIndex:0];
    }
    NSInteger rawEnd = [rawPoint minimum];
    double dbEnd = [dbPoint minimum];
    if (count < 2)
        return YES;
    NSInteger prevRawEnd = 0, rawMin = 0;
    double prevDBEnd = 0.0, dbMin = 0.0;
    for (NSUInteger i = 1; i < count; i++) {
        prevRawEnd = rawEnd;
        prevDBEnd = dbEnd;
        rawMin = [rawPoint minimum];
        NSInteger rawMax = [rawPoint maximum];
        dbMin = [dbPoint minimum];
        double dbMax = [dbPoint maximum];
        rawPoint = [_rawArray objectAtIndex:i];
        dbPoint = [_dbArray objectAtIndex:i];
        rawEnd = (prevRawEnd - rawMin) + rawMax;
        dbEnd = (dbMax - dbMin) + prevDBEnd;
    }
    return prevRawEnd == rawMin && prevDBEnd == dbMin;
}

- (void)resetRange
{
    [_rawArray removeAllObjects];
    [_dbArray removeAllObjects];
}

// Ranges are appended; the scan stops at the first overlap or at an existing
// range starting at or below the new one.
- (void)addRangeWithMinRaw:(NSInteger)aRaw maxRaw:(NSInteger)aRaw2 minDB:(double)aDB maxDB:(double)aDB2
{
    HSRawPoint *rawPoint = [HSRawPoint rawPointWithMinimum:aRaw maximum:aRaw2];
    HSDBPoint *dbPoint = [HSDBPoint dbPointWithMinimum:aDB maximum:aDB2];
    BOOL passed = NO;
    BOOL overlap = NO;
    NSEnumerator *e = [_rawArray objectEnumerator];
    HSRawPoint *existing;
    while ((existing = [e nextObject]) != nil && !(passed || overlap)) {
        overlap = [HSRawPoint overlapRawPoint:rawPoint withRawPoint:existing];
        passed = [existing minimum] <= [rawPoint minimum];
    }
    if (!overlap) {
        [_rawArray addObject:rawPoint];
        [_dbArray addObject:dbPoint];
    }
}

- (double)maximumDB
{
    HSDBPoint *point = [[_dbArray reverseObjectEnumerator] nextObject];
    return point ? [point maximum] : 0.0;
}

- (double)minimumDB
{
    HSDBPoint *point = [[_dbArray objectEnumerator] nextObject];
    return point ? [point minimum] : 0.0;
}

- (NSInteger)maximumRaw
{
    HSRawPoint *point = [[_rawArray reverseObjectEnumerator] nextObject];
    return point ? [point maximum] : 0;
}

- (NSInteger)minimumRaw
{
    HSRawPoint *point = [[_rawArray objectEnumerator] nextObject];
    return point ? [point minimum] : 0;
}

- (void)dealloc
{
    [_rawArray release];
    [_dbArray release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _rawArray = [NSMutableArray new];
        _dbArray = [NSMutableArray new];
    }
    return self;
}

@end

@implementation HSDBPoint

+ (BOOL)overlapDBPoint:(id)aPoint withDBPoint:(id)aPoint2
{
    if ([(HSDBPoint *)aPoint minimum] >= [(HSDBPoint *)aPoint2 maximum])
        return NO;
    return [(HSDBPoint *)aPoint2 minimum] <= [(HSDBPoint *)aPoint maximum];
}

+ (id)dbPointWithMinimum:(double)aMinimum maximum:(double)aMaximum
{
    return [[[HSDBPoint alloc] initWithMinimum:aMinimum maximum:aMaximum] autorelease];
}

+ (id)dbPointWithDBPoint:(id)aPoint
{
    return [HSDBPoint dbPointWithMinimum:[(HSDBPoint *)aPoint minimum] maximum:[(HSDBPoint *)aPoint maximum]];
}

+ (id)dbPoint
{
    return [HSDBPoint dbPointWithMinimum:0.0 maximum:0.0];
}

- (void)setMaximum:(double)aMaximum
{
    _maximum = aMaximum;
}

- (double)maximum
{
    return _maximum;
}

- (void)setMinimum:(double)aMinimum
{
    _minimum = aMinimum;
}

- (double)minimum
{
    return _minimum;
}

- (id)initWithMinimum:(double)aMinimum maximum:(double)aMaximum
{
    self = [super init];
    if (self != nil) {
        _minimum = aMinimum;
        _maximum = aMaximum;
    }
    return self;
}

// Allocates a fresh instance and leaks the receiver (original behaviour).
- (id)initWithDBPoint:(id)aPoint
{
    return [[HSDBPoint alloc] initWithMinimum:[(HSDBPoint *)aPoint minimum] maximum:[(HSDBPoint *)aPoint maximum]];
}

@end

@implementation HSRawPoint

+ (BOOL)overlapRawPoint:(id)aPoint withRawPoint:(id)aPoint2
{
    if ([(HSRawPoint *)aPoint minimum] < [(HSRawPoint *)aPoint2 maximum])
        return [(HSRawPoint *)aPoint2 minimum] < [(HSRawPoint *)aPoint maximum];
    return NO;
}

+ (id)rawPointWithMinimum:(NSInteger)aMinimum maximum:(NSInteger)aMaximum
{
    return [[[HSRawPoint alloc] initWithMinimum:aMinimum maximum:aMaximum] autorelease];
}

+ (id)rawPointWithRawPoint:(id)aPoint
{
    return [HSRawPoint rawPointWithMinimum:[(HSRawPoint *)aPoint minimum] maximum:[(HSRawPoint *)aPoint maximum]];
}

+ (id)rawPoint
{
    return [HSRawPoint rawPointWithMinimum:0 maximum:0];
}

- (void)setMaximum:(NSInteger)aMaximum
{
    _maximum = (int)aMaximum;
}

- (NSInteger)maximum
{
    return _maximum;
}

- (void)setMinimum:(NSInteger)aMinimum
{
    _minimum = (int)aMinimum;
}

- (NSInteger)minimum
{
    return _minimum;
}

- (id)initWithMinimum:(NSInteger)aMinimum maximum:(NSInteger)aMaximum
{
    self = [super init];
    if (self != nil) {
        _minimum = (int)aMinimum;
        _maximum = (int)aMaximum;
    }
    return self;
}

// Allocates a fresh instance and leaks the receiver (original behaviour).
- (id)initWithRawPoint:(id)aPoint
{
    return [[HSRawPoint alloc] initWithMinimum:[(HSRawPoint *)aPoint minimum] maximum:[(HSRawPoint *)aPoint maximum]];
}

@end
