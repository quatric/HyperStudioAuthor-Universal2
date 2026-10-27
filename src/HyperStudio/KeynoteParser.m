#import "KeynoteParser.h"
#import "KeynoteNode.h"

@implementation KeynoteParser

/* i386 ivar offsets: _fileWrapperRepresentation=0x4, _xmlTree=0x8, _delegate=0xc, _parentObject=0x10 */

/* --- i386 decompilation (Ghidra) ---
/* FUN_000baa06 @ 000baa06, 123 bytes * /

id FUN_000baa06(id self,SEL _cmd,CFTree *xmlTreeNamespace)

{
  undefined4 uVar1;
  id pvVar2;
  id pvVar3;
  
  uVar1 = _CFXMLTreeGetNode(xmlTreeNamespace);
  pvVar2 = (id)_CFXMLNodeGetString(uVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_componentsSeparatedByString_,&cfstr__);
  pvVar3 = _objc_msgSend(pvVar2,sel_count);
  if (pvVar3 < (id)0x2) {
    pvVar2 = (id)0x0;
  }
  else {
    pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,0);
  }
  return pvVar2;
}

*/
+ (id)xmlTreeNamespace:(struct __CFTree *)aNamespace
{
    NSString *string = (NSString *)CFXMLNodeGetString(CFXMLTreeGetNode(aNamespace));
    NSArray *components = [string componentsSeparatedByString:@":"];
    if ([components count] < 2) {
        return nil;
    }
    return [components objectAtIndex:0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000baa81 @ 000baa81, 112 bytes * /

id FUN_000baa81(id self,SEL _cmd,CFTree *xmlTreeName)

{
  undefined *self_00;
  undefined4 uVar1;
  int iVar2;
  cfstringStruct *pcVar3;
  
  uVar1 = _CFXMLTreeGetNode(xmlTreeName);
  iVar2 = _CFXMLNodeGetTypeCode(uVar1);
  self_00 = cls_KeynoteParser;
  if (iVar2 == 6) {
    pcVar3 = &cfstr_text;
  }
  else if (iVar2 == 7) {
    pcVar3 = &cfstr_C_D_A_T_A;
  }
  else {
    uVar1 = _CFXMLTreeGetNode(xmlTreeName);
    uVar1 = _CFXMLNodeGetString(uVar1);
    pcVar3 = _objc_msgSend(self_00,sel_xmlName_,uVar1);
  }
  return pcVar3;
}

*/
+ (id)xmlTreeName:(struct __CFTree *)aName
{
    CFXMLNodeTypeCode type = CFXMLNodeGetTypeCode(CFXMLTreeGetNode(aName));
    if (type == kCFXMLNodeTypeText) {
        return @"text";
    }
    if (type == kCFXMLNodeTypeCDATASection) {
        return @"C-D-A-T-A";
    }
    return [KeynoteParser xmlName:(NSString *)CFXMLNodeGetString(CFXMLTreeGetNode(aName))];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000baaf1 @ 000baaf1, 120 bytes * /

id FUN_000baaf1(id self,SEL _cmd,id xmlName)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(xmlName,sel_componentsSeparatedByString_,&cfstr__);
  pvVar2 = _objc_msgSend(pvVar1,sel_count);
  pvVar1 = _objc_msgSend(pvVar1,sel_objectAtIndex_,(uint)((id)0x1 < pvVar2));
  return pvVar1;
}

*/
+ (id)xmlName:(id)aName
{
    NSArray *components = [aName componentsSeparatedByString:@":"];
    return [components objectAtIndex:([components count] > 1) ? 1 : 0];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bab69 @ 000bab69, 371 bytes * /

id FUN_000bab69(id self,SEL _cmd,CFTree *xmlTreeAttributes)

{
  id self_00;
  undefined4 uVar1;
  int iVar2;
  undefined4 *puVar3;
  id pvVar4;
  id pvVar5;
  id self_01;
  id pvVar6;
  id pvVar7;
  
  if (xmlTreeAttributes != (CFTree *)0x0) {
    uVar1 = _CFXMLTreeGetNode(xmlTreeAttributes);
    iVar2 = _CFXMLNodeGetTypeCode(uVar1);
    if (iVar2 == 2) {
      puVar3 = (undefined4 *)_CFXMLNodeGetInfoPtr(uVar1);
      self_00 = (id)*puVar3;
      pvVar4 = _objc_msgSend(cls_NSDictionary,sel_class);
      pvVar5 = _objc_msgSend(self_00,sel_isKindOfClass_,pvVar4);
      if ((char)pvVar5 == '\0') {
        return self_00;
      }
      pvVar4 = _objc_msgSend(self_00,sel_allKeys,pvVar4);
      pvVar5 = _objc_msgSend(pvVar4,sel_count);
      self_01 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionaryWithCapacity_,pvVar5);
      if ((int)pvVar5 < 1) {
        return self_01;
      }
      iVar2 = 0;
      do {
        pvVar6 = _objc_msgSend(pvVar4,sel_objectAtIndex_,iVar2);
        pvVar7 = _objc_msgSend(cls_KeynoteParser,sel_xmlName_,pvVar6);
        pvVar6 = _objc_msgSend(self_00,sel_objectForKey_,pvVar6);
        _objc_msgSend(self_01,sel_setObject_forKey_,pvVar6,pvVar7);
        iVar2 = iVar2 + 1;
      } while (iVar2 < (int)pvVar5);
      return self_01;
    }
  }
  return (id)0x0;
}

*/
+ (id)xmlTreeAttributes:(struct __CFTree *)aAttributes
{
    if (aAttributes == NULL) {
        return nil;
    }
    CFXMLNodeRef node = CFXMLTreeGetNode(aAttributes);
    if (CFXMLNodeGetTypeCode(node) != kCFXMLNodeTypeElement) {
        return nil;
    }
    NSDictionary *attributes = (NSDictionary *)((const CFXMLElementInfo *)CFXMLNodeGetInfoPtr(node))->attributes;
    if (![attributes isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSArray *keys = [attributes allKeys];
    NSInteger count = [keys count];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        id key = [keys objectAtIndex:i];
        [result setObject:[attributes objectForKey:key] forKey:[KeynoteParser xmlName:key]];
    }
    return result;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bacdc @ 000bacdc, 377 bytes * /

CFTree * FUN_000bacdc(id self,SEL _cmd,CFTree *xmlTree,id findTreeForPath)

{
  id self_00;
  id pvVar1;
  id self_01;
  id pvVar2;
  id local_14;
  
  self_00 = _objc_msgSend(findTreeForPath,sel_componentsSeparatedByString_,&cfstr__);
  pvVar1 = _objc_msgSend(self_00,sel_count);
  if ((pvVar1 != (id)0x0) && (xmlTree != (CFTree *)0x0)) {
    local_14 = (id)0x0;
    do {
      self_01 = _objc_msgSend(self_00,sel_objectAtIndex_,local_14);
      pvVar2 = _objc_msgSend(self_01,sel_isEqual_,&cfstr_empty);
      if ((char)pvVar2 == '\0') {
        pvVar2 = _objc_msgSend(self_01,sel_isEqual_,&cfstr___);
        if ((char)pvVar2 == '\0') {
          pvVar2 = _objc_msgSend(self_01,sel_isEqual_,&cfstr__);
          if ((char)pvVar2 == '\0') {
            for (xmlTree = (CFTree *)_CFTreeGetFirstChild(xmlTree); xmlTree != (CFTree *)0x0;
                xmlTree = (CFTree *)_CFTreeGetNextSibling(xmlTree)) {
              pvVar2 = _objc_msgSend(cls_KeynoteParser,sel_xmlTreeName_,xmlTree);
              pvVar2 = _objc_msgSend(pvVar2,sel_isEqual_,self_01);
              if ((char)pvVar2 != '\0') break;
            }
          }
        }
        else {
          xmlTree = (CFTree *)_CFTreeGetParent(xmlTree);
        }
      }
      else if (local_14 == (id)0x0) {
        xmlTree = (CFTree *)_CFTreeFindRoot(xmlTree);
      }
    } while (((id)((int)local_14 + 1U) < pvVar1) &&
            (local_14 = (id)((int)local_14 + 1U), xmlTree != (CFTree *)0x0));
  }
  return xmlTree;
}

*/
+ (struct __CFTree *)xmlTree:(struct __CFTree *)aTree findTreeForPath:(id)aPath
{
    NSArray *components = [aPath componentsSeparatedByString:@"/"];
    NSUInteger count = [components count];
    if (count == 0 || aTree == NULL) {
        return aTree;
    }
    CFXMLTreeRef tree = aTree;
    for (NSUInteger i = 0; i < count && tree != NULL; i++) {
        NSString *component = [components objectAtIndex:i];
        if ([component isEqual:@""]) {
            if (i == 0) {
                tree = CFTreeFindRoot(tree);
            }
        }
        else if ([component isEqual:@".."]) {
            tree = CFTreeGetParent(tree);
        }
        else if (![component isEqual:@"."]) {
            for (tree = CFTreeGetFirstChild(tree); tree != NULL; tree = CFTreeGetNextSibling(tree)) {
                if ([[KeynoteParser xmlTreeName:tree] isEqual:component]) {
                    break;
                }
            }
        }
    }
    return tree;
}

+ (NSInteger)countXMLTree:(struct __CFTree *)aTree forTag:(id)aTag
{
    int iVar1;
    int iVar2;
    int iVar5;

    iVar1 = CFTreeGetChildCount(aTree);
    iVar2 = iVar1;
    if (aTag != nil) {
        if (iVar1 < 1) {
            iVar2 = 0;
        }
        else {
            iVar5 = 0;
            iVar2 = 0;
            do {
                iVar2 = iVar2 + (unsigned int)([[KeynoteParser xmlName:[KeynoteParser xmlTreeName:(CFTreeGetChildAtIndex(aTree,iVar5))]] isEqualToString:aTag]);
                iVar5 = iVar5 + 1;
            } while (iVar1 != iVar5);
        }
    }
    return iVar2;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000baf10 @ 000baf10, 301 bytes * /

id FUN_000baf10(KeynoteParser *self,SEL _cmd,CFTree *objectForXMLTree,id parentObject)

{
  id pvVar1;
  id pvVar2;
  
  pvVar1 = _objc_msgSend(cls_KeynoteParser,sel_xmlTreeName_,objectForXMLTree);
  pvVar2 = _objc_msgSend(cls_KeynoteTools,sel_classForXMLTreeName_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_new);
  _objc_msgSend(pvVar2,sel_setXmlTree_,objectForXMLTree);
  _objc_msgSend(pvVar2,sel_setName_,pvVar1);
  if (parentObject != (id)0x0) {
    pvVar1 = _objc_msgSend(parentObject,sel_rootNode,pvVar1);
    if (pvVar1 == (id)0x0) {
      pvVar1 = parentObject;
    }
    _objc_msgSend(pvVar2,sel_setRootNode_,pvVar1);
    _objc_msgSend(pvVar2,sel_setParentNode_,parentObject);
    pvVar1 = _objc_msgSend(parentObject,sel_importManager);
    _objc_msgSend(pvVar2,sel_setImportManager_,pvVar1);
  }
  _objc_msgSend(pvVar2,sel_didInitFromParser,pvVar1);
  pvVar1 = _objc_msgSend(pvVar2,sel_autorelease);
  return pvVar1;
}

*/
- (id)objectForXMLTree:(struct __CFTree *)aTree parentObject:(id)aObject
{
    NSString *name = [KeynoteParser xmlTreeName:aTree];
    id object = [[KeynoteTools classForXMLTreeName:name] new];
    [object setXmlTree:aTree];
    [(KeynoteNode *)object setName:name];
    if (aObject != nil) {
        id rootNode = [aObject rootNode];
        [object setRootNode:(rootNode != nil) ? rootNode : aObject];
        [object setParentNode:aObject];
        [object setImportManager:[aObject importManager]];
    }
    [object didInitFromParser];
    return [object autorelease];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bb03d @ 000bb03d, 930 bytes * /

id FUN_000bb03d(KeynoteParser *self,SEL _cmd)

{
  id pvVar1;
  id pvVar2;
  id pvVar3;
  id pvVar4;
  cfstringStruct *pcVar5;
  id self_00;
  id pvVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  id local_1c;
  
  pvVar1 = _objc_msgSend(cls_KeynotePresentation,sel_new);
  pvVar2 = _objc_msgSend(cls_KeynotePackageContent,sel_new);
  pvVar3 = _objc_msgSend(self->_fileWrapperRepresentation,sel_fileWrappers);
  pcVar5 = &cfstr_theme_files;
  pvVar4 = _objc_msgSend(pvVar3,sel_objectForKey_,&cfstr_theme_files);
  local_1c = pvVar3;
  if (pvVar4 != (id)0x0) {
    local_1c = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary,pcVar5);
    _objc_msgSend(local_1c,sel_addEntriesFromDictionary_,pvVar3);
    pcVar5 = _objc_msgSend(pvVar4,sel_fileWrappers);
    _objc_msgSend(local_1c,sel_addEntriesFromDictionary_,pcVar5);
  }
  pvVar4 = _objc_msgSend(cls_NSMutableDictionary,sel_dictionary,pcVar5);
  pvVar3 = _objc_msgSend(local_1c,sel_allValues);
  self_00 = _objc_msgSend(pvVar3,sel_objectEnumerator);
  pvVar3 = _objc_msgSend(self_00,sel_nextObject);
  while (pvVar3 != (id)0x0) {
    pvVar6 = _objc_msgSend(pvVar3,sel_isRegularFile,pcVar5);
    if ((char)pvVar6 != '\0') {
      pvVar6 = _objc_msgSend(pvVar3,sel_filename);
      pcVar5 = _objc_msgSend(pvVar3,sel_regularFileContents);
      _objc_msgSend(pvVar4,sel_setObject_forKey_,pcVar5,pvVar6);
    }
    pvVar3 = _objc_msgSend(self_00,sel_nextObject,pcVar5);
  }
  _objc_msgSend(pvVar2,sel_setResources_,pvVar4);
  pvVar3 = _objc_msgSend(local_1c,sel_objectForKey_,&cfstr_index_apxl);
  pvVar3 = _objc_msgSend(pvVar3,sel_regularFileContents);
  if (pvVar3 == (id)0x0) {
    pcVar5 = &cfstr_index_apxl_gz;
    pvVar3 = _objc_msgSend(local_1c,sel_objectForKey_,&cfstr_index_apxl_gz);
    pvVar4 = _objc_msgSend(pvVar3,sel_regularFileContents);
    pvVar3 = (id)0x0;
    if (pvVar4 != (id)0x0) {
      pvVar3 = _objc_msgSend(pvVar4,sel_hyperDataWithGzipUnpack,pcVar5);
    }
  }
  if (pvVar3 != (id)0x0) {
    uVar7 = _CFXMLTreeCreateFromData(*(undefined4 *)PTR_003363a4,pvVar3,0,8,1);
    uVar8 = _CFTreeGetChildAtIndex(uVar7,1);
    _objc_msgSend(pvVar2,sel_setIndexXmlTree_,uVar8);
    _objc_msgSend(pvVar1,sel_setXmlTree_,uVar8);
    pvVar3 = _objc_msgSend(cls_KeynoteParser,sel_xmlTreeName_,uVar8);
    _objc_msgSend(pvVar1,sel_setName_,pvVar3);
    _CFRelease(uVar7);
  }
  _objc_msgSend(pvVar1,sel_setRootNode_,pvVar1);
  _objc_msgSend(pvVar1,sel_setParentNode_,pvVar1);
  pvVar2 = _objc_msgSend(pvVar2,sel_autorelease);
  _objc_msgSend(pvVar1,sel_setContent_,pvVar2);
  _objc_msgSend(pvVar1,sel_setXmlPath_,&cfstr__presentation);
  _objc_msgSend(pvVar1,sel_didInitFromParser);
  pvVar1 = _objc_msgSend(pvVar1,sel_autorelease);
  return pvVar1;
}

*/
- (id)keynotePresentation
{
    KeynotePresentation *presentation = [KeynotePresentation new];
    KeynotePackageContent *content = [KeynotePackageContent new];
    NSDictionary *fileWrappers = [_fileWrapperRepresentation fileWrappers];
    NSFileWrapper *themeFiles = [fileWrappers objectForKey:@"theme-files"];
    if (themeFiles != nil) {
        NSMutableDictionary *allWrappers = [NSMutableDictionary dictionary];
        [allWrappers addEntriesFromDictionary:fileWrappers];
        [allWrappers addEntriesFromDictionary:[themeFiles fileWrappers]];
        fileWrappers = allWrappers;
    }
    NSMutableDictionary *resources = [NSMutableDictionary dictionary];
    for (NSFileWrapper *wrapper in [fileWrappers allValues]) {
        if ([wrapper isRegularFile]) {
            [resources setObject:[wrapper regularFileContents] forKey:[wrapper filename]];
        }
    }
    [content setResources:resources];
    NSData *indexData = [[fileWrappers objectForKey:@"index.apxl"] regularFileContents];
    if (indexData == nil) {
        NSData *packedData = [[fileWrappers objectForKey:@"index.apxl.gz"] regularFileContents];
        if (packedData != nil) {
            indexData = [packedData hyperDataWithGzipUnpack];
        }
    }
    if (indexData != nil) {
        CFXMLTreeRef document = CFXMLTreeCreateFromData(kCFAllocatorDefault, (CFDataRef)indexData, NULL, kCFXMLParserSkipWhitespace, kCFXMLNodeCurrentVersion);
        CFXMLTreeRef root = CFTreeGetChildAtIndex(document, 1);
        [content setIndexXmlTree:root];
        [presentation setXmlTree:root];
        [presentation setName:[KeynoteParser xmlTreeName:root]];
        CFRelease(document);
    }
    [presentation setRootNode:presentation];
    [presentation setParentNode:presentation];
    [presentation setContent:[content autorelease]];
    [presentation setXmlPath:@"/presentation"];
    [presentation didInitFromParser];
    return [presentation autorelease];
}

- (id)namespace
{
    return [KeynoteParser xmlTreeNamespace:_xmlTree];
}

- (id)name
{
    return [KeynoteParser xmlTreeName:_xmlTree];
}

- (id)attributes
{
    return [KeynoteParser xmlTreeAttributes:_xmlTree];
}

- (struct __CFTree *)findTreeForPath:(id)aPath
{
    return [KeynoteParser xmlTree:_xmlTree findTreeForPath:aPath];
}

- (id)parseXMLTree:(struct __CFTree *)aTree resultAsArray:(id)aArray
{
    int iVar1;
    id pvVar3;
    int iVar4;

    iVar1 = CFTreeGetChildCount(aTree);
    if (0 < iVar1) {
        iVar4 = 0;
        do {
            pvVar3 = [self _parseXMLTree:(CFTreeGetChildAtIndex(aTree,iVar4))];
            if (pvVar3 != nil) {
                [aArray addObject:pvVar3];
            }
            iVar4 = iVar4 + 1;
        } while (iVar1 != iVar4);
    }
    return aArray;
}

- (id)parseXMLTree:(struct __CFTree *)aTree resultAsDictionary:(id)aDictionary
{
    int iVar1;
    id pvVar3;
    int iVar5;

    iVar1 = CFTreeGetChildCount(aTree);
    if (0 < iVar1) {
        iVar5 = 0;
        do {
            pvVar3 = [self _parseXMLTree:(CFTreeGetChildAtIndex(aTree,iVar5))];
            if (pvVar3 != nil) {
                [aDictionary setObject:pvVar3 forKey:[KeynoteParser xmlTreeName:aTree]];
            }
            iVar5 = iVar5 + 1;
        } while (iVar1 != iVar5);
    }
    return aDictionary;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bb5d3 @ 000bb5d3, 326 bytes * /

void FUN_000bb5d3(KeynoteParser *self,SEL _cmd,id specifyDetailForKeynoteObject)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  int iVar3;
  undefined4 uVar4;
  int iVar5;
  
  self_00 = _objc_msgSend(cls_NSAutoreleasePool,sel_new);
  self->_parentObject = specifyDetailForKeynoteObject;
  pvVar1 = _objc_msgSend(specifyDetailForKeynoteObject,sel_xmlTree);
  pvVar2 = _objc_msgSend(cls_KeynoteParser,sel_xmlTreeAttributes_,pvVar1);
  _objc_msgSend(specifyDetailForKeynoteObject,sel_setNodeAttributes_,pvVar2);
  if (pvVar1 != (id)0x0) {
    iVar3 = _CFTreeGetChildCount(pvVar1);
    if (0 < iVar3) {
      iVar5 = 0;
      do {
        uVar4 = _CFTreeGetChildAtIndex(pvVar1,iVar5);
        pvVar2 = _objc_msgSend(self,sel_objectForXMLTree_parentObject_,uVar4,
                               specifyDetailForKeynoteObject);
        _objc_msgSend(self,sel__parseXMLTree_,uVar4);
        _objc_msgSend(specifyDetailForKeynoteObject,sel_addChild_,pvVar2);
        iVar5 = iVar5 + 1;
      } while (iVar3 != iVar5);
    }
    _objc_msgSend(specifyDetailForKeynoteObject,sel_didDetail,pvVar2);
  }
  _objc_msgSend(self_00,sel_release,pvVar2);
  return;
}

*/
- (void)specifyDetailForKeynoteObject:(id)aObject
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    _parentObject = aObject;
    CFXMLTreeRef tree = [aObject xmlTree];
    [aObject setNodeAttributes:[KeynoteParser xmlTreeAttributes:tree]];
    if (tree != NULL) {
        CFIndex count = CFTreeGetChildCount(tree);
        for (CFIndex i = 0; i < count; i++) {
            CFXMLTreeRef child = CFTreeGetChildAtIndex(tree, i);
            id object = [self objectForXMLTree:child parentObject:aObject];
            [self _parseXMLTree:child];
            [aObject addChild:object];
        }
        [aObject didDetail];
    }
    [pool release];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bb719 @ 000bb719, 138 bytes * /

void FUN_000bb719(KeynoteParser *self,SEL _cmd,CFTree *parseXMLTree,Class targetClass,
                 id currentObject)

{
  id pvVar1;
  
  pvVar1 = _objc_msgSend(targetClass,sel_alloc);
  pvVar1 = _objc_msgSend(pvVar1,sel_initWithXMLTree_context_,parseXMLTree,0);
  _objc_msgSend(pvVar1,sel_setDelegate_,self);
  _objc_msgSend(pvVar1,sel_parseXML);
  _objc_msgSend(pvVar1,sel_release);
  return;
}

*/
- (void)parseXMLTree:(struct __CFTree *)aTree targetClass:(Class)aClass currentObject:(id)aObject
{
    KeynoteParser *parser = [[aClass alloc] initWithXMLTree:aTree context:nil];
    [parser setDelegate:self];
    [parser parseXML];
    [parser release];
}

- (void)parseXMLTree:(struct __CFTree *)aTree
{
    int iVar1;
    int iVar3;

    iVar1 = CFTreeGetChildCount(aTree);
    if (0 < iVar1) {
        iVar3 = 0;
        do {
            [self _parseXMLTree:(CFTreeGetChildAtIndex(aTree,iVar3))];
            iVar3 = iVar3 + 1;
        } while (iVar1 != iVar3);
    }
}

- (void)parseXML
{
    [self parseXMLTree:_xmlTree];
    [[self delegate] keynoteParser:self didParseProperties:[self extraDictionaryRepresentation]];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bb86d @ 000bb86d, 384 bytes * /

id FUN_000bb86d(KeynoteParser *self,SEL _cmd,CFTree *_parseXMLTree)

{
  undefined *self_00;
  id pvVar1;
  undefined4 uVar2;
  id pvVar3;
  id pvVar4;
  
  self_00 = cls_KeynoteTools;
  if (self->_delegate == (id)0x0) {
    pvVar4 = (id)0x0;
  }
  else {
    pvVar1 = _objc_msgSend(cls_KeynoteParser,sel_xmlTreeName_,_parseXMLTree);
    pvVar1 = _objc_msgSend(self_00,sel_parseSelectorNameSuffixForXMLTreeName_,pvVar1);
    pvVar4 = _objc_msgSend(cls_NSMutableString,sel_stringWithFormat_,&cfstr_parse___,pvVar1);
    uVar2 = _NSSelectorFromString(pvVar4);
    pvVar4 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,uVar2);
    if ((char)pvVar4 == '\0') {
      pvVar4 = (id)0x0;
    }
    else {
      pvVar4 = _objc_msgSend(self->_delegate,sel_performSelector_withObject_,uVar2,_parseXMLTree);
    }
    pvVar3 = _objc_msgSend(cls_NSMutableString,sel_stringWithFormat_,
                           &cfstr_parse__WithAttributes_xmlTree_,pvVar1);
    uVar2 = _NSSelectorFromString(pvVar3);
    pvVar3 = _objc_msgSend(self->_delegate,sel_respondsToSelector_,uVar2);
    if ((char)pvVar3 != '\0') {
      pvVar4 = self->_delegate;
      pvVar1 = _objc_msgSend(cls_KeynoteParser,sel_xmlTreeAttributes_,_parseXMLTree,pvVar1);
      pvVar4 = _objc_msgSend(pvVar4,sel_performSelector_withObject_withObject_,uVar2,pvVar1,
                             _parseXMLTree);
    }
  }
  return pvVar4;
}

*/
- (id)_parseXMLTree:(struct __CFTree *)aTree
{
    if (_delegate == nil) {
        return nil;
    }
    NSString *suffix = [KeynoteTools parseSelectorNameSuffixForXMLTreeName:[KeynoteParser xmlTreeName:aTree]];
    SEL selector = NSSelectorFromString([NSMutableString stringWithFormat:@"parse%@:", suffix]);
    id result = nil;
    if ([_delegate respondsToSelector:selector]) {
        result = [_delegate performSelector:selector withObject:(id)aTree];
    }
    selector = NSSelectorFromString([NSMutableString stringWithFormat:@"parse%@WithAttributes:xmlTree:", suffix]);
    if ([_delegate respondsToSelector:selector]) {
        result = [_delegate performSelector:selector withObject:[KeynoteParser xmlTreeAttributes:aTree] withObject:(id)aTree];
    }
    return result;
}

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000bb9ed @ 000bb9ed, 51 bytes * /

void FUN_000bb9ed(KeynoteParser *self,SEL _cmd,CFTree *setXmlTree)

{
  CFTree *pCVar1;
  
  pCVar1 = self->_xmlTree;
  if (pCVar1 != setXmlTree) {
    if (pCVar1 != (CFTree *)0x0) {
      _CFRelease(pCVar1);
    }
    pCVar1 = (CFTree *)_CFRetain(setXmlTree);
    self->_xmlTree = pCVar1;
  }
  return;
}

*/
- (void)setXmlTree:(struct __CFTree *)aTree
{
    if (_xmlTree != aTree) {
        if (_xmlTree != NULL) {
            CFRelease(_xmlTree);
        }
        _xmlTree = (CFXMLTreeRef)CFRetain(aTree);
    }
}

- (struct __CFTree *)xmlTree
{
    return _xmlTree;
}

- (void)setFileWrapperRepresentation:(id)aRepresentation
{
    if (_fileWrapperRepresentation != aRepresentation) {
        [_fileWrapperRepresentation release];
        _fileWrapperRepresentation = [aRepresentation retain];
    }
}

- (id)fileWrapperRepresentation
{
    return _fileWrapperRepresentation;
}

- (void)dealloc
{
    _delegate = nil;
    _parentObject = nil;
    if (_xmlTree != nil) {
        CFRelease(_xmlTree);
    }
    [super dealloc];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000ba99d @ 000ba99d, 105 bytes * /

id FUN_000ba99d(KeynoteParser *self,SEL _cmd,CFTree *initWithXMLTree,id context)

{
  id self_00;
  undefined4 uVar1;
  KeynoteParser *local_14;
  undefined *local_10;
  
  local_14 = self;
  local_10 = PTR_s_NSObject_0034fa30;
  self_00 = _objc_msgSendSuper(&local_14,sel_init);
  if ((self_00 == (id)0x0) || (initWithXMLTree == (CFTree *)0x0)) {
    _objc_msgSend(self_00,sel_release);
    self_00 = (id)0x0;
  }
  else {
    uVar1 = _CFRetain(initWithXMLTree);
    *(undefined4 *)((int)self_00 + 8) = uVar1;
  }
  return self_00;
}

*/
- (id)initWithXMLTree:(struct __CFTree *)aTree context:(id)aContext
{
    self = [super init];
    if (self == nil || aTree == NULL) {
        [self release];
        return nil;
    }
    _xmlTree = (CFXMLTreeRef)CFRetain(aTree);
    return self;
}

@end

@implementation NSObject (KeynoteParserDelegate)

- (void)keynoteParser:(id)aParser didParseChild:(id)aChild forObject:(id)aObject
{

}

- (void)keynoteParser:(id)aParser didParseAttributes:(id)aAttributes forObject:(id)aObject
{

}

- (void)keynoteParser:(id)aParser didParseProperties:(id)aProperties
{

}

- (void)keynoteParser:(id)aParser didParseChild:(struct __CFTree *)aChild
{

}

@end

