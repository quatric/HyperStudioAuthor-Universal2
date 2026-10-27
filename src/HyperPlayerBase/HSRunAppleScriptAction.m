#import "HSRunAppleScriptAction.h"
// Runs an AppleScript, from a file or from source typed into the action.
@implementation HSRunAppleScriptAction
- (BOOL)isValid
{
    if ([self useCustomAppleScriptSource])
        return [[self appleScriptSource] length] != 0;
    return [self appleScriptURL] != nil;
}
- (void)setAppleScriptSource:(id)aSource
{
    if ([[self appleScriptSource] isEqual:aSource])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set AppleScript Source" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setAppleScriptSource:[self appleScriptSource]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAppleScriptSourceAttribute) ofObject:self withUserInfo:nil];
    [_scriptSource release];
    _scriptSource = [aSource retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAppleScriptSourceAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)appleScriptSource
{
    return _scriptSource;
}
- (void)setAppleScriptURL:(id)aURL
{
    if ([[self appleScriptURL] isEqual:aURL])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set AppleScript File" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setAppleScriptURL:[self appleScriptURL]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSAppleScriptURLAttribute) ofObject:self withUserInfo:nil];
    [_scriptURL release];
    _scriptURL = [aURL retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSAppleScriptURLAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (id)appleScriptURL
{
    return _scriptURL;
}
- (void)setUseCustomAppleScriptSource:(BOOL)aSource
{
    if (_useCustomScriptSource == aSource)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Use AppleScript Source" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setUseCustomAppleScriptSource:[self useCustomAppleScriptSource]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSUseCustomAppleScriptSourceAttribute) ofObject:self withUserInfo:nil];
    _useCustomScriptSource = aSource;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSUseCustomAppleScriptSourceAttribute) ofObject:self withUserInfo:nil];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}
- (BOOL)useCustomAppleScriptSource
{
    return _useCustomScriptSource;
}
// Errors (loading or running) are presented by the context. The original
// leaked the script when it failed to run (fixed).
- (void)startInContext:(id)aContext
{
    NSDictionary *errorInfo = nil;
    NSAppleScript *script;
    if ([self useCustomAppleScriptSource])
        script = [[NSAppleScript alloc] initWithSource:[self appleScriptSource]];
    else
        script = [[NSAppleScript alloc] initWithContentsOfURL:[self appleScriptURL] error:&errorInfo];
    if (script != nil && errorInfo == nil)
        [script executeAndReturnError:&errorInfo];
    [script release];
    if (script == nil || errorInfo != nil)
        [aContext presentHyperError:[HSError appleScriptErrorWithDictionary:errorInfo]];
    [self notifyDidFinish];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:@"useCustomAppleScriptSource", [@"appleScriptURL" extraKeyForMultiRepresentations], @"appleScriptSource", nil];
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}
- (void)dealloc
{
    [_scriptURL release];
    [_scriptSource release];
    [super dealloc];
}
@end
