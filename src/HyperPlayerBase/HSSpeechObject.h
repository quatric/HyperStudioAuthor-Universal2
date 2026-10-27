#import "HyperPlayerBasePrefix.h"
#import "HSObject.h"


@interface HSSpeechObject : HSObject <HSScriptObject, HyperInterface, NSObject>
{
    BOOL _isSpeaking;
    SMKSpeechSimpleParser *_speechTextParser;
    SMKMutableSpeechSettings *_speechSettings;
}
+ (id)availableVoiceConstants;
- (double)volumeFromHyperLogoSpeechVolume:(double)aVolume;
- (double)hyperLogoSpeechVolume:(double)aVolume;
- (double)pitchFromHyperLogoSpeechPitch:(double)aPitch;
- (double)hyperLogoSpeechPitch:(double)aPitch;
- (double)speedFromHyperLogoSpeechSpeed:(double)aSpeed;
- (double)hyperLogoSpeechSpeed:(double)aSpeed;
- (void)speechManagerDoneSpeakingObject:(id)aObject;
- (id)speechTextParser;
- (id)nonLocalizedKindName;
- (id)hyperScriptName;
- (id)hyperScriptKind;
- (id)hyperScriptDisplayName;
- (id)setVolumeFromScript:(id)aScript;
- (id)getVolumeFromScript:(id)aScript;
- (id)setPitchFromScript:(id)aScript;
- (id)getPitchFromScript:(id)aScript;
- (id)setSpeedFromScript:(id)aScript;
- (id)getSpeedFromScript:(id)aScript;
- (id)sayFromScript:(id)aScript;
- (id)eraseDictFromScript:(id)aScript;
- (id)toPhoneticFromScript:(id)aScript;
- (id)putDictFromScript:(id)aScript;
- (id)setVoiceFromScript:(id)aScript;
- (id)voiceForConstant:(id)aConstant;
- (id)getVoiceFromScript:(id)aScript;
- (id)getVoicesFromScript:(id)aScript;
- (id)invokeUndefinedMethodFromWebScript:(id)aScript withArguments:(id)aArguments;
- (id)speechSettings;
- (id)HSSpeechObject_speechSettings;
- (id)speechDictionary;
- (void)dealloc;
@end

