#import "HSObjectListController.h"

static NSAttributedString *sCellTemplate = nil;
static NSRange sCellTemplateIdentifierRange;
static NSRange sCellTemplateTypeRange;

@implementation HSObjectListController

/* i386 ivar offsets: _view=0x4, _tableView=0x8, _statusBarTintedView=0xc, _flattenButton=0x10, _mergeButton=0x14, _deleteButton=0x18, _objectsCountField=0x1c, _objectListTableView=0x20, _topLevelParent=0x24, _displayedObjects=0x28, _selection=0x2c, _documentSelectionHolder=0x30, _cellValuesByIdentifier=0x34, _cellPreviewsByIdentifier=0x38, _isObservingObjectNotifications=0x3c, _displaysTopLevelParent=0x3d, _isChangingSelectionInTableView=0x3e, _isUpdatingSelectionToSyncWithExternalSelection=0x3f */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00089c74 @ 00089c74, 978 bytes * /

id FUN_00089c74(id self,SEL _cmd,id attributedStringWithObjectIdentifier,id type)

{
  undefined *puVar1;
  int iVar2;
  undefined4 uVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  cfstringStruct *pcVar9;
  cfstringStruct *pcVar10;
  
  if (DAT_0034281c == (id)0x0) {
    pvVar4 = _objc_msgSend(cls_NSBundle,sel_bundleForClass_,self);
    pcVar10 = &cfstr_rtf;
    pcVar9 = &cfstr_ObjectListCellTemplate;
    pcVar5 = _objc_msgSend(pvVar4,sel_pathForResource_ofType_,&cfstr_ObjectListCellTemplate,
                           &cfstr_rtf);
    if (pcVar5 == (cfstringStruct *)0x0) {
      pvVar4 = (id)0x0;
      pcVar5 = pcVar9;
    }
    else {
      pvVar4 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc,pcVar9,pcVar10);
      pcVar10 = (cfstringStruct *)0x0;
      pvVar4 = _objc_msgSend(pvVar4,sel_initWithPath_documentAttributes_,pcVar5,0);
      pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
    }
    pvVar6 = _objc_msgSend(pvVar4,sel_length,pcVar5,pcVar10);
    if (pvVar6 == (id)0x0) {
      pvVar4 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc,pcVar5,pcVar10);
      pcVar5 = &cfstr__;
      pvVar4 = _objc_msgSend(pvVar4,sel_initWithString_,&cfstr__);
      pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
    }
    pvVar6 = _objc_msgSend(pvVar4,sel_string,pcVar5,pcVar10);
    pcVar10 = &cfstr__Identifier_;
    DAT_00342820 = _objc_msgSend(pvVar6,sel_rangeOfString_,&cfstr__Identifier_);
    DAT_00342824 = extraout_EDX;
    if (DAT_00342820 == (id)0x7fffffff) {
      DAT_00342820 = (id)0x0;
      DAT_00342824 = 0;
    }
    pvVar6 = _objc_msgSend(pvVar4,sel_string,pcVar10);
    DAT_00342828 = _objc_msgSend(pvVar6,sel_rangeOfString_,&cfstr__ObjectType_);
    puVar1 = PTR_00336150;
    DAT_0034282c = extraout_EDX_00;
    if (DAT_00342828 == (id)0x7fffffff) {
      DAT_00342828 = (id)0x0;
      DAT_0034282c = 0;
    }
    pvVar6 = _objc_msgSend(pvVar4,sel_attribute_atIndex_effectiveRange_,*(undefined4 *)PTR_00336150,
                           0,0);
    pvVar6 = _objc_msgSend(pvVar6,sel_hyperParagraphStyleByChangingLineBreakMode_,4);
    pvVar7 = _objc_msgSend(pvVar4,sel_length);
    _objc_msgSend(pvVar4,sel_addAttribute_value_range_,*(undefined4 *)puVar1,pvVar6,0,pvVar7);
    DAT_0034281c = _objc_msgSend(pvVar4,sel_copy);
  }
  pvVar7 = _objc_msgSend(DAT_0034281c,sel_mutableCopy);
  uVar3 = DAT_0034282c;
  pvVar6 = DAT_00342828;
  iVar2 = DAT_00342824;
  pvVar4 = DAT_00342820;
  _objc_msgSend(pvVar7,sel_replaceCharactersInRange_withString_,DAT_00342820,DAT_00342824,
                attributedStringWithObjectIdentifier);
  pvVar8 = _objc_msgSend(attributedStringWithObjectIdentifier,sel_length);
  if (pvVar4 <= pvVar6) {
    pvVar6 = (id)(((int)pvVar6 - iVar2) + (int)pvVar8);
  }
  _objc_msgSend(pvVar7,sel_replaceCharactersInRange_withString_,pvVar6,uVar3,type);
  puVar1 = PTR_00336150;
  pvVar4 = _objc_msgSend(pvVar7,sel_attribute_atIndex_effectiveRange_,*(undefined4 *)PTR_00336150,0,
                         0);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperParagraphStyleByChangingLineBreakMode_,4);
  pvVar6 = _objc_msgSend(pvVar7,sel_length);
  _objc_msgSend(pvVar7,sel_addAttribute_value_range_,*(undefined4 *)puVar1,pvVar4,0,pvVar6);
  pvVar4 = _objc_msgSend(pvVar7,sel_copy);
  pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
  _objc_msgSend(pvVar7,sel_release);
  return pvVar4;
}

*/
+ (id)attributedStringWithObjectIdentifier:(id)aIdentifier type:(id)aType
{
    if (sCellTemplate == nil) {
        NSString *path = [[NSBundle bundleForClass:self] pathForResource:@"ObjectListCellTemplate" ofType:@"rtf"];
        NSMutableAttributedString *template = nil;
        if (path != nil) {
            template = [[[NSMutableAttributedString alloc] initWithPath:path documentAttributes:NULL] autorelease];
        }
        if ([template length] == 0) {
            template = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
        }
        sCellTemplateIdentifierRange = [[template string] rangeOfString:@"<Identifier>"];
        if (sCellTemplateIdentifierRange.location == NSNotFound) {
            sCellTemplateIdentifierRange = NSMakeRange(0, 0);
        }
        sCellTemplateTypeRange = [[template string] rangeOfString:@"<ObjectType>"];
        if (sCellTemplateTypeRange.location == NSNotFound) {
            sCellTemplateTypeRange = NSMakeRange(0, 0);
        }
        id style = [[template attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL] hyperParagraphStyleByChangingLineBreakMode:NSLineBreakByTruncatingTail];
        [template addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [template length])];
        sCellTemplate = [template copy];
    }
    NSMutableAttributedString *string = [sCellTemplate mutableCopy];
    NSRange typeRange = sCellTemplateTypeRange;
    [string replaceCharactersInRange:sCellTemplateIdentifierRange withString:aIdentifier];
    if (sCellTemplateIdentifierRange.location <= typeRange.location) {
        typeRange.location = typeRange.location - sCellTemplateIdentifierRange.length + [aIdentifier length];
    }
    [string replaceCharactersInRange:typeRange withString:aType];
    id style = [[string attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:NULL] hyperParagraphStyleByChangingLineBreakMode:NSLineBreakByTruncatingTail];
    [string addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [string length])];
    id result = [[string copy] autorelease];
    [string release];
    return result;
}

- (void)deleteForward:(id)aForward
{
    [self handleUserActionSelector:@selector(deleteSelectedCardObjects:)];
}

- (void)deleteBackward:(id)aBackward
{
    [self handleUserActionSelector:@selector(deleteSelectedCardObjects:)];
}

- (BOOL)keyboardHandlingView:(id)aView doCommandBySelector:(SEL)aSelector
{
    BOOL bVar2;

    bVar2 = [self respondsToSelector:aSelector];
    if (bVar2) {
        [self performSelector:aSelector withObject:0];
    }
    return bVar2;
}

- (void)deleteSelectedObjectsInPalette:(id)aPalette
{
    [self handleUserActionSelector:@selector(deleteSelectedCardObjects:)];
}

- (void)mergeSelectedObjectsInPalette:(id)aPalette
{
    [self handleUserActionSelector:@selector(mergeSelectionToImage:)];
}

- (void)flattenSelectedObjectsInPalette:(id)aPalette
{
    [self handleUserActionSelector:@selector(flatSelection:)];
}

- (void)validateUserInterface
{
    [self validateToolbarButtons];
}

- (void)validateToolbarButtons
{
    [self validateToolbarButton:_deleteButton withUserActionSelector:@selector(deleteSelectedCardObjects:)];
    [self validateToolbarButton:_mergeButton withUserActionSelector:@selector(mergeSelectionToImage:)];
    [self validateToolbarButton:_flattenButton withUserActionSelector:@selector(flatSelection:)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00089979 @ 00089979, 262 bytes * /

void FUN_00089979(HSObjectListController *self,SEL _cmd,id validateToolbarButton,
                 SEL withUserActionSelector)

{
  id pvVar1;
  id pvVar2;
  char cVar3;
  undefined *puVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  
  uVar6 = 0;
  uVar5 = 0;
  pvVar1 = _objc_msgSend(*(id *)PTR_00336058,sel_targetForAction_to_from_,withUserActionSelector,0,0
                        );
  if ((pvVar1 == (id)0x0) || (validateToolbarButton == (id)0x0)) {
    cVar3 = '\0';
  }
  else {
    puVar4 = sel_validateUserInterfaceItem_;
    pvVar2 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_validateUserInterfaceItem_,uVar5,uVar6
                          );
    if ((char)pvVar2 == '\0') {
      cVar3 = '\x01';
    }
    else {
      pvVar2 = _objc_msgSend(validateToolbarButton,sel_action,puVar4,uVar5,uVar6);
      _objc_msgSend(validateToolbarButton,sel_setAction_,withUserActionSelector);
      pvVar1 = _objc_msgSend(pvVar1,sel_validateUserInterfaceItem_,validateToolbarButton);
      cVar3 = (char)pvVar1;
      _objc_msgSend(validateToolbarButton,sel_setAction_,pvVar2);
    }
  }
  _objc_msgSend(validateToolbarButton,sel_setEnabled_,(int)cVar3,uVar5,uVar6);
  return;
}

*/
- (void)validateToolbarButton:(id)aButton withUserActionSelector:(SEL)aSelector
{
    id target = [NSApp targetForAction:aSelector to:nil from:nil];
    BOOL enabled = NO;
    if (target != nil && aButton != nil) {
        if (![target respondsToSelector:@selector(validateUserInterfaceItem:)]) {
            enabled = YES;
        }
        else {
            // Validate as if the button sent the user action itself.
            SEL action = [(NSButton *)aButton action];
            [aButton setAction:aSelector];
            enabled = [target validateUserInterfaceItem:aButton];
            [aButton setAction:action];
        }
    }
    [aButton setEnabled:enabled];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00089911 @ 00089911, 104 bytes * /

void FUN_00089911(HSObjectListController *self,SEL _cmd,SEL handleUserActionSelector)

{
  id self_00;
  undefined4 uVar1;
  
  uVar1 = 0;
  self_00 = _objc_msgSend(*(id *)PTR_00336058,sel_targetForAction_to_from_,handleUserActionSelector,
                          0,0);
  if (self_00 != (id)0x0) {
    _objc_msgSend(self_00,sel_performSelector_withObject_,handleUserActionSelector,0,uVar1);
  }
  return;
}

*/
- (void)handleUserActionSelector:(SEL)aSelector
{
    id target = [NSApp targetForAction:aSelector to:nil from:nil];
    if (target != nil) {
        [target performSelector:aSelector withObject:nil];
    }
}

- (BOOL)shouldDisplaySelection
{
    return ![[[HSApplicationController sharedDocumentController] currentDocument] isInPlayerMode];
}

- (NSInteger)rowForUserObject:(id)aObject
{
    NSUInteger pvVar1;

    if ((aObject != nil) && (pvVar1 = [self indexOfUserObject:aObject], pvVar1 != NSNotFound )) {
        return (int)pvVar1;
    }
    return NSNotFound;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000897ac @ 000897ac, 209 bytes * /

uint FUN_000897ac(HSObjectListController *self,SEL _cmd,id indexOfUserObject)

{
  id pvVar1;
  undefined *puVar2;
  id pvVar3;
  uint uVar4;
  undefined *puVar5;
  
  pvVar1 = _objc_msgSend(self,sel_displaysUserObject_,indexOfUserObject);
  if ((char)pvVar1 != '\0') {
    puVar5 = &DAT_00366768;
    puVar2 = _objc_msgSend(indexOfUserObject,sel_queryHyperInterface_,&DAT_00366768);
    uVar4 = 0;
    pvVar1 = _objc_msgSend(self,sel_userObjectEnumerator);
    while (pvVar3 = _objc_msgSend(pvVar1,sel_nextObject,puVar5), pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00366768);
      puVar5 = puVar2;
      pvVar3 = _objc_msgSend(pvVar3,sel_isEqual_,puVar2);
      if ((char)pvVar3 != '\0') {
        return uVar4;
      }
      uVar4 = uVar4 + 1;
    }
  }
  return 0x7fffffff;
}

*/
- (NSUInteger)indexOfUserObject:(id)aObject
{
    if ([self displaysUserObject:aObject]) {
        id node = [aObject queryHyperInterface:@protocol(HSNodeAttributes)];
        NSUInteger index = 0;
        NSEnumerator *enumerator = [self userObjectEnumerator];
        id object;
        while ((object = [enumerator nextObject]) != nil) {
            if ([[object queryHyperInterface:@protocol(HSNodeAttributes)] isEqual:node]) {
                return index;
            }
            index++;
        }
    }
    return NSNotFound;
}

- (void)invalidateDisplayedObjects
{
    [_displayedObjects release];
    _displayedObjects = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00089635 @ 00089635, 325 bytes * /

id FUN_00089635(HSObjectListController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  undefined *self_01;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = self->_displayedObjects;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self->_topLevelParent,sel_hyperDeepEnumerator);
    if (self->_displaysTopLevelParent == '\0') {
      _objc_msgSend(pvVar1,sel_nextObject);
    }
    self_00 = _objc_msgSend(cls_NSMutableArray,sel_new);
    self_01 = _objc_msgSend(pvVar1,sel_nextObject);
    while (self_01 != (undefined *)0x0) {
      puVar3 = &DAT_00366240;
      pvVar2 = _objc_msgSend(self_01,sel_queryHyperInterface_,&DAT_00366240);
      pvVar2 = _objc_msgSend(pvVar2,sel_isTemporary);
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(self_00,sel_addObject_,self_01);
        puVar3 = self_01;
      }
      self_01 = _objc_msgSend(pvVar1,sel_nextObject,puVar3);
    }
    pvVar1 = _objc_msgSend(cls_NSArray,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithArray_copyItems_,self_00,0);
    self->_displayedObjects = pvVar1;
    _objc_msgSend(self_00,sel_release);
    pvVar1 = self->_displayedObjects;
  }
  return pvVar1;
}

*/
- (id)displayedObjects
{
    if (_displayedObjects == nil) {
        NSEnumerator *enumerator = [_topLevelParent hyperDeepEnumerator];
        if (!_displaysTopLevelParent) {
            [enumerator nextObject];
        }
        NSMutableArray *objects = [NSMutableArray new];
        id object;
        while ((object = [enumerator nextObject]) != nil) {
            if (![[object queryHyperInterface:@protocol(HSNodeChild)] isTemporary]) {
                [objects addObject:object];
            }
        }
        _displayedObjects = [[NSArray alloc] initWithArray:objects copyItems:NO];
        [objects release];
    }
    return _displayedObjects;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000895b4 @ 000895b4, 129 bytes * /

void FUN_000895b4(HSObjectListController *self,SEL _cmd,id setSelectedObjects)

{
  undefined *puVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  puVar3 = &DAT_00366768;
  puVar1 = _objc_msgSend(setSelectedObjects,sel_queryAllHyperInterfaces_,&DAT_00366768);
  op = sel_set;
  if (puVar1 != (undefined *)0x0) {
    op = sel_setWithArray_;
    puVar3 = puVar1;
  }
  pvVar2 = _objc_msgSend(cls_NSSet,op,puVar3);
  _objc_msgSend(self,sel_updateTableViewWithObjectsInSet_addToSelection_,pvVar2,1);
  return;
}

*/
- (void)setSelectedObjects:(id)aObjects
{
    id nodes = [aObjects queryAllHyperInterfaces:@protocol(HSNodeAttributes)];
    [self updateTableViewWithObjectsInSet:(nodes != nil ? [NSSet setWithArray:nodes] : [NSSet set]) addToSelection:YES];
}

- (void)setSelectedObject:(id)aObject
{
    [self setSelectedObject:aObject row:[self rowForUserObject:aObject] byExtendingSelection:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000894e3 @ 000894e3, 124 bytes * /

void FUN_000894e3(HSObjectListController *self,SEL _cmd,id deselectObject)

{
  id pvVar1;
  id self_00;
  
  pvVar1 = _objc_msgSend(self,sel_rowForUserObject_,deselectObject);
  self_00 = _objc_msgSend(self,sel_selection);
  _objc_msgSend(self_00,sel_removeNode_,deselectObject);
  _objc_msgSend(self,sel_deselectRow_,pvVar1);
  return;
}

*/
- (void)deselectObject:(id)aObject
{
    NSInteger row = [self rowForUserObject:aObject];
    [(HSNodeSelection *)[self selection] removeNode:aObject];
    [self deselectRow:row];
}

- (void)deselectAllRows
{
    if (0 < (int)[_objectListTableView numberOfSelectedRows]) {
        _isChangingSelectionInTableView = YES;
        [_objectListTableView deselectAll:0];
        _isChangingSelectionInTableView = NO;
    }
    [self validateToolbarButtons];
}

- (void)deselectRow:(NSInteger)aRow
{
    if (aRow < (int)[_objectListTableView numberOfRows]) {
        _isChangingSelectionInTableView = YES;
        [_objectListTableView deselectRow:aRow];
        _isChangingSelectionInTableView = NO;
    }
    [self validateToolbarButtons];
}

- (void)selectRowInTableView:(NSInteger)aView byExtendingSelection:(BOOL)aSelection
{
    [self selectRowIndexesInTableView:[NSIndexSet indexSetWithIndex:aView] byExtendingSelection:aSelection];
}

- (void)selectRowIndexesInTableView:(id)aView byExtendingSelection:(BOOL)aSelection
{
    BOOL iVar3;

    _isChangingSelectionInTableView = YES;
    iVar3 = (int)aSelection;
    [_objectListTableView selectRowIndexes:aView byExtendingSelection:iVar3];
    if ([aView count] != 0) {
        [_objectListTableView scrollRowToVisible:[aView lastIndex]];
    }
    _isChangingSelectionInTableView = NO;
    [self validateToolbarButtons];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00089222 @ 00089222, 254 bytes * /

void FUN_00089222(HSObjectListController *self,SEL _cmd,id setSelectedObject,int row,
                 BOOL byExtendingSelection)

{
  id pvVar1;
  SEL op;
  int local_14;
  
  if (setSelectedObject == (id)0x0) {
LAB_00089238:
    local_14 = -1;
  }
  else {
    local_14 = row;
    pvVar1 = _objc_msgSend(self->_objectListTableView,sel_numberOfRows);
    if ((int)pvVar1 <= row) {
      setSelectedObject = (id)0x0;
      goto LAB_00089238;
    }
    if (row == -1) {
      setSelectedObject = (id)0x0;
    }
    else if (byExtendingSelection != '\0') goto LAB_000892a3;
  }
  pvVar1 = _objc_msgSend(self,sel_selection);
  _objc_msgSend(pvVar1,sel_removeAllNodes);
LAB_000892a3:
  if (setSelectedObject != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_selection);
    _objc_msgSend(pvVar1,sel_addNode_,setSelectedObject);
  }
  op = sel_deselectAllRows;
  if (local_14 != -1) {
    op = sel_selectRowInTableView_byExtendingSelection_;
  }
  _objc_msgSend(self,op);
  _objc_msgSend(self,sel_validateToolbarButtons);
  return;
}

*/
- (void)setSelectedObject:(id)aObject row:(NSInteger)aRow byExtendingSelection:(BOOL)aSelection
{
    id object = aObject;
    NSInteger row = aRow;

    if (object == nil || row >= [_objectListTableView numberOfRows]) {
        object = nil;
        row = -1;
        [[self selection] removeAllNodes];
    }
    else {
        if (row == -1) {
            object = nil;
        }
        if (row == -1 || !aSelection) {
            [[self selection] removeAllNodes];
        }
    }
    if (object != nil) {
        [[self selection] addNode:object];
    }
    if (row != -1) {
        [self selectRowInTableView:row byExtendingSelection:aSelection];
    }
    else {
        [self deselectAllRows];
    }
    [self validateToolbarButtons];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00089093 @ 00089093, 399 bytes * /

void FUN_00089093(HSObjectListController *self,SEL _cmd,id updateTableViewWithObjectsInSet,
                 BOOL addToSelection)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id local_14;
  
  self_00 = _objc_msgSend(self,sel_userObjectEnumerator);
  pvVar1 = _objc_msgSend(self->_objectListTableView,sel_numberOfRows);
  pvVar2 = _objc_msgSend(updateTableViewWithObjectsInSet,sel_count);
  if (addToSelection != '\0') {
    pvVar3 = _objc_msgSend(self,sel_selection);
    _objc_msgSend(pvVar3,sel_removeAllNodes);
  }
  pvVar3 = _objc_msgSend(cls_NSMutableIndexSet,sel_alloc);
  pvVar3 = _objc_msgSend(pvVar3,sel_init);
  local_14 = (id)0x0;
  for (pvVar6 = (id)0x0; pvVar6 < pvVar1; pvVar6 = (id)((int)pvVar6 + 1)) {
    pvVar4 = _objc_msgSend(self_00,sel_nextObject);
    if (pvVar4 == (id)0x0) break;
    if (local_14 < pvVar2) {
      pvVar5 = _objc_msgSend(updateTableViewWithObjectsInSet,sel_containsObject_,pvVar4);
      if ((char)pvVar5 != '\0') {
        pvVar5 = pvVar6;
        _objc_msgSend(pvVar3,sel_addIndex_,pvVar6);
        if (addToSelection != '\0') {
          pvVar5 = _objc_msgSend(self,sel_selection,pvVar5);
          _objc_msgSend(pvVar5,sel_addNode_,pvVar4);
        }
        local_14 = (id)((int)local_14 + 1);
      }
    }
  }
  _objc_msgSend(self,sel_selectRowIndexesInTableView_byExtendingSelection_,pvVar3,0);
  _objc_msgSend(pvVar3,sel_release);
  return;
}

*/
- (void)updateTableViewWithObjectsInSet:(id)aSet addToSelection:(BOOL)aSelection
{
    NSEnumerator *enumerator = [self userObjectEnumerator];
    NSInteger rowCount = [_objectListTableView numberOfRows];
    NSUInteger objectCount = [aSet count];
    NSUInteger found = 0;

    if (aSelection) {
        [[self selection] removeAllNodes];
    }
    NSMutableIndexSet *rows = [[NSMutableIndexSet alloc] init];
    for (NSInteger row = 0; row < rowCount; row++) {
        id object = [enumerator nextObject];
        if (object == nil) {
            break;
        }
        if (found < objectCount && [aSet containsObject:object]) {
            [rows addIndex:row];
            if (aSelection) {
                [[self selection] addNode:object];
            }
            found++;
        }
    }
    [self selectRowIndexesInTableView:rows byExtendingSelection:NO];
    [rows release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00088f5c @ 00088f5c, 311 bytes * /

void FUN_00088f5c(HSObjectListController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  HSObjectListController *self_00;
  SEL op;
  
  if (self->_objectListTableView != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_selection);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectsArray);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    pvVar2 = _objc_msgSend(self,sel_shouldDisplaySelection);
    op = sel_deselectAllRows;
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(cls_NSMutableIndexSet,sel_alloc);
      self_00 = _objc_msgSend(pvVar2,sel_init);
      while (pvVar2 = _objc_msgSend(pvVar1,sel_nextObject), pvVar2 != (id)0x0) {
        pvVar2 = _objc_msgSend(self,sel_rowForUserObject_,pvVar2);
        if (pvVar2 != (id)0x7fffffff) {
          _objc_msgSend(self_00,sel_addIndex_,pvVar2);
        }
      }
      _objc_msgSend(self,sel_selectRowIndexesInTableView_byExtendingSelection_,self_00,0);
      self = self_00;
      op = sel_release;
    }
    _objc_msgSend(self,op);
  }
  return;
}

*/
- (void)updateSelectionInTableViewWithCurrentSelection
{
    if (_objectListTableView == nil) {
        return;
    }
    NSEnumerator *enumerator = [[[self selection] objectsArray] objectEnumerator];
    if (![self shouldDisplaySelection]) {
        [self deselectAllRows];
        return;
    }
    NSMutableIndexSet *rows = [[NSMutableIndexSet alloc] init];
    id object;
    while ((object = [enumerator nextObject]) != nil) {
        NSInteger row = [self rowForUserObject:object];
        if (row != NSNotFound) {
            [rows addIndex:row];
        }
    }
    [self selectRowIndexesInTableView:rows byExtendingSelection:NO];
    [rows release];
}

- (void)updateSelectionWithCurrentSelectionInTableView
{
    NSUInteger pvVar2;
    id self_00;
    id pvVar3;
    NSInteger local_18;
    NSInteger pvVar1_2;

    [[self selection] removeAllNodes];
    pvVar1_2 = [_objectListTableView numberOfSelectedRows];
    pvVar2 = [_objectListTableView numberOfRows];
    local_18 = 0;
    self_00 = [self userObjectEnumerator];
    while ((local_18 < pvVar2 && (pvVar1_2 != 0))) {
        pvVar3 = [self_00 nextObject];
        if (pvVar3 == nil) break;
        if ([_objectListTableView isRowSelected:local_18]) {
            [self switchToEditor];
            [[self selection] addNode:pvVar3];
            pvVar1_2 = (pvVar1_2 + -1);
            if (pvVar1_2 == 0) break;
        }
        local_18 = (local_18 + 1);
    }
    [self validateToolbarButtons];
}

- (id)selection
{
    HSObjectListControllerNodeSelection *pHVar1;
    HSObjectListControllerNodeSelection *pHVar1_2;

    pHVar1 = _selection;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSObjectListControllerNodeSelection alloc] init];
        _selection = pHVar1_2;
        [pHVar1_2 setOwner:self];
        pHVar1 = _selection;
    }
    return pHVar1;
}

- (BOOL)tableView:(id)aView shouldSelectRow:(NSInteger)aRow
{
    BOOL bVar2;

    if (_documentSelectionHolder == nil) {
        bVar2 = NO;
    }
    else {
        bVar2 = ![[HSObjectListPaletteController sharedInstance] isHyperPaletteLocked];
    }
    return bVar2;
}

- (void)objectListTableViewDoubleAction:(id)aAction
{
    id pvVar1_2;

    pvVar1_2 = [[self selection] selectedObject];
    if (pvVar1_2 != nil) {
        [[HSObjectAssistantController sharedAssistantController] openDefaultEditingPaneForObject:pvVar1_2];
    }
}

- (void)objectListTableViewAction:(id)aAction
{

}

- (void)tableViewSelectionDidChange:(id)aChange
{
    if (_isChangingSelectionInTableView == NO) {
        [self updateSelectionWithCurrentSelectionInTableView];
        [_documentSelectionHolder makeCurrentSelectionHost:self];
        [self localNotifyHyperSelectionDidChange];
    }
    [self validateToolbarButtons];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008a1be @ 0008a1be, 2178 bytes * /

BOOL FUN_0008a1be(HSObjectListController *self,SEL _cmd,id tableView,id acceptDrop,int row,
                 uint dropOperation)

{
  int iVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  SEL op;
  undefined8 in_stack_ffffff4c;
  undefined8 uVar8;
  undefined4 uVar9;
  undefined8 in_stack_ffffff54;
  uint uVar12;
  longlong lVar10;
  undefined8 uVar11;
  undefined4 uVar13;
  char local_85 [17];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  uVar13 = (undefined4)((ulonglong)in_stack_ffffff4c >> 0x20);
  _objc_msgSend(self,sel_switchToEditor);
  uVar12 = (uint)((ulonglong)in_stack_ffffff54 >> 0x20);
  if (dropOperation == 0) {
    pvVar3 = _objc_msgSend(self,sel_userObjectAtRowIndex_,row);
    if (pvVar3 != (id)0x0) {
      uVar8 = CONCAT44(uVar13,&DAT_00366308);
      pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00366308);
      pvVar4 = _objc_msgSend(pvVar4,sel_isLocked);
      if ((char)pvVar4 == '\0') {
        pvVar4 = _objc_msgSend(acceptDrop,sel_draggingPasteboard,uVar8);
        uVar8 = CONCAT44((int)((ulonglong)uVar8 >> 0x20),&DAT_003663f8);
        pvVar7 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_003663f8);
        if ((char)pvVar7 == '\0') {
          uVar8 = CONCAT44((int)((ulonglong)uVar8 >> 0x20),&DAT_00366574);
          pvVar7 = _objc_msgSend(pvVar3,sel_implementsHyperInterface_,&DAT_00366574);
          if ((char)pvVar7 != '\0') {
            uVar8 = CONCAT44(1,pvVar4);
            pvVar7 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPasteboard_mediaGroup_,pvVar4,1);
            if (pvVar7 != (id)0x0) {
              pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00366574,
                                     (int)((ulonglong)uVar8 >> 0x20));
              _objc_msgSend(pvVar3,sel_setMedia_,pvVar7);
              pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00366894);
              local_85[1] = '\0';
              local_85[2] = '\0';
              local_85[3] = '\0';
              local_85[4] = '\0';
              local_85[5] = '\0';
              local_85[6] = '\0';
              local_85[7] = '\0';
              local_85[8] = '\0';
              local_85[9] = '\0';
              local_85[10] = '\0';
              local_85[0xb] = -0x80;
              local_85[0xc] = '?';
              local_85[0xd] = '\0';
              local_85[0xe] = '\0';
              local_85[0xf] = -0x80;
              local_85[0x10] = '?';
              uVar13 = 0;
              _objc_msgSend(pvVar4,sel_setRelativeMovieSourceRect_,0,0x3f8000003f800000);
              self = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036686c);
              pvVar3 = _objc_msgSend(pvVar7,sel_mediaName);
              pvVar3 = _objc_msgSend(pvVar3,sel_lastPathComponent);
              uVar8 = CONCAT44(uVar13,pvVar3);
              op = sel_setHyperComments_;
LAB_0008a3fa:
              _objc_msgSend(self,op,uVar8);
              return '\x01';
            }
          }
        }
        else {
          pvVar7 = _objc_msgSend(cls_NSImage,sel_alloc,uVar8);
          uVar8 = CONCAT44((int)((ulonglong)uVar8 >> 0x20),pvVar4);
          pvVar7 = _objc_msgSend(pvVar7,sel_initWithPasteboard_,pvVar4);
          pvVar7 = _objc_msgSend(pvVar7,sel_autorelease);
          if (pvVar7 != (id)0x0) {
            uVar8 = CONCAT44(1,pvVar4);
            pvVar5 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPasteboard_mediaGroup_,pvVar4,1);
            if (pvVar5 == (id)0x0) {
              in_stack_ffffff54 = CONCAT44(&cfstr_imageObject,pvVar3);
              uVar8 = CONCAT44(&cfstr_image,pvVar7);
              uVar13 = 0;
              pvVar7 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pvVar7,
                                     &cfstr_image,pvVar3,&cfstr_imageObject,0);
              if (pvVar7 != (id)0x0) {
                uVar9 = (undefined4)((ulonglong)uVar8 >> 0x20);
                pvVar4 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,pvVar4,uVar9,
                                       in_stack_ffffff54,uVar13);
                if (pvVar4 == (id)0x0) {
                  pvVar4 = (id)0x0;
                }
                else {
                  pvVar4 = _objc_msgSend(cls_HSEditorCardViewDragHelper,
                                         sel_commentsForDroppedObjectWithURL_,pvVar4,uVar9,
                                         in_stack_ffffff54,uVar13);
                }
                pvVar5 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0036686c,uVar9,
                                       in_stack_ffffff54,uVar13);
                _objc_msgSend(pvVar5,sel_appendHyperComments_,pvVar4);
                _objc_msgSend(pvVar3,sel_setHyperName_,pvVar4);
                uVar8 = CONCAT44(pvVar7,sel_replaceImageForGraphicObjectWithContextInfo_);
                op = sel_performSelector_withObject_afterDelay_;
                goto LAB_0008a3fa;
              }
            }
          }
        }
        uVar13 = (undefined4)((ulonglong)in_stack_ffffff54 >> 0x20);
        local_85[0] = '\0';
        pvVar7 = _objc_msgSend(self,sel_dragHelper,uVar8);
        uVar11 = CONCAT44(uVar13,local_85);
        uVar8 = CONCAT44(pvVar3,pvVar4);
        pvVar4 = _objc_msgSend(pvVar7,
                               sel_canRecieveDataFromPasteboard_acceptingObject_canConnectToObject_,
                               pvVar4,pvVar3,local_85);
        if (((char)pvVar4 != '\0') && (local_85[0] != '\0')) {
          pvVar4 = _objc_msgSend(self,sel_dragHelper,uVar8,uVar11);
          pvVar3 = _objc_msgSend(pvVar4,sel_performDragOperation_acceptingObject_,acceptDrop,pvVar3)
          ;
          return (BOOL)pvVar3;
        }
      }
    }
  }
  else if (dropOperation == 1) {
    pvVar3 = _objc_msgSend(acceptDrop,sel_draggingSource);
    if (pvVar3 != self->_objectListTableView) {
      pvVar3 = _objc_msgSend(self,sel_dragHelper);
      pvVar4 = _objc_msgSend(acceptDrop,sel_draggingPasteboard);
      lVar10 = (ulonglong)uVar12 << 0x20;
      uVar8 = CONCAT44(1,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,
                             sel_readSelectionFromPasteboard_useDragPreferences_didAddNewObject_,
                             pvVar4,1,0);
      cVar2 = (char)pvVar3;
      if (cVar2 == '\0') {
        return '\0';
      }
      pvVar3 = _objc_msgSend(self->_topLevelParent,sel_hyperCount,uVar8,lVar10);
      pvVar4 = _objc_msgSend(self,sel_selection);
      pvVar4 = _objc_msgSend(pvVar4,sel_nodesArray);
      pvVar7 = _objc_msgSend(pvVar4,sel_count);
      local_74 = 0;
      local_70 = 0;
      local_6c = (int *)0x0;
      local_68 = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      pvVar5 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_74,
                             local_50,0x10);
      if (pvVar5 == (id)0x0) {
        return cVar2;
      }
      iVar1 = *local_6c;
      do {
        pvVar6 = (id)0x0;
        do {
          if (iVar1 != *local_6c) {
            _objc_enumerationMutation(pvVar4);
          }
          _objc_msgSend(*(id *)(local_70 + (int)pvVar6 * 4),sel_setHyperIndex_,
                        (int)pvVar3 + (-(int)pvVar7 - row));
          pvVar6 = (id)((int)pvVar6 + 1);
        } while (pvVar6 < pvVar5);
        pvVar5 = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_74,
                               local_50,0x10);
      } while (pvVar5 != (id)0x0);
      return cVar2;
    }
    pvVar3 = _objc_msgSend(acceptDrop,sel_draggingPasteboard);
    pvVar3 = _objc_msgSend(pvVar3,sel_types);
    uVar8 = CONCAT44(uVar13,&cfstr_HSObjectListDraggingRowIndexesPboardType);
    pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,
                           &cfstr_HSObjectListDraggingRowIndexesPboardType);
    if ((char)pvVar3 != '\0') {
      pvVar3 = _objc_msgSend(acceptDrop,sel_draggingPasteboard,uVar8);
      uVar13 = (undefined4)((ulonglong)uVar8 >> 0x20);
      pvVar3 = _objc_msgSend(pvVar3,sel_propertyListForType_,
                             &cfstr_HSObjectListDraggingRowIndexesPboardType);
      uVar8 = CONCAT44(uVar13,&cfstr_RowIndexes);
      pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_RowIndexes);
      pvVar4 = _objc_msgSend(pvVar3,sel_count);
      if (pvVar4 == (id)0x0) {
        return '\x01';
      }
      pvVar4 = _objc_msgSend(self,sel_selection,uVar8);
      _objc_msgSend(pvVar4,sel_removeAllNodes);
      pvVar4 = _objc_msgSend(pvVar3,sel_count);
      if (pvVar4 != (id)0x0) {
        pvVar7 = (id)0x0;
        do {
          pvVar5 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar7);
          pvVar5 = _objc_msgSend(pvVar5,sel_intValue);
          pvVar5 = _objc_msgSend(self,sel_userObjectAtRowIndex_,pvVar5);
          pvVar6 = _objc_msgSend(self,sel_selection);
          _objc_msgSend(pvVar6,sel_addNode_,pvVar5);
          pvVar7 = (id)((int)pvVar7 + 1);
        } while (pvVar7 < pvVar4);
      }
      uVar8 = CONCAT44(row,pvVar3);
      op = sel_moveNodesAtRows_toRow_;
      goto LAB_0008a3fa;
    }
  }
  return '\0';
}

*/
- (BOOL)tableView:(id)aView acceptDrop:(id)aDrop row:(NSInteger)aRow dropOperation:(NSUInteger)aOperation
{
    [self switchToEditor];
    if (aOperation == NSTableViewDropOn) {
        id object = [self userObjectAtRowIndex:aRow];
        if (object == nil || [[object queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
            return NO;
        }
        NSPasteboard *pasteboard = [aDrop draggingPasteboard];
        if ([object implementsHyperInterface:@protocol(HSImageObjectAttributes)]) {
            NSImage *image = [[[NSImage alloc] initWithPasteboard:pasteboard] autorelease];
            if (image != nil && [HSNewMedia mediaWithPasteboard:pasteboard mediaGroup:1] == nil) {
                NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:image, @"image", object, @"imageObject", nil];
                if (info != nil) {
                    NSURL *url = [NSURL URLFromPasteboard:pasteboard];
                    id comments = url != nil ? [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:url] : nil;
                    [[object queryHyperInterface:@protocol(HSCommentsAttributes)] appendHyperComments:comments];
                    // The original names the object after the dropped file's comments as well.
                    [object setHyperName:comments];
                    [self performSelector:@selector(replaceImageForGraphicObjectWithContextInfo:) withObject:info afterDelay:0.0];
                    return YES;
                }
            }
        }
        else if ([object implementsHyperInterface:@protocol(HSMovieObjectAttributes)]) {
            id media = [HSNewMedia mediaWithPasteboard:pasteboard mediaGroup:1];
            if (media != nil) {
                id movieObject = [object queryHyperInterface:@protocol(HSMovieObjectAttributes)];
                [movieObject setMedia:media];
                [[movieObject queryHyperInterface:@protocol(HSMovieAttributes)] setRelativeMovieSourceRect:NSMakeRect(0.0, 0.0, 1.0, 1.0)];
                [[movieObject queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:[[media mediaName] lastPathComponent]];
                return YES;
            }
        }
        BOOL canConnect = NO;
        if ([[self dragHelper] canRecieveDataFromPasteboard:pasteboard acceptingObject:object canConnectToObject:&canConnect] && canConnect) {
            return [[self dragHelper] performDragOperation:aDrop acceptingObject:object];
        }
        return NO;
    }
    if (aOperation != NSTableViewDropAbove) {
        return NO;
    }
    if ([aDrop draggingSource] != _objectListTableView) {
        BOOL result = [[self dragHelper] readSelectionFromPasteboard:[aDrop draggingPasteboard] useDragPreferences:YES didAddNewObject:NULL];
        if (!result) {
            return NO;
        }
        NSUInteger topCount = [_topLevelParent hyperCount];
        NSArray *nodes = [[self selection] nodesArray];
        NSUInteger index = topCount - aRow - [nodes count];
        for (id node in nodes) {
            [node setHyperIndex:index];
        }
        return result;
    }
    if ([[[aDrop draggingPasteboard] types] containsObject:@"HSObjectListDraggingRowIndexesPboardType"]) {
        NSArray *rows = [[[aDrop draggingPasteboard] propertyListForType:@"HSObjectListDraggingRowIndexesPboardType"] objectForKey:@"RowIndexes"];
        if ([rows count] == 0) {
            return YES;
        }
        [[self selection] removeAllNodes];
        NSUInteger count = [rows count];
        for (NSUInteger i = 0; i < count; i++) {
            [[self selection] addNode:[self userObjectAtRowIndex:[[rows objectAtIndex:i] intValue]]];
        }
        [self moveNodesAtRows:rows toRow:aRow];
        return YES;
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008aa40 @ 0008aa40, 1245 bytes * /

void FUN_0008aa40(HSObjectListController *self,SEL _cmd,
                 id replaceImageForGraphicObjectWithContextInfo)

{
  float fVar1;
  undefined *puVar2;
  char cVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  id pvVar6;
  float *pfVar7;
  float extraout_EDX;
  float extraout_EDX_00;
  float fVar8;
  undefined8 in_stack_ffffff8c;
  undefined8 uVar9;
  float fVar11;
  undefined8 uVar10;
  undefined4 uVar12;
  float local_50;
  id local_4c;
  float local_34;
  float fStack_30;
  id local_2c;
  float fStack_28;
  float local_24;
  float local_20;
  id local_1c;
  float local_18;
  
  uVar12 = (undefined4)((ulonglong)in_stack_ffffff8c >> 0x20);
  pvVar4 = _objc_msgSend(replaceImageForGraphicObjectWithContextInfo,sel_objectForKey_,&cfstr_image)
  ;
  self_00 = _objc_msgSend(replaceImageForGraphicObjectWithContextInfo,sel_objectForKey_,
                          &cfstr_imageObject);
  uVar9 = CONCAT44(uVar12,&DAT_003667f4);
  pvVar5 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_003667f4);
  puVar2 = PTR_0033607c;
  local_4c = *(id *)PTR_0033607c;
  local_50 = *(float *)(PTR_0033607c + 4);
  if (pvVar5 != (id)0x0) {
    local_4c = _objc_msgSend(pvVar5,sel_size,uVar9);
    local_50 = extraout_EDX;
  }
  pvVar5 = _objc_msgSend(self_00,sel_isEnabledCacheImage,uVar9);
  if ((char)pvVar5 != '\0') {
    _objc_msgSend(self_00,sel_setEnabledCacheImageForAllGroupObjects_setUpUndoManager_,0,1);
  }
  pvVar6 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithImage_,pvVar4);
  _objc_msgSend(self_00,sel_setHyperEffectedMedia_refreshName_,pvVar6,0);
  uVar9 = 0x3f8000003f800000;
  uVar12 = 0;
  _objc_msgSend(self_00,sel_setRelativeImageRect_updateClipPaths_,0,0x3f8000003f800000,0);
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperPixelsSize);
  fVar11 = local_50;
  cVar3 = _NSEqualSizes(*(undefined4 *)puVar2,*(undefined4 *)(puVar2 + 4),local_4c,local_50);
  if (cVar3 != '\0') goto LAB_0008ae79;
  fVar11 = extraout_EDX_00;
  cVar3 = _NSEqualSizes(*(undefined4 *)puVar2,*(undefined4 *)(puVar2 + 4),pvVar4,extraout_EDX_00);
  if (cVar3 != '\0') goto LAB_0008ae79;
  fVar11 = extraout_EDX_00;
  cVar3 = _NSEqualSizes(local_4c,local_50,pvVar4,extraout_EDX_00);
  if (cVar3 != '\0') goto LAB_0008ae79;
  pvVar6 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  uVar9 = CONCAT44(fVar11,*(undefined4 *)PTR_00336190);
  pvVar6 = _objc_msgSend(pvVar6,sel_objectForKey_,*(undefined4 *)PTR_00336190);
  if (pvVar6 == (id)0x0) {
LAB_0008ad94:
    fVar8 = (float)pvVar4 / extraout_EDX_00;
    fVar11 = *(float *)PTR_00336078;
    fVar1 = *(float *)(PTR_00336078 + 4);
    if (fVar8 <= (float)local_4c / local_50) {
      local_1c = (id)(fVar8 * local_50);
      local_18 = local_50;
    }
    else {
      local_1c = local_4c;
      local_18 = (float)local_4c / fVar8;
    }
    local_24 = (((float)local_4c * 0.5 + fVar11) - ((float)local_1c * 0.5 + fVar11)) + fVar11;
    local_20 = ((local_50 * 0.5 + fVar1) - (local_18 * 0.5 + fVar1)) + fVar1;
    pfVar7 = &local_24;
  }
  else {
    pvVar6 = _objc_msgSend(pvVar6,sel_intValue,uVar9);
    if (pvVar6 != (id)0x2) goto LAB_0008ad94;
    fVar8 = (float)pvVar4 / extraout_EDX_00;
    fVar11 = *(float *)PTR_00336078;
    fVar1 = *(float *)(PTR_00336078 + 4);
    if ((float)local_4c / local_50 <= fVar8) {
      local_2c = (id)(fVar8 * local_50);
      fStack_28 = local_50;
    }
    else {
      local_2c = local_4c;
      fStack_28 = (float)local_4c / fVar8;
    }
    local_34 = (((float)local_4c * 0.5 + fVar11) - ((float)local_2c * 0.5 + fVar11)) + fVar11;
    fStack_30 = ((local_50 * 0.5 + fVar1) - (fStack_28 * 0.5 + fVar1)) + fVar1;
    pfVar7 = &local_34;
  }
  uVar10 = *(undefined8 *)pfVar7;
  uVar9 = *(undefined8 *)(pfVar7 + 2);
  uVar12 = 0;
  _objc_msgSend(self_00,sel_setImageRect_updateClipPaths_,uVar10,uVar9,0);
  fVar11 = (float)((ulonglong)uVar10 >> 0x20);
LAB_0008ae79:
  pvVar4 = _objc_msgSend(self_00,sel_queryHyperInterface_,&DAT_00366844,fVar11,uVar9,uVar12);
  _objc_msgSend(pvVar4,sel_removeAllClipPaths);
  _objc_msgSend(self_00,sel_dropInitialClipPaths);
  pvVar4 = _objc_msgSend(cls_HSImageCropApplier,sel_cropApplierForImageObject_,self_00);
  _objc_msgSend(pvVar4,sel_updateCurrentBorderPath);
  if ((char)pvVar5 != '\0') {
    _objc_msgSend(self_00,sel_setEnabledCacheImageForAllGroupObjects_setUpUndoManager_,1,1);
  }
  return;
}

*/
- (void)replaceImageForGraphicObjectWithContextInfo:(id)aInfo
{
    NSImage *image = [aInfo objectForKey:@"image"];
    id object = [aInfo objectForKey:@"imageObject"];
    id sizeAttributes = [object queryHyperInterface:@protocol(HSSizeAttributes)];
    NSSize size = NSZeroSize;
    if (sizeAttributes != nil) {
        size = [(id<HSSizeAttributes>)sizeAttributes size];
    }
    BOOL cachesImage = [object isEnabledCacheImage];
    if (cachesImage) {
        [object setEnabledCacheImageForAllGroupObjects:NO setUpUndoManager:YES];
    }
    [object setHyperEffectedMedia:[HSNewMedia mediaWithImage:image] refreshName:NO];
    [object setRelativeImageRect:NSMakeRect(0.0, 0.0, 1.0, 1.0) updateClipPaths:NO];
    NSSize pixelsSize = [image hyperPixelsSize];
    if (!NSEqualSizes(NSZeroSize, size) && !NSEqualSizes(NSZeroSize, pixelsSize) && !NSEqualSizes(size, pixelsSize)) {
        float ratio = (float)(pixelsSize.width / pixelsSize.height);
        float objectRatio = (float)(size.width / size.height);
        NSSize imageSize;
        // Layout 2 fills the object; anything else fits the image inside it.
        BOOL fill = [[[NSUserDefaults standardUserDefaults] objectForKey:HSImportedImageLayoutKey] intValue] == 2;
        if (fill ? objectRatio <= ratio : ratio <= objectRatio) {
            imageSize = NSMakeSize(ratio * size.height, size.height);
        }
        else {
            imageSize = NSMakeSize(size.width, size.width / ratio);
        }
        NSRect rect = NSMakeRect(NSZeroRect.origin.x + size.width * 0.5 - imageSize.width * 0.5, NSZeroRect.origin.y + size.height * 0.5 - imageSize.height * 0.5, imageSize.width, imageSize.height);
        [object setImageRect:rect updateClipPaths:NO];
    }
    [[object queryHyperInterface:@protocol(HSMutableClipPathsAttributes)] removeAllClipPaths];
    [object dropInitialClipPaths];
    [[HSImageCropApplier cropApplierForImageObject:object] updateCurrentBorderPath];
    if (cachesImage) {
        [object setEnabledCacheImageForAllGroupObjects:YES setUpUndoManager:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00088846 @ 00088846, 1077 bytes * /

void FUN_00088846(HSObjectListController *self,SEL _cmd,id moveNodesAtRows,int toRow)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  SEL op;
  int local_14;
  
  pvVar1 = _objc_msgSend(cls_HSSelectionOperationVerifier,sel_alloc);
  pvVar2 = _objc_msgSend(self,sel_selection);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithSelection_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar1,sel_selectedNodesArrayForOrderOperation);
  _objc_msgSend(pvVar1,sel_release);
  if (pvVar3 != (id)0x0) {
    pvVar1 = _objc_msgSend(moveNodesAtRows,sel_count,pvVar2);
    pvVar4 = _objc_msgSend(cls_NSMutableArray,sel_array);
    self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
    if (pvVar1 == (id)0x0) {
      local_14 = 0;
    }
    else {
      local_14 = 0;
      pvVar11 = (id)0x0;
      do {
        pvVar2 = _objc_msgSend(moveNodesAtRows,sel_objectAtIndex_,pvVar11);
        pvVar5 = _objc_msgSend(pvVar2,sel_intValue);
        pvVar6 = _objc_msgSend(self,sel_userObjectAtRowIndex_,pvVar5);
        pvVar2 = pvVar6;
        pvVar7 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar6);
        if ((char)pvVar7 != '\0') {
          pvVar2 = _objc_msgSend(moveNodesAtRows,sel_objectAtIndex_,pvVar11);
          _objc_msgSend(pvVar4,sel_addObject_,pvVar2);
          pvVar2 = _objc_msgSend(self,sel_displaysNodesInReverseOrder);
          op = sel_addObject_;
          if ((char)pvVar2 != '\0') {
            op = sel_insertObject_atIndex_;
          }
          _objc_msgSend(self_00,op,pvVar6);
          local_14 = (uint)((int)pvVar5 < toRow) + local_14;
          pvVar2 = pvVar6;
        }
        pvVar11 = (id)((int)pvVar11 + 1);
      } while (pvVar11 < pvVar1);
    }
    pvVar2 = _objc_msgSend(pvVar4,sel_count,pvVar2);
    pvVar1 = _objc_msgSend(self,
                           sel_newUserObjectIndexesForMovingRows_aboveRow_countOfRowsBeforeTargetRow_
                           ,pvVar4,toRow,local_14);
    pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar11 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_array);
    pvVar6 = _objc_msgSend(cls_NSMutableArray,sel_array);
    if (pvVar2 != (id)0x0) {
      pvVar7 = (id)0x0;
      do {
        pvVar4 = _objc_msgSend(self_00,sel_objectAtIndex_,pvVar7);
        pvVar8 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00366768);
        pvVar4 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar7);
        pvVar9 = _objc_msgSend(pvVar8,sel_hyperIndex);
        pvVar10 = _objc_msgSend(pvVar4,sel_unsignedIntValue);
        if (pvVar10 < pvVar9) {
          _objc_msgSend(pvVar5,sel_addObject_,pvVar8);
          pvVar8 = pvVar6;
        }
        else {
          _objc_msgSend(pvVar3,sel_addObject_,pvVar8);
          pvVar8 = pvVar11;
        }
        _objc_msgSend(pvVar8,sel_addObject_,pvVar4);
        pvVar7 = (id)((int)pvVar7 + 1);
      } while (pvVar7 < pvVar2);
    }
    pvVar2 = _objc_msgSend(pvVar11,sel_reverseObjectEnumerator,pvVar4);
    pvVar1 = _objc_msgSend(pvVar3,sel_reverseObjectEnumerator);
    _objc_msgSend(self,sel_moveNodesInEnumerator_toIndexesInEnumerator_,pvVar1,pvVar2);
    pvVar2 = _objc_msgSend(pvVar6,sel_objectEnumerator);
    pvVar1 = _objc_msgSend(pvVar5,sel_objectEnumerator);
    _objc_msgSend(self,sel_moveNodesInEnumerator_toIndexesInEnumerator_,pvVar1,pvVar2);
  }
  return;
}

*/
- (void)moveNodesAtRows:(id)aRows toRow:(NSInteger)aRow
{
    HSSelectionOperationVerifier *verifier = [[HSSelectionOperationVerifier alloc] initWithSelection:[self selection]];
    NSArray *orderable = [verifier selectedNodesArrayForOrderOperation];
    [verifier release];
    if (orderable == nil) {
        return;
    }
    NSUInteger count = [aRows count];
    NSMutableArray *rows = [NSMutableArray array];
    NSMutableArray *nodes = [NSMutableArray array];
    NSUInteger rowsBeforeTarget = 0;
    for (NSUInteger i = 0; i < count; i++) {
        int row = [[aRows objectAtIndex:i] intValue];
        id node = [self userObjectAtRowIndex:row];
        if ([orderable containsObject:node]) {
            [rows addObject:[aRows objectAtIndex:i]];
            if ([self displaysNodesInReverseOrder]) {
                [nodes insertObject:node atIndex:0];
            }
            else {
                [nodes addObject:node];
            }
            if (row < aRow) {
                rowsBeforeTarget++;
            }
        }
    }
    NSUInteger moveCount = [rows count];
    NSArray *indexes = [self newUserObjectIndexesForMovingRows:rows aboveRow:aRow countOfRowsBeforeTargetRow:rowsBeforeTarget];
    NSMutableArray *forwardNodes = [NSMutableArray array];
    NSMutableArray *forwardIndexes = [NSMutableArray array];
    NSMutableArray *backwardNodes = [NSMutableArray array];
    NSMutableArray *backwardIndexes = [NSMutableArray array];
    for (NSUInteger i = 0; i < moveCount; i++) {
        id node = [[nodes objectAtIndex:i] queryHyperInterface:@protocol(HSNodeAttributes)];
        id index = [indexes objectAtIndex:i];
        if ([index unsignedIntValue] < (NSUInteger)[node hyperIndex]) {
            [backwardNodes addObject:node];
            [backwardIndexes addObject:index];
        }
        else {
            [forwardNodes addObject:node];
            [forwardIndexes addObject:index];
        }
    }
    // Nodes moving up go last-first, nodes moving down first-last, so earlier moves don't shift later targets.
    [self moveNodesInEnumerator:[forwardNodes reverseObjectEnumerator] toIndexesInEnumerator:[forwardIndexes reverseObjectEnumerator]];
    [self moveNodesInEnumerator:[backwardNodes objectEnumerator] toIndexesInEnumerator:[backwardIndexes objectEnumerator]];
}

- (void)moveNodesInEnumerator:(id)aEnumerator toIndexesInEnumerator:(id)aEnumerator2
{
    id pvVar1;
    id pvVar2;

    pvVar1 = [aEnumerator nextObject];
    while (pvVar1 != nil) {
        pvVar2 = [aEnumerator2 nextObject];
        [[pvVar1 queryHyperInterface:@protocol(HSNodeAttributes)] setHyperIndex:[pvVar2 unsignedIntValue]];
        pvVar1 = [aEnumerator nextObject];
    }
    [self switchToEditor];
}

- (NSUInteger)userObjectIndexForRowIndex:(NSInteger)aIndex
{
    if ([self displaysNodesInReverseOrder]) {
        aIndex = (int)[self userObjectCount] + ~aIndex;
    }
    return aIndex;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00088608 @ 00088608, 306 bytes * /

id FUN_00088608(HSObjectListController *self,SEL _cmd,id newUserObjectIndexesForMovingRows,
               int aboveRow,uint countOfRowsBeforeTargetRow)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  int iVar4;
  id pvVar5;
  SEL op;
  
  pvVar1 = _objc_msgSend(newUserObjectIndexesForMovingRows,sel_count);
  pvVar3 = pvVar1;
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,pvVar1);
  if (pvVar1 != (id)0x0) {
    iVar4 = (countOfRowsBeforeTargetRow - 1) - aboveRow;
    pvVar5 = (id)0x0;
    do {
      pvVar2 = _objc_msgSend(self,sel_displaysNodesInReverseOrder,pvVar3);
      if ((char)pvVar2 == '\0') {
        pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedInt_,
                               (aboveRow - countOfRowsBeforeTargetRow) + (int)pvVar5);
        op = sel_addObject_;
      }
      else {
        pvVar3 = _objc_msgSend(self,sel_userObjectCount,pvVar3);
        pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithUnsignedInt_,(int)pvVar3 + iVar4);
        op = sel_insertObject_atIndex_;
      }
      _objc_msgSend(self_00,op,pvVar3);
      iVar4 = iVar4 + -1;
      pvVar5 = (id)((int)pvVar5 + 1);
    } while (pvVar5 < pvVar1);
  }
  return self_00;
}

*/
- (id)newUserObjectIndexesForMovingRows:(id)aRows aboveRow:(NSInteger)aRow countOfRowsBeforeTargetRow:(NSUInteger)aRow2
{
    NSUInteger count = [aRows count];
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:count];
    int reverseOffset = (int)aRow2 - 1 - (int)aRow;
    // Despite the name the array is autoreleased, as in the original.
    for (NSUInteger i = 0; i < count; i++) {
        if ([self displaysNodesInReverseOrder]) {
            [indexes insertObject:[NSNumber numberWithUnsignedInt:(unsigned int)((int)[self userObjectCount] + reverseOffset)] atIndex:0];
        }
        else {
            [indexes addObject:[NSNumber numberWithUnsignedInt:(unsigned int)((int)aRow - (int)aRow2 + (int)i)]];
        }
        reverseOffset--;
    }
    return indexes;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008825c @ 0008825c, 940 bytes * /

uint FUN_0008825c(HSObjectListController *self,SEL _cmd,id tableView,id validateDrop,int proposedRow
                 ,uint proposedDropOperation)

{
  id pvVar1;
  id pvVar2;
  undefined *self_00;
  id pvVar3;
  SEL op;
  cfstringStruct *pcVar4;
  undefined *puVar5;
  char *pcVar6;
  char local_11;
  
  pvVar1 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
  pvVar1 = _objc_msgSend(pvVar1,sel_documents);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 != (id)0x0) {
    if (proposedDropOperation == 0) {
      local_11 = '\0';
      pvVar1 = _objc_msgSend(self,sel_dragHelper);
      pvVar2 = _objc_msgSend(self,sel_userObjectAtRowIndex_,proposedRow);
      pvVar3 = _objc_msgSend(validateDrop,sel_draggingPasteboard);
      pcVar6 = &local_11;
      pvVar1 = _objc_msgSend(pvVar1,
                             sel_canRecieveDataFromPasteboard_acceptingObject_canConnectToObject_,
                             pvVar3,pvVar2,pcVar6);
      if (((char)pvVar1 != '\0') && (local_11 != '\0')) {
        return 4;
      }
      pvVar1 = _objc_msgSend(self,sel_userObjectAtRowIndex_,proposedRow,pvVar2,pcVar6);
      if (pvVar1 != (id)0x0) {
        pvVar3 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00366308,pvVar2,pcVar6);
        pvVar3 = _objc_msgSend(pvVar3,sel_isLocked);
        if ((char)pvVar3 == '\0') {
          puVar5 = &DAT_003663f8;
          pvVar3 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_003663f8,pvVar2,pcVar6);
          self_00 = cls_NSImage;
          if ((char)pvVar3 == '\0') {
            puVar5 = &DAT_00366574;
            pvVar1 = _objc_msgSend(pvVar1,sel_implementsHyperInterface_,&DAT_00366574);
            self_00 = cls_HSNewMedia;
            if ((char)pvVar1 == '\0') {
              return 0;
            }
            pvVar1 = _objc_msgSend(validateDrop,sel_draggingPasteboard,puVar5);
            pvVar2 = (id)0x1;
            op = sel_canInitMediaWithPasteboard_mediaGroup_;
          }
          else {
            pvVar1 = _objc_msgSend(validateDrop,sel_draggingPasteboard,puVar5);
            op = sel_canInitWithPasteboard_;
          }
          goto LAB_00088599;
        }
      }
    }
    else if (proposedDropOperation == 1) {
      pvVar1 = _objc_msgSend(validateDrop,sel_draggingSource);
      if (pvVar1 != self->_objectListTableView) {
        self_00 = _objc_msgSend(self,sel_dragHelper);
        pvVar1 = _objc_msgSend(validateDrop,sel_draggingPasteboard);
        pcVar6 = (char *)0x0;
        pvVar2 = (id)0x0;
        op = sel_canRecieveDataFromPasteboard_acceptingObject_canConnectToObject_;
LAB_00088599:
        pvVar1 = _objc_msgSend(self_00,op,pvVar1,pvVar2,pcVar6);
        return (uint)((char)pvVar1 != '\0') << 2;
      }
      pvVar1 = _objc_msgSend(validateDrop,sel_draggingPasteboard);
      pvVar1 = _objc_msgSend(pvVar1,sel_types);
      pcVar4 = &cfstr_HSObjectListDraggingRowIndexesPboardType;
      pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,
                             &cfstr_HSObjectListDraggingRowIndexesPboardType);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(validateDrop,sel_draggingPasteboard,pcVar4);
        pvVar1 = _objc_msgSend(pvVar1,sel_propertyListForType_,
                               &cfstr_HSObjectListDraggingRowIndexesPboardType);
        pvVar2 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_RowIndexesAreContiguous);
        pvVar2 = _objc_msgSend(pvVar2,sel_intValue);
        if (pvVar2 == (id)0x0) {
          return 0x10;
        }
        pcVar4 = &cfstr_RowIndexes;
        pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_RowIndexes);
        pvVar2 = _objc_msgSend(pvVar1,sel_extraFirstObject);
        pvVar2 = _objc_msgSend(pvVar2,sel_intValue);
        if (pvVar2 != (id)proposedRow) {
          pvVar1 = _objc_msgSend(pvVar1,sel_lastObject,pcVar4);
          pvVar1 = _objc_msgSend(pvVar1,sel_intValue);
          return (uint)((int)pvVar1 + 1 != proposedRow) << 4;
        }
      }
    }
  }
  return 0;
}

*/
- (NSUInteger)tableView:(id)aView validateDrop:(id)aDrop proposedRow:(NSInteger)aRow proposedDropOperation:(NSUInteger)aOperation
{
    if ([[[NSDocumentController sharedDocumentController] documents] count] == 0) {
        return NSDragOperationNone;
    }
    if (aOperation == NSTableViewDropOn) {
        BOOL canConnect = NO;
        if ([[self dragHelper] canRecieveDataFromPasteboard:[aDrop draggingPasteboard] acceptingObject:[self userObjectAtRowIndex:aRow] canConnectToObject:&canConnect] && canConnect) {
            return NSDragOperationGeneric;
        }
        id object = [self userObjectAtRowIndex:aRow];
        if (object == nil || [[object queryHyperInterface:@protocol(HSCardObjectAttributes)] isLocked]) {
            return NSDragOperationNone;
        }
        if ([object implementsHyperInterface:@protocol(HSImageObjectAttributes)]) {
            return [NSImage canInitWithPasteboard:[aDrop draggingPasteboard]] ? NSDragOperationGeneric : NSDragOperationNone;
        }
        if ([object implementsHyperInterface:@protocol(HSMovieObjectAttributes)]) {
            return [HSNewMedia canInitMediaWithPasteboard:[aDrop draggingPasteboard] mediaGroup:1] ? NSDragOperationGeneric : NSDragOperationNone;
        }
        return NSDragOperationNone;
    }
    if (aOperation != NSTableViewDropAbove) {
        return NSDragOperationNone;
    }
    if ([aDrop draggingSource] != _objectListTableView) {
        return [[self dragHelper] canRecieveDataFromPasteboard:[aDrop draggingPasteboard] acceptingObject:nil canConnectToObject:NULL] ? NSDragOperationGeneric : NSDragOperationNone;
    }
    if (![[[aDrop draggingPasteboard] types] containsObject:@"HSObjectListDraggingRowIndexesPboardType"]) {
        return NSDragOperationNone;
    }
    NSDictionary *info = [[aDrop draggingPasteboard] propertyListForType:@"HSObjectListDraggingRowIndexesPboardType"];
    if ([[info objectForKey:@"RowIndexesAreContiguous"] intValue] == 0) {
        return NSDragOperationMove;
    }
    // A contiguous block dropped onto its own edges does not move.
    NSArray *rows = [info objectForKey:@"RowIndexes"];
    if ([[rows extraFirstObject] intValue] == aRow) {
        return NSDragOperationNone;
    }
    return [[rows lastObject] intValue] + 1 != aRow ? NSDragOperationMove : NSDragOperationNone;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008809e @ 0008809e, 446 bytes * /

BOOL FUN_0008809e(HSObjectListController *self,SEL _cmd,id tableView,id writeRowsWithIndexes,
                 id toPasteboard)

{
  bool bVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id self_01;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id local_18;
  
  pvVar2 = _objc_msgSend(writeRowsWithIndexes,sel_count);
  pvVar3 = _objc_msgSend(self,sel_userObjectCount);
  bVar1 = true;
  local_18 = (id)0x0;
  self_01 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,pvVar2);
  pvVar6 = (id)0x7fffffff;
  for (pvVar7 = (id)0x0; pvVar7 < pvVar3; pvVar7 = (id)((int)pvVar7 + 1)) {
    pvVar4 = _objc_msgSend(writeRowsWithIndexes,sel_containsIndex_,pvVar7);
    pvVar5 = pvVar6;
    if ((char)pvVar4 != '\0') {
      pvVar5 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,pvVar7);
      _objc_msgSend(self_01,sel_addObject_,pvVar5);
      local_18 = (id)((int)local_18 + 1);
      pvVar5 = pvVar7;
      if (((pvVar6 != (id)0x7fffffff) && (bVar1)) && (pvVar7 != (id)((int)pvVar6 + 1))) {
        bVar1 = false;
      }
    }
    if (local_18 == pvVar2) break;
    pvVar6 = pvVar5;
  }
  self_00 = cls_NSDictionary;
  pvVar6 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,(uint)bVar1);
  pvVar6 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,self_01,&cfstr_RowIndexes,pvVar6,
                         &cfstr_RowIndexesAreContiguous,0);
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,
                         &cfstr_HSObjectListDraggingRowIndexesPboardType);
  _objc_msgSend(toPasteboard,sel_declareTypes_owner_,pvVar2,0);
  pvVar6 = _objc_msgSend(toPasteboard,sel_setPropertyList_forType_,pvVar6,
                         &cfstr_HSObjectListDraggingRowIndexesPboardType);
  return (BOOL)pvVar6;
}

*/
- (BOOL)tableView:(id)aView writeRowsWithIndexes:(id)aIndexes toPasteboard:(id)aPasteboard
{
    NSUInteger count = [aIndexes count];
    NSUInteger objectCount = [self userObjectCount];
    BOOL contiguous = YES;
    NSUInteger found = 0;
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:count];
    NSUInteger previous = NSNotFound;
    for (NSUInteger i = 0; i < objectCount; i++) {
        if ([aIndexes containsIndex:i]) {
            [rows addObject:[NSNumber numberWithInt:(int)i]];
            found++;
            if (previous != NSNotFound && contiguous && i != previous + 1) {
                contiguous = NO;
            }
            previous = i;
        }
        if (found == count) {
            break;
        }
    }
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:rows, @"RowIndexes", [NSNumber numberWithInt:contiguous], @"RowIndexesAreContiguous", nil];
    [aPasteboard declareTypes:[NSArray arrayWithObject:@"HSObjectListDraggingRowIndexesPboardType"] owner:nil];
    return [aPasteboard setPropertyList:info forType:@"HSObjectListDraggingRowIndexesPboardType"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00088004 @ 00088004, 154 bytes * /

id FUN_00088004(HSObjectListController *self,SEL _cmd,id tableView,id objectValueForTableColumn,
               int row)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  
  pvVar1 = _objc_msgSend(tableView,sel_tableColumns);
  pvVar1 = _objc_msgSend(pvVar1,sel_indexOfObject_,objectValueForTableColumn);
  pvVar2 = _objc_msgSend(self,sel_userObjectAtRowIndex_,row);
  if ((pvVar2 == (id)0x0) ||
     ((op = sel_cellValueForObject_, pvVar1 != (id)0x1 &&
      (op = sel_cellPreviewForObject_, pvVar1 != (id)0x0)))) {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self,op,pvVar2);
  }
  return pvVar1;
}

*/
- (id)tableView:(id)aView objectValueForTableColumn:(id)aColumn row:(NSInteger)aRow
{
    NSUInteger column = [[aView tableColumns] indexOfObject:aColumn];
    id object = [self userObjectAtRowIndex:aRow];
    if (object == nil) {
        return nil;
    }
    if (column == 1) {
        return [self cellValueForObject:object];
    }
    if (column == 0) {
        return [self cellPreviewForObject:object];
    }
    return nil;
}

- (NSInteger)numberOfRowsInTableView:(id)aView
{
    return (int)[self userObjectCount];
}

- (id)objectListTableView
{
    return _objectListTableView;
}

- (void)selectionDidChange:(id)aChange wasExpanded:(BOOL)aExpanded
{
    if (_isUpdatingSelectionToSyncWithExternalSelection == NO) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSNodeSelectionDidChangeNotification" object:aChange];
    }
    else {
        _isChangingSelectionInTableView = YES;
        [self updateSelectionInTableViewWithCurrentSelection];
        _isChangingSelectionInTableView = NO;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00087c73 @ 00087c73, 758 bytes * /

void FUN_00087c73(HSObjectListController *self,SEL _cmd,id nodeContainerDidRemoveChild)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  bool bVar6;
  SEL op;
  
  pvVar1 = _objc_msgSend(nodeContainerDidRemoveChild,sel_object);
  pvVar2 = _objc_msgSend(nodeContainerDidRemoveChild,sel_userInfo);
  pvVar3 = _objc_msgSend(pvVar2,sel_valueForKey_,&cfstr_HSNodeChildrenForRemoval);
  pvVar4 = _objc_msgSend(pvVar3,sel_count);
  pvVar2 = self->_topLevelParent;
  pvVar5 = _objc_msgSend(pvVar1,sel_isEqual_,pvVar2);
  if (pvVar4 == (id)0x0) {
    if (((char)pvVar5 != '\0') ||
       (pvVar3 = _objc_msgSend(self,sel_displaysUserObject_,pvVar1), pvVar2 = pvVar1,
       (char)pvVar3 != '\0')) {
      _objc_msgSend(self,sel_invalidateDisplayedObjects,pvVar2);
      _objc_msgSend(self->_objectListTableView,sel_noteNumberOfRowsChanged);
      _objc_msgSend(self->_objectListTableView,sel_reloadData);
      pvVar2 = _objc_msgSend(self,sel_selection);
      pvVar2 = _objc_msgSend(pvVar2,sel_nodes);
      _objc_msgSend(self,sel_updateTableViewWithObjectsInSet_addToSelection_,pvVar2,0);
      _objc_msgSend(self,sel_didChangeNumberOfDisplayedItems);
    }
  }
  else if (((char)pvVar5 != '\0') ||
          (pvVar4 = _objc_msgSend(self,sel_displaysUserObject_,pvVar1), pvVar2 = pvVar1,
          (char)pvVar4 != '\0')) {
    pvVar1 = _objc_msgSend(pvVar3,sel_objectEnumerator,pvVar2);
    pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
    while (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_selection);
      pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar2);
      bVar6 = (char)pvVar3 != '\0';
      if (bVar6) {
        _objc_msgSend(self,sel_deselectObject_,pvVar2);
      }
      _objc_msgSend(self,sel_invalidateObject_,pvVar2);
      _objc_msgSend(self,sel_invalidateDisplayedObjects);
      self->_isChangingSelectionInTableView = '\x01';
      _objc_msgSend(self->_objectListTableView,sel_noteNumberOfRowsChanged);
      _objc_msgSend(self->_objectListTableView,sel_reloadData);
      self->_isChangingSelectionInTableView = '\0';
      op = sel_localNotifyHyperSelectionDidChange;
      if (!bVar6) {
        pvVar2 = _objc_msgSend(self,sel_selection,pvVar2);
        pvVar2 = _objc_msgSend(pvVar2,sel_nodes);
        op = sel_updateTableViewWithObjectsInSet_addToSelection_;
      }
      _objc_msgSend(self,op,pvVar2);
      _objc_msgSend(self,sel_didChangeNumberOfDisplayedItems);
      pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
    }
  }
  return;
}

*/
- (void)nodeContainerDidRemoveChild:(id)aChild
{
    id container = [aChild object];
    NSArray *removed = [[aChild userInfo] valueForKey:@"HSNodeChildrenForRemoval"];
    BOOL isTopLevel = [container isEqual:_topLevelParent];

    if ([removed count] == 0) {
        if (isTopLevel || [self displaysUserObject:container]) {
            [self invalidateDisplayedObjects];
            [_objectListTableView noteNumberOfRowsChanged];
            [_objectListTableView reloadData];
            [self updateTableViewWithObjectsInSet:[[self selection] nodes] addToSelection:NO];
            [self didChangeNumberOfDisplayedItems];
        }
    }
    else if (isTopLevel || [self displaysUserObject:container]) {
        NSEnumerator *enumerator = [removed objectEnumerator];
        id child;
        while ((child = [enumerator nextObject]) != nil) {
            BOOL wasSelected = [[self selection] containsObject:child];
            if (wasSelected) {
                [self deselectObject:child];
            }
            [self invalidateObject:child];
            [self invalidateDisplayedObjects];
            _isChangingSelectionInTableView = YES;
            [_objectListTableView noteNumberOfRowsChanged];
            [_objectListTableView reloadData];
            _isChangingSelectionInTableView = NO;
            if (wasSelected) {
                [self localNotifyHyperSelectionDidChange];
            }
            else {
                [self updateTableViewWithObjectsInSet:[[self selection] nodes] addToSelection:NO];
            }
            [self didChangeNumberOfDisplayedItems];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00087ba6 @ 00087ba6, 205 bytes * /

void FUN_00087ba6(HSObjectListController *self,SEL _cmd,id updateSelectionWithSelectedObject)

{
  id pvVar1;
  SEL op;
  undefined *puVar2;
  
  self->_isUpdatingSelectionToSyncWithExternalSelection = '\x01';
  puVar2 = &DAT_00366308;
  pvVar1 = _objc_msgSend(updateSelectionWithSelectedObject,sel_implementsHyperInterface_,
                         &DAT_00366308);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(updateSelectionWithSelectedObject,sel_isHyperProxy,puVar2);
    op = sel_setSelectedObject_;
    if ((char)pvVar1 == '\0') goto LAB_00087c62;
    updateSelectionWithSelectedObject =
         _objc_msgSend(updateSelectionWithSelectedObject,sel_allHyperInterfaces,puVar2);
    pvVar1 = _objc_msgSend(updateSelectionWithSelectedObject,sel_count);
    if (pvVar1 < (id)0x2) {
      updateSelectionWithSelectedObject =
           _objc_msgSend(updateSelectionWithSelectedObject,sel_lastObject,puVar2);
      op = sel_setSelectedObject_;
      goto LAB_00087c62;
    }
    op = sel_setSelectedObjects_;
    if (updateSelectionWithSelectedObject != (id)0x0) goto LAB_00087c62;
  }
  updateSelectionWithSelectedObject = (id)0x0;
  op = sel_setSelectedObject_;
LAB_00087c62:
  _objc_msgSend(self,op,updateSelectionWithSelectedObject);
  self->_isUpdatingSelectionToSyncWithExternalSelection = '\0';
  return;
}

*/
- (void)updateSelectionWithSelectedObject:(id)aObject
{
    _isUpdatingSelectionToSyncWithExternalSelection = YES;
    if (![aObject implementsHyperInterface:@protocol(HSCardObjectAttributes)]) {
        [self setSelectedObject:nil];
    }
    else if (![aObject isHyperProxy]) {
        [self setSelectedObject:aObject];
    }
    else {
        NSArray *objects = [aObject allHyperInterfaces];
        if ([objects count] < 2) {
            [self setSelectedObject:[objects lastObject]];
        }
        else {
            [self setSelectedObjects:objects];
        }
    }
    _isUpdatingSelectionToSyncWithExternalSelection = NO;
}

- (id)documentSelectionHolder
{
    return _documentSelectionHolder;
}

- (void)setDocumentSelectionHolder:(id)aHolder
{
    _documentSelectionHolder = aHolder;
}

- (id)ownSelectedObject
{
    return [[self selection] selectedObject];
}

- (void)localNotifyHyperSelectionDidChange
{
    [_documentSelectionHolder selectionHostDidChangeSelectedObject:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000879db @ 000879db, 356 bytes * /

void FUN_000879db(HSObjectListController *self,SEL _cmd,id objectVisualAttributesDidChange)

{
  id pvVar1;
  undefined *self_00;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(objectVisualAttributesDidChange,sel_object);
  self_00 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003660d8);
  pvVar1 = _objc_msgSend(objectVisualAttributesDidChange,sel_attributeProtocolSet);
  pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
  _objc_msgSend(pvVar1,sel_removeProtocol_,&DAT_003662f4);
  puVar3 = &DAT_003662a4;
  _objc_msgSend(pvVar1,sel_removeProtocol_,&DAT_003662a4);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(self_00,sel_attributeObservingController,puVar3);
    puVar3 = _objc_msgSend(pvVar2,sel_attributesBeingChangedContinuously);
    pvVar2 = _objc_msgSend(pvVar1,sel_isSubsetOfProtocolSet_,puVar3);
    if ((char)pvVar2 == '\0') {
      puVar3 = self_00;
      pvVar2 = _objc_msgSend(self,sel_displaysUserObject_,self_00);
      if ((char)pvVar2 != '\0') {
        _objc_msgSend(self,sel_invalidateCellPreviewForObject_,self_00);
        _objc_msgSend(self->_objectListTableView,sel_reloadData);
        puVar3 = self_00;
      }
    }
  }
  _objc_msgSend(pvVar1,sel_release,puVar3);
  return;
}

*/
- (void)objectVisualAttributesDidChange:(id)aChange
{
    id object = [[aChange object] queryHyperInterface:@protocol(HSAttributes)];
    NSEMutableProtocolSet *attributes = [[aChange attributeProtocolSet] mutableCopy];
    [attributes removeProtocol:@protocol(HSVerticalOffsetAttribute)];
    [attributes removeProtocol:@protocol(HSHorizontalOffsetAttribute)];
    if ([attributes count] != 0
        && ![attributes isSubsetOfProtocolSet:[[object attributeObservingController] attributesBeingChangedContinuously]]
        && [self displaysUserObject:object]) {
        [self invalidateCellPreviewForObject:object];
        [_objectListTableView reloadData];
    }
    [attributes release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00087921 @ 00087921, 186 bytes * /

void FUN_00087921(HSObjectListController *self,SEL _cmd,
                 id objectVisualAttributesDidEndChangeContinuously)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(objectVisualAttributesDidEndChangeContinuously,sel_object);
  pvVar2 = _objc_msgSend(objectVisualAttributesDidEndChangeContinuously,sel_attributeProtocolSet);
  puVar3 = &DAT_003662a4;
  uVar4 = 0;
  pvVar2 = _objc_msgSend(pvVar2,sel_containsProtocolsExludingProtocols_,&DAT_003662f4,&DAT_003662a4,
                         0);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(self,sel_displaysUserObject_,pvVar1,puVar3,uVar4);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend(self,sel_invalidateCellPreviewForObject_,pvVar1,puVar3,uVar4);
      _objc_msgSend(self->_objectListTableView,sel_reloadData);
    }
  }
  return;
}

*/
- (void)objectVisualAttributesDidEndChangeContinuously:(id)aContinuously
{
    id object = [aContinuously object];
    if ([[aContinuously attributeProtocolSet] containsProtocolsExludingProtocols:@protocol(HSVerticalOffsetAttribute), @protocol(HSHorizontalOffsetAttribute), nil]
        && [self displaysUserObject:object]) {
        [self invalidateCellPreviewForObject:object];
        [_objectListTableView reloadData];
    }
}

- (void)objectIdentifierDidChange:(id)aChange
{
    id pvVar1;

    pvVar1 = [aChange object];
    if ([self displaysUserObject:pvVar1]) {
        [self invalidateCellValueForObject:pvVar1];
        [_objectListTableView reloadData];
    }
}

- (BOOL)displaysUserObject:(id)aObject
{
    id pvVar1;
    BOOL pvVar2;

    if (_topLevelParent != nil) {
        pvVar1 = [aObject queryHyperInterface:@protocol(HSNodeChild)];
        pvVar2 = [pvVar1 isEqual:_topLevelParent];
        if (pvVar2) {
            return _displaysTopLevelParent;
        }
        for (; pvVar1 != nil; pvVar1 = [pvVar1 hyperParent]) {
            pvVar2 = [pvVar1 isEqual:_topLevelParent];
            if (pvVar2) {
                return YES;
            }
            pvVar1 = [pvVar1 queryHyperInterface:@protocol(HSNodeChild)];
        }
    }
    return NO;
}

- (id)tableView
{
    return _objectListTableView;
}

- (void)setTableView:(id)aView
{
    if (_objectListTableView != aView) {
        [_objectListTableView release];
        [_objectListTableView setDelegate:0];
        [_objectListTableView setDataSource:0];
        [_objectListTableView setTarget:0];
        _objectListTableView = [aView retain];
        [self setupTableView];
    }
}

- (void)setupTableView
{
    if (_objectListTableView != nil) {
        [_objectListTableView setDelegate:self];
        [_objectListTableView setDataSource:self];
        [_objectListTableView setTarget:self];
        [_objectListTableView setAction:@selector(objectListTableViewAction:)];
        [_objectListTableView setDoubleAction:@selector(objectListTableViewDoubleAction:)];
        [self updateStatusBar];
    }
}

- (void)setDisplaysTopLevelParent:(BOOL)aParent
{
    if (_displaysTopLevelParent != aParent) {
        _displaysTopLevelParent = aParent;
        [self topLevelParentDidChange];
    }
}

- (BOOL)displaysTopLevelParent
{
    return _displaysTopLevelParent;
}

- (void)didChangeNumberOfDisplayedItems
{
    [self updateStatusBar];
    [self validateToolbarButtons];
}

- (void)didChangeTopLevelParent
{

}

- (void)setTopLevelParent:(id)aParent
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _topLevelParent;
    if (pvVar1 != aParent) {
        if (pvVar1 != nil) {
            [[pvVar1 attributeObservingController] removeAttributeObserver:self];
            [_topLevelParent removeChildrenAttributeObserver:self];
            _isObservingObjectNotifications = NO;
        }
        [self topLevelParentWillChange];
        [_topLevelParent release];
        pvVar1_3 = [aParent retain];
        _topLevelParent = pvVar1_3;
        if (pvVar1_3 != nil) {
            [self registerForObjectNotificationsIfNeeded];
        }
        [self topLevelParentDidChange];
        [self didChangeTopLevelParent];
    }
}

- (id)topLevelParent
{
    return _topLevelParent;
}

- (void)topLevelParentDidChange
{
    if (_objectListTableView != nil) {
        [_objectListTableView noteNumberOfRowsChanged];
        [_objectListTableView reloadData];
    }
    [self updateStatusBar];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000873b7 @ 000873b7, 272 bytes * /

void FUN_000873b7(HSObjectListController *self,SEL _cmd)

{
  cfstringStruct *pcVar1;
  undefined *self_00;
  id pvVar2;
  SEL op;
  cfstringStruct *pcVar3;
  undefined4 uVar4;
  
  pcVar1 = _objc_msgSend(self,sel_userObjectCount);
  if (pcVar1 == (cfstringStruct *)0x0) {
    self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar3 = &cfstr_0_objects;
  }
  else {
    self_00 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    if (pcVar1 != (cfstringStruct *)0x1) {
      uVar4 = 0;
      pcVar3 = _objc_msgSend(self_00,sel_localizedStringForKey_value_table_,&cfstr__u_objects,
                             &cfstr_empty,0);
      self_00 = cls_NSString;
      op = sel_stringWithFormat_;
      goto LAB_0008749f;
    }
    pcVar3 = &cfstr_1_object;
  }
  pcVar1 = &cfstr_empty;
  uVar4 = 0;
  op = sel_localizedStringForKey_value_table_;
LAB_0008749f:
  pvVar2 = _objc_msgSend(self_00,op,pcVar3,pcVar1,uVar4);
  _objc_msgSend(self->_objectsCountField,sel_setStringValue_,pvVar2);
  return;
}

*/
- (void)updateStatusBar
{
    NSUInteger count = [self userObjectCount];
    NSString *status;
    if (count == 0) {
        status = [[NSBundle mainBundle] localizedStringForKey:@"0 objects" value:@"" table:nil];
    }
    else if (count == 1) {
        status = [[NSBundle mainBundle] localizedStringForKey:@"1 object" value:@"" table:nil];
    }
    else {
        status = [NSString stringWithFormat:[[NSBundle mainBundle] localizedStringForKey:@"%u objects" value:@"" table:nil], (unsigned int)count];
    }
    [_objectsCountField setStringValue:status];
}

- (void)topLevelParentWillChange
{
    [self invalidateDisplayedObjects];
    [self invalidateAllObjects];
}

- (void)registerForObjectNotificationsIfNeeded
{
    int uVar1;
    id self_00;

    if (_isObservingObjectNotifications == NO) {
        _isObservingObjectNotifications = YES;
        self_00 = [_topLevelParent attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [self_00 addObserver:self selector:@selector(nodeContainerDidRemoveChild:) ofChanges:uVar1 ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.25];
        [_topLevelParent addObserver:self selector:@selector(objectVisualAttributesDidEndChangeContinuously:) ofChanges:0x80 ofChildrenAttribute:@protocol(HSVisualAttribute) withPriority:-0.25]
        ;
        [_topLevelParent addObserver:self selector:@selector(objectVisualAttributesDidChange:) ofChanges:2 ofChildrenAttribute:@protocol(HSVisualAttribute) withPriority:-0.25];
        [_topLevelParent addObserver:self selector:@selector(objectIdentifierDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSObjectNameAttribute) withPriority:-0.25];
        [_topLevelParent addObserver:self selector:@selector(objectIdentifierDidChange:) ofChanges:uVar1 ofChildrenAttribute:@protocol(HSTitleAttribute) withPriority:-0.25];
    }
}

- (NSUInteger)userObjectCount
{
    id self_00;
    unsigned int uVar2;
    id pvVar1_2;

    self_00 = [self userObjectEnumerator];
    if ([self_00 nextObject] == nil) {
        uVar2 = 0;
    }
    else {
        uVar2 = 0;
        do {
            uVar2 = uVar2 + 1;
            pvVar1_2 = [self_00 nextObject];
        } while (pvVar1_2 != nil);
    }
    return uVar2;
}

- (id)userObjectAtIndex:(NSUInteger)aIndex
{
    return [self userObjectAtIndex:aIndex withEnumerator:[[self displayedObjects] objectEnumerator]];
}

- (id)userObjectAtRowIndex:(NSUInteger)aIndex
{
    return [self userObjectAtIndex:aIndex withEnumerator:[self userObjectEnumerator]];
}

- (id)userObjectAtIndex:(NSUInteger)aIndex withEnumerator:(id)aEnumerator
{
    id pvVar1;

    pvVar1 = [aEnumerator nextObject];
    for (; aIndex != 0; aIndex = aIndex - 1) {
        pvVar1 = [aEnumerator nextObject];
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00087048 @ 00087048, 98 bytes * /

id FUN_00087048(HSObjectListController *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_displaysNodesInReverseOrder);
  self_00 = _objc_msgSend(self,sel_displayedObjects);
  op = sel_objectEnumerator;
  if ((char)pvVar1 != '\0') {
    op = sel_reverseObjectEnumerator;
  }
  pvVar1 = _objc_msgSend(self_00,op);
  return pvVar1;
}

*/
- (id)userObjectEnumerator
{
    if ([self displaysNodesInReverseOrder]) {
        return [[self displayedObjects] reverseObjectEnumerator];
    }
    return [[self displayedObjects] objectEnumerator];
}

- (BOOL)displaysNodesInReverseOrder
{
    return YES;
}

- (void)invalidateAllObjects
{
    [_cellValuesByIdentifier removeAllObjects];
    [_cellPreviewsByIdentifier removeAllObjects];
}

- (void)invalidateObject:(id)aObject
{
    id pvVar1_2;

    pvVar1_2 = [[aObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    if (pvVar1_2 != nil) {
        [_cellValuesByIdentifier removeObjectForKey:pvVar1_2];
        [_cellPreviewsByIdentifier removeObjectForKey:pvVar1_2];
    }
}

- (void)invalidateCellPreviewForObject:(id)aObject
{
    id pvVar1_2;

    pvVar1_2 = [[aObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    if (pvVar1_2 != nil) {
        [_cellPreviewsByIdentifier removeObjectForKey:pvVar1_2];
    }
}

- (void)invalidateCellValueForObject:(id)aObject
{
    id pvVar1_2;

    pvVar1_2 = [[aObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    if (pvVar1_2 != nil) {
        [_cellValuesByIdentifier removeObjectForKey:pvVar1_2];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008af1d @ 0008af1d, 421 bytes * /

id FUN_0008af1d(HSObjectListController *self,SEL _cmd,id cellPreviewForObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  double dVar4;
  id local_1c;
  
  pvVar1 = _objc_msgSend(cellPreviewForObject,sel_queryHyperInterface_,&DAT_00366178);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperUID);
  if (pvVar1 == (id)0x0) {
    pvVar3 = (id)0x0;
  }
  else {
    local_1c = pvVar1;
    pvVar3 = _objc_msgSend(self->_cellPreviewsByIdentifier,sel_objectForKey_,pvVar1);
    if (pvVar3 == (id)0x0) {
      pvVar3 = _objc_msgSend(self->_objectListTableView,sel_numberOfColumns,local_1c);
      if ((int)pvVar3 < 1) {
        local_1c = *(id *)PTR_0033607c;
      }
      else {
        pvVar3 = _objc_msgSend(self->_objectListTableView,sel_tableColumns,local_1c);
        pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
        dVar4 = _objc_msgSend_fpret(pvVar3,sel_width);
        local_1c = (id)(float)dVar4;
      }
      dVar4 = _objc_msgSend_fpret(self->_objectListTableView,sel_rowHeight);
      pvVar3 = (id)(float)dVar4;
      pvVar2 = local_1c;
      if (((float)pvVar3 <= (float)local_1c) && (pvVar2 = pvVar3, (float)pvVar3 < (float)local_1c))
      {
        local_1c = pvVar3;
      }
      pvVar3 = _objc_msgSend(cls_HSObjectListPalettePreviewView,
                             sel_thumbnailPreviewImageOfSize_forObject_borderInset_,local_1c,pvVar2,
                             cellPreviewForObject,0x40000000,0x40000000);
    }
    if (pvVar3 != (id)0x0) {
      pvVar2 = _objc_msgSend(self,sel_cellPreviewsByIdentifier,local_1c);
      _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar3,pvVar1);
    }
  }
  return pvVar3;
}

*/
- (id)cellPreviewForObject:(id)aObject
{
    id uid = [[aObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
    if (uid == nil) {
        return nil;
    }
    id preview = [_cellPreviewsByIdentifier objectForKey:uid];
    if (preview == nil) {
        CGFloat side = 0.0;
        if ([_objectListTableView numberOfColumns] > 0) {
            side = (float)[[[_objectListTableView tableColumns] objectAtIndex:0] width];
        }
        CGFloat rowHeight = (float)[_objectListTableView rowHeight];
        if (rowHeight < side) {
            side = rowHeight;
        }
        preview = [HSObjectListPalettePreviewView thumbnailPreviewImageOfSize:NSMakeSize(side, side) forObject:aObject borderInset:NSMakeSize(2.0, 2.0)];
    }
    if (preview != nil) {
        [[self cellPreviewsByIdentifier] setObject:preview forKey:uid];
    }
    return preview;
}

- (id)cellValueForObject:(id)aObject
{
    id pvVar1;
    id pcVar2;
    id pcVar3;
    id pcVar4;
    id pvVar6;
    id pcVar5_2;

    pvVar1 = [aObject queryHyperInterface:@protocol(HSObjectAttributes)];
    pcVar2 = [pvVar1 hyperUID];
    if (pcVar2 == NULL) {
        pvVar6 = nil;
    }
    else {
        pvVar6 = [_cellValuesByIdentifier objectForKey:pcVar2];
        if (pvVar6 == nil) {
            pcVar3 = [self identifierForObject:aObject];
            pcVar4 = [pvVar1 hyperKindDisplayName];
            if (pcVar4 == NULL) {
                pcVar4 = @"";
            }
            pcVar5_2 = @"";
            if (pcVar3 != NULL) {
                pcVar5_2 = pcVar3;
            }
            pvVar6 = [HSObjectListController attributedStringWithObjectIdentifier:pcVar5_2 type:pcVar4];
        }
        if (pvVar6 != nil) {
            [[self cellValuesByIdentifier] setObject:pvVar6 forKey:pcVar2];
        }
    }
    return pvVar6;
}

- (id)cellPreviewsByIdentifier
{
    id pvVar1;

    pvVar1 = _cellPreviewsByIdentifier;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableDictionary new];
        _cellPreviewsByIdentifier = pvVar1;
    }
    return pvVar1;
}

- (id)cellValuesByIdentifier
{
    id pvVar1;

    pvVar1 = _cellValuesByIdentifier;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableDictionary new];
        _cellValuesByIdentifier = pvVar1;
    }
    return pvVar1;
}

- (id)identifierForObject:(id)aObject
{
    id pvVar1_2;

    pvVar1_2 = [[aObject queryHyperInterface:@protocol(HSTitleAttributes)] title];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [[aObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    }
    return pvVar1_2;
}

- (id)dragHelper
{
    return [[[[_topLevelParent queryHyperInterface:@protocol(HSUserObjectSupport)] document] cardView] dragHelper];
}

- (void)switchToEditor
{
    if ([[[NSDocumentController sharedDocumentController] currentDocument] isInPlayerMode]) {
        [[[NSDocumentController sharedDocumentController] currentDocument] switchToEditor];
        [[self selection] removeAllNodes];
    }
}

- (void)willUnmountFromWindow:(id)aWindow
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSObjectListControllerWillUnmountFromWindowNotification" object:self];
}

- (void)didMountIntoWindow:(id)aWindow
{
    id pvVar1;

    pvVar1 = [NSArray arrayWithObjects:NSFilenamesPboardType, NSURLPboardType, NSStringPboardType, nil];
    [_objectListTableView registerForDraggedTypes:[[NSImage imagePasteboardTypes] arrayByAddingObjectsFromArray:[pvVar1 arrayByAddingObject:@"HSObjectListDraggingRowIndexesPboardType"]]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSObjectListControllerDidMountIntoWindowNotification" object:self];
}

- (void)willMountIntoWindow:(id)aWindow
{

}

- (void)didLoadNib
{
    [_statusBarTintedView setDrawsBorder:NO];
    [_statusBarTintedView setDrawsFill:YES];
    [_statusBarTintedView setTintColor:[NSColor colorWithCalibratedWhite:0.82 alpha:1.0]];
    [_statusBarTintedView setOpaque:YES];
    [[_flattenButton cell] setBackgroundRenderer:[HSObjectBrowserToolbarButtonBackgroundRenderer sharedBackgroundRenderer]];
    [[_mergeButton cell] setBackgroundRenderer:[HSObjectBrowserToolbarButtonBackgroundRenderer sharedBackgroundRenderer]];
    [[_deleteButton cell] setBackgroundRenderer:[HSObjectBrowserToolbarButtonBackgroundRenderer sharedBackgroundRenderer]];
    [_statusBarTintedView setBackgroundImage:[NSImage imageNamed:@"ObjectListStatusBar"]];
    [self setTableView:_tableView];
}

- (id)nibName
{
    return @"ObjectList";
}

- (id)view
{
    id pvVar1;

    pvVar1 = _view;
    if (pvVar1 == nil) {
        [NSBundle loadNibNamed:[self nibName] owner:self];
        [_view setAutoresizingMask:0x12];
        [self didLoadNib];
        pvVar1 = _view;
    }
    return pvVar1;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[_topLevelParent attributeObservingController] removeAttributeObserver:self];
    [_topLevelParent removeChildrenAttributeObserver:self];
    [_topLevelParent release];
    [_objectListTableView setDelegate:0];
    [_objectListTableView setDataSource:0];
    [_objectListTableView release];
    [_cellValuesByIdentifier release];
    [_cellPreviewsByIdentifier release];
    [_selection release];
    [_displayedObjects release];
    [_view release];
    [super dealloc];
}

- (BOOL)hasSheetAttached
{
    id parent = [[self topLevelParent] queryHyperInterface:@protocol(HSUserObjectSupport)];
    return parent != nil && [[parent document] isModalSessionPresent];
}

- (id)findTargetForAction:(SEL)aAction target:(id)aTarget from:(id)aFrom
{
    return [self hasSheetAttached] ? nil : [NSApp targetForAction:aAction to:aTarget from:aFrom];
}

@end

