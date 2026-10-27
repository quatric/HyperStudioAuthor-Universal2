#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSPlayAnimationAction : HSToDoAction <HSPlayAnimationActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSPlayAnimationActionAnimationAttribute, HSMediaCopySupport>
{
    HSAnimation *_animation;
    HSAnimation *_playingAnimation;
    HSActionExecutionContext *_context;
}
- (void)importFromXMLElementRepresentation:(id)aRepresentation inContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)supportedInIPad;
- (id)mediaUIDs;
- (id)ownedMediaUIDs;
- (id)HTML5UnsupportedFeaturesForDocumentType:(id)aType;
- (BOOL)hasUnsupportedHTML5FeaturesForDocumentType:(id)aType;
- (BOOL)canBeExportedToHTML5DocumentType:(id)aType;
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (void)animationPlaybackDidEnd:(id)aEnd;
- (BOOL)canBeStopped;
- (void)stop:(id)aStop;
- (void)startInContext:(id)aContext;
- (void)setAnimation:(id)aAnimation;
- (id)animation;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (BOOL)isValid;
- (BOOL)wantsSaveAfterRemove;
- (void)dealloc;
- (id)init;
@end

