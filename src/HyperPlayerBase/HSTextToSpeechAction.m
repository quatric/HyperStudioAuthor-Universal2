#import "HSTextToSpeechAction.h"
#import "HSActionMediaPlayer.h"
#import "HSMovie.h"
#import "HSTextToMovieConverter.h"
#import "NSMutableArray+EXMutableArray.h"
#import "SMKMutableSpeechSettings.h"
#import "SMKSpeechManager.h"
#import "SMKSpeechVoice.h"

// Speaks a text, or a text object's text: a converter turns it into sound
// files component by component, played one after another through the
// action media player. An NSNull in the unplayed files marks the end.
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

- (void)converterDidfinishConvertingAllComponents
{
    [self setUnplayedMoviesLastComponentMark];
}

- (void)converterDidFinishConvertingComponentToFile:(id)aFile
{
    if (aFile == nil)
        return;
    [[self unplayedMovieFilePaths] addObject:aFile];
    if ([self currentlyPlayingMovie] == nil)
        [self speakNextComponent];
}

- (void)movieDidStop:(id)aStop
{
}

- (void)movieDidPlayOnce:(id)aOnce
{
}

- (void)movieDidChangeImage:(id)aImage
{
}

- (void)movieDidEnd:(id)aEnd
{
    [self speakNextComponent];
}

- (BOOL)isValid
{
    if ([self usesTextObject])
        return [self textObjectUID] != nil;
    return [[self textToSpeak] length] != 0;
}

- (BOOL)isUnplayedMoviesLastComponentMark
{
    return [NSNull null] == [[self unplayedMovieFilePaths] extraFirstObject];
}

- (void)setUnplayedMoviesLastComponentMark
{
    [[self unplayedMovieFilePaths] addObject:[NSNull null]];
}

// Finishes at the end mark; waits when the next file isn't converted yet.
- (void)speakNextComponent
{
    if ([self isUnplayedMoviesLastComponentMark]) {
        [self notifyDidFinish];
        return;
    }
    [self setCurrentlyPlayingMovie:[self nextMovieComponentForSpeaking]];
    if ([self currentlyPlayingMovie] == nil)
        return;
    [[HSActionMediaPlayer sharedActionMediaPlayer] startSound:[self currentlyPlayingMovie] forObject:self];
    [[self currentlyPlayingMovie] setDelegate:self];
}

// The first unplayed file's movie (nil for a missing or unreadable file),
// taken out of the unplayed files.
- (id)nextMovieComponentForSpeaking
{
    id path = [[self unplayedMovieFilePaths] extraFirstObject];
    id movie = nil;
    NSURL *URL = [NSURL fileURLWithPath:path];
    if (URL != nil && [[NSFileManager defaultManager] fileExistsAtPath:path] && [[NSFileManager defaultManager] isReadableFileAtPath:path])
        movie = [HSMovie movieWithURL:URL error:NULL];
    [[self unplayedMovieFilePaths] removeObject:path];
    return movie;
}

- (void)speechManagerDidFinishSpeaking:(id)aSpeaking
{
    [self notifyDidFinish];
}

- (void)stop:(id)aStop
{
    [[self textToMovieConverter] stopConverting];
    [super stop:aStop];
}

- (BOOL)canBeStopped
{
    return YES;
}

- (void)startInContext:(id)aContext
{
    id text = [self textToSpeak];
    if ([self usesTextObject] && [self textObjectUID] != nil) {
        id object = [[[self card] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childWithUID:[self textObjectUID]];
        text = [[object queryHyperInterface:@protocol(HSStringContentAttributes)] hyperStringValue];
    }
    if ([text length] == 0)
        return;
    HSTextToMovieConverter *converter = [[HSTextToMovieConverter alloc] initWithSpeachSynthesizer:[self speechSynthezier] textToConvert:text];
    [self setTextToMovieConverter:converter];
    // Fixed: the converter leaked.
    [converter release];
    [[self textToMovieConverter] startConverting];
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

// The first synthesizer voice whose identifier contains the voice name.
- (id)voiceIdentifier
{
    for (NSString *identifier in [NSSpeechSynthesizer availableVoices]) {
        if ([identifier rangeOfString:[self voiceName]].length != 0)
            return identifier;
    }
    return nil;
}

- (void)setSpeechVoice:(id)aVoice
{
    if ([[[self speechSettings] voice] isEqual:aVoice])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Speech Voice" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setSpeechVoice:[self speechVoice]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSTextToSpeechVoiceAttribute) ofObject:self withUserInfo:nil];
    [(SMKMutableSpeechSettings *)[self HSTextToSpeechAction_speechSettings] setVoice:aVoice];
    [(NSSpeechSynthesizer *)[self speechSynthezier] setVoice:[self voiceIdentifier]];
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
    [[self speechSynthezier] setObject:[NSNumber numberWithFloat:[[self class] speechRateFromRelativeValue:aRate]] forProperty:NSSpeechRateProperty error:NULL];
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
    [[self speechSynthezier] setObject:[NSNumber numberWithFloat:[[self class] speechPitchFromRelativeValue:aPitch]] forProperty:NSSpeechPitchBaseProperty error:NULL];
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

- (id)unplayedMovieFilePaths
{
    if (_unplayedMovieFilePaths == nil)
        _unplayedMovieFilePaths = [[NSMutableArray alloc] init];
    return _unplayedMovieFilePaths;
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

- (id)currentlyPlayingMovie
{
    return _currentlyPlayingMovie;
}

- (void)setCurrentlyPlayingMovie:(id)aMovie
{
    if (_currentlyPlayingMovie == aMovie)
        return;
    [_currentlyPlayingMovie setDelegate:nil];
    [_currentlyPlayingMovie release];
    _currentlyPlayingMovie = [aMovie retain];
    [_currentlyPlayingMovie setDelegate:self];
}

- (id)textToMovieConverter
{
    return _textToMovieConverter;
}

- (void)setTextToMovieConverter:(id)aConverter
{
    if (_textToMovieConverter == aConverter)
        return;
    [_textToMovieConverter setDelegate:nil];
    [_textToMovieConverter release];
    _textToMovieConverter = [aConverter retain];
    [_textToMovieConverter setDelegate:self];
}

- (void)setSpeechSynthezier:(id)aSynthezier
{
    if (_speechSynthezier == aSynthezier)
        return;
    [_speechSynthezier release];
    _speechSynthezier = [aSynthezier retain];
}

- (id)speechSynthezier
{
    if (_speechSynthezier == nil)
        _speechSynthezier = [[NSSpeechSynthesizer alloc] initWithVoice:[self voiceIdentifier]];
    return _speechSynthezier;
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
    [_speechSynthezier release];
    [self setCurrentlyPlayingMovie:nil];
    [self setTextToMovieConverter:nil];
    [_unplayedMovieFilePaths release];
    // Fixed: the text object UID and the speech settings leaked.
    [_textObjectUID release];
    [_speechSettings release];
    [super dealloc];
}

@end
