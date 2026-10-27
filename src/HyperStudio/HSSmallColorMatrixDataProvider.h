#import "HyperStudioPrefix.h"


@interface HSSmallColorMatrixDataProvider : NSObject <HSColorMatrixDataProvider, NSObject>
{
    id<HSColorMatrixDataProvider> _colorsProvider;
    NSMutableArray *_positions;
}
+ (id)sharedDataProvider;
- (NSInteger)indexInPositionsArrayForRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)defaultPositions;
- (void)colorsProviderDidColorChange:(id)aChange;
- (void)setReferencedPosition:(id)aPosition atRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)referencedPositionAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)positionOfColor:(id)aColor;
- (NSSize)colorSwatchImageSize;
- (id)colorSwatchImageAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (void)setColor:(id)aColor atRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)colorAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (NSInteger)numberOfColumns;
- (NSInteger)numberOfRows;
- (void)dealloc;
- (id)initWithColorsProvider:(id)aProvider;
@end

