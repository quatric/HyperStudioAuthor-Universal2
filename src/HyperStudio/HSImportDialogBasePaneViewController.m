#import "HSImportDialogBasePaneViewController.h"

@implementation HSImportDialogBasePaneViewController

/* i386 ivar offsets: _mediaPathDictionary=0x4, _searchedMediaPathsHash=0x8, _searchedMediaPathsHashLock=0xc, _isObjectOptionsDisabled=0x10, _optionsKeyToProcessingSelectorMap=0x14, _dialogController=0x18 */

- (void)setupDialogInterfaceWithOptions:(id)aOptions
{
    NSUInteger pvVar1;
    NSEnumerator *self_00;
    id self_01;
    id pvVar1_2;
    id pvVar1_5;

    if ((aOptions != nil) && (pvVar1 = [aOptions count], pvVar1 != 0)) {
        pvVar1_2 = _optionsKeyToProcessingSelectorMap;
        if (pvVar1_2 == nil) {
            if (![self respondsToSelector:@selector(optionsKeyToProcessingSelectorMap)]) {
                pvVar1_2 = _optionsKeyToProcessingSelectorMap;
            }
            else {
                pvVar1_2 = [[self optionsKeyToProcessingSelectorMap] retain];
                _optionsKeyToProcessingSelectorMap = pvVar1_2;
            }
        }
        if (pvVar1_2 != nil) {
            self_00 = [aOptions keyEnumerator];
            pvVar1_5 = [self_00 nextObject];
            while (pvVar1_5 != nil) {
                self_01 = [_optionsKeyToProcessingSelectorMap objectForKey:pvVar1_5];
                if (self_01 != nil) {
                    [self performSelector:[self_01 pointerValue] withObject:[aOptions objectForKey:pvVar1_5]];
                }
                pvVar1_5 = [self_00 nextObject];
            }
        }
    }
}

- (void)setObjectOptionsDisabled:(BOOL)aDisabled
{
    _isObjectOptionsDisabled = aDisabled;
}

- (BOOL)isObjectOptionsDisabled
{
    return _isObjectOptionsDisabled;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001b5d7d @ 001b5d7d, 229 bytes * /

BOOL FUN_001b5d7d(HSImportDialogBasePaneViewController *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  char local_11;
  
  pvVar1 = _objc_msgSend(self,sel_paneFilePath);
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar4 = pvVar1;
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperFileTypeAtPath_,pvVar1);
  if ((pvVar2 != (id)0x0) && (pvVar3 = _objc_msgSend(pvVar2,sel_length,pvVar4), pvVar3 != (id)0x0))
  {
    pvVar4 = pvVar1;
    pvVar1 = _objc_msgSend(cls_HSNewMediaAccessor,sel_fullPathForMediaPath_mediaType_,pvVar1,pvVar2)
    ;
  }
  local_11 = '\0';
  pvVar4 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar4);
  pvVar4 = _objc_msgSend(pvVar4,sel_fileExistsAtPath_isDirectory_,pvVar1,&local_11);
  return (char)pvVar4 != '\0' && local_11 == '\0';
}

*/
- (BOOL)isObjectValid
{
    id path = [self paneFilePath];
    id type = [[NSFileManager defaultManager] hyperFileTypeAtPath:path];
    if (type != nil && [type length] != 0) {
        path = [HSNewMediaAccessor fullPathForMediaPath:path mediaType:type];
    }
    BOOL isDirectory = NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory;
    return 0;
}

- (id)mutableFilteredMediaPathsForKey:(id)aKey
{
    [_searchedMediaPathsHashLock lock];
    if (_searchedMediaPathsHash == nil) {
        _searchedMediaPathsHash = [[self filteredPathsWithArray:[self mediaPathsForKey:aKey]] mutableCopy];
    }
    [_searchedMediaPathsHashLock unlock];
    return _searchedMediaPathsHash;
}

- (id)filteredPathsWithArray:(id)aArray
{
    NSEnumerator *self_01;
    id pvVar3;
    id local_14;

    local_14 = nil;
    self_01 = [aArray objectEnumerator];
    while( YES ) {
        pvVar3 = [self_01 nextObject];
        if (pvVar3 == nil) break;
        if ([self mediaPathConformsToFilter:pvVar3]) {
            if (local_14 == nil) {
                local_14 = [[[NSMutableArray allocWithZone:[self zone]] initWithCapacity:0] autorelease];
            }
            [local_14 addObject:pvVar3];
        }
    }
    return local_14;
}

- (id)mediaPathsForKey:(id)aKey
{
    id pvVar2;
    id self_00;
    id pvVar2_3;

    if (aKey == nil) {
        pvVar2 = nil;
    }
    else {
        pvVar2 = [_mediaPathDictionary objectForKey:aKey];
        if (pvVar2 == nil) {
            pvVar2 = [self createMediaPathsForKey:aKey];
            if (pvVar2 == nil) {
                pvVar2_3 = [NSMutableArray allocWithZone:[self zone]];
                pvVar2 = [[pvVar2_3 initWithCapacity:0] autorelease];
            }
            if (pvVar2 != nil) {
                self_00 = _mediaPathDictionary;
                if (self_00 == nil) {
                    self_00 = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:0];
                    _mediaPathDictionary = self_00;
                }
                [self_00 setObject:pvVar2 forKey:aKey];
            }
        }
    }
    return pvVar2;
}

- (void)invalidateMediaPaths
{
    [_searchedMediaPathsHashLock lock];
    [_searchedMediaPathsHash autorelease];
    _searchedMediaPathsHash = nil;
    [_searchedMediaPathsHashLock unlock];
    [self reloadMediaPaths];
}

- (id)helpTopicKey
{
    return @"HSHomeTopic";
}

- (void)restoreSelection
{

}

- (void)storeSelection
{

}

- (void)reloadMediaPaths
{

}

- (id)filteredMediaPathsForKey:(id)aKey
{
    return [self mutableFilteredMediaPathsForKey:aKey];
}

- (BOOL)mediaPathConformsToFilter:(id)aFilter
{
    return YES;
}

- (id)paneHyperDocument
{
    return [_dialogController hyperDocument];
}

- (id)dialogType
{
    return [_dialogController dialogType];
}

- (id)supportedMediaTypes
{
    return nil;
}

- (id)createMediaPathsForKey:(id)aKey
{
    return nil;
}

- (BOOL)isPaneValid
{
    return YES;
}

- (void)willUnmountFromDialogController:(id)aController
{
    _dialogController = nil;
}

- (void)willMountToDialogController:(id)aController
{
    _dialogController = aController;
}

- (void)paneDialogWillOpen
{

}

- (void)paneDialogWillClose
{

}

- (void)paneDialogWillCancel
{

}

- (id)paneUserOptions
{
    return nil;
}

- (id)paneFileDisplayName
{
    NSString *pvVar1_2;

    if ([self paneFilePath] == nil) {
        pvVar1_2 = nil;
    }
    else {
        pvVar1_2 = [[NSFileManager defaultManager] displayNameAtPath:[self paneFilePath]];
    }
    return pvVar1_2;
}

- (id)paneFilePath
{
    return nil;
}

- (id)paneAccessoryView
{
    return nil;
}

- (id)paneView
{
    return nil;
}

- (id)paneTitle
{
    return nil;
}

- (NSInteger)paneWeight
{
    return 0;
}

- (id)paneIdentifier
{
    return @"HSImportDialogBaseIdentifier";
}

- (void)dealloc
{
    [_searchedMediaPathsHash release];
    [_mediaPathDictionary release];
    [_searchedMediaPathsHashLock release];
    [_optionsKeyToProcessingSelectorMap release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _searchedMediaPathsHashLock = [[NSRecursiveLock allocWithZone:[self zone]] init];
    }
    return self;
}

@end

