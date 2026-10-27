#import "HSColorMatrixDataProvider.h"

@implementation HSColorMatrixDataProvider

// Writes a colour to the user defaults (called delayed so dragging in the
// colour panel does not write on every change).
- (void)updateDefaultsItem:(id)aItem
{
    id key = [[aItem allKeys] lastObject];
    [[NSUserDefaults standardUserDefaults] setObject:[aItem objectForKey:key] forKey:key];
}

- (id)colorSwatchImageWithColor:(id)aColor
{
    NSImage *image = [[[NSImage alloc] initWithSize:_colorSwatchImageSize] autorelease];
    [image setCacheMode:NSImageCacheAlways];
    [image lockFocus];
    [(NSColor *)aColor set];
    NSRectFill(NSMakeRect(_colorSwatchImageOutline.width, _colorSwatchImageOutline.height, _colorSwatchImageSize.width - _colorSwatchImageOutline.width, _colorSwatchImageSize.height - _colorSwatchImageOutline.height));
    [[NSColor whiteColor] set];
    NSFrameRect(NSMakeRect(0, 0, _colorSwatchImageSize.width, _colorSwatchImageSize.height));
    [image unlockFocus];
    return image;
}

- (id)colorFromUserDefaultsAtPosition:(id)aPosition
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:[self keyToStoringInDefaultsFromPosition:aPosition]])
        return nil;
    return [NSColor objectWithExtraDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:[self keyToStoringInDefaultsFromPosition:aPosition]]];
}

- (id)keyToStoringInDefaultsFromRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    return [self keyToStoringInDefaultsFromPosition:[HSMatrixPosition positionWithRow:aRow column:aColumn]];
}

- (id)keyToStoringInDefaultsFromPosition:(id)aPosition
{
    return [NSString stringWithFormat:@"%@%@", [aPosition stringRepresentation], NSStringFromClass([self class])];
}

// Subclasses supply the default colours.
- (id)defaultColorAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)cleanColorsInUserDefaults
{
    if (_storeColorsInDefaults) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        for (int row = 0; row < _numberOfRows; row++) {
            for (int column = 0; column < _numberOfColumns; column++)
                [defaults removeObjectForKey:[self keyToStoringInDefaultsFromRow:row column:column]];
        }
    }
}

// (The original's inner break only leaves the column loop, so the match in
// the last matching row wins.)
- (id)positionOfColor:(id)aColor
{
    id result = nil;
    for (int row = 0; row < _numberOfRows; row++) {
        for (int column = 0; column < _numberOfColumns; column++) {
            id position = [HSMatrixPosition positionWithRow:row column:column];
            if ([[_colors objectForKey:position] isEqualTo:aColor]) {
                result = position;
                break;
            }
        }
    }
    return result;
}

- (void)setColor:(id)aColor atRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    if (aRow == -1 && aColumn == -1)
        return;
    id position = [HSMatrixPosition positionWithRow:aRow column:aColumn];
    if ([[_colors objectForKey:position] isEqualTo:aColor])
        return;
    [_colors setObject:aColor forKey:position];
    [_colorSwatchImages removeObjectForKey:[HSMatrixPosition positionWithRow:aRow column:aColumn]];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSColorMatrixDataProviderColorDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:(int)aRow], HSRowKey, [NSNumber numberWithInt:(int)aColumn], HSColumnKey, nil]];
    if (_storeColorsInDefaults) {
        NSDictionary *item = [NSDictionary dictionaryWithObject:[aColor extraDictionaryRepresentation] forKey:[self keyToStoringInDefaultsFromPosition:position]];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(updateDefaultsItem:) withObject:item afterDelay:0.25];
    }
}

- (NSSize)colorSwatchImageSize
{
    return _colorSwatchImageSize;
}

- (id)colorSwatchImageAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    if (aRow == -1 && aColumn == -1)
        return nil;
    if (!_colorSwatchImages)
        _colorSwatchImages = [NSMutableDictionary new];
    id position = [HSMatrixPosition positionWithRow:aRow column:aColumn];
    id image = [_colorSwatchImages objectForKey:position];
    if (!image) {
        image = [self colorSwatchImageWithColor:[self colorAtRow:aRow column:aColumn]];
        [_colorSwatchImages setObject:image forKey:position];
    }
    return image;
}

- (id)colorAtRow:(NSInteger)aRow column:(NSInteger)aColumn
{
    if (aRow == -1 && aColumn == -1)
        return nil;
    if (!_colors)
        _colors = [NSMutableDictionary new];
    id position = [HSMatrixPosition positionWithRow:aRow column:aColumn];
    id color = [_colors objectForKey:position];
    if (!color) {
        if (_storeColorsInDefaults)
            color = [self colorFromUserDefaultsAtPosition:position];
        if (!color)
            color = [self defaultColorAtRow:aRow column:aColumn];
        [_colors setObject:color forKey:position];
    }
    return color;
}

- (NSInteger)numberOfColumns
{
    return _numberOfColumns;
}

- (NSInteger)numberOfRows
{
    return _numberOfRows;
}

- (void)dealloc
{
    [_colors release];
    [_colorSwatchImages release];
    [super dealloc];
}

- (id)initWithNumberOfRows:(NSInteger)aRows columns:(NSInteger)aColumns colorSwatchImageSize:(NSSize)aSize outline:(NSSize)aOutline storeInDefaults:(BOOL)aDefaults
{
    self = [super init];
    if (self) {
        _numberOfRows = (int)aRows;
        _numberOfColumns = (int)aColumns;
        _colorSwatchImageSize = aSize;
        _colorSwatchImageOutline = aOutline;
        _storeColorsInDefaults = aDefaults;
    }
    return self;
}

@end
