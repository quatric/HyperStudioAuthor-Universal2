#import "HyperStudioPrefix.h"


@interface HSRadioButton : NSButton
{
}
+ (Class)cellClass;
- (void)setDisabledPushedRadioButtonImage:(id)aImage;
- (id)disabledPushedRadioButtonImage;
- (void)setDisabledRadioButtonImage:(id)aImage;
- (id)disabledRadioButtonImage;
- (void)setRadioButtonPushedImage:(id)aImage;
- (id)radioButtonPushedImage;
- (void)setRadioButtonImage:(id)aImage;
- (id)radioButtonImage;
- (void)awakeFromNib;
@end

