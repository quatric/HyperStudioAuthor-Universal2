#import "SMKMutableSpeechSettings.h"
// Speech settings: voice, volume, pitch, pitch modulation and rate (the
// Speech Synthesis Manager's Fixed values as floats).
@implementation SMKSpeechSettings
// The default voice's settings, read from a temporary channel.
+ (id)systemSettings
{
    VoiceDescription description;
    OSErr error = GetVoiceDescription(NULL, &description, sizeof(description));
    if (error != noErr) {
        NSLog(@"GetVoiceDescription error #%d returned.", (int)error);
        return nil;
    }
    SpeechChannel channel = NULL;
    error = NewSpeechChannel(NULL, &channel);
    if (error != noErr) {
        NSLog(@"NewSpeechChannel error #%d returned.", (int)error);
        return nil;
    }
    SMKSpeechSettings *settings = [[SMKSpeechSettings alloc] initWithSpeechChannel:channel voiceSpec:description.voice];
    error = DisposeSpeechChannel(channel);
    if (error != noErr)
        NSLog(@"DisposeSpeechChannel error #%d returned.", (int)error);
    return [settings autorelease];
}
- (struct VoiceSpec)voiceSpec
{
    return _voiceSpec;
}
- (id)voice
{
    return [[[SMKSpeechVoice alloc] initWithVoiceSpec:_voiceSpec] autorelease];
}
- (CGFloat)rate
{
    return _rate;
}
- (CGFloat)pitchModulation
{
    return _pitchModulation;
}
- (CGFloat)pitch
{
    return _pitch;
}
- (CGFloat)volume
{
    return _volume;
}
- (id)mutableCopyWithZone:(NSZone *)aZone
{
    return [[SMKMutableSpeechSettings allocWithZone:aZone] initWithSpeechSettings:self];
}
- (id)copyWithZone:(NSZone *)aZone
{
    return [[SMKSpeechSettings allocWithZone:aZone] initWithSpeechSettings:self];
}
- (id)initWithSpeechChannel:(struct SpeechChannelRecord *)aChannel voiceSpec:(struct VoiceSpec)aSpec
{
    self = [super init];
    if (self == nil)
        return nil;
    Fixed value = 0;
    OSErr error = GetSpeechInfo(aChannel, soVolume, &value);
    NSString *format = @"GetSpeechInfo error #%d returned.";
    if (error == noErr) {
        _volume = (float)value * (1.0f / 65536.0f);
        error = GetSpeechPitch(aChannel, &value);
        format = @"GetSpeechPitch error #%d returned.";
        if (error == noErr) {
            _pitch = (float)value * (1.0f / 65536.0f);
            error = GetSpeechInfo(aChannel, soPitchMod, &value);
            format = @"GetSpeechInfo error #%d returned.";
            if (error == noErr) {
                _pitchModulation = (float)value * (1.0f / 65536.0f);
                error = GetSpeechRate(aChannel, &value);
                format = @"GetSpeechRate error #%d returned.";
                if (error == noErr) {
                    _rate = (float)value * (1.0f / 65536.0f);
                    _voiceSpec = aSpec;
                    return self;
                }
            }
        }
    }
    NSLog(format, (int)error);
    [self release];
    return nil;
}
- (id)initWithSpeechSettings:(SMKSpeechSettings *)aSettings
{
    self = [super init];
    if (self != nil) {
        _volume = [aSettings volume];
        _pitch = [aSettings pitch];
        _pitchModulation = [aSettings pitchModulation];
        _rate = [aSettings rate];
        _voiceSpec = [aSettings voiceSpec];
    }
    return self;
}
@end
@implementation SMKMutableSpeechSettings
- (void)setVoice:(id)aVoice
{
    _voiceSpec = [(SMKSpeechVoice *)aVoice voiceSpec];
}
- (void)setRate:(CGFloat)aRate
{
    _rate = aRate;
}
- (void)setPitchModulation:(CGFloat)aModulation
{
    _pitchModulation = aModulation;
}
- (void)setPitch:(CGFloat)aPitch
{
    _pitch = aPitch;
}
- (void)setVolume:(CGFloat)aVolume
{
    _volume = aVolume;
}
@end
