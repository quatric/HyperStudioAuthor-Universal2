#import "HSFrameSelectionKnobSettings.h"
static id sDAT_00342790;

static id sDAT_00342790;


@implementation HSFrameSelectionKnobSettings

/* i386 ivar offsets: _framePositionFactor=0x4, _modifyingEdges=0xc, _defaultCursorIdentifier=0x10 */

+ (id)settingsWithModifyingEdges:(NSInteger)aEdges defaultCursorIdentifier:(id)aIdentifier
{
    return [[[self alloc] initWithModifyingEdges:aEdges defaultCursorIdentifier:aIdentifier] autorelease];
}

+ (void)registerSettings:(id)aSettings forKnobIdentifier:(id)aIdentifier
{
    [[self settingsByID] setObject:aSettings forKey:aIdentifier];
}

+ (id)settingsForKnobIdentifier:(id)aIdentifier
{
    return [[self settingsByID] objectForKey:aIdentifier];
}

+ (id)settingsByID
{
    if (sDAT_00342790 == nil) {
        sDAT_00342790 = [NSMutableDictionary new];
    }
    return sDAT_00342790;
}

- (id)defaultCursor
{
    id pvVar1;

    if (_defaultCursorIdentifier == nil) {
        pvVar1 = nil;
    }
    else {
        pvVar1 = [HSCursor cursorNamed:_defaultCursorIdentifier];
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00043001 @ 00043001, 14 bytes * /

ulonglong FUN_00043001(HSFrameSelectionKnobSettings *self,SEL _cmd)

{
  ulonglong uVar1;
  
  uVar1._0_4_ = (self->_framePositionFactor).width;
  uVar1._4_4_ = (self->_framePositionFactor).height;
  return uVar1;
}

*/
- (NSSize)framePositionFactor
{
    return _framePositionFactor;
}

- (NSInteger)modifyingEdges
{
    return _modifyingEdges;
}

- (void)dealloc
{
    [_defaultCursorIdentifier release];
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00043912 @ 00043912, 173 bytes * /

id FUN_00043912(HSFrameSelectionKnobSettings *self,SEL _cmd,int initWithModifyingEdges,
               id defaultCursorIdentifier)

{
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  HSFrameSelectionKnobSettings *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSObject_0034dde0;
  pvVar1 = _objc_msgSendSuper(&local_14,sel_init);
  if (pvVar1 != (id)0x0) {
    if ((initWithModifyingEdges & 1U) == 0) {
      if ((initWithModifyingEdges & 4U) == 0) {
        uVar3 = 0x3f000000;
      }
      else {
        uVar3 = 0x3f800000;
      }
    }
    else {
      uVar3 = 0;
    }
    if ((initWithModifyingEdges & 2U) == 0) {
      if ((initWithModifyingEdges & 8U) == 0) {
        uVar4 = 0x3f000000;
      }
      else {
        uVar4 = 0x3f800000;
      }
    }
    else {
      uVar4 = 0;
    }
    *(undefined4 *)((int)pvVar1 + 4) = uVar3;
    *(undefined4 *)((int)pvVar1 + 8) = uVar4;
    *(int *)((int)pvVar1 + 0xc) = initWithModifyingEdges;
    pvVar2 = _objc_msgSend(defaultCursorIdentifier,sel_retain);
    *(id *)((int)pvVar1 + 0x10) = pvVar2;
  }
  return pvVar1;
}

*/
- (id)initWithModifyingEdges:(NSInteger)aEdges defaultCursorIdentifier:(id)aIdentifier
{
    self = [super init];
    if (self != nil) {
        CGFloat x = (aEdges & 1) ? 0.0 : ((aEdges & 4) ? 1.0 : 0.5);
        CGFloat y = (aEdges & 2) ? 0.0 : ((aEdges & 8) ? 1.0 : 0.5);
        _framePositionFactor = NSMakeSize(x, y);
        _modifyingEdges = aEdges;
        _defaultCursorIdentifier = [aIdentifier retain];
    }
    return self;
}

@end

@implementation HSFrameSelectionKnob

/* i386 ivar offsets: _knobSettings=0x38, _invertsProportionalResizePreference=0x3c */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00043068 @ 00043068, 211 bytes * /

id FUN_00043068(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = (id)_NSStringFromSelector(_cmd);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_settingsForKnobIdentifier_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,
                           sel_settingsWithModifyingEdges_defaultCursorIdentifier_,3,
                           *(undefined4 *)PTR_PTR_00336304);
    pvVar3 = pvVar2;
    _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_registerSettings_forKnobIdentifier_,pvVar2,
                  pvVar1);
  }
  pvVar3 = _objc_msgSend(self,sel_alloc,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithKnobSettings_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  return pvVar3;
}

*/
+ (id)topLeftSelectionKnob
{
    NSString *identifier = NSStringFromSelector(_cmd);
    HSFrameSelectionKnobSettings *settings = [HSFrameSelectionKnobSettings settingsForKnobIdentifier:identifier];
    if (settings == nil) {
        settings = [HSFrameSelectionKnobSettings settingsWithModifyingEdges:3 defaultCursorIdentifier:HSTLBRCursor];
        [HSFrameSelectionKnobSettings registerSettings:settings forKnobIdentifier:identifier];
    }
    return [[[self alloc] initWithKnobSettings:settings] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004313b @ 0004313b, 211 bytes * /

id FUN_0004313b(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = (id)_NSStringFromSelector(_cmd);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_settingsForKnobIdentifier_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,
                           sel_settingsWithModifyingEdges_defaultCursorIdentifier_,2,
                           *(undefined4 *)PTR_PTR_003362ec);
    pvVar3 = pvVar2;
    _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_registerSettings_forKnobIdentifier_,pvVar2,
                  pvVar1);
  }
  pvVar3 = _objc_msgSend(self,sel_alloc,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithKnobSettings_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  return pvVar3;
}

*/
+ (id)topCenterSelectionKnob
{
    NSString *identifier = NSStringFromSelector(_cmd);
    HSFrameSelectionKnobSettings *settings = [HSFrameSelectionKnobSettings settingsForKnobIdentifier:identifier];
    if (settings == nil) {
        settings = [HSFrameSelectionKnobSettings settingsWithModifyingEdges:2 defaultCursorIdentifier:HSScaleVertCursor];
        [HSFrameSelectionKnobSettings registerSettings:settings forKnobIdentifier:identifier];
    }
    return [[[self alloc] initWithKnobSettings:settings] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004320e @ 0004320e, 211 bytes * /

id FUN_0004320e(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = (id)_NSStringFromSelector(_cmd);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_settingsForKnobIdentifier_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,
                           sel_settingsWithModifyingEdges_defaultCursorIdentifier_,1,
                           *(undefined4 *)PTR_PTR_003362e8);
    pvVar3 = pvVar2;
    _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_registerSettings_forKnobIdentifier_,pvVar2,
                  pvVar1);
  }
  pvVar3 = _objc_msgSend(self,sel_alloc,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithKnobSettings_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  return pvVar3;
}

*/
+ (id)centerLeftSelectionKnob
{
    NSString *identifier = NSStringFromSelector(_cmd);
    HSFrameSelectionKnobSettings *settings = [HSFrameSelectionKnobSettings settingsForKnobIdentifier:identifier];
    if (settings == nil) {
        settings = [HSFrameSelectionKnobSettings settingsWithModifyingEdges:1 defaultCursorIdentifier:HSScaleHorCursor];
        [HSFrameSelectionKnobSettings registerSettings:settings forKnobIdentifier:identifier];
    }
    return [[[self alloc] initWithKnobSettings:settings] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000432e1 @ 000432e1, 211 bytes * /

id FUN_000432e1(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = (id)_NSStringFromSelector(_cmd);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_settingsForKnobIdentifier_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,
                           sel_settingsWithModifyingEdges_defaultCursorIdentifier_,9,
                           *(undefined4 *)PTR_PTR_00336308);
    pvVar3 = pvVar2;
    _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_registerSettings_forKnobIdentifier_,pvVar2,
                  pvVar1);
  }
  pvVar3 = _objc_msgSend(self,sel_alloc,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithKnobSettings_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  return pvVar3;
}

*/
+ (id)bottomLeftSelectionKnob
{
    NSString *identifier = NSStringFromSelector(_cmd);
    HSFrameSelectionKnobSettings *settings = [HSFrameSelectionKnobSettings settingsForKnobIdentifier:identifier];
    if (settings == nil) {
        settings = [HSFrameSelectionKnobSettings settingsWithModifyingEdges:9 defaultCursorIdentifier:HSTRBLCursor];
        [HSFrameSelectionKnobSettings registerSettings:settings forKnobIdentifier:identifier];
    }
    return [[[self alloc] initWithKnobSettings:settings] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000433b4 @ 000433b4, 211 bytes * /

id FUN_000433b4(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = (id)_NSStringFromSelector(_cmd);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_settingsForKnobIdentifier_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,
                           sel_settingsWithModifyingEdges_defaultCursorIdentifier_,6,
                           *(undefined4 *)PTR_PTR_00336308);
    pvVar3 = pvVar2;
    _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_registerSettings_forKnobIdentifier_,pvVar2,
                  pvVar1);
  }
  pvVar3 = _objc_msgSend(self,sel_alloc,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithKnobSettings_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  return pvVar3;
}

*/
+ (id)topRightSelectionKnob
{
    NSString *identifier = NSStringFromSelector(_cmd);
    HSFrameSelectionKnobSettings *settings = [HSFrameSelectionKnobSettings settingsForKnobIdentifier:identifier];
    if (settings == nil) {
        settings = [HSFrameSelectionKnobSettings settingsWithModifyingEdges:6 defaultCursorIdentifier:HSTRBLCursor];
        [HSFrameSelectionKnobSettings registerSettings:settings forKnobIdentifier:identifier];
    }
    return [[[self alloc] initWithKnobSettings:settings] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00043487 @ 00043487, 211 bytes * /

id FUN_00043487(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = (id)_NSStringFromSelector(_cmd);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_settingsForKnobIdentifier_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,
                           sel_settingsWithModifyingEdges_defaultCursorIdentifier_,8,
                           *(undefined4 *)PTR_PTR_003362ec);
    pvVar3 = pvVar2;
    _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_registerSettings_forKnobIdentifier_,pvVar2,
                  pvVar1);
  }
  pvVar3 = _objc_msgSend(self,sel_alloc,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithKnobSettings_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  return pvVar3;
}

*/
+ (id)bottomCenterSelectionKnob
{
    NSString *identifier = NSStringFromSelector(_cmd);
    HSFrameSelectionKnobSettings *settings = [HSFrameSelectionKnobSettings settingsForKnobIdentifier:identifier];
    if (settings == nil) {
        settings = [HSFrameSelectionKnobSettings settingsWithModifyingEdges:8 defaultCursorIdentifier:HSScaleVertCursor];
        [HSFrameSelectionKnobSettings registerSettings:settings forKnobIdentifier:identifier];
    }
    return [[[self alloc] initWithKnobSettings:settings] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004355a @ 0004355a, 211 bytes * /

id FUN_0004355a(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = (id)_NSStringFromSelector(_cmd);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_settingsForKnobIdentifier_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,
                           sel_settingsWithModifyingEdges_defaultCursorIdentifier_,4,
                           *(undefined4 *)PTR_PTR_003362e8);
    pvVar3 = pvVar2;
    _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_registerSettings_forKnobIdentifier_,pvVar2,
                  pvVar1);
  }
  pvVar3 = _objc_msgSend(self,sel_alloc,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithKnobSettings_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  return pvVar3;
}

*/
+ (id)centerRightSelectionKnob
{
    NSString *identifier = NSStringFromSelector(_cmd);
    HSFrameSelectionKnobSettings *settings = [HSFrameSelectionKnobSettings settingsForKnobIdentifier:identifier];
    if (settings == nil) {
        settings = [HSFrameSelectionKnobSettings settingsWithModifyingEdges:4 defaultCursorIdentifier:HSScaleHorCursor];
        [HSFrameSelectionKnobSettings registerSettings:settings forKnobIdentifier:identifier];
    }
    return [[[self alloc] initWithKnobSettings:settings] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0004362d @ 0004362d, 211 bytes * /

id FUN_0004362d(id self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = (id)_NSStringFromSelector(_cmd);
  pvVar3 = pvVar1;
  pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_settingsForKnobIdentifier_,pvVar1);
  if (pvVar2 == (id)0x0) {
    pvVar2 = _objc_msgSend(cls_HSFrameSelectionKnobSettings,
                           sel_settingsWithModifyingEdges_defaultCursorIdentifier_,0xc,
                           *(undefined4 *)PTR_PTR_00336304);
    pvVar3 = pvVar2;
    _objc_msgSend(cls_HSFrameSelectionKnobSettings,sel_registerSettings_forKnobIdentifier_,pvVar2,
                  pvVar1);
  }
  pvVar3 = _objc_msgSend(self,sel_alloc,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithKnobSettings_,pvVar2);
  pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
  return pvVar3;
}

*/
+ (id)bottomRightSelectionKnob
{
    NSString *identifier = NSStringFromSelector(_cmd);
    HSFrameSelectionKnobSettings *settings = [HSFrameSelectionKnobSettings settingsForKnobIdentifier:identifier];
    if (settings == nil) {
        settings = [HSFrameSelectionKnobSettings settingsWithModifyingEdges:12 defaultCursorIdentifier:HSTLBRCursor];
        [HSFrameSelectionKnobSettings registerSettings:settings forKnobIdentifier:identifier];
    }
    return [[[self alloc] initWithKnobSettings:settings] autorelease];
}

- (id)cursorAtPoint:(NSPoint)aPoint modifierFlags:(NSUInteger)aFlags inView:(id)aView owner:(id)aOwner
{
    id pvVar1;

    pvVar1 = [super cursorAtPoint:aPoint modifierFlags:aFlags inView:aView owner:aOwner];
    if (pvVar1 == nil) {
        pvVar1 = [[self knobSettings] defaultCursor];
    }
    return pvVar1;
}

- (id)createSelectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    return [[self selectionTrackerForModifierFlags:aFlags] retain];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000437cd @ 000437cd, 148 bytes * /

id FUN_000437cd(HSFrameSelectionKnob *self,SEL _cmd,uint selectionTrackerForModifierFlags)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_trackerClass);
  pvVar2 = _objc_msgSend(self,sel_invertsProportionalResizePreference);
  pvVar3 = _objc_msgSend(self,sel_knobSettings);
  pvVar3 = _objc_msgSend(pvVar3,sel_modifyingEdges);
  op = sel_trackerWithModifyingEdges_;
  if ((char)pvVar2 != '\0') {
    op = sel_alternateProportionsTrackerWithModifyingEdges_;
  }
  pvVar1 = _objc_msgSend(pvVar1,op,pvVar3);
  return pvVar1;
}

*/
- (id)selectionTrackerForModifierFlags:(NSUInteger)aFlags
{
    Class trackerClass = [self trackerClass];
    if ([self invertsProportionalResizePreference]) {
        return [trackerClass alternateProportionsTrackerWithModifyingEdges:[[self knobSettings] modifyingEdges]];
    }
    return [trackerClass trackerWithModifyingEdges:[[self knobSettings] modifyingEdges]];
}

- (NSSize)framePositionFactor
{
    return [[self knobSettings] framePositionFactor];
}

- (Class)trackerClass
{
    return [HSFrameResizeSelectionTracker class];
}

- (void)setInvertsProportionalResizePreference:(BOOL)aPreference
{
    _invertsProportionalResizePreference = aPreference;
}

- (BOOL)invertsProportionalResizePreference
{
    return _invertsProportionalResizePreference;
}

- (id)knobSettings
{
    return _knobSettings;
}

- (void)dealloc
{
    [_knobSettings release];
    [super dealloc];
}

- (id)initWithKnobSettings:(id)aSettings
{
    self = [super init];
    if (self != nil) {
        _knobSettings = [aSettings retain];
    }
    return self;
}

@end

