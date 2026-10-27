#import "HSPrintCardActionAssistantPane.h"

@implementation HSPrintCardActionAssistantPane

/* i386 ivar offsets: _printDialogCheckBox=0x88, _pageSetupDialogCheckBox=0x8c, _centerPrintoutCheckBox=0x90 */

- (void)updateCheckboxes
{
    id pvVar1;
    BOOL pvVar2;
    BOOL pvVar3;
    BOOL pvVar1_2;

    pvVar1 = [self actionAttributes];
    pvVar2 = [pvVar1 showPrintDialog];
    pvVar3 = [pvVar1 showPageSetupDialog];
    pvVar1_2 = [pvVar1 centerPrintout];
    [_printDialogCheckBox setState:pvVar2];
    [_pageSetupDialogCheckBox setState:pvVar3];
    [_centerPrintoutCheckBox setState:(unsigned int)(pvVar1_2)];
}

- (id)actionType
{
    return [HSPrintCardAction actionType];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self updateCheckboxes];
}

- (void)centerPrintoutCheckBoxStateChanged:(id)aChanged
{
    NSInteger pvVar1;

    pvVar1 = [aChanged state];
    [[self printCardActionAssistantPaneApplier] setCenterPrintout:(unsigned int)(pvVar1 == 0x1)];
}

- (void)pageSetupDialogCheckBoxStateChanged:(id)aChanged
{
    NSInteger pvVar1;

    pvVar1 = [aChanged state];
    [[self printCardActionAssistantPaneApplier] setShowPageSetupDialog:(unsigned int)(pvVar1 == 0x1)];
}

- (void)printDialogCheckBoxStateChanged:(id)aChanged
{
    NSInteger pvVar1;

    pvVar1 = [aChanged state];
    [[self printCardActionAssistantPaneApplier] setShowPrintDialog:(unsigned int)(pvVar1 == 0x1)];
}

- (id)initialKeyView
{
    return _pageSetupDialogCheckBox;
}

- (id)helpTopicKey
{
    return @"HSPrintCard";
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self updateCheckboxes];
    [self addActionAssistantPaneObserver];
}

- (id)actionAttribute
{
    return (id)@protocol(HSPrintCardActionAttributes);
}

- (id)actionAttributes
{
    return [[self printCardActionAssistantPaneApplier] printCardActionAttributes];
}

- (id)printCardActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSPrintCardActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"PrintCardAssistantPane"];
    return self;
}

@end

@implementation HSPrintCardActionAssistantPaneApplier

/* i386 ivar offsets: _initialNeedsShowPageSetupDialog=0x30, _initialNeedsShowPrintDialog=0x31, _initialNeedsCenterPrintout=0x32, _needsShowPageSetupDialog=0x33, _needsShowPrintDialog=0x34, _needsCenterPrintout=0x35 */

- (BOOL)areSettingsEqual
{
    BOOL bVar2;

    if (((![super areSettingsEqual]) || (_initialNeedsShowPageSetupDialog != _needsShowPageSetupDialog)) || (_initialNeedsShowPrintDialog != _needsShowPrintDialog)) {
        bVar2 = NO;
    }
    else {
        bVar2 = _initialNeedsCenterPrintout == _needsCenterPrintout;
    }
    return bVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    _needsShowPrintDialog = _initialNeedsShowPrintDialog;
    _needsShowPageSetupDialog = _initialNeedsShowPageSetupDialog;
    _needsCenterPrintout = _initialNeedsCenterPrintout;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    _initialNeedsShowPrintDialog = _needsShowPrintDialog;
    _initialNeedsShowPageSetupDialog = _needsShowPageSetupDialog;
    _initialNeedsCenterPrintout = _needsCenterPrintout;
}

- (void)setInitialSettingsToObject
{
    [[self printCardActionAttributes] setShowPrintDialog:_initialNeedsShowPrintDialog];
    [[self printCardActionAttributes] setShowPageSetupDialog:_initialNeedsShowPageSetupDialog];
    [[self printCardActionAttributes] setCenterPrintout:_initialNeedsCenterPrintout];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self printCardActionAttributes] setShowPrintDialog:_needsShowPrintDialog];
    [[self printCardActionAttributes] setShowPageSetupDialog:_needsShowPageSetupDialog];
    [[self printCardActionAttributes] setCenterPrintout:_needsCenterPrintout];
}

- (void)setCenterPrintout:(BOOL)aPrintout
{
    if (_needsCenterPrintout != aPrintout) {
        _needsCenterPrintout = aPrintout;
        [self disableUndo];
        [[self printCardActionAttributes] setCenterPrintout:aPrintout];
        [self enableUndo];
    }
}

- (void)setShowPrintDialog:(BOOL)aDialog
{
    if (_needsShowPrintDialog != aDialog) {
        _needsShowPrintDialog = aDialog;
        [self disableUndo];
        [[self printCardActionAttributes] setShowPrintDialog:aDialog];
        [self enableUndo];
    }
}

- (void)setShowPageSetupDialog:(BOOL)aDialog
{
    if (_needsShowPageSetupDialog != aDialog) {
        _needsShowPageSetupDialog = aDialog;
        [self disableUndo];
        [[self printCardActionAttributes] setShowPageSetupDialog:aDialog];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    BOOL pvVar1_2;
    BOOL pvVar1_4;
    BOOL pvVar1_6;

    pvVar1_2 = [[self printCardActionAttributes] showPageSetupDialog];
    _needsShowPageSetupDialog = (BOOL)pvVar1_2;
    _initialNeedsShowPageSetupDialog = (BOOL)pvVar1_2;
    pvVar1_4 = [[self printCardActionAttributes] showPrintDialog];
    _needsShowPrintDialog = (BOOL)pvVar1_4;
    _initialNeedsShowPrintDialog = (BOOL)pvVar1_4;
    pvVar1_6 = [[self printCardActionAttributes] centerPrintout];
    _needsCenterPrintout = (BOOL)pvVar1_6;
    _initialNeedsCenterPrintout = (BOOL)pvVar1_6;
}

- (id)printCardActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSPrintCardActionAttributes)];
}

@end

