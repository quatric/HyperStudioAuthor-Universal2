#import "HSEditorRootCanvasLayer.h"

@implementation HSEditorRootCanvasLayer

+ (id)arrowToolIdentifiers
{
    return [NSSet setWithObjects:@"HSArrowToolCanvasLayer", @"HSRuntimeEditorCanvasLayer", nil];
}

+ (id)supportedIdentifiers
{
    return [NSArray arrayWithObjects:@"HSBitmapToolsCanvasLayer", @"HSVectorToolsCanvasLayer", @"HSBitmapToolsSelectionCanvasLayer", @"HSArrowToolCanvasLayer", @"HSRuntimeEditorCanvasLayer", @"HSOnionSkinPreviousCanvasLayerIdentifier", @"HSOnionSkinNextCanvasLayerIdentifier", nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bfbf9 @ 000bfbf9, 122 bytes * /

void FUN_000bfbf9(HSEditorRootCanvasLayer *self,SEL _cmd,NSRect renderTopLayersInRect)

{
  id pvVar1;
  id pvVar2;
  int extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_rangeOfBottomLayers);
  pvVar1 = (id)(extraout_EDX + (int)pvVar1);
  pvVar2 = _objc_msgSend(self,sel_numberOfSublayers);
  if (pvVar2 != pvVar1) {
    _objc_msgSend(self,sel_renderSublayersInRange_inRect_,pvVar1,(int)pvVar2 - (int)pvVar1,
                  renderTopLayersInRect.origin,renderTopLayersInRect.size);
  }
  return;
}

*/
- (void)renderTopLayersInRect:(NSRect)aRect
{
    NSRange bottom = [self rangeOfBottomLayers];
    NSUInteger start = bottom.location + bottom.length;
    NSUInteger count = [self numberOfSublayers];
    if (count != start) {
        [self renderSublayersInRange:NSMakeRange(start, count - start) inRect:aRect];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bfb99 @ 000bfb99, 96 bytes * /

void FUN_000bfb99(HSEditorRootCanvasLayer *self,SEL _cmd,NSRect renderBitmapToolsLayerInRect)

{
  id pvVar1;
  int extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_rangeOfBottomLayers);
  if (extraout_EDX != 0) {
    _objc_msgSend(self,sel_renderSublayersInRange_inRect_,pvVar1,extraout_EDX,
                  renderBitmapToolsLayerInRect.origin,renderBitmapToolsLayerInRect.size);
  }
  return;
}

*/
- (void)renderBitmapToolsLayerInRect:(NSRect)aRect
{
    NSRange bottom = [self rangeOfBottomLayers];
    if (bottom.length != 0) {
        [self renderSublayersInRange:bottom inRect:aRect];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bfb1d @ 000bfb1d, 124 bytes * /

ulonglong FUN_000bfb1d(HSEditorRootCanvasLayer *self,SEL _cmd)

{
  id pvVar1;
  uint uVar2;
  
  pvVar1 = _objc_msgSend(self,sel_isEnabledSublayerForIdentifier_,
                         PTR_cfstr_HSBitmapToolsCanvasLayer_003424b4);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_sublayerForIdentifier_,
                           PTR_cfstr_HSBitmapToolsCanvasLayer_003424b4);
    pvVar1 = _objc_msgSend(self,sel_indexOfSublayer_,pvVar1);
    if (pvVar1 != (id)0x7fffffff) {
      uVar2 = (int)pvVar1 + 1;
      goto LAB_000bfb92;
    }
  }
  uVar2 = 0;
LAB_000bfb92:
  return (ulonglong)uVar2 << 0x20;
}

*/
- (NSRange)rangeOfBottomLayers
{
    if ([self isEnabledSublayerForIdentifier:@"HSBitmapToolsCanvasLayer"]) {
        NSUInteger index = [self indexOfSublayer:[self sublayerForIdentifier:@"HSBitmapToolsCanvasLayer"]];
        if (index != NSNotFound) {
            return NSMakeRange(0, index + 1);
        }
    }
    return NSMakeRange(0, 0);
    return (NSRange){0};
}

- (void)setRepresentedObject:(id)aObject
{
    [self setCard:aObject];
}

- (void)setCard:(id)aCard
{
    [super setRepresentedObject:aCard];
}

- (id)card
{
    return [self representedObject];
}

- (id)arrowToolIdentifiers
{
    return [[self class] arrowToolIdentifiers];
}

- (id)vectorToolsIdentifiers
{
    id self_00;

    self_00 = [NSMutableSet setWithObject:@"HSVectorToolsCanvasLayer"];
    if ([self isEnabledOnionSkinPreviousCanvasLayer]) {
        [self_00 addObject:@"HSOnionSkinPreviousCanvasLayerIdentifier"];
    }
    if ([self isEnabledOnionSkinNextCanvasLayer]) {
        [self_00 addObject:@"HSOnionSkinNextCanvasLayerIdentifier"];
    }
    return self_00;
}

- (id)bitmapToolsIdentifiers
{
    id self_00;

    self_00 = [NSMutableSet setWithObject:@"HSBitmapToolsCanvasLayer"];
    if ([self isEnabledOnionSkinPreviousCanvasLayer]) {
        [self_00 addObject:@"HSOnionSkinPreviousCanvasLayerIdentifier"];
    }
    if ([self isEnabledOnionSkinNextCanvasLayer]) {
        [self_00 addObject:@"HSOnionSkinNextCanvasLayerIdentifier"];
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bf74d @ 000bf74d, 507 bytes * /

void FUN_000bf74d(HSEditorRootCanvasLayer *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_01;
  id pvVar4;
  id pvVar5;
  bool bVar6;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_isEnabledOnionSkinPreviousCanvasLayer);
  if (((char)pvVar1 != '\0') ||
     (pvVar1 = _objc_msgSend(self,sel_isEnabledOnionSkinNextCanvasLayer), (char)pvVar1 != '\0')) {
    pvVar2 = _objc_msgSend(self,sel_sublayerForIdentifier_,
                           PTR_cfstr_HSOnionSkinPreviousCanvasLayerIdentifier_003424bc);
    pvVar3 = _objc_msgSend(self,sel_sublayerForIdentifier_,
                           PTR_cfstr_HSOnionSkinNextCanvasLayerIdentifier_003424b8);
    self_00 = cls_NSMutableArray;
    pvVar1 = _objc_msgSend(self,sel_allSublayers);
    self_01 = _objc_msgSend(self_00,sel_arrayWithArray_,pvVar1);
    pvVar4 = _objc_msgSend(self_01,sel_count);
    local_14 = (id)((int)pvVar4 + -1);
    if ((pvVar3 == (id)0x0) ||
       (pvVar5 = _objc_msgSend(self,sel_isEnabledOnionSkinNextCanvasLayer,pvVar1),
       (char)pvVar5 == '\0')) {
      bVar6 = false;
    }
    else {
      pvVar1 = pvVar3;
      pvVar5 = _objc_msgSend(self_01,sel_indexOfObject_,pvVar3);
      bVar6 = pvVar5 != local_14;
      if (bVar6) {
        _objc_msgSend(self_01,sel_removeObjectAtIndex_,pvVar5);
        _objc_msgSend(self_01,sel_insertObject_atIndex_,pvVar3,local_14);
        pvVar1 = pvVar3;
      }
      local_14 = (id)((int)pvVar4 + -2);
    }
    if (((pvVar2 == (id)0x0) ||
        (pvVar1 = _objc_msgSend(self,sel_isEnabledOnionSkinPreviousCanvasLayer,pvVar1),
        (char)pvVar1 == '\0')) ||
       (pvVar1 = _objc_msgSend(self_01,sel_indexOfObject_,pvVar2), pvVar1 == local_14)) {
      if (!bVar6) {
        return;
      }
    }
    else {
      _objc_msgSend(self_01,sel_removeObjectAtIndex_,pvVar1);
      _objc_msgSend(self_01,sel_insertObject_atIndex_,pvVar2,local_14);
    }
    _objc_msgSend(self,sel_setReorderedSublayers_,self_01);
  }
  return;
}

*/
- (void)fixOnionSkinCanvasLayerIfNeeded
{
    if ([self isEnabledOnionSkinPreviousCanvasLayer] || [self isEnabledOnionSkinNextCanvasLayer]) {
        id previous = [self sublayerForIdentifier:@"HSOnionSkinPreviousCanvasLayerIdentifier"];
        id next = [self sublayerForIdentifier:@"HSOnionSkinNextCanvasLayerIdentifier"];
        NSMutableArray *layers = [NSMutableArray arrayWithArray:[self allSublayers]];
        NSUInteger count = [layers count];
        NSUInteger last = count - 1;
        BOOL changed = NO;
        if (next != nil && [self isEnabledOnionSkinNextCanvasLayer]) {
            NSUInteger index = [layers indexOfObject:next];
            changed = index != last;
            if (changed) {
                [layers removeObjectAtIndex:index];
                [layers insertObject:next atIndex:last];
            }
            last = count - 2;
        }
        NSUInteger previousIndex;
        if (previous != nil && [self isEnabledOnionSkinPreviousCanvasLayer] && (previousIndex = [layers indexOfObject:previous]) != last) {
            [layers removeObjectAtIndex:previousIndex];
            [layers insertObject:previous atIndex:last];
        } else if (!changed) {
            return;
        }
        [self setReorderedSublayers:layers];
    }
}

- (BOOL)isEnabledOnionSkinNextCanvasLayer
{
    return (BOOL)[self isEnabledSublayerForIdentifier:@"HSOnionSkinNextCanvasLayerIdentifier"];
}

- (BOOL)isEnabledOnionSkinPreviousCanvasLayer
{
    return (BOOL)[self isEnabledSublayerForIdentifier:@"HSOnionSkinPreviousCanvasLayerIdentifier"];
}

- (id)enabledArrowToolCanvasLayer
{
    return [self enabledSublayerForIdentifier:@"HSArrowToolCanvasLayer"];
}

- (id)runtimeEditorCanvasLayer
{
    return [self sublayerForIdentifier:@"HSRuntimeEditorCanvasLayer"];
}

- (id)arrowToolCanvasLayer
{
    return [self sublayerForIdentifier:@"HSArrowToolCanvasLayer"];
}

- (id)vectorToolsCanvasLayer
{
    return [self sublayerForIdentifier:@"HSVectorToolsCanvasLayer"];
}

- (id)bitmapToolsSelectionCanvasLayer
{
    return [self sublayerForIdentifier:@"HSBitmapToolsSelectionCanvasLayer"];
}

- (id)bitmapToolsCanvasLayer
{
    return [self sublayerForIdentifier:@"HSBitmapToolsCanvasLayer"];
}

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    id pvVar1_3;

    pvVar1_3 = [super initWithSupportedIdentifiers:[[self class] supportedIdentifiers] enabledIdentifiers:nil sublayerFactory:nil];
    if (pvVar1_3 != nil) {
        [pvVar1_3 setDefaultSublayerIdentifiers:[[pvVar1_3 class] arrowToolIdentifiers]];
    }
    return pvVar1_3;
}

- (id)initWithSupportedIdentifiers:(id)aIdentifiers enabledIdentifiers:(id)aIdentifiers2 sublayerFactory:(id)aFactory
{
    return nil;
}

- (id)sublayerFactory
{
    Class pvVar8;
    Class pvVar9;
    Class pvVar10;
    Class pvVar11;
    Class pvVar12;
    Class pvVar13;
    id pvVar8_2;

    pvVar8 = [HSOnionSkinCanvasLayer class];
    pvVar9 = [HSOnionSkinCanvasLayer class];
    pvVar10 = [HSCompositeCanvasLayer class];
    pvVar11 = [HSArrowToolCanvasLayer class];
    pvVar12 = [HSToolCanvasLayer class];
    pvVar13 = [HSCompositeCanvasLayer class];
    pvVar8_2 = [NSDictionary dictionaryWithObjectsAndKeys:[HSToolCanvasLayer class], @"HSBitmapToolsCanvasLayer", pvVar13, @"HSBitmapToolsSelectionCanvasLayer", pvVar12, @"HSVectorToolsCanvasLayer", pvVar11, @"HSArrowToolCanvasLayer", pvVar10, @"HSRuntimeEditorCanvasLayer", pvVar9, @"HSOnionSkinPreviousCanvasLayerIdentifier", pvVar8, @"HSOnionSkinNextCanvasLayerIdentifier", nil]
    ;
    return pvVar8_2;
}

@end

