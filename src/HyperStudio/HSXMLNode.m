#import "HSXMLNode.h"

@implementation HSXMLNode

- (id)data
{
    if (_root == NULL)
        return nil;
    return [(id)CFXMLTreeCreateXMLData(NULL, _root) autorelease];
}

// Replaces the node with an element node carrying the new attributes, moving the children over.
- (void)setAttributes:(id)aAttributes
{
    if (_root == NULL || aAttributes == nil)
        return;
    CFXMLNodeRef node = CFXMLTreeGetNode(_root);
    if (node == NULL)
        return;
    CFStringRef name = CFXMLNodeGetString(node);
    if (name == NULL)
        return;
    CFXMLElementInfo info;
    memset(&info, 0, sizeof(info));
    if ([aAttributes count] != 0) {
        info.attributes = CFDictionaryCreateCopy(NULL, (CFDictionaryRef)aAttributes);
        info.attributeOrder = CFArrayCreateCopy(NULL, (CFArrayRef)[aAttributes allKeys]);
    }
    info.isEmpty = [aAttributes count] == 0;
    CFXMLNodeRef newNode = CFXMLNodeCreate(NULL, CFXMLNodeGetTypeCode(node), name, &info, CFXMLNodeGetVersion(node));
    if (info.attributes != NULL)
        CFRelease(info.attributes);
    if (info.attributeOrder != NULL)
        CFRelease(info.attributeOrder);
    if (newNode == NULL)
        return;
    CFXMLTreeRef newTree = CFXMLTreeCreateWithNode(NULL, newNode);
    CFRelease(newNode);
    if (newTree == NULL)
        return;
    [self _moveChildrenAndReplaceRootWithTree:newTree];
    CFRelease(newTree);
}

- (id)attributes
{
    if (_root == NULL)
        return nil;
    CFXMLNodeRef node = CFXMLTreeGetNode(_root);
    if (node == NULL || CFXMLNodeGetTypeCode(node) != kCFXMLNodeTypeElement)
        return nil;
    const CFXMLElementInfo *info = CFXMLNodeGetInfoPtr(node);
    if (info == NULL || info->isEmpty)
        return nil;
    return [NSDictionary dictionaryWithDictionary:(NSDictionary *)info->attributes];
}

- (void)setName:(id)aName
{
    if (_root == NULL)
        return;
    CFXMLNodeRef node = CFXMLTreeGetNode(_root);
    if (node == NULL)
        return;
    CFXMLNodeTypeCode type = CFXMLNodeGetTypeCode(node);
    if (type == 0)
        return;
    CFXMLNodeRef newNode = CFXMLNodeCreate(NULL, type, (CFStringRef)aName, CFXMLNodeGetInfoPtr(node), CFXMLNodeGetVersion(node));
    if (newNode == NULL)
        return;
    CFXMLTreeRef newTree = CFXMLTreeCreateWithNode(NULL, newNode);
    CFRelease(newNode);
    if (newTree == NULL)
        return;
    [self _moveChildrenAndReplaceRootWithTree:newTree];
    CFRelease(newTree);
}

// Fix: a node without a parent now takes over the new tree too; the original left its children in the discarded tree.
- (void)_moveChildrenAndReplaceRootWithTree:(CFTreeRef)aTree
{
    CFIndex count = CFTreeGetChildCount(_root);
    for (CFIndex i = 0; i < count; i++) {
        CFTreeRef child = CFTreeGetFirstChild(_root);
        if (child == NULL)
            return;
        CFRetain(child);
        CFTreeRemove(child);
        CFTreeAppendChild(aTree, child);
        CFRelease(child);
    }
    CFTreeRef parent = CFTreeGetParent(_root);
    if (parent != NULL) {
        CFTreeRemove(_root);
        CFTreeAppendChild(parent, aTree);
    }
    CFRelease(_root);
    _root = (struct __CFTree *)CFRetain(aTree);
}

- (struct __CFTree *)elementNamed:(id)aNamed inTree:(struct __CFTree *)aTree
{
    if (aTree == NULL)
        return NULL;
    CFIndex count = CFTreeGetChildCount(aTree);
    for (CFIndex i = 0; i < count; i++) {
        CFTreeRef child = CFTreeGetChildAtIndex(aTree, i);
        if (child != NULL && [[self nameForTree:(struct __CFTree *)child] isEqual:aNamed])
            return (struct __CFTree *)child;
        struct __CFTree *found = [self elementNamed:aNamed inTree:(struct __CFTree *)child];
        if (found != NULL && [[self nameForTree:found] isEqual:aNamed])
            return found;
    }
    return NULL;
}

- (id)elementNamed:(id)aNamed
{
    struct __CFTree *tree = [self elementNamed:aNamed inTree:_root];
    if (tree == NULL)
        return nil;
    return [[[HSXMLNode alloc] initWithTree:tree] autorelease];
}

// Fix: a node without a name yields nil instead of raising.
- (id)name
{
    NSString *name = [self nameForTree:_root];
    return name ? [NSString stringWithString:name] : nil;
}

- (id)nameForTree:(struct __CFTree *)aTree
{
    if (aTree == NULL)
        return nil;
    return (id)CFXMLNodeGetString(CFXMLTreeGetNode(aTree));
}

- (void)dealloc
{
    if (_root != NULL)
        CFRelease(_root);
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[HSXMLNode allocWithZone:aZone] initWithData:[self data]];
}

- (id)initWithTree:(struct __CFTree *)aTree
{
    self = [self init];
    if (self != nil) {
        if (aTree == NULL) {
            [self release];
            return nil;
        }
        _root = (struct __CFTree *)CFRetain(aTree);
    }
    return self;
}

- (id)initWithData:(id)aData
{
    self = [self init];
    if (self != nil) {
        CFDictionaryRef error = NULL;
        _root = (struct __CFTree *)CFXMLTreeCreateFromDataWithError(kCFAllocatorDefault, (CFDataRef)aData, NULL, 0, 1, &error);
        if (error != NULL) {
            CFRelease(error);
            [self release];
            return nil;
        }
        if (_root == NULL) {
            [self release];
            return nil;
        }
    }
    return self;
}

@end
