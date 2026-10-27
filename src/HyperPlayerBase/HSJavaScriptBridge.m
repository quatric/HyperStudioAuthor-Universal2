#import "HSJavaScriptBridge.h"
// The bridge between stacks and JavaScript in a web view. Allocating the
// class itself gives the subclass for the installed WebKit: the Jaguar one
// for WebKit builds before 130, the Tiger one otherwise (always, today).
@implementation HSJavaScriptBridge
static BOOL sIsJaguar;
+ (id)allocWithZone:(NSZone *)aZone
{
    if ([HSJavaScriptBridge class] == self)
        return [([self _isJaguar] ? [HSJavaScriptBridgeJaguar class] : [HSJavaScriptBridgeTiger class]) allocWithZone:aZone];
    return [super allocWithZone:aZone];
}
+ (BOOL)_isJaguar
{
    NSDictionary *info = [[NSBundle bundleWithIdentifier:@"com.apple.WebKit"] infoDictionary];
    sIsJaguar = [[info objectForKey:(id)kCFBundleVersionKey] intValue] < 130;
    return sIsJaguar;
}
- (void)setMainHTMLPath:(id)aPath
{
    if (_mainHTMLPath != aPath) {
        [_mainHTMLPath release];
        _mainHTMLPath = [aPath retain];
    }
}
// Defaults to the page in the framework's resources.
- (id)mainHTMLPath
{
    if (_mainHTMLPath == nil)
        [self setMainHTMLPath:[[HSPlayerBaseID bundle] pathForResource:@"JavaScriptMainFile" ofType:@"html"]];
    return _mainHTMLPath;
}
- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}
- (id)delegate
{
    return _delegate;
}
- (void)setJavaScriptObject:(id)aObject
{
    if (_javaScriptObject != aObject) {
        [_javaScriptObject release];
        _javaScriptObject = [aObject retain];
    }
}
- (id)javaScriptObject
{
    return _javaScriptObject;
}
- (void)dealloc
{
    [_mainHTMLPath release];
    [_javaScriptObject release];
    [super dealloc];
}
- (id)init
{
    return [super init];
}
@end
