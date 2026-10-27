#import "HSInfoTag.h"
static id sDAT_003428a8;
static id sDAT_003428ac;
static id sDAT_003428b0;

static id sDAT_003428a8;
static id sDAT_003428ac;
static id sDAT_003428b0;


@implementation HSInfoTag

/* i386 ivar offsets: _window=0x4, _backgroundView=0x8, _tagView=0xc, _tagStorage=0x10, _ownersWindow=0x14 */

+ (void)setDefaultColor:(id)aColor
{
    if (sDAT_003428a8 != aColor) {
        [sDAT_003428a8 release];
        sDAT_003428a8 = [aColor retain];
    }
}

+ (id)defaultColor
{
    return sDAT_003428a8;
}

+ (void)setDefaultFont:(id)aFont
{
    if (sDAT_003428b0 != aFont) {
        [sDAT_003428b0 release];
        sDAT_003428b0 = [aFont retain];
    }
}

+ (id)defaultFont
{
    if (sDAT_003428b0 == nil) {
        sDAT_003428b0 = [[NSFont toolTipsFontOfSize:(float)[NSFont labelFontSize]] retain];
    }
    return sDAT_003428b0;
}

+ (id)sharedInstance
{
    if (sDAT_003428ac == nil) {
        sDAT_003428ac = [self new];
    }
    return sDAT_003428ac;
}

- (void)windowDidResignKey:(id)aKey
{
    [self hide];
}

- (void)windowDidUpdate:(id)aUpdate
{
    BOOL pvVar1;
    NSUInteger pvVar2_2;

    pvVar1 = [_window isVisible];
    pvVar2_2 = [[NSApp orderedWindows] indexOfObjectIdenticalTo:_window];
    if ((pvVar1) && (0 < (int)pvVar2_2)) {
        [self hide];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a15ca @ 000a15ca, 132 bytes * /

void FUN_000a15ca(HSInfoTag *self,SEL _cmd,id setBorderColor)

{
  id self_00;
  double dVar1;
  
  dVar1 = _objc_msgSend_fpret(setBorderColor,sel_alphaComponent);
  if ((float)dVar1 < 1.0) {
    setBorderColor = _objc_msgSend(setBorderColor,sel_colorWithAlphaComponent_,0x3f800000);
  }
  self_00 = _objc_msgSend(self,sel__backgroundView);
  _objc_msgSend(self_00,sel_setBorderColor_,setBorderColor);
  return;
}

*/
- (void)setBorderColor:(id)aColor
{
    if ([aColor alphaComponent] < 1.0f) {
        aColor = [aColor colorWithAlphaComponent:1.0];
    }
    [(SMKTintedView *)[self _backgroundView] setBorderColor:aColor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a164e @ 000a164e, 58 bytes * /

id FUN_000a164e(HSInfoTag *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel__backgroundView);
  pvVar1 = _objc_msgSend(pvVar1,sel_borderColor);
  return pvVar1;
}

*/
- (id)borderColor
{
    return [(SMKTintedView *)[self _backgroundView] borderColor];
}

- (void)setBackgroundColor:(id)aColor
{
    if ((float)[aColor alphaComponent] < 1.0) {
        aColor = [aColor colorWithAlphaComponent:1.0];
    }
    [[self _backgroundView] setTintColor:aColor];
}

- (id)backgroundColor
{
    return [[self _backgroundView] tintColor];
}

- (void)hideWithFadeOutEffect
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSInfoTagWillHide" object:self];
    _ownersWindow = nil;
    [[self _window] fadeOut];
}

- (void)hide
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSInfoTagWillHide" object:self];
    _ownersWindow = nil;
    [[self _window] close];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a183c @ 000a183c, 227 bytes * /

void FUN_000a183c(HSInfoTag *self,SEL _cmd,NSRect showTaggedToRightSideOfRect,id inView)

{
  id pvVar1;
  float extraout_EDX;
  longdouble lVar2;
  float local_18;
  
  pvVar1 = _objc_msgSend(inView,sel_window);
  self->_ownersWindow = pvVar1;
  _objc_msgSend(self,sel__window);
  local_18 = showTaggedToRightSideOfRect.origin.y;
  _objc_msgSend(self,sel_size);
  if (extraout_EDX < showTaggedToRightSideOfRect.size.height) {
    lVar2 = (longdouble)_floorf(extraout_EDX * 0.5);
    local_18 = (showTaggedToRightSideOfRect.origin.y + showTaggedToRightSideOfRect.size.height * 0.5
               ) - (float)lVar2;
  }
  _objc_msgSend(self,sel_showWithTopLeft_inView_,
                showTaggedToRightSideOfRect.origin.x + showTaggedToRightSideOfRect.size.width,
                local_18,inView);
  return;
}

*/
- (void)showTaggedToRightSideOfRect:(NSRect)aRect inView:(id)aView
{
    _ownersWindow = [aView window];
    [self _window];
    CGFloat top = aRect.origin.y;
    NSSize size = [self size];
    if (size.height < aRect.size.height) {
        top = (aRect.origin.y + aRect.size.height * 0.5f) - floorf((float)(size.height * 0.5f));
    }
    [self showWithTopLeft:NSMakePoint(aRect.origin.x + aRect.size.width, top) inView:aView];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a191f @ 000a191f, 1753 bytes * /

void FUN_000a191f(HSInfoTag *self,SEL _cmd,NSRect showWithAlignRelativeToRect,id inView)

{
  undefined1 *puVar1;
  float fVar2;
  undefined8 uVar3;
  undefined8 uVar4;
  char cVar5;
  id pvVar6;
  float extraout_EDX;
  int *piVar7;
  float **ppfVar8;
  float fVar9;
  undefined8 local_190;
  float *local_188;
  undefined1 *puStack_184;
  undefined1 *local_134;
  float fStack_130;
  undefined1 local_124 [8];
  float local_11c;
  float local_118;
  undefined1 *local_114;
  float local_110;
  undefined8 local_104;
  undefined8 local_fc;
  undefined1 *local_f4;
  float fStack_f0;
  float local_ec;
  float fStack_e8;
  undefined8 local_e4;
  undefined8 local_dc;
  undefined8 local_d4;
  undefined8 local_cc;
  undefined1 *local_c4;
  float fStack_c0;
  float local_bc;
  float fStack_b8;
  undefined8 local_b4;
  undefined8 local_ac;
  undefined8 local_a4;
  undefined8 local_9c;
  undefined1 *local_94;
  float fStack_90;
  float local_8c;
  float fStack_88;
  undefined1 local_84 [16];
  undefined8 local_74;
  undefined8 local_6c;
  undefined1 *local_64;
  float fStack_60;
  float local_5c;
  float fStack_58;
  undefined1 local_54 [16];
  undefined1 *local_44;
  float fStack_40;
  id local_3c;
  undefined1 *local_34;
  float fStack_30;
  float local_2c;
  float fStack_28;
  
  pvVar6 = _objc_msgSend(inView,sel_window);
  self->_ownersWindow = pvVar6;
  fVar9 = showWithAlignRelativeToRect.size.height + showWithAlignRelativeToRect.origin.y;
  puVar1 = *(undefined1 **)PTR_00336078;
  fVar2 = *(float *)(PTR_00336078 + 4);
  uVar4 = *(undefined8 *)PTR_00336078;
  uVar3 = *(undefined8 *)PTR_00336078;
  _objc_msgSend_stret(local_124,inView,sel_frame);
  puStack_184 = (undefined1 *)0xa1a11;
  pvVar6 = _objc_msgSend(self,sel_size);
  local_2c = local_11c;
  fStack_28 = local_118;
  puStack_184 = (undefined1 *)0xa1aa2;
  local_34 = puVar1;
  fStack_30 = fVar2;
  local_3c = pvVar6;
  local_44 = puVar1;
  fStack_40 = fVar2;
  _NSIntersectionRect();
  puStack_184 = local_44;
  local_188 = (float *)0xa1ad5;
  cVar5 = _NSEqualRects();
  local_134 = (undefined1 *)showWithAlignRelativeToRect.origin.x;
  ppfVar8 = (float **)&puStack_184;
  fStack_130 = fVar9;
  if (cVar5 != '\0') {
    local_74 = CONCAT44(fVar9,showWithAlignRelativeToRect.origin.x);
    local_6c = CONCAT44(extraout_EDX,pvVar6);
    local_5c = local_11c;
    fStack_58 = local_118;
    puStack_184 = local_54;
    local_188 = (float *)0xa1b82;
    local_64 = puVar1;
    fStack_60 = fVar2;
    _NSIntersectionRect();
    local_188 = (float *)local_74;
    puStack_184 = (undefined1 *)((ulonglong)local_74 >> 0x20);
    local_190 = CONCAT44(0xa1bb5,(undefined4)local_190);
    cVar5 = _NSEqualRects();
    ppfVar8 = &local_188;
    if (cVar5 == '\0') {
      ppfVar8 = &local_188;
      if (fVar2 + local_118 < fVar9 + extraout_EDX) {
        puStack_184 = (undefined1 *)
                      ((float)pvVar6 / -3.0 +
                      showWithAlignRelativeToRect.size.width * 0.5 +
                      showWithAlignRelativeToRect.origin.x);
        local_188 = (float *)&local_114;
        local_190 = CONCAT44(0xa1c5c,(undefined4)local_190);
        _NSIntegralRect();
        local_134 = local_114;
        fStack_130 = local_110;
        local_a4 = CONCAT44(local_110,local_114);
        local_9c = CONCAT44(extraout_EDX,pvVar6);
        local_8c = local_11c;
        fStack_88 = local_118;
        local_190 = CONCAT44(local_84,0xa1d22);
        local_94 = puVar1;
        fStack_90 = fVar2;
        _NSIntersectionRect();
        local_188 = (float *)local_9c;
        puStack_184 = (undefined1 *)((ulonglong)local_9c >> 0x20);
        local_190 = local_a4;
        cVar5 = _NSEqualRects();
        ppfVar8 = (float **)&local_190;
        if (cVar5 != '\0') goto LAB_000a1fbb;
        ppfVar8 = (float **)&local_190;
        if (local_110 < fVar2) {
          local_134 = (undefined1 *)showWithAlignRelativeToRect.origin.x;
          ppfVar8 = (float **)&local_190;
          fStack_130 = fVar9;
        }
      }
      piVar7 = (int *)ppfVar8;
      if ((float)puVar1 + local_11c < (float)local_134 + (float)pvVar6) {
        local_134 = (undefined1 *)(((float)puVar1 + local_11c) - (float)pvVar6);
        local_d4 = CONCAT44(fStack_130,local_134);
        local_cc = CONCAT44(extraout_EDX,pvVar6);
        local_bc = local_11c;
        fStack_b8 = local_118;
        *(ulonglong *)(ppfVar8 + 7) = CONCAT44(local_118,local_11c);
        *(undefined8 *)(ppfVar8 + 5) = uVar3;
        *(undefined8 *)(ppfVar8 + 3) = local_cc;
        *(undefined8 *)(ppfVar8 + 1) = local_d4;
        *ppfVar8 = (float *)&local_b4;
        ppfVar8[-1] = (float *)0xa1e76;
        local_c4 = puVar1;
        fStack_c0 = fVar2;
        _NSIntersectionRect();
        piVar7 = (int *)(ppfVar8 + -1);
        *(undefined8 *)(ppfVar8 + 5) = local_ac;
        *(undefined8 *)(ppfVar8 + 3) = local_b4;
        *(undefined8 *)(ppfVar8 + 1) = local_cc;
        *(undefined8 *)(ppfVar8 + -1) = local_d4;
        ppfVar8[-2] = (float *)0xa1eb5;
        cVar5 = _NSEqualRects();
        ppfVar8 = ppfVar8 + -1;
        if (cVar5 != '\0') goto LAB_000a1fbb;
      }
      ppfVar8 = (float **)piVar7;
      if ((float)local_134 < (float)puVar1) {
        local_104 = CONCAT44(fStack_130,puVar1);
        local_fc = CONCAT44(extraout_EDX,pvVar6);
        local_ec = local_11c;
        fStack_e8 = local_118;
        *(ulonglong *)(piVar7 + 7) = CONCAT44(local_118,local_11c);
        *(undefined8 *)(piVar7 + 5) = uVar4;
        *(undefined8 *)(piVar7 + 3) = local_fc;
        *(undefined8 *)(piVar7 + 1) = local_104;
        *piVar7 = (int)&local_e4;
        piVar7[-1] = 0xa1f7c;
        local_f4 = puVar1;
        fStack_f0 = fVar2;
        _NSIntersectionRect();
        ppfVar8 = (float **)(piVar7 + -1);
        *(undefined8 *)(piVar7 + 5) = local_dc;
        *(undefined8 *)(piVar7 + 3) = local_e4;
        *(undefined8 *)(piVar7 + 1) = local_fc;
        *(undefined8 *)(piVar7 + -1) = local_104;
        piVar7[-2] = 0xa1fbb;
        _NSEqualRects();
        local_134 = puVar1;
      }
    }
  }
LAB_000a1fbb:
  ppfVar8[4] = inView;
  ppfVar8[3] = (float *)fStack_130;
  ppfVar8[2] = (float *)local_134;
  ppfVar8[1] = (float *)sel_showWithTopLeft_inView_;
  *ppfVar8 = (float *)self;
  ppfVar8[-1] = (float *)0xa1fed;
  _objc_msgSend(*ppfVar8,(SEL)ppfVar8[1]);
  return;
}

*/
- (void)showWithAlignRelativeToRect:(NSRect)aRect inView:(id)aView
{
    _ownersWindow = [aView window];
    NSRect bounds = NSZeroRect;
    bounds.size = [aView frame].size;
    NSSize size = [self size];
    NSRect tagRect = NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, size.width, size.height);
    /* Prefer below the rect, then above it centered-ish, then slide back inside horizontally. */
    NSPoint topLeft = NSMakePoint(aRect.origin.x, aRect.origin.y + aRect.size.height);
    if (!NSEqualRects(NSIntersectionRect(tagRect, bounds), tagRect)) {
        [self showWithTopLeft:topLeft inView:aView];
        return;
    }
    tagRect.origin = topLeft;
    if (NSEqualRects(NSIntersectionRect(tagRect, bounds), tagRect)) {
        [self showWithTopLeft:topLeft inView:aView];
        return;
    }
    if (topLeft.y + size.height > bounds.origin.y + bounds.size.height) {
        topLeft.y = aRect.origin.y - size.height;
        topLeft.x = (float)(aRect.size.width * 0.5f + aRect.origin.x) + (float)(size.width / -3.0f);
        topLeft = NSIntegralRect(NSMakeRect(topLeft.x, topLeft.y, size.width, size.height)).origin;
        tagRect.origin = topLeft;
        if (NSEqualRects(NSIntersectionRect(tagRect, bounds), tagRect)) {
            [self showWithTopLeft:topLeft inView:aView];
            return;
        }
        if (bounds.origin.y > topLeft.y) {
            topLeft = NSMakePoint(aRect.origin.x, aRect.origin.y + aRect.size.height);
        }
    }
    if (topLeft.x + size.width > bounds.origin.x + bounds.size.width) {
        topLeft.x = bounds.origin.x + bounds.size.width - size.width;
        tagRect.origin = topLeft;
        if (NSEqualRects(NSIntersectionRect(tagRect, bounds), tagRect)) {
            [self showWithTopLeft:topLeft inView:aView];
            return;
        }
    }
    if (bounds.origin.x > topLeft.x) {
        topLeft.x = bounds.origin.x;
    }
    [self showWithTopLeft:topLeft inView:aView];
}

- (void)showWithTopLeft:(NSPoint)aLeft attributedTitle:(id)aTitle
{
    [self setAttributedTitle:aTitle];
    [self showWithTopLeft:aLeft];
}

- (void)showWithTopLeft:(NSPoint)aLeft title:(id)aTitle
{
    [self setTitle:aTitle];
    [self showWithTopLeft:aLeft];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a20aa @ 000a20aa, 181 bytes * /

void FUN_000a20aa(HSInfoTag *self,SEL _cmd,NSPoint showWithTopLeft,id inView)

{
  id pvVar1;
  id self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(inView,sel_window);
  self->_ownersWindow = pvVar1;
  pvVar1 = _objc_msgSend(inView,sel_convertPoint_toView_,showWithTopLeft.x,showWithTopLeft.y,0);
  self_00 = _objc_msgSend(inView,sel_window);
  pvVar1 = _objc_msgSend(self_00,sel_convertBaseToScreen_,pvVar1,extraout_EDX);
  _objc_msgSend(self,sel_showWithTopLeft_,pvVar1,extraout_EDX_00);
  return;
}

*/
- (void)showWithTopLeft:(NSPoint)aLeft inView:(id)aView
{
    _ownersWindow = [aView window];
    NSPoint point = [aView convertPoint:aLeft toView:nil];
    [self showWithTopLeft:[(NSWindow *)[aView window] convertPointToScreen:point]];
}

- (void)showWithTopLeft:(NSPoint)aLeft
{
    [[self _window] setFrameTopLeftPoint:aLeft];
    [[self _window] orderFront:0];
}

- (BOOL)isVisible
{
    BOOL BVar1;

    if (_window == nil) {
        BVar1 = NO;
    }
    else {
        BVar1 = (BOOL)[_window isVisible];
    }
    return BVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a2211 @ 000a2211, 104 bytes * /

void FUN_000a2211(HSInfoTag *self,SEL _cmd,float sizeToWidth)

{
  undefined4 extraout_EDX;
  
  _objc_msgSend(self,sel__window);
  _objc_msgSend(self,sel_contentSizeForMaxWidth_,sizeToWidth);
  _objc_msgSend(self,sel_setSize_,sizeToWidth,extraout_EDX);
  return;
}

*/
- (void)sizeToWidth:(CGFloat)aWidth
{
    [self _window];
    NSSize size = [self contentSizeForMaxWidth:aWidth];
    [self setSize:NSMakeSize(aWidth, size.height)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a2279 @ 000a2279, 97 bytes * /

void FUN_000a2279(HSInfoTag *self,SEL _cmd,float sizeToMaxWidth)

{
  id pvVar1;
  undefined4 extraout_EDX;
  
  _objc_msgSend(self,sel__window);
  pvVar1 = _objc_msgSend(self,sel_contentSizeForMaxWidth_,sizeToMaxWidth);
  _objc_msgSend(self,sel_setSize_,pvVar1,extraout_EDX);
  return;
}

*/
- (void)sizeToMaxWidth:(CGFloat)aWidth
{
    [self _window];
    [self setSize:[self contentSizeForMaxWidth:aWidth]];
}

- (void)sizeToFit
{
    [self _sizeWindowToFitContent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a2300 @ 000a2300, 160 bytes * /

void FUN_000a2300(HSInfoTag *self,SEL _cmd,NSSize setSize)

{
  id self_00;
  undefined4 local_1c;
  float fStack_18;
  float local_14;
  float fStack_10;
  
  self_00 = _objc_msgSend(self,sel__window);
  _objc_msgSend_stret(&local_1c,self_00,sel_frame);
  fStack_18 = fStack_18 + fStack_10;
  local_14 = setSize.width;
  fStack_10 = setSize.height;
  fStack_18 = fStack_18 - setSize.height;
  _objc_msgSend(self->_window,sel_setFrame_display_,CONCAT44(fStack_18,local_1c),setSize,1);
  return;
}

*/
- (void)setSize:(NSSize)aSize
{
    NSRect frame = [[self _window] frame];
    /* Keep the top edge fixed. */
    frame.origin.y = frame.origin.y + frame.size.height - aSize.height;
    frame.size = aSize;
    [_window setFrame:frame display:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a23a0 @ 000a23a0, 74 bytes * /

ulonglong FUN_000a23a0(HSInfoTag *self,SEL _cmd)

{
  id self_00;
  undefined1 local_1c [8];
  ulonglong local_14;
  
  self_00 = _objc_msgSend(self,sel__window);
  _objc_msgSend_stret(local_1c,self_00,sel_frame);
  return local_14;
}

*/
- (NSSize)size
{
    return [[self _window] frame].size;
}

- (id)window
{
    return _ownersWindow;
}

- (void)setAttributedTitle:(id)aTitle
{
    unsigned pvVar1_2;

    pvVar1_2 = [[self _tagStorage] length];
    [[self _tagStorage] beginEditing];
    [[self _tagStorage] replaceCharactersInRange:NSMakeRange(0, pvVar1_2) withAttributedString:aTitle];
    [[self _tagStorage] endEditing];
    [self _sizeWindowToFitContent];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a24c5 @ 000a24c5, 118 bytes * /

id FUN_000a24c5(HSInfoTag *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = self->_tagStorage;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSAttributedString,sel_new);
    op = sel_autorelease;
  }
  else {
    _objc_msgSend(pvVar1,sel_length);
    op = sel_attributedSubstringFromRange_;
  }
  pvVar1 = _objc_msgSend(pvVar1,op);
  return pvVar1;
}

*/
- (id)attributedTitle
{
    if (_tagStorage == nil) {
        return [[NSAttributedString new] autorelease];
    }
    return [_tagStorage attributedSubstringFromRange:NSMakeRange(0, [_tagStorage length])];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a253b @ 000a253b, 587 bytes * /

void FUN_000a253b(HSInfoTag *self,SEL _cmd,id setTitle)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  SEL op;
  undefined4 uVar5;
  undefined4 uVar6;
  
  pvVar1 = _objc_msgSend(self,sel__tagStorage);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  pvVar2 = _objc_msgSend(self,sel__tagStorage);
  _objc_msgSend(pvVar2,sel_beginEditing);
  pvVar2 = _objc_msgSend(self,sel__tagStorage);
  uVar5 = 0;
  _objc_msgSend(pvVar2,sel_replaceCharactersInRange_withString_,0,pvVar1,setTitle);
  pvVar2 = _objc_msgSend(self,sel__tagStorage);
  pvVar2 = _objc_msgSend(pvVar2,sel_length);
  if (pvVar2 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel__tagStorage,uVar5,pvVar1,setTitle);
    pvVar3 = _objc_msgSend(self,sel_class);
    pvVar4 = _objc_msgSend(pvVar3,sel_defaultFont);
    uVar5 = *(undefined4 *)PTR_00336068;
    uVar6 = 0;
    pvVar3 = pvVar2;
    _objc_msgSend(pvVar1,sel_addAttribute_value_range_,uVar5,pvVar4,0,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_defaultColor);
    self_00 = _objc_msgSend(self,sel__tagStorage);
    if (pvVar1 == (id)0x0) {
      uVar5 = *(undefined4 *)PTR_00336394;
      pvVar1 = (id)0x0;
      op = sel_removeAttribute_range_;
      setTitle = pvVar2;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_class,uVar5,pvVar4,uVar6,pvVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_defaultColor);
      uVar5 = *(undefined4 *)PTR_00336394;
      op = sel_addAttribute_value_range_;
      setTitle = (id)0x0;
      pvVar3 = pvVar2;
    }
    _objc_msgSend(self_00,op,uVar5,pvVar1,setTitle,pvVar3);
  }
  pvVar1 = _objc_msgSend(self,sel__tagStorage,uVar5,pvVar1,setTitle);
  _objc_msgSend(pvVar1,sel_endEditing);
  _objc_msgSend(self,sel__sizeWindowToFitContent);
  return;
}

*/
- (void)setTitle:(id)aTitle
{
    NSUInteger oldLength = [[self _tagStorage] length];
    [[self _tagStorage] beginEditing];
    [[self _tagStorage] replaceCharactersInRange:NSMakeRange(0, oldLength) withString:aTitle];
    NSUInteger length = [[self _tagStorage] length];
    if (length != 0) {
        [[self _tagStorage] addAttribute:NSFontAttributeName value:[[self class] defaultFont] range:NSMakeRange(0, length)];
        if ([[self class] defaultColor] == nil) {
            [[self _tagStorage] removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, length)];
        } else {
            [[self _tagStorage] addAttribute:NSForegroundColorAttributeName value:[[self class] defaultColor] range:NSMakeRange(0, length)];
        }
    }
    [[self _tagStorage] endEditing];
    [self _sizeWindowToFitContent];
}

- (id)title
{
    NSString *pcVar2;

    if (_tagStorage == nil) {
        pcVar2 = @"";
    }
    else {
        pcVar2 = [[_tagStorage string] substringWithRange:NSMakeRange(0, [_tagStorage length])];
    }
    return pcVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a27f6 @ 000a27f6, 669 bytes * /

id FUN_000a27f6(HSInfoTag *self,SEL _cmd)

{
  undefined8 uVar1;
  undefined8 uVar2;
  id pvVar3;
  id pvVar4;
  
  pvVar3 = self->_window;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(cls_HSInfoTagWindow,sel_alloc);
    pvVar3 = _objc_msgSend(pvVar3,sel_initWithContentRect_styleMask_backing_defer_,0,
                           0x4120000041200000,0,2,1);
    self->_window = pvVar3;
    pvVar4 = _objc_msgSend(cls_NSColor,sel_clearColor);
    _objc_msgSend(pvVar3,sel_setBackgroundColor_,pvVar4);
    _objc_msgSend(self->_window,sel_setOpaque_,0);
    _objc_msgSend(self->_window,sel_setHasShadow_,1);
    uVar2 = *(undefined8 *)PTR_00336074;
    uVar1 = *(undefined8 *)PTR_00336074;
    pvVar3 = _objc_msgSend(self,sel__backgroundView);
    _objc_msgSend(pvVar3,sel_setFrame_,uVar1,0x4120000041200000);
    pvVar3 = _objc_msgSend(self,sel__tagView);
    _objc_msgSend(pvVar3,sel_setFrame_,uVar2,0x4120000041200000);
    pvVar3 = _objc_msgSend(self,sel__backgroundView);
    pvVar4 = _objc_msgSend(self,sel__tagView);
    _objc_msgSend(pvVar3,sel_addSubview_,pvVar4);
    pvVar3 = _objc_msgSend(self,sel__backgroundView);
    _objc_msgSend(pvVar3,sel_setAutoresizesSubviews_,1);
    pvVar3 = _objc_msgSend(self,sel__tagView);
    _objc_msgSend(pvVar3,sel_setAutoresizingMask_,0x12);
    pvVar3 = self->_window;
    pvVar4 = _objc_msgSend(self,sel__backgroundView);
    _objc_msgSend(pvVar3,sel_setContentView_,pvVar4);
    _objc_msgSend(self,sel__sizeWindowToFitContent);
    _objc_msgSend(self->_window,sel_setReleasedWhenClosed_,0);
    _objc_msgSend(self->_window,sel_setDelegate_,self);
    pvVar3 = self->_window;
  }
  return pvVar3;
}

*/
- (id)_window
{
    if (_window == nil) {
        _window = [[HSInfoTagWindow alloc] initWithContentRect:NSMakeRect(0, 0, 10, 10) styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES];
        [_window setBackgroundColor:[NSColor clearColor]];
        [_window setOpaque:NO];
        [_window setHasShadow:YES];
        [[self _backgroundView] setFrame:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, 10, 10)];
        [[self _tagView] setFrame:NSMakeRect(NSZeroPoint.x, NSZeroPoint.y, 10, 10)];
        [[self _backgroundView] addSubview:[self _tagView]];
        [[self _backgroundView] setAutoresizesSubviews:YES];
        [(NSView *)[self _tagView] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [_window setContentView:[self _backgroundView]];
        [self _sizeWindowToFitContent];
        [_window setReleasedWhenClosed:NO];
        [_window setDelegate:self];
    }
    return _window;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a2a93 @ 000a2a93, 332 bytes * /

id FUN_000a2a93(HSInfoTag *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = self->_backgroundView;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_SMKTintedView,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_,0,0x4120000041200000);
    self->_backgroundView = pvVar1;
    pvVar2 = _objc_msgSend(cls_NSColor,sel_colorWithCalibratedHue_saturation_brightness_alpha_,
                           0x3e23d70a,0x3e3851ec,0x3f800000,0x3f800000);
    _objc_msgSend(pvVar1,sel_setTintColor_,pvVar2);
    pvVar1 = self->_backgroundView;
    pvVar2 = _objc_msgSend(cls_NSColor,sel_colorWithCalibratedHue_saturation_brightness_alpha_,
                           0x3e23d70a,0x3e3851ec,0x3f800000,0x3f800000);
    _objc_msgSend(pvVar1,sel_setBorderColor_,pvVar2);
    _objc_msgSend(self->_backgroundView,sel_setBorderThickness_,0x3fc00000);
    _objc_msgSend(self->_backgroundView,sel_setCornerRadius_,0);
    pvVar1 = self->_backgroundView;
  }
  return pvVar1;
}

*/
- (id)_backgroundView
{
    if (_backgroundView == nil) {
        _backgroundView = [[SMKTintedView alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)];
        [_backgroundView setTintColor:[NSColor colorWithCalibratedHue:0.16 saturation:0.18 brightness:1.0 alpha:1.0]];
        [(SMKTintedView *)_backgroundView setBorderColor:[NSColor colorWithCalibratedHue:0.16 saturation:0.18 brightness:1.0 alpha:1.0]];
        [_backgroundView setBorderThickness:1.5];
        [_backgroundView setCornerRadius:0];
    }
    return _backgroundView;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a2bdf @ 000a2bdf, 610 bytes * /

id FUN_000a2bdf(HSInfoTag *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  
  pvVar1 = self->_tagView;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSLayoutManager,sel_new);
    pvVar2 = _objc_msgSend(cls_NSTextContainer,sel_alloc);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithContainerSize_,0x461c4000,0x461c4000);
    _objc_msgSend(pvVar2,sel_setLineFragmentPadding_,0);
    _objc_msgSend(pvVar1,sel_addTextContainer_,pvVar2);
    _objc_msgSend(pvVar2,sel_release);
    self_00 = _objc_msgSend(self,sel__tagStorage);
    _objc_msgSend(self_00,sel_addLayoutManager_,pvVar1);
    _objc_msgSend(pvVar1,sel_release);
    pvVar1 = _objc_msgSend(cls_NSTextView,sel_alloc);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithFrame_textContainer_,0,0x4120000041200000,pvVar2);
    self->_tagView = pvVar1;
    _objc_msgSend(pvVar1,sel_setTextContainerInset_,0x40800000,0x40800000);
    _objc_msgSend(self->_tagView,sel_setDrawsBackground_,0);
    _objc_msgSend(self->_tagView,sel_setEditable_,0);
    _objc_msgSend(self->_tagView,sel_setSelectable_,1);
    _objc_msgSend(self->_tagView,sel_setDelegate_,self);
    _objc_msgSend(self->_tagView,sel_setHorizontallyResizable_,0);
    _objc_msgSend(self->_tagView,sel_setVerticallyResizable_,0);
    _objc_msgSend(pvVar2,sel_setHeightTracksTextView_,0);
    _objc_msgSend(pvVar2,sel_setWidthTracksTextView_,0);
    pvVar1 = self->_tagView;
  }
  return pvVar1;
}

*/
- (id)_tagView
{
    if (_tagView == nil) {
        NSLayoutManager *layoutManager = [NSLayoutManager new];
        NSTextContainer *container = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(10000, 10000)];
        [container setLineFragmentPadding:0];
        [layoutManager addTextContainer:container];
        [container release];
        [[self _tagStorage] addLayoutManager:layoutManager];
        [layoutManager release];
        _tagView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 10, 10) textContainer:container];
        [_tagView setTextContainerInset:NSMakeSize(4, 4)];
        [_tagView setDrawsBackground:NO];
        [_tagView setEditable:NO];
        [_tagView setSelectable:YES];
        [_tagView setDelegate:self];
        [_tagView setHorizontallyResizable:NO];
        [_tagView setVerticallyResizable:NO];
        [container setHeightTracksTextView:NO];
        [container setWidthTracksTextView:NO];
    }
    return _tagView;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a2e41 @ 000a2e41, 185 bytes * /

id FUN_000a2e41(HSInfoTag *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = self->_tagStorage;
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSTextStorage,sel_alloc);
    self_00 = cls_NSDictionary;
    uVar1 = *(undefined4 *)PTR_00336068;
    pvVar3 = _objc_msgSend(cls_NSFont,sel_toolTipsFontOfSize_,0x41200000);
    pvVar3 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar3,uVar1,0);
    pvVar2 = _objc_msgSend(pvVar2,sel_initWithString_attributes_,&cfstr_empty,pvVar3);
    self->_tagStorage = pvVar2;
  }
  return pvVar2;
}

*/
- (id)_tagStorage
{
    if (_tagStorage == nil) {
        _tagStorage = [[NSTextStorage alloc] initWithString:@"" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont toolTipsFontOfSize:10], NSFontAttributeName, nil]];
    }
    return _tagStorage;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a2efa @ 000a2efa, 126 bytes * /

void FUN_000a2efa(HSInfoTag *self,SEL _cmd)

{
  id pvVar1;
  undefined4 extraout_EDX;
  float fVar2;
  
  if (self->_window != (id)0x0) {
    fVar2 = 10000.0;
    while( true ) {
      pvVar1 = _objc_msgSend(self,sel_contentSizeForMaxWidth_,fVar2);
      if ((float)pvVar1 <= 400.0) break;
      fVar2 = (float)pvVar1 * 0.5;
    }
    _objc_msgSend(self,sel_setSize_,pvVar1,extraout_EDX);
  }
  return;
}

*/
- (void)_sizeWindowToFitContent
{
    if (_window == nil) {
        return;
    }
    /* Halve the width until the tag is no wider than 400 points. */
    CGFloat width = 10000;
    NSSize size;
    while (true) {
        size = [self contentSizeForMaxWidth:width];
        if (size.width <= 400) {
            break;
        }
        width = (float)(size.width * 0.5f);
    }
    [self setSize:size];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000a2f78 @ 000a2f78, 525 bytes * /

ulonglong FUN_000a2f78(HSInfoTag *self,SEL _cmd,float contentSizeForMaxWidth)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  uint extraout_EDX;
  undefined4 extraout_EDX_00;
  float fVar5;
  float local_48;
  undefined1 local_44 [8];
  ulonglong local_3c;
  undefined4 local_34;
  undefined4 uStack_30;
  undefined4 local_2c;
  undefined4 uStack_28;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  local_34 = *(undefined4 *)PTR_00336078;
  uStack_30 = *(undefined4 *)(PTR_00336078 + 4);
  local_2c = *(undefined4 *)(PTR_00336078 + 8);
  uStack_28 = *(undefined4 *)(PTR_00336078 + 0xc);
  pvVar1 = _objc_msgSend(self->_tagView,sel_textContainerInset);
  pvVar2 = _objc_msgSend(self->_tagStorage,sel_length);
  fVar5 = (float)pvVar1 * -2.0 + contentSizeForMaxWidth;
  local_48 = 0.0;
  if (0.0 <= fVar5) {
    local_48 = fVar5;
  }
  pvVar3 = _objc_msgSend(self->_tagView,sel_textContainer);
  _objc_msgSend(pvVar3,sel_setContainerSize_,local_48,0x461c4000);
  pvVar3 = _objc_msgSend(self->_tagView,sel_layoutManager);
  pvVar2 = _objc_msgSend(pvVar3,sel_glyphRangeForCharacterRange_actualCharacterRange_,0,pvVar2,0);
  pvVar3 = _objc_msgSend(self->_tagView,sel_layoutManager);
  pvVar4 = _objc_msgSend(self->_tagView,sel_textContainer);
  _objc_msgSend_stret(local_24,pvVar3,sel_boundingRectForGlyphRange_inTextContainer_,pvVar2,
                      extraout_EDX_00,pvVar4);
  local_2c = local_1c;
  uStack_28 = local_18;
  _NSIntegralRect(&local_34,local_34,uStack_30,local_1c,local_18);
  _NSInsetRect(local_44,local_34,uStack_30,local_2c,uStack_28,(uint)pvVar1 ^ 0x80000000,
               extraout_EDX ^ 0x80000000);
  return local_3c;
}

*/
- (NSSize)contentSizeForMaxWidth:(CGFloat)aWidth
{
    NSSize inset = [_tagView textContainerInset];
    NSUInteger length = [_tagStorage length];
    float width = (float)(inset.width * -2.0f + aWidth);
    if (width < 0) {
        width = 0;
    }
    [[_tagView textContainer] setContainerSize:NSMakeSize(width, 10000)];
    NSRange glyphRange = [[_tagView layoutManager] glyphRangeForCharacterRange:NSMakeRange(0, length) actualCharacterRange:NULL];
    NSRect bounds = [[_tagView layoutManager] boundingRectForGlyphRange:glyphRange inTextContainer:[_tagView textContainer]];
    NSRect rect = NSIntegralRect(NSMakeRect(NSZeroRect.origin.x, NSZeroRect.origin.y, bounds.size.width, bounds.size.height));
    return NSInsetRect(rect, -inset.width, -inset.height).size;
}

- (void)dealloc
{
    if (sDAT_003428ac == self) {
        sDAT_003428ac = nil;
    }
    [super dealloc];
}

- (id)init
{
    if (sDAT_003428ac == nil) {
        self = [super init];
        if (self != nil) {
            _ownersWindow = nil;
            sDAT_003428ac = self;
        }
    }
    else {
        [super dealloc];
        self = sDAT_003428ac;
    }
    return self;
}

@end

