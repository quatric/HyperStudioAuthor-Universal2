#import "HSImportDialogMoviesInUsePaneViewController.h"

@implementation HSImportDialogMoviesInUsePaneViewController

/* i386 ivar offsets: _playableObjectsInUse=0xa4 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_002350eb @ 002350eb, 152 bytes * /

void FUN_002350eb(id self,SEL _cmd)

{
  id self_00;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  _objc_msgSend(cls_HSImportDialogController,sel_registerPaneViewController_withIdentifier_,self,
                *(undefined4 *)PTR_PTR_00336670);
  _objc_msgSend(cls_HSImportDialogController,sel_registerPaneViewController_withIdentifier_,self,
                *(undefined4 *)PTR_PTR_003360cc);
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
+ (void)load
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeMovies];
    [HSImportDialogController registerPaneViewController:self withIdentifier:HSImportDialogControllerTypeAnimations];
    [pool release];
}

- (BOOL)isAttributesNotificationPostingDisabled
{
    return NO;
}

- (id)cardGroupController
{
    return nil;
}

- (id)delegate
{
    return nil;
}

- (id)scriptController
{
    return nil;
}

- (id)undoManager
{
    return nil;
}

- (id)movieAtIndex:(NSUInteger)aIndex
{
    id pvVar1_7;
    id pvVar1_9;

    if (aIndex < [[self playableObjectsInUse] count]) {
        pvVar1_7 = [[[[[self playableObjectsInUse] objectAtIndex:aIndex] hyperObject] localCopyIncludingNodeUnits:YES] autorelease];
        [pvVar1_7 setSupport:self];
        pvVar1_9 = [[pvVar1_7 queryHyperInterface:@protocol(HSMovieObjectAttributes)] hyperMovie];
    }
    else {
        pvVar1_9 = nil;
    }
    return pvVar1_9;
}

- (void)selectionDidChangeInGridControl:(id)aControl
{
    NSUInteger pvVar1;

    [super selectionDidChangeInGridControl:aControl]
    ;
    pvVar1 = [_imageGrid selectedItemIndex];
    if (pvVar1 != NSNotFound) {
        if (pvVar1 < [[self playableObjectsInUse] count]) {
            [_playButton setEnabled:(unsigned int)([[[self playableObjectsInUse] objectAtIndex:pvVar1] implementsHyperInterface:@protocol(HSPlayableObjectAttributes)])];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00234f76 @ 00234f76, 124 bytes * /

id FUN_00234f76(HSImportDialogMoviesInUsePaneViewController *self,SEL _cmd,id gridControl,
               int imageForItemAt)

{
  undefined *puVar1;
  id pvVar2;
  undefined *self_00;
  SEL op;
  
  puVar1 = cls_HSUserObjectInEditorPreviewView;
  if (((self->super)._playableItemIndex != imageForItemAt) ||
     (self_00 = (self->super)._movie, op = sel_currentFrameImage, self_00 == (undefined *)0x0)) {
    pvVar2 = _objc_msgSend(self,sel_playableObjectsInUse);
    _objc_msgSend(pvVar2,sel_objectAtIndex_,imageForItemAt);
    self_00 = puVar1;
    op = sel_previewImageForObject_;
  }
  pvVar2 = _objc_msgSend(self_00,op);
  return pvVar2;
}

*/
- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    if (_playableItemIndex != aAt || _movie == nil) {
        return [HSUserObjectInEditorPreviewView previewImageForObject:[[self playableObjectsInUse] objectAtIndex:aAt]];
    }
    return [_movie currentFrameImage];
    return 0;
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    return [[[[self playableObjectsInUse] objectAtIndex:aAt] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00234e1e @ 00234e1e, 233 bytes * /

int FUN_00234e1e(HSImportDialogMoviesInUsePaneViewController *self,SEL _cmd,
                id numberOfItemsInGridControl)

{
  undefined *self_00;
  undefined *self_01;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(self,sel_playableObjectsInUse);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  self_01 = cls_NSString;
  self_00 = cls_NSBundle;
  pvVar1 = (self->super)._itemsCountTextField;
  pvVar3 = _objc_msgSend(self,sel_class);
  pvVar3 = _objc_msgSend(self_00,sel_bundleForClass_,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr__dItems,&cfstr_empty,
                         &cfstr_ImportDialogs);
  pvVar3 = _objc_msgSend(self_01,sel_stringWithFormat_,pvVar3,pvVar2);
  _objc_msgSend(pvVar1,sel_setStringValue_,pvVar3);
  return (int)pvVar2;
}

*/
- (NSInteger)numberOfItemsInGridControl:(id)aControl
{
    NSUInteger count = [[self playableObjectsInUse] count];
    NSString *format = [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"%dItems" value:@"" table:@"ImportDialogs"];
    [_itemsCountTextField setStringValue:[NSString stringWithFormat:format, (int)count]];
    return count;
    return 0;
}

- (id)playableObjectsInUse
{
    id pvVar1;

    pvVar1 = _playableObjectsInUse;
    if (pvVar1 == nil) {
        pvVar1 = [[HSMoviesInUseProvider moviesInUseForStack:[[self paneHyperDocument] stack]] retain];
        _playableObjectsInUse = pvVar1;
    }
    return pvVar1;
}

- (void)willUnmountFromDialogController:(id)aController
{
    [_playableObjectsInUse release];
    _playableObjectsInUse = nil;
    [super willUnmountFromDialogController:aController]
    ;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00235338 @ 00235338, 403 bytes * /

void FUN_00235338(HSImportDialogMoviesInUsePaneViewController *self,SEL _cmd,
                 id willMountToDialogController)

{
  undefined4 uVar1;
  id self_00;
  id pvVar2;
  id self_01;
  id pvVar3;
  undefined4 uVar4;
  HSImportDialogMoviesInUsePaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogMoviesPaneViewCont_00355550;
  _objc_msgSendSuper(&local_1c,sel_willMountToDialogController_,willMountToDialogController);
  _objc_msgSend(self,sel_storeSelection);
  if ((self->super)._imageGrid != (id)0x0) {
    self_00 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
    pvVar2 = _objc_msgSend((self->super)._imageGrid,sel_tryLockBeforeReloadingData);
    if ((char)pvVar2 == '\0') {
      uVar1 = *(undefined4 *)PTR_00336758;
      do {
        pvVar2 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc);
        self_01 = _objc_msgSend(pvVar2,sel_init);
        pvVar2 = (id)0x3f847ae1;
        uVar4 = 0x47ae147b;
        pvVar3 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceNow_,0x47ae147b,0x3f847ae1);
        if (pvVar3 != (id)0x0) {
          uVar4 = uVar1;
          _objc_msgSend(self_00,sel_runMode_beforeDate_,uVar1,pvVar3);
          pvVar2 = pvVar3;
        }
        _objc_msgSend(self_01,sel_release,uVar4,pvVar2);
        pvVar2 = _objc_msgSend((self->super)._imageGrid,sel_tryLockBeforeReloadingData);
      } while ((char)pvVar2 == '\0');
    }
  }
  _objc_msgSend(self->_playableObjectsInUse,sel_release);
  self->_playableObjectsInUse = (id)0x0;
  _objc_msgSend((self->super)._imageGrid,sel_reloadDataAndUnlock);
  _objc_msgSend(self,sel_restoreSelection);
  return;
}

*/
- (void)willMountToDialogController:(id)aController
{
    [super willMountToDialogController:aController];
    [self storeSelection];
    if (_imageGrid != nil) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        while (![_imageGrid tryLockBeforeReloadingData]) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0.01];
            if (date != nil) {
                [runLoop runMode:HSThumbnailGenerationRunLoopMode beforeDate:date];
            }
            [pool release];
        }
    }
    [_playableObjectsInUse release];
    _playableObjectsInUse = nil;
    [_imageGrid reloadDataAndUnlock];
    [self restoreSelection];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00234c9e @ 00234c9e, 260 bytes * /

id FUN_00234c9e(HSImportDialogMoviesInUsePaneViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  
  pvVar1 = _objc_msgSend(cls_HSImportDialogMoviesInUseUserOptions,sel_new);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  pvVar2 = _objc_msgSend((self->super)._imageGrid,sel_selectedItemIndex);
  if (pvVar2 != (id)0x7fffffff) {
    pvVar3 = _objc_msgSend(self,sel_playableObjectsInUse);
    pvVar3 = _objc_msgSend(pvVar3,sel_count);
    if (pvVar2 < pvVar3) {
      pvVar3 = _objc_msgSend(self,sel_playableObjectsInUse);
      pvVar2 = _objc_msgSend(pvVar3,sel_objectAtIndex_,pvVar2);
      pvVar3 = _objc_msgSend(pvVar2,sel_implementsHyperInterface_,&DAT_003841dc);
      if ((char)pvVar3 != '\0') {
        _objc_msgSend(pvVar1,sel_setValue_forKey_,pvVar2,*(undefined4 *)PTR_PTR_003360f0);
      }
    }
  }
  return pvVar1;
}

*/
- (id)paneUserOptions
{
    HSImportDialogMoviesInUseUserOptions *options = [[HSImportDialogMoviesInUseUserOptions new] autorelease];
    NSUInteger selected = [_imageGrid selectedItemIndex];
    if (selected != NSNotFound && selected < [[self playableObjectsInUse] count]) {
        id object = [[self playableObjectsInUse] objectAtIndex:selected];
        if ([object implementsHyperInterface:@protocol(HSPlayableObjectAttributes)]) {
            [options setValue:object forKey:HSImportDialogMoviesInUseOptionKeyPlayableObject];
        }
    }
    return options;
    return 0;
}

- (BOOL)isObjectValid
{
    NSUInteger pvVar1;

    pvVar1 = [_imageGrid selectedItemIndex];
    if (pvVar1 != NSNotFound) {
        if (pvVar1 < [[self playableObjectsInUse] count]) {
            if ([[[self playableObjectsInUse] objectAtIndex:pvVar1] implementsHyperInterface:@protocol(HSLiveObjectAttributes)]) {
                return YES;
            }
            return (BOOL)[super isObjectValid];
        }
    }
    return NO;
}

- (id)paneFilePath
{
    NSUInteger pvVar1;
    id pvVar1_3;

    pvVar1 = [_imageGrid selectedItemIndex];
    if (pvVar1 != NSNotFound) {
        if (pvVar1 < [[self playableObjectsInUse] count]) {
            pvVar1_3 = [[[self playableObjectsInUse] objectAtIndex:pvVar1] queryHyperInterface:@protocol(HSMovieObjectAttributes)];
            if (pvVar1_3 != nil) {
                return [[pvVar1_3 media] fullPathToMediaFile];
            }
        }
    }
    return nil;
}

- (id)paneTitle
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"ImportDialogMoviesInUsePaneTitle" value:@"" table:@"ImportDialogs"];
}

- (NSInteger)paneWeight
{
    return 4;
}

- (id)paneView
{
    id pvVar1;

    pvVar1 = _paneView;
    if (pvVar1 == nil) {
        [NSBundle loadNibNamed:[self paneViewNibName] owner:self];
        pvVar1 = _paneView;
    }
    return pvVar1;
}

- (id)paneIdentifier
{
    return @"HSImportDialogInUseMovies";
}

- (id)paneViewNibName
{
    return @"IDMoviesInUsePaneView";
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_002355a2 @ 002355a2, 418 bytes * /

void FUN_002355a2(HSImportDialogMoviesInUsePaneViewController *self,SEL _cmd)

{
  undefined4 uVar1;
  id self_00;
  id pvVar2;
  id self_01;
  id pvVar3;
  undefined4 uVar4;
  HSImportDialogMoviesInUsePaneViewController *local_1c;
  undefined *local_18;
  
  local_1c = self;
  local_18 = PTR_s_HSImportDialogMoviesPaneViewCont_00355550;
  _objc_msgSendSuper(&local_1c,sel_awakeFromNib);
  if ((self->super)._imageGrid != (id)0x0) {
    self_00 = _objc_msgSend(cls_NSRunLoop,sel_currentRunLoop);
    pvVar2 = _objc_msgSend((self->super)._imageGrid,sel_tryLockBeforeReloadingData);
    if ((char)pvVar2 == '\0') {
      uVar1 = *(undefined4 *)PTR_00336758;
      do {
        pvVar2 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc);
        self_01 = _objc_msgSend(pvVar2,sel_init);
        pvVar2 = (id)0x3f847ae1;
        uVar4 = 0x47ae147b;
        pvVar3 = _objc_msgSend(cls_NSDate,sel_dateWithTimeIntervalSinceNow_,0x47ae147b,0x3f847ae1);
        if (pvVar3 != (id)0x0) {
          uVar4 = uVar1;
          _objc_msgSend(self_00,sel_runMode_beforeDate_,uVar1,pvVar3);
          pvVar2 = pvVar3;
        }
        _objc_msgSend(self_01,sel_release,uVar4,pvVar2);
        pvVar2 = _objc_msgSend((self->super)._imageGrid,sel_tryLockBeforeReloadingData);
      } while ((char)pvVar2 == '\0');
    }
  }
  _objc_msgSend(self->_playableObjectsInUse,sel_release);
  self->_playableObjectsInUse = (id)0x0;
  _objc_msgSend((self->super)._imageGrid,sel_reloadDataAndUnlock);
  _objc_msgSend((self->super)._playButton,sel_setEnabled_,0);
  _objc_msgSend((self->super)._imageGrid,sel_setThreadedPreloadingEnabled_,0);
  return;
}

*/
- (void)awakeFromNib
{
    [super awakeFromNib];
    if (_imageGrid != nil) {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        while (![_imageGrid tryLockBeforeReloadingData]) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0.01];
            if (date != nil) {
                [runLoop runMode:HSThumbnailGenerationRunLoopMode beforeDate:date];
            }
            [pool release];
        }
    }
    [_playableObjectsInUse release];
    _playableObjectsInUse = nil;
    [_imageGrid reloadDataAndUnlock];
    [_playButton setEnabled:NO];
    [_imageGrid setThreadedPreloadingEnabled:NO];
}

- (void)dealloc
{
    [_playableObjectsInUse release];
    [super dealloc];
}

@end

