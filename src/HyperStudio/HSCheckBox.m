#import "HSCheckBox.h"

@implementation HSCheckBox

+ (Class)cellClass
{
    return [HSCheckBoxCell class];
}

- (void)setDisabledPushedCheckBoxImage:(id)aImage
{
    [[self cell] setDisabledPushedButtonImage:aImage];
}

- (id)disabledPushedCheckBoxImage
{
    return [[self cell] disabledPushedButtonImage];
}

- (void)setDisabledCheckBoxImage:(id)aImage
{
    [[self cell] setDisabledButtonImage:aImage];
}

- (id)disabledCheckBoxImage
{
    return [[self cell] disabledButtonImage];
}

- (void)setCheckBoxPushedImage:(id)aImage
{
    [[self cell] setPushedButtonImage:aImage];
}

- (id)checkBoxPushedImage
{
    return [[self cell] pushedButtonImage];
}

- (void)setCheckBoxImage:(id)aImage
{
    [[self cell] setButtonImage:aImage];
}

- (id)checkBoxImage
{
    return [[self cell] buttonImage];
}

- (void)awakeFromNib
{
    [self setCell:[NSCell hyperCellOfClass:[HSCheckBox cellClass] withCell:[self cell]]];
}

@end
