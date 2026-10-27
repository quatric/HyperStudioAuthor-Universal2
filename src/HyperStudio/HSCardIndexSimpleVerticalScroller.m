#import "HSCardIndexSimpleVerticalScroller.h"

@implementation HSCardIndexVerticalScroller

/* i386 ivar offsets: _imagesHighlighted=0x78, _imagesSimple=0x7c */

- (id)imageNameForExtraPart:(NSInteger)aPart
{
    id pcVar1;
    BOOL pvVar2;

    switch(aPart) {
        case 0:
        pvVar2 = [self arrowsTogether];
        pcVar1 = @"topArrowAtBottom";
        if (!pvVar2) {
            pcVar1 = @"topArrowAtTop";
        }
        break;
        case 1:
        pcVar1 = @"bottomArrowSingle";
        break;
        case 2:
        pcVar1 = @"slot";
        break;
        case 3:
        pcVar1 = @"topShadow";
        break;
        case 4:
        pcVar1 = @"bottomShadow";
        break;
        case 5:
        pcVar1 = @"topPage";
        break;
        case 6:
        pcVar1 = @"bottomPage";
        break;
        case 7:
        pcVar1 = @"knobCenter";
        break;
        case 8:
        pcVar1 = @"knobTop";
        break;
        case 9:
        pcVar1 = @"knobBottom";
        break;
        case 10:
        pcVar1 = @"cup";
        break;
        default:
        pcVar1 = NULL;
    }
    return pcVar1;
}

- (id)imagesSimple
{
    id pvVar1;

    pvVar1 = _imagesSimple;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
        _imagesSimple = pvVar1;
    }
    return pvVar1;
}

- (id)imagesHighlighted
{
    id pvVar1;

    pvVar1 = _imagesHighlighted;
    if (pvVar1 == nil) {
        pvVar1 = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
        _imagesHighlighted = pvVar1;
    }
    return pvVar1;
}

- (id)imageNamed:(id)aNamed highlighted:(BOOL)aHighlighted
{
    return [NSImage imageNamed:aNamed];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0022724f @ 0022724f, 215 bytes * /

BOOL FUN_0022724f(HSCardIndexVerticalScroller *self,SEL _cmd,int shouldDrawPart)

{
  char cVar1;
  id pvVar2;
  undefined8 local_1c;
  undefined8 local_14;
  
  if (shouldDrawPart == 10) {
    pvVar2 = _objc_msgSend(self,sel_arrowsTogether);
    if ((char)pvVar2 != '\0') {
      _objc_msgSend_stret(&local_1c,self,sel_rectForPart_,5);
      cVar1 = _NSEqualRects(local_1c,local_14,*(undefined8 *)PTR_00336078,
                            *(undefined8 *)(PTR_00336078 + 8));
      return cVar1 == '\0';
    }
  }
  else if (1 < shouldDrawPart - 3U) {
    if ((uint)shouldDrawPart < 2) {
      pvVar2 = _objc_msgSend(self,sel_arrowsPosition);
      return pvVar2 != (id)0x2;
    }
    return '\x01';
  }
  return '\0';
}

*/
- (BOOL)shouldDrawPart:(NSInteger)aPart
{
    if (aPart == 10) {
        if ([self arrowsTogether]) {
            return !NSEqualRects([self rectForPart:5], NSZeroRect);
        }
    } else if (1 < (NSUInteger)aPart - 3U) {
        if ((NSUInteger)aPart < 2) {
            return [self arrowsPosition] != 2;
        }
        return YES;
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00226eee @ 00226eee, 251 bytes * /

BOOL FUN_00226eee(HSCardIndexVerticalScroller *self,SEL _cmd,int isPartHighlighted)

{
  id pvVar1;
  
  switch(isPartHighlighted) {
  case 0:
    pvVar1 = _objc_msgSend(self,sel_hitPart);
    return pvVar1 == (id)0x4;
  case 1:
    pvVar1 = _objc_msgSend(self,sel_hitPart);
    return pvVar1 == (id)0x5;
  case 5:
    pvVar1 = _objc_msgSend(self,sel_hitPart);
    if (pvVar1 == (id)0x4) {
      pvVar1 = _objc_msgSend(self,sel_arrowsTogether);
      return (char)pvVar1 == '\0';
    }
    break;
  case 6:
    pvVar1 = _objc_msgSend(self,sel_hitPart);
    if ((pvVar1 == (id)0x5) &&
       (pvVar1 = _objc_msgSend(self,sel_arrowsTogether), (char)pvVar1 == '\0')) {
      return '\x01';
    }
    pvVar1 = _objc_msgSend(self,sel_hitPart);
    if (pvVar1 == (id)0x4) {
      pvVar1 = _objc_msgSend(self,sel_arrowsTogether);
      return (char)pvVar1 != '\0';
    }
    break;
  case 7:
  case 8:
  case 9:
    return '\x01';
  }
  return '\0';
}

*/
- (BOOL)isPartHighlighted:(NSInteger)aHighlighted
{
    switch (aHighlighted) {
        case 0:
        return [self hitPart] == 4;
        case 1:
        return [self hitPart] == 5;
        case 5:
        if ([self hitPart] == 4) {
            return ![self arrowsTogether];
        }
        break;
        case 6:
        if ([self hitPart] == 5 && ![self arrowsTogether]) {
            return YES;
        }
        if ([self hitPart] == 4) {
            return [self arrowsTogether];
        }
        break;
        case 7:
        case 8:
        case 9:
        return YES;
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00227326 @ 00227326, 435 bytes * /

void FUN_00227326(HSCardIndexVerticalScroller *self,SEL _cmd,int drawExtraPart,BOOL highlighted)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  undefined8 local_24;
  undefined8 local_1c;
  
  _objc_msgSend_stret(&local_24,self,sel_rectForExtraPart_,drawExtraPart);
  puVar1 = PTR_00336078;
  cVar2 = _NSEqualRects(local_24,local_1c,*(undefined8 *)PTR_00336078,
                        *(undefined8 *)(PTR_00336078 + 8));
  if (cVar2 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_imageNameForExtraPart_,drawExtraPart);
    pvVar3 = _objc_msgSend(self,sel_imageNamed_highlighted_,pvVar3,(uint)(byte)highlighted);
    pvVar4 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    _objc_msgSend(pvVar4,sel_saveGraphicsState);
    pvVar4 = _objc_msgSend(self,sel_isFlipped);
    if ((char)pvVar4 != '\0') {
      pvVar4 = _objc_msgSend(cls_NSAffineTransform,sel_hyperYFlipInRect_,local_24,local_1c);
      _objc_msgSend(pvVar4,sel_concat);
    }
    _objc_msgSend(pvVar3,sel_drawInRect_fromRect_operation_fraction_,local_24,local_1c,
                  *(undefined8 *)puVar1,*(undefined8 *)(puVar1 + 8),2,0x3f800000);
    pvVar3 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
    _objc_msgSend(pvVar3,sel_restoreGraphicsState);
  }
  return;
}

*/
- (void)drawExtraPart:(NSInteger)aPart highlighted:(BOOL)aHighlighted
{
    NSRect rect = [self rectForExtraPart:aPart];
    if (!NSEqualRects(rect, NSZeroRect)) {
        NSImage *image = [self imageNamed:[self imageNameForExtraPart:aPart] highlighted:aHighlighted];
        [[NSGraphicsContext currentContext] saveGraphicsState];
        if ([self isFlipped]) {
            [[NSAffineTransform hyperYFlipInRect:rect] concat];
        }
        [image drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
        [[NSGraphicsContext currentContext] restoreGraphicsState];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002274d9 @ 002274d9, 104 bytes * /

BOOL FUN_002274d9(HSCardIndexVerticalScroller *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  undefined1 local_1c [4];
  float local_18;
  
  pvVar2 = _objc_msgSend(self,sel_arrowsPosition);
  if (pvVar2 == (id)0x0) {
    _objc_msgSend_stret(local_1c,self,sel_rectForPart_,6);
    bVar1 = local_18 < 10.0;
  }
  else {
    bVar1 = false;
  }
  return bVar1;
}

*/
- (BOOL)arrowsTogether
{
    if ([self arrowsPosition] == 0) {
        return [self rectForPart:6].origin.y < 10.0f;
    }
    return NO;
}

- (id)simpleSubfolder
{
    return @"VerticalScroller/Simple";
}

- (id)highlightedSubfolder
{
    return @"VerticalScroller/Highlighted";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00227541 @ 00227541, 1316 bytes * /

NSRect * FUN_00227541(NSRect *__return_storage_ptr__,HSCardIndexVerticalScroller *self,SEL _cmd,
                     int rectForExtraPart)

{
  float fVar1;
  float fVar2;
  undefined *puVar3;
  char cVar4;
  id pvVar5;
  float local_e4;
  float local_e0;
  float local_dc;
  float local_d8;
  float local_d4;
  float local_d0;
  float local_cc;
  float local_c8;
  float local_c4;
  float local_c0;
  float local_bc;
  float local_b4;
  float local_b0;
  float local_ac;
  undefined4 local_a8;
  float local_a4;
  float local_a0;
  float local_9c;
  float local_98;
  float local_94;
  float local_90;
  float local_8c;
  float local_84;
  float local_80;
  float local_7c;
  float local_78;
  float local_74;
  float local_70;
  float local_6c;
  float local_68;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  float local_54;
  float local_50;
  float local_4c;
  float local_48;
  undefined1 local_44 [4];
  float local_40;
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  puVar3 = PTR_00336078;
  local_54 = *(float *)PTR_00336078;
  local_50 = *(float *)(PTR_00336078 + 4);
  fVar1 = *(float *)(PTR_00336078 + 8);
  fVar2 = *(float *)(PTR_00336078 + 0xc);
  local_4c = fVar1;
  local_48 = fVar2;
  switch(rectForExtraPart) {
  case 0:
    _objc_msgSend_stret(&local_34,self,sel_rectForPart_,4);
    cVar4 = _NSEqualRects(local_34,local_2c,*(undefined8 *)puVar3,*(undefined8 *)(puVar3 + 8));
    if (cVar4 != '\0') break;
    pvVar5 = _objc_msgSend(self,sel_arrowsTogether);
    if ((char)pvVar5 == '\0') {
      _objc_msgSend_stret(&local_c4,self,sel_bounds);
      local_54 = local_c4;
      local_50 = local_c0;
      local_4c = local_bc;
    }
    else {
      _objc_msgSend_stret(&local_d4,self,sel_bounds);
      local_54 = local_d4;
      local_4c = local_cc;
      local_50 = local_d0 + local_c8 + -32.0;
    }
    goto LAB_00227a27;
  case 1:
    _objc_msgSend_stret(&local_24,self,sel_rectForPart_,5);
    cVar4 = _NSEqualRects(local_24,local_1c,*(undefined8 *)puVar3,*(undefined8 *)(puVar3 + 8));
    if (cVar4 != '\0') break;
    _objc_msgSend_stret(&local_e4,self,sel_bounds);
    local_54 = local_e4;
    local_4c = local_dc;
    local_50 = local_e0 + local_d8 + -16.0;
LAB_00227a27:
    local_48 = 16.0;
    break;
  case 2:
    _objc_msgSend_stret(&local_84,self,sel_rectForPart_,6);
    local_54 = local_84;
    local_50 = local_80;
    local_4c = local_7c;
    local_48 = local_78;
    break;
  case 3:
  case 5:
    _objc_msgSend_stret(&local_94,self,sel_rectForPart_,6);
    local_54 = local_94;
    local_50 = local_90;
    local_4c = local_8c;
    local_48 = 10.0;
    break;
  case 4:
  case 6:
    _objc_msgSend_stret(&local_a4,self,sel_rectForPart_,6);
    local_54 = local_a4;
    local_4c = local_9c;
    local_60 = local_a0;
    local_58 = local_98;
    goto LAB_0022761c;
  case 7:
    _objc_msgSend_stret(&local_74,self,sel_rectForPart_,2);
    local_54 = local_74;
    local_4c = local_6c;
    local_50 = local_70 + 10.0;
    local_48 = local_68 + -20.0;
    break;
  case 8:
    _objc_msgSend_stret(&local_54,self,sel_rectForPart_,2);
    local_48 = 10.0;
    break;
  case 9:
    _objc_msgSend_stret(&local_64,self,sel_rectForPart_,2);
    local_54 = local_64;
    local_4c = local_5c;
LAB_0022761c:
    local_50 = local_58 + -10.0 + local_60;
    local_48 = 10.0;
    break;
  case 10:
    _objc_msgSend_stret(&local_b4,self,sel_rectForPart_,0);
    local_54 = local_b4;
    local_50 = local_b0;
    local_4c = local_ac;
    local_48 = (float)local_a8;
    _objc_msgSend_stret(local_44,self,sel_rectForPart_);
    local_48 = local_40 - local_50;
    if ((local_48 == 0.0) && (!NAN(local_48))) {
      local_54 = *(float *)puVar3;
      local_50 = *(float *)(puVar3 + 4);
      local_4c = fVar1;
      local_48 = fVar2;
    }
  }
  (__return_storage_ptr__->origin).x = local_54;
  (__return_storage_ptr__->origin).y = local_50;
  (__return_storage_ptr__->size).width = local_4c;
  (__return_storage_ptr__->size).height = local_48;
  return __return_storage_ptr__;
}

*/
- (NSRect)rectForExtraPart:(NSInteger)aPart
{
    NSRect result = NSZeroRect;
    NSRect rect;
    switch (aPart) {
        case 0:
        if (NSEqualRects([self rectForPart:4], NSZeroRect)) {
            break;
        }
        rect = [self bounds];
        result.origin.x = rect.origin.x;
        result.size.width = rect.size.width;
        if ([self arrowsTogether]) {
            result.origin.y = rect.origin.y + rect.size.height - 32.0f;
        } else {
            result.origin.y = rect.origin.y;
        }
        result.size.height = 16.0f;
        break;
        case 1:
        if (NSEqualRects([self rectForPart:5], NSZeroRect)) {
            break;
        }
        rect = [self bounds];
        result.origin.x = rect.origin.x;
        result.size.width = rect.size.width;
        result.origin.y = rect.origin.y + rect.size.height - 16.0f;
        result.size.height = 16.0f;
        break;
        case 2:
        result = [self rectForPart:6];
        break;
        case 3:
        case 5:
        result = [self rectForPart:6];
        result.size.height = 10.0f;
        break;
        case 4:
        case 6:
        rect = [self rectForPart:6];
        result.origin.x = rect.origin.x;
        result.size.width = rect.size.width;
        result.origin.y = rect.size.height - 10.0f + rect.origin.y;
        result.size.height = 10.0f;
        break;
        case 7:
        rect = [self rectForPart:2];
        result.origin.x = rect.origin.x;
        result.size.width = rect.size.width;
        result.origin.y = rect.origin.y + 10.0f;
        result.size.height = rect.size.height - 20.0f;
        break;
        case 8:
        result = [self rectForPart:2];
        result.size.height = 10.0f;
        break;
        case 9:
        rect = [self rectForPart:2];
        result.origin.x = rect.origin.x;
        result.size.width = rect.size.width;
        result.origin.y = rect.size.height - 10.0f + rect.origin.y;
        result.size.height = 10.0f;
        break;
        case 10:
        result = [self rectForPart:0];
        result.size.height = [self rectForPart:6].origin.y - result.origin.y;
        if (result.size.height == 0.0f) {
            result = NSZeroRect;
        }
        break;
    }
    return result;
}

- (void)drawRect:(NSRect)aRect
{
    int iVar2;

    iVar2 = 0;
    do {
        if ([self shouldDrawPart:iVar2]) {
            [self drawExtraPart:iVar2 highlighted:[self isPartHighlighted:iVar2]];
        }
        iVar2 = iVar2 + 1;
    } while (iVar2 != 0xb);
}

- (BOOL)isOpaque
{
    return NO;
}

- (id)initWithScrollView:(id)aView
{
    id pvVar1;
    id self_01;
    id self_02;
    id pvVar2_2;

    self = [super init];
    pvVar1 = nil;
    if (self != nil) {
        pvVar1 = [NSMutableData alloc];
        self_01 = [pvVar1 initWithCapacity:0];
        pvVar1 = [NSKeyedArchiver alloc];
        self_02 = [pvVar1 initForWritingWithMutableData:self_01];
        pvVar1 = [NSScroller class];
        [self_02 setClassName:(NSStringFromClass([self class])) forClass:pvVar1];
        pvVar1 = [aView verticalScroller];
        [pvVar1 encodeWithCoder:self_02];
        [self_02 finishEncoding];
        pvVar1 = [NSKeyedUnarchiver alloc];
        pvVar2_2 = [pvVar1 initForReadingWithData:self_01];
        [self autorelease];
        pvVar1 = [[[self class] alloc] initWithCoder:pvVar2_2];
        [self_02 release];
        [pvVar2_2 release];
        [self_01 release];
        [pvVar1 setArrowsPosition:2];
    }
    return pvVar1;
}

- (id)init
{
    return [self initWithScrollView:nil];
}

- (void)invalidateColors
{
    [_imagesHighlighted release];
    _imagesHighlighted = nil;
}

- (void)dealloc
{
    [_imagesHighlighted release];
    [_imagesSimple release];
    [super dealloc];
}

@end

@implementation HSCardIndexSimpleVerticalScroller

/* --- i386 decompilation (Ghidra) ---
/* FUN_00228444 @ 00228444, 156 bytes * /

NSRect * FUN_00228444(NSRect *__return_storage_ptr__,HSCardIndexSimpleVerticalScroller *self,
                     SEL _cmd,int rectForExtraPart)

{
  HSCardIndexSimpleVerticalScroller *local_24;
  undefined *local_20;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  local_24 = self;
  local_20 = PTR_s_HSCardIndexVerticalScroller_003550a0;
  _objc_msgSendSuper_stret(&local_1c,&local_24,sel_rectForExtraPart_,rectForExtraPart);
  if (rectForExtraPart == 2) {
    local_18 = local_18 + 10.0;
    local_10 = local_10 + -20.0;
  }
  (__return_storage_ptr__->origin).x = local_1c;
  (__return_storage_ptr__->origin).y = local_18;
  (__return_storage_ptr__->size).width = local_14;
  (__return_storage_ptr__->size).height = local_10;
  return __return_storage_ptr__;
}

*/
- (NSRect)rectForExtraPart:(NSInteger)aPart
{
    NSRect rect = [super rectForExtraPart:aPart];
    if (aPart == 2) {
        rect.origin.y = rect.origin.y + 10.0f;
        rect.size.height = rect.size.height - 20.0f;
    }
    return rect;
}

@end

@implementation HSCardIndexHorizontalScroller

/* --- i386 decompilation (Ghidra) ---
/* FUN_00227e8f @ 00227e8f, 104 bytes * /

BOOL FUN_00227e8f(HSCardIndexHorizontalScroller *self,SEL _cmd)

{
  bool bVar1;
  id pvVar2;
  float local_1c [4];
  
  pvVar2 = _objc_msgSend(self,sel_arrowsPosition);
  if (pvVar2 == (id)0x0) {
    _objc_msgSend_stret(local_1c,self,sel_rectForPart_,6);
    bVar1 = local_1c[0] < 10.0;
  }
  else {
    bVar1 = false;
  }
  return bVar1;
}

*/
- (BOOL)arrowsTogether
{
    if ([self arrowsPosition] == 0) {
        return [self rectForPart:6].origin.x < 10.0f;
    }
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00227ef7 @ 00227ef7, 1311 bytes * /

NSRect * FUN_00227ef7(NSRect *__return_storage_ptr__,HSCardIndexHorizontalScroller *self,SEL _cmd,
                     int rectForExtraPart)

{
  float fVar1;
  float fVar2;
  undefined *puVar3;
  char cVar4;
  id pvVar5;
  float local_e4;
  float local_e0;
  float local_dc;
  float local_d8;
  float local_d4;
  float local_d0;
  float local_cc;
  float local_c8;
  float local_c4;
  float local_c0;
  float local_b8;
  float local_b4;
  float local_b0;
  undefined4 local_ac;
  float local_a8;
  float local_a4;
  float local_a0;
  float local_9c;
  float local_98;
  float local_94;
  float local_90;
  float local_88;
  float local_84;
  float local_80;
  float local_7c;
  float local_78;
  float local_74;
  float local_70;
  float local_6c;
  float local_68;
  float local_64;
  float local_60;
  float local_5c;
  float local_58;
  float local_54;
  float local_50;
  float local_4c;
  float local_48;
  float local_44 [4];
  undefined8 local_34;
  undefined8 local_2c;
  undefined8 local_24;
  undefined8 local_1c;
  
  puVar3 = PTR_00336078;
  local_54 = *(float *)PTR_00336078;
  local_50 = *(float *)(PTR_00336078 + 4);
  fVar1 = *(float *)(PTR_00336078 + 8);
  fVar2 = *(float *)(PTR_00336078 + 0xc);
  local_4c = fVar1;
  local_48 = fVar2;
  switch(rectForExtraPart) {
  case 0:
    _objc_msgSend_stret(&local_34,self,sel_rectForPart_,4);
    cVar4 = _NSEqualRects(local_34,local_2c,*(undefined8 *)puVar3,*(undefined8 *)(puVar3 + 8));
    if (cVar4 != '\0') break;
    pvVar5 = _objc_msgSend(self,sel_arrowsTogether);
    if ((char)pvVar5 == '\0') {
      _objc_msgSend_stret(&local_c4,self,sel_bounds);
      local_54 = local_c4;
      local_50 = local_c0;
      local_48 = local_b8;
    }
    else {
      _objc_msgSend_stret(&local_d4,self,sel_bounds);
      local_50 = local_d0;
      local_48 = local_c8;
      local_54 = local_d4 + local_cc + -32.0;
    }
    goto LAB_002283d8;
  case 1:
    _objc_msgSend_stret(&local_24,self,sel_rectForPart_,5);
    cVar4 = _NSEqualRects(local_24,local_1c,*(undefined8 *)puVar3,*(undefined8 *)(puVar3 + 8));
    if (cVar4 != '\0') break;
    _objc_msgSend_stret(&local_e4,self,sel_bounds);
    local_50 = local_e0;
    local_48 = local_d8;
    local_54 = local_e4 + local_dc + -16.0;
LAB_002283d8:
    local_4c = 16.0;
    break;
  case 2:
    _objc_msgSend_stret(&local_84,self,sel_rectForPart_,6);
    local_54 = local_84;
    local_50 = local_80;
    local_4c = local_7c;
    local_48 = local_78;
    break;
  case 3:
  case 5:
    _objc_msgSend_stret(&local_94,self,sel_rectForPart_,6);
    local_54 = local_94;
    local_50 = local_90;
    local_48 = local_88;
    local_4c = 10.0;
    break;
  case 4:
  case 6:
    _objc_msgSend_stret(&local_a4,self,sel_rectForPart_,6);
    local_50 = local_a0;
    local_58 = local_98;
    local_64 = local_a4;
    local_5c = local_9c;
    goto LAB_00227fcd;
  case 7:
    _objc_msgSend_stret(&local_74,self,sel_rectForPart_,2);
    local_50 = local_70;
    local_48 = local_68;
    local_54 = local_74 + 10.0;
    local_4c = local_6c + -20.0;
    break;
  case 8:
    _objc_msgSend_stret(&local_54,self,sel_rectForPart_,2);
    local_4c = 10.0;
    break;
  case 9:
    _objc_msgSend_stret(&local_64,self,sel_rectForPart_,2);
    local_50 = local_60;
LAB_00227fcd:
    local_54 = local_5c + -10.0 + local_64;
    local_4c = 10.0;
    local_48 = local_58;
    break;
  case 10:
    _objc_msgSend_stret(&local_b4,self,sel_rectForPart_,0);
    local_54 = local_b4;
    local_50 = local_b0;
    local_4c = (float)local_ac;
    local_48 = local_a8;
    _objc_msgSend_stret(local_44,self,sel_rectForPart_);
    local_4c = local_44[0] - local_54;
    if ((local_4c == 0.0) && (!NAN(local_4c))) {
      local_54 = *(float *)puVar3;
      local_50 = *(float *)(puVar3 + 4);
      local_4c = fVar1;
      local_48 = fVar2;
    }
  }
  (__return_storage_ptr__->origin).x = local_54;
  (__return_storage_ptr__->origin).y = local_50;
  (__return_storage_ptr__->size).width = local_4c;
  (__return_storage_ptr__->size).height = local_48;
  return __return_storage_ptr__;
}

*/
- (NSRect)rectForExtraPart:(NSInteger)aPart
{
    NSRect result = NSZeroRect;
    NSRect rect;
    switch (aPart) {
        case 0:
        if (NSEqualRects([self rectForPart:4], NSZeroRect)) {
            break;
        }
        rect = [self bounds];
        result.origin.y = rect.origin.y;
        result.size.height = rect.size.height;
        if ([self arrowsTogether]) {
            result.origin.x = rect.origin.x + rect.size.width - 32.0f;
        } else {
            result.origin.x = rect.origin.x;
        }
        result.size.width = 16.0f;
        break;
        case 1:
        if (NSEqualRects([self rectForPart:5], NSZeroRect)) {
            break;
        }
        rect = [self bounds];
        result.origin.y = rect.origin.y;
        result.size.height = rect.size.height;
        result.origin.x = rect.origin.x + rect.size.width - 16.0f;
        result.size.width = 16.0f;
        break;
        case 2:
        result = [self rectForPart:6];
        break;
        case 3:
        case 5:
        result = [self rectForPart:6];
        result.size.width = 10.0f;
        break;
        case 4:
        case 6:
        rect = [self rectForPart:6];
        result.origin.y = rect.origin.y;
        result.size.height = rect.size.height;
        result.origin.x = rect.size.width - 10.0f + rect.origin.x;
        result.size.width = 10.0f;
        break;
        case 7:
        rect = [self rectForPart:2];
        result.origin.y = rect.origin.y;
        result.size.height = rect.size.height;
        result.origin.x = rect.origin.x + 10.0f;
        result.size.width = rect.size.width - 20.0f;
        break;
        case 8:
        result = [self rectForPart:2];
        result.size.width = 10.0f;
        break;
        case 9:
        rect = [self rectForPart:2];
        result.origin.y = rect.origin.y;
        result.size.height = rect.size.height;
        result.origin.x = rect.size.width - 10.0f + rect.origin.x;
        result.size.width = 10.0f;
        break;
        case 10:
        result = [self rectForPart:0];
        result.size.width = [self rectForPart:6].origin.x - result.origin.x;
        if (result.size.width == 0.0f) {
            result = NSZeroRect;
        }
        break;
    }
    return result;
}

- (id)simpleSubfolder
{
    return @"HorizontalScroller/Simple";
}

- (id)highlightedSubfolder
{
    return @"HorizontalScroller/Highlighted";
}

- (id)initWithScrollView:(id)aView
{
    id pvVar1;
    Class pvVar3;
    id pvVar2_2;
    id pvVar3_4;

    self = [super init];
    pvVar1 = nil;
    if (self != nil) {
        pvVar1 = [NSMutableData data];
        pvVar2_2 = [[NSKeyedArchiver alloc] initForWritingWithMutableData:pvVar1];
        pvVar3 = [NSScroller class];
        [pvVar2_2 setClassName:(NSStringFromClass([self class])) forClass:pvVar3];
        [[aView horizontalScroller] encodeWithCoder:pvVar2_2];
        [pvVar2_2 finishEncoding];
        pvVar3_4 = [[NSKeyedUnarchiver alloc] initForReadingWithData:pvVar1];
        [self autorelease];
        pvVar1 = [[[self class] alloc] initWithCoder:pvVar3_4];
        [pvVar2_2 release];
        [pvVar3_4 release];
    }
    return pvVar1;
}

@end

