#import "HyperPlayerBasePrefix.h"


@interface HSWebAuthenticationPanel : NSObject
{
    id _mainLabel;
    id _panel;
    id _password;
    id _smallLabel;
    id _username;
    id _imageView;
    id _remember;
    BOOL _nibLoaded;
    id _callback;
    SEL _selector;
    NSURLAuthenticationChallenge *_challenge;
}
- (void)runAsModalDialogWithChallenge:(id)aChallenge;
- (void)setUpForChallenge:(id)aChallenge;
- (BOOL)loadNib;
- (void)logIn:(id)aIn;
- (void)cancel:(id)aCancel;
- (void)dealloc;
- (id)initWithCallback:(id)aCallback selector:(SEL)aSelector;
@end

@interface NSControl (HSWebExtras)
- (void)sizeToFitAndAdjustWindowHeight;
@end

