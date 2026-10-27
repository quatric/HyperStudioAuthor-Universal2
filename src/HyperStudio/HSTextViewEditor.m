#import "HSTextViewEditor.h"

@implementation HSTextViewEditor

/* i386 ivar offsets: _textView=0x3c, _text=0x40, _undoManager=0x44, _undoHelper=0x48, _didChangeText=0x4c, _textDidEndEditing=0x4d, _undoApplied=0x4e, _saving=0x4f */

- (void)applyHyperTextAttributesDictionary:(id)aDictionary
{
    NSString *pvVar1_2;
    id pvVar2_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Attributes" value:@"" table:@"UndoManager"];
    pvVar2_2 = [[NSAttributedString alloc] initWithString:[[self coreEditorText] hyperString] attributes:aDictionary];
    [[self coreEditorText] hyperReplaceText:[pvVar2_2 autorelease] undoActionName:pvVar1_2];
}

- (void)setHyperSpaceBetweenLines:(CGFloat)aLines
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Line Spacing" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperSpaceBetweenLines:aLines undoActionName:pvVar1_2];
}

- (CGFloat)hyperSpaceBetweenLines
{
    return (float)[[self coreEditorText] hyperSpaceBetweenLines];
}

- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Space Between Characters" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperSpaceBetweenCharacters:aCharacters undoActionName:pvVar1_2];
}

- (CGFloat)hyperSpaceBetweenCharacters
{
    return (float)[[self coreEditorText] hyperSpaceBetweenCharacters];
}

- (void)setHyperShadowBlurRadius:(CGFloat)aRadius
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow Blur Radius" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperShadowBlurRadius:aRadius undoActionName:pvVar1_2];
}

- (CGFloat)hyperShadowBlurRadius
{
    return (float)[[self coreEditorText] hyperShadowBlurRadius];
}

- (void)setHyperShadowOffset:(NSSize)aOffset
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow Offset" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperShadowOffset:aOffset undoActionName:pvVar1_2];
}

- (NSSize)hyperShadowOffset
{
    return [[self coreEditorText] hyperShadowOffset];
}

- (void)setHyperShadowDistance:(CGFloat)aDistance
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow Distance" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperShadowDistance:aDistance undoActionName:pvVar1_2];
}

- (CGFloat)hyperShadowDistance
{
    return (float)[[self coreEditorText] hyperShadowDistance];
}

- (void)setHyperShadowAngle:(CGFloat)aAngle
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow Angle" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperShadowAngle:aAngle undoActionName:pvVar1_2];
}

- (CGFloat)hyperShadowAngle
{
    return (float)[[self coreEditorText] hyperShadowAngle];
}

- (void)setHyperShadowEnabled:(BOOL)aEnabled
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Shadow" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperShadowEnabled:aEnabled undoActionName:pvVar1_2]
    ;
}

- (BOOL)isHyperShadowEnabled
{
    return (BOOL)[[self coreEditorText] isHyperShadowEnabled];
}

- (BOOL)hasMultipleShadowStyles
{
    return YES;
}

- (void)setHyperAlignment:(NSInteger)aAlignment
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Text Alignment" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperTextAlignment:aAlignment undoActionName:pvVar1_2];
}

- (NSInteger)hyperAlignment
{
    return (int)[[self coreEditorText] hyperTextAlignment];
}

- (void)finishOutlineMutating:(BOOL)aMutating
{
    [[self coreEditorText] finishOutlineMutating:aMutating undoActionName:[[NSBundle mainBundle] localizedStringForKey:@"Outline Change" value:@"" table:@"UndoManager"]]
    ;
}

- (void)startOutlineMutating
{
    [[self coreEditorText] startOutlineMutating];
}

- (void)setHyperOutlineColor:(id)aColor
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Outline Color" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperOutlineColor:aColor undoActionName:pvVar1_2];
}

- (id)hyperOutlineColor
{
    return [[self coreEditorText] hyperOutlineColor];
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Outline Width" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperOutlineWidth:aWidth undoActionName:pvVar1_2];
}

- (CGFloat)hyperOutlineWidth
{
    return (float)[[self coreEditorText] hyperOutlineWidth];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Outline" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperOutlineEnabled:aEnabled undoActionName:pvVar1_2];
}

- (BOOL)isHyperOutlineEnabled
{
    return (BOOL)[[self coreEditorText] isHyperOutlineEnabled];
}

- (void)setHyperUnderlined:(BOOL)aUnderlined
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Underline" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperUnderlined:aUnderlined undoActionName:pvVar1_2];
}

- (BOOL)isHyperUnderlined
{
    return (BOOL)[[self coreEditorText] isHyperUnderlined];
}

- (void)applySystemFontPanelDocumentBackgroundColor:(id)aColor
{
    [self setBackgroundColor:aColor];
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Attributes" value:@"" table:@"UndoManager"];
    [[self coreEditorText] applyCharacterAttributesWithAttributesConverter:aConverter undoActionName:pvVar1_2];
}

- (void)applyFontWithFontConverter:(id)aConverter
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Font" value:@"" table:@"UndoManager"];
    [[self coreEditorText] applyFontWithFontConverter:aConverter undoActionName:pvVar1_2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006f0ba @ 0006f0ba, 82 bytes * /

id FUN_0006f0ba(HSTextViewEditor *self,SEL _cmd,BOOL *fontForSystemFontPanelIsMultiple)

{
  id self_00;
  id local_c;
  
  local_c = (id)0x0;
  self_00 = _objc_msgSend(self,sel_coreEditorText);
  _objc_msgSend(self_00,sel_getHyperFont_multipleValues_,&local_c,fontForSystemFontPanelIsMultiple);
  return local_c;
}

*/
- (id)fontForSystemFontPanelIsMultiple:(BOOL *)aMultiple
{
    id font = nil;
    [[self coreEditorText] getHyperFont:&font multipleValues:aMultiple];
    return font;
}

- (id)hyperTextAttributes
{
    return [[[[self coreEditorText] hyperTextAttributesDictionary] retain] autorelease];
}

- (void)setHyperExpanded:(BOOL)aExpanded
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Expanded" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperExpanded:aExpanded undoActionName:pvVar1_2];
}

- (BOOL)isHyperExpanded
{
    return (BOOL)[[self coreEditorText] isHyperExpanded];
}

- (void)setHyperCondensed:(BOOL)aCondensed
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Condensed" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperCondensed:aCondensed undoActionName:pvVar1_2];
}

- (BOOL)isHyperCondensed
{
    return (BOOL)[[self coreEditorText] isHyperCondensed];
}

- (void)setHyperItalic:(BOOL)aItalic
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Italic" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperItalic:aItalic undoActionName:pvVar1_2];
}

- (BOOL)isHyperItalic
{
    return (BOOL)[[self coreEditorText] isHyperItalic];
}

- (void)setHyperBold:(BOOL)aBold
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Bold" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperBold:aBold undoActionName:pvVar1_2];
}

- (BOOL)isHyperBold
{
    return (BOOL)[[self coreEditorText] isHyperBold];
}

- (void)setHyperFontSize:(CGFloat)aSize
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Font Size" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperFontSize:aSize undoActionName:pvVar1_2];
}

- (CGFloat)hyperFontSize
{
    return (float)[[self coreEditorText] hyperFontSize];
}

- (void)setHyperFontFamily:(id)aFamily
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Font" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperFontFamily:aFamily undoActionName:pvVar1_2];
}

- (id)hyperFontFamily
{
    return [[self coreEditorText] hyperFontFamily];
}

- (void)setHyperFont:(id)aFont
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Font" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperFont:aFont undoActionName:pvVar1_2];
}

- (id)hyperFont
{
    return [[self coreEditorText] hyperFont];
}

- (void)setHyperPlainText:(id)aText
{
    id pvVar1;
    NSString *pvVar2_3;

    pvVar1 = [self hyperPlainText];
    if (![pvVar1 isEqualToString:aText]) {
        pvVar2_3 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text" value:@"" table:@"UndoManager"];
        [[self coreEditorText] hyperReplaceTextWithString:aText undoActionName:pvVar2_3];
    }
}

- (id)hyperPlainText
{
    return [[[self textView] textStorage] string];
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
        [[self coreEditorText] hyperReplaceText:pvVar2_2 undoActionName:pvVar1_4];
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
        [[self coreEditorText] hyperReplaceText:aText undoActionName:pvVar2_3];
    }
}

- (id)hyperText
{
    return [[self textView] textStorage];
}

- (void)setBackgroundColor:(id)aColor
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Background Color" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperTextBackgroundColor:aColor undoActionName:pvVar1_2];
}

- (id)backgroundColor
{
    return [[self coreEditorText] hyperTextBackgroundColor];
}

- (void)setTextColor:(id)aColor
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Color" value:@"" table:@"UndoManager"];
    [[self coreEditorText] setHyperTextColor:aColor undoActionName:pvVar1_2];
}

- (id)textColor
{
    return [[self coreEditorText] hyperTextColor];
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

- (void)setHyperSelectedRange:(NSRange)aRange
{
    [_textView setSelectedRange:aRange];
    [_textView scrollRangeToVisible:aRange];
}

- (NSRange)hyperSelectedRange
{
    return [_textView selectedRange];
}

- (void)setHasHyperVerticalScroller:(BOOL)aScroller
{
    [self updateEmbeddedViewScrollerStyle];
}

- (void)setHyperScrollBarControlSize:(NSUInteger)aSize
{
    [self updateEmbeddedViewScrollerStyle];
}

- (void)setHyperBorderType:(NSUInteger)aType
{
    [self updateEmbeddedViewScrollerStyle];
}

- (void)setHyperBackgroundColor:(id)aColor
{
    [self updateEmbeddedViewBackground];
}

- (void)setHyperTextFilePath:(id)aPath
{
    [self updateEmbeddedViewWithEditingObject];
}

- (void)deactivateUndoManager
{
    if ([_undoManager delegate] == self) {
        [_undoManager setDelegate:0];
    }
    [_undoManager release];
    _undoManager = nil;
}

- (void)finishUndoDuplicating:(BOOL)aDuplicating
{
    [_textView breakUndoCoalescing];
    if (_undoApplied == NO) {
        [_undoHelper finishDuplicating:aDuplicating];
    }
    [_undoHelper release];
    _undoHelper = nil;
    [_undoManager removeAllActions];
    _undoApplied = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006ff14 @ 0006ff14, 483 bytes * /

void FUN_0006ff14(HSTextViewEditor *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  char cVar4;
  id self_00;
  id pvVar5;
  id self_01;
  undefined4 local_34;
  undefined4 uStack_30;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined1 local_24 [8];
  undefined4 local_1c;
  
  self_00 = _objc_msgSend(self->_textView,sel_enclosingScrollView);
  if ((self->_textView != (id)0x0) && (self_00 != (id)0x0)) {
    pvVar5 = _objc_msgSend(self,sel_attributesInterface);
    pvVar5 = _objc_msgSend(pvVar5,sel_borderType);
    _objc_msgSend(self_00,sel_setBorderType_,pvVar5);
    pvVar5 = _objc_msgSend(self,sel_attributesInterface);
    pvVar5 = _objc_msgSend(pvVar5,sel_hasVerticalScroller);
    _objc_msgSend(self_00,sel_setHasVerticalScroller_,(int)(char)pvVar5);
    pvVar5 = _objc_msgSend(self,sel_attributesInterface);
    pvVar5 = _objc_msgSend(pvVar5,sel_hyperScrollBarControlSize);
    self_01 = _objc_msgSend(self_00,sel_verticalScroller);
    _objc_msgSend(self_01,sel_setControlSize_,pvVar5);
    _objc_msgSend_stret(&local_34,self->_textView,sel_frame);
    uVar3 = uStack_28;
    uVar2 = uStack_30;
    uVar1 = local_34;
    _objc_msgSend_stret(local_24,self_00,sel_documentVisibleRect);
    cVar4 = _NSEqualRects(CONCAT44(uVar2,uVar1),CONCAT44(uVar3,local_1c),
                          CONCAT44(uStack_30,local_34),CONCAT44(uStack_28,local_2c));
    if (cVar4 == '\0') {
      _objc_msgSend(self->_textView,sel_setFrame_,CONCAT44(uVar2,uVar1),CONCAT44(uVar3,local_1c));
    }
  }
  return;
}

*/
- (void)updateEmbeddedViewScrollerStyle
{
    NSScrollView *scroll = [_textView enclosingScrollView];
    if (_textView != nil && scroll != nil) {
        [scroll setBorderType:[[self attributesInterface] borderType]];
        [scroll setHasVerticalScroller:[[self attributesInterface] hasVerticalScroller]];
        [[scroll verticalScroller] setControlSize:[[self attributesInterface] hyperScrollBarControlSize]];
        NSRect frame = [_textView frame];
        NSRect visible = [scroll documentVisibleRect];
        NSRect target = NSMakeRect(frame.origin.x, frame.origin.y, visible.size.width, frame.size.height);
        if (!NSEqualRects(target, frame)) {
            [_textView setFrame:target];
        }
    }
}

- (void)updateEmbeddedViewBackground
{
    [_textView setBackgroundColor:[[self attributesInterface] backgroundColor]];
}

- (id)geometryAttributes
{
    return [[self editingObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)attributesInterface
{
    return [[self editingObject] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
}

- (void)coreTextDidChangeAttributes:(id)aAttributes
{
    [self didChangeContent];
}

- (BOOL)textView:(id)aView shouldHyperChangeColor:(id)aColor
{
    return ![HSColorWell hasActiveColorWell];
}

- (BOOL)textView:(id)aView doCommandBySelector:(SEL)aSelector
{
    BOOL BVar1;

    if ((_textView == aView) && (@selector(cancelOperation:) == aSelector)) {
        [self notifyWantsToFinish];
        BVar1 = YES;
    }
    else {
        BVar1 = NO;
    }
    return BVar1;
}

- (void)textDidEndEditing:(id)aEditing
{
    _textDidEndEditing = YES;
    if (![self isDeactivating]) {
        [self finishUndoDuplicating:YES];
        [self notifyWantsToFinish];
        [self deactivateUndoManager];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000702dd @ 000702dd, 165 bytes * /

id FUN_000702dd(HSTextViewEditor *self,SEL _cmd,id textView,
               id willChangeSelectionFromCharacterRanges,id toCharacterRanges)

{
  id pvVar1;
  int extraout_EDX;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(self,sel_isHyperShadowEnabled);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(willChangeSelectionFromCharacterRanges,sel_count);
    if (pvVar1 == (id)0x1) {
      uVar2 = 0;
      pvVar1 = _objc_msgSend(willChangeSelectionFromCharacterRanges,sel_objectAtIndex_,0);
      _objc_msgSend(pvVar1,sel_rangeValue);
      if (extraout_EDX == 0) {
        pvVar1 = _objc_msgSend(self,sel_owner,uVar2);
        _objc_msgSend(pvVar1,sel_setNeedsDisplayRunTimeEditor_,self);
      }
    }
  }
  return toCharacterRanges;
}

*/
- (void)textViewDidChangeSelection:(id)aSelection
{
    [self notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
}

- (void)textViewDidChangeTypingAttributes:(id)aAttributes
{
    [self notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
}

- (void)textDidChange:(id)aChange
{
    _undoApplied = NO;
    [self didChangeContent];
    [self notifyChange:2 ofAttribute:@protocol(HSTextViewTextAttribute) withUserInfo:nil];
}

- (void)didRegisterUndoInUndoManager:(id)aManager
{
    if ([[[self document] undoManager] groupingLevel] != 0) {
        [[[self document] undoManager] endUndoGrouping];
        [[[self document] undoManager] beginUndoGrouping];
    }
    [[self undoHelper] duplicateAction];
}

- (void)willRegisterUndoInUndoManager:(id)aManager
{

}

- (id)undoHelper
{
    id pvVar1;
    id pvVar2;
    id pvVar1_2;
    id pvVar3_2;

    pvVar1 = _undoHelper;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSEditModeUndoHelper alloc];
        pvVar2 = [self undoManager];
        pvVar3_2 = [[self document] undoManager];
        pvVar1 = [pvVar1_2 initWithDocument:[self document] documentUndoManager:pvVar3_2 editModeUndoManager:pvVar2 delegate:self];
        _undoHelper = pvVar1;
    }
    return pvVar1;
}

- (id)document
{
    return [[[self hyperObject] queryHyperInterface:@protocol(HSUserObjectSupport)] document];
}

- (id)undoManagerForTextView:(id)aView
{
    return [self undoManager];
}

- (id)undoManager
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _undoManager;
    if ((pvVar1 == nil) && (_textDidEndEditing == NO)) {
        pvVar1_3 = [[HSRunTimeEditorUndoManager alloc] init];
        _undoManager = pvVar1_3;
        [pvVar1_3 setDelegate:self];
        _undoApplied = NO;
        pvVar1 = _undoManager;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000706e1 @ 000706e1, 403 bytes * /

NSRect * FUN_000706e1(NSRect *__return_storage_ptr__,HSTextViewEditor *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  NSRect *pNVar2;
  NSRect *extraout_EAX;
  longdouble lVar3;
  float fVar4;
  float fVar5;
  double dVar6;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  _objc_msgSend_stret(&local_24,self,sel_editingObjectBounds);
  lVar3 = (longdouble)_roundf(local_1c);
  local_1c = (float)lVar3;
  lVar3 = (longdouble)_roundf(local_18);
  local_18 = (float)lVar3;
  lVar3 = (longdouble)_roundf(local_24);
  local_24 = (float)lVar3;
  lVar3 = (longdouble)_roundf(local_20);
  local_20 = (float)lVar3;
  pvVar1 = _objc_msgSend(self,sel_hostView);
  pvVar1 = _objc_msgSend(pvVar1,sel_userSpaceToViewSpaceTransform);
  pNVar2 = _objc_msgSend(pvVar1,sel_hyperScaleFactor);
  self_00 = cls_NSScroller;
  if (((float)pNVar2 != 0.0) || (NAN((float)pNVar2))) {
    fVar4 = ABS((float)pNVar2);
  }
  else {
    fVar4 = 1.0;
  }
  fVar5 = 1.0;
  if (1.0 <= fVar4) {
    fVar5 = fVar4;
  }
  if ((float)pNVar2 < fVar5 * -0.0005 + 1.0) {
    pvVar1 = _objc_msgSend(self,sel_attributesInterface);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperScrollBarControlSize);
    dVar6 = _objc_msgSend_fpret(self_00,sel_scrollerWidthForControlSize_,pvVar1);
    local_1c = ((float)dVar6 - (float)pNVar2 * (float)dVar6) + local_1c;
    pNVar2 = extraout_EAX;
  }
  (__return_storage_ptr__->origin).x = local_24;
  (__return_storage_ptr__->origin).y = local_20;
  (__return_storage_ptr__->size).width = local_1c;
  (__return_storage_ptr__->size).height = local_18;
  return pNVar2;
}

*/
- (NSRect)calculateOccupiedRect
{
    NSRect rect = [self editingObjectBounds];
    rect.size.width = roundf(rect.size.width);
    rect.size.height = roundf(rect.size.height);
    rect.origin.x = roundf(rect.origin.x);
    rect.origin.y = roundf(rect.origin.y);
    float scale = [[[self hostView] userSpaceToViewSpaceTransform] hyperScaleFactor].width;
    float a = scale != 0.0 ? fabsf(scale) : 1.0;
    float m = 1.0 <= a ? a : 1.0;
    if (scale < m * -0.0005 + 1.0) {
        float scrollerWidth = (float)[NSScroller scrollerWidthForControlSize:[[self attributesInterface] hyperScrollBarControlSize]];
        rect.size.width = (scrollerWidth - scale * scrollerWidth) + rect.size.width;
    }
    return rect;
}

- (BOOL)calculatedRectIsPrecise
{
    return YES;
}

- (id)attributesDidChangeNotificationNames
{
    return [NSArray array];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007089d @ 0007089d, 470 bytes * /

void FUN_0007089d(HSTextViewEditor *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  float extraout_EDX_00;
  longdouble lVar4;
  double dVar5;
  float local_38;
  undefined1 local_24 [12];
  float local_18;
  
  pvVar1 = _objc_msgSend(self,sel_hostView);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_hostView);
    pvVar1 = _objc_msgSend(pvVar1,sel_userSpaceToViewSpaceTransform);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperScaleFactor);
    _objc_msgSend(self->_textView,sel_scaleFactor);
    _objc_msgSend_stret(local_24,self->_textView,sel_frame);
    pvVar2 = _objc_msgSend(self->_textView,sel_enclosingScrollView);
    pvVar3 = _objc_msgSend(pvVar2,sel_verticalScroller);
    pvVar3 = _objc_msgSend(pvVar3,sel_class);
    dVar5 = _objc_msgSend_fpret(pvVar3,sel_scrollerWidth);
    if (1.0 < (float)pvVar1) {
      lVar4 = (longdouble)_ceilf((float)dVar5 * (float)pvVar1 - (float)dVar5);
      local_38 = (float)lVar4;
    }
    else {
      local_38 = 0.0;
    }
    pvVar2 = _objc_msgSend(pvVar2,sel_contentSize);
    _objc_msgSend(self->_textView,sel_setScaleFactor_,pvVar1,extraout_EDX);
    _objc_msgSend(self->_textView,sel_setFrameSize_,(float)pvVar2 - local_38,
                  local_18 / extraout_EDX_00);
  }
  return;
}

*/
- (void)updateViewScaleFactor
{
    if ([self hostView] != nil) {
        NSSize hyperScale = [[[self hostView] userSpaceToViewSpaceTransform] hyperScaleFactor];
        NSSize textScale = [_textView scaleFactor];
        float frameHeight = [_textView frame].size.height;
        NSScrollView *scroll = [_textView enclosingScrollView];
        float scrollerWidth = (float)[[[scroll verticalScroller] class] scrollerWidth];
        float adjust;
        if (1.0 < hyperScale.width) {
            adjust = ceilf(scrollerWidth * hyperScale.width - scrollerWidth);
        }
        else {
            adjust = 0.0;
        }
        NSSize content = [scroll contentSize];
        [_textView setScaleFactor:hyperScale];
        [_textView setFrameSize:NSMakeSize(content.width - adjust, frameHeight / textScale.height)];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00070a73 @ 00070a73, 455 bytes * /

void FUN_00070a73(HSTextViewEditor *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  HSTextViewEditor *local_1c;
  undefined *local_18;
  
  pvVar1 = _objc_msgSend(self,sel_attributesInterface);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperText);
  pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
  pvVar2 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar1 = _objc_msgSend(self->_textView,sel_textStorage);
  pvVar3 = _objc_msgSend(pvVar1,sel_length);
  pvVar4 = _objc_msgSend(pvVar2,sel_length);
  pvVar1 = self->_textView;
  if (pvVar4 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_attributesInterface);
    pvVar4 = _objc_msgSend(pvVar2,sel_hyperTextAttributes);
    op = sel_setTypingAttributes_;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_textStorage);
    _objc_msgSend(pvVar1,sel_beginEditing);
    pvVar1 = _objc_msgSend(self->_textView,sel_textStorage);
    pvVar4 = (id)0x0;
    _objc_msgSend(pvVar1,sel_replaceCharactersInRange_withAttributedString_,0,pvVar3,pvVar2);
    pvVar1 = _objc_msgSend(self->_textView,sel_textStorage);
    op = sel_endEditing;
  }
  _objc_msgSend(pvVar1,op,pvVar4);
  _objc_msgSend(self,sel_updateEmbeddedViewBackground);
  _objc_msgSend(self,sel_updateEmbeddedViewScrollerStyle);
  _objc_msgSend(self,sel_updateViewScaleFactor);
  local_1c = self;
  local_18 = PTR_s_HSBaseEmbeddedEditor_0034e860;
  _objc_msgSendSuper(&local_1c,sel_updateEmbeddedViewWithEditingObject);
  return;
}

*/
- (void)updateEmbeddedViewWithEditingObject
{
    NSMutableAttributedString *text = [[[[self attributesInterface] hyperText] mutableCopy] autorelease];
    NSUInteger storageLength = [[_textView textStorage] length];
    if ([text length] == 0) {
        [_textView setTypingAttributes:[[self attributesInterface] hyperTextAttributes]];
    }
    else {
        [[_textView textStorage] beginEditing];
        [[_textView textStorage] replaceCharactersInRange:NSMakeRange(0, storageLength) withAttributedString:text];
        [[_textView textStorage] endEditing];
    }
    [self updateEmbeddedViewBackground];
    [self updateEmbeddedViewScrollerStyle];
    [self updateViewScaleFactor];
    [super updateEmbeddedViewWithEditingObject];
}

- (id)loadEmbeddedView
{
    double dVar1;
    id pvVar2;
    id pvVar2_2;
    id pvVar3_3;

    pvVar2 = [NSScrollView alloc];
    dVar1 = NSAppKitVersionNumber;
    pvVar2_2 = [pvVar2 init];
    if (1138.0 <= dVar1) {
        [pvVar2_2 setScrollerStyle:0];
    }
    pvVar3_3 = [[HSTextView allocWithZone:[self zone]] init];
    [pvVar3_3 setUsesFindPanel:YES];
    [pvVar3_3 setEditable:YES];
    [pvVar3_3 setSelectable:YES];
    [pvVar3_3 setAllowsUndo:YES];
    [pvVar3_3 setDrawsBackground:NO];
    [pvVar2_2 setDocumentView:pvVar3_3];
    [pvVar3_3 release];
    [self setTextView:pvVar3_3];
    return [pvVar2_2 autorelease];
}

- (void)deactivateEditing
{
    if ([self isEditorChanged]) {
        [self finishUndoDuplicating:NO];
    }
    [[[self document] mainWindowController] setPreferedUndoManager:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HSCoreTextDidChangeAttributesNotification" object:[self coreEditorText]];
    [super deactivateEditing];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00070ec8 @ 00070ec8, 539 bytes * /

BOOL FUN_00070ec8(HSTextViewEditor *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar5;
  undefined4 uVar6;
  HSTextViewEditor *local_1c;
  undefined *local_18;
  
  self->_textDidEndEditing = '\0';
  pvVar1 = _objc_msgSend(self,sel_document);
  pvVar1 = _objc_msgSend(pvVar1,sel_mainWindowController);
  pvVar2 = _objc_msgSend(self,sel_undoManager);
  _objc_msgSend(pvVar1,sel_setPreferedUndoManager_,pvVar2);
  local_1c = self;
  local_18 = PTR_s_HSBaseEmbeddedEditor_0034e860;
  pvVar1 = _objc_msgSendSuper(&local_1c,sel_activateEditing);
  _objc_msgSend(self,sel_updateViewScaleFactor);
  if ((char)pvVar1 != '\0') {
    pvVar3 = self->_textView;
    pvVar2 = _objc_msgSend(*(id *)PTR_00336058,sel_currentEvent,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_locationInWindow);
    uVar6 = 0;
    uVar5 = extraout_EDX;
    pvVar3 = _objc_msgSend(pvVar3,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
    pvVar4 = _objc_msgSend(self->_textView,sel_textContainer);
    self_00 = _objc_msgSend(self->_textView,sel_layoutManager);
    if ((self_00 != (id)0x0) && (pvVar4 != (id)0x0)) {
      pvVar2 = _objc_msgSend(self_00,sel_glyphIndexForPoint_inTextContainer_,pvVar3,extraout_EDX_00,
                             pvVar4);
      uVar6 = 0;
      pvVar2 = _objc_msgSend(self_00,sel_characterRangeForGlyphRange_actualGlyphRange_,pvVar2,1,0);
      uVar5 = 0;
      _objc_msgSend(self->_textView,sel_setSelectedRange_,pvVar2,0);
    }
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter,pvVar2,uVar5,uVar6);
    pvVar3 = _objc_msgSend(self,sel_coreEditorText);
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,sel_coreTextDidChangeAttributes_
                  ,&cfstr_HSCoreTextDidChangeAttributesNotification,pvVar3);
  }
  return (char)pvVar1;
}

*/
- (BOOL)activateEditing
{
    _textDidEndEditing = NO;
    [[[self document] mainWindowController] setPreferedUndoManager:[self undoManager]];
    BOOL activated = [super activateEditing];
    [self updateViewScaleFactor];
    if (activated) {
        NSPoint point = [_textView convertPoint:[[NSApp currentEvent] locationInWindow] fromView:nil];
        NSTextContainer *container = [_textView textContainer];
        NSLayoutManager *layout = [_textView layoutManager];
        if (layout != nil && container != nil) {
            NSUInteger glyph = [layout glyphIndexForPoint:point inTextContainer:container];
            NSRange range = [layout characterRangeForGlyphRange:NSMakeRange(glyph, 1) actualGlyphRange:NULL];
            [_textView setSelectedRange:NSMakeRange(range.location, 0)];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreTextDidChangeAttributes:) name:@"HSCoreTextDidChangeAttributesNotification" object:[self coreEditorText]];
    }
    return activated;
}

- (void)hostViewDidChangeUserSpaceToViewSpaceTransform
{
    [super hostViewDidChangeUserSpaceToViewSpaceTransform];
    [self updateViewScaleFactor];
}

- (BOOL)haveChanges
{
    return (BOOL)[self isEditorChanged];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00071157 @ 00071157, 463 bytes * /

void FUN_00071157(HSTextViewEditor *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  undefined *puVar4;
  
  self->_saving = '\x01';
  pvVar2 = _objc_msgSend(self,sel_isEditorChanged);
  if ((char)pvVar2 == '\0') goto LAB_000712db;
  pvVar2 = _objc_msgSend(self,sel_document);
  puVar4 = sel_isAutosaving;
  pvVar2 = _objc_msgSend(pvVar2,sel_respondsToSelector_,sel_isAutosaving);
  if ((char)pvVar2 == '\0') {
LAB_000711e7:
    bVar1 = false;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_document,puVar4);
    pvVar2 = _objc_msgSend(pvVar2,sel_isAutosaving);
    if ((char)pvVar2 == '\0') goto LAB_000711e7;
    bVar1 = true;
  }
  if ((self->_textDidEndEditing == '\0') && (self->_undoApplied == '\0' && !bVar1)) {
    _objc_msgSend(self->_textView,sel_breakUndoCoalescing,puVar4);
    puVar4 = (undefined *)0x1;
    _objc_msgSend(self->_undoHelper,sel_finishDuplicating_,1);
    self->_undoApplied = '\x01';
  }
  pvVar3 = _objc_msgSend(self->_textView,sel_textStorage,puVar4);
  self_00 = _objc_msgSend(self,sel_attributesInterface);
  pvVar2 = pvVar3;
  _objc_msgSend(self_00,sel_setHyperText_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_length);
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_attributesInterface,pvVar2);
    pvVar2 = _objc_msgSend(self->_textView,sel_typingAttributes);
    _objc_msgSend(pvVar3,sel_applyHyperTextAttributesDictionary_,pvVar2);
  }
  if (!bVar1) {
    _objc_msgSend(self,sel_clearChangedState,pvVar2);
  }
LAB_000712db:
  pvVar2 = _objc_msgSend(self,sel_attributesInterface);
  pvVar3 = _objc_msgSend(self->_textView,sel_backgroundColor);
  _objc_msgSend(pvVar2,sel_setBackgroundColor_,pvVar3);
  self->_saving = '\0';
  return;
}

*/
- (void)saveEditing
{
    _saving = YES;
    if ([self isEditorChanged]) {
        BOOL autosaving = NO;
        if ([[self document] respondsToSelector:@selector(isAutosaving)]) {
            autosaving = [[self document] isAutosaving];
        }
        if (!_textDidEndEditing && !_undoApplied && !autosaving) {
            [_textView breakUndoCoalescing];
            [_undoHelper finishDuplicating:YES];
            _undoApplied = YES;
        }
        NSTextStorage *storage = [_textView textStorage];
        [[self attributesInterface] setHyperText:storage];
        if ([storage length] == 0) {
            [[self attributesInterface] applyHyperTextAttributesDictionary:[_textView typingAttributes]];
        }
        if (!autosaving) {
            [self clearChangedState];
        }
    }
    [[self attributesInterface] setBackgroundColor:[_textView backgroundColor]];
    _saving = NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00071326 @ 00071326, 408 bytes * /

id FUN_00071326(HSTextViewEditor *self,SEL _cmd,id queryHyperInterface)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  id self_00;
  char *pcVar4;
  char *pcVar5;
  int iVar6;
  HSTextViewEditor *local_1c;
  undefined *local_18;
  
  puVar1 = PTR_00336340;
  if (queryHyperInterface == &DAT_00365728) {
LAB_00071346:
    pvVar3 = _objc_msgSend(self,sel_attributesInterface);
    if (pvVar3 == (id)0x0) {
      pvVar3 = (id)0x0;
    }
    else {
      self_00 = _objc_msgSend(cls_HSSelectiveProxy,sel_alloc);
      pvVar3 = _objc_msgSend(self_00,sel_initWithRunTimeEditor_modelInterface_,self,pvVar3);
      pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
    }
  }
  else {
    if (*(double *)PTR_00336340 <= 677.0 && *(double *)PTR_00336340 != 677.0) {
      pcVar4 = _objc_msgSend(queryHyperInterface,sel_name);
    }
    else {
      pcVar4 = (char *)_protocol_getName(queryHyperInterface);
    }
    if (pcVar4 != (char *)0x0) {
      if (*(double *)puVar1 <= 677.0 && *(double *)puVar1 != 677.0) {
        pcVar5 = _objc_msgSend(&DAT_00365728,sel_name);
      }
      else {
        pcVar5 = (char *)_protocol_getName(&DAT_00365728);
      }
      if (pcVar5 != (char *)0x0) {
        iVar6 = _strcmp(pcVar4,pcVar5);
        if (iVar6 == 0) {
          if (*(double *)puVar1 <= 677.0 && *(double *)puVar1 != 677.0) {
            pvVar3 = _objc_msgSend(queryHyperInterface,sel_isEqual_,&DAT_00365728);
            cVar2 = (char)pvVar3;
          }
          else {
            cVar2 = _protocol_isEqual(queryHyperInterface,&DAT_00365728);
          }
          if (cVar2 != '\0') goto LAB_00071346;
        }
      }
    }
    local_1c = self;
    local_18 = PTR_s_HSBaseEmbeddedEditor_0034e860;
    pvVar3 = _objc_msgSendSuper(&local_1c,sel_queryHyperInterface_,queryHyperInterface);
  }
  return pvVar3;
}

*/
- (id)queryHyperInterface:(id)aInterface
{
    if (aInterface == @protocol(HSSystemTextViewAttributes) || protocol_isEqual(aInterface, @protocol(HSSystemTextViewAttributes))) {
        id attributes = [self attributesInterface];
        if (attributes == nil) {
            return nil;
        }
        return [[[HSSelectiveProxy alloc] initWithRunTimeEditor:self modelInterface:attributes] autorelease];
    }
    return [super queryHyperInterface:aInterface];
}

- (BOOL)shouldAutoResizeEditorToFitContent
{
    return NO;
}

- (id)coreEditorText
{
    id pvVar1;

    pvVar1 = _text;
    if (pvVar1 == nil) {
        pvVar1 = [[HSCoreEditorText alloc] initWithTextView:[self textView]];
        _text = pvVar1;
    }
    return pvVar1;
}

- (id)textView
{
    id pvVar1;

    pvVar1 = _textView;
    if (pvVar1 == nil) {
        [self embeddedView];
        pvVar1 = _textView;
    }
    return pvVar1;
}

- (void)setTextView:(id)aView
{
    id pvVar1;
    id pvVar1_2;

    if (_textView != aView) {
        [_textView setDelegate:0];
        [_textView release];
        pvVar1 = [aView retain];
        _textView = pvVar1;
        [pvVar1 setDelegate:self];
        pvVar1_2 = [HSLayoutManager new];
        [[_textView textContainer] replaceLayoutManager:pvVar1_2];
        [pvVar1_2 release];
    }
}

- (void)dealloc
{
    [_textView setDelegate:0];
    [_textView release];
    [_undoManager release];
    [_undoHelper release];
    [_text release];
    [super dealloc];
}

- (id)initWithHyperObject:(id)aObject
{
    self = [super initWithHyperObject:aObject];
    return self;
}

@end

