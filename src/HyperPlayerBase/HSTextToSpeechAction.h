#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSTextToSpeechAction : HSNBAAction <HSTextToSpeechActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTextToSpeakAttribute, HSTextObjectUIDAttribute, HSTextToSpeechUsesTextObjectAttribute, HSTextToSpeechPitchAttribute, HSTextToSpeechRateAttribute, HSTextToSpeechVoiceAttribute>
{
    NSString *_textToSpeak;
    HSUID *_textObjectUID;
    BOOL _usesTextObject;
    SMKMutableSpeechSettings *_speechSettings;
    int _speechRate;
    int _speechPitch;
}
+ (CGFloat)speechRateFromRelativeValue:(NSInteger)aValue;
+ (CGFloat)speechPitchFromRelativeValue:(NSInteger)aValue;
- (BOOL)isValid;
- (void)speechManagerDidFinishSpeaking:(id)aSpeaking;
- (void)stop:(id)aStop;
- (void)pause;
- (void)resume;
- (BOOL)canBeStopped;
- (void)startInContext:(id)aContext;
- (void)setVoiceName:(id)aName;
- (id)voiceName;
- (void)setSpeechVoice:(id)aVoice;
- (id)speechVoice;
- (void)setRelativeSpeechRate:(NSInteger)aRate;
- (NSInteger)relativeSpeechRate;
- (void)setRelativeSpeechPitch:(NSInteger)aPitch;
- (NSInteger)relativeSpeechPitch;
- (void)setUsesTextObject:(BOOL)aObject;
- (BOOL)usesTextObject;
- (void)setTextObjectUID:(id)aUID;
- (id)textObjectUID;
- (void)setTextToSpeak:(id)aSpeak;
- (id)textToSpeak;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)speechSettings;
- (id)HSTextToSpeechAction_speechSettings;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

