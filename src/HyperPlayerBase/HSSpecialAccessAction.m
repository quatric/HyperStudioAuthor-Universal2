#import "HSSpecialAccessAction.h"

// Base of the special-access (switch scanning) actions: highlights buttons in
// turn and gives an audio cue (spoken title or a custom sound) for each.
@implementation HSSpecialAccessAction
- (id)HTML5DictionaryRepresentationInContext:(id)aContext
{
    id dictionary = [super HTML5DictionaryRepresentationInContext:aContext];
    [dictionary setObject:[NSString stringWithFormat:@"%i", (int)[self audioCueType]] forKey:@"audioCueType"];
    id audioMedia = [self audioMedia];
    if (audioMedia) {
        [dictionary setObject:[@"Resources" stringByAppendingPathComponent:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:audioMedia]] forKey:@"src"];
        [aContext addMedia:audioMedia];
    }
    if ([self audioCueType] == 1) {
        // Pre-render the spoken button titles to sound files.
        NSArray *buttons = [self availableButtons];
        NSSpeechSynthesizer *synthesizer = [[NSSpeechSynthesizer alloc] initWithVoice:[NSSpeechSynthesizer defaultVoice]];
        NSMutableArray *sounds = [NSMutableArray array];
        for (id button in buttons) {
            if (![self canUseObject:button])
                continue;
            NSString *title = [[button queryHyperInterface:@protocol(HSTitleAttributes)] title];
            if (title == nil)
                continue;
            NSURL *URL = [NSURL fileURLWithPath:[HSTemporaryFilesManager generatedTempFilePathWithExtension:@"aiff"]];
            if (![synthesizer startSpeakingString:title toURL:URL])
                continue;
            while ([synthesizer isSpeaking])
                ;
            NSMutableDictionary *sound = [[NSMutableDictionary alloc] init];
            [sound setObject:[[button hyperUID] stringValue] forKey:@"object"];
            id media = [HSNewMedia mediaWithPath:[URL path]];
            [sound setObject:[@"Resources" stringByAppendingPathComponent:[HSHTML5ExporterHelper JSonCorrectFilenameForMedia:media]] forKey:@"src"];
            [aContext addMedia:media];
            [sounds addObject:sound];
            [sound release];
        }
        [synthesizer release];
        [dictionary setObject:sounds forKey:@"src"];
    }
    return dictionary;
}
- (id)XMLElementRepresentationInContext:(id)aContext
{
    id element = [super XMLElementRepresentationInContext:aContext];
    [element addAttribute:[NSXMLNode attributeWithName:@"audioType" stringValue:[self audioCueTypeString]]];
    id UID = [self audioMediaUID];
    if (UID)
        [element addAttribute:[NSXMLNode attributeWithName:@"audioMediaUID" stringValue:[UID stringValue]]];
    return element;
}
- (id)audioCueTypeString
{
    switch (_audioCueType) {
    case 0: return @"HSSpecialAccessAudioCueNone";
    case 1: return @"HSSpecialAccessAudioCueButtomName";
    case 2: return @"HSSpecialAccessAudioCueCustom";
    default: return nil;
    }
}
- (BOOL)canBeStoredAsXMLElement
{
    return YES;
}
- (BOOL)canBeStopped
{
    return YES;
}
- (id)sound
{
    if (_sound == nil && [self audioMedia]) {
        NSError *error = nil;
        NSString *path = [[self audioMedia] fullPathToMediaFileCreateIfNeeded:YES];
        if (path)
            _sound = [[HSMovie alloc] initWithURL:[NSURL fileURLWithPath:path] error:&error];
        if (error) {
            [_sound release];
            _sound = nil;
        }
    }
    return _sound;
}
- (id)highlightedObject
{
    return _highlightedObject;
}
- (void)highlightObject:(id)aObject
{
    if (_highlightedObject) {
        [[_highlightedObject queryHyperInterface:@protocol(HSSystemButtonSpecialAccessHighlightAttributes)] setSpecialAccessHighlightActive:NO];
        [self didUnhighlightObject:_highlightedObject];
    }
    [_highlightedObject autorelease];
    _highlightedObject = [aObject retain];
    if (_highlightedObject) {
        [[_highlightedObject queryHyperInterface:@protocol(HSSystemButtonSpecialAccessHighlightAttributes)] setSpecialAccessHighlightActive:YES];
        [self didHighlightObject:_highlightedObject];
    }
}
- (void)didUnhighlightObject:(id)aObject
{
    NSInteger type = [self audioCueType];
    if (type == 2) {
        if ([self sound])
            [[HSActionMediaPlayer sharedActionMediaPlayer] stopSoundForObject:aObject];
    } else if (type == 1) {
        [self cancelPreviousSpeak];
    }
}
- (void)didHighlightObject:(id)aObject
{
    NSInteger type = [self audioCueType];
    if (type == 2) {
        id sound = [self sound];
        if (sound)
            [[HSActionMediaPlayer sharedActionMediaPlayer] startSound:sound forObject:aObject];
    } else if (type == 1) {
        NSString *title = [[aObject queryHyperInterface:@protocol(HSTitleAttributes)] title];
        if (title)
            [self speakText:title];
    }
}
- (void)cancelPreviousSpeak
{
    [[SMKSpeechManager sharedSpeechManager] cancelAllSpeechRequestedByObject:self];
}
- (void)speakText:(id)aText
{
    [[SMKSpeechManager sharedSpeechManager] speakString:aText immediately:NO highPriority:NO needsParsing:YES requestor:self];
}
- (id)ownedMediaUIDs
{
    return [NSCountedSet setWithSet:[self mediaUIDs]];
}
- (id)mediaUIDs
{
    id UID = [self audioMediaUID];
    return UID ? [NSSet setWithObject:UID] : nil;
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:@"audioCueType", @"audioMediaUID", nil]];
}
- (void)setAudioMedia:(id)aMedia
{
    if ([_audioMedia isEqual:aMedia])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSButtonScannerSetAudioCueType" value:@"" table:@"UndoManager"]];
    [[[self undoManager] prepareWithInvocationTarget:self] setAudioMedia:[self audioMedia]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSpecialAccessAudioMediaAttribute) ofObject:self withUserInfo:nil];
    [_audioMedia release];
    _audioMedia = [aMedia retain];
    // The cached _sound is kept as in the original.
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSpecialAccessAudioMediaAttribute) ofObject:self withUserInfo:nil];
}
- (id)audioMedia
{
    return _audioMedia;
}
- (void)setAudioMediaUID:(id)aUID
{
    if (![[self audioMediaUID] isEqual:aUID])
        [self setAudioMedia:[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:aUID]];
}
- (id)audioMediaUID
{
    return [[self audioMedia] mediaUID];
}
- (void)setAudioCueType:(NSInteger)aType
{
    if (_audioCueType == aType)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"HSButtonScannerSetAudioCueType" value:@"" table:@"UndoManager"]];
    [(HSSpecialAccessAction *)[[self undoManager] prepareWithInvocationTarget:self] setAudioCueType:[self audioCueType]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSpecialAccessAudioCueAttribute) ofObject:self withUserInfo:nil];
    _audioCueType = (int)aType;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSpecialAccessAudioCueAttribute) ofObject:self withUserInfo:nil];
}
- (NSInteger)audioCueType
{
    return _audioCueType;
}
- (void)dealloc
{
    [[SMKSpeechManager sharedSpeechManager] requestorWillBecomeInvalid:self];
    [_audioMedia release];
    [_sound release];
    [_highlightedObject release];
    [super dealloc];
}
@end
