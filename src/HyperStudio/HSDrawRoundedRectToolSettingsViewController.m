#import "HSDrawRoundedRectToolSettingsViewController.h"

@implementation HSDrawRoundedRectToolSettingsViewController

// Stores a unit rounded rectangle with the slider value as corner radius.
- (void)cornerRadiusSliderChangedValueTo:(CGFloat)aTo
{
    CGMutablePathRef path = CGPathCreateMutable();

    if (path != NULL) {
        CGFloat r = aTo;
        CGFloat inner = 1.0f - r;

        [(id)path autorelease];
        CGPathMoveToPoint(path, NULL, r, 0.0f);
        CGPathAddArcToPoint(path, NULL, 0.0f, 0.0f, 0.0f, r, r);
        CGPathAddLineToPoint(path, NULL, 0.0f, inner);
        CGPathAddArcToPoint(path, NULL, 0.0f, 1.0f, r, 1.0f, r);
        CGPathAddLineToPoint(path, NULL, inner, 1.0f);
        CGPathAddArcToPoint(path, NULL, 1.0f, 1.0f, 1.0f, inner, r);
        CGPathAddLineToPoint(path, NULL, 1.0f, r);
        CGPathAddArcToPoint(path, NULL, 1.0f, 0.0f, inner, 0.0f, r);
        CGPathCloseSubpath(path);

        HSToolManager *manager = [HSToolManager sharedToolManager];
        [[manager toolSettings] setSetting:[NSBezierPath hyperBezierPathWithCGPath:path]
                             forIdentifier:[[[HSToolManager sharedToolManager] currentTool] primarySettingsIdentifier]
                                    andKey:@"path"];
    }
    [self refreshPreviews];
}

- (id)accessibilitySliderDescriptionValue
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"rounded rectangle" value:@"" table:@"ToolPalette"];
}

- (id)shapeTypeControlFillWithOutlineImage
{
    return [NSImage imageNamed:@"Stroke+Fill_RoundedRectangle"];
}

- (id)shapeTypeControlFillImage
{
    return [NSImage imageNamed:@"Fill_RoundedRectangle"];
}

- (id)shapeTypeControlOutlineImage
{
    return [NSImage imageNamed:@"Stroke_RoundedRectangle"];
}

- (void)updateUI
{
    [super updateUI];

    id settings = [[[HSToolManager sharedToolManager] toolSettings] settingsForTool:[[HSToolManager sharedToolManager] currentTool]];
    id path = [NSObject objectWithExtraDictionary:[settings objectForKey:@"path"]];
    if (path != nil)
        [_cornerRadiusSlider setFloatValue:[path hyperBasePointOfElementAtIndex:0].x];
}

// Grows the settings view by the corner settings and stacks them above the container.
- (void)didLoadNib
{
    NSRect frame = [[self toolSettingsView] frame];
    NSRect corner = [_cornerSettingsView frame];

    [[self toolSettingsView] setFrameSize:NSMakeSize(frame.size.width, frame.size.height + corner.size.height)];
    frame = [_containerView frame];
    corner = [_cornerSettingsView frame];
    [_containerView setFrameSize:NSMakeSize(frame.size.width, frame.size.height - corner.size.height)];
    frame = [_containerView frame];
    [_cornerSettingsView setFrameOrigin:NSMakePoint(NSZeroPoint.x, frame.size.height + 1.0f)];
    [[self toolSettingsView] addSubview:_cornerSettingsView];
    [super didLoadNib];
}

@end
