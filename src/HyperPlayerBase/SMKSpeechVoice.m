#import "SMKSpeechVoice.h"
// A Speech Synthesis Manager voice: its spec and description, with the
// voice's default settings read from a temporary speech channel.
@implementation SMKSpeechVoice
+ (id)availableVoices
{
    SInt16 count = 0;
    OSErr err = CountVoices(&count);
    if (err != noErr) {
        NSLog(@"CountVoices error: %d returned!", (int)err);
        return nil;
    }
    NSMutableArray *voices = [NSMutableArray arrayWithCapacity:count];
    for (SInt16 i = 1; i <= count; i++) {
        VoiceSpec spec;
        err = GetIndVoice(i, &spec);
        if (err != noErr)
            NSLog(@"GetIndVoice (voiceIndex = %d) error: %d returned!", (int)i, (int)err);
        SMKSpeechVoice *voice = [[SMKSpeechVoice alloc] initWithVoiceSpec:spec];
        [voices addObject:voice];
        [voice release];
    }
    return voices;
}
// (The original returned it retained; no caller releases it.)
+ (id)defaultVoice
{
    VoiceDescription description;
    OSErr err = GetVoiceDescription(NULL, &description, sizeof(description));
    if (err != noErr) {
        NSLog(@"GetVoiceDescription error: %d returned!", (int)err);
        return nil;
    }
    return [[[SMKSpeechVoice alloc] initWithVoiceSpec:description.voice] autorelease];
}
- (NSInteger)language
{
    return _voiceDescription.language;
}
- (short)age
{
    return _voiceDescription.age;
}
- (NSInteger)gender
{
    return _voiceDescription.gender;
}
- (id)name
{
    if (_name == nil)
        _name = [[NSString alloc] initWithBytes:_voiceDescription.name + 1
                                         length:_voiceDescription.name[0]
                                       encoding:NSMacOSRomanStringEncoding];
    return _name;
}
- (struct VoiceSpec)voiceSpec
{
    return _voiceSpec;
}
- (id)defaultSettings
{
    if (_defaultSettings == nil) {
        SpeechChannel channel = NULL;
        OSErr err = NewSpeechChannel(&_voiceSpec, &channel);
        if (err != noErr) {
            NSLog(@"NewSpeechChannel error: %d returned!", (int)err);
            return nil;
        }
        _defaultSettings = [[SMKSpeechSettings alloc] initWithSpeechChannel:channel voiceSpec:_voiceSpec];
        err = DisposeSpeechChannel(channel);
        if (err != noErr)
            NSLog(@"DisposeSpeechChannel error: %d returned!", (int)err);
    }
    return _defaultSettings;
}
- (NSUInteger)hash
{
    return ((NSUInteger)_voiceSpec.id & 0xffff0000) | (_voiceSpec.creator & 0xffff);
}
- (BOOL)isEqual:(id)aEqual
{
    if (![aEqual isKindOfClass:[SMKSpeechVoice class]])
        return NO;
    VoiceSpec other = [(SMKSpeechVoice *)aEqual voiceSpec];
    return other.creator == _voiceSpec.creator && other.id == _voiceSpec.id;
}
- (void)dealloc
{
    [_name release];
    [_defaultSettings release];
    [super dealloc];
}
// (The original returns nil without releasing when the voice has no
// description.)
- (id)initWithVoiceSpec:(struct VoiceSpec)aSpec
{
    self = [super init];
    if (self != nil) {
        _voiceSpec = aSpec;
        OSErr err = GetVoiceDescription(&_voiceSpec, &_voiceDescription, sizeof(_voiceDescription));
        if (err != noErr) {
            NSLog(@"GetVoiceDescription error: %d returned!", (int)err);
            [self release];
            return nil;
        }
    }
    return self;
}
@end
