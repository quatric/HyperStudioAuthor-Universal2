#import "HyperStudioPrefix.h"


@interface HSHypertextLinksInspectorController : NSObject
{
    NSMutableDictionary *_linksInspectorToStackMap;
}
+ (id)sharedHypertextLinksInspectorController;
+ (id)allocWithZone:(NSZone *)aZone;
- (id)linksInspectorToStackMap;
- (id)hypertextLinksInspectorForStack:(id)aStack;
- (id)copyWithZone:(NSZone *)aZone;
- (id)retain;
- (NSUInteger)retainCount;
- (oneway void)release;
- (id)autorelease;
- (void)dealloc;
@end
