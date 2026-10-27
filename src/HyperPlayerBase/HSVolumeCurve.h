#import "HyperPlayerBasePrefix.h"


@interface HSVolumeCurve : NSObject
{
    NSMutableArray *_rawArray;
    NSMutableArray *_dbArray;
}
- (double)convertScalarToDB:(double)aDB;
- (NSInteger)convertScalarToRaw:(double)aRaw;
- (double)convertDBToScalar:(double)aScalar;
- (double)convertRawToScalar:(NSInteger)aScalar;
- (double)convertRawToDB:(NSInteger)aDB;
- (NSInteger)convertDBToRaw:(double)aRaw;
- (BOOL)checkForContinuity;
- (void)resetRange;
- (void)addRangeWithMinRaw:(NSInteger)aRaw maxRaw:(NSInteger)aRaw2 minDB:(double)aDB maxDB:(double)aDB2;
- (double)maximumDB;
- (double)minimumDB;
- (NSInteger)maximumRaw;
- (NSInteger)minimumRaw;
- (void)dealloc;
- (id)init;
@end

@interface HSDBPoint : NSObject
{
    double _minimum;
    double _maximum;
}
+ (BOOL)overlapDBPoint:(id)aPoint withDBPoint:(id)aPoint2;
+ (id)dbPointWithMinimum:(double)aMinimum maximum:(double)aMaximum;
+ (id)dbPointWithDBPoint:(id)aPoint;
+ (id)dbPoint;
- (void)setMaximum:(double)aMaximum;
- (double)maximum;
- (void)setMinimum:(double)aMinimum;
- (double)minimum;
- (id)initWithMinimum:(double)aMinimum maximum:(double)aMaximum;
- (id)initWithDBPoint:(id)aPoint;
@end

@interface HSRawPoint : NSObject
{
    int _minimum;
    int _maximum;
}
+ (BOOL)overlapRawPoint:(id)aPoint withRawPoint:(id)aPoint2;
+ (id)rawPointWithMinimum:(NSInteger)aMinimum maximum:(NSInteger)aMaximum;
+ (id)rawPointWithRawPoint:(id)aPoint;
+ (id)rawPoint;
- (void)setMaximum:(NSInteger)aMaximum;
- (NSInteger)maximum;
- (void)setMinimum:(NSInteger)aMinimum;
- (NSInteger)minimum;
- (id)initWithMinimum:(NSInteger)aMinimum maximum:(NSInteger)aMaximum;
- (id)initWithRawPoint:(id)aPoint;
@end

