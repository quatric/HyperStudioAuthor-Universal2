#import "HSQTMovieExporter.h"

// FUN_0025a47b: the play range is stored as a size string, "{location, length}"
static struct HSTimeRange HSQTMovieExporterPlayRangeFromString(NSString *aString)
{
    NSSize size = (aString != nil) ? NSSizeFromString(aString) : NSZeroSize;
    return HSMakeTimeRange(size.width, size.height);
}

// DAT_003426a0: the 'vide' media type
static unsigned int sVideoMediaType = 'vide';

// The exporter's durations are QuickTime times in the movie's 600 time scale.
static struct HyperStudio_anon7 HSQTMovieExporterDurationFromSeconds(double aSeconds)
{
    struct HyperStudio_anon7 duration = { (int)(aSeconds * 600.0), 600, 0 };
    return duration;
}

// FUN_00256918: the movie conversion progress proc; the conversion covers half of the export progress,
// and the callback reports how much it advanced since its previous call (the original kept it in a static).
static short HSQTMovieExporterConversionProgress(void *aMovie, short aMessage, short aOperation, int aPercentDone, id aSender)
{
    static double sPreviousProgress = 0.0;
    double progress = (double)((float)aPercentDone / 65535.0f) * 50.0;
    double step = progress - sPreviousProgress;
    sPreviousProgress = progress;
    [aSender notifyExportProgressDidChangeWithProgress:step];
    return 0;
}

// DAT_003426b0: sound, music, sprite-less audio-bearing media ('soun', 'musi', 'sdsm', 'odsm', 'm1a ')
static unsigned int sSoundMediaTypes[5] = { 'soun', 'musi', 'sdsm', 'odsm', 'm1a ' };

@implementation HSQTMovieExporter

/* i386 ivar offsets: _codeConfiguration=0x24, _dataHandleRef=0x28, _outputMovie=0x2c, _tempFilePath=0x30, _currentImageIndex=0x34, _cornersClipPath=0x38, _transitionName=0x3c, _slideDelay=0x40, _canUseRoundedCorners=0x44 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00256cfb @ 00256cfb, 226 bytes * /

id FUN_00256cfb(id self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  self_00 = cls_NSDictionary;
  pvVar1 = _objc_msgSend(cls_NSValue,sel_valueWithSize_,*(undefined4 *)PTR_DAT_003368ec,
                         *(undefined4 *)(PTR_DAT_003368ec + 4));
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithLong_,0x300);
  pvVar3 = _objc_msgSend(cls_NSString,sel_extraStringWithFourCharCode_,0x6d703476);
  pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar3,
                         &cfstr_HSQTMovieExporterCodecType,pvVar2,
                         &cfstr_HSQTMovieExporterCodecQuality,pvVar1,
                         &cfstr_HSQTMovieExporterMovieFrameSize,0);
  return pvVar1;
}

*/
+ (id)defaultCodecConfigurationForIPadMovie
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString extraStringWithFourCharCode:'mp4v'], HSQTMovieExporterCodecType,
        [NSNumber numberWithLong:0x300], HSQTMovieExporterCodecQuality,
        [NSValue valueWithSize:NSMakeSize(1024.0f, 768.0f)], HSQTMovieExporterMovieFrameSize, nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00256c19 @ 00256c19, 226 bytes * /

id FUN_00256c19(id self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  self_00 = cls_NSDictionary;
  pvVar1 = _objc_msgSend(cls_NSValue,sel_valueWithSize_,*(undefined4 *)PTR_DAT_003368f0,
                         *(undefined4 *)(PTR_DAT_003368f0 + 4));
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithLong_,0x300);
  pvVar3 = _objc_msgSend(cls_NSString,sel_extraStringWithFourCharCode_,0x6d703476);
  pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar3,
                         &cfstr_HSQTMovieExporterCodecType,pvVar2,
                         &cfstr_HSQTMovieExporterCodecQuality,pvVar1,
                         &cfstr_HSQTMovieExporterMovieFrameSize,0);
  return pvVar1;
}

*/
+ (id)defaultCodecConfigurationForIPhone4Movie
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString extraStringWithFourCharCode:'mp4v'], HSQTMovieExporterCodecType,
        [NSNumber numberWithLong:0x300], HSQTMovieExporterCodecQuality,
        [NSValue valueWithSize:NSMakeSize(960.0f, 640.0f)], HSQTMovieExporterMovieFrameSize, nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00256b37 @ 00256b37, 226 bytes * /

id FUN_00256b37(id self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  self_00 = cls_NSDictionary;
  pvVar1 = _objc_msgSend(cls_NSValue,sel_valueWithSize_,*(undefined4 *)PTR_DAT_003368f4,
                         *(undefined4 *)(PTR_DAT_003368f4 + 4));
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithLong_,0x300);
  pvVar3 = _objc_msgSend(cls_NSString,sel_extraStringWithFourCharCode_,0x6d703476);
  pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar3,
                         &cfstr_HSQTMovieExporterCodecType,pvVar2,
                         &cfstr_HSQTMovieExporterCodecQuality,pvVar1,
                         &cfstr_HSQTMovieExporterMovieFrameSize,0);
  return pvVar1;
}

*/
+ (id)defaultCodecConfigurationForIPhoneMovie
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString extraStringWithFourCharCode:'mp4v'], HSQTMovieExporterCodecType,
        [NSNumber numberWithLong:0x300], HSQTMovieExporterCodecQuality,
        [NSValue valueWithSize:NSMakeSize(480.0f, 320.0f)], HSQTMovieExporterMovieFrameSize, nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00256a55 @ 00256a55, 226 bytes * /

id FUN_00256a55(id self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  self_00 = cls_NSDictionary;
  pvVar1 = _objc_msgSend(cls_NSValue,sel_valueWithSize_,*(undefined4 *)PTR_DAT_003368f8,
                         *(undefined4 *)(PTR_DAT_003368f8 + 4));
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithLong_,0x300);
  pvVar3 = _objc_msgSend(cls_NSString,sel_extraStringWithFourCharCode_,0x6d703476);
  pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar3,
                         &cfstr_HSQTMovieExporterCodecType,pvVar2,
                         &cfstr_HSQTMovieExporterCodecQuality,pvVar1,
                         &cfstr_HSQTMovieExporterMovieFrameSize,0);
  return pvVar1;
}

*/
+ (id)defaultCodecConfigurationForIPodMovie
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString extraStringWithFourCharCode:'mp4v'], HSQTMovieExporterCodecType,
        [NSNumber numberWithLong:0x300], HSQTMovieExporterCodecQuality,
        [NSValue valueWithSize:NSMakeSize(320.0f, 240.0f)], HSQTMovieExporterMovieFrameSize, nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00256973 @ 00256973, 226 bytes * /

id FUN_00256973(id self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  self_00 = cls_NSDictionary;
  pvVar1 = _objc_msgSend(cls_NSValue,sel_valueWithSize_,*(undefined4 *)PTR_DAT_003368fc,
                         *(undefined4 *)(PTR_DAT_003368fc + 4));
  pvVar2 = _objc_msgSend(cls_NSNumber,sel_numberWithLong_,0x300);
  pvVar3 = _objc_msgSend(cls_NSString,sel_extraStringWithFourCharCode_,0x6d703476);
  pvVar1 = _objc_msgSend(self_00,sel_dictionaryWithObjectsAndKeys_,pvVar3,
                         &cfstr_HSQTMovieExporterCodecType,pvVar2,
                         &cfstr_HSQTMovieExporterCodecQuality,pvVar1,
                         &cfstr_HSQTMovieExporterMovieFrameSize,0);
  return pvVar1;
}

*/
+ (id)defaultCodecConfigurationForMovie
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSString extraStringWithFourCharCode:'mp4v'], HSQTMovieExporterCodecType,
        [NSNumber numberWithLong:0x300], HSQTMovieExporterCodecQuality,
        [NSValue valueWithSize:NSMakeSize(800.0f, 600.0f)], HSQTMovieExporterMovieFrameSize, nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00256e52 @ 00256e52, 159 bytes * /

void FUN_00256e52(HSQTMovieExporter *self,SEL _cmd)

{
  id self_00;
  
  if (self->_dataHandleRef != (char **)0x0) {
    _CloseMovieStorage(self->_dataHandleRef);
    self->_dataHandleRef = (char **)0x0;
  }
  _objc_msgSend(self->_outputMovie,sel_release);
  self->_outputMovie = (id)0x0;
  self_00 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  _objc_msgSend(self_00,sel_removeFileAtPath_handler_,self->_tempFilePath,0);
  _objc_msgSend(self->_tempFilePath,sel_release);
  self->_tempFilePath = (id)0x0;
  return;
}

*/
- (void)cleanupMovieAfterExport
{
    if (_dataHandleRef != NULL) {
        // CloseMovieStorage(_dataHandleRef) in the original; HSQTKit movies need no data handler.
        _dataHandleRef = NULL;
    }
    [_outputMovie release];
    _outputMovie = nil;
    [[NSFileManager defaultManager] removeItemAtPath:_tempFilePath error:NULL];
    [_tempFilePath release];
    _tempFilePath = nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025653d @ 0025653d, 987 bytes * /

void FUN_0025653d(HSQTMovieExporter *self,SEL _cmd,id performExportDocument,id ofType)

{
  uint *puVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  int *piVar6;
  undefined4 extraout_EDX;
  bool bVar7;
  SEL pcVar8;
  cfstringStruct *pcVar9;
  int iVar10;
  undefined4 uVar11;
  undefined4 uVar12;
  int **ppiVar13;
  code *pcVar14;
  HSQTMovieExporter *pHVar15;
  cfstringStruct *local_20;
  undefined4 local_1c;
  int *local_18;
  int local_14;
  
  local_14 = 0;
  local_18 = (int *)0x0;
  puVar1 = &(self->super)._shouldTerminateExport;
  *(byte *)puVar1 = (byte)*puVar1 & 0xfe;
  pvVar2 = _objc_msgSend(self,sel_HSQTMovieExporter_slideShowAttributes);
  _objc_msgSend(self,sel_notifyExportWillStartWithSlideshowAttributes_,pvVar2);
  _objc_msgSend(self,sel_notifyExportDidStart);
  piVar6 = &local_14;
  pvVar2 = _objc_msgSend(self,sel_createQTKitMovieWithError_,piVar6);
  pvVar2 = _objc_msgSend(pvVar2,sel_retain);
  self->_outputMovie = pvVar2;
  bVar7 = false;
  if (pvVar2 != (id)0x0) {
    pcVar9 = &cfstr_HSiPodDocumentType;
    pvVar2 = _objc_msgSend(ofType,sel_isEqualToString_,&cfstr_HSiPodDocumentType);
    if ((char)pvVar2 == '\0') {
      pcVar9 = &cfstr_HSiPhoneDocumentType;
      pvVar2 = _objc_msgSend(ofType,sel_isEqualToString_,&cfstr_HSiPhoneDocumentType);
      if ((char)pvVar2 == '\0') {
        local_20 = &cfstr_mov;
        local_1c = 0x4d4f5620;
      }
      else {
        local_20 = &cfstr_m4v;
        local_1c = 0x4d345650;
      }
    }
    else {
      local_20 = &cfstr_m4v;
      local_1c = 0x4d345620;
    }
    pvVar2 = _objc_msgSend(self,sel_dataSource,pcVar9);
    pvVar2 = _objc_msgSend(pvVar2,sel_artworkImageForExporter_,self);
    if (pvVar2 != (id)0x0) {
      _objc_msgSend(cls_HSQuickTimeMovieHelper,sel_addArtworkImage_inMovie_ofType_,pvVar2,
                    self->_outputMovie,local_1c);
    }
    piVar6 = self->_outputMovie;
    ppiVar13 = &local_18;
    uVar12 = 0x40590000;
    uVar11 = 0;
    pvVar2 = _objc_msgSend(self,sel_buildMovieContent_inProgressRange_error_,piVar6,0,0x40590000,
                           ppiVar13);
    if (((char)pvVar2 == '\0') || (((self->super)._shouldTerminateExport & 1) != 0)) {
      bVar7 = false;
    }
    else {
      pvVar2 = _objc_msgSend(self->_tempFilePath,sel_stringByDeletingLastPathComponent,piVar6,uVar11
                             ,uVar12,ppiVar13);
      pvVar3 = _objc_msgSend(self,sel_exportedDocumentName);
      pvVar3 = _objc_msgSend(pvVar3,sel_stringByAppendingPathExtension_,local_20);
      pvVar3 = _objc_msgSend(pvVar2,sel_stringByAppendingPathComponent_,pvVar3);
      self_00 = cls_HSQuickTimeMovieHelper;
      pvVar4 = _objc_msgSend(self,sel_movieFrameSize);
      piVar6 = self->_outputMovie;
      pcVar14 = FUN_00256918;
      uVar11 = extraout_EDX;
      pvVar2 = pvVar3;
      pHVar15 = self;
      pvVar5 = _objc_msgSend(self_00,
                             sel_convertMovie_frameSize_ofType_toFile_progressCallback_sender_,
                             piVar6,pvVar4,extraout_EDX,local_1c,pvVar3,FUN_00256918,self);
      bVar7 = pvVar5 == (id)0x0;
      if (bVar7) {
        pvVar2 = _objc_msgSend(cls_NSFileWrapper,sel_alloc,piVar6,pvVar4,uVar11,local_1c,pvVar2,
                               pcVar14,pHVar15);
        pvVar2 = _objc_msgSend(pvVar2,sel_initWithPath_,pvVar3);
        pvVar4 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
        _objc_msgSend(pvVar4,sel_removeFileAtPath_handler_,pvVar3,0);
        piVar6 = (int *)0x0;
        _objc_msgSend(self,sel_notifyExportProgressDidChangeWithProgress_,0,0x40590000);
        goto LAB_00256856;
      }
    }
  }
  pvVar2 = (id)0x0;
LAB_00256856:
  _objc_msgSend(self,sel_cleanupMovieAfterExport,piVar6);
  _objc_msgSend((self->super)._exportRepresentation,sel_autorelease);
  pvVar3 = (id)0x0;
  if (bVar7) {
    pvVar3 = pvVar2;
  }
  (self->super)._exportRepresentation = pvVar3;
  pcVar8 = sel_notifyExportDidEnd;
  if (((!bVar7) &&
      (pcVar8 = sel_notifyExportDidTerminate, ((self->super)._shouldTerminateExport & 1) == 0)) &&
     (pcVar8 = sel_notifyExportErrorInProgress_, piVar6 = local_18, local_18 == (int *)0x0)) {
    pcVar8 = sel_errorWithError_;
    iVar10 = local_14;
    if (local_14 == 0) {
      pcVar8 = sel_errorWithHSCode_;
      iVar10 = 0x5025;
    }
    piVar6 = _objc_msgSend(cls_HSError,pcVar8,iVar10);
    pcVar8 = sel_notifyExportErrorInProgress_;
    local_18 = piVar6;
  }
  _objc_msgSend(self,pcVar8,piVar6);
  return;
}

*/
- (void)performExportDocument:(id)aDocument ofType:(id)aType
{
    NSError *movieError = nil;
    NSError *exportError = nil;
    NSFileWrapper *wrapper = nil;
    BOOL succeeded = NO;
    _shouldTerminateExport = NO;
    [self notifyExportWillStartWithSlideshowAttributes:[self HSQTMovieExporter_slideShowAttributes]];
    [self notifyExportDidStart];
    _outputMovie = [[self createQTKitMovieWithError:&movieError] retain];
    if (_outputMovie != nil) {
        NSString *extension;
        unsigned int movieType;
        if ([aType isEqualToString:@"HSiPodDocumentType"]) {
            extension = @"m4v";
            movieType = 'M4V ';
        } else if ([aType isEqualToString:@"HSiPhoneDocumentType"]) {
            extension = @"m4v";
            movieType = 'M4VP';
        } else {
            extension = @"mov";
            movieType = 'MOV ';
        }
        NSImage *artwork = [[self dataSource] artworkImageForExporter:self];
        if (artwork != nil) {
            [HSQuickTimeMovieHelper addArtworkImage:artwork inMovie:_outputMovie ofType:movieType];
        }
        if ([self buildMovieContent:_outputMovie inProgressRange:100.0 error:&exportError] && !_shouldTerminateExport) {
            NSString *outputPath = [[_tempFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:[[self exportedDocumentName] stringByAppendingPathExtension:extension]];
            NSInteger status = [HSQuickTimeMovieHelper convertMovie:_outputMovie frameSize:[self movieFrameSize] ofType:movieType toFile:outputPath progressCallback:(void *)HSQTMovieExporterConversionProgress sender:self];
            succeeded = (status == 0);
            if (succeeded) {
                wrapper = [[NSFileWrapper alloc] initWithPath:outputPath];
                [[NSFileManager defaultManager] removeItemAtPath:outputPath error:NULL];
                [self notifyExportProgressDidChangeWithProgress:100.0];
            }
        }
    }
    [self cleanupMovieAfterExport];
    [_exportRepresentation autorelease];
    _exportRepresentation = succeeded ? wrapper : nil;
    if (succeeded) {
        [self notifyExportDidEnd];
    } else if (_shouldTerminateExport) {
        [self notifyExportDidTerminate];
    } else {
        if (exportError == nil) {
            exportError = (movieError != nil) ? [HSError errorWithError:movieError] : [HSError errorWithHSCode:0x5025];
        }
        [self notifyExportErrorInProgress:exportError];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00256ef1 @ 00256ef1, 4567 bytes * /

BOOL FUN_00256ef1(HSQTMovieExporter *self,SEL _cmd,id buildMovieContent,double inProgressRange,
                 id *error)

{
  uint uVar1;
  bool bVar2;
  undefined *self_00;
  undefined4 uVar3;
  id *ppvVar4;
  HSQTMovieExporter *pHVar5;
  double *pdVar6;
  int iVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  double *pdVar14;
  double *pdVar15;
  longdouble lVar16;
  longdouble lVar17;
  double dVar18;
  double dVar19;
  double dVar20;
  double dVar21;
  double dVar22;
  double dVar23;
  double dVar24;
  double dVar25;
  double local_214;
  undefined1 local_1ec [8];
  ushort uStack_1e4;
  double local_1b4;
  double local_194;
  HSQTMovieExporter *local_fc;
  id local_f8;
  double local_f4;
  undefined4 local_e8;
  id local_e4;
  id local_e0;
  id local_dc;
  char local_d5;
  int local_d4;
  int local_d0;
  int local_cc;
  int local_c8;
  int local_c4;
  int local_c0;
  int local_bc;
  int local_b8;
  int local_b4;
  int local_b0;
  int local_ac;
  int local_a8;
  int local_a4;
  int local_a0;
  int local_9c;
  int local_98;
  undefined4 local_94;
  int local_90;
  int local_8c;
  int local_88;
  int local_84 [23];
  id *local_28;
  double local_24;
  id local_18;
  HSQTMovieExporter *local_14;
  
  pdVar15 = (double *)&stack0xfffffd94;
  local_14 = self;
  local_18 = buildMovieContent;
  local_24 = inProgressRange;
  local_28 = error;
  local_d5 = '\x01';
  local_dc = (id)0x0;
  local_e0 = (id)0x0;
  local_e4 = (id)0x0;
  _objc_exception_try_enter();
  iVar7 = __setjmp(local_84);
  if (iVar7 == 0) {
    pvVar8 = _objc_msgSend(local_14,sel_dataSource);
    pvVar8 = _objc_msgSend(pvVar8,sel_exportedCardIndexesForExporter_onlySelected_);
    pvVar9 = _objc_msgSend(pvVar8,sel_count);
    if (pvVar9 == (id)0x0) {
      dVar18 = 1.0;
    }
    else {
      pvVar9 = _objc_msgSend(pvVar8,sel_count);
      dVar18 = 1.0 / ((double)(ZEXT48(pvVar9) | 0x4330000000000000) - 4503599627370496.0);
    }
    pHVar5 = local_14;
    dVar18 = local_24 * dVar18;
    local_e8 = 0;
    if (pvVar8 == (id)0x0) {
      pvVar9 = (id)0x7fffffff;
    }
    else {
      pvVar9 = _objc_msgSend(pvVar8,sel_firstIndex);
    }
    pHVar5->_currentImageIndex = (uint)pvVar9;
    local_194 = 0.0;
LAB_00257f53:
    if ((local_14->_currentImageIndex == 0x7fffffff) ||
       (((local_14->super)._shouldTerminateExport & 1) != 0)) goto LAB_00257f74;
    *(undefined **)((int)pdVar15 + 4) = sel_release;
    *(id *)pdVar15 = local_dc;
    *(undefined4 *)((int)pdVar15 + -4) = 0x257137;
    _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_new;
    *(undefined **)pdVar15 = cls_NSAutoreleasePool;
    *(undefined4 *)((int)pdVar15 + -4) = 0x25714f;
    local_dc = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_release;
    *(id *)pdVar15 = local_e0;
    *(undefined4 *)((int)pdVar15 + -4) = 0x25716d;
    _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_dataSource;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(undefined4 *)((int)pdVar15 + -4) = 0x257182;
    pvVar9 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    uVar1 = local_14->_currentImageIndex;
    *(HSQTMovieExporter **)((int)pdVar15 + 0xc) = local_14;
    *(uint *)(pdVar15 + 1) = uVar1;
    *(undefined **)((int)pdVar15 + 4) = sel_moviesWithPropertiesOnCardAtIndex_forExporter_;
    *(id *)pdVar15 = pvVar9;
    *(undefined4 *)((int)pdVar15 + -4) = 0x2571a5;
    pvVar9 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_retain;
    *(id *)pdVar15 = pvVar9;
    *(undefined4 *)((int)pdVar15 + -4) = 0x2571b7;
    local_e0 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_release;
    *(id *)pdVar15 = local_e4;
    *(undefined4 *)((int)pdVar15 + -4) = 0x2571d5;
    _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_dataSource;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(undefined4 *)((int)pdVar15 + -4) = 0x2571ea;
    pvVar9 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    uVar1 = local_14->_currentImageIndex;
    *(HSQTMovieExporter **)((int)pdVar15 + 0xc) = local_14;
    *(uint *)(pdVar15 + 1) = uVar1;
    *(undefined **)((int)pdVar15 + 4) = sel_soundsWithPropertiesOnCardAtIndex_forExporter_;
    *(id *)pdVar15 = pvVar9;
    *(undefined4 *)((int)pdVar15 + -4) = 0x25720d;
    pvVar9 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_retain;
    *(id *)pdVar15 = pvVar9;
    *(undefined4 *)((int)pdVar15 + -4) = 0x25721f;
    local_e4 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(id *)(pdVar15 + 1) = local_e4;
    *(undefined **)((int)pdVar15 + 4) = sel_mediasFromDictionaries_runOnStart_;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(int *)((int)pdVar15 + 0xc) = 1;
    *(undefined4 *)((int)pdVar15 + -4) = 0x25724c;
    pvVar9 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(id *)(pdVar15 + 1) = local_e4;
    *(undefined **)((int)pdVar15 + 4) = sel_mediasFromDictionaries_runOnStart_;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(int *)((int)pdVar15 + 0xc) = 0;
    *(undefined4 *)((int)pdVar15 + -4) = 0x25727b;
    pvVar10 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(id *)(pdVar15 + 1) = pvVar9;
    *(undefined **)((int)pdVar15 + 4) = sel_longestPlayTimeOfMedia_;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(undefined4 *)((int)pdVar15 + -4) = 0x25729c;
    dVar19 = _objc_msgSend_fpret(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(id *)(pdVar15 + 1) = pvVar10;
    *(undefined **)((int)pdVar15 + 4) = sel_longestPlayTimeOfMedia_;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(undefined4 *)((int)pdVar15 + -4) = 0x2572bb;
    dVar20 = _objc_msgSend_fpret(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(uint *)(pdVar15 + 1) = local_14->_currentImageIndex;
    *(undefined **)((int)pdVar15 + 4) = sel_transitionTimeAfterImageAtIndex_;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(undefined4 *)((int)pdVar15 + -4) = 0x2572e0;
    dVar21 = _objc_msgSend_fpret(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_dataSource;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(undefined4 *)((int)pdVar15 + -4) = 0x2572fb;
    pvVar11 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_timeIntervalBetweenFrames;
    *(id *)pdVar15 = pvVar11;
    *(undefined4 *)((int)pdVar15 + -4) = 0x25730d;
    dVar22 = _objc_msgSend_fpret(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_dataSource;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(undefined4 *)((int)pdVar15 + -4) = 0x257328;
    pvVar11 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(uint *)(pdVar15 + 1) = local_14->_currentImageIndex;
    *(undefined **)((int)pdVar15 + 4) = sel_timeDelayOnArriveOnCardAtIndex_;
    *(id *)pdVar15 = pvVar11;
    *(undefined4 *)((int)pdVar15 + -4) = 0x257344;
    dVar23 = _objc_msgSend_fpret(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *(undefined **)((int)pdVar15 + 4) = sel_count;
    *(id *)pdVar15 = local_e0;
    local_194 = local_194 + dVar23;
    *(undefined4 *)((int)pdVar15 + -4) = 0x2573b6;
    pvVar11 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    if (pvVar11 == (id)0x0) {
      *(undefined **)((int)pdVar15 + 4) = sel_count;
      *(id *)pdVar15 = pvVar10;
      *(undefined4 *)((int)pdVar15 + -4) = 0x257b8d;
      pvVar11 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
      if (pvVar11 == (id)0x0) {
        pdVar15[1] = dVar22 - dVar19;
        *(int *)((int)pdVar15 + 4) = 0;
        *(undefined4 *)pdVar15 = 0;
        *(undefined4 *)((int)pdVar15 + -4) = 0x257c07;
        lVar16 = (longdouble)_fmax();
      }
      else {
        pdVar15[1] = dVar22 - (dVar19 + dVar23);
        *(int *)((int)pdVar15 + 4) = 0x3ff00000;
        *(undefined4 *)pdVar15 = 0;
        *(undefined4 *)((int)pdVar15 + -4) = 0x257bcd;
        lVar16 = (longdouble)_fmax();
      }
      *(undefined **)((int)pdVar15 + 4) = sel_exportFPS;
      *(HSQTMovieExporter **)pdVar15 = local_14;
      local_1b4 = dVar19 + (double)lVar16;
      iVar7 = (int)(local_1b4 * 600.0);
      *(undefined4 *)((int)pdVar15 + -4) = 0x257c5a;
      dVar22 = _objc_msgSend_fpret(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
      pHVar5 = local_14;
      pvVar12 = local_18;
      *(int *)((int)pdVar15 + 4) = iVar7;
      *(int **)pdVar15 = &local_a4;
      *(int *)(pdVar15 + 1) = iVar7 >> 0x1f;
      *(int *)((int)pdVar15 + 0xc) = 600;
      dVar22 = dVar18 / ((dVar23 + dVar19 + (double)lVar16 + dVar20 + dVar21) * dVar22);
      *(undefined4 *)((int)pdVar15 + -4) = 0x257cd7;
      _QTMakeTime();
      pdVar15[3] = dVar22;
      *(id *)((int)pdVar15 + 0x14) = pvVar12;
      *(int *)(pdVar15 + 2) = local_98;
      *(int *)((int)pdVar15 + 0xc) = local_9c;
      *(int *)(pdVar15 + 1) = local_a0;
      *(int *)((int)pdVar15 + 4) = local_a4;
      *(undefined **)pdVar15 = sel_addImageWithDuration_inMovie_withProgressStep_;
      *(HSQTMovieExporter **)((int)pdVar15 + -4) = pHVar5;
      *(undefined4 *)(pdVar15 + -1) = 0x257d4a;
      _objc_msgSend(*(id *)((int)pdVar15 + -4),*(SEL *)pdVar15);
      pdVar15[1] = local_194;
      *(undefined4 **)((int)pdVar15 + 0x1c) = &local_e8;
      *(double *)((int)pdVar15 + 0x14) = dVar22;
      *(id *)(pdVar15 + 2) = local_18;
      *(id *)((int)pdVar15 + 4) = pvVar9;
      *(undefined **)pdVar15 = sel_addSounds_atTime_inMovie_withProgressStep_backgroundSounds_;
      *(HSQTMovieExporter **)((int)pdVar15 + -4) = local_14;
      local_1b4 = local_1b4 + local_194;
      *(undefined4 *)(pdVar15 + -1) = 0x257daa;
      _objc_msgSend(*(id *)((int)pdVar15 + -4),*(SEL *)pdVar15);
      pHVar5 = local_14;
      pvVar9 = local_18;
      pdVar14 = (double *)((int)pdVar15 + -4);
      if (((local_14->super)._shouldTerminateExport & 1) != 0) {
LAB_0025710a:
        pdVar15 = pdVar14;
        local_194 = local_1b4;
LAB_00257f74:
        uVar3 = local_e8;
        if (((local_14->super)._shouldTerminateExport & 1) == 0) {
          *(undefined **)((int)pdVar15 + 4) = sel_count;
          *(undefined4 *)pdVar15 = uVar3;
          *(undefined4 *)((int)pdVar15 + -4) = 0x257f95;
          pvVar8 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
          uVar3 = local_e8;
          if (pvVar8 != (id)0x0) {
            local_fc = local_14;
            local_f8 = local_18;
            local_f4 = local_194;
            *(HSQTMovieExporter ***)((int)pdVar15 + 8) = &local_fc;
            *(code **)((int)pdVar15 + 4) = FUN_0025a411;
            *(undefined4 *)pdVar15 = uVar3;
            *(undefined4 *)((int)pdVar15 + -4) = 0x257fdd;
            _CFDictionaryApplyFunction();
          }
        }
        uVar3 = local_e8;
        *(undefined **)((int)pdVar15 + 4) = sel_release;
        *(undefined4 *)pdVar15 = uVar3;
        *(undefined4 *)((int)pdVar15 + -4) = 0x257ff5;
        _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
        if ((local_d5 == '\0') || (((local_14->super)._shouldTerminateExport & 1) != 0)) {
          local_d5 = '\0';
        }
        else {
          local_d5 = '\x01';
        }
        goto LAB_00258025;
      }
      pdVar6 = (double *)((int)pdVar15 + -4);
      local_194 = local_1b4;
      if (pvVar11 != (id)0x0) {
        *(int *)pdVar15 = (int)(dVar20 * 600.0);
        *(undefined4 **)((int)pdVar15 + -4) = &local_94;
        *(int *)((int)pdVar15 + 4) = (int)(dVar20 * 600.0) >> 0x1f;
        *(int *)(pdVar15 + 1) = 600;
        *(undefined4 *)(pdVar15 + -1) = 0x257e0b;
        _QTMakeTime();
        *(double *)((int)pdVar15 + 0x14) = dVar22;
        *(id *)(pdVar15 + 2) = pvVar9;
        *(int *)((int)pdVar15 + 0xc) = local_88;
        *(int *)(pdVar15 + 1) = local_8c;
        *(int *)((int)pdVar15 + 4) = local_90;
        *(undefined4 *)pdVar15 = local_94;
        *(undefined **)((int)pdVar15 + -4) = sel_addImageWithDuration_inMovie_withProgressStep_;
        *(HSQTMovieExporter **)(pdVar15 + -1) = pHVar5;
        *(undefined4 *)((int)pdVar15 + -0xc) = 0x257e7e;
        _objc_msgSend(*(id *)(pdVar15 + -1),*(SEL *)((int)pdVar15 + -4));
        *(double *)((int)pdVar15 + 4) = local_1b4;
        *(undefined4 **)(pdVar15 + 3) = &local_e8;
        pdVar15[2] = dVar22;
        *(id *)((int)pdVar15 + 0xc) = local_18;
        *(id *)pdVar15 = pvVar10;
        *(undefined **)((int)pdVar15 + -4) =
             sel_addSounds_atTime_inMovie_withProgressStep_backgroundSounds_;
        *(HSQTMovieExporter **)(pdVar15 + -1) = local_14;
        local_1b4 = local_1b4 + dVar20;
        *(undefined4 *)((int)pdVar15 + -0xc) = 0x257ed4;
        _objc_msgSend(*(id *)(pdVar15 + -1),*(SEL *)((int)pdVar15 + -4));
        pdVar14 = pdVar15 + -1;
        pdVar6 = pdVar15 + -1;
        local_194 = local_1b4;
        if (((local_14->super)._shouldTerminateExport & 1) != 0) goto LAB_0025710a;
      }
      pdVar15 = pdVar6;
      _local_1ec = (unkuint10)stack0xfffffe18 << 0x20;
    }
    else {
      *(id *)(pdVar15 + 1) = local_e0;
      *(undefined **)((int)pdVar15 + 4) = sel_mediasFromDictionaries_runOnStart_;
      *(HSQTMovieExporter **)pdVar15 = local_14;
      *(int *)((int)pdVar15 + 0xc) = 1;
      *(undefined4 *)((int)pdVar15 + -4) = 0x257425;
      pvVar11 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
      *(id *)(pdVar15 + 1) = local_e0;
      *(undefined **)((int)pdVar15 + 4) = sel_mediasFromDictionaries_runOnStart_;
      *(HSQTMovieExporter **)pdVar15 = local_14;
      *(int *)((int)pdVar15 + 0xc) = 0;
      *(undefined4 *)((int)pdVar15 + -4) = 0x257452;
      pvVar12 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
      *(undefined **)((int)pdVar15 + 4) = sel_count;
      *(id *)pdVar15 = pvVar12;
      *(undefined4 *)((int)pdVar15 + -4) = 0x25746a;
      pvVar13 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
      if (pvVar13 == (id)0x0) {
        *(undefined **)((int)pdVar15 + 4) = sel_count;
        *(id *)pdVar15 = pvVar10;
        *(undefined4 *)((int)pdVar15 + -4) = 0x25748f;
        pvVar13 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
        if (pvVar13 != (id)0x0) goto LAB_0025746e;
        bVar2 = true;
      }
      else {
LAB_0025746e:
        bVar2 = false;
      }
      *(id *)(pdVar15 + 1) = pvVar11;
      *(undefined **)((int)pdVar15 + 4) = sel_longestPlayTimeOfMedia_;
      *(HSQTMovieExporter **)pdVar15 = local_14;
      *(undefined4 *)((int)pdVar15 + -4) = 0x2574b9;
      dVar24 = _objc_msgSend_fpret(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
      if (bVar2) {
        pdVar15[1] = dVar19;
        *pdVar15 = dVar24;
        *(undefined4 *)((int)pdVar15 + -4) = 0x2575b1;
        lVar16 = (longdouble)_fmax();
        local_214 = (double)lVar16;
        pdVar15[1] = dVar22 - local_214;
        *(int *)((int)pdVar15 + 4) = 0;
        *(undefined4 *)pdVar15 = 0;
        *(undefined4 *)((int)pdVar15 + -4) = 0x2575ed;
        lVar16 = (longdouble)_fmax();
        _local_1ec = (unkuint10)uStack_1e4 << 0x40;
      }
      else {
        *(id *)(pdVar15 + 1) = pvVar12;
        *(undefined **)((int)pdVar15 + 4) = sel_longestPlayTimeOfMedia_;
        *(HSQTMovieExporter **)pdVar15 = local_14;
        *(undefined4 *)((int)pdVar15 + -4) = 0x2574fb;
        dVar25 = _objc_msgSend_fpret(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
        pdVar15[1] = dVar19;
        *pdVar15 = dVar24;
        *(undefined4 *)((int)pdVar15 + -4) = 0x257521;
        lVar16 = (longdouble)_fmax();
        local_214 = (double)lVar16;
        pdVar15[1] = dVar22 - (local_214 + dVar23);
        *(int *)((int)pdVar15 + 4) = 0x3ff00000;
        *(undefined4 *)pdVar15 = 0;
        *(undefined4 *)((int)pdVar15 + -4) = 0x257571;
        lVar16 = (longdouble)_fmax();
        uStack_1e4 = (ushort)((unkuint10)(longdouble)dVar25 >> 0x40);
        _local_1ec = CONCAT28(uStack_1e4,dVar25);
      }
      dVar25 = (double)lVar16;
      pdVar15[1] = dVar20;
      *pdVar15 = (double)local_1ec;
      *(undefined4 *)((int)pdVar15 + -4) = 0x25762f;
      lVar16 = (longdouble)_fmax();
      *(undefined **)((int)pdVar15 + 4) = sel_exportFPS;
      *(HSQTMovieExporter **)pdVar15 = local_14;
      *(undefined4 *)((int)pdVar15 + -4) = 0x25764a;
      dVar22 = _objc_msgSend_fpret(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
      dVar22 = dVar18 / ((dVar23 + local_214 + dVar25 + (double)lVar16 + dVar21) * dVar22);
      pdVar14 = pdVar15;
      if (0.0 < dVar23) {
        *(undefined **)((int)pdVar15 + 4) = sel_dataSource;
        *(HSQTMovieExporter **)pdVar15 = local_14;
        *(undefined4 *)((int)pdVar15 + -4) = 0x2576c3;
        pvVar13 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
        uVar1 = local_14->_currentImageIndex;
        *(HSQTMovieExporter **)(pdVar15 + 3) = local_14;
        *(uint *)((int)pdVar15 + 0x14) = uVar1;
        *(undefined **)((int)pdVar15 + 4) =
             sel_setCurrentTimeForMovies_runOnStart_onCardAtIndex_forExporter_;
        *(id *)pdVar15 = pvVar13;
        *(int *)((int)pdVar15 + 0xc) = 0;
        *(int *)(pdVar15 + 1) = 0;
        *(int *)(pdVar15 + 2) = 1;
        *(undefined4 *)((int)pdVar15 + -4) = 0x2576fe;
        _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
        pHVar5 = local_14;
        pvVar13 = local_18;
        *(double *)((int)pdVar15 + 4) = dVar23;
        *(int **)pdVar15 = &local_d4;
        *(undefined4 *)((int)pdVar15 + -4) = 0x25772c;
        _QTMakeTimeWithTimeInterval();
        pdVar14 = (double *)((int)pdVar15 + -4);
        pdVar15[3] = dVar22;
        *(id *)((int)pdVar15 + 0x14) = pvVar13;
        *(int *)(pdVar15 + 2) = local_c8;
        *(int *)((int)pdVar15 + 0xc) = local_cc;
        *(int *)(pdVar15 + 1) = local_d0;
        *(int *)((int)pdVar15 + 4) = local_d4;
        *(undefined **)pdVar15 = sel_addImageWithDuration_inMovie_withProgressStep_;
        *(HSQTMovieExporter **)((int)pdVar15 + -4) = pHVar5;
        *(undefined4 *)(pdVar15 + -1) = 0x25779f;
        _objc_msgSend(*(id *)((int)pdVar15 + -4),*(SEL *)pdVar15);
      }
      *(double *)((int)pdVar14 + 0x24) = dVar22;
      *(id *)((int)pdVar14 + 0x20) = local_18;
      *(double *)((int)pdVar14 + 0x14) = local_194;
      *(double *)((int)pdVar14 + 0xc) = dVar24;
      *(id *)((int)pdVar14 + 8) = pvVar11;
      *(undefined **)((int)pdVar14 + 4) =
           sel_addMovies_withLongestPlayTime_atTime_runOnStart_inMovie_withProgressStep_;
      *(HSQTMovieExporter **)pdVar14 = local_14;
      *(int *)((int)pdVar14 + 0x1c) = 1;
      *(undefined4 *)((int)pdVar14 + -4) = 0x2577f7;
      _objc_msgSend(*(id *)pdVar14,*(SEL *)((int)pdVar14 + 4));
      pHVar5 = local_14;
      pvVar11 = local_18;
      if ((0.0 < dVar25) || (pdVar15 = pdVar14, dVar24 < dVar19)) {
        *(double *)((int)pdVar14 + 8) = dVar19 - dVar24;
        *(int *)((int)pdVar14 + 4) = 0;
        *(undefined4 *)pdVar14 = 0;
        *(undefined4 *)((int)pdVar14 + -4) = 0x25785b;
        lVar17 = (longdouble)_fmax();
        iVar7 = (int)(((double)lVar17 + dVar25) * 600.0);
        *(int *)((int)pdVar14 + 4) = iVar7;
        *(int **)pdVar14 = &local_c4;
        *(int *)((int)pdVar14 + 8) = iVar7 >> 0x1f;
        *(int *)((int)pdVar14 + 0xc) = 600;
        *(undefined4 *)((int)pdVar14 + -4) = 0x25789e;
        _QTMakeTime();
        pdVar15 = (double *)((int)pdVar14 + -4);
        *(double *)((int)pdVar14 + 0x18) = dVar22;
        *(id *)((int)pdVar14 + 0x14) = pvVar11;
        *(int *)((int)pdVar14 + 0x10) = local_b8;
        *(int *)((int)pdVar14 + 0xc) = local_bc;
        *(int *)((int)pdVar14 + 8) = local_c0;
        *(int *)((int)pdVar14 + 4) = local_c4;
        *(undefined **)pdVar14 = sel_addImageWithDuration_inMovie_withProgressStep_;
        *(HSQTMovieExporter **)((int)pdVar14 + -4) = pHVar5;
        *(undefined4 *)((int)pdVar14 + -8) = 0x257911;
        _objc_msgSend(*(id *)((int)pdVar14 + -4),*(SEL *)pdVar14);
      }
      *(double *)((int)pdVar15 + 0xc) = local_194;
      *(undefined4 **)((int)pdVar15 + 0x20) = &local_e8;
      *(double *)((int)pdVar15 + 0x18) = dVar22;
      *(id *)((int)pdVar15 + 0x14) = local_18;
      *(id *)((int)pdVar15 + 8) = pvVar9;
      *(undefined **)((int)pdVar15 + 4) =
           sel_addSounds_atTime_inMovie_withProgressStep_backgroundSounds_;
      *(HSQTMovieExporter **)pdVar15 = local_14;
      local_194 = local_194 + local_214 + dVar25;
      *(undefined4 *)((int)pdVar15 + -4) = 0x257979;
      _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
      if (((local_14->super)._shouldTerminateExport & 1) != 0) goto LAB_00257f74;
      if (!bVar2) {
        *(double *)((int)pdVar15 + 0x24) = dVar22;
        *(id *)((int)pdVar15 + 0x20) = local_18;
        *(double *)((int)pdVar15 + 0x14) = local_194;
        *(undefined1 (*) [8])((int)pdVar15 + 0xc) = local_1ec;
        *(id *)((int)pdVar15 + 8) = pvVar12;
        *(undefined **)((int)pdVar15 + 4) =
             sel_addMovies_withLongestPlayTime_atTime_runOnStart_inMovie_withProgressStep_;
        *(HSQTMovieExporter **)pdVar15 = local_14;
        *(int *)((int)pdVar15 + 0x1c) = 0;
        *(undefined4 *)((int)pdVar15 + -4) = 0x2579eb;
        _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
        pHVar5 = local_14;
        pvVar9 = local_18;
        if ((double)local_1ec < dVar20) {
          *(double *)((int)pdVar15 + 8) = dVar20 - (double)local_1ec;
          *(int *)((int)pdVar15 + 4) = 0;
          *(undefined4 *)pdVar15 = 0;
          *(undefined4 *)((int)pdVar15 + -4) = 0x257a35;
          lVar17 = (longdouble)_fmax();
          *(int *)((int)pdVar15 + 4) = (int)((double)lVar17 * 600.0);
          *(int **)pdVar15 = &local_b4;
          *(int *)((int)pdVar15 + 8) = (int)((double)lVar17 * 600.0) >> 0x1f;
          *(int *)((int)pdVar15 + 0xc) = 600;
          *(undefined4 *)((int)pdVar15 + -4) = 0x257a70;
          _QTMakeTime();
          *(double *)((int)pdVar15 + 0x18) = dVar22;
          *(id *)((int)pdVar15 + 0x14) = pvVar9;
          *(int *)((int)pdVar15 + 0x10) = local_a8;
          *(int *)((int)pdVar15 + 0xc) = local_ac;
          *(int *)((int)pdVar15 + 8) = local_b0;
          *(int *)((int)pdVar15 + 4) = local_b4;
          *(undefined **)pdVar15 = sel_addImageWithDuration_inMovie_withProgressStep_;
          *(HSQTMovieExporter **)((int)pdVar15 + -4) = pHVar5;
          *(undefined4 *)((int)pdVar15 + -8) = 0x257ae3;
          _objc_msgSend(*(id *)((int)pdVar15 + -4),*(SEL *)pdVar15);
          pdVar15 = (double *)((int)pdVar15 + -4);
        }
        *(double *)((int)pdVar15 + 0xc) = local_194;
        *(undefined4 **)((int)pdVar15 + 0x20) = &local_e8;
        *(double *)((int)pdVar15 + 0x18) = dVar22;
        *(id *)((int)pdVar15 + 0x14) = local_18;
        *(id *)((int)pdVar15 + 8) = pvVar10;
        *(undefined **)((int)pdVar15 + 4) =
             sel_addSounds_atTime_inMovie_withProgressStep_backgroundSounds_;
        *(HSQTMovieExporter **)pdVar15 = local_14;
        local_194 = (double)lVar16 + local_194;
        *(undefined4 *)((int)pdVar15 + -4) = 0x257b43;
        _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
        if (((local_14->super)._shouldTerminateExport & 1) != 0) goto LAB_00257f74;
      }
    }
    *(double *)((int)pdVar15 + 0xc) = dVar22;
    *(id *)((int)pdVar15 + 8) = local_18;
    *(undefined **)((int)pdVar15 + 4) = sel_addTransitionInMovie_withProgressStep_;
    *(HSQTMovieExporter **)pdVar15 = local_14;
    *(undefined4 *)((int)pdVar15 + -4) = 0x257f1b;
    _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    pHVar5 = local_14;
    *(uint *)((int)pdVar15 + 8) = local_14->_currentImageIndex;
    *(undefined **)((int)pdVar15 + 4) = sel_indexGreaterThanIndex_;
    *(id *)pdVar15 = pvVar8;
    *(undefined4 *)((int)pdVar15 + -4) = 0x257f40;
    pvVar9 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    pHVar5->_currentImageIndex = (uint)pvVar9;
    local_194 = local_194 + dVar21;
    goto LAB_00257f53;
  }
  pvVar8 = (id)_objc_exception_extract();
  _objc_exception_try_enter();
  iVar7 = __setjmp(local_84);
  if (iVar7 == 0) {
    iVar7 = _objc_exception_match();
    ppvVar4 = local_28;
    self_00 = cls_HSError;
    if (iVar7 != 0) {
      if (local_28 != (id *)0x0) {
        _objc_msgSend(pvVar8,sel_extraStatusError);
        pvVar8 = _objc_msgSend(self_00,sel_errorWithDomain_code_userInfo_);
        *ppvVar4 = pvVar8;
      }
      local_d5 = '\0';
      pdVar15 = (double *)&stack0xfffffd94;
      goto LAB_00258025;
    }
    _objc_exception_try_exit();
  }
  else {
    pvVar8 = (id)_objc_exception_extract();
  }
  pdVar15 = (double *)&stack0xfffffd94;
  if (pvVar8 != (id)0x0) {
                    /* WARNING: Subroutine does not return * /
    _objc_exception_throw();
  }
LAB_00258025:
  *(int **)pdVar15 = local_84;
  *(undefined4 *)((int)pdVar15 + -4) = 0x258030;
  _objc_exception_try_exit();
  pvVar8 = local_e4;
  *(undefined **)((int)pdVar15 + 4) = sel_release;
  *(id *)pdVar15 = pvVar8;
  *(undefined4 *)((int)pdVar15 + -4) = 0x258052;
  _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
  pvVar8 = local_e0;
  *(undefined **)((int)pdVar15 + 4) = sel_release;
  *(id *)pdVar15 = pvVar8;
  *(undefined4 *)((int)pdVar15 + -4) = 0x25806a;
  _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
  pvVar8 = local_dc;
  *(undefined **)((int)pdVar15 + 4) = sel_release;
  *(id *)pdVar15 = pvVar8;
  *(undefined4 *)((int)pdVar15 + -4) = 0x258082;
  _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
  ppvVar4 = local_28;
  if ((local_d5 == '\0') && (local_28 != (id *)0x0)) {
    *(undefined **)((int)pdVar15 + 4) = sel_errorWithHSCode_;
    *(undefined **)pdVar15 = cls_HSError;
    *(int *)((int)pdVar15 + 8) = 0x5025;
    *(undefined4 *)((int)pdVar15 + -4) = 0x2580b4;
    pvVar8 = _objc_msgSend(*(id *)pdVar15,*(SEL *)((int)pdVar15 + 4));
    *ppvVar4 = pvVar8;
  }
  return local_d5;
}

*/
- (BOOL)buildMovieContent:(id)aContent inProgressRange:(double)aRange error:(id *)aError
{
    BOOL result = YES;
    NSAutoreleasePool *pool = nil;
    id movies = nil;
    id sounds = nil;
    NSMutableDictionary *backgroundSounds = nil;
    @try {
        NSIndexSet *indexes = [[self dataSource] exportedCardIndexesForExporter:self onlySelected:NO];
        double cardStep = aRange * (([indexes count] == 0) ? 1.0 : 1.0 / (double)[indexes count]);
        _currentImageIndex = (indexes != nil) ? [indexes firstIndex] : NSNotFound;
        double time = 0.0;
        while (_currentImageIndex != NSNotFound && !_shouldTerminateExport) {
            [pool release];
            pool = [NSAutoreleasePool new];
            [movies release];
            movies = [[[self dataSource] moviesWithPropertiesOnCardAtIndex:_currentImageIndex forExporter:self] retain];
            [sounds release];
            sounds = [[[self dataSource] soundsWithPropertiesOnCardAtIndex:_currentImageIndex forExporter:self] retain];
            NSArray *startSounds = [self mediasFromDictionaries:sounds runOnStart:YES];
            NSArray *endSounds = [self mediasFromDictionaries:sounds runOnStart:NO];
            double startSoundsTime = [self longestPlayTimeOfMedia:startSounds];
            double endSoundsTime = [self longestPlayTimeOfMedia:endSounds];
            double transitionTime = [self transitionTimeAfterImageAtIndex:_currentImageIndex];
            double slideInterval = [[self dataSource] timeIntervalBetweenFrames];
            double arriveDelay = [[self dataSource] timeDelayOnArriveOnCardAtIndex:_currentImageIndex];
            double progressStep;
            time += arriveDelay;
            if ([movies count] == 0) {
                double hold = ([endSounds count] == 0) ? MAX(slideInterval - startSoundsTime, 0.0) : MAX(slideInterval - (startSoundsTime + arriveDelay), 1.0);
                double total = startSoundsTime + hold;
                progressStep = cardStep / ((arriveDelay + startSoundsTime + hold + endSoundsTime + transitionTime) * [self exportFPS]);
                [self addImageWithDuration:HSQTMovieExporterDurationFromSeconds(total) inMovie:aContent withProgressStep:progressStep];
                [self addSounds:startSounds atTime:time inMovie:aContent withProgressStep:progressStep backgroundSounds:&backgroundSounds];
                time += total;
                if (_shouldTerminateExport) {
                    break;
                }
                if ([endSounds count] != 0) {
                    [self addImageWithDuration:HSQTMovieExporterDurationFromSeconds(endSoundsTime) inMovie:aContent withProgressStep:progressStep];
                    [self addSounds:endSounds atTime:time inMovie:aContent withProgressStep:progressStep backgroundSounds:&backgroundSounds];
                    time += endSoundsTime;
                    if (_shouldTerminateExport) {
                        break;
                    }
                }
            } else {
                NSArray *startMovies = [self mediasFromDictionaries:movies runOnStart:YES];
                NSArray *endMovies = [self mediasFromDictionaries:movies runOnStart:NO];
                BOOL noEndMedia = ([endMovies count] == 0 && [endSounds count] == 0);
                double startMoviesTime = [self longestPlayTimeOfMedia:startMovies];
                double endMoviesTime = 0.0;
                double longest = MAX(startMoviesTime, startSoundsTime);
                double tail;
                if (noEndMedia) {
                    tail = MAX(slideInterval - longest, 0.0);
                } else {
                    endMoviesTime = [self longestPlayTimeOfMedia:endMovies];
                    tail = MAX(slideInterval - (longest + arriveDelay), 1.0);
                }
                double endTime = MAX(endSoundsTime, endMoviesTime);
                progressStep = cardStep / ((arriveDelay + longest + tail + endTime + transitionTime) * [self exportFPS]);
                if (arriveDelay > 0.0) {
                    [[self dataSource] setCurrentTimeForMovies:0.0 runOnStart:YES onCardAtIndex:_currentImageIndex forExporter:self];
                    QTTime delayTime = QTMakeTimeWithTimeInterval(arriveDelay);
                    struct HyperStudio_anon7 delay = { delayTime.timeValue, (int)delayTime.timeScale, (int)delayTime.flags };
                    [self addImageWithDuration:delay inMovie:aContent withProgressStep:progressStep];
                }
                [self addMovies:startMovies withLongestPlayTime:startMoviesTime atTime:time runOnStart:YES inMovie:aContent withProgressStep:progressStep];
                if (tail > 0.0 || startMoviesTime < startSoundsTime) {
                    [self addImageWithDuration:HSQTMovieExporterDurationFromSeconds(MAX(startSoundsTime - startMoviesTime, 0.0) + tail) inMovie:aContent withProgressStep:progressStep];
                }
                [self addSounds:startSounds atTime:time inMovie:aContent withProgressStep:progressStep backgroundSounds:&backgroundSounds];
                time += longest + tail;
                if (_shouldTerminateExport) {
                    break;
                }
                if (!noEndMedia) {
                    [self addMovies:endMovies withLongestPlayTime:endMoviesTime atTime:time runOnStart:NO inMovie:aContent withProgressStep:progressStep];
                    if (endMoviesTime < endSoundsTime) {
                        [self addImageWithDuration:HSQTMovieExporterDurationFromSeconds(MAX(endSoundsTime - endMoviesTime, 0.0)) inMovie:aContent withProgressStep:progressStep];
                    }
                    [self addSounds:endSounds atTime:time inMovie:aContent withProgressStep:progressStep backgroundSounds:&backgroundSounds];
                    time += endTime;
                    if (_shouldTerminateExport) {
                        break;
                    }
                }
            }
            [self addTransitionInMovie:aContent withProgressStep:progressStep];
            _currentImageIndex = [indexes indexGreaterThanIndex:_currentImageIndex];
            time += transitionTime;
        }
        if (!_shouldTerminateExport && [backgroundSounds count] != 0) {
            // Asynchronous sounds still playing at the end run until the end of the movie.
            for (id properties in backgroundSounds) {
                double start = [[backgroundSounds objectForKey:properties] doubleValue];
                [self addBackgroundSoundWithProperties:properties atTime:start withDuration:time - start inMovie:aContent];
            }
        }
        [backgroundSounds release];
        backgroundSounds = nil;
        result = result && !_shouldTerminateExport;
    }
    @catch (NSException *exception) {
        if (aError != NULL) {
            *aError = [HSError errorWithDomain:NSOSStatusErrorDomain code:[exception extraStatusError] userInfo:nil];
        }
        result = NO;
    }
    [backgroundSounds release];
    [sounds release];
    [movies release];
    [pool release];
    if (!result && aError != NULL) {
        *aError = [HSError errorWithHSCode:0x5025];
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002580c8 @ 002580c8, 383 bytes * /

double FUN_002580c8(HSQTMovieExporter *self,SEL _cmd,id longestTrackDurationForMovie)

{
  undefined *self_00;
  short sVar1;
  id self_01;
  id pvVar2;
  id pvVar3;
  int iVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  id pvVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *pcVar9;
  double local_2c;
  double local_24;
  
  pcVar8 = (cfstringStruct *)0x1;
  self_01 = _objc_msgSend(self,sel_allTracksOfTypes_count_forMovie_,&DAT_003426a0,1,
                          longestTrackDurationForMovie);
  pvVar2 = _objc_msgSend(self_01,sel_count);
  if (pvVar2 == (id)0x0) {
    local_24 = 0.0;
  }
  else {
    local_2c = 0.0;
    pvVar2 = (id)0x0;
    do {
      pvVar7 = pvVar2;
      pvVar3 = _objc_msgSend(self_01,sel_objectAtIndex_,pvVar2,pcVar8,longestTrackDurationForMovie);
      pvVar3 = _objc_msgSend(pvVar3,sel_quickTimeTrack);
      iVar4 = _GetTrackDuration(pvVar3);
      sVar1 = _GetMoviesError();
      self_00 = cls_NSException;
      if (sVar1 != 0) {
        pvVar7 = (id)(int)sVar1;
        uVar5 = _sel_getName(_cmd);
        uVar6 = _object_getClassName(self);
        pcVar9 = &cfstr_error__d_in___s__p___s_;
        pcVar8 = &cfstr_OSStatusError;
        _objc_msgSend(self_00,sel_extraRaiseError_name_format_,pvVar7,&cfstr_OSStatusError,
                      &cfstr_error__d_in___s__p___s_,pvVar7,uVar6,self,uVar5);
        longestTrackDurationForMovie = pcVar9;
      }
      pvVar2 = (id)((int)pvVar2 + 1);
      pvVar7 = _objc_msgSend(self_01,sel_count,pvVar7,pcVar8,longestTrackDurationForMovie);
      local_24 = (double)((float)iVar4 / 600.0);
      if ((double)((float)iVar4 / 600.0) <= local_2c) {
        local_24 = local_2c;
      }
      local_2c = local_24;
    } while (pvVar2 < pvVar7);
  }
  return local_24;
}

*/
- (double)longestTrackDurationForMovie:(id)aMovie
{
    double longest = 0.0;
    for (QTTrack *track in [self allTracksOfTypes:&sVideoMediaType count:1 forMovie:aMovie]) {
        // GetTrackDuration / 600 in the original (movie time scale).
        NSTimeInterval duration = 0.0;
        QTGetTimeInterval([[track attributeForKey:QTTrackRangeAttribute] QTTimeRangeValue].duration, &duration);
        if (duration > longest) {
            longest = duration;
        }
    }
    return longest;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00258247 @ 00258247, 782 bytes * /

void FUN_00258247(HSQTMovieExporter *self,SEL _cmd,id addTransitionInMovie,double withProgressStep)

{
  undefined *self_00;
  short sVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  double dVar7;
  double dVar8;
  undefined8 uVar9;
  cfstringStruct *pcVar10;
  int iVar11;
  double local_54;
  undefined4 local_24;
  cfstringStruct *local_20;
  int local_1c;
  undefined4 local_18;
  
  pvVar2 = _objc_msgSend(self,sel_dataSource);
  pvVar2 = _objc_msgSend(pvVar2,sel_hasTransitionAfterCardAtIndex_forExporter_);
  if ((char)pvVar2 != '\0') {
    dVar7 = _objc_msgSend_fpret(self,sel_exportFPS);
    _QTMakeTime(&local_24,(longlong)ROUND(600.0 / (float)dVar7),600);
    dVar7 = _objc_msgSend_fpret(self,sel_transitionTimeAfterImageAtIndex_,self->_currentImageIndex);
    dVar8 = _objc_msgSend_fpret(self,sel_exportFPS);
    local_54 = 0.0;
    do {
      iVar11 = 1;
      pvVar2 = _objc_msgSend(self,sel_transitionImageForTime_afterCardAtIndex_applyMovieFrameSize_,
                             local_54,self->_currentImageIndex,1);
      uVar9 = 0x1003426a0;
      pcVar10 = addTransitionInMovie;
      pvVar3 = _objc_msgSend(self,sel_allTracksOfTypes_count_forMovie_,&DAT_003426a0,1,
                             addTransitionInMovie);
      if (pvVar2 != (id)0x0) {
        pvVar4 = _objc_msgSend(pvVar3,sel_count,uVar9,pcVar10,iVar11);
        if (pvVar4 == (id)0x0) {
          pvVar4 = _objc_msgSend(self,sel_addImageCodecConfiguration,uVar9,pcVar10,iVar11);
          pvVar3 = addTransitionInMovie;
        }
        else {
          pvVar3 = _objc_msgSend(pvVar3,sel_objectAtIndex_,0,(int)((ulonglong)uVar9 >> 0x20),pcVar10
                                 ,iVar11);
          pvVar4 = _objc_msgSend(self,sel_addImageCodecConfiguration);
        }
        pcVar10 = local_20;
        iVar11 = local_1c;
        _objc_msgSend(pvVar3,sel_addImage_forDuration_withAttributes_,CONCAT44(local_24,pvVar2),
                      local_20,local_1c,local_18,pvVar4);
      }
      sVar1 = _GetMoviesError();
      self_00 = cls_NSException;
      if (sVar1 != 0) {
        iVar11 = (int)sVar1;
        uVar5 = _sel_getName(_cmd);
        uVar6 = _object_getClassName(self);
        pcVar10 = &cfstr_error__d_in___s__p___s_;
        _objc_msgSend(self_00,sel_extraRaiseError_name_format_,iVar11,&cfstr_OSStatusError,
                      &cfstr_error__d_in___s__p___s_,iVar11,uVar6,self,uVar5);
      }
      local_54 = local_54 + (double)(1.0 / (float)dVar8) / dVar7;
      _objc_msgSend(self,sel_notifyExportProgressDidChangeWithProgress_,withProgressStep,pcVar10,
                    iVar11);
    } while (local_54 < 1.0);
  }
  return;
}

*/
- (void)addTransitionInMovie:(id)aMovie withProgressStep:(double)aStep
{
    if (![[self dataSource] hasTransitionAfterCardAtIndex:_currentImageIndex forExporter:self]) {
        return;
    }
    QTTime frameTime = QTMakeTime((long long)llroundf(600.0f / (float)[self exportFPS]), 600);
    double transitionTime = [self transitionTimeAfterImageAtIndex:_currentImageIndex];
    double fps = [self exportFPS];
    double time = 0.0;
    do {
        NSImage *image = [self transitionImageForTime:time afterCardAtIndex:_currentImageIndex applyMovieFrameSize:YES];
        NSArray *videoTracks = [self allTracksOfTypes:&sVideoMediaType count:1 forMovie:aMovie];
        if (image != nil) {
            id target = ([videoTracks count] == 0) ? aMovie : [videoTracks objectAtIndex:0];
            [target addImage:image forDuration:frameTime withAttributes:[self addImageCodecConfiguration]];
        }
        time = time + (double)(1.0f / (float)fps) / transitionTime;
        [self notifyExportProgressDidChangeWithProgress:aStep];
    } while (time < 1.0);
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00258555 @ 00258555, 1030 bytes * /

void FUN_00258555(HSQTMovieExporter *self,SEL _cmd,id addMovies,double withLongestPlayTime,
                 double atTime,BOOL runOnStart,id inMovie,double withProgressStep)

{
  uint uVar1;
  short sVar2;
  id pvVar3;
  undefined4 uVar4;
  id self_00;
  undefined *puVar5;
  id pvVar6;
  int iVar7;
  id pvVar8;
  double dVar9;
  double dVar10;
  double dVar11;
  longlong lVar12;
  cfstringStruct *pcVar13;
  undefined4 uVar14;
  cfstringStruct *pcVar15;
  id local_50;
  double local_4c;
  undefined2 uStack_44;
  int local_24;
  cfstringStruct *local_20;
  cfstringStruct *local_1c;
  
  pvVar3 = _objc_msgSend(addMovies,sel_count);
  if (pvVar3 != (id)0x0) {
    dVar10 = _objc_msgSend_fpret(self,sel_exportFPS);
    dVar11 = _objc_msgSend_fpret(self,sel_exportFPS);
    lVar12 = (longlong)ROUND(600.0 / (float)dVar11);
    pcVar15 = (cfstringStruct *)0x258;
    _QTMakeTime(&local_24,lVar12,600);
    uStack_44 = (undefined2)((unkuint10)(longdouble)dVar10 >> 0x40);
    _local_4c = CONCAT28(uStack_44,0x10000000000000);
    while( true ) {
      if ((local_4c != 0.0) || (NAN(local_4c))) {
        dVar11 = ABS(local_4c);
      }
      else {
        dVar11 = 1.0;
      }
      if ((withLongestPlayTime != 0.0) || (NAN(withLongestPlayTime))) {
        dVar9 = ABS(withLongestPlayTime);
      }
      else {
        dVar9 = 1.0;
      }
      if (dVar9 <= dVar11) {
        dVar9 = dVar11;
      }
      uVar1 = (self->super)._shouldTerminateExport;
      if (((ABS(local_4c - withLongestPlayTime) <= dVar9 * 1e-05) ||
          (withLongestPlayTime <= local_4c)) || ((uVar1 & 1) != 0)) break;
      pvVar3 = _objc_msgSend(cls_NSAutoreleasePool,sel_new,(int)lVar12,
                             (int)((ulonglong)lVar12 >> 0x20),pcVar15);
      pvVar6 = _objc_msgSend(self,sel_dataSource);
      _objc_msgSend(pvVar6,sel_setCurrentTimeForMovies_runOnStart_onCardAtIndex_forExporter_,
                    (int)_local_4c,(int)((unkuint10)_local_4c >> 0x20),(int)runOnStart,
                    self->_currentImageIndex,self);
      iVar7 = local_24;
      pcVar13 = local_20;
      pcVar15 = local_1c;
      _objc_msgSend(self,sel_addImageWithDuration_inMovie_withProgressStep_);
      _objc_msgSend(pvVar3,sel_release);
      sVar2 = _GetMoviesError();
      puVar5 = cls_NSException;
      if (sVar2 != 0) {
        iVar7 = (int)sVar2;
        uVar14 = _sel_getName(_cmd);
        uVar4 = _object_getClassName(self);
        pcVar15 = &cfstr_error__d_in___s__p___s_;
        pcVar13 = &cfstr_OSStatusError;
        _objc_msgSend(puVar5,sel_extraRaiseError_name_format_,iVar7,&cfstr_OSStatusError,
                      &cfstr_error__d_in___s__p___s_,iVar7,uVar4,self,uVar14);
      }
      lVar12 = CONCAT44(pcVar13,iVar7);
      _local_4c = CONCAT28(uStack_44,local_4c + (double)(1.0 / (float)dVar10));
    }
    if ((uVar1 & 1) == 0) {
      pcVar13 = &cfstr_HSQTMovieExporterMediaKey;
      local_50 = (id)0x0;
      puVar5 = addMovies;
      pvVar3 = _objc_msgSend(self,sel_allProportiesFromDictionaries_forKey_,addMovies,
                             &cfstr_HSQTMovieExporterMediaKey,pcVar15);
      dVar10 = (double)CONCAT44(pcVar15,pcVar13);
      while( true ) {
        uVar14 = SUB84(dVar10,0);
        pvVar6 = _objc_msgSend(pvVar3,sel_count,puVar5,uVar14,(int)((ulonglong)dVar10 >> 0x20));
        if ((pvVar6 <= local_50) || (((self->super)._shouldTerminateExport & 1) != 0)) break;
        pvVar6 = _objc_msgSend(pvVar3,sel_objectAtIndex_,local_50,uVar14);
        puVar5 = &DAT_003426b0;
        uVar14 = 5;
        pvVar8 = (id)0x0;
        self_00 = _objc_msgSend(self,sel_allTracksOfTypes_count_forMovie_,&DAT_003426b0,5,pvVar6);
        dVar10 = (double)CONCAT44(pvVar6,uVar14);
        while( true ) {
          pvVar6 = _objc_msgSend(self_00,sel_count,puVar5,SUB84(dVar10,0),
                                 (int)((ulonglong)dVar10 >> 0x20));
          if ((pvVar6 <= pvVar8) || (((self->super)._shouldTerminateExport & 1) != 0)) break;
          pvVar6 = _objc_msgSend(addMovies,sel_objectAtIndex_,local_50,SUB84(dVar10,0),
                                 (int)((ulonglong)dVar10 >> 0x20));
          puVar5 = _objc_msgSend(self_00,sel_objectAtIndex_,pvVar8);
          dVar10 = atTime;
          _objc_msgSend(self,sel_insertSoundTrack_atTime_withDuration_inMovie_withProperties_,puVar5
                        ,SUB84(atTime,0),(int)((ulonglong)atTime >> 0x20),0,0,inMovie,pvVar6);
          pvVar8 = (id)((int)pvVar8 + 1);
        }
        local_50 = (id)((int)local_50 + 1);
      }
    }
  }
  return;
}

*/
- (void)addMovies:(id)aMovies withLongestPlayTime:(double)aTime atTime:(double)aTime2 runOnStart:(BOOL)aStart inMovie:(id)aMovie withProgressStep:(double)aStep
{
    if ([aMovies count] == 0) {
        return;
    }
    double fps = [self exportFPS];
    QTTime frameTime = QTMakeTime((long long)llroundf(600.0f / (float)fps), 600);
    double time = 0.0;
    for (;;) {
        double timeScale = (time != 0.0) ? fabs(time) : 1.0;
        double longestScale = (aTime != 0.0) ? fabs(aTime) : 1.0;
        double tolerance = MAX(timeScale, longestScale) * 1e-5;
        if (fabs(time - aTime) <= tolerance || aTime <= time || _shouldTerminateExport) {
            break;
        }
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        [[self dataSource] setCurrentTimeForMovies:time runOnStart:aStart onCardAtIndex:_currentImageIndex forExporter:self];
        struct HyperStudio_anon7 duration = { frameTime.timeValue, (int)frameTime.timeScale, (int)frameTime.flags };
        [self addImageWithDuration:duration inMovie:aMovie withProgressStep:aStep];
        [pool release];
        time += (double)(1.0f / (float)fps);
    }
    if (_shouldTerminateExport) {
        return;
    }
    NSArray *mediaList = [self allProportiesFromDictionaries:aMovies forKey:HSQTMovieExporterMediaKey];
    for (NSUInteger i = 0; i < [mediaList count] && !_shouldTerminateExport; i++) {
        NSArray *tracks = [self allTracksOfTypes:sSoundMediaTypes count:5 forMovie:[mediaList objectAtIndex:i]];
        for (NSUInteger j = 0; j < [tracks count] && !_shouldTerminateExport; j++) {
            [self insertSoundTrack:[tracks objectAtIndex:j] atTime:aTime2 withDuration:0.0 inMovie:aMovie withProperties:[aMovies objectAtIndex:i]];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025895b @ 0025895b, 421 bytes * /

void FUN_0025895b(HSQTMovieExporter *self,SEL _cmd,id addBackgroundSoundWithProperties,double atTime
                 ,double withDuration,id inMovie)

{
  int iVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  double dVar5;
  id pvVar6;
  id pvVar7;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  if (((((self->super)._shouldTerminateExport & 1) == 0) &&
      (pvVar2 = _objc_msgSend(addBackgroundSoundWithProperties,sel_objectForKey_,
                              &cfstr_HSQTMovieExporterMediaKey), pvVar2 != (id)0x0)) &&
     (pvVar2 = _objc_msgSend(self,sel_allTracksOfTypes_count_forMovie_,&DAT_003426b0,5,pvVar2),
     pvVar2 != (id)0x0)) {
    local_74 = 0;
    local_70 = 0;
    local_6c = (int *)0x0;
    local_68 = 0;
    local_64 = 0;
    local_60 = 0;
    local_5c = 0;
    local_58 = 0;
    pvVar3 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,local_50,
                           0x10);
    if (pvVar3 != (id)0x0) {
      iVar1 = *local_6c;
      do {
        pvVar4 = (id)0x0;
        do {
          if (iVar1 != *local_6c) {
            _objc_enumerationMutation(pvVar2);
          }
          dVar5 = withDuration;
          pvVar6 = inMovie;
          pvVar7 = addBackgroundSoundWithProperties;
          _objc_msgSend(self,sel_insertSoundTrack_atTime_withDuration_inMovie_withProperties_,
                        *(undefined4 *)(local_70 + (int)pvVar4 * 4),atTime,withDuration,inMovie,
                        addBackgroundSoundWithProperties);
          if (((self->super)._shouldTerminateExport & 1) != 0) {
            return;
          }
          pvVar4 = (id)((int)pvVar4 + 1);
        } while (pvVar4 < pvVar3);
        pvVar3 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,
                               local_50,0x10,dVar5,pvVar6,pvVar7);
      } while (pvVar3 != (id)0x0);
    }
  }
  return;
}

*/
- (void)addBackgroundSoundWithProperties:(id)aProperties atTime:(double)aTime withDuration:(double)aDuration inMovie:(id)aMovie
{
    if (_shouldTerminateExport) {
        return;
    }
    id media = [aProperties objectForKey:HSQTMovieExporterMediaKey];
    if (media == nil) {
        return;
    }
    NSArray *tracks = [self allTracksOfTypes:sSoundMediaTypes count:5 forMovie:media];
    if (tracks == nil) {
        return;
    }
    for (id track in tracks) {
        [self insertSoundTrack:track atTime:aTime withDuration:aDuration inMovie:aMovie withProperties:aProperties];
        if (_shouldTerminateExport) {
            return;
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00258b00 @ 00258b00, 1187 bytes * /

void FUN_00258b00(HSQTMovieExporter *self,SEL _cmd,id addSounds,double atTime,id inMovie,
                 double withProgressStep,id *backgroundSounds)

{
  int iVar1;
  int iVar2;
  id pvVar3;
  id pvVar4;
  id self_00;
  cfstringStruct *pcVar5;
  undefined1 *puVar6;
  id self_01;
  undefined4 uVar7;
  undefined4 uVar9;
  double dVar8;
  undefined4 uVar10;
  undefined4 uVar11;
  id pvVar12;
  id pvVar13;
  id local_fc;
  id local_f8;
  id local_ec;
  HSQTMovieExporter *local_e4;
  id local_e0;
  double local_dc;
  undefined4 local_d4;
  int local_d0;
  int *local_cc;
  undefined4 local_c8;
  undefined4 local_c4;
  undefined4 local_c0;
  undefined4 local_bc;
  undefined4 local_b8;
  undefined1 local_b4 [64];
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar3 = _objc_msgSend(addSounds,sel_count);
  if (pvVar3 == (id)0x0) {
    return;
  }
  if (pvVar3 == (id)0x1) {
    pvVar3 = _objc_msgSend(addSounds,sel_objectAtIndex_,0);
    pcVar5 = &cfstr_HSQTMovieExporterMediaAsynchronyKey;
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_HSQTMovieExporterMediaAsynchronyKey);
    if (pvVar3 == (id)0x0) {
      if (backgroundSounds == (id *)0x0) {
        return;
      }
      pvVar3 = _objc_msgSend(*backgroundSounds,sel_count,pcVar5);
      if (pvVar3 == (id)0x0) {
        return;
      }
      local_e4 = self;
      local_e0 = inMovie;
      local_dc = atTime;
      _CFDictionaryApplyFunction(*backgroundSounds,FUN_0025a411,&local_e4);
      _objc_msgSend(*backgroundSounds,sel_removeAllObjects);
    }
  }
  local_d4 = 0;
  local_d0 = 0;
  local_cc = (int *)0x0;
  local_c8 = 0;
  local_c4 = 0;
  local_c0 = 0;
  local_bc = 0;
  local_b8 = 0;
  puVar6 = local_b4;
  uVar9 = 0x10;
  local_fc = _objc_msgSend(addSounds,sel_countByEnumeratingWithState_objects_count_,&local_d4,puVar6
                           ,0x10);
  if (local_fc != (id)0x0) {
    iVar1 = *local_cc;
    do {
      dVar8 = (double)CONCAT44(uVar9,puVar6);
      local_f8 = (id)0x0;
      do {
        if (iVar1 != *local_cc) {
          _objc_enumerationMutation(addSounds);
        }
        pvVar3 = (id)((int)local_f8 + 1);
        self_01 = *(id *)(local_d0 + (int)local_f8 * 4);
        pcVar5 = &cfstr_HSQTMovieExporterMediaAsynchronyKey;
        pvVar4 = _objc_msgSend(self_01,sel_objectForKey_,&cfstr_HSQTMovieExporterMediaAsynchronyKey,
                               SUB84(dVar8,0),(int)((ulonglong)dVar8 >> 0x20));
        pvVar4 = _objc_msgSend(pvVar4,sel_boolValue);
        uVar7 = (undefined4)((ulonglong)dVar8 >> 0x20);
        uVar9 = (undefined4)((ulonglong)atTime >> 0x20);
        if ((char)pvVar4 == '\0') {
          pvVar4 = _objc_msgSend(self_01,sel_objectForKey_,&cfstr_HSQTMovieExporterMediaKey);
          if (pvVar4 != (id)0x0) {
            uVar7 = 5;
            self_00 = _objc_msgSend(self,sel_allTracksOfTypes_count_forMovie_,&DAT_003426b0,5,pvVar4
                                   );
            dVar8 = (double)CONCAT44(pvVar4,uVar7);
            if (self_00 != (id)0x0) {
              local_74 = 0;
              local_70 = 0;
              local_6c = (int *)0x0;
              local_68 = 0;
              local_64 = 0;
              local_60 = 0;
              local_5c = 0;
              local_58 = 0;
              puVar6 = local_50;
              uVar7 = 0x10;
              local_ec = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,
                                       &local_74,puVar6,0x10);
              dVar8 = (double)CONCAT44(uVar7,puVar6);
              if (local_ec != (id)0x0) {
                iVar2 = *local_6c;
                do {
                  pvVar4 = (id)0x0;
                  do {
                    if (iVar2 != *local_6c) {
                      _objc_enumerationMutation(self_00);
                    }
                    uVar11 = 0;
                    uVar7 = 0;
                    pvVar12 = inMovie;
                    pvVar13 = self_01;
                    dVar8 = atTime;
                    _objc_msgSend(self,
                                  sel_insertSoundTrack_atTime_withDuration_inMovie_withProperties_,
                                  *(undefined4 *)(local_70 + (int)pvVar4 * 4),SUB84(atTime,0),uVar9,
                                  0,0,inMovie,self_01);
                    if (((self->super)._shouldTerminateExport & 1) != 0) goto LAB_00258f3e;
                    pvVar4 = (id)((int)pvVar4 + 1);
                  } while (pvVar4 < local_ec);
                  puVar6 = local_50;
                  uVar10 = 0x10;
                  local_ec = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,
                                           &local_74,puVar6,0x10,uVar7,uVar11,pvVar12,pvVar13);
                  dVar8 = (double)CONCAT44(uVar10,puVar6);
                } while (local_ec != (id)0x0);
              }
              goto LAB_00258f3e;
            }
          }
        }
        else if (backgroundSounds != (id *)0x0) {
          if (*backgroundSounds == (id)0x0) {
            pvVar4 = _objc_msgSend(cls_NSMutableDictionary,sel_alloc,pcVar5);
            pvVar4 = _objc_msgSend(pvVar4,sel_init);
            *backgroundSounds = pvVar4;
            if (pvVar4 == (id)0x0) {
              return;
            }
          }
          pvVar4 = _objc_msgSend(cls_NSNumber,sel_numberWithDouble_,SUB84(atTime,0),uVar9);
          if (pvVar4 == (id)0x0) {
            return;
          }
          _objc_msgSend(*backgroundSounds,sel_setObject_forKey_,pvVar4,self_01);
          dVar8 = (double)CONCAT44(uVar7,self_01);
LAB_00258f3e:
          if (((self->super)._shouldTerminateExport & 1) != 0) {
            return;
          }
        }
        local_f8 = pvVar3;
      } while (pvVar3 < local_fc);
      puVar6 = local_b4;
      uVar9 = 0x10;
      local_fc = _objc_msgSend(addSounds,sel_countByEnumeratingWithState_objects_count_,&local_d4,
                               puVar6,0x10);
    } while (local_fc != (id)0x0);
  }
  return;
}

*/
- (void)addSounds:(id)aSounds atTime:(double)aTime inMovie:(id)aMovie withProgressStep:(double)aStep backgroundSounds:(id *)aSounds2
{
    NSUInteger count = [aSounds count];
    if (count == 0) {
        return;
    }
    if (count == 1) {
        id first = [aSounds objectAtIndex:0];
        if ([first objectForKey:HSQTMovieExporterMediaAsynchronyKey] == nil) {
            // A lone synchronous sound ends the asynchronous ones started earlier: they play until now.
            if (aSounds2 == NULL || [*aSounds2 count] == 0) {
                return;
            }
            for (id properties in *aSounds2) {
                double start = [[*aSounds2 objectForKey:properties] doubleValue];
                [self addBackgroundSoundWithProperties:properties atTime:start withDuration:aTime - start inMovie:aMovie];
            }
            [*aSounds2 removeAllObjects];
        }
    }
    for (id sound in aSounds) {
        if (![[sound objectForKey:HSQTMovieExporterMediaAsynchronyKey] boolValue]) {
            id media = [sound objectForKey:HSQTMovieExporterMediaKey];
            if (media != nil) {
                NSArray *tracks = [self allTracksOfTypes:sSoundMediaTypes count:5 forMovie:media];
                if (tracks != nil) {
                    for (id track in tracks) {
                        [self insertSoundTrack:track atTime:aTime withDuration:0.0 inMovie:aMovie withProperties:sound];
                        if (_shouldTerminateExport) {
                            return;
                        }
                    }
                }
            }
        } else if (aSounds2 != NULL) {
            if (*aSounds2 == nil) {
                *aSounds2 = [[NSMutableDictionary alloc] init];
                if (*aSounds2 == nil) {
                    return;
                }
            }
            NSNumber *start = [NSNumber numberWithDouble:aTime];
            if (start == nil) {
                return;
            }
            [*aSounds2 setObject:start forKey:sound];
            if (_shouldTerminateExport) {
                return;
            }
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00258fa3 @ 00258fa3, 1585 bytes * /

void FUN_00258fa3(HSQTMovieExporter *self,SEL _cmd,id insertSoundTrack,double atTime,
                 double withDuration,id inMovie,id withProperties)

{
  undefined *puVar1;
  short sVar2;
  id pvVar3;
  undefined4 uVar4;
  int iVar5;
  int iVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  int iVar9;
  undefined4 uVar10;
  cfstringStruct *pcVar11;
  longdouble lVar12;
  longdouble lVar13;
  longdouble lVar14;
  double dVar15;
  cfstringStruct *pcVar16;
  undefined4 local_28;
  double local_24;
  double local_1c;
  
  pcVar11 = &cfstr_HSQTMovieExporterMediaPlayRangeKey;
  pvVar3 = _objc_msgSend(withProperties,sel_objectForKey_,&cfstr_HSQTMovieExporterMediaPlayRangeKey)
  ;
  if (pvVar3 != (id)0x0) {
    _objc_msgSend(withProperties,sel_objectForKey_,&cfstr_HSQTMovieExporterMediaPlayRangeKey);
    FUN_0025a47b();
    if ((withDuration != 0.0) && (withDuration < local_1c)) {
      local_1c = withDuration;
    }
    pvVar3 = _objc_msgSend(insertSoundTrack,sel_quickTimeTrack,pcVar11);
    uVar4 = _GetTrackMovie(pvVar3);
    iVar5 = _GetMovieTimeScale(uVar4);
    lVar12 = (longdouble)_floor(local_1c * (double)iVar5 + 0.0005);
    if ((int)lVar12 != 0) {
      pcVar11 = &cfstr_HSQTMovieExporterMediaVolumeKey;
      pvVar3 = _objc_msgSend(withProperties,sel_objectForKey_,&cfstr_HSQTMovieExporterMediaVolumeKey
                            );
      if (pvVar3 != (id)0x0) {
        dVar15 = _objc_msgSend_fpret(pvVar3,sel_floatValue);
        iVar6 = _lroundf((float)dVar15 * 256.0);
        if (0 < iVar6) {
          pvVar3 = _objc_msgSend(insertSoundTrack,sel_quickTimeTrack,pcVar11);
          uVar4 = _GetTrackMedia(pvVar3);
          sVar2 = _GetMoviesError();
          puVar1 = cls_NSException;
          if (sVar2 != 0) {
            pcVar11 = (cfstringStruct *)(int)sVar2;
            uVar7 = _sel_getName(_cmd);
            uVar8 = _object_getClassName(self);
            _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,pcVar11,&cfstr_OSStatusError,
                          &cfstr_error__d_in___s__p___s_,pcVar11,uVar8,self,uVar7);
          }
          iVar9 = _GetMediaTimeScale(uVar4);
          sVar2 = _GetMoviesError();
          puVar1 = cls_NSException;
          if (sVar2 != 0) {
            pcVar11 = (cfstringStruct *)(int)sVar2;
            uVar7 = _sel_getName(_cmd);
            uVar8 = _object_getClassName(self);
            _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,pcVar11,&cfstr_OSStatusError,
                          &cfstr_error__d_in___s__p___s_,pcVar11,uVar8,self,uVar7);
          }
          sVar2 = 0x100;
          if (iVar6 < 0x101) {
            sVar2 = (short)iVar6;
          }
          pvVar3 = _objc_msgSend(inMovie,sel_quickTimeMovie,pcVar11);
          uVar7 = _NewMovieTrack(pvVar3,0,0,(int)sVar2);
          sVar2 = _GetMoviesError();
          puVar1 = cls_NSException;
          if (sVar2 != 0) {
            uVar8 = _sel_getName(_cmd);
            uVar10 = _object_getClassName(self);
            _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar2,&cfstr_OSStatusError,
                          &cfstr_error__d_in___s__p___s_,(int)sVar2,uVar10,self,uVar8);
          }
          local_28 = 0;
          _GetMediaHandlerDescription(uVar4,&local_28,0,0);
          sVar2 = _GetMoviesError();
          puVar1 = cls_NSException;
          if (sVar2 != 0) {
            uVar4 = _sel_getName(_cmd);
            uVar8 = _object_getClassName(self);
            _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar2,&cfstr_OSStatusError,
                          &cfstr_error__d_in___s__p___s_,(int)sVar2,uVar8,self,uVar4);
          }
          pcVar11 = (cfstringStruct *)0x0;
          pcVar16 = (cfstringStruct *)0x0;
          uVar4 = _NewTrackMedia(uVar7,local_28,iVar9,0,0);
          sVar2 = _GetMoviesError();
          puVar1 = cls_NSException;
          if (sVar2 != 0) {
            iVar9 = (int)sVar2;
            uVar8 = _sel_getName(_cmd);
            uVar10 = _object_getClassName(self);
            pcVar11 = &cfstr_error__d_in___s__p___s_;
            pcVar16 = &cfstr_OSStatusError;
            _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,iVar9,&cfstr_OSStatusError,
                          &cfstr_error__d_in___s__p___s_,iVar9,uVar10,self,uVar8);
          }
          lVar13 = (longdouble)_floor(local_24 * (double)iVar5 + 0.0005);
          lVar14 = (longdouble)_floor(atTime * 600.0 + 0.0005);
          _BeginMediaEdits(uVar4);
          sVar2 = _GetMoviesError();
          puVar1 = cls_NSException;
          if (sVar2 != 0) {
            iVar9 = (int)sVar2;
            uVar8 = _sel_getName(_cmd);
            uVar10 = _object_getClassName(self);
            pcVar11 = &cfstr_error__d_in___s__p___s_;
            pcVar16 = &cfstr_OSStatusError;
            _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,iVar9,&cfstr_OSStatusError,
                          &cfstr_error__d_in___s__p___s_,iVar9,uVar10,self,uVar8);
          }
          pvVar3 = _objc_msgSend(insertSoundTrack,sel_quickTimeTrack,iVar9,pcVar16,pcVar11);
          _InsertTrackSegment(pvVar3,uVar7,(int)lVar13,(int)lVar12,(int)lVar14);
          sVar2 = _GetMoviesError();
          puVar1 = cls_NSException;
          if (sVar2 != 0) {
            uVar7 = _sel_getName(_cmd);
            uVar8 = _object_getClassName(self);
            _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar2,&cfstr_OSStatusError,
                          &cfstr_error__d_in___s__p___s_,(int)sVar2,uVar8,self,uVar7);
          }
          _EndMediaEdits(uVar4);
          sVar2 = _GetMoviesError();
          puVar1 = cls_NSException;
          if (sVar2 != 0) {
            uVar4 = _sel_getName(_cmd);
            uVar7 = _object_getClassName(self);
            _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar2,&cfstr_OSStatusError,
                          &cfstr_error__d_in___s__p___s_,(int)sVar2,uVar7,self,uVar4);
          }
        }
      }
    }
  }
  return;
}

*/
- (void)insertSoundTrack:(id)aTrack atTime:(double)aTime withDuration:(double)aDuration inMovie:(id)aMovie withProperties:(id)aProperties
{
    if ([aProperties objectForKey:HSQTMovieExporterMediaPlayRangeKey] == nil) {
        return;
    }
    struct HSTimeRange range = HSQTMovieExporterPlayRangeFromString([aProperties objectForKey:HSQTMovieExporterMediaPlayRangeKey]);
    double length = range.length;
    if (aDuration != 0.0 && aDuration < length) {
        length = aDuration;
    }
    long movieScale = [(QTMovie *)[(QTTrack *)aTrack movie] duration].timeScale;
    long long segmentDuration = (long long)floor(length * (double)movieScale + 0.0005);
    if (segmentDuration == 0) {
        return;
    }
    id volumeValue = [aProperties objectForKey:HSQTMovieExporterMediaVolumeKey];
    if (volumeValue == nil) {
        return;
    }
    // The volume is kept in QuickTime's 8.8 fixed point; a silent sound is not inserted at all.
    long volume = lroundf([volumeValue floatValue] * 256.0f);
    if (volume <= 0) {
        return;
    }
    // The original built the track with NewMovieTrack/NewTrackMedia/InsertTrackSegment; HSQTKit does it in one call.
    long long segmentStart = (long long)floor(range.location * (double)movieScale + 0.0005);
    long long destination = (long long)floor(aTime * 600.0 + 0.0005);
    QTTrack *inserted = [aMovie insertSegmentOfTrack:aTrack
                                           timeRange:QTMakeTimeRange(QTMakeTime(segmentStart, movieScale), QTMakeTime(segmentDuration, movieScale))
                                              atTime:QTMakeTime(destination, 600)];
    [inserted setVolume:(float)MIN(volume, 256) / 256.0f];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002563eb @ 002563eb, 338 bytes * /

void FUN_002563eb(HSQTMovieExporter *self,SEL _cmd,anon_12ef933e_9 addImageWithDuration,id inMovie,
                 double withProgressStep)

{
  id pvVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  undefined8 uVar4;
  
  pvVar1 = _objc_msgSend(self,sel_imageAtIndex_applyMovieFrameSize_,self->_currentImageIndex,1);
  uVar4 = 0x1003426a0;
  pvVar3 = inMovie;
  self_00 = _objc_msgSend(self,sel_allTracksOfTypes_count_forMovie_,&DAT_003426a0,1,inMovie);
  pvVar2 = _objc_msgSend(self_00,sel_count);
  if (pvVar2 == (id)0x0) {
    pvVar3 = _objc_msgSend(self,sel_addImageCodecConfiguration,uVar4,pvVar3);
  }
  else {
    inMovie = _objc_msgSend(self_00,sel_objectAtIndex_,0,(int)((ulonglong)uVar4 >> 0x20),pvVar3);
    pvVar3 = _objc_msgSend(self,sel_addImageCodecConfiguration);
  }
  _objc_msgSend(inMovie,sel_addImage_forDuration_withAttributes_,
                CONCAT44((undefined4)addImageWithDuration.f0,pvVar1),addImageWithDuration.f0._4_4_,
                addImageWithDuration.f1,addImageWithDuration.f2,pvVar3);
  _objc_msgSend(self,sel_notifyExportProgressDidChangeWithProgress_,withProgressStep);
  return;
}

*/
- (void)addImageWithDuration:(struct HyperStudio_anon7)aDuration inMovie:(id)aMovie withProgressStep:(double)aStep
{
    NSImage *image = [self imageAtIndex:_currentImageIndex applyMovieFrameSize:YES];
    NSArray *videoTracks = [self allTracksOfTypes:&sVideoMediaType count:1 forMovie:aMovie];
    id target = ([videoTracks count] == 0) ? aMovie : [videoTracks objectAtIndex:0];
    QTTime duration = QTMakeTime(aDuration.f0, aDuration.f1);
    duration.flags = aDuration.f2;
    [target addImage:image forDuration:duration withAttributes:[self addImageCodecConfiguration]];
    [self notifyExportProgressDidChangeWithProgress:aStep];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002595d4 @ 002595d4, 319 bytes * /

id FUN_002595d4(HSQTMovieExporter *self,SEL _cmd)

{
  id self_00;
  id self_01;
  id pvVar1;
  longdouble lVar2;
  double dVar3;
  
  self_00 = _objc_msgSend(cls_HSSlideshowAttributes,sel_defaultSlideshowAttributes);
  if (self->_transitionName != (id)0x0) {
    self_01 = _objc_msgSend(self_00,sel_transition);
    pvVar1 = _objc_msgSend(self_01,sel_isFastestTransition);
    if ((char)pvVar1 != '\0') {
      pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
      dVar3 = _objc_msgSend_fpret(pvVar1,sel_floatForKey_,*(undefined4 *)PTR_003368e8);
      _objc_msgSend(self_01,sel_setDuration_,dVar3);
    }
    _objc_msgSend(self_01,sel_setTransitionName_,self->_transitionName);
    pvVar1 = _objc_msgSend(self_01,sel_isFastestTransition);
    if ((char)pvVar1 != '\0') {
      _objc_msgSend(self_01,sel_setDuration_,*(undefined8 *)PTR_003365a8);
    }
  }
  lVar2 = (longdouble)_fmaxf(self->_slideDelay,0x3dcccccd);
  _objc_msgSend(self_00,sel_setDurationBetweenSlides_,(double)lVar2);
  return self_00;
}

*/
- (id)HSQTMovieExporter_slideShowAttributes
{
    HSSlideshowAttributes *attributes = [HSSlideshowAttributes defaultSlideshowAttributes];
    if (_transitionName != nil) {
        id transition = [attributes transition];
        if ([transition isFastestTransition]) {
            [transition setDuration:[[NSUserDefaults standardUserDefaults] floatForKey:HSDefaultTransitionDurationDefaultsKey]];
        }
        [transition setTransitionName:_transitionName];
        if ([transition isFastestTransition]) {
            [transition setDuration:HSMinTransitionDuration];
        }
    }
    [attributes setDurationBetweenSlides:fmaxf(_slideDelay, 0.1f)];
    return attributes;
}

- (id)transitionImageForTime:(double)aTime afterCardAtIndex:(NSUInteger)aIndex applyMovieFrameSize:(BOOL)aSize
{
    return [self HS_drawMovieImageWithImage:[[self dataSource] transitionImageForTime:aTime afterCardAtIndex:aIndex forExporter:self] applyMovieFrameSize:(unsigned int)aSize];
}

- (id)imageAtIndex:(NSUInteger)aIndex applyMovieFrameSize:(BOOL)aSize
{
    return [self HS_drawMovieImageWithImage:[[self dataSource] imageForCardAtIndex:aIndex forExporter:self] applyMovieFrameSize:(unsigned int)aSize];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00259713 @ 00259713, 938 bytes * /

id FUN_00259713(HSQTMovieExporter *self,SEL _cmd,id HS_drawMovieImageWithImage,
               BOOL applyMovieFrameSize)

{
  undefined8 uVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  longdouble lVar6;
  longdouble lVar7;
  float fVar8;
  float fVar9;
  undefined8 uVar10;
  id local_64;
  float local_58;
  
  pvVar3 = _objc_msgSend(self,sel_movieFrameSize);
  if (((applyMovieFrameSize != '\0') &&
      (cVar2 = _NSEqualSizes(pvVar3,extraout_EDX,*(undefined4 *)PTR_0033607c,
                             *(undefined4 *)(PTR_0033607c + 4)), cVar2 == '\0')) ||
     (pvVar4 = _objc_msgSend(self,sel_canUseRoundedCorners), (char)pvVar4 != '\0')) {
    local_64 = _objc_msgSend(HS_drawMovieImageWithImage,sel_size);
    uVar10 = CONCAT44(extraout_EDX_00,local_64);
    cVar2 = _NSEqualSizes(pvVar3,extraout_EDX,local_64,extraout_EDX_00);
    local_58 = extraout_EDX_00;
    if (cVar2 == '\0') {
      fVar8 = extraout_EDX_00 / extraout_EDX;
      if (extraout_EDX_00 / extraout_EDX <= (float)local_64 / (float)pvVar3) {
        fVar8 = (float)local_64 / (float)pvVar3;
      }
      lVar6 = (longdouble)_floorf((float)local_64 / fVar8);
      lVar7 = (longdouble)_floorf(extraout_EDX_00 / fVar8);
      _objc_msgSend(HS_drawMovieImageWithImage,sel_setScalesWhenResized_,1);
      uVar10 = CONCAT44((float)lVar7,(float)lVar6);
      _objc_msgSend(HS_drawMovieImageWithImage,sel_setSize_,(float)lVar6,(float)lVar7);
      local_64 = _objc_msgSend(HS_drawMovieImageWithImage,sel_size);
      local_58 = extraout_EDX_01;
    }
    pvVar4 = _objc_msgSend(cls_NSImage,sel_alloc,uVar10);
    pvVar4 = _objc_msgSend(pvVar4,sel_initWithSize_,pvVar3,extraout_EDX);
    uVar1 = *(undefined8 *)PTR_00336074;
    uVar10 = *(undefined8 *)PTR_00336074;
    pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
    fVar8 = ((float)pvVar3 - (float)local_64) * 0.5;
    fVar9 = (extraout_EDX - local_58) * 0.5;
    _objc_msgSend(pvVar4,sel_lockFocus);
    pvVar5 = _objc_msgSend(self,sel_canUseRoundedCorners);
    if ((char)pvVar5 != '\0') {
      pvVar5 = _objc_msgSend(cls_NSColor,sel_blackColor);
      _objc_msgSend(pvVar5,sel_set);
      _NSRectFill(uVar10,CONCAT44(extraout_EDX,pvVar3));
      pvVar3 = _objc_msgSend(self,sel_cornersClipPathForFrameRect_,CONCAT44(fVar9,fVar8),
                             CONCAT44(local_58,local_64));
      _objc_msgSend(pvVar3,sel_setClip);
    }
    _objc_msgSend(HS_drawMovieImageWithImage,sel_drawAtPoint_fromRect_operation_fraction_,fVar8,
                  fVar9,uVar1,CONCAT44(local_58,local_64),2,0x3f800000);
    _objc_msgSend(pvVar4,sel_unlockFocus);
    HS_drawMovieImageWithImage = pvVar4;
  }
  return HS_drawMovieImageWithImage;
}

*/
- (id)HS_drawMovieImageWithImage:(id)aImage applyMovieFrameSize:(BOOL)aSize
{
    NSSize frameSize = [self movieFrameSize];
    BOOL roundedCorners = [self canUseRoundedCorners];
    if (!((aSize && !NSEqualSizes(frameSize, NSZeroSize)) || roundedCorners)) {
        return aImage;
    }
    NSSize imageSize = [aImage size];
    if (!NSEqualSizes(frameSize, imageSize)) {
        CGFloat scale = imageSize.height / frameSize.height;
        if (scale <= imageSize.width / frameSize.width) {
            scale = imageSize.width / frameSize.width;
        }
        [aImage setScalesWhenResized:YES];
        [aImage setSize:NSMakeSize(floor(imageSize.width / scale), floor(imageSize.height / scale))];
        imageSize = [aImage size];
    }
    NSImage *result = [[[NSImage alloc] initWithSize:frameSize] autorelease];
    NSPoint origin = NSMakePoint((frameSize.width - imageSize.width) * 0.5, (frameSize.height - imageSize.height) * 0.5);
    [result lockFocus];
    if (roundedCorners) {
        [[NSColor blackColor] set];
        NSRectFill(NSMakeRect(0.0, 0.0, frameSize.width, frameSize.height));
        [[self cornersClipPathForFrameRect:NSMakeRect(origin.x, origin.y, imageSize.width, imageSize.height)] setClip];
    }
    [aImage drawAtPoint:origin fromRect:NSMakeRect(0.0, 0.0, imageSize.width, imageSize.height) operation:NSCompositingOperationSourceOver fraction:1.0];
    [result unlockFocus];
    return result;
}

- (double)transitionTimeAfterImageAtIndex:(NSInteger)aIndex
{
    id pvVar1;
    double dVar2;

    pvVar1 = [self dataSource];
    if (![pvVar1 hasTransitionAfterCardAtIndex:aIndex forExporter:self]) {
        dVar2 = 0.0;
    }
    else {
        dVar2 = [[self dataSource] transitionTimeAfterCardAtIndex:aIndex forExporter:self];
    }
    return dVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00259b3a @ 00259b3a, 213 bytes * /

double FUN_00259b3a(HSQTMovieExporter *self,SEL _cmd,id longestPlayTimeOfMedia)

{
  id self_00;
  id pvVar1;
  id self_01;
  double local_34;
  double local_1c;
  
  local_34 = 0.0;
  self_00 = _objc_msgSend(longestPlayTimeOfMedia,sel_objectEnumerator);
  while (self_01 = _objc_msgSend(self_00,sel_nextObject), self_01 != (id)0x0) {
    pvVar1 = _objc_msgSend(self_01,sel_objectForKey_,&cfstr_HSQTMovieExporterMediaAsynchronyKey);
    pvVar1 = _objc_msgSend(pvVar1,sel_boolValue);
    if ((char)pvVar1 == '\0') {
      _objc_msgSend(self_01,sel_objectForKey_,&cfstr_HSQTMovieExporterMediaPlayRangeKey);
      FUN_0025a47b();
      local_34 = local_1c;
    }
  }
  return local_34;
}

*/
- (double)longestPlayTimeOfMedia:(id)aMedia
{
    double longest = 0.0;
    NSEnumerator *enumerator = [aMedia objectEnumerator];
    id media;
    while ((media = [enumerator nextObject]) != nil) {
        if (![[media objectForKey:HSQTMovieExporterMediaAsynchronyKey] boolValue]) {
            struct HSTimeRange range = HSQTMovieExporterPlayRangeFromString([media objectForKey:HSQTMovieExporterMediaPlayRangeKey]);
            if (range.length > longest) {
                longest = range.length;
            }
        }
    }
    return longest;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00259c0f @ 00259c0f, 625 bytes * /

id FUN_00259c0f(HSQTMovieExporter *self,SEL _cmd,uint *allTracksOfTypes,uint count,id forMovie)

{
  undefined *puVar1;
  short sVar2;
  id self_00;
  id pvVar3;
  int iVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  uint uVar8;
  id pvVar9;
  int local_18;
  uint local_14;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar3 = _objc_msgSend(forMovie,sel_quickTimeMovie);
  if (pvVar3 != (id)0x0) {
    iVar4 = _GetMovieTrackCount(pvVar3);
    sVar2 = _GetMoviesError();
    puVar1 = cls_NSException;
    if (sVar2 != 0) {
      uVar5 = _sel_getName(_cmd);
      uVar6 = _object_getClassName(self);
      _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar2,&cfstr_OSStatusError,
                    &cfstr_error__d_in___s__p___s_,(int)sVar2,uVar6,self,uVar5);
    }
    if (0 < iVar4) {
      local_18 = 1;
      do {
        uVar5 = _GetMovieIndTrack(pvVar3,local_18);
        sVar2 = _GetMoviesError();
        puVar1 = cls_NSException;
        if (sVar2 != 0) {
          uVar6 = _sel_getName(_cmd);
          uVar7 = _object_getClassName(self);
          _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar2,&cfstr_OSStatusError,
                        &cfstr_error__d_in___s__p___s_,(int)sVar2,uVar7,self,uVar6);
        }
        local_14 = 0;
        uVar6 = _GetTrackMedia(uVar5);
        _GetMediaHandlerDescription(uVar6,&local_14,0,0);
        sVar2 = _GetMoviesError();
        puVar1 = cls_NSException;
        if (sVar2 != 0) {
          uVar6 = _sel_getName(_cmd);
          uVar7 = _object_getClassName(self);
          _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar2,&cfstr_OSStatusError,
                        &cfstr_error__d_in___s__p___s_,(int)sVar2,uVar7,self,uVar6);
        }
        for (uVar8 = 0; uVar8 < count; uVar8 = uVar8 + 1) {
          if (local_14 == allTracksOfTypes[uVar8]) {
            pvVar9 = _objc_msgSend(cls_QTTrack,sel_trackWithQuickTimeTrack_error_,uVar5,0);
            _objc_msgSend(self_00,sel_addObject_,pvVar9);
            break;
          }
        }
        local_18 = local_18 + 1;
      } while (local_18 <= iVar4);
    }
  }
  return self_00;
}

*/
- (id)allTracksOfTypes:(unsigned int *)aTypes count:(NSUInteger)aCount forMovie:(id)aMovie
{
    NSMutableArray *tracks = [NSMutableArray array];
    // The original walked the QuickTime movie's tracks with GetMovieIndTrack and GetMediaHandlerDescription;
    // HSQTKit movies expose the same tracks and their media types.
    if ([aMovie quickTimeMovie] != NULL) {
        for (QTTrack *track in [aMovie tracks]) {
            NSString *trackType = [track attributeForKey:QTTrackMediaTypeAttribute];
            for (NSUInteger i = 0; i < aCount; i++) {
                if ([trackType isEqualToString:[NSString extraStringWithFourCharCode:aTypes[i]]]) {
                    [tracks addObject:track];
                    break;
                }
            }
        }
    }
    return tracks;
}

- (id)allProportiesFromDictionaries:(id)aDictionaries forKey:(id)aKey
{
    id self_00;
    NSEnumerator *self_01;
    id pvVar1;
    id pvVar1_2;

    self_00 = [NSMutableArray array];
    self_01 = [aDictionaries objectEnumerator];
    while( YES ) {
        pvVar1 = [self_01 nextObject];
        if (pvVar1 == nil) break;
        pvVar1_2 = [pvVar1 objectForKey:aKey];
        if (pvVar1_2 != nil) {
            [self_00 addObject:pvVar1_2];
        }
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002561ae @ 002561ae, 202 bytes * /

id FUN_002561ae(HSQTMovieExporter *self,SEL _cmd,id mediasFromDictionaries,BOOL runOnStart)

{
  id self_00;
  id self_01;
  id pvVar1;
  id self_02;
  cfstringStruct *pcVar2;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  self_01 = _objc_msgSend(mediasFromDictionaries,sel_objectEnumerator);
  while (self_02 = _objc_msgSend(self_01,sel_nextObject), self_02 != (id)0x0) {
    pcVar2 = &cfstr_HSQTMovieExporterMediaRunOnStartKey;
    pvVar1 = _objc_msgSend(self_02,sel_objectForKey_,&cfstr_HSQTMovieExporterMediaRunOnStartKey);
    if (((runOnStart != '\0') && (pvVar1 == (id)0x0)) ||
       (pvVar1 = _objc_msgSend(pvVar1,sel_boolValue,pcVar2), (char)pvVar1 == runOnStart)) {
      _objc_msgSend(self_00,sel_addObject_,self_02);
    }
  }
  return self_00;
}

*/
- (id)mediasFromDictionaries:(id)aDictionaries runOnStart:(BOOL)aStart
{
    NSMutableArray *medias = [NSMutableArray array];
    NSEnumerator *enumerator = [aDictionaries objectEnumerator];
    id media;
    while ((media = [enumerator nextObject]) != nil) {
        id runOnStart = [media objectForKey:HSQTMovieExporterMediaRunOnStartKey];
        if ((aStart && runOnStart == nil) || [runOnStart boolValue] == aStart) {
            [medias addObject:media];
        }
    }
    return medias;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00259e80 @ 00259e80, 548 bytes * /

id FUN_00259e80(HSQTMovieExporter *self,SEL _cmd,id *createQTKitMovieWithError)

{
  undefined *self_00;
  id *ppvVar1;
  int iVar2;
  id pvVar3;
  id local_78;
  int local_74 [23];
  id *local_18;
  HSQTMovieExporter *local_14;
  
  local_14 = self;
  local_18 = createQTKitMovieWithError;
  local_78 = (id)0x0;
  _objc_exception_try_enter(local_74);
  iVar2 = __setjmp(local_74);
  if (iVar2 == 0) {
    pvVar3 = _objc_msgSend(local_14,sel_createQuickTimeMovie_,&local_14->_dataHandleRef);
    local_78 = _objc_msgSend(cls_QTMovie,sel_movieWithQuickTimeMovie_disposeWhenDone_error_,pvVar3,1
                             ,local_18);
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
    _objc_msgSend(local_78,sel_setAttribute_forKey_,pvVar3,*(undefined4 *)PTR_00336910);
    pvVar3 = _objc_msgSend(cls_NSNumber,sel_numberWithBool_,1);
    _objc_msgSend(local_78,sel_setAttribute_forKey_,pvVar3,*(undefined4 *)PTR_0033690c);
  }
  else {
    pvVar3 = (id)_objc_exception_extract(local_74);
    _objc_exception_try_enter(local_74);
    iVar2 = __setjmp(local_74);
    if (iVar2 == 0) {
      iVar2 = _objc_exception_match(cls_NSException,pvVar3);
      ppvVar1 = local_18;
      self_00 = cls_HSError;
      if (iVar2 != 0) {
        if (local_18 != (id *)0x0) {
          pvVar3 = _objc_msgSend(pvVar3,sel_extraStatusError);
          pvVar3 = _objc_msgSend(self_00,sel_errorWithDomain_code_userInfo_,
                                 *(undefined4 *)PTR_00336900,pvVar3,0);
          *ppvVar1 = pvVar3;
        }
        goto LAB_0025a050;
      }
      _objc_exception_try_exit(local_74);
    }
    else {
      pvVar3 = (id)_objc_exception_extract(local_74);
    }
    if (pvVar3 != (id)0x0) {
                    /* WARNING: Subroutine does not return * /
      _objc_exception_throw(pvVar3);
    }
  }
LAB_0025a050:
  _objc_exception_try_exit(local_74);
  ppvVar1 = local_18;
  if ((local_78 == (id)0x0) && (local_18 != (id *)0x0)) {
    pvVar3 = _objc_msgSend(cls_HSError,sel_errorWithHSCode_,0x5025);
    *ppvVar1 = pvVar3;
  }
  return local_78;
}

*/
- (id)createQTKitMovieWithError:(id *)aError
{
    QTMovie *movie = nil;
    @try {
        QTMovie *quickTimeMovie = (QTMovie *)[self createQuickTimeMovie:&_dataHandleRef];
        movie = [QTMovie movieWithQuickTimeMovie:quickTimeMovie disposeWhenDone:YES error:aError];
        [quickTimeMovie release];
        [movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];
        [movie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieDontInteractWithUserAttribute];
    }
    @catch (NSException *exception) {
        if (aError != NULL) {
            *aError = [HSError errorWithDomain:NSOSStatusErrorDomain code:[exception extraStatusError] userInfo:nil];
        }
    }
    if (movie == nil && aError != NULL) {
        *aError = [HSError errorWithHSCode:0x5025];
    }
    return movie;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025a0a4 @ 0025a0a4, 763 bytes * /

void *** FUN_0025a0a4(HSQTMovieExporter *self,SEL _cmd,char ***createQuickTimeMovie)

{
  undefined *puVar1;
  short sVar2;
  short sVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  cfstringStruct *pcVar8;
  undefined4 local_1c;
  undefined4 local_18;
  void ***local_14;
  
  puVar1 = cls_NSString;
  local_14 = (void ***)0x0;
  pvVar4 = _objc_msgSend(cls_HSPathsProvider,sel_sharedPathsProvider);
  pvVar4 = _objc_msgSend(pvVar4,sel_temporaryFolder);
  pvVar5 = _objc_msgSend(self,sel_exportedDocumentName);
  pvVar4 = _objc_msgSend(pvVar4,sel_stringByAppendingPathComponent_,pvVar5);
  pcVar8 = &cfstr_qttmp;
  pvVar5 = _objc_msgSend(puVar1,sel_extraCreateUniqueFilename_extension_,pvVar4,&cfstr_qttmp);
  pvVar5 = _objc_msgSend(pvVar5,sel_retain);
  self->_tempFilePath = pvVar5;
  if (pvVar5 != (id)0x0) {
    pvVar4 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar4,pcVar8);
    pvVar4 = _objc_msgSend(pvVar4,sel_hyperIsFileWritableAtPath_,self->_tempFilePath);
    if ((char)pvVar4 != '\0') {
      local_18 = 0;
      local_1c = 0;
      sVar2 = _QTNewDataReferenceFromFullPathCFString
                        (self->_tempFilePath,0xffffffff,0,&local_18,&local_1c);
      sVar3 = _GetMoviesError();
      puVar1 = cls_NSException;
      if (sVar3 != 0) {
        uVar6 = _sel_getName(_cmd);
        uVar7 = _object_getClassName(self);
        _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar3,&cfstr_OSStatusError,
                      &cfstr_error__d_in___s__p___s_,(int)sVar3,uVar7,self,uVar6);
      }
      if (sVar2 == 0) {
        sVar2 = _CreateMovieStorage(local_18,local_1c,0x54564f44,0xffffffff,0x80000001,
                                    createQuickTimeMovie,&local_14);
        sVar3 = _GetMoviesError();
        puVar1 = cls_NSException;
        if (sVar3 != 0) {
          uVar6 = _sel_getName(_cmd);
          uVar7 = _object_getClassName(self);
          _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar3,&cfstr_OSStatusError,
                        &cfstr_error__d_in___s__p___s_,(int)sVar3,uVar7,self,uVar6);
        }
        if (sVar2 == 0) {
          _SetMovieVisualContext(local_14,0);
          sVar2 = _GetMoviesError();
          puVar1 = cls_NSException;
          if (sVar2 != 0) {
            uVar6 = _sel_getName(_cmd);
            uVar7 = _object_getClassName(self);
            _objc_msgSend(puVar1,sel_extraRaiseError_name_format_,(int)sVar2,&cfstr_OSStatusError,
                          &cfstr_error__d_in___s__p___s_,(int)sVar2,uVar7,self,uVar6);
          }
        }
        else {
          local_14 = (void ***)0x0;
          _DisposeHandle(local_18);
        }
      }
    }
  }
  return local_14;
}

*/
- (struct MovieType **)createQuickTimeMovie:(char ***)aMovie
{
    NSString *basePath = [[[HSPathsProvider sharedPathsProvider] temporaryFolder] stringByAppendingPathComponent:[self exportedDocumentName]];
    // The original used a "qttmp" file and CreateMovieStorage on a data reference; HSQTKit writes the
    // movie with AVFoundation, which picks the container from the extension, so the temp file is a .mov.
    _tempFilePath = [[NSString extraCreateUniqueFilename:basePath extension:@"mov"] retain];
    if (_tempFilePath == nil || ![[NSFileManager defaultManager] hyperIsFileWritableAtPath:_tempFilePath]) {
        return NULL;
    }
    QTMovie *movie = [[QTMovie alloc] initToWritableFile:_tempFilePath error:NULL];
    if (movie == nil) {
        return NULL;
    }
    // Returns a +1 movie and no data handler (nothing to dispose in HSQTKit).
    return (struct MovieType **)movie;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00256130 @ 00256130, 126 bytes * /

id FUN_00256130(HSQTMovieExporter *self,SEL _cmd,NSRect cornersClipPathForFrameRect)

{
  id pvVar1;
  
  if (self->_cornersClipPath != (id)0x0) {
    _objc_msgSend(self->_cornersClipPath,sel_release);
  }
  pvVar1 = _objc_msgSend(cls_NSBezierPath,sel_smkRoundedBorderPathWithRect_cornerRadius_,
                         cornersClipPathForFrameRect.origin,cornersClipPathForFrameRect.size,
                         0x41800000);
  pvVar1 = _objc_msgSend(pvVar1,sel_retain);
  self->_cornersClipPath = pvVar1;
  return pvVar1;
}

*/
- (id)cornersClipPathForFrameRect:(NSRect)aRect
{
    if (_cornersClipPath != nil) {
        [_cornersClipPath release];
    }
    _cornersClipPath = [[NSBezierPath smkRoundedBorderPathWithRect:aRect cornerRadius:16.0f] retain];
    return _cornersClipPath;
}

- (id)addImageCodecConfiguration
{
    id pvVar1_2;

    pvVar1_2 = [[self codecConfiguration] objectForKey:@"HSQTMovieExporterCodecQuality"];
    return [NSDictionary dictionaryWithObjectsAndKeys:[[self codecConfiguration] objectForKey:@"HSQTMovieExporterCodecType"], QTAddImageCodecType, pvVar1_2, QTAddImageCodecQuality, nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00255dfe @ 00255dfe, 38 bytes * /

void FUN_00255dfe(HSQTMovieExporter *self,SEL _cmd,BOOL setUseRoundedCorners)

{
  byte bVar1;
  char cVar2;
  
  bVar1 = (byte)self->_canUseRoundedCorners;
  cVar2 = -1;
  if ((bVar1 & 1) == 0) {
    cVar2 = '\0';
  }
  if (cVar2 != setUseRoundedCorners) {
    *(byte *)&self->_canUseRoundedCorners = bVar1 & 0xfe | setUseRoundedCorners & 1U;
  }
  return;
}

*/
- (void)setUseRoundedCorners:(BOOL)aCorners
{
    if (_canUseRoundedCorners != aCorners) {
        _canUseRoundedCorners = aCorners;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00255de8 @ 00255de8, 22 bytes * /

BOOL FUN_00255de8(HSQTMovieExporter *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_canUseRoundedCorners & 1) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)canUseRoundedCorners
{
    return _canUseRoundedCorners;
}

- (void)setSlideDelay:(CGFloat)aDelay
{
    _slideDelay = aDelay;
}

- (CGFloat)slideDelay
{
    return _slideDelay;
}

- (void)setTransitionName:(id)aName
{
    if (![_transitionName isEqualToString:aName]) {
        [_transitionName release];
        _transitionName = [aName retain];
    }
}

- (id)transitionName
{
    return _transitionName;
}

- (void)setMovieFrameSize:(NSSize)aSize
{
    id pvVar1_2;

    pvVar1_2 = [[self codecConfiguration] mutableCopy];
    [pvVar1_2 setObject:[NSValue valueWithSize:aSize] forKey:@"HSQTMovieExporterMovieFrameSize"];
    [self setCodecConfiguration:pvVar1_2];
    [pvVar1_2 release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00255edd @ 00255edd, 122 bytes * /

ulonglong FUN_00255edd(HSQTMovieExporter *self,SEL _cmd)

{
  id pvVar1;
  undefined4 extraout_EDX;
  SEL op;
  cfstringStruct *pcVar2;
  
  pvVar1 = _objc_msgSend(self,sel_codecConfiguration);
  pcVar2 = &cfstr_HSQTMovieExporterMovieFrameSize;
  pvVar1 = _objc_msgSend(pvVar1,sel_objectForKey_,&cfstr_HSQTMovieExporterMovieFrameSize);
  op = sel_sizeValue;
  if (pvVar1 == (id)0x0) {
    pvVar1 = _objc_msgSend(self,sel_dataSource,pcVar2);
    op = sel_movieFrameSize;
  }
  pvVar1 = _objc_msgSend(pvVar1,op,pcVar2);
  return CONCAT44(extraout_EDX,pvVar1);
}

*/
- (NSSize)movieFrameSize
{
    id sizeValue = [[self codecConfiguration] objectForKey:HSQTMovieExporterMovieFrameSize];
    if (sizeValue != nil) {
        return [sizeValue sizeValue];
    }
    return [[self dataSource] movieFrameSize];
}

- (CGFloat)exportFPS
{
    return (float)[self framesPerSecondLimit];
}

- (void)setCodecConfiguration:(id)aConfiguration
{
    if (_codeConfiguration != aConfiguration) {
        [_codeConfiguration release];
        _codeConfiguration = [aConfiguration retain];
    }
}

- (id)codecConfiguration
{
    id pvVar1;

    pvVar1 = _codeConfiguration;
    if (pvVar1 == nil) {
        [self setCodecConfiguration:[[[self class] defaultCodecConfigurationForMovie] retain]];
        pvVar1 = _codeConfiguration;
    }
    return pvVar1;
}

- (void)setDataSource:(id)aSource
{
    [super setDataSource:aSource];
}

- (void)dealloc
{
    [_codeConfiguration release];
    [_cornersClipPath release];
    [self cleanupMovieAfterExport];
    [super dealloc];
}

@end

