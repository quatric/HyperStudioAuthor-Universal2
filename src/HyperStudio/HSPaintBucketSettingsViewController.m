#import "HSPaintBucketSettingsViewController.h"

@implementation HSPaintBucketSettingsViewController

- (void)actionToleranceChanged:(id)aChanged
{
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    id toolSettings = [toolManager toolSettings];
    id identifier = [[toolManager currentTool] toolIdentifier];
    [toolSettings setSetting:[NSNumber numberWithFloat:1.0f - [aChanged floatValue]] forIdentifier:identifier andKey:@"tolerance"];
}

- (id)colorPickingController
{
    return [[self toolView] queryHyperInterface:@protocol(HSColorPickingController)];
}

- (void)colorViewController:(id)aController changedColorTo:(id)aTo
{
    [(NSResponder *)[[[HSToolManager sharedToolManager] currentTool] bitmapTool] doCommandBySelector:@selector(finalize:)];
    [[[HSToolManager sharedToolManager] toolSettings] setDrawColor:aTo];
    [self updateBrushColor];
}

- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController
{
    return YES;
}

- (void)validateUserInterface
{
    [super validateUserInterface];
    [_colorViewController validateUserInterface];
}

- (void)updateBrushColor
{
    [_colorViewController setColor:[[[HSToolManager sharedToolManager] toolSettings] drawColor]];
}

- (void)updateUI
{
    [self updateBrushColor];
    HSToolManager *toolManager = [HSToolManager sharedToolManager];
    id settings = [[toolManager toolSettings] settingsForTool:[toolManager currentTool]];
    [_tolerenceSlider setFloatValue:1.0f - [[settings valueForKey:@"tolerance"] floatValue]];
}

- (void)didMount
{
    [super didMount];
    [self updateUI];
}

- (void)didLoadNib
{
    [_colorViewController setDelegate:self];
    [[_colorViewController colorView] setFrame:[_colorContainerView bounds]];
    [_colorContainerView addSubview:[_colorViewController colorView]];
    [[_colorViewController crayonsView] setNeedsForceLayout:YES];
}

- (id)nibName
{
    return @"PaintBucketToolSettings";
}

- (void)dealloc
{
    [_colorViewController release];
    [super dealloc];
}

@end
