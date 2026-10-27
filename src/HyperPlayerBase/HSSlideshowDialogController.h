#import "HyperPlayerBasePrefix.h"
#import "HSGenericModalController.h"


@interface HSSlideshowDialogController : HSGenericModalController
{
    HSSlideshowAttributes *_slideshowAttributes;
    NSMatrix *_loopModeMatrix;
    NSMatrix *_advanceRuleMatrix;
    NSTextField *_delayTextField;
    NSStepper *_delayStepper;
}
- (void)applyChanges;
- (void)delayDidChange:(id)aChange;
- (void)advanceRuleDidChange:(id)aChange;
- (void)willShowWindow;
- (void)setDefaultSlideshowAttributesToBeCustomized:(id)aCustomized;
- (id)slideshowAttributes;
- (id)nibName;
- (void)dealloc;
@end

