#import "HSSpeechRecognitionActionAssistantPane.h"

@implementation HSSpeechRecognitionActionAssistantPane

/* i386 ivar offsets: _containerView=0x88, _emptyView=0x8c, _mainView=0x90, _tableView=0x94, _scrollOptionsView=0x98, _availableObjects=0x9c, _currentView=0xa0 */

- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id pvVar1_4;
    id pvVar1_6;
    id pvVar2_3;

    if ([self availableObjects] != nil) {
        if ([[aColumn identifier] isEqual:@"HSObjectCheckboxTableIdentifier"]) {
            pvVar1_4 = [self actionAttributes];
            pvVar2_3 = [[[self availableObjects] objectAtIndex:aRow] hyperUID];
            pvVar1_6 = [[pvVar1_4 objectUIDs] mutableCopy];
            if (pvVar1_6 == nil) {
                pvVar1_6 = [NSMutableArray new];
            }
            [pvVar1_6 removeObject:pvVar2_3];
            if ([aValue intValue] != 0) {
                [pvVar1_6 addObject:pvVar2_3];
            }
            [[self speechRecognitionActionAssistantPaneApplier] setObjectUIDs:pvVar1_6];
            [pvVar1_6 release];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011caa5 @ 0011caa5, 647 bytes * /

id FUN_0011caa5(HSSpeechRecognitionActionAssistantPane *self,SEL _cmd,id tableView,
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
  
  pvVar1 = _objc_msgSend(self,sel_availableObjects);
  if (pvVar1 == (id)0x0) {
LAB_0011cacd:
    local_14 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_availableObjects);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID);
    pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
    pcVar6 = &cfstr_HSObjectNameTableIdentifier;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSObjectNameTableIdentifier);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar6);
      pcVar6 = &cfstr_HSObjectTitleTableIdentifier;
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSObjectTitleTableIdentifier);
      if ((char)pvVar2 == '\0') {
        pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar6);
        pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_HSObjectCheckboxTableIdentifier);
        if ((char)pvVar2 == '\0') goto LAB_0011cacd;
        pvVar2 = (id)0x0;
        pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,0);
        pvVar4 = _objc_msgSend(self,sel_actionAttributes);
        pvVar4 = _objc_msgSend(pvVar4,sel_objectUIDs);
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
        pvVar1 = _objc_msgSend(self,sel_availableObjects,pcVar6);
        pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
        puVar7 = &DAT_00371780;
        self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00371780);
        op = sel_title;
      }
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_availableObjects,pcVar6);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
      puVar7 = &DAT_003716cc;
      self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003716cc);
      op = sel_hyperName;
    }
    local_14 = _objc_msgSend(self_00,op,puVar7);
  }
  return local_14;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if ([self availableObjects] == nil) {
        return nil;
    }
    id object = [[self availableObjects] objectAtIndex:aRow];
    id uid = [object hyperUID];
    if ([[aColumn identifier] isEqual:@"HSObjectNameTableIdentifier"]) {
        return [[object queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    }
    if ([[aColumn identifier] isEqual:@"HSObjectTitleTableIdentifier"]) {
        return [[object queryHyperInterface:@protocol(HSSystemButtonAttributes)] title];
    }
    if (![[aColumn identifier] isEqual:@"HSObjectCheckboxTableIdentifier"]) {
        return nil;
    }
    NSEnumerator *enumerator = [[[self actionAttributes] objectUIDs] objectEnumerator];
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
    return (int)[[self availableObjects] count];
}

- (id)initialKeyView
{
    return _tableView;
}

- (id)helpTopicKey
{
    return @"HSSpeechRecognition";
}

- (void)dealloc
{
    if ([_tableView dataSource] == self) {
        [_tableView setDataSource:0];
    }
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [_availableObjects release];
    _availableObjects = nil;
    [_tableView setDataSource:0];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011d258 @ 0011d258, 207 bytes * /

void FUN_0011d258(HSSpeechRecognitionActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  SEL op;
  HSSpeechRecognitionActionAssistantPane *pHVar2;
  HSSpeechRecognitionActionAssistantPane *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSNBAAssistantPane_00351110;
  _objc_msgSendSuper(&local_14,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_availableObjects);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 == (id)0x0) {
    pHVar2 = self->_emptyView;
    op = sel_mountView_;
  }
  else {
    _objc_msgSend(self,sel_mountView_,self->_mainView);
    pHVar2 = self;
    _objc_msgSend(self->_tableView,sel_setDataSource_,self);
    self = self->_tableView;
    op = sel_reloadData;
  }
  _objc_msgSend(self,op,pHVar2);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    if ([[self availableObjects] count] == 0) {
        [self mountView:_emptyView];
    } else {
        [self mountView:_mainView];
        [_tableView setDataSource:self];
        [_tableView reloadData];
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

- (id)availableObjects
{
    id pvVar1;
    id self_00;
    id pvVar3;
    BOOL pvVar2_2;

    pvVar1 = _availableObjects;
    if (pvVar1 == nil) {
        [[self stack] hyperDeepEnumerator];
        self_00 = [NSMutableArray array];
        while (pvVar3 = [pvVar1 nextObject], pvVar3 != nil) {
            [pvVar3 implementsHyperInterface:@protocol(HSActor)];
            if (((pvVar2_2) && (pvVar2_2 = [pvVar3 implementsHyperInterface:@protocol(HSCardAttributes)], !pvVar2_2)) && (pvVar2_2 = [pvVar3 implementsHyperInterface:@protocol(HSStackAttributes)], !pvVar2_2)) {
                pvVar3 = [pvVar3 queryHyperInterface:@protocol(HSObjectAttributes)];
                [self_00 addObject:pvVar3];
            }
        }
        pvVar1 = [self_00 copy];
        _availableObjects = pvVar1;
    }
    return pvVar1;
}

- (id)actionType
{
    return [HSSpeechRecognitionAction actionType];
}

- (id)actionAttributes
{
    return [[self speechRecognitionActionAssistantPaneApplier] speechRecognitionActionAttributes];
}

- (id)speechRecognitionActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSSpeechRecognitionActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"SpeechRecognitionAssistPane"];
    return self;
}

@end

@implementation HSSpeechRecognitionActionAssistantPaneApplier

/* i386 ivar offsets: _initialObjectUIDs=0x30, _objectUIDs=0x34 */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    char cVar2;

    pvVar1 = [super areSettingsEqual];
    cVar2 = pvVar1;
    if ((_initialObjectUIDs != nil) || (_objectUIDs != nil)) {
        if (cVar2 == NO) {
            cVar2 = NO;
        }
        else {
            pvVar1 = [_initialObjectUIDs isEqualToArray:_objectUIDs];
            cVar2 = pvVar1;
        }
    }
    return cVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_objectUIDs release];
    _objectUIDs = [_initialObjectUIDs retain];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialObjectUIDs release];
    _initialObjectUIDs = [_objectUIDs retain];
}

- (void)setInitialSettingsToObject
{
    [[self speechRecognitionActionAttributes] setObjectUIDs:_initialObjectUIDs];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self speechRecognitionActionAttributes] setObjectUIDs:_objectUIDs];
}

- (void)setObjectUIDs:(id)aDs
{
    if (_objectUIDs != aDs) {
        [_objectUIDs release];
        _objectUIDs = [aDs retain];
        [self disableUndo];
        [[self speechRecognitionActionAttributes] setObjectUIDs:_objectUIDs];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _objectUIDs = [[[self speechRecognitionActionAttributes] objectUIDs] retain];
    _initialObjectUIDs = [[[self speechRecognitionActionAttributes] objectUIDs] retain];
}

- (id)speechRecognitionActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSSpeechRecognitionActionAttributes)];
}

- (void)dealloc
{
    [_initialObjectUIDs release];
    [_objectUIDs release];
    [super dealloc];
}

@end

