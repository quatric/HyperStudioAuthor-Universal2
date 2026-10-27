#import "HSEditButtonObjectDialogController.h"
static id sDAT_003429f8;

static id sDAT_003429f8;


@implementation HSEditButtonObjectDialogController

/* i386 ivar offsets: _context=0x24, _nodeSupport=0x28, _createdButtonObject=0x2c, _prototypeObjectView=0x30, _buttonTypeMatrix=0x34, _showTitleSwitch=0x38, _titleColorWell=0x3c, _backgroundColorWell=0x40, _titleTextField=0x44, _cancelButton=0x48, _invisibleLabelTextField=0x4c, _defaultButtonStyle=0x50, _defaultButtonType=0x54, _defaultNotShowTitle=0x58, _defaultTitleColor=0x5c, _defaultBackgroundColor=0x60 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fb2be @ 001fb2be, 331 bytes * /

void FUN_001fb2be(HSEditButtonObjectDialogController *self,SEL _cmd,BOOL finishDialog)

{
  id pvVar1;
  SEL op;
  cfstringStruct *pcVar2;
  HSEditButtonObjectDialogController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSGenericModalController_00354620;
  _objc_msgSendSuper(&local_1c,sel_finishDialog_,(int)finishDialog);
  if (finishDialog != 0) {
    pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
    pvVar1 = _objc_msgSend(pvVar1,sel_backgroundStyle);
    self->_defaultButtonStyle = pvVar1;
    pcVar2 = &cfstr_HSButtonObjectSystemBackgroundStyle;
    pvVar1 = _objc_msgSend(pvVar1,sel_isEqualToString_,&cfstr_HSButtonObjectSystemBackgroundStyle);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(self,sel_shapeBackgroundInterface,pcVar2);
      op = sel_shapeButtonType;
    }
    else {
      pvVar1 = _objc_msgSend(self,sel_systemBackgroundInterface,pcVar2);
      op = sel_systemButtonType;
    }
    pvVar1 = _objc_msgSend(pvVar1,op,pcVar2);
    self->_defaultButtonType = pvVar1;
    pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
    pvVar1 = _objc_msgSend(pvVar1,sel_isTitleVisible);
    self->_defaultNotShowTitle = (char)pvVar1 == '\0';
    pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
    pvVar1 = _objc_msgSend(pvVar1,sel_titleColor);
    self->_defaultTitleColor = pvVar1;
    pvVar1 = _objc_msgSend(self,sel_systemBackgroundInterface);
    pvVar1 = _objc_msgSend(pvVar1,sel_tintColor);
    self->_defaultBackgroundColor = pvVar1;
  }
  return;
}

*/
- (void)finishDialog:(BOOL)aDialog
{
    [super finishDialog:aDialog];
    if (aDialog) {
        /* the original stores these defaults without retaining them */
        _defaultButtonStyle = [[self buttonObjectInterface] backgroundStyle];
        if ([_defaultButtonStyle isEqualToString:@"HSButtonObjectSystemBackgroundStyle"]) {
            _defaultButtonType = [[self systemBackgroundInterface] systemButtonType];
        } else {
            _defaultButtonType = [[self shapeBackgroundInterface] shapeButtonType];
        }
        _defaultNotShowTitle = ![[self buttonObjectInterface] isTitleVisible];
        _defaultTitleColor = [[self buttonObjectInterface] titleColor];
        _defaultBackgroundColor = [[self systemBackgroundInterface] tintColor];
    }
}

- (void)applyShapeBackgrounStyleWithButtonType:(id)aType
{
    BOOL pvVar1;
    id pvVar2_3;

    pvVar1 = [aType isEqualToString:@"HSInvisibleShapeButtonType"];
    [[self buttonObjectInterface] setBackgroundStyle:@"HSButtonObjectShapeBackgroundStyle" needsResetRotationAngle:!pvVar1];
    [[self shapeBackgroundInterface] setShapeButtonType:aType];
    pvVar2_3 = [self systemBackgroundInterface];
    [pvVar2_3 setSystemButtonType:nil];
    if (pvVar1) {
        [[self shapeBackgroundInterface] setBorderPath:[self defaultButtonBorderPath]];
        [[self buttonObjectInterface] setContentOverlapsBackground:NO];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fafac @ 001fafac, 201 bytes * /

void FUN_001fafac(HSEditButtonObjectDialogController *self,SEL _cmd,
                 id applySystemBackgrounStyleWithButtonType)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
  _objc_msgSend(pvVar1,sel_setBackgroundStyle_,&cfstr_HSButtonObjectSystemBackgroundStyle);
  pvVar1 = _objc_msgSend(self,sel_systemBackgroundInterface);
  _objc_msgSend(pvVar1,sel_setSystemButtonType_,applySystemBackgrounStyleWithButtonType);
  pvVar1 = _objc_msgSend(self,sel_shapeBackgroundInterface);
  _objc_msgSend(pvVar1,sel_setShapeButtonType_,0);
  pvVar1 = _objc_msgSend(self,sel_buttonObjectInterface);
  _objc_msgSend(pvVar1,sel_setContentOverlapsBackground_,0);
  return;
}

*/
- (void)applySystemBackgrounStyleWithButtonType:(id)aType
{
    [[self buttonObjectInterface] setBackgroundStyle:@"HSButtonObjectSystemBackgroundStyle"];
    [[self systemBackgroundInterface] setSystemButtonType:aType];
    [[self shapeBackgroundInterface] setShapeButtonType:nil];
    [[self buttonObjectInterface] setContentOverlapsBackground:NO];
}

- (NSInteger)tagForButtonType:(id)aType
{
    int iVar2;

    if (![aType isEqualToString:@"HSRegularSystemButtonType"]) {
        if (![aType isEqualToString:@"HSDefaultSystemButtonType"]) {
            if (![aType isEqualToString:@"HSRectangleSystemButtonType"]) {
                if (![aType isEqualToString:@"HSDropShadowRectangleSystemButtonType"]) {
                    if (![aType isEqualToString:@"HSInvisibleShapeButtonType"]) {
                        if (![aType isEqualToString:@"HSFreehandAreaShapeButtonType"]) {
                            if (![aType isEqualToString:@"HSExpandingAreaShapeButtonType"]) {
                                iVar2 = (unsigned int)([aType isEqualToString:@"HSLassoAreaShapeButtonType"]) << 3;
                            }
                            else {
                                iVar2 = 7;
                            }
                        }
                        else {
                            iVar2 = 6;
                        }
                    }
                    else {
                        iVar2 = 5;
                    }
                }
                else {
                    iVar2 = 4;
                }
            }
            else {
                iVar2 = 3;
            }
        }
        else {
            iVar2 = 2;
        }
    }
    else {
        iVar2 = 1;
    }
    return iVar2;
}

- (id)shapeBackgroundInterface
{
    return [[[self nodeSupport] allObjectsInterface] queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)];
}

- (id)systemBackgroundInterface
{
    return [[[self nodeSupport] allObjectsInterface] queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)];
}

- (id)buttonObjectInterface
{
    return [[[self nodeSupport] allObjectsInterface] queryHyperInterface:@protocol(HSButtonObjectAttributes)];
}

- (void)controlTextDidChange:(id)aChange
{
    [[self buttonObjectInterface] setTitle:[[aChange object] stringValue]];
    [self updateUI];
}

- (void)backgroundColorChanged:(id)aChanged
{
    [[self systemBackgroundInterface] setTintColor:[aChanged color]];
    [self updateUI];
}

- (void)titleColorChanged:(id)aChanged
{
    [[self buttonObjectInterface] setTitleColor:[aChanged color]];
    [self updateUI];
}

- (void)showTitleStateChanged:(id)aChanged
{
    [[self buttonObjectInterface] setTitleVisible:(unsigned int)([aChanged state] == 0x1)];
    [self updateUI];
}

- (void)lassoAreaShapeButtonTypeChosen:(id)aChosen
{
    [self applyShapeBackgrounStyleWithButtonType:@"HSLassoAreaShapeButtonType"];
    [self updateUI];
}

- (void)expandingAreaShapeButtonTypeChosen:(id)aChosen
{
    [self applyShapeBackgrounStyleWithButtonType:@"HSExpandingAreaShapeButtonType"];
    [self updateUI];
}

- (void)freehandAreaButtonTypeChosen:(id)aChosen
{
    [self applyShapeBackgrounStyleWithButtonType:@"HSFreehandAreaShapeButtonType"];
    [self updateUI];
}

- (void)invisibleShapeButtonTypeChosen:(id)aChosen
{
    [self applyShapeBackgrounStyleWithButtonType:@"HSInvisibleShapeButtonType"];
    [self updateUI];
}

- (void)dropShadowRectangleSystemButtonTypeChosen:(id)aChosen
{
    [self applySystemBackgrounStyleWithButtonType:@"HSDropShadowRectangleSystemButtonType"];
    [self updateUI];
}

- (void)rectangleSystemButtonTypeChosen:(id)aChosen
{
    [self applySystemBackgrounStyleWithButtonType:@"HSRectangleSystemButtonType"];
    [self updateUI];
}

- (void)defaultSystemButtonTypeChosen:(id)aChosen
{
    [self applySystemBackgrounStyleWithButtonType:@"HSDefaultSystemButtonType"];
    [self updateUI];
}

- (void)regularSystemButtonTypeChosen:(id)aChosen
{
    [self applySystemBackgrounStyleWithButtonType:@"HSRegularSystemButtonType"];
    [self updateUI];
}

- (void)willCloseWindow
{
    [_titleColorWell deactivate];
    [_backgroundColorWell deactivate];
}

- (void)willShowWindow
{
    [_prototypeObjectView setUserObject:_createdButtonObject];
    [_titleTextField setDelegate:self];
    [[self window] makeFirstResponder:_cancelButton];
    [self updateUI];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fa5b6 @ 001fa5b6, 725 bytes * /

void FUN_001fa5b6(HSEditButtonObjectDialogController *self,SEL _cmd)

{
  HSGradientColorWell *pHVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  cfstringStruct *pcVar5;
  undefined *puVar6;
  
  pvVar3 = _objc_msgSend(self,sel_systemBackgroundInterface);
  if (pvVar3 != (id)0x0) {
    pHVar1 = self->_backgroundColorWell;
    pvVar3 = _objc_msgSend(self,sel_systemBackgroundInterface);
    pvVar3 = _objc_msgSend(pvVar3,sel_tintColor);
    _objc_msgSend(pHVar1,sel_setColor_,pvVar3);
  }
  pHVar1 = self->_titleColorWell;
  pvVar3 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar3 = _objc_msgSend(pvVar3,sel_titleColor);
  _objc_msgSend(pHVar1,sel_setColor_,pvVar3);
  pvVar3 = self->_invisibleLabelTextField;
  pvVar4 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar4 = _objc_msgSend(pvVar4,sel_titleColor);
  _objc_msgSend(pvVar3,sel_setTextColor_,pvVar4);
  pvVar3 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar3 = _objc_msgSend(pvVar3,sel_backgroundStyle);
  pcVar5 = &cfstr_HSButtonObjectSystemBackgroundStyle;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,&cfstr_HSButtonObjectSystemBackgroundStyle);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(self,sel_buttonObjectInterface,pcVar5);
    pvVar3 = _objc_msgSend(pvVar3,sel_isTitleVisible);
    if ((char)pvVar3 != '\0') goto LAB_001fa6d9;
    cVar2 = '\0';
  }
  else {
LAB_001fa6d9:
    cVar2 = '\x01';
  }
  _objc_msgSend(self->_invisibleLabelTextField,sel_setHidden_,(int)cVar2);
  pvVar3 = self->_showTitleSwitch;
  pvVar4 = _objc_msgSend(self->_createdButtonObject,sel_isTitleVisible);
  _objc_msgSend(pvVar3,sel_setState_,(int)(char)pvVar4);
  pvVar3 = self->_titleTextField;
  pvVar4 = _objc_msgSend(self,sel_buttonObjectInterface);
  pvVar4 = _objc_msgSend(pvVar4,sel_title);
  _objc_msgSend(pvVar3,sel_setStringValue_,pvVar4);
  pvVar3 = _objc_msgSend(self->_createdButtonObject,sel_backgroundStyle);
  pcVar5 = &cfstr_HSButtonObjectSystemBackgroundStyle;
  pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,&cfstr_HSButtonObjectSystemBackgroundStyle);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(self->_createdButtonObject,sel_backgroundStyle,pcVar5);
    pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,&cfstr_HSButtonObjectShapeBackgroundStyle);
    if ((char)pvVar3 == '\0') {
      pvVar3 = (id)0x0;
      goto LAB_001fa854;
    }
    puVar6 = &DAT_00381478;
    pvVar3 = _objc_msgSend(self->_createdButtonObject,sel_queryHyperInterface_,&DAT_00381478);
    op = sel_shapeButtonType;
  }
  else {
    puVar6 = &DAT_003813b0;
    pvVar3 = _objc_msgSend(self->_createdButtonObject,sel_queryHyperInterface_,&DAT_003813b0);
    op = sel_systemButtonType;
  }
  pvVar3 = _objc_msgSend(pvVar3,op,puVar6);
LAB_001fa854:
  pvVar4 = self->_buttonTypeMatrix;
  pvVar3 = _objc_msgSend(self,sel_tagForButtonType_,pvVar3);
  _objc_msgSend(pvVar4,sel_selectCellWithTag_,pvVar3);
  return;
}

*/
- (void)updateUI
{
    if ([self systemBackgroundInterface] != nil) {
        [_backgroundColorWell setColor:[[self systemBackgroundInterface] tintColor]];
    }
    [_titleColorWell setColor:[[self buttonObjectInterface] titleColor]];
    [_invisibleLabelTextField setTextColor:[[self buttonObjectInterface] titleColor]];
    BOOL hidden;
    if ([[[self buttonObjectInterface] backgroundStyle] isEqualToString:@"HSButtonObjectSystemBackgroundStyle"]) {
        hidden = YES;
    } else {
        hidden = [[self buttonObjectInterface] isTitleVisible];
    }
    [_invisibleLabelTextField setHidden:hidden];
    [_showTitleSwitch setState:[_createdButtonObject isTitleVisible]];
    [_titleTextField setStringValue:[[self buttonObjectInterface] title]];
    id buttonType;
    if ([[_createdButtonObject backgroundStyle] isEqualToString:@"HSButtonObjectSystemBackgroundStyle"]) {
        buttonType = [[_createdButtonObject queryHyperInterface:@protocol(HSButtonObjectSystemStyleBackgroundAttributes)] systemButtonType];
    } else if ([[_createdButtonObject backgroundStyle] isEqualToString:@"HSButtonObjectShapeBackgroundStyle"]) {
        buttonType = [[_createdButtonObject queryHyperInterface:@protocol(HSButtonObjectShapeBackgroundAttributes)] shapeButtonType];
    } else {
        buttonType = nil;
    }
    [_buttonTypeMatrix selectCellWithTag:[self tagForButtonType:buttonType]];
}

- (id)nibName
{
    return @"EditButtonObjectDialog";
}

- (id)createdButtonObject
{
    return _createdButtonObject;
}

- (void)setContext:(id)aContext
{
    if (_context != aContext) {
        [_context release];
        _context = [aContext retain];
    }
}

- (id)context
{
    return _context;
}

- (void)removeAllObjectsFromNodeSupport
{
    [[self nodeSupport] removeAllNodes];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fa4f0 @ 001fa4f0, 65 bytes * /

void FUN_001fa4f0(HSEditButtonObjectDialogController *self,SEL _cmd,id removeObjectFromNodeSupport)

{
  id self_00;
  
  self_00 = _objc_msgSend(self,sel_nodeSupport);
  _objc_msgSend(self_00,sel_removeNode_,removeObjectFromNodeSupport);
  return;
}

*/
- (void)removeObjectFromNodeSupport:(id)aSupport
{
    [[self nodeSupport] removeNode:aSupport];
}

- (void)addObjectToNodeSupport:(id)aSupport
{
    [[self nodeSupport] addNode:aSupport];
}

- (id)nodeSupport
{
    HSEditObjectDialogNodeSupport *pHVar1;

    pHVar1 = _nodeSupport;
    if (pHVar1 == nil) {
        pHVar1 = [[HSEditObjectDialogNodeSupport nodeSupport] retain];
        _nodeSupport = pHVar1;
    }
    return pHVar1;
}

- (void)runForWindow:(id)aWindow delegate:(id)aDelegate didEndSelector:(SEL)aSelector
{
    [self createNewButtonObject];
    [super runForWindow:aWindow delegate:aDelegate didEndSelector:aSelector];
}

- (NSInteger)runModal
{
    [self createNewButtonObject];
    return (int)[super runModal];
}

- (void)didLoadNib
{
    [super didLoadNib];
    [_backgroundColorWell setPatternSupportEnabled:NO];
    [_backgroundColorWell setGradientSupportEnabled:NO];
    [_titleColorWell setGradientSupportEnabled:NO];
    [_titleColorWell setPatternSupportEnabled:NO];
}

- (void)dealloc
{
    [_createdButtonObject release];
    [_nodeSupport release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001fa28f @ 001fa28f, 468 bytes * /

void FUN_001fa28f(HSEditButtonObjectDialogController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined *puVar3;
  
  puVar3 = &DAT_00381360;
  pvVar1 = _objc_msgSend(self->_createdButtonObject,sel_implementsHyperInterface_,&DAT_00381360);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_removeAllObjectsFromNodeSupport,puVar3);
  }
  _objc_msgSend(self->_createdButtonObject,sel_release,puVar3);
  pvVar1 = _objc_msgSend(cls_HSButtonObject,sel_defaultObject);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_createdButtonObject = pvVar1;
  pvVar2 = _objc_msgSend(self,sel_context);
  pvVar2 = _objc_msgSend(pvVar2,sel_card);
  pvVar2 = _objc_msgSend(pvVar2,sel_support);
  _objc_msgSend(pvVar1,sel_setSupport_,pvVar2);
  pvVar1 = self->_createdButtonObject;
  _objc_msgSend(self,sel_addObjectToNodeSupport_,pvVar1);
  if (self->_defaultButtonStyle != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_defaultButtonStyle,sel_isEqualToString_,
                           &cfstr_HSButtonObjectShapeBackgroundStyle);
    pvVar1 = self->_defaultButtonType;
    op = sel_applySystemBackgrounStyleWithButtonType_;
    if ((char)pvVar2 != '\0') {
      op = sel_applyShapeBackgrounStyleWithButtonType_;
    }
    _objc_msgSend(self,op,pvVar1);
  }
  pvVar2 = _objc_msgSend(self,sel_buttonObjectInterface,pvVar1);
  pvVar1 = (id)(uint)(self->_defaultNotShowTitle == '\0');
  _objc_msgSend(pvVar2,sel_setTitleVisible_,pvVar1);
  if (self->_defaultTitleColor != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_buttonObjectInterface,pvVar1);
    pvVar1 = self->_defaultTitleColor;
    _objc_msgSend(pvVar2,sel_setTitleColor_,pvVar1);
  }
  if (self->_defaultBackgroundColor != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_systemBackgroundInterface,pvVar1);
    _objc_msgSend(pvVar1,sel_setTintColor_,self->_defaultBackgroundColor);
  }
  return;
}

*/
- (void)createNewButtonObject
{
    if ([_createdButtonObject implementsHyperInterface:@protocol(HSNodeAttributes)]) {
        [self removeAllObjectsFromNodeSupport];
    }
    [_createdButtonObject release];
    _createdButtonObject = [[HSButtonObject defaultObject] retain];
    [_createdButtonObject setSupport:[[[self context] card] support]];
    [self addObjectToNodeSupport:_createdButtonObject];
    if (_defaultButtonStyle != nil) {
        if ([_defaultButtonStyle isEqualToString:@"HSButtonObjectShapeBackgroundStyle"]) {
            [self applyShapeBackgrounStyleWithButtonType:_defaultButtonType];
        } else {
            [self applySystemBackgrounStyleWithButtonType:_defaultButtonType];
        }
    }
    [[self buttonObjectInterface] setTitleVisible:!_defaultNotShowTitle];
    if (_defaultTitleColor != nil) {
        [[self buttonObjectInterface] setTitleColor:_defaultTitleColor];
    }
    if (_defaultBackgroundColor != nil) {
        [[self systemBackgroundInterface] setTintColor:_defaultBackgroundColor];
    }
}

- (id)defaultButtonBorderPath
{
    if (sDAT_003429f8 == nil) {
        sDAT_003429f8 = [NSBezierPath bezierPathWithRect:[[[HSButtonObject defaultObject] queryHyperInterface:@protocol(HSGeometryAttributes)] boundingRect]];
    }
    return sDAT_003429f8;
}

@end

