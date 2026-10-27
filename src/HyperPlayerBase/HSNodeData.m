#import "HSNodeData.h"
// Base class of a node's shared data, identified by its own UID. Node
// data keys map to node keys for change notification; the UID has none.

@implementation HSNodeData

+ (id)nodeDataKeysToNodeKeysMap
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    [map setObject:[NSNull null] forKey:HSNodeDataUIDKey];
    return map;
}

+ (id)nodeKeysForNodeDataKeys:(id)aKeys
{
    NSMutableSet *keys = [[[NSMutableSet alloc] initWithCapacity:[aKeys count]] autorelease];
    NSDictionary *map = [self nodeDataKeysToNodeKeysMap];
    NSEnumerator *enumerator = [aKeys objectEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        id nodeKey = [map objectForKey:key];
        if (!nodeKey)
            [keys addObject:key];
        else if (nodeKey != [NSNull null])
            [keys addObject:nodeKey];
    }
    return keys;
}

- (id)localCopy
{
    id copy = [self copy];
    [copy setNodeDataUID:[HSUID UID]];
    return copy;
}

- (id)copyWithZone:(NSZone *)aZone
{
    return [[[self class] objectWithExtraDictionary:[self extraDictionaryRepresentation] zone:aZone] retain];
}

- (void)setHypertextLinkContainer:(id)aContainer
{
}

// Old documents kept hypertext links in node data; they now load into
// the owning object.
- (id)hypertextLinkContainer
{
    return [HSHypertextLinkLegacyLoading loaderWithHyperObject:[[self owner] anyOwningObjectForNodeData:self]];
}

- (id)keysForExtraLoadingWithCodingContext:(id)aContext
{
    return [[super keysForExtraLoadingWithCodingContext:aContext] arrayByAddingObject:@"hypertextLinkContainer"];
}

- (id)keysForExtraStoringWithCodingContext:(id)aContext
{
    return [NSArray arrayWithObject:HSNodeDataUIDKey];
}

- (void)setNodeDataUID:(id)aUID
{
    [aUID retain];
    [_nodeDataUID release];
    _nodeDataUID = aUID;
}

- (id)nodeDataUID
{
    return _nodeDataUID;
}

- (BOOL)hasOwner
{
    return _owner != nil;
}

- (void)setOwner:(id)aOwner
{
    _owner = aOwner;
}

- (id)owner
{
    return _owner;
}

- (void)dealloc
{
    [_nodeDataUID release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
        _nodeDataUID = [[HSUID UID] retain];
    return self;
}

@end
