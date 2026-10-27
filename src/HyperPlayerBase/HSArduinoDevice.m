#import "HSArduinoDevice.h"
#import "NSValue+HSDistantArduinoDevice.h"
#import "SMKApplicationKitData.h"
#import <IOKit/IOKitLib.h>
#import <mach/mach_time.h>

// Arduino boards are driven by the separate HSArduinoServer helper, reached
// over Distributed Objects. The helper is launched on demand and the
// connection retried every 30 seconds while devices are in use.

static NSDistantObject<HSArduinoServer> *sArduinoServer = nil;
static HSDistantArduinoDevice *sDefaultDevice = nil;
static CFMutableDictionaryRef sDevicesBySerialPortName = NULL;
static NSTask *sArduinoServerTask = nil;
static CFRunLoopTimerRef sReconnectTimer = NULL;

static void HSArduinoDevicePerformSelector(const void *aKey, const void *aValue, void *aContext)
{
    [(id)aValue performSelector:(SEL)aContext];
}

static void HSArduinoDeviceReconnectTimerFired(CFRunLoopTimerRef aTimer, void *aInfo)
{
    [(id)aInfo HSArduinoDevice_connectToArduinoServerIfNeeded];
}

// Pin arrays of one kind, as given to the pin state functions below. Digital
// pins 2-13 are stored from index 0.
typedef struct {
    signed char *modes;
    unsigned short *values;
    unsigned long long *times;
    NSMutableIndexSet *changedPins;
    unsigned char pinBeingChanged;
} HSArduinoPinStateUpdate;

typedef struct {
    signed char *modes;
    unsigned short *values;
    unsigned long long *times;
} HSArduinoPinStateCache;

static void HSArduinoLoadDigitalPinState(const void *aKey, const void *aValue, void *aContext)
{
    HSArduinoPinStateCache *cache = aContext;
    unsigned char pin = [(id)aKey unsignedCharValue];
    int mode;
    [(NSValue *)aValue HS_getArduinoPinStateChangeToMode:&mode value:&cache->values[pin - 2] atTime:&cache->times[pin - 2]];
    cache->modes[pin - 2] = (signed char)mode;
}

static void HSArduinoLoadAnalogPinState(const void *aKey, const void *aValue, void *aContext)
{
    HSArduinoPinStateCache *cache = aContext;
    unsigned char pin = [(id)aKey unsignedCharValue];
    int mode;
    [(NSValue *)aValue HS_getArduinoPinStateChangeToMode:&mode value:&cache->values[pin] atTime:&cache->times[pin]];
    cache->modes[pin] = (signed char)mode;
}

// Applies a change unless it is about the pin this device is changing itself
// or is older than the last known change; changed pins are collected.
static void HSArduinoApplyPinStateChange(HSArduinoPinStateUpdate *aUpdate, unsigned char aPin, NSUInteger aIndex, NSValue *aChange)
{
    if (aPin == aUpdate->pinBeingChanged)
        return;
    int mode;
    unsigned short value;
    unsigned long long time;
    [aChange HS_getArduinoPinStateChangeToMode:&mode value:&value atTime:&time];
    if (time < aUpdate->times[aIndex])
        return;
    if (aUpdate->modes[aIndex] != mode || aUpdate->values[aIndex] != value) {
        aUpdate->modes[aIndex] = (signed char)mode;
        aUpdate->values[aIndex] = value;
        if (aUpdate->changedPins == (id)-1)
            aUpdate->changedPins = [[NSMutableIndexSet alloc] init];
        [aUpdate->changedPins addIndex:aPin];
    }
    aUpdate->times[aIndex] = time;
}

static void HSArduinoApplyDigitalPinStateChange(const void *aKey, const void *aValue, void *aContext)
{
    unsigned char pin = [(id)aKey unsignedCharValue];
    HSArduinoApplyPinStateChange(aContext, pin, pin - 2, (NSValue *)aValue);
}

static void HSArduinoApplyAnalogPinStateChange(const void *aKey, const void *aValue, void *aContext)
{
    unsigned char pin = [(id)aKey unsignedCharValue];
    HSArduinoApplyPinStateChange(aContext, pin, pin, (NSValue *)aValue);
}

@implementation HSArduinoDevice

+ (id)deviceWithSerialPort:(NSUInteger)aPort
{
    if (sArduinoServer == nil && ![self HSArduinoDevice_connectToArduinoServer])
        return nil;
    return [HSDistantArduinoDevice deviceWithSerialPort:aPort];
}

+ (id)deviceWithSerialPortName:(id)aName
{
    if (sArduinoServer == nil && ![self HSArduinoDevice_connectToArduinoServer])
        return nil;
    return [HSDistantArduinoDevice deviceWithSerialPortName:aName];
}

+ (id)defaultDevice
{
    return nil;
}

+ (void)HSArduinoDevice_arduinoServerConnectionDidDie:(id)aDie
{
    [sDefaultDevice noteArduinoServerDidDisconnect];
    if (sDevicesBySerialPortName != NULL)
        CFDictionaryApplyFunction(sDevicesBySerialPortName, HSArduinoDevicePerformSelector, @selector(noteArduinoServerDidDisconnect));
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSConnectionDidDieNotification object:[sArduinoServer connectionForProxy]];
    [sArduinoServer release];
    sArduinoServer = nil;
    if (sArduinoServerTask != nil)
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(HSArduinoDevice_arduinoServerDidStart:)
                                                                name:HSArduinoServerDidStartNotification object:nil
                                                  suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    [self HSArduinoDevice_connectToArduinoServerIfNeeded];
}

+ (void)HSArduinoDevice_arduinoServerDidTerminate:(id)aTerminate
{
    if (sArduinoServer == nil)
        [self HSArduinoDevice_connectToArduinoServerIfNeeded];
}

+ (void)HSArduinoDevice_arduinoServerDidStart:(id)aStart
{
    if (sArduinoServer == nil)
        [self HSArduinoDevice_connectToArduinoServerIfNeeded];
}

+ (void)HSArduinoDevice_connectToArduinoServerIfNeeded
{
    if (sDefaultDevice == nil && (sDevicesBySerialPortName == NULL || CFDictionaryGetCount(sDevicesBySerialPortName) < 1))
        return;
    [self HSArduinoDevice_connectToArduinoServer];
}

+ (BOOL)HSArduinoDevice_connectToArduinoServer
{
    NSConnection *connection = [NSConnection connectionWithRegisteredName:HSArduinoServerConnectionName host:nil];
    if (connection != nil) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(HSArduinoDevice_arduinoServerConnectionDidDie:) name:NSConnectionDidDieNotification object:connection];
        if (![connection isValid]) {
            [center removeObserver:self name:NSConnectionDidDieNotification object:connection];
        } else {
            sArduinoServer = (NSDistantObject<HSArduinoServer> *)[[connection rootProxy] retain];
            if (sArduinoServer != nil) {
                [sArduinoServer setProtocolForProxy:@protocol(HSArduinoServer)];
                if (sReconnectTimer != NULL) {
                    CFRunLoopTimerInvalidate(sReconnectTimer);
                    CFRelease(sReconnectTimer);
                    sReconnectTimer = NULL;
                }
                [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:HSArduinoServerDidStartNotification object:nil];
                [sDefaultDevice noteArduinoServerDidConnect];
                if (sDevicesBySerialPortName != NULL)
                    CFDictionaryApplyFunction(sDevicesBySerialPortName, HSArduinoDevicePerformSelector, @selector(noteArduinoServerDidConnect));
                return YES;
            }
        }
    }
    if (sReconnectTimer != NULL)
        return YES;
    return [self HSArduinoDevice_launchArduinoServer];
}

// (Re)launches the helper from the framework's resources, then retries the
// connection every 30 seconds until it is up.
+ (BOOL)HSArduinoDevice_launchArduinoServer
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (sArduinoServerTask == nil) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(HSArduinoDevice_arduinoServerDidStart:)
                                                                name:HSArduinoServerDidStartNotification object:nil
                                                  suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
    } else {
        [center removeObserver:self name:NSTaskDidTerminateNotification object:sArduinoServerTask];
        [sArduinoServerTask terminate];
    }
    NSTask *task = [[NSTask alloc] init];
    if (task == nil)
        return NO;
    NSString *launchPath = [sArduinoServerTask launchPath];
    if (launchPath == nil) {
        launchPath = [[[NSBundle bundleForClass:[HSArduinoDevice class]] resourcePath] stringByAppendingPathComponent:@"HSArduinoServer"];
        if (launchPath == nil)
            return NO;
    }
    [center addObserver:self selector:@selector(HSArduinoDevice_arduinoServerDidTerminate:) name:NSTaskDidTerminateNotification object:task];
    [task setLaunchPath:launchPath];
    [task launch];
    [sArduinoServerTask release];
    sArduinoServerTask = task;
    if (sReconnectTimer == NULL) {
        CFRunLoopTimerContext context = { 0, self, NULL, NULL, CFCopyDescription };
        sReconnectTimer = CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + 30.0, 30.0, 0, 0,
                                               HSArduinoDeviceReconnectTimerFired, &context);
        if (sReconnectTimer == NULL)
            return NO;
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), sReconnectTimer, kCFRunLoopCommonModes);
    } else {
        CFRunLoopTimerSetNextFireDate(sReconnectTimer, CFAbsoluteTimeGetCurrent() + 30.0);
    }
    return YES;
}

- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin
{
}

- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forAnalogPin:(unsigned char)aPin
{
    return NO;
}

- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin
{
}

- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forDigitalPin:(unsigned char)aPin
{
    return NO;
}

- (NSInteger)connectionStatus
{
    return 0;
}

- (id)allAnalogPins
{
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 6)];
}

- (id)allDigitalPins
{
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 12)];
}

@end

// A device proxied by the server. Instances are shared per serial port (the
// cache holds them weakly); the last release lets go of the server device.
// Connection status 1 means disconnected, 6 connected.
@implementation HSDistantArduinoDevice

+ (id)deviceWithSerialPort:(NSUInteger)aPort
{
    NSString *name = (NSString *)IORegistryEntryCreateCFProperty((io_registry_entry_t)aPort, CFSTR("IOCalloutDevice"), kCFAllocatorDefault, 0);
    id device = name != nil ? [self deviceWithSerialPortName:name] : nil;
    [name release];
    return device;
}

+ (id)deviceWithSerialPortName:(id)aName
{
    if (sDevicesBySerialPortName == NULL) {
        sDevicesBySerialPortName = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFEWeakObjectPointerDictionaryValueCallBacks);
        if (sDevicesBySerialPortName == NULL)
            return nil;
    } else {
        id device = (id)CFDictionaryGetValue(sDevicesBySerialPortName, aName);
        if (device != nil)
            return device;
    }
    id device = [[[HSDistantArduinoDevice alloc] HSDistantArduinoDevice_initWithSerialPortName:aName] autorelease];
    if (device != nil)
        CFDictionaryAddValue(sDevicesBySerialPortName, aName, device);
    return device;
}

+ (id)defaultDevice
{
    if (sDefaultDevice == nil)
        sDefaultDevice = [[[HSDistantArduinoDevice alloc] HSDistantArduinoDevice_initWithSerialPortName:nil] autorelease];
    return sDefaultDevice;
}

+ (id)allocWithZone:(NSZone *)aZone
{
    HSDistantArduinoDevice *device = [super allocWithZone:aZone];
    if (device != nil)
        device->_retainCount = 1;
    return device;
}

// Pins with unknown state are read from the server, known ones are sent.
- (void)HSDistantArduinoDevice_updatePinCache
{
    NSDictionary *digitalPinState = (id)-1;
    for (NSUInteger i = 0; i < 12; i++) {
        unsigned char pin = (unsigned char)(i + 2);
        if (_digitalPinModes[i] == -1) {
            NSNumber *key = [NSNumber numberWithUnsignedChar:pin];
            if (key == nil)
                continue;
            if (digitalPinState == (id)-1)
                digitalPinState = [_deviceProxy digitalPinState];
            NSValue *state = [digitalPinState objectForKey:key];
            if (state != nil) {
                int mode;
                [state HS_getArduinoPinStateChangeToMode:&mode value:&_digitalPinValues[i] atTime:&_digitalPinStateTimes[i]];
                _digitalPinModes[i] = (signed char)mode;
            }
        } else {
            _digitalPinBeingChanged = pin;
            [_deviceProxy setMode:_digitalPinModes[i] value:_digitalPinValues[i] forDigitalPin:pin withChangeTime:_digitalPinStateTimes[i]];
            _digitalPinBeingChanged = 14;
        }
    }
    NSDictionary *analogPinState = (id)-1;
    for (NSUInteger i = 0; i < 6; i++) {
        unsigned char pin = (unsigned char)i;
        if (_analogPinModes[i] == -1) {
            NSNumber *key = [NSNumber numberWithUnsignedChar:pin];
            if (key == nil)
                continue;
            if (analogPinState == (id)-1)
                analogPinState = [_deviceProxy analogPinState];
            NSValue *state = [analogPinState objectForKey:key];
            if (state != nil) {
                int mode;
                [state HS_getArduinoPinStateChangeToMode:&mode value:&_analogPinValues[i] atTime:&_analogPinStateTimes[i]];
                _analogPinModes[i] = (signed char)mode;
            }
        } else {
            _analogPinBeingChanged = pin;
            [_deviceProxy setMode:_analogPinModes[i] value:_analogPinValues[i] forAnalogPin:pin withChangeTime:_analogPinStateTimes[i]];
            _analogPinBeingChanged = 6;
        }
    }
}

- (void)deviceDidChangeConnectionStatus:(NSInteger)aStatus
{
    if (_deviceConnectionStatus == (unsigned int)(aStatus & 0xffff))
        return;
    _deviceConnectionStatus = (unsigned int)aStatus;
    if (_deviceConnectionStatus == 6)
        [self HSDistantArduinoDevice_updatePinCache];
    [[NSNotificationCenter defaultCenter] postNotificationName:HSArduinoDeviceConnectionStatusDidChangeNotification object:self];
}

- (void)analogPinStateDidChange:(id)aChange
{
    NSMutableIndexSet *changedPins = nil;
    if (aChange != nil) {
        HSArduinoPinStateUpdate update = { _analogPinModes, _analogPinValues, _analogPinStateTimes, (id)-1, _analogPinBeingChanged };
        CFDictionaryApplyFunction((CFDictionaryRef)aChange, HSArduinoApplyAnalogPinStateChange, &update);
        changedPins = update.changedPins;
    }
    if (changedPins == (id)-1)
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:HSArduinoDevicePinStateDidChangeNotification object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:changedPins, HSArduinoDeviceNotificationInfoAnalogPins, nil]];
    [changedPins release];
}

- (void)digitalPinStateDidChange:(id)aChange
{
    NSMutableIndexSet *changedPins = nil;
    if (aChange != nil) {
        HSArduinoPinStateUpdate update = { _digitalPinModes, _digitalPinValues, _digitalPinStateTimes, (id)-1, _digitalPinBeingChanged };
        CFDictionaryApplyFunction((CFDictionaryRef)aChange, HSArduinoApplyDigitalPinStateChange, &update);
        changedPins = update.changedPins;
    }
    if (changedPins == (id)-1)
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:HSArduinoDevicePinStateDidChangeNotification object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:changedPins, HSArduinoDeviceNotificationInfoDigitalPins, nil]];
    [changedPins release];
}

- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin
{
    _analogPinStateTimes[aPin] = mach_absolute_time();
    _analogPinBeingChanged = aPin;
    [_deviceProxy setMode:aMode value:aValue forAnalogPin:aPin withChangeTime:_analogPinStateTimes[aPin]];
    _analogPinBeingChanged = 6;
    [super setMode:aMode value:aValue forAnalogPin:aPin];
}

- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin
{
    _digitalPinStateTimes[aPin - 2] = mach_absolute_time();
    _digitalPinBeingChanged = aPin;
    [_deviceProxy setMode:aMode value:aValue forDigitalPin:aPin withChangeTime:_digitalPinStateTimes[aPin - 2]];
    _digitalPinBeingChanged = 14;
    [super setMode:aMode value:aValue forDigitalPin:aPin];
}

- (NSInteger)connectionStatus
{
    return _deviceConnectionStatus;
}

- (void)noteArduinoServerDidDisconnect
{
    [_deviceProxy release];
    _deviceProxy = nil;
    if (_deviceConnectionStatus != 1) {
        _deviceConnectionStatus = 1;
        [[NSNotificationCenter defaultCenter] postNotificationName:HSArduinoDeviceConnectionStatusDidChangeNotification object:self];
    }
}

- (void)noteArduinoServerDidConnect
{
    if (_serialPortName != nil)
        _deviceProxy = [sArduinoServer retainDeviceWithSerialPortName:_serialPortName observer:self];
    else
        _deviceProxy = [sArduinoServer retainDefaultDeviceWithObserver:self];
    if (_deviceProxy == nil)
        return;
    [[_deviceProxy retain] setProtocolForProxy:@protocol(HSDistantArduinoDevice)];
    [self HSDistantArduinoDevice_updatePinCache];
    NSInteger status = [_deviceProxy connectionStatus];
    if ((NSInteger)_deviceConnectionStatus != status) {
        _deviceConnectionStatus = (unsigned int)status;
        [[NSNotificationCenter defaultCenter] postNotificationName:HSArduinoDeviceConnectionStatusDidChangeNotification object:self];
    }
}

// When only the cache's reference is left (or none), the server device is
// released and the cache entry dropped.
- (oneway void)release
{
    unsigned int count = __atomic_sub_fetch(&_retainCount, 1, __ATOMIC_SEQ_CST);
    if ((count == 1 && _deviceProxy != nil) || count == 0) {
        [_deviceProxy releaseWithObserver:self];
        [_deviceProxy release];
        _deviceProxy = nil;
        if (sDefaultDevice == self)
            sDefaultDevice = nil;
        else if (sDevicesBySerialPortName != NULL)
            CFDictionaryRemoveValue(sDevicesBySerialPortName, _serialPortName);
    }
    [super release];
}

- (id)retain
{
    __atomic_add_fetch(&_retainCount, 1, __ATOMIC_SEQ_CST);
    return [super retain];
}

- (void)dealloc
{
    [_serialPortName release];
    [super dealloc];
}

- (id)HSDistantArduinoDevice_initWithSerialPortName:(id)aName
{
    self = [super init];
    if (self == nil)
        return nil;
    if (aName != nil) {
        _serialPortName = [aName copy];
        if (_serialPortName == nil) {
            [self release];
            return nil;
        }
    }
    if (_serialPortName != nil)
        _deviceProxy = [sArduinoServer retainDeviceWithSerialPortName:_serialPortName observer:self];
    else
        _deviceProxy = [sArduinoServer retainDefaultDeviceWithObserver:self];
    if (_deviceProxy == nil) {
        _deviceConnectionStatus = 1;
    } else {
        [[_deviceProxy retain] setProtocolForProxy:@protocol(HSDistantArduinoDevice)];
        NSDictionary *digitalPinState = [_deviceProxy digitalPinState];
        if (digitalPinState != nil) {
            HSArduinoPinStateCache cache = { _digitalPinModes, _digitalPinValues, _digitalPinStateTimes };
            CFDictionaryApplyFunction((CFDictionaryRef)digitalPinState, HSArduinoLoadDigitalPinState, &cache);
        }
        NSDictionary *analogPinState = [_deviceProxy analogPinState];
        if (analogPinState != nil) {
            HSArduinoPinStateCache cache = { _analogPinModes, _analogPinValues, _analogPinStateTimes };
            CFDictionaryApplyFunction((CFDictionaryRef)analogPinState, HSArduinoLoadAnalogPinState, &cache);
        }
        _deviceConnectionStatus = (unsigned int)[_deviceProxy connectionStatus];
    }
    _digitalPinBeingChanged = 14;
    _analogPinBeingChanged = 6;
    return self;
}

- (id)init
{
    [self release];
    return nil;
}

@end
