#import "HyperStudioPrefix.h"


@interface HSActionSettingsAssistantFactory : NSObject
{
    NSDictionary *_actionTypeToAssistantMap;
    NSArray *_disabledActionTypes;
}
+ (id)allocWithZone:(NSZone *)aZone;
+ (id)sharedActionSettingsAssistantFactory;
- (void)invalidateDisabledActionTypes;
- (id)disabledActionTypes;
- (void)disabledActionsListDidChange:(id)aChange;
- (id)actionAssistantForActionType:(id)aType;
- (id)actionTypeToAssistantMap;
- (void)dealloc;
- (id)autorelease;
- (void)release;
- (NSUInteger)retainCount;
- (id)retain;
- (id)copyWithZone:(NSZone *)aZone;
@end

