#import "HSFirstVideoFrameCapturer.h"
@implementation HSFirstVideoFrameCapturer
// Plays a video object briefly (30 frames) so it shows its first frame. The
// capturer keeps itself alive until then (or until the object stops).
+ (void)captureFirstFrameForObject:(id)aObject
{
    if (![aObject implementsHyperInterface:@protocol(HSVideoStreamAttributes)])
        return;
    id attributes = [aObject queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
    if (attributes != nil)
        [[[self alloc] HSFirstVideoFrameCapturer_initWithPlayableObjectAttributes:attributes] autorelease];
}
- (void)HSFirstVideoFrameCapturer_objectDidStop:(id)aStop
{
    id controller = [_playableObjectAttributes attributeObservingController];
    [controller removeObserver:self selector:@selector(HSFirstVideoFrameCapturer_objectDidChangeVideoFrame:)
                     ofChanges:2 ofAttribute:@protocol(HSVideoFrameAttribute)];
    [controller removeObserver:self selector:@selector(HSFirstVideoFrameCapturer_objectDidStop:)
                     ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSPlayingVideoStateAttribute)];
    [self release];
}
- (void)HSFirstVideoFrameCapturer_objectDidChangeVideoFrame:(id)aFrame
{
    if (++_frameCount != 30)
        return;
    id controller = [_playableObjectAttributes attributeObservingController];
    [controller removeObserver:self selector:@selector(HSFirstVideoFrameCapturer_objectDidChangeVideoFrame:)
                     ofChanges:2 ofAttribute:@protocol(HSVideoFrameAttribute)];
    [controller removeObserver:self selector:@selector(HSFirstVideoFrameCapturer_objectDidStop:)
                     ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSPlayingVideoStateAttribute)];
    if (!_playedAlready)
        [_playableObjectAttributes hyperStop];
    [self release];
}
- (void)dealloc
{
    [_playableObjectAttributes release];
    [super dealloc];
}
// Starts the object (unless it's already playing) and returns the capturer
// retained once more for itself; nil when the object doesn't play.
- (id)HSFirstVideoFrameCapturer_initWithPlayableObjectAttributes:(id)aAttributes
{
    self = [super init];
    if (self == nil)
        return nil;
    _playableObjectAttributes = [aAttributes retain];
    if (_playableObjectAttributes == nil) {
        [self release];
        return nil;
    }
    id controller = [_playableObjectAttributes attributeObservingController];
    [controller addObserver:self selector:@selector(HSFirstVideoFrameCapturer_objectDidChangeVideoFrame:)
                  ofChanges:2 ofAttribute:@protocol(HSVideoFrameAttribute) withPriority:-0.25];
    _playedAlready = [_playableObjectAttributes isHyperPlaying];
    if (!_playedAlready) {
        [_playableObjectAttributes hyperStart:self];
        if (![_playableObjectAttributes isHyperPlaying]) {
            [controller removeObserver:self selector:@selector(HSFirstVideoFrameCapturer_objectDidChangeVideoFrame:)
                             ofChanges:2 ofAttribute:@protocol(HSVideoFrameAttribute)];
            [self release];
            return nil;
        }
    }
    [controller addObserver:self selector:@selector(HSFirstVideoFrameCapturer_objectDidStop:)
                  ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSPlayingVideoStateAttribute) withPriority:-0.25];
    return [self retain];
}
- (id)init
{
    [self release];
    return nil;
}
@end
