#import "HyperPlayerBasePrefix.h"


@interface HSNodeUnit : NSObject <HSNodeUnit, NSObject, NSCopying, EXKeyValueCoding>
{
    HSUID *_UID;
    struct __CFSet *_nodes;
}
- (BOOL)supportsSharingBetweenGroupObjects;
- (id)undoManager;
- (void)notifyChange:(NSInteger)aChange ofAttributeSet:(id)aSet withUserInfo:(id)aInfo;
- (void)notifyChange:(NSInteger)aChange ofAttribute:(id)aAttribute withUserInfo:(id)aInfo;
- (void)willRemoveFromDocument;
- (void)didAddToDocument;
- (void)nodeDidAddToDocument:(id)aDocument;
- (void)nodeWillRemoveFromDocument:(id)aDocument;
- (id)hostNodes;
- (void)registerEjectionFromNode:(void *)aNode;
- (void)registerInjectionIntoNode:(id)aNode;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (id)mediaUIDs;
- (void)setUID:(id)aUID;
- (id)UID;
- (BOOL)isHyperEqual:(id)aEqual;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
- (id)init;
@end

