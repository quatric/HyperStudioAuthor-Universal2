#import "HyperStudioPrefix.h"


@interface HSColorMatrixDataProvider : NSObject <HSColorMatrixDataProvider, NSObject>
{
    NSMutableDictionary *_colors;
    NSMutableDictionary *_colorSwatchImages;
    int _numberOfRows;
    int _numberOfColumns;
    NSSize _colorSwatchImageSize;
    NSSize _colorSwatchImageOutline;
    BOOL _storeColorsInDefaults;
}
- (void)updateDefaultsItem:(id)aItem;
- (id)colorSwatchImageWithColor:(id)aColor;
- (id)colorFromUserDefaultsAtPosition:(id)aPosition;
- (id)keyToStoringInDefaultsFromRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)keyToStoringInDefaultsFromPosition:(id)aPosition;
- (id)defaultColorAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (void)cleanColorsInUserDefaults;
- (id)positionOfColor:(id)aColor;
- (void)setColor:(id)aColor atRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (NSSize)colorSwatchImageSize;
- (id)colorSwatchImageAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (id)colorAtRow:(NSInteger)aRow column:(NSInteger)aColumn;
- (NSInteger)numberOfColumns;
- (NSInteger)numberOfRows;
- (void)dealloc;
- (id)initWithNumberOfRows:(NSInteger)aRows columns:(NSInteger)aColumns colorSwatchImageSize:(NSSize)aSize outline:(NSSize)aOutline storeInDefaults:(BOOL)aDefaults;
@end

