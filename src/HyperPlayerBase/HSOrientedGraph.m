#import "HSOrientedGraph.h"
// A directed graph of vertices (each representing an object), sorted
// topologically by a depth-first search that records each vertex's colour
// (0 white, 1 grey, 2 black), discovery time ("distance") and finishing time.
@implementation HSOrientedGraph
// By the vertices' topologicalSortCompare: (on the search's times).
- (id)topologicalSort
{
    [self deepFirstSearch];
    NSMutableArray *sorted = [[NSMutableArray alloc] initWithArray:[self vertices]];
    [sorted sortUsingSelector:@selector(topologicalSortCompare:)];
    NSMutableArray *objects = [NSMutableArray new];
    for (id vertex in sorted)
        [objects addObject:[vertex representedObject]];
    [sorted release];
    return [objects autorelease];
}
- (void)deepFirstSearch
{
    NSMutableDictionary *pi = [NSMutableDictionary new];
    for (id vertex in [self vertices])
        [vertex setUserInfo:[NSNumber numberWithInt:0] forKey:HSGraphVertexColorKey];
    _time = 0;
    for (id vertex in [self vertices]) {
        if ([[[vertex userInfo] objectForKey:HSGraphVertexColorKey] intValue] == 0)
            [self deepFirstSearchVisitVertex:vertex piDictionary:pi];
    }
    [pi release];
}
// pi maps each vertex to the one it was reached from.
- (void)deepFirstSearchVisitVertex:(id)aVertex piDictionary:(id)aDictionary
{
    [aVertex setUserInfo:[NSNumber numberWithInt:1] forKey:HSGraphVertexColorKey];
    [aVertex setUserInfo:[NSNumber numberWithInt:++_time] forKey:HSGraphVertexDistanceKey];
    for (id adjacent in [aVertex adjacencyList]) {
        if ([[[adjacent userInfo] objectForKey:HSGraphVertexColorKey] intValue] == 0) {
            [aDictionary setObject:aVertex forKey:adjacent];
            [self deepFirstSearchVisitVertex:adjacent piDictionary:aDictionary];
        }
    }
    [aVertex setUserInfo:[NSNumber numberWithInt:2] forKey:HSGraphVertexColorKey];
    [aVertex setUserInfo:[NSNumber numberWithInt:++_time] forKey:HSGraphVertexTimeKey];
}
- (void)disconnectVertex:(id)aVertex fromVertex:(id)aVertex2
{
    [aVertex disconnectFromVertex:aVertex2];
}
- (void)connectVertex:(id)aVertex toVertex:(id)aVertex2
{
    [aVertex connectToVertex:aVertex2];
}
// The original disconnects each vertex connected to the removed one from
// itself instead of from the removed vertex; fixed. A copy of the adjacency
// list is enumerated, since disconnecting changes it.
- (void)removeVertex:(id)aVertex
{
    [[self mutableVertices] removeObject:aVertex];
    for (id vertex in [self vertices]) {
        if ([vertex connectedToVertex:aVertex])
            [vertex disconnectFromVertex:aVertex];
    }
    for (id adjacent in [[[aVertex adjacencyList] copy] autorelease])
        [aVertex disconnectFromVertex:adjacent];
}
- (void)addVertex:(id)aVertex
{
    [[self mutableVertices] addObject:aVertex];
}
- (id)vertexWithRepresentedObject:(id)aObject
{
    for (id vertex in [self vertices]) {
        if ([vertex representedObject] == aObject)
            return vertex;
    }
    return nil;
}
- (id)vertices
{
    return [[[self mutableVertices] copy] autorelease];
}
- (id)mutableVertices
{
    if (_vertices == nil)
        _vertices = [NSMutableArray new];
    return _vertices;
}
- (void)dealloc
{
    [_vertices release];
    [super dealloc];
}
@end
