#import "HSAutoRecordActionAssistantPane.h"

@implementation HSAutoRecordActionAssistantPane

/* i386 ivar offsets: _recordTimeField=0x88, _sensitivityLevelMatrix=0x8c, _recordNameField=0x90, _recordTimeStepper=0x94 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e67b7 @ 000e67b7, 213 bytes * /

void FUN_000e67b7(HSAutoRecordActionAssistantPane *self,SEL _cmd,id controlTextDidChange)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(controlTextDidChange,sel_object);
  if (pvVar1 == self->_recordNameField) {
    pvVar1 = _objc_msgSend(controlTextDidChange,sel_object);
    pvVar1 = _objc_msgSend(pvVar1,sel_stringValue);
    pvVar1 = _objc_msgSend(pvVar1,sel_length);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_autoRecordActionAssistantPaneApplier);
      pvVar2 = _objc_msgSend(controlTextDidChange,sel_object);
      pvVar2 = _objc_msgSend(pvVar2,sel_stringValue);
      pvVar2 = _objc_msgSend(pvVar2,sel_hyperStringByReplacingSlashesWithColons);
      _objc_msgSend(pvVar1,sel_setRecordName_,pvVar2);
    }
  }
  return;
}

*/
- (void)controlTextDidChange:(id)aChange
{
    if ([aChange object] == _recordNameField) {
        if ([[[aChange object] stringValue] length] != 0) {
            [[self autoRecordActionAssistantPaneApplier] setRecordName:[[[aChange object] stringValue] hyperStringByReplacingSlashesWithColons]];
        }
    }
}

- (void)validateUI
{
    id pvVar2;

    pvVar2 = [self actionAttributes];
    if (pvVar2 != nil) {
        [_recordTimeField setDoubleValue:[pvVar2 recordTime]];
        [_recordTimeStepper setDoubleValue:[pvVar2 recordTime]];
        [_sensitivityLevelMatrix selectCellWithTag:[pvVar2 sensitivityLevel]];
        [_recordNameField setStringValue:[[pvVar2 recordName] hyperStringByReplacingColonsWithSlashes]];
    }
}

- (void)validateUIWithNotification:(id)aNotification
{
    [self validateUI];
}

- (void)sensivityLevelChanged:(id)aChanged
{
    [[self autoRecordActionAssistantPaneApplier] setSensitivityLevel:[[aChanged selectedCell] tag]];
}

- (void)recordTimeChanged:(id)aChanged
{
    [[self autoRecordActionAssistantPaneApplier] setRecordTime:[aChanged floatValue]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e6695 @ 000e6695, 147 bytes * /

void FUN_000e6695(HSAutoRecordActionAssistantPane *self,SEL _cmd,id recordNameChanged)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(recordNameChanged,sel_stringValue);
  pvVar1 = _objc_msgSend(pvVar1,sel_length);
  if (pvVar1 != (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_autoRecordActionAssistantPaneApplier);
    pvVar2 = _objc_msgSend(recordNameChanged,sel_stringValue);
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperStringByReplacingSlashesWithColons);
    _objc_msgSend(pvVar1,sel_setRecordName_,pvVar2);
  }
  return;
}

*/
- (void)recordNameChanged:(id)aChanged
{
    if ([[aChanged stringValue] length] != 0) {
        [[self autoRecordActionAssistantPaneApplier] setRecordName:[[aChanged stringValue] hyperStringByReplacingSlashesWithColons]];
    }
}

- (id)helpTopicKey
{
    return @"HSAutoRecord";
}

- (id)initialKeyView
{
    return _recordTimeField;
}

- (void)viewWillDisappear:(BOOL)aDisappear
{
    [self removeActionAssistantPaneObserver];
    [super viewWillDisappear:aDisappear];
}

- (void)viewWillAppear:(BOOL)aAppear
{
    [super viewWillAppear:aAppear];
    [self addActionAssistantPaneObserver];
    [self validateUI];
}

- (id)actionAttribute
{
    return (id)@protocol(HSAutoRecordActionAttributes);
}

- (id)actionType
{
    return [HSAutoRecordAction actionType];
}

- (id)actionAttributes
{
    return [[self autoRecordActionAssistantPaneApplier] autoRecordActionAttributes];
}

- (id)autoRecordActionAssistantPaneApplier
{
    return [self applier];
}

- (Class)applierClass
{
    return [HSAutoRecordActionAssistantPaneApplier class];
}

- (id)init
{
    self = [super initWithNibName:@"AutoRecordAssistantPane"];
    return self;
}

@end

@implementation HSAutoRecordActionAssistantPaneApplier

/* i386 ivar offsets: _initialRecordTime=0x30, _initialSensitivityLevel=0x38, _initialRecordName=0x3c, _recordTime=0x40, _sensitivityLevel=0x48, _recordName=0x4c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000e68ef @ 000e68ef, 242 bytes * /

BOOL FUN_000e68ef(HSAutoRecordActionAssistantPaneApplier *self,SEL _cmd)

{
  double dVar1;
  double dVar2;
  id pvVar3;
  bool bVar4;
  double dVar5;
  double dVar6;
  HSAutoRecordActionAssistantPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_00350690;
  pvVar3 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if ((char)pvVar3 != '\0') {
    dVar1 = self->_initialRecordTime;
    dVar2 = self->_recordTime;
    if ((dVar1 != 0.0) || (NAN(dVar1))) {
      dVar5 = ABS(dVar1);
    }
    else {
      dVar5 = 1.0;
    }
    if ((dVar2 != 0.0) || (NAN(dVar2))) {
      dVar6 = ABS(dVar2);
    }
    else {
      dVar6 = 1.0;
    }
    if (dVar6 <= dVar5) {
      dVar6 = dVar5;
    }
    if ((ABS(dVar1 - dVar2) <= dVar6 * 1e-05) &&
       (self->_initialSensitivityLevel == self->_sensitivityLevel)) {
      bVar4 = true;
      goto LAB_000e699f;
    }
  }
  bVar4 = false;
LAB_000e699f:
  if ((self->_recordName != (id)0x0) || (self->_initialRecordName != (id)0x0)) {
    if (bVar4 == false) {
      bVar4 = false;
    }
    else {
      pvVar3 = _objc_msgSend(self->_initialRecordName,sel_isEqual_,self->_recordName);
      bVar4 = (char)pvVar3 != '\0';
    }
  }
  return bVar4;
}

*/
- (BOOL)areSettingsEqual
{
    double a = _initialRecordTime;
    double b = _recordTime;
    double scaleA = (a != 0.0 || a != a) ? fabs(a) : 1.0;
    double scaleB = (b != 0.0 || b != b) ? fabs(b) : 1.0;
    if (scaleB <= scaleA) {
        scaleB = scaleA;
    }
BOOL equal = NO;
    if ([super areSettingsEqual] && fabs(a - b) <= scaleB * 1e-05 && _initialSensitivityLevel == _sensitivityLevel) {
        equal = YES;
    }
    if (_recordName != nil || _initialRecordName != nil) {
        equal = equal ? [_initialRecordName isEqual:_recordName] : NO;
    }
    return equal;
    return 0;
}

- (void)makeCurrentEqualToInitial
{
    [super makeCurrentEqualToInitial];
    [_recordName release];
    _recordName = [_initialRecordName retain];
    _recordTime = _initialRecordTime;
    _sensitivityLevel = _initialSensitivityLevel;
}

- (void)makeInitialEqualToCurrent
{
    [super makeInitialEqualToCurrent];
    [_initialRecordName release];
    _initialRecordName = [_recordName retain];
    _initialRecordTime = _recordTime;
    _initialSensitivityLevel = _sensitivityLevel;
}

- (void)setInitialSettingsToObject
{
    [[self autoRecordActionAttributes] setRecordName:_initialRecordName];
    [[self autoRecordActionAttributes] setRecordTime:_initialRecordTime];
    [[self autoRecordActionAttributes] setSensitivityLevel:_initialSensitivityLevel];
    [super setInitialSettingsToObject];
}

- (void)setCurrentSettingsToObject
{
    [super setCurrentSettingsToObject];
    [[self autoRecordActionAttributes] setRecordName:_recordName];
    [[self autoRecordActionAttributes] setRecordTime:_recordTime];
    [[self autoRecordActionAttributes] setSensitivityLevel:_sensitivityLevel];
}

- (void)setSensitivityLevel:(NSInteger)aLevel
{
    if (_sensitivityLevel != aLevel) {
        _sensitivityLevel = aLevel;
        [self disableUndo];
        [[self autoRecordActionAttributes] setSensitivityLevel:_sensitivityLevel];
        [self enableUndo];
    }
}

- (void)setRecordTime:(double)aTime
{
    if (_recordTime != aTime) {
        _recordTime = aTime;
        [self disableUndo];
        [[self autoRecordActionAttributes] setRecordTime:_recordTime];
        [self enableUndo];
    }
}

- (void)setRecordName:(id)aName
{
    if (![_recordName isEqualToString:aName]) {
        [_recordName release];
        _recordName = [aName retain];
        [self disableUndo];
        [[self autoRecordActionAttributes] setRecordName:_recordName];
        [self enableUndo];
    }
}

- (void)setUpInitialSettings
{
    _recordName = [[[self autoRecordActionAttributes] recordName] retain];
    _initialRecordName = [[[self autoRecordActionAttributes] recordName] retain];
    _recordTime = [[self autoRecordActionAttributes] recordTime];
    _initialRecordTime = [[self autoRecordActionAttributes] recordTime];
    _sensitivityLevel = (int)[[self autoRecordActionAttributes] sensitivityLevel];
    _initialSensitivityLevel = (int)[[self autoRecordActionAttributes] sensitivityLevel];
}

- (id)autoRecordActionAttributes
{
    return [[self actionAttributes] queryHyperInterface:@protocol(HSAutoRecordActionAttributes)];
}

- (void)dealloc
{
    [_initialRecordName release];
    [_recordName release];
    [super dealloc];
}

@end

