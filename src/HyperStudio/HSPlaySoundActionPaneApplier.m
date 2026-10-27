#import "HSPlaySoundActionPaneApplier.h"

@implementation HSPlaySoundActionPaneApplier

/* i386 ivar offsets: _initialSoundItems=0x30, _soundItems=0x34, _initialSoundItemsToStop=0x38, _soundItemsToStop=0x3c, _initialStopsAllSounds=0x40, _stopsAllSounds=0x40, _initialFadeOutTimeForStopAllSounds=0x44, _fadeOutTimeForStopAllSounds=0x4c, _ignoresAssistantActions=0x54 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001be1d0 @ 001be1d0, 209 bytes * /

BOOL FUN_001be1d0(HSPlaySoundActionPaneApplier *self,SEL _cmd)

{
  double *pdVar1;
  double dVar2;
  id pvVar3;
  bool bVar4;
  HSPlaySoundActionPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_003537b0;
  pvVar3 = _objc_msgSendSuper(&local_14,sel_areSettingsEqual);
  if (((((char)pvVar3 == '\0') ||
       ((*(uint *)self->_initialStopsAllSounds & 2) >> 1 !=
        (*(uint *)self->_initialStopsAllSounds & 1))) ||
      (dVar2 = *(double *)((int)&self->_initialFadeOutTimeForStopAllSounds + 7),
      pdVar1 = (double *)((int)&self->_stopsAllSounds + 3), dVar2 != *pdVar1)) ||
     (NAN(dVar2) || NAN(*pdVar1))) {
    bVar4 = false;
  }
  else {
    bVar4 = true;
  }
  if ((self->_soundItems != (id)0x0) || (self->_initialSoundItems != (id)0x0)) {
    if ((bVar4 == false) ||
       (pvVar3 = _objc_msgSend(self->_soundItems,sel_isEqualToArray_,self->_initialSoundItems),
       (char)pvVar3 == '\0')) {
      bVar4 = false;
    }
    else {
      bVar4 = true;
    }
  }
  if ((self->_soundItemsToStop != (id)0x0) || (self->_initialSoundItemsToStop != (id)0x0)) {
    if (bVar4 == false) {
      bVar4 = false;
    }
    else {
      pvVar3 = _objc_msgSend(self->_soundItemsToStop,sel_isEqualToDictionary_,
                             self->_initialSoundItemsToStop);
      bVar4 = (char)pvVar3 != '\0';
    }
  }
  return bVar4;
}

*/
- (BOOL)areSettingsEqual
{
    BOOL equal = [super areSettingsEqual] && _initialStopsAllSounds == _stopsAllSounds && _fadeOutTimeForStopAllSounds == _initialFadeOutTimeForStopAllSounds;
    if (_soundItems != nil || _initialSoundItems != nil) {
        equal = equal && [_soundItems isEqualToArray:_initialSoundItems];
    }
    if (_soundItemsToStop != nil || _initialSoundItemsToStop != nil) {
        equal = equal && [_soundItemsToStop isEqualToDictionary:_initialSoundItemsToStop];
    }
    return equal;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bd8b6 @ 001bd8b6, 22 bytes * /

BOOL FUN_001bd8b6(HSPlaySoundActionPaneApplier *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if (((ulonglong)self->_fadeOutTimeForStopAllSounds & 0x100000000000000) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)ignoresAssistantActions
{
    return _ignoresAssistantActions;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bd89e @ 001bd89e, 24 bytes * /

void FUN_001bd89e(HSPlaySoundActionPaneApplier *self,SEL _cmd,BOOL setIgnoresAssistantActions)

{
  *(byte *)((int)&self->_fadeOutTimeForStopAllSounds + 7) =
       *(byte *)((int)&self->_fadeOutTimeForStopAllSounds + 7) & 0xfe |
       setIgnoresAssistantActions & 1U;
  return;
}

*/
- (void)setIgnoresAssistantActions:(BOOL)aActions
{
    _ignoresAssistantActions = aActions;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001be0ae @ 001be0ae, 149 bytes * /

void FUN_001be0ae(HSPlaySoundActionPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  
  if (((ulonglong)self->_fadeOutTimeForStopAllSounds & 0x100000000000000) == 0) {
    _objc_msgSend(self->_soundItems,sel_release);
    pvVar1 = _objc_msgSend(self->_initialSoundItems,sel_mutableCopy);
    self->_soundItems = pvVar1;
    _objc_msgSend(self->_soundItemsToStop,sel_release);
    pvVar1 = _objc_msgSend(self->_initialSoundItemsToStop,sel_mutableCopy);
    self->_soundItemsToStop = pvVar1;
    *(uint *)self->_initialStopsAllSounds =
         (*(uint *)self->_initialStopsAllSounds * 2 & 2) +
         (*(uint *)self->_initialStopsAllSounds & 0xfffffffd);
    *(undefined8 *)((int)&self->_initialFadeOutTimeForStopAllSounds + 7) =
         *(undefined8 *)((int)&self->_stopsAllSounds + 3);
  }
  return;
}

*/
- (void)makeCurrentEqualToInitial
{
    if (!_ignoresAssistantActions) {
        [_soundItems release];
        _soundItems = [_initialSoundItems mutableCopy];
        [_soundItemsToStop release];
        _soundItemsToStop = [_initialSoundItemsToStop mutableCopy];
        _stopsAllSounds = _initialStopsAllSounds;
        _fadeOutTimeForStopAllSounds = _initialFadeOutTimeForStopAllSounds;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001be2a1 @ 001be2a1, 185 bytes * /

void FUN_001be2a1(HSPlaySoundActionPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  HSPlaySoundActionPaneApplier *local_14;
  undefined *local_10;
  
  if (((ulonglong)self->_fadeOutTimeForStopAllSounds & 0x100000000000000) == 0) {
    local_14 = self;
    local_10 = PTR_s_HSActionAssistantSettingsApplier_003537b0;
    _objc_msgSendSuper(&local_14,sel_makeInitialEqualToCurrent);
    _objc_msgSend(self->_initialSoundItems,sel_release);
    pvVar1 = _objc_msgSend(self->_soundItems,sel_mutableCopy);
    self->_initialSoundItems = pvVar1;
    _objc_msgSend(self->_initialSoundItemsToStop,sel_release);
    pvVar1 = _objc_msgSend(self->_soundItemsToStop,sel_mutableCopy);
    self->_initialSoundItemsToStop = pvVar1;
    *(uint *)self->_initialStopsAllSounds =
         (*(uint *)self->_initialStopsAllSounds >> 1 & 1) +
         (*(uint *)self->_initialStopsAllSounds & 0xfffffffe);
    *(undefined8 *)((int)&self->_stopsAllSounds + 3) =
         *(undefined8 *)((int)&self->_initialFadeOutTimeForStopAllSounds + 7);
  }
  return;
}

*/
- (void)makeInitialEqualToCurrent
{
    if (!_ignoresAssistantActions) {
        [super makeInitialEqualToCurrent];
        [_initialSoundItems release];
        _initialSoundItems = [_soundItems mutableCopy];
        [_initialSoundItemsToStop release];
        _initialSoundItemsToStop = [_soundItemsToStop mutableCopy];
        _initialStopsAllSounds = _stopsAllSounds;
        _initialFadeOutTimeForStopAllSounds = _fadeOutTimeForStopAllSounds;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001be35a @ 001be35a, 205 bytes * /

void FUN_001be35a(HSPlaySoundActionPaneApplier *self,SEL _cmd)

{
  id self_00;
  undefined4 uVar1;
  HSPlaySoundActionPaneApplier *local_1c;
  undefined *local_18;
  
  if (((ulonglong)self->_fadeOutTimeForStopAllSounds & 0x100000000000000) == 0) {
    self_00 = _objc_msgSend(self,sel_playSoundActionAttributes);
    _objc_msgSend(self_00,sel_setSounds_,self->_initialSoundItems);
    uVar1 = 0xffffffff;
    if ((*(uint *)self->_initialStopsAllSounds & 1) == 0) {
      uVar1 = 0;
    }
    _objc_msgSend(self_00,sel_setStopsAllSounds_,uVar1);
    _objc_msgSend(self_00,sel_setSoundsToStop_,self->_initialSoundItemsToStop);
    _objc_msgSend(self_00,sel_setFadeOutTimeForStopAllSounds_,
                  *(undefined8 *)((int)&self->_stopsAllSounds + 3));
    local_1c = self;
    local_18 = PTR_s_HSActionAssistantSettingsApplier_003537b0;
    _objc_msgSendSuper(&local_1c,sel_setInitialSettingsToObject);
  }
  return;
}

*/
- (void)setInitialSettingsToObject
{
    if (!_ignoresAssistantActions) {
        id attributes = [self playSoundActionAttributes];
        [attributes setSounds:_initialSoundItems];
        [attributes setStopsAllSounds:_initialStopsAllSounds];
        [attributes setSoundsToStop:_initialSoundItemsToStop];
        [attributes setFadeOutTimeForStopAllSounds:_initialFadeOutTimeForStopAllSounds];
        [super setInitialSettingsToObject];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001be427 @ 001be427, 205 bytes * /

void FUN_001be427(HSPlaySoundActionPaneApplier *self,SEL _cmd)

{
  id self_00;
  undefined4 uVar1;
  HSPlaySoundActionPaneApplier *local_1c;
  undefined *local_18;
  
  if (((ulonglong)self->_fadeOutTimeForStopAllSounds & 0x100000000000000) == 0) {
    local_1c = self;
    local_18 = PTR_s_HSActionAssistantSettingsApplier_003537b0;
    _objc_msgSendSuper(&local_1c,sel_setCurrentSettingsToObject);
    self_00 = _objc_msgSend(self,sel_playSoundActionAttributes);
    _objc_msgSend(self_00,sel_setSounds_,self->_soundItems);
    uVar1 = 0xffffffff;
    if ((*(uint *)self->_initialStopsAllSounds & 2) == 0) {
      uVar1 = 0;
    }
    _objc_msgSend(self_00,sel_setStopsAllSounds_,uVar1);
    _objc_msgSend(self_00,sel_setSoundsToStop_,self->_soundItemsToStop);
    _objc_msgSend(self_00,sel_setFadeOutTimeForStopAllSounds_,
                  *(undefined8 *)((int)&self->_initialFadeOutTimeForStopAllSounds + 7));
  }
  return;
}

*/
- (void)setCurrentSettingsToObject
{
    if (!_ignoresAssistantActions) {
        [super setCurrentSettingsToObject];
        id attributes = [self playSoundActionAttributes];
        [attributes setSounds:_soundItems];
        [attributes setStopsAllSounds:_stopsAllSounds];
        [attributes setSoundsToStop:_soundItemsToStop];
        [attributes setFadeOutTimeForStopAllSounds:_fadeOutTimeForStopAllSounds];
    }
}

- (void)applyChanges
{
    if (((unsigned long long)_fadeOutTimeForStopAllSounds & 0x100000000000000) == 0) {
        [super applyChanges];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001be025 @ 001be025, 137 bytes * /

void FUN_001be025(HSPlaySoundActionPaneApplier *self,SEL _cmd,
                 double setFadeOutStopTimeForStopAllSounds)

{
  id self_00;
  
  if (*(double *)((int)&self->_initialFadeOutTimeForStopAllSounds + 7) !=
      setFadeOutStopTimeForStopAllSounds) {
    _objc_msgSend(self,sel_disableUndo);
    *(double *)((int)&self->_initialFadeOutTimeForStopAllSounds + 7) =
         setFadeOutStopTimeForStopAllSounds;
    self_00 = _objc_msgSend(self,sel_playSoundActionAttributes);
    _objc_msgSend(self_00,sel_setFadeOutTimeForStopAllSounds_,setFadeOutStopTimeForStopAllSounds);
    _objc_msgSend(self,sel_enableUndo);
  }
  return;
}

*/
- (void)setFadeOutStopTimeForStopAllSounds:(double)aSounds
{
    if (_fadeOutTimeForStopAllSounds != aSounds) {
        [self disableUndo];
        _fadeOutTimeForStopAllSounds = aSounds;
        [[self playSoundActionAttributes] setFadeOutTimeForStopAllSounds:aSounds];
        [self enableUndo];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bdef7 @ 001bdef7, 302 bytes * /

void FUN_001bdef7(HSPlaySoundActionPaneApplier *self,SEL _cmd,double setFadeOutStopTime,
                 id forSoundUID)

{
  id pvVar1;
  id pvVar2;
  id self_00;
  SEL op;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  
  _objc_msgSend(self,sel_disableUndo);
  pvVar1 = _objc_msgSend(cls_NSNumber,sel_alloc);
  pvVar3 = SUB84(setFadeOutStopTime,0);
  pvVar4 = (id)((ulonglong)setFadeOutStopTime >> 0x20);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithDouble_,pvVar3,pvVar4);
  if (pvVar1 != (id)0x0) {
    pvVar2 = _objc_msgSend(self->_soundItemsToStop,sel_objectForKey_,forSoundUID,
                           (int)((ulonglong)setFadeOutStopTime >> 0x20));
    _objc_msgSend(self->_soundItemsToStop,sel_setObject_forKey_,pvVar1,forSoundUID);
    _objc_msgSend(pvVar1,sel_release);
    self_00 = _objc_msgSend(self,sel_playSoundActionAttributes);
    op = sel_setSoundFadeOutTime_forStopSoundUID_;
    pvVar1 = pvVar3;
    pvVar5 = pvVar4;
    if (pvVar2 == (id)0x0) {
      op = sel_addSoundUIDToStop_withFadeOutTime_;
      pvVar1 = forSoundUID;
      pvVar5 = pvVar3;
      forSoundUID = pvVar4;
    }
    _objc_msgSend(self_00,op,pvVar1,pvVar5,forSoundUID);
    setFadeOutStopTime = (double)CONCAT44(pvVar5,pvVar1);
  }
  _objc_msgSend(self,sel_enableUndo,SUB84(setFadeOutStopTime,0),
                (int)((ulonglong)setFadeOutStopTime >> 0x20));
  return;
}

*/
- (void)setFadeOutStopTime:(double)aTime forSoundUID:(id)aUID
{
    [self disableUndo];
    NSNumber *time = [[NSNumber alloc] initWithDouble:aTime];
    if (time != nil) {
        id previous = [_soundItemsToStop objectForKey:aUID];
        [_soundItemsToStop setObject:time forKey:aUID];
        [time release];
        id attributes = [self playSoundActionAttributes];
        if (previous != nil) {
            [attributes setSoundFadeOutTime:aTime forStopSoundUID:aUID];
        } else {
            [attributes addSoundUIDToStop:aUID withFadeOutTime:aTime];
        }
    }
    [self enableUndo];
}

- (void)removeSoundUIDToStop:(id)aStop
{
    [self disableUndo];
    if ([_soundItemsToStop objectForKey:aStop] != nil) {
        [_soundItemsToStop removeObjectForKey:aStop];
        [[self playSoundActionAttributes] removeSoundUIDToStop:aStop];
    }
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bdd4c @ 001bdd4c, 268 bytes * /

void FUN_001bdd4c(HSPlaySoundActionPaneApplier *self,SEL _cmd,id addSoundUIDToStop,
                 double withFadeOutTime)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  
  _objc_msgSend(self,sel_disableUndo);
  pvVar2 = addSoundUIDToStop;
  pvVar1 = _objc_msgSend(self->_soundItemsToStop,sel_objectForKey_,addSoundUIDToStop);
  if (pvVar1 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_NSNumber,sel_alloc,pvVar2);
    uVar3 = SUB84(withFadeOutTime,0);
    uVar4 = (undefined4)((ulonglong)withFadeOutTime >> 0x20);
    pvVar1 = _objc_msgSend(pvVar2,sel_initWithDouble_,uVar3,uVar4);
    pvVar2 = SUB84(withFadeOutTime,0);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self->_soundItemsToStop,sel_setObject_forKey_,pvVar1,addSoundUIDToStop);
      _objc_msgSend(pvVar1,sel_release);
      pvVar2 = _objc_msgSend(self,sel_playSoundActionAttributes);
      _objc_msgSend(pvVar2,sel_addSoundUIDToStop_withFadeOutTime_,addSoundUIDToStop,uVar3,uVar4);
      pvVar2 = addSoundUIDToStop;
    }
  }
  _objc_msgSend(self,sel_enableUndo,pvVar2);
  return;
}

*/
- (void)addSoundUIDToStop:(id)aStop withFadeOutTime:(double)aTime
{
    [self disableUndo];
    if ([_soundItemsToStop objectForKey:aStop] == nil) {
        NSNumber *time = [[NSNumber alloc] initWithDouble:aTime];
        if (time != nil) {
            [_soundItemsToStop setObject:time forKey:aStop];
            [time release];
            [[self playSoundActionAttributes] addSoundUIDToStop:aStop withFadeOutTime:aTime];
        }
    }
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bdca4 @ 001bdca4, 168 bytes * /

void FUN_001bdca4(HSPlaySoundActionPaneApplier *self,SEL _cmd,BOOL setStopsAllSounds)

{
  id self_00;
  char cVar1;
  undefined4 uVar2;
  
  cVar1 = -1;
  if ((*(uint *)self->_initialStopsAllSounds & 2) == 0) {
    cVar1 = '\0';
  }
  if ((setStopsAllSounds != '\0') != (bool)cVar1) {
    *(uint *)self->_initialStopsAllSounds =
         (uint)(setStopsAllSounds != '\0') * 2 +
         (*(uint *)self->_initialStopsAllSounds & 0xfffffffd);
    _objc_msgSend(self,sel_disableUndo);
    self_00 = _objc_msgSend(self,sel_playSoundActionAttributes);
    uVar2 = 0xffffffff;
    if ((*(uint *)self->_initialStopsAllSounds & 2) == 0) {
      uVar2 = 0;
    }
    _objc_msgSend(self_00,sel_setStopsAllSounds_,uVar2);
    _objc_msgSend(self,sel_enableUndo);
  }
  return;
}

*/
- (void)setStopsAllSounds:(BOOL)aSounds
{
    if ((BOOL)_stopsAllSounds != aSounds) {
        _stopsAllSounds = aSounds;
        [self disableUndo];
        [[self playSoundActionAttributes] setStopsAllSounds:_stopsAllSounds];
        [self enableUndo];
    }
}

- (void)setSoundPlayback:(id)aPlayback stopThisSound:(BOOL)aSound
{
    [self disableUndo];
    [aPlayback setStopThisSound:aSound];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bdbe4 @ 001bdbe4, 103 bytes * /

void FUN_001bdbe4(HSPlaySoundActionPaneApplier *self,SEL _cmd,id setSoundPlayback,
                 HSTimeRange playRange)

{
  _objc_msgSend(self,sel_disableUndo);
  _objc_msgSend(setSoundPlayback,sel_setSoundPlayRange_,playRange.location,playRange.length);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)setSoundPlayback:(id)aPlayback playRange:(struct HSTimeRange)aRange
{
    [self disableUndo];
    [aPlayback setSoundPlayRange:aRange];
    [self enableUndo];
}

- (void)setSoundPlayback:(id)aPlayback fadeOutTime:(double)aTime
{
    [self disableUndo];
    [aPlayback setSoundFadeOutTime:aTime];
    [self enableUndo];
}

- (void)setSoundPlayback:(id)aPlayback playCount:(NSUInteger)aCount
{
    [self disableUndo];
    [aPlayback setPlayCount:aCount];
    [self enableUndo];
}

- (void)setSoundPlayback:(id)aPlayback synchronousSound:(BOOL)aSound
{
    [self disableUndo];
    [aPlayback setSynchronousSound:aSound];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001bda7b @ 001bda7b, 92 bytes * /

void FUN_001bda7b(HSPlaySoundActionPaneApplier *self,SEL _cmd,id setSoundPlayback,float volume)

{
  _objc_msgSend(self,sel_disableUndo);
  _objc_msgSend(setSoundPlayback,sel_setVolume_,volume);
  _objc_msgSend(self,sel_enableUndo);
  return;
}

*/
- (void)setSoundPlayback:(id)aPlayback volume:(CGFloat)aVolume
{
    [self disableUndo];
    [aPlayback setVolume:aVolume];
    [self enableUndo];
}

- (void)removeSound:(id)aSound
{
    id pvVar2_2;

    if ([_soundItems containsObject:aSound]) {
        pvVar2_2 = [_soundItems mutableCopy];
        [pvVar2_2 removeObject:aSound];
        [self setSounds:pvVar2_2];
        [pvVar2_2 release];
    }
}

- (void)addSound:(id)aSound
{
    if (![_soundItems containsObject:aSound]) {
        [self setSounds:[_soundItems arrayByAddingObject:aSound]];
    }
}

- (void)setSounds:(id)aSounds
{
    id pvVar1;

    pvVar1 = nil;
    if (_soundItems != nil) {
        if ([aSounds isEqualToArray:_soundItems]) {
            return;
        }
        pvVar1 = _soundItems;
    }
    [pvVar1 release];
    _soundItems = [aSounds mutableCopy];
    [self disableUndo];
    [[self playSoundActionAttributes] setSounds:aSounds];
    [self enableUndo];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001be52f @ 001be52f, 262 bytes * /

void FUN_001be52f(HSPlaySoundActionPaneApplier *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  double dVar3;
  
  self_00 = _objc_msgSend(self,sel_playSoundActionAttributes);
  pvVar1 = _objc_msgSend(self_00,sel_sounds);
  pvVar2 = _objc_msgSend(pvVar1,sel_mutableCopy);
  self->_initialSoundItems = pvVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
  self->_soundItems = pvVar1;
  pvVar1 = _objc_msgSend(self_00,sel_soundsToStop);
  pvVar2 = _objc_msgSend(pvVar1,sel_mutableCopy);
  self->_initialSoundItemsToStop = pvVar2;
  pvVar1 = _objc_msgSend(pvVar1,sel_mutableCopy);
  self->_soundItemsToStop = pvVar1;
  pvVar1 = _objc_msgSend(self_00,sel_stopsAllSounds);
  *(uint *)self->_initialStopsAllSounds =
       (uint)((byte)pvVar1 & 1) * 3 + (*(uint *)self->_initialStopsAllSounds & 0xfffffffc);
  dVar3 = _objc_msgSend_fpret(self_00,sel_fadeOutTimeForStopAllSounds);
  *(double *)((int)&self->_stopsAllSounds + 3) = dVar3;
  *(double *)((int)&self->_initialFadeOutTimeForStopAllSounds + 7) = dVar3;
  return;
}

*/
- (void)setUpInitialSettings
{
    id attributes = [self playSoundActionAttributes];
    id sounds = [attributes sounds];
    _initialSoundItems = [sounds mutableCopy];
    _soundItems = [sounds mutableCopy];
    id soundsToStop = [attributes soundsToStop];
    _initialSoundItemsToStop = [soundsToStop mutableCopy];
    _soundItemsToStop = [soundsToStop mutableCopy];
    _initialStopsAllSounds = [attributes stopsAllSounds];
    _stopsAllSounds = _initialStopsAllSounds;
    _initialFadeOutTimeForStopAllSounds = [attributes fadeOutTimeForStopAllSounds];
    _fadeOutTimeForStopAllSounds = _initialFadeOutTimeForStopAllSounds;
}

- (id)playSoundActionAttributes
{
    return [[super actionAttributes] queryHyperInterface:@protocol(HSPlaySoundActionAttributes)];
}

- (void)dealloc
{
    [_initialSoundItems release];
    [_soundItems release];
    [_initialSoundItemsToStop release];
    [_soundItemsToStop release];
    [super dealloc];
}

@end

