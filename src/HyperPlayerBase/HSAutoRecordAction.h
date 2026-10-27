#import "HyperPlayerBasePrefix.h"
#import "HSScriptAction.h"


@interface HSAutoRecordAction : HSNBAAction <HSAutoRecordActionAttributes, HSActionAttributes, HSAttributes, HyperInterface, NSObject, HSAction, HSActionSynchronousAttribute, HSAttribute, HSActionEventsAttribute, HSActionLocalizedNameAttribute, HSRecordTimeAttribute, HSSensitivityLevelAttribute, HSRecordNameAttribute>
{
    double _recordTime;
    int _sensitivityLevel;
    NSString *_recordName;
    HSActionExecutionContext *_context;
    id _audioRecorder;
}
- (void)audioRecorderEncodeErrorDidOccur:(id)aOccur error:(id)aError;
- (void)audioRecorderDidFinishRecording:(id)aRecording successfully:(BOOL)aSuccessfully;
- (void)informAboutDiskSpaceError;
- (BOOL)handleDeviceFile:(id)aFile recordingError:(NSInteger)aError;
- (void)setRecordName:(id)aName;
- (id)recordName;
- (void)setSensitivityLevel:(NSInteger)aLevel;
- (NSInteger)sensitivityLevel;
- (void)setRecordTime:(double)aTime;
- (double)recordTime;
- (void)stopRecordingAction;
- (void)saveAudioFileWithContextInfo:(id)aInfo;
- (BOOL)isRecording;
- (void)stopAudioRecorder;
- (void)startAudioRecorder;
- (id)audioRecorder;
- (void)startInContext:(id)aContext;
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo;
- (void)continueInContext:(id)aContext;
- (void)stop:(id)aStop;
- (BOOL)canBeStopped;
- (void)notifyDidFinish;
- (id)keysForExtraStoringWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

