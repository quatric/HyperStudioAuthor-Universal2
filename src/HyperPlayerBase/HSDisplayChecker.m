#import "HSDisplayChecker.h"
// Checks the main screen against a minimum size and colour depth; while it's
// below, a modal alert blocks the application.
@implementation HSDisplayChecker
- (void)setMinBitsPerPixel:(NSInteger)aPixel
{
    _minBitsPerPixel = (int)aPixel;
}
- (NSInteger)minBitsPerPixel
{
    return _minBitsPerPixel;
}
- (void)setMinWidth:(NSInteger)aWidth
{
    _minWidth = aWidth;
}
- (NSInteger)minWidth
{
    return (NSInteger)_minWidth;
}
- (void)setMinHeight:(NSInteger)aHeight
{
    _minHeight = aHeight;
}
- (NSInteger)minHeight
{
    return (NSInteger)_minHeight;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_alert release];
    [super dealloc];
}
- (void)synhronise
{
    NSScreen *screen = [NSScreen mainScreen];
    NSRect frame = [screen frame];
    _currentHeight = frame.size.height;
    _currentWidth = frame.size.width;
    _currentBitsPerPixel = (int)NSBitsPerPixelFromDepth([screen depth]);
}
// Too small: run the alert modally. It returns once the screen is big enough
// again: this method is called again inside the modal loop and stops it. As in
// the original, the alert is released at the end of every call; the inner call
// releases it while the outer runModal is still running, so it's retained
// around runModal here (bug fix).
- (void)screenParametersDidChange:(id)aChange
{
    [self synhronise];
    BOOL tooSmall = _currentWidth < [self minWidth] || _currentHeight < [self minHeight] || _currentBitsPerPixel < [self minBitsPerPixel];
    if (tooSmall) {
        if (!_isBlocked) {
            _isBlocked = YES;
            if (_alert == nil)
                _alert = [HSDisplayCheckerAlert new];
            id alert = [_alert retain];
            [alert runModal];
            [alert release];
        }
    } else if (_isBlocked) {
        _isBlocked = NO;
        [_alert stopModal];
    }
    [_alert release];
    _alert = nil;
}
- (void)checkMinSpec
{
    [self screenParametersDidChange:nil];
    [super checkMinSpec];
}
- (id)init
{
    self = [super init];
    if (self != nil)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenParametersDidChange:) name:NSApplicationDidChangeScreenParametersNotification object:NSApp];
    return self;
}
@end
