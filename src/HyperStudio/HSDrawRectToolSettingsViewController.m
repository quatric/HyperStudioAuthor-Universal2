#import "HSDrawRectToolSettingsViewController.h"

@implementation HSDrawRectToolSettingsViewController

- (id)accessibilitySliderDescriptionValue
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"rectangle" value:@"" table:@"ToolPalette"];
}

- (id)shapeTypeControlFillWithOutlineImage
{
    return [NSImage imageNamed:@"Stroke+Fill Square"];
}

- (id)shapeTypeControlFillImage
{
    return [NSImage imageNamed:@"Fill Square"];
}

- (id)shapeTypeControlOutlineImage
{
    return [NSImage imageNamed:@"Stroke Square"];
}

@end
