#import "HyperPlayerBasePrefix.h"


@interface HSAudioDeviceSwapper : NSObject
{
    unsigned int _actualDevice;
    unsigned int _actualInputDevice;
    unsigned int _hyperCastingDevice;
    unsigned int _hyperCastingDeviceBufferFrameSize;
    unsigned int _actualDeviceBufferFrameSize;
    AudioStreamBasicDescription _actualDeviceStreamFormat;
    float _actualDeviceFirstChannelVolume;
    float _actualDeviceSecondChannelVolume;
    void *_loopingStorage;
    BOOL _providerCallbackIsRunning;
    BOOL _clientCallbackIsRunning;
    int _actualLatency;
    double _lastInputSampleTime;
    double _inputToOutputSampleDelta;
    int _status;
    int _errorCode;
    unsigned int _propSize;
    int _dataExchangeSetupStage;
    AudioDeviceIOProcID _clientIOProcID;
    AudioDeviceIOProcID _providerIOProcID;
}
+ (void)selectAnotherDeviceIfHSDeviceIsDefault;
+ (void)selectAnotherDeviceIfHSDeviceIsDefaultByType:(BOOL)aType;
+ (NSUInteger)findPreviousDefaultDeviceFromHSPreferencesByUIDKey:(id)aKey;
+ (NSUInteger)createDeviceList:(unsigned int **)aList;
+ (NSUInteger)findHyperCastingDeviceByName:(unsigned int *)aName listLength:(NSUInteger)aLength;
- (NSInteger)processPropertyChange:(NSUInteger)aChange;
- (NSInteger)processClientCallWithOutputTime:(struct AudioTimeStamp *)aTime outputData:(struct AudioBufferList *)aData;
- (NSInteger)processProviderCallWithTimeStampInput:(struct AudioTimeStamp *)aInput buffersList:(struct AudioBufferList *)aList;
- (id)errorDescription;
- (NSInteger)status;
- (BOOL)recoverFromError;
- (void)stop;
- (NSUInteger)run;
- (void)finishListenToHSDevicePropertiesChanges;
- (void)startListenToHSDevicePropertiesChanges;
- (BOOL)translateVolumeFromHSDeviceToDefaultDevice;
- (void)storeAudioDevicesUIDsInUserDefaults;
- (void)translatePropertiesFromDefaultDeviceToHSDevice;
- (BOOL)translateVolumeFromDefaultDeviceToHSDevice;
- (BOOL)setMaximumGainToHSDeviceInput;
- (BOOL)translateMuteFrom:(NSUInteger)aFrom to:(NSUInteger)aTo;
- (BOOL)translateStreamFormatFromActualDeviceToHSDevice;
- (BOOL)endDataExchange;
- (BOOL)beginDataExchange;
- (BOOL)getSyncData;
- (void)releaseLoopingStorage;
- (BOOL)createLoopingStorage;
- (BOOL)setActualDeviceBackAsDefault;
- (NSUInteger)findHyperCastingDevice;
- (void)dealloc;
@end

