#import "HyperPlayerBasePrefix.h"


@interface SMKSpeechVoice : NSObject
{
    struct VoiceSpec _voiceSpec;
    struct VoiceDescription _voiceDescription;
    NSString *_name;
    SMKSpeechSettings *_defaultSettings;
}
+ (id)availableVoices;
+ (id)defaultVoice;
- (NSInteger)language;
- (short)age;
- (NSInteger)gender;
- (id)name;
- (struct VoiceSpec)voiceSpec;
- (id)defaultSettings;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)aEqual;
- (void)dealloc;
- (id)initWithVoiceSpec:(struct VoiceSpec)aSpec;
@end

