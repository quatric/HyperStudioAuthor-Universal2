#import "HSShowMessageActionAssistantPane.h"

@implementation HSShowMessageActionAssistantPane

/* i386 ivar offsets: _messageStylePopup=0x88, _messageTextView=0x8c, _buttonTitleField=0x90, _modalDialogSwitch=0x94, _messageIconView=0x98, _importGraphicDialogController=0x9c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00119f99 @ 00119f99, 575 bytes * /

id FUN_00119f99(id self,SEL _cmd,NSSize createImageOfSize,id fromImage,BOOL resizeProportionally)

{
  undefined8 uVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  float fVar4;
  id local_38;
  float local_34;
  float fStack_30;
  id local_2c;
  float fStack_28;
  
  if (((fromImage == (id)0x0) || (createImageOfSize.width <= 0.0)) ||
     (createImageOfSize.height <= 0.0)) {
    pvVar3 = (id)0x0;
  }
  else {
    local_34 = *(float *)PTR_00336074;
    fStack_30 = *(float *)(PTR_00336074 + 4);
    uVar1 = *(undefined8 *)PTR_00336074;
    pvVar2 = _objc_msgSend(fromImage,sel_size);
    fStack_28 = extraout_EDX;
    if ((createImageOfSize.width < (float)pvVar2) ||
       (local_2c = pvVar2, createImageOfSize.height < extraout_EDX)) {
      if (resizeProportionally == '\0') {
        local_2c = (id)createImageOfSize.width;
        fStack_28 = createImageOfSize.height;
      }
      else {
        fVar4 = createImageOfSize.width / createImageOfSize.height;
        local_34 = *(float *)PTR_00336078;
        fStack_30 = *(float *)(PTR_00336078 + 4);
        if (fVar4 <= (float)pvVar2 / extraout_EDX) {
          local_38 = (id)(fVar4 * extraout_EDX);
        }
        else {
          fStack_28 = (float)pvVar2 / fVar4;
          local_38 = pvVar2;
        }
        local_34 = (((float)pvVar2 * 0.5 + local_34) - ((float)local_38 * 0.5 + local_34)) +
                   local_34;
        fStack_30 = ((extraout_EDX * 0.5 + fStack_30) - (fStack_28 * 0.5 + fStack_30)) + fStack_30;
        local_2c = local_38;
      }
    }
    pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc);
    pvVar3 = _objc_msgSend(pvVar3,sel_initWithSize_,local_2c,fStack_28);
    _objc_msgSend(pvVar3,sel_lockFocus);
    _objc_msgSend(fromImage,sel_drawInRect_fromRect_operation_fraction_,CONCAT44(fStack_30,local_34)
                  ,CONCAT44(fStack_28,local_2c),uVar1,CONCAT44(extraout_EDX,pvVar2),2,0x3f800000);
    _objc_msgSend(pvVar3,sel_unlockFocus);
  }
  return pvVar3;
}

*/
+ (id)createImageOfSize:(NSSize)aSize fromImage:(id)aImage resizeProportionally:(BOOL)aProportionally
{
    if (aImage == nil || aSize.width <= 0.0f || aSize.height <= 0.0f) {
        return nil;
    }
    NSPoint origin = NSZeroPoint;
    NSSize source = [aImage size];
    NSSize size = source;
    if (aSize.width < source.width || aSize.height < source.height) {
        if (!aProportionally) {
            size = aSize;
        } else {
            float ratio = aSize.width / aSize.height;
            if (ratio <= source.width / source.height) {
                size.width = ratio * source.height;
            } else {
                size.height = source.width / ratio;
            }
            /* original quirk: the centring offset is positive, the full image is drawn shifted into the smaller canvas */
            origin.x = (source.width - size.width) * 0.5f;
            origin.y = (source.height - size.height) * 0.5f;
        }
    }
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [aImage drawInRect:NSMakeRect(origin.x, origin.y, size.width, size.height) fromRect:NSMakeRect(0, 0, source.width, source.height) operation:NSCompositeSourceOver fraction:1.0f];
    [image unlockFocus];
    return image;
}

- (void)controlTextDidChange:(id)aChange
{
    if ([aChange object] == _buttonTitleField) {
        [[self showMessageActionAssistantPaneApplier] setButtonTitle:[_buttonTitleField stringValue]];
    }
}

- (void)messageIconChanged:(id)aChanged
{
    id self_00;

    self_00 = [self showMessageActionAssistantPaneApplier];
    [self_00 setMessageIcon:[_messageIconView image]];
    [self_00 setMessageStyle:4];
}

- (void)modalStateChanged:(id)aChanged
{
    [[self showMessageActionAssistantPaneApplier] setRunAsModalDialog:[_modalDialogSwitch intValue]];
}

- (void)messageTitleChanged:(id)aChanged
{
    [[self showMessageActionAssistantPaneApplier] setButtonTitle:[_buttonTitleField stringValue]];
}

- (void)messageStyleChanged:(id)aChanged
{
    [[self showMessageActionAssistantPaneApplier] setMessageStyle:[[_messageStylePopup selectedItem] tag]];
}

- (void)validateMessageView
{
    HSPlaceholderTextView *self_00;
    NSString *pvVar1_2;

    self_00 = _messageTextView;
    pvVar1_2 = [[self actionAttributes] messageString];
    [self_00 replaceCharactersInRange:NSMakeRange(0, [[_messageTextView textStorage] length]) withString:pvVar1_2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00119b70 @ 00119b70, 377 bytes * /

void FUN_00119b70(HSShowMessageActionAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  uint uVar3;
  
  self_01 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = self->_messageStylePopup;
  pvVar1 = _objc_msgSend(self_01,sel_messageStyle);
  _objc_msgSend(pvVar2,sel_selectItemWithTag_,pvVar1);
  pvVar2 = self->_buttonTitleField;
  pvVar1 = _objc_msgSend(self_01,sel_buttonTitle);
  _objc_msgSend(pvVar2,sel_setStringValue_,pvVar1);
  pvVar2 = self->_modalDialogSwitch;
  pvVar1 = _objc_msgSend(self_01,sel_runAsModalDialog);
  uVar3 = (uint)((char)pvVar1 != '\0');
  _objc_msgSend(pvVar2,sel_setState_,uVar3);
  pvVar2 = _objc_msgSend(self->_messageStylePopup,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_tag);
  if (pvVar2 == (id)0x4) {
    pvVar2 = _objc_msgSend(self_01,sel_messageIcon,uVar3);
    if (pvVar2 != (id)0x0) goto LAB_00119cc2;
  }
  self_00 = cls_HSAlert;
  pvVar2 = _objc_msgSend(self->_messageStylePopup,sel_selectedItem,uVar3);
  pvVar2 = _objc_msgSend(pvVar2,sel_tag);
  pvVar2 = _objc_msgSend(self_00,sel_iconForAlertStyle_,pvVar2);
LAB_00119cc2:
  _objc_msgSend(self->_messageIconView,sel_setImage_,pvVar2);
  return;
}

*/
- (void)validateUI
{
    id attributes = [self actionAttributes];
    [_messageStylePopup selectItemWithTag:[attributes messageStyle]];
    [_buttonTitleField setStringValue:[attributes buttonTitle]];
    [_modalDialogSwitch setState:[attributes runAsModalDialog] ? 1 : 0];
    id icon = nil;
    if ([[_messageStylePopup selectedItem] tag] == 4) {
        icon = [attributes messageIcon];
    }
    if (icon == nil) {
        icon = [HSAlert iconForAlertStyle:[[_messageStylePopup selectedItem] tag]];
    }
    [_messageIconView setImage:icon];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
    if ([[aNotification userInfo] objectForKey:HSValidateMessageString] != nil) {
        [self validateMessageView];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001197c9 @ 001197c9, 820 bytes * /

void FUN_001197c9(HSShowMessageActionAssistantPane *self,SEL _cmd,id chooseMessageIcon)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *extraout_EDX;
  float extraout_EDX_00;
  SEL op;
  cfstringStruct *pcVar5;
  undefined4 uVar6;
  cfstringStruct *pcVar7;
  undefined4 uVar8;
  
  pvVar1 = _objc_msgSend(self,sel_importGraphicDialogController);
  pvVar2 = _objc_msgSend(pvVar1,sel_runModal);
  if (pvVar2 == (id)0x1) {
    pvVar2 = _objc_msgSend(pvVar1,sel_dialogUserOptions);
    uVar6 = *(undefined4 *)PTR_PTR_003360a0;
    pvVar3 = _objc_msgSend(pvVar2,sel_valueForKey_,uVar6);
    pvVar3 = _objc_msgSend(pvVar3,sel_boolValue);
    if ((char)pvVar3 == '\0') {
      pvVar3 = *(id *)PTR_PTR_003360e4;
      pvVar2 = _objc_msgSend(pvVar2,sel_valueForKey_,pvVar3);
      op = sel_retain;
      if (pvVar2 == (id)0x0) {
        pvVar2 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar3);
        pvVar3 = _objc_msgSend(pvVar1,sel_fileName);
        op = sel_initWithContentsOfFile_;
      }
      pvVar1 = _objc_msgSend(pvVar2,op,pvVar3);
    }
    else {
      pvVar1 = _objc_msgSend(cls_HSCaptureImageController,sel_alloc,uVar6);
      pvVar2 = _objc_msgSend(pvVar1,sel_init);
      pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pcVar7 = &cfstr_AssistantPanes;
      pcVar5 = &cfstr_empty;
      pvVar3 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,
                             &cfstr_NBA_ShowMessage_CaptureImageOKButton,&cfstr_empty,
                             &cfstr_AssistantPanes);
      _objc_msgSend(pvVar2,sel_setOKButtonTitle_,pvVar3);
      pvVar1 = _objc_msgSend(pvVar2,sel_runModal);
      if (pvVar1 == (id)0x1) {
        pvVar1 = _objc_msgSend(pvVar2,sel_capturedImage,pvVar3,pcVar5,pcVar7);
        pvVar1 = _objc_msgSend(pvVar1,sel_retain);
        _objc_msgSend(pvVar1,sel_setScalesWhenResized_,1);
        pvVar3 = _objc_msgSend(pvVar2,sel_capturePreviewSize);
        pcVar5 = extraout_EDX;
        _objc_msgSend(pvVar1,sel_setSize_,pvVar3,extraout_EDX);
      }
      else {
        pvVar1 = (id)0x0;
      }
      _objc_msgSend(pvVar2,sel_release,pvVar3,pcVar5,pcVar7);
    }
    pvVar2 = _objc_msgSend(pvVar1,sel_size,pvVar3);
    if ((64.0 < (float)pvVar2) || (_objc_msgSend(pvVar1,sel_size,pvVar3), 64.0 < extraout_EDX_00)) {
      uVar8 = 0;
      uVar6 = 0x42800000;
      pvVar3 = (id)0x42800000;
      pvVar2 = pvVar1;
      pvVar4 = _objc_msgSend(cls_HSShowMessageActionAssistantPane,
                             sel_createImageOfSize_fromImage_resizeProportionally_,0x42800000,
                             0x42800000,pvVar1,0);
      if (pvVar4 != (id)0x0) {
        _objc_msgSend(pvVar1,sel_release,pvVar3,uVar6,pvVar2,uVar8);
        pvVar1 = pvVar4;
      }
    }
    if (pvVar1 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_showMessageActionAssistantPaneApplier,pvVar3);
      _objc_msgSend(pvVar2,sel_setMessageIcon_,pvVar1);
      pvVar2 = _objc_msgSend(self,sel_showMessageActionAssistantPaneApplier);
      pvVar3 = (id)0x4;
      _objc_msgSend(pvVar2,sel_setMessageStyle_,4);
    }
    _objc_msgSend(pvVar1,sel_release,pvVar3);
  }
  return;
}

*/
- (void)chooseMessageIcon:(id)aIcon
{
    id dialog = [self importGraphicDialogController];
    if ([dialog runModal] != 1) {
        return;
    }
    NSDictionary *options = [dialog dialogUserOptions];
    NSImage *image;
    if (![[options valueForKey:HSCaptureImageKey] boolValue]) {
        image = [options valueForKey:HSImportDialogGraphicsOptionKeyCroppedImage];
        if (image == nil) {
            image = [[NSImage alloc] initWithContentsOfFile:[dialog fileName]];
        } else {
            image = [image retain];
        }
    } else {
        HSCaptureImageController *capture = [[HSCaptureImageController alloc] init];
        [capture setOKButtonTitle:[[NSBundle mainBundle] localizedStringForKey:@"NBA_ShowMessage_CaptureImageOKButton" value:@"" table:@"AssistantPanes"]];
        if ([capture runModal] == 1) {
            image = [[capture capturedImage] retain];
            [image setScalesWhenResized:YES];
            [image setSize:[capture capturePreviewSize]];
        } else {
            image = nil;
        }
        [capture release];
    }
    if ([image size].width > 64.0f || [image size].height > 64.0f) {
        NSImage *resized = [HSShowMessageActionAssistantPane createImageOfSize:NSMakeSize(64.0f, 64.0f) fromImage:image resizeProportionally:NO];
        if (resized != nil) {
            [image release];
            image = resized;
        }
    }
    if (image != nil) {
        [[self showMessageActionAssistantPaneApplier] setMessageIcon:image];
        [[self showMessageActionAssistantPaneApplier] setMessageStyle:4];
    }
    [image release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00119605 @ 00119605, 452 bytes * /

id FUN_00119605(HSShowMessageActionAssistantPane *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = self->_importGraphicDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360d8);
    self->_importGraphicDialogController = pvVar1;
    self_00 = cls_NSDictionary;
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,4);
    pvVar2 = _objc_msgSend(self_00,sel_dictionaryWithObject_forKey_,pvVar2,
                           *(undefined4 *)PTR_PTR_00336598);
    _objc_msgSend(pvVar1,sel_setupDialogInterfaceWithOptions_,pvVar2);
    pvVar1 = self->_importGraphicDialogController;
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Choose_Icon___,
                           &cfstr_empty,&cfstr_Dialogs);
    _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
    _objc_msgSend(self->_importGraphicDialogController,sel_setObjectOptionsDisabled_,1);
    pvVar1 = self->_importGraphicDialogController;
    pvVar2 = _objc_msgSend(self,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_document);
    _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
    _objc_msgSend(self->_importGraphicDialogController,sel_setCaptureImageButtonEnabled_,1);
    pvVar1 = self->_importGraphicDialogController;
  }
  return pvVar1;
}

*/
- (id)importGraphicDialogController
{
    if (_importGraphicDialogController == nil) {
        _importGraphicDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeGraphicObject];
        [_importGraphicDialogController setupDialogInterfaceWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:4] forKey:HSImportDialogGraphicsObjectLayout]];
        [_importGraphicDialogController setDefaultButtonTitle:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Choose Icon..." value:@"" table:@"Dialogs"]];
        [_importGraphicDialogController setObjectOptionsDisabled:YES];
        [_importGraphicDialogController setHyperDocument:[[self stack] document]];
        [_importGraphicDialogController setCaptureImageButtonEnabled:YES];
    }
    return _importGraphicDialogController;
}

- (id)initialKeyView
{
    return _messageStylePopup;
}

- (id)helpTopicKey
{
    return @"HSShowMessage";
}

- (void)paneDidOK:(id)aOK
{
    id pvVar2;
    id pvVar1_4;

    pvVar1_4 = [[[[_messageTextView textStorage] string] copy] autorelease];
    pvVar2 = [[self actionAttributes] messageString];
    if (![pvVar1_4 isEqual:pvVar2]) {
        pvVar2 = [self showMessageActionAssistantPaneApplier];
        [pvVar2 setMessageString:pvVar1_4];
    }
    [super paneDidOK:aOK];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011a86c @ 0011a86c, 281 bytes * /

void FUN_0011a86c(HSShowMessageActionAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSShowMessageActionAssistantPane *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  _objc_msgSend(self,sel_removeActionAssistantPaneObserver);
  pvVar2 = _objc_msgSend(self->_messageTextView,sel_textStorage);
  pvVar2 = _objc_msgSend(pvVar2,sel_string);
  pvVar2 = _objc_msgSend(pvVar2,sel_copy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  if ((self->super).super.super._userMadeTheDecision == '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_messageString);
    pvVar3 = _objc_msgSend(pvVar2,sel_isEqual_,pvVar1);
    if ((char)pvVar3 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_showMessageActionAssistantPaneApplier,pvVar1);
      _objc_msgSend(pvVar1,sel_setMessageString_,pvVar2);
    }
  }
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00351050;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    id attributes = [self actionAttributes];
    [self removeActionAssistantPaneObserver];
    NSString *message = [[[[_messageTextView textStorage] string] copy] autorelease];
    if (!_userMadeTheDecision) {
        if (![message isEqual:[attributes messageString]]) {
            [[self showMessageActionAssistantPaneApplier] setMessageString:message];
        }
    }
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011a985 @ 0011a985, 299 bytes * /

void FUN_0011a985(HSShowMessageActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  undefined *self_00;
  id pvVar2;
  SEL op;
  HSShowMessageActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00351050;
  pvVar2 = (id)(int)viewWillAppear;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,pvVar2);
  _objc_msgSend(self,sel_addActionAssistantPaneObserver);
  _objc_msgSend(self,sel_validateUI);
  _objc_msgSend(self,sel_validateMessageView);
  pvVar1 = _objc_msgSend(self->_messageStylePopup,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_tag);
  self_00 = cls_HSAlert;
  if (pvVar1 == (id)0x4) {
    self_00 = _objc_msgSend(self,sel_actionAttributes);
    op = sel_messageIcon;
  }
  else {
    pvVar1 = _objc_msgSend(self->_messageStylePopup,sel_selectedItem);
    pvVar2 = _objc_msgSend(pvVar1,sel_tag);
    op = sel_iconForAlertStyle_;
  }
  pvVar1 = _objc_msgSend(self_00,op,pvVar2);
  _objc_msgSend(self->_messageIconView,sel_setImage_,pvVar1);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self validateUI];
    [self validateMessageView];
    id icon;
    if ([[_messageStylePopup selectedItem] tag] == 4) {
        icon = [[self actionAttributes] messageIcon];
    } else {
        icon = [HSAlert iconForAlertStyle:[[_messageStylePopup selectedItem] tag]];
    }
    [_messageIconView setImage:icon];
}

- (id)actionAttribute
{
    return (id)@protocol(HSShowMessageActionAttributes);
}

- (id)actionType
{
    return [HSShowMessageAction actionType];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_messageTextView setPlaceholderString:[[NSBundle mainBundle] localizedStringForKey:@"NBA_ShowMessage_Placeholder" value:@"" table:@"AssistantPanes"]];
    [_messageTextView setRichText:NO];
    [_messageTextView setUsesFontPanel:NO];
}

- (id)actionAttributes
{
    return [[self showMessageActionAssistantPaneApplier] showMessageActionAttributes];
}

- (id)showMessageActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSShowMessageActionAssistantPaneApplier class];
}

- (void)dealloc
{
    [_importGraphicDialogController release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ShowMessageAssistantPane"];
    return self;
}

@end

@implementation HSShowMessageActionAssistantPaneApplier

/* i386 ivar offsets: _initialMessageString=0x30, _initialButtonTitle=0x34, _initialMessageStyle=0x38, _initialRunAsModalDialog=0x3c, _initialMessageIcon=0x40, _messageString=0x44, _buttonTitle=0x48, _messageStyle=0x4c, _runAsModalDialog=0x50, _messageIcon=0x54 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011a28f @ 0011a28f, 236 bytes * /

BOOL FUN_0011a28f(HSShowMessageActionAssistantPaneApplier *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  bool bVar3;
  HSShowMessageActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00351020;
  pvVar2 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  cVar1 = (char)pvVar2;
  if ((self->_initialMessageString != (id)0x0) || (self->_messageString != (id)0x0)) {
    if ((cVar1 == '\0') ||
       (pvVar2 = _objc_msgSend(self->_initialMessageString,sel_isEqualToString_,self->_messageString
                              ), (char)pvVar2 == '\0')) {
      cVar1 = '\0';
    }
    else {
      cVar1 = '\x01';
    }
  }
  if ((self->_initialButtonTitle == (id)0x0) && (self->_buttonTitle == (id)0x0)) {
LAB_0011a31f:
    if (((cVar1 != '\0') && (self->_initialMessageStyle == self->_messageStyle)) &&
       (self->_initialRunAsModalDialog == self->_runAsModalDialog)) {
      bVar3 = true;
      goto LAB_0011a339;
    }
  }
  else if (cVar1 != '\0') {
    pvVar2 = _objc_msgSend(self->_initialButtonTitle,sel_isEqualToString_,self->_buttonTitle);
    cVar1 = (char)pvVar2;
    goto LAB_0011a31f;
  }
  bVar3 = false;
LAB_0011a339:
  if ((self->_initialMessageIcon != (id)0x0) || (self->_messageIcon != (id)0x0)) {
    if (bVar3 == false) {
      bVar3 = false;
    }
    else {
      pvVar2 = _objc_msgSend(self->_initialMessageIcon,sel_isEqual_,self->_messageIcon);
      bVar3 = (char)pvVar2 != '\0';
    }
  }
  return bVar3;
}

*/
- (BOOL)areSettingsEqual
{
    BOOL equal = [super areSettingsEqual];
    if (_initialMessageString != nil || _messageString != nil) {
        equal = equal && [_initialMessageString isEqualToString:_messageString];
    }
    if (_initialButtonTitle != nil || _buttonTitle != nil) {
        equal = equal && [_initialButtonTitle isEqualToString:_buttonTitle];
    }
    equal = equal && _initialMessageStyle == _messageStyle && _initialRunAsModalDialog == _runAsModalDialog;
    if (_initialMessageIcon != nil || _messageIcon != nil) {
        equal = equal && [_initialMessageIcon isEqual:_messageIcon];
    }
    return equal;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_messageString release];
    [_buttonTitle release];
    [_messageIcon release];
    _messageString = [_initialMessageString retain];
    _buttonTitle = [_initialButtonTitle retain];
    _messageIcon = [_initialMessageIcon retain];
    _messageStyle = _initialMessageStyle;
    _runAsModalDialog = _initialRunAsModalDialog;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialMessageString release];
    [_initialButtonTitle release];
    [_initialMessageIcon release];
    _initialMessageString = [_messageString retain];
    _initialButtonTitle = [_buttonTitle retain];
    _initialMessageIcon = [_messageIcon retain];
    _initialMessageStyle = _messageStyle;
    _initialRunAsModalDialog = _runAsModalDialog;
}

- (void)setInitialSettingsToObject
{
    [[self showMessageActionAttributes] setMessageString:_initialMessageString];
    [[self showMessageActionAttributes] setMessageStyle:_initialMessageStyle];
    [[self showMessageActionAttributes] setRunAsModalDialog:_initialRunAsModalDialog];
    [[self showMessageActionAttributes] setButtonTitle:_initialButtonTitle];
    [[self showMessageActionAttributes] setMessageIcon:_initialMessageIcon];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self showMessageActionAttributes] setMessageString:_messageString];
    [[self showMessageActionAttributes] setMessageStyle:_messageStyle];
    [[self showMessageActionAttributes] setRunAsModalDialog:_runAsModalDialog];
    [[self showMessageActionAttributes] setButtonTitle:_buttonTitle];
    [[self showMessageActionAttributes] setMessageIcon:_messageIcon];
}

- (void)setMessageIcon:(id)aIcon
{
    if (_messageIcon != aIcon) {
        [_messageIcon release];
        _messageIcon = [aIcon retain];
        [self disableUndo];
        [[self showMessageActionAttributes] setMessageIcon:_messageIcon];
        [self enableUndo];
    }
}

- (void)setRunAsModalDialog:(BOOL)aDialog
{
    if (_runAsModalDialog != aDialog) {
        _runAsModalDialog = aDialog;
        [self disableUndo];
        [[self showMessageActionAttributes] setRunAsModalDialog:_runAsModalDialog];
        [self enableUndo];
    }
}

- (void)setMessageStyle:(NSInteger)aStyle
{
    if (_messageStyle != aStyle) {
        _messageStyle = aStyle;
        [self disableUndo];
        [[self showMessageActionAttributes] setMessageStyle:_messageStyle];
        [self enableUndo];
    }
}

- (void)setButtonTitle:(id)aTitle
{
    if (![_buttonTitle isEqualToString:aTitle]) {
        [_buttonTitle release];
        _buttonTitle = [aTitle retain];
        [self disableUndo];
        [[self showMessageActionAttributes] setButtonTitle:_buttonTitle];
        [self enableUndo];
    }
}

- (void)setMessageString:(id)aString
{
    if (![_messageString isEqualToString:aString]) {
        [_messageString release];
        _messageString = [aString retain];
        [self disableUndo];
        [[self showMessageActionAttributes] setMessageString:_messageString];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    id pvVar1_3;
    id pvVar1_7;
    id pvVar1_11;
    NSInteger pvVar1_14;
    BOOL pvVar1_16;

    pvVar1_3 = [[[self showMessageActionAttributes] messageString] retain];
    _messageString = pvVar1_3;
    _initialMessageString = [pvVar1_3 retain];
    pvVar1_7 = [[[self showMessageActionAttributes] buttonTitle] retain];
    _buttonTitle = pvVar1_7;
    _initialButtonTitle = [pvVar1_7 retain];
    pvVar1_11 = [[[self showMessageActionAttributes] messageIcon] retain];
    _messageIcon = pvVar1_11;
    _initialMessageIcon = [pvVar1_11 retain];
    pvVar1_14 = [[self showMessageActionAttributes] messageStyle];
    _initialMessageStyle = (int)pvVar1_14;
    _messageStyle = (int)pvVar1_14;
    pvVar1_16 = [[self showMessageActionAttributes] runAsModalDialog];
    _initialRunAsModalDialog = (BOOL)pvVar1_16;
    _runAsModalDialog = (BOOL)pvVar1_16;
}

- (id)showMessageActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSShowMessageActionAttributes)];
}

- (void)dealloc
{
    [_initialMessageString release];
    [_initialButtonTitle release];
    [_initialMessageIcon release];
    [_messageString release];
    [_buttonTitle release];
    [_messageIcon release];
    [super dealloc];
}

@end

