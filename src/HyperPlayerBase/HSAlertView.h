#import "HyperPlayerBasePrefix.h"


@interface HSAlertView : NSView <NSTextViewDelegate, NSTextDelegate, NSObject>
{
    NSView *_customView;
    HSNonOpaqueTextView *_messageTextView;
    HSNonOpaqueTextView *_informativeTextView;
    HSNonOpaqueTextView *_bottomInformativeTextView;
    NSButton *_doNotShowAgainCheckBox;
    NSString *_doNotShowAgainPreferenceKey;
    BOOL _layoutAll;
}
- (void)setFrameSize:(NSSize)aSize;
- (void)setDoNotShowAgainPreferenceKey:(id)aKey;
- (id)doNotShowAgainPreferenceKey;
- (void)HSAlertView_doNotShowAgain:(id)aAgain;
- (void)setBottomInformativeText:(id)aText;
- (id)bottomInformativeText;
- (void)setInformativeText:(id)aText;
- (id)informativeText;
- (void)setMessageText:(id)aText;
- (id)messageText;
- (void)setCustomView:(id)aView;
- (id)customView;
- (void)layout;
- (void)layoutAll;
- (NSSize)sizeForTextView:(id)aView;
- (void)setupTextView:(id)aView;
- (void)dealloc;
- (id)initWithFrame:(NSRect)aFrame;
@end

