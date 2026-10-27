#import "HSTextToSpeechAction.h"
#import "SMKMutableSpeechSettings.h"
#import "SMKSpeechManager.h"
#import "SMKSpeechVoice.h"

// Speaks a text, or a text object's text, through the speech manager.
// Rate and pitch are relative steps (-2 to 2) around the default voice's.
@implementation HSTextToSpeechAction

+ (CGFloat)speechRateFromRelativeValue:(NSInteger)aValue
{
    float rate = [(SMKSpeechSettings *)[[SMKSpeechVoice defaultVoice] defaultSettings] rate];
    switch (aValue) {
    case 1:
        rate += 40.0;
        break;
    case 2:
        rate += 100.0;
        break;
    case -2:
        rate -= 100.0;
        break;
    case -1:
        rate -= 40.0;
        break;
    default:
        break;
    }
    return rate;
}

+ (CGFloat)speechPitchFromRelativeValue:(NSInteger)aValue
{
    float pitch = [(SMKSpeechSettings *)[[SMKSpeechVoice defaultVoice] defaultSettings] pitch];
    float modulation = [[[SMKSpeechVoice defaultVoice] defaultSettings] pitchModulation];
    switch (aValue) {
    case 1:
        pitch += modulation * 0.5;
        break;
    case 2:
        pitch += modulation;
        break;
    case -2:
        pitch -= modulation;
        break;
    case -1:
        pitch -= modulation * 0.5;
        break;
    default:
        break;
    }
    return pitch;
}

- (BOOL)isValid
{
    if ([self usesTextObject])
        return [self textObjectUID] != nil;
    return [[self textToSpeak] length] != 0;
}

// Finishes at the end mark; waits when the next file isn't converted yet.
// The first unplayed file's movie (nil for a missing or unreadable file),
// taken out of the unplayed files.
- (void)speechManagerDidFinishSpeaking:(id)aSpeaking
{
    [self notifyDidFinish];
}

- (BOOL)canBeStopped
{
    return YES;
}

- (void)stop:(id)aStop
{
    [[SMKSpeechManager sharedSpeechManager] cancelAllSpeechRequestedByObject:self];
    [super stop:aStop];
}

- (void)pause
{
    if (![[SMKSpeechManager sharedSpeechManager] isPaused])
        [[SMKSpeechManager sharedSpeechManager] pauseOrContinueSpeech];
}

- (void)resume
{
    if ([[SMKSpeechManager sharedSpeechManager] isPaused])
        [[SMKSpeechManager sharedSpeechManager] pauseOrContinueSpeech];
}

- (void)startInContext:(id)aContext
{
    id text = [self textToSpeak];
    if ([self usesTextObject] && [self textObjectUID] != nil) {
        id object = [[[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childWithUID:[self textObjectUID]];
        text = [[object queryHyperInterface:@protocol(HSStringContentAttributes)] hyperStringValue];
    }
    if ([text length] != 0) {
        [[SMKSpeechManager sharedSpeechManager] speakString:text immediately:NO highPriority:NO needsParsing:YES requestor:self];
    }
}

- (void)setVoiceName:(id)aName
{
    for (SMKSpeechVoice *voice in [SMKSpeechVoice availableVoices]) {
        if ([[voice name] isEqual:aName]) {
            [self setSpeechVoice:voice];
            return;
        }
    }
}

- (id)voiceName
{
    return [(SMKSpeechVoice *)[self speechVoice] name];
}

- (void)setSpeechVoice:(id)aVoice
{
    if ([[[self speechSettings] voice] isEqual:aVoice])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Speech Voice" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSpeechVoice:[self speechVoice]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTextToSpeechVoiceAttribute) ofObject:self withUserInfo:nil];
    [(SMKMutableSpeechSettings *)[self HSTextToSpeechAction_speechSettings] setVoice:aVoice];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTextToSpeechVoiceAttribute) ofObject:self withUserInfo:nil];
}

- (id)speechVoice
{
    return [[self speechSettings] voice];
}

- (void)setRelativeSpeechRate:(NSInteger)aRate
{
    if ([self relativeSpeechRate] == aRate)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Speech Rate" value:@"" table:@"UndoManager"]];
    [(HSTextToSpeechAction *)[[self undoManager] prepareWithInvocationTarget:self] setRelativeSpeechRate:[self relativeSpeechRate]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTextToSpeechRateAttribute) ofObject:self withUserInfo:nil];
    _speechRate = (int)aRate;
    [(SMKMutableSpeechSettings *)[self HSTextToSpeechAction_speechSettings] setRate:[[self class] speechRateFromRelativeValue:_speechRate]];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTextToSpeechRateAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)relativeSpeechRate
{
    return _speechRate;
}

- (void)setRelativeSpeechPitch:(NSInteger)aPitch
{
    if ([self relativeSpeechPitch] == aPitch)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Speech Pitch" value:@"" table:@"UndoManager"]];
    [(HSTextToSpeechAction *)[[self undoManager] prepareWithInvocationTarget:self] setRelativeSpeechPitch:[self relativeSpeechPitch]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTextToSpeechPitchAttribute) ofObject:self withUserInfo:nil];
    _speechPitch = (int)aPitch;
    [(SMKMutableSpeechSettings *)[self HSTextToSpeechAction_speechSettings] setPitch:[[self class] speechPitchFromRelativeValue:_speechPitch]];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSTextToSpeechPitchAttribute) ofObject:self withUserInfo:nil];
}

- (NSInteger)relativeSpeechPitch
{
    return _speechPitch;
}

- (void)setUsesTextObject:(BOOL)aObject
{
    if (_usesTextObject == aObject)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Text Object to Speak" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setUsesTextObject:[self usesTextObject]];
    id center = [self attributeNotificationCenter];
    [center notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:1 ofAttribute:@protocol(HSTextToSpeechUsesTextObjectAttribute) ofObject:self withUserInfo:nil];
    _usesTextObject = aObject;
    [center notifyChange:2 ofAttribute:@protocol(HSTextToSpeechUsesTextObjectAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (BOOL)usesTextObject
{
    return _usesTextObject;
}

- (void)setTextObjectUID:(id)aUID
{
    if ([_textObjectUID isEqual:aUID])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Text Object to Speak" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTextObjectUID:[self textObjectUID]];
    id center = [self attributeNotificationCenter];
    [center notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:1 ofAttribute:@protocol(HSTextObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [_textObjectUID release];
    _textObjectUID = [aUID retain];
    [center notifyChange:2 ofAttribute:@protocol(HSTextObjectUIDAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)textObjectUID
{
    return _textObjectUID;
}

- (void)setTextToSpeak:(id)aSpeak
{
    if ([_textToSpeak isEqual:aSpeak])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Text to Speak" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setTextToSpeak:[self textToSpeak]];
    id center = [self attributeNotificationCenter];
    [center notifyChange:1 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:1 ofAttribute:@protocol(HSTextToSpeakAttribute) ofObject:self withUserInfo:nil];
    [_textToSpeak release];
    _textToSpeak = [aSpeak retain];
    [center notifyChange:2 ofAttribute:@protocol(HSTextToSpeakAttribute) ofObject:self withUserInfo:nil];
    [center notifyChange:2 ofAttribute:@protocol(HSActionValidationStatusAttribute) ofObject:self withUserInfo:nil];
}

- (id)textToSpeak
{
    if (_textToSpeak == nil)
        _textToSpeak = [NSString new];
    return _textToSpeak;
}

- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    if ([self usesTextObject] && [aDs containsObject:[self textObjectUID]])
        return nil;
    return [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
}

- (id)speechSettings
{
    return [self HSTextToSpeechAction_speechSettings];
}

// A copy of the default voice's settings.
- (id)HSTextToSpeechAction_speechSettings
{
    if (_speechSettings == nil)
        _speechSettings = [[[SMKSpeechVoice defaultVoice] defaultSettings] mutableCopy];
    return _speechSettings;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    NSArray *keys = [NSArray arrayWithObjects:@"textToSpeak", @"textObjectUID", @"usesTextObject", @"relativeSpeechPitch", @"relativeSpeechRate", @"voiceName", nil];
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:keys];
}

- (void)dealloc
{
    [[SMKSpeechManager sharedSpeechManager] requestorWillBecomeInvalid:self];
    [_textToSpeak release];
    // Fixed: the text object UID and the speech settings leaked.
    [_textObjectUID release];
    [_speechSettings release];
    [super dealloc];
}

@end
