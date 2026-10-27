#import "HyperStudioPrefix.h"


@interface HSHypertextLinksProxyForInspector : NSObject
{
    id<HSHypertextLink> _selectedHypertextLink;
    HSHypertextLinksAssistantPane *_hypertextLinksAssistantPane;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedHypertextLinksProxyForInspector;
- (id)rootViewController;
- (void)setupHypertextLinksPaneWithInitialText:(id)aText initialStack:(id)aStack initialField:(id)aField;
- (id)hypertextLinksAssistantPane;
- (id)queryHyperInterface:(id)aInterface;
- (void)forwardInvocation:(id)aInvocation;
- (id)methodSignatureForSelector:(SEL)aSelector;
- (void)selectHypertextLink:(id)aLink;
- (id)selectedHypertextLink;
- (BOOL)respondsToSelector:(SEL)aSelector;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

