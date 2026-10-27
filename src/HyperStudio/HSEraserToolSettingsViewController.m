#import "HSEraserToolSettingsViewController.h"

@implementation HSEraserToolSettingsViewController

- (void)actionEraseBackground:(id)aBackground
{
    id attributes = [[[HSToolManager sharedToolManager] currentTool] currentEditableImageAttributes];
    if (attributes == nil)
        return;
    Protocol *required[] = { @protocol(BTCocoaMutableImage), nil };
    id image = [attributes queryImageWithRequiredProtocols:required optionalProtocols:NULL];
    if (image == nil)
        return;
    NSSize size = [image imageSize];
    NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
    [[[[self toolView] card] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Erase Background" value:@"" table:@"UndoManager"]];
    [attributes beginEditImage:image inRect:rect];
    [image beginCocoaEditing];
    [(NSColor *)[[[HSToolManager sharedToolManager] toolSettings] eraserColor] set];
    [NSBezierPath fillRect:rect];
    [image endCocoaEditing];
    [attributes endEditImage];
}

- (id)colorPickingController
{
    return [[self toolView] queryHyperInterface:@protocol(HSColorPickingController)];
}

- (void)colorViewController:(id)aController changedColorTo:(id)aTo
{
    [[[HSToolManager sharedToolManager] toolSettings] setEraserColor:aTo];
}

- (BOOL)shouldDisplayGradientsAndPattersForColorViewController:(id)aController
{
    return NO;
}

- (void)updateEraserSize
{
    float size = [_eraserSizeSlider floatValue];
    [[[HSToolManager sharedToolManager] toolSettings] setEraserSize:NSMakeSize(size, size)];
}

- (void)eraserSizeChanged:(id)aChanged
{
    [self updateEraserSize];
}

- (void)validateUserInterface
{
    [super validateUserInterface];
    [_colorViewController validateUserInterface];
}

- (void)updateUI
{
    [_colorViewController setColor:[[[HSToolManager sharedToolManager] toolSettings] eraserColor]];
    [_eraserSizeSlider setFloatValue:[[[HSToolManager sharedToolManager] toolSettings] eraserSize].width];
}

- (void)willUnMount
{
    [super willUnMount];
    [_colorViewController setShouldShowsAlphaInActivePanel:_previousShouldShowsAlphaFlag];
}

- (void)didMount
{
    [super didMount];
    _previousShouldShowsAlphaFlag = [_colorViewController shouldShowsAlphaInActivePanel];
    [_colorViewController setShouldShowsAlphaInActivePanel:NO];
    [self updateUI];
}

- (id)eraserTool
{
    return [[[HSToolManager sharedToolManager] currentTool] bitmapTool];
}

- (void)didLoadNib
{
    [_colorViewController setDelegate:self];
    [[_colorViewController eraserColorView] setFrame:[_colorContainerView bounds]];
    [_colorContainerView addSubview:[_colorViewController eraserColorView]];
    [[_colorViewController crayonsView] setNeedsForceLayout:YES];
    [_colorViewController setGradientSupportEnabled:NO];
    [_colorViewController setPatternSupportEnabled:NO];
}

- (id)nibName
{
    return @"EraserToolSettings";
}

- (void)dealloc
{
    [_colorViewController release];
    [super dealloc];
}

@end
