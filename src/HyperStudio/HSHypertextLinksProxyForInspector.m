#import "HSHypertextLinksProxyForInspector.h"

static HSHypertextLinksProxyForInspector *HSHypertextLinksProxyShared = nil;

@implementation HSHypertextLinksProxyForInspector

+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (!HSHypertextLinksProxyShared) {
            HSHypertextLinksProxyShared = [super allocWithZone:aZone];
            return HSHypertextLinksProxyShared;
        }
    }
    return nil;
}

+ (id)sharedHypertextLinksProxyForInspector
{
    @synchronized(self) {
        if (!HSHypertextLinksProxyShared)
            [[self alloc] init];
    }
    return HSHypertextLinksProxyShared;
}

- (id)rootViewController
{
    id controller = [[HSHypertextLinksRootViewController alloc] initWithRootViewController:[self hypertextLinksAssistantPane]];
    [controller setInitialObject:[[self hypertextLinksAssistantPane] initialField]];
    return [controller autorelease];
}

- (void)setupHypertextLinksPaneWithInitialText:(id)aText initialStack:(id)aStack initialField:(id)aField
{
    [[self hypertextLinksAssistantPane] setInitialText:aText];
    [[self hypertextLinksAssistantPane] setInitialStack:aStack];
    [[self hypertextLinksAssistantPane] setInitialField:aField];
}

- (id)hypertextLinksAssistantPane
{
    if (!_hypertextLinksAssistantPane)
        _hypertextLinksAssistantPane = [HSHypertextLinksAssistantPane new];
    return _hypertextLinksAssistantPane;
}

- (id)queryHyperInterface:(id)aInterface
{
    return [[self selectedHypertextLink] queryHyperInterface:aInterface];
}

- (void)forwardInvocation:(id)aInvocation
{
    [aInvocation invokeWithTarget:[self selectedHypertextLink]];
}

- (id)methodSignatureForSelector:(SEL)aSelector
{
    id signature = [super methodSignatureForSelector:aSelector];
    if (!signature)
        signature = [[[self selectedHypertextLink] hyperObject] methodSignatureForSelector:aSelector];
    return signature;
}

- (void)selectHypertextLink:(id)aLink
{
    _selectedHypertextLink = aLink;
}

- (id)selectedHypertextLink
{
    return _selectedHypertextLink;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;
    return [[[self selectedHypertextLink] hyperObject] respondsToSelector:aSelector];
}

- (void)dealloc
{
    [_hypertextLinksAssistantPane release];
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (void)release
{
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end
