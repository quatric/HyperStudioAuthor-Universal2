#import "HSEditorCardViewDragHelper.h"

@implementation HSEditorCardViewDragHelper

/* i386 ivar offsets: _dragHost=0x4, _canRecieveDrag=0x8, _draggingPasteboardDataProvider=0xc, _copyPasteboardDataProvider=0x10, _offsetOfAddedObject=0x14, _delegate=0x1c, _mediaDictionary=0x20, _cashedImageDataFromRTFDPasteboard=0x24 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e6ef7 @ 001e6ef7, 350 bytes * /

id FUN_001e6ef7(id self,SEL _cmd,id iTunesSpecificFilenamesFromPasteboard)

{
  id pvVar1;
  id pvVar2;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  id pvVar5;
  
  pvVar1 = _objc_msgSend(iTunesSpecificFilenamesFromPasteboard,sel_types);
  pcVar3 = &cfstr_CorePasteboardFlavorType_0x6974756E;
  pvVar1 = _objc_msgSend(pvVar1,sel_containsObject_,&cfstr_CorePasteboardFlavorType_0x6974756E);
  if ((char)pvVar1 == '\0') {
    pvVar1 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_array,pcVar3);
    pvVar2 = _objc_msgSend(iTunesSpecificFilenamesFromPasteboard,sel_propertyListForType_,
                           &cfstr_CorePasteboardFlavorType_0x6974756E);
    pcVar3 = &cfstr_Tracks;
    pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_,&cfstr_Tracks);
    pvVar2 = _objc_msgSend(pvVar2,sel_objectEnumerator);
    while( true ) {
      pvVar5 = _objc_msgSend(pvVar2,sel_nextObject,pcVar3);
      if (pvVar5 == (id)0x0) break;
      pcVar3 = _objc_msgSend(pvVar5,sel_objectForKey_,&cfstr_Location);
      pvVar5 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pcVar3);
      pcVar4 = _objc_msgSend(pvVar5,sel_path);
      if (pcVar4 != (cfstringStruct *)0x0) {
        _objc_msgSend(pvVar1,sel_addObject_,pcVar4);
        pcVar3 = pcVar4;
      }
    }
    pvVar1 = _objc_msgSend(pvVar1,sel_copy,pcVar3);
    pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  }
  return pvVar1;
}

*/
+ (id)iTunesSpecificFilenamesFromPasteboard:(id)aPasteboard
{
    if (![[aPasteboard types] containsObject:@"CorePasteboardFlavorType 0x6974756E"]) {
        return nil;
    }
    NSMutableArray *paths = [NSMutableArray array];
    NSDictionary *tracks = [[aPasteboard propertyListForType:@"CorePasteboardFlavorType 0x6974756E"] objectForKey:@"Tracks"];
    for (id key in [tracks objectEnumerator]) {
        NSString *path = [[NSURL URLWithString:[key objectForKey:@"Location"]] path];
        if (path != nil) {
            [paths addObject:path];
        }
    }
    return [[paths copy] autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e6da0 @ 001e6da0, 343 bytes * /

id FUN_001e6da0(id self,SEL _cmd,id URLFromPasteboard)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  SEL op;
  undefined4 uVar5;
  undefined4 uVar6;
  undefined4 uVar7;
  
  puVar2 = PTR_003367c0;
  puVar1 = PTR_00336418;
  uVar6 = *(undefined4 *)PTR_003367c0;
  uVar7 = 0;
  pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,*(undefined4 *)PTR_00336418,uVar6,0);
  pvVar3 = _objc_msgSend(URLFromPasteboard,sel_availableTypeFromArray_,pvVar3);
  if (pvVar3 == (id)0x0) {
LAB_001e6eed:
    pvVar3 = (id)0x0;
  }
  else {
    pvVar4 = _objc_msgSend(pvVar3,sel_isEqualToString_,*(undefined4 *)puVar1,uVar6,uVar7);
    if ((char)pvVar4 == '\0') {
      uVar5 = *(undefined4 *)puVar2;
      pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,uVar5,uVar6,uVar7);
      if ((char)pvVar3 == '\0') goto LAB_001e6eed;
      pvVar3 = _objc_msgSend(cls_WebArchive,sel_alloc,uVar5,uVar6,uVar7);
      URLFromPasteboard = _objc_msgSend(URLFromPasteboard,sel_dataForType_,*(undefined4 *)puVar2);
      pvVar3 = _objc_msgSend(pvVar3,sel_initWithData_,URLFromPasteboard);
      pvVar3 = _objc_msgSend(pvVar3,sel_mainResource);
      op = sel_URL;
    }
    else {
      pvVar3 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,URLFromPasteboard,uVar6,uVar7);
      op = sel_standardizedURL;
    }
    pvVar3 = _objc_msgSend(pvVar3,op,URLFromPasteboard);
  }
  return pvVar3;
}

*/
+ (id)URLFromPasteboard:(id)aPasteboard
{
    NSString *type = [aPasteboard availableTypeFromArray:[NSArray arrayWithObjects:NSURLPboardType, WebArchivePboardType, nil]];
    if (type == nil) {
        return nil;
    }
    if ([type isEqualToString:NSURLPboardType]) {
        return [[NSURL URLFromPasteboard:aPasteboard] standardizedURL];
    }
    if ([type isEqualToString:WebArchivePboardType]) {
        // Fix: the original leaked the archive.
        WebArchive *archive = [[[WebArchive alloc] initWithData:[aPasteboard dataForType:WebArchivePboardType]] autorelease];
        return [[archive mainResource] URL];
    }
    return nil;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e8cee @ 001e8cee, 1035 bytes * /

id FUN_001e8cee(id self,SEL _cmd,id commentsForDroppedObjectWithURL)

{
  char cVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id self_00;
  id self_01;
  id pvVar7;
  int iVar8;
  int iVar9;
  int iVar10;
  id pvVar11;
  int iVar12;
  
  pvVar3 = _objc_msgSend(cls_NSMutableString,sel_string);
  if (commentsForDroppedObjectWithURL == (id)0x0) goto LAB_001e90d2;
  pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar4 = _objc_msgSend(pvVar4,sel_boolForKey_,*(undefined4 *)PTR_00336794);
  cVar1 = (char)pvVar4;
  pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar5 = _objc_msgSend(pvVar4,sel_integerForKey_,*(undefined4 *)PTR_0033679c);
  pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar4 = _objc_msgSend(pvVar4,sel_boolForKey_,*(undefined4 *)PTR_00336790);
  cVar2 = (char)pvVar4;
  pvVar6 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  pvVar4 = *(id *)PTR_00336798;
  pvVar6 = _objc_msgSend(pvVar6,sel_integerForKey_,pvVar4);
  if (cVar2 == '\0' && cVar1 == '\0') goto LAB_001e90d2;
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array,pvVar4);
  self_01 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar7 = _objc_msgSend(commentsForDroppedObjectWithURL,sel_isFileURL);
  if ((char)pvVar7 != '\0') {
    pvVar7 = _objc_msgSend(commentsForDroppedObjectWithURL,sel_path,pvVar4);
    iVar8 = _MDItemCreate(*(undefined4 *)PTR_003363a4,pvVar7);
    if (iVar8 != 0) {
      iVar9 = _MDItemCopyAttribute(iVar8,*(undefined4 *)PTR_003367c4);
      if (iVar9 != 0) {
        iVar10 = _CFArrayGetCount(iVar9);
        if (0 < iVar10) {
          iVar12 = 0;
          do {
            pvVar7 = (id)_CFArrayGetValueAtIndex(iVar9,iVar12);
            if ((cVar1 != '\0') &&
               (pvVar11 = _objc_msgSend(pvVar7,sel_isAbsolutePath,pvVar4), (char)pvVar11 != '\0')) {
              pvVar4 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar7);
              _objc_msgSend(self_00,sel_addObject_,pvVar4);
            }
            if ((cVar2 != '\0') &&
               (pvVar11 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar7), pvVar4 = pvVar7,
               pvVar11 != (id)0x0)) {
              _objc_msgSend(self_01,sel_addObject_,pvVar11);
              pvVar4 = pvVar11;
            }
            iVar12 = iVar12 + 1;
          } while (iVar10 != iVar12);
        }
        _CFRelease(iVar9);
      }
      _CFRelease(iVar8);
    }
  }
  pvVar4 = _objc_msgSend(commentsForDroppedObjectWithURL,sel_isFileURL);
  if ((char)pvVar4 == '\0') {
    if (cVar2 != '\0') {
      pvVar7 = _objc_msgSend(self_01,sel_count);
      pvVar4 = self_01;
      goto joined_r0x001e8ffc;
    }
  }
  else if (cVar1 != '\0') {
    pvVar7 = _objc_msgSend(self_00,sel_count);
    pvVar4 = self_00;
joined_r0x001e8ffc:
    if (pvVar7 == (id)0x0) {
      _objc_msgSend(pvVar4,sel_addObject_,commentsForDroppedObjectWithURL);
    }
  }
  pvVar4 = _objc_msgSend(self,sel_commentsForArrayOfURLs_withAutofillType_,self_00,pvVar5);
  _objc_msgSend(pvVar3,sel_appendFormat_,&cfstr___,pvVar4);
  pvVar5 = _objc_msgSend(pvVar3,sel_length);
  if (pvVar5 != (id)0x0) {
    _objc_msgSend(pvVar3,sel_appendString_,&cfstr__,pvVar4);
  }
  pvVar4 = _objc_msgSend(self,sel_commentsForArrayOfURLs_withAutofillType_,self_01,pvVar6);
  _objc_msgSend(pvVar3,sel_appendFormat_,&cfstr___,pvVar4);
LAB_001e90d2:
  pvVar3 = _objc_msgSend(cls_NSString,sel_stringWithString_,pvVar3);
  return pvVar3;
}

*/
+ (id)commentsForDroppedObjectWithURL:(id)aURL
{
    NSMutableString *comments = [NSMutableString string];
    if (aURL == nil) {
        return [NSString stringWithString:comments];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL autofillFromDisk = [defaults boolForKey:HSAutofillCommentsWhenAddingMediaFromDiskPreferencesKey];
    NSInteger diskType = [defaults integerForKey:HSAutofillTypeForMediaFromDiskPreferencesKey];
    BOOL autofillFromBrowser = [defaults boolForKey:HSAutofillCommentsWhenAddingMediaFromBrowserPreferencesKey];
    NSInteger browserType = [defaults integerForKey:HSAutofillTypeForMediaFromBrowserPreferencesKey];
    if (!autofillFromBrowser && !autofillFromDisk) {
        return [NSString stringWithString:comments];
    }
    NSMutableArray *fileURLs = [NSMutableArray array];
    NSMutableArray *webURLs = [NSMutableArray array];
    if ([aURL isFileURL]) {
        // Spotlight remembers where downloaded files came from.
        MDItemRef item = MDItemCreate(kCFAllocatorDefault, (CFStringRef)[aURL path]);
        if (item != NULL) {
            CFArrayRef whereFroms = MDItemCopyAttribute(item, kMDItemWhereFroms);
            if (whereFroms != NULL) {
                CFIndex count = CFArrayGetCount(whereFroms);
                for (CFIndex i = 0; i < count; i++) {
                    NSString *source = (NSString *)CFArrayGetValueAtIndex(whereFroms, i);
                    if (autofillFromDisk && [source isAbsolutePath]) {
                        [fileURLs addObject:[NSURL fileURLWithPath:source]];
                    }
                    if (autofillFromBrowser) {
                        NSURL *url = [NSURL URLWithString:source];
                        if (url != nil) {
                            [webURLs addObject:url];
                        }
                    }
                }
                CFRelease(whereFroms);
            }
            CFRelease(item);
        }
    }
    if (![aURL isFileURL]) {
        if (autofillFromBrowser && [webURLs count] == 0) {
            [webURLs addObject:aURL];
        }
    } else if (autofillFromDisk && [fileURLs count] == 0) {
        [fileURLs addObject:aURL];
    }
    [comments appendFormat:@"%@", [self commentsForArrayOfURLs:fileURLs withAutofillType:diskType]];
    if ([comments length] != 0) {
        [comments appendString:@"\n"];
    }
    [comments appendFormat:@"%@", [self commentsForArrayOfURLs:webURLs withAutofillType:browserType]];
    return [NSString stringWithString:comments];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e6c16 @ 001e6c16, 394 bytes * /

id FUN_001e6c16(id self,SEL _cmd,id commentsForArrayOfURLs,int withAutofillType)

{
  id pvVar1;
  id self_00;
  cfstringStruct *self_01;
  id pvVar2;
  cfstringStruct *self_02;
  SEL op;
  
  pvVar1 = _objc_msgSend(cls_NSMutableString,sel_string);
  self_00 = _objc_msgSend(commentsForArrayOfURLs,sel_objectEnumerator);
  self_01 = _objc_msgSend(self_00,sel_nextObject);
  do {
    if (self_01 == (cfstringStruct *)0x0) {
      pvVar1 = _objc_msgSend(cls_NSString,sel_stringWithString_,pvVar1);
      return pvVar1;
    }
    pvVar2 = _objc_msgSend(self_01,sel_isFileURL);
    if ((char)pvVar2 == '\0') {
      self_02 = self_01;
      op = sel_absoluteString;
      if (withAutofillType != 0) {
        pvVar2 = _objc_msgSend(self_01,sel_absoluteURL);
        self_02 = _objc_msgSend(pvVar2,sel_path);
        op = sel_lastPathComponent;
      }
LAB_001e6ce9:
      self_02 = _objc_msgSend(self_02,op);
    }
    else {
      self_02 = _objc_msgSend(self_01,sel_path);
      op = sel_lastPathComponent;
      if (withAutofillType != 0) goto LAB_001e6ce9;
    }
    _objc_msgSend(pvVar1,sel_appendFormat_,&cfstr___,self_02);
    pvVar2 = _objc_msgSend(commentsForArrayOfURLs,sel_lastObject);
    pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,self_01);
    if ((char)pvVar2 == '\0') {
      self_01 = &cfstr__;
      _objc_msgSend(pvVar1,sel_appendString_,&cfstr__,self_02);
    }
    self_01 = _objc_msgSend(self_00,sel_nextObject,self_01,self_02);
  } while( true );
}

*/
+ (id)commentsForArrayOfURLs:(id)aLs withAutofillType:(NSInteger)aType
{
    NSMutableString *comments = [NSMutableString string];
    for (NSURL *url in [aLs objectEnumerator]) {
        // Type 0 gives the full path or address, anything else only the name.
        NSString *text;
        if ([url isFileURL]) {
            text = aType != 0 ? [[url path] lastPathComponent] : [url path];
        } else {
            text = aType != 0 ? [[[url absoluteURL] path] lastPathComponent] : [url absoluteString];
        }
        [comments appendFormat:@"%@", text];
        if (![[aLs lastObject] isEqual:url]) {
            [comments appendString:@"\n"];
        }
    }
    return [NSString stringWithString:comments];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e6b6d @ 001e6b6d, 169 bytes * /

id FUN_001e6b6d(HSEditorCardViewDragHelper *self,SEL _cmd,id decodeDataObjectFromData,uint *offset)

{
  undefined *self_00;
  int iVar1;
  id pvVar2;
  char *pcVar3;
  int *piVar4;
  uint *puVar5;
  int local_1c;
  int local_18;
  
  local_18 = 0;
  local_1c = 0;
  piVar4 = &local_1c;
  pcVar3 = "Q";
  pvVar2 = decodeDataObjectFromData;
  puVar5 = offset;
  _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_,"Q",piVar4,
                decodeDataObjectFromData,offset);
  iVar1 = local_1c;
  self_00 = cls_NSData;
  if (local_18 == 0) {
    pvVar2 = _objc_msgSend(decodeDataObjectFromData,sel_bytes,pcVar3,piVar4,pvVar2,puVar5);
    pvVar2 = _objc_msgSend(self_00,sel_dataWithBytes_length_,(int)pvVar2 + *offset,iVar1);
  }
  else {
    pvVar2 = (id)0x0;
  }
  *offset = *offset + local_1c;
  return pvVar2;
}

*/
- (id)decodeDataObjectFromData:(id)aData offset:(unsigned int *)aOffset
{
    unsigned long long length = 0;
    [self decodeValueOfObjCType:"Q" at:&length fromData:aData offset:aOffset];
    NSData *data = nil;
    // Lengths above 4 GB are rejected.
    if ((length >> 32) == 0) {
        data = [NSData dataWithBytes:(const char *)[aData bytes] + *aOffset length:(NSUInteger)length];
    }
    *aOffset += (unsigned int)length;
    return data;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e90f9 @ 001e90f9, 212 bytes * /

void FUN_001e90f9(HSEditorCardViewDragHelper *self,SEL _cmd,char *decodeValueOfObjCType,void *at,
                 id fromData,uint *offset)

{
  uint uVar1;
  uint uVar2;
  int iVar3;
  id pvVar4;
  
  iVar3 = _strcmp(decodeValueOfObjCType,"d");
  if (iVar3 == 0) {
    pvVar4 = _objc_msgSend(fromData,sel_bytes);
    uVar1 = *(uint *)((int)pvVar4 + *offset);
    uVar2 = *(uint *)((int)pvVar4 + *offset + 4);
    *(uint *)((int)at + 4) =
         uVar1 >> 0x18 | (uVar1 & 0xff0000) >> 8 | (uVar1 & 0xff00) << 8 | uVar1 << 0x18;
    *(uint *)at = uVar2 >> 0x18 | (uVar2 & 0xff0000) >> 8 | (uVar2 & 0xff00) << 8 | uVar2 << 0x18;
  }
  else {
    iVar3 = _strcmp(decodeValueOfObjCType,"C");
    if (iVar3 == 0) {
      pvVar4 = _objc_msgSend(fromData,sel_bytes);
      *(undefined1 *)at = *(undefined1 *)((int)pvVar4 + *offset);
      *offset = *offset + 1;
      return;
    }
    iVar3 = _strcmp(decodeValueOfObjCType,"Q");
    if (iVar3 != 0) {
      return;
    }
    pvVar4 = _objc_msgSend(fromData,sel_bytes);
    *(undefined8 *)at = *(undefined8 *)((int)pvVar4 + *offset);
  }
  *offset = *offset + 8;
  return;
}

*/
- (void)decodeValueOfObjCType:(char *)aType at:(void *)aAt fromData:(id)aData offset:(unsigned int *)aOffset
{
    const unsigned char *bytes = (const unsigned char *)[aData bytes] + *aOffset;
    if (strcmp(aType, "d") == 0) {
        // Doubles are stored big-endian.
        uint64_t value;
        memcpy(&value, bytes, sizeof(value));
        value = CFSwapInt64BigToHost(value);
        memcpy(aAt, &value, sizeof(value));
    } else if (strcmp(aType, "C") == 0) {
        *(unsigned char *)aAt = *bytes;
        *aOffset += 1;
        return;
    } else if (strcmp(aType, "Q") == 0) {
        // The original reads 64-bit integers in host order.
        memcpy(aAt, bytes, sizeof(unsigned long long));
    } else {
        return;
    }
    *aOffset += 8;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

- (id)delegate
{
    return _delegate;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e69bf @ 001e69bf, 430 bytes * /

void FUN_001e69bf(HSEditorCardViewDragHelper *self,SEL _cmd,id presentDropErrorInWindow,
                 BOOL dropOnCard)

{
  id self_00;
  id pvVar1;
  cfstringStruct *pcVar2;
  cfstringStruct *pcVar3;
  
  self_00 = _objc_msgSend(cls_HSAlert,sel_new);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pcVar2 = &cfstr_HSDropOnCardErrorMessageText;
  if (dropOnCard == '\0') {
    pcVar2 = &cfstr_HSDropOnObjectErrorMessageText;
  }
  pcVar3 = &cfstr_HSDropOnCardErrorInformativeText;
  if (dropOnCard == '\0') {
    pcVar3 = &cfstr_HSDropOnObjectErrorInformativeText;
  }
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar2,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(self_00,sel_setMessageText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,pcVar3,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(self_00,sel_setInformativeText_,pvVar1);
  pvVar1 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
  pvVar1 = _objc_msgSend(pvVar1,sel_localizedStringForKey_value_table_,&cfstr_OK,&cfstr_empty,
                         &cfstr_Alerts);
  _objc_msgSend(self_00,sel_addButtonWithTitle_,pvVar1);
  _objc_msgSend(self_00,sel_beginSheetModalForWindow_modalDelegate_didEndSelector_contextInfo_,
                presentDropErrorInWindow,0,0,0);
  _objc_msgSend(self_00,sel_release);
  return;
}

*/
- (void)presentDropErrorInWindow:(id)aWindow dropOnCard:(BOOL)aCard
{
    HSAlert *alert = [HSAlert new];
    HSExecutableResourceProvider *resources = [HSExecutableResourceProvider sharedInstance];
    NSString *messageKey = aCard ? @"HSDropOnCardErrorMessageText" : @"HSDropOnObjectErrorMessageText";
    NSString *informativeKey = aCard ? @"HSDropOnCardErrorInformativeText" : @"HSDropOnObjectErrorInformativeText";
    [alert setMessageText:[resources localizedStringForKey:messageKey value:@"" table:@"Alerts"]];
    [alert setInformativeText:[resources localizedStringForKey:informativeKey value:@"" table:@"Alerts"]];
    [alert addButtonWithTitle:[resources localizedStringForKey:@"OK" value:@"" table:@"Alerts"]];
    [alert beginSheetModalForWindow:aWindow modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    [alert release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e91cd @ 001e91cd, 1362 bytes * /

uint FUN_001e91cd(HSEditorCardViewDragHelper *self,SEL _cmd,id importToObject,id dataFromFiles)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined *puVar7;
  undefined *self_00;
  id pvVar8;
  HSEditorCardViewDragHelper *self_01;
  undefined *puVar9;
  undefined *extraout_EDX;
  undefined *extraout_EDX_00;
  SEL op;
  undefined *puVar10;
  undefined8 in_stack_ffffff7c;
  uint uVar13;
  longlong lVar11;
  undefined4 uVar14;
  ulonglong uVar12;
  int *piVar15;
  undefined4 uVar16;
  undefined4 uVar17;
  int local_38;
  ulonglong local_34;
  undefined8 local_2c;
  undefined1 local_24 [8];
  undefined *local_1c;
  undefined *local_18;
  
  uVar13 = (uint)((ulonglong)in_stack_ffffff7c >> 0x20);
  _objc_msgSend(self,sel_invalidateMediaDictionary);
  pvVar3 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  pvVar3 = _objc_msgSend(pvVar3,sel_document);
  pvVar3 = _objc_msgSend(pvVar3,sel_isInAnimationMode);
  if ((char)pvVar3 == '\0') {
    lVar11 = (ulonglong)uVar13 << 0x20;
    pvVar3 = _objc_msgSend(self,sel_isLockedObject_,0);
    if ((char)pvVar3 == '\0') {
      pvVar3 = _objc_msgSend(cls_NSMutableArray,sel_array,lVar11);
      pvVar4 = _objc_msgSend(dataFromFiles,sel_objectEnumerator);
      while (pvVar5 = _objc_msgSend(pvVar4,sel_nextObject,lVar11), pvVar5 != (id)0x0) {
        local_38 = 0;
        piVar15 = &local_38;
        uVar17 = 1;
        uVar16 = 0;
        uVar12 = ZEXT48(importToObject);
        lVar11 = CONCAT44(1,pvVar5);
        pvVar5 = _objc_msgSend(self,
                               sel_objectFromFile_shouldImport_intoAcceptingObject_runAnimationMode_error_dragOperation_useDragPreferences_
                               ,pvVar5,1,importToObject,0,piVar15,0,1);
        if ((local_38 == 0) && (pvVar5 != (id)0x0)) {
          uVar14 = (undefined4)((ulonglong)lVar11 >> 0x20);
          lVar11 = CONCAT44(uVar14,pvVar5);
          _objc_msgSend(pvVar3,sel_addObject_,pvVar5,uVar14,uVar12,piVar15,uVar16,uVar17);
        }
      }
      pvVar4 = _objc_msgSend(pvVar3,sel_count,lVar11);
      if (pvVar4 != (id)0x0) {
        pvVar4 = _objc_msgSend(cls_NSMutableArray,sel_array);
        pvVar5 = _objc_msgSend(pvVar3,sel_objectEnumerator);
        while (pvVar6 = _objc_msgSend(pvVar5,sel_nextObject,lVar11), pvVar6 != (id)0x0) {
          lVar11 = CONCAT44((int)((ulonglong)lVar11 >> 0x20),&DAT_00380190);
          pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_00380190);
          if (pvVar6 != (id)0x0) {
            uVar16 = (undefined4)((ulonglong)lVar11 >> 0x20);
            _objc_msgSend(pvVar4,sel_addObject_,pvVar6);
            pvVar8 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
            pvVar8 = _objc_msgSend(pvVar8,sel_support);
            lVar11 = CONCAT44(uVar16,pvVar8);
            _objc_msgSend(pvVar6,sel_setSupport_,pvVar8);
          }
        }
        pvVar5 = _objc_msgSend(self->_dragHost,sel_cardForDragHost,lVar11);
        pvVar5 = _objc_msgSend(pvVar5,sel_undoManager);
        _objc_msgSend(pvVar5,sel_disableUndoRegistration);
        pvVar5 = _objc_msgSend(pvVar4,sel_objectEnumerator);
        pvVar6 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
        pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0037ff4c);
        puVar7 = _objc_msgSend(pvVar6,sel_size);
        self_00 = self->_dragHost;
        _objc_msgSend_stret(&local_34,self_00,sel_visibleRect);
        puVar10 = sel_convertToDragHostCardRect_;
        _objc_msgSend_stret(local_24,self_00,sel_convertToDragHostCardRect_,local_34,local_2c);
        pvVar6 = _objc_msgSend(pvVar5,sel_nextObject);
        if (pvVar6 != (id)0x0) {
          puVar1 = extraout_EDX;
          if ((float)local_18 <= (float)extraout_EDX) {
            puVar1 = local_18;
          }
          puVar2 = puVar7;
          if ((float)local_1c <= (float)puVar7) {
            puVar2 = local_1c;
          }
          uVar12 = local_34;
          do {
            self_00 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0037f934);
            if (self_00 == (undefined *)0x0) {
              self_00 = &DAT_003804ec;
              pvVar8 = _objc_msgSend(pvVar6,sel_implementsHyperInterface_,&DAT_003804ec);
              if ((char)pvVar8 != '\0') {
                self_00 = &DAT_0037ff38;
                self_01 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0037ff38);
                if (self_01 != (HSEditorCardViewDragHelper *)0x0) {
                  puVar9 = _objc_msgSend(self_01,sel_defaultSize,self_00);
                  op = sel_setSize_;
                  self_00 = puVar7;
                  puVar10 = extraout_EDX;
                  if ((float)puVar9 * (float)extraout_EDX_00 <=
                      (float)puVar7 * (float)extraout_EDX * 0.9) {
                    self_00 = puVar9;
                    puVar10 = extraout_EDX_00;
                  }
                  goto LAB_001e95b6;
                }
              }
            }
            else {
              uVar12 = ZEXT48(puVar1);
              self_01 = self;
              op = sel_scaleTextObject_toSize_needCenter_;
              puVar10 = puVar2;
LAB_001e95b6:
              _objc_msgSend(self_01,op,self_00,puVar10,uVar12);
            }
            pvVar6 = _objc_msgSend(pvVar5,sel_nextObject,self_00,puVar10);
          } while (pvVar6 != (id)0x0);
        }
        pvVar5 = _objc_msgSend(self->_dragHost,sel_cardForDragHost,self_00);
        pvVar5 = _objc_msgSend(pvVar5,sel_undoManager);
        _objc_msgSend(pvVar5,sel_enableUndoRegistration);
        _objc_msgSend(pvVar4,sel_makeObjectsPerformSelector_withObject_,sel_setSupport_,0);
        _objc_msgSend(self,sel_addObjectsInArray_center_useDragPreferences_,pvVar3,1,1);
        pvVar3 = _objc_msgSend(pvVar3,sel_count);
        return (uint)pvVar3;
      }
    }
  }
  return 0;
}

*/
- (NSUInteger)importToObject:(id)aObject dataFromFiles:(id)aFiles
{
    [self invalidateMediaDictionary];
    if ([[[_dragHost cardForDragHost] document] isInAnimationMode] || [self isLockedObject:nil]) {
        return 0;
    }
    NSMutableArray *objects = [NSMutableArray array];
    for (NSString *path in [aFiles objectEnumerator]) {
        id error = nil;
        id object = [self objectFromFile:path shouldImport:YES intoAcceptingObject:aObject runAnimationMode:NULL error:&error dragOperation:0 useDragPreferences:YES];
        if (error == nil && object != nil) {
            [objects addObject:object];
        }
    }
    if ([objects count] == 0) {
        return 0;
    }
    id card = [_dragHost cardForDragHost];
    NSMutableArray *children = [NSMutableArray array];
    for (id object in [objects objectEnumerator]) {
        id child = [object queryHyperInterface:@protocol(HSNodeChild)];
        if (child != nil) {
            [children addObject:child];
            [child setSupport:[[_dragHost cardForDragHost] support]];
        }
    }
    [[[_dragHost cardForDragHost] undoManager] disableUndoRegistration];
    NSSize cardSize = [(id<HSSizeAttributes>)[[_dragHost cardForDragHost] queryHyperInterface:@protocol(HSSizeAttributes)] size];
    NSRect visibleRect = [_dragHost convertToDragHostCardRect:[_dragHost visibleRect]];
    // Text fits the visible part of the card; large movies are shrunk to the card.
    NSSize textSize = NSMakeSize(MIN((float)cardSize.width, (float)visibleRect.size.width), MIN((float)cardSize.height, (float)visibleRect.size.height));
    double largeArea = (float)(cardSize.width * cardSize.height) * 0.9;
    for (id child in [children objectEnumerator]) {
        id textObject = [child queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
        if (textObject != nil) {
            [self scaleTextObject:textObject toSize:textSize needCenter:NO];
        } else if ([child implementsHyperInterface:@protocol(HSMovieAttributes)]) {
            id<HSMutableSizeAttributes> sizeAttributes = [child queryHyperInterface:@protocol(HSMutableSizeAttributes)];
            if (sizeAttributes != nil) {
                NSSize defaultSize = [sizeAttributes defaultSize];
                [sizeAttributes setSize:(float)(defaultSize.width * defaultSize.height) > largeArea ? cardSize : defaultSize];
            }
        }
    }
    [[card undoManager] enableUndoRegistration];
    [children makeObjectsPerformSelector:@selector(setSupport:) withObject:nil];
    [self addObjectsInArray:objects center:YES useDragPreferences:YES];
    return [objects count];
}

- (NSUInteger)importToCardDataFromFiles:(id)aFiles
{
    return (unsigned int)[self importToObject:nil dataFromFiles:aFiles];
}

- (id)defaultAcceptingObject
{
    return [_dragHost cardForDragHost];
}

- (void)invalidateMediaDictionary
{
    [_mediaDictionary release];
    _mediaDictionary = nil;
}

- (id)mediaDictionary
{
    id pvVar1;

    pvVar1 = _mediaDictionary;
    if (pvVar1 == nil) {
        pvVar1 = [NSMutableDictionary new];
        _mediaDictionary = pvVar1;
    }
    return pvVar1;
}

- (id)mediaWithPath:(id)aPath
{
    id pvVar2;

    if (aPath == nil) {
        pvVar2 = nil;
    }
    else {
        pvVar2 = [_mediaDictionary objectForKey:aPath];
        if (pvVar2 == nil) {
            pvVar2 = [HSNewMedia mediaWithPath:aPath];
        }
        if (pvVar2 != nil) {
            [[self mediaDictionary] setObject:pvVar2 forKey:aPath];
        }
    }
    return pvVar2;
}

- (void)setupPasteUndoActionNameIfNeeded:(BOOL)aNeeded
{
    if (aNeeded != NO) {
        [[[_dragHost cardForDragHost] undoManager] setMultipleActionsName:[[NSBundle mainBundle] localizedStringForKey:@"Paste" value:@"" table:@"UndoManager"]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e655d @ 001e655d, 604 bytes * /

BOOL FUN_001e655d(HSEditorCardViewDragHelper *self,SEL _cmd,id readSelectionFromPasteboard,
                 BOOL useDragPreferences,BOOL *didAddNewObject)

{
  char cVar1;
  BOOL BVar2;
  id pvVar3;
  id pvVar4;
  int iVar5;
  int iVar6;
  id pvVar7;
  undefined4 extraout_EDX;
  cfstringStruct *pcVar8;
  uint uVar9;
  undefined4 uVar10;
  undefined8 uVar11;
  undefined8 uVar12;
  undefined4 uVar13;
  BOOL *pBVar14;
  undefined4 uVar15;
  
  pvVar3 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  pvVar3 = _objc_msgSend(pvVar3,sel_document);
  pvVar3 = _objc_msgSend(pvVar3,sel_isInAnimationMode);
  if ((char)pvVar3 == '\0') {
    pvVar3 = _objc_msgSend(self->_dragHost,sel_window);
    pvVar3 = _objc_msgSend(pvVar3,sel_attachedSheet);
    if (pvVar3 == (id)0x0) {
      pvVar4 = _objc_msgSend(self,sel_defaultAcceptingObject);
      pvVar3 = _objc_msgSend(readSelectionFromPasteboard,sel_types);
      pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,&cfstr_HSObjectsPasteboardType);
      cVar1 = (char)pvVar3;
      uVar11 = *(undefined8 *)PTR_00336078;
      uVar12 = *(undefined8 *)(PTR_00336078 + 8);
      iVar5 = (int)useDragPreferences;
      iVar6 = (int)cVar1;
      uVar9 = (uint)(cVar1 == '\0');
      uVar15 = 0;
      uVar13 = 0;
      uVar10 = 0;
      pcVar8 = readSelectionFromPasteboard;
      pvVar3 = pvVar4;
      pBVar14 = didAddNewObject;
      pvVar7 = _objc_msgSend(self,
                             sel_tryToReadFromPasteboard_acceptingObject_alignCenter_orAdjustLocation_toRect_runAnimationMode_didAddNewObject_isPasting_dragOperation_useDragPreferences_
                             ,readSelectionFromPasteboard,pvVar4,uVar9,0,uVar11,uVar12,0,
                             didAddNewObject,iVar6,0,iVar5);
      BVar2 = (BOOL)pvVar7;
      if (didAddNewObject == (BOOL *)0x0) {
        return BVar2;
      }
      if (*didAddNewObject == '\0') {
        return BVar2;
      }
      if (useDragPreferences == '\0') {
        if (cVar1 != '\0') {
          return BVar2;
        }
        pvVar7 = _objc_msgSend(readSelectionFromPasteboard,sel_types,pcVar8,pvVar3,uVar9,uVar10,
                               uVar11,uVar12,uVar13,pBVar14,iVar6,uVar15,iVar5);
        pcVar8 = &cfstr_HSLibraryObjectsPasteboardType;
        pvVar7 = _objc_msgSend(pvVar7,sel_containsObject_,&cfstr_HSLibraryObjectsPasteboardType);
        if ((char)pvVar7 != '\0') {
          return BVar2;
        }
      }
      pvVar3 = _objc_msgSend(pvVar4,sel_hyperChildren,pcVar8,pvVar3,uVar9,uVar10,uVar11,uVar12,
                             uVar13,pBVar14,iVar6,uVar15,iVar5);
      pvVar3 = _objc_msgSend(pvVar3,sel_lastObject);
      pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0037f934);
      if (pvVar3 == (id)0x0) {
        return BVar2;
      }
      pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037ff4c);
      pvVar4 = _objc_msgSend(pvVar4,sel_size);
      _objc_msgSend(self,sel_scaleTextObject_toSize_needCenter_,pvVar3,pvVar4,extraout_EDX,1);
      return BVar2;
    }
  }
  return '\0';
}

*/
- (BOOL)readSelectionFromPasteboard:(id)aPasteboard useDragPreferences:(BOOL)aPreferences didAddNewObject:(BOOL *)aObject
{
    if ([[[_dragHost cardForDragHost] document] isInAnimationMode] || [[_dragHost window] attachedSheet] != nil) {
        return NO;
    }
    id acceptingObject = [self defaultAcceptingObject];
    BOOL isObjects = [[aPasteboard types] containsObject:@"HSObjectsPasteboardType"];
    BOOL result = [self tryToReadFromPasteboard:aPasteboard acceptingObject:acceptingObject alignCenter:!isObjects orAdjustLocation:NO toRect:NSZeroRect runAnimationMode:NULL didAddNewObject:aObject isPasting:isObjects dragOperation:0 useDragPreferences:aPreferences];
    if (aObject == NULL || !*aObject) {
        return result;
    }
    if (!aPreferences && (isObjects || [[aPasteboard types] containsObject:@"HSLibraryObjectsPasteboardType"])) {
        return result;
    }
    // A pasted text object is fitted to the card.
    id textObject = [[[acceptingObject hyperChildren] lastObject] queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
    if (textObject != nil) {
        [self scaleTextObject:textObject toSize:[(id<HSSizeAttributes>)[acceptingObject queryHyperInterface:@protocol(HSSizeAttributes)] size] needCenter:YES];
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e6387 @ 001e6387, 470 bytes * /

void FUN_001e6387(HSEditorCardViewDragHelper *self,SEL _cmd,id scaleTextObject,NSSize toSize,
                 BOOL needCenter)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  float extraout_EDX;
  undefined4 uVar4;
  float local_18;
  id local_14;
  
  if (scaleTextObject != (id)0x0) {
    pvVar1 = _objc_msgSend(scaleTextObject,sel_queryHyperInterface_,&DAT_0037ff38);
    pvVar2 = _objc_msgSend(scaleTextObject,sel_hyperText);
    pvVar3 = _objc_msgSend(cls_NSTextStorage,sel_hyperSizeForAttributedString_withWidth_fixedWidth_,
                           pvVar2,0,0);
    local_14 = (id)(toSize.width * 0.85);
    if ((float)pvVar3 <= toSize.width * 0.85) {
      local_14 = pvVar3;
    }
    uVar4 = 1;
    local_18 = toSize.height * 0.85;
    pvVar3 = local_14;
    _objc_msgSend(cls_NSTextStorage,sel_hyperSizeForAttributedString_withWidth_fixedWidth_,pvVar2,
                  local_14,1);
    if (extraout_EDX <= local_18) {
      _objc_msgSend(scaleTextObject,sel_setHasVerticalScroller_,0,pvVar3,uVar4);
      local_18 = extraout_EDX;
    }
    _objc_msgSend(pvVar1,sel_setSize_,local_14,local_18,uVar4);
    if (needCenter != '\0') {
      pvVar1 = _objc_msgSend(scaleTextObject,sel_queryHyperInterface_,&DAT_0037fcb8,local_18,uVar4);
      pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
      _objc_msgSend(pvVar1,sel_moveCenterTo_withLayoutGuidingContext_,toSize.width * 0.5,
                    toSize.height * 0.5,0);
    }
  }
  return;
}

*/
- (void)scaleTextObject:(id)aObject toSize:(NSSize)aSize needCenter:(BOOL)aCenter
{
    if (aObject == nil) {
        return;
    }
    id<HSMutableSizeAttributes> sizeAttributes = [aObject queryHyperInterface:@protocol(HSMutableSizeAttributes)];
    id text = [aObject hyperText];
    // At most 85% of the target, and only as tall as the text needs.
    float width = MIN((float)[NSTextStorage hyperSizeForAttributedString:text withWidth:0.0 fixedWidth:NO].width, (float)(aSize.width * 0.85));
    float height = aSize.height * 0.85;
    float textHeight = [NSTextStorage hyperSizeForAttributedString:text withWidth:width fixedWidth:YES].height;
    if (textHeight <= height) {
        [aObject setHasVerticalScroller:NO];
        height = textHeight;
    }
    [sizeAttributes setSize:NSMakeSize(width, height)];
    if (aCenter) {
        [[[aObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveCenterTo:NSMakePoint(aSize.width * 0.5, aSize.height * 0.5) withLayoutGuidingContext:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e5fe5 @ 001e5fe5, 930 bytes * /

BOOL FUN_001e5fe5(HSEditorCardViewDragHelper *self,SEL _cmd,
                 id canRecieveDataWhileDraggingFromPasteboard)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 uVar7;
  cfstringStruct *pcVar8;
  id pvVar9;
  
  uVar7 = 0;
  pvVar3 = _objc_msgSend(self,sel_isLockedObject_,0);
  if ((char)pvVar3 != '\0') {
    return '\0';
  }
  pvVar3 = _objc_msgSend(canRecieveDataWhileDraggingFromPasteboard,sel_types,uVar7);
  pcVar8 = &cfstr_CorePasteboardFlavorType_0x6974756E;
  pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,&cfstr_CorePasteboardFlavorType_0x6974756E);
  if ((char)pvVar3 == '\0') {
    pvVar3 = (id)0x0;
  }
  else {
    pvVar3 = _objc_msgSend(self,sel_class,pcVar8);
    pcVar8 = canRecieveDataWhileDraggingFromPasteboard;
    pvVar3 = _objc_msgSend(pvVar3,sel_iTunesSpecificFilenamesFromPasteboard_,
                           canRecieveDataWhileDraggingFromPasteboard);
  }
  pvVar4 = _objc_msgSend(canRecieveDataWhileDraggingFromPasteboard,sel_types,pcVar8);
  puVar1 = PTR_00336414;
  pvVar9 = *(id *)PTR_00336414;
  pvVar4 = _objc_msgSend(pvVar4,sel_containsObject_,pvVar9);
  if ((char)pvVar4 != '\0') {
    pvVar9 = *(id *)puVar1;
    pvVar3 = _objc_msgSend(canRecieveDataWhileDraggingFromPasteboard,sel_propertyListForType_,pvVar9
                          );
  }
  pvVar4 = _objc_msgSend(pvVar3,sel_count,pvVar9);
  if (pvVar4 < (id)0x2) {
    if (pvVar4 == (id)0x1) {
      return '\x01';
    }
LAB_001e612f:
    cVar2 = '\0';
  }
  else {
    pvVar4 = _objc_msgSend(pvVar3,sel_objectEnumerator,pvVar9);
    pvVar3 = _objc_msgSend(pvVar4,sel_nextObject);
    if (pvVar3 == (id)0x0) goto LAB_001e612f;
    cVar2 = '\0';
    do {
      pvVar5 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar9);
      pvVar9 = pvVar3;
      pvVar5 = _objc_msgSend(pvVar5,sel_hyperResolveAliasAtPath_);
      if (pvVar5 != (id)0x0) {
        pvVar3 = pvVar5;
      }
      if (cVar2 == '\0') {
        pvVar9 = (id)0x0;
        pvVar5 = pvVar3;
        pvVar6 = _objc_msgSend(cls_HSNewMediaAccessor,sel_canCreateMediaObjectOfClass_withPath_,0,
                               pvVar3);
        if ((char)pvVar6 != '\0') goto LAB_001e6136;
        pvVar9 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar9,pvVar5);
        pvVar5 = _objc_msgSend(pvVar9,sel_hyperIsTextForPath_,pvVar3);
        pvVar9 = pvVar3;
        if ((char)pvVar5 != '\0') goto LAB_001e6136;
        cVar2 = '\0';
      }
      else {
LAB_001e6136:
        cVar2 = '\x01';
      }
      pvVar3 = _objc_msgSend(pvVar4,sel_nextObject,pvVar9);
    } while (pvVar3 != (id)0x0);
    if (cVar2 != '\0') goto LAB_001e62b1;
  }
  pvVar3 = _objc_msgSend(canRecieveDataWhileDraggingFromPasteboard,sel_types,pvVar9);
  pvVar9 = *(id *)PTR_00336418;
  pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar9);
  if ((char)pvVar3 != '\0') {
    pvVar9 = canRecieveDataWhileDraggingFromPasteboard;
    pvVar3 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,
                           canRecieveDataWhileDraggingFromPasteboard);
    pvVar4 = _objc_msgSend(pvVar3,sel_isFileURL);
    puVar1 = cls_HSNewMediaAccessor;
    if ((char)pvVar4 != '\0') {
      pvVar3 = _objc_msgSend(pvVar3,sel_path,pvVar9);
      pvVar9 = (id)0x0;
      pvVar3 = _objc_msgSend(puVar1,sel_canCreateMediaObjectOfClass_withPath_,0,pvVar3);
      cVar2 = (char)pvVar3;
    }
  }
LAB_001e62b1:
  if (cVar2 != '\0') {
    return cVar2;
  }
  pvVar3 = _objc_msgSend(cls_NSImage,sel_imagePasteboardTypes,pvVar9);
  pvVar3 = _objc_msgSend(canRecieveDataWhileDraggingFromPasteboard,sel_availableTypeFromArray_,
                         pvVar3);
  if (pvVar3 != (id)0x0) {
    return '\x01';
  }
  pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObjects_,&cfstr_HSObjectsPasteboardType,
                         &cfstr_HSLibraryObjectsPasteboardType,&cfstr_HSCardsIndexPasteboardType,
                         *(undefined4 *)PTR_003367b8,*(undefined4 *)PTR_003367b4,
                         &cfstr_HSSerializedRichTextPasteboardType,*(undefined4 *)PTR_003361bc,0);
  pvVar3 = _objc_msgSend(canRecieveDataWhileDraggingFromPasteboard,sel_availableTypeFromArray_,
                         pvVar3);
  return pvVar3 != (id)0x0;
}

*/
- (BOOL)canRecieveDataWhileDraggingFromPasteboard:(id)aPasteboard
{
    if ([self isLockedObject:nil]) {
        return NO;
    }
    NSArray *files = nil;
    if ([[aPasteboard types] containsObject:@"CorePasteboardFlavorType 0x6974756E"]) {
        files = [[self class] iTunesSpecificFilenamesFromPasteboard:aPasteboard];
    }
    if ([[aPasteboard types] containsObject:NSFilenamesPboardType]) {
        files = [aPasteboard propertyListForType:NSFilenamesPboardType];
    }
    NSUInteger count = [files count];
    BOOL canReceive = NO;
    if (count == 1) {
        return YES;
    }
    if (count >= 2) {
        for (NSString *path in [files objectEnumerator]) {
            NSString *resolvedPath = [[NSFileManager defaultManager] hyperResolveAliasAtPath:path];
            if (resolvedPath != nil) {
                path = resolvedPath;
            }
            if (!canReceive) {
                canReceive = [HSNewMediaAccessor canCreateMediaObjectOfClass:nil withPath:path]
                    || [[NSFileManager defaultManager] hyperIsTextForPath:path];
            }
        }
    }
    if (!canReceive && [[aPasteboard types] containsObject:NSURLPboardType]) {
        NSURL *url = [NSURL URLFromPasteboard:aPasteboard];
        if ([url isFileURL]) {
            canReceive = [HSNewMediaAccessor canCreateMediaObjectOfClass:nil withPath:[url path]];
        }
    }
    if (canReceive) {
        return YES;
    }
    if ([aPasteboard availableTypeFromArray:[NSImage imagePasteboardTypes]] != nil) {
        return YES;
    }
    return [aPasteboard availableTypeFromArray:[NSArray arrayWithObjects:@"HSObjectsPasteboardType", @"HSLibraryObjectsPasteboardType", @"HSCardsIndexPasteboardType", NSRTFPboardType, NSRTFDPboardType, @"HSSerializedRichTextPasteboardType", NSStringPboardType, nil]] != nil;
}

- (BOOL)canRecieveDataFromPath:(id)aPath acceptingObject:(id)aObject dataName:(id *)aName
{
    return (BOOL)[self canRecieveDataFromPath:aPath acceptingObject:aObject dataName:aName canConnect:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e88fa @ 001e88fa, 899 bytes * /

BOOL FUN_001e88fa(HSEditorCardViewDragHelper *self,SEL _cmd,id canRecieveDataFromPath,
                 id acceptingObject,id *dataName,BOOL *canConnect)

{
  int iVar1;
  char cVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  cfstringStruct *pcVar9;
  bool bVar10;
  undefined1 *puVar11;
  undefined4 uVar12;
  id local_7c;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar3 = _objc_msgSend(cls_NSAttributedString,sel_textFileTypes);
  pvVar4 = _objc_msgSend(canRecieveDataFromPath,sel_pathExtension);
  pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar4);
  if ((char)pvVar3 == '\0') {
    if (canRecieveDataFromPath != (id)0x0) {
      pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,pvVar4);
      pvVar3 = _objc_msgSend(pvVar3,sel_hyperFileTypeAtPath_,canRecieveDataFromPath);
      if (pvVar3 != (id)0x0) {
        pvVar4 = _objc_msgSend(cls_HSNewMediaAccessor,sel_supportedMediaTypes,canRecieveDataFromPath
                              );
        pvVar4 = _objc_msgSend(pvVar4,sel_containsObject_,pvVar3);
        if ((char)pvVar4 == '\0') {
LAB_001e8b88:
          pvVar4 = _objc_msgSend(self,sel_isLockedObject_,acceptingObject);
          cVar2 = (char)pvVar4;
          if ((cVar2 == '\0') && (canConnect != (BOOL *)0x0)) {
            *canConnect = '\x01';
          }
        }
        else {
          pvVar4 = _objc_msgSend(self,sel_actionClassesForMediaType_,pvVar3);
          pvVar5 = _objc_msgSend(pvVar4,sel_count);
          local_74 = 0;
          local_70 = 0;
          local_6c = (int *)0x0;
          local_68 = 0;
          local_64 = 0;
          local_60 = 0;
          local_5c = 0;
          local_58 = 0;
          puVar11 = local_50;
          uVar12 = 0x10;
          local_7c = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,&local_74,
                                   puVar11,0x10);
          if (local_7c != (id)0x0) {
            iVar1 = *local_6c;
            do {
              pvVar8 = (id)0x0;
              do {
                if (iVar1 != *local_6c) {
                  _objc_enumerationMutation(pvVar4);
                }
                pvVar7 = *(id *)(local_70 + (int)pvVar8 * 4);
                puVar11 = acceptingObject;
                pvVar6 = _objc_msgSend(self,sel_canAddActionOfClass_intoObject_,pvVar7,
                                       acceptingObject,uVar12);
                if (((char)pvVar6 == '\0') ||
                   ((pvVar6 = _objc_msgSend(acceptingObject,sel_implementsHyperInterface_,
                                            &DAT_00380014,puVar11), (char)pvVar6 != '\0' &&
                    (pvVar7 = _objc_msgSend(pvVar7,sel_conformsToProtocol_,&DAT_0037fd08,puVar11),
                    (char)pvVar7 != '\0')))) goto LAB_001e8bb6;
                pvVar8 = (id)((int)pvVar8 + 1);
              } while (pvVar8 < local_7c);
              puVar11 = local_50;
              uVar12 = 0x10;
              local_7c = _objc_msgSend(pvVar4,sel_countByEnumeratingWithState_objects_count_,
                                       &local_74,puVar11,0x10);
            } while (local_7c != (id)0x0);
          }
          if (pvVar5 != (id)0x0) goto LAB_001e8b88;
LAB_001e8bb6:
          pvVar4 = _objc_msgSend(self,sel_isLockedObject_,0,puVar11,uVar12);
          cVar2 = (char)pvVar4;
        }
        bVar10 = cVar2 == '\0';
        if (!bVar10) {
          return bVar10;
        }
        if (dataName == (id *)0x0) {
          return bVar10;
        }
        pvVar4 = _objc_msgSend(cls_HSNewMedia,sel_mediaGroupForMediaType_,pvVar3);
        if (pvVar4 == (id)0x3) {
          pcVar9 = &cfstr_HSPasteImage;
        }
        else if (pvVar4 == (id)0x2) {
          pcVar9 = &cfstr_HSPasteSound;
        }
        else {
          if (pvVar4 != (id)0x1) {
            return bVar10;
          }
          pcVar9 = &cfstr_HSPasteMovie;
        }
        goto LAB_001e8c27;
      }
    }
    bVar10 = false;
  }
  else {
    pvVar3 = (id)0x0;
    pvVar4 = _objc_msgSend(self,sel_isLockedObject_,0);
    bVar10 = (char)pvVar4 == '\0';
    pcVar9 = &cfstr_HSPasteText;
LAB_001e8c27:
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
    pvVar3 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,pcVar9,&cfstr_empty,
                           &cfstr_Editor);
    *dataName = pvVar3;
  }
  return bVar10;
}

*/
- (BOOL)canRecieveDataFromPath:(id)aPath acceptingObject:(id)aObject dataName:(id *)aName canConnect:(BOOL *)aConnect
{
    NSString *nameKey;
    BOOL result;
    if ([[NSAttributedString textFileTypes] containsObject:[aPath pathExtension]]) {
        result = ![self isLockedObject:nil];
        nameKey = @"HSPasteText";
    } else {
        if (aPath == nil) {
            return NO;
        }
        NSString *mediaType = [[NSFileManager defaultManager] hyperFileTypeAtPath:aPath];
        if (mediaType == nil) {
            return NO;
        }
        BOOL locked;
        if (![[HSNewMediaAccessor supportedMediaTypes] containsObject:mediaType]) {
            locked = [self isLockedObject:aObject];
            if (!locked && aConnect != NULL) {
                *aConnect = YES;
            }
        } else {
            // The media can connect to the object only if every action it brings can be added.
            NSArray *actionClasses = [self actionClassesForMediaType:mediaType];
            BOOL allAddable = [actionClasses count] != 0;
            for (Class actionClass in actionClasses) {
                if (![self canAddActionOfClass:actionClass intoObject:aObject]
                    || ([aObject implementsHyperInterface:@protocol(HSMovieObjectAttributes)]
                        && [actionClass conformsToProtocol:@protocol(HSPlayMovieActionAttributes)])) {
                    allAddable = NO;
                    break;
                }
            }
            if (allAddable) {
                locked = [self isLockedObject:aObject];
                if (!locked && aConnect != NULL) {
                    *aConnect = YES;
                }
            } else {
                locked = [self isLockedObject:nil];
            }
        }
        if (locked) {
            return NO;
        }
        result = YES;
        if (aName == NULL) {
            return YES;
        }
        NSInteger group = [HSNewMedia mediaGroupForMediaType:mediaType];
        if (group == 3) {
            nameKey = @"HSPasteImage";
        } else if (group == 2) {
            nameKey = @"HSPasteSound";
        } else if (group == 1) {
            nameKey = @"HSPasteMovie";
        } else {
            return YES;
        }
    }
    // Fix: the original wrote the text name without checking for NULL.
    if (aName != NULL) {
        *aName = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:nameKey value:@"" table:@"Editor"];
    }
    return result;
}

- (BOOL)canRecieveDataFromPath:(id)aPath acceptingObject:(id)aObject
{
    return (BOOL)[self canRecieveDataFromPath:aPath acceptingObject:aObject dataName:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e5e93 @ 001e5e93, 205 bytes * /

BOOL FUN_001e5e93(HSEditorCardViewDragHelper *self,SEL _cmd,id isLockedObject)

{
  SEL op;
  id pvVar1;
  bool bVar2;
  undefined *puVar3;
  
  if (isLockedObject == (id)0x0) {
    pvVar1 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037fe70);
    pvVar1 = _objc_msgSend(pvVar1,sel_stack);
    puVar3 = &DAT_0037fe84;
    pvVar1 = _objc_msgSend(pvVar1,sel_queryHyperInterface_,&DAT_0037fe84);
    op = sel_isStackProtected;
  }
  else {
    puVar3 = &DAT_0037fd80;
    pvVar1 = _objc_msgSend(isLockedObject,sel_queryHyperInterface_,&DAT_0037fd80);
    op = sel_isLocked;
  }
  if (pvVar1 == (id)0x0) {
    bVar2 = false;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,op,puVar3);
    bVar2 = (char)pvVar1 != '\0';
  }
  return bVar2;
}

*/
- (BOOL)isLockedObject:(id)aObject
{
    id attributes;
    if (aObject == nil) {
        // Without an object the stack's protection decides.
        attributes = [[[[_dragHost cardForDragHost] queryHyperInterface:@protocol(HSUserObjectSupport)] stack] queryHyperInterface:@protocol(HSMutableStackAttributes)];
        return attributes != nil && [attributes isStackProtected];
    }
    attributes = [aObject queryHyperInterface:@protocol(HSCardObjectAttributes)];
    return attributes != nil && [attributes isLocked];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e971f @ 001e971f, 372 bytes * /

id FUN_001e971f(HSEditorCardViewDragHelper *self,SEL _cmd,id actionClassesForMediaType)

{
  int iVar1;
  id pvVar2;
  id self_00;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  id pvVar6;
  undefined1 *puVar7;
  undefined4 uVar8;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_new);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  self_00 = _objc_msgSend(cls_HSNewMediaAccessor,sel_userActionClassNamesForMediaType_,
                          actionClassesForMediaType);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar7 = local_50;
  uVar8 = 0x10;
  pvVar3 = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,&local_74,puVar7,
                         0x10);
  if (pvVar3 != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar6 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(self_00);
        }
        pvVar4 = _objc_msgSend(self_00,sel_objectForKey_,*(undefined4 *)(local_70 + (int)pvVar6 * 4)
                               ,puVar7,uVar8);
        uVar5 = _NSClassFromString(pvVar4);
        _objc_msgSend(pvVar2,sel_addObject_,uVar5);
        pvVar6 = (id)((int)pvVar6 + 1);
      } while (pvVar6 < pvVar3);
      puVar7 = local_50;
      uVar8 = 0x10;
      pvVar3 = _objc_msgSend(self_00,sel_countByEnumeratingWithState_objects_count_,&local_74,puVar7
                             ,0x10);
    } while (pvVar3 != (id)0x0);
  }
  return pvVar2;
}

*/
- (id)actionClassesForMediaType:(id)aType
{
    NSMutableArray *classes = [[NSMutableArray new] autorelease];
    NSDictionary *classNames = [HSNewMediaAccessor userActionClassNamesForMediaType:aType];
    for (id key in classNames) {
        Class actionClass = NSClassFromString([classNames objectForKey:key]);
        // Fix: skip classes that do not exist instead of raising.
        if (actionClass != Nil) {
            [classes addObject:actionClass];
        }
    }
    return classes;
}

- (BOOL)canAddAction:(id)aAction intoObject:(id)aObject
{
    return (BOOL)[self canAddActionOfClass:[aAction class] intoObject:aObject];
}

- (BOOL)canAddActionOfClass:(Class)aClass intoObject:(id)aObject
{
    BOOL bVar2;

    if ((aObject == nil) || (aClass == Nil)) {
        bVar2 = NO;
    }
    else {
        if (![aClass conformsToProtocol:@protocol(HSPlayMovieActionAttributes)]) {
            bVar2 = YES;
        }
        else {
            bVar2 = ![aObject implementsHyperInterface:@protocol(HSCardAttributes)];
        }
    }
    return bVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e5b12 @ 001e5b12, 708 bytes * /

BOOL FUN_001e5b12(HSEditorCardViewDragHelper *self,SEL _cmd,id addObjectsInArray,id intoObject,
                 BOOL center,BOOL fitCanvas,BOOL needOpenHelpPane,BOOL isPasting,
                 BOOL useDragPreferences,BOOL pastingNotHSObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  int iVar7;
  int iVar8;
  int iVar9;
  int iVar10;
  int iVar11;
  BOOL BVar13;
  uint uVar12;
  char *pcVar14;
  undefined4 uVar15;
  char local_12;
  char local_11;
  
  local_11 = '\0';
  local_12 = '\0';
  pvVar1 = _objc_msgSend(self,sel_editorDocument);
  pvVar2 = _objc_msgSend(pvVar1,sel_editorWindowController);
  pvVar1 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  pvVar2 = _objc_msgSend(pvVar2,sel_verifyObjects_beforeAddToCard_,addObjectsInArray,pvVar1);
  pvVar3 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar3 == (id)0x0) {
    BVar13 = '\0';
  }
  else {
    _objc_msgSend(self->_dragHost,sel_beginDragOperation,addObjectsInArray,pvVar1);
    pvVar3 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
    pvVar4 = _objc_msgSend(pvVar2,sel_count);
    if (pvVar4 < (id)0x2) {
      pvVar3 = _objc_msgSend(pvVar2,sel_count);
      if (pvVar3 == (id)0x1) {
        addObjectsInArray = _objc_msgSend(pvVar2,sel_lastObject);
        pvVar1 = _objc_msgSend(self,
                               sel_addObject_intoObject_center_fitCanvas_isHyperObject_needOpenHelpPane_isPasting_useDragPreferences_pastingNotHSObject_
                               ,addObjectsInArray,intoObject,(int)center,(int)fitCanvas,&local_11,
                               (int)needOpenHelpPane,(int)isPasting,(int)useDragPreferences,
                               (int)pastingNotHSObject);
        BVar13 = (BOOL)pvVar1;
      }
      else {
        BVar13 = '\0';
        intoObject = pvVar1;
      }
    }
    else {
      _objc_msgSend(pvVar3,sel_hyperAddChildrenBeginGrouping);
      pvVar4 = _objc_msgSend(pvVar2,sel_objectEnumerator);
      pvVar5 = _objc_msgSend(pvVar4,sel_nextObject);
      if (pvVar5 == (id)0x0) {
        uVar12 = 0;
      }
      else {
        uVar12 = (uint)(byte)pastingNotHSObject;
        do {
          iVar7 = (int)(char)uVar12;
          iVar8 = (int)useDragPreferences;
          iVar9 = (int)isPasting;
          pcVar14 = &local_12;
          iVar10 = (int)fitCanvas;
          iVar11 = (int)center;
          uVar15 = 0;
          pvVar1 = intoObject;
          pvVar6 = _objc_msgSend(self,
                                 sel_addObject_intoObject_center_fitCanvas_isHyperObject_needOpenHelpPane_isPasting_useDragPreferences_pastingNotHSObject_
                                 ,pvVar5,intoObject,iVar11,iVar10,pcVar14,0,iVar9,iVar8,iVar7);
          uVar12 = (uint)CONCAT11((char)(uVar12 >> 8) != '\0' || (char)pvVar6 != '\0',(char)uVar12);
          if ((local_11 == '\0') && (local_12 == '\0')) {
            local_11 = '\0';
          }
          else {
            local_11 = '\x01';
          }
          addObjectsInArray = pvVar5;
          pvVar5 = _objc_msgSend(pvVar4,sel_nextObject,pvVar5,pvVar1,iVar11,iVar10,pcVar14,uVar15,
                                 iVar9,iVar8,iVar7);
        } while (pvVar5 != (id)0x0);
      }
      BVar13 = (BOOL)(uVar12 >> 8);
      _objc_msgSend(pvVar3,sel_hyperAddChildrenEndGrouping,addObjectsInArray,pvVar1);
      intoObject = pvVar1;
    }
    if (local_11 != '\0') {
      pvVar1 = _objc_msgSend(self,sel_editorDocument,addObjectsInArray,intoObject);
      _objc_msgSend(pvVar1,sel_selectInEditorCardViewObjects_,pvVar2);
      addObjectsInArray = pvVar2;
    }
    _objc_msgSend(self->_dragHost,sel_endDragOperation,addObjectsInArray,intoObject);
  }
  return BVar13;
}

*/
- (BOOL)addObjectsInArray:(id)aArray intoObject:(id)aObject center:(BOOL)aCenter fitCanvas:(BOOL)aCanvas needOpenHelpPane:(BOOL)aPane isPasting:(BOOL)aPasting useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL)aObject2
{
    BOOL addedHyperObject = NO;
    BOOL result = NO;
    NSArray *objects = [[[self editorDocument] editorWindowController] verifyObjects:aArray beforeAddToCard:[_dragHost cardForDragHost]];
    if ([objects count] == 0) {
        return NO;
    }
    [_dragHost beginDragOperation];
    id card = [_dragHost cardForDragHost];
    if ([objects count] < 2) {
        result = [self addObject:[objects lastObject] intoObject:aObject center:aCenter fitCanvas:aCanvas isHyperObject:&addedHyperObject needOpenHelpPane:aPane isPasting:aPasting useDragPreferences:aPreferences pastingNotHSObject:aObject2];
    } else {
        // Several objects are added as one change and never open the help pane.
        [card hyperAddChildrenBeginGrouping];
        for (id object in [objects objectEnumerator]) {
            BOOL isHyperObject = NO;
            if ([self addObject:object intoObject:aObject center:aCenter fitCanvas:aCanvas isHyperObject:&isHyperObject needOpenHelpPane:NO isPasting:aPasting useDragPreferences:aPreferences pastingNotHSObject:aObject2]) {
                result = YES;
            }
            addedHyperObject = addedHyperObject || isHyperObject;
        }
        [card hyperAddChildrenEndGrouping];
    }
    if (addedHyperObject) {
        [[self editorDocument] selectInEditorCardViewObjects:objects];
    }
    [_dragHost endDragOperation];
    return result;
}

- (BOOL)addObjectsInArray:(id)aArray intoObject:(id)aObject center:(BOOL)aCenter fitCanvas:(BOOL)aCanvas isPasting:(BOOL)aPasting useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL)aObject2
{
    return (BOOL)[self addObjectsInArray:aArray intoObject:aObject center:aCenter fitCanvas:aCanvas needOpenHelpPane:YES isPasting:aPasting useDragPreferences:aPreferences pastingNotHSObject:aObject2];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e9893 @ 001e9893, 2496 bytes * /

BOOL FUN_001e9893(HSEditorCardViewDragHelper *self,SEL _cmd,id addObject,id intoObject,BOOL center,
                 BOOL fitCanvas,BOOL *isHyperObject,BOOL needOpenHelpPane,BOOL isPasting,
                 BOOL useDragPreferences,BOOL pastingNotHSObject)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id pvVar4;
  id pvVar5;
  HSEditorCardViewDragHelper *self_01;
  float extraout_EDX;
  float extraout_EDX_00;
  bool bVar6;
  BOOL BVar7;
  id *ppvVar8;
  undefined4 *puVar9;
  id local_80;
  SEL op;
  id local_38;
  undefined1 local_2c [28];
  
  puVar9 = (undefined4 *)&stack0xffffff84;
  ppvVar8 = (id *)&stack0xffffff84;
  local_80 = (id)0x1e98b7;
  pvVar2 = _objc_msgSend(self,sel_editorDocument);
  local_80 = (id)0x1e98c9;
  pvVar2 = _objc_msgSend(pvVar2,sel_editorWindowController);
  local_80 = (id)0x1e98db;
  pvVar2 = _objc_msgSend(pvVar2,sel_cardView);
  local_80 = (id)0x1e98fc;
  pvVar3 = _objc_msgSend(addObject,sel_implementsHyperInterface_);
  local_38 = intoObject;
  if ((char)pvVar3 == '\0') {
    local_80 = (id)0x1ea148;
    pvVar3 = _objc_msgSend(addObject,sel_queryHyperInterface_);
    if (pvVar3 != (id)0x0) {
      if (needOpenHelpPane != '\0') {
        local_80 = (id)0x1ea176;
        pvVar3 = _objc_msgSend(pvVar2,sel_needsOpenHelpPaneBeforeAddObject_toNodeContainer_);
        if ((char)pvVar3 != '\0') {
          local_80 = (id)0x1ea1a5;
          _objc_msgSend(self,sel_actionEventForAction_addedIntoObject_useDragPreferences_);
          local_80 = (id)0x1ea1ce;
          _objc_msgSend(pvVar2,
                        sel_showHelpPaneBeforeAddAction_actionEvent_toNodeContainer_useDragPreferences_
                       );
          BVar7 = '\0';
          BVar1 = '\0';
          goto LAB_001ea23d;
        }
      }
      local_80 = (id)0x1ea1f1;
      _objc_msgSend(self,sel_setupPasteUndoActionNameIfNeeded_);
      local_80 = (id)0x1ea214;
      _objc_msgSend(self,sel_prepareAction_forAddingIntoObject_);
      local_80 = (id)0x1ea239;
      _objc_msgSend(self,sel_addAction_intoObject_useDragPreferences_);
    }
    BVar1 = '\0';
    BVar7 = '\x01';
    goto LAB_001ea23d;
  }
  local_80 = (id)0x1e992a;
  _objc_msgSend(self,sel_setupPasteUndoActionNameIfNeeded_);
  local_80 = (id)0x1e9942;
  pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults);
  local_80 = (id)0x1e9964;
  self_00 = _objc_msgSend(addObject,sel_queryHyperInterface_);
  local_80 = (id)0x1e997c;
  pvVar4 = _objc_msgSend(self_00,sel_image);
  if (self_00 == (id)0x0) {
LAB_001e9c41:
    if (useDragPreferences == '\0') {
LAB_001e9c47:
      pvVar4 = (id)0x3;
    }
    else {
      local_80 = (id)0x1e9c6f;
      pvVar4 = _objc_msgSend(pvVar3,sel_objectForKey_);
      if (pvVar4 == (id)0x0) goto LAB_001e9c47;
      local_80 = (id)0x1e9c85;
      pvVar4 = _objc_msgSend(pvVar4,sel_intValue);
    }
    if ((isPasting != '\0') || (needOpenHelpPane == '\0')) {
LAB_001e9ce7:
      if ((pvVar4 != (id)0x3) || (self_00 == (id)0x0 || pastingNotHSObject == '\0')) {
LAB_001e9d14:
        bVar6 = (self_00 != (id)0x0 && pastingNotHSObject != '\0') && pvVar4 != (id)0x0;
      }
      else {
        local_80 = (id)0x1e9d40;
        pvVar2 = _objc_msgSend(self_00,sel_queryHyperInterface_);
        local_80 = (id)0x1e9d52;
        pvVar2 = _objc_msgSend(pvVar2,sel_affineFrameSize);
        local_80 = (id)0x1e9d6f;
        pvVar5 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
        local_80 = (id)0x1e9d81;
        pvVar5 = _objc_msgSend(pvVar5,sel_stack);
        local_80 = (id)0x1e9d9c;
        pvVar5 = _objc_msgSend(pvVar5,sel_hyperCardSize);
        if (((float)pvVar5 < (float)pvVar2) || (extraout_EDX_00 < extraout_EDX)) goto LAB_001e9d14;
        bVar6 = false;
      }
      self_01 = self;
      op = sel_addObjectToCenterOfCard_;
      if (((useDragPreferences == '\0' || center == '\0') && (!bVar6)) &&
         (op = sel_addObjectToCenter_, center == '\0')) {
        local_80 = (id)0x1e9e16;
        self_01 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
        op = sel_addHyperChild_;
      }
      local_80 = (id)0x1e9e2f;
      _objc_msgSend(self_01,op);
      local_80 = (id)0x1e9e47;
      pvVar2 = _objc_msgSend(cls_HSObjectAssistantController,sel_sharedAssistantController);
      local_80 = (id)0x1e9e5b;
      pvVar4 = _objc_msgSend(pvVar2,sel_isActive);
      if ((char)pvVar4 == '\0') {
        local_80 = (id)0x1e9e7b;
        pvVar4 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
        local_80 = (id)0x1e9e8d;
        pvVar4 = _objc_msgSend(pvVar4,sel_dontShowAllCoachingHints);
        if ((char)pvVar4 == '\0') {
          local_80 = (id)0x1e9ea9;
          pvVar4 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
          local_80 = (id)0x1e9ec0;
          _objc_msgSend(addObject,sel_class);
          local_80 = (id)0x1e9ec8;
          _NSStringFromClass();
          local_80 = (id)0x1e9ede;
          pvVar4 = _objc_msgSend(pvVar4,sel_dontShowCoachingHintsForKey_);
          if ((char)pvVar4 == '\0') {
            local_80 = (id)0x1e9efc;
            _objc_msgSend(pvVar2,sel_setActive_);
          }
        }
      }
      puVar9 = (undefined4 *)&stack0xffffff84;
      if (self_00 != (id)0x0) {
        if (useDragPreferences != '\0') {
          local_80 = (id)0x1e9f2b;
          pvVar2 = _objc_msgSend(addObject,sel_queryHyperInterface_);
          local_80 = (id)0x1e9f4e;
          _objc_msgSend(pvVar3,sel_boolForKey_);
          local_80 = (id)0x1e9f67;
          _objc_msgSend(pvVar2,sel_setHyperShadowEnabled_);
        }
        if (fitCanvas != '\0') {
          local_80 = (id)0x1e9f89;
          _objc_msgSend(self_00,sel_resizeWithMode_);
        }
        puVar9 = (undefined4 *)&stack0xffffff84;
        if (useDragPreferences != '\0') {
          local_80 = (id)0x1e9fb4;
          pvVar2 = _objc_msgSend(pvVar3,sel_boolForKey_);
          puVar9 = (undefined4 *)&stack0xffffff84;
          if ((char)pvVar2 != '\0') {
            local_80 = (id)0x1e9fd1;
            pvVar2 = _objc_msgSend(self_00,sel_media);
            local_80 = (id)0x1e9fe3;
            pvVar2 = _objc_msgSend(pvVar2,sel_GPSDictionary);
            puVar9 = (undefined4 *)&stack0xffffff84;
            if (pvVar2 != (id)0x0) {
              local_80 = (id)0x1ea00b;
              pvVar3 = _objc_msgSend(pvVar2,sel_objectForKey_);
              puVar9 = (undefined4 *)&stack0xffffff84;
              if (pvVar3 != (id)0x0) {
                local_80 = (id)0x1ea033;
                pvVar2 = _objc_msgSend(pvVar2,sel_objectForKey_);
                puVar9 = (undefined4 *)&stack0xffffff84;
                if (pvVar2 != (id)0x0) {
                  local_80 = (id)0x1ea065;
                  pvVar2 = _objc_msgSend(cls_NSString,sel_stringWithFormat_);
                  puVar9 = (undefined4 *)&stack0xffffff84;
                  if (pvVar2 != (id)0x0) {
                    local_80 = (id)0x1ea089;
                    pvVar2 = _objc_msgSend(cls_NSURL,sel_URLWithString_);
                    puVar9 = (undefined4 *)&stack0xffffff84;
                    if (pvVar2 != (id)0x0) {
                      local_80 = (id)0x1ea0a9;
                      pvVar2 = _objc_msgSend(cls_HSGoToURLAction,sel_actionWithURL_);
                      puVar9 = (undefined4 *)&stack0xffffff84;
                      if (pvVar2 != (id)0x0) goto LAB_001ea0ff;
                    }
                  }
                }
              }
            }
          }
        }
      }
      goto LAB_001ea104;
    }
    local_80 = (id)0x1e9cb4;
    pvVar5 = _objc_msgSend(pvVar2,sel_needsOpenHelpPaneBeforeAddObject_toNodeContainer_);
    if ((char)pvVar5 == '\0') goto LAB_001e9ce7;
    local_80 = (id)0x1e9ce0;
    _objc_msgSend(pvVar2,sel_showHelpPaneBeforeAddObject_toNodeContainer_useDragPreferences_);
    BVar7 = '\0';
  }
  else {
    local_80 = (id)0x1e99aa;
    pvVar5 = _objc_msgSend(pvVar3,sel_boolForKey_);
    if (((char)pvVar5 == '\0') || (useDragPreferences == '\0')) goto LAB_001e9c41;
    local_80 = (id)0x1e99db;
    pvVar2 = _objc_msgSend(intoObject,sel_implementsHyperInterface_);
    if ((char)pvVar2 == '\0') {
      local_80 = (id)0x1e99f4;
      local_38 = _objc_msgSend(intoObject,sel_hyperParent);
    }
    local_80 = (id)0x1e9a18;
    pvVar2 = _objc_msgSend(pvVar3,sel_objectForKey_);
    ppvVar8 = (id *)&stack0xffffff84;
    if (pvVar2 != (id)0x0) {
      local_80 = (id)0x1e9a2e;
      pvVar2 = _objc_msgSend(pvVar2,sel_intValue);
      ppvVar8 = (id *)&stack0xffffff84;
      if (((pvVar2 != (id)0x3) && (ppvVar8 = (id *)&stack0xffffff84, pvVar2 != (id)0x2)) &&
         ((ppvVar8 = (id *)&stack0xffffff84, pvVar2 != (id)0x1 &&
          (ppvVar8 = (id *)&stack0xffffff84, center == '\0')))) {
        local_80 = (id)0x1e9a77;
        _objc_msgSend(pvVar4,sel_hyperPixelsSize);
        local_80 = (id)0x1e9a8f;
        pvVar2 = _objc_msgSend(local_38,sel_stack);
        local_80 = (id)0x1e9aa1;
        _objc_msgSend(pvVar2,sel_hyperCardSize);
        local_80 = (id)0x1e9ac2;
        pvVar2 = _objc_msgSend(self_00,sel_queryHyperInterface_);
        local_80 = (id)0x1e9adb;
        _objc_msgSend_stret(local_2c,pvVar2,sel_affineTransform);
        local_80 = local_38;
        ppvVar8 = &local_80;
      }
    }
    ppvVar8[-1] = (id)0x1e9b4c;
    _objc_msgSend(*ppvVar8,ppvVar8[1]);
    ppvVar8[1] = sel_media;
    *ppvVar8 = self_00;
    ppvVar8[-1] = (id)0x1e9b61;
    pvVar2 = _objc_msgSend(*ppvVar8,ppvVar8[1]);
    ppvVar8[1] = sel_fullPathToMediaFile;
    *ppvVar8 = pvVar2;
    ppvVar8[-1] = (id)0x1e9b73;
    pvVar2 = _objc_msgSend(*ppvVar8,ppvVar8[1]);
    if (pvVar2 == (id)0x0) {
      ppvVar8[2] = &DAT_0037f7e0;
      ppvVar8[1] = sel_queryHyperInterface_;
      *ppvVar8 = self_00;
      ppvVar8[-1] = (id)0x1e9bde;
      pvVar2 = _objc_msgSend(*ppvVar8,ppvVar8[1]);
      ppvVar8[1] = sel_hyperName;
      *ppvVar8 = pvVar2;
    }
    else {
      ppvVar8[1] = sel_class;
      *ppvVar8 = self;
      ppvVar8[-1] = (id)0x1e9b8e;
      pvVar3 = _objc_msgSend(*ppvVar8,ppvVar8[1]);
      ppvVar8[2] = pvVar2;
      ppvVar8[1] = sel_fileURLWithPath_;
      *ppvVar8 = cls_NSURL;
      ppvVar8[-1] = (id)0x1e9bac;
      pvVar2 = _objc_msgSend(*ppvVar8,ppvVar8[1]);
      ppvVar8[2] = pvVar2;
      ppvVar8[1] = sel_commentsForDroppedObjectWithURL_;
      *ppvVar8 = pvVar3;
    }
    ppvVar8[-1] = (id)0x1e9bf0;
    pvVar2 = _objc_msgSend(*ppvVar8,ppvVar8[1]);
    ppvVar8[1] = sel_length;
    *ppvVar8 = pvVar2;
    ppvVar8[-1] = (id)0x1e9c04;
    pvVar3 = _objc_msgSend(*ppvVar8,ppvVar8[1]);
    puVar9 = ppvVar8;
    if (pvVar3 != (id)0x0) {
      ppvVar8[2] = &DAT_0037fb8c;
      ppvVar8[1] = sel_queryHyperInterface_;
      *ppvVar8 = local_38;
      ppvVar8[-1] = (id)0x1e9c2b;
      pvVar3 = _objc_msgSend(*ppvVar8,ppvVar8[1]);
      ppvVar8[2] = pvVar2;
      ppvVar8[1] = sel_setHyperComments_;
      *ppvVar8 = pvVar3;
LAB_001ea0ff:
      ppvVar8[-1] = (id)0x1ea104;
      _objc_msgSend(*ppvVar8,ppvVar8[1]);
      puVar9 = ppvVar8;
    }
LAB_001ea104:
    BVar7 = '\x01';
  }
  puVar9[2] = addObject;
  puVar9[1] = sel_prepareGroupObjectIfNeeded_;
  *puVar9 = self;
  puVar9[-1] = 0x1ea122;
  _objc_msgSend((id)*puVar9,(SEL)puVar9[1]);
  BVar1 = '\x01';
LAB_001ea23d:
  if (isHyperObject != (BOOL *)0x0) {
    *isHyperObject = BVar1;
  }
  return BVar7;
}

*/
- (BOOL)addObject:(id)aObject intoObject:(id)aObject2 center:(BOOL)aCenter fitCanvas:(BOOL)aCanvas isHyperObject:(BOOL *)aObject3 needOpenHelpPane:(BOOL)aPane isPasting:(BOOL)aPasting useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL)aObject4
{
    id cardView = [[[self editorDocument] editorWindowController] cardView];
    BOOL isHyperObject;
    BOOL result;
    if (![aObject implementsHyperInterface:@protocol(HSNodeChild)]) {
        // Not a card object: it may be an action for the target object.
        isHyperObject = NO;
        result = YES;
        if ([aObject queryHyperInterface:@protocol(HSActionAttributes)] != nil) {
            if (aPane && [cardView needsOpenHelpPaneBeforeAddObject:aObject toNodeContainer:aObject2]) {
                id event = [self actionEventForAction:aObject addedIntoObject:aObject2 useDragPreferences:aPreferences];
                [cardView showHelpPaneBeforeAddAction:aObject actionEvent:event toNodeContainer:aObject2 useDragPreferences:aPreferences];
                result = NO;
            } else {
                [self setupPasteUndoActionNameIfNeeded:aPasting];
                [self prepareAction:aObject forAddingIntoObject:aObject2];
                [self addAction:aObject intoObject:aObject2 useDragPreferences:aPreferences];
            }
        }
        if (aObject3 != NULL) {
            *aObject3 = isHyperObject;
        }
        return result;
    }
    [self setupPasteUndoActionNameIfNeeded:aPasting];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id imageObject = [aObject queryHyperInterface:@protocol(HSImageObjectAttributes)];
    id image = [imageObject image];
    result = YES;
    if (imageObject != nil && [defaults boolForKey:HSImportImageAsBackgroundKey] && aPreferences) {
        // The image becomes the card background instead of an object.
        id card = aObject2;
        if (![aObject2 implementsHyperInterface:@protocol(HSMutableCardAttributes)]) {
            card = [aObject2 hyperParent];
        }
        id layout = [defaults objectForKey:HSImportedImageLayoutKey];
        NSInteger scalingOption = 6;
        BOOL atPoint = NO;
        if (layout != nil) {
            int value = [layout intValue];
            if (value == 3) {
                scalingOption = 6;
            } else if (value == 2) {
                scalingOption = 2;
            } else if (value == 1) {
                scalingOption = 0;
            } else if (aCenter) {
                scalingOption = 4;
            } else {
                atPoint = YES;
            }
        }
        if (atPoint) {
            // Keep the dropped position, flipped to the card's coordinates.
            NSSize imageSize = [image hyperPixelsSize];
            NSSize cardSize = [[card stack] hyperCardSize];
            CGAffineTransform transform = [(id<HSGeometryAttributes>)[imageObject queryHyperInterface:@protocol(HSGeometryAttributes)] affineTransform];
            float y = (float)cardSize.height - ((float)imageSize.height + (float)transform.ty);
            [card importBackgroundFromImage:image toPoint:NSMakePoint(transform.tx, y) eraseBackground:NO];
        } else {
            [card importBackgroundFromImage:image imageScalingOption:scalingOption eraseBackground:NO];
        }
        NSString *path = [[imageObject media] fullPathToMediaFile];
        NSString *comments;
        if (path != nil) {
            comments = [[self class] commentsForDroppedObjectWithURL:[NSURL fileURLWithPath:path]];
        } else {
            comments = [[imageObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
        }
        if ([comments length] != 0) {
            [[card queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:comments];
        }
    } else {
        NSInteger layout = 3;
        if (aPreferences) {
            id layoutValue = [defaults objectForKey:HSImportedImageLayoutKey];
            if (layoutValue != nil) {
                layout = [layoutValue intValue];
            }
        }
        if (!aPasting && aPane && [cardView needsOpenHelpPaneBeforeAddObject:aObject toNodeContainer:aObject2]) {
            [cardView showHelpPaneBeforeAddObject:aObject toNodeContainer:aObject2 useDragPreferences:aPreferences];
            result = NO;
        } else {
            BOOL centerOnCard = imageObject != nil && aObject4 && layout != 0;
            if (layout == 3 && imageObject != nil && aObject4) {
                // An original-size image that fits keeps its place.
                NSSize frameSize = [(id<HSGeometryAttributes>)[imageObject queryHyperInterface:@protocol(HSGeometryAttributes)] affineFrameSize];
                NSSize cardSize = [[[_dragHost cardForDragHost] stack] hyperCardSize];
                if (cardSize.width >= frameSize.width && cardSize.height >= frameSize.height) {
                    centerOnCard = NO;
                }
            }
            if ((aCenter && aPreferences) || centerOnCard) {
                [self addObjectToCenterOfCard:aObject];
            } else if (aCenter) {
                [self addObjectToCenter:aObject];
            } else {
                [[_dragHost cardForDragHost] addHyperChild:aObject];
            }
            HSObjectAssistantController *assistant = [HSObjectAssistantController sharedAssistantController];
            HSCoachingHelpManager *coaching = [HSCoachingHelpManager sharedCoachingHelpManager];
            if (![assistant isActive] && ![coaching dontShowAllCoachingHints]
                && ![coaching dontShowCoachingHintsForKey:NSStringFromClass([aObject class])]) {
                [assistant setActive:YES];
            }
            if (imageObject != nil) {
                if (aPreferences) {
                    [[aObject queryHyperInterface:@protocol(HSMutableShadowAttributes)] setHyperShadowEnabled:[defaults boolForKey:HSImportImageWithShadowKey]];
                }
                if (aCanvas) {
                    [imageObject resizeWithMode:layout];
                }
                if (aPreferences && [defaults boolForKey:HSImportImageWithGoogleMapsConnectionKey]) {
                    // Photos with a location get a link to the map.
                    NSDictionary *gps = [[imageObject media] GPSDictionary];
                    id latitude = [gps objectForKey:(NSString *)kCGImagePropertyGPSLatitude];
                    id longitude = [gps objectForKey:(NSString *)kCGImagePropertyGPSLongitude];
                    if (gps != nil && latitude != nil && longitude != nil) {
                        NSString *address = [NSString stringWithFormat:@"http://maps.google.com/?q=%@,%@&spn=0.05,0.05&t=h&om=1&hl=en", latitude, longitude];
                        NSURL *url = address != nil ? [NSURL URLWithString:address] : nil;
                        id action = url != nil ? [HSGoToURLAction actionWithURL:url] : nil;
                        if (action != nil) {
                            [self addObject:action intoObject:aObject center:aCenter fitCanvas:aCanvas isHyperObject:NULL needOpenHelpPane:aPane isPasting:aPasting useDragPreferences:aPreferences pastingNotHSObject:aObject4];
                        }
                    }
                }
            }
        }
    }
    [self prepareGroupObjectIfNeeded:aObject];
    isHyperObject = YES;
    if (aObject3 != NULL) {
        *aObject3 = isHyperObject;
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e8028 @ 001e8028, 2258 bytes * /

void FUN_001e8028(HSEditorCardViewDragHelper *self,SEL _cmd,id prepareAction,id forAddingIntoObject)

{
  int iVar1;
  char cVar2;
  undefined1 *puVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  SEL pcVar11;
  undefined *puVar12;
  undefined4 uVar13;
  undefined4 *puVar14;
  undefined1 *puVar15;
  undefined4 uVar16;
  id local_154;
  id local_140;
  id local_13c;
  undefined4 local_134;
  int local_130;
  int *local_12c;
  undefined4 local_128;
  undefined4 local_124;
  undefined4 local_120;
  undefined4 local_11c;
  undefined4 local_118;
  undefined1 local_114 [64];
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
  
  puVar3 = _objc_msgSend(prepareAction,sel_queryHyperInterface_,&DAT_0037fd08);
  pvVar4 = _objc_msgSend(forAddingIntoObject,sel_queryHyperInterface_,&DAT_0037fe70);
  pvVar4 = _objc_msgSend(pvVar4,sel_card);
  puVar12 = &DAT_0037fd80;
  pvVar5 = _objc_msgSend(forAddingIntoObject,sel_queryHyperInterface_,&DAT_0037fd80);
  pvVar5 = _objc_msgSend(pvVar5,sel_isGroupObject);
  cVar2 = (char)pvVar5;
  if ((puVar3 != (undefined1 *)0x0) && (pvVar4 != (id)0x0)) {
    pvVar5 = _objc_msgSend(puVar3,sel_movies,puVar12);
    pvVar6 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar6 = _objc_msgSend(pvVar6,sel_init);
    if (cVar2 == '\0') {
      local_13c = (id)0x0;
    }
    else {
      local_13c = _objc_msgSend(cls_NSMutableSet,sel_new);
    }
    local_134 = 0;
    local_130 = 0;
    local_12c = (int *)0x0;
    local_128 = 0;
    local_124 = 0;
    local_120 = 0;
    local_11c = 0;
    local_118 = 0;
    puVar15 = local_114;
    uVar16 = 0x10;
    local_154 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,&local_134,
                              puVar15,0x10);
    if (local_154 != (id)0x0) {
      iVar1 = *local_12c;
      do {
        local_140 = (id)0x0;
        do {
          if (iVar1 != *local_12c) {
            _objc_enumerationMutation(pvVar5);
          }
          pvVar10 = *(id *)(local_130 + (int)local_140 * 4);
          pvVar7 = _objc_msgSend(pvVar10,sel_movieObjectForCard_,pvVar4,puVar15,uVar16);
          pvVar8 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,&DAT_0037fe70);
          local_140 = (id)((int)local_140 + 1);
          pvVar9 = _objc_msgSend(pvVar8,sel_card);
          pvVar8 = pvVar6;
          pcVar11 = sel_addObject_;
          if (pvVar9 == (id)0x0) {
            pvVar10 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037f8e4);
            _objc_msgSend(pvVar10,sel_addHyperChild_,pvVar7);
            pvVar10 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,&DAT_0037ffec);
            _objc_msgSend(pvVar10,sel_setAutoplayed_,0);
            pvVar10 = _objc_msgSend(cls_HSMoviePlaybackItem,sel_alloc);
            puVar15 = puVar3;
            pvVar8 = _objc_msgSend(pvVar10,sel_initWithMovieObject_playMovieAction_,pvVar7,puVar3);
            uVar13 = 1;
            _objc_msgSend(pvVar8,sel_setEnabled_,1);
            pvVar10 = _objc_msgSend(pvVar7,sel_isHyperQTVR);
            if (((char)pvVar10 == '\0') &&
               (pvVar10 = _objc_msgSend(pvVar7,sel_isHyperPanoramaObject,uVar13,puVar15),
               (char)pvVar10 == '\0')) {
              _objc_msgSend(pvVar8,sel_setEraseWhenDone_,1,puVar15);
            }
            pvVar10 = pvVar8;
            _objc_msgSend(pvVar6,sel_addObject_,pvVar8,puVar15);
            pcVar11 = sel_release;
          }
          _objc_msgSend(pvVar8,pcVar11,pvVar10);
          if ((cVar2 != '\0') &&
             (pvVar10 = _objc_msgSend(pvVar7,sel_isGroupObject,pvVar10), (char)pvVar10 == '\0')) {
            _objc_msgSend(local_13c,sel_addObject_,pvVar7);
          }
        } while (local_140 < local_154);
        puVar15 = local_114;
        uVar16 = 0x10;
        local_154 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,&local_134,
                                  puVar15,0x10);
      } while (local_154 != (id)0x0);
    }
    _objc_msgSend(puVar3,sel_setMovies_,pvVar6,puVar15,uVar16);
    _objc_msgSend(pvVar6,sel_release);
    pvVar5 = _objc_msgSend(puVar3,sel_liveVideos);
    pvVar6 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
    pvVar6 = _objc_msgSend(pvVar6,sel_init);
    local_d4 = 0;
    local_d0 = 0;
    local_cc = (int *)0x0;
    local_c8 = 0;
    local_c4 = 0;
    local_c0 = 0;
    local_bc = 0;
    local_b8 = 0;
    puVar15 = local_b4;
    uVar16 = 0x10;
    local_154 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,&local_d4,
                              puVar15,0x10);
    if (local_154 != (id)0x0) {
      iVar1 = *local_cc;
      do {
        local_140 = (id)0x0;
        do {
          if (iVar1 != *local_cc) {
            _objc_enumerationMutation(pvVar5);
          }
          pvVar10 = *(id *)(local_d0 + (int)local_140 * 4);
          pvVar7 = _objc_msgSend(pvVar10,sel_liveObjectForCard_,pvVar4,puVar15,uVar16);
          pvVar8 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,&DAT_0037fe70);
          local_140 = (id)((int)local_140 + 1);
          pvVar9 = _objc_msgSend(pvVar8,sel_card);
          pvVar8 = pvVar6;
          pcVar11 = sel_addObject_;
          if (pvVar9 == (id)0x0) {
            pvVar10 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037f8e4);
            _objc_msgSend(pvVar10,sel_addHyperChild_,pvVar7);
            pvVar10 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,&DAT_0037ffec);
            _objc_msgSend(pvVar10,sel_setAutoplayed_,0);
            pvVar10 = _objc_msgSend(cls_HSLiveVideoPlaybackItem,sel_alloc);
            puVar15 = puVar3;
            pvVar8 = _objc_msgSend(pvVar10,sel_initWithLiveObject_playMovieAction_,pvVar7,puVar3);
            _objc_msgSend(pvVar8,sel_setEnabled_,1);
            pvVar10 = pvVar8;
            _objc_msgSend(pvVar6,sel_addObject_,pvVar8);
            pcVar11 = sel_release;
          }
          _objc_msgSend(pvVar8,pcVar11,pvVar10,puVar15);
          if ((cVar2 != '\0') &&
             (pvVar10 = _objc_msgSend(pvVar7,sel_isGroupObject,pvVar10), (char)pvVar10 == '\0')) {
            _objc_msgSend(local_13c,sel_addObject_,pvVar7);
          }
        } while (local_140 < local_154);
        puVar15 = local_b4;
        uVar16 = 0x10;
        local_154 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,&local_d4,
                                  puVar15,0x10);
      } while (local_154 != (id)0x0);
    }
    _objc_msgSend(puVar3,sel_setLiveVideos_,pvVar6,puVar15,uVar16);
    _objc_msgSend(pvVar6,sel_release);
    if (local_13c != (id)0x0) {
      local_74 = 0;
      local_70 = 0;
      local_6c = (int *)0x0;
      local_68 = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      puVar3 = local_50;
      puVar14 = &local_74;
      uVar16 = 0x10;
      pvVar4 = _objc_msgSend(local_13c,sel_countByEnumeratingWithState_objects_count_,puVar14,puVar3
                             ,0x10);
      if (pvVar4 != (id)0x0) {
        iVar1 = *local_6c;
        do {
          pvVar5 = (id)0x0;
          do {
            if (iVar1 != *local_6c) {
              _objc_enumerationMutation(local_13c);
            }
            _objc_msgSend(*(id *)(local_70 + (int)pvVar5 * 4),sel_makeGroupObject,puVar14,puVar3,
                          uVar16);
            pvVar5 = (id)((int)pvVar5 + 1);
          } while (pvVar5 < pvVar4);
          puVar3 = local_50;
          puVar14 = &local_74;
          uVar16 = 0x10;
          pvVar4 = _objc_msgSend(local_13c,sel_countByEnumeratingWithState_objects_count_,puVar14,
                                 puVar3,0x10);
        } while (pvVar4 != (id)0x0);
      }
      _objc_msgSend(local_13c,sel_release,puVar14,puVar3,uVar16);
    }
  }
  return;
}

*/
- (void)prepareAction:(id)aAction forAddingIntoObject:(id)aObject
{
    id playMovie = [aAction queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
    id card = [[aObject queryHyperInterface:@protocol(HSUserObjectSupport)] card];
    BOOL isGroupObject = [[aObject queryHyperInterface:@protocol(HSCardObjectAttributes)] isGroupObject];
    if (playMovie == nil || card == nil) {
        return;
    }
    NSMutableSet *groupedObjects = isGroupObject ? [NSMutableSet new] : nil;
    NSArray *movies = [playMovie movies];
    NSMutableArray *newMovies = [[NSMutableArray alloc] init];
    for (id item in movies) {
        id object = [item movieObjectForCard:card];
        if ([[object queryHyperInterface:@protocol(HSUserObjectSupport)] card] == nil) {
            // The played object is not on the card yet: add it, hidden until played.
            [[card queryHyperInterface:@protocol(HSNodeContainer)] addHyperChild:object];
            [[object queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoplayed:NO];
            HSMoviePlaybackItem *newItem = [[HSMoviePlaybackItem alloc] initWithMovieObject:object playMovieAction:playMovie];
            [newItem setEnabled:YES];
            if (![object isHyperQTVR] && ![object isHyperPanoramaObject]) {
                [newItem setEraseWhenDone:YES];
            }
            [newMovies addObject:newItem];
            [newItem release];
        } else {
            [newMovies addObject:item];
        }
        if (isGroupObject && ![object isGroupObject]) {
            [groupedObjects addObject:object];
        }
    }
    [playMovie setMovies:newMovies];
    [newMovies release];
    NSArray *liveVideos = [playMovie liveVideos];
    NSMutableArray *newLiveVideos = [[NSMutableArray alloc] init];
    for (id item in liveVideos) {
        id object = [item liveObjectForCard:card];
        if ([[object queryHyperInterface:@protocol(HSUserObjectSupport)] card] == nil) {
            // The played object is not on the card yet: add it, hidden until played.
            [[card queryHyperInterface:@protocol(HSNodeContainer)] addHyperChild:object];
            [[object queryHyperInterface:@protocol(HSAutoplayAttributes)] setAutoplayed:NO];
            HSLiveVideoPlaybackItem *newItem = [[HSLiveVideoPlaybackItem alloc] initWithLiveObject:object playMovieAction:playMovie];
            [newItem setEnabled:YES];
            [newLiveVideos addObject:newItem];
            [newItem release];
        } else {
            [newLiveVideos addObject:item];
        }
        if (isGroupObject && ![object isGroupObject]) {
            [groupedObjects addObject:object];
        }
    }
    [playMovie setLiveVideos:newLiveVideos];
    [newLiveVideos release];
    if (groupedObjects != nil) {
        for (id object in groupedObjects) {
            [object makeGroupObject];
        }
        [groupedObjects release];
    }
}

- (void)prepareGroupObjectIfNeeded:(id)aNeeded
{
    id pvVar1;

    pvVar1 = [_dragHost cardForDragHost];
    if ([aNeeded isGroupObject]) {
        if ([pvVar1 cardGroupUID] != nil) {
            [aNeeded makeGroupObjectIgnoringGroupObjectFlag];
        }
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e7535 @ 001e7535, 2803 bytes * /

void FUN_001e7535(HSEditorCardViewDragHelper *self,SEL _cmd,id addAction,id intoObject,
                 BOOL useDragPreferences)

{
  int iVar1;
  id self_00;
  undefined1 *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  undefined4 *puVar8;
  id pvVar9;
  id pvVar10;
  SEL op;
  undefined *puVar11;
  undefined4 uVar12;
  undefined1 *puVar13;
  id local_1a8;
  char local_1a0;
  undefined4 local_194;
  int local_190;
  int *local_18c;
  undefined4 local_188;
  undefined4 local_184;
  undefined4 local_180;
  undefined4 local_17c;
  undefined4 local_178;
  undefined1 local_174 [64];
  undefined4 local_134;
  int local_130;
  int *local_12c;
  undefined4 local_128;
  undefined4 local_124;
  undefined4 local_120;
  undefined4 local_11c;
  undefined4 local_118;
  undefined1 local_114 [64];
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
  
  self_00 = _objc_msgSend(intoObject,sel_actor);
  pvVar9 = (id)(uint)(byte)useDragPreferences;
  puVar2 = _objc_msgSend(self,sel_actionEventForAction_addedIntoObject_useDragPreferences_,addAction
                         ,intoObject,pvVar9);
  pvVar3 = _objc_msgSend(addAction,sel_class);
  pvVar3 = _objc_msgSend(pvVar3,sel_actionType);
  puVar13 = puVar2;
  pvVar3 = _objc_msgSend(self_00,sel_hyperActionsOfType_forEvent_,pvVar3,puVar2);
  puVar8 = (undefined4 *)&DAT_0037fbb4;
  pvVar4 = _objc_msgSend(addAction,sel_queryHyperInterface_,&DAT_0037fbb4);
  if (pvVar4 == (id)0x0) goto LAB_001e77d1;
  if (useDragPreferences == '\0') {
LAB_001e765d:
    local_1a0 = '\x01';
  }
  else {
    pvVar9 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,puVar8,puVar13);
    puVar8 = *(undefined4 **)PTR_003367a0;
    pvVar9 = _objc_msgSend(pvVar9,sel_boolForKey_,puVar8);
    if ((char)pvVar9 == '\0') goto LAB_001e765d;
    local_1a0 = '\0';
  }
  local_194 = 0;
  local_190 = 0;
  local_18c = (int *)0x0;
  local_188 = 0;
  local_184 = 0;
  local_180 = 0;
  local_17c = 0;
  local_178 = 0;
  pvVar5 = _objc_msgSend(pvVar4,sel_sounds,puVar8,puVar13);
  puVar13 = local_174;
  puVar8 = &local_194;
  pvVar9 = (id)0x10;
  pvVar6 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,puVar8,puVar13,0x10);
  if (pvVar6 != (id)0x0) {
    iVar1 = *local_18c;
    do {
      pvVar10 = (id)0x0;
      do {
        if (iVar1 != *local_18c) {
          pvVar7 = _objc_msgSend(pvVar4,sel_sounds,puVar8,puVar13,pvVar9);
          _objc_enumerationMutation(pvVar7);
        }
        puVar8 = (undefined4 *)(int)local_1a0;
        _objc_msgSend(*(id *)(local_190 + (int)pvVar10 * 4),sel_setSynchronousSound_,puVar8,puVar13,
                      pvVar9);
        pvVar10 = (id)((int)pvVar10 + 1);
      } while (pvVar10 < pvVar6);
      puVar13 = local_174;
      puVar8 = &local_194;
      pvVar9 = (id)0x10;
      pvVar6 = _objc_msgSend(pvVar5,sel_countByEnumeratingWithState_objects_count_,puVar8,puVar13,
                             0x10);
    } while (pvVar6 != (id)0x0);
  }
LAB_001e77d1:
  pvVar5 = _objc_msgSend(pvVar3,sel_count,puVar8,puVar13,pvVar9);
  op = sel_addHyperAction_forEvent_;
  pvVar4 = addAction;
  if (pvVar5 != (id)0x0) {
    pvVar5 = self->_delegate;
    if (pvVar5 == (id)0x0) {
      puVar11 = &DAT_0037fd08;
      pvVar4 = _objc_msgSend(addAction,sel_queryHyperInterface_,&DAT_0037fd08,puVar13,pvVar9);
      if (pvVar4 != (id)0x0) {
        pvVar5 = _objc_msgSend(pvVar3,sel_extraFirstObject,puVar11,puVar13,pvVar9);
        pvVar5 = _objc_msgSend(pvVar5,sel_queryHyperInterface_,&DAT_0037fd08);
        pvVar6 = _objc_msgSend(cls_NSArray,sel_alloc);
        pvVar10 = _objc_msgSend(pvVar5,sel_movies);
        uVar12 = 1;
        pvVar6 = _objc_msgSend(pvVar6,sel_initWithArray_copyItems_,pvVar10,1);
        pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
        if (pvVar6 != (id)0x0) {
          pvVar10 = _objc_msgSend(pvVar4,sel_movies,pvVar10,uVar12);
          pvVar10 = _objc_msgSend(pvVar10,sel_arrayByAddingObjectsFromArray_,pvVar6);
          _objc_msgSend(pvVar4,sel_setMovies_,pvVar10);
        }
        pvVar6 = _objc_msgSend(cls_NSArray,sel_alloc,pvVar10,uVar12);
        pvVar5 = _objc_msgSend(pvVar5,sel_liveVideos);
        puVar13 = (undefined1 *)0x1;
        pvVar6 = _objc_msgSend(pvVar6,sel_initWithArray_copyItems_,pvVar5,1);
        pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
        if (pvVar6 != (id)0x0) {
          pvVar5 = _objc_msgSend(pvVar4,sel_liveVideos,pvVar5,puVar13);
          pvVar5 = _objc_msgSend(pvVar5,sel_arrayByAddingObjectsFromArray_,pvVar6);
          _objc_msgSend(pvVar4,sel_setLiveVideos_,pvVar5);
        }
      }
      puVar11 = &DAT_0037ffc4;
      pvVar4 = _objc_msgSend(addAction,sel_queryHyperInterface_,&DAT_0037ffc4,puVar13);
      if (pvVar4 != (id)0x0) {
        pvVar9 = _objc_msgSend(pvVar3,sel_extraFirstObject,puVar11,puVar13);
        pvVar5 = _objc_msgSend(pvVar9,sel_queryHyperInterface_,&DAT_0037ffc4);
        pvVar9 = _objc_msgSend(pvVar5,sel_objectsToShow);
        local_134 = 0;
        local_130 = 0;
        local_12c = (int *)0x0;
        local_128 = 0;
        local_124 = 0;
        local_120 = 0;
        local_11c = 0;
        local_118 = 0;
        puVar13 = local_114;
        puVar8 = &local_134;
        pvVar6 = (id)0x10;
        local_1a8 = _objc_msgSend(pvVar9,sel_countByEnumeratingWithState_objects_count_,puVar8,
                                  puVar13,0x10);
        if (local_1a8 != (id)0x0) {
          iVar1 = *local_12c;
          do {
            pvVar10 = (id)0x0;
            do {
              if (iVar1 != *local_12c) {
                _objc_enumerationMutation(pvVar9);
              }
              uVar12 = *(undefined4 *)(local_130 + (int)pvVar10 * 4);
              pvVar7 = _objc_msgSend(pvVar5,sel_hideEffectSettingsWithUID_,uVar12,puVar13,pvVar6);
              pvVar6 = _objc_msgSend(pvVar5,sel_showEffectSettingsWithUID_,uVar12);
              puVar13 = (undefined1 *)0x1;
              _objc_msgSend(pvVar4,sel_addObjectUID_action_showEffectSettings_hideEffectSettings_,
                            uVar12,1,pvVar6,pvVar7);
              pvVar10 = (id)((int)pvVar10 + 1);
            } while (pvVar10 < local_1a8);
            puVar13 = local_114;
            puVar8 = &local_134;
            pvVar6 = (id)0x10;
            local_1a8 = _objc_msgSend(pvVar9,sel_countByEnumeratingWithState_objects_count_,puVar8,
                                      puVar13,0x10,pvVar7);
          } while (local_1a8 != (id)0x0);
        }
        pvVar9 = _objc_msgSend(pvVar5,sel_objectsToHide,puVar8,puVar13,pvVar6);
        local_d4 = 0;
        local_d0 = 0;
        local_cc = (int *)0x0;
        local_c8 = 0;
        local_c4 = 0;
        local_c0 = 0;
        local_bc = 0;
        local_b8 = 0;
        puVar13 = local_b4;
        puVar8 = &local_d4;
        pvVar6 = (id)0x10;
        local_1a8 = _objc_msgSend(pvVar9,sel_countByEnumeratingWithState_objects_count_,puVar8,
                                  puVar13,0x10);
        if (local_1a8 != (id)0x0) {
          iVar1 = *local_cc;
          do {
            pvVar10 = (id)0x0;
            do {
              if (iVar1 != *local_cc) {
                _objc_enumerationMutation(pvVar9);
              }
              uVar12 = *(undefined4 *)(local_d0 + (int)pvVar10 * 4);
              pvVar7 = _objc_msgSend(pvVar5,sel_hideEffectSettingsWithUID_,uVar12,puVar13,pvVar6);
              pvVar6 = _objc_msgSend(pvVar5,sel_showEffectSettingsWithUID_,uVar12);
              puVar13 = (undefined1 *)0x2;
              _objc_msgSend(pvVar4,sel_addObjectUID_action_showEffectSettings_hideEffectSettings_,
                            uVar12,2,pvVar6,pvVar7);
              pvVar10 = (id)((int)pvVar10 + 1);
            } while (pvVar10 < local_1a8);
            puVar13 = local_b4;
            puVar8 = &local_d4;
            pvVar6 = (id)0x10;
            local_1a8 = _objc_msgSend(pvVar9,sel_countByEnumeratingWithState_objects_count_,puVar8,
                                      puVar13,0x10,pvVar7);
          } while (local_1a8 != (id)0x0);
        }
        pvVar6 = _objc_msgSend(pvVar5,sel_objectsToToggle,puVar8,puVar13,pvVar6);
        local_74 = 0;
        local_70 = 0;
        local_6c = (int *)0x0;
        local_68 = 0;
        local_64 = 0;
        local_60 = 0;
        local_5c = 0;
        local_58 = 0;
        puVar13 = local_50;
        pvVar9 = (id)0x10;
        local_1a8 = _objc_msgSend(pvVar6,sel_countByEnumeratingWithState_objects_count_,&local_74,
                                  puVar13,0x10);
        if (local_1a8 != (id)0x0) {
          iVar1 = *local_6c;
          do {
            pvVar10 = (id)0x0;
            do {
              if (iVar1 != *local_6c) {
                _objc_enumerationMutation(pvVar6);
              }
              uVar12 = *(undefined4 *)(local_70 + (int)pvVar10 * 4);
              pvVar7 = _objc_msgSend(pvVar5,sel_hideEffectSettingsWithUID_,uVar12,puVar13,pvVar9);
              pvVar9 = _objc_msgSend(pvVar5,sel_showEffectSettingsWithUID_,uVar12);
              puVar13 = (undefined1 *)0x3;
              _objc_msgSend(pvVar4,sel_addObjectUID_action_showEffectSettings_hideEffectSettings_,
                            uVar12,3,pvVar9,pvVar7);
              pvVar10 = (id)((int)pvVar10 + 1);
            } while (pvVar10 < local_1a8);
            puVar13 = local_50;
            pvVar9 = (id)0x10;
            local_1a8 = _objc_msgSend(pvVar6,sel_countByEnumeratingWithState_objects_count_,
                                      &local_74,puVar13,0x10,pvVar7);
          } while (local_1a8 != (id)0x0);
        }
      }
      pvVar9 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,puVar2,puVar13,pvVar9);
      pvVar4 = _objc_msgSend(pvVar3,sel_extraFirstObject);
      op = sel_replaceHyperAction_withAction_forEvents_;
      puVar2 = addAction;
    }
    else {
      pvVar4 = _objc_msgSend(addAction,sel_queryHyperInterface_,&DAT_0037fbc8,puVar13,pvVar9);
      self_00 = pvVar5;
      op = sel_addHyperAction_;
      puVar2 = puVar13;
    }
  }
  _objc_msgSend(self_00,op,pvVar4,puVar2,pvVar9);
  return;
}

*/
- (void)addAction:(id)aAction intoObject:(id)aObject useDragPreferences:(BOOL)aPreferences
{
    id actor = [aObject actor];
    id event = [self actionEventForAction:aAction addedIntoObject:aObject useDragPreferences:aPreferences];
    NSArray *existingActions = [actor hyperActionsOfType:[[aAction class] actionType] forEvent:event];
    id playSound = [aAction queryHyperInterface:@protocol(HSPlaySoundActionAttributes)];
    if (playSound != nil) {
        // Background sounds play asynchronously.
        BOOL synchronous = !(aPreferences && [[NSUserDefaults standardUserDefaults] boolForKey:HSImportSoundAsBackgroundKey]);
        for (id sound in [playSound sounds]) {
            [sound setSynchronousSound:synchronous];
        }
    }
    if ([existingActions count] == 0) {
        [actor addHyperAction:aAction forEvent:event];
        return;
    }
    if (_delegate != nil) {
        [_delegate addHyperAction:[aAction queryHyperInterface:@protocol(HSActionAttributes)]];
        return;
    }
    // Merge the existing action of this type into the new one, then replace it.
    id existingAction = [existingActions extraFirstObject];
    id playMovie = [aAction queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
    if (playMovie != nil) {
        id existingPlayMovie = [existingAction queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
        NSArray *movies = [[[NSArray alloc] initWithArray:[existingPlayMovie movies] copyItems:YES] autorelease];
        if (movies != nil) {
            [playMovie setMovies:[[playMovie movies] arrayByAddingObjectsFromArray:movies]];
        }
        NSArray *liveVideos = [[[NSArray alloc] initWithArray:[existingPlayMovie liveVideos] copyItems:YES] autorelease];
        if (liveVideos != nil) {
            [playMovie setLiveVideos:[[playMovie liveVideos] arrayByAddingObjectsFromArray:liveVideos]];
        }
    }
    id showHide = [aAction queryHyperInterface:@protocol(HSShowHideObjectActionAttributes)];
    if (showHide != nil) {
        id existingShowHide = [existingAction queryHyperInterface:@protocol(HSShowHideObjectActionAttributes)];
        for (id uid in [existingShowHide objectsToShow]) {
            [showHide addObjectUID:uid action:1 showEffectSettings:[existingShowHide showEffectSettingsWithUID:uid] hideEffectSettings:[existingShowHide hideEffectSettingsWithUID:uid]];
        }
        for (id uid in [existingShowHide objectsToHide]) {
            [showHide addObjectUID:uid action:2 showEffectSettings:[existingShowHide showEffectSettingsWithUID:uid] hideEffectSettings:[existingShowHide hideEffectSettingsWithUID:uid]];
        }
        for (id uid in [existingShowHide objectsToToggle]) {
            [showHide addObjectUID:uid action:3 showEffectSettings:[existingShowHide showEffectSettingsWithUID:uid] hideEffectSettings:[existingShowHide hideEffectSettingsWithUID:uid]];
        }
    }
    [actor replaceHyperAction:existingAction withAction:aAction forEvents:[NSArray arrayWithObject:event]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e59ab @ 001e59ab, 142 bytes * /

BOOL FUN_001e59ab(HSEditorCardViewDragHelper *self,SEL _cmd,id changeMedia,id forObject)

{
  id self_00;
  id pvVar1;
  undefined *puVar2;
  
  if (forObject != (id)0x0) {
    puVar2 = &DAT_0037fccc;
    self_00 = _objc_msgSend(forObject,sel_queryHyperInterface_,&DAT_0037fccc);
    if (self_00 != (id)0x0) {
      pvVar1 = _objc_msgSend(changeMedia,sel_mediaType,puVar2);
      pvVar1 = _objc_msgSend(self_00,sel_isMediaTypeSupported_,pvVar1);
      if ((char)pvVar1 != '\0') {
        _objc_msgSend(self_00,sel_setMedia_,changeMedia);
        return '\x01';
      }
    }
  }
  return '\0';
}

*/
- (BOOL)changeMedia:(id)aMedia forObject:(id)aObject
{
    if (aObject == nil) {
        return NO;
    }
    id mediaAttributes = [aObject queryHyperInterface:@protocol(HSMediaAttributes)];
    if (mediaAttributes == nil || ![mediaAttributes isMediaTypeSupported:[(HSMediaRepresentation *)aMedia mediaType]]) {
        return NO;
    }
    [mediaAttributes setMedia:aMedia];
    return YES;
}

- (BOOL)addObjectsInArray:(id)aArray center:(BOOL)aCenter needOpenHelpPane:(BOOL)aPane useDragPreferences:(BOOL)aPreferences
{
    return (BOOL)[self addObjectsInArray:aArray intoObject:[_dragHost cardForDragHost] center:aCenter fitCanvas:YES needOpenHelpPane:aPane isPasting:NO useDragPreferences:aPreferences pastingNotHSObject:NO];
}

- (BOOL)addObjectsInArray:(id)aArray center:(BOOL)aCenter useDragPreferences:(BOOL)aPreferences
{
    return (BOOL)[self addObjectsInArray:aArray center:aCenter fitCanvas:YES isPasting:NO useDragPreferences:aPreferences pastingNotHSObject:NO];
}

- (BOOL)addObjectsInArray:(id)aArray center:(BOOL)aCenter fitCanvas:(BOOL)aCanvas isPasting:(BOOL)aPasting useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL)aObject
{
    id pvVar1;

    pvVar1 = [_dragHost cardForDragHost];
    [[[self editorDocument] editorWindowController] setActiveCard:pvVar1];
    [[[self editorDocument] editorWindowController] selectActiveCard];
    [[HSObjectAssistantController sharedAssistantController] setShouldOpenCardInfo:YES];
    return (BOOL)[self addObjectsInArray:aArray intoObject:pvVar1 center:aCenter fitCanvas:aCanvas isPasting:aPasting useDragPreferences:aPreferences pastingNotHSObject:aObject];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e5645 @ 001e5645, 374 bytes * /

void FUN_001e5645(HSEditorCardViewDragHelper *self,SEL _cmd,id addObjectToCenterOfCard)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  float extraout_EDX;
  
  self_00 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  pvVar1 = _objc_msgSend(self_00,sel_stack);
  pvVar1 = _objc_msgSend(pvVar1,sel_hyperCardSize);
  pvVar2 = _objc_msgSend(self_00,sel_undoManager);
  _objc_msgSend(pvVar2,sel_disableUndoRegistration);
  pvVar2 = _objc_msgSend(self_00,sel_support);
  _objc_msgSend(addObjectToCenterOfCard,sel_setSupport_,pvVar2);
  pvVar2 = _objc_msgSend(addObjectToCenterOfCard,sel_queryHyperInterface_,&DAT_0037fcb8);
  pvVar2 = _objc_msgSend(pvVar2,sel_queryGeometryBehaviorApplier);
  _objc_msgSend(pvVar2,sel_moveCenterTo_withLayoutGuidingContext_,(float)pvVar1 * 0.5,
                extraout_EDX * 0.5,0);
  _objc_msgSend(addObjectToCenterOfCard,sel_setSupport_,0);
  pvVar1 = _objc_msgSend(self_00,sel_undoManager);
  _objc_msgSend(pvVar1,sel_enableUndoRegistration);
  _objc_msgSend(self_00,sel_addHyperChild_,addObjectToCenterOfCard);
  return;
}

*/
- (void)addObjectToCenterOfCard:(id)aCard
{
    id card = [_dragHost cardForDragHost];
    NSSize cardSize = [[card stack] hyperCardSize];
    [[card undoManager] disableUndoRegistration];
    [aCard setSupport:[card support]];
    [[[aCard queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] moveCenterTo:NSMakePoint(cardSize.width * 0.5, cardSize.height * 0.5) withLayoutGuidingContext:nil];
    [aCard setSupport:nil];
    [[card undoManager] enableUndoRegistration];
    [card addHyperChild:aCard];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ea253 @ 001ea253, 631 bytes * /

void FUN_001ea253(HSEditorCardViewDragHelper *self,SEL _cmd,id addObjectToCenter)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  undefined4 extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  longdouble lVar4;
  longdouble lVar5;
  
  pvVar1 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
  _objc_msgSend(pvVar1,sel_disableUndoRegistration);
  pvVar1 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  pvVar1 = _objc_msgSend(pvVar1,sel_support);
  _objc_msgSend(addObjectToCenter,sel_setSupport_,pvVar1);
  pvVar1 = _objc_msgSend(addObjectToCenter,sel_queryHyperInterface_,&DAT_0037fcb8);
  pvVar1 = _objc_msgSend(pvVar1,sel_queryGeometryBehaviorApplier);
  pvVar2 = _objc_msgSend(self->_dragHost,sel_dragHostCardCenterPoint);
  pvVar2 = _objc_msgSend(self->_dragHost,sel_convertPointFromDragHostToCard_,pvVar2,extraout_EDX);
  pvVar3 = _objc_msgSend(addObjectToCenter,sel_queryHyperInterface_,&DAT_0038035c);
  pvVar3 = _objc_msgSend(pvVar3,sel_size);
  lVar4 = (longdouble)_floorf(extraout_EDX_00 - extraout_EDX_01 * 0.5);
  lVar5 = (longdouble)_floorf((float)pvVar2 - (float)pvVar3 * 0.5);
  _objc_msgSend(pvVar1,sel_moveCenterTo_withLayoutGuidingContext_,(float)pvVar3 * 0.5 + (float)lVar5
                ,extraout_EDX_01 * 0.5 + (float)lVar4,0);
  (self->_offsetOfAddedObject).x = (self->_offsetOfAddedObject).x + 0.0;
  (self->_offsetOfAddedObject).y = (self->_offsetOfAddedObject).y + 0.0;
  _objc_msgSend(addObjectToCenter,sel_setSupport_,0);
  pvVar1 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  pvVar1 = _objc_msgSend(pvVar1,sel_undoManager);
  _objc_msgSend(pvVar1,sel_enableUndoRegistration);
  pvVar1 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  _objc_msgSend(pvVar1,sel_addHyperChild_,addObjectToCenter);
  return;
}

*/
- (void)addObjectToCenter:(id)aCenter
{
    [[[_dragHost cardForDragHost] undoManager] disableUndoRegistration];
    [aCenter setSupport:[[_dragHost cardForDragHost] support]];
    id applier = [[aCenter queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
    NSPoint center = [_dragHost convertPointFromDragHostToCard:[_dragHost dragHostCardCenterPoint]];
    NSSize size = [(id<HSGeometryAttributes>)[aCenter queryHyperInterface:@protocol(HSGeometryAttributes)] size];
    // Centre on the visible area, keeping the origin on whole points.
    float x = floorf(center.x - size.width * 0.5f) + size.width * 0.5f;
    float y = floorf(center.y - size.height * 0.5f) + size.height * 0.5f;
    [applier moveCenterTo:NSMakePoint(x, y) withLayoutGuidingContext:nil];
    // The original also adds a zero offset to _offsetOfAddedObject here.
    [aCenter setSupport:nil];
    [[[_dragHost cardForDragHost] undoManager] enableUndoRegistration];
    [[_dragHost cardForDragHost] addHyperChild:aCenter];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e556d @ 001e556d, 216 bytes * /

id FUN_001e556d(HSEditorCardViewDragHelper *self,SEL _cmd,id actionEventForAction,id addedIntoObject
               ,BOOL useDragPreferences)

{
  id pvVar1;
  undefined *puVar2;
  undefined4 uVar3;
  
  pvVar1 = _objc_msgSend(actionEventForAction,sel_queryHyperInterface_,&DAT_0037fbb4);
  if (pvVar1 != (id)0x0) {
    puVar2 = &DAT_0037fc68;
    pvVar1 = _objc_msgSend(addedIntoObject,sel_queryHyperInterface_,&DAT_0037fc68);
    if (pvVar1 != (id)0x0) {
      if (useDragPreferences != '\0') {
        pvVar1 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,puVar2);
        pvVar1 = _objc_msgSend(pvVar1,sel_boolForKey_,*(undefined4 *)PTR_0033603c);
        if ((char)pvVar1 != '\0') goto LAB_001e561b;
      }
      uVar3 = *(undefined4 *)PTR_00336080;
      goto LAB_001e5633;
    }
  }
LAB_001e561b:
  uVar3 = *(undefined4 *)PTR_00336084;
LAB_001e5633:
  pvVar1 = _objc_msgSend(cls_HSActionEvent,sel_actionEventOfType_,uVar3);
  return pvVar1;
}

*/
- (id)actionEventForAction:(id)aAction addedIntoObject:(id)aObject useDragPreferences:(BOOL)aPreferences
{
    id eventType = kHSClickActionEventType;
    // Sounds dropped on a card play on arrival unless set to play on click.
    if ([aAction queryHyperInterface:@protocol(HSPlaySoundActionAttributes)] != nil
        && [aObject queryHyperInterface:@protocol(HSCardAttributes)] != nil
        && !(aPreferences && [[NSUserDefaults standardUserDefaults] boolForKey:HSImportSoundToPlayOnClickKey])) {
        eventType = kHSArriveActionEventType;
    }
    return [HSActionEvent actionEventOfType:eventType];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ea4ca @ 001ea4ca, 11374 bytes * /

BOOL FUN_001ea4ca(HSEditorCardViewDragHelper *self,SEL _cmd,id readFromPasteboard,id acceptingObject
                 ,id *createdObjects,BOOL *runAnimationMode,uint dragOperation,
                 BOOL useDragPreferences,BOOL *pastingNotHSObject)

{
  int iVar1;
  int iVar2;
  undefined4 uVar3;
  byte bVar4;
  undefined *puVar5;
  char cVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  id pvVar10;
  id pvVar11;
  id pvVar12;
  id pvVar13;
  BOOL *pBVar14;
  id pvVar15;
  undefined *puVar16;
  float extraout_EDX;
  float extraout_EDX_00;
  bool bVar17;
  int *piVar18;
  int *piVar19;
  uint uVar20;
  longdouble lVar21;
  longdouble lVar22;
  int iStack_1c4;
  float local_1c0;
  SEL op;
  int aiStack_1b0 [6];
  id local_198;
  bool local_189;
  id local_184;
  id local_180;
  id local_17c;
  id local_178;
  id local_170;
  id local_168;
  id local_164;
  undefined6 uStack_160;
  id local_154;
  id local_150;
  undefined1 local_14c [8];
  float local_144;
  float local_140;
  int local_138;
  undefined4 local_134;
  int local_130;
  int *local_12c;
  undefined4 local_128;
  undefined4 local_124;
  undefined4 local_120;
  undefined4 local_11c;
  undefined4 local_118;
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
  
  piVar19 = (int *)&stack0xfffffe44;
  piVar18 = (int *)&stack0xfffffe44;
  pvVar7 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  pvVar7 = _objc_msgSend(pvVar7,sel_document);
  pvVar7 = _objc_msgSend(pvVar7,sel_isInAnimationMode);
  if (((char)pvVar7 != '\0') ||
     (pvVar7 = _objc_msgSend(self,sel_isLockedObject_), (char)pvVar7 != '\0')) {
    return '\0';
  }
  local_198 = acceptingObject;
  local_168 = _objc_msgSend(cls_NSMutableArray,sel_array);
  local_138 = 0;
  _objc_msgSend(cls_HSMediaLoader,sel_forceLoadMediasFromPasteboard_);
  pvVar7 = _objc_msgSend(readFromPasteboard,sel_types);
  pvVar7 = _objc_msgSend(pvVar7,sel_containsObject_);
  if ((char)pvVar7 == '\0') {
    pvVar7 = _objc_msgSend(readFromPasteboard,sel_types);
    pvVar7 = _objc_msgSend(pvVar7,sel_containsObject_);
    if ((char)pvVar7 != '\0') {
LAB_001ea924:
      pvVar7 = _objc_msgSend(readFromPasteboard,sel_types);
      _objc_msgSend(pvVar7,sel_containsObject_);
      pvVar7 = _objc_msgSend(readFromPasteboard,sel_propertyListForType_);
      pvVar8 = _objc_msgSend(cls_NSMutableSet,sel_new);
      pvVar12 = _objc_msgSend(pvVar7,sel_count);
      if (pvVar12 == (id)0x0) {
        local_189 = false;
        piVar19 = (int *)&stack0xfffffe44;
      }
      else {
        pvVar12 = _objc_msgSend(self,sel_editorDocument);
        pvVar12 = _objc_msgSend(pvVar12,sel_stack);
        pvVar15 = _objc_msgSend(pvVar12,sel_queryHyperInterface_);
        pvVar12 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
        pvVar12 = _objc_msgSend(pvVar12,sel_stack);
        pvVar12 = _objc_msgSend(pvVar12,sel_queryHyperInterface_);
        pvVar13 = _objc_msgSend(pvVar12,sel_hyperEnumerator);
        pvVar12 = _objc_msgSend(pvVar13,sel_nextObject);
        while (pvVar12 != (id)0x0) {
          _objc_msgSend(pvVar12,sel_hyperUID);
          _objc_msgSend(pvVar8,sel_addObject_);
          pvVar12 = _objc_msgSend(pvVar12,sel_hyperEnumerator);
          while (pvVar9 = _objc_msgSend(pvVar12,sel_nextObject), pvVar9 != (id)0x0) {
            _objc_msgSend(pvVar9,sel_hyperUID);
            _objc_msgSend(pvVar8,sel_addObject_);
          }
          pvVar12 = _objc_msgSend(pvVar13,sel_nextObject);
        }
        local_189 = false;
        pvVar7 = _objc_msgSend(pvVar7,sel_objectEnumerator);
        while (pvVar12 = _objc_msgSend(pvVar7,sel_nextObject), pvVar12 != (id)0x0) {
          pvVar12 = _objc_msgSend(cls_HSNode,sel_nodeWithDictionary_);
          if (pvVar12 != (id)0x0) {
            pvVar13 = _objc_msgSend(pvVar12,sel_queryHyperInterface_);
            _objc_msgSend(pvVar13,sel_mediaUIDs);
            _objc_msgSend(pvVar8,sel_unionSet_);
            pvVar13 = _objc_msgSend(pvVar12,sel_queryHyperInterface_);
            if (pvVar13 != (id)0x0) {
              _objc_msgSend(pvVar13,sel_unrefreshingUIDs);
              _objc_msgSend(pvVar8,sel_unionSet_);
            }
            pvVar12 = _objc_msgSend(pvVar12,sel_queryHyperInterface_);
            _objc_msgSend(pvVar12,sel_hyperUID);
            pvVar12 = _objc_msgSend(pvVar15,sel_childInTreeWithUID_);
            op = sel_addObject_;
            if (pvVar12 != (id)0x0) {
              op = sel_removeObject_;
            }
            _objc_msgSend(pvVar8,op);
            _objc_msgSend(local_168,sel_addObject_);
            local_189 = true;
          }
        }
        pvVar7 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
        pvVar7 = _objc_msgSend(pvVar7,sel_init);
        pvVar12 = _objc_msgSend(local_168,sel_count);
        if (pvVar12 != (id)0x0) {
          pvVar15 = (id)0x1;
          if ((id)0x1 < pvVar12) {
            pvVar15 = pvVar12;
          }
          local_170 = (id)0x0;
          do {
            pvVar13 = _objc_msgSend(local_168,sel_objectAtIndex_);
            pvVar13 = _objc_msgSend(pvVar13,sel_queryHyperInterface_);
            local_134 = 0;
            local_130 = 0;
            local_12c = (int *)0x0;
            local_128 = 0;
            local_124 = 0;
            local_120 = 0;
            local_11c = 0;
            local_118 = 0;
            pvVar9 = _objc_msgSend(pvVar13,sel_hyperActions);
            local_17c = _objc_msgSend(pvVar9,sel_countByEnumeratingWithState_objects_count_);
            if (local_17c != (id)0x0) {
              iVar1 = *local_12c;
              do {
                local_178 = (id)0x0;
                do {
                  if (iVar1 != *local_12c) {
                    _objc_msgSend(pvVar13,sel_hyperActions);
                    _objc_enumerationMutation();
                  }
                  pvVar11 = *(id *)(local_130 + (int)local_178 * 4);
                  _objc_msgSend(cls_HSArduinoWatcherAction,sel_actionType);
                  pvVar10 = _objc_msgSend(pvVar11,sel_isKindOfType_);
                  if (((char)pvVar10 != '\0') &&
                     (pvVar11 = _objc_msgSend(pvVar11,sel_digitalPinConfigurationRangeMappings),
                     pvVar11 != (id)0x0)) {
                    _local_164 = CONCAT64(uStack_160,pvVar11);
                    pvVar11 = (id)0x0;
                    do {
                      pvVar10 = _objc_msgSend(local_168,sel_objectAtIndex_);
                      pvVar10 = _objc_msgSend(pvVar10,sel_hyperUID);
                      pvVar10 = _objc_msgSend(pvVar10,sel_stringValue);
                      if ((pvVar10 != (id)0x0) &&
                         (cVar6 = _CFDictionaryContainsKey(), puVar16 = cls_NSArray, cVar6 != '\0'))
                      {
                        _objc_msgSend(cls_NSNumber,sel_numberWithInteger_);
                        _objc_msgSend(cls_NSNumber,sel_numberWithInteger_);
                        _objc_msgSend(puVar16,sel_arrayWithObjects_);
                        _objc_msgSend(pvVar7,sel_addObject_);
                      }
                      pvVar11 = (id)((int)pvVar11 + 1);
                    } while (pvVar15 != pvVar11);
                  }
                  local_178 = (id)((int)local_178 + 1);
                } while (local_178 < local_17c);
                local_17c = _objc_msgSend(pvVar9,sel_countByEnumeratingWithState_objects_count_);
              } while (local_17c != (id)0x0);
            }
            local_170 = (id)((int)local_170 + 1);
          } while (local_170 < pvVar12);
        }
        pvVar12 = _objc_msgSend(local_168,sel_objectEnumerator);
        pvVar15 = _objc_msgSend(cls_NSMutableArray,sel_alloc);
        _objc_msgSend(local_168,sel_count);
        pvVar15 = _objc_msgSend(pvVar15,sel_initWithCapacity_);
        while (pvVar13 = _objc_msgSend(pvVar12,sel_nextObject), pvVar13 != (id)0x0) {
          _objc_msgSend(pvVar13,sel_extraDictionaryRepresentation);
          _objc_msgSend(pvVar15,sel_addObject_);
        }
        _objc_msgSend(local_168,sel_removeAllObjects);
        _objc_msgSend(pvVar15,sel_refreshHyperUIDsAndIgnoreUIDsFromSet_);
        pvVar12 = _objc_msgSend(pvVar15,sel_objectEnumerator);
        while (pvVar13 = _objc_msgSend(pvVar12,sel_nextObject), pvVar13 != (id)0x0) {
          _objc_msgSend(cls_HSNode,sel_nodeWithDictionary_);
          _objc_msgSend(local_168,sel_addObject_);
        }
        _objc_msgSend(pvVar15,sel_release);
        local_d4 = 0;
        local_d0 = 0;
        local_cc = (int *)0x0;
        local_c8 = 0;
        local_c4 = 0;
        local_c0 = 0;
        local_bc = 0;
        local_b8 = 0;
        local_184 = _objc_msgSend(pvVar7,sel_countByEnumeratingWithState_objects_count_);
        if (local_184 != (id)0x0) {
          iVar1 = *local_cc;
          do {
            local_180 = (id)0x0;
            do {
              if (iVar1 != *local_cc) {
                _objc_enumerationMutation();
              }
              pvVar12 = *(id *)(local_d0 + (int)local_180 * 4);
              pvVar15 = _objc_msgSend(pvVar12,sel_objectAtIndex_);
              _objc_msgSend(pvVar15,sel_integerValue);
              pvVar15 = _objc_msgSend(pvVar12,sel_objectAtIndex_);
              _objc_msgSend(pvVar15,sel_integerValue);
              _objc_msgSend(pvVar12,sel_lastObject);
              pvVar12 = _objc_msgSend(local_168,sel_objectAtIndex_);
              pvVar12 = _objc_msgSend(pvVar12,sel_hyperUID);
              _objc_msgSend(pvVar12,sel_stringValue);
              pvVar12 = _objc_msgSend(local_168,sel_objectAtIndex_);
              pvVar12 = _objc_msgSend(pvVar12,sel_queryHyperInterface_);
              local_74 = 0;
              local_70 = 0;
              local_6c = (int *)0x0;
              local_68 = 0;
              local_64 = 0;
              local_60 = 0;
              local_5c = 0;
              local_58 = 0;
              pvVar15 = _objc_msgSend(pvVar12,sel_hyperActions);
              pvVar13 = _objc_msgSend(pvVar15,sel_countByEnumeratingWithState_objects_count_);
              if (pvVar13 != (id)0x0) {
                iVar2 = *local_6c;
                _local_164 = CONCAT64(uStack_160,pvVar13);
                do {
                  uVar20 = 0;
                  do {
                    if (iVar2 != *local_6c) {
                      _objc_msgSend(pvVar12,sel_hyperActions);
                      _objc_enumerationMutation();
                    }
                    pvVar13 = *(id *)(local_70 + uVar20 * 4);
                    _objc_msgSend(cls_HSArduinoWatcherAction,sel_actionType);
                    pvVar9 = _objc_msgSend(pvVar13,sel_isKindOfType_);
                    if ((char)pvVar9 != '\0') {
                      pvVar9 = _objc_msgSend(pvVar13,
                                             sel_digitalPinConfigurationRangesForObjectWithUID_);
                      _objc_msgSend(pvVar13,sel_analogPinConfigurationRangesForObjectWithUID_);
                      if (pvVar9 != (id)0x0) {
                        _objc_msgSend(pvVar13,
                                      sel_setDigitalPinConfigurationRanges_analogPinConfigurationRanges_forObjectWithUID_
                                     );
                        _objc_msgSend(pvVar13,sel_removePinConfigurationRangesForObjectWithUID_);
                      }
                    }
                    uVar20 = uVar20 + 1;
                  } while (uVar20 < local_164);
                  pvVar13 = _objc_msgSend(pvVar15,sel_countByEnumeratingWithState_objects_count_);
                  _local_164 = CONCAT64(uStack_160,pvVar13);
                } while (pvVar13 != (id)0x0);
              }
              local_180 = (id)((int)local_180 + 1);
            } while (local_180 < local_184);
            local_184 = _objc_msgSend(pvVar7,sel_countByEnumeratingWithState_objects_count_);
          } while (local_184 != (id)0x0);
        }
        _objc_msgSend(pvVar7,sel_release);
        piVar19 = (int *)&stack0xfffffe44;
        if (acceptingObject != (id)0x0) {
          _objc_msgSend(cls_HSConcreteCardObject,sel_class);
          pvVar7 = _objc_msgSend(acceptingObject,sel_isKindOfClass_);
          piVar19 = (int *)&stack0xfffffe44;
          if ((char)pvVar7 != '\0') {
            pvVar7 = _objc_msgSend(local_168,sel_copy);
            pvVar7 = _objc_msgSend(pvVar7,sel_autorelease);
            pvVar7 = _objc_msgSend(pvVar7,sel_objectEnumerator);
            pvVar12 = _objc_msgSend(pvVar7,sel_nextObject);
            if (pvVar12 == (id)0x0) {
              local_150 = (id)0x0;
            }
            else {
              local_150 = (id)0x0;
              piVar18 = (int *)&stack0xfffffe44;
              do {
                if (local_150 == (id)0x0) {
                  piVar18[1] = (int)sel_new;
                  *piVar18 = (int)cls_HSPlayMovieAction;
                  piVar18[-1] = 0x1eb6e1;
                  local_150 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                }
                piVar18[2] = (int)&DAT_00380668;
                piVar18[1] = (int)sel_implementsHyperInterface_;
                *piVar18 = (int)pvVar12;
                piVar18[-1] = 0x1eb709;
                pvVar15 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                if ((char)pvVar15 == '\0') {
                  piVar18[2] = (int)&DAT_00380014;
                  piVar18[1] = (int)sel_implementsHyperInterface_;
                  *piVar18 = (int)pvVar12;
                  piVar18[-1] = 0x1eb7a9;
                  pvVar15 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                  if ((char)pvVar15 != '\0') {
                    piVar18[2] = (int)&DAT_00380014;
                    piVar18[1] = (int)sel_queryHyperInterface_;
                    *piVar18 = (int)pvVar12;
                    piVar18[-1] = 0x1eb7d3;
                    pvVar15 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                    piVar18[1] = (int)sel_alloc;
                    *piVar18 = (int)cls_HSMoviePlaybackItem;
                    piVar18[-1] = 0x1eb7ed;
                    pvVar13 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                    piVar18[3] = (int)local_150;
                    piVar18[2] = (int)pvVar15;
                    piVar18[1] = (int)sel_initWithMovieObject_playMovieAction_;
                    *piVar18 = (int)pvVar13;
                    piVar18[-1] = 0x1eb80d;
                    pvVar13 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                    piVar18[2] = (int)pvVar13;
                    piVar18[1] = (int)sel_addMovie_;
                    *piVar18 = (int)local_150;
                    goto LAB_001eb826;
                  }
                }
                else {
                  piVar18[2] = (int)&DAT_00380668;
                  piVar18[1] = (int)sel_queryHyperInterface_;
                  *piVar18 = (int)pvVar12;
                  piVar18[-1] = 0x1eb72f;
                  pvVar15 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                  piVar18[1] = (int)sel_alloc;
                  *piVar18 = (int)cls_HSLiveVideoPlaybackItem;
                  piVar18[-1] = 0x1eb749;
                  pvVar13 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                  piVar18[3] = (int)local_150;
                  piVar18[2] = (int)pvVar15;
                  piVar18[1] = (int)sel_initWithLiveObject_playMovieAction_;
                  *piVar18 = (int)pvVar13;
                  piVar18[-1] = 0x1eb769;
                  pvVar13 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                  piVar18[2] = (int)pvVar13;
                  piVar18[1] = (int)sel_addLiveVideo_;
                  *piVar18 = (int)local_150;
LAB_001eb826:
                  piVar18[-1] = 0x1eb82b;
                  _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                  piVar18[1] = (int)sel_setPlayOverObjects_;
                  *piVar18 = (int)pvVar13;
                  piVar18[2] = 1;
                  piVar18[-1] = 0x1eb845;
                  _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                  piVar18[1] = (int)sel_setEnabled_;
                  *piVar18 = (int)pvVar13;
                  piVar18[2] = 1;
                  piVar18[-1] = 0x1eb85f;
                  _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                  piVar18[1] = (int)sel_release;
                  *piVar18 = (int)pvVar13;
                  piVar18[-1] = 0x1eb871;
                  _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                  piVar18[2] = (int)&DAT_0038035c;
                  piVar18[1] = (int)sel_queryHyperInterface_;
                  *piVar18 = (int)pvVar15;
                  piVar18[-1] = 0x1eb88d;
                  pvVar13 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
                  piVar18[2] = (int)sel_frameBoundingRect;
                  piVar18[1] = (int)pvVar13;
                  *piVar18 = (int)local_14c;
                  piVar18[-1] = 0x1eb8a9;
                  _objc_msgSend_stret((void *)*piVar18,(id)piVar18[1],(SEL)piVar18[2]);
                  piVar18[1] = (int)&DAT_0037fcb8;
                  *piVar18 = (int)sel_queryHyperInterface_;
                  piVar18[-1] = (int)pvVar15;
                  piVar18[-2] = 0x1eb8c8;
                  pvVar15 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
                  *piVar18 = (int)sel_queryGeometryBehaviorApplier;
                  piVar18[-1] = (int)pvVar15;
                  piVar18[-2] = 0x1eb8da;
                  pvVar15 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
                  if (pvVar15 != (id)0x0) {
                    *piVar18 = (int)sel_editorDocument;
                    piVar18[-1] = (int)self;
                    piVar18[-2] = 0x1eb8f9;
                    pvVar13 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
                    *piVar18 = (int)sel_stack;
                    piVar18[-1] = (int)pvVar13;
                    piVar18[-2] = 0x1eb90b;
                    pvVar13 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
                    *piVar18 = (int)sel_hyperCardSize;
                    piVar18[-1] = (int)pvVar13;
                    piVar18[-2] = 0x1eb91d;
                    pvVar13 = _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
                    piVar18[-1] = (int)((extraout_EDX - local_140) * 0.5);
                    piVar18[-2] = 0x1eb947;
                    lVar21 = (longdouble)_ceilf();
                    piVar18[-1] = (int)(((float)pvVar13 - local_144) * 0.5);
                    piVar18[-2] = 0x1eb96f;
                    lVar22 = (longdouble)_ceilf();
                    piVar18[2] = (int)(float)lVar21;
                    piVar18[1] = (int)(float)lVar22;
                    *piVar18 = (int)sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_;
                    piVar18[-1] = (int)pvVar15;
                    piVar18[3] = 0;
                    piVar18[-2] = 0x1eb997;
                    _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
                  }
                  piVar18[1] = (int)pvVar12;
                  *piVar18 = (int)sel_removeObject_;
                  piVar18[-1] = (int)local_168;
                  piVar18[-2] = 0x1eb9b9;
                  _objc_msgSend((id)piVar18[-1],(SEL)*piVar18);
                  piVar18 = piVar18 + -1;
                }
                piVar18[1] = (int)sel_nextObject;
                *piVar18 = (int)pvVar7;
                piVar18[-1] = 0x1eb9d1;
                pvVar12 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
              } while (pvVar12 != (id)0x0);
            }
            piVar18[1] = (int)sel_movies;
            *piVar18 = (int)local_150;
            piVar18[-1] = 0x1eb9f1;
            pvVar7 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
            piVar18[1] = (int)sel_count;
            *piVar18 = (int)pvVar7;
            piVar18[-1] = 0x1eba03;
            pvVar7 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
            if (pvVar7 == (id)0x0) {
              piVar18[1] = (int)sel_liveVideos;
              *piVar18 = (int)local_150;
              piVar18[-1] = 0x1eba1f;
              pvVar7 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
              piVar18[1] = (int)sel_count;
              *piVar18 = (int)pvVar7;
              piVar18[-1] = 0x1eba31;
              pvVar7 = _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
              if (pvVar7 != (id)0x0) goto LAB_001eba35;
            }
            else {
LAB_001eba35:
              piVar18[2] = (int)local_150;
              piVar18[1] = (int)sel_addObject_;
              *piVar18 = (int)local_168;
              piVar18[-1] = 0x1eba57;
              _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
            }
            piVar18[1] = (int)sel_release;
            *piVar18 = (int)local_150;
            piVar18[-1] = 0x1eba6f;
            _objc_msgSend((id)*piVar18,(SEL)piVar18[1]);
            piVar19 = piVar18;
          }
        }
      }
      piVar19[1] = (int)sel_release;
      *piVar19 = (int)pvVar8;
      piVar19[-1] = 0x1eba87;
      _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      bVar17 = local_189;
      goto LAB_001eba93;
    }
    pvVar7 = _objc_msgSend(readFromPasteboard,sel_types);
    pvVar7 = _objc_msgSend(pvVar7,sel_containsObject_);
    if ((char)pvVar7 != '\0') goto LAB_001ea924;
    bVar17 = false;
    local_189 = false;
    piVar19 = (int *)&stack0xfffffe44;
LAB_001ebaa0:
    if (local_138 == 0) {
      piVar19[1] = (int)sel_types;
      *piVar19 = (int)readFromPasteboard;
      piVar19[-1] = 0x1ebac2;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      puVar16 = PTR_00336414;
      piVar19[2] = *(undefined4 *)PTR_00336414;
      piVar19[1] = (int)sel_containsObject_;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ebae0;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if ((char)pvVar7 == '\0') {
        piVar19[1] = (int)sel_types;
        *piVar19 = (int)readFromPasteboard;
        piVar19[-1] = 0x1ebaf9;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = (int)&cfstr_CorePasteboardFlavorType_0x6974756E;
        piVar19[1] = (int)sel_containsObject_;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ebb15;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if ((char)pvVar7 == '\0') goto LAB_001ebd00;
      }
      piVar19[1] = (int)sel_types;
      *piVar19 = (int)readFromPasteboard;
      piVar19[-1] = 0x1ebb32;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[2] = *(undefined4 *)puVar16;
      piVar19[1] = (int)sel_containsObject_;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ebb4a;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if ((char)pvVar7 == '\0') {
        piVar19[1] = (int)sel_class;
        *piVar19 = (int)self;
        piVar19[-1] = 0x1ebb78;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = (int)readFromPasteboard;
        piVar19[1] = (int)sel_iTunesSpecificFilenamesFromPasteboard_;
      }
      else {
        piVar19[2] = *(undefined4 *)puVar16;
        piVar19[1] = (int)sel_propertyListForType_;
        pvVar7 = readFromPasteboard;
      }
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ebb91;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[1] = (int)sel_array;
      *piVar19 = (int)cls_NSMutableArray;
      piVar19[-1] = 0x1ebbaf;
      pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[1] = (int)sel_objectEnumerator;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ebbd7;
      pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      while( true ) {
        piVar19[1] = (int)sel_nextObject;
        *piVar19 = (int)pvVar12;
        piVar19[-1] = 0x1ebc9d;
        pvVar15 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if (pvVar15 == (id)0x0) break;
        piVar19[1] = (int)sel_count;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ebbfc;
        pvVar13 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[8] = (uint)(byte)useDragPreferences;
        piVar19[7] = dragOperation;
        piVar19[6] = (int)&local_138;
        pBVar14 = (BOOL *)0x0;
        if (pvVar13 == (id)0x1) {
          pBVar14 = runAnimationMode;
        }
        piVar19[5] = (int)pBVar14;
        piVar19[4] = (int)acceptingObject;
        piVar19[2] = (int)pvVar15;
        piVar19[1] = (int)
                     sel_objectFromFile_shouldImport_intoAcceptingObject_runAnimationMode_error_dragOperation_useDragPreferences_
        ;
        *piVar19 = (int)self;
        piVar19[3] = 0;
        piVar19[-1] = 0x1ebc4f;
        pvVar15 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if ((local_138 != 0) || (pvVar15 == (id)0x0)) break;
        piVar19[2] = (int)pvVar15;
        piVar19[1] = (int)sel_addObject_;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ebc79;
        _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if (pastingNotHSObject != (BOOL *)0x0) {
          *pastingNotHSObject = '\x01';
        }
      }
      if (local_138 == 0) {
        piVar19[1] = (int)sel_count;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ebcc7;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if (pvVar7 != (id)0x0) {
          piVar19[2] = (int)pvVar8;
          piVar19[1] = (int)sel_addObjectsFromArray_;
          *piVar19 = (int)local_168;
          piVar19[-1] = 0x1ebced;
          _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if (pastingNotHSObject != (BOOL *)0x0) {
            *pastingNotHSObject = '\x01';
          }
          local_189 = true;
        }
      }
    }
  }
  else {
    pvVar7 = _objc_msgSend(readFromPasteboard,sel_propertyListForType_);
    local_189 = false;
    pvVar7 = _objc_msgSend(pvVar7,sel_objectEnumerator);
LAB_001ea87b:
    pvVar8 = _objc_msgSend(pvVar7,sel_nextObject);
    if (pvVar8 != (id)0x0) {
      pvVar12 = _objc_msgSend(pvVar8,sel_objectForKey_);
      if (pvVar12 != (id)0x0) {
        _objc_msgSend(cls_HSUID,sel_UIDWithString_);
      }
      pvVar12 = _objc_msgSend(cls_HSNewMediaAccessor,sel_sharedMediaAccessor);
      local_150 = _objc_msgSend(pvVar12,sel_mediaForUID_);
      pvVar8 = _objc_msgSend(pvVar8,sel_objectForKey_);
      if ((local_150 == (id)0x0) && (pvVar8 != (id)0x0)) {
        local_150 = _objc_msgSend(cls_HSNewMedia,sel_mediaWithPath_mediaUID_);
      }
      if ((runAnimationMode == (BOOL *)0x0) || (*runAnimationMode != '\0')) {
        cVar6 = '\0';
      }
      else {
        if (((pvVar8 == (id)0x0) ||
            (pvVar8 = _objc_msgSend(cls_HSLibraryContentHelper,
                                    sel_shouldFileBeCreatedAsAnimationAtPath_), (char)pvVar8 == '\0'
            )) || (dragOperation == 1)) {
          cVar6 = '\0';
        }
        else {
          cVar6 = '\x01';
        }
        *runAnimationMode = cVar6;
      }
      if ((((cVar6 != '\0') || (acceptingObject == (id)0x0)) ||
          (pvVar8 = _objc_msgSend(acceptingObject,sel_queryHyperInterface_), pvVar8 != (id)0x0)) &&
         (pvVar8 = _objc_msgSend(local_150,sel_mediaGroup), pvVar8 != (id)0x2)) goto LAB_001ea7f8;
      pvVar8 = _objc_msgSend(self,sel_editorDocument);
      pvVar8 = _objc_msgSend(pvVar8,sel_userActionWithMedia_error_);
      if (((pvVar8 == (id)0x0) ||
          (pvVar8 = _objc_msgSend(self,sel_canAddAction_intoObject_), (char)pvVar8 == '\0')) ||
         (pvVar8 = _objc_msgSend(self,sel_isLockedObject_), (char)pvVar8 != '\0'))
      goto LAB_001ea7f8;
      local_189 = true;
      goto LAB_001ea838;
    }
    bVar17 = false;
LAB_001eba93:
    if (local_189 == false) goto LAB_001ebaa0;
  }
LAB_001ebd00:
  piVar19[1] = (int)sel_types;
  *piVar19 = (int)readFromPasteboard;
  piVar19[-1] = 0x1ebd15;
  pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  piVar19[2] = *(undefined4 *)PTR_00336418;
  piVar19[1] = (int)sel_containsObject_;
  *piVar19 = (int)pvVar7;
  piVar19[-1] = 0x1ebd33;
  pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  cVar6 = (char)pvVar7;
  if ((local_189 == false) && (cVar6 != '\0')) {
    piVar19[1] = (int)sel_types;
    *piVar19 = (int)readFromPasteboard;
    piVar19[-1] = 0x1ebd63;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    piVar19[2] = (int)&cfstr_HSLibraryiPhotoPboardType;
    piVar19[1] = (int)sel_containsObject_;
    *piVar19 = (int)pvVar7;
    piVar19[-1] = 0x1ebd7f;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if (((char)pvVar7 == '\0') || (local_138 != 0)) goto LAB_001ebe40;
    piVar19[2] = (int)readFromPasteboard;
    piVar19[1] = (int)sel_URLFromPasteboard_;
    *piVar19 = (int)cls_NSURL;
    piVar19[-1] = 0x1ebdb3;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    piVar19[1] = (int)sel_path;
    *piVar19 = (int)pvVar7;
    piVar19[-1] = 0x1ebdc5;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    piVar19[8] = (uint)(byte)useDragPreferences;
    piVar19[7] = dragOperation;
    piVar19[6] = (int)&local_138;
    piVar19[4] = (int)acceptingObject;
    piVar19[2] = (int)pvVar7;
    piVar19[1] = (int)
                 sel_objectFromFile_shouldImport_intoAcceptingObject_runAnimationMode_error_dragOperation_useDragPreferences_
    ;
    *piVar19 = (int)self;
    piVar19[5] = 0;
    piVar19[3] = 0;
    piVar19[-1] = 0x1ebe0e;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if ((local_138 != 0) || (pvVar7 == (id)0x0)) goto LAB_001ebe40;
    piVar19[2] = (int)pvVar7;
    piVar19[1] = (int)sel_addObject_;
    *piVar19 = (int)local_168;
    piVar19[-1] = 0x1ebe37;
    _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    local_189 = true;
LAB_001ebe49:
    if ((bVar17 != false) && (local_189 != false)) goto LAB_001ebe5b;
LAB_001ebe68:
    if (local_189 == false) {
      piVar19[1] = (int)sel_types;
      *piVar19 = (int)readFromPasteboard;
      piVar19[-1] = 0x1ebe8a;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      uVar3 = *(undefined4 *)PTR_003367bc;
      piVar19[2] = uVar3;
      piVar19[1] = (int)sel_containsObject_;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ebea8;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (((char)pvVar7 != '\0') && (local_138 == 0)) {
        if (1038.0 < *(double *)PTR_0033605c || *(double *)PTR_0033605c == 1038.0) {
          piVar19[2] = uVar3;
          piVar19[1] = (int)sel_arrayWithObjects_;
          *piVar19 = (int)cls_NSArray;
          piVar19[3] = 0;
          piVar19[-1] = 0x1ebef5;
          pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[2] = (int)pvVar7;
          piVar19[1] = (int)sel_canReadItemWithDataConformingToTypes_;
          *piVar19 = (int)readFromPasteboard;
          piVar19[-1] = 0x1ebf0e;
          pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if ((char)pvVar7 == '\0') goto LAB_001ec3de;
        }
        piVar19[3] = (int)&local_138;
        piVar19[2] = (int)readFromPasteboard;
        piVar19[1] = (int)sel_movieWithPasteboard_error_;
        *piVar19 = (int)cls_QTMovie;
        piVar19[-1] = 0x1ebf3f;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if (pvVar7 != (id)0x0) {
          piVar19[1] = (int)sel_movieFormatRepresentation;
          *piVar19 = (int)pvVar7;
          piVar19[-1] = 0x1ebf5b;
          pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[1] = (int)sel_movieAttributes;
          *piVar19 = (int)pvVar7;
          piVar19[-1] = 0x1ebf73;
          pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[2] = *(undefined4 *)PTR_003361c0;
          piVar19[1] = (int)sel_objectForKey_;
          *piVar19 = (int)pvVar7;
          piVar19[-1] = 0x1ebf91;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[1] = (int)sel_null;
          *piVar19 = (int)cls_NSNull;
          piVar19[-1] = 0x1ebfab;
          pvVar15 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[4] = (int)&cfstr_mov;
          pvVar7 = (id)0x0;
          if (pvVar15 != pvVar12) {
            pvVar7 = pvVar12;
          }
          piVar19[3] = (int)pvVar7;
          piVar19[2] = (int)pvVar8;
          piVar19[1] = (int)sel_mediaWithData_name_type_;
          *piVar19 = (int)cls_HSNewMedia;
          piVar19[-1] = 0x1ebff1;
          pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[1] = (int)sel_alloc;
          *piVar19 = (int)cls_HSMovieObject;
          piVar19[-1] = 0x1ec00b;
          pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[3] = (int)&local_138;
          piVar19[2] = (int)pvVar7;
          piVar19[1] = (int)sel_initWithMedia_error_;
          *piVar19 = (int)pvVar8;
          piVar19[-1] = 0x1ec02b;
          pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[1] = (int)sel_autorelease;
          *piVar19 = (int)pvVar7;
          piVar19[-1] = 0x1ec03d;
          pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if (pvVar7 != (id)0x0) {
            piVar19[2] = (int)pvVar7;
            piVar19[1] = (int)sel_addObject_;
            goto LAB_001ec3bd;
          }
        }
      }
    }
  }
  else {
LAB_001ebe40:
    if (local_189 != false) goto LAB_001ebe49;
LAB_001ebe5b:
    if ((cVar6 == '\0') || (local_138 != 0)) goto LAB_001ebe68;
    piVar19[2] = (int)readFromPasteboard;
    piVar19[1] = (int)sel_URLFromPasteboard_;
    *piVar19 = (int)cls_NSURL;
    piVar19[-1] = 0x1ec084;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    piVar19[1] = (int)sel_isFileURL;
    *piVar19 = (int)pvVar7;
    piVar19[-1] = 0x1ec098;
    pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if ((char)pvVar8 == '\0') {
      pvVar7 = (id)0x0;
      pvVar8 = (id)0x0;
    }
    else {
      piVar19[1] = (int)sel_path;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ec0b7;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pvVar7 != (id)0x0) {
        piVar19[1] = (int)sel_defaultManager;
        *piVar19 = (int)cls_NSFileManager;
        piVar19[-1] = 0x1ec0dc;
        pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = (int)pvVar7;
        piVar19[1] = (int)sel_fileExistsAtPath_;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ec0f2;
        pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if ((char)pvVar8 != '\0') {
          piVar19[1] = (int)sel_sharedDocumentController;
          *piVar19 = (int)cls_HSEditorController;
          piVar19[-1] = 0x1ec10e;
          pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[2] = (int)pvVar7;
          piVar19[1] = (int)sel_canImportFileAtPath_showAlert_;
          *piVar19 = (int)pvVar8;
          piVar19[3] = 1;
          piVar19[-1] = 0x1ec12c;
          pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if ((char)pvVar8 != '\0') {
            piVar19[2] = (int)pvVar7;
            piVar19[1] = (int)sel_mediaWithPath_;
            *piVar19 = (int)self;
            piVar19[-1] = 0x1ec149;
            pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
            goto LAB_001ec14b;
          }
        }
      }
      pvVar8 = (id)0x0;
    }
LAB_001ec14b:
    if (runAnimationMode == (BOOL *)0x0) {
      bVar4 = 0;
    }
    else {
      if (pvVar7 == (id)0x0) {
LAB_001ec187:
        bVar4 = 0;
      }
      else {
        piVar19[2] = (int)pvVar7;
        piVar19[1] = (int)sel_shouldFileBeCreatedAsAnimationAtPath_;
        *piVar19 = (int)cls_HSLibraryContentHelper;
        piVar19[-1] = 0x1ec17a;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if ((char)pvVar7 == '\0') goto LAB_001ec187;
        bVar4 = 1;
      }
      *runAnimationMode = bVar4;
    }
    if ((pvVar8 == (id)0x0) || (local_189 != false)) goto LAB_001ebe68;
    if (acceptingObject == (id)0x0) {
LAB_001ec1d7:
      piVar19[1] = (int)sel_mediaGroup;
      *piVar19 = (int)pvVar8;
      piVar19[-1] = 0x1ec1e9;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pvVar7 == (id)0x2) goto LAB_001ec1f2;
LAB_001ec2a6:
      piVar19[1] = (int)sel_supportedMediaTypes;
      *piVar19 = (int)cls_HSNewMediaAccessor;
      piVar19[-1] = 0x1ec2be;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[1] = (int)sel_mediaType;
      *piVar19 = (int)pvVar8;
      piVar19[-1] = 0x1ec2d2;
      pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[2] = (int)pvVar12;
      piVar19[1] = (int)sel_containsObject_;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ec2e8;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if ((char)pvVar7 == '\0') goto LAB_001ebe68;
      piVar19[4] = (int)&local_138;
      piVar19[3] = (uint)bVar4;
      piVar19[2] = (int)pvVar8;
      piVar19[1] = (int)sel_userObjectWithMedia_animation_error_;
      *piVar19 = (int)cls_HSEditorDocument;
      piVar19[-1] = 0x1ec321;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      puVar16 = PTR_003361bc;
      if (pvVar7 == (id)0x0) goto LAB_001ebe68;
      piVar19[2] = *(undefined4 *)PTR_003361bc;
      piVar19[1] = (int)sel_stringForType_;
      *piVar19 = (int)readFromPasteboard;
      piVar19[-1] = 0x1ec350;
      pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pvVar8 != (id)0x0) {
        piVar19[2] = (int)&DAT_0037f7e0;
        piVar19[1] = (int)sel_queryHyperInterface_;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ec376;
        pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = *(undefined4 *)puVar16;
        piVar19[1] = (int)sel_stringForType_;
        *piVar19 = (int)readFromPasteboard;
        piVar19[-1] = 0x1ec393;
        pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = (int)pvVar12;
        piVar19[1] = (int)sel_setHyperName_;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ec3a9;
        _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      }
      piVar19[2] = (int)pvVar7;
      piVar19[1] = (int)sel_addObject_;
LAB_001ec3bd:
      *piVar19 = (int)local_168;
      piVar19[-1] = 0x1ec3cb;
      _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pastingNotHSObject != (BOOL *)0x0) {
        *pastingNotHSObject = '\x01';
      }
    }
    else {
      piVar19[2] = (int)&DAT_0037fc68;
      piVar19[1] = (int)sel_implementsHyperInterface_;
      *piVar19 = (int)acceptingObject;
      piVar19[-1] = 0x1ec1d3;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if ((char)pvVar7 == '\0') goto LAB_001ec1d7;
LAB_001ec1f2:
      piVar19[1] = (int)sel_editorDocument;
      *piVar19 = (int)self;
      piVar19[-1] = 0x1ec207;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[3] = (int)&local_138;
      piVar19[2] = (int)pvVar8;
      piVar19[1] = (int)sel_userActionWithMedia_error_;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ec227;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pvVar7 == (id)0x0) goto LAB_001ec2a6;
      piVar19[3] = (int)acceptingObject;
      piVar19[2] = (int)pvVar7;
      piVar19[1] = (int)sel_canAddAction_intoObject_;
      *piVar19 = (int)self;
      piVar19[-1] = 0x1ec24d;
      pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if ((char)pvVar12 == '\0') goto LAB_001ec2a6;
      piVar19[2] = (int)acceptingObject;
      piVar19[1] = (int)sel_isLockedObject_;
      *piVar19 = (int)self;
      piVar19[-1] = 0x1ec26d;
      pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if ((char)pvVar12 != '\0' || bVar4 != 0) goto LAB_001ec2a6;
      piVar19[2] = (int)pvVar7;
      piVar19[1] = (int)sel_addObject_;
      *piVar19 = (int)local_168;
      piVar19[-1] = 0x1ec291;
      _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pastingNotHSObject != (BOOL *)0x0) {
        *pastingNotHSObject = '\x01';
      }
    }
    local_189 = true;
  }
LAB_001ec3de:
  piVar19[2] = (int)readFromPasteboard;
  piVar19[1] = (int)sel_canInitWithPasteboard_;
  *piVar19 = (int)cls_NSImage;
  piVar19[-1] = 0x1ec3fd;
  pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  if ((char)pvVar7 != '\0' || local_189 != false) goto LAB_001ec6fa;
  piVar19[1] = (int)sel_types;
  *piVar19 = (int)readFromPasteboard;
  piVar19[-1] = 0x1ec425;
  pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  piVar19[2] = *(undefined4 *)PTR_003367b8;
  piVar19[1] = (int)sel_containsObject_;
  *piVar19 = (int)pvVar8;
  piVar19[-1] = 0x1ec443;
  pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  if ((char)pvVar8 == '\0') {
    piVar19[1] = (int)sel_types;
    *piVar19 = (int)readFromPasteboard;
    piVar19[-1] = 0x1ec460;
    pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    piVar19[2] = (int)&cfstr_HSSerializedRichTextPasteboardType;
    piVar19[1] = (int)sel_containsObject_;
    *piVar19 = (int)pvVar8;
    piVar19[-1] = 0x1ec47c;
    pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if ((char)pvVar8 != '\0') goto LAB_001ec4ff;
    piVar19[1] = (int)sel_types;
    *piVar19 = (int)readFromPasteboard;
    piVar19[-1] = 0x1ec495;
    pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    piVar19[2] = *(undefined4 *)PTR_003367b4;
    piVar19[1] = (int)sel_containsObject_;
    *piVar19 = (int)pvVar8;
    piVar19[-1] = 0x1ec4b3;
    pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if ((char)pvVar8 != '\0') goto LAB_001ec4ff;
    if (cVar6 == '\0') {
      piVar19[1] = (int)sel_types;
      *piVar19 = (int)readFromPasteboard;
      piVar19[-1] = 0x1ec4d9;
      pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[2] = *(undefined4 *)PTR_003361bc;
      piVar19[1] = (int)sel_containsObject_;
      *piVar19 = (int)pvVar8;
      piVar19[-1] = 0x1ec4f7;
      pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if ((char)pvVar8 != '\0') goto LAB_001ec4ff;
    }
  }
  else {
LAB_001ec4ff:
    if (local_138 == 0) {
      piVar19[2] = (int)readFromPasteboard;
      piVar19[1] = (int)sel_stringFromPasteboard_;
      *piVar19 = (int)self;
      piVar19[-1] = 0x1ec528;
      pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[1] = (int)sel_retain;
      *piVar19 = (int)pvVar8;
      piVar19[-1] = 0x1ec53a;
      pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pvVar8 != (id)0x0) {
        if (useDragPreferences == '\0') {
LAB_001ec630:
          piVar19[1] = (int)sel_editorDocument;
          *piVar19 = (int)self;
          piVar19[-1] = 0x1ec645;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[1] = (int)sel_editorWindowController;
          *piVar19 = (int)pvVar12;
          piVar19[-1] = 0x1ec657;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[1] = (int)sel_cardView;
          *piVar19 = (int)pvVar12;
          piVar19[-1] = 0x1ec669;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[2] = (int)pvVar8;
          piVar19[1] = (int)sel_stringOfPermittedLengthFromString_;
          *piVar19 = (int)pvVar12;
          piVar19[-1] = 0x1ec685;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if (pvVar12 != (id)0x0) {
            piVar19[2] = (int)pvVar12;
            piVar19[1] = (int)sel_userObjectWithAttributedString_;
            *piVar19 = (int)cls_HSEditorDocument;
            piVar19[-1] = 0x1ec6a5;
            pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
            if (pvVar12 != (id)0x0) {
              piVar19[2] = (int)pvVar12;
              piVar19[1] = (int)sel_addObject_;
              *piVar19 = (int)local_168;
              piVar19[-1] = 0x1ec6c5;
              _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
              if (pastingNotHSObject != (BOOL *)0x0) {
                *pastingNotHSObject = '\x01';
              }
              local_138 = 0;
              goto LAB_001ec6db;
            }
          }
        }
        else {
          piVar19[1] = (int)sel_string;
          *piVar19 = (int)pvVar8;
          piVar19[-1] = 0x1ec56a;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[2] = (int)pvVar12;
          piVar19[1] = (int)sel_stringIsURL_;
          *piVar19 = (int)self;
          piVar19[-1] = 0x1ec583;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if ((char)pvVar12 == '\0') goto LAB_001ec630;
          piVar19[2] = (int)acceptingObject;
          piVar19[1] = (int)sel_isLockedObject_;
          *piVar19 = (int)self;
          piVar19[-1] = 0x1ec5a7;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          puVar5 = cls_HSGoToURLAction;
          puVar16 = cls_NSURL;
          if ((char)pvVar12 != '\0') goto LAB_001ec630;
          piVar19[1] = (int)sel_string;
          *piVar19 = (int)pvVar8;
          piVar19[-1] = 0x1ec5d3;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[2] = (int)pvVar12;
          piVar19[1] = (int)sel_URLWithString_;
          *piVar19 = (int)puVar16;
          piVar19[-1] = 0x1ec5e9;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[2] = (int)pvVar12;
          piVar19[1] = (int)sel_actionWithURL_;
          *piVar19 = (int)puVar5;
          piVar19[-1] = 0x1ec5ff;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[2] = (int)pvVar12;
          piVar19[1] = (int)sel_addObject_;
          *piVar19 = (int)local_168;
          piVar19[-1] = 0x1ec61b;
          _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if (pastingNotHSObject != (BOOL *)0x0) {
            *pastingNotHSObject = '\x01';
          }
LAB_001ec6db:
          local_189 = true;
        }
        piVar19[1] = (int)sel_release;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ec6fa;
        _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      }
    }
  }
LAB_001ec6fa:
  if (local_189 != false) {
    piVar19[2] = (int)readFromPasteboard;
    piVar19[1] = (int)sel_cashedImageDataFromRTFDPasteboard_;
    *piVar19 = (int)self;
    piVar19[-1] = 0x1ec71f;
    _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    goto LAB_001ecd5c;
  }
  piVar19[1] = (int)sel_types;
  *piVar19 = (int)readFromPasteboard;
  piVar19[-1] = 0x1ec739;
  pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  piVar19[2] = (int)&cfstr_BTArchivedImageRegionPboardType;
  piVar19[1] = (int)sel_containsObject_;
  *piVar19 = (int)pvVar8;
  piVar19[-1] = 0x1ec755;
  pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  if ((char)pvVar8 == '\0') {
LAB_001ec7a4:
    piVar19[1] = (int)sel_types;
    *piVar19 = (int)readFromPasteboard;
    piVar19[-1] = 0x1ec7b9;
    pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    piVar19[2] = (int)&cfstr_HSCardsIndexPasteboardType;
    piVar19[1] = (int)sel_containsObject_;
    *piVar19 = (int)pvVar8;
    piVar19[-1] = 0x1ec7d5;
    pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if ((char)pvVar8 != '\0') {
      piVar19[2] = (int)&cfstr_HSCardsIndexPasteboardType;
      piVar19[1] = (int)sel_propertyListForType_;
      *piVar19 = (int)readFromPasteboard;
      piVar19[-1] = 0x1ec7f6;
      pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[1] = (int)sel_count;
      *piVar19 = (int)pvVar8;
      piVar19[-1] = 0x1ec80a;
      pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pvVar12 != (id)0x0) {
        piVar19[1] = (int)sel_objectAtIndex_;
        *piVar19 = (int)pvVar8;
        piVar19[2] = 0;
        piVar19[-1] = 0x1ec82c;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[1] = (int)sel_unsignedIntValue;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ec83e;
        pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        pvVar7 = self->_dragHost;
        piVar19[1] = (int)sel_cardForDragHost;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ec858;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[1] = (int)sel_hyperParent;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ec86a;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = (int)pvVar8;
        piVar19[1] = (int)sel_hyperChildAtIndex_;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ec880;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[1] = (int)sel_hyperUID;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ec892;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[1] = (int)sel_new;
        *piVar19 = (int)cls_HSOtherCardAction;
        piVar19[-1] = 0x1ec8ac;
        pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = (int)pvVar7;
        piVar19[1] = (int)sel_setDestinationCardUID_;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ec8c4;
        _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = (int)&cfstr_Fade;
        piVar19[1] = (int)sel_transitionWithName_;
        *piVar19 = (int)cls_HSTransition;
        piVar19[-1] = 0x1ec8e6;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = (int)pvVar7;
        piVar19[1] = (int)sel_setTransition_;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ec8fc;
        _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[1] = (int)sel_transition;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ec90e;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        *(double *)(piVar19 + 2) = *(double *)PTR_003365a8 + *(double *)PTR_003365a8;
        piVar19[1] = (int)sel_setDuration_;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ec934;
        _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if (acceptingObject == (id)0x0) {
          pvVar7 = self->_dragHost;
          piVar19[1] = (int)sel_cardForDragHost;
          *piVar19 = (int)pvVar7;
          piVar19[-1] = 0x1ec952;
          local_198 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        }
        piVar19[2] = (int)&DAT_003805f0;
        piVar19[1] = (int)sel_queryHyperInterface_;
        *piVar19 = (int)local_198;
        piVar19[-1] = 0x1ec97a;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = *(undefined4 *)PTR_00336084;
        piVar19[1] = (int)sel_actionEventOfType_;
        *piVar19 = (int)cls_HSActionEvent;
        piVar19[-1] = 0x1ec9a4;
        pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[3] = (int)pvVar12;
        piVar19[2] = (int)pvVar8;
        piVar19[1] = (int)sel_addHyperAction_forEvent_;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ec9c4;
        _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[1] = (int)sel_release;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ec9d6;
        _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        goto LAB_001ec9d6;
      }
    }
    piVar19[2] = (int)readFromPasteboard;
    piVar19[1] = (int)sel_cashedImageDataFromRTFDPasteboard_;
    *piVar19 = (int)self;
    piVar19[-1] = 0x1eca13;
    local_150 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if (((local_150 == (id)0x0) && ((char)pvVar7 == '\0')) || (local_138 != 0)) goto LAB_001ecd5c;
    piVar19[1] = (int)sel_types;
    *piVar19 = (int)readFromPasteboard;
    piVar19[-1] = 0x1eca59;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    puVar16 = PTR_003361bc;
    piVar19[2] = *(undefined4 *)PTR_003361bc;
    piVar19[1] = (int)sel_containsObject_;
    *piVar19 = (int)pvVar7;
    piVar19[-1] = 0x1eca77;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if ((char)pvVar7 == '\0') {
      piVar19[1] = (int)sel_string;
      puVar16 = cls_NSString;
    }
    else {
      piVar19[2] = *(undefined4 *)puVar16;
      piVar19[1] = (int)sel_stringForType_;
      puVar16 = readFromPasteboard;
    }
    *piVar19 = (int)puVar16;
    piVar19[-1] = 0x1ecaa8;
    pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    piVar19[1] = (int)sel_lastPathComponent;
    *piVar19 = (int)pvVar8;
    piVar19[-1] = 0x1ecac6;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    piVar19[1] = (int)sel_length;
    *piVar19 = (int)pvVar7;
    piVar19[-1] = 0x1ecada;
    pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if (pvVar12 == (id)0x0) {
      pvVar7 = pvVar8;
    }
    if (local_150 == (id)0x0) {
      piVar19[2] = *(undefined4 *)PTR_003367b0;
      piVar19[1] = (int)sel_dataForType_;
      *piVar19 = (int)readFromPasteboard;
      piVar19[-1] = 0x1ecb09;
      local_150 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    }
    piVar19[1] = (int)sel_pathExtension;
    *piVar19 = (int)pvVar7;
    piVar19[-1] = 0x1ecb21;
    pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if (local_150 == (id)0x0) {
      piVar19[1] = (int)sel_alloc;
      *piVar19 = (int)cls_NSImage;
      piVar19[-1] = 0x1ecb42;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
LAB_001ecb42:
      piVar19[2] = (int)readFromPasteboard;
      piVar19[1] = (int)sel_initWithPasteboard_;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ecb5b;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[1] = (int)sel_autorelease;
LAB_001ecc02:
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ecc0a;
      local_150 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (local_150 != (id)0x0) {
        piVar19[2] = (int)&cfstr_http___maps_google_com__;
        piVar19[1] = (int)sel_hasPrefix_;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ecc36;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        puVar16 = sel_mediaWithImage_;
        if ((char)pvVar7 != '\0') {
          piVar19[1] = (int)sel_size;
          *piVar19 = (int)local_150;
          piVar19[-1] = 0x1ecc4c;
          pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          piVar19[1] = (int)sel_size;
          *piVar19 = (int)local_150;
          piVar19[-1] = 0x1ecc6a;
          _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          puVar16 = sel_mediaWithImage_;
          if (extraout_EDX_00 * (float)pvVar7 <= 1.0) goto LAB_001ecd5c;
        }
        goto LAB_001ecc8f;
      }
    }
    else {
      piVar19[1] = (int)sel_imageFileTypes;
      *piVar19 = (int)cls_NSImage;
      piVar19[-1] = 0x1ecb7e;
      pvVar15 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[2] = (int)pvVar12;
      piVar19[1] = (int)sel_containsObject_;
      *piVar19 = (int)pvVar15;
      piVar19[-1] = 0x1ecb94;
      pvVar15 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if ((char)pvVar15 == '\0') {
        piVar19[1] = (int)sel_alloc;
        *piVar19 = (int)cls_NSImage;
        piVar19[-1] = 0x1ecbcf;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if (local_150 == (id)0x0) goto LAB_001ecb42;
        piVar19[2] = (int)local_150;
        piVar19[1] = (int)sel_initWithData_;
        *piVar19 = (int)pvVar7;
        piVar19[-1] = 0x1ecbf8;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[1] = (int)sel_autorelease;
        goto LAB_001ecc02;
      }
      piVar19[4] = (int)pvVar12;
      piVar19[3] = (int)pvVar7;
      puVar16 = sel_mediaWithData_name_type_;
LAB_001ecc8f:
      piVar19[2] = (int)local_150;
      piVar19[1] = (int)puVar16;
      *piVar19 = (int)cls_HSNewMedia;
      piVar19[-1] = 0x1ecc9f;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pvVar7 != (id)0x0) {
        piVar19[2] = (int)pvVar7;
        piVar19[1] = (int)sel_userObjectWithMedia_;
        *piVar19 = (int)cls_HSEditorDocument;
        piVar19[-1] = 0x1eccc3;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        if (pvVar7 != (id)0x0) {
          piVar19[2] = (int)&DAT_003801f4;
          piVar19[1] = (int)sel_implementsHyperInterface_;
          *piVar19 = (int)pvVar7;
          piVar19[-1] = 0x1ecce9;
          pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if ((char)pvVar8 != '\0') {
            piVar19[2] = (int)&DAT_00380690;
            piVar19[1] = (int)sel_queryHyperInterface_;
            *piVar19 = (int)pvVar7;
            piVar19[-1] = 0x1ecd09;
            pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
            piVar19[1] = (int)sel_setHyperShadowEnabled_;
            *piVar19 = (int)pvVar8;
            piVar19[2] = 0;
            piVar19[-1] = 0x1ecd23;
            _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          }
          piVar19[2] = (int)pvVar7;
          piVar19[1] = (int)sel_addObject_;
          *piVar19 = (int)local_168;
          piVar19[-1] = 0x1ecd3f;
          _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if (pastingNotHSObject != (BOOL *)0x0) {
            *pastingNotHSObject = '\x01';
          }
          local_138 = 0;
          goto LAB_001ecd55;
        }
      }
    }
  }
  else {
    piVar19[2] = (int)readFromPasteboard;
    piVar19[1] = (int)sel_archivedImageRegionNodeFromPasteboard_;
    *piVar19 = (int)self;
    piVar19[-1] = 0x1ec775;
    pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if (pvVar8 == (id)0x0) goto LAB_001ec7a4;
    piVar19[2] = (int)pvVar8;
    piVar19[1] = (int)sel_addObject_;
    *piVar19 = (int)local_168;
    piVar19[-1] = 0x1ec795;
    _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    local_138 = 0;
LAB_001ec9d6:
    piVar19[2] = (int)readFromPasteboard;
    piVar19[1] = (int)sel_cashedImageDataFromRTFDPasteboard_;
    *piVar19 = (int)self;
    piVar19[-1] = 0x1ec9f2;
    _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
LAB_001ecd55:
    local_189 = true;
  }
LAB_001ecd5c:
  pvVar7 = self->_cashedImageDataFromRTFDPasteboard;
  piVar19[1] = (int)sel_release;
  *piVar19 = (int)pvVar7;
  piVar19[-1] = 0x1ecd74;
  _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  self->_cashedImageDataFromRTFDPasteboard = (id)0x0;
  if (local_189 != false) {
LAB_001ece71:
    piVar19[1] = (int)sel_count;
    *piVar19 = (int)local_168;
    piVar19[-1] = 0x1ece89;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if (pvVar7 != (id)0x0) {
      piVar19[2] = (int)readFromPasteboard;
      piVar19[1] = (int)sel_URLFromPasteboard_;
      *piVar19 = (int)cls_HSEditorCardViewDragHelper;
      piVar19[-1] = 0x1eceb0;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pvVar7 == (id)0x0) {
        local_154 = (id)0x0;
      }
      else {
        piVar19[1] = (int)sel_class;
        *piVar19 = (int)self;
        piVar19[-1] = 0x1ecf80;
        pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        piVar19[2] = (int)pvVar7;
        piVar19[1] = (int)sel_commentsForDroppedObjectWithURL_;
        *piVar19 = (int)pvVar8;
        piVar19[-1] = 0x1ecf96;
        local_154 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      }
      piVar19[1] = (int)sel_length;
      *piVar19 = (int)local_154;
      piVar19[-1] = 0x1ecfb4;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pvVar7 != (id)0x0) {
        piVar19[1] = (int)sel_objectEnumerator;
        *piVar19 = (int)local_168;
        bVar17 = true;
        piVar19[-1] = 0x1ecfd6;
        pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
        while( true ) {
          piVar19[1] = (int)sel_nextObject;
          *piVar19 = (int)pvVar7;
          piVar19[-1] = 0x1ed014;
          pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if (pvVar8 == (id)0x0) break;
          piVar19[2] = (int)&DAT_0037fb8c;
          piVar19[1] = (int)sel_queryHyperInterface_;
          *piVar19 = (int)pvVar8;
          piVar19[-1] = 0x1ed036;
          pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if (pvVar12 == (id)0x0) {
            piVar19[2] = (int)&DAT_003806a4;
            piVar19[1] = (int)sel_queryHyperInterface_;
            *piVar19 = (int)pvVar8;
            bVar17 = false;
            piVar19[-1] = 0x1ecff8;
            _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          }
          else {
            piVar19[1] = (int)sel_hyperComments;
            *piVar19 = (int)pvVar12;
            piVar19[-1] = 0x1ed052;
            pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
            piVar19[1] = (int)sel_length;
            *piVar19 = (int)pvVar8;
            bVar17 = false;
            piVar19[-1] = 0x1ed066;
            pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
            if (pvVar8 == (id)0x0) {
              piVar19[2] = (int)local_154;
              piVar19[1] = (int)sel_setHyperComments_;
              *piVar19 = (int)pvVar12;
              piVar19[-1] = 0x1ed08c;
              _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
              bVar17 = false;
            }
          }
        }
        if (bVar17) {
          if (local_198 == (id)0x0) {
            pvVar7 = self->_dragHost;
            piVar19[1] = (int)sel_cardForDragHost;
            *piVar19 = (int)pvVar7;
            piVar19[-1] = 0x1ed0d9;
            local_198 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
            piVar19[2] = (int)&DAT_0037fb8c;
            piVar19[1] = (int)sel_queryHyperInterface_;
          }
          else {
            piVar19[2] = (int)&DAT_0037fb8c;
            piVar19[1] = (int)sel_queryHyperInterface_;
          }
          *piVar19 = (int)local_198;
          piVar19[-1] = 0x1ed0f5;
          pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          if (pvVar7 != (id)0x0) {
            piVar19[2] = (int)local_154;
            piVar19[1] = (int)sel_appendHyperComments_;
            *piVar19 = (int)pvVar7;
            piVar19[-1] = 0x1ed115;
            _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
          }
        }
      }
      if (createdObjects != (id *)0x0) {
        *createdObjects = local_168;
      }
    }
    return local_189;
  }
  if ((local_138 == 0) && (cVar6 != '\0')) {
    piVar19[2] = (int)local_198;
    piVar19[1] = (int)sel_isLockedObject_;
    *piVar19 = (int)self;
    piVar19[-1] = 0x1ecdc1;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if ((char)pvVar7 == '\0') {
      piVar19[1] = (int)sel_new;
      *piVar19 = (int)cls_HSGoToURLAction;
      piVar19[-1] = 0x1ecde1;
      pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[1] = (int)sel_currentAction;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ecdf5;
      pvVar8 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[2] = (int)readFromPasteboard;
      piVar19[1] = (int)sel_URLFromPasteboard_;
      *piVar19 = (int)cls_NSURL;
      piVar19[-1] = 0x1ece1a;
      pvVar12 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[2] = (int)pvVar12;
      piVar19[1] = (int)sel_setURL_;
      *piVar19 = (int)pvVar8;
      piVar19[-1] = 0x1ece36;
      _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[2] = (int)pvVar7;
      piVar19[1] = (int)sel_addObject_;
      *piVar19 = (int)local_168;
      piVar19[-1] = 0x1ece52;
      _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      piVar19[1] = (int)sel_autorelease;
      *piVar19 = (int)pvVar7;
      piVar19[-1] = 0x1ece64;
      _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
      if (pastingNotHSObject != (BOOL *)0x0) {
        *pastingNotHSObject = '\x01';
      }
      local_189 = true;
      goto LAB_001ece71;
    }
  }
  if (local_138 != 0) goto LAB_001ece71;
  if (local_198 != (id)0x0) {
    piVar19[2] = (int)&DAT_0037fc68;
    piVar19[1] = (int)sel_implementsHyperInterface_;
    *piVar19 = (int)local_198;
    piVar19[-1] = 0x1ecf08;
    pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
    if ((char)pvVar7 == '\0') {
      cVar6 = '\0';
      goto LAB_001ecf0e;
    }
  }
  cVar6 = '\x01';
LAB_001ecf0e:
  pvVar7 = self->_dragHost;
  piVar19[1] = (int)sel_window;
  *piVar19 = (int)pvVar7;
  piVar19[-1] = 0x1ecf26;
  pvVar7 = _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  piVar19[3] = (int)cVar6;
  piVar19[2] = (int)pvVar7;
  piVar19[1] = (int)sel_presentDropErrorInWindow_dropOnCard_;
  *piVar19 = (int)self;
  piVar19[-1] = 0x1ecf43;
  _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  piVar19[1] = (int)sel_removeAllObjects;
  *piVar19 = (int)local_168;
  piVar19[-1] = 0x1ecf62;
  _objc_msgSend((id)*piVar19,(SEL)piVar19[1]);
  return '\0';
LAB_001ea7f8:
  pvVar8 = _objc_msgSend(cls_HSEditorDocument,sel_userObjectWithMedia_animation_error_);
  local_189 = pvVar8 != (id)0x0;
  if (local_189) {
LAB_001ea838:
    if (local_168 == (id)0x0) {
      local_168 = _objc_msgSend(cls_NSMutableArray,sel_array);
    }
    _objc_msgSend(local_168,sel_addObject_);
  }
  goto LAB_001ea87b;
}

*/
- (BOOL)readFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject createdObjects:(id *)aObjects runAnimationMode:(BOOL *)aMode dragOperation:(NSUInteger)aOperation useDragPreferences:(BOOL)aPreferences pastingNotHSObject:(BOOL *)aObject2
{
    id accepting;
    NSMutableArray *objects;
    id error;
    BOOL created = NO;
    BOOL hsObjectsCreated = NO;
    BOOL hasURL = NO;
    BOOL imageCanInit = NO;
    BOOL animation = NO;
    id media = nil;
    id path = nil;
    id object = nil;
    id value = nil;
    NSEnumerator *enumerator = nil;

    if ([[[_dragHost cardForDragHost] document] isInAnimationMode] || [self isLockedObject:nil]) {
        return NO;
    }
    accepting = aObject;
    objects = [NSMutableArray array];
    error = nil;
    [HSMediaLoader forceLoadMediasFromPasteboard:aPasteboard];

    if ([[aPasteboard types] containsObject:@"HSLibraryReusableMediaPboardType"]) {
        enumerator = [[aPasteboard propertyListForType:@"HSLibraryReusableMediaPboardType"] objectEnumerator];
        created = NO;
        id item;
        while ((item = [enumerator nextObject]) != nil) {
            id uidString = [item objectForKey:@"HSLibraryReusableMediaGlobalUIDKey"];
            id uid = uidString != nil ? [HSUID UIDWithString:uidString] : nil;
            media = [[HSNewMediaAccessor sharedMediaAccessor] mediaForUID:uid];
            path = [item objectForKey:@"HSLibraryReusableMediaPathKey"];
            if (media == nil && path != nil) {
                media = [HSNewMedia mediaWithPath:path mediaUID:uid];
            }
            if (aMode == NULL || *aMode) {
                animation = NO;
            } else if (path != nil && [HSLibraryContentHelper shouldFileBeCreatedAsAnimationAtPath:path] && aOperation != 1) {
                animation = YES;
            } else {
                animation = NO;
            }
            if (aMode != NULL) {
                *aMode = animation;
            }
            id action = nil;
            if ((!animation && accepting != nil && [accepting queryHyperInterface:@protocol(HSCardAttributes)] == nil) || [media mediaGroup] == 2) {
                action = [[self editorDocument] userActionWithMedia:media error:&error];
                if (action != nil && [self canAddAction:action intoObject:accepting] && ![self isLockedObject:accepting]) {
                    created = YES;
                    [objects addObject:action];
                    continue;
                }
            }
            object = [HSEditorDocument userObjectWithMedia:media animation:animation error:&error];
            created = object != nil;
            if (object != nil) {
                [objects addObject:object];
            }
        }
        hsObjectsCreated = NO;
        goto afterObjects;
    }

    if (![[aPasteboard types] containsObject:@"HSObjectsPasteboardType"] && ![[aPasteboard types] containsObject:@"HSLibraryObjectsPasteboardType"]) {
        hsObjectsCreated = NO;
        created = NO;
        goto filenames;
    }

    {
        id list = [aPasteboard propertyListForType:[[aPasteboard types] containsObject:@"HSLibraryObjectsPasteboardType"] ? @"HSLibraryObjectsPasteboardType" : @"HSObjectsPasteboardType"];
        NSMutableSet *ignoredUIDs = [NSMutableSet new];
        if ([list count] == 0) {
            created = NO;
        } else {
            id nodeContainer = [[[self editorDocument] stack] queryHyperInterface:@protocol(HSUserObjectUIDBasedAccess)];
            id cardEnumerator = [[[[_dragHost cardForDragHost] stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperEnumerator];
            id card;
            while ((card = [cardEnumerator nextObject]) != nil) {
                [ignoredUIDs addObject:[card hyperUID]];
                id childEnumerator = [card hyperEnumerator];
                id child;
                while ((child = [childEnumerator nextObject]) != nil) {
                    [ignoredUIDs addObject:[child hyperUID]];
                }
            }
            created = NO;
            enumerator = [list objectEnumerator];
            id dictionary;
            while ((dictionary = [enumerator nextObject]) != nil) {
                id node = [HSNode nodeWithDictionary:dictionary];
                if (node == nil) {
                    continue;
                }
                [ignoredUIDs unionSet:[[node queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs]];
                id actionCopy = [node queryHyperInterface:@protocol(HSActionCopySupport)];
                if (actionCopy != nil) {
                    [ignoredUIDs unionSet:[actionCopy unrefreshingUIDs]];
                }
                id nodeUID = [[node queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
                if ([nodeContainer childInTreeWithUID:nodeUID] != nil) {
                    [ignoredUIDs removeObject:nodeUID];
                } else {
                    [ignoredUIDs addObject:nodeUID];
                }
                [objects addObject:node];
                created = YES;
            }

            // The pin configurations that refer to other pasted objects have to follow the refreshed UIDs.
            NSMutableArray *pinReferences = [[NSMutableArray alloc] init];
            NSUInteger objectCount = [objects count];
            for (NSUInteger i = 0; i < objectCount; i++) {
                id actor = [[objects objectAtIndex:i] queryHyperInterface:@protocol(HSActor)];
                for (id action in [actor hyperActions]) {
                    if (![action isKindOfType:[HSArduinoWatcherAction actionType]]) {
                        continue;
                    }
                    id mappings = [action digitalPinConfigurationRangeMappings];
                    if (mappings == nil) {
                        continue;
                    }
                    NSUInteger candidateCount = objectCount > 1 ? objectCount : 1;
                    for (NSUInteger j = 0; j < candidateCount; j++) {
                        NSString *targetUID = [[[objects objectAtIndex:j] hyperUID] stringValue];
                        if (targetUID != nil && CFDictionaryContainsKey((CFDictionaryRef)mappings, targetUID)) {
                            [pinReferences addObject:[NSArray arrayWithObjects:[NSNumber numberWithInteger:i], [NSNumber numberWithInteger:j], targetUID, nil]];
                        }
                    }
                }
            }
            NSMutableArray *dictionaries = [[NSMutableArray alloc] initWithCapacity:[objects count]];
            enumerator = [objects objectEnumerator];
            while ((value = [enumerator nextObject]) != nil) {
                [dictionaries addObject:[value extraDictionaryRepresentation]];
            }
            [objects removeAllObjects];
            [dictionaries refreshHyperUIDsAndIgnoreUIDsFromSet:ignoredUIDs];
            enumerator = [dictionaries objectEnumerator];
            while ((value = [enumerator nextObject]) != nil) {
                [objects addObject:[HSNode nodeWithDictionary:value]];
            }
            [dictionaries release];
            for (id reference in pinReferences) {
                NSInteger ownerIndex = [[reference objectAtIndex:0] integerValue];
                NSInteger targetIndex = [[reference objectAtIndex:1] integerValue];
                id oldUID = [reference lastObject];
                id newUID = [[[objects objectAtIndex:targetIndex] hyperUID] stringValue];
                id actor = [[objects objectAtIndex:ownerIndex] queryHyperInterface:@protocol(HSActor)];
                for (id action in [actor hyperActions]) {
                    if ([action isKindOfType:[HSArduinoWatcherAction actionType]]) {
                        id digital = [action digitalPinConfigurationRangesForObjectWithUID:oldUID];
                        id analog = [action analogPinConfigurationRangesForObjectWithUID:oldUID];
                        if (digital != nil) {
                            [action setDigitalPinConfigurationRanges:digital analogPinConfigurationRanges:analog forObjectWithUID:newUID];
                            [action removePinConfigurationRangesForObjectWithUID:oldUID];
                        }
                    }
                }
            }
            [pinReferences release];

            if (accepting != nil && [accepting isKindOfClass:[HSConcreteCardObject class]]) {
                // Movies and live videos dropped on a card object are played by one action.
                HSPlayMovieAction *playAction = nil;
                for (id pasted in [[[objects copy] autorelease] objectEnumerator]) {
                    if (playAction == nil) {
                        playAction = [HSPlayMovieAction new];
                    }
                    id playbackItem;
                    id source;
                    if ([pasted implementsHyperInterface:@protocol(HSLiveObjectAttributes)]) {
                        source = [pasted queryHyperInterface:@protocol(HSLiveObjectAttributes)];
                        playbackItem = [[HSLiveVideoPlaybackItem alloc] initWithLiveObject:source playMovieAction:playAction];
                        [playAction addLiveVideo:playbackItem];
                    } else if ([pasted implementsHyperInterface:@protocol(HSMovieObjectAttributes)]) {
                        source = [pasted queryHyperInterface:@protocol(HSMovieObjectAttributes)];
                        playbackItem = [[HSMoviePlaybackItem alloc] initWithMovieObject:source playMovieAction:playAction];
                        [playAction addMovie:playbackItem];
                    } else {
                        continue;
                    }
                    [playbackItem setPlayOverObjects:YES];
                    [playbackItem setEnabled:YES];
                    [playbackItem release];
                    NSRect frame = [[source queryHyperInterface:@protocol(HSGeometryAttributes)] frameBoundingRect];
                    id applier = [[source queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
                    if (applier != nil) {
                        NSSize cardSize = [[[self editorDocument] stack] hyperCardSize];
                        [applier moveFrameBoundingRectOriginTo:NSMakePoint(ceilf((cardSize.width - frame.size.width) * 0.5f), ceilf((cardSize.height - frame.size.height) * 0.5f)) withLayoutGuidingContext:nil];
                    }
                    [objects removeObject:pasted];
                }
                if ([[playAction movies] count] != 0 || [[playAction liveVideos] count] != 0) {
                    [objects addObject:playAction];
                }
                [playAction release];
            }
        }
        [ignoredUIDs release];
        hsObjectsCreated = created;
    }

afterObjects:
    if (created) {
        goto urlCheck;
    }
filenames:
    if (error != nil) {
        goto urlCheck;
    }
    if (![[aPasteboard types] containsObject:NSFilenamesPboardType] && ![[aPasteboard types] containsObject:@"CorePasteboardFlavorType 0x6974756E"]) {
        goto urlCheck;
    }
    {
        id files = [[aPasteboard types] containsObject:NSFilenamesPboardType] ? [aPasteboard propertyListForType:NSFilenamesPboardType] : [[self class] iTunesSpecificFilenamesFromPasteboard:aPasteboard];
        NSMutableArray *found = [NSMutableArray array];
        NSEnumerator *fileEnumerator = [files objectEnumerator];
        id file;
        while ((file = [fileEnumerator nextObject]) != nil) {
            object = [self objectFromFile:file shouldImport:NO intoAcceptingObject:accepting runAnimationMode:[files count] == 1 ? aMode : NULL error:&error dragOperation:aOperation useDragPreferences:aPreferences];
            if (error != nil || object == nil) {
                break;
            }
            [found addObject:object];
            if (aObject2 != NULL) {
                *aObject2 = YES;
            }
        }
        if (error == nil && [found count] != 0) {
            [objects addObjectsFromArray:found];
            if (aObject2 != NULL) {
                *aObject2 = YES;
            }
            created = YES;
        }
    }

urlCheck:
    hasURL = [[aPasteboard types] containsObject:NSURLPboardType];
    if (created || !hasURL || ![[aPasteboard types] containsObject:@"HSLibraryiPhotoPboardType"] || error != nil) {
        goto notIPhoto;
    }
    path = [[NSURL URLFromPasteboard:aPasteboard] path];
    object = [self objectFromFile:path shouldImport:NO intoAcceptingObject:accepting runAnimationMode:NULL error:&error dragOperation:aOperation useDragPreferences:aPreferences];
    if (error != nil || object == nil) {
        goto notIPhoto;
    }
    [objects addObject:object];
    created = YES;
    goto afterIPhoto;

notIPhoto:
    if (!created) {
        goto urlFile;
    }
afterIPhoto:
    if (!hsObjectsCreated || !created) {
        goto media;
    }
urlFile:
    if (!hasURL) {
        goto media;
    }
    if (error != nil) {
        goto media;
    }
    {
        NSURL *url = [NSURL URLFromPasteboard:aPasteboard];
        path = nil;
        media = nil;
        if ([url isFileURL]) {
            path = [url path];
            if (path != nil && [[NSFileManager defaultManager] fileExistsAtPath:path] && [[HSEditorController sharedDocumentController] canImportFileAtPath:path showAlert:YES]) {
                media = [self mediaWithPath:path];
            }
        }
        if (aMode == NULL) {
            animation = NO;
        } else {
            animation = path != nil && [HSLibraryContentHelper shouldFileBeCreatedAsAnimationAtPath:path];
            *aMode = animation;
        }
        if (media == nil || created) {
            goto media;
        }
        BOOL addAction = NO;
        if (accepting != nil && ![accepting implementsHyperInterface:@protocol(HSCardAttributes)]) {
            addAction = [media mediaGroup] == 2;
        } else {
            addAction = YES;
        }
        if (addAction) {
            id action = [[self editorDocument] userActionWithMedia:media error:&error];
            if (action != nil && [self canAddAction:action intoObject:accepting] && !([self isLockedObject:accepting] || animation)) {
                [objects addObject:action];
                if (aObject2 != NULL) {
                    *aObject2 = YES;
                }
                created = YES;
                goto media;
            }
        }
        if (![[HSNewMediaAccessor supportedMediaTypes] containsObject:[media mediaType]]) {
            goto media;
        }
        object = [HSEditorDocument userObjectWithMedia:media animation:animation error:&error];
        if (object == nil) {
            goto media;
        }
        if ([aPasteboard stringForType:NSStringPboardType] != nil) {
            [[object queryHyperInterface:@protocol(HSObjectAttributes)] setHyperName:[aPasteboard stringForType:NSStringPboardType]];
        }
        [objects addObject:object];
        if (aObject2 != NULL) {
            *aObject2 = YES;
        }
        created = YES;
    }

media:
    if (!created && [[aPasteboard types] containsObject:QTMoviePasteboardType] && error == nil) {
        if (NSAppKitVersionNumber >= 1038.0 || [aPasteboard canReadItemWithDataConformingToTypes:[NSArray arrayWithObjects:QTMoviePasteboardType, nil]]) {
            QTMovie *movie = [QTMovie movieWithPasteboard:aPasteboard error:&error];
            if (movie != nil) {
                NSData *movieData = [movie movieFormatRepresentation];
                id name = [[movie movieAttributes] objectForKey:QTMovieDisplayNameAttribute];
                if ([NSNull null] == name) {
                    name = nil;
                }
                media = [HSNewMedia mediaWithData:movieData name:name type:@"mov"];
                object = [[[HSMovieObject alloc] initWithMedia:media error:&error] autorelease];
                if (object != nil) {
                    [objects addObject:object];
                    if (aObject2 != NULL) {
                        *aObject2 = YES;
                    }
                    created = YES;
                }
            }
        }
    }

    imageCanInit = [NSImage canInitWithPasteboard:aPasteboard];
    if (imageCanInit || created) {
        goto afterText;
    }
    if (![[aPasteboard types] containsObject:NSRTFPboardType] && ![[aPasteboard types] containsObject:@"HSSerializedRichTextPasteboardType"] && ![[aPasteboard types] containsObject:NSRTFDPboardType]) {
        if (hasURL || ![[aPasteboard types] containsObject:NSStringPboardType]) {
            goto afterText;
        }
    }
    if (error != nil) {
        goto afterText;
    }
    {
        id text = [[self stringFromPasteboard:aPasteboard] retain];
        if (text != nil) {
            if (aPreferences && [self stringIsURL:[text string]] && ![self isLockedObject:accepting]) {
                id action = [HSGoToURLAction actionWithURL:[NSURL URLWithString:[text string]]];
                [objects addObject:action];
                if (aObject2 != NULL) {
                    *aObject2 = YES;
                }
                created = YES;
            } else {
                id permitted = [[[[self editorDocument] editorWindowController] cardView] stringOfPermittedLengthFromString:text];
                if (permitted != nil) {
                    object = [HSEditorDocument userObjectWithAttributedString:permitted];
                    if (object != nil) {
                        [objects addObject:object];
                        if (aObject2 != NULL) {
                            *aObject2 = YES;
                        }
                        error = nil;
                    }
                }
            }
            [text release];
        }
    }

afterText:
    if (created) {
        [self cashedImageDataFromRTFDPasteboard:aPasteboard];
        goto releaseCache;
    }
    if ([[aPasteboard types] containsObject:@"BTArchivedImageRegionPboardType"]) {
        id node = [self archivedImageRegionNodeFromPasteboard:aPasteboard];
        if (node != nil) {
            [objects addObject:node];
            error = nil;
            [self cashedImageDataFromRTFDPasteboard:aPasteboard];
            created = YES;
            goto releaseCache;
        }
    }
    if ([[aPasteboard types] containsObject:@"HSCardsIndexPasteboardType"]) {
        id indexes = [aPasteboard propertyListForType:@"HSCardsIndexPasteboardType"];
        if ([indexes count] != 0) {
            NSUInteger cardIndex = [[indexes objectAtIndex:0] unsignedIntValue];
            id destinationUID = [[[[_dragHost cardForDragHost] hyperParent] hyperChildAtIndex:cardIndex] hyperUID];
            id action = [HSOtherCardAction new];
            [action setDestinationCardUID:destinationUID];
            [action setTransition:[HSTransition transitionWithName:@"Fade"]];
            [[action transition] setDuration:HSMinTransitionDuration + HSMinTransitionDuration];
            if (accepting == nil) {
                accepting = [_dragHost cardForDragHost];
            }
            id actor = [accepting queryHyperInterface:@protocol(HSActor)];
            [actor addHyperAction:action forEvent:[HSActionEvent actionEventOfType:kHSClickActionEventType]];
            [action release];
            [self cashedImageDataFromRTFDPasteboard:aPasteboard];
            created = YES;
            goto releaseCache;
        }
    }
    {
        id imageData = [self cashedImageDataFromRTFDPasteboard:aPasteboard];
        if (created || (imageData == nil && !imageCanInit) || error != nil) {
            goto releaseCache;
        }
        id string = [[aPasteboard types] containsObject:NSStringPboardType] ? [aPasteboard stringForType:NSStringPboardType] : [NSString string];
        id lastComponent = [string lastPathComponent];
        id name = [lastComponent length] == 0 ? string : lastComponent;
        if (imageData == nil) {
            imageData = [aPasteboard dataForType:NSPDFPboardType];
        }
        id extension = [name pathExtension];
        id image = nil;
        if (imageData == nil) {
            image = [[[NSImage alloc] initWithPasteboard:aPasteboard] autorelease];
            media = nil;
        } else if ([[NSImage imageFileTypes] containsObject:extension]) {
            media = [HSNewMedia mediaWithData:imageData name:name type:extension];
            image = media;
        } else {
            image = [[[NSImage alloc] initWithData:imageData] autorelease];
            media = nil;
        }
        if (media == nil) {
            if (image == nil) {
                goto releaseCache;
            }
            if ([string hasPrefix:@"http://maps.google.com/?"]) {
                NSSize imageSize = [image size];
                if (imageSize.width * imageSize.height <= 1.0) {
                    goto releaseCache;
                }
            }
            media = [HSNewMedia mediaWithImage:image];
        }
        if (media == nil) {
            goto releaseCache;
        }
        object = [HSEditorDocument userObjectWithMedia:media];
        if (object == nil) {
            goto releaseCache;
        }
        if ([object implementsHyperInterface:@protocol(HSImageObjectAttributes)]) {
            [[object queryHyperInterface:@protocol(HSMutableShadowAttributes)] setHyperShadowEnabled:NO];
        }
        [objects addObject:object];
        if (aObject2 != NULL) {
            *aObject2 = YES;
        }
        error = nil;
        created = YES;
    }

releaseCache:
    [_cashedImageDataFromRTFDPasteboard release];
    _cashedImageDataFromRTFDPasteboard = nil;
    if (created) {
        goto finish;
    }
    if (error == nil && hasURL) {
        if (![self isLockedObject:accepting]) {
            id action = [HSGoToURLAction new];
            [[action currentAction] setURL:[NSURL URLFromPasteboard:aPasteboard]];
            [objects addObject:action];
            [action autorelease];
            if (aObject2 != NULL) {
                *aObject2 = YES;
            }
            created = YES;
            goto finish;
        }
    }
    if (error == nil) {
        BOOL onCard = accepting == nil || [accepting implementsHyperInterface:@protocol(HSCardAttributes)];
        [self presentDropErrorInWindow:[_dragHost window] dropOnCard:onCard];
        [objects removeAllObjects];
        return created;
    }

finish:
    if ([objects count] != 0) {
        id url = [HSEditorCardViewDragHelper URLFromPasteboard:aPasteboard];
        id comments = url != nil ? [[self class] commentsForDroppedObjectWithURL:url] : nil;
        if ([comments length] != 0) {
            BOOL needsCardComments = YES;
            enumerator = [objects objectEnumerator];
            id pasted;
            while ((pasted = [enumerator nextObject]) != nil) {
                id commentsAttributes = [pasted queryHyperInterface:@protocol(HSCommentsAttributes)];
                if (commentsAttributes != nil) {
                    needsCardComments = NO;
                    if ([[commentsAttributes hyperComments] length] == 0) {
                        [commentsAttributes setHyperComments:comments];
                    }
                } else if ([pasted queryHyperInterface:@protocol(HSOpenLocationActionAttributes)] != nil) {
                    needsCardComments = NO;
                }
            }
            if (needsCardComments) {
                id target = accepting != nil ? accepting : [_dragHost cardForDragHost];
                id commentsAttributes = [target queryHyperInterface:@protocol(HSCommentsAttributes)];
                if (commentsAttributes != nil) {
                    [commentsAttributes appendHyperComments:comments];
                }
            }
        }
        if (aObjects != NULL) {
            *aObjects = objects;
        }
    }
    return created;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ed138 @ 001ed138, 6600 bytes * /

/* WARNING: Removing unreachable block (ram,0x001ed900) * /
/* WARNING: Removing unreachable block (ram,0x001ed909) * /
/* WARNING: Removing unreachable block (ram,0x001edd5b) * /
/* WARNING: Removing unreachable block (ram,0x001edb42) * /
/* WARNING: Removing unreachable block (ram,0x001ed9d5) * /
/* WARNING: Removing unreachable block (ram,0x001ed802) * /
/* WARNING: Removing unreachable block (ram,0x001ed914) * /
/* WARNING: Recovered jumptable eliminated as dead code * /

id FUN_001ed138(HSEditorCardViewDragHelper *self,SEL _cmd,id archivedImageRegionNodeFromPasteboard)

{
  undefined *puVar1;
  char cVar2;
  id pvVar3;
  char *pcVar4;
  int iVar5;
  id pvVar6;
  id pvVar7;
  float extraout_EDX;
  float extraout_EDX_00;
  float extraout_EDX_01;
  float *pfVar8;
  longdouble lVar9;
  longdouble lVar10;
  float fVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  float fVar20;
  id local_1a4;
  char local_60 [80];
  
  pvVar3 = _objc_msgSend(archivedImageRegionNodeFromPasteboard,sel_types);
  pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_);
  if ((char)pvVar3 != '\0') {
    pvVar3 = _objc_msgSend(archivedImageRegionNodeFromPasteboard,sel_dataForType_);
    builtin_strncpy(local_60 + 0x14,"-1.0",5);
    builtin_strncpy(local_60 + 0x10,"hive",4);
    builtin_strncpy(local_60 + 0xc,"nArc",4);
    builtin_strncpy(local_60 + 8,"egio",4);
    builtin_strncpy(local_60 + 4,"ageR",4);
    builtin_strncpy(local_60,"BTIm",4);
    pcVar4 = _objc_msgSend(pvVar3,sel_bytes);
    iVar5 = _strncmp(pcVar4,local_60,0x19);
    if (iVar5 == 0) {
      fVar20 = *(float *)PTR_00336090;
      fVar17 = *(float *)(PTR_00336090 + 4);
      fVar19 = *(float *)(PTR_00336090 + 8);
      fVar15 = *(float *)(PTR_00336090 + 0xc);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      fVar11 = 0.0;
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      fVar12 = 0.0;
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      fVar13 = 0.0;
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      fVar14 = 0.0;
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
      pvVar3 = _objc_msgSend(self,sel_decodeDataObjectFromData_offset_);
      if (pvVar3 != (id)0x0) {
        pvVar3 = (id)_CFStringCreateFromExternalRepresentation();
        pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
        if ((pvVar3 != (id)0x0) &&
           (pvVar3 = _objc_msgSend(self,sel_decodeDataObjectFromData_offset_), pvVar3 != (id)0x0)) {
          pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc);
          pvVar3 = _objc_msgSend(pvVar3,sel_initWithData_);
          local_1a4 = _objc_msgSend(pvVar3,sel_autorelease);
          if ((local_1a4 != (id)0x0) && (iVar5 = _CGPathCreateMutable(), iVar5 != 0)) {
            _objc_msgSend(self,sel_decodeValueOfObjCType_at_fromData_offset_);
            _CGPathGetBoundingBox();
            pfVar8 = (float *)&stack0xfffffe00;
            _CGPathRelease();
            cVar2 = _CGAffineTransformEqualToTransform();
            if (cVar2 == '\0') {
              _CGAffineTransformInvert();
              _hypotf();
              _hypotf();
              _CGAffineTransformInvert();
              pfVar8 = (float *)&stack0xfffffdf8;
              lVar9 = (longdouble)_roundf();
              lVar10 = (longdouble)_roundf();
              fVar16 = (float)lVar10;
              pvVar3 = _objc_msgSend(cls_NSImage,sel_alloc);
              fVar12 = (float)lVar9;
              pvVar3 = _objc_msgSend(pvVar3,sel_initWithSize_);
              pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
              _objc_msgSend(pvVar3,sel_lockFocus);
              pvVar6 = _objc_msgSend(cls_NSGraphicsContext,sel_currentContext);
              _objc_msgSend(pvVar6,sel_graphicsPort);
              _CGContextConcatCTM();
              _objc_msgSend(local_1a4,sel_drawInRect_fromRect_operation_fraction_);
              _objc_msgSend(pvVar3,sel_unlockFocus);
              if ((fVar12 != 0.0) || (NAN(fVar12))) {
                fVar19 = fVar19 / fVar12;
              }
              else {
                fVar19 = 1.0;
              }
              if ((fVar16 != 0.0) || (NAN(fVar16))) {
                fVar15 = fVar15 / fVar16;
              }
              else {
                fVar15 = 1.0;
              }
              fVar11 = fVar19 * 0.0 + 0.0;
              fVar12 = fVar19 * 0.0 + 0.0;
              fVar20 = fVar20 - fVar19 * 0.0;
              fVar13 = fVar15 * 0.0 + 0.0;
              fVar14 = fVar15 * 0.0 + 0.0;
              fVar17 = fVar17 - fVar15 * 0.0;
              fVar19 = fVar17 * 0.0 + fVar20 * 0.0 + 0.0 + fVar13 * fVar16;
              pvVar6 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
              pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_);
              _objc_msgSend(pvVar6,sel_size);
              fVar20 = extraout_EDX - (fVar17 * 0.0 + fVar20 * 0.0 + 0.0 + fVar14 * fVar16);
              local_1a4 = pvVar3;
            }
            else {
              fVar19 = fVar15 * 0.0 + fVar20 * 0.0 + fVar17 * 0.0 + 0.0;
              pvVar3 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
              pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_);
              _objc_msgSend(pvVar3,sel_size);
              fVar20 = extraout_EDX_00 - (fVar15 * 0.0 + fVar20 * 0.0 + fVar17 * 0.0 + 0.0);
            }
            pfVar8[1] = (float)sel_hyperPixelsSize;
            *pfVar8 = (float)local_1a4;
            pfVar8[-1] = 2.838071e-39;
            pvVar3 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
            pfVar8[1] = -fVar12;
            *pfVar8 = fVar11;
            pfVar8[-1] = 2.838233e-39;
            lVar9 = (longdouble)_hypotf();
            pfVar8[1] = --fVar14;
            *pfVar8 = -fVar13;
            fVar17 = (float)lVar9;
            pfVar8[-1] = 2.838287e-39;
            lVar9 = (longdouble)_hypotf();
            fVar15 = (float)lVar9;
            if ((fVar15 != 0.0) || (NAN(fVar15))) {
              fVar16 = 1.0 / fVar15;
            }
            else {
              fVar16 = 1.0;
            }
            if ((fVar17 != 0.0) || (NAN(fVar17))) {
              fVar18 = 1.0 / fVar17;
            }
            else {
              fVar18 = 1.0;
            }
            pfVar8[1] = (float)sel_types;
            *pfVar8 = (float)archivedImageRegionNodeFromPasteboard;
            pfVar8[-1] = 2.838697e-39;
            pvVar6 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
            puVar1 = PTR_003361bc;
            pfVar8[2] = *(float *)PTR_003361bc;
            pfVar8[1] = (float)sel_containsObject_;
            *pfVar8 = (float)pvVar6;
            pfVar8[-1] = 2.838806e-39;
            pvVar6 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
            if ((char)pvVar6 == '\0') {
              pvVar6 = (id)0x0;
            }
            else {
              pfVar8[2] = *(float *)puVar1;
              pfVar8[1] = (float)sel_stringForType_;
              *pfVar8 = (float)archivedImageRegionNodeFromPasteboard;
              pfVar8[-1] = 2.838856e-39;
              pvVar6 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
            }
            pfVar8[1] = (float)sel_lastPathComponent;
            *pfVar8 = (float)pvVar6;
            pfVar8[-1] = 2.838881e-39;
            pvVar6 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
            pfVar8[3] = (float)pvVar6;
            pfVar8[2] = (float)local_1a4;
            pfVar8[1] = (float)sel_mediaWithImage_name_;
            *pfVar8 = (float)cls_HSNewMedia;
            pfVar8[-1] = 2.838934e-39;
            pvVar6 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
            if (pvVar6 != (id)0x0) {
              pfVar8[2] = (float)pvVar6;
              pfVar8[1] = (float)sel_userObjectWithMedia_;
              *pfVar8 = (float)cls_HSEditorDocument;
              pfVar8[-1] = 2.838984e-39;
              pvVar6 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
              pfVar8[2] = (float)&DAT_00380564;
              pfVar8[1] = (float)sel_queryHyperInterface_;
              *pfVar8 = (float)pvVar6;
              pfVar8[-1] = 2.839026e-39;
              pvVar7 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
              pfVar8[1] = (float)sel_setShadowEnabled_;
              *pfVar8 = (float)pvVar7;
              pfVar8[2] = 0.0;
              pfVar8[-1] = 2.839063e-39;
              _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
              if (pvVar6 == (id)0x0) {
                return (id)0x0;
              }
              pfVar8[2] = (float)&DAT_0037fcb8;
              pfVar8[1] = (float)sel_queryHyperInterface_;
              *pfVar8 = (float)pvVar6;
              pfVar8[-1] = 2.839113e-39;
              pvVar7 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
              pfVar8[1] = (float)sel_queryGeometryBehaviorApplier;
              *pfVar8 = (float)pvVar7;
              pfVar8[-1] = 2.839139e-39;
              pvVar7 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
              *(ulonglong *)(pfVar8 + 8) = CONCAT44(fVar20,fVar19);
              *(ulonglong *)(pfVar8 + 6) = CONCAT44(--fVar14 * fVar16,-fVar13 * fVar16);
              *(ulonglong *)(pfVar8 + 4) = CONCAT44(-fVar12 * fVar18,fVar11 * fVar18);
              pfVar8[3] = extraout_EDX_01 * fVar15;
              pfVar8[2] = (float)pvVar3 * fVar17;
              pfVar8[1] = (float)
                          sel_setSize_affineTransform_flippedHorizontally_withLayoutGuidingContext_;
              *pfVar8 = (float)pvVar7;
              pfVar8[0xb] = 0.0;
              pfVar8[10] = 0.0;
              pfVar8[-1] = 2.839284e-39;
              _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
              pfVar8[2] = (float)pvVar6;
              pfVar8[1] = (float)sel_cropApplierForImageObject_;
              *pfVar8 = (float)cls_HSImageCropApplier;
              pfVar8[-1] = 2.839324e-39;
              pvVar3 = _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
              pfVar8[1] = (float)sel_updateCurrentBorderPath;
              *pfVar8 = (float)pvVar3;
              pfVar8[-1] = 2.839349e-39;
              _objc_msgSend((id)*pfVar8,(SEL)pfVar8[1]);
              return pvVar6;
            }
          }
        }
      }
    }
  }
  return (id)0x0;
}

*/
- (id)archivedImageRegionNodeFromPasteboard:(id)aPasteboard
{
    if (![[aPasteboard types] containsObject:@"BTArchivedImageRegionPboardType"]) {
        return nil;
    }
    NSData *data = [aPasteboard dataForType:@"BTArchivedImageRegionPboardType"];
    char header[25] = "BTImageRegionArchive-1.0";
    if (strncmp([data bytes], header, 0x19) != 0) {
        return nil;
    }
    unsigned int offset = 0x19;
    double value;
    CGRect imageRect = CGRectZero;
    CGRect pathBounds = CGRectZero;
    CGAffineTransform archiveTransform = CGAffineTransformIdentity;
    CGAffineTransform placementTransform = CGAffineTransformIdentity;
    CGFloat *rectValues[4] = { &imageRect.origin.x, &imageRect.origin.y, &imageRect.size.width, &imageRect.size.height };
    for (int i = 0; i < 4; i++) {
        value = 0;
        [self decodeValueOfObjCType:"d" at:&value fromData:data offset:&offset];
        *rectValues[i] = value;
    }
    CGFloat *archiveValues[6] = { &archiveTransform.a, &archiveTransform.b, &archiveTransform.c, &archiveTransform.d, &archiveTransform.tx, &archiveTransform.ty };
    for (int i = 0; i < 6; i++) {
        value = 0;
        [self decodeValueOfObjCType:"d" at:&value fromData:data offset:&offset];
        *archiveValues[i] = value;
    }
    CGFloat *placementValues[6] = { &placementTransform.a, &placementTransform.b, &placementTransform.c, &placementTransform.d, &placementTransform.tx, &placementTransform.ty };
    for (int i = 0; i < 6; i++) {
        value = 0;
        [self decodeValueOfObjCType:"d" at:&value fromData:data offset:&offset];
        *placementValues[i] = value;
    }
    offset++;
    NSData *nameData = [self decodeDataObjectFromData:data offset:&offset];
    if (nameData == nil) {
        return nil;
    }
    NSString *name = [(NSString *)CFStringCreateFromExternalRepresentation(kCFAllocatorDefault, (CFDataRef)nameData, kCFStringEncodingUTF8) autorelease];
    if (name == nil) {
        return nil;
    }
    NSData *imageData = [self decodeDataObjectFromData:data offset:&offset];
    if (imageData == nil) {
        return nil;
    }
    NSImage *image = [[[NSImage alloc] initWithData:imageData] autorelease];
    if (image == nil) {
        return nil;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    if (path == NULL) {
        return nil;
    }
    unsigned char element;
    for (;;) {
        element = 0;
        [self decodeValueOfObjCType:"C" at:&element fromData:data offset:&offset];
        if (element == 0) {
            break;
        }
        double p[6] = { 0, 0, 0, 0, 0, 0 };
        int count = 0;
        switch (element) {
            case 1: count = 2; break;
            case 2: count = 2; break;
            case 3: count = 4; break;
            case 4: count = 6; break;
            default: break;
        }
        for (int i = 0; i < count; i++) {
            [self decodeValueOfObjCType:"d" at:&p[i] fromData:data offset:&offset];
        }
        switch (element) {
            case 1: CGPathMoveToPoint(path, NULL, p[0], p[1]); break;
            case 2: CGPathAddLineToPoint(path, NULL, p[0], p[1]); break;
            case 3: CGPathAddQuadCurveToPoint(path, NULL, p[0], p[1], p[2], p[3]); break;
            case 4: CGPathAddCurveToPoint(path, NULL, p[0], p[1], p[2], p[3], p[4], p[5]); break;
            case 5: CGPathCloseSubpath(path); break;
            default: break;
        }
    }
    pathBounds = CGPathGetBoundingBox(path);
    CGPathRelease(path);
    CGAffineTransform placement;
    NSImage *finalImage = image;
    NSSize cardSize;
    if (CGAffineTransformEqualToTransform(archiveTransform, placementTransform)) {
        CGAffineTransform b = placementTransform;
        placement.a = b.a;
        placement.b = b.b;
        placement.c = -b.c;
        placement.d = -b.d;
        placement.tx = b.a * pathBounds.origin.x + b.c * pathBounds.origin.y + b.tx + b.c * pathBounds.size.height;
        placement.ty = b.b * pathBounds.origin.x + b.d * pathBounds.origin.y + b.ty + b.d * pathBounds.size.height;
    } else {
        CGAffineTransform b = placementTransform;
        CGAffineTransform inverse = CGAffineTransformInvert(archiveTransform);
        CGAffineTransform combined = CGAffineTransformConcat(b, inverse);
        CGFloat scaleX = hypot(combined.a, combined.b);
        CGFloat scaleY = hypot(combined.c, combined.d);
        CGFloat invScaleX = (scaleX == 0.0) ? 1.0 : 1.0 / scaleX;
        CGFloat invScaleY = (scaleY == 0.0) ? 1.0 : 1.0 / scaleY;
        CGAffineTransform normalized = CGAffineTransformMake(combined.a * invScaleX, combined.b * invScaleX, combined.c * invScaleY, combined.d * invScaleY, combined.tx, combined.ty);
        CGAffineTransform drawTransform = CGAffineTransformInvert(normalized);
        drawTransform.tx -= pathBounds.origin.x * scaleX;
        drawTransform.ty -= pathBounds.origin.y * scaleY;
        CGFloat newWidth = round(scaleX * pathBounds.size.width);
        CGFloat newHeight = round(scaleY * pathBounds.size.height);
        NSImage *rendered = [[[NSImage alloc] initWithSize:NSMakeSize(newWidth, newHeight)] autorelease];
        [rendered lockFocus];
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextConcatCTM(context, drawTransform);
        [image drawInRect:NSRectFromCGRect(imageRect) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1.0];
        [rendered unlockFocus];
        CGFloat fx = (newWidth == 0.0) ? 1.0 : pathBounds.size.width / newWidth;
        CGFloat fy = (newHeight == 0.0) ? 1.0 : pathBounds.size.height / newHeight;
        placement.a = fx * b.a;
        placement.b = fx * b.b;
        placement.c = -(fy * b.c);
        placement.d = -(fy * b.d);
        placement.tx = pathBounds.origin.x * b.a + pathBounds.origin.y * b.c + b.tx + newHeight * (fy * b.c);
        placement.ty = pathBounds.origin.x * b.b + pathBounds.origin.y * b.d + b.ty + newHeight * (fy * b.d);
        finalImage = rendered;
    }
    cardSize = [[[_dragHost cardForDragHost] queryHyperInterface:@protocol(HSSizeAttributes)] size];
    CGAffineTransform flipped;
    flipped.a = placement.a;
    flipped.b = -placement.b;
    flipped.c = placement.c;
    flipped.d = -placement.d;
    flipped.tx = placement.tx;
    flipped.ty = cardSize.height - placement.ty;
    NSSize pixelsSize = [finalImage hyperPixelsSize];
    CGFloat scaleX = hypot(flipped.a, flipped.b);
    CGFloat scaleY = hypot(flipped.c, flipped.d);
    CGFloat invScaleX = (scaleX == 0.0) ? 1.0 : 1.0 / scaleX;
    CGFloat invScaleY = (scaleY == 0.0) ? 1.0 : 1.0 / scaleY;
    CGAffineTransform objectTransform = CGAffineTransformMake(flipped.a * invScaleX, flipped.b * invScaleX, flipped.c * invScaleY, flipped.d * invScaleY, flipped.tx, flipped.ty);
    NSString *mediaName = nil;
    if ([[aPasteboard types] containsObject:NSStringPboardType]) {
        mediaName = [aPasteboard stringForType:NSStringPboardType];
    }
    id media = [HSNewMedia mediaWithImage:finalImage name:[mediaName lastPathComponent]];
    if (media == nil) {
        return nil;
    }
    id imageObject = [HSEditorDocument userObjectWithMedia:media];
    [[imageObject queryHyperInterface:@protocol(HSShadowAttributes)] setShadowEnabled:NO];
    if (imageObject == nil) {
        return nil;
    }
    [[[imageObject queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier] setSize:NSMakeSize(pixelsSize.width * scaleX, pixelsSize.height * scaleY) affineTransform:objectTransform flippedHorizontally:NO withLayoutGuidingContext:nil];
    [[HSImageCropApplier cropApplierForImageObject:imageObject] updateCurrentBorderPath];
    return imageObject;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e4a79 @ 001e4a79, 2804 bytes * /

id FUN_001e4a79(HSEditorCardViewDragHelper *self,SEL _cmd,id objectFromFile,BOOL shouldImport,
               id intoAcceptingObject,BOOL *runAnimationMode,id *error,uint dragOperation,
               BOOL useDragPreferences)

{
  char cVar1;
  bool bVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  undefined4 extraout_EDX;
  byte bVar7;
  HSEditorCardViewDragHelper *self_00;
  double dVar8;
  undefined *puVar9;
  SEL pcVar10;
  undefined8 in_stack_ffffffdc;
  undefined8 uVar11;
  undefined4 uVar13;
  longlong lVar12;
  uint uVar14;
  id *ppvVar15;
  id local_14;
  
  uVar13 = (undefined4)((ulonglong)in_stack_ffffffdc >> 0x20);
  pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  uVar11 = CONCAT44(uVar13,objectFromFile);
  pvVar3 = _objc_msgSend(pvVar3,sel_hyperResolveAliasAtPath_,objectFromFile);
  if (pvVar3 == (id)0x0) {
    pvVar3 = objectFromFile;
  }
  pvVar4 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController,uVar11);
  uVar11 = CONCAT44(1,pvVar3);
  pvVar4 = _objc_msgSend(pvVar4,sel_canImportFileAtPath_showAlert_,pvVar3,1);
  puVar9 = cls_NSError;
  if ((char)pvVar4 == '\0') {
    if (error == (id *)0x0) {
      return (id)0x0;
    }
    pvVar3 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pvVar3,
                           *(undefined4 *)PTR_003367ac,0);
    pvVar3 = _objc_msgSend(puVar9,sel_errorWithDomain_code_userInfo_,*(undefined4 *)PTR_003361ac,
                           0x107,pvVar3);
    *error = pvVar3;
    return (id)0x0;
  }
  local_14 = (id)0x0;
  pvVar4 = _objc_msgSend(pvVar3,sel_pathExtension,uVar11);
  uVar13 = (undefined4)((ulonglong)uVar11 >> 0x20);
  pvVar5 = _objc_msgSend(pvVar4,sel_isEqualToString_,&cfstr_webloc);
  if (((char)pvVar5 == '\0') &&
     (pvVar5 = _objc_msgSend(pvVar4,sel_isEqualToString_,&cfstr_mailtoloc), (char)pvVar5 == '\0')) {
    pvVar5 = _objc_msgSend(pvVar4,sel_isEqualToString_,&cfstr_webarchive);
    if (((char)pvVar5 != '\0') ||
       (pvVar5 = _objc_msgSend(pvVar4,sel_isEqualToString_,&cfstr_html), (char)pvVar5 != '\0')) {
      lVar12 = CONCAT44(uVar13,pvVar3);
      puVar9 = cls_HSOpenLocationAction;
      pcVar10 = sel_actionWithPathToFile_;
      goto LAB_001e4cdf;
    }
    uVar11 = CONCAT44(uVar13,&cfstr_stack);
    pvVar5 = _objc_msgSend(pvVar4,sel_isEqualToString_,&cfstr_stack);
    if ((char)pvVar5 != '\0') {
      pvVar4 = _objc_msgSend(cls_HSOpenStackAction,sel_new,uVar11);
      pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
      pvVar5 = _objc_msgSend(cls_HSTransition,sel_transitionWithName_,&cfstr_Fade);
      _objc_msgSend(pvVar4,sel_setTransition_,pvVar5);
      pvVar5 = _objc_msgSend(pvVar4,sel_transition);
      dVar8 = *(double *)PTR_003365a8 + *(double *)PTR_003365a8;
      _objc_msgSend(pvVar5,sel_setDuration_,dVar8);
      uVar13 = (undefined4)((ulonglong)dVar8 >> 0x20);
LAB_001e4e19:
      pvVar3 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,pvVar3);
      lVar12 = CONCAT44(uVar13,pvVar3);
      _objc_msgSend(pvVar4,sel_setURL_,pvVar3);
      goto LAB_001e545c;
    }
    uVar11 = CONCAT44((int)((ulonglong)uVar11 >> 0x20),&cfstr_kmz);
    pvVar5 = _objc_msgSend(pvVar4,sel_isEqualToString_,&cfstr_kmz);
    if ((char)pvVar5 != '\0') {
LAB_001e4ded:
      pvVar4 = _objc_msgSend(cls_HSGoogleEarthAction,sel_new,uVar11);
      uVar13 = (undefined4)((ulonglong)uVar11 >> 0x20);
      pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
      goto LAB_001e4e19;
    }
    uVar11 = CONCAT44((int)((ulonglong)uVar11 >> 0x20),&cfstr_kml);
    pvVar5 = _objc_msgSend(pvVar4,sel_isEqualToString_,&cfstr_kml);
    if ((char)pvVar5 != '\0') goto LAB_001e4ded;
    pvVar5 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,uVar11);
    uVar13 = (undefined4)((ulonglong)uVar11 >> 0x20);
    pvVar5 = _objc_msgSend(pvVar5,sel_hyperIsTextForPath_,pvVar3);
    if ((char)pvVar5 != '\0') {
      lVar12 = CONCAT44(uVar13,intoAcceptingObject);
      pvVar5 = _objc_msgSend(self,sel_isLockedObject_,intoAcceptingObject);
      if ((char)pvVar5 != '\0') goto LAB_001e51d5;
      if (useDragPreferences != '\0') {
        pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,lVar12);
        lVar12 = CONCAT44((int)((ulonglong)lVar12 >> 0x20),*(undefined4 *)PTR_0033618c);
        pvVar4 = _objc_msgSend(pvVar4,sel_boolForKey_,*(undefined4 *)PTR_0033618c);
        if ((char)pvVar4 != '\0') goto LAB_001e5460;
      }
      puVar9 = cls_NSAttributedString;
      pvVar4 = _objc_msgSend(self,sel_zone,lVar12);
      pvVar4 = _objc_msgSend(puVar9,sel_allocWithZone_,pvVar4);
      pvVar3 = _objc_msgSend(pvVar4,sel_initWithPath_documentAttributes_,pvVar3,0);
      pvVar4 = _objc_msgSend(pvVar3,sel_autorelease);
      pvVar5 = _objc_msgSend(cls_NSAttributedString,sel_alloc);
      pvVar6 = _objc_msgSend(pvVar4,sel_length);
      pvVar3 = (id)0x0;
      pvVar4 = _objc_msgSend(pvVar4,sel_RTFFromRange_documentAttributes_,0,pvVar6,0);
      uVar14 = 0;
      pvVar4 = _objc_msgSend(pvVar5,sel_initWithRTF_documentAttributes_,pvVar4,0);
      pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
      pvVar5 = _objc_msgSend(self,sel_editorDocument);
      pvVar5 = _objc_msgSend(pvVar5,sel_editorWindowController);
      pvVar5 = _objc_msgSend(pvVar5,sel_cardView);
      pvVar4 = _objc_msgSend(pvVar5,sel_stringOfPermittedLengthFromString_,pvVar4);
      if (pvVar4 == (id)0x0) {
        lVar12 = (ulonglong)uVar14 << 0x20;
        local_14 = _objc_msgSend(cls_HSError,sel_errorWithHSCode_,&DAT_00002711);
        goto LAB_001e5460;
      }
      if ((intoAcceptingObject != (id)0x0) && (shouldImport != '\0')) {
        uVar11 = CONCAT44(uVar14,&DAT_0037f920);
        pvVar5 = _objc_msgSend(intoAcceptingObject,sel_queryHyperInterface_,&DAT_0037f920);
        if (pvVar5 == (id)0x0) {
          uVar13 = (undefined4)((ulonglong)uVar11 >> 0x20);
          intoAcceptingObject =
               _objc_msgSend(intoAcceptingObject,sel_queryHyperInterface_,&DAT_0037f934);
          lVar12 = CONCAT44(uVar13,pvVar4);
          pcVar10 = sel_setHyperText_;
        }
        else {
          pvVar3 = _objc_msgSend(pvVar5,sel_hyperSelectedRange,uVar11);
          lVar12 = CONCAT44(extraout_EDX,pvVar3);
          pcVar10 = sel_replaceTextInRange_withAttributedString_;
          pvVar3 = pvVar4;
        }
        _objc_msgSend(intoAcceptingObject,pcVar10,lVar12,pvVar3);
        goto LAB_001e5460;
      }
      uVar11 = CONCAT44(uVar14,pvVar4);
      pvVar4 = _objc_msgSend(cls_HSEditorDocument,sel_userObjectWithAttributedString_,pvVar4);
      if (useDragPreferences == '\0') {
LAB_001e5137:
        uVar13 = (undefined4)((ulonglong)uVar11 >> 0x20);
        bVar7 = 0;
      }
      else {
        pvVar3 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,uVar11);
        uVar11 = CONCAT44((int)((ulonglong)uVar11 >> 0x20),*(undefined4 *)PTR_003367a4);
        pvVar3 = _objc_msgSend(pvVar3,sel_boolForKey_,*(undefined4 *)PTR_003367a4);
        uVar13 = (undefined4)((ulonglong)uVar11 >> 0x20);
        if ((char)pvVar3 == '\0') goto LAB_001e5137;
        bVar7 = 1;
      }
      pvVar3 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037f934);
      _objc_msgSend(pvVar3,sel_setScrollable_,(int)(char)(bVar7 ^ 1));
      pvVar3 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037f934);
      lVar12 = CONCAT44(uVar13,(int)(char)bVar7);
      _objc_msgSend(pvVar3,sel_setRotatableText_,(int)(char)bVar7);
      goto LAB_001e545c;
    }
LAB_001e51d5:
    lVar12 = 0x10033800c;
    pvVar4 = _objc_msgSend(pvVar4,sel_compare_options_,&cfstr_pdf,1);
    if ((useDragPreferences == '\0') || (pvVar4 != (id)0x0)) {
LAB_001e524d:
      if (shouldImport == '\0') {
LAB_001e5273:
        lVar12 = CONCAT44((int)((ulonglong)lVar12 >> 0x20),pvVar3);
        self_00 = self;
        pcVar10 = sel_mediaWithPath_;
      }
      else {
        lVar12 = CONCAT44((int)((ulonglong)lVar12 >> 0x20),pvVar3);
        pvVar4 = _objc_msgSend(self,sel_isAnimatedGifMovieAtPath_,pvVar3);
        self_00 = (HSEditorCardViewDragHelper *)cls_HSNewMedia;
        if ((char)pvVar4 == '\0') goto LAB_001e5273;
        pvVar4 = _objc_msgSend(cls_NSImage,sel_alloc,lVar12);
        uVar13 = (undefined4)((ulonglong)lVar12 >> 0x20);
        pvVar4 = _objc_msgSend(pvVar4,sel_initWithContentsOfFile_,pvVar3);
        pvVar4 = _objc_msgSend(pvVar4,sel_autorelease);
        lVar12 = CONCAT44(uVar13,pvVar4);
        pcVar10 = sel_mediaWithImage_;
      }
      pvVar5 = _objc_msgSend(self_00,pcVar10,lVar12);
      if (pvVar5 != (id)0x0) {
        uVar11 = CONCAT44((int)((ulonglong)lVar12 >> 0x20),pvVar3);
        pvVar3 = _objc_msgSend(cls_HSLibraryContentHelper,sel_shouldFileBeCreatedAsAnimationAtPath_,
                               pvVar3);
        cVar1 = (char)pvVar3;
        if (cVar1 == '\0') {
          pvVar3 = _objc_msgSend(self,sel_editorDocument,uVar11);
          uVar11 = CONCAT44(&local_14,pvVar5);
          pvVar4 = _objc_msgSend(pvVar3,sel_userActionWithMedia_error_,pvVar5,&local_14);
          pvVar3 = intoAcceptingObject;
          if ((shouldImport != '\0') && (intoAcceptingObject == (id)0x0)) {
            pvVar3 = _objc_msgSend(self,sel_defaultAcceptingObject,uVar11);
          }
          pvVar6 = _objc_msgSend(self,sel_canAddAction_intoObject_,pvVar4,pvVar3);
          if ((char)pvVar6 == '\0') goto LAB_001e53bf;
          lVar12 = CONCAT44(pvVar3,intoAcceptingObject);
          pvVar3 = _objc_msgSend(self,sel_isLockedObject_,intoAcceptingObject);
          if (((char)pvVar3 != '\0') || (pvVar4 == (id)0x0)) goto LAB_001e53bf;
        }
        else {
LAB_001e53bf:
          ppvVar15 = &local_14;
          bVar2 = dragOperation == 1 || (cVar1 == '\0' || runAnimationMode == (BOOL *)0x0);
          uVar14 = bVar2 ^ 1;
          pvVar4 = _objc_msgSend(cls_HSEditorDocument,sel_userObjectWithMedia_animation_error_,
                                 pvVar5,bVar2 ^ 1,ppvVar15);
          lVar12 = (ulonglong)uVar14 << 0x20;
          pvVar3 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037fb3c);
          if (pvVar3 != (id)0x0) {
            uVar14 = (uint)((ulonglong)lVar12 >> 0x20);
            lVar12 = (ulonglong)uVar14 << 0x20;
            _objc_msgSend(pvVar3,sel_setHyperStartingOnClick_,0,uVar14,ppvVar15);
          }
        }
        if (runAnimationMode != (BOOL *)0x0) {
          *runAnimationMode = cVar1 != '\0' && dragOperation != 1;
        }
        goto LAB_001e545c;
      }
    }
    else {
      pvVar4 = _objc_msgSend(cls_NSUserDefaults,sel_standardUserDefaults,lVar12);
      lVar12 = CONCAT44((int)((ulonglong)lVar12 >> 0x20),*(undefined4 *)PTR_0033618c);
      pvVar4 = _objc_msgSend(pvVar4,sel_boolForKey_,*(undefined4 *)PTR_0033618c);
      if (((char)pvVar4 == '\0') || (useDragPreferences == '\0')) goto LAB_001e524d;
    }
  }
  else {
    pvVar3 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithContentsOfFile_,objectFromFile);
    pvVar3 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_URL);
    pvVar4 = _objc_msgSend(cls_NSString,sel_class);
    lVar12 = CONCAT44(uVar13,pvVar4);
    pvVar4 = _objc_msgSend(pvVar3,sel_isKindOfClass_,pvVar4);
    puVar9 = cls_HSGoToURLAction;
    if ((char)pvVar4 == '\0') goto LAB_001e5460;
    uVar13 = (undefined4)((ulonglong)lVar12 >> 0x20);
    pvVar3 = _objc_msgSend(cls_NSURL,sel_URLWithString_,pvVar3);
    lVar12 = CONCAT44(uVar13,pvVar3);
    pcVar10 = sel_actionWithURL_;
LAB_001e4cdf:
    pvVar4 = _objc_msgSend(puVar9,pcVar10,lVar12);
LAB_001e545c:
    uVar13 = (undefined4)((ulonglong)lVar12 >> 0x20);
    if (pvVar4 != (id)0x0) {
      if ((local_14 != (id)0x0) && (error != (id *)0x0)) {
        *error = local_14;
        pvVar4 = (id)0x0;
      }
      goto LAB_001e5499;
    }
  }
LAB_001e5460:
  uVar13 = (undefined4)((ulonglong)lVar12 >> 0x20);
  pvVar4 = _objc_msgSend(cls_HSOpenLocationAction,sel_actionWithPathToFile_,objectFromFile);
LAB_001e5499:
  uVar11 = CONCAT44(uVar13,objectFromFile);
  pvVar3 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,objectFromFile);
  if (pvVar3 == (id)0x0) {
    pvVar3 = (id)0x0;
  }
  else {
    pvVar5 = _objc_msgSend(self,sel_class,uVar11);
    uVar11 = CONCAT44((int)((ulonglong)uVar11 >> 0x20),pvVar3);
    pvVar3 = _objc_msgSend(pvVar5,sel_commentsForDroppedObjectWithURL_,pvVar3);
  }
  pvVar5 = _objc_msgSend(pvVar3,sel_length,uVar11);
  if (pvVar5 != (id)0x0) {
    pvVar5 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037fb8c);
    pvVar3 = _objc_msgSend(pvVar3,sel_copy);
    pvVar3 = _objc_msgSend(pvVar3,sel_autorelease);
    _objc_msgSend(pvVar5,sel_setHyperComments_,pvVar3);
  }
  return pvVar4;
}

*/
- (id)objectFromFile:(id)aFile shouldImport:(BOOL)aImport intoAcceptingObject:(id)aObject runAnimationMode:(BOOL *)aMode error:(id *)aError dragOperation:(NSUInteger)aOperation useDragPreferences:(BOOL)aPreferences
{
    NSString *path = [[NSFileManager defaultManager] hyperResolveAliasAtPath:aFile];
    if (path == nil) {
        path = aFile;
    }
    if (![[HSEditorController sharedDocumentController] canImportFileAtPath:path showAlert:YES]) {
        if (aError != NULL) {
            *aError = [NSError errorWithDomain:NSCocoaErrorDomain code:0x107 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:path, NSFilePathErrorKey, nil]];
        }
        return nil;
    }
    id result = nil;
    NSError *localError = nil;
    NSString *extension = [path pathExtension];
    if ([extension isEqualToString:@"webloc"] || [extension isEqualToString:@"mailtoloc"]) {
        id url = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:@"URL"];
        if (![url isKindOfClass:[NSString class]]) {
            goto openLocation;
        }
        result = [HSGoToURLAction actionWithURL:[NSURL URLWithString:url]];
    } else if ([extension isEqualToString:@"webarchive"] || [extension isEqualToString:@"html"]) {
        result = [HSOpenLocationAction actionWithPathToFile:path];
    } else if ([extension isEqualToString:@"stack"]) {
        id action = [[HSOpenStackAction new] autorelease];
        [action setTransition:[HSTransition transitionWithName:@"Fade"]];
        [[action transition] setDuration:HSMinTransitionDuration * 2];
        [action setURL:[NSURL fileURLWithPath:path]];
        result = action;
    } else if ([extension isEqualToString:@"kmz"] || [extension isEqualToString:@"kml"]) {
        id action = [[HSGoogleEarthAction new] autorelease];
        [action setURL:[NSURL fileURLWithPath:path]];
        result = action;
    } else {
        if ([[NSFileManager defaultManager] hyperIsTextForPath:path] && ![self isLockedObject:aObject]) {
            if (aPreferences && [[NSUserDefaults standardUserDefaults] boolForKey:HSImportTextAsTargetForOpenThisDocumentActionKey]) {
                goto openLocation;
            }
            NSAttributedString *loaded = [[[NSAttributedString allocWithZone:[self zone]] initWithPath:path documentAttributes:NULL] autorelease];
            NSData *rtf = [loaded RTFFromRange:NSMakeRange(0, [loaded length]) documentAttributes:nil];
            NSAttributedString *text = [[[NSAttributedString alloc] initWithRTF:rtf documentAttributes:NULL] autorelease];
            text = [[[[self editorDocument] editorWindowController] cardView] stringOfPermittedLengthFromString:text];
            if (text == nil) {
                localError = [HSError errorWithHSCode:0x2711];
                goto openLocation;
            }
            if (aObject != nil && aImport) {
                id selection = [aObject queryHyperInterface:@protocol(HSTextObjectSelectionInterface)];
                if (selection != nil) {
                    [selection replaceTextInRange:[selection hyperSelectedRange] withAttributedString:text];
                } else {
                    [[aObject queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setHyperText:text];
                }
                goto openLocation;
            }
            result = [HSEditorDocument userObjectWithAttributedString:text];
            BOOL rotatable = aPreferences && [[NSUserDefaults standardUserDefaults] boolForKey:HSImportTextObjectAsRotatableKey];
            [[result queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setScrollable:!rotatable];
            [[result queryHyperInterface:@protocol(HSSystemTextViewAttributes)] setRotatableText:rotatable];
        } else {
            if (aPreferences && [extension compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame
                && [[NSUserDefaults standardUserDefaults] boolForKey:HSImportTextAsTargetForOpenThisDocumentActionKey] && aImport) {
                goto openLocation;
            }
            id media;
            if (aImport && [self isAnimatedGifMovieAtPath:path]) {
                media = [HSNewMedia mediaWithImage:[[[NSImage alloc] initWithContentsOfFile:path] autorelease]];
            } else {
                media = [self mediaWithPath:path];
            }
            if (media == nil) {
                goto openLocation;
            }
            BOOL isAnimation = [HSLibraryContentHelper shouldFileBeCreatedAsAnimationAtPath:path];
            BOOL madeAction = NO;
            if (!isAnimation) {
                id action = [[self editorDocument] userActionWithMedia:media error:&localError];
                id target = (aImport && aObject == nil) ? [self defaultAcceptingObject] : aObject;
                if ([self canAddAction:action intoObject:target] && ![self isLockedObject:aObject] && action != nil) {
                    result = action;
                    madeAction = YES;
                }
            }
            if (!madeAction) {
                BOOL animated = !(aMode == NULL || !isAnimation || aOperation == 1);
                result = [HSEditorDocument userObjectWithMedia:media animation:animated error:&localError];
                id starting = [result queryHyperInterface:@protocol(HSStartingPlayableObjectAttributes)];
                if (starting != nil) {
                    [starting setHyperStartingOnClick:NO];
                }
            }
            if (aMode != NULL) {
                *aMode = (aOperation != 1 && isAnimation);
            }
        }
    }
    if (result == nil) {
        goto openLocation;
    }
    if (localError != nil && aError != NULL) {
        *aError = localError;
        result = nil;
    }
    goto comments;
openLocation:
    result = [HSOpenLocationAction actionWithPathToFile:aFile];
comments:
    {
        NSURL *fileURL = [NSURL fileURLWithPath:aFile];
        NSString *comments = (fileURL != nil) ? [[self class] commentsForDroppedObjectWithURL:fileURL] : nil;
        if ([comments length] != 0) {
            [[result queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:[[comments copy] autorelease]];
        }
    }
    return result;
}

- (id)objectsFromPDFFile:(id)aFile firstPageOnly:(BOOL)aOnly
{
    return [self objectsFromPDFFile:aFile firstPageOnly:(unsigned int)aOnly error:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e720f @ 001e720f, 806 bytes * /

id FUN_001e720f(HSEditorCardViewDragHelper *self,SEL _cmd,id objectsFromPDFFile,BOOL firstPageOnly,
               id *error)

{
  int iVar1;
  undefined *self_00;
  id pvVar2;
  id pvVar3;
  id self_01;
  id pvVar4;
  uint uVar5;
  undefined1 *puVar6;
  id *ppvVar7;
  undefined4 uVar8;
  id local_88;
  id local_84;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
  pvVar3 = objectsFromPDFFile;
  pvVar2 = _objc_msgSend(pvVar2,sel_hyperResolveAliasAtPath_,objectsFromPDFFile);
  if (pvVar2 == (id)0x0) {
    pvVar2 = objectsFromPDFFile;
  }
  pvVar3 = _objc_msgSend(cls_HSEditorController,sel_sharedDocumentController,pvVar3);
  pvVar3 = _objc_msgSend(pvVar3,sel_canImportFileAtPath_showAlert_,pvVar2,1);
  self_00 = cls_NSError;
  if ((char)pvVar3 == '\0') {
    if (error != (id *)0x0) {
      pvVar2 = _objc_msgSend(cls_NSDictionary,sel_dictionaryWithObjectsAndKeys_,pvVar2,
                             *(undefined4 *)PTR_003367ac,0);
      pvVar2 = _objc_msgSend(self_00,sel_errorWithDomain_code_userInfo_,*(undefined4 *)PTR_003361ac,
                             0x107,pvVar2);
      *error = pvVar2;
    }
    pvVar2 = (id)0x0;
  }
  else {
    local_78 = (id)0x0;
    ppvVar7 = &local_78;
    uVar5 = (uint)(byte)firstPageOnly;
    pvVar2 = _objc_msgSend(cls_HSEditorDocument,sel_imageObjectsWithPDFMedia_firstPageOnly_error_,
                           pvVar2,uVar5,ppvVar7);
    if (((pvVar2 == (id)0x0) && (local_78 != (id)0x0)) && (error != (id *)0x0)) {
      *error = local_78;
    }
    pvVar3 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,objectsFromPDFFile,uVar5,ppvVar7);
    if (pvVar3 == (id)0x0) {
      local_88 = (id)0x0;
      pvVar3 = objectsFromPDFFile;
    }
    else {
      pvVar4 = _objc_msgSend(self,sel_class,objectsFromPDFFile,uVar5,ppvVar7);
      local_88 = _objc_msgSend(pvVar4,sel_commentsForDroppedObjectWithURL_,pvVar3);
    }
    pvVar3 = _objc_msgSend(local_88,sel_length,pvVar3,uVar5,ppvVar7);
    if (pvVar3 != (id)0x0) {
      local_74 = 0;
      local_70 = 0;
      local_6c = (int *)0x0;
      local_68 = 0;
      local_64 = 0;
      local_60 = 0;
      local_5c = 0;
      local_58 = 0;
      puVar6 = local_50;
      uVar8 = 0x10;
      local_84 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,
                               puVar6,0x10);
      if (local_84 != (id)0x0) {
        iVar1 = *local_6c;
        do {
          pvVar3 = (id)0x0;
          do {
            if (iVar1 != *local_6c) {
              _objc_enumerationMutation(pvVar2);
            }
            pvVar4 = *(id *)(local_70 + (int)pvVar3 * 4);
            self_01 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037fb8c,puVar6,uVar8);
            _objc_msgSend(self_01,sel_setHyperComments_,local_88);
            pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_,&DAT_0037ffb0);
            _objc_msgSend(pvVar4,sel_setHyperName_,local_88);
            pvVar3 = (id)((int)pvVar3 + 1);
          } while (pvVar3 < local_84);
          puVar6 = local_50;
          uVar8 = 0x10;
          local_84 = _objc_msgSend(pvVar2,sel_countByEnumeratingWithState_objects_count_,&local_74,
                                   puVar6,0x10);
        } while (local_84 != (id)0x0);
      }
    }
  }
  return pvVar2;
}

*/
- (id)objectsFromPDFFile:(id)aFile firstPageOnly:(BOOL)aOnly error:(id *)aError
{
    NSString *path = [[NSFileManager defaultManager] hyperResolveAliasAtPath:aFile];
    if (path == nil) {
        path = aFile;
    }
    if (![[HSEditorController sharedDocumentController] canImportFileAtPath:path showAlert:YES]) {
        if (aError != NULL) {
            *aError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadTooLargeError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:path, NSFilePathErrorKey, nil]];
        }
        return nil;
    }
    id error = nil;
    NSArray *objects = [HSEditorDocument imageObjectsWithPDFMedia:path firstPageOnly:aOnly error:&error];
    if (objects == nil && error != nil && aError != NULL) {
        *aError = error;
    }
    NSURL *url = [NSURL fileURLWithPath:aFile];
    NSString *comments = url != nil ? [[self class] commentsForDroppedObjectWithURL:url] : nil;
    if ([comments length] != 0) {
        // The original uses the comments as the object name too.
        for (id object in objects) {
            [[object queryHyperInterface:@protocol(HSCommentsAttributes)] setHyperComments:comments];
            [[object queryHyperInterface:@protocol(HSMutableObjectAttributes)] setHyperName:comments];
        }
    }
    return objects;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e4959 @ 001e4959, 227 bytes * /

BOOL FUN_001e4959(HSEditorCardViewDragHelper *self,SEL _cmd,id isAnimatedGifMovieAtPath)

{
  BOOL BVar1;
  id self_00;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  int *piVar5;
  int *piVar6;
  int local_14;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  pvVar2 = _objc_msgSend(cls_NSURL,sel_fileURLWithPath_,isAnimatedGifMovieAtPath);
  local_14 = 0;
  piVar6 = &local_14;
  pvVar4 = pvVar2;
  piVar5 = piVar6;
  pvVar3 = _objc_msgSend(cls_HSMovie,sel_canInitWithURL_error_,pvVar2,piVar6);
  if (((char)pvVar3 != '\0') && (local_14 == 0)) {
    pvVar3 = _objc_msgSend(cls_HSMovie,sel_movieWithURL_error_,pvVar2,piVar6);
    pvVar4 = pvVar2;
    piVar5 = piVar6;
    if (local_14 == 0) {
      pvVar3 = _objc_msgSend(pvVar3,sel_isAnimatedGifMovie,pvVar2,piVar6);
      pvVar4 = pvVar2;
      piVar5 = piVar6;
      if ((char)pvVar3 != '\0') {
        BVar1 = '\x01';
        goto LAB_001e4a1a;
      }
    }
  }
  BVar1 = '\0';
LAB_001e4a1a:
  _objc_msgSend(self_00,sel_release,pvVar4,piVar5);
  return BVar1;
}

*/
- (BOOL)isAnimatedGifMovieAtPath:(id)aPath
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSURL *url = [NSURL fileURLWithPath:aPath];
    id error = nil;
    BOOL result = NO;
    if ([HSMovie canInitWithURL:url error:&error] && error == nil) {
        id movie = [HSMovie movieWithURL:url error:&error];
        if (error == nil && [movie isAnimatedGifMovie]) {
            result = YES;
        }
    }
    [pool release];
    return result;
}

- (BOOL)canRecieveDataFromFiles:(id)aFiles acceptingObject:(id)aObject dataName:(id *)aName
{
    return (BOOL)[self canRecieveDataFromFiles:aFiles acceptingObject:aObject dataName:aName canConnect:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e476a @ 001e476a, 425 bytes * /

BOOL FUN_001e476a(HSEditorCardViewDragHelper *self,SEL _cmd,id canRecieveDataFromFiles,
                 id acceptingObject,id *dataName,BOOL *canConnect)

{
  char cVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  undefined4 uVar6;
  char local_11;
  
  local_11 = '\0';
  pvVar2 = _objc_msgSend(canRecieveDataFromFiles,sel_objectEnumerator);
LAB_001e4880:
  do {
    pvVar5 = _objc_msgSend(pvVar2,sel_nextObject);
    if (pvVar5 == (id)0x0) goto LAB_001e489a;
    pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager);
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperResolveAliasAtPath_,pvVar5);
    if (pvVar3 != (id)0x0) {
      pvVar5 = pvVar3;
    }
    uVar6 = 0;
    pvVar3 = pvVar5;
    pvVar4 = _objc_msgSend(cls_HSNewMediaAccessor,sel_canCreateMediaObjectOfClass_withPath_,0,pvVar5
                          );
    if ((char)pvVar4 == '\0') {
      pvVar3 = _objc_msgSend(cls_NSFileManager,sel_defaultManager,uVar6,pvVar3);
      pvVar3 = _objc_msgSend(pvVar3,sel_hyperIsTextForPath_,pvVar5);
      if ((char)pvVar3 == '\0') goto LAB_001e4880;
    }
    pvVar5 = _objc_msgSend(self,sel_canRecieveDataFromPath_acceptingObject_dataName_canConnect_,
                           pvVar5,acceptingObject,dataName,canConnect);
    local_11 = (char)pvVar5;
    cVar1 = local_11;
    if (canConnect != (BOOL *)0x0) {
      if (local_11 == '\0') goto LAB_001e4880;
      cVar1 = *canConnect;
    }
    if (cVar1 != '\0') {
LAB_001e489a:
      if ((local_11 != '\0') &&
         (pvVar2 = _objc_msgSend(canRecieveDataFromFiles,sel_count), (id)0x1 < pvVar2)) {
        pvVar2 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        pvVar2 = _objc_msgSend(pvVar2,sel_localizedStringForKey_value_table_,&cfstr_HSPasteObjects,
                               &cfstr_empty,&cfstr_Editor);
        *dataName = pvVar2;
      }
      return local_11;
    }
  } while( true );
}

*/
- (BOOL)canRecieveDataFromFiles:(id)aFiles acceptingObject:(id)aObject dataName:(id *)aName canConnect:(BOOL *)aConnect
{
    BOOL result = NO;
    for (NSString *path in [aFiles objectEnumerator]) {
        NSString *resolvedPath = [[NSFileManager defaultManager] hyperResolveAliasAtPath:path];
        if (resolvedPath != nil) {
            path = resolvedPath;
        }
        if (![HSNewMediaAccessor canCreateMediaObjectOfClass:nil withPath:path]
            && ![[NSFileManager defaultManager] hyperIsTextForPath:path]) {
            continue;
        }
        result = [self canRecieveDataFromPath:path acceptingObject:aObject dataName:aName canConnect:aConnect];
        // Stop at the first file that can connect (or be received, when not asked).
        if (aConnect != NULL ? (result && *aConnect) : result) {
            break;
        }
    }
    // Fix: the original wrote the name without checking for NULL.
    if (result && [aFiles count] > 1 && aName != NULL) {
        *aName = [[HSExecutableResourceProvider sharedInstance] localizedStringForKey:@"HSPasteObjects" value:@"" table:@"Editor"];
    }
    return result;
}

- (BOOL)canRecieveDataFromFiles:(id)aFiles acceptingObject:(id)aObject
{
    return (BOOL)[self canRecieveDataFromFiles:aFiles acceptingObject:aObject dataName:nil];
}

- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject dataName:(id *)aName dragOperation:(NSUInteger)aOperation
{
    return (BOOL)[self canRecieveDataFromPasteboard:aPasteboard acceptingObject:aObject dataName:aName dragOperation:aOperation canConnectToObject:nil];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e3c08 @ 001e3c08, 2774 bytes * /

BOOL FUN_001e3c08(HSEditorCardViewDragHelper *self,SEL _cmd,id canRecieveDataFromPasteboard,
                 id acceptingObject,id *dataName,uint dragOperation,BOOL *canConnectToObject)

{
  undefined *puVar1;
  undefined *puVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  SEL pcVar7;
  cfstringStruct *pcVar8;
  cfstringStruct *pcVar9;
  cfstringStruct *pcVar10;
  cfstringStruct *pcVar11;
  undefined4 uVar12;
  undefined4 uVar13;
  undefined4 uVar14;
  char local_1d;
  id local_18;
  id local_14;
  
  local_14 = (id)0x0;
  pvVar3 = _objc_msgSend(canRecieveDataFromPasteboard,sel_types);
  _objc_msgSend(self->_cashedImageDataFromRTFDPasteboard,sel_release);
  self->_cashedImageDataFromRTFDPasteboard = (id)0x0;
  pcVar9 = (cfstringStruct *)0x0;
  pvVar4 = _objc_msgSend(self,sel_isLockedObject_,0);
  if ((char)pvVar4 != '\0') {
    pvVar3 = (id)0x0;
    local_1d = '\0';
    goto LAB_001e4671;
  }
  pcVar9 = &cfstr_HSObjectsPasteboardType;
  pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_,&cfstr_HSObjectsPasteboardType);
  if ((char)pvVar4 == '\0') {
LAB_001e3e1b:
    pcVar8 = &cfstr_HSCardsIndexPasteboardType;
    pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_,&cfstr_HSCardsIndexPasteboardType);
    if ((char)pvVar4 != '\0') {
      if (canConnectToObject != (BOOL *)0x0) {
        *canConnectToObject = '\x01';
      }
      goto LAB_001e3dbf;
    }
    pcVar8 = &cfstr_HSLibraryObjectsPasteboardType;
    pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_,&cfstr_HSLibraryObjectsPasteboardType);
    if ((char)pvVar4 != '\0') goto LAB_001e3dbf;
    pcVar9 = &cfstr_CorePasteboardFlavorType_0x6974756E;
    pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_,&cfstr_CorePasteboardFlavorType_0x6974756E);
    if ((char)pvVar4 == '\0') {
      pcVar9 = (cfstringStruct *)0x0;
    }
    else {
      pvVar4 = _objc_msgSend(self,sel_class,pcVar9);
      pcVar9 = _objc_msgSend(pvVar4,sel_iTunesSpecificFilenamesFromPasteboard_,
                             canRecieveDataFromPasteboard);
    }
    puVar1 = PTR_00336414;
    uVar12 = *(undefined4 *)PTR_00336414;
    pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_,uVar12);
    if ((char)pvVar4 != '\0') {
      uVar12 = *(undefined4 *)puVar1;
      pcVar9 = _objc_msgSend(canRecieveDataFromPasteboard,sel_propertyListForType_,uVar12);
    }
    pvVar4 = _objc_msgSend(pcVar9,sel_count,uVar12);
    pcVar7 = sel_canRecieveDataFromFiles_acceptingObject_dataName_canConnect_;
    if (pvVar4 < (id)0x2) {
      if (pvVar4 == (id)0x1) {
        pcVar9 = _objc_msgSend(pcVar9,sel_objectAtIndex_,0);
        pcVar7 = sel_canRecieveDataFromPath_acceptingObject_dataName_canConnect_;
        goto LAB_001e4113;
      }
      local_1d = '\0';
    }
    else {
LAB_001e4113:
      pvVar4 = _objc_msgSend(self,pcVar7,pcVar9,acceptingObject,&local_14,canConnectToObject);
      local_1d = (char)pvVar4;
      if (local_1d != '\0') {
        pvVar3 = (id)0x0;
        goto LAB_001e4671;
      }
    }
    pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_,*(undefined4 *)PTR_00336418);
    if (((char)pvVar4 != '\0') &&
       (pvVar4 = canRecieveDataFromPasteboard,
       pvVar5 = _objc_msgSend(cls_NSURL,sel_URLFromPasteboard_,canRecieveDataFromPasteboard),
       pvVar5 != (id)0x0)) {
      pvVar6 = _objc_msgSend(pvVar5,sel_isFileURL,pvVar4);
      puVar1 = cls_HSNewMediaAccessor;
      if ((char)pvVar6 == '\0') {
        pvVar4 = canRecieveDataFromPasteboard;
        pvVar5 = _objc_msgSend(cls_NSImage,sel_canInitWithPasteboard_,canRecieveDataFromPasteboard);
        if ((char)pvVar5 != '\0') goto LAB_001e4042;
        pvVar4 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar4);
        local_14 = _objc_msgSend(pvVar4,sel_localizedStringForKey_value_table_,&cfstr_URL,
                                 &cfstr_empty,&cfstr_Editor);
        if (canConnectToObject != (BOOL *)0x0) {
          *canConnectToObject = '\x01';
        }
        local_1d = '\x01';
      }
      else {
        pvVar4 = _objc_msgSend(pvVar5,sel_path,pvVar4);
        uVar12 = 0;
        pvVar6 = _objc_msgSend(puVar1,sel_canCreateMediaObjectOfClass_withPath_,0,pvVar4);
        local_1d = '\0';
        if ((char)pvVar6 != '\0') {
          pvVar4 = _objc_msgSend(pvVar5,sel_path,uVar12,pvVar4);
          pvVar4 = _objc_msgSend(self,
                                 sel_canRecieveDataFromPath_acceptingObject_dataName_canConnect_,
                                 pvVar4,acceptingObject,&local_14,canConnectToObject);
          local_1d = (char)pvVar4;
        }
LAB_001e4042:
        if (local_1d == '\0') goto LAB_001e404d;
      }
      pcVar9 = *(cfstringStruct **)PTR_003367b4;
      pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_,pcVar9);
      if ((char)pvVar4 != '\0') goto LAB_001e404d;
LAB_001e41db:
      pvVar3 = (id)0x0;
      goto LAB_001e4671;
    }
LAB_001e404d:
    pvVar4 = *(id *)PTR_003367bc;
    pvVar5 = _objc_msgSend(pvVar3,sel_containsObject_,pvVar4);
    if (((char)pvVar5 != '\0') &&
       (pvVar4 = canRecieveDataFromPasteboard,
       pvVar5 = _objc_msgSend(cls_QTMovie,sel_canInitWithPasteboard_,canRecieveDataFromPasteboard),
       (char)pvVar5 != '\0')) {
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar4);
      pcVar8 = &cfstr_HSPasteMovie;
LAB_001e42ec:
      pcVar9 = &cfstr_Editor;
      pcVar10 = &cfstr_empty;
      pcVar7 = sel_localizedStringForKey_value_table_;
      goto LAB_001e42f0;
    }
    pvVar4 = _objc_msgSend(cls_NSImage,sel_imagePasteboardTypes,pvVar4);
    pvVar4 = _objc_msgSend(canRecieveDataFromPasteboard,sel_availableTypeFromArray_,pvVar4);
    if ((pvVar4 != (id)0x0) &&
       ((pvVar4 = _objc_msgSend(acceptingObject,sel_queryHyperInterface_,&DAT_0037f90c),
        pvVar4 == (id)0x0 ||
        (pvVar4 = _objc_msgSend(pvVar4,sel_isMediaTypeSupported_,*(undefined4 *)PTR_00336154),
        (char)pvVar4 != '\0')))) {
      pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,&cfstr_BTArchivedImageRegionPboardType
                            );
      pvVar4 = _objc_msgSend(canRecieveDataFromPasteboard,sel_availableTypeFromArray_,pvVar3);
      pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
      if (pvVar4 == (id)0x0) {
LAB_001e442c:
        pcVar8 = &cfstr_HSPasteImage;
      }
      else {
        pcVar8 = &cfstr_Selection;
      }
      goto LAB_001e42ec;
    }
    pcVar9 = &cfstr_HSSerializedRichTextPasteboardType;
    pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_,&cfstr_HSSerializedRichTextPasteboardType);
    if ((char)pvVar4 == '\0') {
      pvVar3 = _objc_msgSend(pvVar3,sel_containsObject_,*(undefined4 *)PTR_003367b4);
      puVar1 = PTR_003367b8;
      if ((char)pvVar3 == '\0') {
        pvVar3 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_003367b8);
        pvVar4 = _objc_msgSend(canRecieveDataFromPasteboard,sel_availableTypeFromArray_,pvVar3);
        puVar2 = PTR_003361bc;
        if (pvVar4 == (id)0x0) {
          pcVar9 = _objc_msgSend(cls_NSArray,sel_arrayWithObject_,*(undefined4 *)PTR_003361bc);
          pvVar3 = _objc_msgSend(canRecieveDataFromPasteboard,sel_availableTypeFromArray_,pcVar9);
          if (pvVar3 == (id)0x0) goto LAB_001e41db;
          pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar9);
          pcVar10 = &cfstr_Editor;
          pcVar11 = &cfstr_empty;
          pcVar8 = &cfstr_HSPasteText;
          local_14 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSPasteText,
                                   &cfstr_empty,&cfstr_Editor);
          if (canConnectToObject != (BOOL *)0x0) {
            pcVar9 = *(cfstringStruct **)puVar2;
            pcVar7 = sel_stringForType_;
            goto LAB_001e4668;
          }
        }
        else {
          pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pvVar3);
          pcVar10 = &cfstr_Editor;
          pcVar11 = &cfstr_empty;
          pcVar8 = &cfstr_HSPasteText;
          local_14 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSPasteText,
                                   &cfstr_empty,&cfstr_Editor);
          if (canConnectToObject != (BOOL *)0x0) {
            pcVar8 = *(cfstringStruct **)puVar1;
            pcVar9 = _objc_msgSend(canRecieveDataFromPasteboard,sel_dataForType_,pcVar8,pcVar11,
                                   pcVar10);
            puVar1 = cls_NSString;
            goto joined_r0x001e45a5;
          }
        }
      }
      else {
        pvVar4 = _objc_msgSend(self,sel_cashedImageDataFromRTFDPasteboard_,
                               canRecieveDataFromPasteboard);
        pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance);
        if (pvVar4 != (id)0x0) goto LAB_001e442c;
        pcVar10 = &cfstr_Editor;
        pcVar11 = &cfstr_empty;
        pcVar8 = &cfstr_HSPasteText;
        local_14 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSPasteText,
                                 &cfstr_empty,&cfstr_Editor);
        if (canConnectToObject != (BOOL *)0x0) {
          pcVar8 = *(cfstringStruct **)PTR_003367b8;
          pcVar9 = _objc_msgSend(canRecieveDataFromPasteboard,sel_dataForType_,pcVar8,pcVar11,
                                 pcVar10);
          puVar1 = cls_NSAttributedString;
joined_r0x001e45a5:
          if (pcVar9 != (cfstringStruct *)0x0) {
            pvVar3 = _objc_msgSend(puVar1,sel_alloc,pcVar8,pcVar11,pcVar10);
            pcVar11 = (cfstringStruct *)0x0;
            pvVar3 = _objc_msgSend(pvVar3,sel_initWithRTF_documentAttributes_,pcVar9,0);
            pcVar7 = sel_autorelease;
            goto LAB_001e43a5;
          }
        }
      }
      goto LAB_001e3dbf;
    }
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar9);
    pcVar10 = &cfstr_Editor;
    pcVar11 = &cfstr_empty;
    pcVar8 = &cfstr_HSPasteText;
    local_14 = _objc_msgSend(pvVar3,sel_localizedStringForKey_value_table_,&cfstr_HSPasteText,
                             &cfstr_empty,&cfstr_Editor);
    if (canConnectToObject == (BOOL *)0x0) goto LAB_001e3dbf;
    pvVar3 = _objc_msgSend(cls_HSNonOpaqueTextView,
                           sel_nativelySerializedAttributedStringWithPasteboard_,
                           canRecieveDataFromPasteboard,pcVar11,pcVar10);
    pcVar7 = sel_hyperAttributedStringByConvertingGradientColorsToSolidColors;
    pcVar9 = canRecieveDataFromPasteboard;
LAB_001e43a5:
    canRecieveDataFromPasteboard = _objc_msgSend(pvVar3,pcVar7,pcVar9,pcVar11,pcVar10);
    pcVar7 = sel_string;
LAB_001e4668:
    pvVar3 = _objc_msgSend(canRecieveDataFromPasteboard,pcVar7,pcVar9,pcVar11,pcVar10);
  }
  else {
    pvVar4 = _objc_msgSend(canRecieveDataFromPasteboard,sel_propertyListForType_,
                           &cfstr_HSObjectsPasteboardType);
    pvVar5 = _objc_msgSend(pvVar4,sel_count);
    if (pvVar5 == (id)0x0) goto LAB_001e3e1b;
    pvVar3 = _objc_msgSend(pvVar4,sel_count,pcVar9);
    if (pvVar3 < (id)0x2) {
      pvVar3 = _objc_msgSend(pvVar4,sel_objectAtIndex_,0);
      _objc_msgSend(pvVar3,sel_valueForKey_,*(undefined4 *)PTR_00336674);
      local_18 = (id)0x0;
      pcVar9 = (cfstringStruct *)&local_18;
      uVar14 = 0;
      uVar13 = 0;
      uVar12 = 0;
      pvVar3 = _objc_msgSend(self,
                             sel_readFromPasteboard_acceptingObject_createdObjects_runAnimationMode_dragOperation_useDragPreferences_pastingNotHSObject_
                             ,canRecieveDataFromPasteboard,acceptingObject,pcVar9,0,dragOperation,0,
                             0);
      pcVar8 = canRecieveDataFromPasteboard;
      if (((char)pvVar3 != '\0') &&
         (pvVar3 = _objc_msgSend(local_18,sel_count,canRecieveDataFromPasteboard,acceptingObject,
                                 pcVar9,uVar12,dragOperation,uVar13,uVar14),
         pcVar8 = canRecieveDataFromPasteboard, pvVar3 != (id)0x0)) {
        pvVar3 = _objc_msgSend(local_18,sel_lastObject,canRecieveDataFromPasteboard,acceptingObject,
                               pcVar9,uVar12,dragOperation,uVar13,uVar14);
        pcVar8 = (cfstringStruct *)&DAT_0037f7e0;
        pvVar3 = _objc_msgSend(pvVar3,sel_queryHyperInterface_,&DAT_0037f7e0);
        pcVar7 = sel_hyperKindDisplayName;
        pcVar10 = acceptingObject;
        goto LAB_001e42f0;
      }
      goto LAB_001e3dbf;
    }
    pvVar3 = _objc_msgSend(cls_HSExecutableResourceProvider,sel_sharedInstance,pcVar9);
    pcVar9 = &cfstr_Editor;
    pcVar10 = &cfstr_empty;
    pcVar8 = &cfstr_HSPasteObjects;
    pcVar7 = sel_localizedStringForKey_value_table_;
LAB_001e42f0:
    local_14 = _objc_msgSend(pvVar3,pcVar7,pcVar8,pcVar10,pcVar9);
LAB_001e3dbf:
    pvVar3 = (id)0x0;
    pcVar9 = pcVar8;
  }
  local_1d = '\x01';
LAB_001e4671:
  if (dataName != (id *)0x0) {
    *dataName = local_14;
  }
  if (local_1d == '\0') {
    _objc_msgSend(self->_cashedImageDataFromRTFDPasteboard,sel_release,pcVar9);
    self->_cashedImageDataFromRTFDPasteboard = (id)0x0;
  }
  else if (((canConnectToObject != (BOOL *)0x0) && (pvVar3 != (id)0x0)) &&
          (pvVar3 = _objc_msgSend(self,sel_stringIsURL_,pvVar3), (char)pvVar3 != '\0')) {
    *canConnectToObject = '\x01';
  }
  return local_1d;
}

*/
- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject dataName:(id *)aName dragOperation:(NSUInteger)aOperation canConnectToObject:(BOOL *)aObject2
{
    id name = nil;
    id urlText = nil;
    BOOL result = YES;
    NSArray *types = [aPasteboard types];
    [_cashedImageDataFromRTFDPasteboard release];
    _cashedImageDataFromRTFDPasteboard = nil;
    if ([self isLockedObject:nil]) {
        result = NO;
        goto done;
    }
    {
        id provider = [HSExecutableResourceProvider sharedInstance];
        if ([types containsObject:@"HSObjectsPasteboardType"]) {
            NSArray *objects = [aPasteboard propertyListForType:@"HSObjectsPasteboardType"];
            if ([objects count] != 0) {
                if ([objects count] < 2) {
                    [[objects objectAtIndex:0] valueForKey:EXClassNameKey];
                    NSArray *created = nil;
                    if ([self readFromPasteboard:aPasteboard acceptingObject:aObject createdObjects:&created runAnimationMode:NULL dragOperation:aOperation useDragPreferences:NO pastingNotHSObject:NULL]
                        && [created count] != 0) {
                        id info = [[created lastObject] queryHyperInterface:@protocol(HSObjectAttributes)];
                        name = [info hyperKindDisplayName];
                    }
                } else {
                    name = [provider localizedStringForKey:@"HSPasteObjects" value:@"" table:@"Editor"];
                }
                goto done;
            }
        }
        if ([types containsObject:@"HSCardsIndexPasteboardType"]) {
            if (aObject2 != NULL) {
                *aObject2 = YES;
            }
            goto done;
        }
        if ([types containsObject:@"HSLibraryObjectsPasteboardType"]) {
            goto done;
        }
        id files = nil;
        if ([types containsObject:@"CorePasteboardFlavorType 0x6974756E"]) {
            files = [[self class] iTunesSpecificFilenamesFromPasteboard:aPasteboard];
        }
        if ([types containsObject:NSFilenamesPboardType]) {
            files = [aPasteboard propertyListForType:NSFilenamesPboardType];
        }
        BOOL recognized = NO;
        if ([files count] >= 2) {
            recognized = [self canRecieveDataFromFiles:files acceptingObject:aObject dataName:&name canConnect:aObject2];
        } else if ([files count] == 1) {
            recognized = [self canRecieveDataFromPath:[files objectAtIndex:0] acceptingObject:aObject dataName:&name canConnect:aObject2];
        }
        if (recognized) {
            goto done;
        }
        result = NO;
        if ([types containsObject:NSURLPboardType]) {
            NSURL *url = [NSURL URLFromPasteboard:aPasteboard];
            if (url != nil) {
                BOOL urlRecognized = NO;
                if ([url isFileURL]) {
                    if ([HSNewMediaAccessor canCreateMediaObjectOfClass:nil withPath:[url path]]) {
                        urlRecognized = [self canRecieveDataFromPath:[url path] acceptingObject:aObject dataName:&name canConnect:aObject2];
                    }
                } else if (![NSImage canInitWithPasteboard:aPasteboard]) {
                    name = [provider localizedStringForKey:@"URL" value:@"" table:@"Editor"];
                    if (aObject2 != NULL) {
                        *aObject2 = YES;
                    }
                    urlRecognized = YES;
                }
                if (urlRecognized) {
                    result = YES;
                    if (![types containsObject:NSRTFDPboardType]) {
                        goto done;
                    }
                }
            }
        }
        if ([types containsObject:QTMoviePasteboardType] && [QTMovie canInitWithPasteboard:aPasteboard]) {
            name = [provider localizedStringForKey:@"HSPasteMovie" value:@"" table:@"Editor"];
            result = YES;
            goto done;
        }
        if ([aPasteboard availableTypeFromArray:[NSImage imagePasteboardTypes]] != nil) {
            id mediaSupport = [aObject queryHyperInterface:@protocol(HSMediaObject)];
            if (mediaSupport == nil || [mediaSupport isMediaTypeSupported:NSTIFFPboardType]) {
                BOOL isSelection = [aPasteboard availableTypeFromArray:[NSArray arrayWithObject:@"BTArchivedImageRegionPboardType"]] != nil;
                name = [provider localizedStringForKey:(isSelection ? @"Selection" : @"HSPasteImage") value:@"" table:@"Editor"];
                result = YES;
                goto done;
            }
        }
        if ([types containsObject:@"HSSerializedRichTextPasteboardType"]) {
            name = [provider localizedStringForKey:@"HSPasteText" value:@"" table:@"Editor"];
            if (aObject2 != NULL) {
                urlText = [[[HSNonOpaqueTextView nativelySerializedAttributedStringWithPasteboard:aPasteboard] hyperAttributedStringByConvertingGradientColorsToSolidColors] string];
            }
            result = YES;
            goto done;
        }
        if ([types containsObject:NSRTFDPboardType]) {
            if ([self cashedImageDataFromRTFDPasteboard:aPasteboard] != nil) {
                name = [provider localizedStringForKey:@"HSPasteImage" value:@"" table:@"Editor"];
            } else {
                name = [provider localizedStringForKey:@"HSPasteText" value:@"" table:@"Editor"];
                if (aObject2 != NULL) {
                    NSData *rtf = [aPasteboard dataForType:NSRTFPboardType];
                    if (rtf != nil) {
                        urlText = [[[[NSAttributedString alloc] initWithRTF:rtf documentAttributes:NULL] autorelease] string];
                    }
                }
            }
            result = YES;
            goto done;
        }
        if ([aPasteboard availableTypeFromArray:[NSArray arrayWithObject:NSRTFPboardType]] != nil) {
            name = [provider localizedStringForKey:@"HSPasteText" value:@"" table:@"Editor"];
            if (aObject2 != NULL) {
                NSData *rtf = [aPasteboard dataForType:NSRTFPboardType];
                if (rtf != nil) {
                    urlText = [[[[NSAttributedString alloc] initWithRTF:rtf documentAttributes:NULL] autorelease] string];
                }
            }
            result = YES;
            goto done;
        }
        if ([aPasteboard availableTypeFromArray:[NSArray arrayWithObject:NSStringPboardType]] != nil) {
            name = [provider localizedStringForKey:@"HSPasteText" value:@"" table:@"Editor"];
            if (aObject2 != NULL) {
                urlText = [aPasteboard stringForType:NSStringPboardType];
            }
            result = YES;
            goto done;
        }
        urlText = nil;
    }
done:
    if (aName != NULL) {
        *aName = name;
    }
    if (result) {
        if (aObject2 != NULL && urlText != nil && [self stringIsURL:urlText]) {
            *aObject2 = YES;
        }
    } else {
        [_cashedImageDataFromRTFDPasteboard release];
        _cashedImageDataFromRTFDPasteboard = nil;
    }
    return result;
}

- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject canConnectToObject:(BOOL *)aObject2
{
    BOOL pvVar1;

    if ((aObject2 != nil) && (pvVar1 = [self isLockedObject:aObject], pvVar1)) {
        return NO;
    }
    return (BOOL)[self canRecieveDataFromPasteboard:aPasteboard acceptingObject:aObject dataName:nil dragOperation:0 canConnectToObject:aObject2];
}

- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject dragOperation:(NSUInteger)aOperation
{
    if (aObject == nil) {
        aObject = [self defaultAcceptingObject];
    }
    return (BOOL)[self canRecieveDataFromPasteboard:aPasteboard acceptingObject:aObject dataName:nil dragOperation:aOperation];
}

- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard dataName:(id *)aName
{
    return (BOOL)[self canRecieveDataFromPasteboard:aPasteboard acceptingObject:[self defaultAcceptingObject] dataName:aName dragOperation:0];
}

- (BOOL)canRecieveDataFromPasteboard:(id)aPasteboard
{
    return (BOOL)[self canRecieveDataFromPasteboard:aPasteboard acceptingObject:[self defaultAcceptingObject] dragOperation:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e3a1c @ 001e3a1c, 102 bytes * /

BOOL FUN_001e3a1c(HSEditorCardViewDragHelper *self,SEL _cmd,id stringIsURL)

{
  id pvVar1;
  bool bVar2;
  
  pvVar1 = _objc_msgSend(cls_NSURL,sel_URLWithString_,stringIsURL);
  pvVar1 = _objc_msgSend(pvVar1,sel_scheme);
  if (pvVar1 == (id)0x0) {
    bVar2 = false;
  }
  else {
    pvVar1 = _objc_msgSend(pvVar1,sel_length,stringIsURL);
    bVar2 = pvVar1 != (id)0x0;
  }
  return bVar2;
}

*/
- (BOOL)stringIsURL:(id)aURL
{
    NSString *scheme = [[NSURL URLWithString:aURL] scheme];
    return scheme != nil && [scheme length] != 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e379f @ 001e379f, 637 bytes * /

id FUN_001e379f(HSEditorCardViewDragHelper *self,SEL _cmd,id stringFromPasteboard)

{
  undefined *puVar1;
  id pvVar2;
  id pvVar3;
  SEL op;
  undefined4 uVar4;
  undefined4 uVar5;
  
  pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithObject_,
                         &cfstr_HSSerializedRichTextPasteboardType);
  if (pvVar2 != (id)0x0) {
    pvVar3 = _objc_msgSend(stringFromPasteboard,sel_availableTypeFromArray_,pvVar2);
    if (pvVar3 != (id)0x0) {
      pvVar2 = _objc_msgSend(cls_HSNonOpaqueTextView,
                             sel_nativelySerializedAttributedStringWithPasteboard_,
                             stringFromPasteboard);
      op = sel_hyperAttributedStringByConvertingGradientColorsToSolidColors;
      pvVar3 = stringFromPasteboard;
LAB_001e3820:
      pvVar2 = _objc_msgSend(pvVar2,op,pvVar3);
      return pvVar2;
    }
    uVar5 = *(undefined4 *)PTR_003367b4;
    _objc_msgSend(pvVar2,sel_replaceObjectAtIndex_withObject_,0,uVar5);
    pvVar3 = _objc_msgSend(stringFromPasteboard,sel_availableTypeFromArray_,pvVar2);
    if ((pvVar3 == (id)0x0) ||
       (pvVar3 = _objc_msgSend(self,sel_cashedImageDataFromRTFDPasteboard_,stringFromPasteboard,
                               uVar5), pvVar3 == (id)0x0)) {
      puVar1 = PTR_003367b8;
      uVar5 = *(undefined4 *)PTR_003367b8;
      _objc_msgSend(pvVar2,sel_replaceObjectAtIndex_withObject_,0,uVar5);
      pvVar3 = _objc_msgSend(stringFromPasteboard,sel_availableTypeFromArray_,pvVar2);
      if (pvVar3 != (id)0x0) {
        uVar4 = *(undefined4 *)puVar1;
        pvVar3 = _objc_msgSend(stringFromPasteboard,sel_dataForType_,uVar4,uVar5);
        puVar1 = cls_NSAttributedString;
        if (pvVar3 != (id)0x0) {
          pvVar2 = _objc_msgSend(self->_dragHost,sel_zone,uVar4,uVar5);
          pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
          pvVar2 = _objc_msgSend(pvVar2,sel_initWithRTF_documentAttributes_,pvVar3,0);
          op = sel_autorelease;
          goto LAB_001e3820;
        }
      }
      puVar1 = PTR_003361bc;
      uVar5 = *(undefined4 *)PTR_003361bc;
      _objc_msgSend(pvVar2,sel_replaceObjectAtIndex_withObject_,0,uVar5);
      pvVar2 = _objc_msgSend(stringFromPasteboard,sel_availableTypeFromArray_,pvVar2);
      if (pvVar2 != (id)0x0) {
        uVar4 = *(undefined4 *)puVar1;
        pvVar3 = _objc_msgSend(stringFromPasteboard,sel_stringForType_,uVar4,uVar5);
        puVar1 = cls_NSAttributedString;
        if (pvVar3 != (id)0x0) {
          pvVar2 = _objc_msgSend(self->_dragHost,sel_zone,uVar4,uVar5);
          pvVar2 = _objc_msgSend(puVar1,sel_allocWithZone_,pvVar2);
          pvVar2 = _objc_msgSend(pvVar2,sel_initWithString_,pvVar3);
          op = sel_autorelease;
          goto LAB_001e3820;
        }
      }
    }
  }
  return (id)0x0;
}

*/
- (id)stringFromPasteboard:(id)aPasteboard
{
    NSMutableArray *types = [NSMutableArray arrayWithObject:@"HSSerializedRichTextPasteboardType"];
    if ([aPasteboard availableTypeFromArray:types] != nil) {
        return [[HSNonOpaqueTextView nativelySerializedAttributedStringWithPasteboard:aPasteboard] hyperAttributedStringByConvertingGradientColorsToSolidColors];
    }
    [types replaceObjectAtIndex:0 withObject:NSRTFDPboardType];
    if ([aPasteboard availableTypeFromArray:types] != nil && [self cashedImageDataFromRTFDPasteboard:aPasteboard] != nil) {
        // RTFD holding just an image is read as an image, not text.
        return nil;
    }
    [types replaceObjectAtIndex:0 withObject:NSRTFPboardType];
    if ([aPasteboard availableTypeFromArray:types] != nil) {
        NSData *data = [aPasteboard dataForType:NSRTFPboardType];
        if (data != nil) {
            return [[[NSAttributedString allocWithZone:[_dragHost zone]] initWithRTF:data documentAttributes:NULL] autorelease];
        }
    }
    [types replaceObjectAtIndex:0 withObject:NSStringPboardType];
    if ([aPasteboard availableTypeFromArray:types] != nil) {
        NSString *string = [aPasteboard stringForType:NSStringPboardType];
        if (string != nil) {
            return [[[NSAttributedString allocWithZone:[_dragHost zone]] initWithString:string] autorelease];
        }
    }
    return nil;
}

- (id)cashedImageDataFromRTFDPasteboard:(id)aPasteboard
{
    id pvVar1;

    pvVar1 = _cashedImageDataFromRTFDPasteboard;
    if (pvVar1 == nil) {
        pvVar1 = [[self imageDataFromRTFDPasteboard:aPasteboard] retain];
        _cashedImageDataFromRTFDPasteboard = pvVar1;
    }
    return pvVar1;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e35a8 @ 001e35a8, 426 bytes * /

id FUN_001e35a8(HSEditorCardViewDragHelper *self,SEL _cmd,id imageDataFromRTFDPasteboard)

{
  undefined *self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  undefined4 uVar5;
  undefined4 uVar6;
  
  uVar5 = *(undefined4 *)PTR_003367b4;
  pvVar1 = _objc_msgSend(imageDataFromRTFDPasteboard,sel_dataForType_,uVar5);
  self_00 = cls_NSAttributedString;
  if (pvVar1 == (id)0x0) {
    return (id)0x0;
  }
  pvVar2 = _objc_msgSend(self->_dragHost,sel_zone,uVar5);
  pvVar2 = _objc_msgSend(self_00,sel_allocWithZone_,pvVar2);
  uVar5 = 0;
  pvVar2 = _objc_msgSend(pvVar2,sel_initWithRTFD_documentAttributes_,pvVar1,0);
  pvVar3 = _objc_msgSend(pvVar2,sel_length);
  if (pvVar3 == (id)0x1) {
    pvVar1 = *(id *)PTR_003367a8;
    uVar6 = 0;
    uVar5 = 0;
    pvVar3 = _objc_msgSend(pvVar2,sel_attribute_atIndex_effectiveRange_,pvVar1,0,0);
    if ((pvVar3 != (id)0x0) &&
       (pvVar4 = _objc_msgSend(pvVar3,sel_fileWrapper,pvVar1,uVar5,uVar6), pvVar4 != (id)0x0)) {
      pvVar4 = _objc_msgSend(pvVar3,sel_fileWrapper,pvVar1,uVar5,uVar6);
      pvVar4 = _objc_msgSend(pvVar4,sel_isRegularFile);
      if ((char)pvVar4 != '\0') {
        pvVar1 = _objc_msgSend(pvVar3,sel_fileWrapper,pvVar1,uVar5,uVar6);
        pvVar3 = _objc_msgSend(pvVar1,sel_regularFileContents);
        pvVar4 = _objc_msgSend(cls_NSImage,sel_alloc);
        pvVar1 = pvVar3;
        pvVar4 = _objc_msgSend(pvVar4,sel_initWithData_,pvVar3);
        if (pvVar4 == (id)0x0) {
          pvVar3 = (id)0x0;
        }
        _objc_msgSend(pvVar4,sel_release,pvVar1);
        goto LAB_001e3732;
      }
    }
  }
  pvVar3 = (id)0x0;
LAB_001e3732:
  _objc_msgSend(pvVar2,sel_autorelease,pvVar1,uVar5);
  return pvVar3;
}

*/
- (id)imageDataFromRTFDPasteboard:(id)aPasteboard
{
    NSData *data = [aPasteboard dataForType:NSRTFDPboardType];
    if (data == nil) {
        return nil;
    }
    NSAttributedString *string = [[NSAttributedString allocWithZone:[_dragHost zone]] initWithRTFD:data documentAttributes:NULL];
    NSData *imageData = nil;
    // Only RTFD made of a single attached image counts.
    if ([string length] == 1) {
        NSTextAttachment *attachment = [string attribute:NSAttachmentAttributeName atIndex:0 effectiveRange:NULL];
        if (attachment != nil && [attachment fileWrapper] != nil && [[attachment fileWrapper] isRegularFile]) {
            imageData = [[attachment fileWrapper] regularFileContents];
            NSImage *image = [[NSImage alloc] initWithData:imageData];
            if (image == nil) {
                imageData = nil;
            }
            [image release];
        }
    }
    [string autorelease];
    return imageData;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001eeb14 @ 001eeb14, 2365 bytes * /

BOOL FUN_001eeb14(HSEditorCardViewDragHelper *self,SEL _cmd,id startDragWithNodes,id event)

{
  undefined4 uVar1;
  undefined *self_00;
  undefined1 *puVar2;
  char cVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  id pvVar9;
  float extraout_EDX;
  float extraout_EDX_00;
  undefined4 *puVar10;
  undefined4 uStack_88;
  undefined4 auStack_70 [10];
  id local_48;
  float local_44;
  float local_3c;
  float local_34;
  float local_30;
  float local_28;
  undefined1 local_24 [16];
  id local_14;
  
  pvVar4 = _objc_msgSend(self->_dragHost,sel_window);
  pvVar4 = _objc_msgSend(pvVar4,sel_nextEventMatchingMask_);
  pvVar5 = _objc_msgSend(pvVar4,sel_type);
  if ((pvVar5 == (id)0x2) || (pvVar4 = _objc_msgSend(pvVar4,sel_type), pvVar4 == (id)0xc)) {
    return '\0';
  }
  pvVar4 = self->_dragHost;
  _objc_msgSend(event,sel_locationInWindow);
  local_48 = _objc_msgSend(pvVar4,sel_convertPoint_fromView_);
  pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_);
  pvVar4 = _objc_msgSend(startDragWithNodes,sel_objectsByRemovingLinkedObjects);
  pvVar6 = _objc_msgSend(pvVar4,sel_objectEnumerator);
  pvVar4 = _objc_msgSend(pvVar6,sel_nextObject);
  while (pvVar4 != (id)0x0) {
    _objc_msgSend(cls_HSNode,sel_class);
    pvVar7 = _objc_msgSend(pvVar4,sel_isKindOfClass_);
    if ((char)pvVar7 != '\0') {
      local_14 = (id)0x0;
      pvVar7 = _objc_msgSend(pvVar4,sel_localCopyIncludingNodeUnits_copiedLinkedObjects_);
      _objc_msgSend(pvVar7,sel_autorelease);
      _objc_msgSend(pvVar5,sel_addObject_);
      _objc_msgSend(pvVar4,sel_queryHyperInterface_);
      if (local_14 != (id)0x0) {
        _objc_msgSend(local_14,sel_makeObjectsPerformSelector_withObject_);
      }
      pvVar4 = _objc_msgSend(pvVar5,sel_lastObject);
      _objc_msgSend(pvVar4,sel_setSupport_);
      _objc_msgSend(pvVar5,sel_addObjectsFromArray_);
    }
    pvVar4 = _objc_msgSend(pvVar6,sel_nextObject);
  }
  _objc_msgSend(pvVar5,sel_sortByHyperOrder);
  pvVar6 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_);
  pvVar7 = _objc_msgSend(cls_NSMutableSet,sel_setWithCapacity_);
  pvVar8 = _objc_msgSend(pvVar5,sel_objectEnumerator);
  pvVar4 = _objc_msgSend(pvVar8,sel_nextObject);
  while (pvVar4 != (id)0x0) {
    _objc_msgSend(pvVar4,sel_fullDictionaryRepresentation);
    _objc_msgSend(pvVar6,sel_addObject_);
    pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_);
    pvVar4 = _objc_msgSend(pvVar4,sel_mediaUIDs);
    if (pvVar4 != (id)0x0) {
      _objc_msgSend(pvVar7,sel_unionSet_);
    }
    pvVar4 = _objc_msgSend(pvVar8,sel_nextObject);
  }
  pvVar4 = _objc_msgSend(cls_NSPasteboard,sel_pasteboardWithName_);
  _objc_msgSend(self->_draggingPasteboardDataProvider,sel_release);
  pvVar6 = _objc_msgSend(pvVar5,sel_lastObject);
  pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_);
  _objc_msgSend(pvVar6,sel_hyperName);
  self_00 = cls_HSPasteboardDataProvider;
  _objc_msgSend(self,sel_zone);
  pvVar6 = _objc_msgSend(self_00,sel_allocWithZone_);
  pvVar6 = _objc_msgSend(pvVar6,sel_initWithObjects_UIDs_dragName_);
  self->_draggingPasteboardDataProvider = pvVar6;
  _objc_msgSend(pvVar6,sel_declareTypesForPasteboard_);
  pvVar6 = _objc_msgSend(cls_NSAutoreleasePool,sel_alloc);
  pvVar6 = _objc_msgSend(pvVar6,sel_init);
  pvVar7 = _objc_msgSend(cls_HSUserObjectInEditorPreviewView,sel_alloc);
  pvVar7 = _objc_msgSend(pvVar7,sel_initWithFrame_);
  pvVar7 = _objc_msgSend(pvVar7,sel_autorelease);
  puVar2 = &stack0xffffff84;
  local_44 = extraout_EDX;
  if (pvVar7 != (id)0x0) {
    _objc_msgSend(cls_NSColor,sel_clearColor);
    _objc_msgSend(pvVar7,sel_setBackgroundColor_);
    pvVar8 = _objc_msgSend(pvVar5,sel_count);
    if (pvVar8 == (id)0x1) {
      _objc_msgSend(pvVar5,sel_lastObject);
      _objc_msgSend(pvVar7,sel_addUserObject_);
    }
    else {
      pvVar8 = _objc_msgSend(pvVar5,sel_count);
      if ((id)0x1 < pvVar8) {
        pvVar8 = _objc_msgSend(pvVar5,sel_objectEnumerator);
        while (pvVar9 = _objc_msgSend(pvVar8,sel_nextObject), pvVar9 != (id)0x0) {
          _objc_msgSend(pvVar7,sel_addUserObject_);
        }
      }
    }
    _objc_msgSend_stret(local_24,pvVar7,sel_renderersBoundingRect);
    cVar3 = _NSIsEmptyRect();
    puVar2 = &stack0xffffff80;
    if (cVar3 == '\0') {
      _NSIntegralRect();
      puVar10 = (undefined4 *)&stack0xffffff7c;
      pvVar8 = _objc_msgSend(pvVar7,sel_offsetsFromPoint_);
      if (pvVar8 != (id)0x0) {
        _objc_msgSend(cls_NSArray,sel_arrayWithObject_);
        _objc_msgSend(pvVar4,sel_addTypes_owner_);
        _objc_msgSend(pvVar4,sel_setData_forType_);
      }
      pvVar8 = _objc_msgSend(self->_dragHost,sel_convertPointFromDragHostToCard_);
      local_48 = (id)((float)local_48 + (local_34 - (float)pvVar8));
      pvVar8 = _objc_msgSend(self->_dragHost,sel_isFlipped);
      local_3c = local_30;
      if ((char)pvVar8 != '\0') {
        local_3c = local_30 + local_28;
      }
      _objc_msgSend(pvVar7,sel_setFrameSize_);
      pvVar7 = _objc_msgSend(cls_HSSemiTransparentImageRep,sel_alloc);
      _objc_msgSend(cls_NSImage,sel_hyperImageWithView_);
      pvVar7 = _objc_msgSend(pvVar7,sel_initWithImage_opacity_);
      local_44 = extraout_EDX + (local_3c - extraout_EDX_00);
      pvVar7 = _objc_msgSend(pvVar7,sel_autorelease);
      puVar2 = &stack0xffffff7c;
      if (pvVar7 != (id)0x0) {
        pvVar7 = _objc_msgSend(cls_NSImage,sel_alloc);
        pvVar7 = _objc_msgSend(pvVar7,sel_initWithSize_);
        _objc_msgSend(pvVar7,sel_addRepresentation_);
        goto LAB_001ef38b;
      }
    }
  }
  puVar10 = (undefined4 *)puVar2;
  pvVar7 = (id)0x0;
LAB_001ef38b:
  puVar10[1] = sel_release;
  *puVar10 = pvVar6;
  puVar10[-1] = 0x1ef3a0;
  _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  puVar10[2] = sel_setSupport_;
  puVar10[1] = sel_makeObjectsPerformSelector_withObject_;
  *puVar10 = pvVar5;
  puVar10[3] = 0;
  puVar10[-1] = 0x1ef3c7;
  _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  pvVar5 = self->_dragHost;
  puVar10[9] = self;
  puVar10[8] = pvVar4;
  puVar10[7] = event;
  uVar1 = *(undefined4 *)PTR_0033607c;
  puVar10[6] = *(undefined4 *)(PTR_0033607c + 4);
  puVar10[5] = uVar1;
  puVar10[4] = local_44;
  puVar10[3] = local_48;
  puVar10[2] = pvVar7;
  puVar10[1] = sel_dragImage_at_offset_event_pasteboard_source_slideBack_;
  *puVar10 = pvVar5;
  puVar10[10] = 1;
  puVar10[-1] = 0x1ef42e;
  _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  puVar10[1] = sel_release;
  *puVar10 = pvVar7;
  puVar10[-1] = 0x1ef440;
  _objc_msgSend((id)*puVar10,(SEL)puVar10[1]);
  return '\x01';
}

*/
- (BOOL)startDragWithNodes:(id)aNodes event:(id)aEvent
{
    NSEvent *nextEvent = [[_dragHost window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSFlagsChangedMask];
    if ([nextEvent type] == NSLeftMouseUp || [nextEvent type] == NSFlagsChanged) {
        return NO;
    }
    NSPoint location = [_dragHost convertPoint:[aEvent locationInWindow] fromView:nil];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:0];
    NSEnumerator *nodeEnumerator = [[aNodes objectsByRemovingLinkedObjects] objectEnumerator];
    id node;
    while ((node = [nodeEnumerator nextObject]) != nil) {
        if ([node isKindOfClass:[HSNode class]]) {
            NSArray *linkedObjects = nil;
            id copy = [[node localCopyIncludingNodeUnits:NO copiedLinkedObjects:&linkedObjects] autorelease];
            [objects addObject:copy];
            id support = [node queryHyperInterface:@protocol(HSNodeSupport)];
            if (linkedObjects != nil) {
                [linkedObjects makeObjectsPerformSelector:@selector(setSupport:) withObject:support];
            }
            [[objects lastObject] setSupport:support];
            [objects addObjectsFromArray:linkedObjects];
        }
    }
    [objects sortByHyperOrder];
    NSMutableArray *representations = [NSMutableArray arrayWithCapacity:0];
    NSMutableSet *mediaUIDs = [NSMutableSet setWithCapacity:0];
    NSEnumerator *objectEnumerator = [objects objectEnumerator];
    id object;
    while ((object = [objectEnumerator nextObject]) != nil) {
        [representations addObject:[object fullDictionaryRepresentation]];
        NSSet *uids = [[object queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs];
        if (uids != nil) {
            [mediaUIDs unionSet:uids];
        }
    }
    NSPasteboard *pasteboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [_draggingPasteboardDataProvider release];
    id name = [[[objects lastObject] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    _draggingPasteboardDataProvider = [[HSPasteboardDataProvider allocWithZone:[self zone]] initWithObjects:representations UIDs:mediaUIDs dragName:name];
    [_draggingPasteboardDataProvider declareTypesForPasteboard:pasteboard];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSImage *dragImage = nil;
    HSUserObjectInEditorPreviewView *preview = [[[HSUserObjectInEditorPreviewView alloc] initWithFrame:NSZeroRect] autorelease];
    if (preview != nil) {
        [preview setBackgroundColor:[NSColor clearColor]];
        if ([objects count] == 1) {
            [preview addUserObject:[objects lastObject]];
        }
        else if ([objects count] >= 2) {
            NSEnumerator *previewEnumerator = [objects objectEnumerator];
            id previewObject;
            while ((previewObject = [previewEnumerator nextObject]) != nil) {
                [preview addUserObject:previewObject];
            }
        }
        NSRect boundingRect = [preview renderersBoundingRect];
        if (!NSIsEmptyRect(boundingRect)) {
            NSRect integralRect = NSIntegralRect(boundingRect);
            id offsets = [preview offsetsFromPoint:integralRect.origin];
            if (offsets != nil) {
                [pasteboard addTypes:[NSArray arrayWithObject:@"HSObjectsOriginOffsetsPasteboardType"] owner:nil];
                [pasteboard setData:offsets forType:@"HSObjectsOriginOffsetsPasteboardType"];
            }
            NSPoint cardPoint = [_dragHost convertPointFromDragHostToCard:location];
            location.x = location.x + (integralRect.origin.x - cardPoint.x);
            float originY = integralRect.origin.y;
            if ([_dragHost isFlipped]) {
                originY = integralRect.origin.y + integralRect.size.height;
            }
            [preview setFrameSize:integralRect.size];
            id imageRep = [[[HSSemiTransparentImageRep alloc] initWithImage:[NSImage hyperImageWithView:preview] opacity:0.5f] autorelease];
            location.y = location.y + (originY - cardPoint.y);
            if (imageRep != nil) {
                dragImage = [[NSImage alloc] initWithSize:integralRect.size];
                [dragImage addRepresentation:imageRep];
            }
        }
    }
    [pool release];
    [objects makeObjectsPerformSelector:@selector(setSupport:) withObject:nil];
    [_dragHost dragImage:dragImage at:location offset:NSZeroSize event:aEvent pasteboard:pasteboard source:self slideBack:YES];
    [dragImage release];
    return YES;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e313f @ 001e313f, 1129 bytes * /

void FUN_001e313f(HSEditorCardViewDragHelper *self,SEL _cmd,id duplicateObjectsInEnumerator,
                 id *duplicatedObjects)

{
  id pvVar1;
  id self_00;
  id self_01;
  undefined *puVar2;
  undefined *puVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  undefined4 uVar9;
  id local_28;
  
  local_28 = (id)0x0;
  while (pvVar5 = _objc_msgSend(duplicateObjectsInEnumerator,sel_nextObject), pvVar5 != (id)0x0) {
    pvVar8 = _objc_msgSend(pvVar5,sel_localNodeData);
    if (pvVar8 == (id)0x0) {
      pvVar5 = _objc_msgSend(pvVar5,sel_localCopyIncludingNodeUnits_,0);
      pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
    }
    pvVar5 = _objc_msgSend(pvVar5,sel_fullDictionaryRepresentation);
    pvVar8 = _objc_msgSend(cls_HSNode,sel_nodeWithDictionary_,pvVar5);
    if (pvVar8 != (id)0x0) {
      pvVar7 = _objc_msgSend(pvVar8,sel_queryHyperInterface_,&DAT_0037f7b8);
      pvVar6 = _objc_msgSend(pvVar7,sel_mediaUIDs);
      pvVar1 = _objc_msgSend(cls_NSMutableSet,sel_set);
      pvVar7 = _objc_msgSend(pvVar8,sel_queryHyperInterface_,&DAT_0037f7e0);
      self_00 = _objc_msgSend(pvVar7,sel_hyperUID);
      pvVar7 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
      pvVar7 = _objc_msgSend(pvVar7,sel_stack);
      puVar2 = &DAT_0037f8e4;
      pvVar7 = _objc_msgSend(pvVar7,sel_queryHyperInterface_,&DAT_0037f8e4);
      self_01 = _objc_msgSend(pvVar7,sel_hyperEnumerator);
      pvVar7 = _objc_msgSend(self_01,sel_nextObject);
      while (pvVar7 != (id)0x0) {
        puVar2 = _objc_msgSend(pvVar7,sel_hyperUID,puVar2);
        _objc_msgSend(pvVar1,sel_addObject_);
        pvVar7 = _objc_msgSend(pvVar7,sel_hyperEnumerator);
        while (pvVar4 = _objc_msgSend(pvVar7,sel_nextObject,puVar2), pvVar4 != (id)0x0) {
          puVar3 = _objc_msgSend(pvVar4,sel_hyperUID,puVar2);
          puVar2 = puVar3;
          pvVar4 = _objc_msgSend(self_00,sel_isEqual_);
          if ((char)pvVar4 == '\0') {
            _objc_msgSend(pvVar1,sel_addObject_,puVar3);
            puVar2 = puVar3;
          }
        }
        pvVar7 = _objc_msgSend(self_01,sel_nextObject,puVar2);
      }
      pvVar7 = _objc_msgSend(cls_NSMutableSet,sel_setWithSet_,pvVar6);
      _objc_msgSend(pvVar7,sel_unionSet_,pvVar1);
      pvVar5 = _objc_msgSend(pvVar5,sel_mutableCopy);
      _objc_msgSend(pvVar5,sel_refreshHyperUIDsAndIgnoreUIDsFromSet_,pvVar7);
      _objc_msgSend(pvVar8,sel_loadExtraDictionaryRepresentation_,pvVar5);
      _objc_msgSend(pvVar5,sel_release);
      if (local_28 == (id)0x0) {
        local_28 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,0);
      }
      _objc_msgSend(local_28,sel_addObject_,pvVar8);
    }
  }
  if ((local_28 != (id)0x0) && (duplicatedObjects != (id *)0x0)) {
    pvVar5 = _objc_msgSend(local_28,sel_retain);
    pvVar5 = _objc_msgSend(pvVar5,sel_autorelease);
    *duplicatedObjects = pvVar5;
  }
  uVar9 = 0;
  pvVar8 = (id)0x0;
  pvVar5 = local_28;
  _objc_msgSend(self,sel_addObjectsInArray_center_useDragPreferences_,local_28,0,0);
  pvVar6 = _objc_msgSend(local_28,sel_objectEnumerator);
  pvVar7 = _objc_msgSend(pvVar6,sel_nextObject);
  while (pvVar1 = pvVar7, pvVar1 != (id)0x0) {
    pvVar5 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager,pvVar5,pvVar8,
                           uVar9);
    pvVar8 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
    pvVar8 = _objc_msgSend(pvVar8,sel_stack);
    _objc_msgSend(pvVar5,sel_removeObject_forStack_);
    pvVar7 = _objc_msgSend(pvVar6,sel_nextObject);
    pvVar5 = pvVar1;
  }
  return;
}

*/
- (void)duplicateObjectsInEnumerator:(id)aEnumerator duplicatedObjects:(id *)aObjects
{
    NSMutableArray *duplicates = nil;
    id object;
    while ((object = [aEnumerator nextObject]) != nil) {
        if ([object localNodeData] == nil) {
            object = [[object localCopyIncludingNodeUnits:NO] autorelease];
        }
        NSDictionary *representation = [object fullDictionaryRepresentation];
        id duplicate = [HSNode nodeWithDictionary:representation];
        if (duplicate == nil) {
            continue;
        }
        NSSet *mediaUIDs = [[duplicate queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs];
        // Keep the UIDs used elsewhere in the stack; everything else gets fresh ones.
        NSMutableSet *usedUIDs = [NSMutableSet set];
        id ownUID = [[duplicate queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
        NSEnumerator *cards = [[[[_dragHost cardForDragHost] stack] queryHyperInterface:@protocol(HSNodeContainer)] hyperEnumerator];
        id card;
        while ((card = [cards nextObject]) != nil) {
            [usedUIDs addObject:[card hyperUID]];
            NSEnumerator *children = [card hyperEnumerator];
            id child;
            while ((child = [children nextObject]) != nil) {
                id uid = [child hyperUID];
                if (![ownUID isEqual:uid]) {
                    [usedUIDs addObject:uid];
                }
            }
        }
        NSMutableSet *ignoredUIDs = [NSMutableSet setWithSet:mediaUIDs];
        [ignoredUIDs unionSet:usedUIDs];
        NSMutableDictionary *refreshed = [representation mutableCopy];
        [refreshed refreshHyperUIDsAndIgnoreUIDsFromSet:ignoredUIDs];
        [duplicate loadExtraDictionaryRepresentation:refreshed];
        [refreshed release];
        if (duplicates == nil) {
            duplicates = [NSMutableArray arrayWithCapacity:0];
        }
        [duplicates addObject:duplicate];
    }
    if (duplicates != nil && aObjects != NULL) {
        *aObjects = [[duplicates retain] autorelease];
    }
    [self addObjectsInArray:duplicates center:NO useDragPreferences:NO];
    for (id duplicate in [duplicates objectEnumerator]) {
        [[HSCoachingHelpManager sharedCoachingHelpManager] removeObject:duplicate forStack:[[_dragHost cardForDragHost] stack]];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e2cdb @ 001e2cdb, 1124 bytes * /

void FUN_001e2cdb(HSEditorCardViewDragHelper *self,SEL _cmd,id writeObjectsInEnumeratorToPasteboard)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id self_00;
  id self_01;
  id pvVar4;
  undefined *puVar5;
  SEL op;
  id pvVar6;
  undefined *puVar7;
  id local_14;
  
  pvVar1 = _objc_msgSend(writeObjectsInEnumeratorToPasteboard,sel_allObjects);
  pvVar6 = (id)0x0;
  pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,0);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectsByRemovingLinkedObjects);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectEnumerator);
  while (pvVar3 = _objc_msgSend(pvVar1,sel_nextObject,pvVar6), pvVar3 != (id)0x0) {
    pvVar3 = _objc_msgSend(pvVar3,sel_hyperObject);
    if (pvVar3 != (id)0x0) {
      pvVar6 = _objc_msgSend(pvVar3,sel_hasLinkedObjects);
      op = sel_addObject_;
      if ((char)pvVar6 != '\0') {
        local_14 = (id)0x0;
        pvVar6 = _objc_msgSend(pvVar3,sel_localCopyIncludingNodeUnits_copiedLinkedObjects_,0,
                               &local_14);
        pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
        _objc_msgSend(pvVar2,sel_addObject_,pvVar6);
        op = sel_addObjectsFromArray_;
        pvVar3 = local_14;
      }
      _objc_msgSend(pvVar2,op,pvVar3);
      pvVar6 = pvVar3;
    }
  }
  _objc_msgSend(pvVar2,sel_sortByHyperOrder);
  pvVar1 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithCapacity_,0);
  puVar7 = (undefined *)0x0;
  pvVar3 = _objc_msgSend(cls_NSMutableSet,sel_setWithCapacity_,0);
  self_00 = _objc_msgSend(cls_NSMutableSet,sel_set);
  self_01 = _objc_msgSend(pvVar2,sel_objectEnumerator);
  pvVar6 = _objc_msgSend(self_01,sel_nextObject);
  while (pvVar6 != (id)0x0) {
    pvVar4 = _objc_msgSend(pvVar6,sel_localNodeData,puVar7);
    if (pvVar4 == (id)0x0) {
      puVar7 = (undefined *)0x0;
      pvVar6 = _objc_msgSend(pvVar6,sel_localCopyIncludingNodeUnits_,0);
      pvVar6 = _objc_msgSend(pvVar6,sel_autorelease);
    }
    pvVar4 = _objc_msgSend(pvVar6,sel_fullDictionaryRepresentation,puVar7);
    _objc_msgSend(pvVar1,sel_addObject_,pvVar4);
    pvVar4 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0037f7b8);
    pvVar4 = _objc_msgSend(pvVar4,sel_mediaUIDs);
    if (pvVar4 != (id)0x0) {
      _objc_msgSend(pvVar3,sel_unionSet_,pvVar4);
    }
    puVar7 = &DAT_0037f7cc;
    pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0037f7cc);
    puVar5 = _objc_msgSend(pvVar6,sel_unrefreshingUIDs);
    if (puVar5 != (undefined *)0x0) {
      _objc_msgSend(self_00,sel_unionSet_,puVar5);
      puVar7 = puVar5;
    }
    pvVar6 = _objc_msgSend(self_01,sel_nextObject,puVar7);
  }
  _objc_msgSend(self->_copyPasteboardDataProvider,sel_release,puVar7);
  pvVar6 = _objc_msgSend(pvVar2,sel_lastObject);
  pvVar6 = _objc_msgSend(pvVar6,sel_queryHyperInterface_,&DAT_0037f7e0);
  pvVar6 = _objc_msgSend(pvVar6,sel_hyperName);
  puVar7 = cls_HSPasteboardDataProvider;
  pvVar2 = _objc_msgSend(self,sel_zone);
  pvVar2 = _objc_msgSend(puVar7,sel_allocWithZone_,pvVar2);
  pvVar6 = _objc_msgSend(pvVar2,sel_initWithObjects_UIDs_groupUIDs_unrefreshingUIDs_dragName_,pvVar1
                         ,pvVar3,0,self_00,pvVar6);
  self->_copyPasteboardDataProvider = pvVar6;
  pvVar1 = _objc_msgSend(cls_NSPasteboard,sel_generalPasteboard);
  _objc_msgSend(pvVar6,sel_declareTypesForPasteboard_,pvVar1);
  pvVar6 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  _objc_msgSend(pvVar6,sel_resetPasteCount);
  pvVar6 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
  _objc_msgSend(pvVar6,sel_incrementPasteCount);
  return;
}

*/
- (void)writeObjectsInEnumeratorToPasteboard:(id)aPasteboard
{
    // The argument is an enumerator of the objects to copy.
    NSArray *items = [aPasteboard allObjects];
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:0];
    for (id item in [[items objectsByRemovingLinkedObjects] objectEnumerator]) {
        id object = [item hyperObject];
        if (object == nil) {
            continue;
        }
        if ([object hasLinkedObjects]) {
            id linkedObjects = nil;
            [objects addObject:[[object localCopyIncludingNodeUnits:NO copiedLinkedObjects:&linkedObjects] autorelease]];
            [objects addObjectsFromArray:linkedObjects];
        } else {
            [objects addObject:object];
        }
    }
    [objects sortByHyperOrder];
    NSMutableArray *representations = [NSMutableArray arrayWithCapacity:0];
    NSMutableSet *mediaUIDs = [NSMutableSet setWithCapacity:0];
    NSMutableSet *unrefreshingUIDs = [NSMutableSet set];
    for (id object in [objects objectEnumerator]) {
        if ([object localNodeData] == nil) {
            object = [[object localCopyIncludingNodeUnits:NO] autorelease];
        }
        [representations addObject:[object fullDictionaryRepresentation]];
        NSSet *uids = [[object queryHyperInterface:@protocol(HSMediaCopySupport)] mediaUIDs];
        if (uids != nil) {
            [mediaUIDs unionSet:uids];
        }
        uids = [[object queryHyperInterface:@protocol(HSActionCopySupport)] unrefreshingUIDs];
        if (uids != nil) {
            [unrefreshingUIDs unionSet:uids];
        }
    }
    [_copyPasteboardDataProvider release];
    NSString *name = [[[objects lastObject] queryHyperInterface:@protocol(HSObjectAttributes)] hyperName];
    _copyPasteboardDataProvider = [[HSPasteboardDataProvider allocWithZone:[self zone]] initWithObjects:representations UIDs:mediaUIDs groupUIDs:nil unrefreshingUIDs:unrefreshingUIDs dragName:name];
    [_copyPasteboardDataProvider declareTypesForPasteboard:[NSPasteboard generalPasteboard]];
    [[_dragHost cardForDragHost] resetPasteCount];
    [[_dragHost cardForDragHost] incrementPasteCount];
}

- (void)draggedImage:(id)aImage endedAt:(NSPoint)aAt operation:(NSUInteger)aOperation
{
    if (_draggingPasteboardDataProvider != nil) {
        [_draggingPasteboardDataProvider release];
        _draggingPasteboardDataProvider = nil;
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ef451 @ 001ef451, 599 bytes * /

void FUN_001ef451(HSEditorCardViewDragHelper *self,SEL _cmd,id adjustLocationOfObjects,NSRect toRect
                 ,id offsets,float shift)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  float *pfVar6;
  id pvVar7;
  longdouble lVar8;
  longdouble lVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  int iStack_98;
  float local_94;
  undefined1 local_34 [8];
  float local_2c;
  float local_28;
  float local_24;
  float local_20;
  
  pvVar1 = _objc_msgSend(adjustLocationOfObjects,sel_count);
  if ((adjustLocationOfObjects != (id)0x0) && (pvVar1 != (id)0x0)) {
    _objc_msgSend_stret(&local_24,self->_dragHost,sel_convertToDragHostCardRect_);
    pfVar6 = (float *)&stack0xffffff70;
    pvVar2 = _objc_msgSend(offsets,sel_bytes);
    pvVar3 = _objc_msgSend(offsets,sel_length);
    if (pvVar1 != (id)0x0) {
      pvVar7 = (id)0x0;
      do {
        pfVar6[2] = (float)pvVar7;
        pfVar6[1] = (float)sel_objectAtIndex_;
        *pfVar6 = (float)adjustLocationOfObjects;
        pfVar6[-1] = 2.843019e-39;
        pvVar4 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
        pfVar6[2] = (float)&DAT_0037fcb8;
        pfVar6[1] = (float)sel_queryHyperInterface_;
        *pfVar6 = (float)pvVar4;
        pfVar6[-1] = 2.843058e-39;
        pvVar4 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
        pfVar6[1] = (float)sel_queryGeometryBehaviorApplier;
        *pfVar6 = (float)pvVar4;
        pfVar6[-1] = 2.843087e-39;
        pvVar4 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
        if (pvVar4 != (id)0x0) {
          if ((pvVar2 == (id)0x0) || ((id)((uint)pvVar3 >> 3) <= pvVar7)) {
            pfVar6[1] = (float)sel_mutableGeometryAttributes;
            *pfVar6 = (float)pvVar4;
            pfVar6[-1] = 2.843188e-39;
            pvVar5 = _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
            fVar10 = local_20;
            fVar11 = local_24;
            if (pvVar5 != (id)0x0) {
              pfVar6[2] = (float)sel_frameBoundingRect;
              pfVar6[1] = (float)pvVar5;
              *pfVar6 = (float)local_34;
              pfVar6[-1] = 2.843246e-39;
              _objc_msgSend_stret((void *)*pfVar6,(id)pfVar6[1],(SEL)pfVar6[2]);
              pfVar6[-1] = (toRect.size.width - local_2c) * 0.5;
              pfVar6[-2] = 2.843293e-39;
              lVar8 = (longdouble)_rintf();
              pfVar6[-1] = (toRect.size.height - local_28) * 0.5;
              pfVar6[-2] = 2.843337e-39;
              lVar9 = (longdouble)_rintf();
              pfVar6 = pfVar6 + -1;
              fVar10 = (float)lVar9 + local_20;
              fVar11 = (float)lVar8 + local_24;
            }
          }
          else {
            fVar10 = *(float *)((int)pvVar2 + (int)pvVar7 * 8 + 4) + local_20;
            fVar11 = *(float *)((int)pvVar2 + (int)pvVar7 * 8) + local_24;
          }
          fVar12 = (float)((double)(ZEXT48(pvVar7) | 0x4330000000000000) - 4503599627370496.0) *
                   shift;
          *pfVar6 = fVar10 + fVar12;
          pfVar6[-1] = 2.843442e-39;
          lVar8 = (longdouble)_floorf();
          *pfVar6 = fVar12 + fVar11;
          pfVar6[-1] = 2.843467e-39;
          lVar9 = (longdouble)_floorf();
          pfVar6[3] = (float)lVar8;
          pfVar6[2] = (float)lVar9;
          pfVar6[1] = (float)sel_moveFrameBoundingRectOriginTo_withLayoutGuidingContext_;
          *pfVar6 = (float)pvVar4;
          pfVar6[4] = 0.0;
          pfVar6[-1] = 2.843523e-39;
          _objc_msgSend((id)*pfVar6,(SEL)pfVar6[1]);
        }
        pvVar7 = (id)((int)pvVar7 + 1);
      } while (pvVar7 < pvVar1);
    }
  }
  return;
}

*/
- (void)adjustLocationOfObjects:(id)aObjects toRect:(NSRect)aRect offsets:(id)aOffsets shift:(CGFloat)aShift
{
    NSUInteger count = [aObjects count];
    if (aObjects == nil || count == 0) {
        return;
    }
    NSRect cardRect = [_dragHost convertToDragHostCardRect:aRect];
    const NSPoint *offsets = [aOffsets bytes];
    NSUInteger offsetCount = [aOffsets length] / sizeof(NSPoint);
    for (NSUInteger i = 0; i < count; i++) {
        id applier = [[[aObjects objectAtIndex:i] queryHyperInterface:@protocol(HSGeometryBehaviorAdapting)] queryGeometryBehaviorApplier];
        if (applier == nil) {
            continue;
        }
        float x = cardRect.origin.x;
        float y = cardRect.origin.y;
        if (offsets == NULL || i >= offsetCount) {
            // No offset: centre the object in the drop rectangle.
            id geometry = [applier mutableGeometryAttributes];
            if (geometry != nil) {
                NSRect frame = [geometry frameBoundingRect];
                x = rintf((float)((aRect.size.width - frame.size.width) * 0.5)) + x;
                y = rintf((float)((aRect.size.height - frame.size.height) * 0.5)) + y;
            }
        } else {
            x = offsets[i].x + x;
            y = offsets[i].y + y;
        }
        // Each further object is moved down and right by the shift.
        float shift = (float)i * aShift;
        [applier moveFrameBoundingRectOriginTo:NSMakePoint(floorf(shift + x), floorf(y + shift)) withLayoutGuidingContext:nil];
    }
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001ef6a8 @ 001ef6a8, 3687 bytes * /

BOOL FUN_001ef6a8(HSEditorCardViewDragHelper *self,SEL _cmd,id tryToReadFromPasteboard,
                 id acceptingObject,BOOL alignCenter,BOOL orAdjustLocation,NSRect toRect,
                 BOOL *runAnimationMode,BOOL *didAddNewObject,BOOL isPasting,uint dragOperation,
                 BOOL useDragPreferences)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  id pvVar5;
  id pvVar6;
  id pvVar7;
  id pvVar8;
  float extraout_EDX;
  float extraout_EDX_00;
  BOOL BVar9;
  BOOL BVar10;
  int *piVar11;
  int *piVar12;
  int iVar13;
  undefined *puVar14;
  BOOL local_bd;
  id local_b0;
  id local_ac;
  id local_a8;
  float local_a4;
  float local_a0;
  float local_9c;
  float local_98;
  float local_94;
  float local_90;
  float local_8c;
  float local_88;
  id local_80;
  char local_79;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_54 [64];
  id local_14;
  
  piVar11 = (int *)&stack0xffffff04;
  local_14 = acceptingObject;
  pvVar2 = _objc_msgSend(tryToReadFromPasteboard,sel_types);
  pvVar2 = _objc_msgSend(pvVar2,sel_containsObject_);
  if ((char)pvVar2 != '\0') {
    pvVar2 = _objc_msgSend(cls_HSCoachingHelpManager,sel_sharedCoachingHelpManager);
    _objc_msgSend(pvVar2,sel_disableObjectRegistration);
  }
  _objc_msgSend(self,sel_invalidateMediaDictionary);
  local_78 = (id)0x0;
  local_79 = '\0';
  pvVar2 = _objc_msgSend(self,sel_canRecieveDataFromPasteboard_acceptingObject_dragOperation_);
  if ((char)pvVar2 != '\0') {
    local_bd = alignCenter;
    if (local_14 == (id)0x0) {
      _objc_msgSend(self,sel_defaultAcceptingObject);
    }
    pvVar2 = _objc_msgSend(self,
                           sel_readFromPasteboard_acceptingObject_createdObjects_runAnimationMode_dragOperation_useDragPreferences_pastingNotHSObject_
                          );
    if ((char)pvVar2 != '\0') {
      pvVar2 = _objc_msgSend(local_78,sel_count);
      if (pvVar2 == (id)0x0) {
LAB_001ef800:
        BVar9 = '\0';
        piVar11 = (int *)&stack0xffffff04;
      }
      else {
        if ((runAnimationMode != (BOOL *)0x0) && (*runAnimationMode != '\0')) {
          pvVar2 = _objc_msgSend(self->_dragHost,sel_respondsToSelector_);
          if ((char)pvVar2 == '\0') {
            pvVar2 = _objc_msgSend(self,sel_editorDocument);
            pvVar2 = _objc_msgSend(pvVar2,sel_editorWindowController);
            pvVar2 = _objc_msgSend(pvVar2,sel_cardView);
            pvVar3 = _objc_msgSend(pvVar2,sel_respondsToSelector_);
            if ((char)pvVar3 == '\0') {
              pvVar2 = (id)0x0;
            }
          }
          else {
            pvVar2 = self->_dragHost;
          }
          puVar14 = cls_NSInvocation;
          _objc_msgSend(pvVar2,sel_methodSignatureForSelector_);
          pvVar2 = _objc_msgSend(puVar14,sel_invocationWithMethodSignature_);
          local_80 = _objc_msgSend(local_78,sel_objectAtIndex_);
          _objc_msgSend(pvVar2,sel_setArgument_atIndex_);
          _objc_msgSend(pvVar2,sel_setArgument_atIndex_);
          _objc_msgSend(pvVar2,sel_setTarget_);
          _objc_msgSend(pvVar2,sel_setSelector_);
          _objc_msgSend(cls_NSTimer,sel_scheduledTimerWithTimeInterval_invocation_repeats_);
          pvVar2 = _objc_msgSend(self,sel_editorDocument);
          if (local_14 != (id)0x0) {
            _objc_msgSend(cls_NSArray,sel_arrayWithObject_);
          }
          _objc_msgSend(pvVar2,sel_selectInEditorCardViewObjects_);
          goto LAB_001ef800;
        }
        pvVar2 = _objc_msgSend(cls_NSMutableArray,sel_array);
        pvVar3 = _objc_msgSend(local_78,sel_objectEnumerator);
        while (pvVar4 = _objc_msgSend(pvVar3,sel_nextObject), pvVar4 != (id)0x0) {
          pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_);
          if (pvVar4 != (id)0x0) {
            _objc_msgSend(pvVar2,sel_addObject_);
            pvVar5 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
            _objc_msgSend(pvVar5,sel_support);
            _objc_msgSend(pvVar4,sel_setSupport_);
          }
        }
        pvVar3 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
        pvVar3 = _objc_msgSend(pvVar3,sel_undoManager);
        _objc_msgSend(pvVar3,sel_disableUndoRegistration);
        pvVar3 = _objc_msgSend(tryToReadFromPasteboard,sel_types);
        pvVar4 = _objc_msgSend(pvVar3,sel_containsObject_);
        piVar11 = (int *)&stack0xffffff04;
        if ((char)pvVar4 == '\0') {
          pvVar4 = _objc_msgSend(self->_dragHost,sel_cardForDragHost);
          pvVar4 = _objc_msgSend(pvVar4,sel_queryHyperInterface_);
          pvVar4 = _objc_msgSend(pvVar4,sel_size);
          pvVar5 = _objc_msgSend(local_78,sel_objectEnumerator);
          local_a8 = _objc_msgSend(pvVar5,sel_nextObject);
          piVar11 = (int *)&stack0xffffff04;
          if (local_a8 != (id)0x0) {
            piVar12 = (int *)&stack0xffffff04;
            do {
              piVar12[2] = (int)&DAT_00380190;
              piVar12[1] = (int)sel_queryHyperInterface_;
              *piVar12 = (int)local_a8;
              piVar12[-1] = 0x1efdbf;
              pvVar7 = _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
              piVar11 = piVar12;
              if (pvVar7 != (id)0x0) {
                piVar12[2] = (int)&cfstr_HSLibraryPboardType;
                piVar12[1] = (int)sel_containsObject_;
                *piVar12 = (int)pvVar3;
                piVar12[-1] = 0x1efde5;
                pvVar7 = _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                piVar12[2] = (int)&DAT_003801f4;
                piVar12[1] = (int)sel_queryHyperInterface_;
                *piVar12 = (int)local_a8;
                piVar12[-1] = 0x1efe09;
                pvVar8 = _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                if (pvVar8 == (id)0x0) {
                  if ((char)pvVar7 == '\0') {
                    piVar12[2] = (int)&DAT_0037f934;
                    piVar12[1] = (int)sel_queryHyperInterface_;
                    *piVar12 = (int)local_a8;
                    piVar12[-1] = 0x1efe3b;
                    pvVar7 = _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                    if (pvVar7 != (id)0x0) {
                      piVar12[2] = (int)&cfstr_HSLibraryObjectsPasteboardType;
                      piVar12[1] = (int)sel_containsObject_;
                      *piVar12 = (int)pvVar3;
                      piVar12[-1] = 0x1efe67;
                      pvVar8 = _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                      if ((char)pvVar8 == '\0') {
                        piVar12[2] = (int)&DAT_0037ff38;
                        piVar12[1] = (int)sel_queryHyperInterface_;
                        *piVar12 = (int)local_a8;
                        piVar12[-1] = 0x1efe91;
                        pvVar8 = _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                        piVar12[3] = (int)(extraout_EDX * 0.25);
                        piVar12[2] = (int)((float)pvVar4 * 0.25);
                        piVar12[1] = (int)sel_setSize_;
                        *piVar12 = (int)pvVar8;
                        piVar12[-1] = 0x1efebf;
                        _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                        piVar12[1] = (int)sel_hyperText;
                        *piVar12 = (int)pvVar7;
                        piVar12[-1] = 0x1efed1;
                        pvVar8 = _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                        piVar12[3] = (int)((float)pvVar4 * 0.25);
                        piVar12[2] = (int)pvVar8;
                        piVar12[1] = (int)sel_hyperSizeForAttributedString_withWidth_fixedWidth_;
                        *piVar12 = (int)cls_NSTextStorage;
                        piVar12[4] = 1;
                        piVar12[-1] = 0x1eff03;
                        _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                        if (extraout_EDX_00 <= extraout_EDX * 0.25) {
                          piVar12[1] = (int)sel_setHasVerticalScroller_;
                          *piVar12 = (int)pvVar7;
                          piVar12[2] = 0;
                          piVar12[-1] = 0x1eff32;
                          _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                        }
                        goto LAB_001efd77;
                      }
                    }
                    piVar12[2] = (int)&DAT_003804ec;
                    piVar12[1] = (int)sel_implementsHyperInterface_;
                    *piVar12 = (int)local_a8;
                    piVar12[-1] = 0x1eff59;
                    pvVar7 = _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                    if ((char)pvVar7 != '\0') {
                      piVar12[3] = (int)extraout_EDX;
                      piVar12[2] = (int)pvVar4;
                      piVar12[1] = (int)sel_stretchIfNeededToCardSize_;
                      *piVar12 = (int)local_a8;
                      piVar12[-1] = 0x1eff95;
                      _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                    }
                  }
                }
                else {
                  piVar12[2] = (int)pvVar8;
                  piVar12[1] = (int)sel_cropApplierForImageObject_;
                  *piVar12 = (int)cls_HSImageCropApplier;
                  piVar12[-1] = 0x1efc2d;
                  pvVar6 = _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                  piVar12[1] = (int)sel_updateCurrentBorderPath;
                  *piVar12 = (int)pvVar6;
                  piVar12[-1] = 0x1efc3f;
                  _objc_msgSend((id)*piVar12,(SEL)piVar12[1]);
                  if ((char)pvVar7 == '\0') {
                    piVar12[2] = (int)sel_imageRect;
                    piVar12[1] = (int)pvVar8;
                    *piVar12 = (int)&local_94;
                    piVar12[-1] = 0x1efc63;
                    _objc_msgSend_stret((void *)*piVar12,(id)piVar12[1],(SEL)piVar12[2]);
                    local_a4 = local_94;
                    local_a0 = local_90;
                    local_9c = local_8c;
                    local_98 = local_88;
                    *piVar12 = (int)sel_types;
                    piVar12[-1] = (int)tryToReadFromPasteboard;
                    piVar12[-2] = 0x1efcbb;
                    pvVar7 = _objc_msgSend((id)piVar12[-1],(SEL)*piVar12);
                    piVar12[1] = (int)&cfstr_BTArchivedImageRegionPboardType;
                    *piVar12 = (int)sel_containsObject_;
                    piVar12[-1] = (int)pvVar7;
                    piVar12[-2] = 0x1efcd7;
                    pvVar7 = _objc_msgSend((id)piVar12[-1],(SEL)*piVar12);
                    piVar11 = piVar12 + -1;
                    if ((char)pvVar7 != '\0') {
                      piVar12[1] = (int)&DAT_0038035c;
                      *piVar12 = (int)sel_queryHyperInterface_;
                      piVar12[-1] = (int)local_a8;
                      piVar12[-2] = 0x1efd01;
                      pvVar7 = _objc_msgSend((id)piVar12[-1],(SEL)*piVar12);
                      piVar11 = piVar12 + -1;
                      if (pvVar7 != (id)0x0) {
                        piVar12[1] = (int)sel_frameBoundingRect;
                        *piVar12 = (int)pvVar7;
                        piVar12[-1] = (int)&local_a4;
                        piVar12[-2] = 0x1efd21;
                        _objc_msgSend_stret((void *)piVar12[-1],(id)*piVar12,(SEL)piVar12[1]);
                        piVar11 = piVar12 + -2;
                        if ((((0.0 <= local_a4) && (piVar11 = piVar12 + -2, 0.0 <= local_a0)) &&
                            (piVar11 = piVar12 + -2, local_a4 + local_9c <= (float)pvVar4)) &&
                           (piVar11 = piVar12 + -2, local_a0 + local_98 <= extraout_EDX)) {
                          local_bd = '\0';
                          piVar11 = piVar12 + -2;
                        }
                      }
                    }
                  }
                }
              }
LAB_001efd77:
              piVar11[1] = (int)sel_nextObject;
              *piVar11 = (int)pvVar5;
              piVar11[-1] = 0x1efd8f;
              local_a8 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
              piVar12 = piVar11;
            } while (local_a8 != (id)0x0);
          }
        }
        if ((orAdjustLocation != '\0') && (local_bd == '\0')) {
          piVar11[2] = (int)&cfstr_HSEditorPasteboardType;
          piVar11[1] = (int)sel_containsObject_;
          *piVar11 = (int)pvVar3;
          piVar11[-1] = 0x1effd3;
          _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
          piVar11[2] = (int)&cfstr_HSObjectsOriginOffsetsPasteboardType;
          piVar11[1] = (int)sel_containsObject_;
          *piVar11 = (int)pvVar3;
          piVar11[-1] = 0x1effef;
          pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
          if ((char)pvVar4 == '\0') {
            pvVar4 = (id)0x0;
          }
          else {
            piVar11[2] = (int)&cfstr_HSObjectsOriginOffsetsPasteboardType;
            piVar11[1] = (int)sel_dataForType_;
            *piVar11 = (int)tryToReadFromPasteboard;
            piVar11[-1] = 0x1f0010;
            pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
          }
          pvVar5 = local_78;
          *(NSSize *)(piVar11 + 5) = toRect.size;
          *(NSPoint *)(piVar11 + 3) = toRect.origin;
          piVar11[7] = (int)pvVar4;
          piVar11[2] = (int)pvVar5;
          piVar11[1] = (int)sel_adjustLocationOfObjects_toRect_offsets_shift_;
          *piVar11 = (int)self;
          piVar11[8] = 0;
          piVar11[-1] = 0x1f0050;
          _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
        }
        pvVar4 = self->_dragHost;
        piVar11[1] = (int)sel_cardForDragHost;
        *piVar11 = (int)pvVar4;
        piVar11[-1] = 0x1f0068;
        pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
        piVar11[1] = (int)sel_undoManager;
        *piVar11 = (int)pvVar4;
        piVar11[-1] = 0x1f007a;
        pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
        piVar11[1] = (int)sel_enableUndoRegistration;
        *piVar11 = (int)pvVar4;
        piVar11[-1] = 0x1f008c;
        _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
        piVar11[2] = (int)sel_setSupport_;
        piVar11[1] = (int)sel_makeObjectsPerformSelector_withObject_;
        *piVar11 = (int)pvVar2;
        piVar11[3] = 0;
        piVar11[-1] = 0x1f00b6;
        _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
        pvVar2 = local_78;
        if (local_14 != (id)0x0) {
          local_74 = 0;
          local_70 = 0;
          local_6c = (int *)0x0;
          local_68 = 0;
          local_64 = 0;
          local_60 = 0;
          local_5c = 0;
          local_58 = 0;
          piVar11[3] = (int)local_54;
          piVar11[2] = (int)&local_74;
          piVar11[1] = (int)sel_countByEnumeratingWithState_objects_count_;
          *piVar11 = (int)pvVar2;
          piVar11[4] = 0x10;
          piVar11[-1] = 0x1f0129;
          local_b0 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
          if (local_b0 == (id)0x0) {
            local_ac = (id)0x0;
          }
          else {
            iVar13 = *local_6c;
            local_ac = (id)0x0;
            do {
              local_a8 = (id)0x0;
              do {
                if (iVar13 != *local_6c) {
                  *piVar11 = (int)local_78;
                  piVar11[-1] = 0x1f03af;
                  _objc_enumerationMutation();
                }
                uVar1 = *(undefined4 *)(local_70 + (int)local_a8 * 4);
                piVar11[2] = (int)&DAT_0037fd08;
                piVar11[1] = (int)sel_queryHyperInterface_;
                *piVar11 = uVar1;
                local_a8 = (id)((int)local_a8 + 1);
                piVar11[-1] = 0x1f03de;
                pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                if (pvVar4 != (id)0x0) {
                  piVar11[1] = (int)sel_movies;
                  *piVar11 = (int)pvVar4;
                  piVar11[-1] = 0x1f03fa;
                  pvVar5 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                  piVar11[1] = (int)sel_extraFirstObject;
                  *piVar11 = (int)pvVar5;
                  piVar11[-1] = 0x1f040c;
                  pvVar5 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                  puVar14 = sel_movieObjectForCard_;
                  if (pvVar5 == (id)0x0) {
                    piVar11[1] = (int)sel_liveVideos;
                    *piVar11 = (int)pvVar4;
                    piVar11[-1] = 0x1f0228;
                    pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                    piVar11[1] = (int)sel_extraFirstObject;
                    *piVar11 = (int)pvVar4;
                    piVar11[-1] = 0x1f023a;
                    pvVar5 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                    puVar14 = sel_liveObjectForCard_;
                    if (pvVar5 == (id)0x0) goto LAB_001f0345;
                  }
                  piVar11[1] = (int)puVar14;
                  *piVar11 = (int)pvVar5;
                  piVar11[2] = 0;
                  piVar11[-1] = 0x1f025c;
                  pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                  piVar11[1] = (int)sel_setHidden_;
                  *piVar11 = (int)pvVar4;
                  piVar11[2] = 1;
                  piVar11[-1] = 0x1f0278;
                  _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                  piVar11[2] = (int)&DAT_0037f7e0;
                  piVar11[1] = (int)sel_queryHyperInterface_;
                  *piVar11 = (int)pvVar4;
                  piVar11[-1] = 0x1f0294;
                  pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                  piVar11[1] = (int)sel_hyperUID;
                  *piVar11 = (int)pvVar4;
                  piVar11[-1] = 0x1f02a6;
                  pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                  if (pvVar4 != (id)0x0) {
                    piVar11[2] = (int)&cfstr_HSShowHideObjectAction;
                    piVar11[1] = (int)sel_actionOfType_;
                    *piVar11 = (int)cls_HSAction;
                    piVar11[-1] = 0x1f02d2;
                    pvVar5 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                    piVar11[2] = (int)pvVar4;
                    piVar11[1] = (int)sel_addObjectUID_action_showEffectSettings_hideEffectSettings_
                    ;
                    *piVar11 = (int)pvVar5;
                    piVar11[5] = 0;
                    piVar11[4] = 0;
                    piVar11[3] = 1;
                    piVar11[-1] = 0x1f0302;
                    _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                    if (local_ac == (id)0x0) {
                      piVar11[1] = (int)sel_array;
                      *piVar11 = (int)cls_NSMutableArray;
                      piVar11[-1] = 0x1f0323;
                      local_ac = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                    }
                    piVar11[2] = (int)pvVar5;
                    piVar11[1] = (int)sel_addObject_;
                    *piVar11 = (int)local_ac;
                    piVar11[-1] = 0x1f0345;
                    _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
                  }
                }
LAB_001f0345:
              } while (local_a8 < local_b0);
              piVar11[3] = (int)local_54;
              piVar11[2] = (int)&local_74;
              piVar11[1] = (int)sel_countByEnumeratingWithState_objects_count_;
              *piVar11 = (int)pvVar2;
              piVar11[4] = 0x10;
              piVar11[-1] = 0x1f0381;
              local_b0 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
            } while (local_b0 != (id)0x0);
          }
          piVar11[1] = (int)sel_count;
          *piVar11 = (int)local_ac;
          piVar11[-1] = 0x1f0153;
          pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
          pvVar2 = local_78;
          if (pvVar4 != (id)0x0) {
            piVar11[2] = (int)local_ac;
            piVar11[1] = (int)sel_arrayByAddingObjectsFromArray_;
            *piVar11 = (int)pvVar2;
            piVar11[-1] = 0x1f0176;
            local_78 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
          }
          iVar13 = (int)local_79;
          piVar11[2] = (int)&cfstr_HSEditorPasteboardType;
          piVar11[1] = (int)sel_containsObject_;
          *piVar11 = (int)pvVar3;
          piVar11[-1] = 0x1f019f;
          pvVar4 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
          pvVar3 = local_14;
          pvVar2 = local_78;
          piVar11[8] = iVar13;
          piVar11[7] = (int)useDragPreferences;
          piVar11[6] = (int)isPasting;
          piVar11[5] = (uint)((char)pvVar4 == '\0');
          piVar11[4] = (int)local_bd;
          piVar11[3] = (int)pvVar3;
          piVar11[2] = (int)pvVar2;
          piVar11[1] = (int)
                       sel_addObjectsInArray_intoObject_center_fitCanvas_isPasting_useDragPreferences_pastingNotHSObject_
          ;
          *piVar11 = (int)self;
          BVar10 = '\x01';
          piVar11[-1] = 0x1f01f1;
          pvVar2 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
          BVar9 = (BOOL)pvVar2;
          goto LAB_001f0490;
        }
        iVar13 = (int)local_79;
        piVar11[2] = (int)&cfstr_HSEditorPasteboardType;
        piVar11[1] = (int)sel_containsObject_;
        *piVar11 = (int)pvVar3;
        piVar11[-1] = 0x1f0445;
        pvVar3 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
        pvVar2 = local_78;
        piVar11[7] = iVar13;
        piVar11[6] = (int)useDragPreferences;
        piVar11[5] = (int)isPasting;
        piVar11[4] = (uint)((char)pvVar3 == '\0');
        piVar11[3] = (int)local_bd;
        piVar11[2] = (int)pvVar2;
        piVar11[1] = (int)
                     sel_addObjectsInArray_center_fitCanvas_isPasting_useDragPreferences_pastingNotHSObject_
        ;
        *piVar11 = (int)self;
        piVar11[-1] = 0x1f048e;
        pvVar2 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
        BVar9 = (BOOL)pvVar2;
      }
      BVar10 = '\x01';
      goto LAB_001f0490;
    }
  }
  BVar9 = '\0';
  BVar10 = BVar9;
LAB_001f0490:
  if (didAddNewObject != (BOOL *)0x0) {
    *didAddNewObject = BVar9;
  }
  piVar11[1] = (int)sel_types;
  *piVar11 = (int)tryToReadFromPasteboard;
  piVar11[-1] = 0x1f04b0;
  pvVar2 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
  piVar11[2] = (int)&cfstr_HSObjectsPasteboardType;
  piVar11[1] = (int)sel_containsObject_;
  *piVar11 = (int)pvVar2;
  piVar11[-1] = 0x1f04cc;
  pvVar2 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
  if ((char)pvVar2 != '\0') {
    piVar11[1] = (int)sel_sharedCoachingHelpManager;
    *piVar11 = (int)cls_HSCoachingHelpManager;
    piVar11[-1] = 0x1f04e8;
    pvVar2 = _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
    piVar11[1] = (int)sel_enableObjectRegistration;
    *piVar11 = (int)pvVar2;
    piVar11[-1] = 0x1f04fd;
    _objc_msgSend((id)*piVar11,(SEL)piVar11[1]);
  }
  return BVar10;
}

*/
- (BOOL)tryToReadFromPasteboard:(id)aPasteboard acceptingObject:(id)aObject alignCenter:(BOOL)aCenter orAdjustLocation:(BOOL)aLocation toRect:(NSRect)aRect runAnimationMode:(BOOL *)aMode didAddNewObject:(BOOL *)aObject2 isPasting:(BOOL)aPasting dragOperation:(NSUInteger)aOperation useDragPreferences:(BOOL)aPreferences
{
    BOOL hasObjectsType = [[aPasteboard types] containsObject:@"HSObjectsPasteboardType"];
    if (hasObjectsType) {
        [[HSCoachingHelpManager sharedCoachingHelpManager] disableObjectRegistration];
    }
    [self invalidateMediaDictionary];
    NSArray *created = nil;
    BOOL pastingNotHSObject = NO;
    BOOL result = NO;
    BOOL didAdd = NO;
    if ([self canRecieveDataFromPasteboard:aPasteboard acceptingObject:aObject dragOperation:aOperation]) {
        BOOL center = aCenter;
        id target = aObject != nil ? aObject : [self defaultAcceptingObject];
        if ([self readFromPasteboard:aPasteboard acceptingObject:target createdObjects:&created runAnimationMode:aMode dragOperation:aOperation useDragPreferences:aPreferences pastingNotHSObject:&pastingNotHSObject]) {
            result = YES;
            if ([created count] != 0) {
                if (aMode != NULL && *aMode) {
                    id invocationTarget;
                    if ([_dragHost respondsToSelector:@selector(startAnimationModeForObject:actingObject:)]) {
                        invocationTarget = _dragHost;
                    } else {
                        invocationTarget = [[[self editorDocument] editorWindowController] cardView];
                        if (![invocationTarget respondsToSelector:@selector(startAnimationModeForObject:actingObject:)]) {
                            invocationTarget = nil;
                        }
                    }
                    if (invocationTarget != nil) {
                        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[invocationTarget methodSignatureForSelector:@selector(startAnimationModeForObject:actingObject:)]];
                        id firstObject = [created objectAtIndex:0];
                        [invocation setArgument:&firstObject atIndex:2];
                        [invocation setArgument:&aObject atIndex:3];
                        [invocation setTarget:invocationTarget];
                        [invocation setSelector:@selector(startAnimationModeForObject:actingObject:)];
                        [NSTimer scheduledTimerWithTimeInterval:0.0 invocation:invocation repeats:NO];
                    }
                    [[self editorDocument] selectInEditorCardViewObjects:(aObject != nil ? [NSArray arrayWithObject:aObject] : nil)];
                    result = YES;
                    didAdd = NO;
                    goto finish;
                }
                NSMutableArray *supported = [NSMutableArray array];
                NSEnumerator *enumerator = [created objectEnumerator];
                id object;
                while ((object = [enumerator nextObject]) != nil) {
                    id child = [object queryHyperInterface:@protocol(HSNodeChild)];
                    if (child != nil) {
                        [supported addObject:child];
                        [child setSupport:[[_dragHost cardForDragHost] support]];
                    }
                }
                [[[_dragHost cardForDragHost] undoManager] disableUndoRegistration];
                NSArray *types = [aPasteboard types];
                if (![types containsObject:@"HSEditorPasteboardType"]) {
                    NSSize cardSize = [[[_dragHost cardForDragHost] queryHyperInterface:@protocol(HSSizeAttributes)] size];
                    CGFloat quarterWidth = cardSize.width * 0.25;
                    CGFloat quarterHeight = cardSize.height * 0.25;
                    enumerator = [created objectEnumerator];
                    while ((object = [enumerator nextObject]) != nil) {
                        if ([object queryHyperInterface:@protocol(HSNodeChild)] == nil) {
                            continue;
                        }
                        BOOL isLibrary = [types containsObject:@"HSLibraryPboardType"];
                        id imageAttributes = [object queryHyperInterface:@protocol(HSImageObjectAttributes)];
                        if (imageAttributes != nil) {
                            [[HSImageCropApplier cropApplierForImageObject:imageAttributes] updateCurrentBorderPath];
                            if (!isLibrary) {
                                NSRect bounds = [imageAttributes imageRect];
                                if ([types containsObject:@"BTArchivedImageRegionPboardType"]) {
                                    id geometry = [object queryHyperInterface:@protocol(HSGeometryAttributes)];
                                    if (geometry != nil) {
                                        bounds = [geometry frameBoundingRect];
                                        if (bounds.origin.x >= 0.0 && bounds.origin.y >= 0.0
                                            && bounds.origin.x + bounds.size.width <= cardSize.width
                                            && bounds.origin.y + bounds.size.height <= cardSize.height) {
                                            center = NO;
                                        }
                                    }
                                }
                            }
                        } else if (!isLibrary) {
                            id textView = [object queryHyperInterface:@protocol(HSSystemTextViewAttributes)];
                            if (textView != nil && ![types containsObject:@"HSLibraryObjectsPasteboardType"]) {
                                [[object queryHyperInterface:@protocol(HSMutableSizeAttributes)] setSize:NSMakeSize(quarterWidth, quarterHeight)];
                                NSSize textSize = [NSTextStorage hyperSizeForAttributedString:[textView hyperText] withWidth:quarterWidth fixedWidth:YES];
                                if (textSize.height <= quarterHeight) {
                                    [textView setHasVerticalScroller:NO];
                                }
                            }
                            if ([object implementsHyperInterface:@protocol(HSMovieAttributes)]) {
                                [object stretchIfNeededToCardSize:cardSize];
                            }
                        }
                    }
                }
                if (aLocation && !center) {
                    [types containsObject:@"HSEditorPasteboardType"];
                    NSData *offsets = [types containsObject:@"HSObjectsOriginOffsetsPasteboardType"] ? [aPasteboard dataForType:@"HSObjectsOriginOffsetsPasteboardType"] : nil;
                    [self adjustLocationOfObjects:created toRect:aRect offsets:offsets shift:NO];
                }
                [[[_dragHost cardForDragHost] undoManager] enableUndoRegistration];
                [supported makeObjectsPerformSelector:@selector(setSupport:) withObject:nil];
                if (aObject != nil) {
                    NSMutableArray *showHideActions = nil;
                    for (id createdObject in created) {
                        id playMovie = [createdObject queryHyperInterface:@protocol(HSPlayMovieActionAttributes)];
                        if (playMovie == nil) {
                            continue;
                        }
                        id first = [[playMovie movies] extraFirstObject];
                        SEL objectSelector = @selector(movieObjectForCard:);
                        if (first == nil) {
                            first = [[playMovie liveVideos] extraFirstObject];
                            objectSelector = @selector(liveObjectForCard:);
                            if (first == nil) {
                                continue;
                            }
                        }
                        id movieObject = [first performSelector:objectSelector withObject:nil];
                        [movieObject setHidden:YES];
                        id uid = [[movieObject queryHyperInterface:@protocol(HSObjectAttributes)] hyperUID];
                        if (uid != nil) {
                            id action = [HSAction actionOfType:@"HSShowHideObjectAction"];
                            [action addObjectUID:uid action:1 showEffectSettings:nil hideEffectSettings:nil];
                            if (showHideActions == nil) {
                                showHideActions = [NSMutableArray array];
                            }
                            [showHideActions addObject:action];
                        }
                    }
                    if ([showHideActions count] != 0) {
                        created = [created arrayByAddingObjectsFromArray:showHideActions];
                    }
                    didAdd = [self addObjectsInArray:created intoObject:aObject center:center fitCanvas:![types containsObject:@"HSEditorPasteboardType"] isPasting:aPasting useDragPreferences:aPreferences pastingNotHSObject:pastingNotHSObject];
                } else {
                    didAdd = [self addObjectsInArray:created center:center fitCanvas:![types containsObject:@"HSEditorPasteboardType"] isPasting:aPasting useDragPreferences:aPreferences pastingNotHSObject:pastingNotHSObject];
                }
            }
        }
    }
finish:
    if (aObject2 != NULL) {
        *aObject2 = didAdd;
    }
    if ([[aPasteboard types] containsObject:@"HSObjectsPasteboardType"]) {
        [[HSCoachingHelpManager sharedCoachingHelpManager] enableObjectRegistration];
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001f050f @ 001f050f, 812 bytes * /

BOOL FUN_001f050f(HSEditorCardViewDragHelper *self,SEL _cmd,id performDragOperation,
                 id acceptingObject,BOOL *runAnimationMode,BOOL *didAddNewObject)

{
  BOOL BVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  uint uVar5;
  float extraout_EDX;
  float extraout_EDX_00;
  undefined4 extraout_EDX_01;
  undefined4 extraout_EDX_02;
  uint uVar6;
  float extraout_EDX_03;
  float extraout_EDX_04;
  bool bVar7;
  id local_4c;
  undefined4 local_48;
  id local_44;
  float local_40;
  undefined8 local_34;
  undefined8 local_2c;
  id local_24;
  float fStack_20;
  id local_1c;
  undefined4 uStack_18;
  
  pvVar2 = _objc_msgSend(self->_dragHost,sel_allowsDragSession);
  if ((char)pvVar2 == '\0') {
    BVar1 = '\0';
  }
  else {
    _objc_msgSend(self,sel_invalidateMediaDictionary);
    pvVar2 = _objc_msgSend(performDragOperation,sel_draggingLocation);
    pvVar3 = _objc_msgSend(performDragOperation,sel_draggedImage);
    if (pvVar3 == (id)0x0) {
      local_4c = *(id *)PTR_0033607c;
      local_48 = *(undefined4 *)(PTR_0033607c + 4);
      local_44 = pvVar2;
      local_40 = extraout_EDX;
    }
    else {
      local_44 = _objc_msgSend(performDragOperation,sel_draggedImageLocation);
      local_4c = _objc_msgSend(pvVar3,sel_size);
      local_48 = extraout_EDX_01;
      local_40 = extraout_EDX_00;
    }
    pvVar3 = _objc_msgSend(self->_dragHost,sel_needImageOriginConvertion);
    if ((char)pvVar3 != '\0') {
      pvVar3 = self->_dragHost;
      pvVar4 = _objc_msgSend(pvVar3,sel_convertPoint_fromView_,pvVar2,extraout_EDX,0);
      uVar6 = (int)(extraout_EDX - local_40) >> 0x1f;
      pvVar3 = _objc_msgSend(pvVar3,sel_convertPointFromDragHostToCard_,pvVar4,extraout_EDX_02);
      uVar5 = (int)((float)pvVar2 - (float)local_44) >> 0x1f;
      local_44 = _objc_msgSend(self->_dragHost,sel_convertPoint_toView_,
                               (float)pvVar3 -
                               (float)(int)((int)((float)pvVar2 - (float)local_44) + uVar5 ^ uVar5),
                               extraout_EDX_03 -
                               (float)(int)((int)(extraout_EDX - local_40) + uVar6 ^ uVar6),0);
      local_40 = extraout_EDX_04;
    }
    local_24 = local_44;
    fStack_20 = local_40;
    local_1c = local_4c;
    uStack_18 = local_48;
    _objc_msgSend_stret(&local_34,self->_dragHost,sel_convertRect_fromView_,
                        CONCAT44(local_40,local_44),CONCAT44(local_48,local_4c),0);
    pvVar2 = self->_draggingPasteboardDataProvider;
    pvVar3 = _objc_msgSend(performDragOperation,sel_draggingSourceOperationMask);
    bVar7 = self->_draggingPasteboardDataProvider != (id)0x0;
    pvVar4 = _objc_msgSend(performDragOperation,sel_draggingPasteboard);
    pvVar2 = _objc_msgSend(self,
                           sel_tryToReadFromPasteboard_acceptingObject_alignCenter_orAdjustLocation_toRect_runAnimationMode_didAddNewObject_isPasting_dragOperation_useDragPreferences_
                           ,pvVar4,acceptingObject,0,1,local_34,local_2c,0,didAddNewObject,bVar7,
                           pvVar3,CONCAT11(bVar7,pvVar2 == (id)0x0) & 0xff);
    BVar1 = (BOOL)pvVar2;
  }
  return BVar1;
}

*/
- (BOOL)performDragOperation:(id)aOperation acceptingObject:(id)aObject runAnimationMode:(BOOL *)aMode didAddNewObject:(BOOL *)aObject2
{
    if (![_dragHost allowsDragSession]) {
        return NO;
    }
    [self invalidateMediaDictionary];
    NSPoint location = [aOperation draggingLocation];
    NSImage *image = [aOperation draggedImage];
    NSPoint origin;
    NSSize size;
    if (image == nil) {
        size = NSZeroSize;
        origin = location;
    } else {
        origin = [aOperation draggedImageLocation];
        size = [image size];
    }
    if ([_dragHost needImageOriginConvertion]) {
        // Keep the pointer's offset inside the image when converting to the card.
        NSPoint cardPoint = [_dragHost convertPointFromDragHostToCard:[_dragHost convertPoint:location fromView:nil]];
        int dx = abs((int)(float)(location.x - origin.x));
        int dy = abs((int)(float)(location.y - origin.y));
        origin = [_dragHost convertPoint:NSMakePoint(cardPoint.x - dx, cardPoint.y - dy) toView:nil];
    }
    NSRect rect = [_dragHost convertRect:NSMakeRect(origin.x, origin.y, size.width, size.height) fromView:nil];
    BOOL isInternalDrag = _draggingPasteboardDataProvider != nil;
    // The original passes no run-animation-mode flag here.
    return [self tryToReadFromPasteboard:[aOperation draggingPasteboard] acceptingObject:aObject alignCenter:NO orAdjustLocation:YES toRect:rect runAnimationMode:NULL didAddNewObject:aObject2 isPasting:isInternalDrag dragOperation:[aOperation draggingSourceOperationMask] useDragPreferences:!isInternalDrag];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e2bc9 @ 001e2bc9, 220 bytes * /

BOOL FUN_001e2bc9(HSEditorCardViewDragHelper *self,SEL _cmd,id performDragOperation,
                 id acceptingObject)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  bool bVar4;
  
  _objc_msgSend(self,sel_invalidateMediaDictionary);
  pvVar3 = self->_draggingPasteboardDataProvider;
  pvVar1 = _objc_msgSend(performDragOperation,sel_draggingSourceOperationMask);
  bVar4 = self->_draggingPasteboardDataProvider != (id)0x0;
  pvVar2 = _objc_msgSend(performDragOperation,sel_draggingPasteboard);
  pvVar3 = _objc_msgSend(self,
                         sel_tryToReadFromPasteboard_acceptingObject_alignCenter_orAdjustLocation_toRect_runAnimationMode_didAddNewObject_isPasting_dragOperation_useDragPreferences_
                         ,pvVar2,acceptingObject,0,1,*(undefined8 *)PTR_00336078,
                         *(undefined8 *)(PTR_00336078 + 8),0,0,bVar4,pvVar1,
                         CONCAT11(bVar4,pvVar3 == (id)0x0) & 0xff);
  return (BOOL)pvVar3;
}

*/
- (BOOL)performDragOperation:(id)aOperation acceptingObject:(id)aObject
{
    [self invalidateMediaDictionary];
    BOOL isInternalDrag = _draggingPasteboardDataProvider != nil;
    return [self tryToReadFromPasteboard:[aOperation draggingPasteboard] acceptingObject:aObject alignCenter:NO orAdjustLocation:YES toRect:NSZeroRect runAnimationMode:NULL didAddNewObject:NULL isPasting:isInternalDrag dragOperation:[aOperation draggingSourceOperationMask] useDragPreferences:!isInternalDrag];
}

- (void)concludeDragOperation:(id)aOperation
{

}

- (void)draggingExited:(id)aExited
{

}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e2af5 @ 001e2af5, 212 bytes * /

uint FUN_001e2af5(HSEditorCardViewDragHelper *self,SEL _cmd,id draggingUpdated)

{
  id pvVar1;
  id pvVar2;
  uint uVar3;
  uint uVar4;
  
  pvVar1 = _objc_msgSend(self->_dragHost,sel_allowsDragSession);
  if (((char)pvVar1 == '\0') || ((self->_canRecieveDrag & 1) == 0)) {
    uVar3 = 0;
  }
  else {
    pvVar1 = _objc_msgSend(draggingUpdated,sel_draggingSourceOperationMask);
    pvVar2 = _objc_msgSend(draggingUpdated,sel_draggingPasteboard);
    _objc_msgSend(self,sel_canRecieveDataWhileDraggingFromPasteboard_,pvVar2);
    pvVar2 = _objc_msgSend(pvVar2,sel_types);
    uVar4 = 1;
    if (((uint)pvVar1 & 1) == 0) {
      uVar4 = 0x10;
    }
    pvVar1 = _objc_msgSend(pvVar2,sel_containsObject_,&cfstr_HSCardsIndexPasteboardType);
    uVar3 = 2;
    if ((char)pvVar1 == '\0') {
      uVar3 = uVar4;
    }
  }
  return uVar3;
}

*/
- (NSUInteger)draggingUpdated:(id)aUpdated
{
    if (![_dragHost allowsDragSession] || !_canRecieveDrag) {
        return NSDragOperationNone;
    }
    NSDragOperation sourceMask = [aUpdated draggingSourceOperationMask];
    NSPasteboard *pasteboard = [aUpdated draggingPasteboard];
    // Called for its side effects only; the result is ignored as in the original.
    [self canRecieveDataWhileDraggingFromPasteboard:pasteboard];
    if ([[pasteboard types] containsObject:@"HSCardsIndexPasteboardType"]) {
        return NSDragOperationLink;
    }
    return (sourceMask & NSDragOperationCopy) ? NSDragOperationCopy : NSDragOperationMove;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e2a61 @ 001e2a61, 148 bytes * /

uint FUN_001e2a61(HSEditorCardViewDragHelper *self,SEL _cmd,id draggingEntered)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(draggingEntered,sel_draggingPasteboard);
  pvVar2 = _objc_msgSend(self->_dragHost,sel_allowsDragSession);
  if ((char)pvVar2 != '\0') {
    pvVar1 = _objc_msgSend(self,sel_canRecieveDataWhileDraggingFromPasteboard_,pvVar1);
    self->_canRecieveDrag = self->_canRecieveDrag & 0xfffffffe | (uint)((byte)pvVar1 & 1);
    if (((uint)pvVar1 & 1) != 0) {
      pvVar1 = _objc_msgSend(self,sel_draggingUpdated_,draggingEntered);
      return (uint)pvVar1;
    }
  }
  return 0;
}

*/
- (NSUInteger)draggingEntered:(id)aEntered
{
    NSPasteboard *pasteboard = [aEntered draggingPasteboard];
    if (![_dragHost allowsDragSession]) {
        return NSDragOperationNone;
    }
    _canRecieveDrag = [self canRecieveDataWhileDraggingFromPasteboard:pasteboard];
    if (!_canRecieveDrag) {
        return NSDragOperationNone;
    }
    return [self draggingUpdated:aEntered];
}

- (id)pasteboardTypes
{
    return [[NSArray arrayWithObjects:@"HSObjectsPasteboardType", @"HSLibraryObjectsPasteboardType", NSFilenamesPboardType, NSURLPboardType, NSTIFFPboardType, NSRTFPboardType, NSRTFDPboardType, NSStringPboardType, @"HSSerializedRichTextPasteboardType", @"CorePasteboardFlavorType 0x6974756E", nil] arrayByAddingObjectsFromArray:[NSImage imagePasteboardTypes]];
}

- (id)editorDocument
{
    return [[_dragHost cardForDragHost] document];
}

- (void)dealloc
{
    [_mediaDictionary release];
    [_draggingPasteboardDataProvider release];
    [_copyPasteboardDataProvider release];
    [_cashedImageDataFromRTFDPasteboard release];
    [super dealloc];
}

- (void)invalidateDragHost
{
    [_dragHost unregisterDraggedTypes];
    _dragHost = nil;
}

- (id)initWithDragHost:(id)aHost
{
    self = [super init];
    if (self != nil) {
        _dragHost = aHost;
        [aHost registerForDraggedTypes:[self pasteboardTypes]];
    }
    return self;
}

@end

@implementation NSArray (HSNodeSelectionSupport)

/* --- i386 decompilation (Ghidra) ---
/* FUN_001e7055 @ 001e7055, 442 bytes * /

id FUN_001e7055(id self,SEL _cmd)

{
  int iVar1;
  id self_00;
  id pvVar2;
  undefined4 *puVar3;
  id pvVar4;
  id pvVar5;
  undefined1 *puVar6;
  undefined4 uVar7;
  id local_78;
  undefined4 local_74;
  int local_70;
  int *local_6c;
  undefined4 local_68;
  undefined4 local_64;
  undefined4 local_60;
  undefined4 local_5c;
  undefined4 local_58;
  undefined1 local_50 [64];
  
  pvVar2 = _objc_msgSend(cls_NSMutableSet,sel_setWithCapacity_,0);
  local_74 = 0;
  local_70 = 0;
  local_6c = (int *)0x0;
  local_68 = 0;
  local_64 = 0;
  local_60 = 0;
  local_5c = 0;
  local_58 = 0;
  puVar6 = local_50;
  puVar3 = &local_74;
  uVar7 = 0x10;
  local_78 = _objc_msgSend(self,sel_countByEnumeratingWithState_objects_count_,puVar3,puVar6,0x10);
  if (local_78 != (id)0x0) {
    iVar1 = *local_6c;
    do {
      pvVar5 = (id)0x0;
      do {
        if (iVar1 != *local_6c) {
          _objc_enumerationMutation(self);
        }
        self_00 = *(id *)(local_70 + (int)pvVar5 * 4);
        puVar3 = _objc_msgSend(cls_HSNode,sel_class,puVar3,puVar6,uVar7);
        pvVar4 = _objc_msgSend(self_00,sel_isKindOfClass_);
        if ((char)pvVar4 != '\0') {
          puVar3 = _objc_msgSend(self_00,sel_linkedObjects,puVar3);
          _objc_msgSend(pvVar2,sel_addObjectsFromArray_,puVar3);
        }
        pvVar5 = (id)((int)pvVar5 + 1);
      } while (pvVar5 < local_78);
      puVar6 = local_50;
      puVar3 = &local_74;
      uVar7 = 0x10;
      local_78 = _objc_msgSend(self,sel_countByEnumeratingWithState_objects_count_,puVar3,puVar6,
                               0x10);
    } while (local_78 != (id)0x0);
  }
  pvVar5 = _objc_msgSend(cls_NSMutableArray,sel_arrayWithArray_,self,puVar6,uVar7);
  pvVar2 = _objc_msgSend(pvVar2,sel_allObjects);
  _objc_msgSend(pvVar5,sel_removeObjectsInArray_,pvVar2);
  return pvVar5;
}

*/
- (id)objectsByRemovingLinkedObjects
{
    NSMutableSet *linkedObjects = [NSMutableSet setWithCapacity:0];
    for (id object in self) {
        if ([object isKindOfClass:[HSNode class]]) {
            [linkedObjects addObjectsFromArray:[object linkedObjects]];
        }
    }
    NSMutableArray *objects = [NSMutableArray arrayWithArray:self];
    [objects removeObjectsInArray:[linkedObjects allObjects]];
    return objects;
}

@end

