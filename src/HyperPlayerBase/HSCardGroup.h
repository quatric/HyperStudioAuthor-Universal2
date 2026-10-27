#import "HyperPlayerBasePrefix.h"


@interface HSCardGroup : NSObject <EXKeyValueCoding, HSNodeDataProvider, NSCopying>
{
    HSUID *_groupUID;
    NSMutableDictionary *_nodeUnits;
    NSMutableDictionary *_nodeUnitRoles;
    NSMutableArray *_groupData;
    HSCursor *_cursor;
    NSMutableArray *_nodeDataForOldVersionsSupport;
}
- (id)copyWithZone:(NSZone *)aZone;
- (id)nodeDataForOldVersionsSupport;
- (void)setCursor:(id)aCursor;
- (id)cursor;
- (void)setActor:(id)aActor;
- (id)actor;
- (id)extraDictionaryRepresentationWithCodingContext:(id)aContext;
- (void)loadExtraDictionaryRepresentation:(id)aRepresentation withCodingContext:(id)aContext;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (id)nodeDataWithUID:(id)aUID;
- (void)removeData:(id)aData;
- (void)addData:(id)aData;
- (id)dataEnumerator;
- (void)setGroupData:(id)aData;
- (id)groupData;
- (id)nodeUnitEnumerator;
- (id)nodeUnitRoleEnumerator;
- (id)nodeUnitWithUID:(id)aUID;
- (id)roleOfNodeUnitWithUID:(id)aUID;
- (void)removeNodeUnit:(id)aUnit;
- (void)addNodeUnit:(id)aUnit forRole:(id)aRole;
- (void)setNodeUnits:(id)aUnits;
- (id)nodeUnits;
- (void)setNodeUnitRoles:(id)aRoles;
- (id)nodeUnitRoles;
- (void)setGroupUID:(id)aUID;
- (id)groupUID;
- (void)dealloc;
- (id)init;
@end

