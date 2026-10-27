#import "HSControlslImageProvider.h"

static HSControlslImageProvider *sharedImageProvider;

@implementation HSControlslImageProvider

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized (self) {
        if (sharedImageProvider == nil) {
            sharedImageProvider = [super allocWithZone:aZone];
            return sharedImageProvider;
        }
    }
    return nil;
}

+ (id)sharedImageProvider
{
    @synchronized (self) {
        if (sharedImageProvider == nil)
            [[self alloc] init];
    }
    return sharedImageProvider;
}

- (id)popUpButtonEditableFillPressedImage
{
    return [self popUpButtonEditableFillImage];
}

- (id)popUpButtonEditableRightCapPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_editable_right_pressed"] retain];
    return image;
}

- (id)popUpButtonEditableLeftCapPressedImage
{
    return [self popUpButtonEditableLeftCapImage];
}

- (id)popUpButtonEditableFillImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_editable_fill"] retain];
    return image;
}

- (id)popUpButtonEditableRightCapImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_editable_right"] retain];
    return image;
}

- (id)popUpButtonEditableLeftCapImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_editable_left"] retain];
    return image;
}

- (id)popUpButtonFillDisabledImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_fill_disabled"] retain];
    return image;
}

- (id)popUpButtonRightCapDisabledImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_right_disabled"] retain];
    return image;
}

- (id)popUpButtonLeftCapDisabledImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_left_disabled"] retain];
    return image;
}

- (id)popUpButtonFillPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_fill_pressed"] retain];
    return image;
}

- (id)popUpButtonRightCapPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_right_pressed"] retain];
    return image;
}

- (id)popUpButtonLeftCapPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_left_pressed"] retain];
    return image;
}

- (id)popUpButtonFillImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_fill"] retain];
    return image;
}

- (id)popUpButtonRightCapImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_right"] retain];
    return image;
}

- (id)popUpButtonLeftCapImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"popup_left"] retain];
    return image;
}

- (id)stepperNoPressedDisabledImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"stepper_disabled"] retain];
    return image;
}

- (id)stepperDownPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"stepper_down_pressed"] retain];
    return image;
}

- (id)stepperUpPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"stepper_up_pressed"] retain];
    return image;
}

- (id)stepperNoPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"stepper_no_pressed"] retain];
    return image;
}

// Original quirk kept: the pressed and normal circle images are swapped.
- (id)sliderBlueCirclePressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider_circle"] retain];
    return image;
}

- (id)sliderBlueCircleImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider_circle_press"] retain];
    return image;
}

- (id)sliderAboveBlueTrianglePressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider_a_triangle_press"] retain];
    return image;
}

- (id)sliderAboveBlueTriangleImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider_a_triangle"] retain];
    return image;
}

- (id)sliderBelowBlueTrianglePressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider_b_triangle_press"] retain];
    return image;
}

- (id)sliderBelowBlueTriangleImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider_b_triangle"] retain];
    return image;
}

- (id)sliderPressedWithMarksImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider_with_marks_pressed"] retain];
    return image;
}

- (id)sliderWithMarksImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider_with_marks"] retain];
    return image;
}

- (id)sliderPressedWithoutMarksImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider_pressed"] retain];
    return image;
}

- (id)sliderWithoutMarksImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"slider"] retain];
    return image;
}

- (id)verticalScrollerBottomKnobImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_knob_btm"] retain];
    return image;
}

- (id)verticalScrollerMiddleKnobImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_knob_midl"] retain];
    return image;
}

- (id)verticalScrollerTopKnobImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_knob_top"] retain];
    return image;
}

- (id)verticalScrollerMiddleImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_middle"] retain];
    return image;
}

- (id)verticalScrollerTopImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_top"] retain];
    return image;
}

- (id)verticalScrollerTogetherUpPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_tog_up_p"] retain];
    return image;
}

- (id)verticalScrollerTogetherUpImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_tog_up"] retain];
    return image;
}

- (id)verticalScrollerUpPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_up_press"] retain];
    return image;
}

- (id)verticalScrollerUpImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_up"] retain];
    return image;
}

- (id)verticalScrollerTogetherDownPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vert_tog_down_p"] retain];
    return image;
}

- (id)verticalScrollerTogetherDownImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vert_tog_down"] retain];
    return image;
}

- (id)verticalScrollerDownPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vert_down_press"] retain];
    return image;
}

- (id)verticalScrollerDownImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"scroller_vertical_down"] retain];
    return image;
}

- (id)radioButtonDisabledPushedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"radio_button_disabled_pushed"] retain];
    return image;
}

- (id)radioButtonDisabledImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"radio_button_disabled"] retain];
    return image;
}

- (id)radioButtonPushedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"radio_button_pushed"] retain];
    return image;
}

- (id)radioButtonImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"radio_button"] retain];
    return image;
}

- (id)checkBoxDisabledPushedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"checkbox_disabled_pushed"] retain];
    return image;
}

- (id)checkBoxDisabledImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"checkbox_disabled"] retain];
    return image;
}

- (id)checkBoxPushedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"checkbox_pushed"] retain];
    return image;
}

- (id)checkBoxImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"checkbox"] retain];
    return image;
}

- (id)buttonFillDisabledImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"button_central_disabled"] retain];
    return image;
}

- (id)buttonRightCapDisabledImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"button_right_disabled"] retain];
    return image;
}

- (id)buttonLeftCapDisabledImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"button_left_disabled"] retain];
    return image;
}

- (id)buttonFillPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"button_central_pressed"] retain];
    return image;
}

- (id)buttonRightCapPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"button_right_pressed"] retain];
    return image;
}

- (id)buttonLeftCapPressedImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"button_left_pressed"] retain];
    return image;
}

- (id)buttonFillImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"button_central"] retain];
    return image;
}

- (id)buttonRightCapImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"button_right"] retain];
    return image;
}

- (id)buttonLeftCapImage
{
    static NSImage *image;
    if (image == nil)
        image = [[self imageWithName:@"button_left"] retain];
    return image;
}

- (id)imageWithName:(id)aName
{
    NSBundle *bundle = [NSBundle bundleForClass:[HSControlslImageProvider class]];
    NSString *path = [bundle pathForResource:aName ofType:@"pdf"];
    if (path == nil)
        path = [[NSBundle bundleForClass:[HSControlslImageProvider class]] pathForResource:aName ofType:@"tiff"];
    return [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
}

- (id)autorelease
{
    return self;
}

- (oneway void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
