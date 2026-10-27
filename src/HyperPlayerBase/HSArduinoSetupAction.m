#import "HSArduinoSetupAction.h"
#import "HSArduinoDevice.h"
#import "SMKApplicationKitData.h"

// Pin configurations are stored as pin -> (value << 8) | mode in CF
// dictionaries with unsigned integer keys and values; 0xffffffff stands for
// "no configuration".

static void HSArduinoApplyAnalogPinConfiguration(const void *aKey, const void *aValue, void *aContext)
{
    NSUInteger configuration = (NSUInteger)aValue;
    [(HSArduinoDevice *)aContext setMode:configuration & 0xff value:(unsigned short)(configuration >> 8) forAnalogPin:(unsigned char)(NSUInteger)aKey];
}

static void HSArduinoApplyDigitalPinConfiguration(const void *aKey, const void *aValue, void *aContext)
{
    NSUInteger configuration = (NSUInteger)aValue;
    [(HSArduinoDevice *)aContext setMode:configuration & 0xff value:(unsigned short)(configuration >> 8) forDigitalPin:(unsigned char)(NSUInteger)aKey];
}

static void HSArduinoAddConfigurationString(const void *aKey, const void *aValue, void *aContext)
{
    NSString *key = [NSString stringWithFormat:@"%d", (int)(NSUInteger)aKey];
    if (key == nil)
        return;
    NSString *value = [NSString stringWithFormat:@"%d", (int)(NSUInteger)aValue];
    if (value != nil)
        [(NSMutableDictionary *)aContext setObject:value forKey:key];
}

static void HSArduinoSetConfigurationFromStrings(const void *aKey, const void *aValue, void *aContext)
{
    int pin = [(id)aKey intValue];
    CFDictionarySetValue((CFMutableDictionaryRef)aContext, (const void *)(NSUInteger)pin, (const void *)(NSUInteger)[(id)aValue intValue]);
}

// Combined dictionary: pins 0-15 are digital, 16 and up are analog pin - 16.
static void HSArduinoSetPinConfigurationFromStrings(const void *aKey, const void *aValue, void *aContext)
{
    CFMutableDictionaryRef *dictionaries = (CFMutableDictionaryRef *)aContext;
    unsigned int pin = [(id)aKey intValue];
    int configuration = [(id)aValue intValue];
    if (pin < 0x10)
        CFDictionarySetValue(dictionaries[0], (const void *)(NSUInteger)pin, (const void *)(NSUInteger)configuration);
    else
        CFDictionarySetValue(dictionaries[1], (const void *)(NSUInteger)(pin - 0x10), (const void *)(NSUInteger)configuration);
}

@implementation HSArduinoSetupAction

- (void)startInContext:(id)aContext
{
    [self setupDevice];
    [self notifyDidFinish];
}

- (void)setupDevice
{
    if (_digitalPinConfigurationDictionary != NULL)
        CFDictionaryApplyFunction(_digitalPinConfigurationDictionary, HSArduinoApplyDigitalPinConfiguration, _device);
    if (_analogPinConfigurationDictionary != NULL)
        CFDictionaryApplyFunction(_analogPinConfigurationDictionary, HSArduinoApplyAnalogPinConfiguration, _device);
}

- (void)setAnalogPinConfigurationDictionary:(struct __CFDictionary *)aDictionary
{
    if (aDictionary == NULL) {
        if (_analogPinConfigurationDictionary == NULL || CFDictionaryGetCount(_analogPinConfigurationDictionary) == 0)
            return;
    } else if (_analogPinConfigurationDictionary != NULL && CFEqual(aDictionary, _analogPinConfigurationDictionary)) {
        return;
    }
    CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, aDictionary);
    if (aDictionary == NULL || copy != NULL) {
        [self HSArduinoSetupAction_setAnalogPinConfigurationDictionary:copy];
        if (copy != NULL)
            CFRelease(copy);
    }
}

- (void)HSArduinoSetupAction_setAnalogPinConfigurationDictionary:(struct __CFDictionary *)aDictionary
{
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Arduino Pin Configuration" value:@"" table:@"UndoManager"]];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_notifyUndoOrRedoChange:0x200 withUserInfo:nil];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_setAnalogPinConfigurationDictionary:_analogPinConfigurationDictionary];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_notifyUndoOrRedoChange:0x100 withUserInfo:nil];
        // The undo invocation does not retain its arguments, so the old
        // dictionary is kept alive here (and leaks, as in the original, which
        // also called CFRetain on NULL).
        if (_analogPinConfigurationDictionary != NULL)
            CFRetain(_analogPinConfigurationDictionary);
    }
    id center = [self attributeNotificationCenter];
    // Validity only changes when going from or to an empty configuration.
    Protocol *validation = @protocol(HSActionValidationStatusAttribute);
    if (_analogPinConfigurationDictionary != NULL && aDictionary != NULL
        && CFDictionaryGetCount(_analogPinConfigurationDictionary) != 0 && CFDictionaryGetCount(aDictionary) != 0)
        validation = nil;
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSArduinoPinConfigurationAttribute), validation, nil];
    if (attributes != nil)
        [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    if (aDictionary != NULL)
        CFRetain(aDictionary);
    if (_analogPinConfigurationDictionary != NULL)
        CFRelease(_analogPinConfigurationDictionary);
    _analogPinConfigurationDictionary = aDictionary;
    if (attributes != nil)
        [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

- (struct __CFDictionary *)analogPinConfigurationDictionary
{
    CFDictionaryRef dictionary;
    if (_analogPinConfigurationDictionary == NULL)
        dictionary = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
    else
        dictionary = CFDictionaryCreateCopy(kCFAllocatorDefault, _analogPinConfigurationDictionary);
    return (struct __CFDictionary *)[(id)dictionary autorelease];
}

- (void)removeConfigurationForAnalogPin:(unsigned char)aPin
{
    if (_analogPinConfigurationDictionary == NULL || CFDictionaryGetCount(_analogPinConfigurationDictionary) == 0)
        return;
    NSUInteger previous = 0xffffffff;
    if (CFDictionaryGetValueIfPresent(_analogPinConfigurationDictionary, (const void *)(NSUInteger)aPin, (const void **)&previous))
        [self HSArduinoSetupAction_setConfiguration:0xffffffff forAnalogPin:aPin withPreviousConfiguration:previous];
}

- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin
{
    if (_analogPinConfigurationDictionary == NULL) {
        _analogPinConfigurationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_analogPinConfigurationDictionary == NULL)
            return;
    }
    NSUInteger previous = 0xffffffff;
    NSUInteger configuration = (uint32_t)(((unsigned int)aValue << 8) | (uint32_t)aMode);
    CFDictionaryGetValueIfPresent(_analogPinConfigurationDictionary, (const void *)(NSUInteger)aPin, (const void **)&previous);
    if (previous != configuration)
        [self HSArduinoSetupAction_setConfiguration:configuration forAnalogPin:aPin withPreviousConfiguration:previous];
}

- (void)HSArduinoSetupAction_setConfiguration:(NSUInteger)aConfiguration forAnalogPin:(NSUInteger)aPin withPreviousConfiguration:(NSUInteger)aConfiguration2
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:aPin], @"analogPin", nil];
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Arduino Pin Configuration" value:@"" table:@"UndoManager"]];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_notifyUndoOrRedoChange:0x200 withUserInfo:userInfo];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_setConfiguration:aConfiguration2 forAnalogPin:aPin];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_notifyUndoOrRedoChange:0x100 withUserInfo:userInfo];
    }
    id center = [self attributeNotificationCenter];
    CFIndex count = CFDictionaryGetCount(_analogPinConfigurationDictionary);
    // Removing the last pin or adding the first changes validity.
    Protocol *validation = nil;
    if (aConfiguration == 0xffffffff ? count == 1 : count == 0)
        validation = @protocol(HSActionValidationStatusAttribute);
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSArduinoPinConfigurationAttribute), validation, nil];
    if (attributes != nil)
        [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
    if (aConfiguration == 0xffffffff)
        CFDictionaryRemoveValue(_analogPinConfigurationDictionary, (const void *)aPin);
    else
        CFDictionarySetValue(_analogPinConfigurationDictionary, (const void *)aPin, (const void *)aConfiguration);
    if (attributes != nil)
        [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
}

- (void)HSArduinoSetupAction_setConfiguration:(NSUInteger)aConfiguration forAnalogPin:(NSUInteger)aPin
{
    NSUInteger previous = 0xffffffff;
    CFDictionaryGetValueIfPresent(_analogPinConfigurationDictionary, (const void *)aPin, (const void **)&previous);
    [self HSArduinoSetupAction_setConfiguration:aConfiguration forAnalogPin:aPin withPreviousConfiguration:previous];
}

- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forAnalogPin:(unsigned char)aPin
{
    NSUInteger configuration;
    if (_analogPinConfigurationDictionary == NULL || CFDictionaryGetCount(_analogPinConfigurationDictionary) == 0
        || !CFDictionaryGetValueIfPresent(_analogPinConfigurationDictionary, (const void *)(NSUInteger)aPin, (const void **)&configuration))
        return NO;
    if (aMode != NULL)
        *aMode = configuration & 0xff;
    if (aValue != NULL)
        *aValue = (unsigned short)(configuration >> 8);
    return YES;
}

- (void)setDigitalPinConfigurationDictionary:(struct __CFDictionary *)aDictionary
{
    if (aDictionary == NULL) {
        if (_digitalPinConfigurationDictionary == NULL || CFDictionaryGetCount(_digitalPinConfigurationDictionary) == 0)
            return;
    } else if (_digitalPinConfigurationDictionary != NULL && CFEqual(aDictionary, _digitalPinConfigurationDictionary)) {
        return;
    }
    CFMutableDictionaryRef copy = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, aDictionary);
    if (aDictionary == NULL || copy != NULL) {
        [self HSArduinoSetupAction_setDigitalPinConfigurationDictionary:copy];
        if (copy != NULL)
            CFRelease(copy);
    }
}

- (void)HSArduinoSetupAction_setDigitalPinConfigurationDictionary:(struct __CFDictionary *)aDictionary
{
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Arduino Pin Configuration" value:@"" table:@"UndoManager"]];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_notifyUndoOrRedoChange:0x200 withUserInfo:nil];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_setDigitalPinConfigurationDictionary:_digitalPinConfigurationDictionary];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_notifyUndoOrRedoChange:0x100 withUserInfo:nil];
        // The undo invocation does not retain its arguments, so the old
        // dictionary is kept alive here (and leaks, as in the original, which
        // also called CFRetain on NULL).
        if (_digitalPinConfigurationDictionary != NULL)
            CFRetain(_digitalPinConfigurationDictionary);
    }
    id center = [self attributeNotificationCenter];
    // Validity only changes when going from or to an empty configuration.
    Protocol *validation = @protocol(HSActionValidationStatusAttribute);
    if (_digitalPinConfigurationDictionary != NULL && aDictionary != NULL
        && CFDictionaryGetCount(_digitalPinConfigurationDictionary) != 0 && CFDictionaryGetCount(aDictionary) != 0)
        validation = nil;
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSArduinoPinConfigurationAttribute), validation, nil];
    if (attributes != nil)
        [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    if (aDictionary != NULL)
        CFRetain(aDictionary);
    if (_digitalPinConfigurationDictionary != NULL)
        CFRelease(_digitalPinConfigurationDictionary);
    _digitalPinConfigurationDictionary = aDictionary;
    if (attributes != nil)
        [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

- (struct __CFDictionary *)digitalPinConfigurationDictionary
{
    CFDictionaryRef dictionary;
    if (_digitalPinConfigurationDictionary == NULL)
        dictionary = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
    else
        dictionary = CFDictionaryCreateCopy(kCFAllocatorDefault, _digitalPinConfigurationDictionary);
    return (struct __CFDictionary *)[(id)dictionary autorelease];
}

- (void)removeConfigurationForDigitalPin:(unsigned char)aPin
{
    if (_digitalPinConfigurationDictionary == NULL || CFDictionaryGetCount(_digitalPinConfigurationDictionary) == 0)
        return;
    NSUInteger previous = 0xffffffff;
    if (CFDictionaryGetValueIfPresent(_digitalPinConfigurationDictionary, (const void *)(NSUInteger)aPin, (const void **)&previous))
        [self HSArduinoSetupAction_setConfiguration:0xffffffff forDigitalPin:aPin withPreviousConfiguration:previous];
}

- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin
{
    if (_digitalPinConfigurationDictionary == NULL) {
        _digitalPinConfigurationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_digitalPinConfigurationDictionary == NULL)
            return;
    }
    NSUInteger previous = 0xffffffff;
    NSUInteger configuration = (uint32_t)(((unsigned int)aValue << 8) | (uint32_t)aMode);
    CFDictionaryGetValueIfPresent(_digitalPinConfigurationDictionary, (const void *)(NSUInteger)aPin, (const void **)&previous);
    if (previous != configuration)
        [self HSArduinoSetupAction_setConfiguration:configuration forDigitalPin:aPin withPreviousConfiguration:previous];
}

- (void)HSArduinoSetupAction_setConfiguration:(NSUInteger)aConfiguration forDigitalPin:(NSUInteger)aPin withPreviousConfiguration:(NSUInteger)aConfiguration2
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:aPin], @"digitalPin", nil];
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Arduino Pin Configuration" value:@"" table:@"UndoManager"]];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_notifyUndoOrRedoChange:0x200 withUserInfo:userInfo];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_setConfiguration:aConfiguration2 forDigitalPin:aPin];
        [(HSArduinoSetupAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoSetupAction_notifyUndoOrRedoChange:0x100 withUserInfo:userInfo];
    }
    id center = [self attributeNotificationCenter];
    CFIndex count = CFDictionaryGetCount(_digitalPinConfigurationDictionary);
    // Removing the last pin or adding the first changes validity.
    Protocol *validation = nil;
    if (aConfiguration == 0xffffffff ? count == 1 : count == 0)
        validation = @protocol(HSActionValidationStatusAttribute);
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSArduinoPinConfigurationAttribute), validation, nil];
    if (attributes != nil)
        [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
    if (aConfiguration == 0xffffffff)
        CFDictionaryRemoveValue(_digitalPinConfigurationDictionary, (const void *)aPin);
    else
        CFDictionarySetValue(_digitalPinConfigurationDictionary, (const void *)aPin, (const void *)aConfiguration);
    if (attributes != nil)
        [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
}

- (void)HSArduinoSetupAction_setConfiguration:(NSUInteger)aConfiguration forDigitalPin:(NSUInteger)aPin
{
    NSUInteger previous = 0xffffffff;
    CFDictionaryGetValueIfPresent(_digitalPinConfigurationDictionary, (const void *)aPin, (const void **)&previous);
    [self HSArduinoSetupAction_setConfiguration:aConfiguration forDigitalPin:aPin withPreviousConfiguration:previous];
}

- (BOOL)getMode:(int *)aMode value:(unsigned short *)aValue forDigitalPin:(unsigned char)aPin
{
    NSUInteger configuration;
    if (_digitalPinConfigurationDictionary == NULL || CFDictionaryGetCount(_digitalPinConfigurationDictionary) == 0
        || !CFDictionaryGetValueIfPresent(_digitalPinConfigurationDictionary, (const void *)(NSUInteger)aPin, (const void **)&configuration))
        return NO;
    if (aMode != NULL)
        *aMode = configuration & 0xff;
    if (aValue != NULL)
        *aValue = (unsigned short)(configuration >> 8);
    return YES;
}

- (void)HSArduinoSetupAction_notifyUndoOrRedoChange:(NSInteger)aChange withUserInfo:(id)aInfo
{
    [[self attributeNotificationCenter] notifyChange:aChange ofAttribute:@protocol(HSArduinoPinConfigurationAttribute) ofObject:self withUserInfo:aInfo];
}

- (BOOL)isAbleToStartInInvalidState
{
    return YES;
}

- (BOOL)isValid
{
    if (_digitalPinConfigurationDictionary != NULL && CFDictionaryGetCount(_digitalPinConfigurationDictionary) > 0)
        return YES;
    return _analogPinConfigurationDictionary != NULL && CFDictionaryGetCount(_analogPinConfigurationDictionary) > 0;
}

- (void)setAnalogPinConfigurationAsStringsDictionary:(id)aDictionary
{
    if (_analogPinConfigurationDictionary == NULL) {
        _analogPinConfigurationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_analogPinConfigurationDictionary == NULL)
            return;
    } else {
        CFDictionaryRemoveAllValues(_analogPinConfigurationDictionary);
    }
    CFDictionaryApplyFunction((CFDictionaryRef)aDictionary, HSArduinoSetConfigurationFromStrings, _analogPinConfigurationDictionary);
}

- (void)setDigitalPinConfigurationAsStringsDictionary:(id)aDictionary
{
    if (_digitalPinConfigurationDictionary == NULL) {
        _digitalPinConfigurationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_digitalPinConfigurationDictionary == NULL)
            return;
    } else {
        CFDictionaryRemoveAllValues(_digitalPinConfigurationDictionary);
    }
    CFDictionaryApplyFunction((CFDictionaryRef)aDictionary, HSArduinoSetConfigurationFromStrings, _digitalPinConfigurationDictionary);
}

// Older documents store both pin kinds in one dictionary.
- (void)setPinConfigurationAsStringsDictionary:(id)aDictionary
{
    if (aDictionary == nil)
        return;
    if (_digitalPinConfigurationDictionary == NULL) {
        _digitalPinConfigurationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_digitalPinConfigurationDictionary == NULL)
            return;
    } else {
        CFDictionaryRemoveAllValues(_digitalPinConfigurationDictionary);
    }
    if (_analogPinConfigurationDictionary == NULL) {
        _analogPinConfigurationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_analogPinConfigurationDictionary == NULL)
            return;
    } else {
        CFDictionaryRemoveAllValues(_analogPinConfigurationDictionary);
    }
    CFMutableDictionaryRef dictionaries[2] = { _digitalPinConfigurationDictionary, _analogPinConfigurationDictionary };
    CFDictionaryApplyFunction((CFDictionaryRef)aDictionary, HSArduinoSetPinConfigurationFromStrings, dictionaries);
}

- (id)pinConfigurationAsStringsDictionary
{
    return [NSDictionary dictionary];
}

- (id)analogPinConfigurationAsStringsDictionary
{
    if (_analogPinConfigurationDictionary == NULL)
        return [NSDictionary dictionary];
    NSMutableDictionary *strings = [NSMutableDictionary dictionaryWithCapacity:CFDictionaryGetCount(_analogPinConfigurationDictionary)];
    CFDictionaryApplyFunction(_analogPinConfigurationDictionary, HSArduinoAddConfigurationString, strings);
    return strings;
}

- (id)digitalPinConfigurationAsStringsDictionary
{
    if (_digitalPinConfigurationDictionary == NULL)
        return [NSDictionary dictionary];
    NSMutableDictionary *strings = [NSMutableDictionary dictionaryWithCapacity:CFDictionaryGetCount(_digitalPinConfigurationDictionary)];
    CFDictionaryApplyFunction(_digitalPinConfigurationDictionary, HSArduinoAddConfigurationString, strings);
    return strings;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:@"digitalPinConfigurationAsStringsDictionary", @"analogPinConfigurationAsStringsDictionary", nil]];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [[super keysForExtraLoadingWithCodingContext:aContext] arrayByAddingObject:@"pinConfigurationAsStringsDictionary"];
}

- (void)dealloc
{
    if (_digitalPinConfigurationDictionary != NULL)
        CFRelease(_digitalPinConfigurationDictionary);
    if (_analogPinConfigurationDictionary != NULL)
        CFRelease(_analogPinConfigurationDictionary);
    [_device release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil)
        _device = [[HSArduinoDevice defaultDevice] retain];
    return self;
}

@end
