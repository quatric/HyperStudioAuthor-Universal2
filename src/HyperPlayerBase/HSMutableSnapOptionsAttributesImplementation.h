#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSMutableSnapOptionsAttributesImplementation : HSWeaklyReferencedObject <HSMutableSnapOptionsAttributes, HSAttribute, HSNodeUnitBasedHyperImplementationCreating, HSMutableSnappingTargetUIDIdentification>
{
    HSNode *_node;
    HSMutableSnapOptionsNodeUnit *_nodeUnit;
}
+ (id)hyperImplementationWithNode:(id)aNode unit:(id)aUnit;
- (void)setSnappingOptions:(id)aOptions;
- (id)snappingOptions;
- (void)setIsDropOffSnappingEnabled:(BOOL)aEnabled;
- (BOOL)isDropOffSnappingEnabled;
- (void)setDropOffSnappingRange:(NSUInteger)aRange;
- (NSUInteger)dropOffSnappingRange;
- (void)setIsDropOffTarget:(BOOL)aTarget;
- (BOOL)isDropOffTarget;
- (void)setPlayDropOffRewardSound:(BOOL)aSound;
- (BOOL)playDropOffRewardSound;
- (void)setDropOffRewardSoundMedia:(id)aMedia;
- (id)dropOffRewardSoundMedia;
- (void)setDropOffRewardSoundMediaUID:(id)aUID;
- (id)dropOffRewardSoundMediaUID;
- (void)setDropOffTargetUID:(id)aUID;
- (id)dropOffTargetUID;
- (id)attributeObservingController;
- (id)hyperObject;
- (id)node;
- (void)dealloc;
- (id)initWithNodeUnit:(id)aUnit node:(id)aNode;
- (BOOL)isEqualTo:(id)aObject;
- (id)nodeUnit;
- (id)temporaryDropOffTarget;
- (void)setTemporaryDropOffTarget:(id)aTarget;
@end

