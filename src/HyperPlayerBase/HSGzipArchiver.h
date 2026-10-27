#import "HyperPlayerBasePrefix.h"


@interface HSGzipArchiver : NSObject
{
    NSData *_inputData;
    int _currentPosition;
    NSMutableData *_outputData;
    int _error;
    NSString *_errorString;
}
- (NSInteger)unpack;
- (void)setErrorString:(id)aString;
- (id)errorString;
- (void)setError:(NSInteger)aError;
- (NSInteger)error;
- (void)setOutputData:(id)aData;
- (id)outputData;
- (void)setCurrentPosition:(NSInteger)aPosition;
- (NSInteger)currentPosition;
- (void)setInputData:(id)aData;
- (id)inputData;
- (void)dealloc;
- (id)init;
@end

@interface NSData (HSGzipExtensions)
- (id)hyperDataWithGzipPack;
- (id)hyperDataWithGzipUnpack;
@end

