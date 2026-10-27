#import "HyperStudioPrefix.h"


@interface HSAddSoundComboDialog : HSGenericModalController
{
    NSButton *_firstButton;
    NSButton *_secondButton;
    SEL _action;
}
- (void)recordSound:(id)aSound;
- (void)diskFile:(id)aFile;
- (SEL)action;
- (void)didLoadNib;
- (id)nibName;
@end

