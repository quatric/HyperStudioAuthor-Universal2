#import "HSWebcamAppearanceAssistantPane.h"

@implementation HSWebcamAppearanceAssistantPane

/* i386 ivar offsets: _nameTextField=0x5c, _locationTextField=0x60, _refreshRateTextField=0x64, _sizeTextField=0x68, _localTimeTextField=0x6c, _copyrightTextField=0x70, _shadowSwitch=0x74, _shadowButton=0x78, _reloadButton=0x7c, _reloadImage=0x80, _pressedReloadImage=0x84, _oneMinuteTimer=0x88 */

- (void)invalidateLocalTime:(id)aTime
{
    [_localTimeTextField setStringValue:[self currentTimeStringForTimeZone:[[self webPageObjectAttributes] webPageTimeZone]]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017132b @ 0017132b, 420 bytes * /

id FUN_0017132b(HSWebcamAppearanceAssistantPane *self,SEL _cmd,id currentTimeStringForTimeZone)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  int iVar4;
  int iVar5;
  
  if ((currentTimeStringForTimeZone == (id)0x0) ||
     (pvVar1 = _objc_msgSend(cls_NSTimeZone,sel_timeZoneWithName_,currentTimeStringForTimeZone),
     pvVar1 == (id)0x0)) {
    pcVar3 = &cfstr___;
  }
  else {
    pvVar2 = _objc_msgSend(cls_NSCalendarDate,sel_calendarDate,currentTimeStringForTimeZone);
    _objc_msgSend(pvVar2,sel_setTimeZone_,pvVar1);
    pvVar2 = _objc_msgSend(pvVar2,sel_descriptionWithCalendarFormat_,&cfstr__I__M__p);
    pvVar1 = _objc_msgSend(pvVar1,sel_secondsFromGMT);
    iVar5 = (int)pvVar1 % 0xe10;
    if ((int)pvVar1 < 0) {
      iVar5 = (int)((ulonglong)((longlong)iVar5 * 0x77777777) >> 0x20) - iVar5;
      iVar5 = (iVar5 >> 5) - (iVar5 >> 0x1f);
      iVar4 = (int)((ulonglong)((longlong)(int)pvVar1 * 0x6e5d4c3b) >> 0x20) - (int)pvVar1;
    }
    else {
      iVar5 = iVar5 / 0x3c;
      iVar4 = (int)((ulonglong)((longlong)(int)pvVar1 * 0x91a2b3c5) >> 0x20);
    }
    pcVar3 = &cfstr__;
    if (-1 < (int)pvVar1) {
      pcVar3 = &cfstr__;
    }
    pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_GMT____02d__02d,pcVar3,
                           (iVar4 >> 0xb) - (iVar4 >> 0x1f),iVar5,0);
    pcVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr________,pvVar2,pvVar1);
  }
  return pcVar3;
}

*/
- (id)currentTimeStringForTimeZone:(id)aZone
{
    NSTimeZone *timeZone = (aZone != nil) ? [NSTimeZone timeZoneWithName:aZone] : nil;
    if (timeZone == nil) {
        return @"--";
    }
    NSCalendarDate *date = [NSCalendarDate calendarDate];
    [date setTimeZone:timeZone];
    NSString *time = [date descriptionWithCalendarFormat:@"%I:%M %p"];
    NSInteger seconds = [timeZone secondsFromGMT];
    NSInteger magnitude = (seconds < 0) ? -seconds : seconds;
    NSString *gmt = [NSString stringWithFormat:@"GMT %@%02d:%02d", (seconds < 0) ? @"-" : @"+", (int)(magnitude / 3600), (int)((magnitude % 3600) / 60)];
    return [NSString stringWithFormat:@"%@ (%@)", time, gmt];
}

- (void)updateShadow
{
    char cVar1;
    NSString *pcVar3;

    cVar1 = [[self shadowAttributes] isHyperShadowEnabled];
    [_shadowSwitch setState:cVar1];
    [_shadowButton setHidden:((unsigned int)(cVar1 == NO))];
    if (cVar1 == NO) {
        pcVar3 = [_shadowButton title];
    }
    else {
        pcVar3 = @"";
    }
    [_shadowSwitch setTitle:pcVar3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00171592 @ 00171592, 1101 bytes * /

void FUN_00171592(HSWebcamAppearanceAssistantPane *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  uint uVar4;
  cfstringStruct *pcVar5;
  SEL op;
  uint uVar6;
  double dVar7;
  undefined8 uVar8;
  undefined4 uVar9;
  undefined8 local_24;
  float local_1c;
  float fStack_18;
  
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_);
  if (pvVar2 != (id)0x0) {
    pvVar3 = self->_nameTextField;
    _objc_msgSend(pvVar2,sel_hyperName);
    _objc_msgSend(pvVar3,sel_setStringValue_);
  }
  pvVar2 = _objc_msgSend(self,sel_webPageObjectAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_webPageLocation);
  if (pvVar2 == (id)0x0) {
    pvVar2 = self->_locationTextField;
    op = sel_setStringValue_;
  }
  else {
    pvVar2 = _objc_msgSend(pvVar2,sel_componentsSeparatedByString_);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar3 == (id)0x2) {
      pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_);
      _objc_msgSend(cls_NSCharacterSet,sel_whitespaceCharacterSet);
      _objc_msgSend(pvVar2,sel_stringByTrimmingCharactersInSet_);
    }
    _objc_msgSend(self->_locationTextField,sel_setStringValue_);
    pvVar2 = self->_locationTextField;
    op = sel_setToolTip_;
  }
  _objc_msgSend(pvVar2,op);
  pvVar2 = _objc_msgSend(self,sel_webPageObjectAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_webPageCropPath);
  _objc_msgSend_stret(&local_24,pvVar2,sel_bounds);
  uVar8 = CONCAT44(fStack_18,local_1c);
  cVar1 = _NSIsEmptyRect(local_24,uVar8);
  if (cVar1 == '\0') {
    if (DAT_003429b0 == (id)0x0) {
      pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
      DAT_003429b0 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                                   &cfstr__u_x__u_pixels,&cfstr_empty,0);
    }
    uVar6 = (int)fStack_18;
    if (2.1474836e+09 <= fStack_18) {
      uVar6 = (int)(fStack_18 - 2.1474836e+09) ^ 0x80000000;
    }
    pvVar2 = self->_sizeTextField;
    uVar4 = (int)local_1c;
    if (2.1474836e+09 <= local_1c) {
      uVar4 = (int)(local_1c - 2.1474836e+09) ^ 0x80000000;
    }
    pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,DAT_003429b0,uVar4,uVar6,0);
    uVar8 = CONCAT44(uVar4,pvVar3);
  }
  else {
    pvVar2 = self->_sizeTextField;
    uVar8 = CONCAT44((int)((ulonglong)uVar8 >> 0x20),&cfstr___);
  }
  _objc_msgSend(pvVar2,sel_setStringValue_,uVar8);
  pvVar2 = _objc_msgSend(self,sel_webPageObjectAttributes);
  dVar7 = _objc_msgSend_fpret(pvVar2,sel_webPageRefreshRate);
  pvVar2 = _objc_msgSend(cls_NSObject,sel_localizedRefreshRateStringForRate_,dVar7);
  uVar9 = (undefined4)((ulonglong)dVar7 >> 0x20);
  _objc_msgSend(self->_refreshRateTextField,sel_setStringValue_,pvVar2);
  pvVar2 = self->_localTimeTextField;
  pvVar3 = _objc_msgSend(self,sel_webPageObjectAttributes);
  pvVar3 = _objc_msgSend(pvVar3,sel_webPageTimeZone);
  pvVar3 = _objc_msgSend(self,sel_currentTimeStringForTimeZone_,pvVar3);
  uVar8 = CONCAT44(uVar9,pvVar3);
  _objc_msgSend(pvVar2,sel_setStringValue_,pvVar3);
  pvVar2 = _objc_msgSend(self,sel_webPageObjectAttributes);
  pcVar5 = _objc_msgSend(pvVar2,sel_webPageCopyright);
  if (pcVar5 == (cfstringStruct *)0x0) {
    pvVar2 = _objc_msgSend(self,sel_webPageObjectAttributes,uVar8);
    pvVar2 = _objc_msgSend(pvVar2,sel_webPageURL);
    pcVar5 = _objc_msgSend(pvVar2,sel_absoluteString);
  }
  if (pcVar5 == (cfstringStruct *)0x0) {
    pcVar5 = &cfstr___;
  }
  _objc_msgSend(self->_copyrightTextField,sel_setStringValue_,pcVar5);
  _objc_msgSend(self->_copyrightTextField,sel_setToolTip_,pcVar5);
  return;
}

*/
- (void)validateUI
{
    static NSString *sizeFormat = nil;
    id nameAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    if (nameAttributes != nil) {
        [_nameTextField setStringValue:[nameAttributes hyperName]];
    }
    NSString *location = [[self webPageObjectAttributes] webPageLocation];
    if (location == nil) {
        [_locationTextField setStringValue:@"--"];
    } else {
        NSArray *parts = [location componentsSeparatedByString:@";"];
        if ([parts count] == 2) {
            location = [[parts objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        [_locationTextField setStringValue:location];
        [_locationTextField setToolTip:location];
    }
    NSRect cropBounds = [[[self webPageObjectAttributes] webPageCropPath] bounds];
    if (NSIsEmptyRect(cropBounds)) {
        [_sizeTextField setStringValue:@"--"];
    } else {
        if (sizeFormat == nil) {
            sizeFormat = [[[NSBundle mainBundle] localizedStringForKey:@"%u x %u pixels" value:@"" table:nil] retain];
        }
        [_sizeTextField setStringValue:[NSString stringWithFormat:sizeFormat, (unsigned int)cropBounds.size.width, (unsigned int)cropBounds.size.height]];
    }
    [_refreshRateTextField setStringValue:[NSObject localizedRefreshRateStringForRate:[[self webPageObjectAttributes] webPageRefreshRate]]];
    [_localTimeTextField setStringValue:[self currentTimeStringForTimeZone:[[self webPageObjectAttributes] webPageTimeZone]]];
    NSString *copyright = [[self webPageObjectAttributes] webPageCopyright];
    if (copyright == nil) {
        copyright = [[[self webPageObjectAttributes] webPageURL] absoluteString];
    }
    if (copyright == nil) {
        copyright = @"--";
    }
    [_copyrightTextField setStringValue:copyright];
    [_copyrightTextField setToolTip:copyright];
}

- (void)validateShadowAttributesWithNotification:(id)aNotification
{
    [self updateShadow];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)editShadow:(id)aShadow
{
    [self showShadowPane];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00171a51 @ 00171a51, 201 bytes * /

void FUN_00171a51(HSWebcamAppearanceAssistantPane *self,SEL _cmd,id setShadow)

{
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(setShadow,sel_state);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    uVar2 = 0;
    op = sel_setHyperShadowEnabled_;
  }
  else {
    if (pvVar1 != (id)0x1) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
    _objc_msgSend(pvVar1,sel_setHyperShadowEnabled_,1);
    _objc_msgSend(self->_shadowButton,sel_setHidden_,0);
    pvVar1 = self->_shadowButton;
    uVar2 = 1;
    op = sel_setEnabled_;
  }
  _objc_msgSend(pvVar1,op,uVar2);
  return;
}

*/
- (void)setShadow:(id)aShadow
{
    NSInteger state = [aShadow state];
    if (state == 0) {
        [[self shadowAttributes] setHyperShadowEnabled:NO];
    } else if (state == 1) {
        [[self shadowAttributes] setHyperShadowEnabled:YES];
        [_shadowButton setHidden:NO];
        [_shadowButton setEnabled:YES];
    }
}

- (void)showShadowPane
{
    id pvVar1_2;
    id pvVar1_3;

    pvVar1_2 = [[HSTextShadowAssistantPane new] autorelease];
    pvVar1_3 = [[HSObjectAssistantNavigationController alloc] initWithRootViewController:pvVar1_2];
    [self presentModalViewController:pvVar1_3 animated:YES];
    [pvVar1_3 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00171bbe @ 00171bbe, 58 bytes * /

void FUN_00171bbe(HSWebcamAppearanceAssistantPane *self,SEL _cmd,id reloadWebPage)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_webPageObjectAttributes);
  _objc_msgSend(self_00,sel_reload);
  return;
}

*/
- (void)reloadWebPage:(id)aPage
{
    [[self webPageObjectAttributes] reload];
}

- (void)setName:(id)aName
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] setHyperName:[aName stringValue]];
}

- (id)shadowAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSMutableShadowAttributes)];
}

- (id)webPageObjectAttributes
{
    return [[[self assistant] object] queryHyperInterface:@protocol(HSWebPageAttributes)];
}

- (id)nameTextfField
{
    return _nameTextField;
}

- (id)initialKeyView
{
    return _nameTextField;
}

- (BOOL)isEditingTextAttribute
{
    return [_nameTextField currentEditor] != nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00171d5a @ 00171d5a, 501 bytes * /

void FUN_00171d5a(HSWebcamAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  undefined4 uVar1;
  id pvVar2;
  HSWebcamAppearanceAssistantPane *local_34;
  undefined *local_30;
  undefined *local_2c;
  undefined *local_28;
  undefined *local_24;
  undefined *local_20;
  undefined *local_1c;
  undefined *local_18;
  undefined4 local_14;
  
  _objc_msgSend(self->_oneMinuteTimer,sel_invalidate);
  _objc_msgSend(self->_oneMinuteTimer,sel_release);
  self->_oneMinuteTimer = (id)0x0;
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003756c8);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  uVar1 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateUIWithNotification_,uVar1,&DAT_003756c8);
  local_2c = &DAT_003757e0;
  local_28 = &DAT_0037581c;
  local_24 = &DAT_00375830;
  local_20 = &DAT_00375844;
  local_1c = &DAT_00375858;
  local_18 = &DAT_0037586c;
  local_14 = 0;
  pvVar2 = _objc_msgSend(self,sel_webPageObjectAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributes_,self,
                sel_validateUIWithNotification_,uVar1,&local_2c);
  pvVar2 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_attributeObservingController);
  _objc_msgSend(pvVar2,sel_removeObserver_selector_ofChanges_ofAttributesOfHyperInterface_,self,
                sel_validateShadowAttributesWithNotification_,uVar1,&DAT_00375880);
  local_34 = self;
  local_30 = PTR_s_HSObjectAssistantPane_00352400;
  _objc_msgSendSuper(&local_34,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    [_oneMinuteTimer invalidate];
    [_oneMinuteTimer release];
    _oneMinuteTimer = nil;
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
    id webPageAttributes[] = { @protocol(HSWebPageCropPathAttribute), @protocol(HSWebPageTitleAttribute), @protocol(HSWebPageRefreshRateAttribute), @protocol(HSWebPageLocationAttribute), @protocol(HSWebPageTimeZoneAttribute), @protocol(HSWebPageCopyrightAttribute), nil };
    [[[self webPageObjectAttributes] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributes:webPageAttributes];
    [[[self shadowAttributes] attributeObservingController] removeObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSShadowAttributes)];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00171f4f @ 00171f4f, 1013 bytes * /

void FUN_00171f4f(HSWebcamAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  HSWebcamAppearanceAssistantPane *pHVar9;
  undefined *puVar10;
  undefined4 uVar11;
  undefined4 uVar12;
  undefined *local_38;
  undefined *local_34;
  undefined *local_30;
  undefined *local_2c;
  undefined *local_28;
  undefined *local_24;
  undefined4 local_20;
  HSWebcamAppearanceAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00352400;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003756c8);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  uVar7 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateUIWithNotification_,uVar7,&DAT_003756c8,0xbe800000);
  local_38 = &DAT_003757e0;
  local_34 = &DAT_0037581c;
  local_30 = &DAT_00375830;
  local_2c = &DAT_00375844;
  local_28 = &DAT_00375858;
  local_24 = &DAT_0037586c;
  local_20 = 0;
  pvVar1 = _objc_msgSend(self,sel_webPageObjectAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributes_withPriority_,self,
                sel_validateUIWithNotification_,uVar7,&local_38,0xbe800000);
  pvVar1 = _objc_msgSend(self,sel_shadowAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateShadowAttributesWithNotification_,uVar7,&DAT_00375880,0xbe800000);
  _objc_msgSend(self,sel_validateUI);
  _objc_msgSend(self,sel_updateShadow);
  pvVar1 = _objc_msgSend(cls_NSCalendarDate,sel_dateWithTimeIntervalSinceNow_,0,0x404e0000);
  puVar10 = cls_NSCalendarDate;
  pvVar2 = _objc_msgSend(cls_NSTimeZone,sel_systemTimeZone);
  pvVar3 = _objc_msgSend(pvVar1,sel_minuteOfHour);
  pvVar4 = _objc_msgSend(pvVar1,sel_hourOfDay);
  pvVar5 = _objc_msgSend(pvVar1,sel_dayOfMonth);
  pvVar6 = _objc_msgSend(pvVar1,sel_monthOfYear);
  pvVar1 = _objc_msgSend(pvVar1,sel_yearOfCommonEra);
  pvVar1 = _objc_msgSend(puVar10,sel_dateWithYear_month_day_hour_minute_second_timeZone_,pvVar1,
                         pvVar6,pvVar5,pvVar4,pvVar3,0,pvVar2);
  pvVar2 = _objc_msgSend(cls_NSTimer,sel_alloc);
  uVar8 = 0x404e0000;
  uVar7 = 0;
  uVar12 = 1;
  uVar11 = 0;
  pHVar9 = self;
  puVar10 = sel_invalidateLocalTime_;
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithFireDate_interval_target_selector_userInfo_repeats_,
                         pvVar1,0,0x404e0000,self,sel_invalidateLocalTime_,0,1);
  self->_oneMinuteTimer = pvVar2;
  if (pvVar2 != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop,pvVar1,uVar7,uVar8,pHVar9,puVar10,uVar11
                           ,uVar12);
    _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_oneMinuteTimer,*(undefined4 *)PTR_003361b4);
    _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_oneMinuteTimer,*(undefined4 *)PTR_00336064);
    _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_oneMinuteTimer,*(undefined4 *)PTR_003363f8);
  }
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25f];
    id webPageAttributes[] = { @protocol(HSWebPageCropPathAttribute), @protocol(HSWebPageTitleAttribute), @protocol(HSWebPageRefreshRateAttribute), @protocol(HSWebPageLocationAttribute), @protocol(HSWebPageTimeZoneAttribute), @protocol(HSWebPageCopyrightAttribute), nil };
    [[[self webPageObjectAttributes] attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributes:webPageAttributes withPriority:-0.25f];
    [[[self shadowAttributes] attributeObservingController] addObserver:self selector:@selector(validateShadowAttributesWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSShadowAttributes) withPriority:-0.25f];
    [self validateUI];
    [self updateShadow];
    /* refresh the local time every minute, on the minute */
    NSCalendarDate *next = [NSCalendarDate dateWithTimeIntervalSinceNow:60.0];
    NSDate *fireDate = [NSCalendarDate dateWithYear:[next yearOfCommonEra] month:[next monthOfYear] day:[next dayOfMonth] hour:[next hourOfDay] minute:[next minuteOfHour] second:0 timeZone:[NSTimeZone systemTimeZone]];
    _oneMinuteTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:60.0 target:self selector:@selector(invalidateLocalTime:) userInfo:nil repeats:YES];
    if (_oneMinuteTimer != nil) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:_oneMinuteTimer forMode:NSDefaultRunLoopMode];
        [runLoop addTimer:_oneMinuteTimer forMode:NSEventTrackingRunLoopMode];
        [runLoop addTimer:_oneMinuteTimer forMode:NSModalPanelRunLoopMode];
    }
}

- (void)dealloc
{
    [_reloadImage release];
    [_pressedReloadImage release];
    [_oneMinuteTimer invalidate];
    [_oneMinuteTimer release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001723dd @ 001723dd, 289 bytes * /

void FUN_001723dd(HSWebcamAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_ReloadButton_Normal);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_reloadImage = pvVar1;
  puVar3 = sel_currentControlTint;
  pvVar1 = _objc_msgSend(cls_NSColor,sel_respondsToSelector_,sel_currentControlTint);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_NSColor,sel_currentControlTint,puVar3);
    if (pvVar1 == (id)0x6) {
      pcVar2 = &cfstr_ReloadButton_Graphite;
      goto LAB_00172491;
    }
  }
  pcVar2 = &cfstr_ReloadButton_Aqua;
LAB_00172491:
  pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,pcVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_pressedReloadImage = pvVar1;
  _objc_msgSend(self->_reloadButton,sel_setImage_,self->_reloadImage);
  _objc_msgSend(self->_reloadButton,sel_setAlternateImage_,self->_pressedReloadImage);
  return;
}

*/
- (void)viewDidLoad
{
    _reloadImage = [[NSImage imageNamed:@"ReloadButton_Normal"] retain];
    NSString *pressedName = @"ReloadButton_Aqua";
    if ([NSColor respondsToSelector:@selector(currentControlTint)] && [NSColor currentControlTint] == NSGraphiteControlTint) {
        pressedName = @"ReloadButton_Graphite";
    }
    _pressedReloadImage = [[NSImage imageNamed:pressedName] retain];
    [_reloadButton setImage:_reloadImage];
    [_reloadButton setAlternateImage:_pressedReloadImage];
}

- (id)init
{
    self = [super initWithNibName:@"WebcamAppearancePane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

@end

