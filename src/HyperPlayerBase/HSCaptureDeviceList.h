#import "HyperPlayerBasePrefix.h"


@interface HSCaptureDeviceList : NSObject
{
    NSArray *_mediaTypes;
    NSMutableArray *_captureDeviceList;
    struct __CFDictionary *_captureDeviceToIndexMap;
    NSCountedSet *_attachedMenus;
    unsigned int _showsDisconnectedCaptureDevices:1;
}
+ (id)captureDeviceListForMediaTypes:(id)aTypes;
+ (id)captureDeviceListForMediaType:(id)aType;
+ (id)HSCaptureDeviceList_captureDeviceListForMediaTypes:(id)aTypes;
- (void)detachMenu:(id)aMenu;
- (void)attachMenu:(id)aMenu;
- (id)localizedTitleForCaptureDeviceAtIndex:(NSUInteger)aIndex;
- (id)localizedDisplayNameForCaptureDeviceAtIndex:(NSUInteger)aIndex;
- (id)captureDeviceAtIndex:(NSUInteger)aIndex;
- (NSUInteger)captureDeviceCount;
- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext;
- (void)HSCaptureDeviceList_captureDeviceDidChangeState:(id)aState;
- (void)HSCaptureDeviceList_updateItemAtIndex:(NSUInteger)aIndex inAttachedMenu:(id)aMenu;
- (void)HSCaptureDeviceList_populateAttachedMenu:(id)aMenu;
- (id)HSCaptureDeviceList_localizedTitleForCaptureDevice:(id *)aDevice isMetaTitle:(BOOL *)aTitle;
- (id)HSCaptureDeviceList_localizedTitleForCaptureDevice:(id)aDevice;
- (void)HSCaptureDeviceList_captureDeviceWasDisconnected:(id)aDisconnected;
- (void)HSCaptureDeviceList_captureDeviceWasConnected:(id)aConnected;
- (id)HSCaptureDeviceList_captureDeviceList;
- (void)HSCaptureDeviceList_addCaptureDevicesWithMediaType:(id)aType withObservedCaptureDevices:(struct __CFDictionary *)aDevices;
- (void)HSCaptureDeviceList_invalidateCaptureDeviceList;
- (void)dealloc;
- (id)init;
- (id)HSCaptureDeviceList_initWithMediaTypes:(id)aTypes;
@end

