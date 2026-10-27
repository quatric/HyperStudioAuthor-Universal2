#import "HyperStudioPrefix.h"
#import "HSTool.h"


@interface HSCreationTool : HSTool <HSSelectableObject, HyperInterface, NSObject>
{
    id _prototypeObject;
    id _prototypeNodeSupport;
}
+ (Class)userObjectClass;
- (void)saveChangesAndNotify:(BOOL)aNotify;
- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly;
- (void)saveChanges;
- (void)removeObjectFromPrototypeNodeSupport:(id)aSupport;
- (void)addObjectToPrototypeNodeSupport:(id)aSupport;
- (id)prototypeNodeSupport;
- (id)hyperKindDisplayName;
- (id)queryHyperInterface:(id)aInterface;
- (void)notifyPrototypeObjectInterfacesDidChange;
- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface;
- (BOOL)updatePrototypeWithDictionary:(id)aDictionary;
- (id)localizedObjectKindName;
- (id)createPrototypeObject;
- (void)didCreatePrototypeObject;
- (void)prototypeObjectDidChange;
- (BOOL)hasCreatedPrototypeObject;
- (id)prototypeObject;
- (void)dealloc;
@end

