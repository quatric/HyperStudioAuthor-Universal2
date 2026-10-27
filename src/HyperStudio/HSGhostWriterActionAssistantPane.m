#import "HSGhostWriterActionAssistantPane.h"

@implementation HSGhostWriterActionAssistantPane

/* i386 ivar offsets: _speedsMenu=0x88, _commandsMenu=0x8c, _textObjectsButton=0x90, _speedsButton=0x94, _commandsButton=0x98, _tokenTextView=0x9c, _notAvailableTextField=0xa0, _availableTextViews=0xa4 */

- (void)paneDidCancel:(id)aCancel
{
    [super paneDidCancel:aCancel];
}

- (void)paneDidOK:(id)aOK
{
    id pvVar1_2;

    pvVar1_2 = [self commandsFromAttributedString:[_tokenTextView textStorage]];
    [[self ghostWriterAssistantPaneApplier] setCommands:pvVar1_2];
    [super paneDidOK:aOK];
}

- (void)addToken:(id)aToken
{
    id pvVar1_2;
    id pvVar2_3;

    pvVar1_2 = [[NSTextAttachment alloc] initWithFileWrapper:nil];
    pvVar2_3 = [[[aToken cell] copy] autorelease];
    [pvVar2_3 setCanChangeHighlight:YES];
    [pvVar2_3 setHighlighted:NO];
    [pvVar2_3 setAutosize:YES];
    [pvVar1_2 setAttachmentCell:pvVar2_3];
    [_tokenTextView insertText:[NSAttributedString attributedStringWithAttachment:pvVar1_2]];
    [pvVar1_2 release];
    [_tokenTextView updateTokenRects];
    [_tokenTextView setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00206adb @ 00206adb, 197 bytes * /

void FUN_00206adb(HSGhostWriterActionAssistantPane *self,SEL _cmd,BOOL viewWillDisappear)

{
  id pvVar1;
  id self_00;
  HSGhostWriterActionAssistantPane *local_1c;
  undefined *local_18;
  
  _objc_msgSend(self->_availableTextViews,sel_release);
  self->_availableTextViews = (id)0x0;
  if ((self->super).super.super._userMadeTheDecision == '\0') {
    pvVar1 = _objc_msgSend(self->_tokenTextView,sel_textStorage);
    pvVar1 = _objc_msgSend(self,sel_commandsFromAttributedString_,pvVar1);
    self_00 = _objc_msgSend(self,sel_ghostWriterAssistantPaneApplier);
    _objc_msgSend(self_00,sel_setCommands_,pvVar1);
  }
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00354980;
  _objc_msgSendSuper(&local_1c,sel_viewWillDisappear_,(int)viewWillDisappear);
  return;
}

*/
- (void)viewWillDisappear:(BOOL)aDisappear
{
    [_availableTextViews release];
    _availableTextViews = nil;
    if (!_userMadeTheDecision) {
        id commands = [self commandsFromAttributedString:[_tokenTextView textStorage]];
        [[self ghostWriterAssistantPaneApplier] setCommands:commands];
    }
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00206ba0 @ 00206ba0, 1081 bytes * /

void FUN_00206ba0(HSGhostWriterActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id self_01;
  id pvVar3;
  undefined *puVar4;
  SEL op;
  id pvVar5;
  id local_24;
  id local_20;
  HSGhostWriterActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00354980;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_availableTextViews);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 == (id)0x0) {
    _objc_msgSend(self->_textObjectsButton,sel_setHidden_,1);
    pvVar1 = self->_notAvailableTextField;
    pvVar5 = (id)0x0;
    op = sel_setHidden_;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSMenu,sel_new);
    pvVar5 = (id)0x0;
    _objc_msgSend(pvVar1,sel_setAutoenablesItems_,0);
    pvVar2 = _objc_msgSend(self,sel_availableTextViews);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    local_24 = _objc_msgSend(pvVar2,sel_nextObject);
    if (local_24 != (id)0x0) {
      local_20 = (id)0x0;
      do {
        self_00 = _objc_msgSend(cls_NSMenuItem,sel_new,pvVar5);
        puVar4 = &DAT_00382490;
        pvVar5 = _objc_msgSend(local_24,sel_queryHyperInterface_,&DAT_00382490);
        self_01 = _objc_msgSend(pvVar5,sel_hyperParent);
        if (self_01 != local_20) {
          pvVar5 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_00382490);
          pvVar5 = _objc_msgSend(pvVar5,sel_hyperIndex);
          puVar4 = cls_NSString;
          pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
          pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Card_title,
                                 &cfstr_empty,&cfstr_AssistantPanes);
          puVar4 = _objc_msgSend(puVar4,sel_stringWithFormat_,pvVar3,(int)pvVar5 + 1);
          _objc_msgSend(pvVar1,sel_insertSeparatorWithTitle_,puVar4);
        }
        pvVar5 = _objc_msgSend(local_24,sel_hyperName,puVar4);
        _objc_msgSend(self_00,sel_setTitle_,pvVar5);
        pvVar5 = _objc_msgSend(local_24,sel_hyperUID);
        _objc_msgSend(self_00,sel_setRepresentedObject_,pvVar5);
        pvVar5 = self_00;
        _objc_msgSend(pvVar1,sel_addItem_,self_00);
        _objc_msgSend(self_00,sel_release);
        local_24 = _objc_msgSend(pvVar2,sel_nextObject);
        local_20 = self_01;
      } while (local_24 != (id)0x0);
    }
    _objc_msgSend(self->_notAvailableTextField,sel_setHidden_,1);
    _objc_msgSend(self->_textObjectsButton,sel_setHidden_,0);
    _objc_msgSend(self->_textObjectsButton,sel_setMenu_,pvVar1);
    pvVar2 = _objc_msgSend(self->_textObjectsButton,sel_cell);
    pvVar5 = _objc_msgSend(pvVar1,sel_itemAtIndex_,1);
    _objc_msgSend(pvVar2,sel_setSelectedMenuItem_,pvVar5);
    op = sel_release;
  }
  _objc_msgSend(pvVar1,op,pvVar5);
  pvVar1 = _objc_msgSend(self,sel_ghostWriterActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_commands);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_ghostWriterActionAttributes,pvVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_commands);
    pvVar1 = _objc_msgSend(self,sel_attributedStringFromCommands_,pvVar1);
    pvVar5 = _objc_msgSend(self->_tokenTextView,sel_textStorage);
    _objc_msgSend(pvVar5,sel_setAttributedString_,pvVar1);
  }
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    if ([[self availableTextViews] count] == 0) {
        [_textObjectsButton setHidden:YES];
        [_notAvailableTextField setHidden:NO];
    } else {
        NSMenu *menu = [NSMenu new];
        [menu setAutoenablesItems:NO];
        NSEnumerator *enumerator = [[self availableTextViews] objectEnumerator];
        id textView;
        id lastParent = nil;
        while ((textView = [enumerator nextObject]) != nil) {
            NSMenuItem *item = [NSMenuItem new];
            id parent = [[textView queryHyperInterface:@protocol(HSNodeChild)] hyperParent];
            if (parent != lastParent) {
                NSUInteger index = [[parent queryHyperInterface:@protocol(HSNodeChild)] hyperIndex];
                NSString *format = [[NSBundle mainBundle] localizedStringForKey:@"Card title" value:@"" table:@"AssistantPanes"];
                [menu insertSeparatorWithTitle:[NSString stringWithFormat:format, (int)index + 1]];
            }
            [item setTitle:[textView hyperName]];
            [item setRepresentedObject:[textView hyperUID]];
            [menu addItem:item];
            [item release];
            lastParent = parent;
        }
        [_notAvailableTextField setHidden:YES];
        [_textObjectsButton setHidden:NO];
        [_textObjectsButton setMenu:menu];
        [[_textObjectsButton cell] setSelectedMenuItem:[menu itemAtIndex:1]];
        [menu release];
    }
    if ([[self ghostWriterActionAttributes] commands] != nil) {
        id attributed = [self attributedStringFromCommands:[[self ghostWriterActionAttributes] commands]];
        [[_tokenTextView textStorage] setAttributedString:attributed];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tokenTextView setPlaceholderString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NBA_GhostWriter_Placeholder" value:@"" table:@"AssistantPanes"]];
    [_tokenTextView setExplanationPlaceholderString:[[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"NBA_GhostWriter_Explanation" value:@"" table:@"AssistantPanes"]];
    [_tokenTextView setDelegate:self];
    [_tokenTextView setRichText:NO];
    [_tokenTextView setImportsGraphics:NO];
    [_tokenTextView setUsesFontPanel:NO];
    [_speedsButton setMenu:_speedsMenu];
    [[_speedsButton cell] setSelectedMenuItem:[_speedsMenu itemWithTag:4]];
    [_commandsButton setMenu:_commandsMenu];
    [[_commandsMenu itemWithTag:0] setRepresentedObject:HSGhostWriterBackspace];
    [[_commandsMenu itemWithTag:1] setRepresentedObject:HSGhostWriterErase];
    [[_commandsMenu itemWithTag:2] setRepresentedObject:HSGhostWriterMoveLeft];
    [[_commandsMenu itemWithTag:3] setRepresentedObject:HSGhostWriterMoveRight];
    [[_commandsButton cell] setRepresentedObject:[[HSGhostWriterStuffCommand new] autorelease]];
    [[_speedsButton cell] setRepresentedObject:[[HSGhostWriterSpeedCommand new] autorelease]];
    [[_textObjectsButton cell] setRepresentedObject:[[HSGhostWriterTargetCommand new] autorelease]];
    [_commandsButton setDoubleClickAction:@selector(addToken:)];
    [_speedsButton setDoubleClickAction:@selector(addToken:)];
    [_textObjectsButton setDoubleClickAction:@selector(addToken:)];
    [_commandsButton setTarget:self];
    [_speedsButton setTarget:self];
    [_textObjectsButton setTarget:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002064ca @ 002064ca, 282 bytes * /

void FUN_002064ca(HSGhostWriterActionAssistantPane *self,SEL _cmd,id tokenTextView,id didPopUpCell)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(didPopUpCell,sel_selectedMenuItem);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(didPopUpCell,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_defaultBackgroundColor);
    _objc_msgSend(didPopUpCell,sel_setBackgroundColor_,pvVar1);
    pvVar1 = _objc_msgSend(didPopUpCell,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_defaultHighlightedBackgroundColor);
    _objc_msgSend(didPopUpCell,sel_setHighlightedBackgroundColor_,pvVar1);
    pvVar1 = _objc_msgSend(didPopUpCell,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_defaultBorderColor);
    _objc_msgSend(didPopUpCell,sel_setBorderColor_,pvVar1);
    pvVar1 = _objc_msgSend(didPopUpCell,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_defaultHighlightedBorderColor);
    _objc_msgSend(didPopUpCell,sel_setHighlightedBorderColor_,pvVar1);
  }
  return;
}

*/
- (void)tokenTextView:(id)aView didPopUpCell:(id)aCell
{
    if ([aCell selectedMenuItem] != nil) {
        HSTokenCell *cell = aCell;
        [cell setBackgroundColor:[[cell class] defaultBackgroundColor]];
        [cell setHighlightedBackgroundColor:[[cell class] defaultHighlightedBackgroundColor]];
        [cell setBorderColor:[[cell class] defaultBorderColor]];
        [cell setHighlightedBorderColor:[[cell class] defaultHighlightedBorderColor]];
    }
}

- (id)availableTextViews
{
    id pvVar1;
    id self_00;
    id pvVar1_4;

    pvVar1 = _availableTextViews;
    if (pvVar1 == nil) {
        _availableTextViews = [NSMutableArray new];
        self_00 = [[self stack] hyperDeepEnumerator];
        pvVar1_4 = [self_00 nextObject];
        while (pvVar1_4 != nil) {
            if ([HSGhostWriterAction canUseObject:pvVar1_4]) {
                [_availableTextViews addObject:[pvVar1_4 queryHyperInterface:@protocol(HSObjectAttributes)]];
            }
            pvVar1_4 = [self_00 nextObject];
        }
        pvVar1 = _availableTextViews;
    }
    return pvVar1;
}

- (id)ghostWriterActionAttributes
{
    return [[self ghostWriterAssistantPaneApplier] ghostWriterActionAttributes];
}

- (id)actionAttributes
{
    return [[self ghostWriterAssistantPaneApplier] ghostWriterActionAttributes];
}

- (id)ghostWriterAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSGhostWriterActionAssistantPaneApplier class];
}

- (id)actionType
{
    return [HSGhostWriterAction actionType];
}

- (void)dealloc
{
    [_availableTextViews release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"GhostWriterAssistantPane"];
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00205b83 @ 00205b83, 1876 bytes * /

id FUN_00205b83(HSGhostWriterActionAssistantPane *self,SEL _cmd,id attributedStringFromCommands)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  id pvVar5;
  id self_00;
  id pvVar6;
  undefined *puVar7;
  id pvVar8;
  id pvVar9;
  undefined *self_01;
  undefined *self_02;
  undefined *puVar10;
  id pvVar11;
  id pvVar12;
  undefined4 uVar13;
  
  pvVar5 = _objc_msgSend(cls_NSMutableAttributedString,sel_new);
  pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
  self_00 = _objc_msgSend(attributedStringFromCommands,sel_objectEnumerator);
  pvVar6 = _objc_msgSend(self_00,sel_nextObject);
  if (pvVar6 != (id)0x0) {
    uVar1 = *(undefined4 *)PTR_00336844;
    uVar2 = *(undefined4 *)PTR_00336840;
    uVar3 = *(undefined4 *)PTR_0033683c;
    uVar4 = *(undefined4 *)PTR_00336838;
    do {
      puVar7 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00382350);
      pvVar8 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_003823a0);
      pvVar9 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00382364);
      puVar10 = &DAT_00382378;
      pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00382378);
      if (puVar7 == (undefined *)0x0) {
        if (pvVar8 == (id)0x0) {
          if (pvVar9 == (id)0x0) {
            if (pvVar6 == (id)0x0) goto LAB_002062af;
            pvVar8 = _objc_msgSend(self->_commandsButton,sel_menu,puVar10);
            pvVar8 = _objc_msgSend(pvVar8,sel_copy);
            pvVar8 = _objc_msgSend(pvVar8,sel_autorelease);
            pvVar9 = _objc_msgSend(cls_NSTextAttachment,sel_alloc);
            self_02 = _objc_msgSend(pvVar9,sel_initWithFileWrapper_,0);
            pvVar9 = _objc_msgSend(cls_HSTokenCell,sel_new);
            _objc_msgSend(pvVar9,sel_setCanChangeHighlight_,1);
            _objc_msgSend(pvVar9,sel_setMenu_,pvVar8);
            _objc_msgSend(pvVar9,sel_setAutosize_,1);
            pvVar11 = _objc_msgSend(pvVar6,sel_stuffType);
            pvVar12 = _objc_msgSend(pvVar11,sel_isEqualToString_,uVar4);
            if ((char)pvVar12 == '\0') {
              pvVar12 = _objc_msgSend(pvVar11,sel_isEqualToString_,uVar3);
              if ((char)pvVar12 == '\0') {
                pvVar12 = _objc_msgSend(pvVar11,sel_isEqualToString_,uVar2);
                if ((char)pvVar12 == '\0') {
                  pvVar11 = _objc_msgSend(pvVar11,sel_isEqualToString_,uVar1);
                  if ((char)pvVar11 == '\0') goto LAB_00206181;
                  uVar13 = 3;
                }
                else {
                  uVar13 = 2;
                }
              }
              else {
                uVar13 = 1;
              }
            }
            else {
LAB_00206181:
              uVar13 = 0;
            }
            pvVar8 = _objc_msgSend(pvVar8,sel_itemWithTag_,uVar13);
            _objc_msgSend(pvVar9,sel_setSelectedMenuItem_,pvVar8);
            _objc_msgSend(self_02,sel_setAttachmentCell_,pvVar9);
            _objc_msgSend(pvVar9,sel_setRepresentedObject_,pvVar6);
            _objc_msgSend(pvVar9,sel_release);
            puVar10 = self_02;
            puVar7 = _objc_msgSend(cls_NSAttributedString,sel_attributedStringWithAttachment_,
                                   self_02);
          }
          else {
            pvVar6 = _objc_msgSend(self->_speedsButton,sel_menu,puVar10);
            pvVar6 = _objc_msgSend(pvVar6,sel_copy);
            pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
            pvVar8 = _objc_msgSend(cls_NSTextAttachment,sel_alloc);
            self_02 = _objc_msgSend(pvVar8,sel_initWithFileWrapper_,0);
            pvVar8 = _objc_msgSend(cls_HSTokenCell,sel_new);
            _objc_msgSend(pvVar8,sel_setCanChangeHighlight_,1);
            _objc_msgSend(pvVar8,sel_setMenu_,pvVar6);
            pvVar11 = _objc_msgSend(pvVar9,sel_speed);
            pvVar6 = _objc_msgSend(pvVar6,sel_itemWithTag_,pvVar11);
            _objc_msgSend(pvVar8,sel_setSelectedMenuItem_,pvVar6);
            _objc_msgSend(self_02,sel_setAttachmentCell_,pvVar8);
            _objc_msgSend(pvVar8,sel_setRepresentedObject_,pvVar9);
            _objc_msgSend(pvVar8,sel_setAutosize_,1);
            _objc_msgSend(pvVar8,sel_release);
            puVar10 = self_02;
            puVar7 = _objc_msgSend(cls_NSAttributedString,sel_attributedStringWithAttachment_,
                                   self_02);
          }
          goto LAB_0020628d;
        }
        pvVar6 = _objc_msgSend(cls_NSAttributedString,sel_alloc,puVar10);
        puVar10 = _objc_msgSend(pvVar8,sel_stringToType);
        pvVar6 = _objc_msgSend(pvVar6,sel_initWithString_,puVar10);
        puVar7 = _objc_msgSend(pvVar6,sel_autorelease);
LAB_00206292:
        if (puVar7 != (undefined *)0x0) {
          _objc_msgSend(pvVar5,sel_appendAttributedString_,puVar7);
          puVar10 = puVar7;
        }
      }
      else {
        puVar10 = puVar7;
        pvVar6 = _objc_msgSend(self,sel_isTargetCommandValid_,puVar7);
        if ((char)pvVar6 != '\0') {
          pvVar6 = _objc_msgSend(cls_NSTextAttachment,sel_alloc,puVar10);
          self_01 = _objc_msgSend(pvVar6,sel_initWithFileWrapper_,0);
          self_02 = _objc_msgSend(cls_HSTokenCell,sel_new);
          _objc_msgSend(self_02,sel_setCanChangeHighlight_,1);
          pvVar6 = _objc_msgSend(self->_textObjectsButton,sel_menu);
          pvVar6 = _objc_msgSend(pvVar6,sel_copy);
          pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
          _objc_msgSend(self_02,sel_setMenu_,pvVar6);
          pvVar6 = _objc_msgSend(self_02,sel_menu);
          pvVar8 = _objc_msgSend(puVar7,sel_targetObjectUID);
          pvVar6 = _objc_msgSend(self,sel_menuItemWithRepresentedUID_fromMenu_,pvVar8,pvVar6);
          _objc_msgSend(self_02,sel_setSelectedMenuItem_,pvVar6);
          _objc_msgSend(self_01,sel_setAttachmentCell_,self_02);
          _objc_msgSend(self_02,sel_setRepresentedObject_,puVar7);
          _objc_msgSend(self_02,sel_setAutosize_,1);
          puVar10 = self_01;
          puVar7 = _objc_msgSend(cls_NSAttributedString,sel_attributedStringWithAttachment_,self_01)
          ;
          _objc_msgSend(self_01,sel_release);
LAB_0020628d:
          _objc_msgSend(self_02,sel_release,puVar10);
          goto LAB_00206292;
        }
      }
LAB_002062af:
      pvVar6 = _objc_msgSend(self_00,sel_nextObject,puVar10);
    } while (pvVar6 != (id)0x0);
  }
  return pvVar5;
}

*/
- (id)attributedStringFromCommands:(id)aCommands
{
    NSMutableAttributedString *result = [[NSMutableAttributedString new] autorelease];
    NSEnumerator *enumerator = [aCommands objectEnumerator];
    id command;
    while ((command = [enumerator nextObject]) != nil) {
        id<HSGhostWriterTargetCommandInterface> target = [command queryHyperInterface:@protocol(HSGhostWriterTargetCommandInterface)];
        id<HSGhostWriterTypeTextCommandInterface> typeText = [command queryHyperInterface:@protocol(HSGhostWriterTypeTextCommandInterface)];
        id<HSGhostWriterSpeedCommandInterface> speed = [command queryHyperInterface:@protocol(HSGhostWriterSpeedCommandInterface)];
        id<HSGhostWriterStuffCommandInterface> stuff = [command queryHyperInterface:@protocol(HSGhostWriterStuffCommandInterface)];
        NSAttributedString *piece = nil;
        if (target != nil) {
            if (![self isTargetCommandValid:target]) {
                continue;
            }
            NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:nil];
            HSTokenCell *cell = [HSTokenCell new];
            [cell setCanChangeHighlight:YES];
            [cell setMenu:[[[_textObjectsButton menu] copy] autorelease]];
            [cell setSelectedMenuItem:[self menuItemWithRepresentedUID:[target targetObjectUID] fromMenu:[cell menu]]];
            [attachment setAttachmentCell:cell];
            [cell setRepresentedObject:target];
            [cell setAutosize:YES];
            piece = [NSAttributedString attributedStringWithAttachment:attachment];
            [attachment release];
            [cell release];
        } else if (typeText != nil) {
            piece = [[[NSAttributedString alloc] initWithString:[typeText stringToType]] autorelease];
        } else if (speed != nil) {
            NSMenu *menu = [[[_speedsButton menu] copy] autorelease];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:nil];
            HSTokenCell *cell = [HSTokenCell new];
            [cell setCanChangeHighlight:YES];
            [cell setMenu:menu];
            [cell setSelectedMenuItem:[menu itemWithTag:[speed speed]]];
            [attachment setAttachmentCell:cell];
            [cell setRepresentedObject:speed];
            [cell setAutosize:YES];
            [cell release];
            piece = [NSAttributedString attributedStringWithAttachment:attachment];
            [attachment release];
        } else if (stuff != nil) {
            NSMenu *menu = [[[_commandsButton menu] copy] autorelease];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] initWithFileWrapper:nil];
            HSTokenCell *cell = [HSTokenCell new];
            [cell setCanChangeHighlight:YES];
            [cell setMenu:menu];
            [cell setAutosize:YES];
            NSString *stuffType = [stuff stuffType];
            NSInteger tag = 0;
            if ([stuffType isEqualToString:HSGhostWriterBackspace]) {
                tag = 0;
            } else if ([stuffType isEqualToString:HSGhostWriterErase]) {
                tag = 1;
            } else if ([stuffType isEqualToString:HSGhostWriterMoveLeft]) {
                tag = 2;
            } else if ([stuffType isEqualToString:HSGhostWriterMoveRight]) {
                tag = 3;
            }
            [cell setSelectedMenuItem:[menu itemWithTag:tag]];
            [attachment setAttachmentCell:cell];
            [cell setRepresentedObject:stuff];
            [cell release];
            piece = [NSAttributedString attributedStringWithAttachment:attachment];
            [attachment release];
        }
        if (piece != nil) {
            [result appendAttributedString:piece];
        }
    }
    return result;
    return 0;
}

- (BOOL)isTargetCommandValid:(id)aValid
{
    return (BOOL)[HSGhostWriterAction canUseObject:[self objectWithUID:[aValid targetObjectUID]]];
}

- (id)objectWithUID:(id)aUID
{
    return [[[self stack] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)] childInTreeWithUID:aUID];
}

- (id)menuItemWithRepresentedUID:(id)aUID fromMenu:(id)aMenu
{
    id self_00;
    NSEnumerator *pvVar1_2;
    BOOL pvVar2_2;

    pvVar1_2 = [[aMenu itemArray] objectEnumerator];
    do {
        self_00 = [pvVar1_2 nextObject];
        if (self_00 == nil) {
            return nil;
        }
        pvVar2_2 = [aUID isEqual:[self_00 representedObject]];
    } while (!pvVar2_2);
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00205680 @ 00205680, 953 bytes * /

id FUN_00205680(HSGhostWriterActionAssistantPane *self,SEL _cmd,id commandsFromAttributedString)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_01;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  int iVar8;
  SEL op;
  undefined *puVar9;
  int *piVar10;
  id local_28;
  int local_20;
  int local_1c;
  int local_18;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar2 = _objc_msgSend(commandsFromAttributedString,sel_length);
  puVar1 = PTR_003367a8;
  if (0 < (int)pvVar2) {
    local_28 = (id)0x0;
    local_20 = 0;
    do {
      local_1c = 0;
      local_18 = 0;
      piVar10 = &local_1c;
      pvVar5 = local_28;
      pvVar3 = _objc_msgSend(commandsFromAttributedString,sel_attribute_atIndex_effectiveRange_,
                             *(undefined4 *)puVar1,local_28,piVar10);
      pvVar4 = _objc_msgSend(pvVar3,sel_attachmentCell);
      self_01 = _objc_msgSend(cls_HSTokenCell,sel_class);
      pvVar4 = _objc_msgSend(pvVar4,sel_isKindOfClass_,self_01);
      if ((char)pvVar4 != '\0') {
        if ((local_1c != 0) && (local_1c != local_20)) {
          iVar8 = local_1c - local_20;
          pvVar5 = _objc_msgSend(cls_HSGhostWriterTypeTextCommand,sel_alloc,self_01,pvVar5,piVar10);
          pvVar4 = _objc_msgSend(commandsFromAttributedString,sel_attributedSubstringFromRange_,
                                 local_20,iVar8);
          pvVar4 = _objc_msgSend(pvVar4,sel_string);
          self_01 = _objc_msgSend(pvVar5,sel_initWithStringToType_,pvVar4);
          _objc_msgSend(self_00,sel_addObject_,self_01);
        }
        local_20 = local_1c + local_18;
        pvVar3 = _objc_msgSend(pvVar3,sel_attachmentCell,self_01);
        self_01 = _objc_msgSend(pvVar3,sel_representedObject);
        pvVar5 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_00382350);
        pvVar4 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_00382364);
        puVar9 = &DAT_00382378;
        pvVar6 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_00382378);
        if (pvVar5 == (id)0x0) {
          if (pvVar4 != (id)0x0) {
            pvVar5 = _objc_msgSend(pvVar3,sel_selectedMenuItem,puVar9);
            pvVar7 = _objc_msgSend(pvVar5,sel_tag);
            pvVar5 = pvVar4;
            op = sel_setSpeed_;
            goto LAB_0020595a;
          }
          if (pvVar6 != (id)0x0) {
            pvVar5 = _objc_msgSend(pvVar3,sel_selectedMenuItem,puVar9);
            pvVar7 = _objc_msgSend(pvVar5,sel_representedObject);
            pvVar5 = pvVar6;
            op = sel_setStuffType_;
            goto LAB_0020595a;
          }
        }
        else {
          pvVar4 = _objc_msgSend(pvVar3,sel_selectedMenuItem,puVar9);
          pvVar7 = _objc_msgSend(pvVar4,sel_representedObject);
          op = sel_setTargetObjectUID_;
          if (pvVar7 == (id)0x0) {
            pvVar7 = _objc_msgSend(pvVar3,sel_objectValue,puVar9);
            op = sel_setTargetObjectUID_;
          }
LAB_0020595a:
          _objc_msgSend(pvVar5,op,pvVar7);
        }
        _objc_msgSend(self_00,sel_addObject_,self_01);
      }
      pvVar5 = (id)(local_18 + (int)local_28);
      local_28 = (id)((int)local_28 + 1);
      if (local_18 != 0) {
        local_28 = pvVar5;
      }
      if ((local_28 == pvVar2) && (local_1c == local_20)) {
        pvVar5 = _objc_msgSend(cls_HSGhostWriterTypeTextCommand,sel_alloc,self_01);
        pvVar3 = _objc_msgSend(commandsFromAttributedString,sel_attributedSubstringFromRange_,
                               local_1c,local_18);
        pvVar3 = _objc_msgSend(pvVar3,sel_string);
        pvVar5 = _objc_msgSend(pvVar5,sel_initWithStringToType_,pvVar3);
        _objc_msgSend(self_00,sel_addObject_,pvVar5);
      }
    } while ((int)local_28 < (int)pvVar2);
  }
  return self_00;
}

*/
- (id)commandsFromAttributedString:(id)aString
{
    NSMutableArray *commands = [NSMutableArray array];
    NSInteger length = [aString length];
    if (length > 0) {
        NSInteger index = 0;
        NSInteger textStart = 0;
        do {
            NSRange range = NSMakeRange(0, 0);
            id attachment = [aString attribute:NSAttachmentAttributeName atIndex:index effectiveRange:&range];
            id cell = [attachment attachmentCell];
            if ([cell isKindOfClass:[HSTokenCell class]]) {
                if (range.location != 0 && (NSInteger)range.location != textStart) {
                    NSString *text = [[aString attributedSubstringFromRange:NSMakeRange(textStart, range.location - textStart)] string];
                    [commands addObject:[[[HSGhostWriterTypeTextCommand alloc] initWithStringToType:text] autorelease]];
                }
                textStart = range.location + range.length;
                id represented = [cell representedObject];
                id<HSGhostWriterTargetCommandInterface> target = [represented queryHyperInterface:@protocol(HSGhostWriterTargetCommandInterface)];
                id<HSGhostWriterSpeedCommandInterface> speed = [represented queryHyperInterface:@protocol(HSGhostWriterSpeedCommandInterface)];
                id<HSGhostWriterStuffCommandInterface> stuff = [represented queryHyperInterface:@protocol(HSGhostWriterStuffCommandInterface)];
                if (target == nil) {
                    if (speed != nil) {
                        [speed setSpeed:[[cell selectedMenuItem] tag]];
                    } else if (stuff != nil) {
                        [stuff setStuffType:[[cell selectedMenuItem] representedObject]];
                    }
                } else {
                    id uid = [[cell selectedMenuItem] representedObject];
                    if (uid == nil) {
                        uid = [cell objectValue];
                    }
                    [target setTargetObjectUID:uid];
                }
                [commands addObject:represented];
            }
            if (range.length != 0) {
                index += range.length;
            } else {
                index += 1;
            }
            if (index == length && (NSInteger)range.location == textStart) {
                NSString *text = [[aString attributedSubstringFromRange:range] string];
                [commands addObject:[[[HSGhostWriterTypeTextCommand alloc] initWithStringToType:text] autorelease]];
            }
        } while (index < length);
    }
    return commands;
    return 0;
}

- (void)setUnvailableColorsToCell:(id)aCell
{
    [aCell setBorderColor:[NSColor redColor]];
    [aCell setHighlightedBorderColor:[NSColor redColor]];
    [aCell setHighlightedBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:0.34 blue:0.35 alpha:1.0]];
    [aCell setBackgroundColor:[NSColor colorWithCalibratedRed:1.0 green:0.39 blue:0.4 alpha:1.0]];
}

@end

@implementation HSGhostWriterActionAssistantPaneApplier

/* i386 ivar offsets: _initialCommands=0x30, _commands=0x34 */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    char cVar2;

    pvVar1 = [super areSettingsEqual];
    cVar2 = pvVar1;
    if ((_initialCommands != nil) || (_commands != nil)) {
        if (cVar2 == NO) {
            cVar2 = NO;
        }
        else {
            pvVar1 = [_initialCommands isEqualToArray:_commands];
            cVar2 = pvVar1;
        }
    }
    return cVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_commands release];
    _commands = [_initialCommands retain];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialCommands release];
    _initialCommands = [_commands retain];
}

- (void)setInitialSettingsToObject
{
    [[self ghostWriterActionAttributes] setCommands:_initialCommands];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self ghostWriterActionAttributes] setCommands:_commands];
}

- (void)setCommands:(id)aCommands
{
    if (_commands != aCommands) {
        [_commands release];
        _commands = [aCommands retain];
        [self disableUndo];
        [[self ghostWriterActionAttributes] setCommands:aCommands];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _commands = [[[self ghostWriterActionAttributes] commands] retain];
    _initialCommands = [[NSArray alloc] initWithArray:_commands copyItems:YES];
}

- (id)ghostWriterActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSGhostWriterActionAttributes)];
}

- (void)dealloc
{
    [_commands release];
    [_initialCommands release];
    [super dealloc];
}

@end

