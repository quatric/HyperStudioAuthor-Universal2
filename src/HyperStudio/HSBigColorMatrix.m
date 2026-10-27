#import "HSBigColorMatrix.h"

@implementation HSBigColorMatrix

- (void)dataProviderDidActiveViewChange:(id)aChange
{
    [self setActive:NO];
}

- (void)colorPanelDidColorChange:(id)aChange
{
    [[self dataProvider] setColor:[[NSColorPanel sharedColorPanel] color] atRow:[self selectedRow] column:[self selectedColumn]];
}

- (void)reloadData
{
    [super reloadData];
    if ([NSColorPanel sharedColorPanelExists] && _isActive)
        [[NSColorPanel sharedColorPanel] setColor:[self selectedColor]];
}

- (void)handleMouseTracking
{
    if ([NSColorPanel sharedColorPanelExists]) {
        if (![self isActive]) {
            [[self dataProvider] deactivateAllViews];
            [self setActive:YES];
        }
        [[NSColorPanel sharedColorPanel] setColor:[self selectedColor]];
    }
    [super handleMouseTracking];
}

- (void)handleDoubleClick
{
    if (![NSColorPanel sharedColorPanelExists]) {
        [[NSColorPanel sharedColorPanel] setColor:[self selectedColor]];
        [self setActive:YES];
    }
    [[NSColorPanel sharedColorPanel] orderFront:nil];
    [super handleDoubleClick];
}

- (void)handleSingleClickWithSelectionChange:(BOOL)aChange
{
    if ([NSColorPanel sharedColorPanelExists]) {
        if (![self isActive]) {
            [[self dataProvider] deactivateAllViews];
            [self setActive:YES];
        }
        if (aChange)
            [[NSColorPanel sharedColorPanel] setColor:[self selectedColor]];
    }
    [super handleSingleClickWithSelectionChange:aChange];
}

- (void)setActive:(BOOL)aActive
{
    if (_isActive == aActive)
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (aActive) {
        [center addObserver:self selector:@selector(dataProviderDidActiveViewChange:) name:HSBigColorMatrixDataProviderActiveViewDidChangeNotification object:[self dataProvider]];
        [center addObserver:self selector:@selector(colorPanelDidColorChange:) name:NSColorPanelColorDidChangeNotification object:[NSColorPanel sharedColorPanel]];
    } else {
        [center removeObserver:self name:HSBigColorMatrixDataProviderActiveViewDidChangeNotification object:[self dataProvider]];
        [center removeObserver:self name:NSColorPanelColorDidChangeNotification object:[NSColorPanel sharedColorPanel]];
    }
    _isActive = aActive;
}

- (BOOL)isActive
{
    return _isActive;
}

- (id)dataProvider
{
    return [super dataProvider];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)aFrame
{
    return [super initWithFrame:aFrame dataProvider:[HSBigColorMatrixDataProvider sharedDataProvider]];
}

@end
