#import "HyperPlayerBasePrefix.h"


@interface HSAudioRecorder : NSObject
{
    unsigned int _audioDeviceID;
    struct OpaqueExtAudioFile *_audioFile;
    struct ComponentInstanceRecord *_audioUnit;
    struct AudioBufferList *_audioBufferList;
    NSURL *_outputFileURL;
    id _delegate;
    BOOL _isRecording;
}
- (void)stopRecording;
- (void)cancelRecording;
- (BOOL)startRecordingToFileAtURL:(id)aURL;
- (BOOL)configureOutputFileWithURL:(id)aURL;
- (BOOL)configureAU;
- (BOOL)allocateAuidoBufferListWithNumberOfChannels:(NSUInteger)aChannels andAudioBufferSize:(NSUInteger)aSize;
- (void)freeAudioBufferList;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (BOOL)isRecording;
- (NSUInteger)fileSize;
- (double)duration;
- (struct ComponentInstanceRecord *)audioUnit;
- (struct AudioBufferList *)audioBufferList;
- (struct OpaqueExtAudioFile *)audioFile;
- (NSUInteger)audioDeviceID;
- (void)dealloc;
- (id)initWithAudioDeviceID:(NSUInteger)aID;
- (id)initWithAudioDeviceUID:(id)aUID;
- (id)init;
@end

