#import "HSButtonImageAssistantPane.h"

@implementation HSButtonImageAssistantPane

- (BOOL)shouldEnableOKButtonInNavigationPaneSwitcher:(id)aSwitcher
{
    return (BOOL)[[self HSButtonImageAssistantPane_applier] canApplyCurrentSettings];
}

- (id)HSButtonImageAssistantPane_applier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSButtonImageAssistantPaneApplier class];
}

@end

@implementation HSButtonImageAssistantPaneApplier

/* i386 ivar offsets: _initialMedia=0xc, _initialSize=0x10, _media=0x18, _size=0x1c, _sizeController=0x24, _ignoresSizeChanges=0x28 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f951a @ 001f951a, 70 bytes * /

void FUN_001f951a(HSButtonImageAssistantPaneApplier *self,SEL _cmd,id objectSizeDidChange)

{
  id pvVar1;
  float extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_ignoresSizeChanges);
  if ((char)pvVar1 == '\0') {
    pvVar1 = _objc_msgSend(self,sel_objectSize);
    (self->_size).width = (float)pvVar1;
    (self->_size).height = extraout_EDX;
  }
  return;
}

*/
- (void)objectSizeDidChange:(id)aChange
{
    if (![self ignoresSizeChanges]) {
        _size = [self objectSize];
    }
}

- (void)setIgnoresSizeChanges:(BOOL)aChanges
{
    _ignoresSizeChanges = aChanges;
}

- (BOOL)ignoresSizeChanges
{
    return _ignoresSizeChanges;
}

- (void)setObjectSize:(NSSize)aSize
{
    [[[self object] queryHyperInterface:@protocol(HSMutableGeometryAttributes)] setSize:aSize aboutRelativePoint:NSMakePoint(0.5, 0.5)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f95dc @ 001f95dc, 86 bytes * /

ulonglong FUN_001f95dc(HSButtonImageAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0038116c);
  pvVar1 = _objc_msgSend(pvVar1,sel_size);
  return CONCAT44(extraout_EDX,pvVar1);
}

*/
- (NSSize)objectSize
{
    return [[[self object] queryHyperInterface:@protocol(HSGeometryAttributes)] size];
    return (NSSize){0};
}

- (BOOL)areSettingsEqual
{
    BOOL BVar1;

    if (_media == nil && _initialMedia == nil) {
        BVar1 = YES;
    }
    else {
        BVar1 = (BOOL)[_media isEqual:_initialMedia];
    }
    return BVar1;
}

- (BOOL)canApplyCurrentSettings
{
    return _media != nil;
}

- (void)makeCurrentEqualToInitial
{
    float fVar1;

    [_media release];
    _media = [_initialMedia retain];
    fVar1 = (_initialSize).height;
    (_size).width = (_initialSize).width;
    (_size).height = fVar1;
}

- (void)makeInitialEqualToCurrent
{
    float fVar1;

    [_initialMedia release];
    _initialMedia = [_media retain];
    fVar1 = (_size).height;
    (_initialSize).width = (_size).width;
    (_initialSize).height = fVar1;
}

- (void)setInitialSettingsToObject
{
    [[self mediaAttributes] setMedia:_initialMedia];
    [self setIgnoresSizeChanges:YES];
    [self setObjectSize:(_initialSize)];
    [self setIgnoresSizeChanges:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f97c5 @ 001f97c5, 252 bytes * /

void FUN_001f97c5(HSButtonImageAssistantPaneApplier *self,SEL _cmd)

{
  char cVar1;
  id self_00;
  float fVar2;
  
  _objc_msgSend(self,sel_setIgnoresSizeChanges_,1);
  self_00 = _objc_msgSend(self,sel_mediaAttributes);
  _objc_msgSend(self_00,sel_setMedia_,self->_media);
  fVar2 = *(float *)(PTR_0033607c + 4);
  cVar1 = _NSEqualSizes((self->_size).width,(self->_size).height,*(undefined4 *)PTR_0033607c,fVar2);
  if (cVar1 == '\0') {
    _objc_msgSend(self,sel_disableUndo);
    fVar2 = (self->_size).height;
    _objc_msgSend(self,sel_setObjectSize_,(self->_size).width,fVar2);
    _objc_msgSend(self,sel_enableUndo);
  }
  _objc_msgSend(self,sel_setIgnoresSizeChanges_,0,fVar2);
  return;
}

*/
- (void)setCurrentSettingsToObject
{
    [self setIgnoresSizeChanges:YES];
    [[self mediaAttributes] setMedia:_media];
    if (!NSEqualSizes(_size, NSZeroSize)) {
        [self disableUndo];
        [self setObjectSize:_size];
        [self enableUndo];
    }
    [self setIgnoresSizeChanges:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f98c1 @ 001f98c1, 126 bytes * /

void FUN_001f98c1(HSButtonImageAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  float extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_mediaAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_media);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_media = pvVar1;
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_initialMedia = pvVar1;
  pvVar1 = _objc_msgSend(self,sel_objectSize);
  (self->_initialSize).width = (float)pvVar1;
  (self->_initialSize).height = extraout_EDX;
  return;
}

*/
- (void)setUpInitialSettings
{
    _media = [[[self mediaAttributes] media] retain];
    _initialMedia = [_media retain];
    _initialSize = [self objectSize];
}

- (void)setMedia:(id)aMedia
{
    if (_media != aMedia) {
        [_media release];
        _media = [aMedia retain];
        [self disableUndo];
        [self setIgnoresSizeChanges:YES];
        [[self mediaAttributes] setMedia:_media];
        [self setIgnoresSizeChanges:NO];
        [self enableUndo];
    }
}

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Change Image" value:@"" table:@"UndoManager"];
}

- (id)mediaAttributes
{
    return [[self object] queryHyperInterface:@protocol(HSMediaAttributes)];
}

- (void)dealloc
{
    [_sizeController removeObserver:self selector:@selector(objectSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSSizeAttribute)];
    [_sizeController release];
    [_initialMedia release];
    [_media release];
    [super dealloc];
}

- (id)initWithObject:(id)aObject
{
    id pvVar2_3;

    self = [super initWithObject:aObject];
    if (self != nil) {
        pvVar2_3 = [[[aObject queryHyperInterface:@protocol(HSAttributes)] attributeObservingController] retain];
        _sizeController = pvVar2_3;
        [pvVar2_3 addObserver:self selector:@selector(objectSizeDidChange:) ofChanges:HSActualDidAttributeChanges ofAttribute:@protocol(HSSizeAttribute) withPriority:1.0];
    }
    return self;
}

@end

