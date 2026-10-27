#import "HSSequencerActionAssistantPane.h"
static id sDAT_00342928;

static id sDAT_00342928;


@implementation HSSequencerActionAssistantPane

/* i386 ivar offsets: _containerView=0x88, _emptyView=0x8c, _mainView=0x90, _outlineView=0x94, _scrollOutlineView=0x98, _noActionsPaneBackgroundView=0x9c, _objectsOnThisCardCheckBox=0xa0, _availableCards=0xa4, _currentView=0xa8 */

- (void)showObjectsOnThisCardOnly:(id)aOnly
{
    [_availableCards release];
    _availableCards = nil;
    [_outlineView reloadData];
    [self reloadExpandedStatesForItems:[self availableCards]];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [_outlineView reloadData];
}

- (BOOL)outlineView:(id)aView shouldEditTableColumn:(id)aColumn item:(id)aItem
{
    id pvVar2;
    id pvVar3;
    id pvVar1_9;
    id pvVar2_2;

    if ([self availableCards] != nil) {
        if ([[aColumn identifier] isEqual:@"HSObjectActionsDelayTableColumnIdentifier"]) {
            pvVar2 = [[aItem queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
            pvVar3 = [[[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
            if (![pvVar3 isEqual:pvVar2]) {
                pvVar1_9 = [self actionAttributes];
                pvVar2_2 = [self sequenceItemForObjectWithUID:pvVar2];
                return [[pvVar1_9 sequenceItems] containsObject:pvVar2_2];
            }
        }
    }
    return NO;
}

- (BOOL)outlineView:(id)aView shouldSelectItem:(id)aItem
{
    return ![aItem isKindOfClass:[HSCard class]];
}

- (id)outlineView:(id)aView toolTipForCell:(id)aCell rect:(NSRect *)aRect tableColumn:(id)aColumn item:(id)aItem mouseLocation:(NSPoint)aLocation
{
    if ([[aColumn identifier] isEqual:@"HSObjectActionsDelayTableColumnIdentifier"]) {
        if (![aItem isKindOfClass:[HSCard class]]) {
            return [[NSBundle mainBundle] localizedStringForKey:@"Set the precise time an action will occur after arrival at the card." value:@"" table:@"AssistantPanes"];
        }
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001129cc @ 001129cc, 1210 bytes * /

void FUN_001129cc(HSSequencerActionAssistantPane *self,SEL _cmd,id outlineView,id willDisplayCell,
                 id forTableColumn,id item)

{
  undefined4 uVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  id pvVar7;
  SEL pcVar8;
  double dVar9;
  undefined *puVar10;
  
  pvVar3 = _objc_msgSend(self,sel_availableCards);
  if (pvVar3 != (id)0x0) {
    _objc_msgSend(willDisplayCell,sel_setLineBreakMode_,4);
    pvVar3 = _objc_msgSend(forTableColumn,sel_identifier);
    pcVar6 = &cfstr_HSObjectActionsDelayTableColumnIdentifier;
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,&cfstr_HSObjectActionsDelayTableColumnIdentifier);
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(forTableColumn,sel_identifier,pcVar6);
      pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,&cfstr_HSObjectNameTableColumnIdentifier);
      if ((char)pvVar3 == '\0') {
        return;
      }
      pvVar3 = _objc_msgSend(item,sel_queryHyperInterface_,&DAT_00370c18);
      puVar10 = cls_NSString;
      pvVar4 = _objc_msgSend(pvVar3,sel_hyperKindDisplayName);
      pvVar5 = _objc_msgSend(pvVar3,sel_hyperName);
      pvVar7 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      pvVar7 = _objc_msgSend(pvVar7,sel_localizedStringForKey_value_table_,
                             &cfstr_HSObjectTitleFormat,&cfstr_empty,&cfstr_AssistantPanes);
      pcVar6 = _objc_msgSend(puVar10,sel_stringWithFormat_,pvVar7,pvVar5,pvVar4);
      pvVar7 = _objc_msgSend(cls_HSCard,sel_class);
      pvVar7 = _objc_msgSend(item,sel_isKindOfClass_,pvVar7);
      puVar10 = cls_NSFont;
      dVar9 = _objc_msgSend_fpret(cls_NSFont,sel_systemFontSizeForControlSize_,1);
      pcVar8 = sel_systemFontOfSize_;
      if ((char)pvVar7 != '\0') {
        pcVar8 = sel_boldSystemFontOfSize_;
      }
      pvVar4 = _objc_msgSend(puVar10,pcVar8,(float)dVar9,pvVar5,pvVar4);
      puVar10 = &DAT_00370d30;
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00370d30);
      pvVar3 = _objc_msgSend(pvVar3,sel_isHidden);
      if ((char)pvVar3 == '\0') {
        _objc_msgSend(willDisplayCell,sel_setFont_,pvVar4);
        pcVar8 = sel_setTitle_;
      }
      else {
        pvVar3 = _objc_msgSend(cls_NSAttributedString,sel_alloc,puVar10);
        puVar10 = cls_NSDictionary;
        uVar1 = *(undefined4 *)PTR_00336394;
        uVar2 = *(undefined4 *)PTR_00336068;
        pvVar5 = _objc_msgSend(cls_NSColor,sel_redColor);
        pvVar4 = _objc_msgSend(puVar10,sel_dictionaryWithObjectsAndKeys_,pvVar5,uVar1,pvVar4,uVar2,0
                              );
        pcVar6 = _objc_msgSend(pvVar3,sel_initWithString_attributes_,pcVar6,pvVar4);
        pcVar8 = sel_setAttributedTitle_;
      }
    }
    else {
      pvVar3 = _objc_msgSend(cls_HSCard,sel_class,pcVar6);
      pvVar3 = _objc_msgSend(item,sel_isKindOfClass_,pvVar3);
      if ((char)pvVar3 == '\0') {
        pvVar3 = _objc_msgSend(item,sel_queryHyperInterface_,&DAT_00370c18);
        pvVar4 = _objc_msgSend(pvVar3,sel_hyperUID);
        pvVar3 = _objc_msgSend(self,sel_assistant);
        pvVar3 = _objc_msgSend(pvVar3,sel_object);
        pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00370c18);
        pvVar5 = _objc_msgSend(pvVar3,sel_hyperUID);
        pvVar3 = pvVar4;
        pvVar5 = _objc_msgSend(pvVar5,sel_isEqual_,pvVar4);
        if ((char)pvVar5 != '\0') {
          return;
        }
        pvVar3 = _objc_msgSend(self,sel_actionAttributes,pvVar3);
        pvVar4 = _objc_msgSend(self,sel_sequenceItemForObjectWithUID_,pvVar4);
        pvVar3 = _objc_msgSend(pvVar3,sel_sequenceItems);
        pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar4);
        if ((char)pvVar3 == '\0') {
          pcVar6 = _objc_msgSend(cls_NSColor,sel_grayColor,pvVar4);
          pcVar8 = sel_setTextColor_;
        }
        else {
          pcVar6 = _objc_msgSend(cls_NSColor,sel_blackColor,pvVar4);
          pcVar8 = sel_setTextColor_;
        }
      }
      else {
        pcVar6 = &cfstr_empty;
        pcVar8 = sel_setObjectValue_;
      }
    }
    _objc_msgSend(willDisplayCell,pcVar8,pcVar6);
  }
  return;
}

*/
- (void)outlineView:(id)aView willDisplayCell:(id)aCell forTableColumn:(id)aColumn item:(id)aItem
{
    if ([self availableCards] == nil) {
        return;
    }
    [aCell setLineBreakMode:NSLineBreakByTruncatingTail];
    if ([[aColumn identifier] isEqual:@"HSObjectActionsDelayTableColumnIdentifier"]) {
        if ([aItem isKindOfClass:[HSCard class]]) {
            [aCell setObjectValue:@""];
            return;
        }
        id uid = [[aItem queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
        if ([[[[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] isEqual:uid]) {
            return;
        }
        id sequenceItem = [self sequenceItemForObjectWithUID:uid];
        if ([[[self actionAttributes] sequenceItems] containsObject:sequenceItem]) {
            [aCell setTextColor:[NSColor blackColor]];
        }
        else {
            [aCell setTextColor:[NSColor grayColor]];
        }
        return;
    }
    if (![[aColumn identifier] isEqual:@"HSObjectNameTableColumnIdentifier"]) {
        return;
    }
    id object = [aItem queryHyperInterface:@protocol(HSObjectAttributes)];
    id kindName = [object hyperKindDisplayName];
    id name = [object hyperName];
    NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSObjectTitleFormat" value:@"" table:@"AssistantPanes"];
    NSString *title = [NSString stringWithFormat:format, name, kindName];
    CGFloat fontSize = [NSFont systemFontSizeForControlSize:NSSmallControlSize];
    NSFont *font = [aItem isKindOfClass:[HSCard class]] ? [NSFont boldSystemFontOfSize:fontSize] : [NSFont systemFontOfSize:fontSize];
    if (![[object queryHyperInterface:@protocol(HSCardObjectHiddenAttribute)] isHidden]) {
        [aCell setFont:font];
        [aCell setTitle:title];
    }
    else {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor redColor], NSForegroundColorAttributeName, font, NSFontAttributeName, nil];
        NSAttributedString *attributedTitle = [[[NSAttributedString alloc] initWithString:title attributes:attributes] autorelease];
        [aCell setAttributedTitle:attributedTitle];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00112e86 @ 00112e86, 1305 bytes * /

void FUN_00112e86(HSSequencerActionAssistantPane *self,SEL _cmd,id outlineView,id setObjectValue,
                 id forTableColumn,id byItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  double dVar7;
  cfstringStruct *pcVar8;
  
  pvVar1 = _objc_msgSend(self,sel_availableCards);
  if (pvVar1 == (id)0x0) {
    return;
  }
  pvVar1 = _objc_msgSend(byItem,sel_queryHyperInterface_,&DAT_00370c18);
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperUID);
  pvVar3 = _objc_msgSend(byItem,sel_queryHyperInterface_,&DAT_00370b3c);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00370b3c);
  pvVar4 = _objc_msgSend(cls_HSActionSequencerLastSelectedActorHolder,sel_sharedActorHolder);
  _objc_msgSend(pvVar4,sel_setLastSequenceActor_forActor_,pvVar3,pvVar1);
  pvVar3 = _objc_msgSend(forTableColumn,sel_identifier);
  pcVar8 = &cfstr_HSObjectActionsDelayTableColumnIdentifier;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,&cfstr_HSObjectActionsDelayTableColumnIdentifier);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(forTableColumn,sel_identifier,pcVar8,pvVar1);
    pcVar8 = &cfstr_HSObjectNameTableColumnIdentifier;
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,&cfstr_HSObjectNameTableColumnIdentifier);
    if ((char)pvVar3 == '\0') goto LAB_0011337a;
    pvVar3 = _objc_msgSend(self,sel_assistant,pcVar8);
    pvVar3 = _objc_msgSend(pvVar3,sel_object);
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00370c18);
    pvVar4 = _objc_msgSend(pvVar3,sel_hyperUID);
    pvVar3 = pvVar2;
    pvVar4 = _objc_msgSend(pvVar4,sel_isEqual_,pvVar2);
    if ((char)pvVar4 != '\0') goto LAB_0011337a;
    pvVar5 = _objc_msgSend(self,sel_actionAttributes,pvVar3);
    pvVar6 = _objc_msgSend(setObjectValue,sel_intValue);
    pvVar3 = pvVar2;
    pvVar4 = _objc_msgSend(self,sel_sequenceItemForObjectWithUID_,pvVar2);
    pvVar5 = _objc_msgSend(pvVar5,sel_sequenceItems);
    pvVar5 = _objc_msgSend(pvVar5,sel_mutableCopy);
    if (pvVar5 == (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_alloc,pvVar3);
      pvVar5 = _objc_msgSend(pvVar3,sel_init);
    }
    _objc_msgSend(pvVar5,sel_removeObject_,pvVar4);
    if (pvVar6 == (id)0x1) {
      pvVar3 = _objc_msgSend(cls_HSSequenceItem,sel_alloc,pvVar4);
      pvVar1 = (id)0x0;
      pvVar2 = _objc_msgSend(pvVar3,sel_initWithUID_withDelay_,pvVar2,0);
      pvVar4 = pvVar2;
      _objc_msgSend(pvVar5,sel_addObject_,pvVar2);
      _objc_msgSend(pvVar2,sel_release);
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_assistant,pcVar8,pvVar1);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00370c18);
    pvVar3 = _objc_msgSend(pvVar1,sel_hyperUID);
    pvVar1 = pvVar2;
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,pvVar2);
    if ((char)pvVar3 != '\0') {
      return;
    }
    pvVar3 = _objc_msgSend(self,sel_actionAttributes,pvVar1);
    pvVar1 = pvVar2;
    pvVar4 = _objc_msgSend(self,sel_sequenceItemForObjectWithUID_,pvVar2);
    pvVar5 = _objc_msgSend(pvVar3,sel_sequenceItems);
    pvVar5 = _objc_msgSend(pvVar5,sel_mutableCopy);
    if (pvVar5 == (id)0x0) {
      pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_alloc,pvVar1);
      pvVar5 = _objc_msgSend(pvVar5,sel_init);
    }
    pvVar3 = _objc_msgSend(pvVar3,sel_sequenceItems,pvVar1);
    pvVar1 = pvVar4;
    pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar4);
    if ((char)pvVar3 != '\0') {
      _objc_msgSend(pvVar5,sel_removeObject_,pvVar4);
      pvVar1 = pvVar4;
    }
    pvVar3 = _objc_msgSend(cls_HSSequenceItem,sel_alloc,pvVar1);
    dVar7 = _objc_msgSend_fpret(setObjectValue,sel_doubleValue);
    pvVar1 = (id)(float)dVar7;
    pvVar2 = _objc_msgSend(pvVar3,sel_initWithUID_withDelay_,pvVar2,pvVar1);
    pvVar4 = pvVar2;
    _objc_msgSend(pvVar5,sel_addObject_,pvVar2);
    _objc_msgSend(pvVar2,sel_release);
  }
  pvVar1 = _objc_msgSend(self,sel_sequencerActionAssistantPaneApplier,pvVar4,pvVar1);
  _objc_msgSend(pvVar1,sel_setSequenceItems_,pvVar5);
  _objc_msgSend(pvVar5,sel_release);
LAB_0011337a:
  _objc_msgSend(outlineView,sel_setNeedsDisplay_,1);
  return;
}

*/
- (void)outlineView:(id)aView setObjectValue:(id)aValue forTableColumn:(id)aColumn byItem:(id)aItem
{
    if ([self availableCards] == nil) {
        return;
    }
    id uid = [[aItem queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    id actor = [aItem queryHyperInterface:@protocol(HSActor)];
    id ownerActor = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    [[HSActionSequencerLastSelectedActorHolder sharedActorHolder] setLastSequenceActor:actor forActor:ownerActor];
    NSMutableArray *items = nil;
    if ([[aColumn identifier] isEqual:@"HSObjectActionsDelayTableColumnIdentifier"]) {
        if ([[[[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] isEqual:uid]) {
            return;
        }
        id attributes = [self actionAttributes];
        id sequenceItem = [self sequenceItemForObjectWithUID:uid];
        items = [[attributes sequenceItems] mutableCopy];
        if (items == nil) {
            items = [[NSMutableArray alloc] init];
        }
        if ([[attributes sequenceItems] containsObject:sequenceItem]) {
            [items removeObject:sequenceItem];
        }
        HSSequenceItem *newItem = [[HSSequenceItem alloc] initWithUID:uid withDelay:(float)[aValue doubleValue]];
        [items addObject:newItem];
        [newItem release];
    }
    else {
        if (![[aColumn identifier] isEqual:@"HSObjectNameTableColumnIdentifier"]) {
            [aView setNeedsDisplay:YES];
            return;
        }
        if ([[[[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] isEqual:uid]) {
            [aView setNeedsDisplay:YES];
            return;
        }
        id attributes = [self actionAttributes];
        int state = [aValue intValue];
        id sequenceItem = [self sequenceItemForObjectWithUID:uid];
        items = [[attributes sequenceItems] mutableCopy];
        if (items == nil) {
            items = [[NSMutableArray alloc] init];
        }
        [items removeObject:sequenceItem];
        if (state == 1) {
            HSSequenceItem *newItem = [[HSSequenceItem alloc] initWithUID:uid withDelay:0.0];
            [items addObject:newItem];
            [newItem release];
        }
    }
    [[self sequencerActionAssistantPaneApplier] setSequenceItems:items];
    [items release];
    [aView setNeedsDisplay:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011339f @ 0011339f, 656 bytes * /

id FUN_0011339f(HSSequencerActionAssistantPane *self,SEL _cmd,id outlineView,
               id objectValueForTableColumn,id byItem)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  SEL op;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier);
  pcVar4 = &cfstr_HSObjectNameTableColumnIdentifier;
  pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSObjectNameTableColumnIdentifier);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(objectValueForTableColumn,sel_identifier,pcVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,&cfstr_HSObjectActionsDelayTableColumnIdentifier);
    if ((char)pvVar1 == '\0') {
      return (id)0x0;
    }
    pvVar1 = _objc_msgSend(byItem,sel_queryHyperInterface_,&DAT_00370c18);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID);
    pvVar1 = _objc_msgSend(self,sel_sequenceItemForObjectWithUID_,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_actionAttributes);
    pvVar2 = _objc_msgSend(pvVar2,sel_sequenceItems);
    pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar1);
    self = (HSSequencerActionAssistantPane *)cls_NSNumber;
    if ((char)pvVar2 == '\0') {
      byItem = (id)0x0;
      op = sel_numberWithFloat_;
    }
    else {
      dVar3 = _objc_msgSend_fpret(pvVar1,sel_delay);
      byItem = (id)(float)dVar3;
      op = sel_numberWithFloat_;
    }
  }
  else {
    pvVar1 = _objc_msgSend(byItem,sel_queryHyperInterface_,&DAT_00370c18);
    pvVar2 = _objc_msgSend(cls_HSCard,sel_class);
    pvVar2 = _objc_msgSend(byItem,sel_isKindOfClass_,pvVar2);
    op = sel_stateForItem_;
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(byItem,sel_queryHyperInterface_,&DAT_00370bf0);
      pvVar2 = _objc_msgSend(self,sel_availableObjectsOnCard_,pvVar2);
      _objc_msgSend(pvVar2,sel_count);
      self = (HSSequencerActionAssistantPane *)cls_NSString;
      _objc_msgSend(pvVar1,sel_hyperName);
      pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      byItem = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_HSCardTitleFormat,
                             &cfstr_empty,&cfstr_AssistantPanes);
      op = sel_stringWithFormat_;
    }
  }
  pvVar1 = _objc_msgSend(self,op,byItem);
  return pvVar1;
}

*/
- (id)outlineView:(id)aView objectValueForTableColumn:(id)aColumn byItem:(id)aItem
{
    if ([[aColumn identifier] isEqual:@"HSObjectNameTableColumnIdentifier"]) {
        id object = [aItem queryHyperInterface:@protocol(HSObjectAttributes)];
        if (![aItem isKindOfClass:[HSCard class]]) {
            return [self stateForItem:aItem];
        }
        NSUInteger count = [[self availableObjectsOnCard:[aItem queryHyperInterface:@protocol(HSNodeContainer)]] count];
        NSString *format = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSCardTitleFormat" value:@"" table:@"AssistantPanes"];
        return [NSString stringWithFormat:format, [object hyperName], (int)count];
    }
    if (![[aColumn identifier] isEqual:@"HSObjectActionsDelayTableColumnIdentifier"]) {
        return nil;
    }
    id sequenceItem = [self sequenceItemForObjectWithUID:[[aItem queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID]];
    if (![[[self actionAttributes] sequenceItems] containsObject:sequenceItem]) {
        return [NSNumber numberWithFloat:0.0f];
    }
    return [NSNumber numberWithFloat:(float)[sequenceItem delay]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00111f23 @ 00111f23, 351 bytes * /

id FUN_00111f23(HSSequencerActionAssistantPane *self,SEL _cmd,id stateForItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(stateForItem,sel_queryHyperInterface_,&DAT_00370c18);
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperUID);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00370c18);
  pvVar3 = _objc_msgSend(pvVar1,sel_hyperUID);
  pvVar1 = pvVar2;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,pvVar2);
  if ((char)pvVar3 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_actionAttributes,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_sequenceItemForObjectWithUID_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_sequenceItems);
    pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,pvVar2);
    if (((char)pvVar1 != '\0') &&
       (pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,1), pvVar1 != (id)0x0)) {
      return pvVar1;
    }
  }
  pvVar1 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,0);
  return pvVar1;
}

*/
- (id)stateForItem:(id)aItem
{
    id uid = [[aItem queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    if (![[[[[self assistant] object] queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID] isEqual:uid]) {
        id sequenceItem = [self sequenceItemForObjectWithUID:uid];
        if ([[[self actionAttributes] sequenceItems] containsObject:sequenceItem]) {
            return [NSNumber numberWithInt:1];
        }
    }
    return [NSNumber numberWithInt:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00111e37 @ 00111e37, 236 bytes * /

id FUN_00111e37(HSSequencerActionAssistantPane *self,SEL _cmd,id outlineView,int child,id ofItem)

{
  id pvVar1;
  id pvVar2;
  
  if (ofItem == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_availableCards);
LAB_00111e76:
    pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,child);
  }
  else {
    pvVar1 = _objc_msgSend(cls_HSCard,sel_class);
    pvVar1 = _objc_msgSend(ofItem,sel_isKindOfClass_,pvVar1);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(ofItem,sel_queryHyperInterface_,&DAT_00370bf0);
      if (pvVar1 != (id)0x0) {
        pvVar1 = _objc_msgSend(self,sel_availableObjectsOnCard_,pvVar1);
        pvVar2 = _objc_msgSend(pvVar1,sel_count);
        child = ~child + (int)pvVar2;
        goto LAB_00111e76;
      }
    }
    pvVar1 = (id)0x0;
  }
  return pvVar1;
}

*/
- (id)outlineView:(id)aView child:(NSInteger)aChild ofItem:(id)aItem
{
    if (aItem == nil) {
        return [[self availableCards] objectAtIndex:aChild];
    }
    if (![aItem isKindOfClass:[HSCard class]]) {
        return nil;
    }
    id container = [aItem queryHyperInterface:@protocol(HSNodeContainer)];
    if (container == nil) {
        return nil;
    }
    NSArray *objects = [self availableObjectsOnCard:container];
    return [objects objectAtIndex:[objects count] - 1 - aChild];
}

- (BOOL)outlineView:(id)aView isItemExpandable:(id)aExpandable
{
    if (aExpandable != nil) {
        if ([aExpandable isKindOfClass:[HSCard class]]) {
            return [[self availableObjectsOnCard:[aExpandable queryHyperInterface:@protocol(HSNodeContainer)]] count] != 0;
        }
    }
    return NO;
}

- (NSInteger)outlineView:(id)aView numberOfChildrenOfItem:(id)aItem
{
    id pvVar1;

    if (aItem == nil) {
        pvVar1 = [self availableCards];
    }
    else {
        if (![aItem isKindOfClass:[HSCard class]]) {
            return 0;
        }
        pvVar1 = [self availableObjectsOnCard:[aItem queryHyperInterface:@protocol(HSNodeContainer)]];
    }
    return (int)[pvVar1 count];
}

- (void)outlineViewItemDidCollapse:(id)aCollapse
{
    [self setExpandedState:NO forItem:[[aCollapse userInfo] objectForKey:@"NSObject"]];
}

- (void)outlineViewItemDidExpand:(id)aExpand
{
    [self setExpandedState:YES forItem:[[aExpand userInfo] objectForKey:@"NSObject"]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00111b50 @ 00111b50, 189 bytes * /

void FUN_00111b50(HSSequencerActionAssistantPane *self,SEL _cmd,id reloadExpandedStatesForItems)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  self_00 = _objc_msgSend(reloadExpandedStatesForItems,sel_objectEnumerator);
  pvVar1 = _objc_msgSend(self_00,sel_nextObject);
  while (pvVar1 != (id)0x0) {
    pvVar3 = pvVar1;
    pvVar2 = _objc_msgSend(self,sel_isExpandedStateStoredForItem_,pvVar1);
    if ((char)pvVar2 != '\0') {
      pvVar3 = _objc_msgSend(self,sel_expandedStateForItem_,pvVar1);
      op = sel_collapseItem_;
      if ((char)pvVar3 == '\x01') {
        op = sel_expandItem_;
      }
      _objc_msgSend(self->_outlineView,op,pvVar1);
      pvVar3 = pvVar1;
    }
    pvVar1 = _objc_msgSend(self_00,sel_nextObject,pvVar3);
  }
  return;
}

*/
- (void)reloadExpandedStatesForItems:(id)aItems
{
    for (id item in aItems) {
        if ([self isExpandedStateStoredForItem:item]) {
            if ([self expandedStateForItem:item]) {
                [_outlineView expandItem:item];
            }
            else {
                [_outlineView collapseItem:item];
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001119fa @ 001119fa, 342 bytes * /

void FUN_001119fa(HSSequencerActionAssistantPane *self,SEL _cmd,BOOL setExpandedState,id forItem)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pcVar4 = &cfstr_HSSequencerActionAssistantPaneCardExpandedStates;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,
                         &cfstr_HSSequencerActionAssistantPaneCardExpandedStates);
  op = sel_mutableCopy;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc,pcVar4);
    op = sel_init;
  }
  pvVar1 = _objc_msgSend(pvVar1,op,pcVar4);
  pvVar2 = _objc_msgSend(forItem,sel_hyperUID);
  pvVar2 = _objc_msgSend(pvVar2,sel_stringValue);
  pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)(byte)setExpandedState);
  _objc_msgSend(pvVar1,sel_setObject_forKey_,pvVar3,pvVar2);
  pvVar2 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar3 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,pvVar1,
                         &cfstr_HSSequencerActionAssistantPaneCardExpandedStates);
  _objc_msgSend(pvVar2,sel_registerDefaults_,pvVar3);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)setExpandedState:(BOOL)aState forItem:(id)aItem
{
    id stored = [[NSUserDefaults standardUserDefaults] objectForKey:@"HSSequencerActionAssistantPaneCardExpandedStates"];
    NSMutableDictionary *states = (stored != nil) ? [stored mutableCopy] : [[NSMutableDictionary alloc] init];
    [states setObject:[NSNumber numberWithBool:aState] forKey:[[aItem hyperUID] stringValue]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:states forKey:@"HSSequencerActionAssistantPaneCardExpandedStates"]];
    [states release];
}

- (BOOL)expandedStateForItem:(id)aItem
{
    return [[[[NSUserDefaults standardUserDefaults] objectForKey:@"HSSequencerActionAssistantPaneCardExpandedStates"] objectForKey:[[aItem hyperUID] stringValue]] boolValue];
}

- (BOOL)isExpandedStateStoredForItem:(id)aItem
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"HSSequencerActionAssistantPaneCardExpandedStates"] objectForKey:[[aItem hyperUID] stringValue]] != nil;
}

- (id)sequenceItemForObjectWithUID:(id)aUID
{
    id self_00;
    NSEnumerator *pvVar1_3;
    BOOL pvVar2_2;

    pvVar1_3 = [[[self actionAttributes] sequenceItems] objectEnumerator];
    do {
        self_00 = [pvVar1_3 nextObject];
        if (self_00 == nil) {
            return nil;
        }
        pvVar2_2 = [[self_00 objectUID] isEqual:aUID];
    } while (!pvVar2_2);
    return self_00;
}

- (id)initialKeyView
{
    return _objectsOnThisCardCheckBox;
}

- (id)helpTopicKey
{
    return @"HSSequencer";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [_availableCards release];
    _availableCards = nil;
    [_outlineView setDelegate:0];
    [_outlineView setDataSource:0];
    [super viewWillDisappear:aDisappear];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001136e4 @ 001136e4, 984 bytes * /

void FUN_001136e4(HSSequencerActionAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined4 *puVar4;
  int iVar5;
  HSSequencerActionAssistantPane *local_2c;
  undefined *local_28;
  undefined1 local_24 [20];
  
  puVar4 = (undefined4 *)&stack0xffffffa4;
  local_2c = self;
  local_28 = PTR_s_HSNBAAssistantPane_00350ed0;
  _objc_msgSendSuper(&local_2c,sel_viewWillAppear_);
  _objc_msgSend(self,sel_addActionAssistantPaneObserver);
  pvVar1 = _objc_msgSend(self,sel_availableCards);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(self,sel_mountView_);
    _objc_msgSend(self->_outlineView,sel_setDelegate_);
    _objc_msgSend(self->_outlineView,sel_setDataSource_);
    _objc_msgSend(self->_outlineView,sel_reloadData);
    pvVar1 = _objc_msgSend(self,sel_availableCards);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
    while (pvVar2 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_isExpandedStateStoredForItem_);
      if (((char)pvVar2 == '\0') ||
         (pvVar2 = _objc_msgSend(self,sel_expandedStateForItem_), (char)pvVar2 != '\0')) {
        pvVar2 = self->_outlineView;
        op = sel_expandItem_;
      }
      else {
        pvVar2 = self->_outlineView;
        op = sel_collapseItem_;
      }
      _objc_msgSend(pvVar2,op);
      pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
    }
    _objc_msgSend_stret(local_24,self->_outlineView,sel_visibleRect);
    puVar4 = (undefined4 *)&stack0xffffffa0;
    _objc_msgSend_fpret(self->_outlineView,sel_rowHeight);
    pvVar1 = _objc_msgSend(self,sel_assistant);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    _objc_msgSend(pvVar1,sel_queryHyperInterface_);
    pvVar2 = _objc_msgSend(cls_HSActionSequencerLastSelectedActorHolder,sel_sharedActorHolder);
    pvVar2 = _objc_msgSend(pvVar2,sel_lastSequenceActorForActor_);
    if (pvVar2 == (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_);
      pvVar1 = _objc_msgSend(pvVar1,sel_card);
      if (pvVar1 != (id)0x0) {
        pvVar2 = self->_outlineView;
        _objc_msgSend(pvVar1,sel_hyperObject);
        _objc_msgSend(pvVar2,sel_rowForItem_);
      }
    }
    else {
      pvVar1 = _objc_msgSend(self->_outlineView,sel_numberOfRows);
      for (iVar5 = 0; iVar5 < (int)pvVar1; iVar5 = iVar5 + 1) {
        pvVar3 = _objc_msgSend(self->_outlineView,sel_itemAtRow_);
        pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_);
        if (pvVar3 == pvVar2) break;
      }
    }
    _objc_msgSend(self->_outlineView,sel_numberOfRows);
  }
  puVar4[-1] = 0x113ab4;
  _objc_msgSend((id)*puVar4,(SEL)puVar4[1]);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    if ([[self availableCards] count] == 0) {
        [self mountView:_emptyView];
        return;
    }
    [self mountView:_mainView];
    [_outlineView setDelegate:self];
    [_outlineView setDataSource:self];
    [_outlineView reloadData];
    for (id card in [self availableCards]) {
        if (![self isExpandedStateStoredForItem:card] || [self expandedStateForItem:card]) {
            [_outlineView expandItem:card];
        }
        else {
            [_outlineView collapseItem:card];
        }
    }
    float visibleHeight = [_outlineView visibleRect].size.height;
    float rowHeight = [_outlineView rowHeight];
    NSInteger visibleRows = (NSInteger)(visibleHeight / rowHeight);
    id object = [[self assistant] object];
    id lastActor = [[HSActionSequencerLastSelectedActorHolder sharedActorHolder] lastSequenceActorForActor:[object queryHyperInterface:@protocol(HSActor)]];
    NSInteger row = 0;
    if (lastActor != nil) {
        NSInteger count = [_outlineView numberOfRows];
        for (NSInteger i = 0; i < count; i++) {
            if ([[_outlineView itemAtRow:i] queryHyperInterface:@protocol(HSActor)] == lastActor) {
                row = i + visibleRows / 2;
                break;
            }
        }
    }
    else {
        id card = [[object queryHyperInterface:@protocol(HSUserObjectSupport)] card];
        if (card != nil) {
            row = visibleRows - 1 + [_outlineView rowForItem:[card hyperObject]];
        }
    }
    NSInteger lastRow = [_outlineView numberOfRows] - 1;
    [_outlineView scrollRowToVisible:(lastRow > row) ? row : lastRow];
}

- (id)actionAttribute
{
    return (id)@protocol(HSSequencerActionAttributes);
}

- (void)mountView:(id)aView
{
    if (_currentView != aView) {
        [_currentView removeFromSuperview];
        [_containerView addSubview:aView];
        _currentView = aView;
    }
}

- (id)availableCards
{
    id pvVar1;
    id self_01;
    id self_02;
    id pvVar1_4;

    pvVar1 = _availableCards;
    if (pvVar1 == nil) {
        if ([_objectsOnThisCardCheckBox state] == 0) {
            self_01 = [NSMutableArray array];
            self_02 = [[self stack] hyperEnumerator];
            pvVar1_4 = [self_02 nextObject];
            while (pvVar1_4 != nil) {
                if ([[self availableObjectsOnCard:[pvVar1_4 queryHyperInterface:@protocol(HSNodeContainer)]] count] != 0) {
                    [self_01 addObject:pvVar1_4];
                }
                pvVar1_4 = [self_02 nextObject];
            }
            pvVar1 = [self_01 copy];
            _availableCards = pvVar1;
        }
        else {
            pvVar1 = [[NSArray arrayWithObject:[[[self stack] document] currentCard]] retain];
            _availableCards = pvVar1;
        }
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00111464 @ 00111464, 438 bytes * /

id FUN_00111464(HSSequencerActionAssistantPane *self,SEL _cmd,id availableObjectsOnCard)

{
  undefined4 uVar1;
  id pvVar2;
  undefined *puVar3;
  undefined *puVar4;
  id self_00;
  id pvVar5;
  undefined *puVar6;
  SEL op;
  
  pvVar2 = _objc_msgSend(availableObjectsOnCard,sel_hyperChildren);
  puVar3 = _objc_msgSend(pvVar2,sel_queryAnyHyperInterfaces_,&DAT_00370b3c);
  puVar6 = &DAT_00370b3c;
  puVar4 = _objc_msgSend(availableObjectsOnCard,sel_queryHyperInterface_,&DAT_00370b3c);
  if (puVar4 != (undefined *)0x0) {
    op = sel_arrayWithObject_;
    puVar6 = cls_NSArray;
    if (puVar3 != (undefined *)0x0) {
      op = sel_arrayByAddingObject_;
      puVar6 = puVar3;
    }
    puVar3 = _objc_msgSend(puVar6,op,puVar4);
    puVar6 = puVar4;
  }
  pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_array,puVar6);
  self_00 = _objc_msgSend(puVar3,sel_objectEnumerator);
  pvVar5 = _objc_msgSend(self,sel_assistant);
  pvVar5 = _objc_msgSend(pvVar5,sel_object);
  puVar6 = &DAT_00370b3c;
  puVar3 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_00370b3c);
  puVar4 = _objc_msgSend(self_00,sel_nextObject);
  if (puVar4 != (undefined *)0x0) {
    uVar1 = *(undefined4 *)PTR_003363a8;
    do {
      if (puVar3 != puVar4) {
        puVar6 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,uVar1);
        pvVar5 = _objc_msgSend(puVar4,sel_hyperActionsForEvent_,puVar6);
        pvVar5 = _objc_msgSend(pvVar5,sel_count);
        if (pvVar5 != (id)0x0) {
          _objc_msgSend(pvVar2,sel_addObject_,puVar4);
          puVar6 = puVar4;
        }
      }
      puVar4 = _objc_msgSend(self_00,sel_nextObject,puVar6);
    } while (puVar4 != (undefined *)0x0);
  }
  return pvVar2;
}

*/
- (id)availableObjectsOnCard:(id)aCard
{
    NSArray *actors = [[aCard hyperChildren] queryAnyHyperInterfaces:@protocol(HSActor)];
    id cardActor = [aCard queryHyperInterface:@protocol(HSActor)];
    if (cardActor != nil) {
        actors = (actors != nil) ? [actors arrayByAddingObject:cardActor] : [NSArray arrayWithObject:cardActor];
    }
    NSMutableArray *objects = [NSMutableArray array];
    id ownerActor = [[[self assistant] object] queryHyperInterface:@protocol(HSActor)];
    for (id actor in actors) {
        if (ownerActor != actor && [[actor hyperActionsForEvent:[HSActionEvent actionEventOfType:kHSDefaultActionEventType]] count] != 0) {
            [objects addObject:actor];
        }
    }
    return objects;
}

- (id)actionType
{
    return [HSSequencerAction actionType];
}

- (void)viewDidLoad
{
    id pvVar1_2;

    [super viewDidLoad];
    pvVar1_2 = [[HSSwitchCell new] autorelease];
    [pvVar1_2 setControlSize:1];
    [pvVar1_2 setLineBreakMode:4];
    [pvVar1_2 applyDefaultSettings];
    [[_outlineView outlineTableColumn] setDataCell:pvVar1_2];
    [_noActionsPaneBackgroundView setImage:[NSImage imageNamed:@"Background_Medium"]];
}

- (void)dealloc
{
    if ([_outlineView delegate] == self) {
        [_outlineView setDelegate:0];
    }
    if ([_outlineView dataSource] == self) {
        [_outlineView setDataSource:0];
    }
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"SequencerAssistantPane"];
    return self;
}

- (id)actionAttributes
{
    return [[self sequencerActionAssistantPaneApplier] sequencerActionAttributes];
}

- (id)sequencerActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSSequencerActionAssistantPaneApplier class];
}

@end

@implementation HSSequencerActionAssistantPaneApplier

/* i386 ivar offsets: _initialSequenceItems=0x30, _sequenceItems=0x34 */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    char cVar2;

    pvVar1 = [super areSettingsEqual];
    cVar2 = pvVar1;
    if ((_initialSequenceItems != nil) || (_sequenceItems != nil)) {
        if (cVar2 == NO) {
            cVar2 = NO;
        }
        else {
            pvVar1 = [_initialSequenceItems isEqualToArray:_sequenceItems];
            cVar2 = pvVar1;
        }
    }
    return cVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_sequenceItems release];
    _sequenceItems = [_initialSequenceItems retain];
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialSequenceItems release];
    _initialSequenceItems = [_sequenceItems retain];
}

- (void)setInitialSettingsToObject
{
    [[self sequencerActionAttributes] setSequenceItems:_initialSequenceItems];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self sequencerActionAttributes] setSequenceItems:_sequenceItems];
}

- (void)setSequenceItems:(id)aItems
{
    if (_sequenceItems != aItems) {
        [_sequenceItems release];
        _sequenceItems = [aItems retain];
        [self disableUndo];
        [[self sequencerActionAttributes] setSequenceItems:_sequenceItems];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _initialSequenceItems = [[[self sequencerActionAttributes] sequenceItems] retain];
    _sequenceItems = [[[self sequencerActionAttributes] sequenceItems] retain];
}

- (id)sequencerActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSSequencerActionAttributes)];
}

- (void)dealloc
{
    [_initialSequenceItems release];
    [_sequenceItems release];
    [super dealloc];
}

@end

@implementation HSActionSequencerLastSelectedActorHolder

/* i386 ivar offsets: _actorsMap=0x4 */

+ (id)sharedActorHolder
{
    if (sDAT_00342928 == nil) {
        sDAT_00342928 = [[self class] new];
    }
    return sDAT_00342928;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0011248c @ 0011248c, 364 bytes * /

void FUN_0011248c(HSActionSequencerLastSelectedActorHolder *self,SEL _cmd,id dereferenceObject)

{
  char cVar1;
  id pvVar2;
  undefined4 *puVar3;
  undefined1 local_24 [12];
  id local_18;
  undefined4 local_14;
  
  if ((self->_actorsMap != (id)0x0) &&
     (pvVar2 = (id)_NSMapGet(self->_actorsMap,dereferenceObject), pvVar2 != (id)0x0)) {
    _objc_msgSend(pvVar2,sel_unregisterWeakReferencer_,self);
    _NSMapRemove(self->_actorsMap,dereferenceObject);
  }
  local_14 = 0;
  local_18 = (id)0x0;
  _NSEnumerateMapTable(local_24,self->_actorsMap);
  pvVar2 = (id)0x0;
  while (cVar1 = _NSNextMapEnumeratorPair(local_24,&local_14,&local_18), cVar1 != '\0') {
    if (local_18 == dereferenceObject) {
      if (pvVar2 == (id)0x0) {
        pvVar2 = _objc_msgSend(cls_NSMutableData,sel_dataWithBytes_length_,&local_14,4);
      }
      else {
        _objc_msgSend(pvVar2,sel_appendBytes_length_,&local_14,4);
      }
    }
  }
  _NSEndMapTableEnumeration(local_24);
  puVar3 = _objc_msgSend(pvVar2,sel_bytes);
  for (pvVar2 = _objc_msgSend(pvVar2,sel_length); pvVar2 != (id)0x0; pvVar2 = (id)((int)pvVar2 + -4)
      ) {
    _objc_msgSend((id)*puVar3,sel_unregisterWeakReferencer_,self);
    _NSMapRemove(self->_actorsMap,*puVar3);
    puVar3 = puVar3 + 1;
  }
  return;
}

*/
- (void)dereferenceObject:(id)aObject
{
    if (_actorsMap != nil) {
        id actor = NSMapGet(_actorsMap, aObject);
        if (actor != nil) {
            [actor unregisterWeakReferencer:self];
            NSMapRemove(_actorsMap, aObject);
        }
    }
    void *key = NULL;
    void *value = NULL;
    NSMutableData *keys = nil;
    NSMapEnumerator enumerator = NSEnumerateMapTable(_actorsMap);
    while (NSNextMapEnumeratorPair(&enumerator, &key, &value)) {
        if (value == aObject) {
            if (keys == nil) {
                keys = [NSMutableData dataWithBytes:&key length:sizeof(key)];
            }
            else {
                [keys appendBytes:&key length:sizeof(key)];
            }
        }
    }
    NSEndMapTableEnumeration(&enumerator);
    id const *removed = (id const *)[keys bytes];
    for (NSUInteger length = [keys length]; length != 0; length -= sizeof(key)) {
        [*removed unregisterWeakReferencer:self];
        NSMapRemove(_actorsMap, *removed);
        removed++;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001125f8 @ 001125f8, 258 bytes * /

void FUN_001125f8(HSActionSequencerLastSelectedActorHolder *self,SEL _cmd,id setLastSequenceActor,
                 id forActor)

{
  id pvVar1;
  
  if (self->_actorsMap == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_zone);
    pvVar1 = (id)_NSCreateMapTableWithZone
                           (*(undefined8 *)PTR_00336398,*(undefined8 *)(PTR_00336398 + 8),
                            *(undefined8 *)(PTR_00336398 + 0x10),*(undefined4 *)PTR_00336594,
                            *(undefined4 *)(PTR_00336594 + 4),*(undefined4 *)(PTR_00336594 + 8),0,
                            pvVar1);
    self->_actorsMap = pvVar1;
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = (id)_NSMapGet(self->_actorsMap);
  }
  if (pvVar1 != setLastSequenceActor) {
    _objc_msgSend(pvVar1,sel_unregisterWeakReferencer_,self);
    if (pvVar1 == (id)0x0) {
      _objc_msgSend(forActor,sel_registerWeakReferencer_,self);
    }
    _objc_msgSend(setLastSequenceActor,sel_registerWeakReferencer_,self);
    _NSMapInsert(self->_actorsMap,forActor,setLastSequenceActor);
  }
  return;
}

*/
- (void)setLastSequenceActor:(id)aActor forActor:(id)aActor2
{
    id previous;
    if (_actorsMap == nil) {
        _actorsMap = NSCreateMapTableWithZone(NSNonOwnedPointerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0, [self zone]);
        previous = nil;
    }
    else {
        previous = NSMapGet(_actorsMap, aActor2);
    }
    if (previous != aActor) {
        [previous unregisterWeakReferencer:self];
        if (previous == nil) {
            [aActor2 registerWeakReferencer:self];
        }
        [aActor registerWeakReferencer:self];
        NSMapInsert(_actorsMap, aActor2, aActor);
    }
}

- (id)lastSequenceActorForActor:(id)aActor
{
    id pvVar1;

    if (_actorsMap == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = NSMapGet(_actorsMap,aActor);
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001123ae @ 001123ae, 222 bytes * /

void FUN_001123ae(HSActionSequencerLastSelectedActorHolder *self,SEL _cmd)

{
  char cVar1;
  int *piVar2;
  HSActionSequencerLastSelectedActorHolder *local_1c;
  undefined *local_18;
  
  piVar2 = (int *)&stack0xffffffb4;
  if (self->_actorsMap != (id)0x0) {
    _NSEnumerateMapTable();
    piVar2 = (int *)&stack0xffffffb0;
    while( true ) {
      cVar1 = _NSNextMapEnumeratorPair();
      if (cVar1 == '\0') break;
      _objc_msgSend((id)0x0,sel_unregisterWeakReferencer_);
      _objc_msgSend((id)0x0,sel_unregisterWeakReferencer_);
    }
    _NSEndMapTableEnumeration();
    _NSFreeMapTable();
  }
  local_1c = self;
  local_18 = PTR_s_NSObject_00350e70;
  piVar2[1] = (int)sel_dealloc;
  *piVar2 = (int)&local_1c;
  piVar2[-1] = 0x112484;
  _objc_msgSendSuper((void *)*piVar2,(SEL)piVar2[1]);
  return;
}

*/
- (void)dealloc
{
    if (_actorsMap != nil) {
        void *key = NULL;
        void *value = NULL;
        NSMapEnumerator enumerator = NSEnumerateMapTable(_actorsMap);
        while (NSNextMapEnumeratorPair(&enumerator, &key, &value)) {
            [(id)key unregisterWeakReferencer:self];
            [(id)value unregisterWeakReferencer:self];
        }
        NSEndMapTableEnumeration(&enumerator);
        NSFreeMapTable(_actorsMap);
    }
    [super dealloc];
}

@end

