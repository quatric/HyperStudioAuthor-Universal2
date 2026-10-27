#import "HyperPlayerBasePrefix.h"


@interface AUInputDeviceFile : NSObject
{
    NSString *_filename;
    void *_privateAudioData;
    id _delegate;
}
+ (void)initialize;
- (void)setFilename:(id)aFilename;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (id)filename;
- (void)invalidate;
- (BOOL)writeToFile:(id)aFile atomically:(BOOL)aAtomically;
- (BOOL)createEmptyFile;
- (BOOL)hasData;
- (CGFloat)signalVolumeForChannel:(NSUInteger)aChannel;
- (NSUInteger)channelCount;
- (BOOL)isPaused;
- (void)resume;
- (void)pause;
- (BOOL)isRunning;
- (void)stop;
- (void)start;
- (void)dealloc;
- (id)init;
- (id)initWithFilename:(id)aFilename outputFormatID:(NSUInteger)aID;
- (id)initWithFilename:(id)aFilename;
@end

