#import "HyperPlayerBasePrefix.h"
#import "HSWeaklyReferencedObject.h"


@interface HSLiveVideoStreamAttributesImplementation : HSWeaklyReferencedObject <HSVideoStreamAttributes, HSAttributes, HyperInterface, NSObject, HSVideoRectAttribute, HSVisualAttribute, HSUndoableAttribute, HSAttribute, HSPlayingVideoStateAttribute, HSVideoFrameAttribute, HSLiveVideoAttributes, HSLiveVideoDeviceAttribute>
{
    HSLiveObject *_liveVideoObject;
    HSCaptureDeviceList *_captureDeviceList;
    QTCaptureDevice *_captureDevice;
    HSCaptureDeviceSession *_captureDeviceSession;
    id<NSObject, HSCaptureDeviceSessionClient> _captureDeviceSessionClient;
    unsigned int _captureDeviceActivationCounter;
    struct __CFDictionary *_frameProcessorClassToReferenceCountMap;
    struct __CFDictionary *_frameProcessorClassToCapturedFrameMap;
}
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext;
- (void)HSLiveVideoStreamAttributesImplementation_captureDeviceDidChangeState:(id)aState;
- (void)HSLiveVideoStreamAttributesImplementation_captureDeviceListDidUpdate:(id)aUpdate;
- (void)HSLiveVideoStreamAttributesImplementation_liveVideoObjectDidChangeHyperDeviceIndex:(id)aIndex;
- (void)HSLiveVideoStreamAttributesImplementation_liveVideoObjectDidChangePlayingVideoState:(id)aState;
- (id)attributeObservingController;
- (id)videoFrameForVideoFrameProcessorClass:(Class)aClass;
- (void)removeVideoFrameProcessorClass:(Class)aClass;
- (void)addVideoFrameProcessorClass:(Class)aClass;
- (BOOL)isPlayingVideo;
- (NSRect)videoRect;
- (id)liveVideoDevice;
- (id)hyperObject;
- (id)liveVideoObject;
- (void)release;
- (void)dealloc;
- (id)initWithLiveVideoObject:(id)aObject;
- (void)HSLiveVideoStreamAttributesImplementation_postReceiveFrames;
- (void)HSLiveVideoStreamAttributesImplementation_receiveFrames:(struct __CFDictionary *)aFrames;
- (void)HSLiveVideoStreamAttributesImplementation_setFrame:(id)aFrame forFrameProcessorClass:(Class)aClass;
- (BOOL)HSLiveVideoStreamAttributesImplementation_preReceiveFrames;
- (void)HSLiveVideoStreamAttributesImplementation_receiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass;
- (void)HSLiveVideoStreamAttributesImplementation_removeVideoFrameProcessorClass:(Class)aClass;
- (void)HSLiveVideoStreamAttributesImplementation_addVideoFrameProcessorClass:(Class)aClass;
- (void)HSLiveVideoStreamAttributesImplementation_adoptVideoDevicePostingNotifications:(BOOL)aNotifications;
- (void)HSLiveVideoStreamAttributesImplementation_deactivateCaptureDeviceWithContinuousChangeNotification:(BOOL)aNotification;
- (void)HSLiveVideoStreamAttributesImplementation_activateCaptureDeviceWithContinuousChangeNotification:(BOOL)aNotification;
- (void)HSLiveVideoStreamAttributesImplementation_activateCaptureDeviceWithFrameProcessorClass:(Class)aClass;
- (struct __CFDictionary *)HSLiveVideoStreamAttributesImplementation_frameProcessorClassToCapturedFrameMap;
- (void)HSLiveVideoStreamAttributesImplementation_releaseCaptureDeviceSession;
- (id)HSLiveVideoStreamAttributesImplementation_captureDeviceSession;
@end

@interface HSLiveVideoStreamAttributesImplementation_HSCaptureDeviceSessionClient : NSObject <HSCaptureDeviceSessionClient>
{
    HSLiveVideoStreamAttributesImplementation *_liveVideoStreamAttributesImplementation;
    struct __CFDictionary *_frameProcessorClassToPendingCapturedFrameMap;
    NSThread *_mainThread;
    NSLock *_pendingCapturedFramesLock;
}
- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass;
- (void)receivePendingFrames;
- (void)invalidate;
- (void)dealloc;
- (id)initWithLiveVideoStreamAttributesImplementation:(id)aImplementation;
@end

