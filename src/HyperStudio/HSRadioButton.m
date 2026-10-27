#import "HSRadioButton.h"

@implementation HSRadioButton

+ (Class)cellClass
{
    return [HSRadioButtonCell class];
}

- (void)setDisabledPushedRadioButtonImage:(id)aImage
{
    [[self cell] setDisabledPushedButtonImage:aImage];
}

- (id)disabledPushedRadioButtonImage
{
    return [[self cell] disabledPushedButtonImage];
}

- (void)setDisabledRadioButtonImage:(id)aImage
{
    [[self cell] setDisabledButtonImage:aImage];
}

- (id)disabledRadioButtonImage
{
    return [[self cell] disabledButtonImage];
}

- (void)setRadioButtonPushedImage:(id)aImage
{
    [[self cell] setPushedButtonImage:aImage];
}

- (id)radioButtonPushedImage
{
    return [[self cell] pushedButtonImage];
}

- (void)setRadioButtonImage:(id)aImage
{
    [[self cell] setButtonImage:aImage];
}

- (id)radioButtonImage
{
    return [[self cell] buttonImage];
}

- (void)awakeFromNib
{
    [self setCell:[NSCell hyperCellOfClass:[HSRadioButton cellClass] withCell:[self cell]]];
}

@end
