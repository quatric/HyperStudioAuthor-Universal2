#import "HSPresentationAssistantPaneApplier.h"

static BOOL HSTolEq(float a, float b)
{
    float sa = (a != 0.0f) ? fabsf(a) : 1.0f;
    float sb = (b != 0.0f) ? fabsf(b) : 1.0f;
    float scale = (sb <= sa) ? sa : sb;
    return fabsf(a - b) <= scale * 0.0005f;
}

@implementation HSPresentationAssistantPaneApplier

/* i386 ivar offsets: _defaultBackgroundAttributes=0xc, _initialFillType=0x10, _initialFirstGradientColor=0x14, _initialSecondGradientColor=0x18, _initialSolidColor=0x1c, _initialAngle=0x20, _initialImageScaling=0x24, _initialImage=0x28, _initialPlaysWithoutTitleBar=0x2c, _initialShouldPlayInFullScreen=0x2d, _initialMenuVisible=0x2e, _initialCoveringDesktop=0x2f, _initialHyperKind=0x30, _initialHyperClear=0x34, _initialHyperCacheEnabled=0x35, _initialHyperSolid=0x36, _initialCenterX=0x38, _initialCenterY=0x3c, _currentFillType=0x40, _currentFirstGradientColor=0x44, _currentSecondGradientColor=0x48, _currentSolidColor=0x4c, _currentAngle=0x50, _currentImageScaling=0x54, _currentImage=0x58, _currentShouldPlayInFullScreen=0x5c, _currentPlaysWithoutTitleBar=0x5d, _currentMenuVisible=0x5e, _currentCoveringDesktop=0x5f, _currentHyperKind=0x60, _currentHyperClear=0x64, _currentHyperCacheEnabled=0x65, _currentHyperSolid=0x66, _currentCenterX=0x68, _currentCenterY=0x6c, _mutableBackgroundImageInterface=0x70, _mutableBackgroundColorInterface=0x74 */

- (id)hyperObject
{
    return [self object];
}

- (id)undoManagerForGraphics:(id)aGraphics
{
    return nil;
}

- (void)hyperVisualAttributesChanged:(id)aChanged
{

}

- (void)refreshDefaultBackgroundAttributes
{
    [_defaultBackgroundAttributes release];
    _defaultBackgroundAttributes = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f729d @ 001f729d, 388 bytes * /

int FUN_001f729d(HSPresentationAssistantPaneApplier *self,SEL _cmd,id fillTypeFromInterface)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  pvVar1 = _objc_msgSend(fillTypeFromInterface,sel_backgroundGraphics);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(fillTypeFromInterface,sel_backgroundGraphics);
    pvVar2 = _objc_msgSend(cls_HSGraphics,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_isMemberOfClass_,pvVar2);
    if ((char)pvVar1 == '\0') goto LAB_001f7322;
  }
  fillTypeFromInterface = _objc_msgSend(self,sel_defaultBackgroundAttributes);
LAB_001f7322:
  pvVar1 = _objc_msgSend(fillTypeFromInterface,sel_backgroundGraphics);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(fillTypeFromInterface,sel_backgroundGraphics);
    pvVar2 = _objc_msgSend(cls_HSGraphics,sel_class);
    pvVar1 = _objc_msgSend(pvVar1,sel_isMemberOfClass_,pvVar2);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(fillTypeFromInterface,sel_backgroundGraphics,pvVar2);
      puVar3 = &DAT_00380c44;
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00380c44);
      if (pvVar1 != (id)0x0) {
        pvVar1 = _objc_msgSend(pvVar1,sel_isHyperSolid,puVar3);
        return ((char)pvVar1 == '\0') + 1;
      }
      pvVar1 = _objc_msgSend(fillTypeFromInterface,sel_backgroundGraphics,puVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00380bcc);
      if (pvVar1 != (id)0x0) {
        return 3;
      }
      return -1;
    }
  }
  return 1;
}

*/
- (NSInteger)fillTypeFromInterface:(id)aInterface
{
    id graphics = [aInterface backgroundGraphics];
    if (graphics == nil || [graphics isMemberOfClass:[HSGraphics class]]) {
        aInterface = [self defaultBackgroundAttributes];
    }
    graphics = [aInterface backgroundGraphics];
    if (graphics != nil && ![graphics isMemberOfClass:[HSGraphics class]]) {
        id color = [[aInterface backgroundGraphics] queryHyperInterface:@protocol(HSColor)];
        if (color != nil) {
            return ![color isHyperSolid] + 1;
        }
        if ([[aInterface backgroundGraphics] queryHyperInterface:@protocol(HSImage)] != nil) {
            return 3;
        }
        return -1;
    }
    return 1;
    return 0;
}

- (id)backgroundColorInterface
{
    id pvVar1;

    pvVar1 = _mutableBackgroundColorInterface;
    if (pvVar1 == nil) {
        pvVar1 = [[[self backgroundAttributes] backgroundGraphics] queryHyperInterface:@protocol(HSColor)];
        if (pvVar1 == nil) {
            pvVar1 = [[[self defaultBackgroundAttributes] backgroundGraphics] queryHyperInterface:@protocol(HSColor)];
        }
    }
    return pvVar1;
}

- (id)backgroundImageInterface
{
    id pvVar1;

    pvVar1 = _mutableBackgroundImageInterface;
    if (pvVar1 == nil) {
        pvVar1 = [[[self backgroundAttributes] backgroundGraphics] queryHyperInterface:@protocol(HSImage)];
        if (pvVar1 == nil) {
            pvVar1 = [[[self defaultBackgroundAttributes] backgroundGraphics] queryHyperInterface:@protocol(HSImage)];
        }
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f7070 @ 001f7070, 239 bytes * /

id FUN_001f7070(HSPresentationAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  undefined *puVar4;
  
  pvVar1 = self->_mutableBackgroundColorInterface;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_backgroundAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_backgroundGraphics);
    puVar4 = &DAT_00380c30;
    puVar3 = puVar4;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00380c30);
    self->_mutableBackgroundColorInterface = pvVar1;
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_defaultBackgroundAttributes,puVar3);
      pvVar1 = _objc_msgSend(pvVar1,sel_backgroundGraphics);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00380c30);
      self->_mutableBackgroundColorInterface = pvVar1;
      puVar3 = puVar4;
    }
    pvVar2 = _objc_msgSend(self,sel_zone,puVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_copyWithZone_,pvVar2);
    self->_mutableBackgroundColorInterface = pvVar1;
    _objc_msgSend(pvVar1,sel_setHyperOwner_,self);
    pvVar1 = self->_mutableBackgroundColorInterface;
  }
  return pvVar1;
}

*/
- (id)mutableBackgroundColorInterface
{
    if (_mutableBackgroundColorInterface == nil) {
        id color = [[[self backgroundAttributes] backgroundGraphics] queryHyperInterface:@protocol(HSMutableColor)];
        if (color == nil) {
            color = [[[[self defaultBackgroundAttributes] backgroundGraphics] queryHyperInterface:@protocol(HSMutableColor)] retain];
            color = [color autorelease];
        }
        _mutableBackgroundColorInterface = [color copyWithZone:[self zone]];
        [_mutableBackgroundColorInterface setHyperOwner:self];
    }
    return _mutableBackgroundColorInterface;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f6ef7 @ 001f6ef7, 377 bytes * /

id FUN_001f6ef7(HSPresentationAssistantPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  undefined *puVar2;
  id pvVar3;
  undefined *puVar4;
  
  pvVar1 = self->_mutableBackgroundImageInterface;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_backgroundAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_backgroundGraphics);
    puVar4 = &DAT_00380bb8;
    puVar2 = puVar4;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00380bb8);
    self->_mutableBackgroundImageInterface = pvVar1;
    if (pvVar1 == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_HSBackgroundViewRenderer,sel_new,puVar2);
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryBackgroundGraphicsInterface_,&DAT_00380bb8);
      self->_mutableBackgroundImageInterface = pvVar1;
      _objc_msgSend(pvVar1,sel_setHyperOwner_,self);
      pvVar1 = _objc_msgSend(self,sel_defaultBackgroundAttributes);
      pvVar1 = _objc_msgSend(pvVar1,sel_backgroundGraphics);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00380bb8);
      puVar2 = puVar4;
      if (pvVar1 != (id)0x0) {
        pvVar3 = self->_mutableBackgroundImageInterface;
        puVar2 = _objc_msgSend(pvVar1,sel_hyperImage,puVar4);
        _objc_msgSend(pvVar3,sel_setHyperImage_,puVar2);
      }
    }
    pvVar1 = self->_mutableBackgroundImageInterface;
    pvVar3 = _objc_msgSend(self,sel_zone,puVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_copyWithZone_,pvVar3);
    self->_mutableBackgroundImageInterface = pvVar1;
    _objc_msgSend(pvVar1,sel_setHyperOwner_,self);
    pvVar1 = self->_mutableBackgroundImageInterface;
  }
  return pvVar1;
}

*/
- (id)mutableBackgroundImageInterface
{
    if (_mutableBackgroundImageInterface == nil) {
        _mutableBackgroundImageInterface = [[[[self backgroundAttributes] backgroundGraphics] queryHyperInterface:@protocol(HSMutableImage)] retain];
        if (_mutableBackgroundImageInterface == nil) {
            _mutableBackgroundImageInterface = [[[[HSBackgroundViewRenderer new] autorelease] queryBackgroundGraphicsInterface:@protocol(HSMutableImage)] retain];
            [_mutableBackgroundImageInterface setHyperOwner:self];
            id defaultImage = [[[self defaultBackgroundAttributes] backgroundGraphics] queryHyperInterface:@protocol(HSMutableImage)];
            if (defaultImage != nil) {
                [_mutableBackgroundImageInterface setHyperImage:[defaultImage hyperImage]];
            }
        }
        id copy = [_mutableBackgroundImageInterface copyWithZone:[self zone]];
        _mutableBackgroundImageInterface = copy;
        [_mutableBackgroundImageInterface setHyperOwner:self];
    }
    return _mutableBackgroundImageInterface;
    return 0;
}

- (void)setHyperImage:(id)aImage
{
    if (_currentImage != aImage) {
        [_currentImage release];
        _currentImage = [aImage retain];
    }
}

- (id)hyperImage
{
    return _currentImage;
}

- (void)setHyperImageFromPath:(id)aPath
{
    [[self mutableBackgroundImageInterface] setHyperImageFromPath:aPath];
    [_currentImage autorelease];
    _currentImage = [[[self mutableBackgroundImageInterface] hyperImage] retain];
}

- (void)setHyperImageScaling:(NSInteger)aScaling
{
    _currentImageScaling = aScaling;
}

- (NSInteger)hyperImageScaling
{
    return _currentImageScaling;
}

- (void)hyperSwapGradientColors
{
    id pvVar1;

    pvVar1 = _currentFirstGradientColor;
    _currentFirstGradientColor = _currentSecondGradientColor;
    _currentSecondGradientColor = pvVar1;
}

- (void)setHyperCenterX:(CGFloat)aX andY:(CGFloat)aY
{
    _currentCenterX = aX;
    _currentCenterY = aY;
}

- (CGFloat)hyperCenterY
{
    return (float)[[self backgroundColorInterface] hyperCenterY];
}

- (CGFloat)hyperCenterX
{
    return (float)[[self backgroundColorInterface] hyperCenterX];
}

- (void)setHyperCacheEnabled:(BOOL)aEnabled
{
    _currentHyperCacheEnabled = aEnabled;
}

- (BOOL)isHyperCacheEnabled
{
    return (BOOL)[[self backgroundColorInterface] isHyperCacheEnabled];
}

- (void)setHyperKind:(NSInteger)aKind
{
    _currentHyperKind = aKind;
}

- (NSInteger)hyperKind
{
    return (int)[[self backgroundColorInterface] hyperKind];
}

- (void)setHyperSolid:(BOOL)aSolid
{
    _currentHyperSolid = aSolid;
}

- (BOOL)isHyperSolid
{
    return (BOOL)[[self backgroundColorInterface] isHyperSolid];
}

- (void)setHyperClear:(BOOL)aClear
{
    _currentHyperClear = aClear;
}

- (BOOL)isHyperClear
{
    return (BOOL)[[self backgroundColorInterface] isHyperClear];
}

- (void)setHyperAngle:(CGFloat)aAngle
{
    _currentAngle = aAngle;
}

- (CGFloat)hyperAngle
{
    return _currentAngle;
}

- (void)setHyperEndColor:(id)aColor
{
    if (_currentSecondGradientColor != aColor) {
        [_currentSecondGradientColor release];
        _currentSecondGradientColor = [aColor retain];
    }
}

- (id)hyperEndColor
{
    return _currentSecondGradientColor;
}

- (void)setHyperStartColor:(id)aColor
{
    if (_currentFirstGradientColor != aColor) {
        [_currentFirstGradientColor release];
        _currentFirstGradientColor = [aColor retain];
    }
}

- (id)hyperStartColor
{
    return _currentFirstGradientColor;
}

- (void)setHyperSolidColor:(id)aColor
{
    if (_currentSolidColor != aColor) {
        [_currentSolidColor release];
        _currentSolidColor = [aColor retain];
    }
}

- (id)hyperSolidColor
{
    return _currentSolidColor;
}

- (void)setFillType:(NSInteger)aType
{
    _currentFillType = aType;
}

- (NSInteger)fillType
{
    return _currentFillType;
}

- (void)setPresentationMenuVisible:(BOOL)aVisible
{
    _currentMenuVisible = aVisible;
    [self disableUndo];
    [[self stackAttributes] setPresentationMenuVisible:_currentMenuVisible];
    [self enableUndo];
}

- (BOOL)isPresentationMenuVisible
{
    return _currentMenuVisible;
}

- (void)setPresentationCoveringDesktop:(BOOL)aDesktop
{
    _currentCoveringDesktop = aDesktop;
    [self disableUndo];
    [[self stackAttributes] setPresentationCoveringDesktopMode:_currentCoveringDesktop];
    [self enableUndo];
}

- (BOOL)isPresentationCoveringDesktop
{
    return _currentCoveringDesktop;
}

- (void)setShouldPlayInFullScreen:(BOOL)aScreen
{
    _currentShouldPlayInFullScreen = aScreen;
    [self disableUndo];
    [[self stackAttributes] setShouldPlayInFullScreen:_currentShouldPlayInFullScreen];
    [self enableUndo];
}

- (BOOL)shouldPlayInFullScreen
{
    return _currentShouldPlayInFullScreen;
}

- (void)setPresentationPlaysWithoutTitleBar:(BOOL)aBar
{
    _currentPlaysWithoutTitleBar = aBar;
    [self disableUndo];
    [[self stackAttributes] setPresentationPlaysWithoutTitleBar:_currentPlaysWithoutTitleBar];
    [self enableUndo];
}

- (BOOL)isPresentationPlaysWithoutTitleBar
{
    return _currentPlaysWithoutTitleBar;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f67ee @ 001f67ee, 675 bytes * /

BOOL FUN_001f67ee(HSPresentationAssistantPaneApplier *self,SEL _cmd)

{
  float fVar1;
  float fVar2;
  id pvVar3;
  bool bVar4;
  float fVar5;
  float fVar6;
  
  if (self->_initialFillType == self->_currentFillType) {
    fVar1 = self->_initialAngle;
    fVar2 = self->_currentAngle;
    if ((fVar1 != 0.0) || (NAN(fVar1))) {
      fVar5 = ABS(fVar1);
    }
    else {
      fVar5 = 1.0;
    }
    if ((fVar2 != 0.0) || (NAN(fVar2))) {
      fVar6 = ABS(fVar2);
    }
    else {
      fVar6 = 1.0;
    }
    if (fVar6 <= fVar5) {
      fVar6 = fVar5;
    }
    if (((((((ABS(fVar1 - fVar2) <= fVar6 * 0.0005) &&
            (self->_initialImageScaling == self->_currentImageScaling)) &&
           (self->_initialShouldPlayInFullScreen == self->_currentShouldPlayInFullScreen)) &&
          ((self->_initialPlaysWithoutTitleBar == self->_currentPlaysWithoutTitleBar &&
           (self->_initialMenuVisible == self->_currentMenuVisible)))) &&
         ((self->_initialCoveringDesktop == self->_currentCoveringDesktop &&
          ((self->_initialHyperKind == self->_currentHyperKind &&
           (self->_initialHyperClear == self->_currentHyperClear)))))) &&
        (self->_initialHyperCacheEnabled == self->_currentHyperCacheEnabled)) &&
       (self->_initialHyperSolid == self->_currentHyperSolid)) {
      fVar1 = self->_initialCenterX;
      fVar2 = self->_currentCenterX;
      if ((fVar1 != 0.0) || (NAN(fVar1))) {
        fVar5 = ABS(fVar1);
      }
      else {
        fVar5 = 1.0;
      }
      if ((fVar2 != 0.0) || (NAN(fVar2))) {
        fVar6 = ABS(fVar2);
      }
      else {
        fVar6 = 1.0;
      }
      if (fVar6 <= fVar5) {
        fVar6 = fVar5;
      }
      if (ABS(fVar1 - fVar2) <= fVar6 * 0.0005) {
        fVar1 = self->_initialCenterY;
        fVar2 = self->_currentCenterY;
        if ((fVar1 != 0.0) || (NAN(fVar1))) {
          fVar5 = ABS(fVar1);
        }
        else {
          fVar5 = 1.0;
        }
        if ((fVar2 != 0.0) || (NAN(fVar2))) {
          fVar6 = ABS(fVar2);
        }
        else {
          fVar6 = 1.0;
        }
        if (fVar6 <= fVar5) {
          fVar6 = fVar5;
        }
        if (ABS(fVar1 - fVar2) <= fVar6 * 0.0005) {
          bVar4 = true;
          goto LAB_001f69b3;
        }
      }
    }
  }
  bVar4 = false;
LAB_001f69b3:
  if ((self->_initialFirstGradientColor != (id)0x0) || (self->_currentFirstGradientColor != (id)0x0)
     ) {
    if ((bVar4 == false) ||
       (pvVar3 = _objc_msgSend(self->_initialFirstGradientColor,sel_isEqual_,
                               self->_currentFirstGradientColor), (char)pvVar3 == '\0')) {
      bVar4 = false;
    }
    else {
      bVar4 = true;
    }
  }
  if ((self->_initialSecondGradientColor != (id)0x0) ||
     (self->_currentSecondGradientColor != (id)0x0)) {
    if ((bVar4 == false) ||
       (pvVar3 = _objc_msgSend(self->_initialSecondGradientColor,sel_isEqual_,
                               self->_currentSecondGradientColor), (char)pvVar3 == '\0')) {
      bVar4 = false;
    }
    else {
      bVar4 = true;
    }
  }
  if ((self->_initialSolidColor != (id)0x0) || (self->_currentSolidColor != (id)0x0)) {
    if ((bVar4 == false) ||
       (pvVar3 = _objc_msgSend(self->_initialSolidColor,sel_isEqual_,self->_currentSolidColor),
       (char)pvVar3 == '\0')) {
      bVar4 = false;
    }
    else {
      bVar4 = true;
    }
  }
  if ((self->_initialImage != (id)0x0) || (self->_currentImage != (id)0x0)) {
    if (bVar4 == false) {
      bVar4 = false;
    }
    else {
      pvVar3 = _objc_msgSend(self->_initialImage,sel_isEqual_,self->_currentImage);
      bVar4 = (char)pvVar3 != '\0';
    }
  }
  return bVar4;
}

*/
- (BOOL)areSettingsEqual
{
    BOOL equal = NO;
    if (_initialFillType == _currentFillType &&
        HSTolEq(_initialAngle, _currentAngle) &&
        _initialImageScaling == _currentImageScaling &&
        _initialShouldPlayInFullScreen == _currentShouldPlayInFullScreen &&
        _initialPlaysWithoutTitleBar == _currentPlaysWithoutTitleBar &&
        _initialMenuVisible == _currentMenuVisible &&
        _initialCoveringDesktop == _currentCoveringDesktop &&
        _initialHyperKind == _currentHyperKind &&
        _initialHyperClear == _currentHyperClear &&
        _initialHyperCacheEnabled == _currentHyperCacheEnabled &&
        _initialHyperSolid == _currentHyperSolid &&
        HSTolEq(_initialCenterX, _currentCenterX) &&
        HSTolEq(_initialCenterY, _currentCenterY)) {
        equal = YES;
    }
    if (_initialFirstGradientColor != nil || _currentFirstGradientColor != nil) {
        equal = equal && [_initialFirstGradientColor isEqual:_currentFirstGradientColor];
    }
    if (_initialSecondGradientColor != nil || _currentSecondGradientColor != nil) {
        equal = equal && [_initialSecondGradientColor isEqual:_currentSecondGradientColor];
    }
    if (_initialSolidColor != nil || _currentSolidColor != nil) {
        equal = equal && [_initialSolidColor isEqual:_currentSolidColor];
    }
    if (_initialImage != nil || _currentImage != nil) {
        equal = equal && [_initialImage isEqual:_currentImage];
    }
    return equal;
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    _currentPlaysWithoutTitleBar = _initialPlaysWithoutTitleBar;
    _currentShouldPlayInFullScreen = _initialShouldPlayInFullScreen;
    _currentMenuVisible = _initialMenuVisible;
    _currentCoveringDesktop = _initialCoveringDesktop;
    _currentFillType = _initialFillType;
    [_currentFirstGradientColor autorelease];
    _currentFirstGradientColor = [_initialFirstGradientColor retain];
    [_currentSecondGradientColor autorelease];
    _currentSecondGradientColor = [_initialSecondGradientColor retain];
    [_currentSolidColor autorelease];
    _currentSolidColor = [_initialSolidColor retain];
    _currentAngle = _initialAngle;
    _currentImageScaling = _initialImageScaling;
    [_currentImage autorelease];
    _currentImage = [_initialImage retain];
    _currentHyperKind = _initialHyperKind;
    _currentHyperClear = _initialHyperClear;
    _currentHyperSolid = _initialHyperSolid;
    _currentHyperCacheEnabled = _initialHyperCacheEnabled;
    _currentCenterX = _initialCenterX;
    _currentCenterY = _initialCenterY;
}

- (void)makeInitialEqualToCurrent
{
    _initialPlaysWithoutTitleBar = _currentPlaysWithoutTitleBar;
    _initialShouldPlayInFullScreen = _currentShouldPlayInFullScreen;
    _initialMenuVisible = _currentMenuVisible;
    _initialCoveringDesktop = _currentCoveringDesktop;
    _initialFillType = _currentFillType;
    [_initialFirstGradientColor autorelease];
    _initialFirstGradientColor = [_currentFirstGradientColor retain];
    [_initialSecondGradientColor autorelease];
    _initialSecondGradientColor = [_currentSecondGradientColor retain];
    [_initialSolidColor autorelease];
    _initialSolidColor = [_currentSolidColor retain];
    _initialAngle = _currentAngle;
    _initialImageScaling = _currentImageScaling;
    [_initialImage autorelease];
    _initialImage = [_currentImage retain];
    _initialHyperKind = _currentHyperKind;
    _initialHyperClear = _currentHyperClear;
    _initialHyperSolid = _currentHyperSolid;
    _initialHyperCacheEnabled = _currentHyperCacheEnabled;
    _initialCenterX = _currentCenterX;
    _initialCenterY = _currentCenterY;
}

- (void)enableNotifications
{
    [super enableNotifications];
    [[self stackAttributes] flushPresentationNotifications];
}

- (void)disableNotifications
{
    [[self stackAttributes] suspendPresentationNotifications];
    [super disableNotifications];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f637f @ 001f637f, 547 bytes * /

void FUN_001f637f(HSPresentationAssistantPaneApplier *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar2 = _objc_msgSend(self,sel_stackAttributes);
  _objc_msgSend(pvVar2,sel_setPresentationPlaysWithoutTitleBar_,
                (int)self->_initialPlaysWithoutTitleBar);
  pvVar3 = _objc_msgSend(self,sel_stackAttributes);
  pvVar2 = (id)(int)self->_initialMenuVisible;
  _objc_msgSend(pvVar3,sel_setPresentationMenuVisible_,pvVar2);
  if (self->_initialCoveringDesktop == '\0') {
LAB_001f63ef:
    pvVar3 = (id)0x0;
  }
  else {
    iVar1 = self->_initialFillType;
    if (iVar1 == 3) {
      pvVar3 = _objc_msgSend(self,sel_mutableBackgroundImageInterface,pvVar2);
      _objc_msgSend(pvVar3,sel_setHyperImageScaling_,self->_initialImageScaling);
      pvVar2 = self->_initialImage;
      op = sel_setHyperImage_;
    }
    else if (iVar1 == 2) {
      pvVar3 = _objc_msgSend(self,sel_mutableBackgroundColorInterface,pvVar2);
      _objc_msgSend(pvVar3,sel_setHyperStartColor_,self->_initialFirstGradientColor);
      _objc_msgSend(pvVar3,sel_setHyperEndColor_,self->_initialSecondGradientColor);
      _objc_msgSend(pvVar3,sel_setHyperKind_,self->_initialHyperKind);
      _objc_msgSend(pvVar3,sel_setHyperAngle_,self->_initialAngle);
      _objc_msgSend(pvVar3,sel_setHyperClear_,(int)self->_initialHyperClear);
      _objc_msgSend(pvVar3,sel_setHyperCacheEnabled_,(int)self->_initialHyperCacheEnabled);
      pvVar2 = (id)self->_initialCenterX;
      op = sel_setHyperCenterX_andY_;
    }
    else {
      if (iVar1 != 1) goto LAB_001f63ef;
      pvVar3 = _objc_msgSend(self,sel_mutableBackgroundColorInterface,pvVar2);
      pvVar2 = self->_initialSolidColor;
      op = sel_setHyperSolidColor_;
    }
    _objc_msgSend(pvVar3,op,pvVar2);
  }
  pvVar2 = _objc_msgSend(self,sel_backgroundAttributes,pvVar2);
  _objc_msgSend(pvVar2,sel_setBackgroundGraphics_,pvVar3);
  pvVar2 = _objc_msgSend(self,sel_stackAttributes);
  _objc_msgSend(pvVar2,sel_setShouldPlayInFullScreen_,(int)self->_initialShouldPlayInFullScreen);
  return;
}

*/
- (void)setInitialSettingsToObject
{
    [[self stackAttributes] setPresentationPlaysWithoutTitleBar:_initialPlaysWithoutTitleBar];
    [[self stackAttributes] setPresentationMenuVisible:_initialMenuVisible];
    id graphics = nil;
    if (_initialCoveringDesktop) {
        if (_initialFillType == 3) {
            graphics = [self mutableBackgroundImageInterface];
            [graphics setHyperImageScaling:_initialImageScaling];
            [graphics setHyperImage:_initialImage];
        } else if (_initialFillType == 2) {
            graphics = [self mutableBackgroundColorInterface];
            [graphics setHyperStartColor:_initialFirstGradientColor];
            [graphics setHyperEndColor:_initialSecondGradientColor];
            [graphics setHyperKind:_initialHyperKind];
            [graphics setHyperAngle:_initialAngle];
            [graphics setHyperClear:_initialHyperClear];
            [graphics setHyperCacheEnabled:_initialHyperCacheEnabled];
            [graphics setHyperCenterX:_initialCenterX andY:_initialCenterY];
        } else if (_initialFillType == 1) {
            graphics = [self mutableBackgroundColorInterface];
            [graphics setHyperSolidColor:_initialSolidColor];
        }
    }
    [[self backgroundAttributes] setBackgroundGraphics:graphics];
    [[self stackAttributes] setShouldPlayInFullScreen:_initialShouldPlayInFullScreen];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f6137 @ 001f6137, 584 bytes * /

void FUN_001f6137(HSPresentationAssistantPaneApplier *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  SEL op;
  
  pvVar2 = _objc_msgSend(self,sel_stackAttributes);
  _objc_msgSend(pvVar2,sel_setPresentationPlaysWithoutTitleBar_,
                (int)self->_currentPlaysWithoutTitleBar);
  pvVar2 = _objc_msgSend(self,sel_stackAttributes);
  pvVar3 = (id)(int)self->_currentMenuVisible;
  _objc_msgSend(pvVar2,sel_setPresentationMenuVisible_,pvVar3);
  if (self->_currentCoveringDesktop == '\0') {
LAB_001f61a7:
    self_00 = (id)0x0;
    pvVar2 = pvVar3;
  }
  else {
    iVar1 = self->_currentFillType;
    if (iVar1 == 3) {
      self_00 = _objc_msgSend(self,sel_mutableBackgroundImageInterface,pvVar3);
      _objc_msgSend(self_00,sel_setHyperImageScaling_,self->_currentImageScaling);
      pvVar2 = self->_currentImage;
      op = sel_setHyperImage_;
    }
    else if (iVar1 == 2) {
      self_00 = _objc_msgSend(self,sel_mutableBackgroundColorInterface,pvVar3);
      _objc_msgSend(self_00,sel_setHyperStartColor_,self->_currentFirstGradientColor);
      _objc_msgSend(self_00,sel_setHyperEndColor_,self->_currentSecondGradientColor);
      _objc_msgSend(self_00,sel_setHyperAngle_,self->_currentAngle);
      _objc_msgSend(self_00,sel_setHyperKind_,self->_currentHyperKind);
      _objc_msgSend(self_00,sel_setHyperClear_,(int)self->_currentHyperClear);
      _objc_msgSend(self_00,sel_setHyperCacheEnabled_,(int)self->_currentHyperCacheEnabled);
      pvVar2 = (id)self->_currentCenterX;
      op = sel_setHyperCenterX_andY_;
    }
    else {
      if (iVar1 != 1) goto LAB_001f61a7;
      self_00 = _objc_msgSend(self,sel_mutableBackgroundColorInterface,pvVar3);
      pvVar2 = self->_currentSolidColor;
      op = sel_setHyperSolidColor_;
      if (pvVar2 == (id)0x0) {
        pvVar2 = _objc_msgSend(cls_NSColor,sel_blackColor,pvVar3);
        op = sel_setHyperSolidColor_;
      }
    }
    _objc_msgSend(self_00,op,pvVar2);
  }
  pvVar2 = _objc_msgSend(self,sel_backgroundAttributes,pvVar2);
  _objc_msgSend(pvVar2,sel_setBackgroundGraphics_,self_00);
  pvVar2 = _objc_msgSend(self,sel_stackAttributes);
  _objc_msgSend(pvVar2,sel_setShouldPlayInFullScreen_,(int)self->_currentShouldPlayInFullScreen);
  return;
}

*/
- (void)setCurrentSettingsToObject
{
    [[self stackAttributes] setPresentationPlaysWithoutTitleBar:_currentPlaysWithoutTitleBar];
    [[self stackAttributes] setPresentationMenuVisible:_currentMenuVisible];
    id graphics = nil;
    if (_currentCoveringDesktop) {
        if (_currentFillType == 3) {
            graphics = [self mutableBackgroundImageInterface];
            [graphics setHyperImageScaling:_currentImageScaling];
            [graphics setHyperImage:_currentImage];
        } else if (_currentFillType == 2) {
            graphics = [self mutableBackgroundColorInterface];
            [graphics setHyperStartColor:_currentFirstGradientColor];
            [graphics setHyperEndColor:_currentSecondGradientColor];
            [graphics setHyperAngle:_currentAngle];
            [graphics setHyperKind:_currentHyperKind];
            [graphics setHyperClear:_currentHyperClear];
            [graphics setHyperCacheEnabled:_currentHyperCacheEnabled];
            [graphics setHyperCenterX:_currentCenterX andY:_currentCenterY];
        } else if (_currentFillType == 1) {
            graphics = [self mutableBackgroundColorInterface];
            [graphics setHyperSolidColor:(_currentSolidColor != nil) ? _currentSolidColor : [NSColor blackColor]];
        }
    }
    [[self backgroundAttributes] setBackgroundGraphics:graphics];
    [[self stackAttributes] setShouldPlayInFullScreen:_currentShouldPlayInFullScreen];
}

- (void)dealloc
{
    [_defaultBackgroundAttributes release];
    [_mutableBackgroundColorInterface release];
    [_mutableBackgroundImageInterface release];
    [_initialFirstGradientColor release];
    [_initialSecondGradientColor release];
    [_initialSolidColor release];
    [_initialImage release];
    [_currentFirstGradientColor release];
    [_currentSecondGradientColor release];
    [_currentSolidColor release];
    [_currentImage release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f76c7 @ 001f76c7, 1057 bytes * /

id FUN_001f76c7(HSPresentationAssistantPaneApplier *self,SEL _cmd,id initWithObject)

{
  int iVar1;
  undefined1 uVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  double dVar5;
  HSPresentationAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSAssistantPaneApplier_003543b0;
  self_00 = _objc_msgSendSuper(&local_14,sel_initWithObject_,initWithObject);
  if (self_00 == (id)0x0) {
    return (id)0x0;
  }
  pvVar3 = _objc_msgSend(self_00,sel_stackAttributes);
  pvVar3 = _objc_msgSend(pvVar3,sel_shouldPlayInFullScreen);
  *(char *)((int)self_00 + 0x5c) = (char)pvVar3;
  *(char *)((int)self_00 + 0x2d) = (char)pvVar3;
  pvVar3 = _objc_msgSend(self_00,sel_stackAttributes);
  pvVar3 = _objc_msgSend(pvVar3,sel_isPresentationPlaysWithoutTitleBar);
  *(char *)((int)self_00 + 0x5d) = (char)pvVar3;
  *(char *)((int)self_00 + 0x2c) = (char)pvVar3;
  pvVar3 = _objc_msgSend(self_00,sel_stackAttributes);
  pvVar3 = _objc_msgSend(pvVar3,sel_isPresentationMenuVisible);
  *(char *)((int)self_00 + 0x5e) = (char)pvVar3;
  *(char *)((int)self_00 + 0x2e) = (char)pvVar3;
  pvVar3 = _objc_msgSend(self_00,sel_backgroundAttributes);
  pvVar4 = _objc_msgSend(self_00,sel_fillTypeFromInterface_,pvVar3);
  *(id *)((int)self_00 + 0x40) = pvVar4;
  *(id *)((int)self_00 + 0x10) = pvVar4;
  pvVar4 = _objc_msgSend(self_00,sel_stackAttributes);
  pvVar4 = _objc_msgSend(pvVar4,sel_isPresentationCoveringDesktopMode);
  if ((char)pvVar4 != '\0') {
    pvVar3 = _objc_msgSend(self_00,sel_backgroundAttributes,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_backgroundGraphics);
    if (pvVar3 != (id)0x0) {
      uVar2 = 1;
      goto LAB_001f780c;
    }
  }
  uVar2 = 0;
LAB_001f780c:
  *(undefined1 *)((int)self_00 + 0x5f) = uVar2;
  *(undefined1 *)((int)self_00 + 0x2f) = uVar2;
  iVar1 = *(int *)((int)self_00 + 0x10);
  if (iVar1 == 3) {
    pvVar3 = _objc_msgSend(self_00,sel_backgroundImageInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperImageScaling);
    *(id *)((int)self_00 + 0x54) = pvVar3;
    *(id *)((int)self_00 + 0x24) = pvVar3;
    pvVar3 = _objc_msgSend(self_00,sel_backgroundImageInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperImage);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    *(id *)((int)self_00 + 0x28) = pvVar3;
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    *(id *)((int)self_00 + 0x58) = pvVar3;
  }
  else if (iVar1 == 2) {
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperStartColor);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    *(id *)((int)self_00 + 0x14) = pvVar3;
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    *(id *)((int)self_00 + 0x44) = pvVar3;
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperEndColor);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    *(id *)((int)self_00 + 0x18) = pvVar3;
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    *(id *)((int)self_00 + 0x48) = pvVar3;
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    dVar5 = _objc_msgSend_fpret(pvVar3,sel_hyperAngle);
    *(float *)((int)self_00 + 0x50) = (float)dVar5;
    *(float *)((int)self_00 + 0x20) = (float)dVar5;
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperKind);
    *(id *)((int)self_00 + 0x60) = pvVar3;
    *(id *)((int)self_00 + 0x30) = pvVar3;
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_isHyperClear);
    *(char *)((int)self_00 + 100) = (char)pvVar3;
    *(char *)((int)self_00 + 0x34) = (char)pvVar3;
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_isHyperSolid);
    *(char *)((int)self_00 + 0x66) = (char)pvVar3;
    *(char *)((int)self_00 + 0x36) = (char)pvVar3;
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_isHyperCacheEnabled);
    *(char *)((int)self_00 + 0x65) = (char)pvVar3;
    *(char *)((int)self_00 + 0x35) = (char)pvVar3;
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    dVar5 = _objc_msgSend_fpret(pvVar3,sel_hyperCenterX);
    *(float *)((int)self_00 + 0x68) = (float)dVar5;
    *(float *)((int)self_00 + 0x38) = (float)dVar5;
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    dVar5 = _objc_msgSend_fpret(pvVar3,sel_hyperCenterY);
    *(float *)((int)self_00 + 0x6c) = (float)dVar5;
    *(float *)((int)self_00 + 0x3c) = (float)dVar5;
  }
  else if (iVar1 == 1) {
    pvVar3 = _objc_msgSend(self_00,sel_backgroundColorInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperSolidColor);
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    *(id *)((int)self_00 + 0x1c) = pvVar3;
    pvVar3 = _objc_msgSend(pvVar3,sel_retain);
    *(id *)((int)self_00 + 0x4c) = pvVar3;
  }
  return self_00;
}

*/
- (id)initWithObject:(id)aObject
{
    self = [super initWithObject:aObject];
    if (self == nil) {
        return nil;
    }
    _initialShouldPlayInFullScreen = _currentShouldPlayInFullScreen = [[self stackAttributes] shouldPlayInFullScreen];
    _initialPlaysWithoutTitleBar = _currentPlaysWithoutTitleBar = [[self stackAttributes] isPresentationPlaysWithoutTitleBar];
    _initialMenuVisible = _currentMenuVisible = [[self stackAttributes] isPresentationMenuVisible];
    id background = [self backgroundAttributes];
    _initialFillType = _currentFillType = [self fillTypeFromInterface:background];
    BOOL covering = ([[self stackAttributes] isPresentationCoveringDesktopMode] && [[self backgroundAttributes] backgroundGraphics] != nil);
    _initialCoveringDesktop = _currentCoveringDesktop = covering;
    if (_initialFillType == 3) {
        _initialImageScaling = _currentImageScaling = [[self backgroundImageInterface] hyperImageScaling];
        _initialImage = [[[self backgroundImageInterface] hyperImage] retain];
        _currentImage = [_initialImage retain];
    } else if (_initialFillType == 2) {
        _initialFirstGradientColor = [[[self backgroundColorInterface] hyperStartColor] retain];
        _currentFirstGradientColor = [_initialFirstGradientColor retain];
        _initialSecondGradientColor = [[[self backgroundColorInterface] hyperEndColor] retain];
        _currentSecondGradientColor = [_initialSecondGradientColor retain];
        _initialAngle = _currentAngle = [[self backgroundColorInterface] hyperAngle];
        _initialHyperKind = _currentHyperKind = [[self backgroundColorInterface] hyperKind];
        _initialHyperClear = _currentHyperClear = [[self backgroundColorInterface] isHyperClear];
        _initialHyperSolid = _currentHyperSolid = [[self backgroundColorInterface] isHyperSolid];
        _initialHyperCacheEnabled = _currentHyperCacheEnabled = [[self backgroundColorInterface] isHyperCacheEnabled];
        _initialCenterX = _currentCenterX = [[self backgroundColorInterface] hyperCenterX];
        _initialCenterY = _currentCenterY = [[self backgroundColorInterface] hyperCenterY];
    } else if (_initialFillType == 1) {
        _initialSolidColor = [[[self backgroundColorInterface] hyperSolidColor] retain];
        _currentSolidColor = [_initialSolidColor retain];
    }
    return self;
    return 0;
}

- (id)undoActionName
{
    return [[NSBundle mainBundle] localizedStringForKey:@"Change Background Settings" value:@"" table:@"UndoManager"];
}

- (id)stackAttributes
{
    return [[self object] queryHyperInterface:@protocol(HSMutableStackAttributes)];
}

- (id)defaultBackgroundAttributes
{
    id pvVar1;
    id pvVar2;
    id pvVar1_3;

    pvVar1 = _defaultBackgroundAttributes;
    if (pvVar1 == nil) {
        pvVar1_3 = [[HSUI sharedUI] backgroundGraphics];
        pvVar2 = [HSBackgroundViewRenderer new];
        _defaultBackgroundAttributes = pvVar2;
        [[pvVar2 queryHyperInterface:@protocol(HSMutableBackgroundAttributes)] setBackgroundGraphics:pvVar1_3];
        pvVar1 = _defaultBackgroundAttributes;
    }
    return pvVar1;
}

- (id)backgroundAttributes
{
    return [[self object] queryHyperInterface:@protocol(HSMutableBackgroundAttributes)];
}

@end

