#import "HSButtonObjectAssistantPane.h"

@implementation HSButtonObjectAssistantPane

/* i386 ivar offsets: _buttonTypeMatrix=0x5c, _tintedView=0x60, _updateStyleButton=0x64, _showTitleSwitch=0x68, _showIconSwitch=0x6c, _highlightSwitch=0x70, _showIconButton=0x74, _titleColorWell=0x78, _backgroundColorWell=0x7c, _titleDidChange=0x80, _titleTextField=0x84, _paneState=0x88, _needToRelayoutAssistance=0x8c */

+ (BOOL)canEditObject:(id)aObject
{
    return (BOOL)[aObject implementsHyperInterface:@protocol(HSButtonObjectAttributes)];
}

- (void)applyShapeBackgroundStyleWithButtonType
{
    NSRect local_24;
    BOOL pvVar1_5;
    NSBezierPath *pvVar1_6;

    local_24 = [[[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect];
    pvVar1_5 = [[_paneState buttonType] isEqualToString:@"HSInvisibleShapeButtonType"];
    [[self buttonObjectInterface] setBackgroundStyle:[_paneState backgroundStyle] needsResetRotationAngle:(unsigned int)(!pvVar1_5)];
    [[self shapeBackgroundInterface] setShapeButtonType:[_paneState buttonType]];
    [[self systemBackgroundInterface] setSystemButtonType:nil];
    if (pvVar1_5) {
        pvVar1_6 = [NSBezierPath bezierPathWithRect:local_24];
        [[self shapeBackgroundInterface] setBorderPath:pvVar1_6];
        [[self buttonObjectInterface] setContentOverlapsBackground:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00176e20 @ 00176e20, 636 bytes * /

void FUN_00176e20(HSButtonObjectAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00376d84);
  pcVar2 = _objc_msgSend(pvVar1,sel_size);
  pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar1 = _objc_msgSend(pvVar1,sel_backgroundStyle);
  pvVar3 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar4 = _objc_msgSend(self->_paneState,sel_backgroundStyle);
  _objc_msgSend(pvVar3,sel_setBackgroundStyle_,pvVar4);
  pvVar3 = _objc_msgSend(self,sel_systemBackgroundInterface);
  pvVar4 = _objc_msgSend(self->_paneState,sel_buttonType);
  _objc_msgSend(pvVar3,sel_setSystemButtonType_,pvVar4);
  pvVar3 = _objc_msgSend(self,sel_shapeBackgroundInterface);
  _objc_msgSend(pvVar3,sel_setShapeButtonType_,0);
  pvVar3 = _objc_msgSend(self,sel_shapeBackgroundInterface);
  _objc_msgSend(pvVar3,sel_setBorderPath_,0);
  pcVar5 = &cfstr_HSButtonObjectShapeBackgroundStyle;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_HSButtonObjectShapeBackgroundStyle);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self->_paneState,sel_backgroundStyle,pcVar5);
    pcVar5 = &cfstr_HSButtonObjectSystemBackgroundStyle;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_HSButtonObjectSystemBackgroundStyle);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_assistant,pcVar5);
      pvVar1 = _objc_msgSend(pvVar1,sel_object);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00376f78);
      _objc_msgSend(pvVar1,sel_setSize_,pcVar2,extraout_EDX);
      pcVar5 = pcVar2;
    }
  }
  pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface,pcVar5);
  _objc_msgSend(pvVar1,sel_setContentOverlapsBackground_,0);
  return;
}

*/
- (void)applySystemBackgroundStyleWithButtonType
{
    NSSize size = [[[[self assistant] object] queryHyperInterface:@protocol(HSGeometryAttributes)] size];
    NSString *previousStyle = [[self buttonObjectInterface] backgroundStyle];
    [[self buttonObjectInterface] setBackgroundStyle:[_paneState backgroundStyle]];
    [[self systemBackgroundInterface] setSystemButtonType:[_paneState buttonType]];
    [[self shapeBackgroundInterface] setShapeButtonType:nil];
    [[self shapeBackgroundInterface] setBorderPath:nil];
    if ([previousStyle isEqualToString:@"HSButtonObjectShapeBackgroundStyle"] && [[_paneState backgroundStyle] isEqualToString:@"HSButtonObjectSystemBackgroundStyle"]) {
        [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableGeometryAttributes)] setSize:size];
    }
    [[self buttonObjectInterface] setContentOverlapsBackground:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017709c @ 0017709c, 302 bytes * /

void FUN_0017709c(HSButtonObjectAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  id pvVar2;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(self->_paneState,sel_backgroundStyle);
  pcVar3 = &cfstr_HSButtonObjectSystemBackgroundStyle;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSButtonObjectSystemBackgroundStyle);
  op = sel_applySystemBackgroundStyleWithButtonType;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self->_paneState,sel_backgroundStyle,pcVar3);
    pcVar3 = &cfstr_HSButtonObjectShapeBackgroundStyle;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSButtonObjectShapeBackgroundStyle);
    op = sel_applyShapeBackgroundStyleWithButtonType;
    if ((char)pvVar1 == '\0') goto LAB_00177138;
  }
  _objc_msgSend(self,op,pcVar3);
LAB_00177138:
  pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface,pcVar3);
  pvVar2 = _objc_msgSend(self->_paneState,sel_titleVisible);
  _objc_msgSend(pvVar1,sel_setTitleVisible_,(int)(char)pvVar2);
  pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar2 = _objc_msgSend(self->_paneState,sel_highlight);
  _objc_msgSend(pvVar1,sel_setHasHighlight_,(int)(char)pvVar2);
  return;
}

*/
- (void)applyPaneStateToButtonObject
{
    if ([[_paneState backgroundStyle] isEqual:@"HSButtonObjectSystemBackgroundStyle"]) {
        [self applySystemBackgroundStyleWithButtonType];
    } else if ([[_paneState backgroundStyle] isEqual:@"HSButtonObjectShapeBackgroundStyle"]) {
        [self applyShapeBackgroundStyleWithButtonType];
    }
    [[self buttonObjectInterface] setTitleVisible:[_paneState titleVisible]];
    [[self buttonObjectInterface] setHasHighlight:[_paneState highlight]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001771ca @ 001771ca, 68 bytes * /

void FUN_001771ca(HSButtonObjectAssistantPane *self,SEL _cmd,int selectToolWithTag)

{
  id self_00;
  
  self_00 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  _objc_msgSend(self_00,sel_selectToolWithTag_,selectToolWithTag);
  return;
}

*/
- (void)selectToolWithTag:(NSInteger)aTag
{
    [[HSToolManager sharedToolManager] selectToolWithTag:aTag];
}

- (void)finishButtonTypeEditingWithSelectingToolWithTag:(NSInteger)aTag
{
    [self selectToolWithTag:aTag];
    [[self buttonObjectInterface] setHiddenInEditor:NO];
}

- (void)runDrawShapeBackground
{
    NSUInteger pvVar1_2;
    id pvVar2_2;

    pvVar1_2 = [self toolTagForShapeButtonType:[_paneState buttonType]];
    pvVar2_2 = [HSDrawButtonShapeAssistantPane paneWithCoachingKey:[HSToolManager toolIdentifierForTag:pvVar1_2]];
    [pvVar2_2 setPaneState:_paneState];
    [pvVar2_2 setToolTag:pvVar1_2];
    [self presentModalViewControllerAsRootViewController:pvVar2_2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00177340 @ 00177340, 530 bytes * /

void FUN_00177340(HSButtonObjectAssistantPane *self,SEL _cmd,id setBackgrounStyle,id withButtonType)

{
  HSButtonObjectAssistantPaneState *pHVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  
  _objc_msgSend(self->_paneState,sel_setBackgrounStyle_withButtonType_,setBackgrounStyle,
                withButtonType);
  pHVar1 = self->_paneState;
  pvVar2 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar2 = _objc_msgSend(pvVar2,sel_isTitleVisibleForButtonType_,withButtonType);
  _objc_msgSend(pHVar1,sel_setTitleVisible_,(int)(char)pvVar2);
  pHVar1 = self->_paneState;
  pvVar2 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar2 = _objc_msgSend(pvVar2,sel_hasHighlightForButtonType_,withButtonType);
  _objc_msgSend(pHVar1,sel_setHighlight_,(int)(char)pvVar2);
  pcVar4 = &cfstr_HSButtonObjectShapeBackgroundStyle;
  pvVar2 = _objc_msgSend(setBackgrounStyle,sel_isEqual_,&cfstr_HSButtonObjectShapeBackgroundStyle);
  if ((char)pvVar2 != '\0') {
    pcVar4 = &cfstr_HSInvisibleShapeButtonType;
    pvVar2 = _objc_msgSend(withButtonType,sel_isEqual_,&cfstr_HSInvisibleShapeButtonType);
    if ((char)pvVar2 == '\0') {
      pvVar2 = self->_showTitleSwitch;
      pvVar3 = _objc_msgSend(self->_paneState,sel_titleVisible,pcVar4);
      _objc_msgSend(pvVar2,sel_setState_,(int)(char)pvVar3);
      pvVar2 = self->_highlightSwitch;
      pvVar3 = _objc_msgSend(self->_paneState,sel_highlight);
      _objc_msgSend(pvVar2,sel_setState_,(int)(char)pvVar3);
      pvVar3 = self->_buttonTypeMatrix;
      pvVar2 = _objc_msgSend(self->_paneState,sel_buttonType);
      pvVar2 = _objc_msgSend(self,sel_tagForButtonType_,pvVar2);
      _objc_msgSend(pvVar3,sel_selectCellWithTag_,pvVar2);
      op = sel_runDrawShapeBackground;
      goto LAB_00177545;
    }
  }
  _objc_msgSend(self,sel_applyPaneStateToButtonObject,pcVar4);
  pvVar2 = (id)0x1;
  op = sel_finishButtonTypeEditingWithSelectingToolWithTag_;
LAB_00177545:
  _objc_msgSend(self,op,pvVar2);
  return;
}

*/
- (void)setBackgrounStyle:(id)aStyle withButtonType:(id)aType
{
    [_paneState setBackgrounStyle:aStyle withButtonType:aType];
    [_paneState setTitleVisible:[[self buttonObjectInterface] isTitleVisibleForButtonType:aType]];
    [_paneState setHighlight:[[self buttonObjectInterface] hasHighlightForButtonType:aType]];
    if ([aStyle isEqual:@"HSButtonObjectShapeBackgroundStyle"] && ![aType isEqual:@"HSInvisibleShapeButtonType"]) {
        [_showTitleSwitch setState:[_paneState titleVisible]];
        [_highlightSwitch setState:[_paneState highlight]];
        [_buttonTypeMatrix selectCellWithTag:[self tagForButtonType:[_paneState buttonType]]];
        [self runDrawShapeBackground];
        return;
    }
    [self applyPaneStateToButtonObject];
    [self finishButtonTypeEditingWithSelectingToolWithTag:1];
}

- (NSUInteger)toolTagForShapeButtonType:(id)aType
{
    unsigned int uVar2;
    BOOL pvVar1_3;

    if (![aType isEqualToString:@"HSFreehandAreaShapeButtonType"]) {
        if (![aType isEqualToString:@"HSLassoAreaShapeButtonType"]) {
            pvVar1_3 = [aType isEqualToString:@"HSExpandingAreaShapeButtonType"];
            uVar2 = 0x3d;
            if (!pvVar1_3) {
                uVar2 = 0;
            }
        }
        else {
            uVar2 = 0x3c;
        }
    }
    else {
        uVar2 = 0x3b;
    }
    return uVar2;
}

- (NSInteger)tagForButtonType:(id)aType
{
    int iVar2;

    if (![aType isEqualToString:@"HSRegularSystemButtonType"]) {
        if (![aType isEqualToString:@"HSDefaultSystemButtonType"]) {
            if (![aType isEqualToString:@"HSRectangleSystemButtonType"]) {
                if (![aType isEqualToString:@"HSDropShadowRectangleSystemButtonType"]) {
                    if (![aType isEqualToString:@"HSInvisibleShapeButtonType"]) {
                        if (![aType isEqualToString:@"HSFreehandAreaShapeButtonType"]) {
                            if (![aType isEqualToString:@"HSExpandingAreaShapeButtonType"]) {
                                iVar2 = (unsigned int)([aType isEqualToString:@"HSLassoAreaShapeButtonType"]) << 3;
                            }
                            else {
                                iVar2 = 7;
                            }
                        }
                        else {
                            iVar2 = 6;
                        }
                    }
                    else {
                        iVar2 = 5;
                    }
                }
                else {
                    iVar2 = 4;
                }
            }
            else {
                iVar2 = 3;
            }
        }
        else {
            iVar2 = 2;
        }
    }
    else {
        iVar2 = 1;
    }
    return iVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017773c @ 0017773c, 230 bytes * /

id FUN_0017773c(HSButtonObjectAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  cfstringStruct *pcVar2;
  
  pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar1 = _objc_msgSend(pvVar1,sel_backgroundStyle);
  pcVar2 = &cfstr_HSButtonObjectSystemBackgroundStyle;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSButtonObjectSystemBackgroundStyle);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface,pcVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_backgroundStyle);
    pcVar2 = &cfstr_HSButtonObjectShapeBackgroundStyle;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSButtonObjectShapeBackgroundStyle);
    if ((char)pvVar1 == '\0') {
      return (id)0x0;
    }
    pvVar1 = _objc_msgSend(self,sel_shapeBackgroundInterface,pcVar2);
    op = sel_shapeButtonType;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_systemBackgroundInterface,pcVar2);
    op = sel_systemButtonType;
  }
  pvVar1 = _objc_msgSend(pvVar1,op,pcVar2);
  return pvVar1;
}

*/
- (id)currentButtonType
{
    if ([[[self buttonObjectInterface] backgroundStyle] isEqual:@"HSButtonObjectSystemBackgroundStyle"]) {
        return [[self systemBackgroundInterface] systemButtonType];
    }
    if ([[[self buttonObjectInterface] backgroundStyle] isEqual:@"HSButtonObjectShapeBackgroundStyle"]) {
        return [[self shapeBackgroundInterface] shapeButtonType];
    }
    return nil;
}

- (id)shapeBackgroundInterface
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
}

- (id)systemBackgroundInterface
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
}

- (id)buttonObjectInterface
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
}

- (void)runImagesDialog
{
    id pvVar1_2;

    pvVar1_2 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:[[HSButtonImageAssistantPane new] autorelease]];
    [self presentModalViewController:pvVar1_2 animated:YES];
    [pvVar1_2 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001779c8 @ 001779c8, 1313 bytes * /

void FUN_001779c8(HSButtonObjectAssistantPane *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  SEL pcVar5;
  uint uVar6;
  bool bVar7;
  id pvVar8;
  
  pvVar2 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar2 = _objc_msgSend(pvVar2,sel_backgroundStyle);
  pcVar3 = &cfstr_HSButtonObjectSystemBackgroundStyle;
  pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_HSButtonObjectSystemBackgroundStyle);
  if ((char)pvVar2 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_buttonObjectInterface,pcVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_backgroundStyle);
    pcVar3 = &cfstr_HSButtonObjectShapeBackgroundStyle;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqualToString_,&cfstr_HSButtonObjectShapeBackgroundStyle);
    if ((char)pvVar2 == '\0') {
      pcVar3 = (cfstringStruct *)0x0;
      goto LAB_00177aa4;
    }
    pvVar2 = _objc_msgSend(self,sel_shapeBackgroundInterface,pcVar3);
    pcVar5 = sel_shapeButtonType;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_systemBackgroundInterface,pcVar3);
    pcVar5 = sel_systemButtonType;
  }
  pcVar3 = _objc_msgSend(pvVar2,pcVar5,pcVar3);
LAB_00177aa4:
  pvVar2 = _objc_msgSend(pcVar3,sel_isEqualToString_,&cfstr_HSTexturedBackgroundSystemButtonType);
  cVar1 = (char)pvVar2;
  pvVar2 = _objc_msgSend(self,sel_systemBackgroundInterface);
  pvVar2 = _objc_msgSend(pvVar2,sel_canButtonStyleBeUpdated);
  if ((char)pvVar2 == '\0') {
    _objc_msgSend(self->_buttonTypeMatrix,sel_setHidden_,0);
    _objc_msgSend(self->_tintedView,sel_setHidden_,1);
    if (cVar1 == '\0') {
      _objc_msgSend(self->_buttonTypeMatrix,sel_setEnabled_,1);
      pvVar2 = self->_buttonTypeMatrix;
    }
    else {
      _objc_msgSend(self->_buttonTypeMatrix,sel_setEnabled_,0);
      pvVar2 = self->_buttonTypeMatrix;
      pcVar3 = &cfstr_HSInvisibleShapeButtonType;
    }
    pvVar8 = _objc_msgSend(self,sel_tagForButtonType_,pcVar3);
    pcVar5 = sel_selectCellWithTag_;
  }
  else {
    _objc_msgSend(self->_buttonTypeMatrix,sel_setHidden_,1);
    pvVar2 = self->_tintedView;
    pvVar8 = (id)0x0;
    pcVar5 = sel_setHidden_;
  }
  _objc_msgSend(pvVar2,pcVar5,pvVar8);
  pvVar2 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar2 = _objc_msgSend(pvVar2,sel_titleColor);
  _objc_msgSend(self->_titleColorWell,sel_setColor_,pvVar2);
  pvVar8 = _objc_msgSend(self,sel_systemBackgroundInterface);
  if (pvVar8 != (id)0x0) {
    pvVar8 = _objc_msgSend(self,sel_systemBackgroundInterface,pvVar2);
    pvVar4 = _objc_msgSend(pvVar8,sel_tintColor);
    pvVar8 = self->_backgroundColorWell;
    if (cVar1 == '\0') {
      _objc_msgSend(pvVar8,sel_setColor_,pvVar4);
      pvVar8 = self->_backgroundColorWell;
    }
    else {
      pvVar2 = _objc_msgSend(cls_NSColor,sel_clearColor,pvVar2);
      _objc_msgSend(pvVar8,sel_setColor_,pvVar2);
      pvVar8 = self->_backgroundColorWell;
    }
    pvVar2 = (id)(uint)(cVar1 == '\0');
    _objc_msgSend(pvVar8,sel_setEnabled_,pvVar2);
  }
  pvVar8 = self->_showTitleSwitch;
  pvVar2 = _objc_msgSend(self,sel_buttonObjectInterface,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_isTitleVisible);
  _objc_msgSend(pvVar8,sel_setState_,(int)(char)pvVar2);
  pvVar2 = self->_highlightSwitch;
  pvVar8 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar8 = _objc_msgSend(pvVar8,sel_hasHighlight);
  _objc_msgSend(pvVar2,sel_setState_,(int)(char)pvVar8);
  pvVar2 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar2 = _objc_msgSend(pvVar2,sel_isIconVisible);
  bVar7 = (char)pvVar2 == '\0';
  _objc_msgSend(self->_showIconSwitch,sel_setState_,(uint)!bVar7);
  uVar6 = (uint)bVar7;
  _objc_msgSend(self->_showIconButton,sel_setHidden_,uVar6);
  pvVar2 = _objc_msgSend(self->_showIconButton,sel_isHidden);
  if ((char)pvVar2 == '\0') {
    pcVar3 = &cfstr_empty;
  }
  else {
    pcVar3 = _objc_msgSend(self->_showIconButton,sel_title,uVar6);
  }
  _objc_msgSend(self->_showIconSwitch,sel_setTitle_,pcVar3);
  if (cVar1 == '\0') {
    _objc_msgSend(self->_showIconSwitch,sel_setEnabled_,1);
    pvVar2 = self->_showIconButton;
  }
  else {
    _objc_msgSend(self->_showIconSwitch,sel_setState_,0xffffffff);
    _objc_msgSend(self->_showIconSwitch,sel_setEnabled_,0);
    pvVar2 = self->_showIconButton;
  }
  _objc_msgSend(pvVar2,sel_setEnabled_,(uint)(cVar1 == '\0'));
  pvVar2 = self->_titleTextField;
  pvVar8 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar8 = _objc_msgSend(pvVar8,sel_title);
  _objc_msgSend(pvVar2,sel_setStringValue_,pvVar8);
  self->_titleDidChange = '\0';
  return;
}

*/
- (void)validateUIElements
{
    NSString *buttonType;
    if ([[[self buttonObjectInterface] backgroundStyle] isEqualToString:@"HSButtonObjectSystemBackgroundStyle"]) {
        buttonType = [[self systemBackgroundInterface] systemButtonType];
    } else {
        buttonType = [[self shapeBackgroundInterface] shapeButtonType];
    }
    BOOL isTextured = [buttonType isEqualToString:@"HSTexturedBackgroundSystemButtonType"];
    if (![[self systemBackgroundInterface] canButtonStyleBeUpdated]) {
        [_buttonTypeMatrix setHidden:NO];
        [_tintedView setHidden:YES];
        if (!isTextured) {
            [_buttonTypeMatrix setEnabled:YES];
        } else {
            [_buttonTypeMatrix setEnabled:NO];
            buttonType = @"HSInvisibleShapeButtonType";
        }
        [_buttonTypeMatrix selectCellWithTag:[self tagForButtonType:buttonType]];
    } else {
        [_buttonTypeMatrix setHidden:YES];
        [_tintedView setHidden:NO];
    }
    [_titleColorWell setColor:[[self buttonObjectInterface] titleColor]];
    if ([self systemBackgroundInterface] != nil) {
        if (!isTextured) {
            [_backgroundColorWell setColor:[[self systemBackgroundInterface] tintColor]];
        } else {
            [_backgroundColorWell setColor:[NSColor clearColor]];
        }
        [_backgroundColorWell setEnabled:!isTextured];
    }
    [_showTitleSwitch setState:[[self buttonObjectInterface] isTitleVisible]];
    [_highlightSwitch setState:[[self buttonObjectInterface] hasHighlight]];
    BOOL iconVisible = [[self buttonObjectInterface] isIconVisible];
    [_showIconSwitch setState:iconVisible];
    [_showIconButton setHidden:!iconVisible];
    [_showIconSwitch setTitle:[_showIconButton isHidden] ? [_showIconButton title] : @""];
    if (!isTextured) {
        [_showIconSwitch setEnabled:YES];
    } else {
        [_showIconSwitch setState:-1];
        [_showIconSwitch setEnabled:NO];
    }
    [_showIconButton setEnabled:!isTextured];
    [_titleTextField setStringValue:[[self buttonObjectInterface] title]];
    _titleDidChange = NO;
}

- (void)validateUIElementsWithNotification:(id)aNotification
{
    [self commitTitleChangesToModel];
    [self validateUIElements];
}

- (void)updateButtonObjectStyle:(id)aStyle
{
    [self commitTitleChangesToModel];
    [[self systemBackgroundInterface] updateButtonObjectStyle];
    [self validateUIElements];
}

- (void)controlTextDidChange:(id)aChange
{
    if ([aChange object] == _titleTextField) {
        _titleDidChange = YES;
        [self commitTitleChangesToModel];
    }
}

- (void)titleTextFieldChanged:(id)aChanged
{
    [self commitTitleChangesToModel];
}

- (void)commitTitleChangesToModel
{
    if (_titleDidChange != NO) {
        _titleDidChange = NO;
        _needToRelayoutAssistance = NO;
        [[self buttonObjectInterface] setTitle:[_titleTextField stringValue]];
        _needToRelayoutAssistance = YES;
    }
}

- (void)backgroundColorChanged:(id)aChanged
{
    [[self systemBackgroundInterface] setTintColor:[aChanged color]];
}

- (void)titleColorChanged:(id)aChanged
{
    [[self buttonObjectInterface] setTitleColor:[aChanged color]];
}

- (void)highlightStateChanged:(id)aChanged
{
    [[self buttonObjectInterface] setHasHighlight:(unsigned int)([aChanged state] == 0x1)];
}

- (void)showIconStateChanged:(id)aChanged
{
    NSInteger pvVar1;
    BOOL uVar2;
    id pvVar1_2;

    pvVar1 = [aChanged state];
    if (pvVar1 == 0) {
        pvVar1_2 = [self buttonObjectInterface];
        uVar2 = 0;
    }
    else {
        if (pvVar1 != 0x1) {
            return;
        }
        pvVar1_2 = [self buttonObjectInterface];
        uVar2 = 1;
    }
    [pvVar1_2 setIconVisible:uVar2];
}

- (void)showTitleStateChanged:(id)aChanged
{
    [[self buttonObjectInterface] setTitleVisible:(unsigned int)([aChanged state] == 0x1)];
}

- (void)iconsButtonClicked:(id)aClicked
{
    [self runImagesDialog];
    if ([_showIconSwitch state] == 0) {
        if ([[self buttonObjectInterface] icon] != nil) {
            [[self buttonObjectInterface] setIconVisible:YES];
            [_showIconSwitch setState:1];
        }
    }
}

- (void)lassoAreaShapeButtonTypeChosen:(id)aChosen
{
    [self setBackgrounStyle:@"HSButtonObjectShapeBackgroundStyle" withButtonType:@"HSLassoAreaShapeButtonType"];
}

- (void)expandingAreaShapeButtonTypeChosen:(id)aChosen
{
    [self setBackgrounStyle:@"HSButtonObjectShapeBackgroundStyle" withButtonType:@"HSExpandingAreaShapeButtonType"];
}

- (void)freehandAreaButtonTypeChosen:(id)aChosen
{
    [self setBackgrounStyle:@"HSButtonObjectShapeBackgroundStyle" withButtonType:@"HSFreehandAreaShapeButtonType"];
}

- (void)invisibleShapeButtonTypeChosen:(id)aChosen
{
    [self setBackgrounStyle:@"HSButtonObjectShapeBackgroundStyle" withButtonType:@"HSInvisibleShapeButtonType"];
}

- (void)dropShadowRectangleSystemButtonTypeChosen:(id)aChosen
{
    [self setBackgrounStyle:@"HSButtonObjectSystemBackgroundStyle" withButtonType:@"HSDropShadowRectangleSystemButtonType"];
}

- (void)rectangleSystemButtonTypeChosen:(id)aChosen
{
    [self setBackgrounStyle:@"HSButtonObjectSystemBackgroundStyle" withButtonType:@"HSRectangleSystemButtonType"];
}

- (void)defaultSystemButtonTypeChosen:(id)aChosen
{
    [self setBackgrounStyle:@"HSButtonObjectSystemBackgroundStyle" withButtonType:@"HSDefaultSystemButtonType"];
}

- (void)regularSystemButtonTypeChosen:(id)aChosen
{
    [self setBackgrounStyle:@"HSButtonObjectSystemBackgroundStyle" withButtonType:@"HSRegularSystemButtonType"];
}

- (id)nameTextfField
{
    return _titleTextField;
}

- (id)initialKeyView
{
    return _titleTextField;
}

- (BOOL)needToRelayoutAssistant
{
    return _needToRelayoutAssistance;
}

- (BOOL)assistantShouldBeKeyWindow
{
    return [[self window] firstResponder] == [_titleTextField currentEditor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017854e @ 0017854e, 403 bytes * /

void FUN_0017854e(HSButtonObjectAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  id pvVar1;
  id pvVar2;
  HSButtonObjectAssistantPane *pHVar3;
  HSButtonObjectAssistantPane *local_2c;
  undefined *local_28;
  undefined *local_24;
  undefined4 local_20;
  HSButtonObjectAssistantPane *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_window);
  pvVar1 = _objc_msgSend(pvVar1,sel_firstResponder);
  pvVar2 = _objc_msgSend(self->_titleTextField,sel_currentEditor);
  if (pvVar1 == pvVar2) {
    pvVar1 = _objc_msgSend(self,sel_window);
    pvVar2 = _objc_msgSend(self,sel_window);
    _objc_msgSend(pvVar1,sel_makeFirstResponder_,pvVar2);
  }
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_003524f0;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pHVar3 = (HSButtonObjectAssistantPane *)&DAT_00376834;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00376834);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  if (pvVar1 != (id)0x0) {
    local_28 = &DAT_00376bcc;
    local_24 = &DAT_00376c44;
    local_20 = 0;
    pHVar3 = self;
    local_2c = (HSButtonObjectAssistantPane *)&DAT_00376834;
    _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterfaces_,self,
                  sel_validateUIElementsWithNotification_,*(undefined4 *)PTR_0033601c,&local_2c);
  }
  _objc_msgSend(self->_paneState,sel_release,pHVar3);
  self->_paneState = (HSButtonObjectAssistantPaneState *)0x0;
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    if ([[self window] firstResponder] == [_titleTextField currentEditor]) {
        [[self window] makeFirstResponder:[self window]];
    }
    [super viewWillDisappear:aDisappear];
    id controller = [[[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectAttributes)] attributeObservingController];
    if (controller != nil) {
        id interfaces[4] = { @protocol(HSButtonObjectAttributes), @protocol(HSButtonObjectSystemStyleBackgroundAttributes), @protocol(HSButtonObjectShapeBackgroundAttributes), nil };
        [controller removeObserver:self selector:@selector(validateUIElementsWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterfaces:interfaces];
    }
    [_paneState release];
    _paneState = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001786e1 @ 001786e1, 374 bytes * /

void FUN_001786e1(HSButtonObjectAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  undefined4 uVar1;
  id pvVar2;
  HSButtonObjectAssistantPaneState *pHVar3;
  HSButtonObjectAssistantPane *pHVar4;
  HSButtonObjectAssistantPane *local_2c;
  undefined *local_28;
  undefined *local_24;
  undefined4 local_20;
  HSButtonObjectAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_003524f0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self,sel_validateUIElements);
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pHVar4 = (HSButtonObjectAssistantPane *)&DAT_00376834;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00376834);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  if (pvVar2 != (id)0x0) {
    local_28 = &DAT_00376bcc;
    local_24 = &DAT_00376c44;
    local_20 = 0;
    uVar1 = *(undefined4 *)PTR_0033601c;
    local_2c = (HSButtonObjectAssistantPane *)&DAT_00376834;
    _objc_msgSend(pvVar2,
                  sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterfaces_withPriority_,
                  self,sel_validateUIElementsWithNotification_,uVar1,&local_2c,0xbe800000);
    pHVar4 = self;
    _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                  sel_validateUIElementsWithNotification_,uVar1,&DAT_00376bb8);
  }
  pvVar2 = _objc_msgSend(cls_HSButtonObjectAssistantPaneState,sel_alloc,pHVar4);
  pHVar3 = _objc_msgSend(pvVar2,sel_init);
  self->_paneState = pHVar3;
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self validateUIElements];
    id controller = [[[[self assistant] object] queryHyperInterface:@protocol(HSButtonObjectAttributes)] attributeObservingController];
    if (controller != nil) {
        id interfaces[4] = { @protocol(HSButtonObjectAttributes), @protocol(HSButtonObjectSystemStyleBackgroundAttributes), @protocol(HSButtonObjectShapeBackgroundAttributes), nil };
        [controller addObserver:self selector:@selector(validateUIElementsWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterfaces:interfaces withPriority:-0.25];
        [controller removeObserver:self selector:@selector(validateUIElementsWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSButtonObjectHiddenInEditorAttribute)];
    }
    _paneState = [[HSButtonObjectAssistantPaneState alloc] init];
}

- (void)viewDidLoad
{
    [_backgroundColorWell setPatternSupportEnabled:NO];
    [_backgroundColorWell setGradientSupportEnabled:NO];
    [_titleColorWell setGradientSupportEnabled:NO];
    [_titleColorWell setPatternSupportEnabled:YES];
    [[_titleTextField cell] setAllowsUndo:NO];
}

- (id)init
{
    self = [super initWithNibName:@"EditButtonAssistantPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
        _needToRelayoutAssistance = 1;
    }
    return self;
}

@end

