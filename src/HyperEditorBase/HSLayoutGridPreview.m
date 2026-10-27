#import "HSLayoutGridPreview.h"

// A view showing a layout grid as set up (the grid settings preview).

@implementation HSLayoutGridPreview

+ (NSInteger)defaultMarkStyle
{
    return 3;
}

+ (id)defaultColor
{
    return [NSColor blueColor];
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)updateWithObject:(id)aObject
{
    [self loadExtraDictionaryRepresentation:[aObject extraDictionaryRepresentation]];
}

- (void)layoutGridDidChange:(id)aChange
{
    [self setNeedsDisplay:YES];
}

// Original quirk kept: the grid's notifications aren't removed here.
- (void)resetToDefaults
{
    [_gridColor release];
    _gridColor = nil;
    [_layoutGrid release];
    _layoutGrid = nil;
    _gridOffset = NSZeroSize;
    _isGridVisible = NO;
    _isSnapToGridEnabled = NO;
    _markStyle = 0;
    [self setNeedsDisplay:YES];
}

- (BOOL)isSnapToGridEnabled
{
    return _isSnapToGridEnabled;
}

- (void)setGridVisible:(BOOL)aVisible
{
    if (_isGridVisible != aVisible) {
        _isGridVisible = aVisible;
        [self setNeedsDisplay:YES];
    }
}

- (void)setGridOffset:(NSSize)aOffset
{
    if (!NSEqualSizes(_gridOffset, aOffset)) {
        _gridOffset = aOffset;
        [self setNeedsDisplay:YES];
    }
}

- (void)setIsSnapToGridEnabled:(BOOL)aEnabled
{
    if (_isSnapToGridEnabled != aEnabled) {
        _isSnapToGridEnabled = aEnabled;
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)isGridVisible
{
    return _isGridVisible;
}

- (NSSize)gridOffset
{
    return _gridOffset;
}

- (void)setLayoutGrid:(id)aGrid
{
    if (_layoutGrid == aGrid)
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (_layoutGrid != nil)
        [center removeObserver:self name:HSLayoutGridDidChangeNotification object:_layoutGrid];
    [_layoutGrid release];
    _layoutGrid = [aGrid retain];
    if (_layoutGrid != nil)
        [center addObserver:self selector:@selector(layoutGridDidChange:) name:HSLayoutGridDidChangeNotification object:_layoutGrid];
    [self setNeedsDisplay:YES];
}

- (id)layoutGrid
{
    if (_layoutGrid == nil) {
        _layoutGrid = [[HSLayoutGrid alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutGridDidChange:) name:HSLayoutGridDidChangeNotification object:_layoutGrid];
    }
    return _layoutGrid;
}

- (id)gridColor
{
    if (_gridColor == nil)
        _gridColor = [[[self class] defaultColor] retain];
    return _gridColor;
}

- (void)setGridColor:(id)aColor
{
    if (_gridColor != aColor) {
        [_gridColor release];
        _gridColor = [aColor retain];
    }
    [self setNeedsDisplay:YES];
}

- (NSInteger)markStyle
{
    if (_markStyle == 0)
        _markStyle = (int)[[self class] defaultMarkStyle];
    return _markStyle;
}

- (void)setMarkStyle:(NSInteger)aStyle
{
    _markStyle = (int)aStyle;
    [self setNeedsDisplay:YES];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"isGridVisible", @"layoutGrid", @"isSnapToGridEnabled", [@"gridColor" extraKeyForMultiRepresentations], @"markStyle", nil];
}

- (void)dealloc
{
    [_gridColor release];
    if (_layoutGrid != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:HSLayoutGridDidChangeNotification object:_layoutGrid];
        [_layoutGrid release];
    }
    [super dealloc];
}

- (void)drawRect:(NSRect)aRect
{
    if ([self isGridVisible])
        HSRenderGrid(self, nil, [self bounds]);
}

- (id)initWithFrame:(NSRect)aFrame
{
    return [super initWithFrame:aFrame];
}

@end
