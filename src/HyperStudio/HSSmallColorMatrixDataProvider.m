#import "HSSmallColorMatrixDataProvider.h"

static HSSmallColorMatrixDataProvider *HSSmallColorMatrixDataProviderShared = nil;

@implementation HSSmallColorMatrixDataProvider

+ (id)sharedDataProvider
{
    if (!HSSmallColorMatrixDataProviderShared)
        HSSmallColorMatrixDataProviderShared = [[self alloc] initWithColorsProvider:[HSBigColorMatrixDataProvider sharedDataProvider]];
    return HSSmallColorMatrixDataProviderShared;
}

- (NSInteger)indexInPositionsArrayForRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    return [self numberOfColumns] * aRow + aColumn;
}

// The matrix cells point at positions in the big provider's matrix; the
// default layout comes from ColorMatrixPositions.plist.
- (id)defaultPositions
{
    NSInteger rows = [self numberOfRows];
    NSInteger columns = [self numberOfColumns];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ColorMatrixPositions" ofType:@"plist"];
    NSMutableArray *positions = nil;
    if (path) {
        positions = [NSMutableArray arrayWithCapacity:columns * rows];
        NSEnumerator *enumerator = [[NSArray arrayWithContentsOfFile:path] objectEnumerator];
        for (NSInteger row = 0; row < rows; row++) {
            for (NSInteger column = 0; column < columns; column++)
                [positions addObject:[HSMatrixPosition objectWithExtraDictionary:[enumerator nextObject]]];
        }
    }
    return positions;
}

// Re-posts the change for every cell referencing the changed big-matrix cell.
- (void)colorsProviderDidColorChange:(id)aChange
{
    NSDictionary *userInfo = [aChange userInfo];
    id rowNumber = [userInfo objectForKey:HSRowKey];
    id columnNumber = [userInfo objectForKey:HSColumnKey];
    if (!rowNumber || !columnNumber) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HSColorMatrixDataProviderColorDidChangeNotification object:self];
        return;
    }
    NSInteger changedRow = [rowNumber intValue];
    NSInteger changedColumn = [columnNumber intValue];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    for (NSInteger row = 0; row < [self numberOfRows]; row++) {
        for (NSInteger column = 0; column < [self numberOfColumns]; column++) {
            HSMatrixPosition *position = [self referencedPositionAtRow:row column:column];
            if ([position row] == changedRow && [position column] == changedColumn)
                [center postNotificationName:HSColorMatrixDataProviderColorDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)row], HSRowKey, [NSNumber numberWithInt:(int)column], HSColumnKey, nil]];
        }
    }
}

- (void)setReferencedPosition:(id)aPosition atRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    [_positions replaceObjectAtIndex:[self indexInPositionsArrayForRow:aRow column:aColumn] withObject:aPosition];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSColorMatrixDataProviderColorDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)aRow], HSRowKey, [NSNumber numberWithInt:(int)aColumn], HSColumnKey, nil]];
}

- (id)referencedPositionAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    return [_positions objectAtIndex:[self indexInPositionsArrayForRow:aRow column:aColumn]];
}

// (The original's inner break only leaves the column loop, so the match in
// the last matching row wins.)
- (id)positionOfColor:(id)aColor
{
    id color = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    NSInteger rows = [self numberOfRows];
    NSInteger columns = [self numberOfColumns];
    id result = nil;
    for (NSInteger row = 0; row < rows; row++) {
        for (NSInteger column = 0; column < columns; column++) {
            if ([[self colorAtRow:row column:column] isEqualTo:color]) {
                result = [HSMatrixPosition positionWithRow:row column:column];
                break;
            }
        }
    }
    return result;
}

- (NSSize)colorSwatchImageSize
{
    return [_colorsProvider colorSwatchImageSize];
}

- (id)colorSwatchImageAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    HSMatrixPosition *position = [self referencedPositionAtRow:aRow column:aColumn];
    return [_colorsProvider colorSwatchImageAtRow:[position row] column:[position column]];
}

- (void)setColor:(id)aColor atRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    HSMatrixPosition *position = [self referencedPositionAtRow:aRow column:aColumn];
    [_colorsProvider setColor:aColor atRow:[position row] column:[position column]];
}

- (id)colorAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    HSMatrixPosition *position = [self referencedPositionAtRow:aRow column:aColumn];
    return [_colorsProvider colorAtRow:[position row] column:[position column]];
}

- (NSInteger)numberOfColumns
{
    return 8;
}

- (NSInteger)numberOfRows
{
    return 8;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_positions release];
    [super dealloc];
}

- (id)initWithColorsProvider:(id)aProvider
{
    self = [super init];
    if (self) {
        _colorsProvider = aProvider;
        _positions = [[self defaultPositions] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorsProviderDidColorChange:) name:HSColorMatrixDataProviderColorDidChangeNotification object:_colorsProvider];
    }
    return self;
}

@end
