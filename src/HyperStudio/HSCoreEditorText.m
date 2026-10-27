#import "HSCoreEditorText.h"

@implementation HSCoreEditorText

/* i386 ivar offsets: _textView=0x4 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000742c3 @ 000742c3, 161 bytes * /

void FUN_000742c3(HSCoreEditorText *self,SEL _cmd,id convertParagraphAttribute,id value,
                 SEL convertAttributeSelector,id actionName)

{
  id pvVar1;
  id pvVar2;
  id extraout_EDX;
  
  if (self->_textView == (id)0x0) {
    pvVar1 = (id)0x0;
    pvVar2 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(self->_textView,sel_rangeForUserParagraphAttributeChange);
    pvVar2 = extraout_EDX;
    if (pvVar1 == (id)0x7fffffff) {
      pvVar2 = _objc_msgSend(self->_textView,sel_textStorage);
      pvVar2 = _objc_msgSend(pvVar2,sel_length);
      pvVar1 = (id)0x0;
    }
  }
  _objc_msgSend(self,sel_convertAttribute_inRange_value_convertAttributeSelector_actionName_,
                convertParagraphAttribute,pvVar1,pvVar2,value,convertAttributeSelector,actionName);
  return;
}

*/
- (void)convertParagraphAttribute:(id)aAttribute value:(id)aValue convertAttributeSelector:(SEL)aSelector actionName:(id)aName
{
    NSRange range = NSMakeRange(0, 0);
    if (_textView != nil) {
        range = [_textView rangeForUserParagraphAttributeChange];
        if (range.location == NSNotFound) {
            range = NSMakeRange(0, [[_textView textStorage] length]);
        }
    }
    [self convertAttribute:aAttribute inRange:range value:aValue convertAttributeSelector:aSelector actionName:aName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00074364 @ 00074364, 111 bytes * /

void FUN_00074364(HSCoreEditorText *self,SEL _cmd,id convertActualCharacterAttribute,id value,
                 SEL convertAttributeSelector,id actionName)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 extraout_EDX;
  
  if (self->_textView == (id)0x0) {
    pvVar1 = (id)0x0;
    uVar2 = 0;
  }
  else {
    pvVar1 = _objc_msgSend(self->_textView,sel_rangeForUserCharacterAttributeChange);
    uVar2 = extraout_EDX;
  }
  _objc_msgSend(self,sel_convertActualAttribute_inRange_value_convertAttributeSelector_actionName_,
                convertActualCharacterAttribute,pvVar1,uVar2,value,convertAttributeSelector,
                actionName);
  return;
}

*/
- (void)convertActualCharacterAttribute:(id)aAttribute value:(id)aValue convertAttributeSelector:(SEL)aSelector actionName:(id)aName
{
    NSRange range = NSMakeRange(0, 0);
    if (_textView != nil) {
        range = [_textView rangeForUserCharacterAttributeChange];
    }
    [self convertActualAttribute:aAttribute inRange:range value:aValue convertAttributeSelector:aSelector actionName:aName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000743d3 @ 000743d3, 111 bytes * /

void FUN_000743d3(HSCoreEditorText *self,SEL _cmd,id convertCharacterAttribute,id value,
                 SEL convertAttributeSelector,id actionName)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 extraout_EDX;
  
  if (self->_textView == (id)0x0) {
    pvVar1 = (id)0x0;
    uVar2 = 0;
  }
  else {
    pvVar1 = _objc_msgSend(self->_textView,sel_rangeForUserCharacterAttributeChange);
    uVar2 = extraout_EDX;
  }
  _objc_msgSend(self,sel_convertAttribute_inRange_value_convertAttributeSelector_actionName_,
                convertCharacterAttribute,pvVar1,uVar2,value,convertAttributeSelector,actionName);
  return;
}

*/
- (void)convertCharacterAttribute:(id)aAttribute value:(id)aValue convertAttributeSelector:(SEL)aSelector actionName:(id)aName
{
    NSRange range = NSMakeRange(0, 0);
    if (_textView != nil) {
        range = [_textView rangeForUserCharacterAttributeChange];
    }
    [self convertAttribute:aAttribute inRange:range value:aValue convertAttributeSelector:aSelector actionName:aName];
}

- (void)convertActualAttribute:(id)aAttribute inRange:(NSRange)aRange value:(id)aValue convertAttributeSelector:(SEL)aSelector actionName:(id)aName
{
    [self convertAttribute:aAttribute inRange:aRange value:aValue convertAttributeSelector:aSelector actionName:aName replaceWithDefaultValueIfNil:NO];
}

- (void)convertAttribute:(id)aAttribute inRange:(NSRange)aRange value:(id)aValue convertAttributeSelector:(SEL)aSelector actionName:(id)aName
{
    [self convertAttribute:aAttribute inRange:aRange value:aValue convertAttributeSelector:aSelector actionName:aName replaceWithDefaultValueIfNil:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000744f2 @ 000744f2, 436 bytes * /

void FUN_000744f2(HSCoreEditorText *self,SEL _cmd,id convertAttribute,NSRange inRange,id value,
                 SEL convertAttributeSelector,id actionName,BOOL replaceWithDefaultValueIfNil)

{
  id pvVar1;
  id self_00;
  SEL op;
  int extraout_EDX;
  uint uVar2;
  uint uVar3;
  undefined4 uVar4;
  
  if (self->_textView != (id)0x0) {
    if ((inRange.length == 0) || (_objc_msgSend(self,sel_selectedRange), extraout_EDX == 0)) {
      pvVar1 = _objc_msgSend(self,sel_typingAttributeNamed_replaceWithDefaultValueIfNil_,
                             convertAttribute,(uint)(byte)replaceWithDefaultValueIfNil);
      self_00 = _objc_msgSend(cls_NSMutableAttributedString,sel_class);
      pvVar1 = _objc_msgSend(self_00,sel_performSelector_withObject_withObject_,
                             convertAttributeSelector,pvVar1,value);
      _objc_msgSend(self,sel_setTypingAttributeNamed_value_actionName_,convertAttribute,pvVar1,
                    actionName);
    }
    if (inRange.length != 0) {
      uVar4 = 0;
      uVar2 = inRange.location;
      uVar3 = inRange.length;
      pvVar1 = _objc_msgSend(self->_textView,sel_shouldChangeTextInRange_replacementString_,
                             inRange.location,inRange.length,0);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(self,sel_textStorage,uVar2,uVar3,uVar4);
        op = sel_hyperConvertActualAttribute_inRange_toValue_convertAttributeSelector_;
        if (replaceWithDefaultValueIfNil != '\0') {
          op = sel_hyperConvertAttribute_inRange_toValue_convertAttributeSelector_;
        }
        _objc_msgSend(pvVar1,op,convertAttribute,inRange.location,inRange.length,value,
                      convertAttributeSelector);
        _objc_msgSend(self->_textView,sel_didChangeText);
        if (actionName != (id)0x0) {
          pvVar1 = _objc_msgSend(self,sel_undoManager,convertAttribute,inRange.location,
                                 inRange.length,value,convertAttributeSelector);
          _objc_msgSend(pvVar1,sel_setActionName_,actionName);
        }
      }
    }
  }
  return;
}

*/
- (void)convertAttribute:(id)aAttribute inRange:(NSRange)aRange value:(id)aValue convertAttributeSelector:(SEL)aSelector actionName:(id)aName replaceWithDefaultValueIfNil:(BOOL)aNil
{
    if (_textView == nil) {
        return;
    }
    if (aRange.length == 0 || [self selectedRange].length == 0) {
        id typingValue = [self typingAttributeNamed:aAttribute replaceWithDefaultValueIfNil:aNil];
        id converted = [[NSMutableAttributedString class] performSelector:aSelector withObject:typingValue withObject:aValue];
        [self setTypingAttributeNamed:aAttribute value:converted actionName:aName];
    }
    if (aRange.length != 0 && [_textView shouldChangeTextInRange:aRange replacementString:nil]) {
        if (aNil) {
            [[self textStorage] hyperConvertAttribute:aAttribute inRange:aRange toValue:aValue convertAttributeSelector:aSelector];
        } else {
            [[self textStorage] hyperConvertActualAttribute:aAttribute inRange:aRange toValue:aValue convertAttributeSelector:aSelector];
        }
        [_textView didChangeText];
        if (aName != nil) {
            [[self undoManager] setActionName:aName];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000746a6 @ 000746a6, 420 bytes * /

void FUN_000746a6(HSCoreEditorText *self,SEL _cmd,uint applyFontTrait,id actionName)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int extraout_EDX;
  int extraout_EDX_00;
  int iVar5;
  undefined4 uVar6;
  
  if (self->_textView != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_textView,sel_rangeForUserCharacterAttributeChange);
    if ((extraout_EDX == 0) || (_objc_msgSend(self,sel_selectedRange), extraout_EDX_00 == 0)) {
      puVar1 = PTR_00336068;
      pvVar3 = _objc_msgSend(self,sel_typingAttributeNamed_,*(undefined4 *)PTR_00336068);
      pvVar4 = _objc_msgSend(cls_NSFontManager,sel_sharedFontManager);
      pvVar3 = _objc_msgSend(pvVar4,sel_convertFont_toHaveTrait_,pvVar3,applyFontTrait);
      _objc_msgSend(self,sel_setTypingAttributeNamed_value_actionName_,*(undefined4 *)puVar1,pvVar3,
                    actionName);
    }
    if (extraout_EDX != 0) {
      uVar6 = 0;
      pvVar3 = pvVar2;
      iVar5 = extraout_EDX;
      pvVar4 = _objc_msgSend(self->_textView,sel_shouldChangeTextInRange_replacementString_,pvVar2,
                             extraout_EDX,0);
      if ((char)pvVar4 != '\0') {
        pvVar3 = _objc_msgSend(self,sel_textStorage,pvVar3,iVar5,uVar6);
        iVar5 = extraout_EDX;
        _objc_msgSend(pvVar3,sel_applyFontTraits_range_,applyFontTrait,pvVar2,extraout_EDX);
        _objc_msgSend(self->_textView,sel_didChangeText);
        if (actionName != (id)0x0) {
          pvVar2 = _objc_msgSend(self,sel_undoManager,applyFontTrait,pvVar2,iVar5);
          _objc_msgSend(pvVar2,sel_setActionName_,actionName);
        }
      }
    }
    return;
  }
  return;
}

*/
- (void)applyFontTrait:(NSUInteger)aTrait actionName:(id)aName
{
    if (_textView == nil) {
        return;
    }
    NSRange range = [_textView rangeForUserCharacterAttributeChange];
    if (range.length == 0 || [self selectedRange].length == 0) {
        id font = [[NSFontManager sharedFontManager] convertFont:[self typingAttributeNamed:NSFontAttributeName] toHaveTrait:aTrait];
        [self setTypingAttributeNamed:NSFontAttributeName value:font actionName:aName];
    }
    if (range.length != 0 && [_textView shouldChangeTextInRange:range replacementString:nil]) {
        [[self textStorage] applyFontTraits:aTrait range:range];
        [_textView didChangeText];
        if (aName != nil) {
            [[self undoManager] setActionName:aName];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007484a @ 0007484a, 547 bytes * /

void FUN_0007484a(HSCoreEditorText *self,SEL _cmd,id applyAttributeDictionary,id actionName)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  HSCoreEditorText *pHVar4;
  int extraout_EDX;
  int extraout_EDX_00;
  SEL op;
  HSCoreEditorText *pHVar5;
  cfstringStruct *pcVar6;
  int iVar7;
  undefined4 uVar8;
  
  puVar1 = PTR_00336150;
  if (self->_textView == (id)0x0) {
    return;
  }
  pvVar3 = *(id *)PTR_00336150;
  pvVar2 = _objc_msgSend(applyAttributeDictionary,sel_objectForKey_,pvVar3);
  if (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionaryWithDictionary_,
                           applyAttributeDictionary);
    _objc_msgSend(pvVar3,sel_removeObjectForKey_,*(undefined4 *)puVar1);
    applyAttributeDictionary = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithDictionary_,pvVar3);
  }
  pHVar4 = _objc_msgSend(self->_textView,sel_rangeForUserCharacterAttributeChange,pvVar3);
  if ((extraout_EDX == 0) || (_objc_msgSend(self,sel_selectedRange,pvVar3), extraout_EDX_00 == 0)) {
    _objc_msgSend(self->_textView,sel_setTypingAttributes_,applyAttributeDictionary);
    pvVar3 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    pcVar6 = &cfstr_HSCoreTextDidChangeAttributesNotification;
    op = sel_postNotificationName_object_;
    pHVar4 = self;
  }
  else {
    if (actionName != (id)0x0) {
      pvVar3 = _objc_msgSend(self,sel_undoManager,pvVar3);
      _objc_msgSend(pvVar3,sel_setActionName_,actionName);
    }
    uVar8 = 0;
    pHVar5 = pHVar4;
    iVar7 = extraout_EDX;
    pvVar3 = _objc_msgSend(self->_textView,sel_shouldChangeTextInRange_replacementString_,pHVar4,
                           extraout_EDX,0);
    if ((char)pvVar3 == '\0') goto LAB_00074a2b;
    pvVar3 = _objc_msgSend(self,sel_textStorage,pHVar5,iVar7,uVar8);
    _objc_msgSend(pvVar3,sel_setAttributes_range_,applyAttributeDictionary,pHVar4,extraout_EDX);
    pvVar3 = self->_textView;
    op = sel_didChangeText;
    pcVar6 = applyAttributeDictionary;
  }
  _objc_msgSend(pvVar3,op,pcVar6,pHVar4);
LAB_00074a2b:
  if (pvVar2 != (id)0x0) {
    _objc_msgSend(self,sel_setAttributeNamed_characterAttribute_value_actionName_,
                  *(undefined4 *)puVar1,0,pvVar2,actionName);
  }
  return;
}

*/
- (void)applyAttributeDictionary:(id)aDictionary actionName:(id)aName
{
    if (_textView == nil) {
        return;
    }
    id paragraphStyle = [aDictionary objectForKey:NSParagraphStyleAttributeName];
    if (paragraphStyle != nil) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:aDictionary];
        [mutableDictionary removeObjectForKey:NSParagraphStyleAttributeName];
        aDictionary = [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    NSRange range = [_textView rangeForUserCharacterAttributeChange];
    if (range.length == 0 || [self selectedRange].length == 0) {
        [_textView setTypingAttributes:aDictionary];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCoreTextDidChangeAttributesNotification" object:self];
    } else {
        if (aName != nil) {
            [[self undoManager] setActionName:aName];
        }
        if ([_textView shouldChangeTextInRange:range replacementString:nil]) {
            [[self textStorage] setAttributes:aDictionary range:range];
            [_textView didChangeText];
        }
    }
    if (paragraphStyle != nil) {
        [self setAttributeNamed:NSParagraphStyleAttributeName characterAttribute:NO value:paragraphStyle actionName:aName];
    }
}

- (void)setCharacterAttributeNamed:(id)aNamed value:(id)aValue actionName:(id)aName
{
    [self setAttributeNamed:aNamed characterAttribute:YES value:aValue actionName:aName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00074ab0 @ 00074ab0, 819 bytes * /

void FUN_00074ab0(HSCoreEditorText *self,SEL _cmd,id setOutlineValue,id actionName)

{
  bool bVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  int extraout_EDX;
  int extraout_EDX_00;
  int iVar10;
  undefined4 uVar11;
  
  if (self->_textView == (id)0x0) {
    return;
  }
  pvVar2 = _objc_msgSend(self->_textView,sel_rangeForUserCharacterAttributeChange);
  if ((extraout_EDX == 0) || (_objc_msgSend(self,sel_selectedRange), extraout_EDX_00 == 0)) {
    self_00 = cls_NSAttributedString;
    pvVar4 = _objc_msgSend(self,sel_typingAttributes);
    pvVar5 = setOutlineValue;
    pvVar3 = _objc_msgSend(self_00,
                           sel_hyperAttributeValuesAffectedByApplyingOutlineValue_inDictionary_,
                           setOutlineValue,pvVar4);
    if ((pvVar3 != (id)0x0) &&
       (pvVar6 = _objc_msgSend(pvVar3,sel_isEmpty,pvVar5,pvVar4), (char)pvVar6 == '\0')) {
      pvVar6 = _objc_msgSend(pvVar3,sel_attributeNamesEnumerator,pvVar5,pvVar4);
      pvVar5 = _objc_msgSend(pvVar6,sel_nextObject);
      while (pvVar5 != (id)0x0) {
        pvVar7 = _objc_msgSend(self,sel_typingAttributeNamed_,pvVar5,pvVar4);
        pvVar8 = _objc_msgSend(pvVar3,sel_replacementValueForAttributeName_,pvVar5);
        pvVar4 = pvVar8;
        pvVar9 = _objc_msgSend(cls_NSAttributedString,sel_isHyperAttribute_equalToAttribute_,pvVar7)
        ;
        if ((char)pvVar9 == '\0') {
          _objc_msgSend(self,sel_setTypingAttributeNamed_value_actionName_,pvVar5,pvVar8,actionName)
          ;
          pvVar7 = pvVar5;
          pvVar4 = pvVar8;
        }
        pvVar5 = _objc_msgSend(pvVar6,sel_nextObject,pvVar7,pvVar4);
      }
      goto LAB_00074b13;
    }
    bVar1 = true;
  }
  else {
LAB_00074b13:
    bVar1 = false;
  }
  if (extraout_EDX != 0) {
    pvVar3 = _objc_msgSend(self,sel_textStorage);
    pvVar4 = pvVar2;
    iVar10 = extraout_EDX;
    pvVar5 = setOutlineValue;
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperReplacementsForAttributesInRange_forApplyingOutlineValue_
                           ,pvVar2,extraout_EDX,setOutlineValue);
    if ((pvVar3 == (id)0x0) ||
       (pvVar4 = _objc_msgSend(pvVar3,sel_isEmpty,pvVar4,iVar10,pvVar5), (char)pvVar4 != '\0'))
    goto LAB_00074c50;
    uVar11 = 0;
    pvVar4 = pvVar2;
    iVar10 = extraout_EDX;
    pvVar5 = _objc_msgSend(self->_textView,sel_shouldChangeTextInRange_replacementString_,pvVar2,
                           extraout_EDX,0);
    if ((char)pvVar5 != '\0') {
      pvVar4 = _objc_msgSend(self,sel_textStorage,pvVar4,iVar10,uVar11);
      iVar10 = extraout_EDX;
      _objc_msgSend(pvVar4,sel_hyperApplyAttributeReplacements_range_,pvVar3,pvVar2,extraout_EDX);
      _objc_msgSend(self->_textView,sel_didChangeText);
      if (actionName != (id)0x0) {
        pvVar2 = _objc_msgSend(self,sel_undoManager,pvVar3,pvVar2,iVar10);
        _objc_msgSend(pvVar2,sel_setActionName_,actionName);
      }
    }
  }
  if (!bVar1) {
    return;
  }
LAB_00074c50:
  _objc_msgSend(self,sel_setAttributeNamed_characterAttribute_value_actionName_,
                *(undefined4 *)PTR_003363d8,1,setOutlineValue,actionName);
  return;
}

*/
- (void)setOutlineValue:(id)aValue actionName:(id)aName
{
    if (_textView == nil) {
        return;
    }
    NSRange range = [_textView rangeForUserCharacterAttributeChange];
    BOOL applyToTypingAttributes = NO;
    if (range.length == 0 || [self selectedRange].length == 0) {
        id affected = [NSAttributedString hyperAttributeValuesAffectedByApplyingOutlineValue:aValue inDictionary:[self typingAttributes]];
        if (affected != nil && ![affected isEmpty]) {
            NSEnumerator *names = [affected attributeNamesEnumerator];
            id name;
            while ((name = [names nextObject]) != nil) {
                id current = [self typingAttributeNamed:name];
                id replacement = [affected replacementValueForAttributeName:name];
                if (![NSAttributedString isHyperAttribute:current equalToAttribute:replacement]) {
                    [self setTypingAttributeNamed:name value:replacement actionName:aName];
                }
            }
        }
        applyToTypingAttributes = YES;
    }
    if (range.length != 0) {
        id replacements = [[self textStorage] hyperReplacementsForAttributesInRange:range forApplyingOutlineValue:aValue];
        if (replacements != nil && ![replacements isEmpty] && [_textView shouldChangeTextInRange:range replacementString:nil]) {
            [[self textStorage] hyperApplyAttributeReplacements:replacements range:range];
            [_textView didChangeText];
            if (aName != nil) {
                [[self undoManager] setActionName:aName];
            }
        }
    }
    if (applyToTypingAttributes) {
        [self setAttributeNamed:NSStrokeWidthAttributeName characterAttribute:YES value:aValue actionName:aName];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00074de3 @ 00074de3, 902 bytes * /

void FUN_00074de3(HSCoreEditorText *self,SEL _cmd,id setForegroundColor,id actionName)

{
  bool bVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  int extraout_EDX;
  int extraout_EDX_00;
  int iVar10;
  undefined4 uVar11;
  id local_28;
  
  if (self->_textView == (id)0x0) {
    return;
  }
  local_28 = setForegroundColor;
  pvVar2 = _objc_msgSend(self->_textView,sel_rangeForUserCharacterAttributeChange);
  if ((extraout_EDX == 0) || (_objc_msgSend(self,sel_selectedRange), extraout_EDX_00 == 0)) {
    self_00 = cls_NSAttributedString;
    pvVar4 = _objc_msgSend(self,sel_typingAttributes);
    pvVar5 = setForegroundColor;
    pvVar3 = _objc_msgSend(self_00,
                           sel_hyperAttributeValuesAffectedByChangingForegroundColorTo_inDictionary_
                           ,setForegroundColor,pvVar4);
    if ((pvVar3 != (id)0x0) &&
       (pvVar6 = _objc_msgSend(pvVar3,sel_isEmpty,pvVar5,pvVar4), (char)pvVar6 == '\0')) {
      pvVar6 = _objc_msgSend(pvVar3,sel_attributeNamesEnumerator,pvVar5,pvVar4);
      pvVar5 = _objc_msgSend(pvVar6,sel_nextObject);
      while (pvVar5 != (id)0x0) {
        pvVar7 = _objc_msgSend(self,sel_typingAttributeNamed_,pvVar5,pvVar4);
        pvVar8 = _objc_msgSend(pvVar3,sel_replacementValueForAttributeName_,pvVar5);
        pvVar4 = pvVar8;
        pvVar9 = _objc_msgSend(cls_NSAttributedString,sel_isHyperAttribute_equalToAttribute_,pvVar7)
        ;
        if ((char)pvVar9 == '\0') {
          _objc_msgSend(self,sel_setTypingAttributeNamed_value_actionName_,pvVar5,pvVar8,actionName)
          ;
          pvVar7 = pvVar5;
          pvVar4 = pvVar8;
        }
        pvVar5 = _objc_msgSend(pvVar6,sel_nextObject,pvVar7,pvVar4);
      }
      goto LAB_00074e4c;
    }
    bVar1 = true;
  }
  else {
LAB_00074e4c:
    bVar1 = false;
  }
  if (extraout_EDX != 0) {
    pvVar3 = _objc_msgSend(self,sel_textStorage);
    pvVar4 = pvVar2;
    iVar10 = extraout_EDX;
    pvVar5 = setForegroundColor;
    pvVar3 = _objc_msgSend(pvVar3,
                           sel_hyperReplacementsForForegroundColorDependentAttributesInRange_forApplyingForegroundColor_
                           ,pvVar2,extraout_EDX,setForegroundColor);
    if ((pvVar3 == (id)0x0) ||
       (pvVar4 = _objc_msgSend(pvVar3,sel_isEmpty,pvVar4,iVar10,pvVar5), (char)pvVar4 != '\0'))
    goto LAB_00074f8d;
    uVar11 = 0;
    pvVar4 = pvVar2;
    iVar10 = extraout_EDX;
    pvVar5 = _objc_msgSend(self->_textView,sel_shouldChangeTextInRange_replacementString_,pvVar2,
                           extraout_EDX,0);
    if ((char)pvVar5 != '\0') {
      pvVar4 = _objc_msgSend(self,sel_textStorage,pvVar4,iVar10,uVar11);
      iVar10 = extraout_EDX;
      _objc_msgSend(pvVar4,sel_hyperApplyAttributeReplacements_range_,pvVar3,pvVar2,extraout_EDX);
      _objc_msgSend(self->_textView,sel_didChangeText);
      if (actionName != (id)0x0) {
        pvVar2 = _objc_msgSend(self,sel_undoManager,pvVar3,pvVar2,iVar10);
        _objc_msgSend(pvVar2,sel_setActionName_,actionName);
      }
    }
  }
  if (!bVar1) {
    return;
  }
LAB_00074f8d:
  pvVar2 = _objc_msgSend(setForegroundColor,sel_hyperGradientColor);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(setForegroundColor,sel_hyperGradientColor);
    local_28 = _objc_msgSend(pvVar2,sel_clonedTransparentColor);
  }
  _objc_msgSend(self,sel_setAttributeNamed_characterAttribute_value_actionName_,
                *(undefined4 *)PTR_00336394,1,local_28,actionName);
  return;
}

*/
- (void)setForegroundColor:(id)aColor actionName:(id)aName
{
    if (_textView == nil) {
        return;
    }
    NSRange range = [_textView rangeForUserCharacterAttributeChange];
    BOOL applyToTypingAttributes = NO;
    if (range.length == 0 || [self selectedRange].length == 0) {
        id affected = [NSAttributedString hyperAttributeValuesAffectedByChangingForegroundColorTo:aColor inDictionary:[self typingAttributes]];
        if (affected != nil && ![affected isEmpty]) {
            NSEnumerator *names = [affected attributeNamesEnumerator];
            id name;
            while ((name = [names nextObject]) != nil) {
                id current = [self typingAttributeNamed:name];
                id replacement = [affected replacementValueForAttributeName:name];
                if (![NSAttributedString isHyperAttribute:current equalToAttribute:replacement]) {
                    [self setTypingAttributeNamed:name value:replacement actionName:aName];
                }
            }
        }
        applyToTypingAttributes = YES;
    }
    if (range.length != 0) {
        id replacements = [[self textStorage] hyperReplacementsForForegroundColorDependentAttributesInRange:range forApplyingForegroundColor:aColor];
        if (replacements != nil && ![replacements isEmpty] && [_textView shouldChangeTextInRange:range replacementString:nil]) {
            [[self textStorage] hyperApplyAttributeReplacements:replacements range:range];
            [_textView didChangeText];
            if (aName != nil) {
                [[self undoManager] setActionName:aName];
            }
        }
    }
    if (applyToTypingAttributes) {
        id value = aColor;
        if ([aColor hyperGradientColor] != nil) {
            value = [[aColor hyperGradientColor] clonedTransparentColor];
        }
        [self setAttributeNamed:NSForegroundColorAttributeName characterAttribute:YES value:value actionName:aName];
    }
}

- (void)setActualAttributeNamed:(id)aNamed characterAttribute:(BOOL)aAttribute value:(id)aValue actionName:(id)aName
{
    [self setAttributeNamed:aNamed characterAttribute:aAttribute value:aValue actionName:aName shouldUseActualAttributeValue:YES];
}

- (void)setAttributeNamed:(id)aNamed characterAttribute:(BOOL)aAttribute value:(id)aValue actionName:(id)aName
{
    [self setAttributeNamed:aNamed characterAttribute:aAttribute value:aValue actionName:aName shouldUseActualAttributeValue:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000751ff @ 000751ff, 430 bytes * /

void FUN_000751ff(HSCoreEditorText *self,SEL _cmd,id setAttributeNamed,BOOL characterAttribute,
                 id value,id actionName,BOOL shouldUseActualAttributeValue)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  int extraout_EDX;
  int extraout_EDX_00;
  int iVar4;
  undefined4 uVar5;
  
  if (self->_textView != (id)0x0) {
    op = sel_rangeForUserParagraphAttributeChange;
    if (characterAttribute != '\0') {
      op = sel_rangeForUserCharacterAttributeChange;
    }
    pvVar1 = _objc_msgSend(self->_textView,op);
    if ((extraout_EDX == 0) || (_objc_msgSend(self,sel_selectedRange), extraout_EDX_00 == 0)) {
      pvVar2 = _objc_msgSend(self,sel_typingAttributeNamed_replaceWithDefaultValueIfNil_,
                             setAttributeNamed,(uint)(shouldUseActualAttributeValue == '\0'));
      pvVar2 = _objc_msgSend(cls_NSAttributedString,sel_isHyperAttribute_equalToAttribute_,pvVar2,
                             value);
      if ((char)pvVar2 == '\0') {
        _objc_msgSend(self,sel_setTypingAttributeNamed_value_actionName_,setAttributeNamed,value,
                      actionName);
      }
    }
    if (extraout_EDX != 0) {
      uVar5 = 0;
      pvVar2 = pvVar1;
      iVar4 = extraout_EDX;
      pvVar3 = _objc_msgSend(self->_textView,sel_shouldChangeTextInRange_replacementString_,pvVar1,
                             extraout_EDX,0);
      if ((char)pvVar3 != '\0') {
        pvVar2 = _objc_msgSend(self,sel_textStorage,pvVar2,iVar4,uVar5);
        iVar4 = extraout_EDX;
        _objc_msgSend(pvVar2,sel_hyperApplyAttribute_value_range_,setAttributeNamed,value,pvVar1,
                      extraout_EDX);
        _objc_msgSend(self->_textView,sel_didChangeText);
        if (actionName != (id)0x0) {
          pvVar1 = _objc_msgSend(self,sel_undoManager,setAttributeNamed,value,pvVar1,iVar4);
          _objc_msgSend(pvVar1,sel_setActionName_,actionName);
        }
      }
    }
  }
  return;
}

*/
- (void)setAttributeNamed:(id)aNamed characterAttribute:(BOOL)aAttribute value:(id)aValue actionName:(id)aName shouldUseActualAttributeValue:(BOOL)aValue2
{
    if (_textView == nil) {
        return;
    }
    NSRange range = aAttribute ? [_textView rangeForUserCharacterAttributeChange] : [_textView rangeForUserParagraphAttributeChange];
    if (range.length == 0 || [self selectedRange].length == 0) {
        id current = [self typingAttributeNamed:aNamed replaceWithDefaultValueIfNil:!aValue2];
        if (![NSAttributedString isHyperAttribute:current equalToAttribute:aValue]) {
            [self setTypingAttributeNamed:aNamed value:aValue actionName:aName];
        }
    }
    if (range.length != 0 && [_textView shouldChangeTextInRange:range replacementString:nil]) {
        [[self textStorage] hyperApplyAttribute:aNamed value:aValue range:range];
        [_textView didChangeText];
        if (aName != nil) {
            [[self undoManager] setActionName:aName];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000753ad @ 000753ad, 265 bytes * /

void FUN_000753ad(HSCoreEditorText *self,SEL _cmd,id setTypingAttributeNamed,id value,id actionName)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  SEL op;
  
  if (self->_textView != (id)0x0) {
    self_00 = _objc_msgSend(self,sel_typingAttributes);
    pvVar2 = setTypingAttributeNamed;
    pvVar1 = _objc_msgSend(self_00,sel_objectForKey_,setTypingAttributeNamed);
    if (pvVar1 != value) {
      pvVar2 = _objc_msgSend(self_00,sel_mutableCopy,pvVar2);
      op = sel_removeObjectForKey_;
      if (value != (id)0x0) {
        op = sel_setObject_forKey_;
        setTypingAttributeNamed = value;
      }
      _objc_msgSend(pvVar2,op,setTypingAttributeNamed);
      _objc_msgSend(self->_textView,sel_setTypingAttributes_,pvVar2);
      _objc_msgSend(pvVar2,sel_release);
      pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
      _objc_msgSend(pvVar2,sel_postNotificationName_object_,
                    &cfstr_HSCoreTextDidChangeAttributesNotification,self);
    }
  }
  return;
}

*/
- (void)setTypingAttributeNamed:(id)aNamed value:(id)aValue actionName:(id)aName
{
    if (_textView == nil) {
        return;
    }
    NSDictionary *attributes = [self typingAttributes];
    if ([attributes objectForKey:aNamed] != aValue) {
        NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
        if (aValue != nil) {
            [mutableAttributes setObject:aValue forKey:aNamed];
        } else {
            [mutableAttributes removeObjectForKey:aNamed];
        }
        [_textView setTypingAttributes:mutableAttributes];
        [mutableAttributes release];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCoreTextDidChangeAttributesNotification" object:self];
    }
}

- (id)typingAttributeNamed:(id)aNamed
{
    return [self typingAttributeNamed:aNamed replaceWithDefaultValueIfNil:YES];
}

- (id)typingAttributeNamed:(id)aNamed replaceWithDefaultValueIfNil:(BOOL)aNil
{
    id pvVar1;

    if (_textView == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [[self typingAttributes] objectForKey:aNamed];
        if ((pvVar1 == nil) && (aNil != NO)) {
            pvVar1 = [NSAttributedString hyperNullValueForAttribute:aNamed];
        }
    }
    return pvVar1;
}

- (id)typingAttributes
{
    id pvVar1;

    pvVar1 = [_textView typingAttributes];
    if (pvVar1 == nil) {
        pvVar1 = [NSAttributedString hyperNullAttributes];
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000755a6 @ 000755a6, 261 bytes * /

ulonglong FUN_000755a6(HSCoreEditorText *self,SEL _cmd,float hyperRequiredSizeForTextBlockOfHeight,
                      float maximumWidth)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isHyperEmpty);
  self_00 = cls_NSTextStorage;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    op = sel_hyperTextBlockSizeForTextStorage_ofHeight_maxWidth_;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
    pvVar2 = _objc_msgSend(self,sel_hyperTextAttributesDictionary);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithString_attributes_,&cfstr__,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    self_00 = cls_NSTextStorage;
    op = sel_hyperTextBlockSizeForAttributedString_ofHeight_maxWidth_;
  }
  pvVar1 = _objc_msgSend(self_00,op,pvVar1,hyperRequiredSizeForTextBlockOfHeight,maximumWidth);
  return CONCAT44(extraout_EDX,pvVar1);
}

*/
- (NSSize)hyperRequiredSizeForTextBlockOfHeight:(CGFloat)aHeight maximumWidth:(CGFloat)aWidth
{
    if ([self isHyperEmpty]) {
        NSAttributedString *placeholder = [[[NSAttributedString alloc] initWithString:@" " attributes:[self hyperTextAttributesDictionary]] autorelease];
        return [NSTextStorage hyperTextBlockSizeForAttributedString:placeholder ofHeight:aHeight maxWidth:aWidth];
    }
    return [NSTextStorage hyperTextBlockSizeForTextStorage:[self textStorage] ofHeight:aHeight maxWidth:aWidth];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000756ab @ 000756ab, 255 bytes * /

ulonglong FUN_000756ab(HSCoreEditorText *self,SEL _cmd,float hyperRequiredSizeToFitWidth,
                      BOOL fixedWidth)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined *self_00;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isHyperEmpty);
  self_00 = cls_NSTextStorage;
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    op = sel_hyperSizeForTextStorage_withWidth_fixedWidth_;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
    pvVar2 = _objc_msgSend(self,sel_hyperTextAttributesDictionary);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithString_attributes_,&cfstr__,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    self_00 = cls_NSTextStorage;
    op = sel_hyperSizeForAttributedString_withWidth_fixedWidth_;
  }
  pvVar1 = _objc_msgSend(self_00,op,pvVar1,hyperRequiredSizeToFitWidth,(int)fixedWidth);
  return CONCAT44(extraout_EDX,pvVar1);
}

*/
- (NSSize)hyperRequiredSizeToFitWidth:(CGFloat)aWidth fixedWidth:(BOOL)aWidth2
{
    if ([self isHyperEmpty]) {
        NSAttributedString *placeholder = [[[NSAttributedString alloc] initWithString:@" " attributes:[self hyperTextAttributesDictionary]] autorelease];
        return [NSTextStorage hyperSizeForAttributedString:placeholder withWidth:aWidth fixedWidth:aWidth2];
    }
    return [NSTextStorage hyperSizeForTextStorage:[self textStorage] withWidth:aWidth fixedWidth:aWidth2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000757aa @ 000757aa, 66 bytes * /

BOOL FUN_000757aa(HSCoreEditorText *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_textStorage);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  return pvVar1 == (id)0x0;
}

*/
- (BOOL)isHyperEmpty
{
    return [[self textStorage] length] == 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000757ec @ 000757ec, 453 bytes * /

void FUN_000757ec(HSCoreEditorText *self,SEL _cmd,id hyperReplaceTextWithString,id attributes,
                 id undoActionName)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(attributes,sel_hyperTextAttributesDictionary);
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_hyperNullAttributes);
  }
  pvVar2 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithString_attributes_,hyperReplaceTextWithString,pvVar1);
  self_00 = _objc_msgSend(pvVar2,sel_autorelease);
  pvVar3 = _objc_msgSend(hyperReplaceTextWithString,sel_length);
  pvVar2 = _objc_msgSend(self,sel_textStorage);
  pvVar4 = _objc_msgSend(pvVar2,sel_length);
  pvVar2 = self->_textView;
  pvVar5 = _objc_msgSend(self_00,sel_string);
  uVar7 = 0;
  pvVar6 = pvVar4;
  pvVar2 = _objc_msgSend(pvVar2,sel_shouldChangeTextInRange_replacementString_,0,pvVar4,pvVar5);
  if ((char)pvVar2 != '\0') {
    pvVar6 = _objc_msgSend(self,sel_textStorage,uVar7,pvVar6,pvVar5);
    pvVar2 = (id)0x0;
    _objc_msgSend(pvVar6,sel_replaceCharactersInRange_withAttributedString_,0,pvVar4,self_00);
    if (pvVar3 == (id)0x0) {
      _objc_msgSend(self->_textView,sel_setTypingAttributes_,pvVar1,pvVar4,self_00);
      pvVar2 = pvVar1;
    }
    _objc_msgSend(self->_textView,sel_didChangeText,pvVar2,pvVar4,self_00);
    if (undoActionName != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_undoManager,pvVar2,pvVar4,self_00);
      _objc_msgSend(pvVar1,sel_setActionName_,undoActionName);
    }
  }
  return;
}

*/
- (void)hyperReplaceTextWithString:(id)aString attributes:(id)aAttributes undoActionName:(id)aName
{
    id textAttributes = [aAttributes hyperTextAttributesDictionary];
    if (textAttributes == nil) {
        textAttributes = [NSAttributedString hyperNullAttributes];
    }
    NSAttributedString *replacement = [[[NSAttributedString alloc] initWithString:aString attributes:textAttributes] autorelease];
    NSUInteger stringLength = [aString length];
    NSUInteger storageLength = [[self textStorage] length];
    if ([_textView shouldChangeTextInRange:NSMakeRange(0, storageLength) replacementString:[replacement string]]) {
        [[self textStorage] replaceCharactersInRange:NSMakeRange(0, storageLength) withAttributedString:replacement];
        if (stringLength == 0) {
            [_textView setTypingAttributes:textAttributes];
        }
        [_textView didChangeText];
        if (aName != nil) {
            [[self undoManager] setActionName:aName];
        }
    }
}

- (void)hyperReplaceTextWithString:(id)aString inRange:(NSRange)aRange undoActionName:(id)aName
{
    if ([_textView shouldChangeTextInRange:aRange replacementString:aString]) {
        [[self textStorage] replaceCharactersInRange:aRange withString:aString];
        [_textView didChangeText];
        if (aName != nil) {
            [[self undoManager] setActionName:aName];
        }
    }
}

- (void)hyperReplaceTextWithString:(id)aString undoActionName:(id)aName
{
    [self hyperReplaceTextWithString:aString inRange:NSMakeRange(0, [[self textStorage] length]) undoActionName:aName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00075ae0 @ 00075ae0, 619 bytes * /

void FUN_00075ae0(HSCoreEditorText *self,SEL _cmd,id hyperReplaceText,id undoActionName)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  HSCoreEditorText *self_00;
  SEL op;
  id pvVar5;
  
  pvVar1 = _objc_msgSend(hyperReplaceText,sel_isHyperEmpty);
  if ((char)pvVar1 == '\0') {
    pvVar2 = _objc_msgSend(cls_NSAttributedString,sel_class);
    pvVar3 = _objc_msgSend(hyperReplaceText,sel_isKindOfClass_,pvVar2);
    pvVar1 = hyperReplaceText;
    if ((char)pvVar3 == '\0') {
      pvVar1 = _objc_msgSend(hyperReplaceText,sel_respondsToSelector_,sel_textStorage);
      if ((char)pvVar1 != '\0') {
        pvVar1 = _objc_msgSend(hyperReplaceText,sel_performSelector_,sel_textStorage);
        pvVar2 = _objc_msgSend(cls_NSAttributedString,sel_class);
        pvVar3 = _objc_msgSend(pvVar1,sel_isKindOfClass_,pvVar2);
        if ((char)pvVar3 != '\0') goto LAB_00075b48;
      }
      goto LAB_00075cbf;
    }
LAB_00075b48:
    if (pvVar1 == (id)0x0) goto LAB_00075cbf;
    pvVar3 = _objc_msgSend(self,sel_textStorage,pvVar2);
    hyperReplaceText = _objc_msgSend(pvVar3,sel_length);
    pvVar2 = self->_textView;
    pvVar4 = _objc_msgSend(pvVar1,sel_string);
    pvVar3 = (id)0x0;
    pvVar5 = hyperReplaceText;
    pvVar2 = _objc_msgSend(pvVar2,sel_shouldChangeTextInRange_replacementString_,0,hyperReplaceText,
                           pvVar4);
    if ((char)pvVar2 == '\0') goto LAB_00075cfb;
    pvVar2 = _objc_msgSend(self,sel_textStorage,pvVar3,pvVar5,pvVar4);
    pvVar3 = (id)0x0;
    _objc_msgSend(pvVar2,sel_replaceCharactersInRange_withAttributedString_,0,hyperReplaceText,
                  pvVar1);
    _objc_msgSend(self->_textView,sel_didChangeText);
    pvVar5 = hyperReplaceText;
    pvVar4 = pvVar1;
    if (undoActionName == (id)0x0) goto LAB_00075cfb;
    self_00 = _objc_msgSend(self,sel_undoManager,pvVar3,hyperReplaceText,pvVar1);
    op = sel_setActionName_;
    pvVar3 = undoActionName;
    undoActionName = pvVar1;
  }
  else {
LAB_00075cbf:
    pvVar3 = _objc_msgSend(hyperReplaceText,sel_hyperString);
    self_00 = self;
    op = sel_hyperReplaceTextWithString_attributes_undoActionName_;
  }
  _objc_msgSend(self_00,op,pvVar3,hyperReplaceText,undoActionName);
  pvVar5 = hyperReplaceText;
  pvVar4 = undoActionName;
LAB_00075cfb:
  pvVar1 = self->_textView;
  pvVar3 = _objc_msgSend(pvVar1,sel_textStorage,pvVar3,pvVar5,pvVar4);
  pvVar3 = _objc_msgSend(pvVar3,sel_length);
  _objc_msgSend(pvVar1,sel_setSelectedRange_,0,pvVar3);
  return;
}

*/
- (void)hyperReplaceText:(id)aText undoActionName:(id)aName
{
    id attributed = nil;
    if (![aText isHyperEmpty]) {
        attributed = aText;
        if (![aText isKindOfClass:[NSAttributedString class]]) {
            attributed = [aText respondsToSelector:@selector(textStorage)] ? [aText performSelector:@selector(textStorage)] : nil;
        }
    }
    if (attributed != nil) {
        NSUInteger storageLength = [[self textStorage] length];
        if ([_textView shouldChangeTextInRange:NSMakeRange(0, storageLength) replacementString:[attributed string]]) {
            [[self textStorage] replaceCharactersInRange:NSMakeRange(0, storageLength) withAttributedString:attributed];
            [_textView didChangeText];
            if (aName != nil) {
                [[self undoManager] setActionName:aName];
            }
        }
    } else {
        [self hyperReplaceTextWithString:[aText hyperString] attributes:aText undoActionName:aName];
    }
    [_textView setSelectedRange:NSMakeRange(0, [[_textView textStorage] length])];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00075d4b @ 00075d4b, 332 bytes * /

void FUN_00075d4b(HSCoreEditorText *self,SEL _cmd,id hyperReplaceTextWithAttributedString,
                 id undoActionName)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  
  if (hyperReplaceTextWithAttributedString != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(pvVar1,sel_length);
    pvVar1 = self->_textView;
    pvVar3 = _objc_msgSend(hyperReplaceTextWithAttributedString,sel_string);
    uVar5 = 0;
    pvVar4 = pvVar2;
    pvVar1 = _objc_msgSend(pvVar1,sel_shouldChangeTextInRange_replacementString_,0,pvVar2,pvVar3);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(self->_textView,sel_selectedRanges,uVar5,pvVar4,pvVar3);
      pvVar4 = _objc_msgSend(self,sel_textStorage);
      uVar5 = 0;
      _objc_msgSend(pvVar4,sel_replaceCharactersInRange_withAttributedString_,0,pvVar2,
                    hyperReplaceTextWithAttributedString);
      _objc_msgSend(self->_textView,sel_didChangeText);
      if (undoActionName != (id)0x0) {
        pvVar4 = _objc_msgSend(self,sel_undoManager,uVar5,pvVar2,
                               hyperReplaceTextWithAttributedString);
        _objc_msgSend(pvVar4,sel_setActionName_,undoActionName);
      }
      _objc_msgSend(self->_textView,sel_setSelectedRanges_,pvVar1,pvVar2,
                    hyperReplaceTextWithAttributedString);
    }
  }
  return;
}

*/
- (void)hyperReplaceTextWithAttributedString:(id)aString undoActionName:(id)aName
{
    if (aString == nil) {
        return;
    }
    NSUInteger storageLength = [[self textStorage] length];
    if ([_textView shouldChangeTextInRange:NSMakeRange(0, storageLength) replacementString:[aString string]]) {
        NSArray *ranges = [_textView selectedRanges];
        [[self textStorage] replaceCharactersInRange:NSMakeRange(0, storageLength) withAttributedString:aString];
        [_textView didChangeText];
        if (aName != nil) {
            [[self undoManager] setActionName:aName];
        }
        [_textView setSelectedRanges:ranges];
    }
}

- (void)setHasBackground:(BOOL)aBackground undoActionName:(id)aName
{

}

- (BOOL)hasBackground
{
    return NO;
}

- (void)setHyperTextBackgroundColor:(id)aColor undoActionName:(id)aName
{
    if ([_textView backgroundColor] != aColor) {
        [_textView setBackgroundColor:aColor];
        if (aName != nil) {
            [[self undoManager] setActionName:aName];
        }
    }
}

- (id)hyperTextBackgroundColor
{
    return [_textView backgroundColor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00075f40 @ 00075f40, 283 bytes * /

void FUN_00075f40(HSCoreEditorText *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar2 = self->_textView;
  pvVar1 = _objc_msgSend(*(id *)PTR_00336058,sel_currentEvent);
  pvVar1 = _objc_msgSend(pvVar1,sel_locationInWindow);
  pvVar2 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  pvVar1 = _objc_msgSend(self->_textView,sel_textContainer);
  self_00 = _objc_msgSend(self->_textView,sel_layoutManager);
  if ((self_00 != (id)0x0) && (pvVar1 != (id)0x0)) {
    pvVar2 = _objc_msgSend(self_00,sel_glyphIndexForPoint_inTextContainer_,pvVar2,extraout_EDX_00,
                           pvVar1);
    pvVar2 = _objc_msgSend(self_00,sel_characterRangeForGlyphRange_actualGlyphRange_,pvVar2,1,0);
    _objc_msgSend(self->_textView,sel_setSelectedRange_,pvVar2,0);
  }
  return;
}

*/
- (void)setHyperCursorPositionAccordingToCurrentEvent
{
    NSPoint point = [_textView convertPoint:[[NSApp currentEvent] locationInWindow] fromView:nil];
    NSTextContainer *container = [_textView textContainer];
    NSLayoutManager *layoutManager = [_textView layoutManager];
    if (layoutManager != nil && container != nil) {
        NSUInteger glyphIndex = [layoutManager glyphIndexForPoint:point inTextContainer:container];
        NSRange characterRange = [layoutManager characterRangeForGlyphRange:NSMakeRange(glyphIndex, 1) actualGlyphRange:NULL];
        [_textView setSelectedRange:NSMakeRange(characterRange.location, 0)];
    }
}

- (void)applyCharacterAttributesWithAttributesConverter:(id)aConverter undoActionName:(id)aName
{
    if (aName != nil) {
        [[self undoManager] setActionName:aName];
    }
    [_textView changeAttributes:aConverter];
}

- (void)applyFontWithFontConverter:(id)aConverter undoActionName:(id)aName
{
    if (aName != nil) {
        [[self undoManager] setActionName:aName];
    }
    [_textView changeFont:aConverter];
}

- (void)applyHyperTextAttributes:(id)aAttributes undoActionName:(id)aName
{
    id pvVar1;

    pvVar1 = [aAttributes hyperTextAttributesDictionary];
    if (pvVar1 == nil) {
        pvVar1 = [NSAttributedString hyperNullAttributes];
    }
    [self applyAttributeDictionary:pvVar1 actionName:aName];
}

- (void)setHyperSpaceBetweenCharacters:(CGFloat)aCharacters undoActionName:(id)aName
{
    [self setCharacterAttributeNamed:NSKernAttributeName value:[NSNumber numberWithFloat:aCharacters] actionName:aName];
}

- (void)setHyperSpaceBetweenLines:(CGFloat)aLines undoActionName:(id)aName
{
    [self convertParagraphAttribute:NSParagraphStyleAttributeName value:[NSNumber numberWithFloat:aLines] convertAttributeSelector:@selector(hyperConvertLineSpacingInParagraphStyle:toValue:) actionName:aName];
}

- (void)setHyperTextAlignment:(NSUInteger)aAlignment undoActionName:(id)aName
{
    [self convertParagraphAttribute:NSParagraphStyleAttributeName value:[NSNumber numberWithInt:aAlignment] convertAttributeSelector:@selector(hyperConvertAlignmentInParagraphStyle:toValue:) actionName:aName];
}

- (void)setHyperTextColor:(id)aColor undoActionName:(id)aName
{
    [self setForegroundColor:aColor actionName:aName];
}

- (void)setHyperShadowDistance:(CGFloat)aDistance undoActionName:(id)aName
{
    [self convertActualCharacterAttribute:NSShadowAttributeName value:[NSNumber numberWithFloat:aDistance] convertAttributeSelector:@selector(hyperConvertShadow:toHaveDistanceValue:) actionName:aName];
}

- (void)setHyperShadowBlurRadius:(CGFloat)aRadius undoActionName:(id)aName
{
    [self convertActualCharacterAttribute:NSShadowAttributeName value:[NSNumber numberWithFloat:aRadius] convertAttributeSelector:@selector(hyperConvertShadow:toHaveBlurRadiusValue:) actionName:aName];
}

- (void)setHyperShadowOffset:(NSSize)aOffset undoActionName:(id)aName
{
    [self convertActualCharacterAttribute:NSShadowAttributeName value:[NSValue valueWithSize:aOffset] convertAttributeSelector:@selector(hyperConvertShadow:toHaveOffsetValue:) actionName:aName];
}

- (void)setHyperShadowAngle:(CGFloat)aAngle undoActionName:(id)aName
{
    [self convertActualCharacterAttribute:NSShadowAttributeName value:[NSNumber numberWithFloat:aAngle] convertAttributeSelector:@selector(hyperConvertShadow:toHaveAngleValue:) actionName:aName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000764be @ 000764be, 155 bytes * /

void FUN_000764be(HSCoreEditorText *self,SEL _cmd,BOOL setHyperShadowEnabled,id undoActionName)

{
  id pvVar1;
  SEL op;
  undefined4 uVar2;
  undefined *puVar3;
  
  if (setHyperShadowEnabled == '\0') {
    uVar2 = *(undefined4 *)PTR_003363d0;
    puVar3 = (undefined *)0x0;
    pvVar1 = (id)0x1;
    op = sel_setActualAttributeNamed_characterAttribute_value_actionName_;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSShadow,sel_hyperShadowWithDefaultSettingsForTextObject);
    uVar2 = *(undefined4 *)PTR_003363d0;
    op = sel_convertActualCharacterAttribute_value_convertAttributeSelector_actionName_;
    puVar3 = sel_hyperConvertShadow_forEnablingShadowWithDefaultValue_;
  }
  _objc_msgSend(self,op,uVar2,pvVar1,puVar3,undoActionName);
  return;
}

*/
- (void)setHyperShadowEnabled:(BOOL)aEnabled undoActionName:(id)aName
{
    if (aEnabled) {
        [self convertActualCharacterAttribute:NSShadowAttributeName value:[NSShadow hyperShadowWithDefaultSettingsForTextObject] convertAttributeSelector:@selector(hyperConvertShadow:forEnablingShadowWithDefaultValue:) actionName:aName];
    } else {
        [self setActualAttributeNamed:NSShadowAttributeName characterAttribute:YES value:nil actionName:aName];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00076559 @ 00076559, 688 bytes * /

void FUN_00076559(HSCoreEditorText *self,SEL _cmd,BOOL finishOutlineMutating,id undoActionName)

{
  id pvVar1;
  id pvVar2;
  HSCoreEditorText *pHVar3;
  id pvVar4;
  id self_00;
  SEL op;
  undefined4 uVar5;
  
  pvVar1 = _objc_msgSend(self,sel_textStorage);
  if (finishOutlineMutating == '\0') {
    pvVar2 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(pvVar2,sel_length);
    _objc_msgSend(pvVar1,sel_hyperReplaceAttributeValues_withAttributeValues_inRange_,
                  *(undefined4 *)PTR_003363d8,*(undefined4 *)PTR_003363c8,0,pvVar2);
    pHVar3 = _objc_msgSend(self,sel_textStorage);
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(pvVar1,sel_length);
    pvVar1 = *(id *)PTR_003363d4;
    undoActionName = *(id *)PTR_003363c4;
    uVar5 = 0;
    self = pHVar3;
    op = sel_hyperReplaceAttributeValues_withAttributeValues_inRange_;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    pvVar2 = _objc_msgSend(pvVar1,sel_mutableCopy);
    pvVar4 = _objc_msgSend(pvVar2,sel_autorelease);
    pvVar2 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(pvVar2,sel_length);
    _objc_msgSend(pvVar4,sel_hyperReplaceAttributeValues_withAttributeValues_inRange_,
                  *(undefined4 *)PTR_003363d8,*(undefined4 *)PTR_003363c8,0,pvVar2);
    pvVar2 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(pvVar2,sel_length);
    uVar5 = 0;
    _objc_msgSend(pvVar4,sel_hyperReplaceAttributeValues_withAttributeValues_inRange_,
                  *(undefined4 *)PTR_003363d4,*(undefined4 *)PTR_003363c4,0,pvVar2);
    self_00 = _objc_msgSend(self,sel_undoManager);
    _objc_msgSend(self_00,sel_disableUndoRegistration);
    _objc_msgSend(self,sel_hyperReplaceTextWithAttributedString_undoActionName_,pvVar4,
                  undoActionName);
    pvVar4 = _objc_msgSend(self,sel_undoManager);
    _objc_msgSend(pvVar4,sel_enableUndoRegistration);
    op = sel_hyperReplaceTextWithAttributedString_undoActionName_;
  }
  _objc_msgSend(self,op,pvVar1,undoActionName,uVar5,pvVar2);
  return;
}

*/
- (void)finishOutlineMutating:(BOOL)aMutating undoActionName:(id)aName
{
    NSTextStorage *storage = [self textStorage];
    if (!aMutating) {
        [storage hyperReplaceAttributeValues:NSStrokeWidthAttributeName withAttributeValues:HSTemporaryStrokeWidthAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
        [[self textStorage] hyperReplaceAttributeValues:NSStrokeColorAttributeName withAttributeValues:HSTemporaryStrokeColorAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
    } else {
        NSMutableAttributedString *current = [[storage mutableCopy] autorelease];
        NSMutableAttributedString *previous = [[current mutableCopy] autorelease];
        [previous hyperReplaceAttributeValues:NSStrokeWidthAttributeName withAttributeValues:HSTemporaryStrokeWidthAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
        [previous hyperReplaceAttributeValues:NSStrokeColorAttributeName withAttributeValues:HSTemporaryStrokeColorAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
        [[self undoManager] disableUndoRegistration];
        [self hyperReplaceTextWithAttributedString:previous undoActionName:aName];
        [[self undoManager] enableUndoRegistration];
        [self hyperReplaceTextWithAttributedString:current undoActionName:aName];
    }
}

- (void)startOutlineMutating
{
    [[self textStorage] hyperReplaceAttributeValues:HSTemporaryStrokeWidthAttributeName withAttributeValues:NSStrokeWidthAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
    [[self textStorage] hyperReplaceAttributeValues:HSTemporaryStrokeColorAttributeName withAttributeValues:NSStrokeColorAttributeName inRange:NSMakeRange(0, [[self textStorage] length])];
}

- (void)setHyperOutlineColor:(id)aColor undoActionName:(id)aName
{
    [self setCharacterAttributeNamed:NSStrokeColorAttributeName value:aColor actionName:aName];
}

- (void)setHyperOutlineWidth:(CGFloat)aWidth undoActionName:(id)aName
{
    [self setOutlineValue:[NSNumber numberWithFloat:aWidth] actionName:aName];
}

- (void)setHyperOutlineEnabled:(BOOL)aEnabled undoActionName:(id)aName
{
    id pvVar1_2;

    if ([self isHyperOutlineEnabled] != aEnabled) {
        if (aEnabled == NO) {
            pvVar1_2 = nil;
        }
        else {
            pvVar1_2 = [NSAttributedString hyperDefaultOutlineValueForEnablingOutline];
        }
        [self setOutlineValue:pvVar1_2 actionName:aName];
    }
}

- (void)setHyperUnderlined:(BOOL)aUnderlined undoActionName:(id)aName
{
    NSNumber *pvVar1;

    if (aUnderlined == NO) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [[NSNumber alloc] initWithInt:1];
    }
    [self setCharacterAttributeNamed:NSUnderlineStyleAttributeName value:pvVar1 actionName:aName];
}

- (void)setHyperItalic:(BOOL)aItalic undoActionName:(id)aName
{
    int uVar1;

    uVar1 = 1;
    if (aItalic == NO) {
        uVar1 = 0x1000000;
    }
    [self applyFontTrait:uVar1 actionName:aName];
}

- (void)setHyperCondensed:(BOOL)aCondensed undoActionName:(id)aName
{
    int uVar1;

    uVar1 = 0x40;
    if (aCondensed == NO) {
        uVar1 = 0x20;
    }
    [self applyFontTrait:uVar1 actionName:aName];
}

- (void)setHyperExpanded:(BOOL)aExpanded undoActionName:(id)aName
{
    int uVar1;

    uVar1 = 0x20;
    if (aExpanded == NO) {
        uVar1 = 0x40;
    }
    [self applyFontTrait:uVar1 actionName:aName];
}

- (void)setHyperBold:(BOOL)aBold undoActionName:(id)aName
{
    [self applyFontTrait:(unsigned int)(aBold == NO) * 2 + 2 actionName:aName];
}

- (void)setHyperFontSize:(CGFloat)aSize undoActionName:(id)aName
{
    [self convertCharacterAttribute:NSFontAttributeName value:[NSNumber numberWithFloat:aSize] convertAttributeSelector:@selector(hyperConvertFont:toSizeValue:) actionName:aName]
    ;
}

- (void)setHyperFontFamilyWithFont:(id)aFont undoActionName:(id)aName
{
    [self convertCharacterAttribute:NSFontAttributeName value:aFont convertAttributeSelector:@selector(hyperConvertFont:toFamilyInFont:) actionName:aName];
}

- (void)setHyperFontFamily:(id)aFamily undoActionName:(id)aName
{
    [self convertCharacterAttribute:NSFontAttributeName value:aFamily convertAttributeSelector:@selector(hyperConvertFont:toFamily:) actionName:aName];
}

- (void)setHyperFont:(id)aFont undoActionName:(id)aName
{
    [self setCharacterAttributeNamed:NSFontAttributeName value:aFont actionName:aName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00076ce0 @ 00076ce0, 166 bytes * /

void FUN_00076ce0(HSCoreEditorText *self,SEL _cmd,id *getHyperTextAttributes,BOOL *multipleValues)

{
  id pvVar1;
  id self_00;
  int extraout_EDX;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_selectedRange);
  local_14 = (id)0x0;
  if (extraout_EDX == 0) {
    local_14 = _objc_msgSend(self,sel_typingAttributes);
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    self_00 = _objc_msgSend(self,sel_textStorage);
    _objc_msgSend(self_00,sel_getHyperAttributesDictionary_inRange_multipleValues_,&local_14,pvVar1,
                  extraout_EDX,multipleValues);
  }
  *getHyperTextAttributes = local_14;
  return;
}

*/
- (void)getHyperTextAttributes:(id *)aAttributes multipleValues:(BOOL *)aValues
{
    NSRange range = [self selectedRange];
    id attributes = nil;
    if (range.length == 0) {
        attributes = [self typingAttributes];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperAttributesDictionary:&attributes inRange:range multipleValues:aValues];
    }
    *aAttributes = attributes;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00076d86 @ 00076d86, 187 bytes * /

void FUN_00076d86(HSCoreEditorText *self,SEL _cmd,float *getHyperSpaceBetweenCharacters,
                 BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  double dVar3;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_hyperSpaceBetweenCharacters);
    *getHyperSpaceBetweenCharacters = (float)dVar3;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperSpaceBetweenCharacters_inRange_multipleValues_,
                  getHyperSpaceBetweenCharacters,pvVar2,extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperSpaceBetweenCharacters:(float *)aCharacters multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aCharacters = [[self typingAttributes] hyperSpaceBetweenCharacters];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperSpaceBetweenCharacters:aCharacters inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00076e41 @ 00076e41, 187 bytes * /

void FUN_00076e41(HSCoreEditorText *self,SEL _cmd,float *getHyperSpaceBetweenLines,
                 BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  double dVar3;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_hyperSpaceBetweenLines);
    *getHyperSpaceBetweenLines = (float)dVar3;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperSpaceBetweenLines_inRange_multipleValues_,
                  getHyperSpaceBetweenLines,pvVar2,extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperSpaceBetweenLines:(float *)aLines multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aLines = [[self typingAttributes] hyperSpaceBetweenLines];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperSpaceBetweenLines:aLines inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00076efc @ 00076efc, 187 bytes * /

void FUN_00076efc(HSCoreEditorText *self,SEL _cmd,uint *getHyperTextAlignment,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperTextAlignment);
    *getHyperTextAlignment = (uint)pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperTextAlignment_inRange_multipleValues_,getHyperTextAlignment,
                  pvVar2,extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperTextAlignment:(unsigned int *)aAlignment multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aAlignment = [[self typingAttributes] hyperTextAlignment];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperTextAlignment:aAlignment inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00076fb7 @ 00076fb7, 187 bytes * /

void FUN_00076fb7(HSCoreEditorText *self,SEL _cmd,id *getHyperTextColor,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperTextColor);
    *getHyperTextColor = pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperTextColor_inRange_multipleValues_,getHyperTextColor,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperTextColor:(id *)aColor multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aColor = [[self typingAttributes] hyperTextColor];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperTextColor:aColor inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077072 @ 00077072, 187 bytes * /

void FUN_00077072(HSCoreEditorText *self,SEL _cmd,float *getHyperShadowDistance,BOOL *multipleValues
                 )

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  double dVar3;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_hyperShadowDistance);
    *getHyperShadowDistance = (float)dVar3;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperShadowDistance_inRange_multipleValues_,getHyperShadowDistance,
                  pvVar2,extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperShadowDistance:(float *)aDistance multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aDistance = [[self typingAttributes] hyperShadowDistance];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperShadowDistance:aDistance inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007712d @ 0007712d, 187 bytes * /

void FUN_0007712d(HSCoreEditorText *self,SEL _cmd,float *getHyperShadowBlurRadius,
                 BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  double dVar3;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_hyperShadowBlurRadius);
    *getHyperShadowBlurRadius = (float)dVar3;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperShadowBlurRadius_inRange_multipleValues_,
                  getHyperShadowBlurRadius,pvVar2,extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperShadowBlurRadius:(float *)aRadius multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aRadius = [[self typingAttributes] hyperShadowBlurRadius];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperShadowBlurRadius:aRadius inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000771e8 @ 000771e8, 187 bytes * /

void FUN_000771e8(HSCoreEditorText *self,SEL _cmd,float *getHyperShadowAngle,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  double dVar3;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_hyperShadowAngle);
    *getHyperShadowAngle = (float)dVar3;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperShadowAngle_inRange_multipleValues_,getHyperShadowAngle,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperShadowAngle:(float *)aAngle multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aAngle = [[self typingAttributes] hyperShadowAngle];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperShadowAngle:aAngle inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000772a3 @ 000772a3, 190 bytes * /

void FUN_000772a3(HSCoreEditorText *self,SEL _cmd,NSSize *getHyperShadowOffset,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  float extraout_EDX_00;
  undefined4 extraout_EDX_01;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperShadowOffset);
    getHyperShadowOffset->width = (float)pvVar1;
    getHyperShadowOffset->height = extraout_EDX_00;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperShadowOffset_inRange_multipleValues_,getHyperShadowOffset,
                  pvVar2,extraout_EDX_01,multipleValues);
  }
  return;
}

*/
- (void)getHyperShadowOffset:(NSSize *)aOffset multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aOffset = [[self typingAttributes] hyperShadowOffset];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperShadowOffset:aOffset inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077361 @ 00077361, 187 bytes * /

void FUN_00077361(HSCoreEditorText *self,SEL _cmd,BOOL *getHyperShadowEnabled,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_isHyperShadowEnabled);
    *getHyperShadowEnabled = (BOOL)pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperShadowEnabled_inRange_multipleValues_,getHyperShadowEnabled,
                  pvVar2,extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperShadowEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aEnabled = [[self typingAttributes] isHyperShadowEnabled];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperShadowEnabled:aEnabled inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007741c @ 0007741c, 181 bytes * /

void FUN_0007741c(HSCoreEditorText *self,SEL _cmd,id *getHyperShadow,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributeNamed_,*(undefined4 *)PTR_003363d0);
    *getHyperShadow = pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperShadow_inRange_multipleValues_,getHyperShadow,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperShadow:(id *)aShadow multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aShadow = [self typingAttributeNamed:NSShadowAttributeName];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperShadow:aShadow inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000774d1 @ 000774d1, 187 bytes * /

void FUN_000774d1(HSCoreEditorText *self,SEL _cmd,float *getHyperOutlineWidth,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  double dVar3;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_hyperOutlineWidth);
    *getHyperOutlineWidth = (float)dVar3;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperOutlineWidth_inRange_multipleValues_,getHyperOutlineWidth,
                  pvVar2,extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperOutlineWidth:(float *)aWidth multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aWidth = [[self typingAttributes] hyperOutlineWidth];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperOutlineWidth:aWidth inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007758c @ 0007758c, 187 bytes * /

void FUN_0007758c(HSCoreEditorText *self,SEL _cmd,id *getHyperOutlineColor,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperOutlineColor);
    *getHyperOutlineColor = pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperOutlineColor_inRange_multipleValues_,getHyperOutlineColor,
                  pvVar2,extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperOutlineColor:(id *)aColor multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aColor = [[self typingAttributes] hyperOutlineColor];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperOutlineColor:aColor inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077647 @ 00077647, 187 bytes * /

void FUN_00077647(HSCoreEditorText *self,SEL _cmd,BOOL *getHyperOutlineEnabled,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_isHyperOutlineEnabled);
    *getHyperOutlineEnabled = (BOOL)pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperOutlineEnabled_inRange_multipleValues_,getHyperOutlineEnabled,
                  pvVar2,extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperOutlineEnabled:(BOOL *)aEnabled multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aEnabled = [[self typingAttributes] isHyperOutlineEnabled];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperOutlineEnabled:aEnabled inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077702 @ 00077702, 187 bytes * /

void FUN_00077702(HSCoreEditorText *self,SEL _cmd,BOOL *getHyperExpanded,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_isHyperExpanded);
    *getHyperExpanded = (BOOL)pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperExpanded_inRange_multipleValues_,getHyperExpanded,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperExpanded:(BOOL *)aExpanded multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aExpanded = [[self typingAttributes] isHyperExpanded];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperExpanded:aExpanded inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000777bd @ 000777bd, 187 bytes * /

void FUN_000777bd(HSCoreEditorText *self,SEL _cmd,BOOL *getHyperCondensed,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_isHyperCondensed);
    *getHyperCondensed = (BOOL)pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperCondensed_inRange_multipleValues_,getHyperCondensed,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperCondensed:(BOOL *)aCondensed multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aCondensed = [[self typingAttributes] isHyperCondensed];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperCondensed:aCondensed inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077878 @ 00077878, 187 bytes * /

void FUN_00077878(HSCoreEditorText *self,SEL _cmd,BOOL *getHyperUnderlined,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_isHyperUnderlined);
    *getHyperUnderlined = (BOOL)pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperUnderlined_inRange_multipleValues_,getHyperUnderlined,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperUnderlined:(BOOL *)aUnderlined multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aUnderlined = [[self typingAttributes] isHyperUnderlined];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperUnderlined:aUnderlined inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077933 @ 00077933, 187 bytes * /

void FUN_00077933(HSCoreEditorText *self,SEL _cmd,BOOL *getHyperItalic,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_isHyperItalic);
    *getHyperItalic = (BOOL)pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperItalic_inRange_multipleValues_,getHyperItalic,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperItalic:(BOOL *)aItalic multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aItalic = [[self typingAttributes] isHyperItalic];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperItalic:aItalic inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000779ee @ 000779ee, 187 bytes * /

void FUN_000779ee(HSCoreEditorText *self,SEL _cmd,BOOL *getHyperBold,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_isHyperBold);
    *getHyperBold = (BOOL)pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperBold_inRange_multipleValues_,getHyperBold,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperBold:(BOOL *)aBold multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aBold = [[self typingAttributes] isHyperBold];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperBold:aBold inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077aa9 @ 00077aa9, 187 bytes * /

void FUN_00077aa9(HSCoreEditorText *self,SEL _cmd,float *getHyperFontSize,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  double dVar3;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    dVar3 = _objc_msgSend_fpret(pvVar1,sel_hyperFontSize);
    *getHyperFontSize = (float)dVar3;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperFontSize_inRange_multipleValues_,getHyperFontSize,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperFontSize:(float *)aSize multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aSize = [[self typingAttributes] hyperFontSize];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperFontSize:aSize inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077b64 @ 00077b64, 187 bytes * /

void FUN_00077b64(HSCoreEditorText *self,SEL _cmd,id *getHyperFontFamily,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperFontFamily);
    *getHyperFontFamily = pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperFontFamily_inRange_multipleValues_,getHyperFontFamily,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperFontFamily:(id *)aFamily multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aFamily = [[self typingAttributes] hyperFontFamily];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperFontFamily:aFamily inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077c1f @ 00077c1f, 187 bytes * /

void FUN_00077c1f(HSCoreEditorText *self,SEL _cmd,id *getHyperFont,BOOL *multipleValues)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  undefined4 extraout_EDX_00;
  
  _objc_msgSend(self,sel_selectedRange);
  if ((extraout_EDX == 0) && (self->_textView != (id)0x0)) {
    pvVar1 = _objc_msgSend(self,sel_typingAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperFont);
    *getHyperFont = pvVar1;
    if (multipleValues != (BOOL *)0x0) {
      *multipleValues = '\0';
    }
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(self,sel_selectedRange);
    _objc_msgSend(pvVar1,sel_getHyperFont_inRange_multipleValues_,getHyperFont,pvVar2,
                  extraout_EDX_00,multipleValues);
  }
  return;
}

*/
- (void)getHyperFont:(id *)aFont multipleValues:(BOOL *)aValues
{
    if ([self selectedRange].length == 0 && _textView != nil) {
        *aFont = [[self typingAttributes] hyperFont];
        if (aValues != NULL) {
            *aValues = NO;
        }
    } else {
        [[self textStorage] getHyperFont:aFont inRange:[self selectedRange] multipleValues:aValues];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077cda @ 00077cda, 261 bytes * /

id FUN_00077cda(HSCoreEditorText *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  int extraout_EDX;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_selectedRange);
  if (extraout_EDX == 0) {
    pvVar2 = _objc_msgSend(self,sel_typingAttributes);
  }
  else {
    pvVar2 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc);
    self_00 = _objc_msgSend(pvVar2,sel_init);
    pvVar2 = _objc_msgSend(self,sel_textStorage);
    uVar4 = 0;
    pvVar3 = _objc_msgSend(pvVar2,sel_attributesAtIndex_effectiveRange_,pvVar1,0);
    pvVar2 = (id)0x0;
    if (pvVar3 != (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSDictionary,sel_alloc,pvVar1,uVar4);
      pvVar2 = _objc_msgSend(pvVar1,sel_initWithDictionary_,pvVar3);
      pvVar1 = pvVar3;
    }
    _objc_msgSend(self_00,sel_release,pvVar1,uVar4);
    _objc_msgSend(pvVar2,sel_autorelease);
  }
  return pvVar2;
}

*/
- (id)hyperTextAttributesDictionary
{
    NSRange range = [self selectedRange];
    if (range.length == 0) {
        return [self typingAttributes];
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *attributes = [[self textStorage] attributesAtIndex:range.location effectiveRange:NULL];
    NSDictionary *copy = nil;
    if (attributes != nil) {
        copy = [[NSDictionary alloc] initWithDictionary:attributes];
    }
    [pool release];
    return [copy autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077ddf @ 00077ddf, 63 bytes * /

float FUN_00077ddf(HSCoreEditorText *self,SEL _cmd)

{
  float local_8;
  
  local_8 = 0.0;
  _objc_msgSend(self,sel_getHyperSpaceBetweenCharacters_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (CGFloat)hyperSpaceBetweenCharacters
{
    float value = 0.0;
    [self getHyperSpaceBetweenCharacters:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077e1e @ 00077e1e, 63 bytes * /

float FUN_00077e1e(HSCoreEditorText *self,SEL _cmd)

{
  float local_8;
  
  local_8 = 0.0;
  _objc_msgSend(self,sel_getHyperSpaceBetweenLines_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (CGFloat)hyperSpaceBetweenLines
{
    float value = 0.0;
    [self getHyperSpaceBetweenLines:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077e5d @ 00077e5d, 63 bytes * /

uint FUN_00077e5d(HSCoreEditorText *self,SEL _cmd)

{
  uint local_8;
  
  local_8 = 0;
  _objc_msgSend(self,sel_getHyperTextAlignment_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (NSUInteger)hyperTextAlignment
{
    unsigned int value = 0;
    [self getHyperTextAlignment:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077e9c @ 00077e9c, 63 bytes * /

id FUN_00077e9c(HSCoreEditorText *self,SEL _cmd)

{
  id local_8;
  
  local_8 = (id)0x0;
  _objc_msgSend(self,sel_getHyperTextColor_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (id)hyperTextColor
{
    id value = nil;
    [self getHyperTextColor:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077edb @ 00077edb, 63 bytes * /

float FUN_00077edb(HSCoreEditorText *self,SEL _cmd)

{
  float local_8;
  
  local_8 = 0.0;
  _objc_msgSend(self,sel_getHyperShadowBlurRadius_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (CGFloat)hyperShadowBlurRadius
{
    float value = 0.0;
    [self getHyperShadowBlurRadius:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077f1a @ 00077f1a, 84 bytes * /

ulonglong FUN_00077f1a(HSCoreEditorText *self,SEL _cmd)

{
  undefined4 local_c;
  undefined4 local_8;
  
  local_c = *(undefined4 *)PTR_0033607c;
  local_8 = *(undefined4 *)(PTR_0033607c + 4);
  _objc_msgSend(self,sel_getHyperShadowOffset_multipleValues_,&local_c,0);
  return CONCAT44(local_8,local_c);
}

*/
- (NSSize)hyperShadowOffset
{
    NSSize value = NSZeroSize;
    [self getHyperShadowOffset:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077f6e @ 00077f6e, 63 bytes * /

float FUN_00077f6e(HSCoreEditorText *self,SEL _cmd)

{
  float local_8;
  
  local_8 = 0.0;
  _objc_msgSend(self,sel_getHyperShadowDistance_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (CGFloat)hyperShadowDistance
{
    float value = 0.0;
    [self getHyperShadowDistance:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077fad @ 00077fad, 63 bytes * /

float FUN_00077fad(HSCoreEditorText *self,SEL _cmd)

{
  float local_8;
  
  local_8 = 0.0;
  _objc_msgSend(self,sel_getHyperShadowAngle_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (CGFloat)hyperShadowAngle
{
    float value = 0.0;
    [self getHyperShadowAngle:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00077fec @ 00077fec, 61 bytes * /

BOOL FUN_00077fec(HSCoreEditorText *self,SEL _cmd)

{
  BOOL local_5;
  
  local_5 = '\0';
  _objc_msgSend(self,sel_getHyperShadowEnabled_multipleValues_,&local_5,0);
  return local_5;
}

*/
- (BOOL)isHyperShadowEnabled
{
    BOOL value = NO;
    [self getHyperShadowEnabled:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078029 @ 00078029, 63 bytes * /

id FUN_00078029(HSCoreEditorText *self,SEL _cmd)

{
  id local_8;
  
  local_8 = (id)0x0;
  _objc_msgSend(self,sel_getHyperOutlineColor_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (id)hyperOutlineColor
{
    id value = nil;
    [self getHyperOutlineColor:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078068 @ 00078068, 63 bytes * /

float FUN_00078068(HSCoreEditorText *self,SEL _cmd)

{
  float local_8;
  
  local_8 = 0.0;
  _objc_msgSend(self,sel_getHyperOutlineWidth_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (CGFloat)hyperOutlineWidth
{
    float value = 0.0;
    [self getHyperOutlineWidth:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000780a7 @ 000780a7, 61 bytes * /

BOOL FUN_000780a7(HSCoreEditorText *self,SEL _cmd)

{
  BOOL local_5;
  
  local_5 = '\0';
  _objc_msgSend(self,sel_getHyperOutlineEnabled_multipleValues_,&local_5,0);
  return local_5;
}

*/
- (BOOL)isHyperOutlineEnabled
{
    BOOL value = NO;
    [self getHyperOutlineEnabled:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000780e4 @ 000780e4, 61 bytes * /

BOOL FUN_000780e4(HSCoreEditorText *self,SEL _cmd)

{
  BOOL local_5;
  
  local_5 = '\0';
  _objc_msgSend(self,sel_getHyperExpanded_multipleValues_,&local_5,0);
  return local_5;
}

*/
- (BOOL)isHyperExpanded
{
    BOOL value = NO;
    [self getHyperExpanded:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078121 @ 00078121, 61 bytes * /

BOOL FUN_00078121(HSCoreEditorText *self,SEL _cmd)

{
  BOOL local_5;
  
  local_5 = '\0';
  _objc_msgSend(self,sel_getHyperCondensed_multipleValues_,&local_5,0);
  return local_5;
}

*/
- (BOOL)isHyperCondensed
{
    BOOL value = NO;
    [self getHyperCondensed:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007815e @ 0007815e, 61 bytes * /

BOOL FUN_0007815e(HSCoreEditorText *self,SEL _cmd)

{
  BOOL local_5;
  
  local_5 = '\0';
  _objc_msgSend(self,sel_getHyperUnderlined_multipleValues_,&local_5,0);
  return local_5;
}

*/
- (BOOL)isHyperUnderlined
{
    BOOL value = NO;
    [self getHyperUnderlined:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007819b @ 0007819b, 61 bytes * /

BOOL FUN_0007819b(HSCoreEditorText *self,SEL _cmd)

{
  BOOL local_5;
  
  local_5 = '\0';
  _objc_msgSend(self,sel_getHyperItalic_multipleValues_,&local_5,0);
  return local_5;
}

*/
- (BOOL)isHyperItalic
{
    BOOL value = NO;
    [self getHyperItalic:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000781d8 @ 000781d8, 61 bytes * /

BOOL FUN_000781d8(HSCoreEditorText *self,SEL _cmd)

{
  BOOL local_5;
  
  local_5 = '\0';
  _objc_msgSend(self,sel_getHyperBold_multipleValues_,&local_5,0);
  return local_5;
}

*/
- (BOOL)isHyperBold
{
    BOOL value = NO;
    [self getHyperBold:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078215 @ 00078215, 63 bytes * /

float FUN_00078215(HSCoreEditorText *self,SEL _cmd)

{
  float local_8;
  
  local_8 = 0.0;
  _objc_msgSend(self,sel_getHyperFontSize_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (CGFloat)hyperFontSize
{
    float value = 0.0;
    [self getHyperFontSize:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078254 @ 00078254, 63 bytes * /

id FUN_00078254(HSCoreEditorText *self,SEL _cmd)

{
  id local_8;
  
  local_8 = (id)0x0;
  _objc_msgSend(self,sel_getHyperFontFamily_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (id)hyperFontFamily
{
    id value = nil;
    [self getHyperFontFamily:&value multipleValues:NULL];
    return value;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078293 @ 00078293, 63 bytes * /

id FUN_00078293(HSCoreEditorText *self,SEL _cmd)

{
  id local_8;
  
  local_8 = (id)0x0;
  _objc_msgSend(self,sel_getHyperFont_multipleValues_,&local_8,0);
  return local_8;
}

*/
- (id)hyperFont
{
    id value = nil;
    [self getHyperFont:&value multipleValues:NULL];
    return value;
}

- (id)hyperText
{
    return [self textStorage];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000782f8 @ 000782f8, 108 bytes * /

id FUN_000782f8(HSCoreEditorText *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_textStorage);
  pvVar1 = _objc_msgSend(pvVar1,sel_string);
  pvVar2 = _objc_msgSend(self,sel_selectedRange);
  pvVar1 = _objc_msgSend(pvVar1,sel_substringWithRange_,pvVar2,extraout_EDX);
  return pvVar1;
}

*/
- (id)hyperString
{
    return [[[self textStorage] string] substringWithRange:[self selectedRange]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00078364 @ 00078364, 65 bytes * /

ulonglong FUN_00078364(HSCoreEditorText *self,SEL _cmd)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 extraout_EDX;
  
  if (self->_textView == (id)0x0) {
    pvVar1 = (id)0x0;
    uVar2 = 0;
  }
  else {
    pvVar1 = _objc_msgSend(self->_textView,sel_selectedRange);
    uVar2 = extraout_EDX;
  }
  return CONCAT44(uVar2,pvVar1);
}

*/
- (NSRange)selectedRange
{
    if (_textView == nil) {
        return NSMakeRange(0, 0);
    }
    return [_textView selectedRange];
}

- (void)textViewDidChangeText:(id)aText
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCoreTextDidChangeTextNotification" object:self];
}

- (void)textViewDidChangeSelection:(id)aSelection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSCoreTextDidChangeTextNotification" object:self];
}

- (id)textStorage
{
    return [_textView textStorage];
}

- (id)undoManager
{
    return [_textView undoManager];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_textView release];
    [super dealloc];
}

- (id)initWithTextView:(id)aView
{
    self = [super init];
    if (self != nil) {
        _textView = [aView retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:_textView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeText:) name:NSTextDidChangeNotification object:_textView];
    }
    return self;
}

@end

