#import "HyperPlayerBasePrefix.h"


@interface HSGraphicCompositionPlayer : NSObject
{
    HSGraphicComposition *_graphicComposition;
    double _duration;
    double _maxFPS;
    id _delegate;
    double _startTime;
    double _playTime;
    NSTimer *_timer;
}
- (void)playNewFrame;
- (void)setPlayTime:(double)aTime;
- (double)playTime;
- (BOOL)isPlaying;
- (void)stop;
- (BOOL)start;
- (void)setDelegate:(id)aDelegate;
- (id)delegate;
- (void)setMaxFPS:(double)aFPS;
- (double)maxFPS;
- (void)setDuration:(double)aDuration;
- (double)duration;
- (void)setGraphicComposition:(id)aComposition;
- (id)graphicComposition;
- (void)dealloc;
- (void)HSGraphicComposition_play;
- (void)HSGraphicComposition_finish;
- (id)HSGraphicComposition_createAndScheduleTimerWithTimeInterval:(double)aInterval;
- (double)HSGraphicComposition_timeInterval;
@end

@interface NSObject (HSGraphicCompositionPlayerDelegate)
- (void)graphicCompositionPlayerDidFinish:(id)aFinish;
- (void)graphicCompositionPlayerDidPlayNewFrame:(id)aFrame;
@end

