#import "HSExportManager.h"

@implementation HSExportManager

/* i386 ivar offsets: _document=0x4, _previewDocument=0x8, _exporter=0xc, _publisher=0x10, _exportFormat=0x14, _publishType=0x18, _progressSheetController=0x1c, _exportSessionError=0x20, _alertToDidEndInvocationMapTable=0x24, _movieObjectsRunOnArrive=0x28, _movieObjectsRunOnArriveTemporaryState=0x2c, _movieObjectsRunOnLeave=0x30, _movieObjectsRunOnLeaveTemporaryState=0x34, _slideshowAttributes=0x38, _slideshowTransitionRenderer=0x3c, _slideshowTransitionImageIndex=0x40, _isExporting=0x44, _isPublishing=0x44, _hasSessionError=0x44, _isMovieExportHelperEnable=0x44, _embeddedCode=0x48 */

- (id)hyperCastingLauncherForExporter:(id)aExporter
{
    return _document;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025df75 @ 0025df75, 482 bytes * /

void FUN_0025df75(HSExportManager *self,SEL _cmd,double setCurrentTimeForMovies,BOOL runOnStart,
                 uint onCardAtIndex,id forExporter)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id *ppvVar5;
  int *piVar6;
  id pvVar7;
  longdouble lVar8;
  int aiStack_54 [2];
  double local_24;
  double local_1c;
  
  if (runOnStart == '\0') {
    ppvVar5 = &self->_movieObjectsRunOnLeave;
  }
  else {
    ppvVar5 = &self->_movieObjectsRunOnArrive;
  }
  self_00 = *ppvVar5;
  if (runOnStart == '\0') {
    ppvVar5 = &self->_movieObjectsRunOnLeaveTemporaryState;
  }
  else {
    ppvVar5 = &self->_movieObjectsRunOnArriveTemporaryState;
  }
  pvVar1 = *ppvVar5;
  pvVar2 = _objc_msgSend(self_00,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar7 = (id)0x0;
    piVar6 = (int *)&stack0xffffffb4;
    do {
      piVar6[2] = (int)pvVar7;
      piVar6[1] = (int)sel_objectAtIndex_;
      *piVar6 = (int)self_00;
      piVar6[-1] = 0x25dfe7;
      pvVar3 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
      piVar6[2] = (int)sel_hyperPlayRange;
      piVar6[1] = (int)pvVar3;
      *piVar6 = (int)&local_24;
      piVar6[-1] = 0x25e002;
      _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
      if (local_1c <= setCurrentTimeForMovies) {
        *piVar6 = (int)sel_hyperPlayCount;
        piVar6[-1] = (int)pvVar3;
        piVar6[-2] = 0x25e0a9;
        pvVar4 = _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
        if (pvVar4 != (id)0x1) {
          *(double *)(piVar6 + 1) = local_1c;
          *(double *)(piVar6 + -1) = setCurrentTimeForMovies;
          piVar6[-2] = 0x25e0c8;
          lVar8 = (longdouble)_remainder();
          *(double *)(piVar6 + 1) = (double)lVar8;
          *piVar6 = (int)sel_setHyperCurrentTime_;
          piVar6[-1] = (int)pvVar3;
          piVar6[-2] = 0x25e0de;
          _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
          goto joined_r0x0025e0eb;
        }
        *piVar6 = (int)sel_hyperEraseWhenDone;
        piVar6[-1] = (int)pvVar3;
        piVar6[-2] = 0x25e105;
        pvVar4 = _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
        if ((char)pvVar4 != '\0') {
          *piVar6 = (int)sel_setHidden_;
          piVar6[-1] = (int)pvVar3;
          piVar6[1] = 1;
          piVar6[-2] = 0x25e123;
          _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
        }
        *(double *)(piVar6 + 1) = local_24 + local_1c;
        *piVar6 = (int)sel_setHyperCurrentTime_;
        piVar6[-1] = (int)pvVar3;
LAB_0025e140:
        piVar6[-2] = 0x25e145;
        _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
      }
      else {
        *(double *)(piVar6 + 1) = local_24 + setCurrentTimeForMovies;
        *piVar6 = (int)sel_setHyperCurrentTime_;
        piVar6[-1] = (int)pvVar3;
        piVar6[-2] = 0x25e037;
        _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
joined_r0x0025e0eb:
        if (0.0 < setCurrentTimeForMovies) {
          piVar6[1] = (int)pvVar7;
          *piVar6 = (int)sel_objectAtIndex_;
          piVar6[-1] = (int)pvVar1;
          piVar6[-2] = 0x25e063;
          pvVar4 = _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
          *piVar6 = (int)sel_boolValue;
          piVar6[-1] = (int)pvVar4;
          piVar6[-2] = 0x25e075;
          pvVar4 = _objc_msgSend((id)piVar6[-1],(SEL)*piVar6);
          if ((char)pvVar4 != '\0') {
            *piVar6 = (int)sel_setHidden_;
            piVar6[-1] = (int)pvVar3;
            piVar6[1] = 0;
            goto LAB_0025e140;
          }
        }
      }
      pvVar7 = (id)((int)pvVar7 + 1);
      piVar6 = piVar6 + -1;
    } while (pvVar7 < pvVar2);
  }
  return;
}

*/
- (void)setCurrentTimeForMovies:(double)aMovies runOnStart:(BOOL)aStart onCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    NSArray *movies = aStart ? _movieObjectsRunOnArrive : _movieObjectsRunOnLeave;
    NSArray *temporaryStates = aStart ? _movieObjectsRunOnArriveTemporaryState : _movieObjectsRunOnLeaveTemporaryState;
    NSUInteger count = [movies count];
    for (NSUInteger i = 0; i < count; i++) {
        id movie = [movies objectAtIndex:i];
        struct HSTimeRange range = [movie hyperPlayRange];
        if (range.length <= aMovies) {
            if ([movie hyperPlayCount] == 1) {
                // Played once and finished: park it on its last frame.
                if ([movie hyperEraseWhenDone]) {
                    [movie setHidden:YES];
                }
                [movie setHyperCurrentTime:range.location + range.length];
                continue;
            }
            // Looping. The original does not add the range start here.
            [movie setHyperCurrentTime:remainder(aMovies, range.length)];
        } else {
            [movie setHyperCurrentTime:range.location + aMovies];
        }
        // Temporary movies stay hidden until they start playing.
        if (aMovies > 0.0 && [[temporaryStates objectAtIndex:i] boolValue]) {
            [movie setHidden:NO];
        }
    }
}

- (double)timeIntervalBetweenFrames
{
    double dVar1;

    if (_slideshowAttributes == nil) {
        dVar1 = 0.0;
    }
    else {
        dVar1 = [_slideshowAttributes durationBetweenSlides];
    }
    return dVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025e188 @ 0025e188, 61 bytes * /

double FUN_0025e188(HSExportManager *self,SEL _cmd,uint transitionTimeAfterCardAtIndex,
                   id forExporter)

{
  id self_00;
  double dVar1;
  
  self_00 = _objc_msgSend(self->_slideshowAttributes,sel_transition);
  dVar1 = _objc_msgSend_fpret(self_00,sel_duration);
  return dVar1;
}

*/
- (double)transitionTimeAfterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    return [(HSQTTransition *)[_slideshowAttributes transition] duration];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025dd49 @ 0025dd49, 162 bytes * /

BOOL FUN_0025dd49(HSExportManager *self,SEL _cmd,uint hasTransitionAfterCardAtIndex,id forExporter)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self->_slideshowAttributes,sel_transition);
  if ((pvVar1 != (id)0x0) &&
     (pvVar1 = _objc_msgSend(pvVar1,sel_isFastestTransition), (char)pvVar1 == '\0')) {
    pvVar1 = _objc_msgSend(self,sel_previewDocument);
    pvVar1 = _objc_msgSend(pvVar1,sel_stack);
    if (pvVar1 != (id)0x0) {
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildren);
      pvVar1 = _objc_msgSend(pvVar1,sel_count);
      return -((id)(hasTransitionAfterCardAtIndex + 1) < pvVar1) & 1;
    }
  }
  return '\0';
}

*/
- (BOOL)hasTransitionAfterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    id transition = [_slideshowAttributes transition];
    if (transition == nil || [transition isFastestTransition]) {
        return NO;
    }
    id stack = [[self previewDocument] stack];
    if (stack == nil) {
        return NO;
    }
    return aIndex + 1 < [[stack hyperChildren] count];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025db00 @ 0025db00, 585 bytes * /

id FUN_0025db00(HSExportManager *self,SEL _cmd,double transitionImageForTime,uint afterCardAtIndex,
               id forExporter)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 extraout_EDX;
  undefined8 uVar5;
  
  pvVar1 = _objc_msgSend(self,sel_previewDocument);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  if (pvVar1 == (id)0x0) {
LAB_0025db3a:
    pvVar1 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(pvVar1,sel_hyperCardSize);
    if (self->_slideshowTransitionImageIndex != afterCardAtIndex) {
      pvVar3 = self->_slideshowTransitionRenderer;
      if (pvVar3 == (id)0x0) {
        pvVar3 = _objc_msgSend(self->_slideshowAttributes,sel_transition);
        pvVar3 = _objc_msgSend(pvVar3,sel_effect);
        pvVar3 = _objc_msgSend(pvVar3,sel_createQuartzRendererForSize_,pvVar2,extraout_EDX);
        self->_slideshowTransitionRenderer = pvVar3;
        if (pvVar3 == (id)0x0) goto LAB_0025db3a;
      }
      pvVar4 = _objc_msgSend(pvVar1,sel_hyperChildAtIndex_,afterCardAtIndex);
      pvVar4 = _objc_msgSend(pvVar4,sel_imageForExport);
      _objc_msgSend(pvVar3,sel_setStartImage_,pvVar4);
      pvVar3 = self->_slideshowTransitionRenderer;
      pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildAtIndex_,afterCardAtIndex + 1);
      pvVar1 = _objc_msgSend(pvVar1,sel_imageForExport);
      _objc_msgSend(pvVar3,sel_setEndImage_,pvVar1);
      self->_slideshowTransitionImageIndex = afterCardAtIndex;
    }
    pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
    uVar5 = CONCAT44(extraout_EDX,pvVar2);
    pvVar1 = _objc_msgSend(pvVar1,sel_initWithSize_,pvVar2,extraout_EDX);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
    if (pvVar1 != (id)0x0) {
      _objc_msgSend(pvVar1,sel_lockFocus,uVar5);
      pvVar2 = self->_slideshowTransitionRenderer;
      pvVar3 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
      pvVar3 = _objc_msgSend(pvVar3,sel_graphicsPort);
      _objc_msgSend(pvVar2,sel_renderFrameAtTime_inCoreGraphicsContext_,transitionImageForTime,
                    pvVar3);
      _objc_msgSend(pvVar1,sel_unlockFocus);
    }
  }
  return pvVar1;
}

*/
- (id)transitionImageForTime:(double)aTime afterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    id stack = [[self previewDocument] stack];
    if (stack == nil) {
        return nil;
    }
    NSSize cardSize = [stack hyperCardSize];
    if (_slideshowTransitionImageIndex != aIndex) {
        if (_slideshowTransitionRenderer == nil) {
            _slideshowTransitionRenderer = [[[_slideshowAttributes transition] effect] createQuartzRendererForSize:NSSizeToCGSize(cardSize)];
            if (_slideshowTransitionRenderer == nil) {
                return nil;
            }
        }
        [_slideshowTransitionRenderer setStartImage:[[stack hyperChildAtIndex:aIndex] imageForExport]];
        [_slideshowTransitionRenderer setEndImage:[[stack hyperChildAtIndex:aIndex + 1] imageForExport]];
        _slideshowTransitionImageIndex = (unsigned int)aIndex;
    }
    NSImage *image = [[[NSImage alloc] initWithSize:cardSize] autorelease];
    if (image != nil) {
        [image lockFocus];
        [_slideshowTransitionRenderer renderFrameAtTime:aTime inCoreGraphicsContext:[[NSGraphicsContext currentContext] CGContext]];
        [image unlockFocus];
    }
    return image;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025e1c5 @ 0025e1c5, 372 bytes * /

double FUN_0025e1c5(HSExportManager *self,SEL _cmd,uint asyncSoundLengthOnCardAtIndex)

{
  double dVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int *piVar5;
  int *piVar6;
  int iStack_50;
  double local_34;
  undefined1 local_24 [8];
  double local_1c;
  
  piVar5 = (int *)&stack0xffffffb4;
  pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_array);
  _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_);
  pvVar3 = _objc_msgSend(self,sel_previewDocument);
  pvVar3 = _objc_msgSend(pvVar3,sel_stack);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperChildAtIndex_);
  pvVar3 = _objc_msgSend(pvVar3,sel_actor);
  _objc_msgSend(pvVar3,sel_hyperActionsOfType_forEvent_);
  _objc_msgSend(pvVar2,sel_addObjectsFromArray_);
  local_34 = 0.0;
  pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  do {
    dVar1 = local_34;
    piVar6 = piVar5;
    do {
      do {
        piVar6[1] = (int)sel_nextObject;
        *piVar6 = (int)pvVar2;
        piVar6[-1] = 0x25e320;
        pvVar3 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
        if (pvVar3 == (id)0x0) {
          return dVar1;
        }
        piVar6[1] = (int)sel_isSynchronousSound;
        *piVar6 = (int)pvVar3;
        piVar6[-1] = 0x25e2d3;
        pvVar4 = _objc_msgSend((id)*piVar6,(SEL)piVar6[1]);
      } while ((char)pvVar4 != '\0');
      piVar6[2] = (int)sel_soundPlayRange;
      piVar6[1] = (int)pvVar3;
      *piVar6 = (int)local_24;
      piVar6[-1] = 0x25e2f0;
      _objc_msgSend_stret((void *)*piVar6,(id)piVar6[1],(SEL)piVar6[2]);
      piVar5 = piVar6 + -1;
      piVar6 = piVar6 + -1;
      local_34 = local_1c;
    } while (local_1c <= dVar1);
  } while( true );
}

*/
- (double)asyncSoundLengthOnCardAtIndex:(NSUInteger)aIndex
{
    NSMutableArray *actions = [NSMutableArray array];
    id arrive = [HSActionEvent actionEventOfType:kHSArriveActionEventType];
    [actions addObjectsFromArray:[[[[[self previewDocument] stack] hyperChildAtIndex:aIndex] actor] hyperActionsOfType:@"HSPlaySoundAction" forEvent:arrive]];
    double length = 0.0;
    for (id action in actions) {
        if ([action isSynchronousSound]) {
            continue;
        }
        struct HSTimeRange range = [action soundPlayRange];
        if (range.length > length) {
            length = range.length;
        }
    }
    return length;
}

- (BOOL)asyncSoundPresentOnCardAtIndex:(NSUInteger)aIndex
{
    id pvVar1;
    id pvVar2;
    BOOL pvVar4;
    BOOL bVar5;
    NSEnumerator *pvVar1_2;
    id pvVar3_5;

    pvVar1 = [NSMutableArray array];
    pvVar2 = [HSActionEvent actionEventOfType:kHSArriveActionEventType];
    [pvVar1 addObjectsFromArray:[[[[[self previewDocument] stack] hyperChildAtIndex:aIndex] actor] hyperActionsOfType:@"HSPlaySoundAction" forEvent:pvVar2]];
    pvVar1_2 = [pvVar1 objectEnumerator];
    pvVar3_5 = [pvVar1_2 nextObject];
    if (pvVar3_5 == nil) {
        bVar5 = NO;
    }
    else {
        do {
            pvVar4 = [pvVar3_5 isSynchronousSound];
            pvVar3_5 = [pvVar1_2 nextObject];
            if (pvVar3_5 == nil) break;
        } while (pvVar4);
        bVar5 = !pvVar4;
    }
    return bVar5;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025d673 @ 0025d673, 833 bytes * /

id FUN_0025d673(HSExportManager *self,SEL _cmd,uint soundsWithPropertiesOnCardAtIndex,id forExporter
               )

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  cfstringStruct *pcVar6;
  id pvVar7;
  SEL pcVar8;
  cfstringStruct *pcVar9;
  undefined *puVar10;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar1 = _objc_msgSend(self,sel_previewDocument);
  pvVar1 = _objc_msgSend(pvVar1,sel_stack);
  pvVar2 = _objc_msgSend(pvVar1,sel_hyperChildAtIndex_,soundsWithPropertiesOnCardAtIndex);
  pvVar1 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336080);
  pvVar3 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336500);
  pvVar4 = _objc_msgSend(pvVar2,sel_actor);
  pcVar9 = &cfstr_HSPlaySoundAction;
  pvVar7 = pvVar1;
  pvVar4 = _objc_msgSend(pvVar4,sel_hyperActionsOfType_forEvent_,&cfstr_HSPlaySoundAction,pvVar1);
  pvVar5 = _objc_msgSend(pvVar4,sel_count);
  if (pvVar5 != (id)0x0) {
    pvVar4 = _objc_msgSend(pvVar4,sel_extraFirstObject,pcVar9,pvVar7);
    pcVar9 = (cfstringStruct *)&DAT_003860f4;
    pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_003860f4);
    pvVar5 = _objc_msgSend(pvVar4,sel_stopsAllSounds);
    if ((char)pvVar5 == '\0') {
      pvVar4 = _objc_msgSend(pvVar4,sel_sounds,pcVar9);
      pvVar5 = _objc_msgSend(pvVar4,sel_count);
      if (pvVar5 == (id)0x0) goto LAB_0025d868;
      pcVar6 = _objc_msgSend(self,sel_soundsWithPropertiesFromSoundItems_runOn_,pvVar4,pvVar1);
      pcVar8 = sel_addObjectsFromArray_;
    }
    else {
      pvVar1 = *(id *)PTR_PTR_00336934;
      pcVar9 = *(cfstringStruct **)PTR_00336854;
      pcVar6 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,pcVar9,pvVar1);
      pcVar8 = sel_addObject_;
      pvVar7 = pvVar1;
      if (pcVar6 == (cfstringStruct *)0x0) goto LAB_0025d868;
    }
    _objc_msgSend(self_00,pcVar8,pcVar6,pvVar1);
    pcVar9 = pcVar6;
    pvVar7 = pvVar1;
  }
LAB_0025d868:
  pvVar7 = _objc_msgSend(pvVar2,sel_actor,pcVar9,pvVar7);
  pcVar9 = &cfstr_HSPlaySoundAction;
  pvVar1 = pvVar3;
  pvVar7 = _objc_msgSend(pvVar7,sel_hyperActionsOfType_forEvent_,&cfstr_HSPlaySoundAction,pvVar3);
  pvVar2 = _objc_msgSend(pvVar7,sel_count);
  if (pvVar2 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar7,sel_extraFirstObject,pcVar9,pvVar1);
    puVar10 = &DAT_003860f4;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_003860f4);
    pvVar7 = _objc_msgSend(pvVar1,sel_stopsAllSounds);
    if ((char)pvVar7 == '\0') {
      pvVar1 = _objc_msgSend(pvVar1,sel_sounds,puVar10);
      pvVar7 = _objc_msgSend(pvVar1,sel_count);
      if (pvVar7 == (id)0x0) {
        return self_00;
      }
      pvVar1 = _objc_msgSend(self,sel_soundsWithPropertiesFromSoundItems_runOn_,pvVar1,pvVar3);
      pcVar8 = sel_addObjectsFromArray_;
    }
    else {
      pvVar3 = *(id *)PTR_PTR_00336934;
      pvVar1 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObject_forKey_,
                             *(undefined4 *)PTR_003361d0,pvVar3);
      pcVar8 = sel_addObject_;
      if (pvVar1 == (id)0x0) {
        return self_00;
      }
    }
    _objc_msgSend(self_00,pcVar8,pvVar1,pvVar3);
  }
  return self_00;
}

*/
- (id)soundsWithPropertiesOnCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    NSMutableArray *sounds = [NSMutableArray array];
    id card = [[[self previewDocument] stack] hyperChildAtIndex:aIndex];
    id arrive = [HSActionEvent actionEventOfType:kHSArriveActionEventType];
    id leave = [HSActionEvent actionEventOfType:kHSLeaveActionEventType];
    NSArray *actions;
    actions = [[card actor] hyperActionsOfType:@"HSPlaySoundAction" forEvent:arrive];
    if ([actions count] != 0) {
        id attributes = [[actions extraFirstObject] queryHyperInterface:@protocol(HSPlaySoundActionAttributes)];
        if ([attributes stopsAllSounds]) {
            // A bare marker telling the exporter to stop every sound.
            [sounds addObject:[NSDictionary dictionaryWithObject:(id)kCFBooleanTrue forKey:HSQTMovieExporterMediaRunOnStartKey]];
        } else if ([[attributes sounds] count] != 0) {
            [sounds addObjectsFromArray:[self soundsWithPropertiesFromSoundItems:[attributes sounds] runOn:arrive]];
        }
    }
    actions = [[card actor] hyperActionsOfType:@"HSPlaySoundAction" forEvent:leave];
    if ([actions count] != 0) {
        id attributes = [[actions extraFirstObject] queryHyperInterface:@protocol(HSPlaySoundActionAttributes)];
        if ([attributes stopsAllSounds]) {
            // A bare marker telling the exporter to stop every sound.
            [sounds addObject:[NSDictionary dictionaryWithObject:(id)kCFBooleanFalse forKey:HSQTMovieExporterMediaRunOnStartKey]];
        } else if ([[attributes sounds] count] != 0) {
            [sounds addObjectsFromArray:[self soundsWithPropertiesFromSoundItems:[attributes sounds] runOn:leave]];
        }
    }
    return sounds;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025d107 @ 0025d107, 1388 bytes * /

id FUN_0025d107(HSExportManager *self,SEL _cmd,uint moviesWithPropertiesOnCardAtIndex,id forExporter
               )

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined *puVar8;
  undefined *puVar9;
  id self_01;
  id pvVar10;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar3 = _objc_msgSend(self,sel_previewDocument);
  pvVar3 = _objc_msgSend(pvVar3,sel_stack);
  pvVar4 = _objc_msgSend(pvVar3,sel_hyperChildAtIndex_,moviesWithPropertiesOnCardAtIndex);
  pvVar5 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336080);
  pvVar6 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,*(undefined4 *)PTR_00336500);
  pvVar7 = _objc_msgSend(pvVar4,sel_actor);
  pvVar3 = pvVar5;
  puVar8 = _objc_msgSend(pvVar7,sel_hyperActionsOfType_forEvent_,&cfstr_HSPlayMovieAction,pvVar5);
  _objc_msgSend(pvVar1,sel_addObjectsFromArray_,puVar8);
  pvVar7 = _objc_msgSend(pvVar1,sel_count);
  if (pvVar7 != (id)0x0) {
    pvVar1 = _objc_msgSend(pvVar1,sel_lastObject,puVar8,pvVar3);
    puVar8 = &DAT_00386018;
    puVar9 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_00386018);
    if (puVar9 != (undefined *)0x0) {
      pvVar3 = pvVar4;
      pvVar1 = _objc_msgSend(self,sel_movieObjectsFromPlayMovieActionAttributes_onCard_,puVar9,
                             pvVar4);
      pvVar7 = _objc_msgSend(pvVar1,sel_count);
      puVar8 = puVar9;
      if (pvVar7 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_NSArray,sel_alloc,puVar9,pvVar3);
        pvVar7 = pvVar1;
        pvVar3 = _objc_msgSend(pvVar3,sel_initWithArray_copyItems_,pvVar1,0);
        self->_movieObjectsRunOnArrive = pvVar3;
        pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_new);
        self->_movieObjectsRunOnArriveTemporaryState = pvVar3;
        self_01 = _objc_msgSend(self->_movieObjectsRunOnArrive,sel_objectEnumerator);
        pvVar3 = _objc_msgSend(self_01,sel_nextObject);
        while (pvVar3 != (id)0x0) {
          pvVar10 = _objc_msgSend(pvVar3,sel_isTemporary,pvVar7);
          pvVar7 = self->_movieObjectsRunOnArriveTemporaryState;
          pvVar10 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)pvVar10 & 0xff);
          _objc_msgSend(pvVar7,sel_addObject_,pvVar10);
          pvVar7 = (id)0x0;
          _objc_msgSend(pvVar3,sel_setTemporary_);
          pvVar3 = _objc_msgSend(self_01,sel_nextObject);
        }
        puVar8 = _objc_msgSend(self,sel_movieWithPropertiesFromMovieObjects_runOn_,pvVar1,pvVar5);
        _objc_msgSend(self_00,sel_addObjectsFromArray_,puVar8);
        pvVar3 = pvVar5;
      }
    }
  }
  pvVar1 = _objc_msgSend(pvVar4,sel_actor,puVar8,pvVar3);
  pvVar3 = pvVar6;
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperActionsOfType_forEvent_,&cfstr_HSPlayMovieAction,pvVar6);
  _objc_msgSend(pvVar2,sel_addObjectsFromArray_,pvVar1);
  pvVar5 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar5 != (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar2,sel_lastObject,pvVar1,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_00386018);
    if (pvVar3 != (id)0x0) {
      pvVar1 = _objc_msgSend(self,sel_movieObjectsFromPlayMovieActionAttributes_onCard_,pvVar3,
                             pvVar4);
      pvVar2 = _objc_msgSend(pvVar1,sel_count);
      if (pvVar2 != (id)0x0) {
        pvVar3 = _objc_msgSend(cls_NSArray,sel_alloc,pvVar3,pvVar4);
        pvVar2 = pvVar1;
        pvVar3 = _objc_msgSend(pvVar3,sel_initWithArray_copyItems_,pvVar1,0);
        self->_movieObjectsRunOnLeave = pvVar3;
        pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_new);
        self->_movieObjectsRunOnLeaveTemporaryState = pvVar3;
        pvVar4 = _objc_msgSend(self->_movieObjectsRunOnLeave,sel_objectEnumerator);
        pvVar3 = _objc_msgSend(pvVar4,sel_nextObject);
        while (pvVar3 != (id)0x0) {
          pvVar5 = _objc_msgSend(pvVar3,sel_isTemporary,pvVar2);
          pvVar2 = self->_movieObjectsRunOnLeaveTemporaryState;
          pvVar5 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,(uint)pvVar5 & 0xff);
          _objc_msgSend(pvVar2,sel_addObject_,pvVar5);
          pvVar2 = (id)0x0;
          _objc_msgSend(pvVar3,sel_setTemporary_);
          pvVar3 = _objc_msgSend(pvVar4,sel_nextObject);
        }
        pvVar3 = _objc_msgSend(self,sel_movieWithPropertiesFromMovieObjects_runOn_,pvVar1,pvVar6);
        _objc_msgSend(self_00,sel_addObjectsFromArray_,pvVar3);
      }
    }
  }
  return self_00;
}

*/
- (id)moviesWithPropertiesOnCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    NSMutableArray *movies = [NSMutableArray array];
    NSMutableArray *arriveActions = [NSMutableArray array];
    NSMutableArray *leaveActions = [NSMutableArray array];
    id card = [[[self previewDocument] stack] hyperChildAtIndex:aIndex];
    id arrive = [HSActionEvent actionEventOfType:kHSArriveActionEventType];
    id leave = [HSActionEvent actionEventOfType:kHSLeaveActionEventType];
    [arriveActions addObjectsFromArray:[[card actor] hyperActionsOfType:@"HSPlayMovieAction" forEvent:arrive]];
    if ([arriveActions count] != 0) {
        id attributes = [[arriveActions lastObject] queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
        if (attributes != nil) {
            NSArray *objects = [self movieObjectsFromPlayMovieActionAttributes:attributes onCard:card];
            if ([objects count] != 0) {
                _movieObjectsRunOnArrive = [[NSArray alloc] initWithArray:objects copyItems:NO];
                _movieObjectsRunOnArriveTemporaryState = [NSMutableArray new];
                // Remember which movies were temporary, then keep them for the whole export.
                for (id object in _movieObjectsRunOnArrive) {
                    [(NSMutableArray *)_movieObjectsRunOnArriveTemporaryState addObject:[NSNumber numberWithBool:[object isTemporary]]];
                    [object setTemporary:NO];
                }
                [movies addObjectsFromArray:[self movieWithPropertiesFromMovieObjects:objects runOn:arrive]];
            }
        }
    }
    [leaveActions addObjectsFromArray:[[card actor] hyperActionsOfType:@"HSPlayMovieAction" forEvent:leave]];
    if ([leaveActions count] != 0) {
        id attributes = [[leaveActions lastObject] queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
        if (attributes != nil) {
            NSArray *objects = [self movieObjectsFromPlayMovieActionAttributes:attributes onCard:card];
            if ([objects count] != 0) {
                _movieObjectsRunOnLeave = [[NSArray alloc] initWithArray:objects copyItems:NO];
                _movieObjectsRunOnLeaveTemporaryState = [NSMutableArray new];
                // Remember which movies were temporary, then keep them for the whole export.
                for (id object in _movieObjectsRunOnLeave) {
                    [(NSMutableArray *)_movieObjectsRunOnLeaveTemporaryState addObject:[NSNumber numberWithBool:[object isTemporary]]];
                    [object setTemporary:NO];
                }
                [movies addObjectsFromArray:[self movieWithPropertiesFromMovieObjects:objects runOn:leave]];
            }
        }
    }
    return movies;
}

- (double)timeDelayOnArriveOnCardAtIndex:(NSUInteger)aIndex
{
    id pvVar2;
    id pvVar1_3;

    pvVar1_3 = [[[self previewDocument] stack] hyperChildAtIndex:aIndex];
    pvVar2 = [HSActionEvent actionEventOfType:kHSArriveActionEventType];
    return [[[pvVar1_3 actor] automaticTimerForActionEvent:pvVar2] delayBeforeRunActionsAutomatically];
}

- (id)artworkImageForExporter:(id)aExporter
{
    return [[[[_document stack] hyperChildren] extraFirstObject] image];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025cf2c @ 0025cf2c, 378 bytes * /

id FUN_0025cf2c(HSExportManager *self,SEL _cmd,id movieObjectsFromPlayMovieActionAttributes,
               id onCard)

{
  id self_00;
  id pvVar1;
  id self_01;
  id self_02;
  id pvVar2;
  id pvVar3;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  if (movieObjectsFromPlayMovieActionAttributes != (id)0x0) {
    pvVar1 = _objc_msgSend(movieObjectsFromPlayMovieActionAttributes,sel_movies);
    self_01 = _objc_msgSend(pvVar1,sel_objectEnumerator);
    for (pvVar1 = _objc_msgSend(self_01,sel_nextObject); pvVar1 != (id)0x0;
        pvVar1 = _objc_msgSend(self_01,sel_nextObject,pvVar1)) {
      self_02 = _objc_msgSend(pvVar1,sel_movieObjectForCard_,onCard);
      pvVar2 = _objc_msgSend(self_02,sel_hyperParent);
      if (pvVar2 == (id)0x0) {
        _objc_msgSend(onCard,sel_addTemporaryHyperChild_,self_02);
      }
      pvVar2 = self_02;
      _objc_msgSend(pvVar1,sel_applyAttributesToMovieObject_,self_02);
      pvVar3 = _objc_msgSend(self_02,sel_isTemporary);
      if ((char)pvVar3 != '\0') {
        pvVar2 = (id)0x1;
        _objc_msgSend(self_02,sel_setHidden_,1);
      }
      pvVar1 = _objc_msgSend(pvVar1,sel_eraseWhenDone,pvVar2);
      pvVar1 = (id)(int)(char)pvVar1;
      _objc_msgSend(self_02,sel_setHyperEraseWhenDone_,pvVar1);
      if (self_02 != (id)0x0) {
        _objc_msgSend(self_00,sel_addObject_,self_02);
        pvVar1 = self_02;
      }
    }
  }
  return self_00;
}

*/
- (id)movieObjectsFromPlayMovieActionAttributes:(id)aAttributes onCard:(id)aCard
{
    NSMutableArray *objects = [NSMutableArray array];
    if (aAttributes == nil) {
        return objects;
    }
    for (id movie in [aAttributes movies]) {
        id object = [movie movieObjectForCard:aCard];
        if ([object hyperParent] == nil) {
            [aCard addTemporaryHyperChild:object];
        }
        [movie applyAttributesToMovieObject:object];
        if ([object isTemporary]) {
            [object setHidden:YES];
        }
        [object setHyperEraseWhenDone:[movie eraseWhenDone]];
        if (object != nil) {
            [objects addObject:object];
        }
    }
    return objects;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025e3f2 @ 0025e3f2, 861 bytes * /

id FUN_0025e3f2(HSExportManager *self,SEL _cmd,id soundsWithPropertiesFromSoundItems,id runOn)

{
  float fVar1;
  id pvVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  undefined *puVar7;
  float *pfVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  float fVar13;
  id pvVar14;
  float *pfVar15;
  double dVar16;
  float afStack_74 [2];
  double local_24;
  double local_1c;
  
  pvVar9 = _objc_msgSend(cls_NSMutableArray,sel_array);
  fVar1 = *(float *)PTR_PTR_00336928;
  pvVar2 = *(id *)PTR_00336080;
  fVar3 = *(float *)PTR_PTR_00336934;
  fVar4 = *(float *)PTR_PTR_00336938;
  fVar5 = *(float *)PTR_PTR_00336930;
  fVar6 = *(float *)PTR_PTR_0033692c;
  pvVar10 = _objc_msgSend(soundsWithPropertiesFromSoundItems,sel_objectEnumerator);
  pfVar8 = (float *)&stack0xffffff94;
  while( true ) {
    do {
      do {
        do {
          do {
            pfVar15 = pfVar8;
            pfVar15[1] = (float)sel_nextObject;
            *pfVar15 = (float)pvVar10;
            pfVar15[-1] = 3.480865e-39;
            pvVar14 = _objc_msgSend((id)*pfVar15,(SEL)pfVar15[1]);
            if (pvVar14 == (id)0x0) {
              return pvVar9;
            }
            pfVar15[2] = (float)&DAT_003861f8;
            pfVar15[1] = (float)sel_queryHyperInterface_;
            *pfVar15 = (float)pvVar14;
            pfVar15[-1] = 3.479916e-39;
            pvVar14 = _objc_msgSend((id)*pfVar15,(SEL)pfVar15[1]);
            pfVar8 = pfVar15;
          } while (pvVar14 == (id)0x0);
          pfVar15[2] = (float)sel_soundPlayRange;
          pfVar15[1] = (float)pvVar14;
          *pfVar15 = (float)&local_24;
          pfVar15[-1] = 3.47997e-39;
          _objc_msgSend_stret((void *)*pfVar15,(id)pfVar15[1],(SEL)pfVar15[2]);
          pfVar8 = pfVar15 + -1;
        } while (local_1c <= 0.001);
        *pfVar15 = (float)sel_volume;
        pfVar15[-1] = (float)pvVar14;
        pfVar15[-2] = 3.480031e-39;
        dVar16 = _objc_msgSend_fpret((id)pfVar15[-1],(SEL)*pfVar15);
        puVar7 = cls_QTMovie;
        pfVar8 = pfVar15 + -1;
      } while (dVar16 <= 0.001);
      *pfVar15 = (float)sel_sharedMediaAccessor;
      pfVar15[-1] = (float)cls_HSNewMediaAccessor;
      pfVar15[-2] = 3.480122e-39;
      pvVar11 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
      *pfVar15 = (float)sel_mediaUID;
      pfVar15[-1] = (float)pvVar14;
      pfVar15[-2] = 3.480154e-39;
      pvVar12 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
      pfVar15[1] = (float)pvVar12;
      *pfVar15 = (float)sel_mediaForUID_;
      pfVar15[-1] = (float)pvVar11;
      pfVar15[-2] = 3.480185e-39;
      pvVar11 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
      *pfVar15 = (float)sel_fullPathToMediaFileCreateIfNeeded_;
      pfVar15[-1] = (float)pvVar11;
      pfVar15[1] = 1.4013e-45;
      pfVar15[-2] = 3.480221e-39;
      pvVar11 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
      pfVar15[1] = (float)pvVar11;
      *pfVar15 = (float)sel_movieWithFile_error_;
      pfVar15[-1] = (float)puVar7;
      pfVar15[2] = 0.0;
      pfVar15[-2] = 3.480263e-39;
      pvVar11 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
      pfVar8 = pfVar15 + -1;
    } while (pvVar11 == (id)0x0);
    *pfVar15 = (float)sel_new;
    pfVar15[-1] = (float)cls_NSMutableDictionary;
    pfVar15[-2] = 3.480311e-39;
    pvVar12 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    if (pvVar12 == (id)0x0) break;
    pfVar15[2] = fVar6;
    pfVar15[1] = (float)pvVar11;
    *pfVar15 = (float)sel_setObject_forKey_;
    pfVar15[-1] = (float)pvVar12;
    pfVar15[-2] = 3.480366e-39;
    _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    *pfVar15 = (float)local_1c;
    pfVar15[-1] = (float)local_24;
    pfVar15[-2] = 3.480402e-39;
    fVar13 = (float)_NSStringFromSize();
    pfVar15[2] = fVar5;
    pfVar15[1] = fVar13;
    *pfVar15 = (float)sel_setObject_forKey_;
    pfVar15[-1] = (float)pvVar12;
    pfVar15[-2] = 3.480443e-39;
    _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    pfVar15[1] = (float)dVar16;
    *pfVar15 = (float)sel_numberWithFloat_;
    pfVar15[-1] = (float)cls_NSNumber;
    pfVar15[-2] = 3.480492e-39;
    pvVar11 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    pfVar15[2] = fVar4;
    pfVar15[1] = (float)pvVar11;
    *pfVar15 = (float)sel_setObject_forKey_;
    pfVar15[-1] = (float)pvVar12;
    pfVar15[-2] = 3.480533e-39;
    _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    puVar7 = cls_NSNumber;
    *pfVar15 = (float)sel_eventType;
    pfVar15[-1] = (float)runOn;
    pfVar15[-2] = 3.48057e-39;
    pvVar11 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    pfVar15[1] = (float)(uint)(pvVar11 == pvVar2);
    *pfVar15 = (float)sel_numberWithBool_;
    pfVar15[-1] = (float)puVar7;
    pfVar15[-2] = 3.480614e-39;
    pvVar11 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    pfVar15[2] = fVar3;
    pfVar15[1] = (float)pvVar11;
    *pfVar15 = (float)sel_setObject_forKey_;
    pfVar15[-1] = (float)pvVar12;
    pfVar15[-2] = 3.480654e-39;
    _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    puVar7 = cls_NSNumber;
    *pfVar15 = (float)sel_isSynchronousSound;
    pfVar15[-1] = (float)pvVar14;
    pfVar15[-2] = 3.480692e-39;
    pvVar14 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    pfVar15[1] = (float)(uint)((char)pvVar14 == '\0');
    *pfVar15 = (float)sel_numberWithBool_;
    pfVar15[-1] = (float)puVar7;
    pfVar15[-2] = 3.480734e-39;
    pvVar14 = _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    pfVar15[2] = fVar1;
    pfVar15[1] = (float)pvVar14;
    *pfVar15 = (float)sel_setObject_forKey_;
    pfVar15[-1] = (float)pvVar12;
    pfVar15[-2] = 3.480775e-39;
    _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    pfVar15[1] = (float)pvVar12;
    *pfVar15 = (float)sel_addObject_;
    pfVar15[-1] = (float)pvVar9;
    pfVar15[-2] = 3.48081e-39;
    _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    *pfVar15 = (float)sel_release;
    pfVar15[-1] = (float)pvVar12;
    pfVar15[-2] = 3.480835e-39;
    _objc_msgSend((id)pfVar15[-1],(SEL)*pfVar15);
    pfVar8 = pfVar15 + -1;
  }
  return pvVar9;
}

*/
- (id)soundsWithPropertiesFromSoundItems:(id)aItems runOn:(id)aOn
{
    NSMutableArray *sounds = [NSMutableArray array];
    for (id item in aItems) {
        id playback = [item queryHyperInterface:@protocol(HSSoundPlaybackAttributes)];
        if (playback == nil) {
            continue;
        }
        struct HSTimeRange range = [playback soundPlayRange];
        if (range.length <= 0.001) {
            continue;
        }
        double volume = [(id<HSSoundPlaybackAttributes>)playback volume];
        if (volume <= 0.001) {
            continue;
        }
        NSString *path = [[[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:[playback mediaUID]] fullPathToMediaFileCreateIfNeeded:YES];
        QTMovie *movie = [QTMovie movieWithFile:path error:NULL];
        if (movie == nil) {
            continue;
        }
        NSMutableDictionary *sound = [NSMutableDictionary new];
        if (sound == nil) {
            break;
        }
        [sound setObject:movie forKey:HSQTMovieExporterMediaKey];
        // The play range travels as a size string: {location, length}.
        [sound setObject:NSStringFromSize(NSMakeSize(range.location, range.length)) forKey:HSQTMovieExporterMediaPlayRangeKey];
        [sound setObject:[NSNumber numberWithFloat:volume] forKey:HSQTMovieExporterMediaVolumeKey];
        [sound setObject:[NSNumber numberWithBool:[aOn eventType] == kHSArriveActionEventType] forKey:HSQTMovieExporterMediaRunOnStartKey];
        [sound setObject:[NSNumber numberWithBool:![playback isSynchronousSound]] forKey:HSQTMovieExporterMediaAsynchronyKey];
        [sounds addObject:sound];
        [sound release];
    }
    return sounds;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025ce0b @ 0025ce0b, 289 bytes * /

id FUN_0025ce0b(HSExportManager *self,SEL _cmd,id movieWithPropertiesFromMovieObjects,id runOn)

{
  id self_00;
  id self_01;
  id pvVar1;
  id pvVar2;
  undefined *puVar3;
  
  _objc_msgSend(movieWithPropertiesFromMovieObjects,sel_retain);
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  self_01 = _objc_msgSend(movieWithPropertiesFromMovieObjects,sel_objectEnumerator);
  while( true ) {
    pvVar2 = _objc_msgSend(self_01,sel_nextObject);
    if (pvVar2 == (id)0x0) break;
    puVar3 = &DAT_00385d98;
    pvVar2 = _objc_msgSend(pvVar2,sel_queryHyperInterface_,&DAT_00385d98);
    if (pvVar2 == (id)0x0) break;
    pvVar1 = _objc_msgSend(pvVar2,sel_isHyperQTVR,puVar3);
    if ((char)pvVar1 == '\0') {
      pvVar1 = _objc_msgSend(pvVar2,sel_isHyperPanoramaObject,puVar3);
      if ((char)pvVar1 == '\0') {
        pvVar1 = runOn;
        pvVar2 = _objc_msgSend(self,sel_mediaWithPropertiesFromMovieObject_runOn_,pvVar2,runOn);
        if (pvVar2 != (id)0x0) {
          _objc_msgSend(self_00,sel_addObject_,pvVar2,pvVar1);
        }
      }
    }
  }
  _objc_msgSend(movieWithPropertiesFromMovieObjects,sel_release);
  return self_00;
}

*/
- (id)movieWithPropertiesFromMovieObjects:(id)aObjects runOn:(id)aOn
{
    [aObjects retain];
    NSMutableArray *movies = [NSMutableArray array];
    for (id object in aObjects) {
        id attributes = [object queryHyperInterface:@protocol(HSMovieObjectAttributes)];
        // The original stops at the first object that is not a movie.
        if (attributes == nil) {
            break;
        }
        if ([attributes isHyperQTVR] || [attributes isHyperPanoramaObject]) {
            continue;
        }
        NSDictionary *media = [self mediaWithPropertiesFromMovieObject:attributes runOn:aOn];
        if (media != nil) {
            [movies addObject:media];
        }
    }
    [aObjects release];
    return movies;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025e74f @ 0025e74f, 626 bytes * /

id FUN_0025e74f(HSExportManager *self,SEL _cmd,id mediaWithPropertiesFromMovieObject,id runOn)

{
  undefined *puVar1;
  undefined *self_00;
  short sVar2;
  id self_01;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  double dVar7;
  double local_24;
  double local_1c;
  
  _objc_msgSend_stret(&local_24,mediaWithPropertiesFromMovieObject,sel_hyperPlayRange);
  if (local_1c <= 0.001) {
    self_01 = (id)0x0;
  }
  else {
    self_01 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary);
    puVar1 = cls_QTMovie;
    pvVar3 = _objc_msgSend(mediaWithPropertiesFromMovieObject,sel_media);
    pvVar3 = _objc_msgSend(pvVar3,sel_fullPathToMediaFileCreateIfNeeded_,1);
    pvVar3 = _objc_msgSend(puVar1,sel_movieWithFile_error_,pvVar3,0);
    pvVar4 = _objc_msgSend(pvVar3,sel_quickTimeMovie);
    _SetMovieVisualContext(pvVar4,0);
    sVar2 = _GetMoviesError();
    puVar1 = cls_NSException;
    if (sVar2 != 0) {
      uVar5 = _sel_getName(_cmd);
      uVar6 = _object_getClassName(self);
      _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar2,&cfstr_OSStatusError,
                    &cfstr_error__d_in___s__p___s_,(int)sVar2,uVar6,self,uVar5);
    }
    _objc_msgSend(self_01,sel_setObject_forKey_,pvVar3,*(undefined4 *)PTR_PTR_0033692c);
    uVar5 = _NSStringFromSize((float)local_24,(float)local_1c);
    _objc_msgSend(self_01,sel_setObject_forKey_,uVar5,*(undefined4 *)PTR_PTR_00336930);
    puVar1 = cls_NSNumber;
    dVar7 = _objc_msgSend_fpret(mediaWithPropertiesFromMovieObject,sel_hyperVolume);
    pvVar3 = _objc_msgSend(puVar1,sel_numberWithFloat_,(float)dVar7);
    _objc_msgSend(self_01,sel_setObject_forKey_,pvVar3,*(undefined4 *)PTR_PTR_00336938);
    self_00 = cls_NSNumber;
    puVar1 = PTR_00336080;
    pvVar3 = _objc_msgSend(runOn,sel_eventType);
    pvVar3 = _objc_msgSend(self_00,sel_numberWithBool_,(uint)(pvVar3 == *(id *)puVar1));
    _objc_msgSend(self_01,sel_setObject_forKey_,pvVar3,*(undefined4 *)PTR_PTR_00336934);
  }
  return self_01;
}

*/
- (id)mediaWithPropertiesFromMovieObject:(id)aObject runOn:(id)aOn
{
    struct HSTimeRange range = [aObject hyperPlayRange];
    if (range.length <= 0.001) {
        return nil;
    }
    NSMutableDictionary *media = [NSMutableDictionary dictionary];
    QTMovie *movie = [QTMovie movieWithFile:[[aObject media] fullPathToMediaFileCreateIfNeeded:YES] error:NULL];
    OSStatus error = SetMovieVisualContext([movie quickTimeMovie], NULL);
    if (error != noErr) {
        [NSException extraRaiseError:error name:@"OSStatusError" format:@"error %d in %s(%p) %s", (int)error, object_getClassName(self), self, sel_getName(_cmd)];
    }
    [media setObject:movie forKey:HSQTMovieExporterMediaKey];
    [media setObject:NSStringFromSize(NSMakeSize(range.location, range.length)) forKey:HSQTMovieExporterMediaPlayRangeKey];
    [media setObject:[NSNumber numberWithFloat:[aObject hyperVolume]] forKey:HSQTMovieExporterMediaVolumeKey];
    [media setObject:[NSNumber numberWithBool:[aOn eventType] == kHSArriveActionEventType] forKey:HSQTMovieExporterMediaRunOnStartKey];
    return media;
}

- (BOOL)canExportDocumentAsVideoWithNarration
{
    BOOL bVar2;

    if (![[_document stack] isStackProtected]) {
        bVar2 = ![_document isInStoryboardMode];
    }
    else {
        bVar2 = NO;
    }
    return bVar2;
}

- (NSSize)videoFrameSize
{
    return [[_document stack] hyperCardSize];
}

- (BOOL)isExportDocumentInStoryboardMode
{
    return (BOOL)[_document isInStoryboardMode];
}

- (NSUInteger)countExistedCards
{
    return (unsigned int)[[_document stack] hyperCount];
}

- (id)imageForCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    return [[[[self previewDocument] stack] hyperChildAtIndex:aIndex] imageForExport];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025cb3a @ 0025cb3a, 354 bytes * /

id FUN_0025cb3a(HSExportManager *self,SEL _cmd,id exportedCardIndexesForExporter,BOOL onlySelected)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined *self_01;
  SEL op;
  
  self_00 = _objc_msgSend(cls_NSMutableIndexSet,sel_indexSet);
  pvVar1 = _objc_msgSend(self->_document,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperChildren);
  if (onlySelected != '\0') {
    pvVar2 = _objc_msgSend(self->_document,sel_currentWindowController);
    pvVar1 = self->_document;
    pvVar3 = _objc_msgSend(self,sel_storyboardControllerForDocument_,pvVar1);
    self_01 = cls_NSArray;
    if (pvVar2 == pvVar3) {
      pvVar2 = _objc_msgSend(self->_document,sel_selectionController,pvVar1);
      self_01 = _objc_msgSend(pvVar2,sel_selectedHyperObject);
      op = sel_allHyperInterfaces;
    }
    else {
      pvVar1 = _objc_msgSend(self->_document,sel_currentCard,pvVar1);
      op = sel_arrayWithObject_;
    }
    pvVar1 = _objc_msgSend(self_01,op,pvVar1);
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  while( true ) {
    pvVar2 = _objc_msgSend(pvVar1,sel_nextObject);
    if (pvVar2 == (id)0x0) break;
    pvVar2 = _objc_msgSend(pvVar2,sel_hyperIndex);
    _objc_msgSend(self_00,sel_addIndex_,pvVar2);
  }
  return self_00;
}

*/
- (id)exportedCardIndexesForExporter:(id)aExporter onlySelected:(BOOL)aSelected
{
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSArray *cards = [[_document stack] hyperChildren];
    if (aSelected) {
        if ([_document currentWindowController] == [self storyboardControllerForDocument:_document]) {
            cards = [[[_document selectionController] selectedHyperObject] allHyperInterfaces];
        } else {
            cards = [NSArray arrayWithObject:[_document currentCard]];
        }
    }
    for (id card in cards) {
        [indexes addIndex:[card hyperIndex]];
    }
    return indexes;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025cad8 @ 0025cad8, 98 bytes * /

void FUN_0025cad8(HSExportManager *self,SEL _cmd,id cancelExport)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = _objc_msgSend(self,sel_isExporting);
  op = sel_stopExport;
  if (((char)pvVar1 != '\0') ||
     (pvVar1 = _objc_msgSend(self,sel_isPublishing), op = sel_stopPublish, (char)pvVar1 != '\0')) {
    _objc_msgSend(self,op);
  }
  return;
}

*/
- (void)cancelExport:(id)aExport
{
    if ([self isExporting]) {
        [self stopExport];
    } else if ([self isPublishing]) {
        [self stopPublish];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025b586 @ 0025b586, 11 bytes * /

id FUN_0025b586(HSExportManager *self,SEL _cmd,id embeddedCode)

{
  return *(id *)((int)&self->_isMovieExportHelperEnable + 1);
}

*/
- (id)embeddedCode:(id)aCode
{
    return _embeddedCode;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025caa7 @ 0025caa7, 49 bytes * /

void FUN_0025caa7(HSExportManager *self,SEL _cmd,id publishDidTerminate)

{
  self->_isExporting[0] = self->_isExporting[0] & 0xfd;
  _objc_msgSend(self,sel_publishDidEnd_,publishDidTerminate);
  return;
}

*/
- (void)publishDidTerminate:(id)aTerminate
{
    _isPublishing = NO;
    [self publishDidEnd:aTerminate];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025ca1d @ 0025ca1d, 138 bytes * /

void FUN_0025ca1d(HSExportManager *self,SEL _cmd,id publishDidEnd)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(self,sel_progressSheetController);
  _objc_msgSend(pvVar1,sel_endSheet);
  _objc_msgSend(self,sel_removeProgressSheetController);
  self->_isExporting[0] = self->_isExporting[0] & 0xfd;
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                &cfstr_HSExportManagerDidEndPublishNotification,self);
  return;
}

*/
- (void)publishDidEnd:(id)aEnd
{
    [[self progressSheetController] endSheet];
    [self removeProgressSheetController];
    _isPublishing = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerDidEndPublishNotification" object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025c9c9 @ 0025c9c9, 84 bytes * /

void FUN_0025c9c9(HSExportManager *self,SEL _cmd,id publishDidStart)

{
  id self_00;
  
  self->_isExporting[0] = self->_isExporting[0] | 2;
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(self_00,sel_postNotificationName_object_,
                &cfstr_HSExportManagerDidStartPublishNotification,self);
  return;
}

*/
- (void)publishDidStart:(id)aStart
{
    _isPublishing = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerDidStartPublishNotification" object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025c899 @ 0025c899, 304 bytes * /

void FUN_0025c899(HSExportManager *self,SEL _cmd,id publishWillStart)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(self,sel_progressSheetController);
  _objc_msgSend(pvVar1,sel_setProgress_,0,0);
  pvVar1 = _objc_msgSend(self,sel_progressSheetController);
  pvVar2 = _objc_msgSend(publishWillStart,sel_progressSheetDescription);
  _objc_msgSend(pvVar1,sel_setDescription_,pvVar2);
  pvVar1 = _objc_msgSend(self,sel_progressSheetController);
  _objc_msgSend(pvVar1,sel_setProgressIndicatorIndeterminate_,0);
  pvVar1 = _objc_msgSend(self,sel_progressSheetController);
  pvVar2 = _objc_msgSend(self->_document,sel_windowForSheet);
  _objc_msgSend(pvVar1,sel_beginSheetForWindow_,pvVar2);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                &cfstr_HSExportManagerWillStartPublishNotification,self);
  return;
}

*/
- (void)publishWillStart:(id)aStart
{
    [[self progressSheetController] setProgress:0.0];
    [[self progressSheetController] setDescription:[aStart progressSheetDescription]];
    [[self progressSheetController] setProgressIndicatorIndeterminate:NO];
    [[self progressSheetController] beginSheetForWindow:[_document windowForSheet]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerWillStartPublishNotification" object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025e9c1 @ 0025e9c1, 588 bytes * /

void FUN_0025e9c1(HSExportManager *self,SEL _cmd,id publishAlertInProgress,id invokeOptions)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  HSExportManager *pHVar6;
  undefined *puVar7;
  SEL op;
  HSExportManager *pHVar8;
  id local_14;
  
  pvVar1 = _objc_msgSend(self,sel_progressSheetController);
  _objc_msgSend(pvVar1,sel_endSheet);
  local_14 = _objc_msgSend(invokeOptions,sel_objectForKey_,&cfstr_HSExportAlertKey);
  if (local_14 == (id)0x0) {
    pvVar1 = _objc_msgSend(invokeOptions,sel_objectForKey_,&cfstr_HSExportCustomAlertKey);
  }
  else {
    pvVar1 = (id)0x0;
  }
  pvVar2 = _objc_msgSend(invokeOptions,sel_objectForKey_,&cfstr_HSExportAlertTargetKey);
  pvVar3 = _objc_msgSend(invokeOptions,sel_objectForKey_,&cfstr_HSExportAlertDidEndSelectorKey);
  pvVar4 = (id)_NSSelectorFromString(pvVar3);
  pvVar3 = pvVar4;
  pvVar5 = _objc_msgSend(pvVar2,sel_methodSignatureForSelector_,pvVar4);
  if ((pvVar2 != (id)0x0) && (pvVar5 != (id)0x0)) {
    pvVar3 = _objc_msgSend(cls_NSInvocation,sel_invocationWithMethodSignature_,pvVar5);
    _objc_msgSend(pvVar3,sel_setTarget_,pvVar2);
    _objc_msgSend(pvVar3,sel_setSelector_,pvVar4);
    pvVar4 = _objc_msgSend(self,sel_alertToDidEndInvocationMapTable);
    pvVar2 = pvVar1;
    if (local_14 != (id)0x0) {
      pvVar2 = local_14;
    }
    _NSMapInsert(pvVar4,pvVar2,pvVar3);
  }
  if (local_14 == (id)0x0) {
    local_14 = *(id *)PTR_00336058;
    _objc_msgSend(invokeOptions,sel_retain,pvVar3);
    puVar7 = sel_alertDidEnd_returnCode_contextInfo_;
    pHVar6 = _objc_msgSend(self->_document,sel_windowForSheet);
    op = sel_beginSheet_modalForWindow_modalDelegate_didEndSelector_contextInfo_;
    pHVar8 = self;
  }
  else {
    puVar7 = _objc_msgSend(invokeOptions,sel_retain,pvVar3);
    pHVar8 = (HSExportManager *)sel_alertDidEnd_returnCode_contextInfo_;
    pvVar1 = _objc_msgSend(self->_document,sel_windowForSheet);
    op = sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_;
    pHVar6 = self;
  }
  _objc_msgSend(local_14,op,pvVar1,pHVar6,pHVar8,puVar7);
  return;
}

*/
- (void)publishAlertInProgress:(id)aProgress invokeOptions:(id)aOptions
{
    [[self progressSheetController] endSheet];
    // Either a ready-made alert or a custom sheet window.
    id alert = [aOptions objectForKey:@"HSExportAlertKey"];
    id customSheet = alert == nil ? [aOptions objectForKey:@"HSExportCustomAlertKey"] : nil;
    id target = [aOptions objectForKey:@"HSExportAlertTargetKey"];
    SEL didEndSelector = NSSelectorFromString([aOptions objectForKey:@"HSExportAlertDidEndSelectorKey"]);
    NSMethodSignature *signature = [target methodSignatureForSelector:didEndSelector];
    if (target != nil && signature != nil) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:target];
        [invocation setSelector:didEndSelector];
        NSMapInsert([self alertToDidEndInvocationMapTable], alert != nil ? alert : customSheet, invocation);
    }
    // The options travel as the context info and are released in -alertDidEnd:returnCode:contextInfo:.
    [aOptions retain];
    if (alert == nil) {
        [NSApp beginSheet:customSheet modalForWindow:[_document windowForSheet] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:aOptions];
    } else {
        [alert beginSheetModalForWindow:[_document windowForSheet] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:aOptions];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025c7d3 @ 0025c7d3, 198 bytes * /

void FUN_0025c7d3(HSExportManager *self,SEL _cmd,id publishErrorInProgress,id error)

{
  id pvVar1;
  id pvVar2;
  
  self->_isExporting[0] = self->_isExporting[0] | 4;
  pvVar1 = _objc_msgSend(error,sel_retain);
  self->_exportSessionError = pvVar1;
  pvVar1 = _objc_msgSend(self,sel_progressSheetController);
  pvVar2 = _objc_msgSend(self->_document,sel_windowForSheet);
  _objc_msgSend(pvVar1,sel_endSheetWithErrorSheet_modalForWindow_,error,pvVar2);
  _objc_msgSend(self,sel_removeProgressSheetController);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,&cfstr_HSExportManagerDidFailNotification,
                self);
  return;
}

*/
- (void)publishErrorInProgress:(id)aProgress error:(id)aError
{
    _hasSessionError = YES;
    // The original overwrites any previous error without releasing it.
    _exportSessionError = [aError retain];
    [[self progressSheetController] endSheetWithErrorSheet:aError modalForWindow:[_document windowForSheet]];
    [self removeProgressSheetController];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerDidFailNotification" object:self];
}

- (void)publishProgressDidChange:(id)aChange withProgress:(double)aProgress
{
    id pvVar1_3;

    [[self progressSheetController] incrementProgressBy:aProgress];
    pvVar1_3 = [NSDictionary dictionaryWithObjectsAndKeys:@"HSPublishProgressValueAttribute", [NSNumber numberWithDouble:aProgress], nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerDidChangePublishProgressNotification" object:self userInfo:pvVar1_3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025c6ca @ 0025c6ca, 49 bytes * /

void FUN_0025c6ca(HSExportManager *self,SEL _cmd,id exportDidTerminate)

{
  self->_isExporting[0] = self->_isExporting[0] & 0xfe;
  _objc_msgSend(self,sel_exportDidEnd_,exportDidTerminate);
  return;
}

*/
- (void)exportDidTerminate:(id)aTerminate
{
    _isExporting = NO;
    [self exportDidEnd:aTerminate];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025c335 @ 0025c335, 917 bytes * /

void FUN_0025c335(HSExportManager *self,SEL _cmd,id exportDidEnd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSExportManager *self_00;
  cfstringStruct *pcVar4;
  SEL op;
  undefined *puVar5;
  HSExportManager *pHVar6;
  
  if ((self->_isExporting[0] & 8) != 0) {
    pvVar1 = _objc_msgSend(self->_movieObjectsRunOnArrive,sel_count);
    pvVar2 = self->_movieObjectsRunOnArrive;
    if (pvVar1 != (id)0x0) {
      pvVar1 = (id)0x0;
      do {
        pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar1);
        pvVar3 = _objc_msgSend(self->_movieObjectsRunOnArriveTemporaryState,sel_objectAtIndex_,
                               pvVar1);
        pvVar3 = _objc_msgSend(pvVar3,sel_boolValue);
        _objc_msgSend(pvVar2,sel_setTemporary_,(int)(char)pvVar3);
        pvVar1 = (id)((int)pvVar1 + 1);
        pvVar3 = _objc_msgSend(self->_movieObjectsRunOnArrive,sel_count);
        pvVar2 = self->_movieObjectsRunOnArrive;
      } while (pvVar1 < pvVar3);
    }
    _objc_msgSend(pvVar2,sel_release);
    self->_movieObjectsRunOnArrive = (id)0x0;
    _objc_msgSend(self->_movieObjectsRunOnArriveTemporaryState,sel_release);
    self->_movieObjectsRunOnArriveTemporaryState = (id)0x0;
    pvVar1 = _objc_msgSend(self->_movieObjectsRunOnLeave,sel_count);
    pvVar2 = self->_movieObjectsRunOnLeave;
    if (pvVar1 != (id)0x0) {
      pvVar1 = (id)0x0;
      do {
        pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,pvVar1);
        pvVar3 = _objc_msgSend(self->_movieObjectsRunOnLeaveTemporaryState,sel_objectAtIndex_,pvVar1
                              );
        pvVar3 = _objc_msgSend(pvVar3,sel_boolValue);
        _objc_msgSend(pvVar2,sel_setTemporary_,(int)(char)pvVar3);
        pvVar1 = (id)((int)pvVar1 + 1);
        pvVar3 = _objc_msgSend(self->_movieObjectsRunOnLeave,sel_count);
        pvVar2 = self->_movieObjectsRunOnLeave;
      } while (pvVar1 < pvVar3);
    }
    _objc_msgSend(pvVar2,sel_release);
    self->_movieObjectsRunOnLeave = (id)0x0;
    _objc_msgSend(self->_movieObjectsRunOnLeaveTemporaryState,sel_release);
    self->_movieObjectsRunOnLeaveTemporaryState = (id)0x0;
    _objc_msgSend(self->_slideshowTransitionRenderer,sel_release);
    self->_slideshowTransitionRenderer = (id)0x0;
    _objc_msgSend(self->_slideshowAttributes,sel_release);
    self->_slideshowAttributes = (id)0x0;
    self->_isExporting[0] = self->_isExporting[0] & 0xf7;
  }
  pvVar2 = _objc_msgSend(self,sel_isExporting);
  self->_isExporting[0] = self->_isExporting[0] & 0xfe;
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  pcVar4 = &cfstr_HSExportManagerDidEndExportNotification;
  pHVar6 = self;
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                &cfstr_HSExportManagerDidEndExportNotification,self);
  if (((*(uint *)self->_isExporting & 4) == 0) && ((char)pvVar2 != '\0')) {
    self_00 = _objc_msgSend(self,sel_publisher,pcVar4,pHVar6);
    pvVar2 = _objc_msgSend(self,sel_exporter);
    pcVar4 = _objc_msgSend(pvVar2,sel_exportRepresentation);
    op = sel_publish_;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_progressSheetController,pcVar4,pHVar6);
    _objc_msgSend(pvVar2,sel_endSheet);
    self_00 = self;
    op = sel_removeProgressSheetController;
  }
  _objc_msgSend(self_00,op,pcVar4,pHVar6);
  puVar5 = sel_embeddedCode;
  pvVar2 = _objc_msgSend(exportDidEnd,sel_respondsToSelector_,sel_embeddedCode);
  if ((char)pvVar2 != '\0') {
    _objc_msgSend(*(id *)((int)&self->_isMovieExportHelperEnable + 1),sel_release,puVar5);
    puVar5 = sel_embeddedCode;
    pvVar2 = _objc_msgSend(exportDidEnd,sel_performSelector_,sel_embeddedCode);
    pvVar2 = _objc_msgSend(pvVar2,sel_retain);
    *(id *)((int)&self->_isMovieExportHelperEnable + 1) = pvVar2;
  }
  _objc_msgSend(self,sel_removeExporter,puVar5);
  return;
}

*/
- (void)exportDidEnd:(id)aEnd
{
    if (_isMovieExportHelperEnable) {
        // Give the movie objects back their temporary state.
        for (NSUInteger i = 0; i < [_movieObjectsRunOnArrive count]; i++) {
            [[_movieObjectsRunOnArrive objectAtIndex:i] setTemporary:[[_movieObjectsRunOnArriveTemporaryState objectAtIndex:i] boolValue]];
        }
        [_movieObjectsRunOnArrive release];
        _movieObjectsRunOnArrive = nil;
        [_movieObjectsRunOnArriveTemporaryState release];
        _movieObjectsRunOnArriveTemporaryState = nil;
        for (NSUInteger i = 0; i < [_movieObjectsRunOnLeave count]; i++) {
            [[_movieObjectsRunOnLeave objectAtIndex:i] setTemporary:[[_movieObjectsRunOnLeaveTemporaryState objectAtIndex:i] boolValue]];
        }
        [_movieObjectsRunOnLeave release];
        _movieObjectsRunOnLeave = nil;
        [_movieObjectsRunOnLeaveTemporaryState release];
        _movieObjectsRunOnLeaveTemporaryState = nil;
        [_slideshowTransitionRenderer release];
        _slideshowTransitionRenderer = nil;
        [_slideshowAttributes release];
        _slideshowAttributes = nil;
        _isMovieExportHelperEnable = NO;
    }
    BOOL wasExporting = [self isExporting];
    _isExporting = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerDidEndExportNotification" object:self];
    if (!_hasSessionError && wasExporting) {
        // Hand the result to the publisher.
        [[self publisher] publish:[[self exporter] exportRepresentation]];
    } else {
        [[self progressSheetController] endSheet];
        [self removeProgressSheetController];
    }
    if ([aEnd respondsToSelector:@selector(embeddedCode)]) {
        [_embeddedCode release];
        _embeddedCode = [[aEnd performSelector:@selector(embeddedCode)] retain];
    }
    [self removeExporter];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025c2e1 @ 0025c2e1, 84 bytes * /

void FUN_0025c2e1(HSExportManager *self,SEL _cmd,id exportDidStart)

{
  id self_00;
  
  self->_isExporting[0] = self->_isExporting[0] | 1;
  self_00 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(self_00,sel_postNotificationName_object_,
                &cfstr_HSExportManagerDidStartExportNotification,self);
  return;
}

*/
- (void)exportDidStart:(id)aStart
{
    _isExporting = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerDidStartExportNotification" object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025c10f @ 0025c10f, 466 bytes * /

void FUN_0025c10f(HSExportManager *self,SEL _cmd,id exportWillStart,id withSlideshowAttributes)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(exportWillStart,sel_isSupportedProgressSheet);
  if ((char)pvVar1 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_progressSheetController);
    _objc_msgSend(pvVar1,sel_setProgress_,0,0);
    pvVar1 = _objc_msgSend(self,sel_progressSheetController);
    pvVar2 = _objc_msgSend(exportWillStart,sel_progressSheetDescription);
    _objc_msgSend(pvVar1,sel_setDescription_,pvVar2);
    pvVar1 = _objc_msgSend(self,sel_progressSheetController);
    _objc_msgSend(pvVar1,sel_setProgressIndicatorIndeterminate_,0);
    pvVar1 = _objc_msgSend(self,sel_progressSheetController);
    pvVar2 = _objc_msgSend(self->_document,sel_windowForSheet);
    _objc_msgSend(pvVar1,sel_beginSheetForWindow_,pvVar2);
  }
  self_00 = cls_HSSlideshowAttributes;
  if ((self->_isExporting[0] & 8) != 0) {
    if (withSlideshowAttributes == (id)0x0) {
      pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
      pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSSlideshowAttributesKeyString);
      withSlideshowAttributes = _objc_msgSend(self_00,sel_objectWithExtraDictionary_,pvVar1);
    }
    pvVar1 = _objc_msgSend(withSlideshowAttributes,sel_retain);
    self->_slideshowAttributes = pvVar1;
    self->_slideshowTransitionImageIndex = 0xffffffff;
  }
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,
                &cfstr_HSExportManagerWillStartExportNotification,self);
  return;
}

*/
- (void)exportWillStart:(id)aStart withSlideshowAttributes:(id)aAttributes
{
    if ([aStart isSupportedProgressSheet]) {
        [[self progressSheetController] setProgress:0.0];
        [[self progressSheetController] setDescription:[aStart progressSheetDescription]];
        [[self progressSheetController] setProgressIndicatorIndeterminate:NO];
        [[self progressSheetController] beginSheetForWindow:[_document windowForSheet]];
    }
    if (_isMovieExportHelperEnable) {
        if (aAttributes == nil) {
            aAttributes = [HSSlideshowAttributes objectWithExtraDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"HSSlideshowAttributesKeyString"]];
        }
        _slideshowAttributes = [aAttributes retain];
        _slideshowTransitionImageIndex = UINT_MAX;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerWillStartExportNotification" object:self];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025c049 @ 0025c049, 198 bytes * /

void FUN_0025c049(HSExportManager *self,SEL _cmd,id exportErrorInProgress,id error)

{
  id pvVar1;
  id pvVar2;
  
  self->_isExporting[0] = self->_isExporting[0] | 4;
  pvVar1 = _objc_msgSend(error,sel_retain);
  self->_exportSessionError = pvVar1;
  pvVar1 = _objc_msgSend(self,sel_progressSheetController);
  pvVar2 = _objc_msgSend(self->_document,sel_windowForSheet);
  _objc_msgSend(pvVar1,sel_endSheetWithErrorSheet_modalForWindow_,error,pvVar2);
  _objc_msgSend(self,sel_removeProgressSheetController);
  pvVar1 = _objc_msgSend(cls_NSNotificationCenter,sel_defaultCenter);
  _objc_msgSend(pvVar1,sel_postNotificationName_object_,&cfstr_HSExportManagerDidFailNotification,
                self);
  return;
}

*/
- (void)exportErrorInProgress:(id)aProgress error:(id)aError
{
    _hasSessionError = YES;
    // The original overwrites any previous error without releasing it.
    _exportSessionError = [aError retain];
    [[self progressSheetController] endSheetWithErrorSheet:aError modalForWindow:[_document windowForSheet]];
    [self removeProgressSheetController];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerDidFailNotification" object:self];
}

- (void)exportProgressDidChange:(id)aChange withProgress:(double)aProgress
{
    id pvVar1_3;

    [[self progressSheetController] incrementProgressBy:aProgress];
    pvVar1_3 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:aProgress], @"HSExportProgressValueAttribute", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerDidChangeExportProgressNotification" object:self userInfo:pvVar1_3];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025bf32 @ 0025bf32, 62 bytes * /

void FUN_0025bf32(HSExportManager *self,SEL _cmd)

{
  id self_00;
  
  self->_isExporting[0] = self->_isExporting[0] & 0xfd;
  self_00 = _objc_msgSend(self,sel_publisher);
  _objc_msgSend(self_00,sel_terminatePublish);
  return;
}

*/
- (void)stopPublish
{
    _isPublishing = NO;
    [[self publisher] terminatePublish];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025b56f @ 0025b56f, 23 bytes * /

BOOL FUN_0025b56f(HSExportManager *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((*(uint *)self->_isExporting & 2) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isPublishing
{
    return _isPublishing ? YES : NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025bec7 @ 0025bec7, 107 bytes * /

void FUN_0025bec7(HSExportManager *self,SEL _cmd)

{
  uint uVar1;
  id self_00;
  
  uVar1 = *(uint *)self->_isExporting;
  *(uint *)self->_isExporting = uVar1 & 0xfffffffe;
  if ((uVar1 & 8) != 0) {
    _objc_msgSend(self->_slideshowAttributes,sel_release);
    self->_slideshowAttributes = (id)0x0;
    self->_isExporting[0] = self->_isExporting[0] & 0xf7;
  }
  self_00 = _objc_msgSend(self,sel_exporter);
  _objc_msgSend(self_00,sel_terminateExport);
  return;
}

*/
- (void)stopExport
{
    _isExporting = NO;
    if (_isMovieExportHelperEnable) {
        [_slideshowAttributes release];
        _slideshowAttributes = nil;
        _isMovieExportHelperEnable = NO;
    }
    [[self exporter] terminateExport];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025b558 @ 0025b558, 23 bytes * /

BOOL FUN_0025b558(HSExportManager *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((*(uint *)self->_isExporting & 1) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)isExporting
{
    return _isExporting ? YES : NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025bc9f @ 0025bc9f, 552 bytes * /

void FUN_0025bc9f(HSExportManager *self,SEL _cmd,id exportDocumentWithFileName,id ofType)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  cfstringStruct *pcVar5;
  char *pcVar6;
  id local_18;
  char local_11;
  
  self->_isExporting[0] = self->_isExporting[0] & 0xfb;
  pvVar2 = _objc_msgSend(self,sel_publisher);
  pvVar2 = _objc_msgSend(pvVar2,sel_publishLocation);
  local_18 = exportDocumentWithFileName;
  pvVar2 = _objc_msgSend(pvVar2,sel_stringByAppendingPathComponent_,exportDocumentWithFileName);
  pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar4 = _objc_msgSend(cls_HSSystem,sel_sharedSystem);
  pvVar4 = _objc_msgSend(pvVar4,sel_isSandboxed);
  if ((char)pvVar4 == '\0') {
    local_11 = '\x01';
    pcVar6 = &local_11;
    pvVar2 = _objc_msgSend(pvVar3,sel_hyperIsFileWritableAtPath_directory_,pvVar2,pcVar6);
    cVar1 = local_11;
    if ((char)pvVar2 != '\0') goto joined_r0x0025be31;
  }
  else {
    pcVar6 = (char *)0x0;
    pvVar2 = _objc_msgSend(pvVar3,sel_hyperIsFileWritableAtPath_checkDirectory_,pvVar2,0);
    cVar1 = (char)pvVar2;
joined_r0x0025be31:
    if (cVar1 != '\0') {
      pcVar5 = &cfstr_HSHTML5DocumentType;
      pvVar2 = _objc_msgSend(ofType,sel_isEqualToString_,&cfstr_HSHTML5DocumentType,pcVar6);
      if ((char)pvVar2 == '\0') {
        local_18 = _objc_msgSend(exportDocumentWithFileName,sel_stringByDeletingPathExtension,pcVar5
                                 ,pcVar6);
      }
      pvVar2 = _objc_msgSend(self,sel_exporter,pcVar5,pcVar6);
      _objc_msgSend(pvVar2,sel_setExportedDocumentName_,local_18);
      pvVar3 = _objc_msgSend(self,sel_exporter);
      pvVar2 = self->_document;
      op = sel_exportDocument_ofType_;
      goto LAB_0025beba;
    }
  }
  self->_isExporting[0] = self->_isExporting[0] | 4;
  pvVar2 = _objc_msgSend(cls_HSError,sel_errorWithHSCode_,0x502b,pcVar6);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_exportSessionError = pvVar2;
  pvVar3 = _objc_msgSend(cls_HSErrorManager,sel_sharedErrorManager);
  ofType = _objc_msgSend(self->_document,sel_windowForSheet);
  pvVar2 = self->_exportSessionError;
  op = sel_presentError_inWindow_;
LAB_0025beba:
  _objc_msgSend(pvVar3,op,pvVar2,ofType);
  return;
}

*/
- (void)exportDocumentWithFileName:(id)aName ofType:(id)aType
{
    _hasSessionError = NO;
    NSString *path = [[[self publisher] publishLocation] stringByAppendingPathComponent:aName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL canWrite;
    if (![[HSSystem sharedSystem] isSandboxed]) {
        BOOL isDirectory = YES;
        canWrite = [fileManager hyperIsFileWritableAtPath:path directory:&isDirectory] && isDirectory;
    } else {
        canWrite = [fileManager hyperIsFileWritableAtPath:path checkDirectory:NO];
    }
    if (canWrite) {
        NSString *documentName = aName;
        if (![aType isEqualToString:@"HSHTML5DocumentType"]) {
            documentName = [aName stringByDeletingPathExtension];
        }
        [[self exporter] setExportedDocumentName:documentName];
        [[self exporter] exportDocument:_document ofType:aType];
        return;
    }
    _hasSessionError = YES;
    _exportSessionError = [[HSError errorWithHSCode:0x502b] retain];
    [[HSErrorManager sharedErrorManager] presentError:_exportSessionError inWindow:[_document windowForSheet]];
}

- (void)clearSessionError
{
    [_exportSessionError release];
    _exportSessionError = nil;
}

- (id)exportSessionError
{
    return _exportSessionError;
}

- (void)closeExportSession
{
    [_previewDocument release];
    _previewDocument = nil;
    [_document release];
    _document = nil;
    [self clearSessionError];
}

- (BOOL)isOpenExportSession
{
    return _document != nil;
}

- (void)openExportSessionWithDocument:(id)aDocument
{
    [self removeExporter];
    [self removePublisher];
    if (_document != aDocument) {
        [_document release];
        _document = [aDocument retain];
    }
    [self clearSessionError];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025ec0d @ 0025ec0d, 489 bytes * /

void FUN_0025ec0d(HSExportManager *self,SEL _cmd,id alertDidEnd,int returnCode,void *contextInfo)

{
  void *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  HSExportManager *self_01;
  cfstringStruct *pcVar4;
  SEL op;
  void *local_1c;
  int local_18;
  id local_14;
  
  local_14 = alertDidEnd;
  local_18 = returnCode;
  local_1c = contextInfo;
  pvVar1 = _objc_msgSend(self,sel_alertToDidEndInvocationMapTable);
  pvVar1 = (id)_NSMapGet(pvVar1,alertDidEnd);
  self_00 = local_1c;
  if (pvVar1 != (id)0x0) {
    pcVar4 = &cfstr_HSExportAlertTargetActivityKey;
    pvVar2 = _objc_msgSend(local_1c,sel_objectForKey_,&cfstr_HSExportAlertTargetActivityKey);
    pvVar2 = _objc_msgSend(pvVar2,sel_boolValue);
    self_01 = self;
    op = sel_removeProgressSheetController;
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(self,sel_progressSheetController,pcVar4);
      pvVar3 = _objc_msgSend(self,sel_publisher);
      pvVar3 = _objc_msgSend(pvVar3,sel_progressSheetDescription);
      _objc_msgSend(pvVar2,sel_setDescription_,pvVar3);
      self_01 = _objc_msgSend(self,sel_progressSheetController);
      pcVar4 = _objc_msgSend(self->_document,sel_windowForSheet);
      op = sel_beginSheetForWindow_;
    }
    _objc_msgSend(self_01,op,pcVar4);
    _objc_msgSend(self_00,sel_autorelease);
    _objc_msgSend(pvVar1,sel_setArgument_atIndex_,&local_14,2);
    _objc_msgSend(pvVar1,sel_setArgument_atIndex_,&local_18,3);
    _objc_msgSend(pvVar1,sel_setArgument_atIndex_,&local_1c,4);
    _objc_msgSend(pvVar1,sel_invoke);
    pvVar1 = local_14;
    pvVar2 = _objc_msgSend(self,sel_alertToDidEndInvocationMapTable);
    _NSMapRemove(pvVar2,pvVar1);
  }
  return;
}

*/
- (void)alertDidEnd:(id)aEnd returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    NSInvocation *invocation = NSMapGet([self alertToDidEndInvocationMapTable], aEnd);
    if (invocation == nil) {
        return;
    }
    NSDictionary *options = (NSDictionary *)aInfo;
    if ([[options objectForKey:@"HSExportAlertTargetActivityKey"] boolValue]) {
        // The publisher keeps working after the alert: bring the progress sheet back.
        [[self progressSheetController] setDescription:[[self publisher] progressSheetDescription]];
        [[self progressSheetController] beginSheetForWindow:[_document windowForSheet]];
    } else {
        [self removeProgressSheetController];
    }
    [options autorelease];
    [invocation setArgument:&aEnd atIndex:2];
    [invocation setArgument:&aCode atIndex:3];
    [invocation setArgument:&aInfo atIndex:4];
    [invocation invoke];
    NSMapRemove([self alertToDidEndInvocationMapTable], aEnd);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025edf6 @ 0025edf6, 108 bytes * /

id FUN_0025edf6(HSExportManager *self,SEL _cmd)

{
  id pvVar1;
  
  pvVar1 = self->_alertToDidEndInvocationMapTable;
  if (pvVar1 == (id)0x0) {
    pvVar1 = (id)_NSCreateMapTable(*(undefined8 *)PTR_00336444,*(undefined8 *)(PTR_00336444 + 8),
                                   *(undefined8 *)(PTR_00336444 + 0x10),*(undefined4 *)PTR_0033639c,
                                   *(undefined4 *)(PTR_0033639c + 4),
                                   *(undefined4 *)(PTR_0033639c + 8),0);
    self->_alertToDidEndInvocationMapTable = pvVar1;
  }
  return pvVar1;
}

*/
- (id)alertToDidEndInvocationMapTable
{
    if (_alertToDidEndInvocationMapTable == nil) {
        _alertToDidEndInvocationMapTable = NSCreateMapTable(NSObjectMapKeyCallBacks, NSObjectMapValueCallBacks, 0);
    }
    return _alertToDidEndInvocationMapTable;
}

- (void)removeProgressSheetController
{
    if (_progressSheetController != nil) {
        [_progressSheetController setDelegate:0];
        [_progressSheetController release];
        _progressSheetController = nil;
    }
}

- (id)progressSheetController
{
    id pvVar1;
    id pvVar1_2;

    pvVar1 = _progressSheetController;
    if (pvVar1 == nil) {
        pvVar1_2 = [HSExportProgressSheetController new];
        _progressSheetController = pvVar1_2;
        [pvVar1_2 setDelegate:self];
        pvVar1 = _progressSheetController;
    }
    return pvVar1;
}

- (id)exportPanelController
{
    id pvVar1_2;
    id pvVar2_2;

    pvVar1_2 = [[self exporter] exportAccessoryViewControllerForPublishType:_publishType]
    ;
    pvVar2_2 = [[self publisher] exportPanelController];
    [pvVar1_2 setExportPanelController:pvVar2_2];
    [pvVar2_2 setAccessoryViewController:pvVar1_2];
    [pvVar2_2 setAccessoryView:[pvVar1_2 view]];
    return pvVar2_2;
}

- (id)storyboardControllerForDocument:(id)aDocument
{
    return [self windowControllerOfClass:[HSStoryboardController class] forDocument:aDocument];
}

- (id)windowControllerOfClass:(Class)aClass forDocument:(id)aDocument
{
    NSArray *pvVar1;
    NSEnumerator *self_00;
    id self_01;
    id pvVar1_2;

    pvVar1 = [aDocument windowControllers];
    self_00 = [pvVar1 objectEnumerator];
    pvVar1_2 = nil;
    while ((self_01 = [self_00 nextObject], self_01 != nil && (pvVar1 == nil) )) {
        [self_01 isKindOfClass:aClass];
        pvVar1_2 = self_01;
    }
    return pvVar1_2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025b8e7 @ 0025b8e7, 104 bytes * /

id FUN_0025b8e7(HSExportManager *self,SEL _cmd)

{
  id pvVar1;
  SEL op;
  
  pvVar1 = self->_previewDocument;
  if (pvVar1 == (id)0x0) {
    if ((self->_isExporting[0] & 8) == 0) {
      pvVar1 = self->_document;
      op = sel_retain;
    }
    else {
      pvVar1 = _objc_msgSend(cls_HSPreviewDocument,sel_alloc);
      op = sel_initForExportWithDocument_;
    }
    pvVar1 = _objc_msgSend(pvVar1,op);
    self->_previewDocument = pvVar1;
  }
  return pvVar1;
}

*/
- (id)previewDocument
{
    if (_previewDocument == nil) {
        if (_isMovieExportHelperEnable) {
            // Video export plays the stack, so it works on a preview copy.
            _previewDocument = [[HSPreviewDocument alloc] initForExportWithDocument:_document];
        } else {
            _previewDocument = (HSPreviewDocument *)[_document retain];
        }
    }
    return _previewDocument;
}

- (void)removePublisher
{
    if (_publisher != nil) {
        if ([_publisher delegate] == self) {
            [_publisher setDelegate:0];
        }
    }
    [_publisher release];
    _publisher = nil;
}

- (void)removeExporter
{
    if (_exporter != nil) {
        if ([_exporter delegate] == self) {
            [_exporter setDelegate:0];
        }
        if ([_exporter dataSource] == self) {
            [_exporter setDataSource:0];
        }
    }
    [_exporter release];
    _exporter = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025b744 @ 0025b744, 145 bytes * /

id FUN_0025b744(HSExportManager *self,SEL _cmd)

{
  int iVar1;
  id self_00;
  id pvVar2;
  undefined *puVar3;
  SEL op;
  
  if (self->_publisher != (id)0x0) {
    return self->_publisher;
  }
  iVar1 = self->_publishType;
  puVar3 = cls_HSDiskPublisher;
  if ((iVar1 == 1) || (puVar3 = cls_HSITunesPublisher, iVar1 == 2)) {
    puVar3 = _objc_msgSend(puVar3,sel_alloc);
    op = sel_init;
  }
  else {
    self_00 = (id)0x0;
    puVar3 = cls_HSiBooksAuthorPublisher;
    op = sel_new;
    if (iVar1 != 3) goto LAB_0025b789;
  }
  self_00 = _objc_msgSend(puVar3,op);
  self->_publisher = self_00;
LAB_0025b789:
  pvVar2 = (id)0x0;
  if (self_00 != (id)0x0) {
    _objc_msgSend(self_00,sel_setDelegate_,self);
    pvVar2 = self->_publisher;
  }
  return pvVar2;
}

*/
- (id)publisher
{
    if (_publisher != nil) {
        return _publisher;
    }
    switch (_publishType) {
        case 1:
            _publisher = [[HSDiskPublisher alloc] init];
            break;
        case 2:
            _publisher = [[HSITunesPublisher alloc] init];
            break;
        case 3:
            _publisher = nil;
            break;
        default:
            return nil;
    }
    if (_publisher == nil) {
        return nil;
    }
    [_publisher setDelegate:self];
    return _publisher;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025b5fe @ 0025b5fe, 291 bytes * /

id FUN_0025b5fe(HSExportManager *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  undefined4 uVar3;
  
  if (self->_exporter != (id)0x0) {
    return self->_exporter;
  }
  switch(self->_exportFormat) {
  case 1:
    self_00 = cls_HSWebExporter2;
    break;
  case 2:
    self_00 = cls_HSStackToGoExporter;
    break;
  case 3:
    self_00 = cls_HSImageSequenceExporter;
    break;
  case 4:
    self->_isExporting[0] = self->_isExporting[0] | 8;
    pvVar1 = _objc_msgSend(cls_HSVideoExporter,sel_new);
    self->_exporter = pvVar1;
    uVar3 = 0;
    goto LAB_0025b6dc;
  case 5:
  case 6:
    self->_isExporting[0] = self->_isExporting[0] | 8;
    pvVar1 = _objc_msgSend(cls_HSVideoExporter,sel_new);
    self->_exporter = pvVar1;
    uVar3 = 1;
LAB_0025b6dc:
    _objc_msgSend(pvVar1,sel_setVideoExportFormat_,uVar3);
switchD_0025b630_default:
    pvVar1 = self->_exporter;
    goto LAB_0025b6e4;
  case 7:
    self_00 = cls_HSHTML5Exporter;
    break;
  case 8:
    self_00 = cls_HSiBooksAuthorExporter;
    break;
  default:
    goto switchD_0025b630_default;
  }
  pvVar1 = _objc_msgSend(self_00,sel_new);
  self->_exporter = pvVar1;
LAB_0025b6e4:
  pvVar2 = (id)0x0;
  if (pvVar1 != (id)0x0) {
    _objc_msgSend(pvVar1,sel_setDelegate_,self);
    _objc_msgSend(self->_exporter,sel_setDataSource_,self);
    pvVar2 = self->_exporter;
  }
  return pvVar2;
}

*/
- (id)exporter
{
    if (_exporter != nil) {
        return _exporter;
    }
    switch (_exportFormat) {
        case 1:
            _exporter = [HSWebExporter2 new];
            break;
        case 2:
            _exporter = [HSStackToGoExporter new];
            break;
        case 3:
            _exporter = [HSImageSequenceExporter new];
            break;
        case 4:
            _isMovieExportHelperEnable = YES;
            _exporter = [HSVideoExporter new];
            [(HSVideoExporter *)_exporter setVideoExportFormat:0];
            break;
        case 5:
        case 6:
            _isMovieExportHelperEnable = YES;
            _exporter = [HSVideoExporter new];
            [(HSVideoExporter *)_exporter setVideoExportFormat:1];
            break;
        case 7:
            _exporter = [HSHTML5Exporter new];
            break;
        case 8:
            _exporter = [HSiBooksAuthorExporter new];
            break;
        default:
            break;
    }
    if (_exporter == nil) {
        return nil;
    }
    [_exporter setDelegate:self];
    [_exporter setDataSource:self];
    return _exporter;
}

- (void)setPublishType:(NSInteger)aType
{
    if (_publishType != aType) {
        _publishType = aType;
        [self removePublisher];
    }
}

- (void)setExportFormat:(NSInteger)aFormat
{
    if (_exportFormat != aFormat) {
        _exportFormat = aFormat;
        [self removeExporter];
    }
}

- (NSInteger)exportFormat
{
    return _exportFormat;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025ddeb @ 0025ddeb, 394 bytes * /

void FUN_0025ddeb(HSExportManager *self,SEL _cmd)

{
  id pvVar1;
  HSExportManager *pHVar2;
  HSExportManager *local_14;
  undefined *local_10;
  
  pvVar1 = _objc_msgSend(self,sel_isOpenExportSession);
  if ((char)pvVar1 != '\0') {
    _objc_msgSend(self,sel_closeExportSession);
  }
  _objc_msgSend(self,sel_removeExporter);
  _objc_msgSend(self,sel_removePublisher);
  pHVar2 = _objc_msgSend(self->_progressSheetController,sel_delegate);
  if (pHVar2 == self) {
    _objc_msgSend(self->_progressSheetController,sel_setDelegate_,0);
  }
  _objc_msgSend(self->_progressSheetController,sel_release);
  _objc_msgSend(self,sel_clearSessionError);
  _objc_msgSend(self->_previewDocument,sel_release);
  if ((self->_isExporting[0] & 8) != 0) {
    _objc_msgSend(self->_movieObjectsRunOnArrive,sel_release);
    _objc_msgSend(self->_movieObjectsRunOnArriveTemporaryState,sel_release);
    _objc_msgSend(self->_movieObjectsRunOnLeave,sel_release);
    _objc_msgSend(self->_movieObjectsRunOnLeaveTemporaryState,sel_release);
    _objc_msgSend(self->_slideshowAttributes,sel_release);
  }
  if (self->_alertToDidEndInvocationMapTable != (id)0x0) {
    _NSFreeMapTable(self->_alertToDidEndInvocationMapTable);
  }
  _objc_msgSend(*(id *)((int)&self->_isMovieExportHelperEnable + 1),sel_release);
  local_14 = self;
  local_10 = PTR_s_NSObject_00355fa0;
  _objc_msgSendSuper(&local_14,sel_dealloc);
  return;
}

*/
- (void)dealloc
{
    if ([self isOpenExportSession]) {
        [self closeExportSession];
    }
    [self removeExporter];
    [self removePublisher];
    if ([_progressSheetController delegate] == self) {
        [_progressSheetController setDelegate:nil];
    }
    [_progressSheetController release];
    [self clearSessionError];
    [_previewDocument release];
    if (_isMovieExportHelperEnable) {
        [_movieObjectsRunOnArrive release];
        [_movieObjectsRunOnArriveTemporaryState release];
        [_movieObjectsRunOnLeave release];
        [_movieObjectsRunOnLeaveTemporaryState release];
        [_slideshowAttributes release];
    }
    if (_alertToDidEndInvocationMapTable != nil) {
        NSFreeMapTable(_alertToDidEndInvocationMapTable);
    }
    [_embeddedCode release];
    [super dealloc];
}

- (id)escapeFileNameForExport:(id)aName
{
    return [_exporter escapeFileNameForExport:aName];
}

- (id)finishWindowController
{
    if (_finishWindowController == nil) {
        NSString *location = [[self publisher] publishLocation];
        NSString *fullPath = [location stringByAppendingPathComponent:[[[self exporter] exportRepresentation] preferredFilename]];
        id controllerClass = nil;
        NSString *storePath = fullPath;
        if (_publishType == 5) {
            controllerClass = [HSAFTPServerFinishWindowController class];
            storePath = location;
        } else if (_publishType == 4) {
            controllerClass = [HSiBooksAuthorFinishWindowController class];
        } else if (_publishType == 1 && (unsigned)(_exportFormat - 8) < 2) {
            controllerClass = [HSAFinishWindowController class];
        }
        if (controllerClass != nil) {
            _finishWindowController = [[controllerClass alloc] initWithStorePath:storePath];
        }
    }
    return _finishWindowController;
}

- (int)mapExportErrorCodeWithWriteErrorCode:(int)aCode
{
    if (aCode == 0x200) {
        return 0x5025;
    }
    if (aCode == 0x280) {
        return 0x502c;
    }
    if (aCode == 0x201) {
        return 0x502b;
    }
    return aCode;
}

- (void)notifyPublishDidEnd
{
    _isPublishing = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HSExportManagerDidEndPublishNotification" object:self];
}

- (void)publishWillEnd:(id)aPublish
{
}

- (void)showFinishWindow
{
    id window = [[self finishWindowController] window];
    if (window != nil) {
        [NSApp beginSheet:window modalForWindow:[_document windowForSheet] modalDelegate:self didEndSelector:@selector(showFinishWindowDidEnd:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void)showFinishWindowDidEnd:(id)aWindow returnCode:(NSInteger)aCode contextInfo:(void *)aInfo
{
    [aWindow orderOut:nil];
    [_finishWindowController autorelease];
    _finishWindowController = nil;
}

@end

