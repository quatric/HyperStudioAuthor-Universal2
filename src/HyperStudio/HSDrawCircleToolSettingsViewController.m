#import "HSDrawCircleToolSettingsViewController.h"

@implementation HSDrawCircleToolSettingsViewController

- (id)accessibilitySliderDescriptionValue
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"oval" value:@"" table:@"ToolPalette"];
}

- (id)shapeTypeControlFillWithOutlineImage
{
    return [NSImage imageNamed:@"Stroke+Fill Elipse"];
}

- (id)shapeTypeControlFillImage
{
    return [NSImage imageNamed:@"Fill Elipse"];
}

- (id)shapeTypeControlOutlineImage
{
    return [NSImage imageNamed:@"Stroke Elipse"];
}

@end
