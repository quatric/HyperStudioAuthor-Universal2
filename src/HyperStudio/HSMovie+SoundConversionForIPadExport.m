#import "HSMovie+SoundConversionForIPadExport.h"

static NSString *HSCreateHTML5TmpSoundPath(NSString *aExtension)
{
    return [NSString extraCreateUniqueFilename:[NSTemporaryDirectory() stringByAppendingPathComponent:@"_HTML5TmpSound"] extension:aExtension];
}

// Writes an AAC (M4A) file next to the temporary items; returns its path even
// when the export failed, as the original did.
static NSString *HSConvertAssetToAAC(AVAsset *aAsset)
{
    NSString *path = HSCreateHTML5TmpSoundPath(@"aac");
    BOOL isDirectory = NO;

    if (path == nil)
        return nil;
    if (aAsset != nil) {
        AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:aAsset presetName:AVAssetExportPresetAppleM4A];
        dispatch_semaphore_t done = dispatch_semaphore_create(0);

        [session setOutputURL:[NSURL fileURLWithPath:path]];
        [session setOutputFileType:AVFileTypeAppleM4A];
        [session exportAsynchronouslyWithCompletionHandler:^{
            dispatch_semaphore_signal(done);
        }];
        dispatch_semaphore_wait(done, DISPATCH_TIME_FOREVER);
        dispatch_release(done);
        [session release];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory)
        [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:'M4A '] forKey:NSFileHFSTypeCode] ofItemAtPath:path error:NULL];
    return path;
}

// Renders a standard MIDI file through the Apple DLS synth into a temporary
// AIFF, then converts that to AAC.
static NSString *HSConvertMIDIFileToAAC(NSURL *aURL)
{
    AudioComponentDescription description = { kAudioUnitType_MusicDevice, kAudioUnitSubType_DLSSynth, kAudioUnitManufacturer_Apple, 0, 0 };
    AVAudioEngine *engine;
    AVAudioUnitMIDIInstrument *synth;
    AVAudioSequencer *sequencer;
    AVAudioFormat *format;
    AVAudioFile *file = nil;
    AVAudioPCMBuffer *buffer;
    NSString *aiffPath, *path = nil;
    NSTimeInterval length = 0.0;
    AVAudioFramePosition frames;

    if (aURL == nil || (aiffPath = HSCreateHTML5TmpSoundPath(@"aiff")) == nil)
        return nil;
    engine = [[AVAudioEngine alloc] init];
    synth = [[AVAudioUnitMIDIInstrument alloc] initWithAudioComponentDescription:description];
    format = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:2];
    [engine attachNode:synth];
    [engine connect:synth to:[engine mainMixerNode] format:nil];
    sequencer = [[AVAudioSequencer alloc] initWithAudioEngine:engine];
    if ([engine enableManualRenderingMode:AVAudioEngineManualRenderingModeOffline format:format maximumFrameCount:4096 error:NULL]
        && [sequencer loadFromURL:aURL options:AVMusicSequenceLoadSMF_PreserveTracks error:NULL]) {
        for (AVMusicTrack *track in [sequencer tracks]) {
            [track setDestinationAudioUnit:synth];
            length = MAX(length, [track lengthInSeconds]);
        }
        file = [[AVAudioFile alloc] initForWriting:[NSURL fileURLWithPath:aiffPath] settings:[format settings] commonFormat:AVAudioPCMFormatFloat32 interleaved:NO error:NULL];
    }
    if (file != nil && [engine startAndReturnError:NULL]) {
        [sequencer prepareToPlay];
        if ([sequencer startAndReturnError:NULL]) {
            // One extra second lets the last notes ring out.
            frames = (AVAudioFramePosition)((length + 1.0) * [format sampleRate]);
            buffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[engine manualRenderingFormat] frameCapacity:[engine manualRenderingMaximumFrameCount]];
            while ([engine manualRenderingSampleTime] < frames) {
                AVAudioFrameCount count = (AVAudioFrameCount)MIN((AVAudioFramePosition)[buffer frameCapacity], frames - [engine manualRenderingSampleTime]);
                if ([engine renderOffline:count toBuffer:buffer error:NULL] != AVAudioEngineManualRenderingStatusSuccess
                    || ![file writeFromBuffer:buffer error:NULL])
                    break;
            }
            [buffer release];
            [sequencer stop];
        }
        [engine stop];
        [file release];
        file = nil;
        path = HSConvertAssetToAAC([AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:aiffPath] options:nil]);
    }
    [file release];
    [sequencer release];
    [format release];
    [synth release];
    [engine release];
    return path;
}

@implementation HSMovie (SoundConversionForIPadExport)

// Builds a movie of the first sound track only and converts that.
- (id)convertedSoundtrackPath
{
    NSArray *tracks = [[_movie AVAsset] tracksWithMediaType:AVMediaTypeAudio];
    AVMutableComposition *composition;
    AVMutableCompositionTrack *compositionTrack;
    AVAssetTrack *track;

    if ([tracks count] == 0)
        return nil;
    track = [tracks objectAtIndex:0];
    composition = [AVMutableComposition composition];
    compositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    if (![compositionTrack insertTimeRange:[track timeRange] ofTrack:track atTime:kCMTimeZero error:NULL])
        return nil;
    return HSConvertAssetToAAC(composition);
}

- (id)convertedForIPadExportSoundPath
{
    return [self convertSound:(struct MovieType **)[_movie quickTimeMovie] isMIDI:[self isMIDI]];
}

// QuickTime's movie export components are gone: the sound goes through
// AVAssetExportSession (Apple M4A preset), MIDI is rendered by the DLS synth first.
- (id)convertSound:(struct MovieType **)aSound isMIDI:(BOOL)aMIDI
{
    QTMovie *movie = (QTMovie *)aSound;

    if (!aMIDI)
        return HSConvertAssetToAAC([movie AVAsset]);
    id location = [movie attributeForKey:QTMovieURLAttribute];
    if (location == nil && [movie attributeForKey:QTMovieFileNameAttribute] != nil)
        location = [NSURL fileURLWithPath:[movie attributeForKey:QTMovieFileNameAttribute]];
    return HSConvertMIDIFileToAAC(location);
}

- (BOOL)isIPadExportableFileType
{
    id location = [_movie attributeForKey:QTMovieURLAttribute];
    id extension;

    if (location == nil && (location = [_movie attributeForKey:QTMovieFileNameAttribute]) == nil)
        return NO;
    extension = [location pathExtension];
    if (extension == nil)
        return NO;
    return [[self iPadExportableFileTypes] containsObject:[extension lowercaseString]];
}

- (id)iPadExportableFileTypes
{
    return [NSArray arrayWithObjects:@"m4a", nil];
}

@end
