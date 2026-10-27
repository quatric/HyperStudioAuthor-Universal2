#import "HyperPlayerBasePrefix.h"
#import "HSShadowedObject.h"


@interface HSLiveObject : HSShadowedObject <HSDefaultSizeSubattributes, HSAttributes, HyperInterface, NSObject, HSLiveObjectAttributes, HSPlayableObjectAttributes, HSPlayableObjectUIDAttribute, HSAttribute, HSPlayableObjectNameAttribute, HSPlayableObjectDurationAttribute, HSPlayableObjectStartTimeAttribute, HSPlayableObjectPlayRangeAttribute, HSPlayableObjectHyperPlayingAttribute, HSLiveObjectDeviceIndexAttribute, HSMutableOpacityAttributes, HSOpacityAttributes, HSOpacityAttribute, HSVisualAttribute, HSUndoableAttribute, HSEffectPerObjectAttributes, HSGeometryBehaviorSubattributes, HSVideoStreamAttributes, HSVideoRectAttribute, HSPlayingVideoStateAttribute, HSVideoFrameAttribute, HSLiveVideoAttributes, HSLiveVideoDeviceAttribute>
{
    id _starter;
}
+ (Class)nodeDataClass;
+ (id)defaultUnitClassNames;
- (id)HTML5UnsupportedFunctionalityDescription;
- (id)XMLElementName;
- (BOOL)canBeStoredAsXMLElement;
- (void)hyperStepForward;
- (void)hyperStepBack;
- (void)setHyperCurrentTime:(double)aTime;
- (double)hyperCurrentTime;
- (void)hyperStop;
- (void)hyperStart:(id)aStart;
- (id)hyperStarter;
- (BOOL)isHyperPlaying;
- (id)playSelfActionType;
- (void)setHyperPlayRange:(struct HSTimeRange)aRange;
- (struct HSTimeRange)hyperPlayRange;
- (void)setHyperStartTime:(double)aTime;
- (double)hyperStartTime;
- (double)hyperDuration;
- (id)hyperPlayableObjectName;
- (id)hyperPlayableObjectUID;
- (void)setHyperDeviceIndex:(NSUInteger)aIndex;
- (NSUInteger)hyperDeviceIndex;
- (void)setDeviceIndex:(NSUInteger)aIndex;
- (NSUInteger)deviceIndex;
- (id)liveVideoDevice;
- (id)videoFrameForVideoFrameProcessorClass:(Class)aClass;
- (void)removeVideoFrameProcessorClass:(Class)aClass;
- (void)addVideoFrameProcessorClass:(Class)aClass;
- (BOOL)isPlayingVideo;
- (NSRect)videoRect;
- (NSSize)defaultSize;
- (BOOL)canMoveVertically;
- (BOOL)canMoveHorizontally;
- (BOOL)canRotate;
- (BOOL)canSkew;
- (BOOL)canFlipVertically;
- (BOOL)canFlipHorizontally;
- (BOOL)canScaleVertically;
- (BOOL)canScaleHorizontally;
- (BOOL)canBreakSizeScaleAspectRatio;
- (BOOL)prefersResizingToScaling;
- (void)setHyperOpacity:(CGFloat)aOpacity;
- (CGFloat)hyperOpacity;
- (void)setOpacity:(CGFloat)aOpacity;
- (CGFloat)opacity;
- (BOOL)canBeDraggable;
- (BOOL)canBeResizable;
- (BOOL)canBeRotatable;
- (id)queryCameraObjectHitTester;
- (id)queryInteractivePlayerItem;
- (void)willDisconnectFromDocument;
- (id)queryNewHyperInterface:(id)aInterface;
- (id)keysForExtraLoadingWithCodingContext:(id)aContext;
- (void)dealloc;
- (id)init;
@end

