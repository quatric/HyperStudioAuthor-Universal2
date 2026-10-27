#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSAvailableActionsProvider : HSObject
{
}
+ (id)actionTypes;
+ (id)sharedAvailableActionsProvider;
- (id)createDefaultActionOfType:(id)aType;
- (BOOL)canActionOfType:(id)aType beAppliedToObject:(id)aObject;
- (id)availableActionsOfType:(id)aType forObject:(id)aObject forEvent:(id)aEvent;
- (id)allActionsOfType:(id)aType forObject:(id)aObject;
- (id)allActionsForObject:(id)aObject;
- (id)availableActionsForObject:(id)aObject forEvent:(id)aEvent;
@end

