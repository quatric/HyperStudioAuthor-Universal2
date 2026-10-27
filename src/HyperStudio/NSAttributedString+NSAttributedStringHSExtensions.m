#import "NSAttributedString+NSAttributedStringHSExtensions.h"

@implementation NSAttributedString (NSAttributedStringHSExtensions)

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028a76e @ 0028a76e, 501 bytes * /

id FUN_0028a76e(id self,SEL _cmd,id hyperLoadFromXMLRepresentation,id inContext)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  id pvVar4;
  cfstringStruct *self_00;
  cfstringStruct *pcVar5;
  id local_14;
  
  pcVar3 = &cfstr_substringAttributes;
  pvVar1 = _objc_msgSend(hyperLoadFromXMLRepresentation,sel_elementsForName_,
                         &cfstr_substringAttributes);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar2 == (id)0x0) {
    local_14 = (id)0x0;
  }
  else {
    local_14 = (id)0x0;
    pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator,pcVar3);
    while( true ) {
      self_00 = _objc_msgSend(pvVar1,sel_nextObject,pcVar3);
      if (self_00 == (cfstringStruct *)0x0) break;
      pcVar5 = &cfstr_substring;
      pvVar2 = _objc_msgSend(self_00,sel_elementsForName_,&cfstr_substring);
      pvVar2 = _objc_msgSend(pvVar2,sel_extraFirstObject);
      pcVar3 = _objc_msgSend(pvVar2,sel_stringValue);
      pvVar2 = _objc_msgSend(self_00,sel_childCount);
      if (pvVar2 == (id)0x0) {
        pvVar2 = (id)0x0;
        self_00 = pcVar5;
      }
      else {
        pvVar2 = _objc_msgSend(cls_NSAttributedString,
                               sel_hyperTextAttributesFromXMLRepresentation_inContext_,self_00,
                               inContext);
      }
      if (local_14 == (id)0x0) {
        pvVar4 = _objc_msgSend(cls_NSMutableAttributedString,sel_alloc,self_00);
        pvVar2 = _objc_msgSend(pvVar4,sel_initWithString_attributes_,pcVar3,pvVar2);
        local_14 = _objc_msgSend(pvVar2,sel_autorelease);
      }
      else {
        pvVar4 = _objc_msgSend(cls_NSAttributedString,sel_alloc,self_00);
        pvVar2 = _objc_msgSend(pvVar4,sel_initWithString_attributes_,pcVar3,pvVar2);
        pcVar3 = _objc_msgSend(pvVar2,sel_autorelease);
        _objc_msgSend(local_14,sel_appendAttributedString_,pcVar3);
      }
    }
  }
  pvVar1 = _objc_msgSend(local_14,sel_copy,pcVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  return pvVar1;
}

*/
+ (id)hyperLoadFromXMLRepresentation:(id)aRepresentation inContext:(id)aContext
{
    NSArray *elements = [aRepresentation elementsForName:@"substringAttributes"];
    NSMutableAttributedString *result = nil;
    if ([elements count] != 0) {
        NSEnumerator *enumerator = [elements objectEnumerator];
        id element;
        while ((element = [enumerator nextObject]) != nil) {
            NSString *string = [[[element elementsForName:@"substring"] extraFirstObject] stringValue];
            NSDictionary *attributes = nil;
            if ([element childCount] != 0) {
                attributes = [NSAttributedString hyperTextAttributesFromXMLRepresentation:element inContext:aContext];
            }
            if (result == nil) {
                result = [[[NSMutableAttributedString alloc] initWithString:string attributes:attributes] autorelease];
            } else {
                [result appendAttributedString:[[[NSAttributedString alloc] initWithString:string attributes:attributes] autorelease]];
            }
        }
    }
    return [[result copy] autorelease];
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028c3fb @ 0028c3fb, 5580 bytes * /

id FUN_0028c3fb(id self,SEL _cmd,id hyperTextAttributesFromXMLRepresentation,id inContext)

{
  undefined *puVar1;
  undefined *puVar2;
  undefined *puVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  undefined *puVar8;
  undefined *puVar9;
  undefined *puVar10;
  undefined *puVar11;
  undefined *puVar12;
  undefined *puVar13;
  undefined *puVar14;
  undefined *puVar15;
  undefined *puVar16;
  undefined *puVar17;
  undefined *puVar18;
  undefined *puVar19;
  undefined *puVar20;
  cfstringStruct *self_00;
  id pvVar21;
  id self_01;
  id self_02;
  id self_03;
  cfstringStruct *pcVar22;
  id pvVar23;
  id pvVar24;
  cfstringStruct *pcVar25;
  undefined4 extraout_EDX;
  undefined4 *puVar26;
  float fVar27;
  double dVar28;
  double dVar29;
  double dVar30;
  double dVar31;
  SEL op;
  undefined4 uVar32;
  
  self_00 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
  pvVar21 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc);
  self_01 = _objc_msgSend(pvVar21,sel_init);
  self_02 = _objc_msgSend(cls_NSAttributedString,
                          sel_hyperAcceptableStringKeysAndAttributesForStoring);
  pvVar21 = _objc_msgSend(hyperTextAttributesFromXMLRepresentation,sel_children);
  self_03 = _objc_msgSend(pvVar21,sel_objectEnumerator);
  pvVar21 = _objc_msgSend(self_03,sel_nextObject);
  puVar19 = PTR_003369e0;
  puVar18 = PTR_003369dc;
  puVar17 = PTR_003369d8;
  puVar16 = PTR_003369d4;
  puVar15 = PTR_003369d0;
  puVar14 = PTR_003369cc;
  puVar13 = PTR_003369c8;
  puVar12 = PTR_003369c4;
  puVar11 = PTR_003369c0;
  puVar10 = PTR_003369bc;
  puVar9 = PTR_003369b8;
  puVar8 = PTR_003363e4;
  puVar7 = PTR_003363d8;
  puVar6 = PTR_003363d4;
  puVar5 = PTR_003363d0;
  puVar4 = PTR_003363cc;
  puVar3 = PTR_00336394;
  puVar2 = PTR_00336150;
  puVar1 = PTR_00336068;
  do {
    if (pvVar21 == (id)0x0) {
      _objc_msgSend(self_01,sel_release);
      pvVar21 = _objc_msgSend(self_00,sel_copy);
      pvVar21 = _objc_msgSend(pvVar21,sel_autorelease);
      return pvVar21;
    }
    pcVar22 = _objc_msgSend(pvVar21,sel_name);
    pvVar23 = _objc_msgSend(self_02,sel_allValues);
    pcVar25 = pcVar22;
    pvVar23 = _objc_msgSend(pvVar23,sel_containsObject_,pcVar22);
    if ((char)pvVar23 != '\0') {
      pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_backgroundColor);
      if (((((char)pvVar23 == '\0') &&
           (pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_foregroundColor),
           (char)pvVar23 == '\0')) &&
          (pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_strikethroughColor),
          (char)pvVar23 == '\0')) &&
         ((pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_strokeColor),
          (char)pvVar23 == '\0' &&
          (pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_underlineColor),
          (char)pvVar23 == '\0')))) {
        pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_baselineOffset);
        puVar20 = cls_NSNumber;
        if ((char)pvVar23 == '\0') {
          pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_expansionFactor);
          puVar20 = cls_NSNumber;
          if ((char)pvVar23 != '\0') {
            pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_baselineOffset);
            pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
            dVar28 = _objc_msgSend_fpret(pvVar21,sel_floatValue);
            pcVar25 = _objc_msgSend(puVar20,sel_numberWithFloat_,(float)dVar28);
            puVar26 = (undefined4 *)puVar11;
            goto LAB_0028cb7c;
          }
          pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_font);
          if ((char)pvVar23 != '\0') {
            pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_fontName);
            pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
            pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_fontSize);
            pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
            dVar28 = _objc_msgSend_fpret(pvVar21,sel_floatValue);
            pcVar25 = _objc_msgSend(cls_NSFont,sel_fontWithName_size_,pvVar23,(float)dVar28);
            puVar26 = (undefined4 *)puVar1;
            goto LAB_0028cb7c;
          }
          pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_kern);
          puVar20 = cls_NSNumber;
          if ((char)pvVar23 != '\0') {
            pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_kernAmount);
            pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
            dVar28 = _objc_msgSend_fpret(pvVar21,sel_floatValue);
            pcVar25 = _objc_msgSend(puVar20,sel_numberWithFloat_,(float)dVar28);
            puVar26 = (undefined4 *)puVar4;
            goto LAB_0028cb7c;
          }
          pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_ligatures);
          puVar20 = cls_NSNumber;
          if ((char)pvVar23 != '\0') {
            pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_ligatures);
            pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
            pvVar21 = _objc_msgSend(pvVar21,sel_intValue);
            pcVar25 = _objc_msgSend(puVar20,sel_numberWithInt_,pvVar21);
            puVar26 = (undefined4 *)puVar12;
            goto LAB_0028d86c;
          }
          pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_obliqueness);
          puVar20 = cls_NSNumber;
          if ((char)pvVar23 != '\0') {
            pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_obliqueness);
            pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
            dVar28 = _objc_msgSend_fpret(pvVar21,sel_floatValue);
            pcVar25 = _objc_msgSend(puVar20,sel_numberWithFloat_,(float)dVar28);
            puVar26 = (undefined4 *)puVar14;
            goto LAB_0028cb7c;
          }
          pcVar25 = &cfstr_paragraphStyle;
          pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_paragraphStyle);
          if ((char)pvVar23 == '\0') {
            pcVar25 = &cfstr_shadow;
            pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_shadow);
            if ((char)pvVar23 != '\0') {
              pvVar23 = _objc_msgSend(cls_NSShadow,sel_alloc,pcVar25);
              pcVar22 = _objc_msgSend(pvVar23,sel_init);
              pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_blur);
              pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
              dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
              _objc_msgSend(pcVar22,sel_setShadowBlurRadius_,(float)dVar28);
              pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_angle);
              pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
              dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
              pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_distance);
              pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
              dVar29 = _objc_msgSend_fpret(pvVar21,sel_floatValue);
              pvVar21 = _objc_msgSend(cls_NSShadow,
                                      sel_hyperShadowOffsetWithShadowAngle_shadowDistance_,
                                      (float)((dVar28 * 3.141592653589793) / 180.0),(float)dVar29);
              _objc_msgSend(pcVar22,sel_setShadowOffset_,pvVar21,extraout_EDX);
              puVar26 = (undefined4 *)puVar5;
              goto LAB_0028d4c6;
            }
            pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_strikethroughStyle);
            puVar20 = cls_NSNumber;
            if ((char)pvVar23 != '\0') {
              pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_strikethroughStyle);
              pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
              pvVar21 = _objc_msgSend(pvVar21,sel_intValue);
              pcVar25 = _objc_msgSend(puVar20,sel_numberWithInt_,pvVar21);
              puVar26 = (undefined4 *)puVar16;
              goto LAB_0028d86c;
            }
            pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_strokeWidth);
            puVar20 = cls_NSNumber;
            if ((char)pvVar23 != '\0') {
              pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_strokeWidth);
              pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
              dVar28 = _objc_msgSend_fpret(pvVar21,sel_floatValue);
              pcVar25 = _objc_msgSend(puVar20,sel_numberWithFloat_,(float)dVar28);
              puVar26 = (undefined4 *)puVar7;
              goto LAB_0028cb7c;
            }
            pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_superscript);
            puVar20 = cls_NSNumber;
            if ((char)pvVar23 == '\0') {
              pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_toolTip);
              if ((char)pvVar23 != '\0') {
                pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_toolTip);
                pcVar25 = _objc_msgSend(pvVar21,sel_stringValue);
                puVar26 = (undefined4 *)puVar18;
                goto LAB_0028d86c;
              }
              pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_underlineStyle);
              puVar20 = cls_NSNumber;
              if ((char)pvVar23 != '\0') {
                pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_underline);
                pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
                pvVar21 = _objc_msgSend(pvVar21,sel_intValue);
                pcVar25 = _objc_msgSend(puVar20,sel_numberWithInt_,pvVar21);
                puVar26 = (undefined4 *)puVar8;
                goto LAB_0028d86c;
              }
              pcVar25 = &cfstr_link;
              pvVar23 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_link);
              if ((char)pvVar23 == '\0') goto LAB_0028cad1;
              pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_link);
              pcVar25 = _objc_msgSend(pvVar21,sel_stringValue);
              uVar32 = *(undefined4 *)puVar13;
            }
            else {
              pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_superscript);
              pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
              pvVar21 = _objc_msgSend(pvVar21,sel_intValue);
              pcVar25 = _objc_msgSend(puVar20,sel_numberWithInt_,pvVar21);
              puVar26 = (undefined4 *)puVar17;
LAB_0028d86c:
              uVar32 = *puVar26;
            }
            goto LAB_0028cac6;
          }
          pvVar23 = _objc_msgSend(cls_NSParagraphStyle,sel_defaultParagraphStyle,pcVar25);
          pcVar22 = _objc_msgSend(pvVar23,sel_mutableCopyWithZone_,0);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_alignment);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          pvVar23 = _objc_msgSend(pvVar23,sel_intValue);
          _objc_msgSend(pcVar22,sel_setAlignment_,pvVar23);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_baseWritingDirection);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          pvVar23 = _objc_msgSend(pvVar23,sel_intValue);
          _objc_msgSend(pcVar22,sel_setBaseWritingDirection_,pvVar23);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_defaultTabInterval);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setDefaultTabInterval_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_firstLineHeadIndent);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setFirstLineHeadIndent_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_headIndent);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setHeadIndent_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_lineBreakMode);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          pvVar23 = _objc_msgSend(pvVar23,sel_intValue);
          _objc_msgSend(pcVar22,sel_setLineBreakMode_,pvVar23);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_lineHeightMultiple);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setLineHeightMultiple_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_lineSpacing);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setLineSpacing_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_maximumLineHeight);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setMaximumLineHeight_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_minimumLineHeight);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setMinimumLineHeight_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_paragraphSpacing);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setParagraphSpacing_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_paragraphSpacingBefore);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setParagraphSpacingBefore_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_tailIndent);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setTailIndent_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_tabStop);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          pvVar24 = _objc_msgSend(pvVar23,sel_length);
          if (pvVar24 != (id)0x0) {
            pvVar23 = _objc_msgSend(pvVar23,sel_componentsSeparatedByString_,&cfstr__);
            _objc_msgSend(pcVar22,sel_setTabStops_,pvVar23);
          }
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_tighteningFactorForTruncation
                                 );
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setTighteningFactorForTruncation_,(float)dVar28);
          pvVar23 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_hyphenationFactor);
          pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
          _objc_msgSend(pcVar22,sel_setHyphenationFactor_,(float)dVar28);
          pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_headerLevel);
          pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
          pvVar21 = _objc_msgSend(pvVar21,sel_intValue);
          _objc_msgSend(pcVar22,sel_setHeaderLevel_,pvVar21);
          puVar26 = (undefined4 *)puVar2;
LAB_0028d4c6:
          uVar32 = *puVar26;
          pcVar25 = pcVar22;
          _objc_msgSend(self_00,sel_setObject_forKey_,pcVar22,uVar32);
          op = sel_release;
        }
        else {
          pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_baselineOffset);
          pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
          dVar28 = _objc_msgSend_fpret(pvVar21,sel_floatValue);
          pcVar25 = _objc_msgSend(puVar20,sel_numberWithFloat_,(float)dVar28);
          puVar26 = (undefined4 *)puVar10;
LAB_0028cb7c:
          uVar32 = *puVar26;
          pcVar22 = self_00;
          op = sel_setObject_forKey_;
        }
        _objc_msgSend(pcVar22,op,pcVar25,uVar32);
      }
      else {
        pcVar25 = &cfstr_gradientColor;
        pvVar23 = _objc_msgSend(pvVar21,sel_elementsForName_,&cfstr_gradientColor);
        pvVar23 = _objc_msgSend(pvVar23,sel_extraFirstObject);
        if (pvVar23 == (id)0x0) {
          pvVar23 = _objc_msgSend(pvVar21,sel_elementsForName_,&cfstr_textureMediaRef);
          pvVar23 = _objc_msgSend(pvVar23,sel_extraFirstObject);
          if (pvVar23 != (id)0x0) {
            pvVar21 = _objc_msgSend(pvVar23,sel_attributeForName_,&cfstr_refId);
            pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
            pvVar23 = _objc_msgSend(cls_HSNewMediaAccessor,sel_sharedMediaAccessor);
            pvVar21 = _objc_msgSend(cls_HSUID,sel_UIDWithString_,pvVar21);
            pvVar21 = _objc_msgSend(pvVar23,sel_mediaForUID_,pvVar21);
            pvVar23 = _objc_msgSend(cls_NSImage,sel_alloc);
            pvVar21 = _objc_msgSend(pvVar21,sel_mediaData);
            pvVar24 = _objc_msgSend(pvVar23,sel_initWithData_,pvVar21);
            if (pvVar24 == (id)0x0) {
              pcVar25 = (cfstringStruct *)0x0;
            }
            else {
              pvVar21 = pvVar24;
              pcVar25 = _objc_msgSend(cls_NSColor,sel_colorWithPatternImage_,pvVar24);
            }
            goto LAB_0028c842;
          }
          pvVar21 = _objc_msgSend(pvVar21,sel_attributeForName_,&cfstr_color);
          pvVar21 = _objc_msgSend(pvVar21,sel_stringValue);
          pvVar21 = _objc_msgSend(pvVar21,sel_componentsSeparatedByString_,&cfstr__);
          pvVar23 = _objc_msgSend(pvVar21,sel_count);
          if (pvVar23 < (id)0x3) {
            pcVar25 = (cfstringStruct *)0x0;
          }
          else {
            pvVar23 = _objc_msgSend(pvVar21,sel_objectAtIndex_,0);
            dVar28 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
            pvVar23 = _objc_msgSend(pvVar21,sel_objectAtIndex_,1);
            dVar29 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
            pvVar23 = _objc_msgSend(pvVar21,sel_objectAtIndex_,2);
            dVar30 = _objc_msgSend_fpret(pvVar23,sel_floatValue);
            pvVar23 = _objc_msgSend(pvVar21,sel_count);
            if (pvVar23 == (id)0x4) {
              pvVar21 = _objc_msgSend(pvVar21,sel_objectAtIndex_,3);
              dVar31 = _objc_msgSend_fpret(pvVar21,sel_floatValue);
              fVar27 = (float)dVar31;
            }
            else {
              fVar27 = 1.0;
            }
            pcVar25 = _objc_msgSend(cls_NSColor,sel_colorWithCalibratedRed_green_blue_alpha_,
                                    (float)dVar28,(float)dVar29,(float)dVar30,fVar27);
          }
        }
        else {
          pvVar24 = _objc_msgSend(cls_HSColor,sel_new,pcVar25);
          _objc_msgSend(pvVar24,sel_importFromXMLElementRepresentation_inContext_,pvVar23,inContext)
          ;
          pvVar21 = pvVar24;
          pcVar25 = _objc_msgSend(cls_HSGradientColor,sel_gradientColorWithHSColor_,pvVar24);
LAB_0028c842:
          _objc_msgSend(pvVar24,sel_release,pvVar21);
        }
        uVar32 = *(undefined4 *)puVar9;
        pvVar21 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_foregroundColor);
        puVar26 = (undefined4 *)puVar3;
        if ((((char)pvVar21 != '\0') ||
            (pvVar21 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_strikethroughColor),
            puVar26 = (undefined4 *)puVar15, (char)pvVar21 != '\0')) ||
           ((pvVar21 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_strokeColor),
            puVar26 = (undefined4 *)puVar6, (char)pvVar21 != '\0' ||
            (pvVar21 = _objc_msgSend(pcVar22,sel_isEqualToString_,&cfstr_underlineColor),
            puVar26 = (undefined4 *)puVar19, (char)pvVar21 != '\0')))) {
          uVar32 = *puVar26;
        }
LAB_0028cac6:
        _objc_msgSend(self_00,sel_setObject_forKey_,pcVar25,uVar32);
      }
    }
LAB_0028cad1:
    pvVar21 = _objc_msgSend(self_03,sel_nextObject,pcVar25);
  } while( true );
}

*/
+ (id)hyperTextAttributesFromXMLRepresentation:(id)aRepresentation inContext:(id)aContext
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *acceptable = [NSAttributedString hyperAcceptableStringKeysAndAttributesForStoring];
    NSEnumerator *enumerator = [[aRepresentation children] objectEnumerator];
    id child;
    while ((child = [enumerator nextObject]) != nil) {
        NSString *name = [child name];
        if (![[acceptable allValues] containsObject:name]) {
            continue;
        }
        if ([name isEqualToString:@"backgroundColor"] || [name isEqualToString:@"foregroundColor"] || [name isEqualToString:@"strikethroughColor"] || [name isEqualToString:@"strokeColor"] || [name isEqualToString:@"underlineColor"]) {
            NSColor *color;
            id gradientElement = [[child elementsForName:@"gradientColor"] extraFirstObject];
            if (gradientElement != nil) {
                HSColor *hsColor = [HSColor new];
                [hsColor importFromXMLElementRepresentation:gradientElement inContext:aContext];
                color = (NSColor *)[HSGradientColor gradientColorWithHSColor:hsColor];
                [hsColor release];
            } else {
                id textureElement = [[child elementsForName:@"textureMediaRef"] extraFirstObject];
                if (textureElement != nil) {
                    NSString *refId = [[textureElement attributeForName:@"refId"] stringValue];
                    id media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[HSUID UIDWithString:refId]];
                    NSImage *image = [[NSImage alloc] initWithData:[media mediaData]];
                    if (image == nil) {
                        color = nil;
                    } else {
                        color = [NSColor colorWithPatternImage:image];
                    }
                    [image release];
                } else {
                    NSArray *components = [[[child attributeForName:@"color"] stringValue] componentsSeparatedByString:@","];
                    if ([components count] < 3) {
                        color = nil;
                    } else {
                        float red = [[components objectAtIndex:0] floatValue];
                        float green = [[components objectAtIndex:1] floatValue];
                        float blue = [[components objectAtIndex:2] floatValue];
                        float alpha = ([components count] == 4) ? [[components objectAtIndex:3] floatValue] : 1.0f;
                        color = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha];
                    }
                }
            }
            NSString *key = NSBackgroundColorAttributeName;
            if ([name isEqualToString:@"foregroundColor"]) {
                key = NSForegroundColorAttributeName;
            } else if ([name isEqualToString:@"strikethroughColor"]) {
                key = NSStrikethroughColorAttributeName;
            } else if ([name isEqualToString:@"strokeColor"]) {
                key = NSStrokeColorAttributeName;
            } else if ([name isEqualToString:@"underlineColor"]) {
                key = NSUnderlineColorAttributeName;
            }
            if (color != nil) {
                [result setObject:color forKey:key];
            }
        } else if ([name isEqualToString:@"baselineOffset"]) {
            float value = [[[child attributeForName:@"baselineOffset"] stringValue] floatValue];
            [result setObject:[NSNumber numberWithFloat:value] forKey:NSBaselineOffsetAttributeName];
        } else if ([name isEqualToString:@"expansionFactor"]) {
            float value = [[[child attributeForName:@"baselineOffset"] stringValue] floatValue];
            [result setObject:[NSNumber numberWithFloat:value] forKey:NSExpansionAttributeName];
        } else if ([name isEqualToString:@"font"]) {
            NSString *fontName = [[child attributeForName:@"fontName"] stringValue];
            float fontSize = [[[child attributeForName:@"fontSize"] stringValue] floatValue];
            [result setObject:[NSFont fontWithName:fontName size:fontSize] forKey:NSFontAttributeName];
        } else if ([name isEqualToString:@"kern"]) {
            float value = [[[child attributeForName:@"kernAmount"] stringValue] floatValue];
            [result setObject:[NSNumber numberWithFloat:value] forKey:NSKernAttributeName];
        } else if ([name isEqualToString:@"ligatures"]) {
            int value = [[[child attributeForName:@"ligatures"] stringValue] intValue];
            [result setObject:[NSNumber numberWithInt:value] forKey:NSLigatureAttributeName];
        } else if ([name isEqualToString:@"obliqueness"]) {
            float value = [[[child attributeForName:@"obliqueness"] stringValue] floatValue];
            [result setObject:[NSNumber numberWithFloat:value] forKey:NSObliquenessAttributeName];
        } else if ([name isEqualToString:@"paragraphStyle"]) {
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopyWithZone:nil];
            [style setAlignment:[[[child attributeForName:@"alignment"] stringValue] intValue]];
            [style setBaseWritingDirection:[[[child attributeForName:@"baseWritingDirection"] stringValue] intValue]];
            [style setDefaultTabInterval:[[[child attributeForName:@"defaultTabInterval"] stringValue] floatValue]];
            [style setFirstLineHeadIndent:[[[child attributeForName:@"firstLineHeadIndent"] stringValue] floatValue]];
            [style setHeadIndent:[[[child attributeForName:@"headIndent"] stringValue] floatValue]];
            [style setLineBreakMode:[[[child attributeForName:@"lineBreakMode"] stringValue] intValue]];
            [style setLineHeightMultiple:[[[child attributeForName:@"lineHeightMultiple"] stringValue] floatValue]];
            [style setLineSpacing:[[[child attributeForName:@"lineSpacing"] stringValue] floatValue]];
            [style setMaximumLineHeight:[[[child attributeForName:@"maximumLineHeight"] stringValue] floatValue]];
            [style setMinimumLineHeight:[[[child attributeForName:@"minimumLineHeight"] stringValue] floatValue]];
            [style setParagraphSpacing:[[[child attributeForName:@"paragraphSpacing"] stringValue] floatValue]];
            [style setParagraphSpacingBefore:[[[child attributeForName:@"paragraphSpacingBefore"] stringValue] floatValue]];
            [style setTailIndent:[[[child attributeForName:@"tailIndent"] stringValue] floatValue]];
            NSString *tabStops = [[child attributeForName:@"tabStop"] stringValue];
            if ([tabStops length] != 0) {
                [style setTabStops:[tabStops componentsSeparatedByString:@","]];
            }
            [style setTighteningFactorForTruncation:[[[child attributeForName:@"tighteningFactorForTruncation"] stringValue] floatValue]];
            [style setHyphenationFactor:[[[child attributeForName:@"hyphenationFactor"] stringValue] floatValue]];
            [style setHeaderLevel:[[[child attributeForName:@"headerLevel"] stringValue] intValue]];
            [result setObject:style forKey:NSParagraphStyleAttributeName];
            [style release];
        } else if ([name isEqualToString:@"shadow"]) {
            NSShadow *shadow = [[NSShadow alloc] init];
            [shadow setShadowBlurRadius:[[[child attributeForName:@"blur"] stringValue] floatValue]];
            float angle = [[[child attributeForName:@"angle"] stringValue] floatValue];
            float distance = [[[child attributeForName:@"distance"] stringValue] floatValue];
            [shadow setShadowOffset:[NSShadow hyperShadowOffsetWithShadowAngle:(float)((angle * 3.141592653589793) / 180.0) shadowDistance:distance]];
            [result setObject:shadow forKey:NSShadowAttributeName];
            [shadow release];
        } else if ([name isEqualToString:@"strikethroughStyle"]) {
            int value = [[[child attributeForName:@"strikethroughStyle"] stringValue] intValue];
            [result setObject:[NSNumber numberWithInt:value] forKey:NSStrikethroughStyleAttributeName];
        } else if ([name isEqualToString:@"strokeWidth"]) {
            float value = [[[child attributeForName:@"strokeWidth"] stringValue] floatValue];
            [result setObject:[NSNumber numberWithFloat:value] forKey:NSStrokeWidthAttributeName];
        } else if ([name isEqualToString:@"superscript"]) {
            int value = [[[child attributeForName:@"superscript"] stringValue] intValue];
            [result setObject:[NSNumber numberWithInt:value] forKey:NSSuperscriptAttributeName];
        } else if ([name isEqualToString:@"toolTip"]) {
            [result setObject:[[child attributeForName:@"toolTip"] stringValue] forKey:NSToolTipAttributeName];
        } else if ([name isEqualToString:@"underlineStyle"]) {
            int value = [[[child attributeForName:@"underline"] stringValue] intValue];
            [result setObject:[NSNumber numberWithInt:value] forKey:NSUnderlineStyleAttributeName];
        } else if ([name isEqualToString:@"link"]) {
            [result setObject:[[child attributeForName:@"link"] stringValue] forKey:NSLinkAttributeName];
        }
    }
    [pool release];
    return [[result copy] autorelease];
    return 0;
}

+ (id)hyperAcceptableStringKeysAndAttributesForStoring
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@"backgroundColor", NSBackgroundColorAttributeName, @"baselineOffset", NSBaselineOffsetAttributeName, @"expansion", NSExpansionAttributeName, @"font", NSFontAttributeName, @"foregroundColor", NSForegroundColorAttributeName, @"kern", NSKernAttributeName, @"legature", NSLigatureAttributeName, @"obliqueness", NSObliquenessAttributeName, @"paragraphStyle", NSParagraphStyleAttributeName, @"shadow", NSShadowAttributeName, @"strikethroughColor", NSStrikethroughColorAttributeName, @"strikethroughStyle", NSStrikethroughStyleAttributeName, @"strokeColor", NSStrokeColorAttributeName, @"strokeWidth", NSStrokeWidthAttributeName, @"superscript", NSSuperscriptAttributeName, @"toolTip", NSToolTipAttributeName, @"underlineColor", NSUnderlineColorAttributeName, @"underlineStyle", NSUnderlineStyleAttributeName, @"link", NSLinkAttributeName, nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028c1e1 @ 0028c1e1, 538 bytes * /

id FUN_0028c1e1(id self,SEL _cmd)

{
  undefined *puVar1;
  undefined *puVar2;
  int iVar3;
  id self_00;
  id self_01;
  id self_02;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int *piVar7;
  double dVar8;
  undefined4 uVar9;
  int iVar10;
  int local_24;
  id local_20;
  int local_1c;
  id local_18;
  
  self_00 = _objc_msgSend(self,sel_mutableCopy);
  self_01 = _objc_msgSend(cls_NSLayoutManager,sel_new);
  local_1c = 0;
  local_18 = (id)0x0;
  local_20 = _objc_msgSend(self,sel_length);
  puVar2 = PTR_00336150;
  puVar1 = PTR_00336068;
  if (local_20 != (id)0x0) {
    local_24 = 0;
    do {
      self_02 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
      piVar7 = &local_1c;
      iVar10 = local_24;
      pvVar6 = local_20;
      pvVar4 = _objc_msgSend(self,sel_attributesAtIndex_longestEffectiveRange_inRange_,local_24,
                             piVar7,local_24,local_20);
      uVar9 = *(undefined4 *)puVar2;
      pvVar5 = _objc_msgSend(pvVar4,sel_valueForKey_,uVar9);
      if (pvVar5 != (id)0x0) {
        pvVar6 = _objc_msgSend(pvVar4,sel_valueForKey_,*(undefined4 *)puVar1,piVar7,iVar10,pvVar6);
        dVar8 = _objc_msgSend_fpret(self_01,sel_defaultLineHeightForFont_,pvVar6);
        piVar7 = _objc_msgSend(pvVar5,sel_hyperParagraphStyleByChangingMinimumLineHeight_,
                               (float)dVar8);
        uVar9 = *(undefined4 *)puVar2;
        iVar10 = local_1c;
        pvVar6 = local_18;
        _objc_msgSend(self_00,sel_addAttribute_value_range_,uVar9,piVar7,local_1c,local_18);
      }
      pvVar4 = local_18;
      iVar3 = local_1c;
      pvVar5 = (id)((int)local_20 + (local_24 - local_1c));
      local_20 = (id)((int)pvVar5 - (int)local_18);
      _objc_msgSend(self_02,sel_release,uVar9,piVar7,iVar10,pvVar6);
      local_24 = iVar3 + (int)pvVar4;
    } while (pvVar5 != pvVar4);
  }
  pvVar6 = _objc_msgSend(self_00,sel_copy);
  pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
  _objc_msgSend(self_00,sel_release);
  _objc_msgSend(self_01,sel_release);
  return pvVar6;
}

*/
- (id)hyperAttributedStringByAddingDefaultParagraphLineHeightAttribute
{
    NSMutableAttributedString *copy = [self mutableCopy];
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSRange effectiveRange = NSMakeRange(0, 0);
    NSUInteger remaining = [self length];
    if (remaining != 0) {
        NSUInteger index = 0;
        NSUInteger total;
        do {
            NSAutoreleasePool *pool = [NSAutoreleasePool new];
            NSDictionary *attributes = [self attributesAtIndex:index longestEffectiveRange:&effectiveRange inRange:NSMakeRange(index, remaining)];
            id style = [attributes valueForKey:NSParagraphStyleAttributeName];
            if (style != nil) {
                id font = [attributes valueForKey:NSFontAttributeName];
                float lineHeight = [layoutManager defaultLineHeightForFont:font];
                id newStyle = [style hyperParagraphStyleByChangingMinimumLineHeight:lineHeight];
                [copy addAttribute:NSParagraphStyleAttributeName value:newStyle range:effectiveRange];
            }
            total = remaining + (index - effectiveRange.location);
            remaining = total - effectiveRange.length;
            [pool release];
            index = effectiveRange.location + effectiveRange.length;
        } while (total != effectiveRange.length);
    }
    id result = [[copy copy] autorelease];
    [copy release];
    [layoutManager release];
    return result;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028a388 @ 0028a388, 396 bytes * /

id FUN_0028a388(id self,SEL _cmd,id hyperXMLRepresentationInContext,id UID)

{
  id self_00;
  id pvVar1;
  id self_01;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *self_02;
  id pvVar5;
  int iVar6;
  cfstringStruct *pcVar7;
  int local_1c;
  int local_18;
  
  pcVar7 = &cfstr_richText;
  self_00 = _objc_msgSend(cls_NSXMLElement,sel_elementWithName_,&cfstr_richText);
  pvVar1 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc);
  self_01 = _objc_msgSend(pvVar1,sel_init);
  local_1c = 0;
  local_18 = 0;
  pvVar2 = _objc_msgSend(self,sel_length);
  pvVar1 = (id)(local_18 + local_1c);
  while (pvVar1 < pvVar2) {
    iVar6 = local_1c + local_18;
    pvVar3 = _objc_msgSend(self,sel_attributesAtIndex_longestEffectiveRange_inRange_,iVar6,&local_1c
                           ,iVar6,(int)pvVar2 - iVar6);
    pvVar1 = _objc_msgSend(self,sel_attributedSubstringFromRange_,local_1c,local_18);
    pvVar4 = _objc_msgSend(pvVar1,sel_string);
    pcVar7 = hyperXMLRepresentationInContext;
    pvVar1 = UID;
    self_02 = _objc_msgSend(self,sel_hyperXMLNodeRepresentationInContext_UID_attributes_substring_,
                            hyperXMLRepresentationInContext,UID,pvVar3,pvVar4);
    pvVar5 = _objc_msgSend(self_02,sel_childCount);
    if (pvVar5 != (id)0x0) {
      _objc_msgSend(self_00,sel_addChild_,self_02,pvVar1,pvVar3,pvVar4);
      pcVar7 = self_02;
    }
    pvVar1 = (id)(local_18 + local_1c);
  }
  _objc_msgSend(self_01,sel_release,pcVar7);
  return self_00;
}

*/
- (id)hyperXMLRepresentationInContext:(id)aContext UID:(id)aUID
{
    NSXMLElement *element = [NSXMLElement elementWithName:@"richText"];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSRange range = NSMakeRange(0, 0);
    NSUInteger length = [self length];
    while (range.location + range.length < length) {
        NSUInteger start = range.location + range.length;
        NSDictionary *attributes = [self attributesAtIndex:start longestEffectiveRange:&range inRange:NSMakeRange(start, length - start)];
        NSString *substring = [[self attributedSubstringFromRange:range] string];
        id node = [self hyperXMLNodeRepresentationInContext:aContext UID:aUID attributes:attributes substring:substring];
        if ([node childCount] != 0) {
            [element addChild:node];
        }
    }
    [pool release];
    return element;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0028a963 @ 0028a963, 6270 bytes * /

id FUN_0028a963(id self,SEL _cmd,id hyperXMLNodeRepresentationInContext,id UID,id attributes,
               id substring)

{
  undefined *puVar1;
  undefined *puVar2;
  undefined *puVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  undefined *puVar8;
  undefined *puVar9;
  undefined *puVar10;
  undefined *puVar11;
  undefined *puVar12;
  undefined *puVar13;
  undefined *puVar14;
  undefined *puVar15;
  undefined *puVar16;
  undefined *puVar17;
  undefined *puVar18;
  undefined *puVar19;
  undefined *puVar20;
  undefined *puVar21;
  undefined *puVar22;
  id pvVar23;
  id self_00;
  id self_01;
  id self_02;
  id self_03;
  id pvVar24;
  id pvVar25;
  id self_04;
  id self_05;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined *puVar26;
  undefined *puVar27;
  double dVar28;
  double dVar29;
  double dVar30;
  double dVar31;
  SEL op;
  undefined4 uVar32;
  cfstringStruct *pcVar33;
  undefined8 in_stack_ffffff20;
  undefined8 uVar34;
  undefined1 local_48 [56];
  
  uVar32 = (undefined4)((ulonglong)in_stack_ffffff20 >> 0x20);
  pvVar23 = _objc_msgSend(substring,sel_length);
  if (pvVar23 == (id)0x0) {
    self_00 = (id)0x0;
  }
  else {
    self_00 = _objc_msgSend(cls_NSXMLElement,sel_elementWithName_,&cfstr_substringAttributes);
    uVar34 = CONCAT44(uVar32,substring);
    pvVar23 = _objc_msgSend(cls_NSXMLElement,sel_elementWithName_stringValue_,&cfstr_substring,
                            substring);
    _objc_msgSend(self_00,sel_addChild_,pvVar23);
    self_01 = _objc_msgSend(cls_NSAttributedString,
                            sel_hyperAcceptableStringKeysAndAttributesForStoring);
    self_02 = _objc_msgSend(self_01,sel_allKeys);
    self_03 = _objc_msgSend(attributes,sel_keyEnumerator);
    pvVar23 = _objc_msgSend(self_03,sel_nextObject);
    puVar21 = PTR_003369e0;
    puVar20 = PTR_003369dc;
    puVar19 = PTR_003369d8;
    puVar18 = PTR_003369d4;
    puVar17 = PTR_003369d0;
    puVar16 = PTR_003369cc;
    puVar15 = PTR_003369c8;
    puVar14 = PTR_003369c4;
    puVar13 = PTR_003369c0;
    puVar12 = PTR_003369bc;
    puVar11 = PTR_003369b8;
    puVar10 = PTR_003363e4;
    puVar9 = PTR_003363d8;
    puVar8 = PTR_003363d4;
    puVar7 = PTR_003363d0;
    puVar6 = PTR_003363cc;
    puVar5 = PTR_003363b0;
    puVar4 = PTR_00336394;
    puVar3 = PTR_00336350;
    puVar2 = PTR_00336150;
    puVar1 = PTR_00336068;
    while (pvVar23 != (id)0x0) {
      pvVar25 = pvVar23;
      pvVar24 = _objc_msgSend(self_02,sel_containsObject_,pvVar23);
      if ((char)pvVar24 != '\0') {
        pvVar24 = _objc_msgSend(attributes,sel_objectForKey_,pvVar23);
        local_48._4_6_ = (undefined6)((unkuint10)local_48._0_10_ >> 0x20);
        local_48._0_4_ = pvVar24;
        pvVar25 = _objc_msgSend(self_01,sel_objectForKey_,pvVar23);
        self_04 = _objc_msgSend(cls_NSXMLElement,sel_elementWithName_,pvVar25);
        uVar32 = *(undefined4 *)puVar11;
        pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
        if ((char)pvVar25 == '\0') {
          uVar32 = *(undefined4 *)puVar4;
          pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
          if ((char)pvVar25 != '\0') goto LAB_0028ac64;
          uVar32 = *(undefined4 *)puVar17;
          pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
          if ((char)pvVar25 != '\0') goto LAB_0028ac64;
          uVar32 = *(undefined4 *)puVar8;
          pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
          if ((char)pvVar25 != '\0') goto LAB_0028ac64;
          uVar32 = *(undefined4 *)puVar21;
          pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
          if ((char)pvVar25 != '\0') goto LAB_0028ac64;
          pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,*(undefined4 *)puVar12);
          puVar27 = cls_NSXMLNode;
          puVar26 = cls_NSString;
          if ((char)pvVar25 == '\0') {
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,*(undefined4 *)puVar13);
            puVar27 = cls_NSXMLNode;
            puVar26 = cls_NSString;
            if ((char)pvVar25 != '\0') {
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_floatValue);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              uVar34 = CONCAT44((int)((ulonglong)dVar31 >> 0x20),pvVar23);
              pcVar33 = &cfstr_expansionFactor;
              goto LAB_0028b0c9;
            }
            uVar32 = *(undefined4 *)puVar1;
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
            puVar26 = cls_NSXMLNode;
            if ((char)pvVar25 != '\0') {
              pvVar23 = _objc_msgSend(pvVar24,sel_fontName,uVar32);
              pvVar23 = _objc_msgSend(puVar26,sel_attributeWithName_stringValue_,&cfstr_fontName,
                                      pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_pointSize);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___0f,dVar31);
              uVar32 = (undefined4)((ulonglong)dVar31 >> 0x20);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,&cfstr_fontSize,
                                      pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              pvVar23 = _objc_msgSend(pvVar24,sel_familyName);
              uVar34 = CONCAT44(uVar32,pvVar23);
              pcVar33 = &cfstr_fontFamily;
              goto LAB_0028b0c9;
            }
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,*(undefined4 *)puVar6);
            puVar27 = cls_NSXMLNode;
            puVar26 = cls_NSString;
            if ((char)pvVar25 != '\0') {
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_floatValue);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              uVar34 = CONCAT44((int)((ulonglong)dVar31 >> 0x20),pvVar23);
              pcVar33 = &cfstr_kernAmount;
              goto LAB_0028b0c9;
            }
            uVar32 = *(undefined4 *)puVar14;
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
            puVar26 = cls_NSXMLNode;
            puVar27 = cls_NSString;
            if ((char)pvVar25 != '\0') {
              pvVar23 = _objc_msgSend(pvVar24,sel_intValue,uVar32);
              uVar32 = (undefined4)((ulonglong)uVar34 >> 0x20);
              pvVar23 = _objc_msgSend(puVar27,sel_stringWithFormat_,&cfstr__d,pvVar23);
              uVar34 = CONCAT44(uVar32,pvVar23);
              pcVar33 = &cfstr_ligatures;
              goto LAB_0028b033;
            }
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,*(undefined4 *)puVar16);
            puVar27 = cls_NSXMLNode;
            puVar26 = cls_NSString;
            if ((char)pvVar25 != '\0') {
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_floatValue);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              uVar34 = CONCAT44((int)((ulonglong)dVar31 >> 0x20),pvVar23);
              pcVar33 = &cfstr_obliqueness;
              goto LAB_0028b0c9;
            }
            uVar32 = *(undefined4 *)puVar2;
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
            puVar26 = cls_NSNumber;
            if ((char)pvVar25 != '\0') {
              pvVar23 = _objc_msgSend(pvVar24,sel_alignment,uVar32);
              pvVar23 = _objc_msgSend(puVar26,sel_numberWithInt_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              pvVar23 = _objc_msgSend(pvVar23,sel_intValue);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr__d,pvVar23);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,&cfstr_alignment,
                                      pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar26 = cls_NSNumber;
              pvVar23 = _objc_msgSend(pvVar24,sel_baseWritingDirection);
              pvVar23 = _objc_msgSend(puVar26,sel_numberWithInt_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              pvVar23 = _objc_msgSend(pvVar23,sel_intValue);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr__d,pvVar23);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_baseWritingDirection,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_defaultTabInterval);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___1f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_defaultTabInterval,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_firstLineHeadIndent);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_firstLineHeadIndent,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_headIndent);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,&cfstr_headIndent,
                                      pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar26 = cls_NSNumber;
              pvVar23 = _objc_msgSend(pvVar24,sel_lineBreakMode);
              pvVar23 = _objc_msgSend(puVar26,sel_numberWithInt_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              pvVar23 = _objc_msgSend(pvVar23,sel_intValue);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr__d,pvVar23);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_lineBreakMode,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_lineHeightMultiple);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_lineHeightMultiple,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_lineSpacing);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,&cfstr_lineSpacing,
                                      pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_maximumLineHeight);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_maximumLineHeight,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_minimumLineHeight);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_minimumLineHeight,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_paragraphSpacing);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_paragraphSpacing,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_paragraphSpacingBefore);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_paragraphSpacingBefore,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_tailIndent);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,&cfstr_tailIndent,
                                      pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              pvVar23 = _objc_msgSend(pvVar24,sel_tabStops);
              pvVar23 = _objc_msgSend(pvVar23,sel_componentsJoinedByString_,&cfstr__);
              pvVar23 = _objc_msgSend(cls_NSXMLNode,sel_attributeWithName_stringValue_,
                                      &cfstr_tabStop,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_tighteningFactorForTruncation);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr__f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_tighteningFactorForTruncation,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_hyphenationFactor);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr__f,dVar31);
              uVar32 = (undefined4)((ulonglong)dVar31 >> 0x20);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,
                                      &cfstr_hyphenationFactor,pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar26 = cls_NSString;
              pvVar23 = _objc_msgSend(pvVar24,sel_headerLevel);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr__d,pvVar23);
              uVar34 = CONCAT44(uVar32,pvVar23);
              pcVar33 = &cfstr_headerLevel;
              goto LAB_0028b0c9;
            }
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,*(undefined4 *)puVar7);
            puVar27 = cls_NSXMLNode;
            puVar26 = cls_NSString;
            if ((char)pvVar25 != '\0') {
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_shadowBlurRadius);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___1f,dVar31);
              pvVar23 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,&cfstr_blur,pvVar23
                                     );
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar22 = cls_NSXMLNode;
              puVar27 = cls_NSShadow;
              puVar26 = cls_NSString;
              pvVar23 = _objc_msgSend(pvVar24,sel_shadowOffset);
              dVar31 = _objc_msgSend_fpret(puVar27,sel_hyperShadowAngleWithShadowOffset_,pvVar23,
                                           extraout_EDX);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___1f,
                                      (dVar31 * 180.0) / 3.141592653589793);
              pvVar23 = _objc_msgSend(puVar22,sel_attributeWithName_stringValue_,&cfstr_angle,
                                      pvVar23);
              _objc_msgSend(self_04,sel_addAttribute_,pvVar23);
              puVar27 = cls_NSXMLNode;
              puVar22 = cls_NSShadow;
              puVar26 = cls_NSString;
              pvVar23 = _objc_msgSend(pvVar24,sel_shadowOffset);
              dVar31 = _objc_msgSend_fpret(puVar22,sel_hyperShadowDistanceWithShadowOffset_,pvVar23,
                                           extraout_EDX_00);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___1f,dVar31);
              uVar34 = CONCAT44((int)((ulonglong)dVar31 >> 0x20),pvVar23);
              pcVar33 = &cfstr_distance;
              goto LAB_0028b0c9;
            }
            uVar32 = *(undefined4 *)puVar18;
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
            puVar26 = cls_NSXMLNode;
            puVar27 = cls_NSString;
            if ((char)pvVar25 != '\0') {
              pvVar23 = _objc_msgSend(pvVar24,sel_intValue,uVar32);
              uVar32 = (undefined4)((ulonglong)uVar34 >> 0x20);
              pvVar23 = _objc_msgSend(puVar27,sel_stringWithFormat_,&cfstr__d,pvVar23);
              uVar34 = CONCAT44(uVar32,pvVar23);
              pcVar33 = &cfstr_strikethroughStyle;
              goto LAB_0028b033;
            }
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,*(undefined4 *)puVar9);
            puVar27 = cls_NSXMLNode;
            puVar26 = cls_NSString;
            if ((char)pvVar25 != '\0') {
              dVar31 = _objc_msgSend_fpret(pvVar24,sel_floatValue);
              pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___1f,dVar31);
              uVar34 = CONCAT44((int)((ulonglong)dVar31 >> 0x20),pvVar23);
              pcVar33 = &cfstr_strokeWidth;
              goto LAB_0028b0c9;
            }
            uVar32 = *(undefined4 *)puVar19;
            pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
            puVar26 = cls_NSXMLNode;
            puVar27 = cls_NSString;
            if ((char)pvVar25 == '\0') {
              pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,*(undefined4 *)puVar20);
              if ((char)pvVar25 != '\0') {
                uVar34 = CONCAT44((int)((ulonglong)uVar34 >> 0x20),pvVar24);
                pcVar33 = &cfstr_toolTip;
                puVar26 = cls_NSXMLNode;
                goto LAB_0028b033;
              }
              uVar32 = *(undefined4 *)puVar10;
              pvVar25 = _objc_msgSend(pvVar23,sel_isEqualToString_,uVar32);
              puVar26 = cls_NSXMLNode;
              puVar27 = cls_NSString;
              if ((char)pvVar25 != '\0') {
                pvVar23 = _objc_msgSend(pvVar24,sel_intValue,uVar32);
                uVar32 = (undefined4)((ulonglong)uVar34 >> 0x20);
                pvVar23 = _objc_msgSend(puVar27,sel_stringWithFormat_,&cfstr__d,pvVar23);
                uVar34 = CONCAT44(uVar32,pvVar23);
                pcVar33 = &cfstr_underline;
                goto LAB_0028b033;
              }
              pvVar25 = *(id *)puVar15;
              pvVar23 = _objc_msgSend(pvVar23,sel_isEqualToString_,pvVar25);
              if ((char)pvVar23 == '\0') goto LAB_0028c156;
              pvVar23 = _objc_msgSend(cls_NSURL,sel_class,pvVar25);
              uVar32 = (undefined4)((ulonglong)uVar34 >> 0x20);
              pvVar25 = _objc_msgSend(pvVar24,sel_isKindOfClass_,pvVar23);
              if ((char)pvVar25 != '\0') {
                local_48._0_4_ = _objc_msgSend(pvVar24,sel_absoluteString,pvVar23);
              }
              uVar34 = CONCAT44(uVar32,local_48._0_4_);
              self_05 = _objc_msgSend(cls_NSXMLNode,sel_attributeWithName_stringValue_,&cfstr_link,
                                      local_48._0_4_);
              op = sel_addAttribute_;
              goto LAB_0028c14b;
            }
            pvVar23 = _objc_msgSend(pvVar24,sel_intValue,uVar32);
            uVar32 = (undefined4)((ulonglong)uVar34 >> 0x20);
            pvVar23 = _objc_msgSend(puVar27,sel_stringWithFormat_,&cfstr__d,pvVar23);
            uVar34 = CONCAT44(uVar32,pvVar23);
            pcVar33 = &cfstr_superscript;
            goto LAB_0028b033;
          }
          dVar31 = _objc_msgSend_fpret(pvVar24,sel_floatValue);
          pvVar23 = _objc_msgSend(puVar26,sel_stringWithFormat_,&cfstr___8f,dVar31);
          uVar34 = CONCAT44((int)((ulonglong)dVar31 >> 0x20),pvVar23);
          pcVar33 = &cfstr_baselineOffset;
LAB_0028b0c9:
          pvVar25 = _objc_msgSend(puVar27,sel_attributeWithName_stringValue_,pcVar33,uVar34);
          _objc_msgSend(self_04,sel_addAttribute_,pvVar25);
        }
        else {
LAB_0028ac64:
          pvVar25 = _objc_msgSend(cls_HSGradientColor,sel_class,uVar32);
          pvVar23 = _objc_msgSend(pvVar24,sel_isKindOfClass_,pvVar25);
          if ((char)pvVar23 == '\0') {
            pvVar23 = _objc_msgSend(pvVar24,sel_colorSpaceName,pvVar25);
            pvVar23 = _objc_msgSend(pvVar23,sel_isEqualToString_,*(undefined4 *)puVar5);
            if ((char)pvVar23 == '\0') {
              pvVar23 = _objc_msgSend(pvVar24,sel_colorUsingColorSpaceName_,*(undefined4 *)puVar3);
              if (pvVar23 == (id)0x0) {
                dVar31 = 1.0;
                dVar29 = 0.0;
                dVar28 = 0.0;
                dVar30 = dVar28;
              }
              else {
                dVar28 = _objc_msgSend_fpret(pvVar23,sel_redComponent);
                local_48._0_10_ = (unkbyte10)dVar28;
                dVar29 = _objc_msgSend_fpret(pvVar23,sel_greenComponent);
                dVar30 = _objc_msgSend_fpret(pvVar23,sel_blueComponent);
                dVar31 = _objc_msgSend_fpret(pvVar23,sel_alphaComponent);
              }
              pvVar23 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr___8f___8f___8f___8f,
                                      dVar28,dVar29,dVar30,dVar31);
              uVar34 = CONCAT44((int)((ulonglong)dVar28 >> 0x20),pvVar23);
              pcVar33 = &cfstr_color;
              puVar26 = cls_NSXMLNode;
LAB_0028b033:
              self_05 = _objc_msgSend(puVar26,sel_attributeWithName_stringValue_,pcVar33,uVar34);
              op = sel_addAttribute_;
LAB_0028c14b:
              _objc_msgSend(self_04,op,self_05,uVar34);
              pvVar25 = self_05;
            }
            else {
              pvVar25 = *(id *)puVar5;
              pvVar23 = _objc_msgSend(pvVar24,sel_colorUsingColorSpaceName_,pvVar25);
              local_48._0_4_ = _objc_msgSend(pvVar23,sel_patternImage);
              if ((id)local_48._0_4_ != (id)0x0) {
                pvVar23 = _objc_msgSend(UID,sel_stringValue,pvVar25);
                uVar34 = CONCAT44((int)((ulonglong)uVar34 >> 0x20),substring);
                pvVar23 = _objc_msgSend(pvVar23,sel_stringByAppendingFormat_,&cfstr_____textureImage
                                        ,substring);
                pvVar23 = _objc_msgSend(pvVar23,sel_stringByAppendingPathExtension_,&cfstr_png);
                pvVar25 = pvVar23;
                pvVar24 = _objc_msgSend(hyperXMLNodeRepresentationInContext,
                                        sel_convertedMediaForKey_,pvVar23);
                puVar26 = cls_HSNewMedia;
                if (pvVar24 == (id)0x0) {
                  pvVar25 = _objc_msgSend((id)local_48._0_4_,sel_hyperPNGRepresentation,pvVar25,
                                          uVar34);
                  uVar34 = CONCAT44(&cfstr_png,pvVar23);
                  pvVar24 = _objc_msgSend(puVar26,sel_mediaWithData_name_type_,pvVar25,pvVar23);
                  if (pvVar24 != (id)0x0) {
                    uVar34 = CONCAT44((int)((ulonglong)uVar34 >> 0x20),pvVar23);
                    pvVar25 = pvVar24;
                    _objc_msgSend(hyperXMLNodeRepresentationInContext,sel_setConvertedMedia_forKey_,
                                  pvVar24,pvVar23);
                  }
                }
                if (pvVar24 != (id)0x0) {
                  _objc_msgSend(hyperXMLNodeRepresentationInContext,sel_addMedia_,pvVar24,uVar34);
                  uVar32 = (undefined4)((ulonglong)uVar34 >> 0x20);
                  self_05 = _objc_msgSend(cls_NSXMLElement,sel_elementWithName_,
                                          &cfstr_textureMediaRef);
                  puVar26 = cls_NSXMLNode;
                  local_48._0_4_ = cls_NSXMLNode;
                  pvVar23 = _objc_msgSend(pvVar24,sel_mediaUID);
                  pvVar23 = _objc_msgSend(pvVar23,sel_stringValue);
                  uVar34 = CONCAT44(uVar32,pvVar23);
                  pvVar23 = _objc_msgSend(puVar26,sel_attributeWithName_stringValue_,&cfstr_refId,
                                          pvVar23);
                  _objc_msgSend(self_05,sel_addAttribute_,pvVar23);
                  op = sel_addChild_;
                  goto LAB_0028c14b;
                }
              }
            }
          }
          else {
            pvVar23 = _objc_msgSend(pvVar24,sel_hyperHSColor,pvVar25);
            pvVar24 = _objc_msgSend(pvVar23,sel_canBeStoredAsXMLElement);
            if ((char)pvVar24 != '\0') {
              pvVar25 = hyperXMLNodeRepresentationInContext;
              self_05 = _objc_msgSend(pvVar23,sel_XMLElementRepresentationInContext_,
                                      hyperXMLNodeRepresentationInContext);
              pvVar23 = _objc_msgSend(self_05,sel_attributes);
              pvVar23 = _objc_msgSend(pvVar23,sel_count);
              op = sel_addChild_;
              if (pvVar23 != (id)0x0) goto LAB_0028c14b;
            }
          }
        }
LAB_0028c156:
        pvVar23 = _objc_msgSend(self_04,sel_attributes,pvVar25,uVar34);
        pvVar23 = _objc_msgSend(pvVar23,sel_count);
        if ((pvVar23 != (id)0x0) ||
           (pvVar23 = _objc_msgSend(self_04,sel_childCount,pvVar25), pvVar23 != (id)0x0)) {
          _objc_msgSend(self_00,sel_addChild_,self_04);
          pvVar25 = self_04;
        }
      }
      pvVar23 = _objc_msgSend(self_03,sel_nextObject,pvVar25);
    }
  }
  return self_00;
}

*/
- (id)hyperXMLNodeRepresentationInContext:(id)aContext UID:(id)aUID attributes:(id)aAttributes substring:(id)aSubstring
{
    if ([aSubstring length] == 0) {
        return nil;
    }
    NSXMLElement *result = [NSXMLElement elementWithName:@"substringAttributes"];
    [result addChild:[NSXMLElement elementWithName:@"substring" stringValue:aSubstring]];
    NSDictionary *storable = [NSAttributedString hyperAcceptableStringKeysAndAttributesForStoring];
    NSArray *storableKeys = [storable allKeys];
    NSEnumerator *enumerator = [aAttributes keyEnumerator];
    NSString *key;
    while ((key = [enumerator nextObject]) != nil) {
        if (![storableKeys containsObject:key]) {
            continue;
        }
        id value = [aAttributes objectForKey:key];
        NSXMLElement *node = [NSXMLElement elementWithName:[storable objectForKey:key]];
        if ([key isEqualToString:NSBackgroundColorAttributeName] || [key isEqualToString:NSForegroundColorAttributeName] || [key isEqualToString:NSStrikethroughColorAttributeName] || [key isEqualToString:NSStrokeColorAttributeName] || [key isEqualToString:NSUnderlineColorAttributeName]) {
            if ([value isKindOfClass:[HSGradientColor class]]) {
                id hsColor = [value hyperHSColor];
                if ([hsColor canBeStoredAsXMLElement]) {
                    id colorElement = [hsColor XMLElementRepresentationInContext:aContext];
                    if ([[colorElement attributes] count] != 0) {
                        [node addChild:colorElement];
                    }
                }
            } else if (![[value colorSpaceName] isEqualToString:NSPatternColorSpace]) {
                NSColor *rgbColor = [value colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
                double red = 0.0;
                double green = 0.0;
                double blue = 0.0;
                double alpha = 1.0;
                if (rgbColor != nil) {
                    red = [rgbColor redComponent];
                    green = [rgbColor greenComponent];
                    blue = [rgbColor blueComponent];
                    alpha = [rgbColor alphaComponent];
                }
                [node addAttribute:[NSXMLNode attributeWithName:@"color" stringValue:[NSString stringWithFormat:@"%.8f,%.8f,%.8f,%.8f", red, green, blue, alpha]]];
            } else {
                NSImage *image = [[value colorUsingColorSpaceName:NSPatternColorSpace] patternImage];
                if (image != nil) {
                    NSString *name = [[[aUID stringValue] stringByAppendingFormat:@"_%@_textureImage", aSubstring] stringByAppendingPathExtension:@"png"];
                    id media = [aContext convertedMediaForKey:name];
                    if (media == nil) {
                        media = [HSNewMedia mediaWithData:[image hyperPNGRepresentation] name:name type:@"png"];
                        if (media != nil) {
                            [aContext setConvertedMedia:media forKey:name];
                        }
                    }
                    if (media != nil) {
                        [aContext addMedia:media];
                        NSXMLElement *reference = [NSXMLElement elementWithName:@"textureMediaRef"];
                        [reference addAttribute:[NSXMLNode attributeWithName:@"refId" stringValue:[[media mediaUID] stringValue]]];
                        [node addChild:reference];
                    }
                }
            }
        } else if ([key isEqualToString:NSBaselineOffsetAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"baselineOffset" stringValue:[NSString stringWithFormat:@"%.8f", [value floatValue]]]];
        } else if ([key isEqualToString:NSExpansionAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"expansionFactor" stringValue:[NSString stringWithFormat:@"%.8f", [value floatValue]]]];
        } else if ([key isEqualToString:NSFontAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"fontName" stringValue:[value fontName]]];
            [node addAttribute:[NSXMLNode attributeWithName:@"fontSize" stringValue:[NSString stringWithFormat:@"%.0f", [value pointSize]]]];
            [node addAttribute:[NSXMLNode attributeWithName:@"fontFamily" stringValue:[value familyName]]];
        } else if ([key isEqualToString:NSKernAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"kernAmount" stringValue:[NSString stringWithFormat:@"%.8f", [value floatValue]]]];
        } else if ([key isEqualToString:NSLigatureAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"ligatures" stringValue:[NSString stringWithFormat:@"%d", [value intValue]]]];
        } else if ([key isEqualToString:NSObliquenessAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"obliqueness" stringValue:[NSString stringWithFormat:@"%.8f", [value floatValue]]]];
        } else if ([key isEqualToString:NSParagraphStyleAttributeName]) {
                [node addAttribute:[NSXMLNode attributeWithName:@"alignment" stringValue:[NSString stringWithFormat:@"%d", (int)[value alignment]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"baseWritingDirection" stringValue:[NSString stringWithFormat:@"%d", (int)[value baseWritingDirection]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"defaultTabInterval" stringValue:[NSString stringWithFormat:@"%.1f", [value defaultTabInterval]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"firstLineHeadIndent" stringValue:[NSString stringWithFormat:@"%.8f", [value firstLineHeadIndent]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"headIndent" stringValue:[NSString stringWithFormat:@"%.8f", [value headIndent]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"lineBreakMode" stringValue:[NSString stringWithFormat:@"%d", (int)[value lineBreakMode]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"lineHeightMultiple" stringValue:[NSString stringWithFormat:@"%.8f", [value lineHeightMultiple]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"lineSpacing" stringValue:[NSString stringWithFormat:@"%.8f", [value lineSpacing]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"maximumLineHeight" stringValue:[NSString stringWithFormat:@"%.8f", [value maximumLineHeight]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"minimumLineHeight" stringValue:[NSString stringWithFormat:@"%.8f", [value minimumLineHeight]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"paragraphSpacing" stringValue:[NSString stringWithFormat:@"%.8f", [value paragraphSpacing]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"paragraphSpacingBefore" stringValue:[NSString stringWithFormat:@"%.8f", [value paragraphSpacingBefore]]]];
                [node addAttribute:[NSXMLNode attributeWithName:@"tailIndent" stringValue:[NSString stringWithFormat:@"%.8f", [value tailIndent]]]];
            [node addAttribute:[NSXMLNode attributeWithName:@"tabStop" stringValue:[[value tabStops] componentsJoinedByString:@","]]];
            [node addAttribute:[NSXMLNode attributeWithName:@"tighteningFactorForTruncation" stringValue:[NSString stringWithFormat:@"%f", [value tighteningFactorForTruncation]]]];
            [node addAttribute:[NSXMLNode attributeWithName:@"hyphenationFactor" stringValue:[NSString stringWithFormat:@"%f", [value hyphenationFactor]]]];
            [node addAttribute:[NSXMLNode attributeWithName:@"headerLevel" stringValue:[NSString stringWithFormat:@"%d", (int)[value headerLevel]]]];
        } else if ([key isEqualToString:NSShadowAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"blur" stringValue:[NSString stringWithFormat:@"%.1f", [value shadowBlurRadius]]]];
            double angle = [NSShadow hyperShadowAngleWithShadowOffset:[value shadowOffset]];
            [node addAttribute:[NSXMLNode attributeWithName:@"angle" stringValue:[NSString stringWithFormat:@"%.1f", (angle * 180.0) / 3.141592653589793]]];
            double distance = [NSShadow hyperShadowDistanceWithShadowOffset:[value shadowOffset]];
            [node addAttribute:[NSXMLNode attributeWithName:@"distance" stringValue:[NSString stringWithFormat:@"%.1f", distance]]];
        } else if ([key isEqualToString:NSStrikethroughStyleAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"strikethroughStyle" stringValue:[NSString stringWithFormat:@"%d", [value intValue]]]];
        } else if ([key isEqualToString:NSStrokeWidthAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"strokeWidth" stringValue:[NSString stringWithFormat:@"%.1f", [value floatValue]]]];
        } else if ([key isEqualToString:NSSuperscriptAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"superscript" stringValue:[NSString stringWithFormat:@"%d", [value intValue]]]];
        } else if ([key isEqualToString:NSToolTipAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"toolTip" stringValue:value]];
        } else if ([key isEqualToString:NSUnderlineStyleAttributeName]) {
            [node addAttribute:[NSXMLNode attributeWithName:@"underline" stringValue:[NSString stringWithFormat:@"%d", [value intValue]]]];
        } else if ([key isEqualToString:NSLinkAttributeName]) {
            NSString *link = value;
            if ([value isKindOfClass:[NSURL class]]) {
                link = [value absoluteString];
            }
            [node addAttribute:[NSXMLNode attributeWithName:@"link" stringValue:link]];
        }
        if ([[node attributes] count] != 0 || [node childCount] != 0) {
            [result addChild:node];
        }
    }
    return result;
    return 0;
}

@end

