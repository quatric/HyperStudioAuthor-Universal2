#import "HSCustomTabView.h"

@implementation HSCustomTabView

/* i386 ivar offsets: _header=0x50, _rightSeparator=0x54, _leftSeparator=0x58, _contentView=0x5c, _content=0x60, _delegate=0x64 */

+ (id)defaultCellFont
{
    return [NSFont boldSystemFontOfSize:8.0];
}

+ (id)separatorColor
{
    return [NSColor colorWithCalibratedWhite:0.5 alpha:0.3];
}

- (void)headerSelectionChanged:(id)aChanged
{
    [self mountContentViewForSelectedTab];
    if (_delegate != nil) {
        if ([_delegate respondsToSelector:@selector(selectedTabDidChangeInCustomTabView:)]) {
            [_delegate selectedTabDidChangeInCustomTabView:self];
        }
    }
}

- (id)tabDescriptionWithTitle:(id)aTitle image:(id)aImage toolTip:(id)aTip accessibilityValues:(id)aValues contentView:(id)aView
{
    id self_00;

    self_00 = [NSMutableDictionary dictionary];
    if (aTitle != nil) {
        [self_00 setObject:aTitle forKey:@"HSCustomTabViewItemTitleKey"];
    }
    if (aTip != nil) {
        [self_00 setObject:aTip forKey:@"HSCustomTabViewItemToolTipKey"];
    }
    if (aValues != nil) {
        [self_00 setObject:aValues forKey:@"HSCustomTabViewItemAccessibilityKey"];
    }
    if (aImage != nil) {
        [self_00 setObject:aImage forKey:@"HSCustomTabViewItemImageKey"];
    }
    [self_00 setObject:aView forKey:@"HSCustomTabViewItemContentViewKey"];
    return self_00;
}

- (id)content
{
    id pvVar1;

    pvVar1 = _content;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableArray new];
        _content = pvVar1;
    }
    return pvVar1;
}

- (void)mountContentViewForSelectedTab
{
    [self mountContentViewForTabAtIndex:[_header selectedColumn]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016e89a @ 0016e89a, 289 bytes * /

void FUN_0016e89a(HSCustomTabView *self,SEL _cmd,int mountContentViewForTabAtIndex)

{
  id pvVar1;
  undefined1 local_24 [8];
  undefined4 local_1c;
  undefined4 local_18;
  
  pvVar1 = _objc_msgSend(self->_contentView,sel_subviews);
  _objc_msgSend(pvVar1,sel_makeObjectsPerformSelector_,sel_removeFromSuperview);
  pvVar1 = _objc_msgSend(self,sel_content);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,mountContentViewForTabAtIndex);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,
                         PTR_cfstr_HSCustomTabViewItemContentViewKey_00342518);
  _objc_msgSend(pvVar1,sel_setFrameOrigin_,*(undefined4 *)PTR_00336074,
                *(undefined4 *)(PTR_00336074 + 4));
  _objc_msgSend_stret(local_24,self->_contentView,sel_frame);
  _objc_msgSend(pvVar1,sel_setFrameSize_,local_1c,local_18);
  _objc_msgSend(self->_contentView,sel_addSubview_,pvVar1);
  return;
}

*/
- (void)mountContentViewForTabAtIndex:(NSInteger)aIndex
{
    [[_contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSView *view = [[[self content] objectAtIndex:aIndex] objectForKey:@"HSCustomTabViewItemContentViewKey"];
    [view setFrameOrigin:NSZeroPoint];
    [view setFrameSize:[_contentView frame].size];
    [_contentView addSubview:view];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016e9bb @ 0016e9bb, 103 bytes * /

void FUN_0016e9bb(HSCustomTabView *self,SEL _cmd)

{
  undefined1 local_1c [8];
  undefined4 local_14;
  float local_10;
  
  _objc_msgSend_stret(local_1c,self,sel_frame);
  _objc_msgSend(self->_contentView,sel_setFrameSize_,local_14,local_10 + -26.0);
  return;
}

*/
- (void)updateContentViewSize
{
    [_contentView setFrameSize:NSMakeSize([self frame].size.width, [self frame].size.height - 26.0)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016e4ef @ 0016e4ef, 202 bytes * /

void FUN_0016e4ef(HSCustomTabView *self,SEL _cmd)

{
  undefined4 uVar1;
  undefined8 uVar2;
  id pvVar3;
  
  uVar1 = *(undefined4 *)PTR_00336078;
  uVar2 = *(undefined8 *)(PTR_00336078 + 8);
  pvVar3 = _objc_msgSend(cls_NSView,sel_alloc);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithFrame_,CONCAT44(0x41d00000,uVar1),uVar2);
  self->_contentView = pvVar3;
  _objc_msgSend(pvVar3,sel_setAutoresizingMask_,0x12);
  _objc_msgSend(self,sel_addSubview_,self->_contentView);
  _objc_msgSend(self,sel_updateContentViewSize);
  return;
}

*/
- (void)createContentView
{
    _contentView = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 26.0, 0.0, 0.0)];
    [_contentView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self addSubview:_contentView];
    [self updateContentViewSize];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016ea22 @ 0016ea22, 260 bytes * /

void FUN_0016ea22(HSCustomTabView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  double dVar3;
  
  dVar3 = _objc_msgSend_fpret(self,sel_rightSeparatorOffset);
  _objc_msgSend(self->_leftSeparator,sel_setFrame_,0x41c8000000000000,0x3f80000040a00000);
  pvVar1 = _objc_msgSend(self,sel_headerOrigin);
  pvVar2 = _objc_msgSend(self,sel_frameSizeOfHeader);
  _objc_msgSend(self->_rightSeparator,sel_setFrame_,
                CONCAT44(0x41c80000,((float)pvVar2 + (float)pvVar1) - (float)dVar3),
                CONCAT44(0x3f800000,(float)dVar3 + 5.0));
  return;
}

*/
- (void)updateSeparators
{
    CGFloat offset = [self rightSeparatorOffset];
    [_leftSeparator setFrame:NSMakeRect(0.0, 25.0, 5.0, 1.0)];
    [_rightSeparator setFrame:NSMakeRect(([self headerOrigin].x + [self frameSizeOfHeader].width) - offset, 25.0, offset + 5.0, 1.0)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016e383 @ 0016e383, 364 bytes * /

void FUN_0016e383(HSCustomTabView *self,SEL _cmd)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar2 = _objc_msgSend(cls_HSTintedView,sel_alloc);
  puVar1 = PTR_00336078;
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithFrame_,*(undefined8 *)PTR_00336078,
                         *(undefined8 *)(PTR_00336078 + 8));
  self->_leftSeparator = pvVar2;
  pvVar3 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(pvVar3,sel_separatorColor);
  _objc_msgSend(pvVar2,sel_setTintColor_,pvVar3);
  _objc_msgSend(self,sel_addSubview_,self->_leftSeparator);
  pvVar2 = _objc_msgSend(cls_HSTintedView,sel_alloc);
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithFrame_,*(undefined8 *)puVar1,*(undefined8 *)(puVar1 + 8)
                        );
  self->_rightSeparator = pvVar2;
  pvVar3 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(pvVar3,sel_separatorColor);
  _objc_msgSend(pvVar2,sel_setTintColor_,pvVar3);
  _objc_msgSend(self,sel_addSubview_,self->_rightSeparator);
  _objc_msgSend(self,sel_updateSeparators);
  return;
}

*/
- (void)createSeparators
{
    _leftSeparator = [[HSTintedView alloc] initWithFrame:NSZeroRect];
    [_leftSeparator setTintColor:[[self class] separatorColor]];
    [self addSubview:_leftSeparator];
    _rightSeparator = [[HSTintedView alloc] initWithFrame:NSZeroRect];
    [_rightSeparator setTintColor:[[self class] separatorColor]];
    [self addSubview:_rightSeparator];
    [self updateSeparators];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016e0bd @ 0016e0bd, 710 bytes * /

void FUN_0016e0bd(HSCustomTabView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  id self_01;
  id self_02;
  id pvVar6;
  int local_1c;
  
  pvVar1 = _objc_msgSend(self->_header,sel_selectedColumn);
  while (pvVar2 = _objc_msgSend(self->_header,sel_numberOfColumns), pvVar2 != (id)0x0) {
    _objc_msgSend(self->_header,sel_removeColumn_,0);
  }
  pvVar2 = _objc_msgSend(self,sel_numberOfTabs);
  if (0 < (int)pvVar2) {
    local_1c = 0;
    do {
      _objc_msgSend(self->_header,sel_addColumn);
      self_00 = _objc_msgSend(self,sel_headerCellAtIndex_,local_1c);
      _objc_msgSend(self_00,sel_setHighlightsBy_,0);
      pvVar3 = _objc_msgSend(self->_content,sel_objectAtIndex_,local_1c);
      pvVar4 = _objc_msgSend(pvVar3,sel_objectForKey_,PTR_cfstr_HSCustomTabViewItemTitleKey_00342508
                            );
      if (pvVar4 != (id)0x0) {
        _objc_msgSend(self_00,sel_setTitle_,pvVar4);
      }
      pvVar4 = _objc_msgSend(pvVar3,sel_objectForKey_,PTR_cfstr_HSCustomTabViewItemImageKey_0034250c
                            );
      if (pvVar4 != (id)0x0) {
        _objc_msgSend(self_00,sel_setImage_,pvVar4);
      }
      pcVar5 = _objc_msgSend(pvVar3,sel_objectForKey_,
                             PTR_cfstr_HSCustomTabViewItemToolTipKey_00342510);
      if (pcVar5 == (cfstringStruct *)0x0) {
        pcVar5 = &cfstr_empty;
      }
      pvVar4 = self_00;
      _objc_msgSend(self->_header,sel_setToolTip_forCell_,pcVar5,self_00);
      self_01 = _objc_msgSend(pvVar3,sel_objectForKey_,
                              PTR_cfstr_HSCustomTabViewItemAccessibilityKey_00342514);
      self_02 = _objc_msgSend(self_01,sel_keyEnumerator);
      pvVar3 = _objc_msgSend(self_02,sel_nextObject);
      while (pvVar6 = pvVar3, pvVar6 != (id)0x0) {
        pvVar3 = _objc_msgSend(self_01,sel_objectForKey_,pvVar6,pvVar4);
        _objc_msgSend(self_00,sel_accessibilitySetOverrideValue_forAttribute_,pvVar3);
        pvVar3 = _objc_msgSend(self_02,sel_nextObject);
        pvVar4 = pvVar6;
      }
      local_1c = local_1c + 1;
    } while (local_1c < (int)pvVar2);
  }
  _objc_msgSend(self,sel_updateLayoutOfTabsInHeader);
  _objc_msgSend(self,sel_updateSeparators);
  _objc_msgSend(self->_header,sel_setupOnDidLoad);
  _objc_msgSend(self,sel_selectTabAtIndex_,pvVar1);
  return;
}

*/
- (void)reloadTabsInHeader
{
    NSInteger selected = [_header selectedColumn];
    while ([_header numberOfColumns] != 0) {
        [_header removeColumn:0];
    }
    NSInteger count = [self numberOfTabs];
    for (NSInteger i = 0; i < count; i++) {
        [_header addColumn];
        id cell = [self headerCellAtIndex:i];
        [cell setHighlightsBy:0];
        NSDictionary *tab = [_content objectAtIndex:i];
        id title = [tab objectForKey:@"HSCustomTabViewItemTitleKey"];
        if (title != nil) {
            [cell setTitle:title];
        }
        id image = [tab objectForKey:@"HSCustomTabViewItemImageKey"];
        if (image != nil) {
            [cell setImage:image];
        }
        NSString *toolTip = [tab objectForKey:@"HSCustomTabViewItemToolTipKey"];
        [_header setToolTip:toolTip != nil ? toolTip : @"" forCell:cell];
        NSDictionary *accessibility = [tab objectForKey:@"HSCustomTabViewItemAccessibilityKey"];
        NSEnumerator *keys = [accessibility keyEnumerator];
        id key;
        while ((key = [keys nextObject]) != nil) {
            [cell accessibilitySetOverrideValue:[accessibility objectForKey:key] forAttribute:key];
        }
    }
    [self updateLayoutOfTabsInHeader];
    [self updateSeparators];
    [_header setupOnDidLoad];
    [self selectTabAtIndex:selected];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016eb26 @ 0016eb26, 166 bytes * /

void FUN_0016eb26(HSCustomTabView *self,SEL _cmd)

{
  id pvVar1;
  double dVar2;
  undefined1 local_24 [8];
  float local_1c;
  
  pvVar1 = _objc_msgSend(self,sel_numberOfTabs);
  _objc_msgSend_stret(local_24,self,sel_frame);
  dVar2 = _objc_msgSend_fpret(self,sel_cellSizeOffset);
  _objc_msgSend(self->_header,sel_setCellSize_,
                (local_1c + -10.0) / (float)(int)pvVar1 - (float)dVar2,0x41d00000);
  return;
}

*/
- (void)updateLayoutOfTabsInHeader
{
    NSInteger count = [self numberOfTabs];
    [_header setCellSize:NSMakeSize(([self frame].size.width - 10.0) / (CGFloat)count - [self cellSizeOffset], 26.0)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016e076 @ 0016e076, 71 bytes * /

void FUN_0016e076(HSCustomTabView *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  undefined4 extraout_EDX;
  
  self_00 = self->_header;
  pvVar1 = _objc_msgSend(self,sel_frameSizeOfHeader);
  _objc_msgSend(self_00,sel_setFrameSize_,pvVar1,extraout_EDX);
  return;
}

*/
- (void)updateHeaderSize
{
    [_header setFrameSize:[self frameSizeOfHeader]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016da2e @ 0016da2e, 12 bytes * /

ulonglong FUN_0016da2e(HSCustomTabView *self,SEL _cmd)

{
  return 0x40a00000;
}

*/
- (NSPoint)headerOrigin
{
    return NSMakePoint(5.0, 0.0);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016e01e @ 0016e01e, 88 bytes * /

float FUN_0016e01e(HSCustomTabView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_headerWidthRemains);
  pvVar2 = _objc_msgSend(self,sel_numberOfTabs);
  return *(float *)(&DAT_00335688 + (uint)((int)pvVar2 / 2 < (int)pvVar1) * 4);
}

*/
- (CGFloat)cellSizeOffset
{
    return ([self numberOfTabs] / 2 < [self headerWidthRemains]) ? 0.0 : 1.0;
}

- (CGFloat)rightSeparatorOffset
{
    float fVar3;
    double dVar4;

    dVar4 = [self cellSizeOffset];
    if ((float)dVar4 == 0.0) {
        fVar3 = 0.0;
    }
    else {
        fVar3 = ((float)dVar4 * (float)(int)[self numberOfTabs] - (float)(int)[self headerWidthRemains]) * 0.5;
    }
    return fVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016dfc9 @ 0016dfc9, 85 bytes * /

int FUN_0016dfc9(HSCustomTabView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  int iVar3;
  
  pvVar1 = _objc_msgSend(self,sel_numberOfTabs);
  if (pvVar1 == (id)0x0) {
    iVar3 = 0;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_frameSizeOfHeader);
    iVar3 = (int)(float)pvVar2 % (int)pvVar1;
  }
  return iVar3;
}

*/
- (NSInteger)headerWidthRemains
{
    NSInteger count = [self numberOfTabs];
    if (count == 0) {
        return 0;
    }
    return (NSInteger)(float)[self frameSizeOfHeader].width % count;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016de62 @ 0016de62, 359 bytes * /

void FUN_0016de62(HSCustomTabView *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  
  pvVar1 = _objc_msgSend(self,sel_headerOrigin);
  pvVar2 = _objc_msgSend(self,sel_frameSizeOfHeader);
  self_00 = _objc_msgSend(cls_HSSegmentedControl,sel_alloc);
  pvVar1 = _objc_msgSend(self_00,sel_initWithFrame_,CONCAT44(extraout_EDX,pvVar1),
                         CONCAT44(extraout_EDX_00,pvVar2));
  self->_header = pvVar1;
  _objc_msgSend(self,sel_addSubview_,pvVar1);
  pvVar1 = self->_header;
  pvVar2 = _objc_msgSend(cls_HSSegmentedCell,sel_class);
  _objc_msgSend(pvVar1,sel_setCellClass_,pvVar2);
  pvVar1 = self->_header;
  pvVar2 = _objc_msgSend(cls_HSCustomTabViewBackgroundRenderer,sel_new);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  _objc_msgSend(pvVar1,sel_setBackgroundRenderer_,pvVar2);
  pvVar1 = self->_header;
  pvVar2 = _objc_msgSend(self,sel_class);
  pvVar2 = _objc_msgSend(pvVar2,sel_defaultCellFont);
  _objc_msgSend(pvVar1,sel_setFont_,pvVar2);
  return;
}

*/
- (void)createHeader
{
    _header = [[HSSegmentedControl alloc] initWithFrame:NSMakeRect([self headerOrigin].x, [self headerOrigin].y, [self frameSizeOfHeader].width, [self frameSizeOfHeader].height)];
    [self addSubview:_header];
    [_header setCellClass:[HSSegmentedCell class]];
    [_header setBackgroundRenderer:[[HSCustomTabViewBackgroundRenderer new] autorelease]];
    [_header setFont:[[self class] defaultCellFont]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016ec70 @ 0016ec70, 72 bytes * /

ulonglong FUN_0016ec70(HSCustomTabView *self,SEL _cmd)

{
  undefined1 local_1c [8];
  float local_14;
  
  _objc_msgSend_stret(local_1c,self,sel_frame);
  return CONCAT44(0x41d00000,local_14 + -10.0);
}

*/
- (NSSize)frameSizeOfHeader
{
    return NSMakeSize([self frame].size.width - 10.0, 26.0);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016de0b @ 0016de0b, 87 bytes * /

void FUN_0016de0b(HSCustomTabView *self,SEL _cmd,int selectHeaderCellAtIndex)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_header,sel_selectedColumn);
  if (pvVar1 != (id)selectHeaderCellAtIndex) {
    _objc_msgSend(self->_header,sel_selectCellAtRow_column_,0,selectHeaderCellAtIndex);
  }
  return;
}

*/
- (void)selectHeaderCellAtIndex:(NSInteger)aIndex
{
    if ([_header selectedColumn] != aIndex) {
        [_header selectCellAtRow:0 column:aIndex];
    }
}

- (id)headerCellAtIndex:(NSInteger)aIndex
{
    return [_header cellAtRow:0 column:aIndex];
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

- (void)setFont:(id)aFont
{
    [_header setFont:aFont];
}

- (id)font
{
    return [_header font];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016ecb8 @ 0016ecb8, 70 bytes * /

ulonglong FUN_0016ecb8(HSCustomTabView *self,SEL _cmd,id tabViewSizeForContentView)

{
  undefined1 local_1c [8];
  undefined4 local_14;
  float local_10;
  
  _objc_msgSend_stret(local_1c,tabViewSizeForContentView,sel_frame);
  return CONCAT44(local_10 + 26.0,local_14);
}

*/
- (NSSize)tabViewSizeForContentView:(id)aView
{
    return NSMakeSize([aView frame].size.width, [aView frame].size.height + 26.0);
}

- (NSInteger)indexOfSelectedTab
{
    return (int)[_header selectedColumn];
}

- (void)removeTabAtIndex:(NSInteger)aIndex
{
    [[self content] removeObjectAtIndex:aIndex];
    [self reloadTabsInHeader];
}

- (void)selectTabAtIndex:(NSInteger)aIndex
{
    if (aIndex == -1) {
        if ([self numberOfTabs] != 0) {
            aIndex = 0;
        }
    }
    [self selectHeaderCellAtIndex:aIndex];
    if (aIndex != -1) {
        [self mountContentViewForTabAtIndex:aIndex];
    }
}

- (void)insertTabWithTitle:(id)aTitle image:(id)aImage toolTip:(id)aTip accessibilityValues:(id)aValues contentView:(id)aView atIndex:(NSInteger)aIndex
{
    [self insertTab:[self tabDescriptionWithTitle:aTitle image:aImage toolTip:aTip accessibilityValues:aValues contentView:aView] atIndex:aIndex];
}

- (void)insertTab:(id)aTab atIndex:(NSInteger)aIndex
{
    [[self content] insertObject:aTab atIndex:aIndex];
    [self reloadTabsInHeader];
}

- (void)addTabWithTitle:(id)aTitle image:(id)aImage toolTip:(id)aTip accessibilityValues:(id)aValues contentView:(id)aView
{
    [self addTab:[self tabDescriptionWithTitle:aTitle image:aImage toolTip:aTip accessibilityValues:aValues contentView:aView]];
}

- (void)addTab:(id)aTab
{
    [self insertTab:aTab atIndex:[self numberOfTabs]];
}

- (NSInteger)numberOfTabs
{
    return (int)[_content count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0016ecfe @ 0016ecfe, 151 bytes * /

void FUN_0016ecfe(HSCustomTabView *self,SEL _cmd,NSRect setFrame)

{
  HSCustomTabView *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSView_003522e0;
  _objc_msgSendSuper(&local_14,sel_setFrame_,setFrame.origin,setFrame.size);
  _objc_msgSend(self,sel_updateLayoutOfTabsInHeader);
  _objc_msgSend(self,sel_updateHeaderSize);
  _objc_msgSend(self,sel_updateSeparators);
  _objc_msgSend(self,sel_updateContentViewSize);
  return;
}

*/
- (void)setFrame:(NSRect)aFrame
{
    [super setFrame:aFrame];
    [self updateLayoutOfTabsInHeader];
    [self updateHeaderSize];
    [self updateSeparators];
    [self updateContentViewSize];
}

- (void)awakeFromNib
{
    [self setupOnDidLoad];
}

- (void)setupOnDidLoad
{
    [self createHeader];
    [self reloadTabsInHeader];
    [self createSeparators];
    [self createContentView];
    [_header setTarget:self];
    [_header setAction:@selector(headerSelectionChanged:)];
}

- (void)dealloc
{
    [_header release];
    [_leftSeparator release];
    [_rightSeparator release];
    [_contentView release];
    [_content release];
    [super dealloc];
}

- (BOOL)isFlipped
{
    return YES;
}

@end

