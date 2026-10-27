#import "HSAutoScrollActionAssistantPane.h"

@implementation HSAutoScrollActionAssistantPane

/* i386 ivar offsets: _tableView=0x88, _textNameCombobox=0x8c, _containerView=0x90, _mainView=0x94, _emptyView=0x98, _numberOfStepsField=0x9c, _stepsPerSecondField=0xa0, _scrollUnitsMatrix=0xa4, _scrollAmountField=0xa8, _ignoreMouseClicksButton=0xac, _testSpeedButton=0xb0, _scrollDirectionMatrix=0xb4, _currentView=0xb8, _availableTextViews=0xbc, _actionSynchronizer=0xc0, _playImage=0xc4, _stopImage=0xc8, _pressedPlayImage=0xcc, _pressedStopImage=0xd0 */

- (void)invalidateActionSynchronizer
{
    [_actionSynchronizer stop:self];
    [_actionSynchronizer release];
    _actionSynchronizer = nil;
}

- (void)actionSynchronizerDidFinishPerformActions:(id)aActions
{
    id pvVar1_3;
    id pvVar1_4;

    [_actionSynchronizer release];
    _actionSynchronizer = nil;
    pvVar1_3 = [[[self actionAttributes] textViewUIDs] objectAtIndex:0];
    pvVar1_4 = [[self card] childInTreeWithUID:pvVar1_3];
    [pvVar1_4 setVerticalScrollPosition:0];
    [pvVar1_4 setHorizontalScrollPosition:0];
    [self setUpPlayButton];
}

- (BOOL)isScrolling
{
    return _actionSynchronizer != nil;
}

- (void)setUpPauseButton
{
    [_testSpeedButton setImage:_stopImage];
    [_testSpeedButton setAlternateImage:_pressedStopImage];
    [self setOptionsEnabled:NO];
}

- (void)setUpPlayButton
{
    [_testSpeedButton setImage:_playImage];
    [_testSpeedButton setAlternateImage:_pressedPlayImage];
    [self setOptionsEnabled:YES];
}

- (void)setOptionsEnabled:(BOOL)aEnabled
{
    int iVar1;

    iVar1 = (int)aEnabled;
    [_textNameCombobox setEnabled:iVar1];
    [_numberOfStepsField setEnabled:iVar1];
    [_stepsPerSecondField setEnabled:iVar1];
    [_ignoreMouseClicksButton setEnabled:iVar1];
    [_scrollUnitsMatrix setEnabled:iVar1];
    [_scrollAmountField setEnabled:iVar1];
    [_scrollDirectionMatrix setEnabled:iVar1];
}

- (void)validateUI
{
    [self validateTextNames];
    [self validateScrollSpeed];
    [self validateScrollAmount];
    [self validateScrollDirection];
    [self validateIgnoreMouseClicksButton];
    [self validateTestSpeedButton];
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)controlTextDidEndEditing:(id)aEditing
{
    BOOL uVar3;
    NSInteger pvVar1_2;
    NSString *pvVar1_4;
    id pvVar1_6;
    id pvVar2_4;

    if ([aEditing object] == _textNameCombobox) {
        pvVar1_2 = [_textNameCombobox indexOfSelectedItem];
        if (pvVar1_2 == 0xffffffff) {
            pvVar1_4 = [[aEditing object] stringValue];
            if (pvVar1_4 != nil) {
                if (![pvVar1_4 isEqualToString:@""]) {
                    [[self autoScrollActionAssistantPaneApplier] setTextViewNames:[NSArray arrayWithObject:pvVar1_4]];
                }
            }
            pvVar1_6 = _testSpeedButton;
            uVar3 = 0;
        }
        else {
            pvVar2_4 = [[self availableTextViews] objectAtIndex:pvVar1_2];
            if (pvVar2_4 == nil) {
                return;
            }
            [[self autoScrollActionAssistantPaneApplier] setTextViewUIDs:[NSArray arrayWithObject:[pvVar2_4 hyperUID]]];
            pvVar1_6 = _testSpeedButton;
            uVar3 = 1;
        }
        [pvVar1_6 setEnabled:uVar3];
    }
}

- (NSUInteger)comboBox:(id)aBox indexOfItemWithStringValue:(id)aValue
{
    id pvVar1;
    NSUInteger pvVar3;
    NSUInteger pvVar1_2;

    pvVar1 = [self availableTextViews];
    pvVar3 = 0;
    pvVar1_2 = [pvVar1 count];
    while( YES ) {
        if (pvVar1_2 <= pvVar3) {
            return 0xffffffff;
        }
        if ([[[[self availableTextViews] objectAtIndex:pvVar3] hyperName] isEqualToString:aValue]) break;
        pvVar3 = (pvVar3 + 1);
    }
    return (unsigned int)pvVar3;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e8470 @ 000e8470, 324 bytes * /

id FUN_000e8470(HSAutoScrollActionAssistantPane *self,SEL _cmd,id comboBox,id completedString)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  
  pvVar1 = _objc_msgSend(self,sel_availableTextViews);
  pvVar5 = (id)0x0;
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  do {
    if (pvVar1 <= pvVar5) {
LAB_000e8588:
      pvVar1 = _objc_msgSend(completedString,sel_retain);
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
      return pvVar1;
    }
    pvVar2 = _objc_msgSend(self,sel_availableTextViews);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar5);
    pvVar3 = _objc_msgSend(pvVar2,sel_hyperName);
    pvVar4 = _objc_msgSend(completedString,sel_length);
    uVar7 = 0;
    uVar6 = 1;
    pvVar2 = completedString;
    pvVar3 = _objc_msgSend(pvVar3,sel_compare_options_range_,completedString,1,0,pvVar4);
    if (pvVar3 == (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_availableTextViews,pvVar2,uVar6,uVar7,pvVar4);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pvVar5);
      completedString = _objc_msgSend(pvVar1,sel_hyperName);
      goto LAB_000e8588;
    }
    pvVar5 = (id)((int)pvVar5 + 1);
  } while( true );
}

*/
- (id)comboBox:(id)aBox completedString:(id)aString
{
    NSUInteger count = [[self availableTextViews] count];
    for (NSUInteger index = 0; index < count; index++) {
        NSString *name = [[[self availableTextViews] objectAtIndex:index] hyperName];
        if ([name compare:aString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [aString length])] == NSOrderedSame) {
            aString = [[[self availableTextViews] objectAtIndex:index] hyperName];
            break;
        }
    }
    return [[aString retain] autorelease];
    return 0;
}

- (id)comboBox:(id)aBox objectValueForItemAtIndex:(NSInteger)aIndex
{
    id pvVar1_2;

    if ([self availableTextViews] == nil) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [[[[self availableTextViews] objectAtIndex:aIndex] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    }
    return pvVar1_2;
}

- (NSInteger)numberOfItemsInComboBox:(id)aBox
{
    return (int)[[self availableTextViews] count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e8251 @ 000e8251, 344 bytes * /

void FUN_000e8251(HSAutoScrollActionAssistantPane *self,SEL _cmd,id controlTextDidChange)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(controlTextDidChange,sel_object);
  _objc_msgSend(pvVar1,sel_validateEditing);
  pvVar3 = self->_numberOfStepsField;
  pvVar2 = _objc_msgSend(pvVar1,sel_isEqual_,pvVar3);
  if ((char)pvVar2 == '\0') {
    pvVar3 = self->_stepsPerSecondField;
    pvVar2 = _objc_msgSend(pvVar1,sel_isEqual_,pvVar3);
    if ((char)pvVar2 == '\0') {
      pvVar3 = self->_scrollAmountField;
      pvVar1 = _objc_msgSend(pvVar1,sel_isEqual_,pvVar3);
      if ((char)pvVar1 == '\0') {
        return;
      }
      pvVar3 = _objc_msgSend(self,sel_autoScrollActionAssistantPaneApplier,pvVar3);
      pvVar1 = _objc_msgSend(self->_scrollAmountField,sel_intValue);
      op = sel_setScrollAmount_;
    }
    else {
      pvVar3 = _objc_msgSend(self,sel_autoScrollActionAssistantPaneApplier,pvVar3);
      pvVar1 = _objc_msgSend(self->_stepsPerSecondField,sel_intValue);
      op = sel_setStepsPerSecond_;
    }
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_autoScrollActionAssistantPaneApplier,pvVar3);
    pvVar1 = _objc_msgSend(self->_numberOfStepsField,sel_intValue);
    op = sel_setNumberOfSteps_;
  }
  _objc_msgSend(pvVar3,op,pvVar1);
  return;
}

*/
- (void)controlTextDidChange:(id)aChange
{
    id field = [aChange object];
    [field validateEditing];
    if ([field isEqual:_numberOfStepsField]) {
        [[self autoScrollActionAssistantPaneApplier] setNumberOfSteps:[_numberOfStepsField intValue]];
    } else if ([field isEqual:_stepsPerSecondField]) {
        [[self autoScrollActionAssistantPaneApplier] setStepsPerSecond:[_stepsPerSecondField intValue]];
    } else if ([field isEqual:_scrollAmountField]) {
        [[self autoScrollActionAssistantPaneApplier] setScrollAmount:[_scrollAmountField intValue]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e80fd @ 000e80fd, 340 bytes * /

void FUN_000e80fd(HSAutoScrollActionAssistantPane *self,SEL _cmd,id testSpeed)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  SEL op;
  
  if (self->_actionSynchronizer == (id)0x0) {
    pvVar1 = _objc_msgSend(cls_HSActionSynchronizer,sel_alloc);
    self_00 = cls_NSArray;
    pvVar2 = _objc_msgSend(self,sel_actionAttributes);
    pvVar2 = _objc_msgSend(self_00,sel_arrayWithObject_,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithActions_,pvVar2);
    self->_actionSynchronizer = pvVar1;
    _objc_msgSend(pvVar1,sel_setDelegate_,self);
    pvVar1 = _objc_msgSend(self,sel_actionAttributes);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0036d2ac);
    pvVar1 = _objc_msgSend(pvVar1,sel_document);
    pvVar1 = _objc_msgSend(pvVar1,sel_actionExecutionContext);
    _objc_msgSend(self->_actionSynchronizer,sel_startInContext_,pvVar1);
    op = sel_setUpPauseButton;
  }
  else {
    _objc_msgSend(self,sel_setUpPlayButton);
    op = sel_invalidateActionSynchronizer;
  }
  _objc_msgSend(self,op);
  return;
}

*/
- (void)testSpeed:(id)aSpeed
{
    if (_actionSynchronizer == nil) {
        _actionSynchronizer = [[HSActionSynchronizer alloc] initWithActions:[NSArray arrayWithObject:[self actionAttributes]]];
        [_actionSynchronizer setDelegate:self];
        id document = [[[self actionAttributes] queryHyperInterface:@protocol(HSUserObjectSupport)] document];
        [_actionSynchronizer startInContext:[document actionExecutionContext]];
        [self setUpPauseButton];
    } else {
        [self setUpPlayButton];
        [self invalidateActionSynchronizer];
    }
}

- (void)ignoreMouseClicksStateChanged:(id)aChanged
{
    [[self autoScrollActionAssistantPaneApplier] setIgnoreMouseClicks:(unsigned int)([aChanged state] == 0x1)];
}

- (void)scrollUnitsChanged:(id)aChanged
{
    NSInteger pvVar1_2;

    pvVar1_2 = [[aChanged selectedCell] tag];
    [[self autoScrollActionAssistantPaneApplier] setScrollUnits:(unsigned int)(pvVar1_2 == 0)];
    [_scrollAmountField setEnabled:(unsigned int)(pvVar1_2 != 0)];
}

- (void)scrollAmountChanged:(id)aChanged
{
    [[self autoScrollActionAssistantPaneApplier] setScrollAmount:[aChanged intValue]];
}

- (void)stepsPerSecondChanged:(id)aChanged
{
    [[self autoScrollActionAssistantPaneApplier] setStepsPerSecond:[aChanged intValue]];
}

- (void)numberOfStepsChanged:(id)aChanged
{
    [[self autoScrollActionAssistantPaneApplier] setNumberOfSteps:[aChanged intValue]];
}

- (void)scrollDirectionChanged:(id)aChanged
{
    NSInteger pvVar1_2;

    pvVar1_2 = [[aChanged selectedCell] tag];
    [[self autoScrollActionAssistantPaneApplier] setScrollDirection:(unsigned int)(pvVar1_2 != 0)];
}

- (void)textNameChanged:(id)aChanged
{
    BOOL uVar3;
    NSInteger pvVar1_3;
    id pvVar1_4;
    id pvVar2_2;

    if ([[self availableTextViews] count] != 0) {
        pvVar1_3 = [_textNameCombobox indexOfSelectedItem];
        if (pvVar1_3 == 0xffffffff) {
            pvVar1_4 = _testSpeedButton;
            uVar3 = 0;
        }
        else {
            pvVar2_2 = [[self availableTextViews] objectAtIndex:pvVar1_3];
            if (pvVar2_2 == nil) {
                return;
            }
            [[self autoScrollActionAssistantPaneApplier] setTextViewUIDs:[NSArray arrayWithObject:[pvVar2_2 hyperUID]]];
            pvVar1_4 = _testSpeedButton;
            uVar3 = 1;
        }
        [pvVar1_4 setEnabled:uVar3];
    }
}

- (id)helpTopicKey
{
    return @"HSRollCredits";
}

- (void)dealloc
{
    [_playImage release];
    [_stopImage release];
    [_pressedPlayImage release];
    [_pressedStopImage release];
    [self invalidateActionSynchronizer];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e92cc @ 000e92cc, 571 bytes * /

void FUN_000e92cc(HSAutoScrollActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  undefined *puVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  cfstringStruct *pcVar5;
  HSAutoScrollActionAssistantPane *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSNBAAssistantPane_00350720;
  _objc_msgSendSuper(&local_1c,sel_viewDidLoad);
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pcVar3 = &cfstr_N;
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Play,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_playImage = pvVar1;
  pvVar1 = _objc_msgSend(cls_HSPlaybackControlImagesProvider,
                         sel_sharedPlaybackControlsImagesProvider);
  pcVar5 = &cfstr_A;
  pcVar4 = &cfstr_L;
  pvVar1 = _objc_msgSend(pvVar1,sel_playbackImageOfType_state_size_tint_,&cfstr_Pause,&cfstr_N,
                         &cfstr_L,&cfstr_A);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_stopImage = pvVar1;
  puVar2 = sel_currentControlTint;
  pvVar1 = _objc_msgSend(cls_NSColor,sel_respondsToSelector_,sel_currentControlTint);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(cls_NSColor,sel_currentControlTint,puVar2,pcVar3,pcVar4,pcVar5);
    if (pvVar1 == (id)0x6) {
      pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Play_Graphite,pcVar3,pcVar4,pcVar5);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      self->_pressedPlayImage = pvVar1;
      pcVar3 = &cfstr_Pause_Graphite;
      pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Pause_Graphite);
      goto LAB_000e9483;
    }
  }
  pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Play_Aqua,pcVar3,pcVar4,pcVar5);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_pressedPlayImage = pvVar1;
  pcVar3 = &cfstr_Pause_Aqua;
  pvVar1 = _objc_msgSend(cls_NSImage,sel_imageNamed_,&cfstr_Pause_Aqua);
LAB_000e9483:
  pvVar1 = _objc_msgSend(pvVar1,sel_retain,pcVar3);
  self->_pressedStopImage = pvVar1;
  return;
}

*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    _playImage = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Play" state:@"N" size:@"L" tint:@"A"] retain];
    _stopImage = [[[HSPlaybackControlImagesProvider sharedPlaybackControlsImagesProvider] playbackImageOfType:@"Pause" state:@"N" size:@"L" tint:@"A"] retain];
    if ([NSColor respondsToSelector:@selector(currentControlTint)] && [NSColor currentControlTint] == NSGraphiteControlTint) {
        _pressedPlayImage = [[NSImage imageNamed:@"Play_Graphite"] retain];
        _pressedStopImage = [[NSImage imageNamed:@"Pause_Graphite"] retain];
    } else {
        _pressedPlayImage = [[NSImage imageNamed:@"Play_Aqua"] retain];
        _pressedStopImage = [[NSImage imageNamed:@"Pause_Aqua"] retain];
    }
}

- (id)initialKeyView
{
    return _textNameCombobox;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [_availableTextViews release];
    _availableTextViews = nil;
    [self invalidateActionSynchronizer];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    id self_00;
    NSUInteger pvVar1_4;

    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self mountView:_mainView];
    [self setUpPlayButton];
    [_textNameCombobox setCompletes:YES];
    [_textNameCombobox reloadData];
    self_00 = _textNameCombobox;
    if ([[self availableTextViews] count] < 0x6) {
        pvVar1_4 = [[self availableTextViews] count];
    }
    else {
        pvVar1_4 = 0x5;
    }
    [self_00 setNumberOfVisibleItems:pvVar1_4];
    [self validateUI];
    [self setDefaultActionAttributes];
}

- (void)setDefaultActionAttributes
{
    NSInteger pvVar1_3;
    id pvVar2_2;

    if ([[self availableTextViews] count] != 0) {
        pvVar1_3 = [_textNameCombobox indexOfSelectedItem];
        if (pvVar1_3 != 0xffffffff) {
            pvVar2_2 = [[self availableTextViews] objectAtIndex:pvVar1_3];
            if (pvVar2_2 != nil) {
                [[self autoScrollActionAssistantPaneApplier] setTextViewUIDs:[NSArray arrayWithObject:[pvVar2_2 hyperUID]]];
            }
        }
    }
}

- (id)actionAttribute
{
    return (id)@protocol(HSAutoScrollActionAttributes);
}

- (void)validateTestSpeedButton
{
    [_testSpeedButton setEnabled:(unsigned int)([[self availableTextViews] count] != 0)];
}

- (void)validateIgnoreMouseClicksButton
{
    [_ignoreMouseClicksButton setState:(unsigned int)([[self actionAttributes] ignoreMouseClicks])];
}

- (void)validateScrollSpeed
{
    id pvVar1;

    pvVar1 = [self actionAttributes];
    [_numberOfStepsField setIntValue:[pvVar1 numberOfSteps]];
    [_stepsPerSecondField setIntValue:[pvVar1 stepsPerSecond]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e7a87 @ 000e7a87, 113 bytes * /

void FUN_000e7a87(HSAutoScrollActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_actionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_scrollDirection);
  _objc_msgSend(self->_scrollDirectionMatrix,sel_selectCellWithTag_,(uint)(pvVar1 != (id)0x0));
  return;
}

*/
- (void)validateScrollDirection
{
    [_scrollDirectionMatrix selectCellWithTag:([[self actionAttributes] scrollDirection] != 0)];
}

- (void)validateScrollAmount
{
    id pvVar1;

    pvVar1 = [self actionAttributes];
    [_scrollAmountField setIntValue:[pvVar1 scrollAmount]];
    [_scrollUnitsMatrix selectCellWithTag:(unsigned int)([pvVar1 scrollUnits] != 0x1)];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e788b @ 000e788b, 355 bytes * /

void FUN_000e788b(HSAutoScrollActionAssistantPane *self,SEL _cmd)

{
  id pvVar1;
  cfstringStruct *pcVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_availableTextViews);
  pcVar2 = _objc_msgSend(pvVar1,sel_count);
  if (pcVar2 == (cfstringStruct *)0x0) {
    pvVar1 = self->_textNameCombobox;
    pcVar5 = &cfstr_empty;
    op = sel_setObjectValue_;
  }
  else {
    pvVar1 = _objc_msgSend(self,sel_actionAttributes);
    pvVar3 = _objc_msgSend(pvVar1,sel_textViewUIDs);
    pvVar3 = _objc_msgSend(pvVar3,sel_count);
    if (pvVar3 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar1,sel_textViewUIDs);
      pvVar1 = (id)0x0;
      pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0);
      for (pcVar5 = (cfstringStruct *)0x0; pcVar5 < pcVar2;
          pcVar5 = (cfstringStruct *)((int)&pcVar5->field0_0x0 + 1)) {
        pvVar1 = _objc_msgSend(self,sel_availableTextViews,pvVar1);
        pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,pcVar5);
        pvVar4 = _objc_msgSend(pvVar1,sel_hyperUID);
        pvVar1 = pvVar3;
        pvVar4 = _objc_msgSend(pvVar4,sel_isEqual_);
        if ((char)pvVar4 != '\0') goto LAB_000e790d;
      }
    }
    pcVar5 = (cfstringStruct *)0x0;
LAB_000e790d:
    pvVar1 = self->_textNameCombobox;
    op = sel_selectItemAtIndex_;
  }
  _objc_msgSend(pvVar1,op,pcVar5);
  return;
}

*/
- (void)validateTextNames
{
    NSUInteger count = [[self availableTextViews] count];
    if (count == 0) {
        [_textNameCombobox setObjectValue:@""];
        return;
    }
    id attributes = [self actionAttributes];
    NSUInteger selected = 0;
    if ([[attributes textViewUIDs] count] != 0) {
        id uid = [[attributes textViewUIDs] objectAtIndex:0];
        for (NSUInteger index = 0; index < count; index++) {
            if ([[[[self availableTextViews] objectAtIndex:index] hyperUID] isEqual:uid]) {
                selected = index;
                break;
            }
        }
    }
    [_textNameCombobox selectItemAtIndex:selected];
}

- (void)mountView:(id)aView
{
    if (_currentView != aView) {
        [_currentView removeFromSuperview];
        [_containerView addSubview:aView];
        _currentView = aView;
    }
}

- (id)availableTextViews
{
    id pvVar1;
    id pvVar1_3;
    id pvVar1_5;
    NSEnumerator *pvVar2_2;

    if ((_availableTextViews == nil) && (pvVar1 = [self card], pvVar1 != nil)) {
        pvVar1_3 = [[self card] queryHyperInterface:@protocol(HSNodeContainer)];
        _availableTextViews = [NSMutableArray new];
        pvVar2_2 = [[pvVar1_3 hyperChildren] objectEnumerator];
        pvVar1_5 = [pvVar2_2 nextObject];
        while (pvVar1_5 != nil) {
            if ([pvVar1_5 implementsHyperInterface:@protocol(HSSystemTextViewAttributes)]) {
                [_availableTextViews addObject:[pvVar1_5 queryHyperInterface:@protocol(HSObjectAttributes)]];
            }
            pvVar1_5 = [pvVar2_2 nextObject];
        }
    }
    return _availableTextViews;
}

- (id)actionType
{
    return [HSAutoScrollAction actionType];
}

- (id)actionAttributes
{
    return [[self autoScrollActionAssistantPaneApplier] autoScrollActionAttributes];
}

- (id)autoScrollActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSAutoScrollActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"AutoScrollAssistantPane"];
    return self;
}

@end

@implementation HSAutoScrollActionAssistantPaneApplier

/* i386 ivar offsets: _initialNumberOfSteps=0x30, _initialStepsPerSecond=0x34, _initialScrollAmount=0x38, _initialScrollUnits=0x3c, _initialScrollDirection=0x40, _initialIsInEditMode=0x44, _initialIgnoreMouseClicks=0x45, _initialTextViewNames=0x48, _initialTextViewUIDs=0x4c, _numberOfSteps=0x50, _stepsPerSecond=0x54, _scrollAmount=0x58, _scrollUnits=0x5c, _scrollDirection=0x60, _isInEditMode=0x64, _ignoreMouseClicks=0x65, _textViewNames=0x68, _textViewUIDs=0x6c */

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    BOOL bVar2;

    pvVar1 = [super areSettingsEqual];
    if (((((!pvVar1) || (_initialNumberOfSteps != _numberOfSteps)) || (_initialStepsPerSecond != _stepsPerSecond)) || ((_initialScrollAmount != _scrollAmount || (_initialScrollUnits != _scrollUnits)))) || ((_initialScrollDirection != _scrollDirection || (_initialIgnoreMouseClicks != _ignoreMouseClicks)))) {
        bVar2 = NO;
    }
    else {
        bVar2 = YES;
    }
    if ((_initialTextViewNames != nil) || (_textViewNames != nil)) {
        if ((bVar2 == NO) || (pvVar1 = [_initialTextViewNames isEqualToArray:_textViewNames] , !pvVar1)) {
            bVar2 = NO;
        }
        else {
            bVar2 = YES;
        }
    }
    if ((_initialTextViewUIDs != nil) || (_textViewUIDs != nil)) {
        if (bVar2 == NO) {
            bVar2 = NO;
        }
        else {
            pvVar1 = [_initialTextViewUIDs isEqualToArray:_textViewUIDs];
            bVar2 = pvVar1;
        }
    }
    return bVar2;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_textViewNames release];
    _textViewNames = [_initialTextViewNames retain];
    [_textViewUIDs release];
    _textViewUIDs = [_initialTextViewUIDs retain];
    _numberOfSteps = _initialNumberOfSteps;
    _stepsPerSecond = _initialStepsPerSecond;
    _scrollAmount = _initialScrollAmount;
    _scrollUnits = _initialScrollUnits;
    _scrollDirection = _initialScrollDirection;
    _ignoreMouseClicks = _initialIgnoreMouseClicks;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialTextViewNames release];
    _initialTextViewNames = [_textViewNames retain];
    [_initialTextViewUIDs release];
    _initialTextViewUIDs = [_textViewUIDs retain];
    _initialNumberOfSteps = _numberOfSteps;
    _initialStepsPerSecond = _stepsPerSecond;
    _initialScrollAmount = _scrollAmount;
    _initialScrollUnits = _scrollUnits;
    _initialScrollDirection = _scrollDirection;
    _initialIgnoreMouseClicks = _ignoreMouseClicks;
}

- (void)setInitialSettingsToObject
{
    [[self autoScrollActionAttributes] setNumberOfSteps:_initialNumberOfSteps];
    [[self autoScrollActionAttributes] setStepsPerSecond:_initialStepsPerSecond];
    [[self autoScrollActionAttributes] setScrollAmount:_initialScrollAmount];
    [[self autoScrollActionAttributes] setScrollUnits:_initialScrollUnits];
    [[self autoScrollActionAttributes] setScrollDirection:_initialScrollDirection];
    [[self autoScrollActionAttributes] setTextViewNames:_initialTextViewNames];
    [[self autoScrollActionAttributes] setTextViewUIDs:_initialTextViewUIDs];
    [[self autoScrollActionAttributes] setIgnoreMouseClicks:_initialIgnoreMouseClicks];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self autoScrollActionAttributes] setNumberOfSteps:_numberOfSteps];
    [[self autoScrollActionAttributes] setStepsPerSecond:_stepsPerSecond];
    [[self autoScrollActionAttributes] setScrollAmount:_scrollAmount];
    [[self autoScrollActionAttributes] setScrollUnits:_scrollUnits];
    [[self autoScrollActionAttributes] setScrollDirection:_scrollDirection];
    [[self autoScrollActionAttributes] setTextViewNames:_textViewNames];
    [[self autoScrollActionAttributes] setTextViewUIDs:_textViewUIDs];
    [[self autoScrollActionAttributes] setIgnoreMouseClicks:_ignoreMouseClicks];
}

- (void)setIgnoreMouseClicks:(BOOL)aClicks
{
    if (_ignoreMouseClicks != aClicks) {
        _ignoreMouseClicks = aClicks;
        [self disableUndo];
        [[self autoScrollActionAttributes] setIgnoreMouseClicks:_ignoreMouseClicks];
        [self enableUndo];
    }
}

- (void)setTextViewUIDs:(id)aDs
{
    if (_textViewUIDs != aDs) {
        [_textViewUIDs release];
        _textViewUIDs = [aDs retain];
        [self disableUndo];
        [[self autoScrollActionAttributes] setTextViewUIDs:_textViewUIDs];
        [self enableUndo];
    }
}

- (void)setTextViewNames:(id)aNames
{
    if (_textViewNames != aNames) {
        [_textViewNames release];
        _textViewNames = [aNames retain];
        [self disableUndo];
        [[self autoScrollActionAttributes] setTextViewNames:_textViewNames];
        [self enableUndo];
    }
}

- (void)setScrollDirection:(NSInteger)aDirection
{
    if (_scrollDirection != aDirection) {
        _scrollDirection = aDirection;
        [self disableUndo];
        [[self autoScrollActionAttributes] setScrollDirection:_scrollDirection];
        [self enableUndo];
    }
}

- (void)setScrollUnits:(NSInteger)aUnits
{
    if (_scrollUnits != aUnits) {
        _scrollUnits = aUnits;
        [self disableUndo];
        [[self autoScrollActionAttributes] setScrollUnits:_scrollUnits];
        [self enableUndo];
    }
}

- (void)setScrollAmount:(NSInteger)aAmount
{
    if (_scrollAmount != aAmount) {
        _scrollAmount = aAmount;
        [self disableUndo];
        [[self autoScrollActionAttributes] setScrollAmount:_scrollAmount];
        [self enableUndo];
    }
}

- (void)setStepsPerSecond:(NSInteger)aSecond
{
    if (_stepsPerSecond != aSecond) {
        _stepsPerSecond = aSecond;
        [self disableUndo];
        [[self autoScrollActionAttributes] setStepsPerSecond:_stepsPerSecond];
        [self enableUndo];
    }
}

- (void)setNumberOfSteps:(NSInteger)aSteps
{
    if (_numberOfSteps != aSteps) {
        _numberOfSteps = aSteps;
        [self disableUndo];
        [[self autoScrollActionAttributes] setNumberOfSteps:_numberOfSteps];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    NSInteger pvVar1_2;
    NSInteger pvVar1_4;
    NSInteger pvVar1_6;
    NSInteger pvVar1_8;
    NSCollectionViewScrollDirection pvVar1_10;
    BOOL pvVar1_12;

    pvVar1_2 = [[self autoScrollActionAttributes] numberOfSteps];
    _initialNumberOfSteps = (int)pvVar1_2;
    _numberOfSteps = (int)pvVar1_2;
    pvVar1_4 = [[self autoScrollActionAttributes] stepsPerSecond];
    _initialStepsPerSecond = (int)pvVar1_4;
    _stepsPerSecond = (int)pvVar1_4;
    pvVar1_6 = [[self autoScrollActionAttributes] scrollAmount];
    _initialScrollAmount = (int)pvVar1_6;
    _scrollAmount = (int)pvVar1_6;
    pvVar1_8 = [[self autoScrollActionAttributes] scrollUnits];
    _initialScrollUnits = (int)pvVar1_8;
    _scrollUnits = (int)pvVar1_8;
    pvVar1_10 = [[self autoScrollActionAttributes] scrollDirection];
    _initialScrollDirection = (int)pvVar1_10;
    _scrollDirection = (int)pvVar1_10;
    pvVar1_12 = [[self autoScrollActionAttributes] ignoreMouseClicks];
    _initialIgnoreMouseClicks = (BOOL)pvVar1_12;
    _ignoreMouseClicks = (BOOL)pvVar1_12;
    _textViewNames = [[[self autoScrollActionAttributes] textViewNames] retain];
    _initialTextViewNames = [[[self autoScrollActionAttributes] textViewNames] retain];
    _textViewUIDs = [[[self autoScrollActionAttributes] textViewUIDs] retain];
    _initialTextViewUIDs = [[[self autoScrollActionAttributes] textViewUIDs] retain];
}

- (id)autoScrollActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSAutoScrollActionAttributes)];
}

- (void)dealloc
{
    [_initialTextViewNames release];
    [_textViewNames release];
    [_textViewUIDs release];
    [_initialTextViewUIDs release];
    [super dealloc];
}

@end

