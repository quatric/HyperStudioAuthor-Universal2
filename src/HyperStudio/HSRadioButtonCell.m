#import "HSRadioButtonCell.h"

@implementation HSRadioButtonCell

- (NSRect)drawTitle:(id)aTitle withFrame:(NSRect)aFrame inView:(id)aView
{
    return [super drawTitle:aTitle withFrame:NSOffsetRect(NSInsetRect(aFrame, 1.0, 0.0), 2.0, 0.0) inView:aView];
}

- (void)loadDefaultImages
{
    HSControlslImageProvider *provider = [HSControlslImageProvider sharedImageProvider];
    [self setButtonImage:[provider radioButtonImage]];
    [self setPushedButtonImage:[provider radioButtonPushedImage]];
    [self setDisabledButtonImage:[provider radioButtonDisabledImage]];
    [self setDisabledPushedButtonImage:[provider radioButtonDisabledPushedImage]];
    [self setImage:[self buttonImage]];
}

@end
