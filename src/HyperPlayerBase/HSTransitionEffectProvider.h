#import "HyperPlayerBasePrefix.h"


@interface HSTransitionEffectProvider : NSObject
{
    NSArray *_transitionEffectNames;
    NSMutableDictionary *_transitionEffects;
    NSMutableDictionary *_transitionEffectThumbnails;
    NSSet *_swappedTransitionEffectNames;
    NSImage *_slowBadgeImage;
}
+ (id)exportTransitionNameForTransitionName:(id)aName;
+ (id)unsupportedTransitionEffectNames;
+ (id)sharedTransitionEffectProvider;
- (id)thumbnailForTransitionEffectWithName:(id)aName;
- (id)HSTransitionEffectProvider_slowBadgeImage;
- (id)displayNameForTransitionEffectWithName:(id)aName;
- (id)transitionEffectWithName:(id)aName;
- (id)HSTransitionEffectProvider_transitionEffectWithName:(id)aName;
- (id)transitionEffectNames;
- (void)HSTransitionEffectProvider_collectTransitionEffectsIfNeeded;
- (void)HSTransitionEffectProvider_appendBundledTransitionEffectNamesToArray:(id)aArray;
- (void)HSTransitionEffectProvider_appendNoTransitionEffectNameToArray:(id)aArray;
- (id)HSTransitionEffectProvider_swappedTransitionEffectNames;
- (void)dealloc;
@end

