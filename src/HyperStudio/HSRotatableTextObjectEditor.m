#import "HSRotatableTextObjectEditor.h"

@implementation HSRotatableTextObjectEditor

/* i386 ivar offsets: _undoHelper=0x3c, _undoApplied=0x40, _saving=0x41, _textDidEndEditing=0x42 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022a559 @ 0022a559, 156 bytes * /

void FUN_0022a559(HSRotatableTextObjectEditor *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_hostView);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_hostView);
    pvVar1 = _objc_msgSend(pvVar1,sel_userSpaceToViewSpaceTransform);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperScaleFactor);
    self_00 = _objc_msgSend(self,sel_textEditorEmbedder);
    _objc_msgSend(self_00,sel_setScaleFactor_,pvVar1,extraout_EDX);
  }
  return;
}

*/
- (void)updateViewScaleFactor
{
    if ([self hostView] != nil) {
        [[self textEditorEmbedder] setScaleFactor:[[[self hostView] userSpaceToViewSpaceTransform] hyperScaleFactor]];
    }
}

- (void)recalculateOccupiedRect
{
    [super recalculateOccupiedRect];
    [[self textEditorEmbedder] setDrawsBorderRect:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022a65a @ 0022a65a, 161 bytes * /

NSRect * FUN_0022a65a(NSRect *__return_storage_ptr__,HSRotatableTextObjectEditor *self,SEL _cmd)

{
  id self_00;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  local_1c = *(float *)PTR_00336078;
  local_18 = *(float *)(PTR_00336078 + 4);
  local_14 = *(float *)(PTR_00336078 + 8);
  local_10 = *(float *)(PTR_00336078 + 0xc);
  self_00 = _objc_msgSend(self,sel_geometryAttributes);
  if (self_00 != (id)0x0) {
    _objc_msgSend_stret(&local_1c,self_00,sel_frameBoundingRect);
  }
  (__return_storage_ptr__->origin).x = local_1c;
  (__return_storage_ptr__->origin).y = local_18;
  (__return_storage_ptr__->size).width = local_14;
  (__return_storage_ptr__->size).height = local_10;
  return __return_storage_ptr__;
}

*/
- (NSRect)userSpaceObjectBounds
{
    NSRect bounds = NSZeroRect;
    id geometry = [self geometryAttributes];
    if (geometry != nil) {
        bounds = [geometry frameBoundingRect];
    }
    return bounds;
}

- (id)sizingAttributesInterface
{
    return [[self editingObject] queryHyperInterface:@protocol(HSTextObjectSizingAttributes)];
}

- (id)geometryAttributes
{
    return [[self editingObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)attributesInterface
{
    return [[self editingObject] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
}

- (void)applyHyperTextAttributesDictionary:(id)aDictionary
{
    NSString *pvVar1_2;
    id pvVar2_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Attributes" value:@"" table:@"UndoManager"];
    pvVar2_2 = [[NSAttributedString alloc] initWithString:[[self coreTextInterface] hyperString] attributes:aDictionary];
    [[self coreTextInterface] hyperReplaceText:[pvVar2_2 autorelease] undoActionName:pvVar1_2];
}

- (void)setHyperSpaceBetweenLines:(CGFloat)aLines
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Line Spacing" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperSpaceBetweenLines:aLines undoActionName:pvVar1_2];
}

- (CGFloat)hyperSpaceBetweenLines
{
    return (float)[[self coreTextInterface] hyperSpaceBetweenLines];
}

- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Space Between Characters" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperSpaceBetweenCharacters:aCharacters undoActionName:pvVar1_2];
}

- (CGFloat)hyperSpaceBetweenCharacters
{
    return (float)[[self coreTextInterface] hyperSpaceBetweenCharacters];
}

- (void)setHyperShadowBlurRadius:(CGFloat)aRadius
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow Blur Radius" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperShadowBlurRadius:aRadius undoActionName:pvVar1_2];
}

- (CGFloat)hyperShadowBlurRadius
{
    return (float)[[self coreTextInterface] hyperShadowBlurRadius];
}

- (void)setHyperShadowOffset:(NSSize)aOffset
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow Offset" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperShadowOffset:aOffset undoActionName:pvVar1_2];
}

- (NSSize)hyperShadowOffset
{
    return [[self coreTextInterface] hyperShadowOffset];
}

- (void)setHyperShadowDistance:(CGFloat)aDistance
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow Distance" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperShadowDistance:aDistance undoActionName:pvVar1_2];
}

- (CGFloat)hyperShadowDistance
{
    return (float)[[self coreTextInterface] hyperShadowDistance];
}

- (void)setHyperShadowAngle:(CGFloat)aAngle
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow Angle" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperShadowAngle:aAngle undoActionName:pvVar1_2];
}

- (CGFloat)hyperShadowAngle
{
    return (float)[[self coreTextInterface] hyperShadowAngle];
}

- (void)setHyperShadowEnabled:(BOOL)aEnabled
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperShadowEnabled:aEnabled undoActionName:pvVar1_2]
    ;
}

- (BOOL)isHyperShadowEnabled
{
    return (BOOL)[[self coreTextInterface] isHyperShadowEnabled];
}

- (BOOL)hasMultipleShadowStyles
{
    return YES;
}

- (void)setHyperAlignment:(NSInteger)aAlignment
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Text Alignment" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperTextAlignment:aAlignment undoActionName:pvVar1_2];
}

- (NSInteger)hyperAlignment
{
    return (int)[[self coreTextInterface] hyperTextAlignment];
}

- (void)finishOutlineMutating:(BOOL)aMutating
{
    [[self coreTextInterface] finishOutlineMutating:aMutating undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Outline Change" value:@"" table:@"UndoManager"]]
    ;
}

- (void)startOutlineMutating
{
    [[self coreTextInterface] startOutlineMutating];
}

- (void)setHyperOutlineColor:(id)aColor
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Outline Color" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperOutlineColor:aColor undoActionName:pvVar1_2];
}

- (id)hyperOutlineColor
{
    return [[self coreTextInterface] hyperOutlineColor];
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Outline Width" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperOutlineWidth:aWidth undoActionName:pvVar1_2];
}

- (CGFloat)hyperOutlineWidth
{
    return (float)[[self coreTextInterface] hyperOutlineWidth];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Outline" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperOutlineEnabled:aEnabled undoActionName:pvVar1_2];
}

- (BOOL)isHyperOutlineEnabled
{
    return (BOOL)[[self coreTextInterface] isHyperOutlineEnabled];
}

- (void)setHyperUnderlined:(BOOL)aUnderlined
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Underline" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperUnderlined:aUnderlined undoActionName:pvVar1_2];
}

- (BOOL)isHyperUnderlined
{
    return (BOOL)[[self coreTextInterface] isHyperUnderlined];
}

- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor
{
    [self setBackgroundColor:aColor];
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Attributes" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] applyCharacterAttributesWithAttributesConverter:aConverter undoActionName:pvVar1_2];
}

- (void)applyFontWithFontConverter:(id)aConverter
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Font" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] applyFontWithFontConverter:aConverter undoActionName:pvVar1_2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022b4a1 @ 0022b4a1, 82 bytes * /

id FUN_0022b4a1(HSRotatableTextObjectEditor *self,SEL _cmd,BOOL *fontForSystemFontPanelIsMultiple)

{
  id self_00;
  id local_c;
  
  local_c = (id)0x0;
  self_00 = _objc_msgSend(self,sel_coreTextInterface);
  _objc_msgSend(self_00,sel_getHyperFont_multipleValues_,&local_c,fontForSystemFontPanelIsMultiple);
  return local_c;
}

*/
- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple
{
    id font = nil;
    [[self coreTextInterface] getHyperFont:&font multipleValues:aMultiple];
    return font;
}

- (id)hyperTextAttributes
{
    return [[[[self coreTextInterface] hyperTextAttributesDictionary] retain] autorelease];
}

- (void)setHyperExpanded:(BOOL)aExpanded
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Expanded" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperExpanded:aExpanded undoActionName:pvVar1_2];
}

- (BOOL)isHyperExpanded
{
    return (BOOL)[[self coreTextInterface] isHyperExpanded];
}

- (void)setHyperCondensed:(BOOL)aCondensed
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Condensed" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperCondensed:aCondensed undoActionName:pvVar1_2];
}

- (BOOL)isHyperCondensed
{
    return (BOOL)[[self coreTextInterface] isHyperCondensed];
}

- (void)setHyperItalic:(BOOL)aItalic
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Italic" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperItalic:aItalic undoActionName:pvVar1_2];
}

- (BOOL)isHyperItalic
{
    return (BOOL)[[self coreTextInterface] isHyperItalic];
}

- (void)setHyperBold:(BOOL)aBold
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Bold" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperBold:aBold undoActionName:pvVar1_2];
}

- (BOOL)isHyperBold
{
    return (BOOL)[[self coreTextInterface] isHyperBold];
}

- (void)setHyperFontSize:(CGFloat)aSize
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Font Size" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperFontSize:aSize undoActionName:pvVar1_2];
}

- (CGFloat)hyperFontSize
{
    return (float)[[self coreTextInterface] hyperFontSize];
}

- (void)setHyperFontFamily:(id)aFamily
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Font" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperFontFamily:aFamily undoActionName:pvVar1_2];
}

- (id)hyperFontFamily
{
    return [[self coreTextInterface] hyperFontFamily];
}

- (void)setHyperFont:(id)aFont
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Font" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperFont:aFont undoActionName:pvVar1_2];
}

- (id)hyperFont
{
    return [[self coreTextInterface] hyperFont];
}

- (void)setHyperPlainText:(id)aText
{
    id pvVar1;
    NSString *pvVar2_3;

    pvVar1 = [self hyperPlainText];
    if (![pvVar1 isEqualToString:aText]) {
        pvVar2_3 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text" value:@"" table:@"UndoManager"];
        [[self coreTextInterface] hyperReplaceTextWithString:aText undoActionName:pvVar2_3];
    }
}

- (id)hyperPlainText
{
    return [[[self coreTextInterface] hyperText] string];
}

- (void)replaceTextInRange:(NSRange)aRange withAttributedString:(id)aString
{
    NSString *pvVar1_4;
    id pvVar1_5;
    id pvVar2_2;

    pvVar2_2 = [[NSMutableAttributedString alloc] initWithAttributedString:[self hyperText]];
    [pvVar2_2 replaceCharactersInRange:aRange withAttributedString:aString];
    if (![pvVar2_2 isEqualToAttributedString:[self hyperText]]) {
        pvVar1_4 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text" value:@"" table:@"UndoManager"];
        [[self coreTextInterface] hyperReplaceText:pvVar2_2 undoActionName:pvVar1_4];
        aRange.length = [aString length];
        [self setHyperSelectedRange:aRange];
        pvVar1_5 = (id)aRange.location;
    }
    [pvVar2_2 release];
}

- (void)setHyperText:(id)aText
{
    id pvVar1;
    NSString *pvVar2_3;

    pvVar1 = [self hyperText];
    if (![pvVar1 isEqualToAttributedString:aText]) {
        pvVar2_3 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text" value:@"" table:@"UndoManager"];
        [[self coreTextInterface] hyperReplaceText:aText undoActionName:pvVar2_3];
    }
}

- (id)hyperText
{
    return [[self coreTextInterface] hyperText];
}

- (void)setBackgroundColor:(id)aColor
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Background Color" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperTextBackgroundColor:aColor undoActionName:pvVar1_2];
}

- (id)backgroundColor
{
    return [[self coreTextInterface] hyperTextBackgroundColor];
}

- (void)setTextColor:(id)aColor
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Color" value:@"" table:@"UndoManager"];
    [[self coreTextInterface] setHyperTextColor:aColor undoActionName:pvVar1_2];
}

- (id)textColor
{
    return [[self coreTextInterface] hyperTextColor];
}

- (void)documentUndoManagerDidRemoveAllActions:(id)aActions
{

}

- (void)documentUndoManagerWillRegisterUndo:(id)aUndo
{
    id pvVar1_2;

    pvVar1_2 = [[self document] undoManager];
    if (_saving == NO) {
        if ([self isEditorChanged]) {
            if ([pvVar1_2 isUndoRegistrationEnabled]) {
                [self saveEditing];
                if ([pvVar1_2 groupingLevel] != 0) {
                    [pvVar1_2 endUndoGrouping];
                    [pvVar1_2 beginUndoGrouping];
                }
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022c0c5 @ 0022c0c5, 221 bytes * /

id FUN_0022c0c5(HSRotatableTextObjectEditor *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = self->_undoHelper;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_hyperObject);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00383908);
    pvVar1 = _objc_msgSend(pvVar1,sel_document);
    self_00 = _objc_msgSend(cls_HSEditModeUndoHelper,sel_alloc);
    pvVar2 = _objc_msgSend(self,sel_undoManager);
    pvVar3 = _objc_msgSend(pvVar1,sel_undoManager);
    pvVar1 = _objc_msgSend(self_00,
                           sel_initWithDocument_documentUndoManager_editModeUndoManager_delegate_,
                           pvVar1,pvVar3,pvVar2,0);
    self->_undoHelper = pvVar1;
  }
  return pvVar1;
}

*/
- (id)undoHelper
{
    if (_undoHelper == nil) {
        id document = [[[self hyperObject] queryHyperInterface:@protocol(HSUserObjectSupport)] document];
        _undoHelper = [[HSEditModeUndoHelper alloc] initWithDocument:document documentUndoManager:[document undoManager] editModeUndoManager:[self undoManager] delegate:nil];
    }
    return _undoHelper;
}

- (void)didRegisterUndoInUndoManager:(id)aManager
{
    if ([[self undoManager] isUndoRegistrationEnabled]) {
        if ([[[self document] undoManager] groupingLevel] != 0) {
            [[[self document] undoManager] endUndoGrouping];
            [[[self document] undoManager] beginUndoGrouping];
        }
        [[self undoHelper] duplicateAction];
    }
}

- (void)willRegisterUndoInUndoManager:(id)aManager
{

}

- (void)finishUndoDuplicating:(BOOL)aDuplicating
{
    if (_undoApplied == NO) {
        [_undoHelper finishDuplicating:aDuplicating];
    }
    [_undoHelper release];
    _undoHelper = nil;
    [[self textEditorEmbedder] removeAllUndoActions];
    _undoApplied = NO;
}

- (id)undoManager
{
    id pvVar1_2;

    if (_textDidEndEditing == NO) {
        pvVar1_2 = [[self textEditorEmbedder] undoManager];
    }
    else {
        pvVar1_2 = nil;
    }
    return pvVar1_2;
}

- (id)document
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSUserObjectSupport)] document];
}

- (void)runTimeEditorEmbedderWantsToResign:(id)aResign
{
    _textDidEndEditing = YES;
    if (![self isDeactivating]) {
        [self finishUndoDuplicating:YES];
        [self notifyWantsToFinish];
    }
}

- (void)runTimeEditorEmbedderDidChangeContent:(id)aContent
{
    _undoApplied = NO;
    [self didChangeContent];
    [self notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
}

- (void)runTimeEditorEmbedderWillChangeSelectionWithoutChangingContent:(id)aContent
{
    if ([self isHyperShadowEnabled]) {
        [[self owner] setNeedsDisplayRunTimeEditor:self];
    }
}

- (void)runTimeEditorEmbedderDidChangeSelectionWithoutChangingContent:(id)aContent
{
    [self notifyChange:2 ofAttribute:@protocol(HSTextAttribute) withUserInfo:nil];
}

- (BOOL)displaysFocusRing
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022c519 @ 0022c519, 177 bytes * /

NSRect * FUN_0022c519(NSRect *__return_storage_ptr__,HSRotatableTextObjectEditor *self,SEL _cmd,
                     NSRect boundsWithOccupiedRect)

{
  char cVar1;
  float local_14;
  float fStack_10;
  float local_c;
  float fStack_8;
  
  local_14 = boundsWithOccupiedRect.origin.x;
  fStack_10 = boundsWithOccupiedRect.origin.y;
  local_c = boundsWithOccupiedRect.size.width;
  fStack_8 = boundsWithOccupiedRect.size.height;
  cVar1 = _NSIsEmptyRect(boundsWithOccupiedRect.origin.x,boundsWithOccupiedRect.origin.y,
                         boundsWithOccupiedRect.size.width,boundsWithOccupiedRect.size.height);
  if (cVar1 == '\0') {
    _NSInsetRect(&local_14,local_14,fStack_10,local_c,fStack_8,0xbf800000,0xbf800000);
  }
  (__return_storage_ptr__->origin).x = local_14;
  (__return_storage_ptr__->origin).y = fStack_10;
  (__return_storage_ptr__->size).width = local_c;
  (__return_storage_ptr__->size).height = fStack_8;
  return __return_storage_ptr__;
}

*/
- (NSRect)boundsWithOccupiedRect:(NSRect)aRect
{
    if (!NSIsEmptyRect(aRect)) {
        aRect = NSInsetRect(aRect, -1.0, -1.0);
    }
    return aRect;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022c5ca @ 0022c5ca, 764 bytes * /

NSRect * FUN_0022c5ca(NSRect *__return_storage_ptr__,HSRotatableTextObjectEditor *self,SEL _cmd)

{
  undefined4 *puVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  int *piVar4;
  int *piVar5;
  longdouble lVar6;
  longdouble lVar7;
  undefined4 auStack_9c [3];
  float local_54;
  float local_50;
  id local_4c;
  float local_48;
  undefined1 local_44 [16];
  float local_34;
  float fStack_30;
  id local_2c;
  float fStack_28;
  float local_24;
  float local_20;
  float local_1c;
  
  piVar4 = (int *)&stack0xffffff74;
  local_34 = *(float *)PTR_00336078;
  fStack_30 = *(float *)(PTR_00336078 + 4);
  local_2c = *(id *)(PTR_00336078 + 8);
  fStack_28 = *(float *)(PTR_00336078 + 0xc);
  pvVar2 = _objc_msgSend(self,sel_textEditorEmbedder);
  _objc_msgSend(pvVar2,sel_hyperText);
  pvVar2 = _objc_msgSend(self,sel_sizingAttributesInterface);
  pvVar3 = _objc_msgSend(pvVar2,sel_hyperAutoresizingMode);
  if (pvVar3 == (id)0x3) {
    pvVar3 = _objc_msgSend(self,sel_geometryAttributes);
    puVar1 = (undefined4 *)&stack0xffffff74;
    if (pvVar3 == (id)0x0) goto LAB_0022c702;
  }
  else {
    _objc_msgSend_stret(local_44,pvVar2,sel_hyperAutoresizingOptions);
    _objc_msgSend(pvVar2,sel_hyperAutoresizingMode);
    puVar1 = (undefined4 *)&stack0xffffff70;
  }
  piVar4 = puVar1;
  piVar4[-1] = 0x22c6fc;
  local_2c = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
  fStack_28 = extraout_EDX;
LAB_0022c702:
  piVar4[1] = (int)sel_stickyHorizontalSideForAutoresizing;
  *piVar4 = (int)pvVar2;
  piVar4[-1] = 0x22c714;
  pvVar3 = _objc_msgSend((id)*piVar4,(SEL)piVar4[1]);
  piVar4[2] = (int)sel_userSpaceObjectBounds;
  piVar4[1] = (int)self;
  *piVar4 = (int)&local_24;
  piVar4[-1] = 0x22c732;
  _objc_msgSend_stret((void *)*piVar4,(id)piVar4[1],(SEL)piVar4[2]);
  pvVar2 = local_2c;
  piVar5 = piVar4 + -1;
  if (pvVar3 == (id)0x2) {
    local_24 = (local_24 + local_1c) - (float)local_2c;
  }
  else if (pvVar3 != (id)0x0) {
    local_24 = ((local_24 + local_1c * 0.5) - ((float)local_2c * 0.5 + local_34)) + local_34;
  }
  fStack_30 = local_20;
  piVar4[-1] = (int)fStack_28;
  piVar4[-2] = 0x22c7b3;
  local_34 = local_24;
  lVar6 = (longdouble)_ceilf();
  piVar4[-1] = (int)pvVar2;
  piVar4[-2] = 0x22c7c5;
  lVar7 = (longdouble)_ceilf();
  *piVar4 = (int)sel_hostView;
  piVar4[-1] = (int)self;
  piVar4[-2] = 0x22c7e3;
  pvVar2 = _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
  if (pvVar2 != (id)0x0) {
    *(ulonglong *)(piVar4 + 4) = CONCAT44(fStack_28,local_2c);
    *(ulonglong *)(piVar4 + 2) = CONCAT44(fStack_30,local_34);
    piVar4[1] = (int)sel_viewBoundingRectForUserRect_;
    *piVar4 = (int)pvVar2;
    piVar4[-1] = (int)&local_54;
    piVar4[-2] = 0x22c82a;
    _objc_msgSend_stret((void *)piVar4[-1],(id)*piVar4,(SEL)piVar4[1]);
    piVar5 = piVar4 + -2;
    local_34 = local_54;
    fStack_30 = local_50;
    local_2c = local_4c;
    fStack_28 = local_48;
  }
  piVar5[1] = (int)sel_textEditorEmbedder;
  *piVar5 = (int)self;
  piVar5[-1] = 0x22c86a;
  pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  piVar5[3] = (int)(float)lVar6;
  piVar5[2] = (int)(float)lVar7;
  piVar5[1] = (int)sel_applyOriginalTextSize_;
  *piVar5 = (int)pvVar2;
  piVar5[-1] = 0x22c892;
  _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  (__return_storage_ptr__->origin).x = local_34;
  (__return_storage_ptr__->origin).y = fStack_30;
  (__return_storage_ptr__->size).width = (float)local_2c;
  (__return_storage_ptr__->size).height = fStack_28;
  return __return_storage_ptr__;
}

*/
- (NSRect)calculateOccupiedRect
{
    NSRect rect = NSZeroRect;
    NSSize size = NSZeroSize;
    id text = [[self textEditorEmbedder] hyperText];
    id sizing = [self sizingAttributesInterface];
    if ([sizing hyperAutoresizingMode] == 3) {
        id geometry = [self geometryAttributes];
        if (geometry != nil) {
            size = [geometry size];
        }
    } else {
        struct HSTextObjectAutoresizingOptions options = [sizing hyperAutoresizingOptions];
        if ([sizing hyperAutoresizingMode] == 2) {
            size = [text hyperRequiredSizeForTextBlockOfHeight:options.f1 maximumWidth:options.f0];
        } else {
            size = [text hyperRequiredSizeToFitWidth:options.f0 fixedWidth:options.f2];
        }
    }
    NSInteger sticky = [sizing stickyHorizontalSideForAutoresizing];
    NSRect bounds = [self userSpaceObjectBounds];
    CGFloat x;
    if (sticky == 2) {
        x = (bounds.origin.x + bounds.size.width) - size.width;
    } else if (sticky != 0) {
        x = ((bounds.origin.x + bounds.size.width * 0.5) - (size.width * 0.5 + rect.origin.x)) + rect.origin.x;
    } else {
        x = bounds.origin.x;
    }
    rect = NSMakeRect(x, bounds.origin.y, size.width, size.height);
    CGFloat ceilHeight = ceilf(size.height);
    CGFloat ceilWidth = ceilf(size.width);
    if ([self hostView] != nil) {
        rect = [[self hostView] viewBoundingRectForUserRect:rect];
    }
    [[self textEditorEmbedder] applyOriginalTextSize:NSMakeSize(ceilWidth, ceilHeight)];
    return rect;
}

- (BOOL)calculatedRectIsPrecise
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022c8c6 @ 0022c8c6, 278 bytes * /

void FUN_0022c8c6(HSRotatableTextObjectEditor *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  HSRotatableTextObjectEditor *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_attributesInterface);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperText);
  pvVar2 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_coreTextInterface);
    pvVar1 = _objc_msgSend(self,sel_attributesInterface);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperTextAttributes);
    op = sel_applyHyperTextAttributes_undoActionName_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_textEditorEmbedder);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperText);
    op = sel_hyperReplaceText_undoActionName_;
  }
  _objc_msgSend(pvVar2,op,pvVar1,0);
  _objc_msgSend(self,sel_updateViewScaleFactor);
  local_1c = self;
  local_18 = PTR_s_HSBaseEmbeddedEditor_00355250;
  _objc_msgSendSuper(&local_1c,sel_updateEmbeddedViewWithEditingObject);
  return;
}

*/
- (void)updateEmbeddedViewWithEditingObject
{
    id text = [[self attributesInterface] hyperText];
    if ([text length] == 0) {
        [[self coreTextInterface] applyHyperTextAttributes:[[self attributesInterface] hyperTextAttributes] undoActionName:nil];
    } else {
        [[[self textEditorEmbedder] hyperText] hyperReplaceText:text undoActionName:nil];
    }
    [self updateViewScaleFactor];
    [super updateEmbeddedViewWithEditingObject];
}

- (void)deactivateEditing
{
    if ([self isEditorChanged]) {
        [self finishUndoDuplicating:NO];
    }
    [[[self document] mainWindowController] setPreferedUndoManager:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCoreTextDidChangeAttributesNotification" object:[self coreTextInterface]];
    [super deactivateEditing];
}

- (BOOL)activateEditing
{
    HSRotatableTextObjectEditor *pHVar2;
    id pvVar3;
    id pvVar4;
    id pvVar1_2;
    BOOL pvVar1_4;

    _textDidEndEditing = NO;
    pvVar1_2 = [[self document] mainWindowController];
    pHVar2 = [self undoManager];
    [pvVar1_2 setPreferedUndoManager:pHVar2];
    [[self undoManager] disableUndoRegistration];
    pvVar1_4 = [super activateEditing];
    pvVar3 = [self undoManager];
    [pvVar3 enableUndoRegistration];
    if (pvVar1_4) {
        pvVar3 = [[self textEditorEmbedder] hyperText];
        [pvVar3 setHyperCursorPositionAccordingToCurrentEvent];
        pvVar3 = [NSNotificationCenter defaultCenter];
        pvVar4 = [self coreTextInterface];
        pHVar2 = self;
        [pvVar3 addObserver:self selector:@selector(coreTextDidChangeAttributes:) name:@"HSCoreTextDidChangeAttributesNotification" object:pvVar4];
    }
    [self clearChangedState];
    [self updateViewScaleFactor];
    return pvVar1_4;
}

- (void)hostViewDidChangeUserSpaceToViewSpaceTransform
{
    [self updateViewScaleFactor];
    [super hostViewDidChangeUserSpaceToViewSpaceTransform];
}

- (BOOL)disablesRenderingEditingObject
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022ccc8 @ 0022ccc8, 409 bytes * /

void FUN_0022ccc8(HSRotatableTextObjectEditor *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  undefined *puVar4;
  
  self->_saving = '\x01';
  pvVar2 = _objc_msgSend(self,sel_isEditorChanged);
  if ((char)pvVar2 == '\0') goto LAB_0022ce55;
  pvVar2 = _objc_msgSend(self,sel_document);
  puVar4 = sel_isAutosaving;
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_isAutosaving);
  if ((char)pvVar2 == '\0') {
LAB_0022cd58:
    bVar1 = false;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_document,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_isAutosaving);
    if ((char)pvVar2 == '\0') goto LAB_0022cd58;
    bVar1 = true;
  }
  if ((self->_textDidEndEditing == '\0') && (self->_undoApplied == '\0' && !bVar1)) {
    pvVar2 = _objc_msgSend(self,sel_textEditorEmbedder,puVar4);
    _objc_msgSend(pvVar2,sel_breakUndoCoalescing);
    puVar4 = (undefined *)0x1;
    _objc_msgSend(self->_undoHelper,sel_finishDuplicating_,1);
    self->_undoApplied = '\x01';
  }
  pvVar3 = _objc_msgSend(self,sel_hyperText,puVar4);
  self_00 = _objc_msgSend(self,sel_attributesInterface);
  pvVar2 = pvVar3;
  _objc_msgSend(self_00,sel_setHyperText_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_length);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_attributesInterface,pvVar2);
    pvVar2 = _objc_msgSend(self,sel_hyperTextAttributes);
    _objc_msgSend(pvVar3,sel_applyHyperTextAttributesDictionary_,pvVar2);
  }
  if (!bVar1) {
    _objc_msgSend(self,sel_clearChangedState,pvVar2);
  }
LAB_0022ce55:
  self->_saving = '\0';
  return;
}

*/
- (void)saveEditing
{
    _saving = YES;
    if ([self isEditorChanged]) {
        BOOL autosaving = [[self document] respondsToSelector:@selector(isAutosaving)] && [[self document] isAutosaving];
        if (!_textDidEndEditing && !_undoApplied && !autosaving) {
            [[self textEditorEmbedder] breakUndoCoalescing];
            [_undoHelper finishDuplicating:YES];
            _undoApplied = YES;
        }
        id text = [self hyperText];
        [[self attributesInterface] setHyperText:text];
        if ([text length] == 0) {
            [[self attributesInterface] applyHyperTextAttributesDictionary:[self hyperTextAttributes]];
        }
        if (!autosaving) {
            [self clearChangedState];
        }
    }
    _saving = NO;
}

- (void)HSRotatableTextObjectEditor_textDidChangeText:(id)aText
{
    [self notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
}

- (void)coreTextDidChangeAttributes:(id)aAttributes
{
    [self didChangeContent];
}

- (id)coreTextInterface
{
    return [[self textEditorEmbedder] hyperText];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022cf01 @ 0022cf01, 628 bytes * /

id FUN_0022cf01(HSRotatableTextObjectEditor *self,SEL _cmd,id queryHyperInterface)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  char *pcVar5;
  char *pcVar6;
  int iVar7;
  HSRotatableTextObjectEditor *pHVar8;
  undefined *puVar9;
  HSRotatableTextObjectEditor *local_1c;
  undefined *local_18;
  
  puVar9 = queryHyperInterface;
  pvVar3 = _objc_msgSend(cls_HSProtocolIdentifier,sel_identifierForProtocol_,queryHyperInterface);
  pvVar4 = _objc_msgSend(self,sel_isInCreationMode);
  if ((char)pvVar4 != '\0') {
    if (*(double *)PTR_00336340 <= 677.0 && *(double *)PTR_00336340 != 677.0) {
      puVar9 = &DAT_00383a48;
      _objc_msgSend(queryHyperInterface,sel_conformsTo_,&DAT_00383a48);
    }
    else {
      _protocol_conformsToProtocol(queryHyperInterface,&DAT_00383a48);
    }
  }
  puVar1 = PTR_00336340;
  if (queryHyperInterface == &DAT_0038391c) {
LAB_0022d07d:
    pvVar3 = _objc_msgSend(self,sel_attributesInterface,puVar9);
    if (pvVar3 == (id)0x0) {
      pHVar8 = (HSRotatableTextObjectEditor *)0x0;
    }
    else {
      pvVar4 = _objc_msgSend(cls_HSSelectiveProxy,sel_alloc,puVar9);
      pvVar3 = _objc_msgSend(pvVar4,sel_initWithRunTimeEditor_modelInterface_,self,pvVar3);
      pHVar8 = _objc_msgSend(pvVar3,sel_autorelease);
    }
  }
  else {
    if (*(double *)PTR_00336340 <= 677.0 && *(double *)PTR_00336340 != 677.0) {
      pcVar5 = _objc_msgSend(queryHyperInterface,sel_name,puVar9);
    }
    else {
      pcVar5 = (char *)_protocol_getName(queryHyperInterface);
    }
    if (pcVar5 != (char *)0x0) {
      if (*(double *)puVar1 <= 677.0 && *(double *)puVar1 != 677.0) {
        pcVar6 = _objc_msgSend(&DAT_0038391c,sel_name,puVar9);
      }
      else {
        pcVar6 = (char *)_protocol_getName(&DAT_0038391c);
      }
      if ((pcVar6 != (char *)0x0) && (iVar7 = _strcmp(pcVar5,pcVar6), iVar7 == 0)) {
        if (*(double *)puVar1 <= 677.0 && *(double *)puVar1 != 677.0) {
          puVar9 = &DAT_0038391c;
          pvVar4 = _objc_msgSend(queryHyperInterface,sel_isEqual_,&DAT_0038391c);
          cVar2 = (char)pvVar4;
        }
        else {
          cVar2 = _protocol_isEqual(queryHyperInterface,&DAT_0038391c);
        }
        if (cVar2 != '\0') goto LAB_0022d07d;
      }
    }
    pvVar4 = _objc_msgSend(cls_HSSystemTextView,sel_textImplementationInterfaces,puVar9);
    pvVar4 = _objc_msgSend(pvVar4,sel_containsObject_,pvVar3);
    if ((char)pvVar4 == '\0') {
      local_1c = self;
      local_18 = PTR_s_HSBaseEmbeddedEditor_00355250;
      pHVar8 = _objc_msgSendSuper(&local_1c,sel_queryHyperInterface_,queryHyperInterface);
    }
    else {
      pvVar3 = _objc_msgSend(self,sel_coreTextInterface,pvVar3);
      pHVar8 = (HSRotatableTextObjectEditor *)0x0;
      if (pvVar3 != (id)0x0) {
        pHVar8 = self;
      }
    }
  }
  return pHVar8;
}

*/
- (id)queryHyperInterface:(id)aInterface
{
    id identifier = [HSProtocolIdentifier identifierForProtocol:aInterface];
    if (aInterface == @protocol(HSSystemTextViewAttributes) || protocol_isEqual(aInterface, @protocol(HSSystemTextViewAttributes))) {
        id attributes = [self attributesInterface];
        if (attributes == nil) {
            return nil;
        }
        return [[[HSSelectiveProxy alloc] initWithRunTimeEditor:self modelInterface:attributes] autorelease];
    }
    if ([[HSSystemTextView textImplementationInterfaces] containsObject:identifier]) {
        return [self coreTextInterface] != nil ? self : nil;
    }
    return [super queryHyperInterface:aInterface];
}

- (id)viewEmbeddingInterface
{
    return (id)@protocol(HSTextEditorEmbedder);
}

- (id)textEditorEmbedder
{
    return [self viewEmbedder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCoreTextDidChangeTextNotification" object:0];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject
{
    self = [super initWithHyperObject:aObject];
    if (self != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HSRotatableTextObjectEditor_textDidChangeText:) name:@"HSCoreTextDidChangeTextNotification" object:0];
    }
    return self;
}

@end

