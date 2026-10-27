#import "HSAutoTypeActionAssistantPane.h"

@implementation HSAutoTypeActionAssistantPane

/* i386 ivar offsets: _tableView=0x88, _textToTypeView=0x8c, _containerView=0x90, _mainView=0x94, _emptyView=0x98, _currentView=0x9c, _availableTextViews=0xa0 */

- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id pvVar1_6;
    id pvVar2_3;

    if ([self availableTextViews] != nil) {
        if ([[aColumn identifier] isEqual:@"HSTextViewObjectCheckboxTableIdentifier"]) {
            pvVar1_6 = [[[self availableTextViews] objectAtIndex:aRow] hyperUID];
            pvVar2_3 = [[[self actionAttributes] textViewUIDs] mutableCopy];
            if (pvVar2_3 == nil) {
                pvVar2_3 = [NSMutableArray new];
            }
            [pvVar2_3 removeObject:pvVar1_6];
            if ([aValue intValue] != 0) {
                [pvVar2_3 addObject:pvVar1_6];
            }
            [[self autoTypeActionAssistantPaneApplier] setTextViewUIDs:pvVar2_3];
            [pvVar2_3 release];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e9c08 @ 000e9c08, 509 bytes * /

id FUN_000e9c08(HSAutoTypeActionAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  SEL op;
  cfstringStruct *pcVar6;
  undefined *puVar7;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_availableTextViews);
  if (pvVar1 == (id)0x0) {
LAB_000e9c30:
    local_14 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_availableTextViews);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID);
    pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
    pcVar6 = &cfstr_HSTextViewObjectNameTableIdentifier;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSTextViewObjectNameTableIdentifier);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar6);
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSTextViewObjectCheckboxTableIdentifier);
      if ((char)pvVar2 == '\0') goto LAB_000e9c30;
      pvVar2 = (id)0x0;
      pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,0);
      pvVar4 = _objc_msgSend(self,sel_actionAttributes);
      pvVar4 = _objc_msgSend(pvVar4,sel_textViewUIDs);
      pvVar4 = _objc_msgSend(pvVar4,sel_objectEnumerator);
      do {
        pvVar5 = _objc_msgSend(pvVar4,sel_nextObject,pvVar2);
        if (pvVar5 == (id)0x0) {
          return pvVar3;
        }
        pvVar2 = pvVar1;
        pvVar5 = _objc_msgSend(pvVar5,sel_isEqual_,pvVar1);
      } while ((char)pvVar5 == '\0');
      puVar7 = (undefined *)0x1;
      self_00 = cls_NSNumber;
      op = sel_numberWithInt_;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_availableTextViews,pcVar6);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
      puVar7 = &DAT_0036d770;
      self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036d770);
      op = sel_hyperName;
    }
    local_14 = _objc_msgSend(self_00,op,puVar7);
  }
  return local_14;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if ([self availableTextViews] == nil) {
        return nil;
    }
    id uid = [[[self availableTextViews] objectAtIndex:aRow] hyperUID];
    if ([[aColumn identifier] isEqual:@"HSTextViewObjectNameTableIdentifier"]) {
        return [[[[self availableTextViews] objectAtIndex:aRow] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    }
    if (![[aColumn identifier] isEqual:@"HSTextViewObjectCheckboxTableIdentifier"]) {
        return nil;
    }
    NSEnumerator *enumerator = [[[self actionAttributes] textViewUIDs] objectEnumerator];
    id candidate;
    while ((candidate = [enumerator nextObject]) != nil) {
        if ([candidate isEqual:uid]) {
            return [NSNumber numberWithInt:1];
        }
    }
    return [NSNumber numberWithInt:0];
    return 0;
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[[self availableTextViews] count];
}

- (id)helpTopicKey
{
    return @"HSAutoType";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    id pvVar1_2;

    [_availableTextViews release];
    _availableTextViews = nil;
    pvVar1_2 = [[NSAttributedString alloc] initWithAttributedString:[_textToTypeView textStorage]];
    [[self autoTypeActionAssistantPaneApplier] setTextToType:pvVar1_2];
    [pvVar1_2 release];
    [_tableView setDataSource:0];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ea43b @ 000ea43b, 394 bytes * /

void FUN_000ea43b(HSAutoTypeActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  HSAutoTypeActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00350780;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self->_tableView,sel_setDataSource_,self);
  pvVar1 = _objc_msgSend(self,sel_availableTextViews);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 == (id)0x0) {
    pvVar1 = self->_emptyView;
    op = sel_mountView_;
  }
  else {
    pvVar2 = self->_mainView;
    _objc_msgSend(self,sel_mountView_,pvVar2);
    _objc_msgSend(self->_tableView,sel_reloadData);
    pvVar1 = _objc_msgSend(self,sel_actionAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_textToType);
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_alloc,pvVar2);
      pvVar2 = _objc_msgSend(cls_NSString,sel_string);
      pvVar1 = _objc_msgSend(pvVar1,sel_initWithString_,pvVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    }
    self = _objc_msgSend(self->_textToTypeView,sel_textStorage,pvVar2);
    op = sel_setAttributedString_;
  }
  _objc_msgSend(self,op,pvVar1);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_tableView setDataSource:self];
    if ([[self availableTextViews] count] == 0) {
        [self mountView:_emptyView];
    } else {
        [self mountView:_mainView];
        [_tableView reloadData];
        id textToType = [[self actionAttributes] textToType];
        if (textToType == nil) {
            textToType = [[[NSAttributedString alloc] initWithString:[NSString string]] autorelease];
        }
        [[_textToTypeView textStorage] setAttributedString:textToType];
    }
}

- (void)mountView:(id)aView
{
    if (_currentView != aView) {
        [_currentView removeFromSuperview];
        [_containerView addSubview:aView];
        _currentView = aView;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e9a14 @ 000e9a14, 351 bytes * /

id FUN_000e9a14(HSAutoTypeActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  
  pvVar1 = self->_availableTextViews;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_card);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036d3d8);
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new);
    self->_availableTextViews = pvVar2;
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildren);
    pvVar2 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar1 = _objc_msgSend(pvVar2,sel_nextObject);
    while (pvVar1 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036d400);
      if ((char)pvVar3 == '\0') {
        puVar4 = &DAT_0036d608;
        pvVar3 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_0036d608);
        if ((char)pvVar3 != '\0') goto LAB_000e9b08;
      }
      else {
LAB_000e9b08:
        pvVar3 = self->_availableTextViews;
        puVar4 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036d770);
        _objc_msgSend(pvVar3,sel_addObject_,puVar4);
      }
      pvVar1 = _objc_msgSend(pvVar2,sel_nextObject,puVar4);
    }
    pvVar1 = self->_availableTextViews;
  }
  return pvVar1;
}

*/
- (id)availableTextViews
{
    if (_availableTextViews == nil) {
        id container = [[self card] queryHyperInterface:@protocol(HSNodeContainer)];
        _availableTextViews = [NSMutableArray new];
        NSEnumerator *enumerator = [[container hyperChildren] objectEnumerator];
        id child;
        while ((child = [enumerator nextObject]) != nil) {
            if ([child implementsHyperInterface:@protocol(HSSystemTextViewAttributes)] || [child implementsHyperInterface:@protocol(HSSystemTextFieldAttributes)]) {
                [_availableTextViews addObject:[child queryHyperInterface:@protocol(HSObjectAttributes)]];
            }
        }
    }
    return _availableTextViews;
    return 0;
}

- (id)actionType
{
    return [HSAutoTypeAction actionType];
}

- (id)actionAttributes
{
    return [[self autoTypeActionAssistantPaneApplier] autoTypeActionAttributes];
}

- (id)autoTypeActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSAutoTypeActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"AutoTypeAssistantPane"];
    return self;
}

@end

@implementation HSAutoTypeActionAssistantPaneApplier

/* i386 ivar offsets: _initialUIDs=0x30, _initialTextToType=0x34, _UIDs=0x38, _textToType=0x3c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ea017 @ 000ea017, 152 bytes * /

BOOL FUN_000ea017(HSAutoTypeActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  bool bVar2;
  HSAutoTypeActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00350750;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if ((char)pvVar1 == '\0') {
LAB_000ea0ab:
    bVar2 = false;
  }
  else {
    if (self->_initialUIDs != (id)0x0 || self->_UIDs != (id)0x0) {
      pvVar1 = _objc_msgSend(self->_initialUIDs,sel_isEqualToArray_,self->_UIDs);
      if ((char)pvVar1 == '\0') goto LAB_000ea0ab;
    }
    if (self->_initialTextToType == (id)0x0 && self->_textToType == (id)0x0) {
      bVar2 = true;
    }
    else {
      pvVar1 = _objc_msgSend(self->_initialTextToType,sel_isEqualToAttributedString_,
                             self->_textToType);
      bVar2 = (char)pvVar1 != '\0';
    }
  }
  return bVar2;
}

*/
- (BOOL)areSettingsEqual
{
    if (![super areSettingsEqual]) {
        return NO;
    }
    if ((_initialUIDs != nil || _UIDs != nil) && ![_initialUIDs isEqualToArray:_UIDs]) {
        return NO;
    }
    if (_initialTextToType == nil && _textToType == nil) {
        return YES;
    }
    return [_initialTextToType isEqualToAttributedString:_textToType];
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_UIDs release];
    [_textToType release];
    _UIDs = [_initialUIDs retain];
    _textToType = [_initialTextToType retain];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialUIDs release];
    [_initialTextToType release];
    _initialUIDs = [_UIDs retain];
    _initialTextToType = [_textToType retain];
}

- (void)setInitialSettingsToObject
{
    [[self autoTypeActionAttributes] setTextViewUIDs:_initialUIDs];
    [[self autoTypeActionAttributes] setTextToType:_initialTextToType];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self autoTypeActionAttributes] setTextViewUIDs:_UIDs];
    [[self autoTypeActionAttributes] setTextToType:_textToType];
}

- (void)setTextToType:(id)aType
{
    if (_textToType != aType) {
        [_textToType release];
        _textToType = [aType retain];
        [self disableUndo];
        [[self autoTypeActionAttributes] setTextToType:_textToType];
        [self enableUndo];
    }
}

- (void)setTextViewUIDs:(id)aDs
{
    if (_UIDs != aDs) {
        [_UIDs release];
        _UIDs = [aDs retain];
        [self disableUndo];
        [[self autoTypeActionAttributes] setTextViewUIDs:_UIDs];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _initialUIDs = [[[self autoTypeActionAttributes] textViewUIDs] retain];
    _UIDs = [[[self autoTypeActionAttributes] textViewUIDs] retain];
    _initialTextToType = [[[self autoTypeActionAttributes] textToType] retain];
    _textToType = [[[self autoTypeActionAttributes] textToType] retain];
}

- (id)autoTypeActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSAutoTypeActionAttributes)];
}

- (void)dealloc
{
    [_initialUIDs release];
    [_UIDs release];
    [_initialTextToType release];
    [_textToType release];
    [super dealloc];
}

@end

