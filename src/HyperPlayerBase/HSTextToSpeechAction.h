#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSTextToSpeechAction : HSNBAAction <HSTextToSpeechActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSTextToSpeakAttribute, HSTextObjectUIDAttribute, HSTextToSpeechUsesTextObjectAttribute, HSTextToSpeechPitchAttribute, HSTextToSpeechRateAttribute, HSTextToSpeechVoiceAttribute, HSMovieDelegate, HSTextToMovieConverterDelegate>
{
    NSString *_textToSpeak;
    HSUID *_textObjectUID;
    BOOL _usesTextObject;
    SMKMutableSpeechSettings *_speechSettings;
    NSSpeechSynthesizer *_speechSynthezier;
    int _speechRate;
    int _speechPitch;
    HSMovie *_currentlyPlayingMovie;
    NSMutableArray *_unplayedMovieFilePaths;
    HSTextToMovieConverter *_textToMovieConverter;
}
+ (CGFloat)speechRateFromRelativeValue:(NSInteger)aValue;
+ (CGFloat)speechPitchFromRelativeValue:(NSInteger)aValue;
- (void)converterDidfinishConvertingAllComponents;
- (void)converterDidFinishConvertingComponentToFile:(id)aFile;
- (void)movieDidStop:(id)aStop;
- (void)movieDidPlayOnce:(id)aOnce;
- (void)movieDidChangeImage:(id)aImage;
- (void)movieDidEnd:(id)aEnd;
- (BOOL)isValid;
- (BOOL)isUnplayedMoviesLastComponentMark;
- (void)setUnplayedMoviesLastComponentMark;
- (void)speakNextComponent;
- (id)nextMovieComponentForSpeaking;
- (void)speechManagerDidFinishSpeaking:(id)aSpeaking;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)startInContext:(id)aContext;
- (void)setVoiceName:(id)aName;
- (id)voiceName;
- (id)voiceIdentifier;
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
- (id)unplayedMovieFilePaths;
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID;
- (id)speechSettings;
- (id)HSTextToSpeechAction_speechSettings;
- (id)currentlyPlayingMovie;
- (void)setCurrentlyPlayingMovie:(id)aMovie;
- (id)textToMovieConverter;
- (void)setTextToMovieConverter:(id)aConverter;
- (void)setSpeechSynthezier:(id)aSynthezier;
- (id)speechSynthezier;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
@end

