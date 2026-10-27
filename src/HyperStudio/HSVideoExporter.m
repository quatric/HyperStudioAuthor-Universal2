#import "HSVideoExporter.h"

@implementation HSVideoExporter

/* i386 ivar offsets: _currentExporter=0x24, _videoExportFormat=0x28, _videoExportOption=0x2c, _videoExportDevice=0x30, _movieFrameSize=0x34, _transitionName=0x3c, _slideDelay=0x40, _useRoundedCorners=0x44 */

- (id)hyperCastingLauncherForExporter:(id)aExporter
{
    return [[self dataSource] hyperCastingLauncherForExporter:aExporter];
}

- (void)setCurrentTimeForMovies:(double)aMovies runOnStart:(BOOL)aStart onCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    [[self dataSource] setCurrentTimeForMovies:aMovies runOnStart:aStart onCardAtIndex:aIndex forExporter:aExporter];
}

- (double)timeIntervalBetweenFrames
{
    return [[self dataSource] timeIntervalBetweenFrames];
}

- (double)transitionTimeAfterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    return [[self dataSource] transitionTimeAfterCardAtIndex:aIndex forExporter:aExporter];
}

- (BOOL)hasTransitionAfterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    return (BOOL)[[self dataSource] hasTransitionAfterCardAtIndex:aIndex forExporter:aExporter];
}

- (id)transitionImageForTime:(double)aTime afterCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    return [[self dataSource] transitionImageForTime:aTime afterCardAtIndex:aIndex forExporter:aExporter];
}

- (double)timeDelayOnArriveOnCardAtIndex:(NSUInteger)aIndex
{
    return [[self dataSource] timeDelayOnArriveOnCardAtIndex:aIndex];
}

- (double)asyncSoundLengthOnCardAtIndex:(NSUInteger)aIndex
{
    return [[self dataSource] asyncSoundLengthOnCardAtIndex:aIndex];
}

- (BOOL)asyncSoundPresentOnCardAtIndex:(NSUInteger)aIndex
{
    return (BOOL)[[self dataSource] asyncSoundPresentOnCardAtIndex:aIndex];
}

- (id)soundsWithPropertiesOnCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    return [[self dataSource] soundsWithPropertiesOnCardAtIndex:aIndex forExporter:aExporter];
}

- (id)moviesWithPropertiesOnCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    return [[self dataSource] moviesWithPropertiesOnCardAtIndex:aIndex forExporter:aExporter];
}

- (id)artworkImageForExporter:(id)aExporter
{
    return [[self dataSource] artworkImageForExporter:aExporter];
}

- (id)imageForCardAtIndex:(NSUInteger)aIndex forExporter:(id)aExporter
{
    return [[self dataSource] imageForCardAtIndex:aIndex forExporter:aExporter];
}

- (id)exportedCardIndexesForExporter:(id)aExporter onlySelected:(BOOL)aSelected
{
    return [[self dataSource] exportedCardIndexesForExporter:aExporter onlySelected:(unsigned int)aSelected];
}

- (NSSize)videoFrameSize
{
    return [[self dataSource] videoFrameSize];
}

- (void)exportDidTerminate:(id)aTerminate
{
    [self notifyExportDidTerminate];
}

- (void)exportDidEnd:(id)aEnd
{
    [self notifyExportDidEnd];
}

- (void)exportWillEnd:(id)aEnd
{
    [self notifyExportWillEnd];
}

- (void)exportDidStart:(id)aStart
{
    [self notifyExportDidStart];
}

- (void)exportWillStart:(id)aStart withSlideshowAttributes:(id)aAttributes
{
    [self notifyExportWillStartWithSlideshowAttributes:aAttributes];
}

- (void)exportErrorInProgress:(id)aProgress error:(id)aError
{
    [self notifyExportErrorInProgress:aError];
}

- (void)exportProgressDidChange:(id)aChange withProgress:(double)aProgress
{
    [self notifyExportProgressDidChangeWithProgress:aProgress];
}

- (void)terminateExport
{
    [[self currentExporter] terminateExport];
}

- (void)performExportDocument:(id)aDocument ofType:(id)aType
{
    id self_00;

    [self destroyCurrentExporter];
    self_00 = [self currentExporter];
    [self_00 setExportedDocumentName:[self exportedDocumentName]];
    [self_00 exportDocument:aDocument ofType:aType];
}

- (void)destroyCurrentExporter
{
    if (_currentExporter != nil) {
        if ([_currentExporter dataSource] == self) {
            [_currentExporter setDataSource:0];
        }
        if ([_currentExporter delegate] == self) {
            [_currentExporter setDelegate:0];
        }
        [_currentExporter release];
        _currentExporter = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025feec @ 0025feec, 87 bytes * /

id FUN_0025feec(HSVideoExporter *self,SEL _cmd)

{
  id pvVar1;
  HSExporter2 *pHVar2;
  SEL op;
  
  pHVar2 = self->_currentExporter;
  if (pHVar2 == (HSExporter2 *)0x0) {
    pvVar1 = _objc_msgSend(self,sel_videoExportOption);
    op = sel_createQTMovieExporter;
    if (pvVar1 == (id)0x1) {
      op = sel_createHyperCastingExporter;
    }
    pHVar2 = _objc_msgSend(self,op);
    self->_currentExporter = pHVar2;
  }
  return pHVar2;
}

*/
- (id)currentExporter
{
    if (_currentExporter == nil) {
        if ([self videoExportOption] == 1) {
            _currentExporter = [self createHyperCastingExporter];
        } else {
            _currentExporter = [self createQTMovieExporter];
        }
    }
    return _currentExporter;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0026063f @ 0026063f, 455 bytes * /

id FUN_0026063f(HSVideoExporter *self,SEL _cmd)

{
  id self_00;
  id pvVar1;
  undefined4 uVar2;
  undefined4 extraout_EDX;
  double dVar3;
  id local_18;
  undefined4 local_14;
  
  self_00 = _objc_msgSend(cls_HSHyperCastingExporter,sel_new);
  pvVar1 = _objc_msgSend(self,sel_videoExportDevice);
  switch(pvVar1) {
  case (id)0x1:
    uVar2 = 1;
    local_14 = 0x43700000;
    local_18 = (id)0x43a00000;
    break;
  case (id)0x2:
    uVar2 = 2;
    local_14 = 0x43a00000;
    local_18 = (id)0x43f00000;
    break;
  case (id)0x3:
    uVar2 = 3;
    local_14 = 0x44200000;
    local_18 = (id)0x44700000;
    break;
  case (id)0x4:
    uVar2 = 4;
    local_14 = 0x44400000;
    local_18 = (id)0x44800000;
    break;
  default:
    local_18 = _objc_msgSend(self,sel_movieFrameSize);
    uVar2 = 0;
    local_14 = extraout_EDX;
  }
  _objc_msgSend(self_00,sel_setRecordedMovieFormat_,uVar2);
  _objc_msgSend(self_00,sel_setMovieFrameSize_,local_18,local_14);
  pvVar1 = _objc_msgSend(self,sel_canUseRoundedCorners);
  _objc_msgSend(self_00,sel_setUseRoundedCorners_,(int)(char)pvVar1);
  _objc_msgSend(self_00,sel_setDataSource_,self);
  _objc_msgSend(self_00,sel_setDelegate_,self);
  dVar3 = _objc_msgSend_fpret(self,sel_framesPerSecondLimit);
  _objc_msgSend(self_00,sel_setFramesPerSecondLimit_,dVar3);
  return self_00;
}

*/
- (id)createHyperCastingExporter
{
    HSHyperCastingExporter *exporter = [HSHyperCastingExporter new];
    NSInteger format;
    NSSize frameSize;
    switch ([self videoExportDevice]) {
        case 1:
            format = 1;
            frameSize = NSMakeSize(320.0, 240.0);
            break;
        case 2:
            format = 2;
            frameSize = NSMakeSize(480.0, 320.0);
            break;
        case 3:
            format = 3;
            frameSize = NSMakeSize(960.0, 640.0);
            break;
        case 4:
            format = 4;
            frameSize = NSMakeSize(1024.0, 768.0);
            break;
        default:
            frameSize = [self movieFrameSize];
            format = 0;
            break;
    }
    [exporter setRecordedMovieFormat:format];
    [exporter setMovieFrameSize:frameSize];
    [exporter setUseRoundedCorners:[self canUseRoundedCorners]];
    [exporter setDataSource:self];
    [exporter setDelegate:self];
    [exporter setFramesPerSecondLimit:[self framesPerSecondLimit]];
    return exporter;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00260818 @ 00260818, 569 bytes * /

id FUN_00260818(HSVideoExporter *self,SEL _cmd)

{
  undefined *puVar1;
  id self_00;
  id pvVar2;
  id self_01;
  SEL op;
  undefined4 extraout_EDX;
  double dVar3;
  
  self_00 = _objc_msgSend(cls_HSQTMovieExporter,sel_new);
  pvVar2 = _objc_msgSend(self,sel_videoExportDevice);
  puVar1 = cls_NSMutableDictionary;
  switch(pvVar2) {
  case (id)0x1:
    op = sel_defaultCodecConfigurationForIPodMovie;
    break;
  case (id)0x2:
    op = sel_defaultCodecConfigurationForIPhoneMovie;
    break;
  case (id)0x3:
    op = sel_defaultCodecConfigurationForIPhone4Movie;
    break;
  case (id)0x4:
    op = sel_defaultCodecConfigurationForIPadMovie;
    break;
  default:
    pvVar2 = _objc_msgSend(cls_HSQTMovieExporter,sel_defaultCodecConfigurationForMovie);
    self_01 = _objc_msgSend(puVar1,sel_dictionaryWithDictionary_,pvVar2);
    puVar1 = cls_NSValue;
    pvVar2 = _objc_msgSend(self,sel_movieFrameSize);
    pvVar2 = _objc_msgSend(puVar1,sel_valueWithSize_,pvVar2,extraout_EDX);
    _objc_msgSend(self_01,sel_setObject_forKey_,pvVar2,*(undefined4 *)PTR_PTR_00336944);
    goto LAB_00260976;
  }
  pvVar2 = _objc_msgSend(cls_HSQTMovieExporter,op);
  self_01 = _objc_msgSend(puVar1,sel_dictionaryWithDictionary_,pvVar2);
LAB_00260976:
  _objc_msgSend(self_00,sel_setCodecConfiguration_,self_01);
  pvVar2 = _objc_msgSend(self,sel_canUseRoundedCorners);
  _objc_msgSend(self_00,sel_setUseRoundedCorners_,(int)(char)pvVar2);
  _objc_msgSend(self_00,sel_setTransitionName_,self->_transitionName);
  _objc_msgSend(self_00,sel_setSlideDelay_,self->_slideDelay);
  _objc_msgSend(self_00,sel_setDataSource_,self);
  _objc_msgSend(self_00,sel_setDelegate_,self);
  dVar3 = _objc_msgSend_fpret(self,sel_framesPerSecondLimit);
  _objc_msgSend(self_00,sel_setFramesPerSecondLimit_,dVar3);
  return self_00;
}

*/
- (id)createQTMovieExporter
{
    HSQTMovieExporter *exporter = [HSQTMovieExporter new];
    NSMutableDictionary *configuration;
    switch ([self videoExportDevice]) {
        case 1:
            configuration = [NSMutableDictionary dictionaryWithDictionary:[HSQTMovieExporter defaultCodecConfigurationForIPodMovie]];
            break;
        case 2:
            configuration = [NSMutableDictionary dictionaryWithDictionary:[HSQTMovieExporter defaultCodecConfigurationForIPhoneMovie]];
            break;
        case 3:
            configuration = [NSMutableDictionary dictionaryWithDictionary:[HSQTMovieExporter defaultCodecConfigurationForIPhone4Movie]];
            break;
        case 4:
            configuration = [NSMutableDictionary dictionaryWithDictionary:[HSQTMovieExporter defaultCodecConfigurationForIPadMovie]];
            break;
        default:
            configuration = [NSMutableDictionary dictionaryWithDictionary:[HSQTMovieExporter defaultCodecConfigurationForMovie]];
            [configuration setObject:[NSValue valueWithSize:[self movieFrameSize]] forKey:HSQTMovieExporterMovieFrameSize];
            break;
    }
    [exporter setCodecConfiguration:configuration];
    [exporter setUseRoundedCorners:[self canUseRoundedCorners]];
    [exporter setTransitionName:_transitionName];
    [exporter setSlideDelay:_slideDelay];
    [exporter setDataSource:self];
    [exporter setDelegate:self];
    [exporter setFramesPerSecondLimit:[self framesPerSecondLimit]];
    return exporter;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025fce2 @ 0025fce2, 502 bytes * /

id FUN_0025fce2(HSVideoExporter *self,SEL _cmd)

{
  undefined *self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  
  pvVar1 = _objc_msgSend(self,sel_videoExportDevice);
  self_00 = cls_NSBundle;
  switch(pvVar1) {
  case (id)0x0:
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pcVar2 = &cfstr_ExportSheetProgressQuickTimeMovieDescription;
    break;
  case (id)0x1:
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pcVar2 = &cfstr_ExportSheetProgressIPodDescription;
    break;
  case (id)0x2:
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pcVar2 = &cfstr_ExportSheetProgressIPhoneDescription;
    break;
  case (id)0x3:
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pcVar2 = &cfstr_ExportSheetProgressIPhone4Description;
    break;
  case (id)0x4:
    pvVar1 = _objc_msgSend(self,sel_class);
    pvVar1 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar1);
    pcVar2 = &cfstr_ExportSheetProgressIPadDescription;
    break;
  default:
    return (id)0x0;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar2,&cfstr_empty,
                         &cfstr_Export);
  return pvVar1;
}

*/
- (id)progressSheetDescription
{
    NSString *key;
    switch ([self videoExportDevice]) {
        case 0: key = @"ExportSheetProgressQuickTimeMovieDescription"; break;
        case 1: key = @"ExportSheetProgressIPodDescription"; break;
        case 2: key = @"ExportSheetProgressIPhoneDescription"; break;
        case 3: key = @"ExportSheetProgressIPhone4Description"; break;
        case 4: key = @"ExportSheetProgressIPadDescription"; break;
        default: return nil;
    }
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:key value:@"" table:@"Export"];
}

- (BOOL)isSupportedProgressSheet
{
    return (BOOL)[[self currentExporter] isSupportedProgressSheet];
}

- (id)exportAccessoryViewControllerForPublishType:(NSInteger)aType
{
    id pvVar1;
    id pvVar1_3;

    pvVar1 = _exportAccessoryViewController;
    if (pvVar1 == nil) {
        if ([self videoExportFormat] == 0x1) {
            pvVar1_3 = [HSPodcastExportAccessoryViewController alloc];
        }
        else {
            pvVar1_3 = [HSQuickTimeExportAccessoryViewController alloc];
        }
        pvVar1 = [pvVar1_3 initWithExporter:self publishType:aType];
        _exportAccessoryViewController = pvVar1;
    }
    return pvVar1;
}

- (id)exportRepresentation
{
    return [[self currentExporter] exportRepresentation];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0025fb08 @ 0025fb08, 38 bytes * /

void FUN_0025fb08(HSVideoExporter *self,SEL _cmd,BOOL setUseRoundedCorners)

{
  byte bVar1;
  char cVar2;
  
  bVar1 = (byte)self->_useRoundedCorners;
  cVar2 = -1;
  if ((bVar1 & 1) == 0) {
    cVar2 = '\0';
  }
  if (cVar2 != setUseRoundedCorners) {
    *(byte *)&self->_useRoundedCorners = bVar1 & 0xfe | setUseRoundedCorners & 1U;
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_0025faf2 @ 0025faf2, 22 bytes * /

BOOL FUN_0025faf2(HSVideoExporter *self,SEL _cmd)

{
  BOOL BVar1;
  
  BVar1 = -1;
  if ((self->_useRoundedCorners & 1) == 0) {
    BVar1 = '\0';
  }
  return BVar1;
}

*/
- (BOOL)canUseRoundedCorners
{
    return _useRoundedCorners ? YES : NO;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00260a64 @ 00260a64, 88 bytes * /

void FUN_00260a64(HSVideoExporter *self,SEL _cmd,NSSize setMovieFrameSize)

{
  char cVar1;
  
  cVar1 = _NSEqualSizes((self->_movieFrameSize).width,(self->_movieFrameSize).height,
                        setMovieFrameSize.width,setMovieFrameSize.height);
  if (cVar1 == '\0') {
    (self->_movieFrameSize).width = setMovieFrameSize.width;
    (self->_movieFrameSize).height = setMovieFrameSize.height;
  }
  return;
}

*/
/* --- i386 decompilation (Ghidra) ---
/* FUN_00260abc @ 00260abc, 151 bytes * /

ulonglong FUN_00260abc(HSVideoExporter *self,SEL _cmd)

{
  char cVar1;
  id pvVar2;
  float extraout_EDX;
  float fVar3;
  
  cVar1 = _NSEqualSizes((self->_movieFrameSize).width,(self->_movieFrameSize).height,
                        *(undefined4 *)PTR_0033607c,*(undefined4 *)(PTR_0033607c + 4));
  if (cVar1 == '\0') {
    pvVar2 = (id)(self->_movieFrameSize).width;
    fVar3 = (self->_movieFrameSize).height;
  }
  else {
    pvVar2 = _objc_msgSend(self,sel_dataSource);
    pvVar2 = _objc_msgSend(pvVar2,sel_videoFrameSize);
    (self->_movieFrameSize).width = (float)pvVar2;
    (self->_movieFrameSize).height = extraout_EDX;
    fVar3 = extraout_EDX;
  }
  return CONCAT44(fVar3,pvVar2);
}

*/
- (void)setDataSource:(id)aSource
{
    [super setDataSource:aSource];
}

- (void)dealloc
{
    if (_currentExporter != nil) {
        [self destroyCurrentExporter];
    }
    [super dealloc];
}

- (id)defaultExportSettings
{
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithDictionary:[super defaultExportSettings]];
    [settings setValue:[NSNumber numberWithDouble:10.0] forKey:HSVideoExportFramesPerSecondKey];
    [settings setValue:[NSNumber numberWithInt:0] forKey:HSVideoExportDeviceKey];
    return settings;
}

- (id)exportSettingsValueForKey:(id)aKey
{
    id value = [super exportSettingsValueForKey:aKey];
    if (value != nil)
        return value;
    if ([aKey isEqualToString:HSVideoExportFrameSizeKey])
        return [NSValue valueWithSize:[[self dataSource] videoFrameSize]];
    if ([aKey isEqualToString:HSVideoExportAllowsNarrationKey])
        return [NSNumber numberWithBool:[[self dataSource] canExportDocumentAsVideoWithNarration]];
    return nil;
}

@end

