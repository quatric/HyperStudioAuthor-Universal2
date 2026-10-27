#import "HSCaptureDeviceList.h"
#import "QTCaptureDevice+QTECaptureDevice.h"
#import "SMKApplicationKitData.h"

// The shared lists, by media types (weakly held: a list leaves when it goes).
static CFMutableDictionaryRef HSCaptureDeviceListsByMediaTypes = NULL;
// How many video lists there are.
static NSUInteger HSCaptureDeviceListVideoListCount = 0;

static void HSCaptureDeviceListStopObservingDevice(const void *aDevice, const void *aIndex, void *aList)
{
    [(id)aDevice removeObserver:(id)aList forKeyPath:@"inUseByAnotherApplication"];
    [(id)aDevice removeObserver:(id)aList forKeyPath:@"suspended"];
}

// The capture devices of some media types, kept up to date as devices come
// and go or change state, with menus listing them (an item per device, its
// represented object).
@implementation HSCaptureDeviceList

+ (id)captureDeviceListForMediaTypes:(id)aTypes
{
    NSArray *types = [[[NSArray alloc] initWithArray:aTypes copyItems:YES] autorelease];
    if (types == nil)
        return nil;
    return [self HSCaptureDeviceList_captureDeviceListForMediaTypes:types];
}

+ (id)captureDeviceListForMediaType:(id)aType
{
    id type = [aType copy];
    if (type == nil)
        return nil;
    NSArray *types = [NSArray arrayWithObject:type];
    [type release];
    if (types == nil)
        return nil;
    return [self HSCaptureDeviceList_captureDeviceListForMediaTypes:types];
}

+ (id)HSCaptureDeviceList_captureDeviceListForMediaTypes:(id)aTypes
{
    if (HSCaptureDeviceListsByMediaTypes == NULL) {
        HSCaptureDeviceListsByMediaTypes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFEWeakObjectPointerDictionaryValueCallBacks);
        if (HSCaptureDeviceListsByMediaTypes == NULL)
            return nil;
    }
    HSCaptureDeviceList *list = [(id)CFDictionaryGetValue(HSCaptureDeviceListsByMediaTypes, aTypes) retain];
    if (list == nil) {
        list = [[self alloc] HSCaptureDeviceList_initWithMediaTypes:aTypes];
        if (list != nil) {
            CFDictionaryAddValue(HSCaptureDeviceListsByMediaTypes, aTypes, list);
            if ([aTypes containsObject:QTMediaTypeVideo])
                HSCaptureDeviceListVideoListCount++;
        }
    }
    return [list autorelease];
}

- (void)detachMenu:(id)aMenu
{
    [_attachedMenus removeObject:aMenu];
}

// A menu attached more than once is filled once.
- (void)attachMenu:(id)aMenu
{
    if (_attachedMenus == nil) {
        _attachedMenus = [[NSCountedSet alloc] init];
        if (_attachedMenus == nil)
            return;
    }
    [_attachedMenus addObject:aMenu];
    if ([_attachedMenus countForObject:aMenu] == 1)
        [self HSCaptureDeviceList_populateAttachedMenu:aMenu];
}

- (id)localizedTitleForCaptureDeviceAtIndex:(NSUInteger)aIndex
{
    id device = [[self HSCaptureDeviceList_captureDeviceList] objectAtIndex:aIndex];
    return [self HSCaptureDeviceList_localizedTitleForCaptureDevice:&device isMetaTitle:NULL];
}

// Device names only (names of devices in use are strings themselves).
- (id)localizedDisplayNameForCaptureDeviceAtIndex:(NSUInteger)aIndex
{
    id device = [[self HSCaptureDeviceList_captureDeviceList] objectAtIndex:aIndex];
    if ([device isKindOfClass:[NSString class]])
        return device;
    if ([device isKindOfClass:[NSNull class]])
        return nil;
    return [device localizedDisplayName];
}

// nil for the entries that aren't devices.
- (id)captureDeviceAtIndex:(NSUInteger)aIndex
{
    id device = [[self HSCaptureDeviceList_captureDeviceList] objectAtIndex:aIndex];
    if ([device isKindOfClass:[NSString class]] || [device isKindOfClass:[NSNull class]])
        return nil;
    return device;
}

- (NSUInteger)captureDeviceCount
{
    return [[self HSCaptureDeviceList_captureDeviceList] count];
}

- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if (![aPath isEqualToString:@"inUseByAnotherApplication"] && ![aPath isEqualToString:@"suspended"])
        return;
    [self performSelectorOnMainThread:@selector(HSCaptureDeviceList_captureDeviceDidChangeState:) withObject:aObject waitUntilDone:NO];
}

// Retitles the device's menu items and posts its index.
- (void)HSCaptureDeviceList_captureDeviceDidChangeState:(id)aState
{
    if (_captureDeviceToIndexMap == NULL)
        return;
    const void *index = NULL;
    if (!CFDictionaryGetValueIfPresent(_captureDeviceToIndexMap, aState, &index))
        return;
    for (id menu in _attachedMenus)
        [self HSCaptureDeviceList_updateItemAtIndex:(NSUInteger)index inAttachedMenu:menu];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:(NSUInteger)index], @"HSCaptureDeviceListUpdatedElementIndexKey", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCaptureDeviceListDidUpdateElementNotification" object:self userInfo:userInfo];
}

- (void)HSCaptureDeviceList_updateItemAtIndex:(NSUInteger)aIndex inAttachedMenu:(id)aMenu
{
    [[(NSMenu *)aMenu itemAtIndex:aIndex] setTitle:[self localizedTitleForCaptureDeviceAtIndex:aIndex]];
}

// One item per entry; the entries that aren't devices are disabled.
- (void)HSCaptureDeviceList_populateAttachedMenu:(id)aMenu
{
    for (NSInteger index = [aMenu numberOfItems] - 1; index >= 0; index--)
        [aMenu removeItemAtIndex:index];
    NSUInteger count = [[self HSCaptureDeviceList_captureDeviceList] count];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    if (count == 0) {
        [[aMenu addItemWithTitle:[bundle localizedStringForKey:@"Not Available" value:@"" table:@"HyperPlayerBase"] action:NULL keyEquivalent:@""] setEnabled:NO];
        return;
    }
    NSString *placeholderName = [bundle localizedStringForKey:@"HSDeviceName" value:@"" table:@"HyperPlayerBase"];
    for (NSUInteger index = 0; index < count; index++) {
        BOOL isMetaTitle = NO;
        id device = [_captureDeviceList objectAtIndex:index];
        NSString *title = [self HSCaptureDeviceList_localizedTitleForCaptureDevice:&device isMetaTitle:&isMetaTitle];
        if (title == nil)
            title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Generic Webcam" value:@"" table:@"HyperPlayerBase"];
        else if ([title isEqualToString:placeholderName])
            // Original quirk kept: a device titled as the placeholder name
            // gets no item (which shifts the later items' indexes).
            continue;
        NSMenuItem *item = [aMenu addItemWithTitle:title action:NULL keyEquivalent:@""];
        if (isMetaTitle)
            [item setEnabled:NO];
        else if (device != nil)
            [item setRepresentedObject:device];
    }
}

// Clears *aDevice for the entries that aren't devices: a device name in use
// elsewhere, or the "all in use" entry (a meta title).
- (id)HSCaptureDeviceList_localizedTitleForCaptureDevice:(id *)aDevice isMetaTitle:(BOOL *)aTitle
{
    NSString *title;
    if ([*aDevice isKindOfClass:[NSString class]]) {
        NSString *inUse = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"In Use" value:@"" table:@"HyperPlayerBase"];
        title = [NSString stringWithFormat:@"%@ (%@)", *aDevice, inUse];
        if (aTitle != NULL)
            *aTitle = NO;
    } else if ([*aDevice isKindOfClass:[NSNull class]]) {
        title = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"All Are In Use" value:@"" table:@"HyperPlayerBase"];
        if (aTitle != NULL)
            *aTitle = YES;
    } else {
        title = [self HSCaptureDeviceList_localizedTitleForCaptureDevice:*aDevice];
        if (aTitle != NULL)
            *aTitle = NO;
        return title;
    }
    *aDevice = nil;
    return title;
}

// The name, with the state of a device that can't be used.
- (id)HSCaptureDeviceList_localizedTitleForCaptureDevice:(id)aDevice
{
    NSString *name = [aDevice localizedDisplayName];
    NSString *state;
    if (![aDevice isConnected]) {
        if (!_showsDisconnectedCaptureDevices)
            return name;
        state = @"Disconnected";
    } else if ([aDevice QTE_isInUseByAnotherApplication])
        state = @"In Use";
    else if ([[aDevice attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue])
        state = @"Off";
    else
        return name;
    state = [[NSBundle bundleForClass:[self class]] localizedStringForKey:state value:@"" table:@"HyperPlayerBase"];
    return [NSString stringWithFormat:@"%@ (%@)", name, state];
}

// A list showing disconnected devices retitles the device; others drop it.
- (void)HSCaptureDeviceList_captureDeviceWasDisconnected:(id)aDisconnected
{
    if (!_showsDisconnectedCaptureDevices) {
        [self HSCaptureDeviceList_invalidateCaptureDeviceList];
        return;
    }
    if (_captureDeviceToIndexMap == NULL)
        return;
    const void *index = NULL;
    if (!CFDictionaryGetValueIfPresent(_captureDeviceToIndexMap, [aDisconnected object], &index))
        return;
    for (id menu in _attachedMenus)
        [self HSCaptureDeviceList_updateItemAtIndex:(NSUInteger)index inAttachedMenu:menu];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:(NSUInteger)index], @"HSCaptureDeviceListUpdatedElementIndexKey", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCaptureDeviceListDidUpdateElementNotification" object:self userInfo:userInfo];
}

- (void)HSCaptureDeviceList_captureDeviceWasConnected:(id)aConnected
{
    [self HSCaptureDeviceList_invalidateCaptureDeviceList];
}

// Made on demand; the devices no longer listed stop being observed.
- (id)HSCaptureDeviceList_captureDeviceList
{
    if (_captureDeviceList != nil)
        return _captureDeviceList;
    _captureDeviceList = [[NSMutableArray alloc] init];
    if (_captureDeviceList == nil)
        return nil;
    CFMutableDictionaryRef observedDevices = _captureDeviceToIndexMap;
    _captureDeviceToIndexMap = NULL;
    NSUInteger count = [_mediaTypes count];
    for (NSUInteger index = 0; index < count; index++)
        [self HSCaptureDeviceList_addCaptureDevicesWithMediaType:[_mediaTypes objectAtIndex:index] withObservedCaptureDevices:observedDevices];
    if (observedDevices != NULL) {
        CFDictionaryApplyFunction(observedDevices, HSCaptureDeviceListStopObservingDevice, self);
        CFRelease(observedDevices);
    }
    return _captureDeviceList;
}

// Adds the (connected) devices of the type not listed yet, observing their
// state; the ones in aDevices are observed already and leave it.
- (void)HSCaptureDeviceList_addCaptureDevicesWithMediaType:(id)aType withObservedCaptureDevices:(struct __CFDictionary *)aDevices
{
    NSArray *devices = [QTCaptureDevice inputDevicesWithMediaType:aType];
    NSUInteger count = [devices count];
    for (NSUInteger index = 0; index < count; index++) {
        QTCaptureDevice *device = [devices objectAtIndex:index];
        if (_captureDeviceToIndexMap != NULL && CFDictionaryGetCountOfKey(_captureDeviceToIndexMap, device) == 1)
            continue;
        if (!_showsDisconnectedCaptureDevices && ![device isConnected])
            continue;
        if (_captureDeviceToIndexMap == NULL) {
            _captureDeviceToIndexMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
            if (_captureDeviceToIndexMap == NULL)
                break;
        }
        if (aDevices == NULL || CFDictionaryGetCountOfKey(aDevices, device) != 1) {
            [device addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:NULL];
            [device addObserver:self forKeyPath:@"suspended" options:0 context:NULL];
        } else
            CFDictionaryRemoveValue(aDevices, device);
        CFDictionaryAddValue(_captureDeviceToIndexMap, device, (const void *)[_captureDeviceList count]);
        [_captureDeviceList addObject:device];
    }
    // The original went on, for video, to list the Sequence Grabber's devices
    // that QTKit didn't show (they were in use elsewhere) by name, ending with
    // an "all in use" entry. There's no Sequence Grabber any more, and
    // AVFoundation shows every device, so there's nothing to add.
}

// The list is made again when next asked for; the menus are refilled.
- (void)HSCaptureDeviceList_invalidateCaptureDeviceList
{
    [_captureDeviceList release];
    _captureDeviceList = nil;
    for (id menu in _attachedMenus)
        [self HSCaptureDeviceList_populateAttachedMenu:menu];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCaptureDeviceListDidUpdateNotification" object:self userInfo:nil];
}

- (void)dealloc
{
    if (_mediaTypes != nil) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        if ([_mediaTypes containsObject:QTMediaTypeVideo] && --HSCaptureDeviceListVideoListCount == 0)
            // The original also closed its Sequence Grabber here.
            [center removeObserver:[super class] name:NSApplicationDidBecomeActiveNotification object:NSApp];
        if (HSCaptureDeviceListsByMediaTypes != NULL)
            CFDictionaryRemoveValue(HSCaptureDeviceListsByMediaTypes, _mediaTypes);
        [center removeObserver:self name:QTCaptureDeviceWasConnectedNotification object:nil];
        [center removeObserver:self name:QTCaptureDeviceWasDisconnectedNotification object:nil];
        [_attachedMenus release];
        if (_captureDeviceToIndexMap != NULL) {
            CFDictionaryApplyFunction(_captureDeviceToIndexMap, HSCaptureDeviceListStopObservingDevice, self);
            CFRelease(_captureDeviceToIndexMap);
        }
        // Fix: the original only released the list along with the map.
        [_captureDeviceList release];
        [_mediaTypes release];
    }
    [super dealloc];
}

// Lists come from captureDeviceListForMediaTypes:.
- (id)init
{
    [self release];
    return nil;
}

- (id)HSCaptureDeviceList_initWithMediaTypes:(id)aTypes
{
    self = [super init];
    if (self == nil)
        return nil;
    _mediaTypes = [aTypes retain];
    if (_mediaTypes == nil) {
        [self release];
        return nil;
    }
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(HSCaptureDeviceList_captureDeviceWasConnected:) name:QTCaptureDeviceWasConnectedNotification object:nil];
    [center addObserver:self selector:@selector(HSCaptureDeviceList_captureDeviceWasDisconnected:) name:QTCaptureDeviceWasDisconnectedNotification object:nil];
    return self;
}

@end
