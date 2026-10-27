#import "HSTextToSpeechActionAssistantPane.h"

static NSInteger HSTextToSpeechTextObjectCompare(id a, id b, void *context)
{
    id nameA = [[a queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    id nameB = [[b queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    return [nameA caseInsensitiveCompare:nameB];
}

@implementation HSTextToSpeechActionAssistantPane

/* i386 ivar offsets: _speechPitch=0x88, _speechRate=0x8c, _voices=0x90, _readTextMatrix=0x94, _containerView=0x98, _textFieldView=0x9c, _noTextObjectView=0xa0, _textObjectsView=0xa4, _currentView=0xa8, _textToSpeakField=0xac, _textObjectsTableView=0xb0, _tryItButton=0xb4, _isSpeaking=0xb8, _availableTextObjects=0xbc, _playImage=0xc0, _stopImage=0xc4, _pressedPlayImage=0xc8, _pressedStopImage=0xcc */

+ (id)stopButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"L" tint:@"G"];
}

+ (id)stopButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"P" size:@"L" tint:@"A"];
}

+ (id)stopButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Stop" state:@"N" size:@"L" tint:@"A"];
}

+ (id)playButtonGraphiteImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"L" tint:@"G"];
}

+ (id)playButtonAquaImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"P" size:@"L" tint:@"A"];
}

+ (id)playButtonImage
{
    return [[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"N" size:@"L" tint:@"A"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001213f5 @ 001213f5, 758 bytes * /

void FUN_001213f5(HSTextToSpeechActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  id self_01;
  cfstringStruct *self_02;
  cfstringStruct *pcVar5;
  
  pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_array);
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pcVar5 = (cfstringStruct *)0x0;
  _objc_msgSend(self->_voices,sel_setAutoenablesItems_,0);
  _objc_msgSend(self->_voices,sel_removeAllItems);
  pvVar3 = _objc_msgSend(cls_SMKSpeechVoice,sel_availableVoices);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator);
  while (self_02 = _objc_msgSend(pvVar3,sel_nextObject,pcVar5), self_02 != (cfstringStruct *)0x0) {
    pvVar4 = _objc_msgSend(self_02,sel_gender,pcVar5);
    self_01 = pvVar1;
    if ((pvVar4 != (id)0x1) &&
       (pvVar4 = _objc_msgSend(self_02,sel_gender), self_01 = self_00, pvVar4 == (id)0x2)) {
      self_01 = pvVar2;
    }
    _objc_msgSend(self_01,sel_addObject_,self_02);
    pcVar5 = self_02;
  }
  pvVar3 = _objc_msgSend(pvVar1,sel_count,pcVar5);
  if (pvVar3 != (id)0x0) {
    pcVar5 = &cfstr_Male;
    _objc_msgSend(self,sel_addItemsInVoicesMenuForGender_fromArray_,&cfstr_Male,pvVar1);
  }
  pvVar1 = _objc_msgSend(pvVar2,sel_count,pcVar5);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_voices,sel_numberOfItems,pcVar5);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self->_voices,sel_menu,pcVar5);
      pvVar3 = _objc_msgSend(cls_NSMenuItem,sel_separatorItem);
      _objc_msgSend(pvVar1,sel_addItem_,pvVar3);
    }
    pcVar5 = &cfstr_Female;
    _objc_msgSend(self,sel_addItemsInVoicesMenuForGender_fromArray_,&cfstr_Female,pvVar2);
  }
  pvVar1 = _objc_msgSend(self_00,sel_count,pcVar5);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self->_voices,sel_numberOfItems,pcVar5);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self->_voices,sel_menu,pcVar5);
      pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_separatorItem);
      _objc_msgSend(pvVar1,sel_addItem_,pvVar2);
    }
    _objc_msgSend(self,sel_addItemsInVoicesMenuForGender_fromArray_,&cfstr_Novelty,self_00);
  }
  return;
}

*/
- (void)fillVoicesPopUpMenu
{
    NSMutableArray *maleVoices = [NSMutableArray array];
    NSMutableArray *femaleVoices = [NSMutableArray array];
    NSMutableArray *noveltyVoices = [NSMutableArray array];
    [_voices setAutoenablesItems:NO];
    [_voices removeAllItems];
    for (id voice in [SMKSpeechVoice availableVoices]) {
        NSMutableArray *voices = maleVoices;
        if ([voice gender] != 1) {
            voices = ([voice gender] == 2) ? femaleVoices : noveltyVoices;
        }
        [voices addObject:voice];
    }
    if ([maleVoices count] != 0) {
        [self addItemsInVoicesMenuForGender:@"Male" fromArray:maleVoices];
    }
    if ([femaleVoices count] != 0) {
        if ([_voices numberOfItems] != 0) {
            [[_voices menu] addItem:[NSMenuItem separatorItem]];
        }
        [self addItemsInVoicesMenuForGender:@"Female" fromArray:femaleVoices];
    }
    if ([noveltyVoices count] != 0) {
        if ([_voices numberOfItems] != 0) {
            [[_voices menu] addItem:[NSMenuItem separatorItem]];
        }
        [self addItemsInVoicesMenuForGender:@"Novelty" fromArray:noveltyVoices];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001211fa @ 001211fa, 507 bytes * /

void FUN_001211fa(HSTextToSpeechActionAssistantPane *self,SEL _cmd,id addItemsInVoicesMenuForGender,
                 id fromArray)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  
  pvVar1 = _objc_msgSend(cls_NSMenuItem,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_init);
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,addItemsInVoicesMenuForGender
                         ,&cfstr_empty,&cfstr_AssistantPanes);
  _objc_msgSend(pvVar1,sel_setTitle_,pvVar2);
  _objc_msgSend(pvVar1,sel_setEnabled_,0);
  pvVar3 = _objc_msgSend(self->_voices,sel_menu);
  pvVar2 = pvVar1;
  _objc_msgSend(pvVar3,sel_addItem_,pvVar1);
  _objc_msgSend(pvVar1,sel_release);
  pvVar3 = _objc_msgSend(fromArray,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(pvVar3,sel_nextObject);
  while (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_alloc,pvVar2);
    self_00 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(pvVar1,sel_name);
    _objc_msgSend(self_00,sel_setTitle_,pvVar2);
    _objc_msgSend(self_00,sel_setRepresentedObject_,pvVar1);
    pvVar1 = _objc_msgSend(self->_voices,sel_menu);
    pvVar2 = self_00;
    _objc_msgSend(pvVar1,sel_addItem_);
    _objc_msgSend(self_00,sel_release);
    pvVar1 = _objc_msgSend(pvVar3,sel_nextObject);
  }
  return;
}

*/
- (void)addItemsInVoicesMenuForGender:(id)aGender fromArray:(id)aArray
{
    NSMenuItem *header = [[NSMenuItem alloc] init];
    [header setTitle:[[NSBundle mainBundle] localizedStringForKey:aGender value:@"" table:@"AssistantPanes"]];
    [header setEnabled:NO];
    [[_voices menu] addItem:header];
    [header release];
    for (id voice in aArray) {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        [item setTitle:[(SMKSpeechVoice *)voice name]];
        [item setRepresentedObject:voice];
        [[_voices menu] addItem:item];
        [item release];
    }
}

- (void)updateSpeechText
{
    [[self textToSpeechActionAssistantPaneApplier] setTextToSpeak:[[[[_textToSpeakField textStorage] string] copy] autorelease]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001210c4 @ 001210c4, 164 bytes * /

void FUN_001210c4(HSTextToSpeechActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  bool bVar2;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_usesTextObject);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self->_textToSpeakField,sel_textStorage);
    pvVar1 = _objc_msgSend(pvVar1,sel_string);
    pvVar1 = _objc_msgSend(pvVar1,sel_length);
    bVar2 = pvVar1 != (id)0x0;
  }
  else {
    bVar2 = false;
  }
  _objc_msgSend(self->_tryItButton,sel_setEnabled_,(int)bVar2);
  return;
}

*/
- (void)validateTryItButton
{
    BOOL enabled = NO;
    if (![[self actionAttributes] usesTextObject]) {
        enabled = [[[_textToSpeakField textStorage] string] length] != 0;
    }
    [_tryItButton setEnabled:enabled];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00120d7f @ 00120d7f, 837 bytes * /

void FUN_00120d7f(HSTextToSpeechActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  uint uVar5;
  id pvVar6;
  bool bVar7;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_usesTextObject);
  uVar5 = (uint)((char)pvVar1 == '\0');
  _objc_msgSend(self->_readTextMatrix,sel_selectCellWithTag_,uVar5);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_actionAttributes,uVar5);
    pvVar3 = _objc_msgSend(pvVar1,sel_textToSpeak);
    _objc_msgSend(self,sel_mountView_,self->_textFieldView);
    pvVar2 = _objc_msgSend(self->_textToSpeakField,sel_textStorage);
    pvVar6 = _objc_msgSend(pvVar2,sel_string);
    pvVar1 = pvVar3;
    pvVar6 = _objc_msgSend(pvVar6,sel_isEqualToString_,pvVar3);
    if ((char)pvVar6 == '\0') {
      pvVar6 = _objc_msgSend(pvVar2,sel_length,pvVar1);
      pvVar1 = (id)0x0;
      _objc_msgSend(pvVar2,sel_replaceCharactersInRange_withString_,0,pvVar6,pvVar3);
    }
    pvVar1 = _objc_msgSend(pvVar3,sel_length,pvVar1);
    bVar7 = pvVar1 != (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_availableTextObjects,uVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    if (pvVar1 == (id)0x0) {
      _objc_msgSend(self,sel_mountView_,self->_noTextObjectView);
      bVar7 = false;
    }
    else {
      pvVar3 = self->_textObjectsView;
      _objc_msgSend(self,sel_mountView_,pvVar3);
      _objc_msgSend(self->_textObjectsTableView,sel_reloadData);
      pvVar2 = _objc_msgSend(self,sel_actionAttributes);
      pvVar2 = _objc_msgSend(pvVar2,sel_textObjectUID);
      for (pvVar6 = (id)0x0; pvVar6 < pvVar1; pvVar6 = (id)((int)pvVar6 + 1)) {
        pvVar3 = _objc_msgSend(self,sel_availableTextObjects,pvVar3);
        pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar6);
        pvVar3 = _objc_msgSend(pvVar3,sel_hyperUID);
        pvVar4 = _objc_msgSend(pvVar2,sel_isEqual_);
        if ((char)pvVar4 != '\0') break;
      }
      pvVar3 = (id)0x0;
      if (pvVar6 < pvVar1) {
        pvVar3 = pvVar6;
      }
      pvVar1 = self->_textObjectsTableView;
      pvVar2 = _objc_msgSend(cls_NSIndexSet,sel_indexSetWithIndex_,pvVar3);
      _objc_msgSend(pvVar1,sel_selectRowIndexes_byExtendingSelection_,pvVar2,0);
      _objc_msgSend(self,sel_tableViewSelectionDidChange_,0);
      pvVar1 = _objc_msgSend(self,sel_availableTextObjects);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperStringValue);
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_empty);
      bVar7 = (char)pvVar1 == '\0';
    }
  }
  _objc_msgSend(self->_tryItButton,sel_setEnabled_,(int)bVar7);
  return;
}

*/
- (void)validateView
{
    BOOL usesTextObject = [[self actionAttributes] usesTextObject];
    BOOL enabled;
    [_readTextMatrix selectCellWithTag:usesTextObject ? 0 : 1];
    if (!usesTextObject) {
        NSString *text = [[self actionAttributes] textToSpeak];
        [self mountView:_textFieldView];
        NSTextStorage *storage = [_textToSpeakField textStorage];
        if (![[storage string] isEqualToString:text]) {
            [storage replaceCharactersInRange:NSMakeRange(0, [storage length]) withString:text];
        }
        enabled = [text length] != 0;
    }
    else {
        NSUInteger count = [[self availableTextObjects] count];
        if (count == 0) {
            [self mountView:_noTextObjectView];
            enabled = NO;
        }
        else {
            [self mountView:_textObjectsView];
            [_textObjectsTableView reloadData];
            id textObjectUID = [[self actionAttributes] textObjectUID];
            NSUInteger index;
            for (index = 0; index < count; index++) {
                if ([textObjectUID isEqual:[[[self availableTextObjects] objectAtIndex:index] hyperUID]]) {
                    break;
                }
            }
            if (index >= count) {
                index = 0;
            }
            [_textObjectsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
            [self tableViewSelectionDidChange:nil];
            enabled = ![[[[self availableTextObjects] objectAtIndex:index] hyperStringValue] isEqualToString:@""];
        }
    }
    [_tryItButton setEnabled:enabled];
}

- (void)validateUI
{
    id pvVar1_3;

    [self validateView];
    [_speechPitch selectItemWithTag:[[self actionAttributes] relativeSpeechPitch]];
    [_speechRate selectItemWithTag:[[self actionAttributes] relativeSpeechRate]];
    pvVar1_3 = _voices;
    [pvVar1_3 selectItemAtIndex:[pvVar1_3 indexOfItemWithRepresentedObject:[[self actionAttributes] speechVoice]]];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)setUpStopButton
{
    [_tryItButton setImage:_stopImage];
    [_tryItButton setAlternateImage:_pressedStopImage];
}

- (void)setUpPlayButton
{
    [_tryItButton setImage:_playImage];
    [_tryItButton setAlternateImage:_pressedPlayImage];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00121f2d @ 00121f2d, 375 bytes * /

id FUN_00121f2d(HSTextToSpeechActionAssistantPane *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  float fVar5;
  
  pvVar2 = _objc_msgSend(cls_SMKSpeechVoice,sel_defaultVoice);
  pvVar2 = _objc_msgSend(pvVar2,sel_defaultSettings);
  pvVar2 = _objc_msgSend(pvVar2,sel_mutableCopy);
  puVar1 = cls_HSTextToSpeechAction;
  pvVar3 = _objc_msgSend(self->_speechPitch,sel_selectedCell);
  pvVar3 = _objc_msgSend(pvVar3,sel_tag);
  dVar4 = _objc_msgSend_fpret(puVar1,sel_speechPitchFromRelativeValue_,pvVar3);
  _objc_msgSend(pvVar2,sel_setPitch_,(float)dVar4);
  puVar1 = cls_HSTextToSpeechAction;
  pvVar3 = _objc_msgSend(self->_speechRate,sel_selectedCell);
  pvVar3 = _objc_msgSend(pvVar3,sel_tag);
  dVar4 = _objc_msgSend_fpret(puVar1,sel_speechRateFromRelativeValue_,pvVar3);
  fVar5 = (float)dVar4;
  _objc_msgSend(pvVar2,sel_setRate_,fVar5);
  pvVar3 = _objc_msgSend(self->_voices,sel_indexOfSelectedItem);
  if (-1 < (int)pvVar3) {
    pvVar3 = _objc_msgSend(self->_voices,sel_selectedItem,fVar5);
    pvVar3 = _objc_msgSend(pvVar3,sel_representedObject);
    _objc_msgSend(pvVar2,sel_setVoice_,pvVar3);
  }
  return pvVar2;
}

*/
- (id)speechSettings
{
    SMKMutableSpeechSettings *settings = [[[SMKSpeechVoice defaultVoice] defaultSettings] mutableCopy];
    [settings setPitch:(float)[HSTextToSpeechAction speechPitchFromRelativeValue:[[_speechPitch selectedCell] tag]]];
    [settings setRate:(float)[HSTextToSpeechAction speechRateFromRelativeValue:[[_speechRate selectedCell] tag]]];
    if ([_voices indexOfSelectedItem] >= 0) {
        [settings setVoice:[[_voices selectedItem] representedObject]];
    }
    return [settings autorelease];
}

- (void)speechManagerDidFinishSpeaking:(id)aSpeaking
{
    if (![aSpeaking hasCurrentSpeechRequestedBy:self]) {
        _isSpeaking = NO;
        [self setUpPlayButton];
    }
}

- (void)textDidChange:(id)aChange
{
    [self updateSpeechText];
    [self validateTryItButton];
}

- (void)tableViewSelectionDidChange:(id)aChange
{
    NSInteger pvVar1;

    pvVar1 = [_textObjectsTableView selectedRow];
    if (pvVar1 != 0xffffffff) {
        if ((int)pvVar1 < (int)[[self availableTextObjects] count]) {
            [[self textToSpeechActionAssistantPaneApplier] setTextObjectUID:[[[self availableTextObjects] objectAtIndex:pvVar1] hyperUID]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001209f0 @ 001209f0, 83 bytes * /

id FUN_001209f0(HSTextToSpeechActionAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_availableTextObjects);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
  pvVar1 = _objc_msgSend(pvVar1,sel_name);
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    return ((id (*)(id, SEL))objc_msgSend)([[self availableTextObjects] objectAtIndex:aRow], @selector(name));
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[[self availableTextObjects] count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001207cc @ 001207cc, 490 bytes * /

void FUN_001207cc(HSTextToSpeechActionAssistantPane *self,SEL _cmd,id tryIt)

{
  id pvVar1;
  id pvVar2;
  SEL pcVar3;
  
  pvVar1 = _objc_msgSend(cls_SMKSpeechManager,sel_sharedSpeechManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_isSpeaking);
  if ((char)pvVar1 == '\0') {
    _objc_msgSend(cls_NSString,sel_string);
    pvVar1 = _objc_msgSend(self->_readTextMatrix,sel_selectedCell);
    pvVar1 = _objc_msgSend(pvVar1,sel_tag);
    if (pvVar1 == (id)0x1) {
      pvVar1 = _objc_msgSend(self->_textToSpeakField,sel_textStorage);
      pcVar3 = sel_string;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_availableTextObjects);
      pvVar2 = _objc_msgSend(self->_textObjectsTableView,sel_selectedRow);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar2);
      pcVar3 = sel_hyperStringValue;
    }
    pvVar1 = _objc_msgSend(pvVar1,pcVar3);
    pvVar2 = _objc_msgSend(cls_SMKSpeechManager,sel_sharedSpeechManager);
    _objc_msgSend(pvVar2,sel_setPausesSpeechOnDeactivate_,0);
    pvVar2 = _objc_msgSend(cls_SMKSpeechManager,sel_sharedSpeechManager);
    _objc_msgSend(pvVar2,sel_speakString_immediately_highPriority_needsParsing_requestor_,pvVar1,0,0
                  ,1,self);
    self->_isSpeaking = '\x01';
    pcVar3 = sel_setUpStopButton;
  }
  else {
    pvVar1 = _objc_msgSend(cls_SMKSpeechManager,sel_sharedSpeechManager);
    _objc_msgSend(pvVar1,sel_stopSpeech);
    self->_isSpeaking = '\0';
    pcVar3 = sel_setUpPlayButton;
  }
  _objc_msgSend(self,pcVar3);
  return;
}

*/
- (void)tryIt:(id)aIt
{
    if ([[SMKSpeechManager sharedSpeechManager] isSpeaking]) {
        [[SMKSpeechManager sharedSpeechManager] stopSpeech];
        _isSpeaking = NO;
        [self setUpPlayButton];
        return;
    }
    NSString *text;
    if ([[_readTextMatrix selectedCell] tag] == 1) {
        text = [[_textToSpeakField textStorage] string];
    }
    else {
        text = [[[self availableTextObjects] objectAtIndex:[_textObjectsTableView selectedRow]] hyperStringValue];
    }
    [[SMKSpeechManager sharedSpeechManager] setPausesSpeechOnDeactivate:NO];
    [[SMKSpeechManager sharedSpeechManager] speakString:text immediately:NO highPriority:NO needsParsing:YES requestor:self];
    _isSpeaking = YES;
    [self setUpStopButton];
}

- (void)voiceChanged:(id)aChanged
{
    [self updateSpeechText];
    [[self textToSpeechActionAssistantPaneApplier] setSpeechVoice:[[_voices selectedItem] representedObject]];
}

- (void)speechRateChanged:(id)aChanged
{
    [self updateSpeechText];
    [[self textToSpeechActionAssistantPaneApplier] setRelativeSpeechRate:[[aChanged selectedCell] tag]];
}

- (void)speechPitchChanged:(id)aChanged
{
    [self updateSpeechText];
    [[self textToSpeechActionAssistantPaneApplier] setRelativeSpeechPitch:[[aChanged selectedCell] tag]];
}

- (void)textToSpeakSourceChanged:(id)aChanged
{
    NSInteger pvVar1_2;
    NSInteger pvVar1_3;

    pvVar1_2 = [[aChanged selectedCell] tag];
    [[self textToSpeechActionAssistantPaneApplier] setUsesTextObject:((unsigned int)(pvVar1_2 == 0))];
    [self validateView];
    if (pvVar1_2 == 0) {
        [self updateSpeechText];
        pvVar1_3 = [_textObjectsTableView selectedRow];
        if (-1 < (int)pvVar1_3) {
            if ((int)pvVar1_3 < (int)[[self availableTextObjects] count]) {
                [[self textToSpeechActionAssistantPaneApplier] setTextObjectUID:[[[self availableTextObjects] objectAtIndex:[_textObjectsTableView selectedRow]] hyperUID]];
            }
        }
    }
}

- (id)initialKeyView
{
    return _speechRate;
}

- (id)helpTopicKey
{
    return @"HSTextToSpeech";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [_textObjectsTableView setDataSource:0];
    [_textObjectsTableView setDelegate:0];
    [self updateSpeechText];
    _isSpeaking = NO;
    [[SMKSpeechManager sharedSpeechManager] stopSpeech];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012217a @ 0012217a, 244 bytes * /

void FUN_0012217a(HSTextToSpeechActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  SEL op;
  HSTextToSpeechActionAssistantPane *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSNBAAssistantPane_00351200;
  _objc_msgSendSuper(&local_14,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self->_textObjectsTableView,sel_setDataSource_,self);
  _objc_msgSend(self,sel_addActionAssistantPaneObserver);
  _objc_msgSend(self->_availableTextObjects,sel_release);
  self->_availableTextObjects = (id)0x0;
  _objc_msgSend(self,sel_fillVoicesPopUpMenu);
  _objc_msgSend(self,sel_validateUI);
  op = sel_setUpPlayButton;
  if (self->_isSpeaking != '\0') {
    op = sel_setUpStopButton;
  }
  _objc_msgSend(self,op);
  _objc_msgSend(self->_textObjectsTableView,sel_setDelegate_,self);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [_textObjectsTableView setDataSource:self];
    [self addActionAssistantPaneObserver];
    [_availableTextObjects release];
    _availableTextObjects = nil;
    [self fillVoicesPopUpMenu];
    [self validateUI];
    if (_isSpeaking) {
        [self setUpStopButton];
    }
    else {
        [self setUpPlayButton];
    }
    [_textObjectsTableView setDelegate:self];
}

- (id)actionAttribute
{
    return (id)@protocol(HSTextToSpeechActionAttributes);
}

- (void)mountView:(id)aView
{
    if (_currentView != aView) {
        [_currentView removeFromSuperview];
        [_containerView addSubview:aView];
        _currentView = aView;
    }
}

- (void)dealloc
{
    [_textToSpeakField setDelegate:0];
    [[SMKSpeechManager sharedSpeechManager] requestorWillBecomeInvalid:self];
    [[SMKSpeechManager sharedSpeechManager] setPausesSpeechOnDeactivate:YES];
    [_availableTextObjects release];
    _availableTextObjects = nil;
    [_playImage release];
    [_stopImage release];
    [_pressedPlayImage release];
    [_pressedStopImage release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001223a9 @ 001223a9, 644 bytes * /

void FUN_001223a9(HSTextToSpeechActionAssistantPane *self,SEL _cmd)

{
  HSPlaceholderTextView *self_00;
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  HSTextToSpeechActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00351200;
  _objc_msgSendSuper(&local_1c,sel_viewDidLoad);
  _objc_msgSend(self->_textToSpeakField,sel_setRichText_,0);
  _objc_msgSend(self->_textToSpeakField,sel_setDelegate_,self);
  pvVar2 = self->_noTextObjectView;
  pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Background_Medium);
  _objc_msgSend(pvVar2,sel_setImage_,pvVar1);
  pvVar2 = _objc_msgSend(cls_HSTextToSpeechActionAssistantPane,sel_playButtonImage);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_playImage = pvVar2;
  pvVar2 = _objc_msgSend(cls_HSTextToSpeechActionAssistantPane,sel_stopButtonImage);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_stopImage = pvVar2;
  puVar3 = sel_currentControlTint;
  pvVar2 = _objc_msgSend(cls_NSColor,sel_respondsToSelector_,sel_currentControlTint);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(cls_NSColor,sel_currentControlTint,puVar3);
    if (pvVar2 == (id)0x6) {
      pvVar2 = _objc_msgSend(cls_HSTextToSpeechActionAssistantPane,sel_playButtonGraphiteImage,
                             puVar3);
      pvVar2 = _objc_msgSend(pvVar2,sel_retain);
      self->_pressedPlayImage = pvVar2;
      op = sel_stopButtonGraphiteImage;
      goto LAB_00122588;
    }
  }
  pvVar2 = _objc_msgSend(cls_HSTextToSpeechActionAssistantPane,sel_playButtonAquaImage,puVar3);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_pressedPlayImage = pvVar2;
  op = sel_stopButtonAquaImage;
LAB_00122588:
  pvVar2 = _objc_msgSend(cls_HSTextToSpeechActionAssistantPane,op);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_pressedStopImage = pvVar2;
  _objc_msgSend(self,sel_setUpPlayButton);
  self_00 = self->_textToSpeakField;
  pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_NBA_Blabber_Placeholder,&cfstr_empty,&cfstr_AssistantPanes);
  _objc_msgSend(self_00,sel_setPlaceholderString_,pvVar2);
  return;
}

*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    [_textToSpeakField setRichText:NO];
    [_textToSpeakField setDelegate:self];
    [_noTextObjectView setImage:[NSImage imageNamed:@"Background_Medium"]];
    _playImage = [[HSTextToSpeechActionAssistantPane playButtonImage] retain];
    _stopImage = [[HSTextToSpeechActionAssistantPane stopButtonImage] retain];
    if ([NSColor respondsToSelector:@selector(currentControlTint)] && [NSColor currentControlTint] == NSGraphiteControlTint) {
        _pressedPlayImage = [[HSTextToSpeechActionAssistantPane playButtonGraphiteImage] retain];
        _pressedStopImage = [[HSTextToSpeechActionAssistantPane stopButtonGraphiteImage] retain];
    }
    else {
        _pressedPlayImage = [[HSTextToSpeechActionAssistantPane playButtonAquaImage] retain];
        _pressedStopImage = [[HSTextToSpeechActionAssistantPane stopButtonAquaImage] retain];
    }
    [self setUpPlayButton];
    [_textToSpeakField setPlaceholderString:[[NSBundle mainBundle] localizedStringForKey:@"NBA_Blabber_Placeholder" value:@"" table:@"AssistantPanes"]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0012031d @ 0012031d, 353 bytes * /

id FUN_0012031d(HSTextToSpeechActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  
  pvVar1 = self->_availableTextObjects;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_card);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00371e9c);
    pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new);
    self->_availableTextObjects = pvVar2;
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildren);
    pvVar2 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar1 = _objc_msgSend(pvVar2,sel_nextObject);
    while (pvVar1 != (id)0x0) {
      puVar4 = &DAT_00371ec4;
      pvVar3 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_00371ec4);
      if ((char)pvVar3 != '\0') {
        pvVar3 = self->_availableTextObjects;
        puVar4 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00371f28);
        _objc_msgSend(pvVar3,sel_addObject_,puVar4);
      }
      pvVar1 = _objc_msgSend(pvVar2,sel_nextObject,puVar4);
    }
    _objc_msgSend(self->_availableTextObjects,sel_sortUsingFunction_context_,FUN_0011fc3e,0);
    pvVar1 = self->_availableTextObjects;
  }
  return pvVar1;
}

*/
- (id)availableTextObjects
{
    if (_availableTextObjects == nil) {
        id container = [[self card] queryHyperInterface:@protocol(HSNodeContainer)];
        _availableTextObjects = [NSMutableArray new];
        for (id child in [container hyperChildren]) {
            if ([child implementsHyperInterface:@protocol(HSStringContentAttributes)]) {
                [_availableTextObjects addObject:[child queryHyperInterface:@protocol(HSObjectAttributes)]];
            }
        }
        [_availableTextObjects sortUsingFunction:HSTextToSpeechTextObjectCompare context:NULL];
    }
    return _availableTextObjects;
}

- (id)actionType
{
    return [HSTextToSpeechAction actionType];
}

- (id)actionAttributes
{
    return [[self textToSpeechActionAssistantPaneApplier] textToSpeechActionAttributes];
}

- (id)textToSpeechActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSTextToSpeechActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"TextToSpeechAssistantPane"];
    return self;
}

@end

@implementation HSTextToSpeechActionAssistantPaneApplier

/* i386 ivar offsets: _initialTextToSpeak=0x30, _initialTextObjectUID=0x34, _initialUsesTextObject=0x38, _initialPitch=0x3c, _initialRate=0x40, _initialSpeechVoice=0x44, _textToSpeak=0x48, _textObjectUID=0x4c, _usesTextObject=0x50, _pitch=0x54, _rate=0x58, _speechVoice=0x5c */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;

    pvVar1 = [super areSettingsEqual];
    if (pvVar1) {
        if ((_initialTextToSpeak == nil && _textToSpeak == nil) || (pvVar1 = [_initialTextToSpeak isEqualToString:_textToSpeak], pvVar1)) {
            if (((_initialTextObjectUID == nil && _textObjectUID == nil) || (pvVar1 = [_initialTextObjectUID isEqual:_textObjectUID], pvVar1)) && ((_initialPitch == _pitch && (_initialRate == _rate)))) {
                if (_initialSpeechVoice != nil || _speechVoice != nil) {
                    pvVar1 = [_initialSpeechVoice isEqual:_speechVoice];
                    return pvVar1;
                }
                return YES;
            }
        }
    }
    return NO;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_textToSpeak release];
    [_speechVoice release];
    [_textObjectUID release];
    _textToSpeak = [_initialTextToSpeak retain];
    _speechVoice = [_initialSpeechVoice retain];
    _textObjectUID = [_initialTextObjectUID retain];
    _usesTextObject = _initialUsesTextObject;
    _pitch = _initialPitch;
    _rate = _initialRate;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialTextToSpeak release];
    [_initialSpeechVoice release];
    [_initialTextObjectUID release];
    _initialTextToSpeak = [_textToSpeak retain];
    _initialSpeechVoice = [_speechVoice retain];
    _initialTextObjectUID = [_textObjectUID retain];
    _initialUsesTextObject = _usesTextObject;
    _initialPitch = _pitch;
    _initialRate = _rate;
}

- (void)setInitialSettingsToObject
{
    [[self textToSpeechActionAttributes] setTextToSpeak:_initialTextToSpeak];
    [[self textToSpeechActionAttributes] setTextObjectUID:_initialTextObjectUID];
    [[self textToSpeechActionAttributes] setUsesTextObject:_initialUsesTextObject];
    [[self textToSpeechActionAttributes] setRelativeSpeechPitch:_initialPitch];
    [[self textToSpeechActionAttributes] setRelativeSpeechRate:_initialRate];
    [[self textToSpeechActionAttributes] setSpeechVoice:_initialSpeechVoice];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self textToSpeechActionAttributes] setTextToSpeak:_textToSpeak];
    [[self textToSpeechActionAttributes] setTextObjectUID:_textObjectUID];
    [[self textToSpeechActionAttributes] setUsesTextObject:_usesTextObject];
    [[self textToSpeechActionAttributes] setRelativeSpeechPitch:_pitch];
    [[self textToSpeechActionAttributes] setRelativeSpeechRate:_rate];
    [[self textToSpeechActionAttributes] setSpeechVoice:_speechVoice];
}

- (void)setRelativeSpeechRate:(NSInteger)aRate
{
    if (_rate != aRate) {
        _rate = aRate;
        [self disableUndo];
        [[self textToSpeechActionAttributes] setRelativeSpeechRate:_rate];
        [self enableUndo];
    }
}

- (void)setRelativeSpeechPitch:(NSInteger)aPitch
{
    if (_pitch != aPitch) {
        _pitch = aPitch;
        [self disableUndo];
        [[self textToSpeechActionAttributes] setRelativeSpeechPitch:_pitch];
        [self enableUndo];
    }
}

- (void)setUsesTextObject:(BOOL)aObject
{
    if (_usesTextObject != aObject) {
        _usesTextObject = aObject;
        [self disableUndo];
        [[self textToSpeechActionAttributes] setUsesTextObject:_usesTextObject];
        [self enableUndo];
    }
}

- (void)setSpeechVoice:(id)aVoice
{
    if (_speechVoice != aVoice) {
        [_speechVoice release];
        _speechVoice = [aVoice retain];
        [self disableUndo];
        [[self textToSpeechActionAttributes] setSpeechVoice:_speechVoice];
        [self enableUndo];
    }
}

- (void)setTextObjectUID:(id)aUID
{
    if (_textObjectUID != aUID) {
        [_textObjectUID release];
        _textObjectUID = [aUID retain];
        [self disableUndo];
        [[self textToSpeechActionAttributes] setTextObjectUID:_textObjectUID];
        [self enableUndo];
    }
}

- (void)setTextToSpeak:(id)aSpeak
{
    if (![_textToSpeak isEqualToString:aSpeak]) {
        [_textToSpeak release];
        _textToSpeak = [aSpeak retain];
        [self disableUndo];
        [[self textToSpeechActionAttributes] setTextToSpeak:_textToSpeak];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    BOOL pvVar1_20;
    NSInteger pvVar1_22;
    NSInteger pvVar1_24;

    _textToSpeak = [[[self textToSpeechActionAttributes] textToSpeak] retain];
    _textObjectUID = [[[self textToSpeechActionAttributes] textObjectUID] retain];
    _speechVoice = [[[self textToSpeechActionAttributes] speechVoice] retain];
    _initialTextToSpeak = [[[self textToSpeechActionAttributes] textToSpeak] retain];
    _initialTextObjectUID = [[[self textToSpeechActionAttributes] textObjectUID] retain];
    _initialSpeechVoice = [[[self textToSpeechActionAttributes] speechVoice] retain];
    pvVar1_20 = [[self textToSpeechActionAttributes] usesTextObject];
    _initialUsesTextObject = (BOOL)pvVar1_20;
    _usesTextObject = (BOOL)pvVar1_20;
    pvVar1_22 = [[self textToSpeechActionAttributes] relativeSpeechPitch];
    _initialPitch = (int)pvVar1_22;
    _pitch = (int)pvVar1_22;
    pvVar1_24 = [[self textToSpeechActionAttributes] relativeSpeechRate];
    _initialRate = (int)pvVar1_24;
    _rate = (int)pvVar1_24;
}

- (id)textToSpeechActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSTextToSpeechActionAttributes)];
}

- (void)dealloc
{
    [_initialSpeechVoice release];
    [_initialTextObjectUID release];
    [_initialTextToSpeak release];
    [_speechVoice release];
    [_textObjectUID release];
    [_textToSpeak release];
    [super dealloc];
}

@end

