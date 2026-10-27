#import "HyperPlayerBasePrefix.h"
#import "HSNodeData.h"


@interface HSUserObjectData : HSNodeData <HSActorOwner>
{
    HSUID *_UID;
    HSActor *_actor;
    HSCursor *_cursor;
    NSString *_name;
    BOOL _usingTemplateName;
    HSUniqueNameGenerator *_nameGenerator;
    NSString *_preferredNameTemplate;
    NSDictionary *_attributeToNotificationMap;
    NSString *_comments;
}
- (id)copyWithZone:(NSZone *)aZone;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)enumeratorForGenerator:(id)aGenerator;
- (id)otherActorsFromGroup:(id)aGroup;
- (id)hyperObjectForActor:(id)aActor;
- (void)willRemoveOwningObjectFromDocument:(id)aDocument;
- (void)didAddOwningObjectToDocument:(id)aDocument;
- (void)setComments:(id)aComments;
- (id)comments;
- (void)setAttributeToNotificationMap:(id)aMap;
- (id)attributeToNotificationMap;
- (void)setPreferredNameTemplate:(id)aTemplate;
- (id)preferredNameTemplate;
- (void)setNameGenerator:(id)aGenerator;
- (id)nameGenerator;
- (void)setUsingTemplateName:(BOOL)aName;
- (BOOL)usingTemplateName;
- (void)setName:(id)aName;
- (id)name;
- (void)setCursor:(id)aCursor;
- (id)cursor;
- (void)setActor:(id)aActor;
- (id)actor;
- (void)setUID:(id)aUID;
- (id)UID;
- (void)dealloc;
- (id)init;
@end

