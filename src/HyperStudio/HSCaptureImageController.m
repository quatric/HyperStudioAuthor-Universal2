#import "HSCaptureImageController.h"

@implementation HSCaptureImageController

/* i386 ivar offsets: _captureSession=0x24, _capturedImage=0x28, _captureButton=0x2c, _captureView=0x30, _imageView=0x34, _capturedImageView=0x38, _videoCaptureDevicesPopUp=0x3c, _OKButton=0x40, _videoDevice=0x44, _videoCaptureDeviceList=0x48 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00242e05 @ 00242e05, 184 bytes * /

void FUN_00242e05(HSCaptureImageController *self,SEL _cmd,id ok)

{
  id pvVar1;
  id self_00;
  HSCaptureImageController *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_uniqueID);
  self_00 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  _objc_msgSend(self_00,sel_setObject_forKey_,pvVar1,*(undefined4 *)PTR_00336618);
  local_14 = self;
  local_10 = PTR_s_HSGenericModalController_003558e0;
  _objc_msgSendSuper(&local_14,sel_ok_,ok);
  return;
}

*/
- (void)ok:(id)aOk
{
    NSString *uniqueID = [[[_videoCaptureDevicesPopUp selectedItem] representedObject] uniqueID];
    [[NSUserDefaults standardUserDefaults] setObject:uniqueID forKey:HSVideoDeviceUniqueIDKey];
    [super ok:aOk];
}

- (void)videoDeviceDidChange:(id)aChange
{
    id pvVar1_2;

    pvVar1_2 = [[_videoCaptureDevicesPopUp selectedItem] representedObject];
    [self setVideoDevice:pvVar1_2];
    [self changePreviewingVideoDeviceTo:pvVar1_2];
}

- (void)captureDeviceSession:(id)aSession didReceiveFrame:(id)aFrame fromFrameProcessorOfClass:(Class)aClass
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00242ebd @ 00242ebd, 57 bytes * /

ulonglong FUN_00242ebd(HSCaptureImageController *self,SEL _cmd)

{
  undefined1 local_14 [8];
  ulonglong local_c;
  
  _objc_msgSend_stret(local_14,self->_captureView,sel_frame);
  return local_c;
}

*/
- (NSSize)capturePreviewSize
{
    return [_captureView frame].size;
}

- (id)capturedImage
{
    return _capturedImage;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00242ba2 @ 00242ba2, 354 bytes * /

void FUN_00242ba2(HSCaptureImageController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar1 = _objc_msgSend(cls_HSQuartzVideoFrameProcessor,sel_class);
  pvVar4 = pvVar1;
  _objc_msgSend(self->_captureSession,sel_activateForClient_withFrameProcessorClass_,self,pvVar1);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(self->_captureSession,sel_frameForFrameProcessorClass_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_frameRepresentation);
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(self->_capturedImage,sel_release,pvVar3,pvVar4);
    pvVar3 = _objc_msgSend(cls_NSImage,sel_hyperImageWithCGImage_,pvVar2);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_capturedImage = pvVar3;
  }
  _objc_msgSend(self->_captureSession,sel_deactivateForClient_withFrameProcessorClass_,self,pvVar1);
  _objc_msgSend(self,sel_stopPreviewingAndDisableScreenUpdates_,1);
  pvVar3 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar3,sel_disableScreenUpdatesUntilFlush);
  _objc_msgSend(self->_capturedImageView,sel_setImage_,self->_capturedImage);
  _objc_msgSend(self->_captureButton,sel_setFocusRingType_,0);
  return;
}

*/
- (void)prepareCaptureSession
{
    Class processorClass = [HSQuartzVideoFrameProcessor class];
    [_captureSession activateForClient:self withFrameProcessorClass:processorClass];
    id frame = [_captureSession frameForFrameProcessorClass:processorClass];
    id representation = [frame frameRepresentation];
    if (representation != nil) {
        [_capturedImage release];
        _capturedImage = [[NSImage hyperImageWithCGImage:(CGImageRef)representation] retain];
    }
    [_captureSession deactivateForClient:self withFrameProcessorClass:processorClass];
    [self stopPreviewingAndDisableScreenUpdates:YES];
    [[self window] disableScreenUpdatesUntilFlush];
    [_capturedImageView setImage:_capturedImage];
    [_captureButton setFocusRingType:NSFocusRingTypeDefault];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00242b21 @ 00242b21, 129 bytes * /

void FUN_00242b21(HSCaptureImageController *self,SEL _cmd,id capture)

{
  id pvVar1;
  HSCaptureImageController *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_capturedImageView,sel_isHidden);
  self_00 = self;
  op = sel_prepareForCapturing;
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_prepareCaptureSession);
    self_00 = self->_captureButton;
    op = sel_setFocusRingType_;
  }
  _objc_msgSend(self_00,op);
  _objc_msgSend(self,sel_validateUI);
  return;
}

*/
- (void)capture:(id)aCapture
{
    if ([_capturedImageView isHidden]) {
        [self prepareCaptureSession];
        [_captureButton setFocusRingType:NSFocusRingTypeNone];
    } else {
        [self prepareForCapturing];
    }
    [self validateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00242acb @ 00242acb, 86 bytes * /

void FUN_00242acb(HSCaptureImageController *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  op = sel_startPreviewing;
  if ((self->_captureSession != (id)0x0) ||
     (pvVar1 = _objc_msgSend(self,sel_videoDevice), op = sel_changePreviewingVideoDeviceTo_,
     pvVar1 != (id)0x0)) {
    _objc_msgSend(self,op);
  }
  return;
}

*/
- (void)prepareForCapturing
{
    if (_captureSession != nil) {
        [self startPreviewing];
    } else if ([self videoDevice] != nil) {
        [self changePreviewingVideoDeviceTo:[self videoDevice]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00242947 @ 00242947, 388 bytes * /

void FUN_00242947(HSCaptureImageController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  SEL op;
  
  if (self->_videoDevice != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_isInputDeviceValid_,self->_videoDevice);
    if ((char)pvVar1 != '\0') {
      cVar3 = '\x01';
      goto LAB_00242983;
    }
  }
  cVar3 = '\0';
LAB_00242983:
  pvVar1 = _objc_msgSend(self->_captureSession,sel_captureSession);
  pvVar1 = _objc_msgSend(pvVar1,sel_isRunning);
  _objc_msgSend(self->_captureButton,sel_setEnabled_,(uint)((char)pvVar1 != '\0' && cVar3 != '\0'));
  _objc_msgSend(*(id *)(self->super_HSGenericModalController + 0x20),sel_setEnabled_,
                (uint)(self->_capturedImage != (id)0x0));
  _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_setEnabled_,(int)cVar3);
  pvVar2 = _objc_msgSend(self,sel_isPreviewing);
  pvVar1 = self->_captureButton;
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Preview);
    _objc_msgSend(pvVar1,sel_setImage_,pvVar2);
    pvVar1 = self->_captureButton;
    pvVar2 = (id)0x1;
    op = sel_setEnabled_;
  }
  else {
    pvVar2 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Capture);
    op = sel_setImage_;
  }
  _objc_msgSend(pvVar1,op,pvVar2);
  return;
}

*/
- (void)validateUI
{
    BOOL valid = _videoDevice != nil && [self isInputDeviceValid:_videoDevice];
    [_captureButton setEnabled:[[_captureSession captureSession] isRunning] && valid];
    [_defaultButton setEnabled:_capturedImage != nil];
    [_videoCaptureDevicesPopUp setEnabled:valid];
    if ([self isPreviewing]) {
        [_captureButton setImage:[NSImage imageNamed:@"Capture"]];
    } else {
        [_captureButton setImage:[NSImage imageNamed:@"Preview"]];
        [_captureButton setEnabled:YES];
    }
}

- (void)stopPreviewingAndDisableScreenUpdates:(BOOL)aUpdates
{
    if (aUpdates != NO) {
        [[self window] disableScreenUpdatesUntilFlush];
    }
    [_captureView setHidden:YES];
    [_capturedImageView setHidden:NO];
    [_captureView stopPreviewing];
    [self validateUI];
}

- (void)startPreviewing
{
    if (_videoDevice != nil) {
        [_captureView setHidden:NO];
        [_capturedImageView setHidden:YES];
        [_captureView startPreviewing];
        [self validateUI];
    }
}

- (void)deviceStateDidChange
{
    [self validateUI];
}

- (void)sessionErrorDidReceive:(id)aReceive
{
    [self performSelectorOnMainThread:@selector(deviceStateDidChange) withObject:nil waitUntilDone:NO];
}

- (void)observeValueForKeyPath:(id)aPath ofObject:(id)aObject change:(id)aChange context:(void *)aContext
{
    if ([[self deviceValidationKeys] containsObject:aPath]) {
        [self performSelectorOnMainThread:@selector(deviceStateDidChange) withObject:nil waitUntilDone:NO];
    }
}

- (id)deviceValidationKeys
{
    return [NSSet setWithObjects:@"inUseByAnotherApplication", @"connected", @"suspended", nil];
}

- (id)videoCaptureDeviceList
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _videoCaptureDeviceList;
    if (pvVar1 == nil) {
        pvVar1_3 = [[NSArray alloc] initWithObjects:QTMediaTypeVideo, QTMediaTypeMuxed, nil];
        _videoCaptureDeviceList = [[HSCaptureDeviceList captureDeviceListForMediaTypes:pvVar1_3] retain];
        [pvVar1_3 release];
        pvVar1 = _videoCaptureDeviceList;
    }
    return pvVar1;
}

- (void)changePreviewingVideoDeviceTo:(id)aTo
{
    id pvVar1;
    id pvVar2_3;

    pvVar1 = [_captureSession captureDeviceSet];
    if (![pvVar1 containsObject:aTo]) {
        if (_captureSession != nil) {
            [_captureView stopPreviewing];
            [_captureView setCaptureDeviceSession:nil];
            [_captureSession release];
            _captureSession = nil;
        }
        pvVar2_3 = [[HSCaptureDeviceSession captureDeviceSessionForDevice:aTo] retain];
        _captureSession = pvVar2_3;
        if (pvVar2_3 != nil) {
            [_captureView setCaptureDeviceSession:pvVar2_3];
            [self startPreviewing];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002423a4 @ 002423a4, 412 bytes * /

void FUN_002423a4(HSCaptureImageController *self,SEL _cmd,id setVideoDevice)

{
  id pvVar1;
  HSCaptureImageController *pHVar2;
  
  pvVar1 = _objc_msgSend(self->_videoDevice,sel_uniqueID);
  pHVar2 = _objc_msgSend(setVideoDevice,sel_uniqueID);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,pHVar2);
  if ((char)pvVar1 == '\0') {
    pvVar1 = (id)0x0;
    if (self->_videoDevice != (id)0x0) {
      _objc_msgSend(self->_videoDevice,sel_removeObserver_forKeyPath_,self,
                    &cfstr_inUseByAnotherApplication);
      _objc_msgSend(self->_videoDevice,sel_removeObserver_forKeyPath_,self,&cfstr_suspended);
      pHVar2 = self;
      _objc_msgSend(self->_videoDevice,sel_removeObserver_forKeyPath_,self,&cfstr_connected);
      pvVar1 = self->_videoDevice;
    }
    _objc_msgSend(pvVar1,sel_release,pHVar2);
    pvVar1 = _objc_msgSend(setVideoDevice,sel_retain);
    self->_videoDevice = pvVar1;
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(pvVar1,sel_addObserver_forKeyPath_options_context_,self,
                    &cfstr_inUseByAnotherApplication,0,0);
      _objc_msgSend(self->_videoDevice,sel_addObserver_forKeyPath_options_context_,self,
                    &cfstr_suspended,0,0);
      _objc_msgSend(self->_videoDevice,sel_addObserver_forKeyPath_options_context_,self,
                    &cfstr_connected,0,0);
    }
  }
  return;
}

*/
- (void)setVideoDevice:(id)aDevice
{
    if (![[_videoDevice uniqueID] isEqual:[aDevice uniqueID]]) {
        if (_videoDevice != nil) {
            [_videoDevice removeObserver:self forKeyPath:@"inUseByAnotherApplication"];
            [_videoDevice removeObserver:self forKeyPath:@"suspended"];
            [_videoDevice removeObserver:self forKeyPath:@"connected"];
        }
        [_videoDevice release];
        _videoDevice = [aDevice retain];
        if (_videoDevice != nil) {
            [_videoDevice addObserver:self forKeyPath:@"inUseByAnotherApplication" options:0 context:NULL];
            [_videoDevice addObserver:self forKeyPath:@"suspended" options:0 context:NULL];
            [_videoDevice addObserver:self forKeyPath:@"connected" options:0 context:NULL];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024227c @ 0024227c, 296 bytes * /

id FUN_0024227c(HSCaptureImageController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  
  if (self->_videoDevice == (id)0x0) {
    pvVar5 = *(id *)PTR_0033615c;
    pvVar1 = _objc_msgSend(cls_QTCaptureDevice,sel_defaultInputDeviceWithMediaType_,pvVar5);
    pvVar2 = _objc_msgSend(self,sel_isInputDeviceValid_,pvVar1);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(cls_QTCaptureDevice,sel_inputDevicesWithMediaType_,pvVar5);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
      if (pvVar2 == (id)0x0) goto LAB_00242396;
      do {
        pvVar3 = _objc_msgSend(pvVar2,sel_nextObject,pvVar5);
        if (pvVar3 == (id)0x0) goto LAB_00242391;
        pvVar5 = pvVar3;
        pvVar4 = _objc_msgSend(self,sel_isInputDeviceValid_,pvVar3);
      } while ((char)pvVar4 == '\0');
      _objc_msgSend(self,sel_setVideoDevice_,pvVar3);
    }
LAB_00242391:
    _objc_msgSend(self,sel_setVideoDevice_,pvVar1);
  }
LAB_00242396:
  return self->_videoDevice;
}

*/
- (id)videoDevice
{
    if (_videoDevice == nil) {
        QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
        if (![self isInputDeviceValid:device]) {
            NSEnumerator *enumerator = [[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo] objectEnumerator];
            QTCaptureDevice *candidate;
            while ((candidate = [enumerator nextObject]) != nil) {
                if ([self isInputDeviceValid:candidate]) {
                    device = candidate;
                    break;
                }
            }
        }
        [self setVideoDevice:device];
    }
    return _videoDevice;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002421fc @ 002421fc, 128 bytes * /

BOOL FUN_002421fc(HSCaptureImageController *self,SEL _cmd,id isInputDeviceValid)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(isInputDeviceValid,sel_isConnected);
  if (((char)pvVar1 != '\0') &&
     (pvVar1 = _objc_msgSend(isInputDeviceValid,sel_QTE_isInUseByAnotherApplication),
     (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(isInputDeviceValid,sel_attributeForKey_,*(undefined4 *)PTR_00336400);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    return (char)pvVar1 == '\0';
  }
  return '\0';
}

*/
- (BOOL)isInputDeviceValid:(id)aValid
{
    return [aValid isConnected] && ![aValid QTE_isInUseByAnotherApplication] && ![[aValid attributeForKey:QTCaptureDeviceSuspendedAttribute] boolValue];
}

- (BOOL)isPreviewing
{
    return (BOOL)[_capturedImageView isHidden];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002420c8 @ 002420c8, 264 bytes * /

void FUN_002420c8(HSCaptureImageController *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  
  uVar5 = *(undefined4 *)PTR_0033615c;
  self_00 = _objc_msgSend(cls_QTCaptureDevice,sel_defaultInputDeviceWithMediaType_,uVar5);
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_videoCaptureDeviceList,sel_captureDeviceCount,uVar5);
    for (pvVar4 = (id)0x0; pvVar4 < pvVar1; pvVar4 = (id)((int)pvVar4 + 1)) {
      pvVar2 = _objc_msgSend(self->_videoCaptureDeviceList,sel_captureDeviceAtIndex_,pvVar4);
      pvVar2 = _objc_msgSend(pvVar2,sel_uniqueID);
      pvVar3 = _objc_msgSend(self_00,sel_uniqueID);
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,pvVar3);
      if ((char)pvVar2 != '\0') {
        _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_selectItemAtIndex_,pvVar4);
        _objc_msgSend(self,sel_setVideoDevice_,self_00);
        return;
      }
    }
  }
  return;
}

*/
- (void)selectDefaultVideoDevice
{
    QTCaptureDevice *defaultDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    if (defaultDevice != nil) {
        NSUInteger count = [_videoCaptureDeviceList captureDeviceCount];
        for (NSUInteger i = 0; i < count; i++) {
            if ([[[_videoCaptureDeviceList captureDeviceAtIndex:i] uniqueID] isEqualToString:[defaultDevice uniqueID]]) {
                [_videoCaptureDevicesPopUp selectItemAtIndex:i];
                [self setVideoDevice:defaultDevice];
                return;
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00241f9f @ 00241f9f, 297 bytes * /

BOOL FUN_00241f9f(HSCaptureImageController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar5 = *(undefined4 *)PTR_00336618;
  pvVar1 = _objc_msgSend(pvVar1,sel_stringForKey_,uVar5);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_videoCaptureDeviceList,sel_captureDeviceCount,uVar5);
    for (pvVar4 = (id)0x0; pvVar4 < pvVar2; pvVar4 = (id)((int)pvVar4 + 1)) {
      pvVar3 = _objc_msgSend(self->_videoCaptureDeviceList,sel_captureDeviceAtIndex_,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_uniqueID);
      pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,pvVar1);
      if ((char)pvVar3 != '\0') {
        _objc_msgSend(self->_videoCaptureDevicesPopUp,sel_selectItemAtIndex_,pvVar4);
        pvVar1 = _objc_msgSend(cls_QTCaptureDevice,sel_deviceWithUniqueID_,pvVar1);
        _objc_msgSend(self,sel_setVideoDevice_,pvVar1);
        return '\x01';
      }
    }
  }
  return '\0';
}

*/
- (BOOL)selectVideoDeviceFromUserDefaults
{
    NSString *uniqueID = [[NSUserDefaults standardUserDefaults] stringForKey:HSVideoDeviceUniqueIDKey];
    if (uniqueID != nil) {
        NSUInteger count = [_videoCaptureDeviceList captureDeviceCount];
        for (NSUInteger i = 0; i < count; i++) {
            if ([[[_videoCaptureDeviceList captureDeviceAtIndex:i] uniqueID] isEqualToString:uniqueID]) {
                [_videoCaptureDevicesPopUp selectItemAtIndex:i];
                [self setVideoDevice:[QTCaptureDevice deviceWithUniqueID:uniqueID]];
                return YES;
            }
        }
    }
    return NO;
}

- (void)setOKButtonTitle:(id)aTitle
{
    [self window];
    [_OKButton setTitle:aTitle];
}

- (void)willCloseWindow
{
    [self stopPreviewingAndDisableScreenUpdates:NO];
    [_videoCaptureDeviceList detachMenu:[_videoCaptureDevicesPopUp menu]];
}

- (void)willShowWindow
{
    if (![self selectVideoDeviceFromUserDefaults]) {
        [self selectDefaultVideoDevice];
    }
    [self prepareForCapturing];
    [self validateUI];
}

- (void)didLoadNib
{
    [super didLoadNib];
    [_captureView enableOpenGLSurface];
    [_imageView setImage:[[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"Countdown" ofType:@"pdf"]] autorelease]];
    [[self videoCaptureDeviceList] attachMenu:[_videoCaptureDevicesPopUp menu]];
}

- (id)nibName
{
    return @"CaptureImagePanel";
}

- (void)dealloc
{
    [self setVideoDevice:nil];
    [_captureSession release];
    [_capturedImage release];
    [_videoCaptureDeviceList release];
    [super dealloc];
}

@end

