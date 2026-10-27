#import "HyperPlayerBasePrefix.h"


@interface HSEnvironmentJSObject : NSObject <HSScriptObject, HyperInterface, NSObject>
{
    HSStack *_stack;
}
+ (id)webScriptNameForSelector:(SEL)aSelector;
+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aScript;
- (void)setDocument:(id)aDocument;
- (id)document;
- (id)testTracker;
- (id)invokeUndefinedMethodFromWebScript:(id)aScript withArguments:(id)aArguments;
- (void)setScriptFilePath:(id)aPath;
- (id)scriptFilePath;
- (id)hyperScriptKind;
- (id)hyperScriptName;
- (id)hyperScriptDisplayName;
- (void)dealloc;
@end

