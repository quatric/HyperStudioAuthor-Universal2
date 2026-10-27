#import "HSJavaScriptController.h"
#import <WebKit/WebKit.h>
#import "HSJavaScriptBridge.h"
#import "HSJavaScriptBridgeTiger.h"
#import "HSJavaScriptCodeUtils.h"

// Runs HyperStudio scripts in a JavaScript bridge (a web view): the stack's
// scriptable objects are mapped as globals, the sender as a local, and a
// result with an "abortContext" aborts the action, script, document,
// transition or application.
@implementation HSJavaScriptController

+ (id)buildUIDSetFromObjects:(id)aObjects
{
    NSMutableSet *UIDs = [NSMutableSet set];
    for (id object in aObjects) {
        id attributes = [object queryHyperInterface:@protocol(HSObjectAttributes)];
        if (attributes != nil)
            [UIDs addObject:[attributes hyperUID]];
    }
    return UIDs;
}

// Only setting it records the currently mapped objects.
- (void)setIsMapped:(BOOL)aMapped
{
    if (!aMapped)
        return;
    id UIDs = [[self class] buildUIDSetFromObjects:[[self dataSource] scriptControllerAllScriptObjects:self]];
    [_mappedUIDs release];
    _mappedUIDs = [UIDs retain];
}

// Mapped while the script objects are still the same.
- (BOOL)isMapped
{
    id UIDs = [[self class] buildUIDSetFromObjects:[[self dataSource] scriptControllerAllScriptObjects:self]];
    return [UIDs isEqualToSet:_mappedUIDs];
}

- (void)setJavaScriptBridge:(id)aBridge
{
    if (_javaScriptBridge == aBridge)
        return;
    if ([_javaScriptBridge delegate] == self)
        [_javaScriptBridge setDelegate:nil];
    [_javaScriptBridge release];
    _javaScriptBridge = [aBridge retain];
}

- (id)javaScriptBridge
{
    return _javaScriptBridge;
}

- (void)setIsWebKitSupportJavaScript:(BOOL)aScript
{
    _isWebKitSupportJavaScript = aScript;
}

- (BOOL)isWebKitSupportJavaScript
{
    return _isWebKitSupportJavaScript;
}

- (void)setIsScriptReady:(BOOL)aReady
{
    _isScriptReady = aReady;
}

- (BOOL)isScriptReady
{
    return _isScriptReady;
}

- (void)setScript:(id)aScript
{
    if (_script == aScript)
        return;
    [_script release];
    _script = [aScript retain];
}

- (id)script
{
    return _script;
}

- (void)setScriptObject:(id)aObject
{
    if (_scriptObject == aObject)
        return;
    [_scriptObject release];
    _scriptObject = [aObject retain];
}

- (id)scriptObject
{
    return _scriptObject;
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (id)dataSource
{
    return _dataSource;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)dealloc
{
    [_mappedUIDs release];
    [_javaScriptBridge setDelegate:nil];
    [_javaScriptBridge release];
    [_scriptObject release];
    [_script release];
    [_locals release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _isStartPreloading = NO;
    return self;
}

- (void)scriptFinish:(id)aFinish
{
    // Fixed: this checked for the did-start delegate method before calling
    // the did-finish one.
    if ([_delegate respondsToSelector:@selector(scriptController:didFinishWithScript:)])
        [_delegate scriptController:self didFinishWithScript:aFinish];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSScriptControllerDidFinishNotification" object:self userInfo:[NSDictionary dictionaryWithObject:aFinish forKey:@"HSScriptKey"]];
}

- (void)scriptStart:(id)aStart
{
    if ([_delegate respondsToSelector:@selector(scriptController:didStartWithScript:)])
        [_delegate scriptController:self didStartWithScript:aStart];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSScriptControllerDidStartNotification" object:self userInfo:[NSDictionary dictionaryWithObject:aStart forKey:@"HSScriptKey"]];
}

- (void)processAbortApplication:(id)aApplication
{
    if ([_delegate respondsToSelector:@selector(scriptControllerApplicationClose:)])
        [_delegate scriptControllerApplicationClose:self];
}

- (void)processAbortTransite:(id)aTransite
{
    NSURL *URL = [NSURL fileURLWithPath:[[aTransite valueForKey:@"newStackPath"] description]];
    if ([_delegate respondsToSelector:@selector(scriptController:transiteToURL:)])
        [_delegate scriptController:self transiteToURL:URL];
}

- (void)processAbortDocument:(id)aDocument
{
    if ([_delegate respondsToSelector:@selector(scriptControllerDocumentClose:)])
        [_delegate scriptControllerDocumentClose:self];
}

- (void)processAbortScript:(id)aScript
{
}

// Dispatches to processAbort<abortContext>:.
- (void)processAbortAction:(id)aAction
{
    NSString *name = [NSString stringWithFormat:@"processAbort%@:", [[aAction valueForKey:@"abortContext"] description]];
    SEL selector = NSSelectorFromString(name);
    if ([self respondsToSelector:selector])
        [self performSelector:selector withObject:aAction];
}

// A script object with a defined "abortContext".
- (BOOL)isAbortResult:(id)aResult
{
    if (aResult == nil)
        return NO;
    if ([aResult isKindOfClass:[NSNumber class]])
        return NO;
    if ([aResult isKindOfClass:[WebUndefined class]])
        return NO;
    BOOL isAbort = NO;
    @try {
        isAbort = ![[aResult valueForKey:@"abortContext"] isKindOfClass:[WebUndefined class]];
    } @catch (NSException *exception) {
        isAbort = NO;
    }
    return isAbort;
}

// Quirk kept: without the startup script no finish is reported.
- (id)evaluateScript:(id)aScript withSender:(id)aSender
{
    [self scriptStart:aScript];
    id result = nil;
    if ([aScript length] != 0) {
        if (![self isStartupScriptLoaded])
            return nil;
        aScript = [NSString stringWithFormat:@"$runHyperScript(%@, sender);", [HSJavaScriptCodeUtils quoteString:aScript]];
        [self mapGlobals];
        [self mapLocal:aSender withName:@"sender"];
        result = [self internalEvaluateScript:aScript];
        [self unmapLocals];
        if ([self isAbortResult:result])
            [self processAbortAction:result];
    }
    [self scriptFinish:aScript];
    return result;
}

- (id)evaluateScript:(id)aScript
{
    return [self evaluateScript:aScript withSender:nil];
}

// Checked once.
- (BOOL)isStartupScriptLoaded
{
    if (_isStartupScriptLoadedValid)
        return _isStartupScriptLoaded;
    id result = [self internalEvaluateScript:@"Boolean($runHyperScript != undefined);"];
    _isStartupScriptLoaded = [result respondsToSelector:@selector(boolValue)] ? [result boolValue] : NO;
    _isStartupScriptLoadedValid = YES;
    return _isStartupScriptLoaded;
}

// Waits for the bridge to load first.
- (id)internalEvaluateScript:(id)aScript
{
    id script = [HSJavaScriptCodeUtils removeInvalidCharacters:aScript];
    [self setScript:script];
    if (![self isScriptReady]) {
        [self beginPreloading];
        if (![self waitUntilLoad])
            return nil;
    }
    id bridge = [self javaScriptBridge];
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id result = [[bridge evaluateWebScript:script] retain];
    [pool release];
    return [result autorelease];
}

// Each scriptable object under its script name.
- (void)mapGlobals
{
    if ([self isMapped])
        return;
    NSArray *objects = [[self dataSource] scriptControllerAllScriptObjects:self];
    NSUInteger count = [objects count];
    for (NSUInteger i = 0; i < count; i++) {
        id object = [objects objectAtIndex:i];
        if ([object respondsToSelector:@selector(hyperScriptName)])
            [[self javaScriptBridge] setValue:object forKey:[object hyperScriptName]];
    }
    [self setIsMapped:YES];
}

- (void)unmapLocals
{
    NSMutableString *script = [NSMutableString string];
    for (id name in [[self locals] allKeys])
        [script appendFormat:@"\ndelete %@;\n", name];
    [self internalEvaluateScript:script];
    id locals = _locals;
    _locals = nil;
    [locals release];
}

// Something that can't be scripted becomes undefined (and null for the
// bridge).
- (void)mapLocal:(id)aLocal withName:(id)aName
{
    if ([self isScriptable:aLocal]) {
        [[self locals] setObject:aLocal forKey:aName];
    } else {
        [self internalEvaluateScript:[NSString stringWithFormat:@"var %@ = undefined;", aName]];
        aLocal = [NSNull null];
    }
    [[self javaScriptBridge] setValue:aLocal forKey:aName];
}

- (BOOL)isScriptable:(id)aScriptable
{
    return [aScriptable respondsToSelector:@selector(hyperScriptName)];
}

- (id)locals
{
    if (_locals == nil)
        _locals = [NSMutableDictionary new];
    return _locals;
}

- (void)errorScript:(id)aScript
{
    if ([_delegate respondsToSelector:@selector(scriptController:didErrorWithScript:)])
        [_delegate scriptController:self didErrorWithScript:aScript];
}

- (void)javaScriptBridgeDidReady:(id)aReady
{
    [self setIsScriptReady:YES];
    if ([self delegate] != nil && [_delegate respondsToSelector:@selector(scriptController:didStartWithScript:)])
        [_delegate scriptController:self didStartWithScript:[self script]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSScriptControllerDidReadyNotification" object:self];
}

// A new bridge, loaded asynchronously.
- (void)reload
{
    [self setIsScriptReady:NO];
    [self setIsMapped:NO];
    HSJavaScriptBridge *bridge = [[HSJavaScriptBridge allocWithZone:[self zone]] init];
    [bridge setDelegate:self];
    [self setJavaScriptBridge:[bridge autorelease]];
    [(HSJavaScriptBridgeTiger *)bridge load];   // either concrete bridge class
}

// Spins (and drops) events until the bridge is ready. Quirk kept: the
// events are dequeued and not dispatched.
- (BOOL)waitUntilLoad
{
    if (!_isStartPreloading)
        return NO;
    [[self retain] autorelease];
    while (!_isScriptReady)
        [NSApp nextEventMatchingMask:NSEventMaskAny untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES];
    _isStartPreloading = NO;
    return YES;
}

- (void)beginPreloading
{
    _isStartPreloading = YES;
    [self reload];
}

@end
