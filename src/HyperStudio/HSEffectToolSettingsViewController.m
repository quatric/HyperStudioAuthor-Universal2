#import "HSEffectToolSettingsViewController.h"

@implementation HSEffectToolSettingsViewController

- (void)updateUI
{
    NSInteger tag = [[HSToolManager sharedToolManager] selectedToolTag];
    id tool = [[HSToolManager sharedToolManager] currentTool];
    if (tag == 0x25) {
        if ([tool effectDisplayName] != nil)
            [_effectName setStringValue:[tool effectDisplayName]];
        [_effectPreview setImage:[tool effectPreviewImage]];
    } else if (tag == 0x26) {
        [_effectName setStringValue:[tool effectDisplayName]];
        [_effectPreview setImage:[tool effectPreviewImage]];
    }
    id currentTool = [[HSToolManager sharedToolManager] currentTool];
    id toolSettings = [[HSToolManager sharedToolManager] toolSettings];
    int index = [[[toolSettings settings] objectForKey:[@"template-" stringByAppendingString:[currentTool primarySettingsIdentifier]]] intValue];
    NSInteger tab = index / 8;
    if (tab != [_tabView indexOfSelectedTab]) {
        [_tabView selectTabAtIndex:tab];
        [_gridControl reloadData];
    }
    [_gridControl selectItemAtIndex:index % 8 byExtendingSelection:NO];
    [_effectIntencity setFloatValue:HSLinearValueForSliderFromNonLinear(_effectIntencity, [toolSettings effectIntencity] * 100.0f)];
    [_effectIntencity setEnabled:[tool isIntencitySupported]];
}

- (void)didMount
{
    [self updateUI];
}

- (void)selectedTabDidChangeInCustomTabView:(id)aView
{
    [_gridControl reloadData];
    [self selectionDidChangeInGridControl:_gridControl];
}

- (void)selectionDidChangeInGridControl:(id)aControl
{
    NSInteger item = [_gridControl selectedItemIndex];
    NSInteger tab = [_tabView indexOfSelectedTab];
    [[[HSToolManager sharedToolManager] toolSettings] applySettingsForTool:[[HSToolManager sharedToolManager] currentTool] templateIndex:item + tab * 8];
    [self updateUI];
}

- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    NSInteger tab = [_tabView indexOfSelectedTab];
    return [[[HSToolManager sharedToolManager] toolSettings] imageForTemplateAtIndex:tab * 8 + aAt forTool:[[HSToolManager sharedToolManager] currentTool]];
}

- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt
{
    NSInteger tab = [_tabView indexOfSelectedTab];
    id name = [[[[HSToolManager sharedToolManager] toolSettings] templateDictionaryAtIndex:tab * 8 + aAt forTool:[[HSToolManager sharedToolManager] currentTool]] objectForKey:@"effectName"];
    if (name == nil)
        return nil;
    return [NSDictionary dictionaryWithObject:[[NSBundle bundleForClass:[HSEffect class]] localizedStringForKey:name value:@"" table:@"Effects"] forKey:SMKGridAttributeVoiceOverItemTypeKey];
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    NSInteger tab = [_tabView indexOfSelectedTab];
    id name = [[[[HSToolManager sharedToolManager] toolSettings] templateDictionaryAtIndex:tab * 8 + aAt forTool:[[HSToolManager sharedToolManager] currentTool]] objectForKey:@"effectName"];
    return [[NSBundle bundleForClass:[HSEffect class]] localizedStringForKey:name value:@"" table:@"Effects"];
}

- (NSInteger)numberOfItemsInGridControl:(id)aControl
{
    return 8;
}

- (Class)cellClass
{
    return [SMKGridBaseCell class];
}

- (id)templateDictionaryAtIndex:(NSUInteger)aIndex
{
    return [[[HSToolManager sharedToolManager] toolSettings] templateDictionaryAtIndex:aIndex forTool:[[HSToolManager sharedToolManager] currentTool]];
}

- (void)effectIntencityChanged:(id)aChanged
{
    [[[HSToolManager sharedToolManager] toolSettings] setEffectIntencity:HSNonLinearValueForSlider(aChanged) / 100.0f];
}

- (void)didLoadNib
{
    NSView *contentView = [[[NSView alloc] initWithFrame:NSZeroRect] autorelease];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    [_tabView setDelegate:self];
    NSDictionary *values = [NSDictionary dictionaryWithObjectsAndKeys:
        [bundle localizedStringForKey:@"Image Effects settings" value:@"" table:@"ToolPalette"], NSAccessibilityDescriptionAttribute,
        [[NSBundle mainBundle] localizedStringForKey:@"tab" value:@"" table:nil], NSAccessibilityRoleDescriptionAttribute, nil];
    [_tabView addTabWithTitle:[bundle localizedStringForKey:@"Image Effects" value:@"" table:@"ToolPalette"] image:nil toolTip:[bundle localizedStringForKey:@"Image Effects ToolTip" value:@"" table:@"ToolPalette"] accessibilityValues:values contentView:contentView];
    values = [NSDictionary dictionaryWithObjectsAndKeys:
        [bundle localizedStringForKey:@"Color Effects settings" value:@"" table:@"ToolPalette"], NSAccessibilityDescriptionAttribute,
        [[NSBundle mainBundle] localizedStringForKey:@"tab" value:@"" table:nil], NSAccessibilityRoleDescriptionAttribute, nil];
    [_tabView addTabWithTitle:[bundle localizedStringForKey:@"Color Effects" value:@"" table:@"ToolPalette"] image:nil toolTip:[bundle localizedStringForKey:@"Color Effects ToolTip" value:@"" table:@"ToolPalette"] accessibilityValues:values contentView:contentView];

    [_gridControl setMode:0];
    [_gridControl setScrollerControlSize:1];
    [_gridControl setCellControlSize:2];
    [_gridControl setSelectionStyle:3];
    [_gridControl setImageFrameColor:[NSColor redColor]];
    [_gridControl setThreadedPreloadingEnabled:NO];
    [_gridControl setAllowsMultipleSelection:NO];
    [_gridControl setThumbnailCachingEnabled:NO];
    [_gridControl setThumbnailHyphenationEnabled:YES];
    [_gridControl setGraphicContentShadowEnabled:NO];
    [_gridControl setExtraPasteboardDataProvidingAllowed:NO];
    [_gridControl setDataSource:self];
    [_gridControl setDelegate:self];
    [_gridControl setTarget:self];
    [_gridControl setThumbnailSize:NSMakeSize(46.0, 46.0) andBorderOffset:NSMakeSize(1.0, 2.0) titleOffset:0.0];
    [[_gridControl scrollView] setHasVerticalScroller:NO];
    [[_gridControl scrollView] setHasHorizontalScroller:NO];
    [[_gridControl scrollView] setBorderType:NSNoBorder];
    [[_gridControl gridMatrix] setAcceptsFirstMouse:YES];
    [[_gridControl gridMatrix] setNeedsPanelToBecomeKey:NO];
    [[_gridControl gridMatrix] setTextSelectionStyle:1];
    NSFont *font = [NSFont systemFontOfSize:8.0];
    [_gridControl setThumbnailMaxTitleHeight:(float)[font descender] + (float)[font ascender] + 5.0f];
    [[_gridControl gridMatrix] setTextFont:font];
    [_gridControl reloadData];
    [_effectName setStringValue:@"Effect Name"];
    [self updateUI];
    [self selectionDidChangeInGridControl:_gridControl];
}

- (id)nibName
{
    return @"EffectToolSettings";
}

- (void)dealloc
{
    [super dealloc];
}

@end
