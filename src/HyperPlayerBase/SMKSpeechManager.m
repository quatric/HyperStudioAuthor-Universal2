#import "SMKSpeechManager.h"
#import "SMKSpeechQueue.h"
#import "SMKSpeechSpokenObject.h"
#import "SMKSpeechTextParser.h"
#import "SMKSpeechVoice.h"
#import "SMKMutableSpeechSettings.h"

static NSString * const WBSpeechManagerDidFinishSpeakingNotification = @"WBSpeechManagerDidFinishSpeakingNotification";
static NSString * const WBSpeechManagerDidFinishProcessingTextNotification = @"WBSpeechManagerDidFinishProcessingTextNotification";

static SMKSpeechManager *SMKSharedSpeechManager = nil;
static Class SMKDefaultParserClass = Nil;
// The original enabled tuning from Mac OS X 10.2 on (Gestalt 'sysv' > 0x101f).
static BOOL SMKTuneEnabled = YES;
// Per-process object of the distributed notifications the speech callbacks
// post, so speech done/text done arrive on the main thread.
static NSString *SMKSpeechNotificationObject = nil;

static void SMKErrorCallBack(SpeechChannel aChannel, SRefCon aRefCon, OSErr aError, long aBytePos)
{
    [(SMKSpeechManager *)aRefCon speechError:aError];
}

static void SMKTextDoneCallBack(SpeechChannel aChannel, SRefCon aRefCon, const void **aNextBuffer, unsigned long *aByteLength, SInt32 *aControlFlags)
{
    *aNextBuffer = NULL;
    [(SMKSpeechManager *)aRefCon textDone];
}

static void SMKSpeechDoneCallBack(SpeechChannel aChannel, SRefCon aRefCon)
{
    [(SMKSpeechManager *)aRefCon speechDone];
}

// Speaks strings through one speech channel, queueing them per requestor.
// Paragraphs are parsed (and turned into channel data) by a timer before
// their turn comes.
@implementation SMKSpeechManager

+ (void)setDefaultParserClass:(Class)aClass
{
    SMKDefaultParserClass = aClass;
}

+ (Class)defaultParserClass
{
    return SMKDefaultParserClass;
}

+ (id)sharedSpeechManager
{
    if (SMKSharedSpeechManager == nil)
        [[self alloc] init];
    return SMKSharedSpeechManager;
}

+ (void)initialize
{
    static BOOL needsNotificationObject = YES;
    if (needsNotificationObject) {
        CFUUIDRef uuid = CFUUIDCreate(CFAllocatorGetDefault());
        CFStringRef string = CFUUIDCreateString(CFAllocatorGetDefault(), uuid);
        CFRelease(uuid);
        needsNotificationObject = NO;
        SMKSpeechNotificationObject = (NSString *)string;
    }
}

- (void)applicationDidBecomeActive:(id)aActive
{
    if (!_spmFlags.wasPausedOnDeactivate)
        return;
    _spmFlags.wasPausedOnDeactivate = 0;
    if (_spmFlags.isSpeaking && _spmFlags.paused)
        [self pauseOrContinueSpeech];
}

- (void)applicationWillResignActive:(id)aActive
{
    if (_spmFlags.isSpeaking && !_spmFlags.paused) {
        [self pauseOrContinueSpeech];
        _spmFlags.wasPausedOnDeactivate = 1;
    }
}

- (void)didFinishProcessingText:(id)aText
{
    [[_queue currentSpokenObject] setHasBeenProcessed];
}

// Quirk kept: speechManagerDoneSpeakingObject: is passed the manager, not the
// spoken object.
- (void)didFinishSpeaking:(id)aSpeaking
{
    SMKSpeechSpokenObject *object = [_queue currentSpokenObject];
    [object setHasBeenSpoken];
    if ([[object requestor] respondsToSelector:@selector(speechManagerDoneSpeakingObject:)])
        [[object requestor] speechManagerDoneSpeakingObject:self];
    if ([object shouldBeDropped])
        object = nil;
    else
        [object retain];
    SMKSpeechSpokenObject *next = [_queue nextSpokenObject];
    if (next != nil) {
        [self _speakObject:next];
    } else {
        _spmFlags.isSpeaking = 0;
        _spmFlags.paused = 0;
        [_speechSettings release];
        _speechSettings = nil;
        if ([[object requestor] respondsToSelector:@selector(speechManagerDidFinishSpeaking:)])
            [[object requestor] speechManagerDidFinishSpeaking:self];
    }
    [object release];
}

- (void)stopSpeech
{
    [self _stopAllSpeechImmediately:NO];
}

- (void)pauseOrContinueSpeech
{
    if (!_spmFlags.isSpeaking)
        return;
    if (!_spmFlags.paused) {
        [self channelPauseSpeech:NO];
        _spmFlags.paused = 1;
    } else {
        [self channelContinueSpeech];
        _spmFlags.paused = 0;
    }
}

- (BOOL)isPaused
{
    return _spmFlags.paused;
}

- (BOOL)isSpeaking
{
    return _spmFlags.isSpeaking;
}

- (BOOL)hasCurrentSpeechRequestedBy:(id)aBy
{
    NSParameterAssert(aBy != nil);
    return _spmFlags.isSpeaking && [[_queue currentSpokenObject] requestor] == aBy;
}

- (BOOL)hasPendingSpeechFromRequestor:(id)aRequestor
{
    NSParameterAssert(aRequestor != nil);
    return [_queue hasPendingObjectsWithRequestor:aRequestor];
}

- (void)cancelAllSpeechRequestedByObject:(id)aObject
{
    NSParameterAssert(aObject != nil);
    [self _cancelAllSpeechWithRequestor:aObject requestorWillBecomeInvalid:NO];
}

- (void)requestorWillBecomeInvalid:(id)aInvalid
{
    NSParameterAssert(aInvalid != nil);
    [self _cancelAllSpeechWithRequestor:aInvalid requestorWillBecomeInvalid:YES];
}

// One spoken object per paragraph; paragraphs the parser wants to see with
// their attributes are queued as attributed strings.
- (void)speakAttributedText:(id)aText immediately:(BOOL)aImmediately requestor:(id)aRequestor
{
    NSString *string = [aText string];
    NSUInteger length = [string length];
    id parser = [self _parserForRequestor:aRequestor];
    NSUInteger location = 0;
    while (YES) {
        NSUInteger start, end, contentsEnd;
        [string getLineStart:&start end:&end contentsEnd:&contentsEnd forRange:NSMakeRange(location, 0)];
        if (start < contentsEnd) {
            NSRange range = NSMakeRange(start, contentsEnd - start);
            id paragraph;
            if ([parser needsSpecialParsingForParagraphWithRange:range inAttributedString:aText])
                paragraph = [[[aText attributedSubstringFromRange:range] copy] autorelease];
            else
                paragraph = [string substringWithRange:range];
            [self _speakString:paragraph immediately:aImmediately requestor:aRequestor parsed:NO highPriority:NO];
            if (!_spmFlags.isBreakingLongText)
                _spmFlags.isBreakingLongText = 1;
        }
        if (end >= length)
            break;
        aImmediately = NO;
        location = end;
    }
    _spmFlags.isBreakingLongText = 0;
}

- (void)speakText:(id)aText immediately:(BOOL)aImmediately requestor:(id)aRequestor
{
    NSUInteger length = [aText length];
    NSUInteger location = 0;
    while (YES) {
        NSUInteger start, end, contentsEnd;
        [aText getLineStart:&start end:&end contentsEnd:&contentsEnd forRange:NSMakeRange(location, 0)];
        if (start < contentsEnd) {
            [self _speakString:[aText substringWithRange:NSMakeRange(start, contentsEnd - start)] immediately:aImmediately requestor:aRequestor parsed:NO highPriority:NO];
            if (!_spmFlags.isBreakingLongText)
                _spmFlags.isBreakingLongText = 1;
        }
        if (end >= length)
            break;
        aImmediately = NO;
        location = end;
    }
    _spmFlags.isBreakingLongText = 0;
}

- (void)speakString:(id)aString immediately:(BOOL)aImmediately requestor:(id)aRequestor
{
    [self speakString:aString immediately:aImmediately highPriority:NO needsParsing:YES requestor:aRequestor];
}

- (void)speakString:(id)aString immediately:(BOOL)aImmediately highPriority:(BOOL)aPriority needsParsing:(BOOL)aParsing requestor:(id)aRequestor
{
    [self _speakString:aString immediately:aImmediately requestor:aRequestor parsed:!aParsing highPriority:aPriority];
}

- (void)setReactsOnVoiceChangeASAP:(BOOL)aASAP
{
    _spmFlags.reactsOnSystemSpeechSettingsChangeASAP = aASAP != NO;
}

- (BOOL)reactsOnVoiceChangeASAP
{
    return _spmFlags.reactsOnSystemSpeechSettingsChangeASAP;
}

- (void)setStopsSpeechOnDeactivate:(BOOL)aDeactivate
{
    if ([self stopsSpeechOnDeactivate] == aDeactivate)
        return;
    [self _setRegisteredForCallbackNotifications:aDeactivate || [self pausesSpeechOnDeactivate]];
    _spmFlags.shouldStopOnDeactivate = aDeactivate != NO;
}

- (BOOL)stopsSpeechOnDeactivate
{
    return _spmFlags.shouldStopOnDeactivate;
}

- (void)setPausesSpeechOnDeactivate:(BOOL)aDeactivate
{
    if ([self pausesSpeechOnDeactivate] == aDeactivate)
        return;
    [self _setRegisteredForCallbackNotifications:aDeactivate || [self stopsSpeechOnDeactivate]];
    _spmFlags.shouldPauseOnDeactivate = aDeactivate != NO;
}

- (BOOL)pausesSpeechOnDeactivate
{
    return _spmFlags.shouldPauseOnDeactivate;
}

- (BOOL)isTuneEnabled
{
    return SMKTuneEnabled;
}

// A high priority string interrupts normal speech; over high priority speech
// it only replaces what is pending (when immediate).
- (void)_speakString:(id)aString immediately:(BOOL)aImmediately requestor:(id)aRequestor parsed:(BOOL)aParsed highPriority:(BOOL)aPriority
{
    if (_spmFlags.isSpeaking) {
        if (aPriority && [[_queue currentSpokenObject] isHighPriority]) {
            if (aImmediately)
                [_queue removeAllPendingObjects];
        } else if (aPriority || aImmediately) {
            [self _stopAllSpeechImmediately:YES];
        }
    }
    SMKSpeechSpokenObject *object = [[[SMKSpeechSpokenObject alloc] initWithTextToSpeak:aString requestor:aRequestor parsed:aParsed highPriority:aPriority] autorelease];
    if (!_spmFlags.isBreakingLongText)
        [object setChooseVoiceBeforeProcessing:YES];
    [self _appendSpeechQueueWithObject:object];
}

- (void)_cancelAllSpeechWithRequestor:(id)aRequestor requestorWillBecomeInvalid:(BOOL)aInvalid
{
    if (_spmFlags.isSpeaking && [[_queue currentSpokenObject] requestor] == aRequestor)
        [self channelStopSpeechImmediately:YES];
    [_queue removeAllPendingObjectsWithRequestor:aRequestor clearCurrent:aInvalid];
}

- (void)_stopAllSpeechImmediately:(BOOL)aImmediately
{
    if (!_spmFlags.isSpeaking)
        return;
    [self channelStopSpeechImmediately:aImmediately || _spmFlags.paused];
    [_queue removeAllPendingObjects];
    if (_spmFlags.paused)
        [self pauseOrContinueSpeech];
}

- (void)_appendSpeechQueueWithObject:(id)aObject
{
    id data = [aObject dataToSpeak];
    [_queue addSpokenObject:aObject];
    if (aObject == [_queue currentSpokenObject]) {
        [self _speakObject:aObject];
        return;
    }
    if (data == nil && _speechObjectsProcessingTimer == nil)
        _speechObjectsProcessingTimer = [[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(_doSomePendingObjectsProcessing) userInfo:nil repeats:YES] retain];
}

// The requestor's settings win; otherwise the system settings are applied when
// the object asks for a voice choice (or always when reacting ASAP) and they
// differ from the current ones. Quirk kept: chosen settings are applied
// before and again after preparing the object.
- (void)_speakObject:(id)aObject
{
    id data = [aObject dataToSpeak];
    id settings = nil;
    if ([[aObject requestor] respondsToSelector:@selector(speechSettings)])
        settings = [[aObject requestor] speechSettings];
    if (settings == nil) {
        if (_spmFlags.reactsOnSystemSpeechSettingsChangeASAP || [aObject chooseVoiceBeforeProcessing]) {
            settings = [SMKSpeechSettings systemSettings];
            if (_speechSettings != nil && [_speechSettings isEqual:settings])
                settings = nil;
        }
    }
    if (settings != nil)
        [self applySpeechSettings:settings];
    if (![self prepareSpeechChannel])
        return;
    if (data == nil) {
        [self _processSpokenObject:aObject];
        data = [aObject dataToSpeak];
    }
    [aObject prepareForSpeaking];
    if (settings != nil)
        [self applySpeechSettings:settings];
    if ([self channelSpeakText:data]) {
        _spmFlags.isSpeaking = 1;
        _spmFlags.paused = 0;
    }
}

- (void)_doSomePendingObjectsProcessing
{
    id object = [_queue firstObjectNeedingProcessing];
    if (object == nil) {
        [_speechObjectsProcessingTimer invalidate];
        [_speechObjectsProcessingTimer release];
        _speechObjectsProcessingTimer = nil;
    } else {
        [self _processSpokenObject:object];
    }
}

// Speech channels take Mac Roman text (lossy, then ASCII as the last resort).
- (void)_processSpokenObject:(id)aObject
{
    id text = [aObject textToSpeak];
    NSAssert(text != nil, @"_processSpokenObject: called for an object which doesn't require processing");
    id parser = [aObject needsParsing] ? [self _parserForRequestor:[aObject requestor]] : nil;
    if (parser != nil)
        text = [parser parseParagraph:text];
    else if ([text isKindOfClass:[NSAttributedString class]])
        text = [text string];
    NSData *data = [text dataUsingEncoding:NSMacOSRomanStringEncoding];
    if (data == nil)
        data = [text dataUsingEncoding:NSMacOSRomanStringEncoding allowLossyConversion:YES];
    if (data == nil)
        data = [text dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    if (data == nil) {
        NSLog(@"-[%@ %@]: cannot acquire data for spoken object %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), aObject);
        data = [NSData data];
    }
    [aObject setDataToSpeak:data];
}

- (id)textToWrappedPhonemes:(id)aPhonemes
{
    return [NSString stringWithFormat:@"[[inpt PHON]]%@[[inpt TEXT]]", [self textToPhonemes:aPhonemes]];
}

- (id)textToPhonemes:(id)aPhonemes
{
    return [self channelConvertTextToPhonemes:aPhonemes];
}

- (void)applySpeechSettings:(id)aSettings
{
    NSParameterAssert(aSettings);
    [self setChannelVoice:[aSettings voice]];
    [self setChannelPitch:[(SMKSpeechSettings *)aSettings pitch]];
    [self setChannelPitchModulation:[(SMKSpeechSettings *)aSettings pitchModulation]];
    [self setChannelVolume:[(SMKSpeechSettings *)aSettings volume]];
    [self setChannelRate:[(SMKSpeechSettings *)aSettings rate]];
    [_speechSettings release];
    _speechSettings = [aSettings retain];
}

- (id)speechSettings
{
    if (_speechSettings == nil)
        return [SMKSpeechSettings systemSettings];
    return _speechSettings;
}

- (id)_parserForRequestor:(id)aRequestor
{
    if ([aRequestor respondsToSelector:@selector(speechTextParser)]) {
        id parser = [aRequestor performSelector:@selector(speechTextParser)];
        if (parser != nil)
            return parser;
    }
    return [self _defaultParser];
}

- (void)setDefaultParser:(id)aParser
{
    [aParser retain];
    [_defaultParser release];
    _defaultParser = aParser;
}

- (id)defaultParser
{
    return _defaultParser;
}

- (id)_defaultParser
{
    if (_defaultParser == nil && SMKDefaultParserClass != Nil)
        _defaultParser = [SMKDefaultParserClass new];
    return _defaultParser;
}

- (void)_setRegisteredForCallbackNotifications:(BOOL)aNotifications
{
    BOOL registered = _spmFlags.shouldPauseOnDeactivate || _spmFlags.shouldStopOnDeactivate;
    if (registered == (aNotifications != NO))
        return;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (aNotifications) {
        [center addObserver:self selector:@selector(applicationWillResignActive:) name:NSApplicationWillResignActiveNotification object:NSApp];
        [center addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
    } else {
        [center removeObserver:self name:NSApplicationWillResignActiveNotification object:NSApp];
        [center removeObserver:self name:NSApplicationDidBecomeActiveNotification object:NSApp];
    }
}

// The original only invalidated the processing timer here; it is now released
// too.
- (void)dealloc
{
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_queue removeAllPendingObjects];
    if (_speechInfo != NULL) {
        [self channelStopSpeech];
        [self disposeSpeechChannel];
        free(_speechInfo);
        _speechInfo = NULL;
    }
    if (_speechObjectsProcessingTimer != nil) {
        [_speechObjectsProcessingTimer invalidate];
        [_speechObjectsProcessingTimer release];
        _speechObjectsProcessingTimer = nil;
    }
    [_queue release];
    _queue = nil;
    [_defaultParser release];
    [_speechSettings release];
    [super dealloc];
}

// Singleton: a second instance is deallocated and the shared one returned
// (unretained, as in the original).
- (id)init
{
    if (SMKSharedSpeechManager != nil) {
        [super dealloc];
        return SMKSharedSpeechManager;
    }
    self = [super init];
    if (self == nil)
        return nil;
    SMKSharedSpeechManager = self;
    _speechInfo = [self _allocateSpeechPrivateInfo];
    _queue = [SMKSpeechQueue new];
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didFinishSpeaking:) name:WBSpeechManagerDidFinishSpeakingNotification object:SMKSpeechNotificationObject suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    [center addObserver:self selector:@selector(didFinishProcessingText:) name:WBSpeechManagerDidFinishProcessingTextNotification object:SMKSpeechNotificationObject suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
    [self setPausesSpeechOnDeactivate:YES];
    return self;
}

@end

@implementation SMKSpeechManager (SpeechSynthesisCallbacks)

- (void)textDone
{
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:WBSpeechManagerDidFinishProcessingTextNotification object:SMKSpeechNotificationObject userInfo:nil deliverImmediately:YES];
}

- (void)speechDone
{
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:WBSpeechManagerDidFinishSpeakingNotification object:SMKSpeechNotificationObject userInfo:nil deliverImmediately:YES];
}

- (void)speechError:(short)aError
{
    NSLog(@"Speech error #%d.", (int)aError);
}

@end

#define SMKSpeechInfo ((struct _SMKSpeechPrivateInfo *)_speechInfo)

@implementation SMKSpeechManager (SpeechSynthesisWrappers)

// A nil voice selects the system default voice.
- (void)setChannelVoice:(id)aVoice
{
    if (![self prepareSpeechChannel])
        return;
    OSErr error;
    if (aVoice == nil) {
        VoiceDescription description;
        error = GetVoiceDescription(NULL, &description, sizeof(description));
        if (error != noErr)
            NSLog(@"GetVoiceDescription error #%d returned. (setChannelVoice)", (int)error);
        SMKSpeechInfo->f1 = description.voice;
    } else {
        SMKSpeechInfo->f1 = [(SMKSpeechVoice *)aVoice voiceSpec];
    }
    error = SetSpeechInfo(SMKSpeechInfo->f0, soCurrentVoice, &SMKSpeechInfo->f1);
    if (error != noErr)
        NSLog(@"SetSpeechInfo error #%d returned. (setChannelVoice)", (int)error);
}

- (void)setChannelRate:(CGFloat)aRate
{
    if (![self prepareSpeechChannel])
        return;
    OSErr error = SetSpeechRate(SMKSpeechInfo->f0, (Fixed)(float)(aRate * 65536.0f));
    if (error != noErr)
        NSLog(@"SetSpeechRate error #%d returned.", (int)error);
}

- (CGFloat)channelRate
{
    if (![self prepareSpeechChannel])
        return 0.0;
    Fixed rate = 0;
    OSErr error = GetSpeechRate(SMKSpeechInfo->f0, &rate);
    if (error == noErr)
        return (float)rate * 1.5258789e-05f;
    NSLog(@"GetSpeechRate error #%d returned.", (int)error);
    return 0.0;
}

- (void)setChannelPitchModulation:(CGFloat)aModulation
{
    if (![self prepareSpeechChannel])
        return;
    Fixed modulation = (Fixed)(float)(aModulation * 65536.0f);
    OSErr error = SetSpeechInfo(SMKSpeechInfo->f0, soPitchMod, &modulation);
    if (error != noErr)
        NSLog(@"SetSpeechInfo error #%d returned.", (int)error);
}

- (CGFloat)channelPitchModulation
{
    if (![self prepareSpeechChannel])
        return 0.0;
    Fixed modulation = 0;
    OSErr error = GetSpeechInfo(SMKSpeechInfo->f0, soPitchMod, &modulation);
    if (error == noErr)
        return (float)modulation * 1.5258789e-05f;
    NSLog(@"GetSpeechInfo error #%d returned.", (int)error);
    return 0.0;
}

- (void)setChannelPitch:(CGFloat)aPitch
{
    if (![self prepareSpeechChannel])
        return;
    OSErr error = SetSpeechPitch(SMKSpeechInfo->f0, (Fixed)(float)(aPitch * 65536.0f));
    if (error != noErr)
        NSLog(@"SetSpeechPitch error #%d returned.", (int)error);
}

- (CGFloat)channelPitch
{
    if (![self prepareSpeechChannel])
        return 0.0;
    Fixed pitch = 0;
    OSErr error = GetSpeechPitch(SMKSpeechInfo->f0, &pitch);
    if (error == noErr)
        return (float)pitch * 1.5258789e-05f;
    NSLog(@"GetSpeechPitch error #%d returned.", (int)error);
    return 0.0;
}

- (void)setChannelVolume:(CGFloat)aVolume
{
    if (![self prepareSpeechChannel])
        return;
    Fixed volume = (Fixed)(float)(aVolume * 65536.0f);
    OSErr error = SetSpeechInfo(SMKSpeechInfo->f0, soVolume, &volume);
    if (error != noErr)
        NSLog(@"SetSpeechInfo error #%d returned.", (int)error);
}

- (CGFloat)channelVolume
{
    if (![self prepareSpeechChannel])
        return 0.0;
    Fixed volume = 0;
    OSErr error = GetSpeechInfo(SMKSpeechInfo->f0, soVolume, &volume);
    if (error == noErr)
        return (float)volume * 1.5258789e-05f;
    NSLog(@"GetSpeechInfo error #%d returned.", (int)error);
    return 0.0;
}

// The phoneme handle is now disposed of on every path (the original leaked it
// when the channel or the conversion failed).
- (id)channelConvertTextToPhonemes:(id)aPhonemes
{
    long phonemeLength = 0;
    const char *text = [[aPhonemes dataUsingEncoding:NSMacOSRomanStringEncoding] bytes];
    Handle phonemes = NewHandle(0);
    NSString *result = nil;
    if ([self prepareSpeechChannel]) {
        OSErr error = TextToPhonemes(SMKSpeechInfo->f0, text, text ? strlen(text) : 0, phonemes, &phonemeLength);
        if (error == noErr)
            result = [[[NSString alloc] initWithBytes:*phonemes length:phonemeLength encoding:NSMacOSRomanStringEncoding] autorelease];
        else
            NSLog(@"TextToPhonemes error #%d returned.", (int)error);
    }
    DisposeHandle(phonemes);
    return result;
}

- (BOOL)channelContinueSpeech
{
    OSErr error = ContinueSpeech(SMKSpeechInfo->f0);
    if (error != noErr)
        NSLog(@"ContinueSpeech error #%d returned.", (int)error);
    return error == noErr;
}

// Not immediately: pause at the end of the word.
- (BOOL)channelPauseSpeech:(BOOL)aSpeech
{
    OSErr error = PauseSpeechAt(SMKSpeechInfo->f0, aSpeech ? kImmediate : kEndOfWord);
    if (error != noErr)
        NSLog(@"PauseSpeechAt error #%d returned.", (int)error);
    return error == noErr;
}

- (BOOL)channelStopSpeechImmediately:(BOOL)aImmediately
{
    OSErr error = StopSpeechAt(SMKSpeechInfo->f0, aImmediately ? kImmediate : kEndOfWord);
    if (error != noErr)
        NSLog(@"StopSpeechAt error #%d returned.", (int)error);
    return error == noErr;
}

- (BOOL)channelStopSpeech
{
    OSErr error = StopSpeech(SMKSpeechInfo->f0);
    if (error != noErr)
        NSLog(@"StopSpeechAt error #%d returned.", (int)error);
    return error == noErr;
}

- (BOOL)channelSpeakText:(id)aText
{
    OSErr error = SpeakText(SMKSpeechInfo->f0, [aText bytes], [aText length]);
    if (error != noErr)
        NSLog(@"SpeakText() error #%d returned.", (int)error);
    return error == noErr;
}

- (BOOL)prepareSpeechChannel
{
    if (SMKSpeechInfo->f0 == NULL && ![self createSpeechChannel])
        return NO;
    return YES;
}

- (BOOL)isSpeechChannelUsingDefaultVoice
{
    if (SMKSpeechInfo->f0 == NULL)
        return YES;
    VoiceDescription description;
    OSErr error = GetVoiceDescription(NULL, &description, sizeof(description));
    if (error != noErr) {
        NSLog(@"GetVoiceDescription error #%d returned.", (int)error);
        return NO;
    }
    return description.voice.id == SMKSpeechInfo->f1.id;
}

// The channel starts with the default voice; the callbacks get the manager as
// their reference constant.
- (BOOL)createSpeechChannel
{
    if (SMKSpeechInfo->f0 != NULL)
        [self disposeSpeechChannel];
    VoiceDescription description;
    OSErr error = GetVoiceDescription(NULL, &description, sizeof(description));
    NSString *format = nil;
    if (error == noErr) {
        SMKSpeechInfo->f1 = description.voice;
        error = NewSpeechChannel(&SMKSpeechInfo->f1, &SMKSpeechInfo->f0);
        if (error != noErr)
            format = @"NewSpeechChannel error #%d returned.";
        else if ((error = SetSpeechInfo(SMKSpeechInfo->f0, soRefCon, (void *)self)) != noErr)
            format = @"SetSpeechInfo (soRefCon) error #%d returned.";
        else if ((error = SetSpeechInfo(SMKSpeechInfo->f0, soErrorCallBack, (void *)SMKErrorCallBack)) != noErr)
            format = @"SetSpeechInfo (soErrorCallBack) error #%d returned.";
        else if ((error = SetSpeechInfo(SMKSpeechInfo->f0, soSpeechDoneCallBack, (void *)SMKSpeechDoneCallBack)) != noErr)
            format = @"SetSpeechInfo (soSpeechDoneCallBack) error #%d returned.";
        else if ((error = SetSpeechInfo(SMKSpeechInfo->f0, soTextDoneCallBack, (void *)SMKTextDoneCallBack)) != noErr)
            format = @"SetSpeechInfo (soTextDoneCallBack) error #%d returned.";
    } else {
        format = @"NewSpeechChannel error #%d returned.";
    }
    if (format != nil)
        NSLog(format, (int)error);
    return error == noErr;
}

- (BOOL)disposeSpeechChannel
{
    OSErr error = noErr;
    if (SMKSpeechInfo->f0 != NULL) {
        error = DisposeSpeechChannel(SMKSpeechInfo->f0);
        if (error != noErr)
            NSLog(@"DisposeSpeechChannel error #%d returned.", (int)error);
        SMKSpeechInfo->f0 = NULL;
    }
    return error == noErr;
}

- (struct _SMKSpeechPrivateInfo *)_allocateSpeechPrivateInfo
{
    return calloc(1, sizeof(struct _SMKSpeechPrivateInfo));
}

@end
