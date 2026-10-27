#import "HyperStudioPrefix.h"


@interface HSCoachingHelpManager : NSObject
{
    NSMutableArray *_stacks;
    NSMutableDictionary *_lastAddedChildren;
    NSMutableDictionary *_ignoredChildren;
    NSMapTable *_objectToAdditionalCoachingPanesMap;
    NSMapTable *_objectToDropHelpPanesMap;
    BOOL _ignoreAddedObject;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedCoachingHelpManager;
- (void)enableObjectRegistration;
- (void)disableObjectRegistration;
- (BOOL)isObjectRegistrationEnabled;
- (void)cleanAllDropHelpPanesForStack:(id)aStack;
- (void)removeDropHelpPaneForObject:(id)aObject;
- (void)addDropHelpPane:(id)aPane forObject:(id)aObject;
- (id)dropHelpPaneForObject:(id)aObject;
- (id)HSCoachingHelpManager_objectToDropHelpPanesMap;
- (void)cleanAllAdditionalCoachingPanesForStack:(id)aStack;
- (void)pushAdditionalCoachingPane:(id)aPane forObject:(id)aObject;
- (id)HSCoachingHelpManager_objectToAdditionalCoachingPanesMap;
- (id)coachingPanesForObject:(id)aObject inStack:(id)aStack;
- (id)coachingPanesForObject:(id)aObject inStack:(id)aStack remove:(BOOL)aRemove;
- (void)removeAllObjectsForStack:(id)aStack;
- (void)removeObject:(id)aObject forStack:(id)aStack;
- (void)removeObject:(id)aObject;
- (void)addObject:(id)aObject forStack:(id)aStack;
- (void)containerAttributeDidChange:(id)aChange;
- (void)removeStack:(id)aStack;
- (void)addStack:(id)aStack;
- (id)ignoredChildrenForStack:(id)aStack;
- (id)ignoredChildrenDict;
- (id)lastAddedChildrenForStack:(id)aStack;
- (id)lastAddedChildrenDict;
- (void)setDontShowCoachingHints:(BOOL)aHints forKey:(id)aKey;
- (BOOL)dontShowCoachingHintsForKey:(id)aKey;
- (void)setDontShowAllCoachingHints:(BOOL)aHints;
- (BOOL)dontShowAllCoachingHints;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

