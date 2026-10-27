#import "HyperPlayerBasePrefix.h"


@interface HSNodeData : NSObject <EXKeyValueCoding, NSCopying>
{
    id<HSNodeDataOwner> _owner;
    HSUID *_nodeDataUID;
}
+ (id)nodeDataKeysToNodeKeysMap;
+ (id)nodeKeysForNodeDataKeys:(id)aKeys;
- (id)localCopy;
- (id)copyWithZone:(NSZone *)aZone;
- (void)setHypertextLinkContainer:(id)aContainer;
- (id)hypertextLinkContainer;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setNodeDataUID:(id)aUID;
- (id)nodeDataUID;
- (BOOL)hasOwner;
- (void)setOwner:(id)aOwner;
- (id)owner;
- (void)dealloc;
- (id)init;
@end

