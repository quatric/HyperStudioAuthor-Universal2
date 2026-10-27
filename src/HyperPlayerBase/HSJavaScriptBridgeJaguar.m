#import "HSJavaScriptBridgeJaguar.h"
// The JavaScript bridge of 10.2: a SMKWebBridge from the SMKWebCore
// framework (not shipped any more, so -load finds nothing), which needs the
// page's script files prepended to every script.
@implementation HSJavaScriptBridgeJaguar
+ (id)SMKWebCoreFramework
{
    NSString *path = [[[NSBundle mainBundle] privateFrameworksPath] stringByAppendingPathComponent:@"SMKWebCore.framework"];
    NSBundle *framework = [NSBundle bundleWithPath:path];
    if (framework == nil) {
        path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES) lastObject]
                stringByAppendingPathComponent:@"Frameworks/SMKWebCore.framework"];
        framework = [NSBundle bundleWithPath:path];
    }
    return framework;
}
- (void)dealloc
{
    [super dealloc];
}
- (id)init
{
    return [super init];
}
- (void)setValue:(id)aValue forKey:(id)aKey
{
    [[self javaScriptObject] setValue:aValue forKey:aKey];
}
- (id)evaluateWebScript:(id)aScript
{
    NSMutableString *script = [NSMutableString string];
    [script appendFormat:@"%@\n%@", [self _libraryScript], aScript];
    return [[self javaScriptObject] stringByEvaluatingJavaScriptFromString:script];
}
- (void)load
{
    NSBundle *framework = [[self class] SMKWebCoreFramework];
    if (framework == nil || ![framework load])
        return;
    Class bridgeClass = NSClassFromString(@"SMKWebBridge");
    if (bridgeClass == Nil)
        return;
    [self setJavaScriptObject:[[[bridgeClass allocWithZone:[self zone]] init] autorelease]];
    if ([_delegate respondsToSelector:@selector(javaScriptBridgeDidReady:)])
        [_delegate javaScriptBridgeDidReady:self];
}
// The contents of the script files the main page includes, read once.
- (id)_libraryScript
{
    static NSString *libraryScript = nil;
    if (libraryScript == nil) {
        NSMutableString *script = [NSMutableString string];
        NSString *html = [NSString stringWithContentsOfFile:[self mainHTMLPath]];
        NSArray *lines = [html componentsSeparatedByString:@"\n"];
        int count = (int)[lines count];
        NSString *prefix = @"<script language=\"JavaScript\" src=\"";
        for (int i = 0; i < count; i++) {
            NSString *line = [lines objectAtIndex:i];
            NSRange start = [line rangeOfString:prefix];
            NSRange end = [line rangeOfString:@"\"></script>"];
            if (start.location == NSNotFound || end.location == NSNotFound)
                continue;
            NSUInteger nameStart = start.location + [prefix length];
            NSString *name = [line substringWithRange:NSMakeRange(nameStart, end.location - nameStart)];
            NSString *path = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]];
            [script appendFormat:@"\n%@", [NSString stringWithContentsOfFile:path]];
        }
        libraryScript = [script copy];
    }
    return libraryScript;
}
@end
