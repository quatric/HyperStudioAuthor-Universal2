#import "HSPatternPicker.h"

static id sSharedPatternPicker;

@implementation HSPatternPicker

/* i386 ivar offsets: _gridControl=0x1c, _imageView=0x20, _mediaDataFolder=0x24, _colors=0x28 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_00136d93 @ 00136d93, 224 bytes * /

id FUN_00136d93(id self,SEL _cmd,NSZone *allocWithZone)

{
  bool bVar1;
  int iVar2;
  id unaff_EBX;
  id local_7c;
  undefined *local_78;
  int local_74 [23];
  NSZone *local_18;
  id local_14;
  
  local_14 = self;
  local_18 = allocWithZone;
  _objc_sync_enter(self);
  _objc_exception_try_enter(local_74);
  iVar2 = __setjmp(local_74);
  if (iVar2 == 0) {
    if (DAT_00342950 == (id)0x0) {
      local_7c = local_14;
      local_78 = PTR_s_HSColorPicker_0035a6b0;
      unaff_EBX = _objc_msgSendSuper(&local_7c,sel_allocWithZone_,local_18);
      iVar2 = 0;
      bVar1 = false;
      DAT_00342950 = unaff_EBX;
    }
    else {
      bVar1 = true;
      iVar2 = 0;
      unaff_EBX = (id)0x0;
    }
  }
  else {
    iVar2 = _objc_exception_extract(local_74);
    if (iVar2 != 0) {
      bVar1 = true;
      goto LAB_00136e48;
    }
    bVar1 = true;
    unaff_EBX = (id)0x0;
  }
  _objc_exception_try_exit(local_74);
LAB_00136e48:
  _objc_sync_exit(self);
  if (iVar2 != 0) {
                    /* WARNING: Subroutine does not return * /
    _objc_exception_throw(iVar2);
  }
  if (bVar1) {
    unaff_EBX = (id)0x0;
  }
  return unaff_EBX;
}

*/
+ (id)allocWithZone:(NSZone *)aZone
{
    @synchronized(self) {
        if (sSharedPatternPicker == nil) {
            sSharedPatternPicker = [super allocWithZone:aZone];
            return sSharedPatternPicker;
        }
    }
    return nil;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00136e73 @ 00136e73, 175 bytes * /

id FUN_00136e73(id self,SEL _cmd)

{
  int iVar1;
  id self_00;
  int local_6c [22];
  id local_14;
  
  local_14 = self;
  _objc_sync_enter(self);
  _objc_exception_try_enter(local_6c);
  iVar1 = __setjmp(local_6c);
  if (iVar1 == 0) {
    if (DAT_00342950 == (id)0x0) {
      self_00 = _objc_msgSend(local_14,sel_alloc);
      _objc_msgSend(self_00,sel_init);
    }
    iVar1 = 0;
  }
  else {
    iVar1 = _objc_exception_extract(local_6c);
    if (iVar1 != 0) goto LAB_00136efb;
  }
  _objc_exception_try_exit(local_6c);
LAB_00136efb:
  _objc_sync_exit(self);
  if (iVar1 != 0) {
                    /* WARNING: Subroutine does not return * /
    _objc_exception_throw(iVar1);
  }
  return DAT_00342950;
}

*/
+ (id)sharedPatternPicker
{
    @synchronized(self) {
        if (sSharedPatternPicker == nil) {
            [[self alloc] init];
        }
    }
    return sSharedPatternPicker;
    return 0;
}

- (void)chooseImageFromFile:(id)aFile
{
    id pvVar1_2;
    id pvVar1_3;
    NSColor *pvVar2_2;

    pvVar1_2 = [[HSOpenPanelProvider sharedOpenPanelProvider] chooseFileOfType:kHSImageFileType];
    pvVar1_3 = [[NSImage alloc] initWithContentsOfFile:pvVar1_2];
    if (pvVar1_3 != nil) {
        pvVar2_2 = [NSColor colorWithPatternImage:pvVar1_3];
        [[self colorPanel] setColor:pvVar2_2];
        [pvVar1_3 release];
    }
}

- (void)imageDidChangeInImageView:(id)aView
{
    NSImage *pvVar1;
    NSColor *pvVar1_2;

    pvVar1 = [aView image];
    if (pvVar1 != nil) {
        pvVar1_2 = [NSColor colorWithPatternImage:pvVar1];
        [[self colorPanel] setColor:pvVar1_2];
    }
}

- (void)setColor:(id)aColor
{
    NSUInteger pvVar1_2;

    pvVar1_2 = [[self colors] indexOfObjectIdenticalTo:aColor];
    if (pvVar1_2 == NSNotFound) {
        pvVar1_2 = NSNotFound;
    }
    [_gridControl selectItemAtIndex:pvVar1_2 byExtendingSelection:NO];
    if ([[aColor colorSpaceName] isEqualToString:NSPatternColorSpace]) {
        aColor = [NSColor colorWithPatternImage:[aColor patternImage]];
    }
    [_imageView setImage:[self imageForColor:aColor]];
}

- (id)nibName
{
    return @"HSPatternPicker";
}

- (id)imageName
{
    return @"PatternPicker";
}

- (NSInteger)currentMode
{
    return 9;
}

- (BOOL)supportsMode:(NSInteger)aMode
{
    return aMode == 4 || aMode == 9;
}

- (id)buttonToolTip
{
    return [[NSBundle bundleForClass:[self class]] localizedStringForKey:@"Pattern" value:@"" table:@"ColorPickers"];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_0013691a @ 0013691a, 208 bytes * /

id FUN_0013691a(HSPatternPicker *self,SEL _cmd,id imageForColor)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(cls_NSImage,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithSize_,0x42700000,0x42700000);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  _objc_msgSend(pvVar1,sel_lockFocus);
  _objc_msgSend(imageForColor,sel_drawSwatchInRect_,0,0x4270000042700000);
  _objc_msgSend(pvVar1,sel_unlockFocus);
  return pvVar1;
}

*/
- (id)imageForColor:(id)aColor
{
    NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize(60.0, 60.0)] autorelease];
    [image lockFocus];
    [aColor drawSwatchInRect:NSMakeRect(0.0, 0.0, 60.0, 60.0)];
    [image unlockFocus];
    return image;
    return 0;
}

- (id)colors
{
    id pvVar1;

    pvVar1 = _colors;
    if (pvVar1 == nil) {
        _colors = [[NSMutableArray alloc] init];
        [self addItemsFromMediaDataFolder:[self mediaDataFolder]];
        pvVar1 = _colors;
    }
    return pvVar1;
}

- (void)addItemsFromMediaDataFolder:(id)aFolder
{
    NSUInteger pvVar1;
    int iVar4;
    NSUInteger pvVar1_2;
    int iVar4_2;
    id pvVar2_3;
    id pvVar2_4;

    pvVar1 = [aFolder numberOfDataItems];
    if (0 < (int)pvVar1) {
        iVar4 = 0;
        do {
            pvVar2_3 = [[[aFolder dataItemAtIndex:iVar4] dataURL] path];
            pvVar2_4 = [[NSImage alloc] initWithContentsOfFile:pvVar2_3];
            [_colors addObject:[NSColor colorWithPatternImage:pvVar2_4]];
            [pvVar2_4 release];
            iVar4 = iVar4 + 1;
        } while (iVar4 < (int)pvVar1);
    }
    pvVar1_2 = [aFolder numberOfDataFolders];
    if (0 < (int)pvVar1_2) {
        iVar4_2 = 0;
        do {
            [self addItemsFromMediaDataFolder:[aFolder dataFolderAtIndex:iVar4_2]];
            iVar4_2 = iVar4_2 + 1;
        } while (iVar4_2 < (int)pvVar1_2);
    }
}

- (id)mediaData
{
    return [[self mediaDataProvider] queryInterface:@protocol(HSLibraryMediaData)];
}

- (id)mediaDataProvider
{
    return [[HSLibraryManager sharedLibraryManager] providerForMediaType:[self mediaType]];
}

- (id)mediaDataFolder
{
    id pvVar1;

    pvVar1 = _mediaDataFolder;
    if (pvVar1 == nil) {
        pvVar1 = [self mediaDataFolderAtPath:[self pathToMediaFolder]];
        _mediaDataFolder = pvVar1;
    }
    return pvVar1;
}

- (id)pathToMediaFolder
{
    return @"";
}

- (id)mediaType
{
    return @"pattern";
}

- (id)mediaDataFolderAtPath:(id)aPath
{
    NSArray *self_00;
    NSUInteger pvVar2;
    id pvVar3;
    id self_01;
    NSUInteger iVar5;
    NSUInteger local_24;
    id local_14;
    NSUInteger pvVar1_2;

    self_00 = [aPath pathComponents];
    local_14 = [[self mediaData] rootDataFolder];
    local_24 = 0;
    pvVar1_2 = [self_00 count];
    do {
        if (pvVar1_2 <= local_24) {
            return local_14;
        }
        pvVar2 = [local_14 numberOfDataFolders];
        iVar5 = 0;
        pvVar3 = [self_00 objectAtIndex:local_24];
        while( YES ) {
            if ((int)pvVar2 <= iVar5) {
                return nil;
            }
            self_01 = [local_14 dataFolderAtIndex:iVar5];
            if ([[self_01 dataDisplayName] isEqualToString:pvVar3]) break;
            iVar5 = iVar5 + 1;
        }
        local_24 = (local_24 + 1);
        local_14 = self_01;
    } while( YES );
}

- (void)selectionDidChangeInGridControl:(id)aControl
{
    NSUInteger pvVar1;
    id pvVar2_2;

    pvVar1 = [_gridControl selectedItemIndex];
    if (pvVar1 != NSNotFound) {
        pvVar2_2 = [[self colors] objectAtIndex:pvVar1];
        [[self colorPanel] setColor:pvVar2_2];
        [_imageView setImage:[self imageForColor:pvVar2_2]];
    }
}

- (id)gridControl:(id)aControl imageForItemAt:(NSInteger)aAt
{
    return [self imageForColor:[[self colors] objectAtIndex:aAt]];
}

- (id)gridControl:(id)aControl titleForItemAt:(NSInteger)aAt
{
    return nil;
}

- (NSInteger)numberOfItemsInGridControl:(id)aControl
{
    return (int)[[self colors] count];
}

- (Class)cellClass
{
    return [SMKGridBaseCell class];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_00136158 @ 00136158, 599 bytes * /

void FUN_00136158(HSPatternPicker *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  
  _objc_msgSend(self->_gridControl,sel_setMode_,0);
  _objc_msgSend(self->_gridControl,sel_setThumbnailSize_,0x42700000,0x42700000);
  _objc_msgSend(self->_gridControl,sel_setSelectionStyle_,2);
  _objc_msgSend(self->_gridControl,sel_setThreadedPreloadingEnabled_,0);
  _objc_msgSend(self->_gridControl,sel_setAllowsMultipleSelection_,0);
  _objc_msgSend(self->_gridControl,sel_setThumbnailCachingEnabled_,1);
  _objc_msgSend(self->_gridControl,sel_setThumbnailHyphenationEnabled_,1);
  _objc_msgSend(self->_gridControl,sel_setGraphicContentShadowEnabled_,0);
  _objc_msgSend(self->_gridControl,sel_setExtraPasteboardDataProvidingAllowed_,0);
  _objc_msgSend(self->_gridControl,sel_setDataSource_,self);
  _objc_msgSend(self->_gridControl,sel_reloadData);
  _objc_msgSend(self->_gridControl,sel_setDelegate_,self);
  _objc_msgSend(self->_imageView,sel_setAllowsCutCopyPaste_,0);
  pvVar2 = self->_imageView;
  pvVar1 = _objc_msgSend(self,sel_colorPanel);
  pvVar1 = _objc_msgSend(pvVar1,sel_color);
  pvVar1 = _objc_msgSend(self,sel_imageForColor_,pvVar1);
  _objc_msgSend(pvVar2,sel_setImage_,pvVar1);
  pvVar2 = _objc_msgSend(self->_gridControl,sel_gridMatrix);
  _objc_msgSend(pvVar2,sel_setAllowsEmptySelection_,1);
  _objc_msgSend(self->_gridControl,sel_setSelectedItem_byExtendingSelection_,0,0);
  _objc_msgSend((self->super)._pickerView,sel_setMinSize_,0x43650000,0x43b80000);
  return;
}

*/
- (void)didLoadNib
{
    [_gridControl setMode:0];
    [_gridControl setThumbnailSize:NSMakeSize(60.0, 60.0)];
    [_gridControl setSelectionStyle:2];
    [_gridControl setThreadedPreloadingEnabled:NO];
    [_gridControl setAllowsMultipleSelection:NO];
    [_gridControl setThumbnailCachingEnabled:YES];
    [_gridControl setThumbnailHyphenationEnabled:YES];
    [_gridControl setGraphicContentShadowEnabled:NO];
    [_gridControl setExtraPasteboardDataProvidingAllowed:NO];
    [_gridControl setDataSource:self];
    [_gridControl reloadData];
    [_gridControl setDelegate:self];
    [_imageView setAllowsCutCopyPaste:NO];
    [_imageView setImage:[self imageForColor:[[self colorPanel] color]]];
    [[_gridControl gridMatrix] setAllowsEmptySelection:YES];
    [_gridControl setSelectedItem:0 byExtendingSelection:NO];
    [_pickerView setMinSize:NSMakeSize(229.0, 368.0)];
}

- (void)dealloc
{
    if ([_gridControl dataSource] == self) {
        [_gridControl setDataSource:0];
    }
    if ([_gridControl delegate] == self) {
        [_gridControl setDelegate:0];
    }
    [_colors release];
    [super dealloc];
}

- (id)autorelease
{
    return self;
}

- (void)release
{

}

- (NSUInteger)retainCount
{
    return 0xffffffff;
}

- (id)retain
{
    return self;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return self;
}

@end

