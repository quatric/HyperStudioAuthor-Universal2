#import "HSArduinoSetupActionAssistantPane.h"

@implementation HSArduinoSetupActionAssistantPane

/* i386 ivar offsets: _pinConfigurationTableView=0x88, _pinModePopUp=0x8c, _analogPinModesMenu=0x90, _digitalPWMPinModesMenu=0x94, _digitalPinModesMenu=0x98, _noPinModeMenu=0x9c, _pinValueView=0xa0, _noPinValueView=0xa4, _digitalPinValueView=0xa8, _digitalPinValueMatrix=0xac, _PWMPinValueView=0xb0, _PWMPinValueSlider=0xb4, _PWMPinValueTextField=0xb8, _PWMPinValueSpepper=0xbc, _testButtonCell=0xc0, _modeToTitleMap=0xc4, _indicesToReload=0xc8, _isPinConfigurationBeingUndoneOrRedone=0xcc, _isFinished=0xcc, _isReloadScheduled=0xcc */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00295537 @ 00295537, 67 bytes * /

void FUN_00295537(HSArduinoSetupActionAssistantPane *self,SEL _cmd,id paneDidCancel)

{
  HSArduinoSetupActionAssistantPane *local_c;
  undefined *local_8;
  
  self->_isPinConfigurationBeingUndoneOrRedone[0] =
       self->_isPinConfigurationBeingUndoneOrRedone[0] | 2;
  local_c = self;
  local_8 = PTR_s_HSNBAAssistantPane_003568d0;
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
/* FUN_0029557a @ 0029557a, 67 bytes * /

void FUN_0029557a(HSArduinoSetupActionAssistantPane *self,SEL _cmd,id paneDidOK)

{
  HSArduinoSetupActionAssistantPane *local_c;
  undefined *local_8;
  
  self->_isPinConfigurationBeingUndoneOrRedone[0] =
       self->_isPinConfigurationBeingUndoneOrRedone[0] | 2;
  local_c = self;
  local_8 = PTR_s_HSNBAAssistantPane_003568d0;
  _objc_msgSendSuper(&local_c,sel_paneDidOK_,paneDidOK);
  return;
}

*/
- (void)paneDidOK:(id)aOK
{
    _isFinished = YES;
    [super paneDidOK:aOK];
}

- (void)testAction:(id)aAction
{
    [[[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] arduinoSetupActionAttributes] setupDevice];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294b13 @ 00294b13, 257 bytes * /

void FUN_00294b13(HSArduinoSetupActionAssistantPane *self,SEL _cmd,id selectPinValue)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  char cVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_pinConfigurationTableView,sel_selectedRow);
  pvVar2 = _objc_msgSend(self->_pinModePopUp,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_tag);
  self_00 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier);
  pvVar3 = _objc_msgSend(selectPinValue,sel_selectedCell);
  cVar4 = -0xc;
  if ((int)pvVar1 < 0xc) {
    cVar4 = '\x02';
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_tag);
  op = sel_setMode_value_forAnalogPin_;
  if ((int)pvVar1 < 0xc) {
    op = sel_setMode_value_forDigitalPin_;
  }
  _objc_msgSend(self_00,op,pvVar2,(uint)pvVar3 & 0xffff,(uint)(byte)(cVar4 + (char)pvVar1));
  return;
}

*/
- (void)selectPinValue:(id)aValue
{
    NSInteger row = [_pinConfigurationTableView selectedRow];
    NSInteger mode = [[_pinModePopUp selectedItem] tag];
    HSArduinoSetupActionPaneApplier *applier = [self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier];
    /* Rows 0..11 are digital pins 2..13, rows 12..17 analog pins 0..5. */
    unsigned char pin = (unsigned char)(row + (row < 12 ? 2 : -12));
    unsigned short value = (unsigned short)[[aValue selectedCell] tag];
    if (row < 12) {
        [applier setMode:mode value:value forDigitalPin:pin];
    } else {
        [applier setMode:mode value:value forAnalogPin:pin];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294a24 @ 00294a24, 239 bytes * /

void FUN_00294a24(HSArduinoSetupActionAssistantPane *self,SEL _cmd,id changePinValue)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  char cVar4;
  SEL op;
  
  pvVar1 = _objc_msgSend(self->_pinConfigurationTableView,sel_selectedRow);
  pvVar2 = _objc_msgSend(self->_pinModePopUp,sel_selectedItem);
  pvVar2 = _objc_msgSend(pvVar2,sel_tag);
  self_00 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier);
  cVar4 = -0xc;
  if ((int)pvVar1 < 0xc) {
    cVar4 = '\x02';
  }
  pvVar3 = _objc_msgSend(changePinValue,sel_intValue);
  op = sel_setMode_value_forAnalogPin_;
  if ((int)pvVar1 < 0xc) {
    op = sel_setMode_value_forDigitalPin_;
  }
  _objc_msgSend(self_00,op,pvVar2,(uint)pvVar3 & 0xffff,(uint)(byte)(cVar4 + (char)pvVar1));
  return;
}

*/
- (void)changePinValue:(id)aValue
{
    NSInteger row = [_pinConfigurationTableView selectedRow];
    NSInteger mode = [[_pinModePopUp selectedItem] tag];
    HSArduinoSetupActionPaneApplier *applier = [self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier];
    /* Rows 0..11 are digital pins 2..13, rows 12..17 analog pins 0..5. */
    unsigned char pin = (unsigned char)(row + (row < 12 ? 2 : -12));
    unsigned short value = (unsigned short)[aValue intValue];
    if (row < 12) {
        [applier setMode:mode value:value forDigitalPin:pin];
    } else {
        [applier setMode:mode value:value forAnalogPin:pin];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294830 @ 00294830, 500 bytes * /

void FUN_00294830(HSArduinoSetupActionAssistantPane *self,SEL _cmd,id changePinMode)

{
  byte bVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id self_01;
  SEL pcVar4;
  char local_17;
  ushort local_16;
  int local_14;
  
  pvVar2 = _objc_msgSend(self->_pinConfigurationTableView,sel_selectedRow);
  self_00 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier);
  pvVar3 = _objc_msgSend(self->_pinModePopUp,sel_selectedItem);
  local_17 = -0xc;
  if ((int)pvVar2 < 0xc) {
    local_17 = '\x02';
  }
  bVar1 = local_17 + (char)pvVar2;
  pvVar3 = _objc_msgSend(pvVar3,sel_tag);
  if (pvVar3 == (id)0xffffffff) {
    pcVar4 = sel_removeConfigurationForAnalogPin_;
    if ((int)pvVar2 < 0xc) {
      pcVar4 = sel_removeConfigurationForDigitalPin_;
    }
    pvVar3 = (id)(uint)bVar1;
  }
  else {
    local_14 = 0;
    local_16 = 0;
    self_01 = _objc_msgSend(self_00,sel_arduinoSetupActionAttributes);
    pcVar4 = sel_getMode_value_forAnalogPin_;
    if ((int)pvVar2 < 0xc) {
      pcVar4 = sel_getMode_value_forDigitalPin_;
    }
    _objc_msgSend(self_01,pcVar4,&local_14,&local_16,(uint)bVar1);
    if (pvVar3 == (id)0x4) {
      if (local_14 == 1) {
        if (local_16 == 1) {
          local_16 = 0xb4;
        }
      }
      else if (local_14 == 3) {
        local_16 = (ushort)(((uint)local_16 * 0xb4) / 0xff);
      }
    }
    else if (pvVar3 == (id)0x3) {
      if (local_14 == 1) {
        if (local_16 == 1) {
          local_16 = 0xff;
        }
      }
      else if (local_14 == 4) {
        local_16 = (ushort)(((uint)local_16 * 0xff) / 0xb4);
      }
    }
    else if ((pvVar3 == (id)0x1) && (1 < local_16)) {
      local_16 = 1;
    }
    pcVar4 = sel_setMode_value_forAnalogPin_;
    if ((int)pvVar2 < 0xc) {
      pcVar4 = sel_setMode_value_forDigitalPin_;
    }
  }
  _objc_msgSend(self_00,pcVar4,pvVar3);
  return;
}

*/
- (void)changePinMode:(id)aMode
{
    NSInteger row = [_pinConfigurationTableView selectedRow];
    HSArduinoSetupActionPaneApplier *applier = [self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier];
    unsigned char pin = (unsigned char)(row + (row < 12 ? 2 : -12));
    NSInteger newMode = [[_pinModePopUp selectedItem] tag];
    if (newMode == -1) {
        if (row < 12) {
            [applier removeConfigurationForDigitalPin:pin];
        } else {
            [applier removeConfigurationForAnalogPin:pin];
        }
        return;
    }
    int oldMode = 0;
    unsigned short value = 0;
    id<HSArduinoPinConfigurationAttribute> attributes = (id)[applier arduinoSetupActionAttributes];
    if (row < 12) {
        [attributes getMode:&oldMode value:&value forDigitalPin:pin];
    } else {
        [attributes getMode:&oldMode value:&value forAnalogPin:pin];
    }
    /* Carry the value over between output (0/1), PWM (0..255) and servo (0..180). */
    if (newMode == 4) {
        if (oldMode == 1) {
            if (value == 1) {
                value = 180;
            }
        } else if (oldMode == 3) {
            value = (unsigned short)(((unsigned int)value * 180) / 255);
        }
    } else if (newMode == 3) {
        if (oldMode == 1) {
            if (value == 1) {
                value = 255;
            }
        } else if (oldMode == 4) {
            value = (unsigned short)(((unsigned int)value * 255) / 180);
        }
    } else if (newMode == 1 && value > 1) {
        value = 1;
    }
    if (row < 12) {
        [applier setMode:newMode value:value forDigitalPin:pin];
    } else {
        [applier setMode:newMode value:value forAnalogPin:pin];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294685 @ 00294685, 427 bytes * /

void FUN_00294685(HSArduinoSetupActionAssistantPane *self,SEL _cmd,id tableViewSelectionDidChange)

{
  id pvVar1;
  id self_00;
  id *ppvVar2;
  byte bVar3;
  char cVar4;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(self->_pinConfigurationTableView,sel_selectedRow);
  if (pvVar1 == (id)0xffffffff) {
    _objc_msgSend(self->_pinModePopUp,sel_setMenu_,self->_noPinModeMenu);
    uVar5 = 0xffffffff;
    _objc_msgSend(self->_pinModePopUp,sel_selectItemWithTag_,0xffffffff);
    if (self->_pinValueView != self->_noPinValueView) {
      self_00 = _objc_msgSend(self->_pinValueView,sel_superview,uVar5);
      _objc_msgSend(self_00,sel_replaceSubview_with_,self->_pinValueView,self->_noPinValueView);
      self->_pinValueView = self->_noPinValueView;
    }
    goto LAB_002947fd;
  }
  if ((int)pvVar1 < 0xc) {
    bVar3 = (char)pvVar1 + 2;
    if (bVar3 < 0xe) {
      if ((0x3194U >> (bVar3 & 0x1f) & 1) == 0) {
        if ((0xe68U >> (bVar3 & 0x1f) & 1) == 0) goto LAB_0029478b;
        ppvVar2 = &self->_digitalPWMPinModesMenu;
        cVar4 = '\x01';
      }
      else {
        ppvVar2 = &self->_digitalPinModesMenu;
        cVar4 = '\x01';
      }
    }
    else {
LAB_0029478b:
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
  _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_validateSelectedPin_isPinDigital_,
                (uint)bVar3,(int)cVar4);
LAB_002947fd:
  _objc_msgSend(self->_pinModePopUp,sel_setEnabled_,(uint)(-1 < (int)pvVar1));
  return;
}

*/
- (void)tableViewSelectionDidChange:(id)aChange
{
    NSInteger row = [_pinConfigurationTableView selectedRow];
    if (row == -1) {
        [_pinModePopUp setMenu:_noPinModeMenu];
        [_pinModePopUp selectItemWithTag:-1];
        if (_pinValueView != _noPinValueView) {
            [[_pinValueView superview] replaceSubview:_pinValueView with:_noPinValueView];
            _pinValueView = _noPinValueView;
        }
    } else {
        NSMenu *menu;
        unsigned char pin;
        BOOL isDigital;
        if (row < 12) {
            pin = (unsigned char)(row + 2);
            isDigital = YES;
            /* PWM capable pins: 3, 5, 6, 9, 10, 11. */
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
        [self HSArdinoSetupActionAssistantPane_validateSelectedPin:pin isPinDigital:isDigital];
    }
    [_pinModePopUp setEnabled:row >= 0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294418 @ 00294418, 621 bytes * /

void FUN_00294418(HSArduinoSetupActionAssistantPane *self,SEL _cmd,id tableView,id willDisplayCell,
                 id forTableColumn,int row)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  SEL pcVar4;
  uint uVar5;
  byte bVar6;
  bool bVar7;
  cfstringStruct *pcVar8;
  int *piVar9;
  undefined4 uVar10;
  int local_14;
  
  pvVar2 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar8 = &cfstr_mode;
  cVar1 = -0xc;
  if (row < 0xc) {
    cVar1 = '\x02';
  }
  bVar6 = (char)row + cVar1;
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_mode);
  if ((char)pvVar3 == '\0') {
    pcVar8 = &cfstr_value;
    pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_value);
    if ((char)pvVar3 == '\0') {
      pcVar8 = &cfstr_status;
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_status);
      if ((char)pvVar2 == '\0') {
        return;
      }
      pvVar2 = _objc_msgSend(cls_HSArduinoDevice,sel_defaultDevice,pcVar8);
      pvVar2 = _objc_msgSend(pvVar2,sel_connectionStatus);
      pcVar4 = sel_disabledControlTextColor;
      if (pvVar2 == (id)0x6) {
        pcVar4 = sel_controlTextColor;
      }
      pvVar2 = _objc_msgSend(cls_NSColor,pcVar4,pcVar8);
      goto LAB_00294507;
    }
    pvVar2 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier,
                           pcVar8);
    pvVar2 = _objc_msgSend(pvVar2,sel_arduinoSetupActionAttributes);
    if (row < 0xc) {
      uVar5 = (uint)bVar6;
      piVar9 = &local_14;
      uVar10 = 0;
      pvVar2 = _objc_msgSend(pvVar2,sel_getMode_value_forDigitalPin_,piVar9,0,uVar5);
      pcVar4 = sel_disabledControlTextColor;
      if ((char)pvVar2 != '\0') {
        bVar7 = local_14 == 0;
LAB_002945e6:
        pcVar4 = sel_disabledControlTextColor;
        if (!bVar7) goto LAB_002944d3;
      }
    }
    else {
      uVar5 = (uint)bVar6;
      piVar9 = &local_14;
      uVar10 = 0;
      pvVar2 = _objc_msgSend(pvVar2,sel_getMode_value_forAnalogPin_,piVar9,0,uVar5);
      pcVar4 = sel_disabledControlTextColor;
      if ((char)pvVar2 != '\0') {
        bVar7 = local_14 == 0 || local_14 == 2;
        goto LAB_002945e6;
      }
    }
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier,
                           pcVar8);
    pvVar2 = _objc_msgSend(pvVar2,sel_arduinoSetupActionAttributes);
    pcVar4 = sel_getMode_value_forAnalogPin_;
    if (row < 0xc) {
      pcVar4 = sel_getMode_value_forDigitalPin_;
    }
    uVar5 = (uint)bVar6;
    uVar10 = 0;
    piVar9 = (int *)0x0;
    pvVar2 = _objc_msgSend(pvVar2,pcVar4,0,0,uVar5);
    pcVar4 = sel_disabledControlTextColor;
    if ((char)pvVar2 == '\0') goto LAB_002944e7;
LAB_002944d3:
    pcVar4 = sel_controlTextColor;
  }
LAB_002944e7:
  pvVar2 = _objc_msgSend(cls_NSColor,pcVar4,piVar9,uVar10,uVar5);
LAB_00294507:
  _objc_msgSend(willDisplayCell,sel_setTextColor_,pvVar2);
  return;
}

*/
- (void)tableView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    NSString *identifier = [aColumn identifier];
    unsigned char pin = (unsigned char)(aRow + (aRow < 12 ? 2 : -12));
    BOOL enabled;
    if ([identifier isEqualToString:@"mode"]) {
        id<HSArduinoPinConfigurationAttribute> attributes = (id)[[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] arduinoSetupActionAttributes];
        if (aRow < 12) {
            enabled = [attributes getMode:NULL value:NULL forDigitalPin:pin];
        } else {
            enabled = [attributes getMode:NULL value:NULL forAnalogPin:pin];
        }
    } else if ([identifier isEqualToString:@"value"]) {
        id<HSArduinoPinConfigurationAttribute> attributes = (id)[[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] arduinoSetupActionAttributes];
        int mode;
        if (aRow < 12) {
            /* Digital inputs have no value to set. */
            enabled = [attributes getMode:&mode value:NULL forDigitalPin:pin] && mode != 0;
        } else {
            /* Neither do analog or digital inputs on the analog pins. */
            enabled = [attributes getMode:&mode value:NULL forAnalogPin:pin] && mode != 0 && mode != 2;
        }
    } else if ([identifier isEqualToString:@"status"]) {
        enabled = [[HSArduinoDevice defaultDevice] connectionStatus] == 6;
    } else {
        return;
    }
    [aCell setTextColor:enabled ? [NSColor controlTextColor] : [NSColor disabledControlTextColor]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002955bd @ 002955bd, 1743 bytes * /

id FUN_002955bd(HSArduinoSetupActionAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  undefined *puVar5;
  uint uVar6;
  cfstringStruct *pcVar7;
  SEL pcVar8;
  cfstringStruct *pcVar9;
  byte bVar10;
  undefined **ppuVar11;
  short *psVar12;
  undefined1 local_22 [8];
  short local_1a;
  undefined *local_18;
  int local_14;
  
  pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  cVar1 = -0xc;
  if (row < 0xc) {
    cVar1 = '\x02';
  }
  bVar10 = (char)row + cVar1;
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_pin);
  if ((char)pvVar3 != '\0') {
    if (row < 0xc) {
      pcVar4 = (cfstringStruct *)(uint)bVar10;
      puVar5 = cls_NSNumber;
      pcVar8 = sel_numberWithUnsignedChar_;
    }
    else {
      pcVar4 = &cfstr_A_d;
      puVar5 = cls_NSString;
      pcVar8 = sel_stringWithFormat_;
    }
    goto LAB_00295657;
  }
  pcVar4 = &cfstr_mode;
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_mode);
  if ((char)pvVar3 != '\0') {
    local_14 = -1;
    pvVar2 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier,
                           pcVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_arduinoSetupActionAttributes);
    pcVar8 = sel_getMode_value_forAnalogPin_;
    if (row < 0xc) {
      pcVar8 = sel_getMode_value_forDigitalPin_;
    }
    _objc_msgSend(pvVar2,pcVar8,&local_14,0,(uint)bVar10);
    pvVar2 = _objc_msgSend(self,sel_HSArduinoSetupActionAssistantPane_modeToTitleMap);
    if (pvVar2 != (id)0x0) {
      pvVar2 = (id)_CFDictionaryGetValue(self->_modeToTitleMap,local_14);
      return pvVar2;
    }
    goto switchD_002957f6_default;
  }
  pcVar4 = &cfstr_value;
  pvVar3 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_value);
  if ((char)pvVar3 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier,
                           pcVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_arduinoSetupActionAttributes);
    pcVar8 = sel_getMode_value_forAnalogPin_;
    if (row < 0xc) {
      pcVar8 = sel_getMode_value_forDigitalPin_;
    }
    uVar6 = (uint)bVar10;
    psVar12 = &local_1a;
    ppuVar11 = &local_18;
    pvVar2 = _objc_msgSend(pvVar2,pcVar8,ppuVar11,psVar12,uVar6);
    if ((char)pvVar2 == '\0') {
      puVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,ppuVar11,psVar12,uVar6);
      pcVar4 = &cfstr_No_Change;
      pcVar8 = sel_localizedStringForKey_value_table_;
    }
    else {
      switch(local_18) {
      case (undefined *)0x0:
      case (undefined *)0x2:
        puVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,ppuVar11,psVar12,uVar6);
        pcVar4 = &cfstr_External;
        pcVar8 = sel_localizedStringForKey_value_table_;
        break;
      case (undefined *)0x1:
        puVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,ppuVar11,psVar12,uVar6);
        if (local_1a == 0) {
          pcVar4 = &cfstr_Low;
          pcVar8 = sel_localizedStringForKey_value_table_;
        }
        else {
          pcVar4 = &cfstr_High;
          pcVar8 = sel_localizedStringForKey_value_table_;
        }
        break;
      case (undefined *)0x3:
      case (undefined *)0x4:
        pcVar4 = &cfstr__hu;
        puVar5 = cls_NSString;
        pcVar8 = sel_stringWithFormat_;
        break;
      default:
        goto switchD_002957f6_default;
      }
    }
    goto LAB_00295657;
  }
  pcVar4 = &cfstr_status;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_status);
  if ((char)pvVar2 == '\0') {
switchD_002957f6_default:
    pvVar2 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(cls_HSArduinoDevice,sel_defaultDevice,pcVar4);
    pvVar3 = _objc_msgSend(pvVar2,sel_connectionStatus);
    switch(pvVar3) {
    case (id)0x0:
      puVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
      pcVar4 = &cfstr_No_device;
      pcVar8 = sel_localizedStringForKey_value_table_;
      break;
    case (id)0x1:
      puVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
      pcVar4 = &cfstr_Searching;
      pcVar8 = sel_localizedStringForKey_value_table_;
      break;
    default:
      goto switchD_002957f6_default;
    case (id)0x3:
      puVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
      pcVar4 = &cfstr_Outdated_protocol;
      pcVar8 = sel_localizedStringForKey_value_table_;
      break;
    case (id)0x4:
      puVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
      pcVar4 = &cfstr_Unsupported_protocol;
      pcVar8 = sel_localizedStringForKey_value_table_;
      break;
    case (id)0x5:
      puVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar4);
      pcVar4 = &cfstr_Unsupported_firmware;
      pcVar8 = sel_localizedStringForKey_value_table_;
      break;
    case (id)0x6:
      if (row < 0xc) {
        pcVar7 = (cfstringStruct *)(uint)bVar10;
        pcVar4 = (cfstringStruct *)local_22;
        pcVar9 = (cfstringStruct *)(local_22 + 2);
        pvVar2 = _objc_msgSend(pvVar2,sel_getMode_value_forDigitalPin_,pcVar9,pcVar4,pcVar7);
        if ((char)pvVar2 == '\0') {
          pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar9,pcVar4,pcVar7);
LAB_00295b36:
          pcVar7 = &cfstr_AssistantPanes;
          pcVar4 = &cfstr_empty;
          pcVar9 = &cfstr_No_device;
          pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_No_device,
                                 &cfstr_empty,&cfstr_AssistantPanes);
          if (pvVar2 != (id)0x0) {
            return pvVar2;
          }
        }
      }
      else {
        pcVar7 = (cfstringStruct *)(uint)bVar10;
        pcVar4 = (cfstringStruct *)local_22;
        pcVar9 = (cfstringStruct *)(local_22 + 2);
        pvVar2 = _objc_msgSend(pvVar2,sel_getMode_value_forAnalogPin_,pcVar9,pcVar4,pcVar7);
        if ((char)pvVar2 == '\0') {
          pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar9,pcVar4,pcVar7);
          goto LAB_00295b36;
        }
      }
      pvVar2 = _objc_msgSend(self,sel_HSArduinoSetupActionAssistantPane_modeToTitleMap,pcVar9,pcVar4
                             ,pcVar7);
      if (pvVar2 != (id)0x0) {
        _CFDictionaryGetValue(self->_modeToTitleMap,local_22._2_4_);
      }
      if ((uint)local_22._2_4_ < 2) {
        puVar5 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pcVar9,pcVar4,pcVar7);
        pcVar8 = sel_localizedStringForKey_value_table_;
        if (local_22._0_2_ == 0) {
          pcVar7 = &cfstr_AssistantPanes;
          pcVar4 = &cfstr_empty;
          pcVar9 = &cfstr_Low;
        }
        else {
          pcVar7 = &cfstr_AssistantPanes;
          pcVar4 = &cfstr_empty;
          pcVar9 = &cfstr_High;
        }
      }
      else {
        pcVar4 = (cfstringStruct *)(uint)(ushort)local_22._0_2_;
        pcVar9 = &cfstr__hu;
        puVar5 = cls_NSString;
        pcVar8 = sel_stringWithFormat_;
      }
      _objc_msgSend(puVar5,pcVar8,pcVar9,pcVar4,pcVar7);
      puVar5 = cls_NSString;
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      pcVar4 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr________,
                             &cfstr_empty,&cfstr_AssistantPanes);
      pcVar8 = sel_stringWithFormat_;
    }
LAB_00295657:
    pvVar2 = _objc_msgSend(puVar5,pcVar8,pcVar4);
  }
  return pvVar2;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    NSString *identifier = [aColumn identifier];
    unsigned char pin = (unsigned char)(aRow + (aRow < 12 ? 2 : -12));
    if ([identifier isEqualToString:@"pin"]) {
        if (aRow < 12) {
            return [NSNumber numberWithUnsignedChar:pin];
        }
        return [NSString stringWithFormat:@"A%d", pin];
    }
    if ([identifier isEqualToString:@"mode"]) {
        int mode = -1;
        id<HSArduinoPinConfigurationAttribute> attributes = (id)[[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] arduinoSetupActionAttributes];
        if (aRow < 12) {
            [attributes getMode:&mode value:NULL forDigitalPin:pin];
        } else {
            [attributes getMode:&mode value:NULL forAnalogPin:pin];
        }
        if ([self HSArduinoSetupActionAssistantPane_modeToTitleMap] == NULL) {
            return nil;
        }
        return (id)CFDictionaryGetValue(_modeToTitleMap, (const void *)(intptr_t)mode);
    }
    if ([identifier isEqualToString:@"value"]) {
        int mode;
        unsigned short value;
        BOOL configured;
        id<HSArduinoPinConfigurationAttribute> attributes = (id)[[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] arduinoSetupActionAttributes];
        if (aRow < 12) {
            configured = [attributes getMode:&mode value:&value forDigitalPin:pin];
        } else {
            configured = [attributes getMode:&mode value:&value forAnalogPin:pin];
        }
        if (!configured) {
            return [[NSBundle mainBundle] localizedStringForKey:@"No Change" value:@"" table:@"AssistantPanes"];
        }
        switch (mode) {
            case 0:
            case 2:
                return [[NSBundle mainBundle] localizedStringForKey:@"External" value:@"" table:@"AssistantPanes"];
            case 1:
                return value == 0 ? [[NSBundle mainBundle] localizedStringForKey:@"Low" value:@"" table:@"AssistantPanes"] : [[NSBundle mainBundle] localizedStringForKey:@"High" value:@"" table:@"AssistantPanes"];
            case 3:
            case 4:
                return [NSString stringWithFormat:@"%hu", value];
            default:
                return nil;
        }
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
        case 6:
            break;
        default:
            return nil;
    }
    /* Connected: show the pin's live mode and value. */
    int mode;
    unsigned short value;
    BOOL known;
    if (aRow < 12) {
        known = [device getMode:&mode value:&value forDigitalPin:pin];
    } else {
        known = [device getMode:&mode value:&value forAnalogPin:pin];
    }
    if (!known) {
        return [[NSBundle mainBundle] localizedStringForKey:@"No device" value:@"" table:@"AssistantPanes"];
    }
    NSString *modeTitle = nil;
    if ([self HSArduinoSetupActionAssistantPane_modeToTitleMap] != NULL) {
        modeTitle = (NSString *)CFDictionaryGetValue(_modeToTitleMap, (const void *)(intptr_t)mode);
    }
    NSString *valueString;
    if ((unsigned int)mode < 2) {
        valueString = value == 0 ? [[NSBundle mainBundle] localizedStringForKey:@"Low" value:@"" table:@"AssistantPanes"] : [[NSBundle mainBundle] localizedStringForKey:@"High" value:@"" table:@"AssistantPanes"];
    } else {
        valueString = [NSString stringWithFormat:@"%hu", value];
    }
    return [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"%@ / %@" value:@"" table:@"AssistantPanes"], modeTitle, valueString];
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return 0x12;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00295cbc @ 00295cbc, 354 bytes * /

CFDictionary * FUN_00295cbc(HSArduinoSetupActionAssistantPane *self,SEL _cmd)

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
- (struct __CFDictionary *)HSArduinoSetupActionAssistantPane_modeToTitleMap
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
                CFDictionarySetValue(_modeToTitleMap, (const void *)2, title);
            }
        }
    }
    return _modeToTitleMap;
}

- (id)initialKeyView
{
    return _pinConfigurationTableView;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    id pvVar1;
    NSNotificationCenter *self_00;
    id pvVar1_4;

    pvVar1 = [HSArduinoDevice defaultDevice];
    self_00 = [NSNotificationCenter defaultCenter];
    [self_00 removeObserver:self name:HSArduinoDeviceConnectionStatusDidChangeNotification object:pvVar1];
    [self_00 removeObserver:self name:HSArduinoDevicePinStateDidChangeNotification object:pvVar1];
    pvVar1_4 = [[[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] arduinoSetupActionAttributes] attributeObservingController];
    [pvVar1_4 removeObserver:self selector:@selector(HSArdinoSetupActionAssistantPane_pinConfigurationDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSArduinoPinConfigurationAttribute)];
    [pvVar1_4 removeObserver:self selector:@selector(HSArdinoSetupActionAssistantPane_pinConfigurationWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSArduinoPinConfigurationAttribute)];
    [pvVar1_4 removeObserver:self selector:@selector(HSArdinoSetupActionAssistantPane_pinConfigurationWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSArduinoPinConfigurationAttribute)];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00295fc5 @ 00295fc5, 529 bytes * /

void FUN_00295fc5(HSArduinoSetupActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id self_00;
  HSArduinoSetupActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_003568d0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  self->_isPinConfigurationBeingUndoneOrRedone[0] =
       self->_isPinConfigurationBeingUndoneOrRedone[0] & 0xfd;
  pvVar1 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier);
  pvVar1 = _objc_msgSend(pvVar1,sel_arduinoSetupActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSArdinoSetupActionAssistantPane_pinConfigurationDidChange_,
                *(undefined4 *)PTR_0033601c,&DAT_00388b74,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSArdinoSetupActionAssistantPane_pinConfigurationWillBeUndoneOrRedone_,0x100,
                &DAT_00388b74,0xbe800000);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                sel_HSArdinoSetupActionAssistantPane_pinConfigurationWasUndoneOrRedone_,0x200,
                &DAT_00388b74,0xbe800000);
  pvVar1 = _objc_msgSend(cls_HSArduinoDevice,sel_defaultDevice);
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(self_00,sel_addObserver_selector_name_object_,self,
                sel_HSArdinoSetupActionAssistantPane_arduinoDeviceConnectionStateDidChange_,
                *(undefined4 *)PTR_003369f8,pvVar1);
  _objc_msgSend(self_00,sel_addObserver_selector_name_object_,self,
                sel_HSArdinoSetupActionAssistantPane_pinDidUpdate_,*(undefined4 *)PTR_00336a04,
                pvVar1);
  _objc_msgSend(self->_pinConfigurationTableView,sel_reloadData);
  _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_validateTestButton);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    _isFinished = NO;
    id controller = [[[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] arduinoSetupActionAttributes] attributeObservingController];
    [controller addObserver:self selector:@selector(HSArdinoSetupActionAssistantPane_pinConfigurationDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSArduinoPinConfigurationAttribute) withPriority:-0.25];
    [controller addObserver:self selector:@selector(HSArdinoSetupActionAssistantPane_pinConfigurationWillBeUndoneOrRedone:) ofChanges:0x100 ofAttribute:@protocol(HSArduinoPinConfigurationAttribute) withPriority:-0.25];
    [controller addObserver:self selector:@selector(HSArdinoSetupActionAssistantPane_pinConfigurationWasUndoneOrRedone:) ofChanges:0x200 ofAttribute:@protocol(HSArduinoPinConfigurationAttribute) withPriority:-0.25];
    HSArduinoDevice *device = [HSArduinoDevice defaultDevice];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(HSArdinoSetupActionAssistantPane_arduinoDeviceConnectionStateDidChange:) name:HSArduinoDeviceConnectionStatusDidChangeNotification object:device];
    [center addObserver:self selector:@selector(HSArdinoSetupActionAssistantPane_pinDidUpdate:) name:HSArduinoDevicePinStateDidChangeNotification object:device];
    [_pinConfigurationTableView reloadData];
    [self HSArdinoSetupActionAssistantPane_validateTestButton];
}

- (id)actionType
{
    return [HSArduinoSetupAction actionType];
}

- (Class)applierClass
{
    return [HSArduinoSetupActionPaneApplier class];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294383 @ 00294383, 67 bytes * /

void FUN_00294383(HSArduinoSetupActionAssistantPane *self,SEL _cmd,
                 id HSArdinoSetupActionAssistantPane_pinConfigurationWasUndoneOrRedone)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier);
  _objc_msgSend(self_00,sel_resetPinConfigurationDictionary);
  self->_isPinConfigurationBeingUndoneOrRedone[0] =
       self->_isPinConfigurationBeingUndoneOrRedone[0] & 0xfe;
  return;
}

*/
- (void)HSArdinoSetupActionAssistantPane_pinConfigurationWasUndoneOrRedone:(id)aRedone
{
    [[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] resetPinConfigurationDictionary];
    _isPinConfigurationBeingUndoneOrRedone = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294342 @ 00294342, 65 bytes * /

void FUN_00294342(HSArduinoSetupActionAssistantPane *self,SEL _cmd,
                 id HSArdinoSetupActionAssistantPane_pinConfigurationWillBeUndoneOrRedone)

{
  id self_00;
  
  self->_isPinConfigurationBeingUndoneOrRedone[0] =
       self->_isPinConfigurationBeingUndoneOrRedone[0] | 1;
  self_00 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier);
  _objc_msgSend(self_00,sel_restorePinConfigurationDictionary);
  return;
}

*/
- (void)HSArdinoSetupActionAssistantPane_pinConfigurationWillBeUndoneOrRedone:(id)aRedone
{
    _isPinConfigurationBeingUndoneOrRedone = YES;
    [[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] restorePinConfigurationDictionary];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294136 @ 00294136, 524 bytes * /

void FUN_00294136(HSArduinoSetupActionAssistantPane *self,SEL _cmd,
                 id HSArdinoSetupActionAssistantPane_pinConfigurationDidChange)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  char cVar5;
  byte bVar6;
  bool bVar7;
  SEL pcVar8;
  cfstringStruct *pcVar9;
  
  if ((self->_isPinConfigurationBeingUndoneOrRedone[0] & 1) != 0) {
    return;
  }
  if ((self->_isPinConfigurationBeingUndoneOrRedone[0] & 2) != 0) {
    return;
  }
  pvVar1 = _objc_msgSend(HSArdinoSetupActionAssistantPane_pinConfigurationDidChange,sel_userInfo);
  pcVar4 = &cfstr_digitalPin;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_digitalPin);
  bVar7 = pvVar1 == (id)0x0;
  if (bVar7) {
    pvVar1 = _objc_msgSend(HSArdinoSetupActionAssistantPane_pinConfigurationDidChange,sel_userInfo,
                           pcVar4);
    pcVar4 = &cfstr_analogPin;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_analogPin);
  }
  bVar7 = !bVar7;
  pvVar2 = _objc_msgSend(pvVar1,sel_unsignedCharValue,pcVar4);
  pvVar3 = _objc_msgSend(self->_pinConfigurationTableView,sel_selectedRow);
  if (-1 < (int)pvVar3) {
    cVar5 = -0xc;
    if ((int)pvVar3 < 0xc) {
      cVar5 = '\x02';
    }
    bVar6 = cVar5 + (char)pvVar3;
    if ((pvVar1 == (id)0x0) || (((byte)pvVar2 == bVar6 && ((int)pvVar3 < 0xc == bVar7)))) {
      pcVar4 = (cfstringStruct *)(uint)bVar6;
      _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_validateSelectedPin_isPinDigital_,
                    pcVar4,(uint)((int)pvVar3 < 0xc));
    }
  }
  if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
    pvVar1 = self->_pinConfigurationTableView;
    pcVar8 = sel_reloadData;
  }
  else {
    if (pvVar1 == (id)0x0) {
      pcVar9 = (cfstringStruct *)0x0;
      pcVar8 = sel_indexSetWithIndexesInRange_;
    }
    else {
      pcVar8 = sel_indexSetWithIndex_;
      if (bVar7) {
        pcVar9 = (cfstringStruct *)(((uint)pvVar2 & 0xff) - 2);
      }
      else {
        pcVar9 = (cfstringStruct *)(((uint)pvVar2 & 0xff) + 0xc);
      }
    }
    pcVar4 = _objc_msgSend(cls_NSIndexSet,pcVar8,pcVar9);
    if (pcVar4 == (cfstringStruct *)0x0) goto LAB_00294325;
    pcVar9 = (cfstringStruct *)0x1;
    pvVar1 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndexesInRange_,1,2);
    if (pvVar1 == (id)0x0) goto LAB_00294325;
    pvVar1 = self->_pinConfigurationTableView;
    pcVar8 = sel_reloadDataForRowIndexes_columnIndexes_;
  }
  _objc_msgSend(pvVar1,pcVar8,pcVar4);
  pcVar9 = pcVar4;
LAB_00294325:
  _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_validateTestButton,pcVar9);
  return;
}

*/
- (void)HSArdinoSetupActionAssistantPane_pinConfigurationDidChange:(id)aChange
{
    if (_isPinConfigurationBeingUndoneOrRedone || _isFinished) {
        return;
    }
    NSNumber *pinNumber = [[aChange userInfo] objectForKey:@"digitalPin"];
    BOOL isDigital = pinNumber != nil;
    if (!isDigital) {
        pinNumber = [[aChange userInfo] objectForKey:@"analogPin"];
    }
    unsigned char changedPin = [pinNumber unsignedCharValue];
    NSInteger row = [_pinConfigurationTableView selectedRow];
    if (row >= 0) {
        unsigned char pin = (unsigned char)(row + (row < 12 ? 2 : -12));
        if (pinNumber == nil || (changedPin == pin && (row < 12) == isDigital)) {
            [self HSArdinoSetupActionAssistantPane_validateSelectedPin:pin isPinDigital:row < 12];
        }
    }
    if (NSAppKitVersionNumber < 1038.0) {
        [_pinConfigurationTableView reloadData];
    } else {
        NSIndexSet *rows;
        if (pinNumber == nil) {
            rows = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 18)];
        } else if (isDigital) {
            rows = [NSIndexSet indexSetWithIndex:changedPin - 2];
        } else {
            rows = [NSIndexSet indexSetWithIndex:changedPin + 12];
        }
        if (rows != nil) {
            NSIndexSet *columns = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
            if (columns != nil) {
                [_pinConfigurationTableView reloadDataForRowIndexes:rows columnIndexes:columns];
            }
        }
    }
    [self HSArdinoSetupActionAssistantPane_validateTestButton];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00293f40 @ 00293f40, 502 bytes * /

void FUN_00293f40(HSArduinoSetupActionAssistantPane *self,SEL _cmd,
                 id HSArdinoSetupActionAssistantPane_pinDidUpdate)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  
  if ((self->_isPinConfigurationBeingUndoneOrRedone[0] & 4) == 0) {
    self->_isPinConfigurationBeingUndoneOrRedone[0] =
         self->_isPinConfigurationBeingUndoneOrRedone[0] | 4;
    _objc_msgSend(self,sel_performSelector_withObject_afterDelay_,
                  sel_HSArdinoSetupActionAssistantPane_reloadDataRarely,0,0x9999999a,0x3fc99999);
  }
  if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
    pvVar1 = _objc_msgSend(HSArdinoSetupActionAssistantPane_pinDidUpdate,sel_userInfo);
    pvVar3 = *(id *)PTR_00336a00;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,pvVar3);
    pvVar2 = _objc_msgSend(pvVar1,sel_count);
    if (pvVar2 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy,pvVar3);
      if (pvVar1 != (id)0x0) {
        uVar4 = 0xfffffffe;
        pvVar3 = (id)0x2;
        _objc_msgSend(pvVar1,sel_shiftIndexesStartingAtIndex_by_,2,0xfffffffe);
        if (self->_indicesToReload == (id)0x0) {
          self->_indicesToReload = pvVar1;
        }
        else {
          pvVar3 = pvVar1;
          _objc_msgSend(self->_indicesToReload,sel_addIndexes_,pvVar1,uVar4);
          _objc_msgSend(pvVar1,sel_release);
        }
      }
    }
    pvVar3 = _objc_msgSend(HSArdinoSetupActionAssistantPane_pinDidUpdate,sel_userInfo,pvVar3);
    uVar4 = *(undefined4 *)PTR_003369fc;
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,uVar4);
    pvVar1 = _objc_msgSend(pvVar3,sel_count);
    if (pvVar1 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar3,sel_mutableCopy,uVar4);
      if (pvVar3 != (id)0x0) {
        uVar4 = 0xc;
        _objc_msgSend(pvVar3,sel_shiftIndexesStartingAtIndex_by_,0,0xc);
        if (self->_indicesToReload == (id)0x0) {
          self->_indicesToReload = pvVar3;
        }
        else {
          _objc_msgSend(self->_indicesToReload,sel_addIndexes_,pvVar3,uVar4);
          _objc_msgSend(pvVar3,sel_release);
        }
      }
    }
  }
  return;
}

*/
- (void)HSArdinoSetupActionAssistantPane_pinDidUpdate:(id)aUpdate
{
    if (!_isReloadScheduled) {
        _isReloadScheduled = YES;
        [self performSelector:@selector(HSArdinoSetupActionAssistantPane_reloadDataRarely) withObject:nil afterDelay:0.2];
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
/* FUN_00293e78 @ 00293e78, 200 bytes * /

void FUN_00293e78(HSArduinoSetupActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  self->_isPinConfigurationBeingUndoneOrRedone[0] =
       self->_isPinConfigurationBeingUndoneOrRedone[0] & 0xfb;
  if (*(double *)PTR_0033605c <= 1038.0 && *(double *)PTR_0033605c != 1038.0) {
    pvVar1 = self->_pinConfigurationTableView;
    op = sel_reloadData;
  }
  else {
    pvVar1 = _objc_msgSend(self->_indicesToReload,sel_count);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar1 = self->_pinConfigurationTableView;
    pvVar2 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,3);
    _objc_msgSend(pvVar1,sel_reloadDataForRowIndexes_columnIndexes_,self->_indicesToReload,pvVar2);
    pvVar1 = self->_indicesToReload;
    op = sel_removeAllIndexes;
  }
  _objc_msgSend(pvVar1,op);
  return;
}

*/
- (void)HSArdinoSetupActionAssistantPane_reloadDataRarely
{
    _isReloadScheduled = NO;
    if (NSAppKitVersionNumber < 1038.0) {
        [_pinConfigurationTableView reloadData];
        return;
    }
    if ([_indicesToReload count] == 0) {
        return;
    }
    [_pinConfigurationTableView reloadDataForRowIndexes:_indicesToReload columnIndexes:[NSIndexSet indexSetWithIndex:3]];
    [_indicesToReload removeAllIndexes];
}

- (void)HSArdinoSetupActionAssistantPane_arduinoDeviceConnectionStateDidChange:(id)aChange
{
    [self HSArdinoSetupActionAssistantPane_validateTestButton];
    [_pinConfigurationTableView reloadData];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002961d6 @ 002961d6, 260 bytes * /

void FUN_002961d6(HSArduinoSetupActionAssistantPane *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  int iVar3;
  
  pvVar2 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier);
  pvVar2 = _objc_msgSend(pvVar2,sel_arduinoSetupActionAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_digitalPinConfigurationDictionary);
  if (pvVar2 == (id)0x0) {
    bVar1 = false;
  }
  else {
    iVar3 = _CFDictionaryGetCount(pvVar2);
    bVar1 = 0 < iVar3;
    if (0 < iVar3) goto LAB_0029627c;
  }
  pvVar2 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier);
  pvVar2 = _objc_msgSend(pvVar2,sel_arduinoSetupActionAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_analogPinConfigurationDictionary);
  if (pvVar2 != (id)0x0) {
    iVar3 = _CFDictionaryGetCount(pvVar2);
    bVar1 = 0 < iVar3;
  }
LAB_0029627c:
  pvVar2 = _objc_msgSend(cls_HSArduinoDevice,sel_defaultDevice);
  pvVar2 = _objc_msgSend(pvVar2,sel_connectionStatus);
  _objc_msgSend(self->_testButtonCell,sel_setEnabled_,(uint)(pvVar2 == (id)0x6 && bVar1));
  return;
}

*/
- (void)HSArdinoSetupActionAssistantPane_validateTestButton
{
    id<HSArduinoPinConfigurationAttribute> attributes = (id)[[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] arduinoSetupActionAttributes];
    BOOL hasConfiguration = NO;
    CFDictionaryRef dictionary = [attributes digitalPinConfigurationDictionary];
    if (dictionary != NULL) {
        hasConfiguration = CFDictionaryGetCount(dictionary) > 0;
    }
    if (!hasConfiguration) {
        dictionary = [attributes analogPinConfigurationDictionary];
        if (dictionary != NULL) {
            hasConfiguration = CFDictionaryGetCount(dictionary) > 0;
        }
    }
    [_testButtonCell setEnabled:[[HSArduinoDevice defaultDevice] connectionStatus] == 6 && hasConfiguration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00293bf6 @ 00293bf6, 576 bytes * /

void FUN_00293bf6(HSArduinoSetupActionAssistantPane *self,SEL _cmd,
                 uchar HSArdinoSetupActionAssistantPane_validateSelectedPin,BOOL isPinDigital)

{
  id pvVar1;
  int iVar2;
  id pvVar3;
  SEL pcVar4;
  uint uVar5;
  double dVar6;
  undefined8 uVar7;
  ushort *puVar8;
  ushort local_16;
  int local_14;
  
  pvVar3 = self->_noPinValueView;
  local_14 = -1;
  local_16 = 0;
  pvVar1 = _objc_msgSend(self,sel_HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier);
  pvVar1 = _objc_msgSend(pvVar1,sel_arduinoSetupActionAttributes);
  pcVar4 = sel_getMode_value_forAnalogPin_;
  if (isPinDigital != '\0') {
    pcVar4 = sel_getMode_value_forDigitalPin_;
  }
  uVar5 = (uint)HSArdinoSetupActionAssistantPane_validateSelectedPin;
  puVar8 = &local_16;
  _objc_msgSend(pvVar1,pcVar4,&local_14,puVar8,uVar5);
  if (local_14 == 1) {
    pvVar3 = self->_digitalPinValueView;
    pvVar1 = self->_digitalPinValueMatrix;
    pcVar4 = sel_selectCellWithTag_;
  }
  else {
    if (local_14 == 4) {
      iVar2 = 0xb4;
    }
    else {
      if (local_14 != 3) goto LAB_00293dc3;
      iVar2 = 0xff;
    }
    uVar7 = CONCAT44(puVar8,iVar2);
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedShort_,iVar2,puVar8,uVar5);
    if (pvVar3 != (id)0x0) {
      pvVar1 = _objc_msgSend(self->_PWMPinValueTextField,sel_formatter,uVar7,uVar5);
      _objc_msgSend(pvVar1,sel_setMaximum_,pvVar3);
    }
    dVar6 = (double)iVar2;
    _objc_msgSend(self->_PWMPinValueSlider,sel_setMaxValue_,dVar6,uVar5);
    _objc_msgSend(self->_PWMPinValueSpepper,sel_setMaxValue_,dVar6);
    pvVar3 = self->_PWMPinValueView;
    puVar8 = (ushort *)((ulonglong)dVar6 >> 0x20);
    _objc_msgSend(self->_PWMPinValueSlider,sel_setIntValue_,(uint)local_16);
    _objc_msgSend(self->_PWMPinValueTextField,sel_setIntValue_,(uint)local_16);
    pvVar1 = self->_PWMPinValueSpepper;
    pcVar4 = sel_setIntValue_;
  }
  _objc_msgSend(pvVar1,pcVar4,(uint)local_16,puVar8,uVar5);
LAB_00293dc3:
  uVar7 = CONCAT44(puVar8,local_14);
  _objc_msgSend(self->_pinModePopUp,sel_selectItemWithTag_,local_14,puVar8,uVar5);
  if (pvVar3 != self->_pinValueView) {
    pvVar1 = _objc_msgSend(self->_pinValueView,sel_superview,uVar7,uVar5);
    _objc_msgSend(pvVar1,sel_replaceSubview_with_,self->_pinValueView,pvVar3);
    self->_pinValueView = pvVar3;
  }
  return;
}

*/
- (void)HSArdinoSetupActionAssistantPane_validateSelectedPin:(unsigned char)aPin isPinDigital:(BOOL)aDigital
{
    NSView *valueView = _noPinValueView;
    int mode = -1;
    unsigned short value = 0;
    id<HSArduinoPinConfigurationAttribute> attributes = (id)[[self HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier] arduinoSetupActionAttributes];
    if (aDigital) {
        [attributes getMode:&mode value:&value forDigitalPin:aPin];
    } else {
        [attributes getMode:&mode value:&value forAnalogPin:aPin];
    }
    if (mode == 1) {
        valueView = _digitalPinValueView;
        [_digitalPinValueMatrix selectCellWithTag:value];
    } else if (mode == 3 || mode == 4) {
        /* PWM goes up to 255, a servo up to 180 degrees. */
        int maximum = mode == 4 ? 180 : 255;
        NSNumber *maximumNumber = [NSNumber numberWithUnsignedShort:(unsigned short)maximum];
        if (maximumNumber != nil) {
            [(NSNumberFormatter *)[_PWMPinValueTextField formatter] setMaximum:maximumNumber];
        }
        [_PWMPinValueSlider setMaxValue:(double)maximum];
        [_PWMPinValueSpepper setMaxValue:(double)maximum];
        valueView = _PWMPinValueView;
        [_PWMPinValueSlider setIntValue:value];
        [_PWMPinValueTextField setIntValue:value];
        [_PWMPinValueSpepper setIntValue:value];
    }
    [_pinModePopUp selectItemWithTag:mode];
    if (valueView != _pinValueView) {
        [[_pinValueView superview] replaceSubview:_pinValueView with:valueView];
        _pinValueView = valueView;
    }
}

- (id)HSArdinoSetupActionAssistantPane_arduinoSetupActionPaneApplier
{
    return [self applier];
}

- (void)awakeFromNib
{
    id provider = [HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider];
    [_testButtonCell setImage:[provider playbackImageOfType:@"Play" state:@"N" size:@"M" tint:@"A"]];
    id pressed = [provider playbackImageOfType:@"Play" state:@"P" size:@"M" tint:@"A"];
    [_testButtonCell setAquaAlternateImage:pressed];
    /* the original gives the Graphite alternate image the Aqua one too */
    [_testButtonCell setGraphiteAlternateImage:pressed];
    NSRect pinValueFrame = [_pinValueView frame];
    [_digitalPinValueView setFrame:pinValueFrame];
    [_PWMPinValueView setFrame:pinValueFrame];
    [_noPinModeMenu retain];
    [_noPinValueView retain];
}

- (void)dealloc
{
    if (_modeToTitleMap != nil) {
        CFRelease(_modeToTitleMap);
    }
    [_noPinModeMenu release];
    [_noPinValueView release];
    [_indicesToReload release];
    [super dealloc];
}

- (id)init
{
    return [self initWithNibName:@"ArduinoSetupAssistantPane"];
}

@end

/* A missing pin dictionary equals an empty one. */
static BOOL HSArduinoSetupPinDictionariesEqual(CFDictionaryRef initial, CFDictionaryRef current)
{
    if (current == NULL) {
        return initial == NULL || CFDictionaryGetCount(initial) == 0;
    }
    if (initial == NULL) {
        return CFDictionaryGetCount(current) == 0;
    }
    return CFEqual(initial, current);
}

@implementation HSArduinoSetupActionPaneApplier

/* i386 ivar offsets: _initialDigitalPinConfigurationDictionary=0x30, _currentDigitalPinConfigurationDictionary=0x34, _initialAnalogPinConfigurationDictionary=0x38, _currentAnalogPinConfigurationDictionary=0x3c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294d03 @ 00294d03, 258 bytes * /

void FUN_00294d03(HSArduinoSetupActionPaneApplier *self,SEL _cmd)

{
  id self_00;
  CFDictionary *pCVar1;
  
  self_00 = _objc_msgSend(self,sel_arduinoSetupActionAttributes);
  if (self->_initialDigitalPinConfigurationDictionary != (CFDictionary *)0x0) {
    _CFRelease(self->_initialDigitalPinConfigurationDictionary);
  }
  pCVar1 = _objc_msgSend(self_00,sel_digitalPinConfigurationDictionary);
  self->_initialDigitalPinConfigurationDictionary = pCVar1;
  if (pCVar1 != (CFDictionary *)0x0) {
    pCVar1 = (CFDictionary *)_CFDictionaryCreateCopy(*(undefined4 *)PTR_003363a4,pCVar1);
    self->_initialDigitalPinConfigurationDictionary = pCVar1;
  }
  if (self->_initialAnalogPinConfigurationDictionary != (CFDictionary *)0x0) {
    _CFRelease(self->_initialAnalogPinConfigurationDictionary);
  }
  pCVar1 = _objc_msgSend(self_00,sel_analogPinConfigurationDictionary);
  self->_initialAnalogPinConfigurationDictionary = pCVar1;
  if (pCVar1 != (CFDictionary *)0x0) {
    pCVar1 = (CFDictionary *)_CFDictionaryCreateCopy(*(undefined4 *)PTR_003363a4,pCVar1);
    self->_initialAnalogPinConfigurationDictionary = pCVar1;
  }
  _objc_msgSend(self,sel_disableUndo);
  _objc_msgSend(self_00,sel_setDigitalPinConfigurationDictionary_,
                self->_currentDigitalPinConfigurationDictionary);
  _objc_msgSend(self_00,sel_setAnalogPinConfigurationDictionary_,
                self->_currentAnalogPinConfigurationDictionary);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)resetPinConfigurationDictionary
{
    id<HSArduinoPinConfigurationAttribute> attributes = (id)[self arduinoSetupActionAttributes];
    if (_initialDigitalPinConfigurationDictionary != NULL) {
        CFRelease(_initialDigitalPinConfigurationDictionary);
    }
    _initialDigitalPinConfigurationDictionary = [attributes digitalPinConfigurationDictionary];
    if (_initialDigitalPinConfigurationDictionary != NULL) {
        _initialDigitalPinConfigurationDictionary = (CFMutableDictionaryRef)CFDictionaryCreateCopy(kCFAllocatorDefault, _initialDigitalPinConfigurationDictionary);
    }
    if (_initialAnalogPinConfigurationDictionary != NULL) {
        CFRelease(_initialAnalogPinConfigurationDictionary);
    }
    _initialAnalogPinConfigurationDictionary = [attributes analogPinConfigurationDictionary];
    if (_initialAnalogPinConfigurationDictionary != NULL) {
        _initialAnalogPinConfigurationDictionary = (CFMutableDictionaryRef)CFDictionaryCreateCopy(kCFAllocatorDefault, _initialAnalogPinConfigurationDictionary);
    }
    [self disableUndo];
    [attributes setDigitalPinConfigurationDictionary:_currentDigitalPinConfigurationDictionary];
    [attributes setAnalogPinConfigurationDictionary:_currentAnalogPinConfigurationDictionary];
    [self enableUndo];
}

- (void)restorePinConfigurationDictionary
{
    [self disableUndo];
    [[self arduinoSetupActionAttributes] setDigitalPinConfigurationDictionary:_initialDigitalPinConfigurationDictionary];
    [[self arduinoSetupActionAttributes] setAnalogPinConfigurationDictionary:_initialAnalogPinConfigurationDictionary];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294e05 @ 00294e05, 130 bytes * /

void FUN_00294e05(HSArduinoSetupActionPaneApplier *self,SEL _cmd,
                 uchar removeConfigurationForAnalogPin)

{
  id self_00;
  
  if (self->_currentAnalogPinConfigurationDictionary != (CFDictionary *)0x0) {
    _CFDictionaryRemoveValue
              (self->_currentAnalogPinConfigurationDictionary,removeConfigurationForAnalogPin);
  }
  _objc_msgSend(self,sel_disableUndo);
  self_00 = _objc_msgSend(self,sel_arduinoSetupActionAttributes);
  _objc_msgSend(self_00,sel_removeConfigurationForAnalogPin_,(uint)removeConfigurationForAnalogPin);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)removeConfigurationForAnalogPin:(unsigned char)aPin
{
    if (_currentAnalogPinConfigurationDictionary != NULL) {
        CFDictionaryRemoveValue(_currentAnalogPinConfigurationDictionary, (const void *)(uintptr_t)aPin);
    }
    [self disableUndo];
    [(id<HSArduinoPinConfigurationAttribute>)[self arduinoSetupActionAttributes] removeConfigurationForAnalogPin:aPin];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294e87 @ 00294e87, 130 bytes * /

void FUN_00294e87(HSArduinoSetupActionPaneApplier *self,SEL _cmd,
                 uchar removeConfigurationForDigitalPin)

{
  id self_00;
  
  if (self->_currentDigitalPinConfigurationDictionary != (CFDictionary *)0x0) {
    _CFDictionaryRemoveValue
              (self->_currentDigitalPinConfigurationDictionary,removeConfigurationForDigitalPin);
  }
  _objc_msgSend(self,sel_disableUndo);
  self_00 = _objc_msgSend(self,sel_arduinoSetupActionAttributes);
  _objc_msgSend(self_00,sel_removeConfigurationForDigitalPin_,(uint)removeConfigurationForDigitalPin
               );
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)removeConfigurationForDigitalPin:(unsigned char)aPin
{
    if (_currentDigitalPinConfigurationDictionary != NULL) {
        CFDictionaryRemoveValue(_currentDigitalPinConfigurationDictionary, (const void *)(uintptr_t)aPin);
    }
    [self disableUndo];
    [(id<HSArduinoPinConfigurationAttribute>)[self arduinoSetupActionAttributes] removeConfigurationForDigitalPin:aPin];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294f09 @ 00294f09, 221 bytes * /

void FUN_00294f09(HSArduinoSetupActionPaneApplier *self,SEL _cmd,int setMode,ushort value,
                 uchar forAnalogPin)

{
  CFDictionary *pCVar1;
  id self_00;
  
  pCVar1 = self->_currentAnalogPinConfigurationDictionary;
  if (pCVar1 == (CFDictionary *)0x0) {
    pCVar1 = (CFDictionary *)
             _CFDictionaryCreateMutable(*(undefined4 *)PTR_003363a4,0,PTR_00336a0c,PTR_00336a10);
    self->_currentAnalogPinConfigurationDictionary = pCVar1;
    if (pCVar1 == (CFDictionary *)0x0) goto LAB_00294f78;
  }
  _CFDictionarySetValue(pCVar1,forAnalogPin,(uint)value << 8 | setMode);
LAB_00294f78:
  _objc_msgSend(self,sel_disableUndo);
  self_00 = _objc_msgSend(self,sel_arduinoSetupActionAttributes);
  _objc_msgSend(self_00,sel_setMode_value_forAnalogPin_,setMode,(uint)value,(uint)forAnalogPin);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forAnalogPin:(unsigned char)aPin
{
    if (_currentAnalogPinConfigurationDictionary == NULL) {
        _currentAnalogPinConfigurationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
    }
    if (_currentAnalogPinConfigurationDictionary != NULL) {
        /* Packed as value << 8 | mode, like HSArduinoSetupAction stores it. */
        CFDictionarySetValue(_currentAnalogPinConfigurationDictionary, (const void *)(uintptr_t)aPin, (const void *)(uintptr_t)((unsigned int)aValue << 8 | (unsigned int)aMode));
    }
    [self disableUndo];
    [(id<HSArduinoPinConfigurationAttribute>)[self arduinoSetupActionAttributes] setMode:(int)aMode value:aValue forAnalogPin:aPin];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00294fe6 @ 00294fe6, 221 bytes * /

void FUN_00294fe6(HSArduinoSetupActionPaneApplier *self,SEL _cmd,int setMode,ushort value,
                 uchar forDigitalPin)

{
  CFDictionary *pCVar1;
  id self_00;
  
  pCVar1 = self->_currentDigitalPinConfigurationDictionary;
  if (pCVar1 == (CFDictionary *)0x0) {
    pCVar1 = (CFDictionary *)
             _CFDictionaryCreateMutable(*(undefined4 *)PTR_003363a4,0,PTR_00336a0c,PTR_00336a10);
    self->_currentDigitalPinConfigurationDictionary = pCVar1;
    if (pCVar1 == (CFDictionary *)0x0) goto LAB_00295055;
  }
  _CFDictionarySetValue(pCVar1,forDigitalPin,(uint)value << 8 | setMode);
LAB_00295055:
  _objc_msgSend(self,sel_disableUndo);
  self_00 = _objc_msgSend(self,sel_arduinoSetupActionAttributes);
  _objc_msgSend(self_00,sel_setMode_value_forDigitalPin_,setMode,(uint)value,(uint)forDigitalPin);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)setMode:(NSInteger)aMode value:(unsigned short)aValue forDigitalPin:(unsigned char)aPin
{
    if (_currentDigitalPinConfigurationDictionary == NULL) {
        _currentDigitalPinConfigurationDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEUnsignedIntegerDictionaryKeyCallBacks, &kCFEUnsignedIntegerDictionaryValueCallBacks);
    }
    if (_currentDigitalPinConfigurationDictionary != NULL) {
        /* Packed as value << 8 | mode, like HSArduinoSetupAction stores it. */
        CFDictionarySetValue(_currentDigitalPinConfigurationDictionary, (const void *)(uintptr_t)aPin, (const void *)(uintptr_t)((unsigned int)aValue << 8 | (unsigned int)aMode));
    }
    [self disableUndo];
    [(id<HSArduinoPinConfigurationAttribute>)[self arduinoSetupActionAttributes] setMode:(int)aMode value:aValue forDigitalPin:aPin];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002950c3 @ 002950c3, 177 bytes * /

BOOL FUN_002950c3(HSArduinoSetupActionPaneApplier *self,SEL _cmd)

{
  CFDictionary *pCVar1;
  BOOL BVar2;
  id pvVar3;
  int iVar4;
  char cVar5;
  CFDictionary *pCVar6;
  HSArduinoSetupActionPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_003568a0;
  pvVar3 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if ((char)pvVar3 == '\0') {
    return '\0';
  }
  pCVar1 = self->_initialDigitalPinConfigurationDictionary;
  pCVar6 = self->_currentDigitalPinConfigurationDictionary;
  if (pCVar6 == (CFDictionary *)0x0) {
    pCVar6 = pCVar1;
    if (pCVar1 == (CFDictionary *)0x0) goto LAB_00295132;
LAB_0029510d:
    iVar4 = _CFDictionaryGetCount(pCVar6);
    cVar5 = iVar4 == 0;
  }
  else {
    if (pCVar1 == (CFDictionary *)0x0) goto LAB_0029510d;
    cVar5 = _CFEqual(pCVar1,pCVar6);
  }
  if (cVar5 == '\0') {
    return '\0';
  }
LAB_00295132:
  pCVar1 = self->_initialAnalogPinConfigurationDictionary;
  pCVar6 = self->_currentAnalogPinConfigurationDictionary;
  if (pCVar6 == (CFDictionary *)0x0) {
    pCVar6 = pCVar1;
    if (pCVar1 == (CFDictionary *)0x0) {
      return '\x01';
    }
  }
  else if (pCVar1 != (CFDictionary *)0x0) {
    BVar2 = _CFEqual(pCVar1,pCVar6);
    return BVar2;
  }
  iVar4 = _CFDictionaryGetCount(pCVar6);
  return iVar4 == 0;
}

*/
- (BOOL)areSettingsEqual
{
    if (![super areSettingsEqual]) {
        return NO;
    }
    if (!HSArduinoSetupPinDictionariesEqual(_initialDigitalPinConfigurationDictionary, _currentDigitalPinConfigurationDictionary)) {
        return NO;
    }
    return HSArduinoSetupPinDictionariesEqual(_initialAnalogPinConfigurationDictionary, _currentAnalogPinConfigurationDictionary);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00295174 @ 00295174, 171 bytes * /

void FUN_00295174(HSArduinoSetupActionPaneApplier *self,SEL _cmd)

{
  CFDictionary *pCVar1;
  HSArduinoSetupActionPaneApplier *local_14;
  undefined *local_10;
  
  if (self->_currentDigitalPinConfigurationDictionary != (CFDictionary *)0x0) {
    _CFRelease(self->_currentDigitalPinConfigurationDictionary);
  }
  if (self->_initialDigitalPinConfigurationDictionary == (CFDictionary *)0x0) {
    pCVar1 = (CFDictionary *)0x0;
  }
  else {
    pCVar1 = (CFDictionary *)
             _CFDictionaryCreateMutableCopy
                       (*(undefined4 *)PTR_003363a4,0,
                        self->_initialDigitalPinConfigurationDictionary);
  }
  self->_currentDigitalPinConfigurationDictionary = pCVar1;
  if (self->_currentAnalogPinConfigurationDictionary != (CFDictionary *)0x0) {
    _CFRelease(self->_currentAnalogPinConfigurationDictionary);
  }
  if (self->_initialAnalogPinConfigurationDictionary == (CFDictionary *)0x0) {
    pCVar1 = (CFDictionary *)0x0;
  }
  else {
    pCVar1 = (CFDictionary *)
             _CFDictionaryCreateMutableCopy
                       (*(undefined4 *)PTR_003363a4,0,self->_initialAnalogPinConfigurationDictionary
                       );
  }
  self->_currentAnalogPinConfigurationDictionary = pCVar1;
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_003568a0;
  _objc_msgSendSuper(&local_14,sel_makeCurrentEqualToInitial);
  return;
}

*/
- (void)makeCurrentEqualToInitial
{
    if (_currentDigitalPinConfigurationDictionary != NULL) {
        CFRelease(_currentDigitalPinConfigurationDictionary);
    }
    _currentDigitalPinConfigurationDictionary = _initialDigitalPinConfigurationDictionary == NULL ? NULL : CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, _initialDigitalPinConfigurationDictionary);
    if (_currentAnalogPinConfigurationDictionary != NULL) {
        CFRelease(_currentAnalogPinConfigurationDictionary);
    }
    _currentAnalogPinConfigurationDictionary = _initialAnalogPinConfigurationDictionary == NULL ? NULL : CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, _initialAnalogPinConfigurationDictionary);
    [super makeCurrentEqualToInitial];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0029521f @ 0029521f, 155 bytes * /

void FUN_0029521f(HSArduinoSetupActionPaneApplier *self,SEL _cmd)

{
  CFDictionary *pCVar1;
  HSArduinoSetupActionPaneApplier *local_14;
  undefined *local_10;
  
  if (self->_initialDigitalPinConfigurationDictionary != (CFDictionary *)0x0) {
    _CFRelease(self->_initialDigitalPinConfigurationDictionary);
  }
  if (self->_currentDigitalPinConfigurationDictionary == (CFDictionary *)0x0) {
    pCVar1 = (CFDictionary *)0x0;
  }
  else {
    pCVar1 = (CFDictionary *)
             _CFDictionaryCreateCopy
                       (*(undefined4 *)PTR_003363a4,self->_currentDigitalPinConfigurationDictionary)
    ;
  }
  self->_initialDigitalPinConfigurationDictionary = pCVar1;
  if (self->_initialAnalogPinConfigurationDictionary != (CFDictionary *)0x0) {
    _CFRelease(self->_initialAnalogPinConfigurationDictionary);
  }
  if (self->_currentAnalogPinConfigurationDictionary == (CFDictionary *)0x0) {
    pCVar1 = (CFDictionary *)0x0;
  }
  else {
    pCVar1 = (CFDictionary *)
             _CFDictionaryCreateCopy
                       (*(undefined4 *)PTR_003363a4,self->_currentAnalogPinConfigurationDictionary);
  }
  self->_initialAnalogPinConfigurationDictionary = pCVar1;
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_003568a0;
  _objc_msgSendSuper(&local_14,sel_makeInitialEqualToCurrent);
  return;
}

*/
- (void)makeInitialEqualToCurrent
{
    if (_initialDigitalPinConfigurationDictionary != NULL) {
        CFRelease(_initialDigitalPinConfigurationDictionary);
    }
    _initialDigitalPinConfigurationDictionary = _currentDigitalPinConfigurationDictionary == NULL ? NULL : (CFMutableDictionaryRef)CFDictionaryCreateCopy(kCFAllocatorDefault, _currentDigitalPinConfigurationDictionary);
    if (_initialAnalogPinConfigurationDictionary != NULL) {
        CFRelease(_initialAnalogPinConfigurationDictionary);
    }
    _initialAnalogPinConfigurationDictionary = _currentAnalogPinConfigurationDictionary == NULL ? NULL : (CFMutableDictionaryRef)CFDictionaryCreateCopy(kCFAllocatorDefault, _currentAnalogPinConfigurationDictionary);
    [super makeInitialEqualToCurrent];
}

- (void)setInitialSettingsToObject
{
    [[self arduinoSetupActionAttributes] setDigitalPinConfigurationDictionary:_initialDigitalPinConfigurationDictionary];
    [[self arduinoSetupActionAttributes] setAnalogPinConfigurationDictionary:_initialAnalogPinConfigurationDictionary];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [[self arduinoSetupActionAttributes] setDigitalPinConfigurationDictionary:_currentDigitalPinConfigurationDictionary];
    [[self arduinoSetupActionAttributes] setAnalogPinConfigurationDictionary:_currentAnalogPinConfigurationDictionary];
    [super setCurrentSettingsToObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002953d8 @ 002953d8, 204 bytes * /

void FUN_002953d8(HSArduinoSetupActionPaneApplier *self,SEL _cmd)

{
  undefined4 uVar1;
  id pvVar2;
  CFDictionary *pCVar3;
  
  pvVar2 = _objc_msgSend(self,sel_arduinoSetupActionAttributes);
  pCVar3 = _objc_msgSend(pvVar2,sel_digitalPinConfigurationDictionary);
  self->_initialDigitalPinConfigurationDictionary = pCVar3;
  if (pCVar3 != (CFDictionary *)0x0) {
    uVar1 = *(undefined4 *)PTR_003363a4;
    pCVar3 = (CFDictionary *)_CFDictionaryCreateCopy(uVar1,pCVar3);
    self->_initialDigitalPinConfigurationDictionary = pCVar3;
    pCVar3 = (CFDictionary *)_CFDictionaryCreateMutableCopy(uVar1,0,pCVar3);
    self->_currentDigitalPinConfigurationDictionary = pCVar3;
  }
  pvVar2 = _objc_msgSend(self,sel_arduinoSetupActionAttributes);
  pCVar3 = _objc_msgSend(pvVar2,sel_analogPinConfigurationDictionary);
  self->_initialAnalogPinConfigurationDictionary = pCVar3;
  if (pCVar3 != (CFDictionary *)0x0) {
    uVar1 = *(undefined4 *)PTR_003363a4;
    pCVar3 = (CFDictionary *)_CFDictionaryCreateCopy(uVar1,pCVar3);
    self->_initialAnalogPinConfigurationDictionary = pCVar3;
    pCVar3 = (CFDictionary *)_CFDictionaryCreateMutableCopy(uVar1,0,pCVar3);
    self->_currentAnalogPinConfigurationDictionary = pCVar3;
  }
  return;
}

*/
- (void)setUpInitialSettings
{
    _initialDigitalPinConfigurationDictionary = [(id<HSArduinoPinConfigurationAttribute>)[self arduinoSetupActionAttributes] digitalPinConfigurationDictionary];
    if (_initialDigitalPinConfigurationDictionary != NULL) {
        _initialDigitalPinConfigurationDictionary = (CFMutableDictionaryRef)CFDictionaryCreateCopy(kCFAllocatorDefault, _initialDigitalPinConfigurationDictionary);
        _currentDigitalPinConfigurationDictionary = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, _initialDigitalPinConfigurationDictionary);
    }
    _initialAnalogPinConfigurationDictionary = [(id<HSArduinoPinConfigurationAttribute>)[self arduinoSetupActionAttributes] analogPinConfigurationDictionary];
    if (_initialAnalogPinConfigurationDictionary != NULL) {
        _initialAnalogPinConfigurationDictionary = (CFMutableDictionaryRef)CFDictionaryCreateCopy(kCFAllocatorDefault, _initialAnalogPinConfigurationDictionary);
        _currentAnalogPinConfigurationDictionary = CFDictionaryCreateMutableCopy(kCFAllocatorDefault, 0, _initialAnalogPinConfigurationDictionary);
    }
}

- (id)arduinoSetupActionAttributes
{
    return [self actionAttributes];
}

- (void)dealloc
{
    if (_initialDigitalPinConfigurationDictionary != nil) {
        CFRelease(_initialDigitalPinConfigurationDictionary);
    }
    if (_currentDigitalPinConfigurationDictionary != nil) {
        CFRelease(_currentDigitalPinConfigurationDictionary);
    }
    if (_initialAnalogPinConfigurationDictionary != nil) {
        CFRelease(_initialAnalogPinConfigurationDictionary);
    }
    if (_currentAnalogPinConfigurationDictionary != nil) {
        CFRelease(_currentAnalogPinConfigurationDictionary);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end

