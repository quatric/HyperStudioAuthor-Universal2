#import "HSLassoSettingsViewController.h"

@implementation HSLassoSettingsViewController

- (void)HSLassoSettingsViewController_selectAllArea:(id)aArea
{
    id target = [NSApp targetForAction:@selector(selectAllArea:) to:nil from:aArea];
    if (target != nil)
        [target performSelector:@selector(selectAllArea:) withObject:aArea];
}

- (void)lassoSelectionPencilModeChanged:(id)aChanged
{
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    [[toolManager toolSettings] setSetting:@"BTFreeHandCreateSelectionMode" forIdentifier:[[toolManager currentTool] toolIdentifier] andKey:@"initialCreateSelectionMode"];
}

- (void)lassoSelectionReverseModeChanged:(id)aChanged
{
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    [[toolManager toolSettings] setSetting:@"BTMagicWandCreateSelectionMode" forIdentifier:[[toolManager currentTool] toolIdentifier] andKey:@"initialCreateSelectionMode"];
}

- (void)lassoSelectionSimpleModeChanged:(id)aChanged
{
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    [[toolManager toolSettings] setSetting:@"BTMagicLassoCreateSelectionMode" forIdentifier:[[toolManager currentTool] toolIdentifier] andKey:@"initialCreateSelectionMode"];
}

- (void)actionToleranceChanged:(id)aChanged
{
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    NSNumber *tolerance = [NSNumber numberWithFloat:1.0f - [aChanged floatValue]];
    [[toolManager toolSettings] setSetting:tolerance forIdentifier:[[toolManager currentTool] toolIdentifier] andKey:@"selectionTolerance"];
    [[toolManager toolSettings] setSetting:tolerance forIdentifier:@"HSAnimationSetupLassoGrabTool" andKey:@"tolerance"];
}

- (void)validateUserInterface
{
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    id settings = [[toolManager toolSettings] settingsForTool:[toolManager currentTool]];
    [_tolerenceSlider setFloatValue:1.0f - [[settings valueForKey:@"selectionTolerance"] floatValue]];
    NSString *mode = [[self regionEditingTool] currentCreateSelectionMode];
    NSInteger tag = 0;
    if ([mode isEqualToString:@"BTMagicLassoCreateSelectionMode"])
        tag = 0;
    else if ([mode isEqualToString:@"BTMagicWandCreateSelectionMode"])
        tag = 1;
    else if ([mode isEqualToString:@"BTFreeHandCreateSelectionMode"])
        tag = 2;
    [_modeMatrix selectCellWithTag:tag];
}

- (id)regionEditingTool
{
    return [[[HSToolManager sharedToolManager] currentTool] bitmapTool];
}

- (void)didLoadNib
{
    [_modeMatrix setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
    [_modeMatrix setTarget:self];
    [_modeMatrix setDoubleAction:@selector(HSLassoSettingsViewController_selectAllArea:)];
}

- (void)didMount
{
    [super didMount];
    [self validateUserInterface];
}

- (id)nibName
{
    return @"LassoToolSettings";
}

@end
