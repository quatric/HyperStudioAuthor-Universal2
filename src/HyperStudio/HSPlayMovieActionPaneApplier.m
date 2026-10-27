#import "HSPlayMovieActionPaneApplier.h"

@implementation HSPlayMovieActionPaneApplier

/* i386 ivar offsets: _initialMovies=0x30, _initialLiveVideos=0x34, _movies=0x38, _liveVideos=0x3c, _initialMoviesSettings=0x40, _moviesSettings=0x44, _initialLiveVideosSettings=0x48, _liveVideosSettings=0x4c, _playMovieActionAttributes=0x50, _initialSettingApplied=0x54, _ignoresAssistantActions=0x54, _settingsForPlaybackItemsBuilded=0x55 */

- (void)liveVideosChanged:(id)aChanged
{
    id self_00;
    id self_01;
    id pvVar2;
    id pvVar3;
    id pvVar1_2;
    id pvVar1_4;
    id pvVar1_6;
    id pvVar1_8;
    id pvVar1_10;
    id pvVar1_11;
    id pvVar5_6;
    id pvVar3_2;

    self_00 = [NSAutoreleasePool new];
    self_01 = [[self playMovieActionAttributes] liveVideos];
    pvVar2 = [self playMovieActionAttributes];
    [self_01 count];
    [self liveVideosCountInCurrentAppliedSettings];
    pvVar1_2 = _initialLiveVideos;
    pvVar3 = [self differencesOfPlaybackItems:pvVar1_2 fromPlaybaclItems:self_01];
    if ([pvVar3 count] != 0) {
        [_initialLiveVideos autorelease];
        pvVar1_4 = [[self removePlaybackItem:pvVar3 fromArray:_initialLiveVideos] retain];
        _initialLiveVideos = pvVar1_4;
        [pvVar1_4 makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:pvVar2];
        [_liveVideos autorelease];
        pvVar1_6 = [[self removePlaybackItem:pvVar3 fromArray:_liveVideos] retain];
        _liveVideos = pvVar1_6;
        [pvVar1_6 makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:pvVar2];
        [self removeSettingsForPlaybackItems:pvVar3 fromSettingsStorage:_initialLiveVideosSettings];
        [self removeSettingsForPlaybackItems:pvVar3 fromSettingsStorage:_liveVideosSettings];
    }
    [self_01 count];
    [self liveVideosCountInCurrentAppliedSettings];
    pvVar1_8 = _initialLiveVideos;
    pvVar3_2 = [self differencesOfPlaybackItems:self_01 fromPlaybaclItems:pvVar1_8];
    if ([pvVar3_2 count] != 0) {
        [_initialLiveVideos autorelease];
        pvVar1_10 = [[self addPlaybackItems:pvVar3_2 toPlaybackItems:_initialLiveVideos excludeTemporaryItems:YES] retain];
        _initialLiveVideos = pvVar1_10;
        [pvVar1_10 makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:pvVar2];
    }
    pvVar1_11 = [self differencesOfPlaybackItems:self_01 fromPlaybaclItems:(id)_liveVideos];
    if ([pvVar1_11 count] != 0) {
        [_liveVideos autorelease];
        pvVar5_6 = [[self addPlaybackItems:pvVar1_11 toPlaybackItems:_liveVideos excludeTemporaryItems:NO] retain];
        _liveVideos = pvVar5_6;
        [pvVar5_6 makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:pvVar2];
        [self addSettingsForPlaybackItems:pvVar1_11 withSettingsSelector:@selector(createSettingForLiveVideoPlaybackItem:) toSettingsStorage:_initialLiveVideosSettings];
        [self addSettingsForPlaybackItems:pvVar1_11 withSettingsSelector:@selector(createSettingForLiveVideoPlaybackItem:) toSettingsStorage:_liveVideosSettings];
    }
    [self_00 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c4197 @ 001c4197, 1095 bytes * /

void FUN_001c4197(HSPlayMovieActionPaneApplier *self,SEL _cmd,id moviesChanged)

{
  id self_00;
  id pvVar1;
  HSPlayMovieActionPaneApplier *self_01;
  undefined *puVar2;
  id pvVar3;
  undefined *self_02;
  id pvVar4;
  undefined *self_03;
  SEL op;
  HSPlayMovieActionPaneApplier *pHVar5;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  pvVar1 = _objc_msgSend(self,sel_playMovieActionAttributes);
  self_01 = _objc_msgSend(pvVar1,sel_movies);
  puVar2 = _objc_msgSend(self,sel_playMovieActionAttributes);
  pvVar1 = _objc_msgSend(self_01,sel_count);
  pvVar3 = _objc_msgSend(self,sel_moviesCountInCurrentAppliedSettings);
  if (pvVar1 < pvVar3) {
    pvVar1 = self->_initialMovies;
    pHVar5 = self_01;
    self_02 = _objc_msgSend(self,sel_differencesOfPlaybackItems_fromPlaybaclItems_,pvVar1,self_01);
    pvVar3 = _objc_msgSend(self_02,sel_count);
    op = sel_makeObjectsPerformSelector_withObject_;
    self_03 = sel_setPlaybackItemSupport_;
    if (pvVar3 != (id)0x0) {
      _objc_msgSend(self->_initialMovies,sel_autorelease,pvVar1,pHVar5);
      pvVar1 = _objc_msgSend(self,sel_removePlaybackItem_fromArray_,self_02,self->_initialMovies);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      self->_initialMovies = pvVar1;
      _objc_msgSend(pvVar1,sel_makeObjectsPerformSelector_withObject_,sel_setPlaybackItemSupport_,
                    puVar2);
      _objc_msgSend(self->_movies,sel_autorelease);
      pvVar1 = _objc_msgSend(self,sel_removePlaybackItem_fromArray_,self_02,self->_movies);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      self->_movies = pvVar1;
      _objc_msgSend(pvVar1,sel_makeObjectsPerformSelector_withObject_,sel_setPlaybackItemSupport_,
                    puVar2);
      _objc_msgSend(self,sel_removeSettingsForPlaybackItems_fromSettingsStorage_,self_02,
                    self->_initialMoviesSettings);
      self_01 = self;
      op = sel_removeSettingsForPlaybackItems_fromSettingsStorage_;
      self_03 = self_02;
      puVar2 = self->_moviesSettings;
    }
  }
  else {
    pvVar1 = _objc_msgSend(self_01,sel_count);
    pvVar3 = _objc_msgSend(self,sel_moviesCountInCurrentAppliedSettings);
    if (pvVar1 <= pvVar3) goto LAB_001c45c1;
    pvVar1 = self->_initialMovies;
    pHVar5 = self_01;
    pvVar3 = _objc_msgSend(self,sel_differencesOfPlaybackItems_fromPlaybaclItems_,self_01,pvVar1);
    pvVar4 = _objc_msgSend(pvVar3,sel_count);
    if (pvVar4 != (id)0x0) {
      _objc_msgSend(self->_initialMovies,sel_autorelease,pHVar5,pvVar1);
      pvVar1 = _objc_msgSend(self,sel_addPlaybackItems_toPlaybackItems_excludeTemporaryItems_,pvVar3
                             ,self->_initialMovies,1);
      pvVar1 = _objc_msgSend(pvVar1,sel_retain);
      self->_initialMovies = pvVar1;
      _objc_msgSend(pvVar1,sel_makeObjectsPerformSelector_withObject_,sel_setPlaybackItemSupport_,
                    puVar2);
    }
    pvVar1 = self->_movies;
    self_03 = _objc_msgSend(self,sel_differencesOfPlaybackItems_fromPlaybaclItems_,self_01,pvVar1);
    pvVar3 = _objc_msgSend(self_03,sel_count);
    if (pvVar3 == (id)0x0) goto LAB_001c45c1;
    _objc_msgSend(self->_movies,sel_autorelease,self_01,pvVar1);
    pvVar1 = _objc_msgSend(self,sel_addPlaybackItems_toPlaybackItems_excludeTemporaryItems_,self_03,
                           self->_movies,0);
    pvVar1 = _objc_msgSend(pvVar1,sel_retain);
    self->_movies = pvVar1;
    _objc_msgSend(pvVar1,sel_makeObjectsPerformSelector_withObject_,sel_setPlaybackItemSupport_,
                  puVar2);
    _objc_msgSend(self,sel_addSettingsForPlaybackItems_withSettingsSelector_toSettingsStorage_,
                  self_03,sel_createSettingForMoviePlaybackItem_,self->_initialMoviesSettings);
    self_01 = self;
    op = sel_addSettingsForPlaybackItems_withSettingsSelector_toSettingsStorage_;
    puVar2 = sel_createSettingForMoviePlaybackItem_;
  }
  _objc_msgSend(self_01,op,self_03,puVar2);
LAB_001c45c1:
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)moviesChanged:(id)aChanged
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    id attributes = [self playMovieActionAttributes];
    NSArray *currentMovies = [attributes movies];

    if ([currentMovies count] < [self moviesCountInCurrentAppliedSettings]) {
        NSArray *removed = [self differencesOfPlaybackItems:_initialMovies fromPlaybaclItems:currentMovies];
        if ([removed count] != 0) {
            [_initialMovies autorelease];
            _initialMovies = [[self removePlaybackItem:removed fromArray:_initialMovies] retain];
            [_initialMovies makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:attributes];
            [_movies autorelease];
            _movies = [[self removePlaybackItem:removed fromArray:_movies] retain];
            [_movies makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:attributes];
            [self removeSettingsForPlaybackItems:removed fromSettingsStorage:_initialMoviesSettings];
            [self removeSettingsForPlaybackItems:removed fromSettingsStorage:_moviesSettings];
        }
        else {
            [currentMovies makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:attributes];
        }
    }
    else if ([currentMovies count] > [self moviesCountInCurrentAppliedSettings]) {
        NSArray *added = [self differencesOfPlaybackItems:currentMovies fromPlaybaclItems:_initialMovies];
        if ([added count] != 0) {
            [_initialMovies autorelease];
            _initialMovies = [[self addPlaybackItems:added toPlaybackItems:_initialMovies excludeTemporaryItems:YES] retain];
            [_initialMovies makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:attributes];
        }
        added = [self differencesOfPlaybackItems:currentMovies fromPlaybaclItems:_movies];
        if ([added count] != 0) {
            [_movies autorelease];
            _movies = [[self addPlaybackItems:added toPlaybackItems:_movies excludeTemporaryItems:NO] retain];
            [_movies makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:attributes];
            [self addSettingsForPlaybackItems:added withSettingsSelector:@selector(createSettingForMoviePlaybackItem:) toSettingsStorage:_initialMoviesSettings];
            [self addSettingsForPlaybackItems:added withSettingsSelector:@selector(createSettingForMoviePlaybackItem:) toSettingsStorage:_moviesSettings];
        }
    }
    [pool release];
}

- (id)addPlaybackItems:(id)aItems toPlaybackItems:(id)aItems2 excludeTemporaryItems:(BOOL)aItems3
{
    id self_00;
    NSEnumerator *self_01;
    id pvVar1;
    BOOL pvVar2;

    self_00 = [aItems2 mutableCopy];
    self_01 = [aItems objectEnumerator];
    pvVar1 = [self_01 nextObject];
    while (pvVar1 != nil) {
        if ((aItems3 == NO) || (pvVar2 = [pvVar1 isTemporary], !pvVar2)) {
            [self_00 addObject:pvVar1];
        }
        pvVar1 = [self_01 nextObject];
    }
    return [self_00 autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c3fb9 @ 001c3fb9, 282 bytes * /

id FUN_001c3fb9(HSPlayMovieActionPaneApplier *self,SEL _cmd,id removePlaybackItem,id fromArray)

{
  id pvVar1;
  id self_00;
  id self_01;
  id pvVar2;
  id self_02;
  id self_03;
  
  pvVar1 = _objc_msgSend(fromArray,sel_mutableCopy);
  self_00 = _objc_msgSend(fromArray,sel_objectEnumerator);
LAB_001c40a6:
  do {
    self_03 = _objc_msgSend(self_00,sel_nextObject);
    if (self_03 == (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
      return pvVar1;
    }
    self_01 = _objc_msgSend(removePlaybackItem,sel_objectEnumerator);
    do {
      pvVar2 = _objc_msgSend(self_01,sel_nextObject);
      if (pvVar2 == (id)0x0) goto LAB_001c40a6;
      self_02 = _objc_msgSend(self_03,sel_objectUID);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectUID);
      pvVar2 = _objc_msgSend(self_02,sel_isEqual_,pvVar2);
    } while ((char)pvVar2 == '\0');
    _objc_msgSend(pvVar1,sel_removeObject_,self_03);
  } while( true );
}

*/
- (id)removePlaybackItem:(id)aItem fromArray:(id)aArray
{
    NSMutableArray *result = [aArray mutableCopy];
    NSEnumerator *enumerator = [aArray objectEnumerator];
    id item;

    while ((item = [enumerator nextObject]) != nil) {
        NSEnumerator *removedEnumerator = [aItem objectEnumerator];
        id removed;
        while ((removed = [removedEnumerator nextObject]) != nil) {
            if ([[item objectUID] isEqual:[removed objectUID]]) {
                [result removeObject:item];
                break;
            }
        }
    }
    return [result autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c3e8d @ 001c3e8d, 300 bytes * /

id FUN_001c3e8d(HSPlayMovieActionPaneApplier *self,SEL _cmd,id differencesOfPlaybackItems,
               id fromPlaybaclItems)

{
  id self_00;
  id self_01;
  id pvVar1;
  id self_02;
  id self_03;
  id pvVar2;
  int iVar3;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  self_01 = _objc_msgSend(differencesOfPlaybackItems,sel_objectEnumerator);
LAB_001c3f80:
  do {
    self_03 = _objc_msgSend(self_01,sel_nextObject);
    if (self_03 == (id)0x0) {
      return self_00;
    }
    pvVar2 = _objc_msgSend(fromPlaybaclItems,sel_count);
    for (iVar3 = 0; iVar3 < (int)pvVar2; iVar3 = iVar3 + 1) {
      pvVar1 = _objc_msgSend(fromPlaybaclItems,sel_objectAtIndex_,iVar3);
      self_02 = _objc_msgSend(self_03,sel_objectUID);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectUID);
      pvVar1 = _objc_msgSend(self_02,sel_isEqual_,pvVar1);
      if ((char)pvVar1 != '\0') goto LAB_001c3f80;
    }
    _objc_msgSend(self_00,sel_addObject_,self_03);
  } while( true );
}

*/
- (id)differencesOfPlaybackItems:(id)aItems fromPlaybaclItems:(id)aItems2
{
    NSMutableArray *differences = [NSMutableArray array];
    NSEnumerator *enumerator = [aItems objectEnumerator];
    id item;

    while ((item = [enumerator nextObject]) != nil) {
        int count = (int)[aItems2 count];
        int index;
        BOOL found = NO;
        for (index = 0; index < count; index++) {
            if ([[item objectUID] isEqual:[[aItems2 objectAtIndex:index] objectUID]]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [differences addObject:item];
        }
    }
    return differences;
}

- (void)stopObservingChangesFromPlayMovieAction
{
    int uVar1;
    id pvVar2_2;

    pvVar2_2 = [[self playMovieActionAttributes] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_2 removeObserver:self selector:@selector(moviesChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSPlayMovieMoviesAttribute)];
    [pvVar2_2 removeObserver:self selector:@selector(liveVideosChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSPlayMovieLiveVideosAttribute)];
}

- (void)startObservingChangesFromPlayMovieAction
{
    int uVar1;
    id pvVar2_2;

    pvVar2_2 = [[self playMovieActionAttributes] attributeObservingController];
    uVar1 = HSActualDidAttributeChanges;
    [pvVar2_2 addObserver:self selector:@selector(moviesChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSPlayMovieMoviesAttribute) withPriority:-0.25];
    [pvVar2_2 addObserver:self selector:@selector(liveVideosChanged:) ofChanges:uVar1 ofAttribute:@protocol(HSPlayMovieLiveVideosAttribute) withPriority:-0.25];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c4aed @ 001c4aed, 987 bytes * /

void FUN_001c4aed(HSPlayMovieActionPaneApplier *self,SEL _cmd,
                 id HSPlayMovieActionPaneApplier_updatePlayMovieObjectForItem)

{
  int iVar1;
  int iVar2;
  bool bVar3;
  id pvVar4;
  id pvVar5;
  id self_00;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id local_fc;
  undefined8 local_e4;
  undefined8 local_dc;
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  
  _objc_msgSend(HSPlayMovieActionPaneApplier_updatePlayMovieObjectForItem,sel_movieObjectUID);
  pvVar4 = _objc_msgSend(self,sel_actionAttributes);
  pvVar5 = _objc_msgSend(pvVar4,sel_owner);
  pvVar5 = _objc_msgSend(pvVar5,sel_hyperObjectForAction_);
  pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_);
  pvVar5 = _objc_msgSend(pvVar5,sel_stack);
  self_00 = _objc_msgSend(pvVar5,sel_allActionsOfType_);
  local_d4 = 0;
  local_d0 = 0;
  local_cc = (int *)0x0;
  local_c8 = 0;
  local_c4 = 0;
  local_c0 = 0;
  local_bc = 0;
  local_b8 = 0;
  pvVar6 = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_);
  if (pvVar6 != (id)0x0) {
    iVar1 = *local_cc;
    bVar3 = true;
    do {
      local_fc = (id)0x0;
      do {
        if (iVar1 != *local_cc) {
          _objc_enumerationMutation(self_00);
        }
        pvVar7 = *(id *)(local_d0 + (int)local_fc * 4);
        local_fc = (id)((int)local_fc + 1);
        if (pvVar4 != pvVar7) {
          pvVar7 = _objc_msgSend(pvVar7,sel_movies);
          local_74 = 0;
          local_70 = 0;
          local_6c = (int *)0x0;
          local_68 = 0;
          local_64 = 0;
          local_60 = 0;
          local_5c = 0;
          local_58 = 0;
          pvVar8 = _objc_msgSend(pvVar7,sel_countByEnumeratingWithState_objects_count_);
          if (pvVar8 != (id)0x0) {
            iVar2 = *local_6c;
            do {
              pvVar10 = (id)0x0;
              do {
                if (iVar2 != *local_6c) {
                  _objc_enumerationMutation(pvVar7);
                }
                pvVar9 = _objc_msgSend(*(id *)(local_70 + (int)pvVar10 * 4),sel_movieObjectUID);
                pvVar9 = _objc_msgSend(pvVar9,sel_isEqual_);
                if ((char)pvVar9 != '\0') {
                  bVar3 = false;
                }
                pvVar10 = (id)((int)pvVar10 + 1);
              } while (pvVar10 < pvVar8);
              pvVar8 = _objc_msgSend(pvVar7,sel_countByEnumeratingWithState_objects_count_);
            } while (pvVar8 != (id)0x0);
          }
        }
      } while (local_fc < pvVar6);
      pvVar6 = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_);
    } while (pvVar6 != (id)0x0);
    if (!bVar3) {
      return;
    }
  }
  pvVar4 = _objc_msgSend(pvVar5,sel_childInTreeWithUID_);
  pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_);
  _objc_msgSend_stret(&local_e4,HSPlayMovieActionPaneApplier_updatePlayMovieObjectForItem,
                      sel_playRange);
  _objc_msgSend(pvVar4,sel_setHyperPlayRange_,local_e4,local_dc);
  return;
}

*/
- (void)HSPlayMovieActionPaneApplier_updatePlayMovieObjectForItem:(id)aItem
{
    id movieUID = [aItem movieObjectUID];
    id actionAttributes = [self actionAttributes];
    id stack = [[[[actionAttributes owner] hyperObjectForAction:actionAttributes] queryHyperInterface:@protocol(HSUserObjectSupport)] stack];
    BOOL isUnshared = YES;

    for (id action in [stack allActionsOfType:@protocol(HSPlayMovieActionAttributes)]) {
        if (action == actionAttributes) {
            continue;
        }
        for (id movie in [action movies]) {
            if ([[movie movieObjectUID] isEqual:movieUID]) {
                isUnshared = NO;
            }
        }
    }
    // A movie object that another play movie action also uses keeps its own play range.
    if (!isUnshared) {
        return;
    }
    id playable = [[stack childInTreeWithUID:movieUID] queryHyperInterface:@protocol(HSPlayableObjectAttributes)];
    [playable setHyperPlayRange:[aItem playRange]];
}

- (id)createSettingForLiveVideoPlaybackItem:(id)aItem
{
    id self_00;
    id pvVar1;

    self_00 = [NSMutableDictionary dictionary];
    if (aItem != nil) {
        pvVar1 = [aItem liveVideoName];
        if (pvVar1 != nil) {
            [self_00 setObject:pvVar1 forKey:@"HSPlayMovieApplierLiveVideoName"];
        }
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c4ec8 @ 001c4ec8, 330 bytes * /

id FUN_001c4ec8(HSPlayMovieActionPaneApplier *self,SEL _cmd,id createSettingForMoviePlaybackItem)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  double dVar3;
  undefined1 local_24 [20];
  
  self_00 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
  puVar1 = cls_NSNumber;
  if (createSettingForMoviePlaybackItem != (id)0x0) {
    pvVar2 = _objc_msgSend(createSettingForMoviePlaybackItem,sel_useMovieController);
    pvVar2 = _objc_msgSend(puVar1,sel_numberWithBool_,(uint)pvVar2 & 0xff);
    _objc_msgSend(self_00,sel_setObject_forKey_,pvVar2,&cfstr_HSPlayMovieApplierUseMovieController);
    puVar1 = cls_NSNumber;
    dVar3 = _objc_msgSend_fpret(createSettingForMoviePlaybackItem,sel_volume);
    pvVar2 = _objc_msgSend(puVar1,sel_numberWithFloat_,(float)dVar3);
    _objc_msgSend(self_00,sel_setObject_forKey_,pvVar2,&cfstr_HSPlayMovieApplierVolume);
    _objc_msgSend_stret(local_24,createSettingForMoviePlaybackItem,sel_playRange);
    pvVar2 = _objc_msgSend(cls_NSValue,sel_valueWithBytes_objCType_,local_24,"{HSTimeRange=dd}");
    _objc_msgSend(self_00,sel_setObject_forKey_,pvVar2,&cfstr_HSPlayMovieApplierPlayRange);
  }
  return self_00;
}

*/
- (id)createSettingForMoviePlaybackItem:(id)aItem
{
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];

    if (aItem != nil) {
        [setting setObject:[NSNumber numberWithBool:[aItem useMovieController]] forKey:@"HSPlayMovieApplierUseMovieController"];
        [setting setObject:[NSNumber numberWithFloat:(float)[(HSMoviePlaybackItem *)aItem volume]] forKey:@"HSPlayMovieApplierVolume"];
        struct HSTimeRange range = [aItem playRange];
        [setting setObject:[NSValue valueWithBytes:&range objCType:@encode(struct HSTimeRange)] forKey:@"HSPlayMovieApplierPlayRange"];
    }
    return setting;
}

- (id)buildSettingsForPlaybackItems:(id)aItems withSettingsSelector:(SEL)aSelector
{
    NSMutableDictionary *self_00;
    id self_01;
    NSUInteger pvVar1;
    id pvVar2;
    id pvVar3;
    NSUInteger pvVar4;

    self_00 = [NSMutableDictionary dictionary];
    self_01 = [NSAutoreleasePool new];
    pvVar1 = [aItems count];
    if (pvVar1 != 0) {
        pvVar4 = 0;
        do {
            pvVar2 = [aItems objectAtIndex:pvVar4];
            if (pvVar2 != nil) {
                pvVar3 = [self performSelector:aSelector withObject:pvVar2];
                if (pvVar3 != nil) {
                    [self_00 setObject:pvVar3 forKey:[pvVar2 objectUID]];
                }
            }
            pvVar4 = (pvVar4 + 1);
        } while (pvVar4 < pvVar1);
    }
    [self_01 release];
    return self_00;
}

- (void)removeSettingsForPlaybackItems:(id)aItems fromSettingsStorage:(id)aStorage
{
    id self_00;
    NSUInteger pvVar3;
    NSUInteger pvVar1_2;

    if (([aItems count] != 0) && (aStorage != nil)) {
        pvVar1_2 = [aItems count];
        if (pvVar1_2 != 0) {
            pvVar3 = 0;
            do {
                self_00 = [aItems objectAtIndex:pvVar3];
                if (self_00 != nil) {
                    [aStorage removeObjectForKey:[self_00 objectUID]];
                }
                pvVar3 = (pvVar3 + 1);
            } while (pvVar3 < pvVar1_2);
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c3a8f @ 001c3a8f, 117 bytes * /

void FUN_001c3a8f(HSPlayMovieActionPaneApplier *self,SEL _cmd,id addSettingsForPlaybackItems,
                 SEL withSettingsSelector,id toSettingsStorage)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(addSettingsForPlaybackItems,sel_count);
  if (((pvVar1 != (id)0x0) && (toSettingsStorage != (id)0x0)) && (withSettingsSelector != (SEL)0x0))
  {
    pvVar1 = _objc_msgSend(self,sel_buildSettingsForPlaybackItems_withSettingsSelector_,
                           addSettingsForPlaybackItems,withSettingsSelector);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(toSettingsStorage,sel_addEntriesFromDictionary_,pvVar1,withSettingsSelector);
    }
  }
  return;
}

*/
- (void)addSettingsForPlaybackItems:(id)aItems withSettingsSelector:(SEL)aSelector toSettingsStorage:(id)aStorage
{
    if ([aItems count] != 0 && aStorage != nil && aSelector != NULL) {
        id settings = [self buildSettingsForPlaybackItems:aItems withSettingsSelector:aSelector];
        if (settings != nil) {
            [aStorage addEntriesFromDictionary:settings];
        }
    }
}

- (void)applingSettings:(id)aSettings toLiveVideoPlaybackItem:(id)aItem
{
    id pvVar1;

    if (aItem != nil) {
        pvVar1 = [aSettings objectForKey:@"HSPlayMovieApplierLiveVideoName"]
        ;
        if (pvVar1 != nil) {
            [aItem setLiveVideoName:pvVar1];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c5012 @ 001c5012, 309 bytes * /

void FUN_001c5012(HSPlayMovieActionPaneApplier *self,SEL _cmd,id applingSettings,
                 id toMoviePlaybackItem)

{
  id pvVar1;
  double dVar2;
  undefined8 in_stack_ffffffcc;
  undefined8 uVar3;
  undefined4 local_24;
  undefined4 uStack_20;
  undefined4 local_1c;
  undefined4 uStack_18;
  
  if (toMoviePlaybackItem != (id)0x0) {
    uVar3 = CONCAT44((int)((ulonglong)in_stack_ffffffcc >> 0x20),
                     &cfstr_HSPlayMovieApplierUseMovieController);
    pvVar1 = _objc_msgSend(applingSettings,sel_objectForKey_,
                           &cfstr_HSPlayMovieApplierUseMovieController);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_boolValue,uVar3);
      _objc_msgSend(toMoviePlaybackItem,sel_setUseMovieController_,(int)(char)pvVar1);
    }
    pvVar1 = _objc_msgSend(applingSettings,sel_objectForKey_,&cfstr_HSPlayMovieApplierVolume);
    if (pvVar1 != (id)0x0) {
      dVar2 = _objc_msgSend_fpret(pvVar1,sel_floatValue);
      _objc_msgSend(toMoviePlaybackItem,sel_setVolume_,(float)dVar2);
    }
    pvVar1 = _objc_msgSend(applingSettings,sel_objectForKey_,&cfstr_HSPlayMovieApplierPlayRange);
    if (pvVar1 != (id)0x0) {
      uStack_20 = 0;
      local_24 = 0;
      uStack_18 = 0;
      local_1c = 0;
      _objc_msgSend(pvVar1,sel_getValue_,&local_24);
      _objc_msgSend(toMoviePlaybackItem,sel_setPlayRange_,CONCAT44(uStack_20,local_24),
                    CONCAT44(uStack_18,local_1c));
    }
  }
  return;
}

*/
- (void)applingSettings:(id)aSettings toMoviePlaybackItem:(id)aItem
{
    id value;

    if (aItem == nil) {
        return;
    }
    value = [aSettings objectForKey:@"HSPlayMovieApplierUseMovieController"];
    if (value != nil) {
        [aItem setUseMovieController:[value boolValue]];
    }
    value = [aSettings objectForKey:@"HSPlayMovieApplierVolume"];
    if (value != nil) {
        [(HSMoviePlaybackItem *)aItem setVolume:[value floatValue]];
    }
    value = [aSettings objectForKey:@"HSPlayMovieApplierPlayRange"];
    if (value != nil) {
        struct HSTimeRange range = {0, 0};
        [value getValue:&range];
        [aItem setPlayRange:range];
    }
}

- (void)applingSettings:(id)aSettings toPlaybackItems:(id)aItems withAppingSelector:(SEL)aSelector
{
    id self_00;
    NSUInteger pvVar3;
    NSUInteger pvVar1_2;
    id pvVar2_3;

    if ([aItems count] != 0) {
        pvVar1_2 = [aItems count];
        if (pvVar1_2 != 0) {
            pvVar3 = 0;
            do {
                self_00 = [aItems objectAtIndex:pvVar3];
                if (self_00 != nil) {
                    pvVar2_3 = [aSettings objectForKey:[self_00 objectUID]];
                    if (aSettings != nil) {
                        [self performSelector:aSelector withObject:pvVar2_3 withObject:self_00];
                    }
                }
                pvVar3 = (pvVar3 + 1);
            } while (pvVar3 < pvVar1_2);
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c385d @ 001c385d, 273 bytes * /

void FUN_001c385d(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  if ((self->_initialSettingApplied[0] & 1) == 0) {
    pvVar1 = _objc_msgSend(self->_moviesSettings,sel_count);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self,sel_applingSettings_toPlaybackItems_withAppingSelector_,
                    self->_moviesSettings,self->_movies,sel_applingSettings_toMoviePlaybackItem_);
    }
    pvVar1 = _objc_msgSend(self->_liveVideosSettings,sel_count);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar1 = self->_liveVideos;
    pvVar2 = self->_liveVideosSettings;
  }
  else {
    pvVar1 = _objc_msgSend(self->_initialMoviesSettings,sel_count);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(self,sel_applingSettings_toPlaybackItems_withAppingSelector_,
                    self->_initialMoviesSettings,self->_movies,
                    sel_applingSettings_toMoviePlaybackItem_);
    }
    pvVar1 = _objc_msgSend(self->_initialLiveVideosSettings,sel_count);
    if (pvVar1 == (id)0x0) {
      return;
    }
    pvVar1 = self->_liveVideos;
    pvVar2 = self->_initialLiveVideosSettings;
  }
  _objc_msgSend(self,sel_applingSettings_toPlaybackItems_withAppingSelector_,pvVar2,pvVar1,
                sel_applingSettings_toLiveVideoPlaybackItem_);
  return;
}

*/
- (void)applingPlaybackItemsSettings
{
    if (!_initialSettingApplied) {
        if ([_moviesSettings count] != 0) {
            [self applingSettings:_moviesSettings toPlaybackItems:_movies withAppingSelector:@selector(applingSettings:toMoviePlaybackItem:)];
        }
        if ([_liveVideosSettings count] != 0) {
            [self applingSettings:_liveVideosSettings toPlaybackItems:_liveVideos withAppingSelector:@selector(applingSettings:toLiveVideoPlaybackItem:)];
        }
    }
    else {
        if ([_initialMoviesSettings count] != 0) {
            [self applingSettings:_initialMoviesSettings toPlaybackItems:_movies withAppingSelector:@selector(applingSettings:toMoviePlaybackItem:)];
        }
        if ([_initialLiveVideosSettings count] != 0) {
            [self applingSettings:_initialLiveVideosSettings toPlaybackItems:_liveVideos withAppingSelector:@selector(applingSettings:toLiveVideoPlaybackItem:)];
        }
    }
}

- (void)buildSettingsForPlaybackItems
{
    id self_00;

    self_00 = [NSAutoreleasePool new];
    [_initialMoviesSettings release];
    _initialMoviesSettings = [NSMutableDictionary new];
    [_moviesSettings release];
    _moviesSettings = [NSMutableDictionary new];
    if ([_movies count] != 0) {
        [self addSettingsForPlaybackItems:_movies withSettingsSelector:@selector(createSettingForMoviePlaybackItem:) toSettingsStorage:_initialMoviesSettings]
        ;
        [self addSettingsForPlaybackItems:_movies withSettingsSelector:@selector(createSettingForMoviePlaybackItem:) toSettingsStorage:_moviesSettings];
    }
    [_initialLiveVideosSettings release];
    _initialLiveVideosSettings = [NSMutableDictionary new];
    [_liveVideosSettings release];
    _liveVideosSettings = [NSMutableDictionary new];
    if ([_liveVideos count] != 0) {
        [self addSettingsForPlaybackItems:_liveVideos withSettingsSelector:@selector(createSettingForLiveVideoPlaybackItem:) toSettingsStorage:_initialLiveVideosSettings];
        [self addSettingsForPlaybackItems:_liveVideos withSettingsSelector:@selector(createSettingForLiveVideoPlaybackItem:) toSettingsStorage:_liveVideosSettings];
    }
    [self_00 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c3645 @ 001c3645, 52 bytes * /

uint FUN_001c3645(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  
  if ((self->_initialSettingApplied[0] & 1) == 0) {
    pvVar1 = self->_liveVideos;
  }
  else {
    pvVar1 = self->_initialLiveVideos;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  return (uint)pvVar1;
}

*/
- (NSUInteger)liveVideosCountInCurrentAppliedSettings
{
    return [(_initialSettingApplied ? _initialLiveVideos : _liveVideos) count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c3611 @ 001c3611, 52 bytes * /

uint FUN_001c3611(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  
  if ((self->_initialSettingApplied[0] & 1) == 0) {
    pvVar1 = self->_movies;
  }
  else {
    pvVar1 = self->_initialMovies;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  return (uint)pvVar1;
}

*/
- (NSUInteger)moviesCountInCurrentAppliedSettings
{
    return [(_initialSettingApplied ? _initialMovies : _movies) count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c34e3 @ 001c34e3, 302 bytes * /

void FUN_001c34e3(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  undefined *puVar2;
  id pvVar3;
  undefined4 uVar4;
  
  pvVar1 = _objc_msgSend(cls_NSArray,sel_alloc);
  puVar2 = self->_movies;
  pvVar3 = (id)0x1;
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithArray_copyItems_,puVar2,1);
  self->_initialMovies = pvVar1;
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar1 != (id)0x0) {
    pvVar1 = self->_initialMovies;
    pvVar3 = _objc_msgSend(self,sel_playMovieActionAttributes,puVar2,pvVar3);
    puVar2 = sel_setPlaybackItemSupport_;
    _objc_msgSend(pvVar1,sel_makeObjectsPerformSelector_withObject_,sel_setPlaybackItemSupport_,
                  pvVar3);
  }
  pvVar3 = _objc_msgSend(cls_NSArray,sel_alloc,puVar2,pvVar3);
  pvVar1 = self->_liveVideos;
  uVar4 = 1;
  pvVar3 = _objc_msgSend(pvVar3,sel_initWithArray_copyItems_,pvVar1,1);
  self->_initialLiveVideos = pvVar3;
  pvVar3 = _objc_msgSend(pvVar3,sel_count);
  if (pvVar3 != (id)0x0) {
    pvVar3 = self->_initialLiveVideos;
    pvVar1 = _objc_msgSend(self,sel_playMovieActionAttributes,pvVar1,uVar4);
    _objc_msgSend(pvVar3,sel_makeObjectsPerformSelector_withObject_,sel_setPlaybackItemSupport_,
                  pvVar1);
  }
  return;
}

*/
- (void)copyDataContainsInCurrentStateToInitial
{
    _initialMovies = [[NSArray alloc] initWithArray:_movies copyItems:YES];
    if ([_initialMovies count] != 0) {
        [_initialMovies makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:[self playMovieActionAttributes]];
    }
    _initialLiveVideos = [[NSArray alloc] initWithArray:_liveVideos copyItems:YES];
    if ([_initialLiveVideos count] != 0) {
        [_initialLiveVideos makeObjectsPerformSelector:@selector(setPlaybackItemSupport:) withObject:[self playMovieActionAttributes]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c2c9c @ 001c2c9c, 26 bytes * /

void FUN_001c2c9c(HSPlayMovieActionPaneApplier *self,SEL _cmd,BOOL setIgnoresAssistantActions)

{
  self->_initialSettingApplied[0] =
       self->_initialSettingApplied[0] & 0xfd | setIgnoresAssistantActions * '\x02' & 2U;
  return;
}

*/
- (void)setIgnoresAssistantActions:(BOOL)aActions
{
    _ignoresAssistantActions = aActions ? 1 : 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c2c86 @ 001c2c86, 22 bytes * /

BOOL FUN_001c2c86(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_initialSettingApplied[0] & 2) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)ignoresAssistantActions
{
    return _ignoresAssistantActions ? YES : NO;
}

- (void)setLiveVideoPlaybackItem:(id)aItem name:(id)aName
{
    id pvVar2_2;

    [aItem setLiveVideoName:aName];
    pvVar2_2 = [_liveVideosSettings objectForKey:[aItem objectUID]];
    if (pvVar2_2 != nil) {
        [pvVar2_2 setObject:aName forKey:@"HSPlayMovieApplierLiveVideoName"];
    }
}

- (void)removeLiveVideo:(id)aVideo
{
    id pvVar2;
    id pvVar1_3;

    pvVar1_3 = [[[self playMovieActionAttributes] liveVideos] mutableCopy];
    [pvVar1_3 removeObject:aVideo];
    [self setLiveVideos:pvVar1_3];
    pvVar2 = [NSArray arrayWithObject:aVideo];
    [self removeSettingsForPlaybackItems:pvVar2 fromSettingsStorage:_initialLiveVideosSettings];
    [self removeSettingsForPlaybackItems:pvVar2 fromSettingsStorage:_liveVideosSettings];
    [pvVar1_3 release];
}

- (void)addLiveVideo:(id)aVideo
{
    id pvVar1_2;
    id pvVar1_4;

    pvVar1_2 = [[self playMovieActionAttributes] liveVideos];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [NSArray array];
    }
    [self setLiveVideos:[pvVar1_2 arrayByAddingObject:aVideo]];
    pvVar1_4 = [NSArray arrayWithObject:aVideo];
    [self addSettingsForPlaybackItems:pvVar1_4 withSettingsSelector:@selector(createSettingForLiveVideoPlaybackItem:) toSettingsStorage:_initialLiveVideosSettings];
    [self addSettingsForPlaybackItems:pvVar1_4 withSettingsSelector:@selector(createSettingForLiveVideoPlaybackItem:) toSettingsStorage:_liveVideosSettings];
}

- (void)setLiveVideos:(id)aVideos
{
    if (![_liveVideos isEqual:aVideos]) {
        [_liveVideos release];
        _liveVideos = [aVideos retain];
        [self stopObservingChangesFromPlayMovieAction];
        [self disableUndo];
        [[self playMovieActionAttributes] setLiveVideos:_liveVideos];
        [self enableUndo];
        [self startObservingChangesFromPlayMovieAction];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c30c5 @ 001c30c5, 201 bytes * /

void FUN_001c30c5(HSPlayMovieActionPaneApplier *self,SEL _cmd,id setMoviePlaybackItem,
                 HSTimeRange playRange)

{
  id pvVar1;
  id pvVar2;
  double local_24;
  double local_1c;
  
  local_24 = playRange.location;
  local_1c = playRange.length;
  _objc_msgSend(setMoviePlaybackItem,sel_setPlayRange_,playRange.location,playRange.length);
  pvVar2 = self->_moviesSettings;
  pvVar1 = _objc_msgSend(setMoviePlaybackItem,sel_objectUID);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,pvVar1);
  if (pvVar2 != (id)0x0) {
    pvVar1 = _objc_msgSend(cls_NSValue,sel_valueWithBytes_objCType_,&local_24,"{HSTimeRange=dd}",
                           playRange.length);
    _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar1,&cfstr_HSPlayMovieApplierPlayRange);
  }
  return;
}

*/
- (void)setMoviePlaybackItem:(id)aItem playRange:(struct HSTimeRange)aRange
{
    [aItem setPlayRange:aRange];
    id setting = [_moviesSettings objectForKey:[aItem objectUID]];
    if (setting != nil) {
        [setting setObject:[NSValue valueWithBytes:&aRange objCType:@encode(struct HSTimeRange)] forKey:@"HSPlayMovieApplierPlayRange"];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c5147 @ 001c5147, 188 bytes * /

void FUN_001c5147(HSPlayMovieActionPaneApplier *self,SEL _cmd,id setMoviePlaybackItem,float volume)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  double dVar3;
  
  _objc_msgSend(setMoviePlaybackItem,sel_setVolume_,volume);
  pvVar2 = self->_moviesSettings;
  pvVar1 = _objc_msgSend(setMoviePlaybackItem,sel_objectUID);
  pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,pvVar1);
  self_00 = cls_NSNumber;
  if (pvVar2 != (id)0x0) {
    dVar3 = _objc_msgSend_fpret(setMoviePlaybackItem,sel_volume);
    pvVar1 = _objc_msgSend(self_00,sel_numberWithFloat_,(float)dVar3);
    _objc_msgSend(pvVar2,sel_setObject_forKey_,pvVar1,&cfstr_HSPlayMovieApplierVolume);
  }
  return;
}

*/
- (void)setMoviePlaybackItem:(id)aItem volume:(CGFloat)aVolume
{
    [(HSMoviePlaybackItem *)aItem setVolume:aVolume];
    id setting = [_moviesSettings objectForKey:[aItem objectUID]];
    if (setting != nil) {
        [setting setObject:[NSNumber numberWithFloat:(float)[(HSMoviePlaybackItem *)aItem volume]] forKey:@"HSPlayMovieApplierVolume"];
    }
}

- (void)setMoviePlaybackItem:(id)aItem useMovieController:(BOOL)aController
{
    id pvVar2_2;

    [aItem setUseMovieController:aController];
    pvVar2_2 = [_moviesSettings objectForKey:[aItem objectUID]];
    if (pvVar2_2 != nil) {
        [pvVar2_2 setObject:[NSNumber numberWithBool:(unsigned int)[aItem useMovieController] & 0xff] forKey:@"HSPlayMovieApplierUseMovieController"];
    }
}

- (void)removeMovie:(id)aMovie
{
    id pvVar1_3;

    pvVar1_3 = [[[self playMovieActionAttributes] movies] mutableCopy];
    [pvVar1_3 removeObject:aMovie];
    [self setMovies:pvVar1_3];
    [self removeSettingsForPlaybackItems:[NSArray arrayWithObject:aMovie] fromSettingsStorage:_moviesSettings];
    [pvVar1_3 release];
}

- (void)addMovie:(id)aMovie
{
    id pvVar1_2;

    pvVar1_2 = [[self playMovieActionAttributes] movies];
    if (pvVar1_2 == nil) {
        pvVar1_2 = [NSArray array];
    }
    [self setMovies:[pvVar1_2 arrayByAddingObject:aMovie]];
    [self addSettingsForPlaybackItems:[NSArray arrayWithObject:aMovie] withSettingsSelector:@selector(createSettingForMoviePlaybackItem:) toSettingsStorage:_moviesSettings];
}

- (void)setMovies:(id)aMovies
{
    if (![_movies isEqual:aMovies]) {
        [_movies release];
        _movies = [aMovies retain];
        [self stopObservingChangesFromPlayMovieAction];
        [self disableUndo];
        [[self playMovieActionAttributes] setMovies:_movies];
        [self enableUndo];
        [self startObservingChangesFromPlayMovieAction];
    }
}

- (void)invalidateActionAttributes
{
    [self stopObservingChangesFromPlayMovieAction];
    [super invalidateActionAttributes];
    [_playMovieActionAttributes release];
    _playMovieActionAttributes = nil;
    [self moviesChanged:nil];
    [self startObservingChangesFromPlayMovieAction];
}

- (BOOL)areSettingsEqual
{
    BOOL pvVar1;
    char cVar2;

    pvVar1 = [super areSettingsEqual];
    cVar2 = pvVar1;
    if ((_initialMovies != nil) || (_movies != nil)) {
        if ((cVar2 == NO) || (pvVar1 = [_initialMovies isEqualToArray:_movies], !pvVar1)) {
            cVar2 = NO;
        }
        else {
            cVar2 = YES;
        }
    }
    if ((_initialLiveVideos != nil) || (_liveVideos != nil)) {
        if ((cVar2 == NO) || (pvVar1 = [_initialLiveVideos isEqualToArray:_liveVideos], !pvVar1)) {
            cVar2 = NO;
        }
        else {
            cVar2 = YES;
        }
    }
    if ((_initialMoviesSettings != nil) || (_moviesSettings != nil)) {
        if ((cVar2 == NO) || (pvVar1 = [_initialMoviesSettings isEqualToDictionary:_moviesSettings], !pvVar1)) {
            cVar2 = NO;
        }
        else {
            cVar2 = YES;
        }
    }
    if ((_initialLiveVideosSettings != nil) || (_liveVideosSettings != nil)) {
        if (cVar2 == NO) {
            cVar2 = NO;
        }
        else {
            pvVar1 = [_initialLiveVideosSettings isEqualToDictionary:_liveVideosSettings];
            cVar2 = pvVar1;
        }
    }
    return cVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c53a6 @ 001c53a6, 153 bytes * /

void FUN_001c53a6(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  HSPlayMovieActionPaneApplier *local_14;
  undefined *local_10;
  
  if ((self->_initialSettingApplied[0] & 2) == 0) {
    local_14 = self;
    local_10 = PTR_s_HSActionAssistantSettingsApplier_003538d0;
    _objc_msgSendSuper(&local_14,sel_makeCurrentEqualToInitial);
    _objc_msgSend(self->_movies,sel_release);
    pvVar1 = _objc_msgSend(self->_initialMovies,sel_retain);
    self->_movies = pvVar1;
    _objc_msgSend(self->_liveVideos,sel_release);
    pvVar1 = _objc_msgSend(self->_initialLiveVideos,sel_retain);
    self->_liveVideos = pvVar1;
  }
  return;
}

*/
- (void)makeCurrentEqualToInitial
{
    if (!_ignoresAssistantActions) {
        [super makeCurrentEqualToInitial];
        [_movies release];
        _movies = [_initialMovies retain];
        [_liveVideos release];
        _liveVideos = [_initialLiveVideos retain];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c543f @ 001c543f, 123 bytes * /

void FUN_001c543f(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  HSPlayMovieActionPaneApplier *local_14;
  undefined *local_10;
  
  if ((self->_initialSettingApplied[0] & 2) == 0) {
    local_14 = self;
    local_10 = PTR_s_HSActionAssistantSettingsApplier_003538d0;
    _objc_msgSendSuper(&local_14,sel_makeInitialEqualToCurrent);
    _objc_msgSend(self->_initialMovies,sel_release);
    _objc_msgSend(self->_initialLiveVideos,sel_release);
    _objc_msgSend(self,sel_copyDataContainsInCurrentStateToInitial);
  }
  return;
}

*/
- (void)makeInitialEqualToCurrent
{
    if (!_ignoresAssistantActions) {
        [super makeInitialEqualToCurrent];
        [_initialMovies release];
        [_initialLiveVideos release];
        [self copyDataContainsInCurrentStateToInitial];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c54ba @ 001c54ba, 197 bytes * /

void FUN_001c54ba(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  id self_00;
  HSPlayMovieActionPaneApplier *local_1c;
  undefined *local_18;
  
  if ((self->_initialSettingApplied[0] & 2) == 0) {
    _objc_msgSend(self,sel_stopObservingChangesFromPlayMovieAction);
    self_00 = _objc_msgSend(self,sel_playMovieActionAttributes);
    self->_initialSettingApplied[0] = self->_initialSettingApplied[0] | 1;
    _objc_msgSend(self,sel_applingPlaybackItemsSettings);
    _objc_msgSend(self_00,sel_setMovies_,self->_initialMovies);
    _objc_msgSend(self_00,sel_setLiveVideos_,self->_initialLiveVideos);
    _objc_msgSend(self,sel_startObservingChangesFromPlayMovieAction);
    local_1c = self;
    local_18 = PTR_s_HSActionAssistantSettingsApplier_003538d0;
    _objc_msgSendSuper(&local_1c,sel_setInitialSettingsToObject);
  }
  return;
}

*/
- (void)setInitialSettingsToObject
{
    if (!_ignoresAssistantActions) {
        [self stopObservingChangesFromPlayMovieAction];
        id attributes = [self playMovieActionAttributes];
        _initialSettingApplied = 1;
        [self applingPlaybackItemsSettings];
        [attributes setMovies:_initialMovies];
        [attributes setLiveVideos:_initialLiveVideos];
        [self startObservingChangesFromPlayMovieAction];
        [super setInitialSettingsToObject];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c557f @ 001c557f, 474 bytes * /

void FUN_001c557f(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 *puVar5;
  undefined1 *puVar6;
  undefined4 uVar7;
  HSPlayMovieActionPaneApplier *local_7c;
  undefined *local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  if ((self->_initialSettingApplied[0] & 2) == 0) {
    local_7c = self;
    local_78 = PTR_s_HSActionAssistantSettingsApplier_003538d0;
    _objc_msgSendSuper(&local_7c,sel_setCurrentSettingsToObject);
    _objc_msgSend(self,sel_stopObservingChangesFromPlayMovieAction);
    pvVar2 = _objc_msgSend(self,sel_playMovieActionAttributes);
    _objc_msgSend(pvVar2,sel_setMovies_,self->_movies);
    puVar5 = self->_liveVideos;
    _objc_msgSend(pvVar2,sel_setLiveVideos_,puVar5);
    self->_initialSettingApplied[0] = self->_initialSettingApplied[0] & 0xfe;
    _objc_msgSend(self,sel_applingPlaybackItemsSettings);
    pvVar2 = _objc_msgSend(self,sel_areSettingsEqual);
    if ((char)pvVar2 == '\0') {
      local_74 = 0;
      local_70 = 0;
      local_6c = (int *)0x0;
      local_68 = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      pvVar2 = self->_movies;
      puVar6 = local_50;
      puVar5 = &local_74;
      uVar7 = 0x10;
      pvVar3 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar5,puVar6,
                             0x10);
      if (pvVar3 != (id)0x0) {
        iVar1 = *local_6c;
        do {
          pvVar4 = (id)0x0;
          do {
            if (iVar1 != *local_6c) {
              _objc_enumerationMutation(self->_movies);
            }
            _objc_msgSend(self,sel_HSPlayMovieActionPaneApplier_updatePlayMovieObjectForItem_,
                          *(undefined4 *)(local_70 + (int)pvVar4 * 4),puVar6,uVar7);
            pvVar4 = (id)((int)pvVar4 + 1);
          } while (pvVar4 < pvVar3);
          puVar6 = local_50;
          puVar5 = &local_74;
          uVar7 = 0x10;
          pvVar3 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,puVar5,puVar6
                                 ,0x10);
        } while (pvVar3 != (id)0x0);
      }
    }
    _objc_msgSend(self,sel_startObservingChangesFromPlayMovieAction,puVar5);
  }
  return;
}

*/
- (void)setCurrentSettingsToObject
{
    if (!_ignoresAssistantActions) {
        [super setCurrentSettingsToObject];
        [self stopObservingChangesFromPlayMovieAction];
        id attributes = [self playMovieActionAttributes];
        [attributes setMovies:_movies];
        [attributes setLiveVideos:_liveVideos];
        _initialSettingApplied = 0;
        [self applingPlaybackItemsSettings];
        if (![self areSettingsEqual]) {
            for (id movie in _movies) {
                [self HSPlayMovieActionPaneApplier_updatePlayMovieObjectForItem:movie];
            }
        }
        [self startObservingChangesFromPlayMovieAction];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c5759 @ 001c5759, 59 bytes * /

void FUN_001c5759(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  HSPlayMovieActionPaneApplier *local_c;
  undefined *local_8;
  
  if ((self->_initialSettingApplied[0] & 2) == 0) {
    local_c = self;
    local_8 = PTR_s_HSActionAssistantSettingsApplier_003538d0;
    _objc_msgSendSuper(&local_c,sel_applyChanges);
  }
  return;
}

*/
- (void)applyChanges
{
    if (!_ignoresAssistantActions) {
        [super applyChanges];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c5794 @ 001c5794, 81 bytes * /

void FUN_001c5794(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  HSPlayMovieActionPaneApplier *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_HSActionAssistantSettingsApplier_003538d0;
  _objc_msgSendSuper(&local_14,sel_addActionToActor);
  if (self->_ignoresAssistantActions[0] == 0) {
    _objc_msgSend(self,sel_buildSettingsForPlaybackItems);
  }
  return;
}

*/
- (void)addActionToActor
{
    [super addActionToActor];
    if (!_settingsForPlaybackItemsBuilded) {
        [self buildSettingsForPlaybackItems];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001c2cb6 @ 001c2cb6, 218 bytes * /

void FUN_001c2cb6(HSPlayMovieActionPaneApplier *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_playMovieActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_movies);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_movies = pvVar1;
  pvVar1 = _objc_msgSend(self,sel_playMovieActionAttributes);
  pvVar1 = _objc_msgSend(pvVar1,sel_liveVideos);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_liveVideos = pvVar1;
  _objc_msgSend(self,sel_copyDataContainsInCurrentStateToInitial);
  pvVar1 = _objc_msgSend(self,sel_isInActor);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_buildSettingsForPlaybackItems);
    self->_ignoresAssistantActions[0] = 1;
  }
  _objc_msgSend(self,sel_startObservingChangesFromPlayMovieAction);
  return;
}

*/
- (void)setUpInitialSettings
{
    _movies = [[[self playMovieActionAttributes] movies] retain];
    _liveVideos = [[[self playMovieActionAttributes] liveVideos] retain];
    [self copyDataContainsInCurrentStateToInitial];
    if ([self isInActor]) {
        [self buildSettingsForPlaybackItems];
        _settingsForPlaybackItemsBuilded = YES;
    }
    [self startObservingChangesFromPlayMovieAction];
}

- (id)playMovieActionAttributes
{
    id pvVar1;

    pvVar1 = _playMovieActionAttributes;
    if (pvVar1 == nil) {
        pvVar1 = [[[super actionAttributes] queryHyperInterface:@protocol(HSPlayMovieActionAttributes)] retain];
        _playMovieActionAttributes = pvVar1;
    }
    return pvVar1;
}

- (void)dealloc
{
    [self stopObservingChangesFromPlayMovieAction];
    [_movies release];
    [_initialMovies release];
    [_initialLiveVideos release];
    [_liveVideos release];
    [_initialMoviesSettings release];
    [_moviesSettings release];
    [_initialLiveVideosSettings release];
    [_liveVideosSettings release];
    [_playMovieActionAttributes release];
    [super dealloc];
}

@end

