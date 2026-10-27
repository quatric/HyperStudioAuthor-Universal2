#import "HSTextAppearanceAssistantPane.h"

@implementation HSTextAppearanceAssistantPane

/* i386 ivar offsets: _nameTextField=0x5c, _textTypeMatrix=0x60, _drawScrollBarButton=0x64, _drawFrameButton=0x68, _readOnlyButton=0x6c, _scrollableButton=0x70, _hasBackgroundColorButton=0x74, _textColorWell=0x78, _backgroundColorWell=0x7c, _backgroundTextField=0x80 */

+ (BOOL)canEditObject:(id)aObject
{
    return (BOOL)[aObject implementsHyperInterface:@protocol(HSSystemTextViewAttributes)];
}

- (void)validateScrollBoxControls:(BOOL)aControls
{
    unsigned int uVar1;

    uVar1 = (unsigned int)(aControls == NO);
    [_drawScrollBarButton setEnabled:uVar1];
    [_drawFrameButton setEnabled:uVar1];
    [_readOnlyButton setEnabled:uVar1];
    [_scrollableButton setEnabled:uVar1];
    [_hasBackgroundColorButton setEnabled:uVar1];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017aa7d @ 0017aa7d, 645 bytes * /

void FUN_0017aa7d(HSTextAppearanceAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined *puVar4;
  uint uVar5;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar4 = &DAT_003777fc;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003777fc);
  if (pvVar1 != (id)0x0) {
    pvVar3 = self->_textTypeMatrix;
    pvVar2 = _objc_msgSend(pvVar1,sel_isRotatableText,puVar4);
    _objc_msgSend(pvVar3,sel_selectCellWithTag_,(uint)((char)pvVar2 == '\0'));
    pvVar3 = _objc_msgSend(pvVar1,sel_isRotatableText);
    _objc_msgSend(self,sel_validateScrollBoxControls_,(int)(char)pvVar3);
    pvVar3 = self->_drawFrameButton;
    pvVar2 = _objc_msgSend(pvVar1,sel_borderType);
    _objc_msgSend(pvVar3,sel_setState_,pvVar2);
    pvVar3 = self->_drawScrollBarButton;
    pvVar2 = _objc_msgSend(pvVar1,sel_hasVerticalScroller);
    _objc_msgSend(pvVar3,sel_setState_,(int)(char)pvVar2);
    pvVar3 = self->_readOnlyButton;
    pvVar2 = _objc_msgSend(pvVar1,sel_isEditable);
    _objc_msgSend(pvVar3,sel_setState_,(uint)((char)pvVar2 == '\0'));
    pvVar3 = self->_scrollableButton;
    pvVar2 = _objc_msgSend(pvVar1,sel_isScrollable);
    _objc_msgSend(pvVar3,sel_setState_,(int)(char)pvVar2);
    pvVar3 = self->_textColorWell;
    pvVar2 = _objc_msgSend(pvVar1,sel_textColor);
    _objc_msgSend(pvVar3,sel_setColor_,pvVar2);
    pvVar3 = _objc_msgSend(pvVar1,sel_backgroundColor);
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(self->_backgroundColorWell,sel_setColor_,pvVar3);
      pvVar2 = pvVar3;
    }
    pvVar3 = _objc_msgSend(pvVar1,sel_isTransparent,pvVar2);
    uVar5 = (uint)((char)pvVar3 == '\0');
    _objc_msgSend(self->_hasBackgroundColorButton,sel_setState_,uVar5);
    _objc_msgSend(self->_backgroundColorWell,sel_setEnabled_,uVar5);
    pvVar1 = self->_backgroundTextField;
    op = sel_blackColor;
    if ((char)pvVar3 != '\0') {
      op = sel_disabledControlTextColor;
    }
    pvVar3 = _objc_msgSend(cls_NSColor,op,uVar5);
    _objc_msgSend(pvVar1,sel_setTextColor_,pvVar3);
  }
  return;
}

*/
- (void)validateUI
{
    [self validateSystemTextViewUI];
    [self validateObjectName];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateObjectName];
}

- (void)setHasBackgroundColor:(id)aColor
{
    id pvVar1_3;

    pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    if (pvVar1_3 != nil) {
        [pvVar1_3 setTransparent:(unsigned int)([aColor state] == 0)];
    }
}

- (void)setTextType:(id)aType
{
    id pvVar1_3;

    pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    if (pvVar1_3 != nil) {
        [pvVar1_3 setRotatableText:(unsigned int)([[aType selectedCell] tag] == 0) autoresizing:YES];
    }
}

- (void)backgroundColorChanged:(id)aChanged
{
    id pvVar1_3;

    pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    if (pvVar1_3 != nil) {
        [pvVar1_3 setBackgroundColor:[aChanged color]];
    }
}

- (void)textColorChanged:(id)aChanged
{
    id pvVar1_3;

    pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    if (pvVar1_3 != nil) {
        [pvVar1_3 setTextColor:[aChanged color]];
    }
}

- (void)scrollableChanged:(id)aChanged
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setScrollable:(unsigned int)([aChanged state] == 0x1)];
}

- (void)setDrawVerticalScroller:(id)aScroller
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setHasVerticalScroller:(unsigned int)([aScroller state] == 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017b0f4 @ 0017b0f4, 483 bytes * /

void FUN_0017b0f4(HSTextAppearanceAssistantPane *self,SEL _cmd,id getFile)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *puVar4;
  
  pvVar1 = _objc_msgSend(cls_HSOpenPanelProvider,sel_sharedOpenPanelProvider);
  pvVar1 = _objc_msgSend(pvVar1,sel_chooseFileOfType_,*(undefined4 *)PTR_00336660);
  pvVar2 = _objc_msgSend(self,sel_assistant);
  pvVar2 = _objc_msgSend(pvVar2,sel_object);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003777fc);
  if ((pvVar1 != (id)0x0) && (pvVar2 != (id)0x0)) {
    _objc_msgSend(pvVar2,sel_setHyperTextFilePath_,pvVar1);
  }
  puVar4 = &DAT_003776e4;
  pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_003776e4);
  if (pvVar2 != (id)0x0) {
    pvVar3 = self->_nameTextField;
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperName,puVar4);
    _objc_msgSend(pvVar3,sel_setStringValue_,pvVar2);
  }
  puVar4 = cls_HSEditorCardViewDragHelper;
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar1);
    pvVar1 = _objc_msgSend(puVar4,sel_commentsForDroppedObjectWithURL_,pvVar1);
    pvVar2 = _objc_msgSend(self,sel_assistant);
    pvVar2 = _objc_msgSend(pvVar2,sel_object);
    puVar4 = &DAT_00377a04;
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00377a04);
    if (pvVar1 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar1,sel_length,puVar4);
      if (pvVar3 != (id)0x0) {
        pvVar3 = _objc_msgSend(pvVar2,sel_hyperComments,puVar4);
        pvVar3 = _objc_msgSend(pvVar3,sel_hasHyperSubstring_,pvVar1);
        if (pvVar3 == (id)0x0) {
          _objc_msgSend(pvVar2,sel_appendHyperComments_,pvVar1);
        }
      }
    }
  }
  return;
}

*/
- (void)getFile:(id)aFile
{
    id path = [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:kHSTextFileType];
    id textAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    if (path != nil && textAttributes != nil) {
        [textAttributes setHyperTextFilePath:path];
    }
    id objectAttributes = [textAttributes queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    if (objectAttributes != nil) {
        [_nameTextField setStringValue:[objectAttributes hyperName]];
    }
    if (path != nil) {
        id comments = [HSEditorCardViewDragHelper commentsForDroppedObjectWithURL:[NSURL fileURLWithPath:path]];
        id commentsAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSCommentsAttributes)];
        if (comments != nil && [comments length] != 0) {
            if (![[commentsAttributes hyperComments] hasHyperSubstring:comments]) {
                [commentsAttributes appendHyperComments:comments];
            }
        }
    }
}

- (void)editableChanged:(id)aChanged
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setEditable:(unsigned int)([aChanged state] != 0x1) setByUser:YES];
}

- (void)setName:(id)aName
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] setHyperName:[aName stringValue]];
}

- (void)setDrawFrame:(id)aFrame
{
    [[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setBorderType:(unsigned int)([aFrame state] == 0x1) * 2];
}

- (BOOL)isEditingTextAttribute
{
    return [_nameTextField currentEditor] != nil;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    int uVar1;
    id pvVar2_4;

    [super viewWillDisappear:aDisappear];
    pvVar2_4 = [[[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_4 removeObserver:self selector:@selector(validateSystemTextViewUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSSystemTextViewAttributes)];
    [[[[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)] attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0017b5fe @ 0017b5fe, 377 bytes * /

void FUN_0017b5fe(HSTextAppearanceAssistantPane *self,SEL _cmd,BOOL viewWillAppear)

{
  id pvVar1;
  undefined4 uVar2;
  HSTextAppearanceAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSObjectAssistantPane_00352580;
  _objc_msgSendSuper(&local_1c,sel_viewWillAppear_,(int)viewWillAppear);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003776e4);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  uVar2 = *(undefined4 *)PTR_0033601c;
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateUIWithNotification_,uVar2,&DAT_003776e4,0xbe800000,uVar2);
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003777fc);
  pvVar1 = _objc_msgSend(pvVar1,sel_attributeObservingController);
  _objc_msgSend(pvVar1,sel_addObserver_selector_ofChanges_ofAttributesOfHyperInterface_withPriority_
                ,self,sel_validateSystemTextViewUIWithNotification_,uVar2,&DAT_003777fc,0xbe800000);
  _objc_msgSend(self,sel_validateUI);
  return;
}

*/
- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    id objectAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSMutableObjectAttributes)];
    [[objectAttributes attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSMutableObjectAttributes) withPriority:-0.25];
    id textAttributes = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    [[textAttributes attributeObservingController] addObserver:self selector:@selector(validateSystemTextViewUIWithNotification:) ofChanges:HSActualDidAttributeChanges ofAttributesOfHyperInterface:@protocol(HSSystemTextViewAttributes) withPriority:-0.25];
    [self validateUI];
}

- (void)viewDidLoad
{
    [_textColorWell setPatternSupportEnabled:YES];
    [_textColorWell setGradientSupportEnabled:YES];
    [_backgroundColorWell setPatternSupportEnabled:YES];
    [_backgroundColorWell setGradientSupportEnabled:NO];
}

- (id)init
{
    self = [super initWithNibName:@"TextAppearanceAssistantPane"];
    if (self != nil) {
        [self setTitle:[[NSBundle mainBundle] localizedStringForKey:@"Appearance" value:@"" table:@"AssistantPanes"]];
        [self setIcon:[NSImage imageNamed:@"general"]];
    }
    return self;
}

@end

