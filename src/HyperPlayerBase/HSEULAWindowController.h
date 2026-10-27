#import "HyperPlayerBasePrefix.h"


@interface HSEULAWindowController : NSWindowController
{
    NSTextField *_eulaTitleField;
    NSTextView *_eulaTextView;
}
- (void)setEULAAttributedString:(id)aString;
- (void)setEULATitle:(id)aTitle;
- (void)setEULAWindowTitle:(id)aTitle;
- (void)disagree:(id)aDisagree;
- (void)agree:(id)aAgree;
- (id)windowNibName;
@end

