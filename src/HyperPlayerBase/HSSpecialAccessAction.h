#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSSpecialAccessAction : HSNBAAction <HSSpecialAccessActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSSpecialAccessAudioCueAttribute, HSSpecialAccessAudioMediaAttribute, HSMediaCopySupport>
{
    int _audioCueType;
    HSNewMedia *_audioMedia;
    HSMovie *_sound;
    id _highlightedObject;
}
- (id)HTML5DictionaryRepresentationInContext:(id)aContext;
- (id)XMLElementRepresentationInContext:(id)aContext;
- (id)audioCueTypeString;
- (BOOL)canBeStoredAsXMLElement;
- (BOOL)canBeStopped;
- (id)sound;
- (BOOL)canUseObject:(id)aObject;
- (id)availableButtons;
- (id)highlightedObject;
- (void)highlightObject:(id)aObject;
- (void)didUnhighlightObject:(id)aObject;
- (void)didHighlightObject:(id)aObject;
- (void)cancelPreviousSpeak;
- (void)speakText:(id)aText;
- (id)ownedMediaUIDs;
- (id)mediaUIDs;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)setAudioMedia:(id)aMedia;
- (id)audioMedia;
- (void)setAudioMediaUID:(id)aUID;
- (id)audioMediaUID;
- (void)setAudioCueType:(NSInteger)aType;
- (NSInteger)audioCueType;
- (void)dealloc;
@end

