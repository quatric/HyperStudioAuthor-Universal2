#import "HyperPlayerBasePrefix.h"
#import "HSAlert.h"


@interface HSErrorsAlert : HSAlert
{
    NSView *_errorsAlertView;
    HSErrorsAlertView *_errorsView;
}
- (void)setScriptErrors:(id)aErrors isSimpleView:(BOOL)aView;
- (void)setScriptErrors:(id)aErrors;
- (id)scriptErrors;
- (void)dealloc;
- (id)init;
@end

