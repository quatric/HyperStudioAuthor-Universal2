#import "HyperPlayerBasePrefix.h"
#import "HSNodeUnit.h"


@interface HSMutableSnapOptionsNodeUnit : HSNodeUnit
{
    BOOL _playDropOffRewardSound;
    unsigned int _isDropOffSnappingEnabled:1;
    BOOL _isDropOffTarget;
    unsigned int _dropOffSnappingRange;
    HSNewMedia *_dropOffRewardSoundMedia;
    HSUID *_dropOffTargetUID;
}
+ (id)keysForStoring;
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
- (id)mediaUIDs;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (Class)hyperImplementationClassForHyperInterface:(id)aInterface;
- (BOOL)implementsHyperInterface:(id)aInterface;
- (id)implementedHyperInterfaces;
- (id)attributes;
- (id)copyWithZone:(NSZone *)aZone;
- (void)dealloc;
@end

