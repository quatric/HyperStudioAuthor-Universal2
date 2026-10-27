#import "HyperPlayerBasePrefix.h"


@interface SMKSpeechManager : NSObject
{
    NSTimer *_speechObjectsProcessingTimer;
    id _queue;
    id _defaultParser;
    void *_speechInfo;
    SMKMutableSpeechSettings *_speechSettings;
    struct HyperPlayerBase_anon22 _spmFlags;
}
+ (void)setDefaultParserClass:(Class)aClass;
+ (Class)defaultParserClass;
+ (id)sharedSpeechManager;
+ (void)initialize;
- (void)applicationDidBecomeActive:(id)aActive;
- (void)applicationWillResignActive:(id)aActive;
- (void)didFinishProcessingText:(id)aText;
- (void)didFinishSpeaking:(id)aSpeaking;
- (void)stopSpeech;
- (void)pauseOrContinueSpeech;
- (BOOL)isPaused;
- (BOOL)isSpeaking;
- (BOOL)hasCurrentSpeechRequestedBy:(id)aBy;
- (BOOL)hasPendingSpeechFromRequestor:(id)aRequestor;
- (void)cancelAllSpeechRequestedByObject:(id)aObject;
- (void)requestorWillBecomeInvalid:(id)aInvalid;
- (void)speakAttributedText:(id)aText immediately:(BOOL)aImmediately requestor:(id)aRequestor;
- (void)speakText:(id)aText immediately:(BOOL)aImmediately requestor:(id)aRequestor;
- (void)speakString:(id)aString immediately:(BOOL)aImmediately requestor:(id)aRequestor;
- (void)speakString:(id)aString immediately:(BOOL)aImmediately highPriority:(BOOL)aPriority needsParsing:(BOOL)aParsing requestor:(id)aRequestor;
- (void)setReactsOnVoiceChangeASAP:(BOOL)aASAP;
- (BOOL)reactsOnVoiceChangeASAP;
- (void)setStopsSpeechOnDeactivate:(BOOL)aDeactivate;
- (BOOL)stopsSpeechOnDeactivate;
- (void)setPausesSpeechOnDeactivate:(BOOL)aDeactivate;
- (BOOL)pausesSpeechOnDeactivate;
- (BOOL)isTuneEnabled;
- (void)_speakString:(id)aString immediately:(BOOL)aImmediately requestor:(id)aRequestor parsed:(BOOL)aParsed highPriority:(BOOL)aPriority;
- (void)_cancelAllSpeechWithRequestor:(id)aRequestor requestorWillBecomeInvalid:(BOOL)aInvalid;
- (void)_stopAllSpeechImmediately:(BOOL)aImmediately;
- (void)_appendSpeechQueueWithObject:(id)aObject;
- (void)_speakObject:(id)aObject;
- (void)_doSomePendingObjectsProcessing;
- (void)_processSpokenObject:(id)aObject;
- (id)textToWrappedPhonemes:(id)aPhonemes;
- (id)textToPhonemes:(id)aPhonemes;
- (void)applySpeechSettings:(id)aSettings;
- (id)speechSettings;
- (id)_parserForRequestor:(id)aRequestor;
- (void)setDefaultParser:(id)aParser;
- (id)defaultParser;
- (id)_defaultParser;
- (void)_setRegisteredForCallbackNotifications:(BOOL)aNotifications;
- (void)dealloc;
- (id)init;
@end

@interface SMKSpeechManager (SpeechSynthesisCallbacks)
- (void)textDone;
- (void)speechDone;
- (void)speechError:(short)aError;
@end

@interface SMKSpeechManager (SpeechSynthesisWrappers)
- (void)setChannelVoice:(id)aVoice;
- (void)setChannelRate:(CGFloat)aRate;
- (CGFloat)channelRate;
- (void)setChannelPitchModulation:(CGFloat)aModulation;
- (CGFloat)channelPitchModulation;
- (void)setChannelPitch:(CGFloat)aPitch;
- (CGFloat)channelPitch;
- (void)setChannelVolume:(CGFloat)aVolume;
- (CGFloat)channelVolume;
- (id)channelConvertTextToPhonemes:(id)aPhonemes;
- (BOOL)channelContinueSpeech;
- (BOOL)channelPauseSpeech:(BOOL)aSpeech;
- (BOOL)channelStopSpeechImmediately:(BOOL)aImmediately;
- (BOOL)channelStopSpeech;
- (BOOL)channelSpeakText:(id)aText;
- (BOOL)prepareSpeechChannel;
- (BOOL)isSpeechChannelUsingDefaultVoice;
- (BOOL)createSpeechChannel;
- (BOOL)disposeSpeechChannel;
- (struct _SMKSpeechPrivateInfo *)_allocateSpeechPrivateInfo;
@end

