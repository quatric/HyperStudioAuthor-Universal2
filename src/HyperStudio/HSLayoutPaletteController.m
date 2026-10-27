#import "HSLayoutPaletteController.h"

@implementation HSLayoutPaletteController

- (void)switchToEditor
{
    [[[NSDocumentController sharedDocumentController] currentDocument] switchToEditor];
}

- (void)rotateSelectedObject_forward:(id)aForward
{
    id target = [NSApp targetForAction:@selector(rotateSelectedObject:) to:nil from:aForward];
    if (target != nil)
        [NSApp sendAction:@selector(rotateSelectedObject:) to:target from:aForward];
}

- (void)gridAction:(id)aAction
{
    if (_gridButton == aAction) {
        NSInteger tag = [[aAction selectedItem] tag];
        id gridSettings = [[[[NSDocumentController sharedDocumentController] currentDocument] stack] gridSettings];
        if (tag > 0)
            [[gridSettings layoutGrid] setGridSpacing:NSMakeSize((float)tag, (float)tag)];
        [self switchToEditor];
        [gridSettings setGridVisible:[aAction state] == NSControlStateValueOn];
    } else {
        id target = [NSApp targetForAction:@selector(showGridOptionsDialog:) to:nil from:aAction];
        if (target == nil)
            return;
        [NSApp sendAction:@selector(showGridOptionsDialog:) to:target from:aAction];
    }
}

- (void)startCollapseAnimation:(id)aAnimation
{
    NSRect basicFrame = [_basicSettingsContainer frame];
    NSRect advancedFrame = [_advancedSettingsContainer frame];
    NSRect contentRect = [NSWindow contentRectForFrameRect:[_window frame] styleMask:[_window styleMask]];
    NSRect expandedFrame = NSUnionRect(basicFrame, advancedFrame);
    NSInteger state = [aAnimation state];
    NSSize newSize = state == NSControlStateValueOff ? basicFrame.size : expandedFrame.size;
    NSRect newContentRect = NSMakeRect(contentRect.origin.x, (contentRect.size.height - newSize.height) + contentRect.origin.y, newSize.width, newSize.height);
    NSRect newFrame = [NSWindow frameRectForContentRect:newContentRect styleMask:[_window styleMask]];
    newFrame = [[self class] adjustFrameToFitVisibleScreenFrame:newFrame];
    NSDictionary *animation = [NSDictionary dictionaryWithObjectsAndKeys:
        _window, NSViewAnimationTargetKey,
        [NSValue valueWithRect:[_window frame]], NSViewAnimationStartFrameKey,
        [NSValue valueWithRect:newFrame], NSViewAnimationEndFrameKey,
        nil];
    NSViewAnimation *viewAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animation]];
    [viewAnimation setDuration:[_window animationResizeTime:newFrame]];
    [viewAnimation setAnimationCurve:NSAnimationEaseIn];
    [viewAnimation startAnimation];
    [viewAnimation release];
    [[NSUserDefaults standardUserDefaults] setBool:state == NSControlStateValueOff forKey:@"HSLayoutPaletteIsCollapsedKey"];
}

- (NSRect)collapsedPaletteFrame
{
    NSRect basicFrame = [_basicSettingsContainer frame];
    NSRect contentRect = [NSWindow contentRectForFrameRect:[_window frame] styleMask:[_window styleMask]];
    return [NSWindow frameRectForContentRect:NSMakeRect(contentRect.origin.x, (contentRect.size.height - basicFrame.size.height) + contentRect.origin.y, basicFrame.size.width, basicFrame.size.height)
                                   styleMask:[_window styleMask]];
}

static BOOL HSLayoutPaletteApproximatelyEqual(float a, float b)
{
    float scaleA = a != 0.0f ? fabsf(a) : 1.0f;
    float scaleB = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(scaleA, scaleB) * 0.0005f;
}

- (BOOL)isPaletteExpanded
{
    NSRect basicFrame = [_basicSettingsContainer frame];
    NSRect advancedFrame = [_advancedSettingsContainer frame];
    NSRect contentRect = [NSWindow contentRectForFrameRect:[_window frame] styleMask:[_window styleMask]];
    NSRect expandedFrame = NSUnionRect(basicFrame, advancedFrame);
    return HSLayoutPaletteApproximatelyEqual(contentRect.size.height, expandedFrame.size.height);
}

- (void)validateUserInterface
{
    [self validatePaletteItem:_snapToGridButton];
    [self validatePaletteItem:_showGuidelinesButton];
    [self validatePaletteItem:_alignBottomButton];
    [self validatePaletteItem:_alignTopButton];
    [self validatePaletteItem:_alignYCenterButton];
    [self validatePaletteItem:_alignLeftButton];
    [self validatePaletteItem:_alignRightButton];
    [self validatePaletteItem:_alignXCenterButton];
    [self validatePaletteItem:_orderFrontButton];
    [self validatePaletteItem:_orderBackButton];
    [self validatePaletteItem:_orderForwardButton];
    [self validatePaletteItem:_orderBackwardButton];
    [self validatePaletteItem:_scaleToFillButton];
    [self validatePaletteItem:_scaleToFitButton];
    [self validatePaletteItem:_xFlipButton];
    [self validatePaletteItem:_yFlipButton];
    [self validatePaletteItem:_centerButton];
    [self validatePaletteItem:_rotateButton];
    [self validateGridButton];
}

- (void)validateGridButton
{
    id document = [[NSDocumentController sharedDocumentController] currentDocument];
    if (document == nil) {
        [_gridButton setEnabled:NO];
        return;
    }
    id gridSettings = [[document stack] gridSettings];
    id layoutGrid = [gridSettings layoutGrid];
    [_gridButton setState:[gridSettings isGridVisible] ? NSControlStateValueOn : NSControlStateValueOff];
    NSSize spacing = [layoutGrid gridSpacing];
    NSInteger tag = 0;
    if (HSLayoutPaletteApproximatelyEqual(spacing.width, spacing.height)
        && HSLayoutPaletteApproximatelyEqual(spacing.width, floorf(spacing.width)))
        tag = (NSInteger)spacing.width;
    if (![_gridButton selectItemWithTag:tag])
        [_gridButton selectItemWithTag:0];
    [_gridButton setEnabled:![document isInAnimationMode] && ![document isModalSessionPresent]];
}

- (void)didLoadNib
{
    [super didLoadNib];
    [[_gridButton cell] setDisplayedImage:[NSImage imageNamed:@"Grid"]];
    [[_gridButton cell] setDrawsArrow:NO];
    [[_gridButton cell] setHighlightsBy:12];
    [[_gridButton cell] setShowsStateBy:12];
    [[[_gridButton cell] lastItem] setTarget:self];
    [[[_gridButton cell] lastItem] setAction:@selector(gridAction:)];
    [[[_gridButton cell] lastItem] setTag:0];
    [[NSArray arrayWithObjects:[_gridButton cell], [_snapToGridButton cell], [_showGuidelinesButton cell], nil]
        makeObjectsPerformSelector:@selector(setBackgroundRenderer:) withObject:[HSLayoutPaletteTitleButtonBackgroundRenderer sharedBackgroundRenderer]];
    [[NSArray arrayWithObjects:[_alignBottomButton cell], [_alignTopButton cell], [_alignYCenterButton cell], [_alignLeftButton cell],
        [_alignRightButton cell], [_alignXCenterButton cell], [_orderFrontButton cell], [_orderBackButton cell],
        [_orderForwardButton cell], [_orderBackwardButton cell], [_scaleToFillButton cell], [_scaleToFitButton cell],
        [_xFlipButton cell], [_yFlipButton cell], [_centerButton cell], [_rotateButton cell], nil]
        makeObjectsPerformSelector:@selector(setBackgroundRenderer:) withObject:[HSLayoutPaletteButtonBackgroundRenderer sharedBackgroundRenderer]];
    [[_rotateButton cell] setDisplayedImage:[NSImage imageNamed:@"Rotate"]];
    [[_rotateButton cell] setDrawsArrow:NO];
    [[_rotateButton cell] setHighlightsBy:12];
    [[_rotateButton cell] setShowsStateBy:12];
    [_rotateButton setPullsDown:YES];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HSLayoutPaletteIsCollapsedKey"])
        [_window setFrame:[self collapsedPaletteFrame] display:NO];
    [_collapseButton setState:[self isPaletteExpanded] ? NSControlStateValueOn : NSControlStateValueOff];
}

- (id)nibName
{
    return @"LayoutPalette";
}

@end
