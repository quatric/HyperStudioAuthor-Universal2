#import "HSJavaScriptBridgeTiger.h"
@implementation HSJavaScriptBridgeTiger
- (void)dealloc
{
    [super dealloc];
}
- (id)init
{
    return [super init];
}
// The bridge's JavaScript object is a WebView with the main HTML page; it's
// ready once the page finished loading.
- (void)setValue:(id)aValue forKey:(id)aKey
{
    [[[self javaScriptObject] windowScriptObject] setValue:aValue forKey:aKey];
}
- (id)evaluateWebScript:(id)aScript
{
    return [[[self javaScriptObject] windowScriptObject] evaluateWebScript:aScript];
}
- (void)webViewProgressFinishedNotification:(id)aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:WebViewProgressFinishedNotification object:[aNotification object]];
    if ([[self delegate] respondsToSelector:@selector(javaScriptBridgeDidReady:)])
        [[self delegate] javaScriptBridgeDidReady:self];
}
- (void)load
{
    [self setJavaScriptObject:[[[WebView alloc] init] autorelease]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewProgressFinishedNotification:)
                                                 name:WebViewProgressFinishedNotification object:[self javaScriptObject]];
    NSString *path = [self mainHTMLPath];
    [[[self javaScriptObject] mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
}
@end
