#import "AUDevice.h"
#import <libproc.h>

// The default output and input devices. A device monitor (one per direction,
// made on first use) follows the default device and its hog mode with
// AudioObject property listeners and posts AUAudioDidDie/Revive/Change and
// AUHogModeDidTake/ReleaseByOtherProcess notifications in a center of its
// own (CANotificationCenter in the original, a C++ notification center);
// AUDevice turns them into AUDeviceAliveDidChange,
// AUDeviceDidChangeNotification and AUDeviceHogModeDidChangeNotification.

static NSNotificationCenter *AUDeviceMonitorNotificationCenter(void)
{
    static NSNotificationCenter *center;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ center = [[NSNotificationCenter alloc] init]; });
    return center;
}

@interface AUIODeviceMonitor : NSObject
{
    BOOL _isInput;
    AudioObjectID _deviceID;
    BOOL _isHog;
    AudioObjectPropertyListenerBlock _defaultDeviceListener;
    AudioObjectPropertyListenerBlock _hogModeListener;
}
+ (AUIODeviceMonitor *)sharedMonitorForInput:(BOOL)aInput;
- (BOOL)isAlive;
- (BOOL)isInHogMode;
- (NSString *)copyHogProcessName;
@end

@implementation AUIODeviceMonitor

+ (AUIODeviceMonitor *)sharedMonitorForInput:(BOOL)aInput
{
    static AUIODeviceMonitor *monitors[2];
    if (monitors[aInput] == nil)
        monitors[aInput] = [[AUIODeviceMonitor alloc] initForInput:aInput];
    return monitors[aInput];
}

static AudioObjectPropertyAddress AUIODeviceMonitorDefaultDeviceAddress(BOOL aInput)
{
    AudioObjectPropertyAddress address = { aInput ? kAudioHardwarePropertyDefaultInputDevice : kAudioHardwarePropertyDefaultOutputDevice,
                                           kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };
    return address;
}

static const AudioObjectPropertyAddress kAUIODeviceMonitorHogModeAddress = { kAudioDevicePropertyHogMode, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };

- (AudioObjectID)updatedDeviceID
{
    AudioObjectPropertyAddress address = AUIODeviceMonitorDefaultDeviceAddress(_isInput);
    AudioObjectID device = kAudioObjectUnknown;
    UInt32 size = sizeof(device);
    if (AudioObjectGetPropertyData(kAudioObjectSystemObject, &address, 0, NULL, &size, &device) != noErr)
        return kAudioObjectUnknown;
    return device;
}

- (pid_t)hogModeOwner
{
    pid_t owner = -1;
    UInt32 size = sizeof(owner);
    if (_deviceID == kAudioObjectUnknown || AudioObjectGetPropertyData(_deviceID, &kAUIODeviceMonitorHogModeAddress, 0, NULL, &size, &owner) != noErr)
        return -1;
    return owner;
}

- (BOOL)updatedIsHog
{
    pid_t owner = [self hogModeOwner];
    return owner != -1 && owner != getpid();
}

- (NSString *)notificationObject
{
    return _isInput ? AUAudioInputDeviceObject : AUAudioOutputDeviceObject;
}

- (void)postNotificationName:(NSString *)aName userInfo:(NSDictionary *)aUserInfo
{
    [AUDeviceMonitorNotificationCenter() postNotificationName:aName object:[self notificationObject] userInfo:aUserInfo];
}

- (void)installHogModeListener
{
    if (_deviceID != kAudioObjectUnknown)
        AudioObjectAddPropertyListenerBlock(_deviceID, &kAUIODeviceMonitorHogModeAddress, dispatch_get_main_queue(), _hogModeListener);
}

- (void)removeHogModeListener
{
    if (_deviceID != kAudioObjectUnknown)
        AudioObjectRemovePropertyListenerBlock(_deviceID, &kAUIODeviceMonitorHogModeAddress, dispatch_get_main_queue(), _hogModeListener);
}

// A device after none revives the audio, none after a device kills it, and
// one device after another changes it.
- (void)defaultDeviceDidChange
{
    AudioObjectID previous = _deviceID;
    [self removeHogModeListener];
    _deviceID = [self updatedDeviceID];
    _isHog = [self updatedIsHog];
    [self installHogModeListener];
    NSString *name;
    if ((previous != kAudioObjectUnknown) == (_deviceID != kAudioObjectUnknown))
        name = AUAudioDidChangeNotification;
    else if (_deviceID != kAudioObjectUnknown)
        name = AUAudioDidReviveNotification;
    else
        name = AUAudioDidDieNotification;
    [self postNotificationName:name userInfo:nil];
}

- (void)hogModeDidChange
{
    BOOL wasHog = _isHog;
    _isHog = [self updatedIsHog];
    if (wasHog == _isHog)
        return;
    NSString *processName = [self copyHogProcessName];
    NSDictionary *userInfo = processName != nil ? [NSDictionary dictionaryWithObject:processName forKey:AUHogModeProcessNameKey] : nil;
    [processName release];
    [self postNotificationName:_isHog ? AUHogModeDidTakeByOtherProcessNotification : AUHogModeDidReleaseByOtherProcessNotification userInfo:userInfo];
}

- (id)initForInput:(BOOL)aInput
{
    if ((self = [super init])) {
        _isInput = aInput;
        _deviceID = [self updatedDeviceID];
        _isHog = [self updatedIsHog];
        _defaultDeviceListener = Block_copy(^(UInt32 aCount, const AudioObjectPropertyAddress *aAddresses) { [self defaultDeviceDidChange]; });
        _hogModeListener = Block_copy(^(UInt32 aCount, const AudioObjectPropertyAddress *aAddresses) { [self hogModeDidChange]; });
        AudioObjectPropertyAddress address = AUIODeviceMonitorDefaultDeviceAddress(_isInput);
        AudioObjectAddPropertyListenerBlock(kAudioObjectSystemObject, &address, dispatch_get_main_queue(), _defaultDeviceListener);
        [self installHogModeListener];
    }
    return self;
}

- (void)dealloc
{
    AudioObjectPropertyAddress address = AUIODeviceMonitorDefaultDeviceAddress(_isInput);
    AudioObjectRemovePropertyListenerBlock(kAudioObjectSystemObject, &address, dispatch_get_main_queue(), _defaultDeviceListener);
    [self removeHogModeListener];
    Block_release(_defaultDeviceListener);
    Block_release(_hogModeListener);
    [super dealloc];
}

- (BOOL)isAlive
{
    if (_deviceID == kAudioObjectUnknown)
        return NO;
    AudioObjectPropertyAddress address = { kAudioDevicePropertyDeviceIsAlive, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMain };
    UInt32 alive = 0, size = sizeof(alive);
    return AudioObjectGetPropertyData(_deviceID, &address, 0, NULL, &size, &alive) == noErr && alive != 0;
}

- (BOOL)isInHogMode
{
    return _isHog;
}

// The name of the process holding the device, +1; nil when none does.
- (NSString *)copyHogProcessName
{
    pid_t owner = [self hogModeOwner];
    if (owner == -1 || owner == getpid())
        return nil;
    char name[2 * MAXCOMLEN + 1] = { 0 };
    if (proc_name(owner, name, sizeof(name)) <= 0)
        return nil;
    return [[NSString alloc] initWithUTF8String:name];
}

@end

@implementation AUDevice

+ (id)defaultOutputDevice
{
    static id device;
    if (device == nil)
        device = [[AUOutputDevice alloc] initWithDeviceIdentifier:AUAudioOutputDeviceObject];
    return device;
}

+ (id)defaultInputDevice
{
    static id device;
    if (device == nil)
        device = [[AUInputDevice alloc] initWithDeviceIdentifier:AUAudioInputDeviceObject];
    return device;
}

- (id)deviceIdentifier
{
    return _deviceIdentifier;
}

- (void)dealloc
{
    // Fix: the original left the device observing.
    [AUDeviceMonitorNotificationCenter() removeObserver:self];
    [_deviceIdentifier release];
    [super dealloc];
}

- (id)initWithDeviceIdentifier:(id)aIdentifier
{
    if ((self = [super init]))
        _deviceIdentifier = [aIdentifier retain];
    return self;
}

@end

@implementation AUOutputDevice

- (void *)deviceMonitor
{
    return [AUIODeviceMonitor sharedMonitorForInput:NO];
}

@end

@implementation AUInputDevice

- (void *)deviceMonitor
{
    return [AUIODeviceMonitor sharedMonitorForInput:YES];
}

@end

@implementation AUDevice (AUDeviceAttributes)

- (id)hogProcessName
{
    return [[(AUIODeviceMonitor *)[self deviceMonitor] copyHogProcessName] autorelease];
}

- (BOOL)isInHogMode
{
    return [(AUIODeviceMonitor *)[self deviceMonitor] isInHogMode];
}

- (BOOL)isAlive
{
    return [(AUIODeviceMonitor *)[self deviceMonitor] isAlive];
}

- (BOOL)isAccessible
{
    return [self isAlive] && ![self isInHogMode];
}

- (void)disableNotifications
{
    [AUDeviceMonitorNotificationCenter() removeObserver:self name:nil object:[self deviceIdentifier]];
}

- (void)AUDevice_aliveDidChange:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AUDeviceAliveDidChange object:self userInfo:[aNotification userInfo]];
}

- (void)AUDevice_deviceDidChange:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AUDeviceDidChangeNotification object:self userInfo:[aNotification userInfo]];
}

- (void)AUDevice_hogModeDidChange:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AUDeviceHogModeDidChangeNotification object:self userInfo:[aNotification userInfo]];
}

// The monitor is made first, so it's there to post.
- (void)enableNotifications
{
    [self deviceMonitor];
    NSNotificationCenter *center = AUDeviceMonitorNotificationCenter();
    id identifier = [self deviceIdentifier];
    [center addObserver:self selector:@selector(AUDevice_aliveDidChange:) name:AUAudioDidDieNotification object:identifier];
    [center addObserver:self selector:@selector(AUDevice_aliveDidChange:) name:AUAudioDidReviveNotification object:identifier];
    [center addObserver:self selector:@selector(AUDevice_deviceDidChange:) name:AUAudioDidChangeNotification object:identifier];
    [center addObserver:self selector:@selector(AUDevice_hogModeDidChange:) name:AUHogModeDidTakeByOtherProcessNotification object:identifier];
    [center addObserver:self selector:@selector(AUDevice_hogModeDidChange:) name:AUHogModeDidReleaseByOtherProcessNotification object:identifier];
}

@end
