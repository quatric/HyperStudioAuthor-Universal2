#import "HSGraphVertex.h"
// Vertex of a directed graph: a represented object, its outgoing edges,
// and scratch user info (key "f" holds the topological sort order).

@implementation HSGraphVertex

// Sorts by descending "f".
- (NSInteger)topologicalSortCompare:(id)aCompare
{
    return [[[aCompare userInfo] objectForKey:@"f"] intValue] - [[[self userInfo] objectForKey:@"f"] intValue];
}

- (void)setUserInfo:(id)aInfo forKey:(id)aKey
{
    if (!_userInfo)
        _userInfo = [NSMutableDictionary new];
    [_userInfo setObject:aInfo forKey:aKey];
}

- (id)userInfo
{
    return _userInfo;
}

- (void)setRepresentedObject:(id)aObject
{
    if (_representedObject != aObject) {
        [_representedObject release];
        _representedObject = [aObject retain];
    }
}

- (id)representedObject
{
    return _representedObject;
}

- (BOOL)connectedToVertex:(id)aVertex
{
    return [[self adjacencyList] containsObject:aVertex];
}

- (void)disconnectFromVertex:(id)aVertex
{
    [[self mutableAdjacencyList] removeObject:aVertex];
}

- (void)connectToVertex:(id)aVertex
{
    [[self mutableAdjacencyList] addObject:aVertex];
}

// The copy shares the represented object and the neighbor vertices.
- (id)copyWithZone:(NSZone *)aZone
{
    HSGraphVertex *copy = [[HSGraphVertex allocWithZone:aZone] initWithRepresentedObject:[self representedObject]];
    NSEnumerator *enumerator = [[self adjacencyList] objectEnumerator];
    id vertex;
    while ((vertex = [enumerator nextObject]))
        [copy connectToVertex:vertex];
    [copy setUserInfo:[[[self userInfo] copy] autorelease]];
    return copy;
}

- (id)adjacencyList
{
    return [[[self mutableAdjacencyList] copy] autorelease];
}

- (id)mutableAdjacencyList
{
    if (!_adjacencyList)
        _adjacencyList = [NSMutableArray new];
    return _adjacencyList;
}

// (A copied user info dictionary is immutable, so a later
// -setUserInfo:forKey: on it would throw, as in the original.)
- (void)setUserInfo:(id)aInfo
{
    if (![_userInfo isEqual:aInfo]) {
        [_userInfo release];
        _userInfo = [aInfo retain];
    }
}

- (void)dealloc
{
    [_representedObject release];
    [_adjacencyList release];
    [_userInfo release];
    [super dealloc];
}

- (id)initWithRepresentedObject:(id)aObject
{
    self = [super init];
    if (self)
        [self setRepresentedObject:aObject];
    return self;
}

@end
