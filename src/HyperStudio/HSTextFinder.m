#import "HSTextFinder.h"

@implementation HSTextFinder

/* i386 ivar offsets: _findTextField=0x4, _replaceTextField=0x8, _statusField=0xc, _ignoreCaseButton=0x10, _wrapAroundButton=0x14, _findNextButton=0x18, _includeObjectNamesButton=0x1c, _findPanel=0x20, _findString=0x24, _findStringChangedSinceLastPasteboardUpdate=0x28, _lastFindWasSuccessful=0x29, _textFinderDataSource=0x2c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c207c @ 000c207c, 200 bytes * /

void FUN_000c207c(HSTextFinder *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined *puVar2;
  id self_00;
  id pvVar3;
  
  self_00 = _objc_msgSend(cls_NSPasteboard,sel_pasteboardWithName_,*(undefined4 *)PTR_00336488);
  puVar2 = PTR_003361bc;
  if (self->_findStringChangedSinceLastPasteboardUpdate != '\0') {
    pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_003361bc);
    _objc_msgSend(self_00,sel_declareTypes_owner_,pvVar3,0);
    uVar1 = *(undefined4 *)puVar2;
    pvVar3 = _objc_msgSend(self,sel_findString);
    _objc_msgSend(self_00,sel_setString_forType_,pvVar3,uVar1);
    self->_findStringChangedSinceLastPasteboardUpdate = '\0';
  }
  return;
}

*/
- (void)loadFindStringToPasteboard
{
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];
    if (_findStringChangedSinceLastPasteboardUpdate) {
        [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
        [pasteboard setString:[self findString] forType:NSStringPboardType];
        _findStringChangedSinceLastPasteboardUpdate = NO;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c2144 @ 000c2144, 198 bytes * /

void FUN_000c2144(HSTextFinder *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  undefined4 uVar4;
  
  pvVar2 = _objc_msgSend(cls_NSPasteboard,sel_pasteboardWithName_,*(undefined4 *)PTR_00336488);
  pvVar3 = _objc_msgSend(pvVar2,sel_types);
  puVar1 = PTR_003361bc;
  pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,*(undefined4 *)PTR_003361bc);
  if ((char)pvVar3 != '\0') {
    uVar4 = *(undefined4 *)puVar1;
    pvVar2 = _objc_msgSend(pvVar2,sel_stringForType_,uVar4);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar2,sel_length,uVar4);
      if (pvVar3 != (id)0x0) {
        _objc_msgSend(self,sel_setFindString_,pvVar2);
        self->_findStringChangedSinceLastPasteboardUpdate = '\0';
      }
    }
  }
  return;
}

*/
- (void)loadFindStringFromPasteboard
{
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSFindPboard];
    if ([[pasteboard types] containsObject:NSStringPboardType]) {
        NSString *string = [pasteboard stringForType:NSStringPboardType];
        if (string != nil && [string length] != 0) {
            [self setFindString:string];
            _findStringChangedSinceLastPasteboardUpdate = NO;
        }
    }
}

- (void)windowDidUpdate:(id)aUpdate
{
    [_includeObjectNamesButton setEnabled:(unsigned int)([[self textFinderDataSource] shouldEnableIncludeObjectNamesButton])];
}

- (void)appWillDeactivate:(id)aDeactivate
{
    [self loadFindStringToPasteboard];
}

- (void)appDidActivate:(id)aActivate
{
    [self loadFindStringFromPasteboard];
}

- (void)orderFrontFindPanel:(id)aPanel
{
    id self_00;

    self_00 = [self findPanel];
    [_findTextField selectText:nil];
    [self_00 makeKeyAndOrderFront:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c2318 @ 000c2318, 307 bytes * /

ulonglong FUN_000c2318(HSTextFinder *self,SEL _cmd,id rangeOfFindStringInHyperText,
                      uint searchOptions,NSRange startFromSelectedRange)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 extraout_EDX;
  uint uVar3;
  int iVar4;
  bool bVar5;
  float fVar6;
  float fVar7;
  
  if (rangeOfFindStringInHyperText != (id)0x0) {
    pvVar1 = _objc_msgSend(rangeOfFindStringInHyperText,sel_length);
    fVar6 = (float)((double)(ZEXT48(pvVar1) | 0x4330000000000000) - 4503599627370496.0);
    if ((fVar6 != 0.0) && (startFromSelectedRange.location != 0x7fffffff)) {
      if (startFromSelectedRange.length == 0 && startFromSelectedRange.location == 0) {
        iVar4 = 0;
        fVar7 = fVar6;
      }
      else {
        bVar5 = (searchOptions & 4) == 0;
        iVar4 = 0;
        if (bVar5) {
          iVar4 = startFromSelectedRange.length + startFromSelectedRange.location;
        }
        fVar7 = (float)((double)((ulonglong)startFromSelectedRange & 0xffffffff | 0x4330000000000000
                                ) - 4503599627370496.0);
        if (bVar5) {
          fVar7 = (fVar6 - fVar7) -
                  (float)((double)((ulonglong)startFromSelectedRange.length | 0x4330000000000000) -
                         4503599627370496.0);
        }
      }
      uVar3 = (int)fVar7;
      if (2.1474836e+09 <= fVar7) {
        uVar3 = (int)(fVar7 - 2.1474836e+09) ^ 0x80000000;
      }
      pvVar1 = _objc_msgSend(self,sel_findString);
      pvVar1 = _objc_msgSend(rangeOfFindStringInHyperText,sel_rangeOfString_options_range_,pvVar1,
                             searchOptions,iVar4,uVar3);
      uVar2 = extraout_EDX;
      goto LAB_000c243f;
    }
  }
  pvVar1 = (id)0x7fffffff;
  uVar2 = 0;
LAB_000c243f:
  return CONCAT44(uVar2,pvVar1);
}

*/
- (NSRange)rangeOfFindStringInHyperText:(id)aText searchOptions:(NSUInteger)aOptions startFromSelectedRange:(NSRange)aRange
{
    if (aText != nil) {
        NSUInteger length = [aText length];
        if (length != 0 && aRange.location != NSNotFound) {
            NSUInteger start = 0;
            NSUInteger searchLength = length;
            if (aRange.location != 0 || aRange.length != 0) {
                if ((aOptions & NSBackwardsSearch) == 0) {
                    start = aRange.location + aRange.length;
                    searchLength = length - aRange.location - aRange.length;
                }
                else {
                    searchLength = aRange.location;
                }
            }
            return [aText rangeOfString:[self findString] options:aOptions range:NSMakeRange(start, searchLength)];
        }
    }
    return NSMakeRange(NSNotFound, 0);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c244b @ 000c244b, 498 bytes * /

void FUN_000c244b(HSTextFinder *self,SEL _cmd,uint checkCurrentItemWithOptions,
                 BOOL ignoreSelectedRange)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  undefined4 extraout_EDX_02;
  SEL op;
  uint uVar6;
  
  pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperNameForCurrentItem);
  if (ignoreSelectedRange == '\0') {
    pvVar2 = _objc_msgSend(self,sel_textFinderDataSource);
    pvVar2 = _objc_msgSend(pvVar2,sel_selectedRangeForCurrentItemName);
    uVar5 = extraout_EDX;
  }
  else {
    pvVar2 = (id)0x0;
    uVar5 = 0;
  }
  uVar6 = checkCurrentItemWithOptions;
  pvVar3 = _objc_msgSend(self,sel_rangeOfFindStringInHyperText_searchOptions_startFromSelectedRange_
                         ,pvVar1,checkCurrentItemWithOptions,pvVar2,uVar5);
  if (pvVar3 == (id)0x7fffffff) {
    if (self->_lastFindWasSuccessful != '\0') {
      return;
    }
    pvVar3 = _objc_msgSend(self,sel_textFinderDataSource,pvVar1,uVar6,pvVar2,uVar5);
    pvVar4 = _objc_msgSend(pvVar3,sel_hyperTextForCurrentItem);
    if (ignoreSelectedRange == '\0') {
      pvVar1 = _objc_msgSend(self,sel_textFinderDataSource,pvVar1,uVar6,pvVar2,uVar5);
      pvVar1 = _objc_msgSend(pvVar1,sel_selectedRangeForCurrentItem);
      uVar5 = extraout_EDX_01;
    }
    else {
      pvVar1 = (id)0x0;
      uVar5 = 0;
    }
    pvVar3 = _objc_msgSend(self,
                           sel_rangeOfFindStringInHyperText_searchOptions_startFromSelectedRange_,
                           pvVar4,checkCurrentItemWithOptions,pvVar1,uVar5);
    if (pvVar3 == (id)0x7fffffff) {
      return;
    }
    pvVar1 = _objc_msgSend(self,sel_textFinderDataSource,pvVar4,checkCurrentItemWithOptions,pvVar1,
                           uVar5);
    _objc_msgSend(pvVar1,sel_activateCurrentItem);
    pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
    op = sel_selectCurrentItemStringWithRange_;
    uVar5 = extraout_EDX_02;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textFinderDataSource,pvVar1,uVar6,pvVar2,uVar5);
    _objc_msgSend(pvVar1,sel_activateInspectorOfCurrentItem);
    pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
    op = sel_selectCurrentItemNameWithRange_;
    uVar5 = extraout_EDX_00;
  }
  _objc_msgSend(pvVar1,op,pvVar3,uVar5);
  self->_lastFindWasSuccessful = '\x01';
  return;
}

*/
- (void)checkCurrentItemWithOptions:(NSUInteger)aOptions ignoreSelectedRange:(BOOL)aRange
{
    id dataSource = [self textFinderDataSource];
    NSString *name = [dataSource hyperNameForCurrentItem];
    NSRange nameRange = aRange ? NSMakeRange(0, 0) : [[self textFinderDataSource] selectedRangeForCurrentItemName];
    NSRange found = [self rangeOfFindStringInHyperText:name searchOptions:aOptions startFromSelectedRange:nameRange];
    if (found.location != NSNotFound) {
        [[self textFinderDataSource] activateInspectorOfCurrentItem];
        [[self textFinderDataSource] selectCurrentItemNameWithRange:found];
        _lastFindWasSuccessful = YES;
        return;
    }
    if (_lastFindWasSuccessful) {
        return;
    }
    NSString *text = [[self textFinderDataSource] hyperTextForCurrentItem];
    NSRange textRange = aRange ? NSMakeRange(0, 0) : [[self textFinderDataSource] selectedRangeForCurrentItem];
    found = [self rangeOfFindStringInHyperText:text searchOptions:aOptions startFromSelectedRange:textRange];
    if (found.location == NSNotFound) {
        return;
    }
    [[self textFinderDataSource] activateCurrentItem];
    [[self textFinderDataSource] selectCurrentItemStringWithRange:found];
    _lastFindWasSuccessful = YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c263d @ 000c263d, 577 bytes * /

BOOL FUN_000c263d(HSTextFinder *self,SEL _cmd,int find)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  int iVar7;
  int iVar8;
  cfstringStruct *pcVar9;
  
  self->_lastFindWasSuccessful = '\0';
  pvVar2 = _objc_msgSend(self,sel_ignoreCaseSearch);
  pvVar3 = _objc_msgSend(self,sel_wrapsAround);
  pvVar4 = _objc_msgSend(self,sel_textFinderDataSource);
  _objc_msgSend(pvVar4,sel_setDirection_,find);
  pvVar4 = _objc_msgSend(self,sel_textFinderDataSource);
  _objc_msgSend(pvVar4,sel_setWrapsAround_,(int)(char)pvVar3);
  pvVar4 = _objc_msgSend(self,sel_textFinderDataSource);
  pvVar5 = _objc_msgSend(self,sel_includeObjectNames);
  iVar7 = (uint)((char)pvVar2 != '\0') + (uint)(find == 0) * 4;
  _objc_msgSend(pvVar4,sel_setIncludeObjectNames_,(int)(char)pvVar5);
  pcVar9 = (cfstringStruct *)0x0;
  iVar8 = iVar7;
  _objc_msgSend(self,sel_checkCurrentItemWithOptions_ignoreSelectedRange_,iVar7,0);
  cVar1 = self->_lastFindWasSuccessful;
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(self,sel_textFinderDataSource,iVar8,pcVar9);
    _objc_msgSend(pvVar2,sel_startEnumeration);
    do {
      cVar1 = self->_lastFindWasSuccessful;
      if (cVar1 != '\0') goto LAB_000c27e9;
      pvVar2 = _objc_msgSend(self,sel_textFinderDataSource,iVar8,pcVar9);
      pvVar2 = _objc_msgSend(pvVar2,sel_moveToNext);
      if (((char)pvVar2 != '\0') || ((char)pvVar3 != '\0')) {
        pcVar9 = (cfstringStruct *)0x1;
        iVar8 = iVar7;
        _objc_msgSend(self,sel_checkCurrentItemWithOptions_ignoreSelectedRange_,iVar7,1);
      }
    } while ((char)pvVar2 != '\0');
    cVar1 = self->_lastFindWasSuccessful;
  }
LAB_000c27e9:
  if (cVar1 == '\0') {
    _NSBeep();
    pvVar2 = self->_statusField;
    pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle,iVar8,pcVar9);
    pcVar9 = &cfstr_empty;
    pcVar6 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Not_found,
                           &cfstr_empty,&cfstr_FindPanel);
  }
  else {
    pvVar2 = self->_statusField;
    pcVar6 = &cfstr_empty;
  }
  _objc_msgSend(pvVar2,sel_setStringValue_,pcVar6,pcVar9);
  return self->_lastFindWasSuccessful;
}

*/
- (BOOL)find:(NSInteger)aFind
{
    _lastFindWasSuccessful = NO;
    BOOL ignoreCase = [self ignoreCaseSearch];
    BOOL wrapsAround = [self wrapsAround];
    [(id<HSTextObjectDataSource>)[self textFinderDataSource] setDirection:aFind];
    [[self textFinderDataSource] setWrapsAround:wrapsAround];
    [[self textFinderDataSource] setIncludeObjectNames:[self includeObjectNames]];
    NSUInteger options = (ignoreCase ? NSCaseInsensitiveSearch : 0) + (aFind == 0 ? NSBackwardsSearch : 0);
    [self checkCurrentItemWithOptions:options ignoreSelectedRange:NO];
    if (!_lastFindWasSuccessful) {
        [[self textFinderDataSource] startEnumeration];
        BOOL moved;
        do {
            if (_lastFindWasSuccessful) {
                break;
            }
            moved = [[self textFinderDataSource] moveToNext];
            if (moved || wrapsAround) {
                [self checkCurrentItemWithOptions:options ignoreSelectedRange:YES];
            }
        } while (moved);
    }
    if (!_lastFindWasSuccessful) {
        NSBeep();
        [_statusField setStringValue:[[NSBundle mainBundle] localizedStringForKey:@"Not found" value:@"" table:@"FindPanel"]];
    }
    else {
        [_statusField setStringValue:@""];
    }
    return _lastFindWasSuccessful;
}

- (id)findPanel
{
    id pvVar2;

    pvVar2 = _findPanel;
    if (pvVar2 == nil) {
        [NSBundle loadNibNamed:@"FindPanel" owner:self];
        [_findPanel setFrameAutosaveName:@"Find"];
        [_findTextField setStringValue:[self findString]];
        [_findPanel setDelegate:self];
        pvVar2 = _findPanel;
    }
    return pvVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c292f @ 000c292f, 174 bytes * /

void FUN_000c292f(HSTextFinder *self,SEL _cmd,id findPanelActionSetFindString)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(findPanelActionSetFindString,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_selectedRange);
  pvVar2 = _objc_msgSend(findPanelActionSetFindString,sel_object);
  pvVar2 = _objc_msgSend(pvVar2,sel_textStorage);
  pvVar2 = _objc_msgSend(pvVar2,sel_string);
  pvVar1 = _objc_msgSend(pvVar2,sel_substringWithRange_,pvVar1,extraout_EDX);
  _objc_msgSend(self,sel_setFindString_,pvVar1);
  return;
}

*/
- (void)findPanelActionSetFindString:(id)aString
{
    NSRange selectedRange = [[aString object] selectedRange];
    [self setFindString:[[[[aString object] textStorage] string] substringWithRange:selectedRange]];
}

- (void)setIncludeObjectNames:(BOOL)aNames
{
    [_includeObjectNamesButton setState:aNames];
}

- (BOOL)includeObjectNames
{
    BOOL bVar2;

    if (_includeObjectNamesButton == nil) {
        bVar2 = YES;
    }
    else {
        bVar2 = [_includeObjectNamesButton state] == 0x1;
    }
    return bVar2;
}

- (void)setIgnoreCaseSearch:(BOOL)aSearch
{
    [_ignoreCaseButton setState:aSearch];
}

- (BOOL)ignoreCaseSearch
{
    BOOL bVar2;

    if (_ignoreCaseButton == nil) {
        bVar2 = YES;
    }
    else {
        bVar2 = [_ignoreCaseButton state] == 0x1;
    }
    return bVar2;
}

- (void)setWrapsAround:(BOOL)aAround
{
    [_wrapAroundButton setState:aAround];
}

- (BOOL)wrapsAround
{
    BOOL bVar2;

    if (_wrapAroundButton == nil) {
        bVar2 = YES;
    }
    else {
        bVar2 = [_wrapAroundButton state] == 0x1;
    }
    return bVar2;
}

- (void)setFindString:(id)aString
{
    if (![aString isEqualToString:_findString]) {
        [_findString release];
        _findString = [aString retain];
        if (_findTextField != nil) {
            [_findTextField setStringValue:aString];
            [_findTextField selectText:nil];
        }
        _findStringChangedSinceLastPasteboardUpdate = YES;
    }
}

- (id)findString
{
    id pcVar1;

    pcVar1 = _findString;
    if (pcVar1 == NULL) {
        pcVar1 = @"";
        _findString = @"";
    }
    return pcVar1;
}

- (void)setTextFinderDataSource:(id)aSource
{
    _textFinderDataSource = aSource;
}

- (id)textFinderDataSource
{
    return _textFinderDataSource;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c2bc9 @ 000c2bc9, 144 bytes * /

void FUN_000c2bc9(HSTextFinder *self,SEL _cmd,id runFindPanel)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(runFindPanel,sel_tag);
  op = sel_orderFrontFindPanel_;
  if (((pvVar1 == (id)0x1) ||
      (pvVar1 = _objc_msgSend(runFindPanel,sel_tag), op = sel_findNext_, pvVar1 == (id)0x2)) ||
     (pvVar1 = _objc_msgSend(runFindPanel,sel_tag), op = sel_findPrevious_, pvVar1 == (id)0x3)) {
    _objc_msgSend(self,op,runFindPanel);
  }
  return;
}

*/
- (void)runFindPanel:(id)aPanel
{
    NSInteger tag = [aPanel tag];
    if (tag == 1) {
        [self orderFrontFindPanel:aPanel];
    }
    else if (tag == 2) {
        [self findNext:aPanel];
    }
    else if (tag == 3) {
        [self findPrevious:aPanel];
    }
}

- (void)includeObjectNamesChanged:(id)aChanged
{
    [[self textFinderDataSource] setIncludeObjectNames:(unsigned int)([aChanged state] == 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c2cb9 @ 000c2cb9, 1745 bytes * /

void FUN_000c2cb9(HSTextFinder *self,SEL _cmd,id replaceAll)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  uint uVar6;
  id pvVar7;
  id pvVar8;
  id self_01;
  int extraout_EDX;
  int iVar9;
  int extraout_EDX_00;
  int extraout_EDX_01;
  int extraout_EDX_02;
  int iVar10;
  uint uVar11;
  int iVar12;
  cfstringStruct *pcVar13;
  cfstringStruct *local_28;
  id local_18;
  
  if (self->_findTextField != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_findTextField,sel_stringValue);
    _objc_msgSend(self,sel_setFindString_,pvVar1);
  }
  pvVar2 = _objc_msgSend(self,sel_ignoreCaseSearch);
  pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
  _objc_msgSend(pvVar1,sel_setDirection_,1);
  pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
  _objc_msgSend(pvVar1,sel_setWrapsAround_,1);
  pvVar3 = _objc_msgSend(self,sel_textFinderDataSource);
  pvVar1 = _objc_msgSend(self,sel_includeObjectNames);
  pvVar1 = (id)(int)(char)pvVar1;
  _objc_msgSend(pvVar3,sel_setIncludeObjectNames_,pvVar1);
  pvVar3 = _objc_msgSend(self->_findTextField,sel_stringValue);
  pvVar3 = _objc_msgSend(pvVar3,sel_length);
  pvVar4 = _objc_msgSend(self->_replaceTextField,sel_stringValue);
  pvVar4 = _objc_msgSend(pvVar4,sel_length);
  pvVar5 = _objc_msgSend(self,sel_textFinderDataSource);
  _objc_msgSend(pvVar5,sel_startEnumeration);
  uVar6 = (uint)((char)pvVar2 != '\0');
  local_28 = (cfstringStruct *)0x0;
  pvVar2 = _objc_msgSend(self->_replaceTextField,sel_stringValue);
  do {
    pvVar5 = _objc_msgSend(self,sel_textFinderDataSource,pvVar1);
    pvVar7 = _objc_msgSend(pvVar5,sel_moveToNext);
    pvVar5 = _objc_msgSend(self,sel_textFinderDataSource);
    pvVar5 = _objc_msgSend(pvVar5,sel_hyperNameForCurrentItem);
    if (pvVar5 == (id)0x0) {
      local_18 = (id)0x0;
      pvVar5 = pvVar1;
    }
    else {
      local_18 = _objc_msgSend(cls_NSMutableString,sel_stringWithString_,pvVar5);
    }
    pvVar1 = _objc_msgSend(local_18,sel_length,pvVar5);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(local_18,sel_length,pvVar5);
      pvVar5 = _objc_msgSend(self,sel_findString);
      iVar12 = 0;
      uVar11 = uVar6;
      pvVar8 = _objc_msgSend(local_18,sel_rangeOfString_options_range_,pvVar5,uVar6,0,pvVar1);
      if (pvVar8 == (id)0x7fffffff) {
        iVar10 = 0;
      }
      else {
        iVar10 = 0;
        iVar9 = extraout_EDX;
        do {
          _objc_msgSend(local_18,sel_replaceCharactersInRange_withString_,pvVar8,iVar9,pvVar2,pvVar1
                       );
          pvVar1 = _objc_msgSend(local_18,sel_length);
          iVar12 = (int)pvVar8 + (int)pvVar4 + (iVar9 - (int)pvVar3);
          pvVar1 = (id)((int)pvVar1 - iVar12);
          pvVar5 = _objc_msgSend(self,sel_findString);
          iVar10 = iVar10 + 1;
          uVar11 = uVar6;
          pvVar8 = _objc_msgSend(local_18,sel_rangeOfString_options_range_,pvVar5,uVar6,iVar12);
          iVar9 = extraout_EDX_00;
        } while (pvVar8 != (id)0x7fffffff);
      }
      pvVar1 = _objc_msgSend(self,sel_textFinderDataSource,pvVar5,uVar11,iVar12,pvVar1);
      pvVar1 = _objc_msgSend(pvVar1,sel_setHyperNameForCurrentItem_,local_18);
      iVar12 = 0;
      if ((char)pvVar1 != '\0') {
        iVar12 = iVar10;
      }
      local_28 = (cfstringStruct *)((int)&local_28->field0_0x0 + iVar12);
      pvVar5 = local_18;
    }
    pvVar1 = _objc_msgSend(self,sel_textFinderDataSource,pvVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperTextForCurrentItem);
    if (pvVar1 == (id)0x0) {
      local_18 = (id)0x0;
      pvVar1 = pvVar5;
    }
    else {
      local_18 = _objc_msgSend(cls_NSMutableString,sel_stringWithString_,pvVar1);
    }
    pvVar5 = _objc_msgSend(local_18,sel_length,pvVar1);
    if (pvVar5 != (id)0x0) {
      pvVar1 = _objc_msgSend(local_18,sel_length,pvVar1);
      pvVar5 = _objc_msgSend(self,sel_findString);
      iVar12 = 0;
      uVar11 = uVar6;
      pvVar8 = _objc_msgSend(local_18,sel_rangeOfString_options_range_,pvVar5,uVar6,0,pvVar1);
      self_01 = _objc_msgSend(cls_NSMutableArray,sel_array);
      if (pvVar8 == (id)0x7fffffff) {
        iVar10 = 0;
      }
      else {
        iVar10 = 0;
        iVar9 = extraout_EDX_01;
        do {
          _objc_msgSend(local_18,sel_replaceCharactersInRange_withString_,pvVar8,iVar9,pvVar2,pvVar1
                       );
          pvVar1 = _objc_msgSend(cls_NSValue,sel_valueWithRange_,pvVar8,iVar9);
          _objc_msgSend(self_01,sel_addObject_,pvVar1);
          pvVar1 = _objc_msgSend(local_18,sel_length);
          iVar12 = (int)pvVar8 + (int)pvVar4 + (iVar9 - (int)pvVar3);
          pvVar1 = (id)((int)pvVar1 - iVar12);
          pvVar5 = _objc_msgSend(self,sel_findString);
          iVar10 = iVar10 + 1;
          uVar11 = uVar6;
          pvVar8 = _objc_msgSend(local_18,sel_rangeOfString_options_range_,pvVar5,uVar6,iVar12);
          iVar9 = extraout_EDX_02;
        } while (pvVar8 != (id)0x7fffffff);
      }
      pvVar5 = _objc_msgSend(self,sel_textFinderDataSource,pvVar5,uVar11,iVar12,pvVar1);
      pvVar1 = pvVar2;
      pvVar5 = _objc_msgSend(pvVar5,sel_hyperReplaceTextForCurrentItem_inRanges_,pvVar2,self_01);
      iVar12 = 0;
      if ((char)pvVar5 != '\0') {
        iVar12 = iVar10;
      }
      local_28 = (cfstringStruct *)((int)&local_28->field0_0x0 + iVar12);
    }
    self_00 = cls_NSString;
  } while ((char)pvVar7 != '\0');
  if (local_28 == (cfstringStruct *)0x0) {
    _NSBeep();
    pvVar2 = self->_statusField;
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pvVar1);
    pcVar13 = &cfstr_FindPanel;
    local_28 = &cfstr_empty;
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Not_found,
                           &cfstr_empty,&cfstr_FindPanel);
  }
  else {
    pvVar2 = self->_statusField;
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle,pvVar1);
    pcVar13 = &cfstr_FindPanel;
    pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr__d_replaced,
                           &cfstr_empty,&cfstr_FindPanel);
    pvVar1 = _objc_msgSend(self_00,sel_localizedStringWithFormat_,pvVar1,local_28);
  }
  _objc_msgSend(pvVar2,sel_setStringValue_,pvVar1,local_28,pcVar13);
  return;
}

*/
- (void)replaceAll:(id)aAll
{
    if (_findTextField != nil) {
        [self setFindString:[_findTextField stringValue]];
    }
    BOOL ignoreCase = [self ignoreCaseSearch];
    [(id<HSTextObjectDataSource>)[self textFinderDataSource] setDirection:1];
    [[self textFinderDataSource] setWrapsAround:YES];
    [[self textFinderDataSource] setIncludeObjectNames:[self includeObjectNames]];
    NSUInteger findLength = [[_findTextField stringValue] length];
    NSUInteger replaceLength = [[_replaceTextField stringValue] length];
    [[self textFinderDataSource] startEnumeration];
    NSUInteger options = ignoreCase ? NSCaseInsensitiveSearch : 0;
    NSInteger replacedCount = 0;
    NSString *replacement = [_replaceTextField stringValue];
    BOOL moved;
    do {
        moved = [[self textFinderDataSource] moveToNext];
        NSString *name = [[self textFinderDataSource] hyperNameForCurrentItem];
        NSMutableString *string = (name != nil) ? [NSMutableString stringWithString:name] : nil;
        if ([string length] != 0) {
            NSRange found = [string rangeOfString:[self findString] options:options range:NSMakeRange(0, [string length])];
            NSInteger count = 0;
            while (found.location != NSNotFound) {
                [string replaceCharactersInRange:found withString:replacement];
                NSUInteger next = found.location + replaceLength + (found.length - findLength);
                count++;
                found = [string rangeOfString:[self findString] options:options range:NSMakeRange(next, [string length] - next)];
            }
            if ([[self textFinderDataSource] setHyperNameForCurrentItem:string]) {
                replacedCount += count;
            }
        }
        NSString *text = [[self textFinderDataSource] hyperTextForCurrentItem];
        string = (text != nil) ? [NSMutableString stringWithString:text] : nil;
        if ([string length] != 0) {
            NSRange found = [string rangeOfString:[self findString] options:options range:NSMakeRange(0, [string length])];
            NSMutableArray *ranges = [NSMutableArray array];
            NSInteger count = 0;
            while (found.location != NSNotFound) {
                [string replaceCharactersInRange:found withString:replacement];
                [ranges addObject:[NSValue valueWithRange:found]];
                NSUInteger next = found.location + replaceLength + (found.length - findLength);
                count++;
                found = [string rangeOfString:[self findString] options:options range:NSMakeRange(next, [string length] - next)];
            }
            if ([[self textFinderDataSource] hyperReplaceTextForCurrentItem:replacement inRanges:ranges]) {
                replacedCount += count;
            }
        }
    } while (moved);
    if (replacedCount == 0) {
        NSBeep();
        [_statusField setStringValue:[[NSBundle mainBundle] localizedStringForKey:@"Not found" value:@"" table:@"FindPanel"]];
    }
    else {
        NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"%d replaced" value:@"" table:@"FindPanel"];
        [_statusField setStringValue:[NSString localizedStringWithFormat:format, (int)replacedCount]];
    }
}

- (void)replaceAndFind:(id)aFind
{
    [self replace:aFind];
    [self findNext:aFind];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c33d3 @ 000c33d3, 703 bytes * /

void FUN_000c33d3(HSTextFinder *self,SEL _cmd,id replace)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  int iVar5;
  
  pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperNameForCurrentItem);
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSMutableString,sel_stringWithString_,pvVar1);
  }
  pvVar2 = _objc_msgSend(self,sel_textFinderDataSource);
  pvVar2 = _objc_msgSend(pvVar2,sel_selectedRangeForCurrentItemName);
  if ((pvVar1 == (id)0x0) || (pvVar2 == (id)0x7fffffff)) {
    pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperTextForCurrentItem);
    pvVar2 = _objc_msgSend(self,sel_textFinderDataSource);
    pvVar2 = _objc_msgSend(pvVar2,sel_selectedRangeForCurrentItem);
    if ((pvVar1 == (id)0x0) || (pvVar2 == (id)0x7fffffff)) {
      _NSBeep();
      goto LAB_000c3668;
    }
    pvVar3 = _objc_msgSend(self->_replaceTextField,sel_stringValue);
    pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
    self_00 = cls_NSArray;
    pvVar4 = _objc_msgSend(cls_NSValue,sel_valueWithRange_,pvVar2,extraout_EDX_00);
    pvVar4 = _objc_msgSend(self_00,sel_arrayWithObject_,pvVar4);
    _objc_msgSend(pvVar1,sel_hyperReplaceTextForCurrentItem_inRanges_,pvVar3,pvVar4);
    pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
    pvVar3 = _objc_msgSend(pvVar3,sel_length);
    iVar5 = (int)pvVar2 + (int)pvVar3;
    op = sel_selectCurrentItemStringWithRange_;
  }
  else {
    pvVar3 = _objc_msgSend(self->_replaceTextField,sel_stringValue);
    _objc_msgSend(pvVar1,sel_replaceCharactersInRange_withString_,pvVar2,extraout_EDX,pvVar3);
    pvVar4 = _objc_msgSend(self,sel_textFinderDataSource);
    _objc_msgSend(pvVar4,sel_setHyperNameForCurrentItem_,pvVar1);
    pvVar1 = _objc_msgSend(self,sel_textFinderDataSource);
    pvVar3 = _objc_msgSend(pvVar3,sel_length);
    iVar5 = (int)pvVar2 + (int)pvVar3;
    op = sel_selectCurrentItemNameWithRange_;
  }
  _objc_msgSend(pvVar1,op,iVar5,0);
LAB_000c3668:
  _objc_msgSend(self->_statusField,sel_setStringValue_,&cfstr_empty);
  return;
}

*/
- (void)replace:(id)aReplace
{
    NSString *name = [[self textFinderDataSource] hyperNameForCurrentItem];
    NSMutableString *string = (name != nil) ? [NSMutableString stringWithString:name] : nil;
    NSRange nameRange = [[self textFinderDataSource] selectedRangeForCurrentItemName];
    if (string == nil || nameRange.location == NSNotFound) {
        NSString *text = [[self textFinderDataSource] hyperTextForCurrentItem];
        NSRange textRange = [[self textFinderDataSource] selectedRangeForCurrentItem];
        if (text == nil || textRange.location == NSNotFound) {
            NSBeep();
        }
        else {
            NSString *replacement = [_replaceTextField stringValue];
            [[self textFinderDataSource] hyperReplaceTextForCurrentItem:replacement inRanges:[NSArray arrayWithObject:[NSValue valueWithRange:textRange]]];
            [[self textFinderDataSource] selectCurrentItemStringWithRange:NSMakeRange(textRange.location + [replacement length], 0)];
        }
    }
    else {
        NSString *replacement = [_replaceTextField stringValue];
        [string replaceCharactersInRange:nameRange withString:replacement];
        [[self textFinderDataSource] setHyperNameForCurrentItem:string];
        [[self textFinderDataSource] selectCurrentItemNameWithRange:NSMakeRange(nameRange.location + [replacement length], 0)];
    }
    [_statusField setStringValue:@""];
}

- (void)findPrevious:(id)aPrevious
{
    if (_findTextField != nil) {
        [self setFindString:[_findTextField stringValue]];
    }
    [self find:0];
}

- (void)findNext:(id)aNext
{
    if (_findTextField != nil) {
        [self setFindString:[_findTextField stringValue]];
    }
    [self find:1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000c3754 @ 000c3754, 130 bytes * /

void FUN_000c3754(HSTextFinder *self,SEL _cmd,id findNextAndOrderFindPanelOut)

{
  id self_00;
  SEL op;
  undefined4 uVar1;
  
  uVar1 = 0;
  _objc_msgSend(self->_findNextButton,sel_performClick_,0);
  if (self->_lastFindWasSuccessful == '\0') {
    self_00 = self->_findTextField;
    findNextAndOrderFindPanelOut = (id)0x0;
    op = sel_selectText_;
  }
  else {
    self_00 = _objc_msgSend(self,sel_findPanel,uVar1);
    op = sel_orderOut_;
  }
  _objc_msgSend(self_00,op,findNextAndOrderFindPanelOut);
  return;
}

*/
- (void)findNextAndOrderFindPanelOut:(id)aOut
{
    [_findNextButton performClick:nil];
    if (_lastFindWasSuccessful) {
        [[self findPanel] orderOut:aOut];
    }
    else {
        [_findTextField selectText:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_findString release];
    [_findPanel release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidActivate:) name:NSApplicationDidBecomeActiveNotification object:[NSApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillDeactivate:) name:NSApplicationWillResignActiveNotification object:[NSApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findPanelActionSetFindString:) name:HSFindPanelActionSetFindStringNotification object:0];
        [self loadFindStringFromPasteboard];
    }
    return self;
}

@end

