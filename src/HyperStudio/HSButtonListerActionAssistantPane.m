#import "HSButtonListerActionAssistantPane.h"

@implementation HSButtonListerActionAssistantPane

/* i386 ivar offsets: _buttonsTableView=0x88, _addButtonPopUpButton=0x8c, _removeSelectedButtonButton=0x90, _moveSelectedButtonUpButton=0x94, _moveSelectedButtonDownButton=0x98, _performDelayTextField=0x9c, _performDelayStepper=0xa0, _shouldRepeatCheckBox=0xa4, _audioCueTypeMatrix=0xa8, _chooseAudioMediaButton=0xac, _audioMediaNameTextField=0xb0, _audioMediaNameBox=0xb4, _playButtonCell=0xb8, _previewSoundObject=0xbc, _importSoundObjectDialogController=0xc0, _availableButtonObjects=0xc4, _stack=0xc8 */

+ (id)stopButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"S" tint:@"G"];
}

+ (id)stopButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"S" tint:@"A"];
}

+ (id)stopButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"N" size:@"S" tint:@"A"];
}

+ (id)playButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"S" tint:@"G"];
}

+ (id)playButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"S" tint:@"A"];
}

+ (id)playButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"N" size:@"S" tint:@"A"];
}

- (void)availableCardObjectsDidChange:(id)aChange
{
    [self invalidateAvailableButtonObjects];
    [self validateUIWithNotification:aChange];
}

- (void)setStack:(id)aStack
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_stack != aStack) {
        pvVar2 = [_stack queryHyperInterface:@protocol(HSNodeContainer)];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(availableCardObjectsDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
        [self invalidateAvailableButtonObjects];
        [_stack release];
        pvVar2_2 = [aStack retain];
        _stack = pvVar2_2;
        [[pvVar2_2 queryHyperInterface:@protocol(HSNodeContainer)] addObserver:self selector:@selector(availableCardObjectsDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    }
}

- (id)stack
{
    id pvVar1;

    pvVar1 = _stack;
    if (pvVar1 == nil) {
        pvVar1 = [super stack];
        [self setStack:pvVar1];
        pvVar1 = _stack;
    }
    return pvVar1;
}

- (BOOL)tableView:(id)aView acceptDrop:(id)aDrop row:(NSInteger)aRow dropOperation:(NSUInteger)aOperation
{
    id pvVar3;
    int iVar4;
    NSUInteger pvVar1_4;
    id pvVar2_3;

    pvVar1_4 = [[NSKeyedUnarchiver unarchiveObjectWithData:[[aDrop draggingPasteboard] dataForType:@"HSButtonListerActionTableViewDataType"]] firstIndex];
    pvVar2_3 = [NSMutableArray arrayWithArray:[[self actionAttributes] buttonUIDs]];
    pvVar3 = [pvVar2_3 objectAtIndex:pvVar1_4];
    iVar4 = aRow + -1;
    if (aRow <= (int)pvVar1_4) {
        iVar4 = aRow;
    }
    [pvVar2_3 removeObjectAtIndex:pvVar1_4];
    [pvVar2_3 insertObject:pvVar3 atIndex:iVar4];
    [[self buttonListerActionAssistantPaneApplier] setButtonUIDs:[[pvVar2_3 copy] autorelease]];
    [_buttonsTableView reloadData];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002500ad @ 002500ad, 180 bytes * /

uint FUN_002500ad(HSButtonListerActionAssistantPane *self,SEL _cmd,id tableView,id validateDrop,
                 int proposedRow,uint proposedDropOperation)

{
  id pvVar1;
  
  if ((proposedDropOperation == 1) &&
     (pvVar1 = _objc_msgSend(validateDrop,sel_draggingSource), pvVar1 == self->_buttonsTableView)) {
    pvVar1 = _objc_msgSend(validateDrop,sel_draggingPasteboard);
    pvVar1 = _objc_msgSend(pvVar1,sel_dataForType_,&cfstr_HSButtonListerActionTableViewDataType);
    pvVar1 = _objc_msgSend(cls_NSKeyedUnarchiver,sel_unarchiveObjectWithData_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_firstIndex);
    if (pvVar1 != (id)proposedRow) {
      return (uint)((int)pvVar1 + 1 != proposedRow) << 4;
    }
  }
  return 0;
}

*/
- (NSUInteger)tableView:(id)aView validateDrop:(id)aDrop proposedRow:(NSInteger)aRow proposedDropOperation:(NSUInteger)aOperation
{
    if (aOperation == NSTableViewDropAbove && [aDrop draggingSource] == _buttonsTableView) {
        NSData *data = [[aDrop draggingPasteboard] dataForType:@"HSButtonListerActionTableViewDataType"];
        NSUInteger index = [[NSKeyedUnarchiver unarchiveObjectWithData:data] firstIndex];
        if (index != (NSUInteger)aRow) {
            return (index + 1 != (NSUInteger)aRow) ? NSDragOperationMove : NSDragOperationNone;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(id)aView writeRowsWithIndexes:(id)aIndexes toPasteboard:(id)aPasteboard
{
    NSData *pvVar1;

    pvVar1 = [NSKeyedArchiver archivedDataWithRootObject:aIndexes];
    [aPasteboard declareTypes:[NSArray arrayWithObject:@"HSButtonListerActionTableViewDataType"] owner:self];
    [aPasteboard setData:pvVar1 forType:@"HSButtonListerActionTableViewDataType"];
    return YES;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id pvVar1_7;
    id pvVar2_4;

    if ([[aColumn identifier] isEqualToString:@"HSButtonListerTitleIdentifier"]) {
        pvVar1_7 = [[[[[aColumn dataCell] menu] itemAtIndex:[aValue intValue]] representedObject] queryHyperInterface:@protocol(HSObjectAttributes)];
        pvVar2_4 = [[[self actionAttributes] buttonUIDs] mutableCopy];
        [pvVar2_4 replaceObjectAtIndex:aRow withObject:[pvVar1_7 hyperUID]];
        [[self buttonListerActionAssistantPaneApplier] setButtonUIDs:pvVar2_4];
        [pvVar2_4 release];
        [self validateUserInterface];
    }
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024fcf9 @ 0024fcf9, 394 bytes * /

id FUN_0024fcf9(HSButtonListerActionAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  pcVar3 = &cfstr_HSButtonListerIndexIdentifier;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_HSButtonListerIndexIdentifier);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar3);
    pcVar3 = &cfstr_HSButtonListerTitleIdentifier;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_HSButtonListerTitleIdentifier);
    if ((char)pvVar1 == '\0') {
      return (id)0x0;
    }
    pvVar1 = _objc_msgSend(self,sel_actionAttributes,pcVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_buttonUIDs);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
    pvVar2 = _objc_msgSend(self,sel_stack);
    pvVar1 = _objc_msgSend(pvVar2,sel_childInTreeWithUID_,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00385618);
    pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_dataCell);
    self_00 = cls_NSNumber;
    pvVar2 = _objc_msgSend(pvVar2,sel_menu);
    pvVar1 = _objc_msgSend(pvVar2,sel_indexOfItemWithRepresentedObject_,pvVar1);
  }
  else {
    pvVar1 = (id)(row + 1);
    self_00 = cls_NSNumber;
  }
  pvVar1 = _objc_msgSend(self_00,sel_numberWithInt_,pvVar1);
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    if ([[aColumn identifier] isEqualToString:@"HSButtonListerIndexIdentifier"]) {
        return [NSNumber numberWithInt:(int)aRow + 1];
    }
    if (![[aColumn identifier] isEqualToString:@"HSButtonListerTitleIdentifier"]) {
        return nil;
    }
    id uid = [[[self actionAttributes] buttonUIDs] objectAtIndex:aRow];
    id button = [[[self stack] childInTreeWithUID:uid] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
    return [NSNumber numberWithInt:(int)[[[aColumn dataCell] menu] indexOfItemWithRepresentedObject:button]];
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[[[self actionAttributes] buttonUIDs] count];
}

- (void)tableViewSelectionDidChange:(id)aChange
{
    [self validateButtonsOrginizingControls];
}

- (void)menuNeedsUpdate:(id)aUpdate
{
    if ([_addButtonPopUpButton menu] == aUpdate) {
        if ([self areAvailableButtonObjectsInvalidated]) {
            [self updateAddButtonPopUpButtonMenu];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024fb97 @ 0024fb97, 147 bytes * /

void FUN_0024fb97(HSButtonListerActionAssistantPane *self,SEL _cmd,id playAudioMedia)

{
  id pvVar1;
  HSButtonListerActionAssistantPane *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  self_00 = self;
  op = sel_stopPlaying;
  if ((char)pvVar1 == '\0') {
    self_00 = _objc_msgSend(cls_HSMediaPlaySynchronizer,sel_sharedSynchronizer);
    _objc_msgSend(self,sel_previewSoundObject);
    op = sel_playMediaSingle_;
  }
  _objc_msgSend(self_00,op);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)playAudioMedia:(id)aMedia
{
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    else {
        [[HSMediaPlaySynchronizer sharedSynchronizer] playMediaSingle:[self previewSoundObject]];
    }
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024fa1b @ 0024fa1b, 380 bytes * /

void FUN_0024fa1b(HSButtonListerActionAssistantPane *self,SEL _cmd,id chooseMedia)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_importSoundObjectDialogController);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_document);
  _objc_msgSend(pvVar1,sel_setHyperDocument_,pvVar2);
  self_00 = cls_HSImportDialogController;
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(self_00,sel_defaultButtonTitleForObject_,pvVar2);
  _objc_msgSend(pvVar1,sel_setDefaultButtonTitle_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar1,sel_runModal);
  if (pvVar3 == (id)0x1) {
    pvVar3 = _objc_msgSend(pvVar1,sel_fileName,pvVar2);
    if (pvVar3 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_fileName,pvVar2);
      pvVar2 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPath_,pvVar1);
      if (pvVar2 != (id)0x0) {
        pvVar1 = _objc_msgSend(self,sel_buttonListerActionAssistantPaneApplier,pvVar1);
        _objc_msgSend(pvVar1,sel_setAudioMedia_,pvVar2);
        _objc_msgSend(self,sel_invalidatePreviewSoundObject);
        _objc_msgSend(self,sel_validateUserInterface);
      }
    }
  }
  return;
}

*/
- (void)chooseMedia:(id)aMedia
{
    HSImportDialogController *controller = [self importSoundObjectDialogController];
    [controller setHyperDocument:[[self stack] document]];
    [controller setDefaultButtonTitle:[HSImportDialogController defaultButtonTitleForObject:[[self assistant] object]]];
    if ([controller runModal] != 1 || [controller fileName] == nil) {
        return;
    }
    id media = [HSNewMedia mediaWithPath:[controller fileName]];
    if (media != nil) {
        [[self buttonListerActionAssistantPaneApplier] setAudioMedia:media];
        [self invalidatePreviewSoundObject];
        [self validateUserInterface];
    }
}

- (void)audioCueTypeChanged:(id)aChanged
{
    [[self buttonListerActionAssistantPaneApplier] setAudioCueType:[aChanged selectedTag]];
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    [self validateUserInterface];
}

- (void)shouldRepeatChanged:(id)aChanged
{
    [[self buttonListerActionAssistantPaneApplier] setShouldRepeat:(unsigned int)([aChanged state] == 0x1)];
    [self validateUserInterface];
}

- (void)performDelayChanged:(id)aChanged
{
    [[self buttonListerActionAssistantPaneApplier] setPerformDelay:(float)[aChanged floatValue]];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024f6db @ 0024f6db, 569 bytes * /

void FUN_0024f6db(HSButtonListerActionAssistantPane *self,SEL _cmd,id moveSelectedButtonDown)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  id pvVar3;
  id pvVar4;
  SEL op;
  
  self_00 = cls_NSMutableArray;
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_buttonUIDs);
  pvVar2 = _objc_msgSend(self_00,sel_arrayWithArray_,pvVar1);
  self_01 = _objc_msgSend(self->_buttonsTableView,sel_selectedRowIndexes);
  op = sel_lastIndex;
  while( true ) {
    pvVar3 = _objc_msgSend(self_01,op,pvVar1);
    if (pvVar3 == (id)0x7fffffff) break;
    pvVar1 = self->_buttonsTableView;
    pvVar4 = _objc_msgSend(self,sel_numberOfRowsInTableView_,pvVar1);
    if ((id)((int)pvVar4 + -1) <= pvVar3) break;
    _objc_msgSend(pvVar2,sel_exchangeObjectAtIndex_withObjectAtIndex_,pvVar3,(int)pvVar3 + 1);
    op = sel_indexLessThanIndex_;
    pvVar1 = pvVar3;
  }
  pvVar1 = _objc_msgSend(self,sel_buttonListerActionAssistantPaneApplier,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_copy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  _objc_msgSend(pvVar1,sel_setButtonUIDs_,pvVar2);
  _objc_msgSend(self->_buttonsTableView,sel_reloadData);
  pvVar1 = _objc_msgSend(self_01,sel_firstIndex);
  if (pvVar1 != (id)0x7fffffff) {
    pvVar3 = _objc_msgSend(self_01,sel_mutableCopy,pvVar2);
    pvVar1 = _objc_msgSend(self_01,sel_firstIndex);
    _objc_msgSend(pvVar3,sel_shiftIndexesStartingAtIndex_by_,pvVar1,1);
    _objc_msgSend(self->_buttonsTableView,sel_selectRowIndexes_byExtendingSelection_,pvVar3,0);
    pvVar1 = self->_buttonsTableView;
    pvVar2 = _objc_msgSend(pvVar3,sel_lastIndex);
    _objc_msgSend(pvVar1,sel_scrollRowToVisible_,pvVar2);
    _objc_msgSend(pvVar3,sel_release);
  }
  _objc_msgSend(self,sel_validateUserInterface,pvVar2);
  return;
}

*/
- (void)moveSelectedButtonDown:(id)aDown
{
    NSMutableArray *uids = [NSMutableArray arrayWithArray:[[self actionAttributes] buttonUIDs]];
    NSIndexSet *selection = [_buttonsTableView selectedRowIndexes];
    NSUInteger index = [selection lastIndex];
    while (index != NSNotFound && index < (NSUInteger)([self numberOfRowsInTableView:_buttonsTableView] - 1)) {
        [uids exchangeObjectAtIndex:index withObjectAtIndex:index + 1];
        index = [selection indexLessThanIndex:index];
    }
    [[self buttonListerActionAssistantPaneApplier] setButtonUIDs:[[uids copy] autorelease]];
    [_buttonsTableView reloadData];
    if ([selection firstIndex] != NSNotFound) {
        NSMutableIndexSet *moved = [selection mutableCopy];
        [moved shiftIndexesStartingAtIndex:[selection firstIndex] by:1];
        [_buttonsTableView selectRowIndexes:moved byExtendingSelection:NO];
        [_buttonsTableView scrollRowToVisible:[moved lastIndex]];
        [moved release];
    }
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024f4c2 @ 0024f4c2, 537 bytes * /

void FUN_0024f4c2(HSButtonListerActionAssistantPane *self,SEL _cmd,id moveSelectedButtonUp)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id self_01;
  id pvVar3;
  SEL op;
  
  self_00 = cls_NSMutableArray;
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_buttonUIDs);
  pvVar2 = _objc_msgSend(self_00,sel_arrayWithArray_,pvVar1);
  self_01 = _objc_msgSend(self->_buttonsTableView,sel_selectedRowIndexes);
  op = sel_firstIndex;
  while( true ) {
    pvVar3 = _objc_msgSend(self_01,op,pvVar1);
    if ((pvVar3 == (id)0x0) || (pvVar3 == (id)0x7fffffff)) break;
    _objc_msgSend(pvVar2,sel_exchangeObjectAtIndex_withObjectAtIndex_,pvVar3,(int)pvVar3 + -1);
    op = sel_indexGreaterThanIndex_;
    pvVar1 = pvVar3;
  }
  pvVar1 = _objc_msgSend(self,sel_buttonListerActionAssistantPaneApplier,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_copy);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  _objc_msgSend(pvVar1,sel_setButtonUIDs_,pvVar2);
  _objc_msgSend(self->_buttonsTableView,sel_reloadData);
  pvVar1 = _objc_msgSend(self_01,sel_firstIndex);
  if (pvVar1 != (id)0x7fffffff) {
    pvVar3 = _objc_msgSend(self_01,sel_mutableCopy,pvVar2);
    pvVar1 = _objc_msgSend(self_01,sel_firstIndex);
    _objc_msgSend(pvVar3,sel_shiftIndexesStartingAtIndex_by_,pvVar1,0xffffffff);
    _objc_msgSend(self->_buttonsTableView,sel_selectRowIndexes_byExtendingSelection_,pvVar3,0);
    pvVar1 = self->_buttonsTableView;
    pvVar2 = _objc_msgSend(pvVar3,sel_firstIndex);
    _objc_msgSend(pvVar1,sel_scrollRowToVisible_,pvVar2);
    _objc_msgSend(pvVar3,sel_release);
  }
  _objc_msgSend(self,sel_validateUserInterface,pvVar2);
  return;
}

*/
- (void)moveSelectedButtonUp:(id)aUp
{
    NSMutableArray *uids = [NSMutableArray arrayWithArray:[[self actionAttributes] buttonUIDs]];
    NSIndexSet *selection = [_buttonsTableView selectedRowIndexes];
    NSUInteger index = [selection firstIndex];
    while (index != 0 && index != NSNotFound) {
        [uids exchangeObjectAtIndex:index withObjectAtIndex:index - 1];
        index = [selection indexGreaterThanIndex:index];
    }
    [[self buttonListerActionAssistantPaneApplier] setButtonUIDs:[[uids copy] autorelease]];
    [_buttonsTableView reloadData];
    if ([selection firstIndex] != NSNotFound) {
        NSMutableIndexSet *moved = [selection mutableCopy];
        [moved shiftIndexesStartingAtIndex:[selection firstIndex] by:-1];
        [_buttonsTableView selectRowIndexes:moved byExtendingSelection:NO];
        [_buttonsTableView scrollRowToVisible:[moved firstIndex]];
        [moved release];
    }
    [self validateUserInterface];
}

- (void)removeSelectedButton:(id)aButton
{
    NSIndexSet *pvVar1;
    id self_01;

    pvVar1 = [_buttonsTableView selectedRowIndexes];
    self_01 = [NSMutableArray arrayWithArray:[[self actionAttributes] buttonUIDs]];
    if ([pvVar1 lastIndex] != NSNotFound) {
        if ([pvVar1 lastIndex] < [self_01 count]) {
            [self_01 removeObjectsAtIndexes:pvVar1];
        }
    }
    [[self buttonListerActionAssistantPaneApplier] setButtonUIDs:[[self_01 copy] autorelease]];
    [_buttonsTableView noteNumberOfRowsChanged];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024f21a @ 0024f21a, 333 bytes * /

void FUN_0024f21a(HSButtonListerActionAssistantPane *self,SEL _cmd,id addButton)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  undefined *self_00;
  SEL op;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(addButton,sel_representedObject);
  puVar4 = &DAT_00385938;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00385938);
  pvVar2 = _objc_msgSend(self,sel_actionAttributes);
  puVar3 = _objc_msgSend(pvVar2,sel_buttonUIDs);
  self_00 = cls_NSArray;
  if (puVar3 == (undefined *)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID,puVar4);
    op = sel_arrayWithObject_;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID,puVar4);
    self_00 = puVar3;
    op = sel_arrayByAddingObject_;
  }
  pvVar1 = _objc_msgSend(self_00,op,pvVar1);
  pvVar2 = _objc_msgSend(self,sel_buttonListerActionAssistantPaneApplier);
  _objc_msgSend(pvVar2,sel_setButtonUIDs_,pvVar1);
  _objc_msgSend(self->_buttonsTableView,sel_noteNumberOfRowsChanged);
  pvVar1 = self->_buttonsTableView;
  pvVar2 = _objc_msgSend(pvVar1,sel_numberOfRows);
  _objc_msgSend(pvVar1,sel_scrollRowToVisible_,(int)pvVar2 + -1);
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)addButton:(id)aButton
{
    id object = [[aButton representedObject] queryHyperInterface:@protocol(HSObjectAttributes)];
    NSArray *uids = [[self actionAttributes] buttonUIDs];
    if (uids == nil) {
        uids = [NSArray arrayWithObject:[object hyperUID]];
    }
    else {
        uids = [uids arrayByAddingObject:[object hyperUID]];
    }
    [[self buttonListerActionAssistantPaneApplier] setButtonUIDs:uids];
    [_buttonsTableView noteNumberOfRowsChanged];
    [_buttonsTableView scrollRowToVisible:[_buttonsTableView numberOfRows] - 1];
    [self validateUserInterface];
}

- (void)movieDidStop:(id)aStop
{
    [self movieDidEnd:aStop];
}

- (void)movieDidPlayOnce:(id)aOnce
{

}

- (void)movieDidChangeImage:(id)aImage
{

}

- (void)movieDidEnd:(id)aEnd
{
    [aEnd gotoBeginning];
    [self validateUserInterface];
}

- (id)actionAttributesAudioMediaFileURL
{
    id pvVar1_3;
    NSURL *pvVar1_4;

    pvVar1_3 = [[[self actionAttributes] audioMedia] fullPathToMediaFileCreateIfNeeded:YES];
    if (pvVar1_3 == nil) {
        pvVar1_4 = nil;
    }
    else {
        pvVar1_4 = [NSURL fileURLWithPath:pvVar1_3];
    }
    return pvVar1_4;
}

- (void)invalidatePreviewSoundObject
{
    if ([_previewSoundObject isPlaying]) {
        [_previewSoundObject stop];
    }
    if ([_previewSoundObject delegate] == self) {
        [_previewSoundObject setDelegate:0];
    }
    [_previewSoundObject release];
    _previewSoundObject = nil;
}

- (id)previewSoundObject
{
    id pvVar1;
    id pvVar1_2;

    if (_previewSoundObject == nil) {
        pvVar1 = [self actionAttributesAudioMediaFileURL];
        if (pvVar1 != nil) {
            pvVar1_2 = [[HSMovie alloc] initWithURL:pvVar1 error:0];
            _previewSoundObject = pvVar1_2;
            [pvVar1_2 setDelegate:self];
        }
    }
    return _previewSoundObject;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024ef9d @ 0024ef9d, 94 bytes * /

id FUN_0024ef9d(HSButtonListerActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_importSoundObjectDialogController;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSImportDialogController,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithDialogType_,*(undefined4 *)PTR_PTR_003360dc);
    self->_importSoundObjectDialogController = pvVar1;
  }
  return pvVar1;
}

*/
- (id)importSoundObjectDialogController
{
    if (_importSoundObjectDialogController == nil) {
        _importSoundObjectDialogController = [[HSImportDialogController alloc] initWithDialogType:HSImportDialogControllerTypeSound];
    }
    return _importSoundObjectDialogController;
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUserInterface];
}

- (void)stopPlaying
{
    [_previewSoundObject stop];
    [_previewSoundObject gotoBeginning];
}

- (BOOL)isPlaying
{
    return (BOOL)[_previewSoundObject isPlaying];
}

- (void)validateUserInterface
{
    id pvVar1;
    BOOL uVar5;
    id pcVar6;
    id pvVar1_5;
    NSBundle *pvVar1_6;
    BOOL pvVar1_9;
    id pvVar1_12;
    NSInteger pvVar2_5;
    id pvVar2_6;
    id pvVar2_8;
    id pvVar3_2;
    Class pvVar3_5;

    [self updateButtonsPopUpButtonCellMenu];
    [self updateAddButtonPopUpButtonMenu];
    [self validateButtonsOrginizingControls];
    pvVar1 = [self actionAttributes];
    [_performDelayTextField setFloatValue:(float)[pvVar1 performDelay]];
    [_performDelayStepper setFloatValue:(float)[pvVar1 performDelay]];
    [_shouldRepeatCheckBox setState:(unsigned int)([pvVar1 shouldRepeat])];
    [_audioCueTypeMatrix selectCellWithTag:[pvVar1 audioCueType]];
    pvVar2_5 = [_audioCueTypeMatrix selectedTag];
    uVar5 = (unsigned int)(pvVar2_5 == 0x2);
    [_chooseAudioMediaButton setEnabled:uVar5];
    [_audioMediaNameBox setHyperEnabled:uVar5];
    pvVar1_5 = [[[self actionAttributes] audioMedia] mediaName];
    if (pvVar1_5 == nil) {
        pvVar1_5 = [NSString string];
    }
    [_audioMediaNameTextField setStringValue:pvVar1_5];
    pvVar1_6 = [NSBundle mainBundle];
    pvVar3_2 = [[self actionAttributes] audioMediaUID];
    pcVar6 = @"Change";
    if (pvVar3_2 == nil) {
        pcVar6 = @"Choose";
    }
    [_chooseAudioMediaButton setTitle:[[pvVar1_6 localizedStringForKey:pcVar6 value:@"" table:@"AssistantPanes"] hyperStringByAddingEllipsis]];
    pvVar3_5 = [self class];
    [_playButtonCell setEnabled:((unsigned int)([self previewSoundObject] != nil && pvVar2_5 == 0x2))];
    pvVar1_9 = [self isPlaying];
    pvVar2_6 = _playButtonCell;
    if (!pvVar1_9) {
        [pvVar2_6 setImage:[pvVar3_5 playButtonImage]];
        [_playButtonCell setAquaAlternateImage:[pvVar3_5 playButtonAquaImage]];
        pvVar2_8 = _playButtonCell;
        pvVar1_12 = [pvVar3_5 playButtonGraphiteImage];
    }
    else {
        [pvVar2_6 setImage:[pvVar3_5 stopButtonImage]];
        [_playButtonCell setAquaAlternateImage:[pvVar3_5 stopButtonAquaImage]];
        pvVar2_8 = _playButtonCell;
        pvVar1_12 = [pvVar3_5 stopButtonGraphiteImage];
    }
    [pvVar2_8 setGraphiteAlternateImage:pvVar1_12];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024edc0 @ 0024edc0, 320 bytes * /

void FUN_0024edc0(HSButtonListerActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  int iVar5;
  uint uVar6;
  
  pvVar3 = _objc_msgSend(self->_buttonsTableView,sel_selectedRowIndexes);
  pvVar1 = self->_removeSelectedButtonButton;
  pvVar4 = _objc_msgSend(pvVar3,sel_lastIndex);
  uVar6 = (uint)(pvVar4 != (id)0x7fffffff);
  _objc_msgSend(pvVar1,sel_setEnabled_,uVar6);
  pvVar1 = self->_moveSelectedButtonUpButton;
  pvVar4 = _objc_msgSend(pvVar3,sel_firstIndex);
  if (pvVar4 == (id)0x7fffffff) {
LAB_0024ee64:
    cVar2 = '\0';
  }
  else {
    pvVar4 = _objc_msgSend(pvVar3,sel_firstIndex,uVar6);
    if (pvVar4 == (id)0x0) goto LAB_0024ee64;
    cVar2 = '\x01';
  }
  iVar5 = (int)cVar2;
  _objc_msgSend(pvVar1,sel_setEnabled_,iVar5);
  pvVar1 = self->_moveSelectedButtonDownButton;
  pvVar4 = _objc_msgSend(pvVar3,sel_firstIndex);
  if (pvVar4 != (id)0x7fffffff) {
    pvVar3 = _objc_msgSend(pvVar3,sel_lastIndex,iVar5);
    pvVar4 = _objc_msgSend(self,sel_numberOfRowsInTableView_,self->_buttonsTableView);
    if (pvVar3 < (id)((int)pvVar4 + -1)) {
      cVar2 = '\x01';
      goto LAB_0024eedf;
    }
  }
  cVar2 = '\0';
LAB_0024eedf:
  _objc_msgSend(pvVar1,sel_setEnabled_,(int)cVar2);
  return;
}

*/
- (void)validateButtonsOrginizingControls
{
    NSIndexSet *selection = [_buttonsTableView selectedRowIndexes];
    [_removeSelectedButtonButton setEnabled:[selection lastIndex] != NSNotFound];
    [_moveSelectedButtonUpButton setEnabled:[selection firstIndex] != NSNotFound && [selection firstIndex] != 0];
    BOOL canMoveDown = NO;
    if ([selection firstIndex] != NSNotFound) {
        canMoveDown = [selection lastIndex] < (NSUInteger)([self numberOfRowsInTableView:_buttonsTableView] - 1);
    }
    [_moveSelectedButtonDownButton setEnabled:canMoveDown];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024ebf9 @ 0024ebf9, 455 bytes * /

void FUN_0024ebf9(HSButtonListerActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id self_01;
  id self_02;
  id pvVar2;
  id self_03;
  
  pvVar1 = _objc_msgSend(self->_buttonsTableView,sel_tableColumnWithIdentifier_,
                         &cfstr_HSButtonListerTitleIdentifier);
  self_00 = _objc_msgSend(pvVar1,sel_dataCell);
  pvVar1 = _objc_msgSend(cls_NSMenu,sel_alloc);
  self_01 = _objc_msgSend(pvVar1,sel_init);
  pvVar1 = _objc_msgSend(self,sel_availableButtonObjects);
  self_02 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_02,sel_nextObject);
  while (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0038567c);
    self_03 = _objc_msgSend(cls_NSMenuItem,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_title);
    pvVar2 = _objc_msgSend(self_03,sel_initWithTitle_action_keyEquivalent_,pvVar2,0,&cfstr_empty);
    _objc_msgSend(pvVar2,sel_setRepresentedObject_,pvVar1);
    _objc_msgSend(self_01,sel_addItem_,pvVar2);
    _objc_msgSend(pvVar2,sel_release);
    pvVar1 = _objc_msgSend(self_02,sel_nextObject);
  }
  _objc_msgSend(self_00,sel_setMenu_,self_01);
  _objc_msgSend(self_01,sel_release);
  return;
}

*/
- (void)updateButtonsPopUpButtonCellMenu
{
    NSPopUpButtonCell *cell = [[_buttonsTableView tableColumnWithIdentifier:@"HSButtonListerTitleIdentifier"] dataCell];
    NSMenu *menu = [[NSMenu alloc] init];
    for (id button in [self availableButtonObjects]) {
        id title = [button queryHyperInterface:@protocol(HSTitleAttributes)];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[title title] action:NULL keyEquivalent:@""];
        [item setRepresentedObject:button];
        [menu addItem:item];
        [item release];
    }
    [cell setMenu:menu];
    [menu release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0024e970 @ 0024e970, 649 bytes * /

void FUN_0024e970(HSButtonListerActionAssistantPane *self,SEL _cmd)

{
  int iVar1;
  undefined *puVar2;
  id self_00;
  id self_01;
  id pvVar3;
  id pvVar4;
  id self_02;
  int iVar5;
  
  self_00 = _objc_msgSend(self->_addButtonPopUpButton,sel_menu);
  iVar5 = 1;
  self_01 = _objc_msgSend(self,sel_availableButtonObjects);
  while( true ) {
    pvVar3 = _objc_msgSend(self_00,sel_numberOfItems);
    if ((int)pvVar3 <= iVar5) break;
    pvVar3 = _objc_msgSend(self_00,sel_itemAtIndex_,iVar5);
    pvVar3 = _objc_msgSend(pvVar3,sel_representedObject);
    pvVar3 = _objc_msgSend(self_01,sel_containsObject_,pvVar3);
    if ((char)pvVar3 == '\0') {
      _objc_msgSend(self_00,sel_removeItemAtIndex_,iVar5);
    }
    else {
      iVar5 = iVar5 + 1;
    }
  }
  pvVar3 = _objc_msgSend(self_01,sel_count);
  if (0 < (int)pvVar3) {
    iVar5 = 0;
    do {
      iVar1 = iVar5 + 1;
      pvVar3 = _objc_msgSend(self_00,sel_numberOfItems);
      if (iVar5 < (int)pvVar3 + -1) {
        pvVar3 = _objc_msgSend(self_00,sel_itemAtIndex_,iVar1);
        pvVar4 = _objc_msgSend(pvVar3,sel_representedObject);
        pvVar3 = _objc_msgSend(self_01,sel_objectAtIndex_,iVar5);
        pvVar4 = _objc_msgSend(pvVar4,sel_isEqual_,pvVar3);
        if ((char)pvVar4 == '\0') goto LAB_0024ead0;
      }
      else {
LAB_0024ead0:
        pvVar3 = _objc_msgSend(self_01,sel_objectAtIndex_,iVar5);
        pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0038567c);
        self_02 = _objc_msgSend(cls_NSMenuItem,sel_alloc);
        puVar2 = sel_addButton_;
        pvVar4 = _objc_msgSend(pvVar4,sel_title);
        pvVar4 = _objc_msgSend(self_02,sel_initWithTitle_action_keyEquivalent_,pvVar4,puVar2,
                               &cfstr_empty);
        _objc_msgSend(pvVar4,sel_setTarget_,self);
        _objc_msgSend(pvVar4,sel_setRepresentedObject_,pvVar3);
        pvVar3 = pvVar4;
        _objc_msgSend(self_00,sel_insertItem_atIndex_,pvVar4,iVar1);
        _objc_msgSend(pvVar4,sel_release);
      }
      pvVar3 = _objc_msgSend(self_01,sel_count,pvVar3);
      iVar5 = iVar1;
    } while (iVar1 < (int)pvVar3);
  }
  return;
}

*/
- (void)updateAddButtonPopUpButtonMenu
{
    NSMenu *menu = [_addButtonPopUpButton menu];
    NSInteger index = 1;
    NSArray *buttons = [self availableButtonObjects];
    while (index < [menu numberOfItems]) {
        if (![buttons containsObject:[[menu itemAtIndex:index] representedObject]]) {
            [menu removeItemAtIndex:index];
        }
        else {
            index++;
        }
    }
    for (NSInteger i = 0; i < (NSInteger)[buttons count]; i++) {
        if (i < [menu numberOfItems] - 1 && [[[menu itemAtIndex:i + 1] representedObject] isEqual:[buttons objectAtIndex:i]]) {
            continue;
        }
        id button = [buttons objectAtIndex:i];
        id title = [button queryHyperInterface:@protocol(HSTitleAttributes)];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:[title title] action:@selector(addButton:) keyEquivalent:@""];
        [item setTarget:self];
        [item setRepresentedObject:button];
        [menu insertItem:item atIndex:i + 1];
        [item release];
    }
}

- (id)availableButtonObjects
{
    id pvVar1;
    id pvVar2;
    id pvVar3_2;
    id pvVar3_3;

    pvVar1 = [self stack];
    pvVar2 = _availableButtonObjects;
    if ((pvVar2 == nil) && (pvVar1 != nil)) {
        _availableButtonObjects = [NSMutableArray new];
        [pvVar1 hyperDeepEnumerator];
        while (pvVar1 = [pvVar2 nextObject], pvVar1 != nil) {
            [pvVar1 queryHyperInterface:@protocol(HSCardAttributes)];
            if (((pvVar3_2 == nil) && (pvVar3_2 = [pvVar1 queryHyperInterface:@protocol(HSStackAttributes)], pvVar3_2 == nil) ) && (pvVar3_2 = [pvVar1 queryHyperInterface:@protocol(HSButtonObjectAttributes)], pvVar3_2 != nil)) {
                pvVar3_3 = _availableButtonObjects;
                pvVar1 = [pvVar1 queryHyperInterface:@protocol(HSButtonObjectAttributes)];
                [pvVar3_3 addObject:pvVar1];
            }
        }
        pvVar2 = _availableButtonObjects;
    }
    return pvVar2;
}

- (void)invalidateAvailableButtonObjects
{
    [_availableButtonObjects release];
    _availableButtonObjects = nil;
}

- (BOOL)areAvailableButtonObjectsInvalidated
{
    return _availableButtonObjects == nil;
}

- (id)initialKeyView
{
    return _buttonsTableView;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [self setStack:nil];
    if ([_buttonsTableView dataSource] == self) {
        [_buttonsTableView setDataSource:0];
    }
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_buttonsTableView setDataSource:self];
    [self validateUserInterface];
    [self addActionAssistantPaneObserver];
}

- (id)actionAttribute
{
    return (id)@protocol(HSButtonListerActionAttributes);
}

- (id)actionAttributes
{
    return [[self buttonListerActionAssistantPaneApplier] buttonListerActionAttributes];
}

- (id)buttonListerActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSButtonListerActionAssistantPaneApplier class];
}

- (id)actionType
{
    return [HSButtonListerAction actionType];
}

- (void)awakeFromNib
{
    [_buttonsTableView registerForDraggedTypes:[NSArray arrayWithObject:@"HSButtonListerActionTableViewDataType"]];
}

- (void)dealloc
{
    [_importSoundObjectDialogController release];
    [self invalidatePreviewSoundObject];
    [self setStack:nil];
    [_availableButtonObjects release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"ButtonListerAssistantPane"];
    return self;
}

@end

@implementation HSButtonListerActionAssistantPaneApplier

/* i386 ivar offsets: _initialPerformDelay=0x30, _initialShouldRepeat=0x34, _initialButtonUIDs=0x38, _initialAudioCueType=0x3c, _initialAudioMedia=0x40, _performDelay=0x44, _shouldRepeat=0x48, _buttonUIDs=0x4c, _audioCueType=0x50, _audioMedia=0x54 */

- (void)setAudioMedia:(id)aMedia
{
    if (_audioMedia != aMedia) {
        [_audioMedia release];
        _audioMedia = [aMedia retain];
        [self disableUndo];
        [[self buttonListerActionAttributes] setAudioMedia:_audioMedia];
        [self enableUndo];
    }
}

- (void)setAudioCueType:(NSInteger)aType
{
    if (_audioCueType != aType) {
        _audioCueType = aType;
        [self disableUndo];
        [[self buttonListerActionAttributes] setAudioCueType:_audioCueType];
        [self enableUndo];
    }
}

- (void)setButtonUIDs:(id)aDs
{
    if (![_buttonUIDs isEqualToArray:aDs]) {
        [_buttonUIDs release];
        _buttonUIDs = [aDs retain];
        [self disableUndo];
        [[self buttonListerActionAttributes] setButtonUIDs:_buttonUIDs];
        [self enableUndo];
    }
}

- (void)setShouldRepeat:(BOOL)aRepeat
{
    if ((BOOL)_shouldRepeat != (aRepeat != NO)) {
        _shouldRepeat = aRepeat != NO;
        [self disableUndo];
        [[self buttonListerActionAttributes] setShouldRepeat:_shouldRepeat];
        [self enableUndo];
    }
}

- (void)setPerformDelay:(CGFloat)aDelay
{
    float fVar1;
    float fVar2;
    float fVar3;

    fVar1 = _performDelay;
    fVar2 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar3 = aDelay != 0.0 ? fabs(aDelay) : 1.0;
    if (fVar3 <= fVar2) {
        fVar3 = fVar2;
    }
    if (fVar3 * 0.0005 < fabs(fVar1 - aDelay)) {
        _performDelay = aDelay;
        [self disableUndo];
        [[self buttonListerActionAttributes] setPerformDelay:_performDelay];
        [self enableUndo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025073d @ 0025073d, 282 bytes * /

BOOL FUN_0025073d(HSButtonListerActionAssistantPaneApplier *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  bool bVar4;
  byte bVar5;
  float fVar6;
  float fVar7;
  HSButtonListerActionAssistantPaneApplier *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantSettingsApplier_00355d90;
  pvVar3 = _objc_msgSendSuper(&local_1c,sel_areSettingsEqual);
  fVar1 = self->_initialPerformDelay;
  fVar2 = self->_performDelay;
  if ((fVar1 != 0.0) || (NAN(fVar1))) {
    fVar6 = ABS(fVar1);
  }
  else {
    fVar6 = 1.0;
  }
  if ((fVar2 != 0.0) || (NAN(fVar2))) {
    fVar7 = ABS(fVar2);
  }
  else {
    fVar7 = 1.0;
  }
  if (fVar7 <= fVar6) {
    fVar7 = fVar6;
  }
  bVar4 = self->_initialShouldRepeat == self->_shouldRepeat &&
          ((char)pvVar3 != '\0' && ABS(fVar1 - fVar2) <= fVar7 * 0.0005);
  if (self->_initialButtonUIDs != (id)0x0 || self->_buttonUIDs != (id)0x0) {
    pvVar3 = _objc_msgSend(self->_initialButtonUIDs,sel_isEqualToArray_,self->_buttonUIDs);
    bVar4 = (bool)(bVar4 & (byte)pvVar3);
  }
  bVar5 = self->_initialAudioCueType == self->_audioCueType & bVar4;
  if (self->_initialAudioMedia != (id)0x0 || self->_audioMedia != (id)0x0) {
    pvVar3 = _objc_msgSend(self->_initialAudioMedia,sel_isEqual_,self->_audioMedia);
    bVar5 = (char)pvVar3 != '\0' & bVar5;
  }
  return bVar5;
}

*/
- (BOOL)areSettingsEqual
{
    BOOL equal = [super areSettingsEqual];
    float a = _initialPerformDelay;
    float b = _performDelay;
    float scaleA = (a != 0.0f || a != a) ? fabsf(a) : 1.0f;
    float scaleB = (b != 0.0f || b != b) ? fabsf(b) : 1.0f;
    if (scaleB <= scaleA) {
        scaleB = scaleA;
    }
    equal = equal && fabsf(a - b) <= scaleB * 0.0005f && _initialShouldRepeat == _shouldRepeat;
    if (_initialButtonUIDs != nil || _buttonUIDs != nil) {
        equal = equal & [_initialButtonUIDs isEqualToArray:_buttonUIDs];
    }
    equal = (_initialAudioCueType == _audioCueType) & equal;
    if (_initialAudioMedia != nil || _audioMedia != nil) {
        equal = [_initialAudioMedia isEqual:_audioMedia] & equal;
    }
    return equal;
}

- (void)makeCurrentEqualToInitial
{
    _performDelay = _initialPerformDelay;
    _shouldRepeat = _initialShouldRepeat;
    [_buttonUIDs autorelease];
    _buttonUIDs = [_initialButtonUIDs retain];
    _audioCueType = _initialAudioCueType;
    [_audioMedia autorelease];
    _audioMedia = [_initialAudioMedia retain];
    [super makeCurrentEqualToInitial];
}

- (void)makeInitialEqualToCurrent
{
    _initialPerformDelay = _performDelay;
    _initialShouldRepeat = _shouldRepeat;
    [_initialButtonUIDs autorelease];
    _initialButtonUIDs = [_buttonUIDs retain];
    _initialAudioCueType = _audioCueType;
    [_initialAudioMedia autorelease];
    _initialAudioMedia = [_audioMedia retain];
    [super makeInitialEqualToCurrent];
}

- (void)setInitialSettingsToObject
{
    id pvVar2;
    id pvVar1_5;

    [[self buttonListerActionAttributes] setPerformDelay:_initialPerformDelay];
    [[self buttonListerActionAttributes] setShouldRepeat:_initialShouldRepeat];
    [[self buttonListerActionAttributes] setButtonUIDs:_initialButtonUIDs];
    [[self buttonListerActionAttributes] setAudioCueType:_initialAudioCueType];
    pvVar1_5 = [self buttonListerActionAttributes];
    if (_initialAudioCueType == 2) {
        pvVar2 = _initialAudioMedia;
    }
    else {
        pvVar2 = nil;
    }
    [pvVar1_5 setAudioMedia:pvVar2];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    id pvVar2;
    id pvVar1_5;

    [[self buttonListerActionAttributes] setPerformDelay:_performDelay];
    [[self buttonListerActionAttributes] setShouldRepeat:_shouldRepeat];
    [[self buttonListerActionAttributes] setButtonUIDs:_buttonUIDs];
    [[self buttonListerActionAttributes] setAudioCueType:_audioCueType];
    pvVar1_5 = [self buttonListerActionAttributes];
    if (_audioCueType == 2) {
        pvVar2 = _audioMedia;
    }
    else {
        pvVar2 = nil;
    }
    [pvVar1_5 setAudioMedia:pvVar2];
    [super setCurrentSettingsToObject];
}

- (void)setUpInitialSettings
{
    double dVar2;
    BOOL pvVar1_3;
    id pvVar1_6;
    NSInteger pvVar1_9;
    id pvVar1_12;

    dVar2 = [[self buttonListerActionAttributes] performDelay];
    _performDelay = (float)dVar2;
    _initialPerformDelay = (float)dVar2;
    pvVar1_3 = [[self buttonListerActionAttributes] shouldRepeat];
    _shouldRepeat = (BOOL)pvVar1_3;
    _initialShouldRepeat = (BOOL)pvVar1_3;
    pvVar1_6 = [[[self buttonListerActionAttributes] buttonUIDs] retain];
    _initialButtonUIDs = pvVar1_6;
    _buttonUIDs = [pvVar1_6 retain];
    pvVar1_9 = [[self buttonListerActionAttributes] audioCueType];
    _audioCueType = (int)pvVar1_9;
    _initialAudioCueType = (int)pvVar1_9;
    pvVar1_12 = [[[self buttonListerActionAttributes] audioMedia] retain];
    _initialAudioMedia = pvVar1_12;
    _audioMedia = [pvVar1_12 retain];
    [super setUpInitialSettings];
}

- (id)buttonListerActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSButtonListerActionAttributes)];
}

- (void)dealloc
{
    [_initialButtonUIDs release];
    [_buttonUIDs release];
    [_initialAudioMedia release];
    [_audioMedia release];
    [super dealloc];
}

@end

