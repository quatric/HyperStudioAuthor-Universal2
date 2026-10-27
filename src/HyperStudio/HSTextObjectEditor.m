#import "HSTextObjectEditor.h"

@implementation HSTextObjectEditor

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006d5ce @ 0006d5ce, 156 bytes * /

void FUN_0006d5ce(HSTextObjectEditor *self,SEL _cmd)

{
  id pvVar1;
  id self_00;
  undefined4 extraout_EDX;
  
  pvVar1 = _objc_msgSend(self,sel_hostView);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_hostView);
    pvVar1 = _objc_msgSend(pvVar1,sel_userSpaceToViewSpaceTransform);
    pvVar1 = _objc_msgSend(pvVar1,sel_hyperScaleFactor);
    self_00 = _objc_msgSend(self,sel_textEditorEmbedder);
    _objc_msgSend(self_00,sel_setScaleFactor_,pvVar1,extraout_EDX);
  }
  return;
}

*/
- (void)updateViewScaleFactor
{
    if ([self hostView] != nil) {
        [[self textEditorEmbedder] setScaleFactor:[[[self hostView] userSpaceToViewSpaceTransform] hyperScaleFactor]];
    }
}

- (void)recalculateOccupiedRect
{
    [super recalculateOccupiedRect];
    [[self textEditorEmbedder] setDrawsBorderRect:YES];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006d6cf @ 0006d6cf, 161 bytes * /

NSRect * FUN_0006d6cf(NSRect *__return_storage_ptr__,HSTextObjectEditor *self,SEL _cmd)

{
  id self_00;
  float local_1c;
  float local_18;
  float local_14;
  float local_10;
  
  local_1c = *(float *)PTR_00336078;
  local_18 = *(float *)(PTR_00336078 + 4);
  local_14 = *(float *)(PTR_00336078 + 8);
  local_10 = *(float *)(PTR_00336078 + 0xc);
  self_00 = _objc_msgSend(self,sel_geometryAttributes);
  if (self_00 != (id)0x0) {
    _objc_msgSend_stret(&local_1c,self_00,sel_frameBoundingRect);
  }
  (__return_storage_ptr__->origin).x = local_1c;
  (__return_storage_ptr__->origin).y = local_18;
  (__return_storage_ptr__->size).width = local_14;
  (__return_storage_ptr__->size).height = local_10;
  return __return_storage_ptr__;
}

*/
- (NSRect)userSpaceObjectBounds
{
    NSRect bounds = NSZeroRect;
    id geometry = [self geometryAttributes];
    if (geometry != nil) {
        bounds = [geometry frameBoundingRect];
    }
    return bounds;
    return (NSRect){0};
}

- (id)nodeChildInterface
{
    return [[self editingObject] queryHyperInterface:@protocol(HSNodeChild)];
}

- (id)nodeAttributes
{
    return [[self editingObject] queryHyperInterface:@protocol(HSNodeAttributes)];
}

- (id)sizingAttributesInterface
{
    return [[self editingObject] queryHyperInterface:@protocol(HSTextObjectSizingAttributes)];
}

- (id)geometryAttributes
{
    return [[self editingObject] queryHyperInterface:@protocol(HSGeometryAttributes)];
}

- (id)attributesInterface
{
    return [[self editingObject] queryHyperInterface:@protocol(HSTextObjectAttributes)];
}

- (void)runTimeEditorEmbedderDidChangeSelectionWithoutChangingContent:(id)aContent
{
    [self notifyChange:2 ofAttribute:@protocol(HSTextAttribute) withUserInfo:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006d904 @ 0006d904, 136 bytes * /

void FUN_0006d904(HSTextObjectEditor *self,SEL _cmd,id runTimeEditorEmbedderWantsToResign)

{
  id pvVar1;
  undefined *puVar2;
  HSTextObjectEditor *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(self,sel_hostView);
  puVar2 = &DAT_00365368;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00365368);
  if ((pvVar1 != (id)0x0) &&
     (pvVar1 = _objc_msgSend(pvVar1,sel_isColorPickingModeActive,puVar2), (char)pvVar1 != '\0')) {
    return;
  }
  local_14 = self;
  local_10 = PTR_s_HSBaseEmbeddedEditor_0034e830;
  _objc_msgSendSuper(&local_14,sel_runTimeEditorEmbedderWantsToResign_,
                     runTimeEditorEmbedderWantsToResign);
  return;
}

*/
- (void)runTimeEditorEmbedderWantsToResign:(id)aResign
{
    id colorPicking = [[self hostView] queryHyperInterface:@protocol(HSColorPickingController)];
    if (colorPicking != nil && [colorPicking isColorPickingModeActive]) {
        return;
    }
    [super runTimeEditorEmbedderWantsToResign:aResign];
}

- (BOOL)displaysFocusRing
{
    return NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0006d98c @ 0006d98c, 1032 bytes * /

NSRect * FUN_0006d98c(NSRect *__return_storage_ptr__,HSTextObjectEditor *self,SEL _cmd)

{
  float fVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id self_00;
  undefined *puVar6;
  float extraout_EDX;
  float extraout_EDX_00;
  int *piVar7;
  int *piVar8;
  int *piVar9;
  int aiStack_a0 [4];
  float local_64;
  float local_60;
  id local_5c;
  float local_58;
  float local_54;
  float local_50;
  char local_4c;
  float local_44;
  float fStack_40;
  id local_3c;
  float fStack_38;
  float local_34;
  float local_30;
  float local_24;
  float local_20;
  float local_1c;
  
  piVar7 = (int *)&stack0xffffff74;
  local_44 = *(float *)PTR_00336078;
  fStack_40 = *(float *)(PTR_00336078 + 4);
  local_3c = *(id *)(PTR_00336078 + 8);
  fStack_38 = *(float *)(PTR_00336078 + 0xc);
  pvVar2 = _objc_msgSend(self,sel_textEditorEmbedder);
  pvVar3 = _objc_msgSend(pvVar2,sel_hyperText);
  pvVar2 = _objc_msgSend(self,sel_sizingAttributesInterface);
  pvVar4 = _objc_msgSend(pvVar2,sel_stickyHorizontalSideForAutoresizing);
  pvVar5 = _objc_msgSend(pvVar2,sel_hyperAutoresizingMode);
  if (pvVar5 == (id)0x3) {
    pvVar3 = _objc_msgSend(self,sel_geometryAttributes);
    piVar8 = (int *)&stack0xffffff74;
    if (pvVar3 == (id)0x0) goto LAB_0006dc10;
  }
  else {
    _objc_msgSend_stret(&local_54,pvVar2,sel_hyperAutoresizingOptions);
    aiStack_a0[3] = 0x6da95;
    pvVar5 = _objc_msgSend(self,sel_editingObject);
    aiStack_a0[3] = 0x6dab1;
    pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_);
    aiStack_a0[3] = 0x6dac3;
    pvVar5 = _objc_msgSend(pvVar5,sel_hyperParent);
    piVar7 = (int *)&stack0xffffff70;
    if (pvVar5 == (id)0x0) {
      aiStack_a0[3] = 0x6dae0;
      pvVar5 = _objc_msgSend(self,sel_hostView);
      aiStack_a0[3] = 0x6daf2;
      pvVar5 = _objc_msgSend(pvVar5,sel_cardSize);
      aiStack_a0[3] = 0x6db0b;
      self_00 = _objc_msgSend(self,sel_geometryAttributes);
      aiStack_a0[3] = 0x6db24;
      _objc_msgSend_stret(&local_34,self_00,sel_frameBoundingRect);
      piVar7 = aiStack_a0 + 3;
      if (pvVar4 == (id)0x4) {
        if (local_34 <= (float)pvVar5 * 0.5) {
          local_54 = local_34 + local_34 + 20.0;
        }
        else {
          local_54 = ((float)pvVar5 - local_34) + ((float)pvVar5 - local_34) + -20.0;
        }
      }
      else {
        if (pvVar4 != (id)0x2) {
          piVar7 = aiStack_a0 + 3;
          if (pvVar4 == (id)0x0) {
            local_54 = (float)pvVar5 - local_34;
            local_50 = extraout_EDX - local_30;
            piVar7 = aiStack_a0 + 3;
          }
          goto LAB_0006dbaa;
        }
        local_54 = local_34 + 10.0;
      }
      local_50 = local_30;
    }
LAB_0006dbaa:
    piVar7[1] = (int)sel_hyperAutoresizingMode;
    *piVar7 = (int)pvVar2;
    piVar7[-1] = 0x6dbbf;
    pvVar2 = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
    if (pvVar2 == (id)0x2) {
      piVar7[3] = (int)local_54;
      piVar7[2] = (int)local_50;
      puVar6 = sel_hyperRequiredSizeForTextBlockOfHeight_maximumWidth_;
    }
    else {
      piVar7[3] = (int)local_4c;
      piVar7[2] = (int)local_54;
      puVar6 = sel_hyperRequiredSizeToFitWidth_fixedWidth_;
    }
    piVar7[1] = (int)puVar6;
  }
  *piVar7 = (int)pvVar3;
  piVar7[-1] = 0x6dc0a;
  local_3c = _objc_msgSend((id)*piVar7,(SEL)piVar7[1]);
  piVar8 = piVar7;
  fStack_38 = extraout_EDX_00;
LAB_0006dc10:
  piVar8[2] = (int)sel_userSpaceObjectBounds;
  piVar8[1] = (int)self;
  *piVar8 = (int)&local_24;
  piVar8[-1] = 0x6dc2c;
  _objc_msgSend_stret((void *)*piVar8,(id)piVar8[1],(SEL)piVar8[2]);
  fVar1 = fStack_38;
  pvVar2 = local_3c;
  piVar9 = piVar8 + -1;
  if (pvVar4 == (id)0x2) {
    local_24 = (local_24 + local_1c) - (float)local_3c;
  }
  else if (pvVar4 != (id)0x0) {
    local_24 = ((local_24 + local_1c * 0.5) - ((float)local_3c * 0.5 + local_44)) + local_44;
  }
  fStack_40 = local_20;
  *piVar8 = (int)sel_hostView;
  piVar8[-1] = (int)self;
  piVar8[-2] = 0x6dcc5;
  local_44 = local_24;
  pvVar4 = _objc_msgSend((id)piVar8[-1],(SEL)*piVar8);
  if (pvVar4 != (id)0x0) {
    *(ulonglong *)(piVar8 + 4) = CONCAT44(fStack_38,local_3c);
    *(ulonglong *)(piVar8 + 2) = CONCAT44(fStack_40,local_44);
    piVar8[1] = (int)sel_viewBoundingRectForUserRect_;
    *piVar8 = (int)pvVar4;
    piVar8[-1] = (int)&local_64;
    piVar8[-2] = 0x6dcf8;
    _objc_msgSend_stret((void *)piVar8[-1],(id)*piVar8,(SEL)piVar8[1]);
    piVar9 = piVar8 + -2;
    local_44 = local_64;
    fStack_40 = local_60;
    local_3c = local_5c;
    fStack_38 = local_58;
  }
  piVar9[1] = (int)sel_textEditorEmbedder;
  *piVar9 = (int)self;
  piVar9[-1] = 0x6dd38;
  pvVar4 = _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  piVar9[3] = (int)fVar1;
  piVar9[2] = (int)pvVar2;
  piVar9[1] = (int)sel_applyOriginalTextSize_;
  *piVar9 = (int)pvVar4;
  piVar9[-1] = 0x6dd60;
  _objc_msgSend((id)*piVar9,(SEL)piVar9[1]);
  (__return_storage_ptr__->origin).x = local_44;
  (__return_storage_ptr__->origin).y = fStack_40;
  (__return_storage_ptr__->size).width = (float)local_3c;
  (__return_storage_ptr__->size).height = fStack_38;
  return __return_storage_ptr__;
}

*/
- (NSRect)calculateOccupiedRect
{
    NSRect rect = NSZeroRect;
    NSSize size = NSZeroSize;
    id text = [[self textEditorEmbedder] hyperText];
    id sizing = [self sizingAttributesInterface];
    NSInteger sticky0 = [sizing stickyHorizontalSideForAutoresizing];
    if ([sizing hyperAutoresizingMode] == 3) {
        id geometry = [self geometryAttributes];
        if (geometry != nil) {
            size = [geometry size];
        }
    } else {
        struct HSTextObjectAutoresizingOptions options = [sizing hyperAutoresizingOptions];
        if ([[[self editingObject] queryHyperInterface:@protocol(HSNodeParentAttribute)] hyperParent] == nil) {
            NSSize cardSize = [[self hostView] cardSize];
            NSRect frame = [[self geometryAttributes] frameBoundingRect];
            switch (sticky0) {
                case 4:
                    if (frame.origin.x > cardSize.width * 0.5f) {
                        options.f0 = (cardSize.width - frame.origin.x) * 2.0f + -20.0f;
                    } else {
                        options.f0 = frame.origin.x * 2.0f + 20.0f;
                    }
                    options.f1 = frame.origin.y;
                    break;
                case 2:
                    options.f0 = frame.origin.x + 10.0f;
                    options.f1 = frame.origin.y;
                    break;
                case 0:
                    options.f0 = cardSize.width - frame.origin.x;
                    options.f1 = cardSize.height - frame.origin.y;
                    break;
                default:
                    break;
            }
        }
        if ([sizing hyperAutoresizingMode] == 2) {
            size = [text hyperRequiredSizeForTextBlockOfHeight:options.f1 maximumWidth:options.f0];
        } else {
            size = [text hyperRequiredSizeToFitWidth:options.f0 fixedWidth:options.f2];
        }
    }
    NSInteger sticky = [sizing stickyHorizontalSideForAutoresizing];
    NSRect bounds = [self userSpaceObjectBounds];
    CGFloat x;
    if (sticky == 2) {
        x = (bounds.origin.x + bounds.size.width) - size.width;
    } else if (sticky != 0) {
        x = ((bounds.origin.x + bounds.size.width * 0.5) - (size.width * 0.5 + rect.origin.x)) + rect.origin.x;
    } else {
        x = bounds.origin.x;
    }
    rect = NSMakeRect(x, bounds.origin.y, size.width, size.height);
    CGFloat ceilHeight = ceilf(size.height);
    CGFloat ceilWidth = ceilf(size.width);
    if ([self hostView] != nil) {
        rect = [[self hostView] viewBoundingRectForUserRect:rect];
    }
    [[self textEditorEmbedder] applyOriginalTextSize:NSMakeSize(ceilWidth, ceilHeight)];
    return rect;
}

- (BOOL)calculatedRectIsPrecise
{
    return YES;
}

- (void)updateEmbeddedViewWithEditingObject
{
    id pvVar1_2;

    pvVar1_2 = [[self attributesInterface] hyperText];
    [[[self textEditorEmbedder] hyperText] hyperReplaceText:pvVar1_2 undoActionName:nil];
    [self updateViewScaleFactor];
    [super updateEmbeddedViewWithEditingObject];
}

- (void)postProcessEditingObjectAfterDeactivateEditing
{
    id pvVar2;
    id self_00;
    id pvVar1_2;

    if ([self canEditObject]) {
        pvVar1_2 = [self hyperObject];
        pvVar2 = [pvVar1_2 queryHyperInterface:@protocol(HSTextObjectAttributes)];
        self_00 = [pvVar1_2 queryHyperInterface:@protocol(HSNodeChild)];
        if ([pvVar2 isHyperEmpty]) {
            if ([self_00 hyperParent] != nil) {
                [[pvVar1_2 queryHyperInterface:@protocol(HSNodeAttributes)] removeFromHyperParent];
            }
        }
    }
}

- (void)deactivate
{
    if ([[self attributesInterface] isHyperEmpty]) {
        [[self nodeAttributes] retain];
    }
    [super deactivate];
    [[self textEditorEmbedder] removeAllUndoActions];
}

- (BOOL)activateEditing
{
    id pvVar2;
    BOOL pvVar1_2;

    [[self undoManager] disableUndoRegistration];
    pvVar1_2 = [super activateEditing];
    pvVar2 = [self undoManager];
    [pvVar2 enableUndoRegistration];
    if (pvVar1_2) {
        pvVar2 = [[self textEditorEmbedder] hyperText];
        [pvVar2 setHyperCursorPositionAccordingToCurrentEvent];
    }
    return pvVar1_2;
}

- (id)undoManager
{
    return [[self textEditorEmbedder] undoManager];
}

- (void)hostViewDidChangeUserSpaceToViewSpaceTransform
{
    [self updateViewScaleFactor];
    [super hostViewDidChangeUserSpaceToViewSpaceTransform];
}

- (BOOL)disablesRenderingEditingObject
{
    return YES;
}

- (void)saveEditing
{
    id pvVar1_3;

    if ([self isEditorChanged]) {
        pvVar1_3 = [[self textEditorEmbedder] hyperText];
        [[self attributesInterface] hyperReplaceText:pvVar1_3];
    }
}

- (id)coreTextInterface
{
    return [[self textEditorEmbedder] hyperText];
}

- (id)queryHyperInterface:(id)aInterface
{
    id pvVar2;

    pvVar2 = [HSProtocolIdentifier identifierForProtocol:aInterface];
    if ([self isInCreationMode]) {
        if ((protocol_conformsToProtocol(aInterface,@protocol(HSGeometryAttributes))) != NO) {
            return nil;
        }
    }
    if (![[HSTextObject textImplementationInterfaces] containsObject:pvVar2]) {
        return [super queryHyperInterface:aInterface];
    }
    if ([self coreTextInterface] == nil) {
        return nil;
    }
    return [[[HSTextObjectAttributesImplementation alloc] initWithHyperObject:self interfaces:[HSTextObject textImplementationInterfaces]] autorelease];
}

- (id)viewEmbeddingInterface
{
    return (id)@protocol(HSTextEditorEmbedder);
}

- (id)textEditorEmbedder
{
    return [self viewEmbedder];
}

- (id)initWithHyperObject:(id)aObject
{
    self = [super initWithHyperObject:aObject];
    return self;
}

@end

