#import "HSCheckBoxCell.h"

@implementation HSCheckBoxCell

- (void)loadDefaultImages
{
    HSControlslImageProvider *provider = [HSControlslImageProvider sharedImageProvider];
    [self setButtonImage:[provider checkBoxImage]];
    [self setPushedButtonImage:[provider checkBoxPushedImage]];
    [self setDisabledButtonImage:[provider checkBoxDisabledImage]];
    [self setDisabledPushedButtonImage:[provider checkBoxDisabledPushedImage]];
    [self setImage:[self buttonImage]];
}

@end
