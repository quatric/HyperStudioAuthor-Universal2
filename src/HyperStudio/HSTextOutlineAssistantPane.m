#import "HSTextOutlineAssistantPane.h"

@implementation HSTextOutlineAssistantPane

/* i386 ivar offsets: _outlineColorWell=0x5c, _outlineTypeMatrix=0x60, _observedTextViewAttributes=0x64, _observedTextObjectAttributes=0x68, _navigationPaneSwitcher=0x6c, _userMadeTheDecision=0x70 */

- (void)validateUI
{
    id pvVar1_2;

    [self validateOutlineMatrix];
    pvVar1_2 = [[self outlineAttributes] hyperOutlineColor];
    if (pvVar1_2 != nil) {
        [_outlineColorWell setColor:pvVar1_2];
    }
}

- (void)validateOutlineMatrix
{
    float fVar1;
    float fVar3;
    float fVar4;
    int uVar6;
    id pvVar2_2;
    float fVar3_2;
    float fVar3_3;
    float fVar4_2;
    float fVar4_3;

    fVar1 = (float)[[self outlineAttributes] hyperOutlineWidth];
    fVar3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
    fVar4 = 3.0;
    if (3.0 <= fVar3) {
        fVar4 = fVar3;
    }
    if (fVar4 * 0.0005 < fabs(fVar1 + 3.0)) {
        fVar3_2 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
        fVar4_2 = 5.0;
        if (5.0 <= fVar3_2) {
            fVar4_2 = fVar3_2;
        }
        if (fVar4_2 * 0.0005 < fabs(fVar1 + 5.0)) {
            fVar3_3 = fVar1 != 0.0 ? fabs(fVar1) : 1.0;
            fVar4_3 = 7.0;
            if (7.0 <= fVar3_3) {
                fVar4_3 = fVar3_3;
            }
            pvVar2_2 = _outlineTypeMatrix;
            if (fVar4_3 * 0.0005 < fabs(fVar1 + 7.0)) {
                uVar6 = 0;
            }
            else {
                uVar6 = 3;
            }
        }
        else {
            pvVar2_2 = _outlineTypeMatrix;
            uVar6 = 2;
        }
    }
    else {
        pvVar2_2 = _outlineTypeMatrix;
        uVar6 = 1;
    }
    [pvVar2_2 selectCellWithTag:uVar6];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)outlineTypeChanged:(id)aChanged
{
    CGFloat uVar2;

    if ([[aChanged selectedCell] tag] == 0x1) {
        uVar2 = -3.0;
    }
    else {
        if ([[aChanged selectedCell] tag] == 0x2) {
            uVar2 = -5.0;
        }
        else {
            if ([[aChanged selectedCell] tag] == 0x3) {
                uVar2 = -7.0;
            }
            else {
                uVar2 = 1.0;
            }
        }
    }
    [[self assistantPaneUndoManager] disableUndoRegistration];
    [[self outlineAttributes] setHyperOutlineWidth:uVar2];
    [[self assistantPaneUndoManager] enableUndoRegistration];
}

- (void)outlineColorChanged:(id)aChanged
{
    [[self assistantPaneUndoManager] disableUndoRegistration];
    [[self outlineAttributes] setHyperOutlineColor:[aChanged color]];
    [[self assistantPaneUndoManager] enableUndoRegistration];
}

- (id)helpTopicKey
{
    return @"HSOutlinePane";
}

- (id)outlineAttributes
{
    id pvVar1_3;

    pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSTextObjectAttributes)];
    if (pvVar1_3 == nil) {
        pvVar1_3 = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewFontTraitsAttributes)];
    }
    return pvVar1_3;
}

- (void)paneDidCancel:(id)aCancel
{
    _userMadeTheDecision = YES;
    [[self outlineAttributes] finishOutlineMutating:NO];
    [self dismiss:YES];
}

- (void)paneDidOK:(id)aOK
{
    _userMadeTheDecision = YES;
    [[self outlineAttributes] finishOutlineMutating:YES];
    [[self outlineAttributes] startOutlineMutating];
    [self dismiss:YES];
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self setObservedTextViewAttributes:nil];
    [self setObservedTextObjectAttributes:nil];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    id pvVar1;

    [super viewWillAppear:aAppear];
    if (_userMadeTheDecision != NO) {
        pvVar1 = [self outlineAttributes];
        [pvVar1 startOutlineMutating];
    }
    _userMadeTheDecision = NO;
    pvVar1 = [self assistantPaneUndoManager];
    [pvVar1 disableUndoRegistration];
    pvVar1 = [self outlineAttributes];
    [pvVar1 setHyperOutlineEnabled:YES];
    pvVar1 = [self assistantPaneUndoManager];
    [pvVar1 enableUndoRegistration];
    [self validateUI];
    pvVar1 = [[[self assistant] object] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    [self setObservedTextViewAttributes:pvVar1];
    pvVar1 = [[[self assistant] object] queryHyperInterface:@protocol(HSTextObjectAttributes)];
    [self setObservedTextObjectAttributes:pvVar1];
}

- (void)setObservedTextObjectAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_observedTextObjectAttributes != aAttributes) {
        pvVar2 = [_observedTextObjectAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes)];
        [_observedTextObjectAttributes release];
        pvVar2_2 = [aAttributes retain];
        _observedTextObjectAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes) withPriority:-0.25];
    }
}

- (void)setObservedTextViewAttributes:(id)aAttributes
{
    int uVar1;
    id pvVar2;
    id pvVar2_2;

    if (_observedTextViewAttributes != aAttributes) {
        pvVar2 = [_observedTextViewAttributes attributeObservingController];
        uVar1 = HSActualDidAttributeChanges;
        [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSSystemTextViewAttributes)];
        [_observedTextViewAttributes release];
        pvVar2_2 = [aAttributes retain];
        _observedTextViewAttributes = pvVar2_2;
        [[pvVar2_2 attributeObservingController] addObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSSystemTextViewAttributes) withPriority:-0.25];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00180029 @ 00180029, 186 bytes * /

id FUN_00180029(HSTextOutlineAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  undefined *puVar2;
  
  pvVar1 = _objc_msgSend(self,sel_assistant);
  pvVar1 = _objc_msgSend(pvVar1,sel_object);
  puVar2 = &DAT_00378a94;
  pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00378a94);
  op = sel_support;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_assistant,puVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_object);
    puVar2 = &DAT_00378af8;
    op = sel_queryHyperInterface_;
  }
  pvVar1 = _objc_msgSend(pvVar1,op,puVar2);
  pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
  return pvVar1;
}

*/
- (id)assistantPaneUndoManager
{
    id child = [[[self assistant] object] queryHyperInterface:@protocol(HSNodeChild)];
    id support;
    if (child != nil) {
        support = [child support];
    } else {
        support = [[[self assistant] object] queryHyperInterface:@protocol(HSNodeSupport)];
    }
    return [support undoManager];
    return 0;
}

- (void)viewDidLoad
{
    _userMadeTheDecision = YES;
    [_outlineColorWell setGradientSupportEnabled:NO];
    [_outlineTypeMatrix setBackgroundRenderer:[HSAssistantPaneControlBackgroundRenderer sharedBackgroundRenderer]];
}

- (BOOL)requiresDarkBottomArea
{
    return YES;
}

- (id)navigationPaneSwitcher
{
    HSObjectAssistantNavigationPaneSwitcher *pHVar1;
    HSObjectAssistantNavigationPaneSwitcher *pHVar1_2;

    pHVar1 = _navigationPaneSwitcher;
    if (pHVar1 == nil) {
        pHVar1_2 = [HSObjectAssistantNavigationPaneSwitcher new];
        _navigationPaneSwitcher = pHVar1_2;
        [pHVar1_2 setDelegate:self];
        pHVar1 = _navigationPaneSwitcher;
    }
    return pHVar1;
}

- (void)dealloc
{
    int uVar1;
    id pvVar2;

    pvVar2 = [_observedTextViewAttributes attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2 removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSSystemTextViewAttributes)];
    [_observedTextViewAttributes release];
    [[_observedTextObjectAttributes attributeObservingController] removeObserver:self selector:@selector(validateUIWithNotification:) ofChanges:uVar1 ofAttributesOfHyperInterface:@protocol(HSTextObjectAttributes)];
    [_observedTextObjectAttributes release];
    [_navigationPaneSwitcher setDelegate:0];
    [_navigationPaneSwitcher release];
    [super dealloc];
}

- (id)init
{
    self = [super initWithNibName:@"OutlineAssistantPane"];
    return self;
}

@end

