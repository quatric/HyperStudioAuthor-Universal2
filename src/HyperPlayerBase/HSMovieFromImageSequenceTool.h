#import "HyperPlayerBasePrefix.h"
#import "HSMovie.h"


@interface HSMovieFromImageSequenceTool : NSObject
{
    NSArray *_imageSequence;
    NSArray *_timeSequence;
    long long _frameLength;
    QTMovie *_movie;
    struct ComponentInstanceRecord *_dataHandlerRef;
    NSData *_data;
    id _delegate;
}
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)createMovieFromSequence;
- (long long)timeValueForFrame:(NSUInteger)aFrame;
- (struct MovieType **)newTempMovieAndHandle:(struct ComponentInstanceRecord **)aHandle error:(short *)aError;
- (id)movieData;
- (void)setData:(id)aData;
- (id)data;
- (void)setFrameLength:(long long)aLength;
- (long long)frameLength;
- (void)setTimeSequence:(id)aSequence;
- (id)timeSequence;
- (void)setImageSequence:(id)aSequence;
- (id)imageSequence;
- (void)setMovie:(id)aMovie;
- (id)movie;
- (void)dealloc;
- (id)init;
@end

@interface HSMovie (HSMovieFromImageSequence)
+ (id)movieWithImageSequence:(id)aSequence timeSequence:(id)aSequence2 error:(id *)aError;
+ (id)movieWithImageSequence:(id)aSequence frameLength:(long long)aLength error:(id *)aError;
+ (id)movieWithImageSequence:(id)aSequence timeSequence:(id)aSequence2 frameLength:(long long)aLength error:(id *)aError;
@end

