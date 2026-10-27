#import "HSStreamRenderer.h"
@implementation HSStreamRenderer
// The original initialized QuickTime here (EnterMovies); nothing to do now.
+ (void)initialize
{
}
- (void)setEnabled:(BOOL)aEnabled
{
    _isEnabled = aEnabled;
}
- (BOOL)isEnabled
{
    return _isEnabled;
}
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (id)delegate
{
    return _delegate;
}
@end
