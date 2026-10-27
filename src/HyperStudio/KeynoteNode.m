#import "KeynoteNode.h"

@implementation KeynoteNode

/* i386 ivar offsets: _nodeId=0x4, _nodeIdRef=0x8, _nodeIdent=0xc, _nodeParentIdent=0x10, _nodeAttributes=0x14, _xmlPath=0x18, _rootNode=0x1c, _parentNode=0x20, _name=0x24, _xmlTree=0x28, _children=0x2c */

- (id)firstKeynoteObjectForXMLPath:(id)aPath
{
    id self_00;

    self_00 = [self keynoteObjectForXMLPath:aPath];
    if ([self_00 isKindOfClass:[NSArray class]]) {
        self_00 = [self_00 extraFirstObject];
    }
    return self_00;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b4b71 @ 000b4b71, 372 bytes * /

id FUN_000b4b71(KeynoteNode *self,SEL _cmd,id keynoteObjectForXMLPath)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  cfstringStruct *self_01;
  SEL op;
  cfstringStruct *pcVar3;
  cfstringStruct *pcVar4;
  int local_14;
  
  pcVar3 = &cfstr__;
  self_00 = _objc_msgSend(keynoteObjectForXMLPath,sel_componentsSeparatedByString_,&cfstr__);
  local_14 = 0;
  pvVar1 = _objc_msgSend(self_00,sel_count);
  do {
    if ((int)pvVar1 <= local_14) {
      return self;
    }
    pvVar2 = _objc_msgSend(cls_NSArray,sel_class,pcVar3);
    pvVar2 = _objc_msgSend(self,sel_isKindOfClass_,pvVar2);
    if ((char)pvVar2 != '\0') {
      self = _objc_msgSend(self,sel_objectAtIndex_,0);
    }
    self_01 = _objc_msgSend(self_00,sel_objectAtIndex_,local_14);
    pcVar3 = &cfstr__;
    pvVar2 = _objc_msgSend(self_01,sel_isEqualToString_,&cfstr__);
    if ((char)pvVar2 == '\0') {
      pcVar3 = &cfstr___;
      pvVar2 = _objc_msgSend(self_01,sel_isEqualToString_,&cfstr___);
      op = sel_parentNode;
      if ((char)pvVar2 == '\0') {
        pcVar4 = &cfstr_empty;
        pvVar2 = _objc_msgSend(self_01,sel_isEqualToString_,&cfstr_empty);
        op = sel_childForName_;
        pcVar3 = self_01;
        if ((char)pvVar2 != '\0') {
          local_14 = local_14 + 1;
          op = sel_rootNode;
          pcVar3 = pcVar4;
        }
      }
      self = _objc_msgSend(self,op,pcVar3);
      if (self == (KeynoteNode *)0x0) {
        return (id)0x0;
      }
    }
    local_14 = local_14 + 1;
  } while( true );
}

*/
- (id)keynoteObjectForXMLPath:(id)aPath
{
    NSArray *components = [aPath componentsSeparatedByString:@"/"];
    NSUInteger count = [components count];
    id node = self;
    for (NSUInteger index = 0; index < count; index++) {
        if ([node isKindOfClass:[NSArray class]]) {
            node = [node objectAtIndex:0];
        }
        NSString *component = [components objectAtIndex:index];
        if (![component isEqualToString:@"."]) {
            if ([component isEqualToString:@".."]) {
                node = [node parentNode];
            } else if ([component isEqualToString:@""]) {
                index++;
                node = [node rootNode];
            } else {
                node = [node childForName:component];
            }
            if (node == nil) {
                return nil;
            }
        }
    }
    return node;
    return 0;
}

- (void)removeAllChildren
{
    [[self children] removeAllObjects];
}

- (void)removeChild:(id)aChild
{
    NSUInteger pvVar1_2;

    pvVar1_2 = [[self children] indexOfObject:aChild];
    if (pvVar1_2 != NSNotFound) {
        [[self children] removeObjectAtIndex:pvVar1_2];
    }
}

- (void)addChild:(id)aChild
{
    [[self children] addObject:aChild];
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b4dd6 @ 000b4dd6, 293 bytes * /

id FUN_000b4dd6(KeynoteNode *self,SEL _cmd,id childForName)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  undefined4 local_14;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar1 = _objc_msgSend(self,sel_children);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if ((int)pvVar1 < 1) {
    local_14 = (id)0x0;
  }
  else {
    iVar4 = 0;
    local_14 = (id)0x0;
    do {
      pvVar2 = _objc_msgSend(self,sel_children);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,iVar4);
      pvVar3 = _objc_msgSend(pvVar2,sel_name);
      pvVar3 = _objc_msgSend(pvVar3,sel_isEqualToString_,childForName);
      if ((char)pvVar3 != '\0') {
        if (local_14 == (id)0x0) {
          local_14 = pvVar2;
        }
        _objc_msgSend(self_00,sel_addObject_,pvVar2);
      }
      iVar4 = iVar4 + 1;
    } while (iVar4 < (int)pvVar1);
  }
  pvVar1 = _objc_msgSend(self_00,sel_count);
  if ((id)0x1 < pvVar1) {
    local_14 = self_00;
  }
  return local_14;
}

*/
- (id)childForName:(id)aName
{
    NSMutableArray *matches = [NSMutableArray array];
    id first = nil;
    NSInteger count = [[self children] count];
    for (NSInteger index = 0; index < count; index++) {
        id child = [[self children] objectAtIndex:index];
        if ([[child name] isEqualToString:aName]) {
            if (first == nil) {
                first = child;
            }
            [matches addObject:child];
        }
    }
    if ([matches count] > 1) {
        return matches;
    }
    return first;
    return 0;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b4efb @ 000b4efb, 256 bytes * /

id FUN_000b4efb(KeynoteNode *self,SEL _cmd,Class childForClass)

{
  id self_00;
  id pvVar1;
  id pvVar2;
  id pvVar3;
  int iVar4;
  undefined4 local_14;
  
  self_00 = _objc_msgSend(cls_NSMutableArray,sel_array);
  pvVar1 = _objc_msgSend(self,sel_children);
  pvVar1 = _objc_msgSend(pvVar1,sel_count);
  if ((int)pvVar1 < 1) {
    local_14 = (id)0x0;
  }
  else {
    iVar4 = 0;
    local_14 = (id)0x0;
    do {
      pvVar2 = _objc_msgSend(self,sel_children);
      pvVar2 = _objc_msgSend(pvVar2,sel_objectAtIndex_,iVar4);
      pvVar3 = _objc_msgSend(pvVar2,sel_isKindOfClass_,childForClass);
      if ((char)pvVar3 != '\0') {
        if (local_14 == (id)0x0) {
          local_14 = pvVar2;
        }
        _objc_msgSend(self_00,sel_addObject_,pvVar2);
      }
      iVar4 = iVar4 + 1;
    } while (iVar4 < (int)pvVar1);
  }
  pvVar1 = _objc_msgSend(self_00,sel_count);
  if ((id)0x1 < pvVar1) {
    local_14 = self_00;
  }
  return local_14;
}

*/
- (id)childForClass:(Class)aClass
{
    NSMutableArray *matches = [NSMutableArray array];
    id first = nil;
    NSInteger count = [[self children] count];
    for (NSInteger index = 0; index < count; index++) {
        id child = [[self children] objectAtIndex:index];
        if ([child isKindOfClass:aClass]) {
            if (first == nil) {
                first = child;
            }
            [matches addObject:child];
        }
    }
    if ([matches count] > 1) {
        return matches;
    }
    return first;
    return 0;
}

- (void)setChildren:(id)aChildren
{
    if (_children != aChildren) {
        [_children release];
        _children = [aChildren retain];
    }
}

- (id)children
{
    return _children;
}

/* --- i386 decompilation (Ghidra) ---
/* FUN_000b5046 @ 000b5046, 51 bytes * /

void FUN_000b5046(KeynoteNode *self,SEL _cmd,CFTree *setXmlTree)

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
        _xmlTree = (CFTreeRef)CFRetain(aTree);
    }
}

- (struct __CFTree *)xmlTree
{
    return _xmlTree;
}

- (void)setName:(id)aName
{
    if (_name != aName) {
        [_name release];
        _name = [aName retain];
    }
}

- (id)name
{
    return _name;
}

- (void)setParentNode:(id)aNode
{
    _parentNode = aNode;
}

- (id)parentNode
{
    return _parentNode;
}

- (id)content
{
    return [[self rootNode] content];
}

- (id)cache
{
    id pvVar1_3;

    if (![[self rootNode] conformsToProtocol:@protocol(KeynoteCache)]) {
        pvVar1_3 = nil;
    }
    else {
        pvVar1_3 = [self rootNode];
    }
    return pvVar1_3;
}

- (void)setRootNode:(id)aNode
{
    _rootNode = aNode;
}

- (id)rootNode
{
    return _rootNode;
}

- (void)setXmlPath:(id)aPath
{
    if (_xmlPath != aPath) {
        [_xmlPath release];
        _xmlPath = [aPath retain];
    }
}

- (id)xmlPath
{
    id pvVar1;

    pvVar1 = _xmlPath;
    if (pvVar1 == nil) {
        [self setXmlPath:[[[self parentNode] xmlPath] stringByAppendingPathComponent:[self name]]];
        pvVar1 = _xmlPath;
    }
    return pvVar1;
}

- (void)setNodeAttributes:(id)aAttributes
{
    id pvVar1;

    if (_nodeAttributes != aAttributes) {
        [_nodeAttributes release];
        pvVar1 = [aAttributes retain];
        _nodeAttributes = pvVar1;
        [self setNodeId:[pvVar1 objectForKey:@"ID"]];
        [self setNodeIdRef:[_nodeAttributes objectForKey:@"IDREF"]];
        [self setNodeIdent:[_nodeAttributes objectForKey:@"ident"]];
        [self setNodeParentIdent:[_nodeAttributes objectForKey:@"parent-ident"]];
    }
}

- (id)nodeAttributes
{
    return _nodeAttributes;
}

- (void)setNodeParentIdent:(id)aIdent
{
    if (aIdent != nil) {
        if (_nodeParentIdent != aIdent) {
            [_nodeParentIdent release];
            _nodeParentIdent = [aIdent retain];
        }
    }
}

- (id)nodeParentIdent
{
    return _nodeParentIdent;
}

- (void)setNodeIdent:(id)aIdent
{
    if (aIdent != nil) {
        if (_nodeIdent != aIdent) {
            [_nodeIdent release];
            _nodeIdent = [aIdent retain];
        }
    }
}

- (id)nodeIdent
{
    return _nodeIdent;
}

- (void)setNodeIdRef:(id)aRef
{
    if (aRef != nil) {
        if (_nodeIdRef != aRef) {
            [_nodeIdRef release];
            _nodeIdRef = [aRef retain];
        }
    }
}

- (id)nodeIdRef
{
    return _nodeIdRef;
}

- (void)setNodeId:(id)aId
{
    if (aId != nil) {
        if (_nodeId != aId) {
            [_nodeId release];
            _nodeId = [aId retain];
        }
    }
}

- (id)nodeId
{
    return _nodeId;
}

- (void)dealloc
{
    [_nodeId release];
    [_nodeIdRef release];
    [_nodeIdent release];
    [_nodeParentIdent release];
    [_nodeAttributes release];
    [_name release];
    if (_xmlTree != nil) {
        CFRelease(_xmlTree);
    }
    [_children release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _children = [NSMutableArray new];
    }
    return self;
}

@end

