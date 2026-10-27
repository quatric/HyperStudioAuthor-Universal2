#import "HyperPlayerBasePrefix.h"


@interface HSErrorsAlertView : NSView
{
    HSErrorsAlertTextView *_textView;
    NSScrollView *_scrollView;
    NSButton *_expandButton;
    NSTextField *_title;
    unsigned int _errorsNumber;
    NSSize _viewExpandedSize;
    NSArray *_scriptErrors;
    BOOL _isSimpleView;
}
- (void)setSimpleView:(BOOL)aView;
- (void)setScriptErrors:(id)aErrors;
- (id)scriptErrors;
- (id)pathForResource:(id)aResource;
- (void)setupOutput;
- (void)showTextView;
- (void)hideTextView;
- (void)setTitleText:(id)aText;
- (id)titleText;
- (void)viewWillMoveToWindow:(id)aWindow;
- (void)dealloc;
@end

@interface HSErrorsAlertView (IBActions)
- (void)onExpand:(id)aExpand;
@end

