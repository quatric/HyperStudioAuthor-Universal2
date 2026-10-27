#import "HyperPlayerBasePrefix.h"


@interface HSCaptureDeviceSession : NSObject
{
    NSSet *_captureDeviceSet;
    struct __CFSet *_openCaptureDevices;
    NSMutableArray *_captureDeviceInputs;
    QTCaptureSession *_captureSession;
    unsigned int _clientlessActivationCounter;
    struct __CFDictionary *_clientToFrameProcessorClassesMap;
    pthread_mutex_t *_clientsMutex;
    pthread_cond_t *_clientsCondition;
    unsigned int _clientsReadAccessCount;
    struct __CFDictionary *_frameProcessorClassToClientsMap;
    pthread_mutex_t *_clientsNotificationMutex;
    pthread_cond_t *_clientsNotificationCondition;
    struct __CFDictionary *_clientBeingNotifiedToFrameProcessorClassesMap;
    struct __CFDictionary *_frameProcessorClassToReferenceCountMap;
    struct __CFDictionary *_frameProcessorClassToFrameProcessorMap;
    struct __CFDictionary *_frameProcessorToCaptureOutputMap;
    pthread_mutex_t *_capturedFramesMutex;
    struct __CFDictionary *_frameProcessorClassToCapturedFrameMap;
    struct __CFDictionary *_frameProcessorClassToCapturedFrameDecayTimerMap;
    double _capturedFrameDecayInterval;
    struct __CFDictionary *_clientIdentifierToCapturedFrameDecayIntervalMap;
    unsigned int _isClientsWriteAccessPending:1;
}
+ (id)captureDeviceSessionForDeviceSet:(id)aSet;
+ (id)captureDeviceSessionForDevice:(id)aDevice;
+ (id)existingCaptureDeviceSessions;
- (void)removeFrameDecayIntervalForClientIdentifier:(id)aIdentifier;
- (void)setFrameDecayInterval:(double)aInterval forClientIdentifier:(id)aIdentifier;
- (double)frameDecayIntervalForClientIdentifier:(id)aIdentifier;
- (void)HSCaptureDeviceSession_setCapturedFrameDecayInterval:(double)aInterval;
- (double)frameDecayInterval;
- (id)frameForFrameProcessorClass:(Class)aClass;
- (void)frameProcessor:(id)aProcessor didOutputFrame:(id)aFrame;
- (void)deactivate;
- (void)deactivateForClient:(id)aClient;
- (void)deactivateForClient:(id)aClient withFrameProcessorClass:(Class)aClass;
- (BOOL)HSCaptureDeviceSession_hasClients;
- (void)activateForClient:(id)aClient withFrameProcessorClass:(Class)aClass;
- (void)activate;
- (void)HSCaptureDeviceSession_captureDeviceDidChangeState:(id)aState;
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext;
- (void)HSCaptureDeviceSession_activate;
- (id)captureSession;
- (id)HSCaptureDeviceSession_captureSessionForActivation:(BOOL)aActivation;
- (void)HSCaptureDeviceSession_captureSessionRuntimeErrorNotification:(id)aNotification;
- (id)captureDeviceSet;
- (void)dealloc;
- (id)init;
- (void)HSCaptureDeviceSession_stopRunning;
- (void)HSCaptureDeviceSession_preremoveFrameProcessor:(id)aProcessor;
- (void)HSCaptureDeviceSession_addFrameProcessors;
- (struct __CFDictionary *)HSCaptureDeviceSession_frameProcessorToCaptureOutputMap;
- (struct __CFDictionary *)HSCaptureDeviceSession_frameProcessorClassToFrameProcessorMap;
- (void)HSCaptureDeviceSession_addFrameProcessorOfClass:(Class)aClass;
- (void)HSCaptureDeviceSession_releaseFrameProcessorClass:(Class)aClass forClient:(id)aClient;
- (void)HSCaptureDeviceSession_capturedFrameDecayTimer:(id)aTimer releaseCapturedFrameForFrameProcessorClass:(id)aClass;
- (void)HSCaptureDeviceSession_retainCapturedFrameForFrameProcessorClass:(id)aClass;
- (BOOL)HSCaptureDeviceSession_isClientActive:(id)aActive;
- (BOOL)HSCaptureDeviceSession_isClientActive:(id)aActive forFrameProcessorClass:(Class)aClass;
- (BOOL)HSCaptureDeviceSession_isClientBeingNotifiedOnAnotherThread:(id)aThread forFrameProcessorClass:(Class)aClass;
- (BOOL)HSCaptureDeviceSession_addInputForCaptureDevice:(id)aDevice remainOpen:(BOOL)aOpen;
- (BOOL)HSCaptureDeviceSession_addClient:(id)aClient withFrameProcessorClass:(Class)aClass;
- (BOOL)HSCaptureDeviceSession_addClient:(id)aClient forFrameProcessorClass:(Class)aClass;
- (id)HSCaptureDeviceSession_initWithCaptureDeviceSet:(id)aSet;
@end

