#import "HyperStudioPrefix.h"


@interface HSCheckBox : NSButton
{
}
+ (Class)cellClass;
- (void)setDisabledPushedCheckBoxImage:(id)aImage;
- (id)disabledPushedCheckBoxImage;
- (void)setDisabledCheckBoxImage:(id)aImage;
- (id)disabledCheckBoxImage;
- (void)setCheckBoxPushedImage:(id)aImage;
- (id)checkBoxPushedImage;
- (void)setCheckBoxImage:(id)aImage;
- (id)checkBoxImage;
- (void)awakeFromNib;
@end

