#import "HSSpeechObject.h"
#import "SMKSpeechManager.h"
#import "SMKSpeechSimpleParser.h"
#import "SMKSpeechVoice.h"
#import "SMKMutableSpeechSettings.h"

// Script arguments are clamped to the HyperLogo range 0...9.9.
static double HSSpeechClampedScriptValue(NSArray *aArguments)
{
    double value = [[aArguments objectAtIndex:0] floatValue];
    float clamped = value <= 9.9 ? (float)value : 9.9f;
    return 0.0 <= clamped ? (double)clamped : 0.0;
}

static BOOL HSSpeechHasFloatArgument(NSArray *aArguments)
{
    return [aArguments count] != 0 && [[aArguments objectAtIndex:0] respondsToSelector:@selector(floatValue)];
}

static BOOL HSSpeechHasStringArgument(NSArray *aArguments, NSUInteger aIndex)
{
    return [[aArguments objectAtIndex:aIndex] isKindOfClass:[NSString class]];
}

@implementation HSSpeechObject

+ (id)availableVoiceConstants
{
    return [NSArray arrayWithObjects:@"Male", @"Female", @"Child", nil];
}

- (double)volumeFromHyperLogoSpeechVolume:(double)aVolume
{
    return aVolume / 9.9;
}

- (double)hyperLogoSpeechVolume:(double)aVolume
{
    return aVolume * 9.9;
}

- (double)pitchFromHyperLogoSpeechPitch:(double)aPitch
{
    return aPitch * 6.0 + 20.0;
}

- (double)hyperLogoSpeechPitch:(double)aPitch
{
    return (aPitch + -20.0) / 6.0;
}

- (double)speedFromHyperLogoSpeechSpeed:(double)aSpeed
{
    return aSpeed * 30.0 + 35.0;
}

- (double)hyperLogoSpeechSpeed:(double)aSpeed
{
    return (aSpeed + -35.0) / 30.0;
}

- (void)speechManagerDoneSpeakingObject:(id)aObject
{
    _isSpeaking = NO;
}

- (id)speechTextParser
{
    if (_speechTextParser == nil)
        _speechTextParser = [SMKSpeechSimpleParser new];
    return _speechTextParser;
}

- (id)nonLocalizedKindName
{
    return NSStringFromClass([self class]);
}

- (id)hyperScriptName
{
    return [NSString stringWithFormat:@"$$__%@", @"Speech"];
}

- (id)hyperScriptKind
{
    return @"Speech";
}

- (id)hyperScriptDisplayName
{
    return @"Speech";
}

- (id)setVolumeFromScript:(id)aScript
{
    if (HSSpeechHasFloatArgument(aScript))
        [(SMKMutableSpeechSettings *)[self HSSpeechObject_speechSettings] setVolume:(float)[self volumeFromHyperLogoSpeechVolume:HSSpeechClampedScriptValue(aScript)]];
    return [self getVolumeFromScript:nil];
}

- (id)getVolumeFromScript:(id)aScript
{
    return [NSNumber numberWithFloat:(float)[self hyperLogoSpeechVolume:[(SMKSpeechSettings *)[self speechSettings] volume]]];
}

- (id)setPitchFromScript:(id)aScript
{
    if (HSSpeechHasFloatArgument(aScript))
        [(SMKMutableSpeechSettings *)[self HSSpeechObject_speechSettings] setPitch:(float)[self pitchFromHyperLogoSpeechPitch:HSSpeechClampedScriptValue(aScript)]];
    return [self getPitchFromScript:nil];
}

- (id)getPitchFromScript:(id)aScript
{
    return [NSNumber numberWithFloat:(float)[self hyperLogoSpeechPitch:[(SMKSpeechSettings *)[self speechSettings] pitch]]];
}

- (id)setSpeedFromScript:(id)aScript
{
    if (HSSpeechHasFloatArgument(aScript))
        [(SMKMutableSpeechSettings *)[self HSSpeechObject_speechSettings] setRate:(float)[self speedFromHyperLogoSpeechSpeed:HSSpeechClampedScriptValue(aScript)]];
    return [self getSpeedFromScript:nil];
}

- (id)getSpeedFromScript:(id)aScript
{
    return [NSNumber numberWithFloat:(float)[self hyperLogoSpeechSpeed:[(SMKSpeechSettings *)[self speechSettings] rate]]];
}

// Speaks synchronously, spinning the event loop until the speech manager
// reports the object done.
- (id)sayFromScript:(id)aScript
{
    if ([aScript count] == 0 || !HSSpeechHasStringArgument(aScript, 0))
        return nil;
    NSString *text = [aScript objectAtIndex:0];
    _isSpeaking = YES;
    [[SMKSpeechManager sharedSpeechManager] speakString:text immediately:NO highPriority:NO needsParsing:YES requestor:self];
    NSNumber *result = [NSNumber numberWithBool:[[SMKSpeechManager sharedSpeechManager] isSpeaking]];
    while (_isSpeaking)
        [NSApp nextEventMatchingMask:NSUIntegerMax untilDate:nil inMode:NSDefaultRunLoopMode dequeue:YES];
    return result;
}

- (id)eraseDictFromScript:(id)aScript
{
    [[[SMKSpeechManager sharedSpeechManager] defaultParser] setReplacementWords:nil];
    return nil;
}

- (id)toPhoneticFromScript:(id)aScript
{
    if ([aScript count] == 0 || !HSSpeechHasStringArgument(aScript, 0))
        return nil;
    return [[SMKSpeechManager sharedSpeechManager] textToWrappedPhonemes:[aScript objectAtIndex:0]];
}

- (id)putDictFromScript:(id)aScript
{
    if ([aScript count] < 2 || !HSSpeechHasStringArgument(aScript, 0) || !HSSpeechHasStringArgument(aScript, 1))
        return nil;
    id word = [aScript objectAtIndex:0];
    id replacement = [aScript objectAtIndex:1];
    NSMutableDictionary *words = [NSMutableDictionary dictionaryWithDictionary:[[self speechTextParser] replacementWords]];
    [words setObject:replacement forKey:word];
    [[self speechTextParser] setReplacementWords:words];
    return nil;
}

// Takes a voice constant (Male, Female, Child) or a voice name.
- (id)setVoiceFromScript:(id)aScript
{
    if ([aScript count] != 0 && HSSpeechHasStringArgument(aScript, 0)) {
        id name = [aScript objectAtIndex:0];
        SMKSpeechVoice *voice = nil;
        if ([[[self class] availableVoiceConstants] containsObject:name]) {
            voice = [self voiceForConstant:name];
        } else {
            NSEnumerator *e = [[SMKSpeechVoice availableVoices] objectEnumerator];
            while ((voice = [e nextObject]) != nil) {
                if ([[voice name] isEqual:name])
                    break;
            }
        }
        [(SMKMutableSpeechSettings *)[self HSSpeechObject_speechSettings] setVoice:voice];
    }
    return [self getVoiceFromScript:nil];
}

// Male is gender 2, female gender 1, a child is younger than 18.
- (id)voiceForConstant:(id)aConstant
{
    NSEnumerator *e = [[SMKSpeechVoice availableVoices] objectEnumerator];
    SMKSpeechVoice *voice;
    while ((voice = [e nextObject]) != nil) {
        if ([aConstant isEqual:@"Male"] && [voice gender] == 2)
            return voice;
        if ([aConstant isEqual:@"Female"] && [voice gender] == 1)
            return voice;
        if ([aConstant isEqual:@"Child"] && [voice age] < 0x12)
            return voice;
    }
    return nil;
}

- (id)getVoiceFromScript:(id)aScript
{
    return [(SMKSpeechVoice *)[(SMKSpeechSettings *)[self speechSettings] voice] name];
}

- (id)getVoicesFromScript:(id)aScript
{
    NSMutableArray *voices = [NSMutableArray arrayWithObjects:@"Male", @"Female", @"Child", nil];
    NSEnumerator *e = [[SMKSpeechVoice availableVoices] objectEnumerator];
    SMKSpeechVoice *voice;
    while ((voice = [e nextObject]) != nil)
        [voices addObject:[voice name]];
    return voices;
}

- (id)invokeUndefinedMethodFromWebScript:(id)aScript withArguments:(id)aArguments
{
    SEL selector = NSSelectorFromString([aScript stringByAppendingString:@"FromScript:"]);
    if (![self respondsToSelector:selector])
        return nil;
    return [self performSelector:selector withObject:aArguments];
}

- (id)speechSettings
{
    return [self HSSpeechObject_speechSettings];
}

- (id)HSSpeechObject_speechSettings
{
    if (_speechSettings == nil)
        _speechSettings = [[[SMKSpeechVoice defaultVoice] defaultSettings] mutableCopy];
    return _speechSettings;
}

- (id)speechDictionary
{
    return [[self speechTextParser] replacementWords];
}

- (void)dealloc
{
    [_speechTextParser release];
    [_speechSettings release];
    [super dealloc];
}

@end
