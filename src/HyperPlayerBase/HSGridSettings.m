#import "HSGridSettings.h"

// Grid options of a document (visibility, snapping, offset, layout grid,
// color, mark style); changes are undoable and mirrored to user defaults.
@implementation HSGridSettings
+ (NSInteger)defaultMarkStyle
{
    return 3;
}
+ (id)defaultColor
{
    return [NSColor blueColor];
}
- (void)layoutGridDidChange:(id)aChange
{
    [self notifyAboutChanges];
}
- (BOOL)isSnapToGridEnabled
{
    return _isSnapToGridEnabled;
}
- (void)setGridVisible:(BOOL)aVisible
{
    if (!aVisible == !_isGridVisible)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Grid Visibility Change" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setGridVisible:_isGridVisible];
    _isGridVisible = aVisible;
    [self notifyAboutChanges];
}
- (void)setGridOffset:(NSSize)aOffset
{
    if (NSEqualSizes(_gridOffset, aOffset))
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Grid Offset Change" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setGridOffset:_gridOffset];
    _gridOffset = aOffset;
    [self notifyAboutChanges];
}
- (void)setIsSnapToGridEnabled:(BOOL)aEnabled
{
    if (!aEnabled == !_isSnapToGridEnabled)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Snap To Grid Change" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setIsSnapToGridEnabled:_isSnapToGridEnabled];
    _isSnapToGridEnabled = aEnabled;
    [self notifyAboutChanges];
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
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Layout Grid Change" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setLayoutGrid:_layoutGrid];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (_layoutGrid)
        [center removeObserver:self name:HSLayoutGridDidChangeNotification object:_layoutGrid];
    [_layoutGrid release];
    _layoutGrid = [aGrid retain];
    if (_layoutGrid)
        [center addObserver:self selector:@selector(layoutGridDidChange:) name:HSLayoutGridDidChangeNotification object:_layoutGrid];
    [self notifyAboutChanges];
}
- (id)layoutGrid
{
    if (_layoutGrid == nil) {
        _layoutGrid = [[HSLayoutGrid alloc] init];
        if (_layoutGrid)
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
    if (_gridColor == aColor)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Grid Color Change" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setGridColor:_gridColor];
    [_gridColor release];
    _gridColor = [aColor retain];
    [self notifyAboutChanges];
}
- (NSInteger)markStyle
{
    if (_markStyle == 0)
        _markStyle = (int)[[self class] defaultMarkStyle];
    return _markStyle;
}
- (void)setMarkStyle:(NSInteger)aStyle
{
    if (_markStyle == aStyle)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Mark Style Change" value:@"" table:@"UndoManager"]];
    [(HSGridSettings *)[[self undoManager] prepareWithInvocationTarget:self] setMarkStyle:_markStyle];
    _markStyle = (int)aStyle;
    [self notifyAboutChanges];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObjects:@"isGridVisible", @"layoutGrid", @"isSnapToGridEnabled",
            [@"gridColor" extraKeyForMultiRepresentations], @"markStyle", nil];
}
- (void)resetToDefaults
{
    [_gridColor release];
    _gridColor = nil;
    [_layoutGrid release];
    _layoutGrid = nil; // Original leaves the layout grid observer registered.
    _gridOffset = NSZeroSize;
    _isGridVisible = NO;
    _isSnapToGridEnabled = NO;
    _markStyle = 0;
    [self notifyAboutChanges];
    [self saveToUserDefaults];
}
- (void)saveToUserDefaults
{
    [[NSUserDefaults standardUserDefaults] setObject:[self extraDictionaryRepresentation] forKey:@"HSGridSettings"];
}
- (void)notifyAboutChanges
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSGridSetingsWasChangeNotification" object:self];
}
- (void)setUndoManager:(id)aManager
{
    if (_undoManager != aManager) {
        [_undoManager release];
        _undoManager = [aManager retain];
        [(HSLayoutGrid *)[self layoutGrid] setUndoManager:_undoManager];
    }
}
- (id)undoManager
{
    return _undoManager;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_gridColor release];
    [_layoutGrid release];
    [_undoManager release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self) {
        id settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSGridSettings"];
        if (settings)
            [self loadExtraDictionaryRepresentation:settings];
    }
    return self;
}
@end
