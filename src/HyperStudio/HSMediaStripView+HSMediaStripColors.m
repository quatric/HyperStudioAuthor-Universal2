#import "HSMediaStripView+HSMediaStripColors.h"

@implementation HSMediaStripView (HSMediaStripColors)

+ (id)activeOutlineBackgroundColor
{
    return [NSColor colorWithCalibratedWhite:1.0 alpha:0.25];
}

+ (id)activeOutlineColor
{
    return [NSColor colorWithCalibratedWhite:1.0 alpha:0.55f];
}

+ (id)dropIndicatorColor
{
    return [NSColor redColor];
}

+ (id)textColorSelected:(BOOL)aSelected firstResponder:(BOOL)aResponder
{
    return [self imageBorderColorSelected:aSelected firstResponder:!aResponder];
}

+ (id)imageBorderColorSelected:(BOOL)aSelected firstResponder:(BOOL)aResponder
{
    return aSelected && aResponder ? [NSColor redColor] : [NSColor whiteColor];
}

+ (id)borderColor
{
    return [NSColor lightGrayColor];
}

+ (id)bezelColor
{
    return [NSColor whiteColor];
}

+ (id)stripBackgroundColor
{
    return [NSColor whiteColor];
}

@end
