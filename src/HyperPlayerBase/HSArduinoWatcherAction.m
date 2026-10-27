#import "HSArduinoWatcherAction.h"
#import "HSActionExecutionContext.h"
#import "HSArduinoDevice.h"

// Each watched object (by UID string) has a digital and an analog CF
// dictionary of pin -> range, with unsigned integer keys and values. A range
// packs (end << 20) | (start << 8) | mode, start and end being 12-bit pin
// values; 0xffffffff stands for "no range". An object triggers while every
// one of its pins is in that mode with a value inside its range.

static NSUInteger HSArduinoRange(NSInteger aMode, unsigned short aStart, unsigned short aEnd)
{
    return (uint32_t)(((unsigned int)aEnd << 20) | ((unsigned int)aStart << 8) | (uint32_t)aMode);
}

static BOOL HSArduinoGetRange(CFDictionaryRef aRanges, unsigned char aPin, int *aMode, unsigned short *aStart, unsigned short *aEnd)
{
    NSUInteger range;
    if (!CFDictionaryGetValueIfPresent(aRanges, (const void *)(NSUInteger)aPin, (const void **)&range))
        return NO;
    if (aMode != NULL)
        *aMode = range & 0xff;
    if (aStart != NULL)
        *aStart = (range >> 8) & 0xfff;
    if (aEnd != NULL)
        *aEnd = (unsigned short)(range >> 20);
    return YES;
}

static BOOL HSArduinoRangeContains(NSUInteger aRange, int aMode, unsigned short aValue)
{
    return (int)(aRange & 0xff) == aMode && ((aRange >> 8) & 0xfff) <= aValue && aValue <= (unsigned short)(aRange >> 20);
}

// Applier context: a BOOL that stays YES while every pin is in range.
static void HSArduinoCheckDigitalRange(const void *aKey, const void *aValue, void *aContext)
{
    BOOL *triggering = (BOOL *)aContext;
    if (!*triggering)
        return;
    int mode;
    unsigned short value;
    *triggering = [[HSArduinoDevice defaultDevice] getMode:&mode value:&value forDigitalPin:(unsigned char)(NSUInteger)aKey]
        && HSArduinoRangeContains((NSUInteger)aValue, mode, value);
}

static void HSArduinoCheckAnalogRange(const void *aKey, const void *aValue, void *aContext)
{
    BOOL *triggering = (BOOL *)aContext;
    if (!*triggering)
        return;
    int mode;
    unsigned short value;
    *triggering = [[HSArduinoDevice defaultDevice] getMode:&mode value:&value forAnalogPin:(unsigned char)(NSUInteger)aKey]
        && HSArduinoRangeContains((NSUInteger)aValue, mode, value);
}

// Merges a range into the ranges dictionary aContext: a range in the same
// mode as the existing one widens it, another mode leaves it.
static void HSArduinoMergeRange(const void *aKey, const void *aValue, void *aContext)
{
    NSUInteger range = (NSUInteger)aValue;
    NSUInteger existing = 0;
    if (CFDictionaryGetValueIfPresent((CFDictionaryRef)aContext, aKey, (const void **)&existing)) {
        if ((existing & 0xff) != (range & 0xff))
            return;
        NSUInteger start = MIN((existing >> 8) & 0xfff, (range >> 8) & 0xfff);
        NSUInteger end = MAX((existing >> 20) & 0xfff, (range >> 20) & 0xfff);
        range = (uint32_t)((end << 20) | (start << 8) | (existing & 0xff));
    }
    CFDictionarySetValue((CFMutableDictionaryRef)aContext, aKey, (const void *)range);
}

struct HSArduinoMergeContext {
    CFMutableDictionaryRef mappings;
    id replacedUIDs;
};

// Merges an object's ranges into the mappings, unless the object is replaced.
static void HSArduinoMergeObjectRanges(const void *aKey, const void *aValue, void *aContext)
{
    struct HSArduinoMergeContext *context = (struct HSArduinoMergeContext *)aContext;
    if ([context->replacedUIDs containsObject:(id)aKey])
        return;
    CFDictionaryRef existing = CFDictionaryGetValue(context->mappings, aKey);
    if (existing == NULL) {
        CFDictionarySetValue(context->mappings, aKey, aValue);
        return;
    }
    CFMutableDictionaryRef merged = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, existing);
    CFDictionaryApplyFunction((CFDictionaryRef)aValue, HSArduinoMergeRange, merged);
    CFDictionarySetValue(context->mappings, aKey, merged);
    CFRelease(merged);
}

// The stored numbers may print negative (%d of a range above 0x7fffffff), so
// anything up to 32 bits is accepted back.
static BOOL HSArduinoScanRange(id aString, NSUInteger *aRange)
{
    long long value = 0;
    if (![[NSScanner scannerWithString:aString] scanLongLong:&value] || (value >> 32) >= 1)
        return NO;
    *aRange = (uint32_t)value;
    return YES;
}

static void HSArduinoAddRangeFromStrings(const void *aKey, const void *aValue, void *aContext)
{
    NSUInteger range;
    if (HSArduinoScanRange((id)aValue, &range))
        CFDictionarySetValue((CFMutableDictionaryRef)aContext, (const void *)(NSUInteger)[(id)aKey intValue], (const void *)range);
}

// Combined pins: 0-15 are digital, 16 and up are analog pin - 16.
static void HSArduinoAddCombinedRangeFromStrings(const void *aKey, const void *aValue, void *aContext)
{
    CFMutableDictionaryRef *dictionaries = (CFMutableDictionaryRef *)aContext;
    NSUInteger range;
    if (!HSArduinoScanRange((id)aValue, &range))
        return;
    int pin = [(id)aKey intValue];
    if (pin > 0xf)
        CFDictionarySetValue(dictionaries[1], (const void *)(NSUInteger)(pin - 0x10), (const void *)range);
    else
        CFDictionarySetValue(dictionaries[0], (const void *)(NSUInteger)pin, (const void *)range);
}

static CFMutableDictionaryRef HSArduinoCreateRangesDictionary(void)
{
    return CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
}

static CFMutableDictionaryRef HSArduinoCreateMappingsDictionary(void)
{
    return CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
}

static void HSArduinoSetRangesFromStrings(const void *aKey, const void *aValue, void *aContext)
{
    CFMutableDictionaryRef ranges = HSArduinoCreateRangesDictionary();
    if (ranges == NULL)
        return;
    CFDictionaryApplyFunction((CFDictionaryRef)aValue, HSArduinoAddRangeFromStrings, ranges);
    CFDictionarySetValue((CFMutableDictionaryRef)aContext, aKey, ranges);
    CFRelease(ranges);
}

static void HSArduinoSetCombinedRangesFromStrings(const void *aKey, const void *aValue, void *aContext)
{
    CFMutableDictionaryRef *mappings = (CFMutableDictionaryRef *)aContext;
    CFMutableDictionaryRef digital = HSArduinoCreateRangesDictionary();
    if (digital == NULL)
        return;
    CFMutableDictionaryRef analog = HSArduinoCreateRangesDictionary();
    if (analog != NULL) {
        CFMutableDictionaryRef dictionaries[2] = { digital, analog };
        CFDictionaryApplyFunction((CFDictionaryRef)aValue, HSArduinoAddCombinedRangeFromStrings, dictionaries);
        CFDictionarySetValue(mappings[0], aKey, digital);
        CFDictionarySetValue(mappings[1], aKey, analog);
        CFRelease(analog);
    }
    CFRelease(digital);
}

static void HSArduinoAddRangeString(const void *aKey, const void *aValue, void *aContext)
{
    NSString *key = [NSString stringWithFormat:@"%d", (int)(NSUInteger)aKey];
    if (key == nil)
        return;
    NSString *value = [NSString stringWithFormat:@"%d", (int)(NSUInteger)aValue];
    if (value != nil)
        [(NSMutableDictionary *)aContext setObject:value forKey:key];
}

static void HSArduinoAddRangeStrings(const void *aKey, const void *aValue, void *aContext)
{
    NSMutableDictionary *strings = [[NSMutableDictionary alloc] initWithCapacity:CFDictionaryGetCount((CFDictionaryRef)aValue)];
    if (strings == nil)
        return;
    CFDictionaryApplyFunction((CFDictionaryRef)aValue, HSArduinoAddRangeString, strings);
    [(NSMutableDictionary *)aContext setObject:strings forKey:(id)aKey];
    [strings release];
}

static void HSArduinoCopyObjectRanges(const void *aKey, const void *aValue, void *aContext)
{
    CFMutableDictionaryRef ranges = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)aValue);
    if (ranges == NULL)
        return;
    CFDictionarySetValue((CFMutableDictionaryRef)aContext, aKey, ranges);
    CFRelease(ranges);
}

// Copies the mappings with their ranges dictionaries (the original's
// NSE_mutableCopyToDepth:1 / NSE_copyToDepth:1).
static CFMutableDictionaryRef HSArduinoCreateMappingsCopy(CFDictionaryRef aMappings)
{
    if (aMappings == NULL)
        return NULL;
    CFMutableDictionaryRef copy = HSArduinoCreateMappingsDictionary();
    if (copy != NULL)
        CFDictionaryApplyFunction(aMappings, HSArduinoCopyObjectRanges, copy);
    return copy;
}

@implementation HSArduinoWatcherAction

// Collects the stack's objects that have ranges into the context's watchers.
- (void)startInContext:(id)aContext
{
    __HSArduinoWatchers *watchers = nil;
    if (_digitalPinConfigurationRangeMappings != NULL && _analogPinConfigurationRangeMappings != NULL) {
        CFIndex digitalCount = CFDictionaryGetCount(_digitalPinConfigurationRangeMappings);
        CFIndex analogCount = CFDictionaryGetCount(_analogPinConfigurationRangeMappings);
        id container = [[self stack] queryHyperInterface:@protocol(HSNodeContainer)];
        if (analogCount != 0 && digitalCount != 0 && analogCount == digitalCount && container != nil) {
            NSEnumerator *enumerator = [container hyperDeepEnumerator];
            id node;
            while ((node = [enumerator nextObject]) != nil) {
                id object = [node queryHyperInterface:@protocol(HSObjectAttributes)];
                if (object == nil)
                    continue;
                NSString *uid = [[object hyperUID] stringValue];
                if (uid == nil)
                    break;
                CFDictionaryRef digital = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, uid);
                CFDictionaryRef analog = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, uid);
                if (digital == NULL || analog == NULL)
                    continue;
                if (watchers == nil) {
                    watchers = [[__HSArduinoWatchers alloc] init];
                    if (watchers == nil)
                        break;
                }
                [watchers addWatcher:object withDigitalPinConfigurationRanges:(struct __CFDictionary *)digital analogPinConfigurationRanges:(struct __CFDictionary *)analog];
            }
        }
    }
    [(HSActionExecutionContext *)aContext setArduinoWatchers:watchers];
    [watchers release];
    [self notifyDidFinish];
}

- (void)setDigitalPinConfigurationRangeMappings:(struct __CFDictionary *)aMappings analogPinConfigurationRangeMappings:(struct __CFDictionary *)aMappings2
{
    BOOL digitalChanged;
    if (aMappings == NULL)
        digitalChanged = _digitalPinConfigurationRangeMappings != NULL && CFDictionaryGetCount(_digitalPinConfigurationRangeMappings) != 0;
    else
        digitalChanged = _digitalPinConfigurationRangeMappings == NULL || !CFEqual(aMappings, _digitalPinConfigurationRangeMappings);
    if (!digitalChanged) {
        if (aMappings2 == NULL) {
            if (_analogPinConfigurationRangeMappings == NULL || CFDictionaryGetCount(_analogPinConfigurationRangeMappings) == 0)
                return;
        } else if (_analogPinConfigurationRangeMappings != NULL && CFEqual(aMappings2, _analogPinConfigurationRangeMappings)) {
            return;
        }
    }
    CFMutableDictionaryRef digital = HSArduinoCreateMappingsCopy(aMappings);
    if (aMappings != NULL && digital == NULL)
        return;
    CFMutableDictionaryRef analog = HSArduinoCreateMappingsCopy(aMappings2);
    if (aMappings2 == NULL || analog != NULL)
        [self HSArduinoWatcherAction_setDigitalPinConfigurationDictionary:digital analogPinConfigurationRangeMappings:analog];
    if (digital != NULL)
        CFRelease(digital);
    if (analog != NULL)
        CFRelease(analog);
}

- (void)HSArduinoWatcherAction_setDigitalPinConfigurationDictionary:(struct __CFDictionary *)aDictionary analogPinConfigurationRangeMappings:(struct __CFDictionary *)aMappings
{
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Arduino Pin Configuration Ranges" value:@"" table:@"UndoManager"]];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_notifyUndoOrRedoChange:0x200 withUserInfo:nil];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_setDigitalPinConfigurationDictionary:_digitalPinConfigurationRangeMappings analogPinConfigurationRangeMappings:_analogPinConfigurationRangeMappings];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_notifyUndoOrRedoChange:0x100 withUserInfo:nil];
        // The undo invocation does not retain its arguments, so the old
        // mappings are kept alive here (and leak, as in the original).
        if (_digitalPinConfigurationRangeMappings != NULL)
            CFRetain(_digitalPinConfigurationRangeMappings);
        if (_analogPinConfigurationRangeMappings != NULL)
            CFRetain(_analogPinConfigurationRangeMappings);
    }
    id center = [self attributeNotificationCenter];
    // Validity only changes when going from or to empty mappings.
    Protocol *validation = @protocol(HSActionValidationStatusAttribute);
    if ((_digitalPinConfigurationRangeMappings != NULL && aDictionary != NULL
         && CFDictionaryGetCount(_digitalPinConfigurationRangeMappings) != 0 && CFDictionaryGetCount(aDictionary) != 0)
        || (_analogPinConfigurationRangeMappings != NULL && aMappings != NULL
            && CFDictionaryGetCount(_analogPinConfigurationRangeMappings) != 0 && CFDictionaryGetCount(aMappings) != 0))
        validation = nil;
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute), validation, nil];
    if (attributes != nil)
        [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
    if (aDictionary != NULL)
        CFRetain(aDictionary);
    if (_digitalPinConfigurationRangeMappings != NULL)
        CFRelease(_digitalPinConfigurationRangeMappings);
    _digitalPinConfigurationRangeMappings = aDictionary;
    if (aMappings != NULL)
        CFRetain(aMappings);
    if (_analogPinConfigurationRangeMappings != NULL)
        CFRelease(_analogPinConfigurationRangeMappings);
    _analogPinConfigurationRangeMappings = aMappings;
    if (attributes != nil)
        [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:nil];
}

// Copies of the mappings (and of their ranges).
- (struct __CFDictionary *)analogPinConfigurationRangeMappings
{
    CFDictionaryRef mappings;
    if (_analogPinConfigurationRangeMappings == NULL)
        mappings = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    else
        mappings = HSArduinoCreateMappingsCopy(_analogPinConfigurationRangeMappings);
    return (struct __CFDictionary *)[(id)mappings autorelease];
}

- (struct __CFDictionary *)digitalPinConfigurationRangeMappings
{
    CFDictionaryRef mappings;
    if (_digitalPinConfigurationRangeMappings == NULL)
        mappings = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    else
        mappings = HSArduinoCreateMappingsCopy(_digitalPinConfigurationRangeMappings);
    return (struct __CFDictionary *)[(id)mappings autorelease];
}

- (void)removePinConfigurationRangesForObjectWithUID:(id)aUID
{
    if (_digitalPinConfigurationRangeMappings == NULL)
        return;
    CFDictionaryRef digital = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
    if (digital == NULL)
        return;
    CFDictionaryRef analog = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
    if (analog != NULL)
        [self HSArduinoWatcherAction_setDigitalConfigurationRanges:NULL analogConfigurationRanges:NULL forObjectWithUID:aUID withPreviousDigitalConfigurationRanges:(struct __CFDictionary *)digital previousAnalogConfigurationRanges:(struct __CFDictionary *)analog];
}

- (void)setDigitalPinConfigurationRanges:(struct __CFDictionary *)aRanges analogPinConfigurationRanges:(struct __CFDictionary *)aRanges2 forObjectWithUID:(id)aUID
{
    CFDictionaryRef previousDigital = NULL;
    CFDictionaryRef previousAnalog = NULL;
    if (_digitalPinConfigurationRangeMappings == NULL) {
        _digitalPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_digitalPinConfigurationRangeMappings == NULL)
            return;
        _analogPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_analogPinConfigurationRangeMappings == NULL) {
            CFRelease(_digitalPinConfigurationRangeMappings);
            _digitalPinConfigurationRangeMappings = NULL;
            return;
        }
    } else {
        previousDigital = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
        previousAnalog = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
        if (previousDigital != NULL && CFEqual(aRanges, previousDigital) && CFEqual(aRanges2, previousAnalog))
            return;
    }
    if (CFDictionaryGetCount(aRanges) == 0 && CFDictionaryGetCount(aRanges2) == 0)
        return;
    CFMutableDictionaryRef digital = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, aRanges);
    if (digital == NULL)
        return;
    CFMutableDictionaryRef analog = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, aRanges2);
    if (analog != NULL) {
        [self HSArduinoWatcherAction_setDigitalConfigurationRanges:digital analogConfigurationRanges:analog forObjectWithUID:aUID withPreviousDigitalConfigurationRanges:(struct __CFDictionary *)previousDigital previousAnalogConfigurationRanges:(struct __CFDictionary *)previousAnalog];
        CFRelease(analog);
    }
    CFRelease(digital);
}

// NULL ranges remove the object.
- (void)HSArduinoWatcherAction_setDigitalConfigurationRanges:(struct __CFDictionary *)aRanges analogConfigurationRanges:(struct __CFDictionary *)aRanges2 forObjectWithUID:(id)aUID withPreviousDigitalConfigurationRanges:(struct __CFDictionary *)aRanges3 previousAnalogConfigurationRanges:(struct __CFDictionary *)aRanges4
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aUID, @"objectUID", nil];
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Arduino Pin Configuration Ranges" value:@"" table:@"UndoManager"]];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_notifyUndoOrRedoChange:0x200 withUserInfo:userInfo];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_setDigitalConfigurationRanges:aRanges3 analogConfigurationRanges:aRanges4 forObjectWithUID:aUID];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_notifyUndoOrRedoChange:0x100 withUserInfo:userInfo];
        // kept alive for the undo invocation, as in the original
        if (aRanges3 != NULL)
            CFRetain(aRanges3);
        if (aRanges4 != NULL)
            CFRetain(aRanges4);
    }
    id center = [self attributeNotificationCenter];
    // Removing the last object or adding the first changes validity.
    CFIndex count = CFDictionaryGetCount(_digitalPinConfigurationRangeMappings);
    Protocol *validation = nil;
    if (aRanges == NULL ? count == 1 : count == 0)
        validation = @protocol(HSActionValidationStatusAttribute);
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute), validation, nil];
    if (attributes != nil)
        [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
    if (aRanges == NULL) {
        CFDictionaryRemoveValue(_digitalPinConfigurationRangeMappings, aUID);
        CFDictionaryRemoveValue(_analogPinConfigurationRangeMappings, aUID);
    } else {
        CFDictionarySetValue(_digitalPinConfigurationRangeMappings, aUID, aRanges);
        CFDictionarySetValue(_analogPinConfigurationRangeMappings, aUID, aRanges2);
    }
    if (attributes != nil)
        [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
}

- (void)HSArduinoWatcherAction_setDigitalConfigurationRanges:(struct __CFDictionary *)aRanges analogConfigurationRanges:(struct __CFDictionary *)aRanges2 forObjectWithUID:(id)aUID
{
    CFDictionaryRef previousAnalog = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
    CFDictionaryRef previousDigital = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
    [self HSArduinoWatcherAction_setDigitalConfigurationRanges:aRanges analogConfigurationRanges:aRanges2 forObjectWithUID:aUID withPreviousDigitalConfigurationRanges:(struct __CFDictionary *)previousDigital previousAnalogConfigurationRanges:(struct __CFDictionary *)previousAnalog];
}

- (struct __CFDictionary *)analogPinConfigurationRangesForObjectWithUID:(id)aUID
{
    if (_analogPinConfigurationRangeMappings == NULL || CFDictionaryGetCount(_analogPinConfigurationRangeMappings) == 0)
        return NULL;
    CFDictionaryRef ranges = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
    if (ranges == NULL)
        return NULL;
    return (struct __CFDictionary *)[(id)CFDictionaryCreateCopy(kCFAllocatorDefault, ranges) autorelease];
}

- (struct __CFDictionary *)digitalPinConfigurationRangesForObjectWithUID:(id)aUID
{
    if (_digitalPinConfigurationRangeMappings == NULL || CFDictionaryGetCount(_digitalPinConfigurationRangeMappings) == 0)
        return NULL;
    CFDictionaryRef ranges = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
    if (ranges == NULL)
        return NULL;
    return (struct __CFDictionary *)[(id)CFDictionaryCreateCopy(kCFAllocatorDefault, ranges) autorelease];
}

- (void)removeConfigurationRangeForObjectWithUID:(id)aUID analogPin:(unsigned char)aPin
{
    if (_analogPinConfigurationRangeMappings == NULL)
        return;
    CFDictionaryRef ranges = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
    NSUInteger previous = 0xffffffff;
    if (ranges != NULL && CFDictionaryGetValueIfPresent(ranges, (const void *)(NSUInteger)aPin, (const void **)&previous))
        [self HSArduinoWatcherAction_setConfigurationRange:0xffffffff forObjectWithUID:aUID analogPin:aPin toConfigurationRangeDictionary:(struct __CFDictionary *)ranges withPreviousConfigurationRange:previous];
}

- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin
{
    CFDictionaryRef ranges = NULL;
    NSUInteger previous = 0xffffffff;
    if (_analogPinConfigurationRangeMappings == NULL) {
        _analogPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_analogPinConfigurationRangeMappings == NULL)
            return;
        _digitalPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_digitalPinConfigurationRangeMappings == NULL) {
            CFRelease(_analogPinConfigurationRangeMappings);
            _analogPinConfigurationRangeMappings = NULL;
            return;
        }
    } else {
        ranges = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
        if (ranges != NULL)
            CFDictionaryGetValueIfPresent(ranges, (const void *)(NSUInteger)aPin, (const void **)&previous);
    }
    NSUInteger range = HSArduinoRange(aMode, aValue, aValue2);
    if (range != previous)
        [self HSArduinoWatcherAction_setConfigurationRange:range forObjectWithUID:aUID analogPin:aPin toConfigurationRangeDictionary:(struct __CFDictionary *)ranges withPreviousConfigurationRange:previous];
}

// aDictionary is the object's analog ranges (NULL when it has none yet).
// Removing an object's last range removes the object.
- (void)HSArduinoWatcherAction_setConfigurationRange:(NSUInteger)aRange forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin toConfigurationRangeDictionary:(struct __CFDictionary *)aDictionary withPreviousConfigurationRange:(NSUInteger)aRange2
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aUID, @"objectUID", [NSNumber numberWithUnsignedChar:aPin], @"analogPin", nil];
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Arduino Pin Configuration Ranges" value:@"" table:@"UndoManager"]];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_notifyUndoOrRedoChange:0x200 withUserInfo:userInfo];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_setConfigurationRange:aRange2 forObjectWithUID:aUID analogPin:aPin];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_notifyUndoOrRedoChange:0x100 withUserInfo:userInfo];
    }
    id center = [self attributeNotificationCenter];
    CFIndex count = CFDictionaryGetCount(_analogPinConfigurationRangeMappings);
    Protocol *validation = nil;
    if (aRange == 0xffffffff ? (count == 1 && CFDictionaryGetCount(aDictionary) == 1) : count == 0)
        validation = @protocol(HSActionValidationStatusAttribute);
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute), validation, nil];
    if (attributes != nil)
        [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
    if (aRange == 0xffffffff) {
        CFDictionaryRef digital = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
        if (CFDictionaryGetCount(aDictionary) == 1 && CFDictionaryGetCount(digital) == 0) {
            CFDictionaryRemoveValue(_digitalPinConfigurationRangeMappings, aUID);
            CFDictionaryRemoveValue(_analogPinConfigurationRangeMappings, aUID);
        } else {
            CFDictionaryRemoveValue((CFMutableDictionaryRef)aDictionary, (const void *)(NSUInteger)aPin);
        }
    } else {
        CFMutableDictionaryRef ranges = (CFMutableDictionaryRef)aDictionary;
        if (ranges == NULL) {
            CFMutableDictionaryRef analog = HSArduinoCreateRangesDictionary();
            CFMutableDictionaryRef digital = analog != NULL ? HSArduinoCreateRangesDictionary() : NULL;
            if (digital != NULL) {
                CFDictionarySetValue(_digitalPinConfigurationRangeMappings, aUID, digital);
                CFDictionarySetValue(_analogPinConfigurationRangeMappings, aUID, analog);
                // fixed: the original leaked both new dictionaries
                CFRelease(digital);
                CFRelease(analog);
                ranges = (CFMutableDictionaryRef)CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
            } else if (analog != NULL) {
                CFRelease(analog);
            }
        }
        if (ranges != NULL)
            CFDictionarySetValue(ranges, (const void *)(NSUInteger)aPin, (const void *)aRange);
    }
    if (attributes != nil)
        [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
}

- (void)HSArduinoWatcherAction_setConfigurationRange:(NSUInteger)aRange forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin
{
    CFDictionaryRef ranges = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
    NSUInteger previous = 0xffffffff;
    if (ranges != NULL)
        CFDictionaryGetValueIfPresent(ranges, (const void *)(NSUInteger)aPin, (const void **)&previous);
    [self HSArduinoWatcherAction_setConfigurationRange:aRange forObjectWithUID:aUID analogPin:aPin toConfigurationRangeDictionary:(struct __CFDictionary *)ranges withPreviousConfigurationRange:previous];
}

- (void)removeConfigurationRangeForObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin
{
    if (_digitalPinConfigurationRangeMappings == NULL)
        return;
    CFDictionaryRef ranges = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
    NSUInteger previous = 0xffffffff;
    if (ranges != NULL && CFDictionaryGetValueIfPresent(ranges, (const void *)(NSUInteger)aPin, (const void **)&previous))
        [self HSArduinoWatcherAction_setConfigurationRange:0xffffffff forObjectWithUID:aUID digitalPin:aPin toConfigurationRangeDictionary:(struct __CFDictionary *)ranges withPreviousConfigurationRange:previous];
}

- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin
{
    CFDictionaryRef ranges = NULL;
    NSUInteger previous = 0xffffffff;
    if (_digitalPinConfigurationRangeMappings == NULL) {
        _digitalPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_digitalPinConfigurationRangeMappings == NULL)
            return;
        _analogPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_analogPinConfigurationRangeMappings == NULL) {
            CFRelease(_digitalPinConfigurationRangeMappings);
            _digitalPinConfigurationRangeMappings = NULL;
            return;
        }
    } else {
        ranges = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
        if (ranges != NULL)
            CFDictionaryGetValueIfPresent(ranges, (const void *)(NSUInteger)aPin, (const void **)&previous);
    }
    NSUInteger range = HSArduinoRange(aMode, aValue, aValue2);
    if (range != previous)
        [self HSArduinoWatcherAction_setConfigurationRange:range forObjectWithUID:aUID digitalPin:aPin toConfigurationRangeDictionary:(struct __CFDictionary *)ranges withPreviousConfigurationRange:previous];
}

// aDictionary is the object's digital ranges (NULL when it has none yet).
- (void)HSArduinoWatcherAction_setConfigurationRange:(NSUInteger)aRange forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin toConfigurationRangeDictionary:(struct __CFDictionary *)aDictionary withPreviousConfigurationRange:(NSUInteger)aRange2
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:aUID, @"objectUID", [NSNumber numberWithUnsignedChar:aPin], @"digitalPin", nil];
    NSUndoManager *undoManager = [self undoManager];
    if (undoManager != nil) {
        [undoManager setActionName:[[NSBundle mainBundle] localizedStringForKey:@"Change Arduino Pin Configuration Ranges" value:@"" table:@"UndoManager"]];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_notifyUndoOrRedoChange:0x200 withUserInfo:userInfo];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_setConfigurationRange:aRange2 forObjectWithUID:aUID digitalPin:aPin];
        [(HSArduinoWatcherAction *)[undoManager prepareWithInvocationTarget:self] HSArduinoWatcherAction_notifyUndoOrRedoChange:0x100 withUserInfo:userInfo];
    }
    id center = [self attributeNotificationCenter];
    CFIndex count = CFDictionaryGetCount(_digitalPinConfigurationRangeMappings);
    Protocol *validation = nil;
    if (aRange == 0xffffffff ? (count == 1 && CFDictionaryGetCount(aDictionary) == 1) : count == 0)
        validation = @protocol(HSActionValidationStatusAttribute);
    id attributes = [NSEProtocolSet protocolSetWithProtocols:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute), validation, nil];
    if (attributes != nil)
        [center notifyChange:1 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
    if (aRange == 0xffffffff) {
        CFDictionaryRef analog = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
        if (CFDictionaryGetCount(aDictionary) == 1 && CFDictionaryGetCount(analog) == 0) {
            CFDictionaryRemoveValue(_digitalPinConfigurationRangeMappings, aUID);
            CFDictionaryRemoveValue(_analogPinConfigurationRangeMappings, aUID);
        } else {
            CFDictionaryRemoveValue((CFMutableDictionaryRef)aDictionary, (const void *)(NSUInteger)aPin);
        }
    } else {
        CFMutableDictionaryRef ranges = (CFMutableDictionaryRef)aDictionary;
        if (ranges == NULL) {
            CFMutableDictionaryRef digital = HSArduinoCreateRangesDictionary();
            CFMutableDictionaryRef analog = digital != NULL ? HSArduinoCreateRangesDictionary() : NULL;
            if (analog != NULL) {
                CFDictionarySetValue(_digitalPinConfigurationRangeMappings, aUID, digital);
                CFDictionarySetValue(_analogPinConfigurationRangeMappings, aUID, analog);
                // fixed: the original leaked both new dictionaries
                CFRelease(digital);
                CFRelease(analog);
                ranges = (CFMutableDictionaryRef)CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
            } else if (digital != NULL) {
                CFRelease(digital);
            }
        }
        if (ranges != NULL)
            CFDictionarySetValue(ranges, (const void *)(NSUInteger)aPin, (const void *)aRange);
    }
    if (attributes != nil)
        [center notifyChange:2 ofAttributeSet:attributes ofObject:self withUserInfo:userInfo];
}

- (void)HSArduinoWatcherAction_setConfigurationRange:(NSUInteger)aRange forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin
{
    CFDictionaryRef ranges = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
    NSUInteger previous = 0xffffffff;
    if (ranges != NULL)
        CFDictionaryGetValueIfPresent(ranges, (const void *)(NSUInteger)aPin, (const void **)&previous);
    [self HSArduinoWatcherAction_setConfigurationRange:aRange forObjectWithUID:aUID digitalPin:aPin toConfigurationRangeDictionary:(struct __CFDictionary *)ranges withPreviousConfigurationRange:previous];
}

- (void)HSArduinoWatcherAction_notifyUndoOrRedoChange:(NSInteger)aChange withUserInfo:(id)aInfo
{
    [[self attributeNotificationCenter] notifyChange:aChange ofAttribute:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute) ofObject:self withUserInfo:aInfo];
}

- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forObjectWithUID:(id)aUID analogPin:(unsigned char)aPin
{
    if (_analogPinConfigurationRangeMappings == NULL || CFDictionaryGetCount(_analogPinConfigurationRangeMappings) == 0)
        return NO;
    CFDictionaryRef ranges = CFDictionaryGetValue(_analogPinConfigurationRangeMappings, aUID);
    return ranges != NULL && HSArduinoGetRange(ranges, aPin, aMode, aValue, aValue2);
}

- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forObjectWithUID:(id)aUID digitalPin:(unsigned char)aPin
{
    if (_digitalPinConfigurationRangeMappings == NULL || CFDictionaryGetCount(_digitalPinConfigurationRangeMappings) == 0)
        return NO;
    CFDictionaryRef ranges = CFDictionaryGetValue(_digitalPinConfigurationRangeMappings, aUID);
    return ranges != NULL && HSArduinoGetRange(ranges, aPin, aMode, aValue, aValue2);
}

// Adds aAction's object ranges (except for the replaced objects), widening
// ranges of objects watched by both.
- (void)mergeInArduinoWatcherAction:(id)aAction replacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    CFDictionaryRef digital = [(HSArduinoWatcherAction *)aAction digitalPinConfigurationRangeMappings];
    CFDictionaryRef analog = [(HSArduinoWatcherAction *)aAction analogPinConfigurationRangeMappings];
    if (CFDictionaryGetCount(digital) == 0 || CFDictionaryGetCount(analog) == 0)
        return;
    CFMutableDictionaryRef mergedDigital = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, [self digitalPinConfigurationRangeMappings]);
    CFMutableDictionaryRef mergedAnalog = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, [self analogPinConfigurationRangeMappings]);
    if (mergedDigital != NULL && mergedAnalog != NULL) {
        struct HSArduinoMergeContext digitalContext = { mergedDigital, aDs };
        CFDictionaryApplyFunction(digital, HSArduinoMergeObjectRanges, &digitalContext);
        struct HSArduinoMergeContext analogContext = { mergedAnalog, aDs };
        CFDictionaryApplyFunction(analog, HSArduinoMergeObjectRanges, &analogContext);
        [self setDigitalPinConfigurationRangeMappings:mergedDigital analogPinConfigurationRangeMappings:mergedAnalog];
    }
    // fixed: the original leaked both copies
    if (mergedDigital != NULL)
        CFRelease(mergedDigital);
    if (mergedAnalog != NULL)
        CFRelease(mergedAnalog);
}

// Without the replaced objects; nil when nothing is left.
- (id)copyReplacingObjectUIDs:(id)aDs sortedByPriority:(id)aPriority withImageObjectUID:(id)aUID
{
    HSArduinoWatcherAction *copy = [super copyReplacingObjectUIDs:aDs sortedByPriority:aPriority withImageObjectUID:aUID];
    if (copy == nil)
        return nil;
    for (id uid in aPriority)
        [copy removePinConfigurationRangesForObjectWithUID:[uid stringValue]];
    if (CFDictionaryGetCount([copy digitalPinConfigurationRangeMappings]) == 0 && CFDictionaryGetCount([copy analogPinConfigurationRangeMappings]) == 0) {
        [copy release];
        return nil;
    }
    return copy;
}

- (BOOL)isAbleToStartInInvalidState
{
    return YES;
}

- (BOOL)isValid
{
    if (_digitalPinConfigurationRangeMappings != NULL && CFDictionaryGetCount(_digitalPinConfigurationRangeMappings) > 0)
        return YES;
    return _analogPinConfigurationRangeMappings != NULL && CFDictionaryGetCount(_analogPinConfigurationRangeMappings) > 0;
}

- (void)setAnalogPinConfigurationRangeMappingsAsStringsDictionary:(id)aDictionary
{
    if (_analogPinConfigurationRangeMappings == NULL) {
        _analogPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_analogPinConfigurationRangeMappings == NULL)
            return;
    } else {
        CFDictionaryRemoveAllValues(_analogPinConfigurationRangeMappings);
    }
    CFDictionaryApplyFunction((CFDictionaryRef)aDictionary, HSArduinoSetRangesFromStrings, _analogPinConfigurationRangeMappings);
}

- (void)setDigitalPinConfigurationRangeMappingsAsStringsDictionary:(id)aDictionary
{
    if (_digitalPinConfigurationRangeMappings == NULL) {
        _digitalPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_digitalPinConfigurationRangeMappings == NULL)
            return;
    } else {
        CFDictionaryRemoveAllValues(_digitalPinConfigurationRangeMappings);
    }
    CFDictionaryApplyFunction((CFDictionaryRef)aDictionary, HSArduinoSetRangesFromStrings, _digitalPinConfigurationRangeMappings);
}

// Older documents store both pin kinds in one dictionary per object.
- (void)setPinConfigurationRangeMappingsAsStringsDictionary:(id)aDictionary
{
    if (aDictionary == nil)
        return;
    if (_analogPinConfigurationRangeMappings == NULL) {
        _analogPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_analogPinConfigurationRangeMappings == NULL)
            return;
    } else {
        CFDictionaryRemoveAllValues(_analogPinConfigurationRangeMappings);
    }
    if (_digitalPinConfigurationRangeMappings == NULL) {
        _digitalPinConfigurationRangeMappings = HSArduinoCreateMappingsDictionary();
        if (_digitalPinConfigurationRangeMappings == NULL)
            return;
    } else {
        CFDictionaryRemoveAllValues(_digitalPinConfigurationRangeMappings);
    }
    CFMutableDictionaryRef mappings[2] = { _digitalPinConfigurationRangeMappings, _analogPinConfigurationRangeMappings };
    CFDictionaryApplyFunction((CFDictionaryRef)aDictionary, HSArduinoSetCombinedRangesFromStrings, mappings);
}

- (id)pinConfigurationRangeMappingsAsStringsDictionary
{
    return [NSDictionary dictionary];
}

- (id)analogPinConfigurationRangeMappingsAsStringsDictionary
{
    if (_analogPinConfigurationRangeMappings == NULL)
        return [NSDictionary dictionary];
    NSMutableDictionary *strings = [NSMutableDictionary dictionaryWithCapacity:CFDictionaryGetCount(_analogPinConfigurationRangeMappings)];
    CFDictionaryApplyFunction(_analogPinConfigurationRangeMappings, HSArduinoAddRangeStrings, strings);
    return strings;
}

- (id)digitalPinConfigurationRangeMappingsAsStringsDictionary
{
    if (_digitalPinConfigurationRangeMappings == NULL)
        return [NSDictionary dictionary];
    NSMutableDictionary *strings = [NSMutableDictionary dictionaryWithCapacity:CFDictionaryGetCount(_digitalPinConfigurationRangeMappings)];
    CFDictionaryApplyFunction(_digitalPinConfigurationRangeMappings, HSArduinoAddRangeStrings, strings);
    return strings;
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [[super keysForExtraStoringWithCodingContext:aContext] arrayByAddingObjectsFromArray:
            [NSArray arrayWithObjects:@"digitalPinConfigurationRangeMappingsAsStringsDictionary", @"analogPinConfigurationRangeMappingsAsStringsDictionary", nil]];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [[super keysForExtraLoadingWithCodingContext:aContext] arrayByAddingObject:@"pinConfigurationRangeMappingsAsStringsDictionary"];
}

- (void)dealloc
{
    if (_digitalPinConfigurationRangeMappings != NULL)
        CFRelease(_digitalPinConfigurationRangeMappings);
    if (_analogPinConfigurationRangeMappings != NULL)
        CFRelease(_analogPinConfigurationRangeMappings);
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

// The objects watched during a run, with copies of their ranges. A watcher
// triggers once when all its pins come in range, and again only after going
// out of range.
@implementation __HSArduinoWatchers

- (id)triggeringWatchers
{
    NSUInteger count = [_objects count];
    if (count == 0)
        return [NSSet set];
    NSMutableSet *watchers = [NSMutableSet set];
    for (NSUInteger i = 0; i < count; i++) {
        CFDictionaryRef analog = CFArrayGetValueAtIndex(_analogPinConfigurationRanges, i);
        CFDictionaryRef digital = CFArrayGetValueAtIndex(_digitalPinConfigurationRanges, i);
        if ([self __HSArduinoWatchers_isTriggeringWatcherAtIndex:i withDigitalPinConfigurationRanges:(struct __CFDictionary *)digital analogPinConfigurationRanges:(struct __CFDictionary *)analog])
            [watchers addObject:[_objects objectAtIndex:i]];
    }
    return watchers;
}

- (id)triggeringWatchersForAnalogPin:(unsigned char)aPin
{
    NSUInteger count = [_objects count];
    if (count == 0)
        return [NSSet set];
    NSMutableSet *watchers = [NSMutableSet set];
    for (NSUInteger i = 0; i < count; i++) {
        CFDictionaryRef analog = CFArrayGetValueAtIndex(_analogPinConfigurationRanges, i);
        if (!CFDictionaryContainsKey(analog, (const void *)(NSUInteger)aPin))
            continue;
        CFDictionaryRef digital = CFArrayGetValueAtIndex(_digitalPinConfigurationRanges, i);
        if ([self __HSArduinoWatchers_isTriggeringWatcherAtIndex:i withDigitalPinConfigurationRanges:(struct __CFDictionary *)digital analogPinConfigurationRanges:(struct __CFDictionary *)analog])
            [watchers addObject:[_objects objectAtIndex:i]];
    }
    return watchers;
}

- (id)triggeringWatchersForDigitalPin:(unsigned char)aPin
{
    NSUInteger count = [_objects count];
    if (count == 0)
        return [NSSet set];
    NSMutableSet *watchers = [NSMutableSet set];
    for (NSUInteger i = 0; i < count; i++) {
        CFDictionaryRef digital = CFArrayGetValueAtIndex(_digitalPinConfigurationRanges, i);
        if (!CFDictionaryContainsKey(digital, (const void *)(NSUInteger)aPin))
            continue;
        CFDictionaryRef analog = CFArrayGetValueAtIndex(_analogPinConfigurationRanges, i);
        if ([self __HSArduinoWatchers_isTriggeringWatcherAtIndex:i withDigitalPinConfigurationRanges:(struct __CFDictionary *)digital analogPinConfigurationRanges:(struct __CFDictionary *)analog])
            [watchers addObject:[_objects objectAtIndex:i]];
    }
    return watchers;
}

- (BOOL)__HSArduinoWatchers_isTriggeringWatcherAtIndex:(NSUInteger)aIndex withDigitalPinConfigurationRanges:(struct __CFDictionary *)aRanges analogPinConfigurationRanges:(struct __CFDictionary *)aRanges2
{
    BOOL inRange = YES;
    CFDictionaryApplyFunction(aRanges, HSArduinoCheckDigitalRange, &inRange);
    if (inRange)
        CFDictionaryApplyFunction(aRanges2, HSArduinoCheckAnalogRange, &inRange);
    if (!inRange) {
        [_triggeredObjectInexes removeIndex:aIndex];
        return NO;
    }
    if ([_triggeredObjectInexes containsIndex:aIndex])
        return NO;
    if (_triggeredObjectInexes == nil) {
        _triggeredObjectInexes = [[NSMutableIndexSet alloc] init];
        if (_triggeredObjectInexes == nil)
            return NO;
    }
    [_triggeredObjectInexes addIndex:aIndex];
    return YES;
}

// The object and its two range copies are added together or not at all.
- (void)addWatcher:(id)aWatcher withDigitalPinConfigurationRanges:(struct __CFDictionary *)aRanges analogPinConfigurationRanges:(struct __CFDictionary *)aRanges2
{
    if (_objects == nil) {
        _objects = [[NSMutableArray alloc] init];
        if (_objects == nil)
            return;
    }
    if (_digitalPinConfigurationRanges == NULL) {
        _digitalPinConfigurationRanges = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        if (_digitalPinConfigurationRanges == NULL)
            return;
    }
    if (_analogPinConfigurationRanges == NULL) {
        _analogPinConfigurationRanges = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
        if (_analogPinConfigurationRanges == NULL)
            return;
    }
    CFDictionaryRef digital = CFDictionaryCreateCopy(kCFAllocatorDefault, aRanges);
    if (digital == NULL)
        return;
    CFDictionaryRef analog = CFDictionaryCreateCopy(kCFAllocatorDefault, aRanges2);
    if (analog == NULL) {
        CFRelease(digital);
        return;
    }
    NSUInteger objectsCount = [_objects count];
    [_objects addObject:aWatcher];
    if ([_objects count] == objectsCount) {
        CFRelease(digital);
        CFRelease(analog);
        return;
    }
    CFIndex digitalCount = CFArrayGetCount(_digitalPinConfigurationRanges);
    CFArrayAppendValue(_digitalPinConfigurationRanges, digital);
    CFRelease(digital);
    if (CFArrayGetCount(_digitalPinConfigurationRanges) == digitalCount) {
        [_objects removeObjectAtIndex:objectsCount];
        CFRelease(analog);
        return;
    }
    CFIndex analogCount = CFArrayGetCount(_analogPinConfigurationRanges);
    CFArrayAppendValue(_analogPinConfigurationRanges, analog);
    CFRelease(analog);
    if (CFArrayGetCount(_analogPinConfigurationRanges) == analogCount) {
        [_objects removeObjectAtIndex:objectsCount];
        CFArrayRemoveValueAtIndex(_digitalPinConfigurationRanges, digitalCount);
    }
}

- (void)dealloc
{
    [_triggeredObjectInexes release];
    if (_digitalPinConfigurationRanges != NULL)
        CFRelease(_digitalPinConfigurationRanges);
    if (_analogPinConfigurationRanges != NULL)
        CFRelease(_analogPinConfigurationRanges);
    [_objects release];
    [super dealloc];
}

@end
