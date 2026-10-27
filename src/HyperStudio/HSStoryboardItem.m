#import "HSStoryboardItem.h"
static id sDAT_00342830;

static id sDAT_00342830;


static BOOL HSStoryboardItemFloatsMatch(float a, float b)
{
    float scaleA = (a != 0.0f) ? fabsf(a) : 1.0f;
    float scaleB = (b != 0.0f) ? fabsf(b) : 1.0f;
    float scale = (scaleB <= scaleA) ? scaleA : scaleB;
    return fabsf(a - b) <= scale * 0.0005;
}

@implementation HSStoryboardItem

/* i386 ivar offsets: _parent=0x4, _card=0x8, _observesImageNotifications=0xc, _observesTitleNotifications=0xd, _isSelected=0xe, _isHighlighted=0xf, _cardThumbnail=0x10, _cachedItemImage=0x14, _cachedSelectedItemImage=0x18, _frame=0x1c, _sourceFrame=0x2c, _destinationFrame=0x3c, _tag=0x4c */

+ (id)placeholderImage
{
    if (sDAT_00342830 == nil) {
        sDAT_00342830 = [NSImage imageNamed:@"StoryboardPlaceholder"];
    }
    return [sDAT_00342830 retain];
}

- (void)invalidateAnimation
{
    float fVar1;
    float fVar2;
    float fVar3;
    float fVar4;

    fVar1 = (_frame).origin.x;
    (_sourceFrame).origin.x = fVar1;
    fVar2 = (_frame).origin.y;
    (_sourceFrame).origin.y = fVar2;
    fVar3 = (_frame).size.width;
    (_sourceFrame).size.width = fVar3;
    fVar4 = (_frame).size.height;
    (_sourceFrame).size.height = fVar4;
    (_destinationFrame).origin.x = fVar1;
    (_destinationFrame).origin.y = fVar2;
    (_destinationFrame).size.width = fVar3;
    (_destinationFrame).size.height = fVar4;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008c246 @ 0008c246, 229 bytes * /

void FUN_0008c246(HSStoryboardItem *self,SEL _cmd)

{
  char cVar1;
  
  cVar1 = _NSEqualRects((self->_frame).origin,(self->_frame).size,(self->_destinationFrame).origin,
                        (self->_destinationFrame).size);
  if (cVar1 == '\0') {
    cVar1 = _NSEqualRects((self->_destinationFrame).origin,(self->_destinationFrame).size,
                          *(undefined8 *)PTR_00336078,*(undefined8 *)(PTR_00336078 + 8));
    if (cVar1 == '\0') {
      _objc_msgSend(self->_parent,sel_setNeedsDisplayStoryboardItem_,self);
      (self->_frame).origin.x = (self->_destinationFrame).origin.x;
      (self->_frame).origin.y = (self->_destinationFrame).origin.y;
      (self->_frame).size.width = (self->_destinationFrame).size.width;
      (self->_frame).size.height = (self->_destinationFrame).size.height;
      _objc_msgSend(self->_parent,sel_setNeedsDisplayStoryboardItem_,self);
    }
  }
  return;
}

*/
- (void)endAnimation
{
    if (!NSEqualRects(_frame, _destinationFrame)) {
        if (!NSEqualRects(_destinationFrame, NSZeroRect)) {
            [_parent setNeedsDisplayStoryboardItem:self];
            _frame = _destinationFrame;
            [_parent setNeedsDisplayStoryboardItem:self];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008c32b @ 0008c32b, 173 bytes * /

void FUN_0008c32b(HSStoryboardItem *self,SEL _cmd,float animateWithProgress)

{
  float fVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  
  fVar1 = (self->_sourceFrame).origin.x;
  fVar2 = (self->_sourceFrame).origin.y;
  fVar5 = SQRT(animateWithProgress);
  fVar3 = (self->_sourceFrame).size.height;
  fVar4 = (self->_sourceFrame).size.width;
  _objc_msgSend(self,sel_setFrame_,
                CONCAT44(((self->_destinationFrame).origin.y - fVar2) * fVar5 + fVar2,
                         ((self->_destinationFrame).origin.x - fVar1) * fVar5 + fVar1),
                CONCAT44(((self->_destinationFrame).size.height - fVar3) * fVar5 + fVar3,
                         ((self->_destinationFrame).size.width - fVar4) * fVar5 + fVar4));
  return;
}

*/
- (void)animateWithProgress:(CGFloat)aProgress
{
    float progress = sqrtf(aProgress);
    [self setFrame:NSMakeRect((_destinationFrame.origin.x - _sourceFrame.origin.x) * progress + _sourceFrame.origin.x,
                              (_destinationFrame.origin.y - _sourceFrame.origin.y) * progress + _sourceFrame.origin.y,
                              (_destinationFrame.size.width - _sourceFrame.size.width) * progress + _sourceFrame.size.width,
                              (_destinationFrame.size.height - _sourceFrame.size.height) * progress + _sourceFrame.size.height)];
}

- (void)animateToFrame:(NSRect)aFrame
{
    (_sourceFrame).origin.x = (_frame).origin.x;
    (_sourceFrame).origin.y = (_frame).origin.y;
    (_sourceFrame).size.width = (_frame).size.width;
    (_sourceFrame).size.height = (_frame).size.height;
    (_destinationFrame).origin.x = aFrame.origin.x;
    (_destinationFrame).origin.y = aFrame.origin.y;
    (_destinationFrame).size.width = aFrame.size.width;
    (_destinationFrame).size.height = aFrame.size.height;
}

- (void)setFrame:(NSRect)aFrame
{
    float fVar1;
    float fVar2;
    float fVar3;
    float fVar4;
    float fVar5;
    float fVar6;
    float fVar7;
    float fVar8;
    float fVar6_2;
    float fVar8_2;
    float fVar7_2;
    float fVar5_2;

    fVar6 = fabs(aFrame.origin.y) + aFrame.size.height;
    fVar1 = (_frame).origin.y;
    fVar2 = (_frame).size.height;
    fVar8 = fabs(fVar1) + fVar2;
    fVar8_2 = fVar8 != 0.0 ? fabs(fVar8) : 1.0;
    fVar6_2 = fVar6 != 0.0 ? fabs(fVar6) : 1.0;
    fVar7 = fabs(aFrame.origin.x) + aFrame.size.width;
    fVar3 = (_frame).origin.x;
    fVar4 = (_frame).size.width;
    fVar5 = fabs(fVar3) + fVar4;
    if (fVar6_2 <= fVar8_2) {
        fVar6_2 = fVar8_2;
    }
    fVar5_2 = fVar5 != 0.0 ? fabs(fVar5) : 1.0;
    fVar7_2 = fVar7 != 0.0 ? fabs(fVar7) : 1.0;
    if (fVar7_2 <= fVar5_2) {
        fVar7_2 = fVar5_2;
    }
    if ((((fVar7_2 * 0.0005 < fabs(fVar3 - aFrame.origin.x)) || (fVar6_2 * 0.0005 < fabs(fVar1 - aFrame.origin.y))) || (fVar7_2 * 0.0005 < fabs(fVar4 - aFrame.size.width))) || (fVar6_2 * 0.0005 < fabs(fVar2 - aFrame.size.height))) {
        [_parent setNeedsDisplayStoryboardItem:self];
        (_frame).origin.x = aFrame.origin.x;
        (_frame).origin.y = aFrame.origin.y;
        (_frame).size.width = aFrame.size.width;
        (_frame).size.height = aFrame.size.height;
        [_parent setNeedsDisplayStoryboardItem:self];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008b5c4 @ 0008b5c4, 52 bytes * /

NSRect * FUN_0008b5c4(NSRect *__return_storage_ptr__,HSStoryboardItem *self,SEL _cmd)

{
  (__return_storage_ptr__->origin).x = (self->_frame).origin.x;
  (__return_storage_ptr__->origin).y = (self->_frame).origin.y;
  (__return_storage_ptr__->size).width = (self->_frame).size.width;
  (__return_storage_ptr__->size).height = (self->_frame).size.height;
  return (NSRect *)self;
}

*/
- (NSRect)frame
{
    return _frame;
    return (NSRect){0};
}

- (id)indexString
{
    id pvVar1;
    int iVar2;

    pvVar1 = [_card queryHyperInterface:@protocol(HSNodeAttributes)];
    if (pvVar1 == nil) {
        iVar2 = 0;
    }
    else {
        iVar2 = (int)[pvVar1 hyperIndex] + 1;
    }
    return [NSString stringWithFormat:@"%u", iVar2];
}

- (id)titleString
{
    return [_card hyperTitle];
}

- (BOOL)isHighlighted
{
    return _isHighlighted;
}

- (void)setHighlighted:(BOOL)aHighlighted
{
    if ((BOOL)_isHighlighted != (aHighlighted != NO)) {
        _isHighlighted = aHighlighted != NO;
        [self invalidateImageCaches];
        [_parent setNeedsDisplayStoryboardItem:self];
    }
}

- (BOOL)isSelected
{
    return _isSelected;
}

- (void)setSelected:(BOOL)aSelected
{
    if ((aSelected != NO) != (BOOL)_isSelected) {
        _isSelected = aSelected != NO;
        [_parent setNeedsDisplayStoryboardItem:self];
    }
}

- (void)setCachedSelectedItemImage:(id)aImage
{
    if (_cachedSelectedItemImage != aImage) {
        [_cachedSelectedItemImage release];
        _cachedSelectedItemImage = [aImage retain];
    }
}

- (id)cachedSelectedItemImage
{
    return _cachedSelectedItemImage;
}

- (void)setCachedItemImage:(id)aImage
{
    if (_cachedItemImage != aImage) {
        [_cachedItemImage release];
        _cachedItemImage = [aImage retain];
    }
}

- (id)cachedItemImage
{
    return _cachedItemImage;
}

- (void)setCardThumbnail:(id)aThumbnail
{
    [self invalidateAllImageCaches];
    _cardThumbnail = [aThumbnail retain];
}

- (id)cachedCardThumbnail
{
    return _cardThumbnail;
}

- (id)cardThumbnailForCardSize:(NSSize)aSize
{
    id pvVar1;
    id pvVar2;
    id pvVar2_2;

    [self observeNotificationsIfNeeded];
    pvVar2 = _cardThumbnail;
    if (((pvVar2 != nil) || (_parent == nil)) && (pvVar1 = [HSStoryboardItem placeholderImage], pvVar2 != pvVar1)) {
        return _cardThumbnail;
    }
    pvVar2_2 = [HSStoryboardItem placeholderImage];
    _cardThumbnail = pvVar2_2;
    return pvVar2_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008bb33 @ 0008bb33, 323 bytes * /

BOOL FUN_0008bb33(HSStoryboardItem *self,SEL _cmd,NSSize needsRenderThumbnailOfSize)

{
  bool bVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  float fVar4;
  float fVar5;
  
  pvVar3 = self->_cardThumbnail;
  if ((pvVar3 == (id)0x0) ||
     (pvVar2 = _objc_msgSend(cls_HSStoryboardItem,sel_placeholderImage), pvVar3 == pvVar2)) {
    bVar1 = true;
  }
  else {
    pvVar3 = _objc_msgSend(self->_cardThumbnail,sel_size);
    if (((float)pvVar3 != 0.0) || (NAN((float)pvVar3))) {
      fVar4 = ABS((float)pvVar3);
    }
    else {
      fVar4 = 1.0;
    }
    if ((needsRenderThumbnailOfSize.width != 0.0) || (NAN(needsRenderThumbnailOfSize.width))) {
      fVar5 = ABS(needsRenderThumbnailOfSize.width);
    }
    else {
      fVar5 = 1.0;
    }
    if (fVar5 <= fVar4) {
      fVar5 = fVar4;
    }
    if (ABS((float)pvVar3 - needsRenderThumbnailOfSize.width) <= fVar5 * 0.0005) {
      if ((extraout_EDX != 0.0) || (NAN(extraout_EDX))) {
        fVar4 = ABS(extraout_EDX);
      }
      else {
        fVar4 = 1.0;
      }
      if ((needsRenderThumbnailOfSize.height != 0.0) || (NAN(needsRenderThumbnailOfSize.height))) {
        fVar5 = ABS(needsRenderThumbnailOfSize.height);
      }
      else {
        fVar5 = 1.0;
      }
      if (fVar5 <= fVar4) {
        fVar5 = fVar4;
      }
      bVar1 = fVar5 * 0.0005 < ABS(extraout_EDX - needsRenderThumbnailOfSize.height);
    }
    else {
      bVar1 = true;
    }
  }
  return bVar1;
}

*/
- (BOOL)needsRenderThumbnailOfSize:(NSSize)aSize
{
    if (_cardThumbnail == nil || _cardThumbnail == [HSStoryboardItem placeholderImage]) {
        return YES;
    }
    NSSize size = [_cardThumbnail size];
    return !(HSStoryboardItemFloatsMatch(size.width, aSize.width) && HSStoryboardItemFloatsMatch(size.height, aSize.height));
    return 0;
}

- (void)invalidateImageCaches
{
    [_cachedItemImage release];
    _cachedItemImage = nil;
    [_cachedSelectedItemImage release];
    _cachedSelectedItemImage = nil;
}

- (void)invalidateAllImageCaches
{
    [_cardThumbnail release];
    _cardThumbnail = nil;
    [self invalidateImageCaches];
}

- (void)exportDidEnd:(id)aEnd
{
    [self observeImageNotificationsIfNeeded];
}

- (void)exportWillStart:(id)aStart
{
    if ((_card != nil) && (_observesImageNotifications != NO)) {
        [_card removeObserver:self selector:@selector(cardImageDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute)];
        _observesImageNotifications = NO;
    }
}

- (void)observeNotificationsIfNeeded
{
    [self observeImageNotificationsIfNeeded];
    [self observeTitleNotificationsIfNeeded];
}

- (void)observeTitleNotificationsIfNeeded
{
    if ((_card != nil) && (_observesTitleNotifications == NO)) {
        _observesTitleNotifications = YES;
        [_card addObserver:self selector:@selector(cardTitleDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardTitleAttribute) withPriority:-0.25];
    }
}

- (void)observeImageNotificationsIfNeeded
{
    if ((_card != nil) && (_observesImageNotifications == NO)) {
        _observesImageNotifications = YES;
        [_card addObserver:self selector:@selector(cardImageDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute) withPriority:-0.25];
    }
}

- (void)setTag:(NSInteger)aTag
{
    _tag = aTag;
}

- (NSInteger)tag
{
    return _tag;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0008b71a @ 0008b71a, 482 bytes * /

void FUN_0008b71a(HSStoryboardItem *self,SEL _cmd,id setCard)

{
  id pvVar1;
  id self_00;
  
  pvVar1 = self->_card;
  if (pvVar1 != setCard) {
    if ((pvVar1 != (id)0x0) && (self->_observesImageNotifications != '\0')) {
      _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                    sel_cardImageDidChange_,*(undefined4 *)PTR_0033601c,&DAT_003668f8);
      pvVar1 = self->_card;
    }
    if ((pvVar1 != (id)0x0) && (self->_observesTitleNotifications != '\0')) {
      _objc_msgSend(pvVar1,sel_removeObserver_selector_ofChanges_ofAttribute_,self,
                    sel_cardTitleDidChange_,*(undefined4 *)PTR_0033601c,&DAT_00366934);
    }
    self->_observesImageNotifications = '\0';
    self->_observesTitleNotifications = '\0';
    _objc_msgSend(self,sel_invalidateAllImageCaches);
    _objc_msgSend(self->_card,sel_release);
    pvVar1 = _objc_msgSend(setCard,sel_retain);
    self->_card = pvVar1;
    _objc_msgSend(self->_parent,sel_setNeedsDisplayStoryboardItem_,self);
    pvVar1 = _objc_msgSend(cls_NSDocumentController,sel_sharedDocumentController);
    pvVar1 = _objc_msgSend(pvVar1,sel_currentDocument);
    pvVar1 = _objc_msgSend(pvVar1,sel_exportManager);
    self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
    _objc_msgSend(self_00,sel_addObserver_selector_name_object_,self,sel_exportWillStart_,
                  *(undefined4 *)PTR_PTR_00336428,pvVar1);
    _objc_msgSend(self_00,sel_addObserver_selector_name_object_,self,sel_exportDidEnd_,
                  *(undefined4 *)PTR_PTR_00336424,pvVar1);
  }
  return;
}

*/
- (void)setCard:(id)aCard
{
    if (_card != aCard) {
        if (_card != nil && _observesImageNotifications) {
            [_card removeObserver:self selector:@selector(cardImageDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute)];
        }
        if (_card != nil && _observesTitleNotifications) {
            [_card removeObserver:self selector:@selector(cardTitleDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardTitleAttribute)];
        }
        _observesImageNotifications = NO;
        _observesTitleNotifications = NO;
        [self invalidateAllImageCaches];
        [_card release];
        _card = [aCard retain];
        [_parent setNeedsDisplayStoryboardItem:self];
        id exportManager = [[[NSDocumentController sharedDocumentController] currentDocument] exportManager];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(exportWillStart:) name:HSExportManagerWillStartExportNotification object:exportManager];
        [center addObserver:self selector:@selector(exportDidEnd:) name:HSExportManagerDidEndExportNotification object:exportManager];
    }
}

- (id)card
{
    return _card;
}

- (void)cardTitleDidChange:(id)aChange
{
    [self invalidateImageCaches];
    [_parent setNeedsDisplayStoryboardItem:self];
}

- (void)cardImageDidChange:(id)aChange
{
    [self invalidateAllImageCaches];
    [_parent setNeedsDisplayStoryboardItem:self];
}

- (id)parent
{
    return _parent;
}

- (void)setParent:(id)aParent
{
    _parent = aParent;
}

- (void)dealloc
{
    id pvVar1;

    pvVar1 = _card;
    if ((pvVar1 != nil) && (_observesImageNotifications != NO)) {
        [pvVar1 removeObserver:self selector:@selector(cardImageDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSVisualAttribute)];
        pvVar1 = _card;
    }
    if ((pvVar1 != nil) && (_observesTitleNotifications != NO)) {
        [pvVar1 removeObserver:self selector:@selector(cardTitleDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSCardTitleAttribute)];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_card release];
    [_cardThumbnail release];
    [_cachedItemImage release];
    [_cachedSelectedItemImage release];
    [super dealloc];
}

@end

