#import "HSTextTool.h"
static id sDAT_003427fc;
static id sDAT_00342800;

static id sDAT_003427fc;
static id sDAT_00342800;


@implementation HSTextTool

/* i386 ivar offsets: _createdObject=0x1c, _additionalToolPrototype=0x20, _objectEditingLayer=0x24, _isActive=0x28, _initialRectSide=0x2c */

+ (id)allowedEditorInterfaces
{
    id self_00;

    if (sDAT_00342800 == nil) {
        self_00 = [NSMutableSet set];
        [self_00 unionSet:[HSTextTool allowedPrototypeInterfaces]];
        [self_00 addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSTextObjectSizingAttributes)]];
        [self_00 addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSGeometryAttributes)]];
        [self_00 addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSSelectableObject)]];
        sDAT_00342800 = [self_00 copy];
    }
    return sDAT_00342800;
}

+ (id)allowedPrototypeInterfaces
{
    id self_00;

    if (sDAT_003427fc == nil) {
        self_00 = [NSMutableSet set];
        [self_00 unionSet:[HSTextObject textImplementationInterfaces]];
        [self_00 addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSShadowAttributes)]];
        [self_00 addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableShadowAttributes)]];
        [self_00 addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSOpacityAttributes)]];
        [self_00 addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSMutableOpacityAttributes)]];
        [self_00 addObject:[HSProtocolIdentifier identifierForProtocol:@protocol(HSRunTimeEditor)]];
        sDAT_003427fc = [self_00 copy];
    }
    return sDAT_003427fc;
}

+ (Class)userObjectClass
{
    return [HSTextObject class];
}

- (BOOL)preservesActiveInPlaceEditors
{
    return NO;
}

- (BOOL)allowsActiveInPlaceEditors
{
    return YES;
}

- (BOOL)acceptsFirstMouse
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000648b2 @ 000648b2, 261 bytes * /

void FUN_000648b2(HSTextTool *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  undefined4 uVar3;
  
  uVar3 = 0;
  _objc_msgSend(self,sel_setObjectEditingLayer_,0);
  if (self->_isActive != '\0') {
    _objc_msgSend(self,sel_setupObjectEditingCanvasLayerIfNeeded,uVar3);
  }
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager,uVar3);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentToolSet);
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_toolSettings);
  op = sel_flatTextShadowEnabled;
  if (pvVar1 == (id)0x1) {
    op = sel_textShadowEnabled;
  }
  pvVar1 = _objc_msgSend(pvVar2,op);
  _objc_msgSend(self->_createdObject,sel_setHyperShadowEnabled_,(int)(char)pvVar1);
  pvVar2 = _objc_msgSend(self,sel_prototypeObject);
  _objc_msgSend(pvVar2,sel_setHyperShadowEnabled_,(int)(char)pvVar1);
  return;
}

*/
- (void)noteCurrentToolSetDidChange
{
    [self setObjectEditingLayer:nil];
    if (_isActive) {
        [self setupObjectEditingCanvasLayerIfNeeded];
    }
    id toolSettings = [[HSToolManager sharedToolManager] toolSettings];
    BOOL shadow = ([[HSToolManager sharedToolManager] currentToolSet] == 1) ? [toolSettings textShadowEnabled] : [toolSettings flatTextShadowEnabled];
    [_createdObject setHyperShadowEnabled:shadow];
    [[self prototypeObject] setHyperShadowEnabled:shadow];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00064d3b @ 00064d3b, 251 bytes * /

void FUN_00064d3b(HSTextTool *self,SEL _cmd,BOOL didActivateExplicitly)

{
  id pvVar1;
  id pvVar2;
  SEL op;
  HSTextTool *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSLegacyCreationTool_0034e560;
  _objc_msgSendSuper(&local_1c,sel_didActivateExplicitly_,(int)didActivateExplicitly);
  _objc_msgSend(self,sel_setupObjectEditingCanvasLayerIfNeeded);
  pvVar1 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar1 = _objc_msgSend(pvVar1,sel_currentToolSet);
  pvVar2 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar2 = _objc_msgSend(pvVar2,sel_toolSettings);
  op = sel_flatTextShadowEnabled;
  if (pvVar1 == (id)0x1) {
    op = sel_textShadowEnabled;
  }
  pvVar1 = _objc_msgSend(pvVar2,op);
  pvVar2 = _objc_msgSend(self,sel_prototypeObject);
  _objc_msgSend(pvVar2,sel_setHyperShadowEnabled_,(int)(char)pvVar1);
  self->_isActive = '\x01';
  return;
}

*/
- (void)didActivateExplicitly:(BOOL)aExplicitly
{
    [super didActivateExplicitly:aExplicitly];
    [self setupObjectEditingCanvasLayerIfNeeded];
    id toolSettings = [[HSToolManager sharedToolManager] toolSettings];
    BOOL shadow = ([[HSToolManager sharedToolManager] currentToolSet] == 1) ? [toolSettings textShadowEnabled] : [toolSettings flatTextShadowEnabled];
    [[self prototypeObject] setHyperShadowEnabled:shadow];
    _isActive = YES;
}

- (void)finalizeBeforeDeactivateExplicitly:(BOOL)aExplicitly
{
    _isActive = NO;
    [self setObjectEditingLayer:nil];
    [super finalizeBeforeDeactivateExplicitly:aExplicitly];
}

- (void)setupObjectEditingCanvasLayerIfNeeded
{
    if ([[HSToolManager sharedToolManager] currentToolSet] == 0x1) {
        [self setObjectEditingLayer:[[[HSTextToolObjectEditingCanvasLayer alloc] init] autorelease]];
    }
}

- (void)setObjectEditingLayer:(id)aLayer
{
    id pvVar1;
    id self_00;
    id pvVar1_3;

    pvVar1 = _objectEditingLayer;
    if (pvVar1 != aLayer) {
        self_00 = nil;
        if (pvVar1 != nil) {
            [pvVar1 setClient:0];
            [[self toolLayer] removeSublayer:_objectEditingLayer];
            self_00 = _objectEditingLayer;
        }
        [self_00 release];
        pvVar1_3 = [aLayer retain];
        _objectEditingLayer = pvVar1_3;
        if (pvVar1_3 != nil) {
            [pvVar1_3 setClient:self];
            [[self toolLayer] addSublayer:_objectEditingLayer];
        }
    }
}

- (void)setTextColor:(id)aColor
{
    [[[self prototypeObject] queryHyperInterface:@protocol(HSGenericSolidColorAttributes)] setHyperSolidColor:aColor];
}

- (id)textColor
{
    return [[[self prototypeObject] queryHyperInterface:@protocol(HSGenericSolidColorAttributes)] hyperSolidColor];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00064168 @ 00064168, 19 bytes * /

id FUN_00064168(HSTextTool *self,SEL _cmd)

{
  return *(id *)PTR_PTR_003363ac;
}

*/
- (id)defaultToolCursorName
{
    return HSTextToolCursor;
}

- (BOOL)allowsToEditPrototypeObjectInterface:(id)aInterface
{
    BOOL BVar1;
    id pvVar2;

    pvVar2 = [HSProtocolIdentifier identifierForProtocol:aInterface];
    if (![[[self class] allowedPrototypeInterfaces] containsObject:pvVar2]) {
        BVar1 = (BOOL)[super allowsToEditPrototypeObjectInterface:aInterface];
    }
    else {
        BVar1 = YES;
    }
    return BVar1;
}

- (void)prototypeObjectDidChange
{
    [[self prototypeObject] hyperAutoSizeToFitText];
}

- (void)saveChangesAndNotify:(BOOL)aNotify
{
    [self setCreatedObject:nil];
    if (aNotify != NO) {
        [self notifyManagerAtomOperationPerformedWithResult:YES];
    }
}

- (void)setAdditionalToolPrototype:(id)aPrototype
{
    id self_00;
    id pvVar1_2;
    id pvVar1_3;

    if (_additionalToolPrototype != aPrototype) {
        self_00 = [[HSToolManager sharedToolManager] toolSettings];
        pvVar1_2 = nil;
        if (_additionalToolPrototype != nil) {
            [self_00 removeUserObjectPrototype:_additionalToolPrototype forTool:self];
            pvVar1_2 = _additionalToolPrototype;
        }
        [pvVar1_2 release];
        pvVar1_3 = [aPrototype retain];
        _additionalToolPrototype = pvVar1_3;
        if (pvVar1_3 != nil) {
            [self_00 addUserObjectPrototype:pvVar1_3 forTool:self];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006428d @ 0006428d, 688 bytes * /

void FUN_0006428d(HSTextTool *self,SEL _cmd,id setCreatedObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined4 uVar6;
  
  if (self->_createdObject != setCreatedObject) {
    if (self->_createdObject != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_view);
      pvVar2 = self->_createdObject;
      _objc_msgSend(pvVar1,sel_endEditorForObject_,pvVar2);
      pvVar1 = _objc_msgSend(self->_createdObject,sel_isEmpty);
      if (((char)pvVar1 == '\0') && (self->_createdObject != (id)0x0)) {
        _objc_msgSend(self,sel_addCreatedObjectToCard,pvVar2);
      }
    }
    _objc_msgSend(self,sel_setAdditionalToolPrototype_,0);
    _objc_msgSend(self->_createdObject,sel_autorelease);
    pvVar2 = _objc_msgSend(setCreatedObject,sel_retain);
    self->_createdObject = pvVar2;
    if (pvVar2 != (id)0x0) {
      puVar5 = &DAT_003645a8;
      pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003645a8);
      if (pvVar2 != (id)0x0) {
        pvVar1 = _objc_msgSend(cls_HSLimitedInterfacesProxy,sel_alloc,puVar5);
        pvVar3 = _objc_msgSend(self,sel_class);
        pvVar3 = _objc_msgSend(pvVar3,sel_allowedEditorInterfaces);
        pvVar1 = _objc_msgSend(pvVar1,sel_initWithHyperObject_interfaces_,self->_createdObject,
                               pvVar3);
        pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
        pvVar2 = _objc_msgSend(pvVar2,sel_class);
        pvVar2 = _objc_msgSend(pvVar2,sel_alloc);
        pvVar2 = _objc_msgSend(pvVar2,sel_initWithHyperObject_,pvVar1);
        puVar4 = _objc_msgSend(pvVar2,sel_autorelease);
        pvVar2 = _objc_msgSend(cls_HSRunTimeEditorFactory,sel_sharedInstance);
        _objc_msgSend(pvVar2,sel_setupRunTimeEditor_forObject_,puVar4,pvVar1);
        pvVar2 = _objc_msgSend(self,sel_view);
        uVar6 = 1;
        puVar5 = puVar4;
        pvVar2 = _objc_msgSend(pvVar2,sel_startEditor_forObject_creationMode_,puVar4,pvVar1,1);
        if ((char)pvVar2 != '\0') {
          pvVar2 = _objc_msgSend(cls_HSHyperImplementationProxy,
                                 sel_proxyWithImplementation_forObject_,puVar4,puVar4,uVar6);
          _objc_msgSend(pvVar2,sel_setHyperObjectDirectedAtParentObject_,1);
          _objc_msgSend(self,sel_setAdditionalToolPrototype_,pvVar2);
          return;
        }
      }
      _objc_msgSend(self->_createdObject,sel_autorelease,puVar5);
      self->_createdObject = (id)0x0;
    }
  }
  return;
}

*/
- (void)setCreatedObject:(id)aObject
{
    if (_createdObject != aObject) {
        if (_createdObject != nil) {
            [[self view] endEditorForObject:_createdObject];
            if (![_createdObject isEmpty] && _createdObject != nil) {
                [self addCreatedObjectToCard];
            }
        }
        [self setAdditionalToolPrototype:nil];
        [_createdObject autorelease];
        _createdObject = [aObject retain];
        if (_createdObject != nil) {
            id editor = [_createdObject queryHyperInterface:@protocol(HSRunTimeEditor)];
            if (editor != nil) {
                id limited = [[[HSLimitedInterfacesProxy alloc] initWithHyperObject:_createdObject interfaces:[[self class] allowedEditorInterfaces]] autorelease];
                id runTimeEditor = [[[[editor class] alloc] initWithHyperObject:limited] autorelease];
                [[HSRunTimeEditorFactory sharedInstance] setupRunTimeEditor:runTimeEditor forObject:limited];
                if ([[self view] startEditor:runTimeEditor forObject:limited creationMode:YES]) {
                    /* the original passes the editor as both the implementation and the object */
                    id proxy = [HSHyperImplementationProxy proxyWithImplementation:runTimeEditor forObject:runTimeEditor];
                    [proxy setHyperObjectDirectedAtParentObject:YES];
                    [self setAdditionalToolPrototype:proxy];
                    return;
                }
            }
            [_createdObject autorelease];
            _createdObject = nil;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00064f40 @ 00064f40, 1231 bytes * /

void FUN_00064f40(HSTextTool *self,SEL _cmd)

{
  int iVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  HSTextTool *pHVar6;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined4 extraout_EDX_01;
  float extraout_EDX_02;
  float extraout_EDX_03;
  undefined4 extraout_EDX_04;
  longdouble lVar7;
  longdouble lVar8;
  SEL op;
  undefined4 uVar9;
  undefined4 uVar10;
  float local_40;
  float local_34;
  float local_30;
  char local_2c;
  id local_24;
  float local_20;
  float local_1c;
  
  pvVar3 = _objc_msgSend(self->_createdObject,sel_queryHyperInterface_,&DAT_003649e0);
  pvVar3 = _objc_msgSend(pvVar3,sel_queryGeometryBehaviorApplier);
  pvVar4 = _objc_msgSend(pvVar3,sel_mutableGeometryAttributes);
  _objc_msgSend_stret(&local_24,pvVar4,sel_frameBoundingRect);
  pvVar4 = _objc_msgSend(self,sel_view);
  pvVar4 = _objc_msgSend(pvVar4,sel_convertPointFromUserSpaceToViewSpace_,local_24,local_20);
  pvVar5 = _objc_msgSend(self,sel_view);
  pvVar4 = _objc_msgSend(pvVar5,sel_convertPoint_toView_,pvVar4,extraout_EDX,0);
  lVar7 = (longdouble)_roundf(pvVar4);
  lVar8 = (longdouble)_roundf(extraout_EDX_00);
  pvVar4 = _objc_msgSend(self,sel_view);
  pvVar4 = _objc_msgSend(pvVar4,sel_convertPoint_fromView_,(float)lVar7,(float)lVar8,0);
  pvVar5 = _objc_msgSend(self,sel_view);
  pvVar4 = _objc_msgSend(pvVar5,sel_convertPointFromViewSpaceToUserSpace_,pvVar4,extraout_EDX_01);
  local_24 = pvVar4;
  local_20 = extraout_EDX_02;
  pvVar5 = _objc_msgSend(self->_createdObject,sel_queryHyperInterface_,&DAT_00364738);
  _objc_msgSend_stret(&local_34,pvVar5,sel_hyperAutoresizingOptions);
  pvVar5 = _objc_msgSend(self,sel_view);
  pvVar5 = _objc_msgSend(pvVar5,sel_cardSize);
  puVar2 = cls_NSTextStorage;
  iVar1 = self->_initialRectSide;
  local_40 = local_1c;
  if (iVar1 == 4) {
    if (((float)pvVar4 < 0.0) ||
       (local_30 = extraout_EDX_02, (float)pvVar5 <= (float)pvVar4 + local_1c)) {
      local_40 = local_1c * 0.5 + (float)pvVar4;
      if (local_40 <= (float)pvVar5 * 0.5) {
        local_40 = local_40 + local_40;
        local_30 = extraout_EDX_02;
      }
      else {
        local_40 = ((float)pvVar5 - local_40) + ((float)pvVar5 - local_40);
        local_30 = extraout_EDX_02;
      }
    }
  }
  else if (iVar1 == 2) {
    local_30 = extraout_EDX_02;
    if ((float)pvVar4 <= 0.0) {
      local_40 = local_1c + (float)pvVar4;
    }
  }
  else if (iVar1 == 0) {
    local_40 = (float)pvVar5 - (float)pvVar4;
    local_30 = extraout_EDX_03 - extraout_EDX_02;
  }
  else {
    local_40 = local_34;
  }
  local_34 = local_40;
  pvVar4 = _objc_msgSend(self->_createdObject,sel_cocoaTextStorage);
  pvVar4 = _objc_msgSend(puVar2,sel_hyperSizeForTextStorage_withWidth_fixedWidth_,pvVar4,local_40,
                         (int)local_2c);
  if (self->_initialRectSide == 2) {
    pvVar5 = (id)(((float)local_24 + local_1c) - (float)pvVar4);
  }
  else {
    pvVar5 = local_24;
    if (self->_initialRectSide != 0) {
      pvVar5 = (id)((((float)local_24 + local_1c * 0.5) -
                    ((float)pvVar4 * 0.5 + *(float *)PTR_00336078)) + *(float *)PTR_00336078);
    }
  }
  _objc_msgSend(pvVar3,sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_,pvVar5,local_20,0
               );
  uVar10 = 0;
  uVar9 = extraout_EDX_04;
  _objc_msgSend(pvVar3,sel_resizeTo_withLayoutGuidingContext_,pvVar4,extraout_EDX_04,0);
  pvVar3 = _objc_msgSend(cls_HSToolManager,sel_sharedToolManager);
  pvVar3 = _objc_msgSend(pvVar3,sel_currentToolSet);
  puVar2 = cls_NSObject;
  if (pvVar3 == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_view,pvVar4,uVar9,uVar10);
    pHVar6 = _objc_msgSend(pvVar3,sel_card);
    pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,self->_createdObject);
    self = pHVar6;
    op = sel_drawObjectsOnBackground_;
  }
  else {
    pvVar3 = _objc_msgSend(self->_createdObject,sel_extraDictionaryRepresentation,pvVar4,uVar9,
                           uVar10);
    pvVar3 = _objc_msgSend(puVar2,sel_objectWithExtraDictionary_,pvVar3);
    op = sel_addObjectToCard_;
  }
  _objc_msgSend(self,op,pvVar3);
  return;
}

*/
- (void)addCreatedObjectToCard
{
    id applier = [[_createdObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    NSRect frame = [[applier mutableGeometryAttributes] frameBoundingRect];
    /* snap the origin to whole window pixels */
    NSPoint origin = [[self view] convertPointFromUserSpaceToViewSpace:frame.origin];
    origin = [[self view] convertPoint:origin toView:nil];
    origin = NSMakePoint(roundf(origin.x), roundf(origin.y));
    origin = [[self view] convertPoint:origin fromView:nil];
    frame.origin = [[self view] convertPointFromViewSpaceToUserSpace:origin];
    struct HSTextObjectAutoresizingOptions options = [[_createdObject queryHyperInterface:@protocol(HSTextObjectSizingAttributes)] hyperAutoresizingOptions];
    NSSize cardSize = [[self view] cardSize];
    float width = frame.size.width;
    if (_initialRectSide == 4) {
        if (frame.origin.x < 0.0f || cardSize.width <= frame.origin.x + frame.size.width) {
            width = frame.size.width * 0.5f + frame.origin.x;
            if (width <= cardSize.width * 0.5f) {
                width = width + width;
            } else {
                width = (cardSize.width - width) + (cardSize.width - width);
            }
        }
    } else if (_initialRectSide == 2) {
        if (frame.origin.x <= 0.0f) {
            width = frame.size.width + frame.origin.x;
        }
    } else if (_initialRectSide == 0) {
        width = cardSize.width - frame.origin.x;
    } else {
        width = options.f0;
    }
    NSSize size = [NSTextStorage hyperSizeForTextStorage:[_createdObject cocoaTextStorage] withWidth:width fixedWidth:options.f2];
    float x;
    if (_initialRectSide == 2) {
        x = (frame.origin.x + frame.size.width) - size.width;
    } else if (_initialRectSide != 0) {
        x = (frame.origin.x + frame.size.width * 0.5f) - size.width * 0.5f;
    } else {
        x = frame.origin.x;
    }
    [applier moveFrameBoundingRectOriginTo:NSMakePoint(x, frame.origin.y) withLayoutGuidingContext:nil];
    [applier resizeTo:size withLayoutGuidingContext:nil];
    if ([[HSToolManager sharedToolManager] currentToolSet] == 0) {
        [[[self view] card] drawObjectsOnBackground:[NSArray arrayWithObject:_createdObject]];
    } else {
        [self addObjectToCard:[NSObject objectWithExtraDictionary:[_createdObject extraDictionaryRepresentation]]];
    }
}

- (void)handleMouseDownInNode:(id)aNode atPoint:(NSPoint)aPoint event:(id)aEvent inTextToolObjectEditingCanvasLayer:(id)aLayer
{
    [self willHandleMouseDown];
    [[self view] selectNode:aNode];
    [[self view] startEditorForObject:aNode creationMode:NO];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006540f @ 0006540f, 627 bytes * /

void FUN_0006540f(HSTextTool *self,SEL _cmd,id handleMouseDown)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  undefined4 extraout_EDX_00;
  undefined8 local_24;
  undefined8 local_1c;
  
  pvVar2 = _objc_msgSend(self,sel_view);
  if (pvVar2 != (id)0x0) {
    pvVar2 = _objc_msgSend(self,sel_view);
    _objc_msgSend(handleMouseDown,sel_locationInWindow);
    pvVar2 = _objc_msgSend(pvVar2,sel_convertPoint_fromView_);
    pvVar3 = _objc_msgSend(self,sel_view);
    _objc_msgSend_stret(&local_24,pvVar3,sel_cardViewingRect);
    cVar1 = _NSPointInRect(pvVar2,extraout_EDX,local_24,local_1c);
    if (cVar1 == '\0') {
      _objc_msgSend(self,sel_setCreatedObject_,0);
    }
    else {
      pvVar3 = _objc_msgSend(self,sel_view);
      pvVar2 = _objc_msgSend(pvVar3,sel_convertPointFromViewSpaceToUserSpace_,pvVar2,extraout_EDX);
      pvVar3 = _objc_msgSend(self,sel_prototypeObject);
      pvVar3 = _objc_msgSend(pvVar3,sel_localCopyIncludingNodeUnits_,1);
      pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
      pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00364968);
      _objc_msgSend(pvVar4,sel_hyperReplaceTextWithString_,0);
      pvVar4 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_003649e0);
      pvVar4 = _objc_msgSend(pvVar4,sel_queryGeometryBehaviorApplier);
      _objc_msgSend(pvVar4,sel_moveCenterTo_withLayoutGuidingContext_,pvVar2,extraout_EDX_00,0);
      _objc_msgSend(self,sel_setCreatedObject_,pvVar3);
      pvVar2 = _objc_msgSend(self->_createdObject,sel_queryHyperInterface_,&DAT_00364738);
      pvVar2 = _objc_msgSend(pvVar2,sel_stickyHorizontalSideForAutoresizing);
      self->_initialRectSide = (int)pvVar2;
    }
  }
  return;
}

*/
- (void)handleMouseDown:(id)aDown
{
    if ([self view] != nil) {
        NSPoint point = [[self view] convertPoint:[aDown locationInWindow] fromView:nil];
        if (!NSPointInRect(point, [[self view] cardViewingRect])) {
            [self setCreatedObject:nil];
        } else {
            NSPoint userPoint = [[self view] convertPointFromViewSpaceToUserSpace:point];
            id object = [[[self prototypeObject] localCopyIncludingNodeUnits:YES] autorelease];
            [[object queryHyperInterface:@protocol(HSTextObjectAttributes)] hyperReplaceTextWithString:nil];
            [[[object queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveCenterTo:userPoint withLayoutGuidingContext:nil];
            [self setCreatedObject:object];
            _initialRectSide = [[_createdObject queryHyperInterface:@protocol(HSTextObjectSizingAttributes)] stickyHorizontalSideForAutoresizing];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00064193 @ 00064193, 115 bytes * /

void FUN_00064193(HSTextTool *self,SEL _cmd)

{
  SEL op;
  
  if (self->_createdObject == (id)0x0) {
    self = _objc_msgSend(self,sel_view);
    op = sel_deactivateRunTimeEditor;
  }
  else {
    _objc_msgSend(self,sel_setCreatedObject_,0);
    op = sel_notifyManagerAtomOperationPerformedWithResult_;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)willHandleMouseDown
{
    if (_createdObject == nil) {
        [[self view] deactivateRunTimeEditor];
    } else {
        [self setCreatedObject:nil];
        [self notifyManagerAtomOperationPerformedWithResult:YES];
    }
}

- (void)dealloc
{
    [_createdObject release];
    [_objectEditingLayer setClient:0];
    [_objectEditingLayer release];
    [_additionalToolPrototype release];
    [super dealloc];
}

@end

