#import "HyperPlayerBasePrefix.h"


@interface HSFirstVideoFrameCapturer : NSObject
{
    id<HSPlayableObjectAttributes> _playableObjectAttributes;
    unsigned int _frameCount;
    BOOL _playedAlready;
}
+ (void)captureFirstFrameForObject:(id)aObject;
- (void)HSFirstVideoFrameCapturer_objectDidStop:(id)aStop;
- (void)HSFirstVideoFrameCapturer_objectDidChangeVideoFrame:(id)aFrame;
- (void)dealloc;
- (id)HSFirstVideoFrameCapturer_initWithPlayableObjectAttributes:(id)aAttributes;
- (id)init;
@end

