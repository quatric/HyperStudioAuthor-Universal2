#import "SMKSpeechSpokenObject.h"

// One queued speech request: text (or already processed speech data) plus
// its requestor and state flags.
@implementation SMKSpeechSpokenObject
- (void)setHasBeenSpoken
{
    _soFlags.beingSpoken = 0;
}
- (void)setHasBeenProcessed
{
    _soFlags.beingProcessedBySynth = 0;
}
- (void)prepareForSpeaking
{
    _soFlags.beingProcessedBySynth = 1;
    _soFlags.beingSpoken = 1;
}
- (BOOL)isBeingSpoken
{
    return _soFlags.beingSpoken;
}
- (BOOL)isBeingProcessedBySpeaker
{
    return _soFlags.beingProcessedBySynth;
}
- (id)dataToSpeak
{
    return _soFlags.processed ? _text.data : nil;
}
- (id)textToSpeak
{
    return _soFlags.processed ? nil : _text.string;
}
- (void)clearRequestor
{
    _requestor = nil;
}
- (id)requestor
{
    return _requestor;
}
- (void)setChooseVoiceBeforeProcessing:(BOOL)aProcessing
{
    _soFlags.chooseVoiceBeforeProcessing = aProcessing ? 1 : 0;
}
- (BOOL)chooseVoiceBeforeProcessing
{
    return _soFlags.chooseVoiceBeforeProcessing;
}
- (BOOL)isHighPriority
{
    return _soFlags.isHighPriority;
}
- (BOOL)needsParsing
{
    return _soFlags.needsParsing;
}
- (BOOL)shouldBeDropped
{
    return _soFlags.dropAsSoonAsPossible;
}
- (void)markAsShouldBeDropped
{
    _soFlags.dropAsSoonAsPossible = 1;
}
- (void)setDataToSpeak:(id)aSpeak
{
    [aSpeak retain];
    [_text.string release];
    _soFlags.processed = 1;
    _soFlags.needsParsing = 0;
    _text.data = aSpeak;
}
- (void)dealloc
{
    [_text.string release];
    [super dealloc];
}
- (id)initWithData:(id)aData requestor:(id)aRequestor highPriority:(BOOL)aPriority
{
    self = [super init];
    if (self) {
        [self _setRequestor:aRequestor];
        _soFlags.processed = 1;
        _text.data = [aData retain];
        if (aPriority)
            _soFlags.isHighPriority = 1;
    }
    return self;
}
- (id)initWithTextToSpeak:(id)aSpeak requestor:(id)aRequestor parsed:(BOOL)aParsed highPriority:(BOOL)aPriority
{
    id text;
    if ([aSpeak isKindOfClass:[NSAttributedString class]] || [aSpeak isKindOfClass:[NSMutableString class]]) {
        text = [aSpeak copy];
    } else {
        if (![aSpeak isKindOfClass:[NSString class]])
            [[NSAssertionHandler currentHandler] handleFailureInMethod:_cmd object:self
                file:[NSString stringWithUTF8String:"SMKSpeechSpokenObject.m"] lineNumber:32
                description:@"-[%@ %@]: text parameter should be either NSString or NSAttributedString",
                NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
        text = [aSpeak retain];
    }
    self = [super init];
    if (self) {
        [self _setRequestor:aRequestor];
        _soFlags.processed = 0;
        _text.string = text;
        if (!aParsed)
            _soFlags.needsParsing = 1;
        if (aPriority)
            _soFlags.isHighPriority = 1;
    }
    return self;
}
- (void)_setRequestor:(id)aRequestor
{
    _requestor = aRequestor;
}
@end
