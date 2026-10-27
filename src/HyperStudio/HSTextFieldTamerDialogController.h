#import "HyperStudioPrefix.h"
#import "HSExtraModalController.h"


@interface HSTextFieldTamerDialogController : HSExtraModalController
{
    NSMatrix *_switchStackCard;
    NSMatrix *_switchReadWrite;
}
- (void)applyChanges;
- (void)willShowWindow;
- (id)nibName;
@end

