#import "HSTextViewEmbedder.h"

@implementation HSTextViewEmbedder

/* i386 ivar offsets: _textView=0x8, _undoManager=0xc, _text=0x10, _parentView=0x14, _supportsGradient=0x18, _attributesForSelectedRanges=0x1c */

- (void)textView:(id)aView willInsertText:(id)aText
{
    if ([[self observer] respondsToSelector:@selector(textView:willInsertText:)]) {
        [[self observer] textView:aView willInsertText:aText];
    }
}

- (void)setHyperSelectedRange:(NSRange)aRange
{
    [_textView setSelectedRange:aRange];
}

- (NSRange)hyperSelectedRange
{
    return [_textView selectedRange];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00073ac6 @ 00073ac6, 363 bytes * /

BOOL FUN_00073ac6(HSTextViewEmbedder *self,SEL _cmd,id textView,
                 id shouldHandlePerformKeyEquivalentOutsideOfKeyDown)

{
  undefined *puVar1;
  BOOL BVar2;
  id pvVar3;
  cfstringStruct *self_00;
  id pvVar4;
  id self_01;
  id pvVar5;
  undefined4 extraout_EDX;
  cfstringStruct *pcVar6;
  
  pvVar3 = _objc_msgSend(shouldHandlePerformKeyEquivalentOutsideOfKeyDown,
                         sel_BT_keyBindingCharacters);
  pcVar6 = &cfstr__0;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,&cfstr__0);
  if ((char)pvVar3 == '\0') {
    BVar2 = '\x01';
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_attributesForSelectedRanges,pcVar6);
    pvVar3 = _objc_msgSend(pvVar3,sel_keyEnumerator);
    self_00 = _objc_msgSend(pvVar3,sel_nextObject);
    puVar1 = PTR_00336068;
    while (self_00 != (cfstringStruct *)0x0) {
      pvVar4 = _objc_msgSend(self,sel_attributesForSelectedRanges,pcVar6);
      pcVar6 = self_00;
      pvVar4 = _objc_msgSend(pvVar4,sel_objectForKey_);
      if (pvVar4 != (id)0x0) {
        self_01 = _objc_msgSend(textView,sel_textStorage,pcVar6);
        pvVar5 = _objc_msgSend(self_00,sel_rangeValue);
        pcVar6 = *(cfstringStruct **)puVar1;
        _objc_msgSend(self_01,sel_addAttribute_value_range_,pcVar6,pvVar4,pvVar5,extraout_EDX);
      }
      self_00 = _objc_msgSend(pvVar3,sel_nextObject,pcVar6);
    }
    _objc_msgSend(self,sel_textDidChange_,0);
    BVar2 = '\0';
  }
  return BVar2;
}

*/
- (BOOL)textView:(id)aView shouldHandlePerformKeyEquivalentOutsideOfKeyDown:(id)aDown
{
    if (![[aDown BT_keyBindingCharacters] isEqualToString:@"@0"]) {
        return YES;
    }
    NSEnumerator *keys = [[self attributesForSelectedRanges] keyEnumerator];
    id key;
    while ((key = [keys nextObject]) != nil) {
        id font = [[self attributesForSelectedRanges] objectForKey:key];
        if (font != nil) {
            [[aView textStorage] addAttribute:NSFontAttributeName value:font range:[key rangeValue]];
        }
    }
    [self textDidChange:nil];
    return NO;
}

- (void)textView:(id)aView hyperColorDidChange:(id)aChange
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Change Text Color" value:@"" table:@"UndoManager"];
    [[self text] setHyperTextColor:[aChange color] undoActionName:pvVar1_2];
}

- (BOOL)textView:(id)aView shouldHyperChangeColor:(id)aColor
{
    return ![HSColorWell hasActiveColorWell];
}

- (BOOL)textView:(id)aView doCommandBySelector:(SEL)aSelector
{
    BOOL bVar1;

    bVar1 = @selector(cancelOperation:) == aSelector;
    if (bVar1) {
        [[self observer] runTimeEditorEmbedderWantsToCancel:self];
    }
    return bVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00073909 @ 00073909, 145 bytes * /

id FUN_00073909(HSTextViewEmbedder *self,SEL _cmd,id textView,
               id willChangeSelectionFromCharacterRanges,id toCharacterRanges)

{
  id pvVar1;
  int extraout_EDX;
  undefined4 uVar2;
  
  pvVar1 = _objc_msgSend(willChangeSelectionFromCharacterRanges,sel_count);
  if (pvVar1 == (id)0x1) {
    uVar2 = 0;
    pvVar1 = _objc_msgSend(willChangeSelectionFromCharacterRanges,sel_objectAtIndex_,0);
    _objc_msgSend(pvVar1,sel_rangeValue);
    if (extraout_EDX == 0) {
      pvVar1 = _objc_msgSend(self,sel_observer,uVar2);
      _objc_msgSend(pvVar1,sel_runTimeEditorEmbedderWillChangeSelectionWithoutChangingContent_,self)
      ;
    }
  }
  return toCharacterRanges;
}

*/
- (id)textView:(id)aView willChangeSelectionFromCharacterRanges:(id)aRanges toCharacterRanges:(id)aRanges2
{
    if ([aRanges count] == 1) {
        if ([[aRanges objectAtIndex:0] rangeValue].length == 0) {
            [[self observer] runTimeEditorEmbedderWillChangeSelectionWithoutChangingContent:self];
        }
    }
    return aRanges2;
}

- (void)textViewDidChangeSelection:(id)aSelection
{
    [self rememberAttributesForSelectedRangesForTextView:[aSelection object]];
    [[self observer] runTimeEditorEmbedderDidChangeSelectionWithoutChangingContent:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000736ff @ 000736ff, 415 bytes * /

void FUN_000736ff(HSTextViewEmbedder *self,SEL _cmd,
                 id rememberAttributesForSelectedRangesForTextView)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int extraout_EDX;
  int iVar7;
  id *ppvVar8;
  int iVar9;
  id local_38;
  id local_1c;
  int local_18;
  
  self_00 = _objc_msgSend(rememberAttributesForSelectedRangesForTextView,sel_selectedRanges);
  pvVar2 = _objc_msgSend(self_00,sel_count);
  _objc_msgSend(self,sel_clearAttributesForSelectedRanges);
  puVar1 = PTR_00336068;
  local_38 = (id)0x0;
  while( true ) {
    if (pvVar2 <= local_38) {
      return;
    }
    pvVar5 = local_38;
    pvVar3 = _objc_msgSend(self_00,sel_objectAtIndex_,local_38);
    pvVar3 = _objc_msgSend(pvVar3,sel_rangeValue);
    if (extraout_EDX == 0) break;
    local_18 = 0;
    local_1c = pvVar3;
    do {
      iVar7 = local_18;
      pvVar6 = local_1c;
      pvVar4 = _objc_msgSend(rememberAttributesForSelectedRangesForTextView,sel_textStorage,pvVar5);
      pvVar5 = *(id *)puVar1;
      ppvVar8 = &local_1c;
      iVar7 = (int)pvVar6 + iVar7;
      pvVar6 = pvVar3;
      iVar9 = extraout_EDX;
      pvVar4 = _objc_msgSend(pvVar4,sel_attribute_atIndex_longestEffectiveRange_inRange_,pvVar5,
                             iVar7,ppvVar8,pvVar3,extraout_EDX);
      if (pvVar4 != (id)0x0) {
        pvVar5 = _objc_msgSend(self,sel_attributesForSelectedRanges,pvVar5,iVar7,ppvVar8,pvVar6,
                               iVar9);
        pvVar6 = _objc_msgSend(cls_NSValue,sel_valueWithRange_,local_1c,local_18);
        _objc_msgSend(pvVar5,sel_setObject_forKey_,pvVar4,pvVar6);
        pvVar5 = pvVar4;
      }
    } while ((uint)(local_18 + (int)local_1c) < (uint)(extraout_EDX + (int)pvVar3));
    local_38 = (id)((int)local_38 + 1);
  }
  return;
}

*/
- (void)rememberAttributesForSelectedRangesForTextView:(id)aView
{
    NSArray *ranges = [aView selectedRanges];
    NSUInteger count = [ranges count];
    [self clearAttributesForSelectedRanges];
    for (NSUInteger i = 0; i < count; i++) {
        NSRange range = [[ranges objectAtIndex:i] rangeValue];
        if (range.length == 0) {
            break;
        }
        NSRange effective = NSMakeRange(range.location, 0);
        do {
            id font = [[aView textStorage] attribute:NSFontAttributeName atIndex:effective.location + effective.length longestEffectiveRange:&effective inRange:range];
            if (font != nil) {
                [[self attributesForSelectedRanges] setObject:font forKey:[NSValue valueWithRange:effective]];
            }
        } while (effective.location + effective.length < range.location + range.length);
    }
}

- (void)clearAttributesForSelectedRanges
{
    [_attributesForSelectedRanges release];
    _attributesForSelectedRanges = nil;
}

- (id)attributesForSelectedRanges
{
    id pvVar1;

    pvVar1 = _attributesForSelectedRanges;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableDictionary alloc] initWithCapacity:1];
        _attributesForSelectedRanges = pvVar1;
    }
    return pvVar1;
}

- (void)textDidEndEditing:(id)aEditing
{
    if ([self isMountedInHostView]) {
        [[self observer] runTimeEditorEmbedderWantsToResign:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00073520 @ 00073520, 259 bytes * /

void FUN_00073520(HSTextViewEmbedder *self,SEL _cmd,id textDidChange)

{
  id pvVar1;
  id pvVar2;
  HSTextViewEmbedder *pHVar3;
  
  pvVar1 = _objc_msgSend(self,sel_observer);
  pHVar3 = self;
  _objc_msgSend(pvVar1,sel_runTimeEditorEmbedderDidChangeContent_,self);
  pvVar1 = _objc_msgSend(self,sel_isMountedInHostView);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,pHVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_selectedToolTag);
    if (pvVar1 == (id)0x2) {
      pvVar1 = _objc_msgSend(self,sel_embeddedView,pHVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_window);
      pvVar1 = _objc_msgSend(pvVar1,sel_windowController);
      pvVar1 = _objc_msgSend(pvVar1,sel_document);
      pvVar2 = _objc_msgSend(pvVar1,sel_isDocumentEdited);
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(pvVar1,sel_updateChangeCount_,0);
      }
    }
  }
  return;
}

*/
- (void)textDidChange:(id)aChange
{
    [[self observer] runTimeEditorEmbedderDidChangeContent:self];
    if ([self isMountedInHostView]) {
        if ([[HSToolManager sharedToolManager] selectedToolTag] == 2) {
            id document = [[[[self embeddedView] window] windowController] document];
            if (![document isDocumentEdited]) {
                [document updateChangeCount:NSChangeDone];
            }
        }
    }
}

- (id)undoManagerForTextView:(id)aView
{
    id pvVar1;

    pvVar1 = _undoManager;
    if (pvVar1 == nil) {
        pvVar1 = [self undoManager];
        _undoManager = pvVar1;
    }
    return pvVar1;
}

- (void)toggleOutlineInTextView:(id)aView
{
    NSString *pvVar1_2;

    pvVar1_2 = [[NSBundle mainBundle] localizedStringForKey:@"Outline" value:@"" table:@"UndoManager"];
    [[self text] setHyperOutlineEnabled:(unsigned int)(![[self text] isHyperOutlineEnabled]) undoActionName:pvVar1_2];
}

- (id)undoManager
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _undoManager;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSRunTimeEditorUndoManager alloc] init];
        _undoManager = pvVar1_3;
        [pvVar1_3 setDelegate:[[self observer] queryHyperInterface:@protocol(HSRunTimeEditorUndoManagerDelegate)]];
        pvVar1 = _undoManager;
    }
    return pvVar1;
}

- (void)breakUndoCoalescing
{
    [_textView breakUndoCoalescing];
}

- (void)removeAllUndoActions
{
    [_undoManager removeAllActions];
}

- (NSRect)borderRect
{
    NSRect result;

    result = [[self textView] borderRect];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000732ef @ 000732ef, 80 bytes * /

void FUN_000732ef(HSTextViewEmbedder *self,SEL _cmd,NSRect setBorderRect)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_textView);
  _objc_msgSend(self_00,sel_setBorderRect_,setBorderRect.origin,setBorderRect.size);
  return;
}

*/
- (void)setBorderRect:(NSRect)aRect
{
    [[self textView] setBorderRect:aRect];
}

- (BOOL)drawsBorderRect
{
    return (BOOL)[[self textView] drawsBorderRect];
}

- (void)setDrawsBorderRect:(BOOL)aRect
{
    if ((BOOL)[[self textView] drawsBorderRect] != (aRect != NO)) {
        [[self textView] setDrawsBorderRect:((unsigned int)(aRect != NO))];
        if (aRect != NO) {
            [[self textView] setBorderRectColor:[HSSelectedObjectCanvasItem cardObjectBoundingFrameColor]];
            [[self textView] setBorderRectThickness:(float)[HSSelectedObjectCanvasItem cardObjectBoundingFrameThickness]];
        }
    }
}

- (void)applyOriginalTextSize:(NSSize)aSize
{
    [[self textView] setFrameSize:aSize];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00073223 @ 00073223, 63 bytes * /

void FUN_00073223(HSTextViewEmbedder *self,SEL _cmd,NSSize setScaleFactor)

{
  _objc_msgSend(self->_parentView,sel_setScaleFactor_,setScaleFactor.width,setScaleFactor.height);
  return;
}

*/
- (void)setScaleFactor:(NSSize)aFactor
{
    [_parentView setScaleFactor:aFactor];
}

- (NSSize)scaleFactor
{
    return [_parentView scaleFactor];
}

- (id)hyperText
{
    return [self text];
}

- (BOOL)makeEmbeddedViewFirstResponder
{
    NSTextView *pvVar1;

    pvVar1 = [self textView];
    return (BOOL)[[pvVar1 window] makeFirstResponder:pvVar1];
}

- (id)text
{
    id pvVar1;

    pvVar1 = _text;
    if (pvVar1 == nil) {
        pvVar1 = [[HSCoreEditorText alloc] initWithTextView:[self textView]];
        _text = pvVar1;
    }
    return pvVar1;
}

- (id)embeddedView
{
    id pvVar1;
    NSTextView *pvVar1_3;

    pvVar1 = _parentView;
    if (pvVar1 == nil) {
        _parentView = [HSScalingView new];
        pvVar1_3 = [self textView];
        [_parentView addSubview:pvVar1_3];
        [pvVar1_3 release];
        pvVar1 = _parentView;
    }
    return pvVar1;
}

- (id)textView
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _textView;
    if (pvVar1 == nil) {
        pvVar1_2 = [self createTextView];
        _textView = pvVar1_2;
        [pvVar1_2 setUsesFindPanel:YES];
        [_textView setHorizontallyResizable:NO];
        [_textView setVerticallyResizable:NO];
        [_textView setEditable:YES];
        [_textView setSelectable:YES];
        [_textView setAllowsUndo:YES];
        [_textView setDrawsBackground:NO];
        [_textView setNeverDrawsBackground:YES];
        [_textView setTextContainerInset:NSZeroSize];
        [_textView setDelegate:self];
        pvVar1 = _textView;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00072e5d @ 00072e5d, 211 bytes * /

id FUN_00072e5d(HSTextViewEmbedder *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id self_01;
  id self_02;
  undefined8 uVar2;
  undefined8 uVar3;
  
  self_00 = cls_HSNonOpaqueTextView;
  pvVar1 = _objc_msgSend(self,sel_zone);
  pvVar1 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar1);
  uVar2 = *(undefined8 *)PTR_00336078;
  uVar3 = *(undefined8 *)(PTR_00336078 + 8);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,uVar2,uVar3);
  if (self->_supportsGradient != '\0') {
    self_01 = _objc_msgSend(cls_HSLayoutManager,sel_new,uVar2,uVar3);
    self_02 = _objc_msgSend(pvVar1,sel_textContainer);
    _objc_msgSend(self_02,sel_replaceLayoutManager_,self_01);
    _objc_msgSend(self_01,sel_release);
  }
  return pvVar1;
}

*/
- (id)createTextView
{
    HSNonOpaqueTextView *textView = [[HSNonOpaqueTextView allocWithZone:[self zone]] initWithFrame:NSZeroRect];
    if (_supportsGradient) {
        HSLayoutManager *layoutManager = [HSLayoutManager new];
        [[textView textContainer] replaceLayoutManager:layoutManager];
        [layoutManager release];
    }
    return textView;
}

- (id)initWithGradientSupport:(BOOL)aSupport
{
    self = [super init];
    if (self != nil) {
        _supportsGradient = aSupport;
    }
    return self;
}

- (id)init
{
    return [self initWithGradientSupport:NO];
}

- (void)dealloc
{
    NSNotificationCenter *self_00;
    HSTextViewEmbedder *pHVar2;

    self_00 = [NSNotificationCenter defaultCenter];
    pHVar2 = self;
    [self_00 removeObserver:self];
    [_attributesForSelectedRanges release];
    if ([_textView delegate] == self) {
        pHVar2 = nil;
        [_textView setDelegate:0];
    }
    [_parentView autorelease];
    [_undoManager setDelegate:0];
    [_undoManager release];
    [_text release];
    [super dealloc];
}

@end

