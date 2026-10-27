#import "HSCardShufflerActionAssistantPane.h"

@implementation HSCardShufflerActionAssistantPane

/* i386 ivar offsets: _startingCardPopUp=0x88, _endingCardPopUp=0x8c, _clearChangesCheckBox=0x90, _shouldUpdatePopUpLists=0x94 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028301a @ 0028301a, 353 bytes * /

id FUN_0028301a(HSCardShufflerActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id self_01;
  id pvVar3;
  id pvVar4;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperCount);
  if (pvVar2 != (id)0x0) {
    pvVar4 = (id)0x0;
    do {
      self_01 = _objc_msgSend(cls_NSMenuItem,sel_new);
      pvVar1 = (id)((int)pvVar4 + 1);
      pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_Card__u,pvVar1);
      _objc_msgSend(self_01,sel_setTitle_,pvVar3);
      pvVar3 = _objc_msgSend(cls_NSNumber,sel_alloc);
      pvVar4 = _objc_msgSend(pvVar3,sel_initWithUnsignedInteger_,pvVar4);
      _objc_msgSend(self_01,sel_setRepresentedObject_,pvVar4);
      _objc_msgSend(self_00,sel_addObject_,self_01);
      _objc_msgSend(self_01,sel_release);
      _objc_msgSend(pvVar4,sel_release);
      pvVar4 = pvVar1;
    } while (pvVar1 < pvVar2);
  }
  return self_00;
}

*/
- (id)cardTitles
{
    NSMutableArray *titles = [NSMutableArray array];
    NSUInteger count = [[self stack] hyperCount];
    for (NSUInteger index = 0; index < count; index++) {
        NSMenuItem *item = [NSMenuItem new];
        [item setTitle:[NSString stringWithFormat:@"Card %u", (unsigned int)(index + 1)]];
        NSNumber *number = [[NSNumber alloc] initWithUnsignedInteger:index];
        [item setRepresentedObject:number];
        [titles addObject:item];
        [item release];
        [number release];
    }
    return titles;
    return 0;
}

- (void)clearChangesChanged:(id)aChanged
{
    [[self cardShufflerActionAsssistantApplier] setShouldClearChanges:(unsigned int)([_clearChangesCheckBox state] == 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00282e54 @ 00282e54, 353 bytes * /

void FUN_00282e54(HSCardShufflerActionAssistantPane *self,SEL _cmd,id updateRelatedPopUpButton,
                 id selectedMenuItem)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id self_01;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  
  pvVar1 = _objc_msgSend(self,sel_cardTitles);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  pvVar5 = (id)0x0;
  self_00 = _objc_msgSend(updateRelatedPopUpButton,sel_menu);
  do {
    if (pvVar2 <= pvVar5) {
LAB_00282f6a:
      pvVar1 = _objc_msgSend(selectedMenuItem,sel_representedObject);
      pvVar1 = _objc_msgSend(pvVar1,sel_unsignedIntegerValue);
      _objc_msgSend(self_00,sel_removeItemAtIndex_,pvVar1);
      return;
    }
    self_01 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar5);
    if ((id)((int)pvVar2 + -1) == pvVar5) {
      _objc_msgSend(self_00,sel_addItem_,self_01);
    }
    else {
      pvVar3 = _objc_msgSend(self_00,sel_itemAtIndex_,pvVar5);
      pvVar3 = _objc_msgSend(pvVar3,sel_representedObject);
      pvVar4 = _objc_msgSend(self_01,sel_representedObject);
      if (pvVar3 != pvVar4) {
        _objc_msgSend(self_00,sel_insertItem_atIndex_,self_01,pvVar5);
        goto LAB_00282f6a;
      }
    }
    pvVar5 = (id)((int)pvVar5 + 1);
  } while( true );
}

*/
- (void)chooseEndingCard:(id)aCard
{
    [[self cardShufflerActionAsssistantApplier] setEndingCardIndex:[[[_endingCardPopUp selectedItem] representedObject] unsignedIntegerValue]];
}

- (void)chooseStartingCard:(id)aCard
{
    [[self cardShufflerActionAsssistantApplier] setStartingCardIndex:[[[_startingCardPopUp selectedItem] representedObject] unsignedIntegerValue]];
}

- (void)updatePopUpLists
{
    id pvVar1;
    id pvVar2;
    NSUInteger pvVar3;
    NSUInteger pvVar4;
    id self_00;
    id pvVar5;
    NSMenu *self_01;
    NSUInteger pvVar7;
    id pvVar1_2;
    id pvVar1_3;
    NSUInteger pvVar2_2;

    pvVar1 = [self cardTitles];
    pvVar2 = [self actionAttributes];
    pvVar3 = [pvVar2 startingCardIndex];
    pvVar2_2 = [pvVar2 endingCardIndex];
    [_startingCardPopUp removeAllItems];
    [_endingCardPopUp removeAllItems];
    pvVar4 = [pvVar1 count];
    if (pvVar4 != 0) {
        if (pvVar4 == 0x1) {
            pvVar1_2 = [pvVar1 objectAtIndex:0];
            [[_startingCardPopUp menu] addItem:pvVar1_2];
            pvVar1_3 = [pvVar1_2 copy];
            [[_endingCardPopUp menu] addItem:pvVar1_3];
            [pvVar1_3 release];
        }
        else {
            pvVar7 = 0;
            do {
                self_00 = [NSAutoreleasePool new];
                pvVar5 = [pvVar1 objectAtIndex:pvVar7];
                if (pvVar2_2 != pvVar7) {
                    self_01 = [_startingCardPopUp menu];
                    [self_01 addItem:pvVar5];
                    pvVar5 = [[pvVar5 copy] autorelease];
                }
                if (pvVar3 != pvVar7) {
                    [[_endingCardPopUp menu] addItem:pvVar5];
                }
                [self_00 release];
                pvVar7 = (pvVar7 + 1);
            } while (pvVar7 < pvVar4);
        }
    }
    _shouldUpdatePopUpLists = NO;
}

- (void)validateUserInterface
{
    id pvVar1;
    id pvVar3;
    id pvVar1_2;

    if (_shouldUpdatePopUpLists != NO) {
        [self updatePopUpLists];
    }
    pvVar3 = [self actionAttributes];
    pvVar1 = _startingCardPopUp;
    [pvVar1 selectItemAtIndex:[pvVar1 indexOfItemWithRepresentedObject:[NSNumber numberWithUnsignedInteger:[pvVar3 startingCardIndex]]]];
    pvVar1_2 = _endingCardPopUp;
    [pvVar1_2 selectItemAtIndex:[pvVar1_2 indexOfItemWithRepresentedObject:[NSNumber numberWithUnsignedInteger:[pvVar3 endingCardIndex]]]];
    [_clearChangesCheckBox setState:(unsigned int)([pvVar3 shouldClearChanges])];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUserInterface];
}

- (id)helpTopicKey
{
    return @"HSCardShufflerAction";
}

- (void)stackChanged:(id)aChanged
{
    _shouldUpdatePopUpLists = YES;
    [self validateUserInterface];
}

- (void)removeActionAssistantPaneObserver
{
    [super removeActionAssistantPaneObserver];
    [[[self stack] attributeObservingController] removeObserver:self selector:@selector(stackChanged:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
}

- (void)addActionAssistantPaneObserver
{
    [super addActionAssistantPaneObserver];
    [[[self stack] attributeObservingController] addObserver:self selector:@selector(stackChanged:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    id pvVar1;
    NSUInteger pvVar2;

    [super viewWillAppear:((int)aAppear)];
    pvVar1 = [self actionAttributes];
    pvVar2 = [pvVar1 startingCardIndex];
    if ([pvVar1 endingCardIndex] == 0 && pvVar2 == 0) {
        [[self cardShufflerActionAsssistantApplier] setEndingCardIndex:((int)[[self stack] hyperCount] + -1)];
    }
    _shouldUpdatePopUpLists = YES;
    [self validateUserInterface];
    [self addActionAssistantPaneObserver];
}

- (id)actionAttribute
{
    return (id)@protocol(HSCardShufflerActionAttributes);
}

- (id)actionAttributes
{
    return [[self cardShufflerActionAsssistantApplier] cardShufflerActionAttributes];
}

- (id)actionType
{
    return [HSCardShufflerAction actionType];
}

- (id)cardShufflerActionAsssistantApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSCardShufflerActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"CardShufflerActionAssistantPane"];
    return self;
}

@end

@implementation HSCardShufflerActionAssistantPaneApplier

/* i386 ivar offsets: _actionAttributes=0x30, _initialStartingCardIndex=0x34, _initialEndingCardIndex=0x38, _initialShouldClearChanges=0x3c, _startingCardIndex=0x40, _endingCardIndex=0x44, _shouldClearChanges=0x48 */

- (void)setShouldClearChanges:(BOOL)aChanges
{
    if (((_shouldClearChanges != NO) && (aChanges == NO)) || ((_shouldClearChanges == NO && (aChanges != NO)))) {
        _shouldClearChanges = aChanges;
        [self disableUndo];
        [[self cardShufflerActionAttributes] setShouldClearChanges:_shouldClearChanges];
        [self enableUndo];
    }
}

- (void)setEndingCardIndex:(NSUInteger)aIndex
{
    if (_endingCardIndex != aIndex) {
        _endingCardIndex = aIndex;
        [self disableUndo];
        [[self cardShufflerActionAttributes] setEndingCardIndex:_endingCardIndex];
        [self enableUndo];
    }
}

- (void)setStartingCardIndex:(NSUInteger)aIndex
{
    if (_startingCardIndex != aIndex) {
        _startingCardIndex = aIndex;
        [self disableUndo];
        [[self cardShufflerActionAttributes] setStartingCardIndex:_startingCardIndex];
        [self enableUndo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002831c9 @ 002831c9, 113 bytes * /

BOOL FUN_002831c9(HSCardShufflerActionAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  bool bVar2;
  HSCardShufflerActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00356600;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if ((((char)pvVar1 == '\0') || (self->_initialStartingCardIndex != self->_startingCardIndex)) ||
     (self->_initialEndingCardIndex != self->_endingCardIndex)) {
LAB_0028322b:
    bVar2 = false;
  }
  else {
    if (self->_initialShouldClearChanges != '\0') {
      if (self->_shouldClearChanges != '\0') {
        return '\x01';
      }
      if (self->_initialShouldClearChanges != '\0') goto LAB_0028322b;
    }
    bVar2 = self->_shouldClearChanges == '\0';
  }
  return bVar2;
}

*/
- (BOOL)areSettingsEqual
{
    if (![super areSettingsEqual] || _initialStartingCardIndex != _startingCardIndex || _initialEndingCardIndex != _endingCardIndex) {
        return NO;
    }
    if (_initialShouldClearChanges) {
        if (_shouldClearChanges) {
            return YES;
        }
        return NO;
    }
    return !_shouldClearChanges;
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    _startingCardIndex = _initialStartingCardIndex;
    _endingCardIndex = _initialEndingCardIndex;
    _shouldClearChanges = _initialShouldClearChanges;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialStartingCardIndex = _startingCardIndex;
    _initialEndingCardIndex = _endingCardIndex;
    _initialShouldClearChanges = _shouldClearChanges;
}

- (void)setInitialSettingsToObject
{
    id self_00;

    self_00 = [self cardShufflerActionAttributes];
    [self_00 setStartingCardIndex:_initialStartingCardIndex];
    [self_00 setEndingCardIndex:_initialEndingCardIndex];
    [self_00 setShouldClearChanges:_initialShouldClearChanges];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    id self_00;

    [super setCurrentSettingsToObject];
    self_00 = [self cardShufflerActionAttributes];
    [self_00 setStartingCardIndex:_startingCardIndex];
    [self_00 setEndingCardIndex:_endingCardIndex];
    [self_00 setShouldClearChanges:_shouldClearChanges];
}

- (void)setUpInitialSettings
{
    id pvVar1;
    NSUInteger pvVar2;
    BOOL pvVar1_2;
    NSUInteger pvVar2_2;

    pvVar1 = [self cardShufflerActionAttributes];
    pvVar2 = [pvVar1 startingCardIndex];
    _initialStartingCardIndex = (unsigned int)pvVar2;
    _startingCardIndex = (unsigned int)pvVar2;
    pvVar2_2 = [pvVar1 endingCardIndex];
    _initialEndingCardIndex = (unsigned int)pvVar2_2;
    _endingCardIndex = (unsigned int)pvVar2_2;
    pvVar1_2 = [pvVar1 shouldClearChanges];
    _initialShouldClearChanges = (BOOL)pvVar1_2;
    _shouldClearChanges = (BOOL)pvVar1_2;
}

- (id)cardShufflerActionAttributes
{
    id pvVar1;

    pvVar1 = _actionAttributes;
    if (pvVar1 == nil) {
        pvVar1 = [[[self actionAttributes] queryHyperInterface:@protocol(HSCardShufflerActionAttributes)] retain];
        _actionAttributes = pvVar1;
    }
    return pvVar1;
}

- (void)dealloc
{
    [_actionAttributes release];
    [super dealloc];
}

@end

