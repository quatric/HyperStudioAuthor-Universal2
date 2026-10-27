#import "HSArduinoWatcherActionConfigurationAssistantPane.h"

@implementation HSArduinoWatcherActionConfigurationAssistantPane

/* i386 ivar offsets: _pinConfigurationRangesTableView=0x88, _grayStatusImage=0x8c, _greenStatusImage=0x90, _redStatusImage=0x94, _pinModePopUp=0x98, _analogPinModesMenu=0x9c, _digitalPWMPinModesMenu=0xa0, _digitalPinModesMenu=0xa4, _noPinModeMenu=0xa8, _pinValueRangeView=0xac, _noPinValueRangeView=0xb0, _digitalPinValueView=0xb4, _digitalPinValueMatrix=0xb8, _analogAndPWMPinValueRangeView=0xbc, _analogAndPWMPinStartValueTextField=0xc0, _analogAndPWMPinStartValueSpepper=0xc4, _analogAndPWMPinEndValueTextField=0xc8, _analogAndPWMPinEndValueSpepper=0xcc, _dataSource=0xd0, _modeToTitleMap=0xd4, _indicesToReload=0xd8, _isReloadScheduled=0xdc */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029a1ca @ 0029a1ca, 238 bytes * /

void FUN_0029a1ca(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,id selectPinValue)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  byte bVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_pinConfigurationRangesTableView,sel_selectedRow);
  pvVar2 = _objc_msgSend(self->_pinModePopUp,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_tag);
  pvVar3 = _objc_msgSend(selectPinValue,sel_selectedCell);
  pvVar3 = _objc_msgSend(pvVar3,sel_tag);
  if ((int)pvVar1 < 0xc) {
    self_00 = self->_dataSource;
    bVar4 = (char)pvVar1 + 2;
    op = sel_setMode_startValue_endValue_forDigitalPin_;
  }
  else {
    self_00 = self->_dataSource;
    bVar4 = (char)pvVar1 - 0xc;
    op = sel_setMode_startValue_endValue_forAnalogPin_;
  }
  _objc_msgSend(self_00,op,pvVar2,(uint)pvVar3 & 0xffff,(uint)pvVar3 & 0xffff,(uint)bVar4);
  return;
}

*/
- (void)selectPinValue:(id)aValue
{
    NSInteger row = [_pinConfigurationRangesTableView selectedRow];
    NSInteger mode = [[_pinModePopUp selectedItem] tag];
    unsigned short value = (unsigned short)[[aValue selectedCell] tag];
    if (row < 12) {
        [_dataSource setMode:mode startValue:value endValue:value forDigitalPin:(unsigned char)(row + 2)];
    } else {
        [_dataSource setMode:mode startValue:value endValue:value forAnalogPin:(unsigned char)(row - 12)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029a2b8 @ 0029a2b8, 301 bytes * /

void FUN_0029a2b8(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,
                 id changePinEndValue)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  byte bVar5;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_pinConfigurationRangesTableView,sel_selectedRow);
  pvVar2 = _objc_msgSend(self->_pinModePopUp,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_tag);
  pvVar3 = _objc_msgSend(self->_analogAndPWMPinStartValueSpepper,sel_intValue);
  pvVar4 = _objc_msgSend(changePinEndValue,sel_intValue);
  if ((ushort)pvVar4 < (ushort)pvVar3) {
    _objc_msgSend(changePinEndValue,sel_setIntValue_,(uint)pvVar3 & 0xffff);
    pvVar4 = (id)((uint)pvVar3 & 0xffff);
  }
  if ((int)pvVar1 < 0xc) {
    self_00 = self->_dataSource;
    bVar5 = (char)pvVar1 + 2;
    op = sel_setMode_startValue_endValue_forDigitalPin_;
  }
  else {
    self_00 = self->_dataSource;
    bVar5 = (char)pvVar1 - 0xc;
    op = sel_setMode_startValue_endValue_forAnalogPin_;
  }
  _objc_msgSend(self_00,op,pvVar2,(uint)pvVar3 & 0xffff,(uint)pvVar4 & 0xffff,(uint)bVar5);
  return;
}

*/
- (void)changePinEndValue:(id)aValue
{
    NSInteger row = [_pinConfigurationRangesTableView selectedRow];
    NSInteger mode = [[_pinModePopUp selectedItem] tag];
    unsigned short startValue = (unsigned short)[_analogAndPWMPinStartValueSpepper intValue];
    unsigned short endValue = (unsigned short)[aValue intValue];
    if (endValue < startValue) {
        [aValue setIntValue:startValue];
        endValue = startValue;
    }
    if (row < 12) {
        [_dataSource setMode:mode startValue:startValue endValue:endValue forDigitalPin:(unsigned char)(row + 2)];
    } else {
        [_dataSource setMode:mode startValue:startValue endValue:endValue forAnalogPin:(unsigned char)(row - 12)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029a3e5 @ 0029a3e5, 301 bytes * /

void FUN_0029a3e5(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,
                 id changePinStartValue)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  byte bVar5;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_pinConfigurationRangesTableView,sel_selectedRow);
  pvVar2 = _objc_msgSend(self->_pinModePopUp,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_tag);
  pvVar3 = _objc_msgSend(self->_analogAndPWMPinEndValueSpepper,sel_intValue);
  pvVar4 = _objc_msgSend(changePinStartValue,sel_intValue);
  if ((ushort)pvVar3 < (ushort)pvVar4) {
    _objc_msgSend(changePinStartValue,sel_setIntValue_,(uint)pvVar3 & 0xffff);
    pvVar4 = (id)((uint)pvVar3 & 0xffff);
  }
  if ((int)pvVar1 < 0xc) {
    self_00 = self->_dataSource;
    bVar5 = (char)pvVar1 + 2;
    op = sel_setMode_startValue_endValue_forDigitalPin_;
  }
  else {
    self_00 = self->_dataSource;
    bVar5 = (char)pvVar1 - 0xc;
    op = sel_setMode_startValue_endValue_forAnalogPin_;
  }
  _objc_msgSend(self_00,op,pvVar2,(uint)pvVar4 & 0xffff,(uint)pvVar3 & 0xffff,(uint)bVar5);
  return;
}

*/
- (void)changePinStartValue:(id)aValue
{
    NSInteger row = [_pinConfigurationRangesTableView selectedRow];
    NSInteger mode = [[_pinModePopUp selectedItem] tag];
    unsigned short endValue = (unsigned short)[_analogAndPWMPinEndValueSpepper intValue];
    unsigned short startValue = (unsigned short)[aValue intValue];
    if (endValue < startValue) {
        [aValue setIntValue:endValue];
        startValue = endValue;
    }
    if (row < 12) {
        [_dataSource setMode:mode startValue:startValue endValue:endValue forDigitalPin:(unsigned char)(row + 2)];
    } else {
        [_dataSource setMode:mode startValue:startValue endValue:endValue forAnalogPin:(unsigned char)(row - 12)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029a512 @ 0029a512, 838 bytes * /

void FUN_0029a512(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,id selectPinMode)

{
  byte bVar1;
  id pvVar2;
  id pvVar3;
  SEL pcVar4;
  uint uVar5;
  id self_00;
  char local_19;
  ushort local_18;
  ushort local_16;
  uint local_14;
  
  pvVar2 = _objc_msgSend(self->_pinConfigurationRangesTableView,sel_selectedRow);
  pvVar3 = _objc_msgSend(self->_pinModePopUp,sel_selectedItem);
  local_19 = -0xc;
  if ((int)pvVar2 < 0xc) {
    local_19 = '\x02';
  }
  bVar1 = local_19 + (char)pvVar2;
  pvVar3 = _objc_msgSend(pvVar3,sel_tag);
  if (pvVar3 == (id)0xffffffff) {
    self_00 = self->_dataSource;
    pcVar4 = sel_removeConfigurationRangeForAnalogPin_;
    if ((int)pvVar2 < 0xc) {
      pcVar4 = sel_removeConfigurationRangeForDigitalPin_;
    }
    pvVar3 = (id)(uint)bVar1;
    goto LAB_0029a5a3;
  }
  local_14 = 0;
  local_16 = 0;
  local_18 = 0;
  pcVar4 = sel_getMode_startValue_endValue_forAnalogPin_;
  if ((int)pvVar2 < 0xc) {
    pcVar4 = sel_getMode_startValue_endValue_forDigitalPin_;
  }
  _objc_msgSend(self->_dataSource,pcVar4,&local_14,&local_16,&local_18,(uint)bVar1);
  switch(pvVar3) {
  case (id)0x0:
  case (id)0x1:
    if (local_16 == 0) {
      local_18 = 0;
    }
    else {
      local_16 = 1;
      local_18 = 1;
    }
    break;
  case (id)0x2:
    if (local_14 == 4) {
      local_16 = (ushort)(((uint)local_16 * 0x3ff) / 0xb4);
      uVar5 = (uint)local_18 * 0x3ff;
LAB_0029a6b6:
      local_18 = (ushort)(uVar5 / 0xb4);
    }
    else {
      if (local_14 == 3) {
        local_16 = (ushort)(((uint)local_16 * 0x3ff) / 0xff);
        uVar5 = (uint)local_18 * 0x3ff;
        goto LAB_0029a67e;
      }
      if ((local_14 < 2) && (local_18 == 1)) {
        local_16 = 0x3ff;
        local_18 = 0x3ff;
      }
    }
    break;
  case (id)0x3:
    if (local_14 == 4) {
      local_16 = (ushort)(((uint)local_16 * 0xff) / 0xb4);
      uVar5 = (uint)local_18 * 0xff;
      goto LAB_0029a6b6;
    }
    if (local_14 == 2) {
      local_16 = (ushort)(((uint)local_16 * 0xff) / 0x3ff);
      uVar5 = (uint)local_18 * 0xff;
LAB_0029a728:
      local_18 = (ushort)(uVar5 / 0x3ff);
    }
    else if ((local_14 < 2) && (local_18 == 1)) {
      local_16 = 0xff;
      local_18 = 0xff;
    }
    break;
  case (id)0x4:
    if (local_14 == 3) {
      local_16 = (ushort)(((uint)local_16 * 0xb4) / 0xff);
      uVar5 = (uint)local_18 * 0xb4;
LAB_0029a67e:
      local_18 = (ushort)(uVar5 / 0xff);
    }
    else {
      if (local_14 == 2) {
        local_16 = (ushort)(((uint)local_16 * 0xb4) / 0x3ff);
        uVar5 = (uint)local_18 * 0xb4;
        goto LAB_0029a728;
      }
      if ((local_14 < 2) && (local_18 == 1)) {
        local_16 = 0xb4;
        local_18 = 0xb4;
      }
    }
  }
  self_00 = self->_dataSource;
  pcVar4 = sel_setMode_startValue_endValue_forAnalogPin_;
  if ((int)pvVar2 < 0xc) {
    pcVar4 = sel_setMode_startValue_endValue_forDigitalPin_;
  }
LAB_0029a5a3:
  _objc_msgSend(self_00,pcVar4,pvVar3);
  return;
}

*/
- (void)selectPinMode:(id)aMode
{
    NSInteger row = [_pinConfigurationRangesTableView selectedRow];
    BOOL isDigital = row < 12;
    unsigned char pin = (unsigned char)(isDigital ? row + 2 : row - 12);
    NSInteger mode = [[_pinModePopUp selectedItem] tag];
    if (mode == -1) {
        if (isDigital) {
            [_dataSource removeConfigurationRangeForDigitalPin:pin];
        } else {
            [_dataSource removeConfigurationRangeForAnalogPin:pin];
        }
        return;
    }
    int oldMode = 0;
    unsigned short startValue = 0;
    unsigned short endValue = 0;
    if (isDigital) {
        [_dataSource getMode:&oldMode startValue:&startValue endValue:&endValue forDigitalPin:pin];
    } else {
        [_dataSource getMode:&oldMode startValue:&startValue endValue:&endValue forAnalogPin:pin];
    }
    /* Rescale the range to the new mode: 2 = analog 0..1023, 3 = PWM 0..255,
       4 = servo 0..180, 0/1 = digital low/high (high maps to the maximum). */
    unsigned int newMax = 0;
    switch (mode) {
    case 0:
    case 1:
        if (startValue == 0) {
            endValue = 0;
        } else {
            startValue = 1;
            endValue = 1;
        }
        break;
    case 2:
        newMax = 1023;
        break;
    case 3:
        newMax = 255;
        break;
    case 4:
        newMax = 180;
        break;
    }
    if (newMax != 0) {
        unsigned int oldMax = oldMode == 2 ? 1023 : oldMode == 3 ? 255 : oldMode == 4 ? 180 : 0;
        if (oldMax != 0 && oldMax != newMax) {
            startValue = (unsigned short)((startValue * newMax) / oldMax);
            endValue = (unsigned short)((endValue * newMax) / oldMax);
        } else if (oldMax == 0 && (unsigned int)oldMode < 2 && endValue == 1) {
            startValue = (unsigned short)newMax;
            endValue = (unsigned short)newMax;
        }
    }
    if (isDigital) {
        [_dataSource setMode:mode startValue:startValue endValue:endValue forDigitalPin:pin];
    } else {
        [_dataSource setMode:mode startValue:startValue endValue:endValue forAnalogPin:pin];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029a86c @ 0029a86c, 147 bytes * /

BOOL FUN_0029a86c(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,id control,
                 id isValidObject)

{
  ushort uVar1;
  ushort uVar2;
  HSStepper *self_00;
  id pvVar3;
  
  if (self->_analogAndPWMPinStartValueTextField == control) {
    pvVar3 = _objc_msgSend(self->_analogAndPWMPinStartValueTextField,sel_intValue);
    uVar1 = (ushort)pvVar3;
    self_00 = self->_analogAndPWMPinEndValueSpepper;
  }
  else {
    if (self->_analogAndPWMPinEndValueTextField != control) {
      uVar2 = 0;
      uVar1 = 0;
      goto LAB_0029a8ef;
    }
    pvVar3 = _objc_msgSend(self->_analogAndPWMPinStartValueSpepper,sel_intValue);
    uVar1 = (ushort)pvVar3;
    self_00 = self->_analogAndPWMPinEndValueTextField;
  }
  pvVar3 = _objc_msgSend(self_00,sel_intValue);
  uVar2 = (ushort)pvVar3;
LAB_0029a8ef:
  return uVar1 <= uVar2;
}

*/
- (BOOL)control:(id)aControl isValidObject:(id)aObject
{
    unsigned short startValue = 0;
    unsigned short endValue = 0;
    if (_analogAndPWMPinStartValueTextField == aControl) {
        startValue = (unsigned short)[_analogAndPWMPinStartValueTextField intValue];
        endValue = (unsigned short)[_analogAndPWMPinEndValueSpepper intValue];
    } else if (_analogAndPWMPinEndValueTextField == aControl) {
        startValue = (unsigned short)[_analogAndPWMPinStartValueSpepper intValue];
        endValue = (unsigned short)[_analogAndPWMPinEndValueTextField intValue];
    }
    return startValue <= endValue;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029a8ff @ 0029a8ff, 427 bytes * /

void FUN_0029a8ff(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,
                 id tableViewSelectionDidChange)

{
  id pvVar1;
  id self_00;
  id *ppvVar2;
  byte bVar3;
  char cVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(self->_pinConfigurationRangesTableView,sel_selectedRow);
  if (pvVar1 == (id)0xffffffff) {
    _objc_msgSend(self->_pinModePopUp,sel_setMenu_,self->_noPinModeMenu);
    uVar5 = 0xffffffff;
    _objc_msgSend(self->_pinModePopUp,sel_selectItemWithTag_,0xffffffff);
    if (self->_pinValueRangeView != self->_noPinValueRangeView) {
      self_00 = _objc_msgSend(self->_pinValueRangeView,sel_superview,uVar5);
      _objc_msgSend(self_00,sel_replaceSubview_with_,self->_pinValueRangeView,
                    self->_noPinValueRangeView);
      self->_pinValueRangeView = self->_noPinValueRangeView;
    }
    goto LAB_0029aa77;
  }
  if ((int)pvVar1 < 0xc) {
    bVar3 = (char)pvVar1 + 2;
    if (bVar3 < 0xe) {
      if ((0x3194U >> (bVar3 & 0x1f) & 1) == 0) {
        if ((0xe68U >> (bVar3 & 0x1f) & 1) == 0) goto LAB_0029aa05;
        ppvVar2 = &self->_digitalPWMPinModesMenu;
        cVar4 = '\x01';
      }
      else {
        ppvVar2 = &self->_digitalPinModesMenu;
        cVar4 = '\x01';
      }
    }
    else {
LAB_0029aa05:
      ppvVar2 = &self->_noPinModeMenu;
      cVar4 = '\x01';
    }
  }
  else {
    ppvVar2 = &self->_analogPinModesMenu;
    bVar3 = (char)pvVar1 - 0xc;
    cVar4 = '\0';
  }
  _objc_msgSend(self->_pinModePopUp,sel_setMenu_,*ppvVar2);
  _objc_msgSend(self,
                sel_HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin_isPinDigital_
                ,(uint)bVar3,(int)cVar4);
LAB_0029aa77:
  _objc_msgSend(self->_pinModePopUp,sel_setEnabled_,(uint)(-1 < (int)pvVar1));
  return;
}

*/
- (void)tableViewSelectionDidChange:(id)aChange
{
    NSInteger row = [_pinConfigurationRangesTableView selectedRow];
    if (row == -1) {
        [_pinModePopUp setMenu:_noPinModeMenu];
        [_pinModePopUp selectItemWithTag:-1];
        if (_pinValueRangeView != _noPinValueRangeView) {
            [[_pinValueRangeView superview] replaceSubview:_pinValueRangeView with:_noPinValueRangeView];
            _pinValueRangeView = _noPinValueRangeView;
        }
    } else {
        NSMenu *menu;
        unsigned char pin;
        BOOL isDigital;
        if (row < 12) {
            pin = (unsigned char)(row + 2);
            isDigital = YES;
            if (pin < 14 && ((0x3194U >> pin) & 1) != 0) {
                menu = _digitalPinModesMenu;
            } else if (pin < 14 && ((0xe68U >> pin) & 1) != 0) {
                menu = _digitalPWMPinModesMenu;
            } else {
                menu = _noPinModeMenu;
            }
        } else {
            pin = (unsigned char)(row - 12);
            isDigital = NO;
            menu = _analogPinModesMenu;
        }
        [_pinModePopUp setMenu:menu];
        [self HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin:pin isPinDigital:isDigital];
    }
    [_pinModePopUp setEnabled:row >= 0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029aaaa @ 0029aaaa, 486 bytes * /

void FUN_0029aaaa(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,id tableView,
                 id willDisplayCell,id forTableColumn,int row)

{
  id pvVar1;
  id pvVar2;
  uint uVar3;
  SEL pcVar4;
  undefined4 uVar5;
  cfstringStruct *pcVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  
  pvVar1 = _objc_msgSend(forTableColumn,sel_identifier);
  pvVar2 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_mode);
  if (((char)pvVar2 == '\0') &&
     (pvVar2 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_value), (char)pvVar2 == '\0')) {
    pcVar6 = &cfstr_status;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_status);
    if ((char)pvVar1 == '\0') {
      return;
    }
    pvVar1 = _objc_msgSend(cls_HSArduinoDevice,sel_defaultDevice,pcVar6);
    pvVar1 = _objc_msgSend(pvVar1,sel_connectionStatus);
    pcVar4 = sel_disabledControlTextColor;
    if (pvVar1 == (id)0x6) {
      pcVar4 = sel_controlTextColor;
    }
    pvVar1 = _objc_msgSend(cls_NSColor,pcVar4,pcVar6);
  }
  else if (row < 0xc) {
    uVar3 = (uint)(byte)((char)row + 2);
    uVar8 = 0;
    uVar7 = 0;
    uVar5 = 0;
    pvVar1 = _objc_msgSend(self->_dataSource,sel_getMode_startValue_endValue_forDigitalPin_,0,0,0,
                           uVar3);
    pcVar4 = sel_disabledControlTextColor;
    if ((char)pvVar1 != '\0') {
      pcVar4 = sel_controlTextColor;
    }
    pvVar1 = _objc_msgSend(cls_NSColor,pcVar4,uVar5,uVar7,uVar8,uVar3);
  }
  else {
    uVar3 = (uint)(byte)((char)row - 0xc);
    uVar8 = 0;
    uVar7 = 0;
    uVar5 = 0;
    pvVar1 = _objc_msgSend(self->_dataSource,sel_getMode_startValue_endValue_forAnalogPin_,0,0,0,
                           uVar3);
    pcVar4 = sel_disabledControlTextColor;
    if ((char)pvVar1 != '\0') {
      pcVar4 = sel_controlTextColor;
    }
    pvVar1 = _objc_msgSend(cls_NSColor,pcVar4,uVar5,uVar7,uVar8,uVar3);
  }
  _objc_msgSend(willDisplayCell,sel_setTextColor_,pvVar1);
  return;
}

*/
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    NSString *identifier = [aColumn identifier];
    NSColor *color;
    if ([identifier isEqualToString:@"mode"] || [identifier isEqualToString:@"value"]) {
        BOOL configured;
        if (aRow < 12) {
            configured = [_dataSource getMode:NULL startValue:NULL endValue:NULL forDigitalPin:(unsigned char)(aRow + 2)];
        } else {
            configured = [_dataSource getMode:NULL startValue:NULL endValue:NULL forAnalogPin:(unsigned char)(aRow - 12)];
        }
        color = configured ? [NSColor controlTextColor] : [NSColor disabledControlTextColor];
    } else if ([identifier isEqualToString:@"status"]) {
        color = [[HSArduinoDevice defaultDevice] connectionStatus] == 6 ? [NSColor controlTextColor] : [NSColor disabledControlTextColor];
    } else {
        return;
    }
    [aCell setTextColor:color];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029ac90 @ 0029ac90, 2041 bytes * /

/* WARNING: Type propagation algorithm not settling * /

id FUN_0029ac90(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  SEL pcVar5;
  undefined *self_00;
  uint uVar6;
  cfstringStruct *pcVar7;
  cfstringStruct *pcVar8;
  byte bVar9;
  undefined **ppuVar10;
  ushort *puVar11;
  ushort *puVar12;
  undefined1 local_32 [6];
  ushort local_2c;
  ushort local_2a;
  undefined *local_28;
  int local_24;
  ushort local_1e;
  undefined *local_1c;
  ushort local_18;
  ushort local_16;
  undefined *local_14;
  
  pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  pcVar4 = &cfstr_check;
  cVar1 = -0xc;
  if (row < 0xc) {
    cVar1 = '\x02';
  }
  bVar9 = (char)row + cVar1;
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_check);
  if ((char)pvVar3 != '\0') {
    pvVar2 = _objc_msgSend(cls_HSArduinoDevice,sel_defaultDevice,pcVar4);
    pvVar3 = _objc_msgSend(pvVar2,sel_connectionStatus);
    pcVar5 = sel_HSArduinoWatcherActionConfigurationAssistantPane_grayStatusImage;
    if (pvVar3 == (id)0x6) {
      if (row < 0xc) {
        uVar6 = (uint)bVar9;
        pcVar4 = (cfstringStruct *)&local_14;
        pvVar3 = _objc_msgSend(self->_dataSource,sel_getMode_startValue_endValue_forDigitalPin_,
                               pcVar4,&local_16,&local_18,uVar6);
        cVar1 = (char)pvVar3;
        pcVar5 = sel_HSArduinoWatcherActionConfigurationAssistantPane_grayStatusImage;
      }
      else {
        uVar6 = (uint)bVar9;
        pcVar4 = (cfstringStruct *)&local_14;
        pvVar3 = _objc_msgSend(self->_dataSource,sel_getMode_startValue_endValue_forAnalogPin_,
                               pcVar4,&local_16,&local_18,uVar6);
        cVar1 = (char)pvVar3;
        pcVar5 = sel_HSArduinoWatcherActionConfigurationAssistantPane_grayStatusImage;
      }
      sel_HSArduinoWatcherActionConfigurationAssistantPane_grayStatusImage = pcVar5;
      if (cVar1 != '\0') {
        pcVar5 = sel_getMode_value_forAnalogPin_;
        if (row < 0xc) {
          pcVar5 = sel_getMode_value_forDigitalPin_;
        }
        pcVar4 = (cfstringStruct *)&local_1c;
        pvVar2 = _objc_msgSend(pvVar2,pcVar5,pcVar4,&local_1e,(uint)bVar9,uVar6);
        pcVar5 = sel_HSArduinoWatcherActionConfigurationAssistantPane_grayStatusImage;
        if (((((char)pvVar2 != '\0') &&
             (pcVar5 = sel_HSArduinoWatcherActionConfigurationAssistantPane_redStatusImage,
             local_14 == local_1c)) && (local_16 <= local_1e)) && (local_1e <= local_18)) {
          pcVar5 = sel_HSArduinoWatcherActionConfigurationAssistantPane_greenStatusImage;
        }
      }
    }
    goto LAB_0029ad80;
  }
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_pin);
  if ((char)pvVar3 != '\0') {
    if (row < 0xc) {
      pcVar4 = (cfstringStruct *)(uint)bVar9;
      self = (HSArduinoWatcherActionConfigurationAssistantPane *)cls_NSNumber;
      pcVar5 = sel_numberWithUnsignedChar_;
    }
    else {
      pcVar4 = &cfstr_A_d;
      self = (HSArduinoWatcherActionConfigurationAssistantPane *)cls_NSString;
      pcVar5 = sel_stringWithFormat_;
    }
    goto LAB_0029ad80;
  }
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_mode);
  if ((char)pvVar3 != '\0') {
    local_24 = -1;
    pcVar5 = sel_getMode_startValue_endValue_forAnalogPin_;
    if (row < 0xc) {
      pcVar5 = sel_getMode_startValue_endValue_forDigitalPin_;
    }
    _objc_msgSend(self->_dataSource,pcVar5,&local_24,0,0,(uint)bVar9);
    pvVar2 = _objc_msgSend(self,sel_HSArduinoWatcherActionConfigurationAssistantPane_modeToTitleMap)
    ;
    if (pvVar2 == (id)0x0) {
      return (id)0x0;
    }
    pvVar2 = (id)_CFDictionaryGetValue(self->_modeToTitleMap,local_24);
    return pvVar2;
  }
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_value);
  if ((char)pvVar3 != '\0') {
    pcVar5 = sel_getMode_startValue_endValue_forAnalogPin_;
    if (row < 0xc) {
      pcVar5 = sel_getMode_startValue_endValue_forDigitalPin_;
    }
    uVar6 = (uint)bVar9;
    puVar12 = &local_2c;
    puVar11 = &local_2a;
    ppuVar10 = &local_28;
    pvVar2 = _objc_msgSend(self->_dataSource,pcVar5,ppuVar10,puVar11,puVar12,uVar6);
    if ((char)pvVar2 == '\0') {
      self = _objc_msgSend(cls_NSBundle,sel_mainBundle,ppuVar10,puVar11,puVar12,uVar6);
      pcVar4 = &cfstr_Ignore;
      pcVar5 = sel_localizedStringForKey_value_table_;
    }
    else if (local_28 + -2 < (undefined *)0x3) {
      pcVar4 = (cfstringStruct *)(uint)local_2c;
      self = (HSArduinoWatcherActionConfigurationAssistantPane *)cls_NSNumber;
      pcVar5 = sel_numberWithUnsignedShort_;
      if (local_2a != local_2c) {
        pcVar4 = &cfstr__u____u;
        self = (HSArduinoWatcherActionConfigurationAssistantPane *)cls_NSString;
        pcVar5 = sel_stringWithFormat_;
      }
    }
    else {
      if ((undefined *)0x1 < local_28) {
        return (id)0x0;
      }
      self = _objc_msgSend(cls_NSBundle,sel_mainBundle,ppuVar10,puVar11,puVar12,uVar6);
      if (local_2c == 0) {
        pcVar4 = &cfstr_Low;
        pcVar5 = sel_localizedStringForKey_value_table_;
      }
      else {
        pcVar4 = &cfstr_High;
        pcVar5 = sel_localizedStringForKey_value_table_;
      }
    }
    goto LAB_0029ad80;
  }
  pcVar4 = &cfstr_status;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_status);
  if ((char)pvVar2 == '\0') {
switchD_0029b113_caseD_2:
    return (id)0x0;
  }
  pvVar2 = _objc_msgSend(cls_HSArduinoDevice,sel_defaultDevice,pcVar4);
  pvVar3 = _objc_msgSend(pvVar2,sel_connectionStatus);
  switch(pvVar3) {
  case (id)0x0:
    self = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
    pcVar4 = &cfstr_No_device;
    pcVar5 = sel_localizedStringForKey_value_table_;
    break;
  case (id)0x1:
    self = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
    pcVar4 = &cfstr_Searching;
    pcVar5 = sel_localizedStringForKey_value_table_;
    break;
  default:
    goto switchD_0029b113_caseD_2;
  case (id)0x3:
    self = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
    pcVar4 = &cfstr_Outdated_protocol;
    pcVar5 = sel_localizedStringForKey_value_table_;
    break;
  case (id)0x4:
    self = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
    pcVar4 = &cfstr_Unsupported_protocol;
    pcVar5 = sel_localizedStringForKey_value_table_;
    break;
  case (id)0x5:
    self = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
    pcVar4 = &cfstr_Unsupported_firmware;
    pcVar5 = sel_localizedStringForKey_value_table_;
    break;
  case (id)0x6:
    if (row < 0xc) {
      pcVar7 = (cfstringStruct *)(uint)bVar9;
      pcVar4 = (cfstringStruct *)local_32;
      pcVar8 = (cfstringStruct *)(local_32 + 2);
      pvVar2 = _objc_msgSend(pvVar2,sel_getMode_value_forDigitalPin_,pcVar8,pcVar4,pcVar7);
      if ((char)pvVar2 == '\0') {
        pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar8,pcVar4,pcVar7);
LAB_0029b328:
        pcVar7 = &cfstr_AssistantPanes;
        pcVar4 = &cfstr_empty;
        pcVar8 = &cfstr_No_device;
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_No_device,
                               &cfstr_empty,&cfstr_AssistantPanes);
        if (pvVar2 != (id)0x0) {
          return pvVar2;
        }
      }
    }
    else {
      pcVar7 = (cfstringStruct *)(uint)bVar9;
      pcVar4 = (cfstringStruct *)local_32;
      pcVar8 = (cfstringStruct *)(local_32 + 2);
      pvVar2 = _objc_msgSend(pvVar2,sel_getMode_value_forAnalogPin_,pcVar8,pcVar4,pcVar7);
      if ((char)pvVar2 == '\0') {
        pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar8,pcVar4,pcVar7);
        goto LAB_0029b328;
      }
    }
    pvVar2 = _objc_msgSend(self,sel_HSArduinoWatcherActionConfigurationAssistantPane_modeToTitleMap,
                           pcVar8,pcVar4,pcVar7);
    if (pvVar2 != (id)0x0) {
      _CFDictionaryGetValue(self->_modeToTitleMap,local_32._2_4_);
    }
    if ((uint)local_32._2_4_ < 2) {
      self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar8,pcVar4,pcVar7);
      pcVar5 = sel_localizedStringForKey_value_table_;
      if (local_32._0_2_ == 0) {
        pcVar7 = &cfstr_AssistantPanes;
        pcVar4 = &cfstr_empty;
        pcVar8 = &cfstr_Low;
      }
      else {
        pcVar7 = &cfstr_AssistantPanes;
        pcVar4 = &cfstr_empty;
        pcVar8 = &cfstr_High;
      }
    }
    else {
      pcVar4 = (cfstringStruct *)(uint)(ushort)local_32._0_2_;
      pcVar8 = &cfstr__hu;
      self_00 = cls_NSString;
      pcVar5 = sel_stringWithFormat_;
    }
    _objc_msgSend(self_00,pcVar5,pcVar8,pcVar4,pcVar7);
    self = (HSArduinoWatcherActionConfigurationAssistantPane *)cls_NSString;
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar4 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr________,&cfstr_empty
                           ,&cfstr_AssistantPanes);
    pcVar5 = sel_stringWithFormat_;
  }
LAB_0029ad80:
  pvVar2 = _objc_msgSend(self,pcVar5,pcVar4);
  return pvVar2;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    NSString *identifier = [aColumn identifier];
    BOOL isDigital = aRow < 12;
    unsigned char pin = (unsigned char)(isDigital ? aRow + 2 : aRow - 12);
    if ([identifier isEqualToString:@"check"]) {
        HSArduinoDevice *device = [HSArduinoDevice defaultDevice];
        if ([device connectionStatus] == 6) {
            int mode = 0;
            unsigned short startValue = 0;
            unsigned short endValue = 0;
            BOOL configured;
            if (isDigital) {
                configured = [_dataSource getMode:&mode startValue:&startValue endValue:&endValue forDigitalPin:pin];
            } else {
                configured = [_dataSource getMode:&mode startValue:&startValue endValue:&endValue forAnalogPin:pin];
            }
            if (configured) {
                int currentMode = 0;
                unsigned short currentValue = 0;
                BOOL known = isDigital ? [device getMode:&currentMode value:&currentValue forDigitalPin:pin] : [device getMode:&currentMode value:&currentValue forAnalogPin:pin];
                if (!known) {
                    return [self HSArduinoWatcherActionConfigurationAssistantPane_grayStatusImage];
                }
                if (mode == currentMode && startValue <= currentValue && currentValue <= endValue) {
                    return [self HSArduinoWatcherActionConfigurationAssistantPane_greenStatusImage];
                }
                return [self HSArduinoWatcherActionConfigurationAssistantPane_redStatusImage];
            }
        }
        return [self HSArduinoWatcherActionConfigurationAssistantPane_grayStatusImage];
    }
    if ([identifier isEqualToString:@"pin"]) {
        if (isDigital) {
            return [NSNumber numberWithUnsignedChar:pin];
        }
        return [NSString stringWithFormat:@"A%d", pin];
    }
    if ([identifier isEqualToString:@"mode"]) {
        int mode = -1;
        if (isDigital) {
            [_dataSource getMode:&mode startValue:NULL endValue:NULL forDigitalPin:pin];
        } else {
            [_dataSource getMode:&mode startValue:NULL endValue:NULL forAnalogPin:pin];
        }
        if ([self HSArduinoWatcherActionConfigurationAssistantPane_modeToTitleMap] == NULL) {
            return nil;
        }
        return (id)CFDictionaryGetValue(_modeToTitleMap, (const void *)(intptr_t)mode);
    }
    if ([identifier isEqualToString:@"value"]) {
        int mode = 0;
        unsigned short startValue = 0;
        unsigned short endValue = 0;
        BOOL configured;
        if (isDigital) {
            configured = [_dataSource getMode:&mode startValue:&startValue endValue:&endValue forDigitalPin:pin];
        } else {
            configured = [_dataSource getMode:&mode startValue:&startValue endValue:&endValue forAnalogPin:pin];
        }
        if (!configured) {
            return [[NSBundle mainBundle] localizedStringForKey:@"Ignore" value:@"" table:@"AssistantPanes"];
        }
        if ((unsigned int)(mode - 2) < 3) {
            if (endValue != startValue) {
                return [NSString stringWithFormat:@"%u...%u", startValue, endValue];
            }
            return [NSNumber numberWithUnsignedShort:startValue];
        }
        if ((unsigned int)mode > 1) {
            return nil;
        }
        return startValue == 0 ? [[NSBundle mainBundle] localizedStringForKey:@"Low" value:@"" table:@"AssistantPanes"] : [[NSBundle mainBundle] localizedStringForKey:@"High" value:@"" table:@"AssistantPanes"];
    }
    if (![identifier isEqualToString:@"status"]) {
        return nil;
    }
    HSArduinoDevice *device = [HSArduinoDevice defaultDevice];
    switch ([device connectionStatus]) {
    case 0:
        return [[NSBundle mainBundle] localizedStringForKey:@"No device" value:@"" table:@"AssistantPanes"];
    case 1:
        return [[NSBundle mainBundle] localizedStringForKey:@"Searching" value:@"" table:@"AssistantPanes"];
    case 3:
        return [[NSBundle mainBundle] localizedStringForKey:@"Outdated protocol" value:@"" table:@"AssistantPanes"];
    case 4:
        return [[NSBundle mainBundle] localizedStringForKey:@"Unsupported protocol" value:@"" table:@"AssistantPanes"];
    case 5:
        return [[NSBundle mainBundle] localizedStringForKey:@"Unsupported firmware" value:@"" table:@"AssistantPanes"];
    case 6: {
        int mode = 0;
        unsigned short value = 0;
        BOOL known = isDigital ? [device getMode:&mode value:&value forDigitalPin:pin] : [device getMode:&mode value:&value forAnalogPin:pin];
        if (!known) {
            return [[NSBundle mainBundle] localizedStringForKey:@"No device" value:@"" table:@"AssistantPanes"];
        }
        id title = nil;
        if ([self HSArduinoWatcherActionConfigurationAssistantPane_modeToTitleMap] != NULL) {
            title = (id)CFDictionaryGetValue(_modeToTitleMap, (const void *)(intptr_t)mode);
        }
        NSString *valueString;
        if ((unsigned int)mode < 2) {
            valueString = value == 0 ? [[NSBundle mainBundle] localizedStringForKey:@"Low" value:@"" table:@"AssistantPanes"] : [[NSBundle mainBundle] localizedStringForKey:@"High" value:@"" table:@"AssistantPanes"];
        } else {
            valueString = [NSString stringWithFormat:@"%hu", value];
        }
        return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"%@ / %@" value:@"" table:@"AssistantPanes"], title, valueString];
    }
    default:
        return nil;
    }
}

- (id)HSArduinoWatcherActionConfigurationAssistantPane_redStatusImage
{
    id pvVar1;

    pvVar1 = _redStatusImage;
    if (pvVar1 == nil) {
        pvVar1 = [[NSImage imageNamed:@"RedStatus"] retain];
        _redStatusImage = pvVar1;
    }
    return pvVar1;
}

- (id)HSArduinoWatcherActionConfigurationAssistantPane_greenStatusImage
{
    id pvVar1;

    pvVar1 = _greenStatusImage;
    if (pvVar1 == nil) {
        pvVar1 = [[NSImage imageNamed:@"GreenStatus"] retain];
        _greenStatusImage = pvVar1;
    }
    return pvVar1;
}

- (id)HSArduinoWatcherActionConfigurationAssistantPane_grayStatusImage
{
    id pvVar1;

    pvVar1 = _grayStatusImage;
    if (pvVar1 == nil) {
        pvVar1 = [[NSImage imageNamed:@"GrayStatus"] retain];
        _grayStatusImage = pvVar1;
    }
    return pvVar1;
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return 0x12;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029b5bc @ 0029b5bc, 354 bytes * /

CFDictionary * FUN_0029b5bc(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd)

{
  CFDictionary *pCVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int iVar5;
  int iVar6;
  
  if (self->_modeToTitleMap == (CFDictionary *)0x0) {
    pCVar1 = (CFDictionary *)
             _CFDictionaryCreateMutable(*(undefined4 *)PTR_003363a4,6,PTR_00336a08,PTR_00336514);
    self->_modeToTitleMap = pCVar1;
    if (pCVar1 != (CFDictionary *)0x0) {
      pvVar2 = _objc_msgSend(self->_digitalPWMPinModesMenu,sel_numberOfItems);
      if (0 < (int)pvVar2) {
        iVar5 = 0;
        do {
          iVar6 = iVar5;
          pvVar3 = _objc_msgSend(self->_digitalPWMPinModesMenu,sel_itemAtIndex_,iVar5);
          pvVar4 = _objc_msgSend(pvVar3,sel_title);
          if (pvVar4 != (id)0x0) {
            pvVar3 = _objc_msgSend(pvVar3,sel_tag,iVar6);
            _CFDictionarySetValue(self->_modeToTitleMap,pvVar3,pvVar4);
          }
          iVar5 = iVar5 + 1;
        } while (iVar5 < (int)pvVar2);
      }
      pvVar2 = _objc_msgSend(self->_analogPinModesMenu,sel_itemWithTag_,2);
      pvVar2 = _objc_msgSend(pvVar2,sel_title);
      if (pvVar2 != (id)0x0) {
        _CFDictionarySetValue(self->_modeToTitleMap,2,pvVar2);
      }
    }
  }
  return self->_modeToTitleMap;
}

*/
- (struct __CFDictionary *)HSArduinoWatcherActionConfigurationAssistantPane_modeToTitleMap
{
    if (_modeToTitleMap == NULL) {
        _modeToTitleMap = CFDictionaryCreateMutable(kCFAllocatorDefault, 6, &kCFEIntegerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (_modeToTitleMap != NULL) {
            NSInteger count = [_digitalPWMPinModesMenu numberOfItems];
            for (NSInteger i = 0; i < count; i++) {
                NSMenuItem *item = [_digitalPWMPinModesMenu itemAtIndex:i];
                NSString *title = [item title];
                if (title != nil) {
                    CFDictionarySetValue(_modeToTitleMap, (const void *)(intptr_t)[item tag], title);
                }
            }
            NSString *title = [[_analogPinModesMenu itemWithTag:2] title];
            if (title != nil) {
                CFDictionarySetValue(_modeToTitleMap, (const void *)(intptr_t)2, title);
            }
        }
    }
    return _modeToTitleMap;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029b71e @ 0029b71e, 538 bytes * /

void FUN_0029b71e(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,
                 id HSArdinoWatcherActionConfigurationAssistantPane_pinDidUpdate)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  undefined4 uVar5;
  
  if (self->_isReloadScheduled == '\0') {
    self->_isReloadScheduled = '\x01';
    _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,
                  sel_HSArdinoWatcherActionConfigurationAssistantPane_reloadDataRarely,0,0x9999999a,
                  0x3fc99999);
  }
  puVar1 = PTR_0033605c;
  dVar4 = *(double *)PTR_0033605c;
  if (1038.0 <= dVar4) {
    pvVar2 = _objc_msgSend(HSArdinoWatcherActionConfigurationAssistantPane_pinDidUpdate,sel_userInfo
                          );
    uVar5 = *(undefined4 *)PTR_00336a00;
    pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,uVar5);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar3 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar2,sel_mutableCopy,uVar5);
      if (pvVar2 != (id)0x0) {
        uVar5 = 0xfffffffe;
        _objc_msgSend(pvVar2,sel_shiftIndexesStartingAtIndex_by_,2,0xfffffffe);
        if (self->_indicesToReload == (id)0x0) {
          self->_indicesToReload = pvVar2;
        }
        else {
          _objc_msgSend(self->_indicesToReload,sel_addIndexes_,pvVar2,uVar5);
          _objc_msgSend(pvVar2,sel_release);
        }
      }
    }
    dVar4 = *(double *)puVar1;
  }
  if (1038.0 <= dVar4) {
    pvVar2 = _objc_msgSend(HSArdinoWatcherActionConfigurationAssistantPane_pinDidUpdate,sel_userInfo
                          );
    uVar5 = *(undefined4 *)PTR_003369fc;
    pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,uVar5);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar3 != (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar2,sel_mutableCopy,uVar5);
      if (pvVar2 != (id)0x0) {
        uVar5 = 0xc;
        _objc_msgSend(pvVar2,sel_shiftIndexesStartingAtIndex_by_,0,0xc);
        if (self->_indicesToReload == (id)0x0) {
          self->_indicesToReload = pvVar2;
        }
        else {
          _objc_msgSend(self->_indicesToReload,sel_addIndexes_,pvVar2,uVar5);
          _objc_msgSend(pvVar2,sel_release);
        }
      }
    }
  }
  return;
}

*/
- (void)HSArdinoWatcherActionConfigurationAssistantPane_pinDidUpdate:(id)aUpdate
{
    if (!_isReloadScheduled) {
        _isReloadScheduled = YES;
        [self performSelector:@selector(HSArdinoWatcherActionConfigurationAssistantPane_reloadDataRarely) withObject:nil afterDelay:0.2];
    }
    if (NSAppKitVersionNumber >= 1038.0) {
        NSIndexSet *pins = [[aUpdate userInfo] objectForKey:HSArduinoDeviceNotificationInfoDigitalPins];
        if ([pins count] != 0) {
            NSMutableIndexSet *rows = [pins mutableCopy];
            if (rows != nil) {
                /* Digital pins start at 2 and fill rows 0..11. */
                [rows shiftIndexesStartingAtIndex:2 by:-2];
                if (_indicesToReload == nil) {
                    _indicesToReload = rows;
                } else {
                    [_indicesToReload addIndexes:rows];
                    [rows release];
                }
            }
        }
        pins = [[aUpdate userInfo] objectForKey:HSArduinoDeviceNotificationInfoAnalogPins];
        if ([pins count] != 0) {
            NSMutableIndexSet *rows = [pins mutableCopy];
            if (rows != nil) {
                [rows shiftIndexesStartingAtIndex:0 by:12];
                if (_indicesToReload == nil) {
                    _indicesToReload = rows;
                } else {
                    [_indicesToReload addIndexes:rows];
                    [rows release];
                }
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029b938 @ 0029b938, 241 bytes * /

void FUN_0029b938(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  self->_isReloadScheduled = '\0';
  if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
    pvVar1 = self->_pinConfigurationRangesTableView;
    op = sel_reloadData;
  }
  else {
    pvVar1 = _objc_msgSend(self->_indicesToReload,sel_count);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar1 = _objc_msgSend(cls_NSMutableIndexSet,sel_indexSetWithIndex_,0);
    _objc_msgSend(pvVar1,sel_addIndex_,4);
    _objc_msgSend(self->_pinConfigurationRangesTableView,sel_reloadDataForRowIndexes_columnIndexes_,
                  self->_indicesToReload,pvVar1);
    pvVar1 = self->_indicesToReload;
    op = sel_removeAllIndexes;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)HSArdinoWatcherActionConfigurationAssistantPane_reloadDataRarely
{
    _isReloadScheduled = NO;
    if (NSAppKitVersionNumber < 1038.0) {
        [_pinConfigurationRangesTableView reloadData];
        return;
    }
    if ([_indicesToReload count] == 0) {
        return;
    }
    NSMutableIndexSet *columns = [NSMutableIndexSet indexSetWithIndex:0];
    [columns addIndex:4];
    [_pinConfigurationRangesTableView reloadDataForRowIndexes:_indicesToReload columnIndexes:columns];
    [_indicesToReload removeAllIndexes];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029ba29 @ 0029ba29, 203 bytes * /

void FUN_0029ba29(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,
                 id 
                 HSArdinoWatcherActionConfigurationAssistantPane_arduinoDeviceConnectionStateDidChange
                 )

{
  id pvVar1;
  SEL op;
  
  if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
    pvVar1 = self->_pinConfigurationRangesTableView;
    op = sel_reloadData;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSMutableIndexSet,sel_indexSetWithIndex_,0);
    _objc_msgSend(pvVar1,sel_addIndex_,4);
    pvVar1 = self->_pinConfigurationRangesTableView;
    _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndexesInRange_,0,0x11);
    op = sel_reloadDataForRowIndexes_columnIndexes_;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)HSArdinoWatcherActionConfigurationAssistantPane_arduinoDeviceConnectionStateDidChange:(id)aChange
{
    if (NSAppKitVersionNumber < 1038.0) {
        [_pinConfigurationRangesTableView reloadData];
        return;
    }
    NSMutableIndexSet *columns = [NSMutableIndexSet indexSetWithIndex:0];
    [columns addIndex:4];
    [_pinConfigurationRangesTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 17)] columnIndexes:columns];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029baf4 @ 0029baf4, 306 bytes * /

void FUN_0029baf4(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  char cVar2;
  SEL op;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self->_pinConfigurationRangesTableView,sel_selectedRow);
  if (-1 < (int)pvVar1) {
    cVar2 = -0xc;
    if ((int)pvVar1 < 0xc) {
      cVar2 = '\x02';
    }
    _objc_msgSend(self,
                  sel_HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin_isPinDigital_
                  ,(uint)(byte)((char)pvVar1 + cVar2),(uint)((int)pvVar1 < 0xc));
  }
  if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
    pvVar1 = self->_pinConfigurationRangesTableView;
    op = sel_reloadData;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndexesInRange_,0,0x12);
    if (pvVar1 == (id)0x0) {
      return;
    }
    uVar3 = 2;
    pvVar1 = _objc_msgSend(cls_NSMutableIndexSet,sel_indexSetWithIndexesInRange_,2,2);
    if (pvVar1 == (id)0x0) {
      return;
    }
    _objc_msgSend(pvVar1,sel_addIndex_,0,uVar3);
    pvVar1 = self->_pinConfigurationRangesTableView;
    op = sel_reloadDataForRowIndexes_columnIndexes_;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)notePinConfigurationRangesChanged
{
    NSInteger row = [_pinConfigurationRangesTableView selectedRow];
    if (row >= 0) {
        [self HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin:(unsigned char)(row < 12 ? row + 2 : row - 12) isPinDigital:row < 12];
    }
    if (NSAppKitVersionNumber < 1038.0) {
        [_pinConfigurationRangesTableView reloadData];
        return;
    }
    NSIndexSet *rows = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 18)];
    if (rows == nil) {
        return;
    }
    NSMutableIndexSet *columns = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
    if (columns == nil) {
        return;
    }
    [columns addIndex:0];
    [_pinConfigurationRangesTableView reloadDataForRowIndexes:rows columnIndexes:columns];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029bc26 @ 0029bc26, 330 bytes * /

void FUN_0029bc26(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,
                 uchar notePinConfigurationRangeChangedForPin,BOOL isPinDigital)

{
  id pvVar1;
  char cVar2;
  int iVar3;
  SEL op;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self->_pinConfigurationRangesTableView,sel_selectedRow);
  if (-1 < (int)pvVar1) {
    cVar2 = -0xc;
    if ((int)pvVar1 < 0xc) {
      cVar2 = '\x02';
    }
    if (((uchar)(cVar2 + (char)pvVar1) == notePinConfigurationRangeChangedForPin) &&
       ((int)pvVar1 < 0xc == (bool)isPinDigital)) {
      _objc_msgSend(self,
                    sel_HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin_isPinDigital_
                    ,(uint)notePinConfigurationRangeChangedForPin,(int)isPinDigital);
    }
  }
  if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
    pvVar1 = self->_pinConfigurationRangesTableView;
    op = sel_reloadData;
  }
  else {
    iVar3 = -2;
    if (isPinDigital == '\0') {
      iVar3 = 0xc;
    }
    pvVar1 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,
                           (uint)notePinConfigurationRangeChangedForPin + iVar3);
    if (pvVar1 == (id)0x0) {
      return;
    }
    uVar4 = 2;
    pvVar1 = _objc_msgSend(cls_NSMutableIndexSet,sel_indexSetWithIndexesInRange_,2,2);
    if (pvVar1 == (id)0x0) {
      return;
    }
    _objc_msgSend(pvVar1,sel_addIndex_,0,uVar4);
    pvVar1 = self->_pinConfigurationRangesTableView;
    op = sel_reloadDataForRowIndexes_columnIndexes_;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)notePinConfigurationRangeChangedForPin:(unsigned char)aPin isPinDigital:(BOOL)aDigital
{
    NSInteger row = [_pinConfigurationRangesTableView selectedRow];
    if (row >= 0) {
        unsigned char selectedPin = (unsigned char)(row < 12 ? row + 2 : row - 12);
        if (selectedPin == aPin && (row < 12) == (aDigital != NO)) {
            [self HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin:aPin isPinDigital:aDigital];
        }
    }
    if (NSAppKitVersionNumber < 1038.0) {
        [_pinConfigurationRangesTableView reloadData];
        return;
    }
    NSIndexSet *rows = [NSIndexSet indexSetWithIndex:(NSUInteger)aPin + (aDigital ? -2 : 12)];
    if (rows == nil) {
        return;
    }
    NSMutableIndexSet *columns = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
    if (columns == nil) {
        return;
    }
    [columns addIndex:0];
    [_pinConfigurationRangesTableView reloadDataForRowIndexes:rows columnIndexes:columns];
}

- (void)setDataSource:(id)aSource
{
    _dataSource = aSource;
}

- (id)dataSource
{
    return _dataSource;
}

- (id)initialKeyView
{
    return _pinConfigurationRangesTableView;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029bd70 @ 0029bd70, 290 bytes * /

void FUN_0029bd70(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,
                 BOOL viewWillDisappear)

{
  id pvVar1;
  id self_00;
  HSArduinoWatcherActionConfigurationAssistantPane *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(cls_HSArduinoDevice,sel_defaultDevice);
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(self_00,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_003369f8,pvVar1);
  _objc_msgSend(self_00,sel_removeObserver_name_object_,self,*(undefined4 *)PTR_00336a04,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_isActive);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend((self->super).super.super._delegate,sel_actionPaneDidClose_withApplier_canceled_,
                  self,0,0);
  }
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00356960;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    HSArduinoDevice *device = [HSArduinoDevice defaultDevice];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:HSArduinoDeviceConnectionStatusDidChangeNotification object:device];
    [center removeObserver:self name:HSArduinoDevicePinStateDidChangeNotification object:device];
    if (![[self assistant] isActive]) {
        [_delegate actionPaneDidClose:self withApplier:nil canceled:NO];
    }
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    id pvVar1;
    NSNotificationCenter *self_00;

    [super viewWillAppear:aAppear];
    pvVar1 = [HSArduinoDevice defaultDevice];
    self_00 = [NSNotificationCenter defaultCenter];
    [self_00 addObserver:self selector:@selector(HSArdinoWatcherActionConfigurationAssistantPane_arduinoDeviceConnectionStateDidChange:) name:HSArduinoDeviceConnectionStatusDidChangeNotification object:pvVar1];
    [self_00 addObserver:self selector:@selector(HSArdinoWatcherActionConfigurationAssistantPane_pinDidUpdate:) name:HSArduinoDevicePinStateDidChangeNotification object:pvVar1];
    [self notePinConfigurationRangesChanged];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029bf8b @ 0029bf8b, 206 bytes * /

id FUN_0029bf8b(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  undefined *self_00;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pcVar3 = (cfstringStruct *)&DAT_00388ef8;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00388ef8);
  puVar1 = cls_NSString;
  self_00 = cls_HSArduinoWatcherAction;
  op = sel_localizedNameInInspector;
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(cls_HSArduinoWatcherAction,sel_localizedNameInInspector,pcVar3);
    _objc_msgSend(pvVar2,sel_hyperName);
    pcVar3 = &cfstr________;
    self_00 = puVar1;
    op = sel_stringWithFormat_;
  }
  pvVar2 = _objc_msgSend(self_00,op,pcVar3);
  return pvVar2;
}

*/
- (id)windowTitle
{
    id object = [[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)];
    if (object == nil) {
        return [HSArduinoWatcherAction localizedNameInInspector];
    }
    return [NSString stringWithFormat:@"%@ : %@", [HSArduinoWatcherAction localizedNameInInspector], [object hyperName]];
}

- (id)helpActionType
{
    return @"HSArduinoWatcherActionConfiguration";
}

- (id)actionType
{
    return [HSArduinoWatcherAction actionType];
}

- (Class)applierClass
{
    return Nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029c082 @ 0029c082, 249 bytes * /

void FUN_0029c082(HSArduinoWatcherActionConfigurationAssistantPane *self,SEL _cmd,
                 uchar HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin,
                 BOOL isPinDigital)

{
  id pvVar1;
  id self_00;
  uint uVar2;
  SEL op;
  uint uVar3;
  undefined2 *puVar4;
  undefined2 *puVar5;
  undefined2 local_18;
  undefined2 local_16;
  uint local_14;
  
  pvVar1 = self->_noPinValueRangeView;
  local_14 = 0xffffffff;
  local_16 = 0;
  local_18 = 0;
  op = sel_getMode_startValue_endValue_forAnalogPin_;
  if (isPinDigital != '\0') {
    op = sel_getMode_startValue_endValue_forDigitalPin_;
  }
  uVar2 = (uint)HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin;
  puVar5 = &local_18;
  puVar4 = &local_16;
  _objc_msgSend(self->_dataSource,op,&local_14,puVar4,puVar5,uVar2);
  if (4 < local_14) {
    uVar3 = local_14;
    _objc_msgSend(self->_pinModePopUp,sel_selectItemWithTag_,local_14,puVar4,puVar5,uVar2);
    if (pvVar1 != self->_pinValueRangeView) {
      self_00 = _objc_msgSend(self->_pinValueRangeView,sel_superview,uVar3,puVar4,puVar5,uVar2);
      _objc_msgSend(self_00,sel_replaceSubview_with_,self->_pinValueRangeView,pvVar1);
      self->_pinValueRangeView = pvVar1;
    }
    return;
  }
  (*(code *)(*(int *)(&UNK_0029c2dc + local_14 * 4) + 0x29c090))();
  return;
}

*/
- (void)HSArduinoWatcherActionConfigurationAssistantPane_validateSelectedPin:(unsigned char)aPin isPinDigital:(BOOL)aDigital
{
    NSView *valueView = _noPinValueRangeView;
    int mode = -1;
    unsigned short startValue = 0;
    unsigned short endValue = 0;
    if (aDigital) {
        [_dataSource getMode:&mode startValue:&startValue endValue:&endValue forDigitalPin:aPin];
    } else {
        [_dataSource getMode:&mode startValue:&startValue endValue:&endValue forAnalogPin:aPin];
    }
    unsigned short maximum = 0;
    switch (mode) {
    case 0:
    case 1:
        valueView = _digitalPinValueView;
        [_digitalPinValueMatrix selectCellWithTag:endValue];
        break;
    case 2:
        maximum = 1023;
        break;
    case 3:
        maximum = 255;
        break;
    case 4:
        maximum = 180;
        break;
    }
    if (maximum != 0) {
        NSNumber *number = [NSNumber numberWithUnsignedShort:maximum];
        if (number != nil) {
            [[_analogAndPWMPinStartValueTextField formatter] setMaximum:number];
        }
        [_analogAndPWMPinStartValueSpepper setMaxValue:maximum];
        [_analogAndPWMPinEndValueSpepper setMaxValue:maximum];
        valueView = _analogAndPWMPinValueRangeView;
        [_analogAndPWMPinStartValueTextField setIntValue:startValue];
        [_analogAndPWMPinStartValueSpepper setIntValue:startValue];
        [_analogAndPWMPinEndValueTextField setIntValue:endValue];
        [_analogAndPWMPinEndValueSpepper setIntValue:endValue];
    }
    [_pinModePopUp selectItemWithTag:mode];
    if (valueView != _pinValueRangeView) {
        [[_pinValueRangeView superview] replaceSubview:_pinValueRangeView with:valueView];
        _pinValueRangeView = valueView;
    }
}

- (void)awakeFromNib
{
    NSRect local_1c;

    local_1c = [_pinValueRangeView frame];
    [_digitalPinValueView setFrame:local_1c];
    [_analogAndPWMPinValueRangeView setFrame:local_1c];
    [_noPinModeMenu retain];
    [_noPinValueRangeView retain];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_grayStatusImage release];
    [_greenStatusImage release];
    [_redStatusImage release];
    if (_modeToTitleMap != nil) {
        CFRelease(_modeToTitleMap);
    }
    [_noPinModeMenu release];
    [_noPinValueRangeView release];
    [_indicesToReload release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ArduinoWatcherConfigurationAssistantPane"];
    return self;
}

@end

