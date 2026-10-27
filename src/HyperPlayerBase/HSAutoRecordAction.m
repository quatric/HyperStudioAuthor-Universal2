#import "HSAutoRecordAction.h"
#import "AUInputDeviceFile.h"

// Before AppKit 1138 (10.7) recording went through AUInputDeviceFile, later through AVAudioRecorder.
static BOOL HSAutoRecordAction_usesAudioUnitRecorder(void)
{
    return NSAppKitVersionNumber < 1138.0;
}

@implementation HSAutoRecordAction
- (void)audioRecorderEncodeErrorDidOccur:(id)aOccur error:(id)aError
{
    [self performSelectorOnMainThread:@selector(informAboutDiskSpaceError) withObject:self waitUntilDone:YES];
}
- (void)audioRecorderDidFinishRecording:(id)aRecording successfully:(BOOL)aSuccessfully
{
}
- (void)informAboutDiskSpaceError
{
    HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
    NSString *ok = [provider localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
    NSString *message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Free some disk space and try recording again." value:@"" table:@"Alerts"];
    NSString *title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Not enough disk space to save sound being recorded" value:@"" table:@"Alerts"];
    NSRunCriticalAlertPanel(title, @"%@", ok, nil, nil, message);
}
// AUInputDeviceFile delegate callback.
- (BOOL)handleDeviceFile:(id)aFile recordingError:(NSInteger)aError
{
    [(AUInputDeviceFile *)_audioRecorder stop];
    [self performSelectorOnMainThread:@selector(informAboutDiskSpaceError) withObject:self waitUntilDone:YES];
    return YES;
}
- (void)setRecordName:(id)aName
{
    if ([[self recordName] isEqualToString:aName])
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Sound Name" value:@"" table:@"UndoManager"]];
    [(HSAutoRecordAction *)[[self undoManager] prepareWithInvocationTarget:self] setRecordName:[self recordName]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSRecordNameAttribute) ofObject:self withUserInfo:nil];
    [_recordName release];
    _recordName = [aName retain];
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSRecordNameAttribute) ofObject:self withUserInfo:nil];
}
- (id)recordName
{
    return _recordName;
}
- (void)setSensitivityLevel:(NSInteger)aLevel
{
    if ([self sensitivityLevel] == aLevel)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Sensitivity" value:@"" table:@"UndoManager"]];
    [(HSAutoRecordAction *)[[self undoManager] prepareWithInvocationTarget:self] setSensitivityLevel:[self sensitivityLevel]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSSensitivityLevelAttribute) ofObject:self withUserInfo:nil];
    _sensitivityLevel = (int)aLevel;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSSensitivityLevelAttribute) ofObject:self withUserInfo:nil];
}
- (NSInteger)sensitivityLevel
{
    return _sensitivityLevel;
}
- (void)setRecordTime:(double)aTime
{
    if ([self recordTime] == aTime)
        return;
    [[self undoManager] setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Set Seconds to Record" value:@"" table:@"UndoManager"]];
    [(HSAutoRecordAction *)[[self undoManager] prepareWithInvocationTarget:self] setRecordTime:[self recordTime]];
    [[self attributeNotificationCenter] notifyChange:1 ofAttribute:@protocol(HSRecordTimeAttribute) ofObject:self withUserInfo:nil];
    _recordTime = aTime;
    [[self attributeNotificationCenter] notifyChange:2 ofAttribute:@protocol(HSRecordTimeAttribute) ofObject:self withUserInfo:nil];
}
- (double)recordTime
{
    return _recordTime;
}
// The recording is saved next to the document as "<recordName>.aiff" on the next run loop pass.
- (void)stopRecordingAction
{
    if ([self isRecording])
        [(AVAudioRecorder *)[self audioRecorder] stop];
    [_context setIsRecording:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *folder = [_context documentAuxillaryPath];
    if (folder != nil) {
        NSString *extension = [[[self recordName] pathExtension] lowercaseString];
        NSString *fileName = [[self recordName] hyperStringByReplacingSlashesWithColons];
        if (![extension isEqualToString:@"aiff"])
            fileName = [fileName stringByAppendingPathExtension:@"aiff"];
        NSString *path = [[folder stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:path, @"recordPath", [self audioRecorder], @"audioRecorder", nil];
        [self performSelector:@selector(saveAudioFileWithContextInfo:) withObject:info afterDelay:0.0];
    }
    [self notifyDidFinish];
}
- (void)saveAudioFileWithContextInfo:(id)aInfo
{
    NSString *path = [aInfo objectForKey:@"recordPath"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByExpandingTildeInPath]]) {
        NSString *displayName = [[NSFileManager defaultManager] displayNameAtPath:[path stringByExpandingTildeInPath]];
        BOOL writable = [[NSFileManager defaultManager] isWritableFileAtPath:[path stringByExpandingTildeInPath]];
        HSExecutableResourceProvider *provider = [HSExecutableResourceProvider sharedInstance];
        NSString *messageText;
        NSString *informativeText;
        if (!writable) {
            messageText = [NSString stringWithFormat:[provider localizedStringForKey:@"HSReplaceReadOnlyFileTitle" value:@"" table:@"Alerts"], displayName];
            NSString *folderName = [[path stringByDeletingLastPathComponent] lastPathComponent];
            informativeText = [NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSReplaceReadOnlyFileMessage" value:@"" table:@"Alerts"], folderName];
        } else {
            messageText = [NSString stringWithFormat:[provider localizedStringForKey:@"Are you sure you want to replace the sound file \"%@\"?" value:@"" table:@"Alerts"], displayName];
            NSString *folderName = [[path stringByDeletingLastPathComponent] lastPathComponent];
            informativeText = [NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"This file already exists in the location \"%@\"." value:@"" table:@"Alerts"], folderName];
        }
        NSString *cancel = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"];
        NSString *replace = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Replace" value:@"" table:@"Alerts"];
        NSAlert *alert = [NSAlert new];
        [alert setMessageText:messageText];
        [alert setInformativeText:informativeText];
        [alert addButtonWithTitle:replace];
        [alert addButtonWithTitle:cancel];
        NSInteger result = [alert runModal];
        [alert release];
        if (result != NSAlertFirstButtonReturn)
            return;
        [[NSFileManager defaultManager] moveFileToUserTrash:[path stringByExpandingTildeInPath] createUniqueFileInTrash:NO];
    }
    id recorder = [aInfo objectForKey:@"audioRecorder"];
    BOOL saved;
    if (HSAutoRecordAction_usesAudioUnitRecorder())
        saved = [(AUInputDeviceFile *)recorder writeToFile:[path stringByExpandingTildeInPath] atomically:YES];
    else
        saved = [[NSFileManager defaultManager] moveItemAtPath:[[(AVAudioRecorder *)recorder url] path] toPath:[path stringByExpandingTildeInPath] error:NULL];
    if (!saved) {
        NSAlert *alert = [[NSAlert new] autorelease];
        NSString *fileName = [[path lastPathComponent] hyperStringByReplacingColonsWithSlashes];
        [alert setMessageText:[NSString stringWithFormat:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSCantSaveRecordedFileMessage" value:@"" table:@"Alerts"], fileName]];
        [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSCantSaveRecordedFileDescription" value:@"" table:@"Alerts"]];
        [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
        [alert runModal];
    }
}
- (BOOL)isRecording
{
    id recorder = [self audioRecorder];
    if (HSAutoRecordAction_usesAudioUnitRecorder())
        return [(AUInputDeviceFile *)recorder isRunning];
    return [(AVAudioRecorder *)recorder isRecording];
}
- (void)stopAudioRecorder
{
    if (_audioRecorder == nil)
        return;
    if ([self isRecording])
        [(AVAudioRecorder *)_audioRecorder stop];
    [_audioRecorder setDelegate:nil];
    [_audioRecorder release];
    _audioRecorder = nil;
}
- (void)startAudioRecorder
{
    if (HSAutoRecordAction_usesAudioUnitRecorder()) {
        [(AUInputDeviceFile *)[self audioRecorder] start];
    } else {
        [(AVAudioRecorder *)[self audioRecorder] prepareToRecord];
        [(AVAudioRecorder *)[self audioRecorder] record];
    }
}
// Records mono IMA4 at 44.1kHz into the temporary folder.
- (id)audioRecorder
{
    if (_audioRecorder == nil) {
        NSString *path = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[[self recordName] hyperStringByReplacingSlashesWithColons]];
        if (HSAutoRecordAction_usesAudioUnitRecorder()) {
            _audioRecorder = [[AUInputDeviceFile alloc] initWithFilename:path outputFormatID:kAudioFormatAppleIMA4];
        } else {
            NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                [NSNumber numberWithFloat:44100.0f], AVSampleRateKey,
                [NSNumber numberWithInt:kAudioFormatAppleIMA4], AVFormatIDKey,
                [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                [NSNumber numberWithInt:AVAudioQualityHigh], AVEncoderAudioQualityKey, nil];
            _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"aiff"]] settings:settings error:NULL];
            [settings release];
        }
        [_audioRecorder setDelegate:self];
    }
    return _audioRecorder;
}
// Recording into an unsaved document asks first, since there is no folder to save the sound next to.
- (void)startInContext:(id)aContext
{
    if ([aContext shouldIgnoreRecording]) {
        [self notifyDidFinish];
        return;
    }
    if ([aContext documentURL] != nil) {
        [self continueInContext:aContext];
        return;
    }
    HSAlert *alert = [HSAlert new];
    [alert setAlertStyle:5];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSAutoRecordUnsavedDocumentMessageText" value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSAutoRecordUnsavedDocumentInformativeText" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Continue" value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cancel" value:@"" table:@"Alerts"]];
    [aContext retain];
    [(HSActionExecutionContext *)aContext displayAlert:alert modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:aContext];
}
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aEnd release];
    [(id)aInfo autorelease];
    if (aCode == NSAlertFirstButtonReturn)
        [self continueInContext:(id)aInfo];
    else
        [self notifyDidFinish];
}
- (void)continueInContext:(id)aContext
{
    if ([self isRecording])
        return;
    _context = [aContext retain];
    [aContext setIsRecording:YES];
    [aContext setCurrentAutoRecordAction:self];
    [self startAudioRecorder];
    if ([self recordTime] > 0.0)
        [self performSelector:@selector(stopRecordingAction) withObject:nil afterDelay:[self recordTime]];
}
- (void)stop:(id)aStop
{
    [self stopRecordingAction];
}
- (BOOL)canBeStopped
{
    if (![_context isSlideshow])
        return YES;
    return ![self isRecording];
}
- (void)notifyDidFinish
{
    [self stopAudioRecorder];
    [_context setIsRecording:NO];
    if ([_context currentAutoRecordAction] == self)
        [_context setCurrentAutoRecordAction:nil];
    [_context release];
    _context = nil;
    [super notifyDidFinish];
}
- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:@"recordTime", @"sensitivityLevel", @"recordName", nil]];
}
- (void)dealloc
{
    [self stopAudioRecorder];
    [_audioRecorder release];
    [_context release];
    [_recordName release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    if (self != nil) {
        _recordTime = 10.0;
        _sensitivityLevel = 1;
        _recordName = [[NSString alloc] initWithString:[[NSBundle mainBundle] localizedStringForKey:@"sound" value:@"" table:nil]];
    }
    return self;
}
@end
