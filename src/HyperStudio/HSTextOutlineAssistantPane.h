#import "HyperStudioPrefix.h"
#import "HSCommentsTextView.h"


@interface HSTextOutlineAssistantPane : HSObjectAssistantPane
{
    HSGradientColorWell *_outlineColorWell;
    HSSegmentedControl *_outlineTypeMatrix;
    id<HSSystemTextViewAttributes> _observedTextViewAttributes;
    id<HSTextObjectAttributes> _observedTextObjectAttributes;
    HSObjectAssistantNavigationPaneSwitcher *_navigationPaneSwitcher;
    BOOL _userMadeTheDecision;
}
- (void)validateUI;
- (void)validateOutlineMatrix;
- (void)validateUIWithNotification:(id)aNotification;
- (void)outlineTypeChanged:(id)aChanged;
- (void)outlineColorChanged:(id)aChanged;
- (id)helpTopicKey;
- (id)outlineAttributes;
- (void)paneDidCancel:(id)aCancel;
- (void)paneDidOK:(id)aOK;
- (void)viewWillDisappear:(BOOL)aDisappear;
- (void)viewWillAppear:(BOOL)aAppear;
- (void)setObservedTextObjectAttributes:(id)aAttributes;
- (void)setObservedTextViewAttributes:(id)aAttributes;
- (id)assistantPaneUndoManager;
- (void)viewDidLoad;
- (BOOL)requiresDarkBottomArea;
- (id)navigationPaneSwitcher;
- (void)dealloc;
- (id)init;
@end

