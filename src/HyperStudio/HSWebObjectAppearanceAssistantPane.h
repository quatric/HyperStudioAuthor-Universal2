#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSWebObjectAppearanceAssistantPane : HSObjectAssistantPane <NSTextViewDelegate, NSTextDelegate, NSObject>
{
    NSTextField *_nameTextField;
    NSTextView *_HTMLCodeTextView;
    NSTextField *_refreshRateTextField;
    HSStepper *_refreshRateStepper;
    id<HSMutableObjectAttributes> _objectAttributes;
    id<HSWebElementAttributes> _webElementAttributes;
}
- (void)setRefreshRate:(id)aRate;
- (void)setName:(id)aName;
- (void)textDidEndEditing:(id)aEditing;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)viewDidLoad;
- (void)HSWebObjectAppearanceAssistantPane_refreshRateDidChange:(id)aChange;
- (void)HSWebObjectAppearanceAssistantPane_HTMLCodeDidChange:(id)aChange;
- (void)HSWebObjectAppearanceAssistantPane_nameDidChange:(id)aChange;
- (id)init;
@end

