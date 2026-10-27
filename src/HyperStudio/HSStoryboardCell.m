#import "HSStoryboardCell.h"

static unsigned int sIndexWidthsByDigits[10];
static unsigned int sIndexHeight = 0;
static NSDictionary *sIndexRenderingAttributes = nil;
static NSDictionary *sTitleRenderingAttributes = nil;
static BOOL sHasRolloverCornerRadius = NO;
static float sRolloverCornerRadius;
static BOOL sHasDefaultTitleSize = NO;
static NSSize sDefaultTitleSize;

// The original's relative float comparison: within 0.0005 of the larger magnitude
// (a zero value counts as magnitude 1).
static float HSStoryboardCellMagnitude(float aValue)
{
    return aValue != 0.0f ? fabsf(aValue) : 1.0f;
}

static BOOL HSStoryboardCellNearlyEqual(float aValue, float aOther)
{
    return fabsf(aValue - aOther) <= fmaxf(HSStoryboardCellMagnitude(aValue), HSStoryboardCellMagnitude(aOther)) * 0.0005f;
}

static BOOL HSStoryboardCellSizesNearlyEqual(NSSize aSize, NSSize aOther)
{
    return HSStoryboardCellNearlyEqual((float)aSize.width, (float)aOther.width) && HSStoryboardCellNearlyEqual((float)aSize.height, (float)aOther.height);
}

static BOOL HSStoryboardCellRectsNearlyEqual(NSRect aRect, NSRect aOther)
{
    float xScale = fmaxf(HSStoryboardCellMagnitude((float)(fabs(aRect.origin.x) + aRect.size.width)), HSStoryboardCellMagnitude((float)(fabs(aOther.origin.x) + aOther.size.width))) * 0.0005f;
    float yScale = fmaxf(HSStoryboardCellMagnitude((float)(fabs(aRect.origin.y) + aRect.size.height)), HSStoryboardCellMagnitude((float)(fabs(aOther.origin.y) + aOther.size.height))) * 0.0005f;
    return fabs(aRect.origin.x - aOther.origin.x) <= xScale && fabs(aRect.origin.y - aOther.origin.y) <= yScale
        && fabs(aRect.size.width - aOther.size.width) <= xScale && fabs(aRect.size.height - aOther.size.height) <= yScale;
}

@implementation HSStoryboardCell

/* i386 ivar offsets: _cardBorderRenderer=0x4, _textStorage=0x8, _layoutManager=0xc, _textContainer=0x10, _itemFrameSize=0x14, _cardImageFrame=0x1c, _cardTitleFrame=0x2c, _cardIndexFrame=0x3c, _requiredWidth=0x4c, _requiredHeight=0x50, _boundsWidth=0x54, _maxCardsPerRow=0x58, _numberOfItems=0x5c, _canRecacheCardThumbnail=0x60, _shouldDrawBadgedIcons=0x61, _storyboardLayout=0x64, _auxiliaryUserObjectTraits=0x68 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008f809 @ 0008f809, 103 bytes * /

ulonglong FUN_0008f809(id self,SEL _cmd,uint requiredRenderingSizeForNumberOfItems)

{
  id pvVar1;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr__u,
                         requiredRenderingSizeForNumberOfItems);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  pvVar1 = _objc_msgSend(self,sel_requiredSizeForNumberOfDigits_,pvVar1);
  return CONCAT44(extraout_EDX,pvVar1);
}

*/
+ (NSSize)requiredRenderingSizeForNumberOfItems:(NSUInteger)aItems
{
    return [self requiredSizeForNumberOfDigits:[[NSString stringWithFormat:@"%u", (unsigned int)aItems] length]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008f870 @ 0008f870, 239 bytes * /

ulonglong FUN_0008f870(id self,SEL _cmd,uint requiredSizeForNumberOfDigits)

{
  id pvVar1;
  uint uVar2;
  float extraout_EDX;
  uint uVar3;
  
  uVar3 = 9;
  if (requiredSizeForNumberOfDigits < 10) {
    uVar3 = requiredSizeForNumberOfDigits;
  }
  if (*(int *)(&DAT_00342850 + uVar3 * 4) == 0) {
    uVar2 = 1;
    if (uVar3 != 0) {
      uVar2 = uVar3;
    }
    pvVar1 = _objc_msgSend(self,sel_calculateRequiredSizeForNumberOfDigits_,uVar2);
    uVar2 = (int)(float)pvVar1;
    if (2.1474836e+09 <= (float)pvVar1) {
      uVar2 = (int)((float)pvVar1 - 2.1474836e+09) ^ 0x80000000;
    }
    *(uint *)(&DAT_00342850 + uVar3 * 4) = uVar2;
    if (DAT_00342878 == 0) {
      DAT_00342878 = (int)extraout_EDX;
      if (2.1474836e+09 <= extraout_EDX) {
        DAT_00342878 = (int)(extraout_EDX - 2.1474836e+09) ^ 0x80000000;
      }
    }
  }
  return CONCAT44((float)((double)((ulonglong)DAT_00342878 | 0x4330000000000000) -
                         4503599627370496.0),
                  (float)((double)((ulonglong)*(uint *)(&DAT_00342850 + uVar3 * 4) |
                                  0x4330000000000000) - 4503599627370496.0));
}

*/
+ (NSSize)requiredSizeForNumberOfDigits:(NSUInteger)aDigits
{
    NSUInteger digits = aDigits < 10 ? aDigits : 9;
    if (sIndexWidthsByDigits[digits] == 0) {
        NSSize size = [self calculateRequiredSizeForNumberOfDigits:(digits != 0 ? digits : 1)];
        sIndexWidthsByDigits[digits] = (unsigned int)size.width;
        if (sIndexHeight == 0) {
            sIndexHeight = (unsigned int)size.height;
        }
    }
    return NSMakeSize(sIndexWidthsByDigits[digits], sIndexHeight);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008f95f @ 0008f95f, 304 bytes * /

ulonglong FUN_0008f95f(id self,SEL _cmd,uint calculateRequiredSizeForNumberOfDigits)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  undefined4 extraout_EDX;
  uint uVar3;
  undefined4 uVar4;
  
  pvVar1 = *(id *)PTR_0033607c;
  uVar4 = *(undefined4 *)(PTR_0033607c + 4);
  if (calculateRequiredSizeForNumberOfDigits != 0) {
    pvVar1 = _objc_msgSend(cls_NSMutableData,sel_dataWithLength_,
                           calculateRequiredSizeForNumberOfDigits * 2);
    uVar3 = 0;
    pvVar1 = _objc_msgSend(pvVar1,sel_mutableBytes);
    do {
      *(undefined2 *)((int)pvVar1 + uVar3 * 2) = 0x30;
      uVar3 = uVar3 + 1;
    } while (calculateRequiredSizeForNumberOfDigits != uVar3);
    pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithCharacters_length_,pvVar1,
                           calculateRequiredSizeForNumberOfDigits);
    self_00 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
    pvVar2 = _objc_msgSend(self,sel_indexRenderingAttributes);
    pvVar1 = _objc_msgSend(self_00,sel_initWithString_attributes_,pvVar1,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    pvVar1 = _objc_msgSend(cls_NSTextStorage,
                           sel_hyperSizeForAttributedString_withWidth_fixedWidth_padding_,pvVar1,
                           0x49742400,0,0);
    uVar4 = extraout_EDX;
  }
  return CONCAT44(uVar4,pvVar1);
}

*/
+ (NSSize)calculateRequiredSizeForNumberOfDigits:(NSUInteger)aDigits
{
    if (aDigits == 0) {
        return NSZeroSize;
    }
    NSMutableData *data = [NSMutableData dataWithLength:aDigits * sizeof(unichar)];
    unichar *characters = [data mutableBytes];
    for (NSUInteger i = 0; i < aDigits; i++) {
        characters[i] = '0';
    }
    NSString *zeros = [NSString stringWithCharacters:characters length:aDigits];
    NSAttributedString *string = [[[NSAttributedString alloc] initWithString:zeros attributes:[self indexRenderingAttributes]] autorelease];
    return [NSTextStorage hyperSizeForAttributedString:string withWidth:1000000.0 fixedWidth:NO padding:NO];
}

+ (NSUInteger)defaultLineHeightWithLayoutManager:(id)aManager
{
    unsigned int uVar2;
    double dVar3;

    dVar3 = [aManager defaultLineHeightForFont:[HSStoryboardCell titleFont]];
    uVar2 = (int)dVar3;
    if (2.1474836e+09 <= (float)dVar3) {
        uVar2 = (int)((float)dVar3 - 2.1474836e+09) ^ 0x80000000;
    }
    return uVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008fafe @ 0008fafe, 250 bytes * /

uint FUN_0008fafe(id self,SEL _cmd,id minimalAcceptableWidthForTitleStringWithTextStorage)

{
  id pvVar1;
  id pvVar2;
  uint uVar3;
  
  pvVar1 = _objc_msgSend(minimalAcceptableWidthForTitleStringWithTextStorage,sel_length);
  _objc_msgSend(minimalAcceptableWidthForTitleStringWithTextStorage,
                sel_replaceCharactersInRange_withString_,0,pvVar1,&cfstr_Card_10_);
  pvVar1 = _objc_msgSend(minimalAcceptableWidthForTitleStringWithTextStorage,sel_length);
  pvVar2 = _objc_msgSend(self,sel_titleRenderingAttributes);
  _objc_msgSend(minimalAcceptableWidthForTitleStringWithTextStorage,sel_setAttributes_range_,pvVar2,
                0,pvVar1);
  pvVar1 = _objc_msgSend(cls_NSTextStorage,sel_hyperSizeForTextStorage_withWidth_fixedWidth_padding_
                         ,minimalAcceptableWidthForTitleStringWithTextStorage,0x49742400,0,0);
  uVar3 = (int)(float)pvVar1;
  if (2.1474836e+09 <= (float)pvVar1) {
    uVar3 = (int)((float)pvVar1 - 2.1474836e+09) ^ 0x80000000;
  }
  return uVar3;
}

*/
+ (NSUInteger)minimalAcceptableWidthForTitleStringWithTextStorage:(id)aStorage
{
    [aStorage replaceCharactersInRange:NSMakeRange(0, [aStorage length]) withString:@"Card 10\n"];
    [aStorage setAttributes:[self titleRenderingAttributes] range:NSMakeRange(0, [aStorage length])];
    return (NSUInteger)[NSTextStorage hyperSizeForTextStorage:aStorage withWidth:1000000.0 fixedWidth:NO padding:NO].width;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008fbf8 @ 0008fbf8, 278 bytes * /

id FUN_0008fbf8(id self,SEL _cmd)

{
  undefined4 uVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  double dVar4;
  
  if (DAT_00342890 == (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_titleRenderingAttributes);
    pvVar2 = _objc_msgSend(pvVar2,sel_mutableCopy);
    uVar1 = *(undefined4 *)PTR_00336150;
    pvVar3 = _objc_msgSend(cls_NSParagraphStyle,sel_hyperParagraphStyleWithAlignment_,1);
    _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar3,uVar1);
    self_00 = cls_NSFont;
    uVar1 = *(undefined4 *)PTR_00336068;
    dVar4 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
    pvVar3 = _objc_msgSend(self_00,sel_systemFontOfSize_,(float)dVar4);
    _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar3,uVar1);
    DAT_00342890 = _objc_msgSend(pvVar2,sel_copy);
    _objc_msgSend(pvVar2,sel_release);
  }
  return DAT_00342890;
}

*/
+ (id)indexRenderingAttributes
{
    if (sIndexRenderingAttributes == nil) {
        NSMutableDictionary *attributes = [[self titleRenderingAttributes] mutableCopy];
        [attributes setObject:[NSParagraphStyle hyperParagraphStyleWithAlignment:NSTextAlignmentRight] forKey:NSParagraphStyleAttributeName];
        [attributes setObject:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]] forKey:NSFontAttributeName];
        sIndexRenderingAttributes = [attributes copy];
        [attributes release];
    }
    return sIndexRenderingAttributes;
}

+ (id)selectedTitleRenderingAttributes
{
    return [self titleRenderingAttributes];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008fd34 @ 0008fd34, 248 bytes * /

id FUN_0008fd34(id self,SEL _cmd)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  
  if (DAT_00342840 == (id)0x0) {
    self_00 = _objc_msgSend(cls_NSDictionary,sel_alloc);
    uVar1 = *(undefined4 *)PTR_00336150;
    pvVar4 = _objc_msgSend(cls_NSParagraphStyle,sel_hyperParagraphStyleWithAlignment_,2);
    uVar2 = *(undefined4 *)PTR_00336394;
    pvVar5 = _objc_msgSend(cls_NSColor,sel_whiteColor);
    uVar3 = *(undefined4 *)PTR_00336068;
    pvVar6 = _objc_msgSend(self,sel_titleFont);
    DAT_00342840 = _objc_msgSend(self_00,sel_initWithObjectsAndKeys_,pvVar6,uVar3,pvVar5,uVar2,
                                 pvVar4,uVar1,0);
  }
  return DAT_00342840;
}

*/
+ (id)titleRenderingAttributes
{
    if (sTitleRenderingAttributes == nil) {
        sTitleRenderingAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:[self titleFont], NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, [NSParagraphStyle hyperParagraphStyleWithAlignment:NSTextAlignmentCenter], NSParagraphStyleAttributeName, nil];
    }
    return sTitleRenderingAttributes;
}

+ (id)titleFont
{
    return [NSFont boldSystemFontOfSize:(float)[NSFont smallSystemFontSize]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008fe6f @ 0008fe6f, 1035 bytes * /

ulonglong FUN_0008fe6f(id self,SEL _cmd,NSSize storyboardItemSizeForCardSize,uint itemsCount,
                      NSPoint *offset,NSRect *titleRect,NSRect *cardIndexRect,
                      NSSize defaultTitleSize)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float fVar3;
  float fVar4;
  float local_84;
  float local_80;
  float local_7c;
  float local_78;
  float local_74;
  float local_70;
  undefined4 local_6c;
  undefined4 local_68;
  float local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  float local_54;
  float fStack_50;
  float local_4c;
  float fStack_48;
  float local_44;
  float fStack_40;
  id local_3c;
  float fStack_38;
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  undefined1 local_24 [20];
  
  fVar3 = *(float *)PTR_00336074;
  fStack_30 = *(float *)(PTR_00336074 + 4);
  local_2c = storyboardItemSizeForCardSize.width;
  fStack_28 = storyboardItemSizeForCardSize.height;
  local_34 = fVar3;
  pvVar1 = _objc_msgSend(cls_HSCardBorderRenderer,sel_borderInsetForCardThumbnailSize_,
                         storyboardItemSizeForCardSize.width,storyboardItemSizeForCardSize.height);
  pvVar2 = _objc_msgSend(cls_HSCardBorderRenderer,sel_selectedBorderInsetForCardThumbnailSize_,
                         storyboardItemSizeForCardSize.width,storyboardItemSizeForCardSize.height);
  fVar4 = extraout_EDX_00;
  if (extraout_EDX_00 <= extraout_EDX) {
    fVar4 = extraout_EDX;
  }
  if ((float)pvVar2 <= (float)pvVar1) {
    pvVar2 = pvVar1;
  }
  _NSInsetRect(&local_34,local_34,fStack_30,local_2c,fStack_28,(uint)pvVar2 ^ 0x80000000,-fVar4);
  local_44 = *(float *)PTR_00336078;
  fStack_40 = *(float *)(PTR_00336078 + 4);
  local_3c = *(id *)(PTR_00336078 + 8);
  fStack_38 = *(float *)(PTR_00336078 + 0xc);
  local_3c = _objc_msgSend(self,sel_requiredRenderingSizeForNumberOfItems_,itemsCount);
  fStack_40 = 0.0;
  local_44 = (local_34 + -2.0) - (float)local_3c;
  if (storyboardItemSizeForCardSize.width <= defaultTitleSize.width) {
    storyboardItemSizeForCardSize.width = defaultTitleSize.width;
  }
  local_54 = ((local_2c * 0.5 + local_34) - (storyboardItemSizeForCardSize.width * 0.5 + fVar3)) +
             fVar3;
  fStack_48 = defaultTitleSize.height;
  fStack_50 = fStack_30 + fStack_28 + 2.0;
  local_4c = storyboardItemSizeForCardSize.width;
  fStack_38 = extraout_EDX_01;
  _NSUnionRect(local_24,local_44,0,local_3c,extraout_EDX_01,local_54,fStack_50,
               storyboardItemSizeForCardSize.width,defaultTitleSize.height);
  _NSUnionRect(&local_64,local_34,fStack_30,local_2c,fStack_28,(int)local_24._0_8_,
               SUB84(local_24._0_8_,4),(int)local_24._8_8_,SUB84(local_24._8_8_,4));
  local_34 = local_64;
  fStack_30 = (float)local_60;
  local_2c = (float)local_5c;
  fStack_28 = (float)local_58;
  _NSInsetRect(&local_74,local_64,local_60,local_5c,local_58,0xc0a00000,0xc0800000);
  local_34 = local_74;
  fStack_30 = local_70;
  local_2c = (float)local_6c;
  fStack_28 = (float)local_68;
  fVar4 = -local_70;
  fVar3 = -local_74;
  _NSOffsetRect(&local_84,local_54,fStack_50,local_4c,fStack_48,fVar3,fVar4);
  local_54 = local_84;
  fStack_50 = local_80;
  local_4c = local_7c;
  fStack_48 = local_78;
  _NSOffsetRect(&local_44,local_44,fStack_40,local_3c,fStack_38,fVar3,fVar4);
  if (titleRect != (NSRect *)0x0) {
    (titleRect->origin).x = local_54;
    (titleRect->origin).y = fStack_50;
    (titleRect->size).width = local_4c;
    (titleRect->size).height = fStack_48;
  }
  if (cardIndexRect != (NSRect *)0x0) {
    (cardIndexRect->origin).x = local_44;
    (cardIndexRect->origin).y = fStack_40;
    (cardIndexRect->size).width = (float)local_3c;
    (cardIndexRect->size).height = fStack_38;
  }
  if (offset != (NSPoint *)0x0) {
    offset->x = fVar3;
    offset->y = fVar4;
  }
  return CONCAT44(fStack_28,local_2c);
}

*/
+ (NSSize)storyboardItemSizeForCardSize:(NSSize)aSize itemsCount:(NSUInteger)aCount offset:(NSPoint *)aOffset titleRect:(NSRect *)aRect cardIndexRect:(NSRect *)aRect2 defaultTitleSize:(NSSize)aSize2
{
    NSRect cardRect = NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, aSize.width, aSize.height);
    NSPoint inset = [HSCardBorderRenderer borderInsetForCardThumbnailSize:aSize];
    NSPoint selectedInset = [HSCardBorderRenderer selectedBorderInsetForCardThumbnailSize:aSize];
    cardRect = NSInsetRect(cardRect, -fmax(inset.x, selectedInset.x), -fmax(inset.y, selectedInset.y));

    // The index sits left of the card, the title is centred below it.
    NSRect indexRect;
    indexRect.size = [self requiredRenderingSizeForNumberOfItems:aCount];
    indexRect.origin = NSMakePoint(cardRect.origin.x - 2.0 - indexRect.size.width, 0.0);
    CGFloat titleWidth = fmax(aSize.width, aSize2.width);
    NSRect titleRect = NSMakeRect(cardRect.size.width * 0.5 + cardRect.origin.x - (titleWidth * 0.5 + NSZeroPoint.x) + NSZeroPoint.x,
                                  cardRect.origin.y + cardRect.size.height + 2.0, titleWidth, aSize2.height);
    NSRect itemRect = NSUnionRect(cardRect, NSUnionRect(indexRect, titleRect));
    itemRect = NSInsetRect(itemRect, -5.0, -4.0);
    CGFloat dx = -itemRect.origin.x;
    CGFloat dy = -itemRect.origin.y;
    titleRect = NSOffsetRect(titleRect, dx, dy);
    indexRect = NSOffsetRect(indexRect, dx, dy);
    if (aRect != NULL) {
        *aRect = titleRect;
    }
    if (aRect2 != NULL) {
        *aRect2 = indexRect;
    }
    if (aOffset != NULL) {
        *aOffset = NSMakePoint(dx, dy);
    }
    return itemRect.size;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009027a @ 0009027a, 157 bytes * /

ulonglong FUN_0009027a(id self,SEL _cmd,uint requiredSizeToFitNumberOfItems,NSSize itemSize,
                      uint withMaxCardsPerRow)

{
  float fVar1;
  longdouble lVar2;
  float fVar3;
  
  fVar3 = *(float *)PTR_0033607c;
  fVar1 = *(float *)(PTR_0033607c + 4);
  if (withMaxCardsPerRow != 0) {
    lVar2 = (longdouble)
            _ceilf((float)((double)((ulonglong)
                                    ((uint)(requiredSizeToFitNumberOfItems % withMaxCardsPerRow != 0
                                           ) + requiredSizeToFitNumberOfItems / withMaxCardsPerRow)
                                   | 0x4330000000000000) - 4503599627370496.0) * itemSize.height);
    fVar1 = (float)lVar2;
    if (requiredSizeToFitNumberOfItems < withMaxCardsPerRow) {
      withMaxCardsPerRow = requiredSizeToFitNumberOfItems;
    }
    fVar3 = (float)((double)((ulonglong)withMaxCardsPerRow | 0x4330000000000000) -
                   4503599627370496.0) * itemSize.width;
  }
  return CONCAT44(fVar1,fVar3);
}

*/
+ (NSSize)requiredSizeToFitNumberOfItems:(NSUInteger)aItems itemSize:(NSSize)aSize withMaxCardsPerRow:(NSUInteger)aRow
{
    if (aRow == 0) {
        return NSZeroSize;
    }
    NSUInteger rows = aItems / aRow + (aItems % aRow != 0 ? 1 : 0);
    return NSMakeSize((float)(aItems < aRow ? aItems : aRow) * aSize.width, ceilf((float)rows * aSize.height));
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00090317 @ 00090317, 309 bytes * /

void FUN_00090317(HSStoryboardCell *self,SEL _cmd,id renderIndex,NSRect inRect)

{
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_prepareTextStorageForRenderingIndex_,renderIndex);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_textContainer,renderIndex);
    _objc_msgSend(pvVar1,sel_setContainerSize_,inRect.size.width,inRect.size.height);
    pvVar2 = _objc_msgSend(self,sel_layoutManager);
    pvVar1 = _objc_msgSend(self,sel_textContainer);
    pvVar2 = _objc_msgSend(pvVar2,sel_glyphRangeForTextContainer_,pvVar1);
    if (extraout_EDX != 0.0) {
      pvVar1 = _objc_msgSend(self,sel_layoutManager,pvVar1,inRect.size.height);
      inRect.size.height = extraout_EDX;
      _objc_msgSend(pvVar1,sel_drawGlyphsForGlyphRange_atPoint_,pvVar2,extraout_EDX,inRect.origin.x,
                    inRect.origin.y);
      pvVar1 = pvVar2;
    }
    pvVar1 = _objc_msgSend(self,sel_textContainer,pvVar1,inRect.size.height);
    _objc_msgSend(pvVar1,sel_hyperResizeToContainerHeight_,0x49742400);
  }
  return;
}

*/
- (void)renderIndex:(id)aIndex inRect:(NSRect)aRect
{
    if (![self prepareTextStorageForRenderingIndex:aIndex]) {
        return;
    }
    [[self textContainer] setContainerSize:aRect.size];
    NSRange range = [[self layoutManager] glyphRangeForTextContainer:[self textContainer]];
    if (range.length != 0) {
        [[self layoutManager] drawGlyphsForGlyphRange:range atPoint:aRect.origin];
    }
    [[self textContainer] hyperResizeToContainerHeight:1000000.0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009044c @ 0009044c, 1035 bytes * /

void FUN_0009044c(HSStoryboardCell *self,SEL _cmd,id renderTitle,BOOL selected,NSRect inRect)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  int extraout_EDX;
  int *piVar4;
  int *piVar5;
  float fVar6;
  double dVar7;
  undefined4 uStack_94;
  undefined4 *local_90;
  id local_60;
  int local_5c;
  float local_54;
  undefined4 local_50;
  undefined4 local_4c;
  float local_48;
  float local_44;
  undefined4 local_40;
  undefined4 local_3c;
  float local_38;
  float local_34;
  undefined4 local_30;
  undefined4 local_2c;
  float local_28;
  float local_24;
  float fStack_20;
  undefined4 local_1c;
  float fStack_18;
  
  local_24 = *(float *)PTR_00336078;
  fStack_20 = *(float *)(PTR_00336078 + 4);
  local_1c = *(undefined4 *)(PTR_00336078 + 8);
  fStack_18 = *(float *)(PTR_00336078 + 0xc);
  local_90 = (float *)0x904ac;
  pvVar2 = _objc_msgSend(self,sel_prepareTextStorageForRenderingTitle_selected_);
  if ((char)pvVar2 == '\0') {
    local_60 = (id)0x0;
    local_5c = 0;
    piVar5 = (int *)&stack0xffffff74;
  }
  else {
    local_90 = (undefined4 *)0x904d7;
    pvVar2 = _objc_msgSend(self,sel_layoutManager);
    local_90 = (undefined4 *)0x904eb;
    pvVar3 = _objc_msgSend(self,sel_textContainer);
    local_90 = (undefined4 *)0x90518;
    _objc_msgSend(pvVar3,sel_setContainerSize_);
    local_90 = (float *)0x9052e;
    local_60 = _objc_msgSend(pvVar2,sel_glyphRangeForTextContainer_);
    piVar5 = (int *)&stack0xffffff74;
    local_5c = extraout_EDX;
    if ((selected != '\0') && (piVar5 = (int *)&stack0xffffff74, extraout_EDX != 0)) {
      local_90 = (undefined4 *)0x9056e;
      _objc_msgSend_stret(&local_24,pvVar2,sel_boundingRectForGlyphRange_inTextContainer_);
      local_90 = &local_34;
      uStack_94 = 0x905aa;
      _NSOffsetRect();
      piVar5 = &uStack_94;
      local_24 = local_34;
      fStack_20 = (float)local_30;
      local_1c = local_2c;
      fStack_18 = local_28;
    }
  }
  puVar1 = cls_HSStoryboardCell;
  if (selected != '\0') {
    piVar5[1] = (int)sel_layoutManager;
    *piVar5 = (int)self;
    piVar5[-1] = 0x905fa;
    pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    piVar5[2] = (int)pvVar2;
    piVar5[1] = (int)sel_defaultLineHeightWithLayoutManager_;
    *piVar5 = (int)puVar1;
    piVar5[-1] = 0x90610;
    pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    fVar6 = (float)((double)(ZEXT48(pvVar2) | 0x4330000000000000) - 4503599627370496.0);
    piVar4 = piVar5;
    if (local_5c == 0) {
      local_24 = inRect.size.width * 0.5 + inRect.origin.x;
      fStack_20 = inRect.origin.y;
      *(ulonglong *)(piVar5 + 3) = CONCAT44(fStack_18,local_1c);
      *(ulonglong *)(piVar5 + 1) = CONCAT44(inRect.origin.y,local_24);
      *piVar5 = (int)&local_44;
      piVar5[6] = -0x3fc00000;
      piVar5[5] = -0x3fc00000;
      piVar5[-1] = 0x9068e;
      _NSInsetRect();
      local_24 = local_44;
      fStack_20 = (float)local_40;
      local_1c = local_3c;
      piVar4 = piVar5 + -1;
      fStack_18 = local_38;
    }
    if (fStack_18 <= fVar6) {
      fStack_18 = fVar6;
    }
    piVar4[1] = (int)sel_rolloverCornerRadius;
    *piVar4 = (int)self;
    piVar4[-1] = 0x906d8;
    dVar7 = _objc_msgSend_fpret((id)*piVar4,(SEL)piVar4[1]);
    *(ulonglong *)(piVar4 + 3) = CONCAT44(fStack_18,local_1c);
    *(ulonglong *)(piVar4 + 1) = CONCAT44(fStack_20,local_24);
    *piVar4 = (int)&local_54;
    piVar4[5] = (int)-(float)dVar7;
    piVar4[6] = 0;
    piVar4[-1] = 0x9071f;
    _NSInsetRect();
    piVar5 = piVar4 + -1;
    local_24 = local_54;
    fStack_20 = (float)local_50;
    local_1c = local_4c;
    fStack_18 = local_48;
    *(ulonglong *)(piVar4 + 3) = CONCAT44(local_48,local_4c);
    *(ulonglong *)(piVar4 + 1) = CONCAT44(local_50,local_54);
    piVar4[5] = (int)(float)dVar7;
    *piVar4 = (int)sel_smkRoundedBorderPathWithRect_cornerRadius_;
    piVar4[-1] = (int)cls_NSBezierPath;
    piVar4[-2] = 0x90783;
    pvVar2 = _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
    *piVar4 = (int)sel_cardBorderRenderer;
    piVar4[-1] = (int)self;
    piVar4[-2] = 0x90797;
    pvVar3 = _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
    *piVar4 = (int)sel_fillColor;
    piVar4[-1] = (int)pvVar3;
    piVar4[-2] = 0x907a9;
    pvVar3 = _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
    *piVar4 = (int)sel_set;
    piVar4[-1] = (int)pvVar3;
    piVar4[-2] = 0x907bb;
    _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
    *piVar4 = (int)sel_fill;
    piVar4[-1] = (int)pvVar2;
    piVar4[-2] = 0x907cd;
    _objc_msgSend((id)piVar4[-1],(SEL)*piVar4);
  }
  if (local_5c != 0) {
    piVar5[1] = (int)sel_layoutManager;
    *piVar5 = (int)self;
    piVar5[-1] = 0x907e8;
    pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    piVar5[5] = (int)inRect.origin.y;
    piVar5[4] = (int)inRect.origin.x;
    piVar5[3] = local_5c;
    piVar5[2] = (int)local_60;
    piVar5[1] = (int)sel_drawGlyphsForGlyphRange_atPoint_;
    *piVar5 = (int)pvVar2;
    piVar5[-1] = 0x90820;
    _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  }
  piVar5[1] = (int)sel_textContainer;
  *piVar5 = (int)self;
  piVar5[-1] = 0x90835;
  pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  piVar5[1] = (int)sel_hyperResizeToContainerHeight_;
  *piVar5 = (int)pvVar2;
  piVar5[2] = 0x49742400;
  piVar5[-1] = 0x9084f;
  _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  return;
}

*/
- (void)renderTitle:(id)aTitle selected:(BOOL)aSelected inRect:(NSRect)aRect
{
    NSRect background = NSZeroRect;
    NSRange range = NSMakeRange(0, 0);

    if ([self prepareTextStorageForRenderingTitle:aTitle selected:aSelected]) {
        NSLayoutManager *layoutManager = [self layoutManager];
        [[self textContainer] setContainerSize:aRect.size];
        range = [layoutManager glyphRangeForTextContainer:[self textContainer]];
        if (aSelected && range.length != 0) {
            background = [layoutManager boundingRectForGlyphRange:range inTextContainer:[self textContainer]];
            background = NSOffsetRect(background, aRect.origin.x, aRect.origin.y);
        }
    }
    if (aSelected) {
        float lineHeight = (float)[HSStoryboardCell defaultLineHeightWithLayoutManager:[self layoutManager]];
        if (range.length == 0) {
            background.origin = NSMakePoint(aRect.size.width * 0.5 + aRect.origin.x, aRect.origin.y);
            background = NSInsetRect(background, -3.0, -3.0);
        }
        if (background.size.height < lineHeight) {
            background.size.height = lineHeight;
        }
        CGFloat radius = [self rolloverCornerRadius];
        background = NSInsetRect(background, -radius, 0.0);
        NSBezierPath *path = [NSBezierPath smkRoundedBorderPathWithRect:background cornerRadius:radius];
        [(NSColor *)[[self cardBorderRenderer] fillColor] set];
        [path fill];
    }
    if (range.length != 0) {
        [[self layoutManager] drawGlyphsForGlyphRange:range atPoint:aRect.origin];
    }
    [[self textContainer] hyperResizeToContainerHeight:1000000.0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00090857 @ 00090857, 143 bytes * /

float FUN_00090857(HSStoryboardCell *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  longdouble lVar2;
  
  self_00 = cls_HSStoryboardCell;
  if (DAT_00342888 == '\x01') {
    lVar2 = (longdouble)DAT_0034288c;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_layoutManager);
    pvVar1 = _objc_msgSend(self_00,sel_defaultLineHeightWithLayoutManager_,pvVar1);
    lVar2 = (longdouble)
            _floorf((float)(((double)(ZEXT48(pvVar1) | 0x4330000000000000) - 4503599627370496.0) *
                           0.5));
    DAT_0034288c = (float)lVar2;
    DAT_00342888 = '\x01';
  }
  return (float)lVar2;
}

*/
- (CGFloat)rolloverCornerRadius
{
    if (!sHasRolloverCornerRadius) {
        sRolloverCornerRadius = floorf((float)[HSStoryboardCell defaultLineHeightWithLayoutManager:[self layoutManager]] * 0.5f);
        sHasRolloverCornerRadius = YES;
    }
    return sRolloverCornerRadius;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000908e6 @ 000908e6, 244 bytes * /

ulonglong FUN_000908e6(HSStoryboardCell *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  longdouble lVar3;
  double dVar4;
  
  puVar1 = cls_HSStoryboardCell;
  if (DAT_0034287c != '\x01') {
    pvVar2 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(puVar1,sel_minimalAcceptableWidthForTitleStringWithTextStorage_,pvVar2);
    puVar1 = cls_HSStoryboardCell;
    DAT_00342880 = (float)((double)(ZEXT48(pvVar2) | 0x4330000000000000) - 4503599627370496.0);
    pvVar2 = _objc_msgSend(self,sel_layoutManager);
    pvVar2 = _objc_msgSend(puVar1,sel_defaultLineHeightWithLayoutManager_,pvVar2);
    dVar4 = (double)(ZEXT48(pvVar2) | 0x4330000000000000) - 4503599627370496.0;
    lVar3 = (longdouble)_ceilf((float)(dVar4 + dVar4));
    DAT_00342884 = (float)lVar3;
    DAT_0034287c = '\x01';
  }
  return CONCAT44(DAT_00342884,DAT_00342880);
}

*/
- (NSSize)defaultTitleSize
{
    if (!sHasDefaultTitleSize) {
        sDefaultTitleSize.width = (float)[HSStoryboardCell minimalAcceptableWidthForTitleStringWithTextStorage:[self textStorage]];
        double lineHeight = (double)[HSStoryboardCell defaultLineHeightWithLayoutManager:[self layoutManager]];
        sDefaultTitleSize.height = ceilf((float)(lineHeight + lineHeight));
        sHasDefaultTitleSize = YES;
    }
    return sDefaultTitleSize;
}

- (BOOL)prepareTextStorageForRenderingIndex:(id)aIndex
{
    return (BOOL)[self prepareTextStorageForRenderingText:aIndex attributeSelector:@selector(indexRenderingAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00090a14 @ 00090a14, 73 bytes * /

BOOL FUN_00090a14(HSStoryboardCell *self,SEL _cmd,id prepareTextStorageForRenderingTitle,
                 BOOL selected)

{
  id pvVar1;
  undefined **ppuVar2;
  
  ppuVar2 = &sel_selectedTitleRenderingAttributes;
  if (selected == '\0') {
    ppuVar2 = &sel_titleRenderingAttributes;
  }
  pvVar1 = _objc_msgSend(self,sel_prepareTextStorageForRenderingText_attributeSelector_,
                         prepareTextStorageForRenderingTitle,*ppuVar2);
  return (BOOL)pvVar1;
}

*/
- (BOOL)prepareTextStorageForRenderingTitle:(id)aTitle selected:(BOOL)aSelected
{
    return [self prepareTextStorageForRenderingText:aTitle attributeSelector:(aSelected ? @selector(selectedTitleRenderingAttributes) : @selector(titleRenderingAttributes))];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00090a5d @ 00090a5d, 316 bytes * /

BOOL FUN_00090a5d(HSStoryboardCell *self,SEL _cmd,id prepareTextStorageForRenderingText,
                 SEL attributeSelector)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  undefined4 uVar4;
  
  pvVar2 = _objc_msgSend(prepareTextStorageForRenderingText,sel_length);
  if (pvVar2 == (id)0x0) {
    BVar1 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(pvVar2,sel_length);
    pvVar3 = _objc_msgSend(self,sel_textStorage);
    _objc_msgSend(pvVar3,sel_replaceCharactersInRange_withString_,0,pvVar2,
                  prepareTextStorageForRenderingText);
    pvVar2 = _objc_msgSend(self,sel_textStorage);
    pvVar2 = _objc_msgSend(pvVar2,sel_length);
    if (attributeSelector != (SEL)0x0) {
      uVar4 = 0;
      pvVar3 = _objc_msgSend(cls_HSStoryboardCell,sel_performSelector_withObject_,attributeSelector,
                             0,prepareTextStorageForRenderingText);
      if (pvVar3 != (id)0x0) {
        self_00 = _objc_msgSend(self,sel_textStorage,attributeSelector,uVar4,
                                prepareTextStorageForRenderingText);
        _objc_msgSend(self_00,sel_setAttributes_range_,pvVar3,0,pvVar2);
        return '\x01';
      }
    }
    BVar1 = '\x01';
  }
  return BVar1;
}

*/
- (BOOL)prepareTextStorageForRenderingText:(id)aText attributeSelector:(SEL)aSelector
{
    if ([aText length] == 0) {
        return NO;
    }
    [[self textStorage] replaceCharactersInRange:NSMakeRange(0, [[self textStorage] length]) withString:aText];
    NSUInteger length = [[self textStorage] length];
    if (aSelector != NULL) {
        id attributes = [HSStoryboardCell performSelector:aSelector withObject:nil];
        if (attributes != nil) {
            [[self textStorage] setAttributes:attributes range:NSMakeRange(0, length)];
        }
    }
    return YES;
}

- (id)textContainer
{
    [self layoutManager];
    return _textContainer;
}

- (id)layoutManager
{
    id pvVar1;
    id pvVar1_5;

    pvVar1 = _layoutManager;
    if (pvVar1 == nil) {
        _layoutManager = [[NSLayoutManager alloc] init];
        pvVar1_5 = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(0x49742400, 0x49742400)];
        _textContainer = pvVar1_5;
        [pvVar1_5 setWidthTracksTextView:YES];
        [_textContainer setHeightTracksTextView:NO];
        [_textContainer setLineFragmentPadding:0];
        [_layoutManager addTextContainer:_textContainer];
        [_textContainer release];
        [[self textStorage] addLayoutManager:_layoutManager];
        [_layoutManager release];
        pvVar1 = _layoutManager;
    }
    return pvVar1;
}

- (id)textStorage
{
    id pvVar1;

    pvVar1 = _textStorage;
    if (pvVar1 == nil) {
        pvVar1 = [[NSTextStorage alloc] init];
        _textStorage = pvVar1;
    }
    return pvVar1;
}

- (void)setCanRecacheCardThumbnail:(BOOL)aThumbnail
{
    _canRecacheCardThumbnail = aThumbnail;
}

- (BOOL)canRecacheCardThumbnail
{
    return _canRecacheCardThumbnail;
}

- (void)setShouldDrawBadgedIcons:(BOOL)aIcons
{
    _shouldDrawBadgedIcons = aIcons;
}

- (BOOL)shouldDrawBadgedIcons
{
    return _shouldDrawBadgedIcons;
}

- (id)auxiliaryUserObjectTraits
{
    HSAuxiliaryUserObjectTraits *pHVar1;

    pHVar1 = _auxiliaryUserObjectTraits;
    if (pHVar1 == nil) {
        pHVar1 = [HSAuxiliaryUserObjectTraits new];
        _auxiliaryUserObjectTraits = pHVar1;
    }
    return pHVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00090d9d @ 00090d9d, 274 bytes * /

BOOL FUN_00090d9d(HSStoryboardCell *self,SEL _cmd,NSSize calcSizeWithScaledCardSize)

{
  float fVar1;
  id pvVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  
  fVar3 = (self->_cardImageFrame).size.width;
  fVar1 = (self->_cardImageFrame).size.height;
  if ((calcSizeWithScaledCardSize.width != 0.0) || (NAN(calcSizeWithScaledCardSize.width))) {
    fVar4 = ABS(calcSizeWithScaledCardSize.width);
  }
  else {
    fVar4 = 1.0;
  }
  if ((fVar3 != 0.0) || (NAN(fVar3))) {
    fVar5 = ABS(fVar3);
  }
  else {
    fVar5 = 1.0;
  }
  if (fVar5 <= fVar4) {
    fVar5 = fVar4;
  }
  if (ABS(calcSizeWithScaledCardSize.width - fVar3) <= fVar5 * 0.0005) {
    if ((calcSizeWithScaledCardSize.height != 0.0) || (NAN(calcSizeWithScaledCardSize.height))) {
      fVar3 = ABS(calcSizeWithScaledCardSize.height);
    }
    else {
      fVar3 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar4 = ABS(fVar1);
    }
    else {
      fVar4 = 1.0;
    }
    if (fVar4 <= fVar3) {
      fVar4 = fVar3;
    }
    if (ABS(calcSizeWithScaledCardSize.height - fVar1) <= fVar4 * 0.0005) {
      return '\0';
    }
  }
  pvVar2 = _objc_msgSend(self,sel_calcSizeWithScaledCardSize_itemsCount_,
                         calcSizeWithScaledCardSize.width,calcSizeWithScaledCardSize.height,
                         self->_numberOfItems);
  return (BOOL)pvVar2;
}

*/
- (BOOL)calcSizeWithScaledCardSize:(NSSize)aSize
{
    if (HSStoryboardCellSizesNearlyEqual(aSize, _cardImageFrame.size)) {
        return NO;
    }
    return [self calcSizeWithScaledCardSize:aSize itemsCount:_numberOfItems];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00090eaf @ 00090eaf, 125 bytes * /

BOOL FUN_00090eaf(HSStoryboardCell *self,SEL _cmd,uint calcSizeWithItemsCount)

{
  char cVar1;
  id pvVar2;
  
  if (self->_numberOfItems == calcSizeWithItemsCount) {
    cVar1 = '\0';
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_calcSizeWithScaledCardSize_itemsCount_,
                           (self->_cardImageFrame).size.width,(self->_cardImageFrame).size.height,
                           calcSizeWithItemsCount);
    cVar1 = (char)pvVar2;
    if (cVar1 == '\0') {
      _objc_msgSend(self,sel_calcSizeWithBoundsWidth_force_,self->_boundsWidth,1,
                    calcSizeWithItemsCount);
    }
  }
  return cVar1;
}

*/
- (BOOL)calcSizeWithItemsCount:(NSUInteger)aCount
{
    if (_numberOfItems == aCount) {
        return NO;
    }
    BOOL changed = [self calcSizeWithScaledCardSize:_cardImageFrame.size itemsCount:aCount];
    if (!changed) {
        [self calcSizeWithBoundsWidth:_boundsWidth force:YES];
    }
    return changed;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00090f2c @ 00090f2c, 1785 bytes * /

BOOL FUN_00090f2c(HSStoryboardCell *self,SEL _cmd,NSSize calcSizeWithScaledCardSize,uint itemsCount)

{
  float fVar1;
  float fVar2;
  float fVar3;
  undefined *self_00;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  float extraout_EDX_00;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  uint uVar11;
  float *pfVar12;
  float *pfVar13;
  float *pfVar14;
  undefined4 uVar15;
  char local_3d;
  float local_3c;
  float local_38;
  float local_34;
  float local_30;
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  fVar6 = (self->_cardImageFrame).size.width;
  fVar1 = (self->_cardImageFrame).size.height;
  if ((fVar6 != 0.0) || (NAN(fVar6))) {
    fVar8 = ABS(fVar6);
  }
  else {
    fVar8 = 1.0;
  }
  if ((calcSizeWithScaledCardSize.width != 0.0) || (NAN(calcSizeWithScaledCardSize.width))) {
    fVar7 = ABS(calcSizeWithScaledCardSize.width);
  }
  else {
    fVar7 = 1.0;
  }
  if (fVar7 <= fVar8) {
    fVar7 = fVar8;
  }
  if (fVar7 * 0.0005 < ABS(fVar6 - calcSizeWithScaledCardSize.width)) {
LAB_00091013:
    (self->_cardImageFrame).size.width = calcSizeWithScaledCardSize.width;
    (self->_cardImageFrame).size.height = calcSizeWithScaledCardSize.height;
    _objc_msgSend(self->_cardBorderRenderer,sel_setThumbnailSize_,calcSizeWithScaledCardSize.width,
                  calcSizeWithScaledCardSize.height);
    local_3d = '\x01';
  }
  else {
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar6 = ABS(fVar1);
    }
    else {
      fVar6 = 1.0;
    }
    if ((calcSizeWithScaledCardSize.height != 0.0) || (NAN(calcSizeWithScaledCardSize.height))) {
      fVar8 = ABS(calcSizeWithScaledCardSize.height);
    }
    else {
      fVar8 = 1.0;
    }
    if (fVar8 <= fVar6) {
      fVar8 = fVar6;
    }
    if (fVar8 * 0.0005 < ABS(fVar1 - calcSizeWithScaledCardSize.height)) goto LAB_00091013;
    local_3d = '\0';
  }
  uVar11 = self->_numberOfItems;
  self->_numberOfItems = itemsCount;
  self_00 = cls_HSStoryboardCell;
  local_1c = (self->_cardImageFrame).origin.x;
  local_18 = (self->_cardImageFrame).origin.y;
  local_3c = *(float *)PTR_00336078;
  local_38 = *(float *)(PTR_00336078 + 4);
  local_34 = *(float *)(PTR_00336078 + 8);
  local_30 = *(float *)(PTR_00336078 + 0xc);
  if (uVar11 != itemsCount) {
    local_3d = '\x01';
  }
  local_2c = local_3c;
  local_28 = local_38;
  local_24 = local_34;
  local_20 = local_30;
  pvVar4 = _objc_msgSend(self,sel_defaultTitleSize);
  uVar11 = self->_numberOfItems;
  pfVar12 = &local_1c;
  pfVar13 = &local_2c;
  pfVar14 = &local_3c;
  uVar15 = extraout_EDX;
  pvVar5 = _objc_msgSend(self_00,
                         sel_storyboardItemSizeForCardSize_itemsCount_offset_titleRect_cardIndexRect_defaultTitleSize_
                         ,(self->_cardImageFrame).size.width,(self->_cardImageFrame).size.height,
                         uVar11,pfVar12,pfVar13,pfVar14,pvVar4,extraout_EDX);
  fVar6 = (self->_itemFrameSize).width;
  fVar1 = (self->_itemFrameSize).height;
  if (((float)pvVar5 != 0.0) || (NAN((float)pvVar5))) {
    fVar8 = ABS((float)pvVar5);
  }
  else {
    fVar8 = 1.0;
  }
  if ((fVar6 != 0.0) || (NAN(fVar6))) {
    fVar7 = ABS(fVar6);
  }
  else {
    fVar7 = 1.0;
  }
  if (fVar7 <= fVar8) {
    fVar7 = fVar8;
  }
  if (ABS((float)pvVar5 - fVar6) <= fVar7 * 0.0005) {
    if ((extraout_EDX_00 != 0.0) || (NAN(extraout_EDX_00))) {
      fVar6 = ABS(extraout_EDX_00);
    }
    else {
      fVar6 = 1.0;
    }
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar8 = ABS(fVar1);
    }
    else {
      fVar8 = 1.0;
    }
    if (fVar8 <= fVar6) {
      fVar8 = fVar6;
    }
    if (ABS(extraout_EDX_00 - fVar1) <= fVar8 * 0.0005) {
      fVar6 = (self->_cardImageFrame).origin.x;
      fVar1 = (self->_cardImageFrame).origin.y;
      if ((local_1c != 0.0) || (NAN(local_1c))) {
        fVar8 = ABS(local_1c);
      }
      else {
        fVar8 = 1.0;
      }
      if ((fVar6 != 0.0) || (NAN(fVar6))) {
        fVar7 = ABS(fVar6);
      }
      else {
        fVar7 = 1.0;
      }
      if (fVar7 <= fVar8) {
        fVar7 = fVar8;
      }
      if (ABS(local_1c - fVar6) <= fVar7 * 0.0005) {
        if ((local_18 != 0.0) || (NAN(local_18))) {
          fVar6 = ABS(local_18);
        }
        else {
          fVar6 = 1.0;
        }
        if ((fVar1 != 0.0) || (NAN(fVar1))) {
          fVar8 = ABS(fVar1);
        }
        else {
          fVar8 = 1.0;
        }
        if (fVar8 <= fVar6) {
          fVar8 = fVar6;
        }
        if (ABS(local_18 - fVar1) <= fVar8 * 0.0005) {
          fVar6 = (self->_cardTitleFrame).origin.y;
          fVar1 = (self->_cardTitleFrame).size.height;
          fVar7 = ABS(fVar6) + fVar1;
          fVar8 = ABS(local_28) + local_20;
          if ((fVar8 != 0.0) || (NAN(fVar8))) {
            fVar8 = ABS(fVar8);
          }
          else {
            fVar8 = 1.0;
          }
          if ((fVar7 != 0.0) || (NAN(fVar7))) {
            fVar7 = ABS(fVar7);
          }
          else {
            fVar7 = 1.0;
          }
          fVar2 = (self->_cardTitleFrame).origin.x;
          fVar3 = (self->_cardTitleFrame).size.width;
          fVar9 = ABS(fVar2) + fVar3;
          fVar10 = ABS(local_2c) + local_24;
          if (fVar7 <= fVar8) {
            fVar7 = fVar8;
          }
          if ((fVar10 != 0.0) || (NAN(fVar10))) {
            fVar10 = ABS(fVar10);
          }
          else {
            fVar10 = 1.0;
          }
          if ((fVar9 != 0.0) || (NAN(fVar9))) {
            fVar9 = ABS(fVar9);
          }
          else {
            fVar9 = 1.0;
          }
          if (fVar9 <= fVar10) {
            fVar9 = fVar10;
          }
          if ((((ABS(local_2c - fVar2) <= fVar9 * 0.0005) &&
               (ABS(local_28 - fVar6) <= fVar7 * 0.0005)) &&
              (ABS(local_24 - fVar3) <= fVar9 * 0.0005)) &&
             (ABS(local_20 - fVar1) <= fVar7 * 0.0005)) {
            fVar6 = (self->_cardIndexFrame).origin.y;
            fVar1 = (self->_cardIndexFrame).size.height;
            fVar7 = ABS(fVar6) + fVar1;
            fVar8 = ABS(local_38) + local_30;
            if ((fVar8 != 0.0) || (NAN(fVar8))) {
              fVar8 = ABS(fVar8);
            }
            else {
              fVar8 = 1.0;
            }
            if ((fVar7 != 0.0) || (NAN(fVar7))) {
              fVar7 = ABS(fVar7);
            }
            else {
              fVar7 = 1.0;
            }
            fVar2 = (self->_cardIndexFrame).origin.x;
            fVar3 = (self->_cardIndexFrame).size.width;
            fVar9 = ABS(fVar2) + fVar3;
            fVar10 = ABS(local_3c) + local_34;
            if (fVar7 <= fVar8) {
              fVar7 = fVar8;
            }
            if ((fVar10 != 0.0) || (NAN(fVar10))) {
              fVar10 = ABS(fVar10);
            }
            else {
              fVar10 = 1.0;
            }
            if ((fVar9 != 0.0) || (NAN(fVar9))) {
              fVar9 = ABS(fVar9);
            }
            else {
              fVar9 = 1.0;
            }
            if (fVar9 <= fVar10) {
              fVar9 = fVar10;
            }
            if ((((ABS(local_3c - fVar2) <= fVar9 * 0.0005) &&
                 (ABS(local_38 - fVar6) <= fVar7 * 0.0005)) &&
                (ABS(local_34 - fVar3) <= fVar9 * 0.0005)) &&
               (ABS(local_30 - fVar1) <= fVar7 * 0.0005)) goto LAB_000915f7;
          }
        }
      }
    }
  }
  (self->_itemFrameSize).width = (float)pvVar5;
  (self->_itemFrameSize).height = extraout_EDX_00;
  (self->_cardImageFrame).origin.x = local_1c;
  (self->_cardImageFrame).origin.y = local_18;
  (self->_cardTitleFrame).origin.x = local_2c;
  (self->_cardTitleFrame).origin.y = local_28;
  (self->_cardTitleFrame).size.width = local_24;
  (self->_cardTitleFrame).size.height = local_20;
  (self->_cardIndexFrame).origin.x = local_3c;
  (self->_cardIndexFrame).origin.y = local_38;
  (self->_cardIndexFrame).size.width = local_34;
  (self->_cardIndexFrame).size.height = local_30;
  local_3d = '\x01';
LAB_000915f7:
  _objc_msgSend(self,sel_calcSizeWithBoundsWidth_force_,self->_boundsWidth,(int)local_3d,uVar11,
                pfVar12,pfVar13,pfVar14,pvVar4,uVar15);
  return local_3d;
}

*/
- (BOOL)calcSizeWithScaledCardSize:(NSSize)aSize itemsCount:(NSUInteger)aCount
{
    BOOL changed = NO;
    if (!HSStoryboardCellSizesNearlyEqual(_cardImageFrame.size, aSize)) {
        _cardImageFrame.size = aSize;
        [_cardBorderRenderer setThumbnailSize:aSize];
        changed = YES;
    }
    if (_numberOfItems != aCount) {
        changed = YES;
    }
    _numberOfItems = (unsigned int)aCount;
    NSPoint offset = _cardImageFrame.origin;
    NSRect titleRect = NSZeroRect;
    NSRect indexRect = NSZeroRect;
    NSSize itemSize = [HSStoryboardCell storyboardItemSizeForCardSize:_cardImageFrame.size itemsCount:_numberOfItems offset:&offset titleRect:&titleRect cardIndexRect:&indexRect defaultTitleSize:[self defaultTitleSize]];
    if (!HSStoryboardCellSizesNearlyEqual(itemSize, _itemFrameSize)
        || !HSStoryboardCellNearlyEqual((float)offset.x, (float)_cardImageFrame.origin.x) || !HSStoryboardCellNearlyEqual((float)offset.y, (float)_cardImageFrame.origin.y)
        || !HSStoryboardCellRectsNearlyEqual(titleRect, _cardTitleFrame) || !HSStoryboardCellRectsNearlyEqual(indexRect, _cardIndexFrame)) {
        _itemFrameSize = itemSize;
        _cardImageFrame.origin = offset;
        _cardTitleFrame = titleRect;
        _cardIndexFrame = indexRect;
        changed = YES;
    }
    [self calcSizeWithBoundsWidth:_boundsWidth force:changed];
    return changed;
}

- (BOOL)calcSizeWithBoundsWidth:(NSUInteger)aWidth
{
    return (BOOL)[self calcSizeWithBoundsWidth:aWidth force:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0009165d @ 0009165d, 551 bytes * /

BOOL FUN_0009165d(HSStoryboardCell *self,SEL _cmd,uint calcSizeWithBoundsWidth,BOOL force)

{
  float fVar1;
  float fVar2;
  BOOL BVar3;
  uint uVar4;
  id pvVar5;
  uint uVar6;
  float extraout_EDX;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  
  if (force == '\0') {
    fVar7 = (self->_itemFrameSize).width;
    uVar4 = (int)fVar7;
    if (2.1474836e+09 <= fVar7) {
      uVar4 = (int)(fVar7 - 2.1474836e+09) ^ 0x80000000;
    }
    if (uVar4 <= calcSizeWithBoundsWidth - self->_requiredWidth) goto LAB_000916ae;
  }
  else {
LAB_000916ae:
    fVar7 = (self->_cardImageFrame).size.width;
    fVar1 = (self->_cardImageFrame).size.height;
    fVar8 = *(float *)PTR_0033607c;
    fVar2 = *(float *)(PTR_0033607c + 4);
    if ((fVar7 != 0.0) || (NAN(fVar7))) {
      fVar9 = ABS(fVar7);
    }
    else {
      fVar9 = 1.0;
    }
    if ((fVar8 != 0.0) || (NAN(fVar8))) {
      fVar10 = ABS(fVar8);
    }
    else {
      fVar10 = 1.0;
    }
    if (fVar10 <= fVar9) {
      fVar10 = fVar9;
    }
    if (fVar10 * 0.0005 < ABS(fVar7 - fVar8)) {
LAB_0009178f:
      fVar7 = (self->_itemFrameSize).width;
      uVar4 = (int)fVar7;
      if (2.1474836e+09 <= fVar7) {
        uVar4 = (int)(fVar7 - 2.1474836e+09) ^ 0x80000000;
      }
      uVar4 = calcSizeWithBoundsWidth / uVar4;
      self->_maxCardsPerRow = uVar4;
      if (uVar4 == 0) {
        self->_maxCardsPerRow = 1;
        uVar4 = 1;
      }
    }
    else {
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar7 = ABS(fVar1);
      }
      else {
        fVar7 = 1.0;
      }
      if ((fVar2 != 0.0) || (NAN(fVar2))) {
        fVar8 = ABS(fVar2);
      }
      else {
        fVar8 = 1.0;
      }
      if (fVar8 <= fVar7) {
        fVar8 = fVar7;
      }
      if (fVar8 * 0.0005 < ABS(fVar1 - fVar2)) goto LAB_0009178f;
      fVar7 = (self->_itemFrameSize).width;
      uVar4 = self->_maxCardsPerRow;
    }
    pvVar5 = _objc_msgSend(cls_HSStoryboardCell,
                           sel_requiredSizeToFitNumberOfItems_itemSize_withMaxCardsPerRow_,
                           self->_numberOfItems,fVar7,(self->_itemFrameSize).height,uVar4);
    uVar4 = (int)extraout_EDX;
    if (2.1474836e+09 <= extraout_EDX) {
      uVar4 = (int)(extraout_EDX - 2.1474836e+09) ^ 0x80000000;
    }
    uVar6 = (int)(float)pvVar5;
    if (2.1474836e+09 <= (float)pvVar5) {
      uVar6 = (int)((float)pvVar5 - 2.1474836e+09) ^ 0x80000000;
    }
    if ((uVar6 != self->_requiredWidth) || (uVar4 != self->_requiredHeight)) {
      self->_requiredWidth = uVar6;
      self->_requiredHeight = uVar4;
      BVar3 = '\x01';
      goto LAB_00091870;
    }
  }
  BVar3 = '\0';
LAB_00091870:
  self->_boundsWidth = calcSizeWithBoundsWidth;
  return BVar3;
}

*/
- (BOOL)calcSizeWithBoundsWidth:(NSUInteger)aWidth force:(BOOL)aForce
{
    BOOL changed = NO;
    unsigned int width = (unsigned int)aWidth;
    // Unsigned like the original: a width below the required width wraps and always recalculates.
    if (aForce || (unsigned int)_itemFrameSize.width <= width - _requiredWidth) {
        unsigned int maxCardsPerRow;
        if (!HSStoryboardCellSizesNearlyEqual(_cardImageFrame.size, NSZeroSize)) {
            unsigned int itemWidth = (unsigned int)_itemFrameSize.width;
            // Guarded: the original divided by a zero item width.
            maxCardsPerRow = itemWidth != 0 ? width / itemWidth : 0;
            _maxCardsPerRow = maxCardsPerRow;
            if (maxCardsPerRow == 0) {
                _maxCardsPerRow = 1;
                maxCardsPerRow = 1;
            }
        }
        else {
            maxCardsPerRow = _maxCardsPerRow;
        }
        NSSize required = [HSStoryboardCell requiredSizeToFitNumberOfItems:_numberOfItems itemSize:_itemFrameSize withMaxCardsPerRow:maxCardsPerRow];
        unsigned int requiredWidth = (unsigned int)required.width;
        unsigned int requiredHeight = (unsigned int)required.height;
        if (requiredWidth != _requiredWidth || requiredHeight != _requiredHeight) {
            _requiredWidth = requiredWidth;
            _requiredHeight = requiredHeight;
            changed = YES;
        }
    }
    _boundsWidth = width;
    return changed;
}

- (NSSize)requiredSizeToFitAllItems
{
    return NSMakeSize( (float)((double)((unsigned long long)_requiredWidth | 0x4330000000000000) - 4503599627370496.0), (float)((double)((unsigned long long)_requiredHeight | 0x4330000000000000) - 4503599627370496.0));
}

- (NSUInteger)maxCardsPerRow
{
    unsigned int uVar1;

    uVar1 = _maxCardsPerRow;
    if (uVar1 == 0) {
        _maxCardsPerRow = 1;
        uVar1 = 1;
    }
    return uVar1;
}

- (void)setNeedsDisplayItem:(id)aItem inView:(id)aView
{
    [aView setNeedsDisplayInRect:[aItem frame]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000918e1 @ 000918e1, 493 bytes * /

void FUN_000918e1(HSStoryboardCell *self,SEL _cmd,id renderItem,id inView,NSRect rect)

{
  NSPoint NVar1;
  NSSize NVar2;
  id pvVar3;
  SEL op;
  id pvVar4;
  float extraout_EDX;
  float fVar5;
  undefined4 uVar6;
  float local_38;
  undefined4 local_34;
  float local_30;
  float local_28;
  undefined1 local_24 [20];
  
  if (self->_canRecacheCardThumbnail == '\0') {
    _objc_msgSend(renderItem,sel_setCachedItemImage_,0);
    _objc_msgSend(renderItem,sel_setCachedSelectedItemImage_,0);
  }
  pvVar3 = _objc_msgSend(renderItem,sel_isSelected);
  op = sel_imageForItem_;
  if ((char)pvVar3 != '\0') {
    op = sel_selectedImageForItem_;
  }
  pvVar3 = _objc_msgSend(self,op,renderItem);
  _objc_msgSend_stret(&local_34,renderItem,sel_frame);
  if (pvVar3 != (id)0x0) {
    local_38 = local_30;
    pvVar4 = _objc_msgSend(inView,sel_isFlipped);
    if ((char)pvVar4 != '\0') {
      _objc_msgSend(pvVar3,sel_size);
      local_38 = local_30 + extraout_EDX;
    }
    uVar6 = 2;
    fVar5 = local_38;
    _objc_msgSend(pvVar3,sel_compositeToPoint_operation_,local_34,local_38,2);
    pvVar3 = _objc_msgSend(cls_HSEmptyStoryboardItem,sel_class);
    pvVar4 = _objc_msgSend(renderItem,sel_isKindOfClass_,pvVar3);
    if ((char)pvVar4 == '\0') {
      pvVar3 = _objc_msgSend(renderItem,sel_indexString,pvVar3,fVar5,uVar6);
      NVar1 = (self->_cardIndexFrame).origin;
      NVar2 = (self->_cardIndexFrame).size;
      _NSOffsetRect(local_24,NVar1.x,NVar1.y,NVar2.width,NVar2.height,local_34,local_38 - local_28);
      _objc_msgSend(self,sel_renderIndex_inRect_,pvVar3,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                    (int)local_24._8_8_,SUB84(local_24._8_8_,4));
    }
  }
  return;
}

*/
- (void)renderItem:(id)aItem inView:(id)aView rect:(NSRect)aRect
{
    if (!_canRecacheCardThumbnail) {
        [aItem setCachedItemImage:nil];
        [aItem setCachedSelectedItemImage:nil];
    }
    NSImage *image = [aItem isSelected] ? [self selectedImageForItem:aItem] : [self imageForItem:aItem];
    NSRect frame = [(HSStoryboardItem *)aItem frame];
    if (image == nil) {
        return;
    }
    NSPoint point = frame.origin;
    if ([aView isFlipped]) {
        point.y += [image size].height;
    }
    [image compositeToPoint:point operation:NSCompositingOperationSourceOver];
    if (![aItem isKindOfClass:[HSEmptyStoryboardItem class]]) {
        [self renderIndex:[aItem indexString] inRect:NSOffsetRect(_cardIndexFrame, point.x, point.y - frame.size.height)];
    }
}

- (id)selectedImageForItem:(id)aItem
{
    id self_00;

    self_00 = [aItem cachedSelectedItemImage];
    if (self_00 == nil) {
        self_00 = [self newImageForItem:aItem selected:YES withText:YES];
        [aItem setCachedSelectedItemImage:self_00];
        [self_00 release];
    }
    return self_00;
}

- (id)imageForItem:(id)aItem
{
    id self_00;

    self_00 = [aItem cachedItemImage];
    if (self_00 == nil) {
        self_00 = [self newImageForItem:aItem selected:NO withText:YES];
        [aItem setCachedItemImage:self_00];
        [self_00 release];
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00091bd8 @ 00091bd8, 936 bytes * /

id FUN_00091bd8(HSStoryboardCell *self,SEL _cmd,id newImageForItem,BOOL selected,BOOL withText)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  NSPoint NVar6;
  HSAuxiliaryUserObjectTraits *pHVar7;
  undefined8 uVar8;
  NSSize NVar9;
  undefined *puVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  SEL op;
  undefined8 *puVar14;
  float fVar15;
  undefined4 local_70;
  id local_40;
  
  puVar10 = PTR_00336074;
  NVar9 = self->_itemFrameSize;
  uVar8 = *(undefined8 *)PTR_00336074;
  local_70 = 0x91c2f;
  pvVar11 = _objc_msgSend(cls_NSImage,sel_alloc);
  local_70 = 0x91c57;
  pvVar11 = _objc_msgSend(pvVar11,sel_initWithSize_);
  local_70 = 0x91c74;
  _objc_msgSend(pvVar11,sel_setFlipped_);
  if (self->_canRecacheCardThumbnail == '\0') {
    local_70 = 0x91c8f;
    local_40 = _objc_msgSend(newImageForItem,sel_cachedCardThumbnail);
    if (local_40 != (id)0x0) goto LAB_00091cc1;
  }
  local_70 = 0x91cc1;
  local_40 = _objc_msgSend(newImageForItem,sel_cardThumbnailForCardSize_);
LAB_00091cc1:
  fVar1 = (self->_cardImageFrame).origin.x;
  fVar15 = (self->_cardImageFrame).origin.y;
  fVar2 = (self->_cardImageFrame).size.width;
  fVar3 = (self->_cardImageFrame).size.height;
  fVar4 = *(float *)puVar10;
  fVar5 = *(float *)(puVar10 + 4);
  puVar14 = (undefined8 *)&stack0xffffff94;
  if (local_40 != (id)0x0) {
    local_70 = 0x91d1f;
    pvVar12 = _objc_msgSend(self,sel_cardBorderRenderer);
    local_70 = 0x91d36;
    _objc_msgSend(newImageForItem,sel_isHighlighted);
    op = sel_borderedThumbnailWithCardThumbnail_isHighlighted_inset_;
    if (selected != '\0') {
      op = sel_selectedBorderedThumbnailWithCardThumbnail_isHighlighted_inset_;
    }
    local_70 = 0x91d72;
    pvVar12 = _objc_msgSend(pvVar12,op);
    puVar14 = (undefined8 *)&stack0xffffff94;
    if (pvVar12 != (id)0x0) {
      local_70 = 0x91dbd;
      _NSInsetRect();
      puVar14 = (undefined8 *)&local_70;
      local_40 = pvVar12;
    }
  }
  *(undefined **)((int)puVar14 + 4) = sel_lockFocus;
  *(id *)puVar14 = pvVar11;
  *(undefined4 *)((int)puVar14 + -4) = 0x91dd8;
  _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
  *(NSSize *)(puVar14 + 1) = NVar9;
  *puVar14 = uVar8;
  *(undefined4 *)(puVar14 + 2) = 0;
  *(undefined4 *)((int)puVar14 + -4) = 0x91dfa;
  _NSRectFillUsingOperation();
  if (local_40 != (id)0x0) {
    fVar15 = fVar15 + fVar3;
    *(float *)((int)puVar14 + 0xc) = fVar15;
    *(float *)(puVar14 + 1) = fVar1;
    *(undefined **)((int)puVar14 + 4) = sel_compositeToPoint_operation_;
    *(id *)puVar14 = local_40;
    *(undefined4 *)(puVar14 + 2) = 2;
    *(undefined4 *)((int)puVar14 + -4) = 0x91e46;
    _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
    if (self->_shouldDrawBadgedIcons != '\0') {
      *(undefined **)((int)puVar14 + 4) = sel_auxiliaryUserObjectTraits;
      *(HSStoryboardCell **)puVar14 = self;
      *(undefined4 *)((int)puVar14 + -4) = 0x91e68;
      pvVar12 = _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
      *(undefined **)((int)puVar14 + 4) = sel_card;
      *(id *)puVar14 = newImageForItem;
      *(undefined4 *)((int)puVar14 + -4) = 0x91e7f;
      pvVar13 = _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
      *(id *)(puVar14 + 1) = pvVar13;
      *(undefined **)((int)puVar14 + 4) = sel_setUserObject_;
      *(id *)puVar14 = pvVar12;
      *(undefined4 *)((int)puVar14 + -4) = 0x91e95;
      _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
      pHVar7 = self->_auxiliaryUserObjectTraits;
      *(undefined **)((int)puVar14 + 4) = sel_combinedIconsImage;
      *(HSAuxiliaryUserObjectTraits **)puVar14 = pHVar7;
      *(undefined4 *)((int)puVar14 + -4) = 0x91eaa;
      pvVar12 = _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
      *(undefined **)((int)puVar14 + 4) = sel_size;
      *(id *)puVar14 = pvVar12;
      *(undefined4 *)((int)puVar14 + -4) = 0x91ecd;
      pvVar13 = _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
      *(float *)((int)puVar14 + 0xc) = fVar15 - fVar5;
      *(float *)(puVar14 + 1) = ((fVar2 - fVar4) - (float)pvVar13) + fVar1;
      *(undefined **)((int)puVar14 + 4) = sel_compositeToPoint_operation_;
      *(id *)puVar14 = pvVar12;
      *(undefined4 *)(puVar14 + 2) = 2;
      *(undefined4 *)((int)puVar14 + -4) = 0x91f0f;
      _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
    }
  }
  if (withText != '\0') {
    *(undefined **)((int)puVar14 + 4) = sel_titleString;
    *(id *)puVar14 = newImageForItem;
    *(undefined4 *)((int)puVar14 + -4) = 0x91f2a;
    pvVar12 = _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
    NVar6 = (self->_cardTitleFrame).origin;
    *(NSSize *)(puVar14 + 3) = (self->_cardTitleFrame).size;
    *(NSPoint *)(puVar14 + 2) = NVar6;
    *(int *)((int)puVar14 + 0xc) = (int)selected;
    *(id *)(puVar14 + 1) = pvVar12;
    *(undefined **)((int)puVar14 + 4) = sel_renderTitle_selected_inRect_;
    *(HSStoryboardCell **)puVar14 = self;
    *(undefined4 *)((int)puVar14 + -4) = 0x91f61;
    _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
  }
  *(undefined **)((int)puVar14 + 4) = sel_unlockFocus;
  *(id *)puVar14 = pvVar11;
  *(undefined4 *)((int)puVar14 + -4) = 0x91f76;
  _objc_msgSend(*(id *)puVar14,*(SEL *)((int)puVar14 + 4));
  return pvVar11;
}

*/
- (id)newImageForItem:(id)aItem selected:(BOOL)aSelected withText:(BOOL)aText
{
    NSSize itemSize = _itemFrameSize;
    NSImage *image = [[NSImage alloc] initWithSize:itemSize];
    [image setFlipped:YES];
    NSImage *thumbnail = nil;
    if (!_canRecacheCardThumbnail) {
        thumbnail = [aItem cachedCardThumbnail];
    }
    if (thumbnail == nil) {
        thumbnail = [aItem cardThumbnailForCardSize:_cardImageFrame.size];
    }
    NSRect cardRect = _cardImageFrame;
    NSPoint inset = NSZeroPoint;
    if (thumbnail != nil) {
        HSCardBorderRenderer *renderer = [self cardBorderRenderer];
        BOOL highlighted = [aItem isHighlighted];
        NSImage *bordered = aSelected ? [renderer selectedBorderedThumbnailWithCardThumbnail:thumbnail isHighlighted:highlighted inset:&inset]
                                      : [renderer borderedThumbnailWithCardThumbnail:thumbnail isHighlighted:highlighted inset:&inset];
        if (bordered != nil) {
            cardRect = NSInsetRect(cardRect, -inset.x, -inset.y);
            thumbnail = bordered;
        }
    }
    [image lockFocus];
    NSRectFillUsingOperation(NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, itemSize.width, itemSize.height), NSCompositingOperationClear);
    if (thumbnail != nil) {
        float bottom = (float)(cardRect.origin.y + cardRect.size.height);
        [thumbnail compositeToPoint:NSMakePoint(cardRect.origin.x, bottom) operation:NSCompositingOperationSourceOver];
        if (_shouldDrawBadgedIcons) {
            [[self auxiliaryUserObjectTraits] setUserObject:[aItem card]];
            NSImage *icons = [_auxiliaryUserObjectTraits combinedIconsImage];
            [icons compositeToPoint:NSMakePoint((float)(cardRect.size.width - inset.x) - (float)[icons size].width + (float)cardRect.origin.x, bottom - (float)inset.y) operation:NSCompositingOperationSourceOver];
        }
    }
    if (aText) {
        [self renderTitle:[aItem titleString] selected:aSelected inRect:_cardTitleFrame];
    }
    [image unlockFocus];
    return image;
}

- (BOOL)hitTestPoint:(NSPoint)aPoint inItem:(id)aItem atIndex:(NSUInteger)aIndex inView:(id)aView
{
    return (BOOL)[aView mouse:aPoint inRect:[self borderedCardFrameForItem:aItem atIndex:aIndex]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00092004 @ 00092004, 351 bytes * /

NSRect * FUN_00092004(NSRect *__return_storage_ptr__,HSStoryboardCell *self,SEL _cmd,
                     id borderedCardFrameForItem,uint atIndex)

{
  id pvVar1;
  id self_00;
  NSRect *pNVar2;
  uint extraout_EDX;
  SEL op;
  float local_44;
  float local_40;
  float local_3c;
  float local_38;
  float local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  undefined4 local_24;
  undefined4 local_20;
  
  local_34 = (self->_cardImageFrame).origin.x;
  fStack_30 = (self->_cardImageFrame).origin.y;
  local_2c = (self->_cardImageFrame).size.width;
  fStack_28 = (self->_cardImageFrame).size.height;
  pvVar1 = _objc_msgSend(self,sel_storyboardLayout);
  _objc_msgSend_stret(&local_24,pvVar1,sel_frameForItemAtIndex_,atIndex);
  _NSOffsetRect(&local_34,local_34,fStack_30,local_2c,fStack_28,local_24,local_20);
  pvVar1 = _objc_msgSend(borderedCardFrameForItem,sel_isSelected);
  self_00 = _objc_msgSend(self,sel_cardBorderRenderer);
  op = sel_borderInset;
  if ((char)pvVar1 != '\0') {
    op = sel_selectedBorderInset;
  }
  pvVar1 = _objc_msgSend(self_00,op);
  pNVar2 = (NSRect *)
           _NSInsetRect(&local_44,local_34,fStack_30,local_2c,fStack_28,(uint)pvVar1 ^ 0x80000000,
                        extraout_EDX ^ 0x80000000);
  (__return_storage_ptr__->origin).x = local_44;
  (__return_storage_ptr__->origin).y = local_40;
  (__return_storage_ptr__->size).width = local_3c;
  (__return_storage_ptr__->size).height = local_38;
  return pNVar2;
}

*/
- (NSRect)borderedCardFrameForItem:(id)aItem atIndex:(NSUInteger)aIndex
{
    NSRect itemFrame = [[self storyboardLayout] frameForItemAtIndex:aIndex];
    NSRect frame = NSOffsetRect(_cardImageFrame, itemFrame.origin.x, itemFrame.origin.y);
    NSPoint inset = [aItem isSelected] ? [[self cardBorderRenderer] selectedBorderInset] : [[self cardBorderRenderer] borderInset];
    return NSInsetRect(frame, -inset.x, -inset.y);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00092163 @ 00092163, 115 bytes * /

void FUN_00092163(HSStoryboardCell *self,SEL _cmd,id setCardBorderRenderer)

{
  HSCardBorderRenderer *self_00;
  
  if (self->_cardBorderRenderer != setCardBorderRenderer) {
    _objc_msgSend(self->_cardBorderRenderer,sel_release);
    self_00 = _objc_msgSend(setCardBorderRenderer,sel_retain);
    self->_cardBorderRenderer = self_00;
    _objc_msgSend(self_00,sel_setThumbnailSize_,(self->_cardImageFrame).size.width,
                  (self->_cardImageFrame).size.height);
  }
  return;
}

*/
- (void)setCardBorderRenderer:(id)aRenderer
{
    if (_cardBorderRenderer != aRenderer) {
        [_cardBorderRenderer release];
        _cardBorderRenderer = [aRenderer retain];
        [_cardBorderRenderer setThumbnailSize:_cardImageFrame.size];
    }
}

- (id)cardBorderRenderer
{
    HSCardBorderRenderer *pHVar1;

    pHVar1 = _cardBorderRenderer;
    if (pHVar1 == nil) {
        pHVar1 = [[HSCardBorderRenderer alloc] initWithThumbnailSize:(_cardImageFrame).size];
        _cardBorderRenderer = pHVar1;
    }
    return pHVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008f72b @ 0008f72b, 14 bytes * /

ulonglong FUN_0008f72b(HSStoryboardCell *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_cardImageFrame).origin.x;
  uVar1._4_4_ = (self->_cardImageFrame).origin.y;
  return uVar1;
}

*/
- (NSPoint)cardFrameOffset
{
    return _cardImageFrame.origin;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008f71d @ 0008f71d, 14 bytes * /

ulonglong FUN_0008f71d(HSStoryboardCell *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_cardImageFrame).size.width;
  uVar1._4_4_ = (self->_cardImageFrame).size.height;
  return uVar1;
}

*/
- (NSSize)cardFrameSize
{
    return _cardImageFrame.size;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008f70f @ 0008f70f, 14 bytes * /

ulonglong FUN_0008f70f(HSStoryboardCell *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_itemFrameSize).width;
  uVar1._4_4_ = (self->_itemFrameSize).height;
  return uVar1;
}

*/
- (NSSize)itemFrameSize
{
    return _itemFrameSize;
}

- (void)setStoryboardLayout:(id)aLayout
{
    if (_storyboardLayout != aLayout) {
        [_storyboardLayout release];
        _storyboardLayout = [aLayout retain];
    }
}

- (id)storyboardLayout
{
    return _storyboardLayout;
}

- (void)dealloc
{
    [_cardBorderRenderer release];
    [_textStorage release];
    [_auxiliaryUserObjectTraits release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _canRecacheCardThumbnail = 1;
    }
    _shouldDrawBadgedIcons = 1;
    return self;
}

@end

