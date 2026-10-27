#import "HyperStudioPrefix.h"
#import "HSToolSettingsViewController.h"


@interface HSEffectToolSettingsViewController : HSToolSettingsViewController
{
    HSCustomTabView *_tabView;
    SMKGridControl *_gridControl;
    NSImageView *_effectPreview;
    NSTextField *_effectName;
    NSSlider *_effectIntencity;
}
- (void)updateUI;
- (void)didMount;
- (void)selectedTabDidChangeInCustomTabView:(id)aView;
- (void)selectionDidChangeInGridControl:(id)aControl;
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl additionalInfoForItemAt:(NSInteger)aAt;
- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt;
- (NSInteger)numberOfItemsInGridControl:(id)aControl;
- (Class)cellClass;
- (id)templateDictionaryAtIndex:(NSUInteger)aIndex;
- (void)effectIntencityChanged:(id)aChanged;
- (void)didLoadNib;
- (id)nibName;
- (void)dealloc;
@end

