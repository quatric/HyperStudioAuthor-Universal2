#import "HSGridSetupDialogController.h"

@implementation HSGridSetupDialogController

- (void)resetToDefaults:(id)aDefaults
{
    [_gridPreview resetToDefaults];
    [self setupUIElementsWithGridSettings:_gridPreview];
}

- (void)verticalSpacingDidChange:(id)aChange
{
    if (aChange == _verticalSpacing)
        [_verticalStepper setIntValue:[aChange intValue]];
    else
        [_verticalSpacing setIntValue:[_verticalStepper intValue]];
    [self settingsDidChange:aChange];
}

- (void)horizontalSpacingDidChange:(id)aChange
{
    if (aChange == _horizontalSpacing)
        [_horizontalStepper setIntValue:[aChange intValue]];
    else
        [_horizontalSpacing setIntValue:[_horizontalStepper intValue]];
    [self settingsDidChange:aChange];
}

- (void)settingsDidChange:(id)aChange
{
    if ([self areSpacingFieldsValid])
        [self applySettingsTo:_gridPreview];
}

// Matrix rows run 0 = style 3, 1 = style 2, 2 = style 1.
- (void)setupUIElementsWithGridSettings:(id)aSettings
{
    [_displayCheckBox setState:[aSettings isGridVisible] ? NSControlStateValueOn : NSControlStateValueOff];
    [_snapToGridCheckBox setState:[aSettings isSnapToGridEnabled] ? NSControlStateValueOn : NSControlStateValueOff];
    NSInteger row = 0;
    switch ([aSettings markStyle]) {
        case 2: row = 1; break;
        case 1: row = 2; break;
    }
    [_gridMarkStyleMatrix selectCellAtRow:row column:0];
    [_gridColorWell setColor:[aSettings gridColor]];
    NSSize spacing = [[aSettings layoutGrid] gridSpacing];
    [_horizontalSpacing setFloatValue:spacing.width];
    [_verticalSpacing setFloatValue:spacing.height];
    [_horizontalStepper setFloatValue:spacing.width];
    [_verticalStepper setFloatValue:spacing.height];
    [_gridColorWell setGradientSupportEnabled:NO];
    [_gridColorWell setPatternSupportEnabled:NO];
}

- (void)applyChanges
{
    [self applySettingsTo:[[[[NSDocumentController sharedDocumentController] currentDocument] stack] gridSettings]];
    [super applyChanges];
}

- (BOOL)areSpacingFieldsValid
{
    float horizontal = [_horizontalSpacing floatValue];
    float vertical = [_verticalSpacing floatValue];
    NSRect imageRect = [[_context card] imageRect];
    if (horizontal >= 2.0f && vertical >= 2.0f && horizontal <= imageRect.size.width && vertical <= imageRect.size.height)
        return YES;
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSGridSettingsAlertTitle" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSGridSettingsAlertText" value:@"" table:@"Alerts"]];
    [alert runModal];
    [alert release];
    return NO;
}

- (void)ok:(id)aOk
{
    if ([self areSpacingFieldsValid])
        [super ok:aOk];
}

- (void)willShowWindow
{
    id settings = [[[[NSDocumentController sharedDocumentController] currentDocument] stack] gridSettings];
    [_gridPreview updateWithObject:settings];
    [self setupUIElementsWithGridSettings:settings];
}

- (void)applySettingsTo:(id)aTo
{
    [aTo setGridVisible:[_displayCheckBox state] == NSControlStateValueOn];
    [aTo setIsSnapToGridEnabled:[_snapToGridCheckBox state] == NSControlStateValueOn];
    NSInteger row = [_gridMarkStyleMatrix selectedRow];
    [aTo setMarkStyle:row == 1 ? 2 : row == 2 ? 1 : 3];
    [aTo setGridColor:[_gridColorWell color]];
    [[aTo layoutGrid] setGridSpacing:NSMakeSize([_horizontalSpacing floatValue], [_verticalSpacing floatValue])];
}

- (void)dealloc
{
    [_context release];
    [super dealloc];
}

- (id)initWithContext:(id)aContext
{
    self = [super init];
    if (self != nil)
        _context = [aContext retain];
    return self;
}

- (id)nibName
{
    return @"HSGridSetup";
}

@end
