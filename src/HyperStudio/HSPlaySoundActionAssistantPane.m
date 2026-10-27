#import "HSPlaySoundActionAssistantPane.h"

@implementation HSPlaySoundActionAssistantPane

/* i386 ivar offsets: _rangeControl=0x78, _volumeSlider=0x7c, _playButton=0x80, _soundsContainerView=0x84, _currentContentView=0x88, _stopAllSoundsContentView=0x8c, _stopAllSoundsBackgroundImageView=0x90, _soundsTableContentView=0x94, _soundChooserTableView=0x98, _backgroundSoundSwitch=0x9c, _fadeOutSoundSwitch=0xa0, _maxVolumeButton=0xa4, _minVolumeButton=0xa8, _playCountTextField=0xac, _playCountStepper=0xb0, _loopPopUpButton=0xb4, _segmentedControl=0xb8, _optionsView=0xbc, _soundsToPlayView=0xc0, _soundsToStopView=0xc4, _stopAllSoundsSwitch=0xc8, _soundsOnThisCardSwitch=0xcc, _fadeOutStopSoundsSwitch=0xd0, _playStopButton=0xd4, _availableNodes=0xd8, _availableSoundsInNodes=0xdc, _availableSoundsOutlineView=0xe0, _objectNameParagraphStyle=0xe4, _previewSoundObject=0xe8, _importSoundObjectDialogController=0xec, _playSoundActionApplier=0xf0, _currentSoundPlaybackAttributes=0xf4, _pickSoundSourceAssistantPane=0xf8, _sourcesHidden=0xfc */

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

/* --- i386 decompilation (Ghidra) ---
/* FUN_00109041 @ 00109041, 173 bytes * /

id FUN_00109041(HSPlaySoundActionAssistantPane *self,SEL _cmd,int tooltipForKnob)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  
  if (tooltipForKnob == 1) {
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar2 = &cfstr_Drag_this_slider_to_mark_the_place_where_the_sou;
  }
  else {
    if (tooltipForKnob != 0) {
      return (id)0x0;
    }
    pvVar1 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar2 = &cfstr_Drag_this_slider_to_mark_the_place_where_the_sou;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar2,&cfstr_empty,
                         &cfstr_AssistantPanes);
  return pvVar1;
}

*/
- (id)tooltipForKnob:(NSInteger)aKnob
{
    if (aKnob == 1) {
        return [[NSBundle mainBundle] localizedStringForKey:@"Drag this slider to mark the place where the sound should end." value:@"" table:@"AssistantPanes"];
    }
    if (aKnob != 0) {
        return nil;
    }
    return [[NSBundle mainBundle] localizedStringForKey:@"Drag this slider to mark the place where the sound should start playing." value:@"" table:@"AssistantPanes"];
}

- (void)addHyperAction:(id)aAction
{
    [self setSounds:[[aAction queryHyperInterface:@protocol(HSPlaySoundSoundsAttribute)] sounds]];
}

- (void)stopSound:(id)aSound
{
    [self loadViewIfNeeded];
    [_soundsOnThisCardSwitch setState:(unsigned int)([[[self actionAttributes] soundsToStop] count] != 0)];
    [_segmentedControl selectCellWithTag:1];
    [self switchToOptionViewWithTag:1];
    [_optionsView addSubview:_soundsToStopView];
    if ([self isVisible]) {
        [self toggleAllSounds:_stopAllSoundsSwitch];
    }
}

- (void)pickSoundSourceAssistantPane:(id)aPane didChooseSoundItem:(id)aItem
{
    if ([[self actionAttributes] stopsAllSounds]) {
        [[self playSoundActionApplier] setStopsAllSounds:NO];
    }
    [[self playSoundActionApplier] addSound:aItem];
}

- (void)stopObserveNotification:(id)aNotification
{
    int uVar1;
    id pvVar2_2;

    pvVar2_2 = [[self actionAttributes] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_2 removeObserver:self selector:@selector(soundsInActionDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSPlaySoundSoundsAttribute)];
    [[[self actionAttributes] attributeObservingController] removeObserver:self selector:@selector(stopAllSoundsDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSPlaySoundStopsAllSoundsAttribute)];
    [aNotification removeObserver:self selector:@selector(HSPlaySoundActionAssistantPane_cardTitleDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSCardTitleAttribute)];
    [aNotification removeObserver:self selector:@selector(HSPlaySoundActionAssistantPane_cardsDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [aNotification removeObserver:self selector:@selector(HSPlaySoundActionAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute)];
    [aNotification removeObserver:self selector:@selector(HSPlaySoundActionAssistantPane_objectAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSActionsAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2)];
}

- (void)startObserveNotification
{
    int uVar1;
    id pvVar2_2;
    id pvVar2_5;

    pvVar2_2 = [[self actionAttributes] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_2 addObserver:self selector:@selector(soundsInActionDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSPlaySoundSoundsAttribute) withPriority:-0.25];
    [[[self actionAttributes] attributeObservingController] addObserver:self selector:@selector(stopAllSoundsDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSPlaySoundStopsAllSoundsAttribute) withPriority:-0.25];
    pvVar2_5 = [self stack];
    [pvVar2_5 addObserver:self selector:@selector(HSPlaySoundActionAssistantPane_cardTitleDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSCardTitleAttribute) withPriority:-0.25];
    [pvVar2_5 addObserver:self selector:@selector(HSPlaySoundActionAssistantPane_cardsDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [pvVar2_5 addObserver:self selector:@selector(HSPlaySoundActionAssistantPane_objectsWillChange:) ofChanges:HSActualWillAttributeChanges ofChildrenAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
    [pvVar2_5 addObserver:self selector:@selector(HSPlaySoundActionAssistantPane_objectAttributeDidChange:) ofChanges:uVar1 ofAttribute:@protocol(HSActionsAttribute) ofChildrenInDepthRange:NSMakeRange(0, 2) withPriority:-0.25];
}

- (void)updateStopSoundPlaybackAttributes
{
    [self setCurrentSoundPlaybackAttributes:[[_availableSoundsOutlineView itemAtRow:[_availableSoundsOutlineView selectedRow]] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)]];
    [self invalidatePreviewSoundObject];
}

- (void)updateSoundPlaybackAttributes
{
    NSInteger pvVar1;
    id pvVar2_2;

    pvVar1 = [_soundChooserTableView selectedRow];
    pvVar2_2 = [[self actionAttributes] sounds];
    if (-1 < (int)pvVar1) {
        if ((int)pvVar1 < (int)[pvVar2_2 count]) {
            [self setCurrentSoundPlaybackAttributes:[[pvVar2_2 objectAtIndex:pvVar1] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)]];
            [self invalidatePreviewSoundObject];
        }
    }
}

- (void)setCurrentSoundPlaybackAttributes:(id)aAttributes
{
    if (_currentSoundPlaybackAttributes != aAttributes) {
        [_currentSoundPlaybackAttributes release];
        _currentSoundPlaybackAttributes = [aAttributes retain];
    }
}

- (void)cleanUnUsedSoundItemsIfNeeded
{
    id pvVar1;
    id self_00;
    NSEnumerator *pvVar1_3;
    id pvVar2_2;

    pvVar1 = [self actionAttributes];
    pvVar1_3 = [[pvVar1 soundsForState:NO] objectEnumerator];
    self_00 = [self playSoundActionApplier];
    while( YES ) {
        pvVar2_2 = [pvVar1_3 nextObject];
        if (pvVar2_2 == nil) break;
        [self_00 removeSound:pvVar2_2];
    }
}

- (void)outlineViewSelectionDidChange:(id)aChange
{
    [self stopPlaying];
    [self updateStopSoundPlaybackAttributes];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00109946 @ 00109946, 455 bytes * /

id FUN_00109946(HSPlaySoundActionAssistantPane *self,SEL _cmd,id outlineView,id toolTipForCell,
               NSRect *rect,id tableColumn,id item,NSPoint mouseLocation)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined *puVar5;
  
  pvVar1 = _objc_msgSend(tableColumn,sel_identifier);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_sound);
  if ((char)pvVar1 != '\0') {
    puVar5 = &DAT_0037027c;
    pvVar1 = _objc_msgSend(item,sel_queryHyperInterface_,&DAT_0037027c);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_owner,puVar5);
      puVar5 = &DAT_003702e0;
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003702e0);
      if (((pvVar1 != (id)0x0) &&
          (pvVar2 = _objc_msgSend(pvVar1,sel_owner,puVar5), pvVar2 != (id)0x0)) &&
         (pvVar1 = _objc_msgSend(pvVar2,sel_hyperObjectForAction_,pvVar1), pvVar1 != (id)0x0)) {
        pvVar2 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003702f4);
        pvVar2 = _objc_msgSend(pvVar2,sel_card);
        puVar5 = &DAT_00370308;
        pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00370308);
        pvVar3 = _objc_msgSend(pvVar3,sel_hyperName);
        self_00 = cls_NSMutableString;
        if (pvVar3 != (id)0x0) {
          if (pvVar2 == (id)0x0) {
            pvVar1 = _objc_msgSend(cls_NSMutableString,sel_stringWithString_,pvVar3);
            return pvVar1;
          }
          pvVar4 = _objc_msgSend(pvVar2,sel_hyperTitle,puVar5);
          pvVar4 = _objc_msgSend(self_00,sel_stringWithString_,pvVar4);
          if (pvVar1 == pvVar2) {
            return pvVar4;
          }
          _objc_msgSend(pvVar4,sel_appendFormat_,&cfstr______,pvVar3);
          return pvVar4;
        }
      }
    }
  }
  return (id)0x0;
}

*/
- (id)outlineView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn item:(id)aItem mouseLocation:(NSPoint)aLocation
{
    id soundItem;
    id action;
    id owner;
    id hyperObject;
    id card;
    id name;
    NSMutableString *toolTip;

    if (![[aColumn identifier] isEqual:@"sound"]) {
        return nil;
    }
    soundItem = [aItem queryHyperInterface:@protocol(HSSoundItemAttributes)];
    if (soundItem == nil) {
        return nil;
    }
    action = [[soundItem owner] queryHyperInterface:@protocol(HSAction)];
    if (action == nil) {
        return nil;
    }
    owner = [action owner];
    if (owner == nil) {
        return nil;
    }
    hyperObject = [owner hyperObjectForAction:action];
    if (hyperObject == nil) {
        return nil;
    }
    card = [[hyperObject queryHyperInterface:@protocol(HSUserObjectSupport)] card];
    name = [[hyperObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    if (name == nil) {
        return nil;
    }
    if (card == nil) {
        return [NSMutableString stringWithString:name];
    }
    toolTip = [NSMutableString stringWithString:[card hyperTitle]];
    if (hyperObject != card) {
        [toolTip appendFormat:@" : %@", name];
    }
    return toolTip;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00109b0d @ 00109b0d, 289 bytes * /

void FUN_00109b0d(HSPlaySoundActionAssistantPane *self,SEL _cmd,id outlineView,id willDisplayCell,
                 id forTableColumn,id item)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(forTableColumn,sel_identifier);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_sound);
  if ((((char)pvVar1 != '\0') &&
      (pvVar1 = _objc_msgSend(item,sel_implementsHyperInterface_,&DAT_00370178),
      (char)pvVar1 == '\0')) &&
     (pvVar1 = _objc_msgSend(item,sel_implementsHyperInterface_,&DAT_003701c8), (char)pvVar1 == '\0'
     )) {
    pcVar2 = _objc_msgSend(self,sel_HSPlaySoundActionAssistantPane_titleForItem_,item);
    op = sel_setAttributedTitle_;
    if (pcVar2 == (cfstringStruct *)0x0) {
      pcVar2 = &cfstr_empty;
      op = sel_setTitle_;
    }
    _objc_msgSend(willDisplayCell,op,pcVar2);
    pvVar1 = _objc_msgSend(self->_stopAllSoundsSwitch,sel_state);
    _objc_msgSend(willDisplayCell,sel_setEnabled_,(uint)(pvVar1 != (id)0x1));
  }
  return;
}

*/
- (void)outlineView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn item:(id)aItem
{
    id title;

    if ([[aColumn identifier] isEqualToString:@"sound"]
        && ![aItem implementsHyperInterface:@protocol(HSCardAttributes)]
        && ![aItem implementsHyperInterface:@protocol(HSStackAttributes)]) {
        title = [self HSPlaySoundActionAssistantPane_titleForItem:aItem];
        if (title == nil) {
            [aCell setTitle:@""];
        }
        else {
            [aCell setAttributedTitle:title];
        }
        [aCell setEnabled:[_stopAllSoundsSwitch state] != NSControlStateValueOn];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00109c2e @ 00109c2e, 241 bytes * /

void FUN_00109c2e(HSPlaySoundActionAssistantPane *self,SEL _cmd,id outlineView,id setObjectValue,
                 id forTableColumn,id byItem)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  SEL op;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(forTableColumn,sel_identifier);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_sound);
  if ((char)pvVar1 != '\0') {
    puVar3 = &DAT_0037027c;
    pvVar1 = _objc_msgSend(byItem,sel_implementsHyperInterface_,&DAT_0037027c);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(byItem,sel_itemUID,puVar3);
      pvVar2 = _objc_msgSend(setObjectValue,sel_integerValue);
      self_00 = _objc_msgSend(self,sel_playSoundActionApplier);
      op = sel_removeSoundUIDToStop_;
      if (pvVar2 == (id)0x1) {
        op = sel_addSoundUIDToStop_withFadeOutTime_;
      }
      _objc_msgSend(self_00,op,pvVar1);
    }
  }
  return;
}

*/
- (void)outlineView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn byItem:(id)aItem
{
    id itemUID;
    NSInteger state;

    if ([[aColumn identifier] isEqualToString:@"sound"]
        && [aItem implementsHyperInterface:@protocol(HSSoundItemAttributes)]) {
        itemUID = [aItem itemUID];
        state = [aValue integerValue];
        if (state == 1) {
            [[self playSoundActionApplier] addSoundUIDToStop:itemUID withFadeOutTime:0.0];
        }
        else {
            [[self playSoundActionApplier] removeSoundUIDToStop:itemUID];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00109d1f @ 00109d1f, 188 bytes * /

id FUN_00109d1f(HSPlaySoundActionAssistantPane *self,SEL _cmd,id outlineView,
               id objectValueForTableColumn,id byItem)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_sound);
  if ((char)pvVar1 == '\0') {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(byItem,sel_implementsHyperInterface_,&DAT_00370178);
    if (((char)pvVar1 != '\0') ||
       (pvVar1 = _objc_msgSend(byItem,sel_implementsHyperInterface_,&DAT_003701c8),
       op = sel_HSPlaySoundActionAssistantPane_stateForItem_, (char)pvVar1 != '\0')) {
      op = sel_HSPlaySoundActionAssistantPane_titleForItem_;
    }
    pvVar1 = _objc_msgSend(self,op,byItem);
  }
  return pvVar1;
}

*/
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem
{
    if (![[aColumn identifier] isEqualToString:@"sound"]) {
        return nil;
    }
    if ([aItem implementsHyperInterface:@protocol(HSCardAttributes)]
        || [aItem implementsHyperInterface:@protocol(HSStackAttributes)]) {
        return [self HSPlaySoundActionAssistantPane_titleForItem:aItem];
    }
    return [self HSPlaySoundActionAssistantPane_stateForItem:aItem];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00109ddb @ 00109ddb, 143 bytes * /

BOOL FUN_00109ddb(HSPlaySoundActionAssistantPane *self,SEL _cmd,id outlineView,id isItemExpandable)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(isItemExpandable,sel_implementsHyperInterface_,&DAT_00370178);
  if (((char)pvVar1 == '\0') &&
     (pvVar1 = _objc_msgSend(isItemExpandable,sel_implementsHyperInterface_,&DAT_003701c8),
     (char)pvVar1 == '\0')) {
    return '\0';
  }
  pvVar1 = _objc_msgSend(self,sel_HSPlaySoundActionAssistantPane_availableSoundsInNode_,
                         isItemExpandable);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  return pvVar1 != (id)0x0;
}

*/
- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable
{
    if (![aExpandable implementsHyperInterface:@protocol(HSCardAttributes)]
        && ![aExpandable implementsHyperInterface:@protocol(HSStackAttributes)]) {
        return NO;
    }
    return [[self HSPlaySoundActionAssistantPane_availableSoundsInNode:aExpandable] count] != 0;
}

- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem
{
    id pvVar1;

    if (aItem == nil) {
        pvVar1 = [self HSPlaySoundActionAssistantPane_availableNodes];
    }
    else {
        pvVar1 = [self HSPlaySoundActionAssistantPane_availableSoundsInNode:aItem];
        aChild = ~aChild + (int)[pvVar1 count];
    }
    return [pvVar1 objectAtIndex:aChild];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00109ef7 @ 00109ef7, 81 bytes * /

int FUN_00109ef7(HSPlaySoundActionAssistantPane *self,SEL _cmd,id outlineView,
                id numberOfChildrenOfItem)

{
  id pvVar1;
  SEL op;
  
  op = sel_HSPlaySoundActionAssistantPane_availableSoundsInNode_;
  if (numberOfChildrenOfItem == (id)0x0) {
    op = sel_HSPlaySoundActionAssistantPane_availableNodes;
  }
  pvVar1 = _objc_msgSend(self,op);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  return (int)pvVar1;
}

*/
- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem
{
    if (aItem == nil) {
        return [[self HSPlaySoundActionAssistantPane_availableNodes] count];
    }
    return [[self HSPlaySoundActionAssistantPane_availableSoundsInNode:aItem] count];
}

- (void)HSPlaySoundActionAssistantPane_cardTitleDidChange:(id)aChange
{
    id pvVar1_3;

    if ([self isVisible]) {
        pvVar1_3 = [[aChange object] queryHyperInterface:@protocol(HSNodeContainer)];
        if (pvVar1_3 != nil) {
            [_availableSoundsOutlineView reloadItem:pvVar1_3];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00109fc7 @ 00109fc7, 969 bytes * /

void FUN_00109fc7(HSPlaySoundActionAssistantPane *self,SEL _cmd,
                 id HSPlaySoundActionAssistantPane_cardsDidChange)

{
  int iVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 *puVar6;
  id pvVar7;
  undefined4 uVar8;
  undefined1 *puVar9;
  undefined4 uVar10;
  id local_dc;
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined1 local_b4 [64];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar3 = _objc_msgSend(HSPlaySoundActionAssistantPane_cardsDidChange,sel_userInfo);
  pvVar4 = _objc_msgSend(pvVar3,sel_valueForKey_,&cfstr_HSNodeChildrenForAddition);
  local_d4 = 0;
  local_d0 = 0;
  local_cc = (int *)0x0;
  local_c8 = 0;
  local_c4 = 0;
  local_c0 = 0;
  local_bc = 0;
  local_b8 = 0;
  puVar9 = local_b4;
  uVar10 = 0x10;
  local_dc = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_d4,puVar9,
                           0x10);
  if (local_dc != (id)0x0) {
    iVar1 = *local_cc;
    do {
      pvVar7 = (id)0x0;
      do {
        if (iVar1 != *local_cc) {
          _objc_enumerationMutation(pvVar4);
        }
        uVar2 = *(undefined4 *)(local_d0 + (int)pvVar7 * 4);
        uVar8 = uVar2;
        pvVar5 = _objc_msgSend(self,sel_HSPlaySoundActionAssistantPane_hasSoundsInNode_,uVar2,puVar9
                               ,uVar10);
        if ((char)pvVar5 != '\0') {
          pvVar5 = _objc_msgSend(self,sel_HSPlaySoundActionAssistantPane_availableNodes,uVar8);
          _objc_msgSend(pvVar5,sel_addObject_,uVar2);
          _objc_msgSend(self,sel_HSPlaySoundActionAssistantPane_availableSoundsInNode_,uVar2);
        }
        pvVar7 = (id)((int)pvVar7 + 1);
      } while (pvVar7 < local_dc);
      puVar9 = local_b4;
      uVar10 = 0x10;
      local_dc = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_d4,
                               puVar9,0x10);
    } while (local_dc != (id)0x0);
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_valueForKey_,&cfstr_HSNodeChildrenForRemoval,puVar9,uVar10);
  pvVar4 = _objc_msgSend(self,sel_assistant);
  pvVar4 = _objc_msgSend(pvVar4,sel_object);
  pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00370524);
  pvVar7 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar4);
  if ((char)pvVar7 == '\0') {
    local_74 = 0;
    local_70 = 0;
    local_6c = (int *)0x0;
    local_68 = 0;
    local_64 = 0;
    local_60 = 0;
    local_5c = 0;
    local_58 = 0;
    puVar9 = local_50;
    puVar6 = &local_74;
    uVar10 = 0x10;
    local_dc = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar6,puVar9,
                             0x10);
    if (local_dc != (id)0x0) {
      iVar1 = *local_6c;
      do {
        pvVar4 = (id)0x0;
        do {
          if (iVar1 != *local_6c) {
            _objc_enumerationMutation(pvVar3);
          }
          if (self->_availableSoundsInNodes != (CFDictionary *)0x0) {
            uVar10 = *(undefined4 *)(local_70 + (int)pvVar4 * 4);
            _CFDictionaryRemoveValue(self->_availableSoundsInNodes,uVar10);
            pvVar7 = _objc_msgSend(self,sel_HSPlaySoundActionAssistantPane_availableNodes);
            _objc_msgSend(pvVar7,sel_removeObject_,uVar10);
          }
          pvVar4 = (id)((int)pvVar4 + 1);
        } while (pvVar4 < local_dc);
        puVar9 = local_50;
        puVar6 = &local_74;
        uVar10 = 0x10;
        local_dc = _objc_msgSend(pvVar3,sel_countByEnumeratingWithState_objects_count_,puVar6,puVar9
                                 ,0x10);
      } while (local_dc != (id)0x0);
    }
  }
  else {
    puVar6 = _objc_msgSend(HSPlaySoundActionAssistantPane_cardsDidChange,sel_object,pvVar4);
    _objc_msgSend(self,sel_stopObserveNotification_,puVar6);
  }
  _objc_msgSend(self->_availableSoundsOutlineView,sel_reloadData,puVar6,puVar9,uVar10);
  return;
}

*/
- (void)HSPlaySoundActionAssistantPane_cardsDidChange:(id)aChange
{
    NSDictionary *userInfo;
    id removed;
    id node;

    userInfo = [aChange userInfo];
    for (node in [userInfo valueForKey:@"HSNodeChildrenForAddition"]) {
        if ([self HSPlaySoundActionAssistantPane_hasSoundsInNode:node]) {
            [[self HSPlaySoundActionAssistantPane_availableNodes] addObject:node];
            // Primes the sounds cache for the new node.
            [self HSPlaySoundActionAssistantPane_availableSoundsInNode:node];
        }
    }
    removed = [userInfo valueForKey:@"HSNodeChildrenForRemoval"];
    if ([removed containsObject:[[[self assistant] object] queryHyperInterface:@protocol(HSNodeChild)]]) {
        [self stopObserveNotification:[aChange object]];
    }
    else {
        for (node in removed) {
            if (_availableSoundsInNodes != NULL) {
                CFDictionaryRemoveValue(_availableSoundsInNodes, node);
                [[self HSPlaySoundActionAssistantPane_availableNodes] removeObject:node];
            }
        }
    }
    [_availableSoundsOutlineView reloadData];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010a390 @ 0010a390, 853 bytes * /

void FUN_0010a390(HSPlaySoundActionAssistantPane *self,SEL _cmd,
                 id HSPlaySoundActionAssistantPane_objectsWillChange)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  id self_00;
  id pvVar6;
  undefined1 *puVar7;
  undefined4 uVar8;
  id local_80;
  id local_7c;
  cfstringStruct local_74;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(HSPlaySoundActionAssistantPane_objectsWillChange,sel_object);
  pvVar3 = _objc_msgSend(HSPlaySoundActionAssistantPane_objectsWillChange,sel_userInfo);
  local_7c = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSNodeChildrenForRemoval);
  pvVar4 = _objc_msgSend(self,sel_assistant);
  pvVar4 = _objc_msgSend(pvVar4,sel_object);
  pcVar5 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00370524);
  pvVar4 = _objc_msgSend(local_7c,sel_containsObject_,pcVar5);
  if ((char)pvVar4 == '\0') {
    pvVar4 = _objc_msgSend(self,sel_card,pcVar5);
    if (pvVar2 == pvVar4) {
      pvVar4 = _objc_msgSend(local_7c,sel_count,pcVar5);
      if (pvVar4 == (id)0x0) {
        pcVar5 = &cfstr_HSNodeChildrenForAddition;
        local_7c = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSNodeChildrenForAddition);
      }
      pvVar3 = _objc_msgSend(local_7c,sel_count,pcVar5);
      if ((pvVar3 != (id)0x0) && (self->_availableSoundsInNodes != (CFDictionary *)0x0)) {
        pvVar3 = (id)_CFDictionaryGetValue(self->_availableSoundsInNodes,pvVar2);
        pvVar4 = _objc_msgSend(pvVar3,sel_count,pcVar5);
        if (pvVar4 != (id)0x0) {
          local_74.field0_0x0 = 0;
          local_74.field1_0x4 = 0;
          local_74.field2_0x8 = (undefined *)0x0;
          local_74.field3_0xc = 0;
          local_64 = 0;
          local_60 = 0;
          local_5c = 0;
          local_58 = 0;
          puVar7 = local_50;
          pcVar5 = &local_74;
          uVar8 = 0x10;
          local_80 = _objc_msgSend(local_7c,sel_countByEnumeratingWithState_objects_count_,pcVar5,
                                   puVar7,0x10);
          if (local_80 != (id)0x0) {
            iVar1 = *(int *)local_74.field2_0x8;
            do {
              pvVar4 = (id)0x0;
              do {
                if (iVar1 != *(int *)local_74.field2_0x8) {
                  _objc_enumerationMutation(local_7c);
                }
                pcVar5 = *(cfstringStruct **)(local_74.field1_0x4 + (int)pvVar4 * 4);
                self_00 = _objc_msgSend(self,sel_HSPlaySoundActionAssistantPane_soundsForNode_,
                                        pcVar5,puVar7,uVar8);
                pvVar6 = _objc_msgSend(self_00,sel_count);
                if (pvVar6 != (id)0x0) {
                  pvVar6 = _objc_msgSend(pvVar3,sel_mutableCopy,pcVar5);
                  if (pvVar6 == (id)0x0) goto LAB_0010a6a6;
                  _objc_msgSend(pvVar6,sel_removeObjectsInArray_,self_00);
                  _CFDictionaryReplaceValue(self->_availableSoundsInNodes,pvVar2,pvVar6);
                  _objc_msgSend(pvVar6,sel_release);
                }
                pvVar4 = (id)((int)pvVar4 + 1);
              } while (pvVar4 < local_80);
              puVar7 = local_50;
              pcVar5 = &local_74;
              uVar8 = 0x10;
              local_80 = _objc_msgSend(local_7c,sel_countByEnumeratingWithState_objects_count_,
                                       pcVar5,puVar7,0x10);
            } while (local_80 != (id)0x0);
          }
        }
      }
    }
  }
  else {
    pcVar5 = _objc_msgSend(self,sel_stack,pcVar5);
    _objc_msgSend(self,sel_stopObserveNotification_,pcVar5);
  }
LAB_0010a6a6:
  pvVar2 = _objc_msgSend(self,sel_isVisible,pcVar5);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self->_availableSoundsOutlineView,sel_reloadData,pcVar5);
  }
  return;
}

*/
- (void)HSPlaySoundActionAssistantPane_objectsWillChange:(id)aChange
{
    id changedNode;
    NSDictionary *userInfo;
    id children;
    id cached;
    id child;
    id sounds;
    id remaining;

    changedNode = [aChange object];
    userInfo = [aChange userInfo];
    children = [userInfo objectForKey:@"HSNodeChildrenForRemoval"];
    if ([children containsObject:[[[self assistant] object] queryHyperInterface:@protocol(HSNodeChild)]]) {
        [self stopObserveNotification:[self stack]];
    }
    else if (changedNode == [self card]) {
        if ([children count] == 0) {
            children = [userInfo objectForKey:@"HSNodeChildrenForAddition"];
        }
        if ([children count] != 0 && _availableSoundsInNodes != NULL) {
            cached = (id)CFDictionaryGetValue(_availableSoundsInNodes, changedNode);
            if ([cached count] != 0) {
                for (child in children) {
                    sounds = [self HSPlaySoundActionAssistantPane_soundsForNode:child];
                    if ([sounds count] != 0) {
                        // The original always copies the dictionary's initial array, so each
                        // pass only strips the current child's sounds from that array.
                        remaining = [cached mutableCopy];
                        if (remaining == nil) break;
                        [remaining removeObjectsInArray:sounds];
                        CFDictionaryReplaceValue(_availableSoundsInNodes, changedNode, remaining);
                        [remaining release];
                    }
                }
            }
        }
    }
    if ([self isVisible]) {
        [_availableSoundsOutlineView reloadData];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010a6e5 @ 0010a6e5, 270 bytes * /

void FUN_0010a6e5(HSPlaySoundActionAssistantPane *self,SEL _cmd,
                 id HSPlaySoundActionAssistantPane_objectAttributeDidChange)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  undefined8 local_24;
  undefined8 local_1c;
  
  _objc_msgSend_stret(&local_24,self->_availableSoundsOutlineView,sel_visibleRect);
  cVar1 = _NSEqualRects(local_24,local_1c,*(undefined8 *)PTR_00336078,
                        *(undefined8 *)(PTR_00336078 + 8));
  if (cVar1 == '\0') {
    pvVar2 = _objc_msgSend(HSPlaySoundActionAssistantPane_objectAttributeDidChange,sel_object);
    pvVar3 = _objc_msgSend(self,sel_applier);
    pvVar3 = _objc_msgSend(pvVar3,sel_object);
    if (pvVar2 != pvVar3) {
      _objc_msgSend(self->_availableNodes,sel_release);
      self->_availableNodes = (id)0x0;
      if (self->_availableSoundsInNodes != (CFDictionary *)0x0) {
        _CFRelease(self->_availableSoundsInNodes);
        self->_availableSoundsInNodes = (CFDictionary *)0x0;
      }
      _objc_msgSend(self->_availableSoundsOutlineView,sel_reloadData);
    }
  }
  return;
}

*/
- (void)HSPlaySoundActionAssistantPane_objectAttributeDidChange:(id)aChange
{
    if (NSEqualRects([_availableSoundsOutlineView visibleRect], NSZeroRect)) {
        return;
    }
    if ([aChange object] != [[self applier] object]) {
        [_availableNodes release];
        _availableNodes = nil;
        if (_availableSoundsInNodes != NULL) {
            CFRelease(_availableSoundsInNodes);
            _availableSoundsInNodes = NULL;
        }
        [_availableSoundsOutlineView reloadData];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010a7f3 @ 0010a7f3, 753 bytes * /

id FUN_0010a7f3(HSPlaySoundActionAssistantPane *self,SEL _cmd,
               id HSPlaySoundActionAssistantPane_titleForItem)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL pcVar5;
  float extraout_EDX;
  double dVar6;
  undefined *puVar7;
  undefined4 uVar8;
  id local_24;
  
  self_00 = _objc_msgSend(HSPlaySoundActionAssistantPane_titleForItem,sel_queryHyperInterface_,
                          &DAT_003701c8);
  puVar7 = &DAT_00370178;
  pvVar1 = _objc_msgSend(HSPlaySoundActionAssistantPane_titleForItem,sel_queryHyperInterface_,
                         &DAT_00370178);
  pvVar2 = pvVar1;
  pcVar5 = sel_hyperTitle;
  if (pvVar1 == (id)0x0) {
    if (self_00 == (id)0x0) {
      pvVar2 = _objc_msgSend(HSPlaySoundActionAssistantPane_titleForItem,sel_soundItemName,puVar7);
      pcVar5 = sel_stringByDeletingPathExtension;
    }
    else {
      pvVar2 = _objc_msgSend(self_00,sel_document,puVar7);
      pcVar5 = sel_displayName;
    }
  }
  pvVar2 = _objc_msgSend(pvVar2,pcVar5,puVar7);
  if (pvVar2 == (id)0x0) {
LAB_0010a8aa:
    local_24 = (id)0x0;
  }
  else {
    if (self->_objectNameParagraphStyle == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSParagraphStyle,sel_defaultParagraphStyle,puVar7);
      pvVar3 = _objc_msgSend(pvVar3,sel_mutableCopy);
      self->_objectNameParagraphStyle = pvVar3;
      if (pvVar3 == (id)0x0) goto LAB_0010a8aa;
      dVar6 = _objc_msgSend_fpret(self->_availableSoundsOutlineView,sel_rowHeight);
      pvVar4 = _objc_msgSend(self->_availableSoundsOutlineView,sel_outlineTableColumn);
      pvVar4 = _objc_msgSend(pvVar4,sel_dataCell);
      _objc_msgSend(pvVar4,sel_cellSize);
      _objc_msgSend(pvVar3,sel_setMinimumLineHeight_,(extraout_EDX + (float)dVar6) * 0.5);
      puVar7 = (undefined *)0x4;
      _objc_msgSend(self->_objectNameParagraphStyle,sel_setLineBreakMode_,4);
    }
    pvVar3 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc,puVar7);
    pvVar3 = _objc_msgSend(pvVar3,sel_initWithString_,pvVar2);
    local_24 = _objc_msgSend(pvVar3,sel_autorelease);
    if (local_24 != (id)0x0) {
      pvVar4 = _objc_msgSend(local_24,sel_length,pvVar2);
      pvVar2 = self->_objectNameParagraphStyle;
      uVar8 = 0;
      pvVar3 = pvVar4;
      _objc_msgSend(local_24,sel_addAttribute_value_range_,*(undefined4 *)PTR_00336150,pvVar2,0,
                    pvVar4);
      dVar6 = _objc_msgSend_fpret(cls_NSFont,sel_systemFontSizeForControlSize_,1);
      pcVar5 = sel_systemFontOfSize_;
      if (pvVar1 != (id)0x0 || self_00 != (id)0x0) {
        pcVar5 = sel_boldSystemFontOfSize_;
      }
      pvVar2 = _objc_msgSend(cls_NSFont,pcVar5,(float)dVar6,pvVar2,uVar8,pvVar3);
      if (pvVar2 != (id)0x0) {
        _objc_msgSend(local_24,sel_addAttribute_value_range_,*(undefined4 *)PTR_00336068,pvVar2,0,
                      pvVar4);
      }
    }
  }
  return local_24;
}

*/
- (id)HSPlaySoundActionAssistantPane_titleForItem:(id)aItem
{
    id stack;
    id card;
    NSString *title;
    NSMutableAttributedString *attributedTitle;
    NSUInteger length;
    CGFloat fontSize;
    NSFont *font;

    stack = [aItem queryHyperInterface:@protocol(HSStackAttributes)];
    card = [aItem queryHyperInterface:@protocol(HSCardAttributes)];
    if (card != nil) {
        title = [card hyperTitle];
    }
    else if (stack != nil) {
        title = [[stack document] displayName];
    }
    else {
        title = [[aItem soundItemName] stringByDeletingPathExtension];
    }
    if (title == nil) {
        return nil;
    }
    if (_objectNameParagraphStyle == nil) {
        _objectNameParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        if (_objectNameParagraphStyle == nil) {
            return nil;
        }
        [_objectNameParagraphStyle setMinimumLineHeight:([_availableSoundsOutlineView rowHeight] + [[[_availableSoundsOutlineView outlineTableColumn] dataCell] cellSize].height) * 0.5];
        [_objectNameParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    }
    attributedTitle = [[[NSMutableAttributedString alloc] initWithString:title] autorelease];
    if (attributedTitle != nil) {
        length = [attributedTitle length];
        [attributedTitle addAttribute:NSParagraphStyleAttributeName value:_objectNameParagraphStyle range:NSMakeRange(0, length)];
        fontSize = [NSFont systemFontSizeForControlSize:NSControlSizeSmall];
        if (card != nil || stack != nil) {
            font = [NSFont boldSystemFontOfSize:fontSize];
        }
        else {
            font = [NSFont systemFontOfSize:fontSize];
        }
        if (font != nil) {
            [attributedTitle addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, length)];
        }
    }
    return attributedTitle;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010aae4 @ 0010aae4, 179 bytes * /

id FUN_0010aae4(HSPlaySoundActionAssistantPane *self,SEL _cmd,
               id HSPlaySoundActionAssistantPane_stateForItem)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = _objc_msgSend(self->_stopAllSoundsSwitch,sel_state);
  if (pvVar2 != (id)0x1) {
    pvVar1 = _objc_msgSend(pvVar1,sel_soundsToStop);
    pvVar2 = _objc_msgSend(HSPlaySoundActionAssistantPane_stateForItem,sel_itemUID);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,pvVar2);
    if (pvVar1 == (id)0x0) {
      uVar3 = 0;
      goto LAB_0010ab73;
    }
  }
  uVar3 = 1;
LAB_0010ab73:
  pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInteger_,uVar3);
  return pvVar1;
}

*/
- (id)HSPlaySoundActionAssistantPane_stateForItem:(id)aItem
{
    id attributes;
    NSInteger state;

    attributes = [self actionAttributes];
    if ([_stopAllSoundsSwitch state] == NSControlStateValueOn) {
        state = 1;
    }
    else {
        state = [[attributes soundsToStop] objectForKey:[aItem itemUID]] != nil;
    }
    return [NSNumber numberWithInteger:state];
}

- (id)HSPlaySoundActionAssistantPane_availableNodes
{
    id pvVar2;
    id pvVar3;
    NSUInteger pvVar1_5;
    id pvVar2_2;
    NSUInteger pvVar3_2;
    id pvVar4_3;

    if (_availableNodes == nil) {
        if ([_soundsOnThisCardSwitch state] == 0) {
            _availableNodes = [NSMutableArray new];
            pvVar2 = [self stack];
            pvVar3 = [pvVar2 queryHyperInterface:@protocol(HSNodeContainer)];
            if ([self HSPlaySoundActionAssistantPane_hasSoundsInNode:pvVar3]) {
                [_availableNodes addObject:pvVar3];
            }
            pvVar1_5 = [pvVar2 hyperCount];
            if (pvVar1_5 != 0) {
                pvVar3_2 = 0;
                do {
                    pvVar4_3 = [[pvVar2 hyperChildAtIndex:pvVar3_2] queryHyperInterface:@protocol(HSNodeContainer)];
                    if ([self HSPlaySoundActionAssistantPane_hasSoundsInNode:pvVar4_3]) {
                        [_availableNodes addObject:pvVar4_3];
                    }
                    pvVar3_2 = (pvVar3_2 + 1);
                } while (pvVar3_2 < pvVar1_5);
            }
        }
        else {
            pvVar2_2 = [[self card] queryHyperInterface:@protocol(HSNodeContainer)];
            if ([self HSPlaySoundActionAssistantPane_hasSoundsInNode:pvVar2_2]) {
                _availableNodes = [[NSMutableArray alloc] initWithObjects:pvVar2_2, nil];
            }
        }
    }
    return _availableNodes;
}

- (BOOL)HSPlaySoundActionAssistantPane_hasSoundsInNode:(id)aNode
{
    BOOL bVar2;

    if ([[self HSPlaySoundActionAssistantPane_soundsForNode:aNode] count] == 0) {
        bVar2 = [[self HSPlaySoundActionAssistantPane_availableSoundsInNode:aNode] count] != 0;
    }
    else {
        bVar2 = YES;
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010ae22 @ 0010ae22, 540 bytes * /

id FUN_0010ae22(HSPlaySoundActionAssistantPane *self,SEL _cmd,
               id HSPlaySoundActionAssistantPane_availableSoundsInNode)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *self_00;
  CFDictionary *pCVar7;
  SEL op;
  undefined *puVar8;
  undefined *puVar9;
  
  if ((self->_availableSoundsInNodes == (CFDictionary *)0x0) ||
     (pvVar1 = (id)_CFDictionaryGetValue
                             (self->_availableSoundsInNodes,
                              HSPlaySoundActionAssistantPane_availableSoundsInNode),
     pvVar1 == (id)0x0)) {
    pvVar1 = HSPlaySoundActionAssistantPane_availableSoundsInNode;
    pvVar2 = _objc_msgSend(self,sel_HSPlaySoundActionAssistantPane_soundsForNode_,
                           HSPlaySoundActionAssistantPane_availableSoundsInNode);
    pvVar3 = _objc_msgSend(pvVar2,sel_count);
    op = sel_array;
    if (pvVar3 != (id)0x0) {
      op = sel_arrayWithArray_;
      pvVar1 = pvVar2;
    }
    pvVar1 = _objc_msgSend(cls_NSMutableArray,op,pvVar1);
    if (pvVar1 != (id)0x0) {
      puVar9 = &DAT_00370178;
      pvVar2 = _objc_msgSend(HSPlaySoundActionAssistantPane_availableSoundsInNode,
                             sel_implementsHyperInterface_,&DAT_00370178);
      if ((char)pvVar2 != '\0') {
        pvVar2 = _objc_msgSend(self,sel_assistant,puVar9);
        pvVar2 = _objc_msgSend(pvVar2,sel_object);
        puVar9 = &DAT_00370524;
        puVar4 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00370524);
        puVar5 = _objc_msgSend(HSPlaySoundActionAssistantPane_availableSoundsInNode,sel_hyperCount);
        if (puVar5 != (undefined *)0x0) {
          puVar8 = (undefined *)0x0;
          do {
            puVar9 = puVar8;
            puVar6 = _objc_msgSend(HSPlaySoundActionAssistantPane_availableSoundsInNode,
                                   sel_hyperChildAtIndex_,puVar8);
            if (puVar4 != puVar6) {
              self_00 = _objc_msgSend(self,sel_HSPlaySoundActionAssistantPane_soundsForNode_,puVar6)
              ;
              pvVar2 = _objc_msgSend(self_00,sel_count);
              puVar9 = puVar6;
              if (pvVar2 != (id)0x0) {
                _objc_msgSend(pvVar1,sel_addObjectsFromArray_,self_00);
                puVar9 = self_00;
              }
            }
            puVar8 = puVar8 + 1;
          } while (puVar8 < puVar5);
        }
      }
      pvVar2 = _objc_msgSend(pvVar1,sel_count,puVar9);
      if (pvVar2 != (id)0x0) {
        pCVar7 = self->_availableSoundsInNodes;
        if (pCVar7 == (CFDictionary *)0x0) {
          pCVar7 = (CFDictionary *)
                   _CFDictionaryCreateMutable
                             (*(undefined4 *)PTR_003363a4,0,PTR_00336510,PTR_00336514);
          self->_availableSoundsInNodes = pCVar7;
          if (pCVar7 == (CFDictionary *)0x0) {
            return pvVar1;
          }
        }
        _CFDictionarySetValue(pCVar7,HSPlaySoundActionAssistantPane_availableSoundsInNode,pvVar1);
      }
    }
  }
  return pvVar1;
}

*/
- (id)HSPlaySoundActionAssistantPane_availableSoundsInNode:(id)aNode
{
    NSMutableArray *sounds;
    id nodeSounds;
    id ownNode;
    NSUInteger count;
    NSUInteger index;
    id child;
    id childSounds;

    if (_availableSoundsInNodes != NULL) {
        sounds = (id)CFDictionaryGetValue(_availableSoundsInNodes, aNode);
        if (sounds != nil) {
            return sounds;
        }
    }
    nodeSounds = [self HSPlaySoundActionAssistantPane_soundsForNode:aNode];
    if ([nodeSounds count] != 0) {
        sounds = [NSMutableArray arrayWithArray:nodeSounds];
    }
    else {
        sounds = [NSMutableArray array];
    }
    if (sounds == nil) {
        return nil;
    }
    if ([aNode implementsHyperInterface:@protocol(HSCardAttributes)]) {
        // The object being edited is skipped so its own sounds are not offered.
        ownNode = [[[self assistant] object] queryHyperInterface:@protocol(HSNodeChild)];
        count = [aNode hyperCount];
        for (index = 0; index < count; index++) {
            child = [aNode hyperChildAtIndex:index];
            if (ownNode != child) {
                childSounds = [self HSPlaySoundActionAssistantPane_soundsForNode:child];
                if ([childSounds count] != 0) {
                    [sounds addObjectsFromArray:childSounds];
                }
            }
        }
    }
    if ([sounds count] != 0) {
        if (_availableSoundsInNodes == NULL) {
            _availableSoundsInNodes = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFEWeakObjectPointerDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            if (_availableSoundsInNodes == NULL) {
                return sounds;
            }
        }
        CFDictionarySetValue(_availableSoundsInNodes, aNode, sounds);
    }
    return sounds;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010b03e @ 0010b03e, 437 bytes * /

id FUN_0010b03e(HSPlaySoundActionAssistantPane *self,SEL _cmd,
               id HSPlaySoundActionAssistantPane_soundsForNode)

{
  int iVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined1 *puVar6;
  undefined4 uVar7;
  id local_7c;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar2 = _objc_msgSend(HSPlaySoundActionAssistantPane_soundsForNode,sel_queryHyperInterface_,
                         &DAT_00370060);
  pvVar3 = _objc_msgSend(self,sel_actionType);
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperActionsOfType_,pvVar3);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar6 = local_50;
  uVar7 = 0x10;
  local_7c = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,puVar6,
                           0x10);
  if (local_7c != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar3 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(pvVar2);
        }
        pvVar4 = _objc_msgSend(*(id *)(local_70 + (int)pvVar3 * 4),sel_queryHyperInterface_,
                               &DAT_003704ac,puVar6,uVar7);
        pvVar4 = _objc_msgSend(pvVar4,sel_sounds);
        pvVar5 = _objc_msgSend(pvVar4,sel_count);
        if (pvVar5 != (id)0x0) {
          _objc_msgSend(self_00,sel_addObjectsFromArray_,pvVar4);
        }
        pvVar3 = (id)((int)pvVar3 + 1);
      } while (pvVar3 < local_7c);
      puVar6 = local_50;
      uVar7 = 0x10;
      local_7c = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,
                               puVar6,0x10);
    } while (local_7c != (id)0x0);
  }
  return self_00;
}

*/
- (id)HSPlaySoundActionAssistantPane_soundsForNode:(id)aNode
{
    NSMutableArray *result;
    id action;
    id sounds;

    result = [NSMutableArray array];
    for (action in [[aNode queryHyperInterface:@protocol(HSActor)] hyperActionsOfType:[self actionType]]) {
        sounds = [[action queryHyperInterface:@protocol(HSPlaySoundActionAttributes)] sounds];
        if ([sounds count] != 0) {
            [result addObjectsFromArray:sounds];
        }
    }
    return result;
}

- (id)tableView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn row:(NSInteger)aRow mouseLocation:(NSPoint)aLocation
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Select a sound to be played." value:@"" table:@"AssistantPanes"];
}

- (void)tableViewSelectionDidChange:(id)aChange
{
    [_previewSoundObject stop];
    [_previewSoundObject gotoBeginning];
    [self updateSoundPlaybackAttributes];
    [self validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010b2ba @ 0010b2ba, 245 bytes * /

void FUN_0010b2ba(HSPlaySoundActionAssistantPane *self,SEL _cmd,id tableView,id setObjectValue,
                 id forTableColumn,int row)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  SEL op;
  cfstringStruct *pcVar3;
  
  pvVar1 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar3 = &cfstr_SoundSwitchTableColumn;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_SoundSwitchTableColumn);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_actionAttributes,pcVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_sounds);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
    pvVar2 = _objc_msgSend(setObjectValue,sel_boolValue);
    self_00 = _objc_msgSend(self,sel_actionAttributes);
    op = sel_disableSoundItem_;
    if ((char)pvVar2 != '\0') {
      op = sel_enableSoundItem_;
    }
    _objc_msgSend(self_00,op,pvVar1);
    _objc_msgSend(self,sel_validateUserInterface);
  }
  return;
}

*/
- (void)tableView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id soundItem;

    if ([[aColumn identifier] isEqual:@"SoundSwitchTableColumn"]) {
        soundItem = [[[self actionAttributes] sounds] objectAtIndex:aRow];
        if ([aValue boolValue]) {
            [[self actionAttributes] enableSoundItem:soundItem];
        }
        else {
            [[self actionAttributes] disableSoundItem:soundItem];
        }
        [self validateUserInterface];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010b3af @ 0010b3af, 663 bytes * /

id FUN_0010b3af(HSPlaySoundActionAssistantPane *self,SEL _cmd,id tableView,
               id objectValueForTableColumn,int row)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  SEL op;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_sounds);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
  puVar3 = &DAT_003703bc;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003703bc);
  if (pvVar1 == (id)0x0) {
LAB_0010b63c:
    pvVar1 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,puVar3);
    pcVar4 = &cfstr_SoundSwitchTableColumn;
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_SoundSwitchTableColumn);
    if ((char)pvVar2 == '\0') {
      pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar4);
      pcVar4 = &cfstr_SoundNameTableColumn;
      pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_SoundNameTableColumn);
      if ((char)pvVar2 == '\0') {
        pvVar2 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar4);
        pcVar4 = &cfstr_SoundDurationTableColumn;
        pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,&cfstr_SoundDurationTableColumn);
        puVar3 = cls_NSCalendarDate;
        if ((char)pvVar2 == '\0') goto LAB_0010b63c;
        pvVar1 = _objc_msgSend(pvVar1,sel_sound,pcVar4);
        _objc_msgSend_fpret(pvVar1,sel_duration);
        pvVar1 = (id)0x0;
        op = sel_dateWithYear_month_day_hour_minute_second_timeZone_;
      }
      else {
        pvVar2 = _objc_msgSend(cls_HSNewMediaAccessor,sel_sharedMediaAccessor,pcVar4);
        pvVar1 = _objc_msgSend(pvVar1,sel_mediaUID);
        pvVar2 = _objc_msgSend(pvVar2,sel_mediaForUID_,pvVar1);
        puVar3 = _objc_msgSend(pvVar2,sel_mediaName);
        op = sel_stringByDeletingPathExtension;
      }
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_actionAttributes,pcVar4);
      pvVar1 = _objc_msgSend(pvVar1,sel_sounds);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,row);
      puVar3 = cls_NSNumber;
      pvVar1 = _objc_msgSend(pvVar1,sel_isEnabled);
      pvVar1 = (id)((uint)pvVar1 & 0xff);
      op = sel_numberWithBool_;
    }
    pvVar1 = _objc_msgSend(puVar3,op,pvVar1);
  }
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    id playback;

    playback = [[[[self actionAttributes] sounds] objectAtIndex:aRow] queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
    if (playback == nil) {
        return nil;
    }
    if ([[aColumn identifier] isEqual:@"SoundSwitchTableColumn"]) {
        return [NSNumber numberWithBool:[[[[self actionAttributes] sounds] objectAtIndex:aRow] isEnabled]];
    }
    if ([[aColumn identifier] isEqual:@"SoundNameTableColumn"]) {
        return [[[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[playback mediaUID]] mediaName] stringByDeletingPathExtension];
    }
    if ([[aColumn identifier] isEqual:@"SoundDurationTableColumn"]) {
        return [NSCalendarDate dateWithYear:0 month:0 day:0 hour:0 minute:0 second:(NSUInteger)[(HSMovie *)[playback sound] duration] timeZone:nil];
    }
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[[[self actionAttributes] sounds] count];
}

- (void)switchOptionView:(id)aView
{
    [self switchToOptionViewWithTag:[_segmentedControl selectedTag]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010b6d8 @ 0010b6d8, 262 bytes * /

void FUN_0010b6d8(HSPlaySoundActionAssistantPane *self,SEL _cmd,int switchToOptionViewWithTag)

{
  id pvVar1;
  SEL op;
  id pvVar2;
  
  if (switchToOptionViewWithTag == 1) {
    pvVar1 = self->_soundsToPlayView;
    pvVar2 = self->_soundsToStopView;
    _objc_msgSend(self->_optionsView,sel_replaceSubview_with_,pvVar1,pvVar2);
    _objc_msgSend(self->_availableSoundsOutlineView,sel_reloadData);
    op = sel_updateStopSoundPlaybackAttributes;
  }
  else {
    if (switchToOptionViewWithTag != 0) goto LAB_0010b7c4;
    pvVar1 = _objc_msgSend(self,sel_suggestedContentView);
    _objc_msgSend(self,sel_mountContentView_,pvVar1);
    pvVar1 = self->_soundsToStopView;
    pvVar2 = self->_soundsToPlayView;
    _objc_msgSend(self->_optionsView,sel_replaceSubview_with_,pvVar1,pvVar2);
    _objc_msgSend(self->_soundChooserTableView,sel_reloadData);
    op = sel_updateSoundPlaybackAttributes;
  }
  _objc_msgSend(self,op,pvVar1,pvVar2);
LAB_0010b7c4:
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)switchToOptionViewWithTag:(NSInteger)aTag
{
    if (aTag == 1) {
        [_optionsView replaceSubview:_soundsToPlayView with:_soundsToStopView];
        [_availableSoundsOutlineView reloadData];
        [self updateStopSoundPlaybackAttributes];
    }
    else if (aTag == 0) {
        [self mountContentView:[self suggestedContentView]];
        [_optionsView replaceSubview:_soundsToStopView with:_soundsToPlayView];
        [_soundChooserTableView reloadData];
        [self updateSoundPlaybackAttributes];
    }
    [self validateUserInterface];
}

- (void)stopAllSoundsDidChange:(id)aChange
{
    [self validateUserInterface];
}

- (void)soundsInActionDidChange:(id)aChange
{
    [_soundChooserTableView reloadData];
    [self updateSoundPlaybackAttributes];
    [self validateUserInterface];
}

- (void)movieDidStop:(id)aStop
{
    [self movieDidEnd:aStop];
}

- (void)movieDidPlayOnce:(id)aOnce
{

}

- (void)movieDidEnd:(id)aEnd
{
    [aEnd gotoBeginning];
    [self validateUserInterface];
}

- (void)movieDidChangeImage:(id)aImage
{

}

- (void)paneDidOK:(id)aOK
{
    if ([[_loopPopUpButton selectedItem] tag] == 0) {
        [self playCountChanged:_playCountTextField];
    }
    [NSApp stopModalWithCode:0];
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [self stopObserveNotification:[self stack]];
    [self cleanUnUsedSoundItemsIfNeeded];
    [super paneDidOK:aOK];
}

- (void)paneDidCancel:(id)aCancel
{
    [self dismiss:YES];
    [NSApp stopModalWithCode:0];
    [[HSObjectAssistantController sharedAssistantController] setLocked:NO delegate:nil];
    [super paneDidCancel:aCancel];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010ba9a @ 0010ba9a, 348 bytes * /

void FUN_0010ba9a(HSPlaySoundActionAssistantPane *self,SEL _cmd,id playCountChanged)

{
  bool bVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  if (self->_playCountTextField == playCountChanged) {
    pvVar3 = _objc_msgSend(self->_playCountTextField,sel_stringValue);
    self_00 = cls_NSString;
    pvVar4 = _objc_msgSend(self->_playCountTextField,sel_intValue);
    pvVar4 = _objc_msgSend(self_00,sel_stringWithFormat_,&cfstr__d,pvVar4);
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,pvVar4);
    if ((char)pvVar3 != '\0') goto LAB_0010bab7;
    bVar1 = false;
  }
  else {
LAB_0010bab7:
    bVar1 = true;
  }
  pvVar3 = self->_playCountTextField;
  pvVar4 = self->_playCountStepper;
  if (pvVar3 == playCountChanged) {
    pvVar2 = _objc_msgSend(playCountChanged,sel_intValue);
    pvVar3 = pvVar4;
  }
  else {
    if (pvVar4 != playCountChanged) goto LAB_0010bb9c;
    pvVar2 = _objc_msgSend(playCountChanged,sel_intValue);
  }
  _objc_msgSend(pvVar3,sel_setIntValue_,pvVar2);
LAB_0010bb9c:
  if (bVar1) {
    pvVar3 = _objc_msgSend(self,sel_playSoundActionApplier);
    pvVar4 = _objc_msgSend(playCountChanged,sel_intValue);
    _objc_msgSend(pvVar3,sel_setSoundPlayback_playCount_,self->_currentSoundPlaybackAttributes,
                  pvVar4);
  }
  return;
}

*/
- (void)playCountChanged:(id)aChanged
{
    BOOL shouldApply;

    // Text that is not a plain integer is reflected in the stepper but not applied.
    shouldApply = YES;
    if (_playCountTextField == aChanged) {
        shouldApply = [[_playCountTextField stringValue] isEqualToString:[NSString stringWithFormat:@"%d", [_playCountTextField intValue]]];
    }
    if (_playCountTextField == aChanged) {
        [_playCountStepper setIntValue:[aChanged intValue]];
    }
    else if (_playCountStepper == aChanged) {
        [_playCountTextField setIntValue:[aChanged intValue]];
    }
    if (shouldApply) {
        [[self playSoundActionApplier] setSoundPlayback:_currentSoundPlaybackAttributes playCount:[aChanged intValue]];
    }
}

- (void)loopModeChanged:(id)aChanged
{
    HSPopUpButton *self_00;
    id pvVar1;
    int pvVar2_3;

    if (_currentSoundPlaybackAttributes != nil) {
        pvVar1 = [self playSoundActionApplier];
        if ([[aChanged selectedCell] tag] == 0x1) {
            pvVar2_3 = 0;
        }
        else {
            pvVar2_3 = [_playCountStepper intValue];
        }
        [pvVar1 setSoundPlayback:_currentSoundPlaybackAttributes playCount:pvVar2_3];
        self_00 = _loopPopUpButton;
        [self_00 setToolTip:[[self_00 selectedItem] toolTip]];
        [_playCountStepper setEnabled:(unsigned int)([[aChanged selectedCell] tag] == 0)];
        [_playCountTextField setEnabled:(unsigned int)([[aChanged selectedCell] tag] == 0)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010bd73 @ 0010bd73, 295 bytes * /

void FUN_0010bd73(HSPlaySoundActionAssistantPane *self,SEL _cmd,id toggleFadeOutStopSounds)

{
  id pvVar1;
  id self_00;
  SEL op;
  double local_24;
  
  pvVar1 = _objc_msgSend(toggleFadeOutStopSounds,sel_state);
  if (pvVar1 == (id)0x1) {
    local_24 = _objc_msgSend_fpret(cls_HSPlaySoundAction,sel_defaultSoundFadeOutTime);
  }
  else {
    local_24 = 0.0;
  }
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_stopsAllSounds);
  if ((char)pvVar1 == '\0') {
    if (self->_currentSoundPlaybackAttributes == (id)0x0) {
      return;
    }
    self_00 = _objc_msgSend(self->_currentSoundPlaybackAttributes,sel_queryHyperInterface_,
                            &DAT_0037027c);
    pvVar1 = _objc_msgSend(self,sel_playSoundActionApplier);
    _objc_msgSend(self_00,sel_itemUID);
    op = sel_setFadeOutStopTime_forSoundUID_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_playSoundActionApplier);
    op = sel_setFadeOutStopTimeForStopAllSounds_;
  }
  _objc_msgSend(pvVar1,op,local_24);
  return;
}

*/
- (void)toggleFadeOutStopSounds:(id)aSounds
{
    double fadeOutTime;

    if ([aSounds state] == NSControlStateValueOn) {
        fadeOutTime = [HSPlaySoundAction defaultSoundFadeOutTime];
    }
    else {
        fadeOutTime = 0.0;
    }
    if ([[self actionAttributes] stopsAllSounds]) {
        [[self playSoundActionApplier] setFadeOutStopTimeForStopAllSounds:fadeOutTime];
    }
    else if (_currentSoundPlaybackAttributes != nil) {
        [[self playSoundActionApplier] setFadeOutStopTime:fadeOutTime forSoundUID:[[_currentSoundPlaybackAttributes queryHyperInterface:@protocol(HSSoundItemAttributes)] itemUID]];
    }
}

- (void)toggleAllSounds:(id)aSounds
{
    NSInteger pvVar1;

    pvVar1 = [aSounds state];
    [[self playSoundActionApplier] setStopsAllSounds:(unsigned int)(pvVar1 == 0x1)];
    [_availableSoundsOutlineView reloadData];
}

- (void)toggleSoundsOnThisCardOnly:(id)aOnly
{
    [_availableNodes release];
    _availableNodes = nil;
    [_availableSoundsOutlineView reloadData];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010bf66 @ 0010bf66, 201 bytes * /

void FUN_0010bf66(HSPlaySoundActionAssistantPane *self,SEL _cmd,id chooseSound)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  
  _objc_msgSend(self,sel_stop_,0);
  pvVar2 = _objc_msgSend(self->_optionsView,sel_subviews);
  _objc_msgSend(pvVar2,sel_makeObjectsPerformSelector_,sel_removeFromSuperview);
  pvVar2 = _objc_msgSend(self,sel_objectAssistantNavigationController);
  uVar1 = *(undefined4 *)PTR_PTR_003424ec;
  pvVar3 = _objc_msgSend(self,sel_pickSoundSourceAssistantPane);
  _objc_msgSend(pvVar2,sel_pushViewController_withIdentifier_animate_replacePrevious_,pvVar3,uVar1,1
                ,0);
  return;
}

*/
- (void)chooseSound:(id)aSound
{
    [self stop:nil];
    [[_optionsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[self objectAssistantNavigationController] pushViewController:[self pickSoundSourceAssistantPane] withIdentifier:HSPickSoundSourcePaneIdentifier animate:YES replacePrevious:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010c02f @ 0010c02f, 171 bytes * /

void FUN_0010c02f(HSPlaySoundActionAssistantPane *self,SEL _cmd,id rangeChanged)

{
  id self_00;
  double dVar1;
  double dVar2;
  double dVar3;
  
  dVar1 = _objc_msgSend_fpret(self->_rangeControl,sel_startTime);
  dVar2 = _objc_msgSend_fpret(self->_rangeControl,sel_finishTime);
  dVar3 = _objc_msgSend_fpret(self->_rangeControl,sel_startTime);
  self_00 = _objc_msgSend(self,sel_playSoundActionApplier);
  _objc_msgSend(self_00,sel_setSoundPlayback_playRange_,self->_currentSoundPlaybackAttributes,dVar1,
                dVar2 - dVar3);
  return;
}

*/
- (void)rangeChanged:(id)aChanged
{
    struct HSTimeRange range;

    range.location = [_rangeControl startTime];
    range.length = [_rangeControl finishTime] - [_rangeControl startTime];
    [[self playSoundActionApplier] setSoundPlayback:_currentSoundPlaybackAttributes playRange:range];
}

- (void)toggleFadeOutSound:(id)aSound
{
    id self_00;
    double dVar2;

    self_00 = [self playSoundActionApplier];
    if ([aSound state] == 0x1) {
        dVar2 = [HSPlaySoundAction defaultSoundFadeOutTime];
    }
    else {
        dVar2 = 0.0;
    }
    [self_00 setSoundPlayback:_currentSoundPlaybackAttributes fadeOutTime:dVar2];
}

- (void)synchronousSoundChanged:(id)aChanged
{
    [[self playSoundActionApplier] setSoundPlayback:_currentSoundPlaybackAttributes synchronousSound:(unsigned int)([aChanged state] != 0x1)];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)volumeChangedToMaximum:(id)aMaximum
{
    id pvVar1;

    pvVar1 = _volumeSlider;
    [pvVar1 setFloatValue:(float)[pvVar1 maxValue]];
    [[self playSoundActionApplier] setSoundPlayback:_currentSoundPlaybackAttributes volume:(float)[_volumeSlider maxValue]];
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-multiple-method-names"
- (void)volumeChangedToMinimum:(id)aMinimum
{
    id pvVar1;

    pvVar1 = _volumeSlider;
    [pvVar1 setFloatValue:(float)[pvVar1 minValue]];
    [[self playSoundActionApplier] setSoundPlayback:_currentSoundPlaybackAttributes volume:(float)[_volumeSlider minValue]];
}
#pragma clang diagnostic pop

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010c2f2 @ 0010c2f2, 89 bytes * /

void FUN_0010c2f2(HSPlaySoundActionAssistantPane *self,SEL _cmd,id volumeChanged)

{
  id self_00;
  longdouble lVar1;
  
  self_00 = _objc_msgSend(self,sel_playSoundActionApplier);
  lVar1 = (longdouble)_HSNonLinearValueForSlider(volumeChanged);
  _objc_msgSend(self_00,sel_setSoundPlayback_volume_,self->_currentSoundPlaybackAttributes,
                (float)lVar1);
  return;
}

*/
- (void)volumeChanged:(id)aChanged
{
    [[self playSoundActionApplier] setSoundPlayback:_currentSoundPlaybackAttributes volume:HSNonLinearValueForSlider(aChanged)];
}

- (void)stop:(id)aStop
{
    [self stopPlaying];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010c371 @ 0010c371, 259 bytes * /

void FUN_0010c371(HSPlaySoundActionAssistantPane *self,SEL _cmd,id play)

{
  id pvVar1;
  HSPlaySoundActionAssistantPane *self_00;
  longdouble lVar2;
  double dVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isPlaying);
  self_00 = self;
  op = sel_stopPlaying;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_previewSoundObject);
    if (pvVar1 == (id)0x0) goto LAB_0010c45a;
    _objc_msgSend(pvVar1,sel_gotoBeginning);
    lVar2 = (longdouble)_HSNonLinearValueForSlider(self->_volumeSlider);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_volume);
    if ((float)dVar3 != (float)lVar2) {
      _objc_msgSend(pvVar1,sel_setVolume_,(float)lVar2);
    }
    self_00 = _objc_msgSend(cls_HSMediaPlaySynchronizer,sel_sharedSynchronizer);
    op = sel_playMediaSingle_;
  }
  _objc_msgSend(self_00,op);
LAB_0010c45a:
  _objc_msgSend(self,sel_validateUserInterface);
  return;
}

*/
- (void)play:(id)aPlay
{
    HSMovie *previewSound;
    float volume;

    if ([self isPlaying]) {
        [self stopPlaying];
    }
    else {
        previewSound = [self previewSoundObject];
        if (previewSound == nil) {
            [self validateUserInterface];
            return;
        }
        [previewSound gotoBeginning];
        volume = HSNonLinearValueForSlider(_volumeSlider);
        if ((float)[previewSound volume] != volume) {
            [previewSound setVolume:volume];
        }
        [[HSMediaPlaySynchronizer sharedSynchronizer] playMediaSingle:previewSound];
    }
    [self validateUserInterface];
}

- (id)pickSoundSourceAssistantPane
{
    HSPickSoundSourceAssistantPane *pHVar1;
    HSPickSoundSourceAssistantPane *pHVar1_2;

    pHVar1 = _pickSoundSourceAssistantPane;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSPickSoundSourceAssistantPane new];
        _pickSoundSourceAssistantPane = pHVar1_2;
        [pHVar1_2 setPickSoundSourcePaneDelegate:self];
        pHVar1 = _pickSoundSourceAssistantPane;
    }
    [pHVar1 setActionEvent:[self actionEvent]];
    return _pickSoundSourceAssistantPane;
}

- (void)setSounds:(id)aSounds
{
    [[self playSoundActionApplier] setSounds:aSounds];
    [_segmentedControl selectCellWithTag:0];
    [self switchToOptionViewWithTag:0];
    [_optionsView addSubview:_soundsToPlayView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010c59f @ 0010c59f, 300 bytes * /

void FUN_0010c59f(HSPlaySoundActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  _objc_msgSend(self,sel_validateUserInterface);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_Free_some_disk_space_and_try_recording_again_,&cfstr_empty,
                         &cfstr_Alerts);
  pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,
                         &cfstr_Not_enough_disk_space_to_save_sound_being_record,&cfstr_empty,
                         &cfstr_Alerts);
  _NSRunCriticalAlertPanel(pvVar3,pvVar2,pvVar1,0,0);
  return;
}

*/
- (void)informAboutDiskSpaceError
{
    NSString *ok;
    NSString *message;
    NSString *title;

    [self validateUserInterface];
    ok = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"OK" value:@"" table:@"Alerts"];
    message = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Free some disk space and try recording again." value:@"" table:@"Alerts"];
    title = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Not enough disk space to save sound being recorded" value:@"" table:@"Alerts"];
    NSRunCriticalAlertPanel(title, @"%@", ok, nil, nil, message);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010c6cb @ 0010c6cb, 281 bytes * /

void FUN_0010c6cb(HSPlaySoundActionAssistantPane *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_Cannot_play_sound_,
                         &cfstr_empty,&cfstr_Alerts);
  pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,
                         &cfstr_The_sound_file_may_be_damaged_or_its_type_might_,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  _objc_msgSend(self_00,sel_setInformativeText_,pvVar2);
  _objc_msgSend(self_00,sel_runModal);
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)showAlert
{
    HSAlert *alert;

    alert = [HSAlert new];
    [alert setMessageText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"Cannot play sound." value:@"" table:@"Alerts"]];
    [alert setInformativeText:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"The sound file may be damaged or its type might not be supported. Select another sound file and try again." value:@"" table:@"Alerts"]];
    [alert runModal];
    [alert release];
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
    id pvVar1_3;

    pvVar1 = _previewSoundObject;
    if ((pvVar1 == nil) && (_currentSoundPlaybackAttributes != nil)) {
        pvVar1_3 = [[_currentSoundPlaybackAttributes sound] retain];
        _previewSoundObject = pvVar1_3;
        [pvVar1_3 setDelegate:self];
        pvVar1 = _previewSoundObject;
    }
    return pvVar1;
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

- (void)removeActionIfNeeded
{
    id pvVar1;
    id pvVar1_6;
    id pvVar2_4;

    pvVar1 = [self actionAttributes];
    if (pvVar1 != nil) {
        if ([[pvVar1 sounds] count] == 0) {
            if (![pvVar1 stopsAllSounds]) {
                if ([[pvVar1 soundsToStop] count] == 0) {
                    pvVar1_6 = [[[self applier] object] queryHyperInterface:@protocol(HSActor)];
                    pvVar2_4 = [self actionEvent];
                    [pvVar1_6 removeHyperActionOfType:[self actionType] forEvent:pvVar2_4];
                }
            }
        }
    }
}

- (id)helpTopicKey
{
    return @"HSPlaySound";
}

- (void)viewDidDisappear:(BOOL)aDisappear
{
    [[_optionsView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self removeActionIfNeeded];
    [super viewDidDisappear:aDisappear];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [[[[[self stack] document] currentWindowController] cardView] setDragHelperDelegate:nil];
    [self stopObserveNotification:[self stack]];
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    [_soundChooserTableView setDelegate:0];
    [_soundChooserTableView setDataSource:0];
    [_rangeControl setDelegate:0];
    [_availableNodes release];
    _availableNodes = nil;
    if (_availableSoundsInNodes != nil) {
        CFRelease(_availableSoundsInNodes);
        _availableSoundsInNodes = nil;
    }
    [super viewWillDisappear:aDisappear];
}

- (void)viewDidAppear:(BOOL)aAppear
{
    [super viewDidAppear:aAppear];
    [[self playSoundActionApplier] setIgnoresAssistantActions:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010cd2e @ 0010cd2e, 665 bytes * /

void FUN_0010cd2e(HSPlaySoundActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  HSPopUpButton *self_00;
  id pvVar1;
  id pvVar2;
  SEL op;
  HSPlaySoundActionAssistantPane *pHVar3;
  HSPlaySoundActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSActionAssistantPane_00350cf0;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  _objc_msgSend(self->_rangeControl,sel_setDelegate_,self);
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  _objc_msgSend(pvVar1,sel_convertOldVersionAttributesIfNeeded);
  pvVar2 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar2,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_currentWindowController);
  pvVar2 = _objc_msgSend(pvVar2,sel_cardView);
  _objc_msgSend(pvVar2,sel_setDragHelperDelegate_,self);
  _objc_msgSend(self,sel_startObserveNotification);
  _objc_msgSend(self->_rangeControl,sel_setDelegate_,self);
  _objc_msgSend(self->_soundChooserTableView,sel_setDataSource_,self);
  pHVar3 = self;
  _objc_msgSend(self->_soundChooserTableView,sel_setDelegate_,self);
  pvVar2 = _objc_msgSend(self->_segmentedControl,sel_selectedTag);
  if (pvVar2 == (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_sounds,pHVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    if (pvVar1 != (id)0x0) {
      pvVar1 = self->_soundsToPlayView;
      _objc_msgSend(self->_optionsView,sel_addSubview_,pvVar1);
      _objc_msgSend(self->_soundChooserTableView,sel_reloadData);
      op = sel_updateSoundPlaybackAttributes;
      goto LAB_0010cf4f;
    }
  }
  _objc_msgSend(self->_segmentedControl,sel_selectCellWithTag_,1);
  pvVar1 = self->_soundsToStopView;
  _objc_msgSend(self->_optionsView,sel_addSubview_,pvVar1);
  _objc_msgSend(self->_availableSoundsOutlineView,sel_reloadData);
  op = sel_updateStopSoundPlaybackAttributes;
LAB_0010cf4f:
  _objc_msgSend(self,op,pvVar1);
  _objc_msgSend(self,sel_invalidatePreviewSoundObject);
  _objc_msgSend(self,sel_validateUserInterface);
  self_00 = self->_loopPopUpButton;
  pvVar1 = _objc_msgSend(self_00,sel_selectedItem);
  pvVar1 = _objc_msgSend(pvVar1,sel_toolTip);
  _objc_msgSend(self_00,sel_setToolTip_,pvVar1);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    id attributes;

    [super viewWillAppear:aAppear];
    [_rangeControl setDelegate:self];
    attributes = [self actionAttributes];
    [attributes convertOldVersionAttributesIfNeeded];
    [[[[[self stack] document] currentWindowController] cardView] setDragHelperDelegate:self];
    [self startObserveNotification];
    [_rangeControl setDelegate:self];
    [_soundChooserTableView setDataSource:self];
    [_soundChooserTableView setDelegate:self];
    if ([_segmentedControl selectedTag] == 0 && [[attributes sounds] count] != 0) {
        [_optionsView addSubview:_soundsToPlayView];
        [_soundChooserTableView reloadData];
        [self updateSoundPlaybackAttributes];
    }
    else {
        [_segmentedControl selectCellWithTag:1];
        [_optionsView addSubview:_soundsToStopView];
        [_availableSoundsOutlineView reloadData];
        [self updateStopSoundPlaybackAttributes];
    }
    [self invalidatePreviewSoundObject];
    [self validateUserInterface];
    [_loopPopUpButton setToolTip:[[_loopPopUpButton selectedItem] toolTip]];
}

- (void)viewDidLoad
{
    id pvVar1;
    id pvVar2;
    id pvVar2_3;
    id pvVar2_5;

    [super viewDidLoad];
    pvVar2 = _stopAllSoundsBackgroundImageView;
    pvVar1 = [NSImage imageNamed:@"Background_Medium"];
    [pvVar2 setImage:pvVar1];
    [_soundChooserTableView setTarget:self];
    [_soundChooserTableView setDoubleAction:@selector(play:)];
    [[_rangeControl cell] setControlSize:2];
    pvVar2_3 = _segmentedControl;
    pvVar1 = [HSAssistantSegmentedControlBackgroundRenderer sharedBackgroundRenderer];
    [pvVar2_3 setBackgroundRenderer:pvVar1];
    pvVar2_5 = [[HSSwitchCell new] autorelease];
    if (pvVar2_5 != nil) {
        [pvVar2_5 setControlSize:1];
        [pvVar2_5 setLineBreakMode:4];
        [pvVar2_5 applyDefaultSettings];
        pvVar1 = [_availableSoundsOutlineView outlineTableColumn];
        [pvVar1 setDataCell:pvVar2_5];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010d197 @ 0010d197, 1947 bytes * /

void FUN_0010d197(HSPlaySoundActionAssistantPane *self,SEL _cmd)

{
  SEL op;
  HSPopUpButton *pHVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  undefined4 *puVar5;
  int iVar6;
  uint uVar7;
  char local_40;
  undefined1 local_24 [20];
  
  puVar5 = (undefined4 *)&stack0xffffffa4;
  pvVar3 = _objc_msgSend(self,sel_actionAttributes);
  pvVar4 = _objc_msgSend(pvVar3,sel_stopsAllSounds);
  cVar2 = (char)pvVar4;
  pvVar4 = _objc_msgSend(self->_segmentedControl,sel_selectedTag);
  if (pvVar4 == (id)0x1) {
    _objc_msgSend(self->_stopAllSoundsSwitch,sel_setState_);
    _objc_msgSend(self->_soundsOnThisCardSwitch,sel_setEnabled_);
    if (cVar2 == '\0') {
      if (self->_currentSoundPlaybackAttributes == (id)0x0) {
        _objc_msgSend(self->_fadeOutStopSoundsSwitch,sel_setEnabled_);
        _objc_msgSend(self->_fadeOutStopSoundsSwitch,sel_setState_);
        goto LAB_0010d8ec;
      }
      pvVar4 = _objc_msgSend(self->_currentSoundPlaybackAttributes,sel_queryHyperInterface_);
      pvVar3 = self->_fadeOutStopSoundsSwitch;
      self_00 = _objc_msgSend(self,sel_actionAttributes);
      _objc_msgSend(pvVar4,sel_itemUID);
      _objc_msgSend_fpret(self_00,sel_fadeOutTimeForStopSoundUID_);
      _objc_msgSend(pvVar3,sel_setState_);
      pvVar3 = self->_fadeOutStopSoundsSwitch;
    }
    else {
      _objc_msgSend(self->_soundsOnThisCardSwitch,sel_setState_);
      pvVar4 = self->_fadeOutStopSoundsSwitch;
      _objc_msgSend_fpret(pvVar3,sel_fadeOutTimeForStopAllSounds);
      _objc_msgSend(pvVar4,sel_setState_);
      pvVar3 = self->_fadeOutStopSoundsSwitch;
    }
    _objc_msgSend(pvVar3,sel_setEnabled_);
    puVar5 = (undefined4 *)&stack0xffffffa4;
  }
  else {
    puVar5 = (undefined4 *)&stack0xffffffa4;
    if (pvVar4 != (id)0x0) goto LAB_0010d8f1;
    _objc_msgSend(self,sel_suggestedContentView);
    _objc_msgSend(self,sel_mountContentView_);
    op = sel_showSourceChooser;
    if (cVar2 != '\0') {
      op = sel_hideSourceChooser;
    }
    _objc_msgSend(self,op);
    pvVar3 = self->_backgroundSoundSwitch;
    if (self->_currentSoundPlaybackAttributes == (id)0x0) {
      _objc_msgSend(pvVar3,sel_setState_);
      _objc_msgSend(self->_fadeOutSoundSwitch,sel_setState_);
      _objc_msgSend(self->_volumeSlider,sel_setFloatValue_);
      _objc_msgSend(self->_rangeControl,sel_setDuration_);
      _objc_msgSend(self->_rangeControl,sel_setStartTime_);
      _objc_msgSend(self->_rangeControl,sel_setFinishTime_);
      puVar5 = (undefined4 *)&stack0xffffffa4;
    }
    else {
      _objc_msgSend(self->_currentSoundPlaybackAttributes,sel_isSynchronousSound);
      _objc_msgSend(pvVar3,sel_setState_);
      pvVar3 = self->_fadeOutSoundSwitch;
      _objc_msgSend_fpret(self->_currentSoundPlaybackAttributes,sel_soundFadeOutTime);
      _objc_msgSend(pvVar3,sel_setState_);
      pvVar3 = self->_volumeSlider;
      _objc_msgSend_fpret(self->_currentSoundPlaybackAttributes,sel_volume);
      _HSLinearValueForSliderFromNonLinear();
      _objc_msgSend(pvVar3,sel_setFloatValue_);
      _objc_msgSend_stret(local_24,self->_currentSoundPlaybackAttributes,sel_soundPlayRange);
      pvVar4 = _objc_msgSend(self->_currentSoundPlaybackAttributes,sel_sound);
      pvVar3 = self->_rangeControl;
      _objc_msgSend_fpret(pvVar4,sel_duration);
      _objc_msgSend(pvVar3,sel_setDuration_);
      _objc_msgSend(self->_rangeControl,sel_setStartTime_);
      _objc_msgSend(self->_rangeControl,sel_setFinishTime_);
      puVar5 = (undefined4 *)&stack0xffffffa0;
    }
    if ((cVar2 == '\0') && (self->_currentSoundPlaybackAttributes != (id)0x0)) {
      local_40 = '\x01';
    }
    else {
      local_40 = '\0';
    }
    pvVar3 = self->_backgroundSoundSwitch;
    iVar6 = (int)local_40;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d4db;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_playCountTextField;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d4fa;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_playCountStepper;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d519;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pHVar1 = self->_loopPopUpButton;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pHVar1;
    puVar5[-1] = 0x10d538;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_fadeOutSoundSwitch;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d557;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_volumeSlider;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d573;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_minVolumeButton;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d592;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_maxVolumeButton;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d5b1;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_rangeControl;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d5cd;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_currentSoundPlaybackAttributes;
    puVar5[1] = sel_playCount;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d5e8;
    pvVar4 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pHVar1 = self->_loopPopUpButton;
    puVar5[2] = iVar6;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pHVar1;
    puVar5[-1] = 0x10d60a;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pHVar1 = self->_loopPopUpButton;
    puVar5[2] = (uint)(pvVar4 == (id)0x0);
    puVar5[1] = sel_selectItemWithTag_;
    *puVar5 = pHVar1;
    uVar7 = (uint)(pvVar4 != (id)0x0 && local_40 != '\0');
    puVar5[-1] = 0x10d642;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_playCountStepper;
    puVar5[2] = uVar7;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d661;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_playCountTextField;
    puVar5[2] = uVar7;
    puVar5[1] = sel_setEnabled_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d680;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    if (pvVar4 == (id)0x0) goto LAB_0010d8f1;
    pvVar3 = self->_playCountStepper;
    pvVar4 = self->_currentSoundPlaybackAttributes;
    puVar5[1] = sel_playCount;
    *puVar5 = pvVar4;
    puVar5[-1] = 0x10d6ab;
    pvVar4 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    puVar5[2] = pvVar4;
    puVar5[1] = sel_setIntValue_;
    *puVar5 = pvVar3;
    puVar5[-1] = 0x10d6c1;
    _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    pvVar3 = self->_playCountTextField;
    pvVar4 = self->_currentSoundPlaybackAttributes;
    puVar5[1] = sel_playCount;
    *puVar5 = pvVar4;
    puVar5[-1] = 0x10d6df;
    pvVar4 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
    puVar5[2] = pvVar4;
    puVar5[1] = sel_setIntValue_;
    *puVar5 = pvVar3;
  }
LAB_0010d8ec:
  puVar5[-1] = 0x10d8f1;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
LAB_0010d8f1:
  puVar5[1] = sel_validatePlaySoundButton;
  *puVar5 = self;
  puVar5[-1] = 0x10d906;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  puVar5[1] = sel_navigationPaneSwitcher;
  *puVar5 = self;
  puVar5[-1] = 0x10d918;
  pvVar3 = _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  puVar5[1] = sel_validateUserInterface;
  *puVar5 = pvVar3;
  puVar5[-1] = 0x10d92a;
  _objc_msgSend((id)*puVar5,(SEL)puVar5[1]);
  return;
}

*/
- (void)validateUserInterface
{
    id attributes;
    BOOL stopsAllSounds;
    NSInteger tag;
    BOOL enabled;
    NSUInteger playCount;
    struct HSTimeRange range;

    attributes = [self actionAttributes];
    stopsAllSounds = [attributes stopsAllSounds];
    tag = [_segmentedControl selectedTag];
    if (tag == 1) {
        [_stopAllSoundsSwitch setState:stopsAllSounds ? NSControlStateValueOn : NSControlStateValueOff];
        [_soundsOnThisCardSwitch setEnabled:!stopsAllSounds];
        if (stopsAllSounds) {
            [_soundsOnThisCardSwitch setState:NSControlStateValueOff];
            [_fadeOutStopSoundsSwitch setState:[attributes fadeOutTimeForStopAllSounds] > 0.0];
            [_fadeOutStopSoundsSwitch setEnabled:YES];
        }
        else if (_currentSoundPlaybackAttributes != nil) {
            [_fadeOutStopSoundsSwitch setState:[[self actionAttributes] fadeOutTimeForStopSoundUID:[[_currentSoundPlaybackAttributes queryHyperInterface:@protocol(HSSoundItemAttributes)] itemUID]] > 0.0];
            [_fadeOutStopSoundsSwitch setEnabled:YES];
        }
        else {
            [_fadeOutStopSoundsSwitch setEnabled:NO];
            [_fadeOutStopSoundsSwitch setState:NSControlStateValueOff];
        }
        [_availableSoundsOutlineView reloadData];
    }
    else if (tag == 0) {
        [self mountContentView:[self suggestedContentView]];
        if (stopsAllSounds) {
            [self hideSourceChooser];
        }
        else {
            [self showSourceChooser];
        }
        if (_currentSoundPlaybackAttributes != nil) {
            [_backgroundSoundSwitch setState:![_currentSoundPlaybackAttributes isSynchronousSound]];
            [_fadeOutSoundSwitch setState:[_currentSoundPlaybackAttributes soundFadeOutTime] > 0.0];
            [_volumeSlider setFloatValue:HSLinearValueForSliderFromNonLinear(_volumeSlider, [_currentSoundPlaybackAttributes volume])];
            range = [_currentSoundPlaybackAttributes soundPlayRange];
            [_rangeControl setDuration:[(HSMovie *)[_currentSoundPlaybackAttributes sound] duration]];
            [_rangeControl setStartTime:range.location];
            [_rangeControl setFinishTime:range.location + range.length];
        }
        else {
            [_backgroundSoundSwitch setState:NSControlStateValueOff];
            [_fadeOutSoundSwitch setState:NSControlStateValueOff];
            [_volumeSlider setFloatValue:0.0];
            [_rangeControl setDuration:0.0];
            [_rangeControl setStartTime:0.0];
            [_rangeControl setFinishTime:0.0];
        }
        enabled = !stopsAllSounds && _currentSoundPlaybackAttributes != nil;
        [_backgroundSoundSwitch setEnabled:enabled];
        [_playCountTextField setEnabled:enabled];
        [_playCountStepper setEnabled:enabled];
        [_loopPopUpButton setEnabled:enabled];
        [_fadeOutSoundSwitch setEnabled:enabled];
        [_volumeSlider setEnabled:enabled];
        [_minVolumeButton setEnabled:enabled];
        [_maxVolumeButton setEnabled:enabled];
        [_rangeControl setEnabled:enabled];
        playCount = [_currentSoundPlaybackAttributes playCount];
        [_loopPopUpButton setEnabled:enabled];
        // Tag 1 is "loop forever", which is stored as a play count of zero.
        [_loopPopUpButton selectItemWithTag:playCount == 0];
        [_playCountStepper setEnabled:playCount != 0 && enabled];
        [_playCountTextField setEnabled:playCount != 0 && enabled];
        if (playCount != 0) {
            [_playCountStepper setIntValue:(int)[_currentSoundPlaybackAttributes playCount]];
            [_playCountTextField setIntValue:(int)[_currentSoundPlaybackAttributes playCount]];
        }
    }
    [self validatePlaySoundButton];
    [[self navigationPaneSwitcher] validateUserInterface];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010d932 @ 0010d932, 799 bytes * /

void FUN_0010d932(HSPlaySoundActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  char cVar4;
  int iVar5;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(self,sel_actionAttributes);
  pvVar2 = _objc_msgSend(pvVar2,sel_stopsAllSounds);
  pvVar3 = _objc_msgSend(self->_segmentedControl,sel_selectedTag);
  if (pvVar3 == (id)0x1) {
    pvVar2 = self->_playStopButton;
    if (((self->_availableSoundsInNodes == (CFDictionary *)0x0) ||
        (iVar5 = _CFDictionaryGetCount(self->_availableSoundsInNodes), iVar5 < 1)) ||
       (self->_currentSoundPlaybackAttributes == (id)0x0)) {
      cVar4 = '\0';
    }
    else {
      cVar4 = '\x01';
    }
    iVar5 = (int)cVar4;
    _objc_msgSend(pvVar2,sel_setEnabled_,iVar5);
    pvVar3 = _objc_msgSend(self,sel_isPlaying);
    pvVar2 = self->_playStopButton;
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(pvVar1,sel_playButtonImage,iVar5);
      _objc_msgSend(pvVar2,sel_setImage_,pvVar3);
      pvVar2 = self->_playStopButton;
      pvVar3 = _objc_msgSend(pvVar1,sel_playButtonAquaImage);
      _objc_msgSend(pvVar2,sel_setAquaAlternateImage_,pvVar3);
      pvVar2 = self->_playStopButton;
      pvVar1 = _objc_msgSend(pvVar1,sel_playButtonGraphiteImage);
      goto LAB_0010da7f;
    }
    pvVar3 = _objc_msgSend(pvVar1,sel_stopButtonImage,iVar5);
    _objc_msgSend(pvVar2,sel_setImage_,pvVar3);
    pvVar2 = self->_playStopButton;
    pvVar3 = _objc_msgSend(pvVar1,sel_stopButtonAquaImage);
    _objc_msgSend(pvVar2,sel_setAquaAlternateImage_,pvVar3);
    pvVar2 = self->_playStopButton;
    op = sel_stopButtonGraphiteImage;
  }
  else {
    if (pvVar3 != (id)0x0) {
      return;
    }
    if (((char)pvVar2 == '\0') && (self->_currentSoundPlaybackAttributes != (id)0x0)) {
      cVar4 = '\x01';
    }
    else {
      cVar4 = '\0';
    }
    iVar5 = (int)cVar4;
    _objc_msgSend(self->_playButton,sel_setEnabled_,iVar5);
    pvVar3 = _objc_msgSend(self,sel_isPlaying);
    pvVar2 = self->_playButton;
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(pvVar1,sel_playButtonImage,iVar5);
      _objc_msgSend(pvVar2,sel_setImage_,pvVar3);
      pvVar2 = self->_playButton;
      pvVar3 = _objc_msgSend(pvVar1,sel_playButtonAquaImage);
      _objc_msgSend(pvVar2,sel_setAquaAlternateImage_,pvVar3);
      pvVar2 = self->_playButton;
      op = sel_playButtonGraphiteImage;
    }
    else {
      pvVar3 = _objc_msgSend(pvVar1,sel_stopButtonImage,iVar5);
      _objc_msgSend(pvVar2,sel_setImage_,pvVar3);
      pvVar2 = self->_playButton;
      pvVar3 = _objc_msgSend(pvVar1,sel_stopButtonAquaImage);
      _objc_msgSend(pvVar2,sel_setAquaAlternateImage_,pvVar3);
      pvVar2 = self->_playButton;
      op = sel_stopButtonGraphiteImage;
    }
  }
  pvVar1 = _objc_msgSend(pvVar1,op,pvVar3);
LAB_0010da7f:
  _objc_msgSend(pvVar2,sel_setGraphiteAlternateImage_,pvVar1);
  return;
}

*/
- (void)validatePlaySoundButton
{
    Class paneClass;
    BOOL stopsAllSounds;
    NSInteger tag;
    HSAppearanceButtonCell *button;
    BOOL enabled;

    paneClass = [self class];
    stopsAllSounds = [[self actionAttributes] stopsAllSounds];
    tag = [_segmentedControl selectedTag];
    if (tag == 1) {
        button = _playStopButton;
        enabled = _availableSoundsInNodes != NULL && CFDictionaryGetCount(_availableSoundsInNodes) > 0 && _currentSoundPlaybackAttributes != nil;
    }
    else if (tag == 0) {
        button = _playButton;
        enabled = !stopsAllSounds && _currentSoundPlaybackAttributes != nil;
    }
    else {
        return;
    }
    [button setEnabled:enabled];
    if ([self isPlaying]) {
        [button setImage:[paneClass stopButtonImage]];
        [button setAquaAlternateImage:[paneClass stopButtonAquaImage]];
        [button setGraphiteAlternateImage:[paneClass stopButtonGraphiteImage]];
    }
    else {
        [button setImage:[paneClass playButtonImage]];
        [button setAquaAlternateImage:[paneClass playButtonAquaImage]];
        [button setGraphiteAlternateImage:[paneClass playButtonGraphiteImage]];
    }
}

- (id)suggestedContentView
{
    id *ppvVar2;

    if (![[self actionAttributes] stopsAllSounds]) {
        ppvVar2 = &_soundsTableContentView;
    }
    else {
        ppvVar2 = &_stopAllSoundsContentView;
    }
    return *ppvVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010dca1 @ 0010dca1, 511 bytes * /

void FUN_0010dca1(HSPlaySoundActionAssistantPane *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *self_00;
  undefined *self_01;
  id pvVar3;
  id pvVar4;
  longdouble lVar5;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  if (self->_sourcesHidden != '\0') {
    _objc_msgSend_stret(local_34,self->_soundsContainerView,sel_frame);
    self_00 = cls_NSDictionary;
    uVar1 = *(undefined4 *)PTR_00336548;
    pvVar3 = _objc_msgSend(cls_NSValue,sel_valueWithRect_,(int)local_34._0_8_,
                           SUB84(local_34._0_8_,4),(int)local_34._8_8_,SUB84(local_34._8_8_,4));
    self_01 = cls_NSValue;
    uVar2 = *(undefined4 *)PTR_00336550;
    _objc_msgSend_stret(local_24,self->_soundsContainerView,sel_frame);
    pvVar4 = _objc_msgSend(self_01,sel_valueWithRect_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                           (int)local_24._8_8_,SUB84(local_24._8_8_,4));
    pvVar3 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,self->_soundsContainerView,
                           *(undefined4 *)PTR_00336554,pvVar4,uVar2,pvVar3,uVar1,0);
    pvVar4 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
    pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pvVar3,0);
    pvVar3 = _objc_msgSend(pvVar4,sel_initWithViewAnimations_,pvVar3);
    _objc_msgSend(pvVar3,sel_setAnimationBlockingMode_,0);
    lVar5 = (longdouble)_HSObjectAssistantAnimationDuration();
    _objc_msgSend(pvVar3,sel_setDuration_,SUB84((double)lVar5,0),
                  (int)((ulonglong)(double)lVar5 >> 0x20));
    _objc_msgSend(pvVar3,sel_startAnimation);
    _objc_msgSend(pvVar3,sel_release);
    self->_sourcesHidden = '\0';
  }
  return;
}

*/
- (void)showSourceChooser
{
    NSDictionary *viewAnimation;
    NSViewAnimation *animation;

    if (_sourcesHidden) {
        // The original animates the container from its frame to the same frame,
        // so this only toggles the flag.
        viewAnimation = [NSDictionary dictionaryWithObjectsAndKeys:
                         _soundsContainerView, NSViewAnimationTargetKey,
                         [NSValue valueWithRect:[_soundsContainerView frame]], NSViewAnimationStartFrameKey,
                         [NSValue valueWithRect:[_soundsContainerView frame]], NSViewAnimationEndFrameKey,
                         nil];
        animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:viewAnimation, nil]];
        [animation setAnimationBlockingMode:NSAnimationBlocking];
        [animation setDuration:HSObjectAssistantAnimationDuration()];
        [animation startAnimation];
        [animation release];
        _sourcesHidden = NO;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010dea0 @ 0010dea0, 511 bytes * /

void FUN_0010dea0(HSPlaySoundActionAssistantPane *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined *self_00;
  undefined *self_01;
  id pvVar3;
  id pvVar4;
  longdouble lVar5;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  if (self->_sourcesHidden == '\0') {
    _objc_msgSend_stret(local_34,self->_soundsContainerView,sel_frame);
    self_00 = cls_NSDictionary;
    uVar1 = *(undefined4 *)PTR_00336548;
    pvVar3 = _objc_msgSend(cls_NSValue,sel_valueWithRect_,(int)local_34._0_8_,
                           SUB84(local_34._0_8_,4),(int)local_34._8_8_,SUB84(local_34._8_8_,4));
    self_01 = cls_NSValue;
    uVar2 = *(undefined4 *)PTR_00336550;
    _objc_msgSend_stret(local_24,self->_soundsContainerView,sel_frame);
    pvVar4 = _objc_msgSend(self_01,sel_valueWithRect_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                           (int)local_24._8_8_,SUB84(local_24._8_8_,4));
    pvVar3 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,self->_soundsContainerView,
                           *(undefined4 *)PTR_00336554,pvVar4,uVar2,pvVar3,uVar1,0);
    pvVar4 = _objc_msgSend(cls_NSViewAnimation,sel_alloc);
    pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,pvVar3,0);
    pvVar3 = _objc_msgSend(pvVar4,sel_initWithViewAnimations_,pvVar3);
    _objc_msgSend(pvVar3,sel_setAnimationBlockingMode_,0);
    lVar5 = (longdouble)_HSObjectAssistantAnimationDuration();
    _objc_msgSend(pvVar3,sel_setDuration_,SUB84((double)lVar5,0),
                  (int)((ulonglong)(double)lVar5 >> 0x20));
    _objc_msgSend(pvVar3,sel_startAnimation);
    _objc_msgSend(pvVar3,sel_release);
    self->_sourcesHidden = '\x01';
  }
  return;
}

*/
- (void)hideSourceChooser
{
    NSDictionary *viewAnimation;
    NSViewAnimation *animation;

    if (!_sourcesHidden) {
        // The original animates the container from its frame to the same frame,
        // so this only toggles the flag.
        viewAnimation = [NSDictionary dictionaryWithObjectsAndKeys:
                         _soundsContainerView, NSViewAnimationTargetKey,
                         [NSValue valueWithRect:[_soundsContainerView frame]], NSViewAnimationStartFrameKey,
                         [NSValue valueWithRect:[_soundsContainerView frame]], NSViewAnimationEndFrameKey,
                         nil];
        animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:viewAnimation, nil]];
        [animation setAnimationBlockingMode:NSAnimationBlocking];
        [animation setDuration:HSObjectAssistantAnimationDuration()];
        [animation startAnimation];
        [animation release];
        _sourcesHidden = YES;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0010e09f @ 0010e09f, 268 bytes * /

void FUN_0010e09f(HSPlaySoundActionAssistantPane *self,SEL _cmd,id mountContentView)

{
  id pvVar1;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  if (self->_currentContentView != mountContentView) {
    _objc_msgSend(self->_currentContentView,sel_removeFromSuperview);
    _objc_msgSend(self->_currentContentView,sel_release);
    pvVar1 = _objc_msgSend(mountContentView,sel_retain);
    self->_currentContentView = pvVar1;
    _objc_msgSend(pvVar1,sel_setFrameOrigin_,*(undefined4 *)PTR_00336074,
                  *(undefined4 *)(PTR_00336074 + 4));
    pvVar1 = self->_currentContentView;
    _objc_msgSend_stret(local_24,self->_soundsContainerView,sel_frame);
    _objc_msgSend(pvVar1,sel_setFrameSize_,local_1c,local_18);
    _objc_msgSend(self->_soundsContainerView,sel_addSubview_,self->_currentContentView);
  }
  return;
}

*/
- (void)mountContentView:(id)aView
{
    if (_currentContentView != aView) {
        [_currentContentView removeFromSuperview];
        [_currentContentView release];
        _currentContentView = [aView retain];
        [_currentContentView setFrameOrigin:NSZeroPoint];
        [_currentContentView setFrameSize:[_soundsContainerView frame].size];
        [_soundsContainerView addSubview:_currentContentView];
    }
}

- (id)actionAttributes
{
    return [[self playSoundActionApplier] playSoundActionAttributes];
}

- (id)actionType
{
    return [HSPlaySoundAction actionType];
}

- (id)applier
{
    return [self playSoundActionApplier];
}

- (id)playSoundActionApplier
{
    id pvVar1;

    pvVar1 = _playSoundActionApplier;
    if (pvVar1 == nil) {
        pvVar1 = [super applier];
    }
    return pvVar1;
}

- (void)setPlaySoundActionApplier:(id)aApplier
{
    if (_playSoundActionApplier != aApplier) {
        [_playSoundActionApplier release];
        _playSoundActionApplier = [aApplier retain];
    }
}

- (Class)applierClass
{
    return [HSPlaySoundActionPaneApplier class];
}

- (void)dealloc
{
    NSNotificationCenter *self_00;
    HSPlaySoundActionAssistantPane *pHVar2;

    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self_00 = [NSNotificationCenter defaultCenter];
    pHVar2 = self;
    [self_00 removeObserver:self];
    if ([_previewSoundObject delegate] == self) {
        pHVar2 = nil;
        [_previewSoundObject setDelegate:0];
    }
    [_previewSoundObject stop];
    [_previewSoundObject release];
    [_currentContentView release];
    [_importSoundObjectDialogController release];
    [_playSoundActionApplier release];
    [_currentSoundPlaybackAttributes release];
    if ([_pickSoundSourceAssistantPane pickSoundSourcePaneDelegate] == self) {
        pHVar2 = nil;
        [_pickSoundSourceAssistantPane setPickSoundSourcePaneDelegate:nil];
    }
    [_pickSoundSourceAssistantPane release];
    [_stopAllSoundsContentView release];
    [_soundsTableContentView release];
    [_availableNodes release];
    if (_availableSoundsInNodes != nil) {
        CFRelease(_availableSoundsInNodes);
    }
    [_objectNameParagraphStyle release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"PlaySoundAssistantPane"];
    if (self != nil) {
        [self setTitle:[HSPlaySoundAction localizedName]];
    }
    return self;
}

@end

