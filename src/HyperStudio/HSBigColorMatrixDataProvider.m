#import "HSBigColorMatrixDataProvider.h"

@implementation HSBigColorMatrixDataProvider

+ (id)sharedDataProvider
{
    static id sSharedDataProvider = nil;

    if (sSharedDataProvider == nil)
        sSharedDataProvider = [[self alloc] init];
    return sSharedDataProvider;
}

- (id)defaultColorAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    static NSArray *sDefaultColors = nil;

    if (sDefaultColors == nil)
        sDefaultColors = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ColorMatrixColors" ofType:@"plist"]] retain];
    return [NSColor objectWithExtraDictionary:[sDefaultColors objectAtIndex:aColumn + aRow * [self numberOfColumns]]];
}

- (void)deactivateAllViews
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSBigColorMatrixDataProviderActiveViewDidChangeNotification" object:self];
}

- (void)resetToDefault
{
    NSInteger rows, columns, row, column;

    [self deactivateAllViews];
    rows = [self numberOfRows];
    columns = [self numberOfColumns];
    if (rows > 0 && columns > 0) {
        for (row = 0; row < rows; row++)
            for (column = 0; column < columns; column++)
                [self setColor:[self defaultColorAtRow:row column:column] atRow:row column:column];
    }
    [self cleanColorsInUserDefaults];
}

- (id)init
{
    return [super initWithNumberOfRows:16 columns:16 colorSwatchImageSize:NSMakeSize(8.0, 8.0) outline:NSMakeSize(1.0, 1.0) storeInDefaults:YES];
}

@end
