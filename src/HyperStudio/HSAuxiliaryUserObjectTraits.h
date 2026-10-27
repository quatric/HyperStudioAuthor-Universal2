#import "HyperStudioPrefix.h"


@interface HSAuxiliaryUserObjectTraits : NSObject
{
    id _userObject;
    struct HSAuxiliaryTraits _traits;
    BOOL _traitsMarkedInvalid;
}
+ (id)rectsForIcons:(id)aIcons;
+ (BOOL)userObjectHasScript:(id)aScript isScriptValid:(BOOL *)aValid warning:(BOOL *)aWarning;
- (id)combinedIconsImage;
- (void)renderIconsInRects:(id)aRects clipRect:(NSRect)aRect inView:(id)aView;
- (NSRect)boundingRectForIconRects:(id)aRects;
- (id)iconImages;
- (BOOL)updateTraitsIfInvalid;
- (void)invalidateTraits;
- (BOOL)updateTraitsIfNeeded;
- (struct HSAuxiliaryTraits)updatedTraits;
- (BOOL)traitsAreEqual:(struct HSAuxiliaryTraits)aEqual;
- (void)setUserObject:(id)aObject;
- (id)userObject;
- (void)dealloc;
- (BOOL)userObjectIsHidden;
- (BOOL)userObjectIsMasterObject;
- (BOOL)userObjectIsMasterCard;
- (BOOL)userObjectHasAnimation;
- (BOOL)userObjectHasChildrenWithInvalidScripts;
- (BOOL)userObjectHasScriptValid:(BOOL *)aValid warning:(BOOL *)aWarning;
- (BOOL)allActionsAreValid;
- (BOOL)userObjectHasPlaySoundAction;
- (BOOL)userObjectHasActionsOtherThanScript;
@end

