#import "HSArduinoWatcherActionAssistantPane.h"

@implementation HSArduinoWatcherActionAssistantPane

/* i386 ivar offsets: _currentCardObjectsCheckBox=0x88, _pinConfigurationRangeMappingsOutlineView=0x8c, _objectNameParagraphStyle=0x90, _pinConfigurationRangesButtonBackgroundRenderer=0x94, _selectedObjectCard=0x98, _selectedObjectUID=0x9c, _selectedDigitalPinConfigurationRanges=0xa0, _selectedAnalogPinConfigurationRanges=0xa4, _configurationPane=0xa8, _arePinConfigurationRangeMappingsBeingUndoneOrRedone=0xac, _isFinished=0xac, _availableCards=0xb0, _availableObjectsOnCards=0xb4, _currentObject=0xb8 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00296cc9 @ 00296cc9, 67 bytes * /

void FUN_00296cc9(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,id paneDidCancel)

{
  HSArduinoWatcherActionAssistantPane *local_c;
  undefined *local_8;
  
  self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] =
       self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] | 2;
  local_c = self;
  local_8 = PTR_s_HSNBAAssistantPane_00356930;
  _objc_msgSendSuper(&local_c,sel_paneDidCancel_,paneDidCancel);
  return;
}

*/
- (void)paneDidCancel:(id)aCancel
{
    _isFinished = YES;
    [super paneDidCancel:aCancel];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00296d0c @ 00296d0c, 67 bytes * /

void FUN_00296d0c(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,id paneDidOK)

{
  HSArduinoWatcherActionAssistantPane *local_c;
  undefined *local_8;
  
  self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] =
       self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] | 2;
  local_c = self;
  local_8 = PTR_s_HSNBAAssistantPane_00356930;
  _objc_msgSendSuper(&local_c,sel_paneDidOK_,paneDidOK);
  return;
}

*/
- (void)paneDidOK:(id)aOK
{
    _isFinished = YES;
    [super paneDidOK:aOK];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00296d4f @ 00296d4f, 82 bytes * /

void FUN_00296d4f(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,id toggleCurrentCardObjects)

{
  _objc_msgSend(*(id *)((int)&self->_isFinished + 3),sel_release);
  *(undefined4 *)((int)&self->_isFinished + 3) = 0;
  _objc_msgSend(self->_pinConfigurationRangeMappingsOutlineView,sel_reloadData);
  return;
}

*/
- (void)toggleCurrentCardObjects:(id)aObjects
{
    [_availableCards release];
    _availableCards = nil;
    [_pinConfigurationRangeMappingsOutlineView reloadData];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00296da1 @ 00296da1, 412 bytes * /

void FUN_00296da1(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,id actionPaneDidClose,
                 id withApplier,BOOL canceled)

{
  id pvVar1;
  int iVar2;
  SEL op;
  CFDictionary *pCVar3;
  
  if (self->_selectedDigitalPinConfigurationRanges != (CFDictionary *)0x0) {
    if (canceled == '\0') {
      iVar2 = _CFDictionaryGetCount(self->_selectedDigitalPinConfigurationRanges);
      if ((iVar2 == 0) &&
         (iVar2 = _CFDictionaryGetCount(self->_selectedAnalogPinConfigurationRanges), iVar2 == 0)) {
        pvVar1 = _objc_msgSend(self,
                               sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                              );
        pCVar3 = self->_selectedObjectUID;
        op = sel_removePinConfigurationRangesForObjectWithUID_;
      }
      else {
        pvVar1 = _objc_msgSend(self,
                               sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                              );
        pCVar3 = self->_selectedDigitalPinConfigurationRanges;
        op = sel_setDigitalPinConfigurationRanges_analogPinConfigurationRanges_forObjectWithUID_;
      }
    }
    else {
      pvVar1 = _objc_msgSend(self,
                             sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                            );
      pCVar3 = self->_selectedObjectUID;
      op = sel_synchronizePinConfigurationRangesForObjectWithUID_;
    }
    _objc_msgSend(pvVar1,op,pCVar3);
    _CFRelease(self->_selectedDigitalPinConfigurationRanges);
    self->_selectedDigitalPinConfigurationRanges = (CFDictionary *)0x0;
    _CFRelease(self->_selectedAnalogPinConfigurationRanges);
    self->_selectedAnalogPinConfigurationRanges = (CFDictionary *)0x0;
  }
  _objc_msgSend(self->_selectedObjectCard,sel_release);
  self->_selectedObjectCard = (id)0x0;
  _objc_msgSend(self->_selectedObjectUID,sel_release);
  self->_selectedObjectUID = (id)0x0;
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_isActive);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(self,sel_HSArduinoWatcherActionAssistantPane_cleanCaches);
  }
  return;
}

*/
- (void)actionPaneDidClose:(id)aClose withApplier:(id)aApplier canceled:(BOOL)aCanceled
{
    if (_selectedDigitalPinConfigurationRanges != NULL) {
        if (aCanceled) {
            [[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] synchronizePinConfigurationRangesForObjectWithUID:_selectedObjectUID];
        }
        else if (CFDictionaryGetCount(_selectedDigitalPinConfigurationRanges) == 0
                 && CFDictionaryGetCount(_selectedAnalogPinConfigurationRanges) == 0) {
            [[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] removePinConfigurationRangesForObjectWithUID:_selectedObjectUID];
        }
        else {
            [[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] setDigitalPinConfigurationRanges:_selectedDigitalPinConfigurationRanges analogPinConfigurationRanges:_selectedAnalogPinConfigurationRanges forObjectWithUID:_selectedObjectUID];
        }
        CFRelease(_selectedDigitalPinConfigurationRanges);
        _selectedDigitalPinConfigurationRanges = NULL;
        CFRelease(_selectedAnalogPinConfigurationRanges);
        _selectedAnalogPinConfigurationRanges = NULL;
    }
    [_selectedObjectCard release];
    _selectedObjectCard = nil;
    [_selectedObjectUID release];
    _selectedObjectUID = nil;
    if (![[self assistant] isActive]) {
        [self HSArduinoWatcherActionAssistantPane_cleanCaches];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00296f3d @ 00296f3d, 162 bytes * /

void FUN_00296f3d(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 uchar removeConfigurationRangeForAnalogPin)

{
  id self_00;
  id self_01;
  
  if (self->_selectedAnalogPinConfigurationRanges != (CFDictionary *)0x0) {
    _CFDictionaryRemoveValue
              (self->_selectedAnalogPinConfigurationRanges,removeConfigurationRangeForAnalogPin);
  }
  self_00 = _objc_msgSend(self,
                          sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                         );
  _objc_msgSend(self_00,sel_disableUndo);
  self_01 = _objc_msgSend(self_00,sel_arduinoWatcherActionAttributes);
  _objc_msgSend(self_01,sel_removeConfigurationRangeForObjectWithUID_analogPin_,
                self->_selectedObjectUID,(uint)removeConfigurationRangeForAnalogPin);
  _objc_msgSend(self_00,sel_enableUndo);
  return;
}

*/
- (void)removeConfigurationRangeForAnalogPin:(unsigned char)aPin
{
    id applier;

    if (_selectedAnalogPinConfigurationRanges != NULL) {
        CFDictionaryRemoveValue(_selectedAnalogPinConfigurationRanges, (const void *)(uintptr_t)aPin);
    }
    applier = [self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier];
    [applier disableUndo];
    [[applier arduinoWatcherActionAttributes] removeConfigurationRangeForObjectWithUID:_selectedObjectUID analogPin:aPin];
    [applier enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00296fdf @ 00296fdf, 388 bytes * /

void FUN_00296fdf(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,int setMode,ushort startValue,
                 ushort endValue,uchar forAnalogPin)

{
  undefined4 uVar1;
  undefined *puVar2;
  undefined *puVar3;
  CFDictionary *pCVar4;
  CFDictionary *pCVar5;
  id self_00;
  id self_01;
  
  puVar3 = PTR_00336a10;
  puVar2 = PTR_00336a0c;
  pCVar4 = self->_selectedAnalogPinConfigurationRanges;
  if (pCVar4 == (CFDictionary *)0x0) {
    uVar1 = *(undefined4 *)PTR_003363a4;
    pCVar4 = (CFDictionary *)_CFDictionaryCreateMutable(uVar1,0,PTR_00336a0c,PTR_00336a10);
    self->_selectedAnalogPinConfigurationRanges = pCVar4;
    if (pCVar4 == (CFDictionary *)0x0) {
      return;
    }
    pCVar5 = (CFDictionary *)_CFDictionaryCreateMutable(uVar1,0,puVar2,puVar3);
    self->_selectedDigitalPinConfigurationRanges = pCVar5;
    pCVar4 = self->_selectedAnalogPinConfigurationRanges;
    if (pCVar5 == (CFDictionary *)0x0) {
      _CFRelease(pCVar4);
      self->_selectedAnalogPinConfigurationRanges = (CFDictionary *)0x0;
      return;
    }
  }
  _CFDictionarySetValue
            (pCVar4,(uint)forAnalogPin,(uint)endValue << 0x14 | (uint)startValue << 8 | setMode);
  self_00 = _objc_msgSend(self,
                          sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                         );
  _objc_msgSend(self_00,sel_disableUndo);
  self_01 = _objc_msgSend(self_00,sel_arduinoWatcherActionAttributes);
  _objc_msgSend(self_01,sel_setMode_startValue_endValue_forObjectWithUID_analogPin_,setMode,
                (uint)startValue,(uint)endValue,self->_selectedObjectUID,(uint)forAnalogPin);
  _objc_msgSend(self_00,sel_enableUndo);
  return;
}

*/
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forAnalogPin:(unsigned char)aPin
{
    id applier;

    if (_selectedAnalogPinConfigurationRanges == NULL) {
        _selectedAnalogPinConfigurationRanges = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_selectedAnalogPinConfigurationRanges == NULL) {
            return;
        }
        _selectedDigitalPinConfigurationRanges = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_selectedDigitalPinConfigurationRanges == NULL) {
            CFRelease(_selectedAnalogPinConfigurationRanges);
            _selectedAnalogPinConfigurationRanges = NULL;
            return;
        }
    }
    // Packed as end value << 20 | start value << 8 | mode.
    CFDictionarySetValue(_selectedAnalogPinConfigurationRanges, (const void *)(uintptr_t)aPin, (const void *)(uintptr_t)((unsigned int)aValue2 << 20 | (unsigned int)aValue << 8 | (unsigned int)aMode));
    applier = [self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier];
    [applier disableUndo];
    [[applier arduinoWatcherActionAttributes] setMode:aMode startValue:aValue endValue:aValue2 forObjectWithUID:_selectedObjectUID analogPin:aPin];
    [applier enableUndo];
}

- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forAnalogPin:(unsigned char)aPin
{
    return (BOOL)[[[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] arduinoWatcherActionAttributes] getMode:aMode startValue:aValue endValue:aValue2 forObjectWithUID:_selectedObjectUID analogPin:(unsigned int)aPin];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002971db @ 002971db, 162 bytes * /

void FUN_002971db(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 uchar removeConfigurationRangeForDigitalPin)

{
  id self_00;
  id self_01;
  
  if (self->_selectedDigitalPinConfigurationRanges != (CFDictionary *)0x0) {
    _CFDictionaryRemoveValue
              (self->_selectedDigitalPinConfigurationRanges,removeConfigurationRangeForDigitalPin);
  }
  self_00 = _objc_msgSend(self,
                          sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                         );
  _objc_msgSend(self_00,sel_disableUndo);
  self_01 = _objc_msgSend(self_00,sel_arduinoWatcherActionAttributes);
  _objc_msgSend(self_01,sel_removeConfigurationRangeForObjectWithUID_digitalPin_,
                self->_selectedObjectUID,(uint)removeConfigurationRangeForDigitalPin);
  _objc_msgSend(self_00,sel_enableUndo);
  return;
}

*/
- (void)removeConfigurationRangeForDigitalPin:(unsigned char)aPin
{
    id applier;

    if (_selectedDigitalPinConfigurationRanges != NULL) {
        CFDictionaryRemoveValue(_selectedDigitalPinConfigurationRanges, (const void *)(uintptr_t)aPin);
    }
    applier = [self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier];
    [applier disableUndo];
    [[applier arduinoWatcherActionAttributes] removeConfigurationRangeForObjectWithUID:_selectedObjectUID digitalPin:aPin];
    [applier enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029727d @ 0029727d, 388 bytes * /

void FUN_0029727d(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,int setMode,ushort startValue,
                 ushort endValue,uchar forDigitalPin)

{
  undefined4 uVar1;
  undefined *puVar2;
  undefined *puVar3;
  CFDictionary *pCVar4;
  CFDictionary *pCVar5;
  id self_00;
  id self_01;
  
  puVar3 = PTR_00336a10;
  puVar2 = PTR_00336a0c;
  pCVar4 = self->_selectedDigitalPinConfigurationRanges;
  if (pCVar4 == (CFDictionary *)0x0) {
    uVar1 = *(undefined4 *)PTR_003363a4;
    pCVar4 = (CFDictionary *)_CFDictionaryCreateMutable(uVar1,0,PTR_00336a0c,PTR_00336a10);
    self->_selectedDigitalPinConfigurationRanges = pCVar4;
    if (pCVar4 == (CFDictionary *)0x0) {
      return;
    }
    pCVar5 = (CFDictionary *)_CFDictionaryCreateMutable(uVar1,0,puVar2,puVar3);
    self->_selectedAnalogPinConfigurationRanges = pCVar5;
    pCVar4 = self->_selectedDigitalPinConfigurationRanges;
    if (pCVar5 == (CFDictionary *)0x0) {
      _CFRelease(pCVar4);
      self->_selectedDigitalPinConfigurationRanges = (CFDictionary *)0x0;
      return;
    }
  }
  _CFDictionarySetValue
            (pCVar4,(uint)forDigitalPin,(uint)endValue << 0x14 | (uint)startValue << 8 | setMode);
  self_00 = _objc_msgSend(self,
                          sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                         );
  _objc_msgSend(self_00,sel_disableUndo);
  self_01 = _objc_msgSend(self_00,sel_arduinoWatcherActionAttributes);
  _objc_msgSend(self_01,sel_setMode_startValue_endValue_forObjectWithUID_digitalPin_,setMode,
                (uint)startValue,(uint)endValue,self->_selectedObjectUID,(uint)forDigitalPin);
  _objc_msgSend(self_00,sel_enableUndo);
  return;
}

*/
- (void)setMode:(NSInteger)aMode startValue:(unsigned short)aValue endValue:(unsigned short)aValue2 forDigitalPin:(unsigned char)aPin
{
    id applier;

    if (_selectedDigitalPinConfigurationRanges == NULL) {
        _selectedDigitalPinConfigurationRanges = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_selectedDigitalPinConfigurationRanges == NULL) {
            return;
        }
        _selectedAnalogPinConfigurationRanges = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
        if (_selectedAnalogPinConfigurationRanges == NULL) {
            CFRelease(_selectedDigitalPinConfigurationRanges);
            _selectedDigitalPinConfigurationRanges = NULL;
            return;
        }
    }
    // Packed as end value << 20 | start value << 8 | mode.
    CFDictionarySetValue(_selectedDigitalPinConfigurationRanges, (const void *)(uintptr_t)aPin, (const void *)(uintptr_t)((unsigned int)aValue2 << 20 | (unsigned int)aValue << 8 | (unsigned int)aMode));
    applier = [self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier];
    [applier disableUndo];
    [[applier arduinoWatcherActionAttributes] setMode:aMode startValue:aValue endValue:aValue2 forObjectWithUID:_selectedObjectUID digitalPin:aPin];
    [applier enableUndo];
}

- (BOOL)getMode:(int *)aMode startValue:(unsigned short *)aValue endValue:(unsigned short *)aValue2 forDigitalPin:(unsigned char)aPin
{
    return (BOOL)[[[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] arduinoWatcherActionAttributes] getMode:aMode startValue:aValue endValue:aValue2 forObjectWithUID:_selectedObjectUID digitalPin:(unsigned int)aPin];
}

- (id)outlineView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn item:(id)aItem mouseLocation:(NSPoint)aLocation
{
    NSString *pvVar1_5;

    if ([[aColumn identifier] isEqual:@"pinConfigurationRanges"]) {
        pvVar1_5 = [[[aItem queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] stringValue];
        if (pvVar1_5 != nil) {
            if ([[[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] arduinoWatcherActionAttributes] digitalPinConfigurationRangesForObjectWithUID:pvVar1_5] != nil) {
                return [[NSBundle mainBundle] localizedStringForKey:@"Click this button if you need to change the mode and value settings." value:@"" table:@"AssistantPanes"];
            }
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002975a1 @ 002975a1, 1045 bytes * /

void FUN_002975a1(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,id outlineView,
                 id willDisplayCell,id forTableColumn,id item)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  uint uVar6;
  SEL op;
  undefined *puVar7;
  uint uVar8;
  
  pvVar1 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar3 = &cfstr_object;
  pvVar2 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_object);
  if ((char)pvVar2 == '\0') {
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_pinConfigurationRanges);
    if ((char)pvVar1 == '\0') {
      return;
    }
    puVar7 = &DAT_00388dcc;
    pvVar1 = _objc_msgSend(item,sel_queryHyperInterface_,&DAT_00388dcc);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID);
    pvVar1 = _objc_msgSend(pvVar1,sel_stringValue);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar2 = _objc_msgSend(self,
                           sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                           ,puVar7);
    pvVar2 = _objc_msgSend(pvVar2,sel_arduinoWatcherActionAttributes);
    pvVar4 = _objc_msgSend(pvVar2,sel_digitalPinConfigurationRangesForObjectWithUID_,pvVar1);
    pvVar2 = self->_pinConfigurationRangesButtonBackgroundRenderer;
    if (pvVar2 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_HSActionsPaneButtonBackgroundRenderer,sel_alloc,pvVar1);
      pvVar2 = _objc_msgSend(pvVar1,sel_init);
      self->_pinConfigurationRangesButtonBackgroundRenderer = pvVar2;
      if (pvVar2 == (id)0x0) {
        return;
      }
    }
    _objc_msgSend(pvVar2,sel_setDrawsEmptyBorder_,(uint)(pvVar4 == (id)0x0));
    _objc_msgSend(willDisplayCell,sel_setBackgroundRenderer_,
                  self->_pinConfigurationRangesButtonBackgroundRenderer);
    uVar6 = (uint)(pvVar4 != (id)0x0);
    uVar8 = uVar6;
    _objc_msgSend(willDisplayCell,sel_setBordered_,uVar6);
    if (pvVar4 == (id)0x0) {
      _objc_msgSend(willDisplayCell,sel_setTitle_,&cfstr_empty);
      pcVar3 = (cfstringStruct *)0x0;
      op = sel_setEnabled_;
    }
    else {
      pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,uVar8);
      pcVar3 = &cfstr_AssistantPanes;
      pcVar5 = &cfstr_empty;
      pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Configure___,
                             &cfstr_empty,&cfstr_AssistantPanes);
      _objc_msgSend(willDisplayCell,sel_setTitle_,pvVar1);
      _objc_msgSend(willDisplayCell,sel_setEnabled_,uVar6);
      pvVar1 = _objc_msgSend(cls_NSColor,sel_controlTextColor);
      if (pvVar1 == (id)0x0) {
        return;
      }
      pvVar2 = _objc_msgSend(willDisplayCell,sel_attributedTitle,uVar6,pcVar5,pcVar3);
      pcVar5 = _objc_msgSend(pvVar2,sel_mutableCopy);
      if (pcVar5 == (cfstringStruct *)0x0) {
        return;
      }
      pvVar2 = _objc_msgSend(pcVar5,sel_length,uVar6);
      _objc_msgSend(pcVar5,sel_addAttribute_value_range_,*(undefined4 *)PTR_00336394,pvVar1,0,pvVar2
                   );
      pcVar3 = pcVar5;
      _objc_msgSend(willDisplayCell,sel_setAttributedTitle_,pcVar5);
      willDisplayCell = pcVar5;
      op = sel_release;
    }
  }
  else {
    pvVar1 = _objc_msgSend(item,sel_hyperObject,pcVar3);
    pvVar2 = _objc_msgSend(*(id *)((int)&self->_availableObjectsOnCards + 3),sel_hyperObject);
    if (pvVar1 == pvVar2) {
      return;
    }
    pvVar1 = _objc_msgSend(item,sel_queryHyperInterface_,&DAT_00388d40);
    pvVar2 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_003363a8);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperActionsForEvent_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pcVar3 = _objc_msgSend(self,sel_HSArduinoWatcherActionAssistantPane_titleForItem_,item);
    op = sel_setAttributedTitle_;
    if (pcVar3 == (cfstringStruct *)0x0) {
      pcVar3 = &cfstr_empty;
      op = sel_setTitle_;
    }
  }
  _objc_msgSend(willDisplayCell,op,pcVar3);
  return;
}

*/
- (void)outlineView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn item:(id)aItem
{
    id identifier;
    NSString *uid;
    id ranges;
    NSColor *textColor;
    NSMutableAttributedString *title;
    id attributedTitle;

    identifier = [aColumn identifier];
    if ([identifier isEqualToString:@"object"]) {
        if ([aItem hyperObject] == [_currentObject hyperObject]) {
            return;
        }
        if (!([[[aItem queryHyperInterface:@protocol(HSActor)] hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] count] != 0)) {
            return;
        }
        attributedTitle = [self HSArduinoWatcherActionAssistantPane_titleForItem:aItem];
        if (attributedTitle == nil) {
            [aCell setTitle:@""];
        }
        else {
            [aCell setAttributedTitle:attributedTitle];
        }
        return;
    }
    if (![identifier isEqual:@"pinConfigurationRanges"]) {
        return;
    }
    uid = [[[aItem queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] stringValue];
    if (uid == nil) {
        return;
    }
    ranges = (id)[[[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] arduinoWatcherActionAttributes] digitalPinConfigurationRangesForObjectWithUID:uid];
    if (_pinConfigurationRangesButtonBackgroundRenderer == nil) {
        _pinConfigurationRangesButtonBackgroundRenderer = [[HSActionsPaneButtonBackgroundRenderer alloc] init];
        if (_pinConfigurationRangesButtonBackgroundRenderer == nil) {
            return;
        }
    }
    [_pinConfigurationRangesButtonBackgroundRenderer setDrawsEmptyBorder:ranges == nil];
    [aCell setBackgroundRenderer:_pinConfigurationRangesButtonBackgroundRenderer];
    [aCell setBordered:ranges != nil];
    if (ranges == nil) {
        [aCell setTitle:@""];
        [aCell setEnabled:NO];
        return;
    }
    [aCell setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Configure..." value:@"" table:@"AssistantPanes"]];
    [aCell setEnabled:YES];
    textColor = [NSColor controlTextColor];
    if (textColor == nil) {
        return;
    }
    title = [[aCell attributedTitle] mutableCopy];
    if (title == nil) {
        return;
    }
    [title addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, [title length])];
    [aCell setAttributedTitle:title];
    [title release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002979b6 @ 002979b6, 1035 bytes * /

void FUN_002979b6(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,id outlineView,
                 id setObjectValue,id forTableColumn,id byItem)

{
  undefined4 uVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  HSArduinoWatcherActionAssistantPane *pHVar6;
  CFDictionary *pCVar7;
  SEL op;
  undefined *puVar8;
  
  pvVar3 = _objc_msgSend(forTableColumn,sel_identifier);
  pvVar4 = _objc_msgSend(pvVar3,sel_isEqualToString_,&cfstr_object);
  cVar2 = (char)pvVar4;
  if ((cVar2 == '\0') &&
     (pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,&cfstr_pinConfigurationRanges),
     (char)pvVar3 == '\0')) {
    return;
  }
  pHVar6 = (HSArduinoWatcherActionAssistantPane *)&DAT_00388dcc;
  pvVar3 = _objc_msgSend(byItem,sel_queryHyperInterface_,&DAT_00388dcc);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperUID);
  pvVar3 = _objc_msgSend(pvVar3,sel_stringValue);
  if (pvVar3 == (id)0x0) {
    return;
  }
  if ((cVar2 == '\0') ||
     (pvVar4 = _objc_msgSend(setObjectValue,sel_integerValue,pHVar6), pvVar4 == (id)0x1)) {
    if (self->_configurationPane == (id)0x0) {
      pvVar4 = _objc_msgSend(cls_HSArduinoWatcherActionConfigurationAssistantPane,sel_alloc,pHVar6);
      pvVar4 = _objc_msgSend(pvVar4,sel_init);
      self->_configurationPane = pvVar4;
      if (pvVar4 == (id)0x0) {
        return;
      }
      _objc_msgSend(pvVar4,sel_setDelegate_,self);
      pHVar6 = self;
      _objc_msgSend(self->_configurationPane,sel_setDataSource_,self);
    }
    if (cVar2 == '\0') {
      pvVar4 = _objc_msgSend(self,
                             sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                             ,pHVar6);
      pvVar5 = _objc_msgSend(pvVar4,sel_arduinoWatcherActionAttributes);
      pvVar4 = pvVar3;
      pvVar5 = _objc_msgSend(pvVar5,sel_digitalPinConfigurationRangesForObjectWithUID_,pvVar3);
      if (pvVar5 == (id)0x0) {
        return;
      }
      pvVar4 = _objc_msgSend(self,
                             sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                             ,pvVar4);
      pvVar4 = _objc_msgSend(pvVar4,sel_arduinoWatcherActionAttributes);
      pHVar6 = _objc_msgSend(pvVar4,sel_analogPinConfigurationRangesForObjectWithUID_,pvVar3);
      if (pHVar6 == (HSArduinoWatcherActionAssistantPane *)0x0) {
        return;
      }
      uVar1 = *(undefined4 *)PTR_003363a4;
      pCVar7 = (CFDictionary *)_CFDictionaryCreateMutableCopy(uVar1,0,pvVar5);
      self->_selectedDigitalPinConfigurationRanges = pCVar7;
      if (pCVar7 == (CFDictionary *)0x0) {
        return;
      }
      pCVar7 = (CFDictionary *)_CFDictionaryCreateMutableCopy(uVar1,0,pHVar6);
      self->_selectedAnalogPinConfigurationRanges = pCVar7;
      if (pCVar7 == (CFDictionary *)0x0) {
        _CFRelease(self->_selectedDigitalPinConfigurationRanges);
        self->_selectedDigitalPinConfigurationRanges = (CFDictionary *)0x0;
        return;
      }
    }
    pvVar3 = _objc_msgSend(pvVar3,sel_copy,pHVar6);
    self->_selectedObjectUID = pvVar3;
    if (pvVar3 == (id)0x0) {
      if (self->_selectedDigitalPinConfigurationRanges != (CFDictionary *)0x0) {
        _CFRelease(self->_selectedDigitalPinConfigurationRanges);
        self->_selectedDigitalPinConfigurationRanges = (CFDictionary *)0x0;
      }
      if (self->_selectedAnalogPinConfigurationRanges == (CFDictionary *)0x0) {
        return;
      }
      _CFRelease(self->_selectedAnalogPinConfigurationRanges);
      self->_selectedAnalogPinConfigurationRanges = (CFDictionary *)0x0;
      return;
    }
    puVar8 = &DAT_00388c00;
    pvVar3 = _objc_msgSend(byItem,sel_queryHyperInterface_,&DAT_00388c00);
    pvVar3 = _objc_msgSend(pvVar3,sel_card);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    self->_selectedObjectCard = pvVar3;
    pvVar3 = _objc_msgSend(self,sel_isHelpVisible);
    if ((char)pvVar3 != '\0') {
      puVar8 = (undefined *)0x1;
      _objc_msgSend(self,sel_hideHelpNeedsRelayout_,1);
    }
    pvVar4 = _objc_msgSend(self,sel_objectAssistantNavigationController,puVar8);
    pvVar3 = self->_configurationPane;
    op = sel_pushViewController_animate_;
  }
  else {
    pvVar4 = _objc_msgSend(self,
                           sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                           ,pHVar6);
    _objc_msgSend(pvVar4,sel_removePinConfigurationRangesForObjectWithUID_,pvVar3);
    _objc_msgSend(pvVar4,sel_disableUndo);
    pvVar5 = _objc_msgSend(pvVar4,sel_arduinoWatcherActionAttributes);
    _objc_msgSend(pvVar5,sel_removePinConfigurationRangesForObjectWithUID_,pvVar3);
    op = sel_enableUndo;
  }
  _objc_msgSend(pvVar4,op,pvVar3);
  return;
}

*/
- (void)outlineView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn byItem:(id)aItem
{
    id identifier;
    BOOL isObjectColumn;
    NSString *uid;
    id applier;
    id digitalRanges;
    id analogRanges;

    identifier = [aColumn identifier];
    isObjectColumn = [identifier isEqualToString:@"object"];
    if (!isObjectColumn && ![identifier isEqualToString:@"pinConfigurationRanges"]) {
        return;
    }
    uid = [[[aItem queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] stringValue];
    if (uid == nil) {
        return;
    }
    if (isObjectColumn && [aValue integerValue] != 1) {
        // Unchecking an object drops its pin configuration.
        applier = [self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier];
        [applier removePinConfigurationRangesForObjectWithUID:uid];
        [applier disableUndo];
        [[applier arduinoWatcherActionAttributes] removePinConfigurationRangesForObjectWithUID:uid];
        [applier enableUndo];
        return;
    }
    if (_configurationPane == nil) {
        _configurationPane = [[HSArduinoWatcherActionConfigurationAssistantPane alloc] init];
        if (_configurationPane == nil) {
            return;
        }
        [_configurationPane setDelegate:self];
        [_configurationPane setDataSource:self];
    }
    if (!isObjectColumn) {
        // "Configure..." edits a copy of the object's existing ranges.
        digitalRanges = (id)[[[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] arduinoWatcherActionAttributes] digitalPinConfigurationRangesForObjectWithUID:uid];
        if (digitalRanges == nil) {
            return;
        }
        analogRanges = (id)[[[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] arduinoWatcherActionAttributes] analogPinConfigurationRangesForObjectWithUID:uid];
        if (analogRanges == nil) {
            return;
        }
        _selectedDigitalPinConfigurationRanges = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)digitalRanges);
        if (_selectedDigitalPinConfigurationRanges == NULL) {
            return;
        }
        _selectedAnalogPinConfigurationRanges = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, (CFDictionaryRef)analogRanges);
        if (_selectedAnalogPinConfigurationRanges == NULL) {
            CFRelease(_selectedDigitalPinConfigurationRanges);
            _selectedDigitalPinConfigurationRanges = NULL;
            return;
        }
    }
    _selectedObjectUID = [uid copy];
    if (_selectedObjectUID == nil) {
        if (_selectedDigitalPinConfigurationRanges != NULL) {
            CFRelease(_selectedDigitalPinConfigurationRanges);
            _selectedDigitalPinConfigurationRanges = NULL;
        }
        if (_selectedAnalogPinConfigurationRanges != NULL) {
            CFRelease(_selectedAnalogPinConfigurationRanges);
            _selectedAnalogPinConfigurationRanges = NULL;
        }
        return;
    }
    _selectedObjectCard = [[[aItem queryHyperInterface:@protocol(HSUserObjectSupport)] card] retain];
    if ([self isHelpVisible]) {
        [self hideHelpNeedsRelayout:YES];
    }
    [[self objectAssistantNavigationController] pushViewController:_configurationPane animate:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00297dc1 @ 00297dc1, 464 bytes * /

id FUN_00297dc1(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,id outlineView,
               id objectValueForTableColumn,id byItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  cfstringStruct *pcVar5;
  
  puVar4 = &DAT_00388dcc;
  pvVar1 = _objc_msgSend(byItem,sel_queryHyperInterface_,&DAT_00388dcc);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,puVar4);
    pcVar5 = &cfstr_object;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_object);
    if ((char)pvVar2 != '\0') {
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID,pcVar5);
      pvVar1 = _objc_msgSend(pvVar1,sel_stringValue);
      if (pvVar1 != (id)0x0) {
        pvVar2 = _objc_msgSend(byItem,sel_hyperObject,pcVar5);
        pvVar3 = _objc_msgSend(*(id *)((int)&self->_availableObjectsOnCards + 3),sel_hyperObject);
        op = sel_HSArduinoWatcherActionAssistantPane_titleForItem_;
        if (pvVar2 != pvVar3) {
          pvVar2 = _objc_msgSend(byItem,sel_queryHyperInterface_,&DAT_00388d40);
          pvVar3 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,
                                 *(undefined4 *)PTR_003363a8);
          pvVar2 = _objc_msgSend(pvVar2,sel_hyperActionsForEvent_,pvVar3);
          pvVar2 = _objc_msgSend(pvVar2,sel_count);
          puVar4 = cls_NSNumber;
          op = sel_HSArduinoWatcherActionAssistantPane_titleForItem_;
          if (pvVar2 != (id)0x0) {
            pvVar2 = _objc_msgSend(self,
                                   sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                                   ,pvVar3);
            pvVar2 = _objc_msgSend(pvVar2,sel_arduinoWatcherActionAttributes);
            pvVar1 = _objc_msgSend(pvVar2,sel_digitalPinConfigurationRangesForObjectWithUID_,pvVar1)
            ;
            byItem = (id)(uint)(pvVar1 != (id)0x0);
            self = (HSArduinoWatcherActionAssistantPane *)puVar4;
            op = sel_numberWithInteger_;
          }
        }
        pvVar1 = _objc_msgSend(self,op,byItem);
        return pvVar1;
      }
    }
  }
  return (id)0x0;
}

*/
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem
{
    id attributes;
    NSString *uid;

    attributes = [aItem queryHyperInterface:@protocol(HSObjectAttributes)];
    if (attributes == nil || ![[aColumn identifier] isEqualToString:@"object"]) {
        return nil;
    }
    uid = [[attributes hyperUID] stringValue];
    if (uid == nil) {
        return nil;
    }
    if ([aItem hyperObject] != [_currentObject hyperObject] && [[[aItem queryHyperInterface:@protocol(HSActor)] hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] count] != 0) {
        // Objects with actions show a check box that is on when they have ranges.
        return [NSNumber numberWithInteger:[[[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] arduinoWatcherActionAttributes] digitalPinConfigurationRangesForObjectWithUID:uid] != nil];
    }
    return [self HSArduinoWatcherActionAssistantPane_titleForItem:aItem];
}

- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable
{
    return [[self HSArduinoWatcherActionAssistantPane_availableObjectsOnCard:aExpandable] count] != 0;
}

- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem
{
    id pvVar1;

    if (aItem == nil) {
        pvVar1 = [self HSArduinoWatcherActionAssistantPane_availableCards];
    }
    else {
        pvVar1 = [self HSArduinoWatcherActionAssistantPane_availableObjectsOnCard:aItem];
        aChild = ~aChild + (int)[pvVar1 count];
    }
    return [pvVar1 objectAtIndex:aChild];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00298067 @ 00298067, 81 bytes * /

int FUN_00298067(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,id outlineView,
                id numberOfChildrenOfItem)

{
  id pvVar1;
  SEL op;
  
  op = sel_HSArduinoWatcherActionAssistantPane_availableObjectsOnCard_;
  if (numberOfChildrenOfItem == (id)0x0) {
    op = sel_HSArduinoWatcherActionAssistantPane_availableCards;
  }
  pvVar1 = _objc_msgSend(self,op);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  return (int)pvVar1;
}

*/
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem
{
    if (aItem == nil) {
        return [[self HSArduinoWatcherActionAssistantPane_availableCards] count];
    }
    return [[self HSArduinoWatcherActionAssistantPane_availableObjectsOnCard:aItem] count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002980b8 @ 002980b8, 692 bytes * /

id FUN_002980b8(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
               id HSArduinoWatcherActionAssistantPane_titleForItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL pcVar5;
  float extraout_EDX;
  double dVar6;
  undefined *puVar7;
  undefined4 uVar8;
  id pvVar9;
  
  puVar7 = &DAT_00388dcc;
  pvVar1 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_titleForItem,sel_queryHyperInterface_,
                         &DAT_00388dcc);
  if (pvVar1 != (id)0x0) {
    if (self->_objectNameParagraphStyle == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_NSParagraphStyle,sel_defaultParagraphStyle,puVar7);
      pvVar2 = _objc_msgSend(pvVar2,sel_mutableCopy);
      self->_objectNameParagraphStyle = pvVar2;
      if (pvVar2 == (id)0x0) {
        return (id)0x0;
      }
      dVar6 = _objc_msgSend_fpret(self->_pinConfigurationRangeMappingsOutlineView,sel_rowHeight);
      pvVar3 = _objc_msgSend(self->_pinConfigurationRangeMappingsOutlineView,sel_outlineTableColumn,
                             puVar7);
      pvVar3 = _objc_msgSend(pvVar3,sel_dataCell);
      _objc_msgSend(pvVar3,sel_cellSize);
      _objc_msgSend(pvVar2,sel_setMinimumLineHeight_,(extraout_EDX + (float)dVar6) * 0.5);
      _objc_msgSend(self->_objectNameParagraphStyle,sel_setLineBreakMode_,4);
    }
    puVar7 = &DAT_00388e6c;
    pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00388e6c);
    pcVar5 = sel_hyperName;
    if (pvVar2 != (id)0x0) {
      pvVar1 = pvVar2;
      pcVar5 = sel_hyperTitle;
    }
    pvVar1 = _objc_msgSend(pvVar1,pcVar5,puVar7);
    if (pvVar1 != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc,puVar7);
      pvVar3 = _objc_msgSend(pvVar3,sel_initWithString_,pvVar1);
      pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
      if (pvVar3 != (id)0x0) {
        pvVar4 = _objc_msgSend(pvVar3,sel_length,pvVar1);
        pvVar1 = self->_objectNameParagraphStyle;
        uVar8 = 0;
        pvVar9 = pvVar4;
        _objc_msgSend(pvVar3,sel_addAttribute_value_range_,*(undefined4 *)PTR_00336150,pvVar1,0,
                      pvVar4);
        puVar7 = cls_NSFont;
        dVar6 = _objc_msgSend_fpret(cls_NSFont,sel_systemFontSizeForControlSize_,1);
        pcVar5 = sel_systemFontOfSize_;
        if (pvVar2 != (id)0x0) {
          pcVar5 = sel_boldSystemFontOfSize_;
        }
        pvVar1 = _objc_msgSend(puVar7,pcVar5,(float)dVar6,pvVar1,uVar8,pvVar9);
        if (pvVar1 != (id)0x0) {
          _objc_msgSend(pvVar3,sel_addAttribute_value_range_,*(undefined4 *)PTR_00336068,pvVar1,0,
                        pvVar4);
          return pvVar3;
        }
        return pvVar3;
      }
    }
  }
  return (id)0x0;
}

*/
- (id)HSArduinoWatcherActionAssistantPane_titleForItem:(id)aItem
{
    id attributes;
    id card;
    NSString *title;
    NSMutableAttributedString *attributedTitle;
    NSUInteger length;
    CGFloat fontSize;
    NSFont *font;

    attributes = [aItem queryHyperInterface:@protocol(HSObjectAttributes)];
    if (attributes == nil) {
        return nil;
    }
    if (_objectNameParagraphStyle == nil) {
        _objectNameParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        if (_objectNameParagraphStyle == nil) {
            return nil;
        }
        [_objectNameParagraphStyle setMinimumLineHeight:([_pinConfigurationRangeMappingsOutlineView rowHeight] + [[[_pinConfigurationRangeMappingsOutlineView outlineTableColumn] dataCell] cellSize].height) * 0.5];
        [_objectNameParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    }
    card = [attributes queryHyperInterface:@protocol(HSCardAttributes)];
    if (card != nil) {
        title = [card hyperTitle];
    }
    else {
        title = [attributes hyperName];
    }
    if (title == nil) {
        return nil;
    }
    attributedTitle = [[[NSMutableAttributedString alloc] initWithString:title] autorelease];
    if (attributedTitle == nil) {
        return nil;
    }
    length = [attributedTitle length];
    [attributedTitle addAttribute:NSParagraphStyleAttributeName value:_objectNameParagraphStyle range:NSMakeRange(0, length)];
    fontSize = [NSFont systemFontSizeForControlSize:NSControlSizeSmall];
    if (card != nil) {
        font = [NSFont boldSystemFontOfSize:fontSize];
    }
    else {
        font = [NSFont systemFontOfSize:fontSize];
    }
    if (font != nil) {
        [attributedTitle addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, length)];
    }
    return attributedTitle;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029836c @ 0029836c, 418 bytes * /

id FUN_0029836c(HSArduinoWatcherActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  
  if (*(int *)((int)&self->_isFinished + 3) == 0) {
    pvVar1 = _objc_msgSend(self->_currentCardObjectsCheckBox,sel_state);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
      pvVar1 = _objc_msgSend(pvVar1,sel_init);
      *(id *)((int)&self->_isFinished + 3) = pvVar1;
      pvVar1 = _objc_msgSend(self,sel_stack);
      pvVar2 = _objc_msgSend(pvVar1,sel_hyperCount);
      if (pvVar2 != (id)0x0) {
        pvVar5 = (id)0x0;
        do {
          pvVar3 = _objc_msgSend(pvVar1,sel_hyperChildAtIndex_,pvVar5);
          pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388cb4);
          if ((pvVar3 != (id)0x0) &&
             (pvVar4 = _objc_msgSend(self,sel_HSArduinoWatcherActionAssistantPane_hasActionsOnCard_,
                                     pvVar3), (char)pvVar4 != '\0')) {
            _objc_msgSend(*(id *)((int)&self->_isFinished + 3),sel_addObject_,pvVar3);
          }
          pvVar5 = (id)((int)pvVar5 + 1);
        } while (pvVar5 < pvVar2);
      }
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_card);
      if (pvVar1 != (id)0x0) {
        pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
        pvVar2 = _objc_msgSend(self,sel_card);
        pvVar1 = _objc_msgSend(pvVar1,sel_initWithObjects_,pvVar2,0);
        *(id *)((int)&self->_isFinished + 3) = pvVar1;
      }
    }
  }
  return *(id *)((int)&self->_isFinished + 3);
}

*/
- (id)HSArduinoWatcherActionAssistantPane_availableCards
{
    id stack;
    NSUInteger count;
    NSUInteger index;
    id card;

    if (_availableCards == nil) {
        if ([_currentCardObjectsCheckBox state] == NSControlStateValueOff) {
            _availableCards = [[NSMutableArray alloc] init];
            stack = [self stack];
            count = [stack hyperCount];
            for (index = 0; index < count; index++) {
                card = [[stack hyperChildAtIndex:index] queryHyperInterface:@protocol(HSNodeContainer)];
                if (card != nil && [self HSArduinoWatcherActionAssistantPane_hasActionsOnCard:card]) {
                    [_availableCards addObject:card];
                }
            }
        }
        else if ([self card] != nil) {
            _availableCards = [[NSMutableArray alloc] initWithObjects:[self card], nil];
        }
    }
    return _availableCards;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029850e @ 0029850e, 252 bytes * /

BOOL FUN_0029850e(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 id HSArduinoWatcherActionAssistantPane_hasActionsOnCard)

{
  id pvVar1;
  id pvVar2;
  bool bVar3;
  
  pvVar2 = HSArduinoWatcherActionAssistantPane_hasActionsOnCard;
  pvVar1 = _objc_msgSend(self,sel_HSArduinoWatcherActionAssistantPane_availableObjectsOnCard_,
                         HSArduinoWatcherActionAssistantPane_hasActionsOnCard);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 == (id)0x0) {
    pvVar2 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_hasActionsOnCard,sel_hyperObject,
                           pvVar2);
    pvVar1 = _objc_msgSend(*(id *)((int)&self->_availableObjectsOnCards + 3),sel_hyperObject);
    if (pvVar2 == pvVar1) {
      bVar3 = false;
    }
    else {
      pvVar2 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_hasActionsOnCard,
                             sel_queryHyperInterface_,&DAT_00388d40);
      pvVar1 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_003363a8);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperActionsForEvent_,pvVar1);
      pvVar2 = _objc_msgSend(pvVar2,sel_count);
      bVar3 = pvVar2 != (id)0x0;
    }
  }
  else {
    bVar3 = true;
  }
  return bVar3;
}

*/
- (BOOL)HSArduinoWatcherActionAssistantPane_hasActionsOnCard:(id)aCard
{
    if ([[self HSArduinoWatcherActionAssistantPane_availableObjectsOnCard:aCard] count] != 0) {
        return YES;
    }
    if ([aCard hyperObject] == [_currentObject hyperObject]) {
        return NO;
    }
    return [[[aCard queryHyperInterface:@protocol(HSActor)] hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] count] != 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029860a @ 0029860a, 469 bytes * /

id FUN_0029860a(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
               id HSArduinoWatcherActionAssistantPane_availableObjectsOnCard)

{
  undefined4 uVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  int iVar6;
  id pvVar7;
  
  iVar6 = *(int *)((int)&self->_availableCards + 3);
  if ((iVar6 != 0) &&
     (pvVar2 = (id)_CFDictionaryGetValue
                             (iVar6,HSArduinoWatcherActionAssistantPane_availableObjectsOnCard),
     pvVar2 != (id)0x0)) {
    return pvVar2;
  }
  self_00 = (id)0x0;
  pvVar2 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_availableObjectsOnCard,sel_hyperCount);
  if ((pvVar2 != (id)0x0) &&
     (self_00 = _objc_msgSend(cls_NSMutableArray,sel_array), self_00 != (id)0x0)) {
    uVar1 = *(undefined4 *)PTR_003363a8;
    pvVar7 = (id)0x0;
    do {
      pvVar3 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_availableObjectsOnCard,
                             sel_hyperChildAtIndex_,pvVar7);
      if (pvVar3 != *(id *)((int)&self->_availableObjectsOnCards + 3)) {
        pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388d40);
        pvVar5 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,uVar1);
        pvVar4 = _objc_msgSend(pvVar4,sel_hyperActionsForEvent_,pvVar5);
        pvVar4 = _objc_msgSend(pvVar4,sel_count);
        if ((pvVar4 != (id)0x0) &&
           (pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388cb4), pvVar3 != (id)0x0
           )) {
          _objc_msgSend(self_00,sel_addObject_,pvVar3);
        }
      }
      pvVar7 = (id)((int)pvVar7 + 1);
    } while (pvVar7 < pvVar2);
    iVar6 = *(int *)((int)&self->_availableCards + 3);
    if (iVar6 == 0) {
      iVar6 = _CFDictionaryCreateMutable(*(undefined4 *)PTR_003363a4,0,PTR_00336510,PTR_00336514);
      *(int *)((int)&self->_availableCards + 3) = iVar6;
      if (iVar6 == 0) {
        return self_00;
      }
    }
    _CFDictionarySetValue(iVar6,HSArduinoWatcherActionAssistantPane_availableObjectsOnCard,self_00);
  }
  return self_00;
}

*/
- (id)HSArduinoWatcherActionAssistantPane_availableObjectsOnCard:(id)aCard
{
    NSMutableArray *objects;
    NSUInteger count;
    NSUInteger index;
    id child;
    id node;

    if (_availableObjectsOnCards != NULL) {
        objects = (id)CFDictionaryGetValue(_availableObjectsOnCards, aCard);
        if (objects != nil) {
            return objects;
        }
    }
    count = [aCard hyperCount];
    if (count == 0) {
        return nil;
    }
    objects = [NSMutableArray array];
    if (objects == nil) {
        return nil;
    }
    for (index = 0; index < count; index++) {
        child = [aCard hyperChildAtIndex:index];
        if (child != _currentObject
            && [[[child queryHyperInterface:@protocol(HSActor)] hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] count] != 0) {
            node = [child queryHyperInterface:@protocol(HSNodeContainer)];
            if (node != nil) {
                [objects addObject:node];
            }
        }
    }
    if (_availableObjectsOnCards == NULL) {
        _availableObjectsOnCards = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_availableObjectsOnCards == NULL) {
            return objects;
        }
    }
    CFDictionarySetValue(_availableObjectsOnCards, aCard, objects);
    return objects;
}

- (id)initialKeyView
{
    return _pinConfigurationRangeMappingsOutlineView;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    if (_selectedObjectUID == nil) {
        [self HSArduinoWatcherActionAssistantPane_cleanCaches];
    }
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029883d @ 0029883d, 276 bytes * /

void FUN_0029883d(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  HSArduinoWatcherActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00356930;
  puVar3 = (undefined *)(int)viewWillAppear;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,puVar3);
  if (*(int *)((int)&self->_availableObjectsOnCards + 3) == 0) {
    self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] =
         self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] & 0xfd;
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    puVar3 = &DAT_00388cdc;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00388cdc);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    *(id *)((int)&self->_availableObjectsOnCards + 3) = pvVar1;
    _objc_msgSend(self,sel_HSArduinoWatcherActionAssistantPane_addObservers);
  }
  _objc_msgSend(self->_pinConfigurationRangeMappingsOutlineView,sel_reloadData,puVar3);
  if (self->_selectedObjectUID == (id)0x0) {
    pvVar1 = self->_pinConfigurationRangeMappingsOutlineView;
    pvVar2 = _objc_msgSend(self,sel_card);
    _objc_msgSend(pvVar1,sel_expandItem_expandChildren_,pvVar2,0);
  }
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    if (_currentObject == nil) {
        _isFinished = NO;
        _currentObject = [[[[self assistant] object] queryHyperInterface:@protocol(HSNodeChild)] retain];
        [self HSArduinoWatcherActionAssistantPane_addObservers];
    }
    [_pinConfigurationRangeMappingsOutlineView reloadData];
    if (_selectedObjectUID == nil) {
        [_pinConfigurationRangeMappingsOutlineView expandItem:[self card] expandChildren:NO];
    }
}

- (id)actionType
{
    return [HSArduinoWatcherAction actionType];
}

- (Class)applierClass
{
    return [HSArduinoWatcherActionAssistantPaneApplier class];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002989a3 @ 002989a3, 160 bytes * /

void FUN_002989a3(HSArduinoWatcherActionAssistantPane *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  
  pvVar2 = _objc_msgSend(self,sel_stack);
  _objc_msgSend(self,sel_HSArduinoWatcherActionAssistantPane_removeObserversFromStack_,pvVar2);
  _objc_msgSend(*(id *)((int)&self->_isFinished + 3),sel_release);
  *(undefined4 *)((int)&self->_isFinished + 3) = 0;
  iVar1 = *(int *)((int)&self->_availableCards + 3);
  if (iVar1 != 0) {
    _CFRelease(iVar1);
    *(undefined4 *)((int)&self->_availableCards + 3) = 0;
  }
  _objc_msgSend(*(id *)((int)&self->_availableObjectsOnCards + 3),sel_release,pvVar2);
  *(undefined4 *)((int)&self->_availableObjectsOnCards + 3) = 0;
  return;
}

*/
- (void)HSArduinoWatcherActionAssistantPane_cleanCaches
{
    [self HSArduinoWatcherActionAssistantPane_removeObserversFromStack:[self stack]];
    [_availableCards release];
    _availableCards = nil;
    if (_availableObjectsOnCards != NULL) {
        CFRelease(_availableObjectsOnCards);
        _availableObjectsOnCards = NULL;
    }
    [_currentObject release];
    _currentObject = nil;
}

- (void)HSArduinoWatcherActionAssistantPane_objectNameDidChange:(id)aChange
{
    id pvVar1_3;

    if ([self isVisible]) {
        pvVar1_3 = [[aChange object] queryHyperInterface:@protocol(HSNodeContainer)];
        if (pvVar1_3 != nil) {
            [_pinConfigurationRangeMappingsOutlineView reloadItem:pvVar1_3];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00298ac2 @ 00298ac2, 438 bytes * /

uint FUN_00298ac2(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 id HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight,id toArray,
                 BOOL *containsObject)

{
  id pvVar1;
  id pvVar2;
  id local_18;
  id local_14;
  
  local_14 = _objc_msgSend(toArray,sel_count);
  if (local_14 != (id)0x0) {
    pvVar1 = _objc_msgSend(toArray,sel_objectAtIndex_,0);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperOrderWeight);
    pvVar2 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight,
                           sel_compare_,pvVar1);
    if (pvVar2 == (id)0x0) {
      if (containsObject == (BOOL *)0x0) {
        return 0;
      }
      *containsObject = '\x01';
      return 0;
    }
    if (pvVar2 != (id)0xffffffff) {
      pvVar1 = _objc_msgSend(toArray,sel_lastObject,pvVar1);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperOrderWeight);
      pvVar1 = _objc_msgSend(pvVar1,sel_compare_,
                             HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight);
      if (pvVar1 == (id)0x0) {
        if (containsObject != (BOOL *)0x0) {
          *containsObject = '\x01';
        }
        return (int)local_14 - 1;
      }
      if (pvVar1 != (id)0xffffffff) {
        local_14 = (id)((int)local_14 + -1);
        local_18 = (id)0x0;
        pvVar1 = local_18;
LAB_00298be4:
        local_18 = pvVar1;
        pvVar1 = local_14;
        while (local_14 = pvVar1, pvVar1 = (id)((uint)((int)local_14 + (int)local_18) >> 1),
              local_14 != (id)((int)local_18 + 1)) {
          while( true ) {
            pvVar2 = _objc_msgSend(toArray,sel_objectAtIndex_,pvVar1);
            pvVar2 = _objc_msgSend(pvVar2,sel_hyperOrderWeight);
            pvVar2 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight
                                   ,sel_compare_,pvVar2);
            if (pvVar2 == (id)0xffffffff) break;
            if (pvVar2 == (id)0x1) goto LAB_00298be4;
            if (pvVar2 == (id)0x0) {
              if (containsObject != (BOOL *)0x0) {
                *containsObject = '\x01';
                return (uint)pvVar1;
              }
              return (uint)pvVar1;
            }
          }
        }
      }
      if (containsObject != (BOOL *)0x0) {
        *containsObject = '\0';
        return (uint)local_14;
      }
      return (uint)local_14;
    }
  }
  if (containsObject != (BOOL *)0x0) {
    *containsObject = '\0';
  }
  return 0;
}

*/
- (NSUInteger)HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight:(id)aWeight toArray:(id)aArray containsObject:(BOOL *)aObject
{
    NSUInteger count;
    NSUInteger low;
    NSUInteger high;
    NSUInteger middle;
    NSComparisonResult result;

    // Binary search over the array, which is kept sorted by hyperOrderWeight.
    count = [aArray count];
    if (count != 0) {
        result = [aWeight compare:[[aArray objectAtIndex:0] hyperOrderWeight]];
        if (result == NSOrderedSame) {
            if (aObject != NULL) {
                *aObject = YES;
            }
            return 0;
        }
        if (result != NSOrderedAscending) {
            result = [[[aArray lastObject] hyperOrderWeight] compare:aWeight];
            if (result == NSOrderedSame) {
                if (aObject != NULL) {
                    *aObject = YES;
                }
                return count - 1;
            }
            high = count;
            if (result != NSOrderedAscending) {
                high = count - 1;
                low = 0;
                while (middle = (high + low) >> 1, high != low + 1) {
                    result = [aWeight compare:[[aArray objectAtIndex:middle] hyperOrderWeight]];
                    if (result == NSOrderedAscending) {
                        high = middle;
                    }
                    else if (result == NSOrderedDescending) {
                        low = middle;
                    }
                    else if (result == NSOrderedSame) {
                        if (aObject != NULL) {
                            *aObject = YES;
                        }
                        return middle;
                    }
                }
            }
            if (aObject != NULL) {
                *aObject = NO;
            }
            return high;
        }
    }
    if (aObject != NULL) {
        *aObject = NO;
    }
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00298c78 @ 00298c78, 1404 bytes * /

void FUN_00298c78(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 id HSArduinoWatcherActionAssistantPane_objectAttributeDidChange)

{
  bool bVar1;
  bool bVar2;
  id pvVar3;
  id pvVar4;
  undefined *self_00;
  undefined *puVar5;
  int iVar6;
  undefined *puVar7;
  undefined *puVar8;
  id self_01;
  undefined *puVar9;
  undefined4 uVar10;
  char *pcVar11;
  char local_12;
  char local_11;
  
  pvVar3 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_objectAttributeDidChange,sel_object);
  pvVar4 = _objc_msgSend(*(id *)((int)&self->_availableObjectsOnCards + 3),sel_hyperObject);
  if (pvVar3 == pvVar4) {
    return;
  }
  pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388c00);
  pvVar4 = _objc_msgSend(pvVar4,sel_card);
  puVar8 = &DAT_00388cb4;
  self_00 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00388cb4);
  if (self_00 == (undefined *)0x0) {
    return;
  }
  puVar5 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388cb4);
  if (puVar5 == (undefined *)0x0) {
    return;
  }
  if (puVar5 == self_00) {
LAB_00298d44:
    bVar1 = true;
    bVar2 = false;
    puVar7 = puVar8;
  }
  else {
    puVar8 = &DAT_00388cdc;
    pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388cdc);
    pvVar4 = _objc_msgSend(pvVar4,sel_hyperOrderWeight);
    if (pvVar4 == (id)0x0) goto LAB_00298d44;
    iVar6 = *(int *)((int)&self->_availableCards + 3);
    if (iVar6 == 0) {
      self_01 = (id)0x0;
LAB_00298dae:
      pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388d40);
      puVar8 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_003363a8);
      pvVar4 = _objc_msgSend(pvVar4,sel_hyperActionsForEvent_,puVar8);
      pvVar4 = _objc_msgSend(pvVar4,sel_count);
      if (pvVar4 == (id)0x0) goto LAB_00298d44;
      if (*(int *)((int)&self->_availableCards + 3) == 0) {
        puVar8 = PTR_00336510;
        iVar6 = _CFDictionaryCreateMutable(*(undefined4 *)PTR_003363a4,0,PTR_00336510,PTR_00336514);
        *(int *)((int)&self->_availableCards + 3) = iVar6;
        if (iVar6 == 0) goto LAB_00298d44;
      }
      if (self_01 == (id)0x0) {
        self_01 = _objc_msgSend(cls_NSMutableArray,sel_array,puVar8);
        if (self_01 == (id)0x0) goto LAB_00298d44;
        _CFDictionarySetValue(*(undefined4 *)((int)&self->_availableCards + 3),self_00,self_01);
      }
      puVar9 = (undefined *)0x0;
LAB_00298fc0:
      puVar7 = puVar5;
      _objc_msgSend(self_01,sel_insertObject_atIndex_,puVar5,puVar9);
      bVar1 = true;
      bVar2 = true;
    }
    else {
      self_01 = (id)_CFDictionaryGetValue(iVar6,self_00);
      if (self_01 == (id)0x0) goto LAB_00298dae;
      local_11 = '\0';
      puVar7 = _objc_msgSend(self,
                             sel_HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight_toArray_containsObject_
                             ,pvVar4,self_01,&local_11);
      pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388d40);
      puVar8 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_003363a8);
      pvVar4 = _objc_msgSend(pvVar4,sel_hyperActionsForEvent_,puVar8);
      pvVar4 = _objc_msgSend(pvVar4,sel_count);
      if (pvVar4 != (id)0x0) {
        puVar9 = puVar7;
        if (local_11 != '\0') goto LAB_00298d44;
        goto LAB_00298fc0;
      }
      if (local_11 == '\0') goto LAB_00298d44;
      _objc_msgSend(self_01,sel_removeObjectAtIndex_,puVar7);
      bVar1 = false;
      bVar2 = true;
    }
  }
  pvVar4 = _objc_msgSend(self->_currentCardObjectsCheckBox,sel_state,puVar7);
  if ((pvVar4 == (id)0x1) || ((puVar5 != self_00 && (!bVar2)))) {
LAB_002990f0:
    if (bVar1) goto LAB_002991ad;
  }
  else {
    puVar7 = &DAT_00388cdc;
    pvVar4 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_00388cdc);
    pvVar4 = _objc_msgSend(pvVar4,sel_hyperOrderWeight);
    if (pvVar4 == (id)0x0) goto LAB_002990f0;
    local_12 = '\0';
    uVar10 = *(undefined4 *)((int)&self->_isFinished + 3);
    pcVar11 = &local_12;
    puVar8 = _objc_msgSend(self,
                           sel_HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight_toArray_containsObject_
                           ,pvVar4,uVar10,pcVar11);
    puVar7 = self_00;
    pvVar4 = _objc_msgSend(self,sel_HSArduinoWatcherActionAssistantPane_hasActionsOnCard_,self_00);
    if ((char)pvVar4 != '\0') {
      if (local_12 == '\0') {
        _objc_msgSend(*(id *)((int)&self->_isFinished + 3),sel_insertObject_atIndex_,self_00,puVar8,
                      pcVar11);
        puVar8 = self_00;
LAB_002990ee:
        bVar2 = true;
        puVar7 = puVar8;
      }
      goto LAB_002990f0;
    }
    if (local_12 == '\0') goto LAB_002990f0;
    _objc_msgSend(*(id *)((int)&self->_isFinished + 3),sel_removeObjectAtIndex_,puVar8,uVar10,
                  pcVar11);
    if (puVar5 != self_00) goto LAB_002990ee;
    bVar2 = true;
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388dcc);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperUID);
  pvVar3 = _objc_msgSend(pvVar3,sel_stringValue);
  puVar7 = self->_selectedObjectUID;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,puVar7);
  if ((char)pvVar3 != '\0') {
    _objc_msgSend(self->_configurationPane,sel_dismiss_,1);
    puVar7 = self->_configurationPane;
    _objc_msgSend(self,sel_actionPaneDidClose_withApplier_canceled_,puVar7,0,1);
  }
LAB_002991ad:
  if ((bVar2) && (pvVar3 = _objc_msgSend(self,sel_isVisible,puVar7), (char)pvVar3 != '\0')) {
    _objc_msgSend(self->_pinConfigurationRangeMappingsOutlineView,sel_reloadData,puVar7);
  }
  return;
}

*/
- (void)HSArduinoWatcherActionAssistantPane_objectAttributeDidChange:(id)aChange
{
    id object;
    id card;
    id objectNode;
    id weight;
    NSMutableArray *objects;
    NSUInteger index;
    BOOL contains;
    BOOL hasActions;
    BOOL listed;
    BOOL changed;

    object = [aChange object];
    if (object == [_currentObject hyperObject]) {
        return;
    }
    card = [[[object queryHyperInterface:@protocol(HSUserObjectSupport)] card] queryHyperInterface:@protocol(HSNodeContainer)];
    if (card == nil) {
        return;
    }
    objectNode = [object queryHyperInterface:@protocol(HSNodeContainer)];
    if (objectNode == nil) {
        return;
    }
    // listed: the object is still shown; changed: the outline needs reloading.
    listed = YES;
    changed = NO;
    weight = nil;
    if (objectNode != card) {
        weight = [[object queryHyperInterface:@protocol(HSNodeChild)] hyperOrderWeight];
    }
    if (weight != nil) {
        objects = _availableObjectsOnCards != NULL ? (id)CFDictionaryGetValue(_availableObjectsOnCards, card) : nil;
        hasActions = [[[object queryHyperInterface:@protocol(HSActor)] hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] count] != 0;
        if (objects == nil) {
            if (hasActions) {
                if (_availableObjectsOnCards == NULL) {
                    _availableObjectsOnCards = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
                }
                if (_availableObjectsOnCards != NULL) {
                    objects = [NSMutableArray array];
                    if (objects != nil) {
                        CFDictionarySetValue(_availableObjectsOnCards, card, objects);
                        [objects insertObject:objectNode atIndex:0];
                        changed = YES;
                    }
                }
            }
        }
        else {
            contains = NO;
            index = [self HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight:weight toArray:objects containsObject:&contains];
            if (hasActions) {
                if (!contains) {
                    [objects insertObject:objectNode atIndex:index];
                    changed = YES;
                }
            }
            else if (contains) {
                [objects removeObjectAtIndex:index];
                listed = NO;
                changed = YES;
            }
        }
    }
    if ([_currentCardObjectsCheckBox state] != NSControlStateValueOn && (objectNode == card || changed)) {
        // The card itself may have to enter or leave the card list.
        weight = [[card queryHyperInterface:@protocol(HSNodeChild)] hyperOrderWeight];
        if (weight != nil) {
            contains = NO;
            index = [self HSArduinoWatcherActionAssistantPane_indexToInsertObjectWithWeight:weight toArray:_availableCards containsObject:&contains];
            if ([self HSArduinoWatcherActionAssistantPane_hasActionsOnCard:card]) {
                if (!contains) {
                    [_availableCards insertObject:card atIndex:index];
                    changed = YES;
                }
            }
            else if (contains) {
                [_availableCards removeObjectAtIndex:index];
                changed = YES;
                if (objectNode == card) {
                    listed = NO;
                }
            }
        }
    }
    if (!listed && [[[[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] stringValue] isEqualToString:_selectedObjectUID]) {
        [_configurationPane dismiss:YES];
        [self actionPaneDidClose:_configurationPane withApplier:nil canceled:YES];
    }
    if (changed && [self isVisible]) {
        [_pinConfigurationRangeMappingsOutlineView reloadData];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002991f4 @ 002991f4, 67 bytes * /

void FUN_002991f4(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 id 
                 HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWasUndoneOrRedone)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,
                          sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                         );
  _objc_msgSend(self_00,sel_resetPinConfigurationRangeMappings);
  self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] =
       self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] & 0xfe;
  return;
}

*/
- (void)HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWasUndoneOrRedone:(id)aRedone
{
    [[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] resetPinConfigurationRangeMappings];
    _arePinConfigurationRangeMappingsBeingUndoneOrRedone = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00299237 @ 00299237, 65 bytes * /

void FUN_00299237(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 id 
                 HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWillBeUndoneOrRedone
                 )

{
  id self_00;
  
  self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] =
       self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone[0] | 1;
  self_00 = _objc_msgSend(self,
                          sel_HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
                         );
  _objc_msgSend(self_00,sel_restorePinConfigurationRangeMappings);
  return;
}

*/
- (void)HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWillBeUndoneOrRedone:(id)aRedone
{
    _arePinConfigurationRangeMappingsBeingUndoneOrRedone = YES;
    [[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] restorePinConfigurationRangeMappings];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00299278 @ 00299278, 411 bytes * /

void FUN_00299278(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 id HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsDidChange)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  SEL op;
  
  if (((*(uint *)self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone & 1) == 0) &&
     ((*(uint *)self->_arePinConfigurationRangeMappingsBeingUndoneOrRedone & 2) == 0)) {
    pvVar1 = _objc_msgSend(self,sel_isVisible);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self->_pinConfigurationRangeMappingsOutlineView,sel_reloadData);
    }
    if (self->_selectedObjectUID != (id)0x0) {
      pvVar1 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsDidChange
                             ,sel_userInfo);
      pcVar3 = &cfstr_objectUID;
      pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_objectUID);
      if (pvVar2 == (id)0x0) {
        pvVar1 = self->_configurationPane;
        op = sel_notePinConfigurationRangesChanged;
      }
      else {
        pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,self->_selectedObjectUID);
        if ((char)pvVar2 == '\0') {
          return;
        }
        pcVar3 = &cfstr_digitalPin;
        pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_digitalPin);
        if (pvVar2 == (id)0x0) {
          pcVar3 = &cfstr_analogPin;
          pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_analogPin);
          pvVar1 = self->_configurationPane;
          op = sel_notePinConfigurationRangesChanged;
          if (pvVar2 != (id)0x0) {
            pvVar2 = _objc_msgSend(pvVar2,sel_unsignedCharValue,pcVar3);
            pcVar3 = (cfstringStruct *)((uint)pvVar2 & 0xff);
            op = sel_notePinConfigurationRangeChangedForPin_isPinDigital_;
          }
        }
        else {
          pvVar1 = self->_configurationPane;
          pvVar2 = _objc_msgSend(pvVar2,sel_unsignedCharValue,pcVar3);
          pcVar3 = (cfstringStruct *)((uint)pvVar2 & 0xff);
          op = sel_notePinConfigurationRangeChangedForPin_isPinDigital_;
        }
      }
      _objc_msgSend(pvVar1,op,pcVar3);
    }
  }
  return;
}

*/
- (void)HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsDidChange:(id)aChange
{
    NSDictionary *userInfo;
    id objectUID;
    id pin;

    if (_arePinConfigurationRangeMappingsBeingUndoneOrRedone || _isFinished) {
        return;
    }
    if ([self isVisible]) {
        [_pinConfigurationRangeMappingsOutlineView reloadData];
    }
    if (_selectedObjectUID == nil) {
        return;
    }
    userInfo = [aChange userInfo];
    objectUID = [userInfo objectForKey:@"objectUID"];
    if (objectUID == nil) {
        [_configurationPane notePinConfigurationRangesChanged];
        return;
    }
    if (![objectUID isEqualToString:_selectedObjectUID]) {
        return;
    }
    pin = [userInfo objectForKey:@"digitalPin"];
    if (pin != nil) {
        [_configurationPane notePinConfigurationRangeChangedForPin:[pin unsignedCharValue] isPinDigital:YES];
        return;
    }
    pin = [userInfo objectForKey:@"analogPin"];
    if (pin != nil) {
        [_configurationPane notePinConfigurationRangeChangedForPin:[pin unsignedCharValue] isPinDigital:NO];
    }
    else {
        [_configurationPane notePinConfigurationRangesChanged];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00299413 @ 00299413, 859 bytes * /

void FUN_00299413(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 id HSArduinoWatcherActionAssistantPane_objectsWillChange)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined *puVar6;
  undefined1 *puVar7;
  undefined4 uVar8;
  id local_7c;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  puVar6 = &DAT_00388cdc;
  pvVar2 = _objc_msgSend(*(id *)((int)&self->_availableObjectsOnCards + 3),sel_queryHyperInterface_,
                         &DAT_00388cdc);
  if (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_objectsWillChange,sel_object,puVar6);
    pvVar4 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_objectsWillChange,sel_userInfo);
    pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_,&cfstr_HSNodeChildrenForRemoval);
    pvVar5 = _objc_msgSend(pvVar4,sel_containsObject_,pvVar2);
    if ((char)pvVar5 == '\0') {
      pvVar5 = _objc_msgSend(self->_currentCardObjectsCheckBox,sel_state,pvVar2);
      if ((pvVar5 == (id)0x1) && (pvVar5 = _objc_msgSend(self,sel_card,pvVar2), pvVar3 != pvVar5)) {
        return;
      }
      pvVar5 = _objc_msgSend(self,sel_isVisible,pvVar2);
      if ((char)pvVar5 != '\0') {
        _objc_msgSend(self->_pinConfigurationRangeMappingsOutlineView,sel_reloadData,pvVar2);
      }
      if (((self->_selectedObjectUID != (id)0x0) && (pvVar3 == self->_selectedObjectCard)) &&
         (pvVar4 != (id)0x0)) {
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        puVar7 = local_50;
        uVar8 = 0x10;
        local_7c = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_74,
                                 puVar7,0x10);
        if (local_7c != (id)0x0) {
          iVar1 = *local_6c;
          do {
            pvVar2 = (id)0x0;
            do {
              if (iVar1 != *local_6c) {
                _objc_enumerationMutation(pvVar4);
              }
              pvVar3 = *(id *)(local_70 + (int)pvVar2 * 4);
              pvVar5 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00388dcc,puVar7,uVar8);
              pvVar5 = _objc_msgSend(pvVar5,sel_hyperUID);
              pvVar5 = _objc_msgSend(pvVar5,sel_stringValue);
              pvVar5 = _objc_msgSend(pvVar5,sel_isEqualToString_,self->_selectedObjectUID);
              if ((char)pvVar5 != '\0') {
                if (pvVar3 == (id)0x0) {
                  return;
                }
                _objc_msgSend(self->_configurationPane,sel_dismiss_,1);
                pvVar2 = self->_configurationPane;
                goto LAB_0029952e;
              }
              pvVar2 = (id)((int)pvVar2 + 1);
            } while (pvVar2 < local_7c);
            puVar7 = local_50;
            uVar8 = 0x10;
            local_7c = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_74
                                     ,puVar7,0x10);
          } while (local_7c != (id)0x0);
        }
      }
    }
    else {
      pvVar2 = _objc_msgSend(self,sel_stack,pvVar2);
      _objc_msgSend(self,sel_HSArduinoWatcherActionAssistantPane_removeObserversFromStack_,pvVar2);
      if (self->_selectedObjectUID != (id)0x0) {
        _objc_msgSend(self->_configurationPane,sel_dismiss_,1);
        pvVar2 = self->_configurationPane;
LAB_0029952e:
        _objc_msgSend(self,sel_actionPaneDidClose_withApplier_canceled_,pvVar2,0,1);
      }
    }
  }
  return;
}

*/
- (void)HSArduinoWatcherActionAssistantPane_objectsWillChange:(id)aChange
{
    id current;
    id changedNode;
    id removed;
    id node;

    current = [_currentObject queryHyperInterface:@protocol(HSNodeChild)];
    if (current == nil) {
        return;
    }
    changedNode = [aChange object];
    removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if ([removed containsObject:current]) {
        [self HSArduinoWatcherActionAssistantPane_removeObserversFromStack:[self stack]];
        if (_selectedObjectUID != nil) {
            [_configurationPane dismiss:YES];
            [self actionPaneDidClose:_configurationPane withApplier:nil canceled:YES];
        }
        return;
    }
    if ([_currentCardObjectsCheckBox state] == NSControlStateValueOn && changedNode != [self card]) {
        return;
    }
    if ([self isVisible]) {
        [_pinConfigurationRangeMappingsOutlineView reloadData];
    }
    if (_selectedObjectUID != nil && changedNode == _selectedObjectCard && removed != nil) {
        for (node in removed) {
            if ([[[[node queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] stringValue] isEqualToString:_selectedObjectUID]) {
                [_configurationPane dismiss:YES];
            [self actionPaneDidClose:_configurationPane withApplier:nil canceled:YES];
                return;
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029976e @ 0029976e, 661 bytes * /

void FUN_0029976e(HSArduinoWatcherActionAssistantPane *self,SEL _cmd,
                 id HSArduinoWatcherActionAssistantPane_cardsDidChange)

{
  int iVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined1 *puVar6;
  undefined4 uVar7;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_cardsDidChange,sel_userInfo);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSNodeChildrenForRemoval);
  uVar7 = *(undefined4 *)((int)&self->_availableObjectsOnCards + 3);
  pvVar3 = _objc_msgSend(pvVar2,sel_containsObject_,uVar7);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(self->_currentCardObjectsCheckBox,sel_state,uVar7);
    if (pvVar3 != (id)0x1) {
      pvVar3 = _objc_msgSend(self,sel_isVisible,uVar7);
      if ((char)pvVar3 != '\0') {
        _objc_msgSend(self->_pinConfigurationRangeMappingsOutlineView,sel_reloadData,uVar7);
      }
      if ((self->_selectedObjectUID != (id)0x0) && (pvVar2 != (id)0x0)) {
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        puVar6 = local_50;
        uVar7 = 0x10;
        pvVar3 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,
                               puVar6,0x10);
        if (pvVar3 != (id)0x0) {
          iVar1 = *local_6c;
          do {
            pvVar5 = (id)0x0;
            do {
              if (iVar1 != *local_6c) {
                _objc_enumerationMutation(pvVar2);
              }
              self_00 = *(id *)(local_70 + (int)pvVar5 * 4);
              pvVar4 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_00388cb4,puVar6,uVar7);
              if (pvVar4 == self->_selectedObjectCard) {
                if (self_00 == (id)0x0) {
                  return;
                }
                goto LAB_002999a6;
              }
              pvVar5 = (id)((int)pvVar5 + 1);
            } while (pvVar5 < pvVar3);
            puVar6 = local_50;
            uVar7 = 0x10;
            pvVar3 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,
                                   puVar6,0x10);
          } while (pvVar3 != (id)0x0);
        }
      }
    }
  }
  else {
    pvVar2 = _objc_msgSend(HSArduinoWatcherActionAssistantPane_cardsDidChange,sel_object,uVar7);
    _objc_msgSend(self,sel_HSArduinoWatcherActionAssistantPane_removeObserversFromStack_,pvVar2);
    if (self->_selectedObjectUID != (id)0x0) {
LAB_002999a6:
      _objc_msgSend(self->_configurationPane,sel_dismiss_,1);
      _objc_msgSend(self,sel_actionPaneDidClose_withApplier_canceled_,self->_configurationPane,0,1);
    }
  }
  return;
}

*/
- (void)HSArduinoWatcherActionAssistantPane_cardsDidChange:(id)aChange
{
    id removed;
    id node;

    removed = [[aChange userInfo] objectForKey:@"HSNodeChildrenForRemoval"];
    if ([removed containsObject:_currentObject]) {
        [self HSArduinoWatcherActionAssistantPane_removeObserversFromStack:[aChange object]];
        if (_selectedObjectUID != nil) {
            [_configurationPane dismiss:YES];
            [self actionPaneDidClose:_configurationPane withApplier:nil canceled:YES];
        }
        return;
    }
    if ([_currentCardObjectsCheckBox state] == NSControlStateValueOn) {
        return;
    }
    if ([self isVisible]) {
        [_pinConfigurationRangeMappingsOutlineView reloadData];
    }
    if (_selectedObjectUID != nil && removed != nil) {
        for (node in removed) {
            if ([node queryHyperInterface:@protocol(HSNodeContainer)] == _selectedObjectCard) {
                [_configurationPane dismiss:YES];
            [self actionPaneDidClose:_configurationPane withApplier:nil canceled:YES];
                return;
            }
        }
    }
}

- (void)HSArduinoWatcherActionAssistantPane_removeObserversFromStack:(id)aStack
{
    int uVar1;
    id pvVar2_3;

    uVar1 = HSActualDidAttributeChanges;
    [aStack removeObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_cardsDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [aStack removeObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [aStack removeObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_objectAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSActionsAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
    [aStack removeObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_objectNameDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSCardTitleAttribute)];
    [aStack removeObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_objectNameDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSObjectNameAttribute) ofChildrenInDepthRange:NSMakeRange(1, 1)];
    pvVar2_3 = [[[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] arduinoWatcherActionAttributes] attributeObservingController];
    [pvVar2_3 removeObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute)];
    [pvVar2_3 removeObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute)];
    [pvVar2_3 removeObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute)];
}

- (void)HSArduinoWatcherActionAssistantPane_addObservers
{
    int uVar1;
    id pvVar2;
    id pvVar2_4;

    pvVar2 = [self stack];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2 addObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_cardsDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [pvVar2 addObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [pvVar2 addObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_objectAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSActionsAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2) withPriority:-0.25];
    [pvVar2 addObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_objectNameDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSCardTitleAttribute) withPriority:-0.25];
    [pvVar2 addObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_objectNameDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSObjectNameAttribute) ofChildrenInDepthRange:NSMakeRange(1, 1) withPriority:-0.25];
    pvVar2_4 = [[[self HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier] arduinoWatcherActionAttributes] attributeObservingController];
    [pvVar2_4 addObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute) withPriority:-0.25];
    [pvVar2_4 addObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute) withPriority:-0.25];
    [pvVar2_4 addObserver:self selector:@selector(HSArduinoWatcherActionAssistantPane_pinConfigurationRangeMappingsWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSArduinoPinConfigurationRangeMappingsAttribute) withPriority:-0.25];
}

- (id)HSArduinoWatcherActionAssistantPane_arduinoWatcherActionAssistantPaneApplier
{
    return [self applier];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00299eb9 @ 00299eb9, 74 bytes * /

id FUN_00299eb9(HSArduinoWatcherActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(*(id *)((int)&self->_availableObjectsOnCards + 3),sel_queryHyperInterface_,
                         &DAT_00388c00);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  return pvVar1;
}

*/
- (id)stack
{
    return [[_currentObject queryHyperInterface:@protocol(HSUserObjectSupport)] stack];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00299f03 @ 00299f03, 74 bytes * /

id FUN_00299f03(HSArduinoWatcherActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(*(id *)((int)&self->_availableObjectsOnCards + 3),sel_queryHyperInterface_,
                         &DAT_00388c00);
  pvVar1 = _objc_msgSend(pvVar1,sel_card);
  return pvVar1;
}

*/
- (id)card
{
    return [[_currentObject queryHyperInterface:@protocol(HSUserObjectSupport)] card];
}

- (void)viewDidLoad
{
    NSTableColumn *pvVar1;
    id pvVar2;

    [super viewDidLoad];
    if (NSAppKitVersionNumber <= 949.0 && NSAppKitVersionNumber != 949.0) {
        pvVar2 = _pinConfigurationRangeMappingsOutlineView;
        pvVar1 = [pvVar2 tableColumnWithIdentifier:@"object"];
        [pvVar2 setOutlineTableColumn:pvVar1];
    }
    pvVar2 = [[HSSwitchCell new] autorelease];
    if (pvVar2 != nil) {
        [pvVar2 setControlSize:1];
        [pvVar2 setLineBreakMode:4];
        [pvVar2 applyDefaultSettings];
        pvVar1 = [_pinConfigurationRangeMappingsOutlineView outlineTableColumn];
        [pvVar1 setDataCell:pvVar2];
    }
}

- (void)dealloc
{
    [_configurationPane setDelegate:0];
    [_configurationPane setDataSource:0];
    [_configurationPane release];
    [_objectNameParagraphStyle release];
    [_pinConfigurationRangesButtonBackgroundRenderer release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ArduinoWatcherAssistantPane"];
    return self;
}

@end

@implementation HSArduinoWatcherActionAssistantPaneApplier

/* i386 ivar offsets: _initialDigitalPinConfigurationRangeMappings=0x30, _currentDigitalPinConfigurationRangeMappings=0x34, _initialAnalogPinConfigurationRangeMappings=0x38, _currentAnalogPinConfigurationRangeMappings=0x3c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029651e @ 0029651e, 292 bytes * /

void FUN_0029651e(HSArduinoWatcherActionAssistantPaneApplier *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  CFDictionary *pCVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  
  self_00 = _objc_msgSend(self,sel_arduinoWatcherActionAttributes);
  if (self->_initialDigitalPinConfigurationRangeMappings != (CFDictionary *)0x0) {
    _CFRelease(self->_initialDigitalPinConfigurationRangeMappings);
  }
  pvVar1 = _objc_msgSend(self,sel_arduinoWatcherActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_digitalPinConfigurationRangeMappings);
  uVar4 = 0;
  uVar3 = 1;
  pCVar2 = _objc_msgSend(pvVar1,sel_NSE_copyToDepth_zone_,1,0);
  self->_initialDigitalPinConfigurationRangeMappings = pCVar2;
  if (self->_initialAnalogPinConfigurationRangeMappings != (CFDictionary *)0x0) {
    _CFRelease(self->_initialAnalogPinConfigurationRangeMappings);
  }
  pvVar1 = _objc_msgSend(self,sel_arduinoWatcherActionAttributes,uVar3,uVar4);
  pvVar1 = _objc_msgSend(pvVar1,sel_analogPinConfigurationRangeMappings);
  pCVar2 = _objc_msgSend(pvVar1,sel_NSE_copyToDepth_zone_,1,0);
  self->_initialAnalogPinConfigurationRangeMappings = pCVar2;
  _objc_msgSend(self,sel_disableUndo);
  _objc_msgSend(self_00,
                sel_setDigitalPinConfigurationRangeMappings_analogPinConfigurationRangeMappings_,
                self->_currentDigitalPinConfigurationRangeMappings,
                self->_currentAnalogPinConfigurationRangeMappings);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)resetPinConfigurationRangeMappings
{
    id attributes;

    attributes = [self arduinoWatcherActionAttributes];
    if (_initialDigitalPinConfigurationRangeMappings != NULL) {
        CFRelease(_initialDigitalPinConfigurationRangeMappings);
    }
    _initialDigitalPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)[[self arduinoWatcherActionAttributes] digitalPinConfigurationRangeMappings] NSE_copyToDepth:1 zone:NULL];
    if (_initialAnalogPinConfigurationRangeMappings != NULL) {
        CFRelease(_initialAnalogPinConfigurationRangeMappings);
    }
    _initialAnalogPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)[[self arduinoWatcherActionAttributes] analogPinConfigurationRangeMappings] NSE_copyToDepth:1 zone:NULL];
    [self disableUndo];
    [attributes setDigitalPinConfigurationRangeMappings:_currentDigitalPinConfigurationRangeMappings analogPinConfigurationRangeMappings:_currentAnalogPinConfigurationRangeMappings];
    [self enableUndo];
}

- (void)restorePinConfigurationRangeMappings
{
    [self disableUndo];
    [[self arduinoWatcherActionAttributes] setDigitalPinConfigurationRangeMappings:_initialDigitalPinConfigurationRangeMappings analogPinConfigurationRangeMappings:_initialAnalogPinConfigurationRangeMappings];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002966bb @ 002966bb, 211 bytes * /

void FUN_002966bb(HSArduinoWatcherActionAssistantPaneApplier *self,SEL _cmd,
                 id synchronizePinConfigurationRangesForObjectWithUID)

{
  id pvVar1;
  int iVar2;
  id self_00;
  SEL op;
  
  if (self->_currentDigitalPinConfigurationRangeMappings == (CFDictionary *)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = (id)_CFDictionaryGetValue
                           (self->_currentDigitalPinConfigurationRangeMappings,
                            synchronizePinConfigurationRangesForObjectWithUID);
  }
  if (self->_currentAnalogPinConfigurationRangeMappings == (CFDictionary *)0x0) {
    iVar2 = 0;
  }
  else {
    iVar2 = _CFDictionaryGetValue
                      (self->_currentAnalogPinConfigurationRangeMappings,
                       synchronizePinConfigurationRangesForObjectWithUID);
  }
  _objc_msgSend(self,sel_disableUndo);
  self_00 = _objc_msgSend(self,sel_arduinoWatcherActionAttributes);
  op = sel_setDigitalPinConfigurationRanges_analogPinConfigurationRanges_forObjectWithUID_;
  if (pvVar1 == (id)0x0 && iVar2 == 0) {
    op = sel_removePinConfigurationRangesForObjectWithUID_;
    pvVar1 = synchronizePinConfigurationRangesForObjectWithUID;
  }
  _objc_msgSend(self_00,op,pvVar1);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)synchronizePinConfigurationRangesForObjectWithUID:(id)aUID
{
    id digitalRanges;
    id analogRanges;

    digitalRanges = _currentDigitalPinConfigurationRangeMappings != NULL ? (id)CFDictionaryGetValue(_currentDigitalPinConfigurationRangeMappings, aUID) : nil;
    analogRanges = _currentAnalogPinConfigurationRangeMappings != NULL ? (id)CFDictionaryGetValue(_currentAnalogPinConfigurationRangeMappings, aUID) : nil;
    [self disableUndo];
    if (digitalRanges == nil && analogRanges == nil) {
        [[self arduinoWatcherActionAttributes] removePinConfigurationRangesForObjectWithUID:aUID];
    }
    else {
        [[self arduinoWatcherActionAttributes] setDigitalPinConfigurationRanges:(CFMutableDictionaryRef)digitalRanges analogPinConfigurationRanges:(CFMutableDictionaryRef)analogRanges forObjectWithUID:aUID];
    }
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029678e @ 0029678e, 55 bytes * /

void FUN_0029678e(HSArduinoWatcherActionAssistantPaneApplier *self,SEL _cmd,
                 id removePinConfigurationRangesForObjectWithUID)

{
  if (self->_currentDigitalPinConfigurationRangeMappings != (CFDictionary *)0x0) {
    _CFDictionaryRemoveValue
              (self->_currentDigitalPinConfigurationRangeMappings,
               removePinConfigurationRangesForObjectWithUID);
    _CFDictionaryRemoveValue
              (self->_currentAnalogPinConfigurationRangeMappings,
               removePinConfigurationRangesForObjectWithUID);
  }
  return;
}

*/
- (void)removePinConfigurationRangesForObjectWithUID:(id)aUID
{
    if (_currentDigitalPinConfigurationRangeMappings != NULL) {
        CFDictionaryRemoveValue(_currentDigitalPinConfigurationRangeMappings, aUID);
        CFDictionaryRemoveValue(_currentAnalogPinConfigurationRangeMappings, aUID);
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002967c5 @ 002967c5, 191 bytes * /

void FUN_002967c5(HSArduinoWatcherActionAssistantPaneApplier *self,SEL _cmd,
                 CFDictionary *setDigitalPinConfigurationRanges,
                 CFDictionary *analogPinConfigurationRanges,id forObjectWithUID)

{
  undefined4 uVar1;
  undefined *puVar2;
  undefined *puVar3;
  CFDictionary *pCVar4;
  CFDictionary *pCVar5;
  
  puVar3 = PTR_00336a14;
  puVar2 = PTR_00336514;
  pCVar4 = self->_currentDigitalPinConfigurationRangeMappings;
  if (pCVar4 == (CFDictionary *)0x0) {
    uVar1 = *(undefined4 *)PTR_003363a4;
    pCVar4 = (CFDictionary *)_CFDictionaryCreateMutable(uVar1,0,PTR_00336a14,PTR_00336514);
    self->_currentDigitalPinConfigurationRangeMappings = pCVar4;
    if (pCVar4 == (CFDictionary *)0x0) {
      return;
    }
    pCVar5 = (CFDictionary *)_CFDictionaryCreateMutable(uVar1,0,puVar3,puVar2);
    self->_currentAnalogPinConfigurationRangeMappings = pCVar5;
    pCVar4 = self->_currentDigitalPinConfigurationRangeMappings;
    if (pCVar5 == (CFDictionary *)0x0) {
      _CFRelease(pCVar4);
      self->_currentDigitalPinConfigurationRangeMappings = (CFDictionary *)0x0;
      return;
    }
  }
  _CFDictionarySetValue(pCVar4,forObjectWithUID,setDigitalPinConfigurationRanges);
  _CFDictionarySetValue
            (self->_currentAnalogPinConfigurationRangeMappings,forObjectWithUID,
             analogPinConfigurationRanges);
  return;
}

*/
- (void)setDigitalPinConfigurationRanges:(struct __CFDictionary *)aRanges analogPinConfigurationRanges:(struct __CFDictionary *)aRanges2 forObjectWithUID:(id)aUID
{
    if (_currentDigitalPinConfigurationRangeMappings == NULL) {
        _currentDigitalPinConfigurationRangeMappings = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_currentDigitalPinConfigurationRangeMappings == NULL) {
            return;
        }
        _currentAnalogPinConfigurationRangeMappings = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_currentAnalogPinConfigurationRangeMappings == NULL) {
            CFRelease(_currentDigitalPinConfigurationRangeMappings);
            _currentDigitalPinConfigurationRangeMappings = NULL;
            return;
        }
    }
    CFDictionarySetValue(_currentDigitalPinConfigurationRangeMappings, aUID, aRanges);
    CFDictionarySetValue(_currentAnalogPinConfigurationRangeMappings, aUID, aRanges2);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00296884 @ 00296884, 184 bytes * /

BOOL FUN_00296884(HSArduinoWatcherActionAssistantPaneApplier *self,SEL _cmd)

{
  CFDictionary *pCVar1;
  BOOL BVar2;
  id pvVar3;
  int iVar4;
  CFDictionary *pCVar5;
  char cVar6;
  bool bVar7;
  HSArduinoWatcherActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00356900;
  pvVar3 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if ((char)pvVar3 == '\0') {
LAB_002968b9:
    bVar7 = false;
  }
  else {
    pCVar5 = self->_initialDigitalPinConfigurationRangeMappings;
    pCVar1 = self->_currentDigitalPinConfigurationRangeMappings;
    if (pCVar1 == (CFDictionary *)0x0) {
      if ((pCVar5 != (CFDictionary *)0x0) && (iVar4 = _CFDictionaryGetCount(pCVar5), iVar4 != 0))
      goto LAB_002968b9;
    }
    else {
      if (pCVar5 == (CFDictionary *)0x0) {
        iVar4 = _CFDictionaryGetCount(pCVar1);
        cVar6 = iVar4 == 0;
      }
      else {
        cVar6 = _CFEqual(pCVar5,pCVar1);
      }
      if (cVar6 == '\0') {
        return '\0';
      }
    }
    pCVar5 = self->_currentAnalogPinConfigurationRangeMappings;
    if (pCVar5 == (CFDictionary *)0x0) {
      pCVar5 = self->_initialAnalogPinConfigurationRangeMappings;
      if (pCVar5 == (CFDictionary *)0x0) {
        return '\x01';
      }
    }
    else if (self->_initialDigitalPinConfigurationRangeMappings != (CFDictionary *)0x0) {
      BVar2 = _CFEqual(self->_initialDigitalPinConfigurationRangeMappings,pCVar5);
      return BVar2;
    }
    iVar4 = _CFDictionaryGetCount(pCVar5);
    bVar7 = iVar4 == 0;
  }
  return bVar7;
}

*/
- (BOOL)areSettingsEqual
{
    if (![super areSettingsEqual]) {
        return NO;
    }
    if (_currentDigitalPinConfigurationRangeMappings == NULL) {
        if (_initialDigitalPinConfigurationRangeMappings != NULL && CFDictionaryGetCount(_initialDigitalPinConfigurationRangeMappings) != 0) {
            return NO;
        }
    }
    else if (_initialDigitalPinConfigurationRangeMappings == NULL) {
        if (CFDictionaryGetCount(_currentDigitalPinConfigurationRangeMappings) != 0) {
            return NO;
        }
    }
    else if (!CFEqual(_initialDigitalPinConfigurationRangeMappings, _currentDigitalPinConfigurationRangeMappings)) {
        return NO;
    }
    if (_currentAnalogPinConfigurationRangeMappings == NULL) {
        if (_initialAnalogPinConfigurationRangeMappings == NULL) {
            return YES;
        }
        return CFDictionaryGetCount(_initialAnalogPinConfigurationRangeMappings) == 0;
    }
    if (_initialDigitalPinConfigurationRangeMappings != NULL) {
        // The original compares the initial digital mappings with the current
        // analog ones here, so analog-only edits rarely compare as equal.
        return CFEqual(_initialDigitalPinConfigurationRangeMappings, _currentAnalogPinConfigurationRangeMappings);
    }
    return CFDictionaryGetCount(_currentAnalogPinConfigurationRangeMappings) == 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029693c @ 0029693c, 167 bytes * /

void FUN_0029693c(HSArduinoWatcherActionAssistantPaneApplier *self,SEL _cmd)

{
  CFDictionary *pCVar1;
  HSArduinoWatcherActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  if (self->_currentDigitalPinConfigurationRangeMappings != (CFDictionary *)0x0) {
    _CFRelease(self->_currentDigitalPinConfigurationRangeMappings);
  }
  pCVar1 = _objc_msgSend(self->_initialDigitalPinConfigurationRangeMappings,
                         sel_NSE_mutableCopyToDepth_zone_,1,0);
  self->_currentDigitalPinConfigurationRangeMappings = pCVar1;
  if (self->_currentAnalogPinConfigurationRangeMappings != (CFDictionary *)0x0) {
    _CFRelease(self->_currentAnalogPinConfigurationRangeMappings);
  }
  pCVar1 = _objc_msgSend(self->_initialAnalogPinConfigurationRangeMappings,
                         sel_NSE_mutableCopyToDepth_zone_,1,0);
  self->_currentAnalogPinConfigurationRangeMappings = pCVar1;
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00356900;
  _objc_msgSendSuper(&local_14,sel_makeCurrentEqualToInitial);
  return;
}

*/
- (void)makeCurrentEqualToInitial
{
    if (_currentDigitalPinConfigurationRangeMappings != NULL) {
        CFRelease(_currentDigitalPinConfigurationRangeMappings);
    }
    _currentDigitalPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)_initialDigitalPinConfigurationRangeMappings NSE_mutableCopyToDepth:1 zone:NULL];
    if (_currentAnalogPinConfigurationRangeMappings != NULL) {
        CFRelease(_currentAnalogPinConfigurationRangeMappings);
    }
    _currentAnalogPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)_initialAnalogPinConfigurationRangeMappings NSE_mutableCopyToDepth:1 zone:NULL];
    [super makeCurrentEqualToInitial];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002969e3 @ 002969e3, 167 bytes * /

void FUN_002969e3(HSArduinoWatcherActionAssistantPaneApplier *self,SEL _cmd)

{
  CFDictionary *pCVar1;
  HSArduinoWatcherActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  if (self->_initialDigitalPinConfigurationRangeMappings != (CFDictionary *)0x0) {
    _CFRelease(self->_initialDigitalPinConfigurationRangeMappings);
  }
  pCVar1 = _objc_msgSend(self->_currentDigitalPinConfigurationRangeMappings,
                         sel_NSE_copyToDepth_zone_,1,0);
  self->_initialDigitalPinConfigurationRangeMappings = pCVar1;
  if (self->_initialAnalogPinConfigurationRangeMappings != (CFDictionary *)0x0) {
    _CFRelease(self->_initialAnalogPinConfigurationRangeMappings);
  }
  pCVar1 = _objc_msgSend(self->_currentAnalogPinConfigurationRangeMappings,sel_NSE_copyToDepth_zone_
                         ,1,0);
  self->_initialAnalogPinConfigurationRangeMappings = pCVar1;
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00356900;
  _objc_msgSendSuper(&local_14,sel_makeInitialEqualToCurrent);
  return;
}

*/
- (void)makeInitialEqualToCurrent
{
    if (_initialDigitalPinConfigurationRangeMappings != NULL) {
        CFRelease(_initialDigitalPinConfigurationRangeMappings);
    }
    _initialDigitalPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)_currentDigitalPinConfigurationRangeMappings NSE_copyToDepth:1 zone:NULL];
    if (_initialAnalogPinConfigurationRangeMappings != NULL) {
        CFRelease(_initialAnalogPinConfigurationRangeMappings);
    }
    _initialAnalogPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)_currentAnalogPinConfigurationRangeMappings NSE_copyToDepth:1 zone:NULL];
    [super makeInitialEqualToCurrent];
}

- (void)setInitialSettingsToObject
{
    [[self arduinoWatcherActionAttributes] setDigitalPinConfigurationRangeMappings:_initialDigitalPinConfigurationRangeMappings analogPinConfigurationRangeMappings:_initialAnalogPinConfigurationRangeMappings];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [[self arduinoWatcherActionAttributes] setDigitalPinConfigurationRangeMappings:_currentDigitalPinConfigurationRangeMappings analogPinConfigurationRangeMappings:_currentAnalogPinConfigurationRangeMappings];
    [super setCurrentSettingsToObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00296b70 @ 00296b70, 244 bytes * /

void FUN_00296b70(HSArduinoWatcherActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  CFDictionary *pCVar2;
  
  pvVar1 = _objc_msgSend(self,sel_arduinoWatcherActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_digitalPinConfigurationRangeMappings);
  pCVar2 = _objc_msgSend(pvVar1,sel_NSE_copyToDepth_zone_,1,0);
  self->_initialDigitalPinConfigurationRangeMappings = pCVar2;
  pCVar2 = _objc_msgSend(pCVar2,sel_NSE_mutableCopyToDepth_zone_,1,0);
  self->_currentDigitalPinConfigurationRangeMappings = pCVar2;
  pvVar1 = _objc_msgSend(self,sel_arduinoWatcherActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_analogPinConfigurationRangeMappings);
  pCVar2 = _objc_msgSend(pvVar1,sel_NSE_copyToDepth_zone_,1,0);
  self->_initialAnalogPinConfigurationRangeMappings = pCVar2;
  pCVar2 = _objc_msgSend(pCVar2,sel_NSE_mutableCopyToDepth_zone_,1,0);
  self->_currentAnalogPinConfigurationRangeMappings = pCVar2;
  return;
}

*/
- (void)setUpInitialSettings
{
    _initialDigitalPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)[[self arduinoWatcherActionAttributes] digitalPinConfigurationRangeMappings] NSE_copyToDepth:1 zone:NULL];
    _currentDigitalPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)_initialDigitalPinConfigurationRangeMappings NSE_mutableCopyToDepth:1 zone:NULL];
    _initialAnalogPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)[[self arduinoWatcherActionAttributes] analogPinConfigurationRangeMappings] NSE_copyToDepth:1 zone:NULL];
    _currentAnalogPinConfigurationRangeMappings = (CFMutableDictionaryRef)[(NSDictionary *)_initialAnalogPinConfigurationRangeMappings NSE_mutableCopyToDepth:1 zone:NULL];
}

- (id)arduinoWatcherActionAttributes
{
    return [self actionAttributes];
}

- (void)dealloc
{
    if (_initialDigitalPinConfigurationRangeMappings != nil) {
        CFRelease(_initialDigitalPinConfigurationRangeMappings);
    }
    if (_currentDigitalPinConfigurationRangeMappings != nil) {
        CFRelease(_currentDigitalPinConfigurationRangeMappings);
    }
    if (_initialAnalogPinConfigurationRangeMappings != nil) {
        CFRelease(_initialAnalogPinConfigurationRangeMappings);
    }
    if (_currentAnalogPinConfigurationRangeMappings != nil) {
        CFRelease(_currentAnalogPinConfigurationRangeMappings);
    }
    [super dealloc];
}

@end

