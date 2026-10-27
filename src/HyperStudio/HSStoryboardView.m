#import "HSStoryboardView.h"
#import "HSSharedCardBorderRenderer.h"

// Relative float comparison used for sizes and scale factors.
static BOOL HSStoryboardFloatsAreEqual(float a, float b)
{
    float scaleA = a != 0.0f ? fabsf(a) : 1.0f;
    float scaleB = b != 0.0f ? fabsf(b) : 1.0f;
    return fabsf(a - b) <= MAX(scaleA, scaleB) * 0.0005f;
}

@implementation HSStoryboardView

/* i386 ivar offsets: _stack=0x50, _items=0x54, _storyboardCell=0x58, _backgroundColor=0x5c, _presentationContext=0x60, _cardScaleFactor=0x64, _scaleFactorOnceCalculated=0x68, _selectionChangeDelegate=0x6c, _dragHelper=0x70, _imageLoader=0x74, _shouldSelectItem=0x78, _itemToSelect=0x7c, _storyboardLayout=0x80, _delegate=0x84, _idleTimer=0x88, _windowUpdateTimer=0x8c, _selectionIndex=0x90, _allowDragAndDrop=0x94, _allowEmptySelection=0x95, _allowMultipleSelection=0x96, _inLiveScale=0x97, _didHandleKeyDown=0x98, _shiftPressed=0x99, _modifingStack=0x9a, _readablePasteboardTypes=0x9c */

+ (NSSize)scaledCardSize:(NSSize)aSize withScaleFactor:(CGFloat)aFactor
{
    return NSMakeSize(aSize.width * aFactor, aFactor * aSize.height);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00082d61 @ 00082d61, 173 bytes * /

float FUN_00082d61(id self,SEL _cmd,id defaultScaleFactorForStack)

{
  id pvVar1;
  id pvVar2;
  id extraout_EDX;
  longdouble lVar3;
  float fVar4;
  
  pvVar2 = _objc_msgSend(defaultScaleFactorForStack,sel_hyperCardSize);
  pvVar1 = extraout_EDX;
  if ((float)extraout_EDX <= (float)pvVar2) {
    pvVar1 = pvVar2;
  }
  if (((float)pvVar1 != 0.0) || (NAN((float)pvVar1))) {
    fVar4 = ABS((float)pvVar1);
  }
  else {
    fVar4 = 1.0;
  }
  if (fVar4 <= 100.0) {
    fVar4 = 100.0;
  }
  if (fVar4 * -0.0005 + (float)pvVar1 <= 100.0) {
    fVar4 = 1.0;
  }
  else {
    lVar3 = (longdouble)_roundf((100.0 / (float)pvVar1) * 1000.0);
    fVar4 = (float)lVar3 / 1000.0;
  }
  return fVar4;
}

*/
+ (CGFloat)defaultScaleFactorForStack:(id)aStack
{
    NSSize cardSize = [aStack hyperCardSize];
    float side = MAX(cardSize.width, cardSize.height);
    float tolerance = MAX(side != 0.0f ? fabsf(side) : 1.0f, 100.0f);
    // Cards up to 100 points are shown at full size; bigger ones are scaled down to 100.
    if (side - tolerance * 0.0005f <= 100.0f) {
        return 1.0;
    }
    return roundf(100.0f / side * 1000.0f) / 1000.0f;
}

- (void)cut:(id)aCut
{
    [self copy:self];
    [self deleteSelectedCardsUsePoofAnimation:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00082953 @ 00082953, 694 bytes * /

void FUN_00082953(HSStoryboardView *self,SEL _cmd,id paste)

{
  HSStoryboardItemsCache *self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  SEL op;
  
  self_01 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
  pvVar3 = self_01;
  _objc_msgSend(cls_HSMediaLoader,sel_forceLoadMediasFromPasteboard_,self_01);
  pvVar1 = _objc_msgSend(self,sel_stack);
  pvVar2 = _objc_msgSend(pvVar1,sel_document);
  pvVar2 = _objc_msgSend(pvVar2,sel_isNewAndNotChanged);
  if ((char)pvVar2 == '\0') {
    self_00 = self->_items;
    pvVar3 = _objc_msgSend(self_00,sel_selectedItems,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_lastObject);
    pvVar3 = _objc_msgSend(self_00,sel_indexOfStoryboardItem_,pvVar3);
    if (pvVar3 != (id)0x7fffffff) goto LAB_00082a65;
  }
  else {
    _objc_msgSend(pvVar1,sel_removeAllChildren,pvVar3);
    pvVar3 = _objc_msgSend(self,sel_items);
    _objc_msgSend(pvVar3,sel_invalidateWithRemovedItem);
  }
  pvVar3 = (id)0xffffffff;
LAB_00082a65:
  pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_HSCardPasteboardType);
  iVar4 = (int)pvVar3 + 1;
  pvVar3 = _objc_msgSend(self_01,sel_availableTypeFromArray_,pvVar2);
  if (pvVar3 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_canImportImageFromPasteboard_,self_01);
    op = sel_importImageFromPasteboard_asCardWithIndex_;
    pvVar3 = self_01;
    if ((char)pvVar1 == '\0') {
      return;
    }
  }
  else {
    pvVar3 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,pvVar2);
    _objc_msgSend(pvVar3,sel_disableObjectRegistration);
    pvVar3 = _objc_msgSend(pvVar1,sel_insertCardsFromPasteboard_atIndex_,self_01,iVar4);
    pvVar1 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    _objc_msgSend(pvVar1,sel_enableObjectRegistration);
    pvVar1 = _objc_msgSend(pvVar3,sel_objectEnumerator);
    pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_array);
    while (self_01 = _objc_msgSend(pvVar1,sel_nextObject,self_01), op = sel_addItemsToSelection_,
          self_01 != (id)0x0) {
      pvVar2 = _objc_msgSend(self->_items,sel_itemForCard_,self_01);
      if (pvVar2 != (id)0x0) {
        _objc_msgSend(pvVar3,sel_addObject_,pvVar2);
        self_01 = pvVar2;
      }
    }
  }
  _objc_msgSend(self,op,pvVar3,iVar4);
  return;
}

*/
- (void)paste:(id)aPaste
{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [HSMediaLoader forceLoadMediasFromPasteboard:pasteboard];
    id stack = [self stack];
    NSInteger index = -1;
    if ([[stack document] isNewAndNotChanged]) {
        // Pasting into an untouched new document replaces its blank card.
        [stack removeAllChildren];
        [[self items] invalidateWithRemovedItem];
    } else {
        NSUInteger selectedIndex = [_items indexOfStoryboardItem:[[_items selectedItems] lastObject]];
        if (selectedIndex != NSNotFound) {
            index = selectedIndex;
        }
    }
    NSUInteger insertionIndex = index + 1;
    if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"HSCardPasteboardType"]] != nil) {
        [[HSCoachingHelpManager sharedCoachingHelpManager] disableObjectRegistration];
        NSArray *cards = [stack insertCardsFromPasteboard:pasteboard atIndex:insertionIndex];
        [[HSCoachingHelpManager sharedCoachingHelpManager] enableObjectRegistration];
        NSMutableArray *items = [NSMutableArray array];
        for (id card in cards) {
            id item = [_items itemForCard:card];
            if (item != nil) {
                [items addObject:item];
            }
        }
        [self addItemsToSelection:items];
    } else if ([self canImportImageFromPasteboard:pasteboard]) {
        [self importImageFromPasteboard:pasteboard asCardWithIndex:insertionIndex];
    }
}

- (void)copy:(id)aCopy
{
    NSPasteboard *self_00;

    self_00 = [NSPasteboard generalPasteboard];
    [self_00 declareTypes:[NSArray arrayWithObjects:@"HSCardPasteboardType", @"HSCardsIndexPasteboardType", nil] owner:nil];
    [self writeSelectedCardsToPasteboard:self_00];
}

- (void)registerItemsForActionsAttributeChanges
{
    [_items registerForActionsAttributeChanges];
}

- (void)unregisterItemsForActionsAttributeChanges
{
    [_items unregisterForActionsAttributeChanges];
}

- (void)setShouldDrawBadgedIcons:(BOOL)aIcons
{
    if ([self shouldDrawBadgedIcons] != aIcons) {
        [[self storyboardCell] setShouldDrawBadgedIcons:aIcons];
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)shouldDrawBadgedIcons
{
    return (BOOL)[[self storyboardCell] shouldDrawBadgedIcons];
}

- (void)setInLiveScale:(BOOL)aScale
{
    _inLiveScale = aScale;
    if (aScale == NO) {
        [_items invalidateAllItemsWithoutThumbnails];
        [[self imageLoader] validateInvalidItems];
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)inLiveScale
{
    return _inLiveScale;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00082e0e @ 00082e0e, 1088 bytes * /

id FUN_00082e0e(HSStoryboardView *self,SEL _cmd,id imageForMultipleDraggedItemsForImage,
               NSRect destinationRect)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  int iVar9;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  longdouble lVar10;
  float fVar11;
  float fVar12;
  double dVar13;
  
  pvVar2 = _objc_msgSend(self->_items,sel_draggedItems);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  lVar10 = (longdouble)_log10((double)(int)pvVar2);
  puVar1 = cls_NSBundle;
  pvVar3 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(puVar1,sel_bundleForClass_,pvVar3);
  iVar4 = _lrint((double)lVar10);
  if (iVar4 < 2) {
    iVar9 = 2;
  }
  else {
    iVar9 = 5;
    if (iVar4 < 6) {
      iVar9 = iVar4;
    }
  }
  pvVar5 = _objc_msgSend(cls_NSString,sel_stringWithFormat_,&cfstr_dragBadge__i,iVar9);
  pvVar6 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar3 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_,pvVar5,&cfstr_tiff);
  pvVar3 = _objc_msgSend(pvVar6,sel_initWithContentsOfFile_,pvVar3);
  pvVar5 = _objc_msgSend(pvVar3,sel_autorelease);
  pvVar6 = _objc_msgSend(cls_SMKStringRenderer,sel_sharedRenderer);
  _objc_msgSend(pvVar6,sel_setAlignment_,2);
  pvVar3 = _objc_msgSend(pvVar5,sel_size);
  _objc_msgSend(pvVar6,sel_setContainerWidth_,pvVar3);
  puVar1 = cls_NSFont;
  dVar13 = _objc_msgSend_fpret(cls_NSFont,sel_smallSystemFontSize);
  pvVar3 = _objc_msgSend(puVar1,sel_systemFontOfSize_,(float)dVar13);
  _objc_msgSend(pvVar6,sel_setFont_,pvVar3);
  pvVar7 = _objc_msgSend(pvVar5,sel_size);
  pvVar3 = _objc_msgSend(imageForMultipleDraggedItemsForImage,sel_size);
  _objc_msgSend(pvVar5,sel_size);
  _objc_msgSend(imageForMultipleDraggedItemsForImage,sel_size);
  fVar11 = extraout_EDX_00;
  if (extraout_EDX_00 <= extraout_EDX) {
    fVar11 = extraout_EDX;
  }
  pvVar8 = _objc_msgSend(cls_NSImage,sel_alloc);
  if ((float)pvVar3 <= (float)pvVar7) {
    pvVar3 = pvVar7;
  }
  pvVar7 = _objc_msgSend(pvVar8,sel_initWithSize_,pvVar3,fVar11);
  pvVar7 = _objc_msgSend(pvVar7,sel_autorelease);
  _objc_msgSend(pvVar7,sel_lockFocus);
  _objc_msgSend(imageForMultipleDraggedItemsForImage,sel_size);
  _objc_msgSend(imageForMultipleDraggedItemsForImage,sel_dissolveToPoint_fraction_,0,
                fVar11 - extraout_EDX_01,0x3f000000);
  fVar11 = destinationRect.origin.y + (float)pvVar3 * 0.5;
  pvVar8 = _objc_msgSend(pvVar5,sel_size);
  fVar12 = ((float)pvVar3 * 0.5 + destinationRect.origin.x + destinationRect.size.width) -
           (float)pvVar8;
  _objc_msgSend(pvVar5,sel_dissolveToPoint_fraction_,fVar12,fVar11,0x3f800000);
  pvVar3 = _objc_msgSend(cls_NSColor,sel_whiteColor);
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithInt_,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_stringValue);
  _objc_msgSend(pvVar6,sel_drawString_atPoint_withColor_,pvVar2,fVar12,fVar11 + -1.0,pvVar3);
  _objc_msgSend(pvVar7,sel_unlockFocus);
  return pvVar7;
}

*/
- (id)imageForMultipleDraggedItemsForImage:(id)aImage destinationRect:(NSRect)aRect
{
    NSUInteger count = [[_items draggedItems] count];
    // Badge artwork comes in sizes for 2 to 5 digits.
    long digits = lrint(log10((double)count));
    int badgeSize = digits < 2 ? 2 : (digits < 6 ? (int)digits : 5);
    NSString *badgePath = [[NSBundle bundleForClass:[self class]] pathForResource:[NSString stringWithFormat:@"dragBadge_%i", badgeSize] ofType:@"tiff"];
    NSImage *badge = [[[NSImage alloc] initWithContentsOfFile:badgePath] autorelease];
    SMKStringRenderer *renderer = [SMKStringRenderer sharedRenderer];
    [renderer setAlignment:NSTextAlignmentCenter];
    [renderer setContainerWidth:[badge size].width];
    [renderer setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
    NSSize badgeImageSize = [badge size];
    NSSize imageSize = [(NSImage *)aImage size];
    CGFloat width = MAX(imageSize.width, badgeImageSize.width);
    CGFloat height = MAX(imageSize.height, badgeImageSize.height);
    NSImage *result = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];
    [result lockFocus];
    [aImage drawAtPoint:NSMakePoint(0.0, height - imageSize.height) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:0.5];
    // The original offsets the badge vertically by half the width.
    CGFloat y = aRect.origin.y + width * 0.5;
    CGFloat x = width * 0.5 + aRect.origin.x + aRect.size.width - badgeImageSize.width;
    [badge drawAtPoint:NSMakePoint(x, y) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
    [renderer drawString:[[NSNumber numberWithInt:(int)count] stringValue] atPoint:NSMakePoint(x, y - 1.0) withColor:[NSColor whiteColor]];
    [result unlockFocus];
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008324e @ 0008324e, 1278 bytes * /

id FUN_0008324e(HSStoryboardView *self,SEL _cmd,NSPoint *dragImageWithOrigin,id hitItem)

{
  undefined4 uVar1;
  undefined4 uVar2;
  HSStoryboardCell *self_00;
  ulonglong uVar3;
  id pvVar4;
  id self_01;
  id pvVar5;
  id pvVar6;
  float extraout_EDX;
  uint uVar7;
  bool bVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  id local_70;
  id local_50;
  int local_48;
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar4 = _objc_msgSend(hitItem,sel_cachedItemImage);
  if (pvVar4 == (id)0x0) {
    pvVar4 = _objc_msgSend(self,sel_storyboardCell);
    _objc_msgSend(pvVar4,sel_imageForItem_,hitItem);
  }
  self_01 = _objc_msgSend(self->_items,sel_draggedItems);
  pvVar5 = _objc_msgSend(self,sel_storyboardLayout);
  pvVar4 = _objc_msgSend(self->_items,sel_indexOfStoryboardItem_,hitItem);
  _objc_msgSend_stret(&local_24,pvVar5,sel_frameForItemAtIndex_,pvVar4);
  fVar13 = local_18;
  fVar9 = local_1c;
  pvVar5 = _objc_msgSend(cls_NSImage,sel_alloc);
  fVar13 = fVar13 * 1.6;
  fVar9 = fVar9 * 1.4;
  fVar15 = fVar9;
  fVar12 = fVar13;
  pvVar5 = _objc_msgSend(pvVar5,sel_initWithSize_,fVar9,fVar13);
  uVar1 = *(undefined4 *)PTR_00336078;
  uVar2 = *(undefined4 *)(PTR_00336078 + 4);
  local_70 = _objc_msgSend(pvVar5,sel_autorelease);
  pvVar5 = _objc_msgSend(hitItem,sel_cachedItemImage);
  pvVar5 = _objc_msgSend(pvVar5,sel_size);
  fVar10 = (float)pvVar5 * -0.5;
  fVar11 = extraout_EDX * -0.05 + extraout_EDX * -0.5;
  _objc_msgSend(local_70,sel_lockFocus);
  pvVar6 = _objc_msgSend(self_01,sel_count);
  if (pvVar6 < (id)0x5) {
    local_50 = _objc_msgSend(self_01,sel_count);
  }
  else {
    local_50 = (id)0x5;
  }
  uVar7 = (int)local_50 - 1;
  if (-1 < (int)uVar7) {
    fVar14 = (float)((double)((ulonglong)(uint)((int)local_50 * 0xf) | 0x4330000000000000) -
                    4503599627370496.0);
    uVar3 = (ulonglong)uVar7;
    local_48 = 0;
    do {
      _objc_msgSend(cls_NSGraphicsContext,sel_saveGraphicsState,fVar15,fVar12,pvVar4);
      pvVar4 = _objc_msgSend(cls_NSAffineTransform,sel_transform);
      fVar12 = extraout_EDX * 0.05 + fVar13 * 0.5;
      fVar15 = fVar9 * 0.5;
      _objc_msgSend(pvVar4,sel_translateXBy_yBy_,fVar9 * 0.5,fVar12);
      if ((id)0x1 < local_50) {
        fVar15 = (float)(int)uVar7 *
                 (fVar14 / (float)((double)(uVar3 | 0x4330000000000000) - 4503599627370496.0)) +
                 fVar14 * -0.5;
        _objc_msgSend(pvVar4,sel_rotateByDegrees_,fVar15,fVar12);
      }
      _objc_msgSend(pvVar4,sel_concat,fVar15,fVar12);
      self_00 = self->_storyboardCell;
      pvVar4 = _objc_msgSend(self_01,sel_objectAtIndex_,local_48);
      pvVar6 = _objc_msgSend(self_00,sel_newImageForItem_selected_withText_,pvVar4,0,0);
      fVar15 = fVar10;
      fVar12 = fVar11;
      pvVar4 = pvVar5;
      _objc_msgSend(pvVar6,sel_drawInRect_fromRect_operation_fraction_,fVar10,fVar11,pvVar5,
                    extraout_EDX,uVar1,uVar2,CONCAT44(extraout_EDX,pvVar5),2,
                    (float)(int)uVar7 * -0.2 + 1.0);
      _objc_msgSend(cls_NSGraphicsContext,sel_restoreGraphicsState);
      local_48 = local_48 + 1;
      bVar8 = uVar7 != 0;
      uVar7 = uVar7 - 1;
    } while (bVar8);
  }
  _objc_msgSend(local_70,sel_unlockFocus,fVar15,fVar12,pvVar4);
  dragImageWithOrigin->x = (fVar9 - local_1c) * -0.5 + local_24;
  dragImageWithOrigin->y = (fVar13 - local_18) * -0.5 + local_20 + fVar13;
  pvVar4 = _objc_msgSend(self_01,sel_count);
  if ((id)0x5 < pvVar4) {
    local_70 = _objc_msgSend(self,sel_imageForMultipleDraggedItemsForImage_destinationRect_,local_70
                             ,fVar10,fVar11,pvVar5,extraout_EDX);
  }
  return local_70;
}

*/
- (id)dragImageWithOrigin:(NSPoint *)aOrigin hitItem:(id)aItem
{
    if ([aItem cachedItemImage] == nil) {
        [[self storyboardCell] imageForItem:aItem];
    }
    NSArray *draggedItems = [_items draggedItems];
    NSRect itemFrame = [[self storyboardLayout] frameForItemAtIndex:[_items indexOfStoryboardItem:aItem]];
    CGFloat width = itemFrame.size.width * 1.4;
    CGFloat height = itemFrame.size.height * 1.6;
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(width, height)] autorelease];
    NSSize cachedSize = [(NSImage *)[aItem cachedItemImage] size];
    NSRect cardRect = NSMakeRect(cachedSize.width * -0.5, cachedSize.height * -0.05 + cachedSize.height * -0.5, cachedSize.width, cachedSize.height);
    [image lockFocus];
    // Fan out up to five cards, the first one on top.
    NSUInteger count = MIN([draggedItems count], (NSUInteger)5);
    float spread = count * 15.0f;
    NSUInteger drawn = 0;
    for (NSInteger i = (NSInteger)count - 1; i >= 0; i--, drawn++) {
        [NSGraphicsContext saveGraphicsState];
        NSAffineTransform *transform = [NSAffineTransform transform];
        [transform translateXBy:width * 0.5 yBy:cachedSize.height * 0.05 + height * 0.5];
        if (count > 1) {
            [transform rotateByDegrees:i * (spread / (float)(count - 1)) + spread * -0.5f];
        }
        [transform concat];
        NSImage *cardImage = [_storyboardCell newImageForItem:[draggedItems objectAtIndex:drawn] selected:NO withText:NO];
        [cardImage drawInRect:cardRect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:i * -0.2 + 1.0];
        // Fix: the original leaked the new image.
        [cardImage release];
        [NSGraphicsContext restoreGraphicsState];
    }
    [image unlockFocus];
    aOrigin->x = (width - itemFrame.size.width) * -0.5 + itemFrame.origin.x;
    aOrigin->y = (height - itemFrame.size.height) * -0.5 + itemFrame.origin.y + height;
    if ([draggedItems count] > 5) {
        image = [self imageForMultipleDraggedItemsForImage:image destinationRect:cardRect];
    }
    return image;
}

- (void)showHelpPaneBeforeAddAction:(id)aAction actionEvent:(id)aEvent toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences
{

}

- (void)showHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer useDragPreferences:(BOOL)aPreferences
{

}

- (BOOL)needsOpenHelpPaneBeforeAddObject:(id)aObject toNodeContainer:(id)aContainer
{
    return NO;
}

- (BOOL)allowsDragSession
{
    return ![[[self activeCard] document] isStackProtected];
}

- (id)representedObject
{
    return [self stack];
}

- (void)concludeDragOperation:(id)aOperation
{
    [_items clearDraggedItems];
    [_items synchronizeWithStack];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008374c @ 0008374c, 3064 bytes * /

BOOL FUN_0008374c(HSStoryboardView *self,SEL _cmd,id performDragOperation)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSStoryboardView *pHVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  undefined *puVar7;
  id pvVar8;
  cfstringStruct *pcVar9;
  cfstringStruct *pcVar10;
  undefined *puVar11;
  HSStoryboardView *pHVar12;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  cfstringStruct *pcVar13;
  SEL pcVar14;
  undefined4 uVar15;
  undefined4 uVar16;
  undefined1 *puVar17;
  char *pcVar18;
  cfstringStruct *local_24;
  char local_1e;
  undefined1 local_1d;
  id local_1c;
  int local_18;
  
  pvVar1 = _objc_msgSend(performDragOperation,sel_draggingPasteboard);
  local_24 = _objc_msgSend(self->_items,sel_dropIndex);
  _objc_msgSend(self,sel_removeDragPlaceholder);
  pvVar2 = _objc_msgSend(self->_items,sel_draggedItems);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  while (pvVar3 = _objc_msgSend(pvVar2,sel_nextObject), pvVar3 != (id)0x0) {
    _objc_msgSend(pvVar3,sel_setHighlighted_,0);
  }
  pvVar2 = _objc_msgSend(self,sel_readablePasteboardTypes);
  pvVar3 = _objc_msgSend(pvVar1,sel_availableTypeFromArray_,pvVar2);
  if (pvVar3 == (id)0x0) {
    return '\0';
  }
  pvVar2 = _objc_msgSend(self,sel_stack,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00366024);
  pvVar3 = _objc_msgSend(performDragOperation,sel_draggingSource);
  puVar11 = sel_representedObject;
  pvVar3 = _objc_msgSend(pvVar3,sel_respondsToSelector_,sel_representedObject);
  if ((char)pvVar3 == '\0') {
    pvVar3 = (id)0x0;
  }
  else {
    pvVar3 = _objc_msgSend(performDragOperation,sel_draggingSource,puVar11);
    pvVar3 = _objc_msgSend(pvVar3,sel_representedObject);
  }
  pHVar4 = _objc_msgSend(performDragOperation,sel_draggingSource,puVar11);
  pHVar12 = self;
  if (((pHVar4 == self) ||
      ((pvVar3 != (id)0x0 &&
       (pvVar5 = _objc_msgSend(self,sel_representedObject,puVar11), pvVar5 == pvVar3)))) &&
     (pvVar3 = _objc_msgSend(performDragOperation,sel_draggingSourceOperationMask,puVar11),
     ((uint)pvVar3 & 0x10) != 0)) {
    _objc_msgSend(self,sel_beginModifingStack);
    pvVar3 = _objc_msgSend(self->_items,sel_draggedItemsInitialIndexes);
    pcVar6 = _objc_msgSend(pvVar3,sel_firstIndex);
    if ((pcVar6 < local_24) && (local_24 != (cfstringStruct *)0x7fffffff)) {
      pvVar3 = _objc_msgSend(self->_items,sel_draggedItemsInitialIndexes);
      pvVar3 = _objc_msgSend(pvVar3,sel_firstIndex);
      pvVar5 = _objc_msgSend(self->_items,sel_draggedItemsInitialIndexes);
      pvVar5 = _objc_msgSend(pvVar5,sel_count);
      puVar7 = _malloc((int)pvVar5 << 2);
      pvVar5 = _objc_msgSend(self->_items,sel_draggedItemsInitialIndexes);
      local_1c = _objc_msgSend(pvVar5,sel_firstIndex);
      local_18 = (int)local_24 - (int)pvVar3;
      pvVar5 = _objc_msgSend(self->_items,sel_draggedItemsInitialIndexes);
      puVar11 = puVar7;
      pvVar3 = _objc_msgSend(pvVar5,sel_getIndexes_maxCount_inIndexRange_,puVar7,
                             (int)local_24 - (int)pvVar3,&local_1c);
      local_24 = (cfstringStruct *)((int)local_24 - (int)pvVar3);
      _free(puVar7);
    }
    pcVar14 = sel_endModifingStack;
    if (local_24 != (cfstringStruct *)0x7fffffff) {
      pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_array,puVar11);
      pcVar6 = (cfstringStruct *)0x0;
      _objc_msgSend(self,sel_selectObject_,0);
      pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_array);
      pHVar4 = _objc_msgSend(performDragOperation,sel_draggingSource);
      if (pHVar4 == self) {
        pvVar1 = _objc_msgSend(self->_items,sel_draggedItems,pcVar6);
        pvVar8 = _objc_msgSend(pvVar1,sel_objectEnumerator);
        pvVar1 = _objc_msgSend(pvVar8,sel_nextObject);
        pcVar10 = local_24;
        while (pvVar1 != (id)0x0) {
          pvVar1 = _objc_msgSend(pvVar1,sel_card,pcVar6);
          pcVar6 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00365f48);
          pcVar9 = _objc_msgSend(pcVar6,sel_hyperIndex);
          _objc_msgSend(pvVar3,sel_addObject_);
          local_24 = (cfstringStruct *)((int)&local_24->field0_0x0 + (uint)(pcVar9 < pcVar10));
          pcVar10 = (cfstringStruct *)((int)&pcVar10->field0_0x0 + 1);
          pvVar1 = _objc_msgSend(pvVar8,sel_nextObject);
        }
      }
      else {
        pcVar6 = &cfstr_HSCardsIndexPasteboardType;
        pvVar1 = _objc_msgSend(pvVar1,sel_propertyListForType_,&cfstr_HSCardsIndexPasteboardType);
        pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
        while (pvVar8 = _objc_msgSend(pvVar1,sel_nextObject,pcVar6), pvVar8 != (id)0x0) {
          pvVar8 = _objc_msgSend(pvVar8,sel_unsignedIntValue,pcVar6);
          pcVar6 = _objc_msgSend(pvVar2,sel_hyperChildAtIndex_,pvVar8);
          _objc_msgSend(pvVar3,sel_addObject_);
        }
      }
      pvVar3 = _objc_msgSend(pvVar3,sel_objectEnumerator,pcVar6);
      pvVar1 = _objc_msgSend(pvVar3,sel_nextObject);
      puVar7 = &DAT_00365f48;
      for (pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00365f48); pvVar1 != (id)0x0;
          pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00365f48)) {
        pcVar10 = _objc_msgSend(pvVar1,sel_hyperIndex,puVar7);
        pcVar6 = (cfstringStruct *)((int)&local_24[-1].field3_0xc + 3);
        if (local_24 <= pcVar10) {
          pcVar6 = local_24;
        }
        _objc_msgSend(pvVar2,sel_setIndex_ofHyperChild_,pcVar6,pvVar1);
        pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00366038);
        _objc_msgSend(pvVar5,sel_addObject_,pvVar1);
        pvVar1 = _objc_msgSend(pvVar3,sel_nextObject);
        puVar7 = &DAT_00365f48;
        local_24 = (cfstringStruct *)((int)&local_24->field0_0x0 + (uint)(local_24 <= pcVar10));
      }
      puVar11 = _objc_msgSend(cls_NSMutableArray,sel_array,puVar7);
      _objc_msgSend(self->_items,sel_invalidateWithChangedItemOrder);
      pvVar1 = _objc_msgSend(pvVar5,sel_objectEnumerator);
      while (pvVar2 = _objc_msgSend(pvVar1,sel_nextObject,puVar7), pvVar2 != (id)0x0) {
        puVar7 = _objc_msgSend(self->_items,sel_itemForCard_,pvVar2);
        _objc_msgSend(puVar11,sel_addObject_,puVar7);
      }
      _objc_msgSend(self,sel_addItemsToSelection_,puVar11);
      pcVar14 = sel_endModifingStack;
    }
  }
  else {
    pvVar2 = _objc_msgSend(performDragOperation,sel_draggingSourceOperationMask,puVar11);
    if (((uint)pvVar2 & 1) == 0) goto LAB_000842dc;
    if (self->_shiftPressed != '\0') {
      pvVar1 = _objc_msgSend(performDragOperation,sel_draggingLocation);
      uVar16 = 0;
      puVar11 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
      pvVar1 = _objc_msgSend(self,sel_storyboardLayout);
      uVar15 = extraout_EDX_00;
      pvVar1 = _objc_msgSend(pvVar1,sel_itemIndexAtPoint_,puVar11,extraout_EDX_00);
      pvVar2 = _objc_msgSend(self->_items,sel_numberOfItems);
      if (pvVar2 <= pvVar1) goto LAB_000842dc;
      local_1d = 0;
      local_1e = '\0';
      pvVar2 = _objc_msgSend(self,sel_stack,puVar11,uVar15,uVar16);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperChildAtIndex_,pvVar1);
      pvVar3 = _objc_msgSend(self,sel_dragHelper);
      pcVar18 = &local_1e;
      puVar17 = &local_1d;
      pvVar3 = _objc_msgSend(pvVar3,
                             sel_performDragOperation_acceptingObject_runAnimationMode_didAddNewObject_
                             ,performDragOperation,pvVar2,puVar17,pcVar18);
      puVar11 = performDragOperation;
      if (((char)pvVar3 == '\0') || (local_1e == '\0')) goto LAB_000842dc;
      pvVar2 = _objc_msgSend(self->_items,sel_objectInStoryboardItemsAtIndex_,pvVar1,pvVar2,puVar17,
                             pcVar18);
      _objc_msgSend(pvVar2,sel_invalidateAllImageCaches);
      pvVar2 = _objc_msgSend(self,sel_imageLoader);
      _objc_msgSend(pvVar2,sel_validateInvalidItems);
      puVar11 = _objc_msgSend(self->_items,sel_objectInStoryboardItemsAtIndex_,pvVar1);
      pcVar14 = sel_setNeedsDisplayStoryboardItem_;
      goto LAB_000842d7;
    }
    pvVar2 = _objc_msgSend(self,sel_stack);
    pvVar2 = _objc_msgSend(pvVar2,sel_undoManager);
    pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    pcVar6 = &cfstr_UndoManager;
    pcVar10 = &cfstr_empty;
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_Paste,&cfstr_empty,
                           &cfstr_UndoManager);
    _objc_msgSend(pvVar2,sel_setMultipleActionsName_,pvVar3);
    pvVar2 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    _objc_msgSend(pvVar2,sel_disableObjectRegistration);
    pcVar9 = &cfstr_HSCardPasteboardType;
    pcVar13 = (cfstringStruct *)0x0;
    if (local_24 != (cfstringStruct *)0x7fffffff) {
      pcVar13 = local_24;
    }
    pvVar2 = _objc_msgSend(pvVar1,sel_propertyListForType_,&cfstr_HSCardPasteboardType,pcVar10,
                           pcVar6);
    if (pvVar2 == (id)0x0) {
      pvVar2 = _objc_msgSend(pvVar1,sel_types,pcVar9);
      puVar11 = PTR_00336414;
      uVar15 = *(undefined4 *)PTR_00336414;
      pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,uVar15);
      if ((char)pvVar2 != '\0') {
        pHVar12 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController,uVar15);
        pvVar2 = _objc_msgSend(self,sel_stack);
        pcVar6 = _objc_msgSend(pvVar2,sel_document);
        pvVar1 = _objc_msgSend(pvVar1,sel_propertyListForType_,*(undefined4 *)puVar11);
        pcVar14 = sel_importDataFromFiles_asCardWithIndex_toDocument_;
        goto LAB_00084226;
      }
      pvVar2 = _objc_msgSend(self,sel_canImportMovieFromPasteboard_,pvVar1);
      pcVar14 = sel_importMovieFromPasteboard_asCardWithIndex_;
      if (((char)pvVar2 != '\0') ||
         (pvVar2 = pvVar1, pvVar3 = _objc_msgSend(self,sel_canImportImageFromPasteboard_,pvVar1),
         pcVar14 = sel_importImageFromPasteboard_asCardWithIndex_, (char)pvVar3 != '\0'))
      goto LAB_00084226;
    }
    else {
      pHVar12 = _objc_msgSend(self,sel_stack,pcVar9);
      pcVar14 = sel_insertCardsFromPasteboard_atIndex_;
LAB_00084226:
      pvVar2 = pvVar1;
      _objc_msgSend(pHVar12,pcVar14,pvVar2,pcVar13,pcVar6);
      pcVar10 = pcVar13;
    }
    pvVar1 = _objc_msgSend(self,sel_stack,pvVar2,pcVar10,pcVar6);
    pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
    pvVar2 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
    puVar11 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_Paste,&cfstr_empty,
                            &cfstr_UndoManager);
    _objc_msgSend(pvVar1,sel_setMultipleActionsName_,puVar11);
    pHVar12 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    pcVar14 = sel_enableObjectRegistration;
  }
LAB_000842d7:
  _objc_msgSend(pHVar12,pcVar14,puVar11);
LAB_000842dc:
  pvVar1 = _objc_msgSend(self,sel_window,puVar11);
  _objc_msgSend(pvVar1,sel_makeKeyAndOrderFront_,0);
  pvVar1 = _objc_msgSend(self,sel_window);
  _objc_msgSend(pvVar1,sel_makeFirstResponder_,self);
  return '\x01';
}

*/
- (BOOL)performDragOperation:(id)aOperation
{
    NSPasteboard *pasteboard = [aOperation draggingPasteboard];
    NSUInteger dropIndex = [_items dropIndex];
    [self removeDragPlaceholder];
    for (id item in [_items draggedItems]) {
        [item setHighlighted:NO];
    }
    if ([pasteboard availableTypeFromArray:[self readablePasteboardTypes]] == nil) {
        return NO;
    }
    id container = [[self stack] queryHyperInterface:@protocol(HSNodeContainer)];
    id source = [aOperation draggingSource];
    id representedObject = [source respondsToSelector:@selector(representedObject)] ? [source representedObject] : nil;
    // Dragged from this view, or from another view showing the same stack.
    BOOL isInternal = source == self || (representedObject != nil && [self representedObject] == representedObject);
    if (isInternal && ([aOperation draggingSourceOperationMask] & NSDragOperationMove)) {
        [self beginModifingStack];
        NSIndexSet *initialIndexes = [_items draggedItemsInitialIndexes];
        if ([initialIndexes firstIndex] < dropIndex && dropIndex != NSNotFound) {
            // Dragged cards in front of the drop point no longer count once they are moved.
            NSUInteger first = [initialIndexes firstIndex];
            NSUInteger *buffer = malloc([initialIndexes count] * sizeof(NSUInteger));
            NSRange range = NSMakeRange(first, dropIndex - first);
            NSUInteger found = [initialIndexes getIndexes:buffer maxCount:dropIndex - first inIndexRange:&range];
            dropIndex -= found;
            free(buffer);
        }
        if (dropIndex != NSNotFound) {
            NSMutableArray *cards = [NSMutableArray array];
            [self selectObject:nil];
            NSMutableArray *movedCards = [NSMutableArray array];
            if ([aOperation draggingSource] == self) {
                NSUInteger insertionIndex = dropIndex;
                for (id item in [_items draggedItems]) {
                    id child = [[item card] queryHyperInterface:@protocol(HSNodeChild)];
                    NSUInteger index = [child hyperIndex];
                    [cards addObject:child];
                    if (index < insertionIndex) {
                        dropIndex++;
                    }
                    insertionIndex++;
                }
            } else {
                for (NSNumber *index in [pasteboard propertyListForType:@"HSCardsIndexPasteboardType"]) {
                    [cards addObject:[container hyperChildAtIndex:[index unsignedIntValue]]];
                }
            }
            for (id card in cards) {
                id child = [card queryHyperInterface:@protocol(HSNodeChild)];
                if (child == nil) {
                    break;
                }
                NSUInteger index = [child hyperIndex];
                [container setIndex:(dropIndex <= index ? dropIndex : dropIndex - 1) ofHyperChild:child];
                [movedCards addObject:[child queryHyperInterface:@protocol(HSCardAttributes)]];
                if (dropIndex <= index) {
                    dropIndex++;
                }
            }
            NSMutableArray *items = [NSMutableArray array];
            [_items invalidateWithChangedItemOrder];
            for (id card in movedCards) {
                [items addObject:[_items itemForCard:card]];
            }
            [self addItemsToSelection:items];
        }
        [self endModifingStack];
    } else if ([aOperation draggingSourceOperationMask] & NSDragOperationCopy) {
        if (_shiftPressed) {
            // Shift-drop: hand the drop to the card under the pointer.
            NSPoint point = [self convertPoint:[aOperation draggingLocation] fromView:nil];
            NSUInteger index = [[self storyboardLayout] itemIndexAtPoint:point];
            if (index < [_items numberOfItems]) {
                BOOL runAnimationMode = NO;
                BOOL didAddNewObject = NO;
                id card = [[self stack] hyperChildAtIndex:index];
                if ([[self dragHelper] performDragOperation:aOperation acceptingObject:card runAnimationMode:&runAnimationMode didAddNewObject:&didAddNewObject]
                    && didAddNewObject) {
                    [[_items objectInStoryboardItemsAtIndex:index] invalidateAllImageCaches];
                    [[self imageLoader] validateInvalidItems];
                    [self setNeedsDisplayStoryboardItem:[_items objectInStoryboardItemsAtIndex:index]];
                }
            }
        } else {
            NSString *actionName = [[NSBundle mainBundle] localizedStringForKey:@"Paste" value:@"" table:@"UndoManager"];
            [[[self stack] undoManager] setMultipleActionsName:actionName];
            [[HSCoachingHelpManager sharedCoachingHelpManager] disableObjectRegistration];
            NSUInteger insertionIndex = dropIndex != NSNotFound ? dropIndex : 0;
            if ([pasteboard propertyListForType:@"HSCardPasteboardType"] != nil) {
                [[self stack] insertCardsFromPasteboard:pasteboard atIndex:insertionIndex];
            } else if ([[pasteboard types] containsObject:NSFilenamesPboardType]) {
                [[HSEditorController sharedDocumentController] importDataFromFiles:[pasteboard propertyListForType:NSFilenamesPboardType] asCardWithIndex:insertionIndex toDocument:[[self stack] document]];
            } else if ([self canImportMovieFromPasteboard:pasteboard]) {
                [self importMovieFromPasteboard:pasteboard asCardWithIndex:insertionIndex];
            } else if ([self canImportImageFromPasteboard:pasteboard]) {
                [self importImageFromPasteboard:pasteboard asCardWithIndex:insertionIndex];
            }
            [[[self stack] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Paste" value:@"" table:@"UndoManager"]];
            [[HSCoachingHelpManager sharedCoachingHelpManager] enableObjectRegistration];
        }
    }
    [[self window] makeKeyAndOrderFront:nil];
    [[self window] makeFirstResponder:self];
    return YES;
}

- (BOOL)prepareForDragOperation:(id)aOperation
{
    BOOL bVar3;

    if (_allowDragAndDrop == NO) {
        bVar3 = NO;
    }
    else {
        bVar3 = [[aOperation draggingPasteboard] availableTypeFromArray:[self readablePasteboardTypes]] != nil;
    }
    return bVar3;
}

- (NSUInteger)draggingSourceOperationMaskForLocal:(BOOL)aLocal
{
    NSInteger pvVar1;
    unsigned int uVar2;

    if (aLocal == NO) {
        uVar2 = 5;
    }
    else {
        pvVar1 = [_items numberOfItems];
        uVar2 = 5;
        if (0x1 < pvVar1) {
            uVar2 = 0x15;
        }
    }
    return uVar2;
}

- (void)draggedImage:(id)aImage endedAt:(NSPoint)aAt operation:(NSUInteger)aOperation
{
    id self_00;
    NSEnumerator *pvVar1_3;

    pvVar1_3 = [[[self items] draggedItems] objectEnumerator];
    while( YES ) {
        self_00 = [pvVar1_3 nextObject];
        if (self_00 == nil) break;
        [self_00 setHighlighted:NO];
    }
    [_items clearDraggedItems];
    [_items synchronizeWithStack];
}

- (void)draggingEnded:(id)aEnded
{

}

- (void)draggingExited:(id)aExited
{
    [self removeDragPlaceholder];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00082133 @ 00082133, 963 bytes * /

uint FUN_00082133(HSStoryboardView *self,SEL _cmd,id draggingUpdated)

{
  id pvVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  HSStoryboardView *pHVar4;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  SEL op;
  undefined *puVar5;
  undefined4 uVar6;
  uint local_14;
  
  pvVar1 = _objc_msgSend(draggingUpdated,sel_draggingSourceOperationMask);
  self_00 = _objc_msgSend(draggingUpdated,sel_draggingPasteboard);
  pvVar2 = _objc_msgSend(self,sel_readablePasteboardTypes);
  pvVar3 = _objc_msgSend(self_00,sel_availableTypeFromArray_,pvVar2);
  if (pvVar3 == (id)0x0) {
    return (uint)pvVar1;
  }
  pvVar1 = _objc_msgSend(draggingUpdated,sel_draggingSource,pvVar2);
  puVar5 = sel_representedObject;
  pvVar1 = _objc_msgSend(pvVar1,sel_respondsToSelector_,sel_representedObject);
  if ((char)pvVar1 == '\0') {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(draggingUpdated,sel_draggingSource,puVar5);
    pvVar1 = _objc_msgSend(pvVar1,sel_representedObject);
  }
  pHVar4 = _objc_msgSend(draggingUpdated,sel_draggingSource,puVar5);
  if (((pHVar4 == self) ||
      ((pvVar1 != (id)0x0 &&
       (pvVar2 = _objc_msgSend(self,sel_representedObject,puVar5), pvVar2 == pvVar1)))) &&
     (pvVar1 = _objc_msgSend(draggingUpdated,sel_draggingSourceOperationMask,puVar5),
     ((uint)pvVar1 & 0x14) != 0)) {
    local_14 = 0x10;
  }
  else {
    pvVar1 = _objc_msgSend(self_00,sel_types,puVar5);
    puVar5 = *(undefined **)PTR_00336414;
    pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,puVar5);
    if ((((char)pvVar1 == '\0') &&
        (puVar5 = self_00, pvVar1 = _objc_msgSend(self,sel_canImportImageFromPasteboard_,self_00),
        (char)pvVar1 == '\0')) &&
       (pvVar1 = _objc_msgSend(self,sel_canImportMovieFromPasteboard_,self_00), puVar5 = self_00,
       (char)pvVar1 == '\0')) {
      return 0;
    }
    local_14 = 1;
  }
  pvVar1 = _objc_msgSend(draggingUpdated,sel_draggingLocation,puVar5);
  pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  pvVar1 = _objc_msgSend(self,sel_storyboardLayout);
  uVar6 = extraout_EDX_00;
  pvVar1 = _objc_msgSend(pvVar1,sel_itemIndexAtPoint_,pvVar2,extraout_EDX_00);
  pvVar3 = _objc_msgSend(*(id *)PTR_00336058,sel_currentEvent);
  pvVar3 = _objc_msgSend(pvVar3,sel_modifierFlags);
  self->_shiftPressed = (byte)((uint)pvVar3 >> 0x11) & 1;
  if (((uint)pvVar3 >> 0x11 & 1) == 0) {
    pvVar3 = _objc_msgSend(self->_items,sel_numberOfItems,pvVar2,uVar6);
    if (pvVar3 < pvVar1) {
      pvVar1 = _objc_msgSend(self->_items,sel_numberOfItems,pvVar2,uVar6);
    }
    op = sel_insertDragPlaceholderAtIndex_;
    if ((local_14 == 0x10) &&
       (pvVar2 = _objc_msgSend(self->_items,sel_isDraggedSolidGroup),
       op = sel_insertDragPlaceholderAtIndex_, (char)pvVar2 != '\0')) {
      pvVar3 = _objc_msgSend(self->_items,sel_draggedItemsInitialIndexes);
      pvVar2 = pvVar1;
      pvVar3 = _objc_msgSend(pvVar3,sel_containsIndex_,pvVar1);
      if ((char)pvVar3 == '\0') {
        pvVar3 = _objc_msgSend(self->_items,sel_draggedItemsInitialIndexes,pvVar2);
        pvVar3 = _objc_msgSend(pvVar3,sel_lastIndex);
        op = sel_insertDragPlaceholderAtIndex_;
        if ((id)((int)pvVar3 + 1) != pvVar1) goto LAB_000824d0;
      }
      op = sel_removeDragPlaceholder;
      pvVar1 = pvVar2;
    }
  }
  else {
    _objc_msgSend(self,sel_removeDragPlaceholder,pvVar2,uVar6);
    pvVar2 = _objc_msgSend(self->_items,sel_numberOfItems);
    if (pvVar2 <= pvVar1) {
      return local_14;
    }
    pvVar1 = _objc_msgSend(self->_items,sel_objectInStoryboardItemsAtIndex_,pvVar1);
    op = sel_selectItem_;
  }
LAB_000824d0:
  _objc_msgSend(self,op,pvVar1);
  return local_14;
}

*/
- (NSUInteger)draggingUpdated:(id)aUpdated
{
    NSDragOperation sourceMask = [aUpdated draggingSourceOperationMask];
    NSPasteboard *pasteboard = [aUpdated draggingPasteboard];
    if ([pasteboard availableTypeFromArray:[self readablePasteboardTypes]] == nil) {
        return sourceMask;
    }
    id source = [aUpdated draggingSource];
    id representedObject = [source respondsToSelector:@selector(representedObject)] ? [source representedObject] : nil;
    // Dragged from this view, or from another view showing the same stack.
    BOOL isInternal = source == self || (representedObject != nil && [self representedObject] == representedObject);
    NSDragOperation operation;
    if (isInternal && ([aUpdated draggingSourceOperationMask] & (NSDragOperationMove | NSDragOperationGeneric))) {
        operation = NSDragOperationMove;
    } else {
        if (![[pasteboard types] containsObject:NSFilenamesPboardType]
            && ![self canImportImageFromPasteboard:pasteboard]
            && ![self canImportMovieFromPasteboard:pasteboard]) {
            return NSDragOperationNone;
        }
        operation = NSDragOperationCopy;
    }
    NSPoint point = [self convertPoint:[aUpdated draggingLocation] fromView:nil];
    NSUInteger index = [[self storyboardLayout] itemIndexAtPoint:point];
    _shiftPressed = ([[NSApp currentEvent] modifierFlags] & NSEventModifierFlagShift) != 0;
    if (_shiftPressed) {
        // Shift targets the card under the pointer instead of inserting.
        [self removeDragPlaceholder];
        if (index >= [_items numberOfItems]) {
            return operation;
        }
        [self selectItem:[_items objectInStoryboardItemsAtIndex:index]];
        return operation;
    }
    if (index > [_items numberOfItems]) {
        index = [_items numberOfItems];
    }
    if (operation == NSDragOperationMove && [_items isDraggedSolidGroup]
        && ([[_items draggedItemsInitialIndexes] containsIndex:index] || [[_items draggedItemsInitialIndexes] lastIndex] + 1 == index)) {
        // Dropping a contiguous group onto itself changes nothing.
        [self removeDragPlaceholder];
    } else {
        [self insertDragPlaceholderAtIndex:index];
    }
    return operation;
}

- (void)insertDragPlaceholderAtIndex:(NSUInteger)aIndex
{
    [self removeDragPlaceholder];
    [_items insertDragPlaceholderAtIndex:aIndex];
    [self invalidateAreaAroundIndex:aIndex];
}

- (void)removeDragPlaceholder
{
    NSUInteger pvVar1;

    pvVar1 = [_items dropIndex];
    [_items removeDragPlaceholder];
    if (pvVar1 != NSNotFound) {
        [self invalidateAreaAroundIndex:pvVar1];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00084344 @ 00084344, 214 bytes * /

void FUN_00084344(HSStoryboardView *self,SEL _cmd,int invalidateAreaAroundIndex)

{
  id pvVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  undefined4 uVar5;
  undefined1 local_34 [16];
  undefined1 local_24 [20];
  
  pvVar1 = _objc_msgSend(self,sel_storyboardLayout);
  _objc_msgSend_stret(local_34,pvVar1,sel_frameForItemAtIndex_,invalidateAreaAroundIndex);
  uVar4 = (undefined4)local_34._8_8_;
  uVar5 = SUB84(local_34._8_8_,4);
  uVar2 = (undefined4)local_34._0_8_;
  uVar3 = SUB84(local_34._0_8_,4);
  _objc_msgSend(self,sel_setNeedsDisplayInRect_,uVar2,uVar3,uVar4,uVar5);
  if (invalidateAreaAroundIndex != 0) {
    pvVar1 = _objc_msgSend(self,sel_storyboardLayout,uVar2,uVar3,uVar4,uVar5);
    _objc_msgSend_stret(local_24,pvVar1,sel_frameForItemAtIndex_,invalidateAreaAroundIndex + -1);
    _objc_msgSend(self,sel_setNeedsDisplayInRect_,(int)local_24._0_8_,SUB84(local_24._0_8_,4),
                  (int)local_24._8_8_,SUB84(local_24._8_8_,4));
  }
  return;
}

*/
- (void)invalidateAreaAroundIndex:(NSInteger)aIndex
{
    [self setNeedsDisplayInRect:[[self storyboardLayout] frameForItemAtIndex:aIndex]];
    if (aIndex != 0) {
        [self setNeedsDisplayInRect:[[self storyboardLayout] frameForItemAtIndex:aIndex - 1]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00081ea4 @ 00081ea4, 461 bytes * /

uint FUN_00081ea4(HSStoryboardView *self,SEL _cmd,id draggingEntered)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  HSStoryboardView *pHVar5;
  uint uVar6;
  
  pvVar1 = _objc_msgSend(draggingEntered,sel_draggingPasteboard);
  pvVar2 = _objc_msgSend(self,sel_readablePasteboardTypes);
  pvVar3 = _objc_msgSend(pvVar1,sel_availableTypeFromArray_,pvVar2);
  if ((pvVar3 == (id)0x0) || (self->_allowDragAndDrop == '\0')) {
    return 0;
  }
  pvVar3 = _objc_msgSend(draggingEntered,sel_draggingSource,pvVar2);
  pvVar4 = _objc_msgSend(self,sel_stack);
  if ((pvVar3 == pvVar4) &&
     (pvVar3 = _objc_msgSend(draggingEntered,sel_draggingSourceOperationMask,pvVar2),
     ((uint)pvVar3 & 0x10) != 0)) {
    uVar6 = 0x10;
  }
  else {
    pvVar3 = _objc_msgSend(draggingEntered,sel_draggingSourceOperationMask,pvVar2);
    if (((uint)pvVar3 & 1) != 0) {
      pvVar3 = _objc_msgSend(pvVar1,sel_types);
      pvVar2 = *(id *)PTR_00336414;
      pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar2);
      if ((((char)pvVar3 != '\0') ||
          (pvVar2 = pvVar1, pvVar3 = _objc_msgSend(self,sel_canImportImageFromPasteboard_,pvVar1),
          (char)pvVar3 != '\0')) ||
         (pvVar3 = _objc_msgSend(self,sel_canImportMovieFromPasteboard_,pvVar1), pvVar2 = pvVar1,
         (char)pvVar3 != '\0')) {
        uVar6 = 1;
        goto LAB_00081fef;
      }
    }
    uVar6 = 0;
  }
LAB_00081fef:
  pHVar5 = _objc_msgSend(draggingEntered,sel_draggingSource,pvVar2);
  if (pHVar5 == self) {
    pvVar1 = _objc_msgSend(self->_items,sel_selectedItems,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    while (pvVar3 = _objc_msgSend(pvVar1,sel_nextObject,pvVar2), pvVar3 != (id)0x0) {
      pvVar2 = (id)0x1;
      _objc_msgSend(pvVar3,sel_setHighlighted_,1);
    }
  }
  return uVar6;
}

*/
- (NSUInteger)draggingEntered:(id)aEntered
{
    NSPasteboard *pasteboard = [aEntered draggingPasteboard];
    if ([pasteboard availableTypeFromArray:[self readablePasteboardTypes]] == nil || !_allowDragAndDrop) {
        return NSDragOperationNone;
    }
    NSDragOperation operation = NSDragOperationNone;
    // The original compares the source with the stack here, not with the view.
    if ([aEntered draggingSource] == [self stack] && ([aEntered draggingSourceOperationMask] & NSDragOperationMove)) {
        operation = NSDragOperationMove;
    } else if (([aEntered draggingSourceOperationMask] & NSDragOperationCopy)
               && ([[pasteboard types] containsObject:NSFilenamesPboardType]
                   || [self canImportImageFromPasteboard:pasteboard]
                   || [self canImportMovieFromPasteboard:pasteboard])) {
        operation = NSDragOperationCopy;
    }
    if ([aEntered draggingSource] == self) {
        for (id item in [_items selectedItems]) {
            [item setHighlighted:YES];
        }
    }
    return operation;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00081d5a @ 00081d5a, 330 bytes * /

void FUN_00081d5a(HSStoryboardView *self,SEL _cmd,id importImageFromPasteboard,uint asCardWithIndex)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar1 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,importImageFromPasteboard);
  pvVar3 = importImageFromPasteboard;
  pvVar2 = _objc_msgSend(cls_NSImage,sel_canInitWithPasteboard_,importImageFromPasteboard);
  if ((char)pvVar2 == '\0') {
    if (pvVar1 == (id)0x0) {
      pvVar2 = (id)0x0;
      importImageFromPasteboard = pvVar3;
      goto LAB_00081e8a;
    }
    pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar3);
    importImageFromPasteboard = pvVar1;
    pvVar2 = _objc_msgSend(pvVar3,sel_initWithContentsOfURL_,pvVar1);
    if (pvVar2 == (id)0x0) goto LAB_00081e8a;
  }
  else {
    pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc,pvVar3);
    pvVar2 = _objc_msgSend(pvVar3,sel_initWithPasteboard_,importImageFromPasteboard);
  }
  pvVar3 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController,
                         importImageFromPasteboard);
  pvVar4 = _objc_msgSend(self,sel_stack);
  pvVar4 = _objc_msgSend(pvVar4,sel_document);
  importImageFromPasteboard = pvVar2;
  _objc_msgSend(pvVar3,sel_importImage_withFileURL_asCardWithIndex_toDocument_,pvVar2,pvVar1,
                asCardWithIndex,pvVar4);
LAB_00081e8a:
  _objc_msgSend(pvVar2,sel_release,importImageFromPasteboard);
  return;
}

*/
- (void)importImageFromPasteboard:(id)aPasteboard asCardWithIndex:(NSUInteger)aIndex
{
    NSURL *url = [NSURL URLFromPasteboard:aPasteboard];
    NSImage *image = nil;
    if ([NSImage canInitWithPasteboard:aPasteboard]) {
        image = [[NSImage alloc] initWithPasteboard:aPasteboard];
    } else if (url != nil) {
        image = [[NSImage alloc] initWithContentsOfURL:url];
    }
    if (image != nil) {
        [[HSEditorController sharedDocumentController] importImage:image withFileURL:url asCardWithIndex:aIndex toDocument:[[self stack] document]];
    }
    [image release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00081c2f @ 00081c2f, 299 bytes * /

BOOL FUN_00081c2f(HSStoryboardView *self,SEL _cmd,id canImportImageFromPasteboard)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar3 = canImportImageFromPasteboard;
  pvVar2 = _objc_msgSend(cls_NSImage,sel_canInitWithPasteboard_,canImportImageFromPasteboard);
  cVar1 = (char)pvVar2;
  if (cVar1 == '\0') {
    pvVar3 = _objc_msgSend(canImportImageFromPasteboard,sel_types,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,*(undefined4 *)PTR_00336418);
    if (((char)pvVar3 != '\0') &&
       (pvVar3 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,canImportImageFromPasteboard),
       pvVar3 != (id)0x0)) {
      pvVar3 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,canImportImageFromPasteboard);
      pvVar3 = _objc_msgSend(pvVar3,sel_absoluteURL);
      pvVar3 = _objc_msgSend(pvVar3,sel_path);
      pvVar3 = _objc_msgSend(pvVar3,sel_pathExtension);
      pvVar2 = _objc_msgSend(cls_NSImage,sel_imageFileTypes);
      pvVar3 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar3);
      cVar1 = (char)pvVar3;
    }
  }
  return cVar1;
}

*/
- (BOOL)canImportImageFromPasteboard:(id)aPasteboard
{
    if ([NSImage canInitWithPasteboard:aPasteboard]) {
        return YES;
    }
    if (![[aPasteboard types] containsObject:NSURLPboardType] || [NSURL URLFromPasteboard:aPasteboard] == nil) {
        return NO;
    }
    NSString *extension = [[[[NSURL URLFromPasteboard:aPasteboard] absoluteURL] path] pathExtension];
    return [[NSImage imageFileTypes] containsObject:extension];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000819d3 @ 000819d3, 604 bytes * /

void FUN_000819d3(HSStoryboardView *self,SEL _cmd,id importMovieFromPasteboard,uint asCardWithIndex)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  SEL op;
  undefined4 uVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  undefined4 uVar9;
  
  pvVar1 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,importMovieFromPasteboard);
  pvVar3 = importMovieFromPasteboard;
  pvVar2 = _objc_msgSend(cls_QTMovie,sel_canInitWithPasteboard_,importMovieFromPasteboard);
  if ((char)pvVar2 == '\0') {
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar3 = _objc_msgSend(cls_NSDictionary,sel_alloc,pvVar3);
    uVar7 = *(undefined4 *)PTR_003361c8;
    uVar8 = *(undefined4 *)PTR_003361d0;
    uVar6 = *(undefined4 *)PTR_00336420;
    importMovieFromPasteboard = pvVar1;
  }
  else {
    pvVar3 = _objc_msgSend(cls_NSDictionary,sel_alloc,pvVar3);
    uVar7 = *(undefined4 *)PTR_003361c8;
    uVar8 = *(undefined4 *)PTR_003361d0;
    uVar6 = *(undefined4 *)PTR_0033641c;
  }
  uVar9 = 0;
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithObjectsAndKeys_,importMovieFromPasteboard,uVar6,uVar8,
                         uVar7,0);
  if (pvVar3 != (id)0x0) {
    pvVar4 = _objc_msgSend(cls_QTMovie,sel_alloc,importMovieFromPasteboard,uVar6,uVar8,uVar7,uVar9);
    uVar6 = 0;
    pvVar2 = pvVar3;
    pvVar4 = _objc_msgSend(pvVar4,sel_initWithAttributes_error_,pvVar3,0);
    _objc_msgSend(pvVar3,sel_release);
    if (pvVar4 != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_HSMovieVerifier,sel_alloc,pvVar2,uVar6,uVar8,uVar7,uVar9);
      pvVar2 = _objc_msgSend(pvVar3,sel_init);
      uVar8 = 0;
      uVar7 = 0;
      pvVar3 = pvVar4;
      pvVar5 = _objc_msgSend(pvVar2,sel_verifyMovie_withOptions_error_,pvVar4,0,0);
      _objc_msgSend(pvVar2,sel_release);
      op = sel_autorelease;
      if (pvVar4 != pvVar5) {
        op = sel_release;
      }
      _objc_msgSend(pvVar4,op,pvVar3,uVar7,uVar8);
      if (pvVar5 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController,pvVar3,uVar7,
                               uVar8);
        pvVar2 = _objc_msgSend(self,sel_stack);
        pvVar2 = _objc_msgSend(pvVar2,sel_document);
        _objc_msgSend(pvVar3,sel_importMovie_withFileURL_asCardWithIndex_toDocument_,pvVar5,pvVar1,
                      asCardWithIndex,pvVar2);
      }
    }
  }
  return;
}

*/
- (void)importMovieFromPasteboard:(id)aPasteboard asCardWithIndex:(NSUInteger)aIndex
{
    NSURL *url = [NSURL URLFromPasteboard:aPasteboard];
    NSDictionary *attributes;
    if ([QTMovie canInitWithPasteboard:aPasteboard]) {
        attributes = [[NSDictionary alloc] initWithObjectsAndKeys:aPasteboard, QTMoviePasteboardAttribute, (id)kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
    } else if (url != nil) {
        attributes = [[NSDictionary alloc] initWithObjectsAndKeys:url, QTMovieURLAttribute, (id)kCFBooleanFalse, QTMovieResolveDataRefsAttribute, nil];
    } else {
        return;
    }
    if (attributes == nil) {
        return;
    }
    QTMovie *movie = [[QTMovie alloc] initWithAttributes:attributes error:NULL];
    [attributes release];
    if (movie == nil) {
        return;
    }
    HSMovieVerifier *verifier = [[HSMovieVerifier alloc] init];
    QTMovie *verifiedMovie = [verifier verifyMovie:movie withOptions:0 error:NULL];
    [verifier release];
    // The verifier may hand back a different (converted) movie.
    if (movie == verifiedMovie) {
        [movie autorelease];
    } else {
        [movie release];
    }
    if (verifiedMovie != nil) {
        [[HSEditorController sharedDocumentController] importMovie:verifiedMovie withFileURL:url asCardWithIndex:aIndex toDocument:[[self stack] document]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000818a8 @ 000818a8, 299 bytes * /

BOOL FUN_000818a8(HSStoryboardView *self,SEL _cmd,id canImportMovieFromPasteboard)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar3 = canImportMovieFromPasteboard;
  pvVar2 = _objc_msgSend(cls_QTMovie,sel_canInitWithPasteboard_,canImportMovieFromPasteboard);
  cVar1 = (char)pvVar2;
  if (cVar1 == '\0') {
    pvVar3 = _objc_msgSend(canImportMovieFromPasteboard,sel_types,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,*(undefined4 *)PTR_00336418);
    if (((char)pvVar3 != '\0') &&
       (pvVar3 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,canImportMovieFromPasteboard),
       pvVar3 != (id)0x0)) {
      pvVar3 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,canImportMovieFromPasteboard);
      pvVar3 = _objc_msgSend(pvVar3,sel_absoluteURL);
      pvVar3 = _objc_msgSend(pvVar3,sel_path);
      pvVar3 = _objc_msgSend(pvVar3,sel_pathExtension);
      pvVar2 = _objc_msgSend(cls_HSMovieObject,sel_movieFileTypes);
      pvVar3 = _objc_msgSend(pvVar2,sel_containsObject_,pvVar3);
      cVar1 = (char)pvVar3;
    }
  }
  return cVar1;
}

*/
- (BOOL)canImportMovieFromPasteboard:(id)aPasteboard
{
    if ([QTMovie canInitWithPasteboard:aPasteboard]) {
        return YES;
    }
    if (![[aPasteboard types] containsObject:NSURLPboardType] || [NSURL URLFromPasteboard:aPasteboard] == nil) {
        return NO;
    }
    NSString *extension = [[[[NSURL URLFromPasteboard:aPasteboard] absoluteURL] path] pathExtension];
    return [[HSMovieObject movieFileTypes] containsObject:extension];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00081616 @ 00081616, 658 bytes * /

void FUN_00081616(HSStoryboardView *self,SEL _cmd,id mouseDragged)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar5;
  undefined4 *puVar6;
  undefined4 local_1c;
  undefined4 local_18;
  undefined4 local_14;
  
  if (self->_allowDragAndDrop != '\0') {
    self->_shouldSelectItem = '\0';
    pvVar1 = _objc_msgSend(mouseDragged,sel_locationInWindow);
    pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
    local_14 = 0x7fffffff;
    puVar6 = &local_14;
    uVar5 = extraout_EDX_00;
    pvVar2 = _objc_msgSend(self,sel_itemAtPoint_index_,pvVar1,extraout_EDX_00,puVar6);
    if (pvVar2 != (id)0x0) {
      pvVar3 = _objc_msgSend(self->_items,sel_numberOfItems,pvVar1,uVar5,puVar6);
      if (pvVar3 != (id)0x0) {
        pvVar3 = _objc_msgSend(self->_items,sel_selectedItems,pvVar1,uVar5,puVar6);
        pvVar1 = pvVar2;
        pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar2);
        if ((char)pvVar3 == '\0') {
          pvVar1 = pvVar2;
          _objc_msgSend(self,sel_selectItem_,pvVar2,uVar5,puVar6);
        }
        self_00 = cls_NSMutableArray;
        pvVar1 = _objc_msgSend(self->_items,sel_selectedItems,pvVar1);
        pvVar1 = _objc_msgSend(self_00,sel_arrayWithArray_,pvVar1);
        pvVar3 = _objc_msgSend(cls_NSPasteboard,sel_pasteboardWithName_,*(undefined4 *)PTR_00336390)
        ;
        pvVar4 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_HSCardPasteboardType,
                               &cfstr_HSCardsIndexPasteboardType,0);
        _objc_msgSend(pvVar3,sel_declareTypes_owner_,pvVar4,0);
        _objc_msgSend(self,sel_writeSelectedCardsToPasteboard_,pvVar3);
        _objc_msgSend(self->_items,sel_setDraggedItems_,pvVar1);
        local_1c = *(undefined4 *)PTR_00336074;
        local_18 = *(undefined4 *)(PTR_00336074 + 4);
        pvVar1 = _objc_msgSend(self,sel_dragImageWithOrigin_hitItem_,&local_1c,pvVar2);
        _objc_msgSend(self,sel_dragImage_at_offset_event_pasteboard_source_slideBack_,pvVar1,
                      local_1c,local_18,*(undefined4 *)PTR_0033607c,
                      *(undefined4 *)(PTR_0033607c + 4),mouseDragged,pvVar3,self,1);
      }
    }
  }
  return;
}

*/
- (void)mouseDragged:(id)aDragged
{
    if (!_allowDragAndDrop) {
        return;
    }
    _shouldSelectItem = NO;
    NSPoint point = [self convertPoint:[aDragged locationInWindow] fromView:nil];
    unsigned int index = INT_MAX;
    id item = [self itemAtPoint:point index:&index];
    if (item == nil || [_items numberOfItems] == 0) {
        return;
    }
    if (![[_items selectedItems] containsObject:item]) {
        [self selectItem:item];
    }
    NSMutableArray *draggedItems = [NSMutableArray arrayWithArray:[_items selectedItems]];
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pasteboard declareTypes:[NSArray arrayWithObjects:@"HSCardPasteboardType", @"HSCardsIndexPasteboardType", nil] owner:nil];
    [self writeSelectedCardsToPasteboard:pasteboard];
    [_items setDraggedItems:draggedItems];
    NSPoint origin = NSZeroPoint;
    NSImage *image = [self dragImageWithOrigin:&origin hitItem:item];
    [self dragImage:image at:origin offset:NSZeroSize event:aDragged pasteboard:pasteboard source:self slideBack:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008122b @ 0008122b, 1003 bytes * /

void FUN_0008122b(HSStoryboardView *self,SEL _cmd,id writeSelectedCardsToPasteboard)

{
  bool bVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id self_01;
  id self_02;
  id self_03;
  id self_04;
  id pvVar4;
  id pvVar5;
  undefined4 extraout_EDX;
  undefined4 uVar6;
  id local_20;
  
  pvVar2 = _objc_msgSend(self->_items,sel_selectedItems);
  pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_HSCardPasteboardType,
                         &cfstr_HSCardsIndexPasteboardType,0);
  uVar6 = 0;
  _objc_msgSend(writeSelectedCardsToPasteboard,sel_declareTypes_owner_,pvVar3,0);
  self_01 = _objc_msgSend(cls_NSMutableArray,sel_array);
  self_02 = _objc_msgSend(cls_NSMutableArray,sel_array);
  self_03 = _objc_msgSend(cls_NSMutableSet,sel_set);
  self_04 = _objc_msgSend(cls_NSMutableSet,sel_set);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  pvVar4 = _objc_msgSend(pvVar2,sel_nextObject);
  if (pvVar4 == (id)0x0) {
    local_20 = (id)0x0;
  }
  else {
    bVar1 = false;
    local_20 = (id)0x0;
    do {
      if (!bVar1) {
        pvVar3 = _objc_msgSend(pvVar4,sel_card,pvVar3);
        pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00365e44);
        pvVar3 = _objc_msgSend(pvVar3,sel_size);
        pvVar5 = _objc_msgSend(pvVar4,sel_card);
        pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_00365f0c);
        bVar1 = true;
        uVar6 = extraout_EDX;
        local_20 = _objc_msgSend(pvVar5,sel_imageOfSize_,pvVar3,extraout_EDX);
      }
      pvVar3 = _objc_msgSend(pvVar4,sel_card,pvVar3,uVar6);
      pvVar3 = _objc_msgSend(pvVar3,sel_fullDictionaryRepresentation);
      _objc_msgSend(self_02,sel_addObject_,pvVar3);
      pvVar3 = _objc_msgSend(pvVar4,sel_card);
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00365f20);
      pvVar3 = _objc_msgSend(pvVar3,sel_mediaUIDs);
      _objc_msgSend(self_03,sel_unionSet_,pvVar3);
      pvVar3 = _objc_msgSend(pvVar4,sel_card);
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00365f34);
      pvVar3 = _objc_msgSend(pvVar3,sel_unrefreshingUIDs);
      _objc_msgSend(self_04,sel_unionSet_,pvVar3);
      self_00 = cls_NSNumber;
      pvVar3 = _objc_msgSend(self,sel_stack);
      pvVar4 = _objc_msgSend(pvVar4,sel_card);
      pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_00365f48);
      pvVar3 = _objc_msgSend(pvVar3,sel_indexOfHyperChild_,pvVar4);
      pvVar3 = _objc_msgSend(self_00,sel_numberWithUnsignedInt_,pvVar3);
      _objc_msgSend(self_01,sel_addObject_);
      pvVar4 = _objc_msgSend(pvVar2,sel_nextObject);
    } while (pvVar4 != (id)0x0);
  }
  _objc_msgSend(self,
                sel_writeCardsRepresentations_andMediaUIDs_andUnrefreshingUIDs_cardImage_toPasteboard_
                ,self_02,self_03,self_04,local_20,writeSelectedCardsToPasteboard);
  _objc_msgSend(writeSelectedCardsToPasteboard,sel_setPropertyList_forType_,self_01,
                &cfstr_HSCardsIndexPasteboardType);
  return;
}

*/
- (void)writeSelectedCardsToPasteboard:(id)aPasteboard
{
    NSArray *selectedItems = [_items selectedItems];
    [aPasteboard declareTypes:[NSArray arrayWithObjects:@"HSCardPasteboardType", @"HSCardsIndexPasteboardType", nil] owner:nil];
    NSMutableArray *indexes = [NSMutableArray array];
    NSMutableArray *representations = [NSMutableArray array];
    NSMutableSet *mediaUIDs = [NSMutableSet set];
    NSMutableSet *unrefreshingUIDs = [NSMutableSet set];
    NSImage *cardImage = nil;
    for (id item in selectedItems) {
        if (cardImage == nil) {
            // The first card's picture represents the whole drag.
            NSSize size = [(id<HSSizeAttributes>)[[item card] queryHyperInterface:@protocol(HSSizeAttributes)] size];
            cardImage = [[[item card] queryHyperInterface:@protocol(HSUserObjectImageProvider)] imageOfSize:size];
        }
        [representations addObject:[[item card] fullDictionaryRepresentation]];
        [mediaUIDs unionSet:[[[item card] queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs]];
        [unrefreshingUIDs unionSet:[[[item card] queryHyperInterface:@protocol(HSActionCopySupport)] unrefreshingUIDs]];
        [indexes addObject:[NSNumber numberWithUnsignedInt:(unsigned int)[[self stack] indexOfHyperChild:[[item card] queryHyperInterface:@protocol(HSNodeChild)]]]];
    }
    [self writeCardsRepresentations:representations andMediaUIDs:mediaUIDs andUnrefreshingUIDs:unrefreshingUIDs cardImage:cardImage toPasteboard:aPasteboard];
    [aPasteboard setPropertyList:indexes forType:@"HSCardsIndexPasteboardType"];
}

- (BOOL)writeCardsRepresentations:(id)aRepresentations andMediaUIDs:(id)aDs andUnrefreshingUIDs:(id)aDs2 cardImage:(id)aImage toPasteboard:(id)aPasteboard
{
    return (BOOL)[[[[HSPasteboardDataProvider allocWithZone:[self zone]] initWithCards:aRepresentations UIDs:aDs groupUIDs:[[[self stack] cardGroupController] allGroupedObjectsUIDs] unrefreshingUIDs:aDs2 cardImage:aImage] autorelease] declareTypesForPasteboard:aPasteboard];
}

- (void)setAllowDragAndDrop:(BOOL)aDrop
{
    _allowDragAndDrop = aDrop;
}

- (BOOL)allowDragAndDrop
{
    return _allowDragAndDrop;
}

- (void)removeItemFromSelection:(id)aSelection
{
    BOOL pvVar1;

    if (((aSelection == nil) || (pvVar1 = [aSelection isSelected], !pvVar1)) || (_allowEmptySelection == NO)) {
        if (_allowEmptySelection != NO) {
            return;
        }
        if ([[_items selectedItems] count] < 0x2) {
            return;
        }
    }
    [aSelection setSelected:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008100e @ 0008100e, 174 bytes * /

void FUN_0008100e(HSStoryboardView *self,SEL _cmd,id addItemToSelection)

{
  id pvVar1;
  SEL op;
  
  if (((addItemToSelection == (id)0x0) ||
      (pvVar1 = _objc_msgSend(addItemToSelection,sel_isSelected), (char)pvVar1 != '\0')) ||
     (self->_allowMultipleSelection == '\0')) {
    if (self->_allowMultipleSelection == '\0') {
      pvVar1 = _objc_msgSend(self->_items,sel_selectedItems);
      pvVar1 = _objc_msgSend(pvVar1,sel_count);
      if (pvVar1 == (id)0x0) goto LAB_0008107a;
    }
    if (addItemToSelection == (id)0x0) {
      return;
    }
    op = sel_selectItem_;
    if (self->_allowMultipleSelection != '\0') {
      return;
    }
  }
  else {
LAB_0008107a:
    self = addItemToSelection;
    op = sel_setSelected_;
    addItemToSelection = (id)0x1;
  }
  _objc_msgSend(self,op,addItemToSelection);
  return;
}

*/
- (void)addItemToSelection:(id)aSelection
{
    if (aSelection != nil && ![aSelection isSelected] && _allowMultipleSelection) {
        [aSelection setSelected:YES];
        return;
    }
    if (!_allowMultipleSelection && [[_items selectedItems] count] == 0) {
        [aSelection setSelected:YES];
        return;
    }
    if (aSelection == nil || _allowMultipleSelection) {
        return;
    }
    [self selectItem:aSelection];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00080f0e @ 00080f0e, 256 bytes * /

void FUN_00080f0e(HSStoryboardView *self,SEL _cmd,id removeItemsFromSelection)

{
  id pvVar1;
  id pvVar2;
  
  if (self->_allowEmptySelection == '\0') {
    pvVar1 = _objc_msgSend(self->_items,sel_selectedItems);
    pvVar1 = _objc_msgSend(pvVar1,sel_count);
    pvVar2 = _objc_msgSend(removeItemsFromSelection,sel_count);
    if (pvVar1 == pvVar2) {
      return;
    }
  }
  pvVar1 = _objc_msgSend(removeItemsFromSelection,sel_objectEnumerator);
  while (pvVar2 = _objc_msgSend(pvVar1,sel_nextObject), pvVar2 != (id)0x0) {
    _objc_msgSend(self,sel_removeItemFromSelection_,pvVar2);
  }
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                &cfstr_HSStoryboardViewDidChangeSelectionNotification,self);
  _objc_msgSend(self,sel_notifyHyperSelectionDidChangeAndActivate_,0);
  return;
}

*/
- (void)removeItemsFromSelection:(id)aSelection
{
    if (!_allowEmptySelection && [[_items selectedItems] count] == [aSelection count]) {
        return;
    }
    for (id item in aSelection) {
        [self removeItemFromSelection:item];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSStoryboardViewDidChangeSelectionNotification" object:self];
    [self notifyHyperSelectionDidChangeAndActivate:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008441a @ 0008441a, 304 bytes * /

void FUN_0008441a(HSStoryboardView *self,SEL _cmd,id addItemsToSelection)

{
  id pvVar1;
  id pvVar2;
  undefined4 *puVar3;
  undefined1 local_24 [20];
  
  puVar3 = (undefined4 *)&stack0xffffffc4;
  if (self->_allowMultipleSelection != '\0') {
    pvVar1 = _objc_msgSend(addItemsToSelection,sel_objectEnumerator);
    while( true ) {
      pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
      if (pvVar2 == (id)0x0) break;
      _objc_msgSend(self,sel_addItemToSelection_);
    }
    pvVar1 = _objc_msgSend(addItemsToSelection,sel_lastObject);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(addItemsToSelection,sel_lastObject);
      _objc_msgSend_stret(local_24,pvVar1,sel_frame);
      puVar3 = (undefined4 *)&stack0xffffffc0;
      _objc_msgSend(self,sel_scrollRectToVisible_);
    }
    puVar3[1] = sel_defaultCenter;
    *puVar3 = cls_NSNotificationCenter;
    puVar3[-1] = 0x84508;
    pvVar1 = _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
    puVar3[3] = self;
    puVar3[2] = &cfstr_HSStoryboardViewDidChangeSelectionNotification;
    puVar3[1] = sel_postNotificationName_object_;
    *puVar3 = pvVar1;
    puVar3[-1] = 0x84528;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
    puVar3[1] = sel_notifyHyperSelectionDidChangeAndActivate_;
    *puVar3 = self;
    puVar3[2] = 1;
    puVar3[-1] = 0x84542;
    _objc_msgSend((id)*puVar3,(SEL)puVar3[1]);
  }
  return;
}

*/
- (void)addItemsToSelection:(id)aSelection
{
    if (!_allowMultipleSelection) {
        return;
    }
    for (id item in aSelection) {
        [self addItemToSelection:item];
    }
    if ([aSelection lastObject] != nil) {
        [self scrollRectToVisible:[[aSelection lastObject] frame]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSStoryboardViewDidChangeSelectionNotification" object:self];
    [self notifyHyperSelectionDidChangeAndActivate:YES];
}

- (void)selectItems:(id)aItems
{
    id pvVar1_3;

    if (_allowMultipleSelection == NO) {
        if ([aItems count] != 0) {
            return;
        }
        if (![self allowEmptySelection]) {
            return;
        }
    }
    pvVar1_3 = [_items selectedItems];
    [self addItemsToSelection:aItems];
    [self removeItemsFromSelection:pvVar1_3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008454a @ 0008454a, 377 bytes * /

void FUN_0008454a(HSStoryboardView *self,SEL _cmd,id selectItem)

{
  id pvVar1;
  id pvVar2;
  undefined8 in_stack_ffffffd0;
  undefined4 uVar4;
  undefined8 uVar3;
  undefined8 local_24;
  undefined8 local_1c;
  
  uVar4 = (undefined4)((ulonglong)in_stack_ffffffd0 >> 0x20);
  pvVar1 = _objc_msgSend(self->_items,sel_selectedItems);
  if (selectItem == (id)0x0) {
    if (self->_allowEmptySelection == '\0') {
      return;
    }
  }
  else {
    pvVar2 = _objc_msgSend(selectItem,sel_isSelected);
    if (((char)pvVar2 != '\0') && (pvVar2 = _objc_msgSend(pvVar1,sel_count), pvVar2 == (id)0x1)) {
      return;
    }
  }
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  if ((pvVar2 != (id)0x0) || (selectItem != (id)0x0)) {
    _objc_msgSend(pvVar1,sel_makeObjectsPerformSelector_withObject_);
    _objc_msgSend(selectItem,sel_setSelected_);
    pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    uVar3 = CONCAT44(uVar4,self);
    _objc_msgSend(pvVar1,sel_postNotificationName_object_);
    _objc_msgSend(self,sel_notifyHyperSelectionDidChangeAndActivate_);
    if (selectItem != (id)0x0) {
      _objc_msgSend_stret(&local_24,selectItem,sel_frame,uVar3);
      _objc_msgSend(self,sel_scrollRectToVisible_,local_24,local_1c);
    }
  }
  return;
}

*/
- (void)selectItem:(id)aItem
{
    NSArray *selectedItems = [_items selectedItems];
    if (aItem == nil) {
        if (!_allowEmptySelection) {
            return;
        }
    } else if ([aItem isSelected] && [selectedItems count] == 1) {
        return;
    }
    if ([selectedItems count] == 0 && aItem == nil) {
        return;
    }
    // The original sends setSelected: with a nil object, which reads as NO.
    for (id item in [[selectedItems copy] autorelease]) {
        [item setSelected:NO];
    }
    [aItem setSelected:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSStoryboardViewDidChangeSelectionNotification" object:self];
    [self notifyHyperSelectionDidChangeAndActivate:YES];
    if (aItem != nil) {
        [self scrollRectToVisible:[aItem frame]];
    }
}

- (void)setAllowMultipleSelection:(BOOL)aSelection
{
    _allowMultipleSelection = aSelection;
}

- (BOOL)allowMultipleSelection
{
    return _allowMultipleSelection;
}

- (void)setAllowEmptySelection:(BOOL)aSelection
{
    _allowEmptySelection = aSelection;
    if (aSelection == NO) {
        if ([[_items selectedItems] count] == 0) {
            if ([_items numberOfItems] != 0) {
                [self selectItem:[_items objectInStoryboardItemsAtIndex:0]];
            }
        }
    }
}

- (BOOL)allowEmptySelection
{
    return _allowEmptySelection;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000846c3 @ 000846c3, 268 bytes * /

void FUN_000846c3(HSStoryboardView *self,SEL _cmd,id magnifyWithEvent)

{
  id pvVar1;
  float fVar2;
  float fVar3;
  double dVar4;
  double dVar5;
  undefined4 local_2c;
  
  pvVar1 = _objc_msgSend(cls_NSEvent,sel_respondsToSelector_,sel_standardRotationThreshold);
  if ((char)pvVar1 == '\0') {
    local_2c = 0.0;
  }
  else {
    dVar4 = _objc_msgSend_fpret(cls_NSEvent,sel_standardRotationThreshold);
    local_2c = (float)dVar4;
  }
  dVar4 = _objc_msgSend_fpret(magnifyWithEvent,sel_deltaZ);
  if (local_2c < ABS((float)dVar4)) {
    dVar4 = _objc_msgSend_fpret(self,sel_cardScaleFactor);
    dVar5 = _objc_msgSend_fpret(magnifyWithEvent,sel_deltaZ);
    fVar2 = (float)dVar5 / 1000.0 + (float)dVar4;
    fVar3 = 0.1;
    if (0.1 <= fVar2) {
      fVar3 = fVar2;
    }
    fVar2 = 1.0;
    if (fVar3 <= 1.0) {
      fVar2 = fVar3;
    }
    _objc_msgSend(self,sel_setCardScaleFactor_,fVar2);
  }
  return;
}

*/
- (void)magnifyWithEvent:(id)aEvent
{
    float threshold = 0.0f;
    if ([NSEvent respondsToSelector:@selector(standardRotationThreshold)]) {
        threshold = ((CGFloat (*)(id, SEL))objc_msgSend)([NSEvent class], @selector(standardRotationThreshold));
    }
    if (fabsf((float)[aEvent deltaZ]) > threshold) {
        float scale = [self cardScaleFactor] + [aEvent deltaZ] / 1000.0f;
        [self setCardScaleFactor:MIN(MAX(scale, 0.1f), 1.0f)];
    }
}

- (void)endGestureWithEvent:(id)aEvent
{
    [self setInLiveScale:NO];
}

- (void)beginGestureWithEvent:(id)aEvent
{
    [self setInLiveScale:YES];
}

- (void)cancelOperation:(id)aOperation
{
    [[[self stack] document] exitStoryboardMode:aOperation];
}

- (void)delete:(id)aDelete
{
    [self deleteForward:aDelete];
}

- (void)deleteBackward:(id)aBackward
{
    [self deleteForward:aBackward];
}

- (void)deleteForward:(id)aForward
{
    id pvVar1;
    id self_00;
    BOOL cVar2;

    pvVar1 = [_items selectedItems];
    self_00 = [self delegate];
    cVar2 = pvVar1 != nil;
    if (((BOOL)cVar2) && (self_00 != nil)) {
        if ([self_00 respondsToSelector:@selector(needsDeleteSelectedCardInStoryboardView:)]) {
            cVar2 = [self_00 needsDeleteSelectedCardInStoryboardView:self];
        }
    }
    if (cVar2 != NO) {
        [self deleteSelectedCardsUsePoofAnimation:YES];
    }
}

- (void)selectAll:(id)aAll
{
    [_items selectAllItems];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSStoryboardViewDidChangeSelectionNotification" object:self];
    [self notifyHyperSelectionDidChangeAndActivate:YES];
}

- (void)moveDown:(id)aDown
{
    NSUInteger pvVar1_4;
    NSUInteger pvVar2_4;

    if ([_items selectedItems] != nil) {
        pvVar1_4 = [_items indexOfStoryboardItem:[[_items selectedItems] objectAtIndex:(int)[[_items selectedItems] count] + -1]];
        pvVar2_4 = [[self storyboardCell] maxCardsPerRow];
        if ((pvVar2_4 + (int)pvVar1_4) < [_items numberOfItems]) {
            [self selectItem:[_items objectInStoryboardItemsAtIndex:(pvVar2_4 + (int)pvVar1_4)]];
        }
    }
}

- (void)moveUp:(id)aUp
{
    id pvVar1;
    NSUInteger pvVar1_3;
    NSUInteger pvVar2_2;

    pvVar1 = [_items selectedItems];
    if (pvVar1 != nil) {
        pvVar1_3 = [_items indexOfStoryboardItem:[pvVar1 objectAtIndex:0]];
        pvVar2_2 = [[self storyboardCell] maxCardsPerRow];
        if (-1 < (int)pvVar1_3 - (int)pvVar2_2) {
            [self selectItem:[_items objectInStoryboardItemsAtIndex:(int)pvVar1_3 - (int)pvVar2_2]];
        }
    }
}

- (void)moveLeftAndModifySelection:(id)aSelection
{
    [self moveBackwardAndModifySelection:aSelection];
}

- (void)moveLeft:(id)aLeft
{
    [self moveBackward:aLeft];
}

- (void)moveBackwardAndModifySelection:(id)aSelection
{
    id pvVar1;
    NSUInteger pvVar1_3;

    pvVar1 = [_items selectedItems];
    if (pvVar1 != nil) {
        pvVar1_3 = [_items indexOfStoryboardItem:[pvVar1 objectAtIndex:0]];
        if (0 < (int)pvVar1_3) {
            [self addItemsToSelection:[NSArray arrayWithObject:[_items objectInStoryboardItemsAtIndex:(int)pvVar1_3 + -1]]];
        }
    }
}

- (void)moveBackward:(id)aBackward
{
    NSUInteger pvVar1_4;

    if ([_items selectedItems] != nil) {
        pvVar1_4 = [_items indexOfStoryboardItem:[[_items selectedItems] objectAtIndex:0]];
        if (0 < (int)pvVar1_4) {
            [self selectItem:[_items objectInStoryboardItemsAtIndex:(int)pvVar1_4 + -1]];
        }
    }
}

- (void)moveRightAndModifySelection:(id)aSelection
{
    [self moveForwardAndModifySelection:aSelection];
}

- (void)moveRight:(id)aRight
{
    [self moveForward:aRight];
}

- (void)moveForwardAndModifySelection:(id)aSelection
{
    id pvVar1;
    NSUInteger pvVar1_3;

    pvVar1 = [_items selectedItems];
    if (pvVar1 != nil) {
        pvVar1_3 = [_items indexOfStoryboardItem:[pvVar1 objectAtIndex:(int)[pvVar1 count] + -1]];
        if (pvVar1_3 < ([_items numberOfItems] + -1)) {
            [self addItemsToSelection:[NSArray arrayWithObject:[_items objectInStoryboardItemsAtIndex:(int)pvVar1_3 + 1]]];
        }
    }
}

- (void)moveForward:(id)aForward
{
    id pvVar1;
    NSUInteger pvVar1_3;

    pvVar1 = [_items selectedItems];
    if (pvVar1 != nil) {
        pvVar1_3 = [_items indexOfStoryboardItem:[pvVar1 objectAtIndex:(int)[pvVar1 count] + -1]];
        if (pvVar1_3 < ([_items numberOfItems] + -1)) {
            [self selectItem:[_items objectInStoryboardItemsAtIndex:(int)pvVar1_3 + 1]];
        }
    }
}

- (void)doCommandBySelector:(SEL)aSelector
{
    if ([self respondsToSelector:aSelector]) {
        [super performSelector:aSelector withObject:0];
        _didHandleKeyDown = YES;
    }
}

- (void)keyDown:(id)aDown
{
    _didHandleKeyDown = NO;
    [self interpretKeyEvents:[NSArray arrayWithObject:aDown]];
    if (_didHandleKeyDown == NO) {
        [super keyDown:aDown];
    }
}

- (void)imageLoader:(id)aLoader loadedImage:(id)aImage
{
    id pvVar1_3;

    pvVar1_3 = [_items itemForCard:[[aImage objectForKey:@"request"] objectForKey:@"card"]];
    if (pvVar1_3 != nil) {
        [pvVar1_3 setCardThumbnail:[aImage objectForKey:@"image"]];
        [self setNeedsDisplayStoryboardItem:pvVar1_3];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000848be @ 000848be, 627 bytes * /

id FUN_000848be(HSStoryboardView *self,SEL _cmd,id nextInvalidItemForImageLoader)

{
  HSStoryboardItemsCache *pHVar1;
  undefined *puVar2;
  char cVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 uVar7;
  int extraout_EDX;
  id pvVar8;
  int *piVar9;
  int *piVar10;
  id pvVar11;
  int aiStack_78 [2];
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  _objc_msgSend_stret(&local_34,self,sel_visibleRect);
  cVar3 = _NSEqualRects();
  if (cVar3 == '\0') {
    pvVar4 = _objc_msgSend(self,sel_storyboardCell);
    pvVar4 = _objc_msgSend(pvVar4,sel_cardFrameSize);
    pvVar11 = (id)0x0;
    pvVar5 = _objc_msgSend(self->_items,sel_numberOfItems);
    piVar9 = (int *)&stack0xffffff90;
    for (pvVar8 = (id)0x0; pvVar8 < pvVar5; pvVar8 = (id)((int)pvVar8 + 1)) {
      pHVar1 = self->_items;
      piVar9[2] = (int)pvVar8;
      piVar9[1] = (int)sel_objectInStoryboardItemsAtIndex_;
      *piVar9 = (int)pHVar1;
      piVar9[-1] = 0x8499f;
      pvVar11 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
      piVar9[2] = (int)sel_frame;
      piVar9[1] = (int)pvVar11;
      *piVar9 = (int)&local_24;
      piVar9[-1] = 0x849ba;
      _objc_msgSend_stret((void *)*piVar9,(id)piVar9[1],(SEL)piVar9[2]);
      piVar10 = piVar9 + -1;
      *(undefined8 *)(piVar9 + 5) = local_2c;
      *(undefined8 *)(piVar9 + 3) = local_34;
      *(undefined8 *)(piVar9 + 1) = local_1c;
      *(undefined8 *)(piVar9 + -1) = local_24;
      piVar9[-2] = 0x849ed;
      cVar3 = _NSIntersectsRect();
      if (cVar3 != '\0') {
        piVar9[2] = extraout_EDX;
        piVar9[1] = (int)pvVar4;
        *piVar9 = (int)sel_needsRenderThumbnailOfSize_;
        piVar9[-1] = (int)pvVar11;
        piVar9[-2] = 0x84a19;
        pvVar6 = _objc_msgSend((id)piVar9[-1],(SEL)*piVar9);
        if ((char)pvVar6 != '\0') goto LAB_00084a7b;
      }
      piVar9 = piVar9 + -1;
    }
    for (pvVar8 = (id)0x0; piVar10 = piVar9, pvVar8 < pvVar5; pvVar8 = (id)((int)pvVar8 + 1)) {
      pHVar1 = self->_items;
      piVar9[2] = (int)pvVar8;
      piVar9[1] = (int)sel_objectInStoryboardItemsAtIndex_;
      *piVar9 = (int)pHVar1;
      piVar9[-1] = 0x84a47;
      pvVar11 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
      piVar9[3] = extraout_EDX;
      piVar9[2] = (int)pvVar4;
      piVar9[1] = (int)sel_needsRenderThumbnailOfSize_;
      *piVar9 = (int)pvVar11;
      piVar9[-1] = 0x84a71;
      pvVar6 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
      if ((char)pvVar6 != '\0') break;
    }
LAB_00084a7b:
    puVar2 = cls_NSDictionary;
    if ((pvVar8 < pvVar5) && (pvVar11 != (id)0x0)) {
      piVar10[1] = (int)sel_presentationContext;
      *piVar10 = (int)self;
      piVar10[-1] = 0x84aaa;
      pvVar5 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
      piVar10[1] = extraout_EDX;
      *piVar10 = (int)pvVar4;
      piVar10[-1] = 0x84ac7;
      uVar7 = _NSStringFromSize();
      piVar10[1] = (int)sel_card;
      *piVar10 = (int)pvVar11;
      piVar10[-1] = 0x84adb;
      pvVar4 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
      piVar10[7] = (int)&cfstr_presentationContext;
      piVar10[6] = (int)pvVar5;
      piVar10[5] = (int)&cfstr_size;
      piVar10[4] = uVar7;
      piVar10[3] = (int)&cfstr_card;
      piVar10[2] = (int)pvVar4;
      piVar10[1] = (int)sel_dictionaryWithObjectsAndKeys_;
      *piVar10 = (int)puVar2;
      piVar10[8] = 0;
      piVar10[-1] = 0x84b25;
      pvVar4 = _objc_msgSend((id)*piVar10,(SEL)piVar10[1]);
      return pvVar4;
    }
  }
  return (id)0x0;
}

*/
- (id)nextInvalidItemForImageLoader:(id)aLoader
{
    NSRect visibleRect = [self visibleRect];
    if (NSEqualRects(visibleRect, NSZeroRect)) {
        return nil;
    }
    NSSize thumbnailSize = [[self storyboardCell] cardFrameSize];
    NSUInteger count = [_items numberOfItems];
    id item = nil;
    NSUInteger index;
    // Visible items first, then everything else.
    for (index = 0; index < count; index++) {
        item = [_items objectInStoryboardItemsAtIndex:index];
        if (NSIntersectsRect([item frame], visibleRect) && [item needsRenderThumbnailOfSize:thumbnailSize]) {
            break;
        }
    }
    if (index >= count) {
        for (index = 0; index < count; index++) {
            item = [_items objectInStoryboardItemsAtIndex:index];
            if ([item needsRenderThumbnailOfSize:thumbnailSize]) {
                break;
            }
        }
    }
    if (index < count && item != nil) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                [item card], @"card",
                NSStringFromSize(thumbnailSize), @"size",
                [self presentationContext], @"presentationContext",
                nil];
    }
    return nil;
}

- (void)updateWindowWithTimer:(id)aTimer
{
    [self displayIfNeeded];
}

- (void)storyboardItemsCacheDidUpdateItem:(id)aItem
{
    [aItem invalidateAllImageCaches];
    [[self imageLoader] validateInvalidItems];
    [self setNeedsDisplayStoryboardItem:aItem];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00084b31 @ 00084b31, 184 bytes * /

void FUN_00084b31(HSStoryboardView *self,SEL _cmd,id storyboardItemsCacheDidAddItem,uint atIndex)

{
  id pvVar1;
  undefined4 uVar2;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_storyboardLayout);
  _objc_msgSend_stret(&local_24,pvVar1,sel_frameForItemAtIndex_,atIndex);
  _objc_msgSend(storyboardItemsCacheDidAddItem,sel_setFrame_,local_24,local_1c);
  uVar2 = (undefined4)((ulonglong)local_24 >> 0x20);
  pvVar1 = _objc_msgSend(self,sel_storyboardLayout);
  _objc_msgSend(pvVar1,sel_invalidateLayout);
  if (storyboardItemsCacheDidAddItem != (id)0x0) {
    _objc_msgSend(self,sel_setNeedsDisplayStoryboardItem_,storyboardItemsCacheDidAddItem,uVar2,
                  local_1c);
  }
  return;
}

*/
- (void)storyboardItemsCacheDidAddItem:(id)aItem atIndex:(NSUInteger)aIndex
{
    [aItem setFrame:[[self storyboardLayout] frameForItemAtIndex:aIndex]];
    [[self storyboardLayout] invalidateLayout];
    if (aItem != nil) {
        [self setNeedsDisplayStoryboardItem:aItem];
    }
}

- (void)storyboardItemsCacheDidRemoveItem:(id)aItem atIndex:(NSUInteger)aIndex
{
    [[self storyboardLayout] invalidateLayout];
}

- (void)storyboardItemsCacheWillRemoveItem:(id)aItem atIndex:(NSUInteger)aIndex
{
    [self setNeedsDisplayInRect:[aItem frame]];
}

- (CGFloat)cardScaleFactor
{
    return _cardScaleFactor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008018c @ 0008018c, 725 bytes * /

void FUN_0008018c(HSStoryboardView *self,SEL _cmd,float setCardScaleFactor)

{
  undefined *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  float fVar4;
  float fVar5;
  SEL op;
  undefined4 uVar6;
  float fVar7;
  
  fVar7 = self->_cardScaleFactor;
  if ((fVar7 != 0.0) || (NAN(fVar7))) {
    fVar4 = ABS(fVar7);
  }
  else {
    fVar4 = 1.0;
  }
  if ((setCardScaleFactor != 0.0) || (NAN(setCardScaleFactor))) {
    fVar5 = ABS(setCardScaleFactor);
  }
  else {
    fVar5 = 1.0;
  }
  if (fVar5 <= fVar4) {
    fVar5 = fVar4;
  }
  if (fVar5 * 0.0005 < ABS(fVar7 - setCardScaleFactor)) {
    self->_scaleFactorOnceCalculated = '\x01';
    self->_cardScaleFactor = setCardScaleFactor;
    self_00 = cls_NSTimer;
    puVar1 = sel_idleTime_;
    if (self->_inLiveScale == '\0') {
      _objc_msgSend(self->_items,sel_invalidateAllItemsWithoutThumbnails);
      pvVar2 = _objc_msgSend(self,sel_imageLoader);
      op = sel_validateInvalidItems;
    }
    else {
      pvVar2 = self->_idleTimer;
      if (pvVar2 == (id)0x0) {
        pvVar2 = _objc_msgSend(self,sel_NSE_newWeakProxy);
        pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
        pvVar2 = _objc_msgSend(self_00,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,
                               0x40000000,0x3fd33333,pvVar2,puVar1,0,0);
        pvVar2 = _objc_msgSend(pvVar2,sel_retain);
        self->_idleTimer = pvVar2;
        pvVar2 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
        op = sel_addTimer_forMode_;
      }
      else {
        _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceNow_,0x40000000,0x3fd33333);
        op = sel_setFireDate_;
      }
    }
    _objc_msgSend(pvVar2,op);
    puVar1 = cls_HSStoryboardView;
    if (self->_stack != (id)0x0) {
      fVar7 = self->_cardScaleFactor;
      pvVar2 = _objc_msgSend(self->_stack,sel_hyperCardSize);
      pvVar2 = _objc_msgSend(puVar1,sel_scaledCardSize_withScaleFactor_,pvVar2,extraout_EDX,fVar7);
      pvVar3 = _objc_msgSend(self,sel_storyboardCell);
      uVar6 = extraout_EDX_00;
      pvVar3 = _objc_msgSend(pvVar3,sel_calcSizeWithScaledCardSize_,pvVar2,extraout_EDX_00);
      if ((char)pvVar3 != '\0') {
        pvVar2 = (id)0x1;
        _objc_msgSend(self,sel_setNeedsDisplay_,1,uVar6,fVar7);
        _objc_msgSend(self,sel_sizeToFitRequiredSize);
      }
      pvVar2 = _objc_msgSend(self,sel_storyboardLayout,pvVar2,uVar6,fVar7);
      _objc_msgSend(pvVar2,sel_invalidateLayoutWithAnimation_,0);
    }
  }
  return;
}

*/
- (void)setCardScaleFactor:(CGFloat)aFactor
{
    if (HSStoryboardFloatsAreEqual(_cardScaleFactor, aFactor)) {
        return;
    }
    _scaleFactorOnceCalculated = YES;
    _cardScaleFactor = aFactor;
    if (!_inLiveScale) {
        [_items invalidateAllItemsWithoutThumbnails];
        [[self imageLoader] validateInvalidItems];
    } else if (_idleTimer == nil) {
        // Re-render thumbnails once live scaling pauses.
        _idleTimer = [[NSTimer timerWithTimeInterval:0.3 target:[[self NSE_newWeakProxy] autorelease] selector:@selector(idleTime:) userInfo:nil repeats:NO] retain];
        [[NSRunLoop currentRunLoop] addTimer:_idleTimer forMode:NSEventTrackingRunLoopMode];
    } else {
        [_idleTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    }
    if (_stack != nil) {
        NSSize scaledSize = [HSStoryboardView scaledCardSize:[_stack hyperCardSize] withScaleFactor:_cardScaleFactor];
        if ([[self storyboardCell] calcSizeWithScaledCardSize:scaledSize]) {
            [self setNeedsDisplay:YES];
            [self sizeToFitRequiredSize];
        }
        [[self storyboardLayout] invalidateLayoutWithAnimation:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000800bf @ 000800bf, 205 bytes * /

void FUN_000800bf(HSStoryboardView *self,SEL _cmd,id idleTime)

{
  id pvVar1;
  HSStoryboardView *self_00;
  SEL op;
  
  if (self->_inLiveScale == '\0') {
    pvVar1 = _objc_msgSend(self,sel_inLiveResize);
    if ((char)pvVar1 == '\0') goto LAB_00080163;
    self_00 = _objc_msgSend(self,sel_storyboardLayout);
    op = sel_invalidateLayout;
  }
  else {
    _objc_msgSend(self->_items,sel_invalidateAllItemsWithoutThumbnails);
    pvVar1 = _objc_msgSend(self,sel_imageLoader);
    _objc_msgSend(pvVar1,sel_validateInvalidItems);
    self_00 = self;
    op = sel_setNeedsDisplay_;
  }
  _objc_msgSend(self_00,op);
LAB_00080163:
  _objc_msgSend(self->_idleTimer,sel_release);
  self->_idleTimer = (id)0x0;
  return;
}

*/
- (void)idleTime:(id)aTime
{
    if (_inLiveScale) {
        [_items invalidateAllItemsWithoutThumbnails];
        [[self imageLoader] validateInvalidItems];
        [self setNeedsDisplay:YES];
    } else if ([self inLiveResize]) {
        [[self storyboardLayout] invalidateLayout];
    }
    [_idleTimer release];
    _idleTimer = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00084c46 @ 00084c46, 308 bytes * /

void FUN_00084c46(HSStoryboardView *self,SEL _cmd,NSSize setFrameSize)

{
  id pvVar1;
  float extraout_EDX;
  int *piVar2;
  undefined4 local_50;
  float local_30;
  HSStoryboardView *local_2c;
  undefined *local_28;
  undefined1 local_24 [12];
  float local_18;
  
  local_50 = 0x84c91;
  pvVar1 = _objc_msgSend(self,sel_storyboardCell);
  local_50 = 0x84ca7;
  _objc_msgSend(pvVar1,sel_calcSizeWithBoundsWidth_);
  local_50 = 0x84cb9;
  pvVar1 = _objc_msgSend(self,sel_storyboardCell);
  local_50 = 0x84ccb;
  _objc_msgSend(pvVar1,sel_requiredSizeToFitAllItems);
  local_50 = 0x84cdf;
  pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
  piVar2 = (int *)&stack0xffffffb4;
  local_30 = extraout_EDX;
  if (pvVar1 != (id)0x0) {
    local_50 = 0x84d05;
    _objc_msgSend_stret(local_24,pvVar1,sel_documentVisibleRect);
    piVar2 = &local_50;
    local_30 = local_18;
    if (local_18 <= extraout_EDX) {
      piVar2 = &local_50;
      local_30 = extraout_EDX;
    }
  }
  local_2c = self;
  local_28 = PTR_s_NSView_0034eaa0;
  piVar2[3] = (int)local_30;
  piVar2[2] = (int)setFrameSize.width;
  piVar2[1] = (int)sel_setFrameSize_;
  *piVar2 = (int)&local_2c;
  piVar2[-1] = 0x84d4e;
  _objc_msgSendSuper((void *)*piVar2,(SEL)piVar2[1]);
  piVar2[1] = (int)sel_storyboardLayout;
  *piVar2 = (int)self;
  piVar2[-1] = 0x84d60;
  pvVar1 = _objc_msgSend((id)*piVar2,(SEL)piVar2[1]);
  piVar2[1] = (int)sel_invalidateLayout;
  *piVar2 = (int)pvVar1;
  piVar2[-1] = 0x84d72;
  _objc_msgSend((id)*piVar2,(SEL)piVar2[1]);
  return;
}

*/
- (void)setFrameSize:(NSSize)aSize
{
    [[self storyboardCell] calcSizeWithBoundsWidth:(unsigned int)aSize.width];
    CGFloat height = [[self storyboardCell] requiredSizeToFitAllItems].height;
    NSScrollView *scrollView = [self enclosingScrollView];
    if (scrollView != nil) {
        // Always fill the visible area.
        height = MAX(height, [scrollView documentVisibleRect].size.height);
    }
    [super setFrameSize:NSMakeSize(aSize.width, height)];
    [[self storyboardLayout] invalidateLayout];
}

- (void)setNeedsDisplayStoryboardItem:(id)aItem
{
    [[self storyboardCell] setNeedsDisplayItem:aItem inView:self];
}

- (id)cocoaView
{
    return self;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00084d7a @ 00084d7a, 877 bytes * /

void FUN_00084d7a(HSStoryboardView *self,SEL _cmd,id stackDidAddOrRemoveOrReorderCards)

{
  int *piVar1;
  id pvVar2;
  id pvVar3;
  HSStoryboardView *self_00;
  id pvVar4;
  int *piVar5;
  int aiStack_54 [2];
  SEL op;
  undefined8 local_24;
  undefined8 local_1c;
  
  piVar5 = (int *)&stack0xffffffb4;
  pvVar2 = _objc_msgSend(self,sel_isModifingStack);
  if ((char)pvVar2 != '\0') {
    return;
  }
  pvVar2 = _objc_msgSend(stackDidAddOrRemoveOrReorderCards,sel_userInfo);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_);
  pvVar2 = _objc_msgSend(pvVar2,sel_count);
  pvVar3 = _objc_msgSend(stackDidAddOrRemoveOrReorderCards,sel_userInfo);
  pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_);
  pvVar3 = _objc_msgSend(pvVar3,sel_count);
  self_00 = _objc_msgSend(self,sel_items);
  op = sel_invalidateWithChangedItemOrder;
  if ((pvVar3 != (id)0x0 || pvVar2 != (id)0x0) &&
     (op = sel_invalidateWithAddedItem, pvVar2 == (id)0x0)) {
    _objc_msgSend(self_00,sel_invalidateWithRemovedItem);
    pvVar2 = (id)self->_selectionIndex;
    pvVar3 = _objc_msgSend(self,sel_items);
    pvVar3 = _objc_msgSend(pvVar3,sel_numberOfItems);
    if (pvVar3 <= pvVar2) {
      self->_selectionIndex = self->_selectionIndex - 1;
    }
    pvVar2 = _objc_msgSend(self,sel_items);
    pvVar2 = _objc_msgSend(pvVar2,sel_numberOfItems);
    if (pvVar2 == (id)0x0) goto LAB_00084f29;
    pvVar2 = _objc_msgSend(self,sel_items);
    _objc_msgSend(pvVar2,sel_objectInStoryboardItemsAtIndex_);
    self_00 = self;
    op = sel_selectItem_;
  }
  _objc_msgSend(self_00,op);
LAB_00084f29:
  pvVar2 = _objc_msgSend(stackDidAddOrRemoveOrReorderCards,sel_userInfo);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_);
  if (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar2,sel_firstIndex);
    piVar1 = (int *)&stack0xffffffb4;
    piVar5 = (int *)&stack0xffffffb4;
    while (pvVar3 != (id)0x7fffffff) {
      piVar1[1] = (int)sel_items;
      *piVar1 = (int)self;
      piVar1[-1] = 0x84f98;
      pvVar4 = _objc_msgSend((id)*piVar1,(SEL)piVar1[1]);
      piVar1[2] = (int)pvVar3;
      piVar1[1] = (int)sel_objectInStoryboardItemsAtIndex_;
      *piVar1 = (int)pvVar4;
      piVar1[-1] = 0x84fae;
      pvVar4 = _objc_msgSend((id)*piVar1,(SEL)piVar1[1]);
      piVar1[2] = (int)sel_frame;
      piVar1[1] = (int)pvVar4;
      *piVar1 = (int)&local_24;
      piVar1[-1] = 0x84fc7;
      _objc_msgSend_stret((void *)*piVar1,(id)piVar1[1],(SEL)piVar1[2]);
      piVar5 = piVar1 + -1;
      *(undefined8 *)(piVar1 + 3) = local_1c;
      *(undefined8 *)(piVar1 + 1) = local_24;
      *piVar1 = (int)sel_setNeedsDisplayInRect_;
      piVar1[-1] = (int)self;
      piVar1[-2] = 0x84ff5;
      _objc_msgSend((id)piVar1[-1],(SEL)*piVar1);
      piVar1[1] = (int)pvVar3;
      *piVar1 = (int)sel_indexGreaterThanIndex_;
      piVar1[-1] = (int)pvVar2;
      piVar1[-2] = 0x8500b;
      pvVar3 = _objc_msgSend((id)piVar1[-1],(SEL)*piVar1);
      piVar1 = piVar1 + -1;
    }
  }
  piVar5[1] = (int)sel_storyboardCell;
  *piVar5 = (int)self;
  piVar5[-1] = 0x8502d;
  pvVar3 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  pvVar2 = self->_stack;
  piVar5[1] = (int)sel_hyperCount;
  *piVar5 = (int)pvVar2;
  piVar5[-1] = 0x85044;
  pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  piVar5[2] = (int)pvVar2;
  piVar5[1] = (int)sel_calcSizeWithItemsCount_;
  *piVar5 = (int)pvVar3;
  piVar5[-1] = 0x8505a;
  pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  if ((char)pvVar2 != '\0') {
    piVar5[1] = (int)sel_storyboardLayout;
    *piVar5 = (int)self;
    piVar5[-1] = 0x85070;
    pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    piVar5[1] = (int)sel_invalidateLayout;
    *piVar5 = (int)pvVar2;
    piVar5[-1] = 0x85082;
    _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    piVar5[1] = (int)sel_items;
    *piVar5 = (int)self;
    piVar5[-1] = 0x85094;
    pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    piVar5[1] = (int)sel_invalidateAllItems;
    *piVar5 = (int)pvVar2;
    piVar5[-1] = 0x850a6;
    _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    piVar5[1] = (int)sel_imageLoader;
    *piVar5 = (int)self;
    piVar5[-1] = 0x850b8;
    pvVar2 = _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
    piVar5[1] = (int)sel_validateInvalidItems;
    *piVar5 = (int)pvVar2;
    piVar5[-1] = 0x850ca;
    _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  }
  piVar5[1] = (int)sel_sizeToFitRequiredSize;
  *piVar5 = (int)self;
  piVar5[-1] = 0x850df;
  _objc_msgSend((id)*piVar5,(SEL)piVar5[1]);
  return;
}

*/
- (void)stackDidAddOrRemoveOrReorderCards:(id)aCards
{
    if ([self isModifingStack]) {
        return;
    }
    NSUInteger added = [[[aCards userInfo] objectForKey:@"HSNodeChildrenForAddition"] count];
    NSUInteger removed = [[[aCards userInfo] objectForKey:@"HSNodeChildrenForRemoval"] count];
    if (added == 0 && removed == 0) {
        [[self items] invalidateWithChangedItemOrder];
    } else if (added != 0) {
        [[self items] invalidateWithAddedItem];
    } else {
        [[self items] invalidateWithRemovedItem];
        if (_selectionIndex >= [[self items] numberOfItems]) {
            _selectionIndex--;
        }
        if ([[self items] numberOfItems] != 0) {
            [self selectItem:[[self items] objectInStoryboardItemsAtIndex:_selectionIndex]];
        }
    }
    NSIndexSet *affected = [[aCards userInfo] objectForKey:@"HSAffectedNodeChildrenIndexes"];
    if (affected != nil) {
        for (NSUInteger index = [affected firstIndex]; index != NSNotFound; index = [affected indexGreaterThanIndex:index]) {
            [self setNeedsDisplayInRect:[[[self items] objectInStoryboardItemsAtIndex:index] frame]];
        }
    }
    if ([[self storyboardCell] calcSizeWithItemsCount:[_stack hyperCount]]) {
        [[self storyboardLayout] invalidateLayout];
        [[self items] invalidateAllItems];
        [[self imageLoader] validateInvalidItems];
    }
    [self sizeToFitRequiredSize];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007ffab @ 0007ffab, 205 bytes * /

void FUN_0007ffab(HSStoryboardView *self,SEL _cmd,id cardSizeDidChange)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 uVar3;
  float fVar4;
  
  self_00 = cls_HSStoryboardView;
  fVar4 = self->_cardScaleFactor;
  pvVar1 = _objc_msgSend(self->_stack,sel_hyperCardSize);
  pvVar1 = _objc_msgSend(self_00,sel_scaledCardSize_withScaleFactor_,pvVar1,extraout_EDX,fVar4);
  _objc_msgSend(self,sel_setNeedsDisplay_,1);
  pvVar2 = _objc_msgSend(self,sel_storyboardCell);
  uVar3 = extraout_EDX_00;
  pvVar2 = _objc_msgSend(pvVar2,sel_calcSizeWithScaledCardSize_,pvVar1,extraout_EDX_00);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(self,sel_sizeToFitRequiredSize,pvVar1,uVar3,fVar4);
  }
  return;
}

*/
- (void)cardSizeDidChange:(id)aChange
{
    NSSize scaledSize = [HSStoryboardView scaledCardSize:[_stack hyperCardSize] withScaleFactor:_cardScaleFactor];
    [self setNeedsDisplay:YES];
    if ([[self storyboardCell] calcSizeWithScaledCardSize:scaledSize]) {
        [self sizeToFitRequiredSize];
    }
}

- (id)imageLoader
{
    HSStoryboardImageLoader *pHVar1;

    pHVar1 = _imageLoader;
    if (pHVar1 == nil) {
        pHVar1 = [[HSStoryboardImageLoader alloc] initWithDelegate:self];
        _imageLoader = pHVar1;
    }
    return pHVar1;
}

- (id)presentationContext
{
    id pvVar1;

    pvVar1 = _presentationContext;
    if (pvVar1 == nil) {
        pvVar1 = [[HSThumbnailContext presentationContext] retain];
        _presentationContext = pvVar1;
    }
    return pvVar1;
}

- (id)stack
{
    return _stack;
}

- (void)setStack:(id)aStack
{
    [self setStack:aStack andSelectCard:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000850e7 @ 000850e7, 1566 bytes * /

void FUN_000850e7(HSStoryboardView *self,SEL _cmd,id setStack,id andSelectCard)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  double dVar4;
  SEL pcVar5;
  HSStoryboardItemsCache *self_01;
  undefined *puVar6;
  undefined4 uVar7;
  id local_4c;
  undefined4 local_48;
  undefined1 local_44 [4];
  float local_40;
  undefined1 local_34 [12];
  float local_28;
  undefined1 local_24 [12];
  float local_18;
  
  if (self->_stack == setStack) {
    return;
  }
  pvVar2 = (id)0x0;
  if (self->_stack != (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,0,self->_stack);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    pvVar3 = _objc_msgSend(self->_stack,sel_document);
    _objc_msgSend(pvVar2,sel_removeObserver_name_object_,self,0,pvVar3);
    _objc_msgSend(self->_stack,sel_removeAttributeObserver_,self);
    _objc_msgSend(self->_stack,sel_removeChildrenAttributeObserver_,self);
    pvVar2 = self->_stack;
  }
  _objc_msgSend(pvVar2,sel_release);
  pvVar2 = _objc_msgSend(setStack,sel_retain);
  self->_stack = pvVar2;
  if (pvVar2 != (id)0x0) {
    uVar7 = *(undefined4 *)PTR_0033601c;
    _objc_msgSend(pvVar2,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                  sel_cardSizeDidChange_,uVar7,&DAT_00365ffc,0xbf400000);
    _objc_msgSend(self->_stack,sel_addObserver_selector_ofChanges_ofAttribute_withPriority_,self,
                  sel_stackDidAddOrRemoveOrReorderCards_,uVar7,&DAT_00366010,0xbf400000);
    pvVar2 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    pvVar3 = _objc_msgSend(self->_stack,sel_document);
    uVar7 = *(undefined4 *)PTR_PTR_0033640c;
    puVar6 = sel_cardsDidDelete_;
    _objc_msgSend(pvVar2,sel_addObserver_selector_name_object_,self,sel_cardsDidDelete_,uVar7,pvVar3
                 );
    if (self->_scaleFactorOnceCalculated == '\0') {
      dVar4 = _objc_msgSend_fpret(cls_HSStoryboardView,sel_defaultScaleFactorForStack_,self->_stack)
      ;
      _objc_msgSend(self,sel_setCardScaleFactor_,(float)dVar4,puVar6,uVar7,pvVar3);
      self->_scaleFactorOnceCalculated = '\x01';
    }
  }
  pvVar3 = _objc_msgSend(self,sel_items);
  pvVar2 = self->_stack;
  _objc_msgSend(pvVar3,sel_setStack_,pvVar2);
  pvVar3 = _objc_msgSend(self->_stack,sel_hyperCount);
  puVar6 = cls_HSStoryboardView;
  if (self->_stack == (id)0x0) {
    local_4c = *(id *)PTR_0033607c;
    local_48 = *(undefined4 *)(PTR_0033607c + 4);
  }
  else {
    fVar1 = self->_cardScaleFactor;
    pvVar2 = _objc_msgSend(self->_stack,sel_hyperCardSize,pvVar2);
    local_4c = _objc_msgSend(puVar6,sel_scaledCardSize_withScaleFactor_,pvVar2,extraout_EDX,fVar1);
    local_48 = extraout_EDX_00;
  }
  pvVar2 = _objc_msgSend(self,sel_storyboardCell,pvVar2);
  pvVar2 = _objc_msgSend(pvVar2,sel_calcSizeWithScaledCardSize_itemsCount_,local_4c,local_48,pvVar3)
  ;
  if ((char)pvVar2 != '\0') {
    local_4c = (id)0x1;
    _objc_msgSend(self,sel_setNeedsDisplay_,1,local_48,pvVar3);
    _objc_msgSend(self,sel_sizeToFitRequiredSize);
  }
  if (andSelectCard == (id)0x0) {
    if (self->_allowEmptySelection != '\0') goto LAB_0008551e;
    pvVar2 = _objc_msgSend(self->_items,sel_selectedItems,local_4c,local_48,pvVar3);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    if ((pvVar2 != (id)0x0) ||
       (pvVar2 = _objc_msgSend(self->_items,sel_numberOfItems,local_4c,local_48,pvVar3),
       pvVar2 == (id)0x0)) goto LAB_0008551e;
    self_01 = self->_items;
    andSelectCard = (id)0x0;
    pcVar5 = sel_objectInStoryboardItemsAtIndex_;
  }
  else {
    self_01 = self->_items;
    pcVar5 = sel_itemForCard_;
  }
  local_4c = _objc_msgSend(self_01,pcVar5,andSelectCard,local_48,pvVar3);
  _objc_msgSend(self,sel_selectItem_,local_4c);
LAB_0008551e:
  pvVar2 = _objc_msgSend(self,sel_storyboardLayout,local_4c,local_48,pvVar3);
  _objc_msgSend(pvVar2,sel_invalidateLayoutWithAnimation_,0);
  pvVar2 = _objc_msgSend(self->_items,sel_selectedItems);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,0);
  _objc_msgSend_stret(local_44,pvVar2,sel_frame);
  _objc_msgSend_stret(local_34,self,sel_frame);
  pvVar2 = _objc_msgSend(self,sel_enclosingScrollView);
  pvVar2 = _objc_msgSend(pvVar2,sel_contentView);
  _objc_msgSend_stret(local_24,pvVar2,sel_frame);
  pvVar2 = _objc_msgSend(self,sel_enclosingScrollView);
  if (local_28 - local_18 <= local_40) {
    local_40 = local_28 - local_18;
  }
  pvVar2 = _objc_msgSend(pvVar2,sel_contentView);
  _objc_msgSend(pvVar2,sel_scrollToPoint_,*(undefined4 *)PTR_00336074,local_40);
  pvVar2 = _objc_msgSend(self,sel_enclosingScrollView);
  pvVar3 = _objc_msgSend(self,sel_enclosingScrollView);
  pvVar3 = _objc_msgSend(pvVar3,sel_contentView);
  _objc_msgSend(pvVar2,sel_reflectScrolledClipView_,pvVar3);
  pvVar2 = self->_stack;
  self_00 = _objc_msgSend(self,sel_imageLoader);
  pcVar5 = sel_cancelAllRequests;
  if (pvVar2 != (id)0x0) {
    pcVar5 = sel_validateInvalidItems;
  }
  _objc_msgSend(self_00,pcVar5,pvVar3);
  return;
}

*/
- (void)setStack:(id)aStack andSelectCard:(id)aCard
{
    if (_stack == aStack) {
        return;
    }
    if (_stack != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:_stack];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:[_stack document]];
        [_stack removeAttributeObserver:self];
        [_stack removeChildrenAttributeObserver:self];
    }
    [_stack release];
    _stack = [aStack retain];
    if (_stack != nil) {
        [_stack addObserver:self selector:@selector(cardSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSStackCardSizeAttribute) withPriority:-0.75];
        [_stack addObserver:self selector:@selector(stackDidAddOrRemoveOrReorderCards:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSNodeContainerChildrenAttribute) withPriority:-0.75];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardsDidDelete:) name:HSCardsDidDeleteNotification object:[_stack document]];
        if (!_scaleFactorOnceCalculated) {
            [self setCardScaleFactor:[HSStoryboardView defaultScaleFactorForStack:_stack]];
            _scaleFactorOnceCalculated = YES;
        }
    }
    [[self items] setStack:_stack];
    NSUInteger count = [_stack hyperCount];
    NSSize scaledSize = NSZeroSize;
    if (_stack != nil) {
        scaledSize = [HSStoryboardView scaledCardSize:[_stack hyperCardSize] withScaleFactor:_cardScaleFactor];
    }
    if ([[self storyboardCell] calcSizeWithScaledCardSize:scaledSize itemsCount:count]) {
        [self setNeedsDisplay:YES];
        [self sizeToFitRequiredSize];
    }
    if (aCard != nil) {
        [self selectItem:[_items itemForCard:aCard]];
    } else if (!_allowEmptySelection && [[_items selectedItems] count] == 0 && [_items numberOfItems] != 0) {
        [self selectItem:[_items objectInStoryboardItemsAtIndex:0]];
    }
    [[self storyboardLayout] invalidateLayoutWithAnimation:NO];
    // Scroll the selection into view. Fix: the original read item 0 of a possibly empty selection.
    NSRect itemFrame = [[[_items selectedItems] firstObject] frame];
    NSRect frame = [self frame];
    NSRect clipFrame = [[[self enclosingScrollView] contentView] frame];
    CGFloat y = MIN(itemFrame.origin.y, frame.size.height - clipFrame.size.height);
    [[[self enclosingScrollView] contentView] scrollToPoint:NSMakePoint(NSZeroPoint.x, y)];
    [[self enclosingScrollView] reflectScrolledClipView:[[self enclosingScrollView] contentView]];
    if (_stack != nil) {
        [[self imageLoader] validateInvalidItems];
    } else {
        [[self imageLoader] cancelAllRequests];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00085705 @ 00085705, 469 bytes * /

void FUN_00085705(HSStoryboardView *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  int *piVar2;
  float fVar3;
  float fVar4;
  undefined4 local_60;
  id local_44;
  float local_40;
  HSStoryboardView *local_3c;
  undefined *local_38;
  undefined1 local_34 [8];
  id local_2c;
  float local_28;
  undefined1 local_24 [8];
  float local_1c;
  float local_18;
  
  piVar2 = (int *)&stack0xffffffa4;
  local_60 = 0x85729;
  pvVar1 = _objc_msgSend(self,sel_storyboardCell);
  local_60 = 0x8573b;
  local_44 = _objc_msgSend(pvVar1,sel_requiredSizeToFitAllItems);
  local_60 = 0x85754;
  pvVar1 = _objc_msgSend(self,sel_enclosingScrollView);
  local_40 = extraout_EDX;
  if (pvVar1 != (id)0x0) {
    local_60 = 0x85785;
    _objc_msgSend_stret(local_34,pvVar1,sel_documentVisibleRect);
    local_44 = local_2c;
    piVar2 = &local_60;
    local_40 = local_28;
    if (local_28 <= extraout_EDX) {
      piVar2 = &local_60;
      local_40 = extraout_EDX;
    }
  }
  piVar2[2] = (int)sel_frame;
  piVar2[1] = (int)self;
  *piVar2 = (int)local_24;
  piVar2[-1] = 0x857bd;
  _objc_msgSend_stret((void *)*piVar2,(id)piVar2[1],(SEL)piVar2[2]);
  if ((local_1c != 0.0) || (NAN(local_1c))) {
    fVar3 = ABS(local_1c);
  }
  else {
    fVar3 = 1.0;
  }
  if (((float)local_44 != 0.0) || (NAN((float)local_44))) {
    fVar4 = ABS((float)local_44);
  }
  else {
    fVar4 = 1.0;
  }
  if (fVar4 <= fVar3) {
    fVar4 = fVar3;
  }
  if (ABS(local_1c - (float)local_44) <= fVar4 * 0.0005) {
    if ((local_18 != 0.0) || (NAN(local_18))) {
      fVar3 = ABS(local_18);
    }
    else {
      fVar3 = 1.0;
    }
    if ((local_40 != 0.0) || (NAN(local_40))) {
      fVar4 = ABS(local_40);
    }
    else {
      fVar4 = 1.0;
    }
    if (fVar4 <= fVar3) {
      fVar4 = fVar3;
    }
    if (ABS(local_18 - local_40) <= fVar4 * 0.0005) {
      return;
    }
  }
  local_3c = self;
  local_38 = PTR_s_NSView_0034eaa0;
  piVar2[2] = (int)local_40;
  piVar2[1] = (int)local_44;
  *piVar2 = (int)sel_setFrameSize_;
  piVar2[-1] = (int)&local_3c;
  piVar2[-2] = 0x858d2;
  _objc_msgSendSuper((void *)piVar2[-1],(SEL)*piVar2);
  return;
}

*/
- (void)sizeToFitRequiredSize
{
    NSSize size = [[self storyboardCell] requiredSizeToFitAllItems];
    NSScrollView *scrollView = [self enclosingScrollView];
    if (scrollView != nil) {
        NSRect visibleRect = [scrollView documentVisibleRect];
        size.width = visibleRect.size.width;
        size.height = MAX(size.height, visibleRect.size.height);
    }
    NSRect frame = [self frame];
    if (HSStoryboardFloatsAreEqual(frame.size.width, size.width) && HSStoryboardFloatsAreEqual(frame.size.height, size.height)) {
        return;
    }
    [super setFrameSize:size];
}

- (NSSize)requiredSizeToFitAllItems
{
    return [[self storyboardCell] requiredSizeToFitAllItems];
}

- (id)items
{
    HSStoryboardItemsCache *pHVar1;
    HSStoryboardItemsCache *pHVar1_2;

    pHVar1 = _items;
    if (pHVar1 == nil) {
        pHVar1_2 = [[HSStoryboardItemsCache alloc] init];
        _items = pHVar1_2;
        [pHVar1_2 setParentView:self];
        pHVar1 = _items;
    }
    return pHVar1;
}

- (BOOL)acceptsFirstMouse:(id)aMouse
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)isOpaque
{
    return NO;
}

- (BOOL)isFlipped
{
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007fddc @ 0007fddc, 95 bytes * /

void FUN_0007fddc(HSStoryboardView *self,SEL _cmd,id cardsDidDelete)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cardsDidDelete,sel_userInfo);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,*(undefined4 *)PTR_PTR_00336410);
  _objc_msgSend(self,sel_recalculateSelectionIndexIfNeeded_,pvVar1);
  return;
}

*/
- (void)cardsDidDelete:(id)aDelete
{
    [self recalculateSelectionIndexIfNeeded:[[aDelete userInfo] objectForKey:HSCardsIndexesForRemovalKey]];
}

- (void)recalculateSelectionIndexIfNeeded:(id)aNeeded
{
    unsigned int uVar2;
    NSUInteger pvVar1_2;

    if ([_items numberOfItems] != 0) {
        pvVar1_2 = [aNeeded firstIndex];
        uVar2 = (int)pvVar1_2 - 1;
        if (pvVar1_2 == 0) {
            uVar2 = 0;
        }
        if (_selectionIndex != uVar2) {
            _selectionIndex = uVar2;
            [self selectItem:[[self items] objectInStoryboardItemsAtIndex:_selectionIndex]];
        }
    }
}

- (void)mouseUp:(id)aUp
{
    if (_shouldSelectItem != NO) {
        [self selectItem:_itemToSelect];
        _itemToSelect = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007f98d @ 0007f98d, 883 bytes * /

void FUN_0007f98d(HSStoryboardView *self,SEL _cmd,id mouseDown)

{
  id pvVar1;
  id pvVar2;
  HSStoryboardItem *pHVar3;
  id pvVar4;
  id self_00;
  id pvVar5;
  id pvVar6;
  HSStoryboardView *self_01;
  undefined4 extraout_EDX;
  id extraout_EDX_00;
  HSStoryboardView *pHVar7;
  SEL op;
  undefined *puVar8;
  id *ppvVar9;
  id local_14;
  
  self->_shouldSelectItem = '\0';
  self->_itemToSelect = (HSStoryboardItem *)0x0;
  pvVar1 = _objc_msgSend(mouseDown,sel_locationInWindow);
  pvVar2 = _objc_msgSend(self,sel_convertPoint_fromView_,pvVar1,extraout_EDX,0);
  local_14 = (id)0x7fffffff;
  ppvVar9 = &local_14;
  pvVar1 = extraout_EDX_00;
  pHVar3 = _objc_msgSend(self,sel_itemAtPoint_index_,pvVar2,extraout_EDX_00,ppvVar9);
  pvVar4 = _objc_msgSend(mouseDown,sel_modifierFlags);
  pHVar7 = self;
  if (pHVar3 == (HSStoryboardItem *)0x0) {
    op = sel_selectObject_;
    self_01 = (HSStoryboardView *)0x0;
  }
  else if (((uint)pvVar4 & 0x20000) == 0) {
    if (((uint)pvVar4 & 0x100000) == 0) {
      self->_shouldSelectItem = '\x01';
      self->_itemToSelect = pHVar3;
      pvVar2 = _objc_msgSend(mouseDown,sel_clickCount,pvVar2,pvVar1,ppvVar9);
      if (pvVar2 != (id)0x2) {
        return;
      }
      puVar8 = sel_storyboardView_didSelectCard_;
      pvVar2 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,
                             sel_storyboardView_didSelectCard_,pvVar1,ppvVar9);
      if ((char)pvVar2 == '\0') {
        return;
      }
      pHVar7 = self->_delegate;
      pvVar1 = _objc_msgSend(self->_itemToSelect,sel_card,puVar8,pvVar1,ppvVar9);
      op = sel_storyboardView_didSelectCard_;
      self_01 = self;
    }
    else {
      pvVar2 = _objc_msgSend(self->_items,sel_selectedItems,pvVar2,pvVar1,ppvVar9);
      pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_,pHVar3);
      self_01 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,pHVar3);
      op = sel_addItemsToSelection_;
      if ((char)pvVar2 != '\0') {
        op = sel_removeItemsFromSelection_;
      }
    }
  }
  else {
    pvVar4 = _objc_msgSend(self->_items,sel_selectedItems,pvVar2,pvVar1,ppvVar9);
    pvVar4 = _objc_msgSend(pvVar4,sel_count);
    if (pvVar4 == (id)0x0) {
      self_01 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,pHVar3,pvVar1,ppvVar9);
      op = sel_addItemsToSelection_;
    }
    else {
      pvVar4 = _objc_msgSend(self->_items,sel_selectedItems,pvVar2,pvVar1,ppvVar9);
      self_00 = _objc_msgSend(pvVar4,sel_objectEnumerator);
      pvVar5 = (id)0x7fffffff;
      pvVar4 = (id)0x7fffffff;
      while (pvVar6 = _objc_msgSend(self_00,sel_nextObject,pvVar2), pvVar6 != (id)0x0) {
        pvVar5 = _objc_msgSend(self->_items,sel_indexOfStoryboardItem_,pvVar6);
        pvVar2 = pvVar6;
        if (pvVar4 == (id)0x7fffffff || pvVar5 < pvVar4) {
          pvVar4 = pvVar5;
        }
      }
      if (pvVar5 == (id)0x7fffffff || pvVar5 < local_14) {
        pvVar5 = local_14;
      }
      if (pvVar4 == (id)0x7fffffff || local_14 < pvVar4) {
        pvVar4 = local_14;
      }
      self_01 = _objc_msgSend(cls_NSMutableArray,sel_array,pvVar2);
      for (; op = sel_addItemsToSelection_, pvVar4 <= pvVar5; pvVar4 = (id)((int)pvVar4 + 1)) {
        pvVar2 = _objc_msgSend(self->_items,sel_objectInStoryboardItemsAtIndex_,pvVar4);
        _objc_msgSend(self_01,sel_addObject_,pvVar2);
      }
    }
  }
  _objc_msgSend(pHVar7,op,self_01,pvVar1,ppvVar9);
  return;
}

*/
- (void)mouseDown:(id)aDown
{
    _shouldSelectItem = NO;
    _itemToSelect = nil;
    NSPoint point = [self convertPoint:[aDown locationInWindow] fromView:nil];
    unsigned int index = INT_MAX;
    HSStoryboardItem *item = [self itemAtPoint:point index:&index];
    NSEventModifierFlags flags = [aDown modifierFlags];
    if (item == nil) {
        [self selectObject:nil];
        return;
    }
    if (flags & NSEventModifierFlagShift) {
        if ([[_items selectedItems] count] == 0) {
            [self addItemsToSelection:[NSArray arrayWithObject:item]];
            return;
        }
        // Extend the selection to a contiguous range.
        NSUInteger last = NSNotFound;
        NSUInteger first = NSNotFound;
        for (id selected in [_items selectedItems]) {
            last = [_items indexOfStoryboardItem:selected];
            if (first == NSNotFound || last < first) {
                first = last;
            }
        }
        // The original takes the last enumerated index as the upper bound.
        if (last == NSNotFound || last < index) {
            last = index;
        }
        if (first == NSNotFound || index < first) {
            first = index;
        }
        NSMutableArray *items = [NSMutableArray array];
        for (NSUInteger i = first; i <= last; i++) {
            [items addObject:[_items objectInStoryboardItemsAtIndex:i]];
        }
        [self addItemsToSelection:items];
    } else if (flags & NSEventModifierFlagCommand) {
        NSArray *items = [NSArray arrayWithObject:item];
        if ([[_items selectedItems] containsObject:item]) {
            [self removeItemsFromSelection:items];
        } else {
            [self addItemsToSelection:items];
        }
    } else {
        // Plain clicks select on mouse up, so a drag can start first.
        _shouldSelectItem = YES;
        _itemToSelect = item;
        if ([aDown clickCount] == 2 && [_delegate respondsToSelector:@selector(storyboardView:didSelectCard:)]) {
            [_delegate storyboardView:self didSelectCard:[_itemToSelect card]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007f892 @ 0007f892, 251 bytes * /

id FUN_0007f892(HSStoryboardView *self,SEL _cmd,NSPoint itemAtPoint,uint *index)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float fVar4;
  
  pvVar1 = _objc_msgSend(self,sel_storyboardCell);
  pvVar2 = _objc_msgSend(self,sel_storyboardLayout);
  fVar4 = itemAtPoint.y;
  pvVar2 = _objc_msgSend(pvVar2,sel_itemIndexAtPoint_,itemAtPoint.x,itemAtPoint.y);
  pvVar3 = _objc_msgSend(self->_items,sel_numberOfItems);
  if (pvVar2 < pvVar3) {
    pvVar3 = _objc_msgSend(self->_items,sel_objectInStoryboardItemsAtIndex_,pvVar2,fVar4);
    pvVar1 = _objc_msgSend(pvVar1,sel_hitTestPoint_inItem_atIndex_inView_,itemAtPoint.x,
                           itemAtPoint.y,pvVar3,pvVar2,self);
    if ((char)pvVar1 != '\0') goto LAB_0007f96e;
  }
  pvVar3 = (id)0x0;
LAB_0007f96e:
  if (index != (uint *)0x0) {
    if (pvVar3 == (id)0x0) {
      pvVar2 = (id)0x7fffffff;
    }
    *index = (uint)pvVar2;
  }
  return pvVar3;
}

*/
- (id)itemAtPoint:(NSPoint)aPoint index:(unsigned int *)aIndex
{
    HSStoryboardCell *cell = [self storyboardCell];
    NSUInteger index = [[self storyboardLayout] itemIndexAtPoint:aPoint];
    id item = nil;
    if (index < [_items numberOfItems]) {
        item = [_items objectInStoryboardItemsAtIndex:index];
        if (![cell hitTestPoint:aPoint inItem:item atIndex:index inView:self]) {
            item = nil;
        }
    }
    if (aIndex != NULL) {
        *aIndex = item != nil ? (unsigned int)index : INT_MAX;
    }
    return item;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000858da @ 000858da, 907 bytes * /

void FUN_000858da(HSStoryboardView *self,SEL _cmd,NSRect drawRect)

{
  HSStoryboardItemsCache *pHVar1;
  HSStoryboardLayout *pHVar2;
  undefined *self_00;
  char cVar3;
  id pvVar4;
  id self_01;
  id pvVar5;
  float extraout_EDX;
  float extraout_EDX_00;
  int *piVar6;
  int *piVar7;
  id pvVar8;
  int local_88 [2];
  float local_50;
  undefined1 local_44 [16];
  undefined8 local_34;
  undefined8 local_2c;
  float local_24;
  float local_20;
  
  pvVar4 = _objc_msgSend(self,sel_backgroundColor);
  _objc_msgSend(pvVar4,sel_set);
  self_00 = cls_NSBezierPath;
  _objc_msgSend_stret(local_44,self,sel_bounds);
  piVar7 = (int *)&stack0xffffff80;
  _objc_msgSend(self_00,sel_fillRect_);
  pvVar4 = _objc_msgSend(self->_items,sel_numberOfItems);
  self_01 = _objc_msgSend(self,sel_storyboardCell);
  if (self->_inLiveScale != '\0') {
    _objc_msgSend(self_01,sel_setCanRecacheCardThumbnail_);
  }
  if (pvVar4 != (id)0x0) {
    pvVar8 = (id)0x0;
    piVar6 = (int *)&stack0xffffff80;
    do {
      pHVar1 = self->_items;
      piVar6[2] = (int)pvVar8;
      piVar6[1] = (int)sel_objectInStoryboardItemsAtIndex_;
      *piVar6 = (int)pHVar1;
      piVar6[-1] = 0x859e0;
      pvVar5 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
      piVar6[2] = (int)sel_frame;
      piVar6[1] = (int)pvVar5;
      *piVar6 = (int)&local_34;
      piVar6[-1] = 0x859fe;
      _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
      piVar7 = piVar6 + -1;
      *(NSSize *)(piVar6 + 5) = drawRect.size;
      *(NSPoint *)(piVar6 + 3) = drawRect.origin;
      *(undefined8 *)(piVar6 + 1) = local_2c;
      *(undefined8 *)(piVar6 + -1) = local_34;
      piVar6[-2] = 0x85a30;
      cVar3 = _NSIntersectsRect();
      if (cVar3 != '\0') {
        *(NSSize *)(piVar6 + 5) = drawRect.size;
        *(NSPoint *)(piVar6 + 3) = drawRect.origin;
        piVar6[2] = (int)self;
        piVar6[1] = (int)pvVar5;
        *piVar6 = (int)sel_renderItem_inView_rect_;
        piVar6[-1] = (int)self_01;
        piVar6[-2] = 0x85a6c;
        _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
      }
      pvVar8 = (id)((int)pvVar8 + 1);
      piVar6 = piVar6 + -1;
    } while (pvVar8 < pvVar4);
  }
  piVar7[1] = (int)sel_setCanRecacheCardThumbnail_;
  *piVar7 = (int)self_01;
  piVar7[2] = 1;
  piVar7[-1] = 0x85a96;
  _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
  pHVar1 = self->_items;
  piVar7[1] = (int)sel_dropIndex;
  *piVar7 = (int)pHVar1;
  piVar7[-1] = 0x85aae;
  pvVar4 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
  if (pvVar4 != (id)0x7fffffff) {
    piVar7[1] = (int)sel_bezierPath;
    *piVar7 = (int)cls_NSBezierPath;
    piVar7[-1] = 0x85ad6;
    pvVar8 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    pHVar2 = self->_storyboardLayout;
    piVar7[3] = (int)pvVar4;
    piVar7[2] = (int)sel_frameForItemAtIndex_;
    piVar7[1] = (int)pHVar2;
    *piVar7 = (int)&local_24;
    piVar7[-1] = 0x85afe;
    _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
    local_50 = local_24;
    *piVar7 = (int)sel_maxCardsPerRow;
    piVar7[-1] = (int)self_01;
    piVar7[-2] = 0x85b2a;
    pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    if ((uint)pvVar4 % (uint)pvVar5 == 0) {
      local_50 = local_24 + 1.0;
    }
    piVar7[2] = (int)local_20;
    piVar7[1] = (int)local_50;
    *piVar7 = (int)sel_moveToPoint_;
    piVar7[-1] = (int)pvVar8;
    piVar7[-2] = 0x85b75;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_cardFrameSize;
    piVar7[-1] = (int)self_01;
    piVar7[-2] = 0x85b8d;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_cardFrameOffset;
    piVar7[-1] = (int)self_01;
    piVar7[-2] = 0x85ba4;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_setLineWidth_;
    piVar7[-1] = (int)pvVar8;
    piVar7[1] = 0x40400000;
    piVar7[-2] = 0x85bdb;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    piVar7[2] = (int)(extraout_EDX_00 + extraout_EDX_00 + extraout_EDX + local_20);
    piVar7[1] = (int)local_50;
    *piVar7 = (int)sel_lineToPoint_;
    piVar7[-1] = (int)pvVar8;
    piVar7[-2] = 0x85c06;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_cardBorderRenderer;
    piVar7[-1] = (int)self;
    piVar7[-2] = 0x85c1e;
    pvVar4 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_fillColor;
    piVar7[-1] = (int)pvVar4;
    piVar7[-2] = 0x85c33;
    pvVar4 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_set;
    piVar7[-1] = (int)pvVar4;
    piVar7[-2] = 0x85c48;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
    *piVar7 = (int)sel_stroke;
    piVar7[-1] = (int)pvVar8;
    piVar7[-2] = 0x85c5d;
    _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
  }
  return;
}

*/
- (void)drawRect:(NSRect)aRect
{
    [(NSColor *)[self backgroundColor] set];
    [NSBezierPath fillRect:[self bounds]];
    NSUInteger count = [_items numberOfItems];
    HSStoryboardCell *cell = [self storyboardCell];
    if (_inLiveScale) {
        [cell setCanRecacheCardThumbnail:NO];
    }
    for (NSUInteger i = 0; i < count; i++) {
        id item = [_items objectInStoryboardItemsAtIndex:i];
        if (NSIntersectsRect([item frame], aRect)) {
            [cell renderItem:item inView:self rect:aRect];
        }
    }
    [cell setCanRecacheCardThumbnail:YES];
    NSUInteger dropIndex = [_items dropIndex];
    if (dropIndex != NSNotFound) {
        // Insertion marker on the left edge of the drop slot.
        NSBezierPath *path = [NSBezierPath bezierPath];
        NSRect frame = [_storyboardLayout frameForItemAtIndex:dropIndex];
        CGFloat x = frame.origin.x;
        if (dropIndex % [cell maxCardsPerRow] == 0) {
            x = frame.origin.x + 1.0;
        }
        [path moveToPoint:NSMakePoint(x, frame.origin.y)];
        NSSize cardFrameSize = [cell cardFrameSize];
        NSPoint cardFrameOffset = [cell cardFrameOffset];
        [path setLineWidth:3.0];
        [path lineToPoint:NSMakePoint(x, cardFrameOffset.y + cardFrameOffset.y + cardFrameSize.height + frame.origin.y)];
        [(NSColor *)[[self cardBorderRenderer] fillColor] set];
        [path stroke];
    }
}

- (void)setBackgroundColor:(id)aColor
{
    if (![_backgroundColor isEqual:aColor]) {
        [_backgroundColor release];
        _backgroundColor = [aColor retain];
        [self setNeedsDisplay:YES];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007f7a2 @ 0007f7a2, 114 bytes * /

id FUN_0007f7a2(HSStoryboardView *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = self->_backgroundColor;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_backgroundPattern);
    op = sel_colorWithPatternImage_;
    if (pvVar1 == (id)0x0) {
      op = sel_clearColor;
    }
    pvVar1 = _objc_msgSend(cls_NSColor,op);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_backgroundColor = pvVar1;
  }
  return pvVar1;
}

*/
- (id)backgroundColor
{
    if (_backgroundColor == nil) {
        NSImage *pattern = [self backgroundPattern];
        _backgroundColor = [(pattern != nil ? [NSColor colorWithPatternImage:pattern] : [NSColor clearColor]) retain];
    }
    return _backgroundColor;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007f6c2 @ 0007f6c2, 224 bytes * /

id FUN_0007f6c2(HSStoryboardView *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  
  pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pcVar2 = _objc_msgSend(pvVar1,sel_stringForKey_,*(undefined4 *)PTR_00336054);
  pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar3 = _objc_msgSend(cls_NSBundle,sel_mainBundle);
  pcVar4 = &cfstr_Denim;
  if (pcVar2 != (cfstringStruct *)0x0) {
    pcVar4 = pcVar2;
  }
  pvVar3 = _objc_msgSend(pvVar3,sel_pathForResource_ofType_inDirectory_,pcVar4,&cfstr_tiff,
                         &cfstr_WABPatterns);
  pvVar1 = _objc_msgSend(pvVar1,sel_initByReferencingFile_,pvVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  return pvVar1;
}

*/
- (id)backgroundPattern
{
    NSString *patternName = [[NSUserDefaults standardUserDefaults] stringForKey:HSWorkAreaBackgroundKey];
    NSString *path = [[NSBundle mainBundle] pathForResource:patternName != nil ? patternName : @"Denim" ofType:@"tiff" inDirectory:@"WABPatterns"];
    return [[[NSImage alloc] initByReferencingFile:path] autorelease];
}

- (void)animationDidEndForStoryboardLayout:(id)aLayout
{
    [_windowUpdateTimer invalidate];
    _windowUpdateTimer = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007f5e6 @ 0007f5e6, 164 bytes * /

void FUN_0007f5e6(HSStoryboardView *self,SEL _cmd,id animationWillStartForStoryboardLayout)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSTimer,sel_timerWithTimeInterval_target_selector_userInfo_repeats_,
                         0xa0000000,0x3fa99999,self,sel_updateWindowWithTimer_,0,1);
  self->_windowUpdateTimer = pvVar1;
  pvVar1 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
  _objc_msgSend(pvVar1,sel_addTimer_forMode_,self->_windowUpdateTimer,*(undefined4 *)PTR_00336064);
  return;
}

*/
- (void)animationWillStartForStoryboardLayout:(id)aLayout
{
    // Not retained and only run while tracking events, as in the original.
    _windowUpdateTimer = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(updateWindowWithTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_windowUpdateTimer forMode:NSEventTrackingRunLoopMode];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007ee0a @ 0007ee0a, 2012 bytes * /

BOOL FUN_0007ee0a(HSStoryboardView *self,SEL _cmd,id validateUserInterfaceItem)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  undefined *self_00;
  bool bVar6;
  SEL op;
  cfstringStruct *pcVar7;
  
  puVar1 = _objc_msgSend(validateUserInterfaceItem,sel_action);
  if ((puVar1 == sel_cut_) || (puVar1 == sel_copy_)) {
    pvVar2 = _objc_msgSend(self->_items,sel_selectedItems);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    bVar6 = pvVar2 != (id)0x0;
    if (pvVar2 == (id)0x0) {
LAB_0007efcc:
      pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_class);
      pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar2);
      if ((char)pvVar3 == '\0') {
        return bVar6;
      }
      self_00 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar2);
      pcVar5 = &cfstr_HSCopyMenuTitle;
      if (puVar1 == sel_cut_) {
        pcVar5 = &cfstr_HSCutMenuTitle;
      }
      goto LAB_0007f23b;
    }
    pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_class);
    pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar2);
    if ((char)pvVar3 == '\0') goto LAB_0007efcc;
    pvVar2 = _objc_msgSend(self->_items,sel_selectedItems,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    if (pvVar2 < (id)0x2) {
      pcVar5 = &cfstr_HSCopyCard;
    }
    else {
      pcVar5 = &cfstr_HSCopyCards;
    }
    pcVar4 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                           &cfstr_Editor);
    self_00 = cls_NSString;
    pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
    pcVar5 = &cfstr_HSCopyFormat;
    if (puVar1 == sel_cut_) {
      pcVar5 = &cfstr_HSCutFormat;
    }
    pcVar7 = &cfstr_Editor;
    pcVar5 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                           &cfstr_Editor);
    op = sel_stringWithFormat_;
  }
  else {
    if (puVar1 != sel_delete_) {
      if (puVar1 != sel_paste_) {
        return '\x01';
      }
      pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_class);
      pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar2);
      if ((char)pvVar3 == '\0') {
        return '\x01';
      }
      pvVar3 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard,pvVar2);
      _objc_msgSend(cls_NSString,sel_string);
      pvVar2 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_HSCardPasteboardType);
      pvVar2 = _objc_msgSend(pvVar3,sel_availableTypeFromArray_,pvVar2);
      if ((pvVar2 == (id)0x0) ||
         (pvVar2 = _objc_msgSend(pvVar3,sel_propertyListForType_,&cfstr_HSCardPasteboardType),
         pvVar2 == (id)0x0)) {
        pvVar2 = _objc_msgSend(self,sel_canImportImageFromPasteboard_,pvVar3);
        if ((char)pvVar2 != '\0') {
          pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
          pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_HSPasteImage,
                                 &cfstr_empty,&cfstr_Editor);
          puVar1 = cls_NSString;
          pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
          pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSPasteFormat,
                                 &cfstr_empty,&cfstr_Editor);
          pvVar2 = _objc_msgSend(puVar1,sel_stringWithFormat_,pvVar3,pvVar2);
          _objc_msgSend(validateUserInterfaceItem,sel_setTitle_,pvVar2);
          return '\x01';
        }
        bVar6 = false;
      }
      else {
        pvVar2 = _objc_msgSend(pvVar3,sel_propertyListForType_,&cfstr_HSCardPasteboardType);
        pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_HSSerializedCardsKey);
        pvVar2 = _objc_msgSend(pvVar2,sel_count);
        pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        if (pvVar2 < (id)0x2) {
          pcVar5 = &cfstr_HSPasteCard;
        }
        else {
          pcVar5 = &cfstr_HSPasteCards;
        }
        pvVar2 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                               &cfstr_Editor);
        puVar1 = cls_NSString;
        pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSPasteFormat,
                               &cfstr_empty,&cfstr_Editor);
        pvVar3 = _objc_msgSend(puVar1,sel_stringWithFormat_,pvVar3,pvVar2);
        _objc_msgSend(validateUserInterfaceItem,sel_setTitle_,pvVar3);
        bVar6 = true;
      }
      pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
      pcVar7 = &cfstr_Editor;
      pcVar4 = &cfstr_empty;
      pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_HSPasteMenuTitle,
                             &cfstr_empty,&cfstr_Editor);
      goto LAB_0007f263;
    }
    pvVar2 = _objc_msgSend(self->_items,sel_selectedItems);
    pvVar2 = _objc_msgSend(pvVar2,sel_count);
    bVar6 = pvVar2 != (id)0x0;
    if (bVar6) {
      pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_class);
      pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar2);
      if ((char)pvVar3 != '\0') {
        pvVar2 = _objc_msgSend(self->_items,sel_selectedItems,pvVar2);
        pvVar2 = _objc_msgSend(pvVar2,sel_count);
        pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        if (pvVar2 < (id)0x2) {
          pcVar5 = &cfstr_HSCopyCard;
        }
        else {
          pcVar5 = &cfstr_HSCopyCards;
        }
        pcVar4 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar5,&cfstr_empty,
                               &cfstr_Editor);
        self_00 = cls_NSString;
        pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pcVar7 = &cfstr_Editor;
        pcVar5 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_HSDeleteFormat,
                               &cfstr_empty,&cfstr_Editor);
        op = sel_stringWithFormat_;
        goto LAB_0007f243;
      }
    }
    pvVar2 = _objc_msgSend(cls_NSMenuItem,sel_class);
    pvVar3 = _objc_msgSend(validateUserInterfaceItem,sel_isKindOfClass_,pvVar2);
    if ((char)pvVar3 == '\0') {
      return bVar6;
    }
    self_00 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar2);
    pcVar5 = &cfstr_HSDeleteMenuTitle;
LAB_0007f23b:
    pcVar7 = &cfstr_Editor;
    pcVar4 = &cfstr_empty;
    op = sel_localizedStringForKey_value_table_;
  }
LAB_0007f243:
  pvVar2 = _objc_msgSend(self_00,op,pcVar5,pcVar4,pcVar7);
LAB_0007f263:
  _objc_msgSend(validateUserInterfaceItem,sel_setTitle_,pvVar2,pcVar4,pcVar7);
  return bVar6;
}

*/
- (BOOL)validateUserInterfaceItem:(id)aItem
{
    SEL action = [(id<NSValidatedUserInterfaceItem>)aItem action];
    BOOL isMenuItem = [aItem isKindOfClass:[NSMenuItem class]];
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    if (action == @selector(cut:) || action == @selector(copy:) || action == @selector(delete:)) {
        NSUInteger count = [[_items selectedItems] count];
        BOOL enabled = count != 0;
        if (!isMenuItem) {
            return enabled;
        }
        if (enabled) {
            NSString *cards = [resources localizedStringForKey:(count < 2 ? @"HSCopyCard" : @"HSCopyCards") value:@"" table:@"Editor"];
            NSString *formatKey = action == @selector(delete:) ? @"HSDeleteFormat" : (action == @selector(cut:) ? @"HSCutFormat" : @"HSCopyFormat");
            [aItem setTitle:[NSString stringWithFormat:[resources localizedStringForKey:formatKey value:@"" table:@"Editor"], cards]];
        } else {
            NSString *titleKey = action == @selector(delete:) ? @"HSDeleteMenuTitle" : (action == @selector(cut:) ? @"HSCutMenuTitle" : @"HSCopyMenuTitle");
            [aItem setTitle:[resources localizedStringForKey:titleKey value:@"" table:@"Editor"]];
        }
        return enabled;
    }
    if (action != @selector(paste:) || !isMenuItem) {
        return YES;
    }
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    BOOL enabled;
    if ([pasteboard availableTypeFromArray:[NSArray arrayWithObject:@"HSCardPasteboardType"]] != nil
        && [pasteboard propertyListForType:@"HSCardPasteboardType"] != nil) {
        NSUInteger count = [[[pasteboard propertyListForType:@"HSCardPasteboardType"] objectForKey:@"HSSerializedCardsKey"] count];
        NSString *cards = [resources localizedStringForKey:(count < 2 ? @"HSPasteCard" : @"HSPasteCards") value:@"" table:@"Editor"];
        [aItem setTitle:[NSString stringWithFormat:[resources localizedStringForKey:@"HSPasteFormat" value:@"" table:@"Editor"], cards]];
        enabled = YES;
    } else if ([self canImportImageFromPasteboard:pasteboard]) {
        NSString *image = [resources localizedStringForKey:@"HSPasteImage" value:@"" table:@"Editor"];
        [aItem setTitle:[NSString stringWithFormat:[resources localizedStringForKey:@"HSPasteFormat" value:@"" table:@"Editor"], image]];
        return YES;
    } else {
        enabled = NO;
    }
    // The original replaces the card count title with the plain one here.
    [aItem setTitle:[resources localizedStringForKey:@"HSPasteMenuTitle" value:@"" table:@"Editor"]];
    return enabled;
}

- (void)setSelectionChangeDelegate:(id)aDelegate
{
    if (_selectionChangeDelegate != aDelegate) {
        _selectionChangeDelegate = aDelegate;
        [self updateSelectionWithSelectionAccessor:aDelegate];
    }
}

- (id)selectionChangeDelegate
{
    return _selectionChangeDelegate;
}

- (void)displaySelectionHolderInactiveState
{

}

- (void)displaySelectionHolderActiveStateAndBecomeFirstResponder:(BOOL)aResponder
{

}

- (BOOL)isPrimarySelectionAccessorForCurrentlyHeldSelection
{
    return YES;
}

- (BOOL)updateSelectionWithInactiveCardViewSelectionAccessor:(id)aAccessor
{
    return NO;
}

- (BOOL)isInterestedToBeSynchronizedWithInactiveCardViewSelectionAccessor:(id)aAccessor
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0007ed31 @ 0007ed31, 164 bytes * /

BOOL FUN_0007ed31(HSStoryboardView *self,SEL _cmd,id updateSelectionWithSelectionAccessor)

{
  BOOL BVar1;
  id pvVar2;
  SEL op;
  int iVar3;
  int *piVar4;
  int local_18;
  int local_14;
  
  pvVar2 = _objc_msgSend(updateSelectionWithSelectionAccessor,sel_queryHyperInterface_,&DAT_00365e08
                        );
  if (pvVar2 == (id)0x0) {
    BVar1 = '\0';
  }
  else {
    local_14 = 0;
    local_18 = 0;
    piVar4 = &local_14;
    _objc_msgSend(updateSelectionWithSelectionAccessor,sel_getSelectedHyperObject_orObjects_,
                  &local_18,piVar4);
    op = sel_selectObject_;
    iVar3 = local_18;
    if (local_14 != 0) {
      op = sel_selectObjects_;
      iVar3 = local_14;
    }
    _objc_msgSend(self,op,iVar3,piVar4);
    BVar1 = '\x01';
  }
  return BVar1;
}

*/
- (BOOL)updateSelectionWithSelectionAccessor:(id)aAccessor
{
    if ([aAccessor queryHyperInterface:@protocol(HSCardSelectionAccessor)] == nil) {
        return NO;
    }
    id object = nil;
    id objects = nil;
    [aAccessor getSelectedHyperObject:&object orObjects:&objects];
    if (objects != nil) {
        [self selectObjects:objects];
    } else {
        [self selectObject:object];
    }
    return YES;
}

- (void)selectHyperObjects:(id)aObjects
{
    [self selectObjects:aObjects];
    [self notifyHyperSelectionDidChangeAndActivate:YES];
}

- (void)selectHyperObject:(id)aObject
{
    [self selectObject:aObject];
    [self notifyHyperSelectionDidChangeAndActivate:YES];
}

- (void)selectObjects:(id)aObjects
{
    NSUInteger pvVar1;
    NSUInteger pvVar2;
    NSUInteger pvVar4;
    id pvVar2_2;

    pvVar1 = [aObjects count];
    if (pvVar1 != 0) {
        pvVar2 = [aObjects count];
        pvVar4 = 0;
        pvVar2_2 = [NSMutableArray arrayWithCapacity:pvVar2];
        do {
            [pvVar2_2 addObject:[_items itemForCard:[aObjects objectAtIndex:pvVar4]]];
            pvVar4 = (pvVar4 + 1);
        } while (pvVar4 < pvVar1);
        [self selectItems:pvVar2_2];
    }
}

- (void)selectObject:(id)aObject
{
    [self selectItem:[[self items] itemForCard:aObject]];
}

- (id)selectedHyperObject
{
    return [[self items] selectedHyperObject];
}

- (id)activeCard
{
    return [[self items] activeCard];
}

- (void)endDragOperation
{

}

- (void)beginDragOperation
{

}

- (BOOL)needImageOriginConvertion
{
    return YES;
}

- (NSRect)convertToDragHostCardRect:(NSRect)aRect
{
    NSRect result;

    result.origin.x = aRect.origin.x;
    result.origin.y = aRect.origin.y;
    result.size.width = aRect.size.width;
    result.size.height = aRect.size.height;
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00085c65 @ 00085c65, 385 bytes * /

ulonglong FUN_00085c65(HSStoryboardView *self,SEL _cmd,NSPoint convertPointFromDragHostToCard)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  float extraout_EDX;
  float extraout_EDX_00;
  float local_24;
  float local_20;
  float local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_storyboardLayout);
  pvVar1 = _objc_msgSend(pvVar1,sel_itemIndexAtPoint_,convertPointFromDragHostToCard.x,
                         convertPointFromDragHostToCard.y);
  pvVar2 = _objc_msgSend(self,sel_cardBorderRenderer);
  pvVar2 = _objc_msgSend(pvVar2,sel_thumbnailSize);
  self_00 = _objc_msgSend(self,sel_storyboardLayout);
  _objc_msgSend_stret(&local_24,self_00,sel_frameForItemAtIndex_,pvVar1);
  pvVar1 = _objc_msgSend(self,sel_cardForDragHost);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00365e44);
  _objc_msgSend(pvVar1,sel_size);
  pvVar1 = _objc_msgSend(pvVar1,sel_size);
  return CONCAT44(extraout_EDX_00 * ((convertPointFromDragHostToCard.y - local_20) / extraout_EDX),
                  (float)pvVar1 *
                  (((local_1c - (float)pvVar2) * -0.5 +
                   (convertPointFromDragHostToCard.x - local_24)) / (float)pvVar2));
}

*/
- (NSPoint)convertPointFromDragHostToCard:(NSPoint)aCard
{
    NSUInteger index = [[self storyboardLayout] itemIndexAtPoint:aCard];
    NSSize thumbnailSize = [(HSCardBorderRenderer *)[self cardBorderRenderer] thumbnailSize];
    NSRect frame = [[self storyboardLayout] frameForItemAtIndex:index];
    NSSize cardSize = [(id<HSSizeAttributes>)[[self cardForDragHost] queryHyperInterface:@protocol(HSSizeAttributes)] size];
    // The thumbnail is centred horizontally in the item frame.
    CGFloat x = cardSize.width * (((frame.size.width - thumbnailSize.width) * -0.5 + (aCard.x - frame.origin.x)) / thumbnailSize.width);
    CGFloat y = cardSize.height * ((aCard.y - frame.origin.y) / thumbnailSize.height);
    return NSMakePoint(x, y);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00085de6 @ 00085de6, 164 bytes * /

ulonglong FUN_00085de6(HSStoryboardView *self,SEL _cmd)

{
  id pvVar1;
  undefined4 extraout_EDX;
  float local_2c [2];
  float local_24;
  float local_1c [2];
  float local_14;
  
  _objc_msgSend_stret(local_2c,self,sel_bounds);
  _objc_msgSend_stret(local_1c,self,sel_bounds);
  pvVar1 = _objc_msgSend(self,sel_convertPoint_fromView_,local_14 * 0.5 + local_1c[0],
                         local_24 * 0.5 + local_2c[0],0);
  return CONCAT44(extraout_EDX,pvVar1);
}

*/
- (NSPoint)dragHostCardCenterPoint
{
    NSRect bounds = [self bounds];
    return [self convertPoint:NSMakePoint(bounds.size.width * 0.5 + bounds.origin.x, bounds.size.height * 0.5 + bounds.origin.y) fromView:nil];
}

- (id)cardForDragHost
{
    return [self selectedHyperObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00085e8a @ 00085e8a, 682 bytes * /

void FUN_00085e8a(HSStoryboardView *self,SEL _cmd,BOOL deleteSelectedCardsUsePoofAnimation)

{
  int iVar1;
  int iVar2;
  HSStoryboardItemsCache *pHVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int extraout_EDX;
  int extraout_EDX_00;
  int *piVar7;
  int *piVar8;
  int aiStack_64 [2];
  float local_54;
  int local_50 [11];
  float local_24;
  float local_20;
  float local_1c;
  float local_18;
  
  pvVar4 = _objc_msgSend(self->_items,sel_selectedItems);
  pvVar4 = _objc_msgSend(pvVar4,sel_objectEnumerator);
  piVar8 = (int *)&stack0xffffffa4;
  if (deleteSelectedCardsUsePoofAnimation != '\0') {
    pvVar5 = _objc_msgSend(pvVar4,sel_nextObject);
    piVar8 = (int *)&stack0xffffffa4;
    if (pvVar5 != (id)0x0) {
      iVar1 = *(int *)PTR_0033607c;
      iVar2 = *(int *)(PTR_0033607c + 4);
      piVar7 = (int *)&stack0xffffffa4;
      do {
        piVar7[1] = (int)sel_storyboardLayout;
        *piVar7 = (int)self;
        piVar7[-1] = 0x85f1d;
        pvVar6 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
        pHVar3 = self->_items;
        piVar7[2] = (int)pvVar5;
        piVar7[1] = (int)sel_indexOfStoryboardItem_;
        *piVar7 = (int)pHVar3;
        piVar7[-1] = 0x85f3b;
        pvVar5 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
        piVar7[3] = (int)pvVar5;
        piVar7[2] = (int)sel_frameForItemAtIndex_;
        piVar7[1] = (int)pvVar6;
        *piVar7 = (int)&local_24;
        piVar7[-1] = 0x85f58;
        _objc_msgSend_stret((void *)*piVar7,(id)piVar7[1],(SEL)piVar7[2]);
        piVar8 = piVar7 + -1;
        piVar7[2] = (int)(local_18 * 0.5 + local_20);
        piVar7[1] = (int)(local_1c * 0.5 + local_24);
        *piVar7 = (int)sel_convertPoint_toView_;
        piVar7[-1] = (int)self;
        piVar7[3] = 0;
        piVar7[-2] = 0x85fa8;
        pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
        *piVar7 = (int)sel_window;
        piVar7[-1] = (int)self;
        piVar7[-2] = 0x85fc1;
        pvVar6 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
        piVar7[2] = extraout_EDX;
        piVar7[1] = (int)pvVar5;
        *piVar7 = (int)sel_convertBaseToScreen_;
        piVar7[-1] = (int)pvVar6;
        piVar7[-2] = 0x85fdb;
        pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
        piVar7[3] = iVar2;
        piVar7[2] = iVar1;
        piVar7[1] = extraout_EDX_00;
        *piVar7 = (int)pvVar5;
        piVar7[6] = 0;
        piVar7[5] = 0;
        piVar7[4] = 0;
        piVar7[-1] = 10;
        piVar7[-2] = 0x8601d;
        _NSShowAnimationEffect();
        *piVar7 = (int)sel_nextObject;
        piVar7[-1] = (int)pvVar4;
        piVar7[-2] = 0x86032;
        pvVar5 = _objc_msgSend((id)piVar7[-1],(SEL)*piVar7);
        piVar7 = piVar7 + -1;
      } while (pvVar5 != (id)0x0);
    }
  }
  pHVar3 = self->_items;
  piVar8[1] = (int)sel_selectedItems;
  *piVar8 = (int)pHVar3;
  piVar8[-1] = 0x86054;
  pvVar4 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  piVar8[1] = (int)sel_objectEnumerator;
  *piVar8 = (int)pvVar4;
  piVar8[-1] = 0x86066;
  pvVar4 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  piVar8[1] = (int)sel_nextObject;
  *piVar8 = (int)pvVar4;
  piVar8[-1] = 0x8607b;
  pvVar5 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  while (pvVar6 = self->_stack, pvVar5 != (id)0x0) {
    piVar8[1] = (int)sel_card;
    *piVar8 = (int)pvVar5;
    piVar8[-1] = 0x86091;
    pvVar5 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
    piVar8[2] = (int)&DAT_00365f48;
    piVar8[1] = (int)sel_queryHyperInterface_;
    *piVar8 = (int)pvVar5;
    piVar8[-1] = 0x860ad;
    pvVar5 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
    piVar8[2] = (int)pvVar5;
    piVar8[1] = (int)sel_removeHyperChild_;
    *piVar8 = (int)pvVar6;
    piVar8[-1] = 0x860c3;
    _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
    piVar8[1] = (int)sel_nextObject;
    *piVar8 = (int)pvVar4;
    piVar8[-1] = 0x860d8;
    pvVar5 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  }
  piVar8[1] = (int)sel_hyperCount;
  *piVar8 = (int)pvVar6;
  piVar8[-1] = 0x860f4;
  pvVar4 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  if (pvVar4 == (id)0x0) {
    pvVar4 = self->_stack;
    piVar8[1] = (int)sel_defaultObject;
    *piVar8 = (int)cls_HSCard;
    piVar8[-1] = 0x86116;
    pvVar5 = _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
    piVar8[2] = (int)pvVar5;
    piVar8[1] = (int)sel_addHyperChild_;
    *piVar8 = (int)pvVar4;
    piVar8[-1] = 0x8612c;
    _objc_msgSend((id)*piVar8,(SEL)piVar8[1]);
  }
  return;
}

*/
- (void)deleteSelectedCardsUsePoofAnimation:(BOOL)aAnimation
{
    if (aAnimation) {
        for (id item in [_items selectedItems]) {
            NSRect frame = [[self storyboardLayout] frameForItemAtIndex:[_items indexOfStoryboardItem:item]];
            NSPoint center = [self convertPoint:NSMakePoint(frame.size.width * 0.5 + frame.origin.x, frame.size.height * 0.5 + frame.origin.y) toView:nil];
            center = [[self window] convertPointToScreen:center];
            NSShowAnimationEffect(NSAnimationEffectPoof, center, NSZeroSize, nil, NULL, NULL);
        }
    }
    // Copy: removing cards updates the selection while we walk it.
    for (id item in [[[_items selectedItems] copy] autorelease]) {
        [_stack removeHyperChild:[[item card] queryHyperInterface:@protocol(HSNodeChild)]];
    }
    // A stack always keeps at least one card.
    if ([_stack hyperCount] == 0) {
        [_stack addHyperChild:[HSCard defaultObject]];
    }
}

- (void)setCardBorderRenderer:(id)aRenderer
{
    [[self storyboardCell] setCardBorderRenderer:aRenderer];
}

- (id)cardBorderRenderer
{
    return [[self storyboardCell] cardBorderRenderer];
}

- (void)setDelegate:(id)aDelegate
{
    if (_delegate != aDelegate) {
        _delegate = aDelegate;
    }
}

- (id)delegate
{
    return _delegate;
}

- (id)storyboardLayout
{
    id self_00;
    id pvVar1;
    HSStoryboardLayout *pHVar3;

    pHVar3 = _storyboardLayout;
    if (pHVar3 == nil) {
        self_00 = [HSStoryboardLayout alloc];
        pvVar1 = [self storyboardCell];
        pHVar3 = [self_00 initWithItems:[self items] cell:pvVar1 delegate:self];
        _storyboardLayout = pHVar3;
    }
    return pHVar3;
}

- (id)storyboardCell
{
    HSStoryboardCell *pHVar1;

    pHVar1 = _storyboardCell;
    if (pHVar1 == nil) {
        pHVar1 = [HSStoryboardCell new];
        _storyboardCell = pHVar1;
    }
    return pHVar1;
}

- (id)dragHelper
{
    HSEditorCardViewDragHelper *pHVar1;

    pHVar1 = _dragHelper;
    if (pHVar1 == nil) {
        pHVar1 = [[HSEditorCardViewDragHelper alloc] initWithDragHost:self];
        _dragHelper = pHVar1;
    }
    return pHVar1;
}

- (void)dealloc
{
    [_idleTimer invalidate];
    [_idleTimer release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_stack removeAttributeObserver:self];
    [_items unregisterForActionsAttributeChanges];
    [_items setParentView:nil];
    [_items release];
    [_stack release];
    [_backgroundColor release];
    [_presentationContext release];
    [_imageLoader cancelAllRequests];
    [_imageLoader release];
    [_storyboardCell setStoryboardLayout:nil];
    [_storyboardCell release];
    [_storyboardLayout release];
    [self unregisterDraggedTypes];
    [_readablePasteboardTypes release];
    [_dragHelper release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00082c51 @ 00082c51, 272 bytes * /

id FUN_00082c51(HSStoryboardView *self,SEL _cmd,NSRect initWithFrame)

{
  id self_00;
  id pvVar1;
  uint uVar2;
  HSStoryboardView *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_NSView_0034eaa0;
  self_00 = _objc_msgSendSuper(&local_1c,sel_initWithFrame_,initWithFrame.origin,initWithFrame.size)
  ;
  if (self_00 != (id)0x0) {
    pvVar1 = _objc_msgSend(self_00,sel_storyboardCell);
    uVar2 = (int)initWithFrame.size.width;
    if (2.1474836e+09 <= initWithFrame.size.width) {
      uVar2 = (int)(initWithFrame.size.width - 2.1474836e+09) ^ 0x80000000;
    }
    _objc_msgSend(pvVar1,sel_calcSizeWithBoundsWidth_,uVar2);
    pvVar1 = _objc_msgSend(self_00,sel_storyboardLayout);
    _objc_msgSend(pvVar1,sel_invalidateLayout);
    pvVar1 = _objc_msgSend(self_00,sel_readablePasteboardTypes);
    _objc_msgSend(self_00,sel_registerForDraggedTypes_,pvVar1);
    *(undefined1 *)((int)self_00 + 0x95) = 1;
    *(undefined1 *)((int)self_00 + 0x94) = 1;
    *(undefined1 *)((int)self_00 + 0x96) = 1;
  }
  return self_00;
}

*/
- (id)initWithFrame:(NSRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self != nil) {
        [[self storyboardCell] calcSizeWithBoundsWidth:(unsigned int)aFrame.size.width];
        [[self storyboardLayout] invalidateLayout];
        [self registerForDraggedTypes:[self readablePasteboardTypes]];
        _allowEmptySelection = YES;
        _allowDragAndDrop = YES;
        _allowMultipleSelection = YES;
    }
    return self;
}

- (id)readablePasteboardTypes
{
    id pvVar1;

    pvVar1 = _readablePasteboardTypes;
    if (pvVar1 == nil) {
        pvVar1 = [[[NSArray arrayWithObjects:@"HSCardPasteboardType", NSFilenamesPboardType, NSURLPboardType, nil] arrayByAddingObjectsFromArray:[NSImage imagePasteboardTypes]] retain];
        _readablePasteboardTypes = pvVar1;
    }
    return pvVar1;
}

- (BOOL)isModifingStack
{
    return _modifingStack;
}

- (void)endModifingStack
{
    _modifingStack = NO;
    [[self items] synchronizeWithStack];
    [self setNeedsDisplay:YES];
}

- (void)beginModifingStack
{
    _modifingStack = YES;
}

@end

