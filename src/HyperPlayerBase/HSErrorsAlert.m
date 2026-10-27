#import "HSErrorsAlert.h"
@implementation HSErrorsAlert
- (void)setScriptErrors:(id)aErrors isSimpleView:(BOOL)aView
{
    [_errorsView setSimpleView:aView];
    [self setScriptErrors:aErrors];
}
- (void)setScriptErrors:(id)aErrors
{
    [_errorsView setScriptErrors:aErrors];
}
- (id)scriptErrors
{
    return [_errorsView scriptErrors];
}
- (void)dealloc
{
    [_errorsAlertView release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        if (_errorsView == nil)
            [EXBundleID loadNibNamed:@"HSErrorsAlertView" owner:self];
        [_errorsView removeFromSuperview];
        [self setCustomView:_errorsView];
        [self setIcon:[NSImage imageNamed:@"NSApplicationIcon"]];
    }
    return self;
}
@end
