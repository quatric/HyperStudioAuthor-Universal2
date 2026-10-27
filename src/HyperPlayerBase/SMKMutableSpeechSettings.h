#import "HyperPlayerBasePrefix.h"


@interface SMKSpeechSettings : NSObject <NSCopying, NSMutableCopying>
{
    struct VoiceSpec _voiceSpec;
    float _volume;
    float _pitch;
    float _pitchModulation;
    float _rate;
}
+ (id)systemSettings;
- (struct VoiceSpec)voiceSpec;
- (id)voice;
- (CGFloat)rate;
- (CGFloat)pitchModulation;
- (CGFloat)pitch;
- (CGFloat)volume;
- (id)mutableCopyWithZone:(NSZone *)aZone;
- (id)copyWithZone:(NSZone *)aZone;
- (id)initWithSpeechChannel:(struct SpeechChannelRecord *)aChannel voiceSpec:(struct VoiceSpec)aSpec;
- (id)initWithSpeechSettings:(id)aSettings;
@end

@interface SMKMutableSpeechSettings : SMKSpeechSettings
{
}
- (void)setVoice:(id)aVoice;
- (void)setRate:(CGFloat)aRate;
- (void)setPitchModulation:(CGFloat)aModulation;
- (void)setPitch:(CGFloat)aPitch;
- (void)setVolume:(CGFloat)aVolume;
@end

